FUNCTION z_ps_fb_kalkulation.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IM_OPERATOR1) TYPE  I
*"     VALUE(IM_OPERATOR2) TYPE  I
*"     REFERENCE(IM_OPERAND) TYPE  C
*"  EXPORTING
*"     VALUE(E_ERGEBNIS) TYPE  I
*"  EXCEPTIONS
*"      NULLDIVISION
*"      OPERATOR_UNGUELTIG
*"----------------------------------------------------------------------

**********************************************************************
*Programmlogik
**********************************************************************
  IF im_operator2 = 0 AND im_operand = '/'.
    RAISE NULLDIVISION.
  ENDIF.

  CASE im_operand.
    WHEN '+'.
      e_ergebnis = im_operator1 + im_operator2.
    WHEN '-'.
      e_ergebnis = im_operator1 - im_operator2.
    WHEN '*'.
      e_ergebnis = im_operator1 * im_operator2.
    WHEN '/'.
      e_ergebnis = im_operator1 / im_operator2.
    WHEN OTHERS.
      RAISE OPERATOR_UNGUELTIG.
  ENDCASE.

ENDFUNCTION.
