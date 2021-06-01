FUNCTION Z_LS_FB_KALKULATION.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IV_OPERAND1) TYPE  I
*"     VALUE(IV_OPERAND2) TYPE  I
*"     REFERENCE(IV_OPERATOR) TYPE  C
*"  EXPORTING
*"     VALUE(EV_ERGEBNIS) TYPE  I
*"  EXCEPTIONS
*"      NULLDIVISION
*"      OPERATOR_UNGUELTIG
*"----------------------------------------------------------------------


CASE IV_OPERATOR.
  WHEN '+'.
    EV_ERGEBNIS = IV_OPERAND1 + IV_OPERAND2.
  WHEN '-'.
    EV_ERGEBNIS = IV_OPERAND1 - IV_OPERAND2.
  WHEN '*'.
    EV_ERGEBNIS = IV_OPERAND1 * IV_OPERAND2.
  WHEN '/'.
    IF IV_OPERAND2 = 0.
      RAISE NULLDIVISION.
    ENDIF.
    EV_ERGEBNIS = IV_OPERAND1 / IV_OPERAND2.
  WHEN OTHERS.
    RAISE OPERATOR_UNGUELTIG.
ENDCASE.


ENDFUNCTION.
