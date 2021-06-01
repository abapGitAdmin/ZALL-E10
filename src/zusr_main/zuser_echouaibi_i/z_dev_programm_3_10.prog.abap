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
REPORT z_dev_programm_3_10.
*&---------------------------------------------------------------------*
*& Global Declarations *
*&---------------------------------------------------------------------*
TYPES: betrag TYPE p DECIMALS 2,
       BEGIN OF datumstyp ,
         jahr(4)  TYPE c,
         monat(2) TYPE c,
         tag(2)   TYPE c,
       END OF datumstyp .

PARAMETERS: ean_nr TYPE z_dev_nr,
            bar    TYPE betrag.

DATA: mwst        TYPE betrag,
      rubetrag    TYPE betrag,
      datum       TYPE datumstyp,
      anzahl_tage TYPE i,
      tab_artikel TYPE zdev_artikel,
      tab_mwst    TYPE zdev_mwst.

START-OF-SELECTION .


*---------- Lesen der Artikeldaten mittels Funktionsbaustein ----------*
  CALL FUNCTION 'Z_DEV_ARTIKELDATEN_LESEN'
    EXPORTING
      ean_nr   = ean_nr
    IMPORTING
      kurztext = tab_artikel-kurztext
      langtext = tab_artikel-langtext
      vk_preis = tab_artikel-verkpreis
      mwstsatz = tab_mwst-mwstsatz.

  IF bar < tab_artikel-verkpreis .
    MESSAGE a000(zdev).

* ----- Berechnung des Rückgabebetrags ----- *
  ELSE.
    rubetrag = bar - tab_artikel-verkpreis .

* ----- Berechnung der MWST mittels Funktionsbaustein ----- *
    CALL FUNCTION 'Z_DEV_ENTHALTENE_MWST'
      EXPORTING
        bruttowert = tab_artikel-verkpreis
        mwstsatz   = tab_mwst-mwstsatz
      IMPORTING
        mwst       = mwst.

* ----- Ausgabe des Kassenbelegs ----- *
    datum = sy-datum .
    WRITE: / ' Kassenbeleg der Kaufrausch AG' ,
    / ' Ihr Einkauf vom ' ,
    datum-tag, datum-monat ,datum-jahr .
    SKIP .
    WRITE: / ' EAN_Nummer', 19 'Artikel', 40 'Betrag'.
    SKIP.

    WRITE: / ean_nr ,
    tab_artikel-kurztext , 34 tab_artikel-verkpreis .
    SKIP.
    WRITE: / 'erhalten in Bar: ' , 31 bar .
    ULINE .

    WRITE: / 'Rückgabebetrag : ' , rubetrag UNDER bar.
    SKIP .
    WRITE: / 'enthaltene MWST: ' , mwst UNDER bar.
    SKIP .
    WRITE / '-------- Vielen Dank für Ihren Einkauf --------' .
* ----- Werbung auf dem Kassenbeleg ----- *
    IF ( datum-monat = '10' ) AND ( datum-tag < 20 ) .
      anzahl_tage = 21 - datum-tag .
      WRITE: / ' ... und nicht vergessen:' ,
      / 'in ' , anzahl_tage , ' Tagen beginnt der Schlussverkauf !'.
    ELSEIF ( datum-monat = '10' ) AND ( datum-tag = 21 ) .
      WRITE: / ' ... und nicht vergessen:' ,
      / ' Morgen beginnt der Schlussverkauf !' .
    ENDIF.
  ENDIF.
