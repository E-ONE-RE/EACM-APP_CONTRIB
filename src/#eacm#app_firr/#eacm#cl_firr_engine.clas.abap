CLASS /eacm/cl_firr_engine DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /eacm/if_firr_types.

    ALIASES ty_request FOR /eacm/if_firr_types~ty_request.
    ALIASES ty_result  FOR /eacm/if_firr_types~ty_result.
    ALIASES ty_period  FOR /eacm/if_firr_types~ty_period.

    METHODS run
      IMPORTING is_request TYPE ty_request
      RETURNING VALUE(rs_result) TYPE ty_result
      RAISING cx_uuid_error.

    CLASS-METHODS determine_period
      IMPORTING
        iv_fiscal_year   TYPE gjahr
        iv_periodicity   TYPE /eacm/if_firr_types=>ty_periodicity
        iv_period_number TYPE /eacm/if_firr_types=>ty_request-period_number
      RETURNING VALUE(rs_period) TYPE ty_period.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_agent_context,
        agent    TYPE /eacm/zcdaz,
        supplier TYPE lifnr,
        erdat    TYPE /eacm/zpraa-erdat,
      END OF ty_agent_context,
      tt_agent_context TYPE HASHED TABLE OF ty_agent_context WITH UNIQUE KEY agent,

      BEGIN OF ty_contract_context,
        agent        TYPE /eacm/zcdaz,
        supplier     TYPE lifnr,
        contract_from TYPE /eacm/prcn-zdtin,
        contract_to   TYPE /eacm/prcn-zdtfi,
        firr_model   TYPE /eacm/prcn-ztman,
        prov_type    TYPE /eacm/prcn-ztprv,
      END OF ty_contract_context,
      tt_contract_context TYPE HASHED TABLE OF ty_contract_context WITH UNIQUE KEY agent,

      BEGIN OF ty_rule_context,
        firr_model    TYPE /eacm/zpr24-ztman,
        percent_1     TYPE /eacm/zpr24-zper1,
        percent_2     TYPE /eacm/zpr24-zper2,
        percent_3     TYPE /eacm/zpr24-zper3,
        threshold_1   TYPE /eacm/zpr24-zsca1,
        threshold_2   TYPE /eacm/zpr24-zsca2,
        threshold_3   TYPE /eacm/zpr24-zsca3,
        month_rule    TYPE /eacm/zpr24-zmese,
        firr_currency TYPE /eacm/zpr24-zwaer,
      END OF ty_rule_context,
      tt_rule_context TYPE HASHED TABLE OF ty_rule_context WITH UNIQUE KEY firr_model,

      BEGIN OF ty_excluded_commission,
        company_code      TYPE bukrs,
        commission_class TYPE /eacm/zpr08-zclpr,
      END OF ty_excluded_commission,
      tt_excluded_commission TYPE HASHED TABLE OF ty_excluded_commission
        WITH UNIQUE KEY company_code commission_class.

    METHODS validate_required_request
      IMPORTING is_request TYPE ty_request
      CHANGING  ct_messages TYPE /eacm/if_firr_types=>tt_message.

    METHODS validate_request
      IMPORTING is_request TYPE ty_request
      CHANGING  ct_messages TYPE /eacm/if_firr_types=>tt_message.

    METHODS validate_calculation_basis
      IMPORTING is_request TYPE ty_request
      CHANGING  ct_messages TYPE /eacm/if_firr_types=>tt_message.

    METHODS apply_company_configuration
      CHANGING
        cs_request  TYPE ty_request
        ct_messages TYPE /eacm/if_firr_types=>tt_message.

    METHODS collect_base_amounts
      IMPORTING
        is_request TYPE ty_request
        is_period  TYPE ty_period
      CHANGING
        ct_firr    TYPE /eacm/if_firr_types=>tt_firr
        ct_messages TYPE /eacm/if_firr_types=>tt_message.

    METHODS enrich_and_calculate
      IMPORTING
        is_request TYPE ty_request
        is_period  TYPE ty_period
      CHANGING
        ct_firr    TYPE /eacm/if_firr_types=>tt_firr
        ct_messages TYPE /eacm/if_firr_types=>tt_message.

    METHODS get_company_currency
      IMPORTING iv_company_code TYPE bukrs
      CHANGING  ct_messages     TYPE /eacm/if_firr_types=>tt_message
      RETURNING VALUE(rv_currency) TYPE waers.

    METHODS load_agent_contexts
      IMPORTING
        is_request TYPE ty_request
        is_period  TYPE ty_period
      RETURNING VALUE(rt_agents) TYPE tt_agent_context.

    METHODS load_contract_contexts
      IMPORTING
        is_request TYPE ty_request
        is_period  TYPE ty_period
        it_agents  TYPE tt_agent_context
      RETURNING VALUE(rt_contracts) TYPE tt_contract_context.

    METHODS load_rule_contexts
      IMPORTING it_contracts TYPE tt_contract_context
      RETURNING VALUE(rt_rules) TYPE tt_rule_context.

    METHODS load_excluded_commissions
      IMPORTING iv_company_code TYPE bukrs
      RETURNING VALUE(rt_excluded) TYPE tt_excluded_commission.

    METHODS add_firr_row
      IMPORTING is_firr TYPE /eacm/zprfirr
      CHANGING  ct_firr TYPE /eacm/if_firr_types=>tt_firr.

    METHODS get_document_sign
      IMPORTING iv_vbtyp TYPE /eacm/prdo-vbtyp
      RETURNING VALUE(rv_sign) TYPE decfloat34.

    METHODS convert_by_rate
      IMPORTING
        iv_amount TYPE /eacm/zpmat
        iv_rate   TYPE ukurs_curr
      RETURNING VALUE(rv_amount) TYPE /eacm/zpmat.

    METHODS convert_to_currency
      IMPORTING
        iv_amount          TYPE /eacm/zpmat
        iv_source_currency TYPE waers
        iv_target_currency TYPE waers
        iv_date            TYPE d
      RETURNING VALUE(rv_amount) TYPE /eacm/zpmat.

    METHODS calculate_months
      IMPORTING
        iv_fiscal_year TYPE gjahr
        iv_period_end  TYPE d
        is_contract    TYPE ty_contract_context
        is_rule        TYPE ty_rule_context
      RETURNING VALUE(rv_months) TYPE /eacm/if_firr_types=>ty_month.

    METHODS calculate_contribution
      IMPORTING
        iv_amount      TYPE /eacm/zpmat
        iv_months      TYPE /eacm/if_firr_types=>ty_month
        iv_percent_1   TYPE /eacm/zpr24-zper1
        iv_percent_2   TYPE /eacm/zpr24-zper2
        iv_percent_3   TYPE /eacm/zpr24-zper3
        iv_threshold_1 TYPE /eacm/zpr24-zsca1
        iv_threshold_2 TYPE /eacm/zpr24-zsca2
        iv_threshold_3 TYPE /eacm/zpr24-zsca3
      RETURNING VALUE(rv_firr) TYPE /eacm/zbuto.

    METHODS apply_period_amounts
      IMPORTING
        is_request TYPE ty_request
        is_period  TYPE ty_period
      CHANGING
        cs_firr    TYPE /eacm/zprfirr.

    METHODS distribute_by_brand
      CHANGING ct_firr TYPE /eacm/if_firr_types=>tt_firr.

    METHODS save_result
      IMPORTING it_firr TYPE /eacm/if_firr_types=>tt_firr
      RETURNING VALUE(rv_saved_rows) TYPE i.

    CLASS-METHODS last_day_of_month
      IMPORTING
        iv_year  TYPE gjahr
        iv_month TYPE /eacm/if_firr_types=>ty_month
      RETURNING VALUE(rv_date) TYPE d.

ENDCLASS.



CLASS /EACM/CL_FIRR_ENGINE IMPLEMENTATION.


  METHOD add_firr_row.
    READ TABLE ct_firr ASSIGNING FIELD-SYMBOL(<firr>)
      WITH KEY bukrs = is_firr-bukrs
               vkorg = is_firr-vkorg
               gjahr = is_firr-gjahr
               zcdaz = is_firr-zcdaz
               lifnr = is_firr-lifnr
               waerk = is_firr-waerk
               ztpmf = is_firr-ztpmf.

    IF sy-subrc = 0.
      <firr>-zfpmat += is_firr-zfpmat.
      <firr>-zfpmatc += is_firr-zfpmatc.
    ELSE.
      APPEND is_firr TO ct_firr.
    ENDIF.
  ENDMETHOD.


  METHOD distribute_by_brand.
    TYPES:
      BEGIN OF ty_total,
        bukrs  TYPE bukrs,
        gjahr  TYPE gjahr,
        zcdaz  TYPE /eacm/zcdaz,
        zfpmat TYPE /eacm/zpmat,
        zfbuto TYPE /eacm/zbuto,
      END OF ty_total.

    DATA lt_totals TYPE HASHED TABLE OF ty_total WITH UNIQUE KEY bukrs gjahr zcdaz.

    LOOP AT ct_firr ASSIGNING FIELD-SYMBOL(<firr>).
      COLLECT VALUE ty_total(
        bukrs  = <firr>-bukrs
        gjahr  = <firr>-gjahr
        zcdaz  = <firr>-zcdaz
        zfpmat = <firr>-zfpmat
        zfbuto = <firr>-zfbuto ) INTO lt_totals.
    ENDLOOP.

    LOOP AT ct_firr ASSIGNING <firr>.
      READ TABLE lt_totals ASSIGNING FIELD-SYMBOL(<total>)
        WITH TABLE KEY bukrs = <firr>-bukrs
                       gjahr = <firr>-gjahr
                       zcdaz = <firr>-zcdaz.
      IF sy-subrc = 0 AND <total>-zfpmat IS NOT INITIAL.
        <firr>-zfbuto = <firr>-zfpmat * ( <total>-zfbuto / <total>-zfpmat ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD convert_by_rate.
    DATA(lv_rate) = iv_rate.

    rv_amount = iv_amount.

    IF lv_rate IS INITIAL.
      lv_rate = 1.
    ENDIF.

    IF lv_rate > 0.
      rv_amount = iv_amount * lv_rate.
    ELSE.
      lv_rate *= -1.
      rv_amount = iv_amount / lv_rate.
    ENDIF.
  ENDMETHOD.


  METHOD validate_calculation_basis.
    IF is_request-calculation_basis <> /eacm/if_firr_types=>gc_basis_invoiced
       AND is_request-calculation_basis <> /eacm/if_firr_types=>gc_basis_accrued
       AND is_request-calculation_basis <> /eacm/if_firr_types=>gc_basis_invoice_dt
       AND is_request-calculation_basis <> /eacm/if_firr_types=>gc_basis_contract.
      APPEND VALUE #( type = /eacm/if_firr_types=>gc_msg_error
                      text = `Base calcolo /EACM/ZPR01-ZFIRRTPCAL ammessa: FATT, MAT, FAC, CON` ) TO ct_messages.
    ENDIF.
  ENDMETHOD.


  METHOD determine_period.
    DATA(lv_period_number) = CONV i( iv_period_number ).
    DATA lv_month TYPE n LENGTH 2.

    CASE iv_periodicity.
      WHEN /eacm/if_firr_types=>gc_period_yearly.
        rs_period-begin_date = CONV d( |{ iv_fiscal_year }0101| ).
        rs_period-end_date = CONV d( |{ iv_fiscal_year }1231| ).
        rs_period-period_field_index = 0.

      WHEN /eacm/if_firr_types=>gc_period_quarterly.
        rs_period-begin_date = CONV d( |{ iv_fiscal_year }0101| ).
        rs_period-period_field_index = lv_period_number * 3.
        lv_month = rs_period-period_field_index.
        rs_period-end_date = last_day_of_month(
          iv_year  = iv_fiscal_year
          iv_month = lv_month ).

      WHEN /eacm/if_firr_types=>gc_period_monthly.
        rs_period-begin_date = CONV d( |{ iv_fiscal_year }0101| ).
        rs_period-period_field_index = lv_period_number.
        rs_period-end_date = last_day_of_month(
          iv_year  = iv_fiscal_year
          iv_month = iv_period_number ).
    ENDCASE.
  ENDMETHOD.


  METHOD run.
    DATA(ls_request) = is_request.

    rs_result-run_uuid = cl_system_uuid=>create_uuid_x16_static( ).
    rs_result-preview = xsdbool( ls_request-definitive = abap_false ).

    validate_required_request(
      EXPORTING is_request = ls_request
      CHANGING  ct_messages = rs_result-messages ).

    IF line_exists( rs_result-messages[ type = /eacm/if_firr_types=>gc_msg_error ] ).
      RETURN.
    ENDIF.

    apply_company_configuration(
      CHANGING
        cs_request  = ls_request
        ct_messages = rs_result-messages ).

    IF NOT line_exists( rs_result-messages[ type = /eacm/if_firr_types=>gc_msg_error ] ).
      validate_request(
        EXPORTING is_request = ls_request
        CHANGING  ct_messages = rs_result-messages ).
    ENDIF.

    IF NOT line_exists( rs_result-messages[ type = /eacm/if_firr_types=>gc_msg_error ] ).
      validate_calculation_basis(
        EXPORTING is_request = ls_request
        CHANGING  ct_messages = rs_result-messages ).
    ENDIF.

    IF line_exists( rs_result-messages[ type = /eacm/if_firr_types=>gc_msg_error ] ).
      RETURN.
    ENDIF.

    rs_result-period = determine_period(
      iv_fiscal_year   = ls_request-fiscal_year
      iv_periodicity   = ls_request-periodicity
      iv_period_number = ls_request-period_number ).

    collect_base_amounts(
      EXPORTING
        is_request = ls_request
        is_period  = rs_result-period
      CHANGING
        ct_firr     = rs_result-firr_rows
        ct_messages = rs_result-messages ).

    enrich_and_calculate(
      EXPORTING
        is_request = ls_request
        is_period  = rs_result-period
      CHANGING
        ct_firr     = rs_result-firr_rows
        ct_messages = rs_result-messages ).

    distribute_by_brand( CHANGING ct_firr = rs_result-firr_rows ).

    rs_result-processed_rows = lines( rs_result-firr_rows ).

    IF ls_request-definitive = abap_true
       AND NOT line_exists( rs_result-messages[ type = /eacm/if_firr_types=>gc_msg_error ] ).
      rs_result-saved_rows = save_result( rs_result-firr_rows ).
    ENDIF.
  ENDMETHOD.


  METHOD load_contract_contexts.
    CHECK it_agents IS NOT INITIAL.

    DATA lt_contracts TYPE STANDARD TABLE OF ty_contract_context WITH EMPTY KEY.

    SELECT zcdaz AS agent,
           zdtin AS contract_from,
           zdtfi AS contract_to,
           ztman AS firr_model,
           ztprv AS prov_type
      FROM /eacm/prcn
      FOR ALL ENTRIES IN @it_agents
      WHERE bukrs = @is_request-company_code
        AND zcdaz = @it_agents-agent
        AND zstre <> 'A'
        AND zdtin <= @is_period-end_date
      INTO CORRESPONDING FIELDS OF TABLE @lt_contracts.

    SORT lt_contracts BY agent ASCENDING contract_from DESCENDING.

    LOOP AT lt_contracts INTO DATA(ls_contract).
      READ TABLE it_agents ASSIGNING FIELD-SYMBOL(<agent>)
        WITH TABLE KEY agent = ls_contract-agent.
      IF sy-subrc = 0.
        ls_contract-supplier = <agent>-supplier.
      ENDIF.

      INSERT ls_contract INTO TABLE rt_contracts.
    ENDLOOP.
  ENDMETHOD.


  METHOD load_rule_contexts.
    CHECK it_contracts IS NOT INITIAL.

    DATA lt_rules TYPE STANDARD TABLE OF ty_rule_context WITH EMPTY KEY.

    SELECT ztman AS firr_model,
           zper1 AS percent_1,
           zper2 AS percent_2,
           zper3 AS percent_3,
           zsca1 AS threshold_1,
           zsca2 AS threshold_2,
           zsca3 AS threshold_3,
           zmese AS month_rule,
           zwaer AS firr_currency
      FROM /eacm/zpr24
      FOR ALL ENTRIES IN @it_contracts
      WHERE ztman = @it_contracts-firr_model
      INTO CORRESPONDING FIELDS OF TABLE @lt_rules.

    LOOP AT lt_rules INTO DATA(ls_rule).
      INSERT ls_rule INTO TABLE rt_rules.
    ENDLOOP.
  ENDMETHOD.


  METHOD apply_company_configuration.
    IF cs_request-company_code IS INITIAL.
      RETURN.
    ENDIF.

    SELECT SINGLE zgfirr, zfirrtpcal
      FROM /eacm/zpr01
      WHERE bukrs = @cs_request-company_code
      INTO @DATA(ls_company_config).

    IF sy-subrc <> 0.
      APPEND VALUE #( type = /eacm/if_firr_types=>gc_msg_error
                      company = cs_request-company_code
                      text = `Configurazione FIRR societa non trovata in /EACM/ZPR01` ) TO ct_messages.
      RETURN.
    ENDIF.

    cs_request-calculation_basis = ls_company_config-zfirrtpcal.
    cs_request-periodicity = ls_company_config-zgfirr.

    IF ls_company_config-zgfirr IS INITIAL.
      APPEND VALUE #( type = /eacm/if_firr_types=>gc_msg_error
                      company = cs_request-company_code
                      text = |Periodicita FIRR non configurata per la societa { cs_request-company_code } in /EACM/ZPR01-ZGFIRR| ) TO ct_messages.
    ENDIF.
  ENDMETHOD.


  METHOD save_result.
    DATA lt_firr TYPE /eacm/if_firr_types=>tt_firr.
    DATA lv_timestamp TYPE timestampl.

    lt_firr = it_firr.
    GET TIME STAMP FIELD lv_timestamp.

    LOOP AT lt_firr ASSIGNING FIELD-SYMBOL(<firr>).
      SELECT SINGLE created_by, created_at
        FROM /eacm/zprfirr
        WHERE bukrs = @<firr>-bukrs
          AND vkorg = @<firr>-vkorg
          AND gjahr = @<firr>-gjahr
          AND zcdaz = @<firr>-zcdaz
        INTO ( @DATA(lv_created_by), @DATA(lv_created_at) ).

      IF sy-subrc = 0.
        <firr>-created_by = lv_created_by.
        <firr>-created_at = lv_created_at.
      ELSE.
        <firr>-created_by = sy-uname.
        <firr>-created_at = lv_timestamp.
      ENDIF.

      <firr>-changed_by = sy-uname.
      <firr>-changed_at = lv_timestamp.
      <firr>-local_last_changed_at = lv_timestamp.
    ENDLOOP.

    MODIFY /eacm/zprfirr FROM TABLE @lt_firr.
    rv_saved_rows = sy-dbcnt.
  ENDMETHOD.


  METHOD last_day_of_month.
    DATA(lv_month) = CONV i( iv_month ).
    DATA(lv_year) = CONV i( iv_year ).

    IF lv_month = 12.
      lv_year += 1.
      lv_month = 1.
    ELSE.
      lv_month += 1.
    ENDIF.

    DATA(lv_next_month) = CONV d( |{ lv_year WIDTH = 4 PAD = '0' }{ lv_month WIDTH = 2 PAD = '0' ALIGN = RIGHT }01| ).
    rv_date = lv_next_month - 1.
  ENDMETHOD.


  METHOD convert_to_currency.
    rv_amount = iv_amount.

    IF iv_source_currency IS INITIAL
       OR iv_target_currency IS INITIAL
       OR iv_source_currency = iv_target_currency.
      RETURN.
    ENDIF.

    TRY.
        SELECT SINGLE
               currency_conversion(
                 amount             = @iv_amount,
                 source_currency    = @iv_source_currency,
                 target_currency    = @iv_target_currency,
                 exchange_rate_date = @iv_date,
                 exchange_rate_type = 'M',
                 round              = 'X' ) AS amount
          FROM I_Currency
          WHERE Currency = @iv_source_currency
          INTO @rv_amount.
      CATCH cx_sy_open_sql_db.
        rv_amount = iv_amount.
    ENDTRY.

    IF sy-subrc <> 0.
      rv_amount = iv_amount.
    ENDIF.
  ENDMETHOD.


  METHOD load_excluded_commissions.
    DATA lt_excluded TYPE STANDARD TABLE OF ty_excluded_commission WITH EMPTY KEY.

    SELECT bukrs AS company_code,
           zclpr AS commission_class
      FROM /eacm/zpr08
      WHERE bukrs = @iv_company_code
      INTO TABLE @lt_excluded.

    LOOP AT lt_excluded INTO DATA(ls_excluded).
      INSERT ls_excluded INTO TABLE rt_excluded.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_document_sign.
    DATA lv_sign TYPE /eacm/zpr48-zsegn.

    rv_sign = 1.

    SELECT SINGLE zsegn
      FROM /eacm/zpr48
      WHERE vbtyp = @iv_vbtyp
      INTO @lv_sign.

    IF sy-subrc = 0 AND lv_sign IS NOT INITIAL.
      rv_sign = CONV decfloat34( lv_sign ).
      RETURN.
    ENDIF.

    IF iv_vbtyp = 'O' OR iv_vbtyp = 'N'.
      rv_sign = -1.
    ENDIF.
  ENDMETHOD.


  METHOD load_agent_contexts.
    DATA lv_has_agent_range TYPE abap_bool.

    lv_has_agent_range = xsdbool( is_request-agent_range IS NOT INITIAL ).

    SELECT zcdaz AS agent,
           lifnr AS supplier,
           erdat
      FROM /eacm/zpraa
      WHERE ( @lv_has_agent_range = @abap_false OR zcdaz IN @is_request-agent_range )
        AND erdat <= @is_period-end_date
        AND zstre <> 'A'
        AND zstre <> 'S'
        AND zsfir = @abap_true
      ORDER BY zcdaz ASCENDING, erdat DESCENDING
      INTO TABLE @DATA(lt_agents).

    LOOP AT lt_agents INTO DATA(ls_agent).
      INSERT ls_agent INTO TABLE rt_agents.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_company_currency.
*    SELECT SINGLE currency
*      FROM /eacm/i_company
*      WHERE SapCompanyCode = @iv_company_code
*      INTO @rv_currency.
    SELECT SINGLE waers
      FROM /eacm/t001
      WHERE bukrs = @iv_company_code
      INTO @rv_currency.

    IF sy-subrc <> 0 OR rv_currency IS INITIAL.
      APPEND VALUE #( type = /eacm/if_firr_types=>gc_msg_error
                      company = iv_company_code
                      text = 'Valuta societa non trovata in T001' ) TO ct_messages.
*                      text = 'Valuta societa non trovata in I_Company' ) TO ct_messages.
    ENDIF.
  ENDMETHOD.


  METHOD calculate_contribution.
    DATA(lv_remaining) = iv_amount.
    DATA(lv_negative) = xsdbool( lv_remaining < 0 ).

    IF lv_negative = abap_true.
      lv_remaining = abs( lv_remaining ).
    ENDIF.

    DATA(lv_sc1) = iv_threshold_1 * iv_months / 12 ##TYPE.
    DATA(lv_sc2) = ( iv_threshold_2 - iv_threshold_1 ) * iv_months / 12 ##TYPE.
    DATA(lv_sc3) = ( iv_threshold_3 - iv_threshold_2 ) * iv_months / 12 ##TYPE.

    DATA(lv_take) = COND #( WHEN lv_remaining <= lv_sc1 THEN lv_remaining ELSE lv_sc1 ).
    rv_firr += lv_take * iv_percent_1 / 100.
    lv_remaining -= lv_take.

    IF lv_remaining > 0.
      lv_take = COND #( WHEN lv_remaining <= lv_sc2 THEN lv_remaining ELSE lv_sc2 ).
      rv_firr += lv_take * iv_percent_2 / 100.
      lv_remaining -= lv_take.
    ENDIF.

    IF lv_remaining > 0.
      lv_take = COND #( WHEN lv_remaining <= lv_sc3 THEN lv_remaining ELSE lv_sc3 ).
      rv_firr += lv_take * iv_percent_3 / 100.
    ENDIF.

    IF lv_negative = abap_true.
      rv_firr *= -1.
    ENDIF.
  ENDMETHOD.


  METHOD apply_period_amounts.
    IF is_request-definitive = abap_true.
      cs_firr-ztprc = /eacm/if_firr_types=>gc_status_calculated.
    ELSE.
      CLEAR cs_firr-ztprc.
    ENDIF.

    CASE is_request-periodicity.
      WHEN /eacm/if_firr_types=>gc_period_yearly.
        RETURN.

      WHEN /eacm/if_firr_types=>gc_period_monthly
        OR /eacm/if_firr_types=>gc_period_quarterly.
        CASE is_period-period_field_index.
          WHEN 1.
            cs_firr-zfpmat_1 = cs_firr-zfpmat.
            cs_firr-zfbuto_1 = cs_firr-zfbuto.
            cs_firr-ztprc_1 = /eacm/if_firr_types=>gc_status_calculated.
          WHEN 2.
            cs_firr-zfpmat_2 = cs_firr-zfpmat.
            cs_firr-zfbuto_2 = cs_firr-zfbuto.
            cs_firr-ztprc_2 = /eacm/if_firr_types=>gc_status_calculated.
          WHEN 3.
            cs_firr-zfpmat_3 = cs_firr-zfpmat.
            cs_firr-zfbuto_3 = cs_firr-zfbuto.
            cs_firr-ztprc_3 = /eacm/if_firr_types=>gc_status_calculated.
          WHEN 4.
            cs_firr-zfpmat_4 = cs_firr-zfpmat.
            cs_firr-zfbuto_4 = cs_firr-zfbuto.
            cs_firr-ztprc_4 = /eacm/if_firr_types=>gc_status_calculated.
          WHEN 5.
            cs_firr-zfpmat_5 = cs_firr-zfpmat.
            cs_firr-zfbuto_5 = cs_firr-zfbuto.
            cs_firr-ztprc_5 = /eacm/if_firr_types=>gc_status_calculated.
          WHEN 6.
            cs_firr-zfpmat_6 = cs_firr-zfpmat.
            cs_firr-zfbuto_6 = cs_firr-zfbuto.
            cs_firr-ztprc_6 = /eacm/if_firr_types=>gc_status_calculated.
          WHEN 7.
            cs_firr-zfpmat_7 = cs_firr-zfpmat.
            cs_firr-zfbuto_7 = cs_firr-zfbuto.
            cs_firr-ztprc_7 = /eacm/if_firr_types=>gc_status_calculated.
          WHEN 8.
            cs_firr-zfpmat_8 = cs_firr-zfpmat.
            cs_firr-zfbuto_8 = cs_firr-zfbuto.
            cs_firr-ztprc_8 = /eacm/if_firr_types=>gc_status_calculated.
          WHEN 9.
            cs_firr-zfpmat_9 = cs_firr-zfpmat.
            cs_firr-zfbuto_9 = cs_firr-zfbuto.
            cs_firr-ztprc_9 = /eacm/if_firr_types=>gc_status_calculated.
          WHEN 10.
            cs_firr-zfpmat_10 = cs_firr-zfpmat.
            cs_firr-zfbuto_10 = cs_firr-zfbuto.
            cs_firr-ztprc_10 = /eacm/if_firr_types=>gc_status_calculated.
          WHEN 11.
            cs_firr-zfpmat_11 = cs_firr-zfpmat.
            cs_firr-zfbuto_11 = cs_firr-zfbuto.
            cs_firr-ztprc_11 = /eacm/if_firr_types=>gc_status_calculated.
          WHEN 12.
            cs_firr-zfpmat_12 = cs_firr-zfpmat.
            cs_firr-zfbuto_12 = cs_firr-zfbuto.
            cs_firr-ztprc_12 = /eacm/if_firr_types=>gc_status_calculated.
        ENDCASE.
    ENDCASE.
  ENDMETHOD.


  METHOD enrich_and_calculate.
    CHECK ct_firr IS NOT INITIAL.

    SORT ct_firr BY lifnr ASCENDING zfpmat DESCENDING.

    DATA ls_contract TYPE ty_contract_context.
    DATA lt_contract_match TYPE STANDARD TABLE OF ty_contract_context WITH EMPTY KEY.
    DATA ls_rule TYPE ty_rule_context.
    DATA lv_adjustment TYPE /eacm/zprindrett-firr.

    LOOP AT ct_firr ASSIGNING FIELD-SYMBOL(<firr>).
      CLEAR: ls_contract, ls_rule, lv_adjustment.
      CLEAR lt_contract_match.

      SELECT zcdaz AS agent,
             zdtin AS contract_from,
             zdtfi AS contract_to,
             ztman AS firr_model,
             ztprv AS prov_type
        FROM /eacm/prcn
        WHERE zcdaz = @<firr>-zcdaz
          AND bukrs = @is_request-company_code
          AND zstre <> 'A'
          AND zdtin <= @is_period-end_date
        INTO CORRESPONDING FIELDS OF TABLE @lt_contract_match.

      SORT lt_contract_match BY contract_from DESCENDING.
      READ TABLE lt_contract_match INTO ls_contract INDEX 1.

      IF sy-subrc <> 0.
        APPEND VALUE #( type = /eacm/if_firr_types=>gc_msg_warning
                        company = <firr>-bukrs
                        fiscal_year = <firr>-gjahr
                        vkorg = <firr>-vkorg
                        agent = <firr>-zcdaz
                        text = |Contratto non trovato in /EACM/ZPRCN per agente { <firr>-zcdaz }| ) TO ct_messages.
        CONTINUE.
      ENDIF.

      ls_contract-supplier = <firr>-lifnr.

      SELECT SINGLE ztman AS firr_model,
                    zper1 AS percent_1,
                    zper2 AS percent_2,
                    zper3 AS percent_3,
                    zsca1 AS threshold_1,
                    zsca2 AS threshold_2,
                    zsca3 AS threshold_3,
                    zmese AS month_rule,
                    zwaer AS firr_currency
        FROM /eacm/zpr24
        WHERE ztman = @ls_contract-firr_model
        INTO CORRESPONDING FIELDS OF @ls_rule.

      IF sy-subrc <> 0.
        APPEND VALUE #( type = /eacm/if_firr_types=>gc_msg_warning
                        company = <firr>-bukrs
                        fiscal_year = <firr>-gjahr
                        vkorg = <firr>-vkorg
                        agent = <firr>-zcdaz
                        text = |Regola FIRR { ls_contract-firr_model } non trovata in /EACM/ZPR24| ) TO ct_messages.
        CONTINUE.
      ENDIF.

      DATA(lv_months) = calculate_months(
        iv_fiscal_year = is_request-fiscal_year
        iv_period_end  = is_period-end_date
        is_contract    = ls_contract
        is_rule        = ls_rule ).

      SELECT SINGLE firr
        FROM /eacm/zprindrett
        WHERE bukrs = @<firr>-bukrs
          AND vkorg = @<firr>-vkorg
          AND gjahr = @<firr>-gjahr
          AND zcdaz = @<firr>-zcdaz
        INTO @lv_adjustment.

      IF sy-subrc = 0.
        <firr>-zfpmat += lv_adjustment.
      ENDIF.

      <firr>-mesi = lv_months.
      <firr>-zfbuto = calculate_contribution(
        iv_amount      = <firr>-zfpmat
        iv_months      = lv_months
        iv_percent_1   = ls_rule-percent_1
        iv_percent_2   = ls_rule-percent_2
        iv_percent_3   = ls_rule-percent_3
        iv_threshold_1 = ls_rule-threshold_1
        iv_threshold_2 = ls_rule-threshold_2
        iv_threshold_3 = ls_rule-threshold_3 ).

      apply_period_amounts(
        EXPORTING
          is_request = is_request
          is_period  = is_period
        CHANGING
          cs_firr    = <firr> ).
      ENDLOOP.
  ENDMETHOD.


  METHOD validate_required_request.
    IF is_request-company_code IS INITIAL.
      APPEND VALUE #( type = /eacm/if_firr_types=>gc_msg_error
                      text = `Company code obbligatorio` ) TO ct_messages.
    ENDIF.

    IF is_request-fiscal_year IS INITIAL.
      APPEND VALUE #( type = /eacm/if_firr_types=>gc_msg_error
                      text = `Esercizio obbligatorio` ) TO ct_messages.
    ENDIF.
  ENDMETHOD.


  METHOD calculate_months.
    DATA lv_year_begin TYPE d.
    DATA lv_start TYPE d.
    DATA lv_end TYPE d.
    DATA lv_months TYPE i.

    lv_year_begin = CONV d( |{ iv_fiscal_year }0101| ).
    lv_start = is_contract-contract_from.
    lv_end = is_contract-contract_to.

    IF lv_start IS INITIAL OR lv_start < lv_year_begin.
      lv_start = lv_year_begin.
    ENDIF.

    IF lv_end IS INITIAL OR lv_end > iv_period_end.
      lv_end = iv_period_end.
    ENDIF.

    IF lv_start > iv_period_end OR lv_end < lv_start.
      rv_months = 0.
      RETURN.
    ENDIF.

    lv_months = CONV i( lv_end+4(2) ) - CONV i( lv_start+4(2) ) + 1.

    IF is_rule-month_rule = abap_true.
      IF lv_start+6(2) > '15'.
        lv_months -= 1.
      ENDIF.

      IF lv_end+6(2) <= '15'.
        lv_months -= 1.
      ENDIF.
    ENDIF.

    IF lv_months < 0.
      lv_months = 0.
    ENDIF.

    rv_months = lv_months.
  ENDMETHOD.


  METHOD collect_base_amounts.
    FIELD-SYMBOLS:
      <agent>    TYPE ty_agent_context,
      <contract> TYPE ty_contract_context,
      <rule>     TYPE ty_rule_context.

    DATA(lv_company_currency) = get_company_currency(
      EXPORTING iv_company_code = is_request-company_code
      CHANGING  ct_messages     = ct_messages ).

    IF lv_company_currency IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lt_agents) = load_agent_contexts(
      is_request = is_request
      is_period  = is_period ).

    IF lt_agents IS INITIAL.
      APPEND VALUE #( type = /eacm/if_firr_types=>gc_msg_warning
                      company = is_request-company_code
                      fiscal_year = is_request-fiscal_year
                      text = `Nessun agente FIRR trovato in /EACM/ZPRAA` ) TO ct_messages.
      RETURN.
    ENDIF.

    DATA(lt_contracts) = load_contract_contexts(
      is_request = is_request
      is_period  = is_period
      it_agents  = lt_agents ).

    IF lt_contracts IS INITIAL.
      APPEND VALUE #( type = /eacm/if_firr_types=>gc_msg_warning
                      company = is_request-company_code
                      fiscal_year = is_request-fiscal_year
                      text = `Nessun contratto FIRR trovato in /EACM/ZPRCN` ) TO ct_messages.
      RETURN.
    ENDIF.

    DATA(lt_rules) = load_rule_contexts( it_contracts = lt_contracts ).
    DATA(lt_excluded_commissions) = load_excluded_commissions(
      iv_company_code = is_request-company_code ).

    DATA lv_period_from TYPE n LENGTH 6.
    DATA lv_period_to   TYPE n LENGTH 6.
    DATA lv_has_vkorg_range TYPE abap_bool.
    DATA lv_amount TYPE /eacm/zpmat.
    DATA lv_firr_amount TYPE /eacm/zpmat.
    DATA lv_company_amount TYPE /eacm/zpmatc.
    DATA lv_firr_currency TYPE waers.
    DATA lv_conversion_date TYPE d.

    lv_period_from = is_period-begin_date(6).
    lv_period_to = is_period-end_date(6).
    lv_has_vkorg_range = xsdbool( is_request-vkorg_range IS NOT INITIAL ).

    IF is_request-calculation_basis = /eacm/if_firr_types=>gc_basis_invoiced
       OR is_request-calculation_basis = /eacm/if_firr_types=>gc_basis_contract.

      SELECT bukrs, vkorg, zcdaz, waerk, zimco AS amount,
             vbtyp, zclpr, kurrf, fkdat
        FROM /eacm/prdo
        WHERE zstre <> 'D'
          AND bukrs = @is_request-company_code
          AND ( @lv_has_vkorg_range = @abap_false OR vkorg IN @is_request-vkorg_range )
          AND fkdat BETWEEN @is_period-begin_date AND @is_period-end_date
        INTO TABLE @DATA(lt_zprdo).

      LOOP AT lt_zprdo INTO DATA(ls_zprdo).
        READ TABLE lt_contracts ASSIGNING <contract>
          WITH TABLE KEY agent = ls_zprdo-zcdaz.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        IF is_request-calculation_basis = /eacm/if_firr_types=>gc_basis_contract
           AND <contract>-prov_type <> /eacm/if_firr_types=>gc_basis_invoiced.
          CONTINUE.
        ENDIF.

        READ TABLE lt_agents ASSIGNING <agent>
          WITH TABLE KEY agent = ls_zprdo-zcdaz.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        IF line_exists( lt_excluded_commissions[
             company_code      = ls_zprdo-bukrs
             commission_class = ls_zprdo-zclpr ] ).
          CONTINUE.
        ENDIF.

        lv_firr_currency = lv_company_currency.
        READ TABLE lt_rules ASSIGNING <rule>
          WITH TABLE KEY firr_model = <contract>-firr_model.
        IF sy-subrc = 0 AND <rule>-firr_currency IS NOT INITIAL.
          lv_firr_currency = <rule>-firr_currency.
        ENDIF.

        lv_amount =  CONV decfloat34( ls_zprdo-amount )
                            * get_document_sign( iv_vbtyp = ls_zprdo-vbtyp ) .
        lv_firr_amount = convert_to_currency(
          iv_amount          = lv_amount
          iv_source_currency = ls_zprdo-waerk
          iv_target_currency = lv_firr_currency
          iv_date            = ls_zprdo-fkdat ).
        lv_company_amount = COND #(
          WHEN ls_zprdo-waerk = lv_company_currency THEN lv_amount
          ELSE convert_by_rate( iv_amount = lv_amount
                                iv_rate   = ls_zprdo-kurrf ) ).

        add_firr_row(
          EXPORTING
            is_firr = VALUE #(
              bukrs   = ls_zprdo-bukrs
              vkorg   = ls_zprdo-vkorg
              gjahr   = is_request-fiscal_year
              zcdaz   = ls_zprdo-zcdaz
              lifnr   = <agent>-supplier
              waerk   = lv_firr_currency
              zfpmat  = lv_firr_amount
              ztpmf   = 'F'
              waersc  = lv_company_currency
              zfpmatc = lv_company_amount )
          CHANGING
            ct_firr = ct_firr ).
      ENDLOOP.
    ENDIF.

    IF is_request-calculation_basis = /eacm/if_firr_types=>gc_basis_accrued
       OR is_request-calculation_basis = /eacm/if_firr_types=>gc_basis_contract.

      SELECT a~bukrs, b~fkdat, a~vkorg, a~zcdaz,
             a~zamco AS period_yyyymm, a~waerk, a~ziprv AS amount,
             b~vbtyp, a~zclpr, b~kurrf
        FROM /eacm/zprdp AS a
        INNER JOIN /eacm/prdo AS b
          ON  a~vkorg = b~vkorg
          AND a~vtweg = b~vtweg
          AND a~zclpr = b~zclpr
          AND a~vbeln = b~vbeln
          AND a~posnr = b~posnr
          AND a~zcdaz = b~zcdaz
          AND a~zidag = b~zidag
        WHERE a~zstre <> 'D'
          AND a~bukrs = @is_request-company_code
          AND ( @lv_has_vkorg_range = @abap_false OR a~vkorg IN @is_request-vkorg_range )
          AND a~zamco BETWEEN @lv_period_from AND @lv_period_to
        INTO TABLE @DATA(lt_zprdp).

      LOOP AT lt_zprdp INTO DATA(ls_zprdp).
        READ TABLE lt_contracts ASSIGNING <contract>
          WITH TABLE KEY agent = ls_zprdp-zcdaz.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        IF is_request-calculation_basis = /eacm/if_firr_types=>gc_basis_contract
           AND <contract>-prov_type = /eacm/if_firr_types=>gc_basis_invoiced.
          CONTINUE.
        ENDIF.

        READ TABLE lt_agents ASSIGNING <agent>
          WITH TABLE KEY agent = ls_zprdp-zcdaz.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        IF line_exists( lt_excluded_commissions[
             company_code      = ls_zprdp-bukrs
             commission_class = ls_zprdp-zclpr ] ).
          CONTINUE.
        ENDIF.

        lv_firr_currency = lv_company_currency.
        READ TABLE lt_rules ASSIGNING <rule>
          WITH TABLE KEY firr_model = <contract>-firr_model.
        IF sy-subrc = 0 AND <rule>-firr_currency IS NOT INITIAL.
          lv_firr_currency = <rule>-firr_currency.
        ENDIF.

        lv_amount = CONV #( CONV decfloat34( ls_zprdp-amount )
                            * get_document_sign( iv_vbtyp = ls_zprdp-vbtyp ) ).
        lv_conversion_date = COND #( WHEN ls_zprdp-fkdat IS INITIAL
                                     THEN is_period-end_date
                                     ELSE ls_zprdp-fkdat ).
        lv_firr_amount = convert_to_currency(
          iv_amount          = lv_amount
          iv_source_currency = ls_zprdp-waerk
          iv_target_currency = lv_firr_currency
          iv_date            = lv_conversion_date ).
        lv_company_amount = COND #(
          WHEN ls_zprdp-waerk = lv_company_currency THEN lv_amount
          ELSE convert_by_rate( iv_amount = lv_amount
                                iv_rate   = ls_zprdp-kurrf ) ).

        add_firr_row(
          EXPORTING
            is_firr = VALUE #(
              bukrs   = ls_zprdp-bukrs
              vkorg   = ls_zprdp-vkorg
              gjahr   = is_request-fiscal_year
              zcdaz   = ls_zprdp-zcdaz
              lifnr   = <agent>-supplier
              waerk   = lv_firr_currency
              zfpmat  = lv_firr_amount
              ztpmf   = 'M'
              waersc  = lv_company_currency
              zfpmatc = lv_company_amount )
          CHANGING
            ct_firr = ct_firr ).
      ENDLOOP.
    ENDIF.

    IF is_request-calculation_basis = /eacm/if_firr_types=>gc_basis_invoice_dt.
      SELECT a~bukrs, b~fkdat, a~vkorg, a~zcdaz,
             a~zamcf AS period_yyyymm, a~zwaersp AS waerk, a~ziprvvs AS amount,
             b~vbtyp, a~zclpr, b~kurrf
        FROM /eacm/zprdp AS a
        INNER JOIN /eacm/prdo AS b
          ON  a~vkorg = b~vkorg
          AND a~vtweg = b~vtweg
          AND a~zclpr = b~zclpr
          AND a~vbeln = b~vbeln
          AND a~posnr = b~posnr
          AND a~zcdaz = b~zcdaz
          AND a~zidag = b~zidag
        WHERE a~zstre <> 'D'
          AND a~bukrs = @is_request-company_code
          AND ( @lv_has_vkorg_range = @abap_false OR a~vkorg IN @is_request-vkorg_range )
          AND a~zamcf BETWEEN @lv_period_from AND @lv_period_to
        INTO TABLE @DATA(lt_zprdp_fac).

      LOOP AT lt_zprdp_fac INTO DATA(ls_zprdp_fac).
        READ TABLE lt_contracts ASSIGNING <contract>
          WITH TABLE KEY agent = ls_zprdp_fac-zcdaz.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        READ TABLE lt_agents ASSIGNING <agent>
          WITH TABLE KEY agent = ls_zprdp_fac-zcdaz.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        IF line_exists( lt_excluded_commissions[
             company_code      = ls_zprdp_fac-bukrs
             commission_class = ls_zprdp_fac-zclpr ] ).
          CONTINUE.
        ENDIF.

        lv_firr_currency = lv_company_currency.
        READ TABLE lt_rules ASSIGNING <rule>
          WITH TABLE KEY firr_model = <contract>-firr_model.
        IF sy-subrc = 0 AND <rule>-firr_currency IS NOT INITIAL.
          lv_firr_currency = <rule>-firr_currency.
        ENDIF.

        lv_amount = CONV #( CONV decfloat34( ls_zprdp_fac-amount )
                            * get_document_sign( iv_vbtyp = ls_zprdp_fac-vbtyp ) ).
        lv_conversion_date = COND #( WHEN ls_zprdp_fac-fkdat IS INITIAL
                                     THEN is_period-end_date
                                     ELSE ls_zprdp_fac-fkdat ).
        lv_firr_amount = convert_to_currency(
          iv_amount          = lv_amount
          iv_source_currency = ls_zprdp_fac-waerk
          iv_target_currency = lv_firr_currency
          iv_date            = lv_conversion_date ).
        lv_company_amount = COND #(
          WHEN ls_zprdp_fac-waerk = lv_company_currency THEN lv_amount
          ELSE convert_by_rate( iv_amount = lv_amount
                                iv_rate   = ls_zprdp_fac-kurrf ) ).

        add_firr_row(
          EXPORTING
            is_firr = VALUE #(
              bukrs   = ls_zprdp_fac-bukrs
              vkorg   = ls_zprdp_fac-vkorg
              gjahr   = is_request-fiscal_year
              zcdaz   = ls_zprdp_fac-zcdaz
              lifnr   = <agent>-supplier
              waerk   = lv_firr_currency
              zfpmat  = lv_firr_amount
              ztpmf   = 'M'
              waersc  = lv_company_currency
              zfpmatc = lv_company_amount )
          CHANGING
            ct_firr = ct_firr ).
      ENDLOOP.
    ENDIF.

    IF ct_firr IS INITIAL.
      APPEND VALUE #( type = /eacm/if_firr_types=>gc_msg_warning
                      company = is_request-company_code
                      fiscal_year = is_request-fiscal_year
                      text = `Nessun record trovato in /EACM/ZPRDO o /EACM/ZPRDP per il periodo richiesto` ) TO ct_messages.
    ENDIF.
  ENDMETHOD.


  METHOD validate_request.
    IF is_request-periodicity <> /eacm/if_firr_types=>gc_period_monthly
       AND is_request-periodicity <> /eacm/if_firr_types=>gc_period_quarterly
       AND is_request-periodicity <> /eacm/if_firr_types=>gc_period_yearly.
      APPEND VALUE #( type = /eacm/if_firr_types=>gc_msg_error
                      text = `Periodicita FIRR ammessa: M, T, A` ) TO ct_messages.
      RETURN.
    ENDIF.

    DATA(lv_period_number) = CONV i( is_request-period_number ).

    CASE is_request-periodicity.
      WHEN /eacm/if_firr_types=>gc_period_yearly.
        IF lv_period_number <> 0.
          APPEND VALUE #( type = /eacm/if_firr_types=>gc_msg_error
                          text = `Per FIRR annuale il numero periodo deve essere iniziale o 0` ) TO ct_messages.
        ENDIF.
      WHEN /eacm/if_firr_types=>gc_period_quarterly.
        IF lv_period_number < 1 OR lv_period_number > 4.
          APPEND VALUE #( type = /eacm/if_firr_types=>gc_msg_error
                          text = `Per FIRR trimestrale il periodo deve essere compreso tra 1 e 4` ) TO ct_messages.
        ENDIF.
      WHEN /eacm/if_firr_types=>gc_period_monthly.
        IF lv_period_number < 1 OR lv_period_number > 12.
          APPEND VALUE #( type = /eacm/if_firr_types=>gc_msg_error
                          text = `Per FIRR mensile il periodo deve essere compreso tra 1 e 12` ) TO ct_messages.
        ENDIF.
    ENDCASE.

  ENDMETHOD.
ENDCLASS.
