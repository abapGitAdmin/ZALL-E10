*----------------------------------------------------------------------*
***INCLUDE /IDXGC/LORDERS_DIALOGO01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  PBO_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_0100 OUTPUT.

  SET PF-STATUS '100'.

*  CASE gv_doctype.
** Z14: Master Data for Point of Delivery
*    WHEN /idxgc/if_constants_ide=>gc_msg_category_z14.
*      SET TITLEBAR 'GUI_TITLE_100' WITH text-001.
** Z27: Transfer of Transaction Data
*    WHEN /idxgc/if_constants_ide=>gc_msg_category_z27.
*      SET TITLEBAR 'GUI_TITLE_100' WITH text-002.
** Z28: Transfer of Energy and Demand Maxima (related to Billing Period)
*    WHEN /idxgc/if_constants_ide=>gc_msg_category_z28.
*      SET TITLEBAR 'GUI_TITLE_100' WITH text-003.
*  ENDCASE.

  CASE gv_doctype.
*Z30 Änderung des Bilanzierungsverfahren
    WHEN 'Z30'.
      SET TITLEBAR 'GUI_TITLE_100' WITH TEXT-004.
*Z31 Änderung der Gerätekonfiguration
    WHEN 'Z31'.
      SET TITLEBAR 'GUI_TITLE_100' WITH TEXT-005.
*Z34 Reklamation von Lastgängen
    WHEN 'Z34'.
      SET TITLEBAR 'GUI_TITLE_100' WITH TEXT-006.
  ENDCASE.

ENDMODULE.                 " PBO_0100  OUTPUT
