FUNCTION ZADMREPAD_EDITOR_EXIT .
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      BUFFER TYPE  RSWSOURCET
*"  EXCEPTIONS
*"      CANCELLED
*"--------------------------------------------------------------------

DATA ls_buffer TYPE LINE OF RSWSOURCET.

DATA lt_return type TABLE OF BAPIRET2.
DATA ls_addr TYPE BAPIADDR3.
DATA lv_date(10) TYPE C.

WRITE sy-datum to lv_date DD/MM/YYYY.
CALL FUNCTION 'BAPI_USER_GET_DETAIL'
  EXPORTING
    username             = sy-uname
 IMPORTING
   ADDRESS              = ls_addr
  tables
    return               = lt_return
          .


ls_buffer =	'************************************************************************'.
APPEND ls_buffer to buffer.
ls_buffer =	'*******'.
APPEND ls_buffer to buffer.
ls_buffer =	'*            _'.
APPEND ls_buffer to buffer.
ls_buffer =	'*   __ _  __| | ___  ___ ___  ___'.
APPEND ls_buffer to buffer.
ls_buffer =	'*  / _` |/ _` |/ _ \/ __/ __|/ _ \'.
APPEND ls_buffer to buffer.
ls_buffer =	'* | (_| | (_| |  __/\__ \__ \ (_) |'.
APPEND ls_buffer to buffer.
ls_buffer =	'*  \__,_|\__,_|\___||___/___/\___/'.
APPEND ls_buffer to buffer.
ls_buffer = '************************************************************************'.
APPEND ls_buffer to buffer.
ls_buffer =	'*******'.
APPEND ls_buffer to buffer.
ls_buffer =	'*'.
APPEND ls_buffer to buffer.
ls_buffer =	'*'.
APPEND ls_buffer to buffer.
ls_buffer =	'*&Erstellt von: ' && ` ` && ls_addr-lastname && ', ' && ` ` && ls_addr-firstname .
APPEND ls_buffer to buffer.
ls_buffer =	'*'.
APPEND ls_buffer to buffer.
ls_buffer =	'*&Datum ' && ` ` && lv_date.
APPEND ls_buffer to buffer.
ls_buffer =	'*'.
APPEND ls_buffer to buffer.
ls_buffer =	'*&Beschreibung: ' && `...................` .
APPEND ls_buffer to buffer.
ls_buffer =	'************************************************************************'.
APPEND ls_buffer to buffer.
ls_buffer =	'*******'.
APPEND ls_buffer to buffer.


ENDFUNCTION.
