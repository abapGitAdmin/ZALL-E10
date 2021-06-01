*&---------------------------------------------------------------------*
*&  Include           /ADESSO/WO_MONITOR_TOP
*&---------------------------------------------------------------------*
TABLES: /adesso/wo_mon.
TABLES: /adesso/wo_req.
TABLES: tfk048a.

* Selektionen
DATA: gt_gpvk TYPE TABLE OF /adesso/inkasso_select.

DATA: gt_wo_out TYPE TABLE OF /adesso/wo_out.
DATA: gs_wo_out TYPE /adesso/wo_out.

DATA: gt_header TYPE TABLE OF /adesso/wo_header WITH HEADER LINE.
DATA: gs_header TYPE /adesso/wo_header.
DATA: gt_items TYPE TABLE OF /adesso/wo_items WITH HEADER LINE.
DATA: gs_items TYPE /adesso/wo_items.

* Customizing
DATA: gt_wo_cust  TYPE TABLE OF /adesso/wo_cust.   "Customizing allgemein
DATA: gt_wo_vks   TYPE TABLE OF /adesso/wo_vks.    "Verkaufsquote
DATA: gt_nfhf     TYPE TABLE OF /adesso/ink_nfhf.  "Hauptvorgänge SR/HF/NF
DATA: gt_vkst     TYPE TABLE OF /adesso/wo_vkst.  "Verkaufsquote Texte
DATA: gt_igrdt    TYPE TABLE OF /adesso/wo_igrdt. "Int.Ausbuchungsgrund Texte
DATA: gt_tfk048at TYPE TABLE OF tfk048at.          "Ausbuchungsgrund Texte
DATA: gt_ink_cust TYPE TABLE OF /adesso/ink_cust.  "Customizing allgemein Inkasso
DATA: gs_Ink_cust TYPE /adesso/ink_cust.

DATA: gr_vks      TYPE RANGE OF /adesso/wo_wovks.
DATA: gr_vks_sell TYPE RANGE OF /adesso/wo_wovks.
DATA: gr_hvorg    TYPE RANGE OF hvorg_kk.
DATA: gr_wosta    TYPE RANGE OF /adesso/wo_wosta.
DATA: gr_abdat    TYPE RANGE OF abdat_kk.


DATA: gs_vks    LIKE LINE OF gr_vks.
DATA: gs_hvorg  LIKE LINE OF gr_hvorg.
DATA: gs_nfhf   TYPE /adesso/ink_nfhf.   "Hauptvorgänge SR/HF/NF
DATA: gs_wosta  LIKE LINE OF gr_wosta.

DATA: BEGIN OF gs_womonh_cha,
        gpart TYPE gpart_kk,
        vkont TYPE vkont_kk,
        wosta TYPE /adesso/wo_wosta,
        wohkf TYPE /adesso/wo_wohkf,
        agsta TYPE agsta_kk,
        aenam TYPE aenam_kk,
        aedat TYPE aedat,
        acptm TYPE acptm_kk,
      END OF gs_womonh_cha.

DATA: gv_gplocked(1) TYPE c.
DATA: gv_info(50) TYPE c.

DATA: ht_enqtab       LIKE ienqtab OCCURS 0 WITH HEADER LINE.

DATA: ok TYPE ok.

FIELD-SYMBOLS: <gs_header> TYPE /adesso/wo_header.

* Konstanten
CONSTANTS: const_wosta_vorm  TYPE /adesso/wo_wosta VALUE '01'.
CONSTANTS: const_wosta_look  TYPE /adesso/wo_wosta VALUE '02'.
CONSTANTS: const_wosta_chkd  TYPE /adesso/wo_wosta VALUE '03'.
CONSTANTS: const_wosta_ready TYPE /adesso/wo_wosta VALUE '10'.
CONSTANTS: const_wosta_frei1 TYPE /adesso/wo_wosta VALUE '11'.
CONSTANTS: const_wosta_frei2 TYPE /adesso/wo_wosta VALUE '12'.
CONSTANTS: const_wosta_decl  TYPE /adesso/wo_wosta VALUE '13'.
CONSTANTS: const_wosta_opwo  TYPE /adesso/wo_wosta VALUE '20'.

CONSTANTS: const_herkf_16    LIKE rfka1-herkf VALUE '16'.
CONSTANTS: const_buber_1052  LIKE tfkfbm-fbeve VALUE '1052'.


CONSTANTS: const_sell(5)  VALUE 'SELL'.
CONSTANTS: const_wroff(5) VALUE 'WROFF'.

CONSTANTS: const_marked VALUE 'X'.
CONSTANTS: const_insert VALUE 'I'.

* ALV
TYPE-POOLS: slis.
DATA: rev_alv TYPE REF TO cl_gui_alv_grid.

DATA: g_repid            LIKE sy-repid,
      g_save             TYPE char1,
      g_exit             TYPE char1,
      gx_variant         LIKE disvariant,
      g_variant          LIKE disvariant,
      gs_layout          TYPE slis_layout_alv,
      gt_sort            TYPE slis_t_sortinfo_alv,
      gt_fieldcat        TYPE slis_t_fieldcat_alv,
      gt_extab           TYPE slis_t_extab,
      g_user_command     TYPE slis_formname VALUE 'USER_COMMAND',
      g_status           TYPE slis_formname VALUE 'STANDARD_WO',
      g_tabname_all      TYPE slis_tabname,
      g_expa             TYPE char1,
      gs_keyinfo         TYPE slis_keyinfo_alv,
      gt_fieldcat_header TYPE slis_t_fieldcat_alv,
      gt_fieldcat_items  TYPE slis_t_fieldcat_alv.
DATA: g_title             TYPE  lvc_title.

DATA: gt_event      TYPE slis_t_event.
DATA: gs_listheader TYPE slis_listheader.
DATA: gt_listheader TYPE slis_listheader OCCURS 1.
