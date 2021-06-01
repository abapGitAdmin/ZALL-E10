*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTE_ENTL_INVOICE
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT /ADESSO/MTE_ENTL_INVOICE.


* Datendeklarationen
DATA: imeldung LIKE /adesso/mt_messages OCCURS 0 WITH HEADER LINE.
DATA: imig_err LIKE /adesso/mte_err OCCURS 0 WITH HEADER LINE.
DATA: ent_file TYPE emg_pfad.


DATA: cnt_index     TYPE i.
DATA: num_exp_file(2) TYPE n VALUE '01'.
DATA: cnt_exp_file  TYPE i.
DATA: counter       TYPE i.


DATA: anz_obj  TYPE i.
DATA: anz_inv  TYPE i.
DATA: anz_head TYPE i,
      anz_doc TYPE i,
      anz_doc_db TYPE i,
      anz_lineb TYPE i,
      anz_append TYPE i.

**  Die Interne Tabelle für die Schnittstelle des FuBas muss CHAR-Inhalte heben
**  INT_INV_NO ist in der Tabelle TINV_INV_HEAD ein NUMC Feled der Länge 18
**  das FEld wird daher als CHAR18 deklariert
DATA: BEGIN OF w_invoice,
       int_inv_no TYPE char18,
      END OF w_invoice.
DATA: i_invoice LIKE STANDARD TABLE OF w_invoice WITH HEADER LINE.


DATA: wa_tinv_inv_head TYPE tinv_inv_head.


* Selektionsbildschirm
** Grundeinstellungen (Firma, Exportpfad, Extension Export, Importpfad)
SELECTION-SCREEN BEGIN OF BLOCK a WITH FRAME TITLE text-b01.
SELECTION-SCREEN BEGIN OF BLOCK aa WITH FRAME TITLE text-b02.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(22) text-p01.
PARAMETERS: firma LIKE temob-firma DEFAULT 'EGUT ' OBLIGATORY.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK aa.
SELECTION-SCREEN BEGIN OF BLOCK ab WITH FRAME TITLE text-b03.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(22) text-p02.
PARAMETERS: exp_path LIKE temfd-path
    DEFAULT '\\sdit10027\migration\Entladung_Golive\'.
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
* Netznutzungsabrechnung (INVOICE)
SELECTION-SCREEN BEGIN OF BLOCK ginv WITH FRAME TITLE text-inv.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(18) text-obj.
PARAMETERS: dat_inv LIKE temfd-file DEFAULT 'INVOICE'.
SELECTION-SCREEN COMMENT 42(12) text-001.
PARAMETERS: obj_inv AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK ginv.
SELECTION-SCREEN BEGIN OF BLOCK test WITH FRAME TITLE text-tes.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(15) text-tst.
SELECT-OPTIONS: so_test FOR wa_tinv_inv_head-int_inv_no. " OBLIGATORY.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK test.
SELECTION-SCREEN END OF BLOCK b.



*---------------------------------------------------------------------
*START-OF-SELECTION
*---------------------------------------------------------------------
START-OF-SELECTION.

  CLEAR: imig_err[].
  CLEAR cnt_index.


** Anlegen Netznutzungsabrechnung
  IF obj_inv EQ 'X'.

* Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'INVOICE'.

    PERFORM erst_entlade_files USING dat_inv.

*    Schlüssel aus relevanztabelle ermitteln
    SELECT obj_key FROM /adesso/mte_rel INTO TABLE i_invoice
                                  WHERE firma  = firma
                                  AND object = 'INVOICE'
                                  AND obj_key IN so_test.
    IF sy-subrc NE 0.
      SKIP.
      WRITE: / 'keine Daten für Netznutzungsabrechnungen in Relevanztabelle gefunden'.
      EXIT.
    ELSE.
      IF NOT p_split IS INITIAL.
        REPLACE '.' WITH '01.' INTO ent_file.
      ENDIF.
      PERFORM open_entlade_file.
    ENDIF.

    LOOP AT i_invoice.


** Fuba Aufrufen
      CALL FUNCTION '/ADESSO/MTE_ENT_INVOICE'
        EXPORTING
          firma        = firma
          x_beleg      = i_invoice-int_inv_no
          pfad_dat_ent = ent_file
        IMPORTING
          anz_obj      = anz_obj
          anz_head     = anz_head
          anz_doc      = anz_doc
          anz_doc_db   = anz_doc_db
          anz_lineb    = anz_lineb
          anz_append   = anz_append
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
          LOOP AT imeldung.
            imig_err-firma  = firma.
            imig_err-object = 'INVOICE'.
            imig_err-obj_key = i_invoice-int_inv_no.
            imig_err-meldung = imeldung-meldung.
            APPEND imig_err.
          ENDLOOP.
        ELSE.
          ADD anz_obj TO anz_inv.
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
*
    ENDLOOP.

* Entladedatei schließen
    PERFORM close_entlade_file.

* Fehlerauswertung
    SORT imig_err.
    DELETE ADJACENT DUPLICATES FROM imig_err COMPARING ALL FIELDS.

    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl Netznutzungsabrechnungen:', 50 anz_inv.
    WRITE: / 'Enthaltene Strukturen      HEAD', 50 anz_head,
           / '                           DOC', 50 anz_doc,
           / '                           DOC_DB', 50 anz_doc_db,
           / '                           LINEB', 50 anz_lineb,
           / '                           APPEND', 50 anz_append  .
    SKIP.
    WRITE: / 'Fehler bei Dateierstellung INVOICE:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
*    ENDIF.

      MESSAGE  s001(/adesso/mt_n)  WITH
                  'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                                 anz_inv.

    ENDIF.
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
FORM open_entlade_file.
  OPEN DATASET ent_file FOR OUTPUT IN TEXT MODE ENCODING NON-UNICODE.
  IF sy-subrc NE 0.
    CONCATENATE 'Datei' ent_file
    'konnte nicht geöffnet werden'
                       INTO imeldung-meldung SEPARATED BY space.
    APPEND imeldung.
    RAISE no_open.
  ENDIF.
ENDFORM.                    "open_entlade_file



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
    ent_file+sy-fdpos(2) = num_exp_file.
*    REPLACE ent_file+sy-fdpos(2) WITH num_exp_file INTO ent_file.
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
