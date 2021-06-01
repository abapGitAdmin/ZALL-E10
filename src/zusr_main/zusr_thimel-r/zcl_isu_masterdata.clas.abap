class ZCL_ISU_MASTERDATA definition
  public
  final
  create public .

public section.

  class-methods GET_EXT_UI
    importing
      !IV_INT_UI type INT_UI
      !IV_KEYDATE type /IDXGC/DE_KEYDATE default SY-DATUM
    returning
      value(RV_EXT_UI) type EXT_UI
    raising
      /ADESSO/CX_ISU_GENERAL .
  class-methods GET_INT_UI
    importing
      !IV_EXT_UI type EXT_UI optional
      !IV_ANLAGE type ANLAGE optional
      !IV_KEYDATE type /IDXGC/DE_KEYDATE default SY-DATUM
    returning
      value(RV_INT_UI) type INT_UI
    raising
      /ADESSO/CX_ISU_GENERAL .
  class-methods GET_SPARTYP
    importing
      !IV_INT_UI type INT_UI optional
      !IV_KEYDATE type /IDXGC/DE_KEYDATE default SY-DATUM
    returning
      value(RV_SPARTYP) type SPARTYP
    raising
      /ADESSO/CX_ISU_GENERAL .
  class-methods GET_SPARTE
    importing
      !IV_EXT_UI type EXT_UI optional
      !IV_INT_UI type INT_UI optional
      !IV_SERVICEID type SERVICEID optional
      !IV_ANLAGE type ANLAGE optional
      !IV_KEYDATE type /IDXGC/DE_KEYDATE default SY-DATUM
    returning
      value(RV_SPARTE) type SPARTE
    raising
      /ADESSO/CX_ISU_GENERAL .
  class-methods GET_PARTNER
    importing
      !IV_EXT_UI type EXT_UI optional
      !IV_INT_UI type INT_UI optional
      !IV_KEYDATE type /IDXGC/DE_KEYDATE default SY-DATUM
    returning
      value(RV_PARTNER) type BU_PARTNER
    raising
      /ADESSO/CX_ISU_GENERAL .
  class-methods GET_V_EANL
    importing
      !IV_ANLAGE type ANLAGE
      !IV_KEYDATE type /IDXGC/DE_KEYDATE default SY-DATUM
    returning
      value(RV_EANL) type V_EANL
    raising
      /ADESSO/CX_ISU_GENERAL .
  class-methods GET_ANLAGE
    importing
      !IV_EXT_UI type EXT_UI optional
      !IV_INT_UI type INT_UI optional
      !IV_KEYDATE type /IDXGC/DE_KEYDATE default SY-DATUM
    returning
      value(RV_ANLAGE) type ANLAGE
    raising
      /ADESSO/CX_ISU_GENERAL .
  class-methods GET_SERVPROV
    importing
      !IV_SERVICEID type SERVICEID
    returning
      value(RS_SERVPROV) type ESERVPROV
    raising
      /ADESSO/CX_ISU_GENERAL .
  class-methods GET_PREMISE
    importing
      !IV_ANLAGE type ANLAGE
      !IV_KEYDATE type /IDXGC/DE_KEYDATE default SY-DATUM
    returning
      value(RV_PREMISE) type VSTELLE
    raising
      /ADESSO/CX_ISU_GENERAL .
  class-methods GET_SERVICETYPE
    importing
      !IV_SERCODE type SERCODE
    returning
      value(RS_TECDE) type TECDE
    raising
      /ADESSO/CX_ISU_GENERAL .
  class-methods GET_CONN_OBJ
    importing
      !IV_PREMISE type VSTELLE
    returning
      value(RV_HAUS) type HAUS .
  class-methods GET_EVER
    importing
      !IV_INT_UI type INT_UI optional
      !IV_EXT_UI type EXT_UI optional
      !IV_ANLAGE type ANLAGE optional
      !IV_KEYDATE type /IDXGC/DE_KEYDATE default SY-DATUM
    returning
      value(RS_EVER) type EVER
    raising
      /ADESSO/CX_ISU_GENERAL .
  class-methods GET_GRID
    importing
      !IV_INT_UI type INT_UI
      !IV_KEYDATE type DATS default SY-DATUM
    returning
      value(RS_EUIGRID) type EUIGRID
    raising
      /ADESSO/CX_ISU_GENERAL .
protected section.
private section.

  class-data GV_MSGTEXT type STRING .
ENDCLASS.



CLASS ZCL_ISU_MASTERDATA IMPLEMENTATION.


  method GET_ANLAGE.

    DATA: lv_int_ui    TYPE          int_ui,
          ls_v_eanl    TYPE          v_eanl,
          lt_euiinstln TYPE TABLE OF euiinstln.

    FIELD-SYMBOLS: <fs_euiinstln> TYPE euiinstln.

    IF iv_int_ui IS NOT INITIAL.
      lv_int_ui = iv_int_ui.
    ELSEIF iv_ext_ui IS NOT INITIAL.
      lv_int_ui = get_int_ui( iv_ext_ui = iv_ext_ui iv_keydate = iv_keydate ).
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
    IF sy-subrc <> 0.
      MESSAGE i002(/ADESSO/ISU_GENERAL) WITH 'EUIINSTLN' iv_ext_ui iv_keydate INTO gv_msgtext.
      /ADESSO/CX_ISU_GENERAL=>raise_exception_from_msg( ).
    ENDIF.

    LOOP AT lt_euiinstln ASSIGNING <fs_euiinstln>.
      ls_v_eanl = get_v_eanl( iv_anlage = <fs_euiinstln>-anlage iv_keydate = iv_keydate ).
      IF ls_v_eanl-service IS NOT INITIAL.
        rv_anlage = <fs_euiinstln>-anlage.
        EXIT.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD GET_CONN_OBJ.

    CLEAR rv_haus.
    SELECT SINGLE haus FROM evbs INTO rv_haus WHERE vstelle = iv_premise.

  ENDMETHOD.


  METHOD GET_EVER.
    DATA: lv_int_ui TYPE int_ui,
          lv_anlage TYPE anlage.

    IF iv_int_ui IS INITIAL AND iv_ext_ui IS NOT INITIAL.
      lv_int_ui = /adesso/cl_isu_masterdata=>get_int_ui( iv_ext_ui  = iv_ext_ui iv_keydate = iv_keydate ).
    ELSE.
      lv_int_ui = iv_int_ui.
    ENDIF.

    IF iv_anlage IS INITIAL.
      lv_anlage = /adesso/cl_isu_masterdata=>get_anlage( iv_int_ui  = lv_int_ui iv_keydate = iv_keydate ).
    ENDIF.

    SELECT SINGLE * INTO rs_ever FROM ever WHERE anlage = lv_anlage AND einzdat <= iv_keydate AND auszdat >= iv_keydate.
  ENDMETHOD.


  METHOD GET_EXT_UI.

    DATA: ls_euitrans TYPE euitrans.

    CALL FUNCTION 'ISU_DB_EUITRANS_INT_SINGLE'
      EXPORTING
        x_int_ui     = iv_int_ui
        x_keydate    = iv_keydate
      IMPORTING
        y_euitrans   = ls_euitrans
      EXCEPTIONS
        not_found    = 1
        system_error = 2
        OTHERS       = 3.

    IF sy-subrc <> 0.
      MESSAGE i002(/adesso/isu_general) WITH 'EUITRANS' iv_int_ui iv_keydate INTO gv_msgtext.
      /adesso/cx_isu_general=>raise_exception_from_msg( ).
    ELSE.
      rv_ext_ui = ls_euitrans-ext_ui.
    ENDIF.

  ENDMETHOD.


  METHOD GET_GRID.
    CALL FUNCTION 'ISU_DB_EUIGRID_INT_SINGLE'
      EXPORTING
        x_int_ui     = iv_int_ui
        x_keydate    = iv_keydate
      IMPORTING
        y_euigrid    = rs_euigrid
      EXCEPTIONS
        not_found    = 1
        system_error = 2
        OTHERS       = 3.
    IF sy-subrc <> 0.
      /adesso/cx_isu_general=>raise_exception_from_msg( ).
    ENDIF.

  ENDMETHOD.


  METHOD GET_INT_UI.

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
        MESSAGE i002(/adesso/isu_general) WITH 'EUITRANS' iv_ext_ui iv_keydate INTO gv_msgtext.
        /adesso/cx_isu_general=>raise_exception_from_msg( ).
      ELSE.
        rv_int_ui = ls_euitrans-int_ui.
      ENDIF.
    ELSE.
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
        MESSAGE i002(/adesso/isu_general) WITH 'EUIINSTLN' iv_anlage iv_keydate INTO gv_msgtext.
*        zcx_agc_masterdata=>raise_exception_from_msg( ).
      ELSE.
        READ TABLE lt_euiinstln ASSIGNING <fs_euiinstln> INDEX 1.
        rv_int_ui = <fs_euiinstln>-int_ui.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD GET_PARTNER.

    DATA: lt_partner TYPE TABLE OF bapiisupodpartner,
          lv_ext_ui  TYPE ext_ui.

    FIELD-SYMBOLS: <fs_partner> TYPE bapiisupodpartner.

    IF iv_ext_ui IS INITIAL.
      lv_ext_ui = get_ext_ui( iv_int_ui = iv_int_ui iv_keydate = iv_keydate ).
    ELSE.
      lv_ext_ui = iv_ext_ui.
    ENDIF.

    CALL FUNCTION 'BAPI_ISUPOD_GETPARTNER'
      EXPORTING
        keydate         = iv_keydate
        pointofdelivery = lv_ext_ui
      TABLES
        partner         = lt_partner.

    IF lines( lt_partner ) = 1.
      READ TABLE lt_partner ASSIGNING <fs_partner> INDEX 1.
      rv_partner = <fs_partner>-partner.
    ELSEIF lines( lt_partner ) > 1.
      MESSAGE i104(/adesso/isu_general) WITH lv_ext_ui iv_keydate INTO gv_msgtext.
      /adesso/cx_isu_general=>raise_exception_from_msg( ).
    ELSE.
      MESSAGE i103(/adesso/isu_general) WITH lv_ext_ui iv_keydate INTO gv_msgtext.
      /adesso/cx_isu_general=>raise_exception_from_msg( ).
    ENDIF.

  ENDMETHOD.


  METHOD GET_PREMISE.

    CLEAR rv_premise.

    SELECT SINGLE vstelle FROM eanl INTO rv_premise WHERE anlage = iv_anlage.

  ENDMETHOD.


  method GET_SERVICETYPE.

   SELECT SINGLE * FROM tecde INTO rs_tecde
      WHERE service = iv_sercode.

    IF rs_tecde IS INITIAL.
      MESSAGE i001(/ADESSO/ISU_GENERAL) WITH 'TECDE' iv_sercode INTO gv_msgtext.
      /ADESSO/CX_ISU_GENERAL=>raise_exception_from_msg( ).
    ENDIF.

  endmethod.


  METHOD GET_SERVPROV.

    SELECT SINGLE * FROM eservprov INTO rs_servprov
      WHERE serviceid = iv_serviceid.

    IF rs_servprov IS INITIAL.
      MESSAGE i001(/ADESSO/ISU_GENERAL) WITH 'ESERVPROV' iv_serviceid INTO gv_msgtext.
      /ADESSO/CX_ISU_GENERAL=>raise_exception_from_msg( ).
    ENDIF.

  ENDMETHOD.


  METHOD GET_SPARTE.
    DATA: ls_servprov TYPE eservprov,
          ls_tecde    TYPE tecde,
          ls_v_eanl   TYPE v_eanl.

    IF iv_int_ui IS NOT INITIAL.
      ls_v_eanl = get_v_eanl( iv_anlage = get_anlage( iv_int_ui = iv_int_ui iv_keydate = iv_keydate ) iv_keydate = iv_keydate ).
      IF ls_v_eanl-sparte IS INITIAL.
        MESSAGE i101(/adesso/isu_general) WITH iv_int_ui INTO gv_msgtext.
        /adesso/cx_isu_general=>raise_exception_from_msg( ).
      ELSE.
        rv_sparte = ls_v_eanl-sparte.
      ENDIF.
    ELSEIF iv_ext_ui IS NOT INITIAL.
      ls_v_eanl = get_v_eanl( iv_anlage = get_anlage( iv_ext_ui = iv_ext_ui iv_keydate = iv_keydate ) iv_keydate = iv_keydate ).
      IF ls_v_eanl-sparte IS INITIAL.
        MESSAGE i101(/adesso/isu_general) WITH iv_int_ui INTO gv_msgtext.
        /adesso/cx_isu_general=>raise_exception_from_msg( ).
      ELSE.
        rv_sparte = ls_v_eanl-sparte.
      ENDIF.
    ELSEIF iv_serviceid IS NOT INITIAL.
      ls_servprov = get_servprov( iv_serviceid = iv_serviceid ).
      ls_tecde = get_servicetype( iv_sercode = ls_servprov-service ).
      IF ls_tecde-division IS INITIAL.
        MESSAGE i100(/adesso/isu_general) WITH iv_serviceid INTO gv_msgtext.
        /adesso/cx_isu_general=>raise_exception_from_msg( ).
      ELSE.
        rv_sparte = ls_tecde-division.
      ENDIF.
    ELSEIF iv_anlage IS NOT INITIAL.
      ls_v_eanl = get_v_eanl( iv_anlage = iv_anlage iv_keydate = iv_keydate ).
      rv_sparte = ls_v_eanl-sparte.
      IF rv_sparte IS INITIAL.
        MESSAGE i102(/adesso/isu_general) WITH iv_anlage INTO gv_msgtext.
        /adesso/cx_isu_general=>raise_exception_from_msg( ).
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD GET_SPARTYP.

    DATA: lv_sparte TYPE sparte.

    lv_sparte = get_sparte( iv_int_ui = iv_int_ui iv_keydate = iv_keydate ).

    IF lv_sparte IS NOT INITIAL.

      SELECT SINGLE spartyp FROM tespt INTO rv_spartyp WHERE sparte = lv_sparte.

      IF rv_spartyp IS INITIAL.
        MESSAGE i001(/adesso/isu_general) WITH 'TESPT' lv_sparte INTO gv_msgtext.
        /adesso/cx_isu_general=>raise_exception_from_msg( ).
      ENDIF.

    ENDIF.

  ENDMETHOD.


  method GET_V_EANL.

    SELECT SINGLE * FROM v_eanl INTO rv_eanl
      WHERE anlage = iv_anlage AND
            bis >= iv_keydate AND
            ab <= iv_keydate.
    IF sy-subrc <> 0.
      MESSAGE i002(/ADESSO/ISU_GENERAL) WITH 'V_EANL' iv_anlage INTO gv_msgtext.
      /ADESSO/CX_ISU_GENERAL=>raise_exception_from_msg( ).
    ENDIF.

  endmethod.
ENDCLASS.
