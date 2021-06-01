*&---------------------------------------------------------------------*
*& Report  /ADESSO/INKASSO_MONITOR
*&
*&---------------------------------------------------------------------*
REPORT /adesso/wo_monitor MESSAGE-ID /adesso/wo_mon.

INCLUDE /adesso/wo_monitor_top.

INCLUDE /adesso/wo_monitor_scr.

************************************************************************
* INITIALIZATION
************************************************************************
INITIALIZATION.

  PERFORM alv_variant_init.

*  PERFORM get_cust_begru.

*********************************************************************************
* Process on value request
*********************************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM f4_for_variant CHANGING p_vari.

**************************************************************************
* AT SELECTION-SCREEN OUTPUT
**************************************************************************
AT SELECTION-SCREEN OUTPUT.


**************************************************************************
* START-OF-SELECTION
**************************************************************************
START-OF-SELECTION.

  PERFORM get_customizing.

*  PERFORM pre_select.
*  CHECK gt_gpvk[] IS NOT INITIAL.

  PERFORM select_womon_req.
  PERFORM select_womon_ink.
  PERFORM prepare_output.



**************************************************************************
* END-OF-SELECTION
**************************************************************************
END-OF-SELECTION.

  PERFORM alv_init.

  SORT gt_header BY vkont ASCENDING.
  SORT gt_items  BY vkont ASCENDING hvorg DESCENDING faedn ASCENDING.

  LOOP AT gt_header ASSIGNING <gs_header>.

    AT NEW vkont.

      CLEAR gv_info.
      CALL FUNCTION 'ENQUEUE_/ADESSO/WOMON'
        EXPORTING
          mode_/adesso/wo_enqu = 'X'
          wo_proc              = '01'
          vkont                = <gs_header>-vkont
          x_bukrs              = ' '
          _scope               = '1'
          _wait                = ' '
          _collect             = ' '
        EXCEPTIONS
          foreign_lock         = 1
          system_failure       = 2
          OTHERS               = 3.

      CASE sy-subrc.
        WHEN 1.
          CONCATENATE TEXT-spo sy-msgv1
                      INTO gv_info
                      SEPARATED BY space.
          CALL FUNCTION 'ICON_CREATE'
            EXPORTING
              name                  = 'ICON_USER_BREAKPOINT'
              info                  = gv_info
            IMPORTING
              result                = <gs_header>-locked
            EXCEPTIONS
              icon_not_found        = 1
              outputfield_too_short = 2
              OTHERS                = 3.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.
        WHEN 2.
        WHEN OTHERS.

      ENDCASE.
    ENDAT.

  ENDLOOP.

  PERFORM alv_display.


**************************************************************************
* INCLUDES
**************************************************************************
  INCLUDE /adesso/wo_monitor_alv_falv.

  INCLUDE /adesso/wo_monitor_f01.

  INCLUDE /adesso/wo_monitor_u01.

INCLUDE /adesso/wo_monitor_o01.

INCLUDE /adesso/wo_monitor_i01.
