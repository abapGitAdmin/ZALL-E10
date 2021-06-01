FUNCTION-POOL /adesso/invoic_endkunde.      "MESSAGE-ID ..
*
** INCLUDE /ADESSO/LINVOIC_ENDKUNDED...       " Local class definition
*
**** Änderungshistorie:
** Datum        Benutzer   Name       Grund
** Beschreibung der Änderung
** --------------------------------------------------------------------
**
** --------------------------------------------------------------------
*
** eigene Datendefinitionen
**DATA:   gt_zeidxc_clerk TYPE TABLE OF zeidxc_clerk.
*
*DATA: badi_obj TYPE REF TO if_ex_isu_ide_datexconnect.
*
*CONSTANTS: gc_disc_qual_z01         TYPE char3 VALUE 'Z01',
**           gc_unb_codelist_agency_dvgw  TYPE char3        VALUE '502',
**           gc_sap_codelist_agency_dvgw  TYPE e_edmideextcodelistid VALUE '332',
*           gc_bukrs_eav             TYPE bukrs  VALUE '0901',     "Buchungskreis Avacon
*           gc_bukrs_edi             TYPE bukrs  VALUE '1101',     "Buchungskreis Edis
*           gc_bgm_reversal_debit(3) TYPE c  VALUE '457',  "Storno für Belastung
*           gc_imd_abs(3)            TYPE c  VALUE 'ABS',  "Abschlagsrechnung
*           gc_imd_wim(3)            TYPE c  VALUE 'WIM',  "WIM
*           gc_rff_ace(3)            TYPE c  VALUE 'ACE',  "Qualifier ACE
*           gc_msg_program(8)        VALUE 'ECOMEV11',
*           gc_rff_z13(3)            TYPE c  VALUE 'Z13',
*           gc_disc_qual_en          TYPE char3 VALUE 'EN',
*           lc_gas_anlart_kom        TYPE anlart VALUE 'GKOX'..
*
** --- type pools
**TYPE-POOLS: sscr.
*TYPE-POOLS: isu21, eemsg.
*
** --- types
*TYPES: BEGIN OF tax_struc_in,
*         detail_rate TYPE e1vdewtax-detail_rate,
*         taxbw       TYPE bapi_inv_line-taxbw,
*         sbasw       TYPE bapi_inv_line-sbasw,
*         sbasw_gross TYPE bapi_inv_line-sbasw_gross,
*       END OF tax_struc_in.
*SET EXTENDED CHECK OFF.
*
*TYPES:     BEGIN OF tax_struc_out,
*             taxlinetype      TYPE char_02,
*             mwskz            TYPE mwskz,
*             "stprz       TYPE steuersatz,                  "#08
*             taxrate_internal TYPE stprz_kk,                "#08
*             sbetw            TYPE sbetw_kk,
*             sbasw            TYPE sbasw_kk,
*             sbasw_gross      TYPE sbasw_kk,
*           END OF tax_struc_out.
*
** --- class definitions
*CLASS: cl_inv_inv_remadv_doc DEFINITION LOAD,
*       cl_inv_inv_remadv_log DEFINITION LOAD.
*
** --- includes
*INCLUDE:
*  ieabelzart,
*  iee_inv_constants_linetype,
*  iecclog,
*  iecclog1,
*  ieide_events,
*  ie00flag,
*  emsg,
*  ieidoc_constants_vdew,
*  iinvoice_line_content,
*  iee_inv_constants_cust,
*  iee_inv_constants_serident,
*  iinvoice_ident_type,
*  ieupdmod,
*  iinvoice_partner_type.
*
*"Begin of insert
** --- structures
*DATA: una      TYPE /idexge/e1vdewuna_1,
*      unb      TYPE /isidex/e1vdewunb_1,
*      unh      TYPE /isidex/e1vdewunh_1,
*      bgm      TYPE /isidex/e1vdewbgm_1,
*      dtm      TYPE /isidex/e1vdewdtm_1,
*      dtm3     TYPE /isidex/e1vdewdtm_3,
*      dtm5     TYPE /isidex/e1vdewdtm_5,
*      imd      TYPE /idexge/e1vdewimd_2,
*      ftx      TYPE /idexge/e1vdewftx_3,
*      rff1     TYPE /idexge/e1vdewrff_11,
*      nad      TYPE /isidex/e1vdewnad_3,
*      loc      TYPE /idexge/e1vdewloc_4,
*      loc1     TYPE /idexge/e1vdewloc_4,
*      fii      TYPE /idexge/e1vdewfii_2,
*      rff2     TYPE  /idexge/e1vdewrff_12,
*      cux      TYPE /isidex/e1vdewcux_1,
*      pyt1     TYPE /isidex/e1vdewpyt_1,
*      lin      TYPE /isidex/e1vdewlin_1,
*      qty      TYPE /idexge/e1vdewqty_3,
*      moa      TYPE /isidex/e1vdewmoa_1,
*      pri      TYPE /isidex/e1vdewpri_1,
*      rff3     TYPE /idexge/e1vdewrff_13,
*      tax      TYPE /isidex/e1vdewtax_2,
*      alc      TYPE /idexge/e1vdewalc_1,
*      pcd      TYPE /idexge/e1vdewpcd_1,
*      moa2     TYPE /isidex/e1vdewmoa_2,
*      moa3     TYPE /isidex/e1vdewmoa_3,
*      tax2     TYPE /isidex/e1vdewtax_3,
*      moa4     TYPE /isidex/e1vdewmoa_4,
*      unt      TYPE /isidex/e1vdewunt_1,
*      unz      TYPE /isidex/e1vdewunz_1,
*      com_sg12 TYPE /isidex/e1vdewcom_1,
*      cta_sg12 TYPE /isidex/e1vdewcta_1,
*      dtm_imd  TYPE /isidex/e1vdewdtm_3,
*      dtm_rff  TYPE /isidex/e1vdewdtm_2,
*      fii_sg11 TYPE /idexge/e1vdewfii_2,
*      moa_sg34 TYPE /isidex/e1vdewmoa_2,
*      moa_sg50 TYPE /isidex/e1vdewmoa_3,
*      moa_sg52 TYPE /isidex/e1vdewmoa_4,
*      rff      TYPE /idexge/e1vdewrff_11,
*      rff_sg5  TYPE /idexge/e1vdewrff_12,
*      rff_sg30 TYPE /idexge/e1vdewrff_13,
*      tax_sg52 TYPE /isidex/e1vdewtax_3,
*      uns      TYPE /isidex/e1vdewuns_1.
*
*SET EXTENDED CHECK OFF.
** --- constants
*CONSTANTS: co_message_release_invoic_2(3) TYPE c VALUE '06A',
*           co_seg_vdew_una1               TYPE edilsegtyp VALUE '/IDEXGE/E1VDEWUNA_1',
*           co_seg_vdew_unb1               TYPE edilsegtyp VALUE '/ISIDEX/E1VDEWUNB_1',
*           co_seg_vdew_unh1               TYPE edilsegtyp VALUE '/ISIDEX/E1VDEWUNH_1',
*           co_seg_vdew_bgm1               TYPE edilsegtyp VALUE '/ISIDEX/E1VDEWBGM_1',
*           co_seg_vdew_dtm1               TYPE edilsegtyp VALUE '/ISIDEX/E1VDEWDTM_1',
*           co_seg_vdew_imd1               TYPE edilsegtyp VALUE '/IDEXGE/E1VDEWIMD_2',
*           co_seg_vdew_ftx                TYPE edilsegtyp VALUE '/IDEXGE/E1VDEWFTX_3',
*           co_seg_vdew_rff4               TYPE edilsegtyp VALUE '/IDEXGE/E1VDEWRFF_11',
*           co_seg_vdew_dtm2               TYPE edilsegtyp VALUE '/ISIDEX/E1VDEWDTM_2',
*           co_seg_vdew_nad3               TYPE edilsegtyp VALUE '/ISIDEX/E1VDEWNAD_3',
*           co_seg_vdew_loc2               TYPE edilsegtyp VALUE '/IDEXGE/E1VDEWLOC_4',
*           co_seg_vdew_fii1               TYPE edilsegtyp VALUE '/IDEXGE/E1VDEWFII_2',
*           co_seg_vdew_rff5               TYPE edilsegtyp VALUE '/IDEXGE/E1VDEWRFF_12',
*           co_seg_vdew_cta1               TYPE edilsegtyp VALUE '/ISIDEX/E1VDEWCTA_1',
*           co_seg_vdew_com1               TYPE edilsegtyp VALUE '/ISIDEX/E1VDEWCOM_1',
*           co_seg_vdew_cux1               TYPE edilsegtyp VALUE '/ISIDEX/E1VDEWCUX_1',
*           co_seg_vdew_pyt1               TYPE edilsegtyp VALUE '/ISIDEX/E1VDEWPYT_1',
*           co_seg_vdew_dtm3               TYPE edilsegtyp VALUE '/ISIDEX/E1VDEWDTM_3',
*           co_seg_vdew_lin1               TYPE edilsegtyp VALUE '/ISIDEX/E1VDEWLIN_1',
*           co_seg_vdew_qty2               TYPE edilsegtyp VALUE '/IDEXGE/E1VDEWQTY_3',
*           co_seg_vdew_dtm5               TYPE edilsegtyp VALUE '/ISIDEX/E1VDEWDTM_5',
*           co_seg_vdew_moa1               TYPE edilsegtyp VALUE '/ISIDEX/E1VDEWMOA_1',
*           co_seg_vdew_pri1               TYPE edilsegtyp VALUE '/ISIDEX/E1VDEWPRI_1',
*           co_seg_vdew_rff6               TYPE edilsegtyp VALUE '/IDEXGE/E1VDEWRFF_13',
*           co_seg_vdew_tax2               TYPE edilsegtyp VALUE '/ISIDEX/E1VDEWTAX_2',
*           co_seg_vdew_moa2               TYPE edilsegtyp VALUE '/ISIDEX/E1VDEWMOA_2',
*           co_seg_vdew_alc1               TYPE edilsegtyp VALUE '/IDEXGE/E1VDEWALC_1',
*           co_seg_vdew_pcd1               TYPE edilsegtyp VALUE '/IDEXGE/E1VDEWPCD_1',
*           co_seg_vdew_uns1               TYPE edilsegtyp VALUE '/ISIDEX/E1VDEWUNS_1',
*           co_seg_vdew_moa3               TYPE edilsegtyp VALUE '/ISIDEX/E1VDEWMOA_3',
*           co_seg_vdew_tax3               TYPE edilsegtyp VALUE '/ISIDEX/E1VDEWTAX_3',
*           co_seg_vdew_moa4               TYPE edilsegtyp VALUE '/ISIDEX/E1VDEWMOA_4',
*           co_seg_vdew_unt1               TYPE edilsegtyp VALUE '/ISIDEX/E1VDEWUNT_1',
*           co_seg_vdew_unz1               TYPE edilsegtyp VALUE '/ISIDEX/E1VDEWUNZ_1',
*           co_function_vdew_invoic_in     TYPE rs38l_fnam VALUE 'ISU_COMEV_INVOIC_2_IN',
*           co_len_zipcode(11)             TYPE c          VALUE 'LEN_ZIPCODE',
*           co_loc_vdew_agency(3)          TYPE c          VALUE '89',
*           co_assigned_code_vdew          TYPE char6      VALUE '2.5',
*           co_exit_name_invoic_out        TYPE exit_def   VALUE 'ISU_VDEW_INVOIC_OUT',
*           co_lin_resp_ag_sender(3)       TYPE c          VALUE '86 ',
*           co_space                       TYPE c          VALUE ' ',
*           co_isu_invoic_vdew             TYPE edi_idoctp VALUE 'ZEIDE_ISU_INVOIC_V24',
*           co_isu_bill_list               TYPE edi_mestyp VALUE 'ISU_BILL_LIST_INFORMATION',
*           co_isu_syntax_version          TYPE i          VALUE '3',
*           co_isu_syntax_ident            TYPE char4      VALUE 'UNOC',
*           co_ergrd_consumption_billing   TYPE ergrd      VALUE '01',
*           co_ergrd_budget_billing        TYPE ergrd      VALUE '02',
*           co_ergrd_reversal_bill         TYPE ergrd      VALUE '04',
*           co_ergrd_budget_billing_ch     TYPE ergrd      VALUE '07',
*           co_int_billing                 TYPE abrvorg    VALUE '02',
*           co_end_billing                 TYPE abrvorg    VALUE '03',
*           co_period_end_billing          TYPE abrvorg    VALUE '04',
*           co_service_territory_transfer  TYPE abrvorg   VALUE '05',
*           co_manual_credit_memo          TYPE abrvorg    VALUE '06',
*           co_contract_change             TYPE abrvorg    VALUE '07',
*           co_cust_change                 TYPE abrvorg    VALUE '08',
*           co_belzart_bbppay              TYPE erdz-belzart VALUE 'BBPPAY',
*           co_belzart_subt                TYPE erdz-belzart VALUE 'SUBT',
*           co_rff_fiscal_code(3)          TYPE c            VALUE 'FC ',
*           co_party_fiscal_code           TYPE party        VALUE 'SAP011',
*           co_isu_part_type_vdew          TYPE char4        VALUE '500',
*           co_erdz_timtype_month          TYPE char1        VALUE '1',
*           co_erdz_timtype_day            TYPE char1        VALUE '2',
*           co_cta_contactfunc(3)          TYPE c            VALUE 'IC',
*           co_una_group_separator         TYPE char1        VALUE ':',
*           co_una_dataelement_separator   TYPE char1        VALUE '+',
**<<< #01: SAP Hinweis 1227567 : Dezimaltrennzeichen von ',' -> '.'
*           "co_una_decimal_sequence         TYPE char1      VALUE ',',
*           co_una_decimal_sequence        TYPE char1      VALUE '.',
**>>> #01
*           co_una_escape_sequence         TYPE char1        VALUE '?',
*           co_una_reserved                TYPE char1        VALUE ' ',
*           co_una_end_of_segment          TYPE char1        VALUE '''',
*           co_rabtyp_disc                 TYPE rabtyp       VALUE '1',
*           co_rabtyp_surcharge            TYPE rabtyp       VALUE '2',
*           co_qualifier_allowance(3)      TYPE c            VALUE 'A',
*           co_qualifier_charge(3)         TYPE c            VALUE 'C',
*           co_rabart_perc                 TYPE c            VALUE '2',
*           co_qaulifier_perctype(3)       TYPE c            VALUE '3',
*           co_moa_amount_totaldisc(3)     TYPE c            VALUE '131',
*           co_credentials(3)              TYPE c            VALUE 'REG',
*           co_subsequent_use(1)           TYPE c            VALUE '1',
*           co_reverse_charge(3)           TYPE c            VALUE 'RCH',
*           co_tax_category_o(3)           TYPE c            VALUE 'O  ',
*           co_tax_category_ae(3)          TYPE c            VALUE 'AE ',
*           co_imd_bill_month_sonder(3)    TYPE c            VALUE '13I'.
*
*CONSTANTS:
*  co_person       TYPE bu_type      VALUE '1',
*  co_organization TYPE bu_type      VALUE '2',
*  gc_sdata(3)     TYPE c            VALUE '380',
*  co_group        TYPE bu_type      VALUE '3'.
*SET EXTENDED CHECK ON.
*
** --- Badi
*DATA:
*      badi_isu_invoic_out  TYPE REF TO /idexge/invoic_out.
*
** --- data
*DATA:  exit_isu_vdew_invoic_in TYPE REF TO if_ex_isu_vdew_invoic_in.
*
*DATA: len_zipcode TYPE i.
*
** idoc control
*DATA: idoc_line       TYPE edidd,
*      idoc_data       TYPE STANDARD TABLE OF edidd,
*      idoc_control    TYPE edidc,
*      gs_idoc_data    TYPE edidd,
*      gv_sdata(3)     TYPE c,
*      idoc_comcontrol TYPE STANDARD TABLE OF edidc.
*
** message
*DATA: last_msg         TYPE eemsg_msg_single.
*
** Number of segments
*DATA: seg_count       TYPE p.
*
** Own sy-subrc
*DATA: my_sysubrc TYPE sy-subrc.
*
*** -> global variables for gas
*DATA: gv_division_category TYPE spartyp.
** Tax free sum
*DATA: gv_tax_free_sum       TYPE nettobtr.
*
** macro to fill segments
*DEFINE mac_seg_append.
*  clear idoc_line.
*  idoc_line-segnam = &1.
*  idoc_line-sdata  = &2.
*  append idoc_line to idoc_data.
*  add 1 to seg_count.
*  clear &2.
*END-OF-DEFINITION.
*
*DEFINE switch_log_off.
**   switch Applicationlog off
*  call function 'MSG_ACTION'
*    exporting
*      x_action = co_msg_log_off.
*END-OF-DEFINITION.
*DEFINE switch_log_on.
**   switch Applicationlog on
*  call function 'MSG_ACTION'
*    exporting
*      x_action = co_msg_log_on.
*END-OF-DEFINITION.
