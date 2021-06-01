*&---------------------------------------------------------------------*
*&  Include           /ADESSO/INKASSO_MONITOR_TOP
*&---------------------------------------------------------------------*

TABLES: /adesso/inkasso_items.
TABLES: /adesso/wo_mon.
TABLES: /adesso/wo_req.
TABLES: sscrfields.

DATA: gt_return TYPE TABLE OF ddshretval.
DATA: gs_return TYPE ddshretval.


* Customizing
DATA: gt_nfhf    TYPE TABLE OF /adesso/ink_nfhf.  "Hauptvorgänge SR/HF/NF
DATA: gs_nfhf    TYPE /adesso/ink_nfhf.
DATA: gt_nf_mahn TYPE TABLE OF /adesso/ink_nfhf.  "HV / TV Mahnung
DATA: gt_begr    TYPE TABLE OF /adesso/ink_begr.   "Berechtigungsgruppen
DATA: gs_begr    TYPE /adesso/ink_begr.
DATA: gt_bgus    TYPE TABLE OF /adesso/ink_bgus.   "User - Berechtigungsgruppe
DATA: gs_bgus    TYPE /adesso/ink_bgus.
DATA: gt_bgss    TYPE TABLE OF /adesso/ink_bgss.   "Steuerung Sel/Fkt pro Berechtigungsgruppe
DATA: gs_bgss    TYPE /adesso/ink_bgss.
DATA: gt_bgsb    TYPE TABLE OF /adesso/ink_bgsb.   "Steuerung Bearbeitung
DATA: gs_bgsb    TYPE /adesso/ink_bgsb.
DATA: gt_stat    TYPE TABLE OF /adesso/ink_stat.   "Statusverwaltung Berechtigungsgruppe
DATA: gs_stat    TYPE /adesso/ink_stat.
DATA: gt_cust    TYPE TABLE OF /adesso/ink_cust.  "Customizing allgemein
DATA: gs_cust    TYPE /adesso/ink_cust.
DATA: gt_dd03m   TYPE STANDARD TABLE OF dd03m.
DATA: gs_dd03m   TYPE dd03m.

DATA: gt_cust_wo  TYPE TABLE OF /adesso/wo_cust.  "Customizing Ausbuchungen
DATA: gt_wo_frei  TYPE TABLE OF /adesso/wo_frei. " Freigaben Ausbuchungen
DATA: gs_wo_frei  TYPE /adesso/wo_frei.
DATA: gt_wo_begr  TYPE TABLE OF /adesso/wo_begr. " Ber.Gruppe Ausbuchungen
DATA: gs_wo_begr  TYPE /adesso/wo_begr.
DATA: gt_vkst     TYPE TABLE OF /adesso/wo_vkst.  "Verkaufsquote Texte
DATA: gt_igrdt    TYPE TABLE OF /adesso/wo_igrdt. "Int.Ausbuchungsgrund Texte
DATA: gt_tfk048at TYPE TABLE OF tfk048at.          "Ausbuchungsgrund Texte

DATA: gv_icon TYPE iconname.

* Selektionen
DATA: t_gpvk TYPE TABLE OF /adesso/inkasso_select.
DATA: t_gpvk_md TYPE TABLE OF /adesso/inkasso_select.
DATA: t_select TYPE TABLE OF /adesso/inkasso_select.

DATA: gs_vktyp TYPE /adesso/inkasso_vktyp,
      gt_vktyp TYPE /adesso/inkasso_vktypt,
      gs_regio TYPE /adesso/inkasso_regio,
      gt_regio TYPE /adesso/inkasso_regiot,
      gs_spart TYPE /adesso/inkasso_spart,
      gt_spart TYPE /adesso/inkasso_spartt,
      gs_lockr TYPE /adesso/inkasso_lockr,
      gt_lockr TYPE /adesso/inkasso_lockrt.

DATA: gr_hvorg TYPE RANGE OF hvorg_kk.
DATA: gs_hvorg LIKE LINE OF gr_hvorg.

* Tabell für Ausgabe ALV
DATA: wa_out  TYPE  /adesso/inkasso_out.
DATA: wa_tout TYPE  /adesso/inkasso_out.
DATA: ft_out TYPE TABLE OF /adesso/inkasso_out.
DATA: t_out  TYPE TABLE OF /adesso/inkasso_out.

DATA: t_items TYPE TABLE OF /adesso/inkasso_items WITH HEADER LINE.
DATA: s_items TYPE /adesso/inkasso_items.
DATA: t_header TYPE TABLE OF /adesso/inkasso_header WITH HEADER LINE.
DATA: s_header TYPE /adesso/inkasso_header.


DATA: gt_vkont TYPE RANGE OF vkont_kk.
DATA: gs_vkont LIKE LINE OF gt_vkont.

DATA: BEGIN OF gs_header_key,
        gpart TYPE gpart_kk,
        vkont TYPE vkont_kk,
      END OF gs_header_key.

DATA: gv_gplocked(1) TYPE c.
DATA: gv_info(40) TYPE c.

FIELD-SYMBOLS: <t_out> TYPE /adesso/inkasso_out.

DATA: wa_fkkop    TYPE fkkop,
      wa_dfkkcoll TYPE dfkkcoll,
      wa_fkkmaze  TYPE fkkmaze.
*      it_fkkmaze TYPE STANDARD TABLE OF fkkmaze.
* --> Nuss 04.2018
DATA: wa_fkkvk  TYPE fkkvk,
      wa_fkkvkp TYPE fkkvkp.
* <-- Nuss 04.2018

DATA: wa_name TYPE char35.

* Positionstabelle
DATA: pos_itab_marked TYPE TABLE OF /adesso/inkasso_out WITH HEADER LINE,
      pos_itab        TYPE /adesso/inkasso_out,                              "Nuss 06.2018
      ht_enqtab       LIKE ienqtab OCCURS 0 WITH HEADER LINE,
      t_history_coll  LIKE dfkkcollh OCCURS 0 WITH HEADER LINE.

DATA: wa_opt TYPE /adesso/inkasso_opt.

DATA:  error           TYPE i.
DATA:  okcode          LIKE sy-ucomm.


DATA: bdcdata TYPE TABLE OF bdcdata WITH HEADER LINE.
DATA: ok TYPE ok.

DATA: gs_texte TYPE /adesso/ink_text.
DATA: gv_overdue TYPE /adesso/overdue.
DATA: gv_popgv_code(4).

*Parallelisierung
DATA: BEGIN OF wa_tasks,
        name(40) TYPE c,
        count(4) TYPE n,
        low      TYPE sy-tabix,
        high     TYPE sy-tabix,
      END OF wa_tasks.
DATA: t_tasks  LIKE TABLE OF wa_tasks.
FIELD-SYMBOLS: <t_tasks> LIKE wa_tasks.
DATA: taskname LIKE wa_tasks-name.
DATA: taskcnt(4) TYPE n.

DATA: x_runts TYPE sy-tabix.
DATA: x_maxts TYPE sy-tabix.
DATA: x_uzeit TYPE sy-uzeit.
DATA: x_tabix      TYPE sy-tabix.
DATA: x_prtio      TYPE sy-tabix.


* ALV
TYPE-POOLS: slis.
DATA: rev_alv TYPE REF TO cl_gui_alv_grid.

DATA: g_repid             LIKE sy-repid,
      g_save              TYPE char1,
      g_exit              TYPE char1,
      gx_variant          LIKE disvariant,
      g_variant           LIKE disvariant,
      gs_layout           TYPE slis_layout_alv,
      gt_sort             TYPE slis_t_sortinfo_alv,
      gt_fieldcat         TYPE slis_t_fieldcat_alv,
      gt_extab            TYPE slis_t_extab,                           "Nuss 05.2018
      g_user_command      TYPE slis_formname VALUE 'USER_COMMAND',
      g_status            TYPE slis_formname VALUE 'STANDARD_INKASSO',
      g_tabname_all       TYPE slis_tabname,                           "Nuss 04.2018
      g_expa              TYPE char1,                                  "Nuss 05.2018
      gs_keyinfo          TYPE slis_keyinfo_alv,                         "Nuss 06.2018
      gt_fieldcat_header  TYPE slis_t_fieldcat_alv,                     "Nuss 06.2018
      gt_fieldcat_items   TYPE slis_t_fieldcat_alv,                     "Nuss 06.2018
      g_user_command_hier TYPE slis_formname VALUE 'USER_COMMAND_HIER'. "Nuss 06.2018
DATA: g_title             TYPE  lvc_title.

DATA: gt_event      TYPE slis_t_event.
DATA: gs_listheader TYPE slis_listheader.
DATA: gt_listheader TYPE slis_listheader OCCURS 1.
DATA: x_lines TYPE i.
DATA: c_lines(10) TYPE c.

* Für Extrakt
DATA: h_ex LIKE ltex-exname.
DATA: h_extract TYPE disextract.
DATA: h_extadmin TYPE ltexadmin.

* Konstanten
CONSTANTS: c_disabled TYPE raw4 VALUE '00100000'.
CONSTANTS: c_enabled  TYPE raw4 VALUE '00080000'.
CONSTANTS: c_ibut_save  LIKE icon-name VALUE icon_system_save.
CONSTANTS: c_ibut_dele LIKE icon-name  VALUE icon_delete.

CONSTANTS: const_aggrd_einzelabgabe   LIKE dfkkcoll-aggrd VALUE '06',
           const_agsta_freigegeben    LIKE dfkkcoll-agsta VALUE '01',
           const_agsta_abgegeben      LIKE dfkkcoll-agsta VALUE '02',
           const_agsta_bezahlt        LIKE dfkkcoll-agsta VALUE '03',
           const_agsta_teilbezahlt    LIKE dfkkcoll-agsta VALUE '04',
           const_agsta_storniert      LIKE dfkkcoll-agsta VALUE '05',
           const_agsta_erfolglos      LIKE dfkkcoll-agsta VALUE '06',
           const_agsta_cu_t-erfolglos LIKE dfkkcoll-agsta VALUE '07',
           const_agsta_t-erfolglos    LIKE dfkkcoll-agsta VALUE '08',
           const_agsta_recalled       LIKE dfkkcoll-agsta VALUE '09',
           const_agsta_cust_pay       LIKE dfkkcoll-agsta VALUE '10',
           const_agsta_cust_p_pay     LIKE dfkkcoll-agsta VALUE '11',
           const_agsta_paid           LIKE dfkkcoll-agsta VALUE '12',
           const_agsta_p_paid         LIKE dfkkcoll-agsta VALUE '13',
           const_agsta_rel_erfolglos  LIKE dfkkcoll-agsta VALUE '14',
           const_agsta_wroff          LIKE dfkkcoll-agsta VALUE '20',
           const_agsta_sell           LIKE dfkkcoll-agsta VALUE '30',
           const_agsta_dswo           LIKE dfkkcoll-agsta VALUE '31',
           const_agsta_dsrc           LIKE dfkkcoll-agsta VALUE '32',
           const_agsta_vorm           LIKE dfkkcoll-agsta VALUE '99',
           const_agsta_look           LIKE dfkkcoll-agsta VALUE '98',
           const_agsta_chkd           LIKE dfkkcoll-agsta VALUE '97',
           const_chara(1)             TYPE c VALUE 'A',
           const_marked(1)            TYPE c VALUE 'X'.

CONSTANTS: c_prtio           TYPE sy-tabix VALUE 1000.
CONSTANTS: c_maxtb           TYPE sy-tabix VALUE 5.
CONSTANTS: c_maxtd           TYPE sy-tabix VALUE 10.
CONSTANTS: const_alv(4)      TYPE c VALUE 'ALV '.
CONSTANTS: const_hier(4)     TYPE c VALUE 'HIER'.

CONSTANTS: c_mode_upd  TYPE char1 VALUE 'U'.
CONSTANTS: c_mode_mod  TYPE char1 VALUE 'M'.
CONSTANTS: c_mode_del  TYPE char1 VALUE 'D'.
CONSTANTS: c_mode_ins  TYPE char1 VALUE 'I'.
CONSTANTS: const_abbri TYPE /adesso/ink_abbruch VALUE 'SEG'.
