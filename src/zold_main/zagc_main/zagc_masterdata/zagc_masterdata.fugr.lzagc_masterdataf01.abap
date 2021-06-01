*----------------------------------------------------------------------*
***INCLUDE LZAGC_MASTERDATAF01.
*----------------------------------------------------------------------*
FORM zz_update_change_info.
  DATA: ls_mrcontact TYPE zagc_mrcontact.

  ls_mrcontact = extract.

  IF ls_mrcontact-anlage IS NOT INITIAL.
    zagc_mrcontact-ch_name = sy-uname.
    zagc_mrcontact-ch_date = sy-datum.
    zagc_mrcontact-ch_time = sy-uzeit.
  ENDIF.

ENDFORM.

FORM zz_update_create_info.

  zagc_mrcontact-cr_name = sy-uname.
  zagc_mrcontact-cr_date = sy-datum.
  zagc_mrcontact-cr_time = sy-uzeit.

ENDFORM.
