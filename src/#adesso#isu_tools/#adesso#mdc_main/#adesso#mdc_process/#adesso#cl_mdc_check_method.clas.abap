class /ADESSO/CL_MDC_CHECK_METHOD definition
  public
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
  class-methods CHECK_DISTRIBUTION_NECESSARY
    importing
      !IS_PROCESS_STEP_KEY type /IDXGC/S_PROC_STEP_KEY
    exporting
      !ET_CHECK_RESULT type /IDXGC/T_CHECK_RESULT
    changing
      !CR_DATA type ref to DATA
      !CR_DATA_LOG type ref to DATA
    raising
      /IDXGC/CX_UTILITY_ERROR .
  class-methods CHECK_FORWARD_NECESSARY
    importing
      !IS_PROCESS_STEP_KEY type /IDXGC/S_PROC_STEP_KEY
    exporting
      !ET_CHECK_RESULT type /IDXGC/T_CHECK_RESULT
    changing
      !CR_DATA type ref to DATA
      !CR_DATA_LOG type ref to DATA
    raising
      /IDXGC/CX_UTILITY_ERROR .
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
  class-methods CHECK_PROCESSING_TYPE_RESP
    importing
      !IS_PROCESS_STEP_KEY type /IDXGC/S_PROC_STEP_KEY
    exporting
      !ET_CHECK_RESULT type /IDXGC/T_CHECK_RESULT
    changing
      !CR_DATA type ref to DATA
      !CR_DATA_LOG type ref to DATA
    raising
      /IDXGC/CX_UTILITY_ERROR .
  class-methods CHECK_RECEIVE_ANSWER_AUTH
    importing
      !IS_PROCESS_STEP_KEY type /IDXGC/S_PROC_STEP_KEY
    exporting
      !ET_CHECK_RESULT type /IDXGC/T_CHECK_RESULT
    changing
      !CR_DATA type ref to DATA
      !CR_DATA_LOG type ref to DATA
    raising
      /IDXGC/CX_UTILITY_ERROR .
  class-methods CHECK_RESPONSE_CODE
    importing
      !IS_PROCESS_STEP_KEY type /IDXGC/S_PROC_STEP_KEY
    exporting
      !ET_CHECK_RESULT type /IDXGC/T_CHECK_RESULT
    changing
      !CR_DATA type ref to DATA
      !CR_DATA_LOG type ref to DATA
    raising
      /IDXGC/CX_UTILITY_ERROR .
  class-methods CHECK_TRANSACTION_ALLOWED
    importing
      !IS_PROCESS_STEP_KEY type /IDXGC/S_PROC_STEP_KEY
    exporting
      !ET_CHECK_RESULT type /IDXGC/T_CHECK_RESULT
    changing
      !CR_DATA type ref to DATA
      !CR_DATA_LOG type ref to DATA
    raising
      /IDXGC/CX_UTILITY_ERROR .
  class-methods CHECK_WAIT_TIME_BEFORE_SEND
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
  class-methods UPDATE_STEP_DATA_FOR_NEW_PDOC
    importing
      !IS_PROCESS_STEP_KEY type /IDXGC/S_PROC_STEP_KEY
    exporting
      !ET_CHECK_RESULT type /IDXGC/T_CHECK_RESULT
    changing
      !CR_DATA type ref to DATA
      !CR_DATA_LOG type ref to DATA
    raising
      /IDXGC/CX_UTILITY_ERROR .
  class-methods UPDATE_STEP_DATA_FROM_SRC_ADD
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

    CLASS-DATA gr_previous TYPE REF TO cx_root .
    CLASS-DATA gv_mtext TYPE string .
private section.
ENDCLASS.



CLASS /ADESSO/CL_MDC_CHECK_METHOD IMPLEMENTATION.


  METHOD check_already_exch_meter_proc.
    DATA: lr_process_data_step  TYPE REF TO /idxgc/if_process_data_step,
          ls_proc_step_data     TYPE /idxgc/s_proc_step_data_all,
          ls_proc_step_data_src TYPE /idxgc/s_proc_step_data_all,
          ls_proc_step_key      TYPE /idxgc/s_proc_step_key,
          ls_proc_config        TYPE /idxgc/s_proc_config_all,
          lv_class_name         TYPE seoclsname,
          lv_method_name        TYPE seocpdname.

    FIELD-SYMBOLS: <fr_process_log>      TYPE REF TO /idxgc/if_process_log,
                   <fr_proc_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
                   <fs_proc_step_config> TYPE /idxgc/s_proc_step_config_all,
                   <fs_diverse>          TYPE /idxgc/s_diverse_details,
                   <fs_diverse_src>      TYPE /idxgc/s_diverse_details.

    ASSIGN cr_data_log->* TO <fr_process_log>.
    ASSIGN cr_data->* TO <fr_proc_data_extern>.
    lr_process_data_step ?= <fr_proc_data_extern>.

***** Schrittdaten vom aktuellen Schritt holen ****************************************************
    TRY.
        ls_proc_step_data = lr_process_data_step->get_process_step_data( is_process_step_key ).
      CATCH /idxgc/cx_process_error INTO gr_previous .
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.

***** Schrittdaten vom zusätzlichem Quellschritt holen ********************************************
    TRY.
        /idxgc/cl_cust_access=>/idxgc/if_cust_access~get_process_config( EXPORTING iv_process_id = ls_proc_step_data-proc_id IMPORTING es_process_config = ls_proc_config ).
      CATCH /idxgc/cx_config_error INTO gr_previous.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.

    READ TABLE ls_proc_config-steps ASSIGNING <fs_proc_step_config> WITH KEY proc_step_no = is_process_step_key-proc_step_no.
    IF sy-subrc = 0.
      ls_proc_step_key-proc_id  = is_process_step_key-proc_id.
      IF <fs_proc_step_config>-proc_step_src IS NOT INITIAL.
        ls_proc_step_key-proc_step_no = <fs_proc_step_config>-proc_step_src.
        TRY.
            ls_proc_step_data_src = lr_process_data_step->get_process_step_data( ls_proc_step_key ).
          CATCH /idxgc/cx_process_error INTO gr_previous .
            /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
        ENDTRY.
      ENDIF.
    ENDIF.

***** Methodenlogik *******************************************************************************
    READ TABLE ls_proc_step_data-diverse ASSIGNING <fs_diverse> INDEX 1.
    READ TABLE ls_proc_step_data_src-diverse ASSIGNING <fs_diverse_src> INDEX 1.
    IF <fs_diverse> IS ASSIGNED AND <fs_diverse_src> IS ASSIGNED AND
       <fs_diverse>-exch_meter_proc = <fs_diverse_src>-exch_meter_proc.
      APPEND /adesso/if_mdc_co=>gc_cr_exch_meter_proc_equal TO et_check_result.
    ELSE.
      APPEND /adesso/if_mdc_co=>gc_cr_exch_meter_proc_unequal TO et_check_result.
    ENDIF.

  ENDMETHOD.


  METHOD check_already_exch_pod_type.
    DATA: lr_process_data_step  TYPE REF TO /idxgc/if_process_data_step,
          ls_proc_step_data     TYPE /idxgc/s_proc_step_data_all,
          ls_proc_step_data_src TYPE /idxgc/s_proc_step_data_all,
          ls_proc_step_key      TYPE /idxgc/s_proc_step_key,
          ls_proc_config        TYPE /idxgc/s_proc_config_all,
          lv_class_name         TYPE seoclsname,
          lv_method_name        TYPE seocpdname.

    FIELD-SYMBOLS: <fr_process_log>      TYPE REF TO /idxgc/if_process_log,
                   <fr_proc_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
                   <fs_proc_step_config> TYPE /idxgc/s_proc_step_config_all,
                   <fs_pod>              TYPE /idxgc/s_pod_info_details,
                   <fs_pod_src>          TYPE /idxgc/s_pod_info_details.

    ASSIGN cr_data_log->* TO <fr_process_log>.
    ASSIGN cr_data->* TO <fr_proc_data_extern>.
    lr_process_data_step ?= <fr_proc_data_extern>.

***** Schrittdaten vom aktuellen Schritt holen ****************************************************
    TRY.
        ls_proc_step_data = lr_process_data_step->get_process_step_data( is_process_step_key ).
      CATCH /idxgc/cx_process_error INTO gr_previous .
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.

***** Schrittdaten vom zusätzlichem Quellschritt holen ********************************************
    TRY.
        /idxgc/cl_cust_access=>/idxgc/if_cust_access~get_process_config( EXPORTING iv_process_id = ls_proc_step_data-proc_id IMPORTING es_process_config = ls_proc_config ).
      CATCH /idxgc/cx_config_error INTO gr_previous.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.

    READ TABLE ls_proc_config-steps ASSIGNING <fs_proc_step_config> WITH KEY proc_step_no = is_process_step_key-proc_step_no.
    IF sy-subrc = 0.
      ls_proc_step_key-proc_id  = is_process_step_key-proc_id.
      IF <fs_proc_step_config>-proc_step_src IS NOT INITIAL.
        ls_proc_step_key-proc_step_no = <fs_proc_step_config>-proc_step_src.
        TRY.
            ls_proc_step_data_src = lr_process_data_step->get_process_step_data( ls_proc_step_key ).
          CATCH /idxgc/cx_process_error INTO gr_previous .
            /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
        ENDTRY.
      ENDIF.
    ENDIF.

***** Methodenlogik *******************************************************************************
    READ TABLE ls_proc_step_data-pod ASSIGNING <fs_pod> INDEX 1.
    READ TABLE ls_proc_step_data_src-pod ASSIGNING <fs_pod_src> INDEX 1.
    IF <fs_pod> IS ASSIGNED AND <fs_pod_src> IS ASSIGNED AND
       <fs_pod>-exch_pod_type = <fs_pod_src>-exch_pod_type.
      APPEND /adesso/if_mdc_co=>gc_cr_exch_pod_type_equal TO et_check_result.
    ELSE.
      APPEND /adesso/if_mdc_co=>gc_cr_exch_pod_type_unequal TO et_check_result.
    ENDIF.

  ENDMETHOD.


  METHOD check_compare_result.
    DATA: lr_process_data_step TYPE REF TO /idxgc/if_process_data_step,
          ls_proc_step_data    TYPE /idxgc/s_proc_step_data_all.

    FIELD-SYMBOLS: <fr_process_log>      TYPE REF TO /idxgc/if_process_log,
                   <fr_proc_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
                   <fs_mtd_code_result>  TYPE /idxgc/s_mtd_code_details.

    ASSIGN cr_data_log->* TO <fr_process_log>.
    ASSIGN cr_data->* TO <fr_proc_data_extern>.
    lr_process_data_step ?= <fr_proc_data_extern>.

***** Schrittdaten vom aktuellen Schritt holen ****************************************************
    TRY.
        ls_proc_step_data = lr_process_data_step->get_process_step_data( is_process_step_key ).
      CATCH /idxgc/cx_process_error INTO gr_previous .
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.

***** Methodenlogik *******************************************************************************
    LOOP AT ls_proc_step_data-mtd_code_result ASSIGNING <fs_mtd_code_result>.
      IF <fs_mtd_code_result>-src_field_value <> <fs_mtd_code_result>-cmp_field_value.
        APPEND /adesso/if_mdc_co=>gc_cr_difference_found TO et_check_result.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF et_check_result IS INITIAL.
      APPEND /adesso/if_mdc_co=>gc_cr_no_difference_found TO et_check_result.
    ENDIF.
  ENDMETHOD.


  METHOD check_distribution_necessary.
    DATA: lr_process_data_step TYPE REF TO /idxgc/if_process_data_step,
          ls_proc_step_data    TYPE /idxgc/s_proc_step_data_all.

    FIELD-SYMBOLS: <fr_process_log>      TYPE REF TO /idxgc/if_process_log,
                   <fr_proc_data_extern> TYPE REF TO /idxgc/if_process_data_extern.

    ASSIGN cr_data_log->* TO <fr_process_log>.
    ASSIGN cr_data->* TO <fr_proc_data_extern>.
    lr_process_data_step ?= <fr_proc_data_extern>.

***** Schrittdaten vom aktuellen Schritt holen ****************************************************
    TRY.
        ls_proc_step_data = lr_process_data_step->get_process_step_data( is_process_step_key ).
      CATCH /idxgc/cx_process_error INTO gr_previous .
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.

***** Methodenlogik *******************************************************************************
    IF lines( ls_proc_step_data-serviceprovider ) > 0.
      APPEND /adesso/if_mdc_co=>gc_cr_distribution_needed TO et_check_result.
    ELSE.
      APPEND /adesso/if_mdc_co=>gc_cr_distribution_not_needed TO et_check_result.
    ENDIF.
  ENDMETHOD.


  METHOD check_forward_necessary.
    DATA: lr_process_data_step TYPE REF TO /idxgc/if_process_data_step,
          lt_servprovs         TYPE /idxgc/t_servprov_details,
          ls_proc_step_data    TYPE /idxgc/s_proc_step_data_all.

    FIELD-SYMBOLS: <fr_process_log>      TYPE REF TO /idxgc/if_process_log,
                   <fr_proc_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
                   <fs_serviceprovider>  TYPE /idxgc/s_servprov_details.

    ASSIGN cr_data_log->* TO <fr_process_log>.
    ASSIGN cr_data->* TO <fr_proc_data_extern>.
    lr_process_data_step ?= <fr_proc_data_extern>.

***** Schrittdaten vom aktuellen Schritt holen ****************************************************
    TRY.
        ls_proc_step_data = lr_process_data_step->get_process_step_data( is_process_step_key ).
      CATCH /idxgc/cx_process_error INTO gr_previous .
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.

***** Methodenlogik *******************************************************************************
*---- Bei CH201 immer Weiterleitung an den Lieferant ----------------------------------------------
    IF ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch201.
      APPEND /adesso/if_mdc_co=>gc_cr_forward TO et_check_result.

*---- Bei CH221 und CH222 Weiterleitung an MSB, falls das Netz dieses Rolle nicht selbst ausfüllt -
    ELSE.
      TRY.
          lt_servprovs = /adesso/cl_mdc_utility=>get_servprovs_for_pod( iv_int_ui = ls_proc_step_data-int_ui iv_keydate = ls_proc_step_data-proc_date ).
        CATCH /idxgc/cx_general INTO gr_previous.
          /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
      ENDTRY.
      LOOP AT lt_servprovs TRANSPORTING NO FIELDS WHERE service_cat = /adesso/if_mdc_co=>gc_intcode_m1 AND own_service = abap_false.
        APPEND /adesso/if_mdc_co=>gc_cr_forward TO et_check_result.
        EXIT.
      ENDLOOP.
    ENDIF.

    IF et_check_result IS INITIAL.
      APPEND /adesso/if_mdc_co=>gc_cr_no_forward TO et_check_result.
    ENDIF.

  ENDMETHOD.


  METHOD check_notification_period.
***************************************************************************************************
* THIMEL.R, 20150906, SDÄ auf Common Layer
*   Kopiert aus /IDXGC/CL_CHECK_METHOD_ADD=>CHECK_NOTIFICATION_PERIOD und Rückgabewert so
*     angepasst, dass immer 'NOTIFICATION_PERIOD_OK' zurückgegeben wird, wenn keine Fristverletzung
*     festgestellt wurde.
***************************************************************************************************
    DATA: lv_check_result   TYPE /idxgc/de_check_result,
          ls_proc_step_data TYPE /idxgc/s_proc_step_data_all,
          ls_proc_data      TYPE /idxgc/s_proc_data,
          ls_diverse        TYPE /idxgc/s_diverse_details,
          lv_date           TYPE dats,
          lr_process_data   TYPE REF TO /idxgc/if_process_data,
          lx_previous       TYPE REF TO /idxgc/cx_general.

    FIELD-SYMBOLS: <fs_ref_process_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
                   <fs_ref_process_log>         TYPE REF TO /idxgc/if_process_log.

    ASSIGN cr_data->*     TO  <fs_ref_process_data_extern>.
    ASSIGN cr_data_log->* TO  <fs_ref_process_log>.

    lr_process_data ?= <fs_ref_process_data_extern>.

* Get process data,Step data
    TRY.
        CALL METHOD <fs_ref_process_data_extern>->get_process_step_data
          EXPORTING
            is_process_step_key  = is_process_step_key
          RECEIVING
            rs_process_step_data = ls_proc_step_data.

      CATCH /idxgc/cx_process_error INTO lx_previous.
        <fs_ref_process_log>->add_message_to_process_log( ).
        CALL METHOD /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = lx_previous ).
    ENDTRY.

* Notification Period check only available for settlement relevant data
    IF ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch131 OR
       ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch141 OR
       ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch151 OR
       ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch161 OR
       ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch231 OR
       ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch241 OR
       ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch251.

* The message date has to be at least a whole month ahead of the VALIDSTART_DATE
* Example: in case of VALIDSTART_DATE = 01.06.2015 the message date has to be before
* the 01.05.2015 (message date = 01.05.2015 is not o.k.; message date 30.04.2015 is fine).
* If the nodification is not valid, set check result to 'NOTIFICATION_PERIOD_VIOLATION',
* otherwise, set check result to 'NOTIFICATION_PERIOD_OK'.
      READ TABLE ls_proc_step_data-diverse INTO ls_diverse INDEX 1.
      IF ls_diverse-validstart_date+6(2) <> '01'.
        lv_check_result = /idxgc/if_constants_add=>gc_cr_notiperiod_violation. "'NOTIFICATION_PERIOD_VIOLATION'

      ELSE.
        CALL FUNCTION 'FIMA_DATE_CREATE'
          EXPORTING
            i_date   = ls_diverse-validstart_date
            i_months = '-1'
          IMPORTING
            e_date   = lv_date.

        IF lv_date > ls_proc_step_data-msg_date.
          lv_check_result = /idxgc/if_constants_add=>gc_cr_notiperiod_ok.        "'NOTIFICATION_PERIOD_OK'
        ELSE.
          lv_check_result = /idxgc/if_constants_add=>gc_cr_notiperiod_violation. "'NOTIFICATION_PERIOD_VIOLATION'
        ENDIF.

      ENDIF.
    ELSE.
      lv_check_result = /idxgc/if_constants_add=>gc_cr_notiperiod_ok.            "'NOTIFICATION_PERIOD_OK'
    ENDIF.
    APPEND lv_check_result TO et_check_result.
  ENDMETHOD.


  METHOD check_processing_type_auth.
    DATA: lr_process_data_step TYPE REF TO /idxgc/if_process_data_step,
          ls_proc_step_data    TYPE /idxgc/s_proc_step_data_all,
*          ls_proc_step_data_src_add TYPE /idxgc/s_proc_step_data_all,
*          ls_proc_step_key          TYPE /idxgc/s_proc_step_key,
*          ls_proc_config            TYPE /idxgc/s_proc_config_all,
          ls_cust_in           TYPE /adesso/mdc_s_in,
          lv_edifact_structur  TYPE /idxgc/de_edifact_str,
          lv_flag_response     TYPE /idxgc/de_boolean_flag.

    FIELD-SYMBOLS: <fr_process_log>      TYPE REF TO /idxgc/if_process_log,
                   <fr_proc_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
*                   <fs_proc_step_config> TYPE /idxgc/s_proc_step_config_all,
                   <fs_mtd_code_result>  TYPE /idxgc/s_mtd_code_details.

    ASSIGN cr_data_log->* TO <fr_process_log>.
    ASSIGN cr_data->* TO <fr_proc_data_extern>.
    lr_process_data_step ?= <fr_proc_data_extern>.

***** Schrittdaten vom aktuellen Schritt holen ****************************************************
    TRY.
        ls_proc_step_data = lr_process_data_step->get_process_step_data( is_process_step_key ).
      CATCH /idxgc/cx_process_error INTO gr_previous .
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.

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

***** Methodenlogik *******************************************************************************
*---- Anfrage oder Antwort? -----------------------------------------------------------------------
    READ TABLE ls_proc_step_data-msgrespstatus TRANSPORTING NO FIELDS INDEX 1.
    IF sy-subrc = 0.
      lv_flag_response = abap_true.
    ENDIF.

*---- (Teilweise) automatische Verbuchung möglich? ------------------------------------------------
    LOOP AT ls_proc_step_data-mtd_code_result ASSIGNING <fs_mtd_code_result>.
      lv_edifact_structur = <fs_mtd_code_result>-addinfo.
      TRY.
          CLEAR: ls_cust_in.
          ls_cust_in = /adesso/cl_mdc_customizing=>get_inbound_config_for_edifact( iv_edifact_structur = lv_edifact_structur iv_assoc_servprov = ls_proc_step_data-assoc_servprov ).
        CATCH /idxgc/cx_general INTO gr_previous.
          ls_cust_in-auto_change = /adesso/if_mdc_co=>gc_in_change_manual.
          ls_cust_in-auto_change_response = /adesso/if_mdc_co=>gc_in_change_manual.
          sy-msgty = /idxgc/if_constants=>gc_message_type_warning.
          <fr_process_log>->add_message_to_process_log( ).
          MESSAGE w050(/adesso/mdc_process) INTO gv_mtext.
          <fr_process_log>->add_message_to_process_log( ).
      ENDTRY.
      IF lv_flag_response = abap_false.
        IF ls_cust_in-auto_change = /adesso/if_mdc_co=>gc_in_change_auto.
          APPEND /adesso/if_mdc_co=>gc_cr_change_auto TO et_check_result.
          EXIT.
        ENDIF.
      ELSE.
        IF ls_cust_in-auto_change_response = /adesso/if_mdc_co=>gc_in_change_auto.
          APPEND /adesso/if_mdc_co=>gc_cr_change_auto TO et_check_result.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.
    IF et_check_result IS INITIAL.
      APPEND /adesso/if_mdc_co=>gc_cr_change_manual TO et_check_result.
    ENDIF.
  ENDMETHOD.


  METHOD check_processing_type_resp.
    DATA: lr_process_data_step TYPE REF TO /idxgc/if_process_data_step,
          ls_proc_step_data    TYPE /idxgc/s_proc_step_data_all,
          ls_cust_in           TYPE /adesso/mdc_s_in,
          lv_edifact_structur  TYPE /idxgc/de_edifact_str,
          lv_check_result      TYPE /idxgc/de_check_result.

    FIELD-SYMBOLS: <fr_process_log>      TYPE REF TO /idxgc/if_process_log,
                   <fr_proc_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
                   <fs_mtd_code_result>  TYPE /idxgc/s_mtd_code_details.

    ASSIGN cr_data_log->* TO <fr_process_log>.
    ASSIGN cr_data->* TO <fr_proc_data_extern>.
    lr_process_data_step ?= <fr_proc_data_extern>.

***** Schrittdaten vom aktuellen Schritt holen ****************************************************
    TRY.
        ls_proc_step_data = lr_process_data_step->get_process_step_data( is_process_step_key ).
      CATCH /idxgc/cx_process_error INTO gr_previous .
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.

***** Methodenlogik *******************************************************************************
    LOOP AT ls_proc_step_data-mtd_code_result ASSIGNING <fs_mtd_code_result>.
      lv_edifact_structur = <fs_mtd_code_result>-addinfo.
      TRY.
          CLEAR: ls_cust_in.
          ls_cust_in = /adesso/cl_mdc_customizing=>get_inbound_config_for_edifact( iv_edifact_structur = lv_edifact_structur iv_assoc_servprov = ls_proc_step_data-assoc_servprov ).
        CATCH /idxgc/cx_general INTO gr_previous.
          ls_cust_in-auto_change = /adesso/if_mdc_co=>gc_in_change_manual.
          sy-msgty = /idxgc/if_constants=>gc_message_type_warning.
          <fr_process_log>->add_message_to_process_log( ).
          MESSAGE w050(/adesso/mdc_process) INTO gv_mtext.
          <fr_process_log>->add_message_to_process_log( ).
      ENDTRY.
      IF ls_cust_in-auto_change = /adesso/if_mdc_co=>gc_in_change_auto.
        CLEAR: et_check_result.
        APPEND /adesso/if_mdc_co=>gc_cr_change_auto TO et_check_result.
        EXIT.
      ELSEIF ls_cust_in-auto_change = /adesso/if_mdc_co=>gc_in_change_manual.
        APPEND /adesso/if_mdc_co=>gc_cr_change_manual TO et_check_result.
      ENDIF.
    ENDLOOP.
    IF et_check_result IS INITIAL.
      APPEND /adesso/if_mdc_co=>gc_cr_change_auto_reject TO et_check_result.
    ENDIF.
  ENDMETHOD.


  METHOD check_receive_answer_auth.
    DATA: lr_process_data_step TYPE REF TO /idxgc/if_process_data_step,
          ls_proc_step_data    TYPE /idxgc/s_proc_step_data_all.

    FIELD-SYMBOLS: <fr_process_log>      TYPE REF TO /idxgc/if_process_log,
                   <fr_proc_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
                   <fs_msg_respstatus>   TYPE /idxgc/s_msgsts_details.

    ASSIGN cr_data_log->* TO <fr_process_log>.
    ASSIGN cr_data->* TO <fr_proc_data_extern>.
    lr_process_data_step ?= <fr_proc_data_extern>.

***** Schrittdaten vom aktuellen Schritt holen ****************************************************
    TRY.
        ls_proc_step_data = lr_process_data_step->get_process_step_data( is_process_step_key ).
      CATCH /idxgc/cx_process_error INTO gr_previous .
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.

***** Methodenlogik *******************************************************************************
    IF lines( ls_proc_step_data-msgrespstatus ) = 1.
      READ TABLE ls_proc_step_data-msgrespstatus ASSIGNING <fs_msg_respstatus> INDEX 1.
      IF <fs_msg_respstatus>-respstatus = /idxgc/if_constants_add=>gc_response_code_zg2 OR
         <fs_msg_respstatus>-respstatus = /adesso/if_mdc_co=>gc_response_code_zg4.
        APPEND /idxgc/if_constants_add=>gc_cr_response TO et_check_result.
      ELSE.
        APPEND /idxgc/if_constants_add=>gc_cr_rec_reject TO et_check_result.
      ENDIF.
    ELSE.
      MESSAGE e027(/adesso/mdc_process) INTO gv_mtext.
      /idxgc/cx_utility_error=>raise_util_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD check_response_code.
    DATA: lr_process_data_step TYPE REF TO /idxgc/if_process_data_step,
          lr_badi_exception    TYPE REF TO /idxgc/badi_exception,
          ls_proc_step_data    TYPE /idxgc/s_proc_step_data_all,
          ls_cust_in           TYPE /adesso/mdc_s_in,
          lv_edifact_structur  TYPE /idxgc/de_edifact_str,
          lv_check_result      TYPE /idxgc/de_check_result.

    FIELD-SYMBOLS: <fr_process_log>      TYPE REF TO /idxgc/if_process_log,
                   <fr_proc_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
                   <fs_mtd_code_result>  TYPE /idxgc/s_mtd_code_details.

    ASSIGN cr_data_log->* TO <fr_process_log>.
    ASSIGN cr_data->* TO <fr_proc_data_extern>.
    lr_process_data_step ?= <fr_proc_data_extern>.

***** Schrittdaten vom aktuellen Schritt holen ****************************************************
    TRY.
        ls_proc_step_data = lr_process_data_step->get_process_step_data( is_process_step_key ).
      CATCH /idxgc/cx_process_error INTO gr_previous .
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.

***** Methodenlogik *******************************************************************************
    LOOP AT ls_proc_step_data-check TRANSPORTING NO FIELDS WHERE proc_step_value IS NOT INITIAL AND rejection_code IS NOT INITIAL.
      APPEND /adesso/if_mdc_co=>gc_cr_response_code_set TO et_check_result.
      EXIT.
    ENDLOOP.
    IF et_check_result IS INITIAL.
      APPEND /adesso/if_mdc_co=>gc_cr_response_code_not_set TO et_check_result.

      GET BADI lr_badi_exception
        FILTERS
          iv_proc_cluster = ''.

      TRY.
          CALL BADI lr_badi_exception->reprocess_step
            EXPORTING
              iv_process_ref      = ls_proc_step_data-proc_ref
              iv_process_step_ref = ls_proc_step_data-proc_step_ref.
        CATCH /idxgc/cx_utility_error INTO gr_previous.
          <fr_process_log>->add_message_to_process_log( ).
      ENDTRY.
    ENDIF.
  ENDMETHOD.


  METHOD CHECK_TRANSACTION_ALLOWED.
    DATA: lr_process_data_step TYPE REF TO /idxgc/if_process_data_step,
          ls_proc_step_data    TYPE /idxgc/s_proc_step_data_all,
          lv_own_intcode       TYPE intcode.

    FIELD-SYMBOLS: <fr_process_log>      TYPE REF TO /idxgc/if_process_log,
                   <fr_proc_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
                   <fs_amid>             TYPE /idxgc/s_amid_details.

    ASSIGN cr_data_log->* TO <fr_process_log>.
    ASSIGN cr_data->* TO <fr_proc_data_extern>.
    lr_process_data_step ?= <fr_proc_data_extern>.

***** Schrittdaten vom aktuellen Schritt holen ****************************************************
    TRY.
        ls_proc_step_data = lr_process_data_step->get_process_step_data( is_process_step_key ).
      CATCH /idxgc/cx_process_error INTO gr_previous .
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.

***** Methodenlogik *******************************************************************************
    "READ TABLE ls_proc_step_data-amid ASSIGNING <fs_amid> INDEX 1.
    TRY.
        lv_own_intcode = /adesso/cl_mdc_customizing=>get_own_intcode( ).
      CATCH /idxgc/cx_general INTO gr_previous.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.

    IF lv_own_intcode = /idxgc/if_constants=>gc_service_code_supplier.
      IF ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch101 OR
         ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch102 OR
         ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch112 OR
         ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch113 OR
         ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch121 OR
         ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch123 OR
         ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch131 OR
         ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch162 OR
         ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch163 OR
         ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch201 OR
         ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch202 OR
         ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch203 OR
         ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch211 OR
         ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch212 OR
         ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch213 OR
         ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch221 OR
         ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch222 OR
         ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch225 OR
         ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch226 OR
         ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch241 OR
         ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch251.
        APPEND /adesso/if_mdc_co=>gc_cr_transaction_not_allowed TO et_check_result.
      ELSE.
        APPEND /adesso/if_mdc_co=>gc_cr_transaction_allowed TO et_check_result.
      ENDIF.
    ELSE.
      IF ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch111 OR
         ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch122 OR
         ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch141 OR
         ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch151 OR
         ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch161 OR
         ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch204 OR
         ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch205 OR
         ls_proc_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ch231.
        APPEND /adesso/if_mdc_co=>gc_cr_transaction_not_allowed TO et_check_result.
      ELSE.
        APPEND /adesso/if_mdc_co=>gc_cr_transaction_allowed TO et_check_result.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD check_wait_time_before_send.
    DATA: lr_process_data_step TYPE REF TO /idxgc/if_process_data_step,
          ls_proc_step_data    TYPE /idxgc/s_proc_step_data_all,
          lv_edifact_structur  TYPE /idxgc/de_edifact_str.

    FIELD-SYMBOLS: <fr_process_log>      TYPE REF TO /idxgc/if_process_log,
                   <fr_proc_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
                   <fs_mtd_code_result>  TYPE /idxgc/s_mtd_code_details.

    ASSIGN cr_data_log->* TO <fr_process_log>.
    ASSIGN cr_data->* TO <fr_proc_data_extern>.
    lr_process_data_step ?= <fr_proc_data_extern>.

***** Schrittdaten vom aktuellen Schritt holen ****************************************************
    TRY.
        ls_proc_step_data = lr_process_data_step->get_process_step_data( is_process_step_key ).
      CATCH /idxgc/cx_process_error INTO gr_previous .
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.

***** Methodenlogik *******************************************************************************
    LOOP AT ls_proc_step_data-mtd_code_result ASSIGNING <fs_mtd_code_result>.
      TRY.
          lv_edifact_structur = <fs_mtd_code_result>-addinfo.
          IF /adesso/cl_mdc_customizing=>get_send_delay( iv_edifact_structur = lv_edifact_structur
                                                         iv_keydate          = ls_proc_step_data-proc_date
                                                         iv_assoc_servprov   = ls_proc_step_data-assoc_servprov ) IS NOT INITIAL.
            APPEND /adesso/if_mdc_co=>gc_cr_wait TO et_check_result.
            RETURN.
          ENDIF.
        CATCH /idxgc/cx_general.
          "Kein Warten wenn kein Customizing vorhanden ist.
      ENDTRY.
    ENDLOOP.

    IF et_check_result is INITIAL.
      APPEND /adesso/if_mdc_co=>gc_cr_no_wait TO et_check_result.
    ENDIF.

  ENDMETHOD.


  METHOD check_wait_time_for_update.
    DATA: lr_process_data_step TYPE REF TO /idxgc/if_process_data_step,
          lr_badi_exception    TYPE REF TO /idxgc/badi_exception,
          ls_proc_step_data    TYPE /idxgc/s_proc_step_data_all,
          ls_cust_in           TYPE /adesso/mdc_s_in,
          lv_edifact_structur  TYPE /idxgc/de_edifact_str.

    FIELD-SYMBOLS: <fr_process_log>      TYPE REF TO /idxgc/if_process_log,
                   <fr_proc_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
                   <fs_mtd_code_result>  TYPE /idxgc/s_mtd_code_details.

    ASSIGN cr_data_log->* TO <fr_process_log>.
    ASSIGN cr_data->* TO <fr_proc_data_extern>.
    lr_process_data_step ?= <fr_proc_data_extern>.

***** Schrittdaten vom aktuellen Schritt holen ****************************************************
    TRY.
        ls_proc_step_data = lr_process_data_step->get_process_step_data( is_process_step_key ).
      CATCH /idxgc/cx_process_error INTO gr_previous.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.

***** Methodenlogik *******************************************************************************
    LOOP AT ls_proc_step_data-mtd_code_result ASSIGNING <fs_mtd_code_result>.
      CHECK <fs_mtd_code_result>-src_field_value <> <fs_mtd_code_result>-cmp_field_value.
      lv_edifact_structur = <fs_mtd_code_result>-addinfo.
      TRY.
          ls_cust_in = /adesso/cl_mdc_customizing=>get_inbound_config_for_edifact( iv_edifact_structur = lv_edifact_structur
                                                                                   iv_keydate = ls_proc_step_data-proc_date
                                                                                   iv_assoc_servprov = ls_proc_step_data-assoc_servprov ).
          IF ls_cust_in-auto_change_delay IS NOT INITIAL.
            APPEND /adesso/if_mdc_co=>gc_cr_wait TO et_check_result.
            RETURN.
          ENDIF.
        CATCH /idxgc/cx_general.
          "Kein Customizing bedeutet auch, dass nicht gewartet werden soll / muss
      ENDTRY.
    ENDLOOP.

    IF lines( et_check_result ) = 0.
      APPEND /adesso/if_mdc_co=>gc_cr_no_wait TO et_check_result.
    ENDIF.
  ENDMETHOD.


  METHOD update_compare_result.
    DATA: lr_process_data_step      TYPE REF TO /idxgc/if_process_data_step,
          ls_proc_step_data         TYPE /idxgc/s_proc_step_data_all,
          ls_proc_step_data_src_add TYPE /idxgc/s_proc_step_data_all,
          ls_proc_step_data_1       TYPE /idxgc/s_proc_step_data,
          ls_proc_step_data_2       TYPE /idxgc/s_proc_step_data,
          ls_proc_step_key          TYPE /idxgc/s_proc_step_key,
          ls_proc_config            TYPE /idxgc/s_proc_config_all.

    FIELD-SYMBOLS: <fr_process_log>      TYPE REF TO /idxgc/if_process_log,
                   <fr_proc_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
                   <fs_proc_step_config> TYPE /idxgc/s_proc_step_config_all,
                   <fs_mtd_code_result>  TYPE /idxgc/s_mtd_code_details.

    ASSIGN cr_data_log->* TO <fr_process_log>.
    ASSIGN cr_data->* TO <fr_proc_data_extern>.
    lr_process_data_step ?= <fr_proc_data_extern>.

***** Schrittdaten vom aktuellen Schritt holen ****************************************************
    TRY.
        ls_proc_step_data = lr_process_data_step->get_process_step_data( is_process_step_key ).
      CATCH /idxgc/cx_process_error INTO gr_previous .
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.

***** Schrittdaten vom zusätzlichem Quellschritt holen ********************************************
    TRY.
        /idxgc/cl_cust_access=>/idxgc/if_cust_access~get_process_config( EXPORTING iv_process_id = ls_proc_step_data-proc_id IMPORTING es_process_config = ls_proc_config ).
      CATCH /idxgc/cx_config_error INTO gr_previous.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.

    READ TABLE ls_proc_config-steps ASSIGNING <fs_proc_step_config> WITH KEY proc_step_no = is_process_step_key-proc_step_no.
    IF sy-subrc = 0.
      ls_proc_step_key-proc_id = is_process_step_key-proc_id.
      IF <fs_proc_step_config>-step_no_src_add IS NOT INITIAL.
        ls_proc_step_key-proc_step_no = <fs_proc_step_config>-step_no_src_add.
        TRY.
            ls_proc_step_data_src_add = lr_process_data_step->get_process_step_data( ls_proc_step_key ).
          CATCH /idxgc/cx_process_error INTO gr_previous .
            /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
        ENDTRY.
      ENDIF.
    ENDIF.

***** Methodenlogik *******************************************************************************
    MOVE-CORRESPONDING ls_proc_step_data         TO ls_proc_step_data_1.
    MOVE-CORRESPONDING ls_proc_step_data_src_add TO ls_proc_step_data_2.
    TRY.
        ls_proc_step_data-mtd_code_result = /adesso/cl_mdc_utility=>compare_proc_step_data( is_proc_step_data_1 = ls_proc_step_data_1 is_proc_step_data_2 = ls_proc_step_data_2 ).
      CATCH /idxgc/cx_general INTO gr_previous.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.
    LOOP AT ls_proc_step_data-mtd_code_result ASSIGNING <fs_mtd_code_result>.
      IF <fs_mtd_code_result>-src_field_value = <fs_mtd_code_result>-cmp_field_value.
        DELETE ls_proc_step_data-mtd_code_result.
      ENDIF.
    ENDLOOP.
    APPEND /idxgc/if_constants_add=>gc_cr_ok TO et_check_result.

***** Schrittdaten aktualisieren ******************************************************************
    lr_process_data_step->update_process_step_data( is_process_step_data = ls_proc_step_data ).
  ENDMETHOD.


  METHOD UPDATE_COMPARE_RESULT_SELECT.
    DATA: lr_process_data_step      TYPE REF TO /idxgc/if_process_data_step,
          lt_edifact_structur       TYPE /adesso/mdc_t_edifact_str,
          ls_proc_step_data         TYPE /idxgc/s_proc_step_data_all,
          ls_proc_step_data_src_add TYPE /idxgc/s_proc_step_data_all,
          ls_proc_step_data_1       TYPE /idxgc/s_proc_step_data,
          ls_proc_step_data_2       TYPE /idxgc/s_proc_step_data,
          ls_proc_step_key          TYPE /idxgc/s_proc_step_key,
          ls_proc_config            TYPE /idxgc/s_proc_config_all.

    FIELD-SYMBOLS: <fr_process_log>      TYPE REF TO /idxgc/if_process_log,
                   <fr_proc_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
                   <fs_proc_step_config> TYPE /idxgc/s_proc_step_config_all,
                   <fs_mtd_code_result>  TYPE /idxgc/s_mtd_code_details.

    ASSIGN cr_data_log->* TO <fr_process_log>.
    ASSIGN cr_data->* TO <fr_proc_data_extern>.
    lr_process_data_step ?= <fr_proc_data_extern>.

***** Schrittdaten vom aktuellen Schritt holen ****************************************************
    TRY.
        ls_proc_step_data = lr_process_data_step->get_process_step_data( is_process_step_key ).
      CATCH /idxgc/cx_process_error INTO gr_previous .
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.

***** Schrittdaten vom zusätzlichem Quellschritt holen ********************************************
    TRY.
        /idxgc/cl_cust_access=>/idxgc/if_cust_access~get_process_config( EXPORTING iv_process_id = ls_proc_step_data-proc_id IMPORTING es_process_config = ls_proc_config ).
      CATCH /idxgc/cx_config_error INTO gr_previous.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.

    READ TABLE ls_proc_config-steps ASSIGNING <fs_proc_step_config> WITH KEY proc_step_no = is_process_step_key-proc_step_no.
    IF sy-subrc = 0.
      ls_proc_step_key-proc_id = is_process_step_key-proc_id.
      IF <fs_proc_step_config>-step_no_src_add IS NOT INITIAL.
        ls_proc_step_key-proc_step_no = <fs_proc_step_config>-step_no_src_add.
        TRY.
            ls_proc_step_data_src_add = lr_process_data_step->get_process_step_data( ls_proc_step_key ).
          CATCH /idxgc/cx_process_error INTO gr_previous .
            /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
        ENDTRY.
      ENDIF.
    ENDIF.

***** Methodenlogik *******************************************************************************
    MOVE-CORRESPONDING ls_proc_step_data         TO ls_proc_step_data_1.
    MOVE-CORRESPONDING ls_proc_step_data_src_add TO ls_proc_step_data_2.
    TRY.
        ls_proc_step_data-mtd_code_result = /adesso/cl_mdc_utility=>compare_proc_step_data( is_proc_step_data_1 = ls_proc_step_data_1
          is_proc_step_data_2 = ls_proc_step_data_2 it_mtd_code_result_select = ls_proc_step_data-mtd_code_result ).
      CATCH /idxgc/cx_general INTO gr_previous.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.
    APPEND /idxgc/if_constants_add=>gc_cr_ok TO et_check_result.

***** Schrittdaten aktualisieren ******************************************************************
    lr_process_data_step->update_process_step_data( is_process_step_data = ls_proc_step_data ).
  ENDMETHOD.


  METHOD update_step_data_for_new_pdoc.
    DATA: lr_process_data_step TYPE REF TO /idxgc/if_process_data_step,
          ls_proc_step_data    TYPE /idxgc/s_proc_step_data_all.

    FIELD-SYMBOLS: <fr_process_log>      TYPE REF TO /idxgc/if_process_log,
                   <fr_proc_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
                   <fs_serviceprovider>  TYPE /idxgc/s_servprov_details.

    ASSIGN cr_data_log->* TO <fr_process_log>.
    ASSIGN cr_data->* TO <fr_proc_data_extern>.
    lr_process_data_step ?= <fr_proc_data_extern>.

***** Schrittdaten vom aktuellen Schritt holen ****************************************************
    TRY.
        ls_proc_step_data = lr_process_data_step->get_process_step_data( is_process_step_key ).
      CATCH /idxgc/cx_process_error INTO gr_previous .
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.

***** Methodenlogik *******************************************************************************
    LOOP AT ls_proc_step_data-serviceprovider ASSIGNING <fs_serviceprovider>.
      ls_proc_step_data-assoc_servprov = <fs_serviceprovider>-service_id.
      DELETE ls_proc_step_data-serviceprovider.
      EXIT.
    ENDLOOP.
    IF sy-subrc = 0.
      APPEND /idxgc/if_constants_add=>gc_cr_ok TO et_check_result.
    ELSE.
      APPEND /idxgc/if_constants_add=>gc_cr_error TO et_check_result.
    ENDIF.
  ENDMETHOD.


  METHOD UPDATE_STEP_DATA_FROM_SRC_ADD.
    DATA: lr_process_data_step      TYPE REF TO /idxgc/if_process_data_step,
          lt_mtd_code_result        TYPE /idxgc/t_mtd_code_details,
          ls_proc_step_data         TYPE /idxgc/s_proc_step_data_all,
          ls_proc_step_data_src_add TYPE /idxgc/s_proc_step_data_all,
          ls_proc_step_key          TYPE /idxgc/s_proc_step_key,
          ls_proc_config            TYPE /idxgc/s_proc_config_all.

    FIELD-SYMBOLS: <fr_process_log>      TYPE REF TO /idxgc/if_process_log,
                   <fr_proc_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
                   <fs_proc_step_config> TYPE /idxgc/s_proc_step_config_all.

    ASSIGN cr_data_log->* TO <fr_process_log>.
    ASSIGN cr_data->* TO <fr_proc_data_extern>.
    lr_process_data_step ?= <fr_proc_data_extern>.

***** Schrittdaten vom aktuellen Schritt holen ****************************************************
    TRY.
        ls_proc_step_data = lr_process_data_step->get_process_step_data( is_process_step_key ).
      CATCH /idxgc/cx_process_error INTO gr_previous .
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.

***** Schrittdaten vom zusätzlichem Quellschritt holen ********************************************
    TRY.
        /idxgc/cl_cust_access=>/idxgc/if_cust_access~get_process_config( EXPORTING iv_process_id = ls_proc_step_data-proc_id IMPORTING es_process_config = ls_proc_config ).
      CATCH /idxgc/cx_config_error INTO gr_previous.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.

    READ TABLE ls_proc_config-steps ASSIGNING <fs_proc_step_config> WITH KEY proc_step_no = is_process_step_key-proc_step_no.
    IF sy-subrc = 0.
      ls_proc_step_key-proc_id  = is_process_step_key-proc_id.
      IF <fs_proc_step_config>-step_no_src_add IS NOT INITIAL.
        ls_proc_step_key-proc_step_no = <fs_proc_step_config>-step_no_src_add.
        TRY.
            ls_proc_step_data_src_add = lr_process_data_step->get_process_step_data( ls_proc_step_key ).
          CATCH /idxgc/cx_process_error INTO gr_previous .
            /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
        ENDTRY.
      ENDIF.
    ENDIF.

***** Methodenlogik *******************************************************************************
    lt_mtd_code_result = ls_proc_step_data-mtd_code_result.
    CLEAR ls_proc_step_data.
    MOVE-CORRESPONDING ls_proc_step_data_src_add to ls_proc_step_data.
    ls_proc_step_data-mtd_code_result = lt_mtd_code_result.

***** Schrittdaten aktualisieren ******************************************************************
    lr_process_data_step->update_process_step_data( is_process_step_data = ls_proc_step_data ).
  ENDMETHOD.


  METHOD update_step_data_from_system.
    DATA: lr_process_data_step      TYPE REF TO /idxgc/if_process_data_step,
          lr_badi_datapro           TYPE REF TO /idxgc/badi_data_provision,
          lt_pod                    TYPE /idxgc/t_pod_info_details,
          ls_proc_data              TYPE /idxgc/s_proc_data,
          ls_proc_step_data         TYPE /idxgc/s_proc_step_data_all,
          ls_proc_step_data_src_add TYPE /idxgc/s_proc_step_data_all,
          ls_proc_step_data_src_dp  TYPE /idxgc/s_proc_step_data_all,
          ls_proc_step_key          TYPE /idxgc/s_proc_step_key,
          ls_proc_config            TYPE /idxgc/s_proc_config_all,
          ls_bmid                   TYPE /idxgc/bmid,
          lr_dp_out                 TYPE REF TO /idxgc/if_dp_out,
          ls_bmid_var               TYPE /idxgc/bmid_var.

    FIELD-SYMBOLS: <fr_process_log>      TYPE REF TO /idxgc/if_process_log,
                   <fr_proc_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
                   <fs_proc_step_config> TYPE /idxgc/s_proc_step_config_all,
                   <fs_proc_step_data>   TYPE /idxgc/s_proc_step_data,
                   <fs_diverse>          TYPE /idxgc/s_diverse_details,
                   <fs_diverse_src_add>  TYPE /idxgc/s_diverse_details,
                   <fs_diverse_src_dp>   TYPE /idxgc/s_diverse_details,
                   <fs_check>            TYPE /idxgc/s_check_details,
                   <fs_msgrespstatus>    TYPE /idxgc/s_msgsts_details.

    ASSIGN cr_data_log->* TO <fr_process_log>.
    ASSIGN cr_data->* TO <fr_proc_data_extern>.
    lr_process_data_step ?= <fr_proc_data_extern>.

***** Schrittdaten vom aktuellen Schritt holen ****************************************************
    TRY.
        ls_proc_step_data = lr_process_data_step->get_process_step_data( is_process_step_key ).
      CATCH /idxgc/cx_process_error INTO gr_previous .
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.

***** Schrittdaten vom zusätzlichem Quellschritt holen ********************************************
    TRY.
        /idxgc/cl_cust_access=>/idxgc/if_cust_access~get_process_config( EXPORTING iv_process_id = ls_proc_step_data-proc_id IMPORTING es_process_config = ls_proc_config ).
      CATCH /idxgc/cx_config_error INTO gr_previous.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.

    READ TABLE ls_proc_config-steps ASSIGNING <fs_proc_step_config> WITH KEY proc_step_no = is_process_step_key-proc_step_no.
    IF sy-subrc = 0.
      ls_proc_step_key-proc_id  = is_process_step_key-proc_id.
      IF <fs_proc_step_config>-step_no_src_add IS NOT INITIAL.
        ls_proc_step_key-proc_step_no = <fs_proc_step_config>-step_no_src_add.
        TRY.
            ls_proc_step_data_src_add = lr_process_data_step->get_process_step_data( ls_proc_step_key ).
          CATCH /idxgc/cx_process_error INTO gr_previous .
            /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
        ENDTRY.
      ENDIF.
    ENDIF.

***** Methodenlogik *******************************************************************************
*---- Datenbereitstellungsklasse und BMID Customizing holen ---------------------------------------
    TRY.
        CALL METHOD /idxgc/cl_cust_access=>/idxgc/if_cust_access_add~get_bmid_msg_config
          EXPORTING
            iv_bmid       = ls_proc_step_data_src_add-bmid
            iv_valid_from = ls_proc_step_data_src_add-msg_date
          IMPORTING
            es_bmid_var   = ls_bmid_var.
        CALL METHOD /idxgc/cl_cust_access=>/idxgc/if_cust_access_add~get_bmid_details
          EXPORTING
            iv_bmid = ls_proc_step_data_src_add-bmid
          IMPORTING
            es_bmid = ls_bmid.
      CATCH /idxgc/cx_config_error INTO gr_previous.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.

*---- Daten vorbereiten ---------------------------------------------------------------------------
    ls_proc_step_data_src_dp-hdr_attr = ls_proc_step_data_src_add-hdr_attr.
    ls_proc_step_data_src_dp-bmid     = ls_proc_step_data_src_add-bmid.
    ls_proc_step_data_src_dp-ext_ui   = ls_proc_step_data_src_add-ext_ui.
    "Bei Anfragen: Nur MTD_CODE_RESULT und einige Zusatzfelder
    IF ls_bmid-dexbasicproc = /idxgc/if_constants_ide=>gc_basicproc_e_utilreq.
      READ TABLE ls_proc_step_data_src_add-diverse ASSIGNING <fs_diverse_src_add> INDEX 1.
      IF sy-subrc = 0.
        APPEND INITIAL LINE TO ls_proc_step_data_src_dp-diverse ASSIGNING <fs_diverse_src_dp>.
        <fs_diverse_src_dp>-item_id          = <fs_diverse_src_add>-item_id.
        <fs_diverse_src_dp>-transaction_no   = <fs_diverse_src_add>-transaction_no.
        <fs_diverse_src_dp>-msgtransreason   = <fs_diverse_src_add>-msgtransreason.
        <fs_diverse_src_dp>-contr_start_date = <fs_diverse_src_add>-contr_start_date.
        <fs_diverse_src_dp>-validstart_date  = <fs_diverse_src_add>-validstart_date.
      ENDIF.
      APPEND LINES OF ls_proc_step_data-mtd_code_result TO ls_proc_step_data_src_dp-mtd_code_result.
      "Bei Antworten: Alle Daten aus Anfrage
    ELSEIF ls_bmid-dexbasicproc           = /idxgc/if_constants_ide=>gc_basicproc_e_utilres.
      ls_proc_step_data_src_dp-non_meter_dev     = ls_proc_step_data_src_add-non_meter_dev.
      ls_proc_step_data_src_dp-charges           = ls_proc_step_data_src_add-charges.
      ls_proc_step_data_src_dp-diverse           = ls_proc_step_data_src_add-diverse.
      ls_proc_step_data_src_dp-name_address      = ls_proc_step_data_src_add-name_address.
      ls_proc_step_data_src_dp-meter_dev         = ls_proc_step_data_src_add-meter_dev.
      ls_proc_step_data_src_dp-time_series       = ls_proc_step_data_src_add-time_series.
      ls_proc_step_data_src_dp-marketpartner_add = ls_proc_step_data_src_add-marketpartner_add.
      ls_proc_step_data_src_dp-settl_terr        = ls_proc_step_data_src_add-settl_terr.
      ls_proc_step_data_src_dp-pod               = ls_proc_step_data_src_add-pod.
      ls_proc_step_data_src_dp-reg_code_data     = ls_proc_step_data_src_add-reg_code_data.
      ls_proc_step_data_src_dp-settl_unit        = ls_proc_step_data_src_add-settl_unit.
      ls_proc_step_data_src_dp-pod_quant         = ls_proc_step_data_src_add-pod_quant.
      ls_proc_step_data_src_dp-msgcomments       = ls_proc_step_data_src_add-msgcomments.
      APPEND INITIAL LINE TO ls_proc_step_data_src_dp-check ASSIGNING <fs_check>.
      <fs_check>-exec_flag = abap_true.
      READ TABLE ls_proc_step_data_src_add-msgrespstatus ASSIGNING <fs_msgrespstatus> INDEX 1.
      IF sy-subrc = 0.
        <fs_check>-rejection_code = <fs_msgrespstatus>-respstatus.
      ELSE.
        <fs_check>-rejection_code = /idxgc/if_constants_add=>gc_response_code_zg2.
      ENDIF.
    ENDIF.

    CLEAR: ls_proc_step_data-non_meter_dev,     ls_proc_step_data-charges,    ls_proc_step_data-diverse,
           ls_proc_step_data-name_address,      ls_proc_step_data-meter_dev,  ls_proc_step_data-time_series,
           ls_proc_step_data-marketpartner_add, ls_proc_step_data-settl_terr, ls_proc_step_data-pod,
           ls_proc_step_data-reg_code_data,     ls_proc_step_data-settl_unit, ls_proc_step_data-pod_quant.
    ls_proc_step_data-bmid           = ls_proc_step_data_src_add-bmid.
    ls_proc_step_data-dexbasicproc   = ls_bmid-dexbasicproc.
    ls_proc_step_data-assoc_servprov = ls_proc_step_data_src_add-assoc_servprov.
    ls_proc_step_data-own_servprov   = ls_proc_step_data_src_add-own_servprov.

*---- Datenbereitstellung aufrufen ----------------------------------------------------------------
    CREATE OBJECT lr_dp_out
      TYPE
        (ls_bmid_var-data_prov_class)
      EXPORTING
        is_process_data_src = ls_proc_step_data_src_dp.
    TRY.
        lr_dp_out->process_data_provision( CHANGING cs_process_step_data = ls_proc_step_data ).
      CATCH /idxgc/cx_process_error INTO gr_previous.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.
    APPEND /idxgc/if_constants_add=>gc_cr_ok TO et_check_result.

*---- Daten ändern für Anzeige im Programm und spätere Verarbeitung -------------------------------
    "Daten löschen, die nicht relevant sind und im Prozessschritt stören
    CLEAR: ls_proc_step_data-amid, ls_proc_step_data-marketpartner, ls_proc_step_data-dexbasicproc.
    "Transaktionsnummer aus der Anfrage hier übernehmen für die Antwort.
    READ TABLE ls_proc_step_data-diverse ASSIGNING <fs_diverse> INDEX 1.
    IF sy-subrc = 0 AND <fs_diverse_src_add> IS ASSIGNED.
      <fs_diverse>-transaction_no = <fs_diverse_src_add>-transaction_no.
    ENDIF.

***** Schrittdaten aktualisieren ******************************************************************
    lr_process_data_step->update_process_step_data( is_process_step_data = ls_proc_step_data ).
  ENDMETHOD.


  METHOD update_system_from_message.
    DATA: lr_process_data_step  TYPE REF TO /idxgc/if_process_data_step,
          lr_badi_ref           TYPE REF TO cl_badi_base,
          lt_badi_name          TYPE TABLE OF badi_name,
          ls_proc_step_data     TYPE /idxgc/s_proc_step_data_all,
          ls_proc_step_data_src TYPE /idxgc/s_proc_step_data_all,
          ls_cust_in            TYPE /adesso/mdc_s_in,
          ls_proc_step_key      TYPE /idxgc/s_proc_step_key,
          ls_proc_config        TYPE /idxgc/s_proc_config_all,
          lv_edifact_structur   TYPE /idxgc/de_edifact_str.

    FIELD-SYMBOLS: <fr_process_log>      TYPE REF TO /idxgc/if_process_log,
                   <fr_proc_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
                   <fs_proc_step_config> TYPE /idxgc/s_proc_step_config_all,
                   <fs_mtd_code_result>  TYPE /idxgc/s_mtd_code_details,
                   <fv_badi_name>        TYPE badi_name.

    ASSIGN cr_data_log->* TO <fr_process_log>.
    ASSIGN cr_data->* TO <fr_proc_data_extern>.
    lr_process_data_step ?= <fr_proc_data_extern>.

***** Schrittdaten vom aktuellen Schritt holen ****************************************************
    TRY.
        ls_proc_step_data = lr_process_data_step->get_process_step_data( is_process_step_key ).
      CATCH /idxgc/cx_process_error INTO gr_previous .
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.

***** Schrittdaten vom zusätzlichem Quellschritt holen ********************************************
    TRY.
        /idxgc/cl_cust_access=>/idxgc/if_cust_access~get_process_config( EXPORTING iv_process_id = ls_proc_step_data-proc_id IMPORTING es_process_config = ls_proc_config ).
      CATCH /idxgc/cx_config_error INTO gr_previous.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.

    READ TABLE ls_proc_config-steps ASSIGNING <fs_proc_step_config> WITH KEY proc_step_no = is_process_step_key-proc_step_no.
    IF sy-subrc = 0.
      ls_proc_step_key-proc_id = is_process_step_key-proc_id.
      IF <fs_proc_step_config>-proc_step_src IS NOT INITIAL.
        ls_proc_step_key-proc_step_no = <fs_proc_step_config>-proc_step_src.
        TRY.
            ls_proc_step_data_src = lr_process_data_step->get_process_step_data( ls_proc_step_key ).
          CATCH /idxgc/cx_process_error INTO gr_previous .
            /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
        ENDTRY.
      ENDIF.
    ENDIF.

***** Methodenlogik *******************************************************************************
*---- Änderungs-BAdIs ermitteln -------------------------------------------------------------------
    LOOP AT ls_proc_step_data-mtd_code_result ASSIGNING <fs_mtd_code_result>.
      lv_edifact_structur = <fs_mtd_code_result>-addinfo.
      TRY.
          ls_cust_in = /adesso/cl_mdc_customizing=>get_inbound_config_for_edifact( iv_edifact_structur = lv_edifact_structur iv_assoc_servprov = ls_proc_step_data-assoc_servprov ).
        CATCH /idxgc/cx_general INTO gr_previous.
          sy-msgty = /idxgc/if_constants=>gc_message_type_warning.
          <fr_process_log>->add_message_to_process_log( ).
          MESSAGE w050(/adesso/mdc_process) INTO gv_mtext.
          <fr_process_log>->add_message_to_process_log( ).
      ENDTRY.
      IF ls_cust_in-badi_name IS NOT INITIAL.
        APPEND ls_cust_in-badi_name TO lt_badi_name.
      ENDIF.
    ENDLOOP.

    SORT lt_badi_name.
    DELETE ADJACENT DUPLICATES FROM lt_badi_name.

*---- Änderungs-Methoden ausführen ----------------------------------------------------------------
    LOOP AT lt_badi_name ASSIGNING <fv_badi_name>.
      TRY.
          GET BADI lr_badi_ref TYPE (<fv_badi_name>)
            FILTERS mandt = sy-mandt.
          CALL BADI lr_badi_ref->('CHANGE_AUTO')
            EXPORTING
              is_proc_step_data     = ls_proc_step_data
              is_proc_step_data_src = ls_proc_step_data_src.
        CATCH cx_root INTO gr_previous.
          "Bei Fehlern wird später eine manuelle Bearbeitung ausgelöst
          <fr_process_log>->add_message_to_process_log( ).
      ENDTRY.
    ENDLOOP.

    APPEND /idxgc/if_constants_add=>gc_cr_ok TO et_check_result.
  ENDMETHOD.
ENDCLASS.
