*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTD_CUSTOMIZE_REL
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT /ADESSO/MTD_CUSTOMIZE_REL.

DATA: BEGIN OF wa_insert,
        mandt    TYPE sy-mandt,
        firma    TYPE emg_firma,
        lfdnr    TYPE /adesso/mte_laufnr,
        sign     TYPE vvssign,
        option   TYPE bapioption,
        low(20)  TYPE c,
        high(20) TYPE c,
      END OF wa_insert.


************************************************************************
* Selektionsbildschirm                                                 *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-001.

PARAMETERS: firma   TYPE emg_firma DEFAULT 'AELIM',
            lfdnr   TYPE /adesso/mte_laufnr,
            sign    TYPE vvssign,
            option  TYPE bapioption,
            low(20) TYPE c,
            high(20) TYPE c.

SELECTION-SCREEN SKIP.
PARAMETERS: table TYPE tddat-tabname.

SELECTION-SCREEN END OF BLOCK bl1.

**************************************************************************
* START-OF-SELECTION                                                     *
**************************************************************************
START-OF-SELECTION.
  wa_insert-mandt = sy-mandt.
  wa_insert-firma = firma.
  wa_insert-lfdnr = lfdnr.
  wa_insert-sign = sign.
  wa_insert-option = option.
  wa_insert-low = low.
  wa_insert-high = high.


* Update der Tabelle mit Modify, da dies ein INSERT und UPDATE kombiniert
  MODIFY (table) FROM wa_insert.


  IF sy-subrc = 0.
    WRITE: /5 'Tabelle', table, 'wurde upgedatet'.
  ELSE.
    WRITE: /5 'Fehler beim Update von Tabelle', table.
  ENDIF.
