*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTD_ENT_DEVGRP
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT /adesso/mte_entl_devgrp.

*---------------------------------------------------------------------
* Datendeklaration
*---------------------------------------------------------------------
TABLES: /adesso/mte_rel,
        /adesso/mte_rels,
        /adesso/mte_err.


DATA ent_file TYPE emg_pfad.
DATA bel_file TYPE emg_pfad.

DATA: imeldung LIKE /adesso/mt_messages OCCURS 0 WITH HEADER LINE.
DATA: imig_err LIKE /adesso/mte_err OCCURS 0 WITH HEADER LINE.

DATA: counter   TYPE i.
DATA: cnt_index TYPE i.


DATA: anz_obj TYPE i.
DATA: anz_dgr TYPE i.

DATA: idgr_devgrp  LIKE edevgr-devgrp    OCCURS 0 WITH HEADER LINE.
DATA: iegerh2 LIKE egerh OCCURS 0 WITH HEADER LINE.

DATA: data_equnr         LIKE  /adesso/mte_rel-obj_key.



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
PARAMETERS: p_step(5) TYPE n DEFAULT '1000'.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK ac.

SELECTION-SCREEN END OF BLOCK a.


SELECTION-SCREEN BEGIN OF BLOCK b WITH FRAME TITLE text-b05.
*Lagerzähler
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

  CLEAR: imig_err[].
  CLEAR cnt_index.



*DEVGRP	Gerätegruppe Anlegen
  IF obj_dgr EQ 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'DEVGRP'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_dgr.

    OPEN DATASET ent_file FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
    IF sy-subrc NE 0.
      CONCATENATE 'Datei' ent_file
       'konnte nicht geöffnet werden'
                         INTO imig_err-meldung SEPARATED BY space.
      APPEND imig_err.
      EXIT.
    ENDIF.


* Gerätegruppierung ermitteln
    REFRESH idgr_devgrp.

    SELECT * FROM egerh INTO TABLE iegerh2
                        WHERE devgrp NE space
                          AND devloc NE space
                          AND bis    EQ '99991231'.

    LOOP AT iegerh2.

      data_equnr = iegerh2-equnr.
      SELECT SINGLE * FROM /adesso/mte_rel
                          WHERE firma  EQ firma
                            AND object  = 'DEVICE'
                            AND obj_key = data_equnr.

      IF sy-subrc NE 0.
* dann in der gesicherten Relavanztabelle gucken
        SELECT SINGLE * FROM /adesso/mte_rels
                           WHERE firma  EQ firma
                             AND object  = 'DEVICE'
                             AND obj_key = data_equnr.
        IF sy-subrc NE 0.
          CONTINUE.
        ENDIF.
      ENDIF.

      MOVE iegerh2-devgrp TO idgr_devgrp.
      APPEND idgr_devgrp.
      CLEAR idgr_devgrp.

    ENDLOOP.

    SORT idgr_devgrp.
    DELETE ADJACENT DUPLICATES FROM idgr_devgrp.

* Ermitteln der Gerätegruppierungen
    LOOP AT idgr_devgrp.

      CALL FUNCTION '/ADESSO/MTE_ENT_DEVGRP'
           EXPORTING
                firma        = firma
                x_devgrp     = idgr_devgrp
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
          imig_err-object = 'DEVGRP'.
          imig_err-obj_key = idgr_devgrp.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_dgr.
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
    WRITE: / 'Anzahl  Gerätegruppierungen:', anz_dgr.
    SKIP.
    WRITE: / 'Fehler bei Dateierstellung DEVGRP:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_dgr.



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
