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
* INIT         appel-h  23.02.2020
************************************************************************
*******
REPORT zhar_test_service_consumer.


IF 1 < 0.
  " test mit fugr
  DATA lv_input  TYPE zhaco1zha_extract_leading_zer1.
  DATA lv_output TYPE zhaco1zha_extract_leading_zero.
  lv_input-iv_str = '0007Blubber'.

  DATA lv_input2  TYPE zhaco1zha_add_get_log_info.
  DATA lv_output2 TYPE zhaco1zha_add_get_log_info_res.
  DATA lv_logportname TYPE prx_logical_port_name VALUE 'ZHA_LP_TEST_01_FUGR'.
  lv_input2-iv_msg = |Greetings from logical proxy { lv_logportname }|.


  DATA(lr_proxy) = NEW zhaco1co_zha_sd_soa_test_01_fu( logical_port_name =  lv_logportname ).

  lr_proxy->zha_extract_leading_zeros(
    EXPORTING    input  = lv_input
    IMPORTING    output = lv_output  ).
  WRITE : / '------------------------------------------------------------'.
  WRITE : / lv_input-iv_str, '-->', lv_output-ev_str.

  lr_proxy->zha_add_get_log_info(
    EXPORTING    input  = lv_input2
    IMPORTING    output = lv_output2  ).
  WRITE : / '------------------------------------------------------------'.
  WRITE : / 'log_info'.
  LOOP AT lv_output2-ct_log_info-item INTO DATA(ls_loginfo).
    DATA(lo_structdescr) = CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_data( ls_loginfo ) ).
    DATA(lt_comp)   = lo_structdescr->get_components( ).
    DATA(lv_string) = VALUE string(  ).
    LOOP AT lt_comp INTO DATA(ls_comp).
      CHECK ls_comp-name NE 'CONTROLLER'.
      ASSIGN COMPONENT ls_comp-name OF STRUCTURE ls_loginfo TO FIELD-SYMBOL(<lv_value>).
      lv_string = |{ lv_string }{ ls_comp-name } = { <lv_value> }   |.
    ENDLOOP.
    WRITE : / lv_string.
  ENDLOOP.
ELSE.
  DATA lv_input_cx  TYPE zhaco2zha_complex_type.
  DATA lv_output_cx TYPE zhaco2zha_complex_typeresponse.
  DATA(lr_proxy_cx) = NEW zhaco2co_soa_complextype( logical_port_name = 'ZHA_LP_TEST_COMPLEXTYPE' ).
  lv_input_cx-iv_datetime = '20190227121415'.

  lr_proxy_cx->zha_complex_type(
    EXPORTING    input  = lv_input_cx
    IMPORTING    output = lv_output_cx  ).
  WRITE : / '------------------------------------------------------------'.
  DATA lv_test_date TYPE dats.
  lv_test_date = '20190227'.
  WRITE : / lv_input_cx-iv_datetime, '-->', lv_output_cx-ev_date.
  lv_test_date = lv_output_cx-ev_date.
  WRITE : / lv_test_date.

ENDIF.
