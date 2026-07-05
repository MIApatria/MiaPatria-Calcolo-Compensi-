import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/busta_paga.dart';
import '../models/giorno_lavorativo.dart';
import '../models/impostazioni_calcolo.dart';
import '../models/voce_cedolino.dart';
import 'seed_loader.dart';

/// Gestisce il database SQLite locale (nessun dato lascia il telefono).
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'busta_paga_cirfood.db');
    final db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
    await _seedIfEmpty(db);
    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE buste_paga (
        id TEXT PRIMARY KEY,
        meseRiferimento TEXT,
        anno INTEGER,
        mese INTEGER,
        numeroDocumento TEXT,
        dataElaborazione TEXT,
        qualifica TEXT,
        livello TEXT,
        provinciaLavoro TEXT,
        percentualePartTime REAL,
        sede TEXT,
        centroCosto TEXT,
        pagaBase REAL,
        contingenza REAL,
        importoScatti REAL,
        retribuzioneOraria REAL,
        totaleRetribuzione REAL,
        inpsImponibile REAL,
        inpsTrattenute REAL,
        inailImponibile REAL,
        irpefMoImponibile REAL,
        irpefMoTrattenute REAL,
        irpefMsImponibile REAL,
        irpefMsTrattenute REAL,
        irpefCongImponibile REAL,
        irpefCongTrattenute REAL,
        aliquotaMaxIrpef REAL,
        tfrElementiUtili REAL,
        tfrQuotaMese REAL,
        totaleTrattenute REAL,
        totaleCompetenze REAL,
        netto REAL,
        dataValuta TEXT,
        origine TEXT,
        immaginePath TEXT,
        note TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE voci_cedolino (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bustaPagaId TEXT,
        codice TEXT,
        descrizione TEXT,
        sociale INTEGER,
        fiscale INTEGER,
        valoreUnitario REAL,
        oreGgMesi REAL,
        trattenute REAL,
        competenze REAL,
        FOREIGN KEY (bustaPagaId) REFERENCES buste_paga (id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE giorni_lavorativi (
        data TEXT PRIMARY KEY,
        turni TEXT,
        note TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE impostazioni (
        chiave TEXT PRIMARY KEY,
        valore TEXT
      )
    ''');
  }

  Future<void> _seedIfEmpty(Database db) async {
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM buste_paga'),
    );
    if (count != null && count > 0) return;
    final seed = await caricaCedoliniSeed();
    for (final bp in seed) {
      await _insertBustaPaga(db, bp);
    }
  }

  Future<void> _insertBustaPaga(Database db, BustaPaga bp) async {
    final batch = db.batch();
    batch.insert('buste_paga', bp.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    for (final v in bp.voci) {
      batch.insert('voci_cedolino', {
        ...v.toMap(),
        'bustaPagaId': bp.id,
      });
    }
    await batch.commit(noResult: true);
  }

  // ---------------- Buste paga ----------------

  Future<List<BustaPaga>> getBustePaga() async {
    final db = await database;
    final rows = await db.query('buste_paga', orderBy: 'anno DESC, mese DESC');
    final result = <BustaPaga>[];
    for (final row in rows) {
      final voci = await _getVociPer(db, row['id'] as String);
      result.add(BustaPaga.fromMap(row, voci));
    }
    return result;
  }

  Future<BustaPaga?> getBustaPaga(String id) async {
    final db = await database;
    final rows = await db.query('buste_paga', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    final voci = await _getVociPer(db, id);
    return BustaPaga.fromMap(rows.first, voci);
  }

  Future<List<VoceCedolino>> _getVociPer(Database db, String bustaPagaId) async {
    final rows = await db.query('voci_cedolino',
        where: 'bustaPagaId = ?', whereArgs: [bustaPagaId]);
    return rows.map(VoceCedolino.fromMap).toList();
  }

  Future<void> salvaBustaPaga(BustaPaga bp) async {
    final db = await database;
    await db.delete('voci_cedolino', where: 'bustaPagaId = ?', whereArgs: [bp.id]);
    await _insertBustaPaga(db, bp);
  }

  Future<void> eliminaBustaPaga(String id) async {
    final db = await database;
    await db.delete('voci_cedolino', where: 'bustaPagaId = ?', whereArgs: [id]);
    await db.delete('buste_paga', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------- Calendario turni ----------------

  Future<Map<String, GiornoLavorativo>> getGiorniMese(int anno, int mese) async {
    final db = await database;
    final prefix =
        '${anno.toString().padLeft(4, '0')}-${mese.toString().padLeft(2, '0')}-%';
    final rows = await db.query('giorni_lavorativi',
        where: 'data LIKE ?', whereArgs: [prefix]);
    final map = <String, GiornoLavorativo>{};
    for (final row in rows) {
      final g = GiornoLavorativo.fromMap(row);
      map[g.chiave] = g;
    }
    return map;
  }

  Future<void> salvaGiorno(GiornoLavorativo giorno) async {
    final db = await database;
    if (giorno.turni.isEmpty) {
      await db.delete('giorni_lavorativi',
          where: 'data = ?', whereArgs: [giorno.chiave]);
    } else {
      await db.insert('giorni_lavorativi', giorno.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  // ---------------- Impostazioni ----------------

  Future<ImpostazioniCalcolo> getImpostazioni() async {
    final db = await database;
    final rows = await db.query('impostazioni');
    if (rows.isEmpty) return const ImpostazioniCalcolo();
    final map = <String, dynamic>{};
    for (final row in rows) {
      map[row['chiave'] as String] =
          jsonDecode(row['valore'] as String);
    }
    return ImpostazioniCalcolo.fromMap(map);
  }

  Future<void> salvaImpostazioni(ImpostazioniCalcolo impostazioni) async {
    final db = await database;
    final batch = db.batch();
    impostazioni.toMap().forEach((chiave, valore) {
      batch.insert(
        'impostazioni',
        {'chiave': chiave, 'valore': jsonEncode(valore)},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
    await batch.commit(noResult: true);
  }
}
