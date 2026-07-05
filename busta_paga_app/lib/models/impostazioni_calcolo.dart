/// Parametri configurabili usati dal motore di calcolo/verifica.
/// Valori di default coerenti con quanto osservato nei cedolini CIRFOOD
/// e con il CCNL Pubblici Esercizi, ma restano modificabili dall'utente
/// dalla schermata Impostazioni nel caso cambino in futuro.
class ImpostazioniCalcolo {
  /// Maggiorazione ore supplementari part-time in giorno feriale (voce 2312).
  final double maggiorazioneSupplementareFeriale; // 0.30 = +30%

  /// Maggiorazione aggiuntiva per le ore ordinarie lavorate di domenica
  /// (voce 2329, si somma al valore orario pieno già pagato altrove).
  final double maggiorazioneDomenicaleOrdinaria; // 0.10 = +10%

  /// Maggiorazione ore supplementari part-time lavorate di domenica
  /// (voce 4047).
  final double maggiorazioneSupplementareDomenicale; // 0.30 = +30%

  /// Maggiorazione ore lavorate in giornata festiva infrasettimanale
  /// (voce 2314).
  final double maggiorazioneFestiva; // 0.20 = +20%

  /// Ore settimanali di un contratto a tempo pieno, usate per calcolare
  /// le ore contrattuali mensili di un part-time in base alla percentuale.
  final double oreSettimanaliTempoPieno;

  /// Tolleranza (in ore) sotto la quale una discrepanza ore è considerata
  /// arrotondamento e non un vero errore.
  final double tolleranzaOre;

  /// Tolleranza (in euro) sotto la quale una discrepanza importo è
  /// considerata arrotondamento e non un vero errore.
  final double tolleranzaImporto;

  const ImpostazioniCalcolo({
    this.maggiorazioneSupplementareFeriale = 0.30,
    this.maggiorazioneDomenicaleOrdinaria = 0.10,
    this.maggiorazioneSupplementareDomenicale = 0.30,
    this.maggiorazioneFestiva = 0.20,
    this.oreSettimanaliTempoPieno = 40,
    this.tolleranzaOre = 0.30,
    this.tolleranzaImporto = 2.0,
  });

  ImpostazioniCalcolo copyWith({
    double? maggiorazioneSupplementareFeriale,
    double? maggiorazioneDomenicaleOrdinaria,
    double? maggiorazioneSupplementareDomenicale,
    double? maggiorazioneFestiva,
    double? oreSettimanaliTempoPieno,
    double? tolleranzaOre,
    double? tolleranzaImporto,
  }) {
    return ImpostazioniCalcolo(
      maggiorazioneSupplementareFeriale:
          maggiorazioneSupplementareFeriale ?? this.maggiorazioneSupplementareFeriale,
      maggiorazioneDomenicaleOrdinaria:
          maggiorazioneDomenicaleOrdinaria ?? this.maggiorazioneDomenicaleOrdinaria,
      maggiorazioneSupplementareDomenicale: maggiorazioneSupplementareDomenicale ??
          this.maggiorazioneSupplementareDomenicale,
      maggiorazioneFestiva: maggiorazioneFestiva ?? this.maggiorazioneFestiva,
      oreSettimanaliTempoPieno:
          oreSettimanaliTempoPieno ?? this.oreSettimanaliTempoPieno,
      tolleranzaOre: tolleranzaOre ?? this.tolleranzaOre,
      tolleranzaImporto: tolleranzaImporto ?? this.tolleranzaImporto,
    );
  }

  Map<String, dynamic> toMap() => {
        'maggiorazioneSupplementareFeriale': maggiorazioneSupplementareFeriale,
        'maggiorazioneDomenicaleOrdinaria': maggiorazioneDomenicaleOrdinaria,
        'maggiorazioneSupplementareDomenicale':
            maggiorazioneSupplementareDomenicale,
        'maggiorazioneFestiva': maggiorazioneFestiva,
        'oreSettimanaliTempoPieno': oreSettimanaliTempoPieno,
        'tolleranzaOre': tolleranzaOre,
        'tolleranzaImporto': tolleranzaImporto,
      };

  factory ImpostazioniCalcolo.fromMap(Map<String, dynamic> map) {
    return ImpostazioniCalcolo(
      maggiorazioneSupplementareFeriale:
          (map['maggiorazioneSupplementareFeriale'] as num?)?.toDouble() ?? 0.30,
      maggiorazioneDomenicaleOrdinaria:
          (map['maggiorazioneDomenicaleOrdinaria'] as num?)?.toDouble() ?? 0.10,
      maggiorazioneSupplementareDomenicale:
          (map['maggiorazioneSupplementareDomenicale'] as num?)?.toDouble() ??
              0.30,
      maggiorazioneFestiva:
          (map['maggiorazioneFestiva'] as num?)?.toDouble() ?? 0.20,
      oreSettimanaliTempoPieno:
          (map['oreSettimanaliTempoPieno'] as num?)?.toDouble() ?? 40,
      tolleranzaOre: (map['tolleranzaOre'] as num?)?.toDouble() ?? 0.30,
      tolleranzaImporto: (map['tolleranzaImporto'] as num?)?.toDouble() ?? 2.0,
    );
  }
}
