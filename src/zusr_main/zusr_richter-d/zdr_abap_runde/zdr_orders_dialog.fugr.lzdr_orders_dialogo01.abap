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
** Z14: Master Data for Point of Delivery
*    WHEN /idxgc/if_constants_ide=>gc_msg_category_z14.
*      SET TITLEBAR 'GUI_TITLE_100' WITH text-001.
** Z27: Transfer of Transaction Data
*    WHEN /idxgc/if_constants_ide=>gc_msg_category_z27.
*      SET TITLEBAR 'GUI_TITLE_100' WITH text-002.
** Z28: Transfer of Energy and Demand Maxima (related to Billing Period)
*    WHEN /idxgc/if_constants_ide=>gc_msg_category_z28.
*      SET TITLEBAR 'GUI_TITLE_100' WITH text-003.
* Z30: Master Data for Point of Delivery
    WHEN zdr_if_constants_ide=>gc_msg_category_z30.
      SET PF-STATUS '130'.
      SET TITLEBAR 'GUI_TITLE_100' WITH text-001.
* Z34: Transfer of Transaction Data
    WHEN zdr_if_constants_ide=>gc_msg_category_z34.
      SET PF-STATUS '134'.
      SET TITLEBAR 'GUI_TITLE_100' WITH text-002.
  ENDCASE.

ENDMODULE.                 " PBO_0100  OUTPUT
