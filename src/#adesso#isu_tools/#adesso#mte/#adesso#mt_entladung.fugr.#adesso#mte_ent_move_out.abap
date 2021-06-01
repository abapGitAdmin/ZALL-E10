FUNCTION /ADESSO/MTE_ENT_MOVE_OUT.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(X_VERTRAG) TYPE  EAUSV-VERTRAG
*"     REFERENCE(PFAD_DAT_ENT) TYPE  EMG_PFAD
*"  EXPORTING
*"     REFERENCE(ANZ_OBJ) TYPE  I
*"     REFERENCE(ANZ_EAUSD) TYPE  I
*"     REFERENCE(ANZ_EAUSVD) TYPE  I
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
  DATA: p_beginn        LIKE  sy-datum.
  DATA: o_key           TYPE  emg_oldkey.

  object     = 'MOVE_OUT'.
  ent_file   = pfad_dat_ent.
  oldkey_moo = x_vertrag.
*
*  oldkey_moh = '12'.
*
* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.


*>   Initialisierung
  CLEAR: imoo_out, wmoo_out, imoo_eaus, imoo_eausv, meldung, anz_obj.
  REFRESH: imoo_out, imoo_eaus, imoo_eausv, meldung.
**<


*> Datenermittlung ---------
  CLEAR: eaus, eausv.
  SELECT SINGLE * FROM eausv WHERE vertrag = oldkey_moo
       AND storausz NE 'X'.

  SELECT SINGLE * FROM eaus WHERE auszbeleg = eausv-auszbeleg.


*  CLEAR eaus.
*  SELECT SINGLE * FROM eaus WHERE auszbeleg = oldkey_moo.
*  IF sy-subrc NE 0.
*    meldung-meldung =
*      'Der Auszugsbeleg ist in EAUS nicht vorhanden'.
*    APPEND meldung.
*    RAISE wrong_data.
*  ENDIF.
*
*  SELECT SINGLE * FROM eausv WHERE auszbeleg = oldkey_moo.

* IMOO_EAUS.
  imoo_eaus-actualmodate = eaus-departuredate.
  imoo_eaus-moveoutdate  = eausv-auszdat.
  imoo_eaus-womovein = eausv-ohneeinz.
  APPEND imoo_eaus.


* IMOO_EAUSV
  imoo_eausv-contract = eausv-vertrag.
  imoo_eausv-dunn_block = eausv-mansp.
  imoo_eausv-dunn_proc_mo = eausv-mahnvumz.
  imoo_eausv-end_bb = eausv-absstopkz.
  imoo_eausv-installation = eausv-anlage.
  imoo_eausv-no_mr_doc = eausv-keinablbel.
  APPEND imoo_eausv.
*< Datenermittlung ---------

*>> Wegschreiben des Objektschlüssels in Entlade-KSV
  o_key = oldkey_moo.
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
*  IF NOT ums_fuba IS INITIAL.
*         CALL FUNCTION '/EADESSO/MTU_SAMPLE_ENT_MOVE_OUT'
*    CALL FUNCTION ums_fuba
*      EXPORTING
*        firma      = firma
*      TABLES
*        meldung    = meldung
*        auszbeleg  = imoo_auszbeleg
*      CHANGING
*        oldkey_moh = oldkey_moh.
*  ENDIF.

* Sätze für Datei in interne Tabelle schreiben
  PERFORM fill_moo_out USING oldkey_moo
                             firma
                             object
                             anz_eausd
                             anz_eausvd.
*
*
  LOOP AT imoo_out INTO wmoo_out.
    TRANSFER wmoo_out TO ent_file.
  ENDLOOP.





ENDFUNCTION.
