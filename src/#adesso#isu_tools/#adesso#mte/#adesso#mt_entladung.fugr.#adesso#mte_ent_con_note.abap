FUNCTION /adesso/mte_ent_con_note.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(X_HAUS) LIKE  EVBS-HAUS
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
*  DATA: ibcont LIKE bcont OCCURS 0 WITH HEADER LINE.
  DATA: o_key           TYPE  emg_oldkey.


* für Text aus FUBA 'READ_TEXT'
  DATA: BEGIN OF itab_txt OCCURS 0.
          INCLUDE STRUCTURE tline.
  DATA: END OF itab_txt.


  object   = 'CON_NOTE'.
  ent_file = pfad_dat_ent.
  oldkey_cno = x_haus.



* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.


*>   Initialisierung
  CLEAR: icno_out, wcno_out, icno_notkey, icno_notlin, meldung, anz_obj.
  REFRESH: icno_out, icno_notkey, icno_notlin, meldung.
*<



*> Datenermittlung ---------


* icno_notkey
  SELECT SINGLE * FROM stxh
     WHERE tdobject EQ 'IFLOT'
       AND tdid     EQ 'LTXT'
       AND tdname   EQ oldkey_cno
       AND tdspras  EQ sy-langu.

  IF sy-subrc EQ 0.
    MOVE stxh-tdid        TO icno_notkey-tdid.
    MOVE stxh-tdobject    TO icno_notkey-tdobject.
    MOVE stxh-tdspras     TO icno_notkey-tdspras.
    MOVE stxh-tdname      TO icno_notkey-tdname.
    APPEND icno_notkey.
    CLEAR  icno_notkey.
  ELSE.
    EXIT.
  ENDIF.


* zugehörigen Text ermitteln
* icno_notlin
  REFRESH: itab_txt.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      client                  = sy-mandt
      id                      = stxh-tdid
      language                = stxh-tdspras
      name                    = stxh-tdname
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
      MOVE-CORRESPONDING itab_txt TO icno_notlin.
      APPEND icno_notlin.
      CLEAR icno_notlin.
    ENDLOOP.
  ENDIF.

*< Datenermittlung ---------


*>> Wegschreiben des Objektschlüssels in Entlade-KSV
  o_key = oldkey_cno.
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
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_ENT_CON_NOTE'
    CALL FUNCTION ums_fuba
      EXPORTING
        firma       = firma
      TABLES
        meldung     = meldung
        icno_notkey = icno_notkey
        icno_notlin = icno_notlin
      CHANGING
        oldkey_cno  = oldkey_cno.
  ENDIF.


* Sätze für Datei in interne Tabelle schreiben
  PERFORM fill_icno_out USING oldkey_cno
                              firma
                              object.



  LOOP AT icno_out INTO wcno_out.
    TRANSFER wcno_out TO ent_file.
  ENDLOOP.





ENDFUNCTION.
