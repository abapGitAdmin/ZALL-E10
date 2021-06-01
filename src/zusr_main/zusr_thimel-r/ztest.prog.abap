*&---------------------------------------------------------------------*
*& Report  ZTEST
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT ztest.

DATA: lv_integer   TYPE integer,
      lv_flag_1    TYPE boolean,
      lv_flag_2    TYPE boolean,
      lv_date      TYPE dats,
      lv_date_from TYPE dats,
      lv_date_to   TYPE dats.


"Wenn LV_INTEGER mindestens 100 ist und entweder LV_FLAG_1 = TRUE und LV_FLAG_2 = TRUE oder beide FALSE sind.




"Wenn LV_FLAG_1 = TRUE ist und ob LV_DATE zwischen LV_DATE_FROM und LV_DATE_TO liegt.




"Wenn LV_FLAG_1 TRUE ist und LV_INTEGER nicht größer als 10 und LV_DATE ist nicht kleiner oder nicht gleich dem 31.12.2019.










lv_integer   = 9.
lv_flag_1    = abap_true.
lv_flag_2    = abap_true.
lv_date      = '20220909'.
lv_date_from = '19091219'.
lv_date_to   = '20221111'.




















IF lv_integer >= 100 AND ( ( lv_flag_1 = abap_true  AND lv_flag_2 = abap_true ) OR
                           ( lv_flag_1 = abap_false AND lv_flag_2 = abap_false ) ).
  WRITE: 'OK'.
ENDIF.

IF lv_flag_1 = abap_true AND lv_date > lv_date_from AND lv_date < lv_date_to.
  WRITE: 'OK'.
ENDIF.

IF lv_flag_1 = abap_true AND lv_integer <= 10 AND lv_date > '20191231'.
  WRITE: 'OK'.
ENDIF.





































PERFORM test. " using lt_ext_ui.

*&---------------------------------------------------------------------*
*&      Form  TEST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_T100  text
*----------------------------------------------------------------------*
FORM test. "using it_ext_ui TYPE ext_ui_table.

*  LOOP AT gt_ext_ui INTO DATA(ls_t000).
*  ENDLOOP.
*
*  IF 1 = 2.
*  ENDIF.

ENDFORM.
