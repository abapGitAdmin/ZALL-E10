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
REPORT zhar_auth_test.

DATA lv_uname TYPE sy-uname.
DATA lv_authobj type FIELDNAME.

lv_uname = 'APPEL-H'.

lv_authobj = 'ZHAR_TEST'.
AUTHORITY-CHECK OBJECT lv_authobj FOR USER lv_uname ID 'ZHA_BERF1' FIELD '01'.
"ID <authority field 1> FIELD <field value 1>.
"ID <authority field 2> FIELD <field value 2>.
WRITE : /'Authorization for ', lv_authobj ,  cond char10( when sy-subrc eq 0 then 'positiv' else 'negativ' ).

AUTHORITY-CHECK OBJECT lv_authobj FOR USER lv_uname ID  'ZHA_BERF1' DUMMY.
WRITE : /'Authorization for ', lv_authobj ,  cond char10( when sy-subrc eq 0 then 'positiv' else 'negativ' ).

AUTHORITY-CHECK OBJECT lv_authobj FOR USER lv_uname ID  'XXX' DUMMY.
WRITE : /'Authorization for ', lv_authobj ,  cond char10( when sy-subrc eq 0 then 'positiv' else 'negativ' ).

AUTHORITY-CHECK OBJECT lv_authobj FOR USER lv_uname ID  'XXX' FIELD '02'.
WRITE : /'Authorization for ', lv_authobj ,  cond char10( when sy-subrc eq 0 then 'positiv' else 'negativ' ).

lv_authobj = 'S_SERVICE'.
AUTHORITY-CHECK OBJECT lv_authobj  FOR USER lv_uname ID 'SRV_NAME'  FIELD 'HT'.
WRITE : /'Authorization for ', lv_authobj , cond char10( when sy-subrc eq 0 then 'positiv' else 'negativ' ).

AUTHORITY-CHECK OBJECT lv_authobj  FOR USER lv_uname ID 'XXX'  DUMMY.
WRITE : /'Authorization for ', lv_authobj , cond char10( when sy-subrc eq 0 then 'positiv' else 'negativ' ).
