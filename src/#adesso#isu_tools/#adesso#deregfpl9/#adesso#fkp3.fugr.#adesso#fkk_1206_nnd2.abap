function /ADESSO/FKK_1206_NND2.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_OPBEL) LIKE  FKKOP-OPBEL OPTIONAL
*"     VALUE(I_OPUPK) LIKE  FKKOP-OPUPK OPTIONAL
*"     VALUE(I_OPUPW) LIKE  FKKOP-OPUPW OPTIONAL
*"     VALUE(I_OPUPZ) LIKE  FKKOP-OPUPZ OPTIONAL
*"     VALUE(I_GIVE_ONLY_TEXT) LIKE  BOOLE-BOOLE OPTIONAL
*"     VALUE(I_VKONT) LIKE  FKKOP-VKONT OPTIONAL
*"     VALUE(I_GPART) LIKE  FKKOP-GPART OPTIONAL
*"     VALUE(I_FKKEPOS) LIKE  FKKEPOS STRUCTURE  FKKEPOS OPTIONAL
*"     VALUE(I_FKKL1) TYPE  FKKL1 OPTIONAL
*"     VALUE(I_CONTEXT) TYPE  FKKEPOS OPTIONAL
*"  EXPORTING
*"     VALUE(E_FTEXT) LIKE  OFICS-FTEXT
*"     VALUE(E_NO_DOC_KEY) LIKE  BOOLE-BOOLE
*"     VALUE(E_MESSAGES) LIKE  BOOLE-BOOLE
*"----------------------------------------------------------------------

  if i_give_only_text = space.
    if i_opbel is initial.
*  Funktion nur möglich, wenn Einzelposten identifizerbar ist
      mac_msg_putx co_msg_error '407' '>4'
        space space space space space.
      set extended check off.
      if 1 = 2. message e407(>4). endif.
      set extended check on.
    endif.

    set parameter id 'EESERVPROVID' field i_fkkepos-zzrecid.
    call transaction 'EEDMIDESERVPROV03' and skip first screen.

  else.
    e_ftext    = text-nd2.
    e_messages = 'X'.     "no exception 'ERROR_MESSAGE' when called
  endif.

endfunction.
