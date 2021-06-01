FUNCTION-POOL /adesso/mt_entladung.         "MESSAGE-ID ..

TYPE-POOLS: isu25.


TABLES: but000,
        ekun,
        but020,
        but021_fs,
        but100,
        but0cc,
        adrc,
        but0bk,
        tiban,                     "Nuss 31.08.2015
        dfkkbptaxnum,
        adrct,
        adr2,
        adr3,
*        adr4,
*        adr5,
*        adr6,
*        adr12,
        but0is.


TABLES: ehauisu,
        iloa,
        iflotx,
        iflot.
*        adcp.

TABLES: enote,
        enotet.

TABLES: evbs.

TABLES: egpltx.

TABLES:
  v_equi,
*        equi,
  egers,
  egerh,
  ausp,
  kssk,
  klah.

TABLES: fkkvk,
        fkkvkp,
        fkkvk_corr,
        dfkklocks,
        dfkktaxex.

TABLES: stxh.

TABLES: v_eanl,
        eanl,
        eanlh.
*        ettifn,
*        te221.

TABLES: euiinstln,
        euitrans,
        euihead,
        euigrid.

TABLES: /adesso/mte_rel,
        /adesso/mte_rels.

TABLES: ettifb.

TABLES: ever.

TABLES: "eabp,
*        ejvl,
  dfkkop.
*        dfkkopw.

TABLES: "erch,
  dfkkko,
  dfkkopk.

*TABLES: bcont.

*TABLES: fkk_instpln_head,
*        fkk_instpln_hist.


TABLES: eabl,
*        eablg,
        eastl,
        easts,
*        easte,
        eadz,
        etdz.

TABLES: eservice.

TABLES: "elpass,
  eufass.

*TABLES: elweg.

*TABLES: tespt.

*TABLES: fkkmaze,
*        ediscdoc.

TABLES: "ediscobj,
*        ediscobjh,
  ediscact,
  ediscpos.

TABLES: edevgr.

TABLES:  egerr.

TABLES: /adesso/mte_dtab.

DATA: flag_maze(1) TYPE c.
DATA: ifkkmaze LIKE fkkmaze OCCURS 0 WITH HEADER LINE.
*
DATA: flag_egerh(1) TYPE c.
DATA: iegerh LIKE egerh OCCURS 0 WITH HEADER LINE.


*------------------------------------------------
* Datendeklaration für Entlade-FUBA Partner
DATA: oldkey_par LIKE but000-partner.

DATA: ipar_out LIKE TABLE OF /adesso/mt_transfer,
      wpar_out LIKE /adesso/mt_transfer.

* interne Tabellen für Partner
DATA: ipar_init TYPE /adesso/mt_emg_ekun_init OCCURS 0 WITH HEADER LINE.
DATA: ipar_ekun   TYPE /adesso/mt_ekun_di OCCURS 0 WITH HEADER LINE.
DATA: ipar_but000 TYPE /adesso/mt_bus000_di OCCURS 0 WITH HEADER LINE.
DATA: ipar_but001 TYPE /adesso/mt_bus001_di OCCURS 0 WITH HEADER LINE.
DATA: ipar_bus000icomm TYPE /adesso/mt_bus000icomm OCCURS 0 WITH HEADER LINE.
DATA: ipar_but0bk TYPE /adesso/mt_bus0bk_di OCCURS 0 WITH HEADER LINE.
DATA: ipar_but020 TYPE /adesso/mt_bus020_di OCCURS 0 WITH HEADER LINE.
DATA: ipar_but021 TYPE /adesso/mt_bus021_di OCCURS 0 WITH HEADER LINE.
DATA: ipar_but0cc TYPE /adesso/mt_bus0cc_di OCCURS 0 WITH HEADER LINE.
DATA: ipar_shipto TYPE /adesso/mt_eshipto_di OCCURS 0 WITH HEADER LINE.
DATA: ipar_taxnum TYPE /adesso/mt_emg_fkkbptax_di
                                           OCCURS 0 WITH HEADER LINE.
DATA: ipar_eccard TYPE /adesso/mt_econcard_di OCCURS 0 WITH HEADER LINE.
DATA: ipar_eccrdh TYPE /adesso/mt_econcardh_di OCCURS 0 WITH HEADER LINE.

DATA: ipar_but0is TYPE /adesso/mt_bus0is_di  OCCURS 0 WITH HEADER LINE.

DATA: "date_to TYPE char15,
      "date_from TYPE char15,
      h_lines  TYPE i.



DATA: iadr2  TYPE adr2  OCCURS 0 WITH HEADER LINE.
DATA: iadr3  TYPE adr3  OCCURS 0 WITH HEADER LINE.
DATA: iadr4  TYPE adr4  OCCURS 0 WITH HEADER LINE.
DATA: iadr5  TYPE adr5  OCCURS 0 WITH HEADER LINE.
DATA: iadr6  TYPE adr6  OCCURS 0 WITH HEADER LINE.
DATA: iadr12 TYPE adr12 OCCURS 0 WITH HEADER LINE.
DATA: iadr13 TYPE adr13 OCCURS 0 WITH HEADER LINE.
DATA: ibut020 TYPE but020 OCCURS 0 WITH HEADER LINE.


*----------------------------------------------------------------------
* Datendeklaration für Entlade-FUBA CONNOBJ
DATA: oldkey_con LIKE ehauisu-haus.

DATA: icon_out LIKE TABLE OF /adesso/mt_transfer,
      wcon_out LIKE /adesso/mt_transfer.

* interne Tabellen für CONNOBJ
DATA: icon_co_eha TYPE /adesso/mt_ehaud OCCURS 0 WITH HEADER LINE.
DATA: icon_co_adr TYPE /adesso/mt_addr1_data OCCURS 0 WITH HEADER LINE.
DATA: icon_co_com TYPE /adesso/mt_isu02_comm_auto
                                       OCCURS 0 WITH HEADER LINE.

*----------------------------------------------------------------------
* Datendeklaration für Entlade-FUBA NOTE_CON
DATA: oldkey_noc LIKE ehauisu-haus.

DATA: inoc_out LIKE TABLE OF /adesso/mt_transfer,
      wnoc_out LIKE /adesso/mt_transfer.

* interne Tabellen für NOTE_CON
DATA: inoc_key   TYPE /adesso/mt_eenfi_note_key_di
                                           OCCURS 0 WITH HEADER LINE.
DATA: inoc_notes TYPE /adesso/mt_eenfi_singl_note_di
                                           OCCURS 0 WITH HEADER LINE.
DATA: inoc_text  TYPE /adesso/mt_eenfi_note_text_di
                                           OCCURS 0 WITH HEADER LINE.


*----------------------------------------------------------------------
* Datendeklaration für Entlade-FUBA PREMISE
DATA: oldkey_pre LIKE evbs-vstelle.

DATA: ipre_out LIKE TABLE OF /adesso/mt_transfer,
      wpre_out LIKE /adesso/mt_transfer.

* interne Tabellen für PREMISE
DATA: ipre_evbsd TYPE /adesso/mt_evbsd OCCURS 0 WITH HEADER LINE.


*----------------------------------------------------------------------
* Datendeklaration für Entlade-FUBA DEVLOC
DATA: oldkey_dlc LIKE  egpl-devloc.

DATA: idlc_out LIKE TABLE OF /adesso/mt_transfer,
      wdlc_out LIKE /adesso/mt_transfer.

* interne Tabellen für DEVLOC
DATA: idlc_egpld TYPE /adesso/mt_egpld OCCURS 0 WITH HEADER LINE.


*----------------------------------------------------------------------
* Datendeklaration für Entlade-FUBA NOTE_DLC
DATA: oldkey_nod LIKE egpl-devloc.

DATA: inod_out LIKE TABLE OF /adesso/mt_transfer,
      wnod_out LIKE /adesso/mt_transfer.

* interne Tabellen für NOTE_DLC
DATA: inod_key   TYPE /adesso/mt_eenfi_note_key_di
                                        OCCURS 0 WITH HEADER LINE.
DATA: inod_notes TYPE /adesso/mt_eenfi_singl_note_di
                                        OCCURS 0 WITH HEADER LINE.
DATA: inod_text  TYPE /adesso/mt_eenfi_note_text_di
                                        OCCURS 0 WITH HEADER LINE.


*----------------------------------------------------------------------
* Datendeklaration für Entlade-FUBA DEVICE
DATA: oldkey_dev LIKE equi-equnr.

DATA: idev_out LIKE TABLE OF /adesso/mt_transfer,
      wdev_out LIKE /adesso/mt_transfer.

* interne Tabellen für DEVICE
DATA: idev_equi   TYPE /adesso/mt_v_equi OCCURS 0 WITH HEADER LINE.
DATA: idev_egers  TYPE /adesso/mt_egers OCCURS 0 WITH HEADER LINE.
DATA: idev_egerh  TYPE /adesso/mt_egerh OCCURS 0 WITH HEADER LINE.
DATA: idev_clhead TYPE /adesso/mt_emg_clshead OCCURS 0 WITH HEADER LINE.
DATA: idev_cldata TYPE /adesso/mt_api_ausp OCCURS 0 WITH HEADER LINE.

* Felder für Merkmalswerte
DATA: leistung   TYPE p LENGTH 5 DECIMALS 2,
      nennweite1 TYPE p LENGTH 3 DECIMALS 0.
*
*----------------------------------------------------------------------
* Datendeklaration für Entlade-FUBA ACCOUNT
DATA: oldkey_acc LIKE fkkvk-vkont.

DATA: iacc_out LIKE TABLE OF /adesso/mt_transfer,
      wacc_out LIKE /adesso/mt_transfer.

* interne Tabellen für ACCOUNT
DATA: iacc_init   TYPE /adesso/mt_fkkvk_hdr_di
                          OCCURS 0 WITH HEADER LINE.
DATA: iacc_vk     TYPE /adesso/mt_fkkvk_s_di
                          OCCURS 0 WITH HEADER LINE.
DATA: iacc_vkp    TYPE /adesso/mt_fkkvkp_s_di
                          OCCURS 0 WITH HEADER LINE.
DATA: iacc_vklock TYPE /adesso/mt_fkkvklock_s_di
                          OCCURS 0 WITH HEADER LINE.
DATA: iacc_vkcorr TYPE /adesso/mt_fkkvk_corr_s_di
                          OCCURS 0 WITH HEADER LINE.
DATA: iacc_vktxex TYPE /adesso/mt_fkkvk_taxex_s_di
                          OCCURS 0 WITH HEADER LINE.


*----------------------------------------------------------------------
* Datendeklaration für Entlade-FUBA ACC_NOTE
DATA: oldkey_acn LIKE fkkvk-vkont.

DATA: iacn_out LIKE TABLE OF /adesso/mt_transfer,
      wacn_out LIKE /adesso/mt_transfer.

* interne Tabellen für ACC_NOTE
DATA: iacn_notkey TYPE /adesso/mt_emg_notice_key
                          OCCURS 0 WITH HEADER LINE.
DATA: iacn_notlin TYPE /adesso/mt_emg_tline
                          OCCURS 0 WITH HEADER LINE.



*----------------------------------------------------------------------
* Datendeklaration für Entlade-FUBA INSTLN
DATA: oldkey_ins LIKE eanl-anlage.

DATA: ins_out  LIKE TABLE OF /adesso/mt_transfer,
      wins_out LIKE /adesso/mt_transfer.

* interne Tabellen für INSTLN
DATA: ins_key   TYPE /adesso/mt_eanlhkey OCCURS 0 WITH HEADER LINE.
DATA: ins_data  TYPE /adesso/mt_emg_eanl OCCURS 0 WITH HEADER LINE.
DATA: ins_rcat  TYPE /adesso/mt_isu_aittyp OCCURS 0 WITH HEADER LINE.
DATA: ins_pod   TYPE /adesso/mt_eui_ext_obj_auto
                                         OCCURS 0 WITH HEADER LINE.

* interne Tabellen mit Operand und Value zusammen (Fakten)
DATA: ins_facts    TYPE /adesso/mt_facts  OCCURS 0 WITH HEADER LINE.



*----------------------------------------------------------------------
* Datendeklaration für Entlade-FUBA FACTS
DATA: oldkey_fac LIKE eanl-anlage.

DATA: ifac_out LIKE TABLE OF /adesso/mt_transfer,
      wfac_out LIKE /adesso/mt_transfer.

* interne Tabellen für FACTS
DATA: ifac_key  TYPE /adesso/mt_eanlhkey OCCURS 0 WITH HEADER LINE.

* interne Tabellen mit Operand und Value zusammen
DATA: ifac_facts    TYPE /adesso/mt_facts  OCCURS 0 WITH HEADER LINE.


*----------------------------------------------------------------------
* Datendeklaration für Entlade-FUBA INSTLNCHA
DATA: oldkey_ich LIKE eanl-anlage.

DATA: ich_out  LIKE TABLE OF /adesso/mt_transfer,
      wich_out LIKE /adesso/mt_transfer.

* interne Tabellen für INSTLNCHA
DATA: ich_key    TYPE /adesso/mt_eanlhkey    OCCURS 0 WITH HEADER LINE.
DATA: ich_data   TYPE /adesso/mt_emg_eanl    OCCURS 0 WITH HEADER LINE.
DATA: ich_rcat   TYPE /adesso/mt_isu_aittyp  OCCURS 0 WITH HEADER LINE.
* interne Tabellen mit Operand und Value zusammen
DATA: ich_facts    TYPE /adesso/mt_facts  OCCURS 0 WITH HEADER LINE.

*----------------------------------------------------------------------
* Datendeklaration für Entlade-FUBA REFVALUES
DATA: oldkey_rva LIKE eanl-anlage.

DATA: irva_out LIKE TABLE OF /adesso/mt_transfer,
      wrva_out LIKE /adesso/mt_transfer.

* interne Tabellen für REFVALUES
DATA: irva_ettifb LIKE /adesso/mt_ettifb OCCURS 0 WITH HEADER LINE.


*----------------------------------------------------------------------
* Datendeklaration für  Entlade-FUBA MOVE_IN
DATA: oldkey_moi LIKE ever-vertrag.

DATA: imoi_out LIKE TABLE OF /adesso/mt_transfer,
      wmoi_out LIKE /adesso/mt_transfer.

* interne Tabellen für MOVE_IN
DATA: imoi_ever TYPE /adesso/mt_everd OCCURS 0 WITH HEADER LINE.

*----------------------------------------------------------------------
* Datendeklaration für  Entlade-FUBA MOVE_IN_H
DATA: oldkey_moh LIKE ever-vertrag.

DATA: imoh_out LIKE TABLE OF /adesso/mt_transfer,
      wmoh_out LIKE /adesso/mt_transfer.

* interne Tabellen für MOVE_IN_H
DATA: imoh_ever TYPE /adesso/mt_everd OCCURS 0 WITH HEADER LINE.

*------------------------------------------------------------------------
** Satendeklaration für Entlade-FUBA MOVE_OUT
TABLES: eaus, eausv.
DATA: oldkey_moo LIKE eausv-vertrag.

DATA: imoo_out LIKE TABLE OF /adesso/mt_transfer,
      wmoo_out LIKE /adesso/mt_transfer.

** interne Tabellen für MOVE_OUT
DATA: imoo_eaus TYPE /adesso/mt_eausd OCCURS 0 WITH HEADER LINE.
DATA: imoo_eausv TYPE /adesso/mt_eausvd OCCURS 0 WITH HEADER LINE.

** Für INVOICE (Netznutzungsabrechnungen -- kein MIG-Objekt
** wird aber so behandelt, als ob es eins wäre
TABLES: tinv_inv_head, tinv_inv_doc, tinv_inv_line_b.
DATA: oldkey_inv LIKE tinv_inv_head-int_inv_no.

DATA: iinv_out LIKE TABLE OF /adesso/mt_transfer,
      winv_out LIKE /adesso/mt_transfer.

DATA: iinv_head TYPE bapi_inv_head OCCURS 0 WITH HEADER LINE.
DATA: iinv_doc  TYPE bapi_inv_doc  OCCURS 0 WITH HEADER LINE.
DATA: iinv_docdb TYPE /adesso/mt_tinv_inv_doc OCCURS 0 WITH HEADER LINE.
DATA: iinv_lineb TYPE /adesso/mt_bapi_inv_line OCCURS 0 WITH HEADER LINE.
DATA: iinv_append  TYPE bapiparex OCCURS 0 WITH HEADER LINE. "wa_EXTENSIONIN    type BAPIPAREX,


*----------------------------------------------------------------------
* Datendeklaration für Entlade-FUBA BBP_MULT
DATA: oldkey_bpm LIKE eabp-opbel.

DATA: ibpm_out LIKE TABLE OF /adesso/mt_transfer,
      wbpm_out LIKE /adesso/mt_transfer.

* interne Tabellen für BBP_MULT
DATA: ibpm_eabp  TYPE /adesso/mt_eabp OCCURS 0 WITH HEADER LINE.
DATA: ibpm_eabpv TYPE /adesso/mt_emigr_ever OCCURS 0 WITH HEADER LINE.
DATA: ibpm_eabps TYPE /adesso/mt_sfkkop OCCURS 0 WITH HEADER LINE.
DATA: ibpm_ejvl  TYPE /adesso/mt_ejvl OCCURS 0 WITH HEADER LINE.


*----------------------------------------------------------------------
* Datendeklaration für Entlade-FUBA PAYMENT
DATA: oldkey_pay LIKE eabp-opbel.

DATA: ipay_out LIKE TABLE OF /adesso/mt_transfer,
      wpay_out LIKE /adesso/mt_transfer.

* interne Tabellen für PAYMENT
DATA: ipay_fkkko  TYPE /adesso/mt_emig_pay_fkkko
                                        OCCURS 0 WITH HEADER LINE.
DATA: ipay_fkkopk TYPE /adesso/mt_fkkopk OCCURS 0 WITH HEADER LINE.
DATA: ipay_seltns TYPE /adesso/mt_emig_pay_seltns
                                        OCCURS 0 WITH HEADER LINE.


*----------------------------------------------------------------------
* Datendeklaration für Entlade-FUBA DOCUMENT
DATA: oldkey_doc LIKE fkkvk-vkont.

DATA: idoc_out LIKE TABLE OF /adesso/mt_transfer,
      wdoc_out LIKE /adesso/mt_transfer.

* interne Tabellen für DOCUMENT
DATA: idoc_ko     TYPE /adesso/mt_fkkko  OCCURS 0 WITH HEADER LINE.
DATA: idoc_op     TYPE /adesso/mt_fkkop  OCCURS 0 WITH HEADER LINE.
DATA: idoc_opk    TYPE /adesso/mt_fkkopk OCCURS 0 WITH HEADER LINE.
DATA: idoc_opl    TYPE /adesso/mt_fkkopl OCCURS 0 WITH HEADER LINE.
DATA: idoc_addinf TYPE /adesso/mt_emig_doc_addinfo
                                        OCCURS 0 WITH HEADER LINE.

*----------------------------------------------------------------------
* Datendeklaration für Entlade-FUBA BCONTACT
DATA: oldkey_bct LIKE bcont-bpcontact.

DATA: ibct_out LIKE TABLE OF /adesso/mt_transfer,
      wbct_out LIKE /adesso/mt_transfer.

* interne Tabellen für BCONTACT
DATA: ibct_bcontd TYPE /adesso/mt_bcontd OCCURS 0 WITH HEADER LINE.
DATA: ibct_pbcobj TYPE /adesso/mt_bpc_obj OCCURS 0 WITH HEADER LINE.


*----------------------------------------------------------------------
* Datendeklaration für Entlade-FUBA BCONT_NOTE
DATA: oldkey_bcn LIKE bcont-bpcontact.

DATA: ibcn_out LIKE TABLE OF /adesso/mt_transfer,
      wbcn_out LIKE /adesso/mt_transfer.

* interne Tabellen für BCONT_NOTE
DATA: ibcn_notkey TYPE /adesso/mt_emg_notice_key
                                           OCCURS 0 WITH HEADER LINE.
DATA: ibcn_notlin TYPE /adesso/mt_emg_tline OCCURS 0 WITH HEADER LINE.


*----------------------------------------------------------------------
* Datendeklaration für Entlade-FUBA INSTPLAN
DATA: oldkey_ipl LIKE fkkvk-vkont.

DATA: ipl_out  LIKE TABLE OF /adesso/mt_transfer,
      wipl_out LIKE /adesso/mt_transfer.

* interne Tabellen für INSTPLAN
DATA: ipl_ipkey  TYPE /adesso/mt_emg_instplan OCCURS 0 WITH HEADER LINE.
DATA: ipl_ipdata TYPE /adesso/mt_fkkintpln    OCCURS 0 WITH HEADER LINE.
DATA: ipl_ipopky TYPE /adesso/mt_fkkopkey     OCCURS 0 WITH HEADER LINE.


*----------------------------------------------------------------------
* Datendeklaration für Entlade-FUBA PARTN_NOTE
DATA: oldkey_pno LIKE /adesso/mt_transfer-oldkey.

DATA: ipno_out LIKE TABLE OF /adesso/mt_transfer,
      wpno_out LIKE /adesso/mt_transfer.

* interne Tabellen für PARTN_NOTE
DATA: ipno_notkey TYPE /adesso/mt_emg_notice_key
                                      OCCURS 0 WITH HEADER LINE.
DATA: ipno_notlin TYPE /adesso/mt_emg_tline
                                      OCCURS 0 WITH HEADER LINE.


*----------------------------------------------------------------------
* Datendeklaration für Entlade-FUBA INST_MGMT
DATA: oldkey_inm LIKE /adesso/mt_transfer-oldkey.

DATA: inm_out  LIKE TABLE OF /adesso/mt_transfer,
      winm_out LIKE /adesso/mt_transfer.

* interne Tabellen für INST_MGMT
DATA: inm_di_int TYPE /adesso/mt_emg_wol OCCURS 0 WITH HEADER LINE.
DATA: inm_di_zw  TYPE /adesso/mt_reg30_zw_c OCCURS 0 WITH HEADER LINE.
DATA: inm_di_ger TYPE /adesso/mt_reg30_gera OCCURS 0 WITH HEADER LINE.
DATA: inm_di_cnt TYPE /adesso/mt_emg_install_containe
                                           OCCURS 0 WITH HEADER LINE.


*----------------------------------------------------------------------
* Datendeklaration für Entlade-FUBA METERREAD
DATA: oldkey_mrd LIKE /adesso/mt_transfer-oldkey.

DATA: imrd_out LIKE TABLE OF /adesso/mt_transfer,
      wmrd_out LIKE /adesso/mt_transfer.

* interne Tabellen für METERREAD
DATA: imrd_ieablu TYPE /adesso/mt_eablu OCCURS 0 WITH HEADER LINE.


*----------------------------------------------------------------------
* Datendeklaration für Entlade-FUBA CON_NOTE
DATA: oldkey_cno LIKE evbs-haus.

DATA: icno_out LIKE TABLE OF /adesso/mt_transfer,
      wcno_out LIKE /adesso/mt_transfer.

* interne Tabellen für BCONT_NOTE
DATA: icno_notkey TYPE /adesso/mt_emg_notice_key
                                           OCCURS 0 WITH HEADER LINE.
DATA: icno_notlin TYPE /adesso/mt_emg_tline OCCURS 0 WITH HEADER LINE.


*----------------------------------------------------------------------
* Datendeklaration für Entlade-FUBA DEVICERATE
DATA: oldkey_drt LIKE /adesso/mt_transfer-oldkey.

DATA: idrt_out LIKE TABLE OF /adesso/mt_transfer,
      wdrt_out LIKE /adesso/mt_transfer.

* interne Tabellen für DEVICERATE
DATA: idrt_drint TYPE /adesso/mt_emg_devrate_int
                                        OCCURS 0 WITH HEADER LINE.
DATA: idrt_drdev TYPE /adesso/mt_reg70_d OCCURS 0 WITH HEADER LINE.
DATA: idrt_drreg TYPE /adesso/mt_reg70_r OCCURS 0 WITH HEADER LINE.

*Hilfstabellen
DATA: idrt_drint_h TYPE /adesso/mt_emg_devrate_int
                                          OCCURS 0 WITH HEADER LINE.
DATA: idrt_drdev_h TYPE /adesso/mt_reg70_d OCCURS 0 WITH HEADER LINE.
DATA: idrt_drreg_h TYPE /adesso/mt_reg70_r OCCURS 0 WITH HEADER LINE.

*----------------------------------------------------------------------
* Datendeklaration für Entlade-FUBA PODSERVICE
DATA: oldkey_pos LIKE eanl-anlage.

DATA: ipos_out LIKE TABLE OF /adesso/mt_transfer,
      wpos_out LIKE /adesso/mt_transfer.

* interne Tabellen für PODSERVICE
DATA: ipos_podsrv TYPE /adesso/mt_eserviced OCCURS 0 WITH HEADER LINE.
DATA: ipos_podsrv_h TYPE /adesso/mt_eserviced OCCURS 0 WITH HEADER LINE.


*----------------------------------------------------------------------
* Datendeklaration für Entlade-FUBA LOADPROF
DATA: oldkey_lop LIKE eanl-anlage.

DATA: ilop_out LIKE TABLE OF /adesso/mt_transfer,
      wlop_out LIKE /adesso/mt_transfer.

* interne Tabellen für LOADPROF
DATA: ilop_key TYPE /adesso/mt_elpass_key OCCURS 0 WITH HEADER LINE.
DATA: ilop_elpass   TYPE /adesso/mt_elpass_auto
                                          OCCURS 0 WITH HEADER LINE.

**----------------------------------------------------------------------
** Datendeklaration für Entlade-FUBA REGRELSHIP
*DATA: oldkey_rrl LIKE /eadesso/mt_transfer-oldkey.
*
*DATA: irrl_out   LIKE TABLE OF /adesso/mt_transfer,
*      wrrl_out   LIKE /adesso/mt_transfer.
*
** interne Tabellen für REGRELSHIP
*DATA: irrl_regrel TYPE /adesso/mt_reg75_zw OCCURS 0 WITH HEADER LINE.
*DATA: irrl_regrlh TYPE /adesso/mt_reg75_h  OCCURS 0 WITH HEADER LINE.
*
*----------------------------------------------------------------------
* Datendeklaration für Entlade-FUBA STRT_ROUTE
DATA: oldkey_srt LIKE eanlh-ableinh.

DATA: isrt_out LIKE TABLE OF /adesso/mt_transfer,
      wsrt_out LIKE /adesso/mt_transfer.

* interne Tabellen für STRT_ROUTE
DATA: isrt_mru   TYPE emg_sr_ableinh OCCURS 0 WITH HEADER LINE.
DATA: isrt_equnr TYPE emg_sr_equnr OCCURS 0 WITH HEADER LINE.

*----------------------------------------------------------------------

* Datendeklaration für Entlade-FUBA DISC_DOC
DATA: oldkey_dcd LIKE ediscdoc-discno.

DATA: idcd_out LIKE TABLE OF /adesso/mt_transfer,
      wdcd_out LIKE /adesso/mt_transfer.

* interne Tabellen für DISC_DOC
DATA: idcd_header TYPE /adesso/mt_emg_ddc_header
                                       OCCURS 0 WITH HEADER LINE.
DATA: idcd_fkkmaz TYPE /adesso/mt_emg_ddc_docu_sel
                                       OCCURS 0 WITH HEADER LINE.


*----------------------------------------------------------------------

* Datendeklaration für Entlade-FUBA DISC_ORDER
DATA: oldkey_dco LIKE ediscdoc-discno.

DATA: idco_out LIKE TABLE OF /adesso/mt_transfer,
      wdco_out LIKE /adesso/mt_transfer.

* interne Tabellen für DISC_ORDER
DATA: idco_header TYPE /adesso/mt_emg_ddc_header
                                       OCCURS 0 WITH HEADER LINE.

*----------------------------------------------------------------------

* Datendeklaration für Entlade-FUBA DISC_ENTER
DATA: oldkey_dce LIKE ediscdoc-discno.

DATA: idce_out LIKE TABLE OF /adesso/mt_transfer,
      wdce_out LIKE /adesso/mt_transfer.

* interne Tabellen für DISC_ENTER
DATA: idce_header TYPE /adesso/mt_emg_ddc_header
                                       OCCURS 0 WITH HEADER LINE.
DATA: idce_anlage TYPE /adesso/mt_emg_ddc_anlage_sel
                                       OCCURS 0 WITH HEADER LINE.
DATA: idce_device TYPE /adesso/mt_emg_ddc_device_sel
                                       OCCURS 0 WITH HEADER LINE.
DATA: iediscobj TYPE ediscobj OCCURS 0 WITH HEADER LINE.

*----------------------------------------------------------------------
* Datendeklaration für Entlade-FUBA DISC_RCENT
DATA: oldkey_dcm LIKE ediscdoc-discno.

DATA: idcm_out LIKE TABLE OF /adesso/mt_transfer,
      wdcm_out LIKE /adesso/mt_transfer.

* interne Tabellen für DISC_ENTER
DATA: idcm_header TYPE /adesso/mt_emg_ddc_header
                                       OCCURS 0 WITH HEADER LINE.
DATA: idcm_anlage TYPE /adesso/mt_emg_ddc_anlage_sel
                                       OCCURS 0 WITH HEADER LINE.
DATA: idcm_device TYPE /adesso/mt_emg_ddc_device_sel
                                       OCCURS 0 WITH HEADER LINE.
*
*----------------------------------------------------------------------

* Datendeklaration für Entlade-FUBA DISC_RCORD
DATA: oldkey_dcr LIKE ediscdoc-discno.

DATA: idcr_out LIKE TABLE OF /adesso/mt_transfer,
      wdcr_out LIKE /adesso/mt_transfer.

* interne Tabellen für DISC_RCORD
DATA: idcr_header TYPE /adesso/mt_emg_ddc_header
                                       OCCURS 0 WITH HEADER LINE.

*----------------------------------------------------------------------

* Datendeklaration für Entlade-FUBA DLC_NOTE
DATA: oldkey_dno LIKE egpl-devloc.

DATA: idno_out LIKE TABLE OF /adesso/mt_transfer,
      wdno_out LIKE /adesso/mt_transfer.

* interne Tabellen für BCONT_NOTE
DATA: idno_notkey TYPE /adesso/mt_emg_notice_key
                                           OCCURS 0 WITH HEADER LINE.
DATA: idno_notlin TYPE /adesso/mt_emg_tline OCCURS 0 WITH HEADER LINE.

*----------------------------------------------------------------------
* Datendeklaration für Entlade-FUBA DEVGRP
DATA: oldkey_dgr LIKE edevgr-devgrp.

DATA: idgr_out LIKE TABLE OF /adesso/mt_transfer,
      wdgr_out LIKE /adesso/mt_transfer.

* interne Tabellen für DEVGRP
DATA: idgr_edevgr TYPE /adesso/mt_emg_edevgr OCCURS 0 WITH HEADER LINE.
DATA: idgr_device TYPE /adesso/mt_v_eger OCCURS 0 WITH HEADER LINE.

*----------------------------------------------------------------------------
* Datendeklaration für Entlade-FuBa DUNNING
DATA: oldkey_dun LIKE fkkmako-gpart.

DATA: idun_out LIKE TABLE OF /adesso/mt_transfer,
      wdun_out LIKE /adesso/mt_transfer.

DATA: idun_key TYPE /adesso/mt_emg_dunning OCCURS 0 WITH HEADER LINE.
DATA: idun_fkkma TYPE /adesso/mt_fkkmavs OCCURS 0 WITH HEADER LINE.


*DATA: gc_commicount TYPE i,
*gc_datcount(2) TYPE n VALUE '01',
*gc_l_file TYPE emg_pfad,
*gc_file(10) TYPE c.

* interne Tabelle für die zu migrierenden Verträge
DATA: BEGIN OF ivt OCCURS 0,
        vertrag LIKE ever-vertrag,
      END OF ivt.
DATA: ivtfilled.
DATA: ipodsv LIKE TABLE OF /adesso/mte_zpsv WITH HEADER LINE.
DATA: ipodsvfilled.
DATA: ipodsr LIKE TABLE OF /adesso/mte_zpsr WITH HEADER LINE.
DATA: ipodsrfilled.
DATA: ipodsi LIKE TABLE OF /adesso/mte_zpsi WITH HEADER LINE.
DATA: ipodsifilled.

*----------------------------------------------------------------------
* Datendeklaration für Entlade-FUBA ADRSTRISUS
DATA: oldkey_rag LIKE adrstreet-strt_code.

DATA: irag_out LIKE TABLE OF /adesso/mt_transfer,
      wrag_out LIKE /adesso/mt_transfer.

* interne Tabellen für ADRSTRISUS
DATA: iadr_co_st TYPE /adesso/mt_adrstreet OCCURS 0 WITH HEADER LINE.
DATA: iadr_co_isu TYPE /adesso/mt_adr_isu OCCURS 0 WITH HEADER LINE.
DATA: iadr_co_mru TYPE /adesso/mt_adr_mru OCCURS 0 WITH HEADER LINE.
DATA: iadr_co_con TYPE /adesso/mt_adr_con OCCURS 0 WITH HEADER LINE.
DATA: iadr_co_ccs TYPE /adesso/mt_adr_ccs OCCURS 0 WITH HEADER LINE.


*-----------------------------------------------------------------------
* Datendeklaration für Entlade-FUBA  DEVINFOREC
DATA: oldkey_dir LIKE egerr-equnr.

DATA: idir_out LIKE TABLE OF /adesso/mt_transfer,
      wdir_out LIKE /adesso/mt_transfer.

* interne Tabellen für Geräteinfosatz
DATA: idir_int      TYPE /adesso/mt_emg_devmod_int OCCURS 0 WITH HEADER LINE.
DATA: idir_dev      TYPE /adesso/mt_reg42_dev OCCURS 0 WITH HEADER LINE.
DATA: idir_dev_flag TYPE /adesso/mt_reg42_dev_input_flg OCCURS 0 WITH HEADER LINE.
DATA: idir_reg      TYPE /adesso/mt_reg42_zw  OCCURS 0 WITH HEADER LINE.
DATA: idir_reg_flag TYPE /adesso/mt_reg42_zw_input_flag OCCURS 0 WITH HEADER LINE.

DATA:  iegerr TYPE egerr OCCURS 0 WITH HEADER LINE.     "Nuss 08.09.2015


*-----------------------------------------------------------------------
* Datendeklaration für Entlade-FUBA  DEVICEREL
DATA: oldkey_dvr LIKE /adesso/mt_devicerel.

DATA: idvr_out LIKE TABLE OF /adesso/mt_transfer,
      wdvr_out LIKE /adesso/mt_transfer.

* interne Tabellen für Gerätezuordnungen
DATA: idvr_int      TYPE /adesso/mt_emg_devrel_int OCCURS 0 WITH HEADER LINE.
DATA: idvr_reg      TYPE /adesso/mt_reg72_r OCCURS 0 WITH HEADER LINE.
DATA: idvr_dev      TYPE /adesso/mt_reg72_d OCCURS 0 WITH HEADER LINE.

*----------------------------------------------------------------------
* Datendeklaration für Entlade-FUBA INSTLN_NN
DATA: oldkey_inn LIKE eanl-anlage.

DATA: inn_out  LIKE TABLE OF /adesso/mt_transfer,
      winn_out LIKE /adesso/mt_transfer.

* interne Tabellen für INSTLN
DATA: inn_key   TYPE /adesso/mt_eanlhkey OCCURS 0 WITH HEADER LINE.
DATA: inn_data  TYPE /adesso/mt_emg_eanl OCCURS 0 WITH HEADER LINE.
DATA: inn_rcat  TYPE /adesso/mt_isu_aittyp OCCURS 0 WITH HEADER LINE.
DATA: inn_pod   TYPE /adesso/mt_eui_ext_obj_auto
                                         OCCURS 0 WITH HEADER LINE.

*----------------------------------------------------------------------
* Datendeklaration für Entlade-FUBA INSTLNCHNN
DATA: oldkey_icn LIKE eanl-anlage. " /evuit/mt_transfer-oldkey.

DATA: icn_out  LIKE TABLE OF /adesso/mt_transfer,
      wicn_out LIKE /adesso/mt_transfer.
*
* interne Tabellen für INSTLNCHA
DATA: icn_key    TYPE /adesso/mt_eanlhkey    OCCURS 0 WITH HEADER LINE.
DATA: icn_data   TYPE /adesso/mt_emg_eanl    OCCURS 0 WITH HEADER LINE.
DATA: icn_rcat   TYPE /adesso/mt_isu_aittyp  OCCURS 0 WITH HEADER LINE.
DATA: icn_pod TYPE /adesso/mt_eui_ext_obj_auto OCCURS 0 WITH HEADER LINE.
