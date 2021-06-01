************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: XXXXX-X                                      Datum: TT.MM.JJJJ
*
* Beschreibung:
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************

REPORT zboe_mathe.

*DATA: gv_zahl1 TYPE i, "noramle Variablen Deklaration
*      gv_dezimalzahl TYPE P DECIMALS 2 VALUE '4.20', "Variablen Deklaration mit Nachkommastelle und vordefiniertem Wert
*      gv_adresse TYPE string,
*      gv_var1 TYPE p DECIMALS 2 VALUE '3',
*      gv_var2 TYPE p DECIMALS 2 VALUE '5',
*      gv_erg TYPE p DECIMALS 2,
*      gv_string TYPE string VALUE 'Hallo!',
*      gv_zahl TYPE i VALUE 5.
*
**      gv_dezimalzahl2 LIKE gv_dezimalzahl,
**      gv_name LIKE mara-ernam.
*
*CONSTANTS gc_pi TYPE p DECIMALS 2 VALUE '3.14'.
*
*WRITE: gv_dezimalzahl,
*        / gc_pi.
*
**gv_erg = gv_var1 + gv_var2.
**
**ADD gv_var1 TO gv_erg.
**
**WRITE / gv_erg.
**gv_erg = gv_var1 - gv_var2.
**WRITE / gv_erg.
**gv_erg = gv_var1 * gv_var2.
**WRITE / gv_erg.
**gv_erg = gv_var1 / gv_var2.
**WRITE / gv_erg.
*
*WRITE gv_string.
*
*gv_string = '3'.
*
*gv_zahl = gv_string.
*
*gv_erg = gv_zahl * gv_string.
*
*WRITE / gv_erg.

DATA: gv_zahl1 TYPE p DECIMALS 2 VALUE 7,
      gv_zahl2 TYPE p DECIMALS 2 VALUE 2,
      gv_erg   TYPE p DECIMALS 2.

gv_erg = gv_zahl1 / gv_zahl2.
WRITE: gv_erg.

gv_erg = gv_zahl1 DIV gv_zahl2.
WRITE / gv_erg.

gv_erg = gv_zahl1 MOD gv_zahl2.
WRITE / gv_erg.

gv_erg = gv_zahl1 ** gv_zahl2. "2 hoch 7
WRITE / gv_erg.
