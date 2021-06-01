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
REPORT zpw_019_runter_damit.

TYPE-POOLS: abap, icon.
TABLES sscrfields.
TYPES: gtt_customers TYPE TABLE OF zpw016customer.
PARAMETERS: pa_dir  TYPE string,
            pa_file TYPE string.

SELECTION-SCREEN SKIP 2.
SELECTION-SCREEN PUSHBUTTON 2(10) down USER-COMMAND down.
SELECTION-SCREEN PUSHBUTTON 12(25) spdsh USER-COMMAND spdsh.
SELECTION-SCREEN PUSHBUTTON 37(10) up USER-COMMAND up.

DATA: gt_customers TYPE gtt_customers.
DATA: gd_temp_dir TYPE string.
DATA: gd_file_path TYPE string.

INITIALIZATION.
  down = 'Download'(b01).
  up = 'Upload'(b02).
  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name       = icon_xls
      text       = 'Start TabCalc'
      info       = 'Start!'
      add_stdinf = space
    IMPORTING
      result     = spdsh
    EXCEPTIONS
      OTHERS     = 0.
  pa_dir = gd_temp_dir.
  pa_file = 'TEST1.XLS'.
  CONCATENATE
  pa_dir
  '\'
  pa_file
  INTO gd_file_path.
  CASE sscrfields.
    WHEN 'SPDSH'.
    WHEN 'DOWN'.
    WHEN 'UP'.
  ENDCASE.
