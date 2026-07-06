CLASS LHC_/EACM/R_ZPRFISC DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR /eacm/rZprfisc
        RESULT result.

    METHODS CalculateFisc
      FOR MODIFY
      IMPORTING keys FOR ACTION /eacm/rZprfisc~CalculateFisc
      RESULT result.

    METHODS PostFisc
      FOR MODIFY
      IMPORTING keys FOR ACTION /eacm/rZprfisc~PostFisc
      RESULT result.
ENDCLASS.

CLASS LHC_/EACM/R_ZPRFISC IMPLEMENTATION.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  ENDMETHOD.

  METHOD CalculateFisc.
    DATA(lo_engine) = NEW /eacm/cl_fisc_engine( ).

    FIELD-SYMBOLS:
      <src_field>  TYPE any,
      <dst_field>  TYPE any,
      <ctrl_field> TYPE any.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      DATA(ls_request) = VALUE /eacm/if_fisc_types=>ty_request(
        company_code      = <key>-%param-CompanyCode
        fiscal_year       = <key>-%param-FiscalYear
        period_number     = <key>-%param-PeriodNumber
        definitive        = <key>-%param-Definitive ).

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

      DATA ls_engine_result TYPE /eacm/if_fisc_types=>ty_result.
      ls_engine_result-preview = xsdbool( ls_request-definitive = abap_false ).

      TRY.
          ls_engine_result = lo_engine->run( ls_request ).
        CATCH cx_root INTO DATA(lx_engine).
          APPEND VALUE #(
            type = /eacm/if_fisc_types=>gc_msg_error
            text = lx_engine->get_text( ) ) TO ls_engine_result-messages.
      ENDTRY.

      DATA(lv_save_failed) = abap_false.
      DATA(lv_save_message) = VALUE string( ).
      DATA(lv_has_engine_error) = xsdbool(
        line_exists( ls_engine_result-messages[ type = /eacm/if_fisc_types=>gc_msg_error ] ) ).

      IF ls_request-definitive = abap_true
         AND ls_engine_result-fisc_rows IS NOT INITIAL
         AND lv_has_engine_error = abap_false.

        DATA lt_update TYPE TABLE FOR UPDATE /EACM/R_ZPRFISC.
        DATA lt_create TYPE TABLE FOR CREATE /EACM/R_ZPRFISC.
        DATA ls_update LIKE LINE OF lt_update.
        DATA ls_create LIKE LINE OF lt_create.
        DATA lv_cid_counter TYPE i.
        DATA lv_fisc_exists TYPE abap_bool.

        CLEAR: lt_update, lt_create, ls_update, ls_create, lv_cid_counter, lv_fisc_exists.

        LOOP AT ls_engine_result-fisc_rows INTO DATA(ls_fisc).
          CLEAR: ls_update, ls_create, lv_fisc_exists.

          ls_update-Bukrs = ls_fisc-bukrs.
          ls_update-Vkorg = ls_fisc-vkorg.
          ls_update-Gjahr = ls_fisc-gjahr.
          ls_update-Zcdaz = ls_fisc-zcdaz.

          ls_update-Lifnr = ls_fisc-lifnr.
          ls_update-Waerk = ls_fisc-waerk.
          ls_update-Zimprv = ls_fisc-zimprv.
          ls_update-Ztprc = ls_fisc-ztprc.
          ls_update-Ztpmf = ls_fisc-ztpmf.
          ls_update-Zfisc = ls_fisc-zfisc.
          ls_update-Mesi = ls_fisc-mesi.

          ls_update-%control-Lifnr = if_abap_behv=>mk-on.
          ls_update-%control-Waerk = if_abap_behv=>mk-on.
          ls_update-%control-Zimprv = if_abap_behv=>mk-on.
          ls_update-%control-Ztprc = if_abap_behv=>mk-on.
          ls_update-%control-Ztpmf = if_abap_behv=>mk-on.
          ls_update-%control-Zfisc = if_abap_behv=>mk-on.
          ls_update-%control-Mesi = if_abap_behv=>mk-on.

          DO ls_engine_result-period-period_field_index TIMES.
            DATA(lv_period_index) = CONV string( sy-index ).

            UNASSIGN: <src_field>, <dst_field>, <ctrl_field>.
            ASSIGN COMPONENT |ZIMPRV_{ lv_period_index }| OF STRUCTURE ls_fisc TO <src_field>.
            ASSIGN COMPONENT |Zimprv{ lv_period_index }| OF STRUCTURE ls_update TO <dst_field>.
            ASSIGN COMPONENT |Zimprv{ lv_period_index }| OF STRUCTURE ls_update-%control TO <ctrl_field>.
            IF <src_field> IS ASSIGNED AND <dst_field> IS ASSIGNED AND <ctrl_field> IS ASSIGNED.
              <dst_field> = <src_field>.
              <ctrl_field> = if_abap_behv=>mk-on.
            ENDIF.

            UNASSIGN: <src_field>, <dst_field>, <ctrl_field>.
            ASSIGN COMPONENT |ZFISC_{ lv_period_index }| OF STRUCTURE ls_fisc TO <src_field>.
            ASSIGN COMPONENT |Zfisc{ lv_period_index }| OF STRUCTURE ls_update TO <dst_field>.
            ASSIGN COMPONENT |Zfisc{ lv_period_index }| OF STRUCTURE ls_update-%control TO <ctrl_field>.
            IF <src_field> IS ASSIGNED AND <dst_field> IS ASSIGNED AND <ctrl_field> IS ASSIGNED.
              <dst_field> = <src_field>.
              <ctrl_field> = if_abap_behv=>mk-on.
            ENDIF.

            UNASSIGN: <src_field>, <dst_field>, <ctrl_field>.
            ASSIGN COMPONENT |ZTPRC_{ lv_period_index }| OF STRUCTURE ls_fisc TO <src_field>.
            ASSIGN COMPONENT |Ztprc{ lv_period_index }| OF STRUCTURE ls_update TO <dst_field>.
            ASSIGN COMPONENT |Ztprc{ lv_period_index }| OF STRUCTURE ls_update-%control TO <ctrl_field>.
            IF <src_field> IS ASSIGNED AND <dst_field> IS ASSIGNED AND <ctrl_field> IS ASSIGNED.
              <dst_field> = <src_field>.
              <ctrl_field> = if_abap_behv=>mk-on.
            ENDIF.

            UNASSIGN: <src_field>, <dst_field>, <ctrl_field>.
            ASSIGN COMPONENT |ZPER{ lv_period_index }| OF STRUCTURE ls_fisc TO <src_field>.
            ASSIGN COMPONENT |Zper{ lv_period_index }| OF STRUCTURE ls_update TO <dst_field>.
            ASSIGN COMPONENT |Zper{ lv_period_index }| OF STRUCTURE ls_update-%control TO <ctrl_field>.
            IF <src_field> IS ASSIGNED AND <dst_field> IS ASSIGNED AND <ctrl_field> IS ASSIGNED.
              <dst_field> = <src_field>.
              <ctrl_field> = if_abap_behv=>mk-on.
            ENDIF.
          ENDDO.

          SELECT SINGLE @abap_true
            FROM /eacm/zprfisc
            WHERE bukrs = @ls_fisc-bukrs
              AND vkorg = @ls_fisc-vkorg
              AND gjahr = @ls_fisc-gjahr
              AND zcdaz = @ls_fisc-zcdaz
            INTO @lv_fisc_exists.

          IF lv_fisc_exists = abap_true.
            READ TABLE lt_update ASSIGNING FIELD-SYMBOL(<existing_update>)
              WITH TABLE KEY entity COMPONENTS
                Bukrs = ls_update-Bukrs
                Vkorg = ls_update-Vkorg
                Gjahr = ls_update-Gjahr
                Zcdaz = ls_update-Zcdaz.

            IF sy-subrc = 0.
              <existing_update>-Zimprv += ls_update-Zimprv.
              <existing_update>-Zfisc += ls_update-Zfisc.

              DO ls_engine_result-period-period_field_index TIMES.
                lv_period_index = CONV string( sy-index ).

                UNASSIGN: <src_field>, <dst_field>.
                ASSIGN COMPONENT |Zimprv{ lv_period_index }| OF STRUCTURE ls_update TO <src_field>.
                ASSIGN COMPONENT |Zimprv{ lv_period_index }| OF STRUCTURE <existing_update> TO <dst_field>.
                IF <src_field> IS ASSIGNED AND <dst_field> IS ASSIGNED.
                  <dst_field> += <src_field>.
                ENDIF.

                UNASSIGN: <src_field>, <dst_field>.
                ASSIGN COMPONENT |Zfisc{ lv_period_index }| OF STRUCTURE ls_update TO <src_field>.
                ASSIGN COMPONENT |Zfisc{ lv_period_index }| OF STRUCTURE <existing_update> TO <dst_field>.
                IF <src_field> IS ASSIGNED AND <dst_field> IS ASSIGNED.
                  <dst_field> += <src_field>.
                ENDIF.
              ENDDO.
            ELSE.
              APPEND ls_update TO lt_update.
            ENDIF.
          ELSE.
            MOVE-CORRESPONDING ls_update TO ls_create.
            lv_cid_counter += 1.

            ls_create-%cid = |ZPRFISC_{ lv_cid_counter }|.
            ls_create-%control-Bukrs = if_abap_behv=>mk-on.
            ls_create-%control-Vkorg = if_abap_behv=>mk-on.
            ls_create-%control-Gjahr = if_abap_behv=>mk-on.
            ls_create-%control-Zcdaz = if_abap_behv=>mk-on.

            READ TABLE lt_create ASSIGNING FIELD-SYMBOL(<existing_create>)
              WITH TABLE KEY entity COMPONENTS
                Bukrs = ls_create-Bukrs
                Vkorg = ls_create-Vkorg
                Gjahr = ls_create-Gjahr
                Zcdaz = ls_create-Zcdaz.

            IF sy-subrc = 0.
              <existing_create>-Zimprv += ls_create-Zimprv.
              <existing_create>-Zfisc += ls_create-Zfisc.

              DO ls_engine_result-period-period_field_index TIMES.
                lv_period_index = CONV string( sy-index ).

                UNASSIGN: <src_field>, <dst_field>.
                ASSIGN COMPONENT |Zimprv{ lv_period_index }| OF STRUCTURE ls_create TO <src_field>.
                ASSIGN COMPONENT |Zimprv{ lv_period_index }| OF STRUCTURE <existing_create> TO <dst_field>.
                IF <src_field> IS ASSIGNED AND <dst_field> IS ASSIGNED.
                  <dst_field> += <src_field>.
                ENDIF.

                UNASSIGN: <src_field>, <dst_field>.
                ASSIGN COMPONENT |Zfisc{ lv_period_index }| OF STRUCTURE ls_create TO <src_field>.
                ASSIGN COMPONENT |Zfisc{ lv_period_index }| OF STRUCTURE <existing_create> TO <dst_field>.
                IF <src_field> IS ASSIGNED AND <dst_field> IS ASSIGNED.
                  <dst_field> += <src_field>.
                ENDIF.
              ENDDO.
            ELSE.
              APPEND ls_create TO lt_create.
            ENDIF.
          ENDIF.
        ENDLOOP.

        IF lt_create IS NOT INITIAL.
          MODIFY ENTITIES OF /EACM/R_ZPRFISC IN LOCAL MODE
            ENTITY /eacm/rZprfisc
            CREATE FROM lt_create
            FAILED DATA(lt_failed_create)
            REPORTED DATA(lt_reported_create).

          APPEND LINES OF lt_reported_create-/eacm/rzprfisc TO reported-/eacm/rzprfisc.

          IF lt_failed_create-/eacm/rzprfisc IS NOT INITIAL.
            lv_save_failed = abap_true.
            lv_save_message = |Errore durante la creazione di { lines( lt_failed_create-/eacm/rzprfisc ) } record fiscali.|.
          ENDIF.
        ENDIF.

        IF lv_save_failed = abap_false AND lt_update IS NOT INITIAL.
          MODIFY ENTITIES OF /EACM/R_ZPRFISC IN LOCAL MODE
            ENTITY /eacm/rZprfisc
            UPDATE FROM lt_update
            FAILED DATA(lt_failed_update)
            REPORTED DATA(lt_reported_update).

          APPEND LINES OF lt_reported_update-/eacm/rzprfisc TO reported-/eacm/rzprfisc.

          IF lt_failed_update-/eacm/rzprfisc IS NOT INITIAL.
            lv_save_failed = abap_true.
            lv_save_message = |Errore durante l'aggiornamento di { lines( lt_failed_update-/eacm/rzprfisc ) } record fiscali.|.
          ENDIF.
        ENDIF.

        IF lv_save_failed = abap_false.
          ls_engine_result-saved_rows = lines( lt_create ) + lines( lt_update ).
        ENDIF.
      ENDIF.

      DATA(lv_severity) = if_abap_behv_message=>severity-success.
      DATA(lv_message) = |Elaborazione fiscale terminata: { ls_engine_result-processed_rows } record elaborati|.
      DATA(lv_engine_error_count) = 0.

      LOOP AT ls_engine_result-messages INTO DATA(ls_engine_message).
        IF ls_engine_message-type = /eacm/if_fisc_types=>gc_msg_error.
          lv_engine_error_count += 1.
        ENDIF.

        APPEND VALUE #(
          %cid = <key>-%cid
          %msg = new_message_with_text(
            severity = SWITCH #( ls_engine_message-type
              WHEN /eacm/if_fisc_types=>gc_msg_error THEN if_abap_behv_message=>severity-error
              WHEN /eacm/if_fisc_types=>gc_msg_warning THEN if_abap_behv_message=>severity-warning
              WHEN /eacm/if_fisc_types=>gc_msg_success THEN if_abap_behv_message=>severity-success
              ELSE if_abap_behv_message=>severity-information )
            text     = ls_engine_message-text ) ) TO reported-/eacm/rzprfisc.
      ENDLOOP.

      IF lv_has_engine_error = abap_true.
        lv_severity = if_abap_behv_message=>severity-error.
        lv_message = |Calcolo FISC terminato con errori: { lv_engine_error_count } errori. Aprire i messaggi di dettaglio.|.

        APPEND VALUE #( %cid = <key>-%cid ) TO failed-/eacm/rzprfisc.

      ELSEIF lv_save_failed = abap_true.
        lv_severity = if_abap_behv_message=>severity-error.
        lv_message = lv_save_message.

        APPEND VALUE #( %cid = <key>-%cid ) TO failed-/eacm/rzprfisc.

      ELSEIF ls_engine_result-processed_rows = 0.
        lv_severity = if_abap_behv_message=>severity-warning.
        lv_message = 'Nessun record trovato'.

      ELSEIF ls_engine_result-preview = abap_true.
        lv_severity = if_abap_behv_message=>severity-information.
        lv_message = |Simulazione fiscale terminata: { ls_engine_result-processed_rows } record elaborati|.

      ELSEIF ls_request-definitive = abap_true.
        lv_message = |Elaborazione fiscale definitiva terminata: { ls_engine_result-processed_rows } record elaborati, { ls_engine_result-saved_rows } salvati|.
      ENDIF.

      APPEND VALUE #(
        %cid = <key>-%cid
        %msg = new_message_with_text(
          severity = lv_severity
          text     = lv_message ) ) TO reported-/eacm/rzprfisc.

      APPEND VALUE #(
        %cid = <key>-%cid
        %param = VALUE #(
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
    ENDLOOP.
  ENDMETHOD.


  METHOD PostFisc.
    DATA(lo_posting) = NEW /eacm/cl_fisc_posting( ).

    FIELD-SYMBOLS:
      <post_status>         TYPE any,
      <post_status_control> TYPE any.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      DATA(ls_selection) = VALUE /eacm/cl_fisc_posting=>ty_selection(
        company_code             = <key>-%param-CompanyCode
        fiscal_year              = <key>-%param-FiscalYear
        test_run                 = <key>-%param-TestRun
        document_date            = <key>-%param-DocumentDate
        posting_date             = <key>-%param-PostingDate
        accounting_document_type = <key>-%param-AccountingDocumentType
        assignment_rule          = <key>-%param-AssignmentRule
        assignment_reference     = <key>-%param-AssignmentReference
        defer_status_update      = abap_true ).

      IF <key>-%param-AgentFrom IS NOT INITIAL
         OR <key>-%param-AgentTo IS NOT INITIAL.
        APPEND VALUE #(
          sign   = 'I'
          option = COND #( WHEN <key>-%param-AgentTo IS INITIAL THEN 'EQ' ELSE 'BT' )
          low    = <key>-%param-AgentFrom
          high   = <key>-%param-AgentTo ) TO ls_selection-agent_range.
      ENDIF.

*      IF <key>-%param-PaymentTypeFrom IS NOT INITIAL
*         OR <key>-%param-PaymentTypeTo IS NOT INITIAL.
*        APPEND VALUE #(
*          sign   = 'I'
*          option = COND #( WHEN <key>-%param-PaymentTypeTo IS INITIAL THEN 'EQ' ELSE 'BT' )
*          low    = <key>-%param-PaymentTypeFrom
*          high   = <key>-%param-PaymentTypeTo ) TO ls_selection-payment_type_range.
*      ENDIF.
*
*      IF <key>-%param-SalesOrgFrom IS NOT INITIAL
*         OR <key>-%param-SalesOrgTo IS NOT INITIAL.
*        APPEND VALUE #(
*          sign   = 'I'
*          option = COND #( WHEN <key>-%param-SalesOrgTo IS INITIAL THEN 'EQ' ELSE 'BT' )
*          low    = <key>-%param-SalesOrgFrom
*          high   = <key>-%param-SalesOrgTo ) TO ls_selection-sales_org_range.
*      ENDIF.
*
*      IF <key>-%param-CommissionClassFrom IS NOT INITIAL
*         OR <key>-%param-CommissionClassTo IS NOT INITIAL.
*        APPEND VALUE #(
*          sign   = 'I'
*          option = COND #( WHEN <key>-%param-CommissionClassTo IS INITIAL THEN 'EQ' ELSE 'BT' )
*          low    = <key>-%param-CommissionClassFrom
*          high   = <key>-%param-CommissionClassTo ) TO ls_selection-commission_class_range.
*      ENDIF.
*
*      IF <key>-%param-BillingDocumentFrom IS NOT INITIAL
*         OR <key>-%param-BillingDocumentTo IS NOT INITIAL.
*        APPEND VALUE #(
*          sign   = 'I'
*          option = COND #( WHEN <key>-%param-BillingDocumentTo IS INITIAL THEN 'EQ' ELSE 'BT' )
*          low    = <key>-%param-BillingDocumentFrom
*          high   = <key>-%param-BillingDocumentTo ) TO ls_selection-billing_document_range.
*      ENDIF.

      DATA lt_posting_result TYPE /eacm/cl_fisc_posting=>tt_result.

      TRY.
          lt_posting_result = lo_posting->run( ls_selection ).
        CATCH cx_root INTO DATA(lx_posting).
          APPEND VALUE #(
            type         = 'E'
            message_text = lx_posting->get_text( ) ) TO lt_posting_result.
      ENDTRY.

      DATA(lv_message_type) = COND symsgty(
        WHEN line_exists( lt_posting_result[ type = 'E' ] )
          OR line_exists( lt_posting_result[ type = 'A' ] )
          OR line_exists( lt_posting_result[ type = 'X' ] ) THEN 'E'
        WHEN line_exists( lt_posting_result[ type = 'W' ] ) THEN 'W'
        ELSE 'S' ).
      DATA(lv_post_error_count) = 0.
      DATA(lv_post_warning_count) = 0.
      DATA(lv_status_save_failed) = abap_false.
      DATA(lv_status_save_message) = VALUE string( ).

      LOOP AT lt_posting_result INTO DATA(ls_posting_message).
        CASE ls_posting_message-type.
          WHEN 'E' OR 'A' OR 'X'.
            lv_post_error_count += 1.
          WHEN 'W'.
            lv_post_warning_count += 1.
        ENDCASE.

        APPEND VALUE #(
          %cid = <key>-%cid
          %msg = new_message_with_text(
            severity = SWITCH #( ls_posting_message-type
              WHEN 'E' THEN if_abap_behv_message=>severity-error
              WHEN 'A' THEN if_abap_behv_message=>severity-error
              WHEN 'X' THEN if_abap_behv_message=>severity-error
              WHEN 'W' THEN if_abap_behv_message=>severity-warning
              WHEN 'S' THEN if_abap_behv_message=>severity-success
              ELSE if_abap_behv_message=>severity-information )
            text     = ls_posting_message-message_text ) ) TO reported-/eacm/rzprfisc.
      ENDLOOP.

      IF lv_message_type <> 'E'
         AND ls_selection-test_run <> abap_true.

        DATA lt_post_update TYPE TABLE FOR UPDATE /EACM/R_ZPRFISC.
        DATA ls_post_update LIKE LINE OF lt_post_update.

        LOOP AT lt_posting_result INTO DATA(ls_posting_success) WHERE success = abap_true.
          CLEAR ls_post_update.
          DATA(lv_has_status_update) = abap_false.

          ls_post_update-Bukrs = ls_posting_success-company_code.
          ls_post_update-Vkorg = ls_posting_success-vkorg.
          ls_post_update-Gjahr = ls_posting_success-fiscal_year.
          ls_post_update-Zcdaz = ls_posting_success-agent.

          IF ls_posting_success-period_index = 0.
            ls_post_update-Ztprc = /eacm/if_fisc_types=>gc_status_historized.
            ls_post_update-%control-Ztprc = if_abap_behv=>mk-on.
            lv_has_status_update = abap_true.
          ELSE.
            DATA(lv_ztprc_field) = |Ztprc{ ls_posting_success-period_index }|.

            UNASSIGN: <post_status>, <post_status_control>.
            ASSIGN COMPONENT lv_ztprc_field OF STRUCTURE ls_post_update TO <post_status>.
            ASSIGN COMPONENT lv_ztprc_field OF STRUCTURE ls_post_update-%control TO <post_status_control>.
            IF <post_status> IS ASSIGNED AND <post_status_control> IS ASSIGNED.
              <post_status> = /eacm/if_fisc_types=>gc_status_historized.
              <post_status_control> = if_abap_behv=>mk-on.
              lv_has_status_update = abap_true.
            ENDIF.

            IF ls_posting_success-is_final_period = abap_true.
              ls_post_update-Ztprc = /eacm/if_fisc_types=>gc_status_historized.
              ls_post_update-%control-Ztprc = if_abap_behv=>mk-on.
              lv_has_status_update = abap_true.
            ENDIF.
          ENDIF.

          IF lv_has_status_update = abap_true.
            APPEND ls_post_update TO lt_post_update.
          ENDIF.
        ENDLOOP.

        IF lt_post_update IS NOT INITIAL.
          MODIFY ENTITIES OF /EACM/R_ZPRFISC IN LOCAL MODE
            ENTITY /eacm/rZprfisc
            UPDATE FROM lt_post_update
            FAILED DATA(lt_failed_post_update)
            REPORTED DATA(lt_reported_post_update).

          APPEND LINES OF lt_reported_post_update-/eacm/rzprfisc TO reported-/eacm/rzprfisc.

          IF lt_failed_post_update-/eacm/rzprfisc IS NOT INITIAL.
            lv_status_save_failed = abap_true.
            lv_status_save_message = |Errore durante aggiornamento stato contabilizzazione FISC: { lines( lt_failed_post_update-/eacm/rzprfisc ) } record.|.
          ENDIF.
        ENDIF.
      ENDIF.

      DATA(lv_message_text) = VALUE string( ).

      IF lv_status_save_failed = abap_true.
        lv_message_type = 'E'.
        lv_message_text = lv_status_save_message.
      ELSEIF lv_message_type = 'E'.
        lv_message_text = |Contabilizzazione FISC terminata con errori: { lv_post_error_count } errori. Aprire i messaggi di dettaglio.|.
      ELSEIF lv_message_type = 'W'.
        lv_message_text = |Contabilizzazione FISC terminata con avvisi: { lv_post_warning_count } avvisi. Aprire i messaggi di dettaglio.|.
      ELSE.
        READ TABLE lt_posting_result INTO DATA(ls_message_for_result)
          WITH KEY type = lv_message_type.

        IF sy-subrc = 0.
          lv_message_text = ls_message_for_result-message_text.
        ELSEIF lines( lt_posting_result ) > 0.
          lv_message_text = lt_posting_result[ 1 ]-message_text.
        ELSE.
          lv_message_text = 'Contabilizzazione FISC completata.'.
        ENDIF.
      ENDIF.

      DATA(lv_severity) = COND #(
        WHEN lv_message_type = 'E' THEN if_abap_behv_message=>severity-error
        WHEN lv_message_type = 'W' THEN if_abap_behv_message=>severity-warning
        ELSE if_abap_behv_message=>severity-success ).

      IF lv_message_type = 'E'.
        APPEND VALUE #( %cid = <key>-%cid ) TO failed-/eacm/rzprfisc.
      ENDIF.

      APPEND VALUE #(
        %cid = <key>-%cid
        %msg = new_message_with_text(
          severity = lv_severity
          text     = lv_message_text ) ) TO reported-/eacm/rzprfisc.

      APPEND VALUE #(
        %cid = <key>-%cid
        %param = VALUE #(
          Preview     = ls_selection-test_run
          MessageType = lv_message_type
          MessageText = lv_message_text ) ) TO result.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.





