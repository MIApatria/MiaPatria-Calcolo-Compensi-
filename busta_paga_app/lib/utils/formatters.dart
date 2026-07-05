import 'package:intl/intl.dart';

final NumberFormat _euroFormat = NumberFormat.currency(
  locale: 'it_IT',
  symbol: '€',
  decimalDigits: 2,
);

final NumberFormat _decimalFormat = NumberFormat.decimalPattern('it_IT');

String formattaEuro(num? valore) => _euroFormat.format(valore ?? 0);

String formattaOre(num? valore) {
  if (valore == null) return '0,00 h';
  return '${_decimalFormat.format(valore)} h';
}

String formattaNumero(num? valore, {int decimali = 2}) {
  if (valore == null) return '';
  return valore.toStringAsFixed(decimali).replaceAll('.', ',');
}

/// Converte un numero in formato italiano ("1.617,44" oppure "84,93")
/// in un double. Ritorna null se la stringa non è un numero valido.
double? parseNumeroItaliano(String? input) {
  if (input == null) return null;
  var s = input.trim();
  if (s.isEmpty) return null;
  // Rimuove separatori di migliaia (punto) e converte la virgola decimale in punto.
  s = s.replaceAll('.', '').replaceAll(',', '.');
  // Consente anche numeri già in formato con punto decimale (es. provenienti da OCR "en").
  return double.tryParse(s);
}

/// Converte ore in formato decimale (es. 37,90) in etichetta "ore e minuti"
/// (es. "37h 54m"), come indicato nella guida CIRFOOD
/// (0,90 ore decimali = 54 minuti, cioè 0,90*60).
String oreDecimaliAOreMinuti(double oreDecimali) {
  final ore = oreDecimali.truncate();
  final minuti = ((oreDecimali - ore) * 60).round();
  return '${ore}h ${minuti.toString().padLeft(2, '0')}m';
}

const List<String> mesiItaliani = [
  'Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno',
  'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre',
];

String nomeMese(int mese) => mesiItaliani[(mese - 1).clamp(0, 11)];
