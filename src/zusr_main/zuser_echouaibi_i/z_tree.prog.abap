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
REPORT Z_TREE.

CLASS lcl_events DEFINITION.
  PUBLIC SECTION.

    TYPES: ty_it_events TYPE STANDARD TABLE OF cntl_simple_event WITH DEFAULT KEY.

    CLASS-METHODS: on_button_click FOR EVENT button_click OF cl_column_tree_model
      IMPORTING
          node_key
          item_name
          sender.

    CLASS-METHODS: on_link_click FOR EVENT link_click OF cl_column_tree_model
      IMPORTING
          node_key
          item_name
          sender.

    CLASS-METHODS: on_checkbox_change FOR EVENT checkbox_change OF cl_column_tree_model
      IMPORTING
          node_key
          item_name
          checked
          sender.

    CLASS-METHODS: on_header_click FOR EVENT header_click OF cl_column_tree_model
      IMPORTING
          header_name
          sender.

ENDCLASS.

CLASS lcl_events IMPLEMENTATION.

  METHOD on_button_click.
    MESSAGE node_key && '_' && item_name TYPE 'S'.
  ENDMETHOD.

  METHOD on_link_click.
    MESSAGE node_key && '_' && item_name TYPE 'S'.
  ENDMETHOD.

  METHOD on_checkbox_change.
    MESSAGE node_key && '_' && item_name && '_' && checked TYPE 'S'.
  ENDMETHOD.

  METHOD on_header_click.
    MESSAGE header_name TYPE 'S'.
  ENDMETHOD.

ENDCLASS.

START-OF-SELECTION.
* Tree-Control erzeugen
* item_selection = abap_true wegen der CheckBoxen
  DATA(o_tree) = NEW cl_column_tree_model( node_selection_mode   = cl_column_tree_model=>NODE_SEL_MODE_MULTIPLE
                                           hierarchy_column_name = 'FOLDER'
                                           hierarchy_header      = VALUE #( t_image = icon_folder
                                                                            heading = 'Beispiel'
                                                                            tooltip = 'Tooltip'
                                                                            width   = 30
                                                                          )
                                           item_selection        = abap_true
                                         ).
* Spalten hinzufügen
  o_tree->add_column( EXPORTING
                        name                = 'COL1'
                        width               = 30
                        header_text         = 'Column1' ).

  o_tree->add_column( EXPORTING
                        name                = 'COL2'
                        width               = 30
                        header_text         = 'Column2' ).

* in default_screen einbetten
  o_tree->create_tree_control( parent = cl_gui_container=>default_screen ).

* Beispielhaft Nodes und Subnodes erzeugen
  o_tree->add_node( EXPORTING
                      isfolder          = abap_true
                      node_key          = 'NODE1'
                      relative_node_key = ''
                      relationship      = cl_tree_model=>relat_last_child
                      expanded_image    = CONV tv_image( icon_folder )
                      image             = CONV tv_image( icon_folder )
                      item_table        = VALUE #( ( class     = cl_column_tree_model=>item_class_checkbox
                                                     item_name = 'FOLDER'
                                                     text      = 'Obj1'
                                                     editable  = abap_true
                                                   )
                                                 )
                  ).

  o_tree->add_node( EXPORTING
                      isfolder          = abap_true
                      node_key          = 'NODE1_1'
                      relative_node_key = 'NODE1'
                      relationship      = cl_tree_model=>relat_last_child
                      expanded_image    = CONV tv_image( icon_oo_object )
                      image             = CONV tv_image( icon_oo_object )
                      item_table        = VALUE #( ( class     = cl_column_tree_model=>item_class_link
                                                     item_name = 'FOLDER'
                                                     text      = 'Obj4'
                                                   )
                                                   ( class     = cl_column_tree_model=>item_class_text
                                                     item_name = 'COL1'
                                                     text      = 'Wert1'
                                                     style     = cl_column_tree_model=>style_intensified
                                                     font      = cl_column_tree_model=>item_font_prop
                                                   )
                                                   ( class     = cl_column_tree_model=>item_class_text
                                                     item_name = 'COL2'
                                                     text      = 'Wert2'
                                                   )
                                                 )
                  ).

  o_tree->add_node( EXPORTING
                      isfolder          = abap_true
                      node_key          = 'NODE2'
                      relative_node_key = ''
                      relationship      = cl_tree_model=>relat_last_child
                      expanded_image    = CONV tv_image( icon_folder )
                      image             = CONV tv_image( icon_folder )
                      item_table        = VALUE #( ( class     = cl_column_tree_model=>item_class_checkbox
                                                     item_name = 'FOLDER'
                                                     text      = 'Obj2'
                                                     editable  = abap_true
                                                   )
                                                 )
                  ).

  o_tree->add_node( EXPORTING
                      isfolder          = abap_true
                      node_key          = 'NODE2_1'
                      relative_node_key = 'NODE2'
                      relationship      = cl_tree_model=>relat_last_child
                      expanded_image    = CONV tv_image( icon_oo_object )
                      image             = CONV tv_image( icon_oo_object )
                      item_table        = VALUE #( ( class     = cl_column_tree_model=>item_class_button
                                                     item_name = 'FOLDER'
                                                     text      = 'Obj3'
                                                   )
                                                   ( class     = cl_column_tree_model=>item_class_text
                                                     item_name = 'COL1'
                                                     text      = 'Wert1'
                                                     style     = cl_column_tree_model=>style_inactive
                                                     font      = cl_column_tree_model=>item_font_prop
                                                   )
                                                   ( class     = cl_column_tree_model=>item_class_text
                                                     item_name = 'COL2'
                                                     text      = 'Wert2'
                                                   )
                                                 )
                  ).


* Nodes expandieren
  o_tree->expand_root_nodes( expand_subtree = abap_true
                             level_count = 10 ).

* Events registrieren
* ITEM_DOUBLE_CLICK            Doppelklick auf Item
* BUTTON_CLICK                 Drucktaste wurde gedrückt
* LINK_CLICK                   Link geklickt
* CHECKBOX_CHANGE              Zustandsänderung einer Checkbox
* ITEM_KEYPRESS                Taste wurde gedrückt, Item war selektiert
* HEADER_CLICK                 Header geklickt
* ITEM_CONTEXT_MENU_REQUEST    Anforderung eines Kontext-Menüs für ein Item
* ITEM_CONTEXT_MENU_SELECT     Kontext-Menü Eintrag wurde ausgewählt
* HEADER_CONTEXT_MENU_REQUEST  Anforderung eines Kontext-Menüs für einen Header
* HEADER_CONTEXT_MENU_SELECT   Kontext-Menü Eintrag wurde ausgewählt
* DRAG                         Ereignis zum Füllen des Drag Drop Daten - Objekts
* DRAG_MULTIPLE                Ereignis zum Füllen des Drag Drop Daten - Objekts
* DROP_COMPLETE                Ereignis nach erfolgreichem Drop
* DROP_COMPLETE_MULTIPLE       Ereignis nach erfolgreichem Drop
  SET HANDLER lcl_events=>on_button_click FOR o_tree.
  SET HANDLER lcl_events=>on_checkbox_change FOR o_tree.
  SET HANDLER lcl_events=>on_header_click FOR o_tree.
  SET HANDLER lcl_events=>on_link_click FOR o_tree.

* Eventtypten müssen gesondert registriert werden
  DATA(it_events) = VALUE lcl_events=>ty_it_events(
                                                    ( eventid = cl_column_tree_model=>eventid_button_click
                                                      appl_event = abap_true )
                                                    ( eventid = cl_column_tree_model=>eventid_checkbox_change
                                                      appl_event = abap_true )
                                                    ( eventid = cl_column_tree_model=>eventid_header_click
                                                      appl_event = abap_true )
                                                    ( eventid = cl_column_tree_model=>eventid_link_click
                                                      appl_event = abap_true )
                                                  ).

  o_tree->set_registered_events( events = it_events ).

* Erzeugung von cl_gui_container=>default_screen erzwingen
  WRITE: space.
