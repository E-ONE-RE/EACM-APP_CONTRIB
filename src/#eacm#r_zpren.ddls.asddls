@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'eACM - Enasarco'
//@Search.searchable: true
define root view entity /EACM/R_ZPREN
  as select from /eacm/zpren
{
  key bukrs as Bukrs,
  key gjahr as Gjahr,
  key lifnr as Lifnr,
  key zcdaz as Zcdaz,
  @Consumption.valueHelpDefinition: [ {
    entity.name: 'I_CurrencyStdVH', 
    entity.element: 'Currency', 
    useForValidation: true
  } ]
  zwaer as Zwaer,
  @Semantics.amount.currencyCode: 'Zwaer'
  zemat_01 as Zemat01,
  @Semantics.amount.currencyCode: 'Zwaer'
  zemat_02 as Zemat02,
  @Semantics.amount.currencyCode: 'Zwaer'
  zemat_03 as Zemat03,
  @Semantics.amount.currencyCode: 'Zwaer'
  zemat1 as Zemat1,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecca_01 as Zecca01,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecca_02 as Zecca02,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecca_03 as Zecca03,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecca1 as Zecca1,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecef_01 as Zecef01,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecef_02 as Zecef02,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecef_03 as Zecef03,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecef1 as Zecef1,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecag_01 as Zecag01,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecag_02 as Zecag02,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecag_03 as Zecag03,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecag1 as Zecag1,
  @Semantics.amount.currencyCode: 'Zwaer'
  zeccd_01 as Zeccd01,
  @Semantics.amount.currencyCode: 'Zwaer'
  zeccd_02 as Zeccd02,
  @Semantics.amount.currencyCode: 'Zwaer'
  zeccd_03 as Zeccd03,
  @Semantics.amount.currencyCode: 'Zwaer'
  zeccd1 as Zeccd1,
  @Semantics.amount.currencyCode: 'Zwaer'
  zever_01 as Zever01,
  @Semantics.amount.currencyCode: 'Zwaer'
  zever_02 as Zever02,
  @Semantics.amount.currencyCode: 'Zwaer'
  zever_03 as Zever03,
  @Semantics.amount.currencyCode: 'Zwaer'
  zever1 as Zever1,
  zecon_01 as Zecon01,
  zecon_02 as Zecon02,
  zecon_03 as Zecon03,
  zecon1 as Zecon1,
  @Semantics.amount.currencyCode: 'Zwaer'
  zemat_04 as Zemat04,
  @Semantics.amount.currencyCode: 'Zwaer'
  zemat_05 as Zemat05,
  @Semantics.amount.currencyCode: 'Zwaer'
  zemat_06 as Zemat06,
  @Semantics.amount.currencyCode: 'Zwaer'
  zemat2 as Zemat2,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecca_04 as Zecca04,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecca_05 as Zecca05,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecca_06 as Zecca06,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecca2 as Zecca2,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecef_04 as Zecef04,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecef_05 as Zecef05,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecef_06 as Zecef06,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecef2 as Zecef2,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecag_04 as Zecag04,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecag_05 as Zecag05,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecag_06 as Zecag06,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecag2 as Zecag2,
  @Semantics.amount.currencyCode: 'Zwaer'
  zeccd_04 as Zeccd04,
  @Semantics.amount.currencyCode: 'Zwaer'
  zeccd_05 as Zeccd05,
  @Semantics.amount.currencyCode: 'Zwaer'
  zeccd_06 as Zeccd06,
  @Semantics.amount.currencyCode: 'Zwaer'
  zeccd2 as Zeccd2,
  @Semantics.amount.currencyCode: 'Zwaer'
  zever_04 as Zever04,
  @Semantics.amount.currencyCode: 'Zwaer'
  zever_05 as Zever05,
  @Semantics.amount.currencyCode: 'Zwaer'
  zever_06 as Zever06,
  @Semantics.amount.currencyCode: 'Zwaer'
  zever2 as Zever2,
  zecon_04 as Zecon04,
  zecon_05 as Zecon05,
  zecon_06 as Zecon06,
  zecon2 as Zecon2,
  @Semantics.amount.currencyCode: 'Zwaer'
  zemat_07 as Zemat07,
  @Semantics.amount.currencyCode: 'Zwaer'
  zemat_08 as Zemat08,
  @Semantics.amount.currencyCode: 'Zwaer'
  zemat_09 as Zemat09,
  @Semantics.amount.currencyCode: 'Zwaer'
  zemat3 as Zemat3,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecca_07 as Zecca07,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecca_08 as Zecca08,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecca_09 as Zecca09,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecca3 as Zecca3,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecef_07 as Zecef07,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecef_08 as Zecef08,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecef_09 as Zecef09,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecef3 as Zecef3,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecag_07 as Zecag07,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecag_08 as Zecag08,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecag_09 as Zecag09,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecag3 as Zecag3,
  @Semantics.amount.currencyCode: 'Zwaer'
  zeccd_07 as Zeccd07,
  @Semantics.amount.currencyCode: 'Zwaer'
  zeccd_08 as Zeccd08,
  @Semantics.amount.currencyCode: 'Zwaer'
  zeccd_09 as Zeccd09,
  @Semantics.amount.currencyCode: 'Zwaer'
  zeccd3 as Zeccd3,
  @Semantics.amount.currencyCode: 'Zwaer'
  zever_07 as Zever07,
  @Semantics.amount.currencyCode: 'Zwaer'
  zever_08 as Zever08,
  @Semantics.amount.currencyCode: 'Zwaer'
  zever_09 as Zever09,
  @Semantics.amount.currencyCode: 'Zwaer'
  zever3 as Zever3,
  zecon_07 as Zecon07,
  zecon_08 as Zecon08,
  zecon_09 as Zecon09,
  zecon3 as Zecon3,
  @Semantics.amount.currencyCode: 'Zwaer'
  zemat_10 as Zemat10,
  @Semantics.amount.currencyCode: 'Zwaer'
  zemat_11 as Zemat11,
  @Semantics.amount.currencyCode: 'Zwaer'
  zemat_12 as Zemat12,
  @Semantics.amount.currencyCode: 'Zwaer'
  zemat4 as Zemat4,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecca_10 as Zecca10,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecca_11 as Zecca11,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecca_12 as Zecca12,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecca4 as Zecca4,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecef_10 as Zecef10,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecef_11 as Zecef11,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecef_12 as Zecef12,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecef4 as Zecef4,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecag_10 as Zecag10,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecag_11 as Zecag11,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecag_12 as Zecag12,
  @Semantics.amount.currencyCode: 'Zwaer'
  zecag4 as Zecag4,
  @Semantics.amount.currencyCode: 'Zwaer'
  zeccd_10 as Zeccd10,
  @Semantics.amount.currencyCode: 'Zwaer'
  zeccd_11 as Zeccd11,
  @Semantics.amount.currencyCode: 'Zwaer'
  zeccd_12 as Zeccd12,
  @Semantics.amount.currencyCode: 'Zwaer'
  zeccd4 as Zeccd4,
  @Semantics.amount.currencyCode: 'Zwaer'
  zever_10 as Zever10,
  @Semantics.amount.currencyCode: 'Zwaer'
  zever_11 as Zever11,
  @Semantics.amount.currencyCode: 'Zwaer'
  zever_12 as Zever12,
  @Semantics.amount.currencyCode: 'Zwaer'
  zever4 as Zever4,
  zecon_10 as Zecon10,
  zecon_11 as Zecon11,
  zecon_12 as Zecon12,
  zecon4 as Zecon4,
  @Semantics.amount.currencyCode: 'Zwaer'
  zfpmat as Zfpmat,
  @Semantics.amount.currencyCode: 'Zwaer'
  zfprem as Zfprem,
  @Semantics.amount.currencyCode: 'Zwaer'
  zfspes as Zfspes,
  @Semantics.amount.currencyCode: 'Zwaer'
  zfbuto as Zfbuto,
  zfcone as Zfcone,
  zstre as Zstre,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.lastChangedBy: true
  changed_by as ChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  changed_at as ChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt
}
