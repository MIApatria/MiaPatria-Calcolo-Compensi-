import 'package:flutter/material.dart';

import '../services/calcolo_service.dart';
import '../utils/formatters.dart';

class DiffRow extends StatelessWidget {
  final DiscrepanzaVoce discrepanza;

  const DiffRow({super.key, required this.discrepanza});

  @override
  Widget build(BuildContext context) {
    final ok = discrepanza.entroTolleranza;
    final colore = ok ? Colors.green.shade700 : Colors.orange.shade800;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(ok ? Icons.check_circle : Icons.error_outline, color: colore, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    discrepanza.categoria,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _colonna(
                    context,
                    'Calendario',
                    formattaOre(discrepanza.oreCalendario),
                  ),
                ),
                Expanded(
                  child: _colonna(
                    context,
                    'Busta paga',
                    formattaOre(discrepanza.oreCedolino),
                  ),
                ),
                Expanded(
                  child: _colonna(
                    context,
                    'Differenza',
                    '${discrepanza.differenzaOre >= 0 ? '+' : ''}${formattaOre(discrepanza.differenzaOre)}',
                    colore: discrepanza.oreEntroTolleranza ? null : colore,
                  ),
                ),
              ],
            ),
            if (discrepanza.importoAtteso != null && discrepanza.importoCedolino != null) ...[
              const Divider(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _colonna(context, 'Importo stimato',
                        formattaEuro(discrepanza.importoAtteso)),
                  ),
                  Expanded(
                    child: _colonna(context, 'Importo in busta',
                        formattaEuro(discrepanza.importoCedolino)),
                  ),
                  Expanded(
                    child: _colonna(
                      context,
                      'Differenza €',
                      '${(discrepanza.differenzaImporto ?? 0) >= 0 ? '+' : ''}${formattaEuro(discrepanza.differenzaImporto)}',
                      colore: discrepanza.importoEntroTolleranza ? null : colore,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _colonna(BuildContext context, String etichetta, String valore, {Color? colore}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(etichetta,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        Text(
          valore,
          style: TextStyle(fontWeight: FontWeight.w600, color: colore),
        ),
      ],
    );
  }
}
