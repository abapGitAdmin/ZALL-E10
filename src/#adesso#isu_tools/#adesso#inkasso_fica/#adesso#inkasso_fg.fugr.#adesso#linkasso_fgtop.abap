FUNCTION-POOL /adesso/inkasso_fg.           "MESSAGE-ID ..

DATA: h_man_sel TYPE c.   " manual selection of Collection Agency
DATA: ut_dfkkop LIKE dfkkop OCCURS 0 WITH HEADER LINE.
DATA:   t_tfkfbc_5054       LIKE tfkfbc    OCCURS 0 WITH HEADER LINE,
        t_tfkfbc_5059       LIKE tfkfbc    OCCURS 0 WITH HEADER LINE,
        t_tfkfbc_5060       LIKE tfkfbc    OCCURS 0 WITH HEADER LINE.

* Includes for FKK_SAMOLE_1729
INCLUDE lfkkaktiv2con.
INCLUDE lfkkaktiv2mac.

*-----------------------------------------------------------------------
* Declaration of constants
*-----------------------------------------------------------------------
CONSTANTS: c_header                 TYPE satztyp_i_kk VALUE '1'.
CONSTANTS: c_position               TYPE satztyp_i_kk VALUE '2'.
CONSTANTS: c_trailer                TYPE satztyp_i_kk VALUE '9'.
CONSTANTS: c_payment                TYPE postyp_kk    VALUE '1'.
CONSTANTS: c_recall                 TYPE postyp_kk    VALUE '2'.
CONSTANTS: c_master_data_changes    TYPE postyp_kk    VALUE '3'.
CONSTANTS: c_storno                 TYPE postyp_kk    VALUE '4'.
CONSTANTS: c_clearing               TYPE postyp_kk    VALUE '5'.
CONSTANTS: c_coll_ag_paid           TYPE postyp_kk    VALUE '6'.
CONSTANTS: c_cancelled_receivable   TYPE postyp_kk    VALUE '7'.
CONSTANTS: c_write_off              TYPE postyp_kk    VALUE '8'.
* adesso Postitionstyp
CONSTANTS: c_pt_sell                TYPE postyp_kk    VALUE 'V'.
CONSTANTS: c_pt_decl                TYPE postyp_kk    VALUE 'A'.
*
CONSTANTS: c_released               TYPE agsta_kk     VALUE '01'.
CONSTANTS: c_receivable_submitted   TYPE agsta_kk     VALUE '02'.
CONSTANTS: c_receivable_paid        TYPE agsta_kk     VALUE '03'.
CONSTANTS: c_receivable_part_paid   TYPE agsta_kk     VALUE '04'.
CONSTANTS: c_receivable_cancelled   TYPE agsta_kk     VALUE '05'.
CONSTANTS: c_receivable_write_off   TYPE agsta_kk     VALUE '06'.
CONSTANTS: c_agsta_cu_t-erfolglos   TYPE agsta_kk     VALUE '07'.
CONSTANTS: c_agsta_t-erfolglos      TYPE agsta_kk     VALUE '08'.
CONSTANTS: c_receivable_recalled    TYPE agsta_kk     VALUE '09'.
CONSTANTS: c_costumer_directly_paid TYPE agsta_kk     VALUE '10'.
CONSTANTS: c_costumer_partally_paid TYPE agsta_kk     VALUE '11'.
CONSTANTS: c_full_clearing          TYPE agsta_kk     VALUE '12'.
CONSTANTS: c_partial_clearing       TYPE agsta_kk     VALUE '13'.
CONSTANTS: c_receivable_part_write_off TYPE agsta_kk  VALUE '15'.
CONSTANTS: c_rec_recall_part_write_off TYPE agsta_kk  VALUE '16'.
* adesso Stati
CONSTANTS: c_direct_wroff           TYPE agsta_kk     VALUE '20'.
CONSTANTS: c_sell                   TYPE agsta_kk     VALUE '30'.
CONSTANTS: c_decl_sell_wroff        TYPE agsta_kk     VALUE '31'.
CONSTANTS: c_decl_sell_rcall        TYPE agsta_kk     VALUE '32'.
*
CONSTANTS: c_sum_no                 TYPE sumknz_kk    VALUE ''.
CONSTANTS: c_sum_gpart              TYPE sumknz_kk    VALUE '1'.
CONSTANTS: c_sum_nrzas              TYPE sumknz_kk    VALUE '2'.
CONSTANTS: c_sum_vkont              TYPE sumknz_kk    VALUE '3'.
CONSTANTS: c_event_5051             LIKE tfkfbm-fbeve VALUE '5051'.
CONSTANTS: c_event_5052             LIKE tfkfbm-fbeve VALUE '5052'.
CONSTANTS: c_event_5053             LIKE tfkfbm-fbeve VALUE '5053'.
CONSTANTS: c_subname(04)            TYPE c            VALUE 'COLI'.
CONSTANTS: c_msgprio_high           LIKE fimsg-msgpr  VALUE '1'.
CONSTANTS: c_msgprio_medium         LIKE fimsg-msgpr  VALUE '2'.
CONSTANTS: c_msgprio_low            LIKE fimsg-msgpr  VALUE '3'.
CONSTANTS: c_msgprio_info           LIKE fimsg-msgpr  VALUE '4'.
CONSTANTS: c_inkgp(05)              TYPE c            VALUE 'INKGP'.
CONSTANTS: c_marked                 TYPE c            VALUE 'X'.
CONSTANTS: c_hstorno                TYPE herkf_kk     VALUE '02'.
CONSTANTS: c_hrueckl                TYPE herkf_kk     VALUE '08'.
CONSTANTS: c_hrausgl                TYPE herkf_kk     VALUE '09'.
CONSTANTS: c_htrausgl               TYPE herkf_kk     VALUE '39'.
CONSTANTS: c_buber_1059             TYPE buber_kk     VALUE '1059'.
CONSTANTS: c_only_log               TYPE c            VALUE 'X'.
CONSTANTS: true                     TYPE c            VALUE 'X'.
CONSTANTS: false                    TYPE c            VALUE space.
CONSTANTS: c_no_msg_per_service          TYPE i            VALUE '10'.

*-------------------- new appl. log for mass activity -----------------*
CONSTANTS: const_aktyp_wo   TYPE aktyp_kk   VALUE '0097',
           const_objtype_gp TYPE swo_objtyp VALUE 'CA_BUS1006',
           const_objtype_vk TYPE swo_typeid VALUE 'CA_CONTACC',
           error_id         LIKE fkk_mass_act_count-countid VALUE '1',
           success_id       LIKE fkk_mass_act_count-countid VALUE '2',
           test_id          LIKE fkk_mass_act_count-countid VALUE '3'.

CONSTANTS: const_mode_insert VALUE 'I'.
CONSTANTS: const_aggrd_ausbuchen       LIKE dfkkcoll-aggrd VALUE '02'.
CONSTANTS: const_event_5054            LIKE tfkfbm-fbeve   VALUE '5054'.
CONSTANTS: const_event_5059            LIKE tfkfbm-fbeve   VALUE '5059'.
CONSTANTS: const_event_5060            LIKE tfkfbm-fbeve   VALUE '5060'.

*----------------------------------------------------------------------*
* Database tables
*----------------------------------------------------------------------*
TABLES:
  dfkkcoll,
  tfk050b.                                                  "0403ins.

*----------------------------------------------------------------------*
* Internal tables
*----------------------------------------------------------------------*
DATA: t_fkkcollh_i_w LIKE dfkkcollh_i_w OCCURS 0 WITH HEADER LINE.
DATA: lt_fkkcollh_i  LIKE fkkcollh_i    OCCURS 0 WITH HEADER LINE.
DATA: ht_agsta_range LIKE fkkr_agsta    OCCURS 0 WITH HEADER LINE.
DATA: ht_gpart_range LIKE fkkr_gpart    OCCURS 0 WITH HEADER LINE.
DATA: gt_inkgp       TYPE inkgp_kk      OCCURS 0 WITH HEADER LINE.
DATA: gt_fall        TYPE gpart_kk      OCCURS 0 WITH HEADER LINE.
DATA  gt_dd07v       LIKE dd07v         OCCURS 0 WITH HEADER LINE.
DATA  w_basics       TYPE fkk_mad_basics.
DATA: BEGIN OF t_gpart_inkgp OCCURS 0,
        gpart LIKE dfkkcoll-gpart,
        inkgp LIKE dfkkcoll-inkgp,
      END OF t_gpart_inkgp.
DATA: BEGIN OF t_inkgp_gpart OCCURS 0,
        inkgp LIKE dfkkcoll-inkgp,
        gpart LIKE dfkkcoll-gpart,
      END OF t_inkgp_gpart.
DATA: BEGIN OF t_gpart_datum OCCURS 0,
        gpart LIKE dfkkcoll-gpart,
        datum LIKE dfkkcoli_log-udate,
        uzeit LIKE dfkkcoli_log-utime,                      "260402ins
      END OF t_gpart_datum.
DATA: BEGIN OF t_stor OCCURS 0,
        storb LIKE dfkkcollh-storb,
      END OF t_stor.

*----------------------------------------------------------------------*
* structure additional fields for mass interest run
*----------------------------------------------------------------------*
DATA: gr_inkgp      TYPE fkkinkgp,
      g_fkkcollinfo TYPE fkkcollinfo.

*----------------------------------------------------------------------*
* Data definitions
*----------------------------------------------------------------------*
DATA: g_xcpart         TYPE xcpart_kk,
      g_xausg          TYPE xausg_kk,
      g_xback          TYPE xback_kk,
      g_xrever         TYPE xrever_kk,
      g_xreclr         TYPE xreclr_kk,
      g_xretrn         TYPE xretrn_kk,
      g_xstorno        TYPE xstorno_kk,
      g_xwroff         TYPE xwroff_kk,
      g_param          TYPE c,
      h_applk          LIKE tfkfbc-applk,
      h_runkey         TYPE fkk_mad_runkey,
      w_runkey         TYPE fkk_mad_runkey,
      w_inkkey(25),
      h_file_name(128),
      t_fkkcollh_i     LIKE fkkcollh_i,
      t_fkkcollt_i     LIKE fkkcollt_i,
      rc               LIKE sy-subrc.
DATA: g_dcpfm        TYPE xudcpfm.

DATA: lv_xml_for_gpart TYPE xfeld.

DATA: g_sort TYPE xfeld.
DATA: gt_fkkcollp_ip LIKE dfkkcollp_ip_w OCCURS 0 WITH HEADER LINE.
DATA: gt_fkkcollp_ir LIKE dfkkcollp_ir_w OCCURS 0 WITH HEADER LINE.

TYPES BEGIN OF gty_fkkcoli_log_ext.
TYPES inkgp  TYPE inkgp_kk.
TYPES gpart  TYPE gpart_kk.
TYPES coli_log_tab     TYPE fkkcoli_log_tab.
TYPES postyp_sum_tab   TYPE fkkcol_postyp_sum_tab.
TYPES END OF gty_fkkcoli_log_ext.

TYPES: BEGIN OF gty_fkkcollpaym_logkz,
         inkgp       TYPE inkgp_kk,
         collpaym_id TYPE collpaym_id_kk,
         collpaym_tp TYPE collpaym_tp_kk,
         logkz       TYPE logkz_kk,
       END OF gty_fkkcollpaym_logkz.
TYPES: gtt_fkkcollpaym_logkz TYPE TABLE OF gty_fkkcollpaym_logkz.

TYPES: BEGIN OF gty_fkkcollitem_logkz,
         inkgp       TYPE inkgp_kk,
         collitem_id TYPE collitem_id_kk,
         collitem_lv TYPE collitem_lv_kk,
         logkz       TYPE logkz_kk,
       END OF gty_fkkcollitem_logkz.
TYPES: gtt_fkkcollitem_logkz TYPE TABLE OF gty_fkkcollitem_logkz.

TYPES: BEGIN OF gty_xguid,
         gpart TYPE gpart_kk,
         xguid TYPE guidxi_kk,
       END OF gty_xguid.
TYPES: gtt_xguid TYPE TABLE OF gty_xguid.

DATA  gv_flg_coll_esoa_active  TYPE xfeld.
DATA  gt_collections_hash  TYPE HASHED TABLE OF fkkcollections WITH UNIQUE KEY inkgp gpart.
DATA  gt_collections       TYPE TABLE OF fkkcollections.
DATA  gt_coli_log_ext_hash TYPE HASHED TABLE OF gty_fkkcoli_log_ext WITH UNIQUE KEY inkgp gpart.
DATA  gt_collpaym_logkz    TYPE gtt_fkkcollpaym_logkz.
DATA  gt_collitem_logkz    TYPE gtt_fkkcollitem_logkz.
DATA  gt_xguid             TYPE gtt_xguid.

*>>>>> HANA
DATA: gt_fkkcollp_ip_w LIKE dfkkcollp_ip_w OCCURS 0 WITH HEADER LINE,
      gt_fkkcollp_ir_w LIKE dfkkcollp_ir_w OCCURS 0 WITH HEADER LINE,
      gt_fkkcollp_im_w LIKE dfkkcollp_im_w OCCURS 0 WITH HEADER LINE,
      gt_fkkcoli_log   LIKE dfkkcoli_log   OCCURS 0 WITH HEADER LINE,
      gv_coli_log_cnt  TYPE i.
*<<<<<< HANA
*----------------------------------------------------------------------*
* function modules for application exit
*----------------------------------------------------------------------*
DATA: t_fbstab      LIKE tfkfbc OCCURS 1 WITH HEADER LINE,
      t_tfkfbc_5051 LIKE tfkfbc OCCURS 0 WITH HEADER LINE,
      t_tfkfbc_5052 LIKE tfkfbc OCCURS 0 WITH HEADER LINE,
      t_tfkfbc_5053 LIKE tfkfbc OCCURS 0 WITH HEADER LINE.
*------------*
* type pools:
*------------*
TYPE-POOLS: abadr.

*-----------*
* constants:
*-----------*
CONSTANTS:
*--- FM Derivation Rule
  con_applclass_fi TYPE tabadr-applclass    VALUE 'FI',
  con_subclass     TYPE tabadr-subclass     VALUE '01',
  con_stratid_fica TYPE tabadr-abadrstratid VALUE 'FICA',
  con_identifier_1 TYPE abadr_identifier    VALUE 'FKKCOLLAG',
  con_env          TYPE tabadrs-abadrenv    VALUE 'SAP',
  const_marked(1)  TYPE c VALUE 'X'.

CONSTANTS: const_agsta_freigegeben    LIKE dfkkcoll-agsta VALUE '01',
           const_agsta_abgegeben      LIKE dfkkcoll-agsta VALUE '02',
           const_agsta_bezahlt        LIKE dfkkcoll-agsta VALUE '03',
           const_agsta_teilbezahlt    LIKE dfkkcoll-agsta VALUE '04',
           const_agsta_storniert      LIKE dfkkcoll-agsta VALUE '05',
           const_agsta_erfolglos      LIKE dfkkcoll-agsta VALUE '06',
           const_agsta_cu_t_erfolglos LIKE dfkkcoll-agsta VALUE '07',
           const_agsta_t_erfolglos    LIKE dfkkcoll-agsta VALUE '08',
           const_agsta_recall         LIKE dfkkcoll-agsta VALUE '09',
           const_agsta_cust_pay       LIKE dfkkcoll-agsta VALUE '10',
           const_agsta_cust_p_pay     LIKE dfkkcoll-agsta VALUE '11',
           const_agsta_paid           LIKE dfkkcoll-agsta VALUE '12',
           const_agsta_p_paid         LIKE dfkkcoll-agsta VALUE '13',
           const_agsta_rel_erfolglos  LIKE dfkkcoll-agsta VALUE '14',
           const_agsta_sub_erfolglos  LIKE dfkkcoll-agsta VALUE '15',
           const_agsta_rec_erfolglos  LIKE dfkkcoll-agsta VALUE '16'.

* adesso Stati
CONSTANTS: const_direct_wroff         TYPE agsta_kk     VALUE '20'.
CONSTANTS: const__sell                TYPE agsta_kk     VALUE '30'.
CONSTANTS: const_decl_sell_wroff      TYPE agsta_kk     VALUE '31'.
CONSTANTS: const_decl_sell_rcall      TYPE agsta_kk     VALUE '32'.

CONSTANTS: const_event_5065            LIKE tfkfbm-fbeve   VALUE '5065'.
CONSTANTS: const_mode_modify                               VALUE 'M'.
CONSTANTS: const_proid                 LIKE tfk042c-proid  VALUE '0008'.

* table with the NEW content of: DFKKCOLL
DATA: BEGIN OF xdfkkcoll OCCURS 20.
        INCLUDE STRUCTURE vdfkkcoll.
      DATA: END OF xdfkkcoll.

* table with the OLD content of: DFKKCOLL
DATA: BEGIN OF ydfkkcoll OCCURS 20.
        INCLUDE STRUCTURE vdfkkcoll.
      DATA: END OF ydfkkcoll.

TABLES:
  fkkcollag.

DATA:
  ok_code        TYPE sy-ucomm,
  sav_ok_code    TYPE sy-tcode,
  g_trace_handle TYPE i,
  answer.

* FUNCTION CODES FOR TABSTRIP 'SOURCETAB'
CONSTANTS: BEGIN OF c_sourcetab,
             tab1 LIKE sy-ucomm VALUE 'SOURCETAB_FC1',
             tab2 LIKE sy-ucomm VALUE 'SOURCETAB_FC2',
             tab3 LIKE sy-ucomm VALUE 'SOURCETAB_FC3',
           END OF c_sourcetab.
* DATA FOR TABSTRIP 'SOURCETAB'
CONTROLS:  sourcetab TYPE TABSTRIP.
DATA: BEGIN OF g_sourcetab,
        subscreen   LIKE sy-dynnr,
        prog        LIKE sy-repid VALUE 'SAPLFKA12',
        pressed_tab LIKE sy-ucomm VALUE c_sourcetab-tab1,
      END OF g_sourcetab.

DATA:   ht_enqtab       LIKE ienqtab OCCURS 0 WITH HEADER LINE.
DATA:  okcode          LIKE sy-ucomm.

DATA i003.

INCLUDE:  emsg,
          iekivorg,
          iekconst,
          iecbuber,
          <cntn01>,
          mea00dat01type,
          meamac00,
          iee_inv_par_process.         "note 974405

TABLES: te305t,
        te305,
        tfk001t,
        dfkkko,
        tfktvot,
        tfkhvot.

* DUMMY-field for function module ISU_AUTHORITY_CHECK
CONSTANTS:
  co_auth_dummy      TYPE isu_author-field VALUE '<<DUMMY>>',
  co_display         TYPE  e_mode          VALUE '1',   " Anzeigen
  co_for_account     VALUE 'T',
  co_auth_object     LIKE xu100-object   VALUE  'E_INVOICE',
  co_authid_activity LIKE isu_author-id  VALUE 'ISU_ACTIVT',
  co_authid_vktyp_kk LIKE isu_author-id  VALUE 'VKTYP_KK',
  co_authid_bukrs    LIKE isu_author-id  VALUE 'BUKRS',
  co_authid_begru    LIKE isu_author-id  VALUE 'BEGRU'.

DATA: BEGIN OF wa_vkont_buftab,
        gpart LIKE fkkop-gpart,
        vkont LIKE fkkvkp-vkont,
        vkbez LIKE fkkvkp-vkbez,
      END OF wa_vkont_buftab.

DATA  vkont_buftab LIKE SORTED TABLE OF wa_vkont_buftab
*>>>CJM
*      with non-unique key vkont.
       WITH UNIQUE KEY gpart vkont.
DATA:  g_gpart LIKE fkkop-gpart.
*<<<CJM
DATA: BEGIN OF wa_head_buftab,
        opbel LIKE fkkko-opbel,
        herkf LIKE fkkko-herkf,
        xblnr LIKE fkkko-xblnr,
        cpudt LIKE fkkko-cpudt,
        cputm LIKE fkkko-cputm,
        storb LIKE fkkko-storb,   "FAKT USABILITY
        htext TYPE htext_kk,
        ernam LIKE fkkko-ernam,
      END OF wa_head_buftab.
DATA: BEGIN OF wa_applk_buffer,
        applk LIKE fkkop-applk,
      END OF wa_applk_buffer.
*-----------------------------------------------------------------------
DATA: BEGIN OF wa_hvtxt_buftab,
        applk LIKE fkkop-applk,
        hvorg LIKE fkkop-hvorg,
        hvtxt LIKE tfkhvot-txt30,
      END OF wa_hvtxt_buftab.

DATA  hvtxt_buftab LIKE SORTED TABLE OF wa_hvtxt_buftab
      WITH NON-UNIQUE KEY hvorg.

DATA: BEGIN OF wa_augrd_vorg_buffer,
        augrd LIKE fkkop-augrd,
        hvorg LIKE fkkop-hvorg,
        tvorg LIKE fkkop-tvorg,
      END OF wa_augrd_vorg_buffer.

DATA: bufktopl LIKE tfk033d-ktopl.
DATA: akto_hv LIKE tfktvo-hvorg.
DATA: akto_tvza LIKE tfktvo-tvorg.


DATA: x_read_r011  LIKE boole-boole,
      x_no_old_bbp LIKE boole-boole.

* Tables
* T_POSTAB_INV includes all items which belong to an invoice
* (if DocId ne FPRZX) or a reversal of an invoics
* even the leading positions are included here
DATA: BEGIN OF wa_postab_inv.
        INCLUDE STRUCTURE fkkepos.
      DATA: END OF wa_postab_inv.
DATA: t_postab_inv LIKE wa_postab_inv OCCURS 0.
DATA: t_postab_inv_hash LIKE HASHED TABLE OF wa_postab_inv
                        WITH UNIQUE KEY opbel opupk opupz opupw.

DATA: t_postab_inv_save LIKE wa_postab_inv OCCURS 0.       "note 761162
DATA: wa_postab_inv_save LIKE wa_postab_inv.               "note 761162

* T_LEAD_POSTAB includes all the 'Leading items' of the invoices,
* but not for reversals, because they can't be determined in Event 1205
DATA: BEGIN OF wa_lead_postab.
        INCLUDE STRUCTURE fkkepos.
      DATA: END OF wa_lead_postab.
DATA: t_lead_postab LIKE wa_lead_postab OCCURS 0.

* T_POSTAB_INV_HELP collects items which can be deleted,
* corresponding items from T_POSTAB_INV are deleted then
DATA: t_postab_inv_help LIKE fkkepos OCCURS 0.
DATA: wa_postab_inv_help LIKE fkkepos.

* T_OPBEL_KK_RG contains one entry for every invoice and for
* every reversal of an invoice
* infvo
DATA: BEGIN OF wa_opbel_kk_rg.
DATA: opbel   TYPE opbel_kk_rg,
      augrd   TYPE augrd_kk,
      herkf   TYPE herkf_kk,
      h_count TYPE sy-tabix.
DATA: END OF wa_opbel_kk_rg.
DATA: t_opbel_kk_rg LIKE wa_opbel_kk_rg OCCURS 0.

* T_POSTAB_NEW collect new items when invoice can be condensed,
* items are appended to T_POSTAB in the end if amount not zero
DATA: t_postab_new LIKE fkkepos OCCURS 0.
DATA: wa_postab_new LIKE fkkepos.

* T_ERDB includes all ERDBs for one business partner
TYPES: BEGIN OF ty_erdb,
         opbel    TYPE opbel_kk,
         invopbel TYPE opbel_kk,
         doc_id   TYPE e_docid,
         gpart    LIKE fkkop-gpart,
       END OF ty_erdb.
DATA: wa_erdb TYPE ty_erdb.
DATA: it_erdb TYPE HASHED TABLE OF ty_erdb
              WITH UNIQUE KEY invopbel.

* Tables for the determination of the transactions
DATA: BEGIN OF wa_invoice_trans.
        INCLUDE STRUCTURE tfkivv.
      DATA: END OF wa_invoice_trans.

DATA: t_invoice_trans LIKE wa_invoice_trans OCCURS 0.
DATA: t_inv_trans_guth LIKE wa_invoice_trans OCCURS 0.
DATA: gt_buffer_trans_list LIKE wa_invoice_trans OCCURS 0.
DATA: wa_inv_trans_guth LIKE wa_invoice_trans.

* T_EABP includes all BBPlans for on BP
DATA: BEGIN OF wa_eabp.
DATA: opbel   LIKE fkkop-opbel,
      gpart   LIKE fkkop-gpart,
      vtref   LIKE fkkop-vtref,                              "note 909685
      deaktiv LIKE fkkop-deaktiv.
DATA: END OF wa_eabp.
DATA: it_eabp LIKE wa_eabp OCCURS 0.
DATA: i_eabp_vtref LIKE eabp-vertrag.

* T_ZEROCL includes all lines which are set to no display,
* corresponding line has to be changed to no-zero-clearing in Event 1211
DATA: BEGIN OF wa_zerocl.
        INCLUDE STRUCTURE fkkepos.
      DATA: END OF wa_zerocl.
DATA: t_zerocl LIKE wa_zerocl OCCURS 0.

DATA: wa_dfkkrapt TYPE dfkkrapt.
DATA: t_fields_fkkepos LIKE dfies OCCURS 0 WITH HEADER LINE.

* Display Print Document
DATA: obj     TYPE swc_object,
      objtype LIKE tojtb-name,
      method  LIKE ewaact-method,
      cont    LIKE swcont OCCURS 0 WITH HEADER LINE,
      key     LIKE ewaact-method.


*>>>> FAKT_USABILITY

DATA: g_isu_1211_processed TYPE xflag,     "note 788302
      g_eff_inactive       TYPE xflag.

** --> Nuss ab 04.2016
DATA: gs_inkasso_cust TYPE /adesso/ink_cust,
      gt_inkasso_cust TYPE STANDARD TABLE OF /adesso/ink_cust.

DATA: gs_nfhf TYPE /adesso/ink_nfhf,
      gt_nfhf TYPE STANDARD TABLE OF /adesso/ink_nfhf.


DATA: gt_bgus TYPE TABLE OF /adesso/ink_bgus.
DATA: gs_bgus TYPE /adesso/ink_bgus.
DATA: gt_bgsb TYPE TABLE OF /adesso/ink_bgsb.
DATA: gs_bgsb TYPE /adesso/ink_bgsb.

DATA: gs_inkasso_sum TYPE /adesso/inkasso_sum,
      gt_inkasso_sum TYPE /adesso/inkasso_sumt.

DATA: gs_inkasso_birth  TYPE /adesso/inkbirth.

DATA: gs_but000 TYPE but000.

DATA: gs_texte TYPE /adesso/ink_text.
DATA: gs_ink_addi TYPE /adesso/ink_addi.

DATA: gs_ink_infi TYPE /adesso/ink_infi.
DATA: gt_ink_infi TYPE TABLE OF /adesso/ink_infi.

DATA: gs_wo_mon TYPE /adesso/wo_mon.
DATA: gt_wo_mon TYPE TABLE OF /adesso/wo_mon.

DATA: gr_hvorg TYPE RANGE OF hvorg_kk.
DATA: gs_hvorg LIKE LINE OF gr_hvorg.

DATA: gr_lockr TYPE RANGE OF lockr_kk.
DATA: gs_lockr LIKE LINE OF gr_lockr.

DATA: gs_sumbtrg TYPE betrw_kk.

DATA: gf_laufd TYPE laufd_kk.
DATA: gf_laufi TYPE laufi_kk.
