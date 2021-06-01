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

PROGRAM z_dev_programm_4_4.

TYPES: BEGIN OF erf_struktur,
         artikel_nr TYPE zdev_artikel-artikelnr,
         kurztext   TYPE zdev_artikel-kurztext,
         anzahl     TYPE i,
       END OF erf_struktur.

TYPES: BEGIN OF aus_struktur,
         anzahl      TYPE i,
         kurztext    TYPE zdev_artikel-kurztext,
         stueckpreis TYPE zdev_artikel-verkpreis,
         gesamtpreis TYPE zdev_artikel-verkpreis,
       END OF aus_struktur.

TYPES: erf_typ TYPE STANDARD TABLE OF erf_struktur,
       aus_typ TYPE STANDARD TABLE OF aus_struktur.

* SUBSCREEN KARTENZAHLUNG
DATA: karten_nr TYPE z_dev_nr,
      geheim_nr TYPE z_dev_nr.

TYPES: BEGIN OF karten_struktur,
         karten_nr TYPE z_dev_nr,
         geheim_nr TYPE z_dev_nr,
         status    TYPE c,
       END OF karten_struktur.
DATA: karten_satz TYPE karten_struktur.

* OK_CODE
DATA: ok_code LIKE sy-ucomm,
      save_ok LIKE ok_code.

* Interne Tabelle und Workarea
DATA: itab_erf TYPE erf_typ,
      erf_satz TYPE erf_struktur.
DATA: itab_aus TYPE aus_typ,
      aus_satz TYPE aus_struktur.

DATA: benutzer TYPE z_dev_nr,
      passwort TYPE z_dev_nr.

DATA: ean         TYPE z_dev_nr,
      anzahl      TYPE i,
      bar         TYPE z_dev_betrag,
      rueck       TYPE z_dev_betrag,
      summe       TYPE z_dev_betrag,
      mwst        TYPE z_dev_betrag,
      mwst_gesamt TYPE z_dev_betrag,
      mwstsatz    TYPE z_dev_prozent.

START-OF-SELECTION.
  CALL SCREEN 100.
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS '100'.
  SET TITLEBAR '100'.
  CLEAR: benutzer, passwort.
ENDMODULE. " STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*& Module USER_COMMAND_0100 INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  save_ok = ok_code.
  CLEAR ok_code.
  CASE save_ok.
    WHEN 'EXIT' OR 'BACK' OR 'CANCEL'.
      LEAVE PROGRAM.
    WHEN 'LOGON'.
      IF ( benutzer = 'ILIASS' ) AND
      ( passwort = '123456' ).
        CLEAR itab_erf.
        LEAVE TO SCREEN 200.
      ENDIF.
  ENDCASE.
ENDMODULE. " USER_COMMAND_0100 INPUT
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS '200'.
  SET TITLEBAR '200'.
  CLEAR: erf_satz, ean, anzahl.
ENDMODULE. " STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*& Module USER_COMMAND_0200 INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0200 INPUT.
  save_ok = ok_code.
  CLEAR ok_code.
  CASE save_ok.
    WHEN 'ADD'.
*&--------------- Überprüfen der Artikelnummer --------------------*
      SELECT artikelnr kurztext
      INTO (erf_satz-artikel_nr, erf_satz-kurztext)
      FROM zdev_artikel
      WHERE artikelnr = ean .
      ENDSELECT.
      IF sy-subrc = 4. " unbekannte Artikelnummer gefunden
        MESSAGE i005(zdev) WITH ean.
* ----- Überprüfung der Anzahl ----- *
      ELSEIF anzahl < 0 .
        MESSAGE i009(zdev) .
      ELSE.
* ----- Satz an Artikelliste anhängen ----- *
        erf_satz-anzahl = anzahl.
        APPEND erf_satz TO itab_erf.
      ENDIF.
    WHEN 'EXIT' OR 'BACK' OR 'CANCEL'.
      LEAVE PROGRAM.
    WHEN 'BELEG'.
      CLEAR: itab_aus, bar, rueck, summe, mwst, mwst_gesamt.
      LOOP AT itab_erf INTO erf_satz.
        CLEAR: aus_satz, mwstsatz.
        aus_satz-anzahl = erf_satz-anzahl.
* ----- fehlende Artikeldaten mittels Funktionsbaustein ermitteln --
        CALL FUNCTION 'Z_DEV_ARTIKELDATEN_LESEN'
          EXPORTING
            ean_nr   = erf_satz-artikel_nr
          IMPORTING
            kurztext = aus_satz-kurztext
*           LANGTEXT =
            vk_preis = aus_satz-stueckpreis
            mwstsatz = mwstsatz.
        aus_satz-gesamtpreis = aus_satz-anzahl * aus_satz-stueckpreis.
        summe = summe + aus_satz-gesamtpreis.
        CLEAR mwst.
* ----- fehlende MWSTSatz mittels Funktionsbaustein ermitteln --
        CALL FUNCTION 'Z_DEV_ENTHALTENE_MWST'
          EXPORTING
            bruttowert = aus_satz-gesamtpreis
            mwstsatz   = mwstsatz
          IMPORTING
            mwst       = mwst.
        mwst_gesamt = mwst_gesamt + mwst.
        APPEND aus_satz TO itab_aus.
      ENDLOOP.
      LEAVE TO SCREEN 300.
  ENDCASE.
ENDMODULE. " USER_COMMAND_0200 INPUT
*&---------------------------------------------------------------------*
*& Module STATUS_0300 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0300 OUTPUT.
  SET PF-STATUS '300'.
  SET TITLEBAR '300'.
ENDMODULE. " STATUS_0300 OUTPUT
*&---------------------------------------------------------------------*
*& Module USER_COMMAND_0300 INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0300 INPUT.
  save_ok = ok_code.
  CLEAR ok_code.
  CASE save_ok.
    WHEN 'CASH'.
      IF ( bar < summe ).
        MESSAGE i010(zdev).
      ELSE.
        rueck = bar - summe .
      ENDIF.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'ENDE'.
      LEAVE PROGRAM.
    WHEN 'NEXT'.
      CLEAR itab_erf.
      CLEAR itab_aus.
      LEAVE TO SCREEN 200.
    WHEN 'BACK'.
      LEAVE TO SCREEN 200.
    WHEN 'PRUEFEN'.
*&---- Lesen des Datensatzes aus der Tabelle ZDEV_KARTEN ----*
      SELECT SINGLE * FROM zdev_karten INTO karten_satz
      WHERE karten_nr = karten_nr .
*&--------------- Überprüfen der Kartennummer --------------------*
      IF sy-subrc = 4. " unbekannte Kartennummer gefunden
        MESSAGE i013(zdev) WITH karten_nr.
* -------------- Überprüfung der Geheimzahl --------------------- *
      ELSE.
        IF geheim_nr NE karten_satz-geheim_nr .
          MESSAGE i014(zdev) .
        ELSE.
* -------------- Überprüfung des Kartenstatus ------------------- *
          IF karten_satz-status = 'G'.
            MESSAGE i015(zdev) .
          ELSE.
            MESSAGE i016(zdev) WITH summe .
            CLEAR itab_erf.
            CLEAR itab_aus.
            LEAVE TO SCREEN 200.
          ENDIF.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDMODULE. " USER_COMMAND_0300 INPUT

*&SPWIZARD: DECLARATION OF TABLECONTROL 'Z_CONTROL' ITSELF
CONTROLS: z_control TYPE TABLEVIEW USING SCREEN 0200.

*&SPWIZARD: OUTPUT MODULE FOR TC 'Z_CONTROL'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE z_control_change_tc_attr OUTPUT.
  DESCRIBE TABLE itab_erf LINES z_control-lines.
ENDMODULE.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'Z_AUSCONTROL' ITSELF
CONTROLS: z_auscontrol TYPE TABLEVIEW USING SCREEN 0300.

*&SPWIZARD: OUTPUT MODULE FOR TC 'Z_AUSCONTROL'. DO NOT CHANGE THIS LINE
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE z_auscontrol_change_tc_attr OUTPUT.
  DESCRIBE TABLE itab_aus LINES z_auscontrol-lines.
ENDMODULE.

*&SPWIZARD: FUNCTION CODES FOR TABSTRIP 'Z_TABSTRIB'
CONSTANTS: BEGIN OF c_z_tabstrib,
             tab1 LIKE sy-ucomm VALUE 'Z_TABSTRIB_FC1',
             tab2 LIKE sy-ucomm VALUE 'Z_TABSTRIB_FC2',
           END OF c_z_tabstrib.
*&SPWIZARD: DATA FOR TABSTRIP 'Z_TABSTRIB'
CONTROLS:  z_tabstrib TYPE TABSTRIP.
DATA: BEGIN OF g_z_tabstrib,
        subscreen   LIKE sy-dynnr,
        prog        LIKE sy-repid VALUE 'Z_DEV_PROGRAMM_4_4',
        pressed_tab LIKE sy-ucomm VALUE c_z_tabstrib-tab1,
      END OF g_z_tabstrib.

*&SPWIZARD: OUTPUT MODULE FOR TS 'Z_TABSTRIB'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: SETS ACTIVE TAB
MODULE z_tabstrib_active_tab_set OUTPUT.
  z_tabstrib-activetab = g_z_tabstrib-pressed_tab.
  CASE g_z_tabstrib-pressed_tab.
    WHEN c_z_tabstrib-tab1.
      g_z_tabstrib-subscreen = '0301'.
    WHEN c_z_tabstrib-tab2.
      g_z_tabstrib-subscreen = '0302'.
    WHEN OTHERS.
*&SPWIZARD:      DO NOTHING
  ENDCASE.
ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TS 'Z_TABSTRIB'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GETS ACTIVE TAB
MODULE z_tabstrib_active_tab_get INPUT.
  ok_code = sy-ucomm.
  CASE ok_code.
    WHEN c_z_tabstrib-tab1.
      g_z_tabstrib-pressed_tab = c_z_tabstrib-tab1.
    WHEN c_z_tabstrib-tab2.
      g_z_tabstrib-pressed_tab = c_z_tabstrib-tab2.
    WHEN OTHERS.
*&SPWIZARD:      DO NOTHING
  ENDCASE.
ENDMODULE.
