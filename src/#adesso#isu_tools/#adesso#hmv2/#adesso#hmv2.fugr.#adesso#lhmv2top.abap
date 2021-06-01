*&---------------------------------------------------------------------*
*&  Include           /ADESSO/LHMV2TOP
*&---------------------------------------------------------------------*
  FUNCTION-POOL /adesso/hmv2               MESSAGE-ID sv.

  INCLUDe: <icon>.
  INCLUDE: /adesso/hmv_constants.

*  DATA: gr_const TYPE REF TO /adesso/cl_hmv_customizing.
*DATA: t_hmv_cons TYPE TABLE OF /adesso/hmv_cons,
*      s_hmv_cons TYPE /adesso/hmv_cons.
  "SELECT count( * ) FROM /adesso/hmv_sart .

*DATA:
*  c_lockaktyp         TYPE fkkopchl-lockaktyp,
*  c_lotyp             TYPE fkkopchl-lotyp,
*  c_proid             TYPE fkkopchl-proid,
*  c_faedn_from        TYPE dfkkop-faedn,
*  c_invoice_paym      TYPE tinv_inv_doc-invoice_type,
*  c_invoice_paymst    LIKE tinv_inv_doc-inv_doc_status,
*  c_invoice_type2     TYPE tinv_inv_doc-invoice_type,
*  c_invoice_type4     TYPE tinv_inv_doc-invoice_type,
*  c_invoice_status_03 TYPE char2,
*  c_invoice_status_04 TYPE char2,
*  c_hvorg_akonto      TYPE tfkhvo-hvorg,
*  c_invoice_type7     LIKE tinv_inv_doc-invoice_type,
*  c_invoice_type8     LIKE tinv_inv_doc-invoice_type.


  DATA:
    t_hmv_sart        TYPE TABLE OF /adesso/hmv_sart,
    s_hmv_sart        TYPE          /adesso/hmv_sart,
    wa_out            TYPE          /adesso/hmv_out,
    wet_out           TYPE          /adesso/hmv_out,
    t_selct           TYPE TABLE OF /adesso/hmv_selct,
    t_selct_memi      TYPE TABLE OF /adesso/hmv_selct_memi WITH HEADER LINE,
    t_selct_msb       TYPE TABLE OF /adesso/hmv_selct_msb WITH HEADER LINE,          "Nuss 09.2018
    f_lockr           TYPE          mansp_old_kk,
    f_fdate           TYPE          sydatum,
    f_tdate           TYPE          sydatum,
    t_memidoc         TYPE TABLE OF /idxmm/memidoc,
    t_idxmm_docstscfg TYPE TABLE OF /idxmm/docstscfg,
    s_idxmm_docstscfg TYPE          /idxmm/docstscfg,
    lt_idxmm_docst    TYPE          /idxmm/docstscfg.

  DATA: rng_docstatus TYPE RANGE OF /idxmm/docstscfg-doc_status WITH HEADER LINE.

  DATA:
    t_dfkkthi  TYPE TABLE OF dfkkthi,
    ls_dfkkthi LIKE LINE OF t_dfkkthi.

  FIELD-SYMBOLS:
    <fs_dfkkthi> TYPE dfkkthi,
    <fs_memidoc> TYPE /idxmm/memidoc,
    <fs_docst>   TYPE /idxmm/docstscfg.

  DATA: it_out TYPE TABLE OF dfkkthi.

* IDoc Statussatz
  DATA:
    BEGIN OF s_edids,
      docnum TYPE edi_docnum,
      status TYPE edi_status,
    END OF s_edids.

  DATA: it_edids LIKE TABLE OF s_edids.

*>>> UH 22012013
  DATA:
    BEGIN OF wa_bcbln,
      opbel LIKE dfkkop-opbel,
      augst LIKE dfkkop-augst,
    END OF wa_bcbln.
  DATA: t_bcbln LIKE TABLE OF wa_bcbln.
  FIELD-SYMBOLS: <t_bcbln> LIKE wa_bcbln.
*<<< UH 22012013

  DATA:
    BEGIN OF wa_so_augst,
      sign   TYPE rsdsselopt-sign,
      option TYPE rsdsselopt-option,
      low    TYPE fkkop-augst,
      high   TYPE fkkop-augst,
    END OF wa_so_augst.
  DATA: t_so_augst LIKE TABLE OF wa_so_augst.
  DATA: ls_so_augst LIKE wa_so_augst.

  DATA: t_so_mansp TYPE RANGE OF fkkmaze-mansp.
  DATA: t_so_mahns TYPE RANGE OF fkkmako-mahns.

  DATA:
    BEGIN OF wa_fkkop,
      vkont           LIKE fkkop-vkont,
      bukrs           LIKE fkkop-bukrs,
      crsrf           LIKE fkkop-int_crossrefno,
      bcbln           LIKE dfkkthi-bcbln,
      vtref           LIKE fkkop-vtref,
      thinr           LIKE dfkkthi-thinr,
      opbel           LIKE fkkmaze_struc-opbel,
      opupw           LIKE fkkmaze_struc-opupw,
      opupk           LIKE fkkmaze_struc-opupk,
      opupz           LIKE fkkmaze_struc-opupz,
      blart           LIKE fkkop-blart,
      stakz           LIKE fkkop-stakz,
      augst           LIKE fkkop-augst,
      faedn           LIKE dfkkthi-thidt,
      thprd           LIKE dfkkthi-thprd,
      mansp           LIKE fkkop-mansp,
      waers           LIKE fkkop-waers,
      betrh           LIKE fkkop-betrh,
      ikey            LIKE fkkop-ikey,
      idocin          TYPE /adesso/hmv_idocin,
      statin          TYPE /adesso/hmv_statin,
      idocct          TYPE /adesso/hmv_idocct,
      statct          TYPE /adesso/hmv_statct,
      dexproc         TYPE e_dexproc,
      dexidocsent     TYPE e_dexidocsent,
      dexidocsentctrl TYPE e_dexidocsent,
      dexidocsendcat  TYPE e_dexidocsendcat,
      intui           LIKE dfkkthi-intui,
      ext_ui          TYPE ext_ui,
      thist           LIKE dfkkthi-thist,
      hvorg           LIKE fkkop-hvorg,
      tvorg           LIKE fkkop-tvorg,
      spart           LIKE fkkop-spart,
      gpart           LIKE fkkop-gpart,
      xtaus           LIKE fkkop-xtaus,
      xmanl           LIKE fkkop-xmanl,
      keydate         LIKE dfkkthi-keydate,
      status(30),
      akonto(30),
    END OF wa_fkkop.

  DATA: t_fkkop LIKE TABLE OF wa_fkkop.
  FIELD-SYMBOLS: <t_fkkop> LIKE wa_fkkop.

* --> Nuss 09.2018
DATA:
  BEGIN OF wa_fkkop_msb,
    vkont           LIKE fkkop-vkont,
    bukrs           LIKE fkkop-bukrs,
    crsrf           LIKE fkkop-int_crossrefno,
    crossrefno      like ecrossrefno-crossrefno,    "Nuss 09.2018
    bcbln           LIKE dfkkthi-bcbln,
    vtref           LIKE fkkop-vtref,
    thinr           LIKE dfkkthi-thinr,
    opbel           LIKE fkkmaze_struc-opbel,
    opupw           LIKE fkkmaze_struc-opupw,
    opupk           LIKE fkkmaze_struc-opupk,
    opupz           LIKE fkkmaze_struc-opupz,
    blart           LIKE fkkop-blart,
    stakz           LIKE fkkop-stakz,
    augst           LIKE fkkop-augst,
    faedn           LIKE dfkkthi-thidt,
    thprd           LIKE dfkkthi-thprd,
    mansp           LIKE fkkop-mansp,
    waers           LIKE fkkop-waers,
    betrh           LIKE fkkop-betrh,
    ikey            LIKE fkkop-ikey,
    senid           type senid_kk,               "Nuss 09.2018
    recid           type recid_kk,               "Nuss 09.2018
    idocin          TYPE /adesso/hmv_idocin,
    statin          TYPE /adesso/hmv_statin,
    idocct          TYPE /adesso/hmv_idocct,
    statct          TYPE /adesso/hmv_statct,
    dexproc         TYPE e_dexproc,
    dexidocsent     TYPE e_dexidocsent,
    dexidocsentctrl TYPE e_dexidocsent,
    dexidocsendcat  TYPE e_dexidocsendcat,
    intui           LIKE dfkkthi-intui,
    ext_ui          TYPE ext_ui,
    thist           LIKE dfkkthi-thist,
    hvorg           LIKE fkkop-hvorg,
    tvorg           LIKE fkkop-tvorg,
    spart           LIKE fkkop-spart,
    gpart           LIKE fkkop-gpart,
    xtaus           LIKE fkkop-xtaus,
    xmanl           LIKE fkkop-xmanl,
    keydate         LIKE dfkkthi-keydate,
    status(30),
    akonto(30),
  END OF wa_fkkop_msb.

DATA: t_fkkop_msb LIKE TABLE OF wa_fkkop_msb.
FIELD-SYMBOLS: <t_fkkop_msb> LIKE wa_fkkop_msb.
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

  DATA: t_crsrf LIKE TABLE OF wa_crsrf.
  FIELD-SYMBOLS: <t_crsrf> LIKE wa_crsrf.


  DATA:
    BEGIN OF wa_remadv,
      own_invoice_no LIKE ecrossrefno-crossrefno,
      invoice_type   LIKE tinv_inv_doc-invoice_type,
      int_inv_doc_no LIKE tinv_inv_line_a-int_inv_doc_no,
      invoice_status LIKE tinv_inv_head-invoice_status,
      doc_type       LIKE tinv_inv_doc-doc_type,
      inv_doc_status LIKE tinv_inv_doc-inv_doc_status,
      rstgr          LIKE tinv_inv_line_a-rstgr,
    END OF wa_remadv.

  DATA: t_remadv  LIKE TABLE OF wa_remadv.
  FIELD-SYMBOLS: <t_remadv> LIKE wa_remadv.


  DATA:
    BEGIN OF wa_akonto,
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
    END OF wa_akonto.

  DATA: t_akonto LIKE TABLE OF wa_akonto.
  FIELD-SYMBOLS: <t_akonto> LIKE wa_akonto.

  DATA: wa_fkkopchl TYPE fkkopchl.
  DATA: t_fkkopchl TYPE TABLE OF fkkopchl.

* INCLUDE /ADESSO/LHMV2D...                  " Local class definition
