import 'package:flutter/foundation.dart';

import '../data/database_helper.dart';
import '../models/impostazioni_calcolo.dart';

class ImpostazioniProvider extends ChangeNotifier {
  ImpostazioniCalcolo _impostazioni = const ImpostazioniCalcolo();
  bool _caricamento = true;

  ImpostazioniCalcolo get impostazioni => _impostazioni;
  bool get inCaricamento => _caricamento;

  Future<void> carica() async {
    _caricamento = true;
    notifyListeners();
    _impostazioni = await DatabaseHelper.instance.getImpostazioni();
    _caricamento = false;
    notifyListeners();
  }

  Future<void> aggiorna(ImpostazioniCalcolo nuove) async {
    _impostazioni = nuove;
    await DatabaseHelper.instance.salvaImpostazioni(nuove);
    notifyListeners();
  }
}
