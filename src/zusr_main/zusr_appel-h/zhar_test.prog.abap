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
REPORT zhar_test.

*********************************************************************
*PARAMETERS  p_user   like V_USERNAME-BNAME.
*
*select count(*) from V_USERNAME where bname = p_user.
*write : 'sy-subrc = ', sy-subrc, '   sy-dbcnt = ', sy-DBCNT.


*********************************************************************
TYPES: BEGIN OF ty_row,
         num TYPE i,
         str TYPE string,
         val TYPE f,
       END OF ty_row,
       BEGIN OF ty_substruct,
         str TYPE string,
         val TYPE f,
       END OF ty_substruct.
"DATA  lt_data type standard table of ty_row WITH KEY num str.
DATA  lt_data TYPE SORTED TABLE OF ty_row with NON-UNIQUE KEY str WITH NON-UNIQUE SORTED KEY secondkey COMPONENTS num.
"SORTED TABLE OF ty_row WITH UNIQUE KEY num str .
DATA  lt_data_std TYPE STANDARD TABLE OF zstr_har_ty_row  WITH KEY num str.
DATA  ls_substruct TYPE ty_substruct.

lt_data = VALUE #( BASE lt_data ( num = 10 str = 'eins' val = '17.4' )  ).
lt_data = VALUE #( BASE lt_data ( num = 20 str = 'zwei' val = '3.5' )  ).
lt_data = VALUE #( BASE lt_data ( num = 13 str = 'dreieeieeieieieieieiei' val = '298999.9742' )  ).

"data(lt_filter)
"data lt_data2 type tty_row_std.
"lt_data2 = filter #( lt_data USING key num str  where num < 10  ).
data lt_data2 like lt_data.
lt_data2 = value #( for ls in lt_data where ( num < 20 ) (  ls  ) ).
lt_data2 = filter #( lt_data  using key secondkey where num < 20 ).

LOOP AT lt_data2  INTO DATA(ls_x).
  WRITE: / ls_x-num, (30):ls_x-str, ls_x-val.
ENDLOOP.

data lt_data3 type STANDARD TABLE OF ty_substruct.
lt_data3 = value #( for ls in lt_data where ( num < 20 ) (  CORRESPONDING #( ls )  ) ).
lt_data3 = CORRESPONDING #( filter #( lt_data using key secondkey where num < 20 ) ).
DATA lt_data_num type SORTED TABLE OF ty_row-num with NON-UNIQUE DEFAULT KEY.
lt_data3 = CORRESPONDING #( filter #( lt_data in lt_data_num where num = table_line ) ).
lt_data3 = CORRESPONDING #( filter #( lt_data in lt_data2 using key secondkey where num = num ) ).
LOOP AT lt_data3  INTO data(ls_y).
  WRITE: /(30):ls_y-str, ls_y-val.
ENDLOOP.
"lt_data[ 2 ] = CORRESPONDING #( lt_data3[ 1 ] ).

return.
"DATA(lv_lines) = lines( lt_data ).
clear lt_data.
TRY.
    DATA(ls_data) = lt_data[ lines( lt_data ) ].
  CATCH cx_sy_itab_line_not_found.
    write 'ls_data is here initial'.
ENDTRY.


lt_data = VALUE #( BASE lt_data ( num = 14 str = 'vier' val = '-0.37' ) ).
WRITE: / 'next try'.
*loop at lt_data  INTO ls_data.
*    write: / ls_data-num, (30):ls_data-str, ls_data-val.
*ENDLOOP.
DATA lr_data2 TYPE REF TO data.
"get reference of lt_data into lr_data.
GET REFERENCE OF lt_data INTO DATA(lr_data).
TYPES ty_reftodata TYPE REF TO data.

lr_data2 ?=  lr_data.

"DATA(lr_data2) = get reference  of  lt_data.
" append LINES OF lt_data to lt_data_std.
zhar_cl_alv_grid=>instance->ausgabe_alv_fuba(
  EXPORTING
    i_title          = 'Hier könnte der Titel stehen'
*    i_dstichtag      =
*    i_fieldcat       =
     i_technames      = 'X'
*    i_structure_name =
    i_alv_repid      =  sy-repid
*    i_alv_variant    =
*    i_alv_sort       =
*    i_alv_layout     = lt_alv_layout
  CHANGING
" c_tab_ausgabe    =
    cr_tab_ausgabe   =  lr_data2
).
*********************************************************************

WRITE: /,'MAMA LAUDA'.
