class ZCL_AGC_MASTERDATA definition
  public
  create public .

public section.

  interfaces BI_OBJECT .
  interfaces BI_PERSISTENT .
  interfaces IF_WORKFLOW .

  constants GC_ANLAGENART_PANL type ANLART value 'PANL'. "#EC NOTEXT
  constants GC_LASTPROFIL_NSP type ZEDMLASTPROFIL value 'NSP'. "#EC NOTEXT
  constants GC_METMETHOD_E14 type EIDESWTMDMETMETHOD value 'E14'. "#EC NOTEXT

  class-methods GET_SPARTE
    importing
      !IV_EXT_UI type EXT_UI optional
      !IV_INT_UI type INT_UI optional
      !IV_SERVICEID type SERVICEID optional
      !IV_KEYDATE type DATS default SY-DATUM
      !IV_ANLAGE type ANLAGE optional
    returning
      value(RV_SPARTE) type SPARTE
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_ANLAGE
    importing
      !IV_EXT_UI type EXT_UI optional
      !IV_INT_UI type INT_UI optional
      !IV_KEYDATE type DATS default SY-DATUM
    returning
      value(RV_ANLAGE) type ANLAGE
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_INT_UI
    importing
      !IV_EXT_UI type EXT_UI optional
      !IV_ANLAGE type ANLAGE optional
      !IV_KEYDATE type DATS default SY-DATUM
    returning
      value(RV_INT_UI) type INT_UI
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_EXT_UI
    importing
      !IV_INT_UI type INT_UI
      !IV_KEYDATE type DATS default SY-DATUM
    returning
      value(RV_EXT_UI) type EXT_UI
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_V_EANL
    importing
      !IV_ANLAGE type ANLAGE
      !IV_KEYDATE type DATS default SY-DATUM
    returning
      value(RV_EANL) type V_EANL
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_ALL_SERVPROV_DISTRIBUTOR
    importing
      !IV_INT_UI type INT_UI
    returning
      value(RT_SERVPROV_DETAILS) type /IDXGC/T_SERVPROV_DETAILS .
  class-methods GET_METMETHOD
    importing
      !IV_ANLAGE type ANLAGE optional
      !IV_INT_UI type INT_UI optional
      !IV_KEYDATE type DATS default SY-DATUM
    returning
      value(RV_METMETHOD) type EIDESWTMDMETMETHOD
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_PORTION
    importing
      !IV_ABLEINH type ABLEINHEIT
    returning
      value(RV_PORTION) type PORTION
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_PERIOD_LENGTH
    importing
      !IV_PORTION type PORTION
    returning
      value(RV_PERIOD_LENGTH) type PERIODEW
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_CONTRACT
    importing
      !IV_ANLAGE type ANLAGE
      !IV_KEYDATE type DATS default SY-DATUM
    returning
      value(RV_CONTRACT) type VERTRAG
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_EVER
    importing
      !IV_ANLAGE type ANLAGE
      !IV_KEYDATE type DATS default SY-DATUM
    returning
      value(RS_EVER) type EVER
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_SERVPROV
    importing
      !IV_SERVICEID type SERVICEID
    returning
      value(RS_SERVPROV) type ESERVPROV
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_SERVICETYPE
    importing
      !IV_SERCODE type SERCODE
    returning
      value(RS_TECDE) type TECDE
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_PROFIL
    importing
      !IV_ANLAGE type ANLAGE
      !IV_KEYDATE type DATS default SY-DATUM
      !IS_ZEDMZPKTH type ZEDMZPKTH optional
    returning
      value(RV_PROFIL) type ZEDMLASTPROFIL
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_SPEBENE_LIEFERSTELLE
    importing
      !IV_ANLAGE type ANLAGE
      !IV_KEYDATE type DATS default SY-DATUM
    returning
      value(RV_SPEBENE_LST) type SPEBENE
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_SPEBENE_MESSUNG
    importing
      !IV_ANLAGE type ANLAGE
      !IV_KEYDATE type DATS default SY-DATUM
    returning
      value(RV_SPEBENE_MES) type ZZESPEBENE_MS
    raising
      ZCX_AGC_MASTERDATA .
  type-pools ABAP .
  class-methods GET_KZ_HHK
    importing
      !IV_ANLAGE type ANLAGE
      !IV_KEYDATE type DATS default SY-DATUM
      !IS_ZEDMZPKTH type ZEDMZPKTH optional
    returning
      value(RV_HH_KUNDE) type ABAP_BOOL
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_PROGYEARCONS
    importing
      !IV_ANLAGE type ANLAGE
      !IV_KEYDATE type DATS default SY-DATUM
    returning
      value(RV_PROGYEARCONS) type EIDESWTMDPROGYEARCONS
    raising
      ZCX_AGC_MASTERDATA .
  class-methods IS_NETZ
    returning
      value(RV_IS_NETZ) type ABAP_BOOL
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_PERVERBR
    importing
      !IV_ANLAGE type ANLAGE
      !IV_KEYDATE type DATS default SY-DATUM
    returning
      value(RV_PERVERBR) type PERVERBR
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_FALLGRUPPE_GABI
    importing
      !IV_ANLAGE type ANLAGE
      !IV_KEYDATE type DATS default SY-DATUM
    returning
      value(RV_FALLGRUPPE) type ZZFALLGRUPPE
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_MAXDEMAND
    importing
      !IV_ANLAGE type ANLAGE
      !IV_KEYDATE type DATS default SY-DATUM
    returning
      value(RV_MAXDEMAND) type EIDESWTMDMAXDEMAND
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_MABIS_TIME_SERIES
    importing
      !IV_ANLAGE type ANLAGE
      !IV_KEYDATE type DATS default SY-DATUM
    returning
      value(RS_TIME_SERIES) type ZLWZEITREIHENTYP
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_LOSS_FACTOR
    importing
      !IV_ANLAGE type ANLAGE
      !IV_KEYDATE type DATS default SY-DATUM
    returning
      value(RV_LOSS_FACTOR) type /IDXGC/DE_LOSSFACT_EXT_1
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_TTYP_ATTRIBUTES
    importing
      !IV_ANLAGE type ANLAGE optional
      !IV_KEYDATE type DATS default SY-DATUM
      !IV_TTYP type TARIFTYP optional
    returning
      value(RS_TTYP_ATTRIBUTES) type ZEPDPRODUKTTARIFTYP
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_DEVICE_DATA
    importing
      !IV_ANLAGE type ANLAGE
      !IV_KEYDATE type DATS default SY-DATUM
    returning
      value(RT_DEVICE_DATA) type /IDXGC/T_DEVICE_DATA
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_MSB
    importing
      !IV_ANLAGE type ANLAGE
      !IV_KEYDATE type DATS default SY-DATUM
    returning
      value(RS_MSB) type ESERVPROV
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_MDL
    importing
      !IV_ANLAGE type ANLAGE
      !IV_KEYDATE type DATS default SY-DATUM
    returning
      value(RS_MDL) type ESERVPROV
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_SERVICES
    importing
      !IV_INT_UI type INT_UI
      !IV_KEYDATE type DATS
    returning
      value(RT_SERVICES) type /IDXGC/T_PROC_AGENT
    raising
      ZCX_AGC_MASTERDATA .
  type-pools ISU20 .
  class-methods GET_INSTLN_FACTS
    importing
      !IV_ANLAGE type ANLAGE
      !IV_KEYDATE type DATS default SY-DATUM
    returning
      value(RS_INSTLN_FACTS) type ISU20_INSTLN_FACTS_AUTO
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_COM_DISC_PERC
    importing
      !IV_ANLAGE type ANLAGE
      !IV_KEYDATE type DATS default SY-DATUM
      !IS_INSTLN_FACTS_AUTO type ISU20_INSTLN_FACTS_AUTO optional
    returning
      value(RV_COM_DISC_PERC) type DEC_16_10_S
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_PARTNER
    importing
      !IV_EXT_UI type EXT_UI
      !IV_KEYDATE type DATS default SY-DATUM
    returning
      value(RV_PARTNER) type BU_PARTNER
    raising
      ZCX_AGC_MASTERDATA .
  class-methods IS_REG_DIVISION_TYPE
    importing
      !IV_DIVISION_TYPE type SPARTYP
    returning
      value(RV_REG_DIVISION_TYPE) type KENNZX
    raising
      ZCX_AGC_MASTERDATA .
  class-methods IS_REG_PROCESS
    importing
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_REG_PROCESS) type KENNZX
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_REGISTER_DATA
    importing
      !IS_V_EGER type V_EGER
    returning
      value(RT_REGISTER_DATA) type /IDXGC/T_REGISTER_DATA
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_QUANTITY_TRANSFORMER
    importing
      !IV_MATNR type MATNR
    returning
      value(RV_QUANTITY) type CHAR35
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_STARTSETTLDATE
    importing
      !IV_INT_UI type INT_UI optional
      !IV_KEYDATE type DATS default SY-DATUM
      !IS_EVER type EVER optional
    returning
      value(RT_SETTLSTARTDATE) type DATS
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_ENDSETTLDATE
    importing
      !IV_INT_UI type INT_UI optional
      !IV_KEYDATE type DATS default SY-DATUM
      !IS_EVER type EVER optional
    returning
      value(RT_SETTLENDDATE) type DATS
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_SETTLUNIT
    importing
      !IV_SERVICE_PROV type SERVICE_PROV
    returning
      value(RT_SETTLUNIT) type T_EEDMSETTLUNIT
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_UISETTLUNIT
    importing
      !IV_INT_UI type INT_UI
    returning
      value(RT_UISETTLUNIT) type T_EEDMUISETTLUNIT
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_REGIO_STRUCTURE
    importing
      !IV_ANLAGE type ANLAGE
      !IV_KEYDATE type DATS default SY-DATUM
    returning
      value(RS_REGIO_STRUCTURE) type ISU_REG0
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_DIV_FROM_DIVCAT_AND_INSTLN
    importing
      !IV_DIVCAT type SPARTYP
      !IV_ANLAGE type ANLAGE
    returning
      value(RV_SPARTE) type SPARTE
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_OWN_MSB_MDL
    returning
      value(RT_V_ESERVPROV) type /IDXGC/T_ESERVPROV
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_GAS_QUALITY
    importing
      !IV_ANLAGE type ANLAGE optional
      !IV_EDMMGEBIET type ZZEDMMGEBIET optional
      !IV_KEYDATE type DATS default SY-DATUM
    returning
      value(RV_GAS_QUALITY) type /IDXGC/DE_GAS_QUALITY
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_MARKET_AREA
    importing
      !IV_ANLAGE type ANLAGE optional
      !IV_EDMMGEBIET type ZZEDMMGEBIET optional
      !IV_KEYDATE type DATS default SY-DATUM
    returning
      value(RV_MARKET_AREA) type /IDXGC/DE_MARKET_AREA
    raising
      ZCX_AGC_MASTERDATA .
  class-methods MAP_EANL_CODES
    importing
      value(IS_EANL) type EANL
    changing
      !CS_SPEBENE_MESSUNG type CHAR3
      !CS_SPEBENE_ENTNAHME type CHAR3
      !CS_DRUCKSTUFE type CHAR3 .
  class-methods GET_CONTRACT_COMMENT
    importing
      !IV_ANLAGE type ANLAGE optional
      !IS_EVER type EVER optional
    returning
      value(RV_FREE_TEXT_VALUE) type /IDXGC/DE_FREE_TEXT_VALUE
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_SETTLEMENT_TERRITORY
    importing
      !IV_INT_UI type INT_UI
      !IV_KEYDATE type DATS
      !IR_ISU_POD type ref to ZCL_AGC_ISU_POD optional
    returning
      value(RV_SETTLTERR_EXT) type /IDXGC/DE_SETTLTERR_EXT
    raising
      ZCX_AGC_MASTERDATA .
  class-methods GET_NETZBETREIBERWECHSEL
    importing
      !IV_INT_UI type INT_UI
      !IV_KEYDATE type DATS
    returning
      value(RV_KENNZ_NETZBETWECHS) type KENNZX
    raising
      ZCX_AGC_MASTERDATA .
protected section.
private section.

  class-data GV_MSGTEXT type STRING .
ENDCLASS.



CLASS ZCL_AGC_MASTERDATA IMPLEMENTATION.


  METHOD get_all_servprov_distributor.
***************************************************************************************************
* Liefert alle Netzbetreiber (ServiceID) zum Zählpunkt. Im Netz sollte dies nur einer sein.
***************************************************************************************************
    DATA:
      ls_servprov_details TYPE          /idxgc/s_servprov_details,
      lt_euigrid          TYPE TABLE OF euigrid,
      lt_egridh           TYPE TABLE OF egridh.
    FIELD-SYMBOLS:
      <fs_servprov_details> TYPE /idxgc/s_servprov_details,
      <fs_euigrid>          TYPE euigrid,
      <fs_egridh>           TYPE egridh.

    "Daten ermitteln
    SELECT * FROM euigrid INTO TABLE lt_euigrid WHERE int_ui = iv_int_ui ORDER BY datefrom ASCENDING.
    LOOP AT lt_euigrid ASSIGNING <fs_euigrid>.
      SELECT * FROM egridh INTO TABLE lt_egridh
        WHERE grid_id = <fs_euigrid>-grid_id AND ab <= <fs_euigrid>-dateto AND bis >= <fs_euigrid>-datefrom.
      LOOP AT lt_egridh ASSIGNING <fs_egridh>.
        CLEAR: ls_servprov_details.
        ls_servprov_details-date_from   = <fs_euigrid>-datefrom.
        ls_servprov_details-date_to     = <fs_euigrid>-dateto.
        IF <fs_egridh>-ab > <fs_euigrid>-datefrom.
          ls_servprov_details-date_from = <fs_egridh>-ab.
        ENDIF.
        IF <fs_egridh>-bis < <fs_euigrid>-dateto.
          ls_servprov_details-date_to = <fs_egridh>-bis.
        ENDIF.
        ls_servprov_details-service_id = <fs_egridh>-distributor.
        APPEND ls_servprov_details TO rt_servprov_details.
      ENDLOOP.
    ENDLOOP.

    "Daten sortieren und verdichten
    SORT rt_servprov_details BY date_from.
    LOOP AT rt_servprov_details ASSIGNING <fs_servprov_details>.
      AT FIRST.
        ls_servprov_details = <fs_servprov_details>.
        CONTINUE.
      ENDAT.
      IF ls_servprov_details-service_id   = <fs_servprov_details>-service_id.
        <fs_servprov_details>-date_from = ls_servprov_details-date_from.
        DELETE TABLE rt_servprov_details FROM ls_servprov_details.
      ENDIF.
      ls_servprov_details = <fs_servprov_details>.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_anlage.
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
      MESSAGE i002(zagc_masterdata) WITH 'EUIINSTLN' iv_ext_ui iv_keydate INTO gv_msgtext.
      zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDIF.

    LOOP AT lt_euiinstln ASSIGNING <fs_euiinstln>.
      ls_v_eanl = get_v_eanl( iv_anlage = <fs_euiinstln>-anlage iv_keydate = iv_keydate ).
      IF ls_v_eanl-service IS NOT INITIAL.
        rv_anlage = <fs_euiinstln>-anlage.
        EXIT.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_com_disc_perc.

    DATA: ls_instln_facts TYPE          isu20_instln_facts_auto,
          lv_v_eanl       TYPE          v_eanl,
          lt_edsch        TYPE TABLE OF edsch,
          lv_value        TYPE          dec_16_10_s.

    FIELD-SYMBOLS: <fs_discount>       TYPE         isu20_adiscper_auto,
                   <fs_discount_value> LIKE LINE OF <fs_discount>-ivalue,
                   <fs_edsch>          LIKE LINE OF lt_edsch.

    lv_v_eanl = zcl_agc_masterdata=>get_v_eanl( iv_anlage = iv_anlage iv_keydate = iv_keydate ).
    IF is_instln_facts_auto IS INITIAL.
      ls_instln_facts = zcl_agc_masterdata=>get_instln_facts( iv_anlage = iv_anlage iv_keydate = iv_keydate ).
    ELSE.
      ls_instln_facts = is_instln_facts_auto.
    ENDIF.

    IF zcl_agc_masterdata=>is_netz( ) = abap_true. "Netz
      CASE lv_v_eanl-tariftyp.
        WHEN 'NETZTKNEU'.
          READ TABLE ls_instln_facts-facts_auto-iadiscper ASSIGNING <fs_discount> WITH KEY operand = 'BRABATTS'.
        WHEN 'NETZNGKGLN' OR 'NETZUGKGLN'.
          READ TABLE ls_instln_facts-facts_auto-iadiscper ASSIGNING <fs_discount> WITH KEY operand = 'NZSTADTRAB'.
        WHEN OTHERS.
          rv_com_disc_perc = 0.
      ENDCASE.
    ELSE.                                          "Vertrieb
      CASE lv_v_eanl-tariftyp.
        WHEN '01TVBSGWN1' OR '01TVBSHHN1'.
          READ TABLE ls_instln_facts-facts_auto-iadiscper ASSIGNING <fs_discount> WITH KEY operand = 'BRABATTS'.
        WHEN 'SJAHRS_E+N' OR 'STROMS_E+N'.
          rv_com_disc_perc = 10.
        WHEN OTHERS.
          rv_com_disc_perc = 0.
      ENDCASE.
    ENDIF.

    IF <fs_discount> IS ASSIGNED.
      LOOP AT <fs_discount>-ivalue ASSIGNING <fs_discount_value> WHERE ab <= iv_keydate AND bis >= iv_keydate. ENDLOOP.

      IF <fs_discount_value> IS ASSIGNED.
        CALL FUNCTION 'ISU_DISCOUNT_READ'
          EXPORTING
            x_discount    = <fs_discount_value>-rabzus
          TABLES
            t_edsch       = lt_edsch
          EXCEPTIONS
            general_fault = 1
            wrong_waers   = 2
            OTHERS        = 3.
        IF sy-subrc <> 0.
          MESSAGE i002(zagc_masterdata) WITH 'EDSCH' iv_anlage INTO gv_msgtext.
          zcx_agc_masterdata=>raise_exception_from_msg( ).
        ELSE.
          LOOP AT lt_edsch ASSIGNING <fs_edsch> WHERE ab <= iv_keydate AND bis >= iv_keydate. ENDLOOP.
          IF <fs_edsch> IS ASSIGNED.
            rv_com_disc_perc = <fs_edsch>-rabproz.
          ENDIF.
        ENDIF.
      ELSE.
        rv_com_disc_perc = 0.
      ENDIF.
    ELSEIF <fs_discount> IS NOT ASSIGNED AND rv_com_disc_perc IS INITIAL.
      rv_com_disc_perc = 0.
    ENDIF.

    rv_com_disc_perc = round( val = rv_com_disc_perc dec = 4 mode = cl_abap_math=>round_half_even ).

  ENDMETHOD.


  METHOD get_contract.
    SELECT SINGLE vertrag FROM ever INTO rv_contract
      WHERE anlage = iv_anlage AND
            einzdat LE iv_keydate AND
            auszdat GE iv_keydate.
    IF sy-subrc <> 0.
      MESSAGE i002(zagc_masterdata) WITH 'EVER' iv_anlage iv_keydate INTO gv_msgtext.
      zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD get_contract_comment.
    DATA: ls_ever TYPE ever.

    IF is_ever IS INITIAL.
      ls_ever = zcl_agc_masterdata=>get_ever( iv_anlage = iv_anlage ).
    ELSE.
      ls_ever = is_ever.
    ENDIF.

    rv_free_text_value = '#SWSG#'.
    IF ls_ever-zzgue IS INITIAL.
      CONCATENATE rv_free_text_value 'NONE' ls_ever-zzscenario INTO rv_free_text_value SEPARATED BY ';'.
    ELSE.
      CONCATENATE rv_free_text_value ls_ever-zzgue ls_ever-zzscenario INTO rv_free_text_value SEPARATED BY ';'.
    ENDIF.
  ENDMETHOD.


  METHOD get_device_data.

    DATA: lt_rt_anlage    TYPE TABLE OF isu_ranges,   "TYPE RANGE OF anlage,
          ls_rt_anlage    LIKE LINE OF  lt_rt_anlage,
          ls_v_eanl       TYPE          v_eanl,
          lv_lines        TYPE          i,
          lt_v_eger       TYPE          t_v_eger,
          lt_v_eger_final TYPE          t_v_eger,
          lt_ezug         TYPE TABLE OF ezug,
          lt_ezuz         TYPE TABLE OF ezuz,
          lt_logiknr      TYPE TABLE OF logiknr_ls,
          lt_etdz         TYPE          isu07_ietdz,
          ls_evbs         TYPE          evbs,
          lt_egpl         TYPE TABLE OF egpl,
          ls_etyp         TYPE          etyp,
          ls_device_data  LIKE LINE OF  rt_device_data,
          lv_bdew_cci     TYPE          /idexge/e_bdewcci.

    FIELD-SYMBOLS: <fs_v_eger_final> LIKE LINE OF lt_v_eger_final,
                   <fs_v_eger>       LIKE LINE OF lt_v_eger,
                   <fs_ezug>         LIKE LINE OF lt_ezug,
                   <fs_ezuz>         LIKE LINE OF lt_ezuz,
                   <fs_etdz>         TYPE         etdz,
                   <fs_egpl>         TYPE         egpl,
                   <fs_device_data>  LIKE LINE OF rt_device_data.

    CLEAR lv_lines.
    ls_rt_anlage-sign   = 'I'.
    ls_rt_anlage-option = 'EQ'.
    ls_rt_anlage-low    = iv_anlage.
    APPEND ls_rt_anlage TO lt_rt_anlage.

    CALL FUNCTION 'ISU_DB_EGER_SELECT_RANGE'
      EXPORTING
        x_keydate      = iv_keydate
        x_read_egerr   = abap_true
      IMPORTING
        y_count        = lv_lines
      TABLES
        xt_anlage      = lt_rt_anlage
        yt_v_eger      = lt_v_eger
      EXCEPTIONS
        not_found      = 1
        date_invalid   = 2
        system_error   = 3
        internal_error = 4
        OTHERS         = 5.

    IF sy-subrc <> 0.
      MESSAGE i002(zagc_masterdata) WITH 'EGERH / EGERR' iv_anlage INTO gv_msgtext.
      zcx_agc_masterdata=>raise_exception_from_msg( ).
    ELSE.
      APPEND LINES OF lt_v_eger TO lt_v_eger_final.
      CLEAR lt_v_eger.
    ENDIF.

    "Gerätezuordnung prüfen nur auf Netzseite
    IF is_netz( ) = abap_true.
      LOOP AT lt_v_eger_final ASSIGNING <fs_v_eger_final>.
        "Prüfung Gerätezuordnung auf Geräteebene
        CALL FUNCTION 'ISU_DB_EZUG_SELECT'
          EXPORTING
            x_logiknr     = <fs_v_eger_final>-logiknr
            x_ab          = iv_keydate
            x_bis         = iv_keydate
          TABLES
            t_ezug        = lt_ezug
          EXCEPTIONS
            not_found     = 1
            system_error  = 2
            not_qualified = 3
            OTHERS        = 4.
        IF sy-subrc <> 0.
        ENDIF.

        LOOP AT lt_ezug ASSIGNING <fs_ezug>.
          APPEND <fs_ezug>-logiknr2 TO lt_logiknr.
        ENDLOOP.

        "Prüfung Gerätezuordnung auf Zählwerksebene
        CALL FUNCTION 'ISU_DB_ETDZ_SELECT'
          EXPORTING
            x_equnr       = <fs_v_eger_final>-equnr
            x_ab          = iv_keydate
            x_bis         = iv_keydate
          TABLES
            t_etdz        = lt_etdz
          EXCEPTIONS
            not_found     = 1
            system_error  = 2
            not_qualified = 3
            OTHERS        = 4.

        IF sy-subrc = 0.
          LOOP AT lt_etdz ASSIGNING <fs_etdz>.
            CALL FUNCTION 'ISU_DB_EZUZ_SELECT'
              EXPORTING
                x_logikzw     = <fs_etdz>-logikzw
                x_ab          = iv_keydate
                x_bis         = iv_keydate
              TABLES
                t_ezuz        = lt_ezuz
              EXCEPTIONS
                not_found     = 1
                system_error  = 2
                not_qualified = 3
                OTHERS        = 4.
            IF sy-subrc = 0.
              LOOP AT lt_ezuz ASSIGNING <fs_ezuz>.
                APPEND <fs_ezuz>-logiknr2 TO lt_logiknr.
              ENDLOOP.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDLOOP.
    ENDIF.

    SORT lt_logiknr BY logiknr.
    DELETE ADJACENT DUPLICATES FROM lt_logiknr.

    CALL FUNCTION 'ISU_DB_EGER_SELECT_LOGIKNR'
      EXPORTING
        x_ab          = sy-datum
        x_bis         = sy-datum
        x_read_egerr  = abap_true
      TABLES
        t_logiknr     = lt_logiknr
        t_v_eger      = lt_v_eger
      EXCEPTIONS
        not_found     = 1
        not_qualified = 2
        OTHERS        = 3.
    IF sy-subrc = 0.
      APPEND LINES OF lt_v_eger TO lt_v_eger_final.
      CLEAR lt_v_eger.
    ENDIF.

    "Gerätezuordnung auf Anschlussobjektebene auswerten bei der Sparte Strom und Tariftyp nicht NETZTKNEU
    "Diese Auswertung wird nur für die technischen Steuereinrichtungen benötigt und nur auf dem Netzmandanten!!!
    ls_v_eanl = zcl_agc_masterdata=>get_v_eanl( iv_anlage = iv_anlage iv_keydate = iv_keydate ).
    IF ls_v_eanl-sparte = zif_agc_datex_utilmd_co=>gc_sparte_strom AND
       ls_v_eanl-tariftyp <> 'NETZTKNEU' AND
       is_netz( ) = abap_true.

      CALL FUNCTION 'ISU_DB_EVBS_SINGLE'
        EXPORTING
          x_vstelle = ls_v_eanl-vstelle
        IMPORTING
          y_evbs    = ls_evbs
        EXCEPTIONS
          OTHERS    = 1.

      IF sy-subrc = 0.
        APPEND INITIAL LINE TO lt_egpl ASSIGNING <fs_egpl>.
        <fs_egpl>-haus = ls_evbs-haus.


        CALL FUNCTION 'ISU_DB_EGPL_FORALL_HAUS'
          TABLES
            t_egpl = lt_egpl
          EXCEPTIONS
            OTHERS = 1.

        IF sy-subrc = 0.
          LOOP AT lt_egpl ASSIGNING <fs_egpl>.
            APPEND INITIAL LINE TO lt_v_eger ASSIGNING <fs_v_eger>.
            <fs_v_eger>-bis     = iv_keydate.
            <fs_v_eger>-ab      = iv_keydate.
            <fs_v_eger>-devloc  = <fs_egpl>-devloc.
          ENDLOOP.

          SORT lt_v_eger BY devloc.
          DELETE ADJACENT DUPLICATES FROM lt_v_eger COMPARING devloc.

          CALL FUNCTION 'ISU_DB_EGER_FORALL_DEVLOC'
            TABLES
              t_v_eger = lt_v_eger
            EXCEPTIONS
              OTHERS   = 0.
          IF sy-subrc = 0.
            LOOP AT lt_v_eger ASSIGNING <fs_v_eger>.
              "Geräte, die auch in Anlagen eingebaut sind werden wieder aussortiert
              SELECT COUNT(*) FROM eastl WHERE logiknr = <fs_v_eger>-logiknr AND
                                               ab <= iv_keydate AND
                                               bis >= iv_keydate.
              IF sy-subrc = 0.
                DELETE lt_v_eger.
                CONTINUE.
              ENDIF.

              "Gerätetyp / Funktionsklasse überprüfen
              CALL FUNCTION 'ISU_DB_ETYP_SINGLE'
                EXPORTING
                  x_matnr      = <fs_v_eger>-matnr
                IMPORTING
                  y_etyp       = ls_etyp
                EXCEPTIONS
                  not_found    = 1
                  system_error = 2
                  OTHERS       = 3.
              IF ls_etyp-funklas <> 'TR' AND
                 ls_etyp-funklas <> 'TU' AND
                 ls_etyp-funklas <> 'FRE'.
                DELETE lt_v_eger.
                CONTINUE.
              ENDIF.
              APPEND <fs_v_eger> TO lt_v_eger_final.
            ENDLOOP.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    SORT lt_v_eger_final BY logiknr.
    DELETE ADJACENT DUPLICATES FROM lt_v_eger_final COMPARING logiknr.

    "Finales Füllen der Gerätedaten
    LOOP AT lt_v_eger_final ASSIGNING <fs_v_eger_final>.
      MOVE-CORRESPONDING <fs_v_eger_final> TO ls_device_data.
      SHIFT ls_device_data-geraet LEFT DELETING LEADING '0'.

      CALL FUNCTION 'ISU_DB_ETYP_SINGLE'
        EXPORTING
          x_matnr      = <fs_v_eger_final>-matnr
        IMPORTING
          y_etyp       = ls_etyp
        EXCEPTIONS
          not_found    = 1
          system_error = 2
          OTHERS       = 3.

      CLEAR lv_bdew_cci.

      SELECT SINGLE bdew_cci FROM /idexge/t_metca INTO lv_bdew_cci
        WHERE meter_cat = ls_etyp-/idexge/met_cat AND
              spartyp = ls_etyp-sparte.

      ls_device_data-metertype = lv_bdew_cci.
      ls_device_data-metertype_code = ls_etyp-/idexge/met_typ.
      ls_device_data-metertype_value = ls_etyp-/idexge/schara.
      ls_device_data-metersize_value = ls_etyp-/idexge/meter_size.
      ls_device_data-ratenumber_code = ls_etyp-/idexge/rate_num.
      ls_device_data-energy_direction = ls_etyp-/idexge/engy_dir.

      "---------------------------------------------------------------------------------------------------------------------------------
      "Erweiterung Vertriebsseite
      "Auf der Vertriebsseite sind die Eigenschaften der Gerätetypen nicht gepflegt, da universal Materialnummern verwendet werden. Aus
      "diesem Grund muss der Gerätetyp manuell immer auf E13 gesetzt werden. Es sind auch nur zählende Geräte in der Anlage eingebaut!
      "---------------------------------------------------------------------------------------------------------------------------------
      IF ls_device_data-metertype IS INITIAL.
        IF ls_etyp-kombinat = 'Z'.
          ls_device_data-metertype = /idxgc/if_constants_ide=>gc_cci_chardesc_code_e13.
          APPEND ls_device_data TO rt_device_data.
        ENDIF.
      ELSE.
        "---------------------------------------------------------------------------------------------------------------------------------
        "Erweiterung Dummy Geräteart
        "Es gibt eingebaute bzw. zugeordnete Geräte an einigen Anlagen die nicht zur Marktkommunikation geeignet sind. (Bsp: Druckregler).
        "Aus diesem Grund gibt es eine Dummy Geräteart, die an den entsprechenden Gerätetypen hinterlegt werden kann. Diese Geräte werden
        "hier ausgesteuert. Auf Vertriebsseite werden sowieso nur Zähler kommuniziert (s.u.).
        "---------------------------------------------------------------------------------------------------------------------------------
        IF ls_device_data-metertype <> zif_agc_masterdata_co=>ac_dummy_metertype.
          APPEND ls_device_data TO rt_device_data.
        ENDIF.
      ENDIF.
    ENDLOOP.

    "---------------------------------------------------------------------------------------------------------------------------------
    "Erweiterung für Mengenumwerter
    "Aktuell sind die zählenden Geräte nicht in den Anlagen eingebaut. Aus diesem Grund würde nur der Mengenumwerter gefunden werden.
    "Wir müssen die Daten des Mengenumwerters in ein zählendes Geräte kopieren, damit die Nachricht korrekt versendet wird.
    "---------------------------------------------------------------------------------------------------------------------------------
    UNASSIGN <fs_device_data>.
    CLEAR ls_device_data.
    READ TABLE rt_device_data ASSIGNING <fs_device_data> WITH KEY metertype = /idxgc/if_constants_ide=>gc_cci_chardesc_code_e13.
    IF <fs_device_data> IS NOT ASSIGNED.
      READ TABLE rt_device_data ASSIGNING <fs_device_data> WITH KEY metertype = /idxgc/if_constants_ide=>gc_cci_chardesc_code_z64.
      IF <fs_device_data> IS ASSIGNED.
        MOVE-CORRESPONDING <fs_device_data> TO ls_device_data.
        ls_device_data-metertype = /idxgc/if_constants_ide=>gc_device_type_code_e13.
        APPEND ls_device_data TO rt_device_data.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD GET_DIV_FROM_DIVCAT_AND_INSTLN.
    "*****************************************************************************************************************************
    "Hinweis: Anlage ist ebenfalls notwendig falls der Spartentyp 99 ist. Eindeutige Zuordnung zu einer Sparte nicht mehr möglich.
    "*****************************************************************************************************************************

    DATA: lt_tespt  TYPE TABLE OF tespt,
          ls_v_eanl TYPE          v_eanl.

    FIELD-SYMBOLS: <fs_tespt> LIKE LINE OF lt_tespt.

    TRY.
        SELECT * FROM tespt INTO TABLE lt_tespt WHERE spartyp = iv_divcat.

        IF lines( lt_tespt ) > 1.
          ls_v_eanl = zcl_agc_masterdata=>get_v_eanl( iv_anlage = iv_anlage ).
          rv_sparte = ls_v_eanl-sparte.
        ELSEIF lines( lt_tespt ) = 1.
          READ TABLE lt_tespt ASSIGNING <fs_tespt> INDEX 1.
          rv_sparte = <fs_tespt>-sparte.
        ELSE.
          zcx_agc_masterdata=>raise_exception_from_msg( ).
        ENDIF.

        IF rv_sparte IS INITIAL.
          zcx_agc_masterdata=>raise_exception_from_msg( ).
        ENDIF.

      CATCH zcx_agc_masterdata.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD get_endsettldate.
***************************************************************************************************
* THIMEL.R 20150511 M4892 Ermittlung Bilanzierungsende analog zum Bilanzierungsbeginn
***************************************************************************************************
    DATA: lt_services          TYPE /idxgc/t_proc_agent,
          lt_settlunit         TYPE t_eedmsettlunit,
          lt_uisettlunit       TYPE t_eedmuisettlunit,
          ls_ever              TYPE ever,
          lv_anlage            TYPE anlage,
          lv_int_ui            TYPE int_ui,
          lv_latest_settlstart TYPE dats,
          lv_agent_id          TYPE service_prov,
          lv_metmethod         TYPE eideswtmdmetmethod,
          lv_auszdat           TYPE dats.

    FIELD-SYMBOLS: <fs_service>     TYPE /idxgc/s_proc_agent,
                   <fs_settlunit>   TYPE eedmsettlunit,
                   <fs_uisettlunit> TYPE eedmuisettlunit.

***** Initialisierung / Prüfungen *****************************************************************
    IF is_ever IS INITIAL OR ( iv_int_ui IS INITIAL AND iv_keydate IS INITIAL ).
      MESSAGE i105(zagc_masterdata) INTO gv_msgtext.
      zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDIF.

    IF is_ever IS INITIAL.
      lv_int_ui = iv_int_ui.
      lv_anlage = get_anlage( iv_int_ui = lv_int_ui iv_keydate = iv_keydate ).
      ls_ever = get_ever( iv_anlage = lv_anlage iv_keydate = iv_keydate ).
      IF ls_ever-auszdat IS NOT INITIAL.
        lv_auszdat = ls_ever-auszdat.
      ELSE.
        lv_auszdat = '99991231'.
      ENDIF.
    ELSE.
      ls_ever = is_ever.
      IF ls_ever-auszdat IS NOT INITIAL.
        lv_auszdat = ls_ever-auszdat.
      ELSE.
        lv_auszdat = '99991231'.
      ENDIF.
      lv_anlage = ls_ever-anlage.
      lv_int_ui = get_int_ui( iv_anlage = lv_anlage iv_keydate = ls_ever-auszdat ).
    ENDIF.

    IF is_ever-vertrag         IS INITIAL OR
       is_ever-anlage          IS INITIAL OR  "Einzugsstorno
       is_ever-invoicing_party IS INITIAL.
      MESSAGE i105(zagc_masterdata) INTO gv_msgtext.
      zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDIF.

*---- Lieferant ermitteln -------------------------------------------------------------------------
    lt_services = get_services( iv_int_ui = lv_int_ui iv_keydate = lv_auszdat ).
    LOOP AT lt_services ASSIGNING <fs_service>
      WHERE service_end = lv_auszdat
        AND ( agent_type = zif_agc_masterdata_co=>gc_agent_type_slfr OR
              agent_type = zif_agc_masterdata_co=>gc_agent_type_glfr ).
      lv_agent_id = <fs_service>-agent_id.
      EXIT.
    ENDLOOP.
    IF lv_agent_id IS INITIAL.
      lv_agent_id = ls_ever-invoicing_party.
    ENDIF.

*---- Gültige Bilanzkreise zum Lieferant ermitteln ------------------------------------------------
    lt_settlunit = get_settlunit( iv_service_prov = lv_agent_id ).

*---- Zuordnung Bilanzkreise zum Zählpunkt ermitteln ----------------------------------------------
    lt_uisettlunit = get_uisettlunit( iv_int_ui = lv_int_ui ).

*---- Zählverfahren zur Anlage ermitteln ----------------------------------------------------------
    lv_metmethod = get_metmethod( iv_anlage = lv_anlage iv_keydate = lv_auszdat ).

***** Ermittlung Bilanzierungsbeginndatum *********************************************************
*---- Bei RLM ist der Bilanzierungsbeginn synchron zum Vertragsende -------------------------------
    IF lv_metmethod = /idxgc/if_constants_ide=>gc_cci_01_chardesc_code_e01.
      rt_settlenddate = lv_auszdat.
*---- Ermittlung für alle anderen Anlagen -----------------------------
    ELSE.
      DELETE lt_uisettlunit WHERE bis < lv_auszdat.
      SORT lt_uisettlunit BY ab ASCENDING.
      LOOP AT lt_uisettlunit ASSIGNING <fs_uisettlunit>.
        LOOP AT lt_settlunit ASSIGNING <fs_settlunit>
          WHERE settlunit = <fs_uisettlunit>-settlunit
            AND datefrom <= <fs_uisettlunit>-bis AND dateto >= <fs_uisettlunit>-bis.
          rt_settlenddate = <fs_uisettlunit>-bis.
          EXIT.
        ENDLOOP.
        IF rt_settlenddate IS NOT INITIAL.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD get_ever.
    SELECT SINGLE * FROM ever INTO rs_ever
      WHERE anlage = iv_anlage AND
            einzdat LE iv_keydate AND
            auszdat GE iv_keydate.
    IF sy-subrc <> 0.
      MESSAGE i002(zagc_masterdata) WITH 'EVER' iv_anlage iv_keydate INTO gv_msgtext.
      zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD get_ext_ui.
    DATA:
      ls_euitrans TYPE euitrans.

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
      MESSAGE i002(zagc_masterdata) WITH 'EUITRANS' iv_int_ui iv_keydate INTO gv_msgtext.
      zcx_agc_masterdata=>raise_exception_from_msg( ).
    ELSE.
      rv_ext_ui = ls_euitrans-ext_ui.
    ENDIF.
  ENDMETHOD.


  METHOD get_fallgruppe_gabi.
    DATA: ls_zedmzpkth TYPE          zedmzpkth,
          lt_zedmzpkth TYPE TABLE OF zedmzpkth.

    "1. Schritt Haushaltskennzeichen aus den EDM-Zeitscheiben ermitteln
    ls_zedmzpkth = zcl_edm_utility=>get_edm_data_single( iv_anlage = iv_anlage iv_keydate = iv_keydate ).

    IF ls_zedmzpkth IS INITIAL.
      lt_zedmzpkth = zcl_edm_utility=>get_edm_data( iv_anlage = iv_anlage ).
      SORT lt_zedmzpkth BY bis DESCENDING.
      READ TABLE lt_zedmzpkth INTO ls_zedmzpkth INDEX 1.
    ENDIF.

    rv_fallgruppe = ls_zedmzpkth-zzfallgruppe.

    IF rv_fallgruppe IS INITIAL.
      MESSAGE i002(zagc_masterdata) WITH 'ZEDMZPKTH' iv_anlage INTO gv_msgtext.
      zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD get_gas_quality.
    DATA: ls_v_eanl TYPE v_eanl,
          lv_edmmgebiet type zzedmmgebiet.

    IF iv_edmmgebiet IS INITIAL.
      ls_v_eanl = zcl_agc_masterdata=>get_v_eanl( iv_anlage = iv_anlage iv_keydate = iv_keydate ).
      lv_edmmgebiet = ls_v_eanl-zzedmmgebiet.
    ELSE.
      lv_edmmgebiet = iv_edmmgebiet.
    ENDIF.

    CASE lv_edmmgebiet.
      WHEN 'NCG HG EXT'.
        rv_gas_quality = zif_agc_masterdata_co=>ac_gas_quality_h_gas.
      WHEN 'NCG LG EXT'.
        rv_gas_quality = zif_agc_masterdata_co=>ac_gas_quality_l_gas.
      WHEN 'NCG LG SWS'.
        rv_gas_quality = zif_agc_masterdata_co=>ac_gas_quality_l_gas.
      WHEN 'GASPOOL'.
        rv_gas_quality = zif_agc_masterdata_co=>ac_gas_quality_h_gas.
      WHEN 'Extern'.
        rv_gas_quality = zif_agc_masterdata_co=>ac_gas_quality_h_gas.
      WHEN 'EGT L-Gas'.
        rv_gas_quality = zif_agc_masterdata_co=>ac_gas_quality_l_gas.
      WHEN 'EGT L-GasE'.
        rv_gas_quality = zif_agc_masterdata_co=>ac_gas_quality_l_gas.
      WHEN 'THY L-GasE'.
        rv_gas_quality = zif_agc_masterdata_co=>ac_gas_quality_l_gas.
      WHEN OTHERS.
        rv_gas_quality = zif_agc_masterdata_co=>ac_gas_quality_h_gas.
    ENDCASE.

  ENDMETHOD.


  METHOD get_instln_facts.

*    DATA: lr_instln TYPE REF TO cl_isu_installation.
*
*    CALL METHOD cl_isu_installation=>select
*      EXPORTING
*        installationid = iv_anlage
*      RECEIVING
*        installation   = lr_instln
*      EXCEPTIONS
*        invalid_object = 1
*        OTHERS         = 2.
*    IF sy-subrc <> 0.
*      MESSAGE i002(zagc_masterdata) WITH 'EANL' iv_anlage INTO gv_msgtext.
*      zcx_agc_masterdata=>raise_exception_from_msg( ).
*    ENDIF.
*
*    IF lr_instln IS BOUND.
*      CALL METHOD lr_instln->open
*        EXPORTING
*          x_keydate      = iv_keydate
*        EXCEPTIONS
*          locked         = 1
*          not_authorized = 2
*          not_selected   = 3
*          object_invalid = 4
*          system_error   = 5
*          OTHERS         = 6.
*      IF sy-subrc <> 0.
**        lr_instln->close( ).           "Wolf.A., 01.04.2015 - verursacht Short Dump
*        MESSAGE i002(zagc_masterdata) WITH 'EANL' iv_anlage INTO gv_msgtext.
*        zcx_agc_masterdata=>raise_exception_from_msg( ).
*      ENDIF.
*
*      CALL METHOD lr_instln->get_all_properties
*        EXPORTING
*          x_keydate        = iv_keydate
*        IMPORTING
*          y_facts          = rs_instln_facts
*        EXCEPTIONS
*          invalid_object   = 1
*          invalid_property = 2
*          keydate_invalid  = 3
*          not_selected     = 4
*          OTHERS           = 5.
*      IF sy-subrc <> 0.
*        lr_instln->close( ).
*        MESSAGE i002(zagc_masterdata) WITH 'ETTIFN' iv_anlage INTO gv_msgtext.
*        zcx_agc_masterdata=>raise_exception_from_msg( ).
*      ENDIF.
*
*      lr_instln->close( ).
*    ENDIF.

    DATA: lv_sparte TYPE eanl-sparte.

    lv_sparte = zcl_agc_masterdata=>get_sparte( iv_anlage = iv_anlage iv_keydate = iv_keydate ).

    CALL FUNCTION 'ISU_O_INST_FACTS_OPEN'
      EXPORTING
        x_anlage        = iv_anlage
        x_sparte        = lv_sparte
        x_wmode         = '1' "DISPLAY
        x_date          = iv_keydate
        x_no_change     = abap_true
        x_no_other      = abap_true
        x_no_dialog     = abap_true
        x_beganlage     = iv_keydate
        x_begabrpe      = iv_keydate
        x_begnach       = iv_keydate
        x_last_endabrpe = iv_keydate
        x_next_contract = space
      IMPORTING
        y_auto          = rs_instln_facts
      EXCEPTIONS
        system_error    = 1
        OTHERS          = 2.
    IF sy-subrc <> 0.
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
        MESSAGE i002(zagc_masterdata) WITH 'EUITRANS' iv_ext_ui iv_keydate INTO gv_msgtext.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
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
        MESSAGE i002(zagc_masterdata) WITH 'EUIINSTLN' iv_anlage iv_keydate INTO gv_msgtext.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
      ELSE.
        READ TABLE lt_euiinstln ASSIGNING <fs_euiinstln> INDEX 1.
        rv_int_ui = <fs_euiinstln>-int_ui.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD get_kz_hhk.

    DATA: ls_zedmzpkth    TYPE          zedmzpkth,
          lt_zedmzpkth    TYPE TABLE OF zedmzpkth,
          ls_v_eanl       TYPE          v_eanl,
          lv_profil       TYPE          zedmlastprofil,
          lv_profile      TYPE          eideswtmsgdata-profile,
          lv_flag_hh      TYPE          char1,
          lv_progyearcons TYPE          eideswtmdprogyearcons.

    "1. Schritt Haushaltskennzeichen aus den EDM-Zeitscheiben ermitteln
    IF is_zedmzpkth IS INITIAL. "THIMEL.R, 20160307, Neuer Übergabeparameter
      ls_zedmzpkth = zcl_edm_utility=>get_edm_data_single( iv_anlage = iv_anlage iv_keydate = iv_keydate ).
    ELSE.
      ls_zedmzpkth = is_zedmzpkth.
    ENDIF.

    IF ls_zedmzpkth IS INITIAL.
      lt_zedmzpkth = zcl_edm_utility=>get_edm_data( iv_anlage = iv_anlage ).
      SORT lt_zedmzpkth BY bis DESCENDING.
      READ TABLE lt_zedmzpkth INTO ls_zedmzpkth INDEX 1.
    ENDIF.

    IF ls_zedmzpkth-zedmhaushalt = abap_true.
      rv_hh_kunde = abap_true.
      RETURN.
    ELSE.
      rv_hh_kunde = abap_false.
    ENDIF.

    "2.Schritt Haushaltskennzeichen anhand des Jahresverbrauches prüfen
    TRY.
        ls_v_eanl = zcl_agc_masterdata=>get_v_eanl( iv_anlage = iv_anlage iv_keydate = iv_keydate ).
      CATCH zcx_agc_masterdata.
    ENDTRY.
    TRY.
        lv_profil = zcl_agc_masterdata=>get_profil( iv_anlage = iv_anlage iv_keydate = iv_keydate is_zedmzpkth = ls_zedmzpkth ).  "THIMEL.R, 20160307, Neuer Übergabeparameter
      CATCH zcx_agc_masterdata.
    ENDTRY.
    TRY.
        lv_progyearcons = zcl_agc_masterdata=>get_progyearcons( iv_anlage = iv_anlage iv_keydate = iv_keydate ).
      CATCH zcx_agc_masterdata.
    ENDTRY.


    "Formalparameter x_profile ist von einem anderen Feldtyp als lv_profil, daher überführen wir den Wert in ein passendes Feld
    WRITE lv_profil TO lv_profile.

    CALL FUNCTION 'Z_LW_EDM_HH_KUNDE'
      EXPORTING
        x_sparte       = ls_v_eanl-sparte
        x_zzenetz1     = ls_v_eanl-zzenetz1
        x_profile      = lv_profile
        x_progyearcons = lv_progyearcons
        x_bedart       = ls_v_eanl-zzebedart           " Wolf.A., 26.06.2015, Mantis 4824
      IMPORTING
        y_flag_hh      = lv_flag_hh
      EXCEPTIONS
        fehler_allg    = 1.

    CASE lv_flag_hh.
      WHEN 'J'.
        MOVE abap_true TO rv_hh_kunde.
      WHEN 'N'.
        MOVE abap_false TO rv_hh_kunde.
    ENDCASE.

  ENDMETHOD.


  METHOD get_loss_factor.

    DATA: ls_v_eanl          TYPE v_eanl,
          ls_ttyp_attributes TYPE zepdprodukttariftyp.

    ls_v_eanl = zcl_agc_masterdata=>get_v_eanl( iv_anlage = iv_anlage iv_keydate = iv_keydate ).

    ls_ttyp_attributes = zcl_agc_masterdata=>get_ttyp_attributes( iv_ttyp = ls_v_eanl-tariftyp ).

    rv_loss_factor = ls_ttyp_attributes-zepdverlustfaktor.

    IF rv_loss_factor IS INITIAL.
      MESSAGE i002(zagc_masterdata) WITH 'TARIFTYP' ls_v_eanl-tariftyp INTO gv_msgtext.
      zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDIF.

  ENDMETHOD.


  METHOD get_mabis_time_series.

    DATA: lv_profil TYPE eideswtmsgdata-profile.

    lv_profil = zcl_agc_masterdata=>get_profil( iv_anlage = iv_anlage iv_keydate = iv_keydate ).

    SELECT SINGLE * FROM zlwzeitreihentyp INTO rs_time_series WHERE zedmlastprofil = lv_profil.

    IF sy-subrc <> 0.
      rs_time_series-zz_zeitreihentyp = 'SLS'.
      rs_time_series-zz_katzeitreityp = 'Z21'.
    ENDIF.

  ENDMETHOD.


  METHOD get_market_area.
    DATA: ls_v_eanl    TYPE v_eanl,
          lv_edmmgebiet TYPE zzedmmgebiet.

    IF iv_edmmgebiet IS INITIAL.
      ls_v_eanl = zcl_agc_masterdata=>get_v_eanl( iv_anlage = iv_anlage iv_keydate = iv_keydate ).
      lv_edmmgebiet = ls_v_eanl-zzedmmgebiet.
    ELSE.
      lv_edmmgebiet = iv_edmmgebiet.
    ENDIF.

    CASE lv_edmmgebiet.
      WHEN 'NCG HG EXT'.
        rv_market_area = zif_agc_masterdata_co=>ac_mkt_ar_37y701125mh0000i.
      WHEN 'NCG LG EXT'.
        rv_market_area = zif_agc_masterdata_co=>ac_mkt_ar_37y701125mh0000i.
      WHEN 'NCG LG SWS'.
        rv_market_area = zif_agc_masterdata_co=>ac_mkt_ar_37y701125mh0000i.
      WHEN 'GASPOOL'.
        rv_market_area = zif_agc_masterdata_co=>ac_mkt_ar_37y701133mh0000p.
      WHEN 'Extern'.
        rv_market_area = zif_agc_masterdata_co=>ac_mkt_ar_37y701125mh0000i.
      WHEN 'EGT L-Gas'.
        rv_market_area = zif_agc_masterdata_co=>ac_mkt_ar_37y701125mh0000i.
      WHEN 'EGT L-GasE'.
        rv_market_area = zif_agc_masterdata_co=>ac_mkt_ar_37y701125mh0000i.
      WHEN 'THY L-GasE'.
        rv_market_area = zif_agc_masterdata_co=>ac_mkt_ar_37y701125mh0000i.
      WHEN OTHERS.
        rv_market_area = zif_agc_masterdata_co=>ac_mkt_ar_37y701125mh0000i. "THIMEL.R, 20151005, Mantis 5103
    ENDCASE.

  ENDMETHOD.


  METHOD get_maxdemand.

    DATA: lv_startabrjahr TYPE dats,
          lv_operand      TYPE e_operand,
          lt_ettifn       TYPE isu_iettifn.

    FIELD-SYMBOLS: <fs_ettifn> LIKE LINE OF lt_ettifn.

    lv_startabrjahr = sy-datum.

    IF zcl_agc_masterdata=>get_sparte( iv_anlage = iv_anlage iv_keydate = iv_keydate ) = zif_agc_datex_utilmd_co=>gc_sparte_strom.
      MOVE '0101' TO lv_startabrjahr+4(4).
      lv_operand = 'NZMAXMF'.
    ELSEIF zcl_agc_masterdata=>get_sparte( iv_anlage = iv_anlage iv_keydate = iv_keydate ) = zif_agc_datex_utilmd_co=>gc_sparte_gas.
      MOVE '1001' TO lv_startabrjahr+4(4).
      IF lv_startabrjahr GT sy-datum.
        SUBTRACT 1 FROM lv_startabrjahr(4).
      ENDIF.
      lv_operand = 'NZGLSTGMXF'.
    ENDIF.

    CALL FUNCTION 'ISU_INST_FACTS_READ'
      EXPORTING
        x_anlage      = iv_anlage
      CHANGING
        xy_iettifn    = lt_ettifn
      EXCEPTIONS
        general_fault = 1
        OTHERS        = 2.
    IF sy-subrc = 0.
      SORT lt_ettifn BY ab DESCENDING.
      READ TABLE lt_ettifn ASSIGNING <fs_ettifn> WITH KEY operand = lv_operand.
      IF <fs_ettifn> IS ASSIGNED.
        rv_maxdemand = <fs_ettifn>-wert1.
      ELSE.
        MOVE 1 TO rv_maxdemand.
      ENDIF.
    ELSE.
      MOVE 1 TO rv_maxdemand.
    ENDIF.

    IF rv_maxdemand IS INITIAL.
      MESSAGE i002(zagc_masterdata) WITH 'ETTIFN' lv_operand INTO gv_msgtext.
      zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDIF.

  ENDMETHOD.


  METHOD get_mdl.
    DATA: ls_zedmzpkth TYPE          zedmzpkth,
          lt_zedmzpkth TYPE TABLE OF zedmzpkth.

    "1. Schritt Haushaltskennzeichen aus den EDM-Zeitscheiben ermitteln
    ls_zedmzpkth = zcl_edm_utility=>get_edm_data_single( iv_anlage = iv_anlage iv_keydate = iv_keydate ).

    IF ls_zedmzpkth IS INITIAL.
      lt_zedmzpkth = zcl_edm_utility=>get_edm_data( iv_anlage = iv_anlage ).
      SORT lt_zedmzpkth BY bis DESCENDING.
      READ TABLE lt_zedmzpkth INTO ls_zedmzpkth INDEX 1.
    ENDIF.

    CALL FUNCTION 'ISU_DB_ESERVPROV_SINGLE'
      EXPORTING
        x_serviceid = ls_zedmzpkth-zedmservmdl
      IMPORTING
        y_eservprov = rs_mdl
      EXCEPTIONS
        not_found   = 1
        OTHERS      = 2.

    IF sy-subrc <> 0.
      IF zcl_agc_masterdata=>get_sparte( iv_anlage = iv_anlage iv_keydate = iv_keydate ) = zif_agc_datex_utilmd_co=>gc_sparte_strom.
        rs_mdl-externalid = zif_agc_masterdata_co=>ac_own_mdl_ext_id_ele.
        rs_mdl-serviceid = zif_agc_masterdata_co=>ac_own_mdl_serv_id_ele.
        rs_mdl-externalidtyp = zif_agc_masterdata_co=>gc_externalidtyp_bdew_1.
      ELSEIF zcl_agc_masterdata=>get_sparte( iv_anlage = iv_anlage iv_keydate = iv_keydate ) = zif_agc_datex_utilmd_co=>gc_sparte_gas.
        rs_mdl-externalid = zif_agc_masterdata_co=>ac_own_mdl_ext_id_gas.
        rs_mdl-serviceid = zif_agc_masterdata_co=>ac_own_mdl_serv_id_gas.
        rs_mdl-externalidtyp = zif_agc_masterdata_co=>gc_externalidtyp_dvgw_3.
      ENDIF.
    ENDIF.

    IF rs_mdl IS INITIAL.
      MESSAGE i002(zagc_masterdata) WITH 'ESERVPROV' ls_zedmzpkth-zedmservmdl INTO gv_msgtext.
      zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD get_metmethod.
    DATA: ls_eanl            TYPE          v_eanl,
          ls_ttyp_attributes TYPE          zepdprodukttariftyp,
          lt_zedmzpkth       TYPE TABLE OF zedmzpkth,
          ls_zedmzpkth       TYPE          zedmzpkth,
          lv_anlage          TYPE          anlage.

    TRY.
        IF iv_anlage IS INITIAL.
          lv_anlage = zcl_agc_masterdata=>get_anlage( iv_int_ui = iv_int_ui iv_keydate = iv_keydate ).
        ELSE.
          lv_anlage = iv_anlage.
        ENDIF.

        ls_eanl = get_v_eanl( iv_anlage = lv_anlage iv_keydate = iv_keydate ).
        ls_zedmzpkth = zcl_edm_utility=>get_edm_data_single( iv_anlage = lv_anlage iv_keydate = iv_keydate ).

        IF ls_zedmzpkth IS INITIAL. "Falls kein Eintrag passend zum Datum gefunden wird, soll die aktuellste Zeitscheibe genommen werden.
          lt_zedmzpkth = zcl_edm_utility=>get_edm_data( iv_anlage = lv_anlage ).
          SORT lt_zedmzpkth BY ab DESCENDING.
          READ TABLE lt_zedmzpkth INTO ls_zedmzpkth INDEX 1.
        ENDIF.

        "Pauschalanlage
        IF ls_eanl-anlart = gc_anlagenart_panl.
          rv_metmethod = /idxgc/cl_check_method_add=>/idxgc/if_check_method_add~gc_meter_proc_z29.
        ELSE.
          IF zcl_agc_masterdata=>is_netz( ) = abap_false.
            IF ls_eanl-zzekzwfstop IS NOT INITIAL.
              rv_metmethod = /idxgc/cl_check_method_add=>/idxgc/if_check_method_add~gc_meter_proc_e01.
            ELSE.
              IF ls_zedmzpkth-zedmlastprofil = gc_lastprofil_nsp.
                rv_metmethod = gc_metmethod_e14.
              ELSE.
                rv_metmethod = /idxgc/cl_check_method_add=>/idxgc/if_check_method_add~gc_meter_proc_e02.
              ENDIF.
            ENDIF.
          ELSEIF zcl_agc_masterdata=>is_netz( ) = abap_true.

            ls_ttyp_attributes = zcl_agc_masterdata=>get_ttyp_attributes( iv_ttyp = ls_eanl-tariftyp ).

            IF ls_ttyp_attributes-zepdkzrlm IS NOT INITIAL.
              rv_metmethod = /idxgc/cl_check_method_add=>/idxgc/if_check_method_add~gc_meter_proc_e01.
            ELSE.
              IF ls_zedmzpkth-zedmlastprofil = gc_lastprofil_nsp.
                rv_metmethod = gc_metmethod_e14.
              ELSE.
                rv_metmethod = /idxgc/cl_check_method_add=>/idxgc/if_check_method_add~gc_meter_proc_e02.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      CATCH zcx_agc_masterdata.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDTRY.

    IF rv_metmethod IS INITIAL.
      MESSAGE i000(zagc_masterdata) WITH 'Zählverfahren fehlt!' lv_anlage INTO gv_msgtext.
      zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDIF.

  ENDMETHOD.


  METHOD get_msb.

    DATA: ls_zedmzpkth TYPE          zedmzpkth,
          lt_zedmzpkth TYPE TABLE OF zedmzpkth.

    "1. Schritt Haushaltskennzeichen aus den EDM-Zeitscheiben ermitteln
    ls_zedmzpkth = zcl_edm_utility=>get_edm_data_single( iv_anlage = iv_anlage iv_keydate = iv_keydate ).

    IF ls_zedmzpkth IS INITIAL.
      lt_zedmzpkth = zcl_edm_utility=>get_edm_data( iv_anlage = iv_anlage ).
      SORT lt_zedmzpkth BY bis DESCENDING.
      READ TABLE lt_zedmzpkth INTO ls_zedmzpkth INDEX 1.
    ENDIF.

    CALL FUNCTION 'ISU_DB_ESERVPROV_SINGLE'
      EXPORTING
        x_serviceid = ls_zedmzpkth-zedmservmsb
      IMPORTING
        y_eservprov = rs_msb
      EXCEPTIONS
        not_found   = 1
        OTHERS      = 2.

    IF sy-subrc <> 0.
      IF zcl_agc_masterdata=>get_sparte( iv_anlage = iv_anlage iv_keydate = iv_keydate ) = zif_agc_datex_utilmd_co=>gc_sparte_strom.
        rs_msb-externalid = zif_agc_masterdata_co=>ac_own_msb_ext_id_ele.
        rs_msb-serviceid = zif_agc_masterdata_co=>ac_own_msb_serv_id_ele.
        rs_msb-externalidtyp = zif_agc_masterdata_co=>gc_externalidtyp_bdew_1.
      ELSEIF zcl_agc_masterdata=>get_sparte( iv_anlage = iv_anlage iv_keydate = iv_keydate ) = zif_agc_datex_utilmd_co=>gc_sparte_gas.
        rs_msb-externalid = zif_agc_masterdata_co=>ac_own_msb_ext_id_gas.
        rs_msb-serviceid = zif_agc_masterdata_co=>ac_own_msb_serv_id_gas.
        rs_msb-externalidtyp = zif_agc_masterdata_co=>gc_externalidtyp_dvgw_3.
      ENDIF.
    ENDIF.

    IF rs_msb IS INITIAL.
      MESSAGE i002(zagc_masterdata) WITH 'ESERVPROV' ls_zedmzpkth-zedmservmsb INTO gv_msgtext.
      zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDIF.

  ENDMETHOD.


  METHOD get_netzbetreiberwechsel.

    DATA:  lt_services    TYPE /idxgc/t_proc_agent,
           ls_services    TYPE /idxgc/s_proc_agent,
           lv_service_end TYPE service_end.

    TRY.
        CALL METHOD /idxgc/cl_utility_service_isu=>get_service_prov_from_sup_scen
          EXPORTING
            iv_int_ui        = iv_int_ui
            iv_proc_date     = iv_keydate
          CHANGING
            ct_process_agent = lt_services.
      CATCH /idxgc/cx_utility_error.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO gv_msgtext.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDTRY.

    READ TABLE lt_services INTO ls_services WITH KEY agent_type = 'SLIE'.
    IF sy-subrc NE 0.
      READ TABLE lt_services INTO ls_services WITH KEY agent_type = 'GLIE'.
      IF sy-subrc EQ 0.
        lv_service_end = ls_services-service_end.
      ENDIF.
    ELSE.
      lv_service_end = ls_services-service_end.
    ENDIF.


    READ TABLE lt_services INTO ls_services WITH KEY agent_type = 'SNFR'.
    IF sy-subrc NE 0.
      READ TABLE lt_services INTO ls_services WITH KEY agent_type = 'GNFR'.
      IF sy-subrc EQ 0.
        IF lv_service_end IS NOT INITIAL AND lv_service_end NE ls_services-service_end.
          rv_kennz_netzbetwechs = abap_true.
        ENDIF.
      ENDIF.
    ELSE.
      IF lv_service_end IS NOT INITIAL AND lv_service_end NE ls_services-service_end.
        rv_kennz_netzbetwechs = abap_true.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD get_own_msb_mdl.

    TRY.
        SELECT * FROM v_eservprov INTO TABLE rt_v_eservprov
        WHERE serviceid IN ( zif_agc_masterdata_co=>ac_own_mdl_serv_id_ele,
                             zif_agc_masterdata_co=>ac_own_mdl_serv_id_gas,
                             zif_agc_masterdata_co=>ac_own_msb_serv_id_ele,
                             zif_agc_masterdata_co=>ac_own_msb_serv_id_gas ).

        IF rt_v_eservprov IS INITIAL.
          MESSAGE i001(zagc_masterdata) WITH 'V_ESERVPROV' INTO gv_msgtext.
        ENDIF.
      CATCH zcx_agc_masterdata.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD get_partner.

    DATA: lt_partner TYPE TABLE OF bapiisupodpartner.

    FIELD-SYMBOLS: <fs_partner> TYPE bapiisupodpartner.

    CALL FUNCTION 'BAPI_ISUPOD_GETPARTNER'
      EXPORTING
        keydate         = iv_keydate
        pointofdelivery = iv_ext_ui
      TABLES
        partner         = lt_partner.

    IF lines( lt_partner ) = 1.
      READ TABLE lt_partner ASSIGNING <fs_partner> INDEX 1.
      rv_partner = <fs_partner>-partner.
    ELSEIF lines( lt_partner ) > 1.
      MESSAGE i104(zagc_masterdata) WITH iv_ext_ui iv_keydate INTO gv_msgtext.
      zcx_agc_masterdata=>raise_exception_from_msg( ).
    ELSE.
      MESSAGE i103(zagc_masterdata) WITH iv_ext_ui iv_keydate INTO gv_msgtext.
      zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDIF.

  ENDMETHOD.


  METHOD get_period_length.
    SELECT SINGLE periodew FROM te420 INTO rv_period_length
      WHERE termschl EQ iv_portion.

    IF sy-subrc <> 0 OR rv_period_length IS INITIAL.
      MESSAGE i001(agc_masterdata) WITH 'TE420' iv_portion INTO gv_msgtext.
      zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD get_perverbr.
    DATA: lt_easts      TYPE TABLE OF easts,
          lt_easte      TYPE TABLE OF easte,
          ls_etdz       TYPE          etdz,
          lt_obis_zwart TYPE TABLE OF zlw_obis_zwart,
          ls_v_eanl     TYPE          v_eanl,
          lv_thgver     TYPE          thgver,
          lv_gasabart   TYPE          gasabart,
          lv_rolle      TYPE          zzobjekt.

    FIELD-SYMBOLS: <fs_easts> TYPE easts,
                   <fs_easte> TYPE easte.

    SELECT * FROM zlw_obis_zwart INTO TABLE lt_obis_zwart. "Z-Tabelle mit relevanten Zählwerken

    CALL FUNCTION 'ISU_DB_EASTS_SELECT'
      EXPORTING
        x_anlage      = iv_anlage
        x_ab          = iv_keydate
        x_bis         = iv_keydate
      TABLES
        t_easts       = lt_easts
      EXCEPTIONS
        not_found     = 1
        system_error  = 2
        not_qualified = 3
        OTHERS        = 4.
    IF sy-subrc <> 0.
      MESSAGE i002(zagc_masterdata) WITH 'EASTS' iv_anlage INTO gv_msgtext.
      zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDIF.

    LOOP AT lt_easts ASSIGNING <fs_easts>.
      CALL FUNCTION 'ISU_DB_ETDZ_SELECT'
        EXPORTING
          x_logikzw     = <fs_easts>-logikzw
          x_ab          = iv_keydate
          x_bis         = iv_keydate
        IMPORTING
          y_etdz        = ls_etdz
        EXCEPTIONS
          not_found     = 1
          system_error  = 2
          not_qualified = 3
          OTHERS        = 4.
      IF sy-subrc <> 0.
        MESSAGE i002(zagc_masterdata) WITH 'EATDZ' iv_anlage INTO gv_msgtext.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
      ENDIF.

      READ TABLE lt_obis_zwart TRANSPORTING NO FIELDS WITH KEY kennziff = ls_etdz-kennziff.

      IF sy-subrc = 0.
        SELECT * FROM easte INTO TABLE lt_easte WHERE logikzw EQ <fs_easts>-logikzw ORDER BY ab DESCENDING.
        IF sy-subrc = 0.
          LOOP AT lt_easte ASSIGNING <fs_easte> WHERE ab <= iv_keydate AND bis >= iv_keydate.
            ADD <fs_easte>-perverbr TO rv_perverbr.
            EXIT.
          ENDLOOP.
          IF <fs_easte> IS NOT ASSIGNED.
            READ TABLE lt_easte ASSIGNING <fs_easte> INDEX 1.
            ADD <fs_easte>-perverbr TO rv_perverbr.
          ENDIF.
        ENDIF.
        UNASSIGN <fs_easte>.
      ENDIF.
    ENDLOOP.

    ls_v_eanl = zcl_agc_masterdata=>get_v_eanl( iv_anlage = iv_anlage iv_keydate = iv_keydate ).

**>>> Maxim Schmidt, 12.10.2015, 0005070: TEST # Prognosewert #1# wird bei Neuanlagen nicht übertragen > Test
*    CALL FUNCTION 'Z_E_ISUMODELL'
*      IMPORTING
*        e_rolle = lv_rolle.
*
*    IF  ls_v_eanl-sparte = '02' AND lv_rolle EQ 'V'.
**       IF  ls_v_eanl-sparte = '02'.
**<<< Maxim Schmidt, 12.10.2015, 0005070: TEST # Prognosewert #1# wird bei Neuanlagen nicht übertragen > Test
    IF  ls_v_eanl-sparte = '02'.
      CLEAR: lv_thgver, lv_gasabart.
      CALL FUNCTION 'Z_ISU_THGVER_SELECT'
        EXPORTING
          x_anlage   = iv_anlage
          x_stichtag = iv_keydate
        IMPORTING
          y_thgver   = lv_thgver
          y_gasabart = lv_gasabart
        EXCEPTIONS
          not_found  = 1
          OTHERS     = 2.
      IF sy-subrc = 0 AND lv_gasabart = '03'.
        IF rv_perverbr > 1.
          rv_perverbr = rv_perverbr * 10.
        ENDIF.
      ENDIF.
**>>> Maxim Schmidt, 12.10.2015, 0005070: TEST # Prognosewert #1# wird bei Neuanlagen nicht übertragen > Test
*    ELSEIF ls_v_eanl-sparte = '02' AND lv_rolle EQ 'N'.
*      rv_perverbr = rv_perverbr * 10.
**<<< Maxim Schmidt, 12.10.2015, 0005070: TEST # Prognosewert #1# wird bei Neuanlagen nicht übertragen > Test
    ENDIF.

  ENDMETHOD.


  METHOD get_portion.
    SELECT SINGLE portion FROM te422 INTO rv_portion WHERE termschl = iv_ableinh.

    IF sy-subrc <> 0 OR rv_portion IS INITIAL.
      MESSAGE i001(zagc_masterdata) WITH 'TE422' iv_ableinh INTO gv_msgtext.
      zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD get_profil.
    DATA: ls_zedmzpkth TYPE zedmzpkth,
          ls_zedm004   TYPE zedm004,
          ls_zedm005   TYPE zedm005,
          ls_v_eanl    TYPE v_eanl.

    ls_v_eanl = zcl_agc_masterdata=>get_v_eanl( iv_anlage = iv_anlage iv_keydate = iv_keydate ).

    IF is_zedmzpkth IS INITIAL. "THIMEL.R, 20160307, Neuer Übergabeparameter
      SELECT SINGLE * FROM zedmzpkth INTO ls_zedmzpkth
        WHERE anlage =  iv_anlage AND
              bis    >= iv_keydate AND
              ab     <= iv_keydate.
      IF sy-subrc NE 0.
* Keine Aktuelle Zeitscheibe, wir nehmen die nächste
        SELECT * FROM zedmzpkth INTO ls_zedmzpkth
          WHERE anlage = iv_anlage
          ORDER BY bis DESCENDING.
          EXIT.
        ENDSELECT.
      ENDIF.
    ELSE.
      ls_zedmzpkth = is_zedmzpkth.
    ENDIF.

* Lastprofil gefunden -> Prüfen auf Gültigkeit
    IF ls_zedmzpkth-zedmlastprofil IS NOT INITIAL.
      SELECT SINGLE * FROM zedm004 INTO ls_zedm004
         WHERE sparte             = ls_v_eanl-sparte AND
               zedmkzvertrsicht   = '1' AND
               zedmlastprofil     = ls_zedmzpkth-zedmlastprofil.
      IF ls_zedm004-zedmkzhist IS NOT INITIAL.
        CLEAR ls_zedmzpkth-zedmlastprofil.
      ENDIF.
    ENDIF.
* Lastprofil gefunden -> Prüfen auf Branchenzuordnung
    IF ls_zedmzpkth-zedmlastprofil IS NOT INITIAL.
      SELECT SINGLE * FROM zedm005 INTO ls_zedm005
         WHERE sparte             = ls_v_eanl-sparte AND
               zedmkzvertrsicht   = '1' AND
               branche            = ls_v_eanl-branche AND
               zedmlastprofil     = ls_zedmzpkth-zedmlastprofil.
      IF sy-subrc <> 0.
        CLEAR ls_zedmzpkth-zedmlastprofil.
      ENDIF.
    ENDIF.
* Ist das ermittelte Lastprofil nicht mehr gültig -> Neuermittlung aus ZEDM005
    IF ls_zedmzpkth-zedmlastprofil IS INITIAL.
      SELECT SINGLE zedmlastprofil FROM zedm005 INTO ls_zedmzpkth-zedmlastprofil
        WHERE sparte             = ls_v_eanl-sparte  AND
              zedmkzvertrsicht   = '1'               AND
              branche            = ls_v_eanl-branche AND
              kz_default         = 'X'.
    ENDIF.

    rv_profil = ls_zedmzpkth-zedmlastprofil.

    IF rv_profil IS INITIAL.
      MESSAGE i001(zagc_masterdata) WITH 'ZEDMZPKTH' iv_anlage INTO gv_msgtext.
      zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD get_progyearcons.

    DATA: ls_zedmzpkth TYPE          zedmzpkth,
          lt_zedmzpkth TYPE TABLE OF zedmzpkth.

    "1. Schritt Haushaltskennzeichen aus den EDM-Zeitscheiben ermitteln
    ls_zedmzpkth = zcl_edm_utility=>get_edm_data_single( iv_anlage = iv_anlage iv_keydate = iv_keydate ).

    IF ls_zedmzpkth IS INITIAL.
      lt_zedmzpkth = zcl_edm_utility=>get_edm_data( iv_anlage = iv_anlage ).
      SORT lt_zedmzpkth BY bis DESCENDING.
      READ TABLE lt_zedmzpkth INTO ls_zedmzpkth INDEX 1.
    ENDIF.

    rv_progyearcons = ls_zedmzpkth-zedmprognosewert.

  ENDMETHOD.


  METHOD get_quantity_transformer.
    DATA:         lt_ewik    TYPE TABLE OF ewik,
                  lv_wgruppe TYPE          wgruppe,
                  lv_wspannp TYPE          ewik-wspann VALUE 1,
                  lv_wspanns TYPE          ewik-wspann VALUE 1,
                  lv_wstromp TYPE          ewik-wstrom VALUE 1,
                  lv_wstroms TYPE          ewik-wstrom VALUE 1.

    FIELD-SYMBOLS: <fs_ewik> LIKE LINE OF lt_ewik.

    "1. Schritt Wicklungsgruppe bestimmen
    SELECT SINGLE wgruppe FROM etyp INTO lv_wgruppe WHERE matnr = iv_matnr.

    CALL FUNCTION 'ISU_DB_EWIK_SELECT_ALL'
      EXPORTING
        x_wgruppe     = lv_wgruppe
      TABLES
        t_ewik        = lt_ewik
      EXCEPTIONS
        not_found     = 1
        system_error  = 2
        not_qualified = 3
        OTHERS        = 4.
    IF sy-subrc <> 0.
    ENDIF.

    LOOP AT lt_ewik ASSIGNING <fs_ewik>.
      IF <fs_ewik>-wtyp = '1'. "Primärwicklung
        IF <fs_ewik>-wstrom IS NOT INITIAL.
          lv_wstromp = <fs_ewik>-wstrom.
        ENDIF.
        IF <fs_ewik>-wspann IS NOT INITIAL.
          lv_wspannp = <fs_ewik>-wspann.
        ENDIF.
      ELSEIF <fs_ewik>-wtyp = '2'. "Sekundärwicklung
        IF <fs_ewik>-wstrom IS NOT INITIAL.
          lv_wstroms = <fs_ewik>-wstrom.
        ENDIF.
        IF <fs_ewik>-wspann IS NOT INITIAL.
          lv_wspanns = <fs_ewik>-wspann.
        ENDIF.
      ENDIF.
    ENDLOOP.

    "2. Schritt Wandlerfaktor berechnen
    rv_quantity = ( lv_wstromp * lv_wspannp ) / ( lv_wstroms * lv_wspanns ).
    SHIFT rv_quantity LEFT DELETING LEADING space.

  ENDMETHOD.


  METHOD get_regio_structure.
    DATA: ls_v_eanl TYPE v_eanl.

    TRY.
        ls_v_eanl = zcl_agc_masterdata=>get_v_eanl( iv_anlage = iv_anlage iv_keydate = iv_keydate ).
      CATCH zcx_agc_masterdata.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDTRY.

    CALL FUNCTION 'ISU_ADDRESS_PROVIDE'
      EXPORTING
        x_address_type             = 'P'
        x_read_adrc_regio          = abap_true
        x_read_isu_data            = abap_true
        x_read_mru                 = abap_true
        x_read_konz                = abap_true
        x_read_bukrs               = abap_true
        x_read_grid                = abap_true
        x_read_cust_regio          = abap_true
        x_vstelle                  = ls_v_eanl-vstelle
        x_anlage                   = ls_v_eanl-anlage
        x_bukrs                    = '1101'
        x_sparte                   = ls_v_eanl-sparte
        x_aklasse                  = ls_v_eanl-aklasse
      IMPORTING
        y_addr_data                = rs_regio_structure
      EXCEPTIONS
        not_found                  = 1
        parameter_error            = 2
        object_not_given           = 3
        address_inconsistency      = 4
        installation_inconsistency = 5
        OTHERS                     = 6.

    IF sy-subrc <> 0.
      zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDIF.

  ENDMETHOD.


  METHOD get_register_data.

    DATA:
      lt_etdz          TYPE isu07_ietdz,
      ls_etdz          TYPE etdz,
      ls_register_data TYPE /idxgc/s_register_data.

    CALL FUNCTION 'ISU_DB_ETDZ_SELECT'
      EXPORTING
        x_equnr       = is_v_eger-equnr
        x_ab          = is_v_eger-ab
        x_bis         = is_v_eger-bis
      TABLES
        t_etdz        = lt_etdz
      EXCEPTIONS
        not_found     = 1
        system_error  = 2
        not_qualified = 3
        OTHERS        = 4.

    IF sy-subrc = 0 AND lt_etdz IS NOT INITIAL.

      LOOP AT lt_etdz INTO ls_etdz.

        ls_register_data-equnr = ls_etdz-equnr.
        ls_register_data-meternumber = is_v_eger-geraet.
        ls_register_data-register = ls_etdz-zwnummer.
        ls_register_data-bis = ls_etdz-bis.
        ls_register_data-ab = ls_etdz-ab.
        ls_register_data-logikzw = ls_etdz-logikzw.
        ls_register_data-kennziff = ls_etdz-kennziff.
        ls_register_data-stanzvor = ls_etdz-stanzvor.
        ls_register_data-stanznac = ls_etdz-stanznac.
        ls_register_data-zwtyp = ls_etdz-zwtyp.
        APPEND ls_register_data TO rt_register_data.
      ENDLOOP.

    ENDIF.


  ENDMETHOD.


  METHOD get_services.

    TRY.
        CALL METHOD /idxgc/cl_utility_service_isu=>get_service_prov_from_sup_scen
          EXPORTING
            iv_int_ui        = iv_int_ui
            iv_proc_date     = iv_keydate
          CHANGING
            ct_process_agent = rt_services.
      CATCH /idxgc/cx_utility_error.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO gv_msgtext.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDTRY.

  ENDMETHOD.


  METHOD get_servicetype.
    SELECT SINGLE * FROM tecde INTO rs_tecde
      WHERE service = iv_sercode.

    IF rs_tecde IS INITIAL.
      MESSAGE i001(zagc_masterdata) WITH 'TECDE' iv_sercode INTO gv_msgtext.
      zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD get_servprov.
    SELECT SINGLE * FROM eservprov INTO rs_servprov
      WHERE serviceid = iv_serviceid.

    IF rs_servprov IS INITIAL.
      MESSAGE i001(zagc_masterdata) WITH 'ESERVPROV' iv_serviceid INTO gv_msgtext.
      zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD get_settlement_territory.

    DATA: lr_isu_pod   TYPE REF TO   zcl_agc_isu_pod,
          lt_zedmzpkth TYPE TABLE OF zedmzpkth,
          ls_zedmzpkth TYPE          zedmzpkth,
          lv_ext_ui    TYPE          ext_ui.

    lr_isu_pod = ir_isu_pod.

    IF lr_isu_pod IS NOT BOUND.
      TRY.
          CREATE OBJECT lr_isu_pod
            EXPORTING
              iv_int_ui           = iv_int_ui
              iv_keydate          = iv_keydate
              iv_process_all_data = abap_false.
        CATCH zcx_agc_masterdata.
          zcx_agc_masterdata=>raise_exception_from_msg( ).
      ENDTRY.
    ENDIF.

    IF lr_isu_pod->get_sparte( ) = zif_agc_datex_utilmd_co=>gc_sparte_strom.
      IF zcl_agc_masterdata=>is_netz( ) = abap_true.     "Netz
        rv_settlterr_ext = '11YR000000014017'.
      ELSE.                                              "Vertrieb
        CALL FUNCTION 'Z_E_ZEDMZPKTH_SELECT_ZP'
          EXPORTING
            x_ext_ui       = lr_isu_pod->get_ext_ui( )
            x_kz_akt       = abap_true
          TABLES
            t_zedmzpkth    = lt_zedmzpkth
          EXCEPTIONS
            fehler_zp      = 1
            fehler_anlage  = 2
            fehler_vertrag = 3
            OTHERS         = 4.
        IF sy-subrc <> 0.
          zcx_agc_masterdata=>raise_exception_from_msg( ).
        ENDIF.
        READ TABLE lt_zedmzpkth INTO ls_zedmzpkth INDEX 1.
        rv_settlterr_ext = ls_zedmzpkth-zedmbilanzgeb.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD get_settlunit.
    SELECT * FROM eedmsettlunit INTO TABLE rt_settlunit
      WHERE settlsupplier = iv_service_prov.
  ENDMETHOD.


  METHOD get_sparte.
    DATA: ls_servprov TYPE eservprov,
          ls_tecde    TYPE tecde,
          ls_v_eanl   TYPE v_eanl.

    IF iv_int_ui IS NOT INITIAL.
      ls_v_eanl = get_v_eanl( iv_anlage = get_anlage( iv_int_ui = iv_int_ui iv_keydate = iv_keydate ) iv_keydate = iv_keydate ).
      IF ls_v_eanl-sparte IS INITIAL.
        MESSAGE i101(zagc_masterdata) WITH iv_int_ui INTO gv_msgtext.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
      ELSE.
        rv_sparte = ls_v_eanl-sparte.
      ENDIF.
    ELSEIF iv_ext_ui IS NOT INITIAL.
      ls_v_eanl = get_v_eanl( iv_anlage = get_anlage( iv_ext_ui = iv_ext_ui iv_keydate = iv_keydate ) iv_keydate = iv_keydate ).
      IF ls_v_eanl-sparte IS INITIAL.
        MESSAGE i101(zagc_masterdata) WITH iv_int_ui INTO gv_msgtext.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
      ELSE.
        rv_sparte = ls_v_eanl-sparte.
      ENDIF.
    ELSEIF iv_serviceid IS NOT INITIAL.
      ls_servprov = get_servprov( iv_serviceid = iv_serviceid ).
      ls_tecde = get_servicetype( iv_sercode = ls_servprov-service ).
      IF ls_tecde-division IS INITIAL.
        MESSAGE i100(zagc_masterdata) WITH iv_serviceid INTO gv_msgtext.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
      ELSE.
        rv_sparte = ls_tecde-division.
      ENDIF.
    ELSEIF iv_anlage IS NOT INITIAL.
      ls_v_eanl = get_v_eanl( iv_anlage = iv_anlage iv_keydate = iv_keydate ).
      rv_sparte = ls_v_eanl-sparte.
      IF rv_sparte IS INITIAL.
        MESSAGE i102(zagc_masterdata) WITH iv_anlage INTO gv_msgtext.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD get_spebene_lieferstelle.
    DATA: ls_v_eanl TYPE v_eanl.

    ls_v_eanl = zcl_agc_masterdata=>get_v_eanl( iv_anlage = iv_anlage iv_keydate = iv_keydate ).

    rv_spebene_lst = ls_v_eanl-spebene.

    IF rv_spebene_lst IS INITIAL.
      MESSAGE i002(zagc_masterdata) WITH 'V_EANL' iv_anlage INTO gv_msgtext.
      zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD get_spebene_messung.

    DATA: ls_v_eanl TYPE v_eanl.

    ls_v_eanl = zcl_agc_masterdata=>get_v_eanl( iv_anlage = iv_anlage iv_keydate = iv_keydate ).

    rv_spebene_mes = ls_v_eanl-spebene.

    IF rv_spebene_mes IS INITIAL.
      MESSAGE i002(zagc_masterdata) WITH 'V_EANL' iv_anlage INTO gv_msgtext.
      zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDIF.

  ENDMETHOD.


  METHOD get_startsettldate.
***************************************************************************************************
* THIMEL.R 20150415 Ermittlung des Bilanzierungsbeginndatums, Logik aus FuBa Z_LW_EDM_BK_SELECT_NB
*   übernommen und erweitert um Anforderung aus Mantis 4613
***************************************************************************************************
    DATA: lt_services          TYPE /idxgc/t_proc_agent,
          lt_settlunit         TYPE t_eedmsettlunit,
          lt_uisettlunit       TYPE t_eedmuisettlunit,
          ls_ever              TYPE ever,
          lv_anlage            TYPE anlage,
          lv_int_ui            TYPE int_ui,
          lv_latest_settlstart TYPE dats,
          lv_agent_id          TYPE service_prov,
          lv_metmethod         TYPE eideswtmdmetmethod,
          ls_services          TYPE /idxgc/s_proc_agent,
          lv_service_end       TYPE service_end,
          lv_netzbetrwechs     TYPE kennzx.

    FIELD-SYMBOLS: <fs_service>     TYPE /idxgc/s_proc_agent,
                   <fs_settlunit>   TYPE eedmsettlunit,
                   <fs_uisettlunit> TYPE eedmuisettlunit.

***** Initialisierung / Prüfungen *****************************************************************
    IF is_ever IS INITIAL OR ( iv_int_ui IS INITIAL AND iv_keydate IS INITIAL ).
      MESSAGE i105(zagc_masterdata) INTO gv_msgtext.
      zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDIF.

    IF is_ever IS INITIAL.
      lv_int_ui = iv_int_ui.
      lv_anlage = get_anlage( iv_int_ui = lv_int_ui iv_keydate = iv_keydate ).
      ls_ever = get_ever( iv_anlage = lv_anlage iv_keydate = iv_keydate ).
    ELSE.
      ls_ever = is_ever.
      lv_anlage = ls_ever-anlage.
      lv_int_ui = get_int_ui( iv_anlage = lv_anlage iv_keydate = ls_ever-einzdat ).
    ENDIF.

    IF is_ever-vertrag         IS INITIAL OR
       is_ever-anlage          IS INITIAL OR  "Einzugsstorno
       is_ever-invoicing_party IS INITIAL.
      MESSAGE i105(zagc_masterdata) INTO gv_msgtext.
      zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDIF.

*---- Lieferant ermitteln -------------------------------------------------------------------------
*>>> Maxim Schmidt, 24.11.2015, Mantis 5216: BL-Erstellung: Abbruch mit Dump 'UNCAUGHT_EXCEPTION' "GET_BILANZIERUNGSBEGINN"
* Exception abfangen
    TRY.
        lt_services = get_services( iv_int_ui = lv_int_ui iv_keydate = ls_ever-einzdat ).
      CATCH zcx_agc_masterdata.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO gv_msgtext.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDTRY.
*<<< Maxim Schmidt, 24.11.2015, Mantis 5216: BL-Erstellung: Abbruch mit Dump 'UNCAUGHT_EXCEPTION' "GET_BILANZIERUNGSBEGINN"

    LOOP AT lt_services ASSIGNING <fs_service>
      WHERE service_start = ls_ever-einzdat "AND service_end = ls_ever-auszdat Fehler bei abgegrenzten Zeitscheiben
        AND ( agent_type = zif_agc_masterdata_co=>gc_agent_type_slfr OR
              agent_type = zif_agc_masterdata_co=>gc_agent_type_glfr ).
      lv_agent_id = <fs_service>-agent_id.
      EXIT.
    ENDLOOP.
    IF lv_agent_id IS INITIAL.
      lv_agent_id = ls_ever-invoicing_party.
    ENDIF.

*---- Gültige Bilanzkreise zum Lieferant ermitteln ------------------------------------------------
    lt_settlunit = get_settlunit( iv_service_prov = lv_agent_id ).

*---- Zuordnung Bilanzkreise zum Zählpunkt ermitteln ----------------------------------------------
    lt_uisettlunit = get_uisettlunit( iv_int_ui = lv_int_ui ).

*---- Zählverfahren zur Anlage ermitteln ----------------------------------------------------------
    lv_metmethod = get_metmethod( iv_anlage = lv_anlage iv_keydate = ls_ever-einzdat ).

***** Ermittlung Bilanzierungsbeginndatum *********************************************************
*---- Bei RLM ist der Bilanzierungsbeginn synchron zum Vertragsbeginn -----------------------------
    IF lv_metmethod = /idxgc/if_constants_ide=>gc_cci_01_chardesc_code_e01.
*>>> Maxim Schmidt, 26.10.2015, Mantis 5153: BL extern: Soll/Ist-Abgleich bringt ungerechtfertigt Differenzen zu Bilanzierungsbeginn
* Wenn Neztbetreiberwechsel stattgefunden hat, soll das Bilanzierungsbeginndatum genommen werden
      IF ls_ever IS NOT INITIAL.
        TRY.
            lv_netzbetrwechs = zcl_agc_masterdata=>get_netzbetreiberwechsel( iv_int_ui = lv_int_ui  iv_keydate = ls_ever-einzdat ).
          CATCH zcx_agc_masterdata.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO gv_msgtext.
            zcx_agc_masterdata=>raise_exception_from_msg( ).
        ENDTRY.
      ENDIF.

      IF lv_netzbetrwechs EQ abap_true.
        SORT lt_uisettlunit BY ab ASCENDING.
        LOOP AT lt_uisettlunit ASSIGNING <fs_uisettlunit>.
          rt_settlstartdate = <fs_uisettlunit>-ab.
        ENDLOOP.
      ELSE.
*<<< Maxim Schmidt, 26.10.2015, Mantis 5153: BL extern: Soll/Ist-Abgleich bringt ungerechtfertigt Differenzen zu Bilanzierungsbeginn
        rt_settlstartdate = ls_ever-einzdat.
      ENDIF. " Maxim Schmidt, 26.10.2015, Mantis 5153: BL extern: Soll/Ist-Abgleich bringt ungerechtfertigt Differenzen zu Bilanzierungsbeginn
*      LOOP AT lt_uisettlunit ASSIGNING <fs_uisettlunit>
*        WHERE ab = ls_ever-einzdat AND ( settlview = '001' OR settlview = '002' ).
*        LOOP AT lt_settlunit ASSIGNING <fs_settlunit>
*          WHERE settlunit = <fs_uisettlunit>-settlunit
*            AND datefrom <= ls_ever-einzdat AND dateto >= ls_ever-einzdat.
*          rt_settlstartdate = <fs_uisettlunit>-ab.
*        ENDLOOP.
*      ENDLOOP.
*---- Ermittlung für alle anderen Anlagen -----------------------------
    ELSE.
*>>> Maxim Schmidt, 26.10.2015, Mantis 5153: BL extern: Soll/Ist-Abgleich bringt ungerechtfertigt Differenzen zu Bilanzierungsbeginn
* Wenn Neztbetreiberwechsel stattgefunden hat, soll das Bilanzierungsbeginndatum genommen werden
      IF ls_ever IS NOT INITIAL.
        TRY.
            lv_netzbetrwechs = zcl_agc_masterdata=>get_netzbetreiberwechsel( iv_int_ui = lv_int_ui  iv_keydate = ls_ever-einzdat ).
          CATCH zcx_agc_masterdata.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO gv_msgtext.
            zcx_agc_masterdata=>raise_exception_from_msg( ).
        ENDTRY.
      ENDIF.

      IF lv_netzbetrwechs EQ abap_true.
        SORT lt_uisettlunit BY ab ASCENDING.
        LOOP AT lt_uisettlunit ASSIGNING <fs_uisettlunit>.
          rt_settlstartdate = <fs_uisettlunit>-ab.
        ENDLOOP.
      ELSE.
*<<< Maxim Schmidt, 26.10.2015, Mantis 5153: BL extern: Soll/Ist-Abgleich bringt ungerechtfertigt Differenzen zu Bilanzierungsbeginn

*      lv_latest_settlstart = ls_ever-einzdat + 180. Unklar wie weit in die Zukunft Bilanzierung beginnen kann.
        DELETE lt_uisettlunit WHERE ab < ls_ever-einzdat." OR ab > lv_latest_settlstart.
        SORT lt_uisettlunit BY ab ASCENDING.
        LOOP AT lt_uisettlunit ASSIGNING <fs_uisettlunit>.
          LOOP AT lt_settlunit ASSIGNING <fs_settlunit>
            WHERE settlunit = <fs_uisettlunit>-settlunit
              AND datefrom <= <fs_uisettlunit>-ab AND dateto >= <fs_uisettlunit>-ab.
            rt_settlstartdate = <fs_uisettlunit>-ab.
            EXIT.
          ENDLOOP.
          IF rt_settlstartdate IS NOT INITIAL.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF. " Maxim Schmidt, 26.10.2015, Mantis 5153: BL extern: Soll/Ist-Abgleich bringt ungerechtfertigt Differenzen zu Bilanzierungsbeginn
  ENDMETHOD.


  METHOD get_ttyp_attributes.

    DATA: ls_v_eanl TYPE v_eanl,
          lv_ttyp   TYPE tariftyp.

    IF iv_ttyp IS NOT INITIAL.
      lv_ttyp = iv_ttyp.
    ELSEIF iv_anlage IS NOT INITIAL AND iv_ttyp IS INITIAL.
      ls_v_eanl = zcl_agc_masterdata=>get_v_eanl( iv_anlage = iv_anlage iv_keydate = iv_keydate ).
      lv_ttyp = ls_v_eanl-tariftyp.
    ENDIF.

    CALL FUNCTION 'Z_ZEBI_TARIFTYPMERKMALE'
      EXPORTING
        iv_tariftyp          = lv_ttyp
      IMPORTING
        es_merkmale_tariftyp = rs_ttyp_attributes
      EXCEPTIONS
        OTHERS               = 3.
    IF sy-subrc = 0.
      "Keine Ausnahme werfen, da es unter umständen auch gewollt ist nichts zu ermitteln
    ENDIF.

  ENDMETHOD.


  METHOD get_uisettlunit.
    SELECT * FROM eedmuisettlunit INTO TABLE rt_uisettlunit
      WHERE int_ui = iv_int_ui.
  ENDMETHOD.


  METHOD GET_V_EANL.
    SELECT SINGLE * FROM v_eanl INTO rv_eanl
      WHERE anlage = iv_anlage AND
            bis >= iv_keydate AND
            ab <= iv_keydate.
    IF sy-subrc <> 0.
      MESSAGE i002(zagc_masterdata) WITH 'V_EANL' iv_anlage INTO gv_msgtext.
      zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD is_netz.

        CASE sy-mandt.
          WHEN '210'.
            MOVE abap_true TO rv_is_netz.
          WHEN '110'.
            MOVE abap_false TO rv_is_netz.
          WHEN OTHERS.
        ENDCASE.

  ENDMETHOD.


  METHOD is_reg_division_type.
    CASE iv_division_type.
      WHEN zif_agc_datex_utilmd_co=>gc_sparte_strom OR zif_agc_datex_utilmd_co=>gc_sparte_gas.
        rv_reg_division_type = abap_true.
      WHEN OTHERS.
        rv_reg_division_type = abap_false.
    ENDCASE.
  ENDMETHOD.


  METHOD is_reg_process.

    FIELD-SYMBOLS: <fs_diverse> TYPE /idxgc/s_diverse_details.

    rv_reg_process = abap_true.

    READ TABLE is_process_step_data-diverse ASSIGNING <fs_diverse> INDEX 1.

    IF <fs_diverse> IS ASSIGNED.
      IF <fs_diverse>-msgtransreason = 'Z33'. "Stilllegung
        CLEAR rv_reg_process.
      ENDIF.
    ENDIF.


  ENDMETHOD.


  METHOD map_eanl_codes.
*---- Spannungsebene Messung ermitteln-------------------------------------------------------------

    IF is_eanl-sparte = /idxgc/if_constants_ide=>gc_division_ele.

      DATA: ls_zlw_spebene TYPE zlw_spebene.

      SELECT SINGLE * FROM zlw_spebene INTO ls_zlw_spebene
                      WHERE spebene  = is_eanl-spebene AND
                            sparte = is_eanl-sparte AND
                            zzespebene_ms = is_eanl-zzespebene_ms AND
                            zzenetz1 = is_eanl-zzenetz1.

      cs_spebene_messung = ls_zlw_spebene-zz_spebenemess.

*---- Spannungsebene Entnahme ermitteln------------------------------------------------------------

      SELECT SINGLE * FROM zlw_spebene INTO ls_zlw_spebene
                      WHERE spebene  = is_eanl-spebene AND
                            sparte = is_eanl-sparte AND
                            zzespebene_ms = is_eanl-zzespebene_ms AND
                            zzenetz1 = is_eanl-zzenetz1.

      cs_spebene_entnahme = ls_zlw_spebene-zz_spebene.

*---- Druckstufe ermitteln-------------------------------------------------------------------------

    ELSEIF is_eanl-sparte = /idxgc/if_constants_ide=>gc_division_gas.

      SELECT SINGLE * FROM zlw_spebene INTO ls_zlw_spebene
                      WHERE spebene  = is_eanl-spebene AND
                            sparte = is_eanl-sparte AND
                            zzespebene_ms = is_eanl-zzespebene_ms AND
                            zzenetz1 = is_eanl-zzenetz1.

      cs_druckstufe = ls_zlw_spebene-zz_spebene.

    ENDIF.
  ENDMETHOD.
ENDCLASS.
