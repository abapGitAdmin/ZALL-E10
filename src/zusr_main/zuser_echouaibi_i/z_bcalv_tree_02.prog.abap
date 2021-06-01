************************************************************************
****
*            _
*   __ _  __| | ___  ___ ___  ___
*  / _` |/ _` |/ _ \/ __/ __|/ _ \
* | (_| | (_| |  __/\__ \__ \ (_) |
*  \__,_|\__,_|\___||___/___/\___/
************************************************************************
*******
*
*
*&
************************************************************************
*******
REPORT z_bcalv_tree_02.

TABLES: zdev_artikel.
CLASS cls_event_handler DEFINITION DEFERRED.
DATA: g_alv_tree           TYPE REF TO cl_gui_alv_tree,
      g_custom_container   TYPE REF TO cl_gui_custom_container,
      go_toolbar_container TYPE REF TO cl_gui_custom_container,
      g_alv_grid           TYPE REF TO cl_gui_alv_grid,
      go_toolbar           TYPE REF TO cl_gui_toolbar,
      it_fcat              TYPE lvc_t_fcat,
      ls_fcat              TYPE lvc_S_fcat,
      layout               TYPE lvc_s_layo,
      struc_name           TYPE dd02l-tabname,
      summe                TYPE zdev_artikel-gesamtpreis.


DATA: ean         TYPE z_dev_nr,
      anzahl      TYPE i,
      bar         TYPE z_dev_betrag,
      rueck       TYPE z_dev_betrag,
      mwst        TYPE z_dev_betrag,
      mwst_gesamt TYPE z_dev_betrag,
      mwstsatz    TYPE z_dev_prozent.
* SUBSCREEN KARTENZAHLUNG
DATA: karten_nr TYPE z_dev_nr,
      geheim_nr TYPE z_dev_nr.

TYPES: BEGIN OF karten_struktur,
         karten_nr TYPE z_dev_nr,
         geheim_nr TYPE z_dev_nr,
         status    TYPE c,
       END OF karten_struktur.
DATA: karten_satz TYPE karten_struktur.

DATA: benutzer TYPE z_dev_nr,
      passwort TYPE z_dev_nr.

DATA:
  ls_artikel  TYPE zdev_artikel,
  lt_artikel  TYPE TABLE OF zdev_artikel,
  ls_rechnung TYPE  zrechnungen,
  ok_code     TYPE sy-ucomm.

DATA:

  gi_events        TYPE cntl_simple_events,
*   * Workspace for table gi_events
  g_event          TYPE cntl_simple_event,
*   * Table for button group
  gi_button_group  TYPE ttb_button,
* Event handler
  go_event_handler TYPE REF TO cls_event_handler,
* Context menu
  go_context_menu  TYPE REF TO cl_ctmenu.

DATA:
*   * Global varables for position of context menu
  g_posx TYPE i,
  g_posy TYPE i.
*DATA: gt_sflight      TYPE sflight," OCCURS 0,      "Output-Table
DATA: gt_filiale      TYPE TABLE OF zfiliale,
      gt_person       TYPE TABLE OF zperson,
      gt_artikel      TYPE TABLE OF zdev_artikel,
      gt_rechnungen   TYPE TABLE OF zrechnungen,
      gt_fieldcatalog TYPE lvc_t_fcat,
      save_ok         LIKE sy-ucomm,           "OK-Code
      g_max           TYPE i VALUE 255. "maximum of db records to select


CLASS lcl_tree_event_receiver DEFINITION.

  PUBLIC SECTION.
*§2. Define an event handler method for each event you want to react to.
    METHODS handle_node_double_click
                FOR EVENT node_double_click OF cl_gui_alv_tree
      IMPORTING node_key sender.

ENDCLASS.
****************************************************************
CLASS lcl_tree_event_receiver IMPLEMENTATION.

  METHOD handle_node_double_click.
    DATA: lt_children TYPE lvc_t_nkey.
*first check if the node is a leaf, i.e. can not be expanded

*    CALL METHOD sender->get_children
*      EXPORTING
*        i_node_key  = node_key
*      IMPORTING
*        et_children = lt_children.

select * from zfiliale into TABLE gt_filiale WHERE c_key = node_key.
  IF sy-subrc = 0.

     MESSAGE i010(zdev_z).

  ENDIF.

    CALL METHOD g_alv_grid->set_table_for_first_display
    EXPORTING
      is_layout       = layout
    CHANGING
      it_fieldcatalog = it_fcat[]
      it_outtab       = gt_filiale.

*    IF NOT lt_children IS INITIAL.
*
*      CALL METHOD sender->expand_node
*        EXPORTING
*          i_node_key    = node_key
*          i_level_count = 2.
*    ENDIF.

  ENDMETHOD.

ENDCLASS.
*##################################################################

CLASS cls_event_handler DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_function_selected
                  FOR EVENT function_selected OF cl_gui_toolbar
        IMPORTING fcode,
      on_dropdown_clicked
                  FOR EVENT dropdown_clicked OF cl_gui_toolbar
        IMPORTING fcode posx posy.

ENDCLASS.

*   *---------------------------------------------------------------------*
*   *       CLASS cls_event_handler IMPLEMENTATION
*   *---------------------------------------------------------------------*
*   *       ........                                                      *
*   *---------------------------------------------------------------------*
CLASS cls_event_handler IMPLEMENTATION.
  METHOD on_function_selected.
    CASE fcode.
      WHEN 'ANLEGEN'.
        CALL SCREEN 200.
      WHEN 'ANZEIGEN'.
        CALL SCREEN 300.
      WHEN 'CREATE_P'.
        CALL SCREEN 400.
      WHEN 'EIN'.
        CALL SCREEN 400.
    ENDCASE.
  ENDMETHOD.

  METHOD on_dropdown_clicked.

  ENDMETHOD.
ENDCLASS.


START-OF-SELECTION.

END-OF-SELECTION.

  CALL SCREEN 100.

*&---------------------------------------------------------------------*
*&      Module  PBO  OUTPUT
*&---------------------------------------------------------------------*
*       process before output
*----------------------------------------------------------------------*
MODULE pbo OUTPUT.

  SET PF-STATUS 'MAIN100'.
  SET TITLEBAR 'MAINTITLE'.


  IF go_toolbar_container IS INITIAL.
*   * Create container
    CREATE OBJECT go_toolbar_container
      EXPORTING
        container_name = 'C_TOOL'.

*   * Create toolbar
    CREATE OBJECT go_toolbar
      EXPORTING
        parent = go_toolbar_container.

*   * Add a button
    CALL METHOD go_toolbar->add_button
      EXPORTING
        fcode       = 'ANLEGEN'            "Function Code
        icon        = icon_system_end   "ICON name
        is_disabled = ' '               "Disabled = X
        butn_type   = cntb_btype_button "Type of button
        text        = 'Filial anlegen'            "Text on button
        is_checked  = ' '.              "Button selected
*  ENDIF.

*   * Add a button
    CALL METHOD go_toolbar->add_button
      EXPORTING
        fcode       = 'AENDERN'            "Function Code
        icon        = icon_system_end   "ICON name
        is_disabled = ' '               "Disabled = X
        butn_type   = cntb_btype_button "Type of button
        text        = 'Filial ändern'            "Text on button
*       quickinfo   = 'FILIAL Anlegen'    "Quick info
        is_checked  = ' '.

*   * Add a button
    CALL METHOD go_toolbar->add_button
      EXPORTING
        fcode       = 'create_p'            "Function Code
        icon        = icon_system_end   "ICON name
        is_disabled = ' '               "Disabled = X
        butn_type   = cntb_btype_button "Type of button
        text        = 'Person anlegen'            "Text on button
*       quickinfo   = 'FILIAL Anlegen'    "Quick info
        is_checked  = ' '.

*   * Add a button
    CALL METHOD go_toolbar->add_button
      EXPORTING
        fcode       = 'change_p'            "Function Code
        icon        = icon_system_end   "ICON name
        is_disabled = ' '               "Disabled = X
        butn_type   = cntb_btype_button "Type of button
        text        = 'Person ändern'            "Text on button
*       quickinfo   = 'FILIAL Anlegen'    "Quick info
        is_checked  = ' '.
*   * Add a button
    CALL METHOD go_toolbar->add_button
      EXPORTING
        fcode       = 'anzeigen'            "Function Code
        icon        = icon_system_end   "ICON name
        is_disabled = ' '               "Disabled = X
        butn_type   = cntb_btype_button "Type of button
        text        = 'Warenkorb anzeigen'            "Text on button
*       quickinfo   = 'FILIAL Anlegen'    "Quick info
        is_checked  = ' '.

*    *   * Add a button
    CALL METHOD go_toolbar->add_button
      EXPORTING
        fcode       = 'Ein'            "Function Code
        icon        = icon_system_end   "ICON name
        is_disabled = ' '               "Disabled = X
        butn_type   = cntb_btype_button "Type of button
        text        = 'Einkaufstarten'            "Text on button
*       quickinfo   = 'FILIAL Anlegen'    "Quick info
        is_checked  = ' '.

  ENDIF.

* Create event table. Note that the event ID must be found in the
* documentation of the specific control
  CLEAR g_event. REFRESH gi_events.
  g_event-eventid    = go_toolbar->m_id_function_selected.
  g_event-appl_event = 'X'.    "This is an application event
  APPEND g_event TO gi_events.

  CLEAR g_event.
  g_event-eventid    = go_toolbar->m_id_dropdown_clicked.
  g_event-appl_event = 'X'.
  APPEND g_event TO gi_events.

*   Use the events table to register events for the control
  CALL METHOD go_toolbar->set_registered_events
    EXPORTING
      events = gi_events.


*  Create event handlers
  CREATE OBJECT go_event_handler.

  SET HANDLER go_event_handler->on_function_selected
    FOR go_toolbar.

  SET HANDLER go_event_handler->on_dropdown_clicked
     FOR go_toolbar.

*     ENDIF.
  IF g_alv_tree IS INITIAL.
    PERFORM init_tree.

    CALL METHOD cl_gui_cfw=>flush
      EXCEPTIONS
        cntl_system_error = 1
        cntl_error        = 2.
    IF sy-subrc NE 0.
      CALL FUNCTION 'POPUP_TO_INFORM'
        EXPORTING
          titel = 'Automation Queue failure'(801)
          txt1  = 'Internal error:'(802)
          txt2  = 'A method in the automation queue'(803)
          txt3  = 'caused a failure.'(804).
    ENDIF.
  ENDIF.

ENDMODULE.                             " PBO  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PAI  INPUT
*&---------------------------------------------------------------------*
*       process after input
*----------------------------------------------------------------------*
MODULE pai INPUT.
  save_ok = ok_code.
  CLEAR ok_code.

  CASE save_ok.
    WHEN 'EXIT' OR 'BACK' OR 'CANC'.
      PERFORM exit_program.
    WHEN OTHERS.

      CALL METHOD cl_gui_cfw=>dispatch.

  ENDCASE.

  CALL METHOD cl_gui_cfw=>flush.
ENDMODULE.                             " PAI  INPUT

*&---------------------------------------------------------------------*
*&      Form  init_tree
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_tree.
* create container for alv-tree
  DATA: l_tree_container_name(30) TYPE c.

  l_tree_container_name = 'C_CONTAINER'.

  CREATE OBJECT g_custom_container
    EXPORTING
      container_name              = l_tree_container_name
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5.
  IF sy-subrc <> 0.
    MESSAGE x208(00) WITH 'ERROR'(100).
  ENDIF.

* create tree control
  CREATE OBJECT g_alv_tree
    EXPORTING
      parent                      = g_custom_container
      node_selection_mode         = cl_gui_column_tree=>node_sel_mode_single
      item_selection              = 'X'
      no_html_header              = 'X'
      no_toolbar                  = ''
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      illegal_node_selection_mode = 5
      failed                      = 6
      illegal_column_name         = 7.
  IF sy-subrc <> 0.
    MESSAGE x208(00) WITH 'ERROR'.                          "#EC NOTEXT
  ENDIF.

  DATA l_hierarchy_header TYPE treev_hhdr.
  PERFORM build_hierarchy_header CHANGING l_hierarchy_header.

* Hide columns and sum up values initially using the fieldcatalog
  PERFORM build_fieldcatalog.

  CALL METHOD g_alv_tree->set_table_for_first_display
    EXPORTING
*     i_structure_name    = 'ZFILIALE'
      is_hierarchy_header = l_hierarchy_header
    CHANGING
      it_fieldcatalog     = gt_fieldcatalog
      it_outtab           = gt_filiale. "table must be empty !

  PERFORM create_hierarchy.

   PERFORM register_events.

*  PERFORM register_events.
* Update calculations which were initially defined by field DO_SUM
* of the fieldcatalog. (see build_fieldcatalog).
  CALL METHOD g_alv_tree->update_calculations.

* Send data to frontend.
  CALL METHOD g_alv_tree->frontend_update.

ENDFORM.                               " init_tree
*&---------------------------------------------------------------------*
*&      Form  build_hierarchy_header
*&---------------------------------------------------------------------*
*       build hierarchy-header-information
*----------------------------------------------------------------------*
*      -->P_L_HIERARCHY_HEADER  strucxture for hierarchy-header
*----------------------------------------------------------------------*
FORM build_hierarchy_header CHANGING
                               p_hierarchy_header TYPE treev_hhdr.

  p_hierarchy_header-heading = 'ÜBERSICHT'(300).
  p_hierarchy_header-tooltip = 'globale Übersicht'(400).
  p_hierarchy_header-width = 35.
  p_hierarchy_header-width_pix = ''.

ENDFORM.                               " build_hierarchy_header
*&---------------------------------------------------------------------*
*&      Form  exit_program
*&---------------------------------------------------------------------*
*       free object and leave program
*----------------------------------------------------------------------*
FORM exit_program.

  CALL METHOD g_custom_container->free.
  LEAVE PROGRAM.

ENDFORM.                               " exit_program
*--------------------------------------------------------------------
FORM build_fieldcatalog.
  DATA: ls_fieldcatalog TYPE lvc_s_fcat.

* The following function module generates a fieldcatalog according
* to a given structure.
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'ZFILIALE'
    CHANGING
      ct_fieldcat      = gt_fieldcatalog.

* Now change the fieldcatalog to hide fields and to determine
* some initial calculations for chosen fields.
  LOOP AT gt_fieldcatalog INTO ls_fieldcatalog.
    CASE ls_fieldcatalog-fieldname.
* hide columns which are already displayed in our tree
      WHEN 'STADT' OR 'FILIALID'.
        ls_fieldcatalog-no_out = 'X'.
    ENDCASE.
    MODIFY gt_fieldcatalog FROM ls_fieldcatalog.
  ENDLOOP.

* The fieldcatalog is provided in form 'init_tree' using method
* set_table_for_first_display.
ENDFORM.                               " build_fieldcatalog
*-----------------------------------------------------------------------
*FORM register_events.
** Event registration: tell ALV Tree which events shall be passed
**    from frontend to backend.
*  DATA: lt_events        TYPE cntl_simple_events,
*        l_event          TYPE cntl_simple_event.
**        l_event_receiver TYPE REF TO lcl_tree_event_receiver.
*
*  CALL METHOD g_alv_tree->get_registered_events
*    IMPORTING
*      events = lt_events.
*
** Frontend registration(ii): add additional event ids
*  l_event-eventid = cl_gui_column_tree=>eventid_node_double_click.
*  APPEND l_event TO lt_events.
*
**Frontend registration(iii):provide new event table to alv tree
*  CALL METHOD g_alv_tree->set_registered_events
*    EXPORTING
*      events                    = lt_events
*    EXCEPTIONS
*      cntl_error                = 1
*      cntl_system_error         = 2
*      illegal_event_combination = 3.
*  IF sy-subrc <> 0.
*    MESSAGE x208(00) WITH 'ERROR'.                          "#EC NOTEXT
*  ENDIF.
**--------------------
**§4d. Register events on backend (ABAP Objects event handling)
*  CREATE OBJECT l_event_receiver.
*  SET HANDLER l_event_receiver->handle_node_double_click FOR g_alv_tree.

*ENDFORM.                               " register_events


FORM create_hierarchy.

  DATA: lt_filiale    TYPE TABLE OF zfiliale,
        ls_filiale    TYPE zfiliale,
        l_city        TYPE string,
        lv_city_old   TYPE string,
        l_carrid      LIKE sflight-carrid,
        l_carrid_last LIKE sflight-carrid.

*  DATA: l_month_key TYPE lvc_nkey,
  DATA: l_city_key   TYPE lvc_nkey,
        l_carrid_key TYPE lvc_nkey,
        l_filial_key TYPE lvc_nkey,
        l_last_key   TYPE lvc_nkey,
        l_top_key    TYPE lvc_nkey.

* Select data

  SELECT * FROM zfiliale INTO TABLE lt_filiale UP TO g_max ROWS.

  CALL METHOD g_alv_tree->add_node
    EXPORTING
      i_relat_node_key = ''
      i_relationship   = cl_gui_column_tree=>relat_last_child
      i_node_text      = TEXT-050
    IMPORTING
      e_new_node_key   = l_top_key.

  SORT lt_filiale BY stadt ASCENDING.
  LOOP AT lt_filiale INTO ls_filiale.
    IF ls_filiale-stadt <> lv_city_old.
      lv_city_old = ls_filiale-stadt.
      CONCATENATE 'FILIALE IN ' ls_filiale-stadt INTO l_city SEPARATED BY space.

      PERFORM add_to_alvtree USING    l_city
                                      l_top_key
                             CHANGING l_city_key.


    ENDIF.

*     ls_filiale-c_key = ls_filiale-filialid.
*     modify zfiliale from ls_filiale.

    PERFORM add_filiale_line USING    ls_filiale
                                     l_city_key
                            CHANGING l_filial_key.

     ls_filiale-c_key = l_filial_key.
     modify zfiliale from ls_filiale.
  ENDLOOP.

ENDFORM.                               " create_hierarchy

*&---------------------------------------------------------------------*
*&      Form  add_month
*&---------------------------------------------------------------------*
FORM add_to_alvtree  USING     p_city TYPE string
                          p_relat_key TYPE lvc_nkey
                CHANGING  p_node_key TYPE lvc_nkey.

  DATA: l_node_text TYPE lvc_value,
        ls_sflight  TYPE sflight,
        ls_filiale  TYPE zfiliale,
        l_month(15) TYPE c.            "output string for month

** get month name for node text
*  PERFORM get_month USING p_yyyymm
*                    CHANGING l_month.
  l_node_text = p_city.

* add node
  CALL METHOD g_alv_tree->add_node
    EXPORTING
      i_relat_node_key = p_relat_key
      i_relationship   = cl_gui_column_tree=>relat_last_child
      i_node_text      = l_node_text
      is_outtab_line   = ls_filiale
    IMPORTING
      e_new_node_key   = p_node_key.

ENDFORM.                               " add_month
*-----------------------------------------------------------------------
FORM add_filiale_line USING     ps_filiale TYPE zfiliale
                               p_relat_key TYPE lvc_nkey
                     CHANGING  p_node_key TYPE lvc_nkey.

  DATA: l_node_text TYPE lvc_value,
        ls_filiale  TYPE zfiliale.

* add node
  l_node_text =  ps_filiale-filialid.
  CALL METHOD g_alv_tree->add_node
    EXPORTING
      i_relat_node_key = p_relat_key
      i_relationship   = cl_gui_column_tree=>relat_last_child
      i_node_text      = l_node_text
      is_outtab_line   = ls_filiale
    IMPORTING
      e_new_node_key   = p_node_key.

ENDFORM.                               " add_carrid_line


*&SPWIZARD: FUNCTION CODES FOR TABSTRIP 'MY_TABSTRIB'
CONSTANTS: BEGIN OF c_my_tabstrib,
             tab1 LIKE sy-ucomm VALUE 'MY_TABSTRIB_FC1',
             tab2 LIKE sy-ucomm VALUE 'MY_TABSTRIB_FC2',
             tab3 LIKE sy-ucomm VALUE 'MY_TABSTRIB_FC3',
             tab4 LIKE sy-ucomm VALUE 'MY_TABSTRIB_FC4',
           END OF c_my_tabstrib.
*&SPWIZARD: DATA FOR TABSTRIP 'MY_TABSTRIB'
CONTROLS:  my_tabstrib TYPE TABSTRIP.
DATA: BEGIN OF g_my_tabstrib,
        subscreen   LIKE sy-dynnr,
        prog        LIKE sy-repid VALUE 'Z_BCALV_TREE_02',
        pressed_tab LIKE sy-ucomm VALUE c_my_tabstrib-tab1,
      END OF g_my_tabstrib.

*&SPWIZARD: OUTPUT MODULE FOR TS 'MY_TABSTRIB'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: SETS ACTIVE TAB
MODULE my_tabstrib_active_tab_set OUTPUT.
  my_tabstrib-activetab = g_my_tabstrib-pressed_tab.
  CASE g_my_tabstrib-pressed_tab.
    WHEN c_my_tabstrib-tab1.
      g_my_tabstrib-subscreen = '0101'.
    WHEN c_my_tabstrib-tab2.
      g_my_tabstrib-subscreen = '0102'.
    WHEN c_my_tabstrib-tab3.
      g_my_tabstrib-subscreen = '0103'.
    WHEN c_my_tabstrib-tab4.
      g_my_tabstrib-subscreen = '0104'.
    WHEN OTHERS.
*&SPWIZARD:      DO NOTHING
  ENDCASE.
ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TS 'MY_TABSTRIB'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GETS ACTIVE TAB
MODULE my_tabstrib_active_tab_get INPUT.
  ok_code = sy-ucomm.
  CASE ok_code.
    WHEN c_my_tabstrib-tab1.
      g_my_tabstrib-pressed_tab = c_my_tabstrib-tab1.
    WHEN c_my_tabstrib-tab2.
      g_my_tabstrib-pressed_tab = c_my_tabstrib-tab2.
    WHEN c_my_tabstrib-tab3.
      g_my_tabstrib-pressed_tab = c_my_tabstrib-tab3.
    WHEN c_my_tabstrib-tab4.
      g_my_tabstrib-pressed_tab = c_my_tabstrib-tab4.
    WHEN OTHERS.
*&SPWIZARD:      DO NOTHING
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Form  PERSONLISTE_EINLESEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM personliste_einlesen .

  SELECT * FROM zperson INTO TABLE gt_person.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  TEST  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE person_ansicht OUTPUT.

*  IF g_custom_container IS INITIAL.


  layout-grid_title = 'Personübersicht'.
  struc_name = 'ZPERSON'.


  CREATE OBJECT g_custom_container
    EXPORTING
      container_name = 'CC_PERSON'.

  CREATE OBJECT g_alv_grid
    EXPORTING
      i_parent = g_custom_container.



  PERFORM field_cat USING struc_name.

  PERFORM personliste_einlesen.

  CALL METHOD g_alv_grid->set_table_for_first_display
    EXPORTING
      is_layout       = layout
    CHANGING
      it_fieldcatalog = it_fcat[]
      it_outtab       = gt_person.

*  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Form  FIELD_CAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM field_cat USING p_struc_name.
  CLEAR: it_fcat.
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = p_struc_name
    CHANGING
      ct_fieldcat      = it_fcat.

  LOOP AT it_fcat into ls_fcat.

    IF ls_fcat-fieldname = 'C_KEY'.

      ls_fcat-no_out = 'X'.
      MODIFY it_fcat FROM ls_fcat.

    ENDIF.

  ENDLOOP.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  FILIAL_ANSICHT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE filial_ansicht OUTPUT.

  layout-grid_title = 'Filialübersicht'.
  struc_name = 'ZFILIALE'.


  CREATE OBJECT g_custom_container
    EXPORTING
      container_name = 'CC_FILIAL'.

  CREATE OBJECT g_alv_grid
    EXPORTING
      i_parent = g_custom_container.



  PERFORM field_cat USING struc_name.

  PERFORM filialliste_einlesen.

  CALL METHOD g_alv_grid->set_table_for_first_display
    EXPORTING
      is_layout       = layout
    CHANGING
      it_fieldcatalog = it_fcat[]
      it_outtab       = gt_filiale.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Form  FILIALLISTE_EINLESEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM filialliste_einlesen.
  SELECT * FROM zfiliale INTO TABLE gt_filiale.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  ARTIKEL_ANSICHT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE artikel_ansicht OUTPUT.

  layout-grid_title = 'Artikelübersicht'.
  struc_name = 'ZDEV_ARTIKEL'.


  CREATE OBJECT g_custom_container
    EXPORTING
      container_name = 'CC_ARTIKEL'.

  CREATE OBJECT g_alv_grid
    EXPORTING
      i_parent = g_custom_container.



  PERFORM field_cat USING struc_name.

  PERFORM artikelliste_einlesen.

  CALL METHOD g_alv_grid->set_table_for_first_display
    EXPORTING
      is_layout       = layout
    CHANGING
      it_fieldcatalog = it_fcat[]
      it_outtab       = gt_artikel.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Form  ARTIKELLISTE_EINLESEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM artikelliste_einlesen .

  SELECT * FROM zdev_artikel INTO TABLE gt_artikel.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  RECHNUNG_ANSICHT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE rechnung_ansicht OUTPUT.
  layout-grid_title = 'Rechnungübersicht'.
  struc_name = 'ZRECHNUNGEN'.


  CREATE OBJECT g_custom_container
    EXPORTING
      container_name = 'CC_RECHNUNG'.

  CREATE OBJECT g_alv_grid
    EXPORTING
      i_parent = g_custom_container.

  PERFORM field_cat USING struc_name.

  PERFORM rechnungliste_einlesen.

  CALL METHOD g_alv_grid->set_table_for_first_display
    EXPORTING
      is_layout       = layout
    CHANGING
      it_fieldcatalog = it_fcat[]
      it_outtab       = gt_rechnungen.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Form  RECHNUNGLISTE_EINLESEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM rechnungliste_einlesen .
  SELECT * FROM zrechnungen INTO TABLE gt_rechnungen.
ENDFORM.

INCLUDE z_bcalv_tree_02_status_0500o01.

INCLUDE z_bcalv_tree_02_user_commani01.

INCLUDE z_bcalv_tree_02_status_0200o01.

INCLUDE z_bcalv_tree_02_user_commani02.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'MY_TABCONTROL' ITSELF
CONTROLS: my_tabcontrol TYPE TABLEVIEW USING SCREEN 0300.

*&SPWIZARD: OUTPUT MODULE FOR TC 'MY_TABCONTROL'. DO NOT CHANGE THIS LIN
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE my_tabcontrol_change_tc_attr OUTPUT.
  DESCRIBE TABLE lt_artikel LINES my_tabcontrol-lines.
ENDMODULE.

INCLUDE z_bcalv_tree_02_user_commani03.

INCLUDE z_bcalv_tree_02_status_0300o01.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'MY_TABCONTROL2' ITSELF
CONTROLS: my_tabcontrol2 TYPE TABLEVIEW USING SCREEN 0400.

*&SPWIZARD: OUTPUT MODULE FOR TC 'MY_TABCONTROL2'. DO NOT CHANGE THIS LI
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE my_tabcontrol2_change_tc_attr OUTPUT.
  DESCRIBE TABLE lt_artikel LINES my_tabcontrol2-lines.
ENDMODULE.

*&SPWIZARD: FUNCTION CODES FOR TABSTRIP 'MY_TABSTRIP_2'
CONSTANTS: BEGIN OF c_my_tabstrip_2,
             tab1 LIKE sy-ucomm VALUE 'MY_TABSTRIP_2_FC1',
             tab2 LIKE sy-ucomm VALUE 'MY_TABSTRIP_2_FC2',
           END OF c_my_tabstrip_2.
*&SPWIZARD: DATA FOR TABSTRIP 'MY_TABSTRIP_2'
CONTROLS:  my_tabstrip_2 TYPE TABSTRIP.
DATA: BEGIN OF g_my_tabstrip_2,
        subscreen   LIKE sy-dynnr,
        prog        LIKE sy-repid VALUE 'Z_BCALV_TREE_02',
        pressed_tab LIKE sy-ucomm VALUE c_my_tabstrip_2-tab1,
      END OF g_my_tabstrip_2.

*&SPWIZARD: OUTPUT MODULE FOR TS 'MY_TABSTRIP_2'. DO NOT CHANGE THIS LIN
*&SPWIZARD: SETS ACTIVE TAB
MODULE my_tabstrip_2_active_tab_set OUTPUT.
  my_tabstrip_2-activetab = g_my_tabstrip_2-pressed_tab.
  CASE g_my_tabstrip_2-pressed_tab.
    WHEN c_my_tabstrip_2-tab1.
      g_my_tabstrip_2-subscreen = '0401'.
    WHEN c_my_tabstrip_2-tab2.
      g_my_tabstrip_2-subscreen = '0402'.
    WHEN OTHERS.
*&SPWIZARD:      DO NOTHING
  ENDCASE.
ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TS 'MY_TABSTRIP_2'. DO NOT CHANGE THIS LINE
*&SPWIZARD: GETS ACTIVE TAB
MODULE my_tabstrip_2_active_tab_get INPUT.
  ok_code = sy-ucomm.
  CASE ok_code.
    WHEN c_my_tabstrip_2-tab1.
      g_my_tabstrip_2-pressed_tab = c_my_tabstrip_2-tab1.
    WHEN c_my_tabstrip_2-tab2.
      g_my_tabstrip_2-pressed_tab = c_my_tabstrip_2-tab2.
    WHEN OTHERS.
*&SPWIZARD:      DO NOTHING
  ENDCASE.
ENDMODULE.

INCLUDE z_bcalv_tree_02_status_0400o01.

INCLUDE z_bcalv_tree_02_user_commani04.
*&---------------------------------------------------------------------*
*&      Form  REGISTER_EVENTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM register_events .
DATA: lt_events TYPE cntl_simple_events,
        l_event TYPE cntl_simple_event,
        l_event_receiver TYPE REF TO lcl_tree_event_receiver.

call method g_alv_tree->get_registered_events
      importing events = lt_events.


  l_event-eventid = cl_gui_column_tree=>eventid_node_double_click.
  APPEND l_event TO lt_events.

  CALL METHOD g_alv_tree->set_registered_events
    EXPORTING
      events = lt_events
    EXCEPTIONS
      cntl_error                = 1
      cntl_system_error         = 2
      illegal_event_combination = 3.
  IF sy-subrc <> 0.
    MESSAGE x208(00) WITH 'ERROR'.     "#EC NOTEXT
  ENDIF.

  CREATE OBJECT l_event_receiver.
  SET HANDLER l_event_receiver->handle_node_double_click FOR g_alv_tree.
ENDFORM.
