*&---------------------------------------------------------------------*
*&  Include           /IDXGC/RP_PDOC_CREATE_BDR_TOP
*&---------------------------------------------------------------------*
DATA:
  ok_code               TYPE sy-ucomm,
  gv_mtext              TYPE string,
  gs_proc_config_all    TYPE /idxgc/s_proc_config_all,
  gx_previous           TYPE REF TO  /idxgc/cx_general.

CONSTANTS:
  gc_ucomm_onli         TYPE sy-ucomm VALUE 'ONLI',
  gc_value_org_s        TYPE ddbool_d VALUE 'S',
  gc_mark_x             TYPE char1 VALUE 'X',
  gc_scr_name_p_pid     TYPE screen-name VALUE 'P_PID',
  gc_scr_name_p_pty     TYPE screen-name VALUE 'P_PTY',
  gc_scr_name_p_pvw     TYPE screen-name VALUE 'P_PVW',
  gc_scr_name_p_ptyt    TYPE screen-name VALUE 'P_PTYT',
  gc_scr_name_p_pvwt    TYPE screen-name VALUE 'P_PVWT',
  gc_scr_name_p_pidt    TYPE screen-name VALUE 'P_PIDT',
  gc_fname_proc_id      TYPE fieldname VALUE 'PROC_ID',
  gc_fname_proc_descr   TYPE fieldname VALUE 'PROC_DESCR',
  gc_fname_proc_type    TYPE fieldname VALUE 'PROC_TYPE',
  gc_fname_proc_view    TYPE fieldname VALUE 'PROC_VIEW',
  gc_tname_proc_config  TYPE tabname VALUE '/IDXGC/S_PROC_CONFIG',
  gc_scr_grp_txt        TYPE screen-group1 VALUE 'TXT'.
