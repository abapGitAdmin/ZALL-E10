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
REPORT ZLS_MATHE.

DATA: gv_zahl TYPE i,
      gv_dezimalzahl Type p DECIMALS 2 VALUE  '4.20',
      gv_adresse TYPE string,
      gv_dezimalzahl2 LIKE gv_dezimalzahl.

CONSTANTS gc_pi TYPE p DECIMALS 2 VALUE '3.14'.

WRITE: gv_dezimalzahl,
       / gc_pi.

ULINE.

DATA gv_var1 TYPE p DECIMALS 2.
DATA gv_var2 TYPE p DECIMALS 2.
DATA gv_erg TYPE p DECIMALS 2.

gv_var1 = 3.
gv_var2 = 5.

gv_erg = gv_var1 + gv_var2.
WRITE gv_erg.

gv_erg = gv_var1 - gv_var2.
WRITE gv_erg.

gv_erg = gv_var1 + gv_var2.
WRITE gv_erg.

gv_erg = gv_var1 / gv_var2.
WRITE gv_erg.
