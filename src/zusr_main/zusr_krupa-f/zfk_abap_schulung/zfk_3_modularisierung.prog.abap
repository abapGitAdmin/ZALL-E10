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
REPORT zfk_3_modularisierung.
**********************************************************************
*INCLUDE Anweisung
**********************************************************************

PARAMETERS p_text TYPE string.

DATA gv_ergebnis type i.

**********************************************************************
* Unterprogramm mit FORM und PEROFRM
**********************************************************************


CALL FUNCTION 'Z_FK_STEIN'
 EXPORTING
   IV_TEST       = p_text
  .







*PERFORM duplicate(zfk_3_modularisierung)
*            USING
*               p_toDoub
*            CHANGING
*               gv_ergebnis.
*
*WRITE gv_ergebnis.


*FORM duplicate USING iv_zahl CHANGING cv_ergebnis.
*
*   cv_ergebnis = 2 * iv_zahl.
*
*ENDFORM.
