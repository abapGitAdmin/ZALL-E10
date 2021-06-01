************************************************************************
*            _
*   __ _  __| | ___  ___ ___  ___
*  / _` |/ _` |/ _ \/ __/ __|/ _ \
* | (_| | (_| |  __/\__ \__ \ (_) |
*  \__,_|\__,_|\___||___/___/\___/
************************************************************************
*&---------------------------------------------------------------------*
*& Report  /ADESSO/INKASSO_MONITOR
*&---------------------------------------------------------------------*
REPORT /adesso/inkasso_statistik.

INCLUDE /adesso/inkasso_statistik_top.

**************************************************************************
* START-OF-SELECTION
**************************************************************************
START-OF-SELECTION.

  PERFORM set_colors.
  PERFORM get_data.

**************************************************************************
* END-OF-SELECTION
**************************************************************************
END-OF-SELECTION.

  g_repid       = sy-repid.
  g_save        = 'A'.

  PERFORM alv_layout    USING gs_layout.
  PERFORM alv_sortieren USING gt_sort[].
  PERFORM alv_fieldcat  USING gt_fieldcat[].
  PERFORM alv_display.

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
FORM get_data .

  DATA: BEGIN OF ls_stat,
          agdat TYPE agdat_kk,
          inkgp TYPE inkgp_kk,
          waers TYPE waers,
          count TYPE i,
          sum   TYPE p DECIMALS 2,
        END OF ls_stat.

  DATA: lt_vzi LIKE TABLE OF ls_stat WITH EMPTY KEY.
  DATA: lt_tzi LIKE TABLE OF ls_stat WITH EMPTY KEY.
  DATA: lt_rpi LIKE TABLE OF ls_stat WITH EMPTY KEY.
  DATA: lt_off LIKE TABLE OF ls_stat WITH EMPTY KEY.
  DATA: lt_agl LIKE TABLE OF ls_stat WITH EMPTY KEY.
  DATA: lt_rec LIKE TABLE OF ls_stat WITH EMPTY KEY.
  DATA: lt_sto LIKE TABLE OF ls_stat WITH EMPTY KEY.
  DATA: lt_aus LIKE TABLE OF ls_stat WITH EMPTY KEY.

* Initial Befüllen mt Abgegebene VK / Betrag
  SELECT agdat, inkgp, waers,
         COUNT( DISTINCT vkont ) AS abg_vk,
         SUM( betrw ) AS abg_btr
         FROM dfkkcollh
         WHERE agsta = '02'
         AND   agdat IN @so_agdat
         AND   inkgp IN @so_inkgp
         GROUP BY agdat, inkgp, waers
         ORDER BY agdat, inkgp, waers
         INTO CORRESPONDING FIELDS OF TABLE @gt_statistik .

* Spätere Verarbeitung alle VK mit RPL beim InkGp holen
  PERFORM get_vk_rpl_igp.

* Dann alle weiteren Stati auswerten
* Alle mit VZ vom IGP
  SELECT agdat, inkgp, waers, COUNT( DISTINCT vkont ), SUM( betrz )
       FROM dfkkcoll
       WHERE agsta = '03'
       AND   agdat IN @so_agdat
       AND   inkgp IN @so_inkgp
       GROUP BY agdat, inkgp, waers
       ORDER BY agdat, inkgp, waers
       INTO TABLE @lt_vzi.

* Alle mit TZ vom IGP
  SELECT agdat, inkgp, waers, COUNT( DISTINCT vkont ), SUM( betrz )
       FROM dfkkcoll
       WHERE agsta = '04'
       AND   agdat IN @so_agdat
       AND   inkgp IN @so_inkgp
       GROUP BY agdat, inkgp, waers
       ORDER BY agdat, inkgp, waers
       INTO TABLE @lt_tzi.

* Alle ZE / Agl direkt
  SELECT agdat, inkgp, waers, COUNT( DISTINCT vkont ), SUM( betrz )
       FROM dfkkcoll
       WHERE agsta BETWEEN '10' AND '13'
       AND   agdat IN @so_agdat
       AND   inkgp IN @so_inkgp
       GROUP BY agdat, inkgp, waers
       ORDER BY agdat, inkgp, waers
       INTO TABLE @lt_agl.

* Alle Stornos
  SELECT agdat, inkgp, waers, COUNT( DISTINCT vkont ), SUM( betrw )
       FROM dfkkcoll
       WHERE agsta = '05'
       AND   agdat IN @so_agdat
       AND   inkgp IN @so_inkgp
       GROUP BY agdat, inkgp, waers
       ORDER BY agdat, inkgp, waers
       INTO TABLE @lt_sto.

* Alle Rückrufe
  SELECT agdat, inkgp, waers, COUNT( DISTINCT vkont ), SUM( betrw )
       FROM dfkkcoll
       WHERE agsta = '09'
       AND   agdat IN @so_agdat
       AND   inkgp IN @so_inkgp
       GROUP BY agdat, inkgp, waers
       ORDER BY agdat, inkgp, waers
       INTO TABLE @lt_rec.

* Alle Ausbuchungen
  SELECT agdat, inkgp, waers, COUNT( DISTINCT vkont ), SUM( ninkb )
       FROM dfkkcoll
       WHERE agsta BETWEEN '06' AND '08'
       AND   agdat IN @so_agdat
       AND   inkgp IN @so_inkgp
       GROUP BY agdat, inkgp, waers
       ORDER BY agdat, inkgp, waers
       INTO TABLE @lt_aus.

* Alle mit ratenplan und noch offen
  IF gr_vkrpl[] IS NOT INITIAL.
    SELECT agdat, inkgp, waers, COUNT( DISTINCT vkont ), SUM( betrw )
         FROM dfkkcoll
         WHERE agsta = '02'
         AND   agdat IN @so_agdat
         AND   inkgp IN @so_inkgp
         AND   vkont IN @gr_vkrpl
         GROUP BY agdat, inkgp, waers
         ORDER BY agdat, inkgp, waers
         INTO TABLE @lt_rpi.
  ENDIF.

* Alle noch offenen beim IGP
  IF gr_vkrpl[] IS NOT INITIAL.
* jetzt die mit RPL ausschließen
    CLEAR gs_vkrpl.
    gs_vkrpl-sign   = 'E'.
    MODIFY gr_vkrpl FROM gs_vkrpl
           TRANSPORTING sign
           WHERE low NE space.

    SELECT agdat, inkgp, waers, COUNT( DISTINCT vkont ), SUM( betrw )
         FROM dfkkcoll
         WHERE agsta = '02'
         AND   agdat IN @so_agdat
         AND   inkgp IN @so_inkgp
         AND   vkont IN @gr_vkrpl
         GROUP BY agdat, inkgp, waers
         ORDER BY agdat, inkgp, waers
         INTO TABLE @lt_off.
  ELSE.
    SELECT agdat, inkgp, waers, COUNT( DISTINCT vkont ), SUM( betrw )
         FROM dfkkcoll
         WHERE agsta = '02'
         AND   agdat IN @so_agdat
         AND   inkgp IN @so_inkgp
         GROUP BY agdat, inkgp, waers
         ORDER BY agdat, inkgp, waers
         INTO TABLE @lt_off.
  ENDIF.

* Dann füllen der Statistiktabelle mit den zusätzlichen Werten
  LOOP AT gt_statistik INTO gs_statistik.

* Alle mit VZ vom IGP
    CLEAR ls_stat.
    READ TABLE lt_vzi INTO ls_stat
         WITH KEY agdat = gs_statistik-agdat
                  inkgp = gs_statistik-inkgp
                  waers = gs_statistik-waers
                  BINARY SEARCH.
    IF sy-subrc = 0.
      gs_statistik-vzi_vk  = ls_stat-count.
      gs_statistik-vzi_btr = ls_stat-sum.
    ENDIF.

* Alle mit TZ vom IGP
    CLEAR ls_stat.
    READ TABLE lt_tzi INTO ls_stat
         WITH KEY agdat = gs_statistik-agdat
                  inkgp = gs_statistik-inkgp
                  waers = gs_statistik-waers
                  BINARY SEARCH.
    IF sy-subrc = 0.
      gs_statistik-tzi_vk  = ls_stat-count.
      gs_statistik-tzi_btr = ls_stat-sum.
    ENDIF.

* Alle ZE / Agl direkt
    CLEAR ls_stat.
    READ TABLE lt_agl INTO ls_stat
         WITH KEY agdat = gs_statistik-agdat
                  inkgp = gs_statistik-inkgp
                  waers = gs_statistik-waers
                  BINARY SEARCH.
    IF sy-subrc = 0.
      gs_statistik-agl_vk  = ls_stat-count.
      gs_statistik-agl_btr = ls_stat-sum.
    ENDIF.

* Alle Stornos
    CLEAR ls_stat.
    READ TABLE lt_sto INTO ls_stat
         WITH KEY agdat = gs_statistik-agdat
                  inkgp = gs_statistik-inkgp
                  waers = gs_statistik-waers
                  BINARY SEARCH.
    IF sy-subrc = 0.
      gs_statistik-sto_vk  = ls_stat-count.
      gs_statistik-sto_btr = ls_stat-sum.
    ENDIF.

* Alle Rückrufe
    CLEAR ls_stat.
    READ TABLE lt_rec INTO ls_stat
         WITH KEY agdat = gs_statistik-agdat
                  inkgp = gs_statistik-inkgp
                  waers = gs_statistik-waers
                  BINARY SEARCH.
    IF sy-subrc = 0.
      gs_statistik-rec_vk  = ls_stat-count.
      gs_statistik-rec_btr = ls_stat-sum.
    ENDIF.

* Alle Ausbuchungen
    CLEAR ls_stat.
    READ TABLE lt_aus INTO ls_stat
         WITH KEY agdat = gs_statistik-agdat
                  inkgp = gs_statistik-inkgp
                  waers = gs_statistik-waers
                  BINARY SEARCH.
    IF sy-subrc = 0.
      gs_statistik-aus_vk  = ls_stat-count.
      gs_statistik-aus_btr = ls_stat-sum.
    ENDIF.

* Alle mit Ratenplan beim InkGP
    CLEAR ls_stat.
    READ TABLE lt_rpi INTO ls_stat
         WITH KEY agdat = gs_statistik-agdat
                  inkgp = gs_statistik-inkgp
                  waers = gs_statistik-waers
                  BINARY SEARCH.
    IF sy-subrc = 0.
      gs_statistik-rpi_vk  = ls_stat-count.
      gs_statistik-rpi_btr = ls_stat-sum.
    ENDIF.

* Alle noch offenen beim InkGP
    CLEAR ls_stat.
    READ TABLE lt_off INTO ls_stat
         WITH KEY agdat = gs_statistik-agdat
                  inkgp = gs_statistik-inkgp
                  waers = gs_statistik-waers
                  BINARY SEARCH.
    IF sy-subrc = 0.
      gs_statistik-off_vk  = ls_stat-count.
      gs_statistik-off_btr = ls_stat-sum.
    ENDIF.

    append LINES OF gt_scol to gs_statistik-ct.
    MODIFY gt_statistik FROM gs_statistik.

  ENDLOOP.


ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  ALV_LAYOUT
*&---------------------------------------------------------------------*
FORM alv_layout  USING  ls_layout TYPE slis_layout_alv.

  ls_layout-zebra = 'X'.
  ls_layout-colwidth_optimize = 'X'.
  ls_layout-window_titlebar = g_title.
  ls_layout-coltab_fieldname   = 'CT'.

ENDFORM.                    " LAYOUT_BUILD

*&---------------------------------------------------------------------*
*&      Form  ALV_SORTIEREN
*&---------------------------------------------------------------------*
FORM alv_sortieren  USING lt_sort TYPE slis_t_sortinfo_alv.

  DATA: ls_sort TYPE slis_sortinfo_alv.
  DATA: ls_sort_hier TYPE slis_sortinfo_alv.

  REFRESH lt_sort.

  CLEAR ls_sort.
  ls_sort-spos = 1.
  ls_sort-fieldname = 'AGDAT'.
  ls_sort-up = 'X'.
  APPEND ls_sort TO lt_sort.

ENDFORM.                    " ALV_SORTIEREN

*&---------------------------------------------------------------------*
*&      Form  ALV_FIELDCAT
*&---------------------------------------------------------------------*
FORM alv_fieldcat USING lt_fieldcat TYPE slis_t_fieldcat_alv.

  DATA: lv_struct   TYPE dd02l-tabname.
  DATA: ls_fieldcat TYPE slis_fieldcat_alv.

  lv_struct = '/ADESSO/INKASSO_STATISTIK'.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = g_repid
      i_structure_name       = lv_struct
      i_client_never_display = 'X'
      i_bypassing_buffer     = 'X'
    CHANGING
      ct_fieldcat            = lt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  LOOP AT lt_fieldcat INTO ls_fieldcat
       WHERE cfieldname NE space.
    ls_fieldcat-do_sum = 'X'.
    MODIFY lt_fieldcat FROM ls_fieldcat.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ALV_DISPLAY
*&---------------------------------------------------------------------*
FORM alv_display .

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      i_grid_title       = g_title
      is_layout          = gs_layout
      it_fieldcat        = gt_fieldcat[]
      it_sort            = gt_sort
*     i_save             = g_save
*     is_variant         = g_variant
*     it_events          = gt_event
    TABLES
      t_outtab           = gt_statistik
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_VK_RPL_IGP
*&---------------------------------------------------------------------*
FORM get_vk_rpl_igp .

  SELECT DISTINCT vkont AS low
         FROM /adesso/ink_infi
         WHERE ratenvb = 'X'
         INTO CORRESPONDING FIELDS OF TABLE @gr_vkrpl.

  CLEAR gs_vkrpl.
  gs_vkrpl-option = 'EQ'.
  gs_vkrpl-sign   = 'I'.
  MODIFY gr_vkrpl FROM gs_vkrpl
         TRANSPORTING option sign
         WHERE low NE space.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_COLORS
*&---------------------------------------------------------------------*
FORM set_colors .

  DATA:  ls_scol TYPE lvc_s_scol.

  ls_scol-fname = 'AGDAT'.
  ls_scol-color-col = '7'.
  ls_scol-color-int = '0'.
  APPEND ls_scol TO gt_scol.

  ls_scol-fname = 'INKGP'.
  ls_scol-color-col = '7'.
  ls_scol-color-int = '0'.
  APPEND ls_scol TO gt_scol.

  ls_scol-fname = 'WAERS'.
  ls_scol-color-col = '7'.
  ls_scol-color-int = '0'.
  APPEND ls_scol TO gt_scol.

  ls_scol-fname = 'ABG_VK'.
  ls_scol-color-col = '7'.
  ls_scol-color-int = '0'.
  APPEND ls_scol TO gt_scol.

  ls_scol-fname = 'ABG_BTR'.
  ls_scol-color-col = '7'.
  ls_scol-color-int = '0'.
  APPEND ls_scol TO gt_scol.

  ls_scol-fname = 'VZI_VK'.
  ls_scol-color-col = '5'.
  ls_scol-color-int = '0'.
  APPEND ls_scol TO gt_scol.

  ls_scol-fname = 'VZI_BTR'.
  ls_scol-color-col = '5'.
  ls_scol-color-int = '0'.
  APPEND ls_scol TO gt_scol.

  ls_scol-fname = 'TZI_VK'.
  ls_scol-color-col = '5'.
  ls_scol-color-int = '0'.
  APPEND ls_scol TO gt_scol.

  ls_scol-fname = 'TZI_BTR'.
  ls_scol-color-col = '5'.
  ls_scol-color-int = '0'.
  APPEND ls_scol TO gt_scol.

  ls_scol-fname = 'RPI_VK'.
  ls_scol-color-col = '5'.
  ls_scol-color-int = '0'.
  APPEND ls_scol TO gt_scol.

  ls_scol-fname = 'RPI_BTR'.
  ls_scol-color-col = '5'.
  ls_scol-color-int = '0'.
  APPEND ls_scol TO gt_scol.

  ls_scol-fname = 'OFF_VK'.
  ls_scol-color-col = '5'.
  ls_scol-color-int = '0'.
  APPEND ls_scol TO gt_scol.

  ls_scol-fname = 'OFF_BTR'.
  ls_scol-color-col = '5'.
  ls_scol-color-int = '0'.
  APPEND ls_scol TO gt_scol.

  ls_scol-fname = 'AGL_VK'.
  ls_scol-color-col = '1'.
  ls_scol-color-int = '0'.
  APPEND ls_scol TO gt_scol.

  ls_scol-fname = 'AGL_BTR'.
  ls_scol-color-col = '1'.
  ls_scol-color-int = '0'.
  APPEND ls_scol TO gt_scol.

  ls_scol-fname = 'REC_VK'.
  ls_scol-color-col = '1'.
  ls_scol-color-int = '0'.
  APPEND ls_scol TO gt_scol.

  ls_scol-fname = 'REC_BTR'.
  ls_scol-color-col = '1'.
  ls_scol-color-int = '0'.
  APPEND ls_scol TO gt_scol.

  ls_scol-fname = 'STO_VK'.
  ls_scol-color-col = '1'.
  ls_scol-color-int = '0'.
  APPEND ls_scol TO gt_scol.

  ls_scol-fname = 'STO_BTR'.
  ls_scol-color-col = '1'.
  ls_scol-color-int = '0'.
  APPEND ls_scol TO gt_scol.

  ls_scol-fname = 'AUS_VK'.
  ls_scol-color-col = '1'.
  ls_scol-color-int = '0'.
  APPEND ls_scol TO gt_scol.

  ls_scol-fname = 'AUS_BTR'.
  ls_scol-color-col = '1'.
  ls_scol-color-int = '0'.
  APPEND ls_scol TO gt_scol.

ENDFORM.
