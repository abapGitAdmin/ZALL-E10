*&---------------------------------------------------------------------*
*&  Include           /ADESSO/MTE_RELEVANT_NN_TOP
*&---------------------------------------------------------------------*

TABLES: /adesso/mte_rel.

* interne Tabelle und Arbeitsbereich zum Zwischenspeichern der
* ermittelten Relevanz
DATA: irel LIKE TABLE OF /adesso/mte_rel,
      wrel LIKE /adesso/mte_rel.

DATA: wa_head TYPE tinv_inv_head.

DATA: it_head TYPE STANDARD TABLE OF tinv_inv_head.


* Relevante Belege
DATA: BEGIN OF ihead OCCURS 0,
        int_inv_no LIKE tinv_inv_head-int_inv_no,
      END OF ihead.

DATA:       objcount TYPE i.



*----------------------------------------------------------------------
* SELEKTIONSBILDSCHIM
*----------------------------------------------------------------------
SELECTION-SCREEN BEGIN OF BLOCK aa WITH FRAME TITLE text-b02.
PARAMETERS: firma LIKE temfd-firma DEFAULT 'EGUT ' OBLIGATORY.
SELECTION-SCREEN SKIP.
PARAMETERS: lfdnr TYPE /adesso/mte_laufnr NO-DISPLAY.
SELECTION-SCREEN SKIP.
SELECTION-SCREEN END OF BLOCK aa.
