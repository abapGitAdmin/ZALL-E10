FUNCTION /ADESSO/MTE_ENT_DEVICE_LAGER.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(X_EQUNR) LIKE  EQUI-EQUNR
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

  DATA: iegerh LIKE egerh OCCURS 0 WITH HEADER LINE.
  DATA: datab_h LIKE sy-datum,
        datbi_h LIKE sy-datum.

  DATA: datinb LIKE sy-datum.



  object   = 'DEVICE'.
  ent_file = pfad_dat_ent.
  oldkey_dev = x_equnr.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
       EXPORTING
            input  = oldkey_dev
       IMPORTING
            output = oldkey_dev.



* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.



*>   Initialisierung
  PERFORM init_dev.
  CLEAR: idev_out, wdev_out, meldung, anz_obj.
  REFRESH: idev_out, meldung.
*<



*> Datenermittlung ---------
  SELECT SINGLE * FROM v_equi WHERE equnr = oldkey_dev
                              AND   datbi = '99991231'.

  IF sy-subrc = 0.
*idev_EQUI
* Es wird später (bei egerh) das größte und kleinste Datum ermittelt
* und daher erst nach dem select appended.
    MOVE v_equi-datab TO datab_h.
    MOVE v_equi-datbi TO datbi_h.
    MOVE-CORRESPONDING v_equi TO idev_equi.

    select single b_lager into idev_equi-lager
           from eqbs
           where equnr = oldkey_dev.

*idev_EGERS
    SELECT SINGLE * FROM egers WHERE equnr = v_equi-equnr.
    IF sy-subrc EQ 0.
      MOVE-CORRESPONDING egers TO idev_egers.
      APPEND idev_egers.
      CLEAR  idev_egers.
    ENDIF.


*idev_EGERH
    SELECT * FROM egerh INTO TABLE iegerh
                WHERE equnr = v_equi-equnr.
    IF sy-subrc EQ 0.
      LOOP AT iegerh.
        MOVE-CORRESPONDING iegerh TO idev_egerh.
        IF iegerh-ab < datab_h.
          datab_h = iegerh-ab.
        ENDIF.
*      IF egerh-bis > datbi_h.
*        datbi_h = egerh-bis.
*      ENDIF.
      ENDLOOP.
      IF sy-subrc EQ 0.
        MOVE datab_h TO idev_egerh-ab.
        MOVE datbi_h TO idev_egerh-bis.
        APPEND idev_egerh.
        CLEAR  idev_egerh.
      ENDIF.
    ENDIF.

*  erstes Inbetriebnahmedatum (in Betrieb ab)
   clear datinb.
   sort iegerh by einbdat descending.
   loop at iegerh.
    move iegerh-ab to datinb.
    exit.
   endloop.

* Klassifizierungsdaten ???
    SELECT SINGLE * FROM kssk WHERE objek = oldkey_dev.
    IF sy-subrc EQ 0.
      SELECT SINGLE * FROM klah WHERE clint = kssk-clint.
      IF sy-subrc EQ 0.
*idev_clhead
        MOVE klah-class TO idev_clhead-class.
        MOVE klah-klart TO idev_clhead-classtype.
        APPEND idev_clhead.
        CLEAR  idev_clhead.

*idev_cldata
        SELECT * FROM ausp WHERE objek = oldkey_dev.
          MOVE-CORRESPONDING ausp TO idev_cldata.
          MOVE ausp-atwrt TO   idev_cldata-value.
          MOVE ausp-atzis TO   idev_cldata-instance.

          CALL FUNCTION 'CONVERSION_EXIT_ATINN_OUTPUT'
               EXPORTING
                    input  = ausp-atinn
               IMPORTING
                    output = idev_cldata-charact.

          APPEND idev_cldata.
          CLEAR  idev_cldata.

        ENDSELECT.

      ENDIF.
    ENDIF.

*  ENDSELECT.

*  IF sy-subrc EQ 0.
    MOVE datab_h TO idev_equi-datab.
    MOVE datbi_h TO idev_equi-datbi.
    MOVE datinb  TO idev_equi-inbdt.
    APPEND idev_equi.
    CLEAR  idev_equi.
  ELSE.
    meldung-meldung =
        'Gerät nicht in V_EQUI gefunden'.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.

*< Datenermittlung ---------


*>> Wegschreiben des Objektschlüssels in Entlade-KSV
  o_key = oldkey_dev.
  CALL FUNCTION '/ADESSO/MTE_OBJKEY_INSERT_ONE'
       EXPORTING
            i_firma  = firma
            i_object = 'DEVICE_LAG' "object
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
    CALL FUNCTION ums_fuba
         EXPORTING
              firma       = firma
         TABLES
              meldung     = meldung
              idev_equi   = idev_equi
              idev_egers  = idev_egers
              idev_egerh  = idev_egerh
              idev_clhead = idev_clhead
              idev_cldata = idev_cldata
         CHANGING
              oldkey_dev  = oldkey_dev.
  ENDIF.


* Sätze für Datei in interne Tabelle schreiben
  PERFORM fill_idev_out USING oldkey_dev
                              firma
                              object.


  LOOP AT idev_out INTO wdev_out.
    TRANSFER wdev_out TO ent_file.
  ENDLOOP.





ENDFUNCTION.
