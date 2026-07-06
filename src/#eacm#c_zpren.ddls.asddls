@Metadata.allowExtensions: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Enasarco'
@Metadata.ignorePropagatedAnnotations: true
define root view entity /EACM/C_ZPREN 
as projection on /EACM/R_ZPREN
{
    key Bukrs,
    key Gjahr,
    key Lifnr,
    key Zcdaz,
    Zwaer,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zemat01,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zemat02,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zemat03,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zemat1,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecca01,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecca02,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecca03,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecca1,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecef01,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecef02,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecef03,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecef1,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecag01,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecag02,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecag03,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecag1,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zeccd01,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zeccd02,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zeccd03,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zeccd1,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zever01,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zever02,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zever03,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zever1,
    Zecon01,
    Zecon02,
    Zecon03,
    Zecon1,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zemat04,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zemat05,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zemat06,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zemat2,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecca04,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecca05,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecca06,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecca2,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecef04,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecef05,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecef06,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecef2,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecag04,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecag05,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecag06,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecag2,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zeccd04,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zeccd05,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zeccd06,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zeccd2,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zever04,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zever05,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zever06,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zever2,
    Zecon04,
    Zecon05,
    Zecon06,
    Zecon2,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zemat07,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zemat08,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zemat09,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zemat3,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecca07,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecca08,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecca09,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecca3,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecef07,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecef08,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecef09,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecef3,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecag07,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecag08,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecag09,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecag3,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zeccd07,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zeccd08,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zeccd09,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zeccd3,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zever07,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zever08,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zever09,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zever3,
    Zecon07,
    Zecon08,
    Zecon09,
    Zecon3,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zemat10,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zemat11,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zemat12,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zemat4,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecca10,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecca11,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecca12,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecca4,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecef10,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecef11,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecef12,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecef4,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecag10,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecag11,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecag12,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zecag4,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zeccd10,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zeccd11,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zeccd12,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zeccd4,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zever10,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zever11,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zever12,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zever4,
    Zecon10,
    Zecon11,
    Zecon12,
    Zecon4,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zfpmat,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zfprem,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zfspes,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zfbuto,
  @Semantics.amount.currencyCode: 'Zwaer'
    Zfcone,
    Zstre,
    CreatedBy,
    CreatedAt,
    ChangedBy,
    ChangedAt,
    LocalLastChangedAt
}
