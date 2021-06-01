*----------------------------------------------------------------------*
***INCLUDE /ADESSO/LMDC_DISPLAYO01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9000 OUTPUT.

  SET PF-STATUS 'STATUS_9000'.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  INIT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE init OUTPUT.

  IF gr_custom_container IS INITIAL.
    CREATE OBJECT gr_custom_container
      EXPORTING
        container_name = 'ALV_CONTAINER'.

    CREATE OBJECT gr_grid
      EXPORTING
        i_parent = gr_custom_container.

    CLEAR gt_fieldcat.
    PERFORM modify_fieldcatalog.
  ENDIF.

  PERFORM load_data_into_grid.

  PERFORM set_layout_and_display.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  MODIFY_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_screen OUTPUT.

  CASE gs_proc_step_data-bmid.
    WHEN /idxgc/if_constants_ide=>gc_bmid_ch101 OR
         /idxgc/if_constants_ide=>gc_bmid_ch102 OR
         /idxgc/if_constants_ide=>gc_bmid_ch111 OR
         /idxgc/if_constants_ide=>gc_bmid_ch112 OR
         /idxgc/if_constants_ide=>gc_bmid_ch113 OR
         /idxgc/if_constants_ide=>gc_bmid_ch121 OR
         /idxgc/if_constants_ide=>gc_bmid_ch122 OR
         /idxgc/if_constants_ide=>gc_bmid_ch123 OR
         /idxgc/if_constants_ide=>gc_bmid_ch141 OR
         /idxgc/if_constants_ide=>gc_bmid_ch151 OR
         /idxgc/if_constants_ide=>gc_bmid_ch161 OR
         /idxgc/if_constants_ide=>gc_bmid_ch162 OR
         /idxgc/if_constants_ide=>gc_bmid_ch163 OR
         /idxgc/if_constants_ide=>gc_bmid_ch171 OR
         /idxgc/if_constants_ide=>gc_bmid_ch172.

      CONCATENATE icon_okay 'Zustimmen' 'E15' INTO gv_but7 SEPARATED BY space.

      LOOP AT SCREEN.
        IF screen-name = 'GV_BUT7'.
          screen-invisible = 0.
          MODIFY SCREEN.
        ELSEIF screen-name = 'GV_BUT5' OR screen-name = 'GV_BUT6'.
          screen-invisible = 1.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.

    WHEN /idxgc/if_constants_ide=>gc_bmid_ch221 OR
         /idxgc/if_constants_ide=>gc_bmid_ch222 OR
         /idxgc/if_constants_ide=>gc_bmid_ch225 OR
         /idxgc/if_constants_ide=>gc_bmid_ch226 OR
         /idxgc/if_constants_ide=>gc_bmid_ch251.

      CONCATENATE icon_ws_post 'Daten senden' 'ZG2' INTO gv_but7 SEPARATED BY space.

      LOOP AT SCREEN.
        IF screen-name = 'GV_BUT7'.
          screen-invisible = 0.
          MODIFY SCREEN.
        ELSEIF screen-name = 'GV_BUT5' OR screen-name = 'GV_BUT6'.
          screen-invisible = 1.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.

    WHEN /idxgc/if_constants_ide=>gc_bmid_ch131.

      CONCATENATE icon_red_xcircle 'Ablehnung' 'E13' INTO gv_but5 SEPARATED BY space.
      CONCATENATE icon_red_xcircle 'Ablehnung' 'ZE2' INTO gv_but6 SEPARATED BY space.
      CONCATENATE icon_okay 'Zustimmen' 'E15'        INTO gv_but7 SEPARATED BY space.

      LOOP AT SCREEN.
        IF screen-name = 'GV_BUT5' OR screen-name = 'GV_BUT6' OR screen-name = 'GV_BUT7'.
          screen-invisible = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.

    WHEN /idxgc/if_constants_ide=>gc_bmid_ch201 OR
         /idxgc/if_constants_ide=>gc_bmid_ch204 OR
         /idxgc/if_constants_ide=>gc_bmid_ch205 OR
         /idxgc/if_constants_ide=>gc_bmid_ch211 OR
         /idxgc/if_constants_ide=>gc_bmid_ch212 OR
         /idxgc/if_constants_ide=>gc_bmid_ch213 OR
         /idxgc/if_constants_ide=>gc_bmid_ch231 OR
         /idxgc/if_constants_ide=>gc_bmid_ch241 OR
         /idxgc/if_constants_ide=>gc_bmid_ch261 OR
         /idxgc/if_constants_ide=>gc_bmid_ch264 OR
         /idxgc/if_constants_ide=>gc_bmid_ch265.

      CONCATENATE icon_red_xcircle 'Ablehnung' 'ZG0' INTO gv_but6 SEPARATED BY space.
      CONCATENATE icon_okay 'Daten senden' 'ZG2'     INTO gv_but7 SEPARATED BY space.

      LOOP AT SCREEN.
        IF screen-name = 'GV_BUT6' OR screen-name = 'GV_BUT7'.
          screen-invisible = 0.
          MODIFY SCREEN.
        ELSEIF screen-name = 'GV_BUT5'.
          screen-invisible = 1.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.

    WHEN /idxgc/if_constants_ide=>gc_bmid_ch202 OR
         /idxgc/if_constants_ide=>gc_bmid_ch203 OR
         /idxgc/if_constants_ide=>gc_bmid_ch206 OR
         /idxgc/if_constants_ide=>gc_bmid_ch214 OR
         /idxgc/if_constants_ide=>gc_bmid_ch223 OR
         /idxgc/if_constants_ide=>gc_bmid_ch224 OR
         /idxgc/if_constants_ide=>gc_bmid_ch227 OR
         /idxgc/if_constants_ide=>gc_bmid_ch232 OR
         /idxgc/if_constants_ide=>gc_bmid_ch233 OR
         /idxgc/if_constants_ide=>gc_bmid_ch242 OR
         /idxgc/if_constants_ide=>gc_bmid_ch243 OR
         /idxgc/if_constants_ide=>gc_bmid_ch252.

      CONCATENATE icon_okay 'Daten übernommen' INTO gv_but7 SEPARATED BY space.

      LOOP AT SCREEN.
        IF screen-name = 'GV_BUT7'.
          screen-invisible = 0.
          MODIFY SCREEN.
        ELSEIF screen-name = 'GV_BUT5' OR screen-name = 'GV_BUT6'.
          screen-invisible = 1.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.

    WHEN /adesso/if_mdc_co=>gc_bmid_zch01.

      CONCATENATE icon_red_xcircle 'Ablehnung' 'ZE0' INTO gv_but6 SEPARATED BY space.
      CONCATENATE icon_okay 'Zustimmen' 'E15'        INTO gv_but7 SEPARATED BY space.

      LOOP AT SCREEN.
        IF screen-name = 'GV_BUT6' OR screen-name = 'GV_BUT7'.
          screen-invisible = 0.
          MODIFY SCREEN.
        ELSEIF screen-name = 'GV_BUT5'.
          screen-invisible = 1.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.

    WHEN OTHERS.
      LOOP AT SCREEN.
        IF screen-name = 'GV_BUT5' OR screen-name = 'GV_BUT6' OR screen-name = 'GV_BUT7'.
          screen-invisible = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
  ENDCASE.
ENDMODULE.
