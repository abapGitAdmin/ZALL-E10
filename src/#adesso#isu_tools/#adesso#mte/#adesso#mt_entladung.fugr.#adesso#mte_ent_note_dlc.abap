FUNCTION /ADESSO/MTE_ENT_NOTE_DLC.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(X_DEVLOC) LIKE  EGPL-DEVLOC
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
  data: o_key           TYPE  EMG_OLDKEY.

  object     = 'NOTE_DLC'.
  ent_file   = pfad_dat_ent.
  oldkey_nod = X_DEVLOC.

* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.


*>   Initialisierung
  PERFORM init_nod.
  CLEAR: inod_out, wnod_out, meldung, ANZ_OBJ.
  REFRESH: inod_out, meldung.
*<



*> Datenermittlung ---------

  SELECT * FROM enote  WHERE objkey EQ oldkey_nod.

    MOVE-CORRESPONDING enote TO inod_key.

* inod_notes
    MOVE-CORRESPONDING enote TO inod_notes.
    APPEND inod_notes.
    CLEAR  inod_notes.

*inod_text
    SELECT SINGLE * FROM enotet
      WHERE objkey  EQ enote-objkey
        AND objtype EQ enote-objtype
        AND lfdnr   EQ enote-lfdnr.

    IF sy-subrc EQ 0.
      MOVE-CORRESPONDING enotet TO inod_text.
      APPEND inod_text.
      CLEAR  inod_text.
    else.
     MOVE-CORRESPONDING enote TO inod_text.
     APPEND inod_text.
     CLEAR  inod_text.
    ENDIF.

  ENDSELECT.

*inod_key
  IF sy-subrc EQ 0.
    APPEND inod_key.
    CLEAR  inod_key.
  else.
    meldung-meldung = 'keine Hinweise für Objekt in ENOTE gefunden'.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.

*< Datenermittlung ---------


*>> Wegschreiben des Objektschlüssels in Entlade-KSV
  o_key = oldkey_nod.
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



  add 1 to anz_obj.

* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
  IF NOT ums_fuba IS INITIAL.
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_ENT_NOTE_DLC'
    CALL FUNCTION ums_fuba
         EXPORTING
              firma       = firma
         TABLES
              meldung    = meldung
              inod_key   = inod_key
              inod_notes = inod_notes
              inod_text  = inod_text
         CHANGING
              oldkey_nod = oldkey_nod.
  ENDIF.



* Sätze für Datei in interne Tabelle schreiben
  PERFORM fill_inod_out USING oldkey_nod
                              firma
                              object.


  LOOP AT inod_out INTO wnod_out.
    TRANSFER wnod_out TO ent_file.
  ENDLOOP.






ENDFUNCTION.
