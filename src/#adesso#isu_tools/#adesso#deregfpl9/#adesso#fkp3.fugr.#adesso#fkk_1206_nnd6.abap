function /ADESSO/FKK_1206_NND6.
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

  data: x_initiator type service_prov.
  data: t_yparam  type ttinv_param_inv_outbound_ser.
  data: t_param   type ttinv_param_inv_outbound.
  data: t_acpar   type ttinv_param_inv_outbound_acc.
  data: y_yparam  type inv_param_inv_outbound_ser.
  data: y_param   type inv_param_inv_outbound.
  data: y_acpar   type inv_param_inv_outbound_acc.

  field-symbols: <y_yparam> like y_yparam.
  field-symbols: <y_param> like y_param.
  field-symbols: <y_acpar> like y_acpar.

  if i_give_only_text = space.
    if i_opbel is initial.
*  Funktion nur möglich, wenn Einzelposten identifizerbar ist
      mac_msg_putx co_msg_error '407' '>4'
        space space space space space.
      set extended check off.
      if 1 = 2. message e407(>4). endif.
      set extended check on.
    endif.

    x_initiator = i_fkkepos-zzrecid.

    call function 'ISU_DEREG_PARAM_INV_OUTBOUND'
      exporting
        x_keydate   = sy-datum
        x_initiator = x_initiator
      importing
        y_param     = t_yparam
      exceptions
        others      = 3.

    if sy-subrc <> 0.
*   Funktion nur möglich, wenn SP identifizerbar ist
      mac_msg_putx co_msg_information '503' 'ZEK1'
        space space space space space.
      set extended check off.
      if 1 = 2. message i503(zek1). endif.
      set extended check on.
    else.
      loop at t_yparam assigning <y_yparam>.
        loop at <y_yparam>-param assigning <y_param>.
          loop at <y_param>-account_param assigning <y_acpar>.
            set parameter id 'KTO' field <y_acpar>-vkont_aggbill.
          endloop.
        endloop.
      endloop.
      call transaction 'FPL9'.
    endif.

  else.
    e_ftext    = text-nd6.
    e_messages = 'X'.     "no exception 'ERROR_MESSAGE' when called
  endif.

endfunction.
