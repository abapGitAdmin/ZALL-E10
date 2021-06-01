*&---------------------------------------------------------------------*
*&  Include           /ADESSO/INVOIC_CHECKTOP
*&---------------------------------------------------------------------*
TABLES: eanlh.
TABLES: euiinstln.
TABLES: euitrans.
TABLES: tinv_inv_head.
TABLES: tinv_inv_doc.

DATA: BEGIN OF s_eanl,
        anlage   TYPE anlage,
        ab       TYPE abzeitsch,
        bis      TYPE biszeitsch,
        aklasse  TYPE aklasse,
        tariftyp TYPE tariftyp_anl,
        ableinh  TYPE ableinheit,
        int_ui   TYPE int_ui,
        ext_ui   TYPE ext_ui,
      END OF s_eanl.
DATA: t_eanl LIKE TABLE OF s_eanl.
FIELD-SYMBOLS: <t_eanl> LIKE s_eanl.

DATA: BEGIN OF s_docs,
        int_inv_no      TYPE inv_int_inv_no,
        invoice_status  TYPE inv_invoice_status,
        int_receiver    TYPE inv_int_receiver,
        int_sender      TYPE inv_int_sender,
        created_on      TYPE erdat,
        doc_type        TYPE inv_doc_type,
        inv_doc_status  TYPE inv_doc_status,
        ext_invoice_no  TYPE inv_ext_invoice_no,
        inv_bulk_ref    TYPE inv_bulk_ref,
        invperiod_start TYPE inv_period_start,
        invperiod_end   TYPE inv_period_end,
        date_of_payment TYPE inv_date_of_payment,
        int_partner     TYPE bu_partner,
        inv_cancel_rsn  TYPE inv_cancel_rsn,
        inv_cancel_doc  TYPE inv_int_inv_cancel_doc_no,
        rstgr           TYPE rstgr,
        bukrs           TYPE bukrs,
        thbln_ext       TYPE thbln_ext,
        thprd           TYPE thprd_kk,
        line_content    TYPE inv_line_content,
        vkont           TYPE vkont_kk,
        waers           TYPE waers,
        betrw           TYPE betrw_kk,
        taxbw           TYPE inv_taxbw,
        mwskz           TYPE mwskz,
      END OF s_docs.
DATA: t_docs LIKE TABLE OF s_docs.

DATA: s_alvout TYPE /adesso/invoic_check_alv.
DATA: t_alvout TYPE TABLE OF /adesso/invoic_check_alv.

DATA: g_structure LIKE dd02l-tabname.

DATA: s_inv_doc_a  TYPE tinv_inv_doc,
      s_inv_line_a TYPE tinv_inv_line_a,
      s_inv_line_b TYPE tinv_inv_line_b.

DATA: s_ever TYPE ever.
DATA: s_erch TYPE erch.

DATA: BEGIN OF s_ext_out,
        product_id      TYPE tinv_inv_line_b-product_id,
        text            TYPE edereg_sidprot-text,
        date_from       TYPE tinv_inv_line_b-date_from,
        date_to         TYPE tinv_inv_line_b-date_to,
        quantity        TYPE tinv_inv_line_b-quantity,
        unit            TYPE tinv_inv_line_b-unit,
        price           TYPE tinv_inv_line_b-price,
        price_unit      TYPE tinv_inv_line_b-price_unit,
        betrw_net       TYPE tinv_inv_line_b-betrw_net,
        taxbw           TYPE tinv_inv_line_b-taxbw,
        date_of_payment TYPE tinv_inv_line_b-date_of_payment,
        mwskz           TYPE tinv_inv_line_b-mwskz,
        strpz           TYPE tinv_inv_line_b-strpz,
      END OF s_ext_out.
DATA: t_ext_out LIKE STANDARD TABLE OF s_ext_out.

DATA: s_sidpro  TYPE edereg_sidpro,
      s_sidprot TYPE edereg_sidprot.

DATA: s_invchk_mail TYPE /adesso/chk_mail,
      t_invchk_mail TYPE STANDARD TABLE OF /adesso/chk_mail.

DATA: s_header TYPE thead.
DATA: s_line TYPE tline,
      t_line TYPE TABLE OF tline.

*-----------------------------------------------------------------------
* ALV
*-----------------------------------------------------------------------
TYPE-POOLS: slis.
INCLUDE <icon>.

DATA: gt_fieldcat         TYPE slis_t_fieldcat_alv WITH HEADER LINE.
DATA: gt_sort             TYPE slis_t_sortinfo_alv WITH HEADER LINE.
DATA: gt_sp_group         TYPE slis_t_sp_group_alv.
DATA: gt_events           TYPE slis_t_event.
DATA: gt_list_top_of_page TYPE slis_t_listheader.
DATA: gt_filtered         TYPE slis_t_filtered_entries.
DATA: gt_listheader       TYPE slis_t_listheader.

DATA: gs_layout     TYPE slis_layout_alv.
DATA: gs_keyinfo    TYPE slis_keyinfo_alv.
DATA: gs_fieldcat   TYPE slis_fieldcat_alv.
DATA: gs_listheader TYPE slis_listheader.
DATA: gs_variant    LIKE disvariant.
DATA: gx_variant    LIKE disvariant.
DATA: gs_ex         LIKE ltex-exname.
DATA: gs_extract    TYPE disextract.
DATA: gs_extadmin   TYPE ltexadmin.

DATA: g_repid          TYPE sy-repid.
DATA: g_struct         TYPE dd02l-tabname.
DATA: g_tabname_header TYPE slis_tabname.
DATA: g_tabname_item   TYPE slis_tabname.
DATA: g_tabname        TYPE slis_tabname.
DATA: g_sav_ucomm      LIKE sy-ucomm.
DATA: g_block_line     LIKE sy-index.
DATA: g_block_beg      LIKE sy-index.
DATA: g_block_end      LIKE sy-index.
DATA: g_default        TYPE char1.
DATA: g_save           TYPE char1.
DATA: g_exit           TYPE char1.
DATA: g_lignam         TYPE slis_fieldname VALUE  'LIGHTS'.

*main list
DATA: gt_fieldcat_main TYPE slis_t_fieldcat_alv WITH HEADER LINE.
DATA: g_ucom_main      TYPE slis_formname VALUE 'ALV_UCOM_MAIN'.
DATA: g_status_main    TYPE slis_formname VALUE 'ALV_STATUS_MAIN'.

*main list
DATA: gt_fieldcat_invno TYPE slis_t_fieldcat_alv WITH HEADER LINE.
DATA: g_ucom_invno      TYPE slis_formname VALUE 'ALV_UCOM_INVNO'.
DATA: g_status_invno    TYPE slis_formname VALUE 'ALV_STATUS_INVNO'.

DATA: rev_alv TYPE REF TO cl_gui_alv_grid.
