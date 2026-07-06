CLASS /eacm/cl_enasarco_calculation DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_selection,
        gjahr TYPE gjahr,
        monat TYPE monat,
        bukrs_range TYPE RANGE OF bukrs,
        calculation_mode TYPE c LENGTH 1, " M = mensile, T = trimestrale
        zcdaz_range TYPE RANGE OF /eacm/zpraa-zcdaz,
      END OF ty_selection,

      BEGIN OF ty_message,
        type TYPE symsgty,
        id TYPE symsgid,
        number TYPE symsgno,
        text TYPE string,
      END OF ty_message,
      tt_message TYPE STANDARD TABLE OF ty_message WITH EMPTY KEY,

      BEGIN OF ty_result_log,
        bukrs TYPE bukrs,
        gjahr TYPE gjahr,
        monat TYPE monat,
        lifnr TYPE lifnr,
        name1 TYPE /eacm/zpraa-name1,
        zwaer TYPE waers,
        zemat TYPE /eacm/zmat_01,
        zecca TYPE /eacm/zcca1,
        zecef TYPE /eacm/zcca1,
        zecag TYPE /eacm/zcca1,
        zeccd TYPE /eacm/zcca1,
        zever TYPE /eacm/zcca1,
        is_cessato TYPE abap_bool,
        zdtfr TYPE /eacm/zpr35-zdtfr,
      END OF ty_result_log,
      tt_result_log TYPE STANDARD TABLE OF ty_result_log WITH EMPTY KEY,

      BEGIN OF ty_result,
        has_error TYPE abap_bool,
        messages TYPE tt_message,
        log TYPE tt_result_log,
        zpren_to_save TYPE STANDARD TABLE OF /eacm/zpren WITH EMPTY KEY,
        zpr23_to_update TYPE STANDARD TABLE OF /eacm/zpr23 WITH EMPTY KEY,
      END OF ty_result.

    METHODS calculate
      IMPORTING
        is_selection TYPE ty_selection
        iv_test_mode TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result) TYPE ty_result.

  PRIVATE SECTION.
    DATA mv_test_mode TYPE abap_bool.
    CONSTANTS:
  gc_mode_monthly   TYPE c LENGTH 1 VALUE 'M',
  gc_mode_quarterly TYPE c LENGTH 1 VALUE 'T'.
    TYPES:
      BEGIN OF ty_zpr23,
        bukrs TYPE /eacm/zpr23-bukrs,
        zelin TYPE /eacm/zpr23-zelin,
        zelfi TYPE /eacm/zpr23-zelfi,
        zcoco TYPE /eacm/zpr23-zcoco,
        zccon TYPE /eacm/zpr23-zccon,
        zcimp TYPE /eacm/zpr23-zcimp,
        zperi TYPE /eacm/zpr23-zperi,
      END OF ty_zpr23,
      tt_zpr23 TYPE STANDARD TABLE OF ty_zpr23 WITH EMPTY KEY,

      BEGIN OF ty_agent_key,
        zcdaz TYPE /eacm/zprfac-zcdaz,
        lifnr TYPE /eacm/zprfac-lifnr,
      END OF ty_agent_key,
      tt_agent_key TYPE STANDARD TABLE OF ty_agent_key WITH EMPTY KEY,

      BEGIN OF ty_work,
        bukrs TYPE /eacm/zprfac-bukrs,
        gjahr TYPE /eacm/zprfac-gjahr,
        lifnr TYPE /eacm/zpraa-lifnr,
        zcdaz TYPE /eacm/zprfac-zcdaz,
        zimcoe TYPE /eacm/zprfac-zimcoe,
        zagecae TYPE /eacm/zprfac-zagecae,
        zageffe TYPE /eacm/zprfac-zageffe,
        zwaen TYPE /eacm/zprfac-zwaen,
        waerk TYPE /eacm/zprfac-waerk,
        name1 TYPE /eacm/zpraa-name1,
        znsoc TYPE /eacm/zpraa-znsoc,
        ztsoc TYPE /eacm/zpraa-ztsoc,
        zpage TYPE /eacm/zpr22-zpage,
        zpdit TYPE /eacm/zpr22-zpdit,
        zimin TYPE /eacm/zpr21-zimin,
        zimas TYPE /eacm/zpr21-zimas,
        zsena TYPE /eacm/zpraa-zsena,
        znoena TYPE /eacm/zpraa-znoena,
        zcodpre TYPE /eacm/zpraa-zcodpre,
      END OF ty_work,
      tt_work TYPE STANDARD TABLE OF ty_work WITH EMPTY KEY,
      tt_zpren TYPE STANDARD TABLE OF /eacm/zpren WITH EMPTY KEY.

    DATA ms_selection TYPE ty_selection.
    DATA mt_messages TYPE tt_message.
    DATA mt_log TYPE tt_result_log.
    DATA mt_agents TYPE tt_agent_key.
    DATA mv_stprec TYPE n LENGTH 6.
    DATA mv_stcur TYPE n LENGTH 6.
    DATA mv_endcur TYPE n LENGTH 6.
    DATA mv_end_date TYPE d.
    types: ty_period TYPE n LENGTH 6.

    METHODS validate_selection
      RETURNING VALUE(rv_ok) TYPE abap_bool.

    METHODS determine_period.

    METHODS read_companies_to_process
      RETURNING VALUE(rt_zpr23) TYPE tt_zpr23.

METHODS validate_zpr23
  IMPORTING
    is_zpr23 TYPE ty_zpr23
  RETURNING
    VALUE(rv_ok) TYPE abap_bool.

METHODS check_existing_postings
  IMPORTING
    iv_bukrs TYPE bukrs
    iv_period TYPE ty_period
  RETURNING
    VALUE(rv_exists) TYPE abap_bool.

    METHODS create_work_table
      IMPORTING
        is_zpr23 TYPE ty_zpr23
      RETURNING
        VALUE(rt_work) TYPE tt_work.

    METHODS enrich_work_row
      IMPORTING
        is_zpr23 TYPE ty_zpr23
      CHANGING
        cs_work TYPE ty_work.

    METHODS calculate_work_rows
      IMPORTING
        is_zpr23 TYPE ty_zpr23
        it_work TYPE tt_work
      RETURNING
        VALUE(rt_zpren) TYPE tt_zpren.

    METHODS calculate_row_amounts
      IMPORTING
        is_zpr23 TYPE ty_zpr23
        is_work TYPE ty_work
        is_existing_zpren TYPE /eacm/zpren
        iv_zever_prec TYPE /eacm/zpren-zever1
      CHANGING
        cs_zpren TYPE /eacm/zpren.

    METHODS calculate_minimum
      IMPORTING
        is_zpr23 TYPE ty_zpr23
        is_zpr35 TYPE /eacm/zpr35
        is_zpr21 TYPE /eacm/zpr21
      RETURNING
        VALUE(rv_zimin) TYPE /eacm/zpr21-zimin.

    METHODS count_members
      IMPORTING
        iv_zcdaz TYPE /eacm/zprsc-zcdaz
        iv_end_date TYPE d
      RETURNING
        VALUE(rv_count) TYPE /eacm/zpraa-znsoc.

    METHODS find_agent_contract
      IMPORTING
        iv_lifnr TYPE lifnr
        iv_bukrs TYPE bukrs
        iv_end_date TYPE d
      EXPORTING
        es_zpraa TYPE /eacm/zpraa
        ev_zcdaz TYPE /eacm/zpraa-zcdaz
        ev_ztman TYPE /eacm/ztman.

    METHODS add_agents_without_commissions
      IMPORTING
        is_zpr23 TYPE ty_zpr23
      CHANGING
        ct_work TYPE tt_work.

    METHODS append_message
      IMPORTING
        iv_type TYPE symsgty
        iv_text TYPE string
        iv_id TYPE symsgid OPTIONAL
        iv_number TYPE symsgno OPTIONAL.

   METHODS calculate_qut_rowamounts
      IMPORTING
        is_zpr23 TYPE ty_zpr23
        is_work TYPE ty_work
        is_existing_zpren TYPE /eacm/zpren
        iv_zever_prec TYPE /eacm/zpren-zever1
      CHANGING
        cs_zpren TYPE /eacm/zpren.
ENDCLASS.

CLASS /eacm/cl_enasarco_calculation IMPLEMENTATION.
  METHOD calculate.

    CLEAR rs_result.
    CLEAR: mt_messages, mt_log, mt_agents.
    ms_selection = is_selection.

    mv_test_mode = iv_test_mode.

    IF mv_test_mode = abap_true.
        append_message(
          iv_type = 'I'
          iv_text = 'Esecuzione in modalità TEST: nessun aggiornamento database eseguito.' ).
    ENDIF.

    IF ms_selection-gjahr IS INITIAL OR ms_selection-monat IS INITIAL.
      append_message( iv_type = 'E' iv_text = 'Anno e mese sono obbligatori.' ).
      rs_result-has_error = abap_true.
      rs_result-messages = mt_messages.
      RETURN.
    ENDIF.

    IF ms_selection-monat < '01' OR ms_selection-monat > '12'.
      append_message( iv_type = 'E' iv_text = |Mese non valido: { ms_selection-monat }.| ).
      rs_result-has_error = abap_true.
      rs_result-messages = mt_messages.
      RETURN.
    ENDIF.

    determine_period( ).

    IF validate_selection( ) = abap_false.
      rs_result-has_error = abap_true.
      rs_result-messages = mt_messages.
      RETURN.
    ENDIF.

    DATA(lt_zpr23) = read_companies_to_process( ).

    LOOP AT lt_zpr23 INTO DATA(ls_zpr23).
      IF validate_zpr23( ls_zpr23 ) = abap_false.
        CONTINUE.
      ENDIF.
      DATA(lt_work) = create_work_table( ls_zpr23 ).
      add_agents_without_commissions(
        EXPORTING is_zpr23 = ls_zpr23
        CHANGING  ct_work  = lt_work ).

      DATA(lt_zpren) = calculate_work_rows(
        is_zpr23 = ls_zpr23
        it_work  = lt_work ).

       APPEND LINES OF lt_zpren TO rs_result-zpren_to_save.
    ENDLOOP.

    rs_result-has_error = xsdbool(
      line_exists( mt_messages[ type = 'E' ] )
      OR line_exists( mt_messages[ type = 'A' ] )
      OR line_exists( mt_messages[ type = 'X' ] ) ).
    rs_result-messages = mt_messages.
    rs_result-log = mt_log.

*    DELETE ADJACENT DUPLICATES FROM rs_result-zpren_to_save
*        COMPARING bukrs gjahr lifnr.
    DELETE ADJACENT DUPLICATES FROM rs_result-zpren_to_save
        COMPARING bukrs gjahr lifnr zcdaz.

    if rs_result-has_error = abap_false and
        mv_test_mode = abap_false.

        CLEAR ls_zpr23-zcoco.

        "Se è l'ultimo mese metto la 'S': tutti calcolati
        IF mv_endcur < ls_zpr23-zelfi.
          CLEAR:
            ls_zpr23-zccon,
            ls_zpr23-zcimp.
        ELSE.
          ls_zpr23-zccon = 'S'.
          ls_zpr23-zcimp = 'S'.
        ENDIF.

      APPEND VALUE /eacm/zpr23(
        bukrs = ls_zpr23-bukrs
        zccon = ls_zpr23-zccon
        zcimp = ls_zpr23-zcimp
        zcoco = ls_zpr23-zcoco
        zelin = ls_zpr23-zelin
        zelfi = ls_zpr23-zelfi
        zperi = ls_zpr23-zperi
      ) TO rs_result-zpr23_to_update.

    ENDIF.

  ENDMETHOD.

  METHOD determine_period.
  DATA lv_start_month TYPE n LENGTH 2.
  DATA lv_previous_month TYPE n LENGTH 2.

  IF ms_selection-calculation_mode IS INITIAL.
    ms_selection-calculation_mode = gc_mode_monthly.
  ENDIF.

  IF ms_selection-calculation_mode = gc_mode_quarterly.

    CASE ms_selection-monat.
      WHEN '03'.
        lv_start_month = '01'.
      WHEN '06'.
        lv_start_month = '04'.
      WHEN '09'.
        lv_start_month = '07'.
      WHEN '12'.
        lv_start_month = '10'.
    ENDCASE.

    mv_stcur  = |{ ms_selection-gjahr }{ lv_start_month }|.
    mv_endcur = |{ ms_selection-gjahr }{ ms_selection-monat }|.

    IF lv_start_month = '01'.
      mv_stprec = |{ CONV i( ms_selection-gjahr ) - 1 }12|.
    ELSE.
      lv_previous_month = lv_start_month - 1.
      mv_stprec = |{ ms_selection-gjahr }{ lv_previous_month }|.
    ENDIF.

  ELSE.

    IF ms_selection-monat = '01'.
      mv_stprec = |{ CONV i( ms_selection-gjahr ) - 1 }12|.
      mv_stcur  = |{ ms_selection-gjahr }01|.
      mv_endcur = mv_stcur.
    ELSE.
      lv_previous_month = ms_selection-monat - 1.
      mv_stprec = |{ ms_selection-gjahr }{ lv_previous_month }|.
      mv_stcur  = |{ ms_selection-gjahr }{ ms_selection-monat }|.
      mv_endcur = mv_stcur.
    ENDIF.

  ENDIF.

  mv_end_date = /eacm/cl_last_day_of_month=>get_last_day_of_month(
    iv_gjahr = ms_selection-gjahr
    iv_monat = ms_selection-monat ).




*    DATA lv_previous_month TYPE n LENGTH 2.
*
*    IF ms_selection-monat = '01'.
*      mv_stprec = |{ CONV i( ms_selection-gjahr ) - 1 }12|.
*      mv_stcur = |{ ms_selection-gjahr }01|.
*      mv_endcur = mv_stcur.
*    ELSE.
*      lv_previous_month = ms_selection-monat - 1.
**      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
**        EXPORTING input = lv_previous_month
**        IMPORTING output = lv_previous_month.
*
*      mv_stprec = |{ ms_selection-gjahr }{ lv_previous_month }|.
*      mv_stcur = |{ ms_selection-gjahr }{ ms_selection-monat }|.
*      mv_endcur = mv_stcur.
*    ENDIF.
*
*    DATA(lv_first_day) = CONV d( |{ ms_selection-gjahr }{ ms_selection-monat }01| ).
*    mv_end_date = /EACM/cl_last_day_of_month=>get_last_day_of_month(  iv_gjahr = ms_selection-gjahr  iv_monat = ms_selection-monat ).
  ENDMETHOD.

  METHOD validate_selection.
  IF ms_selection-calculation_mode IS INITIAL.
  ms_selection-calculation_mode = gc_mode_monthly.
ENDIF.

IF ms_selection-calculation_mode <> gc_mode_monthly
AND ms_selection-calculation_mode <> gc_mode_quarterly.
  append_message(
    iv_type = 'E'
    iv_text = 'Tipo calcolo non valido: usare M per mensile o T per trimestrale.' ).
  rv_ok = abap_false.
  RETURN.
ENDIF.

IF ms_selection-calculation_mode = gc_mode_quarterly
AND ms_selection-monat <> '03'
AND ms_selection-monat <> '06'
AND ms_selection-monat <> '09'
AND ms_selection-monat <> '12'.
  append_message(
    iv_type = 'E'
    iv_text = 'Per il calcolo trimestrale il mese deve essere 03, 06, 09 o 12.' ).
  rv_ok = abap_false.
  RETURN.
ENDIF.



    rv_ok = abap_true.

    IF ms_selection-gjahr IS INITIAL OR ms_selection-monat IS INITIAL.
      append_message( iv_type = 'E' iv_text = 'Anno e mese sono obbligatori.' ).
      rv_ok = abap_false.
      RETURN.
    ENDIF.

    IF ms_selection-monat < '01' OR ms_selection-monat > '12'.
      append_message( iv_type = 'E' iv_text = |Mese non valido: { ms_selection-monat }.| ).
      rv_ok = abap_false.
      RETURN.
    ENDIF.

DATA(lv_date) = cl_abap_context_info=>get_system_date( ).
*    IF sy-datum+0(6) < mv_stcur.
    IF lv_date+0(6) < mv_stcur.
      append_message( iv_type = 'E' iv_text = 'Il periodo selezionato è futuro rispetto alla data di sistema.' ).
      rv_ok = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD read_companies_to_process.
    SELECT bukrs, zelin, zelfi, zcoco, zccon, zcimp, zperi
      FROM /eacm/zpr23
      WHERE bukrs IN @ms_selection-bukrs_range
      AND zelfi = @mv_endcur
      INTO TABLE @rt_zpr23.

    IF rt_zpr23 IS INITIAL.
      append_message( iv_type = 'E' iv_text = 'Nessuna società trovata in /EACM/ZPR23 per la selezione.' ).
      RETURN.
    ENDIF.

    LOOP AT rt_zpr23 ASSIGNING FIELD-SYMBOL(<ls_zpr23>).
      <ls_zpr23>-zccon = 'E'.
      <ls_zpr23>-zcimp = 'E'.
      CLEAR <ls_zpr23>-zcoco.
      <ls_zpr23>-zelin = mv_stcur.
      <ls_zpr23>-zelfi = mv_endcur.
      <ls_zpr23>-zperi = mv_endcur+4(2).
    ENDLOOP.
  ENDMETHOD.

  METHOD create_work_table.
    CLEAR rt_work.
  IF ms_selection-calculation_mode = gc_mode_quarterly.

  SELECT bukrs, gjahr, lifnr, zimcoe, zagecae, zageffe, zwaen, waerk, zcdaz, zamcf
    FROM /eacm/zprfac
    WHERE bukrs = @is_zpr23-bukrs
      AND zamcf <= @is_zpr23-zelfi
      AND gjahr = @ms_selection-gjahr
      AND zcdaz IN @ms_selection-zcdaz_range
    INTO TABLE @DATA(lt_zprfac).

ELSE.

*  SELECT bukrs, gjahr, lifnr, zimcoe, zagecae, zageffe, zwaen, waerk, zcdaz, zamcf
*    FROM /eacm/zprfac
*    WHERE bukrs = @is_zpr23-bukrs
*      AND zamcf = @is_zpr23-zelfi
*      AND gjahr = @ms_selection-gjahr
*      AND zcdaz IN @ms_selection-zcdaz_range
*    INTO TABLE @lt_zprfac.

"ATTENZIONE! NON raggruppo per zcdaz, nel risultato questo campo deve essere vuoto
"e non fare da split
  SELECT bukrs, gjahr, lifnr, zwaen, waerk, zamcf,
  sum( zimcoe ) as zimcoe,
  sum( zagecae ) as zagecae,
  sum( zageffe ) as zageffe
  FROM /eacm/zprfac
    WHERE bukrs = @is_zpr23-bukrs
      AND zamcf = @is_zpr23-zelfi
      AND gjahr = @ms_selection-gjahr
      AND zcdaz IN @ms_selection-zcdaz_range
      group by bukrs, gjahr, lifnr, zwaen, waerk, zamcf

    INTO CORRESPONDING FIELDS OF TABLE @lt_zprfac.
ENDIF.
*
*    SELECT bukrs, gjahr, lifnr, zimcoe, zagecae, zageffe, zwaen, waerk, zcdaz
*      FROM /eacm/zprfac
*      WHERE bukrs = @is_zpr23-bukrs
*        AND zamcf = @is_zpr23-zelfi
*        AND gjahr = @ms_selection-gjahr
*        AND zcdaz IN @ms_selection-zcdaz_range
*      INTO TABLE @DATA(lt_zprfac).
*

    LOOP AT lt_zprfac INTO DATA(ls_zprfac).
    "Aggiunta 00 davanti se non ci sono
*    ls_zprfac-lifnr = |{ ls_zprfac-lifnr ALPHA = IN }|.
      DATA(ls_work) = VALUE ty_work(
        bukrs = ls_zprfac-bukrs
        gjahr = ls_zprfac-gjahr
        lifnr = ls_zprfac-lifnr
        zimcoe = ls_zprfac-zimcoe
        zagecae = ls_zprfac-zagecae
        zageffe = ls_zprfac-zageffe
        zwaen = ls_zprfac-zwaen
        waerk = ls_zprfac-waerk
        zcdaz = ls_zprfac-zcdaz ).

      IF ms_selection-calculation_mode = gc_mode_quarterly
        AND NOT ( ls_zprfac-zamcf BETWEEN is_zpr23-zelin AND is_zpr23-zelfi ).
          CLEAR:
            ls_work-zimcoe,
            ls_work-zagecae,
            ls_work-zageffe.
      ENDIF.


      APPEND VALUE ty_agent_key( zcdaz = ls_zprfac-zcdaz lifnr = ls_zprfac-lifnr ) TO mt_agents.

      SELECT lifnr, zcodpre
        FROM /eacm/zpraa
        WHERE zcdaz = @ls_zprfac-zcdaz
          AND erdat <= @mv_end_date
          AND zstre <> 'A'
          AND zstre <> 'S'
          AND zcodpre = @ls_zprfac-lifnr
          AND zsena <> @space
        ORDER BY erdat ASCENDING
        INTO (@ls_work-lifnr, @ls_work-zcodpre)
        UP TO 1 ROWS.
      ENDSELECT.

      IF sy-subrc <> 0.
        SELECT SINGLE zcodpre
          FROM /eacm/zpraa
          WHERE zcdaz = @ls_zprfac-zcdaz
            AND erdat <= @mv_end_date
            AND zstre <> 'A'
            AND zstre <> 'S'
            AND zsena <> @space
          INTO @ls_work-zcodpre.
      ENDIF.

      append ls_work TO rt_work .

*      COLLECT ls_work INTO rt_work.
    ENDLOOP.

    DATA lt_valid_work TYPE tt_work.

    LOOP AT rt_work INTO DATA(ls_valid_work).

      enrich_work_row(
        EXPORTING
          is_zpr23 = is_zpr23
        CHANGING
          cs_work  = ls_valid_work ).

      IF ls_valid_work-zcdaz IS NOT INITIAL.
        APPEND ls_valid_work TO lt_valid_work.
      ENDIF.

    ENDLOOP.

    rt_work = lt_valid_work.

*    LOOP AT rt_work ASSIGNING FIELD-SYMBOL(<ls_work>).
*      enrich_work_row(
*        EXPORTING is_zpr23 = is_zpr23
*        CHANGING  cs_work = <ls_work> ).
*      IF <ls_work>-zcdaz IS INITIAL.
*        DELETE rt_work INDEX sy-tabix.
*      ENDIF.
*    ENDLOOP.
  ENDMETHOD.

  METHOD enrich_work_row.
    DATA ls_zpraa TYPE /eacm/zpraa.
    DATA lv_zcdaz TYPE /eacm/zpraa-zcdaz.
    DATA lv_ztman TYPE /eacm/ztman.

    cs_work-gjahr = is_zpr23-zelin(4).

    find_agent_contract(
      EXPORTING
        iv_lifnr = cs_work-lifnr
        iv_bukrs = cs_work-bukrs
        iv_end_date = mv_end_date
      IMPORTING
        es_zpraa = ls_zpraa
        ev_zcdaz = lv_zcdaz
        ev_ztman = lv_ztman ).

    IF lv_zcdaz IS INITIAL.
      CLEAR cs_work-zcdaz.
      RETURN.
    ENDIF.

    cs_work-zcdaz = lv_zcdaz.
    cs_work-ztsoc = ls_zpraa-ztsoc.
    cs_work-zsena = ls_zpraa-zsena.
    cs_work-znoena = ls_zpraa-znoena.
    cs_work-lifnr = ls_zpraa-lifnr.

*    SELECT SINGLE name1, name2
*      FROM lfa1
*      WHERE lifnr = @cs_work-lifnr
*      INTO @DATA(ls_name).
*    IF sy-subrc = 0.
*      cs_work-name1 = |{ ls_name-name1 } { ls_name-name2 }|.
*    ENDIF.

    cs_work-znsoc = count_members(
      iv_zcdaz = lv_zcdaz
      iv_end_date = mv_end_date ).

    SELECT SINGLE *
      FROM /eacm/zpr22
      WHERE ztcon = 'EN'
        AND ztsoc = @cs_work-ztsoc
        AND ztman = @lv_ztman
        AND gjahr = @ms_selection-gjahr
      INTO @DATA(ls_zpr22).
    IF sy-subrc <> 0.
      SELECT SINGLE *
        FROM /eacm/zpr22
        WHERE ztcon = 'EN'
          AND ztsoc = @cs_work-ztsoc
          AND ztman = @lv_ztman
          AND gjahr = '0000'
        INTO @ls_zpr22.
    ENDIF.
    MOVE-CORRESPONDING ls_zpr22 TO cs_work.

    SELECT SINGLE *
      FROM /eacm/zpr21
      WHERE ztcon = 'EN'
        AND ztsoc = @cs_work-ztsoc
        AND ztman = @lv_ztman
        AND gjahr = @ms_selection-gjahr
      INTO @DATA(ls_zpr21).
    IF sy-subrc <> 0.
      SELECT SINGLE *
        FROM /eacm/zpr21
        WHERE ztcon = 'EN'
          AND ztsoc = @cs_work-ztsoc
          AND ztman = @lv_ztman
          AND gjahr = '0000'
        INTO @ls_zpr21.
    ENDIF.

    SELECT SINGLE * "#EC CI_ALL_FIELDS_NEEDED
      FROM /eacm/zpr35
      WHERE bukrs = @cs_work-bukrs
        AND zcdaz = @lv_zcdaz
      INTO @DATA(ls_zpr35).

    cs_work-zimas = ls_zpr21-zimas.
    cs_work-zimin = calculate_minimum(
      is_zpr23 = is_zpr23
      is_zpr35 = ls_zpr35
      is_zpr21 = ls_zpr21 ).

    IF cs_work-znsoc >= ls_zpr21-znmsoc AND ls_zpr21-zdivmi IS NOT INITIAL.
      cs_work-zimin = cs_work-zimin / ls_zpr21-zdivmi * cs_work-znsoc.
      IF cs_work-zimin > ls_zpr21-zimas.
        cs_work-zimin = ls_zpr21-zimas.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD calculate_work_rows.
    CLEAR rt_zpren.

    LOOP AT it_work INTO DATA(ls_work).
      DATA ls_existing TYPE /eacm/zpren.
      DATA lv_zever_prec TYPE /eacm/zpren-zever1.

      SELECT SINGLE *
        FROM /eacm/zpren
        WHERE bukrs = @ls_work-bukrs
          AND gjahr = @ls_work-gjahr
          AND lifnr = @ls_work-lifnr
          AND zcdaz = @ls_work-zcdaz
        INTO @ls_existing.

      IF sy-subrc <> 0.
        CLEAR ls_existing.
        ls_existing-bukrs = ls_work-bukrs.
        ls_existing-gjahr = ls_work-gjahr.
        ls_existing-lifnr = ls_work-lifnr.
        ls_existing-zcdaz = ls_work-zcdaz.
        ls_existing-zwaer = ls_work-zwaen.
*        Da fare esternamente perchè da qui dumpa
*        IF mv_test_mode = abap_false.
*          INSERT /eacm/zpren FROM @ls_existing.
*        ENDIF.
      ENDIF.

      IF ls_work-zcodpre IS NOT INITIAL.
        SELECT SINGLE zever1, zever2, zever3 "#EC WARNOK
          FROM /eacm/zpren
          WHERE bukrs = @ls_work-bukrs
            AND gjahr = @ls_work-gjahr
            AND lifnr = @ls_work-zcodpre
          INTO @DATA(ls_previous_supplier).
        IF sy-subrc = 0.
          lv_zever_prec = ls_previous_supplier-zever1 + ls_previous_supplier-zever2 + ls_previous_supplier-zever3.
        ENDIF.
      ENDIF.

      DATA(ls_new) = ls_existing.
      calculate_row_amounts(
        EXPORTING
          is_zpr23 = is_zpr23
          is_work = ls_work
          is_existing_zpren = ls_existing
          iv_zever_prec = lv_zever_prec
        CHANGING
          cs_zpren = ls_new ).

      APPEND ls_new TO rt_zpren.
    ENDLOOP.
  ENDMETHOD.

  METHOD calculate_row_amounts.
    FIELD-SYMBOLS:
      <zemat> TYPE any,
      <zecca> TYPE any,
      <zecef> TYPE any,
      <zecag> TYPE any,
      <zeccd> TYPE any,
      <zever> TYPE any,
      <field> TYPE any.

IF ms_selection-calculation_mode = gc_mode_quarterly.
  calculate_qut_rowamounts(
    EXPORTING
      is_zpr23 = is_zpr23
      is_work = is_work
      is_existing_zpren = is_existing_zpren
      iv_zever_prec = iv_zever_prec
    CHANGING
      cs_zpren = cs_zpren ).
  RETURN.
ENDIF.
    ASSIGN COMPONENT |ZEMAT_{ ms_selection-monat }| OF STRUCTURE cs_zpren TO <zemat>.
    ASSIGN COMPONENT |ZECCA_{ ms_selection-monat }| OF STRUCTURE cs_zpren TO <zecca>.
    ASSIGN COMPONENT |ZECEF_{ ms_selection-monat }| OF STRUCTURE cs_zpren TO <zecef>.
    ASSIGN COMPONENT |ZECAG_{ ms_selection-monat }| OF STRUCTURE cs_zpren TO <zecag>.
    ASSIGN COMPONENT |ZECCD_{ ms_selection-monat }| OF STRUCTURE cs_zpren TO <zeccd>.
    ASSIGN COMPONENT |ZEVER_{ ms_selection-monat }| OF STRUCTURE cs_zpren TO <zever>.

    IF <zemat> IS NOT ASSIGNED
    OR <zecca> IS NOT ASSIGNED
    OR <zecef> IS NOT ASSIGNED
    OR <zecag> IS NOT ASSIGNED
    OR <zeccd> IS NOT ASSIGNED
    OR <zever> IS NOT ASSIGNED.
      append_message(
        iv_type = 'E'
        iv_text = |Errore assegnazione campi mese { ms_selection-monat }.| ).
      RETURN.
    ENDIF.

    DATA lv_tot_cal TYPE /eacm/zpren-zecca1.
    DATA lv_tot_eff TYPE /eacm/zpren-zecef1.
    DATA lv_tot_ver TYPE /eacm/zpren-zever1.

    DATA(lv_month) = ms_selection-monat.
    WHILE lv_month >= 2.
      lv_month = lv_month - 1.

      ASSIGN COMPONENT |ZECCA_{ lv_month }| OF STRUCTURE cs_zpren TO <field>.
      IF sy-subrc = 0. lv_tot_cal += <field>. ENDIF.

      ASSIGN COMPONENT |ZECEF_{ lv_month }| OF STRUCTURE cs_zpren TO <field>.
      IF sy-subrc = 0. lv_tot_eff += <field>. ENDIF.

      ASSIGN COMPONENT |ZEVER_{ lv_month }| OF STRUCTURE cs_zpren TO <field>.
      IF sy-subrc = 0. lv_tot_ver += <field>. ENDIF.
    ENDWHILE.
    lv_tot_ver += iv_zever_prec.

    <zemat> = is_work-zimcoe.
    <zecca> = is_work-zimcoe * ( is_work-zpdit + is_work-zpage ) / 100.

    lv_tot_cal += <zecca>.

    IF lv_tot_ver >= is_work-zimas.
      <zever> = 0.
      <zecef> = 0.
    ELSEIF lv_tot_ver >= is_work-zimin.
      IF lv_tot_cal <= is_work-zimin.
        <zever> = 0.
        <zecef> = <zecca>.
      ELSEIF lv_tot_cal >= is_work-zimas.
        <zever> = is_work-zimas - lv_tot_ver.
        <zecef> = is_work-zimas - lv_tot_eff.
      ELSE.
        <zever> = lv_tot_cal - lv_tot_ver.
        <zecef> = lv_tot_cal - lv_tot_eff.
      ENDIF.
    ELSE.
      IF lv_tot_cal <= is_work-zimin.
        <zever> = is_work-zimin - lv_tot_ver.
        <zecef> = <zecca>.
      ELSEIF lv_tot_cal >= is_work-zimas.
        <zever> = is_work-zimas - lv_tot_ver.
        <zecef> = is_work-zimas - lv_tot_eff.
      ELSE.
        <zever> = lv_tot_cal - lv_tot_ver.
        <zecef> = <zecca>.
      ENDIF.
    ENDIF.

    IF <zever> < 0. <zever> = 0. ENDIF.
    IF <zecef> < 0. <zecef> = 0. ENDIF.

    <zecag> = is_work-zageffe.
    <zeccd> = <zever> - <zecag>.

    cs_zpren-zwaer = is_work-zwaen.

    CASE ms_selection-monat.
      WHEN '01' OR '02' OR '03'.
        cs_zpren-zemat1 = cs_zpren-zemat_01 + cs_zpren-zemat_02 + cs_zpren-zemat_03.
        cs_zpren-zecca1 = cs_zpren-zecca_01 + cs_zpren-zecca_02 + cs_zpren-zecca_03.
        cs_zpren-zecef1 = cs_zpren-zecef_01 + cs_zpren-zecef_02 + cs_zpren-zecef_03.
        cs_zpren-zecag1 = cs_zpren-zecag_01 + cs_zpren-zecag_02 + cs_zpren-zecag_03.
        cs_zpren-zeccd1 = cs_zpren-zeccd_01 + cs_zpren-zeccd_02 + cs_zpren-zeccd_03.
        cs_zpren-zever1 = cs_zpren-zever_01 + cs_zpren-zever_02 + cs_zpren-zever_03.
      WHEN '04' OR '05' OR '06'.
        cs_zpren-zemat2 = cs_zpren-zemat_04 + cs_zpren-zemat_05 + cs_zpren-zemat_06.
        cs_zpren-zecca2 = cs_zpren-zecca_04 + cs_zpren-zecca_05 + cs_zpren-zecca_06.
        cs_zpren-zecef2 = cs_zpren-zecef_04 + cs_zpren-zecef_05 + cs_zpren-zecef_06.
        cs_zpren-zecag2 = cs_zpren-zecag_04 + cs_zpren-zecag_05 + cs_zpren-zecag_06.
        cs_zpren-zeccd2 = cs_zpren-zeccd_04 + cs_zpren-zeccd_05 + cs_zpren-zeccd_06.
        cs_zpren-zever2 = cs_zpren-zever_04 + cs_zpren-zever_05 + cs_zpren-zever_06.
      WHEN '07' OR '08' OR '09'.
        cs_zpren-zemat3 = cs_zpren-zemat_07 + cs_zpren-zemat_08 + cs_zpren-zemat_09.
        cs_zpren-zecca3 = cs_zpren-zecca_07 + cs_zpren-zecca_08 + cs_zpren-zecca_09.
        cs_zpren-zecef3 = cs_zpren-zecef_07 + cs_zpren-zecef_08 + cs_zpren-zecef_09.
        cs_zpren-zecag3 = cs_zpren-zecag_07 + cs_zpren-zecag_08 + cs_zpren-zecag_09.
        cs_zpren-zeccd3 = cs_zpren-zeccd_07 + cs_zpren-zeccd_08 + cs_zpren-zeccd_09.
        cs_zpren-zever3 = cs_zpren-zever_07 + cs_zpren-zever_08 + cs_zpren-zever_09.
      WHEN '10' OR '11' OR '12'.
        cs_zpren-zemat4 = cs_zpren-zemat_10 + cs_zpren-zemat_11 + cs_zpren-zemat_12.
        cs_zpren-zecca4 = cs_zpren-zecca_10 + cs_zpren-zecca_11 + cs_zpren-zecca_12.
        cs_zpren-zecef4 = cs_zpren-zecef_10 + cs_zpren-zecef_11 + cs_zpren-zecef_12.
        cs_zpren-zecag4 = cs_zpren-zecag_10 + cs_zpren-zecag_11 + cs_zpren-zecag_12.
        cs_zpren-zeccd4 = cs_zpren-zeccd_10 + cs_zpren-zeccd_11 + cs_zpren-zeccd_12.
        cs_zpren-zever4 = cs_zpren-zever_10 + cs_zpren-zever_11 + cs_zpren-zever_12.
    ENDCASE.

    APPEND VALUE ty_result_log(
      bukrs = is_work-bukrs
      gjahr = is_work-gjahr
      monat = ms_selection-monat
      lifnr = is_work-lifnr
      name1 = is_work-name1
      zwaer = cs_zpren-zwaer
      zemat = <zemat>
      zecca = <zecca>
      zecef = <zecef>
      zecag = <zecag>
      zeccd = <zeccd>
      zever = <zever> ) TO mt_log.
  ENDMETHOD.

  METHOD calculate_minimum.
    DATA lv_trim TYPE i.

    IF is_zpr23-zelfi+4(2) = '03'
    OR is_zpr23-zelfi+4(2) = '06'
    OR is_zpr23-zelfi+4(2) = '09'
    OR is_zpr23-zelfi+4(2) = '12'.
      IF is_zpr35-zdtfr IS NOT INITIAL
      AND is_zpr35-zdtfr <= mv_end_date
      AND is_zpr35-zdtin(4) <> ms_selection-gjahr.
        lv_trim = trunc( ( CONV i( is_zpr35-zdtfr+4(2) ) + 2 ) / 3 ).
      ELSEIF is_zpr35-zdtin(4) <> ms_selection-gjahr.
        lv_trim = trunc( CONV i( is_zpr23-zelfi+4(2) ) / 3 ).
      ELSE.
        lv_trim = trunc( ( CONV i( is_zpr23-zelfi+4(2) ) - CONV i( is_zpr35-zdtin+4(2) ) ) / 3 ) + 1.
      ENDIF.
      rv_zimin = is_zpr21-zimin * lv_trim.
    ELSE.
      CLEAR rv_zimin.
    ENDIF.
  ENDMETHOD.

  METHOD count_members.
    DATA lv_begin_date TYPE d.
    DATA lv_month TYPE n LENGTH 2.
    data i_count type i.


    lv_month = iv_end_date+4(2) - 2.
    lv_begin_date = |{ iv_end_date(4) }{ lv_month }01|.

    SELECT erdat
      FROM /eacm/zprsc
      WHERE zcdaz = @iv_zcdaz
        AND erdat <= @iv_end_date
        AND zdtfi >= @lv_begin_date
        AND zstre <> 'A'
        AND zmena <> 0
      ORDER BY erdat DESCENDING
      INTO @DATA(lv_erdat)
      UP TO 1 ROWS.
    ENDSELECT.

    IF sy-subrc = 0.
      SELECT COUNT(*)
        FROM /eacm/zprsc
        WHERE zcdaz = @iv_zcdaz
          AND erdat = @lv_erdat
          AND zdtfi >= @lv_begin_date
          AND zstre <> 'A'
          AND zmena <> 0
        INTO @i_count.
    ENDIF.

rv_count = i_count.
    IF rv_count = 0.
      rv_count = 1.
    ENDIF.
  ENDMETHOD.

  METHOD find_agent_contract.
    CLEAR: es_zpraa, ev_zcdaz, ev_ztman.

    SELECT lifnr, zcdaz, zcodpre, znoena, zsena, ztsoc
      FROM /eacm/zpraa
      WHERE erdat <= @iv_end_date
        AND lifnr = @iv_lifnr
        AND zstre <> 'A'
        AND zstre <> 'S'
        AND zsena <> @space
      ORDER BY erdat DESCENDING
      INTO CORRESPONDING FIELDS OF @es_zpraa.

      SELECT ztman
        FROM /eacm/prcn
        WHERE zcdaz = @es_zpraa-zcdaz
          AND bukrs = @iv_bukrs
          AND zdtin <= @iv_end_date
        ORDER BY zdtin DESCENDING
        INTO @ev_ztman
        UP TO 1 ROWS.
      ENDSELECT.

      IF sy-subrc = 0.
        ev_zcdaz = es_zpraa-zcdaz.
        EXIT.
      ENDIF.
    ENDSELECT.
  ENDMETHOD.

  METHOD add_agents_without_commissions.
    DATA lv_first_day TYPE d.
    DATA lv_last_day TYPE d.

    lv_first_day = |{ ms_selection-gjahr }{ ms_selection-monat }01|.
    lv_last_day = mv_end_date.

    SELECT a~lifnr, b~bukrs, b~zcdaz
      FROM /eacm/zpraa AS a
      INNER JOIN /eacm/prcn AS b ON a~zcdaz = b~zcdaz
      INNER JOIN /eacm/zpr35 AS c ON b~bukrs = c~bukrs AND b~zcdaz = c~zcdaz
      WHERE a~zsena = 'X'
        AND a~zstre <> 'A'
        AND a~zstre <> 'S'
        AND b~bukrs = @is_zpr23-bukrs
        AND ( b~zdtin <= @lv_last_day OR b~zdtin = '00000000' )
        AND ( b~zdtfi >= @lv_first_day OR b~zdtfi = '00000000' )
        AND ( c~zdtfr = '00000000' OR c~zdtfr >= @lv_first_day )
        AND ( c~zdtin <= @lv_last_day OR c~zdtin = '00000000' )
      INTO TABLE @DATA(lt_agents).

    LOOP AT lt_agents INTO DATA(ls_agent).
      IF line_exists( ct_work[ bukrs = ls_agent-bukrs lifnr = ls_agent-lifnr ] ).
        CONTINUE.
      ENDIF.

      APPEND VALUE ty_work(
        bukrs = ls_agent-bukrs
        gjahr = ms_selection-gjahr
        lifnr = ls_agent-lifnr
        zcdaz = ls_agent-zcdaz
        zwaen = 'EUR' ) TO ct_work.
    ENDLOOP.

    LOOP AT ct_work ASSIGNING FIELD-SYMBOL(<ls_work>) WHERE name1 IS INITIAL.
      enrich_work_row(
        EXPORTING is_zpr23 = is_zpr23
        CHANGING  cs_work = <ls_work> ).
    ENDLOOP.
  ENDMETHOD.

  METHOD append_message.
    APPEND VALUE ty_message(
      type = iv_type
      id = iv_id
      number = iv_number
      text = iv_text ) TO mt_messages.
  ENDMETHOD.
  METHOD calculate_qut_rowamounts.

  FIELD-SYMBOLS:
    <zemat> TYPE any,
    <zecca> TYPE any,
    <zecef> TYPE any,
    <zecag> TYPE any,
    <zeccd> TYPE any,
    <zever> TYPE any.

  DATA lv_quarter TYPE n LENGTH 1.
  DATA lv_tot_cal TYPE /eacm/zpren-zecca1.
  DATA lv_tot_eff TYPE /eacm/zpren-zecef1.
  DATA lv_tot_ver TYPE /eacm/zpren-zever1.

  CASE ms_selection-monat.
    WHEN '03'.
      lv_quarter = '1'.
      lv_tot_cal = 0.
      lv_tot_eff = 0.
      lv_tot_ver = 0.
    WHEN '06'.
      lv_quarter = '2'.
      lv_tot_cal = cs_zpren-zecca1.
      lv_tot_eff = cs_zpren-zecef1.
      lv_tot_ver = cs_zpren-zever1 + iv_zever_prec.
    WHEN '09'.
      lv_quarter = '3'.
      lv_tot_cal = cs_zpren-zecca1 + cs_zpren-zecca2.
      lv_tot_eff = cs_zpren-zecef1 + cs_zpren-zecef2.
      lv_tot_ver = cs_zpren-zever1 + cs_zpren-zever2 + iv_zever_prec.
    WHEN '12'.
      lv_quarter = '4'.
      lv_tot_cal = cs_zpren-zecca1 + cs_zpren-zecca2 + cs_zpren-zecca3.
      lv_tot_eff = cs_zpren-zecef1 + cs_zpren-zecef2 + cs_zpren-zecef3.
      lv_tot_ver = cs_zpren-zever1 + cs_zpren-zever2 + cs_zpren-zever3 + iv_zever_prec.
  ENDCASE.

  ASSIGN COMPONENT |ZEMAT{ lv_quarter }| OF STRUCTURE cs_zpren TO <zemat>.
  ASSIGN COMPONENT |ZECCA{ lv_quarter }| OF STRUCTURE cs_zpren TO <zecca>.
  ASSIGN COMPONENT |ZECEF{ lv_quarter }| OF STRUCTURE cs_zpren TO <zecef>.
  ASSIGN COMPONENT |ZECAG{ lv_quarter }| OF STRUCTURE cs_zpren TO <zecag>.
  ASSIGN COMPONENT |ZECCD{ lv_quarter }| OF STRUCTURE cs_zpren TO <zeccd>.
  ASSIGN COMPONENT |ZEVER{ lv_quarter }| OF STRUCTURE cs_zpren TO <zever>.

  IF <zemat> IS NOT ASSIGNED
  OR <zecca> IS NOT ASSIGNED
  OR <zecef> IS NOT ASSIGNED
  OR <zecag> IS NOT ASSIGNED
  OR <zeccd> IS NOT ASSIGNED
  OR <zever> IS NOT ASSIGNED.
    append_message(
      iv_type = 'E'
      iv_text = |Errore assegnazione campi trimestre { lv_quarter }.| ).
    RETURN.
  ENDIF.

  <zemat> = is_work-zimcoe.
  <zecca> = is_work-zimcoe * ( is_work-zpdit + is_work-zpage ) / 100.

  lv_tot_cal += <zecca>.

  IF lv_tot_ver >= is_work-zimas.
    <zever> = 0.
    <zecef> = 0.
  ELSEIF lv_tot_ver >= is_work-zimin.
    IF lv_tot_cal <= is_work-zimin.
      <zever> = 0.
      <zecef> = <zecca>.
    ELSEIF lv_tot_cal >= is_work-zimas.
      <zever> = is_work-zimas - lv_tot_ver.
      <zecef> = is_work-zimas - lv_tot_eff.
    ELSE.
      <zever> = lv_tot_cal - lv_tot_ver.
      <zecef> = lv_tot_cal - lv_tot_eff.
    ENDIF.
  ELSE.
    IF lv_tot_cal <= is_work-zimin.
      <zever> = is_work-zimin - lv_tot_ver.
      <zecef> = <zecca>.
    ELSEIF lv_tot_cal >= is_work-zimas.
      <zever> = is_work-zimas - lv_tot_ver.
      <zecef> = is_work-zimas - lv_tot_eff.
    ELSE.
      <zever> = lv_tot_cal - lv_tot_ver.
      <zecef> = <zecca>.
    ENDIF.
  ENDIF.

  IF <zever> < 0.
    <zever> = 0.
  ENDIF.

  IF <zecef> < 0.
    <zecef> = 0.
  ENDIF.

  <zecag> = is_work-zageffe.
  <zeccd> = <zever> - <zecag>.

  cs_zpren-zwaer = is_work-zwaen.

  APPEND VALUE ty_result_log(
    bukrs = is_work-bukrs
    gjahr = is_work-gjahr
    monat = ms_selection-monat
    lifnr = is_work-lifnr
    name1 = is_work-name1
    zwaer = cs_zpren-zwaer
    zemat = <zemat>
    zecca = <zecca>
    zecef = <zecef>
    zecag = <zecag>
    zeccd = <zeccd>
    zever = <zever> ) TO mt_log.

ENDMETHOD.
METHOD validate_zpr23.

  rv_ok = abap_true.

  DATA lv_some_posted TYPE abap_bool.

  " Periodo precedente non contabilizzato
  IF mv_stprec > is_zpr23-zelin
  OR ( mv_stprec = is_zpr23-zelin
       AND is_zpr23-zcoco <> 'C' ).

    append_message(
      iv_type = 'E'
      iv_text = |Eseguire prima la contabilizzazione del periodo precedente per società { is_zpr23-bukrs }.| ).

    rv_ok = abap_false.
    RETURN.

  ENDIF.

  " Periodo già contabilizzato
  IF mv_stcur = is_zpr23-zelin
  AND is_zpr23-zcoco = 'C'.

    append_message(
      iv_type = 'E'
      iv_text = |Periodo già contabilizzato per società { is_zpr23-bukrs }.| ).

    rv_ok = abap_false.
    RETURN.

  ENDIF.

  " Periodo precedente già chiuso
  IF mv_stcur < is_zpr23-zelin.

    append_message(
      iv_type = 'E'
      iv_text = |Periodo già chiuso per società { is_zpr23-bukrs }.| ).

    rv_ok = abap_false.
    RETURN.

  ENDIF.

  " Controllo contabilizzazioni parziali
  lv_some_posted = check_existing_postings(
    iv_bukrs = is_zpr23-bukrs
    iv_period = mv_stcur ).

  IF mv_stcur = is_zpr23-zelin
  AND lv_some_posted = abap_true.

    append_message(
      iv_type = 'E'
      iv_text = |Esistono già agenti contabilizzati per società { is_zpr23-bukrs }.| ).

    rv_ok = abap_false.
    RETURN.

  ENDIF.

ENDMETHOD.

METHOD check_existing_postings.

  FIELD-SYMBOLS <field> TYPE any.

  DATA lv_field_name TYPE string.

  rv_exists = abap_false.

  lv_field_name = |ZECON_{ iv_period+4(2) }|.

  SELECT * "#EC CI_ALL_FIELDS_NEEDED
    FROM /eacm/zpren
    WHERE bukrs = @iv_bukrs
      AND gjahr = @iv_period(4)
    INTO TABLE @DATA(lt_zpren).

  LOOP AT lt_zpren ASSIGNING FIELD-SYMBOL(<ls_zpren>). "#EC CI_NOORDER  "#EC WARNOK

    ASSIGN COMPONENT lv_field_name
      OF STRUCTURE <ls_zpren>
      TO <field>.

    IF sy-subrc = 0
    AND <field> IS NOT INITIAL.

      rv_exists = abap_true.
      RETURN.

    ENDIF.

  ENDLOOP.

ENDMETHOD.
ENDCLASS.
