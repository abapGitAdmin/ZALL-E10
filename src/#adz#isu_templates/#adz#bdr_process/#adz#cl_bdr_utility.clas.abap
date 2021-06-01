CLASS /adz/cl_bdr_utility DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS check_if_bpem_to_be_closed
      IMPORTING
        !is_ccat_sop     TYPE emmac_ccat_sop
        !iv_mainobjkey   TYPE swo_typeid
      EXPORTING
        !ev_closing_flag TYPE flag .
    CLASS-METHODS check_orders_data
      IMPORTING
        !is_proc_step_data   TYPE /idxgc/s_proc_step_data
      EXPORTING
        VALUE(et_fieldnames) TYPE /idxgc/t_fieldnames
        VALUE(et_errors)     TYPE smt_error_tab .
    CLASS-METHODS get_division_cat
      IMPORTING
        !iv_division           TYPE sparte
      RETURNING
        VALUE(rv_division_cat) TYPE spartyp
      RAISING
        /idxgc/cx_general .
    CLASS-METHODS get_eanl
      IMPORTING
        !iv_int_ui       TYPE int_ui OPTIONAL
        !iv_ext_ui       TYPE ext_ui OPTIONAL
        !iv_installation TYPE anlage OPTIONAL
      RETURNING
        VALUE(rs_eanl)   TYPE eanl
      RAISING
        /idxgc/cx_general .
    CLASS-METHODS get_installation
      IMPORTING
        !iv_ext_ui             TYPE ext_ui OPTIONAL
        !iv_int_ui             TYPE int_ui OPTIONAL
        !iv_keydate            TYPE /idxgc/de_keydate DEFAULT sy-datum
      RETURNING
        VALUE(rv_installation) TYPE anlage
      RAISING
        /idxgc/cx_general .
    CLASS-METHODS get_int_ui
      IMPORTING
        !iv_ext_ui       TYPE ext_ui
        !iv_keydate      TYPE /idxgc/de_keydate DEFAULT sy-datum
      RETURNING
        VALUE(rv_int_ui) TYPE int_ui
      RAISING
        /idxgc/cx_general .
    CLASS-METHODS get_servprov_from_pod
      IMPORTING
        !iv_int_ui         TYPE int_ui
        !iv_keydate        TYPE /idxgc/de_keydate DEFAULT sy-datum
        !iv_own_intcode    TYPE intcode
        !iv_assoc_intcode  TYPE intcode
      EXPORTING
        !ev_own_servprov   TYPE e_dexservprovself
        !ev_assoc_servprov TYPE e_dexservprov
      RAISING
        /idxgc/cx_general .
    CLASS-METHODS get_timezone
      IMPORTING
        !iv_date       TYPE dats DEFAULT sy-datum
        !iv_time       TYPE tims DEFAULT sy-uzeit
      RETURNING
        VALUE(rv_offs) TYPE char3 .
    CLASS-METHODS is_own_intcode
      IMPORTING
        !iv_intcode                   TYPE intcode
      RETURNING
        VALUE(rv_flag_is_own_intcode) TYPE flag
      RAISING
        /idxgc/cx_general .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-DATA gv_msgtxt TYPE string .
    CLASS-DATA gt_tespt TYPE itespt_type .
    CLASS-DATA gt_tecde TYPE eide_service_tab .
ENDCLASS.



CLASS /adz/cl_bdr_utility IMPLEMENTATION.


  METHOD check_if_bpem_to_be_closed.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 14.05.2019
*
* Beschreibung: Prüft ob BPEM Fall geschlossen werden soll.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    IF is_ccat_sop-method = 'EXECUTESOLVINGMETHOD' AND is_ccat_sop-soptxtid CS '/ADZ/BDR'.
      ev_closing_flag = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD check_orders_data.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: WISNIEWSKI-P                                                            Datum: 19.07.2019
*
* Beschreibung: Prüft ob obligatorische Felder gefüllt sind und teilweise ob der Inhalt plausibel
*   ist.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************

    DATA: ls_eservprov_own      TYPE eservprov,
          ls_eservprov_assoc    TYPE eservprov,
          lv_division_cat_own   TYPE spartyp,
          lv_division_cat_assoc TYPE spartyp,
          lv_intcode_own        TYPE intcode,
          lv_intcode_assoc      TYPE intcode,

          ls_error              TYPE smt_error.

    ls_error-msgid = '/ADZ/BDR_MESSAGES'.
    ls_error-msgty = 'E'.

    TRY.
***** Datenermittlung und Prüfungen für alle Nachrichten ******************************************
        CLEAR ls_eservprov_own.

        "Zählpunktbezeichnung
        IF is_proc_step_data-ext_ui IS INITIAL.
          APPEND /idxgc/cl_bdr_orders_req_cntr=>co_fieldname_ext_ui TO et_fieldnames.
          ls_error-msgno = 100.
          APPEND ls_error TO et_errors.
        ENDIF.

        IF is_proc_step_data-own_servprov IS INITIAL.
          APPEND /idxgc/cl_bdr_orders_req_cntr=>co_fieldname_sender TO et_fieldnames.
          ls_error-msgno = 101.
          APPEND ls_error TO et_errors.
        ELSE.
          SELECT SINGLE * FROM eservprov WHERE serviceid = @is_proc_step_data-own_servprov INTO @ls_eservprov_own.
          IF ls_eservprov_own IS INITIAL.
            APPEND /idxgc/cl_bdr_orders_req_cntr=>co_fieldname_sender TO et_fieldnames.
            ls_error-msgno = 110.
            APPEND ls_error TO et_errors.
          ENDIF.
        ENDIF.

        CLEAR ls_eservprov_assoc.
        IF is_proc_step_data-assoc_servprov IS INITIAL.
          APPEND /idxgc/cl_bdr_orders_req_cntr=>co_fieldname_receiver TO et_fieldnames.
          ls_error-msgno = 102.
          APPEND ls_error TO et_errors.
        ELSE.
          SELECT SINGLE * FROM eservprov WHERE serviceid = @is_proc_step_data-assoc_servprov INTO @ls_eservprov_assoc.
          IF ls_eservprov_assoc IS INITIAL.
            APPEND /idxgc/cl_bdr_orders_req_cntr=>co_fieldname_receiver TO et_fieldnames.
            ls_error-msgno = 125.
            APPEND ls_error TO et_errors.
          ENDIF.
        ENDIF.

        IF gt_tecde IS INITIAL.
          SELECT * FROM tecde INTO TABLE @gt_tecde.
        ENDIF.
        IF line_exists( gt_tecde[ service = ls_eservprov_own-service ] ).
          lv_intcode_own      = gt_tecde[ service = ls_eservprov_own-service ]-intcode.
          lv_division_cat_own = /adz/cl_bdr_utility=>get_division_cat( iv_division = gt_tecde[ service = ls_eservprov_own-service ]-division ).
        ENDIF.
        IF line_exists( gt_tecde[ service = ls_eservprov_assoc-service ] ).
          lv_intcode_assoc      = gt_tecde[ service = ls_eservprov_assoc-service ]-intcode.
          lv_division_cat_assoc = /adz/cl_bdr_utility=>get_division_cat( iv_division = gt_tecde[ service = ls_eservprov_assoc-service ]-division ).
        ENDIF.

        "Verschiedene Sparten
        IF lv_division_cat_own IS NOT INITIAL AND lv_division_cat_assoc IS NOT INITIAL.
          IF lv_division_cat_own <> lv_division_cat_assoc.
            APPEND /idxgc/cl_bdr_orders_req_cntr=>co_fieldname_receiver TO et_fieldnames.
            APPEND /idxgc/cl_bdr_orders_req_cntr=>co_fieldname_sender TO et_fieldnames.
            ls_error-msgno = 120.
            APPEND ls_error TO et_errors.
          ENDIF.
        ELSE.
          APPEND /idxgc/cl_bdr_orders_req_cntr=>co_fieldname_sender TO et_fieldnames.
          APPEND /idxgc/cl_bdr_orders_req_cntr=>co_fieldname_receiver TO et_fieldnames.
          ls_error-msgno = 126.
          APPEND ls_error TO et_errors.
        ENDIF.


***** Überprüfe Felder beim Nachrichtentyp Z14 ****************************************************
        IF is_proc_step_data-docname_code = /adz/if_bdr_co=>gc_msg_category_z14.

          "Lieferrichtung
          IF is_proc_step_data-supply_direct IS INITIAL.
            APPEND /idxgc/cl_bdr_orders_req_cntr=>co_fieldname_supply_direct TO et_fieldnames.
            ls_error-msgno = 105.
            APPEND ls_error TO et_errors.
          ELSEIF NOT ( is_proc_step_data-supply_direct = /adz/if_bdr_co=>gc_supply_direct_z06
                    OR is_proc_step_data-supply_direct = /adz/if_bdr_co=>gc_supply_direct_z07 ).
            APPEND /idxgc/cl_bdr_orders_req_cntr=>co_fieldname_supply_direct TO et_fieldnames.
            ls_error-msgno = 109.
            APPEND ls_error TO et_errors.
          ENDIF.

***** Überprüfe Felder beim Nachrichtentyp Z30 ****************************************************
        ELSEIF is_proc_step_data-docname_code = /adz/if_bdr_co=>gc_msg_category_z30.

          "Eigener Serviceanbieter = LF
          IF lv_intcode_own <> /adz/if_bdr_co=>gc_intcode_02. "LF
            APPEND /idxgc/cl_bdr_orders_req_cntr=>co_fieldname_sender TO et_fieldnames.
            ls_error-msgno = 121.
            APPEND ls_error TO et_errors.
          ENDIF.

          "Fremder Serviceanbieter = NB
          IF lv_intcode_assoc <> /adz/if_bdr_co=>gc_intcode_01. "NB
            APPEND /idxgc/cl_bdr_orders_req_cntr=>co_fieldname_receiver TO et_fieldnames.
            ls_error-msgno = 122.
            APPEND ls_error TO et_errors.
          ENDIF.

          "Ausführungsdatum
          IF is_proc_step_data-execution_date IS INITIAL.
            APPEND /adz/if_bdr_co=>gc_fieldname_execution_date TO et_fieldnames.
            ls_error-msgno = 103.
            APPEND ls_error TO et_errors.
          ENDIF.

          "Bilanzierungsverfahren & Gerätekonfiguration
          IF line_exists( is_proc_step_data-ord_item_add[ 1 ] ).
            IF is_proc_step_data-ord_item_add[ 1 ]-settl_proc IS INITIAL.
              APPEND /adz/if_bdr_co=>gc_fieldname_settl_proc TO et_fieldnames.
              ls_error-msgno = 104.
              APPEND ls_error TO et_errors.
            ELSEIF is_proc_step_data-ord_item_add[ 1 ]-settl_proc <> /adz/if_bdr_co=>gc_settl_proc_z38
               AND is_proc_step_data-ord_item_add[ 1 ]-settl_proc <> /adz/if_bdr_co=>gc_settl_proc_z39.
              APPEND /adz/if_bdr_co=>gc_fieldname_settl_proc TO et_fieldnames.
              ls_error-msgno = 108.
              APPEND ls_error TO et_errors.
            ENDIF.
            IF is_proc_step_data-ord_item_add[ 1 ]-device_conf IS INITIAL.
              APPEND /adz/if_bdr_co=>gc_fieldname_device_conf TO et_fieldnames.
              ls_error-msgno = 130.
              APPEND ls_error TO et_errors.
            ELSEIF is_proc_step_data-ord_item_add[ 1 ]-device_conf <> /adz/if_bdr_co=>gc_settl_proc_za9
               AND is_proc_step_data-ord_item_add[ 1 ]-device_conf <> /adz/if_bdr_co=>gc_settl_proc_zb0.
              APPEND /adz/if_bdr_co=>gc_fieldname_device_conf TO et_fieldnames.
              ls_error-msgno = 131.
              APPEND ls_error TO et_errors.
            ENDIF.
          ENDIF.

***** Überprüfe Felder beim Nachrichtentyp Z31 ********************************************
        ELSEIF is_proc_step_data-docname_code = /adz/if_bdr_co=>gc_msg_category_z31.

          "Eigener Serviceanbieter = LF
          IF lv_intcode_own <> /adz/if_bdr_co=>gc_intcode_01. "NB
            APPEND /idxgc/cl_bdr_orders_req_cntr=>co_fieldname_sender TO et_fieldnames.
            ls_error-msgno = 121.
            APPEND ls_error TO et_errors.
          ENDIF.

          "Fremder Serviceanbieter = NB
          IF lv_intcode_assoc <> /adz/if_bdr_co=>gc_intcode_m1. "MSB
            APPEND /idxgc/cl_bdr_orders_req_cntr=>co_fieldname_receiver TO et_fieldnames.
            ls_error-msgno = 122.
            APPEND ls_error TO et_errors.
          ENDIF.

          "Ausführungsdatum
          IF is_proc_step_data-execution_date IS INITIAL.
            APPEND /adz/if_bdr_co=>gc_fieldname_execution_date TO et_fieldnames.
            ls_error-msgno = 103.
            APPEND ls_error TO et_errors.
          ENDIF.


          IF line_exists( is_proc_step_data-reg_code_data[ 1 ] ).
            "OBIS-Kennziffer
            IF is_proc_step_data-reg_code_data[ 1 ]-reg_code IS INITIAL.
              APPEND /adz/if_bdr_co=>gc_fieldname_kennziff TO et_fieldnames.
              ls_error-msgno = 150.
              APPEND ls_error TO et_errors.
            ENDIF.

            "Schwachlast
            IF is_proc_step_data-reg_code_data[ 1 ]-tarif_alloc IS NOT INITIAL
               AND is_proc_step_data-reg_code_data[ 1 ]-tarif_alloc <> /adz/if_bdr_co=>gc_tarif_alloc_z59
               AND is_proc_step_data-reg_code_data[ 1 ]-tarif_alloc <> /adz/if_bdr_co=>gc_tarif_alloc_z60.
              APPEND /adz/if_bdr_co=>gc_fieldname_tarif_alloc TO et_fieldnames.
              ls_error-msgno = 152.
              APPEND ls_error TO et_errors.
            ENDIF.

            "Verbrauchsart
            IF is_proc_step_data-reg_code_data[ 1 ]-cons_type IS NOT INITIAL
               AND is_proc_step_data-reg_code_data[ 1 ]-cons_type <> /adz/if_bdr_co=>gc_cons_type_z64
               AND is_proc_step_data-reg_code_data[ 1 ]-cons_type <> /adz/if_bdr_co=>gc_cons_type_z65
               AND is_proc_step_data-reg_code_data[ 1 ]-cons_type <> /adz/if_bdr_co=>gc_cons_type_z66
               AND is_proc_step_data-reg_code_data[ 1 ]-cons_type <> /adz/if_bdr_co=>gc_cons_type_z87
               AND is_proc_step_data-reg_code_data[ 1 ]-cons_type <> /adz/if_bdr_co=>gc_cons_type_za8
               AND is_proc_step_data-reg_code_data[ 1 ]-cons_type <> /adz/if_bdr_co=>gc_cons_type_zb3.
              APPEND /adz/if_bdr_co=>gc_fieldname_cons_type TO et_fieldnames.
              ls_error-msgno = 154.
              APPEND ls_error TO et_errors.
            ENDIF.

            "Unterbrechbarkeit
            IF is_proc_step_data-reg_code_data[ 1 ]-appl_interrupt IS NOT INITIAL
               AND is_proc_step_data-reg_code_data[ 1 ]-appl_interrupt <> /adz/if_bdr_co=>gc_appl_interrupt_z62
               AND is_proc_step_data-reg_code_data[ 1 ]-appl_interrupt <> /adz/if_bdr_co=>gc_appl_interrupt_z63.
              APPEND /adz/if_bdr_co=>gc_fieldname_appl_interrupt TO et_fieldnames.
              ls_error-msgno = 156.
              APPEND ls_error TO et_errors.
            ENDIF.

            "Wärmenutzung
            IF is_proc_step_data-reg_code_data[ 1 ]-heat_consumpt IS NOT INITIAL
               AND is_proc_step_data-reg_code_data[ 1 ]-heat_consumpt <> /adz/if_bdr_co=>gc_heat_consumpt_z56
               AND is_proc_step_data-reg_code_data[ 1 ]-heat_consumpt <> /adz/if_bdr_co=>gc_heat_consumpt_z57
               AND is_proc_step_data-reg_code_data[ 1 ]-heat_consumpt <> /adz/if_bdr_co=>gc_heat_consumpt_z61.
              APPEND /adz/if_bdr_co=>gc_fieldname_heat_consumpt TO et_fieldnames.
              ls_error-msgno = 158.
              APPEND ls_error TO et_errors.
            ENDIF.
          ENDIF.

***** Überprüfe Felder beim Nachrichtentyp Z34 ****************************************************
        ELSEIF is_proc_step_data-docname_code = /adz/if_bdr_co=>gc_msg_category_z34.

          "Lieferrichtung
          IF is_proc_step_data-supply_direct IS INITIAL.
            APPEND /idxgc/cl_bdr_orders_req_cntr=>co_fieldname_supply_direct TO et_fieldnames.
            ls_error-msgno = 105.
            APPEND ls_error TO et_errors.
          ELSEIF NOT ( is_proc_step_data-supply_direct = /adz/if_bdr_co=>gc_supply_direct_z06
                    OR is_proc_step_data-supply_direct = /adz/if_bdr_co=>gc_supply_direct_z07 ).
            APPEND /idxgc/cl_bdr_orders_req_cntr=>co_fieldname_supply_direct TO et_fieldnames.
            ls_error-msgno = 109.
            APPEND ls_error TO et_errors.
          ENDIF.

          "Kommentar-Qualifier
          IF line_exists( is_proc_step_data-msgcomments[ 1 ] ).
            IF is_proc_step_data-msgcomments[ 1 ]-text_subj_qual IS INITIAL.
              APPEND /adz/if_bdr_co=>gc_fieldname_text_subj_qual TO et_fieldnames.
              ls_error-msgno = 106.
              APPEND ls_error TO et_errors.
            ELSEIF NOT ( is_proc_step_data-msgcomments[ 1 ]-text_subj_qual = /adz/if_bdr_co=>gc_text_subj_qual_z04
                      OR is_proc_step_data-msgcomments[ 1 ]-text_subj_qual = /adz/if_bdr_co=>gc_text_subj_qual_z05
                      OR is_proc_step_data-msgcomments[ 1 ]-text_subj_qual = /adz/if_bdr_co=>gc_text_subj_qual_z06 ).
              APPEND /adz/if_bdr_co=>gc_fieldname_text_subj_qual TO et_fieldnames.
              ls_error-msgno = 109.
              APPEND ls_error TO et_errors.
            ENDIF.
          ENDIF.

          IF  lv_division_cat_own <> /adz/if_bdr_co=>gc_division_cat_01 AND (
              is_proc_step_data-serv_measval = /idxgc/if_constants_ide=>gc_imd_chardesc_code_z12 OR
              is_proc_step_data-serv_measval = /adz/if_bdr_co=>gc_imd_chardesc_code_z35 ).
            APPEND /idxgc/cl_bdr_orders_req_cntr=>co_fieldname_sender TO et_fieldnames.
            ls_error-msgno = 129.
            APPEND ls_error TO et_errors.

          ENDIF.

          "Serviceanbieter
          "Strom mit Format ab 01.12.2019
          IF lv_division_cat_own = /adz/if_bdr_co=>gc_division_cat_01 AND
             /adz/cl_bdr_customizing=>get_format_setting( ) = /adz/if_bdr_co=>gc_format_setting_02.
            "Eigener Serviceanbieter
            IF lv_intcode_own <> /adz/if_bdr_co=>gc_intcode_02 AND "LF
               lv_intcode_own <> /adz/if_bdr_co=>gc_intcode_01 AND "NB
               lv_intcode_own <> /adz/if_bdr_co=>gc_intcode_90 AND "ÜNB
               lv_intcode_own <> /adz/if_bdr_co=>gc_intcode_m1.    "MSB
              APPEND /idxgc/cl_bdr_orders_req_cntr=>co_fieldname_sender TO et_fieldnames.
              ls_error-msgno = 123.
              APPEND ls_error TO et_errors.
            ENDIF.
            "Fremder Serviceanbieter
            IF lv_intcode_assoc <> /adz/if_bdr_co=>gc_intcode_m1. "MSB
              APPEND /idxgc/cl_bdr_orders_req_cntr=>co_fieldname_receiver TO et_fieldnames.
              ls_error-msgno = 124.
              APPEND ls_error TO et_errors.
            ENDIF.
            "Gas oder Strom mit Format ab 01.10.2017
          ELSE.
            "Eigener Serviceanbieter
            IF lv_intcode_own <> /adz/if_bdr_co=>gc_intcode_02. "LF
              APPEND /idxgc/cl_bdr_orders_req_cntr=>co_fieldname_sender TO et_fieldnames.
              ls_error-msgno = 121.
              APPEND ls_error TO et_errors.
            ENDIF.
            "Fremder Serviceanbieter
            IF lv_intcode_assoc <> /adz/if_bdr_co=>gc_intcode_01. "NB
              APPEND /idxgc/cl_bdr_orders_req_cntr=>co_fieldname_receiver TO et_fieldnames.
              ls_error-msgno = 122.
              APPEND ls_error TO et_errors.
            ENDIF.
          ENDIF.

          "Referenzierte Nachricht
          IF line_exists( is_proc_step_data-ref_to_msg[ 1 ] ).
            IF is_proc_step_data-ref_to_msg[ 1 ]-ref_no IS INITIAL.
              APPEND /adz/if_bdr_co=>gc_fieldname_ref_no TO et_fieldnames.
              ls_error-msgno = 111.
              APPEND ls_error TO et_errors.
            ENDIF.
            IF is_proc_step_data-ref_to_msg[ 1 ]-ref_msg_date IS INITIAL.
              APPEND /adz/if_bdr_co=>gc_fieldname_ref_msg_date TO et_fieldnames.
              ls_error-msgno = 112.
              APPEND ls_error TO et_errors.
            ENDIF.
            IF is_proc_step_data-ref_to_msg[ 1 ]-ref_msg_time IS INITIAL.
              APPEND /adz/if_bdr_co=>gc_fieldname_ref_msg_time TO et_fieldnames.
              ls_error-msgno = 113.
              APPEND ls_error TO et_errors.
            ENDIF.
          ENDIF.

          "Zählwerks-Kennziffer
          IF line_exists( is_proc_step_data-reg_code_data[ 1 ] ).
            IF is_proc_step_data-reg_code_data[ 1 ]-reg_code IS INITIAL.
              APPEND /adz/if_bdr_co=>gc_fieldname_reg_code TO et_fieldnames.
              ls_error-msgno = 107.
              APPEND ls_error TO et_errors.
            ENDIF.
          ENDIF.

          "Beginn und Ende
          IF line_exists( is_proc_step_data-ord_item_add[ 1 ] ).
            IF is_proc_step_data-ord_item_add[ 1 ]-start_read_date IS INITIAL.
              APPEND /adz/if_bdr_co=>gc_fieldname_start_read_date TO et_fieldnames.
              ls_error-msgno = 114.
              APPEND ls_error TO et_errors.
            ENDIF.
            IF is_proc_step_data-ord_item_add[ 1 ]-start_read_time = ''. "Initial ist 000000 und gültig.
              APPEND /adz/if_bdr_co=>gc_fieldname_start_read_time TO et_fieldnames.
              ls_error-msgno = 115.
              APPEND ls_error TO et_errors.
            ENDIF.
            IF is_proc_step_data-ord_item_add[ 1 ]-start_read_offs IS INITIAL.
              APPEND /adz/if_bdr_co=>gc_fieldname_start_read_offs TO et_fieldnames.
              ls_error-msgno = 116.
              APPEND ls_error TO et_errors.
            ENDIF.
            IF is_proc_step_data-ord_item_add[ 1 ]-end_read_date IS INITIAL.
              APPEND /adz/if_bdr_co=>gc_fieldname_end_read_date TO et_fieldnames.
              ls_error-msgno = 117.
              APPEND ls_error TO et_errors.
            ENDIF.
            IF is_proc_step_data-ord_item_add[ 1 ]-end_read_time = ''. "Initial ist 000000 und gültig.
              APPEND /adz/if_bdr_co=>gc_fieldname_end_read_time TO et_fieldnames.
              ls_error-msgno = 118.
              APPEND ls_error TO et_errors.
            ENDIF.
            IF is_proc_step_data-ord_item_add[ 1 ]-end_read_offs IS INITIAL.
              APPEND /adz/if_bdr_co=>gc_fieldname_end_read_offs TO et_fieldnames.
              ls_error-msgno = 119.
              APPEND ls_error TO et_errors.
            ENDIF.
          ENDIF.
        ENDIF.

      CATCH /idxgc/cx_general.
        et_errors = VALUE #( ( msgid = sy-msgid msgno = sy-msgno msgty = sy-msgty msgv1 = sy-msgv1
                               msgv2 = sy-msgv2 msgv3 = sy-msgv3 msgv4 = sy-msgv4 ) ).
    ENDTRY.
  ENDMETHOD.


  METHOD get_division_cat.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: WISNIEWSKI-P, THIMEL-R                                                  Datum: 19.07.2019
*
* Beschreibung: Bestimmt den Spartentyp zur Sparte.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************

    IF gt_tespt IS INITIAL.
      SELECT * FROM tespt INTO TABLE @gt_tespt.
    ENDIF.

    IF line_exists( gt_tespt[ sparte = iv_division ] ).
      rv_division_cat = gt_tespt[ sparte = iv_division ]-spartyp.
    ELSE.
      MESSAGE e001(/adz/bdr_messages) WITH 'TESPT' iv_division INTO gv_msgtxt.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.

  ENDMETHOD.


  METHOD get_eanl.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 13.05.2019
*
* Beschreibung: Liest die Tabelle EANL zu einem Zählpunkt oder einer Anlage.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    DATA: lv_installation TYPE anlage.

    IF iv_installation IS NOT INITIAL.
      lv_installation = iv_installation.
    ELSEIF iv_int_ui IS NOT INITIAL.
      lv_installation = get_installation( iv_int_ui = iv_int_ui ).
    ELSEIF iv_ext_ui IS NOT INITIAL.
      lv_installation = get_installation( iv_ext_ui = iv_ext_ui ).
    ENDIF.

    SELECT SINGLE * FROM eanl INTO rs_eanl WHERE anlage = lv_installation.

    IF rs_eanl IS INITIAL.
      MESSAGE e001(/adz/bdr_messages) WITH 'EANL' lv_installation INTO gv_msgtxt.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD get_installation.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 15.05.2019
*
* Beschreibung: Bestimmt Anlage zu einem Zählpunkt.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    DATA: lv_int_ui    TYPE          int_ui,
          lt_euiinstln TYPE TABLE OF euiinstln.

    FIELD-SYMBOLS: <fs_euiinstln> TYPE euiinstln.

    IF iv_int_ui IS NOT INITIAL.
      lv_int_ui = iv_int_ui.
    ELSEIF iv_ext_ui IS NOT INITIAL.
      lv_int_ui = get_int_ui( iv_ext_ui = iv_ext_ui iv_keydate = iv_keydate ).
    ELSE.

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
      MESSAGE e001(/adz/bdr_messages) WITH 'EUIINSTLN' lv_int_ui INTO gv_msgtxt.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.

    IF lines( lt_euiinstln ) = 1.
      rv_installation = lt_euiinstln[ 1 ]-anlage.
    ENDIF.

  ENDMETHOD.


  METHOD get_int_ui.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 14.05.2019
*
* Beschreibung: Ermittelt internen Zählpunkt.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    DATA: ls_euitrans TYPE euitrans.

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
      MESSAGE i001(/adz/bdr_messages) WITH 'EUITRANS' iv_ext_ui INTO gv_msgtxt.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ELSE.
      rv_int_ui = ls_euitrans-int_ui.
    ENDIF.
  ENDMETHOD.


  METHOD get_servprov_from_pod.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 14.05.2019
*
* Beschreibung: Holt Serviceanbieter aus Versorgungsszenario holen.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    DATA: lr_previous         TYPE REF TO cx_root,
          lt_servprov_details TYPE /idxgc/t_servprov_details.

    TRY.
        /idxgc/cl_utility_isu_add=>get_servprov_onpod( EXPORTING iv_int_ui           = iv_int_ui
                                                                 iv_keydate          = iv_keydate
                                                       IMPORTING et_servprov_details = lt_servprov_details ).
      CATCH /idxgc/cx_utility_error INTO lr_previous.
        /idxgc/cx_general=>raise_exception_from_msg( ir_previous = lr_previous ).
    ENDTRY.

    LOOP AT lt_servprov_details ASSIGNING FIELD-SYMBOL(<ls_servprov_details>).
      CASE <ls_servprov_details>-service_cat.
        WHEN iv_assoc_intcode.
          ev_assoc_servprov = <ls_servprov_details>-service_id.
        WHEN iv_own_intcode.
          ev_own_servprov = <ls_servprov_details>-service_id.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_timezone.
************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: WISNIEWSKI-P, THIMEL-R                       Datum: 06.12.2019
*
* Beschreibung: Zeitzone ermitteln
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************
    DATA: lv_time_utc TYPE tims,
          lv_diff_utc TYPE tims,
          lv_date_utc TYPE dats,
          lv_pre_sign TYPE char1,
          lv_date     TYPE char35.

    CALL FUNCTION 'ISU_DATE_TIME_CONVERT_UTC'
      EXPORTING
        x_date     = iv_date
        x_time     = iv_time
        x_timezone = sy-zonlo
      IMPORTING
        y_date_utc = lv_date_utc
        y_time_utc = lv_time_utc.

    IF iv_date > lv_date_utc.
      lv_diff_utc = iv_time - lv_time_utc.
      lv_pre_sign  = '+'.
    ELSEIF iv_date < lv_date_utc.
      lv_diff_utc = lv_time_utc - iv_time.
      lv_pre_sign  = '-'.
    ELSEIF iv_date = lv_date_utc.
      IF iv_time > lv_time_utc.
        lv_diff_utc = iv_time - lv_time_utc.
        lv_pre_sign  = '+'.
      ELSEIF  iv_time < lv_time_utc.
        lv_diff_utc = lv_time_utc - iv_time.
        lv_pre_sign  = '-'.
      ENDIF.
    ENDIF.
    lv_date(2) = lv_diff_utc.

    rv_offs = |{ lv_pre_sign }{ lv_date }|.

  ENDMETHOD.


  METHOD is_own_intcode.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 27.05.2019
*
* Beschreibung: Überprüft ob der Servicetyp erfüllt wird.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************

    IF /adz/cl_bdr_customizing=>get_own_intcode_1( ) = iv_intcode OR /adz/cl_bdr_customizing=>get_own_intcode_2( ) = iv_intcode.
      rv_flag_is_own_intcode = abap_true.
    ELSE.
      rv_flag_is_own_intcode = abap_false.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
