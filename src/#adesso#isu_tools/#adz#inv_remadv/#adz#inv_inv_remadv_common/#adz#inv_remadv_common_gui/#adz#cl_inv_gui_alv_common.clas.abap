CLASS /adz/cl_inv_gui_alv_common DEFINITION ABSTRACT
  PUBLIC
  CREATE PUBLIC .


  PUBLIC SECTION.
    INTERFACES /adz/if_inv_gui_common.

    DATA  mv_titel_param1  TYPE string READ-ONLY.
    DATA  mt_excl_functions    TYPE slis_t_extab READ-ONLY.

    CLASS-METHODS:
      get_fc_standard RETURNING VALUE(rt_buttons) TYPE ttb_button.

    METHODS:
      constructor    IMPORTING iv_repid TYPE repid
                               iv_vari  TYPE slis_vari OPTIONAL,
      init_display   IMPORTING
                       it_funcnames_excl TYPE  stringtab  OPTIONAL
                       if_event_handler  TYPE REF TO /adz/if_inv_salv_table_evt_hlr
                       ib_use_pf_status  TYPE abap_bool DEFAULT abap_false
                       iv_vari           TYPE slis_vari OPTIONAL
                       ib_use_grid_xt    TYPE abap_bool DEFAULT abap_true
                       ib_show_all_cols  TYPE abap_bool DEFAULT abap_false
                     CHANGING
                       crt_data          TYPE REF TO data,
      display,

      get_exclude_functions
        IMPORTING it_funcnames        TYPE  stringtab
        RETURNING VALUE(rt_funcnames) TYPE  stringtab,

      handle_toolbar FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object e_interactive,
*      onf4 FOR EVENT onf4 OF cl_gui_alv_grid
*        IMPORTING
*          e_fieldname
*          e_fieldvalue
*          es_row_no
*          er_event_data
*          et_bad_cells
*          e_display.

      update_table FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING er_data_changed
                  e_onf4
                  e_onf4_before
                  e_onf4_after,

      execute_user_command
        IMPORTING iv_user_cmd TYPE syst_ucomm.


  PROTECTED SECTION.
    DATA mv_repid TYPE  repid.
    DATA mv_vari  TYPE  slis_vari.
    DATA mrt_data TYPE  REF TO data.
    DATA mo_grid  TYPE  REF TO cl_gui_alv_grid.
    METHODS :
      get_column_definition ABSTRACT
        RETURNING VALUE(rt_fieldcat) TYPE lvc_t_fcat,
      get_sort
        RETURNING VALUE(rt_sort) TYPE lvc_t_sort.
    .
  PRIVATE SECTION.

    METHODS prepare_autotext
      RETURNING
        VALUE(rt_autotext) TYPE alv_auto_text_t .
    METHODS set_colors
      IMPORTING
        !is_data          TYPE any
      RETURNING
        VALUE(crt_colors) TYPE lvc_t_scol .
ENDCLASS.



CLASS /adz/cl_inv_gui_alv_common IMPLEMENTATION.


  METHOD /adz/if_inv_gui_common~set_nr_of_nows.
    mv_titel_param1 = iv_nr_rows.
  ENDMETHOD.


  METHOD constructor.
    mv_repid = iv_repid.
    mv_vari  = iv_vari.
  ENDMETHOD.


  METHOD display.
    mo_grid->set_ready_for_input( EXPORTING i_ready_for_input = 1 ).
  ENDMETHOD.

  METHOD get_fc_standard.
    DATA(lc) = NEW  cl_gui_alv_grid( i_parent = cl_gui_custom_container=>screen8 ).
    rt_buttons = VALUE #(
      ( butn_type = 3 ) " append a separator to normal toolbar
      ( function = cl_gui_alv_grid=>MC_FC_DETAIL    icon = icon_select_detail text = '' quickinfo = 'Details   '   )
      ( function = cl_gui_alv_grid=>mc_fc_view_grid icon = icon_table_settings quickinfo = 'Bericht aufrufen...'   ) "hk = 'B
      ( function = 'ZEFRESH' icon = icon_refresh    text = '' quickinfo = 'Auffrischen'  )
      ( butn_type = 3 ) " append a separator to normal toolbar
      ( function = '&ALL_U'  icon = icon_select_all   text = '' quickinfo = 'Alle markieren' )
      ( function = '&SAL_U'  icon = icon_deselect_all text = '' quickinfo = 'Alle Mark. löschen' )
      ( function = 'CHECK'   icon = icon_display_more text = 'Markierte Auswählen'  quickinfo = 'Markierte Einträge auswählen'  )
      ( function = lc->mc_fc_sort_asc  icon = icon_sort_up   text = ''  quickinfo = 'Sortieren aufsteig.' ) "hk = 'I
      ( function = lc->mc_fc_sort_dsc  icon = icon_sort_down text = ''  quickinfo = 'Sortieren absteigend' ) "hk = 'O
      ( function = lc->mc_fc_find      icon = icon_search    text = ''  quickinfo = 'Suchen'    ) "hk = 'F
      ( function = lc->mc_fc_filter    icon = icon_filter    text = ''  quickinfo = 'Filter setzen'    ) "hk = 'K
      ( function = lc->mc_fc_delete_filter icon = icon_filter_undo text = '' quickinfo = 'Filter löschen' )  "hk = 'L
      ( function = lc->mc_fc_sum        icon = icon_sum text = '' quickinfo = 'Summen'  ) "hk = 'S
      ( butn_type = 3 ) " append a separator to normal toolbar
      ( function = lc->mc_fc_subtot     icon = icon_intermediate_sum text = '' quickinfo = 'Zwischensummen' ) "hk = 'Z
      ( function = lc->mc_fc_print_prev icon = icon_layout_control text = ''   quickinfo = 'Druckvorschau' ) "hk = 'R
      ( function = lc->mc_fc_pc_file    icon = icon_export text = ''           quickinfo = 'Lokale Datei...' ) "hk = 'D )
      ( butn_type = 3 )
      ( function = cl_gui_alv_grid=>mc_fc_current_variant icon = icon_alv_variants        quickinfo = 'Layout ändern...' )
      ( function = cl_gui_alv_grid=>mc_fc_load_variant    icon = icon_alv_variant_choose  quickinfo = 'Layout auswählen...' )
      ( function = cl_gui_alv_grid=>mc_fc_save_variant    icon = icon_alv_variant_save    quickinfo = 'Layout sichern...' )
      ( butn_type = 3 )
    ).
  ENDMETHOD.

  METHOD execute_user_command.
    " wegen cl_alv_grid_xt nicht mehr notwendig
    " mo_grid->raise_event( i_ucomm = iv_user_cmd ).
  ENDMETHOD.

  METHOD get_exclude_functions.
* Welche Buttons sollen angezeigt werden
    DATA lt_usergroups TYPE TABLE OF usgroups.
    DATA lt_inv_usr TYPE TABLE OF /adz/inv_usr.
    DATA ls_inv_usr TYPE /adz/inv_usr.
    DATA lt_inv_func TYPE TABLE OF /adz/inv_func.
    DATA lv_allow_all TYPE c.
    CLEAR lt_inv_func.
    CALL FUNCTION 'SUSR_USER_GROUP_GROUPS_GET'
      EXPORTING
        bname      = sy-uname
*       WITH_TEXT  = ' '
      TABLES
        usergroups = lt_usergroups.

    IF lt_usergroups IS NOT INITIAL.
      SELECT * FROM /adz/inv_usr INTO TABLE lt_inv_usr FOR ALL ENTRIES IN lt_usergroups WHERE gruppe = lt_usergroups-usergroup.
      LOOP AT lt_inv_usr INTO ls_inv_usr.
        SELECT * FROM /adz/inv_func APPENDING TABLE lt_inv_func WHERE functions = ls_inv_usr-functions.
        IF ls_inv_usr-functions = 9.
          lv_allow_all = 'X'.
        ENDIF.
      ENDLOOP.
    ENDIF.

*# vorübergehend ausblenden
    APPEND 'STATISTIK' TO rt_funcnames.

    IF lv_allow_all <> 'X' AND sy-sysid <> 'E10'.
      LOOP AT it_funcnames INTO DATA(lv_funcname).
        IF NOT ( line_exists( lt_inv_func[ function = lv_funcname ] ) ).
          APPEND lv_funcname TO rt_funcnames.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD get_sort.
    CLEAR rt_sort.
  ENDMETHOD.


  METHOD handle_toolbar.
    " look to super
  ENDMETHOD.


  METHOD init_display.
    "DATA lv_container TYPE scrfname VALUE 'CL_INV_GUI_ALV_COMMON_XYZ'.
    DATA lo_custom_container TYPE REF TO cl_gui_custom_container.
    DATA ls_layout           TYPE lvc_s_layo.
    DATA lr_line             TYPE REF TO data.

    FIELD-SYMBOLS <ct_data> TYPE ANY TABLE.
    FIELD-SYMBOLS <fs_data_c> TYPE any.
    FIELD-SYMBOLS <fs_color> TYPE any.
    "lr_columns    TYPE REF TO cl_salv_columns.

    ASSIGN crt_data->* TO <ct_data>.

    CREATE DATA lr_line LIKE LINE OF <ct_data>.
    ASSIGN lr_line->* TO <fs_data_c>.

    DATA(lv_anz) = lines( <ct_data> ).
    DATA(lv_title) = |{ mv_repid } Belege:{ lv_anz }|.
    "SET TITLEBAR 'STANDARD_TITEL' with lv_anz.
    mv_titel_param1 = lv_anz.
    DATA(lt_autotext) = prepare_autotext( ).

    IF 1 > 0.
      lo_custom_container = NEW cl_gui_custom_container(
         container_name = 'CL_INV_GUI_ALV_COMMON_XYZ'
         style  = cl_gui_custom_container=>ws_maximizebox ).
      IF ib_use_grid_xt EQ abap_true.
        mo_grid  = NEW cl_alv_grid_xt( i_parent = lo_custom_container it_auto_text_det  = lt_autotext  i_optimize_output = '' i_toolbar_manager = '' ).
      ELSE.
        mo_grid  = NEW cl_gui_alv_grid( i_parent = lo_custom_container  ).
      ENDIF.
    ELSE.
      mo_grid  = NEW cl_alv_grid_xt( i_parent = cl_gui_custom_container=>screen0  it_auto_text_det  = lt_autotext ).
    ENDIF.

    DATA(lt_fieldcat) = get_column_definition(  ).

    " §1.Set status of all cells to editable using the layout structure.
    ls_layout-edit = ''.
    ls_layout-no_toolbar = ib_use_pf_status.  " Grid - Toolbar oder PF-STATUS-Toolbar (drüber)
    "ls_layout-grid_title = 'Flights'(100).
    " allow to select multiple lines
    ls_layout-sel_mode = 'A'.
    ls_layout-zebra = 'X'.
    ls_layout-excp_led = ''. "lights_fieldname
    IF line_exists( lt_fieldcat[ fieldname = 'LIGHTS' ] ).
      ls_layout-excp_fname = 'LIGHTS'.
    ENDIF.
    IF line_exists( lt_fieldcat[ fieldname = 'COLOR' ] ).
      ls_layout-ctab_fname = 'COLOR'.
    ENDIF.
*    ls_layout-col_opt = 'X'.
    "ls_layout-box_fname = 'SEL'.


    DATA ls_variant TYPE  disvariant.
    ls_variant-report  = mv_repid.
    ls_variant-variant = COND #( WHEN iv_vari IS NOT INITIAL THEN iv_vari ELSE mv_vari ).
    IF ib_show_all_cols EQ abap_true.
      CLEAR ls_variant-variant.
    ENDIF.

    DATA : lt_color TYPE STANDARD TABLE OF lvc_s_scol.
    LOOP AT <ct_data> ASSIGNING <fs_data_c>.
      ASSIGN COMPONENT 'COLOR' OF STRUCTURE <fs_data_c> TO <fs_color>.
      IF sy-subrc EQ 0.
        <fs_color> = set_colors( <fs_data_c> ).
      ENDIF.
    ENDLOOP.
    " User Funktionen ausblenden
    mt_excl_functions = VALUE #( FOR ls IN it_funcnames_excl ( fcode = ls ) ).

    DATA(lt_double_func) = VALUE stringtab(
       ( |&ETA| ) " Details
       "( |&EB9| )  " Bericht aufrufen
       "( |ZEFRESH| ) " 'Auffrischen'
       ( |&OUP| ) "Sortieren aufsteig.
       ( |&ODN| ) "Sortieren absteigend
       ( |&ILT| ) "Filter setzen
       ( |&ILD| ) "Filter löschen
       ( |&UMC| ) "Summen
       ( |&SUM| ) "Zwischensummen
       ( |&RNT_PREV| ) "Druckvorschau
       ( |%PC|  ) "Lokale Datei...
       ( |&OL0| ) "Layout ändern...
       ( |&OAD| ) "Layout auswählen...
       ( |&AVE| ) "Layout sichern...
       ).
    IF ib_use_pf_status = abap_false.
      " bei pf_status wird die Ausblendung nicht benötigt.
      " upd: aktuell werden keine standard funktionen mehr anzeigt => ausblenden nicht notwendig
      IF 1 = 0.
        mt_excl_functions = VALUE #( BASE mt_excl_functions FOR ls IN lt_double_func ( fcode = ls )  ).
      ENDIF.
    ENDIF.


    DATA(lt_std_func_excl) = VALUE ui_functions(
     ( cl_gui_alv_grid=>mc_fc_refresh )
     ( cl_gui_alv_grid=>mc_fc_print_back )
     ( cl_gui_alv_grid=>mc_fc_view_grid )
     ( cl_gui_alv_grid=>mc_fc_view_excel )
     ( cl_gui_alv_grid=>mc_fc_check )
     ( cl_gui_alv_grid=>mc_fc_loc_cut )
     ( cl_gui_alv_grid=>mc_fc_loc_copy )
     ( cl_gui_alv_grid=>mc_mb_paste )
     ( cl_gui_alv_grid=>mc_fc_loc_paste )
     ( cl_gui_alv_grid=>mc_fc_loc_paste_new_row )
     ( cl_gui_alv_grid=>mc_fc_loc_undo )
     ( cl_gui_alv_grid=>mc_fc_loc_append_row )
     ( cl_gui_alv_grid=>mc_fc_loc_insert_row )
     ( cl_gui_alv_grid=>mc_fc_loc_delete_row )
     ( cl_gui_alv_grid=>mc_fc_loc_copy_row )
     ( cl_gui_alv_grid=>mc_fc_view_lotus )
     ( cl_gui_alv_grid=>mc_fc_view_crystal )
     ( cl_gui_alv_grid=>mc_fc_info )
     ( cl_gui_alv_grid=>mc_fc_graph )
     ).
    " upd: mit screen0 als container werden gar keine standard funktionen mehr anzeigt
    CLEAR lt_std_func_excl.
    DATA(lt_sort) = get_sort( ).

    mo_grid->set_table_for_first_display(
       EXPORTING
*        i_buffer_active               =                  " Pufferung aktiv
*        i_bypassing_buffer            =                  " Puffer ausschalten
*        i_consistency_check           =                  " Starte Konsistenzverprobung für Schnittstellefehlererkennung
*        i_structure_name              =  lv_strucname     " Strukturname der internen Ausgabetabelle
        is_variant                    =  ls_variant       " Anzeigevariante
        i_save                        =  'A'              " Anzeigevariante sichern
        i_default                     = xsdbool( ls_variant-variant IS INITIAL AND ib_show_all_cols = abap_false ) " Defaultanzeigevariante
        is_layout                     =  ls_layout        " Layout
*        is_print                      =                  " Drucksteuerung
*        it_special_groups             =                  " Feldgruppen
        it_toolbar_excluding          =  lt_std_func_excl      " excludierte Toolbarstandardfunktionen
*        it_hyperlink                  =                  " Hyperlinks
*        it_alv_graphics               =                  " Tabelle von der Struktur DTC_S_TC
*        it_except_qinfo               =                  " Tabelle für die Exception Quickinfo
*        ir_salv_adapter               =                  " Interface ALV Adapter
      CHANGING
        it_outtab                     = <ct_data>        " Ausgabetabelle
        it_fieldcatalog               = lt_fieldcat       " Feldkatalog
        it_sort                       = lt_sort           " Sortierkriterien
*        it_filter                     =                  " Filterkriterien
*      EXCEPTIONS
*        invalid_parameter_combination = 1                " Parameter falsch
*        program_error                 = 2                " Programmfehler
*        too_many_lines                = 3                " Zu viele Zeilen in eingabebereitem Grid.
*        others                        = 4
    ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    mrt_data = crt_data.
*    mo_grid->set_scroll_info_via_id(
*      EXPORTING
*        is_row_info = value LVC_S_ROW( rowtype = '' index = 5 )
*        is_col_info = value LVC_S_COL( fieldname = lt_fieldcat[ 1 ]-fieldname  )                " SpaltenID
**        is_row_no   = value lvc_s_roid( row_id = 30 )                 " Numerische ZeilenID
*    ).
*    mo_grid->set_current_cell_via_id(   EXPORTING
*         is_row_id    =  value LVC_S_ROW( rowtype = '' index = '30' )                " Zeile
**        is_column_id =                  " Spalte
**        is_row_no    =                  " Numerische Zeilen ID
*   ).
    SET HANDLER if_event_handler->on_user_command FOR mo_grid.
    SET HANDLER if_event_handler->on_hotspotclick FOR mo_grid.

    CALL METHOD mo_grid->set_ready_for_input
      EXPORTING
        i_ready_for_input = 1.


* § 4.Call method 'set_toolbar_interactive' to raise event TOOLBAR.
    IF ib_use_pf_status = abap_false.
      SET HANDLER me->handle_toolbar FOR mo_grid.
      CALL METHOD mo_grid->set_toolbar_interactive.
    ENDIF.
    " SET HANDLER update_table FOR ALL INSTANCES. " reagiert nur auf Doppelclick
  ENDMETHOD.


  METHOD prepare_autotext.

    DATA ls_autotext TYPE LINE OF alv_auto_text_t.

    ls_autotext-keep_fieldname_visible = 'X'.
    ls_autotext-fieldname              = 'LS_STATUS'.
    ls_autotext-fieldname_longtext     = 'LS_STATUS_TEXT'.
    INSERT ls_autotext INTO TABLE rt_autotext.

  ENDMETHOD.


  METHOD set_colors.
    DATA ls_color TYPE lvc_s_scol.
    FIELD-SYMBOLS <ct_data> TYPE ANY TABLE.
    FIELD-SYMBOLS <fs_line> TYPE any .
    ASSIGN is_data TO <fs_line>.

    FIELD-SYMBOLS: <lfs_data> TYPE any.

    ASSIGN COMPONENT 'LS_NUMMER' OF STRUCTURE <fs_line> TO <lfs_data>.
    CHECK sy-subrc = 0.
    IF <lfs_data> IS NOT INITIAL.
      ASSIGN COMPONENT 'LS_STATUS_DATE' OF STRUCTURE <fs_line> TO <lfs_data>.
      CHECK sy-subrc = 0.
      IF <lfs_data> IS INITIAL.
        ls_color-fname = 'LS_NUMMER'.
        ls_color-color-col = 6.  " red color
        APPEND ls_color TO crt_colors.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD update_table.
    DATA : lv_value TYPE char1.

    FIELD-SYMBOLS: <lt_data> TYPE ANY TABLE.
    ASSIGN mrt_data->* TO <lt_data>.

    LOOP AT <lt_data> ASSIGNING FIELD-SYMBOL(<ls_data>).
      CALL METHOD er_data_changed->get_cell_value
        EXPORTING
*         I_ROW_ID    = lv_count
          i_tabix     = sy-tabix
          i_fieldname = 'SEL'
        IMPORTING
          e_value     = lv_value.
      ASSIGN COMPONENT 'SEL'  OF  STRUCTURE <ls_data> TO FIELD-SYMBOL(<lv_value>).
      <lv_value> = lv_value.
    ENDLOOP.
*      CALL METHOD er_data_changed->modify_cell
*        EXPORTING
**         I_ROW_ID    = lv_count
*          i_tabix     = lv_index
*          i_fieldname = ‘checkbox’
*          i_value     = ”.
*    ENDDO.
  ENDMETHOD.
ENDCLASS.
