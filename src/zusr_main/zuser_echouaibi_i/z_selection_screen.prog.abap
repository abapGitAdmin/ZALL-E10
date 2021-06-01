************************************************************************
****
*            _
*   __ _  __| | ___  ___ ___  ___
*  / _` |/ _` |/ _ \/ __/ __|/ _ \
* | (_| | (_| |  __/\__ \__ \ (_) |
*  \__,_|\__,_|\___||___/___/\___/
************************************************************************
*******
*
*
*&
************************************************************************
*******
REPORT Z_SELECTION_SCREEN.

* Inspiriert (Quelle) von: http://www.abapgit.org
DATA: gv_user TYPE string.
DATA: gv_pass TYPE string.

**********************************************************************
*
* Dynproelemente für Standard-Selektionbild
*
**********************************************************************
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN PUSHBUTTON 2(30) b_pop USER-COMMAND pop.
SELECTION-SCREEN END OF LINE.
**********************************************************************
*
* Dynproelemente für Popup
*
**********************************************************************
SELECTION-SCREEN BEGIN OF SCREEN 3000 TITLE s_title.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(10) s_user FOR FIELD p_user.
PARAMETERS: p_user TYPE string LOWER CASE.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(10) s_pass FOR FIELD p_pass.
PARAMETERS: p_pass TYPE string LOWER CASE.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF SCREEN 3000.
**********************************************************************
*
* Klasse zur Anzeige des Popup-Fensters
*
**********************************************************************
CLASS lcl_pwdlg DEFINITION FINAL.

  PUBLIC SECTION.
    CONSTANTS: co_dynnr TYPE char4 VALUE '3000'.

    CLASS-METHODS on_initialization.
    CLASS-METHODS on_output.
    CLASS-METHODS on_event
      IMPORTING
        i_ucomm TYPE sy-ucomm.

    CLASS-METHODS show
      IMPORTING
        i_user TYPE string
      EXPORTING
        e_user TYPE string
        e_pass TYPE string.

  PRIVATE SECTION.
    CLASS-DATA: gv_ok TYPE abap_bool.

ENDCLASS.

CLASS lcl_pwdlg IMPLEMENTATION.

  METHOD on_initialization.
    s_title = 'Loginfenster'.
    s_user  = 'Benutzer'.
    s_pass  = 'Passwort'.
  ENDMETHOD.

  METHOD on_output.
    IF sy-dynnr = lcl_pwdlg=>co_dynnr.
* Wenn Popup angezeigt werden soll

* GUI Status aus Program RSDBRUNT setzen (Ausführen- und Schließen-Button)
      PERFORM set_pf_status IN PROGRAM rsdbrunt IF FOUND.

      DATA: it_ucomm TYPE STANDARD TABLE OF sy-ucomm WITH DEFAULT KEY.

* Prüfen-Button entfernen
      APPEND 'NONE' TO it_ucomm.
* Variante-Speichern-Button entfernen
      APPEND 'SPOS' TO it_ucomm.

      CALL FUNCTION 'RS_SET_SELSCREEN_STATUS'
        EXPORTING
          p_status  = sy-pfkey
        TABLES
          p_exclude = it_ucomm.

      IF NOT p_user IS INITIAL.
* Cursor in Passwort-Feld setzen
        SET CURSOR FIELD 'P_PASS'.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD show.

* User + Passwort setzen
    p_user = i_user.
    CLEAR: p_pass.

    gv_ok = abap_false.

* Selektionsbild CO_DYNNR (das Popup) anzeigen
    CALL SELECTION-SCREEN co_dynnr STARTING AT 15 10 ENDING AT 75 12.

    IF gv_ok = abap_true.
* wenn Popup per Ausführen (F8) oder ENTER geschlossen wird, dann Werte übernehmen
      e_user = p_user.
      e_pass = p_pass.
    ENDIF.

    CLEAR: p_user.
    CLEAR: p_pass.

  ENDMETHOD.

  METHOD on_event.
* Tastendrücke vom Popup abfangen
    IF sy-dynnr = co_dynnr.
      CASE i_ucomm.
        WHEN 'CRET'.
* für Ausführen (F8)
          gv_ok = abap_true.
        WHEN OTHERS.
* für ENTER
          gv_ok = abap_true.
          LEAVE TO SCREEN 0.
      ENDCASE.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

INITIALIZATION.
  b_pop   = 'Popup öffnen'.
* Popup initialisieren
  lcl_pwdlg=>on_initialization( ).

AT SELECTION-SCREEN OUTPUT.
  CASE sy-dynnr.
    WHEN 1000.
* wenn Ereignis aus dem Standart-Selektionsbild (Dynpro 1000) getriggert wird

    WHEN lcl_pwdlg=>co_dynnr.
* wenn Ereignis aus dem Popup (Dynpro CO_DYNNR) getriggert wird
      lcl_pwdlg=>on_output( ).
    WHEN OTHERS.
  ENDCASE.

AT SELECTION-SCREEN.
  CASE sy-dynnr.
    WHEN 1000.
* wenn Ereignis aus dem Standart-Selektionsbild (Dynpro 1000) getriggert wird
      CASE sy-ucomm.
* Button "Popup öffnen" geklickt
        WHEN 'POP'.
* Popup anzeigen
          lcl_pwdlg=>show( EXPORTING i_user = CONV #( sy-uname )
                           IMPORTING e_user = gv_user
                                     e_pass = gv_pass ).
      ENDCASE.
    WHEN lcl_pwdlg=>co_dynnr.
* wenn Ereignis aus dem Popup (Dynpro CO_DYNNR) getriggert wird
      lcl_pwdlg=>on_event( sy-ucomm ).
  ENDCASE.

START-OF-SELECTION.
  WRITE: / gv_user.
  WRITE: / gv_pass.
