FUNCTION /ADESSO/MTE_ENT_DISC_RCENT.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(X_EDISCDOC) LIKE  EDISCDOC STRUCTURE  EDISCDOC
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
  DATA: x_meldung(132) TYPE c.

  object   = 'DISC_RCENT'.
  ent_file = pfad_dat_ent.
  oldkey_dcm = x_ediscdoc-discno.



* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.


*>   Initialisierung
  CLEAR: idcm_out, wdcm_out, meldung, anz_obj,
         idcm_header, idcm_anlage, idcm_device, x_meldung.
  REFRESH: idcm_out, meldung,
           idcm_header, idcm_anlage, idcm_device.
*<


*> Datenermittlung ---------

* idcm_HEADER
* prüfen, ob es eine Wiederinbetriebnahmeerfassung gibt:
  CLEAR ediscact.

  SELECT SINGLE * FROM ediscact
   WHERE  discno = oldkey_dcm
   AND discacttyp = '04' " nur die Wiederinbetriebnahmeerfassung
   AND neworder = ' '    " ohne Erzeugung eines neuen (nur aktuelle)
   AND disccanceld = ' '. " Keine Stornos der Sperraktion

  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

*INFOmeldung:
  CONCATENATE 'INFO RCENT: Sperrbel.'
              ediscact-discno
              ediscact-discacttyp
              '(Wiederinbetriebnahmeerf.) wurde entladen!'
    INTO x_meldung SEPARATED BY space.
  WRITE:/ x_meldung.


  MOVE-CORRESPONDING x_ediscdoc TO idcm_header.
  MOVE ediscact-actdate TO idcm_header-ab.
  MOVE ediscact-acttime TO idcm_header-ab_time.
  CASE x_ediscdoc-refobjtype.
    WHEN 'ISUACCOUNT'.
      MOVE x_ediscdoc-refobjkey(12) TO idcm_header-vkonto.

    WHEN 'DEVICE'.
      MOVE x_ediscdoc-refobjkey TO idcm_header-equnr.

    WHEN 'INSTLN'.
      MOVE x_ediscdoc-refobjkey TO idcm_header-anlage.

    WHEN OTHERS.

  ENDCASE.

  APPEND idcm_header.
  CLEAR idcm_header.

*Sperrbeleg: Sperrgegenstand lesen.
  CLEAR: iediscobj, iediscobj[].
  SELECT * INTO TABLE iediscobj FROM ediscobj
   WHERE discno = oldkey_dcm.

  SORT iediscobj.

  LOOP AT iediscobj.

    CLEAR ediscpos.
*
    SELECT SINGLE * FROM ediscpos
     WHERE discno = oldkey_dcm
     AND discact = ediscact-discact
     AND discobj = iediscobj-discobj.

    IF sy-subrc EQ 0.

*idcm_ANLAGE:
      IF iediscobj-discobjtyp = '03'. "Anlage
*
        MOVE ediscpos-actdate TO idcm_anlage-ab.
        MOVE ediscpos-acttime TO idcm_anlage-ab_time.
        MOVE iediscobj-anlage TO idcm_anlage-anlage.
        MOVE ediscpos-disctype TO idcm_anlage-disctype.
        APPEND idcm_anlage.
        CLEAR idcm_anlage.
      ENDIF.

*idcm_DEVICE:
      IF iediscobj-discobjtyp = '01'. "Geraet
        CLEAR egerh.
*
        SELECT SINGLE * FROM egerh
         WHERE ab LE ediscpos-actdate
         AND   bis GE ediscpos-actdate
         AND logiknr = iediscobj-logiknr.
*
        IF sy-subrc EQ 0.
          MOVE ediscpos-actdate TO idcm_device-ab.
          MOVE ediscpos-acttime TO idcm_device-ab_time.
          MOVE ediscpos-disctype TO idcm_device-disctype.
          MOVE egerh-equnr TO idcm_device-equnr.
          APPEND idcm_device.
          CLEAR idcm_device.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDLOOP.

**< Datenermittlung ---------
*
*
**>> Wegschreiben des Objektschlüssels in Entlade-KSV
  o_key = oldkey_dcm.
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
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_ENT_DISC_RCE'
    CALL FUNCTION ums_fuba
         EXPORTING
              firma       = firma
         TABLES
              meldung     = meldung
              idcm_header = idcm_header
              idcm_anlage = idcm_anlage
              idcm_device = idcm_device
         CHANGING
              oldkey_dcm  = oldkey_dcm.
  ENDIF.



* Sätze für Datei in interne Tabelle schreiben
  PERFORM fill_idcm_out USING oldkey_dcm
                              firma
                              object.



  LOOP AT idcm_out INTO wdcm_out.
    TRANSFER wdcm_out TO ent_file.
  ENDLOOP.




ENDFUNCTION.
