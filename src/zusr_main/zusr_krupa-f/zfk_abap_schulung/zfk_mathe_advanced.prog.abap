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
REPORT zfk_mathe_advanced.

DATA gv_zahl1 TYPE p DECIMALS 2 VALUE 14.
DATA gv_zahl2 TYPE p DECIMALS 2 VALUE 5.
DATA gv_erg TYPE p DECIMALS 2.


gv_erg = gv_zahl1 DIV gv_zahl2.
WRITE gv_erg.

gv_erg = gv_zahl1 MOD gv_zahl2.
WRITE / gv_erg.

WRITE / gv_zahl2.

gv_erg = 2 ** 3.
WRITE / gv_erg.

ULINE.
Data gv_int type i.


write gv_int.



*DATA: gv_string TYPE string VALUE 'Hallo!',
*      gv_zahl   TYPE i VALUE 5.
*
*WRITE gv_string.
*
*gv_string = gv_zahl.
*
*gv_string = '5'.
*
*gv_zahl = gv_string.
*
*WRITE gv_zahl.
