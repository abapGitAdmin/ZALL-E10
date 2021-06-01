class /ADZ/CL_CI_TEST_WUL definition
  public
  inheriting from CL_CI_TEST_ROOT
  create public .

*"* public components of class /ADZ/CL_CI_TEST_WUL
*"* do not include other source files here!!!
public section.

  methods CONSTRUCTOR .

  methods GET_MESSAGE_TEXT
    redefinition .
  methods GET_RESULT_NODE
    redefinition .
  methods RUN
    redefinition .
protected section.
*"* protected components of class /ADZ/CL_CI_TEST_WUL
*"* do not include other source files here!!!
private section.
*"* private components of class /ADZ/CL_CI_TEST_WUL
*"* do not include other source files here!!!

  constants C_MY_NAME type SEOCLSNAME value '/ADZ/CL_CI_TEST_WUL' ##NO_TEXT.
ENDCLASS.



CLASS /ADZ/CL_CI_TEST_WUL IMPLEMENTATION.


  METHOD CONSTRUCTOR .

    DATA:
      l_typelist LIKE LINE OF typelist.

    super->constructor( ).

    description         = 'Verwendungsnachweis'(000). "required
    category            = '/ADZ/CL_CI_CATEGORY_ADZ'.  "required
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

    fill_message '0001' c_warning '(&2) &3   &4.'(001) ''.
    fill_message '0002' c_warning 'wird nicht verwendet.'(002) ''.

  ENDMETHOD.                    "CONSTRUCTOR


  METHOD GET_MESSAGE_TEXT .

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

  ENDMETHOD.                    "GET_MESSAGE_TEXT


  METHOD GET_RESULT_NODE.

    CREATE OBJECT p_result TYPE /adz/cl_ci_result_wul
      EXPORTING
        p_kind = p_kind.

  ENDMETHOD.


  METHOD run .

*    Quelle: CL_MDG_GN_BBI->GET_CROSSREF
    DATA: lt_sciobj TYPE TABLE OF /adz/sciobj.
    FIELD-SYMBOLS: <ls_sciobj> TYPE /adz/sciobj.

    DATA: lr_object_type TYPE REF TO cl_wb_object_type,
          ls_tadir       TYPE tadir,
          ls_trdirn      TYPE trdir-name,
          lv_objtype     TYPE euobj-id,
          lv_globaltype  TYPE wbobjtype,
          lv_exttype     TYPE trobjtype,
          lv_inttype     TYPE seu_objtyp.

    DATA: lt_objs TYPE TABLE OF rsfind,
          lt_used TYPE TABLE OF rsfindlst.
    FIELD-SYMBOLS: <ls_objs> LIKE LINE OF lt_objs,
                   <ls_used> LIKE LINE OF lt_used.

    DATA: lv_param_1 TYPE string,
          lv_param_2 TYPE string,
          lv_param_3 TYPE string,
          lv_param_4 TYPE string.

    SELECT * FROM /adz/sciobj INTO TABLE lt_sciobj.
    IF sy-subrc <> 0.
      EXIT. "keine Objekte gefunden, also nichts zu tun
    ENDIF.

    LOOP AT lt_sciobj ASSIGNING <ls_sciobj>.
      CLEAR: lt_objs, lv_objtype.

      "gesuchtes Objekt
      APPEND INITIAL LINE TO lt_objs ASSIGNING <ls_objs>.
      <ls_objs>-object = <ls_sciobj>-obj_name.
      "Typ einschränken
      lv_objtype = <ls_sciobj>-object.

*      Verwendungsnachweis
      CALL FUNCTION 'RS_EU_CROSSREF'
        EXPORTING
          i_find_obj_cls           = lv_objtype
          no_dialog                = 'X'
          with_generated_objects   = 'X'
        TABLES
          i_findstrings            = lt_objs
          o_founds                 = lt_used
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
      IF sy-subrc <> 0 OR lines( lt_used ) = 0 .
*        Wird nicht verwendet
        inform(
          EXPORTING
            p_test         = c_my_name            " Name der Klassse
            p_code         = '0002'               " CHAR04
            p_param_1      = <ls_sciobj>-obj_name " Parameter_1
        ).
      ELSE.
*        Verwendnungsnachweis gefunden
*        Quelle: CL_CI_COLLECTOR_EU->COLLECT
        LOOP AT lt_used ASSIGNING <ls_used>.
          CLEAR: lv_param_1, lv_param_2, lv_param_3, lv_param_4.
          "Verwendetes Objekt
          lv_param_1 = <ls_sciobj>-obj_name.

          "Verwendendes Objekt
          IF <ls_used>-encl_objec NE ''.
            lv_param_3 = <ls_used>-encl_objec.
            lv_param_4 = <ls_used>-object.
          ELSE.
            lv_param_3 = <ls_used>-object.
          ENDIF.

          "Tadir Name und Typ bestimmen
          IF <ls_used>-object_cls = 'P'. "Programme und Funktionsgruppen
            ls_trdirn = lv_param_3.
            CALL FUNCTION 'TR_TRANSFORM_TRDIR_TO_TADIR'
              EXPORTING
                iv_trdir_name       = ls_trdirn
              IMPORTING
                es_tadir_keys       = ls_tadir
              EXCEPTIONS
                invalid_name_syntax = 1
                OTHERS              = 2.
            lv_param_3 = ls_tadir-obj_name.
            lv_param_2 = ls_tadir-object.
          ELSE. "Andere
            lv_inttype = <ls_used>-object_cls.
            lv_param_2 = cl_wb_object_type=>get_r3tr_from_internal_type( EXPORTING p_internal_type = lv_inttype ).
          ENDIF.

          "Eintrag in Ausgabe erzeugen
          IF lv_param_3 CP 'Z*'.
            inform(
              EXPORTING
                p_test         = c_my_name  " Name der Klassse
                p_code         = '0001'     " CHAR04
                p_param_1      = lv_param_1 " Parameter_1 -> verwendetes Objekt
                p_param_2      = lv_param_2 " Parameter_2 -> Tadir Typ des gefundenen/verwendenden Objekts
                p_param_3      = lv_param_3 " Parameter_3 -> Objektname
                p_param_4      = lv_param_4 " Parameter_4 -> evtl. Tabellenfeld, Klassenmethode etc.
            ).
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
