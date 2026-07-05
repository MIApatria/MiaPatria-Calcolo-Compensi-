import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';

import '../data/codici_voce_dizionario.dart';
import '../models/voce_cedolino.dart';
import '../utils/formatters.dart';

/// Risultato grezzo dell'importazione: testo riconosciuto, voci individuate
/// con un'euristica riga-per-riga e alcuni totali di riepilogo se trovati.
/// Va sempre presentato all'utente in un form di revisione prima di essere
/// salvato, perché il riconoscimento automatico di una tabella fitta come
/// quella del cedolino può contenere errori.
class BozzaImportata {
  final String testoGrezzo;
  final List<VoceCedolino> voci;
  final Map<String, double> campiRilevati;

  BozzaImportata({
    required this.testoGrezzo,
    required this.voci,
    required this.campiRilevati,
  });
}

class OcrService {
  final TextRecognizer _recognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  /// Riconosce il testo di una singola immagine (foto del cedolino).
  Future<BozzaImportata> analizzaImmagine(String pathImmagine) async {
    final input = InputImage.fromFilePath(pathImmagine);
    final recognized = await _recognizer.processImage(input);
    return _parseTesto(recognized.text);
  }

  /// Renderizza ogni pagina di un PDF come immagine e ne concatena il testo
  /// OCR. Funziona sia con PDF "scansionati" sia con PDF generati
  /// digitalmente dal software paghe (in quel caso l'OCR sul rendering è
  /// comunque affidabile perché il testo è nitido, non fotografato).
  Future<BozzaImportata> analizzaPdf(String pathPdf) async {
    final document = await PdfDocument.openFile(pathPdf);
    final buffer = StringBuffer();
    final voci = <VoceCedolino>[];
    final campi = <String, double>{};
    final tempDir = await getTemporaryDirectory();

    try {
      for (var i = 1; i <= document.pagesCount; i++) {
        final page = await document.getPage(i);
        final image = await page.render(
          width: page.width * 2.5,
          height: page.height * 2.5,
          format: PdfPageImageFormat.png,
        );
        await page.close();
        if (image == null) continue;

        final tempFile = File(
            '${tempDir.path}/busta_paga_pdf_page_$i.png');
        await tempFile.writeAsBytes(image.bytes);

        final parziale = await analizzaImmagine(tempFile.path);
        buffer.writeln(parziale.testoGrezzo);
        voci.addAll(parziale.voci);
        campi.addAll(parziale.campiRilevati);

        await tempFile.delete();
      }
    } finally {
      await document.close();
    }

    return BozzaImportata(
      testoGrezzo: buffer.toString(),
      voci: voci,
      campiRilevati: campi,
    );
  }

  void dispose() {
    _recognizer.close();
  }

  // ---------------- Parsing euristico ----------------

  BozzaImportata _parseTesto(String testo) {
    final righe = testo
        .split('\n')
        .map((r) => r.trim())
        .where((r) => r.isNotEmpty)
        .toList();

    final voci = <VoceCedolino>[];
    final campi = <String, double>{};

    final regexNumero = RegExp(r'-?\d{1,3}(?:\.\d{3})*,\d{2}');
    final regexCodiceIniziale = RegExp(r'^(\d{4})\b\s*(.*)$');

    for (final riga in righe) {
      // Riconosce una riga voce: inizia con un codice a 4 cifre presente
      // nel dizionario, seguito da testo e da 1-4 numeri in formato italiano.
      final matchCodice = regexCodiceIniziale.firstMatch(riga);
      if (matchCodice != null) {
        final codice = matchCodice.group(1)!;
        if (dizionarioCodiciVoce.containsKey(codice)) {
          final resto = matchCodice.group(2) ?? '';
          final numeri = regexNumero
              .allMatches(resto)
              .map((m) => parseNumeroItaliano(m.group(0)))
              .whereType<double>()
              .toList();
          final descrizione = resto.replaceAll(regexNumero, '').trim();
          voci.add(_costruisciVoce(codice, descrizione, numeri));
          continue;
        }
      }

      _cercaCampoRiepilogo(riga, regexNumero, campi);
    }

    return BozzaImportata(testoGrezzo: testo, voci: voci, campiRilevati: campi);
  }

  VoceCedolino _costruisciVoce(
      String codice, String descrizioneRiconosciuta, List<double> numeri) {
    final def = dizionarioCodiciVoce[codice];
    final descrizione =
        descrizioneRiconosciuta.isNotEmpty ? descrizioneRiconosciuta : (def?.descrizioneCedolino ?? '');

    // Euristica sul numero di valori trovati sulla riga:
    // 1 valore  -> quasi sempre ore/gg/mesi (voci informative) oppure un importo
    // 2 valori  -> valore unitario + ore/gg/mesi (competenza senza trattenuta)
    // 3 valori  -> valore unitario + ore/gg/mesi + competenza (o trattenuta)
    // 4 valori  -> valore unitario + ore/gg/mesi + trattenute + competenze
    double? valoreUnitario;
    double? oreGgMesi;
    double trattenute = 0;
    double competenze = 0;

    switch (numeri.length) {
      case 0:
        break;
      case 1:
        if (def?.tipo == TipoVoce.informativo) {
          oreGgMesi = numeri[0];
        } else if (def?.tipo == TipoVoce.trattenuta) {
          trattenute = numeri[0];
        } else {
          competenze = numeri[0];
        }
        break;
      case 2:
        valoreUnitario = numeri[0];
        oreGgMesi = numeri[1];
        break;
      case 3:
        valoreUnitario = numeri[0];
        oreGgMesi = numeri[1];
        if (def?.tipo == TipoVoce.trattenuta) {
          trattenute = numeri[2];
        } else {
          competenze = numeri[2];
        }
        break;
      default:
        valoreUnitario = numeri[0];
        oreGgMesi = numeri[1];
        trattenute = numeri[2];
        competenze = numeri[3];
    }

    return VoceCedolino(
      codice: codice,
      descrizione: descrizione,
      sociale: false,
      fiscale: false,
      valoreUnitario: valoreUnitario,
      oreGgMesi: oreGgMesi,
      trattenute: trattenute,
      competenze: competenze,
    );
  }

  void _cercaCampoRiepilogo(
      String riga, RegExp regexNumero, Map<String, double> campi) {
    final righeMaiuscole = riga.toUpperCase();
    void cerca(String etichetta, String chiave) {
      if (righeMaiuscole.contains(etichetta) && !campi.containsKey(chiave)) {
        final match = regexNumero.firstMatch(riga);
        final valore = match != null ? parseNumeroItaliano(match.group(0)) : null;
        if (valore != null) campi[chiave] = valore;
      }
    }

    cerca('NETTO', 'netto');
    cerca('TOTALE COMPETENZE', 'totaleCompetenze');
    cerca('TOTALE TRATTENUTE', 'totaleTrattenute');
    cerca('RETR. ORARIA', 'retribuzioneOraria');
    cerca('PAGA BASE', 'pagaBase');
    cerca('CONTINGENZA', 'contingenza');
    cerca('IMPORTO SCATTI', 'importoScatti');
    cerca('% P.TIME', 'percentualePartTime');
  }
}
