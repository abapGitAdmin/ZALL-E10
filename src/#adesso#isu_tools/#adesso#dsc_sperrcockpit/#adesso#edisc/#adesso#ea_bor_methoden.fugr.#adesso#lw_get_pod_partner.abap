FUNCTION /ADESSO/LW_GET_POD_PARTNER.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_EXT_UI) TYPE  EUITRANS-EXT_UI OPTIONAL
*"     REFERENCE(I_KEYDATE) TYPE  EVER-EINZDAT DEFAULT SY-DATUM
*"     REFERENCE(I_INT_UI) TYPE  INT_UI OPTIONAL
*"  EXPORTING
*"     REFERENCE(E_GPART) TYPE  BUT000-PARTNER
*"----------------------------------------------------------------------


  DATA ld_int_ui TYPE int_ui.
  DATA lf_ever TYPE ever.
* Ermittle zählpunkt

  CLEAR e_gpart.

  if i_int_ui is initial and not i_ext_ui is initial.

  PERFORM hole_int_ui USING i_ext_ui
                            i_keydate
                   CHANGING ld_int_ui.

  elseif not i_int_ui is initial.
     move i_int_ui to ld_int_ui.
  else.
    exit.
  endif.



  CHECK NOT ld_int_ui IS INITIAL.

  PERFORM hole_ersten_vertrag USING ld_int_ui
                                    i_keydate
                           CHANGING lf_ever.

  CHECK NOT lf_ever IS INITIAL.

  PERFORM hole_gpart_ever USING lf_ever
                       CHANGING e_gpart .


ENDFUNCTION.
