class /ADESSO/CL_MDC_IM_PRO_COADDR definition
  public
  create public .

public section.

  interfaces /ADESSO/IF_MDC_PRO_CHG .
  interfaces IF_BADI_INTERFACE .
protected section.

  class-data GR_PREVIOUS type ref to CX_ROOT .
  class-data GV_MTEXT type STRING .

  methods SET_COADDR_DATA
    importing
      !IS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    changing
      !CS_ADDR1_DATA type ADDR1_DATA
      !CS_OBJ type ISU01_CONNOBJ
    raising
      /IDXGC/CX_UTILITY_ERROR .
private section.
ENDCLASS.



CLASS /ADESSO/CL_MDC_IM_PRO_COADDR IMPLEMENTATION.


  METHOD /adesso/if_mdc_pro_chg~change_auto.
    DATA: lt_error_table   TYPE TABLE OF addr_error,
          ls_obj           TYPE isu01_connobj,
          ls_addr1_sel     TYPE addr1_sel,
          ls_addr1_val_old TYPE addr1_val,
          ls_addr1_data    TYPE addr1_data,
          lv_anlage        TYPE anlage,
          lv_premise       TYPE vstelle,
          lv_haus          TYPE haus.

    TRY.
        lv_anlage  = /adesso/cl_mdc_masterdata=>get_anlage( iv_int_ui = is_proc_step_data-int_ui iv_keydate = is_proc_step_data-proc_date ).
        lv_premise = /adesso/cl_mdc_masterdata=>get_premise( iv_anlage = lv_anlage ).
        lv_haus    = /adesso/cl_mdc_masterdata=>get_conn_obj( iv_premise = lv_premise ).
      CATCH /idxgc/cx_general INTO gr_previous.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.

    DO 5 TIMES.
      CALL FUNCTION 'ISU_S_CONNOBJ_PROVIDE'
        EXPORTING
          x_haus        = lv_haus
          x_wmode       = /idxgc/cl_pod_rel_access=>gc_change
        IMPORTING
          y_obj         = ls_obj
        EXCEPTIONS
          not_found     = 1
          foreign_lock  = 2
          general_fault = 3
          OTHERS        = 4.
      IF sy-subrc = 2.
        "Objekt gesperrt
        WAIT UP TO 1 SECONDS.
      ELSEIF sy-subrc <> 0.
        MESSAGE w013(/adesso/mdc_process) INTO gv_mtext.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ).
      ELSEIF sy-subrc = 0.
        EXIT.
      ENDIF.
    ENDDO.

    CALL FUNCTION 'ISU_O_CONNOBJ_CLOSE'
      CHANGING
        xy_obj = ls_obj.

    ls_addr1_sel-addrnumber = ls_obj-addrobj-addrnumber.

    CALL FUNCTION 'ADDR_GET'
      EXPORTING
        address_selection = ls_addr1_sel
      IMPORTING
        address_value     = ls_addr1_val_old
      EXCEPTIONS
        parameter_error   = 1
        address_not_exist = 2
        version_not_exist = 3
        internal_error    = 4
        OTHERS            = 5.
    IF sy-subrc <> 0.
      MESSAGE e013(/adesso/mdc_process) INTO gv_mtext.
      /idxgc/cx_utility_error=>raise_util_exception_from_msg( ).
    ENDIF.

    MOVE-CORRESPONDING ls_addr1_val_old TO ls_addr1_data.

    me->set_coaddr_data( EXPORTING is_proc_step_data = is_proc_step_data CHANGING cs_obj = ls_obj cs_addr1_data = ls_addr1_data ).

    /adesso/cl_mdc_datex_utility=>disable_datex( iv_int_ui = is_proc_step_data-int_ui ).

    CALL FUNCTION 'ADDR_UPDATE'
      EXPORTING
        address_data      = ls_addr1_data
        address_handle    = ls_addr1_val_old-addrhandle
        address_number    = ls_addr1_val_old-addrnumber
        check_address     = abap_true
      IMPORTING
        address_data      = ls_addr1_data
      TABLES
        error_table       = lt_error_table
      EXCEPTIONS
        address_not_exist = 1
        parameter_error   = 2
        version_not_exist = 3
        internal_error    = 4
        OTHERS            = 5.
    IF sy-subrc <> 0 OR lt_error_table IS NOT INITIAL.
      /adesso/cl_mdc_datex_utility=>enable_datex( iv_int_ui = is_proc_step_data-int_ui ).
      MESSAGE w014(/adesso/mdc_process) INTO gv_mtext.
      /idxgc/cx_utility_error=>raise_util_exception_from_msg( ).
    ENDIF.

    CALL FUNCTION 'ADDR_SINGLE_SAVE'
      EXPORTING
        address_number         = ls_addr1_val_old-addrnumber
      EXCEPTIONS
        address_not_exist      = 1
        person_not_exist       = 2
        address_number_missing = 3
        reference_missing      = 4
        internal_error         = 5
        database_error         = 6
        parameter_error        = 7
        OTHERS                 = 8.
    IF sy-subrc <> 0.
      /adesso/cl_mdc_datex_utility=>enable_datex( iv_int_ui = is_proc_step_data-int_ui ).
      MESSAGE w014(/adesso/mdc_process) INTO gv_mtext.
      /idxgc/cx_utility_error=>raise_util_exception_from_msg( ).
    ENDIF.

    /adesso/cl_mdc_datex_utility=>enable_datex( iv_int_ui = is_proc_step_data-int_ui ).

  ENDMETHOD.


  METHOD /adesso/if_mdc_pro_chg~change_manual.

    CALL FUNCTION '/ADESSO/MDC_CHANGE_COADDR' STARTING NEW TASK 'MDC_CHANGE_COADDR'
      EXPORTING
        is_proc_step_data = is_proc_step_data.

  ENDMETHOD.


  METHOD set_coaddr_data.
    DATA: ls_mtd_code_result TYPE /idxgc/s_mtd_code_details.

    FIELD-SYMBOLS: <fs_name_address> TYPE /idxgc/s_nameaddr_details.

    READ TABLE is_proc_step_data-name_address ASSIGNING <fs_name_address> WITH KEY party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_dp.

    LOOP AT is_proc_step_data-mtd_code_result INTO ls_mtd_code_result
        WHERE compname = /adesso/if_mdc_co=>gc_compname_name_address AND ref_id = /idxgc/if_constants_ide=>gc_nad_qual_dp.

      CASE ls_mtd_code_result-fieldname.
        WHEN /adesso/if_mdc_co=>gc_fieldname_streetname.
          cs_addr1_data-street      = <fs_name_address>-streetname.
        WHEN /adesso/if_mdc_co=>gc_fieldname_houseid.
          cs_addr1_data-house_num1  = <fs_name_address>-houseid.
        WHEN /adesso/if_mdc_co=>gc_fieldname_houseid_add.
          cs_addr1_data-house_num2  = <fs_name_address>-houseid_add.
        WHEN /adesso/if_mdc_co=>gc_fieldname_postalcode.
          cs_addr1_data-post_code1  = <fs_name_address>-postalcode.
        WHEN /adesso/if_mdc_co=>gc_fieldname_countrycode.
          cs_addr1_data-county_code = <fs_name_address>-countrycode .
        WHEN /adesso/if_mdc_co=>gc_fieldname_cityname.
          cs_addr1_data-city1       = <fs_name_address>-cityname .
      ENDCASE.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
