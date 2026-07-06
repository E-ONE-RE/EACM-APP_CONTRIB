CLASS /eacm/cl_eacm_zpren_posting_tm DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_selection,
        bukrs     TYPE bukrs,
        bldat     TYPE budat,
        budat     TYPE budat,
        blart     TYPE blart,
        zcdaz     TYPE /eacm/zcdaz,
        ztpag     TYPE /eacm/ztpag,
        pa_fratt  TYPE /eacm/zpr43-zfratt,
        p_zuonr   TYPE c LENGTH 18,
        kokrs     TYPE kokrs,
        pa_test   TYPE abap_bool,
      END OF ty_selection,
      BEGIN OF ty_cont,
        xblnr   TYPE c LENGTH 16,
        waers   TYPE /eacm/zpren-zwaer,
        zever   TYPE /eacm/zpren-zever1,
        zecag   TYPE /eacm/zpren-zecag1,
        zeccd   TYPE /eacm/zpren-zeccd1,
        zcpena  TYPE /eacm/zpr25-zcpena,
        zceage  TYPE /eacm/zpr25-zceage,
        zceagp  TYPE /eacm/zpr25-zceagp,
        lifnr   TYPE /eacm/zpren-lifnr,
        zcdaz   TYPE /eacm/zpren-zcdaz,
        ztpag   TYPE /eacm/zpraa-ztpag,
        kostl   TYPE kostl,
        prctr   TYPE prctr,
        zwerks  TYPE /eacm/zwerks,
        mwskz   TYPE mwskz,
      END OF ty_cont,
      tt_cont TYPE STANDARD TABLE OF ty_cont WITH DEFAULT KEY,
      tt_message_detail TYPE /eacm/cl_eacm_journal_post_api=>tt_message_detail,
      BEGIN OF ty_post_result,
        bukrs               TYPE bukrs,
        gjahr               TYPE gjahr,
        zcdaz               TYPE /eacm/zpren-zcdaz,
        lifnr               TYPE /eacm/zpren-lifnr,
        period_num          TYPE i,
        period_id           TYPE c LENGTH 2,
        external_reference  TYPE c LENGTH 16,
        accounting_document TYPE c LENGTH 10,
        fiscal_year         TYPE c LENGTH 4,
        success             TYPE abap_bool,
        processing_status   TYPE c LENGTH 1,
        message_text        TYPE string,
        message_details     TYPE tt_message_detail,
      END OF ty_post_result,
      tt_post_result TYPE STANDARD TABLE OF ty_post_result WITH DEFAULT KEY,
      BEGIN OF ty_period_info,
        period_num   TYPE i,
        period_id    TYPE c LENGTH 2,
        field_zever  TYPE string,
        field_zecag  TYPE string,
        field_zeccd  TYPE string,
        field_zecon  TYPE string,
        xblnr        TYPE c LENGTH 16,
      END OF ty_period_info.

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
    DATA mt_tb_cont TYPE tt_cont.
    DATA ms_zpr23   TYPE /eacm/zpr23.
    DATA mt_tb_age  TYPE STANDARD TABLE OF /eacm/zpraa WITH DEFAULT KEY.
    DATA mt_tvko    TYPE STANDARD TABLE OF /eacm/tvko WITH DEFAULT KEY.
    DATA mv_kokrs   TYPE kokrs.
    DATA mv_t_m     TYPE c LENGTH 1.
    DATA ms_period  TYPE ty_period_info.

    METHODS load_context
      IMPORTING
        is_selection TYPE ty_selection
      RAISING
        /eacm/cx_eacm_posting.

    METHODS determine_period
      RETURNING
        VALUE(rs_period)  TYPE ty_period_info.

    METHODS validate_assignment_rule
      IMPORTING
        is_selection TYPE ty_selection
      RAISING
        /eacm/cx_eacm_posting.

    METHODS build_accounting_data
      IMPORTING
        is_selection TYPE ty_selection
      RAISING
        /eacm/cx_eacm_posting.

    METHODS load_agents
      IMPORTING
        is_selection TYPE ty_selection.

    METHODS get_start_quarter
      IMPORTING
        iv_bldat       TYPE d
      RETURNING
        VALUE(rv_dtit) TYPE d.

    METHODS determine_agent_data
      IMPORTING
        is_selection      TYPE ty_selection
        is_zpren          TYPE /eacm/zpren
        iv_start_quarter  TYPE d
      CHANGING
        cs_cont           TYPE ty_cont.

    METHODS fill_month_specific_data
      CHANGING
        cs_cont TYPE ty_cont.

    METHODS estrazione_cdc
      IMPORTING
        iv_zcdaz TYPE /eacm/zcdaz
      CHANGING
        cv_kostl TYPE kostl
        cv_prctr TYPE prctr.

    METHODS contr_area
      IMPORTING
        iv_bukrs TYPE bukrs
        iv_vkorg TYPE vkorg
        iv_vtweg TYPE vtweg
        iv_zclpr TYPE /eacm/prdo-zclpr
        iv_kokrs TYPE kokrs
        iv_zcdaz TYPE /eacm/zcdaz
        iv_case  TYPE c
      CHANGING
        cv_kostl TYPE kostl
        cv_aufnr TYPE aufnr
        cv_prctr TYPE prctr.

    METHODS build_assignment_reference
      IMPORTING
        is_selection    TYPE ty_selection
        is_cont         TYPE ty_cont
      RETURNING
        VALUE(rv_zuonr) TYPE dzuonr.

    METHODS build_request
      IMPORTING
        is_selection      TYPE ty_selection
        is_cont           TYPE ty_cont
      RETURNING
        VALUE(rs_request) TYPE /eacm/cl_eacm_journal_post_api=>ty_request.

    METHODS update_after_success
      IMPORTING
        is_selection TYPE ty_selection
        is_cont      TYPE ty_cont.
ENDCLASS.



CLASS /EACM/CL_EACM_ZPREN_POSTING_TM IMPLEMENTATION.


  METHOD execute.
    DATA lo_api TYPE REF TO /eacm/cl_eacm_journal_post_api.
    CREATE OBJECT lo_api.

    load_context( is_selection ).
    load_agents( is_selection ).
    ms_period = determine_period( ).
    build_accounting_data( is_selection ).

    IF mt_tb_cont IS INITIAL.
      RAISE EXCEPTION TYPE /eacm/cx_eacm_posting
        EXPORTING
          iv_text = 'Nessun dato utile trovato in /EACM/ZPREN per la selezione richiesta'.
    ENDIF.

    LOOP AT mt_tb_cont ASSIGNING FIELD-SYMBOL(<ls_cont>).
      DATA(ls_request) = build_request(
        is_selection = is_selection
        is_cont      = <ls_cont> ).

      DATA ls_response TYPE /eacm/cl_eacm_journal_post_api=>ty_response.
      IF is_selection-pa_test = abap_true.
        ls_response = VALUE /eacm/cl_eacm_journal_post_api=>ty_response(
          success      = abap_true
          message_text = |Test eseguito: documento { <ls_cont>-xblnr } non contabilizzato.| ).
      ELSE.
        ls_response = lo_api->post_journal_entry( ls_request ).
      ENDIF.

      APPEND VALUE ty_post_result(
        bukrs               = is_selection-bukrs
        gjahr               = ms_zpr23-zelfi(4)
        zcdaz               = <ls_cont>-zcdaz
        lifnr               = <ls_cont>-lifnr
        period_num          = ms_period-period_num
        period_id           = ms_period-period_id
        external_reference  = <ls_cont>-xblnr
        accounting_document = ls_response-accounting_document
        fiscal_year         = ls_response-fiscal_year
        success             = ls_response-success
        processing_status   = COND #( WHEN ls_response-success = abap_true THEN 'S' ELSE 'E' )
        message_text        = ls_response-message_text
        message_details     = ls_response-message_details ) TO rt_result.

    ENDLOOP.
  ENDMETHOD.


  METHOD load_context.
    DATA l_zelfi TYPE /eacm/zelfi.
    l_zelfi = is_selection-bldat(6).

    SELECT SINGLE *
      FROM /eacm/zpr23
      WHERE bukrs = @is_selection-bukrs
        AND zcimp = 'S'
        AND zccon = 'S'
        AND zelfi <= @l_zelfi
      INTO @ms_zpr23.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE /eacm/cx_eacm_posting
        EXPORTING
          iv_text = |Nessun record valido trovato in /EACM/ZPR23 per societa { is_selection-bukrs }|.
    ENDIF.

    validate_assignment_rule( is_selection ).

    SELECT SINGLE zgena
      FROM /eacm/zpr01
      WHERE bukrs = @is_selection-bukrs
      INTO @mv_t_m.

    IF sy-subrc <> 0 OR ( mv_t_m <> 'T' AND mv_t_m <> 'M' ).
      RAISE EXCEPTION TYPE /eacm/cx_eacm_posting
        EXPORTING
          iv_text = |Parametro ZGENA non valido in /EACM/ZPR01 per societa { is_selection-bukrs }|.
    ENDIF.

    mv_kokrs = is_selection-kokrs.

    SELECT * "vkorg, bukrs
      FROM /eacm/tvko
      WHERE bukrs = @is_selection-bukrs
      INTO CORRESPONDING FIELDS OF TABLE @mt_tvko.
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

    SELECT SINGLE zfield1, zfield2, zfield3, zfield4, zfield5
      FROM /eacm/zpr43
      WHERE zfratt = @is_selection-pa_fratt
      INTO @DATA(ls_zpr43).

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE /eacm/cx_eacm_posting
        EXPORTING
          iv_text = |Regola attribuzione { is_selection-pa_fratt } non trovata in /EACM/ZPR43|.
    ENDIF.

    IF ls_zpr43-zfield1 = 'VKORG'
    OR ls_zpr43-zfield2 = 'VKORG'
    OR ls_zpr43-zfield3 = 'VKORG'
    OR ls_zpr43-zfield4 = 'VKORG'
    OR ls_zpr43-zfield5 = 'VKORG'.
      RAISE EXCEPTION TYPE /eacm/cx_eacm_posting
        EXPORTING
          iv_text = 'La regola attribuzione non puo contenere il campo VKORG'.
    ENDIF.

    IF ls_zpr43-zfield1 = 'GSBER'
    OR ls_zpr43-zfield2 = 'GSBER'
    OR ls_zpr43-zfield3 = 'GSBER'
    OR ls_zpr43-zfield4 = 'GSBER'
    OR ls_zpr43-zfield5 = 'GSBER'.
      RAISE EXCEPTION TYPE /eacm/cx_eacm_posting
        EXPORTING
          iv_text = 'La regola attribuzione non puo contenere il campo GSBER'.
    ENDIF.

    DATA ls_cont_probe TYPE ty_cont.
    DO 5 TIMES.
      ASSIGN COMPONENT |ZFIELD{ sy-index }| OF STRUCTURE ls_zpr43 TO FIELD-SYMBOL(<lv_rule_field>).
      IF <lv_rule_field> IS NOT ASSIGNED OR <lv_rule_field> IS INITIAL.
        CONTINUE.
      ENDIF.

      IF <lv_rule_field> = 'ZCDAZ'
      OR <lv_rule_field> = 'BUKRS'
      OR <lv_rule_field> = 'BLDAT'.
        CONTINUE.
      ENDIF.

      ASSIGN COMPONENT <lv_rule_field> OF STRUCTURE ls_cont_probe TO FIELD-SYMBOL(<lv_probe>).
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE /eacm/cx_eacm_posting
          EXPORTING
            iv_text = |Campo { <lv_rule_field> } non gestito nella regola attribuzione { is_selection-pa_fratt }|.
      ENDIF.
    ENDDO.
  ENDMETHOD.


  METHOD determine_period.
    DATA lv_month_num TYPE i.
    DATA lv_month_txt TYPE n LENGTH 2.

    lv_month_txt = ms_zpr23-zelin+4(2).
    lv_month_num = lv_month_txt.

    IF mv_t_m = 'M'.
      rs_period-period_num = lv_month_num.
      rs_period-period_id = lv_month_txt.
      rs_period-field_zever = |ZEVER_{ lv_month_txt }|.
      rs_period-field_zecag = |ZECAG_{ lv_month_txt }|.
      rs_period-field_zeccd = |ZECCD_{ lv_month_txt }|.
      rs_period-field_zecon = |ZECON_{ lv_month_txt }|.
      rs_period-xblnr = |{ lv_month_txt }_mese._{ ms_zpr23-zelfi(4) }|.
    ELSE.
      rs_period-period_num = ( lv_month_num - 1 ) DIV 3 + 1.
      rs_period-field_zever = |ZEVER{ rs_period-period_num }|.
      rs_period-field_zecag = |ZECAG{ rs_period-period_num }|.
      rs_period-field_zeccd = |ZECCD{ rs_period-period_num }|.
      rs_period-field_zecon = |ZECON{ rs_period-period_num }|.
      rs_period-xblnr = |{ rs_period-period_num }_trim._{ ms_zpr23-zelfi(4) }|.
    ENDIF.
  ENDMETHOD.


  METHOD build_accounting_data.
    DATA lv_year TYPE gjahr.
    DATA lv_start_quarter TYPE d.

    lv_year = ms_zpr23-zelfi(4).
    lv_start_quarter = get_start_quarter( is_selection-bldat ).

    CLEAR mt_tb_cont.
    IF mt_tb_age IS INITIAL.
      RETURN.
    ENDIF.

    SELECT * "#EC CI_ALL_FIELDS_NEEDED
      FROM /eacm/zpren
      WHERE bukrs = @is_selection-bukrs
        AND gjahr = @lv_year
      INTO TABLE @DATA(lt_zpren).


    LOOP AT lt_zpren ASSIGNING FIELD-SYMBOL(<ls_zpren>).
      IF NOT line_exists( mt_tb_age[ lifnr = <ls_zpren>-lifnr ] ).
        CONTINUE.
      ENDIF.

      ASSIGN COMPONENT ms_period-field_zever OF STRUCTURE <ls_zpren> TO FIELD-SYMBOL(<lv_zever>).
      ASSIGN COMPONENT ms_period-field_zecag OF STRUCTURE <ls_zpren> TO FIELD-SYMBOL(<lv_zecag>).
      ASSIGN COMPONENT ms_period-field_zeccd OF STRUCTURE <ls_zpren> TO FIELD-SYMBOL(<lv_zeccd>).
      ASSIGN COMPONENT ms_period-field_zecon OF STRUCTURE <ls_zpren> TO FIELD-SYMBOL(<lv_zecon>).

      IF <lv_zever> IS NOT ASSIGNED OR <lv_zecag> IS NOT ASSIGNED OR <lv_zeccd> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      IF <lv_zecon> IS ASSIGNED.
        IF <lv_zecon> IS NOT INITIAL.
          RAISE EXCEPTION TYPE /eacm/cx_eacm_posting
            EXPORTING
              iv_text = |Fornitore { <ls_zpren>-lifnr } gia contabilizzato per periodo { ms_period-period_id }/{ ms_zpr23-zelfi(4) }|.
        ENDIF.
      ENDIF.

      CHECK <lv_zever> <> 0 OR <lv_zecag> <> 0 OR <lv_zeccd> <> 0.

      DATA(ls_cont) = VALUE ty_cont(
        xblnr = ms_period-xblnr
        waers = <ls_zpren>-zwaer
        lifnr = <ls_zpren>-lifnr
        zever = <lv_zever>
        zecag = <lv_zecag>
        zeccd = <lv_zeccd> ).

      determine_agent_data(
        EXPORTING
          is_selection     = is_selection
          is_zpren         = <ls_zpren>
          iv_start_quarter = lv_start_quarter
        CHANGING
          cs_cont          = ls_cont ).

      SELECT SINGLE ztpag
        FROM /eacm/zpraa
        WHERE zcdaz = @ls_cont-zcdaz
          AND ( ztpag = @is_selection-ztpag OR @is_selection-ztpag = '' )
        INTO @ls_cont-ztpag.

      SELECT SINGLE zcpena, zceage, zceagp, zmwskz_age
        FROM /eacm/zpr25
        WHERE bukrs = @is_selection-bukrs
          AND ztpag = @ls_cont-ztpag
        INTO (@ls_cont-zcpena, @ls_cont-zceage, @ls_cont-zceagp, @ls_cont-mwskz).

      IF sy-subrc <> 0.
        SELECT SINGLE zcpena, zceage, zceagp, zmwskz_age
          FROM /eacm/zpr25
          WHERE bukrs = @is_selection-bukrs
            AND ztpag = ''
          INTO (@ls_cont-zcpena, @ls_cont-zceage, @ls_cont-zceagp, @ls_cont-mwskz).
      ENDIF.

      IF mv_t_m = 'M'.
        fill_month_specific_data( CHANGING cs_cont = ls_cont ).
      ENDIF.

      COLLECT ls_cont INTO mt_tb_cont.
    ENDLOOP.
  ENDMETHOD.


  METHOD load_agents.
    CLEAR mt_tb_age.

    SELECT *
      FROM /eacm/zpraa
      WHERE ( zcdaz = @is_selection-zcdaz OR @is_selection-zcdaz = '' )
        AND ( ztpag = @is_selection-ztpag OR @is_selection-ztpag = '' )
        AND zstre <> 'D'
        AND erdat <= @is_selection-bldat
        AND zsena <> ''
      ORDER BY zcdaz ASCENDING, erdat DESCENDING
      INTO TABLE @DATA(lt_zpraa_raw).

    LOOP AT lt_zpraa_raw ASSIGNING FIELD-SYMBOL(<ls_zpraa_raw>).
      SELECT SINGLE zcdaz "#EC WARNOK
        FROM /eacm/prcn
        WHERE zcdaz = @<ls_zpraa_raw>-zcdaz
          AND bukrs = @is_selection-bukrs
        INTO @DATA(lv_zcdaz_app).
      CHECK lv_zcdaz_app IS NOT INITIAL.

      IF line_exists( mt_tb_age[ zcdaz = <ls_zpraa_raw>-zcdaz ] ).
        CONTINUE.
      ENDIF.

      APPEND <ls_zpraa_raw> TO mt_tb_age.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_start_quarter.
    DATA lv_mm TYPE n LENGTH 2.

    lv_mm = iv_bldat+4(2).
    WHILE lv_mm <> '01' AND lv_mm <> '04' AND
          lv_mm <> '07' AND lv_mm <> '10'.
      lv_mm = lv_mm - 1.
    ENDWHILE.

    rv_dtit = |{ iv_bldat(4) }{ lv_mm }01|.
  ENDMETHOD.


  METHOD determine_agent_data.
    cs_cont-zcdaz = is_zpren-zcdaz.
    CLEAR: cs_cont-kostl, cs_cont-prctr, cs_cont-zwerks.

    IF cs_cont-zcdaz IS INITIAL.
      LOOP AT mt_tb_age ASSIGNING FIELD-SYMBOL(<ls_age>) WHERE lifnr = is_zpren-lifnr.
        SELECT SINGLE zdtfr
          FROM /eacm/zpr35
          WHERE zcdaz = @<ls_age>-zcdaz
          INTO @DATA(ls_zdtfr).

        IF mv_t_m = 'M'.
          IF ls_zdtfr IS INITIAL OR ls_zdtfr >= is_selection-bldat.
            cs_cont-zcdaz = <ls_age>-zcdaz.
            cs_cont-zwerks = <ls_age>-zwerks.
            EXIT.
          ENDIF.
        ELSE.
          IF ls_zdtfr IS INITIAL OR ls_zdtfr >= iv_start_quarter.
            cs_cont-zcdaz = <ls_age>-zcdaz.
            estrazione_cdc(
              EXPORTING
                iv_zcdaz = cs_cont-zcdaz
              CHANGING
                cv_kostl = cs_cont-kostl
                cv_prctr = cs_cont-prctr ).
            EXIT.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ELSE.
      IF mv_t_m = 'M'.
        SELECT SINGLE zwerks
          FROM /eacm/zpraa
          WHERE zcdaz = @cs_cont-zcdaz
          INTO @cs_cont-zwerks.
      ELSE.
        estrazione_cdc(
          EXPORTING
            iv_zcdaz = cs_cont-zcdaz
          CHANGING
            cv_kostl = cs_cont-kostl
            cv_prctr = cs_cont-prctr ).
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD fill_month_specific_data.
    IF cs_cont-zwerks IS NOT INITIAL.
      SELECT SINGLE kostl, prctr
        FROM /eacm/zpr13_b
        WHERE zwerks = @cs_cont-zwerks
        INTO (@cs_cont-kostl, @cs_cont-prctr).
    ENDIF.

    IF cs_cont-kostl IS INITIAL.
      estrazione_cdc(
        EXPORTING
          iv_zcdaz = cs_cont-zcdaz
        CHANGING
          cv_kostl = cs_cont-kostl
          cv_prctr = cs_cont-prctr ).
    ENDIF.
  ENDMETHOD.


  METHOD estrazione_cdc.
    DATA lv_aufnr TYPE aufnr.

    CLEAR: cv_kostl, cv_prctr.

    LOOP AT mt_tvko ASSIGNING FIELD-SYMBOL(<ls_tvko>) .  "#EC CI_NOORDER  "#EC WARNOK
      contr_area(
        EXPORTING
          iv_bukrs = <ls_tvko>-bukrs
          iv_vkorg = <ls_tvko>-vkorg
          iv_vtweg = ''
          iv_zclpr = ''
          iv_kokrs = mv_kokrs
          iv_zcdaz = iv_zcdaz
          iv_case  = '1'
        CHANGING
          cv_kostl = cv_kostl
          cv_aufnr = lv_aufnr
          cv_prctr = cv_prctr ).

      IF cv_kostl IS NOT INITIAL.
        EXIT.
      ENDIF.
    ENDLOOP.

    CHECK cv_kostl IS INITIAL.

    LOOP AT mt_tvko ASSIGNING <ls_tvko>.  "#EC CI_NOORDER  "#EC WARNOK
      contr_area(
        EXPORTING
          iv_bukrs = <ls_tvko>-bukrs
          iv_vkorg = <ls_tvko>-vkorg
          iv_vtweg = ''
          iv_zclpr = ''
          iv_kokrs = mv_kokrs
          iv_zcdaz = iv_zcdaz
          iv_case  = '2'
        CHANGING
          cv_kostl = cv_kostl
          cv_aufnr = lv_aufnr
          cv_prctr = cv_prctr ).

      IF cv_kostl IS NOT INITIAL.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD contr_area.
    DATA lv_kokrs TYPE kokrs.

    CASE iv_case.
      WHEN '1'.
        lv_kokrs = COND #( WHEN iv_kokrs IS NOT INITIAL THEN iv_kokrs ELSE '9999' ).
        SELECT SINGLE kostl, prctr "#EC WARNOK
          FROM /eacm/zpr13
          WHERE kokrs = @lv_kokrs
            AND vkorg = @iv_vkorg
            AND zcdaz = @iv_zcdaz
          INTO (@cv_kostl, @cv_prctr).

      WHEN '2'.
        lv_kokrs = COND #( WHEN iv_kokrs IS NOT INITIAL THEN iv_kokrs ELSE '9999' ).
        SELECT SINGLE kostl, prctr "#EC WARNOK
          FROM /eacm/zpr13
          WHERE kokrs = @lv_kokrs
            AND vkorg = @iv_vkorg
          INTO (@cv_kostl, @cv_prctr).
    ENDCASE.
  ENDMETHOD.


  METHOD build_assignment_reference.
    IF is_selection-pa_fratt IS INITIAL.
      rv_zuonr = is_selection-p_zuonr.
      RETURN.
    ENDIF.

    SELECT SINGLE * "#EC CI_ALL_FIELDS_NEEDED
      FROM /eacm/zpr43
      WHERE zfratt = @is_selection-pa_fratt
      INTO @DATA(ls_zpr43).

    DO 5 TIMES.
      DATA(lv_idx) = sy-index.
      ASSIGN COMPONENT |ZFIELD{ lv_idx }| OF STRUCTURE ls_zpr43 TO FIELD-SYMBOL(<lv_field_name>).
      ASSIGN COMPONENT |ZLENG{ lv_idx }| OF STRUCTURE ls_zpr43 TO FIELD-SYMBOL(<lv_field_len>).

      IF <lv_field_name> IS NOT ASSIGNED OR <lv_field_name> IS INITIAL.
        CONTINUE.
      ENDIF.

      DATA(lv_piece) = ``.

      CASE <lv_field_name>.
        WHEN 'ZCDAZ'.
          lv_piece = |{ is_cont-zcdaz }|.
          IF lv_piece IS INITIAL.
            READ TABLE mt_tb_age ASSIGNING FIELD-SYMBOL(<ls_age_zuonr>) WITH KEY lifnr = is_cont-lifnr.
            IF sy-subrc = 0.
              lv_piece = |{ <ls_age_zuonr>-zcdaz }|.
            ENDIF.
          ENDIF.
        WHEN 'BUKRS'.
          lv_piece = |{ is_selection-bukrs }|.
        WHEN 'BLDAT'.
          lv_piece = |{ is_selection-bldat(4) }{ is_selection-bldat+4(2) }{ is_selection-bldat+6(2) }|.
        WHEN 'VKORG' OR 'GSBER'.
          CONTINUE.
        WHEN OTHERS.
          ASSIGN COMPONENT <lv_field_name> OF STRUCTURE is_cont TO FIELD-SYMBOL(<lv_cont_field>).
          IF <lv_cont_field> IS ASSIGNED.
            lv_piece = |{ <lv_cont_field> }|.
          ENDIF.
      ENDCASE.

      CONDENSE lv_piece.
      CHECK lv_piece IS NOT INITIAL.

      IF <lv_field_len> IS ASSIGNED.
        IF <lv_field_len> IS INITIAL.
          rv_zuonr = |{ rv_zuonr }{ lv_piece }|.
          CONTINUE.
        ENDIF.

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
    DATA lv_zuonr TYPE dzuonr.
    lv_zuonr = build_assignment_reference(
      is_selection = is_selection
      is_cont      = is_cont ).

    rs_request-company_code = is_selection-bukrs.
    rs_request-document_date = is_selection-bldat.
    rs_request-posting_date = is_selection-budat.
    rs_request-accounting_document_type = is_selection-blart.
    rs_request-original_reference_document = is_cont-xblnr.
    rs_request-document_header_text = |ENASARCO { is_cont-zcdaz }|.
    rs_request-created_by_user = cl_abap_context_info=>get_user_technical_name( ).

    APPEND VALUE /eacm/cl_eacm_journal_post_api=>ty_gl_item(
      gl_account        = is_cont-zcpena
      amount            = is_cont-zever
      currency_code     = is_cont-waers
      debit_credit_code = 'H'
      assignment_ref    = lv_zuonr
      profit_center     = is_cont-prctr
      item_text         = 'ENASARCO' ) TO rs_request-items.

    IF is_cont-zecag <> 0.
      APPEND VALUE /eacm/cl_eacm_journal_post_api=>ty_gl_item(
        gl_account        = is_cont-zceage
        amount            = is_cont-zecag
        currency_code     = is_cont-waers
        debit_credit_code = 'S'
        assignment_ref    = lv_zuonr
        profit_center     = is_cont-prctr
        item_text         = 'CARICO AGENTE' ) TO rs_request-items.
    ENDIF.

    IF is_cont-zeccd > 0.
      APPEND VALUE /eacm/cl_eacm_journal_post_api=>ty_gl_item(
        gl_account        = is_cont-zceagp
        amount            = is_cont-zeccd
        currency_code     = is_cont-waers
        debit_credit_code = 'S'
        assignment_ref    = lv_zuonr
        cost_center       = is_cont-kostl
        profit_center     = COND #( WHEN mv_t_m = 'T' THEN is_cont-prctr ELSE '' )
        item_text         = 'PREVIDENZA' ) TO rs_request-items.
    ELSEIF is_cont-zeccd < 0.
      APPEND VALUE /eacm/cl_eacm_journal_post_api=>ty_gl_item(
        gl_account        = is_cont-zceagp
        amount            = abs( is_cont-zeccd )
        currency_code     = is_cont-waers
        debit_credit_code = 'H'
        assignment_ref    = lv_zuonr
        cost_center       = is_cont-kostl
        tax_code          = COND #( WHEN mv_t_m = 'M' THEN is_cont-mwskz ELSE '' )
        item_text         = 'PREVIDENZA' ) TO rs_request-items.
    ENDIF.
  ENDMETHOD.


  METHOD update_after_success.
    " In RAP non eseguire UPDATE diretti dentro una classe chiamata dal behavior handler.
    " L'aggiornamento dei flag viene fatto nel behavior handler con MODIFY ENTITIES.
  ENDMETHOD.
ENDCLASS.


