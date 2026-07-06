@EndUserText.label: 'FIRR unified action input'
define abstract entity /eacm/a_firr_action_input
{
  @Consumption.valueHelpDefinition: [{
    entity: {name: '/EACM/R_T001', element: 'Bukrs' }}]
  CompanyCode      : bukrs;
  FiscalYear       : gjahr;
  
//  @Consumption.defaultValue: 'M'
//  FirrPeriodicity  : /eacm/tpper;  // M monthly, T quarterly, A yearly
  PeriodNumber     : abap.numc(2);
//  @Consumption.defaultValue: 'MAT'
//  CalculationBasis : abap.char(4);  // FATT, MAT, FAC, CON
  @EndUserText.label: 'Definitivo'
  Definitive       : abap_boolean;
//  GroupBySupplier  : abap_boolean;
  @Consumption.valueHelpDefinition: [{
    entity: {name: '/EACM/I_ZPRAA', element: 'Zcdaz' }}]
  AgentFrom        : /eacm/zcdaz;
  @Consumption.valueHelpDefinition: [{
    entity: {name: '/EACM/I_ZPRAA', element: 'Zcdaz' }}]
  AgentTo          : /eacm/zcdaz;
  @Consumption.valueHelpDefinition: [{
    entity: {name: '/EACM/I_TVKO', element: 'Vkorg' }}]
  SalesOrgFrom     : vkorg;
  @Consumption.valueHelpDefinition: [{
    entity: {name: '/EACM/I_TVKO', element: 'Vkorg' }}]
  SalesOrgTo       : vkorg;
}
