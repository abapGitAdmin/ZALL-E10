*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTE_ENTL_DEVICERATE_ZW
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT /adesso/mte_entl_devicerate_zw.

*---------------------------------------------------------------------
* Datendeklaration
*---------------------------------------------------------------------
TABLES: /adesso/mte_rel,
        /adesso/mte_rels,
        /adesso/mte_htge,
        /adesso/mte_htsi,
        /adesso/mte_err.


DATA ent_file TYPE emg_pfad.
DATA bel_file TYPE emg_pfad.

DATA: imeldung LIKE /adesso/mt_messages OCCURS 0 WITH HEADER LINE.
DATA: imig_err LIKE /adesso/mte_err OCCURS 0 WITH HEADER LINE.

DATA: counter   TYPE i.
DATA: cnt_index TYPE i.


DATA: anz_obj TYPE i.
DATA: anz_drt TYPE i.

DATA: iht_ger_drt LIKE /adesso/mte_htge OCCURS 0 WITH HEADER LINE.




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

SELECTION-SCREEN BEGIN OF BLOCK ac WITH FRAME TITLE text-bac.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(22) text-obz.
PARAMETERS: p_step(5) TYPE n DEFAULT '5000'.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK ac.

SELECTION-SCREEN END OF BLOCK a.


SELECTION-SCREEN BEGIN OF BLOCK b WITH FRAME TITLE text-b05.
*Tarifdaten zur Anlagenstruktur ändern
SELECTION-SCREEN BEGIN OF BLOCK bdrt WITH FRAME TITLE text-drt.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(18) text-obj.
PARAMETERS: dat_drt LIKE temfd-file DEFAULT 'DEVICERATE'.
SELECTION-SCREEN COMMENT 42(12) text-001.
PARAMETERS: obj_drt AS CHECKBOX.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK bdrt.

SELECTION-SCREEN END OF BLOCK b.

PARAMETERS: ger_si AS CHECKBOX.


*---------------------------------------------------------------------
* START-OF-SELECTION
*---------------------------------------------------------------------
START-OF-SELECTION.

  CLEAR: imig_err[].
  CLEAR cnt_index.



*DEVICERATE	Tarifdaten zur Anlagenstruktur ändern

  IF obj_drt EQ 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'DEVICERATE'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_drt.

* Schlüssel aus ermitteln
    IF ger_si EQ 'X'.

      SELECT * FROM /adesso/mte_htsi INTO TABLE iht_ger_drt
              WHERE  action = '03'.
      IF sy-subrc NE 0.
        SKIP.
        WRITE: /
      'keine Wechsel-Daten für Devicerate in /adesso/mte_htsi gefunden'.
        EXIT.
      ELSE.

        OPEN DATASET ent_file FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
        IF sy-subrc NE 0.
          CONCATENATE 'Datei' ent_file
           'konnte nicht geöffnet werden'
                             INTO imig_err-meldung SEPARATED BY space.
          APPEND imig_err.
          EXIT.
        ENDIF.
      ENDIF.

    ELSE.

      SELECT * FROM /adesso/mte_htge INTO TABLE iht_ger_drt
              WHERE  action = '03'.
      IF sy-subrc NE 0.
        SKIP.
        WRITE: /
      'keine Wechsel-Daten für Devicerate in /adesso/mte_htge gefunden'.
        EXIT.
      ELSE.

        OPEN DATASET ent_file FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
        IF sy-subrc NE 0.
          CONCATENATE 'Datei' ent_file
           'konnte nicht geöffnet werden'
                             INTO imig_err-meldung SEPARATED BY space.
          APPEND imig_err.
          EXIT.
        ENDIF.
      ENDIF.

    ENDIF.

    LOOP AT iht_ger_drt.

*   Aufruf des FUBAS pro iht_ger-Satz
      CALL FUNCTION '/ADESSO/MTE_ENT_DEVICERATE_ZW'
           EXPORTING
                firma        = firma
                x_htger      = iht_ger_drt
                pfad_dat_ent = ent_file
           IMPORTING
                anz_obj      = anz_obj
           TABLES
                meldung      = imeldung
           EXCEPTIONS
                no_open      = 1
                no_close     = 2
                wrong_data   = 3
                error        = 4
                OTHERS       = 5.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'DEVICERATE'.
          imig_err-obj_key = iht_ger_drt-equnr.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_drt.
      ENDIF.


* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH
                'Anzahl durchlaufender Objekte bzw. Vorgänge:'
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
    WRITE: / 'Anzahl Tarifänderungen:', anz_drt.
    SKIP.
    WRITE: / 'Fehler bei Dateierstellung DEVICERATE:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
               'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                              anz_drt.

  ENDIF.

*-----------------------------------------------------------------------






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
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
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
