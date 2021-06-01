*----------------------------------------------------------------------*
***INCLUDE Z_BCALV_TREE_02_USER_COMMANI04.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0400 INPUT.

  CASE ok_code.
    WHEN 'RERSTL'.
      IF ( bar < summe ).
        MESSAGE i010(zdev).
      ELSE.
        rueck = bar - summe .
      ENDIF.

      SELECT * FROM zrechnungen INTO TABLE gt_rechnungen.

      SORT gt_rechnungen DESCENDING BY rechnungnr.

      READ TABLE gt_rechnungen INTO ls_rechnung INDEX 1.

      ls_rechnung-rechnungnr = ls_rechnung-rechnungnr + 1.
      ls_rechnung-gesamtpreis = summe.

      MODIFY zrechnungen FROM ls_rechnung.


    WHEN 'BACK'.
      LEAVE TO SCREEN 100.
    WHEN 'CHECK'.
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
*            CLEAR itab_erf.
*            CLEAR itab_aus.
*            LEAVE TO SCREEN 200.
          ENDIF.
        ENDIF.
      ENDIF.
  ENDCASE.

ENDMODULE.
