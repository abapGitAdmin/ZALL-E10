FUNCTION /adesso/mte_ent_podservice_02.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(X_ANLAGE) LIKE  EANL-ANLAGE
*"     REFERENCE(PFAD_DAT_ENT) TYPE  EMG_PFAD
*"  EXPORTING
*"     REFERENCE(ANZ_OBJ) TYPE  I
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"  EXCEPTIONS
*"      NO_OPEN
*"      NO_CLOSE
*"      WRONG_DATA
*"      GEN_ERROR
*"      ERROR
*"----------------------------------------------------------------------
  DATA  object          TYPE  emg_object.
  DATA  ent_file        TYPE  emg_pfad.
  DATA: ums_fuba        TYPE  funcname.
  DATA: o_key           TYPE  emg_oldkey.
  DATA: p_beginn        TYPE  sy-datum.

*Hilfstabellen zur Ermittlung der Services:
  DATA: ieuiinstln TYPE TABLE OF euiinstln WITH HEADER LINE.

* Hilfstabelle ESERVICE zum Ermitteln des Beginndatums
  DATA it_eservice TYPE STANDARD TABLE OF eservice.
  DATA: wa_eservice TYPE eservice.
  DATA: h_index(1) TYPE n.


  object   = 'PODSERVICE'.
  ent_file = pfad_dat_ent.
  oldkey_pos = x_anlage.

* Ermitteln des Umschlüsselung-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.
*>   Initialisierung
  PERFORM init_pos.

  CLEAR: ipos_out, wpos_out, meldung, anz_obj.
  REFRESH: ipos_out, meldung.

** AB-Datum aus Tabelle /ADESSO/MTE_DTAB
*  SELECT SINGLE * FROM /adesso/mte_dtab.
*  IF sy-subrc = 0.
    p_beginn = /adesso/mte_dtab-datab.
*  ELSE.


* Ermittlung der Ext-ZP-Bezeichnung wird in der Quelle und im Ziel
* zum Sy-Datum prozessiert - BegAbrPe ist nicht mehr nötig

** Beginn der Abrechnungsperiode
*  CALL FUNCTION 'ISU_BILLING_DATES_FOR_INSTLN'
*    EXPORTING
*      x_anlage               = oldkey_pos
**       X_DPC_MR               =
*   IMPORTING
**       Y_BEGABRPE             =
**       Y_BEGNACH              =
*     y_default_date          = p_beginn
*   EXCEPTIONS
*     no_contract_found       = 1
*     general_fault           = 2
*     parameter_fault         = 3
*     OTHERS                  = 4
*            .
*  IF sy-subrc <> 0.
*    IF sy-subrc EQ 1 AND
*       p_beginn IS INITIAL.
*      SELECT SINGLE * FROM eanlh WHERE anlage = oldkey_pos
*                                   AND bis    = '99991231'.
*      IF sy-subrc EQ 0.
*        MOVE eanlh-ab TO p_beginn.
*      ELSE.
*        meldung-meldung =
*          'Es ist kein Anlagen-Beginndatum zu ermitteln'.
*        APPEND meldung.
*        RAISE wrong_data.
*      ENDIF.
*
*    ELSE.
*      meldung-meldung =
*        'Es ist kein Anlagen-Beginndatum zu ermitteln'.
*      APPEND meldung.
*      RAISE wrong_data.
*    ENDIF.
*  ENDIF.

* Ermittlung des internen Zaehlpunktes:
  SELECT SINGLE * FROM euiinstln
   WHERE anlage = oldkey_pos.

*Ermittlung des externen Zaehlpunktes.
  CLEAR euitrans.
  SELECT SINGLE * FROM euitrans
    WHERE int_ui = euiinstln-int_ui
*    AND dateto   GE p_beginn
*    AND datefrom LE p_beginn.
    AND dateto   GE sy-datum
    AND datefrom LE sy-datum.

* Aufbau der Services wurde zum MIG-4 komplett neu definiert

* Services SKOR (Zeitscheiben der Bilanzkoordinatore)
  CLEAR: it_eservice.
  SELECT * FROM eservice INTO TABLE it_eservice
    WHERE int_ui = euiinstln-int_ui
    AND service = 'SKOR'
    AND loevm NE 'X'.
  IF sy-subrc NE 0.
    meldung-meldung = 'Es konnte kein Biko ermittelt werden'.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.

* Fuellen der Autostruktur für den Bilanzkoordinator
  LOOP AT it_eservice INTO wa_eservice.
    CLEAR ipos_podsrv.
    ipos_podsrv-ext_ui = euitrans-ext_ui.
    ipos_podsrv-service = 'BIKO'.
    ipos_podsrv-serviceid = 'BIKO'.
    ipos_podsrv-service_start = wa_eservice-service_start.
    ipos_podsrv-service_end = wa_eservice-service_end.
    APPEND ipos_podsrv.
  ENDLOOP.

* Service SNEX (Zeitscheiben der Netzbetreiber)
  CLEAR: it_eservice.
  SELECT * FROM eservice INTO TABLE it_eservice
    WHERE int_ui = euiinstln-int_ui
    AND service = 'SNEX'
    AND loevm NE 'X'.
  IF sy-subrc NE 0.
    meldung-meldung = 'Es konnte kein Netzbetreiber ermittelt werden'.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.

* Fuellen der Autostrukturen für sonstige Serviceprovider

  LOOP AT it_eservice INTO wa_eservice.
*   Netzbetreiber
    CLEAR ipos_podsrv.
    ipos_podsrv-ext_ui = euitrans-ext_ui.
    ipos_podsrv-service = 'VNB'.
    ipos_podsrv-serviceid = 'VNB'.
    ipos_podsrv-service_start = wa_eservice-service_start.
    ipos_podsrv-service_end = wa_eservice-service_end.
    APPEND ipos_podsrv.

*   Messstellenbetreiber (Service kommt im Quellsystem nicht vor)
    ipos_podsrv-service = 'MSB'.
    ipos_podsrv-serviceid = 'MSB'.
    APPEND ipos_podsrv.

*   Messdienstleister (Service kommt im Quellsystem nicht vor)
    ipos_podsrv-service = 'MDL'.
    ipos_podsrv-serviceid = 'MDL'.
    APPEND ipos_podsrv.

  ENDLOOP.

* In der MIG-Import-Datei dürfen Service-Arten nur ein mal
* pro Old-Key vorkommen - sonst werden sie nicht migriert;
* Deswegen müssen die Gruppen an dieser Stelle getrennt
* verarbeitet werden

  SORT ipos_podsrv BY service_start.
  ipos_podsrv_h[] = ipos_podsrv[].

  CLEAR h_index.
  LOOP AT ipos_podsrv_h.

*   Anfang neuer Service-Gruppe
    AT NEW service_start.
      REFRESH ipos_podsrv.
      ADD 1 TO h_index.
      CONCATENATE x_anlage '_' h_index INTO oldkey_pos.
    ENDAT.

*   Aufbau der Arbeitstabelle
    ipos_podsrv = ipos_podsrv_h.
    APPEND ipos_podsrv.

* Speichern der Arbeitstabelle
    AT END OF service_start.

*     >> Wegschreiben des Objektschlüssels in Entlade-KSV
      o_key = oldkey_pos.
      CALL FUNCTION '/ADESSO/MTE_OBJKEY_INSERT_ONE'
        EXPORTING
          i_firma  = firma
          i_object = object
          i_oldkey = o_key
        EXCEPTIONS
          error    = 1
          OTHERS   = 2.
      IF sy-subrc <> 0.
        meldung-meldung =
            'Fehler bei wegschreiben in Entlade-KSV'.
        APPEND meldung.
        RAISE error.
      ENDIF.
*     << Wegschreiben des Objektschlüssels in Entlade-KSV

      ADD 1 TO anz_obj.
*     Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
      IF NOT ums_fuba IS INITIAL.
        CALL FUNCTION ums_fuba
          EXPORTING
            firma       = firma
          TABLES
            meldung     = meldung
            ipos_podsrv = ipos_podsrv
          CHANGING
            oldkey_pos  = oldkey_pos.
      ENDIF.

* Sätze für Datei in interne Tabelle schreiben
      PERFORM fill_ipos_out USING oldkey_pos
                                  firma
                                  object.

      LOOP AT ipos_out INTO wpos_out.
        TRANSFER wpos_out TO ent_file.
      ENDLOOP.
      REFRESH ipos_out.

    ENDAT.
  ENDLOOP.



ENDFUNCTION.
