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
REPORT z_dev_neuerpreis.

*&---------------------------------------------------------------------*
*& Global Declarations *
*&---------------------------------------------------------------------*
PARAMETERS: a_nummer TYPE z_dev_nr,
            neupreis TYPE z_dev_betrag.
DATA: tab_artikel TYPE zdev_artikel.

START-OF-SELECTION.
*&--------------- Überprüfen der Artikelnummer --------------------*
  SELECT SINGLE * FROM zdev_artikel INTO tab_artikel
  WHERE artikelnr = a_nummer.
  IF sy-subrc = 4. " Kein Datensatz mit der Artikelnummer gefunden
    MESSAGE a005(zdev) WITH a_nummer.
  ELSE.

*&--------------- Datensatz aufbereiten und Änderungsmeldung ---------*
    WRITE: / 'Artikel-Nummer: ', a_nummer,
    tab_artikel-kurztext,
    / 'VK_Preis (alt): ', tab_artikel-verkpreis.
    tab_artikel-verkpreis = neupreis.
    WRITE: / 'VK_Preis (neu): ', tab_artikel-verkpreis.
*&--------- geänderten Datensatz in Tabelle zurückschreiben ----------*
    UPDATE zdev_artikel FROM tab_artikel.
    IF sy-subrc NE 0.
      ROLLBACK WORK.
      MESSAGE a004(zdev).
    ELSE.
      WRITE 'Preis des Artikels wurde geändert.'.
    ENDIF.
  ENDIF.
