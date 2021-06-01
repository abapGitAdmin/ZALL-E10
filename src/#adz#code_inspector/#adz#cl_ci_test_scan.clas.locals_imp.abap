*"* local class implementation for public class
*"* CL_CI_TEST_INCLUDE
*"* use this source file for the implementation part of
*"* local helper classes
CLASS lcl_checks DEFINITION FINAL CREATE PRIVATE.

  PUBLIC SECTION.

    CLASS-DATA oref TYPE REF TO lcl_checks.
    CLASS-DATA pa TYPE REF TO /adz/cl_ci_test_scan.

    CLASS-METHODS get_instance
      IMPORTING p_parent   TYPE REF TO /adz/cl_ci_test_scan
      RETURNING VALUE(ref) TYPE REF TO lcl_checks.

    METHODS chk_scan   EXPORTING et_inform TYPE pa->tt_inform .

  PRIVATE SECTION.

ENDCLASS.
CLASS /adz/cl_ci_test_scan DEFINITION LOCAL FRIENDS lcl_checks.
CLASS lcl_checks IMPLEMENTATION.

  METHOD get_instance.

    IF oref IS NOT BOUND.
      CREATE OBJECT oref.
    ENDIF.
    ref = oref.
    pa = p_parent.

  ENDMETHOD.

  METHOD chk_scan.

    DATA: lv_search_string LIKE LINE OF pa->search_strings,
          lv_found_string  TYPE string.

    CLEAR: et_inform.
    LOOP AT pa->search_strings INTO lv_search_string.
      LOOP AT pa->sit_dd02l ASSIGNING FIELD-SYMBOL(<ls_dd02l>) WHERE tabname = pa->object_name
                                                                 AND sqltab CP lv_search_string.
        et_inform = VALUE #( BASE et_inform
                             ( otype     = pa->object_type
                               oname     = pa->object_name
                               code      = '0001'
                               param1    = lv_search_string
                               param2    = <ls_dd02l>-sqltab ) ).
      ENDLOOP.

      LOOP AT pa->sit_dd03l ASSIGNING FIELD-SYMBOL(<ls_dd03l>) WHERE tabname = pa->object_name
                                                                 AND ( rollname  CP lv_search_string OR
                                                                       domname   CP lv_search_string OR
                                                                       precfield CP lv_search_string ).
        IF <ls_dd03l>-precfield IS INITIAL.
          lv_found_string =  <ls_dd03l>-rollname.
        ELSE.
          lv_found_string =  <ls_dd03l>-fieldname.
        ENDIF.

        et_inform = VALUE #( BASE et_inform
                             ( otype     = pa->object_type
                               oname     = pa->object_name
                               code      = '0001'
                               param1    = lv_search_string
                               param2    = lv_found_string ) ).
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

*"* local class implementation for public class
*"* CL_CI_TEST_INCLUDE
*"* use this source file for the implementation part of
*"* local helper classes
CLASS lcl_repository_access DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS get_enhanced_programs
      IMPORTING
        enhancement_name TYPE csequence
      RETURNING
        VALUE(result)    TYPE enh_program_it .
  PRIVATE SECTION.
ENDCLASS.
CLASS lcl_repository_access IMPLEMENTATION.
* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method CL_ENH_UTIL_PROGRAMS_TO_CHECK=>IF_ENH_PROGRAMS_TO_CHECK~GET_PROGRAMMS_TO_CHECK
* +-------------------------------------------------------------------------------------------------+
* | [--->] ENHNAME                        TYPE        ENHNAME
* | [<-()] PROGRAMS                       TYPE        ENH_PROGRAM_IT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_enhanced_programs.
    DATA:
      enhanced_item  TYPE enh_program,
      enhanced_items TYPE enh_program_it,
      key            TYPE sabp_s_tadir_key,
      keys           TYPE sabp_t_tadir_keys,
      keys_contract  TYPE sabp_t_tadir_keys, "DR 17.05.2021
      programs       TYPE programt,
      text_offset    TYPE i.

    SELECT DISTINCT obj_type obj_name FROM enhobj
      INTO CORRESPONDING FIELDS OF TABLE keys
      WHERE enhname = enhancement_name.

    "DR 17.05.2021
    SELECT DISTINCT obj_type obj_name FROM enhobjcontract
      INTO CORRESPONDING FIELDS OF TABLE keys_contract
      WHERE enhname = enhancement_name.

    LOOP AT keys INTO key.
      CLEAR enhanced_item.
      enhanced_item-obj_name = key-obj_name.
      enhanced_item-obj_type = key-obj_type.

      CASE key-obj_type.
        WHEN 'PROG'. " Report / Module Pool / ....
          enhanced_item-program = key-obj_name.
          INSERT enhanced_item INTO TABLE enhanced_items.
        WHEN 'CLAS'. " Class-Pool
          enhanced_item-program = key-obj_name.
          OVERLAY enhanced_item-program WITH '==============================CP'.
          INSERT enhanced_item INTO TABLE enhanced_items.
        WHEN 'INTF'. " Interface-Pool
          enhanced_item-program = key-obj_name.
          OVERLAY enhanced_item-program WITH '==============================IP'.
          INSERT enhanced_item INTO TABLE enhanced_items.
        WHEN 'FUGR'. " Function Pool
          IF ( '/' EQ key-obj_name(1) AND key-obj_name+1 CS '/' ).
            text_offset = sy-fdpos + 2.
            CONCATENATE
              key-obj_name(text_offset) 'SAPL' key-obj_name+text_offset
              INTO enhanced_item-program.
          ELSE.
            CONCATENATE 'SAPL' key-obj_name INTO enhanced_item-program.
          ENDIF.
          INSERT enhanced_item INTO TABLE enhanced_items.
        WHEN 'TYPE'. " Type Pool
          CONCATENATE '%_C' key-obj_name INTO enhanced_item-program.
          INSERT enhanced_item INTO TABLE enhanced_items.
        WHEN 'REPS'. " Include
          enhanced_item-obj_type = 'PROG'.
          CALL FUNCTION 'RS_GET_MAINPROGRAMS'
            EXPORTING
              dialog       = ' '
              name         = key-obj_name
            TABLES
              mainprograms = programs.
          LOOP AT programs INTO enhanced_item-program.
            INSERT enhanced_item INTO TABLE enhanced_items.
          ENDLOOP.
        WHEN 'WDYN'. "Web Dynpro Component
          TRY.
              enhanced_item-program = cl_wdy_test_tool_api=>get_program_name( key-obj_name ).
              INSERT enhanced_item INTO TABLE enhanced_items.
            CATCH cx_wdy_test_api ##no_handler.
          ENDTRY.
      ENDCASE.
    ENDLOOP.

    "DR 17.05.2021
    LOOP AT keys_contract INTO key.
      CLEAR enhanced_item.
      enhanced_item-obj_name = key-obj_name.
      enhanced_item-obj_type = key-obj_type.

      INSERT enhanced_item INTO TABLE enhanced_items.
    ENDLOOP.

    SORT enhanced_items.
    DELETE ADJACENT DUPLICATES FROM enhanced_items.

    result = enhanced_items.
  ENDMETHOD.

ENDCLASS.
