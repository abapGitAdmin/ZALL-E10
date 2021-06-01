FUNCTION /ADESSO/MTE_ENT_LOADPROF.
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
  DATA: p_beginn LIKE sy-datum.

* Zur Ermittlung der lfd. Nr. der Lastprofilzuordnung
  DATA: h_tabix TYPE sy-tabix.

* Arbeitstabellen:
  DATA: ielpass TYPE TABLE OF elpass WITH HEADER LINE.

  object   = 'LOADPROF'.
  ent_file = pfad_dat_ent.
  oldkey_lop = x_anlage.

* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.

* Initialisierung
  PERFORM init_lop.
  CLEAR: ilop_out, wlop_out, meldung, anz_obj.
  CLEAR ielpass. REFRESH ielpass.
  REFRESH: ilop_out, meldung.
*

*> Datenermittlung ---------

* ermitteln des Datums, ab wann die Anlage aufgebaut werden soll.
* Es wird das Beginn-Datum der Abrechnungsperiode genommen. Wenn die
* Anlage noch nie abgerechnet wurde, wird die Anlage mit dem
* Einzugsdatum des zugeordneteten Vertrages migriert.
  CALL FUNCTION 'ISU_BILLING_DATES_FOR_INSTLN'
    EXPORTING
      x_anlage                = oldkey_lop
*   X_DPC_MR                =
   IMPORTING
*   Y_BEGABRPE              =
*   Y_BEGNACH               =
     y_default_date          = p_beginn
   EXCEPTIONS
     no_contract_found       = 1
     general_fault           = 2
     parameter_fault         = 3
     OTHERS                  = 4
            .
  IF sy-subrc <> 0.
    IF sy-subrc EQ 1 AND
       p_beginn IS INITIAL.
      SELECT SINGLE * FROM eanlh WHERE anlage = oldkey_lop
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

* ilop_ELPASS füllen:
  SELECT * FROM elpass INTO TABLE ielpass
   WHERE objkey = oldkey_lop
   AND  objtype = 'INSTLN'
   AND  bis GT p_beginn.

* Lastprofilzuordnung vorhanden?
  IF ielpass[] IS INITIAL.
    meldung-meldung =
    'log. Lastprofilnr nicht in ELPASS gefunden'.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.

* Zuordnung des Usagefaktors:
  SORT ielpass.

* Hauptverarbeitung - Zuordnungstabelle entladen
  LOOP AT ielpass.

    at first.
*     ilop_KEY aufbauen
      read table ielpass index sy-tabix.
      MOVE-CORRESPONDING ielpass TO ilop_key.

      SELECT SINGLE * FROM eanl
       WHERE anlage = oldkey_lop.
      MOVE eanl-sparte TO ilop_key-sparte.

      APPEND ilop_key.
    endat.

*   Usage-Factor der Zuordnung ermitteln
    CLEAR eufass.
    SELECT * FROM eufass
     WHERE objkey     = ielpass-objkey
     AND   objtype    = ielpass-objtype
     AND   loglprelno = ielpass-loglprelno
     AND   bis        = ielpass-bis.

*     Abgrenzung gegen p_beginn.
      IF p_beginn GT eufass-ab.
        eufass-ab = p_beginn.
      ENDIF.

*     Autostruktur ilop_ELPASS füllen
      MOVE-CORRESPONDING ielpass TO ilop_elpass.
      MOVE-CORRESPONDING eufass TO ilop_elpass.
      ilop_elpass-lprelno = 1.
      APPEND ilop_elpass.
      CLEAR ilop_elpass.

    ENDSELECT.

    IF sy-subrc <> 0.
*     Usage-Factor nicht gefunden
      meldung-meldung =
      'Usage-Factor für log. Lastprofilnr nicht in EUFASS gefunden'.
      APPEND meldung.
      RAISE wrong_data.
    ENDIF.

  ENDLOOP.

* Erhöhung der Nummer der Lastprofilzuordnung bei Gleichheit
* von: Logischer Nummer der Lastprofilzuordnung (loglprelno)
*     AB-Zeitpunkt
*     BIS-Zeitpunkt
*     Lastprofil
* aber unterschiedlichem USEFACTOR:
  SORT ilop_elpass.
  LOOP AT ilop_elpass.
    h_tabix = sy-tabix - 1.
    READ TABLE ilop_elpass INDEX h_tabix COMPARING loglprelno
                                                   ab
                                                   bis
                                                   loadprof.
    IF sy-subrc = 0.
      ADD 1 TO ilop_elpass-lprelno.
      MODIFY ilop_elpass TRANSPORTING lprelno.
    ENDIF.

  ENDLOOP.

*< Datenermittlung ---------


* Wegschreiben des Objektschlüssels in Entlade-KSV
  o_key = oldkey_lop.
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

  ADD 1 TO anz_obj.

* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
  IF NOT ums_fuba IS INITIAL.
    CALL FUNCTION ums_fuba
         EXPORTING
              firma       = firma
         TABLES
              meldung     = meldung
              ilop_key    = ilop_key
              ilop_elpass = ilop_elpass
         CHANGING
              oldkey_lop  = oldkey_lop.
  ENDIF.


* Sätze für Datei in interne Tabelle schreiben
  PERFORM fill_ilop_out USING oldkey_lop
                              firma
                              object.

  LOOP AT ilop_out INTO wlop_out.
    TRANSFER wlop_out TO ent_file.
  ENDLOOP.






ENDFUNCTION.
