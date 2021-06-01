FUNCTION zadm_req_popup.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  EXPORTING
*"     REFERENCE(E_REQ_LOG) TYPE  ZADM_REQ_LOG
*"     REFERENCE(E_OK) TYPE  OK
*"----------------------------------------------------------------------
  CLEAR zadm_req_log.

  zadm_req_log-uname = sy-uname.
  zadm_req_log-datum = sy-datum.
  zadm_req_log-kunde = 'adesso'.



  CALL SCREEN 100 STARTING AT 1 1 ENDING AT 40 10.

  e_req_log-zmandt  = zadm_req_log-zmandt.
  e_req_log-beschreibung = zadm_req_log-beschreibung.
  e_req_log-uname = zadm_req_log-uname.
  e_req_log-kunde = zadm_req_log-kunde.
  e_req_log-datum = zadm_req_log-datum.
  e_req_log-zweck = zadm_req_log-zweck.
  IF g_ok_code IS NOT INITIAL.
    e_ok = g_ok_code.
  ELSE.
    e_ok = 'ABR'.
  ENDIF.



ENDFUNCTION.
