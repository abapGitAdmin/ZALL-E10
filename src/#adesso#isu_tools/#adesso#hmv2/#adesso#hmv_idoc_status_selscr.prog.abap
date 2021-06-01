*&---------------------------------------------------------------------*
*&  Include           /ADESSO/HMV_IDOC_STATUS_SELSCR
*&---------------------------------------------------------------------*

*>>> UH 20062012
TABLES: edextask, edextaskidoc, /adesso/hmv_cons.
*<<< UH 20062012

DATA: sel_datum    TYPE e_dexaedat,
      sel_provself TYPE e_dexservprovself,
      sel_intui    TYPE int_ui,
      sel_serve    TYPE e_dexservprov.


SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: so_datum FOR edextask-dexaedat DEFAULT '20000101' TO sy-datum OBLIGATORY.
SELECT-OPTIONS: so_taski FOR edextask-dextaskid.
SELECTION-SCREEN SKIP.
PARAMETERS: p_updm  AS CHECKBOX.
PARAMETERS: p_updd  AS CHECKBOX.
PARAMETERS: p_updms AS CHECKBOX.             "Nuss 09.2018

SELECTION-SCREEN BEGIN OF BLOCK bla WITH FRAME TITLE TEXT-018.
PARAMETERS  p_shoalv RADIOBUTTON GROUP aaw.
PARAMETERS: p_stat   RADIOBUTTON GROUP aaw.
PARAMETERS  p_noshow RADIOBUTTON GROUP aaw.
SELECTION-SCREEN END OF BLOCK bla.
SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE TEXT-002.
SELECT-OPTIONS: so_serv  FOR edextask-dexservprovself,
                so_serve FOR edextask-dexservprov,
                so_intui FOR edextask-int_ui.
SELECTION-SCREEN END OF BLOCK bl2.
SELECTION-SCREEN BEGIN OF BLOCK bl3 WITH FRAME TITLE TEXT-017.
PARAMETERS  p_maxpar type i.
SELECTION-SCREEN END OF BLOCK bl3.
