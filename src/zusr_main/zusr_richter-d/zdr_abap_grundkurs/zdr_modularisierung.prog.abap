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
report zdr_modularisierung.

include zdr_modularisierung_include.

*gv_global_include = p_incl.

perform dulicate(zdr_modularisierung)
      using
        p_zahl
      changing
        gv_ergebnis.

write gv_ergebnis.

call function 'Z_DR_TESTFUBA'
 EXPORTING
   IV_TEST       = 'Test'
  .

form dulicate using iv_zahl changing cv_ergebnis.
  cv_ergebnis = 2 * iv_zahl.
endform.
