class ZADE_CUST definition
  public
  final
  create public .

public section.

  class-methods GET_NEXT_ABTID
    returning
      value(RV_ID) type ZADE_ABTID .
  class-methods GET_NEXT_MANR
    returning
      value(RV_NR) type ZADE_MANR .
protected section.
PRIVATE SECTION.
  CONSTANTS:
    BEGIN OF gc_nr_object,
      abt                    TYPE nrobj  VALUE 'ZADE_ABT',
      ma                     TYPE nrobj  VALUE 'ZADE_MA',
    END OF gc_nr_object,

    BEGIN OF gc_nr_range,
      abt_id                 TYPE nrnr  VALUE 'ID',
      ma_nr                  TYPE nrnr  VALUE 'NR',
    END OF gc_nr_range.
ENDCLASS.



CLASS ZADE_CUST IMPLEMENTATION.


METHOD get_next_abtid.
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr             = gc_nr_range-abt_id
      object                  = gc_nr_object-abt
    IMPORTING
      number                  = rv_id
   EXCEPTIONS
     interval_not_found       = 1
     number_range_not_intern  = 2
     object_not_found         = 3
     quantity_is_0            = 4
     quantity_is_not_1        = 5
     interval_overflow        = 6
     buffer_overflow          = 7
     OTHERS                   = 8.
  IF sy-subrc <> 0.
    CLEAR rv_id.
  ENDIF.
ENDMETHOD.


METHOD get_next_manr.
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr             = gc_nr_range-ma_nr
      object                  = gc_nr_object-ma
    IMPORTING
      number                  = rv_nr
   EXCEPTIONS
     interval_not_found       = 1
     number_range_not_intern  = 2
     object_not_found         = 3
     quantity_is_0            = 4
     quantity_is_not_1        = 5
     interval_overflow        = 6
     buffer_overflow          = 7
     OTHERS                   = 8.
  IF sy-subrc <> 0.
    CLEAR rv_nr.
  ENDIF.
ENDMETHOD.
ENDCLASS.
