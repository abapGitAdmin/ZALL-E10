*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTE_ENTL_PAY_BBP_MULT
*&
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------
* Grundeinstieg in die Befüllung der Migrations-
* objekte. Die entladenen Daten pro Objekt werden hier eingelesen und
* für die Beladung der Migrationsworkbench aufbereitet.
*----------------------------------------------------------------------
REPORT /adesso/mte_entl_pay_bbp_mult LINE-SIZE 132.


TABLES: eabp.  "#EC NEEDED
*---------------------------------------------------------------------
* Datendeklaration
*---------------------------------------------------------------------
DATA ent_file TYPE emg_pfad.
DATA bel_file TYPE emg_pfad. "#EC NEEDED
DATA: anz_obj TYPE i.
DATA: imeldung LIKE /adesso/mt_messages OCCURS 0 WITH HEADER LINE.
DATA: mig_err LIKE /adesso/mt_messages OCCURS 0 WITH HEADER LINE. "#EC NEEDED
DATA: anz_reg TYPE i. "#EC NEEDED
DATA: anz_pab TYPE i. "#EC NEEDED
DATA: imig_err LIKE /adesso/mte_err OCCURS 0 WITH HEADER LINE. "#EC NEEDED

DATA: counter   TYPE i.
DATA: cnt_exp_file  TYPE i.
DATA: num_exp_file(2) TYPE n VALUE '01'. "#EC NEEDED
DATA: cnt_index TYPE i.

* Datendeklaration für Belade-FUBA payment/BBP_MULT
DATA: oldkey_pay LIKE /adesso/mt_transfer-oldkey. "#EC NEEDED
DATA  i_pay_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE. "#EC NEEDED

* interne Tabellen für eabp (Weiterverarbeitung)
DATA: i_co_fkkko TYPE fkkko OCCURS 0 WITH HEADER LINE. "#EC NEEDED
DATA: i_co_fkkop TYPE fkkop OCCURS 0 WITH HEADER LINE. "#EC NEEDED
DATA: ipay_abplan LIKE eabp-opbel    OCCURS 0 WITH HEADER LINE.

*----------------------------------------------------------------------
* SELEKTIONSBILDSCHIM
*----------------------------------------------------------------------

* Grundeinstellungen (Firma, Exportpfad, Extension Export, Importpfad)
SELECTION-SCREEN BEGIN OF BLOCK a WITH FRAME TITLE text-b01.
SELECTION-SCREEN BEGIN OF BLOCK aa WITH FRAME TITLE text-b02.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(22) text-p01.
PARAMETERS: firma LIKE temfd-firma DEFAULT 'SWL' OBLIGATORY.

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
SELECTION-SCREEN BEGIN OF BLOCK ac WITH FRAME TITLE text-b04.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(22) text-p04.
PARAMETERS: imp_path LIKE temfd-path
DEFAULT '/Mig/SWL_BI/Migration/Bel/'.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(22) text-p05.
PARAMETERS: imp_ext(3) TYPE c DEFAULT 'IMP'.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK ac.
SELECTION-SCREEN END OF BLOCK a.

* Migrations-Objekte
SELECTION-SCREEN BEGIN OF BLOCK c WITH FRAME TITLE text-b05.
* PAYMENT
SELECTION-SCREEN BEGIN OF BLOCK bpay WITH FRAME TITLE text-p17.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(18) text-obj.
PARAMETERS: dat_pab LIKE temfd-file DEFAULT 'PAY_BBP'.
SELECTION-SCREEN COMMENT 42(12) text-001.
PARAMETERS: obj_pab AS CHECKBOX.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK bpay.

SELECTION-SCREEN END OF BLOCK c.

*---------------------------------------------------------------------
*START-OF-SELECTION
*---------------------------------------------------------------------
START-OF-SELECTION.
PERFORM dateien_erstellen.
*---------------------------------------------------------------------
*END-OF-SELECTION
*---------------------------------------------------------------------

*&---------------------------------------------------------------------*
*&      Form  be_und_entlade_files
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DAT_REG  text
*----------------------------------------------------------------------*
FORM be_und_entlade_files USING    object_name. "#EC CALLED


  CONCATENATE exp_path object_name '.' exp_ext
        INTO ent_file.
  CONCATENATE imp_path object_name '.' imp_ext
        INTO bel_file.


ENDFORM.                    " be_und_entlade_files
**&--------------------------------------------------------------------*
**&      Form  dateien_erstellen
**&--------------------------------------------------------------------*
**       text
**---------------------------------------------------------------------*
**  -->  p1        text
**  <--  p2        text
**---------------------------------------------------------------------*
FORM dateien_erstellen .
* payment_ bbp_mult anlegen
  IF obj_pab EQ 'X'.
  PERFORM erst_entlade_files USING dat_pab.
* Schlüssel aus Relevanztabelle ermitteln
    SELECT obj_key FROM /adesso/mte_rel INTO TABLE ipay_abplan
                                  WHERE firma  = firma
                                  AND   object = 'BBP_MULT'.
    IF sy-subrc NE 0.
      SKIP.
      WRITE: / 'keine Daten für Zahlungen in Relevanztabelle gefunden'.
      EXIT.
      PERFORM open_entlade_file.
    ENDIF.

    LOOP AT ipay_abplan.

      CALL FUNCTION '/ADESSO/MTE_ENT_PAY_BBP_MULT'
        EXPORTING
          firma        = firma
          x_abplan     = ipay_abplan
          pfad_dat_ent = ent_file
        IMPORTING
          anz_obj      = anz_obj
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
*          no_data      = 4
          error        = 5
          OTHERS       = 6.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'PAY_BBP'.
          imig_err-obj_key = ipay_abplan.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_pab.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.


* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.

        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
    ENDLOOP.

    PERFORM close_entlade_file.


* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl Abschlags-Zahlungen:', anz_pab.
    SKIP.
    WRITE: / 'Meldung bei Dateierstellung PAY_BBP:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_pab.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  erst_entlade_files
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DAT_REG  text
*----------------------------------------------------------------------*
FORM erst_entlade_files USING    object_name. "#EC *

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
    'konnte nicht geöffnet werden' "#EC NOTEXT

                       INTO imeldung-meldung SEPARATED BY space.
    APPEND imeldung.
    RAISE no_open.      "#EC *
  ENDIF.

ENDFORM.                    " open_entlade_file

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
     'konnte nicht geschlossen werden' "#EC NOTEXT

                       INTO imig_err-meldung SEPARATED BY space.
    APPEND imig_err.
    RAISE no_open.
  ENDIF.
ENDFORM.                    " close_entlade_file
