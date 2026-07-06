INTERFACE /eacm/if_firr_types PUBLIC.

  TYPES ty_periodicity TYPE c LENGTH 1.
  TYPES ty_calculation_basis TYPE c LENGTH 4.
  TYPES ty_message_type TYPE c LENGTH 1.
  TYPES ty_month TYPE n LENGTH 2.

  CONSTANTS:
    gc_period_monthly   TYPE ty_periodicity VALUE 'M',
    gc_period_quarterly TYPE ty_periodicity VALUE 'T',
    gc_period_yearly    TYPE ty_periodicity VALUE 'A',

    gc_basis_invoiced   TYPE ty_calculation_basis VALUE 'FATT',
    gc_basis_accrued    TYPE ty_calculation_basis VALUE 'MAT',
    gc_basis_invoice_dt TYPE ty_calculation_basis VALUE 'FAC',
    gc_basis_contract   TYPE ty_calculation_basis VALUE 'CON',

    gc_msg_error        TYPE ty_message_type VALUE 'E',
    gc_msg_warning      TYPE ty_message_type VALUE 'W',
    gc_msg_success      TYPE ty_message_type VALUE 'S',

    gc_status_calculated TYPE c LENGTH 1 VALUE 'C',
    gc_status_historized TYPE c LENGTH 1 VALUE 'S'.

  TYPES:
    BEGIN OF ty_agent_range,
      sign   TYPE c LENGTH 1,
      option TYPE c LENGTH 2,
      low    TYPE /eacm/zcdaz,
      high   TYPE /eacm/zcdaz,
    END OF ty_agent_range,
    tt_agent_range TYPE STANDARD TABLE OF ty_agent_range WITH EMPTY KEY.

  TYPES:
    BEGIN OF ty_vkorg_range,
      sign   TYPE c LENGTH 1,
      option TYPE c LENGTH 2,
      low    TYPE vkorg,
      high   TYPE vkorg,
    END OF ty_vkorg_range,
    tt_vkorg_range TYPE STANDARD TABLE OF ty_vkorg_range WITH EMPTY KEY.

  TYPES:
    BEGIN OF ty_request,
      company_code      TYPE bukrs,
      fiscal_year       TYPE gjahr,
      periodicity       TYPE ty_periodicity,
      period_number     TYPE ty_month,
      calculation_basis TYPE ty_calculation_basis,
      definitive        TYPE abap_bool,
      group_by_supplier TYPE abap_bool,
      agent_range       TYPE tt_agent_range,
      vkorg_range       TYPE tt_vkorg_range,
    END OF ty_request.

  TYPES:
    BEGIN OF ty_period,
      begin_date         TYPE d,
      end_date           TYPE d,
      period_field_index TYPE i,
    END OF ty_period.

  TYPES:
    tt_firr TYPE STANDARD TABLE OF /eacm/zprfirr WITH EMPTY KEY.

  TYPES:
    BEGIN OF ty_message,
      type       TYPE ty_message_type,
      id         TYPE symsgid,
      number     TYPE symsgno,
      text       TYPE string,
      company    TYPE bukrs,
      fiscal_year TYPE gjahr,
      vkorg      TYPE vkorg,
      agent      TYPE /eacm/zcdaz,
    END OF ty_message,
    tt_message TYPE STANDARD TABLE OF ty_message WITH EMPTY KEY.

  TYPES:
    BEGIN OF ty_result,
      run_uuid       TYPE sysuuid_x16,
      preview        TYPE abap_bool,
      processed_rows TYPE i,
      saved_rows     TYPE i,
      period         TYPE ty_period,
      firr_rows      TYPE tt_firr,
      messages       TYPE tt_message,
    END OF ty_result.

ENDINTERFACE.
