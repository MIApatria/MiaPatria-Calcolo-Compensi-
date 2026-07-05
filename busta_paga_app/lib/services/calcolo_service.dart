import '../models/busta_paga.dart';
import '../models/giorno_lavorativo.dart';
import '../models/impostazioni_calcolo.dart';
import '../models/voce_cedolino.dart';
import '../utils/date_utils.dart' as du;

/// Una singola riga di confronto ore/importo tra il calendario turni
/// compilato dall'utente e i valori riportati nella busta paga.
class DiscrepanzaVoce {
  final String categoria;
  final double oreCalendario;
  final double oreCedolino;
  final double? importoAtteso;
  final double? importoCedolino;
  final double tolleranzaOre;
  final double tolleranzaImporto;

  DiscrepanzaVoce({
    required this.categoria,
    required this.oreCalendario,
    required this.oreCedolino,
    this.importoAtteso,
    this.importoCedolino,
    required this.tolleranzaOre,
    required this.tolleranzaImporto,
  });

  double get differenzaOre => oreCalendario - oreCedolino;
  double? get differenzaImporto =>
      (importoAtteso != null && importoCedolino != null)
          ? importoAtteso! - importoCedolino!
          : null;

  bool get oreEntroTolleranza => differenzaOre.abs() <= tolleranzaOre;
  bool get importoEntroTolleranza =>
      differenzaImporto == null || differenzaImporto!.abs() <= tolleranzaImporto;

  bool get entroTolleranza => oreEntroTolleranza && importoEntroTolleranza;
}

/// Esito completo della verifica di un mese di calendario contro un cedolino.
class RisultatoVerifica {
  final List<DiscrepanzaVoce> righe;
  final double totaleOreCalendario;
  final double totaleOreCedolino;

  RisultatoVerifica({
    required this.righe,
    required this.totaleOreCalendario,
    required this.totaleOreCedolino,
  });

  bool get tuttoCorrisponde => righe.every((r) => r.entroTolleranza);

  double get differenzaOreTotale => totaleOreCalendario - totaleOreCedolino;

  /// Messaggio di verdetto pronto per essere mostrato in un banner, come
  /// richiesto: se le ore non corrispondono, indica esplicitamente quanto
  /// vale la discrepanza.
  String get messaggioVerdetto {
    if (tuttoCorrisponde) {
      return 'Le ore che hai segnato sul calendario corrispondono a quelle '
          'riportate in busta paga (entro le normali tolleranze di arrotondamento).';
    }
    final righeProblematiche = righe.where((r) => !r.entroTolleranza).toList();
    final dettagli = righeProblematiche.map((r) {
      final segno = r.differenzaOre > 0 ? 'in più' : 'in meno';
      final oreTesto = '${r.differenzaOre.abs().toStringAsFixed(2)} ore $segno';
      final importoTesto = (r.differenzaImporto != null && !r.importoEntroTolleranza)
          ? ' (circa ${r.differenzaImporto!.abs().toStringAsFixed(2)} € di differenza)'
          : '';
      return '${r.categoria}: $oreTesto rispetto al cedolino$importoTesto';
    }).join('; ');
    return 'Trovata una discrepanza tra calendario e busta paga. $dettagli.';
  }
}

class CalcoloService {
  final ImpostazioniCalcolo impostazioni;

  const CalcoloService(this.impostazioni);

  /// Aggrega le ore lavorate nel mese secondo il calendario turni,
  /// suddivise in feriali, domenicali e festive infrasettimanali.
  ({double feriali, double domenicali, double festive}) aggregaCalendario(
      Iterable<GiornoLavorativo> giorni) {
    double feriali = 0, domenicali = 0, festive = 0;
    for (final g in giorni) {
      if (!g.lavorato) continue;
      final ore = g.oreLavorate;
      if (g.isDomenica) {
        domenicali += ore;
      } else if (du.isFestivo(g.data)) {
        festive += ore;
      } else {
        feriali += ore;
      }
    }
    return (feriali: feriali, domenicali: domenicali, festive: festive);
  }

  /// Confronta il calendario di un mese con il cedolino corrispondente e
  /// produce l'esito dettagliato per categoria, con verdetto finale.
  ///
  /// Il confronto usa le TARIFFE stampate sul cedolino stesso (valore
  /// unitario delle singole voci) per stimare l'importo atteso: verifica
  /// quindi la coerenza interna aritmetica tra ore dichiarate e importi
  /// liquidati, non un audit indipendente della correttezza della tariffa
  /// contrattuale (che andrebbe verificata con l'ufficio paghe).
  RisultatoVerifica verificaMese(
      BustaPaga cedolino, Iterable<GiornoLavorativo> giorniMese) {
    final cal = aggregaCalendario(giorniMese);

    final oreOrdinarieCedolino = cedolino.oreVoce(CodiciVoce.oreOrdinarie);
    final oreSupplFerialeCedolino = cedolino.oreVoce(CodiciVoce.oreSupplPartTime30);
    final oreStraordinarioCedolino = cedolino.oreVoce(CodiciVoce.straordinario30);
    final oreFestiveCedolino = cedolino.oreVoce(CodiciVoce.oreFestive);
    final oreDomOrdCedolino = cedolino.oreVoce(CodiciVoce.maggiorazione10Domenicali);
    final oreDomSupplCedolino = cedolino.oreVoce(CodiciVoce.oreSupplPartTimeDomenica30);
    final oreFormazioneCedolino = cedolino.oreVoce(CodiciVoce.corsoFormazione);

    final domenicaliTotaliCedolino = oreDomOrdCedolino + oreDomSupplCedolino;

    final totaleOreCedolino = oreOrdinarieCedolino +
        oreSupplFerialeCedolino +
        oreStraordinarioCedolino +
        oreFestiveCedolino +
        oreDomSupplCedolino +
        oreFormazioneCedolino;

    final totaleOreCalendario = cal.feriali + cal.domenicali + cal.festive;

    // Ore feriali extra rispetto alle ore ordinarie contrattuali riportate
    // in busta (base per il confronto con supplementare + straordinario).
    final extraFerialiCalendario =
        (cal.feriali - oreOrdinarieCedolino).clamp(0, double.infinity);

    final valoreSuppl = cedolino.voce(CodiciVoce.oreSupplPartTime30)?.valoreUnitario;
    final valoreDomenicale =
        cedolino.voce(CodiciVoce.maggiorazione10Domenicali)?.valoreUnitario;
    final valoreFestivo = cedolino.voce(CodiciVoce.oreFestive)?.valoreUnitario;

    final righe = <DiscrepanzaVoce>[
      DiscrepanzaVoce(
        categoria: 'Totale ore lavorate',
        oreCalendario: totaleOreCalendario,
        oreCedolino: totaleOreCedolino,
        tolleranzaOre: impostazioni.tolleranzaOre,
        tolleranzaImporto: impostazioni.tolleranzaImporto,
      ),
      DiscrepanzaVoce(
        categoria: 'Ore supplementari/straordinario feriali',
        oreCalendario: extraFerialiCalendario.toDouble(),
        oreCedolino: oreSupplFerialeCedolino + oreStraordinarioCedolino,
        importoAtteso: valoreSuppl != null
            ? extraFerialiCalendario * valoreSuppl
            : null,
        importoCedolino: cedolino.competenzeVoce(CodiciVoce.oreSupplPartTime30) +
            cedolino.competenzeVoce(CodiciVoce.straordinario30),
        tolleranzaOre: impostazioni.tolleranzaOre,
        tolleranzaImporto: impostazioni.tolleranzaImporto,
      ),
      DiscrepanzaVoce(
        categoria: 'Ore domenicali',
        oreCalendario: cal.domenicali,
        oreCedolino: domenicaliTotaliCedolino,
        importoAtteso:
            valoreDomenicale != null ? cal.domenicali * valoreDomenicale : null,
        importoCedolino:
            cedolino.competenzeVoce(CodiciVoce.maggiorazione10Domenicali),
        tolleranzaOre: impostazioni.tolleranzaOre,
        tolleranzaImporto: impostazioni.tolleranzaImporto,
      ),
      DiscrepanzaVoce(
        categoria: 'Ore festive infrasettimanali',
        oreCalendario: cal.festive,
        oreCedolino: oreFestiveCedolino,
        importoAtteso: valoreFestivo != null ? cal.festive * valoreFestivo : null,
        importoCedolino: cedolino.competenzeVoce(CodiciVoce.oreFestive),
        tolleranzaOre: impostazioni.tolleranzaOre,
        tolleranzaImporto: impostazioni.tolleranzaImporto,
      ),
    ];

    return RisultatoVerifica(
      righe: righe,
      totaleOreCalendario: totaleOreCalendario,
      totaleOreCedolino: totaleOreCedolino,
    );
  }
}
