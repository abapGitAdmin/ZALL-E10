*&---------------------------------------------------------------------*
*& Modulpool         Z_ARTIKELANLEGEN
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
PROGRAM z_artikelanlegen.

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

TABLES: zdev_artikel.
DATA: ls_artikel TYPE zdev_artikel,
      lt_artikel TYPE TABLE OF zdev_artikel,
      ok_code    TYPE sy-ucomm.

* Interne Tabelle und Workarea
DATA: itab_erf TYPE erf_typ,
      erf_satz TYPE erf_struktur.
DATA: itab_aus TYPE aus_typ,
      aus_satz TYPE aus_struktur.

START-OF-SELECTION.
  CALL SCREEN 100.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS '100'.
  SET TITLEBAR '100'.
  MOVE-CORRESPONDING ls_artikel TO zdev_artikel.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE ok_code.
    WHEN 'ANLEGEN'.

SELECT artikelnr kurztext
      INTO (erf_satz-artikel_nr, erf_satz-kurztext)
      FROM zdev_artikel
      WHERE artikelnr = zdev_artikel-artikelnr .
      ENDSELECT.
      IF sy-subrc = 4. " unbekannte Artikelnummer gefunden
*        MESSAGE i005(zdev) WITH ean.
* ----- Überprüfung der Anzahl ----- *
      ENDIF.
        APPEND erf_satz TO itab_erf.
    WHEN 'UPDATE'.
SELECT artikelnr kurztext
      INTO (erf_satz-artikel_nr, erf_satz-kurztext)
      FROM zdev_artikel
      WHERE artikelnr = zdev_artikel-artikelnr .
      ENDSELECT.
      delete zdev_artikel FROM erf_satz.

    WHEN 'BACK'.

      LEAVE TO SCREEN 0.

          WHEN 'NEXT'.

      LEAVE TO SCREEN 300.
    WHEN OTHERS.

      MOVE-CORRESPONDING zdev_artikel TO ls_artikel.
      SELECT  SINGLE *
        FROM  zdev_artikel
        WHERE artikelnr = @zdev_artikel-artikelnr
        INTO  CORRESPONDING FIELDS OF @ls_artikel.
  ENDCASE.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0300 OUTPUT.
  SET PF-STATUS '100'.
  SET TITLEBAR '100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0300 INPUT.

  CASE sy-ucomm.
    WHEN 'BACK'.
      leave to SCREEN 100.
*    WHEN .
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'MY_TABCONTROL' ITSELF
CONTROLS: MY_TABCONTROL TYPE TABLEVIEW USING SCREEN 0300.

*&SPWIZARD: OUTPUT MODULE FOR TC 'MY_TABCONTROL'. DO NOT CHANGE THIS LIN
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE MY_TABCONTROL_CHANGE_TC_ATTR OUTPUT.
  DESCRIBE TABLE ITAB_ERF LINES MY_TABCONTROL-lines.
ENDMODULE.
