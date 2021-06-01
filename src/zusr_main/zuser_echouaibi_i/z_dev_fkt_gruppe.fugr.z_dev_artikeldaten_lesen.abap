FUNCTION z_dev_artikeldaten_lesen.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(EAN_NR) TYPE  Z_DEV_NR
*"  EXPORTING
*"     REFERENCE(KURZTEXT) TYPE  Z_DEV_KURZTEXT
*"     REFERENCE(LANGTEXT) TYPE  Z_DEV_LANGTEXT
*"     REFERENCE(VK_PREIS) TYPE  Z_DEV_BETRAG
*"     REFERENCE(MWSTSATZ) TYPE  Z_DEV_PROZENT
*"----------------------------------------------------------------------


  DATA: tab_artikel TYPE zdev_artikel,
        tab_mwst    TYPE zdev_mwst.
*&--------------- Überprüfen der Artikelnummer --------------------*
  SELECT SINGLE * FROM zdev_artikel INTO tab_artikel
  WHERE artikelnr = ean_nr .
  IF sy-subrc = 4. " Kein Datensatz mit der Artikelnummer gefunden
    MESSAGE a005(zdev) WITH ean_nr.
  ELSE.
* ----- Ermitteln des MWSTSatzes des Artikel aus Tabelle ----- *
    SELECT SINGLE * FROM zdev_mwst INTO tab_mwst
    WHERE mwstklasse = tab_artikel-mwstklasse.
    IF sy-subrc NE 0.
      MESSAGE a001(zdev) .
    ENDIF.
* ----- Artikelstammdaten in Exportschnittstelle einstellen ----- *
    kurztext = tab_artikel-kurztext.
    langtext = tab_artikel-langtext.
    vk_preis = tab_artikel-verkpreis.
    mwstsatz = tab_mwst-mwstsatz.
  ENDIF.


ENDFUNCTION.
