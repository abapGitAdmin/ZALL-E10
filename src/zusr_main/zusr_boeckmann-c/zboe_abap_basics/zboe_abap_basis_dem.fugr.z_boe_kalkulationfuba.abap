FUNCTION z_boe_kalkulationfuba.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IM_OPERAND1) TYPE  I
*"     VALUE(IM_OPERAND2) TYPE  I
*"     REFERENCE(IM_OPERATOR) TYPE  C
*"  EXPORTING
*"     VALUE(EV_ERGEBNIS) TYPE  I
*"  EXCEPTIONS
*"      NULLDIVISION
*"      OPERATOR_UNGUELTIG
*"----------------------------------------------------------------------

  CASE im_operator.
    WHEN '+'.
      ev_ergebnis = im_operand1 + im_operand2.
    WHEN '-'.
      ev_ergebnis = im_operand1 - im_operand2.
    WHEN '*'.
      ev_ergebnis = im_operand1 * im_operand2.
    WHEN '/'.
      IF im_operand2 = 0.
        RAISE nulldivision.
      ELSEIF
          ev_ergebnis = im_operand1 / im_operand2.
      ENDIF.
    WHEN OTHERS.
      WRITE: 'Kein gültiger Operator!'.
  ENDCASE.

ENDFUNCTION.
