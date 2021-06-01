class /ADZ/CL_MDC_CHECK_METHOD definition
  public
  final
  create public .

public section.

  class-methods CHECK_ALREADY_EXCH_METER_PROC
    importing
      !IS_PROCESS_STEP_KEY type /IDXGC/S_PROC_STEP_KEY
    exporting
      !ET_CHECK_RESULT type /IDXGC/T_CHECK_RESULT
    changing
      !CR_DATA type ref to DATA
      !CR_DATA_LOG type ref to DATA
    raising
      /IDXGC/CX_UTILITY_ERROR .
  class-methods CHECK_ALREADY_EXCH_POD_TYPE
    importing
      !IS_PROCESS_STEP_KEY type /IDXGC/S_PROC_STEP_KEY
    exporting
      !ET_CHECK_RESULT type /IDXGC/T_CHECK_RESULT
    changing
      !CR_DATA type ref to DATA
      !CR_DATA_LOG type ref to DATA
    raising
      /IDXGC/CX_UTILITY_ERROR .
  class-methods CHECK_COMPARE_RESULT
    importing
      !IS_PROCESS_STEP_KEY type /IDXGC/S_PROC_STEP_KEY
    exporting
      !ET_CHECK_RESULT type /IDXGC/T_CHECK_RESULT
    changing
      !CR_DATA type ref to DATA
      !CR_DATA_LOG type ref to DATA
    raising
      /IDXGC/CX_UTILITY_ERROR .
  class-methods CHECK_DISTRIBUTOR_ASSIGNMENT
    importing
      !IS_PROCESS_STEP_KEY type /IDXGC/S_PROC_STEP_KEY
    exporting
      !ET_CHECK_RESULT type /IDXGC/T_CHECK_RESULT
    changing
      !CR_DATA type ref to DATA
      !CR_DATA_LOG type ref to DATA .
  class-methods CHECK_NOTIFICATION_PERIOD
    importing
      !IS_PROCESS_STEP_KEY type /IDXGC/S_PROC_STEP_KEY
    exporting
      !ET_CHECK_RESULT type /IDXGC/T_CHECK_RESULT
    changing
      !CR_DATA type ref to DATA
      !CR_DATA_LOG type ref to DATA
    raising
      /IDXGC/CX_UTILITY_ERROR .
  class-methods CHECK_POD_MALO_EXIST
    importing
      !IS_PROCESS_STEP_KEY type /IDXGC/S_PROC_STEP_KEY
    exporting
      !ET_CHECK_RESULT type /IDXGC/T_CHECK_RESULT
    changing
      !CR_DATA type ref to DATA
      !CR_DATA_LOG type ref to DATA
    raising
      /IDXGC/CX_UTILITY_ERROR .
  class-methods CHECK_PROCESSING_TYPE_AUTH
    importing
      !IS_PROCESS_STEP_KEY type /IDXGC/S_PROC_STEP_KEY
    exporting
      !ET_CHECK_RESULT type /IDXGC/T_CHECK_RESULT
    changing
      !CR_DATA type ref to DATA
      !CR_DATA_LOG type ref to DATA
    raising
      /IDXGC/CX_UTILITY_ERROR .
  class-methods CHECK_RESP_MSG_TYPE
    importing
      !IS_PROCESS_STEP_KEY type /IDXGC/S_PROC_STEP_KEY
    exporting
      !ET_CHECK_RESULT type /IDXGC/T_CHECK_RESULT
    changing
      !CR_DATA type ref to DATA
      !CR_DATA_LOG type ref to DATA
    raising
      /IDXGC/CX_UTILITY_ERROR .
  class-methods CHECK_SYNC_NECESSARY
    importing
      !IS_PROCESS_STEP_KEY type /IDXGC/S_PROC_STEP_KEY
    exporting
      !ET_CHECK_RESULT type /IDXGC/T_CHECK_RESULT
    changing
      !CR_DATA type ref to DATA
      !CR_DATA_LOG type ref to DATA
    raising
      /IDXGC/CX_UTILITY_ERROR .
  class-methods CHECK_WAIT_TIME_FOR_UPDATE
    importing
      !IS_PROCESS_STEP_KEY type /IDXGC/S_PROC_STEP_KEY
    exporting
      !ET_CHECK_RESULT type /IDXGC/T_CHECK_RESULT
    changing
      !CR_DATA type ref to DATA
      !CR_DATA_LOG type ref to DATA
    raising
      /IDXGC/CX_UTILITY_ERROR .
  class-methods UPDATE_COMPARE_RESULT
    importing
      !IS_PROCESS_STEP_KEY type /IDXGC/S_PROC_STEP_KEY
    exporting
      !ET_CHECK_RESULT type /IDXGC/T_CHECK_RESULT
    changing
      !CR_DATA type ref to DATA
      !CR_DATA_LOG type ref to DATA
    raising
      /IDXGC/CX_UTILITY_ERROR .
  class-methods UPDATE_COMPARE_RESULT_SELECT
    importing
      !IS_PROCESS_STEP_KEY type /IDXGC/S_PROC_STEP_KEY
    exporting
      !ET_CHECK_RESULT type /IDXGC/T_CHECK_RESULT
    changing
      !CR_DATA type ref to DATA
      !CR_DATA_LOG type ref to DATA
    raising
      /IDXGC/CX_UTILITY_ERROR .
  class-methods UPDATE_RECEIVER_SYNC
    importing
      !IS_PROCESS_STEP_KEY type /IDXGC/S_PROC_STEP_KEY
    exporting
      !ET_CHECK_RESULT type /IDXGC/T_CHECK_RESULT
    changing
      !CR_DATA type ref to DATA
      !CR_DATA_LOG type ref to DATA
    raising
      /IDXGC/CX_UTILITY_ERROR .
  class-methods UPDATE_STEP_DATA_FROM_SYSTEM
    importing
      !IS_PROCESS_STEP_KEY type /IDXGC/S_PROC_STEP_KEY
    exporting
      !ET_CHECK_RESULT type /IDXGC/T_CHECK_RESULT
    changing
      !CR_DATA type ref to DATA
      !CR_DATA_LOG type ref to DATA
    raising
      /IDXGC/CX_UTILITY_ERROR .
  class-methods UPDATE_STEP_DATA_START_SYNC
    importing
      !IS_PROCESS_STEP_KEY type /IDXGC/S_PROC_STEP_KEY
    exporting
      !ET_CHECK_RESULT type /IDXGC/T_CHECK_RESULT
    changing
      !CR_DATA type ref to DATA
      !CR_DATA_LOG type ref to DATA
    raising
      /IDXGC/CX_UTILITY_ERROR .
  class-methods UPDATE_SYSTEM_FROM_MESSAGE
    importing
      !IS_PROCESS_STEP_KEY type /IDXGC/S_PROC_STEP_KEY
    exporting
      !ET_CHECK_RESULT type /IDXGC/T_CHECK_RESULT
    changing
      !CR_DATA type ref to DATA
      !CR_DATA_LOG type ref to DATA
    raising
      /IDXGC/CX_UTILITY_ERROR .
  PROTECTED SECTION.

    CLASS-DATA ssv_msgtxt TYPE string .
  PRIVATE SECTION.

    CLASS-DATA gv_msgtxt TYPE string .
    CLASS-DATA gx_previous TYPE REF TO cx_root .
ENDCLASS.



CLASS /ADZ/CL_MDC_CHECK_METHOD IMPLEMENTATION.


  METHOD check_already_exch_meter_proc.
************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: ILIASS ECHOUAIBI                                Datum: 07.11.2019
*
* Beschreibung:
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************


*    DATA: lr_process_data_step  TYPE REF TO /idxgc/if_process_data_step,
*          ls_proc_step_data     TYPE /idxgc/s_proc_step_data_all,
*          ls_proc_step_data_src TYPE /idxgc/s_proc_step_data_all,
*          ls_proc_step_key      TYPE /idxgc/s_proc_step_key,
*          ls_proc_config        TYPE /idxgc/s_proc_config_all,
*          lv_class_name         TYPE seoclsname,
*          lv_method_name        TYPE seocpdname.
*
*    FIELD-SYMBOLS: <fr_process_log>      TYPE REF TO /idxgc/if_process_log,
*                   <fr_proc_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
*                   <fs_proc_step_config> TYPE /idxgc/s_proc_step_config_all,
*                   <fs_diverse>          TYPE /idxgc/s_diverse_details,
*                   <fs_diverse_src>      TYPE /idxgc/s_diverse_details.
*
*    ASSIGN cr_data_log->* TO <fr_process_log>.
*    ASSIGN cr_data->* TO <fr_proc_data_extern>.
*    lr_process_data_step ?= <fr_proc_data_extern>.
*
****** Schrittdaten vom aktuellen Schritt holen ****************************************************
*    TRY.
*        ls_proc_step_data = lr_process_data_step->get_process_step_data( is_process_step_key ).
*      CATCH /idxgc/cx_process_error INTO gr_previous .
*        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
*    ENDTRY.
*
****** Schrittdaten vom zusätzlichem Quellschritt holen ********************************************
*    TRY.
*        /idxgc/cl_cust_access=>/idxgc/if_cust_access~get_process_config( EXPORTING iv_process_id = ls_proc_step_data-proc_id IMPORTING es_process_config = ls_proc_config ).
*      CATCH /idxgc/cx_config_error INTO gr_previous.
*        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
*    ENDTRY.
*
*    READ TABLE ls_proc_config-steps ASSIGNING <fs_proc_step_config> WITH KEY proc_step_no = is_process_step_key-proc_step_no.
*    IF sy-subrc = 0.
*      ls_proc_step_key-proc_id  = is_process_step_key-proc_id.
*      IF <fs_proc_step_config>-proc_step_src IS NOT INITIAL.
*        ls_proc_step_key-proc_step_no = <fs_proc_step_config>-proc_step_src.
*        TRY.
*            ls_proc_step_data_src = lr_process_data_step->get_process_step_data( ls_proc_step_key ).
*          CATCH /idxgc/cx_process_error INTO gr_previous .
*            /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
*        ENDTRY.
*      ENDIF.
*    ENDIF.
*
****** Methodenlogik *******************************************************************************
*    READ TABLE ls_proc_step_data-diverse ASSIGNING <fs_diverse> INDEX 1.
*    READ TABLE ls_proc_step_data_src-diverse ASSIGNING <fs_diverse_src> INDEX 1.
*    IF <fs_diverse> IS ASSIGNED AND <fs_diverse_src> IS ASSIGNED AND
*       <fs_diverse>-exch_meter_proc = <fs_diverse_src>-exch_meter_proc.
*      APPEND /ADZ/IF_MDC_CO=>gc_cr_exch_meter_proc_equal TO et_check_result.
*    ELSE.
*      APPEND /ADZ/IF_MDC_CO=>gc_cr_exch_meter_proc_unequal TO et_check_result.
*    ENDIF.

    et_check_result = VALUE #( ( /adz/if_mdc_co=>gc_cr-meter_proc_equal ) ). "gc_cr_exch_meter_proc_equal
  ENDMETHOD.


  METHOD check_already_exch_pod_type.
************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: ILIASS ECHOUAIBI                                     Datum: 07.11.2019
*
* Beschreibung:
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************


*  DATA: lr_process_data_step  TYPE REF TO /idxgc/if_process_data_step,
*          ls_proc_step_data     TYPE /idxgc/s_proc_step_data_all,
*          ls_proc_step_data_src TYPE /idxgc/s_proc_step_data_all,
*          ls_proc_step_key      TYPE /idxgc/s_proc_step_key,
*          ls_proc_config        TYPE /idxgc/s_proc_config_all,
*          lv_class_name         TYPE seoclsname,
*          lv_method_name        TYPE seocpdname.
*
*    FIELD-SYMBOLS: <fr_process_log>      TYPE REF TO /idxgc/if_process_log,
*                   <fr_proc_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
*                   <fs_proc_step_config> TYPE /idxgc/s_proc_step_config_all,
*                   <fs_pod>              TYPE /idxgc/s_pod_info_details,
*                   <fs_pod_src>          TYPE /idxgc/s_pod_info_details.
*
*    ASSIGN cr_data_log->* TO <fr_process_log>.
*    ASSIGN cr_data->* TO <fr_proc_data_extern>.
*    lr_process_data_step ?= <fr_proc_data_extern>.
*
****** Schrittdaten vom aktuellen Schritt holen ****************************************************
*    TRY.
*        ls_proc_step_data = lr_process_data_step->get_process_step_data( is_process_step_key ).
*      CATCH /idxgc/cx_process_error INTO gr_previous .
*        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
*    ENDTRY.
*
****** Schrittdaten vom zusätzlichem Quellschritt holen ********************************************
*    TRY.
*        /idxgc/cl_cust_access=>/idxgc/if_cust_access~get_process_config( EXPORTING iv_process_id = ls_proc_step_data-proc_id IMPORTING es_process_config = ls_proc_config ).
*      CATCH /idxgc/cx_config_error INTO gr_previous.
*        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
*    ENDTRY.
*
*    READ TABLE ls_proc_config-steps ASSIGNING <fs_proc_step_config> WITH KEY proc_step_no = is_process_step_key-proc_step_no.
*    IF sy-subrc = 0.
*      ls_proc_step_key-proc_id  = is_process_step_key-proc_id.
*      IF <fs_proc_step_config>-proc_step_src IS NOT INITIAL.
*        ls_proc_step_key-proc_step_no = <fs_proc_step_config>-proc_step_src.
*        TRY.
*            ls_proc_step_data_src = lr_process_data_step->get_process_step_data( ls_proc_step_key ).
*          CATCH /idxgc/cx_process_error INTO gr_previous .
*            /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
*        ENDTRY.
*      ENDIF.
*    ENDIF.
*
****** Methodenlogik *******************************************************************************
*    READ TABLE ls_proc_step_data-pod ASSIGNING <fs_pod> INDEX 1.
*    READ TABLE ls_proc_step_data_src-pod ASSIGNING <fs_pod_src> INDEX 1.
*    IF <fs_pod> IS ASSIGNED AND <fs_pod_src> IS ASSIGNED AND
*       <fs_pod>-exch_pod_type = <fs_pod_src>-exch_pod_type.
*      APPEND /ADZ/IF_MDC_CO=>gc_cr_exch_pod_type_equal TO et_check_result.
*    ELSE.
*      APPEND /ADZ/IF_MDC_CO=>gc_cr_exch_pod_type_unequal TO et_check_result.
*    ENDIF.

    et_check_result = VALUE #( ( /adz/if_mdc_co=>gc_cr-pod_type_equal ) ). "gc_cr_exch_pod_type_equal
  ENDMETHOD.


  METHOD check_compare_result.
************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: ILIASS ECHOUAIBI                                     Datum: 07.11.2019
*
* Beschreibung:
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************

*   DATA: lr_process_data_step TYPE REF TO /idxgc/if_process_data_step,
*          ls_proc_step_data    TYPE /idxgc/s_proc_step_data_all.
*
*    FIELD-SYMBOLS: <fr_process_log>      TYPE REF TO /idxgc/if_process_log,
*                   <fr_proc_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
*                   <fs_mtd_code_result>  TYPE /idxgc/s_mtd_code_details.
*
*    ASSIGN cr_data_log->* TO <fr_process_log>.
*    ASSIGN cr_data->* TO <fr_proc_data_extern>.
*    lr_process_data_step ?= <fr_proc_data_extern>.
*
****** Schrittdaten vom aktuellen Schritt holen ****************************************************
*    TRY.
*        ls_proc_step_data = lr_process_data_step->get_process_step_data( is_process_step_key ).
*      CATCH /idxgc/cx_process_error INTO gr_previous .
*        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
*    ENDTRY.
*
****** Methodenlogik *******************************************************************************
*    LOOP AT ls_proc_step_data-mtd_code_result ASSIGNING <fs_mtd_code_result>.
*      IF <fs_mtd_code_result>-src_field_value <> <fs_mtd_code_result>-cmp_field_value.
*        APPEND /ADZ/IF_MDC_CO=>gc_cr_difference_found TO et_check_result.
*        EXIT.
*      ENDIF.
*    ENDLOOP.
*    IF et_check_result IS INITIAL.
*      APPEND /ADZ/IF_MDC_CO=>gc_cr_no_difference_found TO et_check_result.
*    ENDIF.

    et_check_result = VALUE #( ( /adz/if_mdc_co=>gc_cr-no_difference_found ) ).



  ENDMETHOD.


  METHOD check_distributor_assignment.
************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: ILIASS ECHOUAIBI Thimel Rene                    Datum: 07.11.2019
*
* Beschreibung:
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************

    DATA: lr_process_data_step TYPE REF TO /idxgc/if_process_data_step,
          ls_proc_step_data    TYPE /idxgc/s_proc_step_data_all.

    FIELD-SYMBOLS: <lr_process_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
                   <lr_process_log>         TYPE REF TO /idxgc/if_process_log.

    ASSIGN cr_data->* TO <lr_process_data_extern>.
    ASSIGN cr_data_log->* TO <lr_process_log>.

    IF <lr_process_data_extern> IS ASSIGNED.
      lr_process_data_step ?= <lr_process_data_extern>.
    ELSE.
      MESSAGE e001(/adz/mdc_messages) INTO gv_msgtxt.
      IF <lr_process_log> IS ASSIGNED.
        <lr_process_log>->add_message_to_process_log( is_process_step_key = is_process_step_key ).
      ENDIF.
      et_check_result = VALUE #( ( /idxgc/if_constants_add=>gc_cr_error ) ).
      RETURN.
    ENDIF.

    TRY.
        ls_proc_step_data = lr_process_data_step->get_process_step_data( is_process_step_key ).
      CATCH /idxgc/cx_process_error INTO gx_previous.
        IF <lr_process_log> IS ASSIGNED.
          <lr_process_log>->add_message_to_process_log( is_process_step_key = is_process_step_key ).
        ENDIF.
        et_check_result = VALUE #( ( /idxgc/if_constants_add=>gc_cr_error ) ).
        RETURN.
    ENDTRY.

    /idxgc/cl_utility_isu_add=>get_distributor_assignment( EXPORTING iv_ext_ui      = ls_proc_step_data-ext_ui
                                                                     iv_date        = ls_proc_step_data-proc_date
                                                           IMPORTING ev_distributor = DATA(lv_distributor) ).

    IF lv_distributor <> ls_proc_step_data-assoc_servprov.
      et_check_result = VALUE #( ( /idxgc/if_constants_add=>gc_cr_grid_not_assigned ) ).
      IF <lr_process_log> IS ASSIGNED.
        MESSAGE e003(/idxgc/utility_add) WITH ls_proc_step_data-ext_ui ls_proc_step_data-distributor INTO gv_msgtxt.
        <lr_process_log>->add_message_to_process_log( is_business_log = abap_true ).
      ENDIF.
    ELSE.
      et_check_result = VALUE #( ( /idxgc/if_constants_add=>gc_cr_grid_assigned ) ).

      IF <lr_process_log> IS ASSIGNED.
        MESSAGE s004(/idxgc/utility_add) WITH ls_proc_step_data-ext_ui ls_proc_step_data-distributor INTO gv_msgtxt.
        <lr_process_log>->add_message_to_process_log( is_business_log = abap_true ).
      ENDIF.
    ENDIF.

    IF et_check_result[ 1 ]  = /idxgc/if_constants_add=>gc_cr_grid_not_assigned.
      TRY.
          DATA(ls_eservprov) = /adz/cl_mdc_utility=>get_service_provider( lv_distributor ).
        CATCH /idxgc/cx_general.
          RETURN.
      ENDTRY.
      IF ls_eservprov-externalid IS NOT INITIAL.
        IF lines( ls_proc_step_data-error_ref ) > 0.
          ls_proc_step_data-error_ref[ 1 ]-distributor_mpid  = ls_eservprov-externalid.
        ELSE.
          ls_proc_step_data-error_ref = VALUE #( ( item_id = 1 distributor_mpid = ls_eservprov-externalid ) ).
        ENDIF.
        lr_process_data_step->update_process_step_data( is_process_step_data = ls_proc_step_data ).
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD check_notification_period.
************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: ILIASS ECHOUAIBI                                     Datum: 07.11.2019
*
* Beschreibung:
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************

***************************************************************************************************
* THIMEL.R, 20150906, SDÄ auf Common Layer
*   Kopiert aus /IDXGC/CL_CHECK_METHOD_ADD=>CHECK_NOTIFICATION_PERIOD und Rückgabewert so
*     angepasst, dass immer 'NOTIFICATION_PERIOD_OK' zurückgegeben wird, wenn keine Fristverletzung
*     festgestellt wurde.
***************************************************************************************************
*    DATA: lv_check_result   TYPE /idxgc/de_check_result,
*          ls_proc_step_data TYPE /idxgc/s_proc_step_data_all,
*          ls_proc_data      TYPE /idxgc/s_proc_data,
*          ls_diverse        TYPE /idxgc/s_diverse_details,
*          lv_date           TYPE dats,
*          lr_process_data   TYPE REF TO /idxgc/if_process_data,
*          lx_previous       TYPE REF TO /idxgc/cx_general.
*
*    FIELD-SYMBOLS: <fs_ref_process_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
*                   <fs_ref_process_log>         TYPE REF TO /idxgc/if_process_log.
*
*    ASSIGN cr_data->*     TO  <fs_ref_process_data_extern>.
*    ASSIGN cr_data_log->* TO  <fs_ref_process_log>.
*
*    lr_process_data ?= <fs_ref_process_data_extern>.
*
** Get process data,Step data
*    TRY.
*        CALL METHOD <fs_ref_process_data_extern>->get_process_step_data
*          EXPORTING
*            is_process_step_key  = is_process_step_key
*          RECEIVING
*            rs_process_step_data = ls_proc_step_data.
*
*      CATCH /idxgc/cx_process_error INTO lx_previous.
*        <fs_ref_process_log>->add_message_to_process_log( ).
*        CALL METHOD /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = lx_previous ).
*    ENDTRY.
*
** Notification Period check only available for settlement relevant data
*    IF ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch131 OR
*       ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch141 OR
*       ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch151 OR
*       ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch161 OR
*       ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch231 OR
*       ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch241 OR
*       ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch251.
*
** The message date has to be at least a whole month ahead of the VALIDSTART_DATE
** Example: in case of VALIDSTART_DATE = 01.06.2015 the message date has to be before
** the 01.05.2015 (message date = 01.05.2015 is not o.k.; message date 30.04.2015 is fine).
** If the nodification is not valid, set check result to 'NOTIFICATION_PERIOD_VIOLATION',
** otherwise, set check result to 'NOTIFICATION_PERIOD_OK'.
*      READ TABLE ls_proc_step_data-diverse INTO ls_diverse INDEX 1.
*      IF ls_diverse-validstart_date+6(2) <> '01'.
*        lv_check_result = /idxgc/if_constants_add=>gc_cr_notiperiod_violation. "'NOTIFICATION_PERIOD_VIOLATION'
*
*      ELSE.
*        CALL FUNCTION 'FIMA_DATE_CREATE'
*          EXPORTING
*            i_date   = ls_diverse-validstart_date
*            i_months = '-1'
*          IMPORTING
*            e_date   = lv_date.
*
*        IF lv_date > ls_proc_step_data-msg_date.
*          lv_check_result = /ADZ/IF_MDC_CO=>GC_CR_NOTIPERIOD_OK.        "'NOTIFICATION_PERIOD_OK'
*        ELSE.
*          lv_check_result = /ADZ/IF_MDC_CO=>GC_CR_NOTIPERIOD_VIOLATION. "'NOTIFICATION_PERIOD_VIOLATION'
*        ENDIF.
*
*      ENDIF.
*    ELSE.
*      lv_check_result = /ADZ/IF_MDC_CO=>GC_CR_NOTIPERIOD_OK.            "'NOTIFICATION_PERIOD_OK'
*    ENDIF.
*    APPEND lv_check_result TO et_check_result.


    et_check_result = VALUE #( ( /adz/if_mdc_co=>gc_cr-notification_period_ok ) ).


  ENDMETHOD.


  METHOD check_pod_malo_exist.
*************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: Iliass Echouaibi                                Datum: 04.11.2019
*
* Beschreibung:
*
*************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
*************************************************************************


    FIELD-SYMBOLS:
      <lr_ref_process_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
      <lr_ref_process_log>         TYPE REF TO /idxgc/if_process_log.

    DATA: cr_datatest     TYPE REF TO data,
          cr_data_logtest TYPE REF TO data.

    DATA:
      lr_badi_data_access  TYPE REF TO /idxgl/badi_data_access,
      lv_is_malo           TYPE flag,
      ls_check_result      TYPE /idxgc/de_check_result,
      lr_process_data_step TYPE REF TO /idxgc/if_process_data_step,
      lx_previous          TYPE REF TO /idxgc/cx_general.

    ASSIGN cr_data->* TO <lr_ref_process_data_extern>.
    ASSIGN cr_data_log->* TO <lr_ref_process_log>.

    IF <lr_ref_process_data_extern> IS ASSIGNED.
      lr_process_data_step ?= <lr_ref_process_data_extern>.
    ELSE.
      RETURN.
    ENDIF.

    TRY.
        DATA(ls_proc_step_data_all) = lr_process_data_step->get_process_step_data( is_process_step_key  = is_process_step_key ).
      CATCH /idxgc/cx_process_error INTO lx_previous.
        IF <lr_ref_process_log> IS ASSIGNED.
          <lr_ref_process_log>->add_message_to_process_log( is_process_step_key =  is_process_step_key ).
        ENDIF.
        TRY.
            /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = lx_previous ).
          CATCH /idxgc/cx_utility_error.
            MESSAGE e003(/adz/mdc_messages) INTO gv_msgtxt.
        ENDTRY.
    ENDTRY.

* If Pod Ext_ui not exist, return.
    CALL FUNCTION 'ISU_DB_EUITRANS_EXT_SINGLE'
      EXPORTING
        x_ext_ui     = ls_proc_step_data_all-ext_ui
        x_keydate    = ls_proc_step_data_all-proc_date
      EXCEPTIONS
        not_found    = 1
        system_error = 2
        OTHERS       = 3.
    IF sy-subrc <> 0.
      et_check_result = VALUE #( ( 'MALO_NOT_EXIST' ) ).
      RETURN.
    ENDIF.

    GET BADI lr_badi_data_access.
    TRY .
        CALL BADI lr_badi_data_access->is_pod_malo
          EXPORTING
            iv_ext_ui      = ls_proc_step_data_all-ext_ui
            iv_key_date    = ls_proc_step_data_all-proc_date
          RECEIVING
            rv_pod_is_malo = lv_is_malo.
      CATCH /idxgc/cx_general.
    ENDTRY.
    IF lv_is_malo = abap_true.
      et_check_result = VALUE #( ( 'MALO_EXIST' ) ).
    ELSE.
      et_check_result = VALUE #( ( 'MALO_NOT_EXIST' ) ).
    ENDIF.



  ENDMETHOD.


  METHOD check_processing_type_auth.
************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: ILIASS ECHOUAIBI                                     Datum: 07.11.2019
*
* Beschreibung:
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************

*   DATA: lr_process_data_step TYPE REF TO /idxgc/if_process_data_step,
*          ls_proc_step_data    TYPE /idxgc/s_proc_step_data_all,
**          ls_proc_step_data_src_add TYPE /idxgc/s_proc_step_data_all,
**          ls_proc_step_key          TYPE /idxgc/s_proc_step_key,
**          ls_proc_config            TYPE /idxgc/s_proc_config_all,
*          ls_cust_in           TYPE /adesso/mdc_s_in,
*          lv_edifact_structur  TYPE /idxgc/de_edifact_str,
*          lv_flag_response     TYPE /idxgc/de_boolean_flag.
*
*    FIELD-SYMBOLS: <fr_process_log>      TYPE REF TO /idxgc/if_process_log,
*                   <fr_proc_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
**                   <fs_proc_step_config> TYPE /idxgc/s_proc_step_config_all,
*                   <fs_mtd_code_result>  TYPE /idxgc/s_mtd_code_details.
*
*    ASSIGN cr_data_log->* TO <fr_process_log>.
*    ASSIGN cr_data->* TO <fr_proc_data_extern>.
*    lr_process_data_step ?= <fr_proc_data_extern>.
*
****** Schrittdaten vom aktuellen Schritt holen ****************************************************
*    TRY.
*        ls_proc_step_data = lr_process_data_step->get_process_step_data( is_process_step_key ).
*      CATCH /idxgc/cx_process_error INTO gr_previous .
*        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
*    ENDTRY.
*
******* Schrittdaten vom zusätzlichem Quellschritt holen ********************************************
**    TRY.
**        /idxgc/cl_cust_access=>/idxgc/if_cust_access~get_process_config( EXPORTING iv_process_id = ls_proc_step_data-proc_id IMPORTING es_process_config = ls_proc_config ).
**      CATCH /idxgc/cx_config_error INTO gr_previous.
**        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
**    ENDTRY.
**
**    READ TABLE ls_proc_config-steps ASSIGNING <fs_proc_step_config> WITH KEY proc_step_no = is_process_step_key-proc_step_no.
**    IF sy-subrc = 0.
**      ls_proc_step_key-proc_id = is_process_step_key-proc_id.
**      IF <fs_proc_step_config>-step_no_src_add IS NOT INITIAL.
**        ls_proc_step_key-proc_step_no = <fs_proc_step_config>-step_no_src_add.
**        TRY.
**            ls_proc_step_data_src_add = lr_process_data_step->get_process_step_data( ls_proc_step_key ).
**          CATCH /idxgc/cx_process_error INTO gr_previous .
**            /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
**        ENDTRY.
**      ENDIF.
**    ENDIF.
*
****** Methodenlogik *******************************************************************************
**---- Anfrage oder Antwort? -----------------------------------------------------------------------
*    READ TABLE ls_proc_step_data-msgrespstatus TRANSPORTING NO FIELDS INDEX 1.
*    IF sy-subrc = 0.
*      lv_flag_response = abap_true.
*    ENDIF.
*
**---- (Teilweise) automatische Verbuchung möglich? ------------------------------------------------
*    LOOP AT ls_proc_step_data-mtd_code_result ASSIGNING <fs_mtd_code_result>.
*      lv_edifact_structur = <fs_mtd_code_result>-addinfo.
*      TRY.
*          CLEAR: ls_cust_in.
*          ls_cust_in = /adesso/cl_mdc_customizing=>get_inbound_config_for_edifact( iv_edifact_structur = lv_edifact_structur iv_assoc_servprov = ls_proc_step_data-assoc_servprov ).
*        CATCH /idxgc/cx_general INTO gr_previous.
*          ls_cust_in-auto_change = /adesso/if_mdc_co=>gc_in_change_manual.
*          ls_cust_in-auto_change_response = /adesso/if_mdc_co=>gc_in_change_manual.
*          sy-msgty = /idxgc/if_constants=>gc_message_type_warning.
*          <fr_process_log>->add_message_to_process_log( ).
*          MESSAGE w050(/adesso/mdc_process) INTO gv_mtext.
*          <fr_process_log>->add_message_to_process_log( ).
*      ENDTRY.
*      IF lv_flag_response = abap_false.
*        IF ls_cust_in-auto_change = /adesso/if_mdc_co=>gc_in_change_auto.
*          APPEND /ADZ/IF_MDC_CO=>gc_cr_change_auto TO et_check_result.
*          EXIT.
*        ENDIF.
*      ELSE.
*        IF ls_cust_in-auto_change_response = /adesso/if_mdc_co=>gc_in_change_auto.
*          APPEND /ADZ/IF_MDC_CO=>gc_cr_change_auto TO et_check_result.
*          EXIT.
*        ENDIF.
*      ENDIF.
*    ENDLOOP.
*    IF et_check_result IS INITIAL.
*      APPEND /ADZ/IF_MDC_CO=>gc_cr_change_manual TO et_check_result.
*    ENDIF.

    et_check_result = VALUE #( ( /adz/if_mdc_co=>gc_cr-auto ) ). "War gc_cr_change_auto
  ENDMETHOD.


  METHOD check_resp_msg_type.
***************************************************************************************************
*            _                        _____ ______
*           | |                      / ____|  ____|
*   __ _  __| | ___  ___ ___  ___   | (___ | |__
*  / _` |/ _` |/ _ \/ __/ __|/ _ \   \___ \|  __|
* | (_| | (_| |  __/\__ \__ \ (_) |  ____) | |____
*  \__,_|\__,_|\___||___/___/\___/  |_____/|______|
*
* Author: schmidt-m                                                               Datum: 17.07.2020
*
* Beschreibung: Antwort der Stammdatensynchronisation prüfen
*
***************************************************************************************************
* Wichtige / Große Änderungen:
* Nutzer      Datum      Beschreibung
* RICHTER-D   16.03.2021 Prüfergebnisse ERROR und NOT_RELEVANT ergänzt
***************************************************************************************************
    DATA:
      lr_process_data_step TYPE REF TO /idxgc/if_process_data_step,
      ls_process_step_data TYPE /idxgc/s_proc_step_data_all,
      lr_ctx               TYPE REF TO /idxgc/cl_pd_doc_context,
      lt_proc_step_data    TYPE /idxgc/t_proc_step_data,
      ls_proc_step_data    TYPE /idxgc/s_proc_step_data.

    FIELD-SYMBOLS:
      <lr_process_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
      <lr_process_log>         TYPE REF TO /idxgc/if_process_log.

*** Schrittdaten holen ****************************************************************************
    ASSIGN cr_data->*     TO  <lr_process_data_extern>.
    ASSIGN cr_data_log->* TO  <lr_process_log>.

    IF <lr_process_data_extern> IS ASSIGNED.
      lr_process_data_step ?= <lr_process_data_extern>.
    ELSE.
      " Prozessdaten wurden nicht gefunden
      MESSAGE e001(/adz/mdc_messages) INTO gv_msgtxt.
      IF <lr_process_log> IS ASSIGNED.
        <lr_process_log>->add_message_to_process_log( is_process_step_key = is_process_step_key ).
      ENDIF.
      et_check_result = VALUE #( ( /idxgc/if_constants_add=>gc_cr_error ) ).
      RETURN.
    ENDIF.

    TRY.
        ls_process_step_data = lr_process_data_step->get_process_step_data( is_process_step_key ).

        lr_ctx = /idxgc/cl_pd_doc_context=>get_instance( iv_pdoc_no = ls_process_step_data-proc_ref
                                                         iv_bufref  = /idxgc/if_constants=>gc_true ).

        lr_ctx->get_proc_step_data( EXPORTING iv_msg_dir        = /idxgc/if_constants_add=>gc_message_direction_import
                                    IMPORTING et_proc_step_data = lt_proc_step_data ).
      CATCH /idxgc/cx_process_error INTO gx_previous.
        IF <lr_process_log> IS ASSIGNED.
          <lr_process_log>->add_message_to_process_log( is_process_step_key = is_process_step_key ).
        ENDIF.
        et_check_result = VALUE #( ( /idxgc/if_constants_add=>gc_cr_error ) ).
        RETURN.
    ENDTRY.

*** Prüfe ob es eine eingehende Nachricht mit BMID CH187 gibt (Stammdatensynchronisation vom ÜNB) *
    SORT lt_proc_step_data BY proc_step_timestamp DESCENDING.
    READ TABLE lt_proc_step_data INTO ls_proc_step_data INDEX 1.

    IF ls_proc_step_data-bmid = /adz/if_mdc_co=>gc_bmid-adz_ch187.
      IF lines( ls_proc_step_data-msgrespstatus ) = 0.
        " Prozessdaten (Antwortstatus) wurden nicht gefunden
        MESSAGE e001(/adz/mdc_messages) INTO gv_msgtxt.
        IF <lr_process_log> IS ASSIGNED.
          <lr_process_log>->add_message_to_process_log( EXPORTING is_process_step_key = is_process_step_key ).
        ENDIF.
        et_check_result = VALUE #( ( /idxgc/if_constants_add=>gc_cr_error ) ).
        RETURN.
      ELSEIF line_exists( ls_proc_step_data-msgrespstatus[ /idxgl/status_reason = /adz/if_mdc_co=>gc_msg_resp-a13 ] ).
        " Positive Nachricht wurde empfangen
        MESSAGE s327(/idxgc/utility_add) WITH ls_proc_step_data-assoc_servprov ls_proc_step_data-bmid ls_proc_step_data-response_cat INTO gv_msgtxt.
        IF <lr_process_log> IS ASSIGNED.
          <lr_process_log>->add_message_to_process_log( EXPORTING is_process_step_key = is_process_step_key ).
        ENDIF.
        et_check_result = VALUE #( ( /idxgc/if_constants_add=>gc_cr_rec_confirm ) ).
        RETURN.
      ELSE.
        " Negative Nachricht wurde empfangen
        MESSAGE s326(/idxgc/utility_add) WITH ls_proc_step_data-assoc_servprov ls_proc_step_data-bmid ls_proc_step_data-response_cat INTO gv_msgtxt.
        IF <lr_process_log> IS ASSIGNED.
          <lr_process_log>->add_message_to_process_log( EXPORTING is_process_step_key = is_process_step_key ).
        ENDIF.
        et_check_result = VALUE #( ( /idxgc/if_constants_add=>gc_cr_rec_reject ) ).
        RETURN.
      ENDIF.
    ENDIF.

    et_check_result = VALUE #( ( /idxgc/if_constants_add=>gc_cr_not_relevant ) ).

  ENDMETHOD.


  METHOD check_sync_necessary.
***************************************************************************************************
*            _                        _____ ______
*           | |                      / ____|  ____|
*   __ _  __| | ___  ___ ___  ___   | (___ | |__
*  / _` |/ _` |/ _ \/ __/ __|/ _ \   \___ \|  __|
* | (_| | (_| |  __/\__ \__ \ (_) |  ____) | |____
*  \__,_|\__,_|\___||___/___/\___/  |_____/|______|
*
* Author: THIMEL-R                                                                Datum: 28.10.2019
*
* Beschreibung: Prüfung, ob Stammdatensynchronisation versendet werden soll
*
***************************************************************************************************
* Wichtige / Große Änderungen:
* Nutzer      Datum      Beschreibung
* THIMEL-R    23.10.2020 Anpassung für Einspeiser + Nicht benötigtes Coding entfernt
***************************************************************************************************

    DATA: lr_process_data_step TYPE REF TO /idxgc/if_process_data_step,
          ls_proc_step_data    TYPE /idxgc/s_proc_step_data_all.

    FIELD-SYMBOLS: <lr_process_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
                   <lr_process_log>         TYPE REF TO /idxgc/if_process_log.

    ASSIGN cr_data->* TO <lr_process_data_extern>.
    ASSIGN cr_data_log->* TO <lr_process_log>.

    IF <lr_process_data_extern> IS ASSIGNED.
      lr_process_data_step ?= <lr_process_data_extern>.
    ELSE.
      MESSAGE e002(/adz/mdc_messages) INTO gv_msgtxt.
      IF <lr_process_log> IS ASSIGNED.
        <lr_process_log>->add_message_to_process_log( is_process_step_key = is_process_step_key ).
      ENDIF.
      et_check_result = VALUE #( ( /idxgc/if_constants_add=>gc_cr_error ) ).
      RETURN.
    ENDIF.

    TRY.
        ls_proc_step_data = lr_process_data_step->get_process_step_data( is_process_step_key ).
      CATCH /idxgc/cx_process_error INTO gx_previous.
        IF <lr_process_log> IS ASSIGNED.
          <lr_process_log>->add_message_to_process_log( is_process_step_key = is_process_step_key ).
        ENDIF.
        et_check_result = VALUE #( ( /idxgc/if_constants_add=>gc_cr_error ) ).
        RETURN.
    ENDTRY.

***** Prüfungen ob Synchronisation erzeugt werden soll (unten sind weitere Prüfungen) *************
    "Alle relevanten Nachrichten haben eine MaLo im Header, bei MeLo keine SDÄ-Sync
    IF strlen( ls_proc_step_data-ext_ui ) = 33. "MeLo hat immer 33 stellen.
      et_check_result = VALUE #( ( /adz/if_mdc_co=>gc_cr-mdc_sync_not_necessary ) ).
      RETURN.
    ENDIF.

    "Nur bestimmte Stammdatenänderungen, Anmeldungen und EoG mit Zustimmung enthalten relevante Daten für die Synchronisation.
    IF ls_proc_step_data-proc_id = /adz/if_mdc_co=>gc_proc_id-sos_1012.
      IF NOT line_exists( <lr_process_data_extern>->gs_process_data-steps[ bmid = /idxgc/if_constants_add=>gc_bmid_es103 ] ).
        et_check_result = VALUE #( ( /adz/if_mdc_co=>gc_cr-mdc_sync_not_necessary ) ).
        RETURN.
      ENDIF.
    ELSEIF ls_proc_step_data-proc_id = /adz/if_mdc_co=>gc_proc_id-sbs_1041.
      IF NOT line_exists( <lr_process_data_extern>->gs_process_data-steps[ bmid = /idxgc/if_constants_add=>gc_bmid_eb103 ] ).
        et_check_result = VALUE #( ( /adz/if_mdc_co=>gc_cr-mdc_sync_not_necessary ) ).
        RETURN.
      ENDIF.
    ELSEIF ls_proc_step_data-proc_id = /adz/if_mdc_co=>gc_proc_id-mdc_send_res_8030.
      IF NOT line_exists( <lr_process_data_extern>->gs_process_data-steps[ bmid = /idxgc/if_constants_ide=>gc_bmid_ch111 ] ) AND
         NOT line_exists( <lr_process_data_extern>->gs_process_data-steps[ bmid = /idxgc/if_constants_ide=>gc_bmid_ch112 ] ) AND
         NOT line_exists( <lr_process_data_extern>->gs_process_data-steps[ bmid = /idxgc/if_constants_ide=>gc_bmid_ch141 ] ) AND
         NOT line_exists( <lr_process_data_extern>->gs_process_data-steps[ bmid = /idxgc/if_constants_ide=>gc_bmid_ch151 ] ).
        et_check_result = VALUE #( ( /adz/if_mdc_co=>gc_cr-mdc_sync_not_necessary ) ).
        RETURN.
      ENDIF.
    ELSEIF ls_proc_step_data-proc_id = /adz/if_mdc_co=>gc_proc_id-mdc_send_ath_8031.
      IF NOT line_exists( <lr_process_data_extern>->gs_process_data-steps[ bmid = /idxgc/if_constants_ide=>gc_bmid_ch225 ] ) AND
         NOT line_exists( <lr_process_data_extern>->gs_process_data-steps[ bmid = /idxgc/if_constants_ide=>gc_bmid_ch226 ] ) AND
         NOT line_exists( <lr_process_data_extern>->gs_process_data-steps[ bmid = /idxgc/if_constants_ide=>gc_bmid_ch231 ] ).
        et_check_result = VALUE #( ( /adz/if_mdc_co=>gc_cr-mdc_sync_not_necessary ) ).
        RETURN.
      ENDIF.
    ELSEIF ls_proc_step_data-proc_id = /adz/if_mdc_co=>gc_proc_id-mdc_rec_res_8032.
      IF NOT line_exists( <lr_process_data_extern>->gs_process_data-steps[ bmid = /idxgc/if_constants_ide=>gc_bmid_ch211 ] ) AND
         NOT line_exists( <lr_process_data_extern>->gs_process_data-steps[ bmid = /idxgc/if_constants_ide=>gc_bmid_ch212 ] ) AND
         NOT line_exists( <lr_process_data_extern>->gs_process_data-steps[ bmid = /idxgc/if_constants_ide=>gc_bmid_ch251 ] ).
        et_check_result = VALUE #( ( /adz/if_mdc_co=>gc_cr-mdc_sync_not_necessary ) ).
        RETURN.
      ENDIF.
    ELSEIF ls_proc_step_data-proc_id = /adz/if_mdc_co=>gc_proc_id-mdc_rec_ath_8033.
      IF NOT line_exists( <lr_process_data_extern>->gs_process_data-steps[ bmid = /idxgc/if_constants_ide=>gc_bmid_ch121 ] ) AND
         NOT line_exists( <lr_process_data_extern>->gs_process_data-steps[ bmid = /idxgc/if_constants_ide=>gc_bmid_ch131 ] ).
        et_check_result = VALUE #( ( /adz/if_mdc_co=>gc_cr-mdc_sync_not_necessary ) ).
        RETURN.
      ENDIF.
    ENDIF.

    "Bei Stammdatenänderungen an den MSB soll keine Nachricht verschickt werden.
    TRY.
        IF /adz/cl_mdc_utility=>get_intcode( iv_serviceid = ls_proc_step_data-assoc_servprov ) = /adz/if_mdc_co=>gc_intcode-mso_m1.
          et_check_result = VALUE #( ( /adz/if_mdc_co=>gc_cr-mdc_sync_not_necessary ) ).
          RETURN.
        ENDIF.
      CATCH /idxgc/cx_general.
        IF <lr_process_log> IS ASSIGNED.
          <lr_process_log>->add_message_to_process_log( is_process_step_key = is_process_step_key ).
        ENDIF.
        et_check_result = VALUE #( ( /idxgc/if_constants_add=>gc_cr_error ) ).
        RETURN.
    ENDTRY.

    "Wenn keine Bilanzierung bei EoG und LB stattfindet, muss auch keine Synchronisation verschickt werden.
    IF ls_proc_step_data-proc_id = /adz/if_mdc_co=>gc_proc_id-sos_1012 OR ls_proc_step_data-proc_id = /adz/if_mdc_co=>gc_proc_id-sbs_1041.
      IF line_exists( ls_proc_step_data-diverse[ 1 ] ).
        IF ls_proc_step_data-diverse[ 1 ]-startsettldate IS INITIAL OR
          ( ls_proc_step_data-diverse[ 1 ]-startsettldate > ls_proc_step_data-diverse[ 1 ]-endsettldate AND
            ls_proc_step_data-diverse[ 1 ]-endsettldate IS NOT INITIAL ). "Sonderfall
          et_check_result = VALUE #( ( /adz/if_mdc_co=>gc_cr-mdc_sync_not_necessary ) ).
          RETURN.
        ENDIF.
      ELSE.
        "Wenn keine DIVERSE-Daten vorhanden sind, dann kann auch keine Bilanzierung stattfinden.
        et_check_result = VALUE #( ( /adz/if_mdc_co=>gc_cr-mdc_sync_not_necessary ) ).
        RETURN.
      ENDIF.
    ENDIF.

    lr_process_data_step->update_process_step_data( ls_proc_step_data ).
    et_check_result = VALUE #( ( /adz/if_mdc_co=>gc_cr-mdc_sync_necessary ) ).

  ENDMETHOD.


  METHOD check_wait_time_for_update.
************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: ILIASS ECHOUAIBI                                     Datum: 07.11.2019
*
* Beschreibung:
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************

*       DATA: lr_process_data_step TYPE REF TO /idxgc/if_process_data_step,
*          lr_badi_exception    TYPE REF TO /idxgc/badi_exception,
*          ls_proc_step_data    TYPE /idxgc/s_proc_step_data_all,
*          ls_cust_in           TYPE /adesso/mdc_s_in,
*          lv_edifact_structur  TYPE /idxgc/de_edifact_str.
*
*    FIELD-SYMBOLS: <fr_process_log>      TYPE REF TO /idxgc/if_process_log,
*                   <fr_proc_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
*                   <fs_mtd_code_result>  TYPE /idxgc/s_mtd_code_details.
*
*    ASSIGN cr_data_log->* TO <fr_process_log>.
*    ASSIGN cr_data->* TO <fr_proc_data_extern>.
*    lr_process_data_step ?= <fr_proc_data_extern>.
*
****** Schrittdaten vom aktuellen Schritt holen ****************************************************
*    TRY.
*        ls_proc_step_data = lr_process_data_step->get_process_step_data( is_process_step_key ).
*      CATCH /idxgc/cx_process_error INTO gr_previous.
*        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
*    ENDTRY.
*
****** Methodenlogik *******************************************************************************
*    LOOP AT ls_proc_step_data-mtd_code_result ASSIGNING <fs_mtd_code_result>.
*      CHECK <fs_mtd_code_result>-src_field_value <> <fs_mtd_code_result>-cmp_field_value.
*      lv_edifact_structur = <fs_mtd_code_result>-addinfo.
*      TRY.
*          ls_cust_in = /adesso/cl_mdc_customizing=>get_inbound_config_for_edifact( iv_edifact_structur = lv_edifact_structur
*                                                                                   iv_keydate = ls_proc_step_data-proc_date
*                                                                                   iv_assoc_servprov = ls_proc_step_data-assoc_servprov ).
*          IF ls_cust_in-auto_change_delay IS NOT INITIAL.
*            APPEND /ADZ/IF_MDC_CO=>gc_cr_wait TO et_check_result.
*            RETURN.
*          ENDIF.
*        CATCH /idxgc/cx_general.
*          "Kein Customizing bedeutet auch, dass nicht gewartet werden soll / muss
*      ENDTRY.
*    ENDLOOP.
*
*    IF lines( et_check_result ) = 0.
*      APPEND /ADZ/IF_MDC_CO=>gc_cr_no_wait TO et_check_result.
*    ENDIF.

    et_check_result = VALUE #( ( /adz/if_mdc_co=>gc_cr-no_wait ) ).
  ENDMETHOD.


  METHOD update_compare_result.
************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: ILIASS ECHOUAIBI                                     Datum: 07.11.2019
*
* Beschreibung:
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************

*    DATA: lr_process_data_step      TYPE REF TO /idxgc/if_process_data_step,
*          ls_proc_step_data         TYPE /idxgc/s_proc_step_data_all,
*          ls_proc_step_data_src_add TYPE /idxgc/s_proc_step_data_all,
*          ls_proc_step_data_1       TYPE /idxgc/s_proc_step_data,
*          ls_proc_step_data_2       TYPE /idxgc/s_proc_step_data,
*          ls_proc_step_key          TYPE /idxgc/s_proc_step_key,
*          ls_proc_config            TYPE /idxgc/s_proc_config_all.
*
*    FIELD-SYMBOLS: <fr_process_log>      TYPE REF TO /idxgc/if_process_log,
*                   <fr_proc_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
*                   <fs_proc_step_config> TYPE /idxgc/s_proc_step_config_all,
*                   <fs_mtd_code_result>  TYPE /idxgc/s_mtd_code_details.
*
*    ASSIGN cr_data_log->* TO <fr_process_log>.
*    ASSIGN cr_data->* TO <fr_proc_data_extern>.
*    lr_process_data_step ?= <fr_proc_data_extern>.
*
****** Schrittdaten vom aktuellen Schritt holen ****************************************************
*    TRY.
*        ls_proc_step_data = lr_process_data_step->get_process_step_data( is_process_step_key ).
*      CATCH /idxgc/cx_process_error INTO gr_previous .
*        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
*    ENDTRY.
*
****** Schrittdaten vom zusätzlichem Quellschritt holen ********************************************
*    TRY.
*        /idxgc/cl_cust_access=>/idxgc/if_cust_access~get_process_config( EXPORTING iv_process_id = ls_proc_step_data-proc_id IMPORTING es_process_config = ls_proc_config ).
*      CATCH /idxgc/cx_config_error INTO gr_previous.
*        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
*    ENDTRY.
*
*    READ TABLE ls_proc_config-steps ASSIGNING <fs_proc_step_config> WITH KEY proc_step_no = is_process_step_key-proc_step_no.
*    IF sy-subrc = 0.
*      ls_proc_step_key-proc_id = is_process_step_key-proc_id.
*      IF <fs_proc_step_config>-step_no_src_add IS NOT INITIAL.
*        ls_proc_step_key-proc_step_no = <fs_proc_step_config>-step_no_src_add.
*        TRY.
*            ls_proc_step_data_src_add = lr_process_data_step->get_process_step_data( ls_proc_step_key ).
*          CATCH /idxgc/cx_process_error INTO gr_previous .
*            /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
*        ENDTRY.
*      ENDIF.
*    ENDIF.
*
****** Methodenlogik *******************************************************************************
*    MOVE-CORRESPONDING ls_proc_step_data         TO ls_proc_step_data_1.
*    MOVE-CORRESPONDING ls_proc_step_data_src_add TO ls_proc_step_data_2.
*    TRY.
*        ls_proc_step_data-mtd_code_result = /adesso/cl_mdc_utility=>compare_proc_step_data( is_proc_step_data_1 = ls_proc_step_data_1 is_proc_step_data_2 = ls_proc_step_data_2 ).
*      CATCH /idxgc/cx_general INTO gr_previous.
*        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
*    ENDTRY.
*    LOOP AT ls_proc_step_data-mtd_code_result ASSIGNING <fs_mtd_code_result>.
*      IF <fs_mtd_code_result>-src_field_value = <fs_mtd_code_result>-cmp_field_value.
*        DELETE ls_proc_step_data-mtd_code_result.
*      ENDIF.
*    ENDLOOP.
*    APPEND /idxgc/if_constants_add=>gc_cr_ok TO et_check_result.
*
****** Schrittdaten aktualisieren ******************************************************************
*    lr_process_data_step->update_process_step_data( is_process_step_data = ls_proc_step_data ).


    et_check_result = VALUE #( ( /idxgc/if_constants_add=>gc_cr_ok ) ).



  ENDMETHOD.


  METHOD update_compare_result_select.
************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: ILIASS ECHOUAIBI                                     Datum: 07.11.2019
*
* Beschreibung:
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************

*    DATA: lr_process_data_step      TYPE REF TO /idxgc/if_process_data_step,
*          lt_edifact_structur       TYPE /adesso/mdc_t_edifact_str,
*          ls_proc_step_data         TYPE /idxgc/s_proc_step_data_all,
*          ls_proc_step_data_src_add TYPE /idxgc/s_proc_step_data_all,
*          ls_proc_step_data_1       TYPE /idxgc/s_proc_step_data,
*          ls_proc_step_data_2       TYPE /idxgc/s_proc_step_data,
*          ls_proc_step_key          TYPE /idxgc/s_proc_step_key,
*          ls_proc_config            TYPE /idxgc/s_proc_config_all.
*
*    FIELD-SYMBOLS: <fr_process_log>      TYPE REF TO /idxgc/if_process_log,
*                   <fr_proc_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
*                   <fs_proc_step_config> TYPE /idxgc/s_proc_step_config_all,
*                   <fs_mtd_code_result>  TYPE /idxgc/s_mtd_code_details.
*
*    ASSIGN cr_data_log->* TO <fr_process_log>.
*    ASSIGN cr_data->* TO <fr_proc_data_extern>.
*    lr_process_data_step ?= <fr_proc_data_extern>.
*
****** Schrittdaten vom aktuellen Schritt holen ****************************************************
*    TRY.
*        ls_proc_step_data = lr_process_data_step->get_process_step_data( is_process_step_key ).
*      CATCH /idxgc/cx_process_error INTO gr_previous .
*        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
*    ENDTRY.
*
****** Schrittdaten vom zusätzlichem Quellschritt holen ********************************************
*    TRY.
*        /idxgc/cl_cust_access=>/idxgc/if_cust_access~get_process_config( EXPORTING iv_process_id = ls_proc_step_data-proc_id IMPORTING es_process_config = ls_proc_config ).
*      CATCH /idxgc/cx_config_error INTO gr_previous.
*        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
*    ENDTRY.
*
*    READ TABLE ls_proc_config-steps ASSIGNING <fs_proc_step_config> WITH KEY proc_step_no = is_process_step_key-proc_step_no.
*    IF sy-subrc = 0.
*      ls_proc_step_key-proc_id = is_process_step_key-proc_id.
*      IF <fs_proc_step_config>-step_no_src_add IS NOT INITIAL.
*        ls_proc_step_key-proc_step_no = <fs_proc_step_config>-step_no_src_add.
*        TRY.
*            ls_proc_step_data_src_add = lr_process_data_step->get_process_step_data( ls_proc_step_key ).
*          CATCH /idxgc/cx_process_error INTO gr_previous .
*            /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
*        ENDTRY.
*      ENDIF.
*    ENDIF.
*
****** Methodenlogik *******************************************************************************
*    MOVE-CORRESPONDING ls_proc_step_data         TO ls_proc_step_data_1.
*    MOVE-CORRESPONDING ls_proc_step_data_src_add TO ls_proc_step_data_2.
*    TRY.
*        ls_proc_step_data-mtd_code_result = /adesso/cl_mdc_utility=>compare_proc_step_data( is_proc_step_data_1 = ls_proc_step_data_1
*          is_proc_step_data_2 = ls_proc_step_data_2 it_mtd_code_result_select = ls_proc_step_data-mtd_code_result ).
*      CATCH /idxgc/cx_general INTO gr_previous.
*        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
*    ENDTRY.
*    APPEND /idxgc/if_constants_add=>gc_cr_ok TO et_check_result.
*
****** Schrittdaten aktualisieren ******************************************************************
*    lr_process_data_step->update_process_step_data( is_process_step_data = ls_proc_step_data ).


    et_check_result = VALUE #( ( /idxgc/if_constants_add=>gc_cr_ok ) ).
  ENDMETHOD.


  METHOD update_receiver_sync.
***************************************************************************************************
*            _                        _____ ______
*           | |                      / ____|  ____|
*   __ _  __| | ___  ___ ___  ___   | (___ | |__
*  / _` |/ _` |/ _ \/ __/ __|/ _ \   \___ \|  __|
* | (_| | (_| |  __/\__ \__ \ (_) |  ____) | |____
*  \__,_|\__,_|\___||___/___/\___/  |_____/|______|
*
* Author: THIMEL-R                                                                Datum: 20.02.2020
*
* Beschreibung: Empfänger für Weiterleitung SDÄ-Sync ermitteln
*
***************************************************************************************************
* Wichtige / Große Änderungen:
* Nutzer      Datum      Beschreibung
* THIMEL-R    26.10.2020 Immer an den ÜNB für Beendigung der Aggr. Verantwortung
***************************************************************************************************

    DATA: lr_process_data_step  TYPE REF TO /idxgc/if_process_data_step,
          ls_proc_step_data_add TYPE /idxgc/s_proc_step_data_all,
          ls_proc_step_data     TYPE /idxgc/s_proc_step_data_all,
          ls_proc_step_key      TYPE /idxgc/s_proc_step_key.

    FIELD-SYMBOLS: <lr_process_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
                   <lr_process_log>         TYPE REF TO /idxgc/if_process_log.

***** Schrittdaten holen **************************************************************************
    ASSIGN cr_data->* TO <lr_process_data_extern>.
    ASSIGN cr_data_log->* TO <lr_process_log>.

    IF <lr_process_data_extern> IS ASSIGNED.
      lr_process_data_step ?= <lr_process_data_extern>.
    ELSE.
      MESSAGE e002(/adz/mdc_messages) INTO gv_msgtxt.
      IF <lr_process_log> IS ASSIGNED.
        <lr_process_log>->add_message_to_process_log( is_process_step_key = is_process_step_key ).
      ENDIF.
      et_check_result = VALUE #( ( /idxgc/if_constants_add=>gc_cr_error ) ).
      RETURN.
    ENDIF.

    TRY.
        ls_proc_step_data = lr_process_data_step->get_process_step_data( is_process_step_key ).
      CATCH /idxgc/cx_process_error INTO gx_previous.
        IF <lr_process_log> IS ASSIGNED.
          <lr_process_log>->add_message_to_process_log( is_process_step_key = is_process_step_key ).
        ENDIF.
        et_check_result = VALUE #( ( /idxgc/if_constants_add=>gc_cr_error ) ).
        RETURN.
    ENDTRY.

***** Empfänger der Weiterleitung ermitteln (NB oder ÜNB) *****************************************
* Der Empfänger muss nur geändert werden, wenn die Nachricht an den ÜNB geschickt weren soll. Da
* Absender der NB ist, werden die Nachrichten sonst immer dorthin zurück geschickt.
    IF ls_proc_step_data-bmid = /adz/if_mdc_co=>gc_bmid-adz_ch188 OR "Beendigung der Aggregationsverantwortung schicken wir erstmal immer an den ÜNB.
       line_exists( ls_proc_step_data-/idxgl/pod_data[ resp_market_role = /adz/if_mdc_co=>gc_resp_market_role-za9 ] ) OR "Verantwortung liegt beim ÜNB
       ( line_exists( ls_proc_step_data-/idxgl/pod_data[ forecast_basis = /adz/if_mdc_co=>gc_forecast_basis-zc0 ] ) AND ls_proc_step_data-msg_date >= '20200401' ). "RLM nach dem 01.04.2020

      TRY.
          ls_proc_step_data-assoc_servprov = /adz/cl_mdc_utility=>get_assigned_tso( iv_int_ui = ls_proc_step_data-int_ui iv_keydate = ls_proc_step_data-proc_date )-serviceid.
        CATCH /idxgc/cx_general.
          IF <lr_process_log> IS ASSIGNED.
            <lr_process_log>->add_message_to_process_log( is_process_step_key = is_process_step_key ).
          ENDIF.
          et_check_result = VALUE #( ( /idxgc/if_constants_add=>gc_cr_error ) ).
          RETURN.
      ENDTRY.
      et_check_result = VALUE #( ( /adz/if_mdc_co=>gc_cr-receiver_updated ) ).
      lr_process_data_step->update_process_step_data( ls_proc_step_data ).
      RETURN.

    ENDIF.

    et_check_result = VALUE #( ( /adz/if_mdc_co=>gc_cr-receiver_not_updated ) ).

  ENDMETHOD.


  METHOD update_step_data_from_system.
************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: ILIASS ECHOUAIBI                                     Datum: 07.11.2019
*
* Beschreibung:
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************

*      DATA: lr_process_data_step      TYPE REF TO /idxgc/if_process_data_step,
*          lr_badi_datapro           TYPE REF TO /idxgc/badi_data_provision,
*          lt_pod                    TYPE /idxgc/t_pod_info_details,
*          ls_proc_data              TYPE /idxgc/s_proc_data,
*          ls_proc_step_data         TYPE /idxgc/s_proc_step_data_all,
*          ls_proc_step_data_src_add TYPE /idxgc/s_proc_step_data_all,
*          ls_proc_step_data_src_dp  TYPE /idxgc/s_proc_step_data_all,
*          ls_proc_step_key          TYPE /idxgc/s_proc_step_key,
*          ls_proc_config            TYPE /idxgc/s_proc_config_all,
*          ls_bmid                   TYPE /idxgc/bmid,
*          lr_dp_out                 TYPE REF TO /idxgc/if_dp_out,
*          ls_bmid_var               TYPE /idxgc/bmid_var.
*
*    FIELD-SYMBOLS: <fr_process_log>      TYPE REF TO /idxgc/if_process_log,
*                   <fr_proc_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
*                   <fs_proc_step_config> TYPE /idxgc/s_proc_step_config_all,
*                   <fs_proc_step_data>   TYPE /idxgc/s_proc_step_data,
*                   <fs_diverse>          TYPE /idxgc/s_diverse_details,
*                   <fs_diverse_src_add>  TYPE /idxgc/s_diverse_details,
*                   <fs_diverse_src_dp>   TYPE /idxgc/s_diverse_details,
*                   <fs_check>            TYPE /idxgc/s_check_details,
*                   <fs_msgrespstatus>    TYPE /idxgc/s_msgsts_details.
*
*    ASSIGN cr_data_log->* TO <fr_process_log>.
*    ASSIGN cr_data->* TO <fr_proc_data_extern>.
*    lr_process_data_step ?= <fr_proc_data_extern>.
*
****** Schrittdaten vom aktuellen Schritt holen ****************************************************
*    TRY.
*        ls_proc_step_data = lr_process_data_step->get_process_step_data( is_process_step_key ).
*      CATCH /idxgc/cx_process_error INTO gr_previous .
*        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
*    ENDTRY.
*
****** Schrittdaten vom zusätzlichem Quellschritt holen ********************************************
*    TRY.
*        /idxgc/cl_cust_access=>/idxgc/if_cust_access~get_process_config( EXPORTING iv_process_id = ls_proc_step_data-proc_id IMPORTING es_process_config = ls_proc_config ).
*      CATCH /idxgc/cx_config_error INTO gr_previous.
*        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
*    ENDTRY.
*
*    READ TABLE ls_proc_config-steps ASSIGNING <fs_proc_step_config> WITH KEY proc_step_no = is_process_step_key-proc_step_no.
*    IF sy-subrc = 0.
*      ls_proc_step_key-proc_id  = is_process_step_key-proc_id.
*      IF <fs_proc_step_config>-step_no_src_add IS NOT INITIAL.
*        ls_proc_step_key-proc_step_no = <fs_proc_step_config>-step_no_src_add.
*        TRY.
*            ls_proc_step_data_src_add = lr_process_data_step->get_process_step_data( ls_proc_step_key ).
*          CATCH /idxgc/cx_process_error INTO gr_previous .
*            /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
*        ENDTRY.
*      ENDIF.
*    ENDIF.
*
****** Methodenlogik *******************************************************************************
**---- Datenbereitstellungsklasse und BMID Customizing holen ---------------------------------------
*    TRY.
*        CALL METHOD /idxgc/cl_cust_access=>/idxgc/if_cust_access_add~get_bmid_msg_config
*          EXPORTING
*            iv_bmid       = ls_proc_step_data_src_add-bmid
*            iv_valid_from = ls_proc_step_data_src_add-msg_date
*          IMPORTING
*            es_bmid_var   = ls_bmid_var.
*        CALL METHOD /idxgc/cl_cust_access=>/idxgc/if_cust_access_add~get_bmid_details
*          EXPORTING
*            iv_bmid = ls_proc_step_data_src_add-bmid
*          IMPORTING
*            es_bmid = ls_bmid.
*      CATCH /idxgc/cx_config_error INTO gr_previous.
*        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
*    ENDTRY.
*
**---- Daten vorbereiten ---------------------------------------------------------------------------
*    ls_proc_step_data_src_dp-hdr_attr = ls_proc_step_data_src_add-hdr_attr.
*    ls_proc_step_data_src_dp-bmid     = ls_proc_step_data_src_add-bmid.
*    ls_proc_step_data_src_dp-ext_ui   = ls_proc_step_data_src_add-ext_ui.
*    "Bei Anfragen: Nur MTD_CODE_RESULT und einige Zusatzfelder
*    IF ls_bmid-dexbasicproc = /idxgc/if_constants_ide=>gc_basicproc_e_utilreq.
*      READ TABLE ls_proc_step_data_src_add-diverse ASSIGNING <fs_diverse_src_add> INDEX 1.
*      IF sy-subrc = 0.
*        APPEND INITIAL LINE TO ls_proc_step_data_src_dp-diverse ASSIGNING <fs_diverse_src_dp>.
*        <fs_diverse_src_dp>-item_id          = <fs_diverse_src_add>-item_id.
*        <fs_diverse_src_dp>-transaction_no   = <fs_diverse_src_add>-transaction_no.
*        <fs_diverse_src_dp>-msgtransreason   = <fs_diverse_src_add>-msgtransreason.
*        <fs_diverse_src_dp>-contr_start_date = <fs_diverse_src_add>-contr_start_date.
*        <fs_diverse_src_dp>-validstart_date  = <fs_diverse_src_add>-validstart_date.
*      ENDIF.
*      APPEND LINES OF ls_proc_step_data-mtd_code_result TO ls_proc_step_data_src_dp-mtd_code_result.
*      "Bei Antworten: Alle Daten aus Anfrage
*    ELSEIF ls_bmid-dexbasicproc           = /idxgc/if_constants_ide=>gc_basicproc_e_utilres.
*      ls_proc_step_data_src_dp-non_meter_dev     = ls_proc_step_data_src_add-non_meter_dev.
*      ls_proc_step_data_src_dp-charges           = ls_proc_step_data_src_add-charges.
*      ls_proc_step_data_src_dp-diverse           = ls_proc_step_data_src_add-diverse.
*      ls_proc_step_data_src_dp-name_address      = ls_proc_step_data_src_add-name_address.
*      ls_proc_step_data_src_dp-meter_dev         = ls_proc_step_data_src_add-meter_dev.
*      ls_proc_step_data_src_dp-time_series       = ls_proc_step_data_src_add-time_series.
*      ls_proc_step_data_src_dp-marketpartner_add = ls_proc_step_data_src_add-marketpartner_add.
*      ls_proc_step_data_src_dp-settl_terr        = ls_proc_step_data_src_add-settl_terr.
*      ls_proc_step_data_src_dp-pod               = ls_proc_step_data_src_add-pod.
*      ls_proc_step_data_src_dp-reg_code_data     = ls_proc_step_data_src_add-reg_code_data.
*      ls_proc_step_data_src_dp-settl_unit        = ls_proc_step_data_src_add-settl_unit.
*      ls_proc_step_data_src_dp-pod_quant         = ls_proc_step_data_src_add-pod_quant.
*      ls_proc_step_data_src_dp-msgcomments       = ls_proc_step_data_src_add-msgcomments.
*      APPEND INITIAL LINE TO ls_proc_step_data_src_dp-check ASSIGNING <fs_check>.
*      <fs_check>-exec_flag = abap_true.
*      READ TABLE ls_proc_step_data_src_add-msgrespstatus ASSIGNING <fs_msgrespstatus> INDEX 1.
*      IF sy-subrc = 0.
*        <fs_check>-rejection_code = <fs_msgrespstatus>-respstatus.
*      ELSE.
*        <fs_check>-rejection_code = /idxgc/if_constants_add=>gc_response_code_zg2.
*      ENDIF.
*    ENDIF.
*
*    CLEAR: ls_proc_step_data-non_meter_dev,     ls_proc_step_data-charges,    ls_proc_step_data-diverse,
*           ls_proc_step_data-name_address,      ls_proc_step_data-meter_dev,  ls_proc_step_data-time_series,
*           ls_proc_step_data-marketpartner_add, ls_proc_step_data-settl_terr, ls_proc_step_data-pod,
*           ls_proc_step_data-reg_code_data,     ls_proc_step_data-settl_unit, ls_proc_step_data-pod_quant.
*    ls_proc_step_data-bmid           = ls_proc_step_data_src_add-bmid.
*    ls_proc_step_data-dexbasicproc   = ls_bmid-dexbasicproc.
*    ls_proc_step_data-assoc_servprov = ls_proc_step_data_src_add-assoc_servprov.
*    ls_proc_step_data-own_servprov   = ls_proc_step_data_src_add-own_servprov.
*
**---- Datenbereitstellung aufrufen ----------------------------------------------------------------
*    CREATE OBJECT lr_dp_out
*      TYPE
*        (ls_bmid_var-data_prov_class)
*      EXPORTING
*        is_process_data_src = ls_proc_step_data_src_dp.
*    TRY.
*        lr_dp_out->process_data_provision( CHANGING cs_process_step_data = ls_proc_step_data ).
*      CATCH /idxgc/cx_process_error INTO gr_previous.
*        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
*    ENDTRY.
*    APPEND /idxgc/if_constants_add=>gc_cr_ok TO et_check_result.
*
**---- Daten ändern für Anzeige im Programm und spätere Verarbeitung -------------------------------
*    "Daten löschen, die nicht relevant sind und im Prozessschritt stören
*    CLEAR: ls_proc_step_data-amid, ls_proc_step_data-marketpartner, ls_proc_step_data-dexbasicproc.
*    "Transaktionsnummer aus der Anfrage hier übernehmen für die Antwort.
*    READ TABLE ls_proc_step_data-diverse ASSIGNING <fs_diverse> INDEX 1.
*    IF sy-subrc = 0 AND <fs_diverse_src_add> IS ASSIGNED.
*      <fs_diverse>-transaction_no = <fs_diverse_src_add>-transaction_no.
*    ENDIF.
*
****** Schrittdaten aktualisieren ******************************************************************
*    lr_process_data_step->update_process_step_data( is_process_step_data = ls_proc_step_data ).

    et_check_result = VALUE #( ( /idxgc/if_constants_add=>gc_cr_ok ) ).

  ENDMETHOD.


  METHOD update_step_data_start_sync.
***************************************************************************************************
*            _                        _____ ______
*           | |                      / ____|  ____|
*   __ _  __| | ___  ___ ___  ___   | (___ | |__
*  / _` |/ _` |/ _ \/ __/ __|/ _ \   \___ \|  __|
* | (_| | (_| |  __/\__ \__ \ (_) |  ____) | |____
*  \__,_|\__,_|\___||___/___/\___/  |_____/|______|
*
* Author: THIMEL-R, ECHOUAIBI-I                                                   Datum: 07.11.2019
*
* Beschreibung: Daten aus Antwort holen
*
***************************************************************************************************
* Wichtige / Große Änderungen:
* Nutzer      Datum      Beschreibung
* THIMEL-R    11.03.2020 Prozess 1041 ergänzt
* THIMEL-R    20.09.2020 Anpassung Datenermittlung Prozess 8030 und allgemein Übernahme aus ADD
* THIMEL-R    23.10.2020 Serviceanbieterermittlung aufgenommen
***************************************************************************************************

    DATA: lr_process_data_step   TYPE REF TO /idxgc/if_process_data_step,
          lr_badi_data_provision TYPE REF TO /idxgl/badi_data_provision,
          ls_proc_step_data_add  TYPE /idxgc/s_proc_step_data_all,
          ls_proc_step_data      TYPE /idxgc/s_proc_step_data_all,
          ls_proc_step_key       TYPE /idxgc/s_proc_step_key,
          lv_date_from           TYPE /idxgc/de_date_from,
          lv_date_to             TYPE /idxgc/de_date_to.

    FIELD-SYMBOLS: <lr_process_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
                   <lr_process_log>         TYPE REF TO /idxgc/if_process_log.

***** Schrittdaten holen **************************************************************************
    ASSIGN cr_data->* TO <lr_process_data_extern>.
    ASSIGN cr_data_log->* TO <lr_process_log>.

    IF <lr_process_data_extern> IS ASSIGNED.
      lr_process_data_step ?= <lr_process_data_extern>.
    ELSE.
      MESSAGE e002(/adz/mdc_messages) INTO gv_msgtxt.
      IF <lr_process_log> IS ASSIGNED.
        <lr_process_log>->add_message_to_process_log( is_process_step_key = is_process_step_key ).
      ENDIF.
      et_check_result = VALUE #( ( /idxgc/if_constants_add=>gc_cr_error ) ).
      RETURN.
    ENDIF.

    TRY.
        ls_proc_step_data = lr_process_data_step->get_process_step_data( is_process_step_key ).
      CATCH /idxgc/cx_process_error INTO gx_previous.
        IF <lr_process_log> IS ASSIGNED.
          <lr_process_log>->add_message_to_process_log( is_process_step_key = is_process_step_key ).
        ENDIF.
        et_check_result = VALUE #( ( /idxgc/if_constants_add=>gc_cr_error ) ).
        RETURN.
    ENDTRY.

***** Nicht benötigte Daten löschen ***************************************************************
    CLEAR: ls_proc_step_data-meter_dev,       ls_proc_step_data-non_meter_dev,     ls_proc_step_data-reg_code_data,
           ls_proc_step_data-attribute,       ls_proc_step_data-quantities,        ls_proc_step_data-settl_unit,
           ls_proc_step_data-name_address,    ls_proc_step_data-name_address_ref,  ls_proc_step_data-amid,
           ls_proc_step_data-/idxgl/pod_data, ls_proc_step_data-/idxgl/pod_dates,  ls_proc_step_data-/idxgl/data_relevance,
           ls_proc_step_data-marketpartner,   ls_proc_step_data-marketpartner_add, ls_proc_step_data-settl_terr,
           ls_proc_step_data-time_series,     ls_proc_step_data-msgrespstatus,     ls_proc_step_data-/idxgl/profile_data.

***** Zählpunktdaten ergänzen (unterschiedliche je Prozess) ***************************************
    TRY.
        IF ls_proc_step_data-proc_id = /adz/if_mdc_co=>gc_proc_id-sos_1012.
          ls_proc_step_key      = VALUE #( proc_ref = ls_proc_step_data-proc_ref proc_step_no = '0120' ).
          ls_proc_step_data_add = lr_process_data_step->get_process_step_data( ls_proc_step_key ).
          IF ls_proc_step_data_add IS INITIAL.
            ls_proc_step_key    = VALUE #( proc_ref = ls_proc_step_data-proc_ref proc_step_no = '0390' ).
          ENDIF.
        ELSEIF ls_proc_step_data-proc_id = /adz/if_mdc_co=>gc_proc_id-sbs_1041.
          ls_proc_step_key      = VALUE #( proc_ref = ls_proc_step_data-proc_ref proc_step_no = '0030' ).
        ELSEIF ls_proc_step_data-proc_id = /adz/if_mdc_co=>gc_proc_id-mdc_send_res_8030.
          "Versand als Verantwortlicher: Hier wird die versandte Nachricht gesucht. Die Antwort muss nicht kommen. 25.09.2020
          LOOP AT <lr_process_data_extern>->gs_process_data-steps ASSIGNING FIELD-SYMBOL(<ls_step>)
            WHERE dexbasicproc = /idxgc/if_constants_ide=>gc_basicproc_e_utilreq AND proc_step_status = '001'.
            ls_proc_step_key    = VALUE #( proc_ref = ls_proc_step_data-proc_ref proc_step_no = <ls_step>-proc_step_no ).
          ENDLOOP.
        ELSEIF ls_proc_step_data-proc_id = /adz/if_mdc_co=>gc_proc_id-mdc_send_ath_8031.
          ls_proc_step_key      = VALUE #( proc_ref = ls_proc_step_data-proc_ref proc_step_no = '0415' ).
        ELSEIF ls_proc_step_data-proc_id = /adz/if_mdc_co=>gc_proc_id-mdc_rec_res_8032.
          ls_proc_step_key      = VALUE #( proc_ref = ls_proc_step_data-proc_ref proc_step_no = '0195' ).
        ELSEIF ls_proc_step_data-proc_id = /adz/if_mdc_co=>gc_proc_id-mdc_rec_ath_8033.
          ls_proc_step_key      = VALUE #( proc_ref = ls_proc_step_data-proc_ref proc_step_no = '0205' ).
        ENDIF.

        IF ls_proc_step_data_add IS INITIAL.
          ls_proc_step_data_add = lr_process_data_step->get_process_step_data( ls_proc_step_key ).
        ENDIF.

        ls_proc_step_data-pod             = ls_proc_step_data_add-pod.
        ls_proc_step_data-diverse         = ls_proc_step_data_add-diverse.
        ls_proc_step_data-/idxgl/pod_data = ls_proc_step_data_add-/idxgl/pod_data. "Für Prozess 8030 um Transaktionsgrund zu bestimmen, 25.09.2020

        "Falls noch nicht befüllt auch die Serviceanbieter übernehmen (z.B. in Prozess 1012), 20.09.2020
        IF ls_proc_step_data-assoc_servprov IS INITIAL.
          ls_proc_step_data-assoc_servprov = ls_proc_step_data_add-assoc_servprov.
        ENDIF.
        IF ls_proc_step_data-own_servprov IS INITIAL.
          ls_proc_step_data-own_servprov = ls_proc_step_data_add-own_servprov.
        ENDIF.

      CATCH /idxgc/cx_process_error INTO gx_previous.
        IF <lr_process_log> IS ASSIGNED.
          <lr_process_log>->add_message_to_process_log( is_process_step_key = is_process_step_key ).
        ENDIF.
        et_check_result = VALUE #( ( /idxgc/if_constants_add=>gc_cr_error ) ).
        RETURN.
    ENDTRY.

***** Startdatum (und ggf. Endedatum) ermitteln ***************************************************
    "Bei Stammdatenänderungen ist das Startdatum = Prozessdatum, wenn keine bestehende zukünftige Zuordnung
    lv_date_from = ls_proc_step_data-proc_date.
    IF ls_proc_step_data-proc_id = /adz/if_mdc_co=>gc_proc_id-mdc_send_res_8030 OR
       ls_proc_step_data-proc_id = /adz/if_mdc_co=>gc_proc_id-mdc_send_ath_8031 OR
       ls_proc_step_data-proc_id = /adz/if_mdc_co=>gc_proc_id-mdc_rec_res_8032  OR
       ls_proc_step_data-proc_id = /adz/if_mdc_co=>gc_proc_id-mdc_rec_ath_8033.
      IF line_exists( ls_proc_step_data-diverse[ 1 ] ).
        IF ls_proc_step_data-diverse[ 1 ]-contr_start_date IS NOT INITIAL AND ls_proc_step_data-diverse[ 1 ]-contr_start_date > lv_date_from.
          lv_date_from = ls_proc_step_data-diverse[ 1 ]-contr_start_date.
        ENDIF.
      ENDIF.
    ENDIF.

    "Bei EoG und Lieferbeginn ist das Start (Abweichung zum Prozessdatum möglich!)
    IF ls_proc_step_data-proc_id = /adz/if_mdc_co=>gc_proc_id-sos_1012 OR ls_proc_step_data-proc_id = /adz/if_mdc_co=>gc_proc_id-sbs_1041.
      IF line_exists( ls_proc_step_data-diverse[ 1 ] ) AND ls_proc_step_data-diverse[ 1 ]-startsettldate IS NOT INITIAL.
        lv_date_from = ls_proc_step_data-diverse[ 1 ]-startsettldate.
        lv_date_to   = ls_proc_step_data-diverse[ 1 ]-endsettldate.
      ENDIF.
    ENDIF.

***** Daten in Tabelle SERVICEANBIETER hinterlegen ************************************************
    DATA(lv_ext_ui) = ls_proc_step_data-ext_ui.
    "Tranchen ZP muss im Header vom neuen PDoc stehen, wenn vorhanden.

    LOOP AT ls_proc_step_data-pod ASSIGNING FIELD-SYMBOL(<ls_pod>).
      IF <ls_pod>-int_ui IS INITIAL.
        TRY.
            <ls_pod>-int_ui = /adz/cl_mdc_utility=>get_int_ui( iv_ext_ui = <ls_pod>-ext_ui iv_keydate = lv_date_from ).
          CATCH /idxgc/cx_general.
            "Ohne Fehler weiter
        ENDTRY.
      ENDIF.

      IF <ls_pod>-pod_type IS INITIAL.
        GET BADI lr_badi_data_provision.
        TRY.
            CALL BADI lr_badi_data_provision->determine_pod_type
              EXPORTING
                iv_int_ui       = <ls_pod>-int_ui
                iv_ext_ui       = <ls_pod>-ext_ui
                iv_key_date     = lv_date_from
                iv_process_date = lv_date_from
              RECEIVING
                rv_pod_type     = <ls_pod>-pod_type.

          CATCH /idxgc/cx_general INTO gx_previous.
            IF <lr_process_log> IS ASSIGNED.
              <lr_process_log>->add_message_to_process_log( is_process_step_key = is_process_step_key ).
            ENDIF.
            et_check_result = VALUE #( ( /idxgc/if_constants_add=>gc_cr_error ) ).
            RETURN.
        ENDTRY.
      ENDIF.

      IF <ls_pod>-pod_type = /idxgc/if_constants_add=>gc_pod_type_z70.
        lv_ext_ui = <ls_pod>-ext_ui.
      ENDIF.
    ENDLOOP.

    ls_proc_step_data-serviceprovider = VALUE #( ( ext_ui       = lv_ext_ui
                                                   service_id   = ls_proc_step_data-assoc_servprov
                                                   contract_ref = /adz/if_mdc_co=>gc_bmid-adz_ch185
                                                   date_from    = lv_date_from
                                                   date_to      = lv_date_to   ) ).


    lr_process_data_step->update_process_step_data( ls_proc_step_data ).

    et_check_result = VALUE #( ( /idxgc/if_constants_add=>gc_cr_ok ) ).

  ENDMETHOD.


  METHOD update_system_from_message.
************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: ILIASS ECHOUAIBI                                     Datum: 07.11.2019
*
* Beschreibung:
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************

* DATA: lr_process_data_step  TYPE REF TO /idxgc/if_process_data_step,
*          lr_badi_ref           TYPE REF TO cl_badi_base,
*          lt_badi_name          TYPE TABLE OF badi_name,
*          ls_proc_step_data     TYPE /idxgc/s_proc_step_data_all,
*          ls_proc_step_data_src TYPE /idxgc/s_proc_step_data_all,
*          ls_cust_in            TYPE /adesso/mdc_s_in,
*          ls_proc_step_key      TYPE /idxgc/s_proc_step_key,
*          ls_proc_config        TYPE /idxgc/s_proc_config_all,
*          lv_edifact_structur   TYPE /idxgc/de_edifact_str.
*
*    FIELD-SYMBOLS: <fr_process_log>      TYPE REF TO /idxgc/if_process_log,
*                   <fr_proc_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
*                   <fs_proc_step_config> TYPE /idxgc/s_proc_step_config_all,
*                   <fs_mtd_code_result>  TYPE /idxgc/s_mtd_code_details,
*                   <fv_badi_name>        TYPE badi_name.
*
*    ASSIGN cr_data_log->* TO <fr_process_log>.
*    ASSIGN cr_data->* TO <fr_proc_data_extern>.
*    lr_process_data_step ?= <fr_proc_data_extern>.
*
****** Schrittdaten vom aktuellen Schritt holen ****************************************************
*    TRY.
*        ls_proc_step_data = lr_process_data_step->get_process_step_data( is_process_step_key ).
*      CATCH /idxgc/cx_process_error INTO gr_previous .
*        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
*    ENDTRY.
*
****** Schrittdaten vom zusätzlichem Quellschritt holen ********************************************
*    TRY.
*        /idxgc/cl_cust_access=>/idxgc/if_cust_access~get_process_config( EXPORTING iv_process_id = ls_proc_step_data-proc_id IMPORTING es_process_config = ls_proc_config ).
*      CATCH /idxgc/cx_config_error INTO gr_previous.
*        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
*    ENDTRY.
*
*    READ TABLE ls_proc_config-steps ASSIGNING <fs_proc_step_config> WITH KEY proc_step_no = is_process_step_key-proc_step_no.
*    IF sy-subrc = 0.
*      ls_proc_step_key-proc_id = is_process_step_key-proc_id.
*      IF <fs_proc_step_config>-proc_step_src IS NOT INITIAL.
*        ls_proc_step_key-proc_step_no = <fs_proc_step_config>-proc_step_src.
*        TRY.
*            ls_proc_step_data_src = lr_process_data_step->get_process_step_data( ls_proc_step_key ).
*          CATCH /idxgc/cx_process_error INTO gr_previous .
*            /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
*        ENDTRY.
*      ENDIF.
*    ENDIF.
*
****** Methodenlogik *******************************************************************************
**---- Änderungs-BAdIs ermitteln -------------------------------------------------------------------
*    LOOP AT ls_proc_step_data-mtd_code_result ASSIGNING <fs_mtd_code_result>.
*      lv_edifact_structur = <fs_mtd_code_result>-addinfo.
*      TRY.
*          ls_cust_in = /adesso/cl_mdc_customizing=>get_inbound_config_for_edifact( iv_edifact_structur = lv_edifact_structur iv_assoc_servprov = ls_proc_step_data-assoc_servprov ).
*        CATCH /idxgc/cx_general INTO gr_previous.
*          sy-msgty = /idxgc/if_constants=>gc_message_type_warning.
*          <fr_process_log>->add_message_to_process_log( ).
*          MESSAGE w050(/adesso/mdc_process) INTO gv_mtext.
*          <fr_process_log>->add_message_to_process_log( ).
*      ENDTRY.
*      IF ls_cust_in-badi_name IS NOT INITIAL.
*        APPEND ls_cust_in-badi_name TO lt_badi_name.
*      ENDIF.
*    ENDLOOP.
*
*    SORT lt_badi_name.
*    DELETE ADJACENT DUPLICATES FROM lt_badi_name.
*
**---- Änderungs-Methoden ausführen ----------------------------------------------------------------
*    LOOP AT lt_badi_name ASSIGNING <fv_badi_name>.
*      TRY.
*          GET BADI lr_badi_ref TYPE (<fv_badi_name>)
*            FILTERS mandt = sy-mandt.
*          CALL BADI lr_badi_ref->('CHANGE_AUTO')
*            EXPORTING
*              is_proc_step_data     = ls_proc_step_data
*              is_proc_step_data_src = ls_proc_step_data_src.
*        CATCH cx_root INTO gr_previous.
*          "Bei Fehlern wird später eine manuelle Bearbeitung ausgelöst
*          <fr_process_log>->add_message_to_process_log( ).
*      ENDTRY.
*    ENDLOOP.
*
*    APPEND /idxgc/if_constants_add=>gc_cr_ok TO et_check_result.

    et_check_result = VALUE #( ( /idxgc/if_constants_add=>gc_cr_ok ) ).


  ENDMETHOD.
ENDCLASS.
