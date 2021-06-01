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
REPORT ZLS_MATHE_ADVANCED.

*DATA: gv_string TYPE string VALUE 'Hallo',
*      gv_zahl   TYPE i VALUE 5,
*      gv_erg    TYPE p DECIMALS 2.
*
*WRITE gv_string.
*
*gv_string = gv_zahl.
*
*WRITE gv_string.
*
*gv_string = 'HAllo'.
*gv_zahl = gv_string.
*gv_erg = gv_zahl * gv_string.

DATA gv_zahl1 TYPE p DECIMALS 2 VALUE 3.
DATA gv_zahl2 TYPE p DECIMALS 2 VALUE 2.
DATA gv_erg TYPE p DECIMALS 2.

gv_erg = gv_zahl1 / gv_zahl2.
WRITE gv_erg.

gv_erg = gv_zahl1 DIV gv_zahl2.
WRITE gv_erg.

gv_erg = gv_zahl1 MOD gv_zahl2.

gv_erg = gv_zahl1 ** gv_zahl2. "3 hoch 2
WRITE gv_erg.
