*----------------------------------------------------------------------*
***INCLUDE /adz/LMDC_DISPLAYI01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9000 INPUT.
  DATA: lr_badi_ref TYPE REF TO cl_badi_base,
        lt_rows     TYPE lvc_t_row,
        lv_offset   TYPE i,
        lv_field    TYPE string.

  FIELD-SYMBOLS: <fs_check_details>    TYPE /idxgc/s_check_details,
                 <fs_proc_step_values> TYPE /idxgc/s_proc_step_value,
                 <fs_row>              TYPE lvc_s_row,
                 <fs_seltab>           TYPE ts_seltab.

  CLEAR: lt_rows.
  CASE gv_ok_code.

    WHEN 'EXIT'.
      gr_custom_container->free( ).
      LEAVE TO SCREEN 0.

***** Automatisch ändern **************************************************************************
    WHEN 'BTN1'.
      CALL METHOD gr_grid->get_selected_rows IMPORTING et_index_rows = lt_rows.
      IF lines( lt_rows ) = 0.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT' EXPORTING textline1 = gc_text_mark_one_line.
        EXIT.
      ELSE.
        READ TABLE lt_rows ASSIGNING <fs_row> INDEX 1.
        READ TABLE gt_seltab ASSIGNING <fs_seltab> INDEX <fs_row>-index.
        IF <fs_seltab> IS ASSIGNED AND <fs_seltab>-badi_name IS NOT INITIAL.
          TRY.
              GET BADI lr_badi_ref TYPE (<fs_seltab>-badi_name)
                FILTERS mandt = sy-mandt
                        sysid = sy-sysid.
              gs_proc_step_data_src_add-mtd_code_result = gs_proc_step_data-mtd_code_result.
              gs_proc_step_data_src_add-docname_code    = gs_proc_step_data-docname_code.
              CALL BADI lr_badi_ref->('CHANGE_AUTO')
                EXPORTING
                  is_proc_step_data     = gs_proc_step_data_src_add "Ursprüngliche Nachricht
                  is_proc_step_data_src = gs_proc_step_data.
            CATCH cx_badi_not_implemented.
              MESSAGE i071(/adz/mdc_process).
            CATCH /idxgc/cx_utility_error.
              MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDTRY.
          PERFORM reload_alv_grid.
          CALL METHOD gr_grid->refresh_table_display( ).
        ELSE.
          MESSAGE i071(/adz/mdc_process).
        ENDIF.
      ENDIF.

***** Manuell ändern ******************************************************************************
    WHEN 'BTN2'.
      CALL METHOD gr_grid->get_selected_rows IMPORTING et_index_rows = lt_rows.
      IF lines( lt_rows ) = 0.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT' EXPORTING textline1 = gc_text_mark_one_line.
        EXIT.
      ELSE.
        READ TABLE lt_rows ASSIGNING <fs_row> INDEX 1.
        READ TABLE gt_seltab ASSIGNING <fs_seltab> INDEX <fs_row>-index.
        IF <fs_seltab> IS ASSIGNED AND <fs_seltab>-badi_name IS NOT INITIAL.
          TRY.
              GET BADI lr_badi_ref TYPE (<fs_seltab>-badi_name)
                FILTERS mandt = sy-mandt
                        sysid = sy-sysid.
              CALL BADI lr_badi_ref->('CHANGE_MANUAL') EXPORTING is_proc_step_data = gs_proc_step_data.
            CATCH cx_badi_not_implemented.
              MESSAGE i070(/adz/mdc_process).
            CATCH /idxgc/cx_utility_error.
              MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDTRY.
          PERFORM reload_alv_grid.
          CALL METHOD gr_grid->refresh_table_display( ).
        ELSE.
          MESSAGE i070(/adz/mdc_process).
        ENDIF.
      ENDIF.

***** Aktualisieren *******************************************************************************
    WHEN 'BTN3'.
      PERFORM reload_alv_grid.
      CALL METHOD gr_grid->refresh_table_display( ).

***** Schließen ***********************************************************************************
    WHEN 'BTN4'.
      gr_custom_container->free( ).
      LEAVE TO SCREEN 0.

***** Ablehnungsgrund 1 ***************************************************************************
    WHEN 'BTN5'.
      SORT gs_proc_step_data-check BY check_counter DESCENDING.
      READ TABLE gs_proc_step_data-check ASSIGNING <fs_check_details> INDEX 1.

      lv_offset = strlen( gv_but5 ) - 3.
      <fs_check_details>-rejection_code  = gv_but5+lv_offset(3).

      IF <fs_check_details>-rejection_code = /idxgc/if_constants_ide=>gc_respstatus_e13 .
        <fs_check_details>-proc_step_value = /adz/if_mdc_co=>gc_cr-no_accept.
        APPEND INITIAL LINE TO gs_proc_step_data-proc_step_values ASSIGNING <fs_proc_step_values>.
        <fs_proc_step_values> = /adz/if_mdc_co=>gc_cr-no_accept.
      ENDIF.

*IR---> übernommen aus dem adz-Paket: BAdI entfernt
*      IF gr_badi_mdc_pro_show_disp IS BOUND.
*        CALL BADI gr_badi_mdc_pro_show_disp->btn5_action.
*      ENDIF.

      gr_custom_container->free( ).
      LEAVE TO SCREEN 0.

***** Ablehnungsgrund 2 ***************************************************************************
    WHEN 'BTN6'.
      SORT gs_proc_step_data-check BY check_counter DESCENDING.
      READ TABLE gs_proc_step_data-check ASSIGNING <fs_check_details> INDEX 1.

      lv_offset = strlen( gv_but6 ) - 3.
      <fs_check_details>-rejection_code  = gv_but6+lv_offset(3).

      IF <fs_check_details>-rejection_code = /idxgc/if_constants_ide=>gc_respstatus_ze2.
        <fs_check_details>-proc_step_value = /adz/if_mdc_co=>gc_cr-no_accept.
        APPEND /adz/if_mdc_co=>gc_cr-no_accept TO gs_proc_step_data-proc_step_values.
      ELSEIF  <fs_check_details>-rejection_code = /idxgc/if_constants_add=>gc_response_code_zg0.
        <fs_check_details>-proc_step_value = /idxgc/if_constants_add=>gc_cr_data_not_at_pod.
        APPEND /idxgc/if_constants_add=>gc_cr_data_not_at_pod TO gs_proc_step_data-proc_step_values.
      ENDIF.
*IR---> übernommen aus dem adz-Paket: BAdI entfernt
*      IF gr_badi_mdc_pro_show_disp IS BOUND.
*        CALL BADI gr_badi_mdc_pro_show_disp->btn6_action.
*      ENDIF.

      gr_custom_container->free( ).
      LEAVE TO SCREEN 0.

***** Zustimmen bzw. Daten senden *****************************************************************
    WHEN 'BTN7'.
      SORT gs_proc_step_data-check BY check_counter DESCENDING.
      READ TABLE gs_proc_step_data-check ASSIGNING <fs_check_details> INDEX 1.

      lv_offset = strlen( gv_but7 ) - 3.
      <fs_check_details>-rejection_code = gv_but7+lv_offset(3).

      IF <fs_check_details>-rejection_code = /idxgc/if_constants_add=>gc_reason_confirmation.
        <fs_check_details>-proc_step_value = /idxgc/if_constants_add=>gc_cr_accept.
        APPEND /idxgc/if_constants_add=>gc_cr_accept TO gs_proc_step_data-proc_step_values.
      ELSEIF <fs_check_details>-rejection_code = /idxgc/if_constants_add=>gc_response_code_zg2.
        <fs_check_details>-proc_step_value = /adz/if_mdc_co=>gc_cr-send_valid_data.
        APPEND /adz/if_mdc_co=>gc_cr-send_valid_data TO gs_proc_step_data-proc_step_values.
      ENDIF.

*IR---> übernommen aus dem adz-Paket: BAdI entfernt
*      IF gr_badi_mdc_pro_show_disp IS BOUND.
*        CALL BADI gr_badi_mdc_pro_show_disp->btn7_action.
*      ENDIF.

      gr_custom_container->free( ).
      LEAVE TO SCREEN 0.

    WHEN 'KPF'.
      GET CURSOR FIELD lv_field.
      CASE lv_field.
        WHEN 'GS_HEADER-BU_PARTNER'.
          CALL FUNCTION 'ISU_S_PARTNER_DISPLAY'
            EXPORTING
              x_partner      = gs_proc_step_data-bu_partner
            EXCEPTIONS
              not_found      = 1
              general_fault  = 2
              not_authorized = 3
              cancelled      = 4
              dpp            = 5
              OTHERS         = 6.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno.
          ENDIF.
        WHEN 'GS_HEADER-PROC_REF'.
          CALL FUNCTION '/IDXGC/FM_PDOC_DISPLAY'
            EXPORTING
              x_switchnum    = gs_proc_step_data-proc_ref
            EXCEPTIONS
              general_fault  = 1
              not_found      = 2
              not_authorized = 3
              OTHERS         = 4.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno.
          ENDIF.
        WHEN 'GS_HEADER-EXT_UI'.
          CALL FUNCTION 'ISU_S_UI_DISPLAY'
            EXPORTING
              x_int_ui     = gs_proc_step_data-int_ui
              x_keydate    = gs_proc_step_data-proc_date
              x_keytime    = '000000'
              x_no_change  = 'X'
              x_no_other   = 'X'
            EXCEPTIONS
              not_found    = 1
              system_error = 2
              OTHERS       = 3.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno.
          ENDIF.
      ENDCASE.
  ENDCASE.
  CLEAR gv_ok_code.

ENDMODULE.
