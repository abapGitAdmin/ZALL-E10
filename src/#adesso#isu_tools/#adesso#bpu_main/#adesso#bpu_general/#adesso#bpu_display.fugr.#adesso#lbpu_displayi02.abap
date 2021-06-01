*----------------------------------------------------------------------*
***INCLUDE /ADESSO/LBPU_DISPLAYI02.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9010  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9010 INPUT.

  CASE gv_ok_code.

    WHEN 'RA_REASON'.

      IF gv_rbutton_z12 = abap_true.

        gv_subscreen_9010 = /adesso/if_bpu_co=>gc_disp_subscreen_9011.

      ELSEIF gv_rbutton_e14 = abap_true.

        gv_subscreen_9010 = /adesso/if_bpu_co=>gc_disp_subscreen_9012.

      ELSEIF gv_rbutton_e15 = abap_true.

        gv_subscreen_9010 = /adesso/if_bpu_co=>gc_disp_subscreen_9013.

      ENDIF.

    WHEN 'OK'.

      IF gv_rbutton_z12 = abap_true.

        IF gv_endnextposs_from IS INITIAL.

          MESSAGE i020(/adesso/bpu_general) DISPLAY LIKE 'E'.

        ELSE.

          gs_return-type = 'RESPSTATUS'.
          gs_return-value = /idxgc/if_constants_ide=>gc_respstatus_z12.
          APPEND gs_return TO gt_return.

          gs_return-type = 'ENDNEXTPOSS_FROM'.
          gs_return-value = gv_endnextposs_from.
          APPEND gs_return TO gt_return.

          gs_return-type = 'FRIST'.
          gs_return-value = gv_frist_z12.
          APPEND gs_return TO gt_return.

          gv_ok_code = 'EXIT'.

        ENDIF.

      ELSEIF gv_rbutton_e14 = abap_true.

        IF gv_free_text_value IS INITIAL.

          MESSAGE i021(/adesso/bpu_general) DISPLAY LIKE 'E'.

        ELSE.

          gs_return-type = 'RESPSTATUS'.
          gs_return-value = /idxgc/if_constants_ide=>gc_respstatus_e14.
          APPEND gs_return TO gt_return.

          gs_return-type = 'FREE_TEXT_VALUE'.
          gs_return-value = gv_free_text_value.
          APPEND gs_return TO gt_return.

          gv_ok_code = 'EXIT'.

        ENDIF.

      ELSEIF gv_rbutton_e15 = abap_true.

        gs_return-type = 'RESPSTATUS'.
        gs_return-value = /idxgc/if_constants_ide=>gc_respstatus_e15.
        APPEND gs_return TO gt_return.

        gv_ok_code = 'EXIT'.

      ENDIF.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_9010  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9010 OUTPUT.

  IF gv_subscreen_9010 IS INITIAL.

    gv_subscreen_9010 = /adesso/if_bpu_co=>gc_disp_subscreen_9011.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9020  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9020 INPUT.

  CASE gv_ok_code.

    WHEN 'RA_REASON'.

      IF gv_rbutton_z01 = abap_true.

        gv_subscreen_9020 = /adesso/if_bpu_co=>gc_disp_subscreen_9021.

      ELSEIF gv_rbutton_e14 = abap_true.

        gv_subscreen_9020 = /adesso/if_bpu_co=>gc_disp_subscreen_9012.

      ENDIF.

    WHEN 'OK'.

      IF gv_rbutton_z01 = abap_true.

        IF gv_endnextposs_from IS INITIAL.

          MESSAGE i020(/adesso/bpu_general) DISPLAY LIKE 'E'.

        ELSE.

          gs_return-type = 'RESPSTATUS'.
          gs_return-value = /idxgc/if_constants_ide=>gc_respstatus_z01.
          APPEND gs_return TO gt_return.

          gs_return-type = 'ENDNEXTPOSS_FROM'.
          gs_return-value = gv_endnextposs_from.
          APPEND gs_return TO gt_return.

          gv_ok_code = 'EXIT'.

        ENDIF.

      ELSEIF gv_rbutton_e14 = abap_true.

        IF gv_free_text_value IS INITIAL.

          MESSAGE i021(/adesso/bpu_general) DISPLAY LIKE 'E'.

        ELSE.

          gs_return-type = 'RESPSTATUS'.
          gs_return-value = /idxgc/if_constants_ide=>gc_respstatus_e14.
          APPEND gs_return TO gt_return.

          gs_return-type = 'FREE_TEXT_VALUE'.
          gs_return-value = gv_free_text_value.
          APPEND gs_return TO gt_return.

          gv_ok_code = 'EXIT'.

        ENDIF.

      ENDIF.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_9020  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9020 OUTPUT.

  IF gv_subscreen_9020 IS INITIAL.

    gv_subscreen_9020 = /adesso/if_bpu_co=>gc_disp_subscreen_9021.

  ENDIF.

ENDMODULE.
