*&---------------------------------------------------------------------*
*&  Include           /ADESSO/INKASSO_STATISTIK_TOP
*&---------------------------------------------------------------------*
TABLES: dfkkcoll.

DATA: gt_statistik TYPE TABLE OF /adesso/inkasso_statistik.
DATA: gs_statistik TYPE /adesso/inkasso_statistik.
DATA: gt_scol      TYPE lvc_t_scol.

DATA: gr_vkrpl TYPE RANGE OF vkont_kk.
DATA: gs_vkrpl LIKE LINE OF  gr_vkrpl.

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

SELECTION-SCREEN BEGIN OF BLOCK sel WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: so_inkgp FOR dfkkcoll-inkgp.
SELECT-OPTIONS: so_agdat FOR dfkkcoll-agdat.
SELECTION-SCREEN END OF BLOCK sel.
