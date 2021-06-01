*----------------------------------------------------------------------*
*   INCLUDE LFICA_MACROS002                                            *
*----------------------------------------------------------------------*


***************************************************************
***
*** Macros for function module determination
***
***************************************************************

* OBSOLETE
* Please use function module FKK_FUNC_MODULE_DETERMINE directly!


define mac_event_modules_get.

  call function 'FKK_FUNC_MODULE_DETERMINE'
       exporting
            i_fbeve  = &2
            i_applk  = &1
       tables
            t_fbstab = &3.
  describe table &3 lines _mac_h_fbstab_lines.
  if _mac_h_fbstab_lines = 0.
    message e405(>4) with &1 &2.
  endif.

end-of-definition.
