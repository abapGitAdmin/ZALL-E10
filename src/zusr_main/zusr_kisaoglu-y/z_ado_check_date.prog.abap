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
REPORT z_ado_check_date.



DATA: lf_datum  TYPE string,
      lf_range  TYPE RANGE OF string,
      lw_search LIKE LINE OF lf_range,
      lt_search LIKE TABLE OF lw_search,
      lt_zahead TYPE TABLE OF /ado/za_head.


lw_search-sign   = 'I'.
lw_search-option = 'CP'.
lf_datum = '*05**30*'.
lw_search-low    = lf_datum.
APPEND lw_search TO lt_search.

SELECT * FROM /ado/za_head INTO TABLE lt_zahead WHERE datum IN lt_search.

IF sy-subrc = 0.
  LOOP AT lt_zahead ASSIGNING FIELD-SYMBOL(<fs_zahead>).
    WRITE:/
    <fs_zahead>-/ado/za_id,
    <fs_zahead>-bukrs,
    <fs_zahead>-monat,
    <fs_zahead>-datum,
    <fs_zahead>-bu_nameor2,
    <fs_zahead>-ad_street.


  ENDLOOP.
ELSE.
  WRITE:/ 'Fehler'.
ENDIF.
