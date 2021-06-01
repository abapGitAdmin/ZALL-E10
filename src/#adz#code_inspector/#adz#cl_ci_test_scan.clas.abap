class /ADZ/CL_CI_TEST_SCAN definition
  public
  inheriting from CL_CI_TEST_SCAN
  create public .

*"* public components of class /ADZ/CL_CI_TEST_SCAN
*"* do not include other source files here!!!
*"* protected components of class /ADZ/CL_CI_TEST_SCAN
*"* do not include other source files here!!!
public section.

  types:
    BEGIN OF t_inform,
             otype  TYPE trobjtype,
             oname  TYPE sobj_name,
             code   TYPE sci_errc,
             param1 TYPE string,
             param2 TYPE string,
             param3 TYPE string,
             param4 TYPE string,
           END OF t_inform .
  types:
    tt_inform TYPE STANDARD TABLE OF t_inform .

  class-data:
    tablist   TYPE SORTED TABLE OF scir_tobj WITH NON-UNIQUE KEY obj_name .

  methods CONSTRUCTOR .

  methods GET_ATTRIBUTES
    redefinition .
  methods GET_MESSAGE_TEXT
    redefinition .
  methods IF_CI_TEST~QUERY_ATTRIBUTES
    redefinition .
  methods PUT_ATTRIBUTES
    redefinition .
  methods RUN
    redefinition .
  methods RUN_BEGIN
    redefinition .
  methods RUN_END
    redefinition .
  methods GET_RESULT_NODE
    redefinition .
protected section.

  data SEARCH_STRINGS type SCI_SRCHSTR .
  data COMMENT_MODE type FLAG .
  data LITERAL_MODE type FLAG .
  data MSGKIND type SYCHAR01 .

  methods SCAN_DDIC .
  methods SCAN_PROGRAM .
  methods INFORM_DDIC
    importing
      !P_SUB_OBJ_TYPE type TROBJTYPE optional
      !P_SUB_OBJ_NAME type SOBJ_NAME optional
      !P_POSITION type INT4 optional
      !P_LINE type TOKEN_ROW optional
      !P_COLUMN type TOKEN_COL optional
      !P_ERRCNT type SCI_ERRCNT optional
      value(P_KIND) type SYCHAR01 optional
      !P_TEST type SEOCLSNAME
      !P_CODE type SCI_ERRC
      !P_SUPPRESS type SCI_PCOM optional
      !P_PARAM_1 type CSEQUENCE optional
      !P_PARAM_2 type CSEQUENCE optional
      !P_PARAM_3 type CSEQUENCE optional
      !P_PARAM_4 type CSEQUENCE optional
      !P_INCLSPEC type SCI_INCLSPEC optional
      !P_DETAIL type XSTRING optional
      !P_CHECKSUM_1 type INT4 optional
      !P_COMMENTS type T_COMMENTS optional .
  methods GET_DDIC .
  methods GET_XINX_INFO
    importing
      !I_XINX_OBJECT type SOBJ_NAME
    exporting
      !E_TABLENAME type SOBJ_NAME
      !E_INDEXNAME type INDEXID .
  methods SCAN_ENHO .
  methods INFORM_ENHO
    importing
      !P_SUB_OBJ_TYPE type TROBJTYPE optional
      !P_SUB_OBJ_NAME type SOBJ_NAME optional
      !P_POSITION type INT4 optional
      !P_LINE type TOKEN_ROW optional
      !P_COLUMN type TOKEN_COL optional
      !P_ERRCNT type SCI_ERRCNT optional
      value(P_KIND) type SYCHAR01 optional
      !P_TEST type SEOCLSNAME
      !P_CODE type SCI_ERRC
      !P_SUPPRESS type SCI_PCOM optional
      !P_PARAM_1 type CSEQUENCE optional
      !P_PARAM_2 type CSEQUENCE optional
      !P_PARAM_3 type CSEQUENCE optional
      !P_PARAM_4 type CSEQUENCE optional
      !P_INCLSPEC type SCI_INCLSPEC optional
      !P_DETAIL type XSTRING optional
      !P_CHECKSUM_1 type INT4 optional
      !P_COMMENTS type T_COMMENTS optional .
*"* private components of class /ADZ/CL_CI_TEST_SCAN
*"* do not include other source files here!!!
private section.

  data:
    sit_dd03l         TYPE STANDARD TABLE OF dd03l WITH DEFAULT KEY .
  data:
    sit_dd02l         TYPE STANDARD TABLE OF dd02l WITH DEFAULT KEY .
  data W_CURRENT_OBJECT type SCIR_TOBJ .
  constants C_MY_NAME type SEOCLSNAME value '/ADZ/CL_CI_TEST_SCAN' ##NO_TEXT.
  constants:
    BEGIN OF c_message_code,
                 syntax_error TYPE sci_errc  VALUE 'SyntError'    ##no_Text,
               END OF c_message_code .
  class-data LAST_TYPE type TROBJTYPE .
  class-data LAST_OBJECT type SOBJ_NAME .

  methods FILL_DD02L .
  methods FILL_DD03L .
  methods DO_INFORM
    importing
      !IT_INFORM type TT_INFORM .
ENDCLASS.



CLASS /ADZ/CL_CI_TEST_SCAN IMPLEMENTATION.


  METHOD constructor .

    DATA:
      l_typelist LIKE LINE OF typelist.

    super->constructor( ).

    description         = 'Source Scan'(000). "required
    category            = '/ADZ/CL_CI_CATEGORY_ADZ'.  "required
    version             = '000'.
    msgkind             = 'N'.
    has_attributes      = c_true.
    attributes_ok       = c_false.

*    "Quelle CL_CI_TEST_DDIC_TABLES->CONSTRUCTOR
*    add_obj_type( c_type_ddic_table ).
*    add_obj_type( 'VIEW' ).
*    add_obj_type( 'XINX' ).
*    "Quelle CL_CI_TEST_FREE_SEARCH...
*    add_obj_type( c_type_program ).

    "alles erlauben, gefiltert wird in RUN
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

    fill_message '0001' c_warning 'Suchstring &1 gefunden in &2'(001) ''.

  ENDMETHOD.                    "CONSTRUCTOR


  METHOD do_inform.

    "Quelle CL_CI_TEST_DDIC_TABLES->DO_INFORM
    FIELD-SYMBOLS <inform> TYPE t_inform.

    LOOP AT it_inform ASSIGNING <inform>.

      object_type = <inform>-otype.
      object_name = <inform>-oname.

      inform_ddic( p_test    = c_my_name
                   p_code    = <inform>-code
                   p_param_1 = <inform>-param1
                   p_param_2 = <inform>-param2
                   p_param_3 = <inform>-param3
                   p_param_4 = <inform>-param4 ).

    ENDLOOP.

  ENDMETHOD.


  METHOD fill_dd02l.

    DATA: lt_dd02l         TYPE TABLE OF dd02l,
          lt_scope         TYPE RANGE OF string,
          ls_scope         LIKE LINE OF lt_scope,
          lv_search_string LIKE LINE OF search_strings.

    LOOP AT search_strings INTO lv_search_string.
      ls_scope-sign   = 'I'.
      ls_scope-option = 'CP'.
      ls_scope-low    = lv_search_string.
      APPEND ls_scope TO lt_scope.
    ENDLOOP.

    SELECT *
      FROM dd02l
      INTO TABLE sit_dd02l
      WHERE sqltab IN lt_scope. "für Appendstrukturen

  ENDMETHOD.


  METHOD fill_dd03l.

    DATA: lt_dd03l         TYPE TABLE OF dd03l,
          lt_scope         TYPE RANGE OF string,
          ls_scope         LIKE LINE OF lt_scope,
          lv_search_string LIKE LINE OF search_strings.

    LOOP AT search_strings INTO lv_search_string.
      ls_scope-sign   = 'I'.
      ls_scope-option = 'CP'.
      ls_scope-low    = lv_search_string.
      APPEND ls_scope TO lt_scope.
    ENDLOOP.

    SELECT *
      FROM dd03l
      INTO TABLE sit_dd03l
      WHERE rollname  IN lt_scope OR
            domname   IN lt_scope OR
            precfield IN lt_scope.

  ENDMETHOD.


  METHOD get_attributes.

    "Quelle: CL_CI_TEST_FREE_SEARCH->GET_ATTRIBUTES
    EXPORT literal_mode   = literal_mode
           comment_mode   = comment_mode
           search_strings = search_strings
           msgkind        = msgkind
           TO DATA BUFFER p_attributes.

  ENDMETHOD.


  METHOD get_ddic.

    "Quelle CL_CI_TEST_DDIC->GET
    DATA:
      wa_tabl TYPE scir_tobj.

    IF object_name = last_object AND
       object_type = last_type.
      "do nothing
    ELSE.

      IF object_type = 'TABL' OR
         object_type = 'VIEW'.
        wa_tabl-obj_name = object_name.
        wa_tabl-obj_type = object_type.

      ELSEIF object_type = 'XINX'.

        wa_tabl-chk_obj_name = object_name.
        wa_tabl-chk_obj_type = 'XINX'.
        get_xinx_info( EXPORTING i_xinx_object = object_name
                       IMPORTING e_tablename   = wa_tabl-obj_name ).
        wa_tabl-obj_type = 'TABL'.

      ENDIF.

      INSERT wa_tabl INTO TABLE tablist.
      last_object = object_name.
      last_type   = object_type.
    ENDIF.

  ENDMETHOD.


  METHOD get_message_text .

    IF line_exists( scimessages[ test = p_test
                                 code = p_code ] ).
      p_text = scimessages[ test = p_test
                            code = p_code ]-text.
    ELSE.
      super->get_message_text( EXPORTING p_test = p_test
                                         p_code = p_code
                               IMPORTING p_text = p_text ).
    ENDIF.

  ENDMETHOD.                    "GET_MESSAGE_TEXT


  METHOD get_result_node.

    IF object_type = 'ENHO'.
      "Quelle CL_CI_TEST_SYNTAX_ENH_PROG->GET_RESULT_NODE
      CREATE OBJECT p_result TYPE /adz/cl_ci_result_scan
        EXPORTING
          p_kind = ''.
    ELSE.
      p_result = super->get_result_node( p_kind = p_kind ).
    ENDIF.

  ENDMETHOD.


  METHOD get_xinx_info.

    "Quelle CL_CI_TEST_DDIC->GET_XINX_INFO
    DATA l_tabname TYPE string.
    DATA l_indexname TYPE string.


    SPLIT i_xinx_object AT space INTO l_tabname l_indexname.
    CONDENSE: l_tabname, l_indexname.
    IF l_indexname = ''.
      l_tabname   = i_xinx_object(10).
      l_indexname = i_xinx_object+10(3).
    ENDIF.

    e_tablename = l_tabname.
    e_indexname = l_indexname.

  ENDMETHOD.


  METHOD if_ci_test~query_attributes.

    "Quelle: CL_CI_TEST_FREE_SEARCH->IF_CI_TEST~QUERY_ATTRIBUTES
    DATA:
      l_attributes     TYPE sci_atttab,
      l_attribute      LIKE LINE OF l_attributes,
      l_comment_mode   LIKE comment_mode,
      l_literal_mode   LIKE literal_mode,
      l_msgkind        LIKE msgkind,
      l_search_strings LIKE search_strings,
      l_search_string  LIKE LINE OF search_strings,
      l_strlen         TYPE i,
      l_message(72)    TYPE c.

    DEFINE fill_att.
      GET REFERENCE OF &1 INTO l_attribute-ref.
      l_attribute-text = &2.
      l_attribute-kind = &3.
      APPEND l_attribute TO l_attributes.
    end-of-definition.

    l_search_strings = search_strings.
    l_msgkind        = msgkind.
    l_comment_mode   = comment_mode.
    l_literal_mode   = literal_mode.

    l_strlen = 0.

*-- fill attribute table
*FILL_ATT L_CHAR    'Char'(211)       ' '.
*FILL_ATT L_NUM     'Numerisch'(212)  ' '.
*FILL_ATT L_STRUCT  'Struktur'(213)   ' '.

    fill_att l_comment_mode   'Kommentare'(202)       'C'.
    fill_att l_literal_mode   'Literale'(203)         'C'.
    fill_att l_msgkind        'Art der Meldung'(205)  ' '.
    fill_att l_search_strings 'Suchstring(s)'(204)    ' '.

*-- only search with 2 letters minimum
    DO.
      l_strlen = 999999.
      IF cl_ci_query_attributes=>generic(
                            p_name       = 'CL_CI_TEST_FREE_SEARCH'
                            p_title      = 'Meine Selektionen'(005)
                            p_attributes = l_attributes
                            p_message    = l_message
                            p_display    = p_display ) = 'X'.
*-- = 'X' --> 'Exit' Button pressed on PopUp
        RETURN.
      ENDIF.
      IF l_search_strings IS INITIAL.
        l_message = 'Bitte mindestens einen Suchstring angeben'(902).
        l_strlen = 0.
      ELSE.
        LOOP AT l_search_strings INTO l_search_string.
          TRANSLATE l_search_string USING '* + '.
          CONDENSE l_search_string NO-GAPS.
          IF strlen( l_search_string ) < l_strlen.
            l_strlen = strlen( l_search_string ).
          ENDIF.
        ENDLOOP.

        IF l_strlen < 2.
          l_message = 'Bitte mindestens 2 Buchstaben eingeben'(901).
        ELSE.
          CASE l_msgkind.
            WHEN 'E' OR 'W' OR 'N'.
              EXIT.
            WHEN OTHERS.
              l_message = 'Meldungsart nur E, W oder N'(903).
          ENDCASE.
        ENDIF.
      ENDIF.
    ENDDO.

    search_strings = l_search_strings.
    msgkind        = l_msgkind.
    literal_mode   = l_literal_mode.
    comment_mode   = l_comment_mode.
    attributes_ok  = c_true.

  ENDMETHOD.


  METHOD inform_ddic .

    "Quelle CL_CI_TEST_DDIC->INFORM
    DATA: wa_exceptlist  TYPE sciexceptn,                   "#EC NEEDED
          l_suppress     TYPE c,
          l_tabix        TYPE sy-tabix,
          l_pcom         TYPE sci_pcom,
          l_kind         TYPE sci_errty,
          l_sub_obj_name TYPE sobj_name,
          l_sub_obj_type TYPE trobjtype,
          lt_chk_sum     TYPE STANDARD TABLE OF char80 INITIAL SIZE 4,
          wa_chk_sum     TYPE char80,
          l_crc_value    TYPE sci_crc64,
          l_prio_wa      TYPE scipriorities.

    CLASS cl_ci_exception DEFINITION LOAD.

    IF NOT p_sub_obj_name IS SUPPLIED.
      l_sub_obj_name = object_name.
      l_sub_obj_type = object_type.
    ELSE.
      l_sub_obj_name = p_sub_obj_name.
      l_sub_obj_type = p_sub_obj_type.
    ENDIF.

*-- has check filled the SCI code<->message table ?
    READ TABLE scimessages INTO smsg
         WITH TABLE KEY test = p_test
                        code = p_code.
    IF sy-subrc = 0.
      l_kind = smsg-kind.
      l_pcom = smsg-pcom.
    ELSE.
*-- else take parameters from check method run
      l_kind = p_kind.
      l_pcom = p_suppress.
    ENDIF.

*-- is priority (KIND) customized ?
    READ TABLE cust_priorities INTO l_prio_wa
         WITH TABLE KEY checkname = p_test
                        checkcode = p_code
         TRANSPORTING custom_prio.
    IF sy-subrc = 0.
      l_kind = l_prio_wa-custom_prio.
    ENDIF.

**-- shall message be modified by object classification?
    IF ignore_objclsfctn = c_false.

      CALL METHOD cl_ci_provide_object_clsfctn=>modify_prio_by_clsfctn
        EXPORTING
          p_test         = p_test
          p_code         = p_code
          p_obj_type     = object_type
          p_obj_name     = object_name
          p_sub_obj_type = p_sub_obj_type
          p_sub_obj_name = p_sub_obj_name
        CHANGING
          p_kind         = l_kind
          p_pcom         = l_pcom.

    ENDIF.
**------------------------------------------------------

    IF l_kind = 'O'.
      RETURN.
    ENDIF.

*--exceptions only possible for certain pseudocomments
    IF NOT ( l_pcom = c_exceptn_imposibl OR
             l_pcom = '' ).

*--exceptions for tables are always done by table entry
      l_suppress = c_te_exceptn_posibl.

*-----get checksum for message - must be done anyway to save checksum
      CLEAR: lt_chk_sum, l_crc_value.
      wa_chk_sum = p_param_1. APPEND wa_chk_sum TO lt_chk_sum.
      wa_chk_sum = p_param_2. APPEND wa_chk_sum TO lt_chk_sum.
      wa_chk_sum = p_param_3. APPEND wa_chk_sum TO lt_chk_sum.
      wa_chk_sum = p_param_4. APPEND wa_chk_sum TO lt_chk_sum.

      LOOP AT lt_chk_sum INTO wa_chk_sum.
        CALL METHOD cl_ci_provide_checksum=>gen_chksum_from_chars
          EXPORTING
            p_param     = wa_chk_sum
          CHANGING
            p_crc_value = l_crc_value
          EXCEPTIONS
*           PARAMETER_ERROR = 1
            OTHERS      = 2.
        IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.

      ENDLOOP.

      IF exceptlist_read <> 'X' AND
         tablist IS NOT INITIAL.
        SELECT * FROM sciexceptn INTO TABLE exceptlist
                 FOR ALL ENTRIES IN tablist WHERE
                 objname  = tablist-obj_name
             AND objtype  = tablist-obj_type
             ORDER BY PRIMARY KEY.
        exceptlist_read = 'X'.
      ENDIF.

*-- is there at all 1 exception for this object ?
      READ TABLE exceptlist INTO wa_exceptlist BINARY SEARCH WITH KEY
                 objname  = object_name
                 objtype  = object_type.
      IF sy-subrc = 0.
        l_tabix = sy-tabix.
        LOOP AT exceptlist INTO wa_exceptlist FROM l_tabix
                WHERE objname  = object_name
                  AND objtype  = object_type
                AND ( subobjname = l_sub_obj_name OR subobjname = space )
                AND ( subobjtype = l_sub_obj_type OR subobjtype = space )
               AND ( chkcategory = category      OR chkcategory = space )
                  AND ( chkclass = myname           OR chkclass = space )
                  AND ( chkcode  = p_code           OR chkcode  = space )
                  AND ( i1 = l_crc_value-i1         OR i1 = 0 ).
*----------   and ( I2 = l_crc_value-I2         or I2 = 0 ).
          l_suppress = c_te_exceptn_exists.
          EXIT.
        ENDLOOP.
      ENDIF.

    ELSE.
      l_suppress = ''.
    ENDIF.

    RAISE EVENT message
      EXPORTING
        p_sub_obj_type = l_sub_obj_type
        p_sub_obj_name = l_sub_obj_name
        p_line         = p_line
        p_column       = p_column
        p_errcnt       = p_errcnt
        p_kind         = l_kind
        p_test         = p_test
        p_code         = p_code
        p_suppress     = l_suppress
        p_param_1      = p_param_1
        p_param_2      = p_param_2
        p_param_3      = p_param_3
        p_param_4      = p_param_4
        p_checksum_1   = l_crc_value-i1.

  ENDMETHOD.                    "


  METHOD inform_enho.

    "Quelle CL_CI_TEST_ROOT->INFORM
    DATA:
      l_suppress        TYPE abap_bool,
      l_kind            LIKE p_kind,
      l_customized_prio LIKE LINE OF cust_priorities.

    " custom prio > given prio > default prio
    READ TABLE cust_priorities INTO l_customized_prio
      WITH TABLE KEY
        checkname = p_test
        checkcode = p_code.
    IF sy-subrc  = 0.
      l_kind = l_customized_prio-custom_prio.
    ELSE.
      READ TABLE scimessages INTO smsg
        WITH TABLE KEY
          test = p_test
          code = p_code.
      IF sy-subrc = 0.
        l_kind = smsg-kind.
      ELSE.
        l_kind = p_kind.
      ENDIF.
    ENDIF.

    IF l_kind = 'O'.
      RETURN.
    ENDIF.

    CASE p_suppress.
      WHEN c_pc_exceptn_exists OR abap_true.
        l_suppress = c_pc_exceptn_exists.
    ENDCASE.

    RAISE EVENT message
      EXPORTING
        p_sub_obj_type = p_sub_obj_type
        p_sub_obj_name = p_sub_obj_name
        p_line         = p_line
        p_column       = p_column
        p_errcnt       = p_errcnt
        p_kind         = l_kind
        p_test         = p_test
        p_code         = p_code
        p_suppress     = l_suppress
        p_param_1      = p_param_1
        p_param_2      = p_param_2
        p_param_3      = p_param_3
        p_param_4      = p_param_4
        p_detail       = p_detail
        p_checksum_1   = p_checksum_1.

  ENDMETHOD.


  METHOD put_attributes.

    "Quelle: CL_CI_TEST_FREE_SEARCH->PUT_ATTRIBUTES
    IMPORT literal_mode   = literal_mode
           comment_mode   = comment_mode
           search_strings = search_strings
           msgkind        = msgkind
           FROM DATA BUFFER p_attributes.

  ENDMETHOD.


  METHOD run .

    CASE object_type.
      WHEN 'CLAS' OR 'FUGR' OR 'PROG' OR 'INTF' OR 'TYPE' OR 'WDYN'.
        scan_program( ).
      WHEN 'TABL' OR 'VIEW'.
        scan_ddic( ).
      WHEN 'ENHO'.
        scan_enho( ).
      WHEN OTHERS.
        "TODO
    ENDCASE.

  ENDMETHOD.


  METHOD run_begin.

    super->run_begin( ).

    "Quelle CL_CI_TEST_DDIC_TABLES->RUN_BEGIN
    CLEAR: tablist, last_type, last_object, exceptlist.

  ENDMETHOD.


  METHOD run_end.

    super->run_end( ).

    "Quelle CL_CI_TEST_DDIC_TABLES->RUN_END (mit Änderungen)
    DATA l_viewdd TYPE sci_view.
    DATA l_idx TYPE scir_idx.
    DATA l_has_secondary_index TYPE flag.
    DATA l_client_dependend    TYPE flag.
    DATA lt_dfies    TYPE ddfields.
    DATA lt_x031l    TYPE STANDARD TABLE OF x031l.
    DATA l_x030l     TYPE x030l.
    DATA lrc_nametab TYPE sy-subrc.
    DATA ltc_inform TYPE tt_inform.
    DATA lt_total_inform TYPE tt_inform.

    FIELD-SYMBOLS <tabdd> TYPE sci_tabdd.

    IF tablist IS INITIAL.
      RETURN.
    ELSE.
      DELETE ADJACENT DUPLICATES FROM tablist COMPARING ALL FIELDS.
    ENDIF.

    DATA cref TYPE REF TO lcl_checks.
    cref = lcl_checks=>get_instance( EXPORTING p_parent = me ).

    IF sit_dd02l IS INITIAL.
      fill_dd02l( ).
    ENDIF.

    IF sit_dd03l IS INITIAL.
      fill_dd03l( ).
    ENDIF.

    LOOP AT tablist INTO w_current_object.

      IF w_current_object-chk_obj_name = ''.
        object_type = w_current_object-obj_type.
        object_name = w_current_object-obj_name.
      ELSE.
        object_type = w_current_object-chk_obj_type.
        object_name = w_current_object-chk_obj_name.
      ENDIF.

      IF object_type = 'VIEW'.
        cl_ci_provide_cds_info=>check_is_cds_view( EXPORTING p_tabname  = object_name(30)
                                                   IMPORTING p_cds_info = DATA(cds_info) ).
        IF cds_info-is_cds_object = abap_true.
          CONTINUE.
        ENDIF.
      ENDIF.

      cref->chk_scan( IMPORTING et_inform = ltc_inform ).
      APPEND LINES OF ltc_inform TO lt_total_inform.

    ENDLOOP.

    IF lt_total_inform IS NOT INITIAL.
      do_inform( lt_total_inform ).
    ENDIF.

  ENDMETHOD.


  METHOD scan_ddic.

    "Quelle CL_CI_TEST_DDIC_TABLES->RUN
    get_ddic( ).

  ENDMETHOD.


  METHOD scan_enho.

    "Quelle CL_CI_TEST_SYNTAX_ENH_PROG->RUN (mit Änderungen)
    DATA: lv_search_string LIKE LINE OF search_strings,
          lv_found_string  TYPE string.
    TYPES:
      BEGIN OF ty_syntax_error,
        obj_type         TYPE tadir-object,
        obj_name         TYPE tadir-obj_name,
        adt_resource_uri TYPE string,
        message          TYPE string,
        line             TYPE i,
        token            TYPE string,
      END OF ty_syntax_error.
    DATA:
      enh_programs TYPE enh_program_it,
      syntax_error TYPE ty_syntax_error,
      dummy        TYPE c LENGTH 1.
    FIELD-SYMBOLS:
      <enh_program> TYPE enh_program.

    enh_programs = lcl_repository_access=>get_enhanced_programs( object_name ).

    LOOP AT search_strings INTO lv_search_string.
      LOOP AT enh_programs ASSIGNING <enh_program> WHERE obj_name CP lv_search_string.
        inform_enho(
          p_sub_obj_type = object_type "PROG, CLAS, ...
          p_sub_obj_name = object_name
          p_test         = c_my_name
          p_code         = '0001'
          p_param_1      = lv_search_string
          p_param_2      = <enh_program>-obj_name ).
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.


  METHOD scan_program.

    "Quelle: CL_CI_TEST_FREE_SEARCH->RUN
    DATA:
      l_include       TYPE sobj_name,
      l_row           TYPE token_row,
      l_column        TYPE token_col,
      l_tokennr       LIKE statement_wa-from,
      l_code          TYPE sci_errc,
      l_search_string LIKE LINE OF search_strings,
      l_position      TYPE i.

    "experimentel
    IF object_type = 'TYPE'.
      CONCATENATE '%_C' object_name INTO program_name.
    ELSEIF object_type = 'WDYN'.
      TRY.
          program_name = cl_wdy_test_tool_api=>get_program_name( object_name ).
        CATCH cx_wdy_test_api ##no_handler.
      ENDTRY.
    ENDIF.

    IF search_strings IS INITIAL.
      RETURN.
    ENDIF.

    IF ref_scan IS INITIAL.
      CHECK get( ) = 'X'.
    ENDIF.

    CHECK ref_scan->subrc = 0.

*-- loop at all tokens
    LOOP AT ref_scan->statements INTO statement_wa.
      CHECK statement_wa-from <= statement_wa-to.
      l_position = sy-tabix.
      IF statement_wa-type = 'S' OR
         statement_wa-type = 'P'.
        CHECK comment_mode = 'X'.
      ENDIF.

      LOOP AT ref_scan->tokens INTO token_wa
             FROM statement_wa-from TO statement_wa-to.
        l_tokennr = sy-tabix.
        IF token_wa-type = 'S'.
          CHECK literal_mode = 'X'.
        ENDIF.

        LOOP AT search_strings INTO l_search_string.
*-- does ABAP-string contain search-string ?
          IF token_wa-str CP l_search_string.
            UNPACK sy-tabix TO l_code(4).
            l_include = get_include( ).

            l_row     = get_line_abs( l_tokennr ).
            l_column  = get_column_abs( l_tokennr ).

            inform( p_sub_obj_type = c_type_include
                    p_sub_obj_name = l_include
                    p_position     = l_position
                    p_line         = l_row
                    p_column       = l_column
                    p_kind         = msgkind
                    p_test         = c_my_name
                    p_code         = '0001'
                    p_suppress     = '"#EC CI_NOFIND '
                    p_param_1      = l_search_string "DR
                    p_param_2      = token_wa-str ).
            EXIT.
          ENDIF.     "l_strpos > l_pos
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
