class /ADESSO/CL_MDC_MRCONTACT definition
  public
  final
  create public .

public section.

  class-methods DB_SELECT_MRCONTACT
    importing
      !IV_ANLAGE type ANLAGE optional
      !IV_INT_UI type INT_UI optional
      !IV_KEYDATE type SY-DATUM default SY-DATUM
    returning
      value(RS_MRCONTACT) type /IDXGC/MRCONTACT
    raising
      /IDXGC/CX_GENERAL .
  class-methods STOP_MRCONTACT
    importing
      !IV_ANLAGE type ANLAGE optional
      !IV_INT_UI type INT_UI optional
      !IV_KEYDATE type /IDXGC/DE_KEYDATE
    raising
      /IDXGC/CX_GENERAL .
  class-methods CREATE_MRCONTACT
    importing
      !IV_ANLAGE type ANLAGE optional
      !IV_INT_UI type INT_UI optional
      !IV_FROMDATE type ABZEITSCH
      !IV_TODATE type BISZEITSCH
      !IV_CONTACT_BP type /IDXGC/DE_CONTACT_BP
    raising
      /IDXGC/CX_GENERAL .
protected section.

  class-data GV_MTEXT type STRING .
private section.
ENDCLASS.



CLASS /ADESSO/CL_MDC_MRCONTACT IMPLEMENTATION.


  METHOD create_mrcontact.
*--------------------------------------------------------------------*
* THIMEL.R, 20160324, Neue Zeitscheibe in der Tabelle /IDXGC/MRCONTACT
*   wird mit den übergebenen Daten angelegt.
*--------------------------------------------------------------------*
    DATA: lr_previous  TYPE REF TO cx_root,
          lt_mrcontact TYPE TABLE OF /idxgc/mrcontact,
          ls_mrcontact TYPE /idxgc/mrcontact,
          lv_anlage    TYPE anlage.

    FIELD-SYMBOLS: <fs_mrcontact> TYPE /idxgc/mrcontact.

    IF iv_fromdate > iv_todate.
      MESSAGE e004(/adesso/mdc_mrcontct) WITH iv_fromdate iv_todate INTO gv_mtext.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.

    IF iv_anlage IS INITIAL.
      lv_anlage = /adesso/cl_mdc_masterdata=>get_anlage( iv_int_ui = iv_int_ui iv_keydate = iv_fromdate ).
    ELSE.
      lv_anlage = iv_anlage.
    ENDIF.

    SELECT * FROM /idxgc/mrcontact INTO TABLE lt_mrcontact
      WHERE anlage = iv_anlage AND (
        ( fromdate <= iv_fromdate AND todate >= iv_fromdate ) OR
        ( fromdate <= iv_todate   AND todate >= iv_todate   ) ).

    IF lines( lt_mrcontact ) = 0.
      ls_mrcontact-anlage     = iv_anlage.
      ls_mrcontact-fromdate   = iv_fromdate.
      ls_mrcontact-todate     = iv_todate.
      ls_mrcontact-contact_bp = iv_contact_bp.
      ls_mrcontact-cr_name    = sy-uname.
      ls_mrcontact-cr_date    = sy-datum.
      ls_mrcontact-cr_time    = sy-uzeit.

      INSERT /idxgc/mrcontact FROM ls_mrcontact.
      IF sy-subrc <> 0.
        MESSAGE e002(/adesso/mdc_mrcontct) INTO gv_mtext.
        /idxgc/cx_general=>raise_exception_from_msg( ).
      ENDIF.
    ELSE.
      MESSAGE e003(/adesso/mdc_mrcontct) INTO gv_mtext.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD DB_SELECT_MRCONTACT.
*--------------------------------------------------------------------*
* THIMEL-R, 20160324, Datenbankzugriff für die Tabelle
*   /IDXGC/MRCONTACT.
*--------------------------------------------------------------------*
    DATA: lr_previous  TYPE REF TO cx_root,
          lt_euiinstln TYPE ieuiinstln,
          lt_mrcontact TYPE TABLE OF /idxgc/mrcontact,
          lv_anlage    TYPE anlage.
    FIELD-SYMBOLS: <fs_euiinstln> TYPE euiinstln.

    IF iv_anlage IS INITIAL.
      CALL FUNCTION 'ISU_DB_EUIINSTLN_SELECT'
        EXPORTING
          x_int_ui      = iv_int_ui
          x_dateto      = iv_keydate
          x_datefrom    = iv_keydate
        IMPORTING
          y_euiinstln   = lt_euiinstln
        EXCEPTIONS
          not_found     = 1
          system_error  = 2
          not_qualified = 3
          OTHERS        = 4.
      IF sy-subrc = 0 AND lines( lt_euiinstln ) = 1.
        TRY.
            ASSIGN lt_euiinstln[ 1 ] TO <fs_euiinstln>.
          CATCH cx_sy_itab_line_not_found INTO lr_previous.
            /idxgc/cx_general=>raise_exception_from_msg( ir_previous = lr_previous ).
        ENDTRY.
        lv_anlage = <fs_euiinstln>-anlage.
      ELSE.
        MESSAGE e000(/adesso/mdc_mrcontct) WITH iv_int_ui INTO gv_mtext.
        /idxgc/cx_general=>raise_exception_from_msg( ).
      ENDIF.
    ELSE.
      lv_anlage = iv_anlage.
    ENDIF.

    IF lv_anlage IS NOT INITIAL.
      SELECT * FROM /idxgc/mrcontact INTO TABLE lt_mrcontact
        WHERE anlage = lv_anlage AND fromdate <= iv_keydate AND todate >= iv_keydate.
      IF lines( lt_mrcontact ) = 1.
        rs_mrcontact = lt_mrcontact[ 1 ].
      ELSEIF lines( lt_mrcontact ) > 1.
        MESSAGE e000(/adesso/mdc_mrcontct) WITH lv_anlage iv_keydate INTO gv_mtext.
        /idxgc/cx_general=>raise_exception_from_msg( ).
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD STOP_MRCONTACT.
*--------------------------------------------------------------------*
* THIMEL.R, 20160324, Die Zeitscheibe in der Tabelle /IDXGC/MRCONTACT
*   wird zum Stichtag abgegrenzt.
*--------------------------------------------------------------------*
    DATA: lr_previous  TYPE REF TO cx_root,
          lt_mrcontact TYPE TABLE OF /idxgc/mrcontact,
          lt_euiinstln TYPE ieuiinstln,
          ls_mrcontact TYPE /idxgc/mrcontact,
          lv_anlage    TYPE anlage.

    FIELD-SYMBOLS: <fs_mrcontact> TYPE /idxgc/mrcontact,
                   <fs_euiinstln> TYPE euiinstln.

    IF iv_anlage IS INITIAL.
      CALL FUNCTION 'ISU_DB_EUIINSTLN_SELECT'
        EXPORTING
          x_int_ui      = iv_int_ui
          x_dateto      = iv_keydate
          x_datefrom    = iv_keydate
        IMPORTING
          y_euiinstln   = lt_euiinstln
        EXCEPTIONS
          not_found     = 1
          system_error  = 2
          not_qualified = 3
          OTHERS        = 4.
      IF sy-subrc = 0 AND lines( lt_euiinstln ) = 1.
        TRY.
            ASSIGN lt_euiinstln[ 1 ] TO <fs_euiinstln>.
          CATCH cx_sy_itab_line_not_found INTO lr_previous.
            /idxgc/cx_general=>raise_exception_from_msg( ir_previous = lr_previous ).
        ENDTRY.
        lv_anlage = <fs_euiinstln>-anlage.
      ELSE.
        MESSAGE e000(/adesso/mdc_mrcontct) WITH iv_int_ui INTO gv_mtext.
        /idxgc/cx_general=>raise_exception_from_msg( ).
      ENDIF.
    ELSE.
      lv_anlage = iv_anlage.
    ENDIF.

    SELECT * FROM /idxgc/mrcontact INTO TABLE lt_mrcontact
      WHERE anlage = iv_anlage AND fromdate <= iv_keydate AND todate >= iv_keydate.
    IF lines( lt_mrcontact ) = 1.
      ASSIGN lt_mrcontact[ 1 ] TO <fs_mrcontact>.
      <fs_mrcontact>-todate = iv_keydate.
      <fs_mrcontact>-ch_name = sy-uname.
      <fs_mrcontact>-ch_date = sy-datum.
      <fs_mrcontact>-ch_time = sy-uzeit.

      UPDATE /idxgc/mrcontact FROM <fs_mrcontact>.
      IF sy-subrc <> 0.
        MESSAGE e002(/adesso/mdc_mrcontct) INTO gv_mtext.
        /idxgc/cx_general=>raise_exception_from_msg( ).
      ENDIF.
    ELSEIF lines( lt_mrcontact ) > 1.
      MESSAGE e000(/adesso/mdc_mrcontct) WITH iv_anlage iv_keydate INTO gv_mtext.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
