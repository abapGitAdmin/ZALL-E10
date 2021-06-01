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
REPORT ZLS_KALKULATION.

PARAMETERS: operand1 TYPE i,
            operand2 TYPE i,
            operator.

DATA: gv_ergebnis TYPE i.

CALL FUNCTION 'Z_LS_FB_KALKULATION'
  EXPORTING
    iv_operand1 = operand1
    iv_operand2 = operand2
    iv_operator = operator
  IMPORTING
    EV_ERGEBNIS = gv_ergebnis
  EXCEPTIONS
    NULLDIVISION             = 1
    OPERATOR_UNGUELTIG       = 2
    OTHER                    = 3
  .

IF sy-subrc = 0.
  WRITE gv_ergebnis.
ELSEIF sy-subrc = 1.
  WRITE 'Nulldivision aufgetreten!'.
ELSEIF sy-subrc = 2.
  WRITE 'Ungältigen Operator gewählt!'.
ELSEIF sy-subrc = 3.
  WRITE 'Ein Fehler ist aufgetreten!'.
ENDIF.
