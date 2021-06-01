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
REPORT z_dev_artikelliste.

*&---------------------------------------------------------------------*
*& Global Declarations *
*&---------------------------------------------------------------------*
DATA tab_artikel LIKE zdev_artikel .
DATA mwst TYPE p DECIMALS 2.
*&---------------------------------------------------------------------*
*& Processing Blocks called by the Runtime Environment *
*&---------------------------------------------------------------------*
START-OF-SELECTION.
  WRITE /10 'In Tabelle ZDEV_ARTIKEL gespeicherte Datensätze:'.
  SKIP.
  WRITE: / 'Artikelnr.', 14 'Bezeichnung', 35 'Verkaufspreis',
  57 'MWST-Satz'.
  SKIP.
  SELECT * FROM zdev_artikel INTO tab_artikel.
    WRITE: / tab_artikel-artikelnr,
    tab_artikel-kurztext,
    tab_artikel-verkpreis.

    SELECT mwstsatz FROM zdev_mwst INTO mwst WHERE mwstklasse = tab_artikel-mwstklasse.
      WRITE mwst.
    ENDSELECT.
  ENDSELECT.
  SKIP.
  WRITE: / '------------------------',
  ' Ende der Liste -------------------------'.
