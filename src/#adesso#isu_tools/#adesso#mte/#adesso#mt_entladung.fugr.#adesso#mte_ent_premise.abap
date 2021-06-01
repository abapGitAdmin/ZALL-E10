FUNCTION /ADESSO/MTE_ENT_PREMISE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(X_VSTELLE) LIKE  EVBS-VSTELLE
*"     REFERENCE(PFAD_DAT_ENT) TYPE  EMG_PFAD
*"  EXPORTING
*"     REFERENCE(ANZ_OBJ) TYPE  I
*"     REFERENCE(ANZ_EVBSD) TYPE  I
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

  object   = 'PREMISE'.
  ent_file = pfad_dat_ent.
  oldkey_pre = x_vstelle.

* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.


*>   Initialisierung
  PERFORM init_pre.
  CLEAR: ipre_out, wpre_out, meldung, ANZ_OBJ.
  REFRESH: ipre_out, meldung.
*<


*> Datenermittlung ---------
  SELECT SINGLE * FROM evbs WHERE vstelle EQ oldkey_pre.
  IF sy-subrc eq 0.
      MOVE-CORRESPONDING evbs TO ipre_EVBSD.
      APPEND ipre_EVBSD.
      CLEAR  ipre_EVBSD.
    else.
    meldung-meldung =
        'Verbrauchsstelle nicht in EVBS gefunden'.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.

*< Datenermittlung ---------


*>> Wegschreiben des Objektschlüssels in Entlade-KSV
  o_key = oldkey_pre.
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
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_ENT_PREMISE'
          CALL FUNCTION ums_fuba
              EXPORTING
                   firma       = firma
               TABLES
                    meldung     = meldung
                    ipre_EVBSD  = ipre_EVBSD
               CHANGING
                    oldkey_pre  = oldkey_pre.
        ENDIF.



* Sätze für Datei in interne Tabelle schreiben
  PERFORM fill_ipre_out USING oldkey_pre
                              firma
                              object
                              anz_evbsd.



  LOOP AT ipre_out INTO wpre_out.
    TRANSFER wpre_out TO ent_file.
  ENDLOOP.


ENDFUNCTION.
