@EndUserText.label: 'Download file ENASARCO online'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true
@UI.headerInfo: {
  typeName: 'File ENASARCO',
  typeNamePlural: 'File ENASARCO',
  title: { value: 'FileName' },
  description: { value: 'CreatedAt' }
}
@UI.presentationVariant: [{
  sortOrder: [{ by: 'CreatedAt', direction: #DESC }],
  visualizations: [{ type: #AS_LINEITEM }]
}]

define root view entity /EACM/C_EON_FILE
  as projection on /EACM/I_EON_FILE
{

@UI.lineItem: [{
  position: 5,
  type: #FOR_ACTION,
  dataAction: 'GenerateEnasarcoOnline',
  label: 'Create file ENASARCO'
}]
  @UI.hidden: true
  key FileUuid,
  @Search.defaultSearchElement: true
  @UI.lineItem: [{ position: 10, importance: #HIGH }]
  @UI.identification: [{ position: 10 }]
  FileName,

  @UI.lineItem: [{ position: 20, importance: #HIGH }]
  @UI.identification: [{ position: 20 }]
  @UI.selectionField: [{ position: 20 }]
  CreatedAt,

  @UI.lineItem: [{ position: 30 }]
  @UI.identification: [{ position: 30 }]
  @UI.selectionField: [{ position: 30 }]
  CreatedBy,

  @UI.lineItem: [{ position: 35 }]
  @UI.identification: [{ position: 35 }]
  @UI.selectionField: [{ position: 10 }]
  Bukrs,

  @UI.lineItem: [{ position: 36 }]
  @UI.identification: [{ position: 36 }]
  @UI.selectionField: [{ position: 40 }]
  Gjahr,

  @UI.lineItem: [{ position: 37 }]
  @UI.identification: [{ position: 37 }]
  @UI.selectionField: [{ position: 50 }]
  Trimes,

  Firr,
  Zcdaz,
  Ztpag,
  Prot,
  Ditta,
  Cf,
  SplitCessati,

  @UI.hidden: true
  MimeType,

  @UI.lineItem: [{ position: 40 }]
  @UI.identification: [{ position: 40 }]
  FileSize,

  @UI.lineItem: [{ position: 50, label: 'Download', importance: #HIGH }]
  @UI.identification: [{ position: 50, label: 'Download' }]
  FileContent
}

