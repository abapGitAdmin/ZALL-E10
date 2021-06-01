FUNCTION se16n_check_tlock.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXCEPTIONS
*"      NO_ENTRY
*"----------------------------------------------------------------------

  DATA: ls_lock TYPE tappl_lock.

*.check if lock entry exists
  SELECT SINGLE * FROM tappl_lock INTO ls_lock
        WHERE name = c_emergency
          AND type = 'TR'
          AND mandt = sy-mandt.
*.if it does not exist, create the entry
  IF sy-subrc <> 0.
    ls_lock-name     = c_emergency.
    ls_lock-type     = 'TR'.
    ls_lock-mandt    = sy-mandt.
    ls_lock-locked   = true.
    ls_lock-modifier = 'SAP'.
    ls_lock-moddate  = sy-datlo.
    ls_lock-modtime  = sy-timlo.
    INSERT tappl_lock FROM ls_lock.
    COMMIT WORK AND WAIT.
    RAISE no_entry.
  ENDIF.

ENDFUNCTION.
