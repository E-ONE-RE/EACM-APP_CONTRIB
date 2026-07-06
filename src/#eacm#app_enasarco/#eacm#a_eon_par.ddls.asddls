@EndUserText.label: 'Parametri estrazione ENASARCO online'
define abstract entity /EACM/A_EON_PAR
{
  @EndUserText.label: 'Societa'
  Bukrs         : bukrs;

  @EndUserText.label: 'Agente'
  Zcdaz         : /eacm/zcdaz;

  @EndUserText.label: 'Tipo agente'
  Ztpag         : abap.char(2);

  @EndUserText.label: 'Protocollo'
  Prot          : /eacm/zzprotd;

  @EndUserText.label: 'Codice ditta ENASARCO'
  Ditta         : /eacm/zcditta;

  @EndUserText.label: 'Codice fiscale ditta'
  Cf            : /eacm/zccfena;

  @EndUserText.label: 'Esercizio'
  Gjahr         : gjahr;

  @EndUserText.label: 'Trimestre'
  Trimes        : abap.char(1);

  @EndUserText.label: 'FIRR'
  Firr          : abap_boolean;

  @EndUserText.label: 'File separato cessati'
  SplitCessati  : abap_boolean;

}
