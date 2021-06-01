class ZHACO2CO_SOA_COMPLEXTYPE definition
  public
  inheriting from CL_PROXY_CLIENT
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !LOGICAL_PORT_NAME type PRX_LOGICAL_PORT_NAME optional
    raising
      CX_AI_SYSTEM_FAULT .
  methods ZHA_COMPLEX_TYPE
    importing
      !INPUT type ZHACO2ZHA_COMPLEX_TYPE
    exporting
      !OUTPUT type ZHACO2ZHA_COMPLEX_TYPERESPONSE
    raising
      CX_AI_SYSTEM_FAULT .
protected section.
private section.
ENDCLASS.



CLASS ZHACO2CO_SOA_COMPLEXTYPE IMPLEMENTATION.


  method CONSTRUCTOR.

  super->constructor(
    class_name          = 'ZHACO2CO_SOA_COMPLEXTYPE'
    logical_port_name   = logical_port_name
  ).

  endmethod.


  method ZHA_COMPLEX_TYPE.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'INPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of INPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'OUTPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of OUTPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'ZHA_COMPLEX_TYPE'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.
ENDCLASS.
