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
REPORT z_dev_artikeloeschen.

*&---------------------------------------------------------------------*
*& Global Declarations *
*&---------------------------------------------------------------------*
PARAMETERS: a_nummer TYPE z_dev_nr.
DATA tab_artikel LIKE zdev_artikel.

START-OF-SELECTION.
*&--------------- Überprüfen der Artikelnummer --------------------*
  SELECT SINGLE * FROM zdev_artikel INTO tab_artikel
  WHERE artikelnr = a_nummer.
  IF sy-subrc = 4. " Kein Datensatz mit der Artikelnummer gefunden
    MESSAGE a005(zdev) WITH a_nummer.
  ELSE.
*&--------- Datensatz in Tabelle löschen und Quittung ------*
    DELETE FROM zdev_artikel WHERE artikelnr = a_nummer.
    IF sy-subrc NE 0.
      ROLLBACK WORK.
      MESSAGE a006(zdev) WITH a_nummer.
    ELSE.
      WRITE: / 'Der Artikel ', a_nummer,
      ' wurde erfolgreich gelöscht!'.
    ENDIF.
  ENDIF.
