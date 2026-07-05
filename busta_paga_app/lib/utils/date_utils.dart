const List<String> giorniSettimanaBrevi = [
  'Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom',
];

/// Calcola la Pasqua (algoritmo di Gauss) per l'anno indicato.
DateTime pasqua(int anno) {
  final a = anno % 19;
  final b = anno ~/ 100;
  final c = anno % 100;
  final d = b ~/ 4;
  final e = b % 4;
  final f = (b + 8) ~/ 25;
  final g = (b - f + 1) ~/ 3;
  final h = (19 * a + b - d - g + 15) % 30;
  final i = c ~/ 4;
  final k = c % 4;
  final l = (32 + 2 * e + 2 * i - h - k) % 7;
  final m = (a + 11 * h + 22 * l) ~/ 451;
  final mese = (h + l - 7 * m + 114) ~/ 31;
  final giorno = ((h + l - 7 * m + 114) % 31) + 1;
  return DateTime(anno, mese, giorno);
}

DateTime pasquetta(int anno) => pasqua(anno).add(const Duration(days: 1));

/// Festività nazionali italiane fisse più la Pasquetta (mobile).
/// Usate per marcare nel calendario turni i giorni festivi infrasettimanali
/// (rilevanti per la voce 2314 "ORE FESTIVE").
Set<DateTime> festivitaNazionali(int anno) {
  final fisse = <DateTime>{
    DateTime(anno, 1, 1),
    DateTime(anno, 1, 6),
    DateTime(anno, 4, 25),
    DateTime(anno, 5, 1),
    DateTime(anno, 6, 2),
    DateTime(anno, 8, 15),
    DateTime(anno, 11, 1),
    DateTime(anno, 12, 8),
    DateTime(anno, 12, 25),
    DateTime(anno, 12, 26),
  };
  fisse.add(_soloData(pasquetta(anno)));
  return fisse;
}

DateTime _soloData(DateTime d) => DateTime(d.year, d.month, d.day);

bool isFestivo(DateTime data) {
  final d = _soloData(data);
  if (d.weekday == DateTime.sunday) return false; // la domenica ha una sua gestione separata
  return festivitaNazionali(d.year).contains(d);
}

bool isDomenica(DateTime data) => data.weekday == DateTime.sunday;

int giorniNelMese(int anno, int mese) {
  final primoGiornoMeseSuccessivo =
      mese == 12 ? DateTime(anno + 1, 1, 1) : DateTime(anno, mese + 1, 1);
  return primoGiornoMeseSuccessivo.subtract(const Duration(days: 1)).day;
}
