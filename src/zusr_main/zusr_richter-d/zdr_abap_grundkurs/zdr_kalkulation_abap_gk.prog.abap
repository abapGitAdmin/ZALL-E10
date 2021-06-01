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
report zdr_kalkulation_abap_gk.

parameters: p_oper1  type i,
            p_oper2  type i,
            p_operat.

data lv_ergebnis type i.

call function 'Z_DR_FB_KALKULATION'
  exporting
    iv_op1             = p_oper1
    iv_op2             = p_oper2
    iv_op              = p_operat
  importing
    ev_erg             = lv_ergebnis
  exceptions
    nulldivision       = 1
    operator_ungueltig = 2
    others             = 3.

case sy-subrc.
  when 0.
    write: 'Ergebnis: ', lv_ergebnis.
  when 1.
    write: 'Durch 0 teilen is nicht!'.
  when 2.
    write: 'Operator ist ungültig!'.
  when others.
endcase.
