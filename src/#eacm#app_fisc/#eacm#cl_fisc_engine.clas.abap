CLASS /eacm/cl_fisc_engine DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /eacm/if_fisc_types.

    ALIASES ty_request FOR /eacm/if_fisc_types~ty_request.
    ALIASES ty_result  FOR /eacm/if_fisc_types~ty_result.
    ALIASES ty_period  FOR /eacm/if_fisc_types~ty_period.

    METHODS run
      IMPORTING is_request TYPE ty_request
      RETURNING VALUE(rs_result) TYPE ty_result.

    CLASS-METHODS determine_period
      IMPORTING
        iv_fiscal_year   TYPE gjahr
        iv_periodicity   TYPE /eacm/if_fisc_types=>ty_periodicity
        iv_period_number TYPE /eacm/if_fisc_types=>ty_period_number
      RETURNING VALUE(rs_period) TYPE ty_period.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_config,
        company_code       TYPE bukrs,
        currency           TYPE waers,
        periodicity        TYPE /eacm/zpr01-zgfisc,
        calculation_basis  TYPE /eacm/zpr01-zfisctpcal,
        month_rule         TYPE /eacm/zpr01-zmese,
        date_basis         TYPE /eacm/zpr01-zfiscfa,
      END OF ty_config,

      BEGIN OF ty_contract_context,
        agent         TYPE /eacm/zpraa-zcdaz,
        supplier      TYPE lifnr,
        supplier_name TYPE /eacm/zpraa-name1,
        company_code  TYPE bukrs,
        contract_from TYPE /eacm/prcn-zdtin,
        contract_to   TYPE /eacm/prcn-zdtfi,
        mandate_type  TYPE /eacm/prcn-ztman,
        prov_type     TYPE /eacm/prcn-ztprv,
      END OF ty_contract_context,
      tt_contract_context TYPE STANDARD TABLE OF ty_contract_context WITH EMPTY KEY,

      BEGIN OF ty_excluded_commission,
        company_code      TYPE bukrs,
        commission_class TYPE /eacm/zpr08-zclpr,
      END OF ty_excluded_commission,
      tt_excluded_commission TYPE HASHED TABLE OF ty_excluded_commission
        WITH UNIQUE KEY company_code commission_class,

      BEGIN OF ty_fisc_work,
        row   TYPE /eacm/zprfisc,
        zamco TYPE /eacm/zamco,
        fkdat TYPE /eacm/prdo-fkdat,
        ddini TYPE /eacm/prcn-zdtin,
        ddfin TYPE /eacm/prcn-zdtfi,
      END OF ty_fisc_work,
      tt_fisc_work TYPE STANDARD TABLE OF ty_fisc_work WITH EMPTY KEY,

      BEGIN OF ty_supplier_dates,
        supplier TYPE lifnr,
        ddini    TYPE /eacm/prcn-zdtin,
        ddfin    TYPE /eacm/prcn-zdtfi,
      END OF ty_supplier_dates,
      tt_supplier_dates TYPE HASHED TABLE OF ty_supplier_dates WITH UNIQUE KEY supplier,

      BEGIN OF ty_total,
        company_code TYPE bukrs,
        fiscal_year  TYPE gjahr,
        agent        TYPE /eacm/zcdaz,
        amount       TYPE /eacm/zimprv,
        fisc         TYPE /eacm/zfisc,
      END OF ty_total,
      tt_tiers TYPE STANDARD TABLE OF /eacm/zpr26 WITH EMPTY KEY,
      tt_total TYPE HASHED TABLE OF ty_total WITH UNIQUE KEY company_code fiscal_year agent.

    DATA ms_request TYPE ty_request.
    DATA ms_period TYPE ty_period.
    DATA ms_config TYPE ty_config.

    METHODS append_message
      IMPORTING
        iv_type        TYPE symsgty
        iv_text        TYPE string
        iv_company     TYPE bukrs OPTIONAL
        iv_fiscal_year TYPE gjahr OPTIONAL
        iv_vkorg       TYPE vkorg OPTIONAL
        iv_agent       TYPE /eacm/zcdaz OPTIONAL
      CHANGING
        ct_messages    TYPE /eacm/if_fisc_types=>tt_message.

    METHODS validate_required_request
      CHANGING ct_messages TYPE /eacm/if_fisc_types=>tt_message.

    METHODS validate_request
      CHANGING ct_messages TYPE /eacm/if_fisc_types=>tt_message.

    METHODS load_config
      CHANGING ct_messages TYPE /eacm/if_fisc_types=>tt_message.

    METHODS load_contexts
      RETURNING VALUE(rt_contexts) TYPE tt_contract_context.

    METHODS load_excluded_commissions
      RETURNING VALUE(rt_excluded) TYPE tt_excluded_commission.

    METHODS collect_base_amounts
      IMPORTING
        it_contexts TYPE tt_contract_context
        it_excluded TYPE tt_excluded_commission
      CHANGING
        ct_work     TYPE tt_fisc_work
        ct_messages TYPE /eacm/if_fisc_types=>tt_message.

    METHODS add_base_row
      IMPORTING is_work TYPE ty_fisc_work
      CHANGING  ct_work TYPE tt_fisc_work.

    METHODS find_context
      IMPORTING
        iv_agent    TYPE /eacm/zpraa-zcdaz
        it_contexts TYPE tt_contract_context
      RETURNING VALUE(rs_context) TYPE ty_contract_context.

    METHODS is_excluded_commission
      IMPORTING
        iv_company_code      TYPE bukrs
        iv_commission_class TYPE /eacm/zpr08-zclpr
        it_excluded          TYPE tt_excluded_commission
      RETURNING VALUE(rv_excluded) TYPE abap_bool.

    METHODS get_document_sign
      IMPORTING
        iv_vbtyp TYPE /eacm/prdo-vbtyp
      CHANGING
        ct_messages TYPE /eacm/if_fisc_types=>tt_message
      RETURNING VALUE(rv_sign) TYPE decfloat34.

    METHODS convert_by_rate
      IMPORTING
        iv_amount TYPE /eacm/zimprv
        iv_rate   TYPE ukurs_curr
      RETURNING VALUE(rv_amount) TYPE /eacm/zimprv.

    METHODS apply_adjustments
      CHANGING ct_work TYPE tt_fisc_work.

    METHODS build_supplier_dates
      IMPORTING it_work TYPE tt_fisc_work
      RETURNING VALUE(rt_dates) TYPE tt_supplier_dates.

    METHODS calculate_fiscal_rows
      IMPORTING it_work TYPE tt_fisc_work
      CHANGING
        ct_work     TYPE tt_fisc_work
        ct_messages TYPE /eacm/if_fisc_types=>tt_message.

    METHODS get_mandate_type
      IMPORTING
        iv_company_code TYPE bukrs
        iv_agent        TYPE /eacm/zcdaz
      RETURNING VALUE(rv_mandate_type) TYPE /eacm/prcn-ztman.

    METHODS calculate_months
      IMPORTING
        iv_fiscal_year TYPE gjahr
        iv_from        TYPE d
        iv_to          TYPE d
      RETURNING VALUE(rv_months) TYPE /eacm/zmonat.

    METHODS calculate_years
      IMPORTING
        iv_from TYPE d
        iv_to   TYPE d
      RETURNING VALUE(rv_years) TYPE i.

    METHODS load_tiers
      IMPORTING
        iv_company_code TYPE bukrs
        iv_mandate_type TYPE /eacm/prcn-ztman
        iv_fiscal_year  TYPE gjahr
        iv_years        TYPE i
        iv_months       TYPE /eacm/zmonat
      RETURNING VALUE(rt_tiers) TYPE tt_tiers.

    METHODS check_existing_status
      CHANGING
        cs_work     TYPE ty_fisc_work
        ct_messages TYPE /eacm/if_fisc_types=>tt_message
      RETURNING VALUE(rv_ok) TYPE abap_bool.

    METHODS copy_period_fields
      IMPORTING is_existing TYPE /eacm/zprfisc
      CHANGING  cs_fisc     TYPE /eacm/zprfisc.

    METHODS set_previous_periods_hist
      CHANGING cs_fisc TYPE /eacm/zprfisc.

    METHODS apply_period_amounts
      CHANGING cs_work TYPE ty_fisc_work.

    METHODS recalculate_totals
      CHANGING cs_fisc TYPE /eacm/zprfisc.

    METHODS distribute_by_sales_org
      CHANGING ct_work TYPE tt_fisc_work.

ENDCLASS.

CLASS /eacm/cl_fisc_engine IMPLEMENTATION.

  METHOD run.
    CLEAR rs_result.
    CLEAR: ms_request, ms_period, ms_config.

    ms_request = is_request.
    rs_result-preview = xsdbool( ms_request-definitive = abap_false ).

    validate_required_request( CHANGING ct_messages = rs_result-messages ).
    IF line_exists( rs_result-messages[ type = /eacm/if_fisc_types=>gc_msg_error ] ).
      RETURN.
    ENDIF.

    load_config( CHANGING ct_messages = rs_result-messages ).
    IF line_exists( rs_result-messages[ type = /eacm/if_fisc_types=>gc_msg_error ] ).
      RETURN.
    ENDIF.

    validate_request( CHANGING ct_messages = rs_result-messages ).
    IF line_exists( rs_result-messages[ type = /eacm/if_fisc_types=>gc_msg_error ] ).
      RETURN.
    ENDIF.

    ms_period = determine_period(
      iv_fiscal_year   = ms_request-fiscal_year
      iv_periodicity   = ms_request-periodicity
      iv_period_number = ms_request-period_number ).
    rs_result-period = ms_period.

    DATA(lt_contexts) = load_contexts( ).
    IF lt_contexts IS INITIAL.
      append_message(
        EXPORTING
          iv_type        = /eacm/if_fisc_types=>gc_msg_warning
          iv_text        = 'Nessun agente/contratto fiscale trovato per la selezione.'
          iv_company     = ms_request-company_code
          iv_fiscal_year = ms_request-fiscal_year
        CHANGING
          ct_messages    = rs_result-messages ).
      RETURN.
    ENDIF.

    DATA(lt_excluded) = load_excluded_commissions( ).
    DATA lt_work TYPE tt_fisc_work.

    collect_base_amounts(
      EXPORTING
        it_contexts = lt_contexts
        it_excluded = lt_excluded
      CHANGING
        ct_work     = lt_work
        ct_messages = rs_result-messages ).

    IF line_exists( rs_result-messages[ type = /eacm/if_fisc_types=>gc_msg_error ] ).
      RETURN.
    ENDIF.

    IF lt_work IS INITIAL.
      append_message(
        EXPORTING
          iv_type        = /eacm/if_fisc_types=>gc_msg_warning
          iv_text        = 'Nessun record trovato in /EACM/PRDO o /EACM/ZPRDP per il periodo richiesto.'
          iv_company     = ms_request-company_code
          iv_fiscal_year = ms_request-fiscal_year
        CHANGING
          ct_messages    = rs_result-messages ).
      RETURN.
    ENDIF.

    apply_adjustments( CHANGING ct_work = lt_work ).

    DATA lt_checked TYPE tt_fisc_work.
    LOOP AT lt_work INTO DATA(ls_work_to_check).
      IF check_existing_status(
           CHANGING
             cs_work     = ls_work_to_check
             ct_messages = rs_result-messages ) = abap_true.
        APPEND ls_work_to_check TO lt_checked.
      ENDIF.
    ENDLOOP.
    lt_work = lt_checked.

    IF lt_work IS INITIAL.
      RETURN.
    ENDIF.

    calculate_fiscal_rows(
      EXPORTING it_work = lt_work
      CHANGING
        ct_work     = lt_work
        ct_messages = rs_result-messages ).

    LOOP AT lt_work ASSIGNING FIELD-SYMBOL(<work>).
      apply_period_amounts( CHANGING cs_work = <work> ).
    ENDLOOP.

    distribute_by_sales_org( CHANGING ct_work = lt_work ).

    LOOP AT lt_work INTO DATA(ls_final_work).
      APPEND ls_final_work-row TO rs_result-fisc_rows.
    ENDLOOP.

    rs_result-processed_rows = lines( rs_result-fisc_rows ).
    IF ms_request-definitive = abap_true
       AND NOT line_exists( rs_result-messages[ type = /eacm/if_fisc_types=>gc_msg_error ] ).
      rs_result-saved_rows = 0.
    ENDIF.
  ENDMETHOD.

  METHOD determine_period.
    DATA(lv_period_number) = CONV i( iv_period_number ).
    DATA lv_begin_month TYPE n LENGTH 2.
    DATA lv_end_month TYPE n LENGTH 2.

    CASE iv_periodicity.
      WHEN /eacm/if_fisc_types=>gc_period_yearly.
        lv_begin_month = '01'.
        lv_end_month = '12'.
        rs_period-period_field_index = 12.
        rs_period-max_periods = 12.

      WHEN /eacm/if_fisc_types=>gc_period_quarterly.
        lv_begin_month = lv_period_number * 3 - 2.
        lv_end_month = lv_period_number * 3.
        rs_period-period_field_index = lv_period_number.
        rs_period-max_periods = 4.

      WHEN OTHERS.
        lv_begin_month = iv_period_number.
        lv_end_month = iv_period_number.
        rs_period-period_field_index = lv_period_number.
        rs_period-max_periods = 12.
    ENDCASE.

    rs_period-begin_date = CONV d( |{ iv_fiscal_year }{ lv_begin_month }01| ).
    rs_period-end_date = /eacm/cl_last_day_of_month=>get_last_day_of_month(
      iv_gjahr = iv_fiscal_year
      iv_monat = lv_end_month ).
    rs_period-begin_yyyymm = rs_period-begin_date(6).
    rs_period-end_yyyymm = rs_period-end_date(6).
  ENDMETHOD.

  METHOD append_message.
    APPEND VALUE #(
      type        = iv_type
      text        = iv_text
      company     = iv_company
      fiscal_year = iv_fiscal_year
      vkorg       = iv_vkorg
      agent       = iv_agent ) TO ct_messages.
  ENDMETHOD.

  METHOD validate_required_request.
    IF ms_request-company_code IS INITIAL.
      append_message(
        EXPORTING iv_type = /eacm/if_fisc_types=>gc_msg_error
                  iv_text = 'Societa obbligatoria.'
        CHANGING  ct_messages = ct_messages ).
    ENDIF.

    IF ms_request-fiscal_year IS INITIAL.
      append_message(
        EXPORTING iv_type = /eacm/if_fisc_types=>gc_msg_error
                  iv_text = 'Esercizio obbligatorio.'
        CHANGING  ct_messages = ct_messages ).
    ENDIF.
  ENDMETHOD.

  METHOD validate_request.
    DATA(lv_period_number) = CONV i( ms_request-period_number ).

    IF ms_request-periodicity <> /eacm/if_fisc_types=>gc_period_monthly
       AND ms_request-periodicity <> /eacm/if_fisc_types=>gc_period_quarterly
       AND ms_request-periodicity <> /eacm/if_fisc_types=>gc_period_yearly.
      append_message(
        EXPORTING iv_type = /eacm/if_fisc_types=>gc_msg_error
                  iv_text = 'Periodicita fiscale ammessa: M, T o A.'
        CHANGING  ct_messages = ct_messages ).
      RETURN.
    ENDIF.

    IF ms_request-periodicity = /eacm/if_fisc_types=>gc_period_monthly
       AND ( lv_period_number < 1 OR lv_period_number > 12 ).
      append_message(
        EXPORTING iv_type = /eacm/if_fisc_types=>gc_msg_error
                  iv_text = 'Per il calcolo mensile il periodo deve essere compreso tra 1 e 12.'
        CHANGING  ct_messages = ct_messages ).
    ENDIF.

    IF ms_request-periodicity = /eacm/if_fisc_types=>gc_period_quarterly
       AND ( lv_period_number < 1 OR lv_period_number > 4 ).
      append_message(
        EXPORTING iv_type = /eacm/if_fisc_types=>gc_msg_error
                  iv_text = 'Per il calcolo trimestrale il periodo deve essere compreso tra 1 e 4.'
        CHANGING  ct_messages = ct_messages ).
    ENDIF.

    IF ms_request-periodicity = /eacm/if_fisc_types=>gc_period_yearly
       AND lv_period_number <> 0.
      append_message(
        EXPORTING iv_type = /eacm/if_fisc_types=>gc_msg_error
                  iv_text = 'Per il calcolo annuale il periodo deve essere iniziale o 0.'
        CHANGING  ct_messages = ct_messages ).
    ENDIF.

    IF ms_request-calculation_basis <> /eacm/if_fisc_types=>gc_basis_invoiced
       AND ms_request-calculation_basis <> /eacm/if_fisc_types=>gc_basis_invoiced_flat
       AND ms_request-calculation_basis <> /eacm/if_fisc_types=>gc_basis_accrued
       AND ms_request-calculation_basis <> /eacm/if_fisc_types=>gc_basis_contract.
      append_message(
        EXPORTING iv_type = /eacm/if_fisc_types=>gc_msg_error
                  iv_text = 'Base calcolo /EACM/ZPR01-ZFISCTPCAL ammessa: FATT, MAT, FATT1, CON.'
        CHANGING  ct_messages = ct_messages ).
    ENDIF.
  ENDMETHOD.

  METHOD load_config.
    SELECT SINGLE zgfisc, zfisctpcal, zmese, zfiscfa
      FROM /eacm/zpr01
      WHERE bukrs = @ms_request-company_code
      INTO ( @ms_config-periodicity, @ms_config-calculation_basis, @ms_config-month_rule, @ms_config-date_basis ).

    IF sy-subrc <> 0.
      append_message(
        EXPORTING
          iv_type = /eacm/if_fisc_types=>gc_msg_error
          iv_text = 'Configurazione fiscale societa non trovata in /EACM/ZPR01.'
          iv_company = ms_request-company_code
        CHANGING ct_messages = ct_messages ).
      RETURN.
    ENDIF.

    ms_request-periodicity = ms_config-periodicity.
    ms_request-calculation_basis = ms_config-calculation_basis.

    IF ms_config-periodicity IS INITIAL.
      append_message(
        EXPORTING
          iv_type = /eacm/if_fisc_types=>gc_msg_error
          iv_text = |Periodicita fiscale non configurata per la societa { ms_request-company_code } in /EACM/ZPR01-ZGFISC.|
          iv_company = ms_request-company_code
        CHANGING ct_messages = ct_messages ).
    ENDIF.

*    SELECT SINGLE currency
*      FROM /eacm/i_company
*      WHERE SapCompanyCode = @ms_request-company_code
*      INTO @ms_config-currency.
    SELECT SINGLE waers
      FROM /eacm/t001
      WHERE bukrs = @ms_request-company_code
      INTO @ms_config-currency.

    IF sy-subrc <> 0 OR ms_config-currency IS INITIAL.
      ms_config-currency = 'EUR'.
    ENDIF.

    ms_config-company_code = ms_request-company_code.
  ENDMETHOD.

  METHOD load_contexts.
    DATA lv_has_agent_range TYPE abap_bool.
    lv_has_agent_range = xsdbool( ms_request-agent_range IS NOT INITIAL ).

    SELECT zcdaz AS agent,
           lifnr AS supplier,
           name1 AS supplier_name,
           erdat
      FROM /eacm/zpraa
      WHERE zstre <> 'A'
        AND ( @lv_has_agent_range = @abap_false OR zcdaz IN @ms_request-agent_range )
      ORDER BY zcdaz ASCENDING, erdat DESCENDING
      INTO TABLE @DATA(lt_agents_raw).

    DELETE ADJACENT DUPLICATES FROM lt_agents_raw COMPARING agent.
    CHECK lt_agents_raw IS NOT INITIAL.

    DATA(lv_year_begin) = CONV d( |{ ms_request-fiscal_year }0101| ).

    SELECT zcdaz AS agent, "#EC CI_NO_TRANSFORM
           bukrs AS company_code,
           zdtin AS contract_from,
           zdtfi AS contract_to,
           ztman AS mandate_type,
           ztprv AS prov_type
      FROM /eacm/prcn
      FOR ALL ENTRIES IN @lt_agents_raw
      WHERE zcdaz = @lt_agents_raw-agent
        AND bukrs = @ms_request-company_code
        AND zstre <> 'A'
        AND zstre <> 'D'
        AND zsind = @abap_true
        AND zdtin < @ms_period-end_date
        AND ( zdtfi >= @lv_year_begin OR zdtfi = '00000000' )
      INTO TABLE @DATA(lt_contracts).

    SORT lt_contracts BY agent ASCENDING contract_from DESCENDING.

    LOOP AT lt_contracts INTO DATA(ls_contract).
      READ TABLE lt_agents_raw INTO DATA(ls_agent)
        WITH KEY agent = ls_contract-agent.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      DATA(ls_context) = VALUE ty_contract_context(
        agent         = ls_contract-agent
        supplier      = ls_agent-supplier
        supplier_name = ls_agent-supplier_name
        company_code  = ls_contract-company_code
        contract_from = ls_contract-contract_from
        contract_to   = COND #( WHEN ls_contract-contract_to IS INITIAL
                                   OR ls_contract-contract_to > ms_period-end_date
                                 THEN ms_period-end_date
                                 ELSE ls_contract-contract_to )
        mandate_type  = ls_contract-mandate_type
        prov_type     = ls_contract-prov_type ).

      APPEND ls_context TO rt_contexts.
    ENDLOOP.

    SORT rt_contexts BY agent ASCENDING contract_from DESCENDING.
    DELETE ADJACENT DUPLICATES FROM rt_contexts COMPARING agent.
  ENDMETHOD.

  METHOD load_excluded_commissions.
    SELECT bukrs AS company_code,
           zclpr AS commission_class
      FROM /eacm/zpr08
      WHERE bukrs = @ms_request-company_code
        AND ( zcaan = @abap_true OR zesfisc = @abap_true )
      INTO TABLE @DATA(lt_excluded).

    LOOP AT lt_excluded INTO DATA(ls_excluded).
      INSERT ls_excluded INTO TABLE rt_excluded.
    ENDLOOP.
  ENDMETHOD.

  METHOD collect_base_amounts.
    DATA lv_has_vkorg_range TYPE abap_bool.
    lv_has_vkorg_range = xsdbool( ms_request-vkorg_range IS NOT INITIAL ).

    IF ms_request-calculation_basis = /eacm/if_fisc_types=>gc_basis_invoiced
       OR ms_request-calculation_basis = /eacm/if_fisc_types=>gc_basis_invoiced_flat
       OR ms_request-calculation_basis = /eacm/if_fisc_types=>gc_basis_contract.

      SELECT bukrs, vkorg, zcdaz, waerk, zimco AS amount,
             vbtyp, zclpr AS commission_class, kurrf, fkdat
        FROM /eacm/prdo
        WHERE zstre <> 'D'
          AND bukrs = @ms_request-company_code
          AND ( @lv_has_vkorg_range = @abap_false OR vkorg IN @ms_request-vkorg_range )
          AND zclpr <> 'PRV-SBF'
          AND fkdat BETWEEN @ms_period-begin_date AND @ms_period-end_date
        INTO TABLE @DATA(lt_prdo).

      LOOP AT lt_prdo INTO DATA(ls_prdo).
        DATA(ls_context) = find_context(
          iv_agent    = ls_prdo-zcdaz
          it_contexts = it_contexts ).
        IF ls_context-agent IS INITIAL.
          CONTINUE.
        ENDIF.

        IF ms_request-calculation_basis = /eacm/if_fisc_types=>gc_basis_contract
           AND ls_context-prov_type <> /eacm/if_fisc_types=>gc_basis_invoiced.
          CONTINUE.
        ENDIF.

        IF is_excluded_commission(
             iv_company_code      = ls_prdo-bukrs
             iv_commission_class = ls_prdo-commission_class
             it_excluded          = it_excluded ) = abap_true.
          CONTINUE.
        ENDIF.

        DATA(lv_amount) = CONV /eacm/zimprv(
          CONV decfloat34( ls_prdo-amount )
          * get_document_sign(
              EXPORTING iv_vbtyp = ls_prdo-vbtyp
              CHANGING  ct_messages = ct_messages ) ).

        IF ls_prdo-waerk <> ms_config-currency.
          lv_amount = convert_by_rate(
            iv_amount = lv_amount
            iv_rate   = ls_prdo-kurrf ).
        ENDIF.

        add_base_row(
          EXPORTING
            is_work = VALUE #(
              row = VALUE #(
                bukrs  = ls_prdo-bukrs
                vkorg  = ls_prdo-vkorg
                gjahr  = ms_request-fiscal_year
                zcdaz  = ls_prdo-zcdaz
                lifnr  = ls_context-supplier
                waerk  = ms_config-currency
                zimprv = lv_amount
                ztpmf  = 'F' )
              fkdat = ls_prdo-fkdat
              ddini = ls_context-contract_from
              ddfin = ls_context-contract_to )
          CHANGING
            ct_work = ct_work ).
      ENDLOOP.
    ENDIF.

    IF ms_request-calculation_basis = /eacm/if_fisc_types=>gc_basis_accrued
       OR ms_request-calculation_basis = /eacm/if_fisc_types=>gc_basis_contract.

      SELECT a~bukrs, a~vkorg, a~zcdaz, a~zamco, a~waerk, a~ziprv AS amount,
             b~vbtyp, a~zclpr AS commission_class, b~kurrf
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
          AND a~bukrs = @ms_request-company_code
          AND ( @lv_has_vkorg_range = @abap_false OR a~vkorg IN @ms_request-vkorg_range )
          AND a~zclpr <> 'PRV-SBF'
          AND a~zamco BETWEEN @ms_period-begin_yyyymm AND @ms_period-end_yyyymm
        INTO TABLE @DATA(lt_zprdp).

      LOOP AT lt_zprdp INTO DATA(ls_zprdp).
        ls_context = find_context(
          iv_agent    = ls_zprdp-zcdaz
          it_contexts = it_contexts ).
        IF ls_context-agent IS INITIAL.
          CONTINUE.
        ENDIF.

        IF ms_request-calculation_basis = /eacm/if_fisc_types=>gc_basis_contract
           AND ls_context-prov_type = /eacm/if_fisc_types=>gc_basis_invoiced.
          CONTINUE.
        ENDIF.

        IF is_excluded_commission(
             iv_company_code      = ls_zprdp-bukrs
             iv_commission_class = ls_zprdp-commission_class
             it_excluded          = it_excluded ) = abap_true.
          CONTINUE.
        ENDIF.

        lv_amount = CONV /eacm/zimprv(
          CONV decfloat34( ls_zprdp-amount )
          * get_document_sign(
              EXPORTING iv_vbtyp = ls_zprdp-vbtyp
              CHANGING  ct_messages = ct_messages ) ).

        IF ls_zprdp-waerk <> ms_config-currency.
          lv_amount = convert_by_rate(
            iv_amount = lv_amount
            iv_rate   = ls_zprdp-kurrf ).
        ENDIF.

        add_base_row(
          EXPORTING
            is_work = VALUE #(
              row = VALUE #(
                bukrs  = ls_zprdp-bukrs
                vkorg  = ls_zprdp-vkorg
                gjahr  = ms_request-fiscal_year
                zcdaz  = ls_zprdp-zcdaz
                lifnr  = ls_context-supplier
                waerk  = ms_config-currency
                zimprv = lv_amount
                ztpmf  = 'M' )
              zamco = ls_zprdp-zamco
              ddini = ls_context-contract_from
              ddfin = ls_context-contract_to )
          CHANGING
            ct_work = ct_work ).
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD add_base_row.
    READ TABLE ct_work ASSIGNING FIELD-SYMBOL(<work>)
      WITH KEY row-bukrs = is_work-row-bukrs
               row-vkorg = is_work-row-vkorg
               row-gjahr = is_work-row-gjahr
               row-zcdaz = is_work-row-zcdaz
               row-lifnr = is_work-row-lifnr
               row-waerk = is_work-row-waerk
               row-ztpmf = is_work-row-ztpmf
               zamco     = is_work-zamco
               fkdat     = is_work-fkdat
               ddini     = is_work-ddini
               ddfin     = is_work-ddfin.

    IF sy-subrc = 0.
      <work>-row-zimprv += is_work-row-zimprv.
    ELSE.
      APPEND is_work TO ct_work.
    ENDIF.
  ENDMETHOD.

  METHOD find_context.
    READ TABLE it_contexts INTO rs_context
      WITH KEY agent = iv_agent.
  ENDMETHOD.

  METHOD is_excluded_commission.
    rv_excluded = xsdbool( line_exists( it_excluded[
      company_code = iv_company_code
      commission_class = iv_commission_class ] ) ).
  ENDMETHOD.

  METHOD get_document_sign.
    rv_sign = 1.

    IF iv_vbtyp IS INITIAL.
      append_message(
        EXPORTING
          iv_type = /eacm/if_fisc_types=>gc_msg_error
          iv_text = 'Tipo documento vuoto durante il calcolo fiscale.'
        CHANGING ct_messages = ct_messages ).
      RETURN.
    ENDIF.

    SELECT SINGLE zsegn
      FROM /eacm/zpr48
      WHERE vbtyp = @iv_vbtyp
      INTO @DATA(lv_sign).

    IF sy-subrc = 0 AND lv_sign IS NOT INITIAL.
      rv_sign = CONV decfloat34( lv_sign ).
    ELSE.
      append_message(
        EXPORTING
          iv_type = /eacm/if_fisc_types=>gc_msg_error
          iv_text = |Segno documento non configurato in /EACM/ZPR48 per VBTYP { iv_vbtyp }.|
        CHANGING ct_messages = ct_messages ).
    ENDIF.
  ENDMETHOD.

  METHOD convert_by_rate.
    DATA(lv_rate) = iv_rate.
    rv_amount = iv_amount.

    IF lv_rate IS INITIAL.
      RETURN.
    ENDIF.

    IF lv_rate > 0.
      rv_amount = iv_amount * lv_rate.
    ELSE.
      lv_rate *= -1.
      rv_amount = iv_amount / lv_rate.
    ENDIF.
  ENDMETHOD.

  METHOD apply_adjustments.
    LOOP AT ct_work ASSIGNING FIELD-SYMBOL(<work>).
      SELECT SINGLE fisc  "#EC WARNOK
        FROM /eacm/zprindrett
        WHERE bukrs = @<work>-row-bukrs
          AND gjahr = @<work>-row-gjahr
          AND zcdaz = @<work>-row-zcdaz
        INTO @DATA(lv_adjustment).

      IF sy-subrc = 0.
        <work>-row-zimprv += lv_adjustment.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD build_supplier_dates.
    LOOP AT it_work INTO DATA(ls_work).
      READ TABLE rt_dates ASSIGNING FIELD-SYMBOL(<dates>)
        WITH TABLE KEY supplier = ls_work-row-lifnr.

      IF sy-subrc <> 0.
        INSERT VALUE #(
          supplier = ls_work-row-lifnr
          ddini    = ls_work-ddini
          ddfin    = COND #( WHEN ls_work-ddfin IS INITIAL THEN ms_period-end_date ELSE ls_work-ddfin ) )
          INTO TABLE rt_dates.
        CONTINUE.
      ENDIF.

      IF ls_work-ddini < <dates>-ddini OR <dates>-ddini IS INITIAL.
        <dates>-ddini = ls_work-ddini.
      ENDIF.

      IF ls_work-ddfin < <dates>-ddfin OR <dates>-ddfin IS INITIAL.
        <dates>-ddfin = ls_work-ddfin.
      ENDIF.

      IF <dates>-ddfin IS INITIAL OR <dates>-ddfin > ms_period-end_date.
        <dates>-ddfin = ms_period-end_date.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD calculate_fiscal_rows.
    DATA lt_result TYPE tt_fisc_work.
    DATA(lt_supplier_dates) = build_supplier_dates( it_work ).

    DATA lv_break_key TYPE string.
    DATA lv_prev_break_key TYPE string.
    DATA lv_months TYPE /eacm/zmonat.
    DATA lv_years TYPE i.
    DATA lv_threshold TYPE /eacm/zpr26-zscaf.
    DATA lv_idx TYPE i.
    DATA lt_tiers TYPE tt_tiers.
    DATA ls_tier TYPE /eacm/zpr26.

    DATA lt_sorted TYPE tt_fisc_work.
    lt_sorted = it_work.

    IF ms_config-date_basis = 'V'.
      SORT lt_sorted BY row-lifnr row-zcdaz row-vkorg.
    ELSE.
      SORT lt_sorted BY row-zcdaz row-lifnr row-vkorg.
    ENDIF.

    LOOP AT lt_sorted INTO DATA(ls_work).
      lv_break_key = COND string(
        WHEN ms_config-date_basis = 'V' THEN |{ ls_work-row-lifnr }|
        ELSE |{ ls_work-row-zcdaz }| ).

      IF lv_break_key <> lv_prev_break_key.
        DATA(lv_from) = ls_work-ddini.
        DATA(lv_to) = COND d( WHEN ls_work-ddfin IS INITIAL THEN ms_period-end_date ELSE ls_work-ddfin ).

        IF ms_config-date_basis = 'V'.
          READ TABLE lt_supplier_dates INTO DATA(ls_supplier_dates)
            WITH TABLE KEY supplier = ls_work-row-lifnr.
          IF sy-subrc = 0.
            lv_from = ls_supplier_dates-ddini.
            lv_to = ls_supplier_dates-ddfin.
          ENDIF.
        ENDIF.

        lv_months = calculate_months(
          iv_fiscal_year = ls_work-row-gjahr
          iv_from        = lv_from
          iv_to          = lv_to ).

        lv_years = calculate_years(
          iv_from = lv_from
          iv_to   = lv_to ).

        DATA(lv_mandate_type) = get_mandate_type(
          iv_company_code = ls_work-row-bukrs
          iv_agent        = ls_work-row-zcdaz ).

        lt_tiers = load_tiers(
          iv_company_code = ls_work-row-bukrs
          iv_mandate_type = lv_mandate_type
          iv_fiscal_year  = ls_work-row-gjahr
          iv_years        = lv_years
          iv_months       = lv_months ).

        IF lt_tiers IS INITIAL.
          append_message(
            EXPORTING
              iv_type        = /eacm/if_fisc_types=>gc_msg_warning
              iv_text        = |Scaglioni /EACM/ZPR26 non trovati per agente { ls_work-row-zcdaz }.|
              iv_company     = ls_work-row-bukrs
              iv_fiscal_year = ls_work-row-gjahr
              iv_vkorg       = ls_work-row-vkorg
              iv_agent       = ls_work-row-zcdaz
            CHANGING
              ct_messages    = ct_messages ).
          CONTINUE.
        ENDIF.

        lv_idx = 1.
        READ TABLE lt_tiers INTO ls_tier INDEX lv_idx.
        lv_threshold = ls_tier-zscaf - ls_tier-zscai.
        lv_prev_break_key = lv_break_key.
      ENDIF.

      IF lv_threshold = 0.
        CONTINUE.
      ENDIF.

      DATA(lv_remaining) = ls_work-row-zimprv.
      DATA(lv_negative) = xsdbool( lv_remaining < 0 ).
      IF lv_negative = abap_true.
        lv_remaining = abs( lv_remaining ).
      ENDIF.

      WHILE lv_remaining > 0 AND ls_tier IS NOT INITIAL.
        DATA(ls_split) = ls_work.
        DATA(lv_take) = COND /eacm/zimprv(
          WHEN lv_remaining <= lv_threshold THEN lv_remaining
          ELSE lv_threshold ).

        ls_split-row-zimprv = lv_take.
        ls_split-row-zfisc = lv_take * ls_tier-zper1 / 100.
        ls_split-row-zper1 = ls_tier-zper1.
        ls_split-row-mesi = lv_months.

        IF lv_negative = abap_true.
          ls_split-row-zimprv *= -1.
          ls_split-row-zfisc *= -1.
          lv_threshold += lv_take.
        ELSE.
          lv_threshold -= lv_take.
        ENDIF.

        APPEND ls_split TO lt_result.
        lv_remaining -= lv_take.

        IF lv_remaining > 0 AND lv_threshold <= 0.
          lv_idx += 1.
          CLEAR ls_tier.
          READ TABLE lt_tiers INTO ls_tier INDEX lv_idx.
          IF sy-subrc = 0.
            lv_threshold = ls_tier-zscaf - ls_tier-zscai.
          ENDIF.
        ENDIF.
      ENDWHILE.
    ENDLOOP.

    ct_work = lt_result.
  ENDMETHOD.

  METHOD get_mandate_type.
    SELECT SINGLE ztman  "#EC WARNOK
      FROM /eacm/prcn
      WHERE bukrs = @iv_company_code
        AND zcdaz = @iv_agent
        AND zstre <> 'A'
        AND zstre <> 'D'
        AND zsind = @abap_true
      INTO @rv_mandate_type.
  ENDMETHOD.

  METHOD calculate_months.
    DATA lv_from TYPE d.
    DATA lv_to TYPE d.
    DATA lv_months TYPE i.
    DATA lv_delta TYPE i.
    DATA(lv_year_begin) = CONV d( |{ iv_fiscal_year }0101| ).
    DATA(lv_year_end) = CONV d( |{ iv_fiscal_year }1231| ).

    lv_from = COND #( WHEN iv_from IS INITIAL OR iv_from < lv_year_begin THEN lv_year_begin ELSE iv_from ).
    lv_to = COND #( WHEN iv_to IS INITIAL OR iv_to > lv_year_end THEN lv_year_end ELSE iv_to ).

    IF lv_to > ms_period-end_date.
      lv_to = ms_period-end_date.
    ENDIF.

    lv_delta = 0.
    IF ms_config-month_rule = abap_true AND lv_from+6(2) > '15'.
      lv_delta -= 1.
    ENDIF.

    IF ms_config-month_rule = abap_true AND lv_to+6(2) <= '15'.
      lv_delta -= 1.
    ENDIF.

    lv_months = CONV i( lv_to+4(2) ) - CONV i( lv_from+4(2) ) + 1 + lv_delta.
    IF lv_months < 1.
      lv_months = 1.
    ENDIF.

    IF lv_months > CONV i( ms_period-end_date+4(2) ).
      lv_months = CONV i( ms_period-end_date+4(2) ).
    ENDIF.

    rv_months = lv_months.
  ENDMETHOD.

  METHOD calculate_years.
    DATA lv_to TYPE d.
    DATA lv_years_dec TYPE p LENGTH 15 DECIMALS 5.

    lv_to = COND #( WHEN iv_to IS INITIAL OR iv_to > ms_period-end_date THEN ms_period-end_date ELSE iv_to ).
    IF iv_from IS INITIAL OR lv_to IS INITIAL OR lv_to < iv_from.
      rv_years = 1.
      RETURN.
    ENDIF.

    lv_years_dec = ( lv_to - iv_from ) / 365.
    rv_years = floor( lv_years_dec ).

    IF rv_years = 0.
      rv_years = 1.
    ELSEIF lv_years_dec > rv_years.
      rv_years += 1.
    ENDIF.
  ENDMETHOD.

  METHOD load_tiers.
    SELECT *
      FROM /eacm/zpr26
      WHERE bukrs = @iv_company_code
        AND ztcon = 'IS'
        AND ztman = @iv_mandate_type
        AND ztyear >= @iv_fiscal_year
        AND zfmyear <= @iv_fiscal_year
        AND zanin <= @iv_years
        AND zanfi >= @iv_years
      INTO TABLE @rt_tiers.

    LOOP AT rt_tiers ASSIGNING FIELD-SYMBOL(<tier>).
      <tier>-zscai = <tier>-zscai / 12 * iv_months.
      <tier>-zscaf = <tier>-zscaf / 12 * iv_months.
    ENDLOOP.

    SORT rt_tiers BY zprogress.
  ENDMETHOD.

  METHOD check_existing_status.
    rv_ok = abap_true.

    SELECT SINGLE * "#EC CI_ALL_FIELDS_NEEDED
      FROM /eacm/zprfisc
      WHERE bukrs = @cs_work-row-bukrs
        AND vkorg = @cs_work-row-vkorg
        AND gjahr = @cs_work-row-gjahr
        AND zcdaz = @cs_work-row-zcdaz
      INTO @DATA(ls_existing).

    IF sy-subrc <> 0.
      IF ms_request-definitive = abap_true AND ms_period-period_field_index > 1.
        set_previous_periods_hist( CHANGING cs_fisc = cs_work-row ).
      ENDIF.
      RETURN.
    ENDIF.

    copy_period_fields(
      EXPORTING is_existing = ls_existing
      CHANGING  cs_fisc     = cs_work-row ).

    IF cs_work-row-ztpmf <> ls_existing-ztpmf AND ls_existing-ztprc_1 = /eacm/if_fisc_types=>gc_status_historized.
      append_message(
        EXPORTING
          iv_type        = /eacm/if_fisc_types=>gc_msg_error
          iv_text        = |Tipo calcolo diverso da quello gia storicizzato per agente { cs_work-row-zcdaz }.|
          iv_company     = cs_work-row-bukrs
          iv_fiscal_year = cs_work-row-gjahr
          iv_vkorg       = cs_work-row-vkorg
          iv_agent       = cs_work-row-zcdaz
        CHANGING
          ct_messages    = ct_messages ).
      rv_ok = abap_false.
      RETURN.
    ENDIF.

    FIELD-SYMBOLS:
      <status> TYPE any,
      <amount> TYPE any.

    DATA(lv_idx_text) = CONV string( ms_period-period_field_index ).
    ASSIGN COMPONENT |ZTPRC_{ lv_idx_text }| OF STRUCTURE ls_existing TO <status>.
    IF <status> IS ASSIGNED AND <status> = /eacm/if_fisc_types=>gc_status_historized.
      append_message(
        EXPORTING
          iv_type        = /eacm/if_fisc_types=>gc_msg_error
          iv_text        = |Periodo { ms_period-period_field_index } gia storicizzato per agente { cs_work-row-zcdaz }.|
          iv_company     = cs_work-row-bukrs
          iv_fiscal_year = cs_work-row-gjahr
          iv_vkorg       = cs_work-row-vkorg
          iv_agent       = cs_work-row-zcdaz
        CHANGING
          ct_messages    = ct_messages ).
      rv_ok = abap_false.
      RETURN.
    ENDIF.

    DATA(lv_previous) = ms_period-period_field_index - 1.
    WHILE lv_previous > 0.
      lv_idx_text = CONV string( lv_previous ).
      UNASSIGN: <status>, <amount>.
      ASSIGN COMPONENT |ZTPRC_{ lv_idx_text }| OF STRUCTURE ls_existing TO <status>.
      ASSIGN COMPONENT |ZIMPRV_{ lv_idx_text }| OF STRUCTURE ls_existing TO <amount>.
      IF <status> IS ASSIGNED AND <amount> IS ASSIGNED
         AND <status> = /eacm/if_fisc_types=>gc_status_calculated
         AND <amount> IS NOT INITIAL.
        append_message(
          EXPORTING
            iv_type        = /eacm/if_fisc_types=>gc_msg_error
            iv_text        = |Periodo precedente { lv_previous } calcolato ma non storicizzato per agente { cs_work-row-zcdaz }.|
            iv_company     = cs_work-row-bukrs
            iv_fiscal_year = cs_work-row-gjahr
            iv_vkorg       = cs_work-row-vkorg
            iv_agent       = cs_work-row-zcdaz
          CHANGING
            ct_messages    = ct_messages ).
        rv_ok = abap_false.
        RETURN.
      ENDIF.
      lv_previous -= 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD copy_period_fields.
    FIELD-SYMBOLS:
      <src> TYPE any,
      <dst> TYPE any.

    DO ms_period-max_periods TIMES.
      DATA(lv_idx) = CONV string( sy-index ).

      UNASSIGN: <src>, <dst>.
      ASSIGN COMPONENT |ZIMPRV_{ lv_idx }| OF STRUCTURE is_existing TO <src>.
      ASSIGN COMPONENT |ZIMPRV_{ lv_idx }| OF STRUCTURE cs_fisc TO <dst>.
      IF <src> IS ASSIGNED AND <dst> IS ASSIGNED.
        <dst> = <src>.
      ENDIF.

      UNASSIGN: <src>, <dst>.
      ASSIGN COMPONENT |ZFISC_{ lv_idx }| OF STRUCTURE is_existing TO <src>.
      ASSIGN COMPONENT |ZFISC_{ lv_idx }| OF STRUCTURE cs_fisc TO <dst>.
      IF <src> IS ASSIGNED AND <dst> IS ASSIGNED.
        <dst> = <src>.
      ENDIF.

      UNASSIGN: <src>, <dst>.
      ASSIGN COMPONENT |ZTPRC_{ lv_idx }| OF STRUCTURE is_existing TO <src>.
      ASSIGN COMPONENT |ZTPRC_{ lv_idx }| OF STRUCTURE cs_fisc TO <dst>.
      IF <src> IS ASSIGNED AND <dst> IS ASSIGNED.
        <dst> = <src>.
      ENDIF.

      UNASSIGN: <src>, <dst>.
      ASSIGN COMPONENT |ZPER{ lv_idx }| OF STRUCTURE is_existing TO <src>.
      ASSIGN COMPONENT |ZPER{ lv_idx }| OF STRUCTURE cs_fisc TO <dst>.
      IF <src> IS ASSIGNED AND <dst> IS ASSIGNED.
        <dst> = <src>.
      ENDIF.
    ENDDO.
  ENDMETHOD.

  METHOD set_previous_periods_hist.
    FIELD-SYMBOLS <status> TYPE any.

    DATA(lv_previous) = ms_period-period_field_index - 1.
    WHILE lv_previous > 0.
      DATA(lv_idx) = CONV string( lv_previous ).
      ASSIGN COMPONENT |ZTPRC_{ lv_idx }| OF STRUCTURE cs_fisc TO <status>.
      IF <status> IS ASSIGNED.
        <status> = /eacm/if_fisc_types=>gc_status_historized.
      ENDIF.
      UNASSIGN <status>.
      lv_previous -= 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD apply_period_amounts.
    FIELD-SYMBOLS:
      <amount> TYPE any,
      <fisc>   TYPE any,
      <status> TYPE any,
      <percent> TYPE any.

    cs_work-row-ztprc = COND #( WHEN ms_request-definitive = abap_true
                                THEN /eacm/if_fisc_types=>gc_status_calculated
                                ELSE space ).

    DATA(lv_idx) = CONV string( ms_period-period_field_index ).

    ASSIGN COMPONENT |ZIMPRV_{ lv_idx }| OF STRUCTURE cs_work-row TO <amount>.
    IF <amount> IS ASSIGNED.
      <amount> = cs_work-row-zimprv.
    ENDIF.

    ASSIGN COMPONENT |ZFISC_{ lv_idx }| OF STRUCTURE cs_work-row TO <fisc>.
    IF <fisc> IS ASSIGNED.
      <fisc> = cs_work-row-zfisc.
    ENDIF.

    ASSIGN COMPONENT |ZTPRC_{ lv_idx }| OF STRUCTURE cs_work-row TO <status>.
    IF <status> IS ASSIGNED.
      <status> = cs_work-row-ztprc.
    ENDIF.

    ASSIGN COMPONENT |ZPER{ lv_idx }| OF STRUCTURE cs_work-row TO <percent>.
    IF <percent> IS ASSIGNED.
      <percent> = cs_work-row-zper1.
    ENDIF.

    recalculate_totals( CHANGING cs_fisc = cs_work-row ).
  ENDMETHOD.

  METHOD recalculate_totals.
    FIELD-SYMBOLS:
      <amount> TYPE any,
      <fisc>   TYPE any.

    CLEAR: cs_fisc-zimprv, cs_fisc-zfisc.

    DO ms_period-max_periods TIMES.
      DATA(lv_idx) = CONV string( sy-index ).

      ASSIGN COMPONENT |ZIMPRV_{ lv_idx }| OF STRUCTURE cs_fisc TO <amount>.
      IF <amount> IS ASSIGNED.
        cs_fisc-zimprv += <amount>.
      ENDIF.
      UNASSIGN <amount>.

      ASSIGN COMPONENT |ZFISC_{ lv_idx }| OF STRUCTURE cs_fisc TO <fisc>.
      IF <fisc> IS ASSIGNED.
        cs_fisc-zfisc += <fisc>.
      ENDIF.
      UNASSIGN <fisc>.
    ENDDO.
  ENDMETHOD.

  METHOD distribute_by_sales_org.
    DATA lt_totals TYPE tt_total.

    LOOP AT ct_work INTO DATA(ls_work).
      COLLECT VALUE ty_total(
        company_code = ls_work-row-bukrs
        fiscal_year  = ls_work-row-gjahr
        agent        = ls_work-row-zcdaz
        amount       = ls_work-row-zimprv
        fisc         = ls_work-row-zfisc ) INTO lt_totals.
    ENDLOOP.

    LOOP AT ct_work ASSIGNING FIELD-SYMBOL(<work>).
      READ TABLE lt_totals INTO DATA(ls_total)
        WITH TABLE KEY company_code = <work>-row-bukrs
                       fiscal_year  = <work>-row-gjahr
                       agent        = <work>-row-zcdaz.
      IF sy-subrc <> 0 OR ls_total-amount IS INITIAL.
        CONTINUE.
      ENDIF.

      <work>-row-zfisc = <work>-row-zimprv * ( ls_total-fisc / ls_total-amount ).

      FIELD-SYMBOLS:
        <current_fisc> TYPE any,
        <previous_fisc> TYPE any.

      DATA(lv_idx) = CONV string( ms_period-period_field_index ).
      ASSIGN COMPONENT |ZFISC_{ lv_idx }| OF STRUCTURE <work>-row TO <current_fisc>.
      IF <current_fisc> IS ASSIGNED.
        <current_fisc> = <work>-row-zfisc.

        DATA(lv_previous) = ms_period-period_field_index - 1.
        WHILE lv_previous > 0.
          DATA(lv_previous_idx) = CONV string( lv_previous ).
          ASSIGN COMPONENT |ZFISC_{ lv_previous_idx }| OF STRUCTURE <work>-row TO <previous_fisc>.
          IF <previous_fisc> IS ASSIGNED.
            <current_fisc> -= <previous_fisc>.
          ENDIF.
          UNASSIGN <previous_fisc>.
          lv_previous -= 1.
        ENDWHILE.
      ENDIF.

      recalculate_totals( CHANGING cs_fisc = <work>-row ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

