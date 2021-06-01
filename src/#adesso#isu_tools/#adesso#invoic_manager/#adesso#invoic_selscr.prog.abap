*&---------------------------------------------------------------------*
*&  Include           ZAD_INVOIC_SELSCR
*&---------------------------------------------------------------------*

*************************************************************************
* Selektionsbildschirm
*************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE text-b01.
SELECT-OPTIONS: so_abrkl FOR eanlh-aklasse.
SELECT-OPTIONS: so_tatyp FOR eanlh-tariftyp.
SELECT-OPTIONS: so_ablei FOR eanlh-ableinh. ".DEFAULT 'GERA-05'.
SELECT-OPTIONS: so_anlag FOR eanlh-anlage.
SELECTION-SCREEN END OF BLOCK b01.

SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE text-b02.
PARAMETERS: pa_datab LIKE tinv_inv_doc-invperiod_start.". DEFAULT '20000101' OBLIGATORY.
PARAMETERS: pa_datbi LIKE tinv_inv_doc-invperiod_end  ." DEFAULT '20151231' OBLIGATORY.
SELECTION-SCREEN SKIP.
SELECT-OPTIONS: s_rece  FOR tinv_inv_head-int_receiver,
                s_send  FOR tinv_inv_head-int_sender,
                s_insta FOR tinv_inv_head-invoice_status ," DEFAULT '01' TO '99',
                s_dtrec FOR tinv_inv_head-date_of_receipt.
SELECTION-SCREEN SKIP.
SELECT-OPTIONS: s_intido FOR tinv_inv_doc-int_inv_doc_no,

                s_idosta FOR tinv_inv_doc-inv_doc_status.
SELECTION-SCREEN END OF BLOCK b02.

SELECTION-SCREEN BEGIN OF BLOCK head WITH FRAME TITLE text-b03.
PARAMETERS: p_varia LIKE disvariant-variant.
SELECTION-SCREEN END OF BLOCK head.

*-----------------------------------------------------------------------
* At selection-screen
*-----------------------------------------------------------------------
at selection-screen on value-request for p_varia.
  perform alv_f4_variant.

at selection-screen.
  perform alv_pai_selscr.
