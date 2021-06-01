FUNCTION /adesso/mte_ent_adrstrtisu.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(X_STRT_CODE) TYPE  ADRSTRTMRU-STRT_CODE
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
TABLES: adrstrtisu, adrstrtmru, adrstrtkon, adrstrtccs.

  DATA  object          TYPE  emg_object.
  DATA  ent_file        TYPE  emg_pfad.
  DATA: ums_fuba        TYPE  funcname.
  DATA: o_key           TYPE  emg_oldkey.

  object     = 'ADRSTRTISU'.
  ent_file   = pfad_dat_ent.
  oldkey_rag = x_strt_code.

* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.

*>   Initialisierung
  CLEAR: irag_out, wrag_out, meldung, anz_obj, iadr_co_mru, iadr_co_con, iadr_co_ccs, iadr_co_st,
         iadr_co_isu.
  REFRESH: irag_out, meldung, iadr_co_mru, iadr_co_con, iadr_co_ccs, iadr_co_st, iadr_co_isu.
*<
*  hier die meisten Daten vorhanden, Fehlermeldung raus
*> Datenermittlung ---------
* SELECT single * FROM ADRSTrtmru
*         WHERE strt_code EQ oldkey_rag.
*  IF sy-subrc NE 0.
*    meldung-meldung = 'Strassencode nicht in ADRSTrtmru gefunden'.
*    APPEND meldung.
*    RAISE wrong_data.
*  ENDIF.

**iadr_co_st

   SELECT * FROM adrstreet  WHERE country    = 'DE' AND
                                  strt_code  = oldkey_rag.
  IF sy-subrc = 0.
    MOVE-CORRESPONDING adrstreet TO iadr_co_st.

     APPEND iadr_co_st.
     ENDIF.
   ENDSELECT.
   CLEAR  iadr_co_st.


** iadr_co_isu
*  SELECT SINGLE * FROM  ADRSTRTISU  WHERE strt_code  = oldkey_rag. " 060508
  SELECT * FROM  adrstrtisu  WHERE strt_code  = oldkey_rag.         " 060508
   IF sy-subrc EQ 0.
    MOVE-CORRESPONDING adrstrtisu TO iadr_co_isu.

  APPEND iadr_co_isu.
  ENDIF.
  ENDSELECT.

  CLEAR  iadr_co_isu.

*iadr_co_MRU
  SELECT * FROM adrstrtmru
          WHERE country = 'DE' AND
              strt_code = oldkey_rag.
  IF sy-subrc EQ 0.
    MOVE-CORRESPONDING adrstrtmru TO iadr_co_mru.
    APPEND iadr_co_mru.
  ENDIF.
  ENDSELECT.
  CLEAR  iadr_co_mru.

*iadr_co_kon
  SELECT  * FROM  adrstrtkon  WHERE strt_code  = oldkey_rag. " 060508
  IF sy-subrc EQ 0.
    MOVE-CORRESPONDING adrstrtkon TO iadr_co_con.

  APPEND iadr_co_con.
  ENDIF.
  ENDSELECT.
  CLEAR  iadr_co_con.

*iadr_co_ccs
  SELECT SINGLE * FROM  adrstrtccs  WHERE strt_code  = oldkey_rag. " 060508
   SELECT * FROM  adrstrtccs  WHERE strt_code  = oldkey_rag. " 060508
   IF sy-subrc EQ 0.
    MOVE-CORRESPONDING adrstrtccs TO iadr_co_ccs.

  APPEND iadr_co_ccs.
  ENDIF.
   ENDSELECT.
  CLEAR  iadr_co_ccs.
*< Datenermittlung ---------


*>> Wegschreiben des Objektschlüssels in Entlade-KSV
  o_key = oldkey_rag.
*  CALL FUNCTION '/ADESSO/MTE_OBJKEY_INSERT_ONE'
*       EXPORTING
*            i_firma  = firma
*            i_object = object
*            i_oldkey = o_key
*       EXCEPTIONS
*            error    = 1
*            OTHERS   = 2.
*  IF sy-subrc <> 0.
*    meldung-meldung =
*        'Fehler bei wegschreiben in Entlade-KSV'.
*    APPEND meldung.
*    RAISE error.
*  ENDIF.
**<< Wegschreiben des Objektschlüssels in Entlade-KSV

    ADD 1 TO anz_obj.


* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
  IF NOT ums_fuba IS INITIAL.
    CALL FUNCTION ums_fuba
         EXPORTING
              firma       = firma
         TABLES
              meldung     = meldung
              iadr_co_st = iadr_co_st
              iadr_co_isu = iadr_co_isu
              iadr_co_mru = iadr_co_mru
              iadr_co_con = iadr_co_con
              iadr_co_ccs = iadr_co_ccs
         CHANGING
              oldkey_rag  = oldkey_rag.
  ENDIF.

  DESCRIBE TABLE meldung LINES sy-tfill.
  IF sy-tfill > 0.
    RAISE wrong_data.
  ENDIF.



* Sätze für Datei in interne Tabelle schreiben
  PERFORM fill_irag_out USING oldkey_rag
                              firma
                              object.

  LOOP AT irag_out INTO wrag_out.
    TRANSFER wrag_out TO ent_file.
  ENDLOOP.


ENDFUNCTION.
