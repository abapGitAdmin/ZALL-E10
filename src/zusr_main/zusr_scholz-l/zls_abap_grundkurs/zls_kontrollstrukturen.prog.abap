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
REPORT ZLS_KONTROLLSTRUKTUREN. " Verarbeitungsblock 1 =

PARAMETERS: p_name TYPE string,
            p_alter TYPE i.

DATA: lv_i TYPE i.

**********************************************************************
* Verzweigung
**********************************************************************
IF p_alter >= 6 AND p_alter < 20.
  WRITE: 'Schüler ', p_name.
ELSEIF p_alter <= 25 OR NOT p_name = 'Kevin'..
    WRITE: 'Student ', p_name.
ELSE.
    WRITE: 'Mitarbeiter ', p_name.
ENDIF.

CASE p_alter.
  WHEN 6.
    WRITE / 'Alter ist 6 Jahre'.
  WHEN 7 OR 8.
    WRITE / 'Alter ist 7 oder 8 Jahre'.
  WHEN OTHERS.
    WRITE / 'Alter ist weder 6, 7 oder 8 Jahre'.
ENDCASE.

**********************************************************************
* Schleifen
**********************************************************************
DO 5 TIMES.
  CHECK lv_i <= 100.

  lv_i = lv_i + p_alter.
ENDDO.

WRITE: /, 'Ergebniss der Multiplikation: ', lv_i.

CHECK lv_i < 100.

WHILE lv_i > 50.
  lv_i = lv_i - 1.
  WRITE lv_i.
ENDWHILE.
