function z_dr_fb_kalkulation.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IV_OP1) TYPE  I
*"     REFERENCE(IV_OP2) TYPE  I
*"     REFERENCE(IV_OP) TYPE  C
*"  EXPORTING
*"     REFERENCE(EV_ERG) TYPE  I
*"  EXCEPTIONS
*"      NULLDIVISION
*"      OPERATOR_UNGUELTIG
*"----------------------------------------------------------------------

  case iv_op.
    when '*'.
      ev_erg = iv_op1 * iv_op2.
    when '/'.
      if iv_op2 = 0.
        raise nulldivision.
      endif.
      ev_erg = iv_op1 / iv_op2.
    when '+'.
      ev_erg = iv_op1 + iv_op2.
    when '-'.
      ev_erg = iv_op1 - iv_op2.
    when others.
      raise operator_ungueltig.
  endcase.



endfunction.
