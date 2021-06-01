FUNCTION /ADESSO/MTE_ENT_NOTE_CON.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(X_HAUS) LIKE  EHAUISU-HAUS
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

  object     = 'NOTE_CON'.
  ent_file   = pfad_dat_ent.
  oldkey_noc = x_haus.

* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.


*>   Initialisierung
  PERFORM init_noc.
  CLEAR: inoc_out, wnoc_out, meldung, ANZ_OBJ.
  REFRESH: inoc_out, meldung.
*<



*> Datenermittlung ---------
  SELECT SINGLE * FROM ehauisu WHERE haus EQ oldkey_noc.
  IF sy-subrc NE 0.
    meldung-meldung =
        'Anschlußobjekt für Hinweise nicht in EHAUISU gefunden'.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.


  SELECT * FROM enote  WHERE objkey EQ ehauisu-haus.

    MOVE-CORRESPONDING enote TO inoc_key.

* inoc_notes
    MOVE-CORRESPONDING enote TO inoc_notes.
    APPEND inoc_notes.
    CLEAR  inoc_notes.

*inoc_text
    SELECT SINGLE * FROM enotet
      WHERE objkey  EQ enote-objkey
        AND objtype EQ enote-objtype
        AND lfdnr   EQ enote-lfdnr.

    IF sy-subrc EQ 0.
      MOVE-CORRESPONDING enotet TO inoc_text.
      APPEND inoc_text.
      CLEAR  inoc_text.
    else.
     MOVE-CORRESPONDING enote TO inoc_text.
     APPEND inoc_text.
     CLEAR  inoc_text.
    ENDIF.

  ENDSELECT.

*inoc_key
  IF sy-subrc EQ 0.
    APPEND inoc_key.
    CLEAR  inoc_key.
  else.
    meldung-meldung = 'keine Hinweise für Objekt in ENOTE gefunden'.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.

*< Datenermittlung ---------


*>> Wegschreiben des Objektschlüssels in Entlade-KSV
  o_key = oldkey_noc.
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
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_ENT_NOTE_CON'
    CALL FUNCTION ums_fuba
         EXPORTING
              firma       = firma
         TABLES
              meldung    = meldung
              inoc_key   = inoc_key
              inoc_notes = inoc_notes
              inoc_text  = inoc_text
         CHANGING
              oldkey_noc = oldkey_noc.
  ENDIF.



* Sätze für Datei in interne Tabelle schreiben
  PERFORM fill_inoc_out USING oldkey_noc
                              firma
                              object.


  LOOP AT inoc_out INTO wnoc_out.
    TRANSFER wnoc_out TO ent_file.
  ENDLOOP.





ENDFUNCTION.
