@EndUserText.label: 'FISC posting action input'
define abstract entity /eacm/a_fisc_post_input
{
  @Consumption.valueHelpDefinition: [{
    entity: {name: '/EACM/R_T001', element: 'Bukrs' }}]
  CompanyCode      : bukrs;
  FiscalYear       : gjahr;
  @EndUserText.label: 'In Test'
  TestRun                : abap_boolean;
  DocumentDate           : abap.dats;
  PostingDate            : abap.dats;
  AccountingDocumentType : blart;
  @Consumption.valueHelpDefinition: [{
    entity: {name: '/EACM/I_ZPR43', element: 'Zfratt' }}]
  AssignmentRule         : abap.char(10);
  AssignmentReference    : abap.char(18);
  @Consumption.valueHelpDefinition: [{
    entity: {name: '/EACM/I_ZPRAA', element: 'Zcdaz' }}]
  AgentFrom              : /eacm/zcdaz;
  @Consumption.valueHelpDefinition: [{
    entity: {name: '/EACM/I_ZPRAA', element: 'Zcdaz' }}]
  AgentTo                : /eacm/zcdaz;
//  PaymentTypeFrom        : /eacm/ztpag;
//  PaymentTypeTo          : /eacm/ztpag;
//  SalesOrgFrom           : vkorg;
//  SalesOrgTo             : vkorg;
//  CommissionClassFrom    : /eacm/zclpr;
//  CommissionClassTo      : /eacm/zclpr;
//  BillingDocumentFrom    : vbeln;
//  BillingDocumentTo      : vbeln;
}

