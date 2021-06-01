FUNCTION /adesso/mte_objkey_insert_one.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_FIRMA) TYPE  EMG_FIRMA
*"     VALUE(I_OBJECT) TYPE  EMG_OBJECT
*"     VALUE(I_OLDKEY) TYPE  EMG_OLDKEY
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------


  /adesso/mte_obj-firma = i_firma.
  /adesso/mte_obj-object = i_object.
  /adesso/mte_obj-oldkey = i_oldkey.

  INSERT /adesso/mte_obj.
  IF sy-subrc <> 0.
    RAISE error.
  ENDIF.

  COMMIT WORK.



ENDFUNCTION.
