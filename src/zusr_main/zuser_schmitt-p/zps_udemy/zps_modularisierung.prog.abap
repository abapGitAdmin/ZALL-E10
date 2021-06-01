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
REPORT zps_modularisierung.

INCLUDE zps_modularisierung_include.

*Aufruf eines unterprogramms ()
PERFORM duplicate(zps_modularisierung)
            USING
               p_zahl "p_zahl stammt aus dem Include
            CHANGING
               gv_ergebnis. "gv_ergebnis stammt aus dem Include

WRITE: gv_ergebnis.



**********************************************************************
*Methode
**********************************************************************
*iv_zahl = imporing Variable
*cv_ergebnis = changing variable
FORM duplicate USING iv_zahl CHANGING cv_ergebnis.


  cv_ergebnis = iv_zahl * 2 .
ENDFORM.
