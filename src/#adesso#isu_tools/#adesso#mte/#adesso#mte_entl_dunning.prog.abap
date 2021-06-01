*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTE_ENTL_DUNNING
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT /ADESSO/MTE_ENTL_DUNNING.

* Datendeklarationen
DATA: imeldung LIKE /ADESSO/mt_messages OCCURS 0 WITH HEADER LINE.
DATA: imig_err LIKE /adesso/mte_err OCCURS 0 WITH HEADER LINE.
DATA: ent_file TYPE emg_pfad.

*DATA: cnt_index       TYPE i.
*DATA: num_exp_file(2) TYPE n VALUE '01'.
*DATA: cnt_exp_file    TYPE i.
*DATA: counter         TYPE i.
DATA: belkey          TYPE   string.
DATA: wa_rel          TYPE  /adesso/mte_rel.
DATA: o_key           TYPE  emg_oldkey.
DATA  object          TYPE  emg_object.
DATA: meldung         TYPE /adesso/mt_messages OCCURS 0 WITH HEADER LINE.

DATA: anz_obj  TYPE i.
DATA: anz_key  TYPE i.
DATA: anz_fkkma TYPE i.
DATA: anz_dun  TYPE i.

DATA: ifkkmaze TYPE fkkmaze OCCURS 0 WITH HEADER LINE.

DATA: wa_fkkmako TYPE fkkmako.

DATA: oldkey_dun LIKE fkkmako-gpart.

DATA: idun_out LIKE TABLE OF /adesso/mt_transfer,
      wdun_out LIKE /adesso/mt_transfer.

DATA: idun_key TYPE /adesso/mt_emg_dunning OCCURS 0 WITH HEADER LINE.
DATA: idun_fkkma TYPE /adesso/mt_fkkmavs OCCURS 0 WITH HEADER LINE.



* Selektionsbildschirm
** Grundeinstellungen (Firma, Exportpfad, Extension Export, Importpfad)
SELECTION-SCREEN BEGIN OF BLOCK a WITH FRAME TITLE text-b01.
SELECTION-SCREEN BEGIN OF BLOCK aa WITH FRAME TITLE text-b02.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(22) text-p01.
PARAMETERS: firma LIKE temob-firma DEFAULT 'WBD' OBLIGATORY.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK aa.
SELECTION-SCREEN BEGIN OF BLOCK ab WITH FRAME TITLE text-b03.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(22) text-p02.
PARAMETERS: exp_path LIKE temfd-path
    DEFAULT '\\srv8705\migWBD1\Entladung\'.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(22) text-p03.
PARAMETERS: exp_ext(3) TYPE c DEFAULT 'EXP'.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK ab.
*SELECTION-SCREEN BEGIN OF BLOCK ac WITH FRAME TITLE text-bac.
**SELECTION-SCREEN BEGIN OF LINE.
**SELECTION-SCREEN COMMENT 1(22) text-obz.
**PARAMETERS: p_step(6) TYPE n DEFAULT '1000'.
**SELECTION-SCREEN END OF LINE.
*SELECTION-SCREEN BEGIN OF LINE.
**SELECTION-SCREEN COMMENT 1(22) text-obd.
**PARAMETERS: p_split(6) TYPE n.
**SELECTION-SCREEN END OF LINE.
*SELECTION-SCREEN END OF BLOCK ac.
SELECTION-SCREEN END OF BLOCK a.

* Migrations-Objekte
SELECTION-SCREEN BEGIN OF BLOCK b WITH FRAME TITLE text-b05.
* Geräteinfosatz
SELECTION-SCREEN BEGIN OF BLOCK gdun WITH FRAME TITLE text-dun.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(18) text-obj.
PARAMETERS: dat_dun LIKE temfd-file DEFAULT 'DUNNING'.
SELECTION-SCREEN COMMENT 42(12) text-001.
PARAMETERS: obj_dun AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK gdun.
SELECTION-SCREEN END OF BLOCK b.


*---------------------------------------------------------------------
*START-OF-SELECTION
*---------------------------------------------------------------------
START-OF-SELECTION.

  CLEAR: imig_err[].
*  CLEAR cnt_index.

  IF obj_dun = 'X'.

    object = 'DUNNING'.

* Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'DUNNING'.

    PERFORM erst_entlade_files USING dat_dun.

    PERFORM open_entlade_file.

* Gesamte FKKMAZE Sammeln
    SELECT * FROM fkkmaze INTO TABLE ifkkmaze
        WHERE xmsto NE 'X'
        AND mdrkd NE '00000000'.

    LOOP AT ifkkmaze.

      CONCATENATE ifkkmaze-opbel
                  ifkkmaze-opupw
                  ifkkmaze-opupk
                  ifkkmaze-opupz
                INTO belkey.

      SELECT SINGLE * FROM /adesso/mte_rel INTO wa_rel
         WHERE firma = firma
          AND object = 'DUNNING'
          AND obj_key = belkey.

      IF sy-subrc NE 0.
        DELETE ifkkmaze.
      ENDIF.
    ENDLOOP.

*> Initialisierung
    PERFORM init_dun.
    CLEAR: idun_out, wdun_out, anz_obj, meldung.
    REFRESH: idun_out, meldung.

    SORT ifkkmaze.

    LOOP AT ifkkmaze.
**    Füllen des Mahnkopfes bei jedem neuen Partner in diesem Lauf
      AT NEW gpart.
        CLEAR wa_fkkmako.
        SELECT SINGLE * FROM fkkmako INTO wa_fkkmako
          WHERE laufd = ifkkmaze-laufd
           AND  laufi = ifkkmaze-laufi
           AND  gpart = ifkkmaze-gpart
           AND xmsto NE 'X'
           AND mdrkd NE '00000000'.

        MOVE-CORRESPONDING wa_fkkmako TO idun_key.
        APPEND idun_key.
        CLEAR idun_key.

      ENDAT.

**    Füllen der Mahnpositionen
      MOVE-CORRESPONDING ifkkmaze TO idun_fkkma.
      MOVE ifkkmaze-mbetm TO idun_fkkma-betrw.
      APPEND idun_fkkma.
      CLEAR idun_fkkma.

**    Am Endes des Partners Objekt wegschreiben
      AT END OF gpart.
        CLEAR o_key.
        CONCATENATE ifkkmaze-laufd
              ifkkmaze-laufi
              ifkkmaze-gpart
            INTO o_key.

**>> Wegschreiben des Objektschlüssels in Entlade-KSV
        CALL FUNCTION '/ADESSO/MTE_OBJKEY_INSERT_ONE'
          EXPORTING
            i_firma  = firma
            i_object = object
            i_oldkey = o_key
          EXCEPTIONS
            error    = 1
            OTHERS   = 2.
        IF sy-subrc <> 0.
          meldung-meldung =
              'Fehler bei wegschreiben in Entlade-KSV'.
          APPEND meldung.
          CLEAR meldung.
          CONTINUE.
        ENDIF.
**<< Wegschreiben des Objektschlüssels in Entlade-KSV

        ADD 1 TO anz_obj.
* Sätze für Datei in interne Tabelle schreiben
        PERFORM fill_dun_out USING o_key
                                   firma
                                   object
                                   anz_key
                                   anz_fkkma.

        LOOP AT idun_out INTO wdun_out.
          TRANSFER wdun_out TO ent_file.
        ENDLOOP.

        CLEAR: idun_out, wdun_out.
        REFRESH idun_out.

      ENDAT.

    ENDLOOP.

    ADD anz_obj TO anz_dun.
* Entladedatei schließen
    PERFORM close_entlade_file.

*** Fehlerauswertung
    SORT imig_err.
    DELETE ADJACENT DUPLICATES FROM imig_err COMPARING ALL FIELDS.

    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl Mahnungen:', 50 anz_dun.
    WRITE: / 'Enthaltene Strukturen: KEY',     50 anz_key,
           / '                       FKKMAVS', 50 anz_fkkma.
    SKIP.
    WRITE: / 'Fehler bei Dateierstellung DUNNING:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_dun.
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
FORM del_entl_ksv USING    value(obj).

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
  OPEN DATASET ent_file FOR OUTPUT IN TEXT MODE ENCODING NON-UNICODE.
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
**----------------------------------------------------------------------*
*FORM neue_entlade_datei .
*
*  PERFORM close_entlade_file.
*
**   Neuen Datei-Namen erstellen
*  CLEAR cnt_exp_file.
*  ADD 1 TO num_exp_file.
*
*  SEARCH ent_file FOR '...'.
*  IF sy-subrc NE 0.
*    CONCATENATE 'Datei-Name' ent_file
*     'konnte nicht für die Aufteilung erweitert werden'
*                       INTO imig_err-meldung SEPARATED BY space.
*    APPEND imeldung.
*    RAISE no_open.
*  ELSE.
*    sy-fdpos = sy-fdpos - 2.
*    REPLACE ent_file+sy-fdpos(2) WITH num_exp_file INTO ent_file.
*  ENDIF.
*
*  PERFORM open_entlade_file.
*
*ENDFORM.                    " neue_entlade_datei


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


*&---------------------------------------------------------------------*
*&      Form  INIT_DUN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_dun .

  CLEAR: idun_key,
         idun_fkkma.

  REFRESH: idun_key,
            idun_fkkma.

ENDFORM.                    " INIT_DUN

*&---------------------------------------------------------------------*
*&      Form  FILL_DUN_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_O_KEY  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*      -->P_ANZ_KEY  text
*      -->P_ANZ_FKKMA  text
*----------------------------------------------------------------------*
FORM fill_dun_out  USING    coldkey
                            cfirma
                            cobject
                            p_anz_key
                            p_anz_fkkma.

  LOOP AT idun_key.
    wdun_out-firma  = cfirma.
    wdun_out-object = cobject.
    wdun_out-dttyp  = 'KEY'.
    wdun_out-oldkey = coldkey.
    wdun_out-data   = idun_key.
    ADD 1 TO p_anz_key.
    APPEND wdun_out TO idun_out.
  ENDLOOP.

  LOOP AT idun_fkkma.
    wdun_out-firma = cfirma.
    wdun_out-object = cobject.
    wdun_out-dttyp = 'FKKMA'.
    wdun_out-oldkey = coldkey.
    wdun_out-data = idun_fkkma.
    ADD 1 TO p_anz_fkkma.
    APPEND wdun_out TO idun_out.
  ENDLOOP.

  PERFORM init_dun.

ENDFORM.                    " FILL_DUN_OUT
