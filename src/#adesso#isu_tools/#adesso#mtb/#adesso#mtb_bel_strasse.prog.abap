*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTB_BEL_STRASSE
*&
*----------------------------------------------------------------------
* Grundeinstieg in die Befüllung der Migrations-
* objekte. Die entladenen Daten pro Objekt werden hier eingelesen und
* für die Beladung der Migrationsworkbench aufbereitet.
*----------------------------------------------------------------------
REPORT /adesso/mtb_bel_strasse.
TABLES:adrstreet.
*---------------------------------------------------------------------
* Datendeklaration
*---------------------------------------------------------------------
DATA ent_file TYPE emg_pfad.
DATA bel_file TYPE emg_pfad.
DATA: anz_obj TYPE i.  "#EC NEEDED
DATA: imeldung LIKE /adesso/mt_messages OCCURS 0 WITH HEADER LINE. "#EC NEEDED
DATA: mig_err LIKE /adesso/mt_messages OCCURS 0 WITH HEADER LINE. "#EC NEEDED
DATA: anz_reg TYPE i. "#EC NEEDED
DATA: anz_rag TYPE i. "#EC NEEDED
DATA: imig_err LIKE /adesso/mte_err OCCURS 0 WITH HEADER LINE. "#EC NEEDED

DATA: counter   TYPE i.  "#EC NEEDED
DATA: cnt_exp_file  TYPE i. "#EC NEEDED
DATA: num_exp_file(2) TYPE n VALUE '01'. "#EC NEEDED
DATA: cnt_index TYPE i. "#EC NEEDED

* Datendeklaration für Belade-FUBA ADRSTREET
DATA: oldkey_reg LIKE /adesso/mt_transfer-oldkey. "#EC NEEDED

DATA  i_reg_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE. "#EC NEEDED

* interne Tabellen für adrstreet (Weiterverarbeitung)
DATA: i_co_str TYPE /adesso/mt_adrstreet OCCURS 0 WITH HEADER LINE. "#EC NEEDED
DATA: i_co_pcd TYPE /adesso/mt_adrstrpcd OCCURS 0 WITH HEADER LINE. "#EC NEEDED


* interne Strukturen für adrstreet (Übergabe aus Datei)
DATA: x_i_co_str TYPE /adesso/mt_adrstreet. "#EC NEEDED
DATA: x_i_co_pcd TYPE /adesso/mt_adrstrpcd. "#EC NEEDED

DATA: icon_str LIKE adrstreet-strt_code   OCCURS 0 WITH HEADER LINE. "#EC NEEDED
DATA: inoc_str LIKE adrstreet-strt_code   OCCURS 0 WITH HEADER LINE. "#EC NEEDED

*----------------------------------------------------------------------
* SELEKTIONSBILDSCHIM
*----------------------------------------------------------------------

* Grundeinstellungen (Firma, Exportpfad, Extension Export, Importpfad)
SELECTION-SCREEN BEGIN OF BLOCK a WITH FRAME TITLE text-b01.
SELECTION-SCREEN BEGIN OF BLOCK aa WITH FRAME TITLE text-b02.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(22) text-p01.
PARAMETERS: firma LIKE temfd-firma DEFAULT 'SWL' OBLIGATORY.
SELECT-OPTIONS: s_code FOR adrstreet-strt_code NO-DISPLAY.

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
*SELECTION-SCREEN BEGIN OF BLOCK ac WITH FRAME TITLE text-b04.
SELECTION-SCREEN BEGIN OF BLOCK ac WITH FRAME TITLE text-k04.
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
SELECTION-SCREEN BEGIN OF BLOCK b WITH FRAME TITLE text-b05.
*Strassen
SELECTION-SCREEN BEGIN OF BLOCK bpar WITH FRAME TITLE text-reg.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(18) text-obj.
PARAMETERS: dat_reg LIKE temfd-file DEFAULT 'ADRSTREET'.
SELECTION-SCREEN COMMENT 42(12) text-001.
PARAMETERS: obj_reg AS CHECKBOX.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK bpar.
**weitere Strassendaten
SELECTION-SCREEN BEGIN OF BLOCK bpno WITH FRAME TITLE text-rag.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(18) text-obj.
PARAMETERS: dat_rag LIKE temfd-file DEFAULT 'ADRSTRTISU'.
SELECTION-SCREEN COMMENT 42(12) text-001.
PARAMETERS: obj_rag AS CHECKBOX.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK bpno.

SELECTION-SCREEN END OF BLOCK b.

*---------------------------------------------------------------------
*START-OF-SELECTION
*---------------------------------------------------------------------
START-OF-SELECTION.
PERFORM pruef_ung.

PERFORM migrationsdateien_erstellen.

*---------------------------------------------------------------------
*END-OF-SELECTION
*---------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&      Form  migrationsdateien_erstellen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM migrationsdateien_erstellen.
*Street#Strassen anlegen
  IF obj_reg EQ 'X'.
    PERFORM be_und_entlade_files USING dat_reg.

* Fuba-Aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_ADRSTREET'
         EXPORTING
              firma        = firma
              pfad_dat_ent = ent_file
              pfad_dat_bel = bel_file
         IMPORTING
              anz_obj      = anz_reg
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
      WRITE: / 'Anzahl Street:', anz_reg. "#EC NOTEXT
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung STREET:'. "#EC NOTEXT
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl STREET:', anz_reg. "#EC NOTEXT
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.

  ENDIF.

* weitere Strasseninfo's ISU_DATEN
*Street#Strassen anlegen
  IF obj_rag EQ 'X'.
    PERFORM be_und_entlade_files USING dat_rag.

* Fuba-Aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_ADRSTRTISU'
         EXPORTING
              firma        = firma
              pfad_dat_ent = ent_file
              pfad_dat_bel = bel_file
         IMPORTING
              anz_obj      = anz_rag
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
      WRITE: / 'Anzahl Street:', anz_rag. "#EC NOTEXT
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung ADRSTRTISU:'. "#EC NOTEXT
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl ADRSTRTISU:', anz_rag. "#EC NOTEXT
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.

  ENDIF.

ENDFORM.                    " migrationsdateien_erstellen
*&---------------------------------------------------------------------*
*&      Form  be_und_entlade_files
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DAT_REG  text
*----------------------------------------------------------------------*
FORM be_und_entlade_files USING    object_name. "#EC *

  CONCATENATE exp_path object_name '.' exp_ext
        INTO ent_file.
  CONCATENATE imp_path object_name '.' imp_ext
        INTO bel_file.


ENDFORM.                    " be_und_entlade_files

*ENDFORM.                    " close_entlade_file
*&---------------------------------------------------------------------*
*&      Form  pruef_ung
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pruef_ung .
IF obj_rag IS INITIAL AND
   obj_reg IS INITIAL.
WRITE: 'Es muss ein Migrationsobjekt angekreuzt sein!'. "#EC NOTEXT
 EXIT.
ENDIF.

IF NOT obj_rag IS INITIAL AND
   NOT obj_reg IS INITIAL.
WRITE: 'Es darf nur ein Migrationsobjekt angekreuzt sein!'. "#EC NOTEXT
 EXIT.
ENDIF.
ENDFORM.                    " pruef_ung
