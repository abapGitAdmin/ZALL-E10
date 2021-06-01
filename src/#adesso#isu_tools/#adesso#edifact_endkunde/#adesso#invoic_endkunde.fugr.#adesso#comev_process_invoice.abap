**FUNCTION /adesso/comev_process_invoice.
***"----------------------------------------------------------------------
***"*"Lokale Schnittstelle:
***"  IMPORTING
***"     REFERENCE(X_INVOICE) TYPE  ISU21_PRINT_DOC
***"     REFERENCE(X_ERCH) TYPE  ERCH
***"     REFERENCE(X_EVER) TYPE  EVER
***"     REFERENCE(X_REVERSE) TYPE  KENNZX
***"     REFERENCE(X_INT_UI) TYPE  INT_UI
***"     REFERENCE(X_CROSSREFNO) TYPE  CROSSREFNO
***"     REFERENCE(X_VKONT_AGG) TYPE  E_EDMIDEVKONT_AGGBILL
***"     REFERENCE(X_SENDER) TYPE  SERVICE_PROV
***"     REFERENCE(X_RECEIVER) TYPE  SERVICE_PROV
***"  EXPORTING
***"     REFERENCE(Y_IDOC_DATA) TYPE  EDEX_IDOCDATA
***"  EXCEPTIONS
***"      GENERAL_FAULT
***"----------------------------------------------------------------------
**
**  CONSTANTS: "lc_sprache                   TYPE spras                                  VALUE 'D',
***             lc_trennz                    TYPE char1                                  VALUE ';',
***             lc_basicproc                 TYPE e_dexbasicproc                         VALUE 'INV_OUT', "INVOICE out
**             lc_com_mobil                 TYPE char3                                  VALUE 'AL ',     "COM Qualif. f. Handy
**             lc_qty_time                  TYPE /idexge/e1vdewqty_3-quantity_qualifier VALUE '136',
***             lc_product_cr171             TYPE inv_product_id                         VALUE '8888888888888',
***             lc_product_id_leistung(13)   TYPE c                                      VALUE '4044038000058',    "Leistung
***             lc_product_id_mum(13)        TYPE c                                      VALUE '4044038000577',    "Mehr-/Mindermenge,
***             lc_product_id_sperr(13)      TYPE c                                      VALUE '4044038000546',    "Sperrkosten,
***             lc_product_id_entsperr(13)   TYPE c                                      VALUE '4044038000553',    "Entsperrkosten,
***             lc_product_id_inkas(13)      TYPE c                                      VALUE '4044038000584',    "Inkasso,
***             lc_product_id_mahn(13)       TYPE c                                      VALUE '4044038000560',    "Mahnkosten
***             lc_qty                       TYPE char35                                 VALUE '1',
**             lc_rff_tax_fc(3)             TYPE c                                      VALUE 'FC '.
***             lc_product_id_wirkarbeit(13) TYPE c                                      VALUE '4044038000447',    "Wirkarbeit Vertrieb
***             lc_zformular_ust_text        TYPE text80                                 VALUE 'Steuerschuldnerschaft des Leistungsempfängers / Reverse Charge'.
**
**  CONSTANTS  lc_version    TYPE rvari_vnam   VALUE 'VDEW_VERSNR_INVOIC'.
**
**  FIELD-SYMBOLS: <ecrossrefno> TYPE ecrossrefno,
**                 <erdb>        TYPE erdb,
**                 <erdbbpreq>   TYPE erdbbpreq.
**
**  DATA: lv_ausfdatum             TYPE                   /adesso/ausfdatum,
**        lv_adatum_exist          TYPE                   flag,
**        ls_clerk_data            TYPE                   zeidxc_clerk, "Name + Komm.daten Sachbearbeiter
**        lv_subrc                 TYPE                   sysubrc,
**        ls_com                   TYPE                   /isidex/e1vdewcom_1,
**        ls_cta                   TYPE                   /isidex/e1vdewcta_1,
**        ls_crossref              TYPE                   ecrossrefno,
**        lv_opbel_crossref        TYPE                   crossrefno,
**        lt_erdz_alc              TYPE                   erdz_tab,              "Tabelle mit Rabattzeilen
**        ls_erdz_alc              TYPE                   erdz,
**        ls_storno                TYPE                   kennzx,
**        lv_x_foreign_suppl       TYPE                   boole_d,        "ausländischer Lieferant
**        lv_no_lin                TYPE                   boole_d,             "Flag: kein LIN Segment vorhanden
**        lv_partner_id            TYPE                   bu_partner,          "Geschäftspartner Nummer
**        lv_x_lin_suppr           TYPE                   boole_d,             "Flag: suppress LIN segment
**        lv_lin_curr              TYPE                   p,                   "counter for current LIN
**        lv_x_qty_47_pcs          TYPE                   boole_d,  "Flag: 2. QTY mit PCS bei Zeitanteil in Abrechnungsmenge
**        ls_qty_pcs               TYPE                   /idexge/e1vdewqty_3, "QTY mit Qual. 47 und Einheit PCS
**        lv_x_bud_bill            TYPE                   boole_d,             "Abschlag: add QTY & PRI
**        ls_pri_2                 TYPE                   /isidex/e1vdewpri_1, "PRI für Abschlagsrechnung
**        lv_x_cr171               TYPE                   boole_d,   "Flag: cancel of old invoice incl. payed Budget Billing amount
**        lv_bb_amnt               TYPE                   betrw_kk,            "budget billing amount
**        lv_x_cr171_bb_ok         TYPE                   boole_d, " Flag: Budget Billing amount was processed for CR171
**        lv_cr171_bbpay_gross     TYPE                   betrw_kk,      "CR171: payed budget billing amounts
**        lv_switch_stat           TYPE                   sfw_switchpos,       "state of switch in SFW
**        lv_x_reverse             TYPE                   kennzx,              "flag reverse: for manual created invoice
**        lv_reg_cess_yes          TYPE                   boole_d,           "flag: install. is involved in region cession
**        lv_bgm_doc_no            TYPE                   crossrefno,              "#28
**        lv_externalid_sender     TYPE                   eservprov-externalid,
**        lv_externalid_receiver   TYPE                   eservprov-externalid,
**        lv_quantity(35)          TYPE                   c,
**        lv_zero(3)               TYPE                   c                                   VALUE '0.0',
**        lv_documentnumber        TYPE                   zeided_docnum,
**        lv_refno                 TYPE                   char14,
**        lv_externalid            TYPE                   dunsnr,
**        v_lin_nr                 TYPE                   char6,
**        v_tel_number_tmp         TYPE                   ad_tlnmbr1,
**        v_nettobtr               TYPE                   nettobtr,
**        v_total_gross_sum        TYPE                   sbetw_kk,
**        v_total_net_sum          TYPE                   sbetw_kk,
**        v_bill_gross_sum         TYPE                   betrw_kk,
**        v_bill_net_sum           TYPE                   nettobtr,
**        v_bb_gross_sum           TYPE                   betrw_kk,
**        v_bb_net_sum             TYPE                   nettobtr,
**        v_ext_ui                 TYPE                   ext_ui,
**        v_refno                  TYPE                   char12,
**        v_iso_waers              TYPE                   tcurc-isocd,
**        v_te420                  TYPE                   te420,
**        v_etdz                   TYPE                   etdz,
**        v_product_id             TYPE                   inv_product_id,
**        v_product_id_type        TYPE                   inv_product_id_type,
**        v_abrmenge               TYPE                   char31,
**        v_i_abrmenge             TYPE                   erdz-i_abrmenge,
**        v_massbill               TYPE                   erdz-massbill,
**        v_sum_seg_only           TYPE                   kennzx,
**        v_ab                     TYPE                   erdz-ab,
**        v_bis                    TYPE                   erdz-bis,
**        v_subrc                  TYPE                   sysubrc,
**        h_hv_bbp_p               TYPE                   fkkop-hvorg,
**        h_hv_bbp_r               TYPE                   fkkop-hvorg,
**        h_tv_bbp_p               TYPE                   fkkop-tvorg,
**        h_tv_bbp_r               TYPE                   fkkop-tvorg,
**        h_sbasw_gross            TYPE                   sbasw_kk,
**        h_sbetw                  TYPE                   sbetw_kk,
**        h_bb_gross_sum           TYPE                   betrw_kk,
**        h_bb_tax_sum             TYPE                   sbetw_kk,
**        wa_dexidoc_data          TYPE                   edidd,
**        lt_dexidoc_data          TYPE                   edidd_tt,
**        lt_idoc_data             TYPE                   edex_idocdata,
**        wa_eservprov             TYPE                   eservprov,
**        wa_sender                TYPE                   service_prov_text,
**        wa_receiver              TYPE                   service_prov_text,
**        wa_sender_type           TYPE                   e_edmideextcodelistid,
**        wa_receiver_type         TYPE                   e_edmideextcodelistid,
**        wa_ergrd                 TYPE                   ergrd,
**        wa_org_erdk              TYPE                   erdk,
**        wa_idoc_control          TYPE                   edidc,
**        wa_erdz                  TYPE                   erdz,
**        wa_tax                   TYPE                   tax_struc_out,
**        wa_total_tax             TYPE                   tax_struc_out,
**        wa_bill_tax              TYPE                   tax_struc_out,
**        wa_bb_tax                TYPE                   tax_struc_out,
**        wa_bill_tax_sum          TYPE                   sbetw_kk,
**        wa_bb_tax_sum            TYPE                   sbetw_kk,
**        wa_total_tax_sum         TYPE                   sbetw_kk,
**        wa_tax_stprz             TYPE                   tax_struc_out,
**        wa_tax_sg52              TYPE                   /isidex/e1vdewtax_3,
**        it_erdz_summ             TYPE STANDARD TABLE OF erdz,
**        it_total_tax             TYPE STANDARD TABLE OF tax_struc_out,
**        it_bill_tax              TYPE STANDARD TABLE OF tax_struc_out,
**        it_bb_tax                TYPE STANDARD TABLE OF tax_struc_out,
**        exit_isu_vdew_invoic_out TYPE REF TO            if_ex_isu_vdew_invoic_out,
**        lv_xcrn                  TYPE                   e_xcrn                              VALUE '',
**        lv_mem_orig_refnum       TYPE                   /isidex/e1vdewbgm_1-documentnumber,
**        lt_ecrossrefno           TYPE                   iecrossrefno,
**        lv_intopbel              TYPE                   intopbel,
**        lv_intopbel_anz          TYPE                   string,
**        lv_taxrate_internal      TYPE                   stprz_kk,                "#08
**        lv_tax_free_sum          TYPE                   nettobtr,
**        lt_erdbbpreq             TYPE                   erdbbpreq_t,
**        lt_tax_stprz             TYPE          TABLE OF tax_struc_out,
**        lv_price                 TYPE                   inv_price,
**        lv_address               TYPE                   char512,
**        lv_address_type          TYPE                   /idexge/e_dexcontaddrtype,
**        lv_pos_netamount         TYPE                   nettobtr,
**        lv_totaldisc_netamount   TYPE                   nettobtr,
**        ls_discount_infos        TYPE                   /idexge/discount_infos,
**        lt_discount_infos        TYPE                   /idexge/tt_discount_infos,
**        lv_mr_bpart              TYPE                   eservprovp-bpart,
**        lv_kofiz                 TYPE                   fkkvkp-kofiz_sd,
**        lv_opbel                 TYPE                   erdk-opbel,
**        lv_bldat                 TYPE                   erdk-bldat,
**        lv_crossrefno            LIKE                   x_crossrefno,
**        ls_storn_erdk            TYPE                   erdk,
**        lv_datum_01              TYPE                   datum,
**        lv_docnum_01             TYPE                   zeided_docnum,
**        lv_index                 TYPE                   sy-tabix,
**        wa_tax_stprz_idx1        TYPE                   tax_struc_out,
**        wa_tax_stprz_idx2        TYPE                   tax_struc_out,
**        lv_qty                   TYPE                   p                                   DECIMALS 4,
**        lv_bgm_name              TYPE                   char3,
**        lv_zz_guid               TYPE                   zeided_guid,
**        lv_zz_zp_bezeich         TYPE                   zeided_zp_bezeich,
**        lv_int_ui                TYPE                   int_ui,
**        lv_logiknr               TYPE                   logiknr,
**        lv_anlage                TYPE                   anlage,
**        lv_anlage2               TYPE                   anlage,
**        lv_vkonto                TYPE                   vkont_kk,
**        lv_gpart                 TYPE                   gpart_kk,
**        lv_sparte                TYPE                   spart,
**        ls_fkkvkp                TYPE                   fkkvkp,
**        ls_erdz                  TYPE                   erdz,
**        ls_zeidet_edivar         TYPE                   zeidet_edivar,
**        lv_cust_status1          TYPE                   kennzx,
**        lv_cust_status2          TYPE                   kennzx,
**        lv_typ                   TYPE                   string,
**        lv_int_serident          TYPE                   int_serident,
**        lv_revchar_01            TYPE                   c,
**        lv_revchar_02            TYPE                   c,
**        lv_revchar_03            TYPE                   c,
**        ls_erdz_01               TYPE                   erdz,
**        lv_msgv1_01              TYPE                   symsgv,
**        lv_msgv2_01              TYPE                   symsgv,
**        lv_msgv3_01              TYPE                   symsgv,
**        lv_msgv4_01              TYPE                   symsgv,
**        lv_belzeile_01           TYPE                   belzeile,
**        lv_aklasse_01            TYPE                   aklasse,
**        ls_data_01               LIKE LINE OF           idoc_data,
**        lv_tabix_01              TYPE                   sy-tabix,
**        ls_tax_01                TYPE                   /isidex/e1vdewtax_3,
**        ls_moa_01                TYPE                   /isidex/e1vdewmoa_4,
**        lv_partner_01            TYPE                   bu_partner,
**        lv_vdew_versnr           TYPE                   zeided_vdew_versnr,
**        lv_name                  TYPE                   rvari_vnam,
**        ls_pi_map                TYPE                   zeidxc_pi_map,
**        lv_pruefind              TYPE                   zeidxd_pruef_id,
**        lv_bukrs_01              TYPE                   bukrs,
**        lv_text_01               TYPE                   text100,
**        lv_country               TYPE                   char3,
**        lt_vkdetails_01          TYPE TABLE OF          bapiisuvkp,
**        lt_vkdetails_02          TYPE TABLE OF          bapidfkklocks,
**        ls_return_01             TYPE                   bapiret2,
**        lv_faedn_01              TYPE                   facdate,
**        lv_faedn_02              TYPE                   scdatum,
**        ls_zformular_ust         TYPE                   zformular_ust,
**        ls_map_prod              TYPE                   zeidet_map_prod.
**
**
**  CLEAR idoc_data.
**
****- initialisierung Variablen
**  CLEAR:
**      gv_tax_free_sum,
**      seg_count.
**
*** Ermitteln der Aberchnungsklasse.
**  LOOP AT x_invoice-t_erdz INTO wa_erdz
**  WHERE aklasse EQ 'RLM' OR
**        aklasse EQ 'SLP'.
**
**    MOVE wa_erdz-aklasse TO lv_aklasse_01.
**
**    CLEAR: wa_erdz.
**
**    EXIT.
**
**  ENDLOOP.
**
**  IF sy-subrc NE 0.
**
**    SELECT SINGLE a~aklasse INTO lv_aklasse_01
**      FROM   eanlh      AS a INNER JOIN
**             euiinstln  AS b
**      ON     a~anlage   EQ b~anlage
**      WHERE  b~int_ui   EQ x_int_ui AND
**             a~bis      GE x_erch-endabrpe AND
**             a~ab       LE x_erch-endabrpe AND
**             b~dateto   GE x_erch-endabrpe AND
**             b~datefrom LE x_erch-endabrpe.
**
**    IF sy-subrc NE 0.
**
**      LOOP AT x_invoice-t_erdz INTO ls_erdz_01
**        WHERE belzart EQ co_belzart_subt AND
**              ab      NE '00000000' AND
**              bis     NE '00000000'.
**
**        SELECT SINGLE a~aklasse INTO lv_aklasse_01
**          FROM   eanlh      AS a INNER JOIN
**                 euiinstln  AS b
**          ON     a~anlage   EQ b~anlage
**          WHERE  b~int_ui   EQ x_int_ui AND
**                 a~bis      GE ls_erdz_01-bis AND
**                 a~ab       LE ls_erdz_01-bis AND
**                 b~dateto   GE ls_erdz_01-bis AND
**                 b~datefrom LE ls_erdz_01-bis.
**
**        IF sy-subrc NE 0.
***          Keine Aktion!
**        ENDIF.
**
**        EXIT.
**
**      ENDLOOP.
**
**    ENDIF.
**
**  ENDIF.
**
**  CLEAR: ls_erdz_01.
**
*** Prüfung ob Reverse-Charge-Verfahren hinterlegt ist.
**  IF NOT x_invoice-t_erdz IS INITIAL.
**
**    CLEAR: ls_erdz, ls_zformular_ust.
**
**    READ TABLE x_invoice-t_erdz INTO ls_erdz WITH KEY belzart = co_belzart_subt.
**
**    IF sy-subrc NE 0.
**      READ TABLE x_invoice-t_erdz INTO ls_erdz WITH KEY belzart = co_belzart_bbp.
**    ENDIF.
**
**    SELECT SINGLE * FROM zformular_ust
**          INTO ls_zformular_ust
**          WHERE mwskz = ls_erdz-mwskz
**          AND text =  lc_zformular_ust_text
**          AND ab <= sy-datum
**          AND bis >= sy-datum.
**
**    IF sy-subrc EQ 0.
**      MOVE 'X' TO lv_revchar_01.
**    ENDIF.
**
**  ENDIF.
**
**  PERFORM get_division_category
**          USING x_int_ui
**          CHANGING gv_division_category.
**
*** --- initialize badi
*** call badi
*** does exit handle already exist?
**  IF exit_isu_vdew_invoic_out IS INITIAL.
***   create exit handle
**    CALL METHOD cl_exithandler=>get_instance
**      EXPORTING
**        exit_name              = co_exit_name_invoic_out
**        null_instance_accepted = 'X'
**      CHANGING
**        instance               = exit_isu_vdew_invoic_out.
**  ENDIF.
**
*** --- UNH Header segment
*** --- unh-referencenumber will be filled from converter system
**
**  PERFORM get_unh_refno CHANGING v_refno.
**  MOVE v_refno   TO lv_refno.
**
*** Vertriebsgesellschaft vor UNH_REF packen
**  CALL FUNCTION 'Z_EIDE_BUILD_REFNR'
**    EXPORTING
**      iv_serviceid = x_sender
**      iv_refnr_old = lv_refno
**    IMPORTING
**      ev_refnr_new = lv_refno.
***--Version number change
**  lv_name = lc_version.
***--Call the method to get the Version
**  TRY.
**      CALL METHOD zcl_eide_tools_tvarv=>get_tvar_param
**        EXPORTING
**          iv_name   = lv_name
**          iv_bis    = sy-datum
**        IMPORTING
**          ev_result = lv_vdew_versnr.
**    CATCH zcx_eide.
**      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
**         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
**  ENDTRY.
**
**  unh-assoccode       = lv_vdew_versnr.
***--Version
**  unh-referencenumber = lv_refno.
**  unh-identifier      = co_message_type_invoic.
**  unh-versionnumber   = co_message_version_invoic.
**  unh-releasenumber   = co_message_release_invoic_2.
**  unh-controlagency   = co_controlling_agency.
**
**  mac_seg_append co_seg_vdew_unh1 unh.
**
*** --- BGM Beginning Segment
**  IF x_invoice-erdk-ergrd = co_ergrd_reversal_bill.
***   reversal - this could be both for a bill or for budget billing
***   -> check original bill
**
***>>DATEXPRN_3
**    IF x_invoice-erdk-intopbel IS INITIAL.
***     this happens in the case of pseudo reversals of budget billing
***     request -> determine the original document from ERDBBPREQ
**      READ TABLE x_invoice-t_erdb WITH KEY doc_id = 'Q'
**        ASSIGNING <erdb>.
**
**      IF sy-subrc = 0.
**        CASE <erdb>-awtyp.
**          WHEN 'CRSR7'.
**            SELECT * FROM erdbbpreq INTO TABLE lt_erdbbpreq
**              WHERE crsrf = <erdb>-awkey.               "#EC CI_NOFIELD
**
**            LOOP AT lt_erdbbpreq ASSIGNING <erdbbpreq>
**              WHERE cancel = co_false.
**              EXIT.
**            ENDLOOP.
**
**            IF sy-subrc = 0.
***             reversal is pseudo
***             "original" is a pseudo revival
**              lv_intopbel = <erdbbpreq>-opbel_add.
**            ELSE.
***             reversal is pseudo
***             original is a real original bbp request
**              READ TABLE lt_erdbbpreq INDEX 1 ASSIGNING <erdbbpreq>.
**              IF sy-subrc = 0.
**                lv_intopbel = <erdbbpreq>-opbel_orig.
**              ELSE.
**                mac_msg_putx co_msg_error '708' 'EDEREG_INV'
**                             space space space space
**                             general_fault.
**                IF 1 > 2.
**                  MESSAGE e708(edereg_inv).
**                ENDIF.
**              ENDIF.
**            ENDIF.
**
**          WHEN 'CRSRF'.
**            CALL FUNCTION 'ISU_DB_ECROSSREFNO_SELECT_EXT'
**              EXPORTING
**                x_crossrefno   = x_crossrefno
**              IMPORTING
**                yt_ecrossrefno = lt_ecrossrefno
**              EXCEPTIONS
**                error_occurred = 1
**                not_found      = 2
**                OTHERS         = 3.
**            IF sy-subrc <> 0.
**              mac_msg_repeat co_msg_error general_fault.
**            ENDIF.
**
**            LOOP AT lt_ecrossrefno ASSIGNING <ecrossrefno>.
**              SELECT SINGLE a~opbel FROM erdb AS a
**                INNER JOIN erdk AS b ON a~opbel = b~opbel
**                INTO lv_intopbel
**                WHERE awtyp = 'CRSRF'
**                  AND awkey = <ecrossrefno>-int_crossrefno
**                  AND ergrd = '02'.
**              EXIT.
**            ENDLOOP.
**
**        ENDCASE.
**      ENDIF.
**    ELSE.
**      lv_intopbel = x_invoice-erdk-intopbel.
**    ENDIF.
***>>DATEXPRN_3
**
**    CALL FUNCTION 'ISU_DB_ERDK_SINGLE'
**      EXPORTING
**        x_opbel = lv_intopbel
**      IMPORTING
**        y_erdk  = wa_org_erdk
**      EXCEPTIONS
**        OTHERS  = 1.
**    IF sy-subrc = 0.
**      wa_ergrd = wa_org_erdk-ergrd.
**    ELSE.
**      mac_msg_putx co_msg_error '708' 'EDEREG_INV'
**                                space space space space
**                                general_fault.
**      IF 1 > 2.
**        MESSAGE e708(edereg_inv).
**      ENDIF.
**    ENDIF.
**  ELSE.
**    wa_ergrd = x_invoice-erdk-ergrd.
**  ENDIF.
**
**  IF x_invoice-erdk-ergrd = '04'.
**    bgm-name = gc_bgm_reversal_debit.
**  ELSE.
**    bgm-name = co_bgm_invoice.
**  ENDIF.
**
*** --- use external cross reference number as reference
**  IF x_crossrefno IS INITIAL.
**    mac_msg_putx co_msg_error '702' 'EDEREG_INV'
**                             'ISU_COMPR_NEW_INVOIC26_OUT'
**                              space space space
**                              general_fault.
**    IF 1 > 2.
**      MESSAGE e702(edereg_inv) WITH 'ISU_COMPR_NEW_INVOIC26_OUT'.
**    ENDIF.
**  ENDIF.
**
***>>DATEX_PRN
*** Determine CRN scenario
**  CALL FUNCTION 'ISU_DB_DEREGSWITCHSYST_SELECT'
**    IMPORTING
**      e_xcrn                  = lv_xcrn
**    EXCEPTIONS
**      customizing_not_defined = 1
**      OTHERS                  = 2.
**  IF sy-subrc <> 0.
**    mac_msg_repeat co_msg_error general_fault.
**  ENDIF.
**
**  bgm-documentfunc = co_documentfunc_orig_msg.
**  IF x_invoice-erdk-ergrd = '04'.
**    ls_storno = co_true.   "#02
**  ENDIF.
**
**  CASE lv_xcrn.
**    WHEN co_true.
***     Switch to new CRN if new determination in reversal process
***     this is checked in fill_orig_ref
**      PERFORM fill_orig_ref USING x_crossrefno
**                                  bgm-documentnumber.
**      lv_mem_orig_refnum = bgm-documentnumber.
**    WHEN co_false.
**      bgm-documentnumber = x_crossrefno.
**  ENDCASE.
**
**  MOVE bgm-documentnumber   TO lv_documentnumber.
**
*** Vertriebsgesellschaft vor documentnumber packen
**  CALL FUNCTION 'Z_EIDE_BUILD_BGMNR'
**    EXPORTING
**      iv_serviceid = x_sender
**      iv_bgmnr_old = lv_documentnumber
**    IMPORTING
**      ev_bgmnr_new = lv_documentnumber.
**
**  MOVE lv_documentnumber   TO bgm-documentnumber.
**
**
**  IF NOT x_invoice-erdk-edisenddate IS INITIAL.
***  Resending an IDoc
**    bgm-documentfunc = '7'. "causes problems in processing of
***  resent IDocs on supplier site
***  -> a repeated processing => bgm-documentfunc = "original"
***    bgm-documentfunc = co_bgm_docfunc_duplicate.
**
*** Wird eine Originalrechnung nachgedruckt, die bereits storniert
*** ist, muss als BGM die Originalrechnung ausgegeben werden.
*** lv_xcrn ist in diesem Fall = x, so dass im vorhergehenden
*** Coding fälschlicherweise die Stornorechnung als BGM gesetzt
*** wird. Das wird hier korrigiert.
**    IF x_reverse IS INITIAL.
**      bgm-documentnumber = x_crossrefno.
**      CLEAR lv_mem_orig_refnum.
**    ENDIF.
**  ENDIF.
***<<DATEX_PRN
**
***     Merken bgm-documentnumber
**  CLEAR lv_bgm_doc_no.
**  lv_bgm_doc_no = bgm-documentnumber.
**
**  lv_bgm_name = bgm-name.
**  mac_seg_append co_seg_vdew_bgm1 bgm.
**
*** --- DTM Date/Time/Period
*** --- document time
**  dtm-datumqualifier = co_message_dateq.
**  dtm-datum = x_invoice-erdk-bldat.
**  dtm-format = co_dtm_format.
**  mac_seg_append co_seg_vdew_dtm1 dtm.
**  dtm-datumqualifier = co_proc_dateq.
**  dtm-datum = x_invoice-erdk-budat.
**  dtm-format = co_dtm_format.
**  mac_seg_append co_seg_vdew_dtm1 dtm.
**
**  CLEAR dtm_rff.
**
*** --- determine document date using lines
**  IF x_erch-begabrpe IS INITIAL OR
**     x_erch-endabrpe IS INITIAL.
**    PERFORM determine_doc_date USING    x_invoice-t_erdz
**                               CHANGING v_ab
**                                        v_bis.
**  ELSE.
**    v_ab  = x_erch-begabrpe.
**    v_bis = x_erch-endabrpe.
**  ENDIF.
**
**  IF NOT exit_isu_vdew_invoic_out IS INITIAL AND
**    ( v_ab IS INITIAL AND v_bis IS INITIAL ).
**    CALL METHOD exit_isu_vdew_invoic_out->determine_document_date
**      EXPORTING
**        x_invoice      = x_invoice
**      CHANGING
**        y_date_from    = v_ab
**        y_date_to      = v_bis
**      EXCEPTIONS
**        error_occurred = 1
**        OTHERS         = 2.
**    IF sy-subrc <> 0.
**      mac_msg_putx sy-msgty sy-msgno sy-msgid sy-msgv1
**                   sy-msgv2 sy-msgv3 sy-msgv4 general_fault.
**    ENDIF.
**  ENDIF.
**
*** --- start of billing time
**  IF NOT v_ab IS INITIAL.
**    dtm-datumqualifier = co_dtm_bill_begin.
**    dtm-datum  = v_ab.
**    dtm-format = co_dtm_format.
**    mac_seg_append co_seg_vdew_dtm1 dtm.
**  ENDIF.
**
*** --- end of billing time
**  IF NOT v_bis IS INITIAL.
**    dtm-datumqualifier = co_dtm_bill_end.
**    dtm-datum  = v_bis.
**    dtm-format = co_dtm_format.
**    mac_seg_append co_seg_vdew_dtm1 dtm.
**  ENDIF.
***  ENDIF.
**
*** --- IMD Item Description
***- Änderung gegenüber SAP Standard:
***1.) Für Bestimmung ob Abschlagsrechnung wird BGM-NAME genommen,
**  "weil Erfassungsgrund nicht vorliegt in diesem Fall.
***2.) x_erch-abrvorg durch X_INVOICE-ERDK-ZZABRVORG_KOR ersetzt
*** Partial Invoice (ABS) and WIM:
**  IF x_invoice-erdk-ergrd = co_ergrd_budget_billing.
**    lv_x_bud_bill = abap_true.
**  ENDIF.
**
**  IF wa_ergrd = co_ergrd_budget_billing OR wa_ergrd = co_ergrd_budget_billing_ch.
**    imd-item_char_code = gc_imd_abs. "ABS
**    ls_pi_map-imd_beschrbg = imd-item_char_code.
**    mac_seg_append co_seg_vdew_imd1 imd.
***   budget billing -> 2.5:IMD segment -> build new
**  ELSE.
***   --- only final billing and period-end billing can be identified
**    IF x_erch-abrvorg = co_end_billing.
************************************************************************
**      IF x_erch-endofpeb = 'X'.
**        imd-item_char_code = co_imd_bill_month_sonder.
**      ELSE.
**        imd-item_char_code   = co_imd_bill_end.
**      ENDIF.
**    ELSEIF x_erch-abrvorg = co_period_end_billing.
**      imd-item_char_code   = co_imd_bill_13th.
**    ELSEIF x_erch-abrvorg = co_int_billing.
**      imd-item_char_code = co_imd_bill.
**    ELSEIF x_erch-abrvorg = co_service_territory_transfer.
**      imd-item_char_code = co_imd_bill_end.
**    ELSEIF x_erch-abrvorg = co_manual_credit_memo.
**      IF x_ever-kofiz(1) = '1' OR x_ever-kofiz(1) = '2'.
**        imd-item_char_code = co_imd_bill_month.
**      ELSE.
**        imd-item_char_code = co_imd_bill.
**      ENDIF.
**    ELSEIF x_erch-abrvorg = co_contract_change.
**      imd-item_char_code   = co_imd_bill_end.
**    ELSEIF x_erch-abrvorg = co_cust_change.
**      imd-item_char_code   = co_imd_bill_end.
**    ELSE.
*** --- read item description
**      IF NOT x_invoice-erdk-portion IS INITIAL.
***       switch Applicationlog off
**        switch_log_off.
**        CALL FUNCTION 'ISU_DB_TE420_SINGLE'
**          EXPORTING
**            x_termschl   = x_invoice-erdk-portion
**          IMPORTING
**            y_te420      = v_te420
**          EXCEPTIONS
**            not_found    = 1
**            system_error = 2
**            OTHERS       = 3.
**        IF sy-subrc <> 0.
**          imd-item_descr_description_1 = text-002.
**        ELSE.
**          CASE v_te420-periodew.
**            WHEN '12'.
**              imd-item_char_code = co_imd_bill_year.
**            WHEN '1'.
**              IF x_erch-endofpeb = 'X'.
**                IF x_erch-abrvorg = co_end_billing.
**                  imd-item_char_code = co_imd_bill_13th.
**                ELSE.
**                  imd-item_char_code = co_imd_bill_month_sonder.
**                ENDIF.
**              ELSE.
**                IF x_erch-backbi = 0 AND x_erch-perendbi = 0.
**                  imd-item_char_code = 'JVR'.
**                ELSE.
**                  imd-item_char_code = co_imd_bill_month.
**                ENDIF.
**              ENDIF.
**            WHEN OTHERS.
**              imd-item_char_code = co_imd_bill.
**          ENDCASE.
**        ENDIF.
***       switch Applicationlog on
**        switch_log_on.
**      ELSE.
**        imd-item_char_code = co_imd_bill.
**      ENDIF.
**    ENDIF.
**    ls_pi_map-imd_beschrbg = imd-item_char_code.
**    mac_seg_append co_seg_vdew_imd1 imd.
**  ENDIF.
***    ENDIF.
***  ENDIF.
**
*** FTX Segment bei Reverse Charge.
**  IF lv_x_foreign_suppl NE space OR
**     lv_revchar_01      NE space.
**
**    ftx-textbezug_qualifier = co_credentials.
**    ftx-freiertext_code     = co_reverse_charge.
**    mac_seg_append co_seg_vdew_ftx ftx.
**
**  ENDIF.
**
*** --- RFF Reference
***>>DATEX_PRN_3
**
*** Version 2.6
*** Prüfidentifikator
**  ls_pi_map-edi_format = co_message_type_invoic.
**  ls_pi_map-kategorie = lv_bgm_name.
**
**  CALL METHOD zcl_eidx_ahb_check_central=>get_pruefid_no_mako_table
**    EXPORTING
**      is_pi_map      = ls_pi_map
**    IMPORTING
**      ev_pruefind    = lv_pruefind
**    EXCEPTIONS
**      no_indikator   = 1
**      over_indikator = 2
**      OTHERS         = 3.
**  IF sy-subrc <> 0.
**    mac_msg_putx sy-msgty sy-msgno sy-msgid sy-msgv1
**                 sy-msgv2 sy-msgv3 sy-msgv4 general_fault.
**  ELSE.
**    rff-referencequalifier = gc_rff_z13.
**    rff-referencenumber    = lv_pruefind.
**    mac_seg_append co_seg_vdew_rff4 rff.
**  ENDIF.
**
**  CLEAR: lv_opbel, lv_bldat.
**
***- eigene Logik für RFF im Stornofall
**  IF x_invoice-erdk-stokz IS INITIAL AND
**     ( x_invoice-erdk-intopbel IS NOT INITIAL AND
**     x_invoice-erdk-ergrd = '04' ).
**    "Storno Netznutzungsrechnung aus Altsystem
**    rff-referencequalifier = co_rff_orig_bill.
**
**    CONCATENATE 'PRN' lv_intopbel INTO lv_intopbel_anz.
**
**    SELECT SINGLE edisenddate INTO lv_datum_01
**      FROM erdk
**      WHERE opbel EQ lv_intopbel.
**
**    IF sy-subrc EQ 0.
**
**      IF lv_datum_01 GE '20130503' AND
**         lv_datum_01 GE '20150101'.
**
**        MOVE lv_intopbel_anz TO lv_docnum_01.
**
*** Vertriebsgesellschaft vor documentnumber packen
**        CALL FUNCTION 'Z_EIDE_BUILD_BGMNR'
**          EXPORTING
**            iv_serviceid = x_sender
**            iv_bgmnr_old = lv_docnum_01
**          IMPORTING
**            ev_bgmnr_new = lv_docnum_01.
**
**        MOVE lv_docnum_01 TO lv_intopbel_anz.
**
**      ENDIF.
**
**    ENDIF.
**
**    rff-referencenumber = lv_intopbel_anz.
**    SHIFT rff-referencenumber LEFT DELETING LEADING space.
**
**    IF rff-referencenumber+0(3) EQ 'PRN'.
**
**      SELECT COUNT( * ) FROM erdk
**        WHERE opbel       EQ  rff-referencenumber+3(12) AND
**              druckdat    NE '00000000'                 AND
**              edisenddate EQ '00000000'.
**
**      IF sy-dbcnt GT 0.
**        SHIFT rff-referencenumber BY 3 PLACES LEFT.
**      ENDIF.
**
**    ENDIF.
**
**    mac_seg_append co_seg_vdew_rff4 rff.
**
**    dtm_rff-datumqualifier = co_reference_dateq.
**    CALL FUNCTION 'ISU_DB_ERDK_SINGLE'
**      EXPORTING
**        x_opbel = x_invoice-erdk-intopbel
**      IMPORTING
**        y_erdk  = ls_storn_erdk
**      EXCEPTIONS
**        OTHERS  = 1.
**    IF sy-subrc = 0.
**      lv_bldat = ls_storn_erdk-bldat.
**    ELSE.
**      mac_msg_putx co_msg_error '700' 'EDEREG_INV'
**         'ERDK'(007) 'Druckbelegnummer'(008) x_invoice-erdk-intopbel  space
**                                     general_fault.
**      IF 1 > 2.
**        MESSAGE e700(edereg_inv) WITH 'ERDK'(007) 'Druckbelegnummer'(008) lv_opbel .
**      ENDIF.
**    ENDIF.
**    dtm_rff-datum  = lv_bldat.
**    IF dtm_rff-datum IS INITIAL OR dtm_rff-datum CO ' .0'.
**      mac_msg_putx co_msg_error '053' 'ZEIDX_DEREG'
**         space co_seg_vdew_dtm2  'DATUM' dtm_rff-datum
**         general_fault.
**      IF 1 > 2.
**        MESSAGE e053(zeidx_dereg) WITH space co_seg_vdew_dtm2  'DATUM' dtm_rff-datum
**         RAISING general_fault.
***       ungültige Daten: IDOC &1, Segment &2, Datenelement &3, Wert &4.
**      ENDIF.
**    ENDIF.
**    dtm_rff-format = co_dtm_format.
**    mac_seg_append co_seg_vdew_dtm2 dtm_rff.
**  ELSEIF lv_mem_orig_refnum IS NOT INITIAL.
**
*** x_crossrefno prüfen
**    IF  x_crossrefno(3) EQ 'PRN'.
**      lv_crossrefno = x_crossrefno.
**
**      MOVE lv_crossrefno+3(12) TO lv_opbel.
**
**      CALL FUNCTION 'ISU_DB_ERDK_SINGLE'
**        EXPORTING
**          x_opbel = lv_opbel
**        IMPORTING
**          y_erdk  = ls_storn_erdk
**        EXCEPTIONS
**          OTHERS  = 1.
**      IF sy-subrc = 0.
**        lv_bldat = ls_storn_erdk-bldat.
**      ELSE.
**        mac_msg_putx co_msg_error '700' 'EDEREG_INV'
**           'ERDK'(007) 'Druckbelegnummer'(008) lv_opbel  space
**                                       general_fault.
**        IF 1 > 2.
**          MESSAGE e700(edereg_inv) WITH 'ERDK'(007) 'Druckbelegnummer'(008) lv_opbel .
**        ENDIF.
**      ENDIF.
**    ENDIF.
**
***   Fill original document number only in case of
***   new CRN determination in reversal process
**    IF x_invoice-erdk-ergrd = '04'.
**      CLEAR rff.
**      rff-referencequalifier = co_rff_orig_bill.
**      rff-referencenumber = lv_crossrefno.
**      SHIFT rff-referencenumber LEFT DELETING LEADING space.
**
**      IF rff-referencenumber+0(3) EQ 'PRN'.
**
**        SELECT COUNT( * ) FROM erdk
**          WHERE opbel       EQ  rff-referencenumber+3(12) AND
**                druckdat    NE '00000000'                 AND
**                edisenddate EQ '00000000'.
**
**        IF sy-dbcnt GT 0.
**          SHIFT rff-referencenumber BY 3 PLACES LEFT.
**        ENDIF.
**
**      ENDIF.
**      mac_seg_append co_seg_vdew_rff4 rff.
**
**      CLEAR dtm_rff.
**      dtm_rff-datumqualifier = co_reference_dateq.
**      dtm_rff-datum  = lv_bldat.
**      IF dtm_rff-datum IS INITIAL OR dtm_rff-datum CO ' .0'.
**        mac_msg_putx co_msg_error '053' 'ZEIDX_DEREG'
**           space co_seg_vdew_dtm2  'DATUM' dtm_rff-datum
**           general_fault.
**        IF 1 > 2.
**          MESSAGE e053(zeidx_dereg) WITH space co_seg_vdew_dtm2  'DATUM' dtm_rff-datum
**           RAISING general_fault.
***       ungültige Daten: IDOC &1, Segment &2, Datenelement &3, Wert &4.
**        ENDIF.
**      ENDIF.
**      dtm_rff-format = co_dtm_format.
**      mac_seg_append co_seg_vdew_dtm2 dtm_rff.
**    ENDIF.
**  ENDIF.
**
***<<DATEX_PRN_3
**
***Fill SG2-NAD -> NAD3
*** --- Now we need IDOC_CONTROL record in NAD form
**  PERFORM fill_idoc_control USING    x_receiver
**                            CHANGING wa_idoc_control.
**
*** --- NAD Name & Adress (message)
*** --- sender
**  PERFORM fill_nad USING    x_sender
**                            space
**                            co_nad_sender
**                            wa_idoc_control
**                   CHANGING nad
**                            v_tel_number_tmp
**                            lv_partner_id.
**
**  PERFORM check_adress_01 USING nad 'MS' ''.
**
**  mac_seg_append co_seg_vdew_nad3 nad.
**
***  --- sg3-rff sender
**  rff2-referencequalifier = lc_rff_tax_fc.
**  PERFORM fill_stceg USING    x_vkont_agg
**                     CHANGING rff2-referencenumber.
**  IF NOT rff2-referencenumber IS INITIAL.
**    mac_seg_append co_seg_vdew_rff5 rff2.
**  ENDIF.
**
****- CTA Segment füllen
**  IF ls_clerk_data-clerk_name IS NOT INITIAL.
**    ls_cta-contactfunc = co_func_inf.
**    ls_cta-contactname = ls_clerk_data-clerk_name.
**    mac_seg_append co_seg_vdew_cta1 ls_cta.
**  ENDIF.
**
*** --- COM Communication
***- Telefon
**  IF ls_clerk_data-phone IS NOT INITIAL.
**    ls_com-commqualf  = co_com_telephone.
**    ls_com-commnumber = ls_clerk_data-phone.
**    mac_seg_append co_seg_vdew_com1 ls_com.
**  ENDIF.
**
***- Telefax
**  IF ls_clerk_data-fax IS NOT INITIAL.
**    ls_com-commqualf  = co_com_fax.
**    ls_com-commnumber = ls_clerk_data-fax.
**    mac_seg_append co_seg_vdew_com1 ls_com.
**  ENDIF.
**
***- email
**  IF ls_clerk_data-email IS NOT INITIAL.
**    ls_com-commqualf  = co_com_email.
**    ls_com-commnumber = ls_clerk_data-email.
**    mac_seg_append co_seg_vdew_com1 ls_com.
**  ENDIF.
**
***- Mobile/Handy
**  IF ls_clerk_data-mobile IS NOT INITIAL.
**    ls_com-commqualf  = lc_com_mobil.
**    ls_com-commnumber = ls_clerk_data-mobile.
**    mac_seg_append co_seg_vdew_com1 ls_com.
**  ENDIF.
**
*** --- NAD Name & Adress (message)
*** --- receiver
**  PERFORM fill_nad USING    x_receiver
**                            space
**                            co_nad_receiver
**                            wa_idoc_control
**                   CHANGING nad
**                            v_tel_number_tmp
**                            lv_partner_id.
**
**  PERFORM check_adress_01 USING nad 'MR' ''.
**
**  lv_country = nad-country.
**
**  mac_seg_append co_seg_vdew_nad3 nad.
**
*** --- NAD Name & Adress (message)
*** --- point of delivery
**  CLEAR nad.
**  nad-action = co_nad_pod.
**
**  PERFORM fill_nad USING    x_invoice-erdk-partner
**                            x_int_ui
**                            co_nad_pod
**                            wa_idoc_control
**                   CHANGING nad
**                            v_tel_number_tmp
**                            lv_partner_id.
**
**  PERFORM check_adress_01 USING nad 'DP' x_invoice-erdk-partner.
**
**  mac_seg_append co_seg_vdew_nad3 nad.
*** --- LOC Place / Location
*** --- point of delivery
*** --- determine pod using internal ui
**  CLEAR loc.
**  IF NOT x_erch-endabrpe IS INITIAL.
**    PERFORM determine_ext_ui USING    x_int_ui
**                                      x_erch-endabrpe
**                                      x_ever
**                             CHANGING v_ext_ui.
**  ELSE.
**    PERFORM determine_ext_ui USING    x_int_ui
**                                      x_invoice-erdk-bldat
**                                      x_ever
**                             CHANGING v_ext_ui.
**  ENDIF.
**  IF v_ext_ui IS INITIAL.
**    LOOP AT x_invoice-t_erdz INTO wa_erdz WHERE xtotal_amnt = co_true.
**      PERFORM determine_ext_ui USING  x_int_ui
**                                      wa_erdz-bis
**                                      x_ever
**                             CHANGING v_ext_ui.
**      IF NOT v_ext_ui IS INITIAL.
**        EXIT.
**      ENDIF.
**    ENDLOOP.
**  ENDIF.
**  IF v_ext_ui IS INITIAL.
**    PERFORM determine_ext_ui USING  x_int_ui
**                                    sy-datlo
**                                    x_ever
**                           CHANGING v_ext_ui.
**  ENDIF.
**
**  loc-place_qualifier                 = co_reference_point.
**  loc-place_id                         = v_ext_ui.
**  SHIFT loc-place_id LEFT DELETING LEADING ' '.
**
**  mac_seg_append co_seg_vdew_loc2 loc.
**
*** --- CUX Currencies
**  cux-currency_details_1 = co_cux_refcur.
**  PERFORM determine_iso_waers USING x_invoice-erdk-total_waer
**                                    v_iso_waers.
**  cux-currency_id_1 = v_iso_waers.
**  cux-currency_qualifier_1 = co_cux_billcur.
**  mac_seg_append co_seg_vdew_cux1 cux.
**
*** --- PAT -> PYT
**  pyt1-payment_terms_type = co_pat_type.
**  mac_seg_append co_seg_vdew_pyt1 pyt1.
**
*** --- DTM
*** --- payment date
**  CLEAR: lt_vkdetails_01[],
**         lt_vkdetails_02[],
**         lv_faedn_01,
**         lv_faedn_02,
**         dtm3.
**
**  CALL FUNCTION 'BAPI_ISUACCOUNT_GETDETAIL'
**    EXPORTING
**      contractaccount      = x_invoice-erdk-vkont
**    IMPORTING
**      return               = ls_return_01
**    TABLES
**      tcontractaccountdata = lt_vkdetails_01
**      tctraclockdetail     = lt_vkdetails_02.
**
**  IF NOT lt_vkdetails_02[] IS INITIAL..
**
**    LOOP AT lt_vkdetails_02 TRANSPORTING NO FIELDS
**    WHERE process_id EQ '01' AND
**          from_date  LE sy-datum AND
**          to_date    GE sy-datum.
**      EXIT.
**    ENDLOOP.
**
**    IF sy-subrc EQ 0.
**
**      CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
**        EXPORTING
***         CORRECT_OPTION               = '+'
**          date                         = sy-datum
**          factory_calendar_id          = '01'
**        IMPORTING
***         DATE                         =
**          factorydate                  = lv_faedn_01
***         WORKINGDAY_INDICATOR         =
**        EXCEPTIONS
**          calendar_buffer_not_loadable = 1
**          correct_option_invalid       = 2
**          date_after_range             = 3
**          date_before_range            = 4
**          date_invalid                 = 5
**          factory_calendar_not_found   = 6
**          OTHERS                       = 7.
**
**      IF sy-subrc EQ  0.
**
**        ADD 10 TO lv_faedn_01.
**
**        CALL FUNCTION 'FACTORYDATE_CONVERT_TO_DATE'
**          EXPORTING
**            factorydate                  = lv_faedn_01
**            factory_calendar_id          = '01'
**          IMPORTING
**            date                         = lv_faedn_02
**          EXCEPTIONS
**            calendar_buffer_not_loadable = 1
**            factorydate_after_range      = 2
**            factorydate_before_range     = 3
**            factorydate_invalid          = 4
**            factory_calendar_id_missing  = 5
**            factory_calendar_not_found   = 6
**            OTHERS                       = 7.
**
**        IF sy-subrc EQ 0.
**          dtm3-datum = lv_faedn_02.
**        ENDIF.
**
**      ENDIF.
**
**    ENDIF.
**
**  ENDIF.
**
**  IF dtm3-datum IS INITIAL.
**    dtm3-datum = x_invoice-erdk-faedn.
**  ENDIF.
**
**  dtm3-datumqualifier = co_dtm_due_date.
**  dtm3-format = co_dtm_format.
**  mac_seg_append co_seg_vdew_dtm3 dtm3.
**
**  v_lin_nr = 0.
*** --- determine invoice items
**
*** Aufbau interne Tabelle mit allen Rabattzeilen
**  LOOP AT x_invoice-t_erdz INTO ls_erdz_alc
**    WHERE xtotal_amnt = co_true
***      AND buchrel = co_true
**      AND NOT rabzus IS INITIAL
**      AND nettobtr NE 0.
**    APPEND ls_erdz_alc TO lt_erdz_alc.
**  ENDLOOP.
**
*** --- loop at invoice items
**  LOOP AT x_invoice-t_erdz INTO wa_erdz
**                           WHERE  xtotal_amnt = co_true.
***- LOOP Variablen initialisieren
**    CLEAR:
**      lv_x_lin_suppr,
**      lv_x_qty_47_pcs,
**      v_nettobtr.
**
**    CLEAR qty-measure_unit_qualifier.
**
*** Rabattzeilen nicht mehr berücksichtigen, da sie bereits in
*** interner Tabelle lt_erdz_alc enthalten sind
**    IF NOT wa_erdz-rabzus IS INITIAL.
**      CONTINUE.
**    ENDIF.
**
**    CLEAR: wa_tax,
**           v_sum_seg_only.
**
*** --- determine line type
**    IF wa_erdz-belzart IS INITIAL.
**      PERFORM get_transactions CHANGING h_hv_bbp_p
**                                        h_hv_bbp_r
**                                        h_tv_bbp_p
**                                        h_tv_bbp_r.
**      IF ( wa_erdz-hvorg = h_hv_bbp_p AND
**           wa_erdz-tvorg = h_tv_bbp_p ) OR
**         ( wa_erdz-hvorg = h_hv_bbp_r AND
**           wa_erdz-tvorg = h_tv_bbp_r ).
**        wa_erdz-belzart = co_belzart_bbppay.
**      ENDIF.
**    ENDIF.
**
*** --- change amounts for reversal
**    IF x_reverse <> space.
**      PERFORM reverse_amnt_quant USING wa_erdz.
**    ENDIF.
**
**    CASE wa_erdz-belzart.
**      WHEN co_belzart_subt.
*** --- add up tax line
*** --- remove the following command lines,
*** --- if a tax line should be created
**
*** delete line if:
*** - manually created invoice incl. payed Budget Billing amount
*** - and: tax rate = 0%
*** - and: amounts in tax line correpond to amount in Z-BBPPAY fields of ERDK
**        IF lv_x_cr171 EQ abap_true AND
**           wa_erdz-stprz IS INITIAL AND
**           wa_erdz-betrw = lv_cr171_bbpay_gross.
**          CONTINUE.
**        ENDIF.
**        PERFORM fill_tax USING    wa_erdz
**                         CHANGING wa_bill_tax.
**        COLLECT wa_bill_tax INTO it_bill_tax.
**        CONTINUE.
**      WHEN co_belzart_bbppay.
*** --- add up budget bill lines
*** --- remove the following command lines,
*** --- if budget bill lines should be created
**        IF wa_erdz-bruttozeile = 'X'.
**          v_nettobtr   = wa_erdz-nettobtr - wa_erdz-sbetw.
**        ELSE.
**          v_nettobtr   = wa_erdz-nettobtr.
**        ENDIF.
**        v_bb_net_sum   = v_bb_net_sum   + v_nettobtr.
**        IF wa_erdz-stprz IS INITIAL.
**          PERFORM determine_tax_percent
**            USING    x_invoice
**                     wa_erdz
**                     space
**            CHANGING wa_erdz-taxrate_internal. "wa_erdz-stprz.
**        ENDIF.
**        PERFORM fill_tax USING    wa_erdz
**                         CHANGING wa_bb_tax.
**        COLLECT wa_bb_tax INTO it_bb_tax.
**        CONTINUE.
**    ENDCASE.
**
*** --- LIN Line Item
**    v_lin_nr = v_lin_nr + 1.
**    lin-line_item_number = v_lin_nr.
**    SHIFT lin-line_item_number LEFT DELETING LEADING space.
**
*** --- EAN number to be determined
*** Sparte als Parameter in GET_PROCDUCT_ID übegeben
**    lv_sparte = wa_erdz-sparte.
**    PERFORM get_product_id USING  wa_erdz
**                                  x_sender
**                                  x_receiver
**                                  x_vkont_agg
**                                  lv_sparte
**                         CHANGING v_product_id
**                                  v_product_id_type
**                                  lv_cust_status1
**                                  lv_cust_status2
**                                  lv_typ
**                                  lv_int_serident.
**
***    IF v_product_id    EQ '9990001000269'  AND
***       wa_erdz-belzart EQ 'YBA000'.
***
***      CLEAR: v_product_id.
***      MOVE lc_product_id_wirkarbeit TO v_product_id.
***
***    ENDIF.
**
**    CLEAR: ls_map_prod.
**
**    SELECT SINGLE * FROM zeidet_map_prod
**      INTO ls_map_prod
**      WHERE service_prov = x_receiver
**      AND product_id = v_product_id
**      AND belzart = wa_erdz-belzart.
**
**    IF sy-subrc EQ 0.
**      CLEAR: v_product_id.
**      MOVE ls_map_prod-new_product_id TO v_product_id.
**    ENDIF.
**
**    IF lv_x_cr171 = 'X' AND
**       v_product_id EQ lc_product_cr171.
**      "item line for payed Budget billing which has to be left out.
**      "instead there is a value in x_invoice-erdk-ZZABS_NET which will be
**      "processed in SG50-MOA and SG52-TAX-MOA.
**      v_lin_nr = v_lin_nr - 1.
**      CONTINUE.
**    ENDIF.
**    lin-item_number = v_product_id.
**    lin-item_number_type = gc_disc_qual_z01.
***Sonderregelung für alle Kunden die InVOICE vom Lieferantenerhalten, es werden bilateral vereinbarte Artikelnummern verwendet
**
**    CASE lin-item_number(2).
**      WHEN '40'.
**        lin-item_number_type = gc_disc_qual_en.
**      WHEN OTHERS.
**    ENDCASE.
**    CASE lin-item_number.
**      WHEN '9990001000011'.
**        lin-item_number_type = gc_disc_qual_en.
**      WHEN '9990001000029'.
**        lin-item_number_type = gc_disc_qual_en.
**      WHEN '9990001000095'.
**        lin-item_number_type = gc_disc_qual_en.
**      WHEN '9990001000243'.
**        lin-item_number_type = gc_disc_qual_en.
**      WHEN '9990001000251'.
**        lin-item_number_type = gc_disc_qual_en.
**      WHEN '9990001000409'.
**        lin-item_number_type = gc_disc_qual_en.
**      WHEN '9990001100267'.
**        lin-item_number_type = gc_disc_qual_en.
**      WHEN OTHERS.
**    ENDCASE.
**
**    IF lv_bgm_name <> '457'.
**      mac_seg_append co_seg_vdew_lin1 lin.
**    ENDIF.
**    lv_lin_curr = seg_count.        "#16, Segmentnummer des LIN merken
**
***The PIA segment type didn't use any more
**
*** --- QTY Quantity
*** --- billed energy quantity
*** Hier handelt es sich um eine Ausnahmebehandlung, da das Entgelt
*** für Einbau, Betrieb und Wartung der Messtechnik vereinzelt als Pauschalbetrag
*** abgerechnet wird (LUMSUM02). In der INVOIC muß dennoch ein zweites QTY-Segment
*** aufgebaut werden.
**    IF  (   v_product_id       = '9990001000623'           AND
**            wa_erdz-preistyp   =  space                    AND
**            wa_erdz-timtypza   =  space                    AND
**            wa_erdz-timbasis   =  space                    AND
**            wa_erdz-timtyp     =  space                    AND
**            wa_erdz-i_abrmenge =  0                        AND
**          ( wa_erdz-ab+0(6)    =  wa_erdz-bis+0(6) )       AND
**            wa_erdz-programm   = 'LUMSUM02'                AND
**            wa_erdz-massbill   =  space                        ).
**      .
**
**      wa_erdz-preistyp   =  '2'.
**      wa_erdz-timtypza   =  '1'.
**      wa_erdz-zeitant    =  '1'.
**      wa_erdz-i_abrmenge =   1.
**      wa_erdz-timtyp     =  '1'.
**      wa_erdz-timbasis   =  '1'.
**      wa_erdz-preisbtr   =   wa_erdz-nettobtr.
**
**      IF wa_erdz-nettobtr LT 0.
**        wa_erdz-preisbtr   =  wa_erdz-preisbtr * -1.
**      ENDIF.
**
**    ENDIF.
**    IF wa_erdz-preistyp = '2' OR
**       wa_erdz-preistyp = '3'. "pauschale und verrechnung
**
**      IF wa_erdz-timtypza = '1'. "Month
*** it is assumed that one month consists of 30 days
**
*** Abrechnungsmenge hat Zeitbezug -> zusätzliches QTY 47 mit Qualifier PCS
*** benötigt.
**        lv_x_qty_47_pcs = abap_true.
**
***<<<Note 1334984
*** Take the Time Portion only as the quantity if the line is generated by back
*** billing
***         v_i_abrmenge = is_erdz-i_abrmenge * is_erdz-zeitant.
**        IF wa_erdz-backcanc IS NOT INITIAL. " Back Billing Reversal
**          v_i_abrmenge = wa_erdz-zeitant * ( -1 ).
**        ELSEIF wa_erdz-backexec IS NOT INITIAL. " Back Billing Allocation
**          v_i_abrmenge = wa_erdz-zeitant.
**        ELSE.
**          v_i_abrmenge = wa_erdz-i_abrmenge * wa_erdz-zeitant.
**        ENDIF.
**
**        v_massbill   = 'MON'.
**
**      ELSEIF wa_erdz-timtypza = '2'. "Day
*** Abrechnungsmenge hat Zeitbezug -> zusätzliches QTY 47 mit Qualifier PCS
*** benötigt.
**        lv_x_qty_47_pcs = abap_true.
***         v_i_abrmenge = is_erdz-i_abrmenge * is_erdz-zeitant.
**        IF wa_erdz-backcanc IS NOT INITIAL. " Back Billing Reversal
**          v_i_abrmenge = wa_erdz-zeitant * ( -1 ).
**        ELSEIF wa_erdz-backexec IS NOT INITIAL. " Back Billing Allocation
**          v_i_abrmenge = wa_erdz-zeitant.
**        ELSE.
**          v_i_abrmenge = wa_erdz-i_abrmenge * wa_erdz-zeitant.
**        ENDIF.
**
**        v_massbill = 'TAG'.
**      ELSEIF wa_erdz-timtypza IS INITIAL.
**        MESSAGE e079(zeidx_dereg) WITH text-006 RAISING general_fault.
**      ENDIF.
**      IF NOT exit_isu_vdew_invoic_out IS INITIAL.
**        CALL METHOD exit_isu_vdew_invoic_out->determine_quantity
**          EXPORTING
**            x_erdz         = wa_erdz
**          CHANGING
**            y_abrmenge     = v_i_abrmenge
**            y_massbill     = v_massbill
**          EXCEPTIONS
**            error_occurred = 1
**            OTHERS         = 2.
**        IF sy-subrc <> 0.
**          mac_msg_putx sy-msgty sy-msgno sy-msgid sy-msgv1
**                       sy-msgv2 sy-msgv3 sy-msgv4 general_fault.
**        ENDIF.
**      ENDIF.
**
***  --- determine quantity for
**    ELSE.
**      v_i_abrmenge = wa_erdz-i_abrmenge.
**      v_massbill = wa_erdz-massbill.
**    ENDIF.
**
*** call of another badi for quantity adjustment:
*** in case of discounts in the billing document an adjustment of the
*** quantity may be necessary
**    TRY.
**        IF badi_isu_invoic_out IS INITIAL.
**          GET BADI badi_isu_invoic_out
**            FILTERS
**              sparte = wa_erdz-sparte.
**        ENDIF.
**        CALL BADI badi_isu_invoic_out->adjust_quantity
**          EXPORTING
**            is_erdz       = wa_erdz
**            is_invoice    = x_invoice
**            is_erch       = x_erch
**            is_ever       = x_ever
**            iv_reverse    = x_reverse
**            iv_int_ui     = x_int_ui
**            iv_crossrefno = x_crossrefno
**            iv_vkont_agg  = x_vkont_agg
**            iv_sender     = x_sender
**            iv_receiver   = x_receiver
**          CHANGING
**            cv_abrmenge   = v_i_abrmenge
**            cv_massbill   = v_massbill
**          EXCEPTIONS
**            error_occured = 1
**            OTHERS        = 2.
**        IF sy-subrc <> 0.
**          mac_msg_putx sy-msgty sy-msgno sy-msgid sy-msgv1
**                       sy-msgv2 sy-msgv3 sy-msgv4 general_fault.
**        ENDIF.
**      CATCH cx_badi_not_implemented.
**    ENDTRY.
**
*** merged coding for all price types
**    v_abrmenge = v_i_abrmenge.
**    IF lv_x_qty_47_pcs IS INITIAL.
**      qty-quantity_qualifier     = co_qty_calc_amnt.  "Menge
**    ELSE.
**      qty-quantity_qualifier   = lc_qty_time.       "Zeitanteil
**    ENDIF.
**
**    IF wa_erdz-aklasse    EQ 'RLM' AND
**       wa_erdz-zeitant    LT  1    AND
**       wa_erdz-zeitant    NE  0    AND
**       wa_erdz-timtypza   EQ '1'   AND
**       wa_erdz-timbasis   EQ '1'   AND
**       wa_erdz-tcnumtor   NE  0    AND
**       wa_erdz-tcdenomtor EQ  365.
**      v_massbill   = 'TAG'.
**      v_i_abrmenge =  wa_erdz-tcnumtor.
**      v_abrmenge   =  wa_erdz-tcnumtor.
**    ENDIF.
**
**
**    IF v_i_abrmenge <> 0.
**      IF NOT v_i_abrmenge < 0 AND wa_erdz-nettobtr LT 0 AND wa_erdz-preisbtr GT 0.
**        SHIFT v_abrmenge RIGHT DELETING TRAILING ' -'.
**      ENDIF." v_i_abrmenge < 0.
**    ENDIF.
**    SHIFT v_abrmenge RIGHT DELETING TRAILING ' 0'.
**    SHIFT v_abrmenge RIGHT DELETING TRAILING '.,'.
**    SHIFT v_abrmenge LEFT DELETING LEADING space.
**    IF v_i_abrmenge < 0.
**      IF ( lv_x_qty_47_pcs EQ abap_true AND                       "#16
**         ( x_reverse EQ abap_true OR lv_x_reverse EQ abap_true ) ) OR
**           wa_erdz-nettobtr LT 0.
**        IF qty-quantity_qualifier EQ lc_qty_time.
**        ELSE.
**          "bei Storno kommt das "-" zum Segment 47 PCS und fällt
**          "beim 136 Segment weg.
**          IF  wa_erdz-preisbtr LT 0 AND
**              wa_erdz-nettobtr GT 0 AND
**              v_abrmenge LT 0.
**            v_abrmenge = v_abrmenge * -1.
**          ENDIF.
**        ENDIF.
**      ENDIF.
**      SHIFT v_abrmenge LEFT DELETING LEADING space.
**    ENDIF." v_i_abrmenge < 0.
**    qty-quantity               = v_abrmenge.
**    IF NOT v_massbill IS INITIAL.
**      PERFORM get_measure_unit USING v_massbill
**                                     qty-measure_unit_qualifier.
**    ENDIF.
**    IF NOT qty-measure_unit_qualifier IS INITIAL.
**      "muss ein zuätzliches QTY Segment mit Einheit PCS aufgebaut werden?
**      CLEAR lv_quantity.
**      IF lv_x_qty_47_pcs EQ abap_true.
**        ls_qty_pcs-quantity_qualifier     = co_qty_calc_amnt .
***       Berücksichtigung der negativen Preise
**        IF ( wa_erdz-nettobtr LT 0 AND wa_erdz-preisbtr GT 0 ) OR
**           ( wa_erdz-nettobtr GT 0 AND wa_erdz-preisbtr LT 0 ).
**          "bei Storno kommt das "-" zum Segment 47 PCS
**          ls_qty_pcs-quantity               = '-1'.
**        ELSE.
**          ls_qty_pcs-quantity               = '1'.
**        ENDIF.
**        ls_qty_pcs-measure_unit_qualifier = co_qty_unit_piece .
**        lv_quantity = ls_qty_pcs-quantity.
**        IF lv_bgm_name <> '457'.
**          CLEAR: lv_qty.
**          lv_qty = ls_qty_pcs-quantity.
**
**          PERFORM round_number USING  '03'   "Menge darf nur 3 NKS haben
**                                      '+'    "runden
**                             CHANGING lv_qty.
**
**          ls_qty_pcs-quantity = lv_qty.
**
**          SHIFT ls_qty_pcs-quantity RIGHT DELETING TRAILING ' 0'.
**          SHIFT ls_qty_pcs-quantity RIGHT DELETING TRAILING '.,'.
**          SHIFT ls_qty_pcs-quantity LEFT DELETING LEADING space.
**
**          IF ls_qty_pcs-quantity CA '-'.
**            ls_qty_pcs-quantity = ls_qty_pcs-quantity * -1.
**            SHIFT ls_qty_pcs-quantity RIGHT DELETING TRAILING ' 0'.
**            SHIFT ls_qty_pcs-quantity RIGHT DELETING TRAILING '.,'.
**            ls_qty_pcs-quantity = ls_qty_pcs-quantity * -1.
**            SHIFT ls_qty_pcs-quantity LEFT DELETING LEADING space.
**          ENDIF.
**          mac_seg_append co_seg_vdew_qty2 ls_qty_pcs.
**        ENDIF.
**      ENDIF.
**      IF lv_quantity LT lv_zero AND x_reverse NE 'X' AND
**       ( NOT lv_quantity IS INITIAL OR lv_quantity NE space ).
***Folgende Konstellation ist bereits richtig, es darf keine Vorzeichenumkehr
***erfolgen
**        IF wa_erdz-nettobtr < 0 AND
**           lv_quantity(1) = '-' AND
**           qty-quantity GE 0 AND
**           NOT qty-quantity IS INITIAL.
*** do nothing
**        ELSE.
**          IF ( wa_erdz-nettobtr LT 0 AND wa_erdz-preisbtr GT 0 AND
**               lv_quantity(1) EQ '-'  AND qty-quantity LT 0 ) OR
**             ( wa_erdz-nettobtr GT 0 AND wa_erdz-preisbtr LT 0 AND
**               lv_quantity(1) EQ '-' AND qty-quantity LT 0 ).
***           "bei Storno kommt das "-" zum Segment 47 PCS
**            qty-quantity = qty-quantity * -1.
**            SHIFT qty-quantity  RIGHT DELETING TRAILING ' 0'.
**            SHIFT qty-quantity  RIGHT DELETING TRAILING '.,'.
**            SHIFT qty-quantity LEFT DELETING LEADING space.
**          ENDIF.
**        ENDIF.
**      ELSE.
**        IF ( wa_erdz-nettobtr LT 0 AND wa_erdz-preisbtr GT 0 AND
**          lv_quantity(1) EQ '-'  AND qty-quantity LT 0 ) OR
**          ( wa_erdz-nettobtr GT 0 AND wa_erdz-preisbtr LT 0 AND
**          lv_quantity(1) EQ '-' AND qty-quantity LT 0 ).
***        "Menge bei zeitanteiligen Preisen nie negativ
**          qty-quantity = qty-quantity * -1.
**          SHIFT qty-quantity  RIGHT DELETING TRAILING ' 0'.
**          SHIFT qty-quantity  RIGHT DELETING TRAILING '.,'.
**          SHIFT qty-quantity LEFT DELETING LEADING space.
**        ENDIF.
**      ENDIF.
**      IF lv_bgm_name <> '457'.
**        CLEAR: lv_qty.
**        lv_qty = qty-quantity.
**
**        PERFORM round_number USING  '03'   "Menge darf nur 3 NKS haben
**                                    '+'    "runden
**                            CHANGING lv_qty.
**        qty-quantity = lv_qty.
**
**        SHIFT qty-quantity RIGHT DELETING TRAILING ' 0'.
**        SHIFT qty-quantity RIGHT DELETING TRAILING '.,'.
**        SHIFT qty-quantity LEFT DELETING LEADING space.
**
**        IF qty-quantity CA '-'.
**          SHIFT qty-quantity RIGHT DELETING TRAILING ' -'.
**          SHIFT qty-quantity RIGHT DELETING TRAILING ' 0'.
**          SHIFT qty-quantity RIGHT DELETING TRAILING '.,'.
**          qty-quantity = qty-quantity * -1.
**          SHIFT qty-quantity LEFT DELETING LEADING space.
**        ENDIF.
**
**        mac_seg_append co_seg_vdew_qty2 qty.
**      ENDIF.
**    ENDIF.
**
***-  und nun den Zeitteil ausgeben.
**    IF wa_erdz-preistyp = '4' .           "zeitabhängiger Preis
**      CLEAR: v_i_abrmenge, v_massbill.
**      IF wa_erdz-timtypza = '1'. "Month
**        v_i_abrmenge = wa_erdz-zeitant.
**        v_massbill = 'MON'.
**      ELSEIF wa_erdz-timtypza = '2'. "Day
**        v_i_abrmenge = wa_erdz-zeitant.
**        v_massbill = 'TAG'.
**      ELSEIF wa_erdz-timtypza IS INITIAL.
**        MESSAGE e079(zeidx_dereg) WITH text-006 RAISING general_fault.
**      ENDIF.
**      IF NOT exit_isu_vdew_invoic_out IS INITIAL.
**
**        IF wa_erdz-aklasse    EQ 'RLM' AND
**           wa_erdz-zeitant    LT  1    AND
**           wa_erdz-zeitant    NE  0    AND
**           wa_erdz-timtypza   EQ '1'   AND
**           wa_erdz-timbasis   EQ '12'  AND
**           wa_erdz-tcnumtor   NE  0    AND
**           wa_erdz-tcdenomtor EQ  365.
**
**          v_massbill = 'TAG'.
**          v_abrmenge =  wa_erdz-tcnumtor.
**
**        ELSE.
**
**          CALL METHOD exit_isu_vdew_invoic_out->determine_quantity
**            EXPORTING
**              x_erdz         = wa_erdz
**            CHANGING
**              y_abrmenge     = v_i_abrmenge
**              y_massbill     = v_massbill
**            EXCEPTIONS
**              error_occurred = 1
**              OTHERS         = 2.
**          IF sy-subrc <> 0.
**            mac_msg_putx sy-msgty sy-msgno sy-msgid sy-msgv1
**                         sy-msgv2 sy-msgv3 sy-msgv4 general_fault.
**          ENDIF.
**          v_abrmenge = v_i_abrmenge.
**
**        ENDIF.
**        "qty-quantity_qualifier     = co_qty_calc_amnt.   "#16: SAP code
**        "deaktiviert
**        qty-quantity_qualifier     = lc_qty_time .        "#16
**        SHIFT v_abrmenge RIGHT DELETING TRAILING ' 0'.
**        SHIFT v_abrmenge RIGHT DELETING TRAILING '.,'.
**        SHIFT v_abrmenge LEFT DELETING LEADING space.
**        qty-quantity = v_abrmenge.
**        IF NOT v_massbill IS INITIAL.
**          PERFORM get_measure_unit USING v_massbill
**                                         qty-measure_unit_qualifier.
**        ENDIF.
**        IF NOT qty-measure_unit_qualifier IS INITIAL.
**          IF lv_bgm_name <> '457'.
**            CLEAR: lv_qty.
**            lv_qty = qty-quantity.
**
**            PERFORM round_number USING  '03'     "Menge darf nur 3 NKS haben
**                                        '+'      "runden
**                               CHANGING lv_qty.
**
**            qty-quantity = lv_qty.
**
**            SHIFT qty-quantity RIGHT DELETING TRAILING ' 0'.
**            SHIFT qty-quantity RIGHT DELETING TRAILING '.,'.
**            SHIFT qty-quantity LEFT DELETING LEADING space.
**
**            mac_seg_append co_seg_vdew_qty2 qty.
**          ENDIF.
**        ENDIF.
**      ENDIF.
**    ENDIF.
**
**
**    IF lv_x_bud_bill EQ abap_true.
*** QTY einfügen mit Einheit PCS
**      ls_qty_pcs-quantity_qualifier     = co_qty_calc_amnt .
**      IF x_reverse EQ abap_false.
**        ls_qty_pcs-quantity               = '1'.
**      ELSE.
**        "bei Storno kommt das "-" zum Segment QTY+47:PCS
**        ls_qty_pcs-quantity               = '-1'.
**      ENDIF.
**      ls_qty_pcs-measure_unit_qualifier = co_qty_unit_piece .
**      IF lv_bgm_name <> '457'.
**        CLEAR: lv_qty.
**        lv_qty = ls_qty_pcs-quantity.
**
**        PERFORM round_number USING  '03'     "Menge darf nur 3 NKS haben
**                                    '+'      "runden
**                           CHANGING lv_qty.
**
**        ls_qty_pcs-quantity = lv_qty.
**
**        SHIFT ls_qty_pcs-quantity RIGHT DELETING TRAILING ' 0'.
**        SHIFT ls_qty_pcs-quantity RIGHT DELETING TRAILING '.,'.
**        SHIFT ls_qty_pcs-quantity LEFT DELETING LEADING space.
**
**        mac_seg_append co_seg_vdew_qty2 ls_qty_pcs.
**      ENDIF.
**    ENDIF.
**
*** --- DTM
*** --- billing start time
**    IF NOT wa_erdz-ab IS INITIAL.
**      dtm-datumqualifier = co_dtm_bill_begin.
**      dtm-datum          = wa_erdz-ab.
**      dtm-format         = co_dtm_format.
**      IF lv_bgm_name <> '457'.
**        mac_seg_append co_seg_vdew_dtm5 dtm.
**      ENDIF.
**    ENDIF.
**
*** --- billing end time
**    IF NOT wa_erdz-bis IS INITIAL.
**      dtm-datumqualifier = co_dtm_bill_end.
**      dtm-datum = wa_erdz-bis.
**      dtm-format = co_dtm_format.
**      IF lv_bgm_name <> '457'.
**        mac_seg_append co_seg_vdew_dtm5 dtm.
**      ENDIF.
**    ENDIF.
**
**    IF wa_erdz-bis IS INITIAL AND wa_erdz-ab IS INITIAL.
*** DTM Befüllung bei Mahnkosten
**      IF wa_erdz-belzart EQ 'ACCINF' AND wa_erdz-tvorg EQ 'AFMS'.
**        IF v_ab IS INITIAL AND v_bis IS INITIAL.
**
**          IF x_erch-begabrpe IS INITIAL OR
**             x_erch-endabrpe IS INITIAL.
**            PERFORM determine_doc_date USING    x_invoice-t_erdz
**                                       CHANGING v_ab
**                                                v_bis.
**          ELSE.
**            v_ab  = x_erch-begabrpe.
**            v_bis = x_erch-endabrpe.
**          ENDIF.
**
**          IF NOT exit_isu_vdew_invoic_out IS INITIAL AND
**            ( v_ab IS INITIAL AND v_bis IS INITIAL ).
**            CALL METHOD exit_isu_vdew_invoic_out->determine_document_date
**              EXPORTING
**                x_invoice      = x_invoice
**              CHANGING
**                y_date_from    = v_ab
**                y_date_to      = v_bis
**              EXCEPTIONS
**                error_occurred = 1
**                OTHERS         = 2.
**            IF sy-subrc <> 0.
**              mac_msg_putx sy-msgty sy-msgno sy-msgid sy-msgv1
**                           sy-msgv2 sy-msgv3 sy-msgv4 general_fault.
**            ENDIF.
**          ENDIF.
**        ENDIF.
**
**        dtm-datumqualifier = co_dtm_bill_end.
**        dtm-datum  = v_bis.
**        dtm-format = co_dtm_format.
**        IF lv_bgm_name <> '457'.
**          mac_seg_append co_seg_vdew_dtm5 dtm.
**        ENDIF.
**
**        dtm-datumqualifier = co_dtm_bill_begin.
**        dtm-datum  = v_ab.
**        dtm-format = co_dtm_format.
**        IF lv_bgm_name <> '457'.
**          mac_seg_append co_seg_vdew_dtm5 dtm.
**        ENDIF.
**
**      ELSE.
*** DTM Befüllung bei Abschlägen
***  Berechnung bis
**        CALL FUNCTION 'CALCULATE_DATE'
**          EXPORTING
**            days        = '-1'
**            start_date  = wa_erdz-faedn
**          IMPORTING
**            result_date = wa_erdz-bis.
**        IF sy-subrc NE 0.
***     Keine Aktion!
**        ENDIF.
**        dtm-datumqualifier = co_dtm_bill_end.
**        dtm-datum  = wa_erdz-bis.
**        dtm-format = co_dtm_format.
**        IF lv_bgm_name <> '457'.
**          mac_seg_append co_seg_vdew_dtm5 dtm.
**        ENDIF.
***  Berechnung ab
**        CALL FUNCTION 'CALCULATE_DATE'
**          EXPORTING
**            months      = '-1'
**            start_date  = wa_erdz-bis
**          IMPORTING
**            result_date = wa_erdz-ab.
**        IF sy-subrc NE 0.
***     Keine Aktion!
**        ENDIF.
**        dtm-datumqualifier = co_dtm_bill_begin.
**        dtm-datum  = wa_erdz-ab.
**        dtm-format = co_dtm_format.
**        IF lv_bgm_name <> '457'.
**          mac_seg_append co_seg_vdew_dtm5 dtm.
**        ENDIF.
**      ENDIF.
**    ENDIF.
**
*** Hier in interner Tabelle nachlesen, ob zu der Abrechnungszeile ein
*** Rabatt existiert, falls ja, dann ein ALC Segment vorbereiten
**    LOOP AT lt_erdz_alc INTO ls_erdz_alc
**      WHERE ein01      = wa_erdz-aus01 AND
**            ab         = wa_erdz-ab AND
**            bis        = wa_erdz-bis AND
**            backcanc01 = wa_erdz-backcanc01 AND
**            backcanc02 = wa_erdz-backcanc02 AND
**            backcanc03 = wa_erdz-backcanc03 AND
**            backcanc04 = wa_erdz-backcanc04 AND
**            backcanc05 = wa_erdz-backcanc05 AND
**            backcanc   = wa_erdz-backcanc AND
**            backexec   = wa_erdz-backexec.
**      PERFORM append_alc_pcd USING ls_erdz_alc.
*** ----- Umkehr des Vorzeichen wenn Storno
**      IF ls_storno = co_true.
**        ls_erdz_alc-nettobtr = ls_erdz_alc-nettobtr * -1.
**      ENDIF.
*** ----- verarbeiteten Satz löschen
**      IF NOT alc IS INITIAL.
**        DELETE lt_erdz_alc.
**        EXIT.
**      ELSE.
**        CLEAR ls_erdz_alc.
**      ENDIF.
**    ENDLOOP.
**
*** --- MOA 1 Monetary amount
**    CASE wa_erdz-belzart.
**      WHEN co_belzart_subt.
*** --- tax line (if tax line should be created)
**        moa-monetary_amount_type  = co_moa_amount.
**        PERFORM move_amount
**           USING 0 v_iso_waers moa-monetary_amount_value.
**        moa-currency_id = v_iso_waers.
**        IF lv_bgm_name <> '457'.
**          mac_seg_append co_seg_vdew_moa1 moa.
**        ENDIF.
**
**      WHEN co_belzart_bbppay.
*** --- budget billing (if bb line should be created)
**        moa-monetary_amount_type  = co_moa_amount.
**        IF wa_erdz-bruttozeile = 'X'.
**          v_nettobtr = wa_erdz-nettobtr - wa_erdz-sbetw.
**        ELSE.
**          v_nettobtr = wa_erdz-nettobtr.
**        ENDIF.
**        PERFORM move_amount
**           USING v_nettobtr v_iso_waers moa-monetary_amount_value.
**        moa-currency_id = v_iso_waers.
**        IF lv_bgm_name <> '457'.
**          mac_seg_append co_seg_vdew_moa1 moa.
**        ENDIF.
**        v_bb_net_sum = v_bb_net_sum + v_nettobtr.
**
**      WHEN OTHERS.
**
**        IF wa_tax IS INITIAL.
*** --- billing amount
*** Call BAdI Method for amount and disount determination: there is coding
*** in default implementation
**          TRY.
**              IF badi_isu_invoic_out IS INITIAL.
**                GET BADI badi_isu_invoic_out
**                  FILTERS
**                    sparte = wa_erdz-sparte.
**              ENDIF.
**              CALL BADI badi_isu_invoic_out->determine_amounts_and_disc
**                EXPORTING
**                  is_erdz                = wa_erdz
**                  is_total_waer          = x_invoice-erdk-total_waer
**                  is_invoice             = x_invoice
**                  is_erch                = x_erch
**                  is_ever                = x_ever
**                  iv_reverse             = x_reverse
**                  iv_int_ui              = x_int_ui
**                  iv_crossrefno          = x_crossrefno
**                  iv_vkont_agg           = x_vkont_agg
**                  iv_sender              = x_sender
**                  iv_receiver            = x_receiver
**                CHANGING
**                  cv_pos_netamount       = lv_pos_netamount
**                  cv_totaldisc_netamount = lv_totaldisc_netamount
**                  ct_discount_infos      = lt_discount_infos
**                EXCEPTIONS
**                  error_occured          = 1
**                  OTHERS                 = 2.
**              IF sy-subrc <> 0.
**                mac_msg_putx sy-msgty sy-msgno sy-msgid sy-msgv1
**                             sy-msgv2 sy-msgv3 sy-msgv4 general_fault.
**              ENDIF.
**            CATCH cx_badi_not_implemented.
**          ENDTRY.
**
**          IF lv_pos_netamount IS INITIAL.
**            IF wa_erdz-bruttozeile = 'X'.
**              lv_pos_netamount = wa_erdz-nettobtr - wa_erdz-sbetw.
**            ELSE.
**              lv_pos_netamount = wa_erdz-nettobtr.
**            ENDIF.
**          ENDIF.
**
*** MOA line for position amount
**          moa-monetary_amount_type  = co_moa_amount.
**          v_nettobtr = lv_pos_netamount.
*** im Nettobetrag soll der Zu/Abschlag berücksichtigt sein.
*** Hinweis: ls_erdz_alc-nettobtr: Rabatt: Betrag ist negativ; Zuschlag: Betrag
*** ist positiv
**          IF NOT alc IS INITIAL.
**            v_nettobtr = v_nettobtr + ls_erdz_alc-nettobtr.
**            wa_erdz-nettobtr = v_nettobtr.         "#11
**          ENDIF.
**
***- wenn Betrag im MOA = 0 -> LIN unterdrücken
*** ABER: wenn Nullbetrag durch Rabatt/Zuschlag zustande kommt -> LIN nicht
*** unterdrücken
*** Bsp:
*** a.) Nettobetrag = 0; es gibt kein Rabatt -> LIN nicht erzeugen (inkl. der
*** Untersegmente)
*** b.) Nettobetrag = +5,00 EUR, Rabatt = -5,00 EUR   -> MOA = 0 -> LIN erzeugen
*** c.) Nettobetrag = -8,00 EUR, Zuschlag = +8,00 EUR -> MOA = 0 -> LIN erzeugen
**
**          IF lv_bgm_name <> '457'.
**            IF lv_pos_netamount IS INITIAL AND v_nettobtr IS INITIAL
**              AND x_invoice-erdk-opbel NE 'DUMMY_MMMA'. "TTOOL MMM Nullrechnung
**              "Nullbetrag ist ohne Rabatt zustande gekommen
**              "die bisher angelegten Segmente löschen : LIN-QTY-DTM-MOA
**              "und Segmentcounter aktualisieren
**              DELETE idoc_data FROM lv_lin_curr.
**              seg_count = lines( idoc_data ).
**              " LIN counter zurücksetzen um 1
**              v_lin_nr = v_lin_nr - 1.
**              "Bearbeitung des aktuellen ERDZ Loop abbrechen
**              CONTINUE.
**            ELSE.
**              IF lv_cust_status1 IS NOT INITIAL.
**                mac_msg_putx co_msg_error '100' 'ZEIDE_EDIFACT_INVOIC'
**                                    wa_erdz-belzart
**                                    wa_erdz-opbel space
**                                    space
**                                    general_fault.
**                IF 1 > 2.
**                  MESSAGE e100(zeide_edifact_invoic) WITH wa_erdz-belzart wa_erdz-opbel space space.
**                ENDIF.
**              ENDIF.
**
**              IF lv_cust_status2 IS NOT INITIAL.
**                mac_msg_putx co_msg_error '101' 'ZEIDE_EDIFACT_INVOIC'
**                          lv_int_serident
**                          lv_typ space
**                          space
**                          general_fault.
**                IF 1 > 2.
**                  MESSAGE e101(zeide_edifact_invoic) WITH lv_int_serident lv_typ space space.
**                ENDIF.
**              ENDIF.
**            ENDIF.
**          ENDIF.
**
**          PERFORM move_amount
**             USING v_nettobtr v_iso_waers moa-monetary_amount_value.
**          MOVE moa-monetary_amount_value TO ls_pri_2-price .      "#16
**          moa-currency_id = v_iso_waers.
**          IF lv_bgm_name <> '457'.
**            mac_seg_append co_seg_vdew_moa1 moa.
**          ENDIF.
**          v_bill_net_sum = v_bill_net_sum + v_nettobtr.
**          IF NOT alc IS INITIAL.
**            moa-monetary_amount_type  = co_moa_amount_totaldisc.
**            v_nettobtr = ls_erdz_alc-nettobtr.
**            PERFORM move_amount
**               USING v_nettobtr v_iso_waers moa-monetary_amount_value.
**            moa-currency_id = v_iso_waers.
**            IF lv_bgm_name <> '457'.
**              mac_seg_append co_seg_vdew_moa1 moa.
**            ENDIF.
**          ENDIF.
**
**        ELSE.
*** --- no amount is given in this segment for tax amounts
**          moa-monetary_amount_type  = co_moa_amount.
**          PERFORM move_amount
**             USING 0 v_iso_waers moa-monetary_amount_value.
**          moa-currency_id = v_iso_waers.
**
**          IF lv_bgm_name <> '457'.
**            mac_seg_append co_seg_vdew_moa1 moa.
**          ENDIF.
**        ENDIF.
**    ENDCASE.
**
*** --- PRI Price
**    IF NOT wa_erdz-preis IS INITIAL
**      OR NOT wa_erdz-preisbtr IS INITIAL.                "#19
**      lv_price = wa_erdz-preisbtr.
**      IF NOT exit_isu_vdew_invoic_out IS INITIAL.
**        CALL METHOD exit_isu_vdew_invoic_out->determine_price
**          EXPORTING
**            x_erdz         = wa_erdz
**          CHANGING
**            y_price_value  = lv_price
**            y_price_unit   = pri-measure_unit
**          EXCEPTIONS
**            error_occurred = 1
**            OTHERS         = 2.
**
**        IF pri-measure_unit IS INITIAL AND wa_erdz-preistyp NE '1'.
***         Zusätzliche Rückversicherung
**          IF wa_erdz-timtyp = 1.                 "(month)
**            IF ( wa_erdz-timbasis = 12 ).
**              lv_price = wa_erdz-preisbtr.
**              pri-measure_unit  = co_pri_unit_year.
**            ELSE.
**              lv_price = wa_erdz-preisbtr / wa_erdz-timbasis.
**              pri-measure_unit  = co_pri_unit_month.
**            ENDIF.
**          ELSEIF wa_erdz-timtyp = 2.             "(day)
**            IF ( wa_erdz-timbasis = 365 ) OR ( wa_erdz-timbasis = 366 ).
**              lv_price = wa_erdz-preisbtr.
**              pri-measure_unit  = co_pri_unit_year.
**            ELSEIF ( wa_erdz-timbasis = 30 ) OR ( wa_erdz-timbasis = 31 ).
**              lv_price = wa_erdz-preisbtr.
**              pri-measure_unit  = co_pri_unit_month.
**            ELSE.
**              lv_price = wa_erdz-preisbtr / wa_erdz-timbasis.
**              pri-measure_unit  = co_pri_unit_day.
**            ENDIF.
**          ELSE.
**            lv_price = wa_erdz-preisbtr.
**          ENDIF.
**        ENDIF.
**        IF pri-measure_unit IS INITIAL.
***          MESSAGE e768(edereg_inv) WITH text-000 wa_erdz-preisbtr
***                                        text-003 text-004
***          RAISING general_fault.
**        ENDIF.
**
**        PERFORM round_number
**          USING    '06'           "Preis darf nur 6 NKS haben
**                   space          "abschneiden
**          CHANGING lv_price.
**
**        pri-price = lv_price.
**        SHIFT pri-price RIGHT DELETING TRAILING ' 0'.
**        SHIFT pri-price RIGHT DELETING TRAILING ',.'.
**        SHIFT pri-price LEFT DELETING LEADING space.
**
**        IF sy-subrc <> 0.
**          mac_msg_putx sy-msgty sy-msgno sy-msgid sy-msgv1
**                       sy-msgv2 sy-msgv3 sy-msgv4 general_fault.
**        ENDIF.
**      ENDIF.
**
*** call of another badi for price adjustment:
*** in case of discounts in the billing document an adjustment of the price
*** may be necessary
**      TRY.
**          IF badi_isu_invoic_out IS INITIAL.
**            GET BADI badi_isu_invoic_out
**              FILTERS
**                sparte = wa_erdz-sparte.
**          ENDIF.
**          CALL BADI badi_isu_invoic_out->adjust_price
**            EXPORTING
**              is_erdz        = wa_erdz
**              is_total_waer  = x_invoice-erdk-total_waer
**              is_invoice     = x_invoice
**              is_erch        = x_erch
**              is_ever        = x_ever
**              iv_reverse     = x_reverse
**              iv_int_ui      = x_int_ui
**              iv_crossrefno  = x_crossrefno
**              iv_vkont_agg   = x_vkont_agg
**              iv_sender      = x_sender
**              iv_receiver    = x_receiver
**            CHANGING
**              cv_price_value = lv_price
**              cv_price_unit  = pri-measure_unit
**            EXCEPTIONS
**              error_occured  = 1
**              OTHERS         = 2.
**
**          PERFORM round_number
**            USING    '06'           "Preis darf nur 6 NKS haben
**                     space          "abschneiden
**            CHANGING lv_price.
**
**          pri-price = lv_price.
**          SHIFT pri-price RIGHT DELETING TRAILING ' 0'.
**          SHIFT pri-price RIGHT DELETING TRAILING ',.'.
**          SHIFT pri-price LEFT DELETING LEADING space.
**
**          IF sy-subrc <> 0.
**            mac_msg_putx sy-msgty sy-msgno sy-msgid sy-msgv1
**                         sy-msgv2 sy-msgv3 sy-msgv4 general_fault.
**          ENDIF.
**        CATCH cx_badi_not_implemented.
**      ENDTRY.
**      IF pri-measure_unit = qty-measure_unit_qualifier.
**        CLEAR pri-measure_unit.
**      ENDIF.
**      pri-price_qualifier      = co_pri_qualifier.
**      IF lv_bgm_name <> '457'.
**        mac_seg_append co_seg_vdew_pri1 pri.
**      ENDIF.
**    ENDIF.
**
**    IF lv_x_bud_bill EQ abap_true.
*** PRI einfügen mit Abschlagsbetrag
**      ls_pri_2-price_qualifier      = co_pri_qualifier.
**      IF x_reverse EQ abap_false.
**        "ls_pri_2-price wird im MOA Segment gefüllt
**      ELSE.
**        "bei Storno kommt das "-" zum Segment QTY+47:PCS und muss
**        " beim PRI weg, damit QTY * PRI = MOA (MOA ist < 0 bei Storno)
**        SHIFT ls_pri_2-price RIGHT DELETING TRAILING ' -'.
**        SHIFT ls_pri_2-price LEFT DELETING LEADING space.
**      ENDIF.
**      IF lv_bgm_name <> '457'.
**        mac_seg_append co_seg_vdew_pri1 ls_pri_2.
**      ENDIF.
**    ENDIF.
**
*** --- RFF References on item level
**    CLEAR rff_sg30.
**
*** --- TAX Tax
*** --- tax percentage on item level
**    CLEAR tax.
**    IF NOT wa_erdz-mwskz IS INITIAL.
**      tax-dtf_function   = co_tax_tax.
**      tax-type_coded     = co_tax_vat.
***      tax-category       = co_tax_category.
**      IF wa_erdz-stprz IS INITIAL.
**        PERFORM determine_tax_percent
**            USING    x_invoice
**                     wa_erdz
**                     v_product_id
**            CHANGING wa_erdz-taxrate_internal.
**      ENDIF.
**
**      CLEAR: ls_zformular_ust, lv_x_foreign_suppl.
**
**      SELECT SINGLE * FROM zformular_ust
**      INTO ls_zformular_ust
**      WHERE mwskz =  wa_erdz-mwskz
**      AND text =  lc_zformular_ust_text
**      AND ab <= sy-datum
**      AND bis >= sy-datum.
**
**      IF sy-subrc EQ 0.
**        lv_x_foreign_suppl = abap_true.
**      ENDIF.
**
**      IF lv_x_foreign_suppl NE space.
**
**        tax-category  = co_tax_category_ae."Reverse Charge
**
**      ELSE.
**
**        IF NOT gv_tax_free_sum IS INITIAL.
**          tax-category   = co_tax_category_o."nicht steuerbar
**        ELSE.
**          tax-category   = co_tax_category."Standard
**        ENDIF.
**
**      ENDIF.
**
**      CALL FUNCTION 'ISU_TAXRATE_INTERNAL_TO_IDOC'
**        EXPORTING
**          x_taxrate_internal = wa_erdz-taxrate_internal
**        IMPORTING
**          y_taxrate          = tax-detail_rate.
***                                        CHANGING wa_erdz-stprz.
**
**      IF tax-detail_rate IS INITIAL.
**        "#01
**        tax-detail_rate = '0'.
**
**      ENDIF.
**
**      IF tax-detail_rate EQ '0'    AND
**         lv_revchar_01   NE  space.
**        MOVE co_tax_category_ae TO tax-category.
**      ENDIF.
**
**      IF lv_bgm_name <> '457'.
**        mac_seg_append co_seg_vdew_tax2 tax.
**      ENDIF.
**
**    ENDIF.
**
*** --- MOA Monetary amount
*** --- tax amount on item level
*** --- no tax line on item level any longer
*** --- not every line does have tax assinged correctly
**    CLEAR moa_sg34.
**    IF NOT wa_erdz-sbetw IS INITIAL.
**      moa_sg34-monetary_amount_type  = co_moa_tax_type.
**      PERFORM move_amount
**       USING wa_erdz-sbetw v_iso_waers moa_sg34-monetary_amount_value.
**      moa_sg34-currency_id = v_iso_waers.
*** --- remove the following *, if tax lines should be created
*** --- item level
***     mac_seg_append co_seg_moa2 moa_sg34.
**
**      IF wa_erdz-belzart = co_belzart_bbppay.
**        PERFORM fill_tax USING    wa_erdz
**                         CHANGING wa_bb_tax.
**        COLLECT wa_bb_tax INTO it_bb_tax.
**      ELSE.
**        PERFORM fill_tax USING    wa_erdz
**                         CHANGING wa_bill_tax.
**        COLLECT wa_bill_tax INTO it_bill_tax.
**      ENDIF.
**    ELSE.
**      IF NOT wa_erdz-sbasw IS INITIAL.
**        PERFORM fill_tax USING    wa_erdz
**                         CHANGING wa_bill_tax.
**        COLLECT wa_bill_tax INTO it_bill_tax.
**      ENDIF.
**    ENDIF.
**
**** --- other taxes
**    IF NOT wa_tax IS INITIAL.
*** --- MOA tax / fee
**      moa_sg34-monetary_amount_type  = co_moa_tax_type.
**      PERFORM move_amount
**         USING wa_tax-sbetw v_iso_waers
**               moa_sg34-monetary_amount_value.
**      moa_sg34-currency_id = v_iso_waers.
**
**    ENDIF.
**
*** --- ALC + PCD -  allowance OR charge and percentage
**    LOOP AT lt_discount_infos INTO ls_discount_infos.
**
*** fill and append ALC
**      IF ls_discount_infos-disc_type = co_rabtyp_disc.
**        alc-allow_charge_qualifier = co_qualifier_allowance.
**      ELSEIF ls_discount_infos-disc_type = co_rabtyp_surcharge.
**        alc-allow_charge_qualifier = co_qualifier_charge.
**      ENDIF.
**      alc-allow_charge_code = ls_discount_infos-disc_qual.
**      mac_seg_append co_seg_vdew_alc1 alc.
**
*** Fill PCD
**      IF ls_discount_infos-rabart = co_rabart_perc.
**        pcd-percentage_type_qualifier = co_qaulifier_perctype.
**      ENDIF.
**
**      pcd-percentage = ls_discount_infos-rabproz.
**      SHIFT pcd-percentage RIGHT DELETING TRAILING ' 0'.
**      SHIFT pcd-percentage RIGHT DELETING TRAILING ',.'.
**      SHIFT pcd-percentage LEFT DELETING LEADING space.
**
**      IF lv_bgm_name <> '457'.
**        mac_seg_append co_seg_vdew_pcd1 pcd.
**      ENDIF.
**
**      CLEAR: alc, pcd.
**    ENDLOOP.
**
**    CLEAR: lv_pos_netamount, lv_totaldisc_netamount, ls_erdz_alc-nettobtr.
**    REFRESH: lt_discount_infos.
**
**    IF lv_bgm_name <> '457'.
**      IF NOT alc IS INITIAL.
*** --- Append ALC
**        mac_seg_append co_seg_vdew_alc1 alc.
*** --- Append PCD
**        mac_seg_append co_seg_vdew_pcd1 pcd.
**      ENDIF.
**      CLEAR: alc, pcd, ls_erdz_alc-nettobtr.
**    ENDIF.
**  ENDLOOP.                          "AT x_invoice-t_erdz INTO wa_erdz
**
**  IF lv_bgm_name <> '457'.
*** CHECK ob auch alle rabatte verarbeitet wurden
**    IF NOT lt_erdz_alc[] IS INITIAL.
**      LOOP AT lt_erdz_alc INTO ls_erdz_alc.
**        IF ls_erdz_alc-nettobtr NE 0.
***       Fehlermeldung
**          mac_msg_putx co_msg_error '768' 'EDEREG_INV'
**                                    text-005 text-002
**                                    space space general_fault.
**          IF 1 > 2.
**            MESSAGE e768(edereg_inv) WITH text-005 text-002
**            RAISING general_fault.
**          ENDIF.
**        ENDIF.
**      ENDLOOP.
**    ENDIF.
**  ENDIF.
**
*** --- UNS -  Section control
**  uns-section_id = co_uns_saparate.
**  mac_seg_append co_seg_vdew_uns1 uns.
**
**** --- items tax
***  moa_sg50-monetary_amount_type  = co_moa_amnt_tax.
**  PERFORM sum_tax USING  it_bill_tax
**                  CHANGING wa_bill_tax_sum.
**
*** --- items including taxes
**  moa_sg50-monetary_amount_type  = co_moa_amnt_bill.
**  v_bill_gross_sum = v_bill_net_sum + wa_bill_tax_sum.
**  PERFORM move_amount
**    USING v_bill_gross_sum v_iso_waers moa_sg50-monetary_amount_value.
**  moa_sg50-currency_id = v_iso_waers.
**  mac_seg_append co_seg_vdew_moa3 moa_sg50.
**
*** --- budget billing: gross + tax gross
**  IF lv_x_cr171 IS INITIAL.
*** - budget billing gross
**    PERFORM sum_tax USING   it_bb_tax
**                    CHANGING wa_bb_tax_sum.
**    v_bb_gross_sum = v_bb_net_sum + wa_bb_tax_sum.
**    IF NOT v_bb_gross_sum IS INITIAL.
**      moa_sg50-monetary_amount_type  = co_moa_budget_billing.
**      h_bb_gross_sum = v_bb_gross_sum * ( - 1 ).
**      PERFORM move_amount
**       USING h_bb_gross_sum v_iso_waers moa_sg50-monetary_amount_value.
**      moa_sg50-currency_id = v_iso_waers.
**      mac_seg_append co_seg_vdew_moa3 moa_sg50.
**    ENDIF.
**  ELSE.
*** - budget billing gross
**    moa_sg50-monetary_amount_type  = co_moa_budget_billing.
***    lv_bb_amnt = ( x_invoice-erdk-zzabs_net + x_invoice-erdk-zzabs_st ) * -1.
**    PERFORM move_amount
**     USING lv_bb_amnt v_iso_waers moa_sg50-monetary_amount_value.
**    moa_sg50-currency_id = v_iso_waers.
**    mac_seg_append co_seg_vdew_moa3 moa_sg50.
**  ENDIF.
**
*** --- amount to pay
**  wa_total_tax_sum = wa_bill_tax_sum + wa_bb_tax_sum.
**  v_total_net_sum   = v_bill_net_sum + v_bb_net_sum.
**  moa_sg50-monetary_amount_type  = co_moa_payable.
**  v_total_gross_sum = v_total_net_sum + wa_total_tax_sum.
**  IF lv_x_cr171 EQ abap_true.
**    v_total_gross_sum = v_total_gross_sum + lv_cr171_bbpay_gross.
**  ENDIF.
**
**  PERFORM move_amount
**   USING v_total_gross_sum v_iso_waers moa_sg50-monetary_amount_value.
**  moa_sg50-currency_id = v_iso_waers.
**  mac_seg_append co_seg_vdew_moa3 moa_sg50.
**
**
*** --- Taxes (Sums)
**  APPEND LINES OF it_bb_tax   TO lt_tax_stprz.
**  APPEND LINES OF it_bill_tax TO lt_tax_stprz.
**
**  LOOP AT lt_tax_stprz INTO wa_tax_stprz.
**    CLEAR: wa_tax_stprz-sbetw,
**           wa_tax_stprz-sbasw,
**           wa_tax_stprz-sbasw_gross.
**    MODIFY lt_tax_stprz
**           FROM         wa_tax_stprz
**           TRANSPORTING sbetw
**                        sbasw
**                        sbasw_gross.
**  ENDLOOP.
**
**  SORT lt_tax_stprz.
**  DELETE ADJACENT DUPLICATES FROM lt_tax_stprz.
**
**
*** idoc_data 2.Segment, Datenteil Stelle 1-3 = ‘380’
**  CLEAR: gv_sdata.
**  READ TABLE idoc_data INDEX 2 INTO gs_idoc_data.
**  IF sy-subrc EQ 0.
**
**    IF gs_idoc_data-sdata+0(3) = gc_sdata.
**      gv_sdata = gc_sdata.
**    ELSE.
**      gv_sdata = gc_bgm_reversal_debit.
**    ENDIF.
**
**  ENDIF.
**
**  LOOP AT lt_tax_stprz INTO wa_tax_stprz.
**    lv_index = lv_index + 1.
**
**    IF lv_index = 1.
**      wa_tax_stprz_idx1 = wa_tax_stprz.
**    ELSEIF lv_index = 2.
**      wa_tax_stprz_idx2 = wa_tax_stprz.
**    ENDIF.
**  ENDLOOP.
**
**  IF wa_tax_stprz_idx1-mwskz = '0J' AND wa_tax_stprz_idx2-mwskz = '0L'.
**    DELETE lt_tax_stprz INDEX 2.
**  ENDIF.
**
**  CLEAR: lv_taxrate_internal.
**
**  LOOP AT lt_tax_stprz INTO wa_tax_stprz.
**
**    LOOP AT it_bill_tax INTO wa_bill_tax
**     WHERE ( ( taxrate_internal = wa_tax_stprz-taxrate_internal
**             AND sbasw <> 0 ) OR        " alt: sbetw <> 0
**                   ( taxrate_internal = wa_tax_stprz-taxrate_internal
**                 AND sbasw = 0 ) ).
**
**      READ TABLE it_bb_tax INDEX 1 INTO wa_bb_tax.
**      IF ( ( wa_bill_tax-taxrate_internal EQ wa_tax_stprz-taxrate_internal AND
**             wa_bill_tax-sbasw            NE 0                                 ) OR
**           ( wa_bill_tax-taxrate_internal EQ wa_tax_stprz-taxrate_internal AND
**             wa_bill_tax-sbasw            EQ 0                             AND
**             lv_revchar_01                NE space                             ) OR
**           ( wa_bill_tax-taxrate_internal EQ wa_tax_stprz-taxrate_internal AND
**             wa_bill_tax-sbasw            EQ 0                             AND
**             wa_bb_tax-sbasw_gross        NE 0                             AND
**             gv_sdata                     EQ gc_sdata                          ) OR
**           ( wa_bill_tax-taxrate_internal EQ wa_tax_stprz-taxrate_internal AND
**             wa_bill_tax-sbasw            EQ 0                             AND
**             wa_bb_tax-sbasw_gross        NE 0                             AND
**             gv_sdata                     EQ gc_bgm_reversal_debit             )    ).
**      ELSE.
**        CONTINUE.
**      ENDIF.
**
**
**      IF lv_revchar_02 NE space.
**        CLEAR: lv_revchar_02.
**      ENDIF.
**
*** --- TAX Tax (sum)
**      tax_sg52-dtf_function   = co_tax_tax.
**      tax_sg52-type_coded     = co_tax_vat.
**      CALL FUNCTION 'ISU_TAXRATE_INTERNAL_TO_IDOC'
**        EXPORTING
**          x_taxrate_internal = wa_bill_tax-taxrate_internal
**        IMPORTING
**          y_taxrate          = tax_sg52-detail_rate.
**
**      CLEAR: ls_zformular_ust, lv_x_foreign_suppl.
**
**      SELECT SINGLE * FROM zformular_ust
**      INTO ls_zformular_ust
**      WHERE mwskz =  wa_bill_tax-mwskz
**      AND text =  lc_zformular_ust_text
**      AND ab <= sy-datum
**      AND bis >= sy-datum.
**
**      IF sy-subrc EQ 0.
**        lv_x_foreign_suppl = abap_true.
**      ENDIF.
**
**      IF NOT lv_x_foreign_suppl IS INITIAL.
**        tax_sg52-category       = co_tax_category_ae."Reverse Charge
**      ELSE.
**        IF NOT gv_tax_free_sum IS INITIAL.
**          tax_sg52-category       = co_tax_category_o."nicht steuerbar
**          wa_bill_tax-sbasw = wa_bill_tax-sbasw - gv_tax_free_sum."?
**        ELSE.
**          tax_sg52-category   = co_tax_category."Standard
**        ENDIF.
**      ENDIF.
**
**      IF tax_sg52-detail_rate EQ '0'    AND
**         lv_revchar_01        NE  space.
**        MOVE co_tax_category_ae TO tax_sg52-category.
**      ENDIF.
**
**      MOVE wa_bill_tax-taxrate_internal TO lv_taxrate_internal.
**
*** --- MOA Monetary amount (tax)
**      IF wa_bill_tax-taxrate_internal IS INITIAL.
**        SUBTRACT gv_tax_free_sum FROM wa_bill_tax-sbasw.
**        IF wa_bill_tax-sbasw IS INITIAL.
**          CONTINUE.
**        ENDIF.
**      ENDIF.
**
**      mac_seg_append co_seg_vdew_tax3 tax_sg52.
**
**      moa_sg52-monetary_amount_type  = co_moa_amnt_net.
**      PERFORM move_amount
**         USING wa_bill_tax-sbasw v_iso_waers
**               moa_sg52-monetary_amount_value.
**      moa_sg52-currency_id = v_iso_waers.
**      mac_seg_append co_seg_vdew_moa4 moa_sg52.
**
**      moa_sg52-monetary_amount_type  = co_moa_tax_type.
**      PERFORM move_amount
**         USING wa_bill_tax-sbetw v_iso_waers
**               moa_sg52-monetary_amount_value.
**      moa_sg52-currency_id = v_iso_waers.
**      mac_seg_append co_seg_vdew_moa4 moa_sg52.
**    ENDLOOP.
**
**    IF sy-subrc      NE 0 AND
**       lv_revchar_01 NE space AND
**       lv_revchar_02 EQ space.
**      MOVE 'X' TO lv_revchar_03.
**    ENDIF.
**
*** --- budget bill
**    LOOP AT it_bb_tax INTO wa_bb_tax
**
**      WHERE taxrate_internal = wa_tax_stprz-taxrate_internal.
*** --- TAX Tax (sum)
**      tax_sg52-dtf_function   = co_tax_tax.
**      tax_sg52-type_coded     = co_tax_vat.
**      CALL FUNCTION 'ISU_TAXRATE_INTERNAL_TO_IDOC'
**        EXPORTING
**          x_taxrate_internal = wa_bb_tax-taxrate_internal
**        IMPORTING
**          y_taxrate          = tax_sg52-detail_rate.
**
**      IF NOT lv_x_foreign_suppl IS INITIAL.
**        tax_sg52-category       = co_tax_category_ae."Reverse Charge
**      ELSE.
**        IF NOT gv_tax_free_sum IS INITIAL.
**          tax_sg52-category       = co_tax_category_o."nicht steuerbar
**
**          wa_bill_tax-sbasw = wa_bill_tax-sbasw - gv_tax_free_sum."?
**
**        ELSE.
**          tax_sg52-category       = co_tax_category."Standard
**        ENDIF.
**      ENDIF.
**
**      MOVE wa_bb_tax-taxrate_internal TO lv_taxrate_internal.
**
***--- MOA Monetary amount (tax)
**      IF     wa_bb_tax-taxrate_internal IS INITIAL AND
**             lv_revchar_01              IS INITIAL.
**
**        SUBTRACT gv_tax_free_sum FROM wa_bb_tax-sbasw.
**
**        IF wa_bill_tax-sbasw IS INITIAL.
**          MESSAGE e079(zeidx_dereg) WITH text-006 RAISING general_fault.
**        ELSE.
***       das Segment entsteht erst nach Prüfung, ob Summenwerte da sind
**          mac_seg_append co_seg_vdew_tax3 tax_sg52.
**          MOVE wa_bb_tax-taxrate_internal TO lv_taxrate_internal.
***          CONTINUE.
**        ENDIF.
**
**      ELSEIF wa_bb_tax-taxrate_internal IS INITIAL AND NOT
**             lv_revchar_01              IS INITIAL.
**
**        MOVE 'X' TO lv_revchar_02.
**
**      ELSEIF wa_bb_tax-taxrate_internal IS NOT INITIAL AND
**             lv_revchar_02              IS NOT INITIAL.
**
**        mac_seg_append co_seg_vdew_tax3 tax_sg52.
**
**        CLEAR: lv_revchar_02.
**
**      ELSEIF lv_revchar_01 NE space AND
**             lv_revchar_02 EQ space AND
**             lv_revchar_03 NE space.
**
**        mac_seg_append co_seg_vdew_tax3 tax_sg52.
**
**        CLEAR: lv_revchar_02,
**               lv_revchar_03.
**
**      ENDIF.
**
*** --- MOA Monetary amount : gross
**      moa_sg52-monetary_amount_type  = co_moa_budget_billing.
**      h_sbasw_gross = wa_bb_tax-sbasw_gross * ( - 1 ).
**      PERFORM move_amount
***      USING wa_bb_tax-sbasw_gross v_iso_waers
**         USING h_sbasw_gross v_iso_waers
**               moa_sg52-monetary_amount_value.
**      moa_sg52-currency_id = v_iso_waers.
**      mac_seg_append co_seg_vdew_moa4 moa_sg52.
**
*** --- MOA Monetary amount : tax
**      moa_sg52-monetary_amount_type  = co_moa_bb_tax.
**      h_sbetw = wa_bb_tax-sbetw * ( - 1 ).
**      PERFORM move_amount
**         USING h_sbetw v_iso_waers
**               moa_sg52-monetary_amount_value.
**      moa_sg52-currency_id = v_iso_waers.
**      mac_seg_append co_seg_vdew_moa4 moa_sg52.
**
**    ENDLOOP.
**  ENDLOOP.                                " at lt_tax_stprz
**
**
**
**  IF lv_x_cr171 = 'X' AND
**     lv_x_cr171_bb_ok IS INITIAL.
**    "that means: there is a budget billing amout for a canceled invoice from old
**    "Revu system but the BBA was not included in SG52-TAX segment because tax
**    "percentage of BB doesn't fit to the new created invoice.
**    mac_msg_putx co_msg_warning '079' 'ZEIDX_DEREG'
**            x_invoice-erdk-opbel space space space
**            general_fault.
**    IF 1 > 2. MESSAGE w079(zeidx_dereg). ENDIF.   "Verwendungsnachweis
**  ENDIF.
**
**  CLEAR: gv_sdata.
**
**
**
**  LOOP AT idoc_data TRANSPORTING NO FIELDS
**    WHERE segnam EQ co_seg_vdew_tax3.
**
**    MOVE sy-tabix TO lv_tabix_01.
**    ADD  1        TO lv_tabix_01.
**
**    READ TABLE idoc_data INDEX lv_tabix_01 INTO ls_data_01.
**
**    IF sy-subrc EQ 0.
**
**      IF ls_data_01-segnam NE co_seg_vdew_moa4.
**
**        DELETE idoc_data.
**
**        SUBTRACT 1 FROM seg_count.
**
**      ELSE.
**
**        IF ls_data_01-sdata+0(3) NE '125'.
**
**          moa_sg52-monetary_amount_type  = co_moa_amnt_net.
**          moa_sg52-monetary_amount_value = '0'.
**          moa_sg52-currency_id           = v_iso_waers.
**
**          MOVE co_seg_vdew_moa4 TO idoc_line-segnam.
**          MOVE moa_sg52         TO idoc_line-sdata.
**
**          INSERT idoc_line INTO idoc_data INDEX lv_tabix_01.
**
**          ADD 1 TO lv_tabix_01.
**          ADD 1 TO seg_count.
**
**          CLEAR: moa_sg52.
**
**
**          moa_sg52-monetary_amount_type  = co_moa_tax_type.
**          moa_sg52-monetary_amount_value = '0'.
**          moa_sg52-currency_id           = v_iso_waers.
**
**          MOVE co_seg_vdew_moa4 TO idoc_line-segnam.
**          MOVE moa_sg52         TO idoc_line-sdata.
**
**          INSERT idoc_line INTO idoc_data INDEX lv_tabix_01.
**
**          ADD 1 TO lv_tabix_01.
**          ADD 1 TO seg_count.
**
**          CLEAR: moa_sg52.
**
**        ENDIF.
**
**      ENDIF.
**
**    ENDIF.
**
**  ENDLOOP.
**
*** --- UNT -  Trailer segment
**  DESCRIBE TABLE idoc_data LINES seg_count.
**  unt-numseg = seg_count + 1.
**  SHIFT unt-numseg LEFT DELETING LEADING space.
**  unt-refnum = lv_refno.
**  mac_seg_append co_seg_vdew_unt1 unt.
**
*** --- Idoc-Control-Daten fuellen
**  PERFORM fill_idoc_control USING    x_receiver
**                            CHANGING wa_idoc_control.
**
**  y_idoc_data-data[]  = idoc_data[].
**  y_idoc_data-control = wa_idoc_control.
**
*** UNA Character Set segment
**  una-group_seperator       = co_una_group_separator.
**  una-dataelement_separator = co_una_dataelement_separator.
**  una-decimal_sequence      = co_una_decimal_sequence.
**  una-escape_sequence       = co_una_escape_sequence.
**  una-reserved              = co_una_reserved.
**  una-end_of_segment        = co_una_end_of_segment.
**
**  wa_dexidoc_data-segnam = co_seg_vdew_una1.
**  wa_dexidoc_data-sdata  = una.
**
**  APPEND wa_dexidoc_data TO lt_dexidoc_data.
**
**  CLEAR wa_dexidoc_data.
**
*** UNB Header segment
**  CALL FUNCTION 'ISU_DB_ESERVPROV_SINGLE'
**    EXPORTING
**      x_serviceid = x_sender
**    IMPORTING
**      y_eservprov = wa_eservprov
**      y_sp_name   = wa_sender
**    EXCEPTIONS
**      not_found   = 1.
**  IF sy-subrc <> 0.
**    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
**            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING general_fault.
**  ENDIF.
**
**  IF NOT wa_eservprov-externalid IS INITIAL.
**    CALL FUNCTION 'ISU_DATEX_IDENT_CODELIST'
**      EXPORTING
**        x_ext_idtyp     = wa_eservprov-externalidtyp
**        x_idoc_control  = y_idoc_data-control
**      IMPORTING
**        y_extcodelistid = wa_sender_type
**      EXCEPTIONS
**        not_supported   = 1
**        error_occured   = 2
**        OTHERS          = 3.
**    IF sy-subrc <> 0.
**      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
**              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING general_fault.
**    ENDIF.
**  ENDIF.
**
**  lv_externalid_sender = wa_eservprov-externalid.
**
**  CLEAR wa_eservprov.
**
**  CALL FUNCTION 'ISU_DB_ESERVPROV_SINGLE'
**    EXPORTING
**      x_serviceid = x_receiver
**    IMPORTING
**      y_eservprov = wa_eservprov
**      y_sp_name   = wa_receiver
**    EXCEPTIONS
**      not_found   = 1.
**  IF sy-subrc <> 0.
**    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
**            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING general_fault.
**  ENDIF.
**
**  IF NOT wa_eservprov-externalid IS INITIAL.
**    CALL FUNCTION 'ISU_DATEX_IDENT_CODELIST'
**      EXPORTING
**        x_ext_idtyp     = wa_eservprov-externalidtyp
**        x_idoc_control  = y_idoc_data-control
**      IMPORTING
**        y_extcodelistid = wa_receiver_type
**      EXCEPTIONS
**        not_supported   = 1
**        error_occured   = 2
**        OTHERS          = 3.
**    IF sy-subrc <> 0.
**      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
**              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING general_fault.
**    ENDIF.
**  ENDIF.
**
**  lv_externalid_receiver = wa_eservprov-externalid.
**
**  IF lv_externalid_sender+4(1) = '-'.
**    lv_externalid_sender = lv_externalid_sender+5(15).
**  ENDIF.
**
**  unb-sender         = lv_externalid_sender.
**  unb-receiver       = lv_externalid_receiver.
**  unb-syntax_ident   = co_isu_syntax_ident.
**  unb-syntax_version = co_isu_syntax_version.
**  WRITE sy-datum TO unb-date_gen  YYMMDD.
**  unb-time_gen       = sy-uzeit.
**  unb-bulk_ref       = lv_refno.
**
**  "unb-sender_type    = wa_sender_type.     "deaktivierung SAP code
**  "unb-receiver_type  = wa_receiver_type.   "deaktivierung SAP code
**
**  SELECT SINGLE zz_unb_codeid FROM espextidtype
**    INTO unb-sender_type
**    WHERE ext_codelistid = wa_sender_type.
**  IF sy-subrc <> 0.
**    MESSAGE e065(eedmideservprov) WITH wa_sender_type.
**    "Der Typ &1 der externen ID ist nicht im Customizing definiert
**  ENDIF.
**
**  SELECT SINGLE zz_unb_codeid FROM espextidtype
**    INTO unb-receiver_type
**    WHERE ext_codelistid = wa_receiver_type.
**  IF sy-subrc <> 0.
**    MESSAGE e065(eedmideservprov) WITH wa_sender_type.
**    "Der Typ &1 der externen ID ist nicht im Customizing definiert
**  ENDIF.
**
**  IF lv_x_foreign_suppl EQ abap_true.
**    unb-proc_prio = 'X'.
**  ENDIF.
**
**  wa_dexidoc_data-segnam = co_seg_vdew_unb1.
**  wa_dexidoc_data-sdata  = unb.
**
**  APPEND wa_dexidoc_data TO lt_dexidoc_data.
**
**  CLEAR wa_dexidoc_data.
**
**  APPEND LINES OF y_idoc_data-data TO lt_dexidoc_data.
**
*** UNZ Trailer segment
**  wa_dexidoc_data-segnam = co_seg_vdew_unz1.
**  unz-dexcount = '1'.
**  unz-bulk_ref = unb-bulk_ref.
**  wa_dexidoc_data-sdata  = unz.
**
**  APPEND wa_dexidoc_data TO lt_dexidoc_data.
**
**  y_idoc_data-data           = lt_dexidoc_data.
**  y_idoc_data-control-mestyp = co_isu_bill_list.
*** Call Badi at the end of outbound FM, so that customer can do final changes
*** This will keep the logic of original FM:ISU_COMPR_VDEW_INVOIC_OUT
*** --- call badi ISU_VDEW_INVOIC_OUT for possible final changes
**  IF NOT exit_isu_vdew_invoic_out IS INITIAL.
**    CALL METHOD exit_isu_vdew_invoic_out->change_invoice_data
**      EXPORTING
**        x_invoice      = x_invoice
**        x_erch         = x_erch
**        x_ever         = x_ever
**        x_reverse      = x_reverse
**        x_int_ui       = x_int_ui
**        x_crossrefno   = x_crossrefno
**        x_vkont_agg    = x_vkont_agg
**        x_sender       = x_sender
**        x_receiver     = x_receiver
**      CHANGING
**        yx_idoc_data   = y_idoc_data
**      EXCEPTIONS
**        error_occurred = 1
**        OTHERS         = 2.
**    IF sy-subrc <> 0.
**      mac_msg_putx sy-msgty sy-msgno sy-msgid sy-msgv1
**                   sy-msgv2 sy-msgv3 sy-msgv4 general_fault.
**    ENDIF.
**  ENDIF.
**
****- ist LIN da?
**  READ TABLE y_idoc_data-data WITH KEY segnam = co_seg_vdew_lin1
**    TRANSPORTING NO FIELDS.
**  IF sy-subrc <> 0. lv_no_lin = abap_true. ENDIF.
*** nur weiter wenn kein LIN exestiert oder
**  "zu zahlender Betrag = 0 (MOA, Qual. 9) -> kann bei 13. Monatsrechnung RLM
**  "vorkommen.   Oder:
**  "Rechnungsbetrag = 0 (MOA, Qual. 77) -> wenn kein Verbrauch,
**  "zu zahlender Betrag kann dann > 0 sein, wenn Abschläge gezahlt.
**  CHECK lv_no_lin = abap_true OR ( v_total_gross_sum = 0 AND v_bill_gross_sum  = 0 ) OR
**        lv_x_reverse = abap_true OR x_reverse = abap_true.
**
**  IF x_invoice-erdk-edisenddate IS INITIAL.
***- 1.) Druckflag setzen, damit diese Rechnung beim nächsten REDISND1 Lauf
**    "nicht nochmals selektiert wird.
***- richtige Belegnummer für Select bestimmen
**    IF x_invoice-erdk-intopbel IS NOT INITIAL AND
**       x_invoice-erdk-stokz IS INITIAL.
**      "es handelt sich um ein Stornobeleg
**      CONCATENATE 'PRN' x_invoice-erdk-intopbel INTO lv_opbel_crossref.
**    ELSE.
*** - werden Abschläge durch einen Auszug oder eine Rechnung storniert,
*** - so haben sie keine Referenz auf die Originalrechnung in INTOPBEL
*** - bei diesen muss die crossrefno aus der übergebenen übernommen werden
**      IF x_reverse = abap_true.   "Stornorechnung
**        lv_opbel_crossref = x_crossrefno.
**      ELSE.
**        "Originalbeleg (storniert/unstorniert)
**        CONCATENATE 'PRN' x_invoice-erdk-opbel INTO lv_opbel_crossref.
**      ENDIF.
**    ENDIF.
**
***- 2.) Meldung ins Protokoll + Abbruch -> kein IDOC erzeugen
***Hinweis: Message wird im Aufrufprogramm REDISND1 nach Aufruf von
**    "<call function 'ISU_COMEV_PROCESS_INVOICE'> durch mac_msg_repeat
**    "wiederholt. Also 2 x dieselbe msg. Im EDATEXMON01 nur 1 x.
***a.) wenn 13. Monatsrechnung : Warnung
**    IF lv_no_lin = abap_true OR lv_x_reverse = abap_true OR x_reverse = abap_true.
**      IF v_total_gross_sum = '0' AND v_bill_gross_sum = '0'.
**        mac_msg_putx co_msg_error '078' 'ZEIDX_DEREG'
**        x_invoice-erdk-opbel space space space
**        general_fault.
**        IF 1 > 2. MESSAGE w078(zeidx_dereg). ENDIF. "Verwendungsnachweis
**      ENDIF.
**    ELSEIF imd-item_char_code = co_imd_bill_13th.
**      mac_msg_putx co_msg_warning '076' 'ZEIDX_DEREG'
**          x_invoice-erdk-opbel space space space
**          general_fault.
**      IF 1 > 2. MESSAGE w076(zeidx_dereg). ENDIF.   "Verwendungsnachweis
**    ELSE.
**      IF x_invoice-erdk-opbel NE 'DUMMY_MMMA'. "TTOOL MMM Nullrechnung
***b.) sonstige Nullrechnung: Warning
**        mac_msg_putx co_msg_warning '078' 'ZEIDX_DEREG'
**        x_invoice-erdk-opbel space space space
**        general_fault.
**        IF 1 > 2. MESSAGE w078(zeidx_dereg). ENDIF. "Verwendungsnachweis
**      ENDIF.
**    ENDIF.
**  ENDIF.
**
**ENDFUNCTION.
