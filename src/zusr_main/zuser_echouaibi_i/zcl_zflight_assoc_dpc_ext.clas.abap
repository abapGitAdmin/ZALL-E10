class ZCL_ZFLIGHT_ASSOC_DPC_EXT definition
  public
  inheriting from ZCL_ZFLIGHT_ASSOC_DPC
  create public .

public section.
protected section.

  methods CARRIERSET_GET_ENTITYSET
    redefinition .
  methods FLIGHTSET_GET_ENTITY
    redefinition .
  methods FLIGHTSET_GET_ENTITYSET
    redefinition .
  methods CARRIERSET_GET_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZFLIGHT_ASSOC_DPC_EXT IMPLEMENTATION.


  method CARRIERSET_GET_ENTITY.

* URL/SERVICENAME/CarrierSet('AA')
io_tech_request_context->get_converted_keys( IMPORTING es_key_values = er_entity ).

  IF NOT er_entity-carrid IS INITIAL.
    SELECT SINGLE * FROM scarr INTO CORRESPONDING FIELDS OF @er_entity WHERE carrid = @er_entity-carrid.
  ENDIF.



  endmethod.


  METHOD carrierset_get_entityset.
* URL/SERVICENAME/CarrierSet
    SELECT * FROM scarr INTO TABLE et_entityset.

  ENDMETHOD.


  method FLIGHTSET_GET_ENTITY.

* URL/SERVICENAME/FlightsSet(Carrid='AA',Connid='64')
  io_tech_request_context->get_converted_keys( IMPORTING es_key_values = er_entity ).

  IF NOT er_entity-carrid IS INITIAL AND NOT er_entity-connid IS INITIAL..
    SELECT SINGLE * FROM spfli INTO CORRESPONDING FIELDS OF @er_entity
      WHERE carrid = @er_entity-carrid
        AND connid = @er_entity-connid.

    IF sy-subrc <> 0.
      CLEAR: er_entity.
    ENDIF.
  ENDIF.

  endmethod.


  METHOD flightset_get_entityset.

*** URL/SERVICENAME/flightSet
**    SELECT * FROM spfli INTO TABLE et_entityset.


* URL/SERVICENAME/CarrierSet('AA')/ToFlights?$format=json
* Typen und Konstanten sind in der MPC definiert
  DATA: lv_flights TYPE zcl_zflight_assoc_mpc=>ts_flight.

  DATA(lv_source_entity_type_name) = io_tech_request_context->get_source_entity_type_name( ).

  CASE lv_source_entity_type_name.
* Typen und Konstanten sind in der MPC definiert
    WHEN zcl_zflight_assoc_mpc=>gc_carrier.
      io_tech_request_context->get_converted_source_keys( IMPORTING es_key_values = lv_flights ).
  ENDCASE.

  IF NOT lv_flights IS INITIAL.
    SELECT * FROM spfli INTO CORRESPONDING FIELDS OF TABLE @et_entityset WHERE carrid = @lv_flights-carrid.
  ELSE.
    SELECT * FROM spfli INTO CORRESPONDING FIELDS OF TABLE @et_entityset.
  ENDIF.
  ENDMETHOD.
ENDCLASS.
