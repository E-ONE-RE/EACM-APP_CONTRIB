@EndUserText.label: 'Parametri contabilizzazione Enasarco'
define abstract entity /EACM/A_POST_ENAS_PAR
{
  @Consumption.valueHelpDefinition: [{
    entity: {name: '/EACM/R_T001', element: 'Bukrs' }}]
  Bukrs                   : bukrs;
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
//  @Consumption.valueHelpDefinition: [{
//    entity: {name: '/EACM/I_ZPR43', element: 'Zfratt' }}]
  AssignmentRule          : /eacm/zfratt;
  AssignmentReference     : abap.char(18);
}
