class ZCL_AGC_DATEX_TEMP definition
  public
  final
  create public .

public section.

  class-methods IS_NEW_PROCESS_ACTIVE_USERS
    returning
      value(RV_ACTIVE) type FLAG .
protected section.
private section.
ENDCLASS.



CLASS ZCL_AGC_DATEX_TEMP IMPLEMENTATION.


  METHOD is_new_process_active_users.
    SELECT SINGLE active FROM zagc_datexswitch INTO rv_active
      WHERE identifier = 'FA1015' AND uname = sy-uname.
    IF sy-subrc = 4.
      SELECT SINGLE active FROM zagc_datexswitch INTO rv_active
        WHERE identifier = 'FA1015' AND uname = ''.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
