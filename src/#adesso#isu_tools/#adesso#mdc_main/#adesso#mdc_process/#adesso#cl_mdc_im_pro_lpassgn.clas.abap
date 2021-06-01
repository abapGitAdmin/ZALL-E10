class /ADESSO/CL_MDC_IM_PRO_LPASSGN definition
  public
  create public .

public section.

  interfaces /ADESSO/IF_MDC_PRO_CHG .
  interfaces IF_BADI_INTERFACE .
protected section.

  class-data GR_PREVIOUS type ref to CX_ROOT .
  class-data GV_MTEXT type STRING .

  methods SET_LPASSGN_DATA
    importing
      !IS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    changing
      !CS_OBJ type ISULP_LPASSLIST
      !CS_AUTO type ISULP_LPASSLIST_AUTO
    raising
      /IDXGC/CX_UTILITY_ERROR .
private section.
ENDCLASS.



CLASS /ADESSO/CL_MDC_IM_PRO_LPASSGN IMPLEMENTATION.


  METHOD /adesso/if_mdc_pro_chg~change_auto.
    DATA: ls_obj    TYPE isulp_lpasslist,
          ls_auto   TYPE isulp_lpasslist_auto,
          lv_anlage TYPE anlage,
          lv_sparte TYPE sparte,
          lv_objkey TYPE swo_typeid.

    TRY.
        lv_anlage = /adesso/cl_mdc_masterdata=>get_anlage( iv_int_ui  = is_proc_step_data-int_ui iv_keydate = is_proc_step_data-proc_date ).
        lv_sparte = /adesso/cl_mdc_masterdata=>get_sparte( iv_int_ui  = is_proc_step_data-int_ui ).
      CATCH /idxgc/cx_general INTO gr_previous.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.

    lv_objkey = lv_anlage.

    CALL FUNCTION 'ISU_S_LPASSLIST_PROVIDE'
      EXPORTING
        x_objtype           = 'INSTLN'
        x_objkey            = lv_objkey
        x_wmode             = /idxgc/cl_pod_rel_access=>gc_change
        x_no_dialog         = abap_true
      CHANGING
        y_obj               = ls_obj
        y_auto              = ls_auto
      EXCEPTIONS
        not_found           = 1
        invalid_object_type = 2
        invalid_wmode       = 3
        system_error        = 4
        OTHERS              = 5.
    IF sy-subrc <> 0.
      MESSAGE e040(/adesso/mdc_process) INTO gv_mtext.
      /idxgc/cx_utility_error=>raise_util_exception_from_msg( ).
    ENDIF.

    CALL FUNCTION 'ISU_O_INSTLN_CLOSE'
      CHANGING
        xy_obj = ls_obj.

    me->set_lpassgn_data( EXPORTING is_proc_step_data = is_proc_step_data CHANGING cs_obj = ls_obj cs_auto = ls_auto ).

    /adesso/cl_mdc_datex_utility=>disable_datex( iv_int_ui = is_proc_step_data-int_ui ).

    CALL FUNCTION 'ISU_S_LPASSLIST_MAINTAIN'
      EXPORTING
        x_objtype            = 'INSTLN'
        x_objkey             = lv_objkey
        x_wmode              = /idxgc/cl_pod_rel_access=>gc_change
        x_sparte             = lv_sparte
        x_no_dialog          = abap_true
        x_upd_online         = abap_true
        x_key_date           = sy-datum
        x_valid_ab           = '19000101'
        x_valid_bis          = '99991231'
        x_obj                = ls_obj
        x_auto               = ls_auto
        x_initial_uf_allowed = abap_true
      EXCEPTIONS
        invalid_key          = 1
        automation_error     = 2
        system_error         = 3
        OTHERS               = 4.
    IF sy-subrc <> 0.
      /adesso/cl_mdc_datex_utility=>enable_datex( iv_int_ui = is_proc_step_data-int_ui ).
      MESSAGE e041(/adesso/mdc_process) INTO gv_mtext.
      /idxgc/cx_utility_error=>raise_util_exception_from_msg( ).
    ENDIF.

    /adesso/cl_mdc_datex_utility=>enable_datex( iv_int_ui = is_proc_step_data-int_ui ).

  ENDMETHOD.


  METHOD /adesso/if_mdc_pro_chg~change_manual.

    CALL FUNCTION '/ADESSO/MDC_CHANGE_LPASSGN' STARTING NEW TASK 'MDC_CHANGE_LPASSGN'
      EXPORTING
        is_proc_step_data = is_proc_step_data.

  ENDMETHOD.


  METHOD set_lpassgn_data.

    INCLUDE iewmodes.

    CONSTANTS: co_one_day       TYPE date           VALUE '00000001',
               co_date_infinite TYPE isu_timesl-ab  VALUE '99991231',
               co_true(1)       TYPE c              VALUE 'X'.

    DATA:   lref_isu_extsynprofconv TYPE REF TO isu_extsynprofconv,
            l_badi_error            TYPE REF TO cx_badi_not_implemented,
            lref_isu_changedoc      TYPE REF TO isu_changedoc,
            ls_basic_data           TYPE eide_chngdoc_basic,
            lr_previous             TYPE REF TO cx_root.

    DATA:   lv_change     TYPE flag VALUE 'X'.
    DATA:   lv_loglprelno TYPE loglprelno.
    DATA:   ls_eprofhead  TYPE eprofhead.
    DATA:   lv_anlage     TYPE anlage.

    DATA:  ls_pod_quant TYPE /idxgc/s_pod_quant_details,
           ls_pod       TYPE /idxgc/s_pod_info_details,
           ls_diverse   TYPE /idxgc/s_diverse_details.

    DATA:  ls_ielpass_continued TYPE isulp_elpass_auto,
           ls_ielpass_auto_new  TYPE isulp_elpass_auto.

    FIELD-SYMBOLS:
      <ls_elpass_auto> TYPE isulp_elpass_auto.

    TRY.
        lv_anlage = /adesso/cl_mdc_masterdata=>get_anlage( iv_int_ui  = is_proc_step_data-int_ui
                                                          iv_keydate = is_proc_step_data-proc_date ).
      CATCH /idxgc/cx_general INTO gr_previous.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.

    READ TABLE is_proc_step_data-pod_quant  INTO ls_pod_quant INDEX 1.
    READ TABLE is_proc_step_data-diverse    INTO ls_diverse   INDEX 1.

    SORT cs_auto-ielpass_auto ASCENDING BY ab.
    CLEAR ls_ielpass_auto_new-loglprelno.
    ls_ielpass_auto_new-ab        =  ls_diverse-validstart_date.
    ls_ielpass_auto_new-bis       =  co_date_infinite.

    TRY.
        GET BADI lref_isu_extsynprofconv.
      CATCH cx_badi_not_implemented INTO l_badi_error.
    ENDTRY.
    CALL BADI lref_isu_extsynprofconv->get_synprof
      EXPORTING
        imp_extsynprofid = ls_diverse-prof_code_sy
        imp_keydate      = ls_diverse-validstart_date
        imp_int_ui       = is_proc_step_data-int_ui
      IMPORTING
        exp_profile      = ls_ielpass_auto_new-profile
      EXCEPTIONS
        not_found        = 1
        not_unique       = 2
        error_occurred   = 3
        OTHERS           = 4.
    IF sy-subrc <> 0.
    ENDIF.

    ls_basic_data-int_ui   = is_proc_step_data-int_ui.
    ls_basic_data-keydate  = ls_diverse-validstart_date.

    TRY.
        GET BADI lref_isu_changedoc.
      CATCH cx_badi_not_implemented INTO l_badi_error.
    ENDTRY.
    CALL BADI lref_isu_changedoc->get_lpassgnprofrole
      EXPORTING
        imp_basic_data   = ls_basic_data
        imp_dexdirection = cl_isu_datex_process=>co_dexdirection_import
      IMPORTING
        exp_profrole     = ls_ielpass_auto_new-profrole
      EXCEPTIONS
        error_occurred   = 1
        OTHERS           = 2.
    IF sy-subrc <> 0.
    ENDIF.


    IF ls_pod_quant-quantitiy_ext IS NOT INITIAL.
*   set new usage factor
      ls_ielpass_auto_new-usefactor = ls_pod_quant-quantitiy_ext.
    ELSE.
      ls_ielpass_auto_new-usefactor = 0.
*   determine usage factor to be reused
      LOOP AT cs_auto-ielpass_auto ASSIGNING <ls_elpass_auto>
        WHERE profile  = ls_ielpass_auto_new-profile.
*          AND profrole = ' '.
        IF ls_ielpass_auto_new-ab     >= <ls_elpass_auto>-ab
          AND ls_ielpass_auto_new-ab  <= <ls_elpass_auto>-bis.
          ls_ielpass_auto_new-usefactor = <ls_elpass_auto>-usefactor.
        ENDIF.
      ENDLOOP.
    ENDIF.


* check if entry for loglprelno respectively profile, profile allocation role in
* the given timeslice exists
    LOOP AT cs_auto-ielpass_auto ASSIGNING <ls_elpass_auto>.
      CHECK <ls_elpass_auto>-profrole = ls_ielpass_auto_new-profrole.

* Check if timeslices overlaps
* Existing |     <-------------------->         |     <-------------------->
* 1.) new  |<+++++++++>                       =>|<+++++++++><-------------->
* 2.) new  |<+++++++++++++++++++++++++++++++> =>|<+++++++++++++++++++++++++++++++>
* 3.) new  |                      <+++++++++> =>|     <---------------><+++++++++>
* 4.) new  |           <+++++++++>            =>|     <---><+++++++++><~~~~>
*
* --- old allocation, variable <l_isulp_elpass_auto>
* +++ new allocation, variable l_isulp_elpass_new
* ~~~ old allocation, variable l_isulp_elpass_continued
      IF ls_ielpass_auto_new-ab  <= <ls_elpass_auto>-ab
        AND ls_ielpass_auto_new-bis >= <ls_elpass_auto>-ab.
        IF ls_ielpass_auto_new-bis  < <ls_elpass_auto>-bis.
* case 1.)
          <ls_elpass_auto>-ab      = ls_ielpass_auto_new-bis + co_one_day.
          ls_ielpass_auto_new-loglprelno = <ls_elpass_auto>-loglprelno.
          ls_ielpass_auto_new-lprelno    = <ls_elpass_auto>-lprelno.
        ELSE.
* case 2.)
          ls_ielpass_auto_new-loglprelno = <ls_elpass_auto>-loglprelno.
          ls_ielpass_auto_new-lprelno    = <ls_elpass_auto>-lprelno.
          IF  ls_ielpass_auto_new = <ls_elpass_auto>.
*         nothing to change at all
            CLEAR lv_change.
            EXIT. " loop
          ELSE.
            DELETE cs_auto-ielpass_auto INDEX sy-tabix.
          ENDIF.
          CONTINUE.
        ENDIF.
      ENDIF.
      IF ls_ielpass_auto_new-ab  > <ls_elpass_auto>-ab
        AND ls_ielpass_auto_new-ab  <= <ls_elpass_auto>-bis.
        IF ls_ielpass_auto_new-bis  >= <ls_elpass_auto>-bis.
* case 3.)
          <ls_elpass_auto>-bis            = ls_ielpass_auto_new-ab - co_one_day.
          ls_ielpass_auto_new-loglprelno  = <ls_elpass_auto>-loglprelno.
          ls_ielpass_auto_new-lprelno     = <ls_elpass_auto>-lprelno.
        ELSE.
* case 4.)
          MOVE <ls_elpass_auto> TO ls_ielpass_continued.
          <ls_elpass_auto>-bis          = ls_ielpass_auto_new-ab   - co_one_day.
          ls_ielpass_continued-ab       = ls_ielpass_auto_new-bis  + co_one_day.
          ls_ielpass_auto_new-loglprelno    = <ls_elpass_auto>-loglprelno.
          ls_ielpass_auto_new-lprelno       = <ls_elpass_auto>-lprelno.
          APPEND ls_ielpass_continued TO cs_auto-ielpass_auto.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF lv_change = co_true.
*   Determine LPRELNO for new entry
      IF ls_ielpass_auto_new-lprelno IS INITIAL.
        IF lv_loglprelno IS INITIAL.
          READ TABLE cs_auto-ielpass_auto ASSIGNING <ls_elpass_auto>
               WITH KEY profile  = ls_ielpass_auto_new-profile
                        profrole = ls_ielpass_auto_new-profrole.
        ELSE.
          READ TABLE cs_auto-ielpass_auto ASSIGNING <ls_elpass_auto>
             WITH KEY loglprelno = lv_loglprelno.
        ENDIF.
        IF sy-subrc = 0.
*   Entry with same profile and profrole exists => use same LPRELNO
          ls_ielpass_auto_new-lprelno = <ls_elpass_auto>-lprelno.
        ELSE.
*   Entry with same profile and profrole does not exists => create new LPRELNO
          SORT cs_auto-ielpass_auto BY lprelno DESCENDING.
          READ TABLE cs_auto-ielpass_auto ASSIGNING <ls_elpass_auto> INDEX 1.
          IF sy-subrc = 0.
            ls_ielpass_auto_new-lprelno = <ls_elpass_auto>-lprelno + 1.
          ELSE.
            MOVE 1 TO ls_ielpass_auto_new-lprelno.
          ENDIF.
        ENDIF.
      ENDIF.
      APPEND ls_ielpass_auto_new TO cs_auto-ielpass_auto.

*   get division of profile
      CALL FUNCTION 'ISU_DB_EPROFHEAD_SINGLE'
        EXPORTING
          x_profile  = ls_ielpass_auto_new-profile
        IMPORTING
          y_profhead = ls_eprofhead
        EXCEPTIONS
          not_found  = 1
          OTHERS     = 2.
      IF sy-subrc <> 0.
*        MESSAGE e855(elp) RAISING error_occurred.
      ENDIF.

      SORT cs_auto-ielpass_auto BY lprelno bis.

      cs_auto-key-mandt   = sy-mandt.
      cs_auto-key-objtype = 'INSTLN'.
      cs_auto-key-objkey  = lv_anlage.
      cs_auto-key-sparte  = ls_eprofhead-sparte.
      cs_auto-wmode       = /idxgc/cl_pod_rel_access=>gc_change.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
