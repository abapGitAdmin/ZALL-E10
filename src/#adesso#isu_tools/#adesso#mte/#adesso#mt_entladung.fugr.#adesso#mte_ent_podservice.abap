FUNCTION /adesso/mte_ent_podservice.
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
* Hilfstabellen zur Ermittlung der Services:
  DATA: ieuiinstln TYPE TABLE OF euiinstln WITH HEADER LINE.

* Hilfstabelle ESERVICE zum Ermitteln des Beginndatums
  DATA it_eservice TYPE STANDARD TABLE OF eservice.
  DATA: wa_eservice TYPE eservice.
  DATA: h_index(1) type n.


  object   = 'PODSERVICE'.
  ent_file = pfad_dat_ent.
  oldkey_pos = x_anlage.


* Ermitteln des Umschlüsselungs-Fubas
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
*<
  IF ipodsvfilled IS INITIAL.
    ipodsvfilled = 'X'.
    SELECT * FROM /adesso/mte_zpsv INTO TABLE ipodsv
                  WHERE firma = firma.
  ENDIF.
  IF ipodsrfilled IS INITIAL.
    ipodsrfilled = 'X'.
    SELECT * FROM /adesso/mte_zpsr INTO TABLE ipodsr
                  WHERE firma = firma.
  ENDIF.
  IF ipodsifilled IS INITIAL.
    ipodsifilled = 'X'.
    SELECT * FROM /adesso/mte_zpsi INTO TABLE ipodsi
                  WHERE firma = firma.
  ENDIF.
  READ TABLE ipodsi INDEX 1.

*> Datenermittlung ---------
*Es werden nur Anlagen der Serviceart SNET (Netzanlagen) berücksichtigt.
  CLEAR eanl.
  SELECT SINGLE * FROM eanl
  WHERE anlage = oldkey_pos.
*Prüfung auf Netzanlage:
  READ TABLE ipodsv WITH KEY service = eanl-service.
  IF sy-subrc <> 0.
* meldung-meldung =
* 'Anlage hat nicht die Serviceart SNET'.
*        APPEND meldung.
    RAISE wrong_data.
*  exit.
  ENDIF.


** AB-Datum aus Tabelle /ADESSO/MTE_DTAB
  SELECT SINGLE * FROM /adesso/mte_dtab.
  IF sy-subrc = 0.
    p_beginn = /adesso/mte_dtab-datab.
  ELSE.

* ermitteln des Datums, ab wann die Anlage aufgebaut werden soll.
* Es wird das Beginn-Datum der Abrechnungsperiode genommen. Wenn die
* Anlage noch nie abgerechnet wurde, wird die Anlage mit dem
* Einzugsdatum des zugeordneteten Vertrages migriert.



    CALL FUNCTION 'ISU_BILLING_DATES_FOR_INSTLN'
      EXPORTING
        x_anlage          = oldkey_pos
*       X_DPC_MR          =
      IMPORTING
*       Y_BEGABRPE        =
*       Y_BEGNACH         =
        y_default_date    = p_beginn
      EXCEPTIONS
        no_contract_found = 1
        general_fault     = 2
        parameter_fault   = 3
        OTHERS            = 4.
    IF sy-subrc <> 0.
      IF sy-subrc EQ 1 AND
         p_beginn IS INITIAL.
        SELECT SINGLE * FROM eanlh WHERE anlage = oldkey_pos
                                     AND bis    = '99991231'.
        IF sy-subrc EQ 0.
          MOVE eanlh-ab TO p_beginn.
        ELSE.
          meldung-meldung =
            'Es ist kein Anlagen-Beginndatum zu ermitteln'.
          APPEND meldung.
          RAISE wrong_data.
        ENDIF.

      ELSE.

        meldung-meldung =
          'Es ist kein Anlagen-Beginndatum zu ermitteln'.
        APPEND meldung.
        RAISE wrong_data.
      ENDIF.
    ENDIF.
  ENDIF.
*
*Ermittlung des internen Zaehlpunktes:
  SELECT * FROM euiinstln INTO TABLE ieuiinstln
   WHERE anlage = oldkey_pos.
*Ermittlung des Serviceanbieters:
  SORT ieuiinstln.
  LOOP AT ieuiinstln.
    CLEAR eservice.
    SELECT * FROM eservice FOR ALL ENTRIES IN ipodsr
     WHERE int_ui = ieuiinstln-int_ui
     AND service = ipodsr-service
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
*Hier nur für die Serviceid von Werk !!!!!!!!!!!!!!!!!!!!!
     AND NOT serviceid = ipodsi-serviceid.
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
*Abgrenzung fuer den Serviceanbieter:
      IF eservice-service_end LE p_beginn.
        CLEAR eservice.
        CONTINUE.
      ENDIF.
*Abgrenzung des Beginndatums:
      IF p_beginn GT eservice-service_start.
        eservice-service_start = p_beginn.
      ENDIF.
*Ermittlung des externen Zaehlpunktes.
      CLEAR euitrans.
      SELECT SINGLE * FROM euitrans
        WHERE int_ui = eservice-int_ui
        AND dateto   GE eservice-service_end
        AND datefrom LE eservice-service_start.
*Fuellen der Autostruktur ipos_podsrv:
      MOVE-CORRESPONDING eservice TO ipos_podsrv.
      MOVE euitrans-ext_ui TO ipos_podsrv-ext_ui.
      APPEND ipos_podsrv.
      CLEAR ipos_podsrv.

    ENDSELECT.
    IF sy-subrc <> 0.
      WRITE:/ oldkey_pos,
       'keinen Serviceanbieter in ESERVICE gefunden.'.
    ENDIF.
*

  ENDLOOP.

  READ TABLE ipos_podsrv INDEX 1.
  IF sy-subrc NE 0.
    WRITE:/ oldkey_pos,
      'INFO: keinen Serviceanbieter in ESERVICE gefunden (Zeitraum ?).'.
    EXIT.
  ENDIF.

*< Datenermittlung ---------

*>> Wegschreiben des Objektschlüssels in Entlade-KSV

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
*<< Wegschreiben des Objektschlüssels in Entlade-KSV



  ADD 1 TO anz_obj.

* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
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





ENDFUNCTION.
