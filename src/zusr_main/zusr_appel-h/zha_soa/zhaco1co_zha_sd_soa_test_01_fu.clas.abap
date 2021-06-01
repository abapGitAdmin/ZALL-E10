class ZHACO1CO_ZHA_SD_SOA_TEST_01_FU definition
  public
  inheriting from CL_PROXY_CLIENT
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !LOGICAL_PORT_NAME type PRX_LOGICAL_PORT_NAME optional
    raising
      CX_AI_SYSTEM_FAULT .
  methods ZHA_ADD_GET_LOG_INFO
    importing
      !INPUT type ZHACO1ZHA_ADD_GET_LOG_INFO
    exporting
      !OUTPUT type ZHACO1ZHA_ADD_GET_LOG_INFO_RES
    raising
      CX_AI_SYSTEM_FAULT .
  methods ZHA_EXTRACT_LEADING_ZEROS
    importing
      !INPUT type ZHACO1ZHA_EXTRACT_LEADING_ZER1
    exporting
      !OUTPUT type ZHACO1ZHA_EXTRACT_LEADING_ZERO
    raising
      CX_AI_SYSTEM_FAULT .
protected section.
private section.
ENDCLASS.



CLASS ZHACO1CO_ZHA_SD_SOA_TEST_01_FU IMPLEMENTATION.


  method CONSTRUCTOR.

  super->constructor(
    class_name          = 'ZHACO1CO_ZHA_SD_SOA_TEST_01_FU'
    logical_port_name   = logical_port_name
  ).

  endmethod.


  method ZHA_ADD_GET_LOG_INFO.

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
      method_name = 'ZHA_ADD_GET_LOG_INFO'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method ZHA_EXTRACT_LEADING_ZEROS.

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
      method_name = 'ZHA_EXTRACT_LEADING_ZEROS'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.
ENDCLASS.
