INTERFACE /eacm/if_fisc_types PUBLIC.

  TYPES ty_periodicity TYPE c LENGTH 1.
  TYPES ty_calculation_basis TYPE c LENGTH 5.
  TYPES ty_message_type TYPE c LENGTH 1.
  TYPES ty_period_number TYPE n LENGTH 2.

  CONSTANTS:
    gc_period_monthly   TYPE ty_periodicity VALUE 'M',
    gc_period_quarterly TYPE ty_periodicity VALUE 'T',
    gc_period_yearly    TYPE ty_periodicity VALUE 'A',

    gc_basis_invoiced       TYPE ty_calculation_basis VALUE 'FATT',
    gc_basis_invoiced_flat  TYPE ty_calculation_basis VALUE 'FATT1',
    gc_basis_accrued        TYPE ty_calculation_basis VALUE 'MAT',
    gc_basis_contract       TYPE ty_calculation_basis VALUE 'CON',

    gc_msg_error       TYPE ty_message_type VALUE 'E',
    gc_msg_warning     TYPE ty_message_type VALUE 'W',
    gc_msg_success     TYPE ty_message_type VALUE 'S',
    gc_msg_information TYPE ty_message_type VALUE 'I',

    gc_status_calculated TYPE c LENGTH 1 VALUE 'C',
    gc_status_historized TYPE c LENGTH 1 VALUE 'S',
    gc_status_deleted    TYPE c LENGTH 1 VALUE 'D'.

  TYPES:
    tt_agent_range TYPE RANGE OF /eacm/zpraa-zcdaz,
    tt_vkorg_range TYPE RANGE OF vkorg,

    BEGIN OF ty_period,
      begin_date         TYPE d,
      end_date           TYPE d,
      begin_yyyymm       TYPE n LENGTH 6,
      end_yyyymm         TYPE n LENGTH 6,
      period_field_index TYPE i,
      max_periods        TYPE i,
    END OF ty_period,

    BEGIN OF ty_request,
      company_code      TYPE bukrs,
      fiscal_year       TYPE gjahr,
      periodicity       TYPE ty_periodicity,
      period_number     TYPE ty_period_number,
      calculation_basis TYPE ty_calculation_basis,
      definitive        TYPE abap_bool,
      agent_range       TYPE tt_agent_range,
      vkorg_range       TYPE tt_vkorg_range,
    END OF ty_request,

    BEGIN OF ty_message,
      type        TYPE ty_message_type,
      id          TYPE symsgid,
      number      TYPE symsgno,
      text        TYPE string,
      company     TYPE bukrs,
      fiscal_year TYPE gjahr,
      vkorg       TYPE vkorg,
      agent       TYPE /eacm/zcdaz,
    END OF ty_message,
    tt_message TYPE STANDARD TABLE OF ty_message WITH EMPTY KEY,

    tt_fisc TYPE STANDARD TABLE OF /eacm/zprfisc WITH DEFAULT KEY,

    BEGIN OF ty_result,
      preview        TYPE abap_bool,
      processed_rows TYPE i,
      saved_rows     TYPE i,
      period         TYPE ty_period,
      fisc_rows      TYPE tt_fisc,
      messages       TYPE tt_message,
    END OF ty_result.

ENDINTERFACE.
