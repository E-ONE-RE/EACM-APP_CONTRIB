@EndUserText.label: 'FIRR unified action result'
define abstract entity /eacm/a_firr_action_result
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
