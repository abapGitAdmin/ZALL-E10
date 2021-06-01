*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTE_ENTL_STRASSE
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT /adesso/mte_entl_strasse LINE-SIZE 132.

*----------------------------------------------------------------------
* Grundeinstieg in die Befüllung der Migrations-
* objekte. Die entladenen Daten pro Objekt werden hier eingelesen und
* für die Beladung der Migrationsworkbench aufbereitet.
*----------------------------------------------------------------------
TABLES: adrstreet,  "#EC NEEDED
        adrstrtisu, "#EC NEEDED
        adrstrtmru, "#EC NEEDED
        adrstrtkon, "#EC NEEDED
        adrstrtccs. "#EC NEEDED


*---------------------------------------------------------------------
* Datendeklaration
*---------------------------------------------------------------------
DATA ent_file TYPE emg_pfad.
DATA bel_file TYPE emg_pfad. "#EC NEEDED
DATA: anz_obj TYPE i.
DATA: imeldung LIKE /adesso/mt_messages OCCURS 0 WITH HEADER LINE.
DATA: mig_err LIKE /adesso/mt_messages OCCURS 0 WITH HEADER LINE. "#EC NEEDED
DATA: anz_reg TYPE i. "#EC NEEDED
DATA: anz_rag TYPE i. "#EC NEEDED
DATA: imig_err LIKE /adesso/mte_err OCCURS 0 WITH HEADER LINE. "#EC NEEDED

DATA: counter   TYPE i.
DATA: cnt_exp_file  TYPE i.
DATA: num_exp_file(2) TYPE n VALUE '01'. "#EC NEEDED
DATA: cnt_index TYPE i.

* Datendeklaration für Belade-FUBA ADRSTREET
DATA: oldkey_reg LIKE /adesso/mt_transfer-oldkey. "#EC NEEDED
DATA  i_reg_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE. "#EC NEEDED

* interne Tabellen für adrstreet (Weiterverarbeitung)
DATA: i_co_str TYPE adrstreetd OCCURS 0 WITH HEADER LINE. "#EC NEEDED
DATA: i_co_pcd TYPE adrstrpcd OCCURS 0 WITH HEADER LINE. "#EC NEEDED


* interne Strukturen für adrstreet (Übergabe aus Datei)
DATA: x_i_co_str TYPE adrstreetd. "#EC NEEDED
DATA: x_i_co_pcd TYPE adrstrpcd. "#EC NEEDED


 DATA: i_str LIKE adrstreet-strt_code   OCCURS 0 WITH HEADER LINE. "#EC NEEDED
 DATA: i_rag LIKE adrstrtisu-strt_code   OCCURS 0 WITH HEADER LINE. "#EC NEEDED

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
SELECTION-SCREEN BEGIN OF BLOCK kk WITH FRAME TITLE text-k03.
PARAMETERS: p_city LIKE adrcity-city_code.

SELECTION-SCREEN END OF BLOCK kk.
SELECTION-SCREEN END OF BLOCK aa.
SELECTION-SCREEN BEGIN OF BLOCK ab WITH FRAME TITLE text-b03.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(22) text-p02.
PARAMETERS: exp_path LIKE temfd-path
*    DEFAULT '/Ent/SWL_BI/'.
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
*    DEFAULT '/Ent/SWL_BI/'.
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
*&--------------------------------------------------------------------*
*&      Form  dateien_erstellen
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*---------------------------------------------------------------------*
FORM dateien_erstellen .
*ADRSTREET#Strassen anlegen
  IF obj_reg EQ 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'ADRSTREET'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_reg.


     SELECT strt_code FROM adrstreet INTO TABLE i_str
                      WHERE country = 'DE' AND
                            strt_code IN s_code AND
                            city_code = p_city.

      PERFORM open_entlade_file.

    LOOP AT i_str.

      CALL FUNCTION '/ADESSO/MTE_ENT_ADRSTREET' "#EC ARGCHECKED

           EXPORTING
                firma        = firma
                x_strt_code  = i_str
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
          imig_err-firma  = firma.
          imig_err-object = 'ADRSTREET'.
          imig_err-obj_key = i_str.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_reg.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.


* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.

    ENDLOOP.

    PERFORM close_entlade_file.

* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl Strassencodes:', anz_reg."#EC NOTEXT

    SKIP.
    WRITE: / 'Fehler bei Dateierstellung ADRSTREET:'. "#EC NOTEXT

    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'. "#EC NOTEXT

    ENDIF.

*>------------------------------------------------------------
    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:' "#EC NOTEXT

                                               anz_reg.
*<------------------------------------------------------------

  ENDIF.


* weitere Strassendaten
* ADRSTRTISU#weitere Strassen-Info's anlegen
  IF obj_rag EQ 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'ADRSTRTISU'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_rag.


   SELECT strt_code FROM adrstreet INTO TABLE i_rag
                      WHERE country = 'DE' AND
                            strt_code IN s_code AND
                            city_code = p_city.


      PERFORM open_entlade_file.

    LOOP AT i_rag.

      CALL FUNCTION '/EVUIT/MTE_ENT_ADRSTRTISU' "#EC ARGCHECKED

           EXPORTING
                firma        = firma
                x_strt_code  = i_rag
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
          imig_err-firma  = firma.
          imig_err-object = 'ADRSTRTISU'.
          imig_err-obj_key = i_rag.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_rag.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.


* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
*      IF counter EQ p_step.
*     MESSAGE  s001(/evuit/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
*                                                             cnt_index .
*        CLEAR counter.
*      ENDIF.

*     Entlade-Datei splitten ?
*      IF NOT p_split IS INITIAL AND
*         cnt_exp_file GE p_split.
*        PERFORM neue_entlade_datei.
*      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.

* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl weitere Strasseninfos:', anz_rag. "#EC NOTEXT

    SKIP.
    WRITE: / 'Fehler bei Dateierstellung ADRSTRTISU:'. "#EC NOTEXT

    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'. "#EC NOTEXT

    ENDIF.

*>------------------------------------------------------------
    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:' "#EC NOTEXT

                                               anz_rag.
*<------------------------------------------------------------

  ENDIF.

ENDFORM.                    " dateien_erstellen

*&---------------------------------------------------------------------*
*&      Form  del_entl_ksv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0440   text
*----------------------------------------------------------------------*
FORM del_entl_ksv USING    VALUE(obj). "#EC *



  CALL FUNCTION '/ADESSO/MTE_OBJKEY_MAIN'
    EXPORTING
      i_firma                = firma
      i_object               = obj
*    I_OLDKEY               =
    EXCEPTIONS
      error                  = 1
      wrong_parameters       = 2
      OTHERS                 = 3.

  IF sy-subrc <> 0.  "#EC NEEDED
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " del_entl_ksv

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

IF p_city IS INITIAL.
WRITE: 'Es muss ein Citycode angegeben sein!'. "#EC NOTEXT

 EXIT.
ENDIF.
ENDFORM.                    " pruef_ung
