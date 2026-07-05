import 'package:flutter/foundation.dart';

import '../data/database_helper.dart';
import '../models/busta_paga.dart';

class BustePagaProvider extends ChangeNotifier {
  List<BustaPaga> _buste = [];
  bool _caricamento = true;

  List<BustaPaga> get buste => _buste;
  bool get inCaricamento => _caricamento;

  Future<void> carica() async {
    _caricamento = true;
    notifyListeners();
    _buste = await DatabaseHelper.instance.getBustePaga();
    _caricamento = false;
    notifyListeners();
  }

  BustaPaga? perMeseAnno(int mese, int anno) {
    for (final b in _buste) {
      if (b.mese == mese && b.anno == anno) return b;
    }
    return null;
  }

  Future<void> salva(BustaPaga bustaPaga) async {
    await DatabaseHelper.instance.salvaBustaPaga(bustaPaga);
    await carica();
  }

  Future<void> elimina(String id) async {
    await DatabaseHelper.instance.eliminaBustaPaga(id);
    await carica();
  }
}
