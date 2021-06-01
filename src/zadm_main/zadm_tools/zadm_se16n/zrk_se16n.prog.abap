REPORT ZRK_SE16N.

  IF sy-tcode NE 'ZSE16N'.                           "1757450
    call function 'AUTHORITY_CHECK_TCODE'
      exporting
        tcode  = 'SE16N'
      exceptions
        ok     = 0
        not_ok = 1.
    if sy-subrc ne 0.
      message e059(eu) with 'SE16N'.  " no authority
    endif.
  ENDIF.                                            "1757450

CALL FUNCTION 'ZSE16N_START'.
