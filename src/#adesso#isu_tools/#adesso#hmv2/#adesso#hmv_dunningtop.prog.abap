*&---------------------------------------------------------------------*
*&  Include           /ADESSO/HMV_DUNNINGTOP
*&---------------------------------------------------------------------*

*

TABLES:
  fkkvk,
  fkkvkp,
  te002a,
  dfkkop,
  dfkkthi,
  edextask,
  edextaskidoc,
  edidc,
  fkkmako,
  fkkmaze,
  euitrans,
  edexproc,
  edexbasicproc,
  /idxmm/memidoc,
  /adesso/hmv_cons,
  /adesso/hmv_ival.

DATA: wa_edids TYPE edids.

* Internal Tables
DATA:
  t_te002a   LIKE te002a           OCCURS 0 WITH HEADER LINE,
  t_dfkklock LIKE dfkklocks        OCCURS 0 WITH HEADER LINE,
  t_linea    LIKE tinv_inv_line_a  OCCURS 0 WITH HEADER LINE,
  t_invdoc   LIKE tinv_inv_doc     OCCURS 0 WITH HEADER LINE,
  t_edextask LIKE edextask         OCCURS 0 WITH HEADER LINE,
  t_fkkopchl LIKE fkkopchl         OCCURS 0 WITH HEADER LINE,
  t_euitrans LIKE euitrans         OCCURS 0 WITH HEADER LINE,
  t_edid4    LIKE edid4            OCCURS 0 WITH HEADER LINE.

* MEMIDOC
DATA:
  t_memidoc    TYPE TABLE OF /adesso/hmv_selct_memi,
  t_memidoc2   TYPE TABLE OF /adesso/hmv_selct_memi,
  t_selct_memi TYPE TABLE OF /adesso/hmv_selct_memi.

*** --> Nuss 09.2018
* MSBDOC
DATA: t_msbdoc    TYPE TABLE OF /ADESSO/hmv_selct_msb,
      t_msbdoc2   TYPE TABLE OF /adesso/hmv_selct_msb,
      t_selct_msb TYPE TABLE OF /adesso/hmv_selct_msb.
** <-- Nuss 09.2018

DATA:
  BEGIN OF wa_crsrf,
    int_crossrefno TYPE ecrossrefno-int_crossrefno,
    crossrefno     TYPE tinv_inv_line_a-own_invoice_no,
    int_ui         TYPE ecrossrefno-int_ui,
    crn_rev        TYPE ecrossrefno-crn_rev,
    ext_ui         TYPE euitrans-ext_ui,
    dateto         TYPE euitrans-dateto,
  END OF wa_crsrf.
DATA:           t_crsrf  LIKE TABLE OF wa_crsrf.
FIELD-SYMBOLS: <t_crsrf> LIKE          wa_crsrf.

DATA:
  BEGIN OF t_fkkvkp OCCURS 0,             "Vertragskonto partnerspezifisch
    locked(30),
    buchvert(30),
    gpart           LIKE dfkkthi-gpart,
    vkont           LIKE dfkkthi-vkont,
    vkbez           LIKE fkkvk-vkbez,
    stdbk           LIKE fkkvkp-stdbk,
    recid           LIKE dfkkthi-recid,
    senid           LIKE dfkkthi-senid,
    vktyp           LIKE fkkvk-vktyp,
    mahnv           LIKE fkkvkp-mahnv,
    mansp           LIKE fkkvkp-mansp,
    v_group         LIKE dfkkthi-v_group,
    dexidocsent     TYPE e_dexidocsent,
    dexidocsentinv  TYPE e_dexidocsent,
    dexidocsentctrl TYPE e_dexidocsent,
    dexproc         TYPE e_dexproc,
    dexidocsendcat  TYPE e_dexidocsendcat,
    ext_ui          TYPE ext_ui,
  END OF t_fkkvkp.

DATA:
  BEGIN OF wa_fkkop,                      "Geschäftspartnerpositionen zum Kontokorrentbeleg
    doc_id     TYPE /idxmm/de_doc_id,
    vkont      LIKE fkkop-vkont,
    bukrs      LIKE fkkop-bukrs,
    crsrf      LIKE fkkop-int_crossrefno,
    bcbln      TYPE bcbln_kk,
    vtref      LIKE fkkop-vtref,
    opbel      LIKE fkkmaze_struc-opbel,
    opupw      LIKE fkkmaze_struc-opupw,
    opupk      LIKE fkkmaze_struc-opupk,
    opupz      LIKE fkkmaze_struc-opupz,
    blart      LIKE fkkop-blart,
    stakz      LIKE fkkop-stakz,
    augst      LIKE fkkop-augst,
    faedn      LIKE dfkkthi-thidt,
    thprd      LIKE dfkkthi-thprd,
    mansp      LIKE fkkop-mansp,
    waers      LIKE fkkop-waers,
    betrh      LIKE fkkop-betrh,
    zz_idocin  TYPE /adesso/hmv_idocin,
    zz_statin  TYPE /adesso/hmv_statin,
    zz_idocct  TYPE /adesso/hmv_idocct,
    zz_statct  TYPE /adesso/hmv_statct,
    intui      TYPE int_ui,
    thist      LIKE dfkkthi-thist,
    hvorg      LIKE fkkop-hvorg,
    tvorg      LIKE fkkop-tvorg,
    spart      LIKE fkkop-spart,
    gpart      LIKE fkkop-gpart,
    xtaus      LIKE fkkop-xtaus,
    xmanl      LIKE fkkop-xmanl,
    keydate    LIKE dfkkthi-keydate,
    status(30),
    akonto(30),
  END OF wa_fkkop.
DATA:           t_fkkop  LIKE TABLE OF wa_fkkop.
FIELD-SYMBOLS: <t_fkkop> LIKE          wa_fkkop.

DATA:
  BEGIN OF t_opbel OCCURS 0,
    opbel TYPE dfkkop-opbel,
    opupk TYPE dfkkop-opupk,
  END OF t_opbel.

* DFKKOP
DATA:
  wa_bcbln TYPE           /adesso/hmv_selct,
  t_bcbln  TYPE TABLE OF  /adesso/hmv_selct,
  t_tbcbl  TYPE TABLE OF  /adesso/hmv_selct,
  t_selct  TYPE TABLE OF  /adesso/hmv_selct.

FIELD-SYMBOLS: <t_bcbln>      TYPE /adesso/hmv_selct,
               <t_bcbln_memi> TYPE /adesso/hmv_selct_memi. "MEMI

DATA:
  BEGIN OF wa_tasks,
    name(20) TYPE c,
    count(4) TYPE n,
    low      TYPE sy-tabix,
    high     TYPE sy-tabix,
  END OF wa_tasks.
DATA:
  t_tasks    LIKE TABLE OF wa_tasks,
  taskname   LIKE wa_tasks-name,
  taskcnt(4) TYPE n.
FIELD-SYMBOLS: <t_tasks> LIKE wa_tasks.

DATA:
  x_runts TYPE sy-tabix,
  x_maxts TYPE sy-tabix,
  x_uzeit TYPE sy-uzeit.

DATA:
  sel_augst TYPE TABLE OF rsdsselopt,
  sel_mansp TYPE TABLE OF rsdsselopt,
  sel_mahns TYPE TABLE OF rsdsselopt.

DATA:
  wa_out  TYPE          /adesso/hmv_out,
  wa_tout TYPE          /adesso/hmv_out,
  ft_out  TYPE TABLE OF /adesso/hmv_out,
  t_out   TYPE TABLE OF /adesso/hmv_out,
  s_out   LIKE LINE  OF ft_out.

FIELD-SYMBOLS: <t_out> TYPE /adesso/hmv_out.

DATA:
  BEGIN OF wa_remadv,
    own_invoice_no LIKE ecrossrefno-crossrefno,
    int_inv_doc_no LIKE tinv_inv_line_a-int_inv_doc_no,
    invoice_type   LIKE tinv_inv_doc-invoice_type,
    invoice_status LIKE tinv_inv_head-invoice_status,
    doc_type       LIKE tinv_inv_doc-doc_type,
    inv_doc_status LIKE tinv_inv_doc-inv_doc_status,
    rstgr          LIKE tinv_inv_line_a-rstgr,
  END OF wa_remadv.
DATA:           t_remadv  LIKE TABLE OF wa_remadv.
FIELD-SYMBOLS: <t_remadv> LIKE          wa_remadv.

DATA:
  BEGIN OF t_idocs OCCURS 0,
    int_ui       LIKE edextask-int_ui,
    credat       LIKE edidc-credat,
    cretim       LIKE edidc-cretim,
    docnum       LIKE edextaskidoc-docnum,
    dextaskid    LIKE edextask-dextaskid,
    dexduedate   LIKE edextask-dexduedate,
    dexrefdateto LIKE edextask-dexrefdateto,
    dexstatus    LIKE edextask-dexstatus,
    sent         LIKE edextaskidoc-sent,
    status       LIKE edidc-status,
    segnam       LIKE edid4-segnam,
    sdata        LIKE edid4-sdata,
  END OF t_idocs.

DATA:
  BEGIN OF t_akonto OCCURS 0,
    bukrs LIKE dfkkop-bukrs,
    gpart LIKE dfkkop-gpart,
    vkont LIKE dfkkop-vkont,
    vtref LIKE fkkop-vtref,
    opbel LIKE fkkmaze_struc-opbel,
    opupw LIKE fkkmaze_struc-opupw,
    opupk LIKE fkkmaze_struc-opupk,
    opupz LIKE fkkmaze_struc-opupz,
    blart LIKE fkkop-blart,
    stakz LIKE fkkop-stakz,
    augst LIKE fkkop-augst,
    faedn LIKE dfkkthi-thidt,
    mansp LIKE fkkop-mansp,
    waers LIKE fkkop-waers,
    betrh LIKE fkkop-betrh,
    hvorg LIKE fkkop-hvorg,
    tvorg LIKE fkkop-tvorg,
    spart LIKE fkkop-spart,
    xtaus LIKE fkkop-xtaus,
    xmanl LIKE fkkop-xmanl,
  END OF t_akonto.

* Structures
DATA:
  s_dfkkop             LIKE dfkkop,
  s_param_inv_outbound TYPE inv_param_inv_outbound.

* Fields
DATA:
  x_lock_exist TYPE          c,
  x_lock_depex TYPE          c,
  x_initiator  TYPE          e_deregspinitiator,
  x_partner    TYPE          e_deregsppartner,
  x_thidt_from TYPE          thidt_kk,
  x_thidt_to   TYPE          thidt_kk,
  x_tabix      TYPE          sy-tabix,
  x_prtio      TYPE          sy-tabix,
  x_sdata      TYPE          edid4-sdata,
  x_tage       TYPE          i,
  t_sval       LIKE TABLE OF sval,
  w_sval       LIKE          sval.

* Ranges
DATA: r_vktyp TYPE RANGE OF te002a-vktyp WITH HEADER LINE.

*DATA:
*  c_mansp             TYPE mansp_kk,
*  c_mahnv             TYPE mahnv_kk,
*  c_doc_kzd           TYPE char1,
*  c_doc_kzm           TYPE char1,
*  c_invoice_status_03 TYPE char2,
*  c_invoice_status_04 TYPE char2,
*  c_listheader_typ    TYPE slis_listheader-typ,
*  c_lockaktyp         TYPE fkkopchl-lockaktyp,
*  c_lockr             TYPE fkkopchl-lockr,
*  c_lotyp             TYPE fkkopchl-lotyp,
*  c_proid             TYPE fkkopchl-proid,
*  c_proid_dunn        TYPE proid_kk,
*  c_prtio             TYPE sy-tabix,
*  c_maxtb             TYPE sy-tabix,
*  c_maxtd             TYPE sy-tabix,
*  c_faedn_from        TYPE dfkkop-faedn,
*  c_faedn_to          TYPE sy-datum,
*  g_status            TYPE slis_formname,
*  g_user_command      TYPE slis_formname,
*  c_lotyp_gp_vk       TYPE lotyp_kk,
*  h_lotyp_gp_vk       TYPE lotyp_kk,
*  c_invoice_paym      TYPE tinv_inv_doc-invoice_type,
*  c_invoice_paymst    LIKE tinv_inv_doc-inv_doc_status,
*  c_invoice_type7     LIKE tinv_inv_doc-invoice_type,
*  c_invoice_type8     LIKE tinv_inv_doc-invoice_type.


DATA:
  BEGIN OF tab_constant OCCURS 0,
    konstante TYPE /idxgc/de_constant,
    attvalue  TYPE seovalue,
  END OF tab_constant.

DATA:
  t_const_tab LIKE TABLE OF tab_constant WITH HEADER LINE,
  it_const    LIKE TABLE OF tab_constant,
  is_const    LIKE          tab_constant.

*DATA:
*  t_hmv_const TYPE /adesso/hmv_t_constants WITH HEADER LINE,
*  s_hmv_const TYPE /adesso/hmv_s_constants.
*
DATA:
  t_hmv_ival TYPE TABLE OF /adesso/hmv_ival WITH HEADER LINE,
  s_hmv_ival TYPE          /adesso/hmv_ival,
  s_interval TYPE          /adesso/hmv_ival.

* --> Nuss 05.03.2018
DATA: t_hmv_mver TYPE TABLE OF /adesso/hmv_mver WITH HEADER LINE,
      s_hmv_mver TYPE          /adesso/hmv_mver.
* <-- Nuss 05.03.2018


* field-symbols
FIELD-SYMBOLS:
  <outbound_acc>  TYPE inv_param_inv_outbound_acc,
  <outbound_avis> TYPE inv_param_inv_outbound_avis.

*-----------------------------------------------------------------------
* ALV
*-----------------------------------------------------------------------
TYPE-POOLS: slis.

* Includes
INCLUDE <icon>.

DATA:
  gt_fieldcat     TYPE slis_t_fieldcat_alv WITH HEADER LINE,
  gt_fieldcat_all TYPE slis_t_fieldcat_alv WITH HEADER LINE,
  gs_layout       TYPE slis_layout_alv,
  gs_keyinfo      TYPE slis_keyinfo_alv,
  gt_sort         TYPE slis_t_sortinfo_alv WITH HEADER LINE,
  gt_sp_group     TYPE slis_t_sp_group_alv,
  gt_events       TYPE slis_t_event.

DATA:
  g_repid             LIKE sy-repid,
  gt_list_top_of_page TYPE slis_t_listheader,
  g_tabname_header    TYPE slis_tabname,
  g_tabname_item      TYPE slis_tabname,
  g_tabname_all       TYPE slis_tabname,
  ls_fieldcat         TYPE slis_fieldcat_alv,
  gs_listheader       TYPE slis_listheader,
  gt_listheader       TYPE slis_t_listheader.

DATA:
  gt_filtered TYPE slis_t_filtered_entries,
  sav_ucomm   LIKE sy-ucomm,
  block_line  LIKE sy-index,
  block_beg   LIKE sy-index,
  block_end   LIKE sy-index.

DATA:
  g_sort  TYPE        slis_t_sortinfo_alv WITH HEADER LINE,
  rev_alv TYPE REF TO cl_gui_alv_grid.

DATA:
  g_save     TYPE char1,
  g_exit     TYPE char1,
  gx_variant LIKE disvariant,
  g_variant  LIKE disvariant.

DATA:
  h_ex       LIKE ltex-exname,
  h_extract  TYPE disextract,
  h_extadmin TYPE ltexadmin.

DATA:
  BEGIN OF it_docstscfg,
    doc_status      TYPE /idxmm/de_doc_status,
    dunning_enabled TYPE /idxmm/de_dunning_enabled,
  END OF it_docstscfg.

DATA: t_idxmm_docstscfg TYPE TABLE OF /idxmm/docstscfg,
      t_idxmm_doc       LIKE TABLE OF it_docstscfg,
      s_idxmm_doc       LIKE          it_docstscfg.

DATA: t_memi TYPE TABLE OF /idxmm/memidoc,
      s_memi LIKE LINE OF  t_memi.

FIELD-SYMBOLS: <fs_docstscfg> TYPE /idxmm/docstscfg.
