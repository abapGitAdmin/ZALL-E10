class /ADZ/CL_MDC_DATEX_UTILITY definition
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
      value(RV_FLAG_SEND) type /ADZ/MDC_FLAG_SEND
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_SEND_FLAG_FROM_DATEX
    importing
      !IV_INT_UI type INT_UI
    returning
      value(RT_FLAG_SEND) type /ADZ/MDC_FLAG_SEND
    raising
      /IDXGC/CX_GENERAL .
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



CLASS /ADZ/CL_MDC_DATEX_UTILITY IMPLEMENTATION.


  METHOD ADD_AMID_TO_PROC_STEP_DATA.

    DATA: gr_previous         TYPE REF TO cx_root,
          lv_start_amid       TYPE /idxgc/de_amid,
          ls_amid_details     TYPE /idxgc/s_amid_details,
          lv_own_intcode      TYPE /adz/mdc_intcode,
          lv_receiver_intcode TYPE /adz/mdc_intcode,
          lt_edifact_str      TYPE /adz/mdc_t_edifact_str.

    FIELD-SYMBOLS: <fs_edifact_str>  TYPE /idxgc/de_edifact_str.

***** 1. Änderungen aus Schrittdaten lesen und INTCODEs ermitteln *********************************
    lv_own_intcode = /adz/cl_mdc_customizing=>get_own_intcode( ).
    IF cs_proc_step_data-assoc_servprov IS NOT INITIAL.
*      lv_receiver_intcode = /adz/cl_mdc_utility=>get_intcode_servprov( iv_serviceid = cs_proc_step_data-assoc_servprov ).
    ENDIF.
*    lt_edifact_str = /adz/cl_mdc_utility=>get_changes_as_edifact_str( is_proc_step_data = cs_proc_step_data ).

***** 2. Loop über EDIFACT-Strukturen und AMID ermitteln ******************************************
    LOOP AT lt_edifact_str ASSIGNING <fs_edifact_str>.
*      lv_start_amid = /adz/cl_mdc_customizing=>get_start_amid( iv_edifact_structur = <fs_edifact_str>
*        iv_sender_intcode = lv_own_intcode iv_receiver_intcode = lv_receiver_intcode ).
      AT FIRST.
        ls_amid_details-item_id = 1.
        ls_amid_details-amid = lv_start_amid.
        CONTINUE.
      ENDAT.

      IF ls_amid_details-amid <> lv_start_amid.
        MESSAGE e014(/adz/mdc_datex) INTO gv_mtext.
        /idxgc/cx_general=>raise_exception_from_msg( ).
      ENDIF.
    ENDLOOP.

***** 3. Ergebnis in Schrittdaten schreiben. ******************************************************
    CLEAR cs_proc_step_data-amid.
    APPEND ls_amid_details TO cs_proc_step_data-amid.

  ENDMETHOD.


  METHOD ADD_SERVPROVS_AND_BMID.
********************************************************************************************************
****** THIMEL-R, 20150726, SDÄ auf Common Layer Engine
******    Ersten Empfänger ermitteln und alle weiteren Empfänger in Schrittdaten schreiben. Falls der
******    Netzbetreiber nur die Rolle Berechtigter hat, dann muss zuerst der Verantwortliche bestimmt
******    werden.
********************************************************************************************************
*****    DATA: gr_previous                 TYPE REF TO cx_root,
*****          lt_serviceprovider          TYPE /idxgc/t_servprov_details,
*****          lt_edifact_structur         TYPE /adz/mdc_t_edifact_str,
*****          lv_own_intcode              TYPE /adz/mdc_intcode,
*****          lv_responsible_intcode      TYPE /adz/mdc_intcode,
*****          lv_start_amid               TYPE /idxgc/de_amid,
*****          lv_flag_took_over_role_resp TYPE flag,
*****          lv_flag_sender_future       TYPE flag.
*****
*****    FIELD-SYMBOLS: <fs_proc_step_data>  TYPE /idxgc/s_proc_step_data,
*****                   <fs_serviceprovider> TYPE /idxgc/s_servprov_details.
*****
********** 1. Initialisierung von Hilfsstrukturen ******************************************************
*****    lt_serviceprovider = /adz/cl_mdc_utility=>get_servprovs_for_pod( iv_int_ui = cs_proc_data-int_ui iv_keydate = cs_proc_data-proc_date ).
*****    READ TABLE cs_proc_data-steps ASSIGNING <fs_proc_step_data> INDEX 1.
*****    lt_edifact_structur = /adz/cl_mdc_utility=>get_changes_as_edifact_str( is_proc_step_data = <fs_proc_step_data> ).
*****    lv_own_intcode = /adz/cl_mdc_customizing=>get_own_intcode( ).
*****
********** 2. Sender ermitteln *************************************************************************
*****    LOOP AT lt_serviceprovider ASSIGNING <fs_serviceprovider> WHERE service_cat = lv_own_intcode AND is_new = abap_false.
*****      <fs_proc_step_data>-own_servprov = <fs_serviceprovider>-service_id.
*****      DELETE lt_serviceprovider.
*****    ENDLOOP.
*****
********** 3. Ersten Empfänger ermitteln ***************************************************************
******---- 3.1 Vertrieb: Einziger Empfänger ist der Netzbetreiber (ggf. mehrere falls Wechsel) ---------
*****    IF lv_own_intcode = /idxgc/if_constants=>gc_service_code_supplier.
*****      "Im Vertrieb immer an den Netzbetreiber schicken. Aktuelle zuerst prüfen, dann neue NB.
*****      LOOP AT lt_serviceprovider ASSIGNING <fs_serviceprovider>
*****        WHERE service_cat = /idxgc/if_constants=>gc_service_code_dso AND is_new = abap_false.
*****        IF <fs_serviceprovider>-date_from > sy-datum.
*****          lv_flag_sender_future = abap_true.
*****        ELSE.
*****          lv_flag_sender_future = abap_false.
*****        ENDIF.
*****        <fs_proc_step_data>-bmid = /adz/cl_mdc_datex_utility=>get_bmid(
*****          iv_sender_intcode           = lv_own_intcode
*****          iv_receiver_intcode         = <fs_serviceprovider>-service_cat
*****          iv_responsible_intcode      = lv_responsible_intcode
*****          iv_flag_sender_future       = lv_flag_sender_future
*****          iv_flag_took_over_role_resp = lv_flag_took_over_role_resp
*****          is_proc_data                = cs_proc_data ).
*****        IF <fs_proc_step_data>-bmid IS NOT INITIAL.
*****          <fs_proc_step_data>-assoc_servprov = <fs_serviceprovider>-service_id.
*****          DELETE lt_serviceprovider.
*****          EXIT.
*****        ENDIF.
*****      ENDLOOP.
*****      IF <fs_proc_step_data>-assoc_servprov IS INITIAL.
*****        LOOP AT lt_serviceprovider ASSIGNING <fs_serviceprovider>
*****          WHERE service_cat = /idxgc/if_constants=>gc_service_code_dso AND is_new = abap_true.
*****          IF <fs_serviceprovider>-date_from > sy-datum.
*****            lv_flag_sender_future = abap_true.
*****          ELSE.
*****            lv_flag_sender_future = abap_false.
*****          ENDIF.
*****          <fs_proc_step_data>-bmid = /adz/cl_mdc_datex_utility=>get_bmid(
*****            iv_sender_intcode           = lv_own_intcode
*****            iv_receiver_intcode         = <fs_serviceprovider>-service_cat
*****            iv_responsible_intcode      = lv_responsible_intcode
*****            iv_flag_sender_future       = lv_flag_sender_future
*****            iv_flag_took_over_role_resp = lv_flag_took_over_role_resp
*****            is_proc_data                = cs_proc_data ).
*****          IF <fs_proc_step_data>-bmid IS NOT INITIAL.
*****            <fs_proc_step_data>-assoc_servprov = <fs_serviceprovider>-service_id.
*****            DELETE lt_serviceprovider.
*****            EXIT.
*****          ENDIF.
*****        ENDLOOP.
*****      ENDIF.
*****    ELSEIF lv_own_intcode = /idxgc/if_constants=>gc_service_code_dso.
******---- 3.2 Netz: Mehrere Empfänger möglich, zuerst einen auswählen ---------------------------------
******.... 3.2.1 Eigene Rolle bestimmen ................................................................
*****
*****      lv_responsible_intcode = /adz/cl_mdc_customizing=>get_intcode_responsible( it_edifact_structur = lt_edifact_structur ).
*****
*****      IF lv_responsible_intcode <> lv_own_intcode.
******>>> THIMEL.R, 20151117, Logik passte nicht wenn nur der Lieferant am VSZ hängt.
*****        "Prüfen ob der Verantwortliche ein eigener Serviceanbieter ist, dann wird direkt die Verteilung gestartet
*****        LOOP AT lt_serviceprovider ASSIGNING <fs_serviceprovider> WHERE service_cat = lv_responsible_intcode AND is_new = abap_false.
*****          IF <fs_serviceprovider>-own_service = abap_true.
*****            lv_flag_took_over_role_resp = abap_true.
*****          ENDIF.
*****        ENDLOOP.
*****        "Wenn verantwortlicher Serviceanbieter gar nicht im VSZ hinterlegt ist, dann immer die Rolle Verantwortlicher übernehmen.
*****        IF sy-subrc <> 0.
*****          lv_flag_took_over_role_resp = abap_true.
*****        ENDIF.
******<<< THIMEL.R, 20151117
*****      ENDIF.
******.... 3.2.2 Eigene Rolle Berechtigter > Nachricht an Verantwortlichen .............................
*****      IF lv_own_intcode <> lv_responsible_intcode AND lv_flag_took_over_role_resp = abap_false.
*****        LOOP AT lt_serviceprovider ASSIGNING <fs_serviceprovider>
*****          WHERE service_cat = lv_responsible_intcode AND is_new = abap_false.
*****          <fs_proc_step_data>-bmid = /adz/cl_mdc_datex_utility=>get_bmid(
*****            iv_sender_intcode           = lv_own_intcode
*****            iv_receiver_intcode         = <fs_serviceprovider>-service_cat
*****            iv_responsible_intcode      = lv_responsible_intcode
*****            iv_flag_receiver_future     = <fs_serviceprovider>-is_new
*****            is_proc_data                = cs_proc_data ).
*****          IF <fs_proc_step_data>-bmid IS NOT INITIAL.
*****            <fs_proc_step_data>-assoc_servprov = <fs_serviceprovider>-service_id.
*****            DELETE lt_serviceprovider.
*****            EXIT.
*****          ENDIF.
*****        ENDLOOP.
*****        IF <fs_proc_step_data>-assoc_servprov IS INITIAL.
*****          LOOP AT lt_serviceprovider ASSIGNING <fs_serviceprovider>
*****            WHERE service_cat = lv_responsible_intcode AND is_new = abap_true.
*****            <fs_proc_step_data>-bmid = /adz/cl_mdc_datex_utility=>get_bmid(
*****              iv_sender_intcode           = lv_own_intcode
*****              iv_receiver_intcode         = <fs_serviceprovider>-service_cat
*****              iv_responsible_intcode      = lv_responsible_intcode
*****              iv_flag_receiver_future     = <fs_serviceprovider>-is_new
*****              is_proc_data                = cs_proc_data ).
*****            IF <fs_proc_step_data>-bmid IS NOT INITIAL.
*****              <fs_proc_step_data>-assoc_servprov = <fs_serviceprovider>-service_id.
*****              DELETE lt_serviceprovider.
*****              EXIT.
*****            ENDIF.
*****          ENDLOOP.
*****        ENDIF.
******.... 3.2.3 Eigene Rolle Verantwortlicher > Verteilung ............................................
*****      ELSE.
*****        "Reihenfolge der Suche nach erstem Empfänger: Lieferant(aktuell), Lieferant(neu), MSB(aktuell), MDL(aktuell), MDL(neu)
*****        LOOP AT lt_serviceprovider ASSIGNING <fs_serviceprovider> "Lieferant(aktuell)
*****          WHERE service_cat = /idxgc/if_constants=>gc_service_code_supplier AND is_new = abap_false.
*****          <fs_proc_step_data>-bmid = /adz/cl_mdc_datex_utility=>get_bmid(
*****            iv_sender_intcode           = lv_own_intcode
*****            iv_receiver_intcode         = <fs_serviceprovider>-service_cat
*****            iv_responsible_intcode      = lv_responsible_intcode
*****            iv_flag_receiver_future     = <fs_serviceprovider>-is_new
*****            iv_flag_took_over_role_resp = lv_flag_took_over_role_resp
*****            is_proc_data                = cs_proc_data ).
*****          IF <fs_proc_step_data>-bmid IS NOT INITIAL.
*****            <fs_proc_step_data>-assoc_servprov = <fs_serviceprovider>-service_id.
*****            DELETE lt_serviceprovider.
*****            EXIT.
*****          ENDIF.
*****        ENDLOOP.
*****        IF <fs_proc_step_data>-assoc_servprov IS INITIAL. "Lieferant(neu)
*****          LOOP AT lt_serviceprovider ASSIGNING <fs_serviceprovider>
*****            WHERE service_cat = /idxgc/if_constants=>gc_service_code_supplier AND is_new = abap_true.
*****            <fs_proc_step_data>-bmid = /adz/cl_mdc_datex_utility=>get_bmid(
*****              iv_sender_intcode           = lv_own_intcode
*****              iv_receiver_intcode         = <fs_serviceprovider>-service_cat
*****              iv_responsible_intcode      = lv_responsible_intcode
*****              iv_flag_receiver_future     = <fs_serviceprovider>-is_new
*****              iv_flag_took_over_role_resp = lv_flag_took_over_role_resp
*****              is_proc_data                = cs_proc_data ).
*****            IF <fs_proc_step_data>-bmid IS NOT INITIAL.
*****              <fs_proc_step_data>-assoc_servprov = <fs_serviceprovider>-service_id.
*****              DELETE lt_serviceprovider.
*****              EXIT.
*****            ENDIF.
*****          ENDLOOP.
*****        ENDIF.
*****        IF <fs_proc_step_data>-assoc_servprov IS INITIAL. "MSB(aktuell)
*****          LOOP AT lt_serviceprovider ASSIGNING <fs_serviceprovider>
*****            WHERE service_cat = /adz/if_mdc_co=>gc_intcode_m1 AND is_new = abap_false.
*****            <fs_proc_step_data>-bmid = /adz/cl_mdc_datex_utility=>get_bmid(
*****              iv_sender_intcode           = lv_own_intcode
*****              iv_receiver_intcode         = <fs_serviceprovider>-service_cat
*****              iv_responsible_intcode      = lv_responsible_intcode
*****              iv_flag_receiver_future     = <fs_serviceprovider>-is_new
*****              iv_flag_took_over_role_resp = lv_flag_took_over_role_resp
*****              is_proc_data                = cs_proc_data ).
*****            IF <fs_proc_step_data>-bmid IS NOT INITIAL.
*****              <fs_proc_step_data>-assoc_servprov = <fs_serviceprovider>-service_id.
*****              DELETE lt_serviceprovider.
*****              EXIT.
*****            ENDIF.
*****          ENDLOOP.
*****        ENDIF.
*****      ENDIF.
*****
******.... 3.2.4. Übrige fremde Empfänger an die Schrittdaten schreiben als NB .........................
*****      DELETE lt_serviceprovider WHERE own_service = abap_true.
*****      LOOP AT lt_serviceprovider ASSIGNING <fs_serviceprovider>.
*****        "BMID temporär in CONTRACT_REF speichern
*****        <fs_serviceprovider>-contract_ref = /adz/cl_mdc_datex_utility=>get_bmid(
*****          iv_sender_intcode           = lv_own_intcode
*****          iv_receiver_intcode         = <fs_serviceprovider>-service_cat
*****          iv_responsible_intcode      = lv_responsible_intcode
*****          iv_flag_receiver_future     = <fs_serviceprovider>-is_new
*****          iv_flag_took_over_role_resp = lv_flag_took_over_role_resp
*****          is_proc_data                = cs_proc_data ).
*****        IF <fs_serviceprovider>-contract_ref IS NOT INITIAL AND <fs_proc_step_data>-bmid CS 'CH1'.
*****          APPEND <fs_serviceprovider> TO <fs_proc_step_data>-serviceprovider.
*****        ENDIF.
*****      ENDLOOP.
*****    ENDIF.
  ENDMETHOD.


  METHOD ADD_SERVPROVS_TO_PROC_DATA.
***************************************************************************************************
* THIMEL-R, 20150726, SDÄ auf Common Layer Engine
*    Ersten Empfänger ermitteln und alle weiteren Empfänger in Schrittdaten schreiben. Falls der
*    Netzbetreiber nur die Rolle Berechtigter hat, dann muss zuerst der Verantwortliche bestimmt
*    werden.
***************************************************************************************************
    DATA: gr_previous            TYPE REF TO cx_root,
          lt_servprov_details    TYPE /idxgc/t_servprov_details,
          lt_edifact_structur    TYPE /adz/mdc_t_edifact_str,
          ls_own_servprov        TYPE /idxgc/s_servprov_details,
          ls_assoc_servprov      TYPE /idxgc/s_servprov_details,
          lv_own_intcode         TYPE /adz/mdc_intcode,
          lv_intcode_responsible TYPE /adz/mdc_intcode.

    FIELD-SYMBOLS: <fs_proc_step_data>   TYPE /idxgc/s_proc_step_data,
                   <fs_servprov_details> TYPE /idxgc/s_servprov_details.

***** 1. Initialisierung von Hilfsstrukturen ******************************************************
*    lt_servprov_details = /adz/cl_mdc_utility=>get_servprovs_for_pod( iv_int_ui = cs_proc_data-int_ui iv_keydate = cs_proc_data-proc_date ).
    READ TABLE cs_proc_data-steps ASSIGNING <fs_proc_step_data> INDEX 1.
*    lt_edifact_structur = /adz/cl_mdc_utility=>get_changes_as_edifact_str( is_proc_step_data = <fs_proc_step_data> ).
    lv_own_intcode = /adz/cl_mdc_customizing=>get_own_intcode( ).

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
*      lv_intcode_responsible = /adz/cl_mdc_customizing=>get_intcode_responsible( it_edifact_structur = lt_edifact_structur ).
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
*          LOOP AT lt_servprov_details ASSIGNING <fs_servprov_details>
*            WHERE service_cat = /adz/if_mdc_co=>gc_intcode_m1 AND is_new = abap_false.
*            <fs_proc_step_data>-assoc_servprov = <fs_servprov_details>-service_id.
*            DELETE lt_servprov_details.
*            EXIT.
*          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.

***** 4. Übrige fremde Empfänger an die Schrittdaten schreiben ************************************
    DELETE lt_servprov_details WHERE own_service = abap_true.
    APPEND LINES OF lt_servprov_details TO <fs_proc_step_data>-serviceprovider.

***** 5. Prüfen, ob Sender und Empfänger gefüllt **************************************************
*    IF <fs_proc_step_data>-own_servprov IS INITIAL.
*      MESSAGE e011(/adz/mdc_datex) INTO gv_mtext.
*      /idxgc/cx_general=>raise_exception_from_msg( ).
*    ENDIF.
*
*    IF <fs_proc_step_data>-assoc_servprov IS INITIAL.
*      MESSAGE e012(/adz/mdc_datex) INTO gv_mtext.
*      /idxgc/cx_general=>raise_exception_from_msg( ).
*    ENDIF.

  ENDMETHOD.


  METHOD CONDENSE_PROC_STEP_DATA.
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


  METHOD CREATE_ERROR_PDOC.
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


  METHOD DISABLE_DATEX.
    cl_isu_datex_controller=>disable_outgoing_process( x_int_ui = iv_int_ui x_dexbasicproc = /adz/if_mdc_co=>gc_dexbasicproc_mdc_dummy ).
  ENDMETHOD.


  METHOD ENABLE_DATEX.
    cl_isu_datex_controller=>disable_outgoing_process( x_enable_communication = abap_true x_int_ui = iv_int_ui x_dexbasicproc = /adz/if_mdc_co=>gc_dexbasicproc_mdc_dummy ).
  ENDMETHOD.


  METHOD GET_BMID.
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
*          lv_start_amid = /adz/cl_mdc_customizing=>get_start_amid( iv_edifact_structur = lv_edifact_structur
*            iv_sender_intcode = iv_sender_intcode iv_receiver_intcode = iv_receiver_intcode
*            iv_flag_sender_future = iv_flag_sender_future iv_flag_receiver_future = iv_flag_receiver_future ).
        ELSE.
*          lv_start_amid_as_resp = /adz/cl_mdc_customizing=>get_start_amid( iv_edifact_structur = lv_edifact_structur
*            iv_sender_intcode = iv_responsible_intcode iv_receiver_intcode = iv_sender_intcode ).
*          lv_start_amid = /adz/cl_mdc_customizing=>get_forward_amid( iv_amid = lv_start_amid_as_resp iv_receiver_intcode = iv_receiver_intcode ).
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


  METHOD GET_SEND_FLAG_FROM_CUSTOMIZING.
***************************************************************************************************
* THIMEL-R, 20150726, SDÄ auf Common Layer Engine
*    Prüfen ob der Versand für Stammdatenänderungen für diesen Prozess aktiv ist. Sobald für eine
*    EDIFACT-Struktur ein aktiver Versand festgestellt wird,
***************************************************************************************************
    DATA: lt_edifact_structur TYPE /adz/mdc_t_edifact_str,
          lv_flag_send        TYPE /adz/mdc_flag_send.

    FIELD-SYMBOLS: <fs_proc_step_data>   TYPE /idxgc/s_proc_step_data,
                   <fv_edifact_structur> TYPE /idxgc/de_edifact_str.

    READ TABLE is_proc_data-steps ASSIGNING <fs_proc_step_data> INDEX 1.
    IF sy-subrc = 0.
*****      lt_edifact_structur = /adz/cl_mdc_utility=>get_changes_as_edifact_str( is_proc_step_data = <fs_proc_step_data> ).
      LOOP AT lt_edifact_structur ASSIGNING <fv_edifact_structur>.
*****        lv_flag_send = /adz/cl_mdc_customizing=>get_send_flag( iv_edifact_structur = <fv_edifact_structur>
*****         iv_keydate = is_proc_data-proc_date iv_assoc_servprov = <fs_proc_step_data>-assoc_servprov ).
        IF lv_flag_send = abap_true.
          rv_flag_send = lv_flag_send.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
      MESSAGE e010(/adz/mdc_datex) INTO gv_mtext.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.

  ENDMETHOD.


  METHOD GET_SEND_FLAG_FROM_DATEX.
***************************************************************************************************
* THIMEL-R, 20150726, SDÄ auf Common Layer Engine
*    Prüfen ob Datenaustausch aktiviert ist.
***************************************************************************************************
    IF cl_isu_datex_controller=>is_not_relevant( x_dexproc = /adz/if_mdc_co=>gc_dexbasicproc_mdc_dummy x_int_ui = iv_int_ui ) = abap_true.
      rt_flag_send = abap_false.
    ELSE.
      rt_flag_send = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD UPDATE_MTD_CODE_RESULT.
***************************************************************************************************
* THIMEL-R, 20150726, SDÄ auf Common Layer Engine
*    Prüfen ob der Versand für Stammdatenänderungen für die ermittelten Änderungen aktiv ist und
*      alle Einträge mit Kennzeichen AKTIV im Customizing behalten.
***************************************************************************************************
    DATA: lv_edifact_structur TYPE /idxgc/de_edifact_str,
          lv_flag_send        TYPE /adz/mdc_flag_send.

    FIELD-SYMBOLS: <fs_proc_step_data>  TYPE /idxgc/s_proc_step_data,
                   <fs_mtd_code_result> TYPE /idxgc/s_mtd_code_details.

    READ TABLE cs_proc_data-steps ASSIGNING <fs_proc_step_data> INDEX 1.
    IF sy-subrc = 0.
      LOOP AT <fs_proc_step_data>-mtd_code_result ASSIGNING <fs_mtd_code_result>.
        lv_edifact_structur = <fs_mtd_code_result>-addinfo.
*****        IF /adz/cl_mdc_customizing=>get_send_flag( iv_edifact_structur = lv_edifact_structur iv_assoc_servprov = <fs_proc_step_data>-assoc_servprov ) = abap_false.
*****          DELETE <fs_proc_step_data>-mtd_code_result.
*****        ENDIF.
      ENDLOOP.
    ELSE.
      MESSAGE e010(/adz/mdc_datex) INTO gv_mtext.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
