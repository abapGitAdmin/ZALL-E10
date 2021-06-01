*&---------------------------------------------------------------------*
*&  Include           ZAD_FI_NEGATIVE_REMADV_DEF
*&---------------------------------------------------------------------*



DATA: g_repid        LIKE sy-repid,
      g_save         TYPE char1,
      g_exit         TYPE char1,
      gx_variant     LIKE disvariant,
      g_variant      LIKE disvariant,
      gs_layout      TYPE slis_layout_alv,
      gt_sort        TYPE slis_t_sortinfo_alv,
      gt_fieldcat    TYPE slis_t_fieldcat_alv,
      g_user_command TYPE slis_formname VALUE 'USER_COMMAND',
      g_status       TYPE slis_formname VALUE 'STATUS_STANDARD'.

DATA: gt_event      TYPE slis_t_event.
DATA: gs_listheader TYPE slis_listheader.
DATA: gt_listheader TYPE slis_listheader OCCURS 1.
DATA: x_lines TYPE i.
DATA: c_lines(10) TYPE c.

DATA: g_boxnam TYPE slis_fieldname VALUE  'BOX'.

* Sonstige Felder und Variablen
DATA: counter TYPE i.

DATA: wa_inv_head       TYPE tinv_inv_head,
      wa_inv_doc        TYPE tinv_inv_doc,
      wa_inv_extid      TYPE tinv_inv_extid,
      wa_inv_line_b     TYPE tinv_inv_line_b,
      wa_inv_line_a     TYPE tinv_inv_line_a,
      wa_euitrans       TYPE euitrans,
      wa_inv_c_adj_rsnt TYPE tinv_c_adj_rsnt,
      wa_ecrossrefno    TYPE ecrossrefno,
      wa_dfkkthi        TYPE dfkkthi,
      wa_dfkkop         TYPE dfkkop,
      wa_noti           TYPE /idexge/rej_noti.

CONSTANTS: co_object TYPE tdobject VALUE 'Z_REMADV',
           co_id     TYPE tdid VALUE 'Z001'.
DATA gv_okcode.
DATA: wa_fkkvkp TYPE fkkvkp,
      wa_fkkvk  TYPE fkkvk,
      it_fkkvk  TYPE STANDARD TABLE OF fkkvk,
      gv_name   TYPE tdobname.

DATA: xlines TYPE STANDARD TABLE OF tline.
DATA: help_line TYPE tline.

DATA:  h_service_id TYPE serviceid.

RANGES: r_send FOR wa_inv_head-int_sender.


DATA: wa_cust_remadv TYPE /adesso/fi_remad.
DATA: t_cust_remadv  LIKE TABLE OF wa_cust_remadv.

DATA: wa_ederegswitchsyst TYPE ederegswitchsyst.

DATA: BEGIN OF s_cust_cont,
        class     TYPE ct_cclass,
        activity  TYPE ct_activit,
        type      TYPE ct_ctype,
        direction TYPE ct_coming,
        custinfo  TYPE ct_custinfo,
      END OF s_cust_cont.

DATA: BEGIN OF wa_remadv.
    INCLUDE STRUCTURE vinv_monitoring.
DATA: int_inv_line_no TYPE tinv_inv_line_a-int_inv_line_no,          "AVIS-Zeile
      rstgr           TYPE tinv_inv_line_a-rstgr,                  "AVIS-Zeile
      own_invoice_no  TYPE ecrossrefno-crossrefno,                 "AVIS-Zeile
      betrw_req       TYPE tinv_inv_line_a-betrw_req,              "AVIS-Zeile
      free_text1      TYPE /idexge/rej_noti-free_text1,            "Rejection Notification
      free_text5      TYPE /idexge/rej_noti-free_text5.            "Rejection Notification
DATA: END OF wa_remadv.
DATA: t_remadv LIKE TABLE OF wa_remadv.
FIELD-SYMBOLS: <fs_remadv> LIKE wa_remadv.

DATA: t_inv_c_adj_rsnt TYPE TABLE OF tinv_c_adj_rsnt.

DATA: BEGIN OF wa_crsrf_eui,
        int_crossrefno TYPE dfkkthi-crsrf,
        crossrefno     TYPE inv_own_invoice_no,
        crn_rev        TYPE inv_own_invoice_no,
        int_ui         TYPE ecrossrefno-int_ui,
        ext_ui         TYPE euitrans-ext_ui,
        dateto         TYPE euitrans-dateto,
      END OF wa_crsrf_eui.
DATA: t_crsrf_eui LIKE TABLE OF wa_crsrf_eui.
DATA: t_crsrf_eu2 LIKE TABLE OF wa_crsrf_eui.
FIELD-SYMBOLS: <fs_crsrf_eui> LIKE wa_crsrf_eui.

DATA: BEGIN OF wa_paym,
        own_invoice_no TYPE inv_own_invoice_no,                 "Crossref
        int_inv_doc_no TYPE tinv_inv_line_a-int_inv_doc_no,         "AVIS-Nr
        invoice_status TYPE tinv_inv_head-invoice_status,           "AVIS-Status
      END OF wa_paym.
DATA: t_paym LIKE TABLE OF wa_paym.
FIELD-SYMBOLS: <fs_paym> LIKE wa_paym.

DATA: BEGIN OF wa_dfkkthi_op,
        crsrf TYPE dfkkthi-crsrf,                           "DFKKTHI
        stidc TYPE dfkkthi-stidc,
        opbel TYPE dfkkthi-opbel,
        opupw TYPE dfkkthi-opupw,
        opupk TYPE dfkkthi-opupk,
        opupz TYPE dfkkthi-opupz,
        thinr TYPE dfkkthi-thinr,
        thidt TYPE dfkkthi-thidt,
        thist TYPE dfkkthi-thist,
        thprd TYPE dfkkthi-thprd,
        storn TYPE dfkkthi-storn,
        betrw TYPE dfkkthi-betrw,
        gpart TYPE dfkkthi-gpart,
        vkont TYPE dfkkthi-vkont,
        vtref TYPE dfkkthi-vtref,
        bcbln TYPE dfkkthi-bcbln,
        senid TYPE dfkkthi-senid,
        recid TYPE dfkkthi-recid,
        xblnr TYPE dfkkop-xblnr,
      END OF wa_dfkkthi_op.
DATA: t_dfkkthi_op LIKE TABLE OF wa_dfkkthi_op.
FIELD-SYMBOLS: <fs_dfkkthi_op> LIKE wa_dfkkthi_op.

DATA: t_sval LIKE TABLE OF sval.
DATA: w_sval LIKE sval.
DATA: wa_rej_noti TYPE /idexge/rej_noti.

DATA: BEGIN OF wa_bcontact,
        int_inv_doc_no TYPE tinv_inv_doc-int_inv_doc_no,
        partner        TYPE bcont-partner,
        bpcontact      TYPE stxh-tdname,
      END OF wa_bcontact.
DATA: t_bcontact LIKE TABLE OF wa_bcontact.
DATA: wa_stxh TYPE stxh.

DATA: b_storno TYPE boolean.
DATA: x_index  TYPE sy-tabix.
DATA: x_ctrem TYPE i.


DATA: s_username TYPE v_username.


* Ausgabetabelle
DATA: BEGIN OF wa_out,
        xselp                 TYPE xselp,
        sel(1)                TYPE c,
        int_inv_doc_no        TYPE tinv_inv_doc-int_inv_doc_no,             "DOC
        int_inv_line_no       TYPE inv_int_inv_line_no,                   "Line
        int_receiver          TYPE tinv_inv_head-int_receiver,              "HEADER
        int_sender            TYPE    tinv_inv_head-int_sender,             "HEADER
        free_text4(10)        TYPE c,
        aggvk                 TYPE fkkvk-vkont,
        invoice_status        TYPE  tinv_inv_head-invoice_status,           "HEADER
        date_of_receipt       TYPE tinv_inv_head-date_of_receipt,           "HEADER
        line_state(4)         TYPE c,
        process_state(4)      TYPE c,
        cancel_state(4)       TYPE c,
        comm_state(4)         TYPE c,
        free_text5            TYPE /idexge/rej_noti-free_text5,
        text_vorhanden        TYPE c,
        inf_invoice_cancel(4) TYPE c,                                 "Kennzeichen für Storno-Crossrefno
        paym_avis             TYPE tinv_inv_doc-int_inv_doc_no,             "Zahlungsavis
        paym_stat             TYPE tinv_inv_head-invoice_status,            "Zahlungsavis Status
        ext_invoice_no        TYPE tinv_inv_doc-ext_invoice_no,             "DOC
        doc_type              TYPE    tinv_inv_doc-doc_type,                       "DOC
        inv_doc_status        TYPE  tinv_inv_doc-inv_doc_status,             "DOC
        date_of_payment       TYPE tinv_inv_doc-date_of_payment,            "DOC
        invoice_date          TYPE tinv_inv_doc-invoice_date,               "DOC
        rstgr                 TYPE tinv_inv_line_a-rstgr,                  "AVIS-Zeile
        text                  TYPE tinv_c_adj_rsnt-text,                   "Text zum Reklamationsgrund
        free_text1            TYPE /idexge/rej_noti-free_text1,
        own_invoice_no        TYPE  tinv_inv_line_a-own_invoice_no,        "AVIS-Zeile
        ext_ui                TYPE euitrans-ext_ui,                        "Externe Zählpunktbezeichnung
        aklasse               TYPE eanlh-aklasse,
        ext_ui_melo           TYPE euitrans-ext_ui,                         "Nuss 10.2017 - Melo/Malo
        mult_melo             TYPE flag,                                    "Nuss 10.2017 - Melo/Malo
        int_crossrefno        TYPE ecrossrefno-int_crossrefno,              "inerne Crossreference
        betrw_req             TYPE tinv_inv_line_a-betrw_req,              "AVIS-Zeile
        opbel                 TYPE dfkkthi-opbel,                           "DFKKTHI
        opupw                 TYPE dfkkthi-opupw,
        opupk                 TYPE dfkkthi-opupk,
        opupz                 TYPE dfkkthi-opupz,
        thinr                 TYPE dfkkthi-thinr,
        thidt                 TYPE dfkkthi-thidt,
        thist                 TYPE dfkkthi-thist,
        storn                 TYPE dfkkthi-storn,
        stidc                 TYPE dfkkthi-stidc,
        betrw                 TYPE dfkkthi-betrw,
        gpart                 TYPE dfkkthi-gpart,
        vkont                 TYPE dfkkthi-vkont,
        vtref                 TYPE dfkkthi-vtref,
        bcbln                 TYPE dfkkthi-bcbln,
        senid                 TYPE dfkkthi-senid,
        recid                 TYPE dfkkthi-recid,
        xblnr                 TYPE dfkkop-xblnr,
        zisumabr(1)           TYPE c,
      END OF wa_out.
DATA: it_out LIKE STANDARD TABLE OF wa_out.

CONSTANTS:  co_invtype TYPE tinv_inv_head-invoice_type VALUE '004'.
CONSTANTS:  co_memitype TYPE tinv_inv_head-invoice_type VALUE '008'.
CONSTANTS:  co_mgvtype TYPE tinv_inv_head-invoice_type VALUE '011'.
CONSTANTS:  co_msbtype TYPE tinv_inv_head-invoice_type VALUE '013'.     "Nuss 09.2018
CONSTANTS:  co_invpaym TYPE tinv_inv_head-invoice_type VALUE '002'.
CONSTANTS:  co_docpaym TYPE tinv_inv_doc-doc_type VALUE '004'.
CONSTANTS:  co_linetype TYPE tinv_inv_line_a-line_type VALUE '006'.

DATA: txt        TYPE c LENGTH 10,
      rspar_tab  TYPE TABLE OF rsparams,
      rspar_line LIKE LINE OF rspar_tab.

DATA: t_sel_ea15 TYPE TABLE OF rsparams,
      w_sel_ea15 LIKE LINE OF rspar_tab.


* Ausgabetabelle
DATA: BEGIN OF wa_out_memi,
        xselp                     TYPE xselp,
        sel(1)                    TYPE c,
        int_inv_doc_no            TYPE tinv_inv_doc-int_inv_doc_no,             "DOC
        int_inv_line_no           TYPE inv_int_inv_line_no,                   "Line
        int_receiver              TYPE tinv_inv_head-int_receiver,              "HEADER
        int_sender                TYPE    tinv_inv_head-int_sender,             "HEADER
        aggvk                     TYPE fkkvk-vkont,
        suppl_contr_acct          TYPE /idxmm/memidoc-suppl_contr_acct,
        invoice_status            TYPE  tinv_inv_head-invoice_status,           "HEADER
        date_of_receipt           TYPE tinv_inv_head-date_of_receipt,           "HEADER
        process_state(4)          TYPE c,
        cancel_state(4)           TYPE c,
        cancel_state_mm(4)        TYPE c,
        comm_state(4)             TYPE c,
        line_state(4)             TYPE c,
        free_text5                TYPE /idexge/rej_noti-free_text5,
        text_vorhanden            TYPE c,
        inf_invoice_cancel(4)     TYPE c,                                 "Kennzeichen für Storno-Crossrefno
        paym_avis                 TYPE tinv_inv_doc-int_inv_doc_no,             "Zahlungsavis
        paym_stat                 TYPE tinv_inv_head-invoice_status,            "Zahlungsavis Status
        ext_invoice_no            TYPE tinv_inv_doc-ext_invoice_no,             "DOC
        doc_type                  TYPE    tinv_inv_doc-doc_type,                       "DOC
        free_text4(10)            TYPE c,
        inv_doc_status            TYPE  tinv_inv_doc-inv_doc_status,             "DOC
        date_of_payment           TYPE tinv_inv_doc-date_of_payment,            "DOC
        invoice_date              TYPE tinv_inv_doc-invoice_date,               "DOC
        rstgr                     TYPE tinv_inv_line_a-rstgr,                  "AVIS-Zeile
        text                      TYPE tinv_c_adj_rsnt-text,                   "Text zum Reklamationsgrund
        free_text1                TYPE /idexge/rej_noti-free_text1,
        own_invoice_no            TYPE  tinv_inv_line_a-own_invoice_no,        "AVIS-Zeile
        ext_ui                    TYPE euitrans-ext_ui,                        "Externe Zählpunktbezeichnung
        aklasse                   TYPE eanlh-aklasse,
        ext_ui_melo               TYPE euitrans-ext_ui,                        "Nuss 10.2017 Melo/Malo
        mult_melo                 TYPE flag,                                   "Nuss 10.2017 Melo/Malo
        int_crossrefno            TYPE ecrossrefno-int_crossrefno,              "inerne Crossreference
        betrw_req                 TYPE tinv_inv_line_a-betrw_req,              "AVIS-Zeile
        "MeMi Beleg
        doc_id                    TYPE /idxmm/memidoc-doc_id,
        crossrefno                TYPE /idxmm/memidoc-crossrefno,
        doc_status                TYPE /idxmm/memidoc-doc_status,
        mahnsp                    TYPE  mansp_kk,                              "Nuss 12.02.2018
        fdate                     TYPE  fdate_kk,                              "Nuss 12.02.2018
        tdate                     TYPE  tdate_kk,                              "Nuss 12.02.2018
        division                  TYPE /idxmm/memidoc-division,
        dist_sp                   TYPE /idxmm/memidoc-dist_sp,
        suppl_sp                  TYPE /idxmm/memidoc-suppl_sp,
        suppl_bupa                TYPE bu_partner,
        quantity_type             TYPE /idxmm/memidoc-quantity_type,
        quantity                  TYPE /idxmm/memidoc-quantity,
        application_month         TYPE /idxmm/memidoc-application_month,
        application_year          TYPE /idxmm/memidoc-application_year,
        start_date                TYPE /idxmm/memidoc-start_date,
        end_date                  TYPE /idxmm/memidoc-end_date,
        price                     TYPE /idxmm/memidoc-price,
        net_amount                TYPE /idxmm/memidoc-net_amount,
        energy_tax_amount         TYPE /idxmm/memidoc-energy_tax_amount,
        gross_amount              TYPE /idxmm/memidoc-gross_amount,
        tax_code                  TYPE /idxmm/memidoc-tax_code,
        tax_rate                  TYPE /idxmm/memidoc-tax_rate,
        trig_bill_doc_no          TYPE /idxmm/memidoc-trig_bill_doc_no,
        erchcopbel                TYPE erchc-opbel,
        trig_bill_transact        TYPE /idxmm/memidoc-trig_bill_transact,
        trig_bill_orig_start_date TYPE /idxmm/memidoc-trig_bill_orig_start_date,
        trig_bill_orig_end_date   TYPE /idxmm/memidoc-trig_bill_orig_end_date,
        trig_bill_start_date      TYPE /idxmm/memidoc-trig_bill_start_date,
        trig_bill_end_date        TYPE /idxmm/memidoc-trig_bill_end_date,
        trig_bill_quantity        TYPE /idxmm/memidoc-trig_bill_quantity,
        trig_bill_measure_unit    TYPE /idxmm/memidoc-trig_bill_measure_unit,
        trig_bill_trans_previous  TYPE /idxmm/memidoc-trig_bill_trans_previous,
        trig_bill_split           TYPE /idxmm/memidoc-trig_bill_split,
        settle_query_start_date   TYPE /idxmm/memidoc-settle_query_start_date,
        settle_query_end_date     TYPE /idxmm/memidoc-settle_query_end_date,
        settle_start_date         TYPE /idxmm/memidoc-settle_start_date,
        settle_end_date           TYPE /idxmm/memidoc-settle_end_date,
        settle_quantity           TYPE /idxmm/memidoc-settle_quantity,
        settle_measure_unit       TYPE /idxmm/memidoc-settle_measure_unit,
        company_code              TYPE /idxmm/memidoc-company_code,
        doc_date                  TYPE /idxmm/memidoc-doc_date,
        post_date                 TYPE /idxmm/memidoc-post_date,
        due_date                  TYPE /idxmm/memidoc-due_date,
        inv_send_date             TYPE /idxmm/memidoc-inv_send_date,
        vkont                     TYPE dfkkthi-vkont,

        ci_invoic_doc_no          TYPE /idxmm/memidoc-ci_invoic_doc_no,
        ci_fica_doc_no            TYPE /idxmm/memidoc-ci_fica_doc_no,
        opupk                     TYPE /idxmm/memidoc-opupk,
        mscons_idoc               TYPE /idxmm/memidoc-mscons_idoc,
        mscons_doc_ident          TYPE /idxmm/memidoc-mscons_doc_ident,
        invoic_idoc               TYPE /idxmm/memidoc-invoic_idoc,
        remadv_idoc               TYPE /idxmm/memidoc-remadv_idoc,
        inv_doc_no                TYPE /idxmm/memidoc-inv_doc_no,
        billable_item             TYPE /idxmm/memidoc-doc_id,

      END OF wa_out_memi.
DATA: it_out_memi LIKE STANDARD TABLE OF wa_out_memi.




**   > Nuss 28.03.2017
* Ausgabetabelle
DATA: BEGIN OF wa_out_mgv,
        xselp                 TYPE xselp,
        sel(1)                TYPE c,
        int_inv_doc_no        TYPE tinv_inv_doc-int_inv_doc_no,
        int_inv_line_no       TYPE inv_int_inv_line_no,
        int_receiver          TYPE tinv_inv_head-int_receiver,
        int_sender            TYPE    tinv_inv_head-int_sender,
        aggvk                 TYPE fkkvk-vkont,
        invoice_status        TYPE  tinv_inv_head-invoice_status,
        date_of_receipt       TYPE tinv_inv_head-date_of_receipt,
        process_state(4)      TYPE c,
        cancel_state(4)       TYPE c,
        cancel_state_mgv(4)   TYPE c,
        comm_state(4)         TYPE c,
        line_state(4)         TYPE c,
        free_text5            TYPE /idexge/rej_noti-free_text5,
        text_vorhanden        TYPE c,
        inf_invoice_cancel(4) TYPE c,
        paym_avis             TYPE tinv_inv_doc-int_inv_doc_no,
        paym_stat             TYPE tinv_inv_head-invoice_status,
        ext_invoice_no        TYPE tinv_inv_doc-ext_invoice_no,
        doc_type              TYPE tinv_inv_doc-doc_type,
        free_text4(10)        TYPE c,
        inv_doc_status        TYPE tinv_inv_doc-inv_doc_status,
        date_of_payment       TYPE tinv_inv_doc-date_of_payment,
        invoice_date          TYPE tinv_inv_doc-invoice_date,
        rstgr                 TYPE tinv_inv_line_a-rstgr,
        text                  TYPE tinv_c_adj_rsnt-text,
        free_text1            TYPE /idexge/rej_noti-free_text1,
        own_invoice_no        TYPE tinv_inv_line_a-own_invoice_no,
        ext_ui                TYPE euitrans-ext_ui,
        aklasse               TYPE eanlh-aklasse,
        ext_ui_melo           TYPE euitrans-ext_ui,              "Nuss 10.2017 Melo/Malo
        mult_melo             TYPE flag,                         "Nuss 10.2017 Melo/Malo
        int_crossrefno        TYPE ecrossrefno-int_crossrefno,
        betrw_req             TYPE tinv_inv_line_a-betrw_req,
        "   vkont                     TYPE dfkkthi-vkont,
        proc_ref              TYPE /idxgc/pdoc_log-proc_ref,
        opbel                 TYPE dfkkop-opbel,
        opupw                 TYPE dfkkop-opupw,
        opupk                 TYPE dfkkop-opupk,
        opupz                 TYPE dfkkop-opupz,
        invdocno              TYPE dfkkinvdoc_h-invdocno,
        billdocno             TYPE dfkkinvbill_h-billdocno,
        refdocno              TYPE refdocno_kk,
        doctype               TYPE doctype_kk,
        gpart                 TYPE gpart_ci_kk,
        vkont                 TYPE vkont_ci_kk,
        gpart_inv             TYPE gpart_inv_kk,
        vkont_inv             TYPE vkont_inv_kk,
        date_from             TYPE bill_period_from_kk,
        date_to               TYPE bill_period_to_kk,
        simulated             TYPE simulated_kk,
        crname                TYPE crnam,
        crdate                TYPE billcrdate_kk,
        crtime                TYPE billcrtim_kk,
        faedn                 TYPE faedn_kk,

      END OF wa_out_mgv.
DATA: it_out_mgv LIKE STANDARD TABLE OF wa_out_mgv.
* <   Nuss 28.03.2017


*** --> Nuss 10.2017 Melo/Malo
DATA: wa_idxgc_pod_rel TYPE /idxgc/pod_rel,
      it_idxgc_pod_rel TYPE STANDARD TABLE OF /idxgc/pod_rel,
      gv_podlines      TYPE i,
      wa_euitrans_melo TYPE euitrans.


*** --> Nuss 09.2018
* Ausgabetabelle
DATA: BEGIN OF wa_out_msb,
        xselp                 TYPE xselp,
        sel(1)                TYPE c,
        int_inv_doc_no        TYPE tinv_inv_doc-int_inv_doc_no,             "DOC
        int_inv_line_no       TYPE inv_int_inv_line_no,                   "Line
        int_receiver          TYPE tinv_inv_head-int_receiver,              "HEADER
        int_sender            TYPE    tinv_inv_head-int_sender,             "HEADER
        aggvk                 TYPE fkkvk-vkont,
        vkont_msb             TYPE vkont_kk,
        invoice_status        TYPE  tinv_inv_head-invoice_status,           "HEADER
        date_of_receipt       TYPE tinv_inv_head-date_of_receipt,           "HEADER
        process_state(4)      TYPE c,
        cancel_state(4)       TYPE c,
        cancel_state_ap(4)    TYPE c,                                      "Nuss 09.2018-2
        comm_state(4)         TYPE c,
        line_state(4)         TYPE c,
        free_text5            TYPE /idexge/rej_noti-free_text5,
        text_vorhanden        TYPE c,
        inf_invoice_cancel(4) TYPE c,                                 "Kennzeichen für Storno-Crossrefno
        paym_avis             TYPE tinv_inv_doc-int_inv_doc_no,             "Zahlungsavis
        paym_stat             TYPE tinv_inv_head-invoice_status,            "Zahlungsavis Status
        ext_invoice_no        TYPE tinv_inv_doc-ext_invoice_no,             "DOC
        doc_type              TYPE    tinv_inv_doc-doc_type,                       "DOC
        free_text4(10)        TYPE c,
        inv_doc_status        TYPE  tinv_inv_doc-inv_doc_status,             "DOC
        date_of_payment       TYPE tinv_inv_doc-date_of_payment,            "DOC
        invoice_date          TYPE tinv_inv_doc-invoice_date,               "DOC
        rstgr                 TYPE tinv_inv_line_a-rstgr,                  "AVIS-Zeile
        text                  TYPE tinv_c_adj_rsnt-text,                   "Text zum Reklamationsgrund
        free_text1            TYPE /idexge/rej_noti-free_text1,
        own_invoice_no        TYPE  tinv_inv_line_a-own_invoice_no,        "AVIS-Zeile
        ext_ui                TYPE euitrans-ext_ui,                        "Externe Zählpunktbezeichnung
        aklasse               TYPE eanlh-aklasse,
        ext_ui_melo           TYPE euitrans-ext_ui,                        "Nuss 10.2017 Melo/Malo
        mult_melo             TYPE flag,                                   "Nuss 10.2017 Melo/Malo
        int_crossrefno        TYPE ecrossrefno-int_crossrefno,              "inerne Crossreference
        betrw_req             TYPE tinv_inv_line_a-betrw_req,              "AVIS-Zeile

        "MSB-Beleg
        invdocno              TYPE dfkkinvdoc_h-invdocno,                 "Nuss 09.2018
        crossrefno            TYPE /idxmm/memidoc-crossrefno,
        prlinv_status         TYPE dfkkinvdoc_h-prlinv_status,              "Nuss 09.2018
*        mahnsp                    TYPE  mansp_kk,                              "Nuss 12.02.2018
*        fdate                     TYPE  fdate_kk,                              "Nuss 12.02.2018
*        tdate                     TYPE  tdate_kk,                              "Nuss 12.02.2018
        spart                 TYPE dfkkinvdoc_i-spart,                    "Nuss 09.2018
        /mosb/mo_sp           TYPE dfkkinvdoc_h-/mosb/mo_sp,              "Nuss 09.2018
        /mosb/lead_sup        TYPE dfkkinvdoc_h-/mosb/lead_sup,           "Nuss 09.2018
        gpart                 TYPE bu_partner,
        budat                 TYPE dfkkinvdoc_h-budat,                    "Nuss 09.2018
        bldat                 TYPE dfkkinvdoc_h-bldat,                    "Nuss 09.2018
        faedn                 TYPE dfkkinvdoc_h-faedn,                    "Nuss 09.2018
        opbel                 TYPE dfkkop-opbel,                          "Nuss 09.2018
        quantity              TYPE quantity_kk,                           "Nuss 09.2018
        qty_unit              TYPE dfkkinvbill_i-qty_unit,                "Nuss 09.2018
*        application_month         TYPE /idxmm/memidoc-application_month,
*        application_year          TYPE /idxmm/memidoc-application_year,
*        start_date                TYPE /idxmm/memidoc-start_date,
*        end_date                  TYPE /idxmm/memidoc-end_date,
*        price                     TYPE /idxmm/memidoc-price,
        betrw                 TYPE dfkkinvdoc_i-betrw,            "Nuss 09.2018
*        energy_tax_amount         TYPE /idxmm/memidoc-energy_tax_amount,
*        gross_amount              TYPE /idxmm/memidoc-gross_amount,
*        tax_code                  TYPE /idxmm/memidoc-tax_code,
*        tax_rate                  TYPE /idxmm/memidoc-tax_rate,
*        trig_bill_doc_no          TYPE /idxmm/memidoc-trig_bill_doc_no,
        srcdocno              TYPE dfkkinvdoc_i-srcdocno,              "Nuss 09.2018
        billplanno            TYPE billplanno_kk,                      "Nuss 09.2018-2
        erchcopbel            TYPE erchc-opbel,
*        trig_bill_transact        TYPE /idxmm/memidoc-trig_bill_transact,
*        trig_bill_orig_start_date TYPE /idxmm/memidoc-trig_bill_orig_start_date,
*        trig_bill_orig_end_date   TYPE /idxmm/memidoc-trig_bill_orig_end_date,
        date_from             TYPE dfkkinvdoc_i-date_from,
        date_to               TYPE dfkkinvdoc_i-date_to,
*        trig_bill_quantity        TYPE /idxmm/memidoc-trig_bill_quantity,
*        trig_bill_measure_unit    TYPE /idxmm/memidoc-trig_bill_measure_unit,
*        trig_bill_trans_previous  TYPE /idxmm/memidoc-trig_bill_trans_previous,
*        trig_bill_split           TYPE /idxmm/memidoc-trig_bill_split,
*        settle_query_start_date   TYPE /idxmm/memidoc-settle_query_start_date,
*        settle_query_end_date     TYPE /idxmm/memidoc-settle_query_end_date,
*        settle_start_date         TYPE /idxmm/memidoc-settle_start_date,
*        settle_end_date           TYPE /idxmm/memidoc-settle_end_date,
*        settle_quantity           TYPE /idxmm/memidoc-settle_quantity,
*        settle_measure_unit       TYPE /idxmm/memidoc-settle_measure_unit,
        bukrs                 TYPE dfkkinvdoc_i-bukrs,
*        doc_date              TYPE /idxmm/memidoc-doc_date,
*        post_date             TYPE /idxmm/memidoc-post_date,
*        due_date              TYPE /idxmm/memidoc-due_date,
*        inv_send_date         TYPE /idxmm/memidoc-inv_send_date,
        vkont                 TYPE dfkkthi-vkont,

*        ci_invoic_doc_no      TYPE /idxmm/memidoc-ci_invoic_doc_no,
*        ci_fica_doc_no        TYPE /idxmm/memidoc-ci_fica_doc_no,
*        opupk                 TYPE /idxmm/memidoc-opupk,
*        mscons_idoc           TYPE /idxmm/memidoc-mscons_idoc,
*        mscons_doc_ident      TYPE /idxmm/memidoc-mscons_doc_ident,
*        invoic_idoc           TYPE /idxmm/memidoc-invoic_idoc,
*        remadv_idoc           TYPE /idxmm/memidoc-remadv_idoc,
*        inv_doc_no            TYPE /idxmm/memidoc-inv_doc_no,
        billable_item         TYPE /idxmm/memidoc-doc_id,

      END OF wa_out_msb.
DATA: it_out_msb LIKE STANDARD TABLE OF wa_out_msb.
* <-- Nuss 09.2018
