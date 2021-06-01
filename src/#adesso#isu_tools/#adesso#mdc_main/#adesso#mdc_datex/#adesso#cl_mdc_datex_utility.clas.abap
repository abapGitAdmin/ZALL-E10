class /ADESSO/CL_MDC_DATEX_UTILITY definition
  public
  final
  create public .

public section.

  class-methods ADD_AMID_TO_PROC_STEP_DATA
    changing
      !CS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA
    raising
      /IDXGC/CX_GENERAL .
  class-methods ADD_SERVPROVS_TO_PROC_DATA
    changing
      !CS_PROC_DATA type /IDXGC/S_PROC_DATA
    raising
      /IDXGC/CX_GENERAL .
  class-methods ADD_SERVPROVS_AND_BMID
    changing
      !CS_PROC_DATA type /IDXGC/S_PROC_DATA
    raising
      /IDXGC/CX_GENERAL .
  class-methods CONDENSE_PROC_STEP_DATA
    changing
      !CT_PROC_STEP_DATA type /IDXGC/T_PROC_STEP_DATA
    raising
      /IDXGC/CX_GENERAL .
  class-methods CREATE_ERROR_PDOC
    importing
      !IS_PROC_DATA type /IDXGC/S_PROC_DATA
      !IT_MESSAGE type TISU00_MESSAGE
    raising
      /IDXGC/CX_GENERAL .
  class-methods DISABLE_DATEX
    importing
      !IV_INT_UI type INT_UI optional .
  class-methods ENABLE_DATEX
    importing
      !IV_INT_UI type INT_UI optional .
  class-methods ENHANCE_PROC_DATA
    importing
      !IV_PARTNER type BU_PARTNER optional
    changing
      !CS_PROC_DATA type /IDXGC/S_PROC_DATA
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_BMID
    importing
      !IV_SENDER_INTCODE type INTCODE
      !IV_RECEIVER_INTCODE type INTCODE
      !IV_RESPONSIBLE_INTCODE type INTCODE
      !IV_FLAG_SENDER_FUTURE type FLAG optional
      !IV_FLAG_RECEIVER_FUTURE type FLAG optional
      !IV_FLAG_TOOK_OVER_ROLE_RESP type FLAG optional
      !IS_PROC_DATA type /IDXGC/S_PROC_DATA
    returning
      value(RV_BMID) type /IDXGC/DE_BMID
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_SEND_FLAG_FROM_CUSTOMIZING
    importing
      !IS_PROC_DATA type /IDXGC/S_PROC_DATA
    returning
      value(RV_FLAG_SEND) type /ADESSO/MDC_FLAG_SEND
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_SEND_FLAG_FROM_DATEX
    importing
      !IV_INT_UI type INT_UI
    returning
      value(RT_FLAG_SEND) type /ADESSO/MDC_FLAG_SEND
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_PROC_DATA_PARTNER
    importing
      !IS_OLD_DATA type ISU01_PARTNER_DATA
      !IS_NEW_DATA type ISU01_PARTNER_DATA
      !IS_BP_CRM_DATA type BUS_EI_COM_EXTERN optional
      !IV_BP_ID type BU_PARTNER optional
    returning
      value(RT_PROC_DATA) type /IDXGC/T_PROC_DATA
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_PROC_DATA_ACCOUNT
    importing
      !IT_FKKVKP_NEW type ISU_FKKVKP_TAB
      !IT_FKKVKP_OLD type ISU_FKKVKP_TAB
      value(IV_ACCOUNT_HOLDER) type FKKVKP-GPART
    returning
      value(RT_PROC_DATA) type /IDXGC/T_PROC_DATA
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_PROC_DATA_BILLINGINST
    importing
      !IS_CHANGED_DATA type ISUID_BILLINGINST_CHANGED
      !IS_OLD_DATA type ISUID_BILLINGINST_CHANGED
    returning
      value(RT_PROC_DATA) type /IDXGC/T_PROC_DATA
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_PROC_DATA_COADDR
    importing
      !IV_ADDR_REF type ISU02_ADDRESS-ADDR_REF
      !IS_ADDR1_VAL_NEW type ADDR1_VAL
      !IS_ADDR1_VAL_OLD type ADDR1_VAL
    returning
      value(RT_PROC_DATA) type /IDXGC/T_PROC_DATA
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_PROC_DATA_CONTRACT
    importing
      !IS_EVER_OLD type EVER
      !IS_EVER_NEW type EVER
    returning
      value(RT_PROC_DATA) type /IDXGC/T_PROC_DATA
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_PROC_DATA_INSTFACTS
    importing
      !IT_NEW_FACTS type ISU_IETTIF
      !IT_OLD_FACTS type ISU_IETTIF
    returning
      value(RT_PROC_DATA) type /IDXGC/T_PROC_DATA
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_PROC_DATA_INSTLN
    importing
      !IS_CHANGED_DATA type ISU01_INSTLN_CHANGED_DATA
    returning
      value(RT_PROC_DATA) type /IDXGC/T_PROC_DATA
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_PROC_DATA_LPASS
    importing
      !IS_OLD_DATA type ISULP_LPASSLIST_DATA
      !IS_NEW_DATA type ISULP_LPASSLIST_DATA
    returning
      value(RT_PROC_DATA) type /IDXGC/T_PROC_DATA
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_PROC_DATA_NBSERVICE
    importing
      !IS_ESERVICE_OLD type ESERVICE
      !IS_ESERVICE_NEW type ESERVICE
      !IV_UPD_MODE type DAMODUS
    returning
      value(RT_PROC_DATA) type /IDXGC/T_PROC_DATA
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_PROC_DATA_POD
    importing
      !IS_OLD_DATA type EUI_DATEX_DATA
      !IS_NEW_DATA type EUI_DATEX_DATA
    returning
      value(RT_PROC_DATA) type /IDXGC/T_PROC_DATA
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_PROC_DATA_PREMISE
    importing
      !IS_CHANGED_DATA type PREMISE_CHANGED_DATA
    returning
      value(RT_PROC_DATA) type /IDXGC/T_PROC_DATA
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_PROC_DATA_USAGEINFO
    importing
      !IS_BILL_DOC type ISU2A_BILL_DOC
      !IS_DATA_COLLECTOR type ISU2A_DATA_COLLECTOR
      !IS_BILLING_DATA type ISU2A_BILLING_DATA
      !IT_USAGE type ISU2A_IUSAGE
    returning
      value(RT_PROC_DATA) type /IDXGC/T_PROC_DATA
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_TRANSREASON_FROM_BMID
    importing
      !IV_BMID type /IDXGC/DE_BMID
    returning
      value(RV_MSGTRANSREASON) type /IDXGC/DE_MSGTRANSREASON .
  class-methods UPDATE_MTD_CODE_RESULT
    changing
      !CS_PROC_DATA type /IDXGC/S_PROC_DATA
    raising
      /IDXGC/CX_GENERAL .
  PROTECTED SECTION.

    CLASS-DATA gr_previous TYPE REF TO cx_root .
    CLASS-DATA gv_mtext TYPE string .
  PRIVATE SECTION.
ENDCLASS.



CLASS /ADESSO/CL_MDC_DATEX_UTILITY IMPLEMENTATION.


  METHOD add_amid_to_proc_step_data.
***************************************************************************************************
* SOMBERG-J, 20150805, SDÄ auf Common Layer Engine
*   Schreibt den Anwendungsnachrichtenschlüssel AMID in die Prozessschritte des PDOCS
***************************************************************************************************

    DATA: gr_previous         TYPE REF TO cx_root,
          lv_start_amid       TYPE /idxgc/de_amid,
          ls_amid_details     TYPE /idxgc/s_amid_details,
          lv_own_intcode      TYPE /adesso/mdc_intcode,
          lv_receiver_intcode TYPE /adesso/mdc_intcode,
          lt_edifact_str      TYPE /adesso/mdc_t_edifact_str.

    FIELD-SYMBOLS: <fs_edifact_str>  TYPE /idxgc/de_edifact_str.

***** 1. Änderungen aus Schrittdaten lesen und INTCODEs ermitteln *********************************
    lv_own_intcode = /adesso/cl_mdc_customizing=>get_own_intcode( ).
    IF cs_proc_step_data-assoc_servprov IS NOT INITIAL.
      lv_receiver_intcode = /adesso/cl_mdc_utility=>get_intcode_servprov( iv_serviceid = cs_proc_step_data-assoc_servprov ).
    ENDIF.
    lt_edifact_str = /adesso/cl_mdc_utility=>get_changes_as_edifact_str( is_proc_step_data = cs_proc_step_data ).

***** 2. Loop über EDIFACT-Strukturen und AMID ermitteln ******************************************
    LOOP AT lt_edifact_str ASSIGNING <fs_edifact_str>.
      lv_start_amid = /adesso/cl_mdc_customizing=>get_start_amid( iv_edifact_structur = <fs_edifact_str>
        iv_sender_intcode = lv_own_intcode iv_receiver_intcode = lv_receiver_intcode ).
      AT FIRST.
        ls_amid_details-item_id = 1.
        ls_amid_details-amid = lv_start_amid.
        CONTINUE.
      ENDAT.

      IF ls_amid_details-amid <> lv_start_amid.
        MESSAGE e014(/adesso/mdc_datex) INTO gv_mtext.
        /idxgc/cx_general=>raise_exception_from_msg( ).
      ENDIF.
    ENDLOOP.

***** 3. Ergebnis in Schrittdaten schreiben. ******************************************************
    CLEAR cs_proc_step_data-amid.
    APPEND ls_amid_details TO cs_proc_step_data-amid.

  ENDMETHOD.


  METHOD add_servprovs_and_bmid.
***************************************************************************************************
* THIMEL-R, 20150726, SDÄ auf Common Layer Engine
*    Ersten Empfänger ermitteln und alle weiteren Empfänger in Schrittdaten schreiben. Falls der
*    Netzbetreiber nur die Rolle Berechtigter hat, dann muss zuerst der Verantwortliche bestimmt
*    werden.
***************************************************************************************************
    DATA: gr_previous                 TYPE REF TO cx_root,
          lt_serviceprovider          TYPE /idxgc/t_servprov_details,
          lt_edifact_structur         TYPE /adesso/mdc_t_edifact_str,
          lv_own_intcode              TYPE /adesso/mdc_intcode,
          lv_responsible_intcode      TYPE /adesso/mdc_intcode,
          lv_start_amid               TYPE /idxgc/de_amid,
          lv_flag_took_over_role_resp TYPE flag,
          lv_flag_sender_future       TYPE flag.

    FIELD-SYMBOLS: <fs_proc_step_data>  TYPE /idxgc/s_proc_step_data,
                   <fs_serviceprovider> TYPE /idxgc/s_servprov_details.

***** 1. Initialisierung von Hilfsstrukturen ******************************************************
    lt_serviceprovider = /adesso/cl_mdc_utility=>get_servprovs_for_pod( iv_int_ui = cs_proc_data-int_ui iv_keydate = cs_proc_data-proc_date ).
    READ TABLE cs_proc_data-steps ASSIGNING <fs_proc_step_data> INDEX 1.
    lt_edifact_structur = /adesso/cl_mdc_utility=>get_changes_as_edifact_str( is_proc_step_data = <fs_proc_step_data> ).
    lv_own_intcode = /adesso/cl_mdc_customizing=>get_own_intcode( ).

***** 2. Sender ermitteln *************************************************************************
    LOOP AT lt_serviceprovider ASSIGNING <fs_serviceprovider> WHERE service_cat = lv_own_intcode AND is_new = abap_false.
      <fs_proc_step_data>-own_servprov = <fs_serviceprovider>-service_id.
      DELETE lt_serviceprovider.
    ENDLOOP.

***** 3. Ersten Empfänger ermitteln ***************************************************************
*---- 3.1 Vertrieb: Einziger Empfänger ist der Netzbetreiber (ggf. mehrere falls Wechsel) ---------
    IF lv_own_intcode = /idxgc/if_constants=>gc_service_code_supplier.
      "Im Vertrieb immer an den Netzbetreiber schicken. Aktuelle zuerst prüfen, dann neue NB.
      LOOP AT lt_serviceprovider ASSIGNING <fs_serviceprovider>
        WHERE service_cat = /idxgc/if_constants=>gc_service_code_dso AND is_new = abap_false.
        IF <fs_serviceprovider>-date_from > sy-datum.
          lv_flag_sender_future = abap_true.
        ELSE.
          lv_flag_sender_future = abap_false.
        ENDIF.
        <fs_proc_step_data>-bmid = /adesso/cl_mdc_datex_utility=>get_bmid(
          iv_sender_intcode           = lv_own_intcode
          iv_receiver_intcode         = <fs_serviceprovider>-service_cat
          iv_responsible_intcode      = lv_responsible_intcode
          iv_flag_sender_future       = lv_flag_sender_future
          iv_flag_took_over_role_resp = lv_flag_took_over_role_resp
          is_proc_data                = cs_proc_data ).
        IF <fs_proc_step_data>-bmid IS NOT INITIAL.
          <fs_proc_step_data>-assoc_servprov = <fs_serviceprovider>-service_id.
          DELETE lt_serviceprovider.
          EXIT.
        ENDIF.
      ENDLOOP.
      IF <fs_proc_step_data>-assoc_servprov IS INITIAL.
        LOOP AT lt_serviceprovider ASSIGNING <fs_serviceprovider>
          WHERE service_cat = /idxgc/if_constants=>gc_service_code_dso AND is_new = abap_true.
          IF <fs_serviceprovider>-date_from > sy-datum.
            lv_flag_sender_future = abap_true.
          ELSE.
            lv_flag_sender_future = abap_false.
          ENDIF.
          <fs_proc_step_data>-bmid = /adesso/cl_mdc_datex_utility=>get_bmid(
            iv_sender_intcode           = lv_own_intcode
            iv_receiver_intcode         = <fs_serviceprovider>-service_cat
            iv_responsible_intcode      = lv_responsible_intcode
            iv_flag_sender_future       = lv_flag_sender_future
            iv_flag_took_over_role_resp = lv_flag_took_over_role_resp
            is_proc_data                = cs_proc_data ).
          IF <fs_proc_step_data>-bmid IS NOT INITIAL.
            <fs_proc_step_data>-assoc_servprov = <fs_serviceprovider>-service_id.
            DELETE lt_serviceprovider.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ELSEIF lv_own_intcode = /idxgc/if_constants=>gc_service_code_dso.
*---- 3.2 Netz: Mehrere Empfänger möglich, zuerst einen auswählen ---------------------------------
*.... 3.2.1 Eigene Rolle bestimmen ................................................................

      lv_responsible_intcode = /adesso/cl_mdc_customizing=>get_intcode_responsible( it_edifact_structur = lt_edifact_structur ).

      IF lv_responsible_intcode <> lv_own_intcode.
*>>> THIMEL.R, 20151117, Logik passte nicht wenn nur der Lieferant am VSZ hängt.
        "Prüfen ob der Verantwortliche ein eigener Serviceanbieter ist, dann wird direkt die Verteilung gestartet
        LOOP AT lt_serviceprovider ASSIGNING <fs_serviceprovider> WHERE service_cat = lv_responsible_intcode AND is_new = abap_false.
          IF <fs_serviceprovider>-own_service = abap_true.
            lv_flag_took_over_role_resp = abap_true.
          ENDIF.
        ENDLOOP.
        "Wenn verantwortlicher Serviceanbieter gar nicht im VSZ hinterlegt ist, dann immer die Rolle Verantwortlicher übernehmen.
        IF sy-subrc <> 0.
          lv_flag_took_over_role_resp = abap_true.
        ENDIF.
*<<< THIMEL.R, 20151117
      ENDIF.
*.... 3.2.2 Eigene Rolle Berechtigter > Nachricht an Verantwortlichen .............................
      IF lv_own_intcode <> lv_responsible_intcode AND lv_flag_took_over_role_resp = abap_false.
        LOOP AT lt_serviceprovider ASSIGNING <fs_serviceprovider>
          WHERE service_cat = lv_responsible_intcode AND is_new = abap_false.
          <fs_proc_step_data>-bmid = /adesso/cl_mdc_datex_utility=>get_bmid(
            iv_sender_intcode           = lv_own_intcode
            iv_receiver_intcode         = <fs_serviceprovider>-service_cat
            iv_responsible_intcode      = lv_responsible_intcode
            iv_flag_receiver_future     = <fs_serviceprovider>-is_new
            is_proc_data                = cs_proc_data ).
          IF <fs_proc_step_data>-bmid IS NOT INITIAL.
            <fs_proc_step_data>-assoc_servprov = <fs_serviceprovider>-service_id.
            DELETE lt_serviceprovider.
            EXIT.
          ENDIF.
        ENDLOOP.
        IF <fs_proc_step_data>-assoc_servprov IS INITIAL.
          LOOP AT lt_serviceprovider ASSIGNING <fs_serviceprovider>
            WHERE service_cat = lv_responsible_intcode AND is_new = abap_true.
            <fs_proc_step_data>-bmid = /adesso/cl_mdc_datex_utility=>get_bmid(
              iv_sender_intcode           = lv_own_intcode
              iv_receiver_intcode         = <fs_serviceprovider>-service_cat
              iv_responsible_intcode      = lv_responsible_intcode
              iv_flag_receiver_future     = <fs_serviceprovider>-is_new
              is_proc_data                = cs_proc_data ).
            IF <fs_proc_step_data>-bmid IS NOT INITIAL.
              <fs_proc_step_data>-assoc_servprov = <fs_serviceprovider>-service_id.
              DELETE lt_serviceprovider.
              EXIT.
            ENDIF.
          ENDLOOP.
        ENDIF.
*.... 3.2.3 Eigene Rolle Verantwortlicher > Verteilung ............................................
      ELSE.
        "Reihenfolge der Suche nach erstem Empfänger: Lieferant(aktuell), Lieferant(neu), MSB(aktuell), MDL(aktuell), MDL(neu)
        LOOP AT lt_serviceprovider ASSIGNING <fs_serviceprovider> "Lieferant(aktuell)
          WHERE service_cat = /idxgc/if_constants=>gc_service_code_supplier AND is_new = abap_false.
          <fs_proc_step_data>-bmid = /adesso/cl_mdc_datex_utility=>get_bmid(
            iv_sender_intcode           = lv_own_intcode
            iv_receiver_intcode         = <fs_serviceprovider>-service_cat
            iv_responsible_intcode      = lv_responsible_intcode
            iv_flag_receiver_future     = <fs_serviceprovider>-is_new
            iv_flag_took_over_role_resp = lv_flag_took_over_role_resp
            is_proc_data                = cs_proc_data ).
          IF <fs_proc_step_data>-bmid IS NOT INITIAL.
            <fs_proc_step_data>-assoc_servprov = <fs_serviceprovider>-service_id.
            DELETE lt_serviceprovider.
            EXIT.
          ENDIF.
        ENDLOOP.
        IF <fs_proc_step_data>-assoc_servprov IS INITIAL. "Lieferant(neu)
          LOOP AT lt_serviceprovider ASSIGNING <fs_serviceprovider>
            WHERE service_cat = /idxgc/if_constants=>gc_service_code_supplier AND is_new = abap_true.
            <fs_proc_step_data>-bmid = /adesso/cl_mdc_datex_utility=>get_bmid(
              iv_sender_intcode           = lv_own_intcode
              iv_receiver_intcode         = <fs_serviceprovider>-service_cat
              iv_responsible_intcode      = lv_responsible_intcode
              iv_flag_receiver_future     = <fs_serviceprovider>-is_new
              iv_flag_took_over_role_resp = lv_flag_took_over_role_resp
              is_proc_data                = cs_proc_data ).
            IF <fs_proc_step_data>-bmid IS NOT INITIAL.
              <fs_proc_step_data>-assoc_servprov = <fs_serviceprovider>-service_id.
              DELETE lt_serviceprovider.
              EXIT.
            ENDIF.
          ENDLOOP.
        ENDIF.
        IF <fs_proc_step_data>-assoc_servprov IS INITIAL. "MSB(aktuell)
          LOOP AT lt_serviceprovider ASSIGNING <fs_serviceprovider>
            WHERE service_cat = /adesso/if_mdc_co=>gc_intcode_m1 AND is_new = abap_false.
            <fs_proc_step_data>-bmid = /adesso/cl_mdc_datex_utility=>get_bmid(
              iv_sender_intcode           = lv_own_intcode
              iv_receiver_intcode         = <fs_serviceprovider>-service_cat
              iv_responsible_intcode      = lv_responsible_intcode
              iv_flag_receiver_future     = <fs_serviceprovider>-is_new
              iv_flag_took_over_role_resp = lv_flag_took_over_role_resp
              is_proc_data                = cs_proc_data ).
            IF <fs_proc_step_data>-bmid IS NOT INITIAL.
              <fs_proc_step_data>-assoc_servprov = <fs_serviceprovider>-service_id.
              DELETE lt_serviceprovider.
              EXIT.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.

*.... 3.2.4. Übrige fremde Empfänger an die Schrittdaten schreiben als NB .........................
      DELETE lt_serviceprovider WHERE own_service = abap_true.
      LOOP AT lt_serviceprovider ASSIGNING <fs_serviceprovider>.
        "BMID temporär in CONTRACT_REF speichern
        <fs_serviceprovider>-contract_ref = /adesso/cl_mdc_datex_utility=>get_bmid(
          iv_sender_intcode           = lv_own_intcode
          iv_receiver_intcode         = <fs_serviceprovider>-service_cat
          iv_responsible_intcode      = lv_responsible_intcode
          iv_flag_receiver_future     = <fs_serviceprovider>-is_new
          iv_flag_took_over_role_resp = lv_flag_took_over_role_resp
          is_proc_data                = cs_proc_data ).
        IF <fs_serviceprovider>-contract_ref IS NOT INITIAL AND <fs_proc_step_data>-bmid CS 'CH1'.
          APPEND <fs_serviceprovider> TO <fs_proc_step_data>-serviceprovider.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD add_servprovs_to_proc_data.
***************************************************************************************************
* THIMEL-R, 20150726, SDÄ auf Common Layer Engine
*    Ersten Empfänger ermitteln und alle weiteren Empfänger in Schrittdaten schreiben. Falls der
*    Netzbetreiber nur die Rolle Berechtigter hat, dann muss zuerst der Verantwortliche bestimmt
*    werden.
***************************************************************************************************
    DATA: gr_previous            TYPE REF TO cx_root,
          lt_servprov_details    TYPE /idxgc/t_servprov_details,
          lt_edifact_structur    TYPE /adesso/mdc_t_edifact_str,
          ls_own_servprov        TYPE /idxgc/s_servprov_details,
          ls_assoc_servprov      TYPE /idxgc/s_servprov_details,
          lv_own_intcode         TYPE /adesso/mdc_intcode,
          lv_intcode_responsible TYPE /adesso/mdc_intcode.

    FIELD-SYMBOLS: <fs_proc_step_data>   TYPE /idxgc/s_proc_step_data,
                   <fs_servprov_details> TYPE /idxgc/s_servprov_details.

***** 1. Initialisierung von Hilfsstrukturen ******************************************************
    lt_servprov_details = /adesso/cl_mdc_utility=>get_servprovs_for_pod( iv_int_ui = cs_proc_data-int_ui iv_keydate = cs_proc_data-proc_date ).
    READ TABLE cs_proc_data-steps ASSIGNING <fs_proc_step_data> INDEX 1.
    lt_edifact_structur = /adesso/cl_mdc_utility=>get_changes_as_edifact_str( is_proc_step_data = <fs_proc_step_data> ).
    lv_own_intcode = /adesso/cl_mdc_customizing=>get_own_intcode( ).

***** 2. Sender ermitteln *************************************************************************
    LOOP AT lt_servprov_details ASSIGNING <fs_servprov_details> WHERE service_cat = lv_own_intcode AND is_new = abap_false.
      <fs_proc_step_data>-own_servprov = <fs_servprov_details>-service_id.
      DELETE lt_servprov_details.
    ENDLOOP.

***** 3. Ersten Empfänger ermitteln ***************************************************************
*---- 3.1 Vertrieb: Einziger Empfänger ist der Netzbetreiber (ggf. mehrere falls Wechsel) ---------
    IF lv_own_intcode = /idxgc/if_constants=>gc_service_code_supplier.
      "Im Vertrieb immer an den Netzbetreiber schicken. Aktuelle zuerst prüfen, dann neue NB.
      LOOP AT lt_servprov_details ASSIGNING <fs_servprov_details>
        WHERE service_cat = /idxgc/if_constants=>gc_service_code_dso AND is_new = abap_false.
        <fs_proc_step_data>-assoc_servprov = <fs_servprov_details>-service_id.
        DELETE lt_servprov_details.
      ENDLOOP.
      IF <fs_proc_step_data>-assoc_servprov IS INITIAL.
        LOOP AT lt_servprov_details ASSIGNING <fs_servprov_details>
          WHERE service_cat = /idxgc/if_constants=>gc_service_code_dso AND is_new = abap_true.
          <fs_proc_step_data>-assoc_servprov = <fs_servprov_details>-service_id.
          DELETE lt_servprov_details.
        ENDLOOP.
      ENDIF.
    ELSEIF lv_own_intcode = /idxgc/if_constants=>gc_service_code_dso.
*---- 3.2 Netz: Mehrere Empfänger möglich, zuerst einen auswählen ---------------------------------
*.... 3.2.1 Eigene Rolle bestimmen ................................................................
      lv_intcode_responsible = /adesso/cl_mdc_customizing=>get_intcode_responsible( it_edifact_structur = lt_edifact_structur ).
      IF lv_intcode_responsible <> lv_own_intcode.
        LOOP AT lt_servprov_details ASSIGNING <fs_servprov_details>
          WHERE service_cat = lv_intcode_responsible AND is_new = abap_false AND own_service = abap_true.
          lv_intcode_responsible = lv_own_intcode.
        ENDLOOP.
      ENDIF.
*.... 3.2.2 Eigene Rolle Berechtigter .............................................................
      IF lv_intcode_responsible <> lv_own_intcode.
        LOOP AT lt_servprov_details ASSIGNING <fs_servprov_details>
          WHERE service_cat = lv_intcode_responsible AND is_new = abap_false.
          <fs_proc_step_data>-assoc_servprov = <fs_servprov_details>-service_id.
          DELETE lt_servprov_details.
          EXIT.
        ENDLOOP.
        IF <fs_proc_step_data>-assoc_servprov IS INITIAL.
          LOOP AT lt_servprov_details ASSIGNING <fs_servprov_details>
            WHERE service_cat = lv_intcode_responsible AND is_new = abap_true.
            <fs_proc_step_data>-assoc_servprov = <fs_servprov_details>-service_id.
            DELETE lt_servprov_details.
            EXIT.
          ENDLOOP.
        ENDIF.
*.... 3.2.3 Eigene Rolle Verantwortlicher .........................................................
      ELSE.
        "Reihenfolge der Suche nach erstem Empfänger: Lieferant(aktuell), Lieferant(neu), MSB(aktuell), MDL(aktuell), MDL(neu)
        LOOP AT lt_servprov_details ASSIGNING <fs_servprov_details> "Lieferant(aktuell)
          WHERE service_cat = /idxgc/if_constants=>gc_service_code_supplier AND is_new = abap_false.
          <fs_proc_step_data>-assoc_servprov = <fs_servprov_details>-service_id.
          DELETE lt_servprov_details.
          EXIT.
        ENDLOOP.
        IF <fs_proc_step_data>-assoc_servprov IS INITIAL. "Lieferant(neu)
          LOOP AT lt_servprov_details ASSIGNING <fs_servprov_details>
            WHERE service_cat = /idxgc/if_constants=>gc_service_code_supplier AND is_new = abap_true.
            <fs_proc_step_data>-assoc_servprov = <fs_servprov_details>-service_id.
            DELETE lt_servprov_details.
            EXIT.
          ENDLOOP.
        ENDIF.
        IF <fs_proc_step_data>-assoc_servprov IS INITIAL. "MSB(aktuell)
          LOOP AT lt_servprov_details ASSIGNING <fs_servprov_details>
            WHERE service_cat = /adesso/if_mdc_co=>gc_intcode_m1 AND is_new = abap_false.
            <fs_proc_step_data>-assoc_servprov = <fs_servprov_details>-service_id.
            DELETE lt_servprov_details.
            EXIT.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.

***** 4. Übrige fremde Empfänger an die Schrittdaten schreiben ************************************
    DELETE lt_servprov_details WHERE own_service = abap_true.
    APPEND LINES OF lt_servprov_details TO <fs_proc_step_data>-serviceprovider.

***** 5. Prüfen, ob Sender und Empfänger gefüllt **************************************************
*    IF <fs_proc_step_data>-own_servprov IS INITIAL.
*      MESSAGE e011(/adesso/mdc_datex) INTO gv_mtext.
*      /idxgc/cx_general=>raise_exception_from_msg( ).
*    ENDIF.
*
*    IF <fs_proc_step_data>-assoc_servprov IS INITIAL.
*      MESSAGE e012(/adesso/mdc_datex) INTO gv_mtext.
*      /idxgc/cx_general=>raise_exception_from_msg( ).
*    ENDIF.

  ENDMETHOD.


  METHOD condense_proc_step_data.
***************************************************************************************************
* THIMEL-R, 20150726, SDÄ auf Common Layer Engine
* Die Methode führt Schrittdaten zusammen, wenn die AMID identisch ist.
***************************************************************************************************
    DATA:
      ls_amid_details_01 TYPE /idxgc/s_amid_details,
      ls_amid_details_02 TYPE /idxgc/s_amid_details.

    FIELD-SYMBOLS:
      <fs_proc_step_data_01> TYPE /idxgc/s_proc_step_data,
      <fs_proc_step_data_02> TYPE /idxgc/s_proc_step_data,
      <fs_name_adress_01>    TYPE /idxgc/s_nameaddr_details,
      <fs_name_adress_02>    TYPE /idxgc/s_nameaddr_details,
      <fs_any_field_01>      TYPE any,
      <fs_any_field_02>      TYPE any.


    LOOP AT ct_proc_step_data ASSIGNING <fs_proc_step_data_01>.
      <fs_proc_step_data_01>-proc_ref = /idxgc/if_constants=>gc_temp_indicator.
      CLEAR: ls_amid_details_01.
      READ TABLE <fs_proc_step_data_01>-amid INTO ls_amid_details_01 INDEX 1.

      LOOP AT ct_proc_step_data ASSIGNING <fs_proc_step_data_02> WHERE proc_ref <> <fs_proc_step_data_01>-proc_ref.
        CLEAR: ls_amid_details_02.
        READ TABLE <fs_proc_step_data_02>-amid INTO ls_amid_details_02 INDEX 1.
        IF ls_amid_details_01-amid = ls_amid_details_02-amid.
          "Tabellen übernehmen
          APPEND LINES OF <fs_proc_step_data_02>-mtd_code_result TO <fs_proc_step_data_01>-mtd_code_result.
          SORT.
          DELETE ADJACENT DUPLICATES FROM <fs_proc_step_data_01>-mtd_code_result COMPARING ALL FIELDS.

          APPEND LINES OF <fs_proc_step_data_02>-charges TO <fs_proc_step_data_01>-charges.
          SORT.
          DELETE ADJACENT DUPLICATES FROM <fs_proc_step_data_01>-charges COMPARING ALL FIELDS.

          APPEND LINES OF <fs_proc_step_data_02>-diverse TO <fs_proc_step_data_01>-diverse.
          SORT.
          DELETE ADJACENT DUPLICATES FROM <fs_proc_step_data_01>-diverse COMPARING ALL FIELDS.

          APPEND LINES OF <fs_proc_step_data_02>-marketpartner_add TO <fs_proc_step_data_01>-marketpartner_add.
          SORT.
          DELETE ADJACENT DUPLICATES FROM <fs_proc_step_data_01>-marketpartner_add COMPARING ALL FIELDS.

          APPEND LINES OF <fs_proc_step_data_02>-pod TO <fs_proc_step_data_01>-pod.
          SORT.
          DELETE ADJACENT DUPLICATES FROM <fs_proc_step_data_01>-pod COMPARING ALL FIELDS.

          APPEND LINES OF <fs_proc_step_data_02>-pod_quant TO <fs_proc_step_data_01>-pod_quant.
          SORT.
          DELETE ADJACENT DUPLICATES FROM <fs_proc_step_data_01>-pod_quant COMPARING ALL FIELDS.

          APPEND LINES OF <fs_proc_step_data_02>-reg_code_data TO <fs_proc_step_data_01>-reg_code_data.
          SORT.
          DELETE ADJACENT DUPLICATES FROM <fs_proc_step_data_01>-reg_code_data COMPARING ALL FIELDS.

          APPEND LINES OF <fs_proc_step_data_02>-settl_terr TO <fs_proc_step_data_01>-settl_terr.
          SORT.
          DELETE ADJACENT DUPLICATES FROM <fs_proc_step_data_01>-settl_terr COMPARING ALL FIELDS.

          APPEND LINES OF <fs_proc_step_data_02>-settl_unit TO <fs_proc_step_data_01>-settl_unit.
          SORT.
          DELETE ADJACENT DUPLICATES FROM <fs_proc_step_data_01>-settl_unit COMPARING ALL FIELDS.

          "Sonderbehandlung für NAME_ADDRESS, da hier ggf. Zeilen verschmolzen werden müssen
          LOOP AT <fs_proc_step_data_02>-name_address ASSIGNING <fs_name_adress_02>.
            READ TABLE <fs_proc_step_data_01>-name_address ASSIGNING <fs_name_adress_01>
                                  WITH KEY party_func_qual = <fs_name_adress_02>-party_func_qual.
            IF sy-subrc = 0. "Verschmelzen wenn schon eine Zeile mit dem Qualifier vorhanden
              DO.
                ASSIGN COMPONENT sy-index OF STRUCTURE <fs_name_adress_02> TO <fs_any_field_02>.
                IF <fs_any_field_02> IS ASSIGNED.
                  IF NOT <fs_any_field_02> IS INITIAL.
                    ASSIGN COMPONENT sy-index OF STRUCTURE <fs_name_adress_01> TO <fs_any_field_01>.
                    <fs_any_field_01> = <fs_any_field_02>.
                  ENDIF.
                  UNASSIGN <fs_any_field_02>.
                ELSE.

                  EXIT.
                ENDIF.
              ENDDO.
            ELSE.
              APPEND <fs_name_adress_02> TO <fs_proc_step_data_01>-name_address.
            ENDIF.
          ENDLOOP.

          "Schrittdaten nach Übernahme löschen
          DELETE ct_proc_step_data.
        ENDIF.

      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.


  METHOD create_error_pdoc.
    DATA:
      ls_proc_data       TYPE /idxgc/s_proc_data,
      ls_process_key_all TYPE /idxgc/s_proc_key_all,
      lr_process_data    TYPE REF TO /idxgc/if_process_data_extern,
      gr_previous        TYPE REF TO cx_root.

    FIELD-SYMBOLS:
        <fs_proc_step_data> TYPE /idxgc/s_proc_step_data.

    ls_proc_data = is_proc_data.
    ls_proc_data-proc_id = /idxgc/if_constants=>gc_proc_id_unsl."8900
    READ TABLE ls_proc_data-steps ASSIGNING <fs_proc_step_data> INDEX 1.
    IF sy-subrc <> 0.
      APPEND INITIAL LINE TO ls_proc_data-steps ASSIGNING <fs_proc_step_data>.
    ENDIF.
    <fs_proc_step_data>-proc_step_no = /idxgc/if_pd_wf_constants=>gc_proc_step_no_0801.

    TRY.
        CREATE OBJECT lr_process_data
          TYPE
          /idxgc/cl_process_data
          EXPORTING
            is_process_data = ls_proc_data.

      CATCH /idxgc/cx_general INTO gr_previous.
        /idxgc/cl_utility_service=>/idxgc/if_utility_service~create_error_log_message( ).
        /idxgc/cx_general=>raise_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.

    CALL FUNCTION '/IDXGC/CREATE_ERROR_PDOC'
      EXPORTING
        iv_proc_step_no = /idxgc/if_pd_wf_constants=>gc_proc_step_no_0801
        it_message      = it_message
      CHANGING
        cr_process_data = lr_process_data
      EXCEPTIONS
        create_error    = 1
        config_error    = 2
        check_error     = 3
        OTHERS          = 4.
    IF sy-subrc <> 0.
      /idxgc/cl_utility_service=>/idxgc/if_utility_service~create_error_log_message( ).
      /idxgc/cx_general=>raise_exception_from_msg( ir_previous = gr_previous ).
    ENDIF.

  ENDMETHOD.


  METHOD disable_datex.
    cl_isu_datex_controller=>disable_outgoing_process( x_int_ui = iv_int_ui x_dexbasicproc = /adesso/if_mdc_co=>gc_dexbasicproc_mdc_dummy ).
  ENDMETHOD.


  METHOD enable_datex.
    cl_isu_datex_controller=>disable_outgoing_process( x_enable_communication = abap_true x_int_ui = iv_int_ui x_dexbasicproc = /adesso/if_mdc_co=>gc_dexbasicproc_mdc_dummy ).
  ENDMETHOD.


  METHOD enhance_proc_data.
***************************************************************************************************
* THIMEL-R, 20150901, Methode zum anreichern der Prozessdaten für den Prozessstart
* THIMEL-R, 20160326, Erweiterung um Parameter für den Partner. Der Partner ist in den aufrufenden
*   teilweise schon bekannt. Außerdem kann evtl. der falsche Partner genommen werden, falls das VSZ
*   gerade noch umgebaut wird.
***************************************************************************************************
    DATA: lr_badi_data_access TYPE REF TO /idxgc/badi_data_access,
          gr_previous         TYPE REF TO cx_root,
          lt_partner          TYPE /idxgc/t_partner,
          ls_proc_config_all  TYPE /idxgc/s_proc_config_all,
          ls_ever             TYPE ever.

    FIELD-SYMBOLS: <fs_step>           TYPE /idxgc/s_proc_step_config_all,
                   <fs_proc_step_data> TYPE /idxgc/s_proc_step_data,
                   <fs_amid>           TYPE /idxgc/s_amid_details,
                   <fs_diverse>        TYPE /idxgc/s_diverse_details.

    READ TABLE cs_proc_data-steps ASSIGNING <fs_proc_step_data> INDEX 1.
    IF sy-subrc = 0.
***** Prozess-ID setzen ***************************************************************************
      IF <fs_proc_step_data>-bmid(3) = 'CH1'.
        cs_proc_data-proc_id = /idxgc/if_constants_add=>gc_prod_id_send_mdc_res.
      ELSEIF <fs_proc_step_data>-bmid(3) = 'CH2'.
        cs_proc_data-proc_id = /adesso/if_mdc_co=>gc_proc_id_send_mdc_ath.
      ENDIF.

***** Vertragsbeginn- und Gültigkeitsdatum setzen *************************************************
      READ TABLE <fs_proc_step_data>-diverse ASSIGNING <fs_diverse> INDEX 1.
      IF sy-subrc <> 0.
        APPEND INITIAL LINE TO <fs_proc_step_data>-diverse ASSIGNING <fs_diverse>.
        <fs_diverse>-item_id = 1.
      ENDIF.
      <fs_diverse>-validstart_date = cs_proc_data-proc_date.
      ls_ever = /adesso/cl_mdc_masterdata=>get_ever( iv_int_ui = cs_proc_data-int_ui iv_keydate = cs_proc_data-proc_date ).
      <fs_diverse>-contr_start_date = ls_ever-einzdat.

***** Spartentyp setzen ***************************************************************************
      cs_proc_data-spartyp = /idxgc/cl_utility_service_isu=>get_divcat_from_intui(
        iv_int_ui = cs_proc_data-int_ui iv_proc_date = cs_proc_data-proc_date ).

***** Partner setzen ******************************************************************************
      IF iv_partner IS INITIAL.
        lt_partner = /idxgc/cl_utility_service_isu=>get_partner_from_intui(
          iv_int_ui = cs_proc_data-int_ui iv_key_date = cs_proc_data-proc_date ).
        READ TABLE lt_partner INTO cs_proc_data-bu_partner INDEX 1.
      ELSE.
        cs_proc_data-bu_partner = iv_partner.
      ENDIF.

***** Prozesssicht und Prozesstyp setzen **********************************************************
      /idxgc/cl_cust_access=>/idxgc/if_cust_access~get_process_config(
        EXPORTING iv_process_id = cs_proc_data-proc_id iv_process_date = cs_proc_data-proc_date
        IMPORTING es_process_config = ls_proc_config_all ).
      cs_proc_data-proc_view = ls_proc_config_all-proc_view.
      cs_proc_data-proc_type = ls_proc_config_all-proc_type.

***** Schrittnummer vom ersten Prozessschritt setzen **********************************************
      LOOP AT ls_proc_config_all-steps ASSIGNING <fs_step> WHERE category = /idxgc/if_constants=>gc_proc_step_cat_init.
        <fs_proc_step_data>-proc_step_no = <fs_step>-proc_step_no.
      ENDLOOP.

***** Transaktionsgrund setzen ********************************************************************
      <fs_diverse>-msgtransreason = /adesso/cl_mdc_datex_utility=>get_transreason_from_bmid( iv_bmid = <fs_proc_step_data>-bmid ).
    ENDIF.
  ENDMETHOD.


  METHOD get_bmid.
***************************************************************************************************
* THIMEL-R, 20150913, SDÄ auf Common Layer Engine
*   BMID Ermittlung über AMIDs aus Customizing
***************************************************************************************************
    DATA: lr_badi_data_access   TYPE REF TO /idxgc/badi_data_access,
          ls_proc_data          TYPE /idxgc/s_proc_data,
          lv_start_amid         TYPE /idxgc/de_amid,
          lv_start_amid_as_resp TYPE /idxgc/de_amid,
          lv_edifact_structur   TYPE /idxgc/de_edifact_str.

    FIELD-SYMBOLS: <fs_proc_step_data>  TYPE /idxgc/s_proc_step_data,
                   <fs_mtd_code_result> TYPE /idxgc/s_mtd_code_details,
                   <fs_amid>            TYPE /idxgc/s_amid_details.

***** 1. Initiales Lesen der Schrittdaten *********************************************************
    ls_proc_data = is_proc_data.
    READ TABLE ls_proc_data-steps ASSIGNING <fs_proc_step_data> INDEX 1.
    IF sy-subrc = 0.
      READ TABLE <fs_proc_step_data>-mtd_code_result ASSIGNING <fs_mtd_code_result> INDEX 1.
      lv_edifact_structur = <fs_mtd_code_result>-addinfo.
    ENDIF.

***** 2. AMID aus Customizing lesen ***************************************************************
    TRY.
        IF iv_flag_took_over_role_resp = abap_false.
          lv_start_amid = /adesso/cl_mdc_customizing=>get_start_amid( iv_edifact_structur = lv_edifact_structur
            iv_sender_intcode = iv_sender_intcode iv_receiver_intcode = iv_receiver_intcode
            iv_flag_sender_future = iv_flag_sender_future iv_flag_receiver_future = iv_flag_receiver_future ).
        ELSE.
          lv_start_amid_as_resp = /adesso/cl_mdc_customizing=>get_start_amid( iv_edifact_structur = lv_edifact_structur
            iv_sender_intcode = iv_responsible_intcode iv_receiver_intcode = iv_sender_intcode ).
          lv_start_amid = /adesso/cl_mdc_customizing=>get_forward_amid( iv_amid = lv_start_amid_as_resp iv_receiver_intcode = iv_receiver_intcode ).
        ENDIF.
      CATCH /idxgc/cx_general.
        "Es muss nicht für jede Konstellation eine AMID geben. Ggf. soll ein Marktpartner keine Nachricht erhalten.
        RETURN.
    ENDTRY.

***** 3. BMID ermitteln über BAdI *****************************************************************
    CLEAR <fs_proc_step_data>-amid.
    APPEND INITIAL LINE TO <fs_proc_step_data>-amid ASSIGNING <fs_amid>.
    <fs_amid>-item_id = 1.
    <fs_amid>-amid    = lv_start_amid.

    TRY.
        GET BADI lr_badi_data_access
          FILTERS
            iv_proc_cluster = ''.

        CALL BADI lr_badi_data_access->get_bmid
          EXPORTING
            is_msg_data = ls_proc_data
          IMPORTING
            ev_bmid     = rv_bmid.
      CATCH cx_badi_not_implemented.
        MESSAGE e257(/idxgc/utility_add) WITH /idxgc/if_constants=>gc_badi_data_access INTO gv_mtext.
        /idxgc/cx_general=>raise_exception_from_msg( ).
      CATCH cx_badi_multiply_implemented.
        MESSAGE e258(/idxgc/utility_add) WITH /idxgc/if_constants=>gc_badi_data_access INTO gv_mtext.
        /idxgc/cx_general=>raise_exception_from_msg( ).
      CATCH /idxgc/cx_utility_error.
        RETURN.
    ENDTRY.

  ENDMETHOD.


  METHOD get_proc_data_account.
    DATA: lr_badi_mdc_dtx_account TYPE REF TO /adesso/badi_mdc_dtx_account,
          lt_proc_step_data       TYPE /idxgc/t_proc_step_data,
          ls_proc_step_data_old   TYPE /idxgc/s_proc_step_data.

    FIELD-SYMBOLS: <fs_proc_data>      TYPE /idxgc/s_proc_data,
                   <fs_proc_step_data> TYPE /idxgc/s_proc_step_data.

***** BAdI für kundeneigene Implementierung *******************************************************
    TRY.
        GET BADI lr_badi_mdc_dtx_account
          FILTERS
            mandt = sy-mandt
            sysid = sy-sysid.
      CATCH cx_badi_not_implemented.
        "Das BAdI muss nicht implementiert sein.
    ENDTRY.

    IF lr_badi_mdc_dtx_account IS NOT INITIAL.
      CALL BADI lr_badi_mdc_dtx_account->change_proc_data_account
        EXPORTING
          it_fkkvkp_new     = it_fkkvkp_new
          it_fkkvkp_old     = it_fkkvkp_old
          iv_account_holder = iv_account_holder
        CHANGING
          ct_proc_data      = rt_proc_data.
    ENDIF.

  ENDMETHOD.


  METHOD get_proc_data_billinginst.
    DATA:
      lr_badi_mdc_dtx_billingin TYPE REF TO /adesso/badi_mdc_dtx_billingin,
      lt_proc_step_data         TYPE /idxgc/t_proc_step_data,
      ls_proc_step_data         TYPE /idxgc/s_proc_step_data,
      ls_proc_step_data_new     TYPE /idxgc/s_proc_step_data,
      ls_proc_step_data_old     TYPE /idxgc/s_proc_step_data,
      ls_meter_dev_new          TYPE /idxgc/s_meterdev_details,
      ls_meter_dev_old          TYPE /idxgc/s_meterdev_details,
      ls_reg_code_data_new      TYPE /idxgc/s_reg_code_details,
      ls_reg_code_data_old      TYPE /idxgc/s_reg_code_details,
      ls_etyp                   TYPE etyp,
      lv_keydate                TYPE /idxgc/de_keydate.

    FIELD-SYMBOLS:
      <fs_proc_data>      TYPE /idxgc/s_proc_data,
      <fs_proc_step_data> TYPE /idxgc/s_proc_step_data,
      <fs_inst_rel>       TYPE reg30_dreg_equi_inst_rel,
      <fs_v_eger_new>     TYPE v_eger,
      <fs_v_eger_old>     TYPE v_eger,
      <fs_etdz_new>       TYPE etdz,
      <fs_etdz_old>       TYPE etdz.

    "Nur für Netz
    CHECK /adesso/cl_mdc_customizing=>get_own_intcode( ) = /idxgc/if_constants=>gc_service_code_dso.

***** 1. Daten in Prozessschrittdaten übernehmen und vergleichen **********************************
*---- Geräteeinbau, -ausbau oder -wechsel ---------------------------------------------------------
    CLEAR: ls_proc_step_data_new, ls_proc_step_data_old, ls_meter_dev_new, ls_meter_dev_old.
    LOOP AT is_changed_data-inst_rel_tab ASSIGNING <fs_inst_rel> WHERE action = '03'.
      READ TABLE is_changed_data-eger_tab ASSIGNING <fs_v_eger_new> WITH KEY equnr = <fs_inst_rel>-equnrnew.
      READ TABLE is_changed_data-eger_tab ASSIGNING <fs_v_eger_old> WITH KEY equnr = <fs_inst_rel>-equnrold.
      IF <fs_v_eger_new> IS ASSIGNED AND <fs_v_eger_old> IS ASSIGNED.
        CALL FUNCTION 'ISU_DB_ETYP_SINGLE'
          EXPORTING
            x_matnr      = <fs_v_eger_new>-matnr
          IMPORTING
            y_etyp       = ls_etyp
          EXCEPTIONS
            not_found    = 1
            system_error = 2
            OTHERS       = 3.
        IF sy-subrc <> 0.
          MESSAGE e015(/adesso/mdc_datex) WITH <fs_v_eger_new>-matnr INTO gv_mtext.
          /idxgc/cx_general=>raise_exception_from_msg( ).
        ENDIF.
        ls_meter_dev_new-item_id     = 1.
        ls_meter_dev_new-meternumber = <fs_v_eger_new>-geraet.
        ls_meter_dev_new-metertype_code = ls_etyp-/idexge/met_typ.
        ls_meter_dev_new-metertype_value = ls_etyp-/idexge/schara.
        ls_meter_dev_new-energy_direction = ls_etyp-/idexge/engy_dir.
        ls_meter_dev_new-ratenumber_code = ls_etyp-/idexge/rate_num.
        ls_meter_dev_new-metersize_value = ls_etyp-/idexge/meter_size.

        CALL FUNCTION 'ISU_DB_ETYP_SINGLE'
          EXPORTING
            x_matnr      = <fs_v_eger_old>-matnr
          IMPORTING
            y_etyp       = ls_etyp
          EXCEPTIONS
            not_found    = 1
            system_error = 2
            OTHERS       = 3.
        IF sy-subrc <> 0.
          MESSAGE e015(/adesso/mdc_datex) WITH <fs_v_eger_new>-matnr INTO gv_mtext.
          /idxgc/cx_general=>raise_exception_from_msg( ).
        ENDIF.
        ls_meter_dev_new-item_id     = 1.
        ls_meter_dev_old-meternumber = <fs_v_eger_old>-geraet.
        ls_meter_dev_old-metertype_code = ls_etyp-/idexge/met_typ.
        ls_meter_dev_old-metertype_value = ls_etyp-/idexge/schara.
        ls_meter_dev_old-energy_direction = ls_etyp-/idexge/engy_dir.
        ls_meter_dev_old-ratenumber_code = ls_etyp-/idexge/rate_num.
        ls_meter_dev_old-metersize_value = ls_etyp-/idexge/meter_size.

        APPEND ls_meter_dev_new TO ls_proc_step_data_new-meter_dev.
        APPEND ls_meter_dev_old TO ls_proc_step_data_old-meter_dev.

        ls_proc_step_data-mtd_code_result = /adesso/cl_mdc_utility=>compare_proc_step_data( is_proc_step_data_1 = ls_proc_step_data_old is_proc_step_data_2 = ls_proc_step_data_new ).
        IF ls_proc_step_data-mtd_code_result IS NOT INITIAL.
          APPEND ls_proc_step_data TO lt_proc_step_data.
        ENDIF.
        lv_keydate = <fs_inst_rel>-eadat.
      ENDIF.
    ENDLOOP.

*---- OBIS-Daten und Vor- und Nachkommerstellen  --------------------------------------------------
    IF is_changed_data-inst_rel_tab IS INITIAL. "Nur wenn kein Gerätewechsel vorliegt
      CLEAR: ls_proc_step_data_new, ls_proc_step_data_old, ls_reg_code_data_new, ls_reg_code_data_old.
      LOOP AT is_changed_data-etdz_tab ASSIGNING <fs_etdz_new> WHERE bis = /idexge/if_swt_constants=>gc_date_unlimited.
        LOOP AT is_old_data-etdz_tab ASSIGNING <fs_etdz_old>
          WHERE equnr = <fs_etdz_new>-equnr AND logikzw = <fs_etdz_new>-logikzw AND
            ( ( bis >= <fs_etdz_new>-ab AND ab <= <fs_etdz_new>-ab ) OR bis = /idexge/if_swt_constants=>gc_date_unlimited ).

          ls_reg_code_data_new-item_id      = 1.
          ls_reg_code_data_new-reg_code     = <fs_etdz_new>-kennziff.
          ls_reg_code_data_new-int_positons = <fs_etdz_new>-stanzvor.
          ls_reg_code_data_new-dec_places   = <fs_etdz_new>-stanznac.
          SHIFT ls_reg_code_data_new-int_positons LEFT DELETING LEADING '0'.
          SHIFT ls_reg_code_data_new-dec_places   LEFT DELETING LEADING '0'.

          ls_reg_code_data_old-item_id      = 1.
          ls_reg_code_data_old-reg_code     = <fs_etdz_old>-kennziff.
          ls_reg_code_data_old-int_positons = <fs_etdz_old>-stanzvor.
          ls_reg_code_data_old-dec_places   = <fs_etdz_old>-stanznac.
          SHIFT ls_reg_code_data_old-int_positons LEFT DELETING LEADING '0'.
          SHIFT ls_reg_code_data_old-dec_places   LEFT DELETING LEADING '0'.

          APPEND ls_reg_code_data_new TO ls_proc_step_data_new-reg_code_data.
          APPEND ls_reg_code_data_old TO ls_proc_step_data_old-reg_code_data.

          ls_proc_step_data-mtd_code_result = /adesso/cl_mdc_utility=>compare_proc_step_data( is_proc_step_data_1 = ls_proc_step_data_old is_proc_step_data_2 = ls_proc_step_data_new ).
          IF ls_proc_step_data-mtd_code_result IS NOT INITIAL.
            APPEND ls_proc_step_data TO lt_proc_step_data.
          ENDIF.

          lv_keydate = <fs_etdz_new>-ab.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

***** 2. AMIDs ermitteln und Prozessschritte verdichten, falls möglich ****************************
    LOOP AT lt_proc_step_data ASSIGNING <fs_proc_step_data>.
      /adesso/cl_mdc_datex_utility=>add_amid_to_proc_step_data( CHANGING cs_proc_step_data = <fs_proc_step_data> ).
    ENDLOOP.
    /adesso/cl_mdc_datex_utility=>condense_proc_step_data( CHANGING ct_proc_step_data = lt_proc_step_data ).

***** 3. Prozessdaten erzeugen und Prozessdatum eintragen *****************************************
    LOOP AT lt_proc_step_data ASSIGNING <fs_proc_step_data>.
      APPEND INITIAL LINE TO rt_proc_data ASSIGNING <fs_proc_data>.
      <fs_proc_data>-proc_date = lv_keydate.
      APPEND <fs_proc_step_data> TO <fs_proc_data>-steps.
    ENDLOOP.

***** 4. BAdI für kundeneigene Implementierung ****************************************************
    TRY.
        GET BADI lr_badi_mdc_dtx_billingin
          FILTERS
            mandt = sy-mandt
            sysid = sy-sysid.
      CATCH cx_badi_not_implemented.
        "Das BAdI muss nicht implementiert sein.
    ENDTRY.

    IF lr_badi_mdc_dtx_billingin IS NOT INITIAL.
      CALL BADI lr_badi_mdc_dtx_billingin->change_proc_data
        EXPORTING
          is_changed_data = is_changed_data
          is_old_data     = is_old_data
        CHANGING
          ct_proc_data    = rt_proc_data.
    ENDIF.

  ENDMETHOD.


  METHOD get_proc_data_coaddr.

    DATA: lr_badi_mdc_dtx_coaddr TYPE REF TO /adesso/badi_mdc_dtx_coaddr,
          lt_proc_step_data      TYPE /idxgc/t_proc_step_data,
          ls_proc_step_data      TYPE /idxgc/s_proc_step_data,
          ls_proc_step_data_new  TYPE /idxgc/s_proc_step_data,
          ls_proc_step_data_old  TYPE /idxgc/s_proc_step_data,
          ls_name_address_new    TYPE /idxgc/s_nameaddr_details,
          ls_name_address_old    TYPE /idxgc/s_nameaddr_details.


    FIELD-SYMBOLS:
      <fs_proc_data>      TYPE /idxgc/s_proc_data,
      <fs_proc_step_data> TYPE /idxgc/s_proc_step_data,
      <fs_addr1_val_new>  TYPE addr1_val,
      <fs_addr1_val_old>  TYPE addr1_val.

***** 1. Daten in Prozessschrittdaten übernehmen und vergleichen **********************************
*---- Adresse der Anlage / des Anschlussobjekts ---------------------------------------------------
    CLEAR:  ls_proc_step_data_new, ls_proc_step_data_old, ls_name_address_new, ls_name_address_old.

    ls_name_address_new-item_id         = 1.
    ls_name_address_new-party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_dp.
    ls_name_address_new-streetname      = is_addr1_val_new-street.
    ls_name_address_new-houseid         = is_addr1_val_new-house_num1.
    ls_name_address_new-houseid_add     = is_addr1_val_new-house_num2.
    ls_name_address_new-postalcode      = is_addr1_val_new-post_code1.
    ls_name_address_new-cityname        = is_addr1_val_new-city1.
    ls_name_address_new-countrycode     = is_addr1_val_new-country.
    ls_name_address_new-poboxid         = is_addr1_val_new-po_box.
    ls_name_address_new-nameaddr_add1   = is_addr1_val_new-city2.
    ls_name_address_new-nameaddr_add2   = is_addr1_val_new-city2+35(5).

    ls_name_address_old-item_id         = 1.
    ls_name_address_old-party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_dp.
    ls_name_address_old-streetname      = is_addr1_val_old-street.
    ls_name_address_old-houseid         = is_addr1_val_old-house_num1.
    ls_name_address_old-houseid_add     = is_addr1_val_old-house_num2.
    ls_name_address_old-postalcode      = is_addr1_val_old-post_code1.
    ls_name_address_old-cityname        = is_addr1_val_old-city1.
    ls_name_address_old-countrycode     = is_addr1_val_old-country.
    ls_name_address_old-poboxid         = is_addr1_val_old-po_box.
    ls_name_address_old-nameaddr_add1   = is_addr1_val_old-city2.
    ls_name_address_old-nameaddr_add2   = is_addr1_val_old-city2+35(5).

    APPEND ls_name_address_new TO ls_proc_step_data_new-name_address.
    APPEND ls_name_address_old TO ls_proc_step_data_old-name_address.

    ls_proc_step_data-mtd_code_result = /adesso/cl_mdc_utility=>compare_proc_step_data( is_proc_step_data_1 = ls_proc_step_data_old is_proc_step_data_2 = ls_proc_step_data_new ).
    IF ls_proc_step_data-mtd_code_result IS NOT INITIAL.
      APPEND ls_proc_step_data TO lt_proc_step_data.
    ENDIF.

***** 2. AMIDs ermitteln und Prozessschritte verdichten, falls möglich ****************************
    LOOP AT lt_proc_step_data ASSIGNING <fs_proc_step_data>.
      /adesso/cl_mdc_datex_utility=>add_amid_to_proc_step_data( CHANGING cs_proc_step_data = <fs_proc_step_data> ).
    ENDLOOP.
    /adesso/cl_mdc_datex_utility=>condense_proc_step_data( CHANGING ct_proc_step_data = lt_proc_step_data ).

***** 3. Prozessdaten erzeugen und Prozessdatum eintragen *****************************************
    LOOP AT lt_proc_step_data ASSIGNING <fs_proc_step_data>.
      APPEND INITIAL LINE TO rt_proc_data ASSIGNING <fs_proc_data>.
      <fs_proc_data>-proc_date = sy-datum.
      APPEND <fs_proc_step_data> TO <fs_proc_data>-steps.
    ENDLOOP.

***** 4. BAdI für kundeneigene Implementierung ****************************************************
    TRY.
        GET BADI lr_badi_mdc_dtx_coaddr
          FILTERS
            mandt = sy-mandt
            sysid = sy-sysid.
      CATCH cx_badi_not_implemented.
        "Das BAdI muss nicht implementiert sein.
    ENDTRY.

    IF lr_badi_mdc_dtx_coaddr IS NOT INITIAL.
      CALL BADI lr_badi_mdc_dtx_coaddr->change_proc_data
        EXPORTING
          iv_addr_ref      = iv_addr_ref
          is_addr1_val_new = is_addr1_val_new
          is_addr1_val_old = is_addr1_val_old
        CHANGING
          ct_proc_data     = rt_proc_data.
    ENDIF.

  ENDMETHOD.


  METHOD get_proc_data_contract.
***************************************************************************************************
* THIMEL-R, 20150913, SDÄ auf Common Layer Engine
*   Bei Vertägen gibt es sehr viele kundenindividuelle Ausprägungen, daher erfolgt hier nur ein
*     BAdI Aufruf.
***************************************************************************************************
    DATA: lr_badi_mdc_dtx_contract TYPE REF TO /adesso/badi_mdc_dtx_contract.

***** BAdI für kundeneigene Implementierung *******************************************************
    TRY.
        GET BADI lr_badi_mdc_dtx_contract
          FILTERS
            mandt = sy-mandt
            sysid = sy-sysid.
      CATCH cx_badi_not_implemented.
        "Das BAdI muss nicht implementiert sein.
    ENDTRY.

    IF lr_badi_mdc_dtx_contract IS NOT INITIAL.
      CALL BADI lr_badi_mdc_dtx_contract->change_proc_data
        EXPORTING
          is_ever_old  = is_ever_old
          is_ever_new  = is_ever_new
        CHANGING
          ct_proc_data = rt_proc_data.
    ENDIF.

  ENDMETHOD.


  METHOD get_proc_data_instfacts.
    DATA: lr_badi_mdc_dtx_instfacts TYPE REF TO /adesso/badi_mdc_dtx_instfacts.

***** BAdI für kundeneigene Implementierung *******************************************************
    TRY.
        GET BADI lr_badi_mdc_dtx_instfacts
          FILTERS
            mandt = sy-mandt
            sysid = sy-sysid.
      CATCH cx_badi_not_implemented.
        "Das BAdI muss nicht implementiert sein.
    ENDTRY.

    IF lr_badi_mdc_dtx_instfacts IS NOT INITIAL.
      CALL BADI lr_badi_mdc_dtx_instfacts->change_proc_data
        EXPORTING
          it_new_facts = it_new_facts
          it_old_facts = it_old_facts
        CHANGING
          ct_proc_data = rt_proc_data.
    ENDIF.

  ENDMETHOD.


  METHOD get_proc_data_instln.
    DATA: lr_badi_mdc_dtx_instln TYPE REF TO /adesso/badi_mdc_dtx_instln,
          lt_proc_step_data      TYPE /idxgc/t_proc_step_data,
          ls_proc_step_data      TYPE /idxgc/s_proc_step_data,
          ls_proc_step_data_new  TYPE /idxgc/s_proc_step_data,
          ls_proc_step_data_old  TYPE /idxgc/s_proc_step_data,
          ls_diverse_new         TYPE /idxgc/s_diverse_details,
          ls_diverse_old         TYPE /idxgc/s_diverse_details,
          lv_keydate             TYPE /idxgc/de_keydate,
          lv_portion             TYPE portion,
          lv_periodew            TYPE periodew.

    FIELD-SYMBOLS: <fs_proc_data>      TYPE /idxgc/s_proc_data,
                   <fs_proc_step_data> TYPE /idxgc/s_proc_step_data,
                   <fs_eanlh>          TYPE isu01_instln_changed_timeslice.

***** 1. Daten in Prozessschrittdaten übernehmen und vergleichen **********************************
*---- Turnusinterval ------------------------------------------------------------------------------
    CLEAR: ls_proc_step_data_old, ls_proc_step_data_new, ls_diverse_new, ls_diverse_old.
    LOOP AT is_changed_data-eanlh ASSIGNING <fs_eanlh>.
      IF <fs_eanlh>-new-ableinh NE <fs_eanlh>-old-ableinh.
        CLEAR lv_periodew.
        SELECT SINGLE portion FROM te422 INTO lv_portion WHERE termschl EQ <fs_eanlh>-new-ableinh.
        SELECT SINGLE periodew FROM te420 INTO lv_periodew WHERE termschl EQ lv_portion.
        ls_diverse_new-mrperiod_length = lv_periodew.

        CLEAR lv_periodew.
        SELECT SINGLE portion FROM te422 INTO lv_portion WHERE termschl EQ <fs_eanlh>-old-ableinh.
        SELECT SINGLE periodew FROM  te420 INTO lv_periodew WHERE termschl EQ lv_portion.
        ls_diverse_old-mrperiod_length = lv_periodew.

        lv_keydate = <fs_eanlh>-new-ab.
      ENDIF.
    ENDLOOP.

    ls_diverse_new-item_id = 1.
    ls_diverse_old-item_id = 1.

    APPEND ls_diverse_new TO ls_proc_step_data_new-diverse.
    APPEND ls_diverse_old TO ls_proc_step_data_old-diverse.

    ls_proc_step_data-mtd_code_result = /adesso/cl_mdc_utility=>compare_proc_step_data( is_proc_step_data_1 = ls_proc_step_data_old is_proc_step_data_2 = ls_proc_step_data_new ).
    IF ls_proc_step_data-mtd_code_result IS NOT INITIAL.
      APPEND ls_proc_step_data TO lt_proc_step_data.
    ENDIF.

***** 2. AMIDs ermitteln und Prozessschritte verdichten, falls möglich ****************************
    LOOP AT lt_proc_step_data ASSIGNING <fs_proc_step_data>.
      /adesso/cl_mdc_datex_utility=>add_amid_to_proc_step_data( CHANGING cs_proc_step_data = <fs_proc_step_data> ).
    ENDLOOP.
    /adesso/cl_mdc_datex_utility=>condense_proc_step_data( CHANGING ct_proc_step_data = lt_proc_step_data ).

***** 3. Prozessdaten erzeugen und Prozessdatum eintragen *****************************************
    LOOP AT lt_proc_step_data ASSIGNING <fs_proc_step_data>.
      APPEND INITIAL LINE TO rt_proc_data ASSIGNING <fs_proc_data>.
      <fs_proc_data>-proc_date = lv_keydate.
      APPEND <fs_proc_step_data> TO <fs_proc_data>-steps.
    ENDLOOP.

***** 4. BAdI für kundeneigene Implementierung ****************************************************
    TRY.
        GET BADI lr_badi_mdc_dtx_instln
          FILTERS
            mandt = sy-mandt
            sysid = sy-sysid.
      CATCH cx_badi_not_implemented.
        "Das BAdI muss nicht implementiert sein.
    ENDTRY.

    IF lr_badi_mdc_dtx_instln IS NOT INITIAL.
      CALL BADI lr_badi_mdc_dtx_instln->change_proc_data
        EXPORTING
          is_changed_data = is_changed_data
        CHANGING
          ct_proc_data    = rt_proc_data.
    ENDIF.

  ENDMETHOD.


  METHOD get_proc_data_lpass.
    DATA: lr_badi_mdc_dtx_lpass TYPE REF TO /adesso/badi_mdc_dtx_lpass.

***** BAdI für kundeneigene Implementierung *******************************************************
    TRY.
        GET BADI lr_badi_mdc_dtx_lpass
          FILTERS
            mandt = sy-mandt
            sysid = sy-sysid.
      CATCH cx_badi_not_implemented.
        "Das BAdI muss nicht implementiert sein.
    ENDTRY.

    IF lr_badi_mdc_dtx_lpass IS NOT INITIAL.
      CALL BADI lr_badi_mdc_dtx_lpass->change_proc_data_lpass
        EXPORTING
          is_old_data  = is_old_data
          is_new_data  = is_new_data
        CHANGING
          ct_proc_data = rt_proc_data.
    ENDIF.

  ENDMETHOD.


  METHOD get_proc_data_nbservice.
    DATA: lr_badi_mdc_dtx_nbservice TYPE REF TO /adesso/badi_mdc_dtx_nbservice.

***** BAdI für kundeneigene Implementierung *******************************************************
    TRY.
        GET BADI lr_badi_mdc_dtx_nbservice
          FILTERS
            mandt = sy-mandt
            sysid = sy-sysid.
      CATCH cx_badi_not_implemented.
        "Das BAdI muss nicht implementiert sein.
    ENDTRY.

    IF lr_badi_mdc_dtx_nbservice IS NOT INITIAL.
      CALL BADI lr_badi_mdc_dtx_nbservice->change_proc_data_nbservice
        EXPORTING
          is_eservice_old = is_eservice_old
          is_eservice_new = is_eservice_new
          iv_upd_mode     = iv_upd_mode
        CHANGING
          ct_proc_data    = rt_proc_data.
    ENDIF.

  ENDMETHOD.


  METHOD get_proc_data_partner.
    DATA: lr_badi_mdc_dtx_partner TYPE REF TO /adesso/badi_mdc_dtx_partner,
          lt_proc_step_data       TYPE /idxgc/t_proc_step_data,
          ls_proc_step_data       TYPE /idxgc/s_proc_step_data,
          ls_proc_step_data_new   TYPE /idxgc/s_proc_step_data,
          ls_proc_step_data_old   TYPE /idxgc/s_proc_step_data,
          ls_name_address_new     TYPE /idxgc/s_nameaddr_details,
          ls_name_address_old     TYPE /idxgc/s_nameaddr_details.

    FIELD-SYMBOLS: <fs_proc_data>      TYPE /idxgc/s_proc_data,
                   <fs_proc_step_data> TYPE /idxgc/s_proc_step_data,
                   <fs_but000_new>     TYPE but000,
                   <fs_but000_old>     TYPE but000,
                   <eausd>             TYPE eausd.

***** 1. Daten in Prozessschrittdaten übernehmen und vergleichen **********************************
*---- Name und Titel des Geschäftspartners --------------------------------------------------------
    CLEAR: ls_proc_step_data_new, ls_proc_step_data_old, ls_name_address_new, ls_name_address_old.
    LOOP AT is_new_data-t_but000 ASSIGNING <fs_but000_new>.
      LOOP AT is_old_data-t_but000 ASSIGNING <fs_but000_old> WHERE valid_from = <fs_but000_new>-valid_from AND valid_to = <fs_but000_new>-valid_to.
        ls_name_address_new-item_id         = 1.
        ls_name_address_new-party_func_qual = /idxgc/if_constants_ide=>gc_nad_02_qual_ud.
        IF <fs_but000_new>-type EQ '1'.     "natural person
          ls_name_address_new-name_format_code = /idxgc/if_constants_ide=>gc_name_format_code_person.
          ls_name_address_new-fam_comp_name1   = <fs_but000_new>-name_last.
          ls_name_address_new-first_name       = <fs_but000_new>-name_first.
        ELSEIF <fs_but000_new>-type EQ '2'. "Organisation
          ls_name_address_new-name_format_code = /idxgc/if_constants_ide=>gc_name_format_code_company.
          ls_name_address_new-fam_comp_name1   = <fs_but000_new>-name_org1.
          ls_name_address_new-fam_comp_name2   = <fs_but000_new>-name_org2.
        ELSEIF <fs_but000_new>-type EQ '3'. "Group
          ls_name_address_new-name_format_code = /idxgc/if_constants_ide=>gc_name_format_code_company.
          ls_name_address_new-fam_comp_name1   = <fs_but000_new>-name_grp1.
          ls_name_address_new-fam_comp_name2   = <fs_but000_new>-name_grp2.
        ENDIF.

        ls_name_address_old-item_id         = 1.
        ls_name_address_old-party_func_qual = /idxgc/if_constants_ide=>gc_nad_02_qual_ud.
        IF <fs_but000_old>-type EQ '1'.     "natural person
          ls_name_address_old-name_format_code = /idxgc/if_constants_ide=>gc_name_format_code_person.
          ls_name_address_old-fam_comp_name1   = <fs_but000_old>-name_last.
          ls_name_address_old-first_name       = <fs_but000_old>-name_first.
        ELSEIF <fs_but000_old>-type EQ '2'. "Organisation
          ls_name_address_old-name_format_code = /idxgc/if_constants_ide=>gc_name_format_code_company.
          ls_name_address_old-fam_comp_name1   = <fs_but000_old>-name_org1.
          ls_name_address_old-fam_comp_name2   = <fs_but000_old>-name_org2.
        ELSEIF <fs_but000_old>-type EQ '3'. "Group
          ls_name_address_old-name_format_code = /idxgc/if_constants_ide=>gc_name_format_code_company.
          ls_name_address_old-fam_comp_name1   = <fs_but000_old>-name_grp1.
          ls_name_address_old-fam_comp_name2   = <fs_but000_old>-name_grp2.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    APPEND ls_name_address_new TO ls_proc_step_data_new-name_address.
    APPEND ls_name_address_old TO ls_proc_step_data_old-name_address.

    ls_proc_step_data-mtd_code_result = /adesso/cl_mdc_utility=>compare_proc_step_data( is_proc_step_data_1 = ls_proc_step_data_old is_proc_step_data_2 = ls_proc_step_data_new ).
    IF ls_proc_step_data-mtd_code_result IS NOT INITIAL.
      APPEND ls_proc_step_data TO lt_proc_step_data.
    ENDIF.

*---- Adresse des Geschäftspartners ---------------------------------------------------------------
    CLEAR: ls_proc_step_data_new, ls_proc_step_data_old, ls_name_address_new, ls_name_address_old.
    ls_name_address_new-streetname      = is_new_data-ekun-street.
    ls_name_address_new-poboxid         = is_new_data-ekun-po_box.
    CONCATENATE is_new_data-ekun-house_num1 is_new_data-ekun-house_num2 INTO ls_name_address_new-houseid_compl.
    ls_name_address_new-countrycode     = is_new_data-ekun-country.
    ls_name_address_new-district        = is_new_data-ekun-city2.
    IF is_new_data-ekun-po_box IS INITIAL.
      ls_name_address_new-cityname      = is_new_data-ekun-city1.
      ls_name_address_new-postalcode    = is_new_data-ekun-post_code1.
    ELSE.
      IF is_new_data-ekun-post_code2 IS NOT INITIAL.
        ls_name_address_new-postalcode  = is_new_data-ekun-post_code2.
      ELSE.
        ls_name_address_new-postalcode  = is_new_data-ekun-post_code1.
      ENDIF.
      IF is_new_data-ekun-po_box_loc IS NOT INITIAL.
        ls_name_address_new-cityname    = is_new_data-ekun-po_box_loc.
      ELSE.
        ls_name_address_new-cityname    = is_new_data-ekun-city1.
      ENDIF.
    ENDIF.
    ls_name_address_new-item_id         = 1.
    ls_name_address_new-party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_z04.
    APPEND ls_name_address_new TO ls_proc_step_data_new-name_address.

    ls_name_address_old-streetname      = is_old_data-ekun-street.
    ls_name_address_old-poboxid         = is_old_data-ekun-po_box.
    CONCATENATE is_old_data-ekun-house_num1 is_old_data-ekun-house_num2 INTO ls_name_address_old-houseid_compl.
    ls_name_address_old-countrycode     = is_old_data-ekun-country.
    ls_name_address_old-district        = is_old_data-ekun-city2.
    ls_name_address_old-nameaddr_add2   = is_old_data-ekun-city2+35(5).
    IF is_old_data-ekun-po_box IS INITIAL.
      ls_name_address_old-cityname      = is_old_data-ekun-city1.
      ls_name_address_old-postalcode    = is_old_data-ekun-post_code1.
    ELSE.
      IF is_old_data-ekun-post_code2 IS NOT INITIAL.
        ls_name_address_old-postalcode  = is_old_data-ekun-post_code2.
      ELSE.
        ls_name_address_old-postalcode  = is_old_data-ekun-post_code1.
      ENDIF.
      IF is_old_data-ekun-po_box_loc IS NOT INITIAL.
        ls_name_address_old-cityname    = is_old_data-ekun-po_box_loc.
      ELSE.
        ls_name_address_old-cityname    = is_old_data-ekun-city1.
      ENDIF.
    ENDIF.
    ls_name_address_old-item_id         = 1.
    ls_name_address_old-party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_z04.
    APPEND ls_name_address_old TO ls_proc_step_data_old-name_address.

    ls_proc_step_data-mtd_code_result = /adesso/cl_mdc_utility=>compare_proc_step_data( is_proc_step_data_1 = ls_proc_step_data_old is_proc_step_data_2 = ls_proc_step_data_new ).
    IF ls_proc_step_data-mtd_code_result IS NOT INITIAL.
      APPEND ls_proc_step_data TO lt_proc_step_data.
    ENDIF.

*---- Name, Titel und Adresse des Geschäftspartners für die Ablesekarte ---------------------------
*    CLEAR: ls_proc_step_data_new, ls_proc_step_data_old, ls_name_address_new, ls_name_address_old.
*    LOOP AT is_new_data-t_but000 ASSIGNING <fs_but000_new>.
*      LOOP AT is_old_data-t_but000 ASSIGNING <fs_but000_old> WHERE valid_from = <fs_but000_new>-valid_from AND valid_to = <fs_but000_new>-valid_to.
*        ls_name_address_new-item_id         = 1.
*        ls_name_address_new-party_func_qual = /idxgc/if_constants_ide=>gc_nad_02_qual_z05.
**ToDo: Prüfung ob GP in /IDXGC/MRCONTACT vorhanden ist
*
*        IF <fs_but000_new>-type EQ '1'.     "natural person
*          ls_name_address_new-name_format_code = /idxgc/if_constants_ide=>gc_name_format_code_person.
*          ls_name_address_new-fam_comp_name1   = <fs_but000_new>-name_last.
*          ls_name_address_new-first_name       = <fs_but000_new>-name_first.
*        ELSEIF <fs_but000_new>-type EQ '2'. "Organisation
*          ls_name_address_new-name_format_code = /idxgc/if_constants_ide=>gc_name_format_code_company.
*          ls_name_address_new-fam_comp_name1   = <fs_but000_new>-name_org1.
*          ls_name_address_new-fam_comp_name2   = <fs_but000_new>-name_org2.
*        ELSEIF <fs_but000_new>-type EQ '3'. "Group
*          ls_name_address_new-name_format_code = /idxgc/if_constants_ide=>gc_name_format_code_company.
*          ls_name_address_new-fam_comp_name1   = <fs_but000_new>-name_grp1.
*          ls_name_address_new-fam_comp_name2   = <fs_but000_new>-name_grp2.
*        ENDIF.
*        ls_name_address_new-streetname      = is_new_data-ekun-street.
*        ls_name_address_new-poboxid         = is_new_data-ekun-po_box.
*        CONCATENATE is_new_data-ekun-house_num1 is_new_data-ekun-house_num2 INTO ls_name_address_new-houseid_compl.
*        ls_name_address_new-countrycode     = is_new_data-ekun-country.
*        ls_name_address_new-district        = is_new_data-ekun-city2.
*        IF is_new_data-ekun-po_box IS INITIAL.
*          ls_name_address_new-cityname      = is_new_data-ekun-city1.
*          ls_name_address_new-postalcode    = is_new_data-ekun-post_code1.
*        ELSE.
*          IF is_new_data-ekun-post_code2 IS NOT INITIAL.
*            ls_name_address_new-postalcode  = is_new_data-ekun-post_code2.
*          ELSE.
*            ls_name_address_new-postalcode  = is_new_data-ekun-post_code1.
*          ENDIF.
*          IF is_new_data-ekun-po_box_loc IS NOT INITIAL.
*            ls_name_address_new-cityname    = is_new_data-ekun-po_box_loc.
*          ELSE.
*            ls_name_address_new-cityname    = is_new_data-ekun-city1.
*          ENDIF.
*        ENDIF.
*
*        ls_name_address_old-item_id         = 1.
*        ls_name_address_old-party_func_qual = /idxgc/if_constants_ide=>gc_nad_02_qual_z05.
*        IF <fs_but000_old>-type EQ '1'.     "natural person
*          ls_name_address_old-name_format_code = /idxgc/if_constants_ide=>gc_name_format_code_person.
*          ls_name_address_old-fam_comp_name1   = <fs_but000_old>-name_last.
*          ls_name_address_old-first_name       = <fs_but000_old>-name_first.
*        ELSEIF <fs_but000_old>-type EQ '2'. "Organisation
*          ls_name_address_old-name_format_code = /idxgc/if_constants_ide=>gc_name_format_code_company.
*          ls_name_address_old-fam_comp_name1   = <fs_but000_old>-name_org1.
*          ls_name_address_old-fam_comp_name2   = <fs_but000_old>-name_org2.
*        ELSEIF <fs_but000_old>-type EQ '3'. "Group
*          ls_name_address_old-name_format_code = /idxgc/if_constants_ide=>gc_name_format_code_company.
*          ls_name_address_old-fam_comp_name1   = <fs_but000_old>-name_grp1.
*          ls_name_address_old-fam_comp_name2   = <fs_but000_old>-name_grp2.
*        ENDIF.
*        ls_name_address_old-streetname      = is_old_data-ekun-street.
*        ls_name_address_old-poboxid         = is_old_data-ekun-po_box.
*        CONCATENATE is_old_data-ekun-house_num1 is_old_data-ekun-house_num2 INTO ls_name_address_old-houseid_compl.
*        ls_name_address_old-countrycode     = is_old_data-ekun-country.
*        ls_name_address_old-district        = is_old_data-ekun-city2.
*        ls_name_address_old-nameaddr_add2   = is_old_data-ekun-city2+35(5).
*        IF is_old_data-ekun-po_box IS INITIAL.
*          ls_name_address_old-cityname      = is_old_data-ekun-city1.
*          ls_name_address_old-postalcode    = is_old_data-ekun-post_code1.
*        ELSE.
*          IF is_old_data-ekun-post_code2 IS NOT INITIAL.
*            ls_name_address_old-postalcode  = is_old_data-ekun-post_code2.
*          ELSE.
*            ls_name_address_old-postalcode  = is_old_data-ekun-post_code1.
*          ENDIF.
*          IF is_old_data-ekun-po_box_loc IS NOT INITIAL.
*            ls_name_address_old-cityname    = is_old_data-ekun-po_box_loc.
*          ELSE.
*            ls_name_address_old-cityname    = is_old_data-ekun-city1.
*          ENDIF.
*        ENDIF.
*      ENDLOOP.
*    ENDLOOP.
*
*    APPEND ls_name_address_new TO ls_proc_step_data_new-name_address.
*    APPEND ls_name_address_old TO ls_proc_step_data_old-name_address.

    ls_proc_step_data-mtd_code_result = /adesso/cl_mdc_utility=>compare_proc_step_data( is_proc_step_data_1 = ls_proc_step_data_old is_proc_step_data_2 = ls_proc_step_data_new ).
    IF ls_proc_step_data-mtd_code_result IS NOT INITIAL.
      APPEND ls_proc_step_data TO lt_proc_step_data.
    ENDIF.

***** 2. AMIDs ermitteln und Prozessschritte verdichten, falls möglich ****************************
    LOOP AT lt_proc_step_data ASSIGNING <fs_proc_step_data>.
      /adesso/cl_mdc_datex_utility=>add_amid_to_proc_step_data( CHANGING cs_proc_step_data = <fs_proc_step_data> ).
    ENDLOOP.
    /adesso/cl_mdc_datex_utility=>condense_proc_step_data( CHANGING ct_proc_step_data = lt_proc_step_data ).

***** 3. Prozessdaten erzeugen und Prozessdatum eintragen *****************************************
    LOOP AT lt_proc_step_data ASSIGNING <fs_proc_step_data>.
      APPEND INITIAL LINE TO rt_proc_data ASSIGNING <fs_proc_data>.
      "Wenn die SDÄ aus einem Auszug kommt, muss das Auszugsdatum als Prozessdatum verwendet werden, da sonst der Kunde nicht mehr am ZP ist.
      ASSIGN ('(SAPLEC55)EAUSD') TO <eausd>.

      IF <eausd> IS ASSIGNED.
        IF <eausd>-auszdat IS NOT INITIAL AND <eausd>-auszdat < sy-datum.
          <fs_proc_data>-proc_date = <eausd>-auszdat.
        ENDIF.
      ENDIF.
      IF <fs_proc_data>-proc_date IS INITIAL.
        <fs_proc_data>-proc_date = sy-datum.
      ENDIF.
      APPEND <fs_proc_step_data> TO <fs_proc_data>-steps.
    ENDLOOP.

***** 4. BAdI für kundeneigene Implementierung ****************************************************
    TRY.
        GET BADI lr_badi_mdc_dtx_partner
          FILTERS
            mandt = sy-mandt
            sysid = sy-sysid.
      CATCH cx_badi_not_implemented.
        "Das BAdI muss nicht implementiert sein.
    ENDTRY.

    IF lr_badi_mdc_dtx_partner IS NOT INITIAL.
      CALL BADI lr_badi_mdc_dtx_partner->change_proc_data
        EXPORTING
          is_old_data    = is_old_data
          is_new_data    = is_new_data
          is_bp_crm_data = is_bp_crm_data
          iv_bp_id       = iv_bp_id
        CHANGING
          ct_proc_data   = rt_proc_data.
    ENDIF.

  ENDMETHOD.


  METHOD get_proc_data_pod.
    DATA: lr_badi_mdc_dtx_pod     TYPE REF TO /adesso/badi_mdc_dtx_pod,
          lt_proc_step_data       TYPE /idxgc/t_proc_step_data,
          ls_proc_step_data       TYPE /idxgc/s_proc_step_data,
          ls_proc_step_data_new   TYPE /idxgc/s_proc_step_data,
          ls_proc_step_data_old   TYPE /idxgc/s_proc_step_data,
          ls_diverse_new          TYPE /idxgc/s_diverse_details,
          ls_diverse_old          TYPE /idxgc/s_diverse_details,
          ls_settl_unit_new       TYPE /idxgc/s_setunit_details,
          ls_settl_unit_old       TYPE /idxgc/s_setunit_details,
          ls_new_data             TYPE eui_datex_data,
          ls_old_data             TYPE eui_datex_data,
          lv_count_settl_unit_new TYPE i,
          lv_count_settl_unit_old TYPE i,
          lv_own_intcode          TYPE intcode,
          lv_keydate              TYPE /idxgc/de_keydate.

    FIELD-SYMBOLS: <fs_proc_data>      TYPE /idxgc/s_proc_data,
                   <fs_proc_step_data> TYPE /idxgc/s_proc_step_data,
                   <fs_euitrans_new>   TYPE euitrans,
                   <fs_euitrans_old>   TYPE euitrans,
                   <fs_settl_unit_new> TYPE eedmuisettlunit,
                   <fs_settl_unit_old> TYPE eedmuisettlunit.

    ls_new_data = is_new_data.
    ls_old_data = is_old_data.

***** 1. Daten in Prozessschrittdaten übernehmen und vergleichen **********************************
*---- Zählpunktbezeichnung ------------------------------------------------------------------------
    "Sonderfall, da Änderungen der ZPB nur aus dem Netz verschickt werden dürfen. Nur für das Netz
    "ist Customizing vorhanden (siehe AHB). Im Vertrieb würden später Fehler auftreten.
    lv_own_intcode = /adesso/cl_mdc_customizing=>get_own_intcode( ).
    IF lv_own_intcode = /idxgc/if_constants_ide=>gc_service_cat_dis.
      CLEAR: ls_proc_step_data_new, ls_proc_step_data_old, ls_diverse_new, ls_diverse_old.
      SORT ls_old_data-ui_data-euitrans BY datefrom DESCENDING.
      SORT ls_new_data-ui_data-euitrans BY datefrom DESCENDING.

      READ TABLE ls_new_data-ui_data-euitrans ASSIGNING <fs_euitrans_new> INDEX 1.
      READ TABLE ls_old_data-ui_data-euitrans ASSIGNING <fs_euitrans_old> INDEX 1.

      IF <fs_euitrans_new> IS ASSIGNED AND <fs_euitrans_old> IS ASSIGNED AND
         <fs_euitrans_new>-ext_ui <> <fs_euitrans_old>-ext_ui.

        ls_diverse_new-item_id           = 1.
        ls_diverse_new-pod_corrected = <fs_euitrans_new>-ext_ui.

        ls_diverse_old-item_id           = 1.
        ls_diverse_old-pod_corrected = <fs_euitrans_old>-ext_ui.

        APPEND ls_diverse_new TO ls_proc_step_data_new-diverse.
        APPEND ls_diverse_old TO ls_proc_step_data_old-diverse.

        lv_keydate = <fs_euitrans_new>-datefrom.

        ls_proc_step_data-mtd_code_result = /adesso/cl_mdc_utility=>compare_proc_step_data( is_proc_step_data_1 = ls_proc_step_data_old is_proc_step_data_2 = ls_proc_step_data_new ).
        IF ls_proc_step_data-mtd_code_result IS NOT INITIAL.
          APPEND ls_proc_step_data TO lt_proc_step_data.
        ENDIF.
      ENDIF.
    ENDIF.

*---- Settlement Unit --------------------------------------------------------
    CLEAR: ls_proc_step_data_new, ls_proc_step_data_old, ls_settl_unit_new, ls_settl_unit_old.
    ls_new_data = is_new_data.
    ls_old_data = is_old_data.
    SORT ls_new_data-ui_settlunit BY ab DESCENDING.
    SORT ls_old_data-ui_settlunit BY ab DESCENDING.

    lv_count_settl_unit_new = lines( ls_new_data-ui_settlunit ).
    lv_count_settl_unit_old = lines( ls_old_data-ui_settlunit ).

    IF lv_count_settl_unit_new > lv_count_settl_unit_old. "Neue Zeitscheibe in der Bilanzierung
      READ TABLE ls_new_data-ui_settlunit ASSIGNING <fs_settl_unit_new> INDEX 1.
      READ TABLE ls_old_data-ui_settlunit ASSIGNING <fs_settl_unit_old> INDEX 1.

      IF <fs_settl_unit_new> IS ASSIGNED AND <fs_settl_unit_old> IS ASSIGNED.
        IF <fs_settl_unit_new>-settlunit <> <fs_settl_unit_old>-settlunit.
          ls_settl_unit_new-item_id       = 1.
          ls_settl_unit_new-settlunit_ext = <fs_settl_unit_new>-settlunit.

          ls_settl_unit_old-item_id       = 1.
          ls_settl_unit_old-settlunit_ext = <fs_settl_unit_old>-settlunit.

          APPEND ls_settl_unit_new TO ls_proc_step_data_new-settl_unit.
          APPEND ls_settl_unit_old TO ls_proc_step_data_old-settl_unit.

          lv_keydate = <fs_settl_unit_new>-ab.
        ENDIF.
      ENDIF.
    ELSEIF lv_count_settl_unit_new = lv_count_settl_unit_old. "Bilanzierungseinheit innerhalb einer Zeitscheibe wurde geändert
      LOOP AT ls_old_data-ui_settlunit ASSIGNING <fs_settl_unit_old>.
        READ TABLE ls_new_data-ui_settlunit ASSIGNING <fs_settl_unit_new> INDEX sy-tabix.
        IF <fs_settl_unit_new> IS ASSIGNED.
          IF <fs_settl_unit_new>-settlunit <> <fs_settl_unit_old>-settlunit.
            ls_settl_unit_new-item_id       = 1.
            ls_settl_unit_new-settlunit_ext = <fs_settl_unit_new>-settlunit.

            ls_settl_unit_old-item_id       = 1.
            ls_settl_unit_old-settlunit_ext = <fs_settl_unit_old>-settlunit.

            APPEND ls_settl_unit_new TO ls_proc_step_data_new-settl_unit.
            APPEND ls_settl_unit_old TO ls_proc_step_data_old-settl_unit.

            lv_keydate = <fs_settl_unit_new>-ab.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF. "Keine Vorgabe für Löschen von Zeitscheiben.

    ls_proc_step_data-mtd_code_result = /adesso/cl_mdc_utility=>compare_proc_step_data( is_proc_step_data_1 = ls_proc_step_data_old is_proc_step_data_2 = ls_proc_step_data_new ).
    IF ls_proc_step_data-mtd_code_result IS NOT INITIAL.
      APPEND ls_proc_step_data TO lt_proc_step_data.
    ENDIF.

***** 2. AMIDs ermitteln und Prozessschritte verdichten, falls möglich ****************************
    LOOP AT lt_proc_step_data ASSIGNING <fs_proc_step_data>.
      /adesso/cl_mdc_datex_utility=>add_amid_to_proc_step_data( CHANGING cs_proc_step_data = <fs_proc_step_data> ).
    ENDLOOP.
    /adesso/cl_mdc_datex_utility=>condense_proc_step_data( CHANGING ct_proc_step_data = lt_proc_step_data ).

***** 3. Prozessdaten erzeugen und Prozessdatum eintragen *****************************************
    LOOP AT lt_proc_step_data ASSIGNING <fs_proc_step_data>.
      APPEND INITIAL LINE TO rt_proc_data ASSIGNING <fs_proc_data>.
      <fs_proc_data>-proc_date = lv_keydate.
      APPEND <fs_proc_step_data> TO <fs_proc_data>-steps.
    ENDLOOP.

***** 4. BAdI für kundeneigene Implementierung ****************************************************
    TRY.
        GET BADI lr_badi_mdc_dtx_pod
          FILTERS
            mandt = sy-mandt
            sysid = sy-sysid.
      CATCH cx_badi_not_implemented.
        "Das BAdI muss nicht implementiert sein.
    ENDTRY.

    IF lr_badi_mdc_dtx_pod IS NOT INITIAL.
      CALL BADI lr_badi_mdc_dtx_pod->change_proc_data
        EXPORTING
          is_old_data  = is_old_data
          is_new_data  = is_new_data
        CHANGING
          ct_proc_data = rt_proc_data.
    ENDIF.

  ENDMETHOD.


  METHOD get_proc_data_premise.
    DATA: lr_badi_mdc_dtx_premise TYPE REF TO /adesso/badi_mdc_dtx_premise.

***** BAdI für kundeneigene Implementierung *******************************************************
    TRY.
        GET BADI lr_badi_mdc_dtx_premise
          FILTERS
            mandt = sy-mandt
            sysid = sy-sysid.
      CATCH cx_badi_not_implemented.
        "Das BAdI muss nicht implementiert sein.
    ENDTRY.

    IF lr_badi_mdc_dtx_premise IS NOT INITIAL.
      CALL BADI lr_badi_mdc_dtx_premise->change_proc_data_premise
        EXPORTING
          is_changed_data = is_changed_data
        CHANGING
          ct_proc_data    = rt_proc_data.
    ENDIF.

  ENDMETHOD.


  METHOD get_proc_data_usageinfo.
    DATA: lr_badi_mdc_dtx_usageinfo TYPE REF TO /adesso/badi_mdc_dtx_usageinfo.

***** BAdI für kundeneigene Implementierung *******************************************************
    TRY.
        GET BADI lr_badi_mdc_dtx_usageinfo
          FILTERS
            mandt = sy-mandt
            sysid = sy-sysid.
      CATCH cx_badi_not_implemented.
        "Das BAdI muss nicht implementiert sein.
    ENDTRY.

    IF lr_badi_mdc_dtx_usageinfo IS NOT INITIAL.
      CALL BADI lr_badi_mdc_dtx_usageinfo->change_proc_data_usageinfo
        EXPORTING
          is_bill_doc       = is_bill_doc
          is_data_collector = is_data_collector
          is_billing_data   = is_billing_data
          it_usage          = it_usage
        CHANGING
          ct_proc_data      = rt_proc_data.
    ENDIF.

  ENDMETHOD.


  METHOD get_send_flag_from_customizing.
***************************************************************************************************
* THIMEL-R, 20150726, SDÄ auf Common Layer Engine
*    Prüfen ob der Versand für Stammdatenänderungen für diesen Prozess aktiv ist. Sobald für eine
*    EDIFACT-Struktur ein aktiver Versand festgestellt wird,
***************************************************************************************************
    DATA: lt_edifact_structur TYPE /adesso/mdc_t_edifact_str,
          lv_flag_send        TYPE /adesso/mdc_flag_send.

    FIELD-SYMBOLS: <fs_proc_step_data>   TYPE /idxgc/s_proc_step_data,
                   <fv_edifact_structur> TYPE /idxgc/de_edifact_str.

    READ TABLE is_proc_data-steps ASSIGNING <fs_proc_step_data> INDEX 1.
    IF sy-subrc = 0.
      lt_edifact_structur = /adesso/cl_mdc_utility=>get_changes_as_edifact_str( is_proc_step_data = <fs_proc_step_data> ).
      LOOP AT lt_edifact_structur ASSIGNING <fv_edifact_structur>.
        lv_flag_send = /adesso/cl_mdc_customizing=>get_send_flag( iv_edifact_structur = <fv_edifact_structur>
         iv_keydate = is_proc_data-proc_date iv_assoc_servprov = <fs_proc_step_data>-assoc_servprov ).
        IF lv_flag_send = abap_true.
          rv_flag_send = lv_flag_send.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
      MESSAGE e010(/adesso/mdc_datex) INTO gv_mtext.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.

  ENDMETHOD.


  METHOD get_send_flag_from_datex.
***************************************************************************************************
* THIMEL-R, 20150726, SDÄ auf Common Layer Engine
*    Prüfen ob Datenaustausch aktiviert ist.
***************************************************************************************************
    IF cl_isu_datex_controller=>is_not_relevant( x_dexproc = /adesso/if_mdc_co=>gc_dexbasicproc_mdc_dummy x_int_ui = iv_int_ui ) = abap_true.
      rt_flag_send = abap_false.
    ELSE.
      rt_flag_send = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD get_transreason_from_bmid.
***************************************************************************************************
* THIMEL-R, 20151009, SDÄ auf Common Layer Engine
*   Ggf. Umstellen auf /IDXGC/TNREASON, wenn SAP diese pflegt.
* THIMEL-R, 20160322, Neue BMIDs und Transaktionsgründe eingefügt.
***************************************************************************************************
    CASE iv_bmid.
      WHEN /idxgc/if_constants_ide=>gc_bmid_ch101 OR
           /idxgc/if_constants_ide=>gc_bmid_ch102.
        rv_msgtransreason = /adesso/if_mdc_co=>gc_trans_reason_code_ze6.
      WHEN /idxgc/if_constants_ide=>gc_bmid_ch111 OR
           /idxgc/if_constants_ide=>gc_bmid_ch112 OR
           /idxgc/if_constants_ide=>gc_bmid_ch113.
        rv_msgtransreason = /idxgc/if_constants_ide=>gc_trans_reason_code_ze7.
      WHEN /idxgc/if_constants_ide=>gc_bmid_ch121 OR
           /idxgc/if_constants_ide=>gc_bmid_ch122 OR
           /idxgc/if_constants_ide=>gc_bmid_ch123.
        rv_msgtransreason = /idxgc/if_constants_ide=>gc_trans_reason_code_ze8.
      WHEN /idxgc/if_constants_ide=>gc_bmid_ch131.
        rv_msgtransreason = /adesso/if_mdc_co=>gc_trans_reason_code_ze9.
      WHEN /idxgc/if_constants_ide=>gc_bmid_ch141.
        rv_msgtransreason = /adesso/if_mdc_co=>gc_trans_reason_code_zf0.
      WHEN /idxgc/if_constants_ide=>gc_bmid_ch151.
        rv_msgtransreason = /adesso/if_mdc_co=>gc_trans_reason_code_zf1.
      WHEN /idxgc/if_constants_ide=>gc_bmid_ch161 OR
           /idxgc/if_constants_ide=>gc_bmid_ch162 OR
           /idxgc/if_constants_ide=>gc_bmid_ch163.
        rv_msgtransreason = /adesso/if_mdc_co=>gc_trans_reason_code_zf2.
      WHEN /idxgc/if_constants_ide=>gc_bmid_ch171 OR
           /idxgc/if_constants_ide=>gc_bmid_ch172.
        rv_msgtransreason = /adesso/if_mdc_co=>gc_trans_reason_code_zg7.
      WHEN /idxgc/if_constants_ide=>gc_bmid_ch201 OR
           /idxgc/if_constants_ide=>gc_bmid_ch204 OR
           /idxgc/if_constants_ide=>gc_bmid_ch205.
        rv_msgtransreason = /adesso/if_mdc_co=>gc_trans_reason_code_zf3.
      WHEN /idxgc/if_constants_ide=>gc_bmid_ch211 OR
           /idxgc/if_constants_ide=>gc_bmid_ch212 OR
           /idxgc/if_constants_ide=>gc_bmid_ch213.
        rv_msgtransreason = /adesso/if_mdc_co=>gc_trans_reason_code_zf4.
      WHEN /idxgc/if_constants_ide=>gc_bmid_ch221 OR
           /idxgc/if_constants_ide=>gc_bmid_ch222 OR
           /idxgc/if_constants_ide=>gc_bmid_ch225 OR
           /idxgc/if_constants_ide=>gc_bmid_ch226.
        rv_msgtransreason = /adesso/if_mdc_co=>gc_trans_reason_code_zf5.
      WHEN /idxgc/if_constants_ide=>gc_bmid_ch231.
        rv_msgtransreason = /adesso/if_mdc_co=>gc_trans_reason_code_zf6.
      WHEN /idxgc/if_constants_ide=>gc_bmid_ch241.
        rv_msgtransreason = /adesso/if_mdc_co=>gc_trans_reason_code_zf7.
      WHEN /idxgc/if_constants_ide=>gc_bmid_ch251.
        rv_msgtransreason = /adesso/if_mdc_co=>gc_trans_reason_code_zf8.
      WHEN /idxgc/if_constants_ide=>gc_bmid_ch261 OR
           /idxgc/if_constants_ide=>gc_bmid_ch264 OR
           /idxgc/if_constants_ide=>gc_bmid_ch265.
        rv_msgtransreason = /adesso/if_mdc_co=>gc_trans_reason_code_zg8.
      WHEN OTHERS.
        "Keine weiteren Fälle.
    ENDCASE.
  ENDMETHOD.


  METHOD update_mtd_code_result.
***************************************************************************************************
* THIMEL-R, 20150726, SDÄ auf Common Layer Engine
*    Prüfen ob der Versand für Stammdatenänderungen für die ermittelten Änderungen aktiv ist und
*      alle Einträge mit Kennzeichen AKTIV im Customizing behalten.
***************************************************************************************************
    DATA: lv_edifact_structur TYPE /idxgc/de_edifact_str,
          lv_flag_send        TYPE /adesso/mdc_flag_send.

    FIELD-SYMBOLS: <fs_proc_step_data>  TYPE /idxgc/s_proc_step_data,
                   <fs_mtd_code_result> TYPE /idxgc/s_mtd_code_details.

    READ TABLE cs_proc_data-steps ASSIGNING <fs_proc_step_data> INDEX 1.
    IF sy-subrc = 0.
      LOOP AT <fs_proc_step_data>-mtd_code_result ASSIGNING <fs_mtd_code_result>.
        lv_edifact_structur = <fs_mtd_code_result>-addinfo.
        IF /adesso/cl_mdc_customizing=>get_send_flag( iv_edifact_structur = lv_edifact_structur iv_assoc_servprov = <fs_proc_step_data>-assoc_servprov ) = abap_false.
          DELETE <fs_proc_step_data>-mtd_code_result.
        ENDIF.
      ENDLOOP.
    ELSE.
      MESSAGE e010(/adesso/mdc_datex) INTO gv_mtext.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
