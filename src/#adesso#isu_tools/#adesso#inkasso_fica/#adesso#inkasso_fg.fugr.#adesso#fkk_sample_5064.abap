FUNCTION /adesso/fkk_sample_5064.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      T_FKKCOLL STRUCTURE  DFKKCOLL OPTIONAL
*"      T_FKKOP STRUCTURE  FKKOP OPTIONAL
*"      T_FKKMAZE STRUCTURE  FKKMAZE OPTIONAL
*"  CHANGING
*"     VALUE(C_FKKCOLFILE_TRAILER) LIKE  FKKCOLFILE_TRAILER
*"  STRUCTURE  FKKCOLFILE_TRAILER
*"--------------------------------------------------------------------

  DATA: ls_colfile_t TYPE dfkkcolfile_t_w.

  CLEAR ls_colfile_t.
  MOVE-CORRESPONDING c_fkkcolfile_TRAILER TO ls_colfile_t.

  IF gf_laufd IS NOT INITIAL.
    ls_colfile_t-laufd = gf_laufd.
    ls_colfile_t-laufi = gf_laufi.
    INSERT dfkkcolfile_t_w FROM ls_colfile_t.
  ENDIF.

ENDFUNCTION.
