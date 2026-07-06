CLASS /eacm/cl_last_day_of_month DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS get_last_day_of_month
      IMPORTING
        iv_gjahr TYPE gjahr
        iv_monat TYPE monat
      RETURNING
        VALUE(rv_date) TYPE d.
ENDCLASS.


CLASS /eacm/cl_last_day_of_month IMPLEMENTATION.

  METHOD get_last_day_of_month.

    DATA lv_year  TYPE i.
    DATA lv_month TYPE i.
    DATA lv_next_year  TYPE i.
    DATA lv_next_month TYPE i.
    DATA lv_next_month_first_day TYPE d.

    lv_year  = CONV i( iv_gjahr ).
    lv_month = CONV i( iv_monat ).

    IF lv_month = 12.
      lv_next_year  = lv_year + 1.
      lv_next_month = 1.
    ELSE.
      lv_next_year  = lv_year.
      lv_next_month = lv_month + 1.
    ENDIF.

    lv_next_month_first_day =
      |{ lv_next_year WIDTH = 4 PAD = '0' }{ lv_next_month WIDTH = 2 ALIGN = RIGHT PAD = '0' }01|.

    rv_date = lv_next_month_first_day - 1.

  ENDMETHOD.

ENDCLASS.
