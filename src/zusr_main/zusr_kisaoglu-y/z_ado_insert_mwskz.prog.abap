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
REPORT z_ado_insert_mwskz.


DATA ls_mwskz TYPE /ado/za_mwskz.

SELECT mwskz FROM t007a INTO CORRESPONDING FIELDS OF @ls_mwskz.

  SELECT SINGLE text1, spras FROM t007s INTO CORRESPONDING FIELDS OF @ls_mwskz WHERE mwskz = @ls_mwskz-mwskz.

  IF sy-subrc = 0.
    MODIFY /ado/za_mwskz FROM ls_mwskz.
  ENDIF.

ENDSELECT.
