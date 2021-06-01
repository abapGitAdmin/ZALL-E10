*----------------------------------------------------------------------*
***INCLUDE /ADESSO/LMDC_DISPLAYI01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9000 INPUT.

  DATA: lv_field TYPE string.

  CASE gv_ok_code.

    WHEN 'CANCEL'.
      CLEAR gv_respstatus.
      LEAVE TO SCREEN 0.

    WHEN 'EXIT'.
      CLEAR gv_respstatus.
      LEAVE TO SCREEN 0.

    WHEN 'KPF'.

      GET CURSOR FIELD lv_field.

      CASE lv_field.

        WHEN 'GS_HEADER_PROC-ASSOC_SERVPROV'.
          CALL FUNCTION 'ISU_S_EDMIDE_SERVPROV_DISPLAY'
            EXPORTING
              x_serviceid    = gs_header_proc-assoc_servprov
              x_no_change    = abap_true
              x_no_other     = abap_true
            EXCEPTIONS
              error_occurred = 1
              OTHERS         = 2.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno.
          ENDIF.

        WHEN 'GS_HEADER_PROC-OWN_SERVPROV'.
          CALL FUNCTION 'ISU_S_EDMIDE_SERVPROV_DISPLAY'
            EXPORTING
              x_serviceid    = gs_header_proc-own_servprov
              x_no_change    = abap_true
              x_no_other     = abap_true
            EXCEPTIONS
              error_occurred = 1
              OTHERS         = 2.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno.
          ENDIF.

        WHEN 'GS_HEADER_PROC-BU_PARTNER'.
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

        WHEN 'GS_HEADER_PROC-PROC_REF'.
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

        WHEN 'GS_HEADER_PROC-EXT_UI'.
          CALL FUNCTION 'ISU_S_UI_DISPLAY'
            EXPORTING
              x_int_ui     = gs_proc_step_data-int_ui
              x_keydate    = gs_proc_step_data-proc_date
              x_keytime    = '000000'
              x_no_change  = abap_true
              x_no_other   = abap_true
            EXCEPTIONS
              not_found    = 1
              system_error = 2
              OTHERS       = 3.

          IF sy-subrc <> 0.

            MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno.

          ENDIF.

        WHEN 'GS_HEADER_EMMA-CCAT'.

          IF NOT gs_header_emma-ccat IS INITIAL.

            AUTHORITY-CHECK OBJECT 'S_TCODE' ID 'TCD' FIELD 'EMMACCAT3'.

            IF sy-subrc <> 0.

              MESSAGE e003(emma).

            ELSE.

              SET PARAMETER ID 'EMMA_CCAT' FIELD gs_header_emma-ccat.

              CALL TRANSACTION 'EMMACCAT3' AND SKIP FIRST SCREEN.

            ENDIF.

          ENDIF.

      ENDCASE.

  ENDCASE.

  CLEAR gv_ok_code.

ENDMODULE.
