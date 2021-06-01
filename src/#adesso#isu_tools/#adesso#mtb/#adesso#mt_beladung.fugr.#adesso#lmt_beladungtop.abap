FUNCTION-POOL /adesso/mt_beladung.          "MESSAGE-ID ..


TABLES: temfd,
        tspat,
        teminfo,
        temfirma,
        temob,
        temdb,
        temre,
        temru,
        temrc,
        temcnv.

TABLES: dd03l,
        dd01l.


* allgemeine Felder




* Datendeklaration zu /ADESSO/MTB_REP_GENERATE
DATA  irep       TYPE edpline OCCURS 0 WITH HEADER LINE.
DATA  itemdb     LIKE temdb OCCURS 0 WITH HEADER LINE.
DATA  itemre     LIKE temre OCCURS 0 WITH HEADER LINE.
DATA  itemru     LIKE temru OCCURS 0 WITH HEADER LINE.
DATA  repname    TYPE programm.
DATA  formname   TYPE text30.
DATA  struktur   TYPE text20.
DATA  struktur2  TYPE text20.
DATA: struk_feld TYPE text40.
DATA: struk_feld2 TYPE text40.
DATA  dat_typ    TYPE text20.
DATA  x_struktur TYPE text20.
DATA  y_struktur TYPE text20.
DATA  line       TYPE n.
DATA: word       TYPE text40.

DATA: out_len    LIKE dd01l-outputlen.

*------------------------------------------------
* Datendeklaration für Belade-FUBA Partner
DATA: oldkey_partner LIKE /adesso/mt_transfer-oldkey.

DATA  i_par_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Tabellen für Partner (Weiterverarbeitung)
DATA: BEGIN OF i_init OCCURS 0.
        INCLUDE STRUCTURE emg_ekun_init.
DATA  END OF i_init.

DATA: BEGIN OF i_ekun OCCURS 0.
        INCLUDE STRUCTURE ekun_di.
DATA  END OF i_ekun.

DATA: BEGIN OF i_but000 OCCURS 0.
        INCLUDE STRUCTURE bus000_di.
DATA  END OF i_but000.

DATA: BEGIN OF i_but001 OCCURS 0.
        INCLUDE STRUCTURE bus001_di.
DATA  END OF i_but001.

DATA: BEGIN OF i_but0bk OCCURS 0.
        INCLUDE STRUCTURE bus0bk_di.
DATA  END OF i_but0bk.

DATA: BEGIN OF i_but020 OCCURS 0.
        INCLUDE STRUCTURE bus020_di.
DATA  END OF i_but020.

DATA: BEGIN OF i_but021 OCCURS 0.
        INCLUDE STRUCTURE bus021_di.
DATA  END OF i_but021.

DATA: BEGIN OF i_but0cc OCCURS 0.
        INCLUDE STRUCTURE bus0cc_di.
DATA  END OF i_but0cc.

DATA: BEGIN OF i_shipto OCCURS 0.
        INCLUDE STRUCTURE eshipto_di.
DATA  END OF i_shipto.

DATA: BEGIN OF i_taxnum OCCURS 0.
        INCLUDE STRUCTURE emg_fkkbptax_di.
DATA  END OF i_taxnum.

DATA: BEGIN OF i_eccard OCCURS 0.
        INCLUDE STRUCTURE econcard_di.
DATA  END OF i_eccard.

DATA: BEGIN OF i_eccrdh OCCURS 0.
        INCLUDE STRUCTURE econcardh_di.
DATA  END OF i_eccrdh.

DATA: BEGIN OF i_but0is OCCURS 0.
        INCLUDE STRUCTURE bus0is_di.
DATA: END OF i_but0is.

DATA: BEGIN OF i_butcom OCCURS 0.
        INCLUDE STRUCTURE bus000icomm.
DATA: END OF i_butcom.


* interne Strukturen für PARTNER (Übergabe aus Datei)
DATA: x_i_init TYPE /adesso/mt_emg_ekun_init.
DATA: x_i_ekun   TYPE /adesso/mt_ekun_di.
DATA: x_i_but000 TYPE /adesso/mt_bus000_di.
DATA: x_i_but001 TYPE /adesso/mt_bus001_di.
DATA: x_i_but0bk TYPE /adesso/mt_bus0bk_di.
DATA: x_i_but020 TYPE /adesso/mt_bus020_di.
DATA: x_i_but021 TYPE /adesso/mt_bus021_di.
DATA: x_i_but0cc TYPE /adesso/mt_bus0cc_di.
DATA: x_i_shipto TYPE /adesso/mt_eshipto_di.
DATA: x_i_taxnum TYPE /adesso/mt_emg_fkkbptax_di.
DATA: x_i_eccard TYPE /adesso/mt_econcard_di.
DATA: x_i_eccrdh TYPE /adesso/mt_econcardh_di.
DATA: x_i_but0is TYPE /adesso/mt_bus0is_di.
DATA: x_i_butcom TYPE /adesso/mt_bus000icomm.

*----------------------------------------------------------------------
* Datendeklaration für Belade-FUBA CONNOBJ
DATA: oldkey_con LIKE /adesso/mt_transfer-oldkey.
DATA  i_con_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Tabellen für CONNOBJ (Weiterverarbeitung)
DATA: i_co_eha TYPE ehaud OCCURS 0 WITH HEADER LINE.
DATA: i_co_adr TYPE addr1_data OCCURS 0 WITH HEADER LINE.
DATA: i_co_com TYPE isu02_comm_auto OCCURS 0 WITH HEADER LINE.

* interne Strukturen für CONNOBJ (Übergabe aus Datei)
DATA: x_i_co_eha TYPE /adesso/mt_ehaud.
DATA: x_i_co_adr TYPE /adesso/mt_addr1_data.
DATA: x_i_co_com TYPE /adesso/mt_isu02_comm_auto.

*----------------------------------------------------------------------
* Datendeklaration für Belade-FUBA adrstreet
DATA: oldkey_reg LIKE /adesso/mt_transfer-oldkey.
DATA  i_reg_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Tabellen für adrstreet (Weiterverarbeitung)
DATA: i_co_str TYPE adrstreetd OCCURS 0 WITH HEADER LINE. "Änderung 030408
DATA: i_co_pcd TYPE adrstrpcd OCCURS 0 WITH HEADER LINE.  "Änderung 030408

* interne Strukturen für adrstreet (Übergabe aus Datei)
DATA: x_i_co_str TYPE /adesso/mt_adrstreet.
DATA: x_i_co_pcd TYPE /adesso/mt_adrstrpcd.

*----------------------------------------------------------------------
* Datendeklaration für Belade-FUBA adrstrtisu
DATA: oldkey_rag LIKE /adesso/mt_transfer-oldkey.
DATA  i_rag_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Tabellen für v (Weiterverarbeitung)
DATA: i_co_isu TYPE adrstrtisu OCCURS 0 WITH HEADER LINE. "eine Struktur
DATA: i_co_ist TYPE adrstreetd OCCURS 0 WITH HEADER LINE. "eine Struktur
DATA: i_co_mru TYPE adrstrtmru OCCURS 0 WITH HEADER LINE.
DATA: i_co_con TYPE adrstrtkon OCCURS 0 WITH HEADER LINE.
DATA: i_co_css TYPE adrstrtccs OCCURS 0 WITH HEADER LINE.

* interne Strukturen für adrstrtisu (Übergabe aus Datei)
DATA: x_i_co_isu TYPE /adesso/mt_adr_isu.
DATA: x_i_co_ist TYPE /adesso/mt_adrstreet.
DATA: x_i_co_mru TYPE /adesso/mt_adr_mru.
DATA: x_i_co_con TYPE /adesso/mt_adr_con.
DATA: x_i_co_css TYPE /adesso/mt_adr_ccs.

*----------------------------------------------------------------------
* Datendeklaration für Belade-FUBA PREMISE
DATA: oldkey_pre LIKE /adesso/mt_transfer-oldkey.

DATA  i_pre_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Tabellen für PREMISE (Weiterverarbeitung)
*DATA: i_evbsd TYPE evbsd OCCURS 0 WITH HEADER LINE.
DATA: BEGIN OF i_evbsd OCCURS 0.
        INCLUDE STRUCTURE evbsd.
DATA: k_haus TYPE char1.
DATA: END OF i_evbsd.

* interne Strukturen für PREMISE (Übergabe aus Datei)
DATA: x_i_evbsd TYPE /adesso/mt_evbsd.


*----------------------------------------------------------------------
* Datendeklaration für Belade-FUBA DEVLOC
DATA: oldkey_dlc LIKE /adesso/mt_transfer-oldkey.

DATA  i_dlc_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Tabellen für DEVLOC (Weiterverarbeitung)
*DATA: i_egpld TYPE egpld OCCURS 0 WITH HEADER LINE.
DATA: BEGIN OF i_egpld OCCURS 0.
        INCLUDE STRUCTURE egpld.
DATA: k_haus TYPE char1.
DATA: END OF i_egpld.

* interne Struktur für DEVLOC (Übergabe aus Datei)
DATA: x_i_egpld TYPE /adesso/mt_egpld.


*----------------------------------------------------------------------
* Datendeklaration für Belade-FUBA PARTN_NOTE
DATA: oldkey_pno LIKE /adesso/mt_transfer-oldkey.

DATA  i_pno_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Tabellen für PARTN_NOTE (Weiterverarbeitung)
DATA: i_notkey TYPE emg_notice_key OCCURS 0 WITH HEADER LINE.
DATA: i_notlin TYPE emg_tline OCCURS 0 WITH HEADER LINE.

* interne Strukturen für PARTN_NOTE (Übergabe aus Datei)
DATA: x_i_notkey TYPE /adesso/mt_emg_notice_key.
DATA: x_i_notlin TYPE /adesso/mt_emg_tline.

*----------------------------------------------------------------------
* Datendeklaration für Belade-FUBA NOTE_CON
DATA: oldkey_noc LIKE /adesso/mt_transfer-oldkey.

DATA  i_noc_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Tabellen für NOTE_CON (Weiterverarbeitung)
DATA: inoc_key TYPE eenfi_note_key_di OCCURS 0 WITH HEADER LINE.
DATA: inoc_notes TYPE eenfi_single_note_di OCCURS 0 WITH HEADER LINE.
DATA: inoc_text TYPE eenfi_note_text_di OCCURS 0 WITH HEADER LINE.

* interne Strukturen für NOTE_CON (Übergabe aus Datei)
DATA: x_inoc_key TYPE /adesso/mt_eenfi_note_key_di.
DATA: x_inoc_notes TYPE /adesso/mt_eenfi_singl_note_di.
DATA: x_inoc_text TYPE /adesso/mt_eenfi_note_text_di.


*----------------------------------------------------------------------
* Datendeklaration für Belade-FUBA NOTE_DLC
DATA: oldkey_nod LIKE /adesso/mt_transfer-oldkey.

DATA  i_nod_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Tabellen für NOTE_DLC (Weiterverarbeitung)
DATA: inod_key TYPE eenfi_note_key_di OCCURS 0 WITH HEADER LINE.
DATA: inod_notes TYPE eenfi_single_note_di OCCURS 0 WITH HEADER LINE.
DATA: inod_text TYPE eenfi_note_text_di OCCURS 0 WITH HEADER LINE.

* interne Strukturen für NOTE_DLC (Übergabe aus Datei)
DATA: x_inod_key TYPE /adesso/mt_eenfi_note_key_di.
DATA: x_inod_notes TYPE /adesso/mt_eenfi_singl_note_di.
DATA: x_inod_text TYPE /adesso/mt_eenfi_note_text_di.

*----------------------------------------------------------------------
* Datendeklaration für Belade-FUBA DEVICE
DATA: oldkey_dev LIKE /adesso/mt_transfer-oldkey.

DATA  i_dev_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Tabellen für DEVICE (Weiterverarbeitung)
DATA: i_equi TYPE v_equi OCCURS 0 WITH HEADER LINE.
DATA: i_egers TYPE egers OCCURS 0 WITH HEADER LINE.
DATA: i_egerh TYPE egerh OCCURS 0 WITH HEADER LINE.
DATA: i_clhead TYPE emg_clshead OCCURS 0 WITH HEADER LINE.
DATA: i_cldata TYPE api_ausp OCCURS 0 WITH HEADER LINE.

* interne Strukturen für DEVICE (Übergabe aus Datei)
DATA: x_i_equi   TYPE /adesso/mt_v_equi.
DATA: x_i_egers  TYPE /adesso/mt_egers.
DATA: x_i_egerh  TYPE /adesso/mt_egerh.
DATA: x_i_clhead TYPE /adesso/mt_emg_clshead.
DATA: x_i_cldata TYPE /adesso/mt_api_ausp.

*----------------------------------------------------------------------
* Datendeklaration für Belade-FUBA INSTLN
DATA: oldkey_ins LIKE /adesso/mt_transfer-oldkey.

DATA  i_ins_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Strukturen für INSTLN (Übergabe aus Datei)
DATA: x_ins_key    TYPE /adesso/mt_eanlhkey.
DATA: x_ins_data   TYPE /adesso/mt_emg_eanl.
DATA: x_ins_rcat   TYPE /adesso/mt_isu_aittyp.
DATA: x_ins_pod    TYPE /adesso/mt_eui_ext_obj_auto.

* interne Tabellen für INSTLN (Weiterverarbeitung)
DATA: ins_key    TYPE eanlhkey           OCCURS 0 WITH HEADER LINE.

*DATA: ins_data   TYPE emg_eanl           OCCURS 0 WITH HEADER LINE.
DATA: BEGIN OF ins_data OCCURS 0.
        INCLUDE STRUCTURE emg_eanl.
DATA: k_vstelle TYPE char1.
DATA END OF ins_data.

DATA: ins_rcat   TYPE isu_aittyp         OCCURS 0 WITH HEADER LINE.
DATA: ins_pod    TYPE eui_ext_obj_auto   OCCURS 0 WITH HEADER LINE.

DATA: ins_key2    TYPE eanlhkey           OCCURS 0 WITH HEADER LINE.
DATA: ins_data2   TYPE emg_eanl           OCCURS 0 WITH HEADER LINE.
DATA: ins_rcat2   TYPE isu_aittyp         OCCURS 0 WITH HEADER LINE.
DATA: ins_pod2    TYPE eui_ext_obj_auto   OCCURS 0 WITH HEADER LINE.

*DATA: ins_IN_REF TYPE EMG_REFVAL OCCURS 0 WITH HEADER LINE.
DATA: ins_f_quan TYPE emg_facts_quant    OCCURS 0 WITH HEADER LINE.
DATA: ins_v_quan TYPE emg_value_quant    OCCURS 0 WITH HEADER LINE.
DATA: ins_f_dema TYPE emg_facts_demand   OCCURS 0 WITH HEADER LINE.
DATA: ins_v_dema TYPE emg_value_demand   OCCURS 0 WITH HEADER LINE.
DATA: ins_f_tqua TYPE emg_facts_tquant   OCCURS 0 WITH HEADER LINE.
DATA: ins_v_tqua TYPE emg_value_tquant   OCCURS 0 WITH HEADER LINE.
DATA: ins_f_qpri TYPE emg_facts_qprice   OCCURS 0 WITH HEADER LINE.
DATA: ins_v_qpri TYPE emg_value_qprice   OCCURS 0 WITH HEADER LINE.
DATA: ins_f_amou TYPE emg_facts_amount   OCCURS 0 WITH HEADER LINE.
DATA: ins_v_amou TYPE emg_value_amount   OCCURS 0 WITH HEADER LINE.
DATA: ins_f_fact TYPE emg_facts_factor   OCCURS 0 WITH HEADER LINE.
DATA: ins_v_fact TYPE emg_value_factor   OCCURS 0 WITH HEADER LINE.
DATA: ins_f_flag TYPE emg_facts_flag     OCCURS 0 WITH HEADER LINE.
DATA: ins_v_flag TYPE emg_value_flag     OCCURS 0 WITH HEADER LINE.
DATA: ins_f_inte TYPE emg_facts_integer  OCCURS 0 WITH HEADER LINE.
DATA: ins_v_inte TYPE emg_value_integer  OCCURS 0 WITH HEADER LINE.
DATA: ins_f_rate TYPE emg_facts_ratetype OCCURS 0 WITH HEADER LINE.
DATA: ins_v_rate TYPE emg_value_ratetype OCCURS 0 WITH HEADER LINE.
DATA: ins_f_aabs TYPE emg_facts_adiscabs OCCURS 0 WITH HEADER LINE.
DATA: ins_v_aabs TYPE emg_value_adiscabs OCCURS 0 WITH HEADER LINE.
DATA: ins_f_aper TYPE emg_facts_adiscper OCCURS 0 WITH HEADER LINE.
DATA: ins_v_aper TYPE emg_value_adiscper OCCURS 0 WITH HEADER LINE.
DATA: ins_f_ddis TYPE emg_facts_ddiscnt  OCCURS 0 WITH HEADER LINE.
DATA: ins_v_ddis TYPE emg_value_ddiscnt  OCCURS 0 WITH HEADER LINE.
DATA: ins_f_pdis TYPE emg_facts_pdiscnt  OCCURS 0 WITH HEADER LINE.
DATA: ins_v_pdis TYPE emg_value_pdiscnt  OCCURS 0 WITH HEADER LINE.
DATA: ins_f_qdis TYPE emg_facts_qdiscnt  OCCURS 0 WITH HEADER LINE.
DATA: ins_v_qdis TYPE emg_value_qdiscnt  OCCURS 0 WITH HEADER LINE.
DATA: ins_f_lpri TYPE emg_facts_lprice   OCCURS 0 WITH HEADER LINE.
DATA: ins_v_lpri TYPE emg_value_lprice   OCCURS 0 WITH HEADER LINE.
DATA: ins_f_spri TYPE emg_facts_sprice   OCCURS 0 WITH HEADER LINE.
DATA: ins_v_spri TYPE emg_value_sprice   OCCURS 0 WITH HEADER LINE.
DATA: ins_f_tpri TYPE emg_facts_tprice   OCCURS 0 WITH HEADER LINE.
DATA: ins_v_tpri TYPE emg_value_tprice   OCCURS 0 WITH HEADER LINE.
DATA: ins_f_udef TYPE emg_facts_userdef  OCCURS 0 WITH HEADER LINE.
DATA: ins_v_udef TYPE emg_value_userdef  OCCURS 0 WITH HEADER LINE.

* interne Tabellen mit Operand und Value zusammen
DATA: ins_facts    TYPE /adesso/mt_facts  OCCURS 0 WITH HEADER LINE.
DATA: ins_facts2    TYPE /adesso/mt_facts  OCCURS 0 WITH HEADER LINE.
DATA: wins_facts   TYPE /adesso/mt_facts.

*DATA: wins_QUANT    TYPE /ADESSO/MT_FACTS.
*DATA: wins_DEMAND   TYPE /ADESSO/MT_FACTS.
*DATA: wins_TQUANT   TYPE /ADESSO/MT_FACTS.
*DATA: wins_QPRICE   TYPE /ADESSO/MT_FACTS.
*DATA: wins_AMOUNT   TYPE /ADESSO/MT_FACTS.
*DATA: wins_FACTOR   TYPE /ADESSO/MT_FACTS.
*DATA: wins_FLAG     TYPE /ADESSO/MT_FACTS.
*DATA: wins_INTEGER  TYPE /ADESSO/MT_FACTS.
*DATA: wins_RATETYPE TYPE /ADESSO/MT_FACTS.
*DATA: wins_ADISCABS TYPE /ADESSO/MT_FACTS.
*DATA: wins_ADISCPER TYPE /ADESSO/MT_FACTS.
*DATA: wins_DDISCNT  TYPE /ADESSO/MT_FACTS.
*DATA: wins_PDISCNT  TYPE /ADESSO/MT_FACTS.
*DATA: wins_QDISCNT  TYPE /ADESSO/MT_FACTS.
*DATA: wins_LPRICE   TYPE /ADESSO/MT_FACTS.
*DATA: wins_SPRICE   TYPE /ADESSO/MT_FACTS.
*DATA: wins_TPRICE   TYPE /ADESSO/MT_FACTS.
*DATA: wins_USERDEF  TYPE /ADESSO/MT_FACTS.

*----------------------------------------------------------------------
* Datendeklaration für Belade-FUBA INSTLN_NN
DATA: oldkey_inn LIKE /adesso/mt_transfer-oldkey.

DATA  i_inn_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Strukturen für INSTLN_NN (Übergabe aus Datei)
DATA: x_inn_key    TYPE /adesso/mt_eanlhkey.
DATA: x_inn_data   TYPE /adesso/mt_emg_eanl.
DATA: x_inn_rcat   TYPE /adesso/mt_isu_aittyp.
DATA: x_inn_pod    TYPE /adesso/mt_eui_ext_obj_auto.

* interne Tabellen für INSTLN_NN (Weiterverarbeitung)
DATA: inn_key    TYPE eanlhkey           OCCURS 0 WITH HEADER LINE.

*DATA: ins_data   TYPE emg_eanl           OCCURS 0 WITH HEADER LINE.
DATA: BEGIN OF inn_data OCCURS 0.
        INCLUDE STRUCTURE emg_eanl.
DATA: k_vstelle TYPE char1.
DATA END OF inn_data.

DATA: inn_rcat   TYPE isu_aittyp         OCCURS 0 WITH HEADER LINE.
DATA: inn_pod    TYPE eui_ext_obj_auto   OCCURS 0 WITH HEADER LINE.

*----------------------------------------------------------------------

*----------------------------------------------------------------------
* Datendeklaration für Belade-FUBA INSTLNCHA
DATA: oldkey_ich LIKE /adesso/mt_transfer-oldkey.

DATA  i_ich_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Strukturen für INSTLNCHA (Übergabe aus Datei)
DATA: x_ich_key    TYPE /adesso/mt_eanlhkey.
DATA: x_ich_data   TYPE /adesso/mt_emg_eanl.
DATA: x_ich_rcat   TYPE /adesso/mt_isu_aittyp.

* interne Tabellen für INSTLNCHA (Weiterverarbeitung)
DATA: ich_key    TYPE eanlhkey           OCCURS 0 WITH HEADER LINE.
DATA: ich_data   TYPE emg_eanl           OCCURS 0 WITH HEADER LINE.
DATA: ich_rcat   TYPE isu_aittyp         OCCURS 0 WITH HEADER LINE.
DATA: ich_key2    TYPE eanlhkey           OCCURS 0 WITH HEADER LINE.
DATA: ich_data2   TYPE emg_eanl           OCCURS 0 WITH HEADER LINE.
DATA: ich_rcat2   TYPE isu_aittyp         OCCURS 0 WITH HEADER LINE.

*DATA: ich_IN_REF TYPE EMG_REFVAL OCCURS 0 WITH HEADER LINE.
DATA: ich_f_quan TYPE emg_facts_quant    OCCURS 0 WITH HEADER LINE.
DATA: ich_v_quan TYPE emg_value_quant    OCCURS 0 WITH HEADER LINE.
DATA: ich_f_dema TYPE emg_facts_demand   OCCURS 0 WITH HEADER LINE.
DATA: ich_v_dema TYPE emg_value_demand   OCCURS 0 WITH HEADER LINE.
DATA: ich_f_tqua TYPE emg_facts_tquant   OCCURS 0 WITH HEADER LINE.
DATA: ich_v_tqua TYPE emg_value_tquant   OCCURS 0 WITH HEADER LINE.
DATA: ich_f_qpri TYPE emg_facts_qprice   OCCURS 0 WITH HEADER LINE.
DATA: ich_v_qpri TYPE emg_value_qprice   OCCURS 0 WITH HEADER LINE.
DATA: ich_f_amou TYPE emg_facts_amount   OCCURS 0 WITH HEADER LINE.
DATA: ich_v_amou TYPE emg_value_amount   OCCURS 0 WITH HEADER LINE.
DATA: ich_f_fact TYPE emg_facts_factor   OCCURS 0 WITH HEADER LINE.
DATA: ich_v_fact TYPE emg_value_factor   OCCURS 0 WITH HEADER LINE.
DATA: ich_f_flag TYPE emg_facts_flag     OCCURS 0 WITH HEADER LINE.
DATA: ich_v_flag TYPE emg_value_flag     OCCURS 0 WITH HEADER LINE.
DATA: ich_f_inte TYPE emg_facts_integer  OCCURS 0 WITH HEADER LINE.
DATA: ich_v_inte TYPE emg_value_integer  OCCURS 0 WITH HEADER LINE.
DATA: ich_f_rate TYPE emg_facts_ratetype OCCURS 0 WITH HEADER LINE.
DATA: ich_v_rate TYPE emg_value_ratetype OCCURS 0 WITH HEADER LINE.
DATA: ich_f_aabs TYPE emg_facts_adiscabs OCCURS 0 WITH HEADER LINE.
DATA: ich_v_aabs TYPE emg_value_adiscabs OCCURS 0 WITH HEADER LINE.
DATA: ich_f_aper TYPE emg_facts_adiscper OCCURS 0 WITH HEADER LINE.
DATA: ich_v_aper TYPE emg_value_adiscper OCCURS 0 WITH HEADER LINE.
DATA: ich_f_ddis TYPE emg_facts_ddiscnt  OCCURS 0 WITH HEADER LINE.
DATA: ich_v_ddis TYPE emg_value_ddiscnt  OCCURS 0 WITH HEADER LINE.
DATA: ich_f_pdis TYPE emg_facts_pdiscnt  OCCURS 0 WITH HEADER LINE.
DATA: ich_v_pdis TYPE emg_value_pdiscnt  OCCURS 0 WITH HEADER LINE.
DATA: ich_f_qdis TYPE emg_facts_qdiscnt  OCCURS 0 WITH HEADER LINE.
DATA: ich_v_qdis TYPE emg_value_qdiscnt  OCCURS 0 WITH HEADER LINE.
DATA: ich_f_lpri TYPE emg_facts_lprice   OCCURS 0 WITH HEADER LINE.
DATA: ich_v_lpri TYPE emg_value_lprice   OCCURS 0 WITH HEADER LINE.
DATA: ich_f_spri TYPE emg_facts_sprice   OCCURS 0 WITH HEADER LINE.
DATA: ich_v_spri TYPE emg_value_sprice   OCCURS 0 WITH HEADER LINE.
DATA: ich_f_tpri TYPE emg_facts_tprice   OCCURS 0 WITH HEADER LINE.
DATA: ich_v_tpri TYPE emg_value_tprice   OCCURS 0 WITH HEADER LINE.

* interne Tabellen mit Operand und Value zusammen
DATA: ich_facts    TYPE /adesso/mt_facts  OCCURS 0 WITH HEADER LINE.
DATA: ich_facts2    TYPE /adesso/mt_facts  OCCURS 0 WITH HEADER LINE.
DATA: wich_facts   TYPE /adesso/mt_facts.

*----------------------------------------------------------------------
* Datendeklaration für Belade-FUBA FACTS
DATA: oldkey_fac LIKE /adesso/mt_transfer-oldkey.

DATA  i_fac_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Struktur für FACTS (Übergabe aus Datei)
DATA: x_ifac_key  TYPE /adesso/mt_eanlhkey.

* interne Tabellen für FACTS (Weiterverarbeitung)
DATA: ifac_key    TYPE eanlhkey           OCCURS 0 WITH HEADER LINE.
DATA: ifac_key2   TYPE eanlhkey           OCCURS 0 WITH HEADER LINE.
*DATA: ifac_IN_REF TYPE EMG_REFVAL OCCURS 0 WITH HEADER LINE.
DATA: ifac_f_quan TYPE emg_facts_quant    OCCURS 0 WITH HEADER LINE.
DATA: ifac_v_quan TYPE emg_value_quant    OCCURS 0 WITH HEADER LINE.
DATA: ifac_f_dema TYPE emg_facts_demand   OCCURS 0 WITH HEADER LINE.
DATA: ifac_v_dema TYPE emg_value_demand   OCCURS 0 WITH HEADER LINE.
DATA: ifac_f_tqua TYPE emg_facts_tquant   OCCURS 0 WITH HEADER LINE.
DATA: ifac_v_tqua TYPE emg_value_tquant   OCCURS 0 WITH HEADER LINE.
DATA: ifac_f_qpri TYPE emg_facts_qprice   OCCURS 0 WITH HEADER LINE.
DATA: ifac_v_qpri TYPE emg_value_qprice   OCCURS 0 WITH HEADER LINE.
DATA: ifac_f_amou TYPE emg_facts_amount   OCCURS 0 WITH HEADER LINE.
DATA: ifac_v_amou TYPE emg_value_amount   OCCURS 0 WITH HEADER LINE.
DATA: ifac_f_fact TYPE emg_facts_factor   OCCURS 0 WITH HEADER LINE.
DATA: ifac_v_fact TYPE emg_value_factor   OCCURS 0 WITH HEADER LINE.
DATA: ifac_f_flag TYPE emg_facts_flag     OCCURS 0 WITH HEADER LINE.
DATA: ifac_v_flag TYPE emg_value_flag     OCCURS 0 WITH HEADER LINE.
DATA: ifac_f_inte TYPE emg_facts_integer  OCCURS 0 WITH HEADER LINE.
DATA: ifac_v_inte TYPE emg_value_integer  OCCURS 0 WITH HEADER LINE.
DATA: ifac_f_rate TYPE emg_facts_ratetype OCCURS 0 WITH HEADER LINE.
DATA: ifac_v_rate TYPE emg_value_ratetype OCCURS 0 WITH HEADER LINE.
DATA: ifac_f_aabs TYPE emg_facts_adiscabs OCCURS 0 WITH HEADER LINE.
DATA: ifac_v_aabs TYPE emg_value_adiscabs OCCURS 0 WITH HEADER LINE.
DATA: ifac_f_aper TYPE emg_facts_adiscper OCCURS 0 WITH HEADER LINE.
DATA: ifac_v_aper TYPE emg_value_adiscper OCCURS 0 WITH HEADER LINE.
DATA: ifac_f_ddis TYPE emg_facts_ddiscnt  OCCURS 0 WITH HEADER LINE.
DATA: ifac_v_ddis TYPE emg_value_ddiscnt  OCCURS 0 WITH HEADER LINE.
DATA: ifac_f_pdis TYPE emg_facts_pdiscnt  OCCURS 0 WITH HEADER LINE.
DATA: ifac_v_pdis TYPE emg_value_pdiscnt  OCCURS 0 WITH HEADER LINE.
DATA: ifac_f_qdis TYPE emg_facts_qdiscnt  OCCURS 0 WITH HEADER LINE.
DATA: ifac_v_qdis TYPE emg_value_qdiscnt  OCCURS 0 WITH HEADER LINE.
DATA: ifac_f_lpri TYPE emg_facts_lprice   OCCURS 0 WITH HEADER LINE.
DATA: ifac_v_lpri TYPE emg_value_lprice   OCCURS 0 WITH HEADER LINE.
DATA: ifac_f_spri TYPE emg_facts_sprice   OCCURS 0 WITH HEADER LINE.
DATA: ifac_v_spri TYPE emg_value_sprice   OCCURS 0 WITH HEADER LINE.
DATA: ifac_f_tpri TYPE emg_facts_tprice   OCCURS 0 WITH HEADER LINE.
DATA: ifac_v_tpri TYPE emg_value_tprice   OCCURS 0 WITH HEADER LINE.
DATA: ifac_f_udef TYPE emg_facts_userdef  OCCURS 0 WITH HEADER LINE.
DATA: ifac_v_udef TYPE emg_value_userdef  OCCURS 0 WITH HEADER LINE.

* interne Tabellen mit Operand und Value zusammen
DATA: ifac_facts    TYPE /adesso/mt_facts  OCCURS 0 WITH HEADER LINE.
DATA: ifac_facts2   TYPE /adesso/mt_facts  OCCURS 0 WITH HEADER LINE.
DATA: wfac_facts    TYPE /adesso/mt_facts.

*----------------------------------------------------------------------
* Datendeklaration für Belade-FUBA ACCOUNT
DATA: oldkey_acc LIKE /adesso/mt_transfer-oldkey.

DATA  i_acc_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Tabellen für ACCOUNT (zur Weiterverarbeitung)

*DATA: iacc_init   TYPE fkkvk_hdr_di     OCCURS 0 WITH HEADER LINE.
DATA: BEGIN OF iacc_init OCCURS 0.
        INCLUDE STRUCTURE fkkvk_hdr_di.
DATA: k_gpart TYPE char1.
DATA: END OF iacc_init.

*DATA: iacc_vk     TYPE fkkvk_s_di       OCCURS 0 WITH HEADER LINE.
DATA: BEGIN OF iacc_vk OCCURS 0.
        INCLUDE STRUCTURE fkkvk_s_di.
DATA: name_last  TYPE bu_namep_l,
      name_first TYPE bu_namep_f.
DATA: END OF iacc_vk.

*DATA: iacc_vkp    TYPE fkkvkp_s_di      OCCURS 0 WITH HEADER LINE.
DATA: BEGIN OF iacc_vkp OCCURS 0.
        INCLUDE STRUCTURE fkkvkp_s_di.
DATA: k_partner TYPE char1.
DATA: END OF iacc_vkp.

DATA: iacc_vklock TYPE fkkvklock_s_di   OCCURS 0 WITH HEADER LINE.
DATA: iacc_vkcorr TYPE fkkvk_corr_s_di  OCCURS 0 WITH HEADER LINE.
DATA: iacc_vktxex TYPE fkkvk_taxex_s_di OCCURS 0 WITH HEADER LINE.

* interne Strukturen für ACCOUNT (Übergabe aus Datei)
DATA: x_iacc_init   TYPE /adesso/mt_fkkvk_hdr_di.
DATA: x_iacc_vk     TYPE /adesso/mt_fkkvk_s_di.
DATA: x_iacc_vkp    TYPE /adesso/mt_fkkvkp_s_di.
DATA: x_iacc_vklock TYPE /adesso/mt_fkkvklock_s_di.
DATA: x_iacc_vkcorr TYPE /adesso/mt_fkkvk_corr_s_di.
DATA: x_iacc_vktxex TYPE /adesso/mt_fkkvk_taxex_s_di.



*----------------------------------------------------------------------
* Datendeklaration für Belade-FUBA REFVALUES
DATA: oldkey_rva LIKE /adesso/mt_transfer-oldkey.

DATA  i_rva_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Tabellen für REFVALUES (Übergabe aus Datei)
DATA: irva_key    TYPE eanlhkey OCCURS 0 WITH HEADER LINE.
DATA: irva_refval TYPE emg_ref_value OCCURS 0 WITH HEADER LINE.
DATA: irva_tre    TYPE revstre OCCURS 0 WITH HEADER LINE.
DATA: irva_bart   TYPE rebasl OCCURS 0 WITH HEADER LINE.
DATA: irva_hist   TYPE rebezug OCCURS 0 WITH HEADER LINE.
DATA: irva_hzg    TYPE resohzg OCCURS 0 WITH HEADER LINE.
DATA: irva_addr   TYPE addr1_data OCCURS 0 WITH HEADER LINE.
* gelieferte Struktur ETTIFB
DATA: irva_ettifb LIKE /adesso/mt_ettifb OCCURS 0 WITH HEADER LINE.


*----------------------------------------------------------------------
* Datendeklaration für Belade-FUBA ACC_NOTE
DATA: oldkey_acn LIKE /adesso/mt_transfer-oldkey.

DATA  i_acn_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Tabellen für ACC_NOTE (Weiterverarbeitung)
DATA: iacn_notkey TYPE emg_notice_key OCCURS 0 WITH HEADER LINE.
DATA: iacn_notlin TYPE emg_tline OCCURS 0 WITH HEADER LINE.
* interne Strukturen für ACC_NOTE (Übergabe aus Datei)
DATA: x_iacn_notkey TYPE /adesso/mt_emg_notice_key.
DATA: x_iacn_notlin TYPE /adesso/mt_emg_tline.

*----------------------------------------------------------------------
* Datendeklaration für Belade-FUBA MOVE_IN
DATA: oldkey_moi LIKE /adesso/mt_transfer-oldkey.

DATA  i_moi_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Tabellen für MOVE_IN (Weiterverarbeitung)
*DATA: imoi_ever TYPE everd OCCURS 0 WITH HEADER LINE.
DATA: BEGIN OF imoi_ever OCCURS 0.
        INCLUDE STRUCTURE everd.
DATA: k_anlage TYPE char1,
      k_vkonto TYPE char1.
DATA: END OF imoi_ever.

*DATA: imoi_ever2 TYPE everd OCCURS 0 WITH HEADER LINE.
DATA: BEGIN OF imoi_ever2 OCCURS 0.
        INCLUDE STRUCTURE everd.
DATA: k_anlage TYPE char1,
      k_vkonto TYPE char1.
DATA: END OF imoi_ever2.

* interne Struktur für MOVE_IN (Übergabe aus Datei)
DATA: x_imoi_ever TYPE /adesso/mt_everd.

*----------------------------------------------------------------------
* Datendeklaration für Belade-FUBA BCONTACT
DATA: oldkey_bct LIKE /adesso/mt_transfer-oldkey.

DATA  i_bct_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Tabellen für BCONTACT (Weiterverarbeitung)
DATA: ibct_bcontd TYPE bcontd OCCURS 0 WITH HEADER LINE.
DATA: ibct_pbcobj TYPE bpc_obj OCCURS 0 WITH HEADER LINE.

* interne Strukturen für BCONTACT (Übergabe aus Datei)
DATA: x_ibct_bcontd TYPE /adesso/mt_bcontd.
DATA: x_ibct_pbcobj TYPE /adesso/mt_bpc_obj.

*----------------------------------------------------------------------
* Datendeklaration für Belade-FUBA MOVE_IN_H
DATA: oldkey_moh LIKE /adesso/mt_transfer-oldkey.

DATA  i_moh_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Tabellen für MOVE_IN_H (Weiterverarbeitung)
*DATA: imoi_ever TYPE everd OCCURS 0 WITH HEADER LINE.
DATA: BEGIN OF imoh_ever OCCURS 0.
        INCLUDE STRUCTURE everd.
DATA: k_anlage TYPE char1,
      k_vkonto TYPE char1.
DATA: END OF imoh_ever.

*DATA: imoi_ever2 TYPE everd OCCURS 0 WITH HEADER LINE.
DATA: BEGIN OF imoh_ever2 OCCURS 0.
        INCLUDE STRUCTURE everd.
DATA: k_anlage TYPE char1,
      k_vkonto TYPE char1.
DATA: END OF imoh_ever2.

* interne Struktur für MOVE_IN (Übergabe aus Datei)
DATA: x_imoh_ever TYPE /adesso/mt_everd.
*----------------------------------------------------------------------
* Datendeklaration für Belade-FUBA MOVE_OUT
DATA: oldkey_moo LIKE /adesso/mt_transfer-oldkey.

DATA:  i_moo_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Tabellen für MOVE_OUT (Übergabe aus Datei)
DATA: imoo_eausd   TYPE bapiisumocrd OCCURS 0 WITH HEADER LINE.
DATA: imoo_eausvd  TYPE bapiisumovd OCCURS 0 WITH HEADER LINE.

*----------------------------------------------------------------------
* Datendeklaration für Belade-FUBA DUNNING
DATA: oldkey_dun LIKE /adesso/mt_transfer-oldkey.

DATA  idun_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Strukturen für INSTLN (Übergabe aus Datei)
DATA: x_dun_key    TYPE /adesso/mt_emg_dunning.
DATA: x_dun_fkkma   TYPE /adesso/mt_fkkmavs.

* interne Tabellen für INSTPLAN (Weiterverarbeitung)
DATA: idun_key  TYPE emg_dunning OCCURS 0 WITH HEADER LINE.
DATA: idun_fkkma TYPE fkkmavs OCCURS 0 WITH HEADER LINE.

*----------------------------------------------------------------------
* Datendeklaration für Belade-FUBA BCONT_NOTE
DATA: oldkey_bcn LIKE /adesso/mt_transfer-oldkey.

DATA  i_bcn_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Tabellen für BCONT_NOTE (Weiterverarbeitung)
DATA: ibcn_notkey TYPE emg_notice_key OCCURS 0 WITH HEADER LINE.
DATA: ibcn_notlin TYPE emg_tline OCCURS 0 WITH HEADER LINE.

* interne Strukturen für BCONT_NOTE (Übergabe aus Datei)
DATA: x_ibcn_notkey TYPE /adesso/mt_emg_notice_key.
DATA: x_ibcn_notlin TYPE /adesso/mt_emg_tline.

*----------------------------------------------------------------------
* Datendeklaration für Belade-FUBA BBP_MULT
DATA: oldkey_bpm LIKE /adesso/mt_transfer-oldkey.

DATA: ijvl LIKE /adesso/mtb_jvl OCCURS 0 WITH HEADER LINE.
DATA: BEGIN OF key_jvl,
        mandt  TYPE mandt,
        firma  TYPE emg_firma,
        bukrs  TYPE bukrs,
        sparte TYPE sparte,
      END OF key_jvl.

DATA  i_bpm_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Tabellen für BBP_MULT (Weiterverarbeitung)
DATA: ibpm_eabp  TYPE eabp OCCURS 0 WITH HEADER LINE.
DATA: ibpm_eabpv TYPE emigr_ever OCCURS 0 WITH HEADER LINE.
DATA: ibpm_eabpv2 TYPE emigr_ever OCCURS 0 WITH HEADER LINE.
DATA: ibpm_eabps TYPE sfkkop OCCURS 0 WITH HEADER LINE.
DATA: ibpm_eabps2 TYPE sfkkop OCCURS 0 WITH HEADER LINE.
DATA: ibpm_ejvl  TYPE ejvl OCCURS 0 WITH HEADER LINE.
DATA: ibpm_ejvl2  TYPE ejvl OCCURS 0 WITH HEADER LINE.

* interne Strukturen für BBP_MULT (Übergabe aus Datei)
DATA: x_ibpm_eabp  TYPE /adesso/mt_eabp.
DATA: x_ibpm_eabpv TYPE /adesso/mt_emigr_ever.
DATA: x_ibpm_eabps TYPE /adesso/mt_sfkkop.
DATA: x_ibpm_ejvl  TYPE /adesso/mt_ejvl.

*----------------------------------------------------------------------
* Datendeklaration für Belade-FUBA PAYMENT
DATA: oldkey_pay LIKE /adesso/mt_transfer-oldkey.

DATA  i_pay_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Tabellen für PAYMENT (Weiterverarbeitung)
DATA: ipay_fkkko  TYPE emig_pay_fkkko OCCURS 0 WITH HEADER LINE.
DATA: ipay_fkkopk TYPE fkkopk OCCURS 0 WITH HEADER LINE.
DATA: ipay_seltns TYPE emig_pay_seltns OCCURS 0 WITH HEADER LINE.
DATA: ipay_seltns2 TYPE emig_pay_seltns OCCURS 0 WITH HEADER LINE.

* interne Strukturen für PAYMENT (Übergabe aus Datei)
DATA: x_ipay_fkkko  TYPE /adesso/mt_emig_pay_fkkko.
DATA: x_ipay_fkkopk TYPE /adesso/mt_fkkopk.
DATA: x_ipay_seltns TYPE /adesso/mt_emig_pay_seltns.


*----------------------------------------------------------------------
* Datendeklaration für Belade-FUBA DOCUMENT
DATA: oldkey_doc LIKE /adesso/mt_transfer-oldkey.

DATA  i_doc_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Tabellen für DOCUMENT (Weiterverarbeitung)
DATA: idoc_ko     TYPE fkkko OCCURS 0 WITH HEADER LINE.
DATA: idoc_op     TYPE fkkop OCCURS 0 WITH HEADER LINE.
DATA: idoc_opk    TYPE fkkopk OCCURS 0 WITH HEADER LINE.
DATA: idoc_opl    TYPE fkkopl OCCURS 0 WITH HEADER LINE.
DATA: idoc_addinf TYPE emig_doc_addinfo OCCURS 0 WITH HEADER LINE.

* interne Strukturen für DOCUMENT (Übergabe aus Datei)
DATA: x_idoc_ko     TYPE /adesso/mt_fkkko.
DATA: x_idoc_op     TYPE /adesso/mt_fkkop.
DATA: x_idoc_opk    TYPE /adesso/mt_fkkopk.
DATA: x_idoc_opl    TYPE /adesso/mt_fkkopl.
DATA: x_idoc_addinf TYPE /adesso/mt_emig_doc_addinfo.

*----------------------------------------------------------------------
* Datendeklaration für Belade-FUBA INSTPLAN
DATA: oldkey_ipl LIKE /adesso/mt_transfer-oldkey.

DATA  i_ipl_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Tabellen für INSTPLAN (Weiterverarbeitung)
DATA: ipl_ipkey  TYPE emg_instplan OCCURS 0 WITH HEADER LINE.
DATA: ipl_ipdata TYPE fkkintpln OCCURS 0 WITH HEADER LINE.
DATA: ipl_ipopky TYPE fkkopkey OCCURS 0 WITH HEADER LINE.

* interne Strukturen für INSTPLAN (Übergabe aus Datei)
DATA: x_ipl_ipkey  TYPE /adesso/mt_emg_instplan.
DATA: x_ipl_ipdata TYPE /adesso/mt_fkkintpln.
DATA: x_ipl_ipopky TYPE /adesso/mt_fkkopkey.


*----------------------------------------------------------------------
* Datendeklaration für Belade-FUBA INST_MGMT
DATA: oldkey_inm LIKE /adesso/mt_transfer-oldkey.

DATA  i_inm_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Tabellen für INST_MGMT (Weiterverarbeitung)
DATA: inm_di_int TYPE emg_wol OCCURS 0 WITH HEADER LINE.
DATA: inm_di_zw  TYPE reg30_zw_c OCCURS 0 WITH HEADER LINE.
DATA: inm_di_ger TYPE reg30_gera OCCURS 0 WITH HEADER LINE.
DATA: inm_di_cnt TYPE emg_install_container OCCURS 0 WITH HEADER LINE.

DATA: inm_di_int2 TYPE emg_wol OCCURS 0 WITH HEADER LINE.
DATA: inm_di_zw2  TYPE reg30_zw_c OCCURS 0 WITH HEADER LINE.
DATA: inm_di_ger2 TYPE reg30_gera OCCURS 0 WITH HEADER LINE.
DATA: inm_di_cnt2 TYPE emg_install_container OCCURS 0 WITH HEADER LINE.

DATA: inm_di_int3 TYPE emg_wol OCCURS 0 WITH HEADER LINE.
DATA: inm_di_zw3  TYPE reg30_zw_c OCCURS 0 WITH HEADER LINE.
DATA: inm_di_ger3 TYPE reg30_gera OCCURS 0 WITH HEADER LINE.
DATA: inm_di_cnt3 TYPE emg_install_container OCCURS 0 WITH HEADER LINE.


* interne Tabellen für INST_MGMT (Übergabe aus Datei)
DATA: x_inm_di_int TYPE /adesso/mt_emg_wol.
DATA: x_inm_di_zw  TYPE /adesso/mt_reg30_zw_c.
DATA: x_inm_di_ger TYPE /adesso/mt_reg30_gera.
DATA: x_inm_di_cnt TYPE /adesso/mt_emg_install_containe.

*----------------------------------------------------------------------
* Datendeklaration für Belade-FUBA METERREAD
DATA: oldkey_mrd LIKE /adesso/mt_transfer-oldkey.

DATA  i_mrd_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Tabellen für METERREAD  (Weiterverarbeitung)
DATA: imrd_ieablu TYPE eablu OCCURS 0 WITH HEADER LINE.

* interne Tabellen für METERREAD (Übergabe aus Datei)
DATA: x_imrd_ieablu TYPE /adesso/mt_eablu.

*----------------------------------------------------------------------
* Datendeklaration für Belade-FUBA LOT
DATA: oldkey_lot LIKE /adesso/mt_transfer-oldkey.

DATA  i_lot_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Tabellen für LOT (Übergabe aus Datei)
*DATA: ilot_lotd TYPE elotd OCCURS 0 WITH HEADER LINE.
DATA: ilot_lotd TYPE /adesso/mt_elotd OCCURS 0 WITH HEADER LINE.


*----------------------------------------------------------------------
* Datendeklaration für Belade-FUBA STRT_ROUTE
DATA: oldkey_srt LIKE /adesso/mt_transfer-oldkey.

DATA  i_srt_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Tabellen für STRT_ROUTE (Übergabe aus Datei)
DATA: isrt_mru   TYPE emg_sr_ableinh OCCURS 0 WITH HEADER LINE.
DATA: isrt_equnr TYPE emg_sr_equnr OCCURS 0 WITH HEADER LINE.


*----------------------------------------------------------------------
* Datendeklaration für Belade-FUBA POD
DATA: oldkey_pod LIKE /adesso/mt_transfer-oldkey.

DATA  i_pod_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Tabellen für POD (Übergabe aus Datei)
DATA: ipod_uihead TYPE eui_auto_head OCCURS 0 WITH HEADER LINE.
DATA: ipod_uisrc  TYPE eui_auto_source OCCURS 0 WITH HEADER LINE.
DATA: ipod_uitanl TYPE emg_ui_auto_anlage OCCURS 0 WITH HEADER LINE.
DATA: ipod_zwnumm TYPE eui_auto_lzw OCCURS 0 WITH HEADER LINE.
DATA: ipod_uiext TYPE eui_auto_extui OCCURS 0 WITH HEADER LINE.
DATA: ipod_uigrid TYPE eui_auto_grid OCCURS 0 WITH HEADER LINE.


*----------------------------------------------------------------------
* Datendeklaration für Belade-FUBA PODCHANGE
DATA: oldkey_poc LIKE /adesso/mt_transfer-oldkey.

DATA  i_poc_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Tabellen für PODCHANGE (Übergabe aus Datei)
DATA: ipoc_uihead TYPE eui_auto_head OCCURS 0 WITH HEADER LINE.
DATA: ipoc_uisrc  TYPE eui_auto_source OCCURS 0 WITH HEADER LINE.
DATA: ipoc_uitanl TYPE emg_ui_auto_anlage OCCURS 0 WITH HEADER LINE.
DATA: ipoc_uitlzw TYPE eui_auto_lzw OCCURS 0 WITH HEADER LINE.
DATA: ipoc_uiext  TYPE eui_auto_extui OCCURS 0 WITH HEADER LINE.
DATA: ipoc_uigrid TYPE eui_auto_grid OCCURS 0 WITH HEADER LINE.


*----------------------------------------------------------------------
* Datendeklaration für Belade-FUBA PODSERVICE
DATA: oldkey_pos LIKE /adesso/mt_transfer-oldkey.

DATA  i_pos_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Tabellen für PODSERVICE (Weiterverarbeitung)
DATA: ipos_podsrv TYPE eserviced OCCURS 0 WITH HEADER LINE.
DATA: ipos_psvsel TYPE isumi_podservice_select
                                        OCCURS 0 WITH HEADER LINE.

* interne Tabellen für PODSERVICE (Übergabe aus Datei)
DATA: x_ipos_podsrv TYPE /adesso/mt_eserviced.
DATA: x_ipos_psvsel TYPE /adesso/mt_isumi_podservic_sel.


*----------------------------------------------------------------------
* Datendeklaration für Belade-FUBA DEVICERATE
DATA: oldkey_drt LIKE /adesso/mt_transfer-oldkey.

DATA  i_drt_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Tabellen für DEVICERATE (Weiterverarbeitung)
DATA: idrt_drint TYPE emg_devrate_int   OCCURS 0 WITH HEADER LINE.
DATA: idrt_drdev TYPE reg70_d           OCCURS 0 WITH HEADER LINE.
DATA: idrt_drreg TYPE reg70_r           OCCURS 0 WITH HEADER LINE.
DATA: idrt_drint2 TYPE emg_devrate_int   OCCURS 0 WITH HEADER LINE.
DATA: idrt_drdev2 TYPE reg70_d           OCCURS 0 WITH HEADER LINE.
DATA: idrt_drreg2 TYPE reg70_r           OCCURS 0 WITH HEADER LINE.

* interne Tabellen für DEVICERATE (Übergabe aus Datei)
DATA: x_idrt_drint TYPE /adesso/mt_emg_devrate_int.
DATA: x_idrt_drdev TYPE /adesso/mt_reg70_d.
DATA: x_idrt_drreg TYPE /adesso/mt_reg70_r.


*----------------------------------------------------------------------
* Datendeklaration für Belade-FUBA CON_NOTE
DATA: oldkey_cno LIKE /adesso/mt_transfer-oldkey.

DATA  i_cno_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Tabellen für CON_NOTE (Weiterverarbeitung)
DATA: icno_notkey TYPE emg_notice_key OCCURS 0 WITH HEADER LINE.
DATA: icno_notlin TYPE emg_tline OCCURS 0 WITH HEADER LINE.

* interne Strukturen für CON_NOTE (Übergabe aus Datei)
DATA: x_icno_notkey TYPE /adesso/mt_emg_notice_key.
DATA: x_icno_notlin TYPE /adesso/mt_emg_tline.

*----------------------------------------------------------------------
* Datendeklaration für Belade-FUBA LOADPROF
DATA: oldkey_lop LIKE /adesso/mt_transfer-oldkey.

DATA  i_lop_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Tabellen für LOADPROF (Weiterverarbeitung)
*DATA: ilop_key      TYPE elpass_key OCCURS 0 WITH HEADER LINE.
DATA: BEGIN OF ilop_key OCCURS 0.
        INCLUDE STRUCTURE elpass_key.
DATA: k_objkey TYPE char1.
DATA: END OF ilop_key.

DATA: ilop_elpass   TYPE elpass_auto OCCURS 0 WITH HEADER LINE.

*DATA: ilop_key2      TYPE elpass_key OCCURS 0 WITH HEADER LINE.
DATA: BEGIN OF ilop_key2 OCCURS 0.
        INCLUDE STRUCTURE elpass_key.
DATA: k_objkey TYPE char1.
DATA: END OF ilop_key2.

DATA: ilop_elpass2   TYPE elpass_auto OCCURS 0 WITH HEADER LINE.

* interne Strukturen für LOADPROF (Übergabe aus Datei)
DATA: x_ilop_key      TYPE /adesso/mt_elpass_key .
DATA: x_ilop_elpass   TYPE /adesso/mt_elpass_auto.

*----------------------------------------------------------------------

* Datendeklaration für Belade-FUBA DISC_DOC
DATA: oldkey_dcd LIKE /adesso/mt_transfer-oldkey.

DATA  i_dcd_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Tabellen für DISC_DOC (Weiterverarbeitung)
DATA: idcd_header TYPE emg_ddc_header OCCURS 0 WITH HEADER LINE.
DATA: idcd_fkkmaz TYPE emg_ddc_document_select
                                      OCCURS 0 WITH HEADER LINE.
DATA: idcd_header2 TYPE emg_ddc_header OCCURS 0 WITH HEADER LINE.
DATA: idcd_fkkmaz2 TYPE emg_ddc_document_select
                                      OCCURS 0 WITH HEADER LINE.

* interne Strukturen für DISC_DOC (Übergabe aus Datei)
DATA: x_idcd_header TYPE /adesso/mt_emg_ddc_header.
DATA: x_idcd_fkkmaz TYPE /adesso/mt_emg_ddc_docu_sel.


*----------------------------------------------------------------------
* Datendeklaration für Belade-FUBA DLC_NOTE
DATA: oldkey_dno LIKE /adesso/mt_transfer-oldkey.

DATA  i_dno_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Tabellen für DLC_NOTE (Weiterverarbeitung)
DATA: idno_notkey TYPE emg_notice_key OCCURS 0 WITH HEADER LINE.
DATA: idno_notlin TYPE emg_tline OCCURS 0 WITH HEADER LINE.

* interne Strukturen für DLC_NOTE (Übergabe aus Datei)
DATA: x_idno_notkey TYPE /adesso/mt_emg_notice_key.
DATA: x_idno_notlin TYPE /adesso/mt_emg_tline.


*----------------------------------------------------------------------

* Datendeklaration für Belade-FUBA DISC_ORDER
DATA: oldkey_dco LIKE /adesso/mt_transfer-oldkey.

DATA  i_dco_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Tabellen für DISC_ORDER (Weiterverarbeitung)
DATA: idco_header TYPE emg_ddc_header OCCURS 0 WITH HEADER LINE.
DATA: idco_header2 TYPE emg_ddc_header OCCURS 0 WITH HEADER LINE.

* interne Strukturen für DISC_ORDER (Übergabe aus Datei)
DATA: x_idco_header TYPE /adesso/mt_emg_ddc_header.


*----------------------------------------------------------------------

* Datendeklaration für Belade-FUBA DISC_RCORD
DATA: oldkey_dcr LIKE /adesso/mt_transfer-oldkey.

DATA  i_dcr_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Tabellen für DISC_RCORD (Weiterverarbeitung)
DATA: idcr_header TYPE emg_ddc_header OCCURS 0 WITH HEADER LINE.
DATA: idcr_header2 TYPE emg_ddc_header OCCURS 0 WITH HEADER LINE.

* interne Strukturen für DISC_RCORD (Übergabe aus Datei)
DATA: x_idcr_header TYPE /adesso/mt_emg_ddc_header.


*----------------------------------------------------------------------

* Datendeklaration für Belade-FUBA DISC_ENTER
DATA: oldkey_dce LIKE /adesso/mt_transfer-oldkey.

DATA  i_dce_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Tabellen für DISC_ENTER (Weiterverarbeitung)
DATA: idce_header TYPE emg_ddc_header OCCURS 0 WITH HEADER LINE.
DATA: idce_anlage TYPE emg_ddc_anlage_selection
                                            OCCURS 0 WITH HEADER LINE.
DATA: idce_device TYPE emg_ddc_device_selection
                                            OCCURS 0 WITH HEADER LINE.

DATA: idce_header2 TYPE emg_ddc_header OCCURS 0 WITH HEADER LINE.
DATA: idce_anlage2 TYPE emg_ddc_anlage_selection
                                            OCCURS 0 WITH HEADER LINE.
DATA: idce_device2 TYPE emg_ddc_device_selection
                                            OCCURS 0 WITH HEADER LINE.
DATA: idce_anlage3 TYPE emg_ddc_anlage_selection
                                            OCCURS 0 WITH HEADER LINE.

* interne Strukturen für DISC_ENTER (Übergabe aus Datei)
DATA: x_idce_header TYPE /adesso/mt_emg_ddc_header.
DATA: x_idce_anlage TYPE /adesso/mt_emg_ddc_anlage_sel.
DATA: x_idce_device TYPE /adesso/mt_emg_ddc_device_sel.


*----------------------------------------------------------------------

* Datendeklaration für Belade-FUBA DISC_RCENT
DATA: oldkey_dcm LIKE /adesso/mt_transfer-oldkey.

DATA  i_dcm_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Tabellen für DISC_RCENT (Weiterverarbeitung)
DATA: idcm_header TYPE emg_ddc_header OCCURS 0 WITH HEADER LINE.
DATA: idcm_anlage TYPE emg_ddc_anlage_selection
                                            OCCURS 0 WITH HEADER LINE.
DATA: idcm_device TYPE emg_ddc_device_selection
                                            OCCURS 0 WITH HEADER LINE.

DATA: idcm_header2 TYPE emg_ddc_header OCCURS 0 WITH HEADER LINE.
DATA: idcm_anlage2 TYPE emg_ddc_anlage_selection
                                            OCCURS 0 WITH HEADER LINE.
DATA: idcm_device2 TYPE emg_ddc_device_selection
                                            OCCURS 0 WITH HEADER LINE.
DATA: idcm_anlage3 TYPE emg_ddc_anlage_selection
                                            OCCURS 0 WITH HEADER LINE.

* interne Strukturen für DISC_RCENT (Übergabe aus Datei)
DATA: x_idcm_header TYPE /adesso/mt_emg_ddc_header.
DATA: x_idcm_anlage TYPE /adesso/mt_emg_ddc_anlage_sel.
DATA: x_idcm_device TYPE /adesso/mt_emg_ddc_device_sel.


*----------------------------------------------------------------------
* Datendeklaration für Belade-FUBA DEVGRP
DATA: oldkey_dgr LIKE /adesso/mt_transfer-oldkey.

DATA  i_dgr_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Tabellen für DEVGRP (Weiterverarbeitung)
DATA: idgr_edevgr TYPE emg_edevgr OCCURS 0 WITH HEADER LINE.
DATA: idgr_device TYPE v_eger OCCURS 0 WITH HEADER LINE.

* interne Strukturen für DEVGRP (Übergabe aus Datei)
DATA: x_idgr_edevgr TYPE /adesso/mt_emg_edevgr.
DATA: x_idgr_device TYPE /adesso/mt_v_eger.


*------------------------------------------------
* Datendeklaration für Belade-FUBA DEVINFOREC
DATA: oldkey_dir LIKE /adesso/mt_transfer-oldkey.

DATA  i_dir_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.


* interne Tabellen für DEVINFOREC (Weiterverarbeitung)
DATA: BEGIN OF i_dvmint OCCURS 0.
        INCLUDE STRUCTURE emg_devmod_int.
DATA  END OF i_dvmint.

DATA: BEGIN OF i_dvmdev OCCURS 0.
        INCLUDE STRUCTURE reg42_dev.
DATA  END OF i_dvmdev.

DATA: BEGIN OF i_dvmdfl OCCURS 0.
        INCLUDE STRUCTURE reg42_dev_input_flag.
DATA  END OF i_dvmdfl.

DATA: BEGIN OF i_dvmreg OCCURS 0.
        INCLUDE STRUCTURE reg42_zw.
DATA  END OF i_dvmreg.

DATA: BEGIN OF i_dvmrfl OCCURS 0.
        INCLUDE STRUCTURE reg42_zw_input_flag.
DATA  END OF i_dvmrfl.



* interne Strukturen für DEVINFOREC (Übergabe aus Datei)
DATA: x_i_dvmint TYPE /adesso/mt_emg_devmod_int.
DATA: x_i_dvmdev TYPE /adesso/mt_reg42_dev.
DATA: x_i_dvmdfl TYPE /adesso/mt_reg42_dev_input_flg.
DATA: x_i_dvmreg TYPE /adesso/mt_reg42_zw.
DATA: x_i_dvmrfl TYPE /adesso/mt_reg42_zw_input_flag.


*------------------------------------------------
* Datendeklaration für Belade-FUBA DEVICEREL
DATA: oldkey_dvr LIKE /adesso/mt_transfer-oldkey.

DATA  i_dvr_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.


* interne Tabellen für DEVICEREL (Weiterverarbeitung)
DATA: i_int TYPE emg_devrel_int OCCURS 0 WITH HEADER LINE.
*data: i_dev type reg72_d occurs 0 with header line.
DATA: i_reg TYPE reg72_r OCCURS 0 WITH HEADER LINE.


* interne Strukturen für DEVICEREL (Übergabe aus Datei)
DATA: x_i_int TYPE /adesso/mt_emg_devrel_int.
DATA: x_i_reg TYPE /adesso/mt_reg72_r.

*----------------------------------------------------------------------
* Datendeklaration für Belade-FUBA INSTLNCHA
DATA: oldkey_icn LIKE /adesso/mt_transfer-oldkey.

DATA  i_icn_down LIKE /adesso/mt_down_mig_obj OCCURS 0 WITH HEADER LINE.

* interne Strukturen für INSTLNCHA (Übergabe aus Datei)
DATA: x_icn_key    TYPE /adesso/mt_eanlhkey.
DATA: x_icn_data   TYPE /adesso/mt_emg_eanl.
DATA: x_icn_rcat   TYPE /adesso/mt_isu_aittyp.
DATA: x_icn_pod    TYPE /adesso/mt_eui_ext_obj_auto.

* interne Tabellen für INSTLNCHA (Weiterverarbeitung)
DATA: icn_key    TYPE eanlhkey           OCCURS 0 WITH HEADER LINE.
DATA: icn_data   TYPE emg_eanl           OCCURS 0 WITH HEADER LINE.
DATA: icn_rcat   TYPE isu_aittyp         OCCURS 0 WITH HEADER LINE.
DATA: icn_key2    TYPE eanlhkey           OCCURS 0 WITH HEADER LINE.
DATA: icn_data2   TYPE emg_eanl           OCCURS 0 WITH HEADER LINE.
DATA: icn_rcat2   TYPE isu_aittyp         OCCURS 0 WITH HEADER LINE.
DATA: icn_pod    TYPE eui_ext_obj_auto   OCCURS 0 WITH HEADER LINE.
