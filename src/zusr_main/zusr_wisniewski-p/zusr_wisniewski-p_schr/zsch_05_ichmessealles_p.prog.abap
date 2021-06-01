*&---------------------------------------------------------------------*
*& Report ZSCH_05_ICHMESSEALLES_P
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsch_05_ichmessealles_p.

TYPES: gdt_laenge TYPE p LENGTH 3 DECIMALS 2.
TYPES: ldt_stuhl_hoehe TYPE p LENGTH 6 DECIMALS 2.
TYPES: BEGIN OF gst_buch,
         buch_titel TYPE string,
         anz_seiten TYPE zsch_05_td_anz_seiten,
       END OF gst_buch.
TYPES: gtt_buchregal TYPE STANDARD TABLE OF gst_buch WITH NON-UNIQUE DEFAULT KEY.
TYPES: gtt_buchregal_sortiert TYPE SORTED TABLE OF gst_buch WITH NON-UNIQUE SORTED KEY.
TYPES: gtt_buchregal_gehasht TYPE HASHED TABLE OF gst_buch WITH UNIQUE DEFAULT KEY.

DATA: gd_buch_seiten       TYPE zsch_05_td_anz_seiten,
      gd_stock_laenge      TYPE gdt_laenge VALUE '120.37',
      gd_peruecken_form    TYPE string,
      gd_peruecken_groesse TYPE i,
      gd_schritt_hoehe     TYPE f,
      gs_buch              TYPE gst_buch,
      gt_buchregal         TYPE TABLE OF gst_buch,
      gt_buchregal2        TYPE gtt_buchregal,
      gt_bibliothek        TYPE TABLE OF gst_buch.

gs_buch-buch_titel = 'Schrödinger programmiert ABAP'.

START-OF-SELECTION.
