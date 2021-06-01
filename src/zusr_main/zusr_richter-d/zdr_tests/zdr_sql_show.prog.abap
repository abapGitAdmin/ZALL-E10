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
REPORT zdr_sql_show.

SELECT * FROM /ado/sql_select_all INTO TABLE @DATA(lt_itab) UP TO 1000 ROWS ORDER BY PRIMARY KEY.

cl_demo_output=>write_data( lt_itab ).

* HTML-Code vom Demo-Output holen
DATA(lv_html) = cl_demo_output=>get( ).
* Daten im Inline-Browser im SAP-Fenster anzeigen
cl_abap_browser=>show_html( EXPORTING
                              title        = 'Daten aus CSV'
                              html_string  = lv_html
                              container    = cl_gui_container=>default_screen ).

* cl_gui_container=>default_screen erzwingen
WRITE: space.
