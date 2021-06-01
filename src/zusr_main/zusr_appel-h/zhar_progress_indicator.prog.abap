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
REPORT zhar_progress_indicator.

DATA lv_x TYPE i VALUE 0.

WHILE lv_x < 100.
  lv_x = lv_x + 10.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = lv_x
      text       = 'Bitte warten'.
  WAIT UP TO 1 SECONDS.

ENDWHILE..
