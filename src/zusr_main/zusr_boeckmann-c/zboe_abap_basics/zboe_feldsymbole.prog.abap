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

REPORT zboe_feldsymbole.

DATA lv_zahl TYPE i VALUE 5.

FIELD-SYMBOLS <feldsymbol> TYPE i.

ASSIGN lv_zahl TO <feldsymbol>.

UNASSIGN <feldsymbol>.

IF <feldsymbol> IS ASSIGNED.
  <feldsymbol> = 20.
  WRITE lv_zahl.
ELSE.
  WRITE 'Keine Zuweisung vorhanden!'.
ENDIF.

**********************************************************************
* Übungsaufgabe
**********************************************************************
TYPES: BEGIN OF lty_personen,
         name  TYPE string,
         alter TYPE i,
       END OF lty_personen.

DATA: gt_personen TYPE TABLE OF lty_personen,
      gs_personen TYPE lty_personen.

FIELD-SYMBOLS <personen> TYPE lty_personen.

ASSIGN gs_personen TO <personen>.

<personen>-name = 'Müller'.
<personen>-alter = 45.
APPEND <personen> TO gt_personen.

<personen>-name = 'Meier'.
<personen>-alter = 25.
APPEND <personen> TO gt_personen.

LOOP AT gt_personen ASSIGNING <personen>.
  WRITE: / <personen>-name, <personen>-alter.
ENDLOOP.
