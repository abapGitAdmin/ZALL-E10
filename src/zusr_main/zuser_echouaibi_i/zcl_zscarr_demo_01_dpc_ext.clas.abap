class ZCL_ZSCARR_DEMO_01_DPC_EXT definition
  public
  inheriting from ZCL_ZSCARR_DEMO_01_DPC
  create public .

public section.
protected section.

  methods SCARRS_GET_ENTITY
    redefinition .
  methods SCARRS_GET_ENTITYSET
    redefinition .
  methods SCARRS_CREATE_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZSCARR_DEMO_01_DPC_EXT IMPLEMENTATION.


  METHOD scarrs_create_entity.


    DATA : wa_iodp TYPE zcl_zscarr_demo_01_mpc=>ts_scarr.

* Capture Input record from frontend into WA_IODP
    io_data_provider->read_entry_data( IMPORTING es_data = wa_iodp ).

* Insert into table SCARR
    INSERT INTO scarr VALUES wa_iodp.
    IF sy-subrc IS INITIAL.
      COMMIT WORK.
* Transfer Inserted records to frontend
      er_entity = wa_iodp.
    ENDIF.

  ENDMETHOD.


  METHOD scarrs_get_entity.

**    DATA: lv_carrid TYPE scarr-carrid.
**
**    CHECK it_key_tab IS NOT INITIAL.
**
**    DATA(ls_key) = it_key_tab[ 1 ].
**    lv_carrid = ls_key-value.
**
**    SELECT SINGLE * FROM scarr INTO er_entity WHERE carrid = lv_carrid.



    DATA : wa_keytab LIKE LINE OF it_key_tab.

*       Capture CARRID value
    READ TABLE it_key_tab INTO wa_keytab INDEX 1.

    IF sy-subrc IS INITIAL.
      SELECT single *
      FROM scarr INTO CORRESPONDING FIELDS OF er_entity
       WHERE carrid EQ wa_keytab-value.
    ENDIF.

  ENDMETHOD.


  METHOD scarrs_get_entityset.


    IF iv_filter_string IS NOT INITIAL.

      SELECT * FROM scarr
        INTO CORRESPONDING FIELDS OF TABLE et_entityset
        WHERE (iv_filter_string).

    ELSE.

      SELECT * FROM scarr
         INTO CORRESPONDING FIELDS OF TABLE et_entityset.

    ENDIF.


*    TYPES : BEGIN OF ty_scarr,
*              carrid   TYPE s_carr_id,
*              carrname TYPE  s_carrname,
*              currcode TYPE s_currcode,
*              url      TYPE s_carrurl,
*            END OF ty_scarr.
*
*    DATA : lt_scarr TYPE STANDARD TABLE OF ty_scarr,
*           lv_str   TYPE string,
*           lw_eset  TYPE zcl_zscarr_demo_01_mpc=>ts_scarr.
*
*    FIELD-SYMBOLS : <fs_scarr> TYPE ty_scarr.
*
** Get the InputValues from frontend
*    CLEAR : lv_str.
*    lv_str = io_tech_request_context->get_search_string( ).
*
** We need to replace ‘‘ with ‘%’
*    REPLACE ALL OCCURRENCES OF '*' IN lv_str WITH '%'.
*
** Fetch records from table SCARR
*    REFRESH : lt_scarr[].
*    SELECT carrid
*           carrname
*           currcode
*           url
*      FROM scarr
*      INTO TABLE lt_scarr
*      WHERE carrid LIKE lv_str.
*
*    IF sy-subrc IS INITIAL.
*      UNASSIGN <fs_scarr>.
*      LOOP AT lt_scarr ASSIGNING <fs_scarr>.
*        MOVE-CORRESPONDING <fs_scarr> TO lw_eset.
*        APPEND lw_eset TO et_entityset.
*        CLEAR : lw_eset.
*      ENDLOOP.
*      UNASSIGN <fs_scarr>.
*    ENDIF.


  ENDMETHOD.
ENDCLASS.
