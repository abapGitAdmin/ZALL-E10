*----------------------------------------------------------------------*
***INCLUDE /ADESSO/WO_MONITOR_O01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_9100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9100 OUTPUT.
  SET PF-STATUS 'STATUS_9100'.
  SET TITLEBAR  '9100'.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  INIT_9100  OUTPUT
*&---------------------------------------------------------------------*
MODULE init_9100 OUTPUT.

  CASE sy-xcode.
    WHEN 'ALLOW'.                     "Genehmigung
      /adesso/wo_req-tcheader = text-008.
    WHEN 'CORRECT'.                   "Zur Korrektur
      /adesso/wo_req-tcheader = text-010.
    WHEN 'DECL'.                      "Ablehnung
      /adesso/wo_req-tcheader = text-009.
  ENDCASE.

ENDMODULE.
