@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: '/eacm/prfirr'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity /EACM/R_ZPRFIRR
  as select from /eacm/zprfirr
{
  key bukrs as Bukrs,
  key vkorg as Vkorg,
  key gjahr as Gjahr,
  key zcdaz as Zcdaz,
  lifnr as Lifnr,
  @Consumption.valueHelpDefinition: [ {
    entity.name: 'I_CurrencyStdVH', 
    entity.element: 'Currency', 
    useForValidation: true
  } ]
  waerk as Waerk,
  @Semantics.amount.currencyCode: 'Waerk'
  zfpmat as Zfpmat,
  ztprc as Ztprc,
  ztpmf as Ztpmf,
  @Semantics.amount.currencyCode: 'Waerk'
  zfbuto as Zfbuto,
  mesi as Mesi,
  @Semantics.amount.currencyCode: 'Waerk'
  zfpmat_1 as Zfpmat1,
  ztprc_1 as Ztprc1,
  @Semantics.amount.currencyCode: 'Waerk'
  zfbuto_1 as Zfbuto1,
  @Semantics.amount.currencyCode: 'Waerk'
  zfpmat_2 as Zfpmat2,
  ztprc_2 as Ztprc2,
  @Semantics.amount.currencyCode: 'Waerk'
  zfbuto_2 as Zfbuto2,
  @Semantics.amount.currencyCode: 'Waerk'
  zfpmat_3 as Zfpmat3,
  ztprc_3 as Ztprc3,
  @Semantics.amount.currencyCode: 'Waerk'
  zfbuto_3 as Zfbuto3,
  @Semantics.amount.currencyCode: 'Waerk'
  zfpmat_4 as Zfpmat4,
  ztprc_4 as Ztprc4,
  @Semantics.amount.currencyCode: 'Waerk'
  zfbuto_4 as Zfbuto4,
  @Semantics.amount.currencyCode: 'Waerk'
  zfpmat_5 as Zfpmat5,
  ztprc_5 as Ztprc5,
  @Semantics.amount.currencyCode: 'Waerk'
  zfbuto_5 as Zfbuto5,
  @Semantics.amount.currencyCode: 'Waerk'
  zfpmat_6 as Zfpmat6,
  ztprc_6 as Ztprc6,
  @Semantics.amount.currencyCode: 'Waerk'
  zfbuto_6 as Zfbuto6,
  @Semantics.amount.currencyCode: 'Waerk'
  zfpmat_7 as Zfpmat7,
  ztprc_7 as Ztprc7,
  @Semantics.amount.currencyCode: 'Waerk'
  zfbuto_7 as Zfbuto7,
  @Semantics.amount.currencyCode: 'Waerk'
  zfpmat_8 as Zfpmat8,
  ztprc_8 as Ztprc8,
  @Semantics.amount.currencyCode: 'Waerk'
  zfbuto_8 as Zfbuto8,
  @Semantics.amount.currencyCode: 'Waerk'
  zfpmat_9 as Zfpmat9,
  ztprc_9 as Ztprc9,
  @Semantics.amount.currencyCode: 'Waerk'
  zfbuto_9 as Zfbuto9,
  @Semantics.amount.currencyCode: 'Waerk'
  zfpmat_10 as Zfpmat10,
  ztprc_10 as Ztprc10,
  @Semantics.amount.currencyCode: 'Waerk'
  zfbuto_10 as Zfbuto10,
  @Semantics.amount.currencyCode: 'Waerk'
  zfpmat_11 as Zfpmat11,
  ztprc_11 as Ztprc11,
  @Semantics.amount.currencyCode: 'Waerk'
  zfbuto_11 as Zfbuto11,
  @Semantics.amount.currencyCode: 'Waerk'
  zfpmat_12 as Zfpmat12,
  ztprc_12 as Ztprc12,
  @Semantics.amount.currencyCode: 'Waerk'
  zfbuto_12 as Zfbuto12,
  @Consumption.valueHelpDefinition: [ {
    entity.name: 'I_CurrencyStdVH', 
    entity.element: 'Currency', 
    useForValidation: true
  } ]
  waersc as Waersc,
  @Semantics.amount.currencyCode: 'Waersc'
  zfpmatc as Zfpmatc,
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
