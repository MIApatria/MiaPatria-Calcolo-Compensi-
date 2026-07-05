import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/busta_paga.dart';
import '../providers/buste_paga_provider.dart';
import '../utils/formatters.dart';
import '../widgets/voce_tile.dart';
import 'payslip_form_screen.dart';
import 'verification_screen.dart';

class PayslipDetailScreen extends StatelessWidget {
  final BustaPaga bustaPaga;

  const PayslipDetailScreen({super.key, required this.bustaPaga});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${nomeMese(bustaPaga.mese)} ${bustaPaga.anno}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PayslipFormScreen(bustaEsistente: bustaPaga),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confermaEliminazione(context),
          ),
        ],
      ),
      body: ListView(
        children: [
          _intestazione(context),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text('Voci del cedolino (tocca per la spiegazione)',
                style: Theme.of(context).textTheme.titleMedium),
          ),
          ...bustaPaga.voci.map((v) => VoceTile(voce: v)),
          const Divider(),
          _riepilogoFiscale(context),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton.icon(
              icon: const Icon(Icons.fact_check_outlined),
              label: const Text('Verifica ore con il calendario'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => VerificationScreen(
                    anno: bustaPaga.anno,
                    mese: bustaPaga.mese,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _intestazione(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(bustaPaga.meseRiferimento, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            '${bustaPaga.qualifica} · livello ${bustaPaga.livello} · '
            '${bustaPaga.percentualePartTime.toStringAsFixed(2)}% part-time',
          ),
          if (bustaPaga.numeroDocumento.isNotEmpty)
            Text('Documento n. ${bustaPaga.numeroDocumento}'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _stat(context, 'Totale competenze', formattaEuro(bustaPaga.totaleCompetenze))),
              Expanded(child: _stat(context, 'Totale trattenute', formattaEuro(bustaPaga.totaleTrattenute))),
              Expanded(child: _stat(context, 'Netto', formattaEuro(bustaPaga.netto), forte: true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, String etichetta, String valore, {bool forte = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(etichetta, style: Theme.of(context).textTheme.labelSmall),
        Text(
          valore,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: forte ? 20 : 16,
            color: forte ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
      ],
    );
  }

  Widget _riepilogoFiscale(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Area sociale, fiscale e TFR', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _rigaInfo('INPS · imponibile', formattaEuro(bustaPaga.inpsImponibile)),
          _rigaInfo('INPS · trattenute', formattaEuro(bustaPaga.inpsTrattenute)),
          _rigaInfo('INAIL · imponibile', formattaEuro(bustaPaga.inailImponibile)),
          _rigaInfo('IRPEF mese ordinario · imponibile', formattaEuro(bustaPaga.irpefMoImponibile)),
          _rigaInfo('IRPEF mese ordinario · trattenute', formattaEuro(bustaPaga.irpefMoTrattenute)),
          if (bustaPaga.irpefMsImponibile != null)
            _rigaInfo('IRPEF mensilità suppl. · imponibile', formattaEuro(bustaPaga.irpefMsImponibile)),
          if (bustaPaga.irpefMsTrattenute != null)
            _rigaInfo('IRPEF mensilità suppl. · trattenute', formattaEuro(bustaPaga.irpefMsTrattenute)),
          if (bustaPaga.irpefCongImponibile != null)
            _rigaInfo('IRPEF conguaglio · imponibile', formattaEuro(bustaPaga.irpefCongImponibile)),
          if (bustaPaga.irpefCongTrattenute != null)
            _rigaInfo('IRPEF conguaglio · trattenute', formattaEuro(bustaPaga.irpefCongTrattenute)),
          _rigaInfo('Aliquota marginale massima IRPEF', '${formattaNumero(bustaPaga.aliquotaMaxIrpef)}%'),
          if (bustaPaga.tfrElementiUtili != null)
            _rigaInfo('TFR · elementi utili', formattaEuro(bustaPaga.tfrElementiUtili)),
          if (bustaPaga.tfrQuotaMese != null)
            _rigaInfo('TFR · quota mese', formattaEuro(bustaPaga.tfrQuotaMese)),
          if (bustaPaga.note.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(bustaPaga.note),
            ),
          ],
        ],
      ),
    );
  }

  Widget _rigaInfo(String etichetta, String valore) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(etichetta)),
          Text(valore, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _confermaEliminazione(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminare il cedolino?'),
        content: const Text('L\'operazione non può essere annullata.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () async {
              await context.read<BustePagaProvider>().elimina(bustaPaga.id);
              if (context.mounted) {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
              }
            },
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }
}
