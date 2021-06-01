FUNCTION /ADESSO/MTE_ENT_DLC_NOTE.
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
*  DATA: ibcont LIKE bcont OCCURS 0 WITH HEADER LINE.
  DATA: o_key           TYPE  emg_oldkey.


* für Text aus FUBA 'READ_TEXT'
  DATA: BEGIN OF itab_txt OCCURS 0.
          INCLUDE STRUCTURE tline.
  DATA: END OF itab_txt.


  object   = 'DLC_NOTE'.
  ent_file = pfad_dat_ent.
  oldkey_dno = x_devloc.



* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.





*>   Initialisierung
  CLEAR: idno_out, wdno_out, idno_notkey, idno_notlin, meldung, anz_obj.
  REFRESH: idno_out, idno_notkey, idno_notlin, meldung.
*<



*> Datenermittlung ---------


* idno_notkey
  SELECT SINGLE * FROM stxh
     WHERE tdobject EQ 'IFLOT'
       AND tdid     EQ 'LTXT'
       AND tdname   EQ oldkey_dno
       AND tdspras  EQ sy-langu.

  IF sy-subrc EQ 0.
    MOVE stxh-tdid        TO idno_notkey-tdid.
    MOVE stxh-tdobject    TO idno_notkey-tdobject.
    MOVE stxh-tdspras     TO idno_notkey-tdspras.
    MOVE stxh-tdname      TO idno_notkey-tdname.
    APPEND idno_notkey.
    CLEAR  idno_notkey.
  ELSE.
    EXIT.
  ENDIF.


* zugehörigen Text ermitteln
* idno_notlin
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
      MOVE-CORRESPONDING itab_txt TO idno_notlin.
      APPEND idno_notlin.
      CLEAR idno_notlin.
    ENDLOOP.
  ENDIF.

*< Datenermittlung ---------


*>> Wegschreiben des Objektschlüssels in Entlade-KSV
  o_key = oldkey_dno.
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
        idno_notkey = idno_notkey
        idno_notlin = idno_notlin
      CHANGING
        oldkey_dno  = oldkey_dno.
  ENDIF.


* Sätze für Datei in interne Tabelle schreiben
  PERFORM fill_idno_out USING oldkey_dno
                              firma
                              object.



  LOOP AT idno_out INTO wdno_out.
    TRANSFER wdno_out TO ent_file.
  ENDLOOP.





ENDFUNCTION.
