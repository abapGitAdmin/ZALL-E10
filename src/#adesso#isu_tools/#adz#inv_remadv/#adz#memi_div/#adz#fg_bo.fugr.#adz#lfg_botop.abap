FUNCTION-POOL /ADZ/FG_BO.                "MESSAGE-ID ..

* INCLUDE /ADZ/LFG_BOD...                 " Local class definition
INCLUDE ievardat.
INCLUDE ieaprcco.
INCLUDE ieapertyp.

TYPE-POOLS: slis.

TYPES:
  BEGIN OF ts_memi_doc_sta_upd,
    doc_id          TYPE /idxmm/de_doc_id,
    doc_status      TYPE /idxmm/de_doc_status,
    remadv_idoc     TYPE /idxmm/de_remadv_idoc,
    inv_doc_no      TYPE inv_int_inv_doc_no,
    clearing_doc_no TYPE augbl_kk,
  END OF ts_memi_doc_sta_upd,

  BEGIN OF ts_memi_fkkmavs,
    opbel TYPE opbel_kk,
    opupk TYPE opupk_kk,
    mahnv TYPE mahnv_kk,
    mahns TYPE mahns_kk,
    mahnn TYPE mahnn_kk,
  END OF ts_memi_fkkmavs,

  BEGIN OF ts_fkkcl_sum,
    opbel     TYPE opbel_kk,
    opupk     TYPE opupk_kk,
    betrw_sum TYPE betrw_kk,
    betrw_alc TYPE betrw_kk,
  END OF ts_fkkcl_sum,
  tt_fkkcl_sum TYPE TABLE OF ts_fkkcl_sum.

DATA:
  gv_ref_nr            TYPE char14,
  gv_proc_ref          TYPE /idxgc/de_proc_ref,
  gv_rev_proc_ref      TYPE /idxgc/de_proc_ref,
  gv_inv_unit_guid     TYPE inv_unit_guid_kk,
  gt_memi_doc_trig_inv TYPE /idxmm/t_memi_doc,
  gt_memi_doc_sta_upd  TYPE TABLE OF ts_memi_doc_sta_upd,
  gt_memi_fkkmavs      TYPE TABLE OF ts_memi_fkkmavs.
