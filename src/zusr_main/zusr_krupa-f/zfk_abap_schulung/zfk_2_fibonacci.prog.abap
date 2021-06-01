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
REPORT zfk_2_fibonacci.

TYPES: BEGIN OF lty_s_zeile,
         fibstelle TYPE i,
         fibwert   TYPE i,
       END OF lty_s_zeile.

DATA: gv_fibo_sum1 TYPE i,
      gv_fibo_sum2 TYPE i,
      gv_fibo_erg  TYPE i,
      gs_fib       TYPE lty_s_zeile,
      gt_fib       TYPE TABLE OF lty_s_zeile,
      gt_test      TYPE TABLE OF zfk_studenten.

WRITE 'taha'.
LOOP AT gt_test INTO DATA(wa).
  WRITE 'Hallo'.
  ENDLOOP.

gv_fibo_sum1 = 0.
gv_fibo_sum2 = 1.
gv_fibo_erg = 0.

WRITE: gv_fibo_sum1, ' '.
WRITE: gv_fibo_sum2, ' '.

DO 45 TIMES.

  gv_fibo_erg = gv_fibo_sum1 + gv_fibo_sum2.

  gs_fib-fibstelle = sy-index.
  gs_fib-fibwert = gv_fibo_erg.

  APPEND gs_fib TO gt_fib.
  CLEAR gs_fib.



  WRITE: gv_fibo_erg, ' '.

  gv_fibo_sum1 = gv_fibo_sum2.
  gv_fibo_sum2 = gv_fibo_erg.

ENDDO.
