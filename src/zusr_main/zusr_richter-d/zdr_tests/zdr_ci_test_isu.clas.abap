class ZDR_CI_TEST_ISU definition
  public
  inheriting from CL_CI_TEST_ROOT
  create public .

*"* public components of class ZDR_CI_TEST_ISU
*"* do not include other source files here!!!
public section.

  methods CONSTRUCTOR .

  methods GET_MESSAGE_TEXT
    redefinition .
  methods RUN
    redefinition .
  methods GET_RESULT_NODE
    redefinition .
protected section.
*"* protected components of class ZDR_CI_TEST_ISU
*"* do not include other source files here!!!
private section.
*"* private components of class ZDR_CI_TEST_ISU
*"* do not include other source files here!!!

  constants C_MY_NAME type SEOCLSNAME value 'ZDR_CI_TEST_ISU' ##NO_TEXT.
ENDCLASS.



CLASS ZDR_CI_TEST_ISU IMPLEMENTATION.


METHOD constructor .

  DATA:
    l_typelist LIKE LINE OF typelist.

  super->constructor( ).

  description         = 'Seach for ISU'(000).       "required
  category            = 'ZDR_CI_CATEGORY_ISU'.      "required
  version             = '000'.

  l_typelist-sign   = 'I'.
  l_typelist-option = 'CP'.
  l_typelist-low    = '*'.
  APPEND l_typelist TO typelist.

  DEFINE fill_message.
    CLEAR smsg.
    smsg-test = c_my_name.
    smsg-code = &1.  "message code
    smsg-kind = &2.  "message priority
    smsg-text = &3.  "message text
    smsg-pcom = &4.  "pseudocomment
    INSERT smsg INTO TABLE scimessages.
  end-of-definition.

  fill_message '0001' c_warning 'wird verwendet in &3 &2.'(001) ''.
  fill_message '0002' c_warning 'wird nicht verwendet.'(002) ''.

*  DESCRIPTION    = '<test description>'(001).  "required
*  CATEGORY       = '<category_class>'.         "required
*  VERSION        = '000'.                      "required
*  HAS_ATTRIBUTES = 'X'.                        "optional
*  ATTRIBUTES_OK  = 'X' or ' '.                 "optional

ENDMETHOD.                    "CONSTRUCTOR


METHOD get_message_text .
  IF line_exists( scimessages[ test = p_test
                               code = p_code ] ).
    p_text = scimessages[ test = p_test
                          code = p_code ]-text.
  ELSE.
    super->get_message_text(
      EXPORTING p_test = p_test
                p_code = p_code
      IMPORTING p_text = p_text ).
  ENDIF.

*  DATA:    l_code TYPE sci_errc.
*
*  IF p_test <> myname.
*    super->get_message_text( EXPORTING p_test = p_test
*                                       p_code = p_code
*                             IMPORTING p_text = p_text ).
*    RETURN.
*  ENDIF.
*  l_code = p_code.
*  SHIFT l_code LEFT DELETING LEADING space.
*  CONCATENATE 'String'(100) c_sdn 'was found in line &1'(101) INTO p_text SEPARATED BY space.

*  case P_CODE.
*    when '<errcode_1>'. P_TEXT = '<message text 1>'(001).
*
*    when '<errcode_n>'. P_TEXT = '<message text 2>'(002).
*
*    when others.
*      SUPER->GET_MESSAGE_TEXT( exporting P_TEST = P_TEST P_CODE = P_CODE
*                               importing P_TEXT = P_TEXT ).
*  endcase.
ENDMETHOD.                    "GET_MESSAGE_TEXT


  METHOD get_result_node.

    CREATE OBJECT p_result TYPE zdr_ci_result_isu
      EXPORTING
        p_kind = p_kind.

*    DATA(p_test) = get_result_node( p_kind = p_kind ).
*    APPEND p_test TO p_result-child.

*CALL METHOD SUPER->GET_RESULT_NODE
*  EXPORTING
*    P_KIND   =
*  RECEIVING
*    P_RESULT =
*    .
  ENDMETHOD.


METHOD run .

  DATA:
    l_rsfind    TYPE TABLE OF rsfind,
    l_rsfind_wa TYPE rsfind,
    l_rsfindlst TYPE TABLE OF rsfindlst,
    l_obj_cls   TYPE euobj-id.

  DATA:
    lt_sciobj TYPE TABLE OF zdr_sciobj.

  FIELD-SYMBOLS:
    <ls_sciobj>  TYPE zdr_sciobj,
    <l_rsfind>   LIKE LINE OF l_rsfindlst.

  SELECT * FROM zdr_sciobj INTO TABLE lt_sciobj.

  LOOP AT lt_sciobj ASSIGNING <ls_sciobj>.
    CLEAR: l_rsfind_wa, l_rsfind, l_obj_cls.
    l_rsfind_wa-object = <ls_sciobj>-obj_name.
    APPEND l_rsfind_wa TO l_rsfind.

    l_obj_cls = <ls_sciobj>-object.

    CALL FUNCTION 'RS_EU_CROSSREF'
      EXPORTING
        i_find_obj_cls               = l_obj_cls
        no_dialog                    = 'X'
      TABLES
        i_findstrings                = l_rsfind
        o_founds                     = l_rsfindlst
      EXCEPTIONS
        not_executed                 = 1
        not_found                    = 2
        illegal_object               = 3
        no_cross_for_this_object     = 4
        batch                        = 5
        batchjob_error               = 6
        wrong_type                   = 7
        object_not_exist             = 8
        OTHERS                       = 9.
    IF sy-subrc <> 0 OR lines( l_rsfindlst ) = 0 .
      inform(
        EXPORTING
          p_test         = c_my_name        " Name der Klassse
          p_code         = '0002'           " CHAR04
          p_param_1      = <ls_sciobj>-obj_name " Parameter_1
      ).
    ELSE.
      LOOP AT l_rsfindlst ASSIGNING <l_rsfind>.
        DATA(lv_object_cls) = ''.
        CASE <l_rsfind>-object_cls.
          WHEN 'P'.
            lv_object_cls = 'Programm'.
          WHEN 'OM'.
            lv_object_cls = 'Klassen Methode'.
          WHEN OTHERS.
            lv_object_cls = <l_rsfind>-object_cls.
        ENDCASE.

        IF <ls_sciobj>-obj_name CP 'Z*' OR
           <ls_sciobj>-obj_name CP '/ADO/*'.
          inform(
            EXPORTING
              p_test         = c_my_name         " Name der Klassse
              p_code         = '0001'            " CHAR04
              p_param_1      = <ls_sciobj>-obj_name " Parameter_1
              p_param_2      = <l_rsfind>-object " Parameter_2
              p_param_3      = lv_object_cls     " Parameter_3
              p_param_4      = ''  " Parameter_4
          ).
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

** Based on CL_CI_TEST_FREE_SEARCH->RUN
*  DATA: l_include  TYPE sobj_name,
*        l_line     TYPE token_row,
*        l_column   TYPE token_col,
*        l_tokennr  LIKE statement_wa-from,
*        l_errcnt   TYPE sci_errcnt,
*        l_code     TYPE sci_errc,
*        l_position TYPE i,
*        l_param_1  TYPE string.
*
*  TYPE-POOLS : slis.
*
** Types declaration.
*  TYPES : BEGIN OF ty_where,
*            tabname   TYPE tabname,
*            fieldname TYPE fieldname,
*            rollname  TYPE rollname,
*          END OF ty_where,
*
*          BEGIN OF ty_input,
*            element TYPE rsrd1-ddtype_val,
*          END OF ty_input,
*
*          BEGIN OF ty_table,
*            tabname TYPE tabname,
*          END OF ty_table.
*
** Internal tables declaration.
*  DATA  : it_founds     TYPE TABLE OF rsfindlst,
*          it_object_cls TYPE TABLE OF string,
*          it_where      TYPE TABLE OF ty_where,
*          it_input      TYPE TABLE OF ty_input,
*          it_fcat       TYPE slis_t_fieldcat_alv.
*
** Work areas declaration.
*  DATA  : wa_where    TYPE ty_where,
*          wa_input    TYPE ty_input,
*          wa_fcat     TYPE slis_fieldcat_alv,
*          wa_layout   TYPE slis_layout_alv,
*          wa_t_inputs TYPE TABLE OF ty_input.
*
** Variables declaration.
*  DATA  : v_flag     TYPE i,
*          v_title    TYPE string,
*          v_text(70) TYPE c,
*          v_strlen   TYPE i,
*          v_tabname  TYPE tabname.
*
*
** Get a scan
*  IF ref_scan IS INITIAL.
*    CHECK get( ) = 'X'.
*  ENDIF.
*  CHECK ref_scan->subrc = 0.
*  l_errcnt = 0.
*
** Loop at all tokens
*  LOOP AT ref_scan->statements INTO statement_wa.
*    CHECK statement_wa-from <= statement_wa-to.
*    l_position = sy-tabix.
*    LOOP AT ref_scan->tokens INTO token_wa
*      FROM statement_wa-from TO statement_wa-to.
*      l_tokennr = sy-tabix.
*
**     Search for SDN string
*      IF token_wa-str CS c_sdn.
*        l_include = get_include( ).
*        l_line    = get_line_abs( l_tokennr ).
*        l_column  = get_column_abs( l_tokennr ).
*        l_errcnt  = l_errcnt + 1.
*        l_code    = '0001'.
*        l_param_1 = l_line.
*
**       Inform
*        inform( p_sub_obj_type = c_type_include
*                p_sub_obj_name = l_include
*                p_position     = l_position
*                p_line         = l_line
*                p_column       = l_column
*                p_errcnt       = l_errcnt
*                p_kind         = c_note
*                p_test         = c_my_name
*                p_code         = l_code
*                p_suppress     = '"#EC CI_SDN'
*                p_param_1      = l_param_1 ).
*        EXIT.
*      ENDIF.
*    ENDLOOP.
*  ENDLOOP.
*
*
** Consolidating selection inputs into an internal table.
*  SELECT rollname FROM dd04l WHERE rollname LIKE '/IDXGC/%'
*    INTO TABLE @DATA(results).
*
*  LOOP AT results INTO wa_input.
*
*    APPEND wa_input-element TO it_input.
*  ENDLOOP.
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
*
** ALV grid title creation
*  wa_layout-colwidth_optimize = 'X'.
*  v_title = 'Where used list for-'.
*  LOOP AT it_input INTO wa_input.
*    CONCATENATE v_title wa_input-element ', ' INTO v_title.
*  ENDLOOP.
*  v_strlen = strlen( v_title ) - 1.
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


* Test
* Test-Object-Name supplied in
*   OBJECT_TYPE
*   OBJECT_NAME
* Program name supplied in
*   PROGRAM_NAME
*
*result of tests by raise event:
*
*INFORM( P_INCLUDE  = <include>
*        P_LINE     = <line>
*        P_COLUMN   = <column>
*        P_ERRCNT   = L_ERRCNT
*        P_KIND     = C_ERROR / C_WARNING / C_NOTE
*        P_TEST     = MY_NAME
*        P_CODE     = <error code>
*        P_PARAM_1  = <parameter 1>
*        P_PARAM_2  = <parameter 2>
*        P_PARAM_3  = <parameter 3>
*        P_PARAM_4  = <parameter 4> )
* add 1 to L_ERRCNT.
    " Dummy-Statement to avoid SLIN-Errors
    " write C_MY_NAME.

  ENDMETHOD.
ENDCLASS.
