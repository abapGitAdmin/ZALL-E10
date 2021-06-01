*************************************************************************
*****
**            _
**   __ _  __| | ___  ___ ___  ___
**  / _` |/ _` |/ _ \/ __/ __|/ _ \
** | (_| | (_| |  __/\__ \__ \ (_) |
**  \__,_|\__,_|\___||___/___/\___/
*************************************************************************
********
**
**
**&
*************************************************************************
********
*REPORT ZDR_TEST_ONE.
*
*DATA: sdn TYPE char03 VALUE 'SDN'.
*
*DATA: gitab_spfli TYPE STANDARD TABLE OF spfli,
*      go_alv TYPE REF TO cl_salv_table,
*      gx_alv_msg TYPE REF TO cx_salv_msg,
*      gvar_row_count TYPE int4.
*
*SELECT * FROM spfli INTO TABLE gitab_spfli WHERE carrid = 'LH'.
*
*gvar_row_count = sy-dbcnt.
*IF sy-subrc = 0.
*  TRY.
*      cl_salv_table=>factory(
*        IMPORTING r_salv_table = go_alv
*        CHANGING t_table = gitab_spfli ).
*      go_alv->display( ).
*    CATCH cx_salv_msg INTO gx_alv_msg.
*      MESSAGE gx_alv_msg TYPE 'I' DISPLAY LIKE 'E'.
*  ENDTRY.
*ENDIF.
*WRITE: / 'row_count: ', gvar_row_count.


*---------------------------------------------------------------------*
* Title                 : Where used list for multiple data elements
* Author                : RICHTER-D KRUPA-F
*---------------------------------------------------------------------*

REPORT  zwhereusedlist.

TABLES : rsrd1.

TYPE-POOLS : slis.

* Types declaration.
TYPES : BEGIN OF ty_where,
          tabname TYPE tabname,
          fieldname TYPE fieldname,
          rollname TYPE rollname,
        END OF ty_where,

        BEGIN OF ty_input,
          element TYPE rsrd1-ddtype_val,
        END OF ty_input,

        BEGIN OF ty_table,
          tabname TYPE tabname,
        END OF ty_table.

* Internal tables declaration.
DATA  : it_founds TYPE TABLE OF rsfindlst,
        it_object_cls TYPE TABLE OF string,
        it_where TYPE TABLE OF ty_where,
        it_input TYPE TABLE OF ty_input,
        it_fcat TYPE slis_t_fieldcat_alv.

* Work areas declaration.
DATA  : wa_where TYPE ty_where,
        wa_input TYPE ty_input,
        wa_fcat TYPE slis_fieldcat_alv,
        wa_layout TYPE slis_layout_alv.

* Variables declaration.
DATA  : v_flag TYPE i,
        v_title TYPE string,
        v_text(70) TYPE c,
        v_strlen TYPE i,
        v_tabname TYPE tabname.

* Selection screen.

SELECTION-SCREEN BEGIN OF BLOCK b WITH FRAME TITLE text-000.
SELECT-OPTIONS : s_type FOR rsrd1-ddtype_val NO INTERVALS.
SELECTION-SCREEN END OF BLOCK b.

* Tables selection
START-OF-SELECTION.
  PERFORM get_tablenames.
* Outputing result
END-OF-SELECTION.
* Displaying the result tables.
  PERFORM display_result.
*&--------------------------------------------------------------------*
*&      Form  DISPLAY_RESULT
*&--------------------------------------------------------------------*
FORM display_result .
* ALV grid title creation
  wa_layout-colwidth_optimize = 'X'.
  v_title = 'Where used list for-'.
  LOOP AT it_input INTO wa_input.
    CONCATENATE v_title wa_input-element ', ' INTO v_title.
  ENDLOOP.
  v_strlen = STRLEN( v_title ) - 1.
  v_title = v_title+0(v_strlen).
  v_text = v_title.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'RSFINDLST'
    CHANGING
      ct_fieldcat            = it_fcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
* List of tables display
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      i_grid_title       = v_text
      is_layout          = wa_layout
      it_fieldcat        = it_fcat
    TABLES
      t_outtab           = it_founds.
ENDFORM.                    " DISPLAY_RESULT
*&---------------------------------------------------------------------
*&      Form  GET_TABLENAMES
*&---------------------------------------------------------------------
FORM get_tablenames.
* Consolidating selection inputs into an internal table.
  LOOP AT s_type.
    wa_input-element = s_type-low.
    APPEND wa_input TO it_input.
  ENDLOOP.
  APPEND 'P' TO it_object_cls.
* Getting the programs having the input data elements.
  CALL FUNCTION 'RS_EU_CROSSREF'
    EXPORTING
      i_find_obj_cls           = 'DTEL'
      no_dialog                = 'X'
    TABLES
      i_findstrings            = it_input
      o_founds                 = it_founds
    EXCEPTIONS
      not_executed             = 1
      not_found                = 2
      illegal_object           = 3
      no_cross_for_this_object = 4
      batch                    = 5
      batchjob_error           = 6
      wrong_type               = 7
      object_not_exist         = 8
      OTHERS                   = 9.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " GET_TABLENAMES
