CLASS /eacm/cl_fisc_posting DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      tt_agent_range TYPE RANGE OF /eacm/zpraa-zcdaz,
      tt_payment_type_range TYPE RANGE OF /eacm/zpraa-ztpag,
      tt_sales_org_range TYPE RANGE OF /eacm/prdo-vkorg,
      tt_commission_class_range TYPE RANGE OF /eacm/prdo-zclpr,
      tt_billing_document_range TYPE RANGE OF /eacm/prdo-belnr,

      BEGIN OF ty_selection,
        company_code             TYPE bukrs,
        fiscal_year              TYPE gjahr,
        test_run                 TYPE abap_bool,
        document_date            TYPE bldat,
        posting_date             TYPE budat,
        accounting_document_type TYPE blart,
        assignment_rule          TYPE /eacm/zpr43-zfratt,
        assignment_reference     TYPE dzuonr,
        defer_status_update      TYPE abap_bool,
        agent_range              TYPE tt_agent_range,
        payment_type_range       TYPE tt_payment_type_range,
        sales_org_range          TYPE tt_sales_org_range,
        commission_class_range   TYPE tt_commission_class_range,
        billing_document_range   TYPE tt_billing_document_range,
      END OF ty_selection,

      BEGIN OF ty_result,
        type                TYPE symsgty,
        message_text        TYPE string,
        accounting_document TYPE belnr_d,
        fiscal_year         TYPE gjahr,
        company_code        TYPE bukrs,
        vkorg               TYPE vkorg,
        agent               TYPE /eacm/zcdaz,
        period_index        TYPE i,
        is_final_period     TYPE abap_bool,
        success             TYPE abap_bool,
      END OF ty_result,
      tt_result TYPE STANDARD TABLE OF ty_result WITH EMPTY KEY.

    METHODS run
      IMPORTING is_selection TYPE ty_selection
      RETURNING VALUE(rt_result) TYPE tt_result.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_config,
        company_code TYPE bukrs,
        currency     TYPE waers,
        periodicity  TYPE /eacm/zpr01-zgfisc,
        kokrs        TYPE kokrs,
      END OF ty_config,

      BEGIN OF ty_agent,
        agent        TYPE /eacm/zpraa-zcdaz,
        supplier     TYPE /eacm/zpraa-lifnr,
        payment_type TYPE /eacm/zpraa-ztpag,
      END OF ty_agent,

      BEGIN OF ty_accounts,
        payable_account TYPE hkont,
        cost_account    TYPE hkont,
        transaction_type TYPE rmvct,
      END OF ty_accounts,

      BEGIN OF ty_assignment,
        cost_center   TYPE kostl,
        order_number  TYPE aufnr,
        profit_center TYPE prctr,
      END OF ty_assignment,

      BEGIN OF ty_fisc_to_post,
        fisc              TYPE /eacm/zprfisc,
        agent             TYPE ty_agent,
        accounts          TYPE ty_accounts,
        assignment        TYPE ty_assignment,
        amount            TYPE /eacm/zfisc,
        period_index      TYPE i,
        is_final_period   TYPE abap_bool,
        assignment_number TYPE dzuonr,
      END OF ty_fisc_to_post,
      tt_fisc TYPE STANDARD TABLE OF /eacm/zprfisc WITH EMPTY KEY,
      tt_fisc_to_post TYPE STANDARD TABLE OF ty_fisc_to_post WITH EMPTY KEY.

    METHODS validate
      IMPORTING is_selection TYPE ty_selection
      CHANGING  ct_result    TYPE tt_result
      RETURNING VALUE(rv_valid) TYPE abap_bool.

    METHODS load_config
      IMPORTING is_selection TYPE ty_selection
      CHANGING  ct_result    TYPE tt_result
      RETURNING VALUE(rs_config) TYPE ty_config.

    METHODS load_fisc_rows
      IMPORTING is_selection TYPE ty_selection
      RETURNING VALUE(rt_fisc) TYPE tt_fisc.

    METHODS get_agent
      IMPORTING
        iv_agent     TYPE /eacm/zcdaz
        is_selection TYPE ty_selection
      RETURNING VALUE(rs_agent) TYPE ty_agent.

    METHODS determine_open_amount
      IMPORTING
        is_fisc   TYPE /eacm/zprfisc
        is_config TYPE ty_config
      EXPORTING
        ev_amount          TYPE /eacm/zfisc
        ev_period_index    TYPE i
        ev_is_final_period TYPE abap_bool.

    METHODS determine_accounts
      IMPORTING
        is_fisc            TYPE /eacm/zprfisc
        is_agent           TYPE ty_agent
        is_config          TYPE ty_config
        iv_is_final_period TYPE abap_bool
      CHANGING
        ct_result          TYPE tt_result
      RETURNING VALUE(rs_accounts) TYPE ty_accounts.

    METHODS determine_assignment
      IMPORTING
        is_fisc   TYPE /eacm/zprfisc
        is_config TYPE ty_config
      RETURNING VALUE(rs_assignment) TYPE ty_assignment.

    METHODS determine_assignment_number
      IMPORTING
        is_selection TYPE ty_selection
        is_fisc      TYPE /eacm/zprfisc
      RETURNING VALUE(rv_zuonr) TYPE dzuonr.

    METHODS collect_to_post
      IMPORTING
        is_selection TYPE ty_selection
        is_config    TYPE ty_config
      CHANGING
        ct_result    TYPE tt_result
      RETURNING VALUE(rt_to_post) TYPE tt_fisc_to_post.

    METHODS post_journal_entry
      IMPORTING
        is_selection TYPE ty_selection
        is_config    TYPE ty_config
        is_to_post   TYPE ty_fisc_to_post
      CHANGING
        ct_result    TYPE tt_result
      RETURNING VALUE(rv_success) TYPE abap_bool.

    METHODS mark_as_posted
      IMPORTING is_to_post TYPE ty_fisc_to_post.

    METHODS append_message
      IMPORTING
        iv_type TYPE symsgty
        iv_text TYPE string
        iv_agent TYPE /eacm/zcdaz OPTIONAL
      CHANGING
        ct_result TYPE tt_result.

ENDCLASS.

CLASS /eacm/cl_fisc_posting IMPLEMENTATION.

  METHOD run.
    IF validate(
         EXPORTING is_selection = is_selection
         CHANGING  ct_result    = rt_result ) = abap_false.
      RETURN.
    ENDIF.

    DATA(ls_config) = load_config(
      EXPORTING is_selection = is_selection
      CHANGING  ct_result    = rt_result ).
    IF ls_config-company_code IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lt_to_post) = collect_to_post(
      EXPORTING
        is_selection = is_selection
        is_config    = ls_config
      CHANGING
        ct_result    = rt_result ).

    IF lt_to_post IS INITIAL
       AND NOT line_exists( rt_result[ type = 'E' ] ).
      append_message(
        EXPORTING
          iv_type = 'W'
          iv_text = 'Nessun record FISC calcolato da contabilizzare.'
        CHANGING
          ct_result = rt_result ).
      RETURN.
    ENDIF.

    LOOP AT lt_to_post INTO DATA(ls_to_post).
      IF is_selection-test_run = abap_true.
        append_message(
          EXPORTING
            iv_type = 'S'
            iv_text = |Simulazione FISC: agente { ls_to_post-fisc-zcdaz }, importo { ls_to_post-amount } { ls_to_post-fisc-waerk }.|
            iv_agent = ls_to_post-fisc-zcdaz
          CHANGING
            ct_result = rt_result ).
        CONTINUE.
      ENDIF.

      IF post_journal_entry(
           EXPORTING
             is_selection = is_selection
             is_config    = ls_config
             is_to_post   = ls_to_post
           CHANGING
             ct_result    = rt_result ) = abap_true.
        IF is_selection-defer_status_update = abap_false.
          mark_as_posted( ls_to_post ).
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate.
    rv_valid = abap_true.

    IF is_selection-company_code IS INITIAL.
      rv_valid = abap_false.
      append_message(
        EXPORTING iv_type = 'E'
                  iv_text = 'Societa obbligatoria.'
        CHANGING  ct_result = ct_result ).
    ENDIF.

    IF is_selection-fiscal_year IS INITIAL.
      rv_valid = abap_false.
      append_message(
        EXPORTING iv_type = 'E'
                  iv_text = 'Esercizio obbligatorio.'
        CHANGING  ct_result = ct_result ).
    ENDIF.

    IF is_selection-assignment_rule IS INITIAL
       AND is_selection-assignment_reference IS INITIAL.
      rv_valid = abap_false.
      append_message(
        EXPORTING
          iv_type = 'E'
          iv_text = 'Indicare una regola di attribuzione o un riferimento attribuzione.'
        CHANGING
          ct_result = ct_result ).
    ENDIF.
  ENDMETHOD.

  METHOD load_config.
    DATA lv_space TYPE c LENGTH 1.

    rs_config-company_code = is_selection-company_code.

    SELECT SINGLE zgfisc
      FROM /eacm/zpr01
      WHERE bukrs = @is_selection-company_code
      INTO @rs_config-periodicity.

    IF sy-subrc <> 0 OR rs_config-periodicity IS INITIAL.
      append_message(
        EXPORTING
          iv_type = 'E'
          iv_text = |Configurazione FISC non trovata in /EACM/ZPR01 per societa { is_selection-company_code }.|
        CHANGING
          ct_result = ct_result ).
      CLEAR rs_config.
      RETURN.
    ENDIF.

*    SELECT SINGLE waers
*      FROM /eacm/t001
*      WHERE bukrs = @is_selection-company_code
*      INTO @rs_config-currency.

    IF rs_config-currency IS INITIAL.
      rs_config-currency = 'EUR'.
    ENDIF.

*    rs_config-kokrs = 'A000'.

    SELECT SINGLE waers, kokrs
      FROM /eacm/t001
      WHERE bukrs = @is_selection-company_code
      INTO ( @rs_config-currency, @rs_config-kokrs ).

*    SELECT SINGLE kokrs
*      FROM tka02
*      WHERE bukrs = @is_selection-company_code
*        AND gsber = @lv_space
*      INTO @rs_config-kokrs.
  ENDMETHOD.

  METHOD load_fisc_rows.
    DATA lv_has_agent_range TYPE abap_bool.
    DATA lv_has_sales_org_range TYPE abap_bool.

    lv_has_agent_range = xsdbool( is_selection-agent_range IS NOT INITIAL ).
    lv_has_sales_org_range = xsdbool( is_selection-sales_org_range IS NOT INITIAL ).

    SELECT *  "#EC CI_ALL_FIELDS_NEEDED
      FROM /eacm/zprfisc
      WHERE bukrs = @is_selection-company_code
        AND gjahr = @is_selection-fiscal_year
        AND ( @lv_has_agent_range = @abap_false OR zcdaz IN @is_selection-agent_range )
        AND ( @lv_has_sales_org_range = @abap_false OR vkorg IN @is_selection-sales_org_range )
      INTO TABLE @rt_fisc.
  ENDMETHOD.

  METHOD get_agent.
    DATA lv_has_payment_range TYPE abap_bool.
    DATA lt_agent TYPE STANDARD TABLE OF ty_agent WITH EMPTY KEY.

    lv_has_payment_range = xsdbool( is_selection-payment_type_range IS NOT INITIAL ).

    SELECT zcdaz AS agent,
           lifnr AS supplier,
           ztpag AS payment_type
      FROM /eacm/zpraa
      WHERE zcdaz = @iv_agent
        AND zstre <> 'A'
        AND ( @lv_has_payment_range = @abap_false OR ztpag IN @is_selection-payment_type_range )
      ORDER BY erdat DESCENDING
      INTO TABLE @lt_agent.

    READ TABLE lt_agent INTO rs_agent INDEX 1.
  ENDMETHOD.

  METHOD determine_open_amount.
    CLEAR: ev_amount, ev_period_index, ev_is_final_period.

    FIELD-SYMBOLS:
      <status> TYPE any,
      <amount> TYPE any.

    DO 12 TIMES.
      DATA(lv_idx) = sy-index.
      DATA(lv_idx_text) = CONV string( lv_idx ).

      UNASSIGN: <status>, <amount>.
      ASSIGN COMPONENT |ZTPRC_{ lv_idx_text }| OF STRUCTURE is_fisc TO <status>.
      ASSIGN COMPONENT |ZFISC_{ lv_idx_text }| OF STRUCTURE is_fisc TO <amount>.

      IF <status> IS ASSIGNED
         AND <amount> IS ASSIGNED
         AND <status> = /eacm/if_fisc_types=>gc_status_calculated.
        ev_period_index = lv_idx.
        ev_amount = <amount>.
        ev_is_final_period = xsdbool(
          ( is_config-periodicity = /eacm/if_fisc_types=>gc_period_quarterly AND lv_idx = 4 )
          OR ( is_config-periodicity = /eacm/if_fisc_types=>gc_period_monthly AND lv_idx = 12 ) ).
        RETURN.
      ENDIF.
    ENDDO.

    IF is_config-periodicity = /eacm/if_fisc_types=>gc_period_yearly
       AND is_fisc-ztprc = /eacm/if_fisc_types=>gc_status_calculated.
      ev_period_index = 0.
      ev_amount = is_fisc-zfisc.
      ev_is_final_period = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD determine_accounts.
    DATA lv_space TYPE c LENGTH 1.

    SELECT SINGLE *
      FROM /eacm/zpr31
      WHERE bukrs = @is_fisc-bukrs
        AND ztpag = @is_agent-payment_type
      INTO @DATA(ls_zpr31).

    IF sy-subrc <> 0.
      SELECT SINGLE *
        FROM /eacm/zpr31
        WHERE bukrs = @is_fisc-bukrs
          AND ztpag = @lv_space
        INTO @ls_zpr31.
    ENDIF.

    SELECT SINGLE *
      FROM /eacm/zpr42
      WHERE bukrs = @is_fisc-bukrs
        AND ztpag = @is_agent-payment_type
      INTO @DATA(ls_zpr42).

    IF sy-subrc <> 0.
      SELECT SINGLE *
        FROM /eacm/zpr42
        WHERE bukrs = @is_fisc-bukrs
          AND ztpag = @lv_space
        INTO @ls_zpr42.
    ENDIF.

    CASE ls_zpr31-ztpca.
      WHEN '1'.
        rs_accounts-payable_account = ls_zpr31-zcdef.
        rs_accounts-cost_account = ls_zpr31-zcfir.
      WHEN '3'.
        rs_accounts-payable_account = ls_zpr31-zcdef_a.
        rs_accounts-cost_account = ls_zpr31-zcfir_a.
      WHEN OTHERS.
        CASE ls_zpr42-ztpca.
          WHEN '2'.
            rs_accounts-payable_account = ls_zpr42-zcdef_tri.
            rs_accounts-cost_account = ls_zpr42-zcfir_tri.
            rs_accounts-transaction_type = ls_zpr42-zrmvct.
          WHEN '4'.
            IF iv_is_final_period = abap_true.
              rs_accounts-payable_account = ls_zpr31-zcdef_a.
              rs_accounts-cost_account = ls_zpr31-zcfir_a.
            ELSE.
              rs_accounts-payable_account = ls_zpr42-zcdef_tri_a.
              rs_accounts-cost_account = ls_zpr42-zcfir_tri_a.
            ENDIF.
          WHEN '5'.
            IF iv_is_final_period = abap_true.
              rs_accounts-payable_account = ls_zpr31-zcdef.
              rs_accounts-cost_account = ls_zpr31-zcfir.
            ELSE.
              rs_accounts-payable_account = ls_zpr42-zcdef_tri_g.
              rs_accounts-cost_account = ls_zpr42-zcfir_tri_g.
            ENDIF.
        ENDCASE.
    ENDCASE.

    IF rs_accounts-payable_account IS INITIAL
       OR rs_accounts-cost_account IS INITIAL.
      append_message(
        EXPORTING
          iv_type = 'E'
          iv_text = |Conti FISC non configurati in /EACM/ZPR31 o /EACM/ZPR42 per agente { is_fisc-zcdaz }.|
          iv_agent = is_fisc-zcdaz
        CHANGING
          ct_result = ct_result ).
    ENDIF.
  ENDMETHOD.

  METHOD determine_assignment.
    DATA(lv_kokrs) = COND kokrs( WHEN is_config-kokrs IS INITIAL THEN '9999' ELSE is_config-kokrs ).

    SELECT SINGLE kostl, aufnr, prctr  "#EC WARNOK
      FROM /eacm/zpr13
      WHERE kokrs = @lv_kokrs
        AND vkorg = @is_fisc-vkorg
        AND zcdaz = @is_fisc-zcdaz
      INTO (@rs_assignment-cost_center, @rs_assignment-order_number, @rs_assignment-profit_center).

    IF sy-subrc <> 0.
      SELECT SINGLE kostl, aufnr, prctr  "#EC WARNOK
        FROM /eacm/zpr13
        WHERE kokrs = @lv_kokrs
          AND vkorg = @is_fisc-vkorg
        INTO (@rs_assignment-cost_center, @rs_assignment-order_number, @rs_assignment-profit_center).
    ENDIF.
  ENDMETHOD.

  METHOD determine_assignment_number.
    rv_zuonr = is_selection-assignment_reference.

    IF rv_zuonr IS INITIAL.
      CONCATENATE is_fisc-zcdaz is_fisc-gjahr INTO rv_zuonr SEPARATED BY '-'.
    ENDIF.
  ENDMETHOD.

  METHOD collect_to_post.
    DATA(lt_fisc) = load_fisc_rows( is_selection ).

    LOOP AT lt_fisc INTO DATA(ls_fisc).
      DATA(ls_agent) = get_agent(
        iv_agent     = ls_fisc-zcdaz
        is_selection = is_selection ).
      IF ls_agent-agent IS INITIAL.
        CONTINUE.
      ENDIF.

      determine_open_amount(
        EXPORTING
          is_fisc   = ls_fisc
          is_config = is_config
        IMPORTING
          ev_amount          = DATA(lv_amount)
          ev_period_index    = DATA(lv_period_index)
          ev_is_final_period = DATA(lv_is_final_period) ).

      IF lv_amount IS INITIAL.
        CONTINUE.
      ENDIF.

      DATA(ls_accounts) = determine_accounts(
        EXPORTING
          is_fisc            = ls_fisc
          is_agent           = ls_agent
          is_config          = is_config
          iv_is_final_period = lv_is_final_period
        CHANGING
          ct_result          = ct_result ).

      IF ls_accounts-payable_account IS INITIAL
         OR ls_accounts-cost_account IS INITIAL.
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        fisc              = ls_fisc
        agent             = ls_agent
        accounts          = ls_accounts
        assignment        = determine_assignment( is_fisc = ls_fisc is_config = is_config )
        amount            = lv_amount
        period_index      = lv_period_index
        is_final_period   = lv_is_final_period
        assignment_number = determine_assignment_number( is_selection = is_selection is_fisc = ls_fisc ) )
        TO rt_to_post.
    ENDLOOP.
  ENDMETHOD.

  METHOD post_journal_entry.
    rv_success = abap_false.

    DATA(lv_document_date) = COND bldat(
      WHEN is_selection-document_date IS INITIAL
      THEN cl_abap_context_info=>get_system_date( )
      ELSE is_selection-document_date ).

    DATA(lv_posting_date) = COND budat(
      WHEN is_selection-posting_date IS INITIAL
      THEN cl_abap_context_info=>get_system_date( )
      ELSE is_selection-posting_date ).

    DATA(lv_blart) = COND blart(
      WHEN is_selection-accounting_document_type IS INITIAL
      THEN 'SA'
      ELSE is_selection-accounting_document_type ).

    DATA(lv_currency) = COND waers(
      WHEN is_to_post-fisc-waerk IS INITIAL
      THEN is_config-currency
      ELSE is_to_post-fisc-waerk ).
    DATA ls_request TYPE /eacm/cl_eacm_journal_post_api=>ty_request.
    DATA ls_item TYPE /eacm/cl_eacm_journal_post_api=>ty_gl_item.
    DATA lv_abs_amount TYPE decfloat34.

    lv_abs_amount = abs( CONV decfloat34( is_to_post-amount ) ).

    ls_request-company_code = is_selection-company_code.
    ls_request-document_date = lv_document_date.
    ls_request-posting_date = lv_posting_date.
    ls_request-accounting_document_type = lv_blart.
    ls_request-original_reference_document = |{ is_to_post-fisc-zcdaz }_FISC|.
    ls_request-document_header_text = 'Contabilizzazione FISC'.
    ls_request-created_by_user = cl_abap_context_info=>get_user_technical_name( ).

    CLEAR ls_item.
    ls_item-gl_account = is_to_post-accounts-cost_account.
    ls_item-amount = lv_abs_amount.
    ls_item-currency_code = lv_currency.
    ls_item-debit_credit_code = COND #( WHEN is_to_post-amount < 0 THEN 'H' ELSE 'S' ).
    ls_item-cost_center = is_to_post-assignment-cost_center.
    ls_item-profit_center = is_to_post-assignment-profit_center.
    ls_item-assignment_ref = is_to_post-assignment_number.
    ls_item-item_text = 'eACM - FISC Cost'.
    APPEND ls_item TO ls_request-items.

    CLEAR ls_item.
    ls_item-gl_account = is_to_post-accounts-payable_account.
    ls_item-amount = lv_abs_amount.
    ls_item-currency_code = lv_currency.
    ls_item-debit_credit_code = COND #( WHEN is_to_post-amount < 0 THEN 'S' ELSE 'H' ).
    ls_item-assignment_ref = is_to_post-assignment_number.
    ls_item-item_text = 'eACM - FISC'.
    APPEND ls_item TO ls_request-items.

    DATA(ls_response) = NEW /eacm/cl_eacm_journal_post_api( )->post_journal_entry( ls_request ).
    DATA(lv_detail_type) = COND symsgty(
      WHEN ls_response-success = abap_false THEN 'E'
      ELSE 'I' ).

    LOOP AT ls_response-message_details INTO DATA(lv_detail).
      append_message(
        EXPORTING
*          iv_type = 'I'
          iv_type = lv_detail_type
          iv_text = lv_detail
          iv_agent = is_to_post-fisc-zcdaz
        CHANGING
          ct_result = ct_result ).
    ENDLOOP.

    IF ls_response-success = abap_false.
      append_message(
        EXPORTING
          iv_type = 'E'
          iv_text = COND #( WHEN ls_response-message_text IS INITIAL
                            THEN |Contabilizzazione FISC non riuscita per agente { is_to_post-fisc-zcdaz }.|
                            ELSE ls_response-message_text )
          iv_agent = is_to_post-fisc-zcdaz
        CHANGING
          ct_result = ct_result ).
      RETURN.
    ENDIF.

    rv_success = abap_true.
    APPEND VALUE #(
      type                = 'S'
      message_text        = COND #( WHEN ls_response-message_text IS INITIAL
                                    THEN |Contabilizzazione FISC creata per agente { is_to_post-fisc-zcdaz }.|
                                    ELSE ls_response-message_text )
      accounting_document = ls_response-accounting_document
      fiscal_year         = is_to_post-fisc-gjahr
      company_code        = is_to_post-fisc-bukrs
      vkorg               = is_to_post-fisc-vkorg
      agent               = is_to_post-fisc-zcdaz
      period_index        = is_to_post-period_index
      is_final_period     = is_to_post-is_final_period
      success             = abap_true ) TO ct_result.
  ENDMETHOD.

  METHOD mark_as_posted.
    DATA(ls_fisc) = is_to_post-fisc.

    IF is_to_post-period_index = 0.
      ls_fisc-ztprc = /eacm/if_fisc_types=>gc_status_historized.
    ELSE.
      FIELD-SYMBOLS <status> TYPE any.
      DATA(lv_idx_text) = CONV string( is_to_post-period_index ).
      ASSIGN COMPONENT |ZTPRC_{ lv_idx_text }| OF STRUCTURE ls_fisc TO <status>.
      IF <status> IS ASSIGNED.
        <status> = /eacm/if_fisc_types=>gc_status_historized.
      ENDIF.

      IF is_to_post-is_final_period = abap_true.
        ls_fisc-ztprc = /eacm/if_fisc_types=>gc_status_historized.
      ENDIF.
    ENDIF.

    MODIFY /eacm/zprfisc FROM @ls_fisc.
  ENDMETHOD.

  METHOD append_message.
    APPEND VALUE #(
      type = iv_type
      message_text = iv_text
      agent = iv_agent ) TO ct_result.
  ENDMETHOD.

ENDCLASS.



