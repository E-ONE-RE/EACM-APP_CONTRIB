CLASS /eacm/cl_eacm_zprfirr_posting DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_selection,
        bukrs    TYPE bukrs,
        gjahr    TYPE gjahr,
        bldat    TYPE budat,
        budat    TYPE budat,
        blart    TYPE blart,
        zcdaz    TYPE /eacm/zcdaz,
        ztpag    TYPE /eacm/ztpag,
        pa_fratt TYPE /eacm/zpr43-zfratt,
        p_zuonr  TYPE c LENGTH 18,
        kokrs    TYPE kokrs,
        pa_test  TYPE abap_bool,
      END OF ty_selection,
      tt_message_detail TYPE /eacm/cl_eacm_journal_post_api=>tt_message_detail,
      BEGIN OF ty_post_result,
        bukrs               TYPE bukrs,
        gjahr               TYPE gjahr,
        vkorg               TYPE vkorg,
        zcdaz               TYPE /eacm/zcdaz,
        lifnr               TYPE lifnr,
        ztpag               TYPE /eacm/ztpag,
        period_num          TYPE i,
        period_id           TYPE c LENGTH 2,
        status_field        TYPE string,
        total_status_field  TYPE string,
        external_reference  TYPE c LENGTH 16,
        accounting_document TYPE c LENGTH 10,
        fiscal_year         TYPE c LENGTH 4,
        skipped             TYPE abap_bool,
        success             TYPE abap_bool,
        processing_status   TYPE c LENGTH 1,
        message_text        TYPE string,
        message_details     TYPE tt_message_detail,
      END OF ty_post_result,
      tt_post_result TYPE STANDARD TABLE OF ty_post_result WITH DEFAULT KEY.

    METHODS execute
      IMPORTING
        is_selection     TYPE ty_selection
      RETURNING
        VALUE(rt_result) TYPE tt_post_result
      RAISING
        /eacm/cx_eacm_posting
        cx_http_dest_provider_error
        cx_web_http_client_error.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_period_info,
        found          TYPE abap_bool,
        is_annual      TYPE abap_bool,
        period_num     TYPE i,
        period_id      TYPE c LENGTH 2,
        period_counter TYPE i,
        amount_field   TYPE string,
        status_field   TYPE string,
        maturity_field TYPE string,
      END OF ty_period_info,
      BEGIN OF ty_agent_context,
        zpraa     TYPE /eacm/zpraa,
        zpr28     TYPE /eacm/zpr28,
        zpr41     TYPE /eacm/zpr41,
        has_zpraa TYPE abap_bool,
        has_zpr28 TYPE abap_bool,
        has_zpr41 TYPE abap_bool,
      END OF ty_agent_context,
      BEGIN OF ty_firr_doc,
        bukrs                   TYPE bukrs,
        gjahr                   TYPE gjahr,
        vkorg                   TYPE vkorg,
        zcdaz                   TYPE /eacm/zcdaz,
        lifnr                   TYPE lifnr,
        ztpag                   TYPE /eacm/ztpag,
        waerk                   TYPE waers,
        xblnr                   TYPE c LENGTH 16,
        period_num              TYPE i,
        period_id               TYPE c LENGTH 2,
        period_counter          TYPE i,
        status_field            TYPE string,
        total_status_field      TYPE string,
        period_amount           TYPE /eacm/zprfirr-zfbuto,
        amount                  TYPE /eacm/zprfirr-zfbuto,
        company_currency_amount TYPE /eacm/zprfirr-zfbuto,
        total_matured_amount    TYPE /eacm/zprfirr-zfpmat,
        company_matured_amount  TYPE /eacm/zprfirr-zfpmatc,
        debit_account           TYPE c LENGTH 10,
        cost_account            TYPE c LENGTH 10,
        kostl                   TYPE kostl,
        prctr                   TYPE prctr,
        final_period            TYPE abap_bool,
        terminated              TYPE abap_bool,
        annual_period           TYPE abap_bool,
        skipped                 TYPE abap_bool,
        skip_reason             TYPE string,
      END OF ty_firr_doc,
      tt_firr_doc TYPE STANDARD TABLE OF ty_firr_doc WITH DEFAULT KEY.

    DATA mt_docs TYPE tt_firr_doc.
    DATA mt_zpraa TYPE STANDARD TABLE OF /eacm/zpraa WITH DEFAULT KEY.
    DATA mt_zpr28 TYPE STANDARD TABLE OF /eacm/zpr28 WITH DEFAULT KEY.
    DATA mt_zpr41 TYPE STANDARD TABLE OF /eacm/zpr41 WITH DEFAULT KEY.
    DATA mt_tvko  TYPE STANDARD TABLE OF /eacm/tvko WITH DEFAULT KEY.
    DATA ms_zpr01 TYPE /eacm/zpr01.
    DATA mv_kokrs TYPE kokrs.
    DATA mv_company_currency TYPE waers.

    METHODS load_context
      IMPORTING
        is_selection TYPE ty_selection
      RAISING
        /eacm/cx_eacm_posting.

    METHODS validate_assignment_rule
      IMPORTING
        is_selection TYPE ty_selection
      RAISING
        /eacm/cx_eacm_posting.

    METHODS load_reference_data
      IMPORTING
        is_selection TYPE ty_selection.

    METHODS build_accounting_data
      IMPORTING
        is_selection TYPE ty_selection
      RAISING
        /eacm/cx_eacm_posting.

    METHODS determine_period
      IMPORTING
        is_zprfirr       TYPE /eacm/zprfirr
      RETURNING
        VALUE(rs_period) TYPE ty_period_info.

    METHODS map_period_counter
      IMPORTING
        iv_period_num       TYPE i
      RETURNING
        VALUE(rv_counter)   TYPE i.

    METHODS is_final_period
      IMPORTING
        iv_period_counter   TYPE i
        iv_is_annual        TYPE abap_bool
      RETURNING
        VALUE(rv_is_final)  TYPE abap_bool.

    METHODS read_agent_context
      IMPORTING
        is_zprfirr        TYPE /eacm/zprfirr
      RETURNING
        VALUE(rs_context) TYPE ty_agent_context.

    METHODS fill_control_area
      CHANGING
        cs_doc TYPE ty_firr_doc.

    METHODS contr_area
      IMPORTING
        iv_bukrs TYPE bukrs
        iv_vkorg TYPE vkorg
        iv_kokrs TYPE kokrs
        iv_zcdaz TYPE /eacm/zcdaz
        iv_case  TYPE c
      CHANGING
        cv_kostl TYPE kostl
        cv_aufnr TYPE aufnr
        cv_prctr TYPE prctr.

    METHODS is_agent_terminated
      IMPORTING
        iv_bukrs              TYPE bukrs
        iv_gjahr              TYPE gjahr
        iv_zcdaz              TYPE /eacm/zcdaz
      RETURNING
        VALUE(rv_terminated)  TYPE abap_bool.

    METHODS determine_accounts
      IMPORTING
        is_context   TYPE ty_agent_context
      CHANGING
        cs_doc       TYPE ty_firr_doc
      RAISING
        /eacm/cx_eacm_posting.

    METHODS calculate_company_amount
      CHANGING
        cs_doc TYPE ty_firr_doc.

    METHODS build_assignment_reference
      IMPORTING
        is_selection    TYPE ty_selection
        is_doc          TYPE ty_firr_doc
      RETURNING
        VALUE(rv_zuonr) TYPE dzuonr.

    METHODS build_request
      IMPORTING
        is_selection      TYPE ty_selection
        is_doc            TYPE ty_firr_doc
      RETURNING
        VALUE(rs_request) TYPE /eacm/cl_eacm_journal_post_api=>ty_request.
ENDCLASS.


CLASS /eacm/cl_eacm_zprfirr_posting IMPLEMENTATION.

  METHOD execute.
    DATA lo_api TYPE REF TO /eacm/cl_eacm_journal_post_api.

    CREATE OBJECT lo_api.

    load_context( is_selection ).
    load_reference_data( is_selection ).
    build_accounting_data( is_selection ).

    IF mt_docs IS INITIAL.
      RAISE EXCEPTION TYPE /eacm/cx_eacm_posting
        EXPORTING
          iv_text = 'Nessun dato utile trovato in /EACM/ZPRFIRR per la selezione richiesta'.
    ENDIF.

    LOOP AT mt_docs ASSIGNING FIELD-SYMBOL(<ls_doc>).
      DATA ls_response TYPE /eacm/cl_eacm_journal_post_api=>ty_response.

      IF <ls_doc>-skipped = abap_true.
        ls_response = VALUE /eacm/cl_eacm_journal_post_api=>ty_response(
          success      = abap_true
          message_text = <ls_doc>-skip_reason ).
      ELSEIF is_selection-pa_test = abap_true.
        ls_response = VALUE /eacm/cl_eacm_journal_post_api=>ty_response(
          success      = abap_true
          message_text = |Test eseguito: documento FIRR { <ls_doc>-xblnr } non contabilizzato.| ).
      ELSE.
        DATA(ls_request) = build_request(
          is_selection = is_selection
          is_doc       = <ls_doc> ).

        ls_response = lo_api->post_journal_entry( ls_request ).
      ENDIF.

      APPEND VALUE ty_post_result(
        bukrs               = <ls_doc>-bukrs
        gjahr               = <ls_doc>-gjahr
        vkorg               = <ls_doc>-vkorg
        zcdaz               = <ls_doc>-zcdaz
        lifnr               = <ls_doc>-lifnr
        ztpag               = <ls_doc>-ztpag
        period_num          = <ls_doc>-period_num
        period_id           = <ls_doc>-period_id
        status_field        = <ls_doc>-status_field
        total_status_field  = <ls_doc>-total_status_field
        external_reference  = <ls_doc>-xblnr
        accounting_document = ls_response-accounting_document
        fiscal_year         = ls_response-fiscal_year
        skipped             = <ls_doc>-skipped
        success             = ls_response-success
        processing_status   = COND #( WHEN ls_response-success = abap_true THEN 'S' ELSE 'E' )
        message_text        = ls_response-message_text
        message_details     = ls_response-message_details ) TO rt_result.
    ENDLOOP.
  ENDMETHOD.


  METHOD load_context.
    SELECT SINGLE *
      FROM /eacm/zpr01
      WHERE bukrs = @is_selection-bukrs
      INTO @ms_zpr01.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE /eacm/cx_eacm_posting
        EXPORTING
          iv_text = |Nessun record trovato in /EACM/ZPR01 per societa { is_selection-bukrs }|.
    ENDIF.

    IF ms_zpr01-zgfirr <> 'A' AND
       ms_zpr01-zgfirr <> 'T' AND
       ms_zpr01-zgfirr <> 'M'.
      RAISE EXCEPTION TYPE /eacm/cx_eacm_posting
        EXPORTING
          iv_text = |Parametro ZGFIRR non valido in /EACM/ZPR01 per societa { is_selection-bukrs }|.
    ENDIF.

    validate_assignment_rule( is_selection ).

*    mv_kokrs = 'A000'.

    SELECT SINGLE waers, kokrs
      FROM /eacm/t001
      WHERE bukrs = @is_selection-bukrs
      INTO ( @mv_company_currency, @mv_kokrs ).

    SELECT *
      FROM /eacm/tvko
      WHERE bukrs = @is_selection-bukrs
      INTO TABLE @mt_tvko.
  ENDMETHOD.


  METHOD validate_assignment_rule.
    IF is_selection-pa_fratt IS INITIAL AND is_selection-p_zuonr IS INITIAL.
      RAISE EXCEPTION TYPE /eacm/cx_eacm_posting
        EXPORTING
          iv_text = 'Indicare una regola di attribuzione oppure un riferimento attribuzione fisso'.
    ENDIF.

    IF is_selection-pa_fratt IS INITIAL.
      RETURN.
    ENDIF.

    SELECT SINGLE * "#EC CI_ALL_FIELDS_NEEDED
      FROM /eacm/zpr43
      WHERE zfratt = @is_selection-pa_fratt
      INTO @DATA(ls_zpr43).

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE /eacm/cx_eacm_posting
        EXPORTING
          iv_text = |Regola attribuzione { is_selection-pa_fratt } non trovata in /EACM/ZPR43|.
    ENDIF.

    DATA ls_doc_probe TYPE ty_firr_doc.
    DO 5 TIMES.
      ASSIGN COMPONENT |ZFIELD{ sy-index }| OF STRUCTURE ls_zpr43 TO FIELD-SYMBOL(<lv_rule_field>).
      IF <lv_rule_field> IS NOT ASSIGNED OR <lv_rule_field> IS INITIAL.
        CONTINUE.
      ENDIF.

      IF <lv_rule_field> = 'BUKRS'
      OR <lv_rule_field> = 'BLDAT'
      OR <lv_rule_field> = 'GJAHR'
      OR <lv_rule_field> = 'ZFBUTO'
      OR <lv_rule_field> = 'ZFPMAT'
      OR <lv_rule_field> = 'ZFPMATC'
      OR <lv_rule_field> = 'ZTPRC'.
        CONTINUE.
      ENDIF.

      IF <lv_rule_field> = 'GSBER'.
        RAISE EXCEPTION TYPE /eacm/cx_eacm_posting
          EXPORTING
            iv_text = 'La regola attribuzione FIRR non puo contenere il campo GSBER'.
      ENDIF.

      ASSIGN COMPONENT <lv_rule_field> OF STRUCTURE ls_doc_probe TO FIELD-SYMBOL(<lv_probe>).
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE /eacm/cx_eacm_posting
          EXPORTING
            iv_text = |Campo { <lv_rule_field> } non gestito nella regola attribuzione { is_selection-pa_fratt }|.
      ENDIF.
    ENDDO.
  ENDMETHOD.


  METHOD load_reference_data.
    CLEAR: mt_zpraa, mt_zpr28, mt_zpr41.

    SELECT *
      FROM /eacm/zpraa
      WHERE ( zcdaz = @is_selection-zcdaz OR @is_selection-zcdaz = '' )
        AND ( ztpag = @is_selection-ztpag OR @is_selection-ztpag = '' )
      ORDER BY zcdaz ASCENDING, erdat DESCENDING
      INTO TABLE @mt_zpraa.

    SELECT *
      FROM /eacm/zpr28
      WHERE bukrs = @is_selection-bukrs
      INTO TABLE @mt_zpr28.
    SORT mt_zpr28 BY bukrs ztpag.

    SELECT *
      FROM /eacm/zpr41
      WHERE bukrs = @is_selection-bukrs
      INTO TABLE @mt_zpr41.
    SORT mt_zpr41 BY bukrs ztpag.
  ENDMETHOD.


  METHOD build_accounting_data.
    CLEAR mt_docs.

    SELECT * "#EC CI_ALL_FIELDS_NEEDED
      FROM /eacm/zprfirr
      WHERE bukrs = @is_selection-bukrs
        AND gjahr = @is_selection-gjahr
        AND ( zcdaz = @is_selection-zcdaz OR @is_selection-zcdaz = '' )
      INTO TABLE @DATA(lt_zprfirr).

    LOOP AT lt_zprfirr ASSIGNING FIELD-SYMBOL(<ls_zprfirr>).
      DATA(ls_period) = determine_period( <ls_zprfirr> ).
      IF ls_period-found <> abap_true.
        CONTINUE.
      ENDIF.

      DATA(ls_context) = read_agent_context( <ls_zprfirr> ).
      IF ls_context-has_zpraa <> abap_true.
        CONTINUE.
      ENDIF.

      IF ls_context-has_zpr28 <> abap_true AND
         ls_context-has_zpr41 <> abap_true.
        CONTINUE.
      ENDIF.

      DATA(ls_doc) = VALUE ty_firr_doc(
        bukrs                = <ls_zprfirr>-bukrs
        gjahr                = <ls_zprfirr>-gjahr
        vkorg                = <ls_zprfirr>-vkorg
        zcdaz                = <ls_zprfirr>-zcdaz
        lifnr                = <ls_zprfirr>-lifnr
        ztpag                = ls_context-zpraa-ztpag
        waerk                = <ls_zprfirr>-waerk
        xblnr                = |{ <ls_zprfirr>-zcdaz }_FIRR|
        period_num           = ls_period-period_num
        period_id            = ls_period-period_id
        period_counter       = ls_period-period_counter
        status_field         = ls_period-status_field
        total_status_field   = 'ZTPRC'
        annual_period        = ls_period-is_annual
        total_matured_amount = <ls_zprfirr>-zfpmat
        company_matured_amount = <ls_zprfirr>-zfpmatc ).

      ASSIGN COMPONENT ls_period-amount_field OF STRUCTURE <ls_zprfirr> TO FIELD-SYMBOL(<lv_period_amount>).
      IF <lv_period_amount> IS ASSIGNED.
        ls_doc-period_amount = <lv_period_amount>.
      ENDIF.

      ls_doc-final_period = is_final_period(
        iv_period_counter = ls_doc-period_counter
        iv_is_annual      = ls_doc-annual_period ).

      ls_doc-terminated = is_agent_terminated(
        iv_bukrs = ls_doc-bukrs
        iv_gjahr = ls_doc-gjahr
        iv_zcdaz = ls_doc-zcdaz ).

      determine_accounts(
        EXPORTING
          is_context = ls_context
        CHANGING
          cs_doc     = ls_doc ).

      fill_control_area( CHANGING cs_doc = ls_doc ).
      calculate_company_amount( CHANGING cs_doc = ls_doc ).

      IF ls_doc-amount = 0.
        ls_doc-skipped = abap_true.
        ls_doc-skip_reason =
          |FIRR { ls_doc-zcdaz } periodo { ls_doc-period_id }: importo zero, aggiornamento flag senza contabilizzazione.|.
      ENDIF.

      APPEND ls_doc TO mt_docs.
    ENDLOOP.
  ENDMETHOD.


  METHOD determine_period.
    DATA lv_idx TYPE i.
    DATA lv_idx_text TYPE string.
    DATA lv_period_id TYPE n LENGTH 2.
    FIELD-SYMBOLS <lv_status> TYPE any.

    DO 12 TIMES.
      lv_idx = sy-index.
      lv_idx_text = |{ lv_idx }|.
      lv_period_id = lv_idx.

      DATA(lv_status_field) = |ZTPRC_{ lv_idx_text }|.
      UNASSIGN <lv_status>.
      ASSIGN COMPONENT lv_status_field OF STRUCTURE is_zprfirr TO <lv_status>.
      IF <lv_status> IS ASSIGNED AND <lv_status> = 'C'.
        rs_period-found = abap_true.
        rs_period-is_annual = abap_false.
        rs_period-period_num = lv_idx.
        rs_period-period_id = lv_period_id.
        rs_period-period_counter = map_period_counter( lv_idx ).
        rs_period-status_field = lv_status_field.
        rs_period-amount_field = |ZFBUTO_{ lv_idx_text }|.
        rs_period-maturity_field = |ZFPMAT_{ lv_idx_text }|.
        RETURN.
      ENDIF.
    ENDDO.

    IF ms_zpr01-zgfirr = 'A'.
      UNASSIGN <lv_status>.
      ASSIGN COMPONENT 'ZTPRC' OF STRUCTURE is_zprfirr TO <lv_status>.
      IF <lv_status> IS ASSIGNED AND <lv_status> = 'C'.
        rs_period-found = abap_true.
        rs_period-is_annual = abap_true.
        rs_period-period_num = 4.
        rs_period-period_id = '04'.
        rs_period-period_counter = 4.
        rs_period-status_field = 'ZTPRC'.
        rs_period-amount_field = 'ZFBUTO'.
        rs_period-maturity_field = 'ZFPMAT'.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD map_period_counter.
    CASE ms_zpr01-zgfirr.
      WHEN 'A'.
        rv_counter = 4.
      WHEN OTHERS.
        rv_counter = iv_period_num.
    ENDCASE.
  ENDMETHOD.


  METHOD is_final_period.
    IF iv_is_annual = abap_true.
      rv_is_final = abap_true.
      RETURN.
    ENDIF.

    CASE ms_zpr01-zgfirr.
      WHEN 'M'.
        rv_is_final = xsdbool( iv_period_counter = 12 ).
      WHEN 'T'.
        rv_is_final = xsdbool( iv_period_counter = 4 ).
      WHEN 'A'.
        rv_is_final = abap_true.
    ENDCASE.
  ENDMETHOD.


  METHOD read_agent_context.
    READ TABLE mt_zpraa INTO rs_context-zpraa
      WITH KEY zcdaz = is_zprfirr-zcdaz.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    rs_context-has_zpraa = abap_true.

    READ TABLE mt_zpr28 INTO rs_context-zpr28
      WITH KEY bukrs = is_zprfirr-bukrs
               ztpag = rs_context-zpraa-ztpag
      BINARY SEARCH.
    IF sy-subrc <> 0.
      READ TABLE mt_zpr28 INTO rs_context-zpr28
        WITH KEY bukrs = is_zprfirr-bukrs
                 ztpag = ''
        BINARY SEARCH.
    ENDIF.
    IF sy-subrc = 0.
      rs_context-has_zpr28 = abap_true.
    ENDIF.

    READ TABLE mt_zpr41 INTO rs_context-zpr41
      WITH KEY bukrs = is_zprfirr-bukrs
               ztpag = rs_context-zpraa-ztpag
      BINARY SEARCH.
    IF sy-subrc <> 0.
      READ TABLE mt_zpr41 INTO rs_context-zpr41
        WITH KEY bukrs = is_zprfirr-bukrs
                 ztpag = ''
        BINARY SEARCH.
    ENDIF.
    IF sy-subrc = 0.
      rs_context-has_zpr41 = abap_true.
    ENDIF.

    IF rs_context-has_zpr41 = abap_true
       AND rs_context-zpr41-ztpca = '5'
       AND ( rs_context-zpr28-zcdef IS INITIAL OR
             rs_context-zpr28-zcfir IS INITIAL ).
      CLEAR rs_context-zpr41.
      rs_context-has_zpr41 = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD fill_control_area.
    DATA lv_aufnr TYPE aufnr.

    CLEAR: cs_doc-kostl, cs_doc-prctr.

    LOOP AT mt_tvko ASSIGNING FIELD-SYMBOL(<ls_tvko>). "#EC CI_NOORDER  "#EC WARNOK
      contr_area(
        EXPORTING
          iv_bukrs = <ls_tvko>-bukrs
          iv_vkorg = <ls_tvko>-vkorg
          iv_kokrs = mv_kokrs
          iv_zcdaz = cs_doc-zcdaz
          iv_case  = '1'
        CHANGING
          cv_kostl = cs_doc-kostl
          cv_aufnr = lv_aufnr
          cv_prctr = cs_doc-prctr ).

      IF cs_doc-kostl IS NOT INITIAL OR cs_doc-prctr IS NOT INITIAL.
        EXIT.
      ENDIF.
    ENDLOOP.

    CHECK cs_doc-kostl IS INITIAL AND cs_doc-prctr IS INITIAL.

    LOOP AT mt_tvko ASSIGNING <ls_tvko>. "#EC CI_NOORDER  "#EC WARNOK
      contr_area(
        EXPORTING
          iv_bukrs = <ls_tvko>-bukrs
          iv_vkorg = <ls_tvko>-vkorg
          iv_kokrs = mv_kokrs
          iv_zcdaz = cs_doc-zcdaz
          iv_case  = '2'
        CHANGING
          cv_kostl = cs_doc-kostl
          cv_aufnr = lv_aufnr
          cv_prctr = cs_doc-prctr ).

      IF cs_doc-kostl IS NOT INITIAL OR cs_doc-prctr IS NOT INITIAL.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD contr_area.
    DATA lv_kokrs TYPE kokrs.

    lv_kokrs = COND #( WHEN iv_kokrs IS NOT INITIAL THEN iv_kokrs ELSE '9999' ).

    CASE iv_case.
      WHEN '1'.
        SELECT SINGLE kostl, prctr "#EC WARNOK
          FROM /eacm/zpr13
          WHERE kokrs = @lv_kokrs
            AND vkorg = @iv_vkorg
            AND zcdaz = @iv_zcdaz
          INTO (@cv_kostl, @cv_prctr).
      WHEN '2'.
        SELECT SINGLE kostl, prctr "#EC WARNOK
          FROM /eacm/zpr13
          WHERE kokrs = @lv_kokrs
            AND vkorg = @iv_vkorg
          INTO (@cv_kostl, @cv_prctr).
    ENDCASE.
  ENDMETHOD.


  METHOD is_agent_terminated.
    DATA lv_last_day TYPE d.

    lv_last_day = |{ iv_gjahr }1231|.

    SELECT SINGLE zcdaz "#EC WARNOK
      FROM /eacm/prcn
      WHERE zcdaz = @iv_zcdaz
        AND bukrs = @iv_bukrs
        AND ( zdtfi > @lv_last_day OR zdtfi = '00000000' )
      INTO @DATA(lv_zcdaz).

    rv_terminated = xsdbool( sy-subrc <> 0 ).
  ENDMETHOD.


  METHOD determine_accounts.
    CASE is_context-zpr28-ztpca.
      WHEN '1'.
        cs_doc-amount = cs_doc-total_matured_amount.
        IF cs_doc-final_period = abap_true AND cs_doc-terminated = abap_true.
          IF is_context-zpr28-zcdefc IS INITIAL.
            RAISE EXCEPTION TYPE /eacm/cx_eacm_posting
              EXPORTING
                iv_text = |Conto ZCDEFC mancante per FIRR cessato { cs_doc-zcdaz }|.
          ENDIF.
          cs_doc-debit_account = is_context-zpr28-zcdefc.
        ELSE.
          cs_doc-debit_account = is_context-zpr28-zcdef.
        ENDIF.
        cs_doc-cost_account = is_context-zpr28-zcfir.

      WHEN '3'.
        cs_doc-amount = cs_doc-total_matured_amount.
        cs_doc-debit_account = is_context-zpr28-zcdef_a.
        cs_doc-cost_account = is_context-zpr28-zcfir_a.

      WHEN OTHERS.
        CASE is_context-zpr41-ztpca.
          WHEN '2'.
            cs_doc-amount = cs_doc-period_amount.
            cs_doc-debit_account = is_context-zpr41-zcdef_tri.
            cs_doc-cost_account = is_context-zpr41-zcfir_tri.

          WHEN '4'.
            IF cs_doc-final_period = abap_true.
              cs_doc-amount = cs_doc-total_matured_amount.
              cs_doc-debit_account = is_context-zpr28-zcdef_a.
              cs_doc-cost_account = is_context-zpr28-zcfir_a.
            ELSE.
              cs_doc-amount = cs_doc-period_amount.
              cs_doc-debit_account = is_context-zpr41-zcdef_tri_a.
              cs_doc-cost_account = is_context-zpr41-zcfir_tri_a.
            ENDIF.

          WHEN '5'.
            IF cs_doc-final_period = abap_true.
              cs_doc-amount = cs_doc-total_matured_amount.
              IF cs_doc-terminated = abap_true.
                IF is_context-zpr28-zcdefc IS INITIAL.
                  RAISE EXCEPTION TYPE /eacm/cx_eacm_posting
                    EXPORTING
                      iv_text = |Conto ZCDEFC mancante per FIRR cessato { cs_doc-zcdaz }|.
                ENDIF.
                cs_doc-debit_account = is_context-zpr28-zcdefc.
              ELSE.
                cs_doc-debit_account = is_context-zpr28-zcdef.
              ENDIF.
              cs_doc-cost_account = is_context-zpr28-zcfir.
            ELSE.
              cs_doc-amount = cs_doc-period_amount.
              cs_doc-debit_account = is_context-zpr41-zcdef_tri_g.
              cs_doc-cost_account = is_context-zpr41-zcfir_tri_g.
            ENDIF.

          WHEN OTHERS.
            RAISE EXCEPTION TYPE /eacm/cx_eacm_posting
              EXPORTING
                iv_text = |Customizing FIRR mancante o non gestito per societa { cs_doc-bukrs } tipo agente { cs_doc-ztpag }|.
        ENDCASE.
    ENDCASE.

    IF cs_doc-debit_account IS INITIAL OR cs_doc-cost_account IS INITIAL.
      RAISE EXCEPTION TYPE /eacm/cx_eacm_posting
        EXPORTING
          iv_text = |Conti FIRR incompleti per societa { cs_doc-bukrs } tipo agente { cs_doc-ztpag }|.
    ENDIF.
  ENDMETHOD.


  METHOD calculate_company_amount.
    IF mv_company_currency IS INITIAL OR
       cs_doc-waerk = mv_company_currency OR
       cs_doc-total_matured_amount = 0.
      cs_doc-company_currency_amount = cs_doc-amount.
      RETURN.
    ENDIF.

    cs_doc-company_currency_amount =
      cs_doc-company_matured_amount / cs_doc-total_matured_amount * cs_doc-amount.
  ENDMETHOD.


  METHOD build_assignment_reference.
    FIELD-SYMBOLS <lv_doc_field> TYPE any.

    IF is_selection-pa_fratt IS INITIAL.
      rv_zuonr = is_selection-p_zuonr.
      RETURN.
    ENDIF.

    SELECT SINGLE * "#EC CI_ALL_FIELDS_NEEDED
      FROM /eacm/zpr43
      WHERE zfratt = @is_selection-pa_fratt
      INTO @DATA(ls_zpr43).

    DO 5 TIMES.
      ASSIGN COMPONENT |ZFIELD{ sy-index }| OF STRUCTURE ls_zpr43 TO FIELD-SYMBOL(<lv_field_name>).
      ASSIGN COMPONENT |ZLENG{ sy-index }| OF STRUCTURE ls_zpr43 TO FIELD-SYMBOL(<lv_field_len>).

      IF <lv_field_name> IS NOT ASSIGNED OR <lv_field_name> IS INITIAL.
        CONTINUE.
      ENDIF.

      DATA(lv_piece) = ``.

      CASE <lv_field_name>.
        WHEN 'BUKRS'.
          lv_piece = |{ is_doc-bukrs }|.
        WHEN 'GJAHR'.
          lv_piece = |{ is_doc-gjahr }|.
        WHEN 'BLDAT'.
          lv_piece = |{ is_selection-bldat }|.
        WHEN 'ZFBUTO'.
          lv_piece = |{ is_doc-amount }|.
        WHEN 'ZFPMAT'.
          lv_piece = |{ is_doc-total_matured_amount }|.
        WHEN 'ZFPMATC'.
          lv_piece = |{ is_doc-company_matured_amount }|.
        WHEN 'ZTPRC'.
          lv_piece = 'S'.
        WHEN 'GSBER'.
          CONTINUE.
        WHEN OTHERS.
          UNASSIGN <lv_doc_field>.
          ASSIGN COMPONENT <lv_field_name> OF STRUCTURE is_doc TO <lv_doc_field>.
          IF <lv_doc_field> IS ASSIGNED.
            lv_piece = |{ <lv_doc_field> }|.
          ENDIF.
      ENDCASE.

      CONDENSE lv_piece.
      CHECK lv_piece IS NOT INITIAL.

      IF <lv_field_len> IS ASSIGNED AND <lv_field_len> IS NOT INITIAL.
        DATA(lv_trunc_len) = COND i(
          WHEN strlen( lv_piece ) < <lv_field_len> THEN strlen( lv_piece )
          ELSE <lv_field_len> ).
        rv_zuonr = |{ rv_zuonr }{ lv_piece(lv_trunc_len) }|.
      ELSE.
        rv_zuonr = |{ rv_zuonr }{ lv_piece }|.
      ENDIF.
    ENDDO.
  ENDMETHOD.


  METHOD build_request.
  DATA lv_abs_amount LIKE is_doc-amount.
    lv_abs_amount = abs( is_doc-amount ) ##TYPE.
*    DATA(lv_abs_amount) = abs( is_doc-amount ) ##TYPE.
    DATA(lv_zuonr) = build_assignment_reference(
      is_selection = is_selection
      is_doc       = is_doc ).

    rs_request-company_code = is_selection-bukrs.
    rs_request-document_date = is_selection-bldat.
    rs_request-posting_date = is_selection-budat.
    rs_request-accounting_document_type = is_selection-blart.
    rs_request-original_reference_document = is_doc-xblnr.
    rs_request-document_header_text = |FIRR { is_doc-zcdaz }|.
    rs_request-created_by_user = cl_abap_context_info=>get_user_technical_name( ).

    APPEND VALUE /eacm/cl_eacm_journal_post_api=>ty_gl_item(
      gl_account        = is_doc-debit_account
      amount            = lv_abs_amount
      currency_code     = is_doc-waerk
      debit_credit_code = COND #( WHEN is_doc-amount < 0 THEN 'S' ELSE 'H' )
      assignment_ref    = lv_zuonr
      profit_center     = is_doc-prctr
      item_text         = 'eACM - FIRR' ) TO rs_request-items.

    APPEND VALUE /eacm/cl_eacm_journal_post_api=>ty_gl_item(
      gl_account        = is_doc-cost_account
      amount            = lv_abs_amount
      currency_code     = is_doc-waerk
      debit_credit_code = COND #( WHEN is_doc-amount < 0 THEN 'H' ELSE 'S' )
      assignment_ref    = lv_zuonr
      cost_center       = is_doc-kostl
      profit_center     = COND #( WHEN ms_zpr01-zgfirr = 'M' THEN '' ELSE is_doc-prctr )
      item_text         = 'eACM - FIRR Cost' ) TO rs_request-items.
  ENDMETHOD.
ENDCLASS.

