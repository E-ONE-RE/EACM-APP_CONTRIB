CLASS /eacm/cl_eacm_firr_posting_job DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS run
      IMPORTING
        is_selection        TYPE /eacm/cl_eacm_zprfirr_posting=>ty_selection
        iv_flush_api_log    TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_result)    TYPE /eacm/cl_eacm_zprfirr_posting=>tt_post_result
      RAISING
        /eacm/cx_eacm_posting
        cx_http_dest_provider_error
        cx_web_http_client_error.
ENDCLASS.


CLASS /eacm/cl_eacm_firr_posting_job IMPLEMENTATION.

  METHOD run.
    DATA lo_service TYPE REF TO /eacm/cl_eacm_zprfirr_posting.
    DATA ls_selection TYPE /eacm/cl_eacm_zprfirr_posting=>ty_selection.

    CREATE OBJECT lo_service.
    ls_selection = is_selection.

    IF ls_selection-blart IS INITIAL.
      ls_selection-blart = 'SA'.
    ENDIF.

     IF ls_selection-bukrs IS INITIAL OR
       ls_selection-gjahr IS INITIAL OR
       ls_selection-bldat IS INITIAL OR
       ls_selection-budat IS INITIAL OR
       ls_selection-blart IS INITIAL.
      RAISE EXCEPTION TYPE /eacm/cx_eacm_posting
        EXPORTING
          iv_text = 'Parametri obbligatori mancanti: BUKRS, GJAHR, BLDAT, BUDAT, BLART'.
    ENDIF.

    rt_result = lo_service->execute( ls_selection ).

    IF iv_flush_api_log = abap_true.
      /eacm/cl_api_log=>flush( ).
    ENDIF.

    IF rt_result IS INITIAL.
      RAISE EXCEPTION TYPE /eacm/cx_eacm_posting
        EXPORTING
          iv_text = 'Nessun documento FIRR da contabilizzare per i criteri selezionati'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

