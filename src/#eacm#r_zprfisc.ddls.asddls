@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true

@EndUserText.label: 'Gestione FISC'
define root view entity /EACM/R_ZPRFISC
  as select from /eacm/zprfisc
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
  zimprv as Zimprv,
  ztprc as Ztprc,
  ztpmf as Ztpmf,
  @Semantics.amount.currencyCode: 'Waerk'
  zfisc as Zfisc,
  mesi as Mesi,
  @Semantics.amount.currencyCode: 'Waerk'
  zimprv_1 as Zimprv1,
  ztprc_1 as Ztprc1,
  @Semantics.amount.currencyCode: 'Waerk'
  zfisc_1 as Zfisc1,
  zper1 as Zper1,
  @Semantics.amount.currencyCode: 'Waerk'
  zimprv_2 as Zimprv2,
  ztprc_2 as Ztprc2,
  @Semantics.amount.currencyCode: 'Waerk'
  zfisc_2 as Zfisc2,
  zper2 as Zper2,
  @Semantics.amount.currencyCode: 'Waerk'
  zimprv_3 as Zimprv3,
  ztprc_3 as Ztprc3,
  @Semantics.amount.currencyCode: 'Waerk'
  zfisc_3 as Zfisc3,
  zper3 as Zper3,
  @Semantics.amount.currencyCode: 'Waerk'
  zimprv_4 as Zimprv4,
  ztprc_4 as Ztprc4,
  @Semantics.amount.currencyCode: 'Waerk'
  zfisc_4 as Zfisc4,
  zper4 as Zper4,
  @Semantics.amount.currencyCode: 'Waerk'
  zimprv_5 as Zimprv5,
  ztprc_5 as Ztprc5,
  @Semantics.amount.currencyCode: 'Waerk'
  zfisc_5 as Zfisc5,
  zper5 as Zper5,
  @Semantics.amount.currencyCode: 'Waerk'
  zimprv_6 as Zimprv6,
  ztprc_6 as Ztprc6,
  @Semantics.amount.currencyCode: 'Waerk'
  zfisc_6 as Zfisc6,
  zper6 as Zper6,
  @Semantics.amount.currencyCode: 'Waerk'
  zimprv_7 as Zimprv7,
  ztprc_7 as Ztprc7,
  @Semantics.amount.currencyCode: 'Waerk'
  zfisc_7 as Zfisc7,
  zper7 as Zper7,
  @Semantics.amount.currencyCode: 'Waerk'
  zimprv_8 as Zimprv8,
  ztprc_8 as Ztprc8,
  @Semantics.amount.currencyCode: 'Waerk'
  zfisc_8 as Zfisc8,
  zper8 as Zper8,
  @Semantics.amount.currencyCode: 'Waerk'
  zimprv_9 as Zimprv9,
  ztprc_9 as Ztprc9,
  @Semantics.amount.currencyCode: 'Waerk'
  zfisc_9 as Zfisc9,
  zper9 as Zper9,
  @Semantics.amount.currencyCode: 'Waerk'
  zimprv_10 as Zimprv10,
  ztprc_10 as Ztprc10,
  @Semantics.amount.currencyCode: 'Waerk'
  zfisc_10 as Zfisc10,
  zper10 as Zper10,
  @Semantics.amount.currencyCode: 'Waerk'
  zimprv_11 as Zimprv11,
  ztprc_11 as Ztprc11,
  @Semantics.amount.currencyCode: 'Waerk'
  zfisc_11 as Zfisc11,
  zper11 as Zper11,
  @Semantics.amount.currencyCode: 'Waerk'
  zimprv_12 as Zimprv12,
  ztprc_12 as Ztprc12,
  @Semantics.amount.currencyCode: 'Waerk'
  zfisc_12 as Zfisc12,
  zper12 as Zper12,
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
