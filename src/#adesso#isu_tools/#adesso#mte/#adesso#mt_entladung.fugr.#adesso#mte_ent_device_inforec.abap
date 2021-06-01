FUNCTION /ADESSO/MTE_ENT_DEVICE_INFOREC.
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

**  DATA: iegerh LIKE egerh OCCURS 0 WITH HEADER LINE.
*  DATA: datab_h LIKE sy-datum,
*        datbi_h LIKE sy-datum.
*
*  DATA: datinb LIKE sy-datum.

  DATA: wa_egerr TYPE egerr.


  object   = 'DEVINFOREC'.
  ent_file = pfad_dat_ent.
  oldkey_dir = x_equnr.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = oldkey_dir
    IMPORTING
      output = oldkey_dir.

* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.

*>   Initialisierung
  PERFORM init_dir.
  CLEAR: idir_out, wdir_out, meldung, anz_obj.
  REFRESH: idir_out, meldung.
*<

*> Datenermittlung ---------
** Zunächst die Daten aus der V_EQUI mit der Unendlich-Zeitscheibe ziehen
  SELECT SINGLE * FROM v_equi WHERE equnr = oldkey_dir
                                AND datbi = '99991231'.

  IF sy-subrc = 0.
*   EGERS lesen
    SELECT SINGLE * FROM egers WHERE equnr = v_equi-equnr.
    IF sy-subrc NE 0.
      meldung-meldung =
          'Gerät nicht in EGERS gefunden'.
      APPEND meldung.
      RAISE wrong_data.
    ENDIF.

*   EGERH lesen - Unendlichzeitscheibe.
    SELECT * FROM egerh
                WHERE equnr = v_equi-equnr
                  AND bis = '99991231'.
      EXIT.
    ENDSELECT.
    IF sy-subrc NE 0.
      meldung-meldung =
        'Gerät nicht in EGERH gefunden'.
      APPEND meldung.
      RAISE wrong_data.
    ENDIF.


* EGERR zusammenschreiben
* Felder werden aus EGERH, EGERR und EQUI zusammengeschrieben
    CLEAR wa_egerr.
    MOVE-CORRESPONDING egerh TO wa_egerr.
    MOVE-CORRESPONDING egers TO wa_egerr.
    wa_egerr-matnr = v_equi-matnr.
    wa_egerr-geraet = v_equi-sernr.
    wa_egerr-sparte = v_equi-sparte.

* idir_int.
    MOVE-CORRESPONDING wa_egerr TO idir_int.
    idir_int-keydate = wa_egerr-ab.
    APPEND idir_int.
    CLEAR idir_int.

*  idir_dev
*  Mussfelder sind: AB, BIS, GERAET, MATNR
    MOVE-CORRESPONDING wa_egerr TO idir_dev.

* idir_dev_flag.
*  Mussfelder sind: AB, BIS, GERAET, MATNR
    idir_dev_flag-ab     = wa_egerr-ab.
    idir_dev_flag-bis    = wa_egerr-bis.
    idir_dev_flag-geraet = wa_egerr-geraet.
    idir_dev_flag-matnr  = wa_egerr-matnr.

* Flags setzen
    idir_dev_flag-eagruppe = 'X'.
    idir_dev_flag-komgrp = 'X'.
    idir_dev_flag-messdrck = 'X'.
    idir_dev_flag-ueberver = 'X'.
    idir_dev_flag-primwnr1 = 'X'.
    idir_dev_flag-primwnr2 = 'X'.
    idir_dev_flag-sekwnr1 = 'X'.
    idir_dev_flag-sekwnr2 = 'X'.
    idir_dev_flag-wgruppe = 'X'.
    idir_dev_flag-zspannp = 'X'.
    idir_dev_flag-zspanns = 'X'.
    idir_dev_flag-zstromp = 'X'.
    idir_dev_flag-zstroms = 'X'.
    idir_dev_flag-zwgruppe = 'X'.

    APPEND: idir_dev, idir_dev_flag.
    CLEAR:  idir_dev, idir_dev_flag.

*> Zählwerksdaten
    SELECT * FROM etdz
             WHERE equnr = wa_egerr-equnr
             AND   bis   = '99991231'.

** idir_reg
      MOVE-CORRESPONDING etdz TO idir_reg.

      idir_reg-matnr  = wa_egerr-matnr.
      idir_reg-geraet = wa_egerr-geraet.
**    Maßeinheiten
      idir_reg-meins = etdz-massread.
**    Umändern M3 in m3
      IF idir_reg-meins = 'M3'.
        TRANSLATE idir_reg-meins TO LOWER CASE.
      ENDIF.
      idir_reg-massbillc6 = etdz-massbill.
**    Umändern M3 in m3
      IF idir_reg-massbillc6 = 'M3'.
        TRANSLATE idir_reg-massbillc6 TO LOWER CASE.
      ENDIF.

** idir_reg_flag
      idir_reg_flag-ab  = etdz-ab.
      idir_reg_flag-bis = etdz-bis.
      idir_reg_flag-zwnummer = etdz-zwnummer.
      idir_reg_flag-matnr = wa_egerr-matnr.
      idir_reg_flag-geraet = wa_egerr-geraet.

*** Flags setzen
      idir_reg_flag-kennziff = 'X'.
      idir_reg_flag-kzmessw  = 'X'.
      idir_reg_flag-steuergrp = 'X'.
      idir_reg_flag-zwkenn   = 'X'.
      idir_reg_flag-zwart    = 'X'.
      idir_reg_flag-stanzvor = 'X'.
      idir_reg_flag-stanznac = 'X'.
      idir_reg_flag-anzerg   = 'X'.
      idir_reg_flag-ueberver = 'X'.
      idir_reg_flag-nablesen = 'X'.
      idir_reg_flag-zwfakt   = 'X'.
      idir_reg_flag-pruefkl  = 'X'.
      idir_reg_flag-temp_area = 'X'.
      idir_reg_flag-pr_area_ai = 'X'.
      idir_reg_flag-calor_area = 'X'.
      idir_reg_flag-hoekorr    = 'X'.
      idir_reg_flag-thgber     = 'X'.
      idir_reg_flag-kzahle     = 'X'.
      idir_reg_flag-kzahlt     = 'X'.
      idir_reg_flag-gas_prs_ar = 'X'.
      idir_reg_flag-crgpress   = 'X'.
      idir_reg_flag-meins      = 'X'.
      idir_reg_flag-gewkey     = 'X'.
      idir_reg_flag-massbillc6 = 'X'.
      idir_reg_flag-touperiod  = 'X'.
      idir_reg_flag-bliwirk    = 'X'.
      idir_reg_flag-spartyp    = 'X'.
      idir_reg_flag-zwtyp      = 'X'.
      idir_reg_flag-intsizeid  = 'X'.
      idir_reg_flag-zspanns    = 'X'.
      idir_reg_flag-zstroms    = 'X'.
      idir_reg_flag-zspannp    = 'X'.
      idir_reg_flag-zstromp    = 'X'.

      APPEND: idir_reg, idir_reg_flag.
      CLEAR:  idir_reg, idir_reg_flag.

    ENDSELECT.

  ELSE.

    meldung-meldung =
        'Gerät nicht in V_EQUI gefunden'.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.
*
**< Datenermittlung ---------
*
*>> Wegschreiben des Objektschlüssels in Entlade-KSV
    o_key = oldkey_dir.
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
*
* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
    IF NOT ums_fuba IS INITIAL.
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_ENT_DEVINFOREC'
      CALL FUNCTION ums_fuba
        EXPORTING
          firma       = firma
        TABLES
          meldung        = meldung
          idir_int       = idir_int
          idir_dev       = idir_dev
          idir_dev_flag  = idir_dev_flag
          idir_reg       = idir_reg
          idir_reg_flag  = idir_reg_flag

        CHANGING
          oldkey_dev  = oldkey_dev.
    ENDIF.

* Sätze für Datei in interne Tabelle schreiben
    PERFORM fill_idir_out USING oldkey_dir
                                firma
                                object.

    LOOP AT idir_out INTO wdir_out.
      TRANSFER wdir_out TO ent_file.
    ENDLOOP.





ENDFUNCTION.
