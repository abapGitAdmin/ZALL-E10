FUNCTION ZHA_ADD_GET_LOG_INFO.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IV_MSG) TYPE  STRING OPTIONAL
*"  TABLES
*"      CT_LOG_INFO STRUCTURE  ZHA_LOG_INFO
*"----------------------------------------------------------------------
  select max( id ) from zha_log_info into @data(lv_max_id).
  lv_max_id = lv_max_id + 1.

  DATA(ls_log_info) = value zha_log_info( id = lv_max_id msg = iv_msg ).
  insert zha_log_info from ls_log_info.
  commit WORK.

  select * from zha_log_info into table ct_log_info.

ENDFUNCTION.
