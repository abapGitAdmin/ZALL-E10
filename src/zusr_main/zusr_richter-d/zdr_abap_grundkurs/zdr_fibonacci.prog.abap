************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: XXXXX-X                                      Datum: TT.MM.JJJJ
*
* Beschreibung:
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************
report zdr_fibonacci.

types: begin of lty_zeile,
         fibstelle type i,
         fibwert   type i,
       end of lty_zeile.

data: gv_fibonacci_summand1 type i.
data: gv_fibonacci_summand2 type i.
data: gv_fibonacci_summe type i.
data: gs_fibonacci type lty_zeile.
data: gt_fibonacci type table of lty_zeile.
data: gt_fibonacci_kopf type table of lty_zeile with header line.

gv_fibonacci_summand1 = 0.
gv_fibonacci_summand2 = 1.

call function 'HR_READ_INFOTYPE_AUTHC_DISABLE'.

do 45 times.
  gv_fibonacci_summe = gv_fibonacci_summand1 + gv_fibonacci_summand2.

  gs_fibonacci-fibstelle = sy-index.
  gs_fibonacci-fibwert = gv_fibonacci_summe.
  append gs_fibonacci to gt_fibonacci.

  gt_fibonacci_kopf-fibstelle = sy-index.
  gt_fibonacci_kopf-fibwert = gv_fibonacci_summe.
  append gt_fibonacci_kopf.

  write: gv_fibonacci_summe, '|'.

  gv_fibonacci_summand1 = gv_fibonacci_summand2.
  gv_fibonacci_summand2 = gv_fibonacci_summe.
enddo.
