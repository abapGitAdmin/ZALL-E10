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
REPORT zps_kalkulation.
**********************************************************************
*Strukturen und Parameter
**********************************************************************
PARAMETERS: p_ope1 TYPE i,
            p_ope2 TYPE i,
            p_ope.

DATA: lv_erg TYPE i. "Speichert das Ergebnis der Rechnung

**********************************************************************
*Programmlogik
CALL FUNCTION 'Z_PS_FB_KALKULATION'
  EXPORTING
    im_operator1       = p_ope1
    im_operator2       = p_ope2
    im_operand         = p_ope
  IMPORTING
    e_ergebnis         = lv_erg
  EXCEPTIONS
    nulldivision       = 1
    operator_ungueltig = 2.

CASE sy-subrc.
  WHEN 0. "Erfolg
    WRITE: 'Ergebnis: ', lv_erg.
  WHEN 1.
    WRITE: 'Fehler: Nulldivision aufgetreten!'.
  WHEN 2.
    WRITE: 'Fehler: ungültiger Operator eingegeben!'.
  WHEN OTHERS.
ENDCASE.
