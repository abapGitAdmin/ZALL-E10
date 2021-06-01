class ZCL_AGC_ISU_POD definition
  public
  final
  create public .

public section.

  type-pools ABAP .
  methods CONSTRUCTOR
    importing
      !IV_INT_UI type INT_UI
      !IV_KEYDATE type DATS default SY-DATUM
      !IV_PROCESS_ALL_DATA type KENNZX default ABAP_TRUE
    raising
      ZCX_AGC_MASTERDATA .
  methods GET_V_EANL
    returning
      value(RS_V_EANL) type V_EANL
    raising
      ZCX_AGC_MASTERDATA .
  methods GET_EXT_UI
    returning
      value(RV_EXT_UI) type EXT_UI
    raising
      ZCX_AGC_MASTERDATA .
  methods GET_INT_UI
    returning
      value(RV_INT_UI) type INT_UI
    raising
      ZCX_AGC_MASTERDATA .
  methods GET_METMETHOD
    returning
      value(RV_METMETHOD) type EIDESWTMDMETMETHOD
    raising
      ZCX_AGC_MASTERDATA .
  methods GET_SPARTE
    returning
      value(RV_SPARTE) type DIVISION
    raising
      ZCX_AGC_MASTERDATA .
  methods GET_ANLAGE
    returning
      value(RV_ANLAGE) type ANLAGE
    raising
      ZCX_AGC_MASTERDATA .
  methods GET_PORTION
    returning
      value(RV_PORTION) type PORTION
    raising
      ZCX_AGC_MASTERDATA .
  methods GET_PERIOD_LENGTH
    returning
      value(RV_PERIOD_LENGTH) type PERIODEW
    raising
      ZCX_AGC_MASTERDATA .
  methods GET_CONTRACT
    returning
      value(RV_CONTRACT) type VERTRAG
    raising
      ZCX_AGC_MASTERDATA .
  methods GET_EVER
    returning
      value(RS_EVER) type EVER
    raising
      ZCX_AGC_MASTERDATA .
  methods GET_PROFIL
    returning
      value(RV_PROFIL) type ZEDMLASTPROFIL
    raising
      ZCX_AGC_MASTERDATA .
  methods GET_SPEBENE_LST
    returning
      value(RV_SPEBENE_LST) type SPEBENE
    raising
      ZCX_AGC_MASTERDATA .
  methods GET_SPEBENE_MES
    returning
      value(RV_SPEBENE_MES) type ZZESPEBENE_MS
    raising
      ZCX_AGC_MASTERDATA .
  methods GET_KZ_HHK
    returning
      value(RV_KZ_HHK) type ABAP_BOOL
    raising
      ZCX_AGC_MASTERDATA .
  methods GET_PERVERBR
    returning
      value(RV_PERVERBR) type PERVERBR
    raising
      ZCX_AGC_MASTERDATA .
  methods GET_PROGYEARCONS
    returning
      value(RV_PROGYEARCONS) type EIDESWTMDPROGYEARCONS
    raising
      ZCX_AGC_MASTERDATA .
  methods GET_FALLGRUPPE_GABI
    returning
      value(RV_FALLGRUPPE_GABI) type ZZFALLGRUPPE
    raising
      ZCX_AGC_MASTERDATA .
  methods GET_CUSTOMER_VALUE
    importing
      !IV_PROGYEARCONS type EIDESWTMDPROGYEARCONS optional
    returning
      value(RV_CUSTOMER_VALUE) type ZEDMKUNDENWERT
    raising
      ZCX_AGC_MASTERDATA .
  methods GET_MAXDEMAND
    returning
      value(RV_MAXDEMAND) type EIDESWTMDMAXDEMAND
    raising
      ZCX_AGC_MASTERDATA .
  methods GET_MABIS_TIME_SERIES
    returning
      value(RV_MABIS_TIME_SERIES) type ZLWZEITREIHENTYP
    raising
      ZCX_AGC_MASTERDATA .
  methods GET_TTYP_ATTRIBUTES
    returning
      value(RS_TTYP_ATTRIBUTES) type ZEPDPRODUKTTARIFTYP
    raising
      ZCX_AGC_MASTERDATA .
  methods GET_LOSS_FACTOR
    returning
      value(RV_LOSS_FACTOR) type /IDXGC/DE_LOSSFACT_EXT_1
    raising
      ZCX_AGC_MASTERDATA .
  methods GET_DEVICE_DATA
    returning
      value(RT_DEVICE_DATA) type T_V_EGER
    raising
      ZCX_AGC_MASTERDATA .
  methods GET_MSB
    returning
      value(RS_MSB) type ESERVPROV
    raising
      ZCX_AGC_MASTERDATA .
  methods GET_MDL
    returning
      value(RS_MDL) type ESERVPROV
    raising
      ZCX_AGC_MASTERDATA .
  methods GET_SERVICES
    returning
      value(RT_SERVICES) type /IDXGC/T_PROC_AGENT
    raising
      ZCX_AGC_MASTERDATA .
  type-pools ISU20 .
  methods GET_INSTLN_FACTS
    returning
      value(RS_INSTLN_FACTS) type ISU20_INSTLN_FACTS_AUTO
    raising
      ZCX_AGC_MASTERDATA .
  methods GET_COM_DISC_PERC
    returning
      value(RV_COM_DISC_PERC) type /IDXGC/DE_COMMUNITY_DISCNT
    raising
      ZCX_AGC_MASTERDATA .
  methods GET_PARTNER
    returning
      value(RV_PARTNER) type BU_PARTNER
    raising
      ZCX_AGC_MASTERDATA .
  methods GET_GAS_QUALITY
    returning
      value(RV_GAS_QUALITY) type /IDXGC/DE_GAS_QUALITY
    raising
      ZCX_AGC_MASTERDATA .
  methods GET_MARKET_AREA
    returning
      value(RV_MARKET_AREA) type /IDXGC/DE_MARKET_AREA
    raising
      ZCX_AGC_MASTERDATA .
protected section.
private section.

  data LS_V_EANL type V_EANL .
  data LV_EXT_UI type EXT_UI .
  data LV_INT_UI type INT_UI .
  data LV_METMETHOD type EIDESWTMDMETMETHOD .
  data LV_SPARTE type DIVISION .
  data LV_ANLAGE type ANLAGE .
  data LV_KEYDATE type DATS .
  data LV_PORTION type PORTION .
  data LV_PERIOD_LENGTH type PERIODEW .
  data LV_CONTRACT type VERTRAG .
  data LS_EVER type EVER .
  data LV_PROFIL type ZEDMLASTPROFIL .
  data LV_SPEBENE_LST type SPEBENE .
  data LV_SPEBENE_MES type ZZESPEBENE_MS .
  type-pools ABAP .
  data LV_KZ_HHK type ABAP_BOOL .
  data LV_PERVERBR type PERVERBR .
  data LV_PROGYEARCONS type EIDESWTMDPROGYEARCONS .
  data LV_FALLGRUPPE_GABI type ZZFALLGRUPPE .
  data LV_CUSTOMER_VALUE type ZEDMKUNDENWERT .
  data LV_MAXDEMAND type EIDESWTMDMAXDEMAND .
  data LV_MABIS_TIME_SERIES type ZLWZEITREIHENTYP .
  data LS_TTYP_ATTRIBUTES type ZEPDPRODUKTTARIFTYP .
  data LV_LOSS_FACTOR type /IDXGC/DE_LOSSFACT_EXT_1 .
  data LT_DEVICE_DATA type /IDXGC/T_DEVICE_DATA .
  data LS_MSB type ESERVPROV .
  data LS_MDL type ESERVPROV .
  data LT_SERVICES type /IDXGC/T_PROC_AGENT .
  type-pools ISU20 .
  data LS_INSTLN_FACTS type ISU20_INSTLN_FACTS_AUTO .
  data LV_COM_DISC_PERC type /IDXGC/DE_COMMUNITY_DISCNT .
  data LV_PARTNER type BU_PARTNER .
  data LV_GAS_QUALITY type /IDXGC/DE_GAS_QUALITY .
  data LV_MARKET_AREA type /IDXGC/DE_MARKET_AREA .
ENDCLASS.



CLASS ZCL_AGC_ISU_POD IMPLEMENTATION.


  METHOD constructor.
    TRY.

        me->lv_keydate = iv_keydate.

        me->lv_int_ui = iv_int_ui.

        me->lv_ext_ui = zcl_agc_masterdata=>get_ext_ui( iv_int_ui = iv_int_ui iv_keydate = iv_keydate ).

        CHECK iv_process_all_data IS NOT INITIAL.

        me->lv_sparte = zcl_agc_masterdata=>get_sparte( iv_ext_ui = me->get_ext_ui( ) ).

        me->lv_anlage = zcl_agc_masterdata=>get_anlage( iv_ext_ui = me->get_ext_ui( ) iv_keydate = iv_keydate ).

        me->ls_v_eanl = zcl_agc_masterdata=>get_v_eanl( iv_anlage = me->get_anlage( ) iv_keydate = iv_keydate ).

        me->lv_metmethod = zcl_agc_masterdata=>get_metmethod( iv_anlage = me->get_anlage( ) iv_keydate = iv_keydate ).

        me->lv_portion = zcl_agc_masterdata=>get_portion( iv_ableinh = me->ls_v_eanl-ableinh ).

        me->lv_period_length = zcl_agc_masterdata=>get_period_length( iv_portion = me->get_portion( ) ).

        me->lv_contract = zcl_agc_masterdata=>get_contract( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).

        me->ls_ever = zcl_agc_masterdata=>get_ever( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).

        me->lv_profil = zcl_agc_masterdata=>get_profil( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).

        me->lv_spebene_mes = zcl_agc_masterdata=>get_spebene_messung( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).

        me->lv_spebene_lst = zcl_agc_masterdata=>get_spebene_lieferstelle( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).

        me->lv_progyearcons = zcl_agc_masterdata=>get_progyearcons( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).

        me->lv_perverbr = zcl_agc_masterdata=>get_perverbr( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).

        me->lv_kz_hhk = zcl_agc_masterdata=>get_kz_hhk( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).

        me->lv_fallgruppe_gabi = zcl_agc_masterdata=>get_fallgruppe_gabi( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).

        me->lv_customer_value = zcl_edm_utility=>get_customer_value_anlage( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).

        me->lv_maxdemand = zcl_agc_masterdata=>get_maxdemand( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).

        me->lv_mabis_time_series = zcl_agc_masterdata=>get_mabis_time_series( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).

        me->ls_ttyp_attributes = zcl_agc_masterdata=>get_ttyp_attributes( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).

        me->lv_loss_factor = zcl_agc_masterdata=>get_loss_factor( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).

        me->ls_mdl = zcl_agc_masterdata=>get_mdl( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).

        me->ls_msb = zcl_agc_masterdata=>get_msb( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).

        me->lt_device_data = zcl_agc_masterdata=>get_device_data( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).

        me->lt_services = zcl_agc_masterdata=>get_services( iv_int_ui = me->get_int_ui( ) iv_keydate = me->lv_keydate ).

        me->ls_instln_facts = zcl_agc_masterdata=>get_instln_facts( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).

        me->lv_com_disc_perc = zcl_agc_masterdata=>get_com_disc_perc( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).

        me->lv_partner = zcl_agc_masterdata=>get_partner( iv_ext_ui = me->get_ext_ui( ) iv_keydate = me->lv_keydate ).

      CATCH zcx_agc_masterdata.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDTRY.

  ENDMETHOD.


  METHOD get_anlage.
    TRY.

        IF me->lv_anlage IS INITIAL.
          me->lv_anlage = zcl_agc_masterdata=>get_anlage( iv_ext_ui = me->lv_ext_ui iv_keydate = me->lv_keydate ).
        ENDIF.

        rv_anlage = me->lv_anlage.

      CATCH zcx_agc_masterdata.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDTRY.

  ENDMETHOD.


  METHOD get_com_disc_perc.

    DATA lv_value TYPE p DECIMALS 2.                 "Wolf.A., 13.10.2015, Mantis 5087

    TRY.
        IF me->lv_com_disc_perc IS INITIAL.
          me->lv_com_disc_perc = zcl_agc_masterdata=>get_com_disc_perc( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).
        ENDIF.

        lv_value = me->lv_com_disc_perc.             "Wolf.A., 13.10.2015, Mantis 5087: den Wert auf 2 Dezimalstellen begrenzen
        rv_com_disc_perc = lv_value.                 "Wolf.A., 13.10.2015, Mantis 5087
*        rv_com_disc_perc = me->lv_com_disc_perc.    "Wolf.A., 13.10.2015, Mantis 5087

      CATCH zcx_agc_masterdata.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDTRY.

  ENDMETHOD.


  METHOD get_contract.

    TRY.
        IF me->lv_contract IS INITIAL.
          me->lv_contract = zcl_agc_masterdata=>get_contract( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).
        ENDIF.

        rv_contract = me->lv_contract.

      CATCH zcx_agc_masterdata.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDTRY.


  ENDMETHOD.


  METHOD get_customer_value.
    "THIMEL.R, 20150919, Anpassung für SDÄ da auch im Vertrieb ein Kundenwert ermittelt werden muss.
    TRY.
        IF me->lv_customer_value IS INITIAL.
          IF iv_progyearcons IS NOT INITIAL.
            me->lv_customer_value = zcl_edm_utility=>get_customer_value( iv_profile = me->get_profil( ) iv_progyearcons = iv_progyearcons iv_keydate = me->lv_keydate ).
          ELSE.
            me->lv_customer_value = zcl_edm_utility=>get_customer_value_anlage( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).
          ENDIF.
        ENDIF.

        rv_customer_value = me->lv_customer_value.

      CATCH zcx_agc_masterdata.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD get_device_data.
    TRY.
        IF me->lt_device_data IS INITIAL.
          me->lt_device_data = zcl_agc_masterdata=>get_device_data( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).
        ENDIF.

        rt_device_data = me->lt_device_data.

      CATCH zcx_agc_masterdata.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD get_ever.
    TRY.
        IF me->ls_ever IS INITIAL.
          me->ls_ever = zcl_agc_masterdata=>get_ever( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).
        ENDIF.

        rs_ever = me->ls_ever.

      CATCH zcx_agc_masterdata.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  method GET_EXT_UI.
    rv_ext_ui = me->lv_ext_ui.
  endmethod.


  METHOD get_fallgruppe_gabi.
    TRY.
        IF me->lv_fallgruppe_gabi IS INITIAL.
          me->lv_fallgruppe_gabi = zcl_agc_masterdata=>get_fallgruppe_gabi( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).
        ENDIF.

        rv_fallgruppe_gabi = me->lv_fallgruppe_gabi.

      CATCH zcx_agc_masterdata.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD get_gas_quality.
    TRY.
        IF me->lv_gas_quality IS INITIAL.
          me->lv_gas_quality = zcl_agc_masterdata=>get_gas_quality( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).
        ENDIF.

        rv_gas_quality = me->lv_gas_quality.

      CATCH zcx_agc_masterdata.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD get_instln_facts.

    TRY.
        IF me->ls_instln_facts IS INITIAL.
          me->ls_instln_facts = zcl_agc_masterdata=>get_instln_facts( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).
        ENDIF.

        rs_instln_facts = me->ls_instln_facts.

      CATCH zcx_agc_masterdata.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDTRY.

  ENDMETHOD.


  method GET_INT_UI.
    rv_int_ui = me->lv_int_ui.
  endmethod.


  METHOD get_kz_hhk.
    TRY.
        IF me->lv_kz_hhk IS INITIAL.
          me->lv_kz_hhk = zcl_agc_masterdata=>get_kz_hhk( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).
        ENDIF.

        rv_kz_hhk = me->lv_kz_hhk.

      CATCH zcx_agc_masterdata.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD get_loss_factor.
    TRY.
        IF me->lv_loss_factor IS INITIAL.
          me->lv_loss_factor = zcl_agc_masterdata=>get_loss_factor( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).
        ENDIF.

        rv_loss_factor = me->lv_loss_factor.

      CATCH zcx_agc_masterdata.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD GET_MABIS_TIME_SERIES.
    TRY.
        IF me->lv_mabis_time_series IS INITIAL.
          me->lv_mabis_time_series = zcl_agc_masterdata=>get_mabis_time_series( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).
        ENDIF.

        rv_mabis_time_series = me->lv_mabis_time_series.

      CATCH zcx_agc_masterdata.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD get_market_area.
    TRY.
        IF me->lv_market_area IS INITIAL.
          me->lv_market_area = zcl_agc_masterdata=>get_market_area( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).
        ENDIF.

        rv_market_area = me->lv_market_area.

      CATCH zcx_agc_masterdata.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD get_maxdemand.
    TRY.
        IF me->lv_maxdemand IS INITIAL.
          me->lv_maxdemand = zcl_agc_masterdata=>get_maxdemand( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).
        ENDIF.

        rv_maxdemand = me->lv_maxdemand.

      CATCH zcx_agc_masterdata.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD get_mdl.
    TRY.
        IF me->ls_mdl IS INITIAL.
          me->ls_mdl = zcl_agc_masterdata=>get_mdl( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).
        ENDIF.

        rs_mdl = me->ls_mdl.

      CATCH zcx_agc_masterdata.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD get_metmethod.
    TRY.
        IF me->lv_metmethod IS INITIAL.
          me->lv_metmethod = zcl_agc_masterdata=>get_metmethod( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).
        ENDIF.

        rv_metmethod = me->lv_metmethod.

      CATCH zcx_agc_masterdata.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDTRY.

  ENDMETHOD.


  METHOD get_msb.
    TRY.
        IF me->ls_msb IS INITIAL.
          me->ls_msb = zcl_agc_masterdata=>get_msb( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).
        ENDIF.

        rs_msb = me->ls_msb.

      CATCH zcx_agc_masterdata.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD get_partner.
    TRY.
        IF me->lv_partner IS INITIAL.
          me->lv_partner = zcl_agc_masterdata=>get_partner( iv_ext_ui = me->get_ext_ui( ) iv_keydate = me->lv_keydate ).
        ENDIF.

        rv_partner = me->lv_partner.

      CATCH zcx_agc_masterdata.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD get_period_length.

    TRY.
        IF me->lv_portion IS INITIAL.
          me->lv_portion = me->get_portion( ).
        ENDIF.

        IF me->lv_period_length IS INITIAL.
          me->lv_period_length = zcl_agc_masterdata=>get_period_length( iv_portion = me->lv_portion ).
        ENDIF.

        rv_period_length = me->lv_period_length.

      CATCH zcx_agc_masterdata.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDTRY.

  ENDMETHOD.


  METHOD get_perverbr.
    TRY.
        IF me->lv_perverbr IS INITIAL.
          me->lv_perverbr = zcl_agc_masterdata=>get_perverbr( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).
        ENDIF.

        rv_perverbr = me->lv_perverbr.

      CATCH zcx_agc_masterdata.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD get_portion.

    TRY.
        IF me->ls_v_eanl IS INITIAL.
          me->ls_v_eanl = me->get_v_eanl( ).
        ENDIF.

        IF me->lv_portion IS INITIAL.
          me->lv_portion = zcl_agc_masterdata=>get_portion( iv_ableinh = me->ls_v_eanl-ableinh ).
        ENDIF.

        rv_portion = me->lv_portion.

      CATCH zcx_agc_masterdata.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD get_profil.
    TRY.
        IF me->lv_profil IS INITIAL.
          me->lv_profil = zcl_agc_masterdata=>get_profil( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).
        ENDIF.

        rv_profil = me->lv_profil.

      CATCH zcx_agc_masterdata.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD get_progyearcons.
    TRY.
        IF me->lv_progyearcons IS INITIAL.
          me->lv_progyearcons = zcl_agc_masterdata=>get_progyearcons( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).
        ENDIF.

        rv_progyearcons = me->lv_progyearcons.

      CATCH zcx_agc_masterdata.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD get_services.

    TRY.
        IF me->lt_services IS INITIAL.
          me->lt_services = zcl_agc_masterdata=>get_services( iv_int_ui = me->get_int_ui( ) iv_keydate = me->lv_keydate ).
        ENDIF.

        rt_services = me->lt_services.

      CATCH zcx_agc_masterdata.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDTRY.

  ENDMETHOD.


  METHOD get_sparte.
    TRY.

        IF me->lv_sparte IS INITIAL.
          me->lv_sparte = zcl_agc_masterdata=>get_sparte( iv_ext_ui = me->lv_ext_ui iv_keydate = me->lv_keydate ).
        ENDIF.

        rv_sparte = me->lv_sparte.

      CATCH zcx_agc_masterdata.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDTRY.


  ENDMETHOD.


  METHOD get_spebene_lst.
    TRY.
        IF me->lv_spebene_lst IS INITIAL.
          me->lv_spebene_lst = zcl_agc_masterdata=>get_spebene_lieferstelle( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).
        ENDIF.

        rv_spebene_lst = me->lv_spebene_lst.

      CATCH zcx_agc_masterdata.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD get_spebene_mes.
    TRY.
        IF me->lv_spebene_mes IS INITIAL.
          me->lv_spebene_mes = zcl_agc_masterdata=>get_spebene_messung( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).
        ENDIF.

        rv_spebene_mes = me->lv_spebene_mes.

      CATCH zcx_agc_masterdata.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD get_ttyp_attributes.
    TRY.
        IF me->ls_ttyp_attributes IS INITIAL.
          me->ls_ttyp_attributes = zcl_agc_masterdata=>get_ttyp_attributes( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).
        ENDIF.

        rs_ttyp_attributes = me->ls_ttyp_attributes.

      CATCH zcx_agc_masterdata.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD get_v_eanl.
    TRY.
        IF me->ls_v_eanl IS INITIAL.
          me->ls_v_eanl = zcl_agc_masterdata=>get_v_eanl( iv_anlage = me->get_anlage( ) iv_keydate = me->lv_keydate ).
        ENDIF.

        rs_v_eanl = me->ls_v_eanl.
      CATCH zcx_agc_masterdata.
        zcx_agc_masterdata=>raise_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
