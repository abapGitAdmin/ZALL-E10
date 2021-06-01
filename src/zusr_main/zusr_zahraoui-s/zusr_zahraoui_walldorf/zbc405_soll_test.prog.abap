*&---------------------------------------------------------------------*
*& Report ZBC405_SOLL_TEST
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbc405_soll_test.


DATA: gs_spfli TYPE spfli.
CONSTANTS gc_mark VALUE 'X'.
*SELECTION-SCREEN BEGIN OF SCREEN 101  as SUBSCREEN.
*  select-OPTIONS:
*  so_id for gs_spfli-carrid,
*  so_co FOR gs_spfli-connid.
*  SELECTION-SCREEN END OF SCREEN 101.
*
*  SELECTION-SCREEN BEGIN OF SCREEN 102  as SUBSCREEN.
*  select-OPTIONS:
*  so_ci for gs_spfli-cityfrom,
*  so_to FOR gs_spfli-cityto.
*  SELECTION-SCREEN END OF SCREEN 102.


""" wieso wird nix angezeigt""


"für connection
SELECTION-SCREEN BEGIN OF SCREEN 1001 AS SUBSCREEN.
SELECT-OPTIONS:
so_fnr FOR gs_spfli-connid MEMORY ID car,
so_con FOR gs_spfli-connid.

SELECTION-SCREEN END OF SCREEN 1001.

" für Flüge

SELECTION-SCREEN BEGIN OF SCREEN 1002 AS SUBSCREEN.
SELECT-OPTIONS:

so_datu2 FOR gs_spfli-arrtime NO-EXTENSION.

SELECTION-SCREEN END OF SCREEN 1002 .


"output Parameter

SELECTION-SCREEN BEGIN OF SCREEN 1003 as SUBSCREEN.
  " übung 3 variantebis zeile48
SELECTION-SCREEN begin of BLOCK param.
  SELECTION-SCREEN begin of BLOCK ra WITH FRAME.


PARAMETERS:
  pa_kn1 RADIOBUTTON GROUP w,
  pa_kn2 RADIOBUTTON GROUP w,
  pa_kn3 RADIOBUTTON GROUP w DEFAULT 'X'.
SELECTION-SCREEN end of BLOCK ra.
PARAMETERS: so_land LIKE gs_spfli-countryfr.
SELECTION-SCREEN end of BLOCK param.
SELECTION-SCREEN END OF SCREEN 1003.


SELECTION-SCREEN BEGIN OF TABBED BLOCK ai
  FOR 5 LINES.
  SELECTION-SCREEN TAB (20) tab1 USER-COMMAND conn

  DEFAULT SCREEN 1001.

  SELECTION-SCREEN TAB (20) tab2 USER-COMMAND date

  DEFAULT SCREEN 1002.
  SELECTION-SCREEN TAB (20) tab3 USER-COMMAND type

  DEFAULT SCREEN 1003.

  SELECTION-SCREEN end of BLOCK ai.



START-OF-SELECTION.
CASE gc_mark.
  WHEN pa_kn1.

  SELECT * FROM spfli INTO gs_spfli
    WHERE carrid IN so_fnr
    AND fltime IN so_datu2
    AND arrtime IN so_datu2
    AND countryto <> spfli~countryfr
  .


    WRITE: / gs_spfli-connid,
             gs_spfli-carrid,
  "           gs_spfli-fldate,
             gs_spfli-countryfr,
             gs_spfli-airpfrom,
             gs_spfli-cityfrom,
             gs_spfli-countryto,
             gs_spfli-cityfrom,
             gs_spfli-airpto.


  ENDSELECT.

  WHEN pa_kn2.
     SELECT * FROM spfli INTO gs_spfli
    WHERE carrid IN so_fnr
    AND fltime IN so_datu2
    AND arrtime IN so_datu2
    AND countryto = spfli~countryfr
       AND countryto = pa_kn3.


           WRITE: / gs_spfli-connid,
             gs_spfli-carrid,
  "           gs_spfli-fldate,
             gs_spfli-countryfr,
             gs_spfli-airpfrom,
             gs_spfli-cityfrom,
             gs_spfli-countryto,
             gs_spfli-cityfrom,
             gs_spfli-airpto.
           ENDSELECT.
           WHEN pa_kn3.
             "radiobutton international ist markiert.

             SELECT * FROM spfli INTO gs_spfli
    WHERE carrid IN so_fnr
    AND connid IN so_con
    AND arrtime IN so_datu2
    AND countryto <> spfli~countryfr.

           WRITE: / gs_spfli-connid,
             gs_spfli-carrid,
  "           gs_spfli-fldate,
             gs_spfli-countryfr,
             gs_spfli-airpfrom,
             gs_spfli-cityfrom,
             gs_spfli-countryto,
             gs_spfli-cityfrom,
             gs_spfli-airpto.
           ENDSELECT.
           ENDCASE.


INCLUDE ZE01.
