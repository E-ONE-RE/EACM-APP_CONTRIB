@EndUserText.label: 'Parametri calcolo Enasarco'
define abstract entity /EACM/A_CALC_ENAS_PAR
{
 // @EndUserText.label: 'Anno'
  gjahr     : gjahr;

//  @EndUserText.label: 'Mese'
  monat     : monat;

  @Consumption.valueHelpDefinition: [{
    entity: {name: '/EACM/R_T001', element: 'Bukrs' }}]
//  @EndUserText.label: 'Società'
  bukrs     : bukrs;

  @EndUserText.label: 'Test'
  test_mode : abap_boolean;
  }
