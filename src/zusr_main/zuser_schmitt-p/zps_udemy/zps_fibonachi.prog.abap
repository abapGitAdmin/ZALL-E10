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
REPORT zps_fibonachi.

TYPES: BEGIN OF lty_zeile,
         fibstelle TYPE i,
         fibwert   TYPE i,
       END OF lty_zeile.

DATA: gv_fibonachi_num1 TYPE i VALUE 0,
      gv_fibonachi_num2 TYPE i VALUE 1,
      gv_fibonachi_sum  TYPE i.

DATA: gs_fibonacci      TYPE lty_zeile,
      gt_fibonacci      TYPE TABLE OF lty_zeile,
      gt_fibonacci_kopf TYPE TABLE OF lty_zeile WITH HEADER LINE.


DO 45 TIMES.
  gv_fibonachi_sum = gv_fibonachi_num1 + gv_fibonachi_num2.

  gv_fibonachi_num1 = gv_fibonachi_num2.
  gv_fibonachi_num2 = gv_fibonachi_sum.

  gs_fibonacci-fibstelle = sy-index.
  gs_fibonacci-fibwert = gv_fibonachi_sum.

  APPEND gs_fibonacci to gt_fibonacci. " Tabelle ohne Kopfzeile

  gt_fibonacci_kopf-fibstelle = sy-index.
  gt_fibonacci_kopf-fibwert = gv_fibonachi_sum.
  APPEND gt_fibonacci_kopf.

  WRITE: gv_fibonachi_sum, '|'.
  IF sy-index  MOD 10 = 0.
    WRITE: /.
  ENDIF.
ENDDO.
