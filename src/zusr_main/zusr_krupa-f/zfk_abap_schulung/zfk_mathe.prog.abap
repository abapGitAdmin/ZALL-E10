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
REPORT zfk_mathe.
DATA: gv_zahl1       TYPE i,
      gv_dezimalzahl TYPE p DECIMALS 2 VALUE '4.20',
      gv_adresse     TYPE string VALUE 'lel'.

CONSTANTS gc_pi TYPE p DECIMALS 2 VALUE '3.14'.

*WRITE: gv_zahl1,
*/ gc_pi.

DATA: gv_var1 TYPE p DECIMALS 2,
      gv_var2 TYPE p DECIMALS 2,
      gv_erg  TYPE p DECIMALS 2.

gv_var1 = 3.
gv_var2 = 5.

gv_erg = gv_var1 + gv_var2.
WRITE / gv_erg.

gv_erg = gv_var1 - gv_var2.
WRITE / gv_erg.

gv_erg = gv_var1 * gv_var2.
WRITE / gv_erg.

gv_erg = gv_var1 / gv_var2.
WRITE / gv_erg.
