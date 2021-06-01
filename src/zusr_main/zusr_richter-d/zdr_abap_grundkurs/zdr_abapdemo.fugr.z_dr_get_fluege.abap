function z_dr_get_fluege.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IV_CARRID) TYPE  S_CARR_ID
*"  EXPORTING
*"     REFERENCE(ET_FLUEGE) TYPE  ZDR_T_FLUEGE
*"  EXCEPTIONS
*"      NO_AUTH
*"----------------------------------------------------------------------

  authority-check object 'S_CARRID'
    id 'CARRID' field iv_carrid
    id 'ACTVT' field '03'.

  if sy-subrc <> 0.
    raise no_auth.
  endif.

  select * from spfli into table et_fluege where carrid = iv_carrid.

  if sy-subrc <> 0.
    write 'Fehler beim auslesen der Tab'.
  endif.

endfunction.
