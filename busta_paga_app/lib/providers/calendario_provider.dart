import 'package:flutter/foundation.dart';

import '../data/database_helper.dart';
import '../models/giorno_lavorativo.dart';
import '../models/turno.dart';

class CalendarioProvider extends ChangeNotifier {
  int anno;
  int mese;
  Map<String, GiornoLavorativo> _giorni = {};
  bool _caricamento = true;

  CalendarioProvider()
      : anno = DateTime.now().year,
        mese = DateTime.now().month;

  Map<String, GiornoLavorativo> get giorni => _giorni;
  bool get inCaricamento => _caricamento;

  Future<void> caricaMese(int nuovoAnno, int nuovoMese) async {
    anno = nuovoAnno;
    mese = nuovoMese;
    _caricamento = true;
    notifyListeners();
    _giorni = await DatabaseHelper.instance.getGiorniMese(anno, mese);
    _caricamento = false;
    notifyListeners();
  }

  Future<void> meseSuccessivo() async {
    final nuovoMese = mese == 12 ? 1 : mese + 1;
    final nuovoAnno = mese == 12 ? anno + 1 : anno;
    await caricaMese(nuovoAnno, nuovoMese);
  }

  Future<void> mesePrecedente() async {
    final nuovoMese = mese == 1 ? 12 : mese - 1;
    final nuovoAnno = mese == 1 ? anno - 1 : anno;
    await caricaMese(nuovoAnno, nuovoMese);
  }

  GiornoLavorativo? giornoPer(DateTime data) {
    final chiave =
        '${data.year.toString().padLeft(4, '0')}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}';
    return _giorni[chiave];
  }

  Future<void> impostaTurni(DateTime data, List<TipoTurno> turni) async {
    final giorno = GiornoLavorativo(data: data, turni: turni);
    await DatabaseHelper.instance.salvaGiorno(giorno);
    if (turni.isEmpty) {
      _giorni.remove(giorno.chiave);
    } else {
      _giorni[giorno.chiave] = giorno;
    }
    notifyListeners();
  }

  Future<void> rimuoviGiorno(DateTime data) async {
    await impostaTurni(data, []);
  }
}
