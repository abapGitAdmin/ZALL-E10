*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTE_ENTL_DEVICE_LAGER
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT /adesso/mte_entl_device_lager.

*---------------------------------------------------------------------
* Datendeklaration
*---------------------------------------------------------------------
TABLES: /adesso/mte_rel,
        /adesso/mte_err.


DATA ent_file TYPE emg_pfad.
DATA bel_file TYPE emg_pfad.

DATA: imeldung LIKE /adesso/mt_messages OCCURS 0 WITH HEADER LINE.
DATA: imig_err LIKE /adesso/mte_err OCCURS 0 WITH HEADER LINE.

DATA: counter   TYPE i.
DATA: cnt_index TYPE i.


DATA: anz_obj TYPE i.
DATA: anz_devl TYPE i.

DATA: idevl_equnr  LIKE equi-equnr    OCCURS 0 WITH HEADER LINE.




*---------------------------------------------------------------------
* SELEKTION
*---------------------------------------------------------------------
* Einlesen der Lagerzählerdatei
SELECTION-SCREEN BEGIN OF BLOCK xa WITH FRAME TITLE text-bxa.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(22) text-oxa.
PARAMETERS: path_lag LIKE temfd-path
    DEFAULT '/migp1u/evuit/prode/device_lager.txt'.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK xa.



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
PARAMETERS: exp_ext(3) TYPE c DEFAULT 'LAG'.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK ab.

SELECTION-SCREEN BEGIN OF BLOCK ac WITH FRAME TITLE text-bac.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(22) text-obz.
PARAMETERS: p_step(5) TYPE n DEFAULT '1000'.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK ac.

**  >> Tabellen
*SELECTION-SCREEN BEGIN OF BLOCK delt WITH FRAME TITLE text-dt0.
*SELECTION-SCREEN BEGIN OF LINE.
*SELECTION-SCREEN COMMENT 1(22) text-dt1.
*PARAMETERS: p_delerr AS CHECKBOX.
*SELECTION-SCREEN END OF LINE.
*SELECTION-SCREEN END OF BLOCK delt.

SELECTION-SCREEN END OF BLOCK a.


SELECTION-SCREEN BEGIN OF BLOCK b WITH FRAME TITLE text-b05.
*Lagerzähler
SELECTION-SCREEN BEGIN OF BLOCK bdel WITH FRAME TITLE text-del.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(18) text-obj.
PARAMETERS: dat_del LIKE temfd-file DEFAULT 'DEVICE_LAG'.
SELECTION-SCREEN COMMENT 42(12) text-001.
PARAMETERS: obj_del AS CHECKBOX.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK bdel.

SELECTION-SCREEN END OF BLOCK b.



*---------------------------------------------------------------------
* START-OF-SELECTION
*---------------------------------------------------------------------
 START-OF-SELECTION.

  CLEAR: imig_err[].
  CLEAR cnt_index.



*DEVICE_LAG	Lagerzähler
  IF obj_del EQ 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'DEVICE_LAG'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_del.


* einlesen der  Lagerzählerdatei von UNIX
* open Dataset
  OPEN DATASET path_lag FOR INPUT IN TEXT MODE ENCODING DEFAULT.

* Error wenn falscher Pfad bzw.Datei
  IF sy-subrc NE 0.
    SKIP.
    WRITE: / 'Öffnen der Datei', path_lag, 'nicht möglich'.
    EXIT.
  ENDIF.

* Dataset lesen
  DO.
    CLEAR: idevl_equnr.
    READ DATASET path_lag INTO idevl_equnr.

    IF sy-subrc EQ 0.
     APPEND idevl_equnr.
     CLEAR idevl_equnr.
    ELSE.
      EXIT.
    ENDIF.
  ENDDO.

      OPEN DATASET ent_file FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
      IF sy-subrc NE 0.
        CONCATENATE 'Datei' ent_file
         'konnte nicht geöffnet werden'
                           INTO imig_err-meldung SEPARATED BY space.
        APPEND imig_err.
        EXIT.
      ENDIF.

* Ermitteln der Lagerzähler
    LOOP AT idevl_equnr.

      CALL FUNCTION '/ADESSO/MTE_ENT_DEVICE_LAGER'
           EXPORTING
                firma        = firma
                x_equnr      = idevl_equnr
                pfad_dat_ent = ent_file
           IMPORTING
                anz_obj      = anz_obj
           TABLES
                meldung      = imeldung
           EXCEPTIONS
                no_open      = 1
                no_close     = 2
                wrong_data   = 3
                no_data      = 4
                error        = 5
                OTHERS       = 6.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-object = 'DEVICE_LAG'.
          imig_err-obj_key = idevl_equnr.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_devl.
      ENDIF.


* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
     MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                             cnt_index .
        CLEAR counter.
      ENDIF.

    ENDLOOP.

    CLOSE DATASET ent_file.
    IF sy-subrc NE 0.
      CONCATENATE 'Datei' ent_file
       'konnte nicht geschlossen werden'
                         INTO imig_err-meldung SEPARATED BY space.
      APPEND imig_err.
    ENDIF.

* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl  Lagerzähler:', anz_devl.
    SKIP.
    WRITE: / 'Fehler bei Dateierstellung DEVICE_LAG:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_devl.



  ENDIF.






*
*&---------------------------------------------------------------------*
*&      Form  del_entl_ksv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0262   text
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
*      -->P_DAT_PRE  text
*----------------------------------------------------------------------*
FORM erst_entlade_files USING    object_name.

  CONCATENATE exp_path object_name '.' exp_ext
        INTO ent_file.

ENDFORM.                    " erst_entlade_files
