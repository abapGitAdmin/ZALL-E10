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
*&         $USER  $DATE
************************************************************************
*******
REPORT zhar_test_references.

DATA          lo_data   type ref to zhar_cl_load_file.
FIELD-SYMBOLS <lo_data> type any. " ref to zhar_cl_load_file.

assign lo_data to <lo_data>.

<lo_data> = new zhar_cl_load_file(  ).
write : /, '1 lo_data = ', XSDBOOL( lo_data is not initial ).

clear <lo_data>.
write : /, '2 lo_data = ', XSDBOOL( lo_data is not initial ).
