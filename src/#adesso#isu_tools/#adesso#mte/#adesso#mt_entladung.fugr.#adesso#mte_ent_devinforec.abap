FUNCTION /ADESSO/MTE_ENT_DEVINFOREC.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(X_EQUNR) LIKE  EGERR-EQUNR
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

  object     = 'DEVINFOREC'.
  ent_file   = pfad_dat_ent.
  oldkey_dir = x_equnr.

* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.


*> Initialisierung
  PERFORM init_dir.
  CLEAR: idir_out, wdir_out, meldung, anz_obj.
  REFRESH: idir_out, meldung.

* --> Nuss 08.09.2015
* Es kann Geräteinfosätze geben, die nach der letzten Rechnung eingebaut wurden
* Deshalb alle mit LOgiknummer lesen und dann den jüngsten Eintrag aus der EGERR nehmen
  SELECT * FROM egerr INTO TABLE iegerr
      WHERE equnr = oldkey_dir
       AND logiknr NE space.

  IF sy-subrc NE 0.
    meldung-meldung = 'Equipmentnummer nicht in EGERR gefunden'.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.

  SORT iegerr BY bis DESCENDING.
  READ TABLE iegerr INDEX 1.
* <-- NUss 08.09.2015



*> Datenermittlung
  SELECT * FROM egerr WHERE equnr = oldkey_dir
*                        AND bis   = '99991231'.   "Nuss 08.09.2015
                         AND bis   = iegerr-bis.   "Nuss 08.09.2015



* idir_int
    MOVE-CORRESPONDING egerr   TO idir_int.
*    idir_int-keydate = sy-datum.
    idir_int-keydate = egerr-ab.
    APPEND idir_int.
    CLEAR idir_int.

*  idir_dev
*  Mussfelder sind: AB, BIS, GERAET, MATNR

    MOVE-CORRESPONDING egerr TO idir_dev.

* idir_dev_flag.
*  Mussfelder sind: AB, BIS, GERAET, MATNR
    idir_dev_flag-ab     = egerr-ab.
    idir_dev_flag-bis    = egerr-bis.
    idir_dev_flag-geraet = egerr-geraet.
    idir_dev_flag-matnr  = egerr-matnr.

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
             WHERE equnr = egerr-equnr
*             AND   bis   = '99991231'.   "Nuss 08.09.2015
             AND bis GE egerr-bis.        "Nuss 08.09.2015

** idir_reg
      MOVE-CORRESPONDING etdz TO idir_reg.

      idir_reg-matnr  = egerr-matnr.
      idir_reg-geraet = egerr-geraet.
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
      idir_reg_flag-matnr = egerr-matnr.
      idir_reg_flag-geraet = egerr-geraet.

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

    ADD 1 TO anz_obj.

  ENDSELECT.

  IF sy-subrc NE 0.
    meldung-meldung = 'Equipmentnummer nicht in EGERR gefunden'.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.

*< Datenermittlung

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

* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
  IF NOT ums_fuba IS INITIAL.
    CALL FUNCTION ums_fuba
      EXPORTING
        firma         = firma
      TABLES
        meldung       = meldung
        idir_int      = idir_int
        idir_dev      = idir_dev
        idir_dev_flag = idir_dev_flag
        idir_reg      = idir_reg
        idir_reg_flag = idir_reg_flag
      CHANGING
        oldkey_dir    = oldkey_dir.
  ENDIF.

* Sätze für Datei in interne Tabelle schreiben
  PERFORM fill_idir_out USING oldkey_dir
                              firma
                              object.

* Import-Datei fortschreiben
  LOOP AT idir_out INTO wdir_out.
    TRANSFER wdir_out TO ent_file.
  ENDLOOP.






ENDFUNCTION.
