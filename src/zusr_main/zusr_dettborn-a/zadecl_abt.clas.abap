class ZADECL_ABT definition
  public
  final
  create public .

public section.

  data GS_ABT type ZADE_ABT read-only .
  constants GC_ABTID_INITIAL type ZADE_ABTID value '00' ##NO_TEXT.

  class-methods CREATE_ABT
    importing
      !IV_ABTID type ZADE_ABTID
    returning
      value(RR_ABT) type ref to ZADECL_ABT .
  class-methods CREATE_ABT_LIST
    importing
      !IV_ABTBEZ type ZADE_ABTBEZ
    returning
      value(RT_ABT) type ZADECL_ABT_TT .
  class-methods EXIST_ABTID
    importing
      !IV_ABTID type ZADE_ABTID
    returning
      value(RV_ANSWER) type ABAP_BOOL .
  methods DELETE_ABT
    returning
      value(RV_SUBRC) type SY-SUBRC .
  methods SAVE_ABT
    returning
      value(RV_SUBRC) type SY-SUBRC .
  methods SET_ABT
    importing
      value(IS_ABT) type ZADE_ABT .
protected section.
private section.
ENDCLASS.



CLASS ZADECL_ABT IMPLEMENTATION.


METHOD CREATE_ABT.
  CREATE OBJECT rr_abt.

  IF iv_abtid = gc_abtid_initial.
    rr_abt->gs_abt-mandt = sy-mandt.
    rr_abt->gs_abt-id    = gc_abtid_initial.
    RETURN.
  ENDIF.

  SELECT SINGLE *  INTO rr_abt->gs_abt
    FROM zade_abt
    WHERE id = iv_abtid.
ENDMETHOD.


METHOD create_abt_list.
  DATA:
    lv_abtbez_search         TYPE string,
    lr_abtobj                TYPE REF TO zadecl_abt,
    lt_abt                   TYPE STANDARD TABLE OF zade_abt
                                  WITH DEFAULT KEY,
    lr_abt                   TYPE REF TO zade_abt.

  CLEAR lt_abt[].
  IF iv_abtbez IS INITIAL.
    SELECT *  INTO TABLE lt_abt
      FROM zade_abt.
  ELSE.
    lv_abtbez_search = '%' && iv_abtbez && '%'.
    SELECT *  INTO TABLE lt_abt
      FROM zade_abt
      WHERE bez LIKE lv_abtbez_search.
  ENDIF.

  LOOP AT lt_abt  REFERENCE INTO lr_abt.
    CREATE OBJECT lr_abtobj.
    lr_abtobj->set_abt( lr_abt->* ).
    lr_abtobj->gs_abt-mandt = lr_abt->mandt.
    lr_abtobj->gs_abt-id    = lr_abt->id.
    APPEND lr_abtobj  TO rt_abt.
  ENDLOOP.
ENDMETHOD.


METHOD delete_abt.
  rv_subrc = 0.

  IF gs_abt IS INITIAL.
    rv_subrc = 1.
    RETURN.
  ENDIF.

  IF gs_abt-id <> gc_abtid_initial.
    IF exist_abtid( gs_abt-id ).
      DELETE zade_abt  FROM gs_abt.
      IF sy-subrc <> 0.
        rv_subrc = 2.
        RETURN.
      ENDIF.

      gs_abt-id = gc_abtid_initial.
      RETURN.
    ELSE.
      rv_subrc = 3.
      RETURN.
    ENDIF.
  ELSE.
    rv_subrc = 4.
    RETURN.
  ENDIF.
ENDMETHOD.


METHOD EXIST_ABTID.
  DATA:
    lv_abtid                 TYPE zade_abtid.

  rv_answer = abap_true.

  IF iv_abtid = gc_abtid_initial.
    rv_answer = abap_false.
    RETURN.
  ENDIF.

  CLEAR lv_abtid.
  SELECT SINGLE id  INTO lv_abtid
    FROM zade_abt
    WHERE id = iv_abtid.
  IF sy-subrc <> 0.
    rv_answer = abap_false.
    RETURN.
  ENDIF.
ENDMETHOD.


METHOD save_abt.
  rv_subrc = 0.

  IF gs_abt IS INITIAL.
    rv_subrc = 1.
    RETURN.
  ENDIF.

  IF gs_abt-id <> gc_abtid_initial.
    IF exist_abtid( gs_abt-id ).
      UPDATE zade_abt  FROM gs_abt.
      IF sy-subrc <> 0.
        rv_subrc = 2.
        RETURN.
      ENDIF.

      RETURN.
    ELSE.
      rv_subrc = 3.
      RETURN.
    ENDIF.
  ELSE.
    gs_abt-id = zade_cust=>get_next_abtid( ).
    INSERT zade_abt  FROM gs_abt.
    IF sy-subrc <> 0.
      rv_subrc = 4.
      RETURN.
    ENDIF.
  ENDIF.
ENDMETHOD.


METHOD set_abt.
  gs_abt-bez = is_abt-bez.
ENDMETHOD.
ENDCLASS.
