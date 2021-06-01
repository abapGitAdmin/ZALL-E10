FUNCTION /adesso/r403_grupierung .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(X_ERGRD) LIKE  EINV01-ERGRD OPTIONAL
*"     REFERENCE(X_FKKVKP) LIKE  FKKVKP STRUCTURE  FKKVKP OPTIONAL
*"     REFERENCE(X_FKKVK) LIKE  FKKVK STRUCTURE  FKKVK OPTIONAL
*"     REFERENCE(X_PARAM) TYPE  ISU21_INVOICE_PARAM OPTIONAL
*"     REFERENCE(X_XEND) LIKE  REGEN-KENNZX OPTIONAL
*"  TABLES
*"      T_EVER STRUCTURE  EVER
*"      T_EABP STRUCTURE  EABP
*"      T_EITR STRUCTURE  EITRGR
*"      T_EABPS STRUCTURE  EABPSGR
*"      T_BILL_DOC TYPE  ISU2A_T_BILL_DOC
*"      T_VKK_DOC TYPE  ISU21_T_VKK_DOC_ID
*"      T_EVER_LOCK STRUCTURE  INVEVERLOCK OPTIONAL
*"      T_EITR_LOCK STRUCTURE  EITR OPTIONAL
*"      T_EABPS_LOCK STRUCTURE  EABPS OPTIONAL
*"      T_EXTERNAL_DOC STRUCTURE  EITRGR OPTIONAL
*"      T_INVTRIG STRUCTURE  FKKINV_TRIG_GR OPTIONAL
*"  CHANGING
*"     REFERENCE(XY_BILLING_MONTH_ERROR) TYPE  C OPTIONAL
*"     REFERENCE(XY_RECREATE_UNIT_ERROR) TYPE  C OPTIONAL
*"----------------------------------------------------------------------
* Änderungshistorie:
* Datum Benutzer Grund
*---------------------------------------------------------------------
*
*---------------------------------------------------------------------
  DATA: ls_eitr          TYPE eitrgr,
        ls_zeidet_edivar TYPE /adesso/edivar.

*---------------------------------------------------------------------
* EDIFACT an Endkunde
*---------------------------------------------------------------------
  CLEAR: ls_eitr, ls_zeidet_edivar.
  SORT t_eitr BY belnr ASCENDING.
  LOOP AT t_eitr INTO ls_eitr.
    IF ls_eitr-vkont = x_fkkvkp-vkont.
      IF x_fkkvkp-zzedivar IS NOT INITIAL.
        SELECT SINGLE * FROM /adesso/edivar INTO ls_zeidet_edivar WHERE
          edivariante = x_fkkvkp-zzedivar AND
          sparte = ls_eitr-sparte.
        IF sy-subrc <> 0.
          mac_msg_putx co_msg_warning '045' '/ADESSO/EDIFACT_INV'
            ls_eitr-vkont space space space space.
          IF 1 = 2. MESSAGE w045(/adesso/edifact_inv).ENDIF.
          DELETE TABLE t_eitr FROM ls_eitr.
          CONTINUE.
        ENDIF.

        IF ls_zeidet_edivar-refnr IS NOT INITIAL.
          IF x_fkkvkp-exvko IS INITIAL.
            mac_msg_putx co_msg_warning '047' '/ADESSO/EDIFACT_INV'
             ls_eitr-vkont space space space space.
            IF 1 = 2. MESSAGE w047(/adesso/edifact_inv).ENDIF.
            DELETE TABLE t_eitr FROM ls_eitr.
            CONTINUE.
          ENDIF.
        ENDIF.
        IF ls_zeidet_edivar-drucksperre IS INITIAL.
          mac_msg_putx co_msg_warning '048' '/ADESSO/EDIFACT_INV'
            ls_eitr-vkont space space space space.
          IF 1 = 2. MESSAGE w048(/adesso/edifact_inv).ENDIF.
          DELETE TABLE t_eitr FROM ls_eitr.
          CONTINUE.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFUNCTION.
