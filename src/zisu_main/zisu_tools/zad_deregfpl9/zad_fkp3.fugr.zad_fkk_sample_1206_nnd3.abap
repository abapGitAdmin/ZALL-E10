function zad_fkk_sample_1206_nnd3.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_OPBEL) LIKE  FKKOP-OPBEL OPTIONAL
*"     VALUE(I_OPUPK) LIKE  FKKOP-OPUPK OPTIONAL
*"     VALUE(I_OPUPW) LIKE  FKKOP-OPUPW OPTIONAL
*"     VALUE(I_OPUPZ) LIKE  FKKOP-OPUPZ OPTIONAL
*"     VALUE(I_GIVE_ONLY_TEXT) LIKE  BOOLE-BOOLE OPTIONAL
*"     REFERENCE(I_FKKEPOS) TYPE  FKKEPOS OPTIONAL
*"  EXPORTING
*"     VALUE(E_FTEXT) LIKE  OFICS-FTEXT
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

    if i_fkkepos-zzavis2 is initial.
*   Funktion nur möglich, wenn Avis identifizerbar ist
      mac_msg_putx co_msg_information '500' 'ZEK1'
        space space space space space.
      set extended check off.
      if 1 = 2. message i500(ZEK1). endif.
      set extended check on.
    else.
      submit rinv_monitoring with se_docnr-low = i_fkkepos-zzavis2
                         and return.
    endif.

  else.
    e_ftext    = text-nd3.
    e_messages = 'X'.     "no exception 'ERROR_MESSAGE' when called
  endif.

endfunction.
