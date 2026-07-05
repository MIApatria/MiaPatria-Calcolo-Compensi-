import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/busta_paga.dart';

/// Carica lo storico di esempio (14 cedolini reali forniti dall'utente in
/// fase di analisi) da assets/seed/cedolini_seed.json e lo converte in
/// oggetti BustaPaga. Viene inserito nel database SOLO al primo avvio
/// dell'app (se il database è vuoto), così l'utente parte già con uno
/// storico completo consultabile e con cui fare pratica sulla verifica ore.
Future<List<BustaPaga>> caricaCedoliniSeed() async {
  final raw = await rootBundle.loadString('assets/seed/cedolini_seed.json');
  final list = jsonDecode(raw) as List<dynamic>;
  return list
      .map((e) => BustaPaga.fromJson(
          e as Map<String, dynamic>, 'seed-${e['mese']}-${e['anno']}'))
      .toList();
}
