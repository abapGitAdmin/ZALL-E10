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
REPORT zfk_3_kontrollstrukturen.
PARAMETERS: p_name  TYPE string,
            p_alter TYPE i.

DATA: gv_erg type i,
      gv_expo type i VALUE 0.

**********************************************************************
* Altersbedingte Ausgabe
**********************************************************************


" IF
IF p_alter >= 6 AND p_alter < 22.
  WRITE 'Schüler'.
ELSEIF p_alter < 26 .
  WRITE 'Student'.
ELSE.
  WRITE 'Mitarbeiter'.
ENDIF.


 " CASE
CASE p_name.
  WHEN 'FLORIAN'.
    WRITE 'Richtiger G'.
  WHEN 'LARS'.
    WRITE 'halber G'.
  WHEN OTHERS.
    WRITE 'garnix'.
ENDCASE.


**********************************************************************
* Schleifen
**********************************************************************

" DO Schleife

DO 5 TIMES.

ENDDO.

" WHILE Schleife

WHILE gv_erg <= 1000.
  gv_expo = gv_expo + 1.
  gv_erg = 2 ** gv_expo.

ENDWHILE.

WRITE: /, '2 hoch ', gv_expo, ' ist größer als 1000'.
