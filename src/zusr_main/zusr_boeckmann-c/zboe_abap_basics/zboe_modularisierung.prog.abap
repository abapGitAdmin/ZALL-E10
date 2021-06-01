************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: BOECKMANN-C                                  Datum: 15.04.2019
*
* Beschreibung: Modularisierung
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************

REPORT zboe_modularisierung.

INCLUDE zboe_modularisierung_include.

PERFORM duplicate(zboe_modularisierung)
            USING
               p_zahl
            CHANGING
               gv_ergebnis.

WRITE gv_ergebnis.

CALL FUNCTION 'Z_BOE_TESTFUBA'
 EXPORTING
   IV_TEST       = 'Test'
          .

FORM duplicate USING iv_zahl CHANGING cv_ergebnis.
  cv_ergebnis = 2 * iv_zahl.
ENDFORM.
