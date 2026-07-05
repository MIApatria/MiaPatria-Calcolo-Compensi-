import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../data/codici_voce_dizionario.dart';
import '../models/busta_paga.dart';
import '../models/voce_cedolino.dart';
import '../providers/buste_paga_provider.dart';
import '../utils/formatters.dart';

class _RigaVoceControllers {
  final codice = TextEditingController();
  final descrizione = TextEditingController();
  final valoreUnitario = TextEditingController();
  final oreGgMesi = TextEditingController();
  final trattenute = TextEditingController();
  final competenze = TextEditingController();
  bool sociale;
  bool fiscale;

  _RigaVoceControllers({VoceCedolino? da})
      : sociale = da?.sociale ?? false,
        fiscale = da?.fiscale ?? false {
    if (da != null) {
      codice.text = da.codice;
      descrizione.text = da.descrizione;
      valoreUnitario.text = da.valoreUnitario != null ? formattaNumero(da.valoreUnitario) : '';
      oreGgMesi.text = da.oreGgMesi != null ? formattaNumero(da.oreGgMesi) : '';
      trattenute.text = da.trattenute != 0 ? formattaNumero(da.trattenute) : '';
      competenze.text = da.competenze != 0 ? formattaNumero(da.competenze) : '';
    }
  }

  VoceCedolino toVoce() => VoceCedolino(
        codice: codice.text.trim(),
        descrizione: descrizione.text.trim().isNotEmpty
            ? descrizione.text.trim()
            : (dizionarioCodiciVoce[codice.text.trim()]?.descrizioneCedolino ?? ''),
        sociale: sociale,
        fiscale: fiscale,
        valoreUnitario: parseNumeroItaliano(valoreUnitario.text),
        oreGgMesi: parseNumeroItaliano(oreGgMesi.text),
        trattenute: parseNumeroItaliano(trattenute.text) ?? 0,
        competenze: parseNumeroItaliano(competenze.text) ?? 0,
      );

  void dispose() {
    codice.dispose();
    descrizione.dispose();
    valoreUnitario.dispose();
    oreGgMesi.dispose();
    trattenute.dispose();
    competenze.dispose();
  }
}

/// Form completo per l'inserimento manuale di un cedolino oppure per la
/// revisione/correzione di una bozza importata via foto/PDF con OCR.
class PayslipFormScreen extends StatefulWidget {
  final BustaPaga? bustaEsistente;
  final List<VoceCedolino>? vociIniziali;
  final String? immaginePath;
  final String origine;

  const PayslipFormScreen({
    super.key,
    this.bustaEsistente,
    this.vociIniziali,
    this.immaginePath,
    this.origine = 'manuale',
  });

  @override
  State<PayslipFormScreen> createState() => _PayslipFormScreenState();
}

class _PayslipFormScreenState extends State<PayslipFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final _mese = TextEditingController(
      text: (widget.bustaEsistente?.mese ?? DateTime.now().month).toString());
  late final _anno = TextEditingController(
      text: (widget.bustaEsistente?.anno ?? DateTime.now().year).toString());
  late final _numeroDocumento =
      TextEditingController(text: widget.bustaEsistente?.numeroDocumento ?? '');
  late final _qualifica =
      TextEditingController(text: widget.bustaEsistente?.qualifica ?? 'OPERAIO');
  late final _livello = TextEditingController(text: widget.bustaEsistente?.livello ?? '6S');
  late final _provincia =
      TextEditingController(text: widget.bustaEsistente?.provinciaLavoro ?? '');
  late final _percPartTime = TextEditingController(
      text: formattaNumero(widget.bustaEsistente?.percentualePartTime ?? 100));
  late final _pagaBase =
      TextEditingController(text: formattaNumero(widget.bustaEsistente?.pagaBase ?? 0));
  late final _contingenza =
      TextEditingController(text: formattaNumero(widget.bustaEsistente?.contingenza ?? 0));
  late final _importoScatti =
      TextEditingController(text: formattaNumero(widget.bustaEsistente?.importoScatti ?? 0));
  late final _retribuzioneOraria = TextEditingController(
      text: widget.bustaEsistente?.retribuzioneOraria != null
          ? formattaNumero(widget.bustaEsistente!.retribuzioneOraria)
          : '');
  late final _totaleRetribuzione = TextEditingController(
      text: formattaNumero(widget.bustaEsistente?.totaleRetribuzione ?? 0));

  late final _inpsImponibile =
      TextEditingController(text: formattaNumero(widget.bustaEsistente?.inpsImponibile ?? 0));
  late final _inpsTrattenute =
      TextEditingController(text: formattaNumero(widget.bustaEsistente?.inpsTrattenute ?? 0));
  late final _inailImponibile =
      TextEditingController(text: formattaNumero(widget.bustaEsistente?.inailImponibile ?? 0));
  late final _irpefMoImponibile = TextEditingController(
      text: formattaNumero(widget.bustaEsistente?.irpefMoImponibile ?? 0));
  late final _irpefMoTrattenute = TextEditingController(
      text: formattaNumero(widget.bustaEsistente?.irpefMoTrattenute ?? 0));
  late final _aliquotaMaxIrpef = TextEditingController(
      text: formattaNumero(widget.bustaEsistente?.aliquotaMaxIrpef ?? 0));

  late final _tfrElementiUtili = TextEditingController(
      text: widget.bustaEsistente?.tfrElementiUtili != null
          ? formattaNumero(widget.bustaEsistente!.tfrElementiUtili)
          : '');
  late final _tfrQuotaMese = TextEditingController(
      text: widget.bustaEsistente?.tfrQuotaMese != null
          ? formattaNumero(widget.bustaEsistente!.tfrQuotaMese)
          : '');

  late final _totaleTrattenute = TextEditingController(
      text: formattaNumero(widget.bustaEsistente?.totaleTrattenute ?? 0));
  late final _totaleCompetenze = TextEditingController(
      text: formattaNumero(widget.bustaEsistente?.totaleCompetenze ?? 0));
  late final _netto =
      TextEditingController(text: formattaNumero(widget.bustaEsistente?.netto ?? 0));

  final List<_RigaVoceControllers> _righeVoci = [];

  @override
  void initState() {
    super.initState();
    final vociDaCaricare = widget.vociIniziali ?? widget.bustaEsistente?.voci ?? [];
    for (final v in vociDaCaricare) {
      _righeVoci.add(_RigaVoceControllers(da: v));
    }
    if (_righeVoci.isEmpty) _righeVoci.add(_RigaVoceControllers());
  }

  @override
  void dispose() {
    for (final r in _righeVoci) {
      r.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modifica = widget.bustaEsistente != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(modifica ? 'Modifica cedolino' : 'Nuovo cedolino'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _salva),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (widget.vociIniziali != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  border: Border.all(color: Colors.amber),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Controlla i valori riconosciuti automaticamente: il '
                  'riconoscimento del testo può contenere errori, soprattutto '
                  'su tabelle fitte. Correggi prima di salvare.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            _sezione('Periodo e anagrafica', [
              _riga([
                _campo(_mese, 'Mese (1-12)', numerico: true),
                _campo(_anno, 'Anno', numerico: true),
              ]),
              _campo(_numeroDocumento, 'Numero documento'),
              _riga([
                _campo(_qualifica, 'Qualifica'),
                _campo(_livello, 'Livello'),
                _campo(_provincia, 'Provincia'),
              ]),
              _campo(_percPartTime, 'Percentuale part-time (%)', numerico: true),
            ]),
            _sezione('Elementi retributivi fissi', [
              _riga([
                _campo(_pagaBase, 'Paga base', numerico: true),
                _campo(_contingenza, 'Contingenza', numerico: true),
                _campo(_importoScatti, 'Importo scatti', numerico: true),
              ]),
              _riga([
                _campo(_retribuzioneOraria, 'Retr. oraria', numerico: true),
                _campo(_totaleRetribuzione, 'Totale retribuzione', numerico: true),
              ]),
            ]),
            _sezione('Corpo voci', [
              ..._righeVoci.asMap().entries.map((e) => _rigaVoceWidget(e.key, e.value)),
              OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Aggiungi voce'),
                onPressed: () => setState(() => _righeVoci.add(_RigaVoceControllers())),
              ),
            ]),
            _sezione('Area sociale/fiscale', [
              _riga([
                _campo(_inpsImponibile, 'INPS imponibile', numerico: true),
                _campo(_inpsTrattenute, 'INPS trattenute', numerico: true),
              ]),
              _campo(_inailImponibile, 'INAIL imponibile', numerico: true),
              _riga([
                _campo(_irpefMoImponibile, 'IRPEF M.O. imponibile', numerico: true),
                _campo(_irpefMoTrattenute, 'IRPEF M.O. trattenute', numerico: true),
              ]),
              _campo(_aliquotaMaxIrpef, 'Aliquota max. IRPEF (%)', numerico: true),
            ]),
            _sezione('T.F.R.', [
              _riga([
                _campo(_tfrElementiUtili, 'Elementi utili TFR', numerico: true),
                _campo(_tfrQuotaMese, 'Quota mese TFR', numerico: true),
              ]),
            ]),
            _sezione('Riepilogo pagamento', [
              _riga([
                _campo(_totaleTrattenute, 'Totale trattenute', numerico: true),
                _campo(_totaleCompetenze, 'Totale competenze', numerico: true),
              ]),
              _campo(_netto, 'Netto', numerico: true),
            ]),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Salva cedolino'),
              onPressed: _salva,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _rigaVoceWidget(int indice, _RigaVoceControllers riga) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(flex: 2, child: _campo(riga.codice, 'Codice')),
                const SizedBox(width: 8),
                Expanded(flex: 4, child: _campo(riga.descrizione, 'Descrizione')),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => setState(() => _righeVoci.removeAt(indice)),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: _campo(riga.valoreUnitario, 'Valore unit.', numerico: true)),
                const SizedBox(width: 8),
                Expanded(child: _campo(riga.oreGgMesi, 'Ore/gg/mesi', numerico: true)),
                const SizedBox(width: 8),
                Expanded(child: _campo(riga.trattenute, 'Trattenute', numerico: true)),
                const SizedBox(width: 8),
                Expanded(child: _campo(riga.competenze, 'Competenze', numerico: true)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sezione(String titolo, List<Widget> figli) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titolo, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...figli,
        ],
      ),
    );
  }

  Widget _riga(List<Widget> campi) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          for (var i = 0; i < campi.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: campi[i]),
          ],
        ],
      ),
    );
  }

  Widget _campo(TextEditingController controller, String etichetta, {bool numerico = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: etichetta, border: const OutlineInputBorder()),
        keyboardType: numerico ? const TextInputType.numberWithOptions(decimal: true) : null,
      ),
    );
  }

  Future<void> _salva() async {
    final mese = int.tryParse(_mese.text) ?? DateTime.now().month;
    final anno = int.tryParse(_anno.text) ?? DateTime.now().year;

    final busta = BustaPaga(
      id: widget.bustaEsistente?.id ?? const Uuid().v4(),
      meseRiferimento: '${nomeMese(mese).toUpperCase()} $anno',
      anno: anno,
      mese: mese,
      numeroDocumento: _numeroDocumento.text.trim(),
      qualifica: _qualifica.text.trim(),
      livello: _livello.text.trim(),
      provinciaLavoro: _provincia.text.trim(),
      percentualePartTime: parseNumeroItaliano(_percPartTime.text) ?? 100,
      pagaBase: parseNumeroItaliano(_pagaBase.text) ?? 0,
      contingenza: parseNumeroItaliano(_contingenza.text) ?? 0,
      importoScatti: parseNumeroItaliano(_importoScatti.text) ?? 0,
      retribuzioneOraria: parseNumeroItaliano(_retribuzioneOraria.text),
      totaleRetribuzione: parseNumeroItaliano(_totaleRetribuzione.text) ?? 0,
      voci: _righeVoci
          .map((r) => r.toVoce())
          .where((v) => v.codice.isNotEmpty)
          .toList(),
      inpsImponibile: parseNumeroItaliano(_inpsImponibile.text) ?? 0,
      inpsTrattenute: parseNumeroItaliano(_inpsTrattenute.text) ?? 0,
      inailImponibile: parseNumeroItaliano(_inailImponibile.text) ?? 0,
      irpefMoImponibile: parseNumeroItaliano(_irpefMoImponibile.text) ?? 0,
      irpefMoTrattenute: parseNumeroItaliano(_irpefMoTrattenute.text) ?? 0,
      aliquotaMaxIrpef: parseNumeroItaliano(_aliquotaMaxIrpef.text) ?? 0,
      tfrElementiUtili: parseNumeroItaliano(_tfrElementiUtili.text),
      tfrQuotaMese: parseNumeroItaliano(_tfrQuotaMese.text),
      totaleTrattenute: parseNumeroItaliano(_totaleTrattenute.text) ?? 0,
      totaleCompetenze: parseNumeroItaliano(_totaleCompetenze.text) ?? 0,
      netto: parseNumeroItaliano(_netto.text) ?? 0,
      origine: widget.origine,
      immaginePath: widget.immaginePath ?? widget.bustaEsistente?.immaginePath,
    );

    await context.read<BustePagaProvider>().salva(busta);
    if (mounted) Navigator.of(context).pop();
  }
}
