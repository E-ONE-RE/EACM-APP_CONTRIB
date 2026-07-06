CLASS LHC_/EACM/R_ZPREN DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR /eacm/rZpren
        RESULT result.

    METHODS PostEnasarco
      FOR MODIFY
      IMPORTING keys FOR ACTION /eacm/rZpren~PostEnasarco.

    METHODS calculateEnasarco
      FOR MODIFY
      IMPORTING keys FOR ACTION /eacm/rZpren~calculateEnasarco.
*      RESULT result.

    METHODS GenerateEnasarcoOnline
      FOR MODIFY
      IMPORTING keys FOR ACTION /eacm/rZpren~GenerateEnasarcoOnline.
*      RESULT result.

ENDCLASS.

CLASS LHC_/EACM/R_ZPREN IMPLEMENTATION.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  ENDMETHOD.

  METHOD PostEnasarco.

    DATA lv_success_count TYPE i.
    DATA lv_error_count   TYPE i.
    DATA lv_info_text     TYPE string.
    DATA lt_post_update TYPE TABLE FOR UPDATE /EACM/R_ZPREN.
    data w_kokrs type kokrs.

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

    select single kokrs  from /eacm/t001
        where bukrs = @<ls_key>-%param-Bukrs
        into @w_kokrs .


      TRY.
          DATA(lo_job) = NEW /eacm/cl_eacm_posting_job( ).
          DATA(lt_result) = lo_job->run(
            VALUE /eacm/cl_eacm_zpren_posting_tm=>ty_selection(
              bukrs    = <ls_key>-%param-Bukrs
              bldat    = lv_document_date
              budat    = lv_posting_date
              blart    = lv_blart
              zcdaz    = <ls_key>-%param-Zcdaz
              ztpag    = <ls_key>-%param-Ztpag
              pa_fratt = <ls_key>-%param-AssignmentRule
              p_zuonr  = <ls_key>-%param-AssignmentReference
              kokrs    = w_kokrs
              pa_test  = <ls_key>-%param-PaTest ) ).

          READ TABLE lt_result INTO DATA(ls_error_result)
            WITH KEY success = abap_false.

          IF sy-subrc = 0.
            lv_error_count += 1.

            APPEND VALUE #(
              %msg = new_message_with_text(
                       severity = if_abap_behv_message=>severity-error
                       text     = ls_error_result-message_text ) ) TO reported-/eacm/rzpren.

            LOOP AT ls_error_result-message_details INTO DATA(lv_message_detail).
              APPEND VALUE #(
                %msg = new_message_with_text(
                         severity = if_abap_behv_message=>severity-error
                         text     = lv_message_detail ) ) TO reported-/eacm/rzpren.
            ENDLOOP.

            CONTINUE.
          ENDIF.

          IF <ls_key>-%param-PaTest <> abap_true.
            LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<ls_post_result>) WHERE success = abap_true.
              DATA ls_post_update LIKE LINE OF lt_post_update.
              DATA lv_zecon_field TYPE string.

              ls_post_update-Bukrs = <ls_post_result>-bukrs.
              ls_post_update-Gjahr = <ls_post_result>-gjahr.
              ls_post_update-Lifnr = <ls_post_result>-lifnr.
              ls_post_update-Zcdaz = <ls_post_result>-zcdaz.

              IF <ls_post_result>-period_id IS NOT INITIAL.
                lv_zecon_field = |Zecon{ <ls_post_result>-period_id }|.
              ELSE.
                lv_zecon_field = |Zecon{ <ls_post_result>-period_num }|.
              ENDIF.

              ASSIGN COMPONENT lv_zecon_field OF STRUCTURE ls_post_update TO FIELD-SYMBOL(<lv_zecon>).
              ASSIGN COMPONENT lv_zecon_field OF STRUCTURE ls_post_update-%control TO FIELD-SYMBOL(<lv_zecon_control>).

              IF <lv_zecon> IS ASSIGNED AND <lv_zecon_control> IS ASSIGNED.
                <lv_zecon> = 'C'.
                <lv_zecon_control> = if_abap_behv=>mk-on.
                APPEND ls_post_update TO lt_post_update.
              ENDIF.
            ENDLOOP.
          ENDIF.

          lv_success_count += lines( lt_result ).

          DATA(lv_success_text) = COND string(
            WHEN line_exists( lt_result[ 1 ] )
            THEN lt_result[ 1 ]-message_text
*            ELSE 'Contabilizzazione completata' ).
            ELSE ' ' ).
        if lv_success_text ne ' '.
          APPEND VALUE #(
            %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-information
                     text     = lv_success_text ) ) TO reported-/eacm/rzpren.
        else.
*'Contabilizzazione completata'
                APPEND VALUE #(
                  %msg = new_message(
                           id       = '/EACM/MSG_CONTRIB'
                           number   = '001'
                           severity = if_abap_behv_message=>severity-information )
                ) TO reported-/eacm/rzpren.
        endif.
        CATCH /eacm/cx_eacm_posting INTO DATA(lx_posting).
          lv_error_count += 1.

          APPEND VALUE #(
            %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-error
                     text     = lx_posting->mv_text ) ) TO reported-/eacm/rzpren.

        CATCH cx_http_dest_provider_error INTO DATA(lx_dest).
          lv_error_count += 1.

          APPEND VALUE #(
            %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-error
                     text     = lx_dest->get_text( ) ) ) TO reported-/eacm/rzpren.

        CATCH cx_web_http_client_error INTO DATA(lx_http).
          lv_error_count += 1.

          APPEND VALUE #(
            %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-error
                     text     = lx_http->get_text( ) ) ) TO reported-/eacm/rzpren.
      ENDTRY.
    ENDLOOP.

    IF lt_post_update IS NOT INITIAL.
      MODIFY ENTITIES OF /EACM/R_ZPREN IN LOCAL MODE
        ENTITY /eacm/rZpren
        UPDATE FROM lt_post_update
        FAILED DATA(lt_failed_post_update)
        REPORTED DATA(lt_reported_post_update).

      APPEND LINES OF lt_reported_post_update-/eacm/rzpren TO reported-/eacm/rzpren.

      IF lt_failed_post_update-/eacm/rzpren IS NOT INITIAL.
        lv_error_count += lines( lt_failed_post_update-/eacm/rzpren ).
*        APPEND VALUE #(
*          %msg = new_message_with_text(
*                   severity = if_abap_behv_message=>severity-error
*                   text     = |Errore durante aggiornamento flag contabilizzazione: { lines( lt_failed_post_update-/eacm/rzpren ) } record.| ) )
*          TO reported-/eacm/rzpren.

*"Errore durante aggiornamento flag contabilizzazione: &1  record.
        APPEND VALUE #(
          %msg = new_message(
                   id       = '/EACM/MSG_CONTRIB'
                   number   = '002'
                   v1       = lines( lt_failed_post_update-/eacm/rzpren )
                   severity = if_abap_behv_message=>severity-error )
        ) TO reported-/eacm/rzpren.
      ENDIF.
    ENDIF.

*    lv_info_text = |Esecuzione terminata. Documenti elaborati: { lv_success_count }, errori: { lv_error_count }.|.
*    APPEND VALUE #(
*      %msg = new_message_with_text(
*               severity = COND #( WHEN lv_error_count > 0
*                                   THEN if_abap_behv_message=>severity-warning
*                                   ELSE if_abap_behv_message=>severity-success )
*               text     = lv_info_text ) ) TO reported-/eacm/rzpren.

*Esecuzione terminata. Documenti elaborati: &1, errori: &2.
    APPEND VALUE #(
      %msg = new_message(
               id       = '/EACM/MSG_CONTRIB'
               number   = '003'
               v1       = lv_success_count
               v2       = lv_error_count
               severity = COND #( WHEN lv_error_count > 0
                                   THEN if_abap_behv_message=>severity-warning
                                   ELSE if_abap_behv_message=>severity-success ) )
    ) TO reported-/eacm/rzpren.
  ENDMETHOD.

METHOD calculateEnasarco.

  DATA(lo_calc) = NEW /eacm/cl_enasarco_calculation( ).

  DATA lt_update TYPE TABLE FOR UPDATE /EACM/R_ZPREN.
  DATA lt_create TYPE TABLE FOR CREATE /EACM/R_ZPREN.
  DATA lt_keys   TYPE TABLE FOR READ IMPORT /EACM/R_ZPREN.

  DATA lt_all_zpren TYPE STANDARD TABLE OF /eacm/zpren.
  DATA lt_all_zpr23 TYPE STANDARD TABLE OF /eacm/zpr23.


  DATA ls_update LIKE LINE OF lt_update.
  DATA ls_create LIKE LINE OF lt_create.
  DATA lv_month TYPE n LENGTH 2.
  DATA lv_quarter TYPE n LENGTH 1.
  DATA lv_first_month TYPE n LENGTH 2.
  DATA lv_last_month TYPE n LENGTH 2.
  DATA lv_sum_month TYPE n LENGTH 2.
  DATA lv_sum_zemat TYPE /eacm/zpren-zemat1.
  DATA lv_sum_zecca TYPE /eacm/zpren-zecca1.
  DATA lv_sum_zecef TYPE /eacm/zpren-zecef1.
  DATA lv_sum_zecag TYPE /eacm/zpren-zecag1.
  DATA lv_sum_zeccd TYPE /eacm/zpren-zeccd1.
  DATA lv_sum_zever TYPE /eacm/zpren-zever1.
  DATA lv_has_error TYPE abap_bool.
  DATA lv_zpren_exists TYPE abap_bool.
  DATA lv_cid_counter TYPE i.
  DATA ls_result_calc TYPE /eacm/cl_enasarco_calculation=>ty_result.


*lv_month = ls_key-%param-monat.
  LOOP AT keys INTO DATA(ls_key).
  "06.05.2026 mese: unico
    lv_month = ls_key-%param-monat.
    CLEAR ls_result_calc.

    TRY.
        ls_result_calc = lo_calc->calculate(
          is_selection = VALUE /eacm/cl_enasarco_calculation=>ty_selection(
            gjahr = ls_key-%param-gjahr
            monat = ls_key-%param-monat
            calculation_mode = 'M' " fisso mensile
            bukrs_range = VALUE #(
              ( sign = 'I' option = 'EQ' low = ls_key-%param-bukrs ) )
          )
          iv_test_mode = ls_key-%param-test_mode ).

      CATCH cx_root INTO DATA(lx_calc).
        lv_has_error = abap_true.

        APPEND VALUE #(
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = lx_calc->get_text( ) ) )
          TO reported-/eacm/rzpren.

        CONTINUE.
    ENDTRY.

    LOOP AT ls_result_calc-messages INTO DATA(ls_calc_msg).
      APPEND VALUE #(
        %msg = new_message_with_text(
          severity = SWITCH #( ls_calc_msg-type
            WHEN 'E' THEN if_abap_behv_message=>severity-error
            WHEN 'A' THEN if_abap_behv_message=>severity-error
            WHEN 'X' THEN if_abap_behv_message=>severity-error
            WHEN 'W' THEN if_abap_behv_message=>severity-warning
            WHEN 'S' THEN if_abap_behv_message=>severity-success
            WHEN 'I' THEN if_abap_behv_message=>severity-information
            ELSE if_abap_behv_message=>severity-information )
          text     = ls_calc_msg-text ) )
        TO reported-/eacm/rzpren.
    ENDLOOP.

    IF ls_result_calc-has_error = abap_true.
      lv_has_error = abap_true.

      IF ls_result_calc-messages IS INITIAL.
*        APPEND VALUE #(
*          %msg = new_message_with_text(
*            severity = if_abap_behv_message=>severity-error
*            text     = 'Calcolo ENASARCO terminato con errori.' ) )
*          TO reported-/eacm/rzpren.

*ENASARCO calculation completed with errors.
        APPEND VALUE #(
          %msg = new_message(
                   id       = '/EACM/MSG_CONTRIB'
                   number   = '004'
                   severity = if_abap_behv_message=>severity-error )
        ) TO reported-/eacm/rzpren.
      ENDIF.

      CONTINUE.
    ENDIF.

    IF ls_key-%param-test_mode = abap_true.
      CONTINUE.
    ENDIF.

    " Accumulo risultati
    APPEND LINES OF ls_result_calc-zpren_to_save TO lt_all_zpren.
    APPEND LINES OF ls_result_calc-zpr23_to_update TO lt_all_zpr23.

  ENDLOOP.

IF lv_has_error = abap_true.
  RETURN.
ENDIF.

LOOP AT lt_all_zpren INTO DATA(ls_zpren).

  CLEAR ls_update.

  ls_update-Bukrs = ls_zpren-bukrs.
  ls_update-Gjahr = ls_zpren-gjahr.
  ls_update-Lifnr = ls_zpren-lifnr.
  ls_update-Zcdaz = ls_zpren-zcdaz.

  ls_update-Zwaer = ls_zpren-zwaer.
  ls_update-%control-Zwaer = if_abap_behv=>mk-on.

  ASSIGN COMPONENT |ZEMAT_{ lv_month }| OF STRUCTURE ls_zpren TO FIELD-SYMBOL(<src_zemat>).
  ASSIGN COMPONENT |ZECCA_{ lv_month }| OF STRUCTURE ls_zpren TO FIELD-SYMBOL(<src_zecca>).
  ASSIGN COMPONENT |ZECEF_{ lv_month }| OF STRUCTURE ls_zpren TO FIELD-SYMBOL(<src_zecef>).
  ASSIGN COMPONENT |ZECAG_{ lv_month }| OF STRUCTURE ls_zpren TO FIELD-SYMBOL(<src_zecag>).
  ASSIGN COMPONENT |ZECCD_{ lv_month }| OF STRUCTURE ls_zpren TO FIELD-SYMBOL(<src_zeccd>).
  ASSIGN COMPONENT |ZEVER_{ lv_month }| OF STRUCTURE ls_zpren TO FIELD-SYMBOL(<src_zever>).

  ASSIGN COMPONENT |Zemat{ lv_month }| OF STRUCTURE ls_update TO FIELD-SYMBOL(<dst_zemat>) .
  ASSIGN COMPONENT |Zecca{ lv_month }| OF STRUCTURE ls_update TO FIELD-SYMBOL(<dst_zecca>).
  ASSIGN COMPONENT |Zecef{ lv_month }| OF STRUCTURE ls_update TO FIELD-SYMBOL(<dst_zecef>).
  ASSIGN COMPONENT |Zecag{ lv_month }| OF STRUCTURE ls_update TO FIELD-SYMBOL(<dst_zecag>).
  ASSIGN COMPONENT |Zeccd{ lv_month }| OF STRUCTURE ls_update TO FIELD-SYMBOL(<dst_zeccd>).
  ASSIGN COMPONENT |Zever{ lv_month }| OF STRUCTURE ls_update TO FIELD-SYMBOL(<dst_zever>).

  ASSIGN COMPONENT |Zemat{ lv_month }| OF STRUCTURE ls_update-%control TO FIELD-SYMBOL(<ctrl_zemat>).
  ASSIGN COMPONENT |Zecca{ lv_month }| OF STRUCTURE ls_update-%control TO FIELD-SYMBOL(<ctrl_zecca>).
  ASSIGN COMPONENT |Zecef{ lv_month }| OF STRUCTURE ls_update-%control TO FIELD-SYMBOL(<ctrl_zecef>).
  ASSIGN COMPONENT |Zecag{ lv_month }| OF STRUCTURE ls_update-%control TO FIELD-SYMBOL(<ctrl_zecag>).
  ASSIGN COMPONENT |Zeccd{ lv_month }| OF STRUCTURE ls_update-%control TO FIELD-SYMBOL(<ctrl_zeccd>).
  ASSIGN COMPONENT |Zever{ lv_month }| OF STRUCTURE ls_update-%control TO FIELD-SYMBOL(<ctrl_zever>).

  IF <dst_zemat> IS ASSIGNED AND <src_zemat> IS ASSIGNED.
    <dst_zemat> = <src_zemat>.
    <ctrl_zemat> = if_abap_behv=>mk-on.
  ENDIF.

  IF <dst_zecca> IS ASSIGNED AND <src_zecca> IS ASSIGNED.
    <dst_zecca> = <src_zecca>.
    <ctrl_zecca> = if_abap_behv=>mk-on.
  ENDIF.

  IF <dst_zecef> IS ASSIGNED AND <src_zecef> IS ASSIGNED.
    <dst_zecef> = <src_zecef>.
    <ctrl_zecef> = if_abap_behv=>mk-on.
  ENDIF.

  IF <dst_zecag> IS ASSIGNED AND <src_zecag> IS ASSIGNED.
    <dst_zecag> = <src_zecag>.
    <ctrl_zecag> = if_abap_behv=>mk-on.
  ENDIF.

  IF <dst_zeccd> IS ASSIGNED AND <src_zeccd> IS ASSIGNED.
    <dst_zeccd> = <src_zeccd>.
    <ctrl_zeccd> = if_abap_behv=>mk-on.
  ENDIF.

  IF <dst_zever> IS ASSIGNED AND <src_zever> IS ASSIGNED.
    <dst_zever> = <src_zever>.
    <ctrl_zever> = if_abap_behv=>mk-on.
  ENDIF.

  CASE lv_month.
    WHEN '01' OR '02' OR '03'.
      lv_quarter = '1'.
      lv_first_month = '01'.
      lv_last_month = '03'.
    WHEN '04' OR '05' OR '06'.
      lv_quarter = '2'.
      lv_first_month = '04'.
      lv_last_month = '06'.
    WHEN '07' OR '08' OR '09'.
      lv_quarter = '3'.
      lv_first_month = '07'.
      lv_last_month = '09'.
    WHEN '10' OR '11' OR '12'.
      lv_quarter = '4'.
      lv_first_month = '10'.
      lv_last_month = '12'.
  ENDCASE.

  CLEAR:
    lv_sum_zemat,
    lv_sum_zecca,
    lv_sum_zecef,
    lv_sum_zecag,
    lv_sum_zeccd,
    lv_sum_zever.

  lv_sum_month = lv_first_month.
  WHILE lv_sum_month <= lv_last_month.
    ASSIGN COMPONENT |ZEMAT_{ lv_sum_month }| OF STRUCTURE ls_zpren TO FIELD-SYMBOL(<sum_zemat>).
    IF sy-subrc = 0.
      lv_sum_zemat += <sum_zemat>.
    ENDIF.

    ASSIGN COMPONENT |ZECCA_{ lv_sum_month }| OF STRUCTURE ls_zpren TO FIELD-SYMBOL(<sum_zecca>).
    IF sy-subrc = 0.
      lv_sum_zecca += <sum_zecca>.
    ENDIF.

    ASSIGN COMPONENT |ZECEF_{ lv_sum_month }| OF STRUCTURE ls_zpren TO FIELD-SYMBOL(<sum_zecef>).
    IF sy-subrc = 0.
      lv_sum_zecef += <sum_zecef>.
    ENDIF.

    ASSIGN COMPONENT |ZECAG_{ lv_sum_month }| OF STRUCTURE ls_zpren TO FIELD-SYMBOL(<sum_zecag>).
    IF sy-subrc = 0.
      lv_sum_zecag += <sum_zecag>.
    ENDIF.

    ASSIGN COMPONENT |ZECCD_{ lv_sum_month }| OF STRUCTURE ls_zpren TO FIELD-SYMBOL(<sum_zeccd>).
    IF sy-subrc = 0.
      lv_sum_zeccd += <sum_zeccd>.
    ENDIF.

    ASSIGN COMPONENT |ZEVER_{ lv_sum_month }| OF STRUCTURE ls_zpren TO FIELD-SYMBOL(<sum_zever>).
    IF sy-subrc = 0.
      lv_sum_zever += <sum_zever>.
    ENDIF.

    lv_sum_month += 1.
  ENDWHILE.

  ASSIGN COMPONENT |Zemat{ lv_quarter }| OF STRUCTURE ls_update TO FIELD-SYMBOL(<dst_q_zemat>).
  ASSIGN COMPONENT |Zecca{ lv_quarter }| OF STRUCTURE ls_update TO FIELD-SYMBOL(<dst_q_zecca>).
  ASSIGN COMPONENT |Zecef{ lv_quarter }| OF STRUCTURE ls_update TO FIELD-SYMBOL(<dst_q_zecef>).
  ASSIGN COMPONENT |Zecag{ lv_quarter }| OF STRUCTURE ls_update TO FIELD-SYMBOL(<dst_q_zecag>).
  ASSIGN COMPONENT |Zeccd{ lv_quarter }| OF STRUCTURE ls_update TO FIELD-SYMBOL(<dst_q_zeccd>).
  ASSIGN COMPONENT |Zever{ lv_quarter }| OF STRUCTURE ls_update TO FIELD-SYMBOL(<dst_q_zever>).

  ASSIGN COMPONENT |Zemat{ lv_quarter }| OF STRUCTURE ls_update-%control TO FIELD-SYMBOL(<ctrl_q_zemat>).
  ASSIGN COMPONENT |Zecca{ lv_quarter }| OF STRUCTURE ls_update-%control TO FIELD-SYMBOL(<ctrl_q_zecca>).
  ASSIGN COMPONENT |Zecef{ lv_quarter }| OF STRUCTURE ls_update-%control TO FIELD-SYMBOL(<ctrl_q_zecef>).
  ASSIGN COMPONENT |Zecag{ lv_quarter }| OF STRUCTURE ls_update-%control TO FIELD-SYMBOL(<ctrl_q_zecag>).
  ASSIGN COMPONENT |Zeccd{ lv_quarter }| OF STRUCTURE ls_update-%control TO FIELD-SYMBOL(<ctrl_q_zeccd>).
  ASSIGN COMPONENT |Zever{ lv_quarter }| OF STRUCTURE ls_update-%control TO FIELD-SYMBOL(<ctrl_q_zever>).

  IF <dst_q_zemat> IS ASSIGNED.
    <dst_q_zemat> = lv_sum_zemat.
    <ctrl_q_zemat> = if_abap_behv=>mk-on.
  ENDIF.

  IF <dst_q_zecca> IS ASSIGNED.
    <dst_q_zecca> = lv_sum_zecca.
    <ctrl_q_zecca> = if_abap_behv=>mk-on.
  ENDIF.

  IF <dst_q_zecef> IS ASSIGNED.
    <dst_q_zecef> = lv_sum_zecef.
    <ctrl_q_zecef> = if_abap_behv=>mk-on.
  ENDIF.

  IF <dst_q_zecag> IS ASSIGNED.
    <dst_q_zecag> = lv_sum_zecag.
    <ctrl_q_zecag> = if_abap_behv=>mk-on.
  ENDIF.

  IF <dst_q_zeccd> IS ASSIGNED.
    <dst_q_zeccd> = lv_sum_zeccd.
    <ctrl_q_zeccd> = if_abap_behv=>mk-on.
  ENDIF.

  IF <dst_q_zever> IS ASSIGNED.
    <dst_q_zever> = lv_sum_zever.
    <ctrl_q_zever> = if_abap_behv=>mk-on.
  ENDIF.

  CLEAR lv_zpren_exists.
  SELECT SINGLE @abap_true
    FROM /eacm/zpren
    WHERE bukrs = @ls_zpren-bukrs
      AND gjahr = @ls_zpren-gjahr
      AND lifnr = @ls_zpren-lifnr
      AND zcdaz = @ls_zpren-zcdaz
    INTO @lv_zpren_exists.

  IF lv_zpren_exists = abap_true.
    APPEND ls_update TO lt_update.
  ELSE.
    CLEAR ls_create.
    MOVE-CORRESPONDING ls_update TO ls_create.
    lv_cid_counter += 1.

    ls_create-%cid = |ZPREN_{ lv_cid_counter }|.
    ls_create-%control-Bukrs = if_abap_behv=>mk-on.
    ls_create-%control-Gjahr = if_abap_behv=>mk-on.
    ls_create-%control-Lifnr = if_abap_behv=>mk-on.
    ls_create-%control-Zcdaz = if_abap_behv=>mk-on.

    APPEND ls_create TO lt_create.
  ENDIF.

ENDLOOP.

IF lt_create IS NOT INITIAL.
  MODIFY ENTITIES OF /EACM/R_ZPREN IN LOCAL MODE
    ENTITY /eacm/rZpren
    CREATE FROM lt_create
    FAILED DATA(lt_failed_create)
    REPORTED DATA(lt_reported_create).

  APPEND LINES OF lt_reported_create-/eacm/rzpren TO reported-/eacm/rzpren.

  IF lt_failed_create-/eacm/rzpren IS NOT INITIAL.
*    APPEND VALUE #(
*      %msg = new_message_with_text(
*        severity = if_abap_behv_message=>severity-error
*        text     = |Errore durante la creazione di { lines( lt_failed_create-/eacm/rzpren ) } record ENASARCO.| ) )
*      TO reported-/eacm/rzpren.

*Error creating &1 ENASARCO record.
    APPEND VALUE #(
      %msg = new_message(
               id       = '/EACM/MSG_CONTRIB'
               number   = '005'
               v1       = lines( lt_failed_create-/eacm/rzpren )
               severity = if_abap_behv_message=>severity-error )
    ) TO reported-/eacm/rzpren.
    RETURN.
  ENDIF.
ENDIF.

IF lt_update IS NOT INITIAL.
  MODIFY ENTITIES OF /EACM/R_ZPREN IN LOCAL MODE
    ENTITY /eacm/rZpren
    UPDATE FROM lt_update
    FAILED DATA(lt_failed_update)
    REPORTED DATA(lt_reported_update).

  APPEND LINES OF lt_reported_update-/eacm/rzpren TO reported-/eacm/rzpren.

  IF lt_failed_update-/eacm/rzpren IS NOT INITIAL.
*    APPEND VALUE #(
*      %msg = new_message_with_text(
*        severity = if_abap_behv_message=>severity-error
*        text     = |Errore durante l'aggiornamento di { lines( lt_failed_update-/eacm/rzpren ) } record ENASARCO.| ) )
*      TO reported-/eacm/rzpren.

*Error updating &1 ENASARCO record.
        APPEND VALUE #(
          %msg = new_message(
                   id       = '/EACM/MSG_CONTRIB'
                   number   = '006'
                   v1       = lines( lt_failed_update-/eacm/rzpren )
                   severity = if_abap_behv_message=>severity-error )
        ) TO reported-/eacm/rzpren.
    RETURN.
  ENDIF.
ENDIF.

DATA lt_zpr23_update TYPE TABLE FOR UPDATE /EACM/I_ZPR23.
LOOP AT lt_all_zpr23 INTO DATA(ls_zpr23).

  APPEND VALUE #(
    Bukrs = ls_zpr23-bukrs

    Zccon = ls_zpr23-zccon
    Zcimp = ls_zpr23-zcimp
    Zcoco = ls_zpr23-zcoco
    Zelin = ls_zpr23-zelin
    Zelfi = ls_zpr23-zelfi
    Zperi = ls_zpr23-zperi

    %control-Zccon = if_abap_behv=>mk-on
    %control-Zcimp = if_abap_behv=>mk-on
    %control-Zcoco = if_abap_behv=>mk-on
    %control-Zelin = if_abap_behv=>mk-on
    %control-Zelfi = if_abap_behv=>mk-on
    %control-Zperi = if_abap_behv=>mk-on

  ) TO lt_zpr23_update.

ENDLOOP.

IF lt_zpr23_update IS NOT INITIAL.

    MODIFY ENTITIES OF /EACM/I_ZPR23 " IN LOCAL MODE
      ENTITY Zpr23
      UPDATE FROM lt_zpr23_update
      FAILED DATA(lt_failed_zpr23)
      REPORTED DATA(lt_reported_zpr23).

   IF lt_failed_zpr23-zpr23 IS NOT INITIAL.
*    APPEND VALUE #(
*      %msg = new_message_with_text(
*        severity = if_abap_behv_message=>severity-error
*        text     = 'Errore durante aggiornamento stato ZPR23.' ) )
*      TO reported-/eacm/rzpren.
*Error updating &1 ENASARCO record.
        APPEND VALUE #(
          %msg = new_message(
                   id       = '/EACM/MSG_CONTRIB'
                   number   = '007'
                   severity = if_abap_behv_message=>severity-error )
        ) TO reported-/eacm/rzpren.
    RETURN.
  ENDIF.
endif.

*APPEND VALUE #(
*  %msg = new_message_with_text(
*    severity = if_abap_behv_message=>severity-success
*    text     = 'Calcolo ENASARCO completato.' ) )
*  TO reported-/eacm/rzpren.

*Calcolo ENASARCO completato
    APPEND VALUE #(
      %msg = new_message(
               id       = '/EACM/MSG_CONTRIB'
               number   = '008'
               severity = if_abap_behv_message=>severity-error )
    ) TO reported-/eacm/rzpren.



ENDMETHOD.

  METHOD GenerateEnasarcoOnline.

    DATA(lo_generator) = NEW /eacm/cl_eon_generator( ).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).
      DATA(lv_today) = cl_abap_context_info=>get_system_date( ).
      DATA lv_default_trimes TYPE c LENGTH 1.

      lv_default_trimes = COND #(
        WHEN lv_today+4(2) <= '03' THEN '1'
        WHEN lv_today+4(2) <= '06' THEN '2'
        WHEN lv_today+4(2) <= '09' THEN '3'
        ELSE '4' ).

      DATA(ls_selection) = VALUE /EACM/A_EON_PAR(
        bukrs         = <ls_key>-%param-Bukrs
        gjahr         = <ls_key>-%param-Gjahr
        trimes        = COND #( WHEN <ls_key>-%param-Trimes IS NOT INITIAL
                                THEN <ls_key>-%param-Trimes
                                ELSE lv_default_trimes )
        prot          = <ls_key>-%param-Prot
        ditta         = <ls_key>-%param-Ditta
        cf            = <ls_key>-%param-Cf
        firr          = xsdbool( <ls_key>-%param-Firr = abap_true )
        SplitCessati  = xsdbool( <ls_key>-%param-SplitCessati = abap_true )
        zcdaz         = <ls_key>-%param-Zcdaz
        ztpag         = <ls_key>-%param-Ztpag ).

      lo_generator->generate(
        EXPORTING
          is_selection        = ls_selection
        IMPORTING
          et_file_lines       = DATA(lt_file_lines)
          et_cessati_lines    = DATA(lt_cessati_lines)
          et_messages         = DATA(lt_messages)
          ev_filename         = DATA(lv_filename)
          ev_cessati_filename = DATA(lv_cessati_filename) ).

      LOOP AT lt_messages INTO DATA(ls_message).
        APPEND VALUE #(
          %msg = new_message_with_text(
            severity = SWITCH #( ls_message-msgty
              WHEN 'E' THEN if_abap_behv_message=>severity-error
              WHEN 'W' THEN if_abap_behv_message=>severity-warning
              WHEN 'S' THEN if_abap_behv_message=>severity-success
              ELSE if_abap_behv_message=>severity-information )
            text = ls_message-text ) )
          TO reported-/eacm/rzpren.
      ENDLOOP.

      IF line_exists( lt_messages[ msgty = 'E' ] ).
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-success
          text     = |File { lv_filename } generato in memoria: { lines( lt_file_lines ) } righe.| ) )
        TO reported-/eacm/rzpren.

      IF lt_cessati_lines IS NOT INITIAL.
        APPEND VALUE #(
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-information
            text     = |File cessati { lv_cessati_filename } generato in memoria: { lines( lt_cessati_lines ) } righe.| ) )
          TO reported-/eacm/rzpren.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


ENDCLASS.

