CLASS lhc_rzprfirr DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR rZprfirr
        RESULT result.
    METHODS CalculateFirr
      FOR MODIFY
      IMPORTING keys FOR ACTION rZprfirr~CalculateFirr
      RESULT result.

    METHODS PostFirr
        FOR MODIFY
        IMPORTING keys FOR ACTION rZprfirr~PostFirr.
    METHODS set_update_flag
      IMPORTING
        iv_field TYPE string
      CHANGING
        cs_update TYPE any
        cv_changed TYPE abap_bool.

ENDCLASS.

CLASS lhc_rzprfirr IMPLEMENTATION.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  ENDMETHOD.

  METHOD CalculateFirr.
    DATA(lo_engine) = NEW /eacm/cl_firr_engine( ).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      DATA(ls_request) = VALUE /eacm/if_firr_types=>ty_request(
        company_code      = <key>-%param-CompanyCode
        fiscal_year       = <key>-%param-FiscalYear
        period_number     = <key>-%param-PeriodNumber
        definitive        = <key>-%param-Definitive
        group_by_supplier = abap_true ).

      IF <key>-%param-AgentFrom IS NOT INITIAL
         OR <key>-%param-AgentTo IS NOT INITIAL.
        APPEND VALUE #(
          sign   = 'I'
          option = COND #( WHEN <key>-%param-AgentTo IS INITIAL THEN 'EQ' ELSE 'BT' )
          low    = <key>-%param-AgentFrom
          high   = <key>-%param-AgentTo ) TO ls_request-agent_range.
      ENDIF.

      IF <key>-%param-SalesOrgFrom IS NOT INITIAL
         OR <key>-%param-SalesOrgTo IS NOT INITIAL.
        APPEND VALUE #(
          sign   = 'I'
          option = COND #( WHEN <key>-%param-SalesOrgTo IS INITIAL THEN 'EQ' ELSE 'BT' )
          low    = <key>-%param-SalesOrgFrom
          high   = <key>-%param-SalesOrgTo ) TO ls_request-vkorg_range.
      ENDIF.


      TRY.
      DATA(ls_engine_result) = lo_engine->run( ls_request ).

      DATA(lv_severity) = if_abap_behv_message=>severity-success.
*      DATA(lv_message) = |Elaborazione terminata: { ls_engine_result-processed_rows } record elaborati|.
*Processing completed: &1 records processed
      DATA(lv_message) = |Elaborazione terminata: { ls_engine_result-processed_rows } record elaborati|.

      IF line_exists( ls_engine_result-messages[ type = /eacm/if_firr_types=>gc_msg_error ] ).
        lv_severity = if_abap_behv_message=>severity-error.
        lv_message = ls_engine_result-messages[ type = /eacm/if_firr_types=>gc_msg_error ]-text.

        APPEND VALUE #( %cid = <key>-%cid ) TO failed-rzprfirr.

      ELSEIF ls_engine_result-processed_rows = 0.
        lv_severity = if_abap_behv_message=>severity-warning.
        lv_message = 'Nessun record trovato'.

      ELSEIF ls_engine_result-preview = abap_true.
        lv_severity = if_abap_behv_message=>severity-information.
        lv_message = |Simulazione terminata: { ls_engine_result-processed_rows } record elaborati|.
      ENDIF.

      APPEND VALUE #(
        %cid = <key>-%cid
        %msg = new_message_with_text(
          severity = lv_severity
          text     = lv_message ) ) TO reported-rzprfirr.

      APPEND VALUE #(
        %cid = <key>-%cid
        %param = VALUE #(
          RunUUID       = ls_engine_result-run_uuid
          Preview       = ls_engine_result-preview
          ProcessedRows = ls_engine_result-processed_rows
          SavedRows     = ls_engine_result-saved_rows
          BeginDate     = ls_engine_result-period-begin_date
          EndDate       = ls_engine_result-period-end_date
          MessageType   = COND #(
            WHEN lv_severity = if_abap_behv_message=>severity-error THEN 'E'
            WHEN lv_severity = if_abap_behv_message=>severity-warning THEN 'W'
            ELSE 'S' )
          MessageText   = lv_message ) ) TO result.

      CATCH cx_uuid_error INTO DATA(lx_uuid).
        APPEND VALUE #( %cid = <key>-%cid ) TO failed-rzprfirr.
        APPEND VALUE #( %cid = <key>-%cid
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = lx_uuid->get_text( ) ) ) TO reported-rzprfirr.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

   METHOD PostFirr.

    DATA lv_success_count TYPE i.
    DATA lv_error_count   TYPE i.
    DATA lv_info_text     TYPE string.
    DATA lt_post_update TYPE TABLE FOR UPDATE /EACM/R_ZPRFIRR.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).
      DATA(lv_document_date) = COND d(
        WHEN <ls_key>-%param-DocumentDate IS NOT INITIAL
        THEN <ls_key>-%param-DocumentDate
        ELSE cl_abap_context_info=>get_system_date( ) ).

      DATA(lv_posting_date) = COND d(
        WHEN <ls_key>-%param-PostingDate IS NOT INITIAL
        THEN <ls_key>-%param-PostingDate
        ELSE cl_abap_context_info=>get_system_date( ) ).

      DATA(lv_blart) = COND blart(
        WHEN <ls_key>-%param-AccountingDocumentType IS NOT INITIAL
        THEN <ls_key>-%param-AccountingDocumentType
        ELSE 'SA' ).

      DATA(lv_gjahr) = COND gjahr(
        WHEN <ls_key>-%param-Gjahr IS NOT INITIAL
        THEN <ls_key>-%param-Gjahr
        ELSE lv_posting_date(4) ).

      TRY.
          DATA(lo_job) = NEW /eacm/cl_eacm_firr_posting_job( ).
          DATA(lt_result) = lo_job->run(
            VALUE /eacm/cl_eacm_zprfirr_posting=>ty_selection(
              bukrs       = <ls_key>-%param-Bukrs
              gjahr       = lv_gjahr
              bldat       = lv_document_date
              budat       = lv_posting_date
              blart       = lv_blart
              zcdaz       = <ls_key>-%param-Zcdaz
              ztpag       = <ls_key>-%param-Ztpag
              pa_fratt    = <ls_key>-%param-AssignmentRule
              p_zuonr     = <ls_key>-%param-AssignmentReference
              pa_test     = <ls_key>-%param-PaTest ) ).

          READ TABLE lt_result INTO DATA(ls_error_result)
            WITH KEY success = abap_false.

          IF sy-subrc = 0.
            lv_error_count += 1.

            APPEND VALUE #(
              %msg = new_message_with_text(
                       severity = if_abap_behv_message=>severity-error
                       text     = ls_error_result-message_text ) ) TO reported-rzprfirr.

            LOOP AT ls_error_result-message_details INTO DATA(lv_message_detail).
              APPEND VALUE #(
                %msg = new_message_with_text(
                         severity = if_abap_behv_message=>severity-error
                         text     = lv_message_detail ) ) TO reported-rzprfirr.
            ENDLOOP.

            CONTINUE.
          ENDIF.

          IF <ls_key>-%param-PaTest <> abap_true.
            LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<ls_post_result>) WHERE success = abap_true.
              DATA ls_post_update LIKE LINE OF lt_post_update.
              DATA lv_update_changed TYPE abap_bool.

              ls_post_update-Bukrs = <ls_post_result>-bukrs.
              ls_post_update-Gjahr = <ls_post_result>-gjahr.
              ls_post_update-Vkorg = <ls_post_result>-vkorg.
              ls_post_update-Zcdaz = <ls_post_result>-zcdaz.

              set_update_flag(
                EXPORTING
                  iv_field = <ls_post_result>-status_field
                CHANGING
                  cs_update = ls_post_update
                  cv_changed = lv_update_changed ).

              IF <ls_post_result>-total_status_field IS NOT INITIAL
                 AND <ls_post_result>-total_status_field <> <ls_post_result>-status_field.
                set_update_flag(
                  EXPORTING
                    iv_field = <ls_post_result>-total_status_field
                  CHANGING
                    cs_update = ls_post_update
                    cv_changed = lv_update_changed ).
              ENDIF.

              IF lv_update_changed = abap_true.
                APPEND ls_post_update TO lt_post_update.
              ENDIF.
            ENDLOOP.
          ENDIF.

          lv_success_count += lines( lt_result ).

          LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<ls_info_result>).
            APPEND VALUE #(
              %msg = new_message_with_text(
                       severity = COND #( WHEN <ls_info_result>-skipped = abap_true
                                           THEN if_abap_behv_message=>severity-information
                                           ELSE if_abap_behv_message=>severity-success )
                       text     = <ls_info_result>-message_text ) ) TO reported-rzprfirr.
          ENDLOOP.

        CATCH /eacm/cx_eacm_posting INTO DATA(lx_posting).
          lv_error_count += 1.

          APPEND VALUE #(
            %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-error
                     text     = lx_posting->mv_text ) ) TO reported-rzprfirr.

        CATCH cx_http_dest_provider_error INTO DATA(lx_dest).
          lv_error_count += 1.

          APPEND VALUE #(
            %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-error
                     text     = lx_dest->get_text( ) ) ) TO reported-rzprfirr.

        CATCH cx_web_http_client_error INTO DATA(lx_http).
          lv_error_count += 1.

          APPEND VALUE #(
            %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-error
                     text     = lx_http->get_text( ) ) ) TO reported-rzprfirr.
      ENDTRY.
    ENDLOOP.

    IF lt_post_update IS NOT INITIAL.
      MODIFY ENTITIES OF /EACM/R_ZPRFIRR IN LOCAL MODE
        ENTITY rZprfirr
        UPDATE FROM lt_post_update
        FAILED DATA(lt_failed_post_update)
        REPORTED DATA(lt_reported_post_update).

      APPEND LINES OF lt_reported_post_update-rzprfirr TO reported-rzprfirr.

      IF lt_failed_post_update-rzprfirr IS NOT INITIAL.
        lv_error_count += lines( lt_failed_post_update-rzprfirr ).
        APPEND VALUE #(
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = |Errore durante aggiornamento flag FIRR: { lines( lt_failed_post_update-rzprfirr ) } record.| ) )
          TO reported-rzprfirr.
      ENDIF.
    ENDIF.

    lv_info_text = |Esecuzione FIRR terminata. Documenti elaborati: { lv_success_count }, errori: { lv_error_count }.|.
    APPEND VALUE #(
      %msg = new_message_with_text(
               severity = COND #( WHEN lv_error_count > 0
                                   THEN if_abap_behv_message=>severity-warning
                                   ELSE if_abap_behv_message=>severity-success )
               text     = lv_info_text ) ) TO reported-rzprfirr.

  ENDMETHOD.


  METHOD set_update_flag.
    DATA lv_component TYPE string.
    DATA lv_component_compact TYPE string.

    FIELD-SYMBOLS:
      <lv_status> TYPE any,
      <ls_control> TYPE any,
      <lv_control> TYPE any.

    CHECK iv_field IS NOT INITIAL.

    lv_component = iv_field.
    lv_component_compact = iv_field.
    REPLACE ALL OCCURRENCES OF '_' IN lv_component_compact WITH ''.

    UNASSIGN <lv_status>.
    ASSIGN COMPONENT lv_component OF STRUCTURE cs_update TO <lv_status>.
    IF <lv_status> IS NOT ASSIGNED.
      UNASSIGN <lv_status>.
      ASSIGN COMPONENT lv_component_compact OF STRUCTURE cs_update TO <lv_status>.
      IF <lv_status> IS ASSIGNED.
        lv_component = lv_component_compact.
      ENDIF.
    ENDIF.

    CHECK <lv_status> IS ASSIGNED.
    <lv_status> = 'S'.

    ASSIGN COMPONENT '%CONTROL' OF STRUCTURE cs_update TO <ls_control>.
    CHECK <ls_control> IS ASSIGNED.

    UNASSIGN <lv_control>.
    ASSIGN COMPONENT lv_component OF STRUCTURE <ls_control> TO <lv_control>.
    IF <lv_control> IS NOT ASSIGNED AND lv_component <> lv_component_compact.
      UNASSIGN <lv_control>.
      ASSIGN COMPONENT lv_component_compact OF STRUCTURE <ls_control> TO <lv_control>.
    ENDIF.

    CHECK <lv_control> IS ASSIGNED.
    <lv_control> = if_abap_behv=>mk-on.
    cv_changed = abap_true.
  ENDMETHOD.


ENDCLASS.
