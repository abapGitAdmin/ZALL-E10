**----------------------------------------------------------------------*
****INCLUDE LZEIDE_NEW_INVOIC_V25F01.
**----------------------------------------------------------------------*
**&---------------------------------------------------------------------*
**&      Form  APPEND_ALC_PCD
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**      -->P_WA_ERDZ_ALC  text
**----------------------------------------------------------------------*
*FORM append_alc_pcd  USING  p_erdz TYPE erdz.
*
*  DATA: lv_rabtyp         TYPE rabtyp,
*        lv_rabart         TYPE rabart,
*        lv_charge_code    TYPE char3,
*        lv_percentage(20).
*
** Rabattschlüssel für Gemeinderabatt
*  lv_charge_code = gc_disc_qual_z01.
*
** fill and append ALC
*  SELECT SINGLE rabtyp rabart FROM edsc INTO (lv_rabtyp, lv_rabart)
*    WHERE rabzus = p_erdz-rabzus.
*  IF lv_rabtyp = co_rabtyp_disc.
*    alc-allow_charge_qualifier = co_qualifier_allowance.
*  ELSEIF lv_rabtyp = co_rabtyp_surcharge.
*    alc-allow_charge_qualifier = co_qualifier_charge.
*  ENDIF.
*
*  alc-allow_charge_code = lv_charge_code.
*
** Fill PCD
*  IF lv_rabart = co_rabart_perc.
*    pcd-percentage_type_qualifier = co_qaulifier_perctype.
*  ENDIF.
*
*  MOVE p_erdz-i_zahl2 TO lv_percentage.
*  SHIFT lv_percentage RIGHT DELETING TRAILING ' 0'.
*  SHIFT lv_percentage RIGHT DELETING TRAILING ',.'.
*  SHIFT lv_percentage LEFT DELETING LEADING space.
*
*  pcd-percentage = lv_percentage.
*
** Achtung Fortschreiben der erstellten Segmente erfolgt erst am Loop Ende
*ENDFORM.
**&---------------------------------------------------------------------*
**&      Form  CHECK_ADRESS_01
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**      -->is_nad_01  text
**      -->iv_kind_01   text
**      -->iv_partner_01   text
**----------------------------------------------------------------------*
*FORM check_adress_01  USING    is_nad_01     TYPE /isidex/e1vdewnad_3
*                               iv_kind_01    TYPE char2
*                               iv_partner_01 TYPE bu_partner.
*
*  IF is_nad_01-street1 IS INITIAL.
*
*    IF iv_kind_01 EQ 'DP'.
*
*      mac_msg_putx co_msg_error '058' 'ZEIDX_DEREG'
*       'Strassenbezeichnung'(010) iv_partner_01 space space
*      general_fault.
*
*    ELSE.
*
*      mac_msg_putx co_msg_error '058' 'ZEIDX_DEREG'
*        'Strassenbezeichnung'(010) is_nad_01-partner space space
*       general_fault.
*
*    ENDIF.
*
*  ENDIF.
*
*  IF is_nad_01-street3 IS INITIAL.
*
*    IF iv_kind_01 EQ 'DP'.
*
*      mac_msg_putx co_msg_error '058' 'ZEIDX_DEREG'
*      'Hausnummer'(011) iv_partner_01 space space space.
*
*    ELSE.
*
*      mac_msg_putx co_msg_error '058' 'ZEIDX_DEREG'
*        'Hausnummer'(011) is_nad_01-partner space space space.
*
*    ENDIF.
*
*  ENDIF.
*
*  IF is_nad_01-city IS INITIAL.
*
*    IF iv_kind_01 EQ 'DP'.
*
*      mac_msg_putx co_msg_error '058' 'ZEIDX_DEREG'
*      'Stadt'(012) iv_partner_01 space space
*     general_fault.
*
*    ELSE.
*
*      mac_msg_putx co_msg_error '058' 'ZEIDX_DEREG'
*        'Stadt'(012) is_nad_01-partner space space
*       general_fault.
*
*    ENDIF.
*
*  ENDIF.
*
*  IF is_nad_01-zipcode IS INITIAL.
*
*    IF iv_kind_01 EQ 'DP'.
*
*      mac_msg_putx co_msg_error '058' 'ZEIDX_DEREG'
*        'Postleitzahl'(013) iv_partner_01 space space
*       general_fault.
*
*    ELSE.
*
*      mac_msg_putx co_msg_error '058' 'ZEIDX_DEREG'
*        'Postleitzahl'(013) is_nad_01-partner space space
*       general_fault.
*
*    ENDIF.
*
*  ENDIF.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**&      Form  DETERMINE_DOC_DATE
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**      --> it_erdz  text
**      <--cv_ab  text
**      <--cv_bis  text
**----------------------------------------------------------------------*
*FORM determine_doc_date  USING    it_erdz TYPE erdz_tab
*                         CHANGING cv_ab    TYPE erdz-ab
*                                  cv_bis   TYPE erdz-bis.
*
*  FIELD-SYMBOLS: <erdz> TYPE erdz.
*
*  LOOP AT it_erdz ASSIGNING  <erdz>
*                      WHERE  xtotal_amnt = co_true.
*    IF cv_ab > <erdz>-ab OR
*       cv_ab IS INITIAL.
*      cv_ab = <erdz>-ab.
*    ENDIF.
*    IF cv_bis < <erdz>-bis.
*      cv_bis = <erdz>-bis.
*    ENDIF.
*  ENDLOOP.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**&      Form  DETERMINE_EXT_UI
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**      -->iv_int_ui  text
**      -->iv_keydate  text
**      <--cv_ext_u  text
**----------------------------------------------------------------------*
*FORM determine_ext_ui  USING   iv_int_ui  TYPE int_ui
*                               iv_keydate TYPE endabrpe
*                               is_ever TYPE ever
*                               CHANGING cv_ext_ui  TYPE ext_ui.
*
*  DATA: wa_euitrans TYPE euitrans,
*        ls_v_eanl   TYPE v_eanl,
*        lt_eanl     TYPE STANDARD TABLE OF eanl,
*        ls_eanl     TYPE eanl.
*
** switch Applicationlog off
*  switch_log_off.
*  CALL FUNCTION 'ISU_DB_EUITRANS_INT_SINGLE'
*    EXPORTING
*      x_int_ui     = iv_int_ui
*      x_keydate    = iv_keydate
*    IMPORTING
*      y_euitrans   = wa_euitrans
*    EXCEPTIONS
*      not_found    = 1
*      system_error = 2
*      OTHERS       = 3.
*  my_sysubrc = sy-subrc.
** switch Applicationlog on
*  switch_log_on.
*  IF my_sysubrc = 0.
*
*    CALL FUNCTION 'ISU_DB_EANL_SELECT'
*      EXPORTING
*        x_anlage     = is_ever-anlage
*        x_keydate    = iv_keydate
**       X_ACTUAL     =
*      IMPORTING
*        y_v_eanl     = ls_v_eanl
*      EXCEPTIONS
*        not_found    = 1
*        system_error = 2
*        invalid_date = 3
*        OTHERS       = 4.
*    IF sy-subrc <> 0.
*      CALL FUNCTION 'MSG_ACTION'
*        EXPORTING
*          x_action   = co_msg_last
*        IMPORTING
*          y_last_msg = last_msg.
*      mac_msg_putx_parm co_msg_error last_msg-msgno last_msg-msgid
*                      last_msg-msgv1 last_msg-msgv2 last_msg-msgv3
*                      last_msg-msgv4 general_fault last_msg-parm.
*    ENDIF.
*
*    IF ls_v_eanl-aklasse EQ 'VRTR'. " RLM
*      IF ls_v_eanl-anlart EQ 'GABX'.
*
*        CALL FUNCTION 'ISU_DB_EANL_SELECT_VST_SP'
*          EXPORTING
*            x_vstelle    = ls_v_eanl-vstelle
*            x_sparte     = ls_v_eanl-sparte
*          TABLES
*            yt_eanl      = lt_eanl
*          EXCEPTIONS
*            not_found    = 1
*            system_error = 2
*            OTHERS       = 3.
*        IF sy-subrc <> 0.
** Implement suitable error handling here
*        ENDIF.
*
*        READ TABLE lt_eanl INTO ls_eanl WITH KEY anlart = lc_gas_anlart_kom.
*
*        IF sy-subrc EQ 0.
*
*          CALL FUNCTION 'ISU_INT_UI_DETERMINE'
*            EXPORTING
**             X_CONTRACT        =
*              x_anlage          = ls_eanl-anlage
**             X_EXT_POD         =
**             X_INT_POD         =
*              x_keydate         = iv_keydate
*            IMPORTING
**             Y_CONTRACT        =
**             Y_ANLAGE          =
*              y_ext_pod         = cv_ext_ui
**             Y_INT_POD         =
**             Y_SPARTE          =
*            EXCEPTIONS
*              not_found         = 1
*              programming_error = 2
*              system_error      = 3
*              OTHERS            = 4.
*          IF sy-subrc <> 0.
** Implement suitable error handling here
*          ENDIF.
*
*
*        ENDIF.
*
*      ENDIF.
*    ELSE.
*      cv_ext_ui = wa_euitrans-ext_ui.
*    ENDIF.
*
*  ELSEIF my_sysubrc > 1.
*    CALL FUNCTION 'MSG_ACTION'
*      EXPORTING
*        x_action   = co_msg_last
*      IMPORTING
*        y_last_msg = last_msg.
*    mac_msg_putx_parm co_msg_error last_msg-msgno last_msg-msgid
*                    last_msg-msgv1 last_msg-msgv2 last_msg-msgv3
*                    last_msg-msgv4 general_fault last_msg-parm.
*  ENDIF.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**&      Form  DETERMINE_ISO_WAERS
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**      -->iv_waers   text
**      -->iv_iso_waers  text
**----------------------------------------------------------------------*
*FORM determine_iso_waers  USING    iv_waers     TYPE tcurc-waers
*                                   iv_iso_waers TYPE tcurc-isocd.
*
*
** switch Applicationlog off
*  switch_log_off.
*  CALL FUNCTION 'CURRENCY_CODE_SAP_TO_ISO'
*    EXPORTING
*      sap_code = iv_waers
*    IMPORTING
*      iso_code = iv_iso_waers  "defining ISO_WAERS
*    EXCEPTIONS
*      OTHERS   = 01.
*  my_sysubrc = sy-subrc.
** switch Applicationlog on
*  switch_log_on.
*  IF my_sysubrc <> 0.
*    CALL FUNCTION 'MSG_ACTION'
*      EXPORTING
*        x_action   = co_msg_last
*      IMPORTING
*        y_last_msg = last_msg.
*    mac_msg_putx_parm co_msg_error last_msg-msgno last_msg-msgid
*                    last_msg-msgv1 last_msg-msgv2 last_msg-msgv3
*                    last_msg-msgv4 general_fault last_msg-parm.
*  ENDIF.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**&      Form  DETERMINE_TAX_PERCENT
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**      -->is_invoice  text
**      -->is_erdz  text
**      -->iv_product_id  text
**      <--cv_taxrate_internal  text
**----------------------------------------------------------------------*
*FORM determine_tax_percent  USING    is_invoice TYPE isu21_print_doc
*                                     is_erdz    TYPE erdz
*                                     VALUE(iv_product_id) TYPE inv_product_id
*                                     CHANGING cv_taxrate_internal TYPE stprz_kk.
*
*  DATA: wa_erdz            TYPE erdz,
*        ls_taxtab          TYPE          fkktaxlin,
*        lt_taxtab          TYPE TABLE OF fkktaxlin,
*        lv_amount_tax_free TYPE sbasw_kk,
*        lv_artikelnummer   TYPE inv_product_id.
*
*
*  LOOP AT is_invoice-t_erdz INTO wa_erdz
*                         WHERE mwskz   = is_erdz-mwskz
*                           AND belzart = 'SUBT'
*                           AND NOT stprz IS INITIAL.
*    cv_taxrate_internal = wa_erdz-taxrate_internal.
*    EXIT.
*  ENDLOOP.
*  IF sy-subrc <> 0.
*    CALL FUNCTION 'FKK_TAX_LINES_CREATE'
*      EXPORTING
*        i_waers    = is_erdz-twaers
*        i_bukrs    = is_erdz-bukrs
*        i_betrw    = is_erdz-nettobtr
*        i_mwskz    = is_erdz-mwskz
*        i_txjcd    = is_erdz-txjcd
*        i_txdat    = is_erdz-txdat_kk
*        i_xnett    = space
*      TABLES
*        t_taxlines = lt_taxtab
*      EXCEPTIONS
*        OTHERS     = 1.
*    IF sy-subrc NE 0.
*      IF 1 = 2.
*        MESSAGE a898(e9) WITH space space space space.
*      ENDIF.
*    ENDIF.
*    IF lines( lt_taxtab ) = 1.
*      READ TABLE lt_taxtab INTO ls_taxtab INDEX 1.
*      cv_taxrate_internal = ls_taxtab-stprz.
** If the tax rate is 0, the value of item is accumulated in tax free amount.
**      IF cv_taxrate_internal IS INITIAL AND iv_product_id IS NOT INITIAL.
**        SELECT SINGLE artikelnummer
**          FROM zeidxc_taxfreear
**          INTO lv_artikelnummer
**          WHERE artikelnummer = iv_product_id.
**        IF sy-subrc = 0.
**          CLEAR lv_amount_tax_free.
**          lv_amount_tax_free = ls_taxtab-sbasw.
**          gv_tax_free_sum = gv_tax_free_sum + lv_amount_tax_free.
**        ENDIF.
**      ENDIF.
*
*    ENDIF.
*  ENDIF.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**&      Form  FILL_IDOC_CONTROL
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**      -->iv_receiver  text
**      <--cs_idoc_contro  text
**----------------------------------------------------------------------*
*FORM fill_idoc_control  USING   iv_receiver TYPE service_prov
*                       CHANGING cs_idoc_control TYPE edidc.
*
*  cs_idoc_control-mestyp = 'ISU_BILL_INFORMATION'.
*  cs_idoc_control-idoctp = co_isu_invoic_vdew.      "Basis Idoc Type
*  cs_idoc_control-cimtyp = space.                 "Customer extension
*  cs_idoc_control-sndpfc = space.
*  cs_idoc_control-sndprn = space.
*  cs_idoc_control-sndprt = space.
*  cs_idoc_control-rcvpfc = space.                 "Partner Role Receiv.
*  cs_idoc_control-rcvprn = iv_receiver.            "Partner Nr.
*  cs_idoc_control-rcvprt = 'SP'.                  "Partner Type Receiv.
*ENDFORM.
**&---------------------------------------------------------------------*
**&      Form  FILL_NAD
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**      -->x_provider  text
**      -->x_provider text
**      -->x_action  text
**      -->x_idoc_control  text
**      <--cs_nad
**      <--cv_tel_number  text
**      <--cv_bpartner   text
**----------------------------------------------------------------------*
*FORM fill_nad  USING    VALUE(x_provider) TYPE service_prov
*                       VALUE(x_int_ui)   TYPE int_ui
*                       VALUE(x_action)   TYPE /isidex/e1vdewnad_3-action
*                       VALUE(x_idoc_control) TYPE edidc
*              CHANGING cs_nad             TYPE /isidex/e1vdewnad_3
*                       cv_tel_number      TYPE ad_tlnmbr1
*                       cv_bpartner       TYPE bu_partner.
*
*  DATA: wa_eservprov TYPE eservprov,
*        wa_eadrdat   TYPE eadrdat,
*        wa_eadrdat_p TYPE eadrdat,
*        wa_sp_name   TYPE service_prov_text,
*        wa_t005u     TYPE t005u,
*        lv_text_01   TYPE c                    LENGTH 163.
*  DATA: wa_ekun_ext TYPE isu01_ekun.
*  DATA: lv_po_flag TYPE char1.
*
**   Begin of CR 2004A K20570 02.07.2013
*  CONSTANTS: lc_z01 TYPE char3 VALUE 'Z01',
*             lc_z02 TYPE char3 VALUE 'Z02'.
*  DATA:
*      lv_bpart  TYPE bu_partner.
*
*  CLEAR: cs_nad,
*         cv_tel_number.
*
*  cs_nad-action         = x_action.  "#01
*  CASE x_action.
** --- service provider
*    WHEN co_nad_sender OR co_nad_receiver.
**     switch Applicationlog off
*      switch_log_off.
*      CALL FUNCTION 'ISU_DB_ESERVPROV_SINGLE'
*        EXPORTING
*          x_serviceid = x_provider
*        IMPORTING
*          y_eservprov = wa_eservprov
*          y_sp_name   = wa_sp_name
*        EXCEPTIONS
*          not_found   = 1.
*      my_sysubrc = sy-subrc.
**     switch Applicationlog on
*      switch_log_on.
*      IF my_sysubrc <> 0.
*        CALL FUNCTION 'MSG_ACTION'
*          EXPORTING
*            x_action   = co_msg_last
*          IMPORTING
*            y_last_msg = last_msg.
*        mac_msg_putx_parm co_msg_error last_msg-msgno last_msg-msgid
*                        last_msg-msgv1 last_msg-msgv2 last_msg-msgv3
*                        last_msg-msgv4 general_fault last_msg-parm.
*      ENDIF.
*
*      IF wa_eservprov-externalid+4(1) = '-'.
*        wa_eservprov-externalid = wa_eservprov-externalid+5(15).
*      ENDIF.
*
*      cs_nad-partner        = wa_eservprov-externalid.   "#01
*      PERFORM partner_info USING    x_provider
*                           CHANGING wa_eadrdat
*                                    wa_t005u
*                                    lv_bpart.
*    WHEN co_nad_pod.
** --- pod
** --- determine partner data first
** --- if only business partner address should be filled
** --- into NAD segment, please replace wa_eadrdat_p by
** --- wa_eadrdat and delete perform pod_address and
** --- the following adress assignment
*      PERFORM business_partner_info  USING    x_provider
*                                     CHANGING wa_eadrdat_p
*                                              wa_t005u.
*
*
** --- determine address of point of delivery
*      PERFORM pod_address        USING    x_int_ui
*                                 CHANGING wa_eadrdat
*                                          wa_t005u.
*
** --- use partner name only
*      wa_eadrdat-name1   = wa_eadrdat_p-name1.
*      wa_eadrdat-name2   = wa_eadrdat_p-name2.
*      wa_eadrdat-name3   = wa_eadrdat_p-name3.
*      wa_eadrdat-name4   = wa_eadrdat_p-name4.
*
** --- for pod partner should only be used, if
** --- externalid corresponds to VDEW Codenumber
*      CLEAR wa_eservprov-externalid.
*
*      lv_bpart = x_provider. "Hier steckt die Business Partner Nummer drin
*  ENDCASE.
** ERP2007 Support of codelist of external Service Provider ID
*  IF NOT wa_eservprov-externalid IS INITIAL.
*    CALL FUNCTION 'ISU_DATEX_IDENT_CODELIST'
*      EXPORTING
*        x_ext_idtyp     = wa_eservprov-externalidtyp
*        x_idoc_control  = x_idoc_control
*      IMPORTING
*        y_extcodelistid = cs_nad-codelistagency
*      EXCEPTIONS
*        not_supported   = 1
*        error_occured   = 2
*        OTHERS          = 3.
*    IF sy-subrc <> 0.
*      mac_msg_putx co_msg_error sy-msgno sy-msgid
*              sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
*                                   general_fault.
*    ENDIF.
*  ENDIF.
*  IF x_action = co_nad_pod OR
*     x_action = co_nad_sender OR
*     x_action = co_nad_receiver.
*    CALL FUNCTION 'ISU_DB_PARTNER_SINGLE'
*      EXPORTING
*        x_partner                 = lv_bpart    "#01, alt: x_provider
*      IMPORTING
*        y_but000                  = wa_ekun_ext
*      EXCEPTIONS
*        partner_not_found         = 1
*        partner_in_role_not_found = 2
*        internal_error            = 3
*        OTHERS                    = 4.
*    IF sy-subrc <> 0.
*      mac_msg_repeat co_msg_error general_fault.
*    ENDIF.
*  ENDIF.
*
*  IF NOT wa_eadrdat IS INITIAL.
**--Distinguish?person?or?organization
**--Person
*    IF "x_action = co_nad_pod OR * Personenangaben zu DP fallen mit Version 2.6 weg
*       x_action = co_nad_sender OR
*       x_action = co_nad_receiver.
*
*      IF wa_ekun_ext-type = co_person.
*        cs_nad-partnername1 = wa_ekun_ext-name_last.
*        cs_nad-partnername3 = wa_ekun_ext-name_first.
*        cs_nad-partnerformat = lc_z01.
*        CLEAR: cs_nad-partnername2.
**--Middle Name or initials
*        IF NOT wa_ekun_ext-namemiddle IS INITIAL.
*          cs_nad-partnername4 = wa_ekun_ext-namemiddle.
*        ELSEIF NOT wa_ekun_ext-initials IS INITIAL.
*          cs_nad-partnername4 = wa_ekun_ext-initials.
*        ENDIF.
**--Title
*        IF NOT wa_ekun_ext-title_aca1 IS INITIAL.
*          PERFORM read_aca_title
*                      USING    wa_ekun_ext-title_aca1
*                      CHANGING cs_nad-partnername5.
*        ELSEIF NOT wa_ekun_ext-title_aca2 IS INITIAL.
*          PERFORM read_aca_title
*                      USING    wa_ekun_ext-title_aca2
*                      CHANGING cs_nad-partnername5.
*        ENDIF.
*
**--Organization
*      ELSEIF wa_ekun_ext-type = co_organization.
*
*        CLEAR: cs_nad-partnername1,
*               cs_nad-partnername2,
*               cs_nad-partnername3,
*               cs_nad-partnername4,
*               cs_nad-partnername5,
*               lv_text_01.
*
*        IF wa_ekun_ext-name_org1+35(5) NE space.
*
*          CONCATENATE wa_ekun_ext-name_org1
*                      wa_ekun_ext-name_org2
*                      wa_ekun_ext-name_org3
*                      wa_ekun_ext-name_org4 INTO lv_text_01 SEPARATED BY space.
*
*
*          MOVE lv_text_01+0(35)   TO cs_nad-partnername1.
*          MOVE lv_text_01+35(35)  TO cs_nad-partnername2.
*          MOVE lv_text_01+70(35)  TO cs_nad-partnername3.
*          MOVE lv_text_01+105(35) TO cs_nad-partnername4.
*          MOVE lv_text_01+140(23) TO cs_nad-partnername5.
*
*        ELSE.
*
*          MOVE wa_ekun_ext-name_org1 TO cs_nad-partnername1.
*          MOVE wa_ekun_ext-name_org2 TO cs_nad-partnername2.
*          MOVE wa_ekun_ext-name_org3 TO cs_nad-partnername3.
*          MOVE wa_ekun_ext-name_org4 TO cs_nad-partnername4.
*
*        ENDIF.
*
*
*        SHIFT cs_nad-partnername1 LEFT DELETING LEADING space.
*        SHIFT cs_nad-partnername2 LEFT DELETING LEADING space.
*        SHIFT cs_nad-partnername3 LEFT DELETING LEADING space.
*        SHIFT cs_nad-partnername4 LEFT DELETING LEADING space.
*        SHIFT cs_nad-partnername5 LEFT DELETING LEADING space.
*
*
*        cs_nad-partnerformat = lc_z02.
*
*
*      ELSEIF wa_ekun_ext-type = co_group.
*        cs_nad-partnername1 = wa_ekun_ext-name_grp1.
*        cs_nad-partnername2 = wa_ekun_ext-name_grp2.
*        MESSAGE e174(zeidex_dereg)
*        RAISING  general_fault.
*        CLEAR:
*           cs_nad-partnername3,
*           cs_nad-partnername4,
*           cs_nad-partnername5.
*      ENDIF.
*    ENDIF.
*
**--Set PO box as higher priority
*    lv_po_flag = 'X'.
*
**--Street information
*    IF x_action = co_nad_pod OR
*       x_action = co_nad_sender OR
*       x_action = co_nad_receiver.
*      PERFORM fill_street USING lv_po_flag
*                                wa_eadrdat
*                          CHANGING cs_nad.
*
** The REGION element group is not supported by VDEW. They will also not provide
** any code lists for the region ID. Thus we will not support/send region information.
*      IF wa_eadrdat-post_code2 IS INITIAL.
*        cs_nad-zipcode        = wa_eadrdat-post_code1.
*      ELSE.
*        cs_nad-zipcode        = wa_eadrdat-post_code2.
*      ENDIF.
*      cs_nad-country        = wa_eadrdat-country.
*      "cv_tel_number         = wa_eadrdat-tel_number.
*    ENDIF.
*  ENDIF.
*
*  cv_bpartner = lv_bpart.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**&      Form  BUSINESS_PARTNER_INFO
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**      -->iv_bupart  text
**      <--cs_eadrdat  text
**      <--cs_t005u text
**----------------------------------------------------------------------*
*FORM business_partner_info  USING     iv_bupart    TYPE bu_partner
*                            CHANGING cs_eadrdat   TYPE eadrdat
*                                     cs_t005u     TYPE t005u.
*  CLEAR: cs_eadrdat,
*          cs_t005u.
*
** Busines partner info (address data)
*  IF NOT iv_bupart IS INITIAL.
**   switch Applicationlog off
*    switch_log_off.
*    CALL FUNCTION 'ISU_ADDRESS_PROVIDE'
*      EXPORTING
*        x_address_type             = 'B'
*        x_partner                  = iv_bupart
*      IMPORTING
*        y_eadrdat                  = cs_eadrdat
*      EXCEPTIONS
*        not_found                  = 1
*        parameter_error            = 2
*        object_not_given           = 3
*        address_inconsistency      = 4
*        installation_inconsistency = 5.
*    my_sysubrc = sy-subrc.
**   switch Applicationlog on
*    switch_log_on.
*    IF my_sysubrc <> 0.
*      CALL FUNCTION 'MSG_ACTION'
*        EXPORTING
*          x_action   = co_msg_last
*        IMPORTING
*          y_last_msg = last_msg.
*      mac_msg_putx_parm co_msg_error last_msg-msgno last_msg-msgid
*                      last_msg-msgv1 last_msg-msgv2 last_msg-msgv3
*                      last_msg-msgv4 general_fault last_msg-parm.
*    ENDIF.
*
**   Region
*    IF NOT cs_eadrdat-region IS INITIAL.
**     switch Applicationlog off
*      switch_log_off.
*      CALL FUNCTION 'T005U_SINGLE_READ'
*        EXPORTING
*          t005u_spras = sy-langu
*          t005u_land1 = cs_eadrdat-country
*          t005u_bland = cs_eadrdat-region
*        IMPORTING
*          wt005u      = cs_t005u
*        EXCEPTIONS
*          not_found   = 1.
*      my_sysubrc = sy-subrc.
**     switch Applicationlog on
*      switch_log_on.
*      IF my_sysubrc <> 0.
**     do nothing
*      ENDIF.
*    ENDIF.
*
*  ENDIF.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**&      Form  FILL_ORIG_REF
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**      -->x_crossrefno  text
**      -->iv_rff_referencenumber   text
**----------------------------------------------------------------------*
*FORM fill_orig_ref  USING VALUE(x_crossrefno)     TYPE crossrefno
*                          iv_rff_referencenumber TYPE /isidex/e1vdewbgm_1-documentnumber.
*
*  DATA: lv_xcrn                  TYPE e_xcrn VALUE co_space.
*
** Only in case of new CRN determination scenario
*  CALL FUNCTION 'ISU_DB_DEREGSWITCHSYST_SELECT'
*    IMPORTING
*      e_xcrn                  = lv_xcrn
*    EXCEPTIONS
*      customizing_not_defined = 1
*      OTHERS                  = 2.
*  IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.
*
*  IF lv_xcrn IS INITIAL.
*    iv_rff_referencenumber = x_crossrefno.
*  ELSE.
*    SELECT SINGLE crn_rev FROM ecrossrefno INTO iv_rff_referencenumber
*      WHERE crossrefno = x_crossrefno.
*    IF iv_rff_referencenumber IS INITIAL.
*      iv_rff_referencenumber = x_crossrefno.
*    ENDIF.
*  ENDIF.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**&      Form  FILL_STCEG
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**      -->iv_vkont_agg  text
**      <--cv_rff1numb  text
**----------------------------------------------------------------------*
*FORM fill_stceg  USING    iv_vkont_agg TYPE vkont_kk
*                 CHANGING cv_rff1numb TYPE /idexge/e1vdewrff_12-referencenumber.
*
*  DATA: wa_stdbk TYPE stdbk_kk,
*        wa_t001  TYPE t001,
*        wa_t001z TYPE t001z.
*
*  CONSTANTS: lc_party TYPE party VALUE 'SAP011'.
*
** switch Applicationlog off
*  switch_log_off.
*
** read company code data
*  CALL FUNCTION 'FKK_STDBK_DETERMINE'
*    EXPORTING
*      i_vkont        = iv_vkont_agg
*    IMPORTING
*      e_stdbk        = wa_stdbk
*    EXCEPTIONS
*      no_stdbk_found = 1
*      OTHERS         = 2.
*  my_sysubrc = sy-subrc.
** switch Applicationlog on
*  switch_log_on.
*  IF my_sysubrc <> 0.
*    CALL FUNCTION 'MSG_ACTION'
*      EXPORTING
*        x_action   = co_msg_last
*      IMPORTING
*        y_last_msg = last_msg.
*    mac_msg_putx_parm co_msg_error last_msg-msgno last_msg-msgid
*                    last_msg-msgv1 last_msg-msgv2 last_msg-msgv3
*                    last_msg-msgv4 general_fault last_msg-parm.
*  ENDIF.
*
** switch Applicationlog off
*  switch_log_off.
*
*  CALL FUNCTION 'FKK_COMP_CODE_DATA_ADD'
*    EXPORTING
*      i_bukrs = wa_stdbk
*      i_party = lc_party
*    IMPORTING
*      e_t001z = wa_t001z.
*
*  my_sysubrc = sy-subrc.
** switch Applicationlog on
*  switch_log_on.
*  IF my_sysubrc <> 0.
*    CALL FUNCTION 'MSG_ACTION'
*      EXPORTING
*        x_action   = co_msg_last
*      IMPORTING
*        y_last_msg = last_msg.
*    mac_msg_putx_parm co_msg_error last_msg-msgno last_msg-msgid
*                    last_msg-msgv1 last_msg-msgv2 last_msg-msgv3
*                    last_msg-msgv4 general_fault last_msg-parm.
*  ENDIF.
*
*  IF wa_t001z-paval IS INITIAL.
*    mac_msg_putx co_msg_error '703' 'EDEREG_INV' wa_t001z-bukrs
*                              space space
*                              space general_fault.
*    IF 1 > 2.
*      MESSAGE e703(edereg_inv) WITH wa_t001z-bukrs.
*    ENDIF.
*  ENDIF.
*
** fill tax number
*  cv_rff1numb = wa_t001z-paval.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**&      Form  FILL_STREET
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**      -->iv_po_flag  text
**      -->is_eadrdat  text
**      <--cs_nad   text
**----------------------------------------------------------------------*
*FORM fill_street  USING    iv_po_flag TYPE char1
*                           is_eadrdat TYPE eadrdat
*                  CHANGING cs_nad     TYPE /isidex/e1vdewnad_3.
*
*  DATA:
*    lv_house_num       TYPE zeided_hausnummer,
*    lv_house_number    TYPE eideswtmdhousenr,
*    lv_house_extension TYPE eideswtmdhousenrext.
*
*  lv_house_num = is_eadrdat-house_num1.
*
*  IF NOT iv_po_flag IS INITIAL.
*
*    IF is_eadrdat-po_box IS INITIAL.
*      cs_nad-street1 = is_eadrdat-street.
*      IF strlen( is_eadrdat-street ) > 35 .
*        cs_nad-street2 = is_eadrdat-street+35.
*      ENDIF.
*      IF is_eadrdat-house_num1 IS NOT INITIAL.
*
*        CALL FUNCTION 'Z_EIDE_FORMAT_HOUSENUM'
*          EXPORTING
*            id_housenum        = lv_house_num
*          IMPORTING
*            ed_house_number    = lv_house_number
*            ed_house_extension = lv_house_extension.
*
*        cs_nad-street3 = lv_house_number.
*        cs_nad-street4 = lv_house_extension.
*
*      ELSE.
*
*        IF is_eadrdat-house_num2 CO '1234567890'.
*
*          cs_nad-street3 = is_eadrdat-house_num2.
*
*          SHIFT cs_nad-street3 LEFT DELETING LEADING space.
*
*        ELSE.
*
*          cs_nad-street4 = is_eadrdat-house_num2.
*
*          SHIFT cs_nad-street4 LEFT DELETING LEADING space.
*
*        ENDIF.
*
*
*
*      ENDIF.
*
*
*      "cs_nad-street3 = is_eadrdat-house_num1.    "Deaktivierung SAP coding
*      "cs_nad-street4 = is_eadrdat-house_num2.    "Deaktivierung SAP coding
*      cs_nad-city    = is_eadrdat-city1.
*    ELSE.
*      cs_nad-street1 = text-001.
*      cs_nad-street2 = is_eadrdat-po_box.
*      cs_nad-city    = is_eadrdat-po_box_loc.
*      IF is_eadrdat-po_box_loc IS INITIAL.
*        cs_nad-city    = is_eadrdat-city1.
*      ENDIF.
*      CLEAR:
*        cs_nad-street3,
*        cs_nad-street4.
*    ENDIF.
*
*  ELSE.
*
*    IF NOT is_eadrdat-street IS INITIAL.
*      cs_nad-street1 = is_eadrdat-street.
*      IF strlen( is_eadrdat-street ) > 35 .
*        cs_nad-street2 = is_eadrdat-street+35.
*      ENDIF.
*      IF is_eadrdat-house_num1 IS NOT INITIAL.
*
*        CALL FUNCTION 'Z_EIDE_FORMAT_HOUSENUM'
*          EXPORTING
*            id_housenum        = lv_house_num
*          IMPORTING
*            ed_house_number    = lv_house_number
*            ed_house_extension = lv_house_extension.
*
*        cs_nad-street3 = lv_house_number.
*
*      ELSE.
*
*        cs_nad-street3 = is_eadrdat-house_num2.
*
*      ENDIF.
*
*      cs_nad-street4 = lv_house_extension.
*      "cs_nad-street3 = is_eadrdat-house_num1.    "Deaktivierung SAP coding
*      "cs_nad-street4 = is_eadrdat-house_num2.    "Deaktivierung SAP coding
*      cs_nad-city    = is_eadrdat-city1.
*    ELSEIF NOT is_eadrdat-po_box IS INITIAL.
*      cs_nad-street1 = text-001.
*      cs_nad-street2 = is_eadrdat-po_box.
*      cs_nad-city    = is_eadrdat-po_box_loc.
*      IF is_eadrdat-po_box_loc IS INITIAL.
*        cs_nad-city    = is_eadrdat-city1.
*      ENDIF.
*
*      CLEAR:
*        cs_nad-street3,
*        cs_nad-street4.
*    ENDIF.
*  ENDIF.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**&      Form  FILL_TAX
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**      -->is_erdz  text
**      <--cs_tax  text
**----------------------------------------------------------------------*
*FORM fill_tax USING    is_erdz TYPE erdz
*              CHANGING cs_tax  TYPE tax_struc_out.
*
*  CLEAR cs_tax.
*
*  cs_tax-mwskz       = is_erdz-mwskz.
*  cs_tax-taxrate_internal  = is_erdz-taxrate_internal.
*  cs_tax-sbetw       = is_erdz-sbetw.
*  cs_tax-sbasw       = is_erdz-sbasw.
*  cs_tax-sbasw_gross = is_erdz-sbasw + is_erdz-sbetw.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**&      Form  GET_DIVISION_CATEGORY
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**      -->iv_int_ui  text
**      <--cv_division_category  text
**----------------------------------------------------------------------*
*FORM get_division_category  USING    iv_int_ui TYPE int_ui
*                            CHANGING cv_division_category TYPE spartyp.
*
** -> get division type from POD
*  CLEAR cv_division_category.
*  CALL METHOD /idexgg/cl_pod_environment=>select_spartyp
*    EXPORTING
*      iv_int_ui   = iv_int_ui
*    IMPORTING
*      ev_spartyp  = cv_division_category
*    EXCEPTIONS
*      not_found   = 1
*      no_input_ui = 2
*      OTHERS      = 3.
*
*  IF sy-subrc <> 0.
*  ENDIF.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**&      Form  GET_MEASURE_UNIT
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**      -->iv_massbill  text
**      -->iv_unit_qualifier  text
**----------------------------------------------------------------------*
*FORM get_measure_unit  USING iv_massbill TYPE t006-msehi
*                             iv_unit_qualifier TYPE
*                             /idexge/e1vdewqty_3-measure_unit_qualifier.
*
*  CONSTANTS: co_iso_kwh(3)   TYPE c VALUE 'KWH',
*             co_iso_kwt(3)   TYPE c VALUE 'KWT',
*             co_iso_krh(3)   TYPE c VALUE 'KRH',
*             co_iso_kva(3)   TYPE c VALUE 'KVA',
*             co_iso_day(3)   TYPE c VALUE 'DAY',
*             co_iso_month(3) TYPE c VALUE 'MON',
*             co_iso_year(3)  TYPE c VALUE 'ANN',
*             co_iso_pce(3)   TYPE c VALUE 'PCE'.
*
*  DATA: wa_t006 TYPE t006.
*
** switch Applicationlog off
*  switch_log_off.
*  CALL FUNCTION 'ISU_DB_T006_SINGLE'
*    EXPORTING
*      x_msehi      = iv_massbill
*    IMPORTING
*      y_t006       = wa_t006
*    EXCEPTIONS
*      not_found    = 1
*      system_error = 2
*      OTHERS       = 3.
*  my_sysubrc = sy-subrc.
** switch Applicationlog on
*  switch_log_on.
*  IF my_sysubrc <> 0.
*    CALL FUNCTION 'MSG_ACTION'
*      EXPORTING
*        x_action   = co_msg_last
*      IMPORTING
*        y_last_msg = last_msg.
*    mac_msg_putx_parm co_msg_error last_msg-msgno last_msg-msgid
*                    last_msg-msgv1 last_msg-msgv2 last_msg-msgv3
*                    last_msg-msgv4 general_fault last_msg-parm.
*  ENDIF.
*  CASE wa_t006-isocode.
*    WHEN co_iso_kwh.
*      iv_unit_qualifier = co_qty_unit_qualifier_kwh.
*    WHEN co_iso_kwt.
*      iv_unit_qualifier = co_qty_unit_qualifier_kwt.
*    WHEN co_iso_krh.
*      iv_unit_qualifier = co_qty_unit_qualifier_kah.
*    WHEN co_iso_kva.
*      iv_unit_qualifier = co_qty_unit_qualifier_kvr.
*    WHEN co_iso_day.
*      iv_unit_qualifier = co_qty_unit_qualifier_day.
*    WHEN co_iso_month.
*      iv_unit_qualifier = co_qty_unit_month.
*    WHEN co_iso_year.
*      iv_unit_qualifier = co_qty_unit_year.
*    WHEN co_iso_pce.
*      iv_unit_qualifier = co_qty_unit_piece.
*    WHEN OTHERS.
*      iv_unit_qualifier = wa_t006-isocode.
*  ENDCASE.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**&      Form  GET_PRODUCT_ID
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*FORM get_product_id USING   is_erdz        TYPE erdz
*                             iv_sender      TYPE service_prov
*                             iv_receiver    TYPE service_prov
*                             iv_vkont_agg   TYPE e_edmidevkont_aggbill
*                             iv_sparte      TYPE spart
*                    CHANGING cv_product_id  TYPE inv_product_id
*                             cv_product_id_type TYPE inv_product_id_type
*                             cv_cust_status1 TYPE kennzx
*                             cv_cust_status2 TYPE kennzx
*                             cv_typ          TYPE string
*                             cv_int_serident TYPE int_serident.
*
*  DATA: wa_sidproint       TYPE edereg_sidproint,
*        wa_sidpro          TYPE edereg_sidpro,
*        wa_product_id_type TYPE inv_product_id_type.
*
*  CLEAR: cv_cust_status1,
*         cv_cust_status2,
*         cv_product_id,
*         cv_product_id_type.
*
** switch Applicationlog off
*  switch_log_off.
*
** read product id type
*  PERFORM read_product_id_type USING iv_vkont_agg
*                                     iv_sender
*                                     iv_receiver
*                                     iv_sparte
*                            CHANGING wa_product_id_type.
*
** read internal product or service identifier
*  CALL FUNCTION 'ISU_DB_EDEREG_SIDPROINT_SELECT'
*    EXPORTING
*      x_hvorg            = is_erdz-hvorg
*      x_tvorg            = is_erdz-tvorg
*      x_belzart          = is_erdz-belzart
*    IMPORTING
*      y_edereg_sidproint = wa_sidproint
*    EXCEPTIONS
*      not_found          = 1
*      system_error       = 2
*      OTHERS             = 3.
*  IF sy-subrc <> 0.
** Das auskommentierte Coding muß zunächst stehen bleiben, da noch nicht eindeutig
** geklärt werden konnte, welchen Regeln die Ermittlung der Artikelnummer im
** Vertriebssystem tatsächlich folgt.
** Deaktiviertes Coding wurde vierfach ausgesternt.
***** Nach endgültiger Klärung erfolgt die Bereinigung des Bausteins.
*****    CALL FUNCTION 'ISU_DB_EDEREG_SIDPROINT_SELECT'
*****      EXPORTING
*****        x_hvorg            = is_erdz-hvorg
*****        x_tvorg            = is_erdz-tvorg
*****      IMPORTING
*****        y_edereg_sidproint = wa_sidproint
*****      EXCEPTIONS
*****        not_found          = 1
*****        system_error       = 2
*****        OTHERS             = 3.
*
*    IF sy-subrc <> 0. " OR
*****       is_erdz-hvorg <> wa_sidproint-hvorg OR
*****       is_erdz-tvorg <> wa_sidproint-tvorg.
*****      CALL FUNCTION 'ISU_DB_EDEREG_SIDPROINT_SELECT'
*****        EXPORTING
*****          x_hvorg            = is_erdz-tvorg
*****        IMPORTING
*****          y_edereg_sidproint = wa_sidproint
*****        EXCEPTIONS
*****          not_found          = 1
*****          system_error       = 2
*****          OTHERS             = 3.
*      IF sy-subrc <> 0. " OR
**         is_erdz-tvorg <> wa_sidproint-tvorg.
*        CALL FUNCTION 'ISU_DB_EDEREG_SIDPROINT_SELECT'
*          EXPORTING
*            x_belzart          = is_erdz-belzart
*          IMPORTING
*            y_edereg_sidproint = wa_sidproint
*          EXCEPTIONS
*            not_found          = 1
*            system_error       = 2
*            OTHERS             = 3.
*        IF sy-subrc <> 0.
*          cv_cust_status1 = 'X'.
*        ELSEIF is_erdz-belzart <> wa_sidproint-belzart.
*          CLEAR wa_sidproint.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*  ENDIF.
*
*  IF NOT wa_sidproint-int_serident IS INITIAL.
*    IF NOT wa_product_id_type IS INITIAL.
*      CALL FUNCTION 'ISU_DB_EDEREG_SIDPRO_SELECT'
*        EXPORTING
*          x_int_serident    = wa_sidproint-int_serident
*          x_product_id_type = wa_product_id_type
*        IMPORTING
*          y_edereg_sidpro   = wa_sidpro
*        EXCEPTIONS
*          not_found         = 1
*          system_error      = 2
*          not_qualified     = 3
*          OTHERS            = 4.
*      IF sy-subrc <> 0.
*        IF wa_product_id_type EQ '002'.
*          cv_typ = 'BDEW (bis 01.10.2010)'.
*        ELSEIF wa_product_id_type EQ '003'.
*          cv_typ = 'DVGW (bis 01.10.2010)'.
*        ELSEIF wa_product_id_type EQ '004'.
*          cv_typ = 'BDEW'.
*        ELSEIF wa_product_id_type EQ '005'.
*          cv_typ = 'Gas-XBCM / EINK / VERK - 4st.Kürzel'.
*        ELSE.
*          cv_typ = 'Unbekannt'.
*        ENDIF.
*
*        cv_cust_status2 = 'X'.
*        cv_int_serident = wa_sidproint-int_serident.
*      ENDIF.
*      cv_product_id_type = wa_product_id_type.
*      cv_product_id      = wa_sidpro-product_id.
*    ENDIF.
*  ENDIF.
*
** switch Applicationlog on
*  switch_log_on.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**&      Form  GET_TRANSACTIONS
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*
*FORM get_transactions  CHANGING cv_hv_bbp_p TYPE hvorg_kk
*                               cv_hv_bbp_r TYPE hvorg_kk
*                               cv_tv_bbp_p TYPE tvorg_kk
*                               cv_tv_bbp_r TYPE tvorg_kk.
*
*  STATICS: s_bbphv_p TYPE hvorg_kk,
*           s_bbphv_r TYPE hvorg_kk,
*           s_bbptv_p TYPE tvorg_kk,
*           s_bbptv_r TYPE tvorg_kk.
*
*  IF s_bbphv_p IS INITIAL OR
*     s_bbphv_r IS INITIAL OR
*     s_bbptv_p IS INITIAL OR
*     s_bbptv_r IS INITIAL.
*
**   switch Applicationlog off
*    switch_log_off.
*    CALL FUNCTION 'ISU_DB_TEIVV_SELECT'
*      EXPORTING
*        i_ihvor             = '0050'
*        i_itvor             = '0010'
*        i_applk             = 'R'
*      IMPORTING
*        e_hvorg             = s_bbphv_p
*        e_tvorg             = s_bbptv_p
*      EXCEPTIONS
*        not_found           = 1
*        int_trans_not_valid = 2
*        trans_not_valid     = 3
*        OTHERS              = 4.
*    my_sysubrc = sy-subrc.
**   switch Applicationlog on
*    switch_log_on.
*    IF my_sysubrc <> 0.
*      CALL FUNCTION 'MSG_ACTION'
*        EXPORTING
*          x_action   = co_msg_last
*        IMPORTING
*          y_last_msg = last_msg.
*      mac_msg_putx_parm co_msg_error last_msg-msgno last_msg-msgid
*                      last_msg-msgv1 last_msg-msgv2 last_msg-msgv3
*                      last_msg-msgv4 general_fault last_msg-parm.
*    ENDIF.
*
**   switch Applicationlog off
*    switch_log_off.
*    CALL FUNCTION 'ISU_DB_TEIVV_SELECT'
*      EXPORTING
*        i_ihvor             = '0050'
*        i_itvor             = '0020'
*        i_applk             = 'R'
*      IMPORTING
*        e_hvorg             = s_bbphv_r
*        e_tvorg             = s_bbptv_r
*      EXCEPTIONS
*        not_found           = 1
*        int_trans_not_valid = 2
*        trans_not_valid     = 3
*        OTHERS              = 4.
*    my_sysubrc = sy-subrc.
**   switch Applicationlog on
*    switch_log_on.
*    IF my_sysubrc <> 0.
*      CALL FUNCTION 'MSG_ACTION'
*        EXPORTING
*          x_action   = co_msg_last
*        IMPORTING
*          y_last_msg = last_msg.
*      mac_msg_putx_parm co_msg_error last_msg-msgno last_msg-msgid
*                      last_msg-msgv1 last_msg-msgv2 last_msg-msgv3
*                      last_msg-msgv4 general_fault last_msg-parm.
*    ENDIF.
*
*  ENDIF.
*  cv_hv_bbp_p = s_bbphv_p.
*  cv_hv_bbp_r = s_bbphv_r.
*  cv_tv_bbp_p = s_bbptv_p.
*  cv_tv_bbp_r = s_bbptv_r.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**&      Form  GET_UNH_REFNO
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**      <--cv_refno  text
**----------------------------------------------------------------------*
*FORM get_unh_refno  CHANGING cv_refno TYPE char12.
*
*  CALL FUNCTION 'ISU_NUMBER_GET'
*    EXPORTING
**     NR_RANGE_NUMBER                   =
*      object = 'ISU_CREFNO'
**     QUANTITY                          = '1'
**     NUMBER_IN                         =
**     UPD_KZ = 'X'
**     NO_MESSAGE                        =
*    IMPORTING
*      number = cv_refno
**     QUANTITY                          =
**     EXTINTKZ                          =
**     NR_RANGE_NUMBER                   =
*    EXCEPTIONS
*      OTHERS = 1.
*  IF sy-subrc <> 0.
*    mac_msg_repeat co_msg_error general_fault.
*  ENDIF.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**&      Form  GET_VAT_ID_DE
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**      -->iv_partner_id  text
**      <--cv_rff2_referencenumber  text
**----------------------------------------------------------------------*
*FORM get_vat_id_de  USING  iv_partner_id
*                  CHANGING cv_rff2_referencenumber.
*
*  SELECT SINGLE taxnum
*    FROM dfkkbptaxnum
*    INTO cv_rff2_referencenumber
*    WHERE partner = iv_partner_id AND
*          taxtype EQ 'DE4'.
*  IF sy-subrc <> 0.
*    "macht nichts.
*  ENDIF.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**&      Form  GET_VAT_ID_NOT_DE
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**      -->iv_partner_id  text
**      <--cv_rff2_referencenumber  text
**----------------------------------------------------------------------*
*FORM get_vat_id_not_de  USING    iv_partner_id
*                  CHANGING cv_rff2_referencenumber.
*
*  SELECT SINGLE taxnum
*    FROM dfkkbptaxnum
*    INTO cv_rff2_referencenumber
*    WHERE partner = iv_partner_id
*    AND   taxtype NE 'DE*'
*    .
*  IF sy-subrc <> 0.
*    "macht nichts.
*  ENDIF.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**&      Form  MOVE_AMOUNT
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**      -->iv_amount_p       text
**      -->iv_akt_curr   text
**      -->iv_amount_c  text
**----------------------------------------------------------------------*
*FORM move_amount  USING iv_amount_p TYPE betrw_kk
*                        iv_akt_curr TYPE any
*                        iv_amount_c TYPE /isidex/e1vdewmoa_1-monetary_amount_value.
*
*  DATA: lv_up_curr TYPE waers_curc.
*
*  lv_up_curr = iv_akt_curr.
** switch Applicationlog off
*  switch_log_off.
*  CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_IDOC'
*    EXPORTING
*      currency    = lv_up_curr
*      sap_amount  = iv_amount_p
*    IMPORTING
*      idoc_amount = iv_amount_c
*    EXCEPTIONS
*      OTHERS      = 1.
*  my_sysubrc = sy-subrc.
** switch Applicationlog on
*  switch_log_on.
*  IF my_sysubrc <> 0.
*    CALL FUNCTION 'MSG_ACTION'
*      EXPORTING
*        x_action   = co_msg_last
*      IMPORTING
*        y_last_msg = last_msg.
*    mac_msg_putx_parm co_msg_error last_msg-msgno last_msg-msgid
*                    last_msg-msgv1 last_msg-msgv2 last_msg-msgv3
*                    last_msg-msgv4 general_fault last_msg-parm.
*  ENDIF.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**&      Form  PARTNER_INFO
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*FORM partner_info  USING    iv_serviceid TYPE service_prov
*                  CHANGING cs_eadrdat   TYPE eadrdat
*                           cs_t005u     TYPE t005u
*                           cv_bpart    TYPE bu_partner.
*
*  DATA wa_eservprovp    TYPE eservprovp.
*
** Business partner
*  switch_log_off.
*  CALL FUNCTION 'ISU_DB_ESERVPROVP_SINGLE'
*    EXPORTING
*      x_serviceid  = iv_serviceid
*    IMPORTING
*      y_eservprovp = wa_eservprovp
*    EXCEPTIONS
*      not_found    = 1
*      OTHERS       = 2.
*  my_sysubrc = sy-subrc.
*  switch_log_on.
*  IF my_sysubrc <> 0.
*    CALL FUNCTION 'MSG_ACTION'
*      EXPORTING
*        x_action   = co_msg_last
*      IMPORTING
*        y_last_msg = last_msg.
*    mac_msg_putx_parm co_msg_error last_msg-msgno last_msg-msgid
*                    last_msg-msgv1 last_msg-msgv2 last_msg-msgv3
*                    last_msg-msgv4 general_fault last_msg-parm.
*  ENDIF.
*  cv_bpart = wa_eservprovp-bpart.
*  PERFORM business_partner_info  USING    wa_eservprovp-bpart
*                                 CHANGING cs_eadrdat
*                                          cs_t005u.
*ENDFORM.
**&---------------------------------------------------------------------*
**&      Form  POD_ADDRESS
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*FORM pod_address  USING    iv_int_ui    TYPE int_ui
*                            CHANGING cs_eadrdat   TYPE eadrdat
*                                     cs_t005u     TYPE t005u.
*
*  CLEAR: cs_eadrdat,
*         cs_t005u.
*
*  IF NOT iv_int_ui IS INITIAL.
**   switch Applicationlog off
*    switch_log_off.
*    CALL FUNCTION 'ISU_ADDRESS_PROVIDE'
*      EXPORTING
*        x_address_type             = 'Z'
*        x_int_ui                   = iv_int_ui
*      IMPORTING
*        y_eadrdat                  = cs_eadrdat
*      EXCEPTIONS
*        not_found                  = 1
*        parameter_error            = 2
*        object_not_given           = 3
*        address_inconsistency      = 4
*        installation_inconsistency = 5.
*    my_sysubrc = sy-subrc.
**   switch Applicationlog on
*    switch_log_on.
*    IF my_sysubrc <> 0.
*      CALL FUNCTION 'MSG_ACTION'
*        EXPORTING
*          x_action   = co_msg_last
*        IMPORTING
*          y_last_msg = last_msg.
*      mac_msg_putx_parm co_msg_error last_msg-msgno last_msg-msgid
*                      last_msg-msgv1 last_msg-msgv2 last_msg-msgv3
*                      last_msg-msgv4 general_fault last_msg-parm.
*    ENDIF.
*
**   Region
*    IF NOT cs_eadrdat-region IS INITIAL.
**     switch Applicationlog off
*      switch_log_off.
*      CALL FUNCTION 'T005U_SINGLE_READ'
*        EXPORTING
*          t005u_spras = sy-langu
*          t005u_land1 = cs_eadrdat-country
*          t005u_bland = cs_eadrdat-region
*        IMPORTING
*          wt005u      = cs_t005u
*        EXCEPTIONS
*          not_found   = 1.
*      my_sysubrc = sy-subrc.
**   switch Applicationlog on
*      switch_log_on.
*    ENDIF.
*    IF my_sysubrc <> 0.
**   do nothing
*    ENDIF.
*  ENDIF.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**&      Form  READ_ACA_TITLE
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*FORM read_aca_title  USING    VALUE(iv_title) TYPE ad_title1
*                     CHANGING cv_paraname     TYPE char35.
*
*  DATA: lv_paraname TYPE ad_title1t.
*
*  CLEAR cv_paraname.
*
*  CALL FUNCTION 'ADDR_TSAD2_READ'
*    EXPORTING
*      title_key     = iv_title
*    IMPORTING
*      title_text    = lv_paraname
*    EXCEPTIONS
*      key_not_found = 1
*      OTHERS        = 2.
*  IF sy-subrc = 0.
*    cv_paraname = lv_paraname.
*  ENDIF.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**&      Form  READ_PRODUCT_ID_TYPE
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*FORM read_product_id_type  USING iv_vkont_agg        TYPE e_edmidevkont_aggbill
*             iv_sender           TYPE service_prov
*             iv_receiver         TYPE service_prov
*             iv_sparte           TYPE sparte
*    CHANGING cv_product_id_type  TYPE inv_product_id_type.
*
*  DATA: lt_param         TYPE ttinv_param_inv_outbound_ser,
*        wa_param         TYPE inv_param_inv_outbound_ser,
*        wa_param_out     TYPE inv_param_inv_outbound,
*        wa_thi_param     TYPE inv_param_inv_outbound_thi,
*        wa_account_param TYPE inv_param_inv_outbound_acc,
*        ls_servp         TYPE eservprovp,
*        ls_vkontp        TYPE fkkvkp,
*        lt_vkontp        TYPE TABLE OF fkkvkp,
*        lv_gpart         TYPE bu_partner,
*        lv_spart         TYPE service_prov,
*        lv_novk          TYPE flag,
*        ls_eservprovp    TYPE eservprovp.
*
** switch Applicationlog off
*  switch_log_off.
** get deregulation parameters
*  CALL FUNCTION 'ISU_DEREG_PARAM_INV_OUTBOUND'
*    EXPORTING
*      x_keydate          = sy-datum
*      x_initiator        = iv_receiver(10)
*      x_partner          = iv_sender(10)
*    IMPORTING
*      y_param            = lt_param
*    EXCEPTIONS
*      no_parameter_found = 1
*      internal_error     = 2
*      OTHERS             = 3.
*  my_sysubrc = sy-subrc.
** switch Applicationlog on
*  switch_log_on.
*  IF my_sysubrc <> 0.
*    CALL FUNCTION 'MSG_ACTION'
*      EXPORTING
*        x_action   = co_msg_last
*      IMPORTING
*        y_last_msg = last_msg.
*    mac_msg_putx_parm co_msg_error last_msg-msgno last_msg-msgid
*                    last_msg-msgv1 last_msg-msgv2 last_msg-msgv3
*                    last_msg-msgv4 general_fault last_msg-parm.
*  ENDIF.
*  READ TABLE lt_param INDEX 1 INTO wa_param.
*  CHECK sy-subrc = 0.
*  READ TABLE wa_param-param INDEX 1 INTO wa_param_out.
*  CHECK sy-subrc = 0.
** determine V_GROUP
*
*  READ TABLE wa_param_out-account_param INTO wa_account_param
*       WITH KEY vkont_aggbill = iv_vkont_agg.
*
** Suche eines passenden aggregierten Vertragskontos zum GP und prüfe mit SAV
*  IF sy-subrc NE 0.
*
*    CALL FUNCTION 'ISU_DB_ESERVPROVP_SINGLE'
*      EXPORTING
*        x_serviceid  = iv_receiver
*      IMPORTING
*        y_eservprovp = ls_eservprovp
*      EXCEPTIONS
*        not_found    = 1
*        OTHERS       = 2.
*    IF sy-subrc <> 0.
*      mac_msg_putx co_msg_error sy-msgno sy-msgid
*                   sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
*                                        general_fault.
*    ENDIF.
*
*
**    SELECT SINGLE * FROM fkkvkp INTO ls_vkontp
**      WHERE vkont = iv_vkont_agg.
**    lv_gpart = ls_vkontp-gpart.
*
*    lv_gpart = ls_eservprovp-bpart.
*    CLEAR ls_vkontp.
*
*    CASE iv_sparte.
*      WHEN '01'.
*        SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_vkontp
*          FROM fkkvkp AS a
*          INNER JOIN fkkvk AS b
*          ON b~vkont = a~vkont
*          WHERE a~gpart = lv_gpart
*          AND  b~vktyp = 'A7'.
*      WHEN '02'.
*        SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_vkontp
*            FROM fkkvkp AS a
*            INNER JOIN fkkvk AS b
*            ON b~vkont = a~vkont
*            WHERE a~gpart = lv_gpart
*            AND  b~vktyp = 'A7'.
*    ENDCASE.
*
*    IF sy-subrc <> 0 OR lt_vkontp[] IS INITIAL.
*      lv_novk = 'X'.
*    ENDIF.
*
*    LOOP AT lt_vkontp INTO ls_vkontp.
*      CLEAR lv_novk.
*
*      READ TABLE wa_param_out-account_param INTO wa_account_param
*      WITH KEY vkont_aggbill = ls_vkontp-vkont.
*
*      IF sy-subrc NE 0.
*        lv_novk = 'X'.
*      ELSE.
** determine PRODUCT_ID_TYPE
*        READ TABLE wa_param_out-thi_param INTO wa_thi_param
*             WITH KEY v_group = wa_account_param-v_group.
*        CHECK sy-subrc = 0.
*        cv_product_id_type = wa_thi_param-product_id_type.
*        EXIT.
*      ENDIF.
*    ENDLOOP.
*
*    IF lv_novk IS NOT INITIAL.
*
*      CLEAR: lv_gpart, lt_vkontp.
*      lv_spart = wa_param-initiator.
** Select braucht keine Fehlerbehandlung, da SA immer Verknüpfung zum GP hat.
*      SELECT SINGLE * FROM eservprovp INTO ls_servp
*        WHERE serviceid = lv_spart.
*      lv_gpart = ls_servp-bpart.
*
*      CASE iv_sparte.
*        WHEN '01'.
*          SELECT * FROM fkkvkp INTO TABLE lt_vkontp
*           WHERE gpart = lv_gpart
*           AND  kofiz_sd = '6A'.
*        WHEN '02'.
*          SELECT * FROM fkkvkp INTO TABLE lt_vkontp
*          WHERE gpart = lv_gpart
*          AND  kofiz_sd = '7A'.
*      ENDCASE.
** CASE und Select braucht keine Fehlerbehandlung, da Vkonto für SA im Fall INVOICE immer 6A oder 7A hat
*      LOOP AT lt_vkontp INTO ls_vkontp.
*        READ TABLE wa_param_out-account_param INTO wa_account_param
*        WITH KEY vkont_aggbill = ls_vkontp-vkont.
*        CHECK sy-subrc = 0.
*        READ TABLE wa_param_out-thi_param INTO wa_thi_param
*        WITH KEY v_group = wa_account_param-v_group.
*        CHECK sy-subrc = 0.
*        cv_product_id_type = wa_thi_param-product_id_type.
*        EXIT.
*      ENDLOOP.
*
*    ENDIF.
*  ELSE.
*
** determine PRODUCT_ID_TYPE
*    READ TABLE wa_param_out-thi_param INTO wa_thi_param
*         WITH KEY v_group = wa_account_param-v_group.
*    CHECK sy-subrc = 0.
*    cv_product_id_type = wa_thi_param-product_id_type.
*
*  ENDIF.
*  IF cv_product_id_type IS INITIAL.
** Defaultwert setzen: BDEW
*    cv_product_id_type = '004'.
*  ENDIF.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**&      Form  REVERSE_AMNT_QUANT
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**      -->P_WA_ERDZ  text
**----------------------------------------------------------------------*
*FORM reverse_amnt_quant  USING    is_erdz TYPE erdz.
*
*  is_erdz-sbasw      = - 1 * is_erdz-sbasw.
*  is_erdz-sbetw      = - 1 * is_erdz-sbetw.
*  is_erdz-betrw      = - 1 * is_erdz-betrw.
*  is_erdz-augbw      = - 1 * is_erdz-augbw.
*  is_erdz-sktow      = - 1 * is_erdz-sktow.
*  is_erdz-asktw      = - 1 * is_erdz-asktw.
*  is_erdz-nettobtr   = - 1 * is_erdz-nettobtr.
*  is_erdz-nettofrmd  = - 1 * is_erdz-nettofrmd.
*  is_erdz-i_abrmenge = - 1 * is_erdz-i_abrmenge.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**&      Form  ROUND_NUMBER
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*FORM round_number     USING    VALUE(iv_stanznac) TYPE stanznace
*             VALUE(iv_mode)     TYPE char1
*    CHANGING VALUE(cv_number)   TYPE any.
*
*  CALL FUNCTION 'ISU_BI_ROUND'
*    EXPORTING
*      decimals      = iv_stanznac
*      input         = cv_number
*      sign          = iv_mode
*    IMPORTING
*      output        = cv_number
*    EXCEPTIONS
*      input_invalid = 1
*      overflow      = 2
*      type_invalid  = 3
*      OTHERS        = 4.
*  IF sy-subrc <> 0.
*    mac_msg_repeat 'E' general_fault.
*  ENDIF.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**&      Form  SELECT_CTA_COM
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*FORM select_cta_com  USING    iv_erch_endabrpe TYPE endabrpe
*           iv_invoice_erdk_partner TYPE bu_partner
*           iv_bukrs         TYPE bukrs
*           iv_basicproc     TYPE e_dexbasicproc
*           iv_ever          TYPE ever
*  CHANGING es_clerk_data    TYPE zeidxc_clerk
*           ev_subrc         TYPE sysubrc
*           cv_partner_01    TYPE bu_partner.
*
*  CONSTANTS:
*    lc_sprache    TYPE spras VALUE 'D',
*    lc_trennz     TYPE char1 VALUE ';',
*    co_reltyp_abr TYPE bu_reltyp VALUE 'Z016'.
*
*  DATA:
*    ls_clerk_data  TYPE zeidxc_clerk, "Name + Komm.daten Sachbearbeiter
*    ld_text        TYPE text50,
*    lw_clerk       TYPE zeidxc_clerk,
*    ld_contactname TYPE zeidxc_clerk-clerk_name,
*    ld_telnummer   TYPE zeidxc_clerk-phone,
*    ld_faxnummer   TYPE zeidxc_clerk-fax,
*    lw_com         TYPE /isidex/e1vdewcom_1,
*    lw_cta         TYPE /isidex/e1vdewcta_1,
*    lv_dat_but050  TYPE datum,          "Zeitscheiben Datum BUT050
*    lv_bupa_cta    TYPE bu_partner.     "Abrechner vom Kunden
*
*
**- Zeitscheibe für Ansprechpartner Selektion bestimmen
*  IF iv_erch_endabrpe IS NOT INITIAL.
*    lv_dat_but050 = iv_erch_endabrpe.
*  ELSE.
*    lv_dat_but050 = sy-datum.
*  ENDIF.
*
**- Ansprechpartner selektieren
**  IF iv_bukrs EQ gc_bukrs_eav OR
**     iv_bukrs EQ gc_bukrs_edi.
**    "Sonderlogik für Avacon + Edis; #20
**    SELECT SINGLE zzabrechner
**      FROM ever
**      INTO lv_bupa_cta
**      WHERE vertrag = iv_ever.
**  ELSE.
*  SELECT SINGLE partner2
*    FROM but050
*    INTO lv_bupa_cta
*    WHERE reltyp    = co_reltyp_abr AND
*          partner1  = iv_invoice_erdk_partner AND
*          date_to   >= lv_dat_but050 AND
*          date_from <= lv_dat_but050.
**  ENDIF.
*  IF sy-subrc = 0.
**- Daten zum GP lesen
*
*    MOVE lv_bupa_cta TO cv_partner_01.
*
*    PERFORM select_bp_data
*      USING    lv_bupa_cta
*               lv_dat_but050
*      CHANGING es_clerk_data
*               ev_subrc.
*  ELSE.
*    "nichts hinterlegt -> Standard Sachbearbeiter selektieren
*    IF gt_zeidxc_clerk IS INITIAL. "einmaligs Lesen von DB + puffern
*      SELECT *                                        "#EC CI_SGLSELECT
*      FROM zeidxc_clerk
*      INTO TABLE gt_zeidxc_clerk
*      WHERE dexbasicproc = iv_basicproc.                "#EC CI_NOFIRST
*      IF sy-subrc <> 0.
*        ev_subrc = sy-subrc.
*        MESSAGE e077(zeidx_dereg) WITH space iv_basicproc.
*        "Kein Ansprechpart. in Tab. zeidxc_clerk gefunden.
*        " BUKRS &1, Datexproc &2
*        RETURN.
*      ENDIF.
*    ENDIF.
*
*    READ TABLE gt_zeidxc_clerk
*      INTO es_clerk_data
*      WITH KEY bukrs        = iv_bukrs
*               dexbasicproc = iv_basicproc.
*    IF sy-subrc <> 0.
*      ev_subrc = sy-subrc.
*      MESSAGE i077(zeidx_dereg) WITH iv_bukrs iv_basicproc.
*      "Kein Ansprechpart. in Tab. zeidxc_clerk gefunden.
*      " BUKRS &1, Datexproc &2
*    ELSE.
*      ev_subrc = 0.
*    ENDIF.
*  ENDIF.            "sy-subrc <> 0 bei Lesen von BUT050
*
*ENDFORM.
**&---------------------------------------------------------------------*
**&      Form  SELECT_BP_DATA
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**      -->P_LV_BUPA_CTA  text
**      -->P_LV_DAT_BUT050  text
**      <--P_ES_CLERK_DATA  text
**      <--P_EV_SUBRC  text
**----------------------------------------------------------------------*
*FORM select_bp_data  USING    iv_bupa_cta   TYPE bu_partner
*             iv_datum      TYPE datum
*    CHANGING es_clerk_data TYPE zeidxc_clerk
*             ev_subrc      TYPE sysubrc.
*  DATA:
*    lv_name_last  TYPE bu_namep_l,
*    lv_name_first TYPE bu_namep_f,
*    lv_persnumber TYPE ad_persnum,
*    lv_addrnumber TYPE ad_addrnum,
*    lt_adr2       TYPE TABLE OF adr2,
*    lw_adr2       TYPE adr2,
*    ls_but000     TYPE but000,
*    lv_time_01    TYPE c               LENGTH 14.
*
*  CONCATENATE iv_datum '000000' INTO lv_time_01.
*
**- Hinweis: aus Performancegründen wird nicht Fuba ISU_DB_PARTNER_SINGLE
*  " verwendet, sondern direkter DB Zugriff auf die ADR Tabellen
*
** Änderungen Beginn H5649  14.01.2011 --------------------------
****- Name + Personennr. lesen
**  select single name_last name_first persnumber
**    from but000
**    into (lv_name_last, lv_name_first, lv_persnumber)
**    where partner = iv_bupa_cta.
**  if sy-subrc = 0.
**    concatenate lv_name_first lv_name_last
**      into es_clerk_data-clerk_name
**      separated by space.
*
*  SELECT SINGLE *
*      FROM but000  INTO ls_but000
*      WHERE partner = iv_bupa_cta.
*  IF sy-subrc = 0.
*    CASE ls_but000-type.
*      WHEN '1'.
*        CONCATENATE ls_but000-name_first ls_but000-name_last
*         INTO es_clerk_data-clerk_name
*         SEPARATED BY space.
*      WHEN '2'.
*        CONCATENATE ls_but000-name_org1  ls_but000-name_org2
*     INTO es_clerk_data-clerk_name
*     SEPARATED BY space.
*      WHEN '3'.
*        CONCATENATE ls_but000-name_grp1   ls_but000-name_grp2
*     INTO es_clerk_data-clerk_name
*     SEPARATED BY space.
*      WHEN OTHERS.
**    do nothing
*    ENDCASE.
*  ELSE.
*    ev_subrc = sy-subrc.
*    RETURN.
*  ENDIF.
*
****- Adressnr. lesen
*  SELECT SINGLE addrnumber
*    FROM but020
*    INTO lv_addrnumber
*    WHERE partner = iv_bupa_cta.
*  IF sy-subrc <> 0.
*    ev_subrc = sy-subrc.
*    RETURN.
*  ENDIF.
*
*  ev_subrc = 0. "wenn hier angekommen, dann kein Fehler
*
****- Kommunikationsdaten lesen
***- Telefonnummern (Festnetz + mobile)
*  SELECT * FROM adr2
*    INTO TABLE lt_adr2
*    WHERE   addrnumber EQ lv_addrnumber      AND
*            flgdefault NE space              AND
*            valid_from LE lv_time_01         AND
*            valid_to   EQ space.
*  IF sy-subrc <> 0.
*    SELECT * FROM adr2
*    INTO TABLE lt_adr2
*    WHERE   addrnumber EQ lv_addrnumber      AND
*            flgdefault NE space              AND
*            valid_from LE lv_time_01          AND
*            valid_to   GE lv_time_01.
*  ENDIF.
*
** Festnetz
*  READ TABLE lt_adr2 INTO lw_adr2
*    WITH KEY r3_user = space.
*  IF sy-subrc <> 0.
*    READ TABLE lt_adr2 INTO lw_adr2
*    WITH KEY r3_user = '1'.
*  ENDIF.
*  es_clerk_data-phone = lw_adr2-telnr_long.
** handy
*  READ TABLE lt_adr2 INTO lw_adr2
*    WITH KEY r3_user = '3'.
*  IF sy-subrc <> 0.
*    READ TABLE lt_adr2 INTO lw_adr2
*  WITH KEY r3_user = '2'.
*  ENDIF.
*  es_clerk_data-mobile = lw_adr2-telnr_long.
*
*
***- Telefax
*  SELECT SINGLE faxnr_long FROM adr3
*    INTO es_clerk_data-fax
*    WHERE   addrnumber EQ lv_addrnumber      AND
*            flgdefault NE space              AND
*            valid_from LE lv_time_01         AND
*            valid_to   EQ space.
*  IF sy-subrc NE 0.
*
*    SELECT SINGLE faxnr_long FROM adr3
*      INTO es_clerk_data-fax
*      WHERE   addrnumber EQ lv_addrnumber      AND
*              flgdefault NE space              AND
*              valid_from LE lv_time_01         AND
*              valid_to   GE lv_time_01.
*
*  ENDIF.
*
***- email Adresse
*  SELECT SINGLE smtp_addr FROM adr6
*    INTO es_clerk_data-email
*    WHERE   addrnumber EQ lv_addrnumber      AND
*            flgdefault NE space              AND
*            valid_from LE lv_time_01          AND
*            valid_to   EQ space.
*  IF sy-subrc <> 0.
*    SELECT SINGLE smtp_addr FROM adr6
*      INTO es_clerk_data-email
*      WHERE   addrnumber EQ lv_addrnumber      AND
*              flgdefault NE space              AND
*              valid_from LE lv_time_01         AND
*              valid_to   GE lv_time_01.
*  ENDIF.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**&      Form  SUM_TAX
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**      -->P_IT_BILL_TAX  text
**      <--P_WA_BILL_TAX_SUM  text
**----------------------------------------------------------------------*
*FORM sum_tax  USING    it_tax TYPE ANY TABLE
*             CHANGING cv_sum_tax TYPE sbetw_kk.
*
*  DATA wa_tax TYPE tax_struc_out.
*  CLEAR cv_sum_tax.
*
*  LOOP AT it_tax INTO wa_tax.
*    cv_sum_tax = cv_sum_tax + wa_tax-sbetw.
*  ENDLOOP.
*
*ENDFORM.
