FUNCTION /adesso/mte_ent_devicerel.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(X_DEVICEREL) TYPE  /ADESSO/MT_DEVICEREL
*"     REFERENCE(PFAD_DAT_ENT) TYPE  EMG_PFAD
*"  EXPORTING
*"     REFERENCE(ANZ_OBJ) TYPE  I
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"  EXCEPTIONS
*"      NO_OPEN
*"      NO_CLOSE
*"      WRONG_DATA
*"      NO_DATA
*"      ERROR
*"----------------------------------------------------------------------
 DATA  object          TYPE  emg_object.
  DATA  ent_file        TYPE  emg_pfad.
  DATA: ums_fuba        TYPE  funcname.
  DATA: o_key           TYPE  emg_oldkey.

  DATA: i_ezuz          TYPE ezuz OCCURS 0 WITH HEADER LINE.

  DATA: p_beginn        TYPE sy-datum.
  DATA: old_ts          TYPE char1.

  DATA: wa_htger        TYPE /adesso/mte_htge.
  object     = 'DEVICEREL'.
  ent_file   = pfad_dat_ent.
  oldkey_dvr = x_devicerel.

* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.

*> Initialisierung
  PERFORM init_dvr.
  CLEAR: idvr_out, wdvr_out, meldung, anz_obj.
  REFRESH: idvr_out, meldung.
  CLEAR: egerh, etdz, easts.

*> Datenermittlung

** EZUZ-Satz lesen
  CLEAR i_ezuz.
  REFRESH i_ezuz.
  SELECT * FROM ezuz INTO TABLE i_ezuz
     WHERE logikzw = oldkey_dvr-logikzw
       AND     bis = oldkey_dvr-bis.

  LOOP AT i_ezuz.
* Geräteplatz über EGERH
    SELECT * FROM egerh
      WHERE logiknr = i_ezuz-logiknr2
       AND  bis  GE i_ezuz-bis.
*       AND  ab   LE i_ezuz-ab.
      EXIT.
    ENDSELECT.

* Anlage über EASTS
    SELECT * FROM easts
      WHERE logikzw = i_ezuz-logikzw
      AND bis GE i_ezuz-bis.
*      and ab  le i_ezuz-ab.
* Relevante Anlage ermitteln, falls Gerät in mehreren Anlagen.
      o_key = easts-anlage.
      SELECT SINGLE * FROM /adesso/mte_rel
      WHERE firma = firma
      AND   object = 'INSTLN'
      AND   obj_key = o_key.
      CHECK sy-subrc = 0.
      EXIT.
    ENDSELECT.

* Für Equipment des Logikzw in der ETDZ lesen
    SELECT * FROM etdz
      WHERE logikzw = i_ezuz-logikzw
       AND  bis GE i_ezuz-bis.
      EXIT.
    ENDSELECT.

* Ermittlung des Beginndatums
    CLEAR p_beginn.
*   In der Tabelle /ADESSO/MTE_HTGE nur die
*   Einbau gesamt selektieren
    SELECT * FROM /adesso/mte_htge
       INTO wa_htger
       WHERE equnr = etdz-equnr
         AND action = '01'.
      EXIT.
    ENDSELECT.



    p_beginn = wa_htger-ab_anlage.

***  Wenn EZUZ-BIS kleiner als AB-Datum ist, diese Zuordnung nicht
***  mehr nehmen
    CLEAR old_ts.
    IF i_ezuz-bis LT p_beginn.
      old_ts = 'X'.
      EXIT.
    ENDIF.

*** idvr_int
*** Header
    idvr_int-anlage = easts-anlage.
    idvr_int-devloc = egerh-devloc.
*    idvr_int-keydate = sy-datum.
    idvr_int-keydate  = p_beginn.
    APPEND idvr_int.
    CLEAR idvr_int.

*** idrv_dev
*** Keine Gerätezuordnungen auf Geräteebene vorhanden

*** idrv_reg
*** Gerätezuordnungen auf ZW-Ebene
    IF NOT i_ezuz IS INITIAL.
      MOVE-CORRESPONDING i_ezuz TO idvr_reg.
      idvr_reg-ab    = p_beginn.
      idvr_reg-equnr = etdz-equnr.
      idvr_reg-zwnummer = etdz-zwnummer.
      idvr_reg-attribut = i_ezuz-messdrck.
      CONDENSE idvr_reg-attribut.
      REPLACE '.' WITH ',' INTO idvr_reg-attribut.
**    Nur Ausfüllen, wenn EQUNR2 ungleich EQUNR1 ist.
      IF egerh-equnr NE etdz-equnr.
        idvr_reg-equnr2   = egerh-equnr.
      ELSE.
        CLEAR idvr_reg-equnr2.
      ENDIF.
      APPEND idvr_reg.
      CLEAR idvr_reg.
    ENDIF.

  ENDLOOP.

  IF sy-subrc NE 0.
    meldung-meldung = 'Gerätezuordnung nicht in EZUZ gefunden'.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.

  IF old_ts = 'X'.
    EXIT.
  ENDIF.
*< Datenermittlung

*>> Wegschreiben des Objektschlüssels in Entlade-KSV
  o_key = oldkey_dvr.
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
    CALL FUNCTION ums_fuba
      EXPORTING
        firma      = firma
      TABLES
        meldung    = meldung
        idvr_int   = idvr_int
        idvr_dev   = idvr_dev
        idvr_reg   = idvr_reg
      CHANGING
        oldkey_dvr = oldkey_dvr.
  ENDIF.

* Sätze für Datei in interne Tabelle schreiben
  PERFORM fill_idvr_out USING oldkey_dvr
                              firma
                              object.

* Import-Datei fortschreiben
  LOOP AT idvr_out INTO wdvr_out.
    TRANSFER wdvr_out TO ent_file.
  ENDLOOP.





ENDFUNCTION.
