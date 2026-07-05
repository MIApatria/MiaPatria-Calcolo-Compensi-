import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/giorno_lavorativo.dart';
import '../models/impostazioni_calcolo.dart';
import '../models/turno.dart';
import '../providers/calendario_provider.dart';
import '../providers/impostazioni_provider.dart';
import '../services/calcolo_service.dart';
import '../utils/date_utils.dart' as du;
import '../utils/formatters.dart';
import '../widgets/shift_picker_sheet.dart';
import 'verification_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CalendarioProvider>();
      provider.caricaMese(provider.anno, provider.mese);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalendarioProvider>();
    final impostazioni =
        context.watch<ImpostazioniProvider>().impostazioni;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario turni'),
        actions: [
          IconButton(
            icon: const Icon(Icons.fact_check_outlined),
            tooltip: 'Verifica con il cedolino',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => VerificationScreen(
                  anno: provider.anno,
                  mese: provider.mese,
                ),
              ),
            ),
          ),
        ],
      ),
      body: provider.inCaricamento
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _selettoreMese(provider),
                _intestazioneGiorni(),
                Expanded(child: _griglia(provider)),
                _riepilogo(provider, impostazioni),
              ],
            ),
    );
  }

  Widget _selettoreMese(CalendarioProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: provider.mesePrecedente,
          ),
          SizedBox(
            width: 180,
            child: Text(
              '${nomeMese(provider.mese)} ${provider.anno}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: provider.meseSuccessivo,
          ),
        ],
      ),
    );
  }

  Widget _intestazioneGiorni() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: du.giorniSettimanaBrevi
            .map((g) => Expanded(
                  child: Center(
                    child: Text(g,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _griglia(CalendarioProvider provider) {
    final giorniTotali = du.giorniNelMese(provider.anno, provider.mese);
    final primoGiorno = DateTime(provider.anno, provider.mese, 1);
    final offsetIniziale = primoGiorno.weekday - 1; // lunedì = 0

    final celle = <Widget>[];
    for (var i = 0; i < offsetIniziale; i++) {
      celle.add(const SizedBox.shrink());
    }
    for (var giorno = 1; giorno <= giorniTotali; giorno++) {
      final data = DateTime(provider.anno, provider.mese, giorno);
      celle.add(_cellaGiorno(provider, data));
    }

    return GridView.count(
      crossAxisCount: 7,
      padding: const EdgeInsets.all(8),
      children: celle,
    );
  }

  Widget _cellaGiorno(CalendarioProvider provider, DateTime data) {
    final giorno = provider.giornoPer(data);
    final lavorato = giorno?.lavorato ?? false;
    final domenica = du.isDomenica(data);
    final festivo = du.isFestivo(data);

    Color? sfondo;
    if (lavorato) {
      sfondo = giorno!.turni.length == 2
          ? Colors.purple.shade100
          : giorno.turni.first.colore.withOpacity(0.25);
    } else if (domenica || festivo) {
      sfondo = Colors.grey.shade200;
    }

    return GestureDetector(
      onTap: () => _apriSelezioneTurno(provider, data, giorno),
      onDoubleTap: () => provider.rimuoviGiorno(data),
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: sfondo,
          border: Border.all(
            color: domenica || festivo ? Colors.redAccent.shade100 : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${data.day}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: domenica || festivo ? Colors.redAccent.shade700 : null,
              ),
            ),
            if (lavorato)
              Text(
                giorno!.etichettaTurni,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _apriSelezioneTurno(
      CalendarioProvider provider, DateTime data, GiornoLavorativo? giorno) async {
    final risultato =
        await ShiftPickerSheet.mostra(context, giorno?.turni ?? []);
    if (risultato != null) {
      await provider.impostaTurni(data, risultato);
    }
  }

  Widget _riepilogo(CalendarioProvider provider, ImpostazioniCalcolo impostazioni) {
    final calcolo = CalcoloService(impostazioni);
    final aggregato = calcolo.aggregaCalendario(provider.giorni.values);
    final totale = aggregato.feriali + aggregato.domenicali + aggregato.festive;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statistica('Feriali', aggregato.feriali),
          _statistica('Domenicali', aggregato.domenicali),
          _statistica('Festive', aggregato.festive),
          _statistica('Totale', totale, evidenzia: true),
        ],
      ),
    );
  }

  Widget _statistica(String etichetta, double ore, {bool evidenzia = false}) {
    return Column(
      children: [
        Text(etichetta, style: const TextStyle(fontSize: 12)),
        Text(
          formattaOre(ore),
          style: TextStyle(
            fontWeight: evidenzia ? FontWeight.bold : FontWeight.w500,
            fontSize: evidenzia ? 16 : 14,
          ),
        ),
      ],
    );
  }
}
