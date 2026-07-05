/// Una singola riga del "corpo voci" del cedolino CIRFOOD
/// (colonne: Voce, Descrizione, S, F, Valore unitario, Ore/gg/mesi,
/// Trattenute, Competenze).
class VoceCedolino {
  final String codice;
  final String descrizione;
  final bool sociale; // colonna "S": concorre all'imponibile INPS
  final bool fiscale; // colonna "F": concorre all'imponibile IRPEF
  final double? valoreUnitario;
  final double? oreGgMesi;
  final double trattenute;
  final double competenze;

  const VoceCedolino({
    required this.codice,
    required this.descrizione,
    this.sociale = false,
    this.fiscale = false,
    this.valoreUnitario,
    this.oreGgMesi,
    this.trattenute = 0,
    this.competenze = 0,
  });

  double get impattoNetto => competenze - trattenute;

  Map<String, dynamic> toMap() => {
        'codice': codice,
        'descrizione': descrizione,
        'sociale': sociale ? 1 : 0,
        'fiscale': fiscale ? 1 : 0,
        'valoreUnitario': valoreUnitario,
        'oreGgMesi': oreGgMesi,
        'trattenute': trattenute,
        'competenze': competenze,
      };

  factory VoceCedolino.fromMap(Map<String, dynamic> map) => VoceCedolino(
        codice: map['codice'] as String,
        descrizione: map['descrizione'] as String? ?? '',
        sociale: (map['sociale'] as int? ?? 0) == 1,
        fiscale: (map['fiscale'] as int? ?? 0) == 1,
        valoreUnitario: (map['valoreUnitario'] as num?)?.toDouble(),
        oreGgMesi: (map['oreGgMesi'] as num?)?.toDouble(),
        trattenute: (map['trattenute'] as num?)?.toDouble() ?? 0,
        competenze: (map['competenze'] as num?)?.toDouble() ?? 0,
      );

  factory VoceCedolino.fromJson(Map<String, dynamic> json) => VoceCedolino(
        codice: json['codice'] as String,
        descrizione: json['descrizione'] as String? ?? '',
        sociale: json['sociale'] as bool? ?? false,
        fiscale: json['fiscale'] as bool? ?? false,
        valoreUnitario: (json['valoreUnitario'] as num?)?.toDouble(),
        oreGgMesi: (json['oreGgMesi'] as num?)?.toDouble(),
        trattenute: (json['trattenute'] as num?)?.toDouble() ?? 0,
        competenze: (json['competenze'] as num?)?.toDouble() ?? 0,
      );
}

/// Codici voce rilevanti per il confronto ore-lavorate-da-calendario
/// vs ore-riportate-in-busta-paga.
class CodiciVoce {
  static const oreOrdinarie = '0250';
  static const festivitaInfrasettimanale = '0255';
  static const retribuzioneBase = '1000';
  static const arretrati = '1200';
  static const straordinario30 = '2030';
  static const oreSupplPartTime30 = '2312';
  static const oreFestive = '2314';
  static const maggiorazione10Domenicali = '2329';
  static const exFestivita = '2333';
  static const corsoFormazione = '2335';
  static const oreSupplPartTimeDomenica30 = '4047';
  static const contributoVitto = '4137';
  static const erogazioniLiberali = '4170';
}
