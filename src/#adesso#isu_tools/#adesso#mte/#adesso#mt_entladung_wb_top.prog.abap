*&---------------------------------------------------------------------*
*&  Include           /ADESSO/MT_ENTLADUNG_WB_TOP
*&---------------------------------------------------------------------*

*---------------------------------------------------------------------
* Datendeklaration
*---------------------------------------------------------------------
TABLES: /adesso/mte_rel,
        /adesso/mte_htge,
        eanl,
        elpass,
        stxh.


DATA ent_file TYPE emg_pfad.

DATA: imeldung LIKE /adesso/mt_messages OCCURS 0 WITH HEADER LINE.
DATA: imig_err LIKE /adesso/mte_err OCCURS 0 WITH HEADER LINE.
DATA: iht_ger LIKE /adesso/mte_htge OCCURS 0 WITH HEADER LINE.
DATA: iht_gerh LIKE /adesso/mte_htge OCCURS 0 WITH HEADER LINE.
DATA: iht_gerw LIKE /adesso/mte_htge OCCURS 0 WITH HEADER LINE.
DATA: iht_gern LIKE /adesso/mte_htge OCCURS 0 WITH HEADER LINE.
DATA: iht_ger_met LIKE /adesso/mte_htge OCCURS 0 WITH HEADER LINE.
DATA: iht_ger_drt LIKE /adesso/mte_htge OCCURS 0 WITH HEADER LINE.

DATA: counter   TYPE i.
DATA: cnt_exp_file  TYPE i.
DATA: num_exp_file(2) TYPE n VALUE '01'.
DATA: cnt_index TYPE i.

DATA: anz_obj TYPE i.
DATA: anz_par TYPE i.
DATA: anz_con TYPE i.
DATA: anz_pre TYPE i.
DATA: anz_dlc TYPE i.
DATA: anz_pno TYPE i.
DATA: anz_noc TYPE i.
DATA: anz_nod TYPE i.
DATA: anz_dev TYPE i.
DATA: anz_ins TYPE i.
DATA: anz_ich TYPE i.
data: anz_inn type i.
data: anz_icn type i.
DATA: anz_fac TYPE i.
DATA: anz_acc TYPE i.
DATA: anz_acs TYPE i.
DATA: anz_rva TYPE i.
DATA: anz_acn TYPE i.
DATA: anz_moi TYPE i.
DATA: anz_bct TYPE i.
DATA: anz_bcn TYPE i.
DATA: anz_bpm TYPE i.
DATA: anz_pay TYPE i.
DATA: anz_doc TYPE i.
DATA: anz_ipl TYPE i.
DATA: anz_inm TYPE i.
DATA: anz_mrd TYPE i.
DATA: anz_srt TYPE i.
DATA: anz_pos TYPE i.
DATA: anz_drt TYPE i.
DATA: anz_lop TYPE i.
DATA: anz_cno TYPE i.
DATA: anz_ht_upd TYPE i.
DATA: anz_dno TYPE i.
DATA: anz_dcd TYPE i.
DATA: anz_dco TYPE i.
DATA: anz_dce TYPE i.
DATA: anz_dcr TYPE i.
DATA: anz_dcm TYPE i.
DATA: anz_dgr TYPE i.
DATA: anz_dir TYPE i.
DATA: anz_moh TYPE i.
DATA: anz_moo TYPE i.


* Weitere Zähler
DATA: anz_init     TYPE i.
DATA: anz_ekun     TYPE i.
DATA: anz_but000   TYPE i.
DATA: anz_buticom  TYPE i.
DATA: anz_but001   TYPE i.
DATA: anz_but0bk   TYPE i.
DATA: anz_but020   TYPE i.
DATA: anz_but021   TYPE i.
DATA: anz_but0cc   TYPE i.
DATA: anz_shipto   TYPE i.
DATA: anz_taxnum   TYPE i.
DATA: anz_eccard   TYPE i.
DATA: anz_eccardh  TYPE i.
DATA: anz_but0is   TYPE i.


DATA: anz_vk_init TYPE i.
DATA: anz_vk      TYPE i.
DATA: anz_vkp     TYPE i.
DATA: anz_vklock  TYPE i.
DATA: anz_vkcorr  TYPE i.
DATA: anz_vktaxex TYPE i.

DATA: anz_eabp TYPE  i.
DATA: anz_eabpv TYPE i.
DATA: anz_eabps TYPE i.
DATA: anz_ejvl  TYPE i.

DATA: anz_bcontd TYPE i.
DATA: anz_iobjects TYPE i.
DATA: anz_key    TYPE i.
DATA: anz_tline   TYPE i.
DATA: anz_konv    TYPE i.

DATA: anz_ehaud   TYPE i.
DATA: anz_addr_data TYPE i.
DATA: anz_addr_comm_data TYPE i.

DATA: anz_data   TYPE i.
DATA: anz_rcat   TYPE i.
DATA: anz_pod    TYPE i.

DATA: anz_interface TYPE i.
DATA: anz_auto_zw TYPE i.
DATA: anz_auto_ger TYPE i.
DATA: anz_container TYPE i.

DATA: anz_ieablu TYPE i.

DATA: anz_everd TYPE i.

DATA: anz_eausd   TYPE i.
DATA: anz_eausvd  TYPE i.

DATA: anz_evbsd   TYPE i.




DATA: i_partner LIKE but000-partner OCCURS 0 WITH HEADER LINE.
DATA: icon_haus LIKE ehauisu-haus   OCCURS 0 WITH HEADER LINE.
DATA: inoc_haus LIKE ehauisu-haus   OCCURS 0 WITH HEADER LINE.
DATA: i_vstelle LIKE evbs-vstelle   OCCURS 0 WITH HEADER LINE.
DATA: i_devloc  LIKE egpl-devloc    OCCURS 0 WITH HEADER LINE.
DATA: inod_devloc  LIKE egpl-devloc    OCCURS 0 WITH HEADER LINE.
DATA: idev_equnr  LIKE equi-equnr    OCCURS 0 WITH HEADER LINE.
DATA: idir_equnr LIKE egerr-equnr OCCURS 0 WITH HEADER LINE.
DATA: iacc_vkont  LIKE fkkvk-vkont    OCCURS 0 WITH HEADER LINE.
DATA: iacs_vkont  LIKE fkkvk-vkont    OCCURS 0 WITH HEADER LINE.
DATA: iacn_vkont  LIKE fkkvk-vkont    OCCURS 0 WITH HEADER LINE.
DATA: ins_anlage  LIKE eanl-anlage    OCCURS 0 WITH HEADER LINE.
DATA: ifac_anlage  LIKE eanl-anlage    OCCURS 0 WITH HEADER LINE.
DATA: ich_anlage  LIKE eanl-anlage    OCCURS 0 WITH HEADER LINE.
data: inn_anlage  like eanl-anlage    occurs 0 with header line.
DATA: icn_anlage  LIKE eanl-anlage    OCCURS 0 WITH HEADER LINE.
DATA: irva_anlage  LIKE eanl-anlage    OCCURS 0 WITH HEADER LINE.
DATA: imoi_vertrag LIKE ever-vertrag    OCCURS 0 WITH HEADER LINE.
DATA: imoi_vertragl LIKE ever-vertrag  OCCURS 0 WITH HEADER LINE.
DATA: imoh_vertrag LIKE ever-vertrag OCCURS 0 WITH HEADER LINE.
DATA: imoo_vertrag  LIKE eausv-vertrag OCCURS 0 WITH HEADER LINE.
DATA: ibpm_abplan LIKE eabp-opbel    OCCURS 0 WITH HEADER LINE.
DATA: ipay_abplan LIKE eabp-opbel    OCCURS 0 WITH HEADER LINE.
DATA: idoc_vkont  LIKE fkkvk-vkont    OCCURS 0 WITH HEADER LINE.
DATA: ibct_bpcontact LIKE bcont-bpcontact OCCURS 0 WITH HEADER LINE.
DATA: ibcn_bpcontact LIKE bcont-bpcontact OCCURS 0 WITH HEADER LINE.
DATA: ipl_vkont  LIKE fkkvk-vkont    OCCURS 0 WITH HEADER LINE.
DATA: ipno_partner LIKE but000-partner OCCURS 0 WITH HEADER LINE.
DATA: inm_anlage  LIKE eanl-anlage    OCCURS 0 WITH HEADER LINE.
DATA: ilop_anlage  LIKE eanl-anlage    OCCURS 0 WITH HEADER LINE.
DATA: icno_haus LIKE ehauisu-haus   OCCURS 0 WITH HEADER LINE.
DATA: ipos_anlage  LIKE eanl-anlage    OCCURS 0 WITH HEADER LINE.
DATA: isrt_anlage  LIKE eanl-anlage    OCCURS 0 WITH HEADER LINE.
DATA: isrt_ableinh  LIKE eanlh-ableinh    OCCURS 0 WITH HEADER LINE.
DATA: idno_devloc  LIKE egpl-devloc    OCCURS 0 WITH HEADER LINE.
DATA: iediscdoc  LIKE ediscdoc    OCCURS 0 WITH HEADER LINE.
DATA: idgr_devgrp  LIKE edevgr-devgrp    OCCURS 0 WITH HEADER LINE.

DATA: iegerh2 LIKE egerh OCCURS 0 WITH HEADER LINE.

DATA: data_equnr         LIKE  /adesso/mte_rel-obj_key.


DATA: BEGIN OF inm_anlage_s OCCURS 0,
        anlage LIKE eanl-anlage,
        sparte LIKE eanl-sparte,
      END OF inm_anlage_s.

DATA: jvl_file TYPE emg_pfad  VALUE 'PAYMENTJVL'.

* Zähler: Keine Adresse vorhanden (Umschlüsselung Ableseeinheiten)
DATA: count_no_adress TYPE i.
* Zähler: Keine Umschlüsselung vorhanden (Umschlüsselung Ableseeinheiten)
DATA: count_no_key    TYPE i.
