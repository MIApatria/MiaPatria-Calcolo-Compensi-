import 'turno.dart';

/// Rappresenta i turni assegnati a un singolo giorno del calendario.
/// Un giorno può avere 0 turni (non lavorato), 1 turno (singolo) o 2 turni
/// (doppio turno, solo per le combinazioni ammesse).
class GiornoLavorativo {
  final DateTime data; // solo anno/mese/giorno, senza orario
  final List<TipoTurno> turni;
  final String note;

  GiornoLavorativo({
    required this.data,
    List<TipoTurno>? turni,
    this.note = '',
  }) : turni = turni ?? [];

  DateTime get dataNormalizzata => DateTime(data.year, data.month, data.day);

  bool get lavorato => turni.isNotEmpty;
  bool get doppioTurno => turni.length == 2;
  bool get isDomenica => data.weekday == DateTime.sunday;

  double get oreLavorate => oreNetteGiorno(turni);

  String get chiave =>
      '${data.year.toString().padLeft(4, '0')}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}';

  String get etichettaTurni {
    if (turni.isEmpty) return '';
    return turni.map((t) => t.sigla).join('+');
  }

  GiornoLavorativo copyWith({List<TipoTurno>? turni, String? note}) {
    return GiornoLavorativo(
      data: data,
      turni: turni ?? this.turni,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() => {
        'data': chiave,
        'turni': turni.map((t) => t.sigla).join(','),
        'note': note,
      };

  static GiornoLavorativo fromMap(Map<String, dynamic> map) {
    final parts = (map['data'] as String).split('-');
    final data = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
    final turniStr = (map['turni'] as String? ?? '').trim();
    final turni = turniStr.isEmpty
        ? <TipoTurno>[]
        : turniStr
            .split(',')
            .map((s) => TipoTurnoInfo.fromSigla(s))
            .whereType<TipoTurno>()
            .toList();
    return GiornoLavorativo(
      data: data,
      turni: turni,
      note: map['note'] as String? ?? '',
    );
  }
}

/// Fa da riepilogo aggregato di un mese di calendario turni: ore ordinarie,
/// domenicali, ecc. usato dal servizio di calcolo/verifica.
class RiepilogoMeseCalendario {
  final int anno;
  final int mese;
  final double oreFerialiEntroContratto;
  final double oreFerialiSupplementari;
  final double oreDomenicaliOrdinarie; // parte a maggiorazione 10%
  final double oreDomenicaliSupplementari; // parte a maggiorazione 30% (voce 4047)
  final double oreFestive; // festività infrasettimanali lavorate
  final double oreTotali;
  final int giorniLavorati;

  const RiepilogoMeseCalendario({
    required this.anno,
    required this.mese,
    required this.oreFerialiEntroContratto,
    required this.oreFerialiSupplementari,
    required this.oreDomenicaliOrdinarie,
    required this.oreDomenicaliSupplementari,
    required this.oreFestive,
    required this.oreTotali,
    required this.giorniLavorati,
  });
}
