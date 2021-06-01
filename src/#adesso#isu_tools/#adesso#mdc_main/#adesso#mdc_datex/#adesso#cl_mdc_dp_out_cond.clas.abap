class /ADESSO/CL_MDC_DP_OUT_COND definition
  public
  final
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !IS_PROCESS_DATA_SRC type /IDXGC/S_PROC_STEP_DATA_ALL
      !IS_PROCESS_DATA_SRC_ADD type /IDXGC/S_PROC_STEP_DATA_ALL
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods EVALUATE_CONDITION
    importing
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR optional
      !IV_DP_CONDITION type /ADESSO/MDC_DP_CONDITION optional
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
protected section.

  data GS_PROCESS_DATA_SRC type /IDXGC/S_PROC_STEP_DATA_ALL .
  data GS_PROCESS_DATA_SRC_ADD type /IDXGC/S_PROC_STEP_DATA_ALL .
  data GV_AMID type /IDXGC/DE_AMID .
  data GV_METER_PROC type /IDXGC/DE_METER_PROC .
  data GV_MTEXT type STRING .

  methods CHECK_SINGLE_DP_CONDITION
    importing
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR optional
      !IV_DP_CONDITION_NO type /ADESSO/MDC_DP_CONDITION_NO
      !IV_KEYDATE type /IDXGC/DE_KEYDATE default SY-DATUM
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_004_MARKETPARTNER
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_005_MARKETPARTNER
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_019_METER_PROC
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_020_SUPPLY_DIRECT
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_021_METER_PROC
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_024_NEXTMR_PERIOD
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_046_MARKETPARTNER
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_059_MARKETPARTNER
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_086_METER_PROC
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_089_METER_PROC
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_090_METER_PROC
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_092_MTD_CODE_RESULT
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_101_METER_PROC
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_106_METER_PROC
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_119_METER_PROC
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_128_FRANCHISE_FEE
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_135_MARKETPARTNER
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_139_METER_DATA
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_144_TAX_INFO
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_171_FRANCHISE_FEE
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_173_METER_PROC
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_174_METER_PROC
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_175_METER_PROC
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_177_METER_PROC
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_178_METER_PROC
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_179_METER_PROC
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_181_METER_PROC
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_186_METER_PROC
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_188_METER_PROC
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_189_METER_PROC
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_201_POD_INFO
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_202_RESPSTATUS
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_204_REG_CODE_DATA
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_205_POD_QUANT
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_207_CONS_DISTR_EXT
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_209_POD_INFO
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_210_POD_INFO
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_A01_MTD_CODE_RESULT
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_B10_MP_METER_PROC
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_B14_REQUEST_MESSAGE
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CHECK_MTD_CODE_RESULT
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_DP_CHECK_RESULT) type /ADESSO/MDC_DP_CHECK_RESULT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods GET_METER_PROC
    importing
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_METER_PROC) type /IDXGC/DE_METER_PROC
    raising
      /IDXGC/CX_PROCESS_ERROR .
private section.
ENDCLASS.



CLASS /ADESSO/CL_MDC_DP_OUT_COND IMPLEMENTATION.


  METHOD check_004_marketpartner.
***************************************************************************************************
* adesso SDÄ mit Common Layer Engine
*   Bedingung: Wenn MP-ID in SG2 NAD+MR in der Rolle LF
* THIMEL.R, 20160322, Wenn die Daten zum Vergleich gelesen werden, dann sind Sender und Empfänger
*   vertauscht. Daher muss hier der Sender gelesen werden, damit die Bedingung richtig ermittelt
*   wird.
***************************************************************************************************
    DATA: lr_previous            TYPE REF TO cx_root,
          ls_process_step_id     TYPE /idxgc/s_proc_step_id,
          ls_process_step_config TYPE /idxgc/s_proc_step_config_all,
          lv_party_func_qual     TYPE /idxgc/de_party_func_qual.
    FIELD-SYMBOLS: <fs_marketpartner> TYPE /idxgc/s_markpar_details.

    ls_process_step_id-proc_id      = is_process_step_data-proc_id.
    ls_process_step_id-proc_step_no = is_process_step_data-proc_step_no.
    ls_process_step_id-proc_version = is_process_step_data-proc_version.

    TRY.
        CALL METHOD /idxgc/cl_cust_access=>/idxgc/if_cust_access~get_process_step_config
          EXPORTING
            is_process_step_id     = ls_process_step_id
            iv_sucessors           = abap_false
            iv_predecessors        = abap_false
          RECEIVING
            rs_process_step_config = ls_process_step_config.
      CATCH /idxgc/cx_config_error.
        CLEAR ls_process_step_config.
    ENDTRY.

    IF ls_process_step_config-type = /idxgc/if_constants=>gc_proc_step_typ_outbound OR ls_process_step_config-type IS INITIAL.
      lv_party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_mr.
    ELSE.
      lv_party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_ms.
    ENDIF.

    LOOP AT is_process_step_data-marketpartner ASSIGNING <fs_marketpartner> WHERE party_func_qual = lv_party_func_qual.
      TRY.
          IF /adesso/cl_mdc_utility=>get_intcode_servprov( iv_serviceid = <fs_marketpartner>-serviceid ) = /idxgc/if_constants_ide=>gc_service_cat_sup.
            rv_dp_check_result  = abap_true.
          ELSE.
            rv_dp_check_result  = abap_false.
          ENDIF.
        CATCH /idxgc/cx_general INTO lr_previous.
          /idxgc/cx_process_error=>raise_proc_exception_from_msg( ir_previous = lr_previous ).
      ENDTRY.
    ENDLOOP.
    IF sy-subrc <> 0.
      MESSAGE e110(/adesso/mdc_process) INTO gv_mtext.
      /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD check_005_marketpartner.
***************************************************************************************************
* adesso SDÄ mit Common Layer Engine
*   Bedingung: Wenn MP-ID in SG2 NAD+MS in der Rolle LF
* THIMEL.R, 20160322, Wenn die Daten zum Vergleich gelesen werden, dann sind Sender und Empfänger
*   vertauscht. Daher muss hier der Sender gelesen werden, damit die Bedingung richtig ermittelt
*   wird.
***************************************************************************************************
    DATA: lr_previous            TYPE REF TO cx_root,
          ls_process_step_id     TYPE /idxgc/s_proc_step_id,
          ls_process_step_config TYPE /idxgc/s_proc_step_config_all,
          lv_party_func_qual     TYPE /idxgc/de_party_func_qual.
    FIELD-SYMBOLS: <fs_marketpartner> TYPE /idxgc/s_markpar_details.

    ls_process_step_id-proc_id      = is_process_step_data-proc_id.
    ls_process_step_id-proc_step_no = is_process_step_data-proc_step_no.
    ls_process_step_id-proc_version = is_process_step_data-proc_version.

    TRY.
        CALL METHOD /idxgc/cl_cust_access=>/idxgc/if_cust_access~get_process_step_config
          EXPORTING
            is_process_step_id     = ls_process_step_id
            iv_sucessors           = abap_false
            iv_predecessors        = abap_false
          RECEIVING
            rs_process_step_config = ls_process_step_config.
      CATCH /idxgc/cx_config_error.
        CLEAR ls_process_step_config.
    ENDTRY.

    IF ls_process_step_config-type = /idxgc/if_constants=>gc_proc_step_typ_outbound OR ls_process_step_config-type IS INITIAL.
      lv_party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_ms.
    ELSE.
      lv_party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_mr.
    ENDIF.

    LOOP AT is_process_step_data-marketpartner ASSIGNING <fs_marketpartner> WHERE party_func_qual = lv_party_func_qual.
      TRY.
          IF /adesso/cl_mdc_utility=>get_intcode_servprov( iv_serviceid = <fs_marketpartner>-serviceid ) = /idxgc/if_constants_ide=>gc_service_cat_sup.
            rv_dp_check_result  = abap_true.
          ELSE.
            rv_dp_check_result  = abap_false.
          ENDIF.
        CATCH /idxgc/cx_general INTO lr_previous.
          /idxgc/cx_process_error=>raise_proc_exception_from_msg( ir_previous = lr_previous ).
      ENDTRY.
    ENDLOOP.
    IF sy-subrc <> 0.
      MESSAGE e110(/adesso/mdc_process) INTO gv_mtext.
      /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD check_019_meter_proc.
***************************************************************************************************
* adesso SDÄ mit Common Layer Engine
*   Bedingung: Wenn SG7 CCI+++E02 CAV+E01 vorhanden
***************************************************************************************************
    DATA: lv_meter_proc TYPE /idxgc/de_meter_proc.

    lv_meter_proc = get_meter_proc( is_process_step_data = is_process_step_data ).

    IF lv_meter_proc = /idxgc/if_check_method_add=>gc_meter_proc_e01.
      rv_dp_check_result  = abap_true.
    ELSE.
      rv_dp_check_result  = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD check_020_supply_direct.
***************************************************************************************************
* adesso SDÄ mit Common Layer Engine
*   Bedingung: Wenn SG4 IMD++Z14+Z07 vorhanden
***************************************************************************************************
    FIELD-SYMBOLS: <fs_diverse> TYPE  /idxgc/s_diverse_details.

    READ TABLE is_process_step_data-diverse INDEX 1 ASSIGNING <fs_diverse>.
    IF <fs_diverse> IS ASSIGNED AND <fs_diverse>-supply_direct IS NOT INITIAL.
      IF <fs_diverse>-supply_direct = /idxgc/if_constants_add=>gc_supply_direct_z07.
        rv_dp_check_result  = abap_true.
      ELSE.
        rv_dp_check_result = abap_false.
      ENDIF.
    ELSE.
      MESSAGE e022(/adesso/mdc_process) INTO gv_mtext.
      /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD check_021_meter_proc.
***************************************************************************************************
* adesso SDÄ mit Common Layer Engine
*   Bedingung: Wenn SG7 CCI+++E02 CAV+E02/ E14/ E24/ Z29 vorhanden
***************************************************************************************************
    DATA: lv_meter_proc TYPE /idxgc/de_meter_proc.

    lv_meter_proc = get_meter_proc( is_process_step_data = is_process_step_data ).

    IF lv_meter_proc = /idxgc/if_constants_add=>gc_meter_proc_e02 OR
       lv_meter_proc = /idxgc/if_constants_add=>gc_meter_proc_e14 OR
       lv_meter_proc = /idxgc/if_constants_add=>gc_meter_proc_e24 OR
       lv_meter_proc = /idxgc/if_constants_add=>gc_meter_proc_z29.
      rv_dp_check_result  = abap_true.
    ELSE.
      rv_dp_check_result  = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD check_024_nextmr_period.
***************************************************************************************************
* adesso SDÄ mit Common Layer Engine
*   Bedingung: Wenn SG4 DTM+752 vorhanden
***************************************************************************************************
    FIELD-SYMBOLS: <fs_diverse> TYPE  /idxgc/s_diverse_details.

    READ TABLE is_process_step_data-diverse INDEX 1 ASSIGNING <fs_diverse>.
    IF <fs_diverse> IS ASSIGNED.
      IF <fs_diverse>-nextmr_date IS NOT INITIAL.
        rv_dp_check_result  = abap_true.
      ELSE.
        rv_dp_check_result = abap_false.
      ENDIF.
    ELSE.
      MESSAGE e023(/adesso/mdc_process) INTO gv_mtext.
      /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD check_046_marketpartner.
***************************************************************************************************
* adesso SDÄ mit Common Layer Engine
*   Bedingung: Wenn MP-ID in SG2 NAD+MR aus Sparte Gas
***************************************************************************************************
    DATA: ls_process_step_id     TYPE /idxgc/s_proc_step_id,
          ls_process_step_config TYPE /idxgc/s_proc_step_config_all,
          lv_party_func_qual     TYPE /idxgc/de_party_func_qual,
          lv_service             TYPE sercode,
          lv_division            TYPE sparte,
          lv_spartyp             TYPE spartyp.
    FIELD-SYMBOLS: <fs_marketpartner> TYPE /idxgc/s_markpar_details.

    ls_process_step_id-proc_id      = is_process_step_data-proc_id.
    ls_process_step_id-proc_step_no = is_process_step_data-proc_step_no.
    ls_process_step_id-proc_version = is_process_step_data-proc_version.

    TRY.
        CALL METHOD /idxgc/cl_cust_access=>/idxgc/if_cust_access~get_process_step_config
          EXPORTING
            is_process_step_id     = ls_process_step_id
            iv_sucessors           = abap_false
            iv_predecessors        = abap_false
          RECEIVING
            rs_process_step_config = ls_process_step_config.
      CATCH /idxgc/cx_config_error.
        CLEAR ls_process_step_config.
    ENDTRY.

    IF ls_process_step_config-type = /idxgc/if_constants=>gc_proc_step_typ_outbound OR ls_process_step_config-type IS INITIAL.
      lv_party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_mr.
    ELSE.
      lv_party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_ms.
    ENDIF.

    LOOP AT is_process_step_data-marketpartner ASSIGNING <fs_marketpartner> WHERE party_func_qual = lv_party_func_qual.
      SELECT SINGLE service FROM eservprov INTO lv_service WHERE serviceid = <fs_marketpartner>-serviceid.
      SELECT SINGLE division FROM tecde INTO lv_division WHERE service = lv_service.
      SELECT SINGLE spartyp FROM tespt INTO lv_spartyp WHERE sparte = lv_division.
      IF lv_division IS INITIAL.
        MESSAGE e111(/adesso/mdc_process) INTO gv_mtext.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
      ELSEIF lv_spartyp = /adesso/if_mdc_co=>gc_spartyp_02.
        rv_dp_check_result  = abap_true.
      ELSE.
        rv_dp_check_result  = abap_false.
      ENDIF.
    ENDLOOP.
    IF sy-subrc <> 0.
      MESSAGE e110(/adesso/mdc_process) INTO gv_mtext.
      /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD check_059_marketpartner.
***************************************************************************************************
* adesso SDÄ mit Common Layer Engine
*   Bedingung: Wenn MP-ID in SG2 NAD+MR aus Sparte Strom
***************************************************************************************************
    DATA: lv_service  TYPE sercode,
          lv_division TYPE sparte,
          lv_spartyp  TYPE spartyp.

    FIELD-SYMBOLS: <fs_marketpartner> TYPE /idxgc/s_markpar_details.

    LOOP AT is_process_step_data-marketpartner ASSIGNING <fs_marketpartner> WHERE party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_mr.
      SELECT SINGLE service FROM eservprov INTO lv_service WHERE serviceid = <fs_marketpartner>-serviceid.
      SELECT SINGLE division FROM tecde INTO lv_division WHERE service = lv_service.
      SELECT SINGLE spartyp FROM tespt INTO lv_spartyp WHERE sparte = lv_division.
      IF lv_division IS INITIAL.
        MESSAGE e111(/adesso/mdc_process) INTO gv_mtext.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
      ELSEIF lv_spartyp = /adesso/if_mdc_co=>gc_spartyp_01.
        rv_dp_check_result  = abap_true.
      ELSE.
        rv_dp_check_result  = abap_false.
      ENDIF.

    ENDLOOP.
    IF sy-subrc <> 0.
      MESSAGE e110(/adesso/mdc_process) INTO gv_mtext.
      /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD check_086_meter_proc.
***************************************************************************************************
* adesso SDÄ mit Common Layer Engine
*   Bedingung: Wenn SG7 CCI+++E02 CAV+E01 nicht vorhanden
***************************************************************************************************
    DATA: lv_meter_proc TYPE /idxgc/de_meter_proc.

    lv_meter_proc = get_meter_proc( is_process_step_data = is_process_step_data ).

    IF lv_meter_proc <> /idxgc/if_check_method_add=>gc_meter_proc_e01.
      rv_dp_check_result  = abap_true.
    ELSE.
      rv_dp_check_result  = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD check_089_meter_proc.
***************************************************************************************************
* adesso SDÄ mit Common Layer Engine
*   Bedingung: Wenn SG7 CCI+++E02 CAV+E14/ E24 vorhanden
***************************************************************************************************
    DATA: lv_meter_proc TYPE /idxgc/de_meter_proc.

    lv_meter_proc = get_meter_proc( is_process_step_data = is_process_step_data ).

    IF lv_meter_proc = /idxgc/if_constants_add=>gc_meter_proc_e14 OR
       lv_meter_proc = /idxgc/if_constants_add=>gc_meter_proc_e24.
      rv_dp_check_result  = abap_true.
    ELSE.
      rv_dp_check_result = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD check_090_meter_proc.
***************************************************************************************************
* adesso SDÄ mit Common Layer Engine
*   Bedingung: Wenn SG7 CCI+++E02 CAV+E24 vorhanden
***************************************************************************************************
    DATA: lv_meter_proc TYPE /idxgc/de_meter_proc.

    lv_meter_proc = get_meter_proc( is_process_step_data = is_process_step_data ).

    IF lv_meter_proc = /idxgc/if_constants_add=>gc_meter_proc_e24.
      rv_dp_check_result  = abap_true.
    ELSE.
      rv_dp_check_result  = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD check_092_mtd_code_result.
***************************************************************************************************
* adesso SDÄ mit Common Layer Engine
*   Bedingung: Wenn Wert geändert wird
***************************************************************************************************
    rv_dp_check_result = me->check_mtd_code_result( iv_edifact_structur = iv_edifact_structur is_process_step_data = is_process_step_data ).
  ENDMETHOD.


  METHOD check_101_meter_proc.
***************************************************************************************************
* adesso SDÄ mit Common Layer Engine
*   Bedingung: Wenn SG7 CCI+++E02 CAV+E14/E24/Z36 vorhanden
***************************************************************************************************
    DATA: lv_meter_proc TYPE /idxgc/de_meter_proc.

    lv_meter_proc = get_meter_proc( is_process_step_data = is_process_step_data ).

    IF lv_meter_proc = /idxgc/if_constants_add=>gc_meter_proc_e14 OR
       lv_meter_proc = /idxgc/if_constants_add=>gc_meter_proc_e24 OR
       lv_meter_proc = /idxgc/if_constants_add=>gc_meter_proc_z36.
      rv_dp_check_result = abap_true.
    ELSE.
      rv_dp_check_result  = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD check_106_meter_proc.
***************************************************************************************************
* adesso SDÄ mit Common Layer Engine
*   Bedingung: Wenn SG7 CCI+++E02 CAV+E02/E24/Z29 vorhanden
***************************************************************************************************
    DATA: lv_meter_proc TYPE /idxgc/de_meter_proc.

    lv_meter_proc = get_meter_proc( is_process_step_data = is_process_step_data ).

    IF lv_meter_proc = /idxgc/if_constants_add=>gc_meter_proc_e02 OR
       lv_meter_proc = /idxgc/if_constants_add=>gc_meter_proc_e24 OR
       lv_meter_proc = /idxgc/if_constants_add=>gc_meter_proc_z29.
      rv_dp_check_result  = abap_true.
    ELSE.
      rv_dp_check_result  = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD check_119_meter_proc.
***************************************************************************************************
* adesso SDÄ mit Common Layer Engine
*   Bedingung: Wenn SG7 CCI+++E02 CAV+Z29 nicht vorhanden
***************************************************************************************************
    DATA: lv_meter_proc TYPE /idxgc/de_meter_proc.

    lv_meter_proc = get_meter_proc( is_process_step_data = is_process_step_data ).

    IF lv_meter_proc <> /idxgc/if_check_method_add=>gc_meter_proc_z29.
      rv_dp_check_result  = abap_true.
    ELSE.
      rv_dp_check_result  = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD check_128_franchise_fee.
***************************************************************************************************
* adesso SDÄ mit Common Layer Engine
*   Bedingung: Wenn SG10 CAV+TAS/ TSS/ TKS/ SAS/ KAS vorhanden
***************************************************************************************************
    FIELD-SYMBOLS: <fs_charges> TYPE /idxgc/s_charges_details.

    LOOP AT is_process_step_data-charges ASSIGNING <fs_charges> WHERE charge_qual = /idxgc/if_constants_ide=>gc_seq_action_code_z07.
      IF <fs_charges>-franchise_fee = /idxgc/if_constants_ide=>gc_tax_category_tas OR
         <fs_charges>-franchise_fee = /idxgc/if_constants_ide=>gc_tax_category_tss OR
         <fs_charges>-franchise_fee = /idxgc/if_constants_ide=>gc_tax_category_tks OR
         <fs_charges>-franchise_fee = /idxgc/if_constants_ide=>gc_tax_category_sas OR
         <fs_charges>-franchise_fee = /idxgc/if_constants_ide=>gc_tax_category_kas.
        rv_dp_check_result  = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF sy-subrc <> 0.
      MESSAGE e024(/adesso/mdc_process) INTO gv_mtext.
      /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD check_135_marketpartner.
***************************************************************************************************
* adesso SDÄ mit Common Layer Engine
*   Bedingung: Wenn MP-ID in SG2 NAD+MR in der Rolle MDL
***************************************************************************************************
    DATA: lr_previous TYPE REF TO cx_root,
          lv_intcode  TYPE  /adesso/mdc_intcode.

    FIELD-SYMBOLS: <fs_marketpartner> TYPE /idxgc/s_markpar_details.

    LOOP AT is_process_step_data-marketpartner ASSIGNING <fs_marketpartner> WHERE party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_mr.
      TRY.
          IF /adesso/cl_mdc_utility=>get_intcode_servprov( iv_serviceid = <fs_marketpartner>-serviceid ) = /adesso/if_mdc_co=>gc_intcode_m2.
            rv_dp_check_result  = abap_true.
          ELSE.
            rv_dp_check_result  = abap_false.
          ENDIF.

        CATCH /idxgc/cx_general INTO lr_previous.
          /idxgc/cx_process_error=>raise_proc_exception_from_msg( ir_previous = lr_previous ).
      ENDTRY.
    ENDLOOP.
    IF sy-subrc <> 0.
      MESSAGE e110(/adesso/mdc_process) INTO gv_mtext.
      /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDIF.

  ENDMETHOD.


  METHOD check_139_meter_data.
***************************************************************************************************
* adesso SDÄ mit Common Layer Engine
*   Bedingung: Wenn SG10 CAV+IVA nicht vorhanden
***************************************************************************************************
    FIELD-SYMBOLS: <fs_meter_device> TYPE /idxgc/s_meterdev_details.

    READ TABLE is_process_step_data-meter_dev INDEX 1 ASSIGNING <fs_meter_device>.
    IF <fs_meter_device> IS ASSIGNED.
      IF <fs_meter_device>-metertype_code <> /idxgc/if_constants_ide=>gc_chara_value_code_iva.
        rv_dp_check_result  = abap_true.
      ELSE.
        rv_dp_check_result  = abap_false.
      ENDIF.
    ELSE.
      MESSAGE e025(/adesso/mdc_process) INTO gv_mtext.
      /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD check_144_tax_info.
***************************************************************************************************
* THIMEL.R, 20151008, adesso SDÄ mit Common Layer Engine
*   Bedingung: Wenn SG8 SEQ+Z10 vorhanden
* THIMEL.R, 20160308, Erweiterung zur Abfrage der EDIFACT-Strukturen, da die Schrittdaten evtl.
*   noch nicht gefüllt sind.
* THIMEL.R, 20160322, Erweiterung zur Abfrage der Quellstruktur, da EDIFACT-Struktur und
*   Schrittdaten evtl. noch nicht gefüllt sind.
***************************************************************************************************
    LOOP AT is_process_step_data-charges TRANSPORTING NO FIELDS WHERE charge_qual = /idxgc/if_constants_ide=>gc_seq_action_code_z10.
      rv_dp_check_result  = abap_true.
      RETURN.
    ENDLOOP.

    LOOP AT gs_process_data_src-charges TRANSPORTING NO FIELDS WHERE charge_qual = /idxgc/if_constants_ide=>gc_seq_action_code_z10.
      rv_dp_check_result  = abap_true.
      RETURN.
    ENDLOOP.

    rv_dp_check_result = check_mtd_code_result( iv_edifact_structur = /adesso/if_mdc_co=>gc_edifact_sg8_seq_z10 is_process_step_data = is_process_step_data ).
  ENDMETHOD.


  METHOD check_171_franchise_fee.
***************************************************************************************************
* THIMEL.R, 20151008, adesso SDÄ mit Common Layer Engine
*   Bedingung: Wenn SG8 SEQ+Z07 vorhanden
* THIMEL.R, 20160308, Erweiterung zur Abfrage der EDIFACT-Strukturen, da die Schrittdaten evtl.
*   noch nicht gefüllt sind.
* THIMEL.R, 20160322, Erweiterung zur Abfrage der Quellstruktur, da EDIFACT-Struktur und
*   Schrittdaten evtl. noch nicht gefüllt sind.
***************************************************************************************************
    LOOP AT is_process_step_data-charges TRANSPORTING NO FIELDS WHERE charge_qual = /idxgc/if_constants_ide=>gc_seq_action_code_z07.
      rv_dp_check_result  = abap_true.
      RETURN.
    ENDLOOP.

    LOOP AT gs_process_data_src-charges TRANSPORTING NO FIELDS WHERE charge_qual = /idxgc/if_constants_ide=>gc_seq_action_code_z07.
      rv_dp_check_result  = abap_true.
      RETURN.
    ENDLOOP.

    rv_dp_check_result = check_mtd_code_result( iv_edifact_structur = /adesso/if_mdc_co=>gc_edifact_sg8_seq_z07 is_process_step_data = is_process_step_data ).
  ENDMETHOD.


  METHOD check_173_meter_proc.
***************************************************************************************************
* adesso SDÄ mit Common Layer Engine
*   Bedingung: Wenn SG7 CCI+++Z72 CAV+E14/ E24 vorhanden
***************************************************************************************************
    DATA: lv_meter_proc TYPE /idxgc/de_meter_proc.

    lv_meter_proc = get_meter_proc( is_process_step_data = is_process_step_data ).

    IF lv_meter_proc = /idxgc/if_constants_add=>gc_meter_proc_e14 OR
       lv_meter_proc = /idxgc/if_constants_add=>gc_meter_proc_e24.
      rv_dp_check_result = abap_true.
    ELSE.
      rv_dp_check_result  = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD check_174_meter_proc.
***************************************************************************************************
* adesso SDÄ mit Common Layer Engine
*   Bedingung: Wenn SG7 CCI+++Z72 CAV+E02 vorhanden
***************************************************************************************************
    DATA: lv_meter_proc TYPE /idxgc/de_meter_proc.

    lv_meter_proc = get_meter_proc( is_process_step_data = is_process_step_data ).

    IF lv_meter_proc = /idxgc/if_constants_add=>gc_meter_proc_e02.
      rv_dp_check_result = abap_true.
    ELSE.
      rv_dp_check_result  = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD check_175_meter_proc.
***************************************************************************************************
* adesso SDÄ mit Common Layer Engine
*   Bedingung: Wenn SG7 CCI+++Z72 CAV+E01 nicht vorhanden
***************************************************************************************************
    DATA: lv_meter_proc TYPE /idxgc/de_meter_proc.

    lv_meter_proc = get_meter_proc( is_process_step_data = is_process_step_data ).

    IF lv_meter_proc <> /idxgc/if_constants_add=>gc_meter_proc_e01.
      rv_dp_check_result = abap_true.
    ELSE.
      rv_dp_check_result  = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD check_177_meter_proc.
***************************************************************************************************
* adesso SDÄ mit Common Layer Engine
*   Bedingung: Wenn SG7 CCI+++Z72 CAV+E24 vorhanden
***************************************************************************************************
    DATA: lv_meter_proc TYPE /idxgc/de_meter_proc.

    lv_meter_proc = get_meter_proc( is_process_step_data = is_process_step_data ).

    IF lv_meter_proc = /idxgc/if_constants_add=>gc_meter_proc_e24.
      rv_dp_check_result = abap_true.
    ELSE.
      rv_dp_check_result  = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD check_178_meter_proc.
***************************************************************************************************
* adesso SDÄ mit Common Layer Engine
*   Bedingung: Wenn SG7 CCI+++Z72 CAV+E01 vorhanden
***************************************************************************************************
    DATA: lv_meter_proc TYPE /idxgc/de_meter_proc.

    lv_meter_proc = get_meter_proc( is_process_step_data = is_process_step_data ).

    IF lv_meter_proc = /idxgc/if_constants_add=>gc_meter_proc_e01.
      rv_dp_check_result = abap_true.
    ELSE.
      rv_dp_check_result  = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD check_179_meter_proc.
***************************************************************************************************
* adesso SDÄ mit Common Layer Engine
*   Bedingung: Wenn SG7 CCI+++Z72 CAV+E14/E24/Z36 vorhanden
***************************************************************************************************
    DATA: lv_meter_proc TYPE /idxgc/de_meter_proc.

    lv_meter_proc = get_meter_proc( is_process_step_data = is_process_step_data ).

    IF lv_meter_proc = /idxgc/if_constants_add=>gc_meter_proc_e14 OR
       lv_meter_proc = /idxgc/if_constants_add=>gc_meter_proc_e24 OR
       lv_meter_proc = /idxgc/if_constants_add=>gc_meter_proc_z36.
      rv_dp_check_result = abap_true.
    ELSE.
      rv_dp_check_result = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD check_181_meter_proc.
***************************************************************************************************
* adesso SDÄ mit Common Layer Engine
*   Bedingung: Wenn SG7 CCI+++Z72 CAV+E02/ E24/ Z29 vorhanden
***************************************************************************************************
    DATA: lv_meter_proc TYPE /idxgc/de_meter_proc.

    lv_meter_proc = get_meter_proc( is_process_step_data = is_process_step_data ).

    IF lv_meter_proc = /idxgc/if_constants_add=>gc_meter_proc_e02 OR
       lv_meter_proc = /idxgc/if_constants_add=>gc_meter_proc_e24 OR
       lv_meter_proc = /idxgc/if_constants_add=>gc_meter_proc_z29.
      rv_dp_check_result = abap_true.
    ELSE.
      rv_dp_check_result = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD check_186_meter_proc.
***************************************************************************************************
* adesso SDÄ mit Common Layer Engine
*   Bedingung: Wenn SG7 CCI+++Z72 CAV+Z29 nicht vorhanden
***************************************************************************************************
    DATA: lv_meter_proc TYPE /idxgc/de_meter_proc.

    lv_meter_proc = get_meter_proc( is_process_step_data = is_process_step_data ).

    IF lv_meter_proc <> /idxgc/if_constants_add=>gc_meter_proc_z29.
      rv_dp_check_result = abap_true.
    ELSE.
      rv_dp_check_result = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD check_188_meter_proc.
***************************************************************************************************
* adesso SDÄ mit Common Layer Engine
*   Bedingung: Wenn SG7 CCI+++Z72 CAV+E02/ E14/ E24 vorhanden
***************************************************************************************************
    DATA: lv_meter_proc TYPE /idxgc/de_meter_proc.

    lv_meter_proc = get_meter_proc( is_process_step_data = is_process_step_data ).

    IF lv_meter_proc = /idxgc/if_constants_add=>gc_meter_proc_e02 OR
       lv_meter_proc = /idxgc/if_constants_add=>gc_meter_proc_e14 OR
       lv_meter_proc = /idxgc/if_constants_add=>gc_meter_proc_e24.
      rv_dp_check_result = abap_true.
    ELSE.
      rv_dp_check_result = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD check_189_meter_proc.
***************************************************************************************************
* adesso SDÄ mit Common Layer Engine
*   Bedingung: Wenn SG7 CCI+++E02 CAV+E02/ E14/ E24 vorhanden
***************************************************************************************************
    DATA: lv_meter_proc          TYPE /idxgc/de_meter_proc.

    lv_meter_proc = get_meter_proc( is_process_step_data = is_process_step_data ).

    IF lv_meter_proc = /idxgc/if_constants_add=>gc_meter_proc_e02 OR
       lv_meter_proc = /idxgc/if_constants_add=>gc_meter_proc_e14 OR
       lv_meter_proc = /idxgc/if_constants_add=>gc_meter_proc_e24.
      rv_dp_check_result  = abap_true.
    ELSE.
      rv_dp_check_result = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD check_201_pod_info.
***************************************************************************************************
* adesso SDÄ mit Common Layer Engine
*   Bedingung: Wenn SG10 CCI+Z15++Z30/ Z70 vorhanden
***************************************************************************************************
    FIELD-SYMBOLS: <fs_pod_info> TYPE /idxgc/s_pod_info_details.

    READ TABLE is_process_step_data-pod INDEX 1 ASSIGNING <fs_pod_info>.
    IF <fs_pod_info> IS ASSIGNED AND <fs_pod_info>-exch_pod_type IS NOT INITIAL.
      IF <fs_pod_info>-exch_pod_type = /idxgc/if_constants_ide=>gc_pod_type_z30 OR
         <fs_pod_info>-exch_pod_type = /idxgc/if_constants_ide=>gc_pod_type_z70.
        rv_dp_check_result  = abap_true.
      ELSE.
        rv_dp_check_result = abap_false.
      ENDIF.
    ELSE.
      MESSAGE e031(/adesso/mdc_process) INTO gv_mtext.
      /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD check_202_respstatus.
***************************************************************************************************
* adesso SDÄ mit Common Layer Engine
*   Bedingung: Wenn SG4 STS+E01+ZG2 vorhanden
***************************************************************************************************
    FIELD-SYMBOLS: <fs_msgrespstatus> TYPE /idxgc/s_msgsts_details,
                   <fs_check_details> TYPE /idxgc/s_check_details.

    LOOP AT is_process_step_data-msgrespstatus ASSIGNING <fs_msgrespstatus> WHERE respstatus = /idxgc/if_constants_ide=>gc_respstatus_zg2.
      rv_dp_check_result  = abap_true.
    ENDLOOP.

    IF <fs_msgrespstatus> IS NOT ASSIGNED.
      LOOP AT gs_process_data_src-check ASSIGNING <fs_check_details> WHERE rejection_code = /idxgc/if_constants_ide=>gc_respstatus_zg2.
        rv_dp_check_result  = abap_true.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD check_204_reg_code_data.
***************************************************************************************************
* THIMEL.R, 20160308, adesso SDÄ mit Common Layer Engine
*   Bedingung: Wenn SG8 SEQ+Z02 vorhanden
*   Prüfung: In Schrittdaten und MTD_CODE_RESULT (inkl. Subsegmente), falls spätere Füllung
* THIMEL.R, 20160322, Erweiterung zur Abfrage der Quellstruktur, da EDIFACT-Struktur und
*   Schrittdaten evtl. noch nicht gefüllt sind.
***************************************************************************************************
    IF lines( is_process_step_data-reg_code_data ) > 0.
      rv_dp_check_result  = abap_true.
      RETURN.
    ENDIF.

    IF lines( gs_process_data_src-reg_code_data ) > 0.
      rv_dp_check_result  = abap_true.
      RETURN.
    ENDIF.

    rv_dp_check_result = check_mtd_code_result( iv_edifact_structur = /adesso/if_mdc_co=>gc_edifact_sg8_seq_z02 is_process_step_data = is_process_step_data ).
  ENDMETHOD.


  METHOD check_205_pod_quant.
***************************************************************************************************
* adesso SDÄ mit Common Layer Engine
*   Bedingung: Wenn SG9 QTY+Y02 nicht vorhanden
***************************************************************************************************
    FIELD-SYMBOLS: <fs_pod_quant> TYPE  /idxgc/s_pod_quant_details.

    rv_dp_check_result  = abap_true.
    LOOP AT is_process_step_data-pod_quant ASSIGNING <fs_pod_quant> WHERE quant_type_qual = /idxgc/if_constants_ide=>gc_qty_qual_y02.
      rv_dp_check_result  = abap_false.
    ENDLOOP.
  ENDMETHOD.


  METHOD check_207_cons_distr_ext.
***************************************************************************************************
* adesso SDÄ mit Common Layer Engine
*   Bedingung: Wenn SG7 CCI+++E17 CAV+Z22 vorhanden
***************************************************************************************************
    FIELD-SYMBOLS: <fs_diverse> TYPE  /idxgc/s_diverse_details.

    READ TABLE is_process_step_data-diverse INDEX 1 ASSIGNING <fs_diverse>.
    IF <fs_diverse> IS ASSIGNED.
      IF <fs_diverse>-cons_distr_ext IS NOT INITIAL.
        rv_dp_check_result  = abap_true.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD check_209_pod_info.
***************************************************************************************************
* adesso SDÄ mit Common Layer Engine
*   Bedingung: Wenn SG10 CCI+Z15++Z31 vorhanden
***************************************************************************************************
    FIELD-SYMBOLS: <fs_pod_info> TYPE /idxgc/s_pod_info_details.

    READ TABLE is_process_step_data-pod INDEX 1 ASSIGNING <fs_pod_info>.
    IF <fs_pod_info> IS ASSIGNED AND <fs_pod_info>-exch_pod_type IS NOT INITIAL.
      IF <fs_pod_info>-exch_pod_type = /idxgc/if_constants_ide=>gc_pod_type_z31.
        rv_dp_check_result  = abap_true.
      ELSE.
        rv_dp_check_result = abap_false.
      ENDIF.
    ELSE.
      MESSAGE e031(/adesso/mdc_process) INTO gv_mtext.
      /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD check_210_pod_info.
***************************************************************************************************
* adesso SDÄ mit Common Layer Engine
*   Bedingung: Wenn SG10 CCI+Z15++Z30/ Z70 nicht vorhanden
***************************************************************************************************
    FIELD-SYMBOLS: <fs_pod> TYPE /idxgc/s_pod_info_details.

    READ TABLE is_process_step_data-pod INDEX 1 ASSIGNING <fs_pod>.
    IF <fs_pod> IS ASSIGNED AND <fs_pod>-exch_pod_type IS NOT INITIAL.
      IF <fs_pod>-exch_pod_type = /idxgc/if_constants_ide=>gc_pod_type_z31 OR
         <fs_pod>-exch_pod_type = /idxgc/if_constants_ide=>gc_pod_type_z71.
        rv_dp_check_result  = abap_true.
      ELSE.
        rv_dp_check_result = abap_false.
      ENDIF.
    ELSE.
      MESSAGE e031(/adesso/mdc_process) INTO gv_mtext.
      /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD CHECK_A01_MTD_CODE_RESULT.
***************************************************************************************************
* adesso SDÄ mit Common Layer Engine
*   Bedingung: Wenn Wert geändert wird (Eigene Methode für KANN Felder in den Nachrichten vom
*     Berechtigten)
***************************************************************************************************
    rv_dp_check_result = me->check_mtd_code_result( iv_edifact_structur = iv_edifact_structur is_process_step_data = is_process_step_data ).
  ENDMETHOD.


  METHOD check_b10_mp_meter_proc.
***************************************************************************************************
* adesso SDÄ mit Common Layer Engine
*   Bedingung: Einer der Punkte muss erfüllt sein:
*     1. Sparte Gas und Zählverfahren ist E02 (SLP).
*     2. Sparte Strom und wenn Zählver-fahren E14 (TLP/TEP mit getrennter Messung), E24 (TLP mit gemeinsa-mer Messung) oder Z36 (TEP mit Referenzmessung).
***************************************************************************************************
    DATA: lv_meter_proc TYPE /idxgc/de_meter_proc,
          lv_service    TYPE sercode,
          lv_division   TYPE sparte,
          lv_spartyp    TYPE spartyp.

    FIELD-SYMBOLS: <fs_marketpartner>   TYPE /idxgc/s_markpar_details.

    LOOP AT is_process_step_data-marketpartner ASSIGNING <fs_marketpartner> WHERE party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_mr.
      SELECT SINGLE service FROM eservprov INTO lv_service WHERE serviceid = <fs_marketpartner>-serviceid.
      SELECT SINGLE division FROM tecde INTO lv_division WHERE service = lv_service.
      SELECT SINGLE spartyp FROM tespt INTO lv_spartyp WHERE sparte = lv_division.
      IF lv_division IS INITIAL.
        MESSAGE e111(/adesso/mdc_process) INTO gv_mtext.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
      ENDIF.
    ENDLOOP.
    IF sy-subrc <> 0.
      MESSAGE e110(/adesso/mdc_process) INTO gv_mtext.
      /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDIF.

    lv_meter_proc = get_meter_proc( is_process_step_data = is_process_step_data ).

    IF lv_division = /adesso/if_mdc_co=>gc_spartyp_01.
      IF lv_meter_proc = /idxgc/if_constants_add=>gc_meter_proc_e14 OR
         lv_meter_proc = /idxgc/if_constants_add=>gc_meter_proc_e24 OR
         lv_meter_proc = /idxgc/if_constants_add=>gc_meter_proc_z36.
        rv_dp_check_result  = abap_true.
      ENDIF.
    ELSEIF lv_division = /adesso/if_mdc_co=>gc_spartyp_02.
      IF lv_meter_proc = /idxgc/if_constants_add=>gc_meter_proc_e02.
        rv_dp_check_result  = abap_true.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD check_b14_request_message.
    DATA: lt_edifact_structur TYPE /adesso/mdc_t_edifact_str.

    FIELD-SYMBOLS: <fv_edifact_structur> TYPE /idxgc/de_edifact_str.

    TRY.
        IF /adesso/cl_mdc_utility=>is_field_set( iv_edifact_structur = iv_edifact_structur is_proc_step_data = gs_process_data_src ) = abap_true.
          rv_dp_check_result = abap_true.
        ENDIF.
      CATCH /idxgc/cx_general.
        TRY.
            lt_edifact_structur = /adesso/cl_mdc_customizing=>get_sub_edifact_structur( iv_edifact_structur = iv_edifact_structur ).
          CATCH /idxgc/cx_general.
            "Es muss nicht immer etwas gefunden werden.
        ENDTRY.
        TRY.
            LOOP AT lt_edifact_structur ASSIGNING <fv_edifact_structur>.
              IF /adesso/cl_mdc_utility=>is_field_set( iv_edifact_structur = <fv_edifact_structur> is_proc_step_data = gs_process_data_src ) = abap_true.
                rv_dp_check_result = abap_true.
                EXIT.
              ENDIF.
            ENDLOOP.
          CATCH /idxgc/cx_general.
            "Wenn ein Fehler auftritt, dann Rückgabe FALSE.
        ENDTRY.
    ENDTRY.
  ENDMETHOD.


  METHOD CHECK_MTD_CODE_RESULT.
***************************************************************************************************
* adesso SDÄ mit Common Layer Engine
*   Bedingung: Wenn Wert geändert wird
*   Sonderfall 1: SEQ Segmente müssen geschickt werden wenn sich ein Wert darin ändert.
*   Sonderfall 2: Bei NAD+UD gibt es zwei EDIFACT Strukturen, die beide mitgeschickt werden müssen,
*     wenn sich die jeweils andere ändert.
***************************************************************************************************
    DATA: lt_edifact_structur TYPE /adesso/mdc_t_edifact_str.

    FIELD-SYMBOLS: <fv_edifact_structur> TYPE /idxgc/de_edifact_str.

    IF iv_edifact_structur IS INITIAL.
      MESSAGE e034(/adesso/mdc_process) INTO gv_mtext.
      /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDIF.

    LOOP AT gs_process_data_src-mtd_code_result TRANSPORTING NO FIELDS WHERE addinfo = iv_edifact_structur.
      rv_dp_check_result = abap_true.
      EXIT.
    ENDLOOP.
    IF rv_dp_check_result = abap_false.
      "Sonderfall 1: Wenn eine der Unterstrukturen gefüllt ist, soll auch die eigentliche Struktur (meist SEQ-Segmente) mitgeschickt werden.
      TRY.
          lt_edifact_structur = /adesso/cl_mdc_customizing=>get_sub_edifact_structur( iv_edifact_structur = iv_edifact_structur ).
        CATCH /idxgc/cx_general.
          "Es muss nicht immer etwas gefunden werden.
      ENDTRY.
      LOOP AT lt_edifact_structur ASSIGNING <fv_edifact_structur>.
        READ TABLE gs_process_data_src-mtd_code_result TRANSPORTING NO FIELDS WITH KEY addinfo = <fv_edifact_structur>.
        IF sy-subrc = 0.
          rv_dp_check_result = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.

      "Sonderfall 2: NAD+UD
      IF iv_edifact_structur = /adesso/if_mdc_co=>gc_edifact_nad_ud_c059ff.
        LOOP AT gs_process_data_src-mtd_code_result TRANSPORTING NO FIELDS WHERE addinfo = /idxgc/if_constants_ide=>gc_edifact_nad_ud.
          rv_dp_check_result = abap_true.
          EXIT.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD check_single_dp_condition.
    DATA: lr_previous        TYPE REF TO cx_root,
          ls_cust_odpm       TYPE /adesso/mdc_s_odpm,
          lv_dp_condition_no TYPE /adesso/mdc_dp_condition_no.

    FIELD-SYMBOLS:  <fs_cust_odpm>      TYPE /adesso/mdc_s_odpm.

    TRY.
        ls_cust_odpm = /adesso/cl_mdc_customizing=>get_method_for_dp_condition( iv_dp_condition_no = iv_dp_condition_no iv_keydate = iv_keydate ).
      CATCH /idxgc/cx_general INTO lr_previous.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ir_previous = lr_previous ).
    ENDTRY.

    IF ls_cust_odpm-class_name IS NOT INITIAL AND ls_cust_odpm-method_name IS NOT INITIAL.
      TRY.
          CALL METHOD me->(ls_cust_odpm-method_name)
            EXPORTING
              is_process_step_data = is_process_step_data
              iv_edifact_structur  = iv_edifact_structur
            RECEIVING
              rv_dp_check_result   = rv_dp_check_result.
        CATCH /idxgc/cx_process_error INTO lr_previous.
          IF ls_cust_odpm-default_check_result = 'E'.
            /idxgc/cx_process_error=>raise_proc_exception_from_msg( ir_previous = lr_previous ).
          ELSE.
            rv_dp_check_result = ls_cust_odpm-default_check_result.
          ENDIF.
      ENDTRY.
    ELSE.
      IF ls_cust_odpm-default_check_result = 'E'.
        MESSAGE e020(/adesso/mdc_process) INTO gv_mtext.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
      ELSE.
        rv_dp_check_result = ls_cust_odpm-default_check_result.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD constructor.
    gs_process_data_src     = is_process_data_src.
    gs_process_data_src_add = is_process_data_src_add.
  ENDMETHOD.


  METHOD evaluate_condition.
    TYPES: BEGIN OF ty_eval_condition,
             dp_condition  TYPE /adesso/mdc_dp_condition,
             flag_evaluate TYPE char1,
             operator      TYPE char1,
           END OF ty_eval_condition.

    DATA: lt_result_tab       TYPE match_result_tab,
          lt_result_tab_temp  TYPE match_result_tab,
          lv_dp_condition     TYPE /adesso/mdc_dp_condition,
          lv_dp_condition_no  TYPE /adesso/mdc_dp_condition_no,
          lt_eval_condition   TYPE TABLE OF ty_eval_condition,
          lv_length_condition TYPE i,
          lv_offset_operator  TYPE i,
          lv_offset_condition TYPE i,
          lv_offset           TYPE i,
          lv_offset_begin     TYPE i,
          lv_counter          TYPE i,
          lv_condition_value  TYPE char1,
          lv_operator_value   TYPE char1.

    FIELD-SYMBOLS: <fs_eval_condition> TYPE ty_eval_condition,
                   <fs_match_result>   TYPE match_result.

    IF iv_dp_condition IS INITIAL OR iv_dp_condition(1) = 'M' OR iv_dp_condition(1) = 'S' OR iv_dp_condition(1) = 'K'.
      lv_dp_condition = iv_dp_condition+1.
    ELSEIF iv_dp_condition(1) = '[' OR iv_dp_condition(1) = '('.
      lv_dp_condition = iv_dp_condition.
    ELSE.
      MESSAGE e015(/adesso/mdc_process) INTO gv_mtext WITH iv_edifact_structur.
      CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg.
    ENDIF.

    IF strlen( lv_dp_condition ) = 0.
      rv_dp_check_result = abap_true.
    ELSE.
      DO.
        IF lv_dp_condition(1) = '['.
          FIND ']' IN lv_dp_condition MATCH OFFSET lv_offset.
          APPEND INITIAL LINE TO lt_eval_condition ASSIGNING <fs_eval_condition>.
          lv_offset_operator = lv_offset + 1.
          <fs_eval_condition>-operator = lv_dp_condition+lv_offset_operator(1).
          lv_length_condition = lv_offset - 1.
          <fs_eval_condition>-dp_condition = lv_dp_condition+1(lv_length_condition).
          <fs_eval_condition>-flag_evaluate = abap_false.
          lv_offset_condition = lv_offset + 2.
          lv_dp_condition = lv_dp_condition+lv_offset_condition.

        ELSEIF lv_dp_condition(1) = '('.
          FIND ALL OCCURRENCES OF '(' IN lv_dp_condition RESULTS lt_result_tab.
          FIND ALL OCCURRENCES OF ')' IN lv_dp_condition RESULTS lt_result_tab_temp.
          LOOP AT lt_result_tab_temp ASSIGNING <fs_match_result>.
            <fs_match_result>-line = 1.
          ENDLOOP.
          APPEND LINES OF lt_result_tab_temp TO lt_result_tab.
          SORT lt_result_tab BY offset.
          lv_counter = 0.

          LOOP AT lt_result_tab ASSIGNING <fs_match_result>.
            IF <fs_match_result>-line = 0.
              IF lv_counter = 0.
                APPEND INITIAL LINE TO lt_eval_condition ASSIGNING <fs_eval_condition>.
                lv_offset_begin = <fs_match_result>-offset.
              ENDIF.
              lv_counter = lv_counter + 1.
            ELSE.
              IF lv_counter = 1.
                lv_offset_operator = <fs_match_result>-offset + 1.
                <fs_eval_condition>-operator = lv_dp_condition+lv_offset_operator(1).
                lv_length_condition = <fs_match_result>-offset - lv_offset_begin - 1.
                lv_offset_condition = lv_offset_begin + 1.
                <fs_eval_condition>-dp_condition = lv_dp_condition+lv_offset_condition(lv_length_condition).
                <fs_eval_condition>-flag_evaluate = abap_true.
                lv_offset_condition = <fs_match_result>-offset + 2.
              ENDIF.
              lv_counter = lv_counter - 1.
            ENDIF.
          ENDLOOP.
          lv_dp_condition = lv_dp_condition+lv_offset_condition.
        ENDIF.
        IF strlen( lv_dp_condition ) = 0.
          EXIT.
        ENDIF.
      ENDDO.

      LOOP AT lt_eval_condition ASSIGNING <fs_eval_condition> WHERE flag_evaluate = abap_true.
        <fs_eval_condition>-dp_condition = evaluate_condition( is_process_step_data = is_process_step_data iv_edifact_structur = iv_edifact_structur iv_dp_condition = <fs_eval_condition>-dp_condition ).
      ENDLOOP.

      LOOP AT lt_eval_condition ASSIGNING <fs_eval_condition>.
        IF <fs_eval_condition>-dp_condition <> abap_false AND <fs_eval_condition>-dp_condition <> abap_true.
          TRY.
              lv_dp_condition_no = <fs_eval_condition>-dp_condition.
              <fs_eval_condition>-dp_condition = check_single_dp_condition( is_process_step_data = is_process_step_data iv_edifact_structur = iv_edifact_structur iv_dp_condition_no = lv_dp_condition_no  ).
            CATCH /idxgc/cx_general.
          ENDTRY.
        ENDIF.

        IF lv_operator_value IS INITIAL.
          lv_operator_value = <fs_eval_condition>-operator.
          lv_condition_value = <fs_eval_condition>-dp_condition.
          CONTINUE.
        ENDIF.
        CASE lv_operator_value.
          WHEN 'U'.
            IF lv_condition_value = abap_true AND <fs_eval_condition>-dp_condition = abap_true.
              lv_condition_value = abap_true.
              lv_operator_value = <fs_eval_condition>-operator.
            ELSE.
              lv_condition_value = abap_false.
              lv_operator_value = <fs_eval_condition>-operator.
            ENDIF.
          WHEN 'X'.
            IF ( lv_condition_value = abap_true  AND <fs_eval_condition>-dp_condition = abap_false ) OR
               ( lv_condition_value = abap_false AND <fs_eval_condition>-dp_condition = abap_true ).
              lv_condition_value = abap_true.
              lv_operator_value = <fs_eval_condition>-operator.
            ELSE.
              lv_condition_value = abap_false.
              lv_operator_value = <fs_eval_condition>-operator.
            ENDIF.
          WHEN 'O'.
            IF lv_condition_value = abap_true OR <fs_eval_condition>-dp_condition = abap_true.
              lv_condition_value = abap_true.
              lv_operator_value = <fs_eval_condition>-operator.
            ELSE.
              lv_condition_value = abap_false.
              lv_operator_value = <fs_eval_condition>-operator.
            ENDIF.
        ENDCASE.
      ENDLOOP.
      rv_dp_check_result = lv_condition_value.
    ENDIF.

  ENDMETHOD.


  METHOD get_meter_proc.
***************************************************************************************************
* adesso SDÄ mit Common Layer Engine
*   Ermittlung Zählverfahren und Speicherung am Objekt. Ob EXCH_METER_PROC oder METER_PROC ist
*   nicht relevant, da es immer aus dem System ermittelt wird und dem aktuellen entspricht.
***************************************************************************************************
    DATA: lr_badi_data_provision TYPE REF TO /idxgc/badi_data_provision,
          lt_diverse             TYPE /idxgc/t_diverse_details.

    FIELD-SYMBOLS: <fs_diverse>         TYPE /idxgc/s_diverse_details.

    IF gv_meter_proc IS INITIAL.
      READ TABLE is_process_step_data-diverse INDEX 1 ASSIGNING <fs_diverse>.
      IF <fs_diverse> IS ASSIGNED .
        IF <fs_diverse>-meter_proc IS NOT INITIAL.
          gv_meter_proc = <fs_diverse>-meter_proc.
        ELSEIF <fs_diverse>-exch_meter_proc IS NOT INITIAL.
          gv_meter_proc = <fs_diverse>-exch_meter_proc.
        ENDIF.
      ENDIF.
    ENDIF.

    IF gv_meter_proc IS INITIAL.
      TRY.
          GET BADI lr_badi_data_provision.
        CATCH cx_badi_not_implemented.
          "Das BAdI muss nicht implementiert sein.
      ENDTRY.

      IF lr_badi_data_provision IS NOT INITIAL.
        TRY.
            CALL BADI lr_badi_data_provision->already_exch_metering_proc
              EXPORTING
                is_process_data_src     = is_process_step_data
                is_process_data_src_add = is_process_step_data
                is_process_data         = is_process_step_data
                iv_itemid               = 1
              CHANGING
                ct_diverse              = lt_diverse.
          CATCH /idxgc/cx_utility_error.
            "Fehlerbehandlung erfolgt später.
        ENDTRY.
      ENDIF.

      READ TABLE lt_diverse ASSIGNING <fs_diverse> INDEX 1.
      IF sy-subrc = 0 AND <fs_diverse>-exch_meter_proc IS NOT INITIAL.
        gv_meter_proc = <fs_diverse>-exch_meter_proc.
      ELSE.
        MESSAGE e021(/adesso/mdc_process) INTO gv_mtext.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
      ENDIF.
    ENDIF.

    rv_meter_proc = gv_meter_proc.

  ENDMETHOD.
ENDCLASS.
