@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: 'FISC'
}

@AccessControl.authorizationCheck: #MANDATORY
define root view entity /EACM/C_ZPRFISC
  provider contract transactional_query
  as projection on /EACM/R_ZPRFISC
  association [1..1] to /EACM/R_ZPRFISC as _BaseEntity on $projection.Bukrs = _BaseEntity.Bukrs and $projection.Vkorg = _BaseEntity.Vkorg and $projection.Gjahr = _BaseEntity.Gjahr and $projection.Zcdaz = _BaseEntity.Zcdaz
{
  key Bukrs,
  key Vkorg,
  key Gjahr,
  key Zcdaz,
  Lifnr,
  @Consumption: {
    valueHelpDefinition: [ {
      entity.element: 'Currency', 
      entity.name: 'I_CurrencyStdVH', 
      useForValidation: true
    } ]
  }
  Waerk,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zimprv,
  Ztprc,
  Ztpmf,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zfisc,
  Mesi,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zimprv1,
  Ztprc1,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zfisc1,
  Zper1,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zimprv2,
  Ztprc2,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zfisc2,
  Zper2,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zimprv3,
  Ztprc3,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zfisc3,
  Zper3,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zimprv4,
  Ztprc4,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zfisc4,
  Zper4,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zimprv5,
  Ztprc5,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zfisc5,
  Zper5,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zimprv6,
  Ztprc6,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zfisc6,
  Zper6,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zimprv7,
  Ztprc7,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zfisc7,
  Zper7,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zimprv8,
  Ztprc8,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zfisc8,
  Zper8,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zimprv9,
  Ztprc9,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zfisc9,
  Zper9,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zimprv10,
  Ztprc10,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zfisc10,
  Zper10,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zimprv11,
  Ztprc11,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zfisc11,
  Zper11,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zimprv12,
  Ztprc12,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zfisc12,
  Zper12,
  @Semantics: {
    user.createdBy: true
  }
  CreatedBy,
  @Semantics: {
    systemDateTime.createdAt: true
  }
  CreatedAt,
  @Semantics: {
    user.lastChangedBy: true
  }
  ChangedBy,
  @Semantics: {
    systemDateTime.lastChangedAt: true
  }
  ChangedAt,
  @Semantics: {
    systemDateTime.localInstanceLastChangedAt: true
  }
  LocalLastChangedAt,
  _BaseEntity
}
