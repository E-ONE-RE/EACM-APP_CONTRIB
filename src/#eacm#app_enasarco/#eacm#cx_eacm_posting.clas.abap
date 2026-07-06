CLASS /eacm/cx_eacm_posting DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    DATA mv_text TYPE string READ-ONLY.

    METHODS constructor
      IMPORTING
        iv_text TYPE string.
ENDCLASS.



CLASS /EACM/CX_EACM_POSTING IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor( ).
    mv_text = iv_text.
  ENDMETHOD.
ENDCLASS.
