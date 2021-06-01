************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: BOECKMANN-C                                  Datum: 16.05.2019
*
* Beschreibung: Kalkulation
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************
REPORT zboe_kalkulation.

PARAMETERS: operand1 TYPE i,
            operand2 TYPE i,
            operator.
DATA: gv_ergebnis TYPE i.

CALL FUNCTION 'Z_BOE_KALKULATIONFUBA'
  EXPORTING
    im_operand1 = operand1
    im_operand2 = operand2
    im_operator = operator
IMPORTING
    ev_ergebnis = gv_ergebnis
EXCEPTIONS
  nulldivision = 1
  operator_ungueltig = 2.

CASE sy-subrc.
  WHEN 0.
      WRITE: 'Ergebnis: ', gv_ergebnis.
      ULINE.
  WHEN 1.
      WRITE: 'FEHLER: Nulldivision aufgetreten!'.
  WHEN 2.
      WRITE: 'FEHLER: Der Operant ist üngültig!'.
  WHEN OTHERS.
ENDCASE.
