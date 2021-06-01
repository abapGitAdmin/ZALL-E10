class ZCL_RT_TEST_DPC_EXT definition
  public
  inheriting from ZCL_RT_TEST_DPC
  create public .

public section.
protected section.

  methods HEAD_DATASET_GET_ENTITYSET
    redefinition .
  methods HEAD_DATASET_GET_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_RT_TEST_DPC_EXT IMPLEMENTATION.


  METHOD head_dataset_get_entity.

    READ TABLE it_key_tab ASSIGNING FIELD-SYMBOL(<is_key_tab>) INDEX 1.
    IF <is_key_tab> IS ASSIGNED.
      SELECT SINGLE * FROM zkerk_zakopfdat WHERE nummer_zahlungsanweisung = @<is_key_tab>-value INTO @er_entity.
    ENDIF.

  ENDMETHOD.


  METHOD head_dataset_get_entityset.

    SELECT * FROM zkerk_zakopfdat INTO CORRESPONDING FIELDS OF TABLE @et_entityset.

  ENDMETHOD.
ENDCLASS.
