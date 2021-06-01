class /ADESSO/CL_BPM_FILL_CONT_EIDE definition
  public
  abstract
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces /ADESSO/IF_BPM_FILL_CONTAINER .

  class-data AR_PROCESS_DATA_ENGINE type ref to /IDXGC/IF_PROCESS_DATA_EXTERN .

  methods CONSTRUCTOR
    importing
      !IV_PROC_STEP_REF type /IDXGC/DE_PROC_STEP_REF
      !IV_PROC_STEP_NO type /IDXGC/DE_PROC_STEP_NO
      !IV_PROC_REF type /IDXGC/DE_PROC_REF
      !IR_CTX type ref to /IDXGC/CL_PD_DOC_CONTEXT
      !IV_CCAT type EMMA_CCAT
      !IV_PROC_ID type /IDXGC/DE_PROC_ID
      !IV_EXCEPTIONCODE type /IDXGC/DE_EXCP_CODE
    raising
      /ADESSO/CX_BPM_GENERAL .
  methods GET_MESSAGE
    importing
      !IV_MSGID type SYMSGID
      !IV_MSGNO type SYMSGNO
      !IV_MSGTY type SYMSGTY
      !IV_MSGV1 type DATA optional
      !IV_MSGV2 type DATA optional
      !IV_MSGV3 type DATA optional
      !IV_MSGV4 type DATA optional
    returning
      value(RS_MESSAGE) type EDIMESSAGE .
  methods FILL_CONT
    importing
      !IV_ELEMENT type SWC_EDITEL
      !IV_DATA type DATA .
  methods EXECUTE
    raising
      /ADESSO/CX_BPM_GENERAL .
  methods GET_CLASS_ATTRIBUTE
    importing
      !IV_ATTRIBUTE type C
    exporting
      value(ET_ATTRIBUTE) type ANY TABLE
    raising
      /ADESSO/CX_BPM_GENERAL .
protected section.

  data AS_PROC_HDR type /IDXGC/S_PROC_HDR .
  data AS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA .
  data AS_PROC_STEP_DATA_SRC type /IDXGC/S_PROC_STEP_DATA .
  data AS_PROC_STEP_DATA_ADD_SRC type /IDXGC/S_PROC_STEP_DATA .
  data AV_CCAT type EMMA_CCAT .
  data AR_CTX type ref to /IDXGC/CL_PD_DOC_CONTEXT .
  data AV_PROC_ID type /IDXGC/DE_PROC_ID .
  data AS_CURRENT_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA .
  data AV_EXCEPTIONCODE type /IDXGC/DE_EXCP_CODE .
private section.
ENDCLASS.



CLASS /ADESSO/CL_BPM_FILL_CONT_EIDE IMPLEMENTATION.


  METHOD /adesso/if_bpm_fill_container~get_aclass.

    DATA: ls_v_eanl TYPE v_eanl.

    TRY.
        ls_v_eanl = /adesso/cl_isu_masterdata=>get_v_eanl( iv_anlage = /adesso/cl_isu_masterdata=>get_anlage( iv_int_ui = as_proc_hdr-int_ui iv_keydate = as_proc_hdr-proc_date ) iv_keydate = as_proc_hdr-proc_date ).
      CATCH /adesso/cx_isu_general.
    ENDTRY.

    IF ls_v_eanl-aklasse IS NOT INITIAL.
      fill_cont( iv_element = iv_element iv_data = ls_v_eanl-aklasse ).
    ELSE.
      rs_message = get_message( iv_msgid = '/ADESSO/BPM_CONT' iv_msgno = '001' iv_msgty = 'W' iv_msgv1 = iv_element ).
    ENDIF.

  ENDMETHOD.


  METHOD /adesso/if_bpm_fill_container~get_ccat.

    IF av_ccat IS NOT INITIAL.
      fill_cont( EXPORTING iv_element = iv_element iv_data = av_ccat ).
    ELSE.
      rs_message = get_message( iv_msgid = 'ZISU_IDXGC_BPEM' iv_msgty = 'W' iv_msgno = 000 iv_msgv1 = iv_element ).
    ENDIF.

  ENDMETHOD.


  METHOD /adesso/if_bpm_fill_container~get_customer_flag.
    "Kann vom Kunden in der jeweiligen Unterklasse implementiert werden
  ENDMETHOD.


  METHOD /adesso/if_bpm_fill_container~get_grid.

    DATA: ls_euigrid TYPE euigrid.

    TRY.
        ls_euigrid = /adesso/cl_isu_masterdata=>get_grid( iv_int_ui = as_proc_hdr-int_ui iv_keydate = as_proc_hdr-proc_date ).
      CATCH /adesso/cx_isu_general.
    ENDTRY.

    IF ls_euigrid-grid_id IS NOT INITIAL.
      fill_cont( iv_element = iv_element iv_data = ls_euigrid-grid_id ).
    ELSE.
      rs_message = get_message( iv_msgid = '/ADESSO/BPM_CONT' iv_msgno = '001' iv_msgty = 'W' iv_msgv1 = iv_element ).
    ENDIF.

  ENDMETHOD.


  METHOD /adesso/if_bpm_fill_container~get_instln_type.
    DATA: ls_v_eanl TYPE v_eanl.

    TRY.
        ls_v_eanl = /adesso/cl_isu_masterdata=>get_v_eanl( iv_anlage = /adesso/cl_isu_masterdata=>get_anlage( iv_int_ui = as_proc_hdr-int_ui iv_keydate = as_proc_hdr-proc_date ) iv_keydate = as_proc_hdr-proc_date ).
      CATCH /adesso/cx_isu_general.
    ENDTRY.

    IF ls_v_eanl-anlart IS NOT INITIAL.
      fill_cont( iv_element = iv_element iv_data = ls_v_eanl-anlart ).
    ELSE.
      rs_message = get_message( iv_msgid = '/ADESSO/BPM_CONT' iv_msgno = '001' iv_msgty = 'W' iv_msgv1 = iv_element ).
    ENDIF.
  ENDMETHOD.


  METHOD /adesso/if_bpm_fill_container~get_isu_task.

    DATA: lv_dextaskid            TYPE e_dextaskid,
          ls_proc_step_data_local TYPE /idxgc/s_proc_step_data.

    FIELD-SYMBOLS: <fs_step_config> TYPE /idxgc/s_proc_step_config_all.

    IF as_proc_step_data-dextaskid IS INITIAL.
      IF as_proc_step_data_src-dextaskid IS INITIAL.
        IF as_proc_step_data_add_src-dextaskid IS NOT INITIAL.
          lv_dextaskid = as_proc_step_data_add_src-dextaskid.
        ENDIF.
      ELSE.
        lv_dextaskid = as_proc_step_data_src-dextaskid.
      ENDIF.
    ELSE.
      lv_dextaskid = as_proc_step_data-dextaskid.
    ENDIF.

    IF lv_dextaskid IS NOT INITIAL.
      fill_cont( EXPORTING iv_element = iv_element iv_data = lv_dextaskid ).
    ELSE.
      rs_message = get_message( iv_msgid = 'ZISU_IDXGC_BPEM' iv_msgty = 'W' iv_msgno = 000 iv_msgv1 = iv_element ).
    ENDIF.

  ENDMETHOD.


  METHOD /adesso/if_bpm_fill_container~get_mandt.

    IF sy-mandt IS NOT INITIAL.
      fill_cont( EXPORTING iv_element = iv_element iv_data = sy-mandt ).
    ELSE.
      rs_message = get_message( iv_msgid = 'ZISU_IDXGC_BPEM' iv_msgty = 'W' iv_msgno = 000 iv_msgv1 = iv_element ).
    ENDIF.

  ENDMETHOD.


  METHOD /adesso/if_bpm_fill_container~get_metmethod.
    DATA: lv_metmethod TYPE /idxgc/de_meter_proc.

    FIELD-SYMBOLS: <fs_diverse_data> TYPE /idxgc/s_diverse_details.

    IF as_proc_step_data-diverse IS INITIAL.
      IF as_proc_step_data_src-diverse IS INITIAL.
        READ TABLE as_proc_step_data_add_src-diverse ASSIGNING <fs_diverse_data> INDEX 1.
      ELSE.
        READ TABLE as_proc_step_data_src-diverse ASSIGNING <fs_diverse_data> INDEX 1.
      ENDIF.
    ELSE.
      READ TABLE as_proc_step_data-diverse ASSIGNING <fs_diverse_data> INDEX 1.
    ENDIF.

    IF <fs_diverse_data> IS ASSIGNED AND <fs_diverse_data>-meter_proc IS NOT INITIAL.
      lv_metmethod = <fs_diverse_data>-meter_proc.
    ENDIF.

    IF lv_metmethod IS NOT INITIAL.
      fill_cont( iv_element = iv_element iv_data = lv_metmethod ).
    ELSE.
      rs_message = get_message( iv_msgid = '/ADESSO/BPM_CONT' iv_msgno = '001' iv_msgty = 'W' iv_msgv1 = iv_element ).
    ENDIF.
  ENDMETHOD.


  METHOD /adesso/if_bpm_fill_container~get_pod.

    IF as_proc_hdr-int_ui IS NOT INITIAL.
      fill_cont( EXPORTING iv_element = iv_element iv_data = as_proc_hdr-int_ui ).
    ELSE.
      rs_message = get_message( iv_msgid = 'ZISU_IDXGC_BPEM' iv_msgty = 'W' iv_msgno = 000 iv_msgv1 = iv_element ).
    ENDIF.

  ENDMETHOD.


  METHOD /adesso/if_bpm_fill_container~get_regiogroup.

    DATA: lv_vertrag        TYPE ever-vertrag,
          lv_keydate        TYPE dats,

          ls_account_data   TYPE fkkvkp1,
          ls_name_adress    TYPE /idxgc/s_nameaddr_details,
          ls_proc_step_data TYPE /idxgc/s_proc_step_data,

          lr_isu_contract   TYPE REF TO cl_isu_contract,
          lr_isu_account    TYPE REF TO cl_isu_contract_account,

          ls_v_eanl         TYPE v_eanl.

    TRY.
        ls_v_eanl = /adesso/cl_isu_masterdata=>get_v_eanl( iv_anlage = /adesso/cl_isu_masterdata=>get_anlage( iv_int_ui = as_proc_hdr-int_ui iv_keydate = as_proc_hdr-proc_date ) iv_keydate = as_proc_hdr-proc_date ).
      CATCH /adesso/cx_isu_general.
    ENDTRY.

    CHECK ls_v_eanl IS NOT INITIAL.

    WHILE lv_vertrag IS INITIAL.

      SELECT SINGLE vertrag FROM ever INTO lv_vertrag WHERE anlage = ls_v_eanl-anlage AND
                                                            einzdat <= lv_keydate AND
                                                            auszdat >= lv_keydate.

      IF sy-subrc <> 0 AND lv_keydate = as_proc_hdr-proc_date.
        lv_keydate = as_proc_hdr-proc_date - 1.
      ELSE.
        EXIT.
      ENDIF.
    ENDWHILE.

    IF lv_vertrag IS NOT INITIAL.

      CALL METHOD cl_isu_contract=>select
        EXPORTING
          contractid     = lv_vertrag
        RECEIVING
          contract       = lr_isu_contract
        EXCEPTIONS
          invalid_object = 1
          OTHERS         = 2.

      IF sy-subrc = 0.

        CALL METHOD lr_isu_contract->get_account
          RECEIVING
            y_account      = lr_isu_account
          EXCEPTIONS
            invalid_object = 1
            not_found      = 2
            not_selected   = 3
            OTHERS         = 4.

        IF sy-subrc = 0.

          CALL METHOD lr_isu_account->get_all_properties
            RECEIVING
              y_account_data = ls_account_data
            EXCEPTIONS
              invalid_object = 1
              not_selected   = 2
              OTHERS         = 3.

          IF ls_account_data-regiogr_ca_b IS NOT INITIAL.
            fill_cont( EXPORTING iv_element = iv_element iv_data = ls_account_data-regiogr_ca_b ).
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    "Wenn über den Vertrag keine Regiogroup gefunden werden kann dann aus den Schrittdaten ermitteln. Bsp.: Anmeldung EoG
    IF ls_account_data-regiogr_ca_b IS INITIAL.
      READ TABLE as_proc_step_data-name_address INTO ls_name_adress WITH KEY party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_dp.
      IF ls_name_adress-postalcode IS NOT INITIAL.
        fill_cont( EXPORTING iv_element = iv_element iv_data = ls_name_adress-postalcode ).
      ELSE.
        READ TABLE as_proc_step_data_src-name_address INTO ls_name_adress WITH KEY party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_dp.
        IF ls_name_adress-postalcode IS NOT INITIAL.
          fill_cont( EXPORTING iv_element = iv_element iv_data = ls_name_adress-postalcode ).
        ELSE.
          READ TABLE as_proc_step_data_add_src-name_address INTO ls_name_adress WITH KEY party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_dp.
          IF ls_name_adress-postalcode IS NOT INITIAL.
            fill_cont( EXPORTING iv_element = iv_element iv_data = ls_name_adress-postalcode ).
          ELSE.
            rs_message = get_message( iv_msgid = '/ADESSO/BPM_CONT' iv_msgno = '001' iv_msgty = 'W' iv_msgv1 = iv_element ).
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD /adesso/if_bpm_fill_container~get_sysid.

    IF sy-sysid IS NOT INITIAL.
      fill_cont( EXPORTING iv_element = iv_element iv_data = sy-sysid ).
    ELSE.
      rs_message = get_message( iv_msgid = 'ZISU_IDXGC_BPEM' iv_msgty = 'W' iv_msgno = 000 iv_msgv1 = iv_element ).
    ENDIF.

  ENDMETHOD.


  METHOD constructor.
    DATA: ls_proc_config         TYPE /idxgc/s_proc_config_all,
          lv_no_actual_step_data TYPE abap_bool,
          ls_current_step_config TYPE /idxgc/s_proc_step_config_all,
          lv_rel_proc_step_no    TYPE /idxgc/de_proc_step_no.

    FIELD-SYMBOLS: <fs_step_config> TYPE /idxgc/s_proc_step_config_all.

    ar_ctx = ir_ctx.
    av_ccat = iv_ccat.
    av_proc_id = iv_proc_id.
    av_exceptioncode = iv_exceptioncode.

    TRY.

        CALL METHOD ar_ctx->get_header_data
          IMPORTING
            es_proc_hdr = as_proc_hdr.

        CALL METHOD /idxgc/cl_cust_access=>/idxgc/if_cust_access~get_process_config
          EXPORTING
            iv_process_id     = iv_proc_id
          IMPORTING
            es_process_config = ls_proc_config.

        "Relevanten Schritt Ermitteln (Sonderfall Terminschritte, Empfangsschritte usw.)
        READ TABLE ls_proc_config-steps INTO ls_current_step_config WITH KEY proc_step_no = iv_proc_step_no.
        CASE ls_current_step_config-type.
          WHEN 'WFDLC'.
            LOOP AT ls_proc_config-steps ASSIGNING <fs_step_config>.
              IF <fs_step_config>-proc_step_assoc = iv_proc_step_no.
                lv_rel_proc_step_no = <fs_step_config>-proc_step_no.
              ENDIF.
            ENDLOOP.
          WHEN 'WFREC'.
            lv_rel_proc_step_no = iv_proc_step_no.
            lv_no_actual_step_data = abap_true.
          WHEN OTHERS.
            lv_rel_proc_step_no = iv_proc_step_no.
        ENDCASE.

        "Schrittdaten ermitteln
        IF ar_process_data_engine IS NOT BOUND. "Keine Prozess Engine
          CALL METHOD ar_ctx->get_proc_step_data
            EXPORTING
              iv_proc_step_no   = iv_proc_step_no
            IMPORTING
              es_proc_step_data = as_current_proc_step_data.

          CALL METHOD ar_ctx->get_proc_step_data
            EXPORTING
              iv_proc_step_no   = lv_rel_proc_step_no
            IMPORTING
              es_proc_step_data = as_proc_step_data.

          "Quellschrittdaten ermitteln
          READ TABLE ls_proc_config-steps ASSIGNING <fs_step_config> WITH KEY proc_step_no = lv_rel_proc_step_no.

          IF <fs_step_config> IS ASSIGNED.
            CALL METHOD ar_ctx->get_proc_step_data
              EXPORTING
                iv_proc_step_no   = <fs_step_config>-proc_step_src
              IMPORTING
                es_proc_step_data = as_proc_step_data_src.

            CALL METHOD ar_ctx->get_proc_step_data
              EXPORTING
                iv_proc_step_no   = <fs_step_config>-step_no_src_add
              IMPORTING
                es_proc_step_data = as_proc_step_data_add_src.
          ENDIF.
        ELSE. "Prozess Engine
          READ TABLE ar_process_data_engine->gs_process_data-steps INTO as_current_proc_step_data WITH KEY proc_step_no = iv_proc_step_no.
          READ TABLE ar_process_data_engine->gs_process_data-steps INTO as_proc_step_data WITH KEY proc_step_no = lv_rel_proc_step_no.
          "Quellschrittdaten ermitteln
          READ TABLE ls_proc_config-steps ASSIGNING <fs_step_config> WITH KEY proc_step_no = lv_rel_proc_step_no.
          IF <fs_step_config> IS ASSIGNED.
            READ TABLE ar_process_data_engine->gs_process_data-steps INTO as_proc_step_data_src WITH KEY proc_step_no = <fs_step_config>-proc_step_src.
            READ TABLE ar_process_data_engine->gs_process_data-steps INTO as_proc_step_data_add_src WITH KEY proc_step_no = <fs_step_config>-step_no_src_add.
          ENDIF.
        ENDIF.



      CATCH /idxgc/cx_process_error /idxgc/cx_config_error /idxgc/cx_general.
        /adesso/cx_bpm_general=>raise_exception_from_msg( ).
    ENDTRY.

  ENDMETHOD.


  METHOD execute.
    "Muss in den Unterklassen definiert werden!
  ENDMETHOD.


  METHOD FILL_CONT.
    "Muss in den Unterklassen implementiert werden
  ENDMETHOD.


  METHOD get_class_attribute.
    FIELD-SYMBOLS: <ft_any> TYPE ANY TABLE.

    ASSIGN me->(iv_attribute) TO <ft_any>.

    IF <ft_any> IS ASSIGNED.
      et_attribute = <ft_any>.
    ELSE.
      /adesso/cx_bpm_general=>raise_exception_from_msg( ).
    ENDIF.

  ENDMETHOD.


  method GET_MESSAGE.
  endmethod.
ENDCLASS.
