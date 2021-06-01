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
REPORT zls_modularisierung.

INCLUDE zls_modularisierung_include.

*gv_global_include = p_incl.

PERFORM duplicate(zls_modularisierung)
            USING
               p_zahl
            CHANGING
               gv_ergebnis.

WRITE gv_ergebnis.

CALL FUNCTION 'Z_LS_TEST_FUBA'
 EXPORTING
   IV_TEST       = 'Test'
          .


FORM duplicate USING iv_zahl CHANGING cv_ergebnis.
  cv_ergebnis = 2 * iv_zahl.
ENDFORM.
