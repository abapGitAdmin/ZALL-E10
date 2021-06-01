FUNCTION se16n_ddl_entity_get.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_TAB) TYPE  SE16N_TAB
*"  EXPORTING
*"     VALUE(E_ENTITY) TYPE  VIEWNAME
*"     VALUE(E_DDLNAME) TYPE  DDLNAME
*"----------------------------------------------------------------------

 DATA: lt_entity_names_of_abap_view TYPE if_dd_ddl_types=>ty_t_entity_of_view.
 DATA: go_ddl_handler               TYPE REF TO if_dd_ddl_handler.

 FIELD-SYMBOLS <ls_entity_names_of_abap_view> TYPE if_dd_ddl_types=>ty_s_entity_of_view.

 go_ddl_handler = cl_dd_ddl_handler_factory=>create( ).

 TRY.
    go_ddl_handler->get_entityname_from_viewname(
        EXPORTING
          ddnames        = VALUE #( ( name = i_tab ) )
        IMPORTING
          entity_of_view = lt_entity_names_of_abap_view ).
    CATCH cx_dd_ddl_exception.
 ENDTRY.

*.if no DDL exists, clear exporting and skip
 IF lt_entity_names_of_abap_view[] IS INITIAL.
   CLEAR: e_entity, e_ddlname.
 ELSE.
   READ TABLE lt_entity_names_of_abap_view INDEX 1 ASSIGNING <ls_entity_names_of_abap_view>.
   e_entity  = <ls_entity_names_of_abap_view>-entityname.
   e_ddlname = <ls_entity_names_of_abap_view>-ddlname.
 ENDIF.

ENDFUNCTION.
