************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: BOECKMANN-C                                  Datum: 21.05.2019
*
* Beschreibung:
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************

REPORT zboe_feldsymbole_uhrzeit.

**********************************************************************
* Implizit
**********************************************************************

*TYPES: BEGIN OF lty_uhrzeit,
*         stunde(2)  TYPE n,
*         minute(2)  TYPE n,
*         sekunde(2) TYPE n,
*       END OF lty_uhrzeit.
*
*
*FIELD-SYMBOLS <uhrzeit> TYPE lty_uhrzeit.
*
*ASSIGN sy-uzeit TO <uhrzeit> CASTING.
*
*WRITE: <uhrzeit>-stunde, <uhrzeit>-minute, <uhrzeit>-sekunde.

**********************************************************************
* Explizit
**********************************************************************

TYPES: BEGIN OF lty_uhrzeit,
         stunde(2)  TYPE n,
         minute(2)  TYPE n,
         sekunde(2) TYPE n,
       END OF lty_uhrzeit.

FIELD-SYMBOLS <uhrzeit> TYPE any.
FIELD-SYMBOLS <wert> TYPE n.


ASSIGN sy-uzeit TO <uhrzeit> CASTING TYPE lty_uhrzeit.
DO.
  ASSIGN COMPONENT sy-index OF STRUCTURE <uhrzeit> TO <wert>.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.
  WRITE / <wert>.
*  WRITE: <uhrzeit>-stunde, <uhrzeit>-minute, <uhrzeit>-sekunde.
ENDDO.
