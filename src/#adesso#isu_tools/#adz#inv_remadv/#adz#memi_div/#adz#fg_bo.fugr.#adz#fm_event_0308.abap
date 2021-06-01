FUNCTION /ADZ/FM_EVENT_0308.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      CT_FKKMAKO STRUCTURE  FKKMAKO
*"      CT_FKKMAZE STRUCTURE  FKKMAZE
*"--------------------------------------------------------------------

  IF ct_fkkmaze[] IS NOT INITIAL.
    PERFORM pf_update_memi_dun_hist TABLES ct_fkkmaze[].
  ENDIF.

ENDFUNCTION.
