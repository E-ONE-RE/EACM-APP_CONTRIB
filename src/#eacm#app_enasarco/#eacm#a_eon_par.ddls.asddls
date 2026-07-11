@EndUserText.label: 'Parametri estrazione ENASARCO online'
define abstract entity /EACM/A_EON_PAR
{
  @Consumption.valueHelpDefinition: [{
    entity: {name: '/EACM/R_T001', element: 'Bukrs' }}]
  @EndUserText.label: 'Societa'

  Bukrs         : bukrs;

  @EndUserText.label: 'Esercizio'
  Gjahr         : gjahr;

  @EndUserText.label: 'Trimestre'
  Trimes        : abap.char(1);

  @EndUserText.label: 'FIRR'
  Firr          : abap_boolean;

  @EndUserText.label: 'File separato cessati'
  SplitCessati  : abap_boolean;
  
  @EndUserText.label: 'Codice ditta ENASARCO'
  Ditta         : /eacm/zcditta;

  @Consumption.valueHelpDefinition: [{
    entity: {name: '/EACM/I_ZPRAA', element: 'Zcdaz' }}]
  @EndUserText.label: 'Agente'
  Zcdaz         : /eacm/zcdaz;

  @Consumption.valueHelpDefinition: [{
    entity: {name: '/EACM/I_ZPR02', element: 'Ztpag' }}]
  @EndUserText.label: 'Tipo agente'
  Ztpag         : abap.char(2);

  @EndUserText.label: 'Protocollo'
  Prot          : /eacm/zzprotd;

  @EndUserText.label: 'Codice fiscale ditta'
  Cf            : /eacm/zccfena;


}
