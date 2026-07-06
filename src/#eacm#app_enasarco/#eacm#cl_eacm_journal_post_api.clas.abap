CLASS /eacm/cl_eacm_journal_post_api DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_gl_item,
        gl_account         TYPE c LENGTH 10,
        amount             TYPE decfloat34,
        currency_code      TYPE c LENGTH 3,
        debit_credit_code  TYPE c LENGTH 1,
        cost_center        TYPE c LENGTH 10,
        profit_center      TYPE c LENGTH 10,
        tax_code           TYPE mwskz,
        assignment_ref     TYPE c LENGTH 18,
        item_text          TYPE c LENGTH 50,
      END OF ty_gl_item,
      tt_gl_item TYPE STANDARD TABLE OF ty_gl_item WITH DEFAULT KEY,
      tt_message_detail TYPE STANDARD TABLE OF string WITH EMPTY KEY,
      BEGIN OF ty_request,
        company_code                 TYPE c LENGTH 4,
        document_date                TYPE d,
        posting_date                 TYPE d,
        accounting_document_type     TYPE c LENGTH 2,
        original_reference_document  TYPE c LENGTH 16,
        document_header_text         TYPE c LENGTH 25,
        created_by_user              TYPE syuname,
        items                        TYPE tt_gl_item,
      END OF ty_request,
      BEGIN OF ty_response,
        success              TYPE abap_bool,
        accounting_document  TYPE c LENGTH 10,
        fiscal_year          TYPE c LENGTH 4,
        message_text         TYPE string,
        message_details      TYPE tt_message_detail,
      END OF ty_response.

    METHODS post_journal_entry
      IMPORTING
        is_request        TYPE ty_request
      RETURNING
        VALUE(rs_result)  TYPE ty_response.

  PRIVATE SECTION.
    TYPES tt_log_note TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    METHODS persist_api_response_log
      IMPORTING
        is_request  TYPE ty_request
        is_response TYPE /eacm/cl_api_je_post_sync=>ty_response.

    METHODS persist_api_log_entry
      IMPORTING
        iv_step TYPE csequence
        iv_info TYPE csequence OPTIONAL
        iv_full TYPE csequence OPTIONAL.

    METHODS extract_response_notes
      IMPORTING
        is_response     TYPE /eacm/cl_api_je_post_sync=>ty_response
      RETURNING
        VALUE(rt_notes) TYPE tt_log_note.

    METHODS collect_log_notes
      IMPORTING
        is_container TYPE any
      CHANGING
        ct_notes     TYPE tt_log_note.

ENDCLASS.


CLASS /eacm/cl_eacm_journal_post_api IMPLEMENTATION.

  METHOD post_journal_entry.

    DATA ls_req TYPE /eacm/cl_api_je_post_sync=>ty_request.
    DATA lv_item_no TYPE i.

    FIELD-SYMBOLS:
      <bulk_confirmation>    TYPE any,
      <confirmation_table>   TYPE STANDARD TABLE,
      <confirmation>         TYPE any,
      <journal_confirmation> TYPE any,
      <accounting_document>  TYPE any,
      <fiscal_year>          TYPE any,
      <api_field>            TYPE any,
      <api_structure>        TYPE any,
      <api_content>          TYPE any.

    IF is_request-items IS INITIAL.
      rs_result-success = abap_false.
      rs_result-message_text = 'Nessuna riga contabile da registrare.'.
      RETURN.
    ENDIF.

    TRY.

        ls_req-journal_entry_bulk_create_requ-message_header-uuid-content =
          cl_system_uuid=>create_uuid_c32_static( ).
        GET TIME STAMP FIELD
          ls_req-journal_entry_bulk_create_requ-message_header-creation_date_time.

        APPEND INITIAL LINE TO
          ls_req-journal_entry_bulk_create_requ-journal_entry_create_request
          ASSIGNING FIELD-SYMBOL(<request>).

        <request>-message_header-uuid-content =
          cl_system_uuid=>create_uuid_c32_static( ).
        GET TIME STAMP FIELD <request>-message_header-creation_date_time.

        <request>-journal_entry-original_reference_document_ty = 'BKPFF'.
        <request>-journal_entry-business_transaction_type        = 'RFBU'.
        <request>-journal_entry-accounting_document_type         = is_request-accounting_document_type.
        <request>-journal_entry-company_code                     = is_request-company_code.
        <request>-journal_entry-document_date                    = is_request-document_date.
        <request>-journal_entry-posting_date                     = is_request-posting_date.
        <request>-journal_entry-created_by_user                  = is_request-created_by_user.
        <request>-journal_entry-document_header_text             = is_request-document_header_text.
        <request>-journal_entry-original_reference_document      = is_request-original_reference_document.

        LOOP AT is_request-items INTO DATA(ls_item).

          ADD 1 TO lv_item_no.

          APPEND INITIAL LINE TO <request>-journal_entry-item
            ASSIGNING FIELD-SYMBOL(<api_item>).

          UNASSIGN <api_field>.
          ASSIGN COMPONENT 'REFERENCEDOCUMENTITEM'
            OF STRUCTURE <api_item> TO <api_field>.
          IF <api_field> IS NOT ASSIGNED.
            ASSIGN COMPONENT 'REFERENCE_DOCUMENT_ITEM'
              OF STRUCTURE <api_item> TO <api_field>.
          ENDIF.
          IF <api_field> IS ASSIGNED.
            <api_field> = lv_item_no.
          ENDIF.

          UNASSIGN <api_structure>.
          ASSIGN COMPONENT 'GLACCOUNT'
            OF STRUCTURE <api_item> TO <api_structure>.
          IF <api_structure> IS ASSIGNED.
            UNASSIGN <api_field>.
            ASSIGN COMPONENT 'CONTENT'
              OF STRUCTURE <api_structure> TO <api_field>.
            IF <api_field> IS ASSIGNED.
              <api_field> = ls_item-gl_account.
            ENDIF.
          ENDIF.

          UNASSIGN <api_field>.
          ASSIGN COMPONENT 'DOCUMENTITEMTEXT'
            OF STRUCTURE <api_item> TO <api_field>.
          IF <api_field> IS NOT ASSIGNED.
            ASSIGN COMPONENT 'DOCUMENT_ITEM_TEXT'
              OF STRUCTURE <api_item> TO <api_field>.
          ENDIF.
          IF <api_field> IS ASSIGNED.
            <api_field> = ls_item-item_text.
          ENDIF.

          UNASSIGN <api_field>.
          ASSIGN COMPONENT 'ASSIGNMENTREFERENCE'
            OF STRUCTURE <api_item> TO <api_field>.
          IF <api_field> IS NOT ASSIGNED.
            ASSIGN COMPONENT 'ASSIGNMENT_REFERENCE'
              OF STRUCTURE <api_item> TO <api_field>.
          ENDIF.
          IF <api_field> IS ASSIGNED.
            <api_field> = ls_item-assignment_ref.
          ENDIF.

          UNASSIGN <api_field>.
          ASSIGN COMPONENT 'DEBITCREDITCODE'
            OF STRUCTURE <api_item> TO <api_field>.
          IF <api_field> IS NOT ASSIGNED.
            ASSIGN COMPONENT 'DEBIT_CREDIT_CODE'
              OF STRUCTURE <api_item> TO <api_field>.
          ENDIF.
          IF <api_field> IS ASSIGNED.
            <api_field> = ls_item-debit_credit_code.
          ENDIF.

          UNASSIGN <api_structure>.
          ASSIGN COMPONENT 'AMOUNTINTRANSACTIONCURRENCY'
            OF STRUCTURE <api_item> TO <api_structure>.
          IF <api_structure> IS NOT ASSIGNED.
            ASSIGN COMPONENT 'AMOUNT_IN_TRANSACTION_CURRENCY'
              OF STRUCTURE <api_item> TO <api_structure>.
          ENDIF.

          IF <api_structure> IS ASSIGNED.
            UNASSIGN <api_field>.
            ASSIGN COMPONENT 'CURRENCYCODE'
              OF STRUCTURE <api_structure> TO <api_field>.
            IF <api_field> IS NOT ASSIGNED.
              ASSIGN COMPONENT 'CURRENCY_CODE'
                OF STRUCTURE <api_structure> TO <api_field>.
            ENDIF.
            IF <api_field> IS ASSIGNED.
              <api_field> = ls_item-currency_code.
            ENDIF.

            UNASSIGN <api_field>.
            ASSIGN COMPONENT 'CONTENT'
              OF STRUCTURE <api_structure> TO <api_field>.
            IF <api_field> IS ASSIGNED.
              IF ls_item-debit_credit_code = 'H'.
                <api_field> = ls_item-amount * -1.
              ELSE.
                <api_field> = ls_item-amount.
              ENDIF.
            ENDIF.
          ENDIF.

          IF ls_item-cost_center IS NOT INITIAL OR
             ls_item-profit_center IS NOT INITIAL.
            UNASSIGN <api_structure>.
            ASSIGN COMPONENT 'ACCOUNTASSIGNMENT'
              OF STRUCTURE <api_item> TO <api_structure>.
            IF <api_structure> IS NOT ASSIGNED.
              ASSIGN COMPONENT 'ACCOUNT_ASSIGNMENT'
                OF STRUCTURE <api_item> TO <api_structure>.
            ENDIF.

            IF <api_structure> IS ASSIGNED AND ls_item-cost_center IS NOT INITIAL.
              UNASSIGN <api_field>.
              ASSIGN COMPONENT 'COSTCENTER'
                OF STRUCTURE <api_structure> TO <api_field>.
              IF <api_field> IS NOT ASSIGNED.
                ASSIGN COMPONENT 'COST_CENTER'
                  OF STRUCTURE <api_structure> TO <api_field>.
              ENDIF.
              IF <api_field> IS ASSIGNED.
                <api_field> = ls_item-cost_center.
              ENDIF.
            ENDIF.

            IF <api_structure> IS ASSIGNED AND ls_item-profit_center IS NOT INITIAL.
              UNASSIGN <api_field>.
              ASSIGN COMPONENT 'PROFITCENTER'
                OF STRUCTURE <api_structure> TO <api_field>.
              IF <api_field> IS NOT ASSIGNED.
                ASSIGN COMPONENT 'PROFIT_CENTER'
                  OF STRUCTURE <api_structure> TO <api_field>.
              ENDIF.
              IF <api_field> IS ASSIGNED.
                <api_field> = ls_item-profit_center.
              ENDIF.
            ENDIF.
          ENDIF.

          IF ls_item-tax_code IS NOT INITIAL.
            UNASSIGN <api_structure>.
            ASSIGN COMPONENT 'TAX'
              OF STRUCTURE <api_item> TO <api_structure>.
            IF <api_structure> IS ASSIGNED.
              UNASSIGN <api_field>.
              ASSIGN COMPONENT 'TAXCODE'
                OF STRUCTURE <api_structure> TO <api_field>.
              IF <api_field> IS NOT ASSIGNED.
                ASSIGN COMPONENT 'TAX_CODE'
                  OF STRUCTURE <api_structure> TO <api_field>.
              ENDIF.
              IF <api_field> IS ASSIGNED.
                UNASSIGN <api_content>.
                ASSIGN COMPONENT 'CONTENT' OF STRUCTURE <api_field> TO <api_content>.
                IF <api_content> IS ASSIGNED.
                  <api_content> = ls_item-tax_code.
                ELSE.
                  <api_field> = ls_item-tax_code.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.

        ENDLOOP.

        DATA(lo_api) = NEW /eacm/cl_api_je_post_sync( ).
        DATA(ls_response) = lo_api->post_sync( ls_req ).

        ASSIGN COMPONENT 'JOURNAL_ENTRY_BULK_CREATE_CONF'
          OF STRUCTURE ls_response TO <bulk_confirmation>.
        IF <bulk_confirmation> IS NOT ASSIGNED.
          ASSIGN COMPONENT 'JOURNAL_ENTRY_BULK_CREATE_CONFIRMATION'
            OF STRUCTURE ls_response TO <bulk_confirmation>.
        ENDIF.
        IF <bulk_confirmation> IS NOT ASSIGNED.
          ASSIGN COMPONENT 'JOURNAL_ENTRY_BULK_CREATE_CONFIRMAT'
            OF STRUCTURE ls_response TO <bulk_confirmation>.
        ENDIF.
        IF <bulk_confirmation> IS NOT ASSIGNED.
          ASSIGN COMPONENT 'JOURNALENTRYBULKCREATECONFIRMATION'
            OF STRUCTURE ls_response TO <bulk_confirmation>.
        ENDIF.

        IF <bulk_confirmation> IS ASSIGNED.
          ASSIGN COMPONENT 'JOURNAL_ENTRY_CREATE_CONFIRMATION'
            OF STRUCTURE <bulk_confirmation> TO <confirmation_table>.
          IF <confirmation_table> IS NOT ASSIGNED.
            ASSIGN COMPONENT 'JOURNAL_ENTRY_CREATE_CONFIRMAT'
              OF STRUCTURE <bulk_confirmation> TO <confirmation_table>.
          ENDIF.
          IF <confirmation_table> IS NOT ASSIGNED.
            ASSIGN COMPONENT 'JOURNALENTRYCREATECONFIRMATION'
              OF STRUCTURE <bulk_confirmation> TO <confirmation_table>.
          ENDIF.
        ENDIF.

        IF <confirmation_table> IS NOT ASSIGNED.
          ASSIGN COMPONENT 'JOURNAL_ENTRY_CREATE_CONFIRMATION'
            OF STRUCTURE ls_response TO <confirmation_table>.
        ENDIF.
        IF <confirmation_table> IS NOT ASSIGNED.
          ASSIGN COMPONENT 'JOURNAL_ENTRY_CREATE_CONFIRMAT'
            OF STRUCTURE ls_response TO <confirmation_table>.
        ENDIF.
        IF <confirmation_table> IS NOT ASSIGNED.
          ASSIGN COMPONENT 'JOURNALENTRYCREATECONFIRMATION'
            OF STRUCTURE ls_response TO <confirmation_table>.
        ENDIF.

        IF <confirmation_table> IS ASSIGNED.
          READ TABLE <confirmation_table>
            ASSIGNING <confirmation>
            INDEX 1.
        ENDIF.

        IF <confirmation> IS ASSIGNED.
          ASSIGN COMPONENT 'JOURNAL_ENTRY_CREATE_CONFIRMATION'
            OF STRUCTURE <confirmation> TO <journal_confirmation>.
          IF <journal_confirmation> IS NOT ASSIGNED.
            ASSIGN COMPONENT 'JOURNAL_ENTRY_CREATE_CONFIRMAT'
              OF STRUCTURE <confirmation> TO <journal_confirmation>.
          ENDIF.
          IF <journal_confirmation> IS NOT ASSIGNED.
            ASSIGN COMPONENT 'JOURNALENTRYCREATECONFIRMATION'
              OF STRUCTURE <confirmation> TO <journal_confirmation>.
          ENDIF.

          IF <journal_confirmation> IS ASSIGNED.
            ASSIGN COMPONENT 'ACCOUNTING_DOCUMENT'
              OF STRUCTURE <journal_confirmation> TO <accounting_document>.
            IF <accounting_document> IS NOT ASSIGNED.
              ASSIGN COMPONENT 'ACCOUNTINGDOCUMENT'
                OF STRUCTURE <journal_confirmation> TO <accounting_document>.
            ENDIF.
            ASSIGN COMPONENT 'FISCAL_YEAR'
              OF STRUCTURE <journal_confirmation> TO <fiscal_year>.
            IF <fiscal_year> IS NOT ASSIGNED.
              ASSIGN COMPONENT 'FISCALYEAR'
                OF STRUCTURE <journal_confirmation> TO <fiscal_year>.
            ENDIF.
          ENDIF.

          IF <accounting_document> IS NOT ASSIGNED.
            ASSIGN COMPONENT 'ACCOUNTING_DOCUMENT'
              OF STRUCTURE <confirmation> TO <accounting_document>.
          ENDIF.
          IF <accounting_document> IS NOT ASSIGNED.
            ASSIGN COMPONENT 'ACCOUNTINGDOCUMENT'
              OF STRUCTURE <confirmation> TO <accounting_document>.
          ENDIF.
          IF <fiscal_year> IS NOT ASSIGNED.
            ASSIGN COMPONENT 'FISCAL_YEAR'
              OF STRUCTURE <confirmation> TO <fiscal_year>.
          ENDIF.
          IF <fiscal_year> IS NOT ASSIGNED.
            ASSIGN COMPONENT 'FISCALYEAR'
              OF STRUCTURE <confirmation> TO <fiscal_year>.
          ENDIF.
        ENDIF.

        IF <accounting_document> IS ASSIGNED
           AND <accounting_document> IS NOT INITIAL
           AND <accounting_document> <> '0000000000'.
          rs_result-success = abap_true.
          rs_result-accounting_document = <accounting_document>.
          IF <fiscal_year> IS ASSIGNED.
            rs_result-fiscal_year = <fiscal_year>.
          ENDIF.
          rs_result-message_text =
            |Documento contabile creato: { rs_result-accounting_document }|.
        ELSE.
          DATA(lt_response_notes) = extract_response_notes( ls_response ).

          persist_api_response_log(
            is_request  = is_request
            is_response = ls_response ).

          rs_result-success = abap_false.
          rs_result-message_details = lt_response_notes.
          rs_result-message_text = COND #(
            WHEN lt_response_notes IS NOT INITIAL
            THEN 'Documento contabile non restituito dalla API. Dettagli nei messaggi successivi.'
            ELSE 'Documento contabile non restituito dalla API. Verificare log SOAP/AIF.' ).
        ENDIF.

      CATCH /eacm/cx_api_error INTO DATA(lx_api).
        DATA(lv_api_error_text) = COND string(
          WHEN lx_api->mv_context IS NOT INITIAL THEN lx_api->mv_context
          ELSE lx_api->get_text( ) ).

        IF lx_api->previous IS BOUND.
          lv_api_error_text =
            |{ lv_api_error_text } Underlying: { lx_api->previous->get_text( ) }|.
        ENDIF.

        persist_api_log_entry(
          iv_step = 'POST_SYNC_EXCEPTION'
          iv_info = 'SOAP/API exception'
          iv_full = lv_api_error_text ).

        rs_result-success = abap_false.
        rs_result-message_text = lv_api_error_text.

      CATCH cx_uuid_error INTO DATA(lx_uuid).
        rs_result-success = abap_false.
        rs_result-message_text = lx_uuid->get_text( ).

    ENDTRY.

  ENDMETHOD.


  METHOD extract_response_notes.
    DATA lt_notes TYPE tt_log_note.
    DATA lv_index TYPE i.

    CONSTANTS lc_detail_len TYPE i VALUE 90.

    FIELD-SYMBOLS:
      <bulk_confirmation>    TYPE any,
      <confirmation_table>   TYPE STANDARD TABLE,
      <confirmation>         TYPE any,
      <journal_confirmation> TYPE any.

    ASSIGN COMPONENT 'JOURNAL_ENTRY_BULK_CREATE_CONF'
      OF STRUCTURE is_response TO <bulk_confirmation>.
    IF <bulk_confirmation> IS NOT ASSIGNED.
      ASSIGN COMPONENT 'JOURNAL_ENTRY_BULK_CREATE_CONFIRMATION'
        OF STRUCTURE is_response TO <bulk_confirmation>.
    ENDIF.
    IF <bulk_confirmation> IS NOT ASSIGNED.
      ASSIGN COMPONENT 'JOURNAL_ENTRY_BULK_CREATE_CONFIRMAT'
        OF STRUCTURE is_response TO <bulk_confirmation>.
    ENDIF.
    IF <bulk_confirmation> IS NOT ASSIGNED.
      ASSIGN COMPONENT 'JOURNALENTRYBULKCREATECONFIRMATION'
        OF STRUCTURE is_response TO <bulk_confirmation>.
    ENDIF.

    IF <bulk_confirmation> IS ASSIGNED.
      collect_log_notes(
        EXPORTING
          is_container = <bulk_confirmation>
        CHANGING
          ct_notes     = lt_notes ).

      ASSIGN COMPONENT 'JOURNAL_ENTRY_CREATE_CONFIRMATION'
        OF STRUCTURE <bulk_confirmation> TO <confirmation_table>.
      IF <confirmation_table> IS NOT ASSIGNED.
        ASSIGN COMPONENT 'JOURNAL_ENTRY_CREATE_CONFIRMAT'
          OF STRUCTURE <bulk_confirmation> TO <confirmation_table>.
      ENDIF.
      IF <confirmation_table> IS NOT ASSIGNED.
        ASSIGN COMPONENT 'JOURNALENTRYCREATECONFIRMATION'
          OF STRUCTURE <bulk_confirmation> TO <confirmation_table>.
      ENDIF.
    ENDIF.

    IF <confirmation_table> IS NOT ASSIGNED.
      ASSIGN COMPONENT 'JOURNAL_ENTRY_CREATE_CONFIRMATION'
        OF STRUCTURE is_response TO <confirmation_table>.
    ENDIF.
    IF <confirmation_table> IS NOT ASSIGNED.
      ASSIGN COMPONENT 'JOURNAL_ENTRY_CREATE_CONFIRMAT'
        OF STRUCTURE is_response TO <confirmation_table>.
    ENDIF.
    IF <confirmation_table> IS NOT ASSIGNED.
      ASSIGN COMPONENT 'JOURNALENTRYCREATECONFIRMATION'
        OF STRUCTURE is_response TO <confirmation_table>.
    ENDIF.

    IF <confirmation_table> IS ASSIGNED.
      LOOP AT <confirmation_table> ASSIGNING <confirmation>.
        collect_log_notes(
          EXPORTING
            is_container = <confirmation>
          CHANGING
            ct_notes     = lt_notes ).

        UNASSIGN <journal_confirmation>.
        ASSIGN COMPONENT 'JOURNAL_ENTRY_CREATE_CONFIRMATION'
          OF STRUCTURE <confirmation> TO <journal_confirmation>.
        IF <journal_confirmation> IS NOT ASSIGNED.
          ASSIGN COMPONENT 'JOURNAL_ENTRY_CREATE_CONFIRMAT'
            OF STRUCTURE <confirmation> TO <journal_confirmation>.
        ENDIF.
        IF <journal_confirmation> IS NOT ASSIGNED.
          ASSIGN COMPONENT 'JOURNALENTRYCREATECONFIRMATION'
            OF STRUCTURE <confirmation> TO <journal_confirmation>.
        ENDIF.

        IF <journal_confirmation> IS ASSIGNED.
          collect_log_notes(
            EXPORTING
              is_container = <journal_confirmation>
            CHANGING
              ct_notes     = lt_notes ).
        ENDIF.
      ENDLOOP.
    ENDIF.

    LOOP AT lt_notes INTO DATA(lv_note).
      lv_index += 1.
      DATA(lv_remaining_note) = lv_note.
      DATA(lv_first_part) = abap_true.

      WHILE lv_remaining_note IS NOT INITIAL.
        DATA(lv_prefix) = COND string(
          WHEN lv_first_part = abap_true
          THEN |{ lv_index }. |
          ELSE |{ lv_index }. continua: | ).

        DATA(lv_take) = lc_detail_len - strlen( lv_prefix ).

        IF strlen( lv_remaining_note ) < lv_take.
          lv_take = strlen( lv_remaining_note ).
        ENDIF.

        DATA(lv_part) = substring(
          val = lv_remaining_note
          off = 0
          len = lv_take ).

        APPEND |{ lv_prefix }{ lv_part }| TO rt_notes.

        IF strlen( lv_remaining_note ) > lv_take.
          lv_remaining_note = substring(
            val = lv_remaining_note
            off = lv_take ).
        ELSE.
          CLEAR lv_remaining_note.
        ENDIF.

        lv_first_part = abap_false.
      ENDWHILE.
    ENDLOOP.
  ENDMETHOD.


  METHOD collect_log_notes.
    FIELD-SYMBOLS:
      <log>        TYPE any,
      <item_table> TYPE STANDARD TABLE,
      <item>       TYPE any,
      <note>       TYPE any.

    ASSIGN COMPONENT 'LOG' OF STRUCTURE is_container TO <log>.
    IF <log> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    ASSIGN COMPONENT 'ITEM' OF STRUCTURE <log> TO <item_table>.
    IF <item_table> IS NOT ASSIGNED.
      ASSIGN COMPONENT 'ITEMS' OF STRUCTURE <log> TO <item_table>.
    ENDIF.
    IF <item_table> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    LOOP AT <item_table> ASSIGNING <item>.
      UNASSIGN <note>.
      ASSIGN COMPONENT 'NOTE' OF STRUCTURE <item> TO <note>.
      IF <note> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.
      IF <note> IS INITIAL.
        CONTINUE.
      ENDIF.

      DATA(lv_note) = CONV string( <note> ).
      CONDENSE lv_note.

      IF lv_note IS INITIAL.
        CONTINUE.
      ENDIF.

      IF NOT line_exists( ct_notes[ table_line = lv_note ] ).
        APPEND lv_note TO ct_notes.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD persist_api_response_log.
    DATA lv_full_text TYPE string.

    TRY.
        lv_full_text = xco_cp_json=>data->from_abap( is_response )->to_string( ).
      CATCH cx_root INTO DATA(lx_json).
        lv_full_text = |Impossibile serializzare la response API: { lx_json->get_text( ) }|.
    ENDTRY.

    persist_api_log_entry(
      iv_step = 'POST_SYNC_RESPONSE'
      iv_info = |No AccountingDocument for { is_request-company_code }/{ is_request-original_reference_document }|
      iv_full = lv_full_text ).
  ENDMETHOD.


  METHOD persist_api_log_entry.
    DATA(lo_log) = NEW /eacm/cl_api_log( iv_api_name = 'JE_POST_SYNC' ).
    lo_log->write(
      iv_step = iv_step
      iv_info = iv_info
      iv_full = iv_full ).
  ENDMETHOD.

ENDCLASS.


