report  zdr_rp_pdoc_create_bdr.
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

*&---------------------------------------------------------------------*
*&  Include           /IDXGC/RP_PDOC_CREATE_BDR_SEL
*&---------------------------------------------------------------------*
selection-screen begin of block gb_hdr with frame title text-bk1.
parameters:
  p_ownsp type e_dexservprovself matchcode object serviceprovider obligatory,
  p_rcver type e_dexservprov obligatory.
selection-screen begin of line.
selection-screen comment 1(31) text-t02 for field p_pvw.
parameters:
  p_pvw  type /idxgc/de_proc_view  modif id txt,
  p_pvwt type eideswtviewtxt modif id txt.
selection-screen end of line.
selection-screen begin of line.
selection-screen comment 1(31) text-t03 for field p_pty.
parameters:
  p_pty  type /idxgc/de_proc_type modif id txt,
  p_ptyt type eideswttypetxt modif id txt.
selection-screen end of line.
selection-screen begin of line.
selection-screen comment 1(31) text-t01 for field p_pid.
parameters:
  p_pid  type /idxgc/de_proc_id obligatory,
  p_pidt type /idxgc/de_proc_descr modif id txt.
selection-screen end of line.

selection-screen end of block gb_hdr.

selection-screen begin of block gb_msg with frame title text-bk2.

* Z14: Master Data for Point of Delivery
selection-screen begin of line.
parameters: p_z14  radiobutton group g1 default 'X'.
selection-screen comment 6(70) text-t04 for field p_z14.
selection-screen end of line.

* Z27: Transfer of Transaction Data
selection-screen begin of line.
parameters: p_z27  radiobutton group g1.
selection-screen comment 6(60) text-t05 for field p_z27.
selection-screen end of line.

* Z28: Transfer of Energy and Demand Maximum
selection-screen begin of line.
parameters: p_z28  radiobutton group g1.
selection-screen comment 6(70) text-t06 for field p_z28.
selection-screen end of line.
selection-screen end of block gb_msg.

**********************************************************************
* ################################################################## *
**********************************************************************

**********************************************************************
* Radiobuttons zur Auswahl der Nachrichtentypen
**********************************************************************
selection-screen begin of block gb_rad with frame title text-bk3.

* Z30: ??nderung des Bilazierungsverfahrens
selection-screen begin of line.
parameters  p_r30 radiobutton group g2 user-command radcom default 'X'.
selection-screen comment: 6(70) text-t11 for field p_r30.
selection-screen end of line.

* Z34: Reklamation von Lastg??ngen
selection-screen begin of line.
parameters  p_r34 radiobutton group g2.
selection-screen comment 6(70) text-t12 for field p_r34.
selection-screen end of line.
selection-screen end of block gb_rad.

**********************************************************************
* Block f??r Z30
**********************************************************************
selection-screen begin of block gb_s30 with frame title text-bk4.
data gv_locid type ext_ui.

* ID der Marktlokation
selection-screen begin of line.
selection-screen comment 1(28) text-t08.
select-options:
  s_ext_ui       for gv_locid modif id m30.
selection-screen end of line.

* Ausf??hrungsdatum
selection-screen begin of line.
selection-screen comment 1(31) text-t09.
parameters:
  p_edate        type /idxgc/de_proc_date modif id m30.
selection-screen end of line.

* Bilanzierungsverfahren
selection-screen begin of line.
selection-screen comment 1(31) text-t10.
parameters:
  p_sproc        type /idxgc/de_settl_proc modif id m30.
selection-screen end of line.
selection-screen end of block gb_s30.

**********************************************************************
* Block f??r Z34
**********************************************************************
selection-screen begin of block gb_s34 with frame title text-bk5.
data gv_begnr type e_logbelnr.

* Import-Belegnummer
selection-screen begin of line.
selection-screen comment 1(28) text-t13.
select-options:
  p_belnr        for gv_begnr modif id m34. "obligatory.
selection-screen end of line.
selection-screen end of block gb_s34.
