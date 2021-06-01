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
REPORT zps_kontrollstrukturen.

**********************************************************************
*Parameter - User-Eingabe
**********************************************************************
PARAMETERS: p_name  TYPE string,
            p_vorna TYPE string,
            p_alter TYPE i.

DATA: lv_i TYPE i.
**********************************************************************
*Kontrollstrukturen
**********************************************************************
"Jünger als 20 -> Schüler
"zw. 20 und 25 -> Student
" Älter als 25 -> Mitarbeiter
WRITE: p_vorna ,p_name, 'ist ein '.
IF p_alter >= 6 AND p_alter  < 20.
  WRITE: 'Schüler'.
ELSEIF p_alter < 26 OR p_vorna ='Philip'.
  WRITE: 'Student',/.
ELSE.
  WRITE: 'Mitrbeiter.', /.
ENDIF.


CASE p_alter.
  WHEN 6.
    WRITE: 'Alter ist 6 Jahre'.
  WHEN 20.
    WRITE: 'Alter ist 20 Jahre'.
  WHEN OTHERS.
    WRITE: 'Alter ist weder 6 noch 20'.
ENDCASE.

**********************************************************************
*Schleifen
**********************************************************************
DO 5 TIMES.
  lv_i = lv_i + p_alter.

ENDDO.
WRITE: lv_i, '|'.

WHILE lv_i > 20.
lv_i = lv_i - 1.
ENDWHILE.
