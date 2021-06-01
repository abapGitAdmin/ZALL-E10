FUNCTION z_fk_kalkulation.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IV_OP1) TYPE  I
*"     VALUE(IV_OP2) TYPE  I
*"     REFERENCE(IV_OPE) TYPE  C
*"  EXPORTING
*"     VALUE(EV_ERG) TYPE  I
*"     VALUE(EV_STRG) TYPE  STRING
*"  EXCEPTIONS
*"      NULLDIVISION
*"      OPERATOR_UNGUELTIG
*"----------------------------------------------------------------------



  CASE  iv_ope.
    WHEN '+'.
      ev_erg = iv_op1 + iv_op2.
      ev_strg = 'Ergebnis der Addition:'.
    WHEN '-'.
      ev_erg = iv_op1 - iv_op2.
      ev_strg = 'Ergebnis der Subtraktion:'.
    WHEN '*'.
      ev_erg = iv_op1 * iv_op2.
      ev_strg = 'Ergebnis der Multiplikation:'.
    WHEN '/'.
      IF iv_op2 = 0.
        RAISE nulldivision.
      ELSE.
        ev_erg = iv_op1 / iv_op2.
        ev_strg = 'Ergebnis der Division:'.
      ENDIF.
    WHEN OTHERS.
      RAISE operator_ungueltig.
  ENDCASE.

ENDFUNCTION.
