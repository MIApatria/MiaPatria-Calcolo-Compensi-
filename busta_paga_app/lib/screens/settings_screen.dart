import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/impostazioni_calcolo.dart';
import '../providers/buste_paga_provider.dart';
import '../providers/impostazioni_provider.dart';
import '../services/export_service.dart';
import '../utils/formatters.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ImpostazioniCalcolo _bozza;
  bool _inizializzato = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ImpostazioniProvider>();
    if (!_inizializzato && !provider.inCaricamento) {
      _bozza = provider.impostazioni;
      _inizializzato = true;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Impostazioni')),
      body: provider.inCaricamento
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Parametri di calcolo', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                const Text(
                  'Valori di default coerenti con il CCNL Pubblici Esercizi e con i '
                  'cedolini CIRFOOD osservati. Modificali solo se cambiano le regole '
                  'contrattuali.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 16),
                _sliderPercentuale(
                  'Maggiorazione supplementare feriale (voce 2312)',
                  _bozza.maggiorazioneSupplementareFeriale,
                  (v) => setState(() =>
                      _bozza = _bozza.copyWith(maggiorazioneSupplementareFeriale: v)),
                ),
                _sliderPercentuale(
                  'Maggiorazione ore domenicali ordinarie (voce 2329)',
                  _bozza.maggiorazioneDomenicaleOrdinaria,
                  (v) => setState(() =>
                      _bozza = _bozza.copyWith(maggiorazioneDomenicaleOrdinaria: v)),
                ),
                _sliderPercentuale(
                  'Maggiorazione supplementare domenicale (voce 4047)',
                  _bozza.maggiorazioneSupplementareDomenicale,
                  (v) => setState(() =>
                      _bozza = _bozza.copyWith(maggiorazioneSupplementareDomenicale: v)),
                ),
                _sliderPercentuale(
                  'Maggiorazione ore festive (voce 2314)',
                  _bozza.maggiorazioneFestiva,
                  (v) => setState(() => _bozza = _bozza.copyWith(maggiorazioneFestiva: v)),
                ),
                const SizedBox(height: 16),
                _campoNumerico(
                  'Tolleranza ore (per considerare una discrepanza trascurabile)',
                  _bozza.tolleranzaOre,
                  (v) => setState(() => _bozza = _bozza.copyWith(tolleranzaOre: v)),
                ),
                _campoNumerico(
                  'Tolleranza importo in € (per considerare una discrepanza trascurabile)',
                  _bozza.tolleranzaImporto,
                  (v) => setState(() => _bozza = _bozza.copyWith(tolleranzaImporto: v)),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Salva impostazioni'),
                  onPressed: () async {
                    await context.read<ImpostazioniProvider>().aggiorna(_bozza);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Impostazioni salvate')),
                      );
                    }
                  },
                ),
                const Divider(height: 40),
                Text('Dati e backup', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                const Text(
                  'Tutti i dati restano solo su questo telefono, in un database '
                  'locale: nessuna informazione viene inviata a servizi cloud. '
                  'Usa il backup per salvare una copia dei tuoi cedolini.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.ios_share),
                  label: const Text('Esporta e condividi backup (JSON)'),
                  onPressed: () async {
                    final buste = context.read<BustePagaProvider>().buste;
                    await ExportService().condividiBackup(buste);
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Nota: i calcoli di stima e verifica di questa app sono un '
                  'supporto informativo e non sostituiscono una verifica con '
                  'l\'ufficio paghe o le organizzazioni sindacali in caso di dubbio.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
    );
  }

  Widget _sliderPercentuale(String etichetta, double valore, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$etichetta: ${(valore * 100).toStringAsFixed(0)}%'),
          Slider(
            value: valore,
            min: 0,
            max: 1,
            divisions: 100,
            label: '${(valore * 100).toStringAsFixed(0)}%',
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _campoNumerico(String etichetta, double valore, ValueChanged<double> onChanged) {
    final controller = TextEditingController(text: formattaNumero(valore));
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: etichetta, border: const OutlineInputBorder()),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (testo) {
          final v = parseNumeroItaliano(testo);
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}
