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
REPORT Z_SELOPTION_DYNAMIC_WHEREBEDIN.


DATA: lv_matnr TYPE mara-matnr.
DATA: lv_mtart TYPE mara-mtart.
SELECT-OPTIONS: so_matnr FOR lv_matnr DEFAULT 1.
SELECT-OPTIONS: so_mtart FOR lv_mtart DEFAULT 'ROH'.

START-OF-SELECTION.

* SELECT-OPTIONS in deine dynamische WHERE-Clause überführen
  DATA(lv_where_string) = cl_shdb_seltab=>combine_seltabs( it_named_seltabs = VALUE #( ( name = 'MATNR' dref = REF #( so_matnr[] ) )
                                                                                       ( name = 'MTART' dref = REF #( so_mtart[] ) )
                                                                                     )
                                                         ).


  WRITE: / lv_where_string.
