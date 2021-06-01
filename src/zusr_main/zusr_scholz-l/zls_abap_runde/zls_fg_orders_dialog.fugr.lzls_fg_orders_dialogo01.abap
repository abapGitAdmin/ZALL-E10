*----------------------------------------------------------------------*
***INCLUDE /IDXGC/LORDERS_DIALOGO01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  PBO_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_0100 OUTPUT.

*  SET PF-STATUS '100'.

  CASE gv_doctype.
* Z14: Master Data for Point of Delivery
    WHEN /idxgc/if_constants_ide=>gc_msg_category_z14.
      SET PF-STATUS '100'.
      SET TITLEBAR 'GUI_TITLE_100' WITH TEXT-001.
* Z27: Transfer of Transaction Data
    WHEN /idxgc/if_constants_ide=>gc_msg_category_z27.
      SET PF-STATUS '100'.
      SET TITLEBAR 'GUI_TITLE_100' WITH TEXT-002.
* Z28: Transfer of Energy and Demand Maxima (related to Billing Period)
    WHEN /idxgc/if_constants_ide=>gc_msg_category_z28.
      SET PF-STATUS '100'.
      SET TITLEBAR 'GUI_TITLE_100' WITH TEXT-003.
* z30: Änderung des Bilanzierungsverfahrens
    WHEN zls_if_constants_ide=>gc_zls_msg_category_z30.
      SET PF-STATUS '101'.
      SET TITLEBAR 'GUI_TITLE_100' WITH TEXT-004.
* z34: Reklamation von Lastgängen
    WHEN zls_if_constants_ide=>gc_zls_msg_category_z34.
      SET PF-STATUS '100'.
      SET TITLEBAR 'GUI_TITLE_100' WITH TEXT-005.
  ENDCASE.

ENDMODULE.                 " PBO_0100  OUTPUT
