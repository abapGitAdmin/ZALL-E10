FUNCTION SE16N_GET_DATE_INTERVAL.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_SDATE) TYPE  SY-DATLO DEFAULT '00000000'
*"     REFERENCE(I_EDATE) TYPE  SY-DATLO DEFAULT '00000000'
*"  EXPORTING
*"     REFERENCE(E_SDATE) TYPE  SY-DATLO
*"     REFERENCE(E_EDATE) TYPE  SY-DATLO
*"  EXCEPTIONS
*"      CANCELED
*"----------------------------------------------------------------------

  gdu-sdate = i_sdate.
  gdu-edate = i_edate.

  call screen 0005 starting at 5 5 ending at 60 8.

  if gdu-fcode = 'CANC'.
     raise canceled.
  else.
     e_sdate = gdu-sdate.
     e_edate = gdu-edate.
  endif.

ENDFUNCTION.
