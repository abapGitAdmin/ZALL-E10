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
REPORT zfk_kalkulation.

PARAMETERS: operand1 TYPE i,
            operand2 TYPE i,
            operator.

DATA: erg_string Type string,
      ergebnis TYPE i.

CALL FUNCTION 'Z_FK_KALKULATION'
  EXPORTING
    iv_op1             = operand1
    iv_op2             = operand2
    iv_ope             = operator
  IMPORTING
    ev_erg             = ergebnis
    ev_strg            = erg_string
  EXCEPTIONS
    nulldivision       = 1
    operator_ungueltig = 2.


CASE sy-subrc.
  WHEN 1.
    WRITE 'Nulldivision aufgetreten!'.
  WHEN 2.
    WRITE 'Ungültiger Operator aufgetreten!'.
  WHEN OTHERS.
    WRITE: erg_string, ergebnis.
ENDCASE.
