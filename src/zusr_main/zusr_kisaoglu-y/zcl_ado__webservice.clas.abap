*#----------------------------------------------------------------------
*#            _
*#   __ _  __| | ___  ___ ___  ___
*#  / _` |/ _` |/ _ \/ __/ __|/ _ \
*# | (_| | (_| |  __/\__ \__ \ (_) |
*#  \__,_|\__,_|\___||___/___/\___/
*#----------------------------------------------------------------------
*#
*#   Report ZCL_ADO__WEBSERVICE
*#
*#----------------------------------------------------------------------
*#
*#   Ersteller:   Yusuf Kisaoglu (adesso AG)
*#   Am: 22.05.2019
*#
*#----------------------------------------------------------------------
*#
*#   Änderungen:
*#
*# TX<Ticket-Nr.> Aenderer: <Entwicklername> Datum: %DateTime%
*#
*#----------------------------------------------------------------------
class ZCL_ADO__WEBSERVICE definition
  public
  final
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !I_URL type STRING optional .
  methods GET_URL
    exporting
      !E_URL type STRING .
  methods SET_URL
    importing
      !I_URL type STRING .
  methods GET_PAYLOAD
    exporting
      !E_PAYLOAD type STRING .
  methods SET_PAYLOAD
    importing
      !I_PAYLOAD type STRING .
  methods AUTHENTICATE
    importing
      !I_USERNAME type STRING
      !I_PASSWORD type STRING .
  methods SEND_REQUEST
    importing
      !I_URL type STRING optional .
  methods GET_RESPONSE
    exporting
      !E_RESPONSE type STRING .
  methods GET_RESPONSE_JSON
    changing
      !C_ITAB type ANY TABLE .
  methods SET_HEADER
    importing
      !I_METHOD type STRING optional
      !I_CONTENT_TYPE type STRING optional .
  methods GET_HEADER
    importing
      !I_METHOD_X type XFELD optional
      !I_CONTENT_TYPE_X type XFELD optional
    exporting
      !E_METHOD type STRING
      !E_CONTENT_TYPE type STRING .
protected section.
private section.

  data LS_HTTP_CLIENT type ref to IF_HTTP_CLIENT .
  data LF_RESPONSE type STRING .
ENDCLASS.



CLASS ZCL_ADO__WEBSERVICE IMPLEMENTATION.


  METHOD authenticate.

    IF i_username IS NOT INITIAL
    AND i_password IS NOT INITIAL
    AND ls_http_client IS BOUND.

      ls_http_client->authenticate(
        username = i_username
        password = i_password
      ).

    ENDIF.



  ENDMETHOD.


  METHOD constructor.

   IF i_url IS NOT INITIAL.

      me->set_url( i_url = i_url ).

   ELSE.

      me->set_url( i_url = '').

   ENDIF.


  ENDMETHOD.


  method GET_HEADER.

      IF i_method_x IS NOT INITIAL
      AND ls_http_client IS BOUND.

        e_method = ls_http_client->request->get_method( ).

      ENDIF.

      IF i_content_type_x IS NOT INITIAL
      AND ls_http_client IS BOUND.

        e_content_type = ls_http_client->request->get_content_type( ).

      ENDIF.



  endmethod.


  METHOD get_payload.

    DATA lf_payload_x TYPE xstring.

    IF ls_http_client IS BOUND.

      lf_payload_x = ls_http_client->request->get_data( ).

      IF lf_payload_x IS NOT INITIAL.

        CALL FUNCTION 'ECATT_CONV_XSTRING_TO_STRING'
          EXPORTING
            im_xstring  = lf_payload_x
            im_encoding = 'UTF-8'
          IMPORTING
            ex_string   = e_payload.

      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD GET_RESPONSE.

    IF ls_http_client IS BOUND.

      ls_http_client->receive(
        EXCEPTIONS
          http_communication_failure = 1
          http_invalid_state        = 2
          http_processing_failed    = 3 ).

      IF sy-subrc = 0.

        e_response = ls_http_client->response->get_cdata( ).

      ENDIF.

    ENDIF.



  ENDMETHOD.


  METHOD get_response_json.

    DATA lf_response TYPE string.

    IF ls_http_client IS BOUND.

      ls_http_client->receive(
        EXCEPTIONS
          http_communication_failure = 1
          http_invalid_state        = 2
          http_processing_failed    = 3 ).

      IF sy-subrc = 0.

        lf_response = ls_http_client->response->get_cdata( ).

      ENDIF.


      IF lf_response IS NOT INITIAL.

        cl_fdt_json=>JSON_TO_DATA( EXPORTING  iv_json = lf_response
                              CHANGING   ca_data = c_itab ).

        IF sy-subrc <> 0.
          CLEAR c_itab.
        ENDIF.

      ENDIF.
    ENDIF.

  ENDMETHOD.


  method GET_URL.

    IF ls_http_client IS BOUND.
      e_url = ls_http_client->create_rel_url( ).
    ENDIF.

  endmethod.


  METHOD send_request.

    IF i_url IS NOT INITIAL.

      me->set_url( i_url = i_url ).

    ENDIF.

    IF ls_http_client IS BOUND.

      ls_http_client->send(
        EXCEPTIONS
         http_communication_failure = 1
         http_invalid_state        = 2 ).

      IF sy-subrc <> 0.
        RETURN.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  method SET_HEADER.

    IF i_method IS NOT INITIAL
    AND ls_http_client IS BOUND.
      ls_http_client->request->set_method( i_method ).
    ENDIF.

    IF i_content_type IS NOT INITIAL
    AND ls_http_client IS BOUND.
      ls_http_client->request->set_content_type( i_content_type ).
    ENDIF.

  endmethod.


  METHOD SET_PAYLOAD.

    DATA lf_payload_x TYPE xstring.

    CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
      EXPORTING
        text   = i_payload
      IMPORTING
        buffer = lf_payload_x.

    IF sy-subrc = 0.

      IF ls_http_client IS BOUND.
        ls_http_client->request->set_data( lf_payload_x ).
      ENDIF.


    ENDIF.


  ENDMETHOD.


  method SET_URL.

     cl_http_client=>create_by_url(
        EXPORTING
          url                = i_url
        IMPORTING
          client             = ls_http_client
        EXCEPTIONS
          argument_not_found = 1
          plugin_not_active  = 2
          internal_error     = 3
          others             = 4
             ).
      IF sy-subrc <> 0.
          RETURN.
      ENDIF.

  endmethod.
ENDCLASS.
