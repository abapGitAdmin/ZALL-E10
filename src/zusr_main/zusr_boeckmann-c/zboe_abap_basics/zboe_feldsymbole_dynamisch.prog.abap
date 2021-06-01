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

REPORT ZBOE_FELDSYMBOLE_DYNAMISCH.

*DATA: lv_zahl TYPE i VALUE 10,
*      lv_name TYPE string VALUE 'Meier'.
*
*FIELD-SYMBOLS <feldsymbol> TYPE ANY.
*
**ASSIGN lv_zahl TO <feldsymbol>.
**
**<feldsymbol> = 20.
**
**ASSIGN lv_name TO <feldsymbol>.
**<feldsymbol> = 'Schmidt'.
**
**WRITE: lv_zahl, lv_name.
*
*
*FIELD-SYMBOLS <zahl> TYPE ANY.
*FIELD-SYMBOLS <name> TYPE ANY.
*
*ASSIGN lv_zahl TO <zahl>.
*ASSIGN lv_name TO <name>.
*
*<zahl> = <name>.


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
FIELD-SYMBOLS <tabelle> TYPE STANDARD TABLE.

ASSIGN gs_personen TO <personen>.
ASSIGN gt_personen TO <tabelle>.
<personen>-name = 'Müller'.
<personen>-alter = 45.
APPEND <personen> TO <tabelle>.

<personen>-name = 'Meier'.
<personen>-alter = 25.
APPEND <personen> TO <tabelle>.

LOOP AT <tabelle> ASSIGNING <personen>.
  WRITE: / <personen>-name, <personen>-alter.
ENDLOOP.
