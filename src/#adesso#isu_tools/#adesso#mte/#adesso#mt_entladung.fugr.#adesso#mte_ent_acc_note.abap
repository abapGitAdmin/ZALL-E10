FUNCTION /adesso/mte_ent_acc_note.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(X_VKONT) LIKE  FKKVK-VKONT
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
  DATA: tdname          LIKE stxh-tdname.
  DATA: o_key           TYPE  emg_oldkey.

* für Text aus FUBA 'READ_TEXT'
  DATA: BEGIN OF itab_txt OCCURS 0.
          INCLUDE STRUCTURE tline.
  DATA: END OF itab_txt.


  object   = 'ACC_NOTE'.
  ent_file = pfad_dat_ent.
  oldkey_acn = x_vkont.


  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = oldkey_acn
    IMPORTING
      output = oldkey_acn.



* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.

*>   Initialisierung
  PERFORM init_acn.
  CLEAR: iacn_out, wacn_out, meldung, anz_obj.
  REFRESH: iacn_out, meldung.
*<

*> Datenermittlung ---------

* ermitteln des zugehörigen Geschäftspartners
  SELECT SINGLE * FROM fkkvkp WHERE vkont = oldkey_acn.
  IF sy-subrc NE 0.
    meldung-meldung =
          'keinen zugehörigen Partner in FKKVKP gefunden'.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.

* Schlüssel für die Tabelle STXH zusammenstellen
  CLEAR tdname.
  CONCATENATE oldkey_acn fkkvkp-gpart INTO tdname.

* iacn_notkey
  SELECT SINGLE * FROM stxh
     WHERE tdobject EQ 'FKKVKP'
       AND tdid     EQ 'FKK'
       AND tdname   EQ tdname
       AND tdspras  EQ sy-langu.

  IF sy-subrc EQ 0.
    MOVE stxh-tdid       TO iacn_notkey-tdid.
    MOVE stxh-tdobject   TO iacn_notkey-tdobject.
    MOVE stxh-tdspras    TO iacn_notkey-tdspras.
    MOVE oldkey_acn      TO iacn_notkey-tdname.
    MOVE fkkvkp-gpart    TO iacn_notkey-tdname2.
    APPEND iacn_notkey.
    CLEAR  iacn_notkey.
  ELSE.
    meldung-meldung =
          'keine Notiz-Kopfdaten in STXH gefunden'.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.


* zugehörigen Text ermitteln
* iacn_notlin
  REFRESH: itab_txt.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      client                  = sy-mandt
      id                      = stxh-tdid
      language                = stxh-tdspras
      name                    = tdname
      object                  = stxh-tdobject
    TABLES
      lines                   = itab_txt
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7.

  IF sy-subrc EQ 0.
    LOOP AT itab_txt.
      MOVE-CORRESPONDING itab_txt TO iacn_notlin.
      APPEND iacn_notlin.
      CLEAR iacn_notlin.
    ENDLOOP.
  ENDIF.

*< Datenermittlung ---------


*>> Wegschreiben des Objektschlüssels in Entlade-KSV
  o_key = oldkey_acn.
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
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_ENT_ACC_NOTE'
    CALL FUNCTION ums_fuba
      EXPORTING
        firma       = firma
      TABLES
        meldung     = meldung
        iacn_notkey = iacn_notkey
        iacn_notlin = iacn_notlin
      CHANGING
        oldkey_acn  = oldkey_acn.
  ENDIF.



* Sätze für Datei in interne Tabelle schreiben
  PERFORM fill_iacn_out USING oldkey_acn
                              firma
                              object.


  LOOP AT iacn_out INTO wacn_out.
    TRANSFER wacn_out TO ent_file.
  ENDLOOP.

ENDFUNCTION.
