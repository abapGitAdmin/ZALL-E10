class /ADESSO/CL_BPU_MASTERDATA definition
  public
  final
  create public .

public section.

  class-methods GET_EVER
    importing
      !IV_INT_UI type INT_UI optional
      !IV_EXT_UI type EXT_UI optional
      !IV_ANLAGE type ANLAGE optional
      !IV_KEYDATE type /IDXGC/DE_KEYDATE default SY-DATUM
    returning
      value(RS_EVER) type EVER
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_INSTLN
    importing
      !IV_EXT_UI type EXT_UI optional
      !IV_INT_UI type INT_UI optional
      !IV_KEYDATE type /IDXGC/DE_KEYDATE default SY-DATUM
    returning
      value(RV_ANLAGE) type ANLAGE
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_INT_UI
    importing
      !IV_EXT_UI type EXT_UI optional
      !IV_ANLAGE type ANLAGE optional
      !IV_KEYDATE type /IDXGC/DE_KEYDATE default SY-DATUM
    returning
      value(RV_INT_UI) type INT_UI
    raising
      /IDXGC/CX_GENERAL .
protected section.
private section.

  class-data GV_MTEXT type STRING .
ENDCLASS.



CLASS /ADESSO/CL_BPU_MASTERDATA IMPLEMENTATION.


  METHOD get_ever.
    DATA: lv_int_ui TYPE int_ui,
          lv_anlage TYPE anlage.

    IF iv_anlage IS NOT INITIAL.
      lv_anlage = iv_anlage.
    ELSE.
      IF iv_int_ui IS NOT INITIAL.
        lv_int_ui = iv_int_ui.
      ELSEIF iv_ext_ui IS NOT INITIAL.
        lv_int_ui = get_int_ui( iv_ext_ui = iv_ext_ui iv_keydate = iv_keydate ).
      ELSE.
        MESSAGE e004(/adesso/bpu_general) WITH 'EVER' INTO gv_mtext.
        /idxgc/cx_general=>raise_exception_from_msg( ).
      ENDIF.
      lv_anlage = get_instln( iv_int_ui  = lv_int_ui iv_keydate = iv_keydate ).
    ENDIF.

    IF lv_anlage IS NOT INITIAL.
      SELECT SINGLE * INTO rs_ever FROM ever WHERE anlage = lv_anlage AND einzdat <= iv_keydate AND auszdat >= iv_keydate.
      IF sy-subrc <> 0.
        MESSAGE e004(/adesso/bpu_general) WITH 'EVER' INTO gv_mtext.
        /idxgc/cx_general=>raise_exception_from_msg( ).
      ENDIF.
    ELSE.
      MESSAGE e004(/adesso/bpu_general) WITH 'EVER' INTO gv_mtext.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD get_instln.
    DATA: lv_int_ui    TYPE          int_ui,
          ls_v_eanl    TYPE          v_eanl,
          lt_euiinstln TYPE TABLE OF euiinstln.

    FIELD-SYMBOLS: <fs_euiinstln> TYPE euiinstln.

    IF iv_int_ui IS NOT INITIAL.
      lv_int_ui = iv_int_ui.
    ELSEIF iv_ext_ui IS NOT INITIAL.
      lv_int_ui = get_int_ui( iv_ext_ui = iv_ext_ui iv_keydate = iv_keydate ).
    ELSE.
      MESSAGE e004(/adesso/bpu_general) WITH 'ANLAGE' INTO gv_mtext.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.

    CALL FUNCTION 'ISU_DB_EUIINSTLN_SELECT'
      EXPORTING
        x_int_ui      = lv_int_ui
        x_dateto      = iv_keydate
        x_datefrom    = iv_keydate
        x_only_dereg  = abap_true
      IMPORTING
        y_euiinstln   = lt_euiinstln
      EXCEPTIONS
        not_found     = 1
        system_error  = 2
        not_qualified = 3
        OTHERS        = 4.
    IF sy-subrc <> 0 OR lines( lt_euiinstln ) <> 1.
      MESSAGE e003(/adesso/bpu_general) WITH 'EUIINSTLN' iv_int_ui iv_keydate INTO gv_mtext.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ELSE.
      rv_anlage = lt_euiinstln[ 1 ]-anlage.
    ENDIF.
  ENDMETHOD.


  METHOD get_int_ui.
    DATA: lt_euiinstln TYPE ieuiinstln,
          ls_euitrans  TYPE euitrans,
          lv_count     TYPE e_maxcount.

    FIELD-SYMBOLS: <fs_euiinstln> TYPE euiinstln.

    IF iv_ext_ui IS NOT INITIAL.
      CALL FUNCTION 'ISU_DB_EUITRANS_EXT_SINGLE'
        EXPORTING
          x_ext_ui     = iv_ext_ui
          x_keydate    = iv_keydate
        IMPORTING
          y_euitrans   = ls_euitrans
        EXCEPTIONS
          not_found    = 1
          system_error = 2
          OTHERS       = 3.
      IF sy-subrc <> 0.
        MESSAGE e003(/adesso/bpu_general) WITH 'EUITRANS' iv_ext_ui iv_keydate INTO gv_mtext.
        /idxgc/cx_general=>raise_exception_from_msg( ).
      ELSE.
        rv_int_ui = ls_euitrans-int_ui.
      ENDIF.
    ELSEIF iv_anlage IS NOT INITIAL.
      CALL FUNCTION 'ISU_DB_EUIINSTLN_SELECT'
        EXPORTING
          x_anlage      = iv_anlage
          x_dateto      = iv_keydate
          x_datefrom    = iv_keydate
        IMPORTING
          y_count       = lv_count
          y_euiinstln   = lt_euiinstln
        EXCEPTIONS
          not_found     = 1
          system_error  = 2
          not_qualified = 3
          OTHERS        = 4.
      IF sy-subrc <> 0 OR lv_count <> 1.
        MESSAGE i002(/adesso/isu_general) WITH 'EUIINSTLN' iv_anlage iv_keydate INTO gv_mtext.
        /idxgc/cx_general=>raise_exception_from_msg( ).
      ELSE.
        READ TABLE lt_euiinstln ASSIGNING <fs_euiinstln> INDEX 1.
        rv_int_ui = <fs_euiinstln>-int_ui.
      ENDIF.
    ELSE.
      MESSAGE i004(/adesso/isu_general) WITH 'INT_UI' INTO gv_mtext.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
