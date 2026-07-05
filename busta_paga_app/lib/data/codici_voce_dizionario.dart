/// Dizionario dei codici voce del cedolino CIRFOOD, trascritto dalla
/// "Guida alla lettura della busta paga CIRFOOD" (sezione 2).
/// Non sono codici standard di legge ma propri del software paghe CIRFOOD.
enum TipoVoce { competenza, trattenuta, informativo }

class DefinizioneVoce {
  final String codice;
  final String descrizioneCedolino;
  final TipoVoce tipo;
  final String spiegazione;

  const DefinizioneVoce({
    required this.codice,
    required this.descrizioneCedolino,
    required this.tipo,
    required this.spiegazione,
  });
}

final Map<String, DefinizioneVoce> dizionarioCodiciVoce = {
  for (final v in _voci) v.codice: v,
};

const List<DefinizioneVoce> _voci = [
  DefinizioneVoce(
    codice: '0250',
    descrizioneCedolino: 'ORE ORDINARIE',
    tipo: TipoVoce.informativo,
    spiegazione:
        'Numero di ore ordinarie lavorate nel periodo; riga di solo conteggio ore, '
        'senza importo proprio (il valore economico è espresso dalla voce 1000).',
  ),
  DefinizioneVoce(
    codice: '0255',
    descrizioneCedolino: "FESTIVITA' INFRASETTIMANALE",
    tipo: TipoVoce.informativo,
    spiegazione:
        "Conteggio delle ore corrispondenti a festività infrasettimanali (es. 25 aprile, "
        "1 maggio) ricadenti nel periodo; il valore economico è già ricompreso nella "
        "retribuzione base (voce 1000), non genera una competenza separata.",
  ),
  DefinizioneVoce(
    codice: '1000',
    descrizioneCedolino: 'RETRIBUZIONE/STIPENDIO',
    tipo: TipoVoce.competenza,
    spiegazione:
        'Retribuzione base per le ore ordinarie: paga base + contingenza + scatti, '
        'riproporzionata al part-time e alle ore/giorni effettivamente lavorati nel mese.',
  ),
  DefinizioneVoce(
    codice: '1200',
    descrizioneCedolino: 'ARRETRATI',
    tipo: TipoVoce.competenza,
    spiegazione:
        'Importi retributivi arretrati, tipicamente dovuti a rinnovi CCNL, conguagli '
        'di livello o correzioni di mesi precedenti.',
  ),
  DefinizioneVoce(
    codice: '2030',
    descrizioneCedolino: 'STRAORDINARIO 30%',
    tipo: TipoVoce.competenza,
    spiegazione:
        'Ore di lavoro straordinario vero e proprio (oltre il normale orario contrattuale, '
        'tipicamente le 40 ore settimanali), maggiorate del 30%; distinto dal "supplementare" '
        '(voce 2312) che riguarda le ore aggiuntive dei part-time entro il tempo pieno.',
  ),
  DefinizioneVoce(
    codice: '2312',
    descrizioneCedolino: 'ORE SUPPL. P.TIME 30%',
    tipo: TipoVoce.competenza,
    spiegazione:
        'Ore di lavoro supplementare per i part-time (ore aggiuntive rispetto al contratto, '
        'entro il tempo pieno) svolte in giorno feriale, maggiorate del 30% sul valore orario base.',
  ),
  DefinizioneVoce(
    codice: '2314',
    descrizioneCedolino: 'ORE FESTIVE.',
    tipo: TipoVoce.competenza,
    spiegazione:
        'Ore lavorate in giornata festiva (festività nazionale/infrasettimanale), retribuite '
        'con un valore unitario maggiorato rispetto alla paga oraria ordinaria.',
  ),
  DefinizioneVoce(
    codice: '2329',
    descrizioneCedolino: 'MAGG. 10% ORE DOMENICALI',
    tipo: TipoVoce.competenza,
    spiegazione:
        'Maggiorazione del 10% per le ore ordinarie lavorate di domenica, prevista dal CCNL.',
  ),
  DefinizioneVoce(
    codice: '2333',
    descrizioneCedolino: "EX FESTIVITA'",
    tipo: TipoVoce.competenza,
    spiegazione:
        "Monetizzazione delle ex festività (giornate religiose soppresse ma dovute come "
        "retribuzione), liquidata a valore pieno quando non fruita come permesso.",
  ),
  DefinizioneVoce(
    codice: '2335',
    descrizioneCedolino: 'CORSO FORMAZ. FUORI ORARIO',
    tipo: TipoVoce.competenza,
    spiegazione:
        'Compenso per ore di formazione/corso svolte al di fuori del normale orario di lavoro.',
  ),
  DefinizioneVoce(
    codice: '4047',
    descrizioneCedolino: 'ORE SUPPL. PART TIME DOM. 30%',
    tipo: TipoVoce.competenza,
    spiegazione:
        'Ore di lavoro supplementare per i part-time svolte di domenica, maggiorate del 30%; '
        'combina la natura di "supplementare" (2312) con la giornata domenicale (a differenza '
        'della 2329, che riguarda solo le ore ordinarie).',
  ),
  DefinizioneVoce(
    codice: '4137',
    descrizioneCedolino: 'CONTRIBUTO VITTO',
    tipo: TipoVoce.trattenuta,
    spiegazione: 'Quota a carico del dipendente per il servizio mensa/vitto aziendale.',
  ),
  DefinizioneVoce(
    codice: '4170',
    descrizioneCedolino: 'EROGAZIONI LIBERALI',
    tipo: TipoVoce.competenza,
    spiegazione:
        'Erogazioni liberali dell\'azienda al dipendente (es. omaggi/benefit in occasione di '
        'festività), spesso soggette a un regime fiscale agevolato entro i limiti di legge sui '
        'fringe benefit.',
  ),
  DefinizioneVoce(
    codice: '5001',
    descrizioneCedolino: 'FERIE GODUTE ANNO PRECEDENTE',
    tipo: TipoVoce.informativo,
    spiegazione:
        'Ore di ferie residue dell\'anno precedente, fruite nel mese corrente; voce di solo '
        'conteggio, il valore economico è già incluso nella normale retribuzione.',
  ),
  DefinizioneVoce(
    codice: '5002',
    descrizioneCedolino: 'FERIE GODUTE ANNO IN CORSO',
    tipo: TipoVoce.informativo,
    spiegazione:
        'Ore di ferie dell\'anno in corso, fruite nel mese; voce di solo conteggio ore.',
  ),
  DefinizioneVoce(
    codice: '5051',
    descrizioneCedolino: 'ROL GODUTI ANNO PRECEDENTE',
    tipo: TipoVoce.informativo,
    spiegazione:
        'Ore di R.O.L. (permessi retribuiti) residue dell\'anno precedente, fruite nel mese '
        'corrente; voce di solo conteggio ore.',
  ),
  DefinizioneVoce(
    codice: '5101',
    descrizioneCedolino: 'EX FEST GODUTI ANNO PRECEDENTE',
    tipo: TipoVoce.informativo,
    spiegazione:
        'Ore di ex festività (giornate soppresse ma retribuite) residue dell\'anno precedente, '
        'godute nel mese corrente; voce di solo conteggio ore.',
  ),
  DefinizioneVoce(
    codice: '5340',
    descrizioneCedolino: "13MA MENSILITA'",
    tipo: TipoVoce.competenza,
    spiegazione:
        'Importo lordo della tredicesima mensilità, pari a una mensilità di retribuzione in atto '
        '(esclusi assegni familiari).',
  ),
  DefinizioneVoce(
    codice: '5390',
    descrizioneCedolino: "14MA MENSILITA'",
    tipo: TipoVoce.competenza,
    spiegazione:
        'Importo lordo della quattordicesima mensilità, maturata al 30 giugno e liquidata '
        'solitamente con la retribuzione di giugno/luglio.',
  ),
  DefinizioneVoce(
    codice: '5420',
    descrizioneCedolino: 'ACCONTO 13MA',
    tipo: TipoVoce.competenza,
    spiegazione:
        'Anticipo della tredicesima mensilità, erogato in un mese precedente (tipicamente '
        'novembre) rispetto al conguaglio pieno di dicembre.',
  ),
  DefinizioneVoce(
    codice: '5422',
    descrizioneCedolino: "ACCONTO 13MA GIA' EROGATO",
    tipo: TipoVoce.trattenuta,
    spiegazione:
        'Storno dell\'acconto sulla tredicesima già corrisposto in precedenza, per evitare una '
        'doppia erogazione nel mese in cui viene liquidata la tredicesima piena (voce 5340).',
  ),
  DefinizioneVoce(
    codice: '5500',
    descrizioneCedolino: 'RATEI 13 MENSILITA\'',
    tipo: TipoVoce.informativo,
    spiegazione:
        'Rateo mensile di maturazione della tredicesima (dodicesimi); voce di solo conteggio, '
        'usata come base di calcolo.',
  ),
  DefinizioneVoce(
    codice: '5501',
    descrizioneCedolino: 'RATEI 14 MENSILITA\'',
    tipo: TipoVoce.informativo,
    spiegazione:
        'Rateo mensile di maturazione della quattordicesima (dodicesimi); voce di solo conteggio.',
  ),
  DefinizioneVoce(
    codice: '6633',
    descrizioneCedolino: 'CTR. C/DIP. ENTI BILATERALI',
    tipo: TipoVoce.trattenuta,
    spiegazione:
        'Contributo a carico del dipendente destinato agli Enti Bilaterali di settore '
        '(es. Ente Bilaterale Turismo).',
  ),
  DefinizioneVoce(
    codice: '8128',
    descrizioneCedolino: 'ULT.DETRAZIONE: L.207/2024',
    tipo: TipoVoce.trattenuta,
    spiegazione:
        'Ulteriore detrazione IRPEF introdotta dalla L. 207/2024 (Legge di Bilancio 2025) per '
        'specifiche fasce di reddito da lavoro dipendente; può comparire con segno positivo '
        '(riconoscimento) o negativo (storno/conguaglio di fine anno).',
  ),
  DefinizioneVoce(
    codice: '8222',
    descrizioneCedolino: 'CREDITO D.L. 3/2020 MESE',
    tipo: TipoVoce.competenza,
    spiegazione:
        'Trattamento integrativo mensile (il c.d. "ex bonus Renzi", D.L. 3/2020), riconosciuto '
        'in busta se ricorrono i requisiti reddituali; importo fisso di riferimento €100/mese.',
  ),
  DefinizioneVoce(
    codice: '8223',
    descrizioneCedolino: 'CREDITO D.L. 3/2020 CONGUAGLIO',
    tipo: TipoVoce.competenza,
    spiegazione:
        'Conguaglio annuale (di fine anno) del trattamento integrativo D.L. 3/2020, a saldo di '
        'quanto già erogato mensilmente.',
  ),
  DefinizioneVoce(
    codice: '8310',
    descrizioneCedolino: 'ADD.REG.: IMP.TO DA RATEIZZARE',
    tipo: TipoVoce.informativo,
    spiegazione:
        'Importo complessivo dell\'addizionale regionale IRPEF determinato in sede di conguaglio '
        'annuale, da rateizzare nelle mensilità dell\'anno successivo (base di calcolo per la voce 8320).',
  ),
  DefinizioneVoce(
    codice: '8320',
    descrizioneCedolino: 'ADD.REG.: RATA A.P.',
    tipo: TipoVoce.trattenuta,
    spiegazione:
        'Rata mensile dell\'addizionale regionale IRPEF relativa all\'anno precedente (A.P.), '
        'rateizzata sulle mensilità dell\'anno in corso.',
  ),
  DefinizioneVoce(
    codice: '8325',
    descrizioneCedolino: 'ADD.REG.: SALDO A.P.',
    tipo: TipoVoce.trattenuta,
    spiegazione:
        'Saldo/conguaglio finale dell\'addizionale regionale relativa all\'anno precedente, '
        'liquidato tipicamente a fine anno.',
  ),
  DefinizioneVoce(
    codice: '8382',
    descrizioneCedolino: 'SOMMA INTEGR.L.207/2024 MESE',
    tipo: TipoVoce.competenza,
    spiegazione:
        'Ulteriore somma integrativa mensile introdotta dalla Legge di Bilancio 2025 '
        '(L. 207/2024) per i redditi da lavoro dipendente medio-bassi, distinta dal trattamento '
        'D.L. 3/2020 (voce 8222).',
  ),
  DefinizioneVoce(
    codice: '8383',
    descrizioneCedolino: 'SOMMA INTEGR.L.207/2024 CONGUA',
    tipo: TipoVoce.competenza,
    spiegazione:
        'Conguaglio annuale della somma integrativa L. 207/2024, a saldo di quanto già erogato '
        'mensilmente durante l\'anno.',
  ),
  DefinizioneVoce(
    codice: '8410',
    descrizioneCedolino: 'ADD.COM.: IMP.TO DA RATEIZZARE',
    tipo: TipoVoce.informativo,
    spiegazione:
        'Importo complessivo dell\'addizionale comunale IRPEF determinato a conguaglio annuale, '
        'da rateizzare l\'anno successivo (base di calcolo per la voce 8420).',
  ),
  DefinizioneVoce(
    codice: '8412',
    descrizioneCedolino: 'ADD.COM.: IMPON.ESEN.APPLICARE',
    tipo: TipoVoce.informativo,
    spiegazione:
        'Soglia di imponibile esente da applicare ai fini dell\'addizionale comunale (valore di '
        'riferimento, non una trattenuta diretta).',
  ),
  DefinizioneVoce(
    codice: '8420',
    descrizioneCedolino: 'ADD.COM.: RATA A.P.',
    tipo: TipoVoce.trattenuta,
    spiegazione:
        'Rata mensile dell\'addizionale comunale IRPEF relativa all\'anno precedente, rateizzata '
        'sull\'anno in corso.',
  ),
  DefinizioneVoce(
    codice: '8425',
    descrizioneCedolino: 'ADD.COM.: SALDO A.P.',
    tipo: TipoVoce.trattenuta,
    spiegazione:
        'Saldo/conguaglio finale dell\'addizionale comunale relativa all\'anno precedente.',
  ),
  DefinizioneVoce(
    codice: '8460',
    descrizioneCedolino: 'ADD.COM.: RATA ACCONTO A.C.',
    tipo: TipoVoce.trattenuta,
    spiegazione:
        'Rata mensile dell\'acconto sull\'addizionale comunale relativa all\'anno corrente (A.C.), '
        'da conguagliare l\'anno successivo.',
  ),
  DefinizioneVoce(
    codice: '8465',
    descrizioneCedolino: 'ADD.COM.: SALDO ACCONTO A.C.',
    tipo: TipoVoce.trattenuta,
    spiegazione: 'Saldo di fine anno dell\'acconto sull\'addizionale comunale dell\'anno corrente.',
  ),
  DefinizioneVoce(
    codice: '9233',
    descrizioneCedolino: 'ENTE BILATERALE C/AZIENDA',
    tipo: TipoVoce.informativo,
    spiegazione:
        'Quota del contributo all\'Ente Bilaterale a carico del datore di lavoro (non incide '
        'sul netto del dipendente).',
  ),
  DefinizioneVoce(
    codice: '9989',
    descrizioneCedolino: 'ASSIST. SANITARIA C/AZ',
    tipo: TipoVoce.informativo,
    spiegazione:
        'Contributo al fondo di assistenza sanitaria integrativa di settore (es. Fondo EST) '
        'versato dall\'azienda; dà diritto a prestazioni sanitarie integrative (rimborsi ticket, '
        'prestazioni odontoiatriche, ecc.).',
  ),
];

DefinizioneVoce? spiegazionePer(String codice) => dizionarioCodiciVoce[codice];
