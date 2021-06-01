*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTB_BEL_DEVICEREL
*&
*&---------------------------------------------------------------------*
*&
*& Report zum Beladen von Gerätezuordnungen
*&
*&---------------------------------------------------------------------*
REPORT /ADESSO/MTB_BEL_DEVICEREL.

*---------------------------------------------------------------------
* Datendeklaration
*---------------------------------------------------------------------
DATA ent_file TYPE emg_pfad.
DATA bel_file TYPE emg_pfad.

DATA: imeldung LIKE /adesso/mt_messages OCCURS 0 WITH HEADER LINE.
DATA: mig_err LIKE /adesso/mt_messages OCCURS 0 WITH HEADER LINE.

DATA: anz_dvr  TYPE i.


***********************************************************************
* Selektionsbildschirm                                                *
***********************************************************************

* Grundeinstellungen (Firma, Exportpfad, Extension Export, Importpfad)
SELECTION-SCREEN BEGIN OF BLOCK a WITH FRAME TITLE text-b01.
SELECTION-SCREEN BEGIN OF BLOCK aa WITH FRAME TITLE text-b02.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(22) text-p01.
PARAMETERS: firma LIKE temfd-firma DEFAULT 'NVB  ' OBLIGATORY.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK aa.

SELECTION-SCREEN BEGIN OF BLOCK ab WITH FRAME TITLE text-b03.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(22) text-p02.
PARAMETERS: exp_path LIKE temfd-path
    DEFAULT '/rkudat/rkumig/291/nvbmig/ent/'.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(22) text-p03.
PARAMETERS: exp_ext(3) TYPE c DEFAULT 'EXP'.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK ab.

SELECTION-SCREEN BEGIN OF BLOCK ac WITH FRAME TITLE text-b04.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(22) text-p04.
PARAMETERS: imp_path LIKE temfd-path
    DEFAULT '/rkudat/rkumig/291/nvbmig/bel/'.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(22) text-p05.
PARAMETERS: imp_ext(3) TYPE c DEFAULT 'IMP'.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK ac.
SELECTION-SCREEN END OF BLOCK a.

* Migrations-Objekte
SELECTION-SCREEN BEGIN OF BLOCK b WITH FRAME TITLE text-b05.
* Gerätezuordnungen
SELECTION-SCREEN BEGIN OF BLOCK bdvr WITH FRAME TITLE text-dvr.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(18) text-obj.
PARAMETERS: dat_dvr LIKE temfd-file DEFAULT 'DEVICEREL'.
SELECTION-SCREEN COMMENT 42(12) text-001.
PARAMETERS: obj_dvr AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK bdvr.
SELECTION-SCREEN END OF BLOCK b.


*---------------------------------------------------------------------
*START-OF-SELECTION
*---------------------------------------------------------------------
START-OF-SELECTION.

*DEVINFOREC	Anlegen: Geräteinfosatz
  IF obj_dvr EQ 'X'.

    PERFORM be_und_entlade_files USING dat_dvr.
    CALL FUNCTION '/ADESSO/MTB_BEL_DEVICEREL'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_dvr
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
      WRITE: / 'Anzahl Gerätezuordnungen:', anz_dvr.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung DEVICEREL:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Gerätezuordnungen:', anz_dvr.
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
