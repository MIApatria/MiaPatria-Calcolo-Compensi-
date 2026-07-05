import 'package:flutter/material.dart';

/// I tre turni fissi CIRFOOD. Gli orari e le pause sono quelli comunicati
/// dall'utente e non derivano dal cedolino (che non riporta gli orari di
/// inizio/fine turno, solo i totali ore).
enum TipoTurno { a, b, u }

extension TipoTurnoInfo on TipoTurno {
  String get sigla {
    switch (this) {
      case TipoTurno.a:
        return 'A';
      case TipoTurno.b:
        return 'B';
      case TipoTurno.u:
        return 'U';
    }
  }

  /// Orario di inizio come minuti dalla mezzanotte.
  int get inizioMinuti {
    switch (this) {
      case TipoTurno.a:
        return 7 * 60 + 15;
      case TipoTurno.b:
        return 11 * 60 + 45;
      case TipoTurno.u:
        return 16 * 60 + 30;
    }
  }

  /// Orario di fine come minuti dalla mezzanotte.
  int get fineMinuti {
    switch (this) {
      case TipoTurno.a:
        return 12 * 60;
      case TipoTurno.b:
        return 16 * 60 + 30;
      case TipoTurno.u:
        return 21 * 60 + 15;
    }
  }

  String get orarioLabel {
    String fmt(int m) =>
        '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';
    return '${fmt(inizioMinuti)}-${fmt(fineMinuti)}';
  }

  /// Durata lorda del turno in minuti (inclusi i 15' di pausa se singolo).
  int get durataLordaMinuti => fineMinuti - inizioMinuti;

  Color get colore {
    switch (this) {
      case TipoTurno.a:
        return const Color(0xFF2E7D32);
      case TipoTurno.b:
        return const Color(0xFFEF6C00);
      case TipoTurno.u:
        return const Color(0xFF1565C0);
    }
  }

  static TipoTurno? fromSigla(String s) {
    switch (s.trim().toUpperCase()) {
      case 'A':
        return TipoTurno.a;
      case 'B':
        return TipoTurno.b;
      case 'U':
        return TipoTurno.u;
    }
    return null;
  }
}

/// Pausa inclusa nel conteggio dell'orario di lavoro:
/// 15 minuti per un turno singolo, 45 minuti complessivi per un doppio turno.
const int pausaSingoloMinuti = 15;
const int pausaDoppioMinuti = 45;

/// Le combinazioni di doppio turno ammesse, secondo quanto indicato
/// dall'utente: A+B e B+U (turni consecutivi/sovrapposti sull'orario di
/// mezzogiorno). A+U non è considerata una combinazione valida di doppio
/// turno perché lascia un vuoto di ore non lavorate tra le 12:00 e le 16:30.
const List<Set<TipoTurno>> combinazioniDoppioAmmesse = [
  {TipoTurno.a, TipoTurno.b},
  {TipoTurno.b, TipoTurno.u},
];

bool isCombinazioneDoppioAmmessa(TipoTurno t1, TipoTurno t2) {
  final set = {t1, t2};
  if (set.length != 2) return false;
  return combinazioniDoppioAmmesse.any((c) => c.difference(set).isEmpty && set.difference(c).isEmpty);
}

/// Calcola le ore nette lavorate (in ore decimali) per un insieme di turni
/// svolti nello stesso giorno, sottraendo la pausa corretta.
double oreNetteGiorno(List<TipoTurno> turni) {
  if (turni.isEmpty) return 0;
  if (turni.length == 1) {
    final minutiLordi = turni.first.durataLordaMinuti;
    return (minutiLordi - pausaSingoloMinuti) / 60.0;
  }
  // Doppio turno: somma le durate lorde dei due turni e sottrae 45' totali,
  // indipendentemente dal buco eventuale tra i due turni (non pagato,
  // non conteggiato come lavorato né come pausa).
  final minutiLordiTotali =
      turni.map((t) => t.durataLordaMinuti).reduce((a, b) => a + b);
  return (minutiLordiTotali - pausaDoppioMinuti) / 60.0;
}
