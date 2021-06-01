FUNCTION /ADESSO/MTE_ENT_DISC_ENTER.
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
  data: vkont           like  fkkvk-vkont.

  object   = 'DISC_ENTER'.
  ent_file = pfad_dat_ent.
  oldkey_dce = x_ediscdoc-discno.



* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.


*>   Initialisierung
  CLEAR: idce_out, wdce_out, meldung, anz_obj,
         idce_header, idce_anlage, idce_device.
  REFRESH: idce_out, meldung,
           idce_header, idce_anlage, idce_device.
*<


*> Datenermittlung ---------

* idce_HEADER
* prüfen, ob es eine Sperrerfassung gibt:
  CLEAR ediscact.

  SELECT SINGLE * FROM ediscact
   WHERE  discno = oldkey_dce
   AND discacttyp = '02' " nur die Sperrerfassung
  AND neworder = ' '     " ohne Erzeugung eines neuen Sperrauftrages (nur
                                                             " aktuelle)
   AND disccanceld = ' '. " Keine Stornos der Sperraktion

  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

  MOVE-CORRESPONDING x_ediscdoc TO idce_header.
  MOVE ediscact-actdate TO idce_header-ab.
  MOVE ediscact-acttime TO idce_header-ab_time.
  CASE x_ediscdoc-refobjtype.
    WHEN 'ISUACCOUNT'.
      MOVE x_ediscdoc-refobjkey(12) TO idce_header-vkonto.

* prüfen, ob zum Vertragskonto überhaupt ein gültiger
* Vertrag existiert.
     clear vkont.
     move X_EDISCDOC-REFOBJKEY(12) to vkont.
     select single * from ever where vkonto = vkont
                                 and auszdat = '99991231'.
     if sy-subrc ne 0.
      write: / X_EDISCDOC-DISCNO,
               'kein gültiger Vertrag zu VKonto', vkont.

      exit.
     endif.

    WHEN 'DEVICE'.
      MOVE x_ediscdoc-refobjkey TO idce_header-equnr.

    WHEN 'INSTLN'.
      MOVE x_ediscdoc-refobjkey TO idce_header-anlage.

    WHEN OTHERS.

  ENDCASE.

  APPEND idce_header.
  CLEAR idce_header.

*Sperrbeleg: Sperrgegenstand lesen.
  CLEAR: iediscobj, iediscobj[].
  SELECT * INTO TABLE iediscobj FROM ediscobj
   WHERE discno = oldkey_dce.

  SORT iediscobj.

  LOOP AT iediscobj.

    CLEAR ediscpos.
*
    SELECT SINGLE * FROM ediscpos
     WHERE discno = oldkey_dce
     AND discact = ediscact-discact
     AND discobj = iediscobj-discobj.

    IF sy-subrc EQ 0.

*idce_ANLAGE:
      IF iediscobj-discobjtyp = '03'. "Anlage
*
        MOVE ediscpos-actdate TO idce_anlage-ab.
        MOVE ediscpos-acttime TO idce_anlage-ab_time.
        MOVE iediscobj-anlage TO idce_anlage-anlage.
        MOVE ediscpos-disctype TO idce_anlage-disctype.
        APPEND idce_anlage.
        CLEAR idce_anlage.
      ENDIF.

*idce_DEVICE:
      IF iediscobj-discobjtyp = '01'. "Geraet
        CLEAR egerh.
*
        SELECT SINGLE * FROM egerh
         WHERE ab LE ediscpos-actdate
         AND   bis GE ediscpos-actdate
         AND logiknr = iediscobj-logiknr.
*
        IF sy-subrc EQ 0.
          MOVE ediscpos-actdate TO idce_device-ab.
          MOVE ediscpos-acttime TO idce_device-ab_time.
          MOVE ediscpos-disctype TO idce_device-disctype.
          MOVE egerh-equnr TO idce_device-equnr.
          APPEND idce_device.
          CLEAR idce_device.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

**< Datenermittlung ---------
*
*
**>> Wegschreiben des Objektschlüssels in Entlade-KSV
  o_key = oldkey_dce.
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
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_ENT_DISC_ENT'
    CALL FUNCTION ums_fuba
         EXPORTING
              firma       = firma
         TABLES
              meldung     = meldung
              idce_header = idce_header
              idce_anlage = idce_anlage
              idce_device = idce_device
         CHANGING
              oldkey_dce  = oldkey_dce.
  ENDIF.



* Sätze für Datei in interne Tabelle schreiben
  PERFORM fill_idce_out USING oldkey_dce
                              firma
                              object.



  LOOP AT idce_out INTO wdce_out.
    TRANSFER wdce_out TO ent_file.
  ENDLOOP.


ENDFUNCTION.
