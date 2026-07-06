@EndUserText.label: 'Risultato download ENASARCO online'
define abstract entity /EACM/A_EON_DOWNLOAD
{
  @EndUserText.label: 'Nome file'
  FileName           : abap.char(128);

  @EndUserText.label: 'Tipo MIME'
  MimeType           : abap.char(128);

  @EndUserText.label: 'File ENASARCO'
  @Semantics.largeObject: {
    mimeType: 'MimeType',
    fileName: 'FileName',
    contentDispositionPreference: #ATTACHMENT
  }
  FileContent        : abap.rawstring(0);

  @EndUserText.label: 'Dimensione file'
  FileSize           : abap.int8;

  @EndUserText.label: 'File cessati presente'
  HasCessatiFile     : abap_boolean;

  @EndUserText.label: 'Nome file cessati'
  CessatiFileName    : abap.char(128);

  @EndUserText.label: 'Tipo MIME file cessati'
  CessatiMimeType    : abap.char(128);

  @EndUserText.label: 'File cessati'
  @Semantics.largeObject: {
    mimeType: 'CessatiMimeType',
    fileName: 'CessatiFileName',
    contentDispositionPreference: #ATTACHMENT
  }
  CessatiFileContent : abap.rawstring(0);

  @EndUserText.label: 'Dimensione file cessati'
  CessatiFileSize    : abap.int8;
}
