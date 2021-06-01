FUNCTION ztest_fuba.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"----------------------------------------------------------------------

  IF gt_devaccess IS INITIAL.
    SELECT * FROM devaccess INTO TABLE gt_devaccess.
  ENDIF.





ENDFUNCTION.
