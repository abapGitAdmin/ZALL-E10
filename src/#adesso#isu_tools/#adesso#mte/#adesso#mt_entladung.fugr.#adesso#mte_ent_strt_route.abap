FUNCTION /ADESSO/MTE_ENT_STRT_ROUTE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(X_ABLEINH) LIKE  EANLH-ABLEINH
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

  DATA: ielweg  LIKE elweg OCCURS 0 WITH HEADER LINE.
  DATA: logvor  LIKE elweg-vorgaenger.
  DATA: lognach LIKE elweg-nachfolger.

  object   = 'STRT_ROUTE'.
  ent_file = pfad_dat_ent.
  oldkey_srt = x_ableinh.

* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.


*>   Initialisierung
  CLEAR: isrt_out, wsrt_out, meldung, anz_obj, isrt_mru, isrt_equnr.
  REFRESH: isrt_out, meldung, isrt_mru, isrt_equnr.
*<

  CLEAR: ielweg.
  REFRESH: ielweg.


*> Datenermittlung ---------

  SELECT * FROM elweg INTO TABLE ielweg
             WHERE ableinh = oldkey_srt.

  IF sy-subrc EQ 0.
    MOVE oldkey_srt TO isrt_mru-ableinh.
    APPEND isrt_mru.
    CLEAR isrt_mru.
  ELSE.
    meldung-meldung =
        'Ableseeinheit nicht in Tabelle ELWEG gefunden'.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.

* ersten Datensatz bestimmen (Vorgänger = 0)
  logvor = 0.
  lognach = 0.
  LOOP AT ielweg WHERE vorgaenger = logvor.
    MOVE ielweg-nachfolger TO lognach.

    SELECT SINGLE * FROM egerh WHERE logiknr = ielweg-logiknr
                                 AND bis     = '99991231'.
    IF sy-subrc EQ 0.
      MOVE egerh-equnr TO isrt_equnr-equnr.
      APPEND isrt_equnr.
      CLEAR isrt_equnr.
    ENDIF.

  ENDLOOP.

  DO.

    LOOP AT ielweg WHERE logiknr = lognach.
      MOVE ielweg-nachfolger TO lognach.

      SELECT SINGLE * FROM egerh WHERE logiknr = ielweg-logiknr
                                   AND bis     = '99991231'.
      IF sy-subrc EQ 0.
        MOVE egerh-equnr TO isrt_equnr-equnr.
        APPEND isrt_equnr.
        CLEAR isrt_equnr.
      ENDIF.

    ENDLOOP.

    IF lognach EQ 0.
      EXIT.
    ENDIF.

  ENDDO.


*< Datenermittlung ---------


*>> Wegschreiben des Objektschlüssels in Entlade-KSV
  o_key = oldkey_srt.
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
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_ENT_STRT_ROUTE'
    CALL FUNCTION ums_fuba
      EXPORTING
        firma      = firma
      TABLES
        meldung    = meldung
        isrt_mru   = isrt_mru
        isrt_equnr = isrt_equnr
      CHANGING
        oldkey_srt = oldkey_srt.
  ENDIF.

*isrt_mru, isrt_equnr

* Sätze für Datei in interne Tabelle schreiben
  PERFORM fill_isrt_out USING oldkey_srt
                              firma
                              object.



  LOOP AT isrt_out INTO wsrt_out.
    TRANSFER wsrt_out TO ent_file.
  ENDLOOP.








ENDFUNCTION.
