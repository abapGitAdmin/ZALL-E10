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
REPORT z_dev_neuerartikel.

*&---------------------------------------------------------------------*
*& Global Declarations *
*&---------------------------------------------------------------------*
PARAMETERS: a_nummer TYPE z_dev_nr,
            kurztext TYPE z_dev_kurztext,
            langtext TYPE z_dev_langtext,
            vk_preis TYPE z_dev_betrag,
            mwst_kls TYPE z_dev_nr.
DATA: tab_mwst    TYPE zdev_mwst,
      tab_artikel TYPE zdev_artikel.

START-OF-SELECTION.
*&--------------- Überprüfen der Artikelnummer --------------------*
  SELECT SINGLE * FROM zdev_artikel INTO tab_artikel
  WHERE artikelnr = a_nummer.
  IF sy-subrc = 4. " Kein Datensatz mit der Artikelnummer gefunden


*&--------------- Überprüfen der MWST-Klasse --------------------*
    SELECT SINGLE * FROM zdev_mwst INTO tab_mwst
    WHERE mwstklasse = mwst_kls.
    IF sy-subrc NE 0.
      MESSAGE a001(zdev) .
    ENDIF.

*&--------------- Datensatz aufbereiten -----------------*
    CLEAR tab_artikel.
    tab_artikel-artikelnr = a_nummer.
    tab_artikel-kurztext = kurztext.
    tab_artikel-langtext = langtext.
    tab_artikel-verkpreis = vk_preis.
    tab_artikel-mwstklasse = mwst_kls.


*&--------------- neuen Datensatz in Tabelle einfügen -----------------*
    INSERT INTO zdev_artikel VALUES tab_artikel.
    IF sy-subrc NE 0.
      ROLLBACK WORK.
      MESSAGE a003(zdev).
    ELSE.
      WRITE 'Datensatz wurde hinzugefügt.'.
    ENDIF.
  ELSE. " Artikelnummer bereits vorhanden
    MESSAGE a002(zdev) WITH a_nummer.
  ENDIF.
