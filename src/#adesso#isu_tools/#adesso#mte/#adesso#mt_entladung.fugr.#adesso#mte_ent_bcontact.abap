FUNCTION /ADESSO/MTE_ENT_BCONTACT.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(X_BPCONTACT) LIKE  BCONT-BPCONTACT
*"     REFERENCE(PFAD_DAT_ENT) TYPE  EMG_PFAD
*"  EXPORTING
*"     REFERENCE(ANZ_OBJ) TYPE  I
*"     REFERENCE(ANZ_BCONTD) TYPE  I
*"     REFERENCE(ANZ_IOBJECTS) TYPE  I
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
  data: wa_rel          type /adesso/mte_rel.

*  DATA: ibcont LIKE bcont OCCURS 0 WITH HEADER LINE.
  DATA: wa_bcont LIKE bcont.
  DATA: ibcont_obj LIKE bcont_obj OCCURS 0 WITH HEADER LINE.


  object   = 'BCONTACT'.
  ent_file = pfad_dat_ent.
  oldkey_bct = X_BPCONTACT.


* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.

*>   Initialisierung
  CLEAR: ibct_out, wbct_out, ibct_bcontd, ibct_pbcobj, meldung, anz_obj.
  REFRESH: ibct_out,  ibct_bcontd, ibct_pbcobj, meldung.
*<


*> Datenermittlung ---------
    CALL FUNCTION 'DB_BCONT_SINGLE_WITH_OBJECTS'
      EXPORTING
        x_bpcontact       = oldkey_bct
*        X_ACTUAL         =
     IMPORTING
        y_bcont           = wa_bcont
      TABLES
        yt_bconto         = ibcont_obj
     EXCEPTIONS
       not_found         = 1
       OTHERS            = 2
              .
    IF sy-subrc <> 0.
      meldung-meldung =
        'kein Kundenkontakt aus FUBA: DB_BCONT_SINGLE_WITH_OBJECTS'.
      APPEND meldung.
      RAISE wrong_data.
    ENDIF.


* ibct_bcontd
    MOVE-CORRESPONDING wa_bcont TO ibct_bcontd.
    APPEND ibct_bcontd.
    CLEAR ibct_bcontd.



* ibct_pbcobj
    LOOP AT ibcont_obj.
      MOVE-CORRESPONDING ibcont_obj TO ibct_pbcobj.
      APPEND ibct_pbcobj.
      CLEAR ibct_pbcobj.
    ENDLOOP.


*  LOOP AT ibcont_obj WHERE objtype = 'ISUACCOUNT'.
**     Andere Referenzen werden im EGUT-Projekt ignoriert ??????
**     Nur die Referenz mitnehmen, wenn das Vertragskonto relevant ist
*    CLEAR wa_rel.
*    SELECT SINGLE * FROM /adesso/mte_rel INTO wa_rel
*      WHERE firma = 'EGUT'
*      AND object = 'ACCOUNT'
*      AND obj_key = ibcont_obj-objkey+0(12).
*    IF sy-subrc = 0.
*      MOVE-CORRESPONDING ibcont_obj TO ibct_pbcobj.
*      APPEND ibct_pbcobj.
*      CLEAR ibct_pbcobj.
*    ELSE.
*      CONTINUE.
*    ENDIF.
*  ENDLOOP.

*< Datenermittlung ---------


*>> Wegschreiben des Objektschlüssels in Entlade-KSV
  o_key = oldkey_bct.
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
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_ENT_BCONTACT'
      CALL FUNCTION ums_fuba
         EXPORTING
              firma       = firma
           TABLES
                meldung     = meldung
                ibct_bcontd = ibct_bcontd
                ibct_pbcobj = ibct_pbcobj
           CHANGING
                oldkey_bct  = oldkey_bct.
    ENDIF.


* Sätze für Datei in interne Tabelle schreiben
    PERFORM fill_bct_out USING oldkey_bct
                               firma
                               object
                               anz_bcontd
                               anz_iobjects.


    LOOP AT ibct_out INTO wbct_out.
      TRANSFER wbct_out TO ent_file.
    ENDLOOP.


ENDFUNCTION.
