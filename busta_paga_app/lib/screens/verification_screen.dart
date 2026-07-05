import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database_helper.dart';
import '../models/busta_paga.dart';
import '../models/giorno_lavorativo.dart';
import '../providers/buste_paga_provider.dart';
import '../providers/impostazioni_provider.dart';
import '../services/calcolo_service.dart';
import '../utils/formatters.dart';
import '../widgets/diff_row.dart';

/// Confronta il calendario turni di un mese con il cedolino corrispondente
/// e mostra un verdetto esplicito: se le ore coincidono oppure, in caso
/// contrario, quanto vale la discrepanza in ore e in euro.
class VerificationScreen extends StatefulWidget {
  final int anno;
  final int mese;

  const VerificationScreen({super.key, required this.anno, required this.mese});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  Map<String, GiornoLavorativo> _giorni = {};
  bool _caricamento = true;
  BustaPaga? _bustaSelezionata;

  @override
  void initState() {
    super.initState();
    _carica();
  }

  Future<void> _carica() async {
    _giorni = await DatabaseHelper.instance.getGiorniMese(widget.anno, widget.mese);
    if (mounted) {
      _bustaSelezionata =
          context.read<BustePagaProvider>().perMeseAnno(widget.mese, widget.anno);
      setState(() => _caricamento = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final buste = context.watch<BustePagaProvider>().buste;

    return Scaffold(
      appBar: AppBar(title: Text('Verifica ${nomeMese(widget.mese)} ${widget.anno}')),
      body: _caricamento
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<BustaPaga>(
                    decoration: const InputDecoration(
                      labelText: 'Cedolino da confrontare',
                      border: OutlineInputBorder(),
                    ),
                    value: _bustaSelezionata,
                    items: buste
                        .map((b) => DropdownMenuItem(
                              value: b,
                              child: Text('${nomeMese(b.mese)} ${b.anno}'
                                  '${b.numeroDocumento.isNotEmpty ? ' · ${b.numeroDocumento}' : ''}'),
                            ))
                        .toList(),
                    onChanged: (b) => setState(() => _bustaSelezionata = b),
                  ),
                ),
                if (_bustaSelezionata == null)
                  const Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Nessun cedolino disponibile per questo mese. '
                          'Importane uno oppure scegline uno diverso da confrontare.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(child: _contenutoVerifica(_bustaSelezionata!)),
              ],
            ),
    );
  }

  Widget _contenutoVerifica(BustaPaga bustaPaga) {
    final impostazioni = context.watch<ImpostazioniProvider>().impostazioni;
    final calcolo = CalcoloService(impostazioni);
    final risultato = calcolo.verificaMese(bustaPaga, _giorni.values);

    final colore = risultato.tuttoCorrisponde ? Colors.green : Colors.orange;

    return ListView(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colore.withOpacity(0.12),
            border: Border.all(color: colore),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                risultato.tuttoCorrisponde ? Icons.check_circle : Icons.warning_amber_rounded,
                color: colore.shade700,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  risultato.messaggioVerdetto,
                  style: TextStyle(color: colore.shade900, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        ...risultato.righe.map((r) => DiffRow(discrepanza: r)),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Text(
            'Il confronto usa le tariffe orarie stampate su questo cedolino per '
            'stimare l\'importo atteso dalle ore segnate a calendario: verifica '
            'quindi la coerenza aritmetica interna, non un audit indipendente '
            'della correttezza della tariffa contrattuale.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ),
      ],
    );
  }
}
