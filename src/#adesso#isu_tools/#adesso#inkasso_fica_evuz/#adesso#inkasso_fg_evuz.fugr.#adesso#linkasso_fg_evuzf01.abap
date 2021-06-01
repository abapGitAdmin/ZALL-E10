*----------------------------------------------------------------------*
***INCLUDE /ADESSO/LINKASSO_FG_EVUZF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CLEAR_C_COLFILE
*&---------------------------------------------------------------------*
FORM clear_c_colfile using fs_fkkcolfile STRUCTURE fkkcolfile.

  CLEAR: fs_fkkcolfile-zzanrede.
  CLEAR: fs_fkkcolfile-zzname_gp1.
  CLEAR: fs_fkkcolfile-zzname_gp2.
  CLEAR: fs_fkkcolfile-zzname_gp3.
  CLEAR: fs_fkkcolfile-zzname_gp4.
  CLEAR: fs_fkkcolfile-zzpost_code1gp.
  CLEAR: fs_fkkcolfile-zzcity1gp.
  CLEAR: fs_fkkcolfile-zzcity2gp.
  CLEAR: fs_fkkcolfile-zzstreetgp.
  CLEAR: fs_fkkcolfile-zzhouse_num1gp.
  CLEAR: fs_fkkcolfile-zzhouse_num2gp.
  CLEAR: fs_fkkcolfile-zzland.
  CLEAR: fs_fkkcolfile-zztel1.
  CLEAR: fs_fkkcolfile-zztel2.
  CLEAR: fs_fkkcolfile-zzfax1.
  CLEAR: fs_fkkcolfile-zzfax2.
  CLEAR: fs_fkkcolfile-zzsmtp.
  CLEAR: fs_fkkcolfile-zzbirthdt.
  CLEAR: fs_fkkcolfile-zzbankl.
  CLEAR: fs_fkkcolfile-zzbankn.
  CLEAR: fs_fkkcolfile-zziban.
  CLEAR: fs_fkkcolfile-zzswift.
  CLEAR: fs_fkkcolfile-zzbanka.
  CLEAR: fs_fkkcolfile-zzkoinh.
  CLEAR: fs_fkkcolfile-zzkofiz_sd.
  CLEAR: fs_fkkcolfile-zzvertrag.
  CLEAR: fs_fkkcolfile-zzpost_code1vs.
  CLEAR: fs_fkkcolfile-zzcity1vs.
  CLEAR: fs_fkkcolfile-zzcity2vs.
  CLEAR: fs_fkkcolfile-zzstreetvs.
  CLEAR: fs_fkkcolfile-zzhouse_num1vs.
  CLEAR: fs_fkkcolfile-zzhouse_num2vs.
  CLEAR: fs_fkkcolfile-zzabrzu.
  CLEAR: fs_fkkcolfile-zzabrzo.
  CLEAR: fs_fkkcolfile-zztvorgtxt.
  CLEAR: fs_fkkcolfile-zzart.
  CLEAR: fs_fkkcolfile-zzbldat.
  CLEAR: fs_fkkcolfile-zzeinzdat.
  CLEAR: fs_fkkcolfile-zzspartxt.
  CLEAR: fs_fkkcolfile-zzfaellig.
  CLEAR: fs_fkkcolfile-zzrechnung.
  CLEAR: fs_fkkcolfile-zzausdt.
  CLEAR: fs_fkkcolfile-zzfreetext.
  CLEAR: fs_fkkcolfile-zzzinsdatum.
  CLEAR: fs_fkkcolfile-zzvt_beginn.
  CLEAR: fs_fkkcolfile-zzmobil.

ENDFORM.
