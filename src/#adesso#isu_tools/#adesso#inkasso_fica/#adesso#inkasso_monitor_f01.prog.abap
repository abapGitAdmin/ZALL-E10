*&---------------------------------------------------------------------*
*&  Include           /ADESSO/INKASSO_MONITOR_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  INIT_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_alv USING ff_alv_type TYPE char4.

  g_repid       = sy-repid.
  g_save        = 'A'.

  PERFORM layout_build USING gs_layout
                             ff_alv_type.

  PERFORM alv_sortieren USING gt_sort[]
                              ff_alv_type.

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

  PERFORM set_events.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  INIT_CUSTOM_FIELDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_custom_fields .

  FIELD-SYMBOLS: <var>,
                 <tab> TYPE STANDARD TABLE.

  DATA: gv_string TYPE string,
        gv_cust   TYPE /adesso/ink_cust,
        gv_type   TYPE typ.

  SELECT  * FROM /adesso/ink_cust INTO gv_cust WHERE inkasso_option = 'SELSCREEN'.
    ASSIGN (gv_cust-inkasso_field) TO <var>.
    <var> = gv_cust-inkasso_value.
  ENDSELECT.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  LAYOUT_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_LAYOUT  text
*----------------------------------------------------------------------*
FORM layout_build  USING  ls_layout TYPE slis_layout_alv
                          ff_alv_type TYPE char4.

  ls_layout-zebra = 'X'.
  ls_layout-colwidth_optimize = 'X'.

  IF ff_alv_type = const_hier.
    gs_layout-expand_fieldname = 'EXPAND'.
  ENDIF.

  ls_layout-window_titlebar = g_title.

ENDFORM.                    " LAYOUT_BUILD

*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_FIELDCAT[]  text
*----------------------------------------------------------------------*
FORM fieldcat_build   USING  lt_fieldcat TYPE slis_t_fieldcat_alv.

  DATA: ls_fieldcat TYPE slis_fieldcat_alv.

*  CLEAR ls_fieldcat.
*  ls_fieldcat-fieldname = 'XSELP'.
*  ls_fieldcat-tech      = 'X'.
*  ls_fieldcat-tabname = 'POS_ITAB'.
*  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'SEL'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-edit = 'X'.
  ls_fieldcat-input = 'X'.
  ls_fieldcat-checkbox = 'X'.
  ls_fieldcat-seltext_s = 'Selektion'.
  ls_fieldcat-seltext_m = 'Selektion'.
  ls_fieldcat-seltext_l = 'Selektion'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Status-Icon für Status
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname   = 'STATUS'.
  ls_fieldcat-tabname     = 'T_OUT'.
  ls_fieldcat-icon        = 'X'.
  ls_fieldcat-seltext_s   = 'Status'.
  ls_fieldcat-seltext_m   = 'Status'.
  ls_fieldcat-seltext_l   = 'Status'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Geschäftspartnernummer
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'GPART'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Vertragskonto
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'VKONT'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Belegnummer
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'OPBEL'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Vertrag
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'VTREF'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  ls_fieldcat-hotspot = 'X'.
  APPEND ls_fieldcat TO lt_fieldcat.


** Status-Icon für Status
*  CLEAR ls_fieldcat.
*  ls_fieldcat-fieldname   = 'STATUS'.
*  ls_fieldcat-tabname     = 'T_OUT'.
*  ls_fieldcat-icon        = 'X'.
*  ls_fieldcat-seltext_s   = 'Status'.
*  ls_fieldcat-seltext_m   = 'Status'.
*  ls_fieldcat-seltext_l   = 'Status'.
*  APPEND ls_fieldcat TO lt_fieldcat.
*
** selektionsflag
*  CLEAR ls_fieldcat.
*  ls_fieldcat-fieldname = 'SEL'.
*  ls_fieldcat-tabname = 'T_OUT'.
*  ls_fieldcat-edit = 'X'.
*  ls_fieldcat-input = 'X'.
*  ls_fieldcat-checkbox = 'X'.
*  ls_fieldcat-seltext_s = 'Selektion'.
*  ls_fieldcat-seltext_m = 'Selektion'.
*  ls_fieldcat-seltext_l = 'Selektion'.
*  APPEND ls_fieldcat TO lt_fieldcat.

* Geschäftspartner-Name
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'NAME'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-seltext_s = 'Name 1'.
  ls_fieldcat-seltext_m = 'Name 1'.
  ls_fieldcat-seltext_l = 'Name 1'.
  APPEND ls_fieldcat TO lt_fieldcat.

* -->Nuss 04.2018
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'NAME2'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-seltext_s = 'Name 2'.
  ls_fieldcat-seltext_m = 'Name 2'.
  ls_fieldcat-seltext_l = 'Name 2'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'NAME3'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-seltext_s = 'Name 3'.
  ls_fieldcat-seltext_m = 'Name 3'.
  ls_fieldcat-seltext_l = 'Name 3'.
  APPEND ls_fieldcat TO lt_fieldcat.
* <-- Nuss 04.2018

* Geburtsdatum
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BIRTHDT'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'BUT000'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Status: Kunde für Abgebe gesperrt
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname   = 'LOCKED'.
  ls_fieldcat-tabname     = 'T_OUT'.
  ls_fieldcat-icon        = 'X'.
  ls_fieldcat-seltext_s   = 'Gesperrt'.
  ls_fieldcat-seltext_m   = 'Gesperrt'.
  ls_fieldcat-seltext_l   = 'Gesperrt'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Unplausible Stammdaten
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'UNPLAUS'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-icon      = 'X'.
  ls_fieldcat-seltext_s = 'Unplaus'.
  ls_fieldcat-seltext_m = 'Unplausibel'.
  ls_fieldcat-seltext_l = 'Unplausible Stammdaten'.
  APPEND ls_fieldcat TO lt_fieldcat.

** Vertragskonto
*  CLEAR ls_fieldcat.
*  ls_fieldcat-fieldname = 'VKONT'.
*  ls_fieldcat-tabname = 'T_OUT'.
*  ls_fieldcat-hotspot = 'X'.
*  ls_fieldcat-ref_tabname = 'FKKOP'.
*  APPEND ls_fieldcat TO lt_fieldcat.

* Sachbearbeiter
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'SACHB'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-seltext_s = 'Sachbearb.'.
  ls_fieldcat-seltext_m = 'Sachbearbeiter'.
  ls_fieldcat-seltext_l = 'Sachbearbeiter'.
  APPEND ls_fieldcat TO lt_fieldcat.

* --> Nuss 04.2018
* kaufm. Regionalstrukturgruppe
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'REGIOGR_CA_B'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'FKKVKP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Mahnsperre
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'LOCKR'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-seltext_s = 'Mahnsp.'.
  ls_fieldcat-seltext_m = 'Mahnsperre'.
  ls_fieldcat-seltext_l = 'Mahnsperre'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Sparte
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'SPART'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Spartentext
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'VTEXT'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'TSPAT'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Hauptvorgang
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'HVORG'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Teilvorgang
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TVORG'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Teilvorgang (Text)
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TXT30'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'TFKTVOT'.
  APPEND ls_fieldcat TO lt_fieldcat.


** Belegnummer
*  CLEAR ls_fieldcat.
*  ls_fieldcat-fieldname = 'OPBEL'.
*  ls_fieldcat-tabname = 'T_OUT'.
*  ls_fieldcat-hotspot = 'X'.
*  ls_fieldcat-ref_tabname = 'FKKOP'.
*  APPEND ls_fieldcat TO lt_fieldcat.

* Inkasso Büro Vorschlag
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'INKVOR'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-seltext_s = 'Vorsch.Ink'.
  ls_fieldcat-seltext_m = 'Vorschlag Inkassobüro'.
  ls_fieldcat-seltext_l = 'Vorschlag Inkassobüro'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Inkassobüro
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'INKGP'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-ref_tabname = 'DFKKCOLL'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Inkassobüro-Name
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'INKNAME'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-seltext_s = 'NameInkGP'.
  ls_fieldcat-seltext_m = 'Name Inkassobüro'.
  ls_fieldcat-seltext_l = 'Name Inkassobüro'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Inkassoposition
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'INKPS'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Abgabestatus
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'AGSTA'.
  ls_fieldcat-tabname = 'POS_ITAB'.
  ls_fieldcat-ref_tabname = 'DFKKCOLL'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'AGSTATXT'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-seltext_s = 'TextStat'.
  ls_fieldcat-seltext_m = 'Text zum Status'.
  APPEND ls_fieldcat TO lt_fieldcat.


* Abgabegrund
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'AGGRD'.
  ls_fieldcat-tabname = 'POS_ITAB'.
  ls_fieldcat-ref_tabname = 'DFKKCOLL'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Mahnverfahren
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'MAHNV'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'FKKMAZE'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Mahnstufe
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'MAHNS'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'FKKMAZE'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Betrag
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BETRW'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-do_sum = 'X'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Währung
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'WAERS'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Fälligkeit
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'FAEDN'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Forderungshöhe unter Mindesthöhe
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname   = 'FORDHOEHE'.
  ls_fieldcat-tabname     = 'T_OUT'.
  ls_fieldcat-icon        = 'X'.
  ls_fieldcat-seltext_s   = 'Ford.Höhe'.
  ls_fieldcat-seltext_m   = 'Prüfung Ford.Höhe'.
  ls_fieldcat-seltext_l   = 'Prüfung Forderungshöhe'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Nebenforderung größer Hauptforderung
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname   = 'NFHF'.
  ls_fieldcat-tabname     = 'T_OUT'.
  ls_fieldcat-icon        = 'X'.
  ls_fieldcat-seltext_s   = 'NF > HF'.
  ls_fieldcat-seltext_m   = 'NF > HF'.
  ls_fieldcat-seltext_l   = 'Nebenford. > Hauptford.'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'OPUPW'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'OPUPK'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'OPUPZ'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Statistikkennzeichen
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'STAKZ'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Buchungsdatum
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BUDAT'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Belegdatum
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BLDAT'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Referenzbeleg
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'XBLNR'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Ausgleichsgrund
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'AUGRD'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Ausgebucht
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'AUSGEB'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-seltext_s = 'ausgeb.'.
  ls_fieldcat-seltext_m = 'ausgebucht'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Buchungskreis
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BUKRS'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

** Vertrag
*  CLEAR ls_fieldcat.
*  ls_fieldcat-fieldname = 'VTREF'.
*  ls_fieldcat-tabname = 'T_OUT'.
*  ls_fieldcat-ref_tabname = 'FKKOP'.
*  ls_fieldcat-hotspot = 'X'.
*  APPEND ls_fieldcat TO lt_fieldcat.

* Schlussabgerechnet
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BILLFIN'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-seltext_s = 'fakt.'.
  ls_fieldcat-seltext_m = 'fakturiert'.
  APPEND ls_fieldcat TO lt_fieldcat.

* --> Nuss 04.2018
* Freitext
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'FREETEXT'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-seltext_m = 'Freitext'.
  APPEND ls_fieldcat TO lt_fieldcat.
* <-- Nuss 04.2018

* --> Nuss 05.2018
* interner Vermerk
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'INTVERM'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-seltext_s = 'int. Verm'.
  ls_fieldcat-seltext_m = 'interner Vermerk'.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-outputlen = 20.
  APPEND ls_fieldcat TO lt_fieldcat.
* <-- Nuss 05.2018

ENDFORM.                    " FIELDCAT_BUILD

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_alv .

  SORT t_out.
  DELETE ADJACENT DUPLICATES FROM t_out COMPARING ALL FIELDS.

  CASE const_marked.

    WHEN pa_showh.

      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
        EXPORTING
          i_callback_program       = sy-repid
          i_callback_pf_status_set = g_status
          i_callback_user_command  = g_user_command
*         i_callback_top_of_page   = 'TOP_OF_PSAGE'
*         i_grid_title             = g_title
          is_layout                = gs_layout
          it_fieldcat              = gt_fieldcat[]
          it_excluding             = gt_extab[]
          it_sort                  = gt_sort
          i_save                   = g_save
          is_variant               = g_variant
          it_events                = gt_event
        TABLES
          t_outtab                 = t_out
        EXCEPTIONS
          program_error            = 1
          OTHERS                   = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN pa_liste.

      IF p_alv = 'X'.

        CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
          EXPORTING
            i_callback_program       = sy-repid
            i_callback_pf_status_set = g_status
            i_callback_user_command  = g_user_command
*           i_callback_top_of_page   = 'TOP_OF_PSAGE'
*           i_grid_title             = g_title
            is_layout                = gs_layout
            it_fieldcat              = gt_fieldcat[]
            it_excluding             = gt_extab[]
            it_sort                  = gt_sort
            i_save                   = g_save
            is_variant               = g_variant
            it_events                = gt_event
          TABLES
            t_outtab                 = t_out
          EXCEPTIONS
            program_error            = 1
            OTHERS                   = 2.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

      ELSEIF p_hier = 'X'.

        CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
          EXPORTING
*           I_INTERFACE_CHECK        = ' '
            i_callback_program       = sy-repid
            i_callback_pf_status_set = g_status
            i_callback_user_command  = g_user_command_hier
            is_layout                = gs_layout
            it_fieldcat              = gt_fieldcat[]
            it_excluding             = gt_extab[]
*           IT_SPECIAL_GROUPS        =
            it_sort                  = gt_sort
*           IT_FILTER                =
*           IS_SEL_HIDE              =
*           I_SCREEN_START_COLUMN    = 0
*           I_SCREEN_START_LINE      = 0
*           I_SCREEN_END_COLUMN      = 0
*           I_SCREEN_END_LINE        = 0
*           I_DEFAULT                = 'X'
            i_save                   = g_save
            is_variant               = g_variant
            it_events                = gt_event
*           IT_EVENT_EXIT            =
            i_tabname_header         = 'T_HEADER'
            i_tabname_item           = 'T_ITEMS'
*           I_STRUCTURE_NAME_HEADER  =
*           I_STRUCTURE_NAME_ITEM    =
            is_keyinfo               = gs_keyinfo
*           IS_PRINT                 =
*           IS_REPREP_ID             =
*           I_BYPASSING_BUFFER       =
*           I_BUFFER_ACTIVE          =
*           IR_SALV_HIERSEQ_ADAPTER  =
*           IT_EXCEPT_QINFO          =
*           I_SUPPRESS_EMPTY_DATA    = ABAP_FALSE
* IMPORTING
*           E_EXIT_CAUSED_BY_CALLER  =
*           ES_EXIT_CAUSED_BY_USER   =
          TABLES
            t_outtab_header          = t_header
            t_outtab_item            = t_items
          EXCEPTIONS
            program_error            = 1
            OTHERS                   = 2.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.


      ENDIF.

    WHEN pa_updhi.
      PERFORM save_extract.

  ENDCASE.

ENDFORM.                    " DISPLAY_ALV

*-----------------------------------------------------------------------
*    FORM PF_STATUS_SET
*-----------------------------------------------------------------------
*    ........
*-----------------------------------------------------------------------
*    --> extab
*-----------------------------------------------------------------------
FORM standard_inkasso USING extab TYPE slis_t_extab.

  DATA: fcodes TYPE LINE OF slis_t_extab.

  LOOP AT gt_bgss INTO gs_bgss
       WHERE begru    = gs_bgus-begru
       AND   bgcat_ss = 'EXCL_FKT'
       AND   inactiv  = const_marked.

    CLEAR fcodes.
    fcodes-fcode = gs_bgss-bgfld_ss.
    APPEND fcodes TO extab.

  ENDLOOP.

  SET PF-STATUS 'STANDARD_INKASSO' EXCLUDING extab.

ENDFORM.                    "status_standard

*-----------------------------------------------------------------------
*    FORM PF_STATUS_XXL
*-----------------------------------------------------------------------
*    ........
*-----------------------------------------------------------------------
*    --> extab
*-----------------------------------------------------------------------
FORM pf_status_xxl USING extab TYPE slis_t_extab.

  SET PF-STATUS 'STATUS_XXL' EXCLUDING extab.

ENDFORM.                    "status_standard

*&---------------------------------------------------------------------*
*&      Form  ALV_SORTIEREN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_SORT[]  text
*----------------------------------------------------------------------*
FORM alv_sortieren  USING    lt_sort TYPE slis_t_sortinfo_alv
                             ff_alv_type TYPE char4.

  DATA: ls_sort TYPE slis_sortinfo_alv.
  DATA: ls_sort_hier TYPE slis_sortinfo_alv.

  REFRESH lt_sort.

  CLEAR ls_sort.
  ls_sort-spos = 1.
  ls_sort-fieldname = 'GPART'.
  ls_sort-up = 'X'.
  IF ff_alv_type = const_alv.
    ls_sort-subtot = 'X'.
  ELSE.
    ls_sort-tabname = 'T_HEADER'.
  ENDIF.
  APPEND ls_sort TO lt_sort.

  CLEAR ls_sort.
  ls_sort-spos = 2.
  ls_sort-fieldname = 'VKONT'.
  ls_sort-up = 'X'.
  IF ff_alv_type = const_alv.
    ls_sort-subtot = 'X'.
  ELSE.
    ls_sort-tabname = 'T_HEADER'.
  ENDIF.
  APPEND ls_sort TO lt_sort.

  CLEAR ls_sort.
  ls_sort-spos = 3.
  ls_sort-fieldname = 'HVORG'.
  ls_sort-down = 'X'.
  IF ff_alv_type = const_alv.
  ELSE.
    ls_sort-tabname = 'T_ITEMS'.
  ENDIF.
  APPEND ls_sort TO lt_sort.

ENDFORM.                    " ALV_SORTIEREN

*&---------------------------------------------------------------------*
*&      Form  VARIANT_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM variant_init USING ff_alv_type TYPE char4.

  g_repid = sy-repid.

  CLEAR g_variant.
  g_variant-report = g_repid.
  g_variant-handle = ff_alv_type.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_EVENTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_events .

  DATA: ls_events TYPE slis_alv_event.
*
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'                      "#EC *
    EXPORTING
      i_list_type     = 4
    IMPORTING
      et_events       = gt_event
    EXCEPTIONS
      list_type_wrong = 1
      OTHERS          = 2.

  READ TABLE gt_event  WITH KEY name = slis_ev_top_of_page
                         INTO ls_events.
  IF sy-subrc = 0.
    MOVE slis_ev_top_of_page TO ls_events-form.
    MODIFY gt_event FROM ls_events INDEX sy-tabix.
  ENDIF.

ENDFORM.                    " SET_EVENTS

*&---------------------------------------------------------------------*
*&      Form  top_of_page
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM top_of_page.

  DATA: ls_items  TYPE /adesso/inkasso_items.
  DATA: ls_header TYPE /adesso/inkasso_header.

  CLEAR: gs_listheader.
  REFRESH gt_listheader.


  DATA: anzahl TYPE string.


* --> Nuss 04.2018
  DATA: BEGIN OF ls_gpart,
          gpart LIKE wa_out-gpart,
        END OF ls_gpart.
  DATA: lt_gpart LIKE STANDARD TABLE OF ls_gpart.

  DATA: BEGIN OF ls_vkont,
          vkont LIKE wa_out-vkont,
        END OF ls_vkont.
  DATA: lt_vkont LIKE STANDARD TABLE OF ls_vkont.

  DATA: BEGIN OF ls_vtref,
          vtref LIKE wa_out-vtref,
        END OF ls_vtref.
  DATA: lt_vtref LIKE STANDARD TABLE OF ls_vtref.

  IF p_hier = 'X'.
    LOOP AT t_items INTO ls_items.
      MOVE ls_items-gpart TO ls_gpart-gpart.
      MOVE ls_items-vkont TO ls_vkont-vkont.
      MOVE ls_items-vtref TO ls_vtref-vtref.
      COLLECT ls_gpart INTO lt_gpart.
      COLLECT ls_vkont INTO lt_vkont.
      COLLECT ls_vtref INTO lt_vtref.
    ENDLOOP.
  ELSE.
    LOOP AT t_out INTO wa_out.
      MOVE wa_out-gpart TO ls_gpart-gpart.
      MOVE wa_out-vkont TO ls_vkont-vkont.
      MOVE wa_out-vtref TO ls_vtref-vtref.
      COLLECT ls_gpart INTO lt_gpart.
      COLLECT ls_vkont INTO lt_vkont.
      COLLECT ls_vtref INTO lt_vtref.
    ENDLOOP.
  ENDIF.
* <-- Nuss 04.2018

  IF p_hier = 'X'.
    DESCRIBE TABLE t_items LINES x_tabix.
  ELSE.
    DESCRIBE TABLE t_out LINES x_tabix.
  ENDIF.
  MOVE x_tabix TO anzahl.
  gs_listheader-typ  = 'S'.
  gs_listheader-key  = 'Anzahl Posten:'.       "Nuss 04.2018
  gs_listheader-info = anzahl.                 "Nuss 04.2018
*  CONCATENATE anzahl 'Posten selektiert' INTO gs_listheader-info SEPARATED BY space."Nuss 04.2018
  APPEND gs_listheader TO gt_listheader.

* --> Nuss 04.2018
  DESCRIBE TABLE lt_gpart LINES x_tabix.
  MOVE x_tabix TO anzahl.
  gs_listheader-typ = 'S'.
  gs_listheader-key = 'Geschäftspartner:'.
  gs_listheader-info = anzahl.
  APPEND gs_listheader TO gt_listheader.

  DESCRIBE TABLE lt_vkont LINES x_tabix.
  MOVE x_tabix TO anzahl.
  gs_listheader-typ = 'S'.
  gs_listheader-key = 'Vertragskonten:'.
  gs_listheader-info = anzahl.
  APPEND gs_listheader TO gt_listheader.

  DESCRIBE TABLE lt_vtref LINES x_tabix.
  MOVE x_tabix TO anzahl.
  gs_listheader-typ = 'S'.
  gs_listheader-key = 'Verträge:'.
  gs_listheader-info = anzahl.
  APPEND gs_listheader TO gt_listheader.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = gt_listheader.

ENDFORM.                    "top_of_page

*&---------------------------------------------------------------------*
*&      Form  SHOW_HISTORY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM show_history .

* Extraktname bilden ----------------------------------------
* Schlüssel zum Extract bilden
  h_extract-report = sy-repid.

* F4 Hilfe für Extraktselektion
  CALL FUNCTION 'REUSE_ALV_EXTRACT_AT_F4_P_EX2'
* EXPORTING
*   I_PARNAME_P_EXT2       = 'P_EXT2'
    CHANGING
      c_p_ex2     = h_ex
      c_p_ext2    = h_ex
      cs_extract2 = h_extract.

* Extract Laden
  CALL FUNCTION 'REUSE_ALV_EXTRACT_LOAD'
    EXPORTING
      is_extract         = h_extract
*>>> UH 11102012
    IMPORTING
      es_admin           = h_extadmin
*<<< UH 11102012
    TABLES
      et_exp01           = t_out
    EXCEPTIONS
      not_found          = 1
      wrong_relid        = 2
      no_report          = 3
      no_exname          = 4
      no_import_possible = 5
      OTHERS             = 6.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.



ENDFORM.                    " SHOW_HISTORY

*&---------------------------------------------------------------------*
*&      Form  SHOW_INK_INFI
*&---------------------------------------------------------------------*
FORM show_ink_infi TABLES ft_vkont LIKE gt_vkont.

  DATA: lt_ink_infi TYPE TABLE OF /adesso/ink_infi.
  DATA: ls_sort TYPE slis_sortinfo_alv.
  DATA: lt_sort TYPE slis_t_sortinfo_alv.

  DATA: lt_fc_infi TYPE slis_t_fieldcat_alv.
  DATA: ls_fc_infi TYPE slis_fieldcat_alv.
  DATA: ls_layout  TYPE slis_layout_alv.

  REFRESH: lt_ink_infi.
  REFRESH: lt_sort.

  SELECT * FROM /adesso/ink_infi INTO TABLE lt_ink_infi
           WHERE vkont IN ft_vkont.

  DELETE ADJACENT DUPLICATES FROM lt_ink_infi COMPARING satztyp infodat inkgp gpart vkont.

  CLEAR ls_sort.
  ls_sort-spos = 1.
  ls_sort-fieldname = 'INFODAT'.
  ls_sort-up = 'X'.
  APPEND ls_sort TO lt_sort.

  CLEAR ls_sort.
  ls_sort-spos = 2.
  ls_sort-fieldname = 'VKONT'.
  ls_sort-up = 'X'.
  APPEND ls_sort TO lt_sort.

  ls_layout-zebra = 'X'.
  ls_layout-colwidth_optimize = 'X'.


  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_structure_name       = '/ADESSO/INK_INFI'
      i_client_never_display = 'X'
      i_bypassing_buffer     = 'X'
    CHANGING
      ct_fieldcat            = lt_fc_infi
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  LOOP AT lt_fc_infi INTO ls_fc_infi.

    CASE ls_fc_infi-fieldname.

**  Checkbox für Selektion
      WHEN 'OPBEL' OR 'INKPS'.
        ls_fc_infi-no_out = 'X'.
    ENDCASE.
    MODIFY lt_fc_infi FROM ls_fc_infi.

  ENDLOOP.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program    = g_repid
      i_grid_title          = 'Info vom InkGP'
*     i_structure_name      = '/ADESSO/INK_INFI'
      it_sort               = lt_sort
      is_layout             = ls_layout
      it_fieldcat           = lt_fc_infi
      i_screen_start_column = 5
      i_screen_start_line   = 5
      i_screen_end_column   = 150
      i_screen_end_line     = 20
    TABLES
      t_outtab              = lt_ink_infi
    EXCEPTIONS
      program_error         = 1
      OTHERS                = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  SHOW_DFKKCOLI_LOG
*&---------------------------------------------------------------------*
FORM show_dfkkcoli_log TABLES ft_vkont LIKE gt_vkont.

  DATA: lt_coli_log TYPE TABLE OF dfkkcoli_log.
  DATA: ls_sort     TYPE slis_sortinfo_alv.
  DATA: lt_sort     TYPE slis_t_sortinfo_alv.
  DATA: lt_fc_coli  TYPE slis_t_fieldcat_alv.
  DATA: ls_fc_coli  TYPE slis_fieldcat_alv.
  DATA: ls_layout   TYPE slis_layout_alv.

  REFRESH: lt_coli_log.
  REFRESH: lt_sort.

  SELECT * FROM dfkkcoli_log INTO TABLE lt_coli_log
           WHERE vkont IN ft_vkont.

  CLEAR ls_sort.
  ls_sort-spos = 1.
  ls_sort-fieldname = 'VKONT'.
  ls_sort-up = 'X'.
  APPEND ls_sort TO lt_sort.

  CLEAR ls_sort.
  ls_sort-spos = 1.
  ls_sort-fieldname = 'LAUFD'.
  ls_sort-up = 'X'.
  APPEND ls_sort TO lt_sort.

  ls_layout-zebra = 'X'.
  ls_layout-colwidth_optimize = 'X'.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_structure_name       = 'DFKKCOLI_LOG'
      i_client_never_display = 'X'
      i_bypassing_buffer     = 'X'
    CHANGING
      ct_fieldcat            = lt_fc_coli
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program    = g_repid
      i_grid_title          = 'Info an den InkGP'
      it_sort               = lt_sort
      is_layout             = ls_layout
      it_fieldcat           = lt_fc_coli
      i_screen_start_column = 5
      i_screen_start_line   = 5
      i_screen_end_column   = 150
      i_screen_end_line     = 20
    TABLES
      t_outtab              = lt_coli_log
    EXCEPTIONS
      program_error         = 1
      OTHERS                = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CREATE_HISTORY
*&---------------------------------------------------------------------*

FORM create_history TABLES   p_t_coll  STRUCTURE dfkkcoll.


  DATA: t_history_coll TYPE TABLE OF dfkkcollh WITH HEADER LINE.
  DATA: h_lfdnr     LIKE dfkkcollh-lfdnr,
        ht_fkkcollh LIKE dfkkcollh OCCURS 0 WITH HEADER LINE.

  CLEAR: t_history_coll, t_history_coll[].

  LOOP AT p_t_coll.
    MOVE-CORRESPONDING p_t_coll TO t_history_coll.

    t_history_coll-aenam = sy-uname.
    t_history_coll-acpdt = sy-datlo.
    t_history_coll-acptm = sy-timlo.

    CALL FUNCTION 'FKK_DB_DFKKCOLLH_COUNT'
      EXPORTING
        i_opbel = t_history_coll-opbel
        i_inkps = t_history_coll-inkps
      IMPORTING
        e_count = h_lfdnr.

    IF t_history_coll-agsta GT '20'.
      CLEAR t_history_coll-agsta_or.
    ENDIF.

    ADD 1 TO h_lfdnr.

    t_history_coll-lfdnr = h_lfdnr.

    APPEND t_history_coll.
  ENDLOOP.

  CALL FUNCTION 'FKK_DB_DFKKCOLLH_INSERT'
    TABLES
      i_dfkkcollh = t_history_coll.

ENDFORM.                    " create_history


*&---------------------------------------------------------------------*
*&      Form  SAVE_EXTRACT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_extract .

  DATA: h_extract TYPE disextract.

* Extraktname bilden ----------------------------------------
* Schlüssel zum Extract bilden
  CLEAR: h_extract.
* Programmname
  h_extract-report = sy-repid.
* Extrakt Text
  h_extract-text = TEXT-009.
  DESCRIBE TABLE t_out LINES x_tabix.
  WRITE x_tabix TO h_extract-text+15 LEFT-JUSTIFIED.

  h_extract-text+25 = TEXT-010.
  WRITE sy-uzeit TO h_extract-text+31 USING EDIT MASK '__:__:__'.

* Extrakt Name
  h_extract-exname   = sy-datum.
  h_extract-exname+8 = sy-uzeit.

  CALL FUNCTION 'REUSE_ALV_EXTRACT_SAVE'
    EXPORTING
      is_extract         = h_extract
      i_get_selinfos     = 'X'
    TABLES
      it_exp01           = t_out
    EXCEPTIONS
      wrong_relid        = 1
      no_report          = 2
      no_exname          = 3
      no_extract_created = 4
      OTHERS             = 5.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " SAVE_EXTRACT

*&---------------------------------------------------------------------*
*&      Form  F4_FOR_VARIANT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f4_for_variant CHANGING ff_variant TYPE disvariant-variant.

  CASE const_marked.
    WHEN p_alv.
      PERFORM variant_init USING const_alv.
    WHEN p_hier.
      PERFORM variant_init USING const_hier.
  ENDCASE.

*
  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = g_variant
      i_save     = g_save
*     it_default_fieldcat =
    IMPORTING
      e_exit     = g_exit
      es_variant = gx_variant
    EXCEPTIONS
      not_found  = 2.

  IF sy-subrc = 2.
    MESSAGE ID sy-msgid TYPE 'S'      NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    IF g_exit = space.
      ff_variant = gx_variant-variant.
    ENDIF.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  PAI_OF_SELECTION_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pai_of_selection_screen .

  CASE const_marked.
    WHEN p_alv.
      PERFORM variant_init USING const_alv.
    WHEN p_hier.
      PERFORM variant_init USING const_hier.
  ENDCASE.

  IF NOT p_vari IS INITIAL.
    MOVE g_variant TO gx_variant.
    MOVE p_vari TO gx_variant-variant.
    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
      EXPORTING
        i_save     = g_save
      CHANGING
        cs_variant = gx_variant.
    g_variant = gx_variant.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  BUILD_RANGES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_ranges .

  IF so_spart IS NOT INITIAL.
    APPEND LINES OF so_spart TO  gt_spart.
  ENDIF.

  IF so_vktyp IS NOT INITIAL.
    APPEND LINES OF so_vktyp TO  gt_vktyp.
  ENDIF.

  IF so_regio IS NOT INITIAL.
    APPEND LINES OF so_regio TO  gt_regio.
  ENDIF.

  IF so_lockr IS NOT INITIAL.
    APPEND LINES OF so_lockr TO  gt_lockr.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_CUSTOMIZING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_customizing .

  IF gt_cust IS INITIAL.
    SELECT * FROM /adesso/ink_cust INTO TABLE gt_cust.
  ENDIF.

  IF gt_nfhf IS INITIAL.

    SELECT * FROM /adesso/ink_nfhf
             INTO TABLE gt_nfhf
             WHERE schlr = const_marked.

    LOOP AT gt_nfhf INTO gs_nfhf.
      CLEAR gs_hvorg.
      gs_hvorg-option = 'EQ'.
      gs_hvorg-sign   = 'I'.
      gs_hvorg-low    = gs_nfhf-hvorg.
      APPEND gs_hvorg TO gr_hvorg.
    ENDLOOP.

  ENDIF.

  IF gt_nf_mahn IS INITIAL.

    SELECT * FROM /adesso/ink_nfhf
             INTO TABLE gt_nf_mahn
             WHERE tv_mahn_von NE space.
    SORT gt_nf_mahn.

  ENDIF.


* Felder der Tabelle /ADESSO/INK_ADD.I
  SELECT * FROM dd03m
           INTO TABLE gt_dd03m
           WHERE tabname    = '/ADESSO/INK_ADDI'
           AND   ddlanguage = sy-langu .

  SORT gt_dd03m BY position.

  LOOP AT gt_dd03m INTO gs_dd03m.
    CASE gs_dd03m-fieldname.
      WHEN 'MANDT'.
        DELETE gt_dd03m.
*      WHEN 'INKGP'.
*        DELETE gt_dd03m.
*      WHEN 'AGDAT'.
*        DELETE gt_dd03m.
    ENDCASE.
  ENDLOOP.

  IF gt_cust_wo IS INITIAL.
    SELECT * FROM /adesso/wo_cust INTO TABLE gt_cust_wo.
  ENDIF.

  IF gt_vkst IS INITIAL.
    SELECT * FROM /adesso/wo_vkst INTO TABLE gt_vkst.
  ENDIF.

  IF gt_igrdt IS INITIAL.
    SELECT * FROM /adesso/wo_igrdt INTO TABLE gt_igrdt.
  ENDIF.

  IF gt_tfk048at IS INITIAL.
    SELECT * FROM tfk048at INTO TABLE gt_tfk048at.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  PRE_SELECT
*&---------------------------------------------------------------------*
FORM pre_select .

  DATA: lv_hvorg TYPE hvorg_kk.
  DATA: lv_lockr_space TYPE c.
  DATA: lv_lockr_check TYPE c.
  DATA: lv_vjduedt TYPE dats.

* Anzeige alle mit Info an InkassoGP im Zeitraum
  IF p_infos = const_marked.

    CLEAR wa_opt.
    wa_opt-xreca  = const_marked.
    wa_opt-xagip  = const_marked.
    wa_opt-xopwo  = const_marked.

    SELECT dfkkcollh~gpart dfkkcollh~vkont
           APPENDING TABLE t_gpvk
           FROM  dfkkcollh
           WHERE gpart IN so_gpart
           AND   vkont IN so_vkont
           AND   agsta BETWEEN '03' AND '20'
           AND   rudat  IN so_agdat.

    SORT t_gpvk.
    DELETE ADJACENT DUPLICATES FROM t_gpvk.

  ENDIF.

* Anzeige alle mit Info vom InkassoGP im Zeitraum
  IF p_infgp = const_marked.

    CLEAR wa_opt.
    wa_opt-xreca  = const_marked.
    wa_opt-xagip  = const_marked.
    wa_opt-xopwo  = const_marked.
    wa_opt-abbri  = const_marked.
    wa_opt-xfact  = const_marked.

    SELECT i~gpart i~vkont
           APPENDING TABLE t_gpvk
           FROM  /adesso/ink_infi AS i
           WHERE ( satztyp = 'I' OR satztyp = 'A' )
           AND   infodat IN so_agdat
           AND   gpart   IN so_gpart
           AND   vkont   IN so_vkont.

    SORT t_gpvk.
    DELETE ADJACENT DUPLICATES FROM t_gpvk.

  ENDIF.

  CHECK p_infos = space AND p_infgp = space.


* Erstmal alle, die schon im Inkasso-Prozess sind (DFKKCOLL)
* Vorgemerkt
  IF p_vorm = const_marked.
    SELECT dfkkcoll~gpart dfkkcoll~vkont
      APPENDING TABLE t_gpvk
      FROM dfkkcoll
        INNER JOIN fkkvkp
        ON ( fkkvkp~vkont = dfkkcoll~vkont AND
             fkkvkp~gpart = dfkkcoll~gpart )
        INNER JOIN fkkvk
        ON fkkvk~vkont = fkkvkp~vkont
        INNER JOIN but000
        ON but000~partner = dfkkcoll~gpart
      WHERE dfkkcoll~gpart      IN so_gpart
        AND dfkkcoll~vkont      IN so_vkont
        AND fkkvkp~regiogr_ca_b IN so_regio
        AND fkkvk~vktyp         IN so_vktyp
        AND but000~mc_name1     IN so_name1
        AND dfkkcoll~agsta      = const_agsta_vorm.
  ENDIF.

* Erneut prüfen
  IF p_look = const_marked.
    SELECT dfkkcoll~gpart dfkkcoll~vkont
      APPENDING TABLE t_gpvk
      FROM dfkkcoll
        INNER JOIN fkkvkp
        ON ( fkkvkp~vkont = dfkkcoll~vkont AND
             fkkvkp~gpart = dfkkcoll~gpart )
        INNER JOIN fkkvk
        ON fkkvk~vkont = fkkvkp~vkont
        INNER JOIN but000
        ON but000~partner = dfkkcoll~gpart
      WHERE dfkkcoll~gpart      IN so_gpart
        AND dfkkcoll~vkont      IN so_vkont
        AND fkkvkp~regiogr_ca_b IN so_regio
        AND fkkvk~vktyp         IN so_vktyp
        AND but000~mc_name1     IN so_name1
        AND dfkkcoll~agsta      = const_agsta_look.
  ENDIF.

* Geprüft
  IF p_chkd = const_marked.
    SELECT dfkkcoll~gpart dfkkcoll~vkont
      APPENDING TABLE t_gpvk
      FROM dfkkcoll
        INNER JOIN fkkvkp
        ON ( fkkvkp~vkont = dfkkcoll~vkont AND
             fkkvkp~gpart = dfkkcoll~gpart )
        INNER JOIN fkkvk
        ON fkkvk~vkont = fkkvkp~vkont
        INNER JOIN but000
        ON but000~partner = dfkkcoll~gpart
      WHERE dfkkcoll~gpart      IN so_gpart
        AND dfkkcoll~vkont      IN so_vkont
        AND fkkvkp~regiogr_ca_b IN so_regio
        AND fkkvk~vktyp         IN so_vktyp
        AND but000~mc_name1     IN so_name1
        AND dfkkcoll~agsta      = const_agsta_chkd.
  ENDIF.

* Freigegeben
  IF p_frei = const_marked.
    SELECT dfkkcoll~gpart dfkkcoll~vkont
      APPENDING TABLE t_gpvk
      FROM dfkkcoll
        INNER JOIN fkkvkp
        ON ( fkkvkp~vkont = dfkkcoll~vkont AND
             fkkvkp~gpart = dfkkcoll~gpart )
        INNER JOIN fkkvk
        ON fkkvk~vkont = fkkvkp~vkont
        INNER JOIN but000
        ON but000~partner = dfkkcoll~gpart
      WHERE dfkkcoll~gpart      IN so_gpart
        AND dfkkcoll~vkont      IN so_vkont
        AND fkkvkp~regiogr_ca_b IN so_regio
        AND fkkvk~vktyp         IN so_vktyp
        AND but000~mc_name1     IN so_name1
        AND dfkkcoll~agsta      = const_agsta_freigegeben.
  ENDIF.

* Rückrufe
  IF p_reca = const_marked.
    SELECT dfkkcoll~gpart dfkkcoll~vkont
      APPENDING TABLE t_gpvk
      FROM dfkkcoll
        INNER JOIN fkkvkp
        ON ( fkkvkp~vkont = dfkkcoll~vkont AND
             fkkvkp~gpart = dfkkcoll~gpart )
        INNER JOIN fkkvk
        ON fkkvk~vkont = fkkvkp~vkont
        INNER JOIN but000
        ON but000~partner = dfkkcoll~gpart
      WHERE dfkkcoll~gpart      IN so_gpart
        AND dfkkcoll~vkont      IN so_vkont
        AND fkkvkp~regiogr_ca_b IN so_regio
        AND fkkvk~vktyp         IN so_vktyp
        AND but000~mc_name1     IN so_name1
        AND dfkkcoll~agsta      = const_agsta_recalled.
  ENDIF.

* Abgegeben, Storno und Rechnungsneustellung?
  IF p_xnewin = const_marked.
    SELECT dfkkcoll~gpart dfkkcoll~vkont
      APPENDING TABLE t_gpvk
      FROM dfkkcoll
        INNER JOIN fkkvkp
        ON ( fkkvkp~vkont = dfkkcoll~vkont AND
             fkkvkp~gpart = dfkkcoll~gpart )
        INNER JOIN fkkvk
        ON fkkvk~vkont = fkkvkp~vkont
        INNER JOIN but000
        ON but000~partner = dfkkcoll~gpart
      WHERE dfkkcoll~gpart      IN so_gpart
        AND dfkkcoll~vkont      IN so_vkont
        AND dfkkcoll~agdat      IN so_agdat
        AND fkkvkp~regiogr_ca_b IN so_regio
        AND fkkvk~vktyp         IN so_vktyp
        AND but000~mc_name1     IN so_name1
        AND dfkkcoll~agsta      = const_agsta_storniert.
  ENDIF.

* Abgegeben, noch offen
  IF p_xagip = const_marked.
    SELECT dfkkcoll~gpart dfkkcoll~vkont
      APPENDING TABLE t_gpvk
      FROM dfkkcoll
        INNER JOIN fkkvkp
        ON ( fkkvkp~vkont = dfkkcoll~vkont AND
             fkkvkp~gpart = dfkkcoll~gpart )
        INNER JOIN fkkvk
        ON fkkvk~vkont = fkkvkp~vkont
        INNER JOIN but000
        ON but000~partner = dfkkcoll~gpart
      WHERE dfkkcoll~gpart      IN so_gpart
        AND dfkkcoll~vkont      IN so_vkont
        AND dfkkcoll~agdat      IN so_agdat
        AND fkkvkp~regiogr_ca_b IN so_regio
        AND fkkvk~vktyp         IN so_vktyp
        AND but000~mc_name1     IN so_name1
        AND dfkkcoll~agsta      = const_agsta_abgegeben.
  ENDIF.

* Abgegeben, Klärung, Alle prüfen wo noch was offen
  IF p_xrview = const_marked.
*    so_xagip[] = VALUE #(
*      ( sign   = 'I' option = 'EQ' low = '02' )
*      ( sign   = 'I' option = 'EQ' low = '04' )
*      ( sign   = 'I' option = 'EQ' low = '07' )
*      ( sign   = 'I' option = 'EQ' low = '08' )
*      ( sign   = 'I' option = 'EQ' low = '11' )
*      ( sign   = 'I' option = 'EQ' low = '13' )
*      ( sign   = 'I' option = 'EQ' low = '14' )
*      ( sign   = 'I' option = 'EQ' low = '15' )
*      ( sign   = 'I' option = 'EQ' low = '16' ) ).

    SELECT dfkkcoll~gpart dfkkcoll~vkont
      APPENDING TABLE t_gpvk
      FROM dfkkcoll
        INNER JOIN fkkvkp
        ON ( fkkvkp~vkont = dfkkcoll~vkont AND
             fkkvkp~gpart = dfkkcoll~gpart )
        INNER JOIN fkkvk
        ON fkkvk~vkont = fkkvkp~vkont
        INNER JOIN but000
        ON but000~partner = dfkkcoll~gpart
      WHERE dfkkcoll~gpart      IN so_gpart
        AND dfkkcoll~vkont      IN so_vkont
        AND dfkkcoll~agdat      IN so_agdat
        AND fkkvkp~regiogr_ca_b IN so_regio
        AND fkkvk~vktyp         IN so_vktyp
        AND but000~mc_name1     IN so_name1
        AND dfkkcoll~agsta      = const_agsta_abgegeben.
  ENDIF.

* Abgegeben, Ratenvereinbarung beim InkGP
  IF p_xinspl = const_marked.
    SELECT /adesso/ink_infi~gpart /adesso/ink_infi~vkont
      APPENDING TABLE t_gpvk
      FROM /adesso/ink_infi
        INNER JOIN dfkkcoll
        ON ( dfkkcoll~vkont = /adesso/ink_infi~vkont AND
             dfkkcoll~gpart = /adesso/ink_infi~gpart )
        INNER JOIN fkkvkp
        ON ( fkkvkp~vkont = /adesso/ink_infi~vkont AND
             fkkvkp~gpart = /adesso/ink_infi~gpart )
        INNER JOIN fkkvk
        ON fkkvk~vkont = fkkvkp~vkont
        INNER JOIN but000
        ON but000~partner = /adesso/ink_infi~gpart
      WHERE /adesso/ink_infi~gpart   IN so_gpart
        AND /adesso/ink_infi~vkont   IN so_vkont
        AND fkkvkp~regiogr_ca_b      IN so_regio
        AND fkkvk~vktyp              IN so_vktyp
        AND but000~mc_name1          IN so_name1
        AND /adesso/ink_infi~ratenvb = const_marked
        AND dfkkcoll~agsta           = const_agsta_abgegeben.

  ENDIF.

* Abgegeben, Abbruch durch InkGP
  IF p_abbri = const_marked.
    SELECT /adesso/ink_infi~gpart /adesso/ink_infi~vkont
      APPENDING TABLE t_gpvk
      FROM /adesso/ink_infi
        INNER JOIN dfkkcoll
        ON ( dfkkcoll~vkont = /adesso/ink_infi~vkont AND
             dfkkcoll~gpart = /adesso/ink_infi~gpart )
        INNER JOIN fkkvkp
        ON ( fkkvkp~vkont = /adesso/ink_infi~vkont AND
             fkkvkp~gpart = /adesso/ink_infi~gpart )
        INNER JOIN fkkvk
        ON fkkvk~vkont = fkkvkp~vkont
        INNER JOIN but000
        ON but000~partner = /adesso/ink_infi~gpart
      WHERE /adesso/ink_infi~gpart   IN so_gpart
        AND /adesso/ink_infi~vkont   IN so_vkont
        AND fkkvkp~regiogr_ca_b      IN so_regio
        AND fkkvk~vktyp              IN so_vktyp
        AND but000~mc_name1          IN so_name1
        AND /adesso/ink_infi~abbruch NE space
        AND dfkkcoll~agsta           = const_agsta_abgegeben.
  ENDIF.

* Abgegeben, Ankauf Angebot InkGP, und noch was offen
  IF p_xfact = const_marked.
    SELECT /adesso/ink_infi~gpart /adesso/ink_infi~vkont
      APPENDING TABLE t_gpvk
      FROM /adesso/ink_infi
        INNER JOIN dfkkcoll
        ON ( dfkkcoll~vkont = /adesso/ink_infi~vkont AND
             dfkkcoll~gpart = /adesso/ink_infi~gpart )
        INNER JOIN fkkvkp
        ON ( fkkvkp~vkont = /adesso/ink_infi~vkont AND
             fkkvkp~gpart = /adesso/ink_infi~gpart )
        INNER JOIN fkkvk
        ON fkkvk~vkont = fkkvkp~vkont
        INNER JOIN but000
        ON but000~partner = /adesso/ink_infi~gpart
      WHERE /adesso/ink_infi~gpart   IN so_gpart
        AND /adesso/ink_infi~vkont   IN so_vkont
        AND fkkvkp~regiogr_ca_b      IN so_regio
        AND fkkvk~vktyp              IN so_vktyp
        AND but000~mc_name1          IN so_name1
        AND /adesso/ink_infi~satztyp = const_chara
        AND dfkkcoll~agsta           = const_agsta_abgegeben.
  ENDIF.

* Abgegeben, Vormerkung Verkauf
  IF p_apprse = const_marked.
    SELECT dfkkcoll~gpart dfkkcoll~vkont
      APPENDING TABLE t_gpvk
      FROM dfkkcoll
        INNER JOIN fkkvkp
        ON ( fkkvkp~vkont = dfkkcoll~vkont AND
             fkkvkp~gpart = dfkkcoll~gpart )
        INNER JOIN fkkvk
        ON fkkvk~vkont = fkkvkp~vkont
        INNER JOIN but000
        ON but000~partner = dfkkcoll~gpart
      WHERE dfkkcoll~gpart      IN so_gpart
        AND dfkkcoll~vkont      IN so_vkont
        AND dfkkcoll~agdat      IN so_agdat
        AND fkkvkp~regiogr_ca_b IN so_regio
        AND fkkvk~vktyp         IN so_vktyp
        AND but000~mc_name1     IN so_name1
        AND dfkkcoll~agsta      = const_agsta_sell.
  ENDIF.

* Abgegeben, Verkauf
  IF p_sell = const_marked.
    SELECT dfkkcoll~gpart dfkkcoll~vkont
      APPENDING TABLE t_gpvk
      FROM dfkkcoll
        INNER JOIN fkkvkp
        ON ( fkkvkp~vkont = dfkkcoll~vkont AND
             fkkvkp~gpart = dfkkcoll~gpart )
        INNER JOIN fkkvk
        ON fkkvk~vkont = fkkvkp~vkont
        INNER JOIN but000
        ON but000~partner = dfkkcoll~gpart
      WHERE dfkkcoll~gpart      IN so_gpart
        AND dfkkcoll~vkont      IN so_vkont
        AND dfkkcoll~agdat      IN so_agdat
        AND fkkvkp~regiogr_ca_b IN so_regio
        AND fkkvk~vktyp         IN so_vktyp
        AND but000~mc_name1     IN so_name1
        AND dfkkcoll~agsta      = const_agsta_sell.
  ENDIF.

* Abgegeben, Ablehnung Verkauf, Erneute Bearbeitung
  IF p_dsel = const_marked.
    SELECT dfkkcoll~gpart dfkkcoll~vkont
      APPENDING TABLE t_gpvk
      FROM dfkkcoll
        INNER JOIN fkkvkp
        ON ( fkkvkp~vkont = dfkkcoll~vkont AND
             fkkvkp~gpart = dfkkcoll~gpart )
        INNER JOIN fkkvk
        ON fkkvk~vkont = fkkvkp~vkont
        INNER JOIN but000
        ON but000~partner = dfkkcoll~gpart
      WHERE dfkkcoll~gpart      IN so_gpart
        AND dfkkcoll~vkont      IN so_vkont
        AND dfkkcoll~agdat      IN so_agdat
        AND fkkvkp~regiogr_ca_b IN so_regio
        AND fkkvk~vktyp         IN so_vktyp
        AND but000~mc_name1     IN so_name1
        AND dfkkcoll~agsta      =  const_agsta_dsrc .
  ENDIF.

* Abgegeben, Vormerkung Ausbuchen
  IF p_apprwo = const_marked.
    SELECT dfkkcoll~gpart dfkkcoll~vkont
      APPENDING TABLE t_gpvk
      FROM dfkkcoll
        INNER JOIN fkkvkp
        ON ( fkkvkp~vkont = dfkkcoll~vkont AND
             fkkvkp~gpart = dfkkcoll~gpart )
        INNER JOIN fkkvk
        ON fkkvk~vkont = fkkvkp~vkont
        INNER JOIN but000
        ON but000~partner = dfkkcoll~gpart
      WHERE dfkkcoll~gpart      IN so_gpart
        AND dfkkcoll~vkont      IN so_vkont
        AND dfkkcoll~agdat      IN so_agdat
        AND fkkvkp~regiogr_ca_b IN so_regio
        AND fkkvk~vktyp         IN so_vktyp
        AND but000~mc_name1     IN so_name1
        AND ( dfkkcoll~agsta    = const_agsta_wroff OR
              dfkkcoll~agsta    = const_agsta_dswo ).
  ENDIF.

* Abgegeben, Ausbuchen
  IF p_wroff = const_marked.
    SELECT dfkkcoll~gpart dfkkcoll~vkont
      APPENDING TABLE t_gpvk
      FROM dfkkcoll
        INNER JOIN fkkvkp
        ON ( fkkvkp~vkont = dfkkcoll~vkont AND
             fkkvkp~gpart = dfkkcoll~gpart )
        INNER JOIN fkkvk
        ON fkkvk~vkont = fkkvkp~vkont
        INNER JOIN but000
        ON but000~partner = dfkkcoll~gpart
      WHERE dfkkcoll~gpart      IN so_gpart
        AND dfkkcoll~vkont      IN so_vkont
        AND dfkkcoll~agdat      IN so_agdat
        AND fkkvkp~regiogr_ca_b IN so_regio
        AND fkkvk~vktyp         IN so_vktyp
        AND but000~mc_name1     IN so_name1
        AND ( dfkkcoll~agsta    = const_agsta_wroff  OR
              dfkkcoll~agsta    = const_agsta_dswo ).
  ENDIF.

* Abgegeben und erledigt (also ausgebucht, ausgeglichen...)
  IF p_xopwo = const_marked.
    so_xopwo[] = VALUE #(
      ( sign   = 'I' option = 'EQ' low = '03' )
      ( sign   = 'I' option = 'EQ' low = '05' )
      ( sign   = 'I' option = 'EQ' low = '06' )
      ( sign   = 'I' option = 'EQ' low = '10' )
      ( sign   = 'I' option = 'EQ' low = '12' ) ).

    SELECT dfkkcoll~gpart dfkkcoll~vkont
      APPENDING TABLE t_gpvk
      FROM dfkkcoll
        INNER JOIN fkkvkp
        ON ( fkkvkp~vkont = dfkkcoll~vkont AND
             fkkvkp~gpart = dfkkcoll~gpart )
        INNER JOIN fkkvk
        ON fkkvk~vkont = fkkvkp~vkont
        INNER JOIN but000
        ON but000~partner = dfkkcoll~gpart
      WHERE dfkkcoll~gpart      IN so_gpart
        AND dfkkcoll~vkont      IN so_vkont
        AND dfkkcoll~agdat      IN so_agdat
        AND fkkvkp~regiogr_ca_b IN so_regio
        AND fkkvk~vktyp         IN so_vktyp
        AND but000~mc_name1     IN so_name1
        AND dfkkcoll~agsta      IN so_xopwo.
  ENDIF.


* Dann die neuen Fälle (abzugebende Posten)
  IF p_xagapi = const_marked.

* Können vorher schon Stammdaten eingeschränkt werden ?
* Als erstes: Prüfen, ob Mahnsperren eingeschränkt

    SELECT SINGLE @abap_true FROM /adesso/ink_bgsb
       WHERE begru = @gs_bgus-begru
       AND   activ = ' '
       INTO  @DATA(exists).

*   Wenn ja, dann einschränken
    IF sy-subrc = 0  AND
       exists = abap_true.
      lv_lockr_check = 'X'.
      PERFORM pre_select_lock TABLES t_gpvk_md
                              USING  lv_lockr_check
                                     lv_lockr_space.
      APPEND LINES OF t_gpvk_md TO t_gpvk.
      CHECK lv_lockr_check = 'X'.
    ELSE.
      IF so_lockr[] IS NOT INITIAL.
        PERFORM pre_select_lock TABLES t_gpvk_md
                                USING  lv_lockr_check
                                       lv_lockr_space.

        APPEND LINES OF t_gpvk_md TO t_gpvk.
        CHECK lv_lockr_space = 'X'.
      ENDIF.
    ENDIF.

* Können weitere Stammdaten eingeschränkt werden ?
    IF so_vktyp[] IS NOT INITIAL OR
       so_regio[] IS NOT INITIAL OR
       so_name1[] IS NOT INITIAL.

      PERFORM pre_select_md TABLES t_gpvk_md.
      APPEND LINES OF t_gpvk_md TO t_gpvk.

    ELSE.
* keine Stammdaten-Selektion möglich, dann nun über DFKKOP
      CLEAR lv_vjduedt.
      lv_vjduedt = sy-datum - p_ovrdue.

      SELECT dfkkop~gpart dfkkop~vkont
        FROM dfkkop
        APPENDING TABLE t_gpvk
        WHERE dfkkop~augst = space
          AND dfkkop~gpart IN so_gpart
          AND dfkkop~vkont IN so_vkont
          AND dfkkop~hvorg IN gr_hvorg
          AND dfkkop~faedn LT lv_vjduedt.

    ENDIF.
  ENDIF.

  SORT t_gpvk.
  DELETE ADJACENT DUPLICATES FROM t_gpvk.


ENDFORM.                    " PRE_SELECT

*&---------------------------------------------------------------------*
*&      Form  PRE_SELECT_LOCK
*&---------------------------------------------------------------------*
FORM pre_select_lock TABLES ft_gpvk_md
                     USING  ff_lockr_check
                            ff_lockr_space.

  DATA: lr_lockr TYPE RANGE OF lockr_kk.
  DATA: ls_lockr LIKE LINE OF lr_lockr.

  CLEAR ff_lockr_space.

  IF ff_lockr_check = 'X'.

    LOOP AT gt_bgsb INTO gs_bgsb
         WHERE activ = 'X'.
      CLEAR ls_lockr.
      ls_lockr-option = 'EQ'.
      ls_lockr-sign   = 'I'.
      ls_lockr-low    = gs_bgsb-value.
      APPEND ls_lockr TO lr_lockr.
    ENDLOOP.

    CHECK lr_lockr[] IS NOT INITIAL.

    SELECT dfkklocks~gpart dfkklocks~vkont
      INTO TABLE ft_gpvk_md
      FROM dfkklocks
      INNER JOIN fkkvkp
      ON fkkvkp~vkont = dfkklocks~vkont AND
         fkkvkp~gpart = dfkklocks~gpart
      INNER JOIN fkkvk
      ON fkkvk~vkont = dfkklocks~vkont
      INNER JOIN but000
      ON but000~partner = dfkklocks~gpart
      WHERE dfkklocks~lotyp = '06'
        AND dfkklocks~proid = '01'
        AND dfkklocks~lockr IN lr_lockr
        AND dfkklocks~fdate LE sy-datum
        AND dfkklocks~tdate GE sy-datum
        AND dfkklocks~gpart IN so_gpart
        AND dfkklocks~vkont IN so_vkont
        AND but000~mc_name1 IN so_name1
        AND fkkvkp~regiogr_ca_b IN so_regio
        AND fkkvk~vktyp         IN so_vktyp.

  ENDIF.

  CHECK ff_lockr_check = space.

* Als erstes Mahnsperren
* Aber nur wenn nicht = Space selektiert wurde
  LOOP AT so_lockr.
    IF so_lockr-option = 'EQ' AND
       so_lockr-sign   = 'I'  AND
       so_lockr-low    = space.
      ff_lockr_space = 'X'.
    ENDIF.
  ENDLOOP.

  IF  ff_lockr_space = ' '.

    SELECT dfkklocks~gpart dfkklocks~vkont
      INTO TABLE ft_gpvk_md
      FROM dfkklocks
      INNER JOIN fkkvkp
      ON fkkvkp~vkont = dfkklocks~vkont AND
         fkkvkp~gpart = dfkklocks~gpart
      INNER JOIN fkkvk
      ON fkkvk~vkont = dfkklocks~vkont
      INNER JOIN but000
      ON but000~partner = dfkklocks~gpart
      WHERE dfkklocks~lotyp = '06'
        AND dfkklocks~proid = '01'
        AND dfkklocks~lockr IN so_lockr
        AND dfkklocks~fdate LE sy-datum
        AND dfkklocks~tdate GE sy-datum
        AND dfkklocks~gpart IN so_gpart
        AND dfkklocks~vkont IN so_vkont
        AND but000~mc_name1 IN so_name1
        AND fkkvkp~regiogr_ca_b IN so_regio
        AND fkkvk~vktyp         IN so_vktyp.
  ENDIF.

ENDFORM.                    " PRE_SELECT_LOCK

*&---------------------------------------------------------------------*
*&      Form  PRE_SELECT_MD
*&---------------------------------------------------------------------*
FORM pre_select_md TABLES ft_gpvk_md.

* Name selektiert, dann but000
  IF so_name1[] IS NOT INITIAL.
    SELECT fkkvkp~gpart fkkvk~vkont INTO TABLE ft_gpvk_md
      FROM but000
      INNER JOIN fkkvkp
      ON fkkvkp~gpart = but000~partner
      INNER JOIN fkkvk
      ON fkkvk~vkont = fkkvkp~vkont
    WHERE but000~partner      IN so_gpart
      AND but000~mc_name1     IN so_name1
      AND fkkvkp~vkont        IN so_vkont
      AND fkkvkp~regiogr_ca_b IN so_regio
      AND fkkvk~vktyp         IN so_vktyp.
  ELSE.
    IF so_regio[] IS NOT INITIAL OR
       so_vktyp[] IS NOT INITIAL.

      SELECT fkkvkp~gpart fkkvk~vkont  INTO TABLE ft_gpvk_md
      FROM fkkvkp INNER JOIN fkkvk
        ON fkkvk~vkont = fkkvkp~vkont
      WHERE fkkvkp~vkont        IN so_vkont
        AND fkkvkp~gpart        IN so_gpart
        AND fkkvkp~regiogr_ca_b IN so_regio
        AND fkkvk~vktyp         IN so_vktyp.
    ENDIF.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CREATE_TASKS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_tasks .

  DATA: lf_prtio TYPE sy-tabix.
  DATA: lf_max_prtio TYPE sy-tabix.


*  CLEAR gs_cust.
*  SELECT SINGLE * FROM /adesso/ink_cust
*    INTO gs_cust
*    WHERE inkasso_option = 'PARALLEL'
*    AND   inkasso_field  = 'PRTIO'.
*
*  IF sy-subrc = 0.
*    lf_max_prtio = gs_cust-inkasso_value.
*  ELSE.
*    lf_max_prtio = c_prtio.
*  ENDIF.
*
*  CLEAR wa_tasks.
*
*  DESCRIBE TABLE t_gpvk LINES x_tabix.
*  CHECK x_tabix NE 0.
*
*  IF x_tabix <= lf_max_prtio.
*    x_prtio = x_tabix.
*  ELSE.
*    x_prtio = x_tabix / x_maxts.
*    IF x_prtio > c_prtio.
*      x_prtio = c_prtio.
*    ENDIF.
*  ENDIF.
*
*  if x_prtio = 0.
*    x_prtio = lf_max_prtio.
*  endif.

  CLEAR gs_cust.
  LOOP AT gt_cust INTO gs_cust
    WHERE inkasso_option = 'PARALLEL'.

    CASE gs_cust-inkasso_field.
      WHEN 'PRTIO'.
        lf_prtio = gs_cust-inkasso_value.
      WHEN 'MAXPRTIO'.
        lf_max_prtio = gs_cust-inkasso_value.
    ENDCASE.

  ENDLOOP.

  CLEAR wa_tasks.

  DESCRIBE TABLE t_gpvk LINES x_tabix.
  CHECK x_tabix NE 0.

  IF x_tabix <= lf_prtio.
    x_prtio = x_tabix.
  ELSE.
    x_prtio = x_tabix / x_maxts.
    IF x_prtio > lf_max_prtio.
      x_prtio = lf_max_prtio.
    ENDIF.
  ENDIF.

  IF x_prtio = 0.
    x_prtio = c_prtio.
  ENDIF.

  DO.
    wa_tasks-count = wa_tasks-count + 1.
    wa_tasks-low  = wa_tasks-high + 1.
    wa_tasks-high = wa_tasks-low  + x_prtio.
    CONCATENATE sy-repid wa_tasks-count
      INTO wa_tasks-name SEPARATED BY space.
    APPEND wa_tasks TO t_tasks.
    x_tabix = x_tabix - x_prtio.
    IF x_tabix <= 0.
      EXIT.
    ENDIF.
  ENDDO.

ENDFORM.                    " CREATE_TASKS
*&---------------------------------------------------------------------*
*&      Form  ENDE_TASK
*&---------------------------------------------------------------------*

FORM ende_task  USING taskname.

  RECEIVE RESULTS FROM FUNCTION '/ADESSO/INKASSO_SELECT'
*   TABLES
   IMPORTING
     et_out  = ft_out
    EXCEPTIONS
       communication_failure = 1
       system_failure        = 2.

*  IF sy-subrc = 0.
  APPEND LINES OF ft_out TO t_out.

*   Lösche die Task aus der Tasktabelle
  DELETE t_tasks WHERE name = taskname.
  SUBTRACT 1 FROM x_runts.
*  ELSE.
*    MESSAGE text-e04 TYPE 'E'.
*    STOP.
*  ENDIF.


ENDFORM.                    " ENDE_TASK

*---------------------------------------------------------------------*
*       FORM USER_COMMAND                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*       --> R_UCOMM                                                   *
*       --> RS_SELFIELD                                               *
*---------------------------------------------------------------------*
FORM user_command USING r_ucomm LIKE sy-ucomm
                  rs_selfield TYPE slis_selfield.

** Daten im ALV aktualisieren (wichtig für das Selektionsfeld)
*  DATA: rev_alv TYPE REF TO cl_gui_alv_grid.
*
*
** --> Nuss 05.2018
*  DATA: ls_fieldcat TYPE slis_fieldcat_alv .
*
*
** <-- Nuss 05.2018
*
*
*  DATA: ls_dfkkop TYPE dfkkop.                   "Nuss 06.2018
*
*  FIELD-SYMBOLS: <wa_out> LIKE wa_out.
*
*
*
*  rs_selfield-refresh = 'X'.
*  rs_selfield-col_stable = 'X'.
*
*  CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
*    IMPORTING
*      e_grid = rev_alv.
*
*  rev_alv->check_changed_data( ).
*
*  CLEAR wa_out.    "Nuss 04.2018
*
*  READ TABLE t_out INTO wa_out INDEX rs_selfield-tabindex.
*
*  IF sy-ucomm = 'RELE'.
*
**   Wenn Kunde zur Abgabe gesperrt ist, kann er nicht freigegeben werden
*    IF wa_out-locked IS NOT INITIAL.
*      MESSAGE e001 WITH wa_out-vkont wa_out-gpart.
*      CLEAR wa_out.
*      EXIT.
*    ENDIF.
*
*    PERFORM ucom_freigabe.
*
*  ELSEIF sy-ucomm = 'UNDO'.
*
*    PERFORM ucom_freigabe_ruecknahme.
*
*  ELSEIF sy-ucomm = 'MARK'.
*
*    LOOP AT t_out ASSIGNING <wa_out>
*      WHERE vkont = wa_out-vkont.
*      <wa_out>-sel = 'X'.
*    ENDLOOP.
*
*  ELSEIF sy-ucomm = 'MARKALL'.
*    LOOP AT t_out ASSIGNING <wa_out>.
*      <wa_out>-sel = 'X'.
*    ENDLOOP.
*
*  ELSEIF sy-ucomm = 'DEMARK'.
*
*    LOOP AT t_out ASSIGNING <wa_out>
*      WHERE vkont = wa_out-vkont.
*      <wa_out>-sel = ' '.
*    ENDLOOP.
*
*  ELSEIF sy-ucomm = 'DMALL'.
*
*    LOOP AT t_out ASSIGNING <wa_out>.
*      <wa_out>-sel = ' '.
*    ENDLOOP.
*
*** --> Nuss 21.11.2014 Erweiterung
*  ELSEIF sy-ucomm = 'SETSTAT'.
*
*    PERFORM ucom_set_status.
*
*  ELSEIF sy-ucomm = 'DELSTAT'.
*
*    PERFORM ucom_delete_status.
*
*** --> Nuss 06.2018
*  ELSEIF sy-ucomm = 'NEWLOOK'.
*
*    PERFORM ucom_set_newlook.
*** <-- Nuss 06.2018
*
** --> Nuss 04.2018
*  ELSEIF sy-ucomm = 'BALANCE'.
*
*    LOOP AT t_out INTO wa_out WHERE sel IS NOT INITIAL.
*
*      PERFORM ucom_get_kontenstand.
*
*      EXIT.
*
*    ENDLOOP.
*    IF sy-subrc NE 0.
*      MESSAGE e002.
*    ENDIF.
*
*  ELSEIF sy-ucomm = 'CIC'.
*
*    LOOP AT t_out INTO wa_out WHERE sel IS NOT INITIAL.
*
*      PERFORM ucom_get_cic USING wa_out-vkont.
*
*      EXIT.
*
*    ENDLOOP.
*
*    IF sy-subrc NE 0.
*      MESSAGE e002.
*    ENDIF.
*
*
*  ELSEIF sy-ucomm = 'ABGABE'.
*
*    PERFORM ucom_abgabe.
*
**  ELSEIF sy-ucomm = 'RECALL'.
**
**    PERFORM recall.
*
*  ELSEIF sy-ucomm = 'FREETEXT'.
*
*    LOOP AT t_out INTO wa_out WHERE sel IS NOT INITIAL.
*
*      PERFORM ucom_build_freetext.
*
*      EXIT.
*
*    ENDLOOP.
*
** <-- Nuss 04.2018
*
** --> Nuss 05.2018
*  ELSEIF  sy-ucomm = 'SWITCH'.
*
*
*    PERFORM ucom_switch_view USING rev_alv.
*
*
*  ELSEIF sy-ucomm = 'INTVERM'.
*
*    LOOP AT t_out INTO wa_out WHERE sel IS NOT INITIAL.
*
*      PERFORM ucom_edit_intverm.
*
*
*      EXIT.
*
*    ENDLOOP.
*
*
***   --> Nuss 06.2018
*  ELSEIF sy-ucomm = 'STORNO'.
*
*    PERFORM ucom_storno.
*
*    LOOP AT t_out INTO wa_out WHERE sel IS NOT INITIAL.
*      CLEAR ls_dfkkop.
*      SELECT SINGLE * FROM dfkkop INTO ls_dfkkop
*         WHERE opbel = wa_out-opbel
*           AND opupw = wa_out-opupw
*           AND opupk = wa_out-opupk
*           AND opupz = wa_out-opupz.
*
*      IF ls_dfkkop-augbl IS NOT INITIAL
*         AND ls_dfkkop-augrd = '05'.
*
*        CALL FUNCTION 'ICON_CREATE'
*          EXPORTING
*            name                  = 'ICON_STORNO'
*            info                  = TEXT-013
*          IMPORTING
*            result                = wa_out-status
*          EXCEPTIONS
*            icon_not_found        = 1
*            outputfield_too_short = 2
*            OTHERS                = 3.
*        IF sy-subrc <> 0.
*          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*        ENDIF.
*      ENDIF.
*
*      MODIFY t_out FROM wa_out TRANSPORTING status.
*    ENDLOOP.
**   <-- Nuss 06.2018
*
*  ELSEIF sy-ucomm = 'BACKU' OR
*         sy-ucomm = 'EXIT'  OR
*         sy-ucomm = 'CANCEL'.
*
*    IF sy-subrc = 0.
*    ENDIF.
*    LEAVE TO SCREEN 0.
*
*
*  ELSE.
*
*    CASE rs_selfield-fieldname.
*      WHEN 'GPART'.
*        IF wa_out-gpart IS NOT INITIAL.                   "Nuss 04.2018
*          SET PARAMETER ID 'BPA'  FIELD wa_out-gpart.
*          CALL TRANSACTION 'FPP3'.
*        ENDIF.                                            "Nuss 04.2018
*      WHEN 'VKONT'.
*        PERFORM view_vkont USING  wa_out-vkont
*                                  wa_out-gpart.
*      WHEN 'OPBEL'.
*        IF wa_out-opbel IS NOT INITIAL.                  "Nuss 04.2018
*          SET PARAMETER ID '80B' FIELD  wa_out-opbel.
*          CALL TRANSACTION 'FPE3' AND SKIP FIRST SCREEN.
*        ENDIF.                                           "Nuss 04.2018
*      WHEN 'INKGP'.
*        IF wa_out-inkgp IS NOT INITIAL.                  "Nuss 04.2018
*          SET PARAMETER ID 'BPA' FIELD  wa_out-inkgp.
*          CALL TRANSACTION 'FPP3'.
*        ENDIF.                                           "Nuss 04.2018
*      WHEN 'VTREF'.
*        DATA: lv_applk TYPE applk_kk.
*        CALL FUNCTION 'FKK_GET_APPLICATION'
*          IMPORTING
*            e_applk       = lv_applk
*          EXCEPTIONS
*            error_message = 1.
*        "call event 1201 -> display contract object
*        PERFORM event_1201(saplfkk_sec) USING lv_applk
*                                               wa_out-vtref.
*
** --> Nuss 05.2018
*      WHEN 'INTVERM'.
*
*        PERFORM display_intverm.
*
*** <--- Nuss 05.2018
*    ENDCASE.
*
*  ENDIF.

ENDFORM.                    "user_command

*&---------------------------------------------------------------------*
*&      Form  UCOM_FREIGABE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ucom_freigabe .

  DATA: lt_opbel TYPE TABLE OF opbel_kk.
  DATA: ls_opbel TYPE opbel_kk.
  DATA: ls_dfkkcoll TYPE dfkkcoll.

  DATA: itab_release               LIKE TABLE OF fkkop WITH HEADER LINE,
        itab_release_not_submitted LIKE TABLE OF fkkop,
        ht_pos                     TYPE /adesso/inkasso_out OCCURS 0 WITH HEADER LINE,
        ht_dfkkcoll                LIKE TABLE OF dfkkcoll WITH HEADER LINE,
        h_tabix                    LIKE sy-tabix,
        h_tfill                    LIKE sy-tfill,
        lt_gpart                   TYPE gpart_tab,
        ls_gpart                   TYPE LINE OF gpart_tab,
        wa_release                 TYPE fkkop,
        wa_pos                     TYPE /adesso/inkasso_out,
        lx_error                   TYPE xfeld,
        ls_dd07t                   TYPE dd07t,
        ls_but000                  TYPE but000.

  CLEAR pos_itab_marked.
  REFRESH pos_itab_marked.

  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
    EXPORTING
      titel     = TEXT-inf
      textline1 = TEXT-f05
      textline2 = TEXT-e12.
  EXIT.

  PERFORM build_release_tab TABLES itab_release.

  CHECK NOT itab_release IS INITIAL.

* --Enqueue the business partner ---------------------------------------
  PERFORM dfkkop_enqueue.

* * init answer for popup for determination of collection agency
  CALL FUNCTION 'FKK_COLL_AG_SAMPLE_5060_INIT'.

*Tabelle t_fkkop muss gefüllt werden. Move-Corresponding von pos_itab
*-----------------------------------------------------------------------
  CALL FUNCTION 'FKK_RELEASE_FOR_COLLECT_AGENCY'
    EXPORTING
      i_aggrd               = const_aggrd_einzelabgabe
      i_xsimu               = ' '
      i_batch               = ' '
    TABLES
      t_fkkop               = itab_release
      t_fkkop_not_submitted = itab_release_not_submitted
      t_dfkkcoll            = ht_dfkkcoll
    EXCEPTIONS
      error                 = 1
      OTHERS                = 2.
  IF sy-subrc <> 0.
*      MESSAGE e513(>3) WITH 'FKK_RELEASE_FOR_COLLECT_AGENCY'.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    DESCRIBE TABLE itab_release_not_submitted.
    IF sy-tfill > 0.
      h_tfill = sy-tfill.
      DESCRIBE TABLE itab_release.
      MESSAGE w453(>3) WITH h_tfill sy-tfill.
    ENDIF.

*  pos_itab von itab_release modifizieren

    ht_pos[] = t_out[].

    LOOP AT itab_release.
      MOVE-CORRESPONDING itab_release TO wa_out.

      READ TABLE ht_dfkkcoll WITH KEY opbel = wa_out-opbel
                                      betrw = wa_out-betrw
                                      inkps = wa_out-inkps.
      IF sy-subrc EQ 0.
        wa_out-agsta = ht_dfkkcoll-agsta.
        wa_out-aggrd = ht_dfkkcoll-aggrd.
        wa_out-inkgp = ht_dfkkcoll-inkgp.

        READ TABLE ht_pos WITH KEY opbel = wa_out-opbel
                                   opupk = wa_out-opupk
                                   opupw = wa_out-opupw
                                   opupz = wa_out-opupz.
        h_tabix = sy-tabix.

        wa_out-mahnv = ht_pos-mahnv.
        wa_out-mahns = ht_pos-mahns.

        ls_opbel = wa_out-opbel.
        COLLECT ls_opbel INTO lt_opbel.

*     ICON auf Freigabe setzen
        CALL FUNCTION 'ICON_CREATE'
          EXPORTING
            name                  = 'ICON_RELEASE'
            info                  = TEXT-007
          IMPORTING
            result                = wa_out-status
          EXCEPTIONS
            icon_not_found        = 1
            outputfield_too_short = 2
            OTHERS                = 3.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

*       Kurztext zum Abgabestatus reinschreiben
        CLEAR ls_dd07t.
        SELECT * FROM dd07t INTO ls_dd07t
           WHERE domname = 'AGSTA_KK'
            AND ddlanguage = sy-langu
            AND domvalue_l = ht_dfkkcoll-agsta.
          wa_out-agstatxt = ls_dd07t-ddtext.
        ENDSELECT.

*      Name zum Inkassobüro lesen
        SELECT SINGLE name_org1 FROM but000 INTO wa_out-inkname
            WHERE partner = wa_out-inkgp.

*    Wenn ORG1 nicht gefüllt ist, prüfen, ob es eine Gruppe ist
        IF wa_out-inkname IS INITIAL.
          SELECT SINGLE name_grp1 FROM but000 INTO wa_out-inkname
            WHERE partner = wa_out-inkgp.
        ENDIF.

*    Letztendlich noch Vorname Nachname
        IF wa_out-inkname IS INITIAL.
          CLEAR ls_but000.
          SELECT SINGLE * FROM but000 INTO ls_but000
            WHERE partner = wa_out-inkgp.
          CONCATENATE ls_but000-name_first ls_but000-name_last
            INTO wa_out-inkname SEPARATED BY space.
        ENDIF.


        MODIFY t_out FROM wa_out INDEX h_tabix.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_opbel INTO ls_opbel.

      SELECT * FROM dfkkcoll INTO ls_dfkkcoll
        WHERE opbel = ls_opbel
        AND   inkps = '000'
        AND   agsta BETWEEN '97' AND '99'.
        DELETE dfkkcoll FROM ls_dfkkcoll.
      ENDSELECT.

    ENDLOOP.

    COMMIT WORK.
  ENDIF.

*  * --- Dequeue all business partner ------------------------------------
  CALL FUNCTION 'FKK_OPEN_ITEM_DEQUEUE'.


ENDFORM.                    " UCOM_FREIGABE

*&---------------------------------------------------------------------*
*&      Form  BUILD_RELEASE_TAB
*&---------------------------------------------------------------------*
*      POS_ITAB_MARKED    Tabelle mit den markierten
*                         Positionen (global)
*      <--P_ITAB_RELEASE  Posten, die abgegeben werden können
*----------------------------------------------------------------------*
FORM build_release_tab  TABLES  et_itab_release    STRUCTURE fkkop.

  DATA: ht_fkkcoll     TYPE TABLE OF dfkkcoll WITH HEADER LINE,
        wt_fkkop       LIKE fkkop OCCURS 0 WITH HEADER LINE,
        first_warn     TYPE c,
        first_warn_999 TYPE c.


  CLEAR: ht_enqtab, ht_enqtab[].
  REFRESH et_itab_release.

  CLEAR: first_warn, first_warn_999.


  LOOP AT t_out INTO wa_out
     WHERE sel IS NOT INITIAL.
*  --> Nuss 05.2018
*   Beim 4-Augen-Prinzip darf nur freigegeben werden, wenn der Status 98 (Freigabe durch Vorgesetzten) ist.
*    IF p_4eye IS NOT INITIAL.
*      IF wa_out-agsta = '99' OR
*         wa_out-agsta = '97'.
*        MOVE-CORRESPONDING wa_out TO pos_itab.
*
*        APPEND pos_itab TO pos_itab_marked.
*      ENDIF.
*    ELSE.
    MOVE-CORRESPONDING wa_out TO pos_itab.

    APPEND pos_itab TO pos_itab_marked.
*    ENDIF.
*  <-- Nuss 05.2018
  ENDLOOP.

  LOOP AT pos_itab_marked.
    IF pos_itab_marked-inkps <> '999'.
*     Normal case: any value for INKPS
      CALL FUNCTION 'FKK_COLLECT_AGENCY_ITEM_SELECT'
        EXPORTING
          i_opbel        = pos_itab_marked-opbel
          ix_opbel       = 'X' "const_marked
          i_inkps        = pos_itab_marked-inkps
          ix_inkps       = 'X' "const_marked
        TABLES
          t_fkkcoll      = ht_fkkcoll
        EXCEPTIONS
          initial_values = 1
          not_found      = 2
          OTHERS         = 3.
      IF sy-subrc = 0.
        READ TABLE ht_fkkcoll INDEX 1.
        IF ht_fkkcoll-agsta = const_agsta_freigegeben.
          IF first_warn IS INITIAL.
            first_warn = const_marked.
            MESSAGE w492(>3) WITH pos_itab_marked-opbel space.
          ENDIF.
          CONTINUE.   " Go to next table entry
        ELSE.
          IF  ht_fkkcoll-agsta = '98' OR
              ht_fkkcoll-agsta = '99'.
            CLEAR et_itab_release.
            CALL FUNCTION 'FKK_BP_LINE_ITEM_SELECT_SINGLE'
              EXPORTING
                i_opbel = pos_itab_marked-opbel
                i_opupw = pos_itab_marked-opupw
                i_opupk = pos_itab_marked-opupk
                i_opupz = pos_itab_marked-opupz
              IMPORTING
                e_fkkop = et_itab_release.
            IF et_itab_release IS INITIAL AND
               pos_itab_marked-opupw NE '000'.
* select repetition positions
              CALL FUNCTION 'FKK_BP_LINE_ITEMS_SEL_LOGICAL'
                EXPORTING
                  i_opbel     = pos_itab_marked-opbel
                TABLES
                  pt_logfkkop = wt_fkkop.

              READ TABLE wt_fkkop INTO et_itab_release WITH KEY
                                          opbel = pos_itab_marked-opbel
                                          opupw = pos_itab_marked-opupw
                                          opupk = pos_itab_marked-opupk
                                          opupz = pos_itab_marked-opupz.
              REFRESH wt_fkkop.
            ENDIF.
            IF NOT et_itab_release IS INITIAL.

              APPEND et_itab_release.

              READ TABLE ht_enqtab WITH KEY gpart = et_itab_release-gpart.
              IF sy-subrc NE 0.
                ht_enqtab-gpart = et_itab_release-gpart.
                APPEND ht_enqtab.
              ENDIF.
            ENDIF.

          ENDIF.
        ENDIF.
      ELSE.
        CLEAR et_itab_release.
        CALL FUNCTION 'FKK_BP_LINE_ITEM_SELECT_SINGLE'
          EXPORTING
            i_opbel = pos_itab_marked-opbel
            i_opupw = pos_itab_marked-opupw
            i_opupk = pos_itab_marked-opupk
            i_opupz = pos_itab_marked-opupz
          IMPORTING
            e_fkkop = et_itab_release.

        IF et_itab_release IS INITIAL AND
           pos_itab_marked-opupw NE '000'.
* select repetition positions
          CALL FUNCTION 'FKK_BP_LINE_ITEMS_SEL_LOGICAL'
            EXPORTING
              i_opbel     = pos_itab_marked-opbel
            TABLES
              pt_logfkkop = wt_fkkop.

          READ TABLE wt_fkkop INTO et_itab_release WITH KEY
                                      opbel = pos_itab_marked-opbel
                                      opupw = pos_itab_marked-opupw
                                      opupk = pos_itab_marked-opupk
                                      opupz = pos_itab_marked-opupz.
          REFRESH wt_fkkop.
        ENDIF.

        IF NOT et_itab_release IS INITIAL.

          APPEND et_itab_release.

          READ TABLE ht_enqtab WITH KEY gpart = et_itab_release-gpart.
          IF sy-subrc NE 0.
            ht_enqtab-gpart = et_itab_release-gpart.
            APPEND ht_enqtab.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSE.
*     FKKOP-INKPS = 999 shows that items is in collection case
      IF first_warn_999 IS INITIAL.
        first_warn_999 = const_marked.
        MESSAGE w505(>3) WITH pos_itab_marked-opbel.
      ENDIF.
      CONTINUE.   " Go to next table entry
    ENDIF.
  ENDLOOP.

ENDFORM.                    " BUILD_RELEASE_TAB

*&---------------------------------------------------------------------*
*&      Form  DFKKOP_ENQUEUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM dfkkop_enqueue .

  CALL FUNCTION 'FKK_OPEN_ITEM_ENQUEUE'
    TABLES
      t_enqtab = ht_enqtab.

  READ TABLE ht_enqtab INDEX 1.

  IF NOT ht_enqtab-xenqe IS INITIAL.
* dequeue to refresh internal lock tables
    CALL FUNCTION 'FKK_OPEN_ITEM_DEQUEUE'.
    CLEAR okcode.
    MESSAGE e499(>3) WITH ht_enqtab-gpart ht_enqtab-uname.
  ENDIF.

  IF NOT ht_enqtab-xenqm IS INITIAL.
* dequeue to refresh internal lock tables
    CALL FUNCTION 'FKK_OPEN_ITEM_DEQUEUE'.
    CLEAR okcode.
    MESSAGE e500(>3) WITH ht_enqtab-gpart.
  ENDIF.

ENDFORM.                    " DFKKOP_ENQUEUE

*&---------------------------------------------------------------------*
*&      Form  VIEW_VKONT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_POS_WA_GVKONT  text
*      -->P_POS_WA_GPART  text
*----------------------------------------------------------------------*
FORM view_vkont  USING    p_pos_wa_vkont TYPE vkont_kk
                          p_pos_wa_gpart TYPE gpart_kk.

  CHECK NOT p_pos_wa_vkont IS INITIAL.

  SET PARAMETER ID 'BPA' FIELD p_pos_wa_gpart.
  SET PARAMETER ID 'KTO' FIELD p_pos_wa_vkont.

  IF p_acccha IS INITIAL.

    CALL FUNCTION 'FKK_ACCOUNT_CHANGE'
      EXPORTING
        i_vkont       = p_pos_wa_vkont
        i_gpart       = p_pos_wa_gpart
        i_ch_mode     = '1'
        i_no_other    = 'X'
        i_no_change   = 'X'
      EXCEPTIONS
        error_message = 1.
    IF sy-subrc = 1.
*   raises only in dialog
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ELSE.

    CALL FUNCTION 'FKK_ACCOUNT_CHANGE'
      EXPORTING
        i_vkont       = p_pos_wa_vkont
        i_gpart       = p_pos_wa_gpart
        i_ch_mode     = '2'
        i_no_other    = 'X'
        i_no_change   = ' '
      EXCEPTIONS
        error_message = 1.
    IF sy-subrc = 1.
*   raises only in dialog
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.


ENDFORM.                    " VIEW_VKONT
*&---------------------------------------------------------------------*
*&      Form  MAHNZEILEN_LESEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*FORM mahnzeilen_lesen .

*  RANGES: lt_gpart FOR wa_fkkmaze-gpart,
*          lt_vkont for wa_fkkmaze-vkont,
*          lt_opbel for wa_fkkmaze-opbel,
*          lt_bukrs for wa_fkkmaze-bukrs,
*          lt_vtref for wa_fkkmaze-vtref.
*
*  SELECT * FROM fkkmaze INTO TABLE it_fkkmaze
*     WHERE laufd IN so_laufd
*      AND laufi IN so_laufi.
*
*  LOOP AT it_fkkmaze INTO wa_fkkmaze.
**   Geschäftspartner
*    lt_gpart-sign = 'I'.
*    lt_gpart-option = 'EQ'.
*    lt_gpart-low = wa_fkkmaze-gpart.
*    COLLECT lt_gpart.
*    CLEAR lt_gpart.
**   Vertragskonto
*    lt_vkont-sign = 'I'.
*    lt_vkont-option = 'EQ'.
*    lt_vkont-low = wa_fkkmaze-vkont.
*    COLLECT lt_vkont.
*    CLEAR lt_vkont.
**   Belegnummer
*    lt_opbel-sign = 'I'.
*    lt_opbel-option = 'EQ'.
*    lt_opbel-low = wa_fkkmaze-opbel.
*    COLLECT lt_opbel.
*    CLEAR lt_opbel.
**   Buchungskreis
*    lt_bukrs-sign = 'I'.
*    lt_bukrs-option = 'EQ'.
*    lt_bukrs-low = wa_fkkmaze-bukrs.
*    COLLECT lt_bukrs.
*    CLEAR lt_bukrs.
**   Vertrag
*    lt_vtref-sign = 'I'.
*    lt_vtref-option = 'EQ'.
*    lt_vtref-low = wa_fkkmaze-vtref.
*    COLLECT lt_vtref.
*    CLEAR lt_vtref.
*  ENDLOOP.
*
*so_gpart[] = lt_gpart[].
*so_vkont[] = lt_vkont[].
*so_opbel[] = lt_opbel[].
*so_vtref[] = lt_vtref[].
*so_bukrs[] = lt_bukrs[].

***ENDFORM.                    " MAHNZEILEN_LESEN

*&---------------------------------------------------------------------*
*&      Form  UCOM_FREIGABE_RUECKNAHME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ucom_freigabe_ruecknahme .

  DATA: itab_dfkkcoll LIKE TABLE OF dfkkcoll WITH HEADER LINE,
        itab_undo     LIKE TABLE OF pos_itab_marked WITH HEADER LINE,
        l_agsta       LIKE dfkkcoll-agsta,
        l_agdat       LIKE dfkkcoll-agdat,
        mode_delete   VALUE 'D'.

  CLEAR pos_itab_marked.
  REFRESH pos_itab_marked.

  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
    EXPORTING
      titel     = TEXT-inf
      textline1 = TEXT-f06
      textline2 = TEXT-e12.
  EXIT.

  LOOP AT t_out INTO wa_out
   WHERE sel IS NOT INITIAL.
    APPEND wa_out TO pos_itab_marked.
  ENDLOOP.

  LOOP AT pos_itab_marked.
    CLEAR: l_agsta, l_agdat.
* check that the status did not change
    SELECT SINGLE agsta agdat FROM dfkkcoll INTO (l_agsta, l_agdat)
                   WHERE opbel = pos_itab_marked-opbel
                     AND inkps = pos_itab_marked-inkps.

    IF l_agsta = const_agsta_freigegeben         OR
       l_agsta = const_agsta_storniert           OR
       l_agsta = const_agsta_recalled            OR
       ( ( l_agsta = const_agsta_cust_p_pay      OR
           l_agsta = const_agsta_p_paid          OR
           l_agsta = const_agsta_rel_erfolglos ) AND
           l_agdat IS INITIAL )                  AND
       pos_itab_marked-inkps > 0.

      READ TABLE itab_dfkkcoll
                WITH KEY opbel = pos_itab_marked-opbel
                         inkps = pos_itab_marked-inkps.
      IF sy-subrc NE 0.
        MOVE-CORRESPONDING: pos_itab_marked TO itab_dfkkcoll.
        APPEND itab_dfkkcoll.
      ENDIF.

      READ TABLE itab_undo
                WITH KEY opbel = pos_itab_marked-opbel
                         inkps = pos_itab_marked-inkps.
      IF sy-subrc NE 0.
        MOVE-CORRESPONDING pos_itab_marked TO itab_undo.
        APPEND itab_undo.
      ENDIF.

      READ TABLE ht_enqtab WITH KEY gpart = pos_itab_marked-gpart.
      IF sy-subrc NE 0.
        ht_enqtab-gpart = pos_itab_marked-gpart.
        APPEND ht_enqtab.
      ENDIF.
    ELSE.
      error = error + 1.
    ENDIF.

  ENDLOOP.

* -- Enqueue the business partner before changing table DFKKOP ---------
  PERFORM dfkkop_enqueue.

  IF NOT itab_dfkkcoll IS INITIAL.
    CALL FUNCTION 'FKK_DB_DFKKCOLL_MODE'
      EXPORTING
        i_mode    = mode_delete
      TABLES
        t_fkkcoll = itab_dfkkcoll
      EXCEPTIONS
        error     = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
      MESSAGE e845(>3) WITH 'DFKKCOLL'.
    ELSE.
*    insert collection agency history table
      PERFORM create_history TABLES itab_dfkkcoll.
    ENDIF.

    LOOP AT itab_undo.
      UPDATE dfkkop SET inkps = 0
                    WHERE opbel = itab_undo-opbel
                    AND   inkps = itab_undo-inkps.


      LOOP AT t_out INTO wa_out
                       WHERE opbel = itab_undo-opbel
                         AND inkps = itab_undo-inkps.

        CLEAR wa_out-inkgp.
        CLEAR wa_out-inkname.
        CLEAR wa_out-agsta.
        CLEAR wa_out-aggrd.
        CLEAR wa_out-agstatxt.

        wa_out-inkps = 0.
*   ICON auf Rücknahme Freigabe setzen
        CALL FUNCTION 'ICON_CREATE'
          EXPORTING
            name                  = 'ICON_LED_GREEN'
            info                  = TEXT-006
          IMPORTING
            result                = wa_out-status
          EXCEPTIONS
            icon_not_found        = 1
            outputfield_too_short = 2
            OTHERS                = 3.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

        MODIFY t_out FROM wa_out.
      ENDLOOP.

    ENDLOOP.

    COMMIT WORK.

* --- Dequeue all business partner ------------------------------------
    CALL FUNCTION 'FKK_OPEN_ITEM_DEQUEUE'.
  ENDIF.

ENDFORM.                    " UCOM_FREIGABE_RUECKNAHME

*&---------------------------------------------------------------------*
*&      Form  UCOM_SET_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ucom_set_status .

  DATA:  ls_dd07t     TYPE dd07t.
  DATA: ls_dfkkcoll TYPE dfkkcoll.
  DATA: ls_tfk050at TYPE tfk050at.
  DATA: v_tabix LIKE sy-tabix.

  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
    EXPORTING
      titel     = TEXT-inf
      textline1 = TEXT-f01
      textline2 = TEXT-e12.
  EXIT.

  LOOP AT t_out INTO wa_out
     WHERE sel IS NOT INITIAL.

    CHECK wa_out-agsta IS INITIAL.

    CLEAR ls_dfkkcoll.

    wa_out-agsta = '99'.

    CLEAR ls_tfk050at.
    SELECT SINGLE astxt FROM tfk050at INTO wa_out-agstatxt
      WHERE spras = sy-langu
        AND agsta = '99'.
*  <-- Nuss 05.2018

    IF sy-subrc NE 0.
      wa_out-agstatxt = 'Vorgemerkt'.
    ENDIF.

*     ICON auf YELLOW setzen
    CALL FUNCTION 'ICON_CREATE'
      EXPORTING
        name                  = 'ICON_SET_STATE'
        info                  = TEXT-012
      IMPORTING
        result                = wa_out-status
      EXCEPTIONS
        icon_not_found        = 1
        outputfield_too_short = 2
        OTHERS                = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    MOVE-CORRESPONDING wa_out TO ls_dfkkcoll.
    MODIFY dfkkcoll FROM ls_dfkkcoll.

    MODIFY t_out FROM wa_out.

  ENDLOOP.

  COMMIT WORK.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UCOM_SET_STATUS_HIER
*&      Vormerkung Status 99
*&---------------------------------------------------------------------*
FORM ucom_set_status_hier USING ff_ucomm LIKE sy-ucomm
                                ff_gplocked LIKE gv_gplocked.

  DATA: ls_dfkkcoll TYPE dfkkcoll.
  DATA: lt_dfkkcoll TYPE TABLE OF dfkkcoll.
  DATA: ls_tfk050at TYPE tfk050at.
  DATA: lv_tabix LIKE sy-tabix.
  DATA: lf_nochange TYPE sy-tabix.
  DATA: ls_header TYPE /adesso/inkasso_header.
  DATA: ls_items  TYPE /adesso/inkasso_items.
  DATA: lf_agstatxt TYPE val_text.
  DATA: lf_inkgp TYPE inkgp_kk.
  DATA: lf_inkname TYPE bu_descrip.

  CLEAR:   lf_nochange.
  CLEAR:   ff_gplocked.
  CLEAR:   lf_inkgp.

  PERFORM get_ibvalues(saplfka6) CHANGING lf_inkgp.

  IF lf_inkgp IS INITIAL.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-f01
        textline2 = TEXT-e10.
    EXIT.
  ENDIF.

  CALL FUNCTION 'BUP_PARTNER_DESCRIPTION_GET'
    EXPORTING
      i_partner          = lf_inkgp
      i_valdt_sel        = sy-datum
    IMPORTING
      e_description_name = lf_inkname
    EXCEPTIONS
      OTHERS             = 5.

  IF sy-subrc <> 0.
    ls_header-inkname = '???'.
  ENDIF.

  REFRESH lt_dfkkcoll.

* Für Hierarchische Liste
  LOOP AT t_header INTO ls_header
       WHERE sel IS NOT INITIAL.

    lv_tabix = sy-tabix.

* VK für Bearbeitung gesperrt ?
    IF ls_header-locked IS NOT INITIAL.
      ff_gplocked = 'X'.
      CONTINUE.
    ENDIF.

* Berechtigung für Status ?
    CLEAR gs_stat.
    READ TABLE gt_stat INTO gs_stat
         WITH KEY begru = gs_bgus-begru
                  ucomm = ff_ucomm
                  agsta = ls_header-agsta.

    IF sy-subrc NE 0.
      CLEAR gs_stat.
      ADD 1 TO lf_nochange.
      CONTINUE.
    ENDIF.

* Text und Icon zum neuen Status lesen
    CLEAR ls_tfk050at.
    SELECT SINGLE astxt FROM tfk050at
      INTO lf_agstatxt
           WHERE spras = sy-langu
           AND agsta = gs_stat-set_agsta.
    IF sy-subrc NE 0.
      lf_agstatxt = TEXT-012.
    ENDIF.

* Mahnsperre VK setzn
    PERFORM set_mahnsperre USING   ls_header-gpart
                                   ls_header-vkont
                                   p_lockr.

* Zahlsperre VK setzn
    PERFORM set_zahlsperre USING   ls_header-gpart
                                   ls_header-vkont.


    ls_header-inkgp   = lf_inkgp.
    ls_header-inkname = lf_inkname.
    ls_header-lockr   = p_lockr.
    ls_header-agsta   = gs_stat-set_agsta.

*   ICON auf Vorgemerkt setzen
    PERFORM set_status_icon USING ls_header-agsta ls_header-status.
    MODIFY t_header FROM ls_header INDEX lv_tabix.

* jetzt alle Posten bearbeiten
    LOOP AT t_items INTO ls_items
         WHERE gpart = ls_header-gpart
         AND   vkont = ls_header-vkont.

* Ausgeglichene oder stornierte Posten nicht berücksichtigen
      CHECK ls_items-augdt IS INITIAL.

      CLEAR ls_dfkkcoll.
      ls_items-inkgp    = lf_inkgp.
      ls_items-agsta    = gs_stat-set_agsta.
      ls_items-agstatxt = lf_agstatxt.
      MOVE-CORRESPONDING ls_items TO ls_dfkkcoll.
      MODIFY dfkkcoll FROM ls_dfkkcoll.

      IF sy-subrc = 0.
        APPEND ls_dfkkcoll TO lt_dfkkcoll.
*   ICON auf Vorgemerkt setzen
        PERFORM set_status_icon USING ls_items-agsta ls_items-status.

      ELSE.
        CALL FUNCTION 'ICON_CREATE'
          EXPORTING
            name                  = 'ICON_LED_RED'
            info                  = TEXT-e08
          IMPORTING
            result                = ls_items-status
          EXCEPTIONS
            icon_not_found        = 1
            outputfield_too_short = 2
            OTHERS                = 3.

        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      ENDIF.

      MODIFY t_items FROM ls_items.

    ENDLOOP.

  ENDLOOP.

  IF lt_dfkkcoll[] IS NOT INITIAL.
    PERFORM create_history TABLES lt_dfkkcoll.
  ENDIF.

  COMMIT WORK.

  IF lf_nochange > 0.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-f01
        textline2 = TEXT-e04.
  ENDIF.

ENDFORM.                    " UCOM_SET_STATUS_HIER

*&---------------------------------------------------------------------*
*&      Form  UCOM_CHANGE_INKGP_HIER
*&---------------------------------------------------------------------*
FORM ucom_change_inkgp_hier USING ff_ucomm LIKE sy-ucomm
                                  ff_gplocked LIKE gv_gplocked.

  DATA: ls_dfkkcoll TYPE dfkkcoll.
  DATA: ls_tfk050at TYPE tfk050at.
  DATA: lv_tabix LIKE sy-tabix.
  DATA: lf_nochange TYPE sy-tabix.
  DATA: lf_noch_stat TYPE sy-tabix.
  DATA: ls_header TYPE /adesso/inkasso_header.
  DATA: ls_items  TYPE /adesso/inkasso_items.
  DATA: lf_agstatxt TYPE val_text.
  DATA: lf_inkgp TYPE inkgp_kk.
  DATA: lf_inkname TYPE bu_descrip.

  CLEAR:   lf_nochange.
  CLEAR:   lf_noch_stat.
  CLEAR:   ff_gplocked.
  CLEAR:   lf_inkgp.

  PERFORM get_ibvalues(saplfka6) CHANGING lf_inkgp.

  IF lf_inkgp IS INITIAL.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-f01
        textline2 = TEXT-e10.
    EXIT.
  ENDIF.

  CALL FUNCTION 'BUP_PARTNER_DESCRIPTION_GET'
    EXPORTING
      i_partner          = lf_inkgp
      i_valdt_sel        = sy-datum
    IMPORTING
      e_description_name = lf_inkname
    EXCEPTIONS
      OTHERS             = 5.

  IF sy-subrc <> 0.
    ls_header-inkname = '???'.
  ENDIF.

* Für Hierarchische Liste
  LOOP AT t_header INTO ls_header
       WHERE sel IS NOT INITIAL.

    lv_tabix = sy-tabix.

* VK für Bearbeitung gesperrt ?
    IF ls_header-locked IS NOT INITIAL.
      ff_gplocked = 'X'.
      CONTINUE.
    ENDIF.

* Berechtigung für Status ?
    CLEAR gs_stat.
    READ TABLE gt_stat INTO gs_stat
         WITH KEY begru = gs_bgus-begru
                  ucomm = ff_ucomm
                  agsta = ls_header-agsta.

    IF sy-subrc NE 0.
      CLEAR gs_stat.
      ADD 1 TO lf_nochange.
      CONTINUE.
    ENDIF.

    IF ls_header-agsta = '01' OR
       ls_header-agsta = '02'.
      ADD 1 TO lf_noch_stat.
      CONTINUE.
    ENDIF.

    ls_header-inkgp   = lf_inkgp.
    ls_header-inkname = lf_inkname.

    MODIFY t_header FROM ls_header INDEX lv_tabix.

* jetzt alle Posten bearbeiten
    LOOP AT t_items INTO ls_items
         WHERE gpart = ls_header-gpart
         AND   vkont = ls_header-vkont.

* Ausgeglichene oder stornierte Posten nicht berücksichtigen
      CHECK ls_items-augdt IS INITIAL.

      CLEAR ls_dfkkcoll.

      ls_items-inkgp = lf_inkgp.

      MOVE-CORRESPONDING ls_items TO ls_dfkkcoll.
      MODIFY dfkkcoll FROM ls_dfkkcoll.

      IF sy-subrc = 0.

      ELSE.
        CALL FUNCTION 'ICON_CREATE'
          EXPORTING
            name                  = 'ICON_LED_RED'
            info                  = TEXT-e08
          IMPORTING
            result                = ls_items-status
          EXCEPTIONS
            icon_not_found        = 1
            outputfield_too_short = 2
            OTHERS                = 3.

        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      ENDIF.

      MODIFY t_items FROM ls_items.

    ENDLOOP.

  ENDLOOP.

  COMMIT WORK.

  IF lf_nochange > 0.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-f08
        textline2 = TEXT-e04.
  ENDIF.

  IF lf_noch_stat > 0.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-f08
        textline2 = TEXT-e14.
  ENDIF.

ENDFORM.                    " UCOM_CHANGE_INKGP_HIER

*&---------------------------------------------------------------------*
*&      Form  UCOM_DELETE_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ucom_delete_status .

  DATA: ls_dfkkcoll TYPE dfkkcoll.
  DATA: v_tabix LIKE sy-tabix.

  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
    EXPORTING
      titel     = TEXT-inf
      textline1 = TEXT-f02
      textline2 = TEXT-e12.

  LOOP AT t_out INTO wa_out
   WHERE sel IS NOT INITIAL.

    CHECK s_items-agsta = '99' OR
          s_items-agsta = '98' OR
          s_items-agsta = '97'.

    CLEAR wa_out-agstatxt.
    CLEAR wa_out-agsta.

    CALL FUNCTION 'ICON_CREATE'
      EXPORTING
        name                  = 'ICON_LED_GREEN'
        info                  = TEXT-006
      IMPORTING
        result                = wa_out-status
      EXCEPTIONS
        icon_not_found        = 1
        outputfield_too_short = 2
        OTHERS                = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    SELECT * FROM dfkkcoll INTO ls_dfkkcoll
      WHERE opbel = wa_out-opbel.
      DELETE dfkkcoll FROM ls_dfkkcoll.
    ENDSELECT.

    PERFORM del_mahnsperre USING   wa_out-gpart
                                   wa_out-vkont.

    MODIFY t_out FROM wa_out.

  ENDLOOP.

  COMMIT WORK.

ENDFORM.                    " UCOM_DELETE_STATUS

*&---------------------------------------------------------------------*
*&      Form  UCOM_DELETE_STATUS_HIER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ucom_delete_status_hier  USING ff_ucomm LIKE sy-ucomm
                                    ff_gplocked LIKE gv_gplocked.

  DATA: ls_dfkkcoll TYPE dfkkcoll.
  DATA: lt_dfkkcoll TYPE TABLE OF dfkkcoll.

  DATA: ls_tfk050at TYPE tfk050at.
  DATA: lv_tabix LIKE sy-tabix.
  DATA: lf_nochange TYPE sy-tabix.
  DATA: ls_header TYPE /adesso/inkasso_header.
  DATA: ls_items  TYPE /adesso/inkasso_items.
  DATA: lf_agstatxt TYPE val_text.

  CLEAR:   lf_nochange.
  CLEAR:   ff_gplocked.

  REFRESH lt_dfkkcoll.

* Für Hierarchische Liste
  LOOP AT t_header INTO ls_header
       WHERE sel IS NOT INITIAL.

    lv_tabix = sy-tabix.

* VK für Bearbeitung gesperrt ?
    IF ls_header-locked IS NOT INITIAL.
      ff_gplocked = 'X'.
      CONTINUE.
    ENDIF.

* Berechtigung für Status ?
    CLEAR gs_stat.
    READ TABLE gt_stat INTO gs_stat
         WITH KEY begru = gs_bgus-begru
                  ucomm = ff_ucomm
                  agsta = ls_header-agsta.

    IF sy-subrc NE 0.
      CLEAR gs_stat.
      ADD 1 TO lf_nochange.
      CONTINUE.
    ENDIF.

* Text und Icon zum neuen Status lesen
    CLEAR ls_tfk050at.
    SELECT SINGLE astxt FROM tfk050at
      INTO lf_agstatxt
           WHERE spras = sy-langu
           AND agsta = gs_stat-set_agsta.
    IF sy-subrc NE 0.
      ls_items-agstatxt = TEXT-006.
    ENDIF.

    PERFORM del_mahnsperre USING   ls_header-gpart
                                   ls_header-vkont.

    PERFORM set_mahnsp_hist USING  ls_header-gpart
                                   ls_header-vkont
                                   ls_header-lockr.

    CLEAR ls_header-inkgp.
    CLEAR ls_header-inkname.
    ls_header-agsta = gs_stat-set_agsta.

*   ICON auf Abzugebender Poster setzen
    PERFORM set_status_icon USING ls_header-agsta ls_header-status.
    MODIFY t_header FROM ls_header INDEX lv_tabix.


* jetzt alle Posten bearbeiten
    LOOP AT t_items INTO ls_items
         WHERE gpart = ls_header-gpart
         AND   vkont = ls_header-vkont.

      SELECT * FROM dfkkcoll INTO ls_dfkkcoll
        WHERE opbel = ls_items-opbel.
        DELETE dfkkcoll FROM ls_dfkkcoll.
*       Fill table for History
        ls_dfkkcoll-agsta = gs_stat-set_agsta.
        APPEND ls_dfkkcoll TO lt_dfkkcoll.
      ENDSELECT.

      CLEAR ls_items-agstatxt.
      CLEAR ls_items-inkgp.
      ls_items-agsta = gs_stat-set_agsta.

      PERFORM set_status_icon USING ls_items-agsta ls_items-status.
      MODIFY t_items FROM ls_items.

    ENDLOOP.

  ENDLOOP.

  IF lt_dfkkcoll[] IS NOT INITIAL.
    PERFORM create_history TABLES lt_dfkkcoll.
  ENDIF.

  COMMIT WORK.

  IF lf_nochange > 0.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-f02
        textline2 = TEXT-e04.
  ENDIF.


ENDFORM.                    " UCOM_DELETE_STATUS_HIER


*&---------------------------------------------------------------------*
*&      Form  UCOM_GET_KONTENSTAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ucom_get_kontenstand .

  IF wa_out IS NOT INITIAL.

    SET PARAMETER ID 'BPA' FIELD wa_out-gpart.
    SET PARAMETER ID 'KTO' FIELD wa_out-vkont.
    CALL TRANSACTION 'FPL9'.

  ELSEIF s_header IS NOT INITIAL.
    SET PARAMETER ID 'BPA' FIELD s_header-gpart.
    SET PARAMETER ID 'KTO' FIELD s_header-vkont.
    CALL TRANSACTION 'FPL9' AND SKIP FIRST SCREEN.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_CIC_FRAME_FOR_USER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_IV_SCREEN_NO  text
*----------------------------------------------------------------------*
FORM get_cic_frame_for_user  CHANGING iv_screen_no TYPE cicfwscreenno.

  DATA: it_cic_prof TYPE TABLE OF cicprofiles.

  CALL FUNCTION 'CIC_GET_ORG_PROFILES'
    EXPORTING
      agent                 = sy-uname
    TABLES
      profile_list          = it_cic_prof
    EXCEPTIONS
      call_center_not_found = 1
      agent_group_not_found = 2
      profiles_not_found    = 3
      no_hr_record          = 4
      cancel                = 5
      OTHERS                = 6.
  IF sy-subrc <> 0.
    MESSAGE e003.
    EXIT.
  ENDIF.

* existiert mind. 1 Eintrag
  IF lines( it_cic_prof ) EQ 0.
    MESSAGE e003.
    EXIT.
  ENDIF.

* 1. Datensatz aus Tabelle zuweisen
  FIELD-SYMBOLS: <fs_prof> TYPE cicprofiles.
  READ TABLE it_cic_prof ASSIGNING <fs_prof> INDEX 1.
* Fehlerprüfung
  IF <fs_prof> IS NOT ASSIGNED.
    MESSAGE e003.
    EXIT.
  ENDIF.

* Passendes CIC-Profil lesen
* Konfiguration auslesen um die DYNPRO-Nr zu gelangen
  SELECT SINGLE frame_screen
    INTO iv_screen_no
    FROM cicprofile
      INNER JOIN cicconf
        ON cicconf~mandt = cicprofile~mandt
        AND cicconf~frame_conf = cicprofile~framework_id
    WHERE cicprofile~mandt = sy-mandt
    AND cicprofile~cicprof = <fs_prof>-cicprof.

  IF iv_screen_no IS INITIAL.
    MESSAGE e003.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UCOM_ABGABE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ucom_abgabe .

  DATA: ls_out LIKE /adesso/inkasso_out,
        lt_out LIKE STANDARD TABLE OF /adesso/inkasso_out.

  DATA: rspar_tab  TYPE TABLE OF rsparams,
        rspar_line LIKE LINE OF rspar_tab.

  DATA: lt_cust TYPE TABLE OF /adesso/ink_cust.
  DATA: ls_cust TYPE /adesso/ink_cust.

  DATA: lv_inkgp TYPE but000-partner.

  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
    EXPORTING
      titel     = TEXT-inf
      textline1 = TEXT-f07
      textline2 = TEXT-e12.
  EXIT.

  LOOP AT t_out INTO ls_out
    WHERE sel IS NOT INITIAL
      AND agsta = '01'.
    APPEND ls_out TO lt_out.
  ENDLOOP.

  IF lt_out IS INITIAL.
    MESSAGE e004.
    EXIT.
  ENDIF.

  CLEAR lv_inkgp.
  LOOP AT lt_out INTO ls_out.

*  Es ksnn nur an ein Inkassobüro abgegeben werden.
    IF lv_inkgp IS NOT INITIAL.
      IF ls_out-inkgp NE lv_inkgp.
*        MESSAGE e000(e4) WITH 'Bitte nur ein Inkassobüro zur Abgabe auswählen'.
        MESSAGE e005.
        EXIT.
      ENDIF.
    ENDIF.

*   Vertragskontonummer
    rspar_line-selname = 'SELVKONT_LOW'.
    rspar_line-kind = 'S'.
    rspar_line-sign = 'I'.
    rspar_line-option = 'EQ'.
    rspar_line-low = ls_out-vkont.
    APPEND rspar_line TO rspar_tab.
    CLEAR rspar_line.

*   Belegnummer
    rspar_line-selname = 'SELOPBEL_LOW'.
    rspar_line-kind = 'S'.
    rspar_line-sign = 'I'.
    rspar_line-option = 'EQ'.
    rspar_line-low = ls_out-opbel.
    APPEND rspar_line TO rspar_tab.
    CLEAR rspar_line.

*  Inkassobüro
    rspar_line-selname = 'COLGPART'.
    rspar_line-kind = 'P'.
    rspar_line-low = ls_out-inkgp.
    APPEND rspar_line TO rspar_tab.
    CLEAR rspar_line.

    MOVE ls_out-inkgp TO lv_inkgp.

  ENDLOOP.

*  Auch statistische Posten
  rspar_line-selname = 'XSTKZ'.
  rspar_line-kind = 'P'.
  rspar_line-low = 'X'.
  APPEND rspar_line TO rspar_tab.
  CLEAR rspar_line.

*  Simulation aus
  rspar_line-selname = 'SIMULATE'.
  rspar_line-kind = 'P'.
  rspar_line-low = ' '.
  APPEND rspar_line TO rspar_tab.
  CLEAR rspar_line.

*  Echtlauf
  rspar_line-selname = 'REALRUN'.
  rspar_line-kind = 'P'.
  rspar_line-low = 'X'.
  APPEND rspar_line TO rspar_tab.
  CLEAR rspar_line.

* Dateierstellung
  rspar_line-selname = 'YESFILE'.
  rspar_line-kind = 'P'.
  rspar_line-low = 'X'.
  APPEND rspar_line TO rspar_tab.
  CLEAR rspar_line.

* Dateierstellung / Name aus Customizing
  REFRESH lt_cust.
  SELECT * FROM /adesso/ink_cust INTO TABLE lt_cust
     WHERE inkasso_option    = 'DATEI'
     AND   inkasso_category  = 'NAME'
     AND   inkasso_field     = 'FILENAME'.

  READ TABLE lt_cust INTO ls_cust INDEX 1.

  rspar_line-selname = 'FILENAME'.
  rspar_line-kind = 'P'.
  rspar_line-low = ls_cust-inkasso_value.
  APPEND rspar_line TO rspar_tab.
  CLEAR rspar_line.

  SUBMIT rfkkcol2  VIA SELECTION-SCREEN
                     WITH SELECTION-TABLE rspar_tab
                     AND RETURN.

* Posten abgegeben ?
  LOOP AT t_out INTO ls_out
    WHERE sel IS NOT INITIAL
      AND agsta = '01'.

    SELECT SINGLE inkps agsta aggrd inkgp FROM dfkkcoll
     INTO CORRESPONDING FIELDS OF ls_out
        WHERE opbel = ls_out-opbel
        AND   inkps = ls_out-inkps
        AND   agsta = '02'.

    IF sy-subrc = 0.

      ls_out-agstatxt = 'Abgegeben'.

      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_PROPRIETARY'
          info                  = TEXT-011
        IMPORTING
          result                = ls_out-status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      MODIFY t_out FROM ls_out.

    ENDIF.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UCOM_ADD_INFO_HIER
*&---------------------------------------------------------------------*
FORM ucom_add_info_hier .

  DATA: ls_ink_addi TYPE /adesso/ink_addi.
  DATA: lt_sval     LIKE TABLE OF sval.
  DATA: ls_sval     LIKE sval.
  DATA: lf_return   TYPE c.
  DATA: lf_new      TYPE c.
  DATA: lf_title(100).

  FIELD-SYMBOLS: <comp> TYPE any.

  IF s_header-agsta = space.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-025
        textline2 = TEXT-e19.
    EXIT.
  ENDIF.

  CLEAR: lf_new.
  SELECT SINGLE * FROM /adesso/ink_addi
         INTO ls_ink_addi
         WHERE gpart = s_header-gpart
         AND   vkont = s_header-vkont
         AND   inkgp = s_header-inkgp
         AND   agdat = s_header-agdat.

  IF sy-subrc NE 0.
    CLEAR ls_ink_addi.
    MOVE-CORRESPONDING s_header TO ls_ink_addi.
    ls_ink_addi-mandt = sy-mandt.
    lf_new = 'X'.
  ENDIF.

  REFRESH lt_sval.
  LOOP AT gt_dd03m INTO gs_dd03m.
    CLEAR ls_sval.
    MOVE-CORRESPONDING gs_dd03m TO ls_sval.
    IF gs_dd03m-keyflag = 'X'.
      ls_sval-field_attr = '02'.
    ENDIF.
    CASE gs_dd03m-fieldname.
      WHEN 'INKGP'OR 'AGDAT'.
        ls_sval-field_attr = '02'.
    ENDCASE.
    IF s_header-agdat IS NOT INITIAL.
      ls_sval-field_attr = '02'.
    ENDIF.
    ASSIGN COMPONENT  gs_dd03m-fieldname OF STRUCTURE ls_ink_addi TO <comp>.
    ls_sval-value = <comp>.
    APPEND ls_sval TO lt_sval.
  ENDLOOP.

  IF s_header-agdat IS NOT INITIAL.
    lf_title = TEXT-026.
  ELSE.
    lf_title = TEXT-025.
  ENDIF.


  CLEAR gv_popgv_code.
  CALL FUNCTION 'POPUP_GET_VALUES_USER_BUTTONS'
    EXPORTING
      popup_title       = lf_title
      programname       = '/ADESSO/INKASSO_MONITOR'
      formname          = 'EXIT_POPUP_GV_ADD_INFO'
      ok_pushbuttontext = 'Sichern'
      icon_ok_push      = c_ibut_save
      first_pushbutton  = 'Löschen'
      icon_button_1     = c_ibut_dele
      start_column      = '20'
    IMPORTING
      returncode        = lf_return
    TABLES
      fields            = lt_sval.

  IF lf_return = 'A'.
*   Aktion abgebrochen, Keine Änderung
*    MESSAGE i000(/adesso/inkmon) WITH TEXT-m01.
*    RETURN.
  ELSE.

    CHECK s_header-agdat IS INITIAL.
*    and      lf_new = space.

* Routine zur Behandlung der OkCodes des Popups
    CASE gv_popgv_code.
*     Sichern
      WHEN 'FURT'.
        LOOP AT lt_sval INTO ls_sval.
          ASSIGN COMPONENT  ls_sval-fieldname OF STRUCTURE ls_ink_addi TO <comp>.
          <comp> = ls_sval-value .
        ENDLOOP.
        MODIFY /adesso/ink_addi FROM ls_ink_addi.
        IF sy-subrc = 0.
          COMMIT WORK.
          s_header-freetext  = ls_ink_addi-freetext.
          s_header-unbverz   = ls_ink_addi-unbverz.
          s_header-minderj   = ls_ink_addi-minderj.
          s_header-erbenhaft = ls_ink_addi-erbenhaft.
          s_header-betreuung = ls_ink_addi-betreuung.
          s_header-insolvenz = ls_ink_addi-insolvenz.
        ENDIF.

*     Löschen
      WHEN 'COD1'.
        DELETE /adesso/ink_addi FROM ls_ink_addi.
        IF sy-subrc = 0.
          COMMIT WORK.
          CLEAR s_header-freetext.
          CLEAR s_header-unbverz.
          CLEAR s_header-minderj.
          CLEAR s_header-erbenhaft.
          CLEAR s_header-betreuung.
          CLEAR s_header-insolvenz.
        ENDIF.

      WHEN OTHERS.
    ENDCASE.

  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  EXIT_POPUP_GV_HANDLE
*&---------------------------------------------------------------------*
FORM exit_popup_gv_add_info TABLES   ft_sval  STRUCTURE sval
                            USING    ff_code
                            CHANGING fs_svale STRUCTURE svale
                                     ff_show_popup.

  gv_popgv_code = ff_code.

ENDFORM.

**&---------------------------------------------------------------------*
**&      Form  UCOM_BUILD_FREETEXT
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**  -->  p1        text
**  <--  p2        text
**----------------------------------------------------------------------*
*FORM ucom_build_freetext .
*
*
*  CALL SCREEN 9000 STARTING AT 10 10.
*
*
*  IF t_out IS NOT INITIAL.                                "Nuss 06.2018
*    IF ok = 'SAV'.
*
*      MODIFY t_out FROM wa_out TRANSPORTING freetext.
*
*      MOVE wa_out-gpart TO gs_texte-gpart.
*      MOVE wa_out-vkont TO gs_texte-vkont.
**   --> Nuss 06.2018
**   Freitext auf Vertragskontoebene
**    MOVE wa_out-opbel TO gs_texte-opbel.
**    MOVE wa_out-opupk TO gs_texte-opupk.
**    MOVE wa_out-opupw TO gs_texte-opupw.
**    MOVE wa_out-opupz TO gs_texte-opupz.
**   <-- Nuss 06.2018
*      MOVE wa_out-freetext TO gs_texte-freetext.
*
*      MODIFY /adesso/ink_text FROM gs_texte.
*    ELSEIF ok = 'DEL'.
*      MODIFY t_out FROM wa_out TRANSPORTING freetext.
*
*      MOVE wa_out-gpart TO gs_texte-gpart.
*      MOVE wa_out-vkont TO gs_texte-vkont.
**   --> Nuss 06.2018
**   Nur auf Vertragskontebene
**    MOVE wa_out-opbel TO gs_texte-opbel.
**    MOVE wa_out-opupk TO gs_texte-opupk.
**    MOVE wa_out-opupw TO gs_texte-opupw.
**    MOVE wa_out-opupz TO gs_texte-opupz.
**   <-- Nuss 06.2018
*      CLEAR wa_out-freetext.
*
*      DELETE /adesso/ink_text FROM gs_texte.
*
*    ENDIF.
*  ENDIF.                                                      "Nuss 06.2018
*
** --> Nuss 06.2018
*  IF t_header[] IS NOT INITIAL.
*
*    s_header-freetext = wa_out-freetext.
*
*    IF ok = 'SAV'.
*
*      MODIFY t_header[] FROM s_header TRANSPORTING freetext.
*
*      MOVE s_header-gpart TO gs_texte-gpart.
*      MOVE s_header-vkont TO gs_texte-vkont.
*      MOVE s_header-freetext TO gs_texte-freetext.
*
*      MODIFY /adesso/ink_text FROM gs_texte.
*    ELSEIF ok = 'DEL'.
*
*      CLEAR s_header-freetext.
*
*      MODIFY t_header[] FROM s_header TRANSPORTING freetext.
*
*      MOVE s_header-gpart TO gs_texte-gpart.
*      MOVE s_header-vkont TO gs_texte-vkont.
*      CLEAR s_header-freetext.
*
*      DELETE /adesso/ink_text FROM gs_texte.
*
*    ENDIF.
*  ENDIF.
**  <-- Nuss 06.2018
*
*ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  UCOM_SWITCH_VIEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_REV_ALV  text
*----------------------------------------------------------------------*
FORM ucom_switch_view  USING fr_grid TYPE REF TO cl_gui_alv_grid.

  DATA: lt_sort TYPE lvc_t_sort,
        ls_sort TYPE lvc_s_sort.


  IF fr_grid->is_ready_for_input( ) EQ 0.


* set edit enabled cells ready for input
    CALL METHOD fr_grid->set_ready_for_input
      EXPORTING
        i_ready_for_input = 1.

  ELSE.

* lock edit enabled cells against input

    CALL METHOD fr_grid->set_ready_for_input
      EXPORTING
        i_ready_for_input = 0.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ucom_EDIT_INTVERM
*&---------------------------------------------------------------------*
FORM ucom_edit_intverm .

  DATA: lt_text     TYPE catsxt_longtext_itab,
        ls_text     TYPE txline,
        lt_head     TYPE TABLE OF thead,
        ls_head     TYPE thead,
        ls_line     TYPE tline,
        lt_line     TYPE TABLE OF tline,
        ls_stxh     TYPE stxh,
        lt_stxh     TYPE TABLE OF stxh,
        lv_lfdnr(3) TYPE n,
        lv_pattern  TYPE char30,
        lv_select   TYPE char30,
        lv_object   TYPE /adesso/inkasso_value,
        lv_id       TYPE /adesso/inkasso_value.

  CLEAR gs_cust.
  READ TABLE gt_cust INTO gs_cust
    WITH KEY inkasso_option = 'INTVERM'
             inkasso_field  = 'TDOBJECT'.

  IF sy-subrc = 0.
    MOVE gs_cust-inkasso_value TO lv_object.
  ELSE.
    EXIT.
  ENDIF.

  CLEAR gs_cust.
  READ TABLE gt_cust INTO gs_cust
    WITH KEY inkasso_option = 'INTVERM'
             inkasso_field  = 'TDID'.

  IF sy-subrc = 0.
    MOVE gs_cust-inkasso_value TO lv_id.
  ELSE.
    EXIT.
  ENDIF.

  CALL FUNCTION 'CATSXT_SIMPLE_TEXT_EDITOR'
    EXPORTING
      im_title = 'INKASSO_MONITOR'
*     IM_DISPLAY_MODE       = ' '
*     IM_START_COLUMN       = 10
*     IM_START_ROW          = 10
    CHANGING
      ch_text  = lt_text.


  LOOP AT lt_text INTO ls_text.
    MOVE ls_text TO ls_line-tdline.
    APPEND ls_line TO lt_line.
  ENDLOOP.

  IF wa_out IS NOT INITIAL.               "Nuss 06.2018
    CONCATENATE wa_out-gpart
                '_'
                wa_out-vkont
                '_'
                INTO lv_pattern.
* --> Nuss 06.2018
  ELSE.
    CONCATENATE s_header-gpart
                '_'
                s_header-vkont
                '_'
                INTO  lv_pattern.
  ENDIF.
* <-- Nuss 06.2018



  CONCATENATE lv_pattern '%' INTO lv_select.

  CLEAR lt_stxh.
  SELECT * FROM stxh INTO TABLE lt_stxh
           WHERE tdobject = lv_object
           AND tdname LIKE lv_select
           AND tdid = lv_id
           AND tdspras = sy-langu.

  SORT lt_stxh BY tdname DESCENDING.
  READ TABLE lt_stxh INTO ls_stxh INDEX 1.
  IF sy-subrc = 0.
    lv_lfdnr = ls_stxh-tdname+24(3).
    ADD 1 TO lv_lfdnr.
    CONCATENATE lv_pattern lv_lfdnr INTO ls_head-tdname.
  ELSE.
    CONCATENATE lv_pattern '001' INTO ls_head-tdname.
  ENDIF.

  ls_head-tdobject = lv_object.
  ls_head-tdid   = lv_id.
  ls_head-tdspras = sy-langu.

  CALL FUNCTION 'SAVE_TEXT'
    EXPORTING
      client   = sy-mandt
      header   = ls_head
*     INSERT   = ' '
*     SAVEMODE_DIRECT       = ' '
*     OWNER_SPECIFIED       = ' '
*     LOCAL_CAT             = ' '
* IMPORTING
*     FUNCTION =
*     NEWHEADER             =
    TABLES
      lines    = lt_line
    EXCEPTIONS
      id       = 1
      language = 2
      name     = 3
      object   = 4
      OTHERS   = 5.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  READ TABLE lt_text INTO ls_text INDEX 1.

  IF wa_out IS NOT INITIAL.
    wa_out-intverm = ls_text.
    MODIFY t_out FROM wa_out TRANSPORTING intverm.
  ELSE.
    s_header-intverm = ls_text.
    MODIFY t_header FROM s_header TRANSPORTING intverm.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_INTVERM
*&---------------------------------------------------------------------*
FORM display_intverm .
  DATA: lt_thead   TYPE TABLE OF thead,
        ls_thead   TYPE thead,
        lv_pattern TYPE char30,
        lv_select  TYPE char30,
        ls_stxh    TYPE stxh,
        lt_stxh    TYPE STANDARD TABLE OF stxh,
        lt_texte   TYPE text_lh,
        ls_texte   TYPE itclh,
        ls_lines   TYPE tline,
        lt_text    TYPE catsxt_longtext_itab,
        ls_text    TYPE txline,
        ls_line    TYPE tline,
        lv_date    TYPE char10,
        lv_time    TYPE char8,
        lv_object  TYPE /adesso/inkasso_value,
        lv_id      TYPE /adesso/inkasso_value.

  CLEAR gs_cust.
  READ TABLE gt_cust INTO gs_cust
    WITH KEY inkasso_option = 'INTVERM'
             inkasso_field  = 'TDOBJECT'.

  IF sy-subrc = 0.
    MOVE gs_cust-inkasso_value TO lv_object.
  ELSE.
    EXIT.
  ENDIF.

  CLEAR gs_cust.
  READ TABLE gt_cust INTO gs_cust
    WITH KEY inkasso_option = 'INTVERM'
             inkasso_field  = 'TDID'.

  IF sy-subrc = 0.
    MOVE gs_cust-inkasso_value TO lv_id.
  ELSE.
    EXIT.
  ENDIF.

  IF wa_out IS NOT INITIAL.
    CONCATENATE wa_out-gpart
                '_'
                wa_out-vkont
                '_'
                INTO lv_pattern.
  ENDIF.

* --> Nuss 06.2018
* Hierarchische Liste
  IF lv_pattern IS INITIAL.
    CONCATENATE s_header-gpart
              '_'
              s_header-vkont
              '_'
              INTO lv_pattern.
  ENDIF.
* <-- Nuss 06.2018

  CONCATENATE lv_pattern '%' INTO lv_select.

  CLEAR lt_stxh.
  SELECT * FROM stxh INTO TABLE lt_stxh
    WHERE tdobject = lv_object
      AND tdname LIKE lv_select
      AND tdid     = lv_id
      AND tdspras  = sy-langu.

  LOOP AT lt_stxh INTO ls_stxh.
    MOVE-CORRESPONDING ls_stxh TO ls_thead.
    APPEND ls_thead TO lt_thead.
    CLEAR ls_thead.
  ENDLOOP.

  CALL FUNCTION 'READ_TEXT_TABLE'
* EXPORTING
*   CLIENT_SPECIFIED              = ' '
*   ARCHIVE_HANDLE                = 0
*   LOCAL_CAT                     = ' '
    IMPORTING
      text_table              = lt_texte
*     ERROR_TABLE             =
    TABLES
      text_headers            = lt_thead
    EXCEPTIONS
      wrong_access_to_archive = 1
      OTHERS                  = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  SORT lt_texte BY header-tdname DESCENDING.

  LOOP AT lt_texte INTO ls_texte.

*         Datum Formatieren
    CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
      EXPORTING
        date_internal            = ls_texte-header-tdfdate
      IMPORTING
        date_external            = lv_date
      EXCEPTIONS
        date_internal_is_invalid = 1
        OTHERS                   = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

*        Zeit umformatieren
    CONCATENATE ls_texte-header-tdftime(2)
                ':'
                ls_texte-header-tdftime+2(2)
                ':'
                ls_texte-header-tdftime+4(2)
                 INTO lv_time.


    CONCATENATE ls_texte-header-tdfuser
                lv_date
                lv_time
                INTO ls_text
                SEPARATED BY space.

    APPEND ls_text TO lt_text.
    CLEAR ls_text.
*         Texte einlesen
    LOOP AT ls_texte-lines INTO ls_lines.
      MOVE ls_lines-tdline TO ls_text.
      APPEND ls_text TO lt_text.
      CLEAR ls_text.
    ENDLOOP.
    APPEND INITIAL LINE TO lt_text.
  ENDLOOP.

  CALL FUNCTION 'CATSXT_SIMPLE_TEXT_EDITOR'
    EXPORTING
      im_title        = 'INKASSO MONITOR'
      im_display_mode = 'X'
*     IM_START_COLUMN = 10
*     IM_START_ROW    = 10
    CHANGING
      ch_text         = lt_text.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DOCU
*&---------------------------------------------------------------------*
FORM display_docu .

  DATA: lt_thead   TYPE TABLE OF thead,
        ls_thead   TYPE thead,
        lv_pattern TYPE char30,
        lv_select  TYPE char30,
        ls_stxh    TYPE stxh,
        lt_stxh    TYPE STANDARD TABLE OF stxh,
        lt_texte   TYPE text_lh,
        ls_texte   TYPE itclh,
        ls_lines   TYPE tline,
        lt_text    TYPE catsxt_longtext_itab,
        ls_text    TYPE txline,
        ls_line    TYPE tline,
        lv_date    TYPE char10,
        lv_time    TYPE char8,
        lv_object  TYPE /adesso/inkasso_value,
        lv_id      TYPE /adesso/inkasso_value.
  DATA: ls_wo_mon  TYPE /adesso/wo_mon.
  DATA: ls_vkst     TYPE /adesso/wo_vkst.  "Verkaufsquote Texte
  DATA: ls_igrdt    TYPE /adesso/wo_igrdt. "Int.Ausbuchungsgrund Texte
  DATA: ls_tfk048at TYPE tfk048at.          "Ausbuchungsgrund Texte


  CHECK NOT s_header-vkont IS INITIAL.

* infos im ausbuchungsmonitor
  CLEAR: ls_wo_mon.
  SELECT * FROM /adesso/wo_mon
         INTO  ls_wo_mon
         WHERE vkont = s_header-vkont
         AND   hvorg IN gr_hvorg.
  ENDSELECT.

  IF sy-subrc = 0.
* Kontakt Text Ausbuchungsgrund
    CLEAR ls_text.
    READ TABLE gt_tfk048at INTO ls_tfk048at
         WITH KEY spras = sy-langu
                  abgrd = ls_wo_mon-abgrd.
    CONCATENATE ls_wo_mon-abgrd
                ls_tfk048at-abtxt
                TEXT-040
                INTO ls_text
                SEPARATED BY space.
    APPEND ls_text TO lt_text.

* Kontakt Text Interner Ausbuchungsgrund
    CLEAR ls_text.
    READ TABLE gt_igrdt INTO ls_igrdt
         WITH KEY spras = sy-langu
                  woigd = ls_wo_mon-woigd.
    CONCATENATE ls_wo_mon-woigd
                ls_igrdt-woigdt
                TEXT-041
                INTO ls_text
                SEPARATED BY space.
    APPEND ls_text TO lt_text.

* Kontakt Text Verkaufsquote
    CLEAR ls_text.
    READ TABLE gt_vkst INTO ls_vkst
         WITH KEY spras = sy-langu
                  wovks = ls_wo_mon-wovks.
    CONCATENATE ls_wo_mon-wovks
                ls_vkst-wovkt
                TEXT-042
                INTO ls_text
                SEPARATED BY space.
    APPEND ls_text TO lt_text.
  ENDIF.

  CLEAR gs_cust.
  READ TABLE gt_cust INTO gs_cust
       WITH KEY inkasso_option   = 'AUSBUCHUNG'
                inkasso_category = 'DOCU'
                inkasso_field    = 'TDOBJECT'.

  IF sy-subrc = 0.
    MOVE gs_cust-inkasso_value TO lv_object.
  ELSE.
    EXIT.
  ENDIF.

  CLEAR gs_cust.
  READ TABLE gt_cust INTO gs_cust
       WITH KEY inkasso_option   = 'AUSBUCHUNG'
                inkasso_category = 'DOCU'
                inkasso_field    = 'TDID'.

  IF sy-subrc = 0.
    MOVE gs_cust-inkasso_value TO lv_id.
  ELSE.
    EXIT.
  ENDIF.

  CONCATENATE s_header-gpart '_'
              s_header-vkont '_'
              INTO lv_pattern.

  CONCATENATE lv_pattern '%' INTO lv_select.

  CLEAR lt_stxh.
  SELECT * FROM stxh INTO TABLE lt_stxh
    WHERE tdobject = lv_object
      AND tdname LIKE lv_select
      AND tdid     = lv_id
      AND tdspras  = sy-langu.

  LOOP AT lt_stxh INTO ls_stxh.
    MOVE-CORRESPONDING ls_stxh TO ls_thead.
    APPEND ls_thead TO lt_thead.
    CLEAR ls_thead.
  ENDLOOP.

  CALL FUNCTION 'READ_TEXT_TABLE'
    IMPORTING
      text_table              = lt_texte
    TABLES
      text_headers            = lt_thead
    EXCEPTIONS
      wrong_access_to_archive = 1
      OTHERS                  = 2.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  SORT lt_texte BY header-tdname DESCENDING.

  IF lt_texte[] IS NOT INITIAL.
    APPEND INITIAL LINE TO lt_text.
  ENDIF.

  LOOP AT lt_texte INTO ls_texte.

*         Datum Formatieren
    CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
      EXPORTING
        date_internal            = ls_texte-header-tdfdate
      IMPORTING
        date_external            = lv_date
      EXCEPTIONS
        date_internal_is_invalid = 1
        OTHERS                   = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

*   Zeit umformatieren
    CONCATENATE ls_texte-header-tdftime(2)
                ':'
                ls_texte-header-tdftime+2(2)
                ':'
                ls_texte-header-tdftime+4(2)
                 INTO lv_time.

    CONCATENATE ls_texte-header-tdfuser
                lv_date
                lv_time
                INTO ls_text
                SEPARATED BY space.

    APPEND ls_text TO lt_text.
    CLEAR ls_text.
*         Texte einlesen
    LOOP AT ls_texte-lines INTO ls_lines.
      MOVE ls_lines-tdline TO ls_text.
      APPEND ls_text TO lt_text.
      CLEAR ls_text.
    ENDLOOP.
    APPEND INITIAL LINE TO lt_text.
  ENDLOOP.

  CALL FUNCTION 'CATSXT_SIMPLE_TEXT_EDITOR'
    EXPORTING
      im_title        = 'DOKUMENTATION AUSBUCHUNG'
      im_display_mode = 'X'
*     IM_START_COLUMN = 10
*     IM_START_ROW    = 10
    CHANGING
      ch_text         = lt_text.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ucom_EDIT_DOCU
*&---------------------------------------------------------------------*
FORM ucom_edit_docu .

  DATA: lt_text     TYPE catsxt_longtext_itab,
        ls_text     TYPE txline,
        lt_head     TYPE TABLE OF thead,
        ls_head     TYPE thead,
        ls_line     TYPE tline,
        lt_line     TYPE TABLE OF tline,
        ls_stxh     TYPE stxh,
        lt_stxh     TYPE TABLE OF stxh,
        lv_lfdnr(3) TYPE n,
        lv_pattern  TYPE char30,
        lv_select   TYPE char30,
        lv_object   TYPE /adesso/inkasso_value,
        lv_id       TYPE /adesso/inkasso_value.
  DATA: lv_function(1).

  CLEAR gs_cust.
  READ TABLE gt_cust INTO gs_cust
       WITH KEY inkasso_option   = 'AUSBUCHUNG'
                inkasso_category = 'DOCU'
                inkasso_field    = 'TDOBJECT'.

  IF sy-subrc = 0.
    MOVE gs_cust-inkasso_value TO lv_object.
  ELSE.
    EXIT.
  ENDIF.

  CLEAR gs_cust.
  READ TABLE gt_cust INTO gs_cust
       WITH KEY inkasso_option   = 'AUSBUCHUNG'
                inkasso_category = 'DOCU'
                inkasso_field    = 'TDID'.

  IF sy-subrc = 0.
    MOVE gs_cust-inkasso_value TO lv_id.
  ELSE.
    EXIT.
  ENDIF.

  CALL FUNCTION 'J_1BNFE_EDITOR_CALL'
    EXPORTING
      iv_titel       = 'Dokumentation Ausbuchung'
*     IV_MAX_NUMBER_CHARS       =
*     IV_DISPLAY     = ' '
    TABLES
      ct_textlines   = lt_text
    EXCEPTIONS
      user_cancelled = 1
      OTHERS         = 2.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.


  LOOP AT lt_text INTO ls_text.
    MOVE ls_text TO ls_line-tdline.
    APPEND ls_line TO lt_line.
  ENDLOOP.

  CONCATENATE s_header-gpart '_'
              s_header-vkont '_'
              INTO  lv_pattern.

  CONCATENATE lv_pattern '%' INTO lv_select.

  CLEAR lt_stxh.
  SELECT * FROM stxh INTO TABLE lt_stxh
           WHERE tdobject = lv_object
           AND tdname LIKE lv_select
           AND tdid = lv_id
           AND tdspras = sy-langu.

  SORT lt_stxh BY tdname DESCENDING.
  READ TABLE lt_stxh INTO ls_stxh INDEX 1.
  IF sy-subrc = 0.
    lv_lfdnr = ls_stxh-tdname+24(3).
    ADD 1 TO lv_lfdnr.
    CONCATENATE lv_pattern lv_lfdnr INTO ls_head-tdname.
  ELSE.
    CONCATENATE lv_pattern '001' INTO ls_head-tdname.
  ENDIF.

  ls_head-tdobject = lv_object.
  ls_head-tdid   = lv_id.
  ls_head-tdspras = sy-langu.

  CALL FUNCTION 'SAVE_TEXT'
    EXPORTING
      client   = sy-mandt
      header   = ls_head
    IMPORTING
      function = lv_function
    TABLES
      lines    = lt_line
    EXCEPTIONS
      id       = 1
      language = 2
      name     = 3
      object   = 4
      OTHERS   = 5.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  IF lv_function = c_mode_ins.
    s_header-ic_docu(3) = '@6X'.
*    PERFORM set_status_icon
*            USING 'DOCU'
*                  s_header-ic_docu.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_KEYINFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GS_KEYINFO  text
*----------------------------------------------------------------------*
FORM set_keyinfo  CHANGING ls_keyinfo TYPE slis_keyinfo_alv.

*  ls_keyinfo-item01 = 'APPLK'.
  ls_keyinfo-item01 = 'GPART'.
  ls_keyinfo-item02 = 'VKONT'.

*  ls_keyinfo-header01 = 'APPLK'.
  ls_keyinfo-header01 = 'GPART'.
  ls_keyinfo-header02 = 'VKONT'.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_FIELDCAT_HEADER  text
*----------------------------------------------------------------------*
FORM fieldcat_header  USING lt_fieldcat TYPE slis_t_fieldcat_alv.

  DATA: ls_fieldcat TYPE slis_fieldcat_alv.
  DATA: lv_struct   TYPE dd02l-tabname.

  lv_struct = '/ADESSO/INKASSO_HEADER'.

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

    ls_fieldcat-tabname = 'T_HEADER'.

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

** Vertragskonto
      WHEN 'VKONT'.
        ls_fieldcat-hotspot = 'X'.

** Mahnsperre
      WHEN 'LOCKR'.
        ls_fieldcat-seltext_s = 'Mahnsp.'.
        ls_fieldcat-seltext_m = 'Mahnsperre'.
        ls_fieldcat-seltext_l = 'Mahnsperre'.

** Status: Kunde für Abgebe gesperrt
      WHEN 'LOCKED'.
        ls_fieldcat-icon        = 'X'.
        ls_fieldcat-seltext_s   = 'Gesperrt'.
        ls_fieldcat-seltext_m   = 'Gesperrt'.
        ls_fieldcat-seltext_l   = 'Gesperrt'.

** Verjahrungsfrist beachten
      WHEN 'VJFRIST'.
        ls_fieldcat-icon      = 'X'.
        ls_fieldcat-seltext_s = 'Frist VJ'.
        ls_fieldcat-seltext_m = 'Frist Verjä.'.
        ls_fieldcat-seltext_l = 'Frist Verjährung'.


** Inkassobüro
      WHEN 'INKGP'.
        ls_fieldcat-hotspot = 'X'.

** Inkassobüro-Name
      WHEN 'INKNAME'.
        ls_fieldcat-seltext_s = 'NameInkGP'.
        ls_fieldcat-seltext_m = 'Name Inkassobüro'.
        ls_fieldcat-seltext_l = 'Name Inkassobüro'.
        ls_fieldcat-outputlen = 20.

** Betrag
      WHEN 'BETRW'.
        ls_fieldcat-do_sum = 'X'.

** Storno SR
      WHEN 'SSR'.
        ls_fieldcat-tech = 'X'.

** Storno SR
      WHEN 'SATZTYP'.
        ls_fieldcat-tech = 'X'.

** Nebenforderung größer Hauptforderung
      WHEN 'NFHF'.
        ls_fieldcat-icon        = 'X'.
        ls_fieldcat-seltext_s   = 'NF > HF'.
        ls_fieldcat-seltext_m   = 'NF > HF'.
        ls_fieldcat-seltext_l   = 'NF > HF'.

** Freitext
      WHEN 'FREETEXT' OR 'UNBVERZ' OR 'MINDERJ' OR 'ERBENHAFT' OR 'BETREUUNG'  OR 'INSOLVENZ'.
        ls_fieldcat-hotspot = 'X'.
*        ls_fieldcat-tabname = 'T_HEADER'.
*        ls_fieldcat-seltext_s = 'Freitext'.
*        ls_fieldcat-seltext_m = 'Freitext'.
*        ls_fieldcat-seltext_m = 'Freitext'.

** Status Information vom InkGP
      WHEN 'INFODAT'.
        ls_fieldcat-hotspot = 'X'.

      WHEN 'INFOSTA'.
        ls_fieldcat-icon        = 'X'.
        ls_fieldcat-hotspot = 'X'.
        ls_fieldcat-seltext_s = 'Inf/Ank'.
        ls_fieldcat-seltext_m = 'Stat Inf/Ank'.
        ls_fieldcat-seltext_l = 'Stat Info/Ankauf'.

** interner Vermerk
      WHEN 'INTVERM'.
        ls_fieldcat-seltext_s = 'int. Verm'.
        ls_fieldcat-seltext_m = 'int. Verm'.
        ls_fieldcat-seltext_l = 'interner Vermerk'.
        ls_fieldcat-hotspot = 'X'.
        ls_fieldcat-outputlen = 20.

** interner Vermerk
      WHEN 'IC_DOCU'.
        ls_fieldcat-seltext_s = 'Doku Ausb'.
        ls_fieldcat-seltext_m = 'Doku Ausb'.
        ls_fieldcat-seltext_l = 'Doku Ausb'.
        ls_fieldcat-hotspot = 'X'.

** Sachbearbeiter
      WHEN 'SACHB'.
        ls_fieldcat-seltext_s = 'Sachb'.
        ls_fieldcat-seltext_m = 'Sachb'.
        ls_fieldcat-seltext_l = 'Sachbearbeiter'.

    ENDCASE.

    MODIFY lt_fieldcat FROM ls_fieldcat.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_ITEMS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_FIELDCAT_ITEMS  text
*----------------------------------------------------------------------*
FORM fieldcat_items  USING   lt_fieldcat TYPE slis_t_fieldcat_alv.

  DATA: ls_fieldcat TYPE slis_fieldcat_alv.
  DATA: lv_struct   TYPE dd02l-tabname.

  lv_struct = '/ADESSO/INKASSO_ITEMS'.

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

    ls_fieldcat-tabname = 'T_ITEMS'.

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

* Geschäftspartnernummer
      WHEN 'GPART'.
        ls_fieldcat-hotspot = 'X'.
*
* Vertragskonto
      WHEN 'VKONT'.
        ls_fieldcat-hotspot = 'X'.
*
* Beleg
      WHEN 'OPBEL'.
        ls_fieldcat-hotspot = 'X'.
*
* Betrag
      WHEN 'BETRW'.
        ls_fieldcat-do_sum = 'X'.
*
      WHEN 'AGSTATXT'.
        ls_fieldcat-seltext_s = 'TextStat'.
        ls_fieldcat-seltext_m = 'TextStat'.
        ls_fieldcat-seltext_l = 'TextStat'.
*
* Vertrag
      WHEN 'VTREF'.
        ls_fieldcat-hotspot = 'X'.
*
* Ausgleichsbeleg
      WHEN 'AUGBL'.
        ls_fieldcat-hotspot = 'X'.
*
* Ausgebucht
      WHEN'AUSGEB'.
        ls_fieldcat-seltext_s = 'ausgeb.'.
        ls_fieldcat-seltext_m = 'ausgeb.'.
        ls_fieldcat-seltext_l = 'ausgebucht'.
*
* Schlussabgerechnet
      WHEN 'BILLFIN'.
        ls_fieldcat-seltext_s = 'fakt.'.
        ls_fieldcat-seltext_m = 'fakt.'.
        ls_fieldcat-seltext_l = 'fakturiert'.

* HF
      WHEN 'HF'.
        ls_fieldcat-tech = 'X'.

    ENDCASE.

    MODIFY lt_fieldcat FROM ls_fieldcat.

  ENDLOOP.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM USER_COMMAND                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*       --> R_UCOMM                                                   *
*       --> RS_SELFIELD                                               *
*---------------------------------------------------------------------*
FORM user_command_hier USING r_ucomm LIKE sy-ucomm
                             rs_selfield TYPE slis_selfield.

* Daten im ALV aktualisieren (wichtig für das Selektionsfeld)
  DATA: rev_alv TYPE REF TO cl_gui_alv_grid.

  DATA: iv_screen_no TYPE cicfwscreenno.
  DATA: wa_bdc    TYPE bdcdata,
        t_bdc     TYPE TABLE OF bdcdata,
        t_messtab TYPE TABLE OF bdcmsgcoll.

  DATA:  lv_tcode TYPE sy-tcode.
  DATA:  lv_subrc TYPE sy-subrc.
  DATA:  lv_text1 TYPE char40.

  DATA: lv_gpart  TYPE gpart_kk,
        lv_vkont  TYPE vkont_kk,
        lv_opbel  TYPE opbel_kk,
        lv_vtref  TYPE vtref_kk,
        lv_inkgp  TYPE inkgp_kk,
        lv_locked TYPE char35.

  FIELD-SYMBOLS: <wa_items>  TYPE /adesso/inkasso_items,
                 <wa_header> TYPE /adesso/inkasso_header.

* --> Nuss 05.2018
  DATA: ls_fieldcat TYPE slis_fieldcat_alv .
* <-- Nuss 05.2018

  DATA: ls_dfkkop TYPE dfkkop.         "Nuss 06.2018

  rs_selfield-refresh = 'X'.
  rs_selfield-col_stable = 'X'.
  rs_selfield-row_stable = 'X'.

  CLEAR wa_out.    "Nuss 04.2018
  CLEAR t_out.     "Nuss 06.2018

  CLEAR: s_items, s_header.
  IF rs_selfield-tabname = 'T_ITEMS'.
    READ TABLE t_items INTO s_items INDEX rs_selfield-tabindex.
  ELSEIF rs_selfield-tabname = 'T_HEADER'.
    READ TABLE t_header INTO s_header INDEX rs_selfield-tabindex.
  ENDIF.

  IF s_items IS NOT INITIAL.
    MOVE s_items-gpart TO lv_gpart.
    MOVE s_items-vkont TO lv_vkont.
    MOVE s_items-opbel TO lv_opbel.
    MOVE s_items-vtref TO lv_vtref.
  ENDIF.

  IF s_header IS NOT INITIAL.
    MOVE s_header-gpart TO lv_gpart.
    MOVE s_header-vkont TO lv_vkont.
    MOVE s_header-inkgp TO lv_inkgp.
  ENDIF.

  CASE r_ucomm.

    WHEN 'SETSTAT'.
*   Vormerken Inkasso

*   Prüfen Berechtigung für Funktion
      PERFORM check_auth_for_ucomm USING r_ucomm lv_subrc.
      IF lv_subrc NE 0.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            titel     = TEXT-err
            textline1 = TEXT-f01
            textline2 = TEXT-e03.
        RETURN.
      ENDIF.

      PERFORM ucom_set_status_hier USING r_ucomm gv_gplocked.

*   Wenn VK gesperrt (z.B. Mahnsperre oder Bearbeitung durch anderen User) Meldung
      IF gv_gplocked = 'X'.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            titel     = TEXT-inf
            textline1 = TEXT-e05
            textline2 = TEXT-e06.
      ENDIF.

    WHEN 'DELSTAT'.
*   Rücknahme Vormerken Inkasso

*   Prüfen Berechtigung für Funktion
      PERFORM check_auth_for_ucomm USING r_ucomm lv_subrc.
      IF lv_subrc NE 0.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            titel     = TEXT-err
            textline1 = TEXT-f02
            textline2 = TEXT-e03.
        RETURN.
      ENDIF.

      PERFORM ucom_delete_status_hier  USING r_ucomm gv_gplocked.

*   Wenn VK gesperrt (z.B. Mahnsperre oder Bearbeitung durch anderen User) Meldung
      IF gv_gplocked = 'X'.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            titel     = TEXT-inf
            textline1 = TEXT-e05
            textline2 = TEXT-e06.
      ENDIF.

    WHEN 'NEWLOOK'.
*   Erneut Prüfen

*   Prüfen Berechtigung für Funktion
      PERFORM check_auth_for_ucomm USING r_ucomm lv_subrc.
      IF lv_subrc NE 0.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            titel     = TEXT-err
            textline1 = TEXT-f03
            textline2 = TEXT-e03.
        RETURN.
      ENDIF.

      PERFORM ucom_set_newlook_hier  USING r_ucomm gv_gplocked.

*   Wenn VK gesperrt (z.B. Mahnsperre oder Bearbeitung durch anderen User) Meldung
      IF gv_gplocked = 'X'.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            titel     = TEXT-inf
            textline1 = TEXT-e05
            textline2 = TEXT-e06.
      ENDIF.

    WHEN 'CHECKED'.
*   Geprüft

*   Prüfen Berechtigung für Funktion
      PERFORM check_auth_for_ucomm USING r_ucomm lv_subrc.
      IF lv_subrc NE 0.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            titel     = TEXT-err
            textline1 = TEXT-f04
            textline2 = TEXT-e03.
        RETURN.
      ENDIF.

      PERFORM ucom_set_checked_hier USING r_ucomm gv_gplocked.

*   Wenn VK gesperrt (z.B. Mahnsperre oder Bearbeitung durch anderen User) Meldung
      IF gv_gplocked = 'X'.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            titel     = TEXT-inf
            textline1 = TEXT-e05
            textline2 = TEXT-e06.
      ENDIF.

    WHEN 'RELE'.
*   Freigabe Inkasso

*   Prüfen Berechtigung für Funktion
      PERFORM check_auth_for_ucomm USING r_ucomm lv_subrc.
      IF lv_subrc NE 0.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            titel     = TEXT-err
            textline1 = TEXT-f05
            textline2 = TEXT-e03.
        RETURN.
      ENDIF.

      PERFORM ucom_freigabe_hier  USING r_ucomm gv_gplocked.

*   Wenn VK gesperrt (z.B. Mahnsperre oder Bearbeitung durch anderen User) Meldung
      IF gv_gplocked = 'X'.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            titel     = TEXT-inf
            textline1 = TEXT-e05
            textline2 = TEXT-e06.
      ENDIF.

    WHEN 'UNDO'.
*   Rücknahme Freigabe Inkasso

*   Prüfen Berechtigung für Funktion
      PERFORM check_auth_for_ucomm USING r_ucomm lv_subrc.
      IF lv_subrc NE 0.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            titel     = TEXT-err
            textline1 = TEXT-f06
            textline2 = TEXT-e03.
        RETURN.
      ENDIF.

      PERFORM ucom_freigabe_ruecknahme_hier  USING r_ucomm gv_gplocked.

*   Wenn VK gesperrt (z.B. Mahnsperre oder Bearbeitung durch anderen User) Meldung
      IF gv_gplocked = 'X'.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            titel     = TEXT-inf
            textline1 = TEXT-e05
            textline2 = TEXT-e06.
      ENDIF.


    WHEN 'ABGABE'.
*   Inkasso Abgabe

*   Prüfen Berechtigung für Funktion
      PERFORM check_auth_for_ucomm USING r_ucomm lv_subrc.
      IF lv_subrc NE 0.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            titel     = TEXT-err
            textline1 = TEXT-f07
            textline2 = TEXT-e03.
        RETURN.
      ENDIF.

      PERFORM ucom_abgabe_hier  USING r_ucomm gv_gplocked.

*   Wenn VK gesperrt (z.B. Mahnsperre oder Bearbeitung durch anderen User) Meldung
      IF gv_gplocked = 'X'.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            titel     = TEXT-inf
            textline1 = TEXT-e05
            textline2 = TEXT-e06.
      ENDIF.

    WHEN 'RECALL'.
*   Rückruf Posten

*   Prüfen Berechtigung für Funktion
      PERFORM check_auth_for_ucomm USING r_ucomm lv_subrc.
      IF lv_subrc NE 0.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            titel     = TEXT-err
            textline1 = TEXT-f09
            textline2 = TEXT-e03.
        RETURN.
      ENDIF.

      READ TABLE t_items INTO s_items
           WITH KEY sel = 'X'.
      IF sy-subrc NE 0.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            titel     = TEXT-err
            textline1 = TEXT-f09
            textline2 = TEXT-e23.
        RETURN.
      ENDIF.

      PERFORM ucom_recall_hier USING r_ucomm gv_gplocked.

*   Wenn VK gesperrt (z.B. Mahnsperre oder Bearbeitung durch anderen User) Meldung
      IF gv_gplocked = 'X'.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            titel     = TEXT-inf
            textline1 = TEXT-e05
            textline2 = TEXT-e06.
      ENDIF.

    WHEN 'CHGINK'.
*   Inkasso-Büro ändern

*   Prüfen Berechtigung für Funktion
      PERFORM check_auth_for_ucomm USING r_ucomm lv_subrc.
      IF lv_subrc NE 0.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            titel     = TEXT-err
            textline1 = TEXT-f08
            textline2 = TEXT-e03.
        RETURN.
      ENDIF.

      PERFORM ucom_change_inkgp_hier USING r_ucomm gv_gplocked.

*   Wenn VK gesperrt (z.B. Mahnsperre oder Bearbeitung durch anderen User) Meldung
      IF gv_gplocked = 'X'.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            titel     = TEXT-inf
            textline1 = TEXT-e05
            textline2 = TEXT-e06.
      ENDIF.

    WHEN 'SELL'.
*   Verkauf Forderung
      PERFORM check_auth_for_ucomm USING r_ucomm lv_subrc.

      IF lv_subrc NE 0.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            titel     = TEXT-err
            textline1 = TEXT-f12
            textline2 = TEXT-e03.
        RETURN.
      ENDIF.

      PERFORM ucom_sell_hier USING r_ucomm gv_gplocked.

*   Wenn VK gesperrt (z.B. Mahnsperre oder Bearbeitung durch anderen User) Meldung
      IF gv_gplocked = 'X'.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            titel     = TEXT-inf
            textline1 = TEXT-e05
            textline2 = TEXT-e06.
      ENDIF.

    WHEN 'SELL_DECL'.
*   Ablehnung Verkauf Forderung
      PERFORM check_auth_for_ucomm USING r_ucomm lv_subrc.
      IF lv_subrc NE 0.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            titel     = TEXT-err
            textline1 = TEXT-f11
            textline2 = TEXT-e03.
        RETURN.
      ENDIF.

      PERFORM ucom_sell_decl_hier USING r_ucomm gv_gplocked.

*   Wenn VK gesperrt (z.B. Mahnsperre oder Bearbeitung durch anderen User) Meldung
      IF gv_gplocked = 'X'.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            titel     = TEXT-inf
            textline1 = TEXT-e05
            textline2 = TEXT-e06.
      ENDIF.

    WHEN 'WROFF'.
*   Ausbuchung
      PERFORM check_auth_for_ucomm USING r_ucomm lv_subrc.
      IF lv_subrc NE 0.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            titel     = TEXT-err
            textline1 = TEXT-f10
            textline2 = TEXT-e03.
        RETURN.
      ENDIF.

      PERFORM ucom_wroff_hier USING r_ucomm gv_gplocked.

*   Wenn VK gesperrt (z.B. Mahnsperre oder Bearbeitung durch anderen User) Meldung
      IF gv_gplocked = 'X'.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            titel     = TEXT-inf
            textline1 = TEXT-e05
            textline2 = TEXT-e06.
      ENDIF.

    WHEN 'APPROVE'.
*   Genehmigung Ausbuchung / Verkauf
      PERFORM check_auth_for_ucomm USING r_ucomm lv_subrc.
      IF lv_subrc NE 0.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            titel     = TEXT-err
            textline1 = TEXT-f13
            textline2 = TEXT-e03.
        RETURN.
      ENDIF.

      PERFORM ucom_approve_hier USING r_ucomm gv_gplocked.

*   Wenn VK gesperrt (z.B. Mahnsperre oder Bearbeitung durch anderen User) Meldung
      IF gv_gplocked = 'X'.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            titel     = TEXT-inf
            textline1 = TEXT-e05
            textline2 = TEXT-e06.
      ENDIF.

    WHEN 'REVOKE'.
*   Rücknahme Genehmigung Ausbuchung / Verkauf
      PERFORM check_auth_for_ucomm USING r_ucomm lv_subrc.
      IF lv_subrc NE 0.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            titel     = TEXT-err
            textline1 = TEXT-f14
            textline2 = TEXT-e03.
        RETURN.
      ENDIF.

      PERFORM ucom_revoke_hier USING r_ucomm gv_gplocked.

*   Wenn VK gesperrt (z.B. Mahnsperre oder Bearbeitung durch anderen User) Meldung
      IF gv_gplocked = 'X'.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            titel     = TEXT-inf
            textline1 = TEXT-e05
            textline2 = TEXT-e06.
      ENDIF.

    WHEN 'FINISHED'.
*   Vorgang erledigt / rauschmeißen

*   Prüfen Berechtigung für Funktion
      PERFORM check_auth_for_ucomm USING r_ucomm lv_subrc.
      IF lv_subrc NE 0.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            titel     = TEXT-err
            textline1 = TEXT-f15
            textline2 = TEXT-e03.
        RETURN.
      ENDIF.

      READ TABLE t_items INTO s_items
           WITH KEY sel = 'X'.
      IF sy-subrc NE 0.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            titel     = TEXT-err
            textline1 = TEXT-f15
            textline2 = TEXT-e23.
        RETURN.
      ENDIF.

      PERFORM ucom_finished_hier  USING r_ucomm gv_gplocked.

*   Wenn VK gesperrt (z.B. Mahnsperre oder Bearbeitung durch anderen User) Meldung
      IF gv_gplocked = 'X'.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            titel     = TEXT-inf
            textline1 = TEXT-e05
            textline2 = TEXT-e06.
      ENDIF.


    WHEN 'BALANCE'.

      LOOP AT t_header INTO s_header WHERE sel IS NOT INITIAL.

        PERFORM ucom_get_kontenstand.

        EXIT.

      ENDLOOP.
      IF sy-subrc NE 0.
        MESSAGE e002.
      ENDIF.

    WHEN 'CIC'.


      LOOP AT t_header INTO s_header WHERE sel IS NOT INITIAL.

        PERFORM ucom_get_cic USING s_header-vkont.

        EXIT.

      ENDLOOP.

      IF sy-subrc NE 0.
        MESSAGE e002.
      ENDIF.

    WHEN 'INFOINKGP'.

      REFRESH: gt_vkont.
      LOOP AT t_header INTO s_header WHERE sel IS NOT INITIAL.
        gs_vkont-option = 'EQ'.
        gs_vkont-sign   = 'I'.
        gs_vkont-low    = s_header-vkont.
        APPEND gs_vkont TO gt_vkont.
      ENDLOOP.

      PERFORM ucom_info_inkgp TABLES gt_vkont.

    WHEN 'INTVERM'.

      LOOP AT t_header INTO s_header WHERE sel IS NOT INITIAL.

        PERFORM ucom_edit_intverm.

        EXIT.

      ENDLOOP.

    WHEN 'DOCU'.

      LOOP AT t_header INTO s_header WHERE sel IS NOT INITIAL.

        PERFORM ucom_edit_docu.
        MODIFY t_header FROM s_header TRANSPORTING ic_docu.

        EXIT.

      ENDLOOP.

    WHEN 'HISTORY'.

      PERFORM ucom_history.

    WHEN 'STORNO'.

      PERFORM ucom_storno_hier.


    WHEN 'REFRESH'.

      PERFORM ucom_refresh_hier.

    WHEN 'XLS_HEAD'.

      PERFORM ucom_downl_xls_hier
              TABLES t_header
                     t_items
                     gt_fieldcat_header
                     gt_fieldcat_items
              USING r_ucomm.

    WHEN 'XLS_ITEM'.

      PERFORM ucom_downl_xls_hier
              TABLES t_header
                     t_items
                     gt_fieldcat_header
                     gt_fieldcat_items
              USING r_ucomm.


    WHEN 'MARK'.

      PERFORM ucom_mark_hier.

    WHEN 'DEMARK'.

      PERFORM ucom_demark_hier.

    WHEN 'MARKALL'.

      LOOP AT t_items ASSIGNING <wa_items>.
        <wa_items>-sel = 'X'.
      ENDLOOP.

      LOOP AT t_header ASSIGNING <wa_header>.
        <wa_header>-sel = 'X'.
      ENDLOOP.

    WHEN 'DMALL'.

      LOOP AT t_items ASSIGNING <wa_items>.
        <wa_items>-sel = ' '.
      ENDLOOP.

      LOOP AT t_header ASSIGNING <wa_header>.
        <wa_header>-sel = ' '.
      ENDLOOP.

    WHEN 'BACKU' OR 'EXIT' OR 'CANCEL'.

      IF sy-subrc = 0.
      ENDIF.
      LEAVE TO SCREEN 0.

    WHEN OTHERS.
*
      CASE rs_selfield-fieldname.

        WHEN 'GPART'.
          IF lv_gpart IS NOT INITIAL.
            SET PARAMETER ID 'BPA'  FIELD lv_gpart.
            CALL TRANSACTION 'FPP3'.
          ENDIF.

        WHEN 'VKONT'.
          GET CURSOR LINE sy-tabix.
          PERFORM view_vkont USING  lv_vkont
                                    lv_gpart.
        WHEN 'OPBEL'.
          IF lv_opbel IS NOT INITIAL.
            SET PARAMETER ID '80B' FIELD  lv_opbel.
            CALL TRANSACTION 'FPE3' AND SKIP FIRST SCREEN.
          ENDIF.

        WHEN 'INKGP'.
          IF lv_inkgp IS NOT INITIAL.
            SET PARAMETER ID 'BPA' FIELD  lv_inkgp.
            CALL TRANSACTION 'FPP3'.
          ENDIF.

        WHEN 'VTREF'.
          DATA: lv_applk TYPE applk_kk.
          CALL FUNCTION 'FKK_GET_APPLICATION'
            IMPORTING
              e_applk       = lv_applk
            EXCEPTIONS
              error_message = 1.
          "call event 1201 -> display contract object
          PERFORM event_1201(saplfkk_sec) USING lv_applk
                                                 lv_vtref.

        WHEN 'INTVERM'.

          IF rs_selfield-tabname = 'T_HEADER'.
            READ TABLE t_header INTO s_header INDEX rs_selfield-tabindex.
          ENDIF.

          PERFORM display_intverm.

        WHEN 'IC_DOCU'.

          IF rs_selfield-tabname = 'T_HEADER'.
            READ TABLE t_header INTO s_header INDEX rs_selfield-tabindex.
          ENDIF.

          PERFORM display_docu.

        WHEN 'FREETEXT' OR 'UNBVERZ' OR 'MINDERJ' OR 'ERBENHAFT' OR 'BETREUUNG'  OR 'INSOLVENZ'.
          READ TABLE t_header INTO s_header INDEX rs_selfield-tabindex.
          PERFORM ucom_add_info_hier.
          MODIFY t_header INDEX rs_selfield-tabindex FROM s_header.

        WHEN 'INFODAT' OR 'INFOSTA'.
          READ TABLE t_header INTO s_header INDEX rs_selfield-tabindex.
          REFRESH: gt_vkont.
          gs_vkont-option = 'EQ'.
          gs_vkont-sign   = 'I'.
          gs_vkont-low    = s_header-vkont.
          APPEND gs_vkont TO gt_vkont.

          PERFORM ucom_info_inkgp TABLES gt_vkont.

      ENDCASE.
*
  ENDCASE.

  CLEAR r_ucomm.

ENDFORM.                    "user_command_hier

*&---------------------------------------------------------------------*
*&      Form  UCOM_ABGABE_HIER
*&---------------------------------------------------------------------*
FORM ucom_abgabe_hier  USING ff_ucomm LIKE sy-ucomm
                             ff_gplocked LIKE gv_gplocked.

  DATA: ls_dfkkcoll TYPE dfkkcoll.
  DATA: ls_dfkkcollh TYPE dfkkcollh.
  DATA: ls_tfk050at TYPE tfk050at.
  DATA: lv_tabix LIKE sy-tabix.
  DATA: lf_nochange TYPE sy-tabix.
  DATA: lf_no_inkgp TYPE sy-tabix.
  DATA: ls_header TYPE /adesso/inkasso_header.
  DATA: ls_items  TYPE /adesso/inkasso_items.
  DATA: lf_agstatxt TYPE val_text.
  DATA: lf_inkgp TYPE inkgp_kk.
  DATA: lf_inkname TYPE bu_descrip.
  DATA: lf_error.
  DATA: lf_hf.

  DATA: rspar_tab    TYPE TABLE OF rsparams.
  DATA: rspar_items  TYPE TABLE OF rsparams.
  DATA: rspar_line   LIKE LINE OF rspar_tab.
  DATA: lf_subrc  LIKE sy-subrc.
  DATA: lf_filen  TYPE fileintern.


  CLEAR:   lf_nochange.
  CLEAR:   ff_gplocked.
  CLEAR:   lf_no_inkgp.
  REFRESH: rspar_tab.

* Für Hierarchische Liste
  LOOP AT t_header INTO ls_header
       WHERE sel IS NOT INITIAL.

* VK für Bearbeitung gesperrt ?
    IF ls_header-locked IS NOT INITIAL.
      CONTINUE.
    ENDIF.

* kein INKGP gesetzt ?
    IF ls_header-inkgp IS INITIAL.
      CONTINUE.
    ENDIF.

* Berechtigung für Status ?
* Bei Storno SR, Prüfung auf Positionsebene
    IF ls_header-ssr = space.
      CLEAR gs_stat.
      READ TABLE gt_stat INTO gs_stat
           WITH KEY begru = gs_bgus-begru
                    ucomm = ff_ucomm
                    agsta = ls_header-agsta.

      IF sy-subrc NE 0.
        CONTINUE.
      ENDIF.
    ENDIF.

    REFRESH rspar_items.
    CLEAR lf_hf.
    LOOP AT t_items INTO ls_items
           WHERE gpart = ls_header-gpart
           AND   vkont = ls_header-vkont.

      CHECK ls_items-augdt IS INITIAL.

* Bei Storno SR, Prüfung auf Positionsebene
      IF ls_header-ssr = 'X'.
        CLEAR gs_stat.
        READ TABLE gt_stat INTO gs_stat
             WITH KEY begru = gs_bgus-begru
                      ucomm = ff_ucomm
                      agsta = ls_items-agsta.

        IF sy-subrc NE 0.
          CONTINUE.
        ENDIF.
      ENDIF.

      IF ls_items-hf = 'X'.
        lf_hf = 'X'.
      ENDIF.

*   Belegnummer
      rspar_line-selname = 'SELOPBEL_LOW'.
      rspar_line-kind = 'S'.
      rspar_line-sign = 'I'.
      rspar_line-option = 'EQ'.
      rspar_line-low = ls_items-opbel.
      APPEND rspar_line TO rspar_items.
      CLEAR rspar_line.

    ENDLOOP.

    IF rspar_items[] IS INITIAL.
      CLEAR ls_header-sel.
      PERFORM create_icon_text
              USING 'ICON_LED_RED' TEXT-e21
              CHANGING ls_header-status.
      MODIFY t_header FROM ls_header.
      CONTINUE.
    ENDIF.

    IF lf_hf = space.
      CLEAR ls_header-sel.
      PERFORM create_icon_text
              USING 'ICON_LED_RED' TEXT-e22
              CHANGING ls_header-status.
      MODIFY t_header FROM ls_header.
      CONTINUE.
    ENDIF.

    APPEND LINES OF rspar_items TO rspar_tab.

*   Vertragskontonummer
    CLEAR rspar_line.
    rspar_line-selname = 'SELVKONT_LOW'.
    rspar_line-kind = 'S'.
    rspar_line-sign = 'I'.
    rspar_line-option = 'EQ'.
    rspar_line-low = ls_header-vkont.
    APPEND rspar_line TO rspar_tab.

  ENDLOOP.

  SORT rspar_tab.
  DELETE ADJACENT DUPLICATES FROM rspar_tab.

  IF rspar_tab[] IS INITIAL.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-f07
        textline2 = TEXT-e16.
    EXIT.
  ENDIF.

  CLEAR lf_subrc.
  PERFORM create_job_abgabe TABLES rspar_tab
                            USING  lf_subrc
                                   lf_filen.

  IF lf_subrc NE 0.
    MESSAGE TEXT-e18 TYPE 'E'.
  ENDIF.

* Posten abgegeben ?
  CLEAR error.
  LOOP AT t_header INTO ls_header
       WHERE sel IS NOT INITIAL.

* VK für Bearbeitung gesperrt ?
    IF ls_header-locked IS NOT INITIAL.
      ff_gplocked = 'X'.
      CONTINUE.
    ENDIF.

* kein INKGP gesetzt ?
    IF ls_header-inkgp IS INITIAL.
      ADD 1 TO lf_no_inkgp.
      CONTINUE.
    ENDIF.

* Berechtigung für Status ?
    CLEAR gs_stat.
    READ TABLE gt_stat INTO gs_stat
         WITH KEY begru = gs_bgus-begru
                  ucomm = ff_ucomm
                  agsta = ls_header-agsta.

    IF sy-subrc NE 0.
      CLEAR gs_stat.
      ADD 1 TO lf_nochange.
      CONTINUE.
    ENDIF.

    CLEAR lf_error.
    LOOP AT t_items INTO ls_items
           WHERE gpart = ls_header-gpart
           AND   vkont = ls_header-vkont.

      CHECK ls_items-augdt IS INITIAL.

      SELECT SINGLE * FROM dfkkcoll
             INTO ls_dfkkcoll
             WHERE opbel = ls_items-opbel
             AND   inkps = ls_items-inkps
             AND   agsta = '02'.

      IF sy-subrc = 0.

        ls_items-agsta    = ls_dfkkcoll-agsta.
        ls_items-inkps    = ls_dfkkcoll-inkps.
        ls_items-aggrd    = ls_dfkkcoll-aggrd.
        ls_items-inkgp    = ls_dfkkcoll-inkgp.
        ls_items-agstatxt = TEXT-020.

*   ICON auf Abgegeben setzen
        PERFORM set_status_icon USING ls_items-agsta ls_items-status.

      ELSE.

        ADD 1 TO error.
        lf_error = 'X'.
        PERFORM create_icon_text
                USING 'ICON_LED_RED' TEXT-e08
                CHANGING ls_items-status.

      ENDIF.

* Jetzt noch Lauf ermitteln
      SELECT SINGLE laufd laufi FROM dfkkcolfile_p_w
          INTO  (ls_items-laufd, ls_items-laufi)
          WHERE laufd = sy-datum
          AND   opbel = ls_items-opbel
          AND   inkps = ls_items-inkps
          AND   inkgp = ls_items-inkgp.
      IF sy-subrc NE 0.
        CLEAR ls_items-laufd.
        CLEAR ls_items-laufi.
      ENDIF.

      MODIFY t_items FROM ls_items.

    ENDLOOP.

    IF lf_error = 'X'.
      PERFORM create_icon_text
              USING 'ICON_LED_RED' TEXT-e08
              CHANGING ls_items-status.
    ELSE.

      ls_header-laufd = ls_items-laufd.
      ls_header-laufi = ls_items-laufi.

      ls_header-agsta   = '02'.
      ls_header-agdat   = sy-datum.
*     ICON auf Abgegeben setzen
      PERFORM set_status_icon USING ls_header-agsta ls_header-status.

    ENDIF.

*    ls_header-filen = lf_filen.
    MODIFY t_header FROM ls_header.

  ENDLOOP.

  COMMIT WORK.

  IF lf_nochange > 0.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-f07
        textline2 = TEXT-e04.
  ENDIF.

  IF lf_no_inkgp > 0.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-f07
        textline2 = TEXT-e11.
  ENDIF.

  IF error > 0.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-f07
        textline2 = TEXT-e12.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UCOM_RECALL_HIER
*&---------------------------------------------------------------------*
FORM ucom_recall_hier  USING ff_ucomm LIKE sy-ucomm
                             ff_gplocked LIKE gv_gplocked.

  DATA: ls_header TYPE /adesso/inkasso_header.
  DATA: ls_items  TYPE /adesso/inkasso_items.
  DATA: lf_nochange TYPE sy-tabix.
  DATA: lf_nochg_stat TYPE sy-tabix.
  DATA: ls_tfk050at TYPE tfk050at.
  DATA: lv_tabix LIKE sy-tabix.
  DATA: lf_agstatxt TYPE val_text.
  DATA: lf_error.

  DATA: lt_fkkop    TYPE TABLE OF fkkop.
  DATA: ls_fkkop    TYPE fkkop.
  DATA: lt_recall   TYPE TABLE OF dfkkcoll.
  DATA: ls_recall   TYPE dfkkcoll.
  DATA: lt_fimsg    TYPE TABLE OF fimsg.
  DATA: lf_rudat    TYPE rudat_kk.
  DATA: lf_rugrd    TYPE deagr_kk.

  CLEAR:   lf_nochange.
  CLEAR:   lf_nochg_stat.
  CLEAR:   ff_gplocked.


* pop-up to enter recall date and recall reason
  CALL SCREEN 9001
     STARTING AT 21 2.

  IF okcode EQ 'CANC'.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-f09
        textline2 = TEXT-e24.
    EXIT.
  ELSE.
    lf_rudat = /adesso/inkasso_items-rudat.
    lf_rugrd = /adesso/inkasso_items-rugrd.
  ENDIF.
  CLEAR okcode.

* Für Hierarchische Liste
  LOOP AT t_header INTO ls_header
       WHERE sel IS NOT INITIAL.

    lv_tabix = sy-tabix.

* VK für Bearbeitung gesperrt ?
    IF ls_header-locked IS NOT INITIAL.
      ff_gplocked = 'X'.
      CONTINUE.
    ENDIF.

** Berechtigung für Status ?
*    CLEAR gs_stat.
*    READ TABLE gt_stat INTO gs_stat
*         WITH KEY begru = gs_bgus-begru
*                  ucomm = ff_ucomm
*                  agsta = ls_header-agsta.
*
*    IF sy-subrc NE 0.
*      CLEAR gs_stat.
*      ADD 1 TO lf_nochange.
*      CONTINUE.
*    ENDIF.
*
** Text und Icon zum neuen Status lesen
*    CLEAR ls_tfk050at.
*    SELECT SINGLE astxt FROM tfk050at
*      INTO lf_agstatxt
*           WHERE spras = sy-langu
*           AND agsta = gs_stat-set_agsta.
*    IF sy-subrc NE 0.
*      lf_agstatxt = TEXT-022.
*    ENDIF.

    REFRESH lt_fkkop.

    LOOP AT t_items INTO ls_items
         WHERE gpart = ls_header-gpart
         AND   vkont = ls_header-vkont
         AND   sel IS NOT INITIAL.

* Berechtigung für Status ?
      CLEAR gs_stat.
      READ TABLE gt_stat INTO gs_stat
           WITH KEY begru = gs_bgus-begru
                    ucomm = ff_ucomm
                    agsta = ls_items-agsta.

      IF sy-subrc NE 0.
        CLEAR gs_stat.
        ADD 1 TO lf_nochg_stat.
        CONTINUE.
      ENDIF.

      SELECT SINGLE * FROM dfkkop
       INTO CORRESPONDING FIELDS OF ls_fkkop
       WHERE opbel = ls_items-opbel
       AND   opupw = ls_items-opupw
       AND   opupk = ls_items-opupk
       AND   opupz = ls_items-opupz.
      APPEND ls_fkkop TO lt_fkkop.

    ENDLOOP.

    CHECK lt_fkkop[] IS NOT INITIAL.

    CALL FUNCTION '/ADESSO/INK_RECALL_COLL_AGENCY'
      EXPORTING
        i_xsimu  = ' '
        i_rudat  = lf_rudat
        i_rugrd  = lf_rugrd
        i_agsta  = const_agsta_recalled
      TABLES
        t_fkkop  = lt_fkkop
        t_fimsg  = lt_fimsg
        t_recall = lt_recall
      EXCEPTIONS
        error    = 1
        OTHERS   = 2.

    IF sy-subrc <> 0.

      LOOP AT t_items INTO ls_items
           WHERE gpart = ls_header-gpart
           AND   vkont = ls_header-vkont
           AND   sel   = 'X'.

        CALL FUNCTION 'ICON_CREATE'
          EXPORTING
            name                  = 'ICON_LED_RED'
            info                  = TEXT-err
          IMPORTING
            result                = ls_items-status
          EXCEPTIONS
            icon_not_found        = 1
            outputfield_too_short = 2
            OTHERS                = 3.

        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

        MODIFY t_items FROM ls_items.

      ENDLOOP.

      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_LED_RED'
          info                  = TEXT-err
        IMPORTING
          result                = ls_header-status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.

      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    ELSE.

*     Falls Ablehnung Verkauf --> Rückruf XSOLD zurücksetzen für gesamtes VK
      UPDATE dfkkcoll SET xsold = ' '
             WHERE gpart = ls_header-gpart
             AND   vkont = ls_header-vkont.

      COMMIT WORK.

      LOOP AT t_items INTO ls_items
           WHERE gpart = ls_header-gpart
           AND   vkont = ls_header-vkont
           AND   sel   = 'X'.

        ls_items-rudat = lf_rudat.
        ls_items-rugrd = lf_rugrd.

        ls_items-agsta    = gs_stat-set_agsta.
        ls_items-agstatxt = lf_agstatxt.

*        ICON auf Rückruf setzen
        PERFORM set_status_icon USING ls_items-agsta ls_items-status.
        MODIFY t_items FROM ls_items.

      ENDLOOP.

      ls_header-rudat = lf_rudat.
      ls_header-rugrd = lf_rugrd.

*   Status Header
      ls_header-agsta = gs_stat-set_agsta.

*   ICON auf Rückruf setzen
      PERFORM set_status_icon USING ls_header-agsta ls_header-status.
      MODIFY t_header FROM ls_header INDEX lv_tabix.

      PERFORM create_contact
              USING ls_header-gpart
                    ls_header-vkont
                    ls_header-inkgp
                    'RECALL'
                    ' '
                    lf_rugrd.
    ENDIF.

  ENDLOOP.

  IF lf_nochange > 0.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-f09
        textline2 = TEXT-e04.
  ENDIF.

  IF lf_nochg_stat > 0.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-f09
        textline2 = TEXT-e09.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UCOM_FREIGABE_HIER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ucom_freigabe_hier  USING  ff_ucomm LIKE sy-ucomm
                                ff_gplocked LIKE gv_gplocked.

  DATA: ls_dfkkcoll TYPE dfkkcoll.
  DATA: ls_tfk050at TYPE tfk050at.
  DATA: lv_tabix LIKE sy-tabix.
  DATA: lf_nochange TYPE sy-tabix.
  DATA: ls_header TYPE /adesso/inkasso_header.
  DATA: ls_items  TYPE /adesso/inkasso_items.
  DATA: lf_agstatxt TYPE val_text.
  DATA: lf_nochg_stat TYPE sy-tabix.

  DATA: itab_release LIKE TABLE OF fkkop WITH HEADER LINE.
  DATA: itab_release_not_submitted LIKE TABLE OF fkkop.
  DATA: ht_dfkkcoll LIKE TABLE OF dfkkcoll WITH HEADER LINE.
  DATA: dt_dfkkcoll LIKE TABLE OF dfkkcoll WITH HEADER LINE.
  DATA: h_tfill LIKE sy-tfill.
  DATA: mode_delete   VALUE 'D'.

  CLEAR:   lf_nochange.
  CLEAR:   lf_nochg_stat.
  CLEAR:   ff_gplocked.

* Für Hierarchische Liste
  LOOP AT t_header INTO ls_header
       WHERE sel IS NOT INITIAL.

    lv_tabix = sy-tabix.

* VK für Bearbeitung gesperrt ?
    IF ls_header-locked IS NOT INITIAL.
      ff_gplocked = 'X'.
      CONTINUE.
    ENDIF.

* Berechtigung für Status ?
    CLEAR gs_stat.
    READ TABLE gt_stat INTO gs_stat
         WITH KEY begru = gs_bgus-begru
                  ucomm = ff_ucomm
                  agsta = ls_header-agsta.

    IF sy-subrc NE 0.
      CLEAR gs_stat.
      ADD 1 TO lf_nochange.
      CONTINUE.
    ENDIF.

* Text und Icon zum neuen Status lesen
    CLEAR ls_tfk050at.
    SELECT SINGLE astxt FROM tfk050at
      INTO lf_agstatxt
           WHERE spras = sy-langu
           AND agsta = gs_stat-set_agsta.
    IF sy-subrc NE 0.
      lf_agstatxt = TEXT-007.
    ENDIF.

* Prüfen, ob alle Posten zum VK freigegeben werden können und füllen itab_release
    REFRESH ht_enqtab.
    REFRESH itab_release.
    REFRESH ht_dfkkcoll.

    PERFORM build_release_tab_hier
            TABLES itab_release
            USING  ls_header-gpart
                   ls_header-vkont
                   ff_ucomm.

    IF itab_release[] IS INITIAL.
      ADD 1 TO lf_nochg_stat.
      CONTINUE.
    ENDIF.

*--Enqueue the business partner ---------------------------------------
    PERFORM dfkkop_enqueue.

* * init answer for popup for determination of collection agency
    CALL FUNCTION 'FKK_COLL_AG_SAMPLE_5060_INIT'.

* Posten zum VK freigeben
    CALL FUNCTION '/ADESSO/INK_REL_FOR_COLLAGENCY'
      EXPORTING
        i_aggrd               = const_aggrd_einzelabgabe
        i_xsimu               = ' '
        i_batch               = ' '
        i_inkgp               = ls_header-inkgp
      TABLES
        t_fkkop               = itab_release
        t_fkkop_not_submitted = itab_release_not_submitted
        t_dfkkcoll            = ht_dfkkcoll
      EXCEPTIONS
        error                 = 1
        OTHERS                = 2.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.
      DESCRIBE TABLE itab_release_not_submitted.
      IF sy-tfill > 0.
        h_tfill = sy-tfill.
        DESCRIBE TABLE itab_release.
        MESSAGE w453(>3) WITH h_tfill sy-tfill.
      ENDIF.

      LOOP AT t_items INTO ls_items
           WHERE gpart = ls_header-gpart
           AND   vkont = ls_header-vkont.

        CLEAR itab_release.
        READ TABLE itab_release
             WITH KEY opbel = ls_items-opbel
                      opupk = ls_items-opupk
                      opupw = ls_items-opupw
                      opupz = ls_items-opupz.

        CLEAR ht_dfkkcoll.
        READ TABLE ht_dfkkcoll
             WITH KEY opbel = itab_release-opbel
                      inkps = itab_release-inkps.

        IF sy-subrc = 0.
          ls_items-inkps = ht_dfkkcoll-inkps.
          ls_items-agsta = ht_dfkkcoll-agsta.
          ls_items-aggrd = ht_dfkkcoll-aggrd.
          ls_items-inkgp = ht_dfkkcoll-inkgp.
          ls_items-agstatxt = lf_agstatxt.
*        ICON auf Vorgemerkt setzen
          PERFORM set_status_icon USING ls_items-agsta ls_items-status.
        ELSE.
          IF ls_items-augdt IS INITIAL.
            CALL FUNCTION 'ICON_CREATE'
              EXPORTING
                name                  = 'ICON_LED_RED'
                info                  = TEXT-e08
              IMPORTING
                result                = ls_items-status
              EXCEPTIONS
                icon_not_found        = 1
                outputfield_too_short = 2
                OTHERS                = 3.

            IF sy-subrc <> 0.
              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.
          ENDIF.

        ENDIF.

        MODIFY t_items FROM ls_items.

      ENDLOOP.

      IF ht_dfkkcoll[] IS NOT INITIAL.

        REFRESH dt_dfkkcoll.

        SELECT * FROM dfkkcoll
          INTO TABLE dt_dfkkcoll
          FOR ALL ENTRIES IN ht_dfkkcoll
          WHERE opbel = ht_dfkkcoll-opbel
          AND   inkps = '000'
          AND   agsta BETWEEN '97' AND '99'.

        CALL FUNCTION 'FKK_DB_DFKKCOLL_MODE'
          EXPORTING
            i_mode    = mode_delete
          TABLES
            t_fkkcoll = dt_dfkkcoll
          EXCEPTIONS
            error     = 1
            OTHERS    = 2.

        IF sy-subrc <> 0.
          MESSAGE e845(>3) WITH 'DFKKCOLL'.
        ENDIF.

      ENDIF.

      COMMIT WORK.

    ENDIF.

**  * --- Dequeue all business partner ------------------------------------
    CALL FUNCTION 'FKK_OPEN_ITEM_DEQUEUE'.

*   Status Header
    ls_header-agsta = gs_stat-set_agsta.

*   ICON auf Vorgemerkt setzen
    PERFORM set_status_icon USING ls_header-agsta ls_header-status.
    MODIFY t_header FROM ls_header INDEX lv_tabix.

  ENDLOOP.

  IF lf_nochange > 0.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-f05
        textline2 = TEXT-e04.
  ENDIF.

  IF lf_nochg_stat > 0.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-f05
        textline2 = TEXT-e09.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  BUILD_RELEASE_TAB_HIER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITAB_RELEASE  text
*----------------------------------------------------------------------*
FORM build_release_tab_hier  TABLES   et_itab_release STRUCTURE fkkop
                             USING    ff_gpart TYPE gpart_kk
                                      ff_vkont TYPE vkont_kk
                                      ff_ucomm LIKE sy-ucomm.

  DATA: ht_fkkcoll TYPE TABLE OF dfkkcoll WITH HEADER LINE,
        wt_fkkop   LIKE fkkop OCCURS 0 WITH HEADER LINE.

  CLEAR: ht_enqtab.
  REFRESH et_itab_release.
  REFRESH pos_itab_marked.

** Für Hierarchische Liste
  LOOP AT t_items INTO s_items
       WHERE gpart = ff_gpart
       AND   vkont = ff_vkont.

    CHECK s_items-augdt IS INITIAL.

    CLEAR pos_itab.
    MOVE-CORRESPONDING s_items TO pos_itab.
    APPEND pos_itab TO pos_itab_marked.

  ENDLOOP.

  LOOP AT pos_itab_marked.

    IF pos_itab_marked-inkps = '999'.
*     FKKOP-INKPS = 999 shows that items is in collection case
      REFRESH et_itab_release.
      EXIT.
    ENDIF.

*   Normal case: any value for INKPS
    CALL FUNCTION 'FKK_COLLECT_AGENCY_ITEM_SELECT'
      EXPORTING
        i_opbel        = pos_itab_marked-opbel
        ix_opbel       = 'X' "const_marked
        i_inkps        = pos_itab_marked-inkps
        ix_inkps       = 'X' "const_marked
      TABLES
        t_fkkcoll      = ht_fkkcoll
      EXCEPTIONS
        initial_values = 1
        not_found      = 2
        OTHERS         = 3.

*Der Posten muss mindestens Vorgemerkt sein und steht daher in der DFKKCOLL
    IF sy-subrc NE 0.
      REFRESH et_itab_release.
      EXIT.
    ENDIF.

    READ TABLE ht_fkkcoll INDEX 1.

*     Erlaubter status ?
    CLEAR gs_stat.
    READ TABLE gt_stat INTO gs_stat
         WITH KEY begru = gs_bgus-begru
                  ucomm = ff_ucomm
                  agsta = ht_fkkcoll-agsta.

    IF sy-subrc NE 0.
      REFRESH et_itab_release.
      EXIT.
    ENDIF.

    CLEAR et_itab_release.
    CALL FUNCTION 'FKK_BP_LINE_ITEM_SELECT_SINGLE'
      EXPORTING
        i_opbel = pos_itab_marked-opbel
        i_opupw = pos_itab_marked-opupw
        i_opupk = pos_itab_marked-opupk
        i_opupz = pos_itab_marked-opupz
      IMPORTING
        e_fkkop = et_itab_release.

    IF et_itab_release IS INITIAL AND
       pos_itab_marked-opupw NE '000'.
* select repetition positions
      CALL FUNCTION 'FKK_BP_LINE_ITEMS_SEL_LOGICAL'
        EXPORTING
          i_opbel     = pos_itab_marked-opbel
        TABLES
          pt_logfkkop = wt_fkkop.

      READ TABLE wt_fkkop INTO et_itab_release WITH KEY
                                  opbel = pos_itab_marked-opbel
                                  opupw = pos_itab_marked-opupw
                                  opupk = pos_itab_marked-opupk
                                  opupz = pos_itab_marked-opupz.
      REFRESH wt_fkkop.
    ENDIF.

    IF NOT et_itab_release IS INITIAL.

      APPEND et_itab_release.

      READ TABLE ht_enqtab WITH KEY gpart = et_itab_release-gpart.
      IF sy-subrc NE 0.
        ht_enqtab-gpart = et_itab_release-gpart.
        APPEND ht_enqtab.
      ENDIF.
    ENDIF.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UCOM_FREIGABE_RUECKNAHME_HIER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ucom_freigabe_ruecknahme_hier  USING ff_ucomm LIKE sy-ucomm
                                          ff_gplocked LIKE gv_gplocked.

  DATA: ls_dfkkcoll TYPE dfkkcoll.
  DATA: ls_tfk050at TYPE tfk050at.
  DATA: lh_tabix LIKE sy-tabix.
  DATA: li_tabix LIKE sy-tabix.
  DATA: lf_nochange TYPE sy-tabix.
  DATA: ls_header TYPE /adesso/inkasso_header.
  DATA: ls_items  TYPE /adesso/inkasso_items.
  DATA: lf_agstatxt TYPE val_text.
  DATA: lf_nochg_stat TYPE sy-tabix.

  DATA: itab_dfkkcoll LIKE TABLE OF dfkkcoll WITH HEADER LINE.
  DATA: istr_dfkkcoll   TYPE dfkkcoll.
  DATA: itab_undo     TYPE TABLE OF /adesso/inkasso_items WITH HEADER LINE.
  DATA: lf_agsta      LIKE dfkkcoll-agsta.
  DATA: lf_agdat      LIKE dfkkcoll-agdat.
  DATA: mode_delete   VALUE 'D'.

  CLEAR:   lf_nochange.
  CLEAR:   lf_nochg_stat.
  CLEAR:   ff_gplocked.

* Für Hierarchische Liste
  LOOP AT t_header INTO ls_header
       WHERE sel IS NOT INITIAL.

    lh_tabix = sy-tabix.

* VK für Bearbeitung gesperrt ?
    IF ls_header-locked IS NOT INITIAL.
      ff_gplocked = 'X'.
      CONTINUE.
    ENDIF.

** Berechtigung für Status ?
*    CLEAR gs_stat.
*    READ TABLE gt_stat INTO gs_stat
*         WITH KEY begru = gs_bgus-begru
*                  ucomm = ff_ucomm
*                  agsta = ls_header-agsta.
*
*    IF sy-subrc NE 0.
*      CLEAR gs_stat.
*      ADD 1 TO lf_nochange.
*      CONTINUE.
*    ENDIF.

* Text und Icon zum neuen Status lesen
*    CLEAR ls_tfk050at.
*    SELECT SINGLE astxt FROM tfk050at
*      INTO lf_agstatxt
*           WHERE spras = sy-langu
*           AND agsta = gs_stat-set_agsta.
*    IF sy-subrc NE 0.
*      ls_items-agstatxt = TEXT-015.
*    ENDIF.

    REFRESH itab_dfkkcoll.
    REFRESH itab_undo.
    REFRESH ht_enqtab.
    CLEAR error.

    LOOP AT t_items INTO ls_items
         WHERE gpart = ls_header-gpart
         AND   vkont = ls_header-vkont.

      CLEAR: lf_agsta, lf_agdat.
* check that the status did not change
      SELECT SINGLE agsta agdat FROM dfkkcoll
             INTO (lf_agsta, lf_agdat)
             WHERE opbel = ls_items-opbel
             AND   inkps = ls_items-inkps.

      IF lf_agsta = const_agsta_freigegeben OR
         lf_agsta = const_agsta_recalled.

* Berechtigung für Status ?
        CLEAR gs_stat.
        READ TABLE gt_stat INTO gs_stat
             WITH KEY begru = gs_bgus-begru
                      ucomm = ff_ucomm
                      agsta = ls_items-agsta.

        IF sy-subrc NE 0.
          CLEAR gs_stat.
          ADD 1 TO lf_nochange.
          CONTINUE.
        ENDIF.

        READ TABLE itab_dfkkcoll
                  WITH KEY opbel = ls_items-opbel
                           inkps = ls_items-inkps.
        IF sy-subrc NE 0.
          MOVE-CORRESPONDING: ls_items TO itab_dfkkcoll.
          APPEND itab_dfkkcoll.
        ENDIF.

        READ TABLE itab_undo
                  WITH KEY opbel = ls_items-opbel
                           inkps = ls_items-inkps.
        IF sy-subrc NE 0.
          MOVE-CORRESPONDING ls_items TO itab_undo.
          APPEND itab_undo.
        ENDIF.

        READ TABLE ht_enqtab WITH KEY gpart = ls_items-gpart.
        IF sy-subrc NE 0.
          ht_enqtab-gpart = ls_items-gpart.
          APPEND ht_enqtab.
        ENDIF.
*      ELSE.
*        error = error + 1.
      ENDIF.

    ENDLOOP.

    IF error NE 0.
      ADD 1 TO lf_nochg_stat.
      CONTINUE.
    ENDIF.

    CHECK itab_dfkkcoll[] IS NOT INITIAL.

* -- Enqueue the business partner before changing table DFKKOP ---------
    PERFORM dfkkop_enqueue.

    CALL FUNCTION 'FKK_DB_DFKKCOLL_MODE'
      EXPORTING
        i_mode    = mode_delete
      TABLES
        t_fkkcoll = itab_dfkkcoll
      EXCEPTIONS
        error     = 1
        OTHERS    = 2.

    IF sy-subrc <> 0.
      MESSAGE e845(>3) WITH 'DFKKCOLL'.
    ELSE.
*    insert collection agency history table w/ new status
      istr_dfkkcoll-agsta = gs_stat-set_agsta.
      MODIFY itab_dfkkcoll FROM istr_dfkkcoll
             TRANSPORTING agsta
*             WHERE agsta = '01'
             WHERE agsta = const_agsta_freigegeben OR
                   agsta = const_agsta_recalled.

      PERFORM create_history TABLES itab_dfkkcoll.
      COMMIT WORK.
    ENDIF.

    LOOP AT itab_undo.
      UPDATE dfkkop SET inkps = 0
                    WHERE opbel = itab_undo-opbel
                    AND   inkps = itab_undo-inkps.

* set new status in DFKKCOLL if set in customizing
      IF gs_stat-set_agsta NE space.
        CLEAR ls_dfkkcoll.
        MOVE-CORRESPONDING itab_undo TO ls_dfkkcoll.
        ls_dfkkcoll-agsta = gs_stat-set_agsta.
        CLEAR ls_dfkkcoll-inkps.
        CLEAR ls_dfkkcoll-aggrd.
        MODIFY dfkkcoll FROM ls_dfkkcoll.
      ENDIF.


      LOOP AT t_items INTO ls_items
                       WHERE opbel = itab_undo-opbel
                         AND inkps = itab_undo-inkps.

        li_tabix = sy-tabix.

        IF gs_stat-set_agsta = space.
          CLEAR ls_items-inkgp.
        ENDIF.

        ls_items-agsta = gs_stat-set_agsta.

        CLEAR ls_items-aggrd.
        CLEAR ls_items-inkps.

*   ICON auf erneut ptüfen setzen
        PERFORM set_status_icon USING ls_items-agsta ls_items-status.
        MODIFY t_items FROM ls_items INDEX li_tabix.

      ENDLOOP.

    ENDLOOP.

    COMMIT WORK.

* --- Dequeue all business partner ------------------------------------
    CALL FUNCTION 'FKK_OPEN_ITEM_DEQUEUE'.

    IF gs_stat-set_agsta = space.
      CLEAR s_header-inkgp.
      CLEAR s_header-inkname.
    ENDIF.

    ls_header-agsta = gs_stat-set_agsta.
    CLEAR ls_header-agdat.

*   ICON auf Vorgemerkt setzen
    PERFORM set_status_icon USING ls_header-agsta ls_header-status.
    MODIFY t_header FROM ls_header INDEX lh_tabix.

  ENDLOOP.

  IF lf_nochange > 0.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-f06
        textline2 = TEXT-e04.
  ENDIF.

  IF lf_nochg_stat > 0.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-f05
        textline2 = TEXT-e09.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  SET_MAHNSPERRE
*&---------------------------------------------------------------------*
FORM set_mahnsperre  USING       pv_gpart
                                 pv_vkont
                                 pv_lockr.

  DATA: lv_loobj1 LIKE dfkklocks-loobj1.

* Schon Mahnsperre auf VK vorhanden, dann vorher löschen
  PERFORM del_mahnsperre  USING pv_gpart pv_vkont.

* Dann Mahnsperre setzen
  CONCATENATE pv_vkont pv_gpart INTO lv_loobj1.

  CALL FUNCTION 'FKK_S_LOCK_CREATE'
    EXPORTING
      i_loobj1              = lv_loobj1
      i_gpart               = pv_gpart
      i_vkont               = pv_vkont
      i_proid               = '01'
      i_lotyp               = '06'
      i_lockr               = pv_lockr
      i_fdate               = sy-datum
      i_tdate               = '99991231'
      i_upd_online          = 'X'
    EXCEPTIONS
      already_exist         = 1
      imp_data_not_complete = 2
      no_authority          = 3
      enqueue_lock          = 4
      wrong_data            = 5
      OTHERS                = 6.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  DEL_MAHNSPERRE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_OUT_VKONT  text
*----------------------------------------------------------------------*
FORM del_mahnsperre  USING       pv_gpart
                                 pv_vkont.

  DATA: lt_locks  TYPE  dfkklocks_t.
  DATA: ls_locks  TYPE  dfkklocks.

  CALL FUNCTION 'FKK_S_LOCK_GET_FOR_VKONT'
    EXPORTING
      iv_vkont = pv_vkont
      iv_gpart = pv_gpart
      iv_date  = sy-datum
      iv_proid = '01'
    IMPORTING
      et_locks = lt_locks.

* Alle derzeitige Mahnsperre löschen
  LOOP AT lt_locks INTO ls_locks
       WHERE lotyp = '06'
       AND   proid = '01'.

    CALL FUNCTION 'FKK_S_LOCK_DELETE'
      EXPORTING
        i_loobj1 = ls_locks-loobj1
        i_gpart  = ls_locks-gpart
        i_vkont  = ls_locks-vkont
        i_proid  = ls_locks-proid
        i_lotyp  = ls_locks-lotyp
        i_lockr  = ls_locks-lockr
        i_fdate  = ls_locks-fdate
        i_tdate  = ls_locks-tdate
      EXCEPTIONS
        OTHERS   = 7.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_MAHNSP_HIST
*&---------------------------------------------------------------------*
FORM set_mahnsp_hist  USING pv_gpart
                            pv_vkont
                            pv_lockr.

  DATA: lt_dfkklocksh TYPE TABLE OF dfkklocksh.
  DATA: ls_dfkklocksh TYPE dfkklocksh.
  DATA: ls_locksh_del TYPE dfkklocksh.
  DATA: lv_loobj1 LIKE dfkklocks-loobj1.

  CLEAR pv_lockr.
* Historie Mahnsperren zu GPART und VKONT lesen
  CONCATENATE pv_vkont pv_gpart INTO lv_loobj1.
  SELECT * FROM dfkklocksh
         INTO TABLE lt_dfkklocksh
         WHERE loobj1 = lv_loobj1
         AND   lotyp = '06'
         AND   proid = '01'.

  SORT lt_dfkklocksh BY lfdnr DESCENDING.

* Letzte Änderung sollte die Löschung aus del_mahnsperre sein.
* Sehr unwahrscheinlich, aber sonst hat jemand dazwischen gefunkt.
  CLEAR ls_locksh_del.
  READ TABLE lt_dfkklocksh INTO ls_locksh_del INDEX 1.
  CHECK sy-subrc = 0.
  CHECK ls_locksh_del-lockr  = p_lockr AND
        ls_locksh_del-luname = sy-uname AND
        ls_locksh_del-ldatum = sy-datum.

  DELETE  lt_dfkklocksh INDEX 1.

  CLEAR ls_dfkklocksh-lockr.
* letzte Sperre for Inkasso-Sperrgrund wieder setzen
  LOOP AT lt_dfkklocksh INTO ls_dfkklocksh
       WHERE lockr NE p_lockr
       AND   luname = ls_locksh_del-uname
       AND   ldatum = ls_locksh_del-adatum
       AND   lzeit  = ls_locksh_del-azeit.

    CALL FUNCTION 'FKK_S_LOCK_CREATE'
      EXPORTING
        i_loobj1              = ls_dfkklocksh-loobj1
        i_gpart               = pv_gpart
        i_vkont               = pv_vkont
        i_proid               = '01'
        i_lotyp               = '06'
        i_lockr               = ls_dfkklocksh-lockr
        i_fdate               = sy-datum
        i_tdate               = ls_dfkklocksh-tdate
        i_upd_online          = 'X'
      EXCEPTIONS
        already_exist         = 1
        imp_data_not_complete = 2
        no_authority          = 3
        enqueue_lock          = 4
        wrong_data            = 5
        OTHERS                = 6.
    IF sy-subrc <> 0.
      CLEAR ls_dfkklocksh-lockr.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    EXIT.

  ENDLOOP.

  pv_lockr = ls_dfkklocksh-lockr.


ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_ZAHLSPERRE
*&---------------------------------------------------------------------*
FORM set_zahlsperre  USING       pv_gpart
                                 pv_vkont.

  DATA: lt_locks  TYPE  dfkklocks_t.
  DATA: ls_locks  TYPE  dfkklocks.
  DATA: lv_loobj1 LIKE dfkklocks-loobj1.
  DATA: lv_lockr  TYPE lockr_kk.


* Nur durchführen, wenn im Customizing gepflegt
  CLEAR gs_cust.
  READ TABLE gt_cust INTO gs_cust
       WITH KEY inkasso_option   = 'ZAHL_SPERRE'
                inkasso_category = 'AUSGANG'
                inkasso_field    = 'LOCKR'.

  CHECK sy-subrc = 0.
  lv_lockr = gs_cust-inkasso_value.


* Schon Zahlsperre auf VK vorhanden, dann vorher löschen
  CALL FUNCTION 'FKK_S_LOCK_GET_FOR_VKONT'
    EXPORTING
      iv_vkont = pv_vkont
      iv_gpart = pv_gpart
      iv_date  = sy-datum
      iv_proid = '03'
    IMPORTING
      et_locks = lt_locks.

* Alle derzeitige Zahlsperre löschen
  LOOP AT lt_locks INTO ls_locks
       WHERE lotyp = '06'
       AND   proid = '03'.

    CALL FUNCTION 'FKK_S_LOCK_DELETE'
      EXPORTING
        i_loobj1 = ls_locks-loobj1
        i_gpart  = ls_locks-gpart
        i_vkont  = ls_locks-vkont
        i_proid  = ls_locks-proid
        i_lotyp  = ls_locks-lotyp
        i_lockr  = ls_locks-lockr
        i_fdate  = ls_locks-fdate
        i_tdate  = ls_locks-tdate
      EXCEPTIONS
        OTHERS   = 7.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDLOOP.

* Dann Zahlsperre setzen
  CONCATENATE pv_vkont pv_gpart INTO lv_loobj1.

  CALL FUNCTION 'FKK_S_LOCK_CREATE'
    EXPORTING
      i_loobj1              = lv_loobj1
      i_gpart               = pv_gpart
      i_vkont               = pv_vkont
      i_proid               = '03'
      i_lotyp               = '06'
      i_lockr               = lv_lockr
      i_fdate               = sy-datum
      i_tdate               = '99991231'
      i_upd_online          = 'X'
    EXCEPTIONS
      already_exist         = 1
      imp_data_not_complete = 2
      no_authority          = 3
      enqueue_lock          = 4
      wrong_data            = 5
      OTHERS                = 6.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ucom_STORNO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ucom_storno .

  DATA: ls_dfkkko TYPE dfkkko.
  DATA: ls_dfkkop TYPE dfkkop.

  DATA: ls_out LIKE /adesso/inkasso_out,
        lt_out LIKE STANDARD TABLE OF /adesso/inkasso_out.

  DATA: rspar_tab  TYPE TABLE OF rsparams,
        rspar_line LIKE LINE OF rspar_tab.

  DATA: lt_cust TYPE TABLE OF /adesso/ink_cust,
        ls_cust TYPE /adesso/ink_cust.


  SELECT * FROM /adesso/ink_cust INTO TABLE  lt_cust
    WHERE inkasso_option = 'STORNO'
      AND inkasso_field =  'BLART'.


  IF sy-subrc NE 0.
    MESSAGE e007.
  ENDIF.


  LOOP AT t_out INTO ls_out WHERE sel IS NOT INITIAL
     AND agsta IS INITIAL.

    SELECT SINGLE * FROM dfkkko INTO ls_dfkkko
    WHERE opbel = ls_out-opbel.

    READ TABLE lt_cust TRANSPORTING NO FIELDS
      WITH KEY inkasso_value = ls_dfkkko-blart.

    IF sy-subrc = 0.
      APPEND ls_out TO lt_out.
    ENDIF.
  ENDLOOP.

  IF lt_out IS INITIAL.
    MESSAGE e006.
  ENDIF.

* Normale ALV-Tabelle
  LOOP AT lt_out INTO ls_out.

    rspar_line-selname = 'SC_OPBEL-LOW'.
    rspar_line-kind = 'S'.
    rspar_line-sign = 'I'.
    rspar_line-option = 'EQ'.
    rspar_line-low = ls_out-opbel.
    APPEND rspar_line TO rspar_tab.
    CLEAR rspar_line.

  ENDLOOP.

  IF rspar_tab IS NOT INITIAL.
    SUBMIT rfkkstor  VIA SELECTION-SCREEN
                     WITH SELECTION-TABLE rspar_tab
                     AND RETURN.
  ENDIF.



ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UCOM_STORNO_HIER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ucom_storno_hier .

  DATA: ls_dfkkko   TYPE dfkkko.
  DATA: ls_dfkkop   TYPE dfkkop.
  DATA: ls_dfkkcoll TYPE dfkkcoll.

  DATA: ls_items     LIKE /adesso/inkasso_items,
        lt_items_sto LIKE STANDARD TABLE OF /adesso/inkasso_items.

  DATA: rspar_tab  TYPE TABLE OF rsparams,
        rspar_line LIKE LINE OF rspar_tab.

  DATA: lt_cust TYPE TABLE OF /adesso/ink_cust,
        ls_cust TYPE /adesso/ink_cust.

  SELECT * FROM /adesso/ink_cust INTO TABLE  lt_cust
    WHERE inkasso_option = 'STORNO'
      AND inkasso_field =  'BLART'.

  IF sy-subrc NE 0.
    MESSAGE e007.
  ENDIF.

  LOOP AT t_items INTO ls_items
     WHERE sel IS NOT INITIAL.

* Ausgeglichene oder stornierte Posten nicht berücksichtigen
    CHECK ls_items-augdt IS INITIAL.

* Storno Mahnkosten immer zulassen
*    CHECK ls_items-agsta NOT BETWEEN '01' AND '02'.

    SELECT SINGLE * FROM dfkkko INTO ls_dfkkko
    WHERE opbel = ls_items-opbel.

    READ TABLE lt_cust TRANSPORTING NO FIELDS
      WITH KEY inkasso_value = ls_dfkkko-blart.

    IF sy-subrc = 0.
      APPEND ls_items TO lt_items_sto.
    ENDIF.
  ENDLOOP.

  IF lt_items_sto IS INITIAL.
    MESSAGE e006.
  ENDIF.

  LOOP AT lt_items_sto INTO ls_items.

    rspar_line-selname = 'SC_OPBEL-LOW'.
    rspar_line-kind = 'S'.
    rspar_line-sign = 'I'.
    rspar_line-option = 'EQ'.
    rspar_line-low = ls_items-opbel.
    APPEND rspar_line TO rspar_tab.
    CLEAR rspar_line.

  ENDLOOP.

  PERFORM fill_rspar_rfkkstor TABLES rspar_tab.

  IF rspar_tab IS NOT INITIAL.
    SUBMIT rfkkstor  VIA SELECTION-SCREEN
                     WITH SELECTION-TABLE rspar_tab
                     AND RETURN.
  ENDIF.

  COMMIT WORK.

  LOOP AT t_items INTO ls_items WHERE sel IS NOT INITIAL.

    CLEAR ls_dfkkop.
    SELECT SINGLE * FROM dfkkop INTO ls_dfkkop
       WHERE opbel = ls_items-opbel
         AND opupw = ls_items-opupw
         AND opupk = ls_items-opupk
         AND opupz = ls_items-opupz.

    IF ls_dfkkop-augbl IS NOT INITIAL AND
       ls_dfkkop-augrd = '05'.

      ls_items-augdt = ls_dfkkop-augdt.
      ls_items-augrd = ls_dfkkop-augrd.

      CASE ls_items-agsta.
        WHEN '97' OR '98' OR '99'.
          PERFORM set_agsta_dfkkcoll USING ls_items-opbel
                                           ls_items-inkps
                                           c_mode_del
                                           ls_items-agsta
                                           ' '.
          ls_items-agsta = const_agsta_storniert.
        WHEN OTHERS.
*         get dfkkcoll
          SELECT SINGLE * FROM dfkkcoll
                 INTO ls_dfkkcoll
                 WHERE opbel = ls_items-opbel
                 AND   inkps = ls_items-inkps.
*         AGSTA noch nicht 05, dan setzen
          IF ls_dfkkcoll-agsta NE const_agsta_storniert.
            ls_items-agsta = const_agsta_storniert.
            UPDATE dfkkcoll
                   SET agsta = const_agsta_storniert
                   WHERE opbel = ls_items-opbel
                   AND   inkps = ls_items-inkps.
          ENDIF.

      ENDCASE.

    ENDIF.

    PERFORM set_status_icon USING ls_items-agsta ls_items-status.

    MODIFY t_items FROM ls_items.

  ENDLOOP.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  UCOM_SET_NEWLOOK
*&---------------------------------------------------------------------*
FORM ucom_set_newlook.

  DATA: ls_dd07t    TYPE dd07t.
  DATA: ls_dfkkcoll TYPE dfkkcoll.
  DATA: ls_tfk050at TYPE tfk050at.
  DATA: v_tabix LIKE sy-tabix.

  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
    EXPORTING
      titel     = TEXT-inf
      textline1 = TEXT-f03
      textline2 = TEXT-e12.
  EXIT.

  LOOP AT t_out INTO wa_out
     WHERE sel IS NOT INITIAL.

    CLEAR ls_dfkkcoll.

    CHECK wa_out-agsta = '99'.

    wa_out-agsta = '98'.

*   Kurztext zum Abgabestatus reinschreiben
    CLEAR ls_tfk050at.
    SELECT SINGLE astxt FROM tfk050at INTO wa_out-agstatxt
      WHERE spras = sy-langu
        AND agsta = '98'.

    IF sy-subrc NE 0.
      wa_out-agstatxt = 'erneute Prüfung erforderlich'.
    ENDIF.

*  ICON auf YELLOW setzen
    CALL FUNCTION 'ICON_CREATE'
      EXPORTING
        name                  = 'ICON_DISPLAY'
        info                  = TEXT-015
      IMPORTING
        result                = wa_out-status
      EXCEPTIONS
        icon_not_found        = 1
        outputfield_too_short = 2
        OTHERS                = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.


    MOVE-CORRESPONDING wa_out TO ls_dfkkcoll.
    MODIFY dfkkcoll FROM ls_dfkkcoll.

    MODIFY t_out FROM wa_out.
  ENDLOOP.

  COMMIT WORK.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UCOM_SET_NEWLOOK_HIER
*&---------------------------------------------------------------------*
FORM ucom_set_newlook_hier  USING ff_ucomm LIKE sy-ucomm
                                  ff_gplocked LIKE gv_gplocked.

  DATA: ls_dfkkcoll TYPE dfkkcoll.
  DATA: lt_dfkkcoll TYPE TABLE OF dfkkcoll.
  DATA: ls_tfk050at TYPE tfk050at.
  DATA: lv_tabix LIKE sy-tabix.
  DATA: lf_nochange TYPE sy-tabix.
  DATA: ls_header TYPE /adesso/inkasso_header.
  DATA: ls_items  TYPE /adesso/inkasso_items.
  DATA: lf_agstatxt TYPE val_text.

  CLEAR:   lf_nochange.
  CLEAR:   ff_gplocked.

  REFRESH lt_dfkkcoll.

* Für Hierarchische Liste
  LOOP AT t_header INTO ls_header
       WHERE sel IS NOT INITIAL.

    lv_tabix = sy-tabix.

* VK für Bearbeitung gesperrt ?
    IF ls_header-locked IS NOT INITIAL.
      ff_gplocked = 'X'.
      CONTINUE.
    ENDIF.

* Berechtigung für Status ?
    CLEAR gs_stat.
    READ TABLE gt_stat INTO gs_stat
         WITH KEY begru = gs_bgus-begru
                  ucomm = ff_ucomm
                  agsta = ls_header-agsta.

    IF sy-subrc NE 0.
      CLEAR gs_stat.
      ADD 1 TO lf_nochange.
      CONTINUE.
    ENDIF.

* Text und Icon zum neuen Status lesen
    CLEAR ls_tfk050at.
    SELECT SINGLE astxt FROM tfk050at
      INTO lf_agstatxt
           WHERE spras = sy-langu
           AND agsta = gs_stat-set_agsta.
    IF sy-subrc NE 0.
      lf_agstatxt = TEXT-015.
    ENDIF.


    ls_header-agsta = gs_stat-set_agsta.

*   ICON auf Erneut Prüfen setzen
    PERFORM set_status_icon USING ls_header-agsta ls_header-status.
    MODIFY t_header FROM ls_header INDEX lv_tabix.

* jetzt alle Posten bearbeiten
    LOOP AT t_items INTO ls_items
           WHERE gpart = ls_header-gpart
           AND   vkont = ls_header-vkont.

* Ausgeglichene oder stornierte Posten nicht berücksichtigen
      CHECK ls_items-augdt IS INITIAL.

      CLEAR ls_dfkkcoll.

      ls_items-agsta    = gs_stat-set_agsta.
      ls_items-agstatxt = lf_agstatxt.
      MOVE-CORRESPONDING ls_items TO ls_dfkkcoll.
      MODIFY dfkkcoll FROM ls_dfkkcoll.

      IF sy-subrc = 0.
        APPEND ls_dfkkcoll TO lt_dfkkcoll.
*    ICON auf Erneut prüfen setzen
        PERFORM set_status_icon USING ls_items-agsta ls_items-status.
      ELSE.
        CALL FUNCTION 'ICON_CREATE'
          EXPORTING
            name                  = 'ICON_LED_RED'
            info                  = TEXT-e08
          IMPORTING
            result                = ls_items-status
          EXCEPTIONS
            icon_not_found        = 1
            outputfield_too_short = 2
            OTHERS                = 3.

        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      ENDIF.

      MODIFY t_items FROM ls_items.

    ENDLOOP.

  ENDLOOP.

  IF lt_dfkkcoll[] IS NOT INITIAL.
    PERFORM create_history TABLES lt_dfkkcoll.
  ENDIF.

  COMMIT WORK.

  IF lf_nochange > 0.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-f03
        textline2 = TEXT-e04.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UCOM_SET_CHECKED
*&---------------------------------------------------------------------*
FORM ucom_set_checked.

  DATA:  ls_dd07t     TYPE dd07t.
  DATA: ls_dfkkcoll TYPE dfkkcoll.
  DATA: ls_tfk050at TYPE tfk050at.
  DATA: v_tabix LIKE sy-tabix.

  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
    EXPORTING
      titel     = TEXT-inf
      textline1 = TEXT-f04
      textline2 = TEXT-e12.
  EXIT.

  LOOP AT t_out INTO wa_out
     WHERE sel IS NOT INITIAL.

    CLEAR ls_dfkkcoll.

    CHECK wa_out-agsta = '98'.

    wa_out-agsta = '97'.


*   Kurztext zum Abgabestatus reinschreiben
    CLEAR ls_tfk050at.
    SELECT SINGLE astxt FROM tfk050at INTO wa_out-agstatxt
      WHERE spras = sy-langu
        AND agsta = '97'.

    IF sy-subrc NE 0.
      wa_out-agstatxt = 'Geprüft'.
    ENDIF.

*  ICON auf YELLOW setzen
    CALL FUNCTION 'ICON_CREATE'
      EXPORTING
        name                  = 'ICON_AVAILABILITY_DISPLAY'
        info                  = TEXT-016
      IMPORTING
        result                = wa_out-status
      EXCEPTIONS
        icon_not_found        = 1
        outputfield_too_short = 2
        OTHERS                = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.


    MOVE-CORRESPONDING wa_out TO ls_dfkkcoll.
    MODIFY dfkkcoll FROM ls_dfkkcoll.

    MODIFY t_out FROM wa_out.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UCOM_SET_CHECKED_HIER
*&---------------------------------------------------------------------*
FORM ucom_set_checked_hier  USING ff_ucomm LIKE sy-ucomm
                                  ff_gplocked LIKE gv_gplocked.

  DATA: ls_dfkkcoll TYPE dfkkcoll.
  DATA: lt_dfkkcoll TYPE TABLE OF dfkkcoll.
  DATA: ls_tfk050at TYPE tfk050at.
  DATA: lv_tabix LIKE sy-tabix.
  DATA: lf_nochange TYPE sy-tabix.
  DATA: ls_header TYPE /adesso/inkasso_header.
  DATA: ls_items  TYPE /adesso/inkasso_items.
  DATA: lf_agstatxt TYPE val_text.

  CLEAR:   lf_nochange.
  CLEAR:   ff_gplocked.

  REFRESH lt_dfkkcoll.

* Für Hierarchische Liste
  LOOP AT t_header INTO ls_header
       WHERE sel IS NOT INITIAL.

    lv_tabix = sy-tabix.

* VK für Bearbeitung gesperrt ?
    IF ls_header-locked IS NOT INITIAL.
      ff_gplocked = 'X'.
      CONTINUE.
    ENDIF.

* Berechtigung für Status ?
    CLEAR gs_stat.
    READ TABLE gt_stat INTO gs_stat
         WITH KEY begru = gs_bgus-begru
                  ucomm = ff_ucomm
                  agsta = ls_header-agsta.

    IF sy-subrc NE 0.
      CLEAR gs_stat.
      ADD 1 TO lf_nochange.
      CONTINUE.
    ENDIF.

* Text und Icon zum neuen Status lesen
    CLEAR ls_tfk050at.
    SELECT SINGLE astxt FROM tfk050at
      INTO lf_agstatxt
           WHERE spras = sy-langu
           AND   agsta = gs_stat-set_agsta.
    IF sy-subrc NE 0.
      lf_agstatxt = TEXT-016.
    ENDIF.

    ls_header-agsta = gs_stat-set_agsta.

*   ICON auf Geprüft setzen
    PERFORM set_status_icon USING ls_header-agsta ls_header-status.
    MODIFY t_header FROM ls_header INDEX lv_tabix.

* jetzt alle Posten bearbeiten
    LOOP AT t_items INTO ls_items
           WHERE gpart = ls_header-gpart
           AND   vkont = ls_header-vkont.

* Ausgeglichene oder stornierte Posten nicht berücksichtigen
      CHECK ls_items-augdt IS INITIAL.

      CLEAR ls_dfkkcoll.

      ls_items-agsta    = gs_stat-set_agsta.
      ls_items-agstatxt = lf_agstatxt.
      MOVE-CORRESPONDING ls_items TO ls_dfkkcoll.
      MODIFY dfkkcoll FROM ls_dfkkcoll.

      IF sy-subrc = 0.
        APPEND ls_dfkkcoll TO lt_dfkkcoll.
*   ICON auf Geprüft setzen
        PERFORM set_status_icon USING ls_items-agsta ls_items-status.

      ELSE.
        CALL FUNCTION 'ICON_CREATE'
          EXPORTING
            name                  = 'ICON_LED_RED'
            info                  = TEXT-e08
          IMPORTING
            result                = ls_items-status
          EXCEPTIONS
            icon_not_found        = 1
            outputfield_too_short = 2
            OTHERS                = 3.

        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      ENDIF.

      MODIFY t_items FROM ls_items.

    ENDLOOP.

  ENDLOOP.

  IF lt_dfkkcoll[] IS NOT INITIAL.
    PERFORM create_history TABLES lt_dfkkcoll.
  ENDIF.

  COMMIT WORK.

  IF lf_nochange > 0.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-f04
        textline2 = TEXT-e04.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UCOM_GET_CIC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ucom_get_cic USING ff_vkont TYPE vkont_kk.

* --> nuss 04.2018
  DATA: iv_screen_no TYPE cicfwscreenno.
  DATA: wa_bdc    TYPE bdcdata,
        t_bdc     TYPE TABLE OF bdcdata,
        t_messtab TYPE TABLE OF bdcmsgcoll.

  DATA:  lv_tcode TYPE sy-tcode.
* <-- Nuss 04.2018

  PERFORM get_cic_frame_for_user CHANGING iv_screen_no.

  CLEAR t_bdc.

  wa_bdc-fnam = 'BDC_OKCODE'.
  wa_bdc-fval = '=RFSH'.
  APPEND wa_bdc TO t_bdc.
  CLEAR wa_bdc.

  wa_bdc-fnam = 'EFINDD_CIC-A_VKONT'.
  wa_bdc-fval = ff_vkont.
  APPEND wa_bdc TO t_bdc.
  CLEAR wa_bdc.

  IF iv_screen_no IS NOT INITIAL.
    CLEAR wa_bdc.
    wa_bdc-program = 'SAPLCIC0'.
    wa_bdc-dynpro = iv_screen_no.
    wa_bdc-dynbegin = 'X'.
    APPEND wa_bdc TO t_bdc.
    CLEAR wa_bdc.

    SORT t_bdc
      BY program DESCENDING
           fnam  ASCENDING.
  ELSE.
    MESSAGE w003.
    CLEAR  t_bdc.
  ENDIF.

  lv_tcode = 'CIC0'.

  CALL FUNCTION 'CALL_CIC_TRANSACTION'
    EXPORTING
      tcode            = lv_tcode
      skipfirst        = 'X'
    TABLES
      in_bdcdata       = t_bdc
      out_messtab      = t_messtab
    EXCEPTIONS
      no_authorization = 1
      OTHERS           = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_CUST_BEGRU
*&---------------------------------------------------------------------*
FORM get_cust_begru .

  REFRESH gt_bgus.

  SELECT SINGLE * FROM /adesso/ink_bgus
         INTO gs_bgus
         WHERE bname = sy-uname.

  IF sy-subrc = 0.
    APPEND gs_bgus TO gt_bgus.
  ELSE.
    SELECT SINGLE * FROM /adesso/ink_bgus
          INTO gs_bgus
          WHERE bname = '*'.
    IF sy-subrc = 0.
      APPEND gs_bgus TO gt_bgus.
    ENDIF.
  ENDIF.

  IF gt_bgus[] IS NOT INITIAL.
    SELECT * FROM /adesso/ink_begr
           INTO TABLE gt_begr
           FOR ALL ENTRIES IN gt_bgus
           WHERE begru = gt_bgus-begru.

    SELECT * FROM /adesso/ink_bgss
           INTO TABLE gt_bgss
           FOR ALL ENTRIES IN gt_bgus
           WHERE begru = gt_bgus-begru.

    SELECT * FROM /adesso/ink_stat
           INTO TABLE gt_stat
           FOR ALL ENTRIES IN gt_bgus
           WHERE begru = gt_bgus-begru.

    SELECT * FROM /adesso/ink_bgsb
           INTO TABLE gt_bgsb
           FOR ALL ENTRIES IN gt_bgus
           WHERE begru = gt_bgus-begru.

    SELECT * FROM /adesso/wo_begr
           INTO TABLE gt_wo_begr
           FOR ALL ENTRIES IN gt_bgus
           WHERE begru = gt_bgus-begru.

    SELECT * FROM /adesso/wo_frei
           INTO TABLE gt_wo_frei
           FOR ALL ENTRIES IN gt_bgus
           WHERE begru = gt_bgus-begru.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  UCOM_MARK_HIER
*&---------------------------------------------------------------------*
FORM ucom_mark_hier .

  FIELD-SYMBOLS: <wa_header> TYPE /adesso/inkasso_header.
  FIELD-SYMBOLS: <wa_items>  TYPE /adesso/inkasso_items.

  LOOP AT t_header ASSIGNING <wa_header>
          WHERE sel = 'X'.
    LOOP AT t_items ASSIGNING <wa_items>
      WHERE vkont = <wa_header>-vkont.
      <wa_items>-sel = 'X'.
    ENDLOOP.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UCOM_DEMARK_HIER
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM ucom_demark_hier .

  FIELD-SYMBOLS: <wa_header> TYPE /adesso/inkasso_header.
  FIELD-SYMBOLS: <wa_items>  TYPE /adesso/inkasso_items.

  LOOP AT t_header ASSIGNING <wa_header>
          WHERE sel = 'X'.
    LOOP AT t_items ASSIGNING <wa_items>
      WHERE vkont = <wa_header>-vkont.
      <wa_items>-sel = ' '.
    ENDLOOP.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UCOM_DEMARK_HIER
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM ucom_refresh_hier .

  FIELD-SYMBOLS: <wa_header> TYPE /adesso/inkasso_header.
  FIELD-SYMBOLS: <wa_items>  TYPE /adesso/inkasso_items.

  DATA: lr_agsta TYPE RANGE OF agsta_kk.
  DATA: ls_agsta LIKE LINE OF lr_agsta.
  DATA: lv_tabix LIKE sy-tabix.


  REFRESH lr_agsta.

  ls_agsta-option = 'EQ'.
  ls_agsta-sign   = 'I'.

  IF wa_opt-xagapi = space.
    ls_agsta-low   = '  '.
    APPEND ls_agsta TO lr_agsta.
  ENDIF.

  IF wa_opt-xvorm = space.
    ls_agsta-low   = '99'.
    APPEND ls_agsta TO lr_agsta.
  ENDIF.

  IF wa_opt-xlook = space.
    ls_agsta-low   = '98'.
    APPEND ls_agsta TO lr_agsta.
  ENDIF.

  IF wa_opt-xchkd = space.
    ls_agsta-low   = '97'.
    APPEND ls_agsta TO lr_agsta.
  ENDIF.

  IF wa_opt-xfrei = space.
    ls_agsta-low   = '01'.
    APPEND ls_agsta TO lr_agsta.
  ENDIF.

  IF wa_opt-xagip = space.
    ls_agsta-low   = '02'.
    APPEND ls_agsta TO lr_agsta.
  ENDIF.

  IF wa_opt-xreca = space.
    ls_agsta-low   = '09'.
    APPEND ls_agsta TO lr_agsta.
  ENDIF.

  LOOP AT t_header ASSIGNING <wa_header>.
    CHECK <wa_header>-agsta IN lr_agsta.

    lv_tabix = sy-tabix.

    LOOP AT t_items ASSIGNING <wa_items>
      WHERE gpart = <wa_header>-gpart
      AND   vkont = <wa_header>-vkont.

      DELETE t_items INDEX sy-tabix.

    ENDLOOP.

    CALL FUNCTION 'DEQUEUE_/ADESSO/INKMON'
      EXPORTING
        mode_/adesso/ink_enqu = 'X'
        ink_proc              = '01'
        vkont                 = <wa_header>-vkont
        x_bukrs               = ' '
        _scope                = '1'
        _collect              = ' '.

    DELETE t_header INDEX lv_tabix.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FILL_RSPAR_RFKKCOL2
*&---------------------------------------------------------------------*
FORM fill_rspar_rfkkcol2  TABLES ft_rspar_tab STRUCTURE rsparams.

  DATA: rspar_line LIKE LINE OF ft_rspar_tab.

  DATA: lt_cust TYPE TABLE OF /adesso/ink_cust.
  DATA: ls_cust TYPE /adesso/ink_cust.


*  Auch statistische Posten
  rspar_line-selname = 'XSTKZ'.
  rspar_line-kind = 'P'.
  rspar_line-low = 'X'.
  APPEND rspar_line TO ft_rspar_tab.
  CLEAR rspar_line.

*  Simulation aus
  rspar_line-selname = 'SIMULATE'.
  rspar_line-kind = 'P'.
  rspar_line-low = ' '.
  APPEND rspar_line TO ft_rspar_tab.
  CLEAR rspar_line.

*  Echtlauf
  rspar_line-selname = 'REALRUN'.
  rspar_line-kind = 'P'.
  rspar_line-low = 'X'.
  APPEND rspar_line TO ft_rspar_tab.
  CLEAR rspar_line.

* Dateierstellung
  rspar_line-selname = 'YESFILE'.
  rspar_line-kind = 'P'.
  rspar_line-low = 'X'.
  APPEND rspar_line TO ft_rspar_tab.
  CLEAR rspar_line.

* Dateierstellung / Name aus Customizing
  REFRESH lt_cust.
  SELECT * FROM /adesso/ink_cust INTO TABLE lt_cust
     WHERE inkasso_option    = 'DATEI'
     AND   inkasso_category  = 'FILENAME'.

  READ TABLE lt_cust INTO ls_cust INDEX 1.

  rspar_line-selname = 'FILENAME'.
  rspar_line-kind = 'P'.
  rspar_line-low = ls_cust-inkasso_value.
  APPEND rspar_line TO ft_rspar_tab.
  CLEAR rspar_line.

* Dateierstellung / Name aus Customizing
  REFRESH lt_cust.
  SELECT * FROM /adesso/ink_cust INTO TABLE lt_cust
     WHERE inkasso_option    = 'DATEI'
     AND   inkasso_category  = 'UNICODE'.

  READ TABLE lt_cust INTO ls_cust INDEX 1.

  rspar_line-selname = 'UNICODE'.
  rspar_line-kind = 'P'.
  rspar_line-low = ls_cust-inkasso_value.
  APPEND rspar_line TO ft_rspar_tab.
  CLEAR rspar_line.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FILL_RSPAR_RFKKSTOR
*&---------------------------------------------------------------------*
FORM fill_rspar_rfkkstor  TABLES ft_rspar_tab STRUCTURE rsparams.

  DATA: rspar_line LIKE LINE OF ft_rspar_tab.

*  Belege stornieren
  rspar_line-selname = 'P_RTSTOR'.
  rspar_line-kind = 'P'.
  rspar_line-low = 'X'.
  APPEND rspar_line TO ft_rspar_tab.
  CLEAR rspar_line.

*  Belege anzeigen
  rspar_line-selname = 'P_RTSHOW'.
  rspar_line-kind = 'P'.
  rspar_line-low = ' '.
  APPEND rspar_line TO ft_rspar_tab.
  CLEAR rspar_line.

*  Belege stornieren
  rspar_line-selname = 'P_RTCOUN'.
  rspar_line-kind = 'P'.
  rspar_line-low = ' '.
  APPEND rspar_line TO ft_rspar_tab.
  CLEAR rspar_line.

*  Storno-Datum
  rspar_line-selname = 'P_STODT'.
  rspar_line-kind = 'P'.
  rspar_line-low = sy-datum.
  APPEND rspar_line TO ft_rspar_tab.
  CLEAR rspar_line.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CHECK_AUTH_FOR_UCOMM
*&---------------------------------------------------------------------*
FORM check_auth_for_ucomm  USING ff_ucomm LIKE sy-ucomm
                                 ff_subrc LIKE sy-subrc.


  DATA: lt_stat TYPE TABLE OF /adesso/ink_stat.

  REFRESH: lt_stat.
  CLEAR:   ff_subrc.

* Prüfen auf Berechtigungsgruppe / Funktion
  LOOP AT gt_stat INTO gs_stat
       WHERE begru = gs_bgus-begru
       AND   ucomm = ff_ucomm.
    APPEND gs_stat TO lt_stat.
  ENDLOOP.

  IF lt_stat[] IS INITIAL.
    ff_subrc = 4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_CONTACT
*&---------------------------------------------------------------------*
FORM create_contact  USING  ff_gpart
                            ff_vkont
                            ff_inkgp
                            ff_category
                            ff_text
                            ff_rugrd.


  DATA: lv_auto_data TYPE bpc01_bcontact_auto .
  DATA: lv_object TYPE bpc_obj.
  DATA: lv_bpcontact TYPE ct_contact.
  DATA: lv_textline TYPE bpc01_text_line.
  DATA: lv_but000   TYPE but000.
  DATA: lv_inrtxt   TYPE inrtxt_kk.

  DATA: lv_partner  TYPE but000-partner.
  DATA: lv_vkont    TYPE fkkvkp-vkont .              "Nuss 08.02.2018
  DATA: lv_class    TYPE ct_cclass,
        lv_activity TYPE ct_activit,
        lv_type     TYPE ct_ctype,
        lv_coming   TYPE ct_coming,
        lv_funcc    TYPE funcc_kk.
  DATA: lv_gpname   TYPE bpc01_text_line.


* Kontaktklasse
  CLEAR gs_cust.
  READ TABLE gt_cust INTO gs_cust
    WITH KEY inkasso_option   = 'CONTACT'
             inkasso_category = 'CLASS'
             inkasso_field = 'CCLASS'
             inkasso_id = '1'.
  IF sy-subrc = 0.
    lv_class = gs_cust-inkasso_value.
  ELSE.
    lv_class = '0200'.
  ENDIF.

* Kontakt-Aktivität
  CLEAR gs_cust.
  READ TABLE gt_cust INTO gs_cust
    WITH KEY inkasso_option   = 'CONTACT'
             inkasso_category = ff_category
             inkasso_field = 'ACTIVITY'
             inkasso_id = '1'.
  IF sy-subrc = 0.
    lv_activity = gs_cust-inkasso_value.
  ELSE.
    lv_activity = '0010'.
  ENDIF.

* Kontakt-Typ
  CLEAR gs_cust.
  READ TABLE gt_cust INTO gs_cust
    WITH KEY inkasso_option   = 'CONTACT'
             inkasso_category = 'TYPE'
             inkasso_field    = 'CTYPE'
             inkasso_id       = '1'.
  IF sy-subrc = 0.
    lv_type = gs_cust-inkasso_value.
  ELSE.
    lv_type = '002'.
  ENDIF.

* Richtung
  CLEAR gs_cust.
  READ TABLE gt_cust INTO gs_cust
    WITH KEY inkasso_option   = 'CONTACT'
             inkasso_category = 'DIRECTION'
             inkasso_field    = 'F_COMING'
             inkasso_id       = '1'.
  IF sy-subrc = 0.
    lv_coming = gs_cust-inkasso_value.
  ELSE.
    lv_coming = '2'.
  ENDIF.

  CLEAR: lv_auto_data.

  lv_vkont   = ff_vkont.
  lv_partner = ff_gpart.

  lv_auto_data-bcontd-mandt       = sy-mandt.
  lv_auto_data-bcontd-partner     = lv_partner.
  lv_auto_data-bcontd-cclass      = lv_class.
  lv_auto_data-bcontd-activity    = lv_activity.
  lv_auto_data-bcontd-ctype       = lv_type.
  lv_auto_data-bcontd-ctdate      = sy-datum.
  lv_auto_data-bcontd-cttime      = sy-uzeit.
  lv_auto_data-bcontd-erdat       = sy-datum.
  lv_auto_data-bcontd-ernam       = sy-uname.
  lv_auto_data-text-langu         = sy-langu.
  lv_auto_data-bcontd_use         = 'X'.

*      Name zum Inkassobüro lesen
  SELECT SINGLE * FROM but000
         INTO lv_but000
         WHERE partner = ff_inkgp.

* Name Inkasso-Büro über Customizing
  CLEAR gs_cust.
  READ TABLE gt_cust INTO gs_cust
    WITH KEY inkasso_option   = 'CONTACT'
             inkasso_category = 'NAME_IGP'
             inkasso_field    = ff_inkgp.

  IF sy-subrc = 0.
    lv_gpname = gs_cust-inkasso_value.
  ELSE.
    CONCATENATE lv_but000-partner
                lv_but000-name_org1
                lv_but000-name_first
                lv_but000-name_last
                lv_but000-name_grp1
                INTO lv_gpname
                SEPARATED BY space.
  ENDIF.

  CASE ff_category.
    WHEN 'RECALL'.
      CONCATENATE TEXT-023
                  ff_vkont
                  TEXT-024
                  lv_gpname
                  INTO lv_textline-tdline
                  SEPARATED BY space.
    WHEN 'WROFF'.
      CONCATENATE TEXT-001
                  ff_vkont
                  TEXT-032
                  INTO lv_textline-tdline
                  SEPARATED BY space.
    WHEN 'SELL'.
      CONCATENATE TEXT-001
                  ff_vkont
                  TEXT-033
                  INTO lv_textline-tdline
                  SEPARATED BY space.
    WHEN 'SELL_DECL'.
      CONCATENATE TEXT-001
                  ff_vkont
                  TEXT-035
                  INTO lv_textline-tdline
                  SEPARATED BY space.
  ENDCASE.

  lv_textline-tdformat = '/'.
  APPEND lv_textline TO lv_auto_data-text-textt.

  IF ff_rugrd NE space.
    SELECT SINGLE inrtxt FROM tfk050dt
           INTO  lv_inrtxt
           WHERE spras = sy-langu
             AND deagr = ff_rugrd.
    IF sy-subrc = 0.
      lv_textline-tdformat = '/'.
      CONCATENATE TEXT-034
                  lv_inrtxt
                  INTO lv_textline-tdline
                  SEPARATED BY space.
      APPEND lv_textline TO lv_auto_data-text-textt.
    ENDIF.
  ENDIF.

  IF ff_text NE space.
    lv_textline-tdformat = '/'.
    lv_textline-tdline = ff_text.
    APPEND lv_textline TO lv_auto_data-text-textt.
  ENDIF.

  lv_object-objrole = 'X00040002001'.
  lv_object-objtype = 'ISUACCOUNT'.
  CONCATENATE lv_vkont lv_partner INTO lv_object-objkey.
  APPEND lv_object TO lv_auto_data-iobjects.

* abweichender FuBa
  CLEAR gs_cust.
  READ TABLE gt_cust INTO gs_cust
    WITH KEY inkasso_option   = 'CONTACT'
             inkasso_category = 'FUBA'.

  IF sy-subrc = 0.
    lv_funcc = gs_cust-inkasso_value.

    CALL FUNCTION lv_funcc
      EXPORTING
        x_upd_online    = 'X'
        x_no_dialog     = 'X'
        x_auto          = lv_auto_data
        x_partner       = lv_partner
      IMPORTING
        y_new_bpcontact = lv_bpcontact
      EXCEPTIONS
        existing        = 1
        foreign_lock    = 2
        number_error    = 3
        general_fault   = 4
        input_error     = 5
        not_authorized  = 6
        OTHERS          = 7.

    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

  ELSE.

    CALL FUNCTION 'BCONTACT_CREATE'
      EXPORTING
        x_upd_online    = 'X'
        x_no_dialog     = 'X'
        x_auto          = lv_auto_data
        x_partner       = lv_partner
      IMPORTING
        y_new_bpcontact = lv_bpcontact
      EXCEPTIONS
        existing        = 1
        foreign_lock    = 2
        number_error    = 3
        general_fault   = 4
        input_error     = 5
        not_authorized  = 6
        OTHERS          = 7.

    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

  ENDIF.
*------

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CREATE_JOB_ABGABE
*&---------------------------------------------------------------------*
FORM create_job_abgabe  TABLES   ft_rspar_tab STRUCTURE rsparams
                        USING    ff_subrc
                                 ff_filen.

  DATA: lf_jobcnt  TYPE btcjobcnt.
  DATA: lf_runtime LIKE sy-tabix.
  DATA: lf_cancel  LIKE sy-input.
  DATA: lf_job_abort LIKE sy-input.
  DATA: ls_joblog TYPE tbtc5.
  DATA: lt_joblog TYPE TABLE OF tbtc5.
  DATA: ls_valtab TYPE btctxuncod.
  DATA: lt_valtab LIKE TABLE OF ls_valtab.
  DATA: lf_choice LIKE sy-tabix.

  DATA: lf_abort LIKE	tbtcv-abort.
  DATA: lf_fin   LIKE	tbtcv-fin.
  DATA: lf_run   LIKE	tbtcv-run.

  CONSTANTS: co_jobname TYPE btcjob VALUE 'RFKKCOL2_INK_ABGABE'.

  ff_subrc = 0.

  CALL FUNCTION 'JOB_OPEN'
    EXPORTING
      jobname          = co_jobname
    IMPORTING
      jobcount         = lf_jobcnt
    EXCEPTIONS
      cant_create_job  = 1
      invalid_job_data = 2
      jobname_missing  = 3
      OTHERS           = 4.
  IF sy-subrc <> 0.
    MESSAGE TEXT-e15 TYPE 'E'.
  ENDIF.

  CHECK sy-subrc = 0.

  PERFORM fill_rspar_rfkkcol2
          TABLES ft_rspar_tab.

  SUBMIT rfkkcol2  TO SAP-SPOOL
                   WITHOUT SPOOL DYNPRO
                   VIA SELECTION-SCREEN
                   VIA JOB co_jobname NUMBER lf_jobcnt
                   WITH SELECTION-TABLE ft_rspar_tab
                   AND RETURN.

  CASE sy-subrc.
    WHEN 0.

      CALL FUNCTION 'JOB_CLOSE'
        EXPORTING
          jobcount             = lf_jobcnt
          jobname              = co_jobname
          strtimmed            = 'X'
        EXCEPTIONS
          cant_start_immediate = 1
          invalid_startdate    = 2
          jobname_missing      = 3
          job_close_failed     = 4
          job_nosteps          = 5
          job_notex            = 6
          lock_failed          = 7
          OTHERS               = 8.
      IF sy-subrc <> 0.
        MESSAGE TEXT-e15 TYPE 'E'.
      ENDIF.

      WAIT UP TO 10 SECONDS.
      DO 120 TIMES.

        CALL FUNCTION 'SHOW_JOBSTATE'
          EXPORTING
            jobcount         = lf_jobcnt
            jobname          = co_jobname
          IMPORTING
            aborted          = lf_abort
            finished         = lf_fin
            running          = lf_run
          EXCEPTIONS
            jobcount_missing = 1
            jobname_missing  = 2
            job_notex        = 3
            OTHERS           = 4.

        IF sy-subrc <> 0.
          ff_subrc = 4.
          MESSAGE TEXT-e15 TYPE 'E'.
          EXIT.
        ENDIF.

        IF lf_abort = 'X'.
          ff_subrc = 4.
          EXIT.
        ENDIF.

        IF lf_fin = 'X'.
          COMMIT WORK AND WAIT.
          EXIT.
        ENDIF.

        WAIT UP TO 10 SECONDS.
      ENDDO.

      REFRESH lt_joblog.
      REFRESH lt_valtab.
      CALL FUNCTION 'BP_JOBLOG_READ'
        EXPORTING
          client                = sy-mandt
          jobcount              = lf_jobcnt
          jobname               = co_jobname
        TABLES
          joblogtbl             = lt_joblog
        EXCEPTIONS
          cant_read_joblog      = 1
          jobcount_missing      = 2
          joblog_does_not_exist = 3
          joblog_is_empty       = 4
          joblog_name_missing   = 5
          jobname_missing       = 6
          job_does_not_exist    = 7
          OTHERS                = 8.

      IF sy-subrc <> 0.
* Implement suitable error handling here
      ELSE.
        LOOP AT lt_joblog INTO ls_joblog.
          ls_valtab = ls_joblog-text.
          APPEND ls_valtab TO lt_valtab.
          IF ls_joblog-msgid = '>3' AND
             ls_joblog-msgno = '515'.
            ff_filen = ls_joblog-msgv1.
          ENDIF.
        ENDLOOP.

        CALL FUNCTION 'POPUP_WITH_TABLE_DISPLAY'
          EXPORTING
            endpos_col   = 80
            endpos_row   = 20
            startpos_col = 5
            startpos_row = 5
            titletext    = 'Abgabedateien'
          IMPORTING
            choise       = lf_choice
          TABLES
            valuetab     = lt_valtab
          EXCEPTIONS
            break_off    = 1
            OTHERS       = 2.

        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.

      ENDIF.

    WHEN 4.
      ff_subrc = 4.
      MESSAGE TEXT-e17 TYPE 'E'.
    WHEN OTHERS.
      ff_subrc = 4.
      MESSAGE TEXT-e15 TYPE 'E'.
  ENDCASE.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  SET_STATUS_ICON
*&---------------------------------------------------------------------*
FORM set_status_icon  USING    fp_agsta
                               fp_status.

  CASE fp_agsta.

    WHEN ' '.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_LED_GREEN'
          info                  = TEXT-a00
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '01'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_RELEASE'
          info                  = TEXT-a01
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '02'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_PROPRIETARY'
          info                  = TEXT-a02
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '03'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_TRANSFER'
          info                  = TEXT-a03
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '04'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_RELATION'
          info                  = TEXT-a04
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '05'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_STORNO'
          info                  = TEXT-a05
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '06'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_WF_WORKITEM_OL'
          info                  = TEXT-a06
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '07'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_MONEY'
          info                  = TEXT-a07
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '08'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_MONEY'
          info                  = TEXT-a08
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '09'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_SYSTEM_UNDO'
          info                  = TEXT-a09
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '10'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_PAYMENT'
          info                  = TEXT-a10
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '11'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_MONEY'
          info                  = TEXT-a11
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '12'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_STATUS_BOOKED'
          info                  = TEXT-a12
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '13'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_STATUS_PARTLY_BOOKED'
          info                  = TEXT-a13
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '20'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_STATUS_REVERSE'
          info                  = TEXT-a20
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '30'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_ALLOW'
          info                  = TEXT-a30
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '31'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_REJECT'
          info                  = TEXT-a31
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '32'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_REJECT'
          info                  = TEXT-a32
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '97'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_AVAILABILITY_CHECK'
          info                  = TEXT-a97
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '98'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_DISPLAY'
          info                  = TEXT-a98
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '99'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_SET_STATE'
          info                  = TEXT-a99
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

*----------------------------------------------------------------------
* Hier auch Status Ausbuchungsmonitor
* Vormerkung Ausbuchung
    WHEN 'W01'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_SET_STATE'
*         TEXT                  = ' '
          info                  = TEXT-w01
*         ADD_STDINF            = 'X'
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

* Zur Prüfung
    WHEN 'W02'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_ACTION_FAULT'
*         TEXT                  = ' '
          info                  = TEXT-w02
*         ADD_STDINF            = 'X'
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.


* Status Übergabe an Amor --> Bereit zur Genehmigung
    WHEN 'W10'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_COPY_OBJECT'
*         TEXT                  = ' '
          info                  = TEXT-w10
*         ADD_STDINF            = 'X'
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

* Status Genehmigung 1
    WHEN 'W11'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_INSERT_ROW'
*         TEXT                  = ' '
          info                  = TEXT-w11
*         ADD_STDINF            = 'X'
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

* Status Genehmigt
    WHEN 'W12'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_INSERT_MULTIPLE_LINES'
*         TEXT                  = ' '
          info                  = TEXT-w12
*         ADD_STDINF            = 'X'
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

* Status Ablehnung Genehmigung
    WHEN 'W13'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_DELETE_ROW'
*         TEXT                  = ' '
          info                  = TEXT-w13
*         ADD_STDINF            = 'X'
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

* Status Ausgebucht
    WHEN 'W20'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_STATUS_REVERSE'
*         TEXT                  = ' '
          info                  = TEXT-w20
*         ADD_STDINF            = 'X'
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.


* Hier auch für Info vom InkDL
* Status für Ankauf
    WHEN 'A'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_CONVERT'
*         TEXT                  = ' '
          info                  = TEXT-aia
*         ADD_STDINF            = 'X'
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

* Status für Erneute Bearbeitung
    WHEN 'B'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_LAYOUT_CONTROL'
*         TEXT                  = ' '
          info                  = TEXT-aeb
*         ADD_STDINF            = 'X'
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.


* Status für Abbruch SEG
    WHEN 'C'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_FAILURE'
*         TEXT                  = ' '
          info                  = TEXT-aic
*         ADD_STDINF            = 'X'
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

* Status für Info InkDl
    WHEN 'I'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_HINT'
*         TEXT                  = ' '
          info                  = TEXT-aii
*         ADD_STDINF            = 'X'
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

    WHEN 'DOCU'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_TEXT_ACT'
          info                  = TEXT-doc
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN 'NODOCU'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_TEXT_INA'
          info                  = TEXT-doc
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN 'CANCEL'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_CANCEL'
          info                  = TEXT-can
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

*----------------------------------------------------------------------
*    Allgeminer Fehler
    WHEN 'ER'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_LED_RED'
          info                  = TEXT-aer
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UCOM_HISTORY
*&---------------------------------------------------------------------*
FORM ucom_history .

  DATA: rt_gpart TYPE RANGE OF gpart_kk.
  DATA: rt_vkont TYPE RANGE OF vkont_kk.
  DATA: rs_gpart LIKE LINE OF rt_gpart.
  DATA: rs_vkont LIKE LINE OF rt_vkont.
  DATA: lt_dfkkcollh TYPE TABLE OF dfkkcollh.
  DATA: ls_sort TYPE slis_sortinfo_alv.
  DATA: lt_sort TYPE slis_t_sortinfo_alv.

  REFRESH: rt_gpart.
  REFRESH: rt_vkont.
  REFRESH: lt_dfkkcollh.
  REFRESH: lt_sort.

  LOOP AT t_header INTO s_header WHERE sel IS NOT INITIAL.
    rs_gpart-option = 'EQ'.
    rs_gpart-sign   = 'I'.
    rs_gpart-low    = s_header-gpart.
    APPEND rs_gpart TO rt_gpart.

    rs_vkont-option = 'EQ'.
    rs_vkont-sign   = 'I'.
    rs_vkont-low    = s_header-vkont.
    APPEND rs_vkont TO rt_vkont.

  ENDLOOP.

  IF rt_gpart[] IS INITIAL AND
     rt_vkont IS INITIAL.
    MESSAGE TEXT-e20 TYPE 'E'.
  ENDIF.


  SELECT * FROM dfkkcollh INTO TABLE lt_dfkkcollh
           WHERE gpart IN rt_gpart
           AND   vkont IN rt_vkont.

  CLEAR ls_sort.
  ls_sort-spos = 1.
  ls_sort-fieldname = 'GPART'.
  ls_sort-up = 'X'.
  APPEND ls_sort TO lt_sort.

  CLEAR ls_sort.
  ls_sort-spos = 2.
  ls_sort-fieldname = 'VKONT'.
  ls_sort-up = 'X'.
  APPEND ls_sort TO lt_sort.

  CLEAR ls_sort.
  ls_sort-spos = 3.
  ls_sort-fieldname = 'OPBEL'.
  ls_sort-up = 'X'.
  APPEND ls_sort TO lt_sort.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program    = g_repid
      i_grid_title          = 'Inkasso Historie'
      i_structure_name      = 'DFKKCOLLH'
      it_sort               = lt_sort
      i_screen_start_column = 5
      i_screen_start_line   = 5
      i_screen_end_column   = 150
      i_screen_end_line     = 20
    TABLES
      t_outtab              = lt_dfkkcollh
    EXCEPTIONS
      program_error         = 1
      OTHERS                = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UCOM_INFO_INKGP
*&---------------------------------------------------------------------*
FORM ucom_info_inkgp TABLES ft_vkont LIKE gt_vkont.

*  DATA: lt_ink_infi TYPE TABLE OF /adesso/ink_infi.
*  DATA: ls_sort TYPE slis_sortinfo_alv.
*  DATA: lt_sort TYPE slis_t_sortinfo_alv.
*
*  DATA: lt_fc_infi TYPE slis_t_fieldcat_alv.
*  DATA: ls_fc_infi TYPE slis_fieldcat_alv.
*  DATA: ls_layout  TYPE slis_layout_alv.
*
*  REFRESH: lt_ink_infi.
*  REFRESH: lt_sort.

  DATA: lv_answer TYPE c.

  IF ft_vkont[] IS INITIAL.
    MESSAGE TEXT-e20 TYPE 'E'.
  ENDIF.

  CALL FUNCTION 'POPUP_FOR_INTERACTION'
    EXPORTING
      headline       = TEXT-027
      text1          = TEXT-028
      button_1       = TEXT-029
      button_2       = TEXT-030
      button_3       = TEXT-031
    IMPORTING
      button_pressed = lv_answer.

  CASE lv_answer.
    WHEN '1'.
      PERFORM show_ink_infi TABLES ft_vkont.
    WHEN '2'.
      PERFORM show_dfkkcoli_log TABLES ft_vkont.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_ICON_TEXT
*&---------------------------------------------------------------------*
FORM create_icon_text  USING ff_icon
                             ff_text
                       CHANGING ff_field.


  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name                  = ff_icon
      info                  = ff_text
    IMPORTING
      result                = ff_field
    EXCEPTIONS
      icon_not_found        = 1
      outputfield_too_short = 2
      OTHERS                = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_AGSTA_DFKKCOLL
*&---------------------------------------------------------------------*
FORM set_agsta_dfkkcoll  USING ff_opbel ff_inkps ff_mode ff_agsta ff_xsold.

  DATA: ls_dfkkcoll TYPE dfkkcoll.
  DATA: lt_dfkkcoll TYPE STANDARD TABLE OF dfkkcoll.

  REFRESH: lt_dfkkcoll.

* get dfkkcoll
  SELECT SINGLE * FROM dfkkcoll
         INTO ls_dfkkcoll
         WHERE opbel = ff_opbel
         AND   inkps = ff_inkps.

  IF sy-subrc = 0.
    ls_dfkkcoll-agsta = ff_agsta.
    ls_dfkkcoll-xsold = ff_xsold.
    APPEND ls_dfkkcoll TO lt_dfkkcoll.
  ENDIF.
  CHECK lt_dfkkcoll[] IS NOT INITIAL.

  CALL FUNCTION 'FKK_DB_DFKKCOLL_MODE'
    EXPORTING
      i_mode    = ff_mode
    TABLES
      t_fkkcoll = lt_dfkkcoll.

* insert collection agency history table
  IF sy-subrc = 0.
    PERFORM create_history TABLES lt_dfkkcoll.
    COMMIT WORK.
  ELSE.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CHECK_DOCU_EXISTS
*&---------------------------------------------------------------------*
FORM check_docu_exists  USING fs_header TYPE /adesso/inkasso_header
                              ff_exists.

  DATA: ls_cust   TYPE /adesso/ink_cust.  "Customizing allgemein
  DATA: lv_object TYPE thead-tdobject.
  DATA: lv_id     TYPE thead-tdid.
  DATA: lv_tdname TYPE tdobname.

* Dokumentation Ausbuchung vorhanden ?
  CLEAR ff_exists.
  CLEAR ls_cust.
  READ TABLE gt_cust INTO ls_cust
       WITH KEY inkasso_option   = 'AUSBUCHUNG'
                inkasso_category = 'DOCU'
                inkasso_field    = 'TDOBJECT'.

  IF sy-subrc = 0.
    MOVE ls_cust-inkasso_value TO lv_object.
  ENDIF.

  CLEAR ls_cust.
  READ TABLE gt_cust INTO ls_cust
       WITH KEY inkasso_option   = 'AUSBUCHUNG'
                inkasso_category = 'DOCU'
                inkasso_field    = 'TDID'.

  IF sy-subrc = 0.
    MOVE ls_cust-inkasso_value TO lv_id.
  ENDIF.

  CONCATENATE fs_header-gpart '_'
              fs_header-vkont '_'
               '001'
              INTO lv_tdname.

*  Prüfen, ob Docu existiert
  SELECT SINGLE @abap_true FROM stxh
         WHERE tdobject = @lv_object
         AND   tdname   = @lv_tdname
         AND   tdid     = @lv_id
         AND   tdspras  = @sy-langu
         INTO  @DATA(docu_exists).

  ff_exists = docu_exists.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UCOM_FINISHED_HIER
*&---------------------------------------------------------------------*
FORM ucom_finished_hier  USING ff_ucomm LIKE sy-ucomm
                               ff_gplocked LIKE gv_gplocked.

  DATA: ls_dfkkcoll TYPE dfkkcoll.
  DATA: ls_tfk050at TYPE tfk050at.
  DATA: lh_tabix LIKE sy-tabix.
  DATA: li_tabix LIKE sy-tabix.
  DATA: lf_nochange TYPE sy-tabix.
  DATA: ls_header TYPE /adesso/inkasso_header.
  DATA: ls_items  TYPE /adesso/inkasso_items.
  DATA: lf_agstatxt TYPE val_text.
  DATA: lf_nochg_stat TYPE sy-tabix.

  DATA: itab_dfkkcoll LIKE TABLE OF dfkkcoll WITH HEADER LINE.
  DATA: istr_dfkkcoll   TYPE dfkkcoll.
  DATA: itab_undo     TYPE TABLE OF /adesso/inkasso_items WITH HEADER LINE.
  DATA: lf_agsta      LIKE dfkkcoll-agsta.
  DATA: lf_agdat      LIKE dfkkcoll-agdat.
  DATA: mode_delete   VALUE 'D'.

  DATA: ls_wo_mon     TYPE /adesso/wo_mon.
  DATA: ls_wo_mon_h   TYPE /adesso/wo_mon_h.
  DATA: lf_rc         TYPE syst_subrc.

  CLEAR:   lf_nochange.
  CLEAR:   lf_nochg_stat.
  CLEAR:   ff_gplocked.

* Für Hierarchische Liste
  LOOP AT t_header INTO ls_header
       WHERE sel IS NOT INITIAL.

    lh_tabix = sy-tabix.

* VK für Bearbeitung gesperrt ?
    IF ls_header-locked IS NOT INITIAL.
      ff_gplocked = 'X'.
      CONTINUE.
    ENDIF.

    REFRESH itab_dfkkcoll.
    REFRESH itab_undo.
    REFRESH ht_enqtab.
    CLEAR error.

    LOOP AT t_items INTO ls_items
         WHERE gpart = ls_header-gpart
         AND   vkont = ls_header-vkont
         AND   sel   IS NOT INITIAL.

      CLEAR: lf_agsta, lf_agdat.
* check that the status did not change
      SELECT SINGLE agsta agdat FROM dfkkcoll
             INTO (lf_agsta, lf_agdat)
             WHERE opbel = ls_items-opbel
             AND   inkps = ls_items-inkps.

      CHECK ls_items-agsta NE space.

* Berechtigung für Status ?
      CLEAR gs_stat.
      READ TABLE gt_stat INTO gs_stat
           WITH KEY begru = gs_bgus-begru
                    ucomm = ff_ucomm
                    agsta = ls_items-agsta.

      IF sy-subrc NE 0.
        CLEAR gs_stat.
        ADD 1 TO lf_nochange.
        CONTINUE.
      ENDIF.

      READ TABLE itab_dfkkcoll
                WITH KEY opbel = ls_items-opbel
                         inkps = ls_items-inkps.

      IF sy-subrc NE 0.
        MOVE-CORRESPONDING: ls_items TO itab_dfkkcoll.
        APPEND itab_dfkkcoll.
      ENDIF.

      READ TABLE itab_undo
                WITH KEY opbel = ls_items-opbel
                         inkps = ls_items-inkps.
      IF sy-subrc NE 0.
        MOVE-CORRESPONDING ls_items TO itab_undo.
        APPEND itab_undo.
      ENDIF.

      READ TABLE ht_enqtab WITH KEY gpart = ls_items-gpart.
      IF sy-subrc NE 0.
        ht_enqtab-gpart = ls_items-gpart.
        APPEND ht_enqtab.
      ENDIF.

    ENDLOOP.

    IF error NE 0.
      ADD 1 TO lf_nochg_stat.
      CONTINUE.
    ENDIF.

    CHECK itab_dfkkcoll[] IS NOT INITIAL.

* -- Enqueue the business partner before changing table DFKKOP ---------
    PERFORM dfkkop_enqueue.

    CALL FUNCTION 'FKK_DB_DFKKCOLL_MODE'
      EXPORTING
        i_mode    = mode_delete
      TABLES
        t_fkkcoll = itab_dfkkcoll
      EXCEPTIONS
        error     = 1
        OTHERS    = 2.

    IF sy-subrc <> 0.
      MESSAGE e845(>3) WITH 'DFKKCOLL'.
    ELSE.
*    insert collection agency history table w/ status finished
      istr_dfkkcoll-agsta = 'XX'.
      MODIFY itab_dfkkcoll FROM istr_dfkkcoll
             TRANSPORTING agsta
             WHERE agsta NE space.
      PERFORM create_history TABLES itab_dfkkcoll.
      COMMIT WORK.
    ENDIF.

    LOOP AT itab_undo.
      UPDATE dfkkop SET inkps = 0
                    WHERE opbel = itab_undo-opbel
                    AND   inkps = itab_undo-inkps.

      LOOP AT t_items INTO ls_items
                       WHERE opbel = itab_undo-opbel
                         AND inkps = itab_undo-inkps.

        CLEAR ls_wo_mon.
        SELECT SINGLE * FROM /adesso/wo_mon
               INTO  ls_wo_mon
               WHERE opbel = ls_items-opbel
               AND   opupw = ls_items-opupw
               AND   opupk = ls_items-opupk
               AND   opupz = ls_items-opupz.

        IF sy-subrc = 0.
          MOVE-CORRESPONDING ls_wo_mon TO ls_wo_mon_h.
          CLEAR lf_rc.
          PERFORM update_womon_wohist
                  USING ls_wo_mon
                        ls_wo_mon_h
                        c_mode_del
                        lf_rc.
        ENDIF.

        li_tabix = sy-tabix.

        CLEAR ls_items-inkgp.
        ls_items-agsta = space.

        CLEAR ls_items-aggrd.
        CLEAR ls_items-inkps.

*   ICON auf erneut ptüfen setzen
        PERFORM set_status_icon USING 'CANCEL' ls_items-status.
        MODIFY t_items FROM ls_items INDEX li_tabix.

      ENDLOOP.

    ENDLOOP.

    COMMIT WORK.

* --- Dequeue all business partner ------------------------------------
    CALL FUNCTION 'FKK_OPEN_ITEM_DEQUEUE'.

    CLEAR s_header-inkgp.
    CLEAR s_header-inkname.

    ls_header-agsta = space.
    CLEAR ls_header-agdat.

*   Mahnsperre löschen
    PERFORM del_mahnsperre  USING ls_header-gpart ls_header-vkont.
    CLEAR ls_header-lockr.

*   ICON auf Vorgemerkt setzen
    PERFORM set_status_icon USING 'CANCEL' ls_header-status.
    MODIFY t_header FROM ls_header INDEX lh_tabix.

  ENDLOOP.

  IF lf_nochange > 0.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-f06
        textline2 = TEXT-e04.
  ENDIF.

  IF lf_nochg_stat > 0.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-f05
        textline2 = TEXT-e09.
  ENDIF.

ENDFORM.
