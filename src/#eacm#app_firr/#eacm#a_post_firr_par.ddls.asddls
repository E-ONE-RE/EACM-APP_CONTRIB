@EndUserText.label: 'Parametri contabilizzazione FIRR'
define abstract entity /EACM/A_POST_FIRR_PAR
{
  @Consumption.valueHelpDefinition: [{
    entity: {name: '/EACM/R_T001', element: 'Bukrs' }}]
  Bukrs                   : bukrs;
  Gjahr                   : gjahr;
  @Consumption.valueHelpDefinition: [{
    entity: {name: '/EACM/I_ZPRAA', element: 'Zcdaz' }}]
  Zcdaz                   : /eacm/zcdaz;
  @Consumption.valueHelpDefinition: [{
    entity: {name: '/EACM/I_ZPR02', element: 'Ztpag' }}]
  Ztpag                   : /eacm/ztpag;
  @EndUserText.label: 'Test'
  PaTest                  : abap_boolean;
  DocumentDate            : abap.dats;
  PostingDate             : abap.dats;
  AccountingDocumentType  : abap.char(2);
  @Consumption.valueHelpDefinition: [{
    entity: {name: '/EACM/I_ZPR43', element: 'Zfratt' }}]
  AssignmentRule          : abap.char(10);
  AssignmentReference     : abap.char(18);

}
