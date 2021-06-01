*----------------------------------------------------------------------*
***INCLUDE /ADESSO/WO_MONITOR_ALV_FALV.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  ALV_INIT
*&---------------------------------------------------------------------*
FORM alv_init.

  g_repid       = sy-repid.
  g_save        = 'A'.

* Get default variant
  IF g_variant-variant IS INITIAL.
    gx_variant = g_variant.
    CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
      EXPORTING
        i_save     = g_save
      CHANGING
        cs_variant = gx_variant
      EXCEPTIONS
        not_found  = 2.
    IF sy-subrc = 0.
      g_variant-variant = gx_variant-variant.
    ENDIF.
  ENDIF.

  PERFORM alv_layout        USING gs_layout.
  PERFORM alv_sort          USING gt_sort.
  PERFORM alv_event         USING gt_event.
  PERFORM alv_keyinfo       USING gs_keyinfo.
  PERFORM alv_fldcat_head   USING gt_fieldcat.
  PERFORM alv_fldcat_item   USING gt_fieldcat.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ALV_LAYOUT
*&---------------------------------------------------------------------*
FORM alv_layout USING  fs_layout TYPE slis_layout_alv.

  fs_layout-zebra             = 'X'.
  fs_layout-colwidth_optimize = 'X'.
  fs_layout-expand_fieldname  = 'EXPAND'.
  fs_layout-window_titlebar   = g_title.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ALV_SORT
*&---------------------------------------------------------------------*
FORM alv_sort USING  ft_sort TYPE slis_t_sortinfo_alv.

  DATA: ls_sort TYPE slis_sortinfo_alv.

  REFRESH ft_sort.

  CLEAR ls_sort.
  ls_sort-spos = 1.
  ls_sort-fieldname = 'GPART'.
  ls_sort-up = 'X'.
  ls_sort-tabname = 'T_HEADER'.
  APPEND ls_sort TO ft_sort.

  CLEAR ls_sort.
  ls_sort-spos = 2.
  ls_sort-fieldname = 'VKONT'.
  ls_sort-up = 'X'.
  ls_sort-tabname = 'T_HEADER'.
  APPEND ls_sort TO ft_sort.

  CLEAR ls_sort.
  ls_sort-spos = 3.
  ls_sort-fieldname = 'HVORG'.
  ls_sort-down = 'X'.
  ls_sort-tabname = 'T_ITEMS'.
  APPEND ls_sort TO ft_sort.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ALV_EVENT
*&---------------------------------------------------------------------*
FORM alv_event  USING ft_event TYPE slis_t_event.

  DATA: ls_events TYPE slis_alv_event.
*
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'                      "#EC *
    EXPORTING
      i_list_type     = 4
    IMPORTING
      et_events       = ft_event
    EXCEPTIONS
      list_type_wrong = 1
      OTHERS          = 2.

  READ TABLE ft_event  WITH KEY name = slis_ev_top_of_page
                       INTO ls_events.
  IF sy-subrc = 0.
    MOVE slis_ev_top_of_page TO ls_events-form.
    MODIFY ft_event FROM ls_events INDEX sy-tabix.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ALV_KEYINFO
*&---------------------------------------------------------------------*
FORM alv_keyinfo USING fs_keyinfo TYPE slis_keyinfo_alv.

  fs_keyinfo-header01 = 'GPART'.
  fs_keyinfo-header02 = 'VKONT'.

  fs_keyinfo-item01 = 'GPART'.
  fs_keyinfo-item02 = 'VKONT'.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ALV_FLDCAT_HEAD
*&---------------------------------------------------------------------*
FORM alv_fldcat_head USING ft_fieldcat TYPE slis_t_fieldcat_alv.

  DATA: lt_fieldcat TYPE slis_t_fieldcat_alv.
  DATA: ls_fieldcat TYPE slis_fieldcat_alv.
  DATA: lv_struct   TYPE dd02l-tabname.

  lv_struct = '/ADESSO/WO_HEADER'.

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

  LOOP AT lt_fieldcat INTO ls_fieldcat.

    ls_fieldcat-tabname = 'GT_HEADER'.

    CASE ls_fieldcat-fieldname.

**  Checkbox für Selektion
      WHEN 'SEL'.
        ls_fieldcat-edit = 'X'.
        ls_fieldcat-input = 'X'.
        ls_fieldcat-checkbox = 'X'.
        ls_fieldcat-seltext_s = 'Sel'.
        ls_fieldcat-seltext_m = 'Sel'.
        ls_fieldcat-seltext_l = 'Sel'.

** Status-Icon für Status
      WHEN 'STATUS'.
        ls_fieldcat-icon        = 'X'.
        ls_fieldcat-seltext_s   = 'Status'.
        ls_fieldcat-seltext_m   = 'Status'.
        ls_fieldcat-seltext_l   = 'Status'.

** Geschäftspartnernummer
      WHEN 'GPART'.
        ls_fieldcat-hotspot = 'X'.

      WHEN 'LOCKED'.
        ls_fieldcat-icon        = 'X'.
        ls_fieldcat-seltext_s   = 'Gesperrt'.
        ls_fieldcat-seltext_m   = 'Gesperrt'.
        ls_fieldcat-seltext_l   = 'Gesperrt'.

** Vertragskonto
      WHEN 'VKONT'.
        ls_fieldcat-hotspot = 'X'.

** Inkassobüro
      WHEN 'INKGP'.
        ls_fieldcat-hotspot = 'X'.

** Betrag
      WHEN 'BETRW'.
        ls_fieldcat-do_sum = 'X'.

** Betrag
      WHEN 'ABDAT'.
        ls_fieldcat-seltext_s = 'Ausb.Dat.'.
        ls_fieldcat-seltext_m = 'Ausb.Datum'.
        ls_fieldcat-seltext_l = 'Ausb.Datum'.

** interner Vermerk
      WHEN 'INTVERM'.
        ls_fieldcat-seltext_s = 'Genehmigungen'.
        ls_fieldcat-seltext_m = 'Genehmigungen'.
        ls_fieldcat-seltext_l = 'Genehmigungen'.
        ls_fieldcat-hotspot = 'X'.
        ls_fieldcat-outputlen = 20.

* Dokumentation
      WHEN 'IC_DOCU'.
        ls_fieldcat-hotspot     = 'X'.
        ls_fieldcat-icon        = 'X'.
        ls_fieldcat-seltext_s   = 'Doku'.
        ls_fieldcat-seltext_m   = 'Dokumentation'.
        ls_fieldcat-seltext_l   = 'Dokumentation'.

      WHEN 'IC_AGSTA'.
        ls_fieldcat-icon        = 'X'.
        ls_fieldcat-seltext_s   = 'ISta'.
        ls_fieldcat-seltext_m   = 'Ink.Stat.'.
        ls_fieldcat-seltext_l   = 'Ink.Status'.

** interner Vermerk
      WHEN 'EXPAND'.
        ls_fieldcat-tech = 'X'.
    ENDCASE.

    MODIFY lt_fieldcat FROM ls_fieldcat.

  ENDLOOP.

  APPEND LINES OF lt_fieldcat TO gt_fieldcat.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ALV_FLDCAT_ITEM
*&---------------------------------------------------------------------*
FORM alv_fldcat_item USING ft_fieldcat TYPE slis_t_fieldcat_alv.

  DATA: lt_fieldcat TYPE slis_t_fieldcat_alv.
  DATA: ls_fieldcat TYPE slis_fieldcat_alv.
  DATA: lv_struct   TYPE dd02l-tabname.

  lv_struct = '/ADESSO/WO_ITEMS'.

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


  LOOP AT lt_fieldcat INTO ls_fieldcat.

    ls_fieldcat-tabname = 'GT_ITEMS'.

    CASE ls_fieldcat-fieldname.

**  Checkbox für Selektion
      WHEN 'SEL'.
        ls_fieldcat-edit = 'X'.
        ls_fieldcat-input = 'X'.
        ls_fieldcat-checkbox = 'X'.
        ls_fieldcat-seltext_s = 'Sel'.
        ls_fieldcat-seltext_m = 'Sel'.
        ls_fieldcat-seltext_l = 'Sel'.

** Status-Icon für Status
      WHEN 'STATUS'.
        ls_fieldcat-icon        = 'X'.
        ls_fieldcat-seltext_s   = 'Status'.
        ls_fieldcat-seltext_m   = 'Status'.
        ls_fieldcat-seltext_l   = 'Status'.

* Beleg
      WHEN 'OPBEL'.
        ls_fieldcat-hotspot = 'X'.
*
* Betrag
      WHEN 'BETRW'.
        ls_fieldcat-do_sum = 'X'.
*
* Ausbuchungsbeleg
      WHEN 'ABBEL'.
        ls_fieldcat-hotspot = 'X'.

    ENDCASE.

    MODIFY lt_fieldcat FROM ls_fieldcat.

  ENDLOOP.

  APPEND LINES OF lt_fieldcat TO gt_fieldcat.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ALV_VARIANT_INIT
*&---------------------------------------------------------------------*
FORM alv_variant_init .

  g_repid = sy-repid.

  CLEAR g_variant.
  g_variant-report = g_repid.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ALV_DISPLAY
*&---------------------------------------------------------------------*
FORM alv_display .

  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
    EXPORTING
      i_callback_program       = g_repid
      i_callback_pf_status_set = g_status
      i_callback_user_command  = g_user_command
      is_layout                = gs_layout
      it_fieldcat              = gt_fieldcat[]
      it_excluding             = gt_extab[]
      it_sort                  = gt_sort
      i_save                   = g_save
      is_variant               = g_variant
      it_events                = gt_event
      i_tabname_header         = 'GT_HEADER'
      i_tabname_item           = 'GT_ITEMS'
      is_keyinfo               = gs_keyinfo
    TABLES
      t_outtab_header          = gt_header
      t_outtab_item            = gt_items
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  top_of_page
*&---------------------------------------------------------------------*
FORM top_of_page.

  DATA: lv_tabix  TYPE sy-tabix.
  DATA: lv_sell   TYPE sy-tabix.
  DATA: lv_wroff  TYPE sy-tabix.
  DATA: anzahl    TYPE string.

  REFRESH: gt_listheader.

  DESCRIBE TABLE gt_header LINES lv_tabix.

  LOOP AT gt_header INTO gs_header.
    IF gs_header-wovks IN gr_vks_sell.
      lv_sell = lv_sell + 1.
    ELSE.
      lv_wroff = lv_wroff + 1.
    ENDIF.
  ENDLOOP.

  MOVE lv_tabix TO anzahl.
  CLEAR: gs_listheader.
  gs_listheader-typ = 'S'.
  gs_listheader-key = 'Anzahl Vorgänge:'.
  gs_listheader-info = anzahl.
  APPEND gs_listheader TO gt_listheader.

  MOVE lv_wroff TO anzahl.
  CLEAR: gs_listheader.
  gs_listheader-typ = 'S'.
  gs_listheader-key = 'Int. Ausbuchungen:'.
  gs_listheader-info = anzahl.
  APPEND gs_listheader TO gt_listheader.

  MOVE lv_sell TO anzahl.
  CLEAR: gs_listheader.
  gs_listheader-typ = 'S'.
  gs_listheader-key = 'Verkäufe:'.
  gs_listheader-info = anzahl.
  APPEND gs_listheader TO gt_listheader.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = gt_listheader.

ENDFORM.
