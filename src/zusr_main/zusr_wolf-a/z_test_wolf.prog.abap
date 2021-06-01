*&---------------------------------------------------------------------*
*& Report Z_TEST_WOLF
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_TEST_WOLF.

*DATA: ls_ever type ever ##needed,
*      lv_vertrag TYPE ever-VERTRAG ##needed.
*
*lv_vertrag = '1000000000'.
*
*select SINGLE * FROM ever into ls_ever WHERE VERTRAG = lv_vertrag.
*
*  write / ls_ever-ANLAGE.

data: lv_a  TYPE char12 VALUE 'abc',
      lv_b TYPE char3 VALUE 'abc'.

IF lv_a = lv_b.
  WRITE / 'gleich'.
  else.
    write / 'ungleich'.
ENDIF.
