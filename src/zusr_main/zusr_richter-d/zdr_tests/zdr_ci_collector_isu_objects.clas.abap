class ZDR_CI_COLLECTOR_ISU_OBJECTS definition
  public
  inheriting from CL_CI_COLLECTOR_ROOT
  final
  create public .

public section.

*"* public components of class ZDR_CI_COLLECTOR_ISU_OBJECTS
*"* do not include other source files here!!!
  methods CONSTRUCTOR .

  methods IF_CI_COLLECTOR~COLLECT
    redefinition .
  methods IF_CI_COLLECTOR~GET_ATTRIBUTES
    redefinition .
  methods IF_CI_COLLECTOR~PUT_ATTRIBUTES
    redefinition .
  methods IF_CI_COLLECTOR~QUERY_ATTRIBUTES
    redefinition .
  protected section.
*"* protected components of class CL_CI_COLLECTOR_CPRO
*"* do not include other source files here!!!
  private section.
*"* private components of class ZDR_CI_COLLECTOR_ISU_OBJECTS
*"* do not include other source files here!!!
    data REGULAR        type FLAG.
    data ENHANCEMENTS   type FLAG.
    data MODIFICATION   type FLAG.
    data TEST_CODE      type FLAG.
    data GENERATED_CODE type FLAG.
    data NAMESPACES     type scit_namespace.
ENDCLASS.



CLASS ZDR_CI_COLLECTOR_ISU_OBJECTS IMPLEMENTATION.


method CONSTRUCTOR.

  super->constructor( ).

  description = 'Selektion von ISU Objekten'(000).
  position    = '999'.
  version     = '000'.
  has_attributes       = abap_true.
  attributes_ok        = abap_false.

endmethod.


  METHOD if_ci_collector~collect.
    DATA:
      l_objects    TYPE TABLE OF zdr_sciobj,
      l_object     LIKE LINE OF p_objslist,
      l_category   TYPE if_sca_code_assignment_service=>ty_category,
      l_obj_params TYPE scit_obj_par,
      l_obj_param  TYPE scir_obj_par,
      ls_objnames  TYPE scir_objn,
      lt_objnames  TYPE TABLE OF scir_objn.

    LOOP AT namespaces ASSIGNING FIELD-SYMBOL(<ls_name>).
      ls_objnames-sign = 'I'.
      ls_objnames-option = 'CP'.
      ls_objnames-low = |{ <ls_name> }*|.
      APPEND ls_objnames TO lt_objnames.
    ENDLOOP.

    SELECT * FROM tadir INTO CORRESPONDING FIELDS OF TABLE l_objects
      WHERE obj_name IN lt_objnames.

    LOOP AT l_objects ASSIGNING FIELD-SYMBOL(<ls_item>).
      <ls_item>-row_id = sy-tabix.
    ENDLOOP.
    DELETE FROM zdr_sciobj.
    INSERT zdr_sciobj FROM TABLE l_objects.
*    IF sy-subrc <> 0.
*
*    ENDIF.


    l_object-objtype = 'TABL'.
    l_object-objname = 'ZDR_SCIOBJ'.
    APPEND l_object TO p_objslist.

  ENDMETHOD.


  METHOD if_ci_collector~get_attributes ##NEEDED.
    EXPORT
      namespaces     = namespaces
    TO DATA BUFFER p_attributes.
  ENDMETHOD.


  METHOD if_ci_collector~put_attributes ##NEEDED.
    IMPORT
      namespaces     = namespaces
    FROM DATA BUFFER p_attributes.
  ENDMETHOD.


  METHOD if_ci_collector~query_attributes ##needed.
    DATA:
      l_attributes  TYPE sci_atttab,
      l_attribute   LIKE LINE OF l_attributes,
      l_message(72) TYPE c,
      l_ok          TYPE flag.

    DEFINE fill_att.
      GET REFERENCE OF &1 INTO l_attribute-ref.
      l_attribute-text = &2.
      l_attribute-kind = &3.
      APPEND l_attribute TO l_attributes.
    end-of-definition.

    fill_att sy-index       'Prüfparameter'(001)     'G'.
    fill_att namespaces     'Namensräume'(007)       'C'.

    IF cl_ci_query_attributes=>generic(
                  p_name       = myname
                  p_title      = 'Prüfparameter'(001)
                  p_attributes = l_attributes
                  p_message    = l_message
                  p_display    = p_display ) = 'X'.
      RETURN.
    ENDIF.

    attributes_ok = l_ok = abap_true.

  ENDMETHOD.
ENDCLASS.
