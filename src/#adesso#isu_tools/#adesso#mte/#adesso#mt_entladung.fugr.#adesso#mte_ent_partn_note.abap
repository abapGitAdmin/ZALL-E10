FUNCTION /ADESSO/MTE_ENT_PARTN_NOTE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(X_PARTNER) LIKE  BUT000-PARTNER
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

  DATA: istxh LIKE stxh OCCURS 0 WITH HEADER LINE.

* für Text aus FUBA 'READ_TEXT'
  DATA: BEGIN OF itab_txt OCCURS 0.
          INCLUDE STRUCTURE tline.
  DATA: END OF itab_txt.


  object   = 'PARTN_NOTE'.
  ent_file = pfad_dat_ent.



* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.



*>   Initialisierung
  CLEAR: ipno_out, wpno_out, ipno_notkey, ipno_notlin, meldung, anz_obj,
 istxh.
  REFRESH: ipno_out, ipno_notkey, ipno_notlin, meldung, istxh.
*<



*> Datenermittlung ---------


  SELECT * FROM stxh INTO TABLE istxh
     WHERE tdobject EQ 'BUT000'
       AND tdname   EQ x_partner
       AND tdspras  EQ sy-langu.

  LOOP AT istxh
     WHERE tdobject EQ 'BUT000'
       AND tdname   EQ x_partner
       AND tdspras  EQ sy-langu.

    CLEAR: ipno_out, wpno_out, ipno_notkey, ipno_notlin.
    REFRESH: ipno_out, ipno_notkey, ipno_notlin.




* ipno_notkey
    MOVE istxh-tdid        TO ipno_notkey-tdid.
    MOVE istxh-tdobject    TO ipno_notkey-tdobject.
    MOVE istxh-tdspras     TO ipno_notkey-tdspras.
    MOVE istxh-tdname      TO ipno_notkey-tdname.
    APPEND ipno_notkey.
    CLEAR  ipno_notkey.

* zugehörigen Text ermitteln
* ipno_notlin
    REFRESH: itab_txt.

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        client                  = sy-mandt
        id                      = istxh-tdid
        language                = istxh-tdspras
        name                    = istxh-tdname
        object                  = istxh-tdobject
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
        MOVE-CORRESPONDING itab_txt TO ipno_notlin.
        APPEND ipno_notlin.
        CLEAR ipno_notlin.
      ENDLOOP.
    ENDIF.

*< Datenermittlung ---------

    ADD 1 TO anz_obj.


* Altsystemschlüssel aus Partnernummer und ID, da mehrere Notizen mögl.
    CONCATENATE x_partner '_' istxh-tdid INTO oldkey_pno.



*>> Wegschreiben des Objektschlüssels in Entlade-KSV
    o_key = oldkey_pno.
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





* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
    IF NOT ums_fuba IS INITIAL.
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_ENT_PARTN_NO'
      CALL FUNCTION ums_fuba
        EXPORTING
          firma       = firma
        TABLES
          meldung     = meldung
          ipno_notkey = ipno_notkey
          ipno_notlin = ipno_notlin
        CHANGING
          oldkey_pno  = oldkey_pno.
    ENDIF.


* Sätze für Datei in interne Tabelle schreiben
    PERFORM fill_pno_out USING oldkey_pno
                                firma
                                object.



    LOOP AT ipno_out INTO wpno_out.
      TRANSFER wpno_out TO ent_file.
    ENDLOOP.

  ENDLOOP.





ENDFUNCTION.
