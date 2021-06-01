class /ADO/CL_WB_REST definition
  public
  create public .

public section.

  class-methods CALL_WALLBE_API
    importing
      !IV_BASE_URL type STRING default 'wallb-e.cloud/services/api'
      !IV_SSL type ABAP_BOOL default ABAP_TRUE
      !IV_SERVICE type STRING
      !IV_HTTP_METHOD type STRING default 'GET'
    changing
      !CT_DATA type DATA .
  class-methods SAVE_CS .
  class-methods SAVE_CP .
  class-methods SAVE_OP .
  class-methods SAVE_USER .
  class-methods SAVE_LOADEDKWH
    importing
      !IV_YEAR type CHAR4
      !IV_OPERATOR type /ADO/WB_DE_OPERATOR_ID optional
      !IV_CHARGING_STATION type /ADO/WB_DE_CHARSTAT_ID optional
    exporting
      !ET_WB_LKWH_OR type /ADO/WB_T_LKWH_OR
      !ET_WB_LKWH_CS type /ADO/WB_T_LKWH_CS .
  class-methods SAVE_REVENUE
    importing
      !IV_YEAR type CHAR4
      !IV_OPERATOR type /ADO/WB_DE_OPERATOR_ID optional
      !IV_CHARGING_STATION type /ADO/WB_DE_CHARSTAT_ID optional
    exporting
      !ET_WB_REV_OR type /ADO/WB_T_REV_OR
      !ET_WB_REV_CS type /ADO/WB_T_REV_CS .
protected section.
private section.
ENDCLASS.



CLASS /ADO/CL_WB_REST IMPLEMENTATION.


  METHOD CALL_WALLBE_API.
    DATA: lr_http_client       TYPE REF TO if_http_client,
          lr_json_deserializer TYPE REF TO /ui2/cl_json,

          lv_service           TYPE string,
          lv_request_result    TYPE string.

    FIELD-SYMBOLS: <ls_data> TYPE any.

    lv_service = SWITCH #( iv_ssl WHEN abap_true THEN 'https://' && iv_base_url && iv_service
                                  WHEN abap_false THEN 'http://' && iv_base_url && iv_service ).

    lv_service = |{ lv_service CASE = LOWER }|.

    cl_http_client=>create_by_url(
      EXPORTING
        url                = lv_service
      IMPORTING
        client             = lr_http_client
      EXCEPTIONS
        argument_not_found = 1
        plugin_not_active  = 2
        internal_error     = 3
        OTHERS             = 4 ).

    lr_http_client->request->set_method(
      EXPORTING
        method = iv_http_method ).

    lr_http_client->authenticate( username = '$2a$04$O.OHNJj6Z41OX5CfQ/Gd1uME9w9BjdUlLtF0ZEAcjQOl1NABSkCHWchristian.schmidt@adesso.de$operator_adessoAG' password = 'adEsso321' ).

    lr_http_client->send(
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2 ).

    lr_http_client->receive(
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3 ).

    DATA(lv_content_type) = lr_http_client->response->get_content_type( ).
    lv_request_result = lr_http_client->response->get_cdata( ).

    " JSON Anwort parsen
    IF lv_content_type EQ 'application/json'.
      CALL METHOD /ui2/cl_json=>deserialize
        EXPORTING
          json = lv_request_result
        CHANGING
          data = ct_data.
    ENDIF.
  ENDMETHOD.


  method SAVE_CP.
        DATA: ls_db_cp   TYPE /ado/wb_cp,
              lt_cp      TYPE /ado/wb_t_charging_process.

"Aufrufen der API
    CALL METHOD /ado/cl_wb_rest=>call_wallbe_api
      EXPORTING
        iv_service = '/charging-processes'
      CHANGING
        ct_data    = lt_cp.
"über die empfangenen Daten loopen
    LOOP AT lt_cp ASSIGNING FIELD-SYMBOL(<fs_cp>).
      SELECT SINGLE * FROM /ado/wb_cp INTO @DATA(ls_db_actual_cp) WHERE id = @<fs_cp>-id.

      ls_db_cp = CORRESPONDING #( <fs_cp> ).

      IF ls_db_actual_cp IS NOT INITIAL.
        UPDATE /ado/wb_cp FROM ls_db_cp.
      ELSE.
        INSERT /ado/wb_cp FROM ls_db_cp.
      ENDIF.
    ENDLOOP.
  endmethod.


  METHOD save_cs.
    DATA: ls_db_cs   TYPE /ado/wb_cs,
          ls_db_ophh TYPE /ado/wb_ophh,
          ls_db_ophp TYPE /ado/wb_ophp,
          lt_cs      TYPE /ado/wb_t_charging_station.

    CALL METHOD /ado/cl_wb_rest=>call_wallbe_api
      EXPORTING
        iv_service = '/charging-stations'
      CHANGING
        ct_data    = lt_cs.

    LOOP AT lt_cs ASSIGNING FIELD-SYMBOL(<fs_cs>).
      SELECT SINGLE * FROM /ado/wb_cs INTO @DATA(ls_db_actual_cs) WHERE id = @<fs_cs>-id.

      "1. Schritt CS Speichern
      ls_db_cs = CORRESPONDING #( <fs_cs> ).
      ls_db_cs-name_cs = <fs_cs>-name.
      ls_db_cs-state_cs = <fs_cs>-state.

      "2. Schritt Adresse speichern
      DATA(ls_address) = <fs_cs>-address.
      ls_db_cs-cs_adr = CORRESPONDING #( ls_address ).

      "3. Schritt Geokoordinaten speichern
      DATA(ls_geo) = <fs_cs>-geocoordinate.
      ls_db_cs-cs_geo = CORRESPONDING #( ls_geo ).

      "4. Schritt Type Ladestation speichern
      DATA(ls_type) = <fs_cs>-type.
      ls_db_cs-cs_type = CORRESPONDING #( ls_type ).

      "5. Schritt Öffnungszeiten Kopfdaten speichern
      IF ls_db_actual_cs-ophh_key IS NOT INITIAL.
        DELETE FROM /ado/wb_ophp WHERE ophh_key = ls_db_actual_cs-ophh_key.
        DELETE FROM /ado/wb_ophh WHERE ophh_key = ls_db_actual_cs-ophh_key.
      ENDIF.

      DATA(ls_ophours) = <fs_cs>-openinghours.
      IF ls_ophours IS NOT INITIAL.
        ls_db_ophh-ophh_key = cl_system_uuid=>create_uuid_c32_static( ).
        ls_db_ophh-ophh_comment = ls_ophours-comment.
        INSERT /ado/wb_ophh FROM ls_db_ophh.

        LOOP AT ls_ophours-entries ASSIGNING FIELD-SYMBOL(<ls_oph_entrie>).
          "6. Schritt Öffungszeiten Positionen speichern
          ls_db_ophp = CORRESPONDING #( <ls_oph_entrie> ).
          ls_db_ophp-ophh_key = ls_db_ophh-ophh_key.
          ls_db_ophp-ophp_key = cl_system_uuid=>create_uuid_c32_static( ).
          INSERT /ado/wb_ophp FROM ls_db_ophp.
        ENDLOOP.

        ls_db_cs-ophh_key = ls_db_ophh-ophh_key.
      ENDIF.

      IF ls_db_actual_cs IS NOT INITIAL.
        UPDATE /ado/wb_cs FROM ls_db_cs.
      ELSE.
        INSERT /ado/wb_cs FROM ls_db_cs.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD save_loadedkwh.
    DATA: ls_db_lkwh_or TYPE /ado/wb_lkwh_or,
          ls_db_lkwh_cs TYPE /ado/wb_lkwh_cs,

          lv_service    TYPE string,
          lv_operator   TYPE kennzx,
          lv_charstat   TYPE kennzx,

          lt_loadedkwh  TYPE /ado/wb_t_loadedkwh.

    IF iv_operator IS INITIAL AND iv_charging_station IS INITIAL.
      lv_service = |/statistics/loaded-kwh?year={ iv_year }|.
    ELSEIF iv_operator IS NOT INITIAL.
      lv_service = |/operators/{ iv_operator }/statistics/loaded-kwh?year={ iv_year }|.
      lv_operator = abap_true.
    ELSEIF iv_charging_station IS NOT INITIAL.
      lv_service = |/charging-stations/{ iv_charging_station }/statistics/loaded-kwh?year={ iv_year }|.
      lv_charstat = abap_true.
    ENDIF.

    CALL METHOD /ado/cl_wb_rest=>call_wallbe_api
      EXPORTING
        iv_service = lv_service
      CHANGING
        ct_data    = lt_loadedkwh.

    LOOP AT lt_loadedkwh ASSIGNING FIELD-SYMBOL(<fs_loadedkwh>).
      "1. Schritt Daten Speichern
      IF lv_operator = abap_true.
        ls_db_lkwh_or = CORRESPONDING #( <fs_loadedkwh> ).
        ls_db_lkwh_or-schluessel = cl_system_uuid=>create_uuid_c32_static( ).
        ls_db_lkwh_or-monat = <fs_loadedkwh>-month.
        ls_db_lkwh_or-operatorid = iv_operator.
        ls_db_lkwh_or-jahr = iv_year.
        GET TIME STAMP FIELD ls_db_lkwh_or-erdat.
        ls_db_lkwh_or-erusr = sy-uname.
        INSERT /ado/wb_lkwh_or FROM ls_db_lkwh_or.
        APPEND ls_db_lkwh_or TO et_wb_lkwh_or.
      ELSEIF lv_charstat = abap_true.
        ls_db_lkwh_cs = CORRESPONDING #( <fs_loadedkwh> ).
        ls_db_lkwh_cs-schluessel = cl_system_uuid=>create_uuid_c32_static( ).
        ls_db_lkwh_cs-monat = <fs_loadedkwh>-month.
        ls_db_lkwh_cs-cs_id = iv_charging_station.
        ls_db_lkwh_cs-jahr = iv_year.
        GET TIME STAMP FIELD ls_db_lkwh_cs-erdat.
        ls_db_lkwh_cs-erusr = sy-uname.
        INSERT /ado/wb_lkwh_cs FROM ls_db_lkwh_cs.
        APPEND ls_db_lkwh_cs TO et_wb_lkwh_cs.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD save_OP.
    DATA: ls_db_op   TYPE /ado/wb_op,
          lt_op      TYPE /ado/wb_t_operator.

    CALL METHOD /ado/cl_wb_rest=>call_wallbe_api
      EXPORTING
        iv_service = '/operators'
      CHANGING
        ct_data    = lt_op.

    LOOP AT lt_op ASSIGNING FIELD-SYMBOL(<fs_op>).
      SELECT SINGLE * FROM /ado/wb_op INTO @DATA(ls_db_actual_op) WHERE id = @<fs_op>-id.

      "1. Schritt OP Speichern
      ls_db_op = CORRESPONDING #( <fs_op> ).

      "2. Schritt ADRESSE speichern
      DATA(ls_address) = <fs_op>-address.
      ls_db_op-op_adr = CORRESPONDING #( ls_address ).


      IF ls_db_actual_op IS NOT INITIAL.
        UPDATE /ado/wb_op FROM ls_db_op.
      ELSE.
        INSERT /ado/wb_op FROM ls_db_op.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD save_revenue.
    DATA: ls_db_rev_or TYPE /ado/wb_rev_or,
          ls_db_rev_cs TYPE /ado/wb_rev_cs,

          lv_service   TYPE string,
          lv_operator  TYPE kennzx,
          lv_charstat  TYPE kennzx,

          lt_revenue   TYPE /ado/wb_t_revenue.

    IF iv_operator IS INITIAL AND iv_charging_station IS INITIAL.
      lv_service = |/statistics/revnue?year={ iv_year }|.
    ELSEIF iv_operator IS NOT INITIAL.
      lv_service = |/operators/{ iv_operator }/statistics/revenue?year={ iv_year }|.
      lv_operator = abap_true.
    ELSEIF iv_charging_station IS NOT INITIAL.
      lv_service = |/charging-stations/{ iv_charging_station }/statistics/revenue?year={ iv_year }|.
      lv_charstat = abap_true.
    ENDIF.

    CALL METHOD /ado/cl_wb_rest=>call_wallbe_api
      EXPORTING
        iv_service = lv_service
      CHANGING
        ct_data    = lt_revenue.

    LOOP AT lt_revenue ASSIGNING FIELD-SYMBOL(<fs_revenue>).
      "1. Schritt Daten Speichern
      IF lv_operator = abap_true.
        ls_db_rev_or = CORRESPONDING #( <fs_revenue> ).
        ls_db_rev_or-schluessel = cl_system_uuid=>create_uuid_c32_static( ).
        ls_db_rev_or-monat = <fs_revenue>-month.
        ls_db_rev_or-operatorid = iv_operator.
        ls_db_rev_or-jahr = iv_year.
        GET TIME STAMP FIELD ls_db_rev_or-erdat.
        ls_db_rev_or-erusr = sy-uname.
        INSERT /ado/wb_rev_or FROM ls_db_rev_or.
        APPEND ls_db_rev_or TO et_wb_rev_or.
      ELSEIF lv_charstat = abap_true.
        ls_db_rev_cs = CORRESPONDING #( <fs_revenue> ).
        ls_db_rev_cs-schluessel = cl_system_uuid=>create_uuid_c32_static( ).
        ls_db_rev_cs-monat = <fs_revenue>-month.
        ls_db_rev_cs-cs_id = iv_charging_station.
        ls_db_rev_cs-jahr = iv_year.
        GET TIME STAMP FIELD ls_db_rev_cs-erdat.
        ls_db_rev_cs-erusr = sy-uname.
        INSERT /ado/wb_rev_cs FROM ls_db_rev_cs.
        APPEND ls_db_rev_cs TO et_wb_rev_cs.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD save_user.
    DATA: ls_db_user   TYPE /ado/wb_user,
          lt_user      TYPE /ado/wb_t_user.

    CALL METHOD /ado/cl_wb_rest=>call_wallbe_api
      EXPORTING
        iv_service = '/operators/cce61348-fd67-11e7-a412-005056a15993/users' "hier muss die ID des Operators eingetragen werden
      CHANGING
        ct_data    = lt_user.

    LOOP AT lt_user ASSIGNING FIELD-SYMBOL(<fs_user>).
      SELECT SINGLE * FROM /ado/wb_user INTO @DATA(ls_db_actual_user) WHERE id = @<fs_user>-id. "die Adressdaten werden hier bereits NICHT übergeben -> Tabelle anpassen / tiefe Struktur

      "1. Schritt USER Speichern
      ls_db_user = CORRESPONDING #( <fs_user> ).

      "2. Schritt Profil speichern
      DATA(ls_profile) = <fs_user>-profile.
      ls_db_user-user_profile = CORRESPONDING #( ls_profile ).

      "3. Schritt Adresse speichern
*      DATA(ls_profile) = <fs_user>-profile.
      ls_db_user-contactaddress = CORRESPONDING #( ls_profile ).


*       ls_profile-addressappendix = ls_db_user-addressappendix.
*       ls_profile-COUNTRY = <fs_user>-country.
*       ls_profile-city = <fs_user>-city.
*       ls_profile-state = <fs_user>-state.
*       ls_profile-street = ls_db_user-street.
*       ls_profile-street2 = <fs_user>-street2.
*       ls_profile-zip = <fs_user>-zip.

*       ls_db_user-addressappendix = <fs_user>-addressappendix.
*       ls_db_user-COUNTRY = <fs_user>-country.
*       ls_db_user-city = <fs_user>-city.
*       ls_db_user-state = <fs_user>-state.
*       ls_db_user-street = <fs_user>-street.
*       ls_db_user-street2 = <fs_user>-street2.
*       ls_db_user-zip = <fs_user>-zip.

      IF ls_db_actual_user IS NOT INITIAL.
        UPDATE /ado/wb_user FROM ls_db_user.
      ELSE.
        INSERT /ado/wb_user FROM ls_db_user.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
