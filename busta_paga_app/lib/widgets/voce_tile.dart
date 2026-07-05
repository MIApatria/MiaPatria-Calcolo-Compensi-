import 'package:flutter/material.dart';

import '../data/codici_voce_dizionario.dart';
import '../models/voce_cedolino.dart';
import '../utils/formatters.dart';

/// Riga di una voce del cedolino nella schermata di dettaglio. Al tocco
/// mostra la spiegazione in linguaggio semplice tratta dal dizionario
/// codici voce CIRFOOD.
class VoceTile extends StatelessWidget {
  final VoceCedolino voce;

  const VoceTile({super.key, required this.voce});

  @override
  Widget build(BuildContext context) {
    final definizione = spiegazionePer(voce.codice);
    final importo = voce.competenze != 0
        ? voce.competenze
        : (voce.trattenute != 0 ? -voce.trattenute : null);
    final coloreImporto = importo == null
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : (importo >= 0 ? Colors.green.shade700 : Colors.red.shade700);

    return ListTile(
      title: Text(voce.descrizione.isNotEmpty
          ? voce.descrizione
          : (definizione?.descrizioneCedolino ?? voce.codice)),
      subtitle: Text(
        [
          'Voce ${voce.codice}',
          if (voce.oreGgMesi != null) formattaOre(voce.oreGgMesi),
          if (voce.valoreUnitario != null)
            '${formattaEuro(voce.valoreUnitario)}/unità',
        ].join(' · '),
      ),
      trailing: importo != null
          ? Text(
              '${importo >= 0 ? '+' : ''}${formattaEuro(importo)}',
              style: TextStyle(color: coloreImporto, fontWeight: FontWeight.bold),
            )
          : null,
      onTap: () => _mostraSpiegazione(context, definizione, voce),
    );
  }

  void _mostraSpiegazione(
      BuildContext context, DefinizioneVoce? definizione, VoceCedolino voce) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Voce ${voce.codice} · ${definizione?.descrizioneCedolino ?? voce.descrizione}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              definizione?.spiegazione ??
                  'Nessuna spiegazione disponibile per questo codice: potrebbe '
                      'trattarsi di una voce non ancora presente nel dizionario '
                      '(es. malattia, infortunio, maternità, trasferta).',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
