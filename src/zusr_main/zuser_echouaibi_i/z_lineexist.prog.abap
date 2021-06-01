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
REPORT z_lineexist.


TYPES: tt_data_single TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

TYPES: BEGIN OF ty_data_multiple,
         field1 TYPE i,
         field2 TYPE c LENGTH 10,
         field3 TYPE abap_bool,
       END OF ty_data_multiple.

TYPES: tt_data_multiple TYPE STANDARD TABLE OF ty_data_multiple WITH DEFAULT KEY.

DATA(lt_data) = VALUE tt_data_single( ( 1 )
                                      ( 2 )
                                      ( 3 )
                                      ( 5 )
                                      ( 8 )
              ).
DATA(lv_value) = 2. "I´m looking for the second row

*-- classic way
READ TABLE lt_data TRANSPORTING NO FIELDS INDEX lv_value.
IF sy-subrc <> 0.
  WRITE: /(20) 'Not Found'.
ELSE.
  WRITE: /(20) 'Found'.
ENDIF.
*-- new way
IF line_exists( lt_data[ table_line = lv_value ] ).
  WRITE: /(20) 'Found'.
ELSE.
  WRITE: /(20) 'Not Found'.
ENDIF.

*-- set values
DATA(lr_data_multiple) =
  NEW tt_data_multiple( ( field1 = 1 field2 = 'String' field3 = abap_true )
               ( field1 = 2 field2 = 'String' field3 = abap_true )
              ).
*-- dereference to field symbolitab

FIELD-SYMBOLS: <fs_data_multiple_tab> TYPE tt_data_multiple.
ASSIGN lr_data_multiple->* TO <fs_data_multiple_tab>.

READ TABLE <fs_data_multiple_tab> TRANSPORTING NO FIELDS WITH KEY field1 = 1 field2 = 'String'.
IF sy-subrc <> 0.
  WRITE: /(20) 'Not Found'.
ELSE.
  WRITE: /(20) 'Found'.
ENDIF.
*-- new way
IF line_exists( <fs_data_multiple_tab>[ field1 = 1 field2 = 'String' ] ).
  WRITE: /(20) 'Found'.
ELSE.
  WRITE: /(20) 'Not Found'.
ENDIF.


****-- dereference to field symbolitab
***ASSIGN lr_data_multiple->* TO FIELD-SYMBOL(<fs_data_tab>).
***READ TABLE <fs_data_tab> TRANSPORTING NO FIELDS WITH KEY field1 = 1 field2 = 'String'.
***IF sy-subrc <> 0.
***  WRITE: /(20) 'Not Found'.
***ELSE.
***  WRITE: /(20) 'Found'.
***ENDIF.
****-- new way
***IF line_exists( <fs_data_tab>[ field1 = 1 field2 = 'String' ] ).
***  WRITE: /(20) 'Found'.
***ELSE.
***  WRITE: /(20) 'Not Found'.
***ENDIF.
