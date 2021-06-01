*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTD_BEL_DEVGRP
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT /ADESSO/MTD_BEL_DEVGRP.


*---------------------------------------------------------------------
* Datendeklaration
*---------------------------------------------------------------------

DATA ent_file TYPE emg_pfad.
DATA bel_file TYPE emg_pfad.

DATA: imeldung LIKE /adesso/mt_messages OCCURS 0 WITH HEADER LINE.

DATA: counter   TYPE i.
DATA: cnt_index TYPE i.


DATA: anz_obj TYPE i.
DATA: anz_dgr TYPE i.

DATA: mig_err LIKE /adesso/mt_messages OCCURS 0 WITH HEADER LINE.


*---------------------------------------------------------------------
* SELEKTION
*---------------------------------------------------------------------
* Grundeinstellungen (Firma, Exportpfad, Extension Export, Importpfad)
SELECTION-SCREEN BEGIN OF BLOCK a WITH FRAME TITLE text-b01.
SELECTION-SCREEN BEGIN OF BLOCK aa WITH FRAME TITLE text-b02.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(22) text-p01.
PARAMETERS: firma LIKE temob-firma DEFAULT 'EVU02' OBLIGATORY.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK aa.
SELECTION-SCREEN BEGIN OF BLOCK ab WITH FRAME TITLE text-b03.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(22) text-p02.
PARAMETERS: exp_path LIKE temfd-path
    DEFAULT '/migp1u/evuit/prode/'.
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
    DEFAULT '/migp1u/evuit/prod1/'.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(22) text-p05.
PARAMETERS: imp_ext(3) TYPE c DEFAULT 'IMP'.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK ac.

SELECTION-SCREEN END OF BLOCK a.


SELECTION-SCREEN BEGIN OF BLOCK b WITH FRAME TITLE text-b05.
*Gerätegruppierung
SELECTION-SCREEN BEGIN OF BLOCK bdgr WITH FRAME TITLE text-dgr.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(18) text-obj.
PARAMETERS: dat_dgr LIKE temfd-file DEFAULT 'DEVGRP'.
SELECTION-SCREEN COMMENT 42(12) text-001.
PARAMETERS: obj_dgr AS CHECKBOX.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK bdgr.

SELECTION-SCREEN END OF BLOCK b.



*---------------------------------------------------------------------
* START-OF-SELECTION
*---------------------------------------------------------------------
START-OF-SELECTION.


*DEVGRP	Gerätegruppe Anlegen
  IF obj_dgr EQ 'X'.

    PERFORM be_und_entlade_files USING dat_dgr.
* fuba-aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_DEVGRP'
         EXPORTING
              firma        = firma
              pfad_dat_ent = ent_file
              pfad_dat_bel = bel_file
         IMPORTING
              anz_obj      = anz_dgr
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
      WRITE: / 'Anzahl Gerätegruppierungen:', anz_dgr.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung DEVGRP:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Gerätegruppierungen:', anz_dgr.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.


  ENDIF.






*
*&---------------------------------------------------------------------*
*&      Form  be_und_entlade_files
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DAT_DGR  text
*----------------------------------------------------------------------*
form be_und_entlade_files USING    object_name.

  CONCATENATE exp_path object_name '.' exp_ext
        INTO ent_file.
  CONCATENATE imp_path object_name '.' imp_ext
        INTO bel_file.


endform.                    " be_und_entlade_files
