class ZADECL_MA definition
  public
  final
  create public .

public section.

  data GS_MA type ZADE_MA read-only .
  constants GC_MANR_INITIAL type ZADE_MANR value '0000' ##NO_TEXT.

  class-methods CREATE_MA
    importing
      !IV_MANR type ZADE_MANR
    returning
      value(RR_MA) type ref to ZADECL_MA .
  class-methods CREATE_MA_LIST
    importing
      !IV_MANAME type ZADE_MANAME
      !IV_ABTID type ZADE_ABTID
    returning
      value(RT_MA) type ZADECL_MA_TT .
  class-methods EXIST_MANR
    importing
      !IV_MANR type ZADE_MANR
    returning
      value(RV_ANSWER) type ABAP_BOOL .
  methods DELETE_MA
    returning
      value(RV_SUBRC) type SY-SUBRC .
  methods SAVE_MA
    returning
      value(RV_SUBRC) type SY-SUBRC .
  methods SET_MA
    importing
      value(IV_MA) type ZADE_MA .
protected section.
private section.
ENDCLASS.



CLASS ZADECL_MA IMPLEMENTATION.


METHOD create_ma.
  CREATE OBJECT rr_ma.

  IF iv_manr = gc_manr_initial.
    rr_ma->gs_ma-mandt = sy-mandt.
    rr_ma->gs_ma-nr    = gc_manr_initial.
    RETURN.
  ENDIF.

  SELECT SINGLE *  INTO rr_ma->gs_ma
    FROM zade_ma
    WHERE nr = iv_manr.
ENDMETHOD.


METHOD create_ma_list.
  DATA:
    lv_maname_search         TYPE string,
    lr_maobj                 TYPE REF TO zadecl_ma,
    lt_ma                    TYPE STANDARD TABLE OF zade_ma
                                  WITH DEFAULT KEY,
    lr_ma                    TYPE REF TO zade_ma.

  CLEAR lt_ma[].
  IF iv_abtid <> zadecl_abt=>gc_abtid_initial.
    SELECT *  INTO TABLE lt_ma
      FROM zade_ma
      WHERE abtid = iv_abtid.

  ELSE.
    IF iv_maname IS INITIAL.
      SELECT *  INTO TABLE lt_ma
        FROM zade_ma.
    ELSE.
      lv_maname_search = '%' && iv_maname && '%'.
      SELECT *  INTO TABLE lt_ma
        FROM zade_ma
        WHERE name LIKE lv_maname_search.
    ENDIF.
  ENDIF.

  LOOP AT lt_ma  REFERENCE INTO lr_ma.
    CREATE OBJECT lr_maobj.
    lr_maobj->set_ma( lr_ma->* ).
    lr_maobj->gs_ma-mandt = lr_ma->mandt.
    lr_maobj->gs_ma-nr    = lr_ma->nr.
    APPEND lr_maobj  TO rt_ma.
  ENDLOOP.
ENDMETHOD.


METHOD delete_ma.
  rv_subrc = 0.

  IF gs_ma IS INITIAL.
    rv_subrc = 1.
    RETURN.
  ENDIF.

  IF gs_ma-nr <> gc_manr_initial.
    IF exist_manr( gs_ma-nr ).
      DELETE zade_ma  FROM gs_ma.
      IF sy-subrc <> 0.
        rv_subrc = 2.
        RETURN.
      ENDIF.

      gs_ma-nr = gc_manr_initial.
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


METHOD exist_manr.
  DATA:
    lv_manr                  TYPE zade_manr.

  rv_answer = abap_true.

  IF iv_manr = gc_manr_initial.
    rv_answer = abap_false.
    RETURN.
  ENDIF.

  CLEAR lv_manr.
  SELECT SINGLE nr  INTO lv_manr
    FROM zade_ma
    WHERE nr = iv_manr.
  IF sy-subrc <> 0.
    rv_answer = abap_false.
    RETURN.
  ENDIF.
ENDMETHOD.


METHOD save_ma.
  rv_subrc = 0.

  IF gs_ma IS INITIAL.
    rv_subrc = 1.
    RETURN.
  ENDIF.

  IF gs_ma-nr <> gc_manr_initial.
    IF exist_manr( gs_ma-nr ).
      UPDATE zade_ma  FROM gs_ma.
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
    gs_ma-nr = zade_cust=>get_next_manr( ).
    INSERT zade_ma  FROM gs_ma.
    IF sy-subrc <> 0.
      rv_subrc = 4.
      RETURN.
    ENDIF.
  ENDIF.
ENDMETHOD.


METHOD set_ma.
  gs_ma-name  = iv_ma-name.
  gs_ma-abtid = iv_ma-abtid.
ENDMETHOD.
ENDCLASS.
