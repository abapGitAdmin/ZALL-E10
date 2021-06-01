FUNCTION /ADESSO/EA_POD_DATA.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_INT_UI) TYPE  INT_UI OPTIONAL
*"     REFERENCE(I_KEYDATUM) TYPE  D
*"     REFERENCE(I_EXT_UI) TYPE  EXT_UI OPTIONAL
*"  EXPORTING
*"     REFERENCE(E_METMETHOD) TYPE  EIDESWTMDMETMETHOD
*"     REFERENCE(E_GPART) TYPE  BU_PARTNER
*"     REFERENCE(E_METMETHODPODGROUP) TYPE  EIDESWTMDMETMETHOD
*"     REFERENCE(E_ANZAHL_ZW) TYPE  I
*"     REFERENCE(E_DISTRIBUTOR) TYPE  SERVICE_PROV_DIST
*"     REFERENCE(E_SERVICEID) TYPE  SERVICE_PROV
*"     REFERENCE(E_INVOICING_PARTY) TYPE  EVER-INVOICING_PARTY
*"     REFERENCE(E_SCENARIO) TYPE  E_DEREGSCENARIO
*"     REFERENCE(E_ANLAGE) TYPE  ANLAGE
*"     REFERENCE(E_SPARTE) TYPE  SPARTE
*"     REFERENCE(E_TARIFTYP) TYPE  TARIFTYP_ANL
*"     REFERENCE(E_AKLASSE) TYPE  AKLASSE
*"     REFERENCE(E_VERTRAG) TYPE  VERTRAG
*"     REFERENCE(E_VKONTO) TYPE  VKONT_KK
*"     REFERENCE(E_VSTELLE) TYPE  VSTELLE
*"     REFERENCE(E_DISCNO) TYPE  DISCNO
*"     REFERENCE(E_EXT_UI) TYPE  EUITRANS-EXT_UI
*"     REFERENCE(E_INT_UI) TYPE  EUIHEAD-INT_UI
*"     REFERENCE(E_EQUNR) TYPE  EQUNR
*"     REFERENCE(E_GUE) TYPE  ZEA_DATA_DEF-GUE
*"     REFERENCE(E_EINZDAT) TYPE  EVER-EINZDAT
*"     REFERENCE(E_KONDIGR) TYPE  KONDIGR
*"     REFERENCE(E_ABLEINH) TYPE  ABLEINH
*"----------------------------------------------------------------------

  DATA: wa_euitrans TYPE euitrans.
  IF i_int_ui IS INITIAL AND NOT i_ext_ui IS INITIAL.
    CALL FUNCTION 'ISU_DB_EUITRANS_EXT_SINGLE'
      EXPORTING
        x_ext_ui     = i_ext_ui
        x_keydate    = i_keydatum
      IMPORTING
        y_euitrans   = wa_euitrans
      EXCEPTIONS
        not_found    = 1
        system_error = 2
        OTHERS       = 3.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ELSE.
      E_INT_UI = wa_euitrans-int_ui.
    ENDIF.
  ELSE.
    E_INT_UI = I_INT_UI.
  ENDIF.

* Zählverfahren
  IF E_metmethod IS REQUESTED.

    PERFORM hole_metmethod USING e_int_ui
                             i_keydatum
                    CHANGING E_metmethod.

  ENDIF. "E_METMETHOD is requested.

** Geschäftspartner
  IF E_gpart IS REQUESTED.

    PERFORM hole_gpart USING E_INT_UI
                             i_keydatum
                    CHANGING E_gpart.
  ENDIF.


* Zählverfahren der Zählpunktgruppe

  IF E_metmethodpodgroup IS REQUESTED.

    PERFORM hole_metmethod USING E_INT_UI
                                 i_keydatum
                        cHANGING E_metmethodpodgroup.


  ENDIF. "E_METMETHODPODGROUP IS REQUESTED.


* Anzahl der zählenden Zählwerke
  IF E_anzahl_zw IS REQUESTED.
    PERFORM hole_anzahl_zw USING i_keydatum
                                 E_INT_UI
                        CHANGING E_anzahl_zw.

  ENDIF.

  IF E_distributor IS REQUESTED.
    PERFORM hole_distributor USING i_keydatum
                                   E_INT_UI
                          CHANGING E_distributor.

  ENDIF.

  IF E_serviceid IS REQUESTED
    OR E_invoicing_party IS REQUESTED.
    PERFORM hole_serviceid USING i_keydatum
                                 E_INT_UI
                        CHANGING E_serviceid
                                 E_invoicing_party.
  ENDIF.

  IF E_scenario IS REQUESTED.
    PERFORM hole_scenario  USING i_keydatum
                                 E_INT_UI
                        CHANGING E_scenario.
  ENDIF.

  IF E_anlage IS REQUESTED.
    PERFORM hole_anlage_int_ui USING i_keydatum
                                     E_INT_UI
                            CHANGING E_anlage.
  ENDIF.


  IF E_sparte IS REQUESTED.
    PERFORM hole_sparte USING i_keydatum
                              E_INT_UI
                     CHANGING E_sparte.

  ENDIF.

  IF E_tariftyp IS REQUESTED.
    PERFORM hole_tariftyp USING i_keydatum
                                E_INT_UI
                       CHANGING E_tariftyp.


  ENDIF.

  IF E_aklasse IS REQUESTED.
    PERFORM hole_aklasse  USING i_keydatum
                                E_INT_UI
                       CHANGING E_aklasse.



  ENDIF.

  IF E_vertrag IS REQUESTED.
    PERFORM hole_pod_vertrag  USING i_keydatum
                                    E_INT_UI
                           CHANGING E_vertrag.



  ENDIF.

  IF E_vkonto IS REQUESTED.
    PERFORM hole_pod_vkonto   USING i_keydatum
                                    E_INT_UI
                           CHANGING E_vkonto.
  ENDIF.

  IF E_vstelle IS REQUESTED.
    PERFORM hole_vstelle  USING i_keydatum
                                E_INT_UI
                       CHANGING E_vstelle.
  ENDIF.

  IF E_discno IS REQUESTED.
    PERFORM hole_discno USING E_INT_UI
                              i_keydatum
                              E_anlage
                        CHANGING E_discno.
  ENDIF.

  IF E_equnr IS REQUESTED.
    PERFORM hole_equnr USING i_keydatum
                             E_INT_UI
                    CHANGING E_equnr.
  ENDIF.

  IF E_gue IS REQUESTED.
     perform hole_gue using i_keydatum
                            E_INT_UI
                   changing E_gue.
  ENDIF.

  IF E_einzdat IS REQUESTED.
     perform hole_einzdat using i_keydatum
                                E_INT_UI
                       changing E_einzdat.

  ENDIF.

  IF E_KONDIGR IS REQUESTED.
     perform hole_kondigr using i_keydatum
                                E_INT_UI
                       changing E_KONDIGR.

  ENDIF.

  if E_Ableinh is requested.
      perform hole_ableinh using i_keydatum
                                 E_INT_UI
                        changing E_Ableinh.
  endif.

ENDFUNCTION.
