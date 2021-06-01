FUNCTION-POOL z_inkasso_fg.                 "MESSAGE-ID ..

* INCLUDE LZ_INKASSO_FGD...                  " Local class definition
"MESSAGE-ID ..

*------------*
* type pools:
*------------*
TYPE-POOLS: abadr.

*-----------*
* constants:
*-----------*
CONSTANTS:
*--- FM Derivation Rule
con_applclass_fi     TYPE tabadr-applclass    VALUE 'FI',
con_subclass         TYPE tabadr-subclass     VALUE '01',
con_stratid_fica     TYPE tabadr-abadrstratid VALUE 'FICA',
con_identifier_1     TYPE abadr_identifier    VALUE 'FKKCOLLAG',
con_env              TYPE tabadrs-abadrenv    VALUE 'SAP'.

TABLES:
  fkkcollag.

DATA:
  ok_code             TYPE sy-ucomm,
  sav_ok_code         TYPE sy-tcode,
  g_trace_handle      TYPE i,
  answer.

* FUNCTION CODES FOR TABSTRIP 'SOURCETAB'
CONSTANTS: BEGIN OF c_sourcetab,
             tab1 LIKE sy-ucomm VALUE 'SOURCETAB_FC1',
             tab2 LIKE sy-ucomm VALUE 'SOURCETAB_FC2',
             tab3 LIKE sy-ucomm VALUE 'SOURCETAB_FC3',
           END OF c_sourcetab.
* DATA FOR TABSTRIP 'SOURCETAB'
CONTROLS:  sourcetab TYPE TABSTRIP.
DATA:      BEGIN OF g_sourcetab,
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
  co_auth_dummy  TYPE isu_author-field VALUE '<<DUMMY>>',
  co_display     TYPE  e_mode          VALUE '1',   " Anzeigen
  co_for_account                       VALUE 'T',
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
DATA:  BEGIN OF wa_head_buftab,
          opbel LIKE fkkko-opbel,
          herkf LIKE fkkko-herkf,
          xblnr LIKE fkkko-xblnr,
          cpudt LIKE fkkko-cpudt,
          cputm LIKE fkkko-cputm,
          storb LIKE fkkko-storb,   "FAKT USABILITY
          htext type HTEXT_KK,
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

*>>>> FAKT_USABILITY
*data: wa_tfk033d  type tfk033d.
*data: begin of wa_eabp.
*data: opbel like fkkop-opbel,
*      gpart like fkkop-gpart,
*      deaktiv like fkkop-deaktiv.
*data: end of wa_eabp.
*data: it_eabp like wa_eabp occurs 0.
*
*data: i_eabp_vtref like eabp-vertrag.   "******************
*
*data: begin of wa_erdb.
*data: opbel  type opbel_kk,
*      invopbel type opbel_kk,
*      doc_id type e_docid,
*      gpart like fkkop-gpart.
*data: end of wa_erdb.
*data: it_erdb like wa_erdb occurs 0.
*
*data: begin of wa_invoice_trans.
*include structure TFKIVV.
*data: end of wa_invoice_trans.
*
*data: t_invoice_trans like wa_invoice_trans occurs 0.
*
*data: begin of wa_lead_postab.
*  include structure fkkepos.
*data: end of wa_lead_postab.
*data: t_lead_postab like wa_lead_postab occurs 0.
*
*data: begin of wa_postab_inv.
*  include structure fkkepos.
*data: end of wa_postab_inv.
*data: t_postab_inv like wa_postab_inv occurs 0.
*
*data: t_fields_fkkepos like dfies occurs 0 with header line.
*data: x_read_r011 type xfeld,
*      x_no_old_bbp type xfeld.
*
*data: t_postab_new like fkkepos occurs 0.
*data: wa_postab_new like fkkepos.
*data: t_postab_inv_help like fkkepos occurs 0.
*data: wa_postab_inv_help like fkkepos.
*data: h_opbel type opbel_kk_rg.
*data: begin of wa_opbel_kk_rg.
*data: opbel type opbel_kk_rg,
*      augrd type augrd_kk.
*data: end of wa_opbel_kk_rg.
*data: t_opbel_kk_rg like wa_opbel_kk_rg occurs 0.
*data: wa_postab_absumb like fkkepos.
*data: t_postab_absumb like fkkepos occurs 0.
*data: h_diff type betrw_kk.

DATA: x_read_r011   LIKE boole-boole,
      x_no_old_bbp  LIKE boole-boole.

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

data: t_postab_inv_save like wa_postab_inv occurs 0.       "note 761162
data: wa_postab_inv_save like wa_postab_inv.               "note 761162

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
DATA: opbel TYPE opbel_kk_rg,
      augrd TYPE augrd_kk,
      herkf TYPE herkf_kk,
      h_count TYPE sy-tabix.
DATA: END OF wa_opbel_kk_rg.
DATA: t_opbel_kk_rg LIKE wa_opbel_kk_rg OCCURS 0.

* T_POSTAB_NEW collect new items when invoice can be condensed,
* items are appended to T_POSTAB in the end if amount not zero
DATA: t_postab_new LIKE fkkepos OCCURS 0.
DATA: wa_postab_new LIKE fkkepos.

* T_ERDB includes all ERDBs for one business partner
TYPES: BEGIN OF ty_erdb,
         opbel  TYPE opbel_kk,
         invopbel TYPE opbel_kk,
         doc_id TYPE e_docid,
         gpart LIKE fkkop-gpart,
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
DATA: opbel LIKE fkkop-opbel,
      gpart LIKE fkkop-gpart,
      vtref LIKE fkkop-vtref,                              "note 909685
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
DATA: obj TYPE swc_object,
      objtype LIKE tojtb-name,
      method LIKE ewaact-method,
      cont LIKE swcont OCCURS 0 WITH HEADER LINE,
      key LIKE ewaact-method.


*>>>> FAKT_USABILITY

data: g_isu_1211_processed type xflag,     "note 788302
      g_eff_inactive       type xflag.
