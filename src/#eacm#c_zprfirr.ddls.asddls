@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: 'FIRR'
}
//@ObjectModel: {
//  sapObjectNodeType.name: '/eacm/prfirr'
//}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity /EACM/C_ZPRFIRR
  provider contract transactional_query
  as projection on /EACM/R_ZPRFIRR
  association [1..1] to /EACM/R_ZPRFIRR as _BaseEntity on $projection.Bukrs = _BaseEntity.Bukrs and $projection.Vkorg = _BaseEntity.Vkorg and $projection.Gjahr = _BaseEntity.Gjahr and $projection.Zcdaz = _BaseEntity.Zcdaz
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
  Zfpmat,
  Ztprc,
  Ztpmf,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zfbuto,
  Mesi,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zfpmat1,
  Ztprc1,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zfbuto1,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zfpmat2,
  Ztprc2,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zfbuto2,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zfpmat3,
  Ztprc3,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zfbuto3,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zfpmat4,
  Ztprc4,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zfbuto4,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zfpmat5,
  Ztprc5,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zfbuto5,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zfpmat6,
  Ztprc6,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zfbuto6,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zfpmat7,
  Ztprc7,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zfbuto7,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zfpmat8,
  Ztprc8,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zfbuto8,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zfpmat9,
  Ztprc9,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zfbuto9,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zfpmat10,
  Ztprc10,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zfbuto10,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zfpmat11,
  Ztprc11,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zfbuto11,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zfpmat12,
  Ztprc12,
  @Semantics: {
    amount.currencyCode: 'Waerk'
  }
  Zfbuto12,
  @Consumption: {
    valueHelpDefinition: [ {
      entity.element: 'Currency', 
      entity.name: 'I_CurrencyStdVH', 
      useForValidation: true
    } ]
  }
  Waersc,
  @Semantics: {
    amount.currencyCode: 'Waersc'
  }
  Zfpmatc,
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
