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
REPORT Z_OPENSQL.

*SELECT

TABLES: zemployees.

SELECT * FROM zemployees WHERE surname = 'MILLS'.
  WRITE: / zemployees.
ENDSELECT.

DATA: a TYPE i,
      b TYPE i,
      c TYPE i.

a = 0.
c = 0.

DO 15 TIMES.
  a = a + 1.
  WRITE: / 'Outer Loop cycle: ', a.
  b = 0.
  DO 10 TIMES.
    b = b + 1.
    WRITE: / 'Inner Loop cycle:     ', b.
  ENDDO.
  c = c + b.
ENDDO.
c = c + a.
WRITE: / 'Total Iterations: ', c.
