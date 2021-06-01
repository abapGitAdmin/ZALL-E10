class ZCL_REPORTMON_MANAGER definition
  public
  final
  create public .

public section.

  interfaces ZIF_REPORTMON_MANAGER .
protected section.
private section.
ENDCLASS.



CLASS ZCL_REPORTMON_MANAGER IMPLEMENTATION.


  METHOD zif_reportmon_manager~log_activity.

    DATA: ls_log_entry TYPE zreportmonall.

    ls_log_entry-name  = sy-cprog.
    ls_log_entry-datum = sy-datum.
    ls_log_entry-time  = sy-uzeit.
    ls_log_entry-tzone = sy-tzone.
    ls_log_entry-uname = sy-uname.

    INSERT INTO zreportmonall VALUES ls_log_entry.

  ENDMETHOD.
ENDCLASS.
