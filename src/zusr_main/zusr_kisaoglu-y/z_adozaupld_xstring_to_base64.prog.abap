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
REPORT z_adozaupld_xstring_to_base64.


DATA zaupld TYPE /ado/za_upld.

DATA xs TYPE xstring.

SELECT SINGLE * FROM /ado/za_upld INTO zaupld WHERE zaid = '0000000140' AND /ado/za_filepid = '1'.

CALL FUNCTION 'SCMS_BASE64_DECODE_STR'
  EXPORTING
    input          = 'Hallo'
*   UNESCAPE       = 'X'
IMPORTING
   OUTPUT         = xs
* EXCEPTIONS
*   FAILED         = 1
*   OTHERS         = 2
          .
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.


WRITE xs.
