import 'package:flutter/material.dart';

import '../models/turno.dart';
import '../utils/formatters.dart';

/// Bottom sheet mostrato al tocco di un giorno del calendario: permette di
/// scegliere nessun turno (riposo), un turno singolo o un doppio turno tra
/// le combinazioni ammesse (A+B oppure B+U).
class ShiftPickerSheet extends StatefulWidget {
  final List<TipoTurno> turniIniziali;

  const ShiftPickerSheet({super.key, required this.turniIniziali});

  static Future<List<TipoTurno>?> mostra(
      BuildContext context, List<TipoTurno> turniIniziali) {
    return showModalBottomSheet<List<TipoTurno>>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => ShiftPickerSheet(turniIniziali: turniIniziali),
    );
  }

  @override
  State<ShiftPickerSheet> createState() => _ShiftPickerSheetState();
}

class _ShiftPickerSheetState extends State<ShiftPickerSheet> {
  late List<TipoTurno> _selezione = List.of(widget.turniIniziali);

  static const _opzioniDoppio = [
    [TipoTurno.a, TipoTurno.b],
    [TipoTurno.b, TipoTurno.u],
  ];

  @override
  Widget build(BuildContext context) {
    final oreAnteprima = oreNetteGiorno(_selezione);

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Turno del giorno', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Text('Turno singolo', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: TipoTurno.values.map((t) {
              final selezionato = _selezione.length == 1 && _selezione.first == t;
              return ChoiceChip(
                label: Text('${t.sigla}  ${t.orarioLabel}'),
                selected: selezionato,
                onSelected: (_) => setState(() => _selezione = [t]),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text('Doppio turno (pausa 45 min. totali)',
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _opzioniDoppio.map((coppia) {
              final selezionato = _selezione.length == 2 &&
                  _selezione.toSet().difference(coppia.toSet()).isEmpty;
              return ChoiceChip(
                label: Text(
                    '${coppia[0].sigla}+${coppia[1].sigla}  ${coppia[0].orarioLabel} / ${coppia[1].orarioLabel}'),
                selected: selezionato,
                onSelected: (_) => setState(() => _selezione = List.of(coppia)),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          if (_selezione.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ore lavorate nette: ${formattaOre(oreAnteprima)} '
                      '(pausa ${_selezione.length == 1 ? pausaSingoloMinuti : pausaDoppioMinuti} min. inclusa)',
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.event_busy),
                  label: const Text('Non lavorato'),
                  onPressed: () => Navigator.of(context).pop(<TipoTurno>[]),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Conferma'),
                  onPressed: _selezione.isEmpty
                      ? null
                      : () => Navigator.of(context).pop(_selezione),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
