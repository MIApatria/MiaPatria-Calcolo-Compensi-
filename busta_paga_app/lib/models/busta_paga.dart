import 'voce_cedolino.dart';

/// Modello completo di un cedolino CIRFOOD, secondo la struttura descritta
/// nella "Guida alla lettura della busta paga CIRFOOD".
class BustaPaga {
  final String id;

  // Riferimenti / testata
  final String meseRiferimento; // es. "MAGGIO 2026"
  final int anno;
  final int mese; // 1-12, mese di riferimento della retribuzione
  final String numeroDocumento;
  final DateTime? dataElaborazione;

  final String qualifica;
  final String livello;
  final String provinciaLavoro;
  final double percentualePartTime;
  final String sede;
  final String centroCosto;

  // Elementi retributivi fissi
  final double pagaBase;
  final double contingenza;
  final double importoScatti;
  final double? retribuzioneOraria;
  final double totaleRetribuzione;

  // Corpo voci
  final List<VoceCedolino> voci;

  // Area sociale/fiscale
  final double inpsImponibile;
  final double inpsTrattenute;
  final double inailImponibile;
  final double irpefMoImponibile;
  final double irpefMoTrattenute;
  final double? irpefMsImponibile;
  final double? irpefMsTrattenute;
  final double? irpefCongImponibile;
  final double? irpefCongTrattenute;
  final double aliquotaMaxIrpef;

  // TFR
  final double? tfrElementiUtili;
  final double? tfrQuotaMese;

  // Riepilogo pagamento
  final double totaleTrattenute;
  final double totaleCompetenze;
  final double netto;
  final DateTime? dataValuta;

  // Origine dato: 'seed' (storico precaricato), 'ocr_foto', 'ocr_pdf', 'manuale'
  final String origine;
  final String? immaginePath;
  final String note;

  const BustaPaga({
    required this.id,
    required this.meseRiferimento,
    required this.anno,
    required this.mese,
    this.numeroDocumento = '',
    this.dataElaborazione,
    this.qualifica = '',
    this.livello = '',
    this.provinciaLavoro = '',
    this.percentualePartTime = 100,
    this.sede = '',
    this.centroCosto = '',
    this.pagaBase = 0,
    this.contingenza = 0,
    this.importoScatti = 0,
    this.retribuzioneOraria,
    this.totaleRetribuzione = 0,
    this.voci = const [],
    this.inpsImponibile = 0,
    this.inpsTrattenute = 0,
    this.inailImponibile = 0,
    this.irpefMoImponibile = 0,
    this.irpefMoTrattenute = 0,
    this.irpefMsImponibile,
    this.irpefMsTrattenute,
    this.irpefCongImponibile,
    this.irpefCongTrattenute,
    this.aliquotaMaxIrpef = 0,
    this.tfrElementiUtili,
    this.tfrQuotaMese,
    this.totaleTrattenute = 0,
    this.totaleCompetenze = 0,
    this.netto = 0,
    this.dataValuta,
    this.origine = 'manuale',
    this.immaginePath,
    this.note = '',
  });

  VoceCedolino? voce(String codice) {
    for (final v in voci) {
      if (v.codice == codice) return v;
    }
    return null;
  }

  double oreVoce(String codice) => voce(codice)?.oreGgMesi ?? 0;
  double competenzeVoce(String codice) => voce(codice)?.competenze ?? 0;

  BustaPaga copyWith({
    String? id,
    String? meseRiferimento,
    int? anno,
    int? mese,
    String? numeroDocumento,
    DateTime? dataElaborazione,
    String? qualifica,
    String? livello,
    String? provinciaLavoro,
    double? percentualePartTime,
    String? sede,
    String? centroCosto,
    double? pagaBase,
    double? contingenza,
    double? importoScatti,
    double? retribuzioneOraria,
    double? totaleRetribuzione,
    List<VoceCedolino>? voci,
    double? inpsImponibile,
    double? inpsTrattenute,
    double? inailImponibile,
    double? irpefMoImponibile,
    double? irpefMoTrattenute,
    double? irpefMsImponibile,
    double? irpefMsTrattenute,
    double? irpefCongImponibile,
    double? irpefCongTrattenute,
    double? aliquotaMaxIrpef,
    double? tfrElementiUtili,
    double? tfrQuotaMese,
    double? totaleTrattenute,
    double? totaleCompetenze,
    double? netto,
    DateTime? dataValuta,
    String? origine,
    String? immaginePath,
    String? note,
  }) {
    return BustaPaga(
      id: id ?? this.id,
      meseRiferimento: meseRiferimento ?? this.meseRiferimento,
      anno: anno ?? this.anno,
      mese: mese ?? this.mese,
      numeroDocumento: numeroDocumento ?? this.numeroDocumento,
      dataElaborazione: dataElaborazione ?? this.dataElaborazione,
      qualifica: qualifica ?? this.qualifica,
      livello: livello ?? this.livello,
      provinciaLavoro: provinciaLavoro ?? this.provinciaLavoro,
      percentualePartTime: percentualePartTime ?? this.percentualePartTime,
      sede: sede ?? this.sede,
      centroCosto: centroCosto ?? this.centroCosto,
      pagaBase: pagaBase ?? this.pagaBase,
      contingenza: contingenza ?? this.contingenza,
      importoScatti: importoScatti ?? this.importoScatti,
      retribuzioneOraria: retribuzioneOraria ?? this.retribuzioneOraria,
      totaleRetribuzione: totaleRetribuzione ?? this.totaleRetribuzione,
      voci: voci ?? this.voci,
      inpsImponibile: inpsImponibile ?? this.inpsImponibile,
      inpsTrattenute: inpsTrattenute ?? this.inpsTrattenute,
      inailImponibile: inailImponibile ?? this.inailImponibile,
      irpefMoImponibile: irpefMoImponibile ?? this.irpefMoImponibile,
      irpefMoTrattenute: irpefMoTrattenute ?? this.irpefMoTrattenute,
      irpefMsImponibile: irpefMsImponibile ?? this.irpefMsImponibile,
      irpefMsTrattenute: irpefMsTrattenute ?? this.irpefMsTrattenute,
      irpefCongImponibile: irpefCongImponibile ?? this.irpefCongImponibile,
      irpefCongTrattenute: irpefCongTrattenute ?? this.irpefCongTrattenute,
      aliquotaMaxIrpef: aliquotaMaxIrpef ?? this.aliquotaMaxIrpef,
      tfrElementiUtili: tfrElementiUtili ?? this.tfrElementiUtili,
      tfrQuotaMese: tfrQuotaMese ?? this.tfrQuotaMese,
      totaleTrattenute: totaleTrattenute ?? this.totaleTrattenute,
      totaleCompetenze: totaleCompetenze ?? this.totaleCompetenze,
      netto: netto ?? this.netto,
      dataValuta: dataValuta ?? this.dataValuta,
      origine: origine ?? this.origine,
      immaginePath: immaginePath ?? this.immaginePath,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'meseRiferimento': meseRiferimento,
        'anno': anno,
        'mese': mese,
        'numeroDocumento': numeroDocumento,
        'dataElaborazione': dataElaborazione?.toIso8601String(),
        'qualifica': qualifica,
        'livello': livello,
        'provinciaLavoro': provinciaLavoro,
        'percentualePartTime': percentualePartTime,
        'sede': sede,
        'centroCosto': centroCosto,
        'pagaBase': pagaBase,
        'contingenza': contingenza,
        'importoScatti': importoScatti,
        'retribuzioneOraria': retribuzioneOraria,
        'totaleRetribuzione': totaleRetribuzione,
        'inpsImponibile': inpsImponibile,
        'inpsTrattenute': inpsTrattenute,
        'inailImponibile': inailImponibile,
        'irpefMoImponibile': irpefMoImponibile,
        'irpefMoTrattenute': irpefMoTrattenute,
        'irpefMsImponibile': irpefMsImponibile,
        'irpefMsTrattenute': irpefMsTrattenute,
        'irpefCongImponibile': irpefCongImponibile,
        'irpefCongTrattenute': irpefCongTrattenute,
        'aliquotaMaxIrpef': aliquotaMaxIrpef,
        'tfrElementiUtili': tfrElementiUtili,
        'tfrQuotaMese': tfrQuotaMese,
        'totaleTrattenute': totaleTrattenute,
        'totaleCompetenze': totaleCompetenze,
        'netto': netto,
        'dataValuta': dataValuta?.toIso8601String(),
        'origine': origine,
        'immaginePath': immaginePath,
        'note': note,
      };

  static BustaPaga fromMap(Map<String, dynamic> map, List<VoceCedolino> voci) {
    return BustaPaga(
      id: map['id'] as String,
      meseRiferimento: map['meseRiferimento'] as String? ?? '',
      anno: map['anno'] as int? ?? 0,
      mese: map['mese'] as int? ?? 1,
      numeroDocumento: map['numeroDocumento'] as String? ?? '',
      dataElaborazione: map['dataElaborazione'] != null
          ? DateTime.tryParse(map['dataElaborazione'] as String)
          : null,
      qualifica: map['qualifica'] as String? ?? '',
      livello: map['livello'] as String? ?? '',
      provinciaLavoro: map['provinciaLavoro'] as String? ?? '',
      percentualePartTime:
          (map['percentualePartTime'] as num?)?.toDouble() ?? 100,
      sede: map['sede'] as String? ?? '',
      centroCosto: map['centroCosto'] as String? ?? '',
      pagaBase: (map['pagaBase'] as num?)?.toDouble() ?? 0,
      contingenza: (map['contingenza'] as num?)?.toDouble() ?? 0,
      importoScatti: (map['importoScatti'] as num?)?.toDouble() ?? 0,
      retribuzioneOraria: (map['retribuzioneOraria'] as num?)?.toDouble(),
      totaleRetribuzione: (map['totaleRetribuzione'] as num?)?.toDouble() ?? 0,
      voci: voci,
      inpsImponibile: (map['inpsImponibile'] as num?)?.toDouble() ?? 0,
      inpsTrattenute: (map['inpsTrattenute'] as num?)?.toDouble() ?? 0,
      inailImponibile: (map['inailImponibile'] as num?)?.toDouble() ?? 0,
      irpefMoImponibile: (map['irpefMoImponibile'] as num?)?.toDouble() ?? 0,
      irpefMoTrattenute: (map['irpefMoTrattenute'] as num?)?.toDouble() ?? 0,
      irpefMsImponibile: (map['irpefMsImponibile'] as num?)?.toDouble(),
      irpefMsTrattenute: (map['irpefMsTrattenute'] as num?)?.toDouble(),
      irpefCongImponibile: (map['irpefCongImponibile'] as num?)?.toDouble(),
      irpefCongTrattenute: (map['irpefCongTrattenute'] as num?)?.toDouble(),
      aliquotaMaxIrpef: (map['aliquotaMaxIrpef'] as num?)?.toDouble() ?? 0,
      tfrElementiUtili: (map['tfrElementiUtili'] as num?)?.toDouble(),
      tfrQuotaMese: (map['tfrQuotaMese'] as num?)?.toDouble(),
      totaleTrattenute: (map['totaleTrattenute'] as num?)?.toDouble() ?? 0,
      totaleCompetenze: (map['totaleCompetenze'] as num?)?.toDouble() ?? 0,
      netto: (map['netto'] as num?)?.toDouble() ?? 0,
      dataValuta: map['dataValuta'] != null
          ? DateTime.tryParse(map['dataValuta'] as String)
          : null,
      origine: map['origine'] as String? ?? 'manuale',
      immaginePath: map['immaginePath'] as String?,
      note: map['note'] as String? ?? '',
    );
  }

  factory BustaPaga.fromJson(Map<String, dynamic> json, String id) {
    final voci = (json['voci'] as List<dynamic>? ?? [])
        .map((v) => VoceCedolino.fromJson(v as Map<String, dynamic>))
        .toList();
    return BustaPaga(
      id: id,
      meseRiferimento: json['meseLabel'] as String? ?? '',
      anno: json['anno'] as int,
      mese: json['mese'] as int,
      numeroDocumento: json['numeroDocumento'] as String? ?? '',
      dataElaborazione: json['dataElaborazione'] != null
          ? DateTime.tryParse(json['dataElaborazione'] as String)
          : null,
      qualifica: json['qualifica'] as String? ?? 'OPERAIO',
      livello: json['livello'] as String? ?? '6S',
      provinciaLavoro: json['provincia'] as String? ?? 'FC',
      percentualePartTime:
          (json['percPartTime'] as num?)?.toDouble() ?? 52.5,
      sede: json['sede'] as String? ?? '',
      centroCosto: json['centroCosto'] as String? ?? '',
      pagaBase: (json['pagaBase'] as num?)?.toDouble() ?? 0,
      contingenza: (json['contingenza'] as num?)?.toDouble() ?? 0,
      importoScatti: (json['importoScatti'] as num?)?.toDouble() ?? 0,
      retribuzioneOraria: (json['retribuzioneOraria'] as num?)?.toDouble(),
      totaleRetribuzione: (json['totaleRetribuzione'] as num?)?.toDouble() ?? 0,
      voci: voci,
      inpsImponibile: (json['inpsImponibile'] as num?)?.toDouble() ?? 0,
      inpsTrattenute: (json['inpsTrattenute'] as num?)?.toDouble() ?? 0,
      inailImponibile: (json['inailImponibile'] as num?)?.toDouble() ?? 0,
      irpefMoImponibile: (json['irpefMoImponibile'] as num?)?.toDouble() ?? 0,
      irpefMoTrattenute: (json['irpefMoTrattenute'] as num?)?.toDouble() ?? 0,
      irpefMsImponibile: (json['irpefMsImponibile'] as num?)?.toDouble(),
      irpefMsTrattenute: (json['irpefMsTrattenute'] as num?)?.toDouble(),
      irpefCongImponibile: (json['irpefCongImponibile'] as num?)?.toDouble(),
      irpefCongTrattenute: (json['irpefCongTrattenute'] as num?)?.toDouble(),
      aliquotaMaxIrpef: (json['aliquotaMaxIrpef'] as num?)?.toDouble() ?? 0,
      tfrElementiUtili: (json['tfrElementiUtili'] as num?)?.toDouble(),
      tfrQuotaMese: (json['tfrQuotaMese'] as num?)?.toDouble(),
      totaleTrattenute: (json['totaleTrattenute'] as num?)?.toDouble() ?? 0,
      totaleCompetenze: (json['totaleCompetenze'] as num?)?.toDouble() ?? 0,
      netto: (json['netto'] as num?)?.toDouble() ?? 0,
      dataValuta: json['dataValuta'] != null
          ? DateTime.tryParse(json['dataValuta'] as String)
          : null,
      origine: 'seed',
      note: json['note'] as String? ?? '',
    );
  }
}
