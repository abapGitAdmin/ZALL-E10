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
REPORT zls_fibonacci.

TYPES: BEGIN OF lty_s_zeile,
         stelle TYPE i,
         wert   TYPE i,
       END OF lty_s_zeile.

DATA: gv_summand1       TYPE i,
      gv_summand2       TYPE i,
      gv_summe          TYPE i,
      gs_fibonacci      TYPE lty_s_zeile,
      gt_fibonacci      TYPE TABLE OF lty_s_zeile,
      gt_fibonacci_kopf TYPE TABLE OF lty_s_zeile WITH HEADER LINE.

gv_summand1 = 0.
gv_summand1 = 1.

CALL FUNCTION 'HR_READ_INFOTYPE_AUTHC_DISABLE'.

DO 45 TIMES.
  gv_summe = gv_summand1 + gv_summand2.

  " Tabelle ohne Kopf
  gs_fibonacci-stelle = sy-index.
  gs_fibonacci-wert   = gv_summe.
  APPEND gs_fibonacci TO gt_fibonacci.

  " Tabelle mit Kopf
  gt_fibonacci_kopf-stelle = sy-index.
  gt_fibonacci_kopf-wert   = gv_summe.
  APPEND gt_fibonacci_kopf.

  WRITE / gv_summe.

  gv_summand1 = gv_summand2.
  gv_summand2 = gv_summe.
ENDDO.
