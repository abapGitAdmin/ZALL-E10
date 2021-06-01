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

REPORT ztc_object1.

Delete FROM ZTC_T_MYPLANER.
*
*TABLES : rsrd1.
*
*TYPE-POOLS : slis.
*
** Types declaration.
*TYPES : BEGIN OF ty_where,
*          tabname TYPE tabname,
*          fieldname TYPE fieldname,
*          rollname TYPE rollname,
*        END OF ty_where,
*
*        BEGIN OF ty_input,
*          element TYPE char50,
*          element2 TYPE char50,
*
*        END OF ty_input,
*
*        BEGIN OF ty_table,
*          tabname TYPE tabname,
*        END OF ty_table.
*
** Internal tables declaration.
*DATA  : it_founds TYPE TABLE OF rsfindlst,
*        it_object_cls TYPE TABLE OF string,
*        it_where TYPE TABLE OF ty_where,
*        it_input TYPE TABLE OF ty_input,
*        it_fcat TYPE slis_t_fieldcat_alv.
*
** Work areas declaration.
*DATA  : wa_where TYPE ty_where,
*        wa_input TYPE ty_input,
*        wa_fcat TYPE slis_fieldcat_alv,
*        wa_layout TYPE slis_layout_alv,
*        wa_t_inputs TYPE TABLE OF ty_input.
*
** Variables declaration.
*DATA  : v_flag TYPE i,
*        v_title TYPE string,
*        v_text(70) TYPE c,
*        v_strlen TYPE i,
*        v_tabname TYPE tabname.
*
** Selection screen.
*
*
*
** Tables selection
*START-OF-SELECTION.
*  PERFORM get_tablenames.
** Outputing result
*END-OF-SELECTION.
** Displaying the result tables.
*  PERFORM display_result.
**&--------------------------------------------------------------------*
**&      Form  DISPLAY_RESULT
**&--------------------------------------------------------------------*
*FORM display_result .
** ALV grid title creation
*  wa_layout-colwidth_optimize = 'X'.
*  v_title = 'Where used list for-'.
*  LOOP AT it_input INTO wa_input.
*    CONCATENATE v_title wa_input-element ', ' INTO v_title.
*  ENDLOOP.
*  v_strlen = STRLEN( v_title ) - 1.
*  v_title = v_title+0(v_strlen).
*  v_text = v_title.
*  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
*    EXPORTING
*      i_structure_name       = 'RSFINDLST'
*    CHANGING
*      ct_fieldcat            = it_fcat
*    EXCEPTIONS
*      inconsistent_interface = 1
*      program_error          = 2
*      OTHERS                 = 3.
*  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.
** List of tables display
*  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
*    EXPORTING
*      i_callback_program = sy-repid
*      i_grid_title       = v_text
*      is_layout          = wa_layout
*      it_fieldcat        = it_fcat
*    TABLES
*      t_outtab           = it_founds.
*ENDFORM.                    " DISPLAY_RESULT
**&---------------------------------------------------------------------
**&      Form  GET_TABLENAMES
**&---------------------------------------------------------------------
*FORM get_tablenames.
** Consolidating selection inputs into an internal table.
*  SELECT rollname from dd04l where rollname like '/IDXGC/%'
*    into TABLE @DATA(results) UP TO 5 ROWS.
*
*    LOOP AT results INTO wa_input.
*      APPEND wa_input-element TO it_input.
*      ENDLOOP.
*
*
**    wa_input-element = '/IDXGC/CAPCHK_STATUS'.
**    APPEND wa_input TO it_input.
*
*  APPEND 'P' TO it_object_cls.
** Getting the programs having the input data elements.
*  CALL FUNCTION 'RS_EU_CROSSREF'
*    EXPORTING
*      i_find_obj_cls           = 'DTEL'
*      no_dialog                = 'X'
*    TABLES
*      i_findstrings            = it_input
*      o_founds                 = it_founds
*    EXCEPTIONS
*      not_executed             = 1
*      not_found                = 2
*      illegal_object           = 3
*      no_cross_for_this_object = 4
*      batch                    = 5
*      batchjob_error           = 6
*      wrong_type               = 7
*      object_not_exist         = 8
*      OTHERS                   = 9.
*  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.
*ENDFORM.                    " GET_TABLENAMES
*
*
*
*
*





















**
**
***LOOP AT itab ASSIGNING FIELD-SYMBOL(<fs>).
***
***<fs>-carrid = 'TT'.
***
***
***
***
***
***
***ENDLOOP.
**
**
**
**LOOP AT itab INTO DATA(wa).
**
**wa-carrid = 'TT'.
**
**
**MODIFY itab FROM wa.
**
**
**
**ENDLOOP.
**
**



























*DATA: index TYPE i.
*DO 20 TIMES.
*  index = sy-index * 5.
*
*  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
*    EXPORTING
*      percentage = index
*      text       = 'Bitte warten ...'.
*
*  WAIT UP TO 1 SECONDS.
*ENDDO.

* int - Zufallszahlen von 0...100 erzeugen















*CONSTANTS: co_max TYPE i VALUE 1000000.
*
*START-OF-SELECTION.
*  DATA(o_progress) = cl_akb_progress_indicator=>get_instance( ).
*
*  DO co_max TIMES.
*    o_progress->display( force_display = abap_false
*                         total         = co_max
*                         processed     = sy-index
*                         message       = 'Bitte warten...' ).
*  ENDDO.
*




.


*DELETE from ztc_table.
*IF sy-subrc <> 0.
*  write 'fail'.
*ELSE.
*  WRITE 'Success'.
*ENDIF.

*
*CLASS lcl_wasserbehaelter DEFINITION.
*
*PUBLIC SECTION.
*METHODS get_wasserstand
* RETURNING
*   value(ed_wasserstand) TYPE i.
*
*CONSTANTS gc_wasser_haerte_grenze TYPE f VALUE '14,0'.
*
*
*PROTECTED SECTION.
*PRIVATE SECTION.
*
*DATA gd_wasserstand TYPE i.
*
*ENDCLASS.
*
*
*
*CLASS lcl_wasserbehaelter IMPLEMENTATION.
*
*METHOD get_wasserstand.
*
*  ENDMETHOD.
*
*ENDCLASS.
*
*
*
*
*
*CLASS lcl_kaffevollautomat DEFINITION.
*
*PUBLIC SECTION.
*
*
*CLASS-DATA: anz_kva TYPE i.
*
* METHODS ein_kaffee_sil_vous_plait
* IMPORTING
*   VALUE(id_espresso) TYPE abap_bool OPTIONAL
*   VALUE(id_verlaengerter) TYPE abap_bool OPTIONAL.
* CLASS-METHODS add_1_to_anz_kva.
* METHODS constructor.
*
*PROTECTED SECTION.
*
*PRIVATE SECTION.
*"DATA gr_wasserbehaelter TYPE REF TO lcl_wasserbehaelter.
*DATA: gd_wasserstand TYPE i.
*
*
*ENDCLASS.
*
*
*
*CLASS lcl_kaffevollautomat IMPLEMENTATION.
*
*  METHOD constructor.
*    anz_kva = anz_kva + 1.
*    me->add_1_to_anz_kva( ).
*    ENDMETHOD.
*
*METHOD ein_kaffee_sil_vous_plait.
*
*  ENDMETHOD.
*
*
*METHOD add_1_to_anz_kva.
*
*  ENDMETHOD.
*
*
*ENDCLASS.
*
*
*
*"
*DATA gd_zubereitungsart type char40.
*DATA gr_rolands_kva TYPE REF TO lcl_kaffevollautomat.
*DATA gr_mein_kva  TYPE REF TO lcl_kaffevollautomat.
*
*
*
*
*
*START-OF-SELECTION.
*INCLUDE ZTahaInclude.
*
*CREATE OBJECT gr_rolands_kva.
*CREATE OBJECT gr_mein_kva .
