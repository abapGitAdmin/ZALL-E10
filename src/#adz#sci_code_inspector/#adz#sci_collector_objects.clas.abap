class /ADZ/SCI_COLLECTOR_OBJECTS definition
  public
  inheriting from CL_CI_COLLECTOR_ROOT
  final
  create public .

public section.

*"* public components of class /ADZ/SCI_COLLECTOR_OBJECTS
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

  data GV_SAPOBJ type FLAG .
  data NAMESPACES type SCIT_NAMESPACE .
  data OBJTYPES type SCIT_OBJT .
  data OBJNAMES type SCIT_OBJN .
  data DEVCLASSES type SCIT_DEVC .
  data RESPONSIBLES type SCIT_RESP .
ENDCLASS.



CLASS /ADZ/SCI_COLLECTOR_OBJECTS IMPLEMENTATION.


  METHOD CONSTRUCTOR.

    super->constructor( ).

    description = 'adesso-orange Objektkollektor für beliebige Objekte'(000).
    position    = '999'.
    version     = '000'.
    has_attributes       = abap_true.
    attributes_ok        = abap_false.

  ENDMETHOD.


  METHOD IF_CI_COLLECTOR~COLLECT.
    DATA:
      ls_object       TYPE scir_objs,
      lt_objects      TYPE TABLE OF /adz/sci_objects,
      ls_objtypes     TYPE scir_objt,
      lt_objtypes     TYPE scit_objt,
      ls_objnames     TYPE scir_objn,
      lt_objnames     TYPE scit_objn,
      ls_devclasses   TYPE scir_devc,
      lt_devclasses   TYPE scit_devc,
      ls_responsibles TYPE scir_resp,
      lt_responsibles TYPE scit_resp.

    FIELD-SYMBOLS: <ls_object> TYPE /adz/sci_objects.

    IF lines( p_confine_objtypes ) > 0 OR
       lines( p_confine_objnames ) > 0 OR
       lines( p_confine_devclasses ) > 0 OR
       lines( p_confine_responsibles ) > 0.
      MESSAGE ID 'SCI' TYPE 'E' NUMBER '071' WITH name
      RAISING invalid_input.
    ENDIF.

    LOOP AT namespaces ASSIGNING FIELD-SYMBOL(<ls_name>).
      ls_objnames-sign = 'I'.
      ls_objnames-option = 'CP'.
      ls_objnames-low = |{ <ls_name> }*|.
      APPEND ls_objnames TO objnames.
    ENDLOOP.

    SELECT * FROM tadir INTO CORRESPONDING FIELDS OF TABLE lt_objects
      WHERE object   IN objtypes
        AND obj_name IN objnames
        AND devclass IN devclasses
        AND author   IN responsibles.
    IF lines( lt_objects ) = 0.
      MESSAGE ID 'SCI' TYPE 'W' NUMBER '070' WITH name
      RAISING no_object_found.
    ENDIF.

    IF gv_sapobj <> abap_true.
      LOOP AT lt_objects ASSIGNING <ls_object>.
        ls_object-objtype = <ls_object>-object.
        ls_object-objname = <ls_object>-obj_name.
        ls_object-prgname = cl_ci_objectset=>get_program( p_pgmid   = 'R3TR'
                                                          p_objtype = <ls_object>-object
                                                          p_objname = <ls_object>-obj_name ).
*        l_object-params = l_obj_params.
*        cl_ci_objectset=>mark_object( changing p_object = l_object ).
        APPEND ls_object TO p_objslist.
      ENDLOOP.
    ELSE.
      LOOP AT lt_objects ASSIGNING <ls_object>.
        <ls_object>-row_id = sy-tabix.
      ENDLOOP.
      DELETE FROM /adz/sci_objects.
      INSERT /adz/sci_objects FROM TABLE lt_objects.
      IF sy-subrc <> 0.
        MESSAGE ID 'SCI' TYPE 'E' NUMBER '072' WITH name
        RAISING collector_error.
      ENDIF.

      ls_object-objtype = 'TABL'.
      ls_object-objname = '/ADZ/SCI_OBJECTS'.
      APPEND ls_object TO p_objslist.
    ENDIF.

  ENDMETHOD.


  METHOD IF_CI_COLLECTOR~GET_ATTRIBUTES ##NEEDED.
    EXPORT
      namespaces     = namespaces
      objtypes       = objtypes
      objnames       = objnames
      devclasses     = devclasses
      responsibles   = responsibles
      gv_sapobj      = gv_sapobj
    TO DATA BUFFER p_attributes.
  ENDMETHOD.


  METHOD IF_CI_COLLECTOR~PUT_ATTRIBUTES ##NEEDED.
    IMPORT
      namespaces     = namespaces
      objtypes       = objtypes
      objnames       = objnames
      devclasses     = devclasses
      responsibles   = responsibles
      gv_sapobj      = gv_sapobj
    FROM DATA BUFFER p_attributes.
  ENDMETHOD.


  METHOD IF_CI_COLLECTOR~QUERY_ATTRIBUTES ##needed.
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

    fill_att sy-index     'Prüfparameter'(001)    'G'.
    fill_att namespaces   'Namensräume'(002)      'C'.
    fill_att objtypes     'Objekttyp'(003)        'S'.
    fill_att objnames     'Objektname'(004)       'S'.
    fill_att devclasses   'Paket'(005)            'S'.
    fill_att responsibles 'Verantwortlicher'(006) 'S'.
    fill_att gv_sapobj    'SAP Objekte'(007)      'C'.

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
