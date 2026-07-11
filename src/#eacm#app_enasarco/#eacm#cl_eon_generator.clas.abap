CLASS /EACM/CL_EON_GENERATOR DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_message,
        msgty TYPE c LENGTH 1,
        text  TYPE string,
      END OF ty_message,

      tt_messages   TYPE STANDARD TABLE OF ty_message WITH EMPTY KEY,
      tt_file_lines TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    METHODS generate
      IMPORTING is_selection        TYPE /EACM/A_EON_PAR
      EXPORTING et_file_lines       TYPE tt_file_lines
                et_cessati_lines    TYPE tt_file_lines
                et_messages         TYPE tt_messages
                ev_filename         TYPE string
                ev_cessati_filename TYPE string.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_record1,
        prriga  TYPE c LENGTH 4,
        tpreco  TYPE c LENGTH 1,
        protoc  TYPE c LENGTH 4,
        tpdist  TYPE c LENGTH 2,
        aarife  TYPE c LENGTH 4,
        trrife  TYPE c LENGTH 1,
        trcorr  TYPE c LENGTH 1,
        tpfond  TYPE c LENGTH 1,
        pditta  TYPE c LENGTH 8,
        vuoto25 TYPE c LENGTH 25,
        cdfisc  TYPE c LENGTH 16,
        ragsoc  TYPE c LENGTH 60,
        inperi  TYPE c LENGTH 8,
        fiperi  TYPE c LENGTH 8,
        vuoto47 TYPE c LENGTH 47,
      END OF ty_record1,

      BEGIN OF ty_record2,
        prriga  TYPE n LENGTH 4,
        tpreco  TYPE c LENGTH 1,
        protoc  TYPE c LENGTH 4,
        tpdist  TYPE c LENGTH 2,
        aarife  TYPE c LENGTH 4,
        trrife  TYPE c LENGTH 1,
        trcorr  TYPE c LENGTH 1,
        tpfond  TYPE c LENGTH 1,
        pditta  TYPE c LENGTH 8,
        cdrapp  TYPE c LENGTH 1,
        cfiscs  TYPE c LENGTH 11,
        percen  TYPE n LENGTH 5,
        mtagen  TYPE c LENGTH 8,
        cdfisc  TYPE c LENGTH 16,
        ragsoa  TYPE c LENGTH 60,
        dtiniz  TYPE c LENGTH 8,
        dtcess  TYPE c LENGTH 8,
        tipom1  TYPE c LENGTH 1,
        tipom2  TYPE c LENGTH 1,
        tipom3  TYPE c LENGTH 1,
        tipom4  TYPE c LENGTH 1,
        toimp1  TYPE n LENGTH 10,
        toimp2  TYPE n LENGTH 10,
        toimp3  TYPE n LENGTH 10,
        toimp4  TYPE n LENGTH 10,
        vuoto03 TYPE c LENGTH 3,
      END OF ty_record2,

      BEGIN OF ty_record3,
        prriga   TYPE c LENGTH 4,
        tpreco   TYPE c LENGTH 1,
        protoc   TYPE c LENGTH 4,
        tpdist   TYPE c LENGTH 2,
        aarife   TYPE c LENGTH 4,
        trrife   TYPE c LENGTH 1,
        trcorr   TYPE c LENGTH 1,
        tpfond   TYPE c LENGTH 1,
        pditta   TYPE c LENGTH 8,
        toimp1   TYPE n LENGTH 12,
        toimp2   TYPE n LENGTH 12,
        toimp3   TYPE n LENGTH 12,
        toimp4   TYPE n LENGTH 12,
        vuoto116 TYPE c LENGTH 116,
      END OF ty_record3,

      BEGIN OF ty_rec2,
        zcdaz TYPE /eacm/zpraa-zcdaz,
        mtagen TYPE /eacm/zprsc-zmena,
        cdfisc TYPE /eacm/zprsc-stcd1,
        cfiscs TYPE /eacm/zprsc-stcd1,
        dtcess TYPE /eacm/zpr35-zdtfr,
        toimp1 TYPE /eacm/zpren-zemat1,
        toimp2 TYPE /eacm/zpren-zemat1,
        toimp3 TYPE /eacm/zpren-zemat1,
        toimp4 TYPE /eacm/zpren-zemat1,
        cdrapp TYPE c LENGTH 1,
        tpreco TYPE c LENGTH 1,
        dtiniz TYPE /eacm/zpr35-zdtfr,
        ragsoa TYPE c LENGTH 60,
        zppar TYPE n LENGTH 5,
        tipom1 TYPE c LENGTH 1,
        tipom2 TYPE c LENGTH 1,
        tipom3 TYPE c LENGTH 1,
        tipom4 TYPE c LENGTH 1,
      END OF ty_rec2,

      BEGIN OF ty_tpsoc,
        tpsoc TYPE /eacm/zpraa-ztsoc,
        crapp TYPE c LENGTH 1,
      END OF ty_tpsoc,

      BEGIN OF ty_agent,
        zcdaz TYPE /eacm/zpraa-zcdaz,
        ztsoc TYPE /eacm/zpraa-ztsoc,
        erdat  TYPE /eacm/zpraa-erdat,
        name1  TYPE /eacm/zpraa-name1,
      END OF ty_agent,

      tt_rec2         TYPE STANDARD TABLE OF ty_rec2 WITH EMPTY KEY,
      tt_tpsoc        TYPE STANDARD TABLE OF ty_tpsoc WITH EMPTY KEY,
      tt_r_zcdaz      TYPE RANGE OF /eacm/zpraa-zcdaz,
      tt_r_ztpag      TYPE RANGE OF /eacm/zpraa-ztpag,
      ty_row_counter  TYPE n LENGTH 4,
      ty_externaldate TYPE c LENGTH 8.

    METHODS append_eon_record2
      IMPORTING is_selection      TYPE /EACM/A_EON_PAR
                is_rec2           TYPE ty_rec2
                iv_quarter_end    TYPE d
                iv_split_cessati  TYPE abap_bool
      CHANGING  ct_file_lines     TYPE tt_file_lines
                ct_cessati_lines  TYPE tt_file_lines
                cv_file_row       TYPE ty_row_counter
                cv_cessati_row    TYPE ty_row_counter
                cv_file_tot1      TYPE /eacm/zpren-zfbuto
                cv_file_tot2      TYPE /eacm/zpren-zfbuto
                cv_file_tot3      TYPE /eacm/zpren-zfbuto
                cv_file_tot4      TYPE /eacm/zpren-zfbuto
                cv_cessati_tot1   TYPE /eacm/zpren-zfbuto
                cv_cessati_tot2   TYPE /eacm/zpren-zfbuto
                cv_cessati_tot3   TYPE /eacm/zpren-zfbuto
                cv_cessati_tot4   TYPE /eacm/zpren-zfbuto.

    METHODS get_quarter_dates
      IMPORTING iv_gjahr       TYPE /eacm/zpren-gjahr
                iv_trimes      TYPE c
      EXPORTING ev_start       TYPE d
                ev_end         TYPE d
                ev_start_text  TYPE ty_externaldate
                ev_end_text    TYPE ty_externaldate.

    METHODS is_valid_zprcn
      IMPORTING iv_zcdaz        TYPE /eacm/zpraa-zcdaz
                iv_bukrs        TYPE bukrs
                iv_validity_day TYPE d
      RETURNING VALUE(rv_valid) TYPE abap_bool.

    METHODS pad_left_zero
      IMPORTING iv_value        TYPE clike
                iv_length       TYPE i
      RETURNING VALUE(rv_value) TYPE string.

    METHODS date_to_ddmmyyyy
      IMPORTING iv_date        TYPE d
      RETURNING VALUE(rv_date) TYPE ty_externaldate.

    METHODS eon_file_name
      IMPORTING is_selection       TYPE /EACM/A_EON_PAR
      RETURNING VALUE(rv_filename) TYPE string.

    METHODS record1_to_line
      IMPORTING is_record      TYPE ty_record1
      RETURNING VALUE(rv_line) TYPE string.

    METHODS record2_to_line
      IMPORTING is_record      TYPE ty_record2
      RETURNING VALUE(rv_line) TYPE string.

    METHODS record3_to_line
      IMPORTING is_record      TYPE ty_record3
      RETURNING VALUE(rv_line) TYPE string.
ENDCLASS.

CLASS /EACM/CL_EON_GENERATOR IMPLEMENTATION.
  METHOD generate.

    CLEAR:
      et_file_lines,
      et_cessati_lines,
      et_messages,
      ev_filename,
      ev_cessati_filename.

    DATA(ls_selection) = is_selection.

    IF ls_selection-firr = abap_true.
      ls_selection-trimes = '4'.
    ENDIF.

    IF ls_selection-bukrs IS INITIAL.
      APPEND VALUE #( msgty = 'E' text = 'Societa obbligatoria per estrazione ENASARCO online.' )
        TO et_messages.
      RETURN.
    ENDIF.

    IF ls_selection-gjahr IS INITIAL.
      APPEND VALUE #( msgty = 'E' text = 'Esercizio obbligatorio per estrazione ENASARCO online.' )
        TO et_messages.
      RETURN.
    ENDIF.

    IF ls_selection-trimes NA '1234'.
      APPEND VALUE #( msgty = 'E' text = 'Trimestre non valido: indicare un valore tra 1 e 4.' )
        TO et_messages.
      RETURN.
    ENDIF.

    IF ls_selection-ditta IS INITIAL
    OR ls_selection-cf IS INITIAL
    OR ls_selection-prot IS INITIAL.
      SELECT SINGLE FROM /eacm/zpr01
        FIELDS zcditta, zccfena, zprotd
        WHERE bukrs = @ls_selection-bukrs
        INTO @DATA(ls_zpr01).

      IF sy-subrc = 0.
        IF ls_selection-ditta IS INITIAL.
          ls_selection-ditta = ls_zpr01-zcditta.
        ENDIF.
        IF ls_selection-cf IS INITIAL.
          ls_selection-cf = ls_zpr01-zccfena.
        ENDIF.
        IF ls_selection-prot IS INITIAL.
          ls_selection-prot = ls_zpr01-zprotd.
        ENDIF.
      ENDIF.
    ENDIF.

    IF ls_selection-ditta IS INITIAL.
      APPEND VALUE #( msgty = 'E' text = 'Codice ditta ENASARCO non valorizzato.' )
        TO et_messages.
    ENDIF.

    IF ls_selection-cf IS INITIAL.
      APPEND VALUE #( msgty = 'E' text = 'Codice fiscale ditta ENASARCO non valorizzato.' )
        TO et_messages.
    ENDIF.

    IF ls_selection-prot IS INITIAL.
      APPEND VALUE #( msgty = 'E' text = 'Protocollo ENASARCO non valorizzato.' )
        TO et_messages.
    ENDIF.

    IF line_exists( et_messages[ msgty = 'E' ] ).
      RETURN.
    ENDIF.

    get_quarter_dates(
      EXPORTING
        iv_gjahr      = ls_selection-gjahr
        iv_trimes     = ls_selection-trimes
      IMPORTING
        ev_start      = DATA(lv_quarter_start)
        ev_end        = DATA(lv_quarter_end)
        ev_start_text = DATA(lv_period_start)
        ev_end_text   = DATA(lv_period_end) ).

    ev_filename = |{ eon_file_name( ls_selection ) }.txt|.
    ev_cessati_filename = |{ eon_file_name( ls_selection ) }_cessati.txt|.

    DATA(ls_record1) = VALUE ty_record1(
      prriga = '0000'
      tpreco = '1'
      protoc = ls_selection-prot
      tpdist = '22'
      aarife = ls_selection-gjahr
      trrife = ls_selection-trimes
      trcorr = ls_selection-trimes
      tpfond = COND #( WHEN ls_selection-firr = abap_true THEN 'F' ELSE 'P' )
      pditta = pad_left_zero( iv_value = ls_selection-ditta iv_length = 8 )
      cdfisc = ls_selection-cf
      inperi = lv_period_start
      fiperi = lv_period_end ).

    IF ls_selection-firr = abap_true.
      ls_record1-inperi = |0101{ ls_selection-gjahr }|.
      ls_record1-fiperi = |3112{ ls_selection-gjahr }|.
    ENDIF.

    SELECT SINGLE FROM /eacm/t001
      FIELDS butxt
      WHERE bukrs = @ls_selection-bukrs
      INTO @ls_record1-ragsoc.

    APPEND record1_to_line( ls_record1 ) TO et_file_lines.

    IF ls_selection-SplitCessati = abap_true.
      APPEND record1_to_line( ls_record1 ) TO et_cessati_lines.
    ENDIF.

    DATA(lt_tpsoc) = VALUE tt_tpsoc(
      ( tpsoc = 'SP1' crapp = 'C' )
      ( tpsoc = 'SPA' crapp = 'C' )
      ( tpsoc = 'SR1' crapp = 'C' )
      ( tpsoc = 'SRL' crapp = 'C' ) ).

    DATA lr_zcdaz_filter TYPE tt_r_zcdaz.
    DATA lr_ztpag_filter TYPE tt_r_ztpag.

    IF ls_selection-zcdaz IS NOT INITIAL.
      lr_zcdaz_filter = VALUE #( ( sign = 'I' option = 'EQ' low = ls_selection-zcdaz ) ).
    ENDIF.

    IF ls_selection-ztpag IS NOT INITIAL.
      lr_ztpag_filter = VALUE #( ( sign = 'I' option = 'EQ' low = ls_selection-ztpag ) ).
    ENDIF.

    DATA(lv_filter_zcdaz) = xsdbool( lr_zcdaz_filter IS NOT INITIAL ).
    DATA(lv_filter_ztpag) = xsdbool( lr_ztpag_filter IS NOT INITIAL ).

    SELECT FROM /eacm/zpren
      FIELDS bukrs, gjahr, lifnr, zcdaz, zemat1, zemat2, zemat3, zemat4
      WHERE bukrs = @ls_selection-bukrs
        AND gjahr = @ls_selection-gjahr
        AND ( @lv_filter_zcdaz = @abap_false OR zcdaz IN @lr_zcdaz_filter )
      ORDER BY lifnr
      INTO TABLE @DATA(lt_zpren).

    DATA lt_rec2 TYPE tt_rec2.

    LOOP AT lt_zpren INTO DATA(ls_zpren).
      DATA lv_previous_supplier TYPE abap_bool.
      CLEAR lv_previous_supplier.

      SELECT SINGLE @abap_true
        FROM /eacm/zpraa
        WHERE zcodpre = @ls_zpren-lifnr
          AND erdat <= @lv_quarter_end
        INTO @lv_previous_supplier.

      IF lv_previous_supplier = abap_true.
        APPEND VALUE #(
          msgty = 'W'
          text  = |Riga scartata: fornitore precedente per agente { ls_zpren-zcdaz }, fornitore { ls_zpren-lifnr }.| )
          TO et_messages.
        CONTINUE.
      ENDIF.

      DATA lr_soci TYPE tt_r_zcdaz.
      SELECT FROM /eacm/zpraa
        FIELDS zcdaz
        WHERE lifnr = @ls_zpren-lifnr
          AND erdat <= @lv_quarter_end
        INTO TABLE @DATA(lt_soci_cdaz).

      LOOP AT lt_soci_cdaz INTO DATA(lv_socio_zcdaz).
        APPEND VALUE #( sign = 'I' option = 'EQ' low = lv_socio_zcdaz ) TO lr_soci.
      ENDLOOP.

      DATA ls_agent TYPE ty_agent.
      CLEAR ls_agent.

      IF ls_zpren-zcdaz IS NOT INITIAL.
        SELECT SINGLE FROM /eacm/zpraa
          FIELDS zcdaz, ztsoc, erdat, name1
          WHERE zcdaz = @ls_zpren-zcdaz
            AND ( @lv_filter_ztpag = @abap_false OR ztpag IN @lr_ztpag_filter )
          INTO @ls_agent.
      ENDIF.

      IF ls_agent-zcdaz IS INITIAL.
        SELECT SINGLE FROM /eacm/zpraa AS a
          INNER JOIN /eacm/zpr35 AS b ON a~zcdaz = b~zcdaz
          FIELDS a~zcdaz, a~ztsoc, a~erdat, a~name1
          WHERE a~erdat <= @lv_quarter_end
            AND a~lifnr = @ls_zpren-lifnr
            AND ( @lv_filter_ztpag = @abap_false OR a~ztpag IN @lr_ztpag_filter )
            AND ( @lv_filter_zcdaz = @abap_false OR a~zcdaz IN @lr_zcdaz_filter )
            AND b~zdtfr = '00000000'
          INTO @ls_agent.
      ENDIF.

      IF ls_agent-zcdaz IS INITIAL.
        SELECT SINGLE FROM /eacm/zpraa AS a
          INNER JOIN /eacm/zpr35 AS b ON a~zcdaz = b~zcdaz
          FIELDS a~zcdaz, a~ztsoc, a~erdat, a~name1
          WHERE a~erdat <= @lv_quarter_end
            AND a~lifnr = @ls_zpren-lifnr
            AND ( @lv_filter_ztpag = @abap_false OR a~ztpag IN @lr_ztpag_filter )
            AND ( @lv_filter_zcdaz = @abap_false OR a~zcdaz IN @lr_zcdaz_filter )
            AND b~zdtfr <> '00000000'
          INTO @ls_agent.
      ENDIF.

      IF ls_agent-zcdaz IS INITIAL.
        SELECT SINGLE FROM /eacm/zpraa AS a
          INNER JOIN /eacm/zpr35 AS b ON a~zcdaz = b~zcdaz
          FIELDS a~zcdaz, a~ztsoc, a~erdat, a~name1
          WHERE a~erdat <= @lv_quarter_end
            AND a~zcodpre = @ls_zpren-lifnr
            AND ( @lv_filter_ztpag = @abap_false OR a~ztpag IN @lr_ztpag_filter )
            AND ( @lv_filter_zcdaz = @abap_false OR a~zcdaz IN @lr_zcdaz_filter )
            AND b~zdtfr = '00000000'
          INTO @ls_agent.
      ENDIF.

      IF ls_agent-zcdaz IS INITIAL.
        SELECT SINGLE FROM /eacm/zpraa AS a
          INNER JOIN /eacm/zpr35 AS b ON a~zcdaz = b~zcdaz
          FIELDS a~zcdaz, a~ztsoc, a~erdat, a~name1
          WHERE a~erdat <= @lv_quarter_end
            AND a~zcodpre = @ls_zpren-lifnr
            AND ( @lv_filter_ztpag = @abap_false OR a~ztpag IN @lr_ztpag_filter )
            AND ( @lv_filter_zcdaz = @abap_false OR a~zcdaz IN @lr_zcdaz_filter )
            AND b~zdtfr <> '00000000'
          INTO @ls_agent.
      ENDIF.

      IF ls_agent-zcdaz IS INITIAL.
        APPEND VALUE #(
          msgty = 'W'
          text  = |Agente non trovato per fornitore { ls_zpren-lifnr }.| )
          TO et_messages.
        CONTINUE.
      ENDIF.

      IF ls_selection-firr = abap_true.
        DATA lv_validity_day TYPE d.
        lv_validity_day = |{ ls_selection-gjahr }1231|.
        lv_validity_day += 1.

        DATA(lv_contract_valid) = is_valid_zprcn(
          iv_zcdaz        = ls_agent-zcdaz
          iv_bukrs        = ls_selection-bukrs
          iv_validity_day = lv_validity_day ).

        IF lv_contract_valid = abap_false.
          SELECT FROM /eacm/zpraa
            FIELDS zcdaz
            WHERE erdat <= @lv_quarter_end
              AND lifnr = @ls_zpren-lifnr
              AND zcdaz <> @ls_agent-zcdaz
            INTO TABLE @DATA(lt_alt_agents).

          LOOP AT lt_alt_agents INTO DATA(lv_alt_zcdaz).
            lv_contract_valid = is_valid_zprcn(
              iv_zcdaz        = lv_alt_zcdaz-zcdaz
              iv_bukrs        = ls_selection-bukrs
              iv_validity_day = lv_validity_day ).

            IF lv_contract_valid = abap_true.
              EXIT.
            ENDIF.
          ENDLOOP.
        ENDIF.

        IF lv_contract_valid = abap_false.
          CONTINUE.
        ENDIF.
      ENDIF.

      DATA lv_tman2 TYPE /eacm/prcn-ztman.
      CLEAR lv_tman2.

      SELECT SINGLE FROM /eacm/prcn
        FIELDS ztman
        WHERE bukrs = @ls_selection-bukrs
          AND zcdaz = @ls_agent-zcdaz
          AND zdtfi = '00000000'
        INTO @lv_tman2.

      IF sy-subrc <> 0.
        SELECT SINGLE FROM /eacm/prcn
          FIELDS ztman
          WHERE bukrs = @ls_selection-bukrs
            AND zcdaz = @ls_agent-zcdaz
            AND zdtfi <> '00000000'
          INTO @lv_tman2.
      ENDIF.

DATA: lv_tman TYPE c.
       if  lv_tman2 = 'ES'.
        lv_tman = 'M' .
       ELSE .
        lv_tman = 'P' .
       endif.

      DATA: BEGIN OF ls_zpr35,
              zmena TYPE /eacm/zpr35-zmena,
              zdtfr TYPE /eacm/zpr35-zdtfr,
              zdtin TYPE /eacm/zpr35-zdtin,
            END OF ls_zpr35.

      SELECT SINGLE FROM /eacm/zpr35
        FIELDS zmena, zdtfr, zdtin
        WHERE bukrs = @ls_selection-bukrs
          AND zcdaz = @ls_agent-zcdaz
        INTO @ls_zpr35.

      IF sy-subrc <> 0.
        APPEND VALUE #(
          msgty = 'W'
          text  = |Dati ENASARCO mancanti in /EACM/ZPR35 per agente { ls_agent-zcdaz }, fornitore { ls_zpren-lifnr }.| )
          TO et_messages.
      ENDIF.

      DATA ls_rec2 TYPE ty_rec2.
      ls_rec2-zcdaz = ls_agent-zcdaz.
      ls_rec2-ragsoa = ls_agent-name1.
      ls_rec2-dtcess = ls_zpr35-zdtfr.
      ls_rec2-dtiniz = ls_zpr35-zdtin.
      ls_rec2-mtagen = pad_left_zero( iv_value = ls_zpr35-zmena iv_length = 8 ).

      IF ls_rec2-mtagen IS INITIAL.
        APPEND VALUE #(
          msgty = 'W'
          text  = |Matricola ENASARCO mancante per agente { ls_agent-zcdaz }, fornitore { ls_zpren-lifnr }.| )
          TO et_messages.
      ENDIF.

      IF ls_rec2-dtiniz IS INITIAL.
        APPEND VALUE #(
          msgty = 'E'
          text  = |Data inizio rapporto mancante per agente { ls_agent-zcdaz }.| )
          TO et_messages.
        CONTINUE.
      ENDIF.

      IF ls_rec2-dtcess(4) < ls_selection-gjahr
      AND ls_rec2-dtcess(4) <> '0000'
      AND ls_selection-firr <> abap_true.
        APPEND VALUE #(
          msgty = 'W'
          text  = |Agente { ls_agent-zcdaz } cessato prima dell'esercizio { ls_selection-gjahr }: contributi da modello G14 online.| )
          TO et_messages.
        CONTINUE.
      ENDIF.

      IF ls_rec2-dtcess(4) <= ls_selection-gjahr
      AND ls_rec2-dtcess(4) <> '0000'
      AND ls_selection-firr = abap_true.
        APPEND VALUE #(
          msgty = 'W'
          text  = |Agente { ls_agent-zcdaz } cessato: riga FIRR scartata.| )
          TO et_messages.
        CONTINUE.
      ENDIF.

*Cercare nell'API (non l'ho trovato)
* o in tabella specchio
*      SELECT SINGLE FROM I_Supplier
*        FIELDS TaxNumber1
*        WHERE Supplier = @ls_zpren-lifnr
*        INTO @ls_rec2-cdfisc.

      select single stcd1
         from /eacm/bp_cache
         where business_partner = @ls_zpren-lifnr
         INTO @ls_rec2-cdfisc.

      IF sy-subrc <> 0.
        APPEND VALUE #(
          msgty = 'W'
          text  = |Fornitore { ls_zpren-lifnr } non trovato in /eacm/bp_cache.| )
          TO et_messages.
      ELSEIF ls_rec2-cdfisc IS INITIAL.
        APPEND VALUE #(
          msgty = 'W'
          text  = |Codice fiscale mancante per fornitore { ls_zpren-lifnr }.| )
          TO et_messages.
      ELSE.
        ls_rec2-cdfisc = pad_left_zero( iv_value = ls_rec2-cdfisc iv_length = 11 ).
      ENDIF.

      ls_rec2-cfiscs = '00000000000'.
      ls_rec2-zppar = '00000'.

      CASE ls_selection-trimes.
        WHEN '1'.
          ls_rec2-toimp1 = ls_zpren-zemat1.
          ls_rec2-tipom1 = lv_tman.
        WHEN '2'.
          ls_rec2-toimp2 = ls_zpren-zemat2.
          ls_rec2-tipom1 = lv_tman.
          ls_rec2-tipom2 = lv_tman.
        WHEN '3'.
          ls_rec2-toimp3 = ls_zpren-zemat3.
          ls_rec2-tipom1 = lv_tman.
          ls_rec2-tipom2 = lv_tman.
          ls_rec2-tipom3 = lv_tman.
        WHEN '4'.
          ls_rec2-toimp4 = ls_zpren-zemat4.
          ls_rec2-tipom1 = lv_tman.
          ls_rec2-tipom2 = lv_tman.
          ls_rec2-tipom3 = lv_tman.
          ls_rec2-tipom4 = lv_tman.

          IF ls_selection-firr = abap_true
          AND ls_rec2-dtcess(4) <> ls_selection-gjahr
          AND lr_soci IS NOT INITIAL.
            SELECT SUM( zfpmat )
              FROM /eacm/zprfirr
              WHERE bukrs = @ls_selection-bukrs
                AND gjahr = @ls_selection-gjahr
                AND zcdaz IN @lr_soci
              INTO @ls_rec2-toimp4.
          ENDIF.
      ENDCASE.

      IF ls_rec2-dtcess(4) = ls_selection-gjahr
      AND ls_rec2-dtcess+4(2) <= '03'.
        CLEAR: ls_rec2-tipom2, ls_rec2-tipom3, ls_rec2-tipom4.
      ENDIF.

      IF ls_rec2-dtcess(4) = ls_selection-gjahr
      AND ls_rec2-dtcess+4(2) <= '06'.
        CLEAR: ls_rec2-tipom3, ls_rec2-tipom4.
      ENDIF.

      IF ls_rec2-dtcess(4) = ls_selection-gjahr
      AND ls_rec2-dtcess+4(2) <= '09'.
        CLEAR ls_rec2-tipom4.
      ENDIF.

      IF ls_agent-erdat(4) = ls_selection-gjahr
      AND ls_agent-erdat+4(2) > '03'.
        CLEAR ls_rec2-tipom1.
      ENDIF.

      IF ls_agent-erdat(4) = ls_selection-gjahr
      AND ls_agent-erdat+4(2) > '06'.
        CLEAR: ls_rec2-tipom1, ls_rec2-tipom2.
      ENDIF.

      IF ls_agent-erdat(4) = ls_selection-gjahr
      AND ls_agent-erdat+4(2) > '09'.
        CLEAR: ls_rec2-tipom1, ls_rec2-tipom2, ls_rec2-tipom3.
      ENDIF.

      READ TABLE lt_tpsoc INTO DATA(ls_tpsoc) WITH KEY tpsoc = ls_agent-ztsoc.
      IF sy-subrc = 0.
        ls_rec2-cdrapp = ls_tpsoc-crapp.
      ELSE.
        ls_rec2-cdrapp = 'A'.
      ENDIF.

      DATA lv_partner_count TYPE i.
      CLEAR lv_partner_count.

      IF lr_soci IS NOT INITIAL.
        SELECT COUNT( * )
          FROM /eacm/zprsc
          WHERE zcdaz IN @lr_soci
            AND erdat <= @lv_quarter_end
            AND ( zdtfi >= @lv_quarter_start OR zdtfi = '00000000' )
          INTO @lv_partner_count.
      ENDIF.

      IF lv_partner_count > 0.
        ls_rec2-cdrapp = 'P'.
      ENDIF.

      APPEND ls_rec2 TO lt_rec2.

      IF ls_rec2-cdrapp = 'P'
      AND lr_soci IS NOT INITIAL.
        DATA(ls_partner_base) = ls_rec2.
        ls_partner_base-cfiscs = ls_partner_base-cdfisc.
        ls_partner_base-cdrapp = 'S'.

        SELECT FROM /eacm/zprsc
          FIELDS zppar, stcd1, zmena, name1
          WHERE zcdaz IN @lr_soci
            AND erdat <= @lv_quarter_end
            AND ( zdtfi >= @lv_quarter_start OR zdtfi = '00000000' )
          ORDER BY erdat ASCENDING
          INTO TABLE @DATA(lt_partners).

        DATA lv_partner_sum TYPE /eacm/zppar.
        CLEAR lv_partner_sum.

        LOOP AT lt_partners INTO DATA(ls_partner).
          IF ls_partner-zppar = 0.
            APPEND VALUE #(
              msgty = 'W'
              text  = |Percentuale socio a zero per agente { ls_rec2-zcdaz }, socio { ls_partner-name1 }.| )
              TO et_messages.
          ENDIF.

          IF lv_partner_sum = 100.
            EXIT.
          ENDIF.

          DATA(ls_partner_rec2) = ls_partner_base.
          ls_partner_rec2-zppar = ls_partner-zppar.
          ls_partner_rec2-cdfisc = pad_left_zero( iv_value = ls_partner-stcd1 iv_length = 11 ).
          ls_partner_rec2-mtagen = pad_left_zero( iv_value = ls_partner-zmena iv_length = 8 ).
          ls_partner_rec2-ragsoa = ls_partner-name1.
          CLEAR:
            ls_partner_rec2-toimp1,
            ls_partner_rec2-toimp2,
            ls_partner_rec2-toimp3,
            ls_partner_rec2-toimp4.

          APPEND ls_partner_rec2 TO lt_rec2.
          lv_partner_sum += ls_partner-zppar.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

    IF lt_rec2 IS INITIAL.
      APPEND VALUE #( msgty = 'W' text = 'Nessun agente estratto per il file ENASARCO online.' )
        TO et_messages.
    ENDIF.

    DATA:
      lv_file_row     TYPE ty_row_counter,
      lv_cessati_row  TYPE ty_row_counter,
      lv_file_tot1    TYPE /eacm/zpren-zfbuto,
      lv_file_tot2    TYPE /eacm/zpren-zfbuto,
      lv_file_tot3    TYPE /eacm/zpren-zfbuto,
      lv_file_tot4    TYPE /eacm/zpren-zfbuto,
      lv_cessati_tot1 TYPE /eacm/zpren-zfbuto,
      lv_cessati_tot2 TYPE /eacm/zpren-zfbuto,
      lv_cessati_tot3 TYPE /eacm/zpren-zfbuto,
      lv_cessati_tot4 TYPE /eacm/zpren-zfbuto.

    LOOP AT lt_rec2 INTO DATA(ls_output_rec2) WHERE cdrapp = 'A'.
      append_eon_record2(
        EXPORTING
          is_selection     = ls_selection
          is_rec2          = ls_output_rec2
          iv_quarter_end   = lv_quarter_end
          iv_split_cessati = ls_selection-SplitCessati
        CHANGING
          ct_file_lines    = et_file_lines
          ct_cessati_lines = et_cessati_lines
          cv_file_row      = lv_file_row
          cv_cessati_row   = lv_cessati_row
          cv_file_tot1     = lv_file_tot1
          cv_file_tot2     = lv_file_tot2
          cv_file_tot3     = lv_file_tot3
          cv_file_tot4     = lv_file_tot4
          cv_cessati_tot1  = lv_cessati_tot1
          cv_cessati_tot2  = lv_cessati_tot2
          cv_cessati_tot3  = lv_cessati_tot3
          cv_cessati_tot4  = lv_cessati_tot4 ).
    ENDLOOP.

    LOOP AT lt_rec2 INTO ls_output_rec2 WHERE cdrapp = 'C'.
      append_eon_record2(
        EXPORTING
          is_selection     = ls_selection
          is_rec2          = ls_output_rec2
          iv_quarter_end   = lv_quarter_end
          iv_split_cessati = ls_selection-SplitCessati
        CHANGING
          ct_file_lines    = et_file_lines
          ct_cessati_lines = et_cessati_lines
          cv_file_row      = lv_file_row
          cv_cessati_row   = lv_cessati_row
          cv_file_tot1     = lv_file_tot1
          cv_file_tot2     = lv_file_tot2
          cv_file_tot3     = lv_file_tot3
          cv_file_tot4     = lv_file_tot4
          cv_cessati_tot1  = lv_cessati_tot1
          cv_cessati_tot2  = lv_cessati_tot2
          cv_cessati_tot3  = lv_cessati_tot3
          cv_cessati_tot4  = lv_cessati_tot4 ).
    ENDLOOP.

    LOOP AT lt_rec2 INTO ls_output_rec2 WHERE cdrapp <> 'A' AND cdrapp <> 'C'.
      append_eon_record2(
        EXPORTING
          is_selection     = ls_selection
          is_rec2          = ls_output_rec2
          iv_quarter_end   = lv_quarter_end
          iv_split_cessati = ls_selection-SplitCessati
        CHANGING
          ct_file_lines    = et_file_lines
          ct_cessati_lines = et_cessati_lines
          cv_file_row      = lv_file_row
          cv_cessati_row   = lv_cessati_row
          cv_file_tot1     = lv_file_tot1
          cv_file_tot2     = lv_file_tot2
          cv_file_tot3     = lv_file_tot3
          cv_file_tot4     = lv_file_tot4
          cv_cessati_tot1  = lv_cessati_tot1
          cv_cessati_tot2  = lv_cessati_tot2
          cv_cessati_tot3  = lv_cessati_tot3
          cv_cessati_tot4  = lv_cessati_tot4 ).
    ENDLOOP.

    DATA(ls_record3) = VALUE ty_record3(
      prriga = '9999'
      tpreco = '9'
      protoc = ls_selection-prot
      tpdist = '22'
      aarife = ls_selection-gjahr
      trrife = ls_selection-trimes
      trcorr = ls_selection-trimes
      tpfond = COND #( WHEN ls_selection-firr = abap_true THEN 'F' ELSE 'P' )
      pditta = pad_left_zero( iv_value = ls_selection-ditta iv_length = 8 )
      toimp1 = lv_file_tot1
      toimp2 = lv_file_tot2
      toimp3 = lv_file_tot3
      toimp4 = lv_file_tot4 ).

    APPEND record3_to_line( ls_record3 ) TO et_file_lines.

    IF ls_selection-SplitCessati = abap_true.
      DATA(ls_record3_cessati) = ls_record3.
      ls_record3_cessati-toimp1 = lv_cessati_tot1.
      ls_record3_cessati-toimp2 = lv_cessati_tot2.
      ls_record3_cessati-toimp3 = lv_cessati_tot3.
      ls_record3_cessati-toimp4 = lv_cessati_tot4.

      APPEND record3_to_line( ls_record3_cessati ) TO et_cessati_lines.
    ENDIF.

  ENDMETHOD.

  METHOD append_eon_record2.

    DATA(ls_record2) = VALUE ty_record2(
      tpreco = '2'
      protoc = is_selection-prot
      tpdist = '22'
      aarife = is_selection-gjahr
      trrife = is_selection-trimes
      trcorr = is_selection-trimes
      tpfond = COND #( WHEN is_selection-firr = abap_true THEN 'F' ELSE 'P' )
      pditta = pad_left_zero( iv_value = is_selection-ditta iv_length = 8 )
      cdrapp = is_rec2-cdrapp
      cfiscs = is_rec2-cfiscs
      percen = is_rec2-zppar
      mtagen = is_rec2-mtagen
      cdfisc = is_rec2-cdfisc
      ragsoa = is_rec2-ragsoa
      tipom1 = is_rec2-tipom1
      tipom2 = is_rec2-tipom2
      tipom3 = is_rec2-tipom3
      tipom4 = is_rec2-tipom4
      toimp1 = is_rec2-toimp1
      toimp2 = is_rec2-toimp2
      toimp3 = is_rec2-toimp3
      toimp4 = is_rec2-toimp4 ).

    IF is_rec2-dtcess <= iv_quarter_end
    AND is_rec2-dtcess(4) = is_selection-gjahr.
      ls_record2-dtcess = date_to_ddmmyyyy( is_rec2-dtcess ).
    ELSE.
      ls_record2-dtcess = '00000000'.
    ENDIF.

    IF is_rec2-dtiniz(4) = is_selection-gjahr.
      ls_record2-dtiniz = date_to_ddmmyyyy( is_rec2-dtiniz ).
    ELSE.
      ls_record2-dtiniz = '00000000'.
    ENDIF.

    IF ls_record2-dtiniz <> '00000000'.
      IF is_rec2-dtiniz+4(2) > '09'.
        CLEAR: ls_record2-tipom1, ls_record2-tipom2, ls_record2-tipom3.
      ELSEIF is_rec2-dtiniz+4(2) > '06'.
        CLEAR: ls_record2-tipom1, ls_record2-tipom2.
      ELSEIF is_rec2-dtiniz+4(2) > '03'.
        CLEAR ls_record2-tipom1.
      ENDIF.
    ENDIF.

    IF is_rec2-dtcess <= iv_quarter_end
    AND is_rec2-dtcess IS NOT INITIAL
    AND iv_split_cessati = abap_true.
      cv_cessati_tot1 += is_rec2-toimp1.
      cv_cessati_tot2 += is_rec2-toimp2.
      cv_cessati_tot3 += is_rec2-toimp3.
      cv_cessati_tot4 += is_rec2-toimp4.
      cv_cessati_row += 1.

      ls_record2-prriga = cv_cessati_row.
      APPEND record2_to_line( ls_record2 ) TO ct_cessati_lines.
    ELSE.
      cv_file_tot1 += is_rec2-toimp1.
      cv_file_tot2 += is_rec2-toimp2.
      cv_file_tot3 += is_rec2-toimp3.
      cv_file_tot4 += is_rec2-toimp4.
      cv_file_row += 1.

      ls_record2-prriga = cv_file_row.
      APPEND record2_to_line( ls_record2 ) TO ct_file_lines.
    ENDIF.

  ENDMETHOD.

  METHOD get_quarter_dates.

    CLEAR:
      ev_start,
      ev_end,
      ev_start_text,
      ev_end_text.

    CASE iv_trimes.
      WHEN '1'.
        ev_start = |{ iv_gjahr }0101|.
        ev_end = |{ iv_gjahr }0331|.
        ev_start_text = |0101{ iv_gjahr }|.
        ev_end_text = |3103{ iv_gjahr }|.
      WHEN '2'.
        ev_start = |{ iv_gjahr }0401|.
        ev_end = |{ iv_gjahr }0630|.
        ev_start_text = |0104{ iv_gjahr }|.
        ev_end_text = |3006{ iv_gjahr }|.
      WHEN '3'.
        ev_start = |{ iv_gjahr }0701|.
        ev_end = |{ iv_gjahr }0930|.
        ev_start_text = |0107{ iv_gjahr }|.
        ev_end_text = |3009{ iv_gjahr }|.
      WHEN '4'.
        ev_start = |{ iv_gjahr }1001|.
        ev_end = |{ iv_gjahr }1231|.
        ev_start_text = |0110{ iv_gjahr }|.
        ev_end_text = |3112{ iv_gjahr }|.
    ENDCASE.

  ENDMETHOD.

  METHOD is_valid_zprcn.

    rv_valid = abap_false.

    SELECT SINGLE @abap_true
      FROM /eacm/prcn
      WHERE zcdaz = @iv_zcdaz
        AND bukrs = @iv_bukrs
        AND zdtin <= @iv_validity_day
        AND ( zdtfi >= @iv_validity_day OR zdtfi = '00000000' )
      INTO @rv_valid.

  ENDMETHOD.

  METHOD pad_left_zero.

    rv_value = |{ iv_value }|.
    CONDENSE rv_value NO-GAPS.

    WHILE strlen( rv_value ) < iv_length.
      rv_value = |0{ rv_value }|.
    ENDWHILE.

  ENDMETHOD.

  METHOD date_to_ddmmyyyy.

    IF iv_date IS INITIAL.
      rv_date = '00000000'.
    ELSE.
      rv_date = |{ iv_date+6(2) }{ iv_date+4(2) }{ iv_date(4) }|.
    ENDIF.

  ENDMETHOD.

  METHOD eon_file_name.

    DATA(lv_period) = COND string(
      WHEN is_selection-firr = abap_true THEN 'F'
      ELSE is_selection-trimes ).

    rv_filename = |{ pad_left_zero( iv_value = is_selection-ditta iv_length = 8 ) }_{ pad_left_zero( iv_value = is_selection-prot iv_length = 4 ) }_{ is_selection-gjahr }{ lv_period }|.

  ENDMETHOD.

  METHOD record1_to_line.

    rv_line =
      |{ is_record-prriga WIDTH = 4 }| &&
      |{ is_record-tpreco WIDTH = 1 }| &&
      |{ is_record-protoc WIDTH = 4 }| &&
      |{ is_record-tpdist WIDTH = 2 }| &&
      |{ is_record-aarife WIDTH = 4 }| &&
      |{ is_record-trrife WIDTH = 1 }| &&
      |{ is_record-trcorr WIDTH = 1 }| &&
      |{ is_record-tpfond WIDTH = 1 }| &&
      |{ is_record-pditta WIDTH = 8 }| &&
      |{ is_record-vuoto25 WIDTH = 25 }| &&
      |{ is_record-cdfisc WIDTH = 16 }| &&
      |{ is_record-ragsoc WIDTH = 60 }| &&
      |{ is_record-inperi WIDTH = 8 }| &&
      |{ is_record-fiperi WIDTH = 8 }| &&
      |{ is_record-vuoto47 WIDTH = 47 }|.

  ENDMETHOD.

  METHOD record2_to_line.

    rv_line =
      |{ is_record-prriga WIDTH = 4 }| &&
      |{ is_record-tpreco WIDTH = 1 }| &&
      |{ is_record-protoc WIDTH = 4 }| &&
      |{ is_record-tpdist WIDTH = 2 }| &&
      |{ is_record-aarife WIDTH = 4 }| &&
      |{ is_record-trrife WIDTH = 1 }| &&
      |{ is_record-trcorr WIDTH = 1 }| &&
      |{ is_record-tpfond WIDTH = 1 }| &&
      |{ is_record-pditta WIDTH = 8 }| &&
      |{ is_record-cdrapp WIDTH = 1 }| &&
      |{ is_record-cfiscs WIDTH = 11 }| &&
      |{ is_record-percen WIDTH = 5 }| &&
      |{ is_record-mtagen WIDTH = 8 }| &&
      |{ is_record-cdfisc WIDTH = 16 }| &&
      |{ is_record-ragsoa WIDTH = 60 }| &&
      |{ is_record-dtiniz WIDTH = 8 }| &&
      |{ is_record-dtcess WIDTH = 8 }| &&
      |{ is_record-tipom1 WIDTH = 1 }| &&
      |{ is_record-tipom2 WIDTH = 1 }| &&
      |{ is_record-tipom3 WIDTH = 1 }| &&
      |{ is_record-tipom4 WIDTH = 1 }| &&
      |{ is_record-toimp1 WIDTH = 10 }| &&
      |{ is_record-toimp2 WIDTH = 10 }| &&
      |{ is_record-toimp3 WIDTH = 10 }| &&
      |{ is_record-toimp4 WIDTH = 10 }| &&
      |{ is_record-vuoto03 WIDTH = 3 }|.

  ENDMETHOD.

  METHOD record3_to_line.

    rv_line =
      |{ is_record-prriga WIDTH = 4 }| &&
      |{ is_record-tpreco WIDTH = 1 }| &&
      |{ is_record-protoc WIDTH = 4 }| &&
      |{ is_record-tpdist WIDTH = 2 }| &&
      |{ is_record-aarife WIDTH = 4 }| &&
      |{ is_record-trrife WIDTH = 1 }| &&
      |{ is_record-trcorr WIDTH = 1 }| &&
      |{ is_record-tpfond WIDTH = 1 }| &&
      |{ is_record-pditta WIDTH = 8 }| &&
      |{ is_record-toimp1 WIDTH = 12 }| &&
      |{ is_record-toimp2 WIDTH = 12 }| &&
      |{ is_record-toimp3 WIDTH = 12 }| &&
      |{ is_record-toimp4 WIDTH = 12 }| &&
      |{ is_record-vuoto116 WIDTH = 116 }|.

  ENDMETHOD.
ENDCLASS.



