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
REPORT z_dev_programm_2_5.


TYPES: betrag TYPE p DECIMALS 2,
       BEGIN OF datumstyp ,
         jahr(4)  TYPE c,
         monat(2) TYPE c, tag(2) TYPE c,
       END OF datumstyp .

PARAMETERS: summe TYPE betrag,
            bar   TYPE betrag.

DATA: mwst        TYPE betrag,
      rubetrag    TYPE betrag,
      datum       TYPE datumstyp,
      anzahl_tage TYPE i.
CONSTANTS mwstsatz TYPE betrag VALUE '19.00' .

*&---------------------------------------------------------------------*
*& Processing Blocks called by the Runtime Environment *
*&---------------------------------------------------------------------*
START-OF-SELECTION .

* ----- Überprüfung der Eingabe ----- *
  IF bar < summe .
    MESSAGE a000(zdev) .
  ENDIF.

* ----- Berechnung des Rückgabebetrags ----- *
  rubetrag = bar - summe .

* ----- Berechnung der MWST mittels Funktionsbaustein ----- *
  CALL FUNCTION 'Z_DEV_ENTHALTENE_MWST'
    EXPORTING
      bruttowert = summe
      mwstsatz   = mwstsatz
    IMPORTING
      mwst       = mwst.

* ----- Ausgabe des Kassenbelegs ----- *
  datum = sy-datum .
  WRITE: / ' Kassenbeleg der Kaufrausch AG' ,
  / ' Ihr Einkauf vom ' ,
  datum-tag, datum-monat ,datum-jahr .
  SKIP .
  WRITE: / 'Rechnungsbetrag: ' , 20 summe ,
  / 'erhalten in Bar: ' , bar UNDER summe .
  ULINE .
  WRITE: / 'Rückgabebetrag : ' , rubetrag UNDER summe.
  SKIP .
  WRITE: / 'enthaltene MWST: ' , mwst UNDER summe .
  SKIP .
  WRITE / '-- Vielen Dank für Ihren Einkauf --' .

* ----- Werbung auf dem Kassenbeleg ----- *
  IF ( datum-monat = '10' ) AND ( datum-tag < 20 ) .
    anzahl_tage = 21 - datum-tag .
    WRITE: / ' ... und nicht vergessen:' ,
    / 'in ' , anzahl_tage , ' Tagen beginnt der Schlussverkauf!'.
  ELSEIF ( datum-monat = '04' ) AND ( datum-tag = 21 ) .
    WRITE: / ' ... und nicht vergessen:' ,
    / ' Morgen beginnt der Schlussverkauf !' .
  ENDIF.
