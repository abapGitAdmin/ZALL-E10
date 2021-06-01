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
REPORT zpw_017_select_varianten.

* Die INTO-Struktur
DATA: ls_customer TYPE zpw016customer,
      ls_address  TYPE zpw016address.

START-OF-SELECTION.
* Einen einzelsatz mit allen Spalten lesen
*  SELECT SINGLE * FROM zsc016customer INTO ls_customer.
* WRITE: / ls_customer.

* Nur unterschiedliche Orte lesen
  SELECT DISTINCT ort FROM zpw016address
    INTO ls_address-ort.
    WRITE: / ls_customer.
  ENDSELECT.
