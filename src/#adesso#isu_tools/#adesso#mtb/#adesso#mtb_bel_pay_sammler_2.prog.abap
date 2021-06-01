*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTB_BEL_PAY_SAMMLER_2
*&
*&---------------------------------------------------------------------*
*& Report zum Beladen von Payment Sammler
*&---------------------------------------------------------------------*
REPORT /ADESSO/MTB_BEL_PAY_SAMMLER_2.
* Datendeklaration
*---------------------------------------------------------------------
DATA ent_file TYPE emg_pfad.
DATA bel_file TYPE emg_pfad.

DATA: imeldung LIKE /adesso/mt_messages OCCURS 0 WITH HEADER LINE.
DATA: mig_err LIKE /adesso/mt_messages OCCURS 0 WITH HEADER LINE. "#EC NEEDED

DATA: anz_pay  TYPE i.

***********************************************************************
* Selektionsbildschirm                                                *
***********************************************************************

* Grundeinstellungen (Firma, Exportpfad, Extension Export, Importpfad)
SELECTION-SCREEN BEGIN OF BLOCK a WITH FRAME TITLE text-y01.
SELECTION-SCREEN BEGIN OF BLOCK aa WITH FRAME TITLE text-y02.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(22) text-z01.
PARAMETERS: firma LIKE temfd-firma DEFAULT 'SWL  ' OBLIGATORY.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK aa.

SELECTION-SCREEN BEGIN OF BLOCK ab WITH FRAME TITLE text-y03.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(22) text-z02.
PARAMETERS: exp_path LIKE temfd-path
    DEFAULT '/Mig/SWL_BI/Migration/Ent/'.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(22) text-z03.
PARAMETERS: exp_ext(3) TYPE c DEFAULT 'EXP'.


SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK ab.

SELECTION-SCREEN BEGIN OF BLOCK ac WITH FRAME TITLE text-y04.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(22) text-z04.
PARAMETERS: imp_path LIKE temfd-path
    DEFAULT '/Mig/SWL_BI/Migration/Bel/'.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(22) text-z05.
PARAMETERS: imp_ext(3) TYPE c DEFAULT 'IMP'.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK ac.
SELECTION-SCREEN END OF BLOCK a.

* Migrations-Objekte
SELECTION-SCREEN BEGIN OF BLOCK b WITH FRAME TITLE text-y05.
* PAY_SAM
*SELECTION-SCREEN BEGIN OF BLOCK bdir WITH FRAME TITLE text-dir.
SELECTION-SCREEN BEGIN OF BLOCK bdir WITH FRAME TITLE text-di1.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(18) text-obj.
PARAMETERS: dat_pay LIKE temfd-file DEFAULT 'PAYSAM'.
SELECTION-SCREEN COMMENT 42(12) text-001.
PARAMETERS: obj_pay AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK bdir.
SELECTION-SCREEN END OF BLOCK b.
*---------------------------------------------------------------------
*START-OF-SELECTION
*---------------------------------------------------------------------
START-OF-SELECTION.

*PAYSAM#Anlegen: PAYMENTS für Sammler
  IF obj_pay EQ 'X'.

    PERFORM be_und_entlade_files USING dat_pay.

    CALL FUNCTION '/ADESSO/MTB_BEL_PAYSAM'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_pay
      TABLES
        meldung      = imeldung
      EXCEPTIONS
        no_open      = 1
        no_close     = 2
        wrong_data   = 3
        gen_error    = 4
        error        = 5
        OTHERS       = 6.

      IF sy-subrc <> 0.
        APPEND LINES OF imeldung TO mig_err.
        WRITE: / 'Anzahl PAYSAM:', anz_pay.
        SKIP.
        WRITE: / 'Meldung bei Dateierstellung PAYSAM:'.
        LOOP AT imeldung.
          WRITE: / imeldung-meldung.
        ENDLOOP.
      ELSE.
        WRITE: / 'Anzahl PAYSAM:', anz_pay.
        LOOP AT imeldung.
          WRITE: / imeldung-meldung.
        ENDLOOP.
      ENDIF.


  ENDIF.


*&---------------------------------------------------------------------*
*&      Form  be_und_entlade_files
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DAT_INF  text
*----------------------------------------------------------------------*
FORM be_und_entlade_files  USING    object_name.

  CONCATENATE exp_path object_name '.' exp_ext
        INTO ent_file.
  CONCATENATE imp_path object_name '.' imp_ext
        INTO bel_file.

ENDFORM.                    " be_und_entlade_files
