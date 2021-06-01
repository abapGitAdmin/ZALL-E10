*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTE_ENTL_DEVINFOREC
*&
*&---------------------------------------------------------------------*
*&
*& Report zum Entladen von Geräteinfosatz-Daten
*&
*&---------------------------------------------------------------------*
REPORT /adesso/mte_entl_devinforec.


* Datendeklarationen
DATA: imeldung LIKE /adesso/mt_messages OCCURS 0 WITH HEADER LINE.
DATA: imig_err LIKE /adesso/mte_err OCCURS 0 WITH HEADER LINE.
DATA: ent_file TYPE emg_pfad.


DATA: cnt_index     TYPE i.
DATA: num_exp_file(2) TYPE n VALUE '01'.
DATA: cnt_exp_file  TYPE i.
DATA: counter       TYPE i.


DATA: anz_obj  TYPE i.
DATA: anz_dir  TYPE i.


DATA: i_equnr LIKE egerr-equnr OCCURS 0 WITH HEADER LINE.




* Selektionsbildschirm
** Grundeinstellungen (Firma, Exportpfad, Extension Export, Importpfad)
SELECTION-SCREEN BEGIN OF BLOCK a WITH FRAME TITLE text-b01.
SELECTION-SCREEN BEGIN OF BLOCK aa WITH FRAME TITLE text-b02.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(22) text-p01.
PARAMETERS: firma LIKE temob-firma DEFAULT 'SWL  ' OBLIGATORY.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK aa.
SELECTION-SCREEN BEGIN OF BLOCK ab WITH FRAME TITLE text-b03.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(22) text-p02.
PARAMETERS: exp_path LIKE temfd-path
    DEFAULT '/Mig/SWL_BI/Migration/Ent/'.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(22) text-p03.
PARAMETERS: exp_ext(3) TYPE c DEFAULT 'EXP'.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK ab.
SELECTION-SCREEN BEGIN OF BLOCK ac WITH FRAME TITLE text-bac.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(22) text-obz.
PARAMETERS: p_step(6) TYPE n DEFAULT '1000'.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(22) text-obd.
PARAMETERS: p_split(6) TYPE n.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK ac.
SELECTION-SCREEN END OF BLOCK a.

* Migrations-Objekte
SELECTION-SCREEN BEGIN OF BLOCK b WITH FRAME TITLE text-b05.
* Geräteinfosatz
SELECTION-SCREEN BEGIN OF BLOCK gdir WITH FRAME TITLE text-dir.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(18) text-obj.
PARAMETERS: dat_dir LIKE temfd-file DEFAULT 'DEVINFOREC'.
SELECTION-SCREEN COMMENT 42(12) text-001.
PARAMETERS: obj_dir AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK gdir.
SELECTION-SCREEN END OF BLOCK b.



*---------------------------------------------------------------------
*START-OF-SELECTION
*---------------------------------------------------------------------
START-OF-SELECTION.

  CLEAR: imig_err[].
  CLEAR cnt_index.


** Anlegen Geräteinfosatz
  IF obj_dir EQ 'X'.

* Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'DEVINFOREC'.

    PERFORM erst_entlade_files USING dat_dir.

* Schlüssel aus Relevanztabelle ermitteln
    SELECT obj_key FROM /adesso/mte_rel INTO TABLE i_equnr
                                  WHERE firma  = firma
                                  AND   object = 'DEVINFOREC'.
    IF sy-subrc NE 0.
      SKIP.
      WRITE: / 'keine Daten für Geräteinfosätze in Relevanztabelle gefunden'.
      EXIT.
    ELSE.
      IF NOT p_split IS INITIAL.
        REPLACE '.' WITH '01.' INTO ent_file.
      ENDIF.
      PERFORM open_entlade_file.
    ENDIF.

    LOOP AT i_equnr.

* Fuba Aufrufen
      CALL FUNCTION '/ADESSO/MTE_ENT_DEVINFOREC'
        EXPORTING
          firma              =  firma
          x_equnr            =  i_equnr
          pfad_dat_ent       =  ent_file
       IMPORTING
          anz_obj            =  anz_obj
       TABLES
          meldung            =  imeldung
       EXCEPTIONS
         no_open            = 1
         no_close           = 2
         wrong_data         = 3
         no_data            = 4
         error              = 5
         OTHERS             = 6.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'DEVINFOREC'.
          imig_err-obj_key = i_equnr.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_dir.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.

* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei.
      ENDIF.

    ENDLOOP.

*** Entladedatei schließen
    PERFORM close_entlade_file.

*** Fehlerauswertung
    SORT imig_err.
    DELETE ADJACENT DUPLICATES FROM imig_err COMPARING ALL FIELDS.

    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl Geräteinfosätze:', anz_dir.
    SKIP.
    WRITE: / 'Fehler bei Dateierstellung DEVINFOREC:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_dir.

  ENDIF.










*---------------------------------------------------------------------
*FORMS
*---------------------------------------------------------------------


*&---------------------------------------------------------------------*
*&      Form  del_entl_ksv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0229   text
*----------------------------------------------------------------------*
FORM del_entl_ksv USING    VALUE(obj).

  CALL FUNCTION '/ADESSO/MTE_OBJKEY_MAIN'
    EXPORTING
      i_firma                = firma
      i_object               = obj
*    I_OLDKEY               =
    EXCEPTIONS
      error                  = 1
      wrong_parameters       = 2
      OTHERS                 = 3
            .
  IF sy-subrc <> 0.
    MESSAGE i001(/adesso/mt_n) WITH 'Kein Objekt vorhanden zu' firma obj.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.



ENDFORM.                    " del_entl_ksv



*&---------------------------------------------------------------------*
*&      Form  erst_entlade_files
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DAT_BCN  text
*----------------------------------------------------------------------*
FORM erst_entlade_files USING    object_name.

  CONCATENATE exp_path object_name '.' exp_ext
        INTO ent_file.

ENDFORM.                    " erst_entlade_files


*&---------------------------------------------------------------------*
*&      Form  open_entlade_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM open_entlade_file .
  OPEN DATASET ent_file FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
  IF sy-subrc NE 0.
    CONCATENATE 'Datei' ent_file
    'konnte nicht geöffnet werden'
                       INTO imeldung-meldung SEPARATED BY space.
    APPEND imeldung.
    RAISE no_open.
  ENDIF.

ENDFORM.                    " open_entlade_file


*&---------------------------------------------------------------------*
*&      Form  neue_entlade_datei
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM neue_entlade_datei .

  PERFORM close_entlade_file.

*   Neuen Datei-Namen erstellen
  CLEAR cnt_exp_file.
  ADD 1 TO num_exp_file.

  SEARCH ent_file FOR '...'.
  IF sy-subrc NE 0.
    CONCATENATE 'Datei-Name' ent_file
     'konnte nicht für die Aufteilung erweitert werden'
                       INTO imig_err-meldung SEPARATED BY space.
    APPEND imeldung.
    RAISE no_open.
  ELSE.
    sy-fdpos = sy-fdpos - 2.
    REPLACE ent_file+sy-fdpos(2) WITH num_exp_file INTO ent_file.
  ENDIF.

  PERFORM open_entlade_file.

ENDFORM.                    " neue_entlade_datei


*&---------------------------------------------------------------------*
*&      Form  close_entlade_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM close_entlade_file .
  CLOSE DATASET ent_file.
  IF sy-subrc NE 0.
    CONCATENATE 'Datei' ent_file
     'konnte nicht geschlossen werden'
                       INTO imig_err-meldung SEPARATED BY space.
    APPEND imig_err.
    RAISE no_open.
  ENDIF.
ENDFORM.                    " close_entlade_file
