class /ADESSO/CL_MDC_CUSTOMIZING definition
  public
  final
  create public .

public section.

  class-methods IS_SERVPROV_IN_MPGR
    importing
      !IV_MP_GROUP_NO type /ADESSO/MDC_MP_GROUP_NO
      !IV_ASSOC_SERVPROV type E_DEXSERVPROV
    returning
      value(RV_SP_IS_IN_MPGR) type ABAP_BOOL
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_EDIFACT_STRUCTUR
    importing
      !IS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA
    returning
      value(RT_EDIFACT_STRUCTUR) type /ADESSO/MDC_T_EDIFACT_STR
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_FORWARD_AMID
    importing
      !IV_AMID type /IDXGC/DE_AMID
      !IV_RECEIVER_INTCODE type /ADESSO/MDC_INTCODE
      !IV_KEYDATE type /IDXGC/DE_KEYDATE default SY-DATUM
    returning
      value(RV_AMID_FORWARD) type /IDXGC/DE_AMID
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_INBOUND_CONFIG_FOR_EDIFACT
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IV_KEYDATE type /IDXGC/DE_KEYDATE default SY-DATUM
      !IV_ASSOC_SERVPROV type E_DEXSERVPROV
    returning
      value(RS_CUST_IN) type /ADESSO/MDC_S_IN
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_ROLES_AMIDS
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IV_KEYDATE type /IDXGC/DE_KEYDATE default SY-DATUM
    returning
      value(RS_CUST_RAID) type /ADESSO/MDC_S_RAID
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_OWN_INTCODE
    returning
      value(RV_OWN_INTCODE) type /ADESSO/MDC_S_MAIN
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_GENERAL_CUSTOMIZING
    returning
      value(RS_CUST_MAIN) type /ADESSO/MDC_S_MAIN
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_INTCODE_RESPONSIBLE
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR optional
      !IT_EDIFACT_STRUCTUR type /ADESSO/MDC_T_EDIFACT_STR optional
    returning
      value(RV_INTCODE_RESPONSIBLE) type /ADESSO/MDC_INTCODE
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_PDOC_EDIFACT_MAPPING
    returning
      value(RT_CUST_PDOC) type /ADESSO/MDC_T_PDOC
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_SINGLE_PDOC_EDIFACT_MAP
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
    returning
      value(RS_CUST_PDOC) type /ADESSO/MDC_S_PDOC
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_SEND_DELAY
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR optional
      !IV_KEYDATE type /IDXGC/DE_KEYDATE default SY-DATUM
      !IV_ASSOC_SERVPROV type E_DEXSERVPROV
    returning
      value(RV_SEND_DELAY) type /ADESSO/MDC_SEND_DELAY
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_SEND_FLAG
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR optional
      !IV_KEYDATE type /IDXGC/DE_KEYDATE default SY-DATUM
      !IV_ASSOC_SERVPROV type E_DEXSERVPROV
    returning
      value(RV_FLAG_SEND) type /ADESSO/MDC_FLAG_SEND
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_START_AMID
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IV_SENDER_INTCODE type /ADESSO/MDC_INTCODE
      !IV_RECEIVER_INTCODE type /ADESSO/MDC_INTCODE optional
      !IV_FLAG_SENDER_FUTURE type FLAG optional
      !IV_FLAG_RECEIVER_FUTURE type FLAG optional
    returning
      value(RV_AMID) type /IDXGC/DE_AMID
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_DP_CONFIG
    importing
      !IV_AMID type /IDXGC/DE_AMID
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IV_KEYDATE type /IDXGC/DE_KEYDATE default SY-DATUM
    returning
      value(RS_CUST_ODP) type /ADESSO/MDC_S_ODP
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_METHOD_FOR_DP_CONDITION
    importing
      !IV_DP_CONDITION_NO type /ADESSO/MDC_DP_CONDITION_NO
      !IV_KEYDATE type /IDXGC/DE_KEYDATE optional
    returning
      value(RS_CUST_ODPM) type /ADESSO/MDC_S_ODPM
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_PDOC_PQAL_MAPPING
    returning
      value(RT_CUST_PQAL) type /ADESSO/MDC_T_PQAL
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_SUB_EDIFACT_STRUCTUR
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IV_KEYDATE type /IDXGC/DE_KEYDATE default SY-DATUM
    returning
      value(RT_EDIFACT_STRUCTUR) type /ADESSO/MDC_T_EDIFACT_STR
    raising
      /IDXGC/CX_GENERAL .
protected section.

  class-data GT_CUST_RAID type /ADESSO/MDC_T_RAID .
  class-data GS_CUST_MAIN type /ADESSO/MDC_S_MAIN .
  class-data GV_MTEXT type STRING .
  class-data GT_CUST_PDOC type /ADESSO/MDC_T_PDOC .
  class-data GT_CUST_ODPM type /ADESSO/MDC_T_ODPM .
  class-data GT_CUST_PQAL type /ADESSO/MDC_T_PQAL .
  class-data GT_CUST_SND type /ADESSO/MDC_T_SND .
  class-data GT_CUST_SNDA type /ADESSO/MDC_T_SNDA .
  class-data GT_CUST_ODP type /ADESSO/MDC_T_ODP .
  class-data GT_CUST_RAED type /ADESSO/MDC_T_RAED .
  class-data GT_CUST_IN type /ADESSO/MDC_T_IN .
  class-data GT_CUST_INA type /ADESSO/MDC_T_INA .
  class-data GT_CUST_OFRW type /ADESSO/MDC_T_OFRW .
  class-data GT_CUST_MPGR type /ADESSO/MDC_T_MPGR .
  class-data GT_CUST_MPSP type /ADESSO/MDC_T_MPSP .
private section.
ENDCLASS.



CLASS /ADESSO/CL_MDC_CUSTOMIZING IMPLEMENTATION.


  METHOD get_dp_config.
    IF gt_cust_odp IS INITIAL.
      SELECT * FROM /adesso/mdc_odp INTO TABLE gt_cust_odp ORDER BY valid_from DESCENDING.
    ENDIF.

    LOOP AT gt_cust_odp INTO rs_cust_odp WHERE amid = iv_amid  AND edifact_structur = iv_edifact_structur AND valid_from < iv_keydate.
      EXIT.
    ENDLOOP.
    IF sy-subrc <> 0.
      MESSAGE e001(/adesso/mdc_cust) WITH '/ADESSO/MDC_ODP' INTO gv_mtext.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  method GET_EDIFACT_STRUCTUR.
  endmethod.


  METHOD get_forward_amid.
    FIELD-SYMBOLS: <fs_cust_amid> TYPE /adesso/mdc_s_ofrw.

    IF gt_cust_ofrw IS INITIAL.
      SELECT * FROM /adesso/mdc_ofrw INTO TABLE gt_cust_ofrw ORDER BY valid_from DESCENDING.
    ENDIF.

    LOOP AT gt_cust_ofrw ASSIGNING <fs_cust_amid> WHERE amid = iv_amid AND intcode = iv_receiver_intcode AND valid_from <= iv_keydate.
      rv_amid_forward = <fs_cust_amid>-amid_forward.
      EXIT.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_general_customizing.
***************************************************************************************************
* THIMEL-R, 20150726, SDÄ auf Common Layer Engine
***************************************************************************************************
    IF gs_cust_main IS INITIAL.
      SELECT SINGLE * FROM /adesso/mdc_main INTO gs_cust_main.
      IF sy-subrc <> 0.
        MESSAGE e001(/adesso/mdc_cust) WITH '/ADESSO/MDC_MAIN' INTO gv_mtext.
        /idxgc/cx_general=>raise_exception_from_msg( ).
      ENDIF.
    ENDIF.
    rs_cust_main = gs_cust_main.
  ENDMETHOD.


  METHOD get_inbound_config_for_edifact.
***************************************************************************************************
* THIMEL-R, 20150726, SDÄ auf Common Layer Engine
*    Ermitteln der Verbuchungsmethodik zu einer Stammdatenänderung  und einem Marktpartner.
*    Suche erst spezielle Bedingungen für den Marktpartner, danach allgemeine für alle.
***************************************************************************************************
    DATA: lv_is_sp_in_mpgr TYPE abap_bool,
          lv_mp_group_no   TYPE /adesso/mdc_mp_group_no,
          lv_servprov      TYPE e_dexservprov.

    FIELD-SYMBOLS: <fs_cust_in>  TYPE /adesso/mdc_s_in,
                   <fs_cust_ina> TYPE /adesso/mdc_s_ina.

    IF gt_cust_in IS INITIAL.
      SELECT * FROM /adesso/mdc_in INTO TABLE gt_cust_in ORDER BY valid_from DESCENDING.
    ENDIF.

    IF gt_cust_ina IS INITIAL.
      SELECT * FROM /adesso/mdc_ina INTO TABLE gt_cust_ina ORDER BY valid_from DESCENDING.
    ENDIF.

    LOOP AT gt_cust_in ASSIGNING <fs_cust_in> WHERE edifact_structur = iv_edifact_structur AND valid_from < iv_keydate.
      "Suche nach speziellen Einträgen zum Marktpartner
      LOOP AT gt_cust_ina ASSIGNING <fs_cust_ina> WHERE edifact_structur = iv_edifact_structur AND valid_from = <fs_cust_in>-valid_from.
        IF is_servprov_in_mpgr( iv_mp_group_no = <fs_cust_ina>-mp_group_no iv_assoc_servprov = iv_assoc_servprov ) = abap_true.
          MOVE-CORRESPONDING <fs_cust_ina> TO rs_cust_in.
          RETURN.
        ENDIF.
      ENDLOOP.
      rs_cust_in = <fs_cust_in>.
      RETURN.
    ENDLOOP.

    MESSAGE e002(/adesso/mdc_cust) WITH iv_edifact_structur '/ADESSO/MDC_IN' INTO gv_mtext.
    /idxgc/cx_general=>raise_exception_from_msg( ).
  ENDMETHOD.


  METHOD get_intcode_responsible.
***************************************************************************************************
* THIMEL-R, 20150726, SDÄ auf Common Layer Engine
*    Ermittlung des Verantwortlichen zu einer EDIFACT Struktur.
***************************************************************************************************
    DATA: lt_edifact_structur    TYPE /adesso/mdc_t_edifact_str,
          ls_cust_raid           TYPE /adesso/mdc_raid,
          lv_intcode_responsible TYPE /adesso/mdc_intcode.
    FIELD-SYMBOLS: <fv_edifact_structur> TYPE /idxgc/de_edifact_str.

    lt_edifact_structur = it_edifact_structur.
    IF iv_edifact_structur IS NOT INITIAL.
      APPEND iv_edifact_structur TO lt_edifact_structur.
    ENDIF.

    LOOP AT lt_edifact_structur ASSIGNING <fv_edifact_structur>.
      ls_cust_raid = /adesso/cl_mdc_customizing=>get_roles_amids( iv_edifact_structur = <fv_edifact_structur> ).

      IF ls_cust_raid-distributor_role = /adesso/if_mdc_co=>gc_role_r.
        lv_intcode_responsible = /idxgc/if_constants=>gc_service_code_dso.
      ELSEIF ls_cust_raid-supplier_role = /adesso/if_mdc_co=>gc_role_r.
        lv_intcode_responsible = /idxgc/if_constants=>gc_service_code_supplier.
      ELSEIF ls_cust_raid-feeder_role = /adesso/if_mdc_co=>gc_role_r.
        lv_intcode_responsible = /idxgc/if_constants=>gc_service_code_supplier.
      ELSEIF ls_cust_raid-mos_role = /adesso/if_mdc_co=>gc_role_r.
        lv_intcode_responsible = /adesso/if_mdc_co=>gc_intcode_m1.
      ELSEIF ls_cust_raid-supplier_future_role = /adesso/if_mdc_co=>gc_role_r.
        lv_intcode_responsible = /idxgc/if_constants=>gc_service_code_supplier.
      ELSEIF ls_cust_raid-feeder_future_role = /adesso/if_mdc_co=>gc_role_r.
        lv_intcode_responsible = /idxgc/if_constants=>gc_service_code_supplier.
      ENDIF.

      IF rv_intcode_responsible IS INITIAL.
        rv_intcode_responsible = lv_intcode_responsible.
      ELSEIF rv_intcode_responsible <> lv_intcode_responsible.
        MESSAGE e004(/adesso/mdc_cust) INTO gv_mtext.
        /idxgc/cx_general=>raise_exception_from_msg( ).
      ENDIF.
    ENDLOOP.
    IF rv_intcode_responsible IS INITIAL.
      MESSAGE e003(/adesso/mdc_cust) WITH iv_edifact_structur INTO gv_mtext.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD get_method_for_dp_condition.

    IF gt_cust_odpm IS INITIAL.
      SELECT * FROM /adesso/mdc_odpm INTO TABLE gt_cust_odpm.
    ENDIF.
    READ TABLE gt_cust_odpm INTO rs_cust_odpm WITH KEY dp_condition_no = iv_dp_condition_no.

    IF sy-subrc = 4.
      MESSAGE e001(/adesso/mdc_cust) WITH '/ADESSO/MDC_ODPM' INTO gv_mtext.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD get_own_intcode.
***************************************************************************************************
* THIMEL-R, 20150726, SDÄ auf Common Layer Engine
***************************************************************************************************
    IF gs_cust_main IS INITIAL.
      SELECT SINGLE * FROM /adesso/mdc_main INTO gs_cust_main.
      IF sy-subrc <> 0.
        MESSAGE e001(/adesso/mdc_cust) WITH '/ADESSO/MDC_MAIN' INTO gv_mtext.
        /idxgc/cx_general=>raise_exception_from_msg( ).
      ENDIF.
    ENDIF.
    rv_own_intcode = gs_cust_main-global_intcode.
  ENDMETHOD.


  method GET_PDOC_EDIFACT_MAPPING.
***************************************************************************************************
    IF gt_cust_pdoc IS INITIAL.
      SELECT * FROM /adesso/mdc_pdoc INTO table gt_cust_pdoc.
      IF sy-subrc <> 0.
        MESSAGE e001(/adesso/mdc_cust) WITH '/ADESSO/MDC_PDOC' INTO gv_mtext.
        /idxgc/cx_general=>raise_exception_from_msg( ).
      ENDIF.
    ENDIF.
    rt_cust_pdoc = gt_cust_pdoc.
  endmethod.


  method GET_PDOC_PQAL_MAPPING.
     IF gt_cust_pqal IS INITIAL.
      SELECT * FROM /adesso/mdc_pqal INTO table gt_cust_pqal.
      IF sy-subrc <> 0.
        MESSAGE e001(/adesso/mdc_cust) WITH '/ADESSO/MDC_PQAL' INTO gv_mtext.
        /idxgc/cx_general=>raise_exception_from_msg( ).
      ENDIF.
    ENDIF.
    rt_cust_pqal = gt_cust_pqal.
  endmethod.


  METHOD get_roles_amids.
***************************************************************************************************
* THIMEL-R, 20150726, SDÄ auf Common Layer Engine
*   Lesen der Rollen aus dem Customizing und ggf. nachlesen von EDIFACT Strukturen aus der
*   Tabelle /ADESSO/MDC_RAED
***************************************************************************************************
    FIELD-SYMBOLS: <rs_cust_raid> TYPE /adesso/mdc_s_raid,
                   <rs_cust_raed> TYPE /adesso/mdc_s_raed.

    IF gt_cust_raid IS INITIAL.
      SELECT * FROM /adesso/mdc_raid INTO TABLE gt_cust_raid ORDER BY valid_from DESCENDING.
    ENDIF.

    IF gt_cust_raed IS INITIAL.
      SELECT * FROM /adesso/mdc_raed INTO TABLE gt_cust_raed ORDER BY valid_from DESCENDING.
    ENDIF.

    LOOP AT gt_cust_raid ASSIGNING <rs_cust_raid> WHERE edifact_structur = iv_edifact_structur AND valid_from < iv_keydate.
      EXIT.
    ENDLOOP.
    IF sy-subrc <> 0.
      SORT gt_cust_raed BY valid_from DESCENDING.
      LOOP AT gt_cust_raed ASSIGNING <rs_cust_raed> WHERE edifact_structur_add = iv_edifact_structur AND valid_from < iv_keydate.
        LOOP AT gt_cust_raid ASSIGNING <rs_cust_raid> WHERE edifact_structur = <rs_cust_raed>-edifact_structur AND valid_from < iv_keydate.
          EXIT.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
    IF <rs_cust_raid> IS ASSIGNED.
      rs_cust_raid = <rs_cust_raid>.
    ELSE.
      MESSAGE e001(/adesso/mdc_cust) WITH iv_edifact_structur '/ADESSO/MDC_RAID' INTO gv_mtext.
      /idxgc/cx_general=>raise_exception_from_msg( )..
    ENDIF.
  ENDMETHOD.


  METHOD get_send_delay.
***************************************************************************************************
* THIMEL-R, 20170704, SDÄ auf Common Layer Engine
*    Ermitteln, die Verzögerung einer Stammdatenänderung
*    Suche erst spezielle Bedingungen für den Marktpartner, danach allgemeine für alle.
***************************************************************************************************
    DATA: lv_is_sp_in_mpgr TYPE abap_bool,
          lv_mp_group_no   TYPE /adesso/mdc_mp_group_no,
          lv_servprov      TYPE e_dexservprov.

    FIELD-SYMBOLS: <fs_cust_snd>  TYPE /adesso/mdc_s_snd,
                   <fs_cust_snda> TYPE /adesso/mdc_s_snda.

    IF gt_cust_snd IS INITIAL.
      SELECT * FROM /adesso/mdc_snd INTO TABLE gt_cust_snd ORDER BY valid_from DESCENDING.
    ENDIF.

    IF gt_cust_snda IS INITIAL.
      SELECT * FROM /adesso/mdc_snda INTO TABLE gt_cust_snda ORDER BY valid_from DESCENDING.
    ENDIF.

    LOOP AT gt_cust_snd ASSIGNING <fs_cust_snd> WHERE edifact_structur = iv_edifact_structur AND valid_from < iv_keydate.
      "Suche nach speziellen Einträgen zum Marktpartner
      LOOP AT gt_cust_snda ASSIGNING <fs_cust_snda> WHERE edifact_structur = iv_edifact_structur AND valid_from = <fs_cust_snd>-valid_from.
        IF is_servprov_in_mpgr( iv_mp_group_no = <fs_cust_snda>-mp_group_no iv_assoc_servprov = iv_assoc_servprov ) = abap_true.
          rv_send_delay = <fs_cust_snda>-send_delay.
          RETURN.
        ENDIF.
      ENDLOOP.
      rv_send_delay = <fs_cust_snd>-send_delay.
      EXIT.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_send_flag.
***************************************************************************************************
* THIMEL-R, 20150726, SDÄ auf Common Layer Engine
*    Ermitteln, ob für den Marktpartner eine Stammdatenänderung versendet werden soll.
*    Suche erst spezielle Bedingungen für den Marktpartner, danach allgemeine für alle.
***************************************************************************************************
    DATA: lv_is_sp_in_mpgr TYPE abap_bool,
          lv_mp_group_no   TYPE /adesso/mdc_mp_group_no,
          lv_servprov      TYPE e_dexservprov.

    FIELD-SYMBOLS: <fs_cust_snd>  TYPE /adesso/mdc_s_snd,
                   <fs_cust_snda> TYPE /adesso/mdc_s_snda.

    IF gt_cust_snd IS INITIAL.
      SELECT * FROM /adesso/mdc_snd INTO TABLE gt_cust_snd ORDER BY valid_from DESCENDING.
    ENDIF.

    IF gt_cust_snda IS INITIAL.
      SELECT * FROM /adesso/mdc_snda INTO TABLE gt_cust_snda ORDER BY valid_from DESCENDING.
    ENDIF.

    LOOP AT gt_cust_snd ASSIGNING <fs_cust_snd> WHERE edifact_structur = iv_edifact_structur AND valid_from < iv_keydate.
      "Suche nach speziellen Einträgen zum Marktpartner
      LOOP AT gt_cust_snda ASSIGNING <fs_cust_snda> WHERE edifact_structur = iv_edifact_structur AND valid_from = <fs_cust_snd>-valid_from.
        IF is_servprov_in_mpgr( iv_mp_group_no = <fs_cust_snda>-mp_group_no iv_assoc_servprov = iv_assoc_servprov ) = abap_true.
          rv_flag_send = <fs_cust_snda>-send.
          RETURN.
        ENDIF.
      ENDLOOP.
      rv_flag_send = <fs_cust_snd>-send.
      EXIT.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_single_pdoc_edifact_map.
    IF gt_cust_pdoc IS INITIAL.
      SELECT * FROM /adesso/mdc_pdoc INTO TABLE gt_cust_pdoc.
    ENDIF.

    READ TABLE gt_cust_pdoc INTO rs_cust_pdoc WITH KEY edifact_structur = iv_edifact_structur.
    IF sy-subrc <> 0.
      MESSAGE e001(/adesso/mdc_cust) WITH '/ADESSO/MDC_PDOC' INTO gv_mtext.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


      METHOD get_start_amid.
***************************************************************************************************
* THIMEL-R, 20150726, SDÄ auf Common Layer Engine
*    Ermittlung der Start-AMID. Besonderheit: Im Netz wird auch ohne Empfänger eine AMID zurück-
*    gegeben. Ggf. ist diese nicht eindeutig, ermöglicht aber eine Gruppierung.
***************************************************************************************************
        DATA: ls_cust_raid TYPE /adesso/mdc_raid.

        ls_cust_raid = /adesso/cl_mdc_customizing=>get_roles_amids( iv_edifact_structur = iv_edifact_structur ).

        IF iv_sender_intcode = /idxgc/if_constants=>gc_service_code_dso.
          IF iv_receiver_intcode = /idxgc/if_constants=>gc_service_code_supplier.
            IF iv_flag_receiver_future = abap_false OR ls_cust_raid-supplier_future_role IS NOT INITIAL.
              rv_amid = ls_cust_raid-distributor_amid_supplier.
            ENDIF.
          ELSEIF iv_receiver_intcode = /adesso/if_mdc_co=>gc_intcode_m1.
            IF iv_flag_receiver_future = abap_false.
              rv_amid = ls_cust_raid-distributor_amid_mos.
            ENDIF.
          ELSE. "Ohne Empfänger: 1) Lieferant, 2) MSB, 2) MDL
            IF ls_cust_raid-distributor_amid_supplier IS NOT INITIAL.
              rv_amid = ls_cust_raid-distributor_amid_supplier.
            ELSEIF ls_cust_raid-distributor_amid_mos IS NOT INITIAL.
              rv_amid = ls_cust_raid-distributor_amid_mos.
            ENDIF.
          ENDIF.
        ELSEIF iv_sender_intcode = /idxgc/if_constants=>gc_service_code_supplier.
          IF iv_flag_sender_future = abap_false OR ls_cust_raid-supplier_future_role IS NOT INITIAL.
            rv_amid = ls_cust_raid-supplier_amid.
          ENDIF.
        ELSEIF iv_sender_intcode = /adesso/if_mdc_co=>gc_intcode_m1.
          IF iv_flag_sender_future = abap_false.
            rv_amid = ls_cust_raid-mos_amid.
          ENDIF.
        ENDIF.

        IF rv_amid IS INITIAL.
          MESSAGE e005(/adesso/mdc_cust) WITH iv_edifact_structur iv_sender_intcode iv_receiver_intcode INTO gv_mtext.
          /idxgc/cx_general=>raise_exception_from_msg( ).
        ENDIF.

      ENDMETHOD.


  METHOD get_sub_edifact_structur.
    FIELD-SYMBOLS: <rs_cust_raed> TYPE /adesso/mdc_s_raed.

    IF gt_cust_raed IS INITIAL.
      SELECT * FROM /adesso/mdc_raed INTO TABLE gt_cust_raed ORDER BY valid_from DESCENDING.
    ENDIF.

    LOOP AT gt_cust_raed ASSIGNING <rs_cust_raed> WHERE edifact_structur = iv_edifact_structur AND valid_from < iv_keydate.
      APPEND <rs_cust_raed>-edifact_structur_add TO rt_edifact_structur.
    ENDLOOP.

    IF rt_edifact_structur IS INITIAL.
      MESSAGE e001(/adesso/mdc_cust) WITH iv_edifact_structur '/ADESSO/MDC_RAED' INTO gv_mtext.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD is_servprov_in_mpgr.
***************************************************************************************************
* THIMEL-R, 20151013, SDÄ auf Common Layer Engine
*   Ermitteln, ob für die Marktpartnergruppe eine Stammdatenänderung versendet werden soll.
***************************************************************************************************
    DATA: lv_mp_group_type TYPE /adesso/mdc_mp_group_type.

    FIELD-SYMBOLS: <fs_cust_mpgr> TYPE /adesso/mdc_s_mpgr.

    IF gt_cust_mpgr IS INITIAL.
      SELECT * FROM /adesso/mdc_mpgr INTO TABLE gt_cust_mpgr.
    ENDIF.

    IF gt_cust_mpsp IS INITIAL.
      SELECT * FROM /adesso/mdc_mpsp INTO TABLE gt_cust_mpsp.
    ENDIF.

    READ TABLE gt_cust_mpgr ASSIGNING <fs_cust_mpgr> WITH KEY mp_group_no = iv_mp_group_no.
    IF <fs_cust_mpgr> IS ASSIGNED.
      IF <fs_cust_mpgr>-mp_group_type = /adesso/if_mdc_co=>gc_mp_group_type_include.
        READ TABLE gt_cust_mpsp TRANSPORTING NO FIELDS WITH KEY mp_group_no = iv_mp_group_no servprov = iv_assoc_servprov.
        IF sy-subrc = 0.
          rv_sp_is_in_mpgr = abap_true.
        ELSE.
          rv_sp_is_in_mpgr = abap_false.
        ENDIF.
      ELSEIF <fs_cust_mpgr>-mp_group_type = /adesso/if_mdc_co=>gc_mp_group_type_exclude.
        READ TABLE gt_cust_mpsp TRANSPORTING NO FIELDS WITH KEY mp_group_no = iv_mp_group_no servprov = iv_assoc_servprov.
        IF sy-subrc = 0.
          rv_sp_is_in_mpgr = abap_false.
        ELSE.
          rv_sp_is_in_mpgr = abap_true.
        ENDIF.
      ENDIF.
    ELSE.
      MESSAGE e001(/adesso/mdc_cust) WITH '/ADESSO/MDC_MPGR' INTO gv_mtext.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
