FUNCTION /adesso/mte_objkey_main.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_FIRMA) TYPE  EMG_FIRMA
*"     VALUE(I_OBJECT) TYPE  EMG_OBJECT OPTIONAL
*"     VALUE(I_OLDKEY) TYPE  EMG_OLDKEY OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"      WRONG_PARAMETERS
*"----------------------------------------------------------------------

  IF i_oldkey IS INITIAL.
    IF NOT i_object IS INITIAL.
      DELETE FROM /adesso/mte_obj WHERE firma = i_firma
                                 AND   object = i_object.

      IF sy-subrc <> 0.
        RAISE error.
      ENDIF.
    ELSE.
      DELETE FROM /adesso/mte_obj WHERE firma = i_firma.
      IF sy-subrc <> 0.
        RAISE error.
      ENDIF.
    ENDIF.
  ELSE.
    IF i_object IS INITIAL.
      RAISE wrong_parameters.
    ENDIF.
    DELETE FROM /adesso/mte_obj WHERE firma = i_firma
                               AND   object = i_object
                               AND   oldkey = i_oldkey.

    IF sy-subrc <> 0.
      RAISE error.
    ENDIF.
  ENDIF.

  COMMIT WORK.

ENDFUNCTION.
