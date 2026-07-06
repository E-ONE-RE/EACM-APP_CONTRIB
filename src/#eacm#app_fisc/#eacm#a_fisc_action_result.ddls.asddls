@EndUserText.label: 'FISC unified action result'
define abstract entity /EACM/A_FISC_ACTION_RESULT
{
  RunUUID       : sysuuid_x16;
  Preview       : abap_boolean;
  ProcessedRows : abap.int4;
  SavedRows     : abap.int4;
  BeginDate     : abap.dats;
  EndDate       : abap.dats;
  MessageType   : abap.char(1);
  MessageText   : abap.string(0);
}
