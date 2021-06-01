************************************************************************
****
*            _
*   __ _  __| | ___  ___ ___  ___
*  / _` |/ _` |/ _ \/ __/ __|/ _ \
* | (_| | (_| |  __/\__ \__ \ (_) |
*  \__,_|\__,_|\___||___/___/\___/
************************************************************************
*******
*
*
*&
************************************************************************
*******
REPORT Z_ADO_WEBSERVICE_TEST.



      TYPES: BEGIN OF image,
         id TYPE integer,
         latitude TYPE string,
         longitude TYPE string,
         filename TYPE string,
         size TYPE string,
          author TYPE string,
           direction TYPE string,
       END OF image.

       DATA: tt_image TYPE TABLE OF image.

      TYPES: BEGIN OF category,
         id TYPE integer,
         name TYPE string,
       END OF category.

       DATA: tt_category TYPE TABLE OF category.



       DATA: tt_contexts TYPE TABLE OF context.

      TYPES: BEGIN OF full_type,
         id TYPE integer,
         latitude TYPE string,
         longitude TYPE string,
         name TYPE string,
         city TYPE string,
         description TYPE string,
         category LIKE tt_category,
         imageInformation LIKE tt_image,

       END OF full_type.

      DATA: oservice TYPE REF TO zcl_ado__webservice,
            lt_itab TYPE TABLE OF full_type,
            lf_url TYPE STRING VALUE 'http://labs.inf.fh-dortmund.de/streetview/api/locations?city=Dortmund'.


      CREATE OBJECT oservice
          EXPORTING
          i_url  = lf_url
          .

      oservice->send_request( ).

      oservice->get_response_json( CHANGING c_itab = lt_itab ).
