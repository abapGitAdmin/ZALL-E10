*&---------------------------------------------------------------------*
*&  Include           /IDXGC/RP_PDOC_CREATE_BDR_TOP
*&---------------------------------------------------------------------*
data:
  ok_code            type sy-ucomm,
  gv_mtext           type string,
  gs_proc_config_all type /idxgc/s_proc_config_all,
  gx_previous        type ref to  /idxgc/cx_general.

constants:
  gc_ucomm_onli        type sy-ucomm value 'ONLI',
  gc_ucomm_rad         type sy-ucomm value 'RADCOM',
  gc_value_org_s       type ddbool_d value 'S',
  gc_mark_x            type char1 value 'X',
  gc_scr_name_p_ownsp  type screen-name value 'P_OWNSP',
  gc_scr_name_p_rcver  type screen-name value 'P_RCVER',
  gc_scr_name_p_pid    type screen-name value 'P_PID',
  gc_scr_name_p_pty    type screen-name value 'P_PTY',
  gc_scr_name_p_pvw    type screen-name value 'P_PVW',
  gc_scr_name_p_ptyt   type screen-name value 'P_PTYT',
  gc_scr_name_p_pvwt   type screen-name value 'P_PVWT',
  gc_scr_name_p_pidt   type screen-name value 'P_PIDT',
  gc_fname_proc_id     type fieldname value 'PROC_ID',
  gc_fname_proc_descr  type fieldname value 'PROC_DESCR',
  gc_fname_proc_type   type fieldname value 'PROC_TYPE',
  gc_fname_proc_view   type fieldname value 'PROC_VIEW',
  gc_tname_proc_config type tabname value '/IDXGC/S_PROC_CONFIG',
  gc_scr_grp_txt       type screen-group1 value 'TXT'.
