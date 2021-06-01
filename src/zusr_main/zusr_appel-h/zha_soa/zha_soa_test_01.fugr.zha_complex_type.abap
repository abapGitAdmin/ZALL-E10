FUNCTION ZHA_COMPLEX_TYPE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IV_DATETIME) TYPE  ZHA_DE_DATETIME
*"     VALUE(IV_DECIMAL) TYPE  ZHA_DE_DECIMAL
*"     VALUE(IS_COMPLEX) TYPE  ZHA_S_COMPLEX4
*"  EXPORTING
*"     VALUE(ES_COMPLEX) TYPE  ZHA_S_COMPLEX4
*"     VALUE(EV_DATE) TYPE  DATS
*"     VALUE(EV_DECIMAL) TYPE  ZHA_DE_DECIMAL
*"----------------------------------------------------------------------
  " Datetime :  Datum extrahieren
  DATA lv_timestamp TYPE timestamp.
  lv_timestamp = iv_datetime.
  CONVERT TIME STAMP  lv_timestamp TIME ZONE sy-zonlo INTO DATE ev_date.

  " Decimals verdoppeln
  ev_decimal = iv_decimal * 2.

  " Komplexer Datentyp
  DATA ls_out_complex1 type zha_s_complex1.
  DATA ls_out_complex2 type zha_s_complex2.
  DATA ls_out_complex3 type zha_s_complex3.
  clear es_complex.
  es_complex-info_msg_num4  = 'Ebene4:' && is_complex-info_msg_num4.
  LOOP AT is_complex-complex4 INTO DATA(ls_complex3).
    clear ls_out_complex3.
    ls_out_complex3-info_msg_num3  = 'Ebene3:' && sy-tabix && ':' && ls_complex3-info_msg_num3.
    LOOP AT ls_complex3-complex3 INTO DATA(ls_complex2).
      clear ls_out_complex2.
      ls_out_complex2-info_msg_num2  = 'Ebene2:' && sy-tabix && ':' && ls_complex2-info_msg_num2.
      LOOP AT ls_complex2-complex2 INTO DATA(ls_complex1).
        clear ls_out_complex1.
        ls_out_complex1-info_msg_num1  = 'Ebene1:' && sy-tabix && ':' && ls_complex2-info_msg_num2.
        LOOP AT ls_complex1-complex1 INTO DATA(ls_complex0).
          ls_complex0-num = ls_complex0-num * 2.
          ls_complex0-str = ls_complex0-str && '|' && ls_complex0-str.
          ls_complex0-val = ls_complex0-val * 2.
          INSERT ls_complex0 INTO TABLE ls_out_complex1-complex1.
        ENDLOOP.
        INSERT ls_out_complex1 INTO TABLE ls_out_complex2-complex2.
      ENDLOOP.
      INSERT ls_out_complex2 INTO TABLE ls_out_complex3-complex3.
    ENDLOOP.
    insert ls_out_complex3 into table es_complex-complex4.
  ENDLOOP.


ENDFUNCTION.
