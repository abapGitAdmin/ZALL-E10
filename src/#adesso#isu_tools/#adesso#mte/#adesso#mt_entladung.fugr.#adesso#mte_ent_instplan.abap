FUNCTION /adesso/mte_ent_instplan.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(X_VKONT) LIKE  FKKVK-VKONT
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
  DATA: wa_rfkn1  LIKE rfkn1.
  DATA: ir_fkkop  LIKE sfkkop OCCURS 0 WITH HEADER LINE.
  DATA: counter(4) TYPE n.
  DATA: o_key           TYPE  emg_oldkey.

  DATA: BEGIN OF i_fkk_instpln_head OCCURS 0.
          INCLUDE STRUCTURE fkk_instpln_head.
  DATA: END OF i_fkk_instpln_head.

  object   = 'INSTPLAN'.
  ent_file = pfad_dat_ent.
  oldkey_ipl = x_vkont.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
       EXPORTING
            input  = oldkey_ipl
       IMPORTING
            output = oldkey_ipl.

* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.

*>   Initialisierung
  PERFORM init_ipl.
  CLEAR: ipl_out, wipl_out, meldung, anz_obj.
  REFRESH: ipl_out, meldung, i_fkk_instpln_head.
*<

*> Datenermittlung ---------
  CLEAR i_fkk_instpln_head.

  SELECT * FROM fkk_instpln_head INTO TABLE i_fkk_instpln_head
                    WHERE vkont = oldkey_ipl
                    AND   deman = space.

  IF i_fkk_instpln_head[] IS INITIAL.
    meldung-meldung =
     'kein aktiver Ratenplan in Tabelle FKK_INSTPLN_HEAD vorhanden'.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.                      "IF i_fkk_instpln_head[] IS INITIAL.

  CLEAR: wa_rfkn1, ir_fkkop.
  REFRESH: ir_fkkop.


  LOOP AT i_fkk_instpln_head.

    CALL FUNCTION 'FKK_S_INSTPLAN_PROVIDE'
      EXPORTING
        i_opbel              = i_fkk_instpln_head-rpnum
        i_accumulate         = ' '
        i_for_update         = ' '
        i_callid             = 'SAPLFKN1'
        i_locks_select       = ' '
*    I_XSHAD              =
      IMPORTING
        e_rfkn1              = wa_rfkn1
      TABLES
        raten_fkkop          = ir_fkkop
*   GEBUEHR_FKKOP        =
*   ZINS_FKKOP           =
*   KOPF                 =
*   HISTORIE             =
      EXCEPTIONS
        already_locked       = 1
        OTHERS               = 2.

    IF sy-subrc <> 0.
      meldung-meldung =
       'Fehler im FUBA: FKK_S_INSTPLAN_PROVIDE'.
      APPEND meldung.
      RAISE wrong_data.
    ELSEIF sy-subrc = 0.
      DELETE ir_fkkop WHERE augst = '9'.

*     wenn int.Tabelle gefüllt, dann offene Posten im Ratenplan
      IF NOT ir_fkkop[] IS INITIAL.
        CLEAR counter.
        LOOP AT ir_fkkop WHERE augst = space.
          counter = counter + 1.
*     ipl_IPDATA
          MOVE-CORRESPONDING ir_fkkop  TO ipl_ipdata.
          APPEND ipl_ipdata.
          CLEAR ipl_ipdata.
        ENDLOOP.
        EXIT.
      ENDIF.
    ENDIF.
  ENDLOOP.

* wenn int.Tabelle nicht gefüllt, dann keine offenen Posten
  IF ir_fkkop[] IS INITIAL.
    PERFORM init_ipl.
    CONCATENATE 'Keine offenen Positionen für Ratenpläne des '
                'Vertragskonto' oldkey_ipl 'vorhanden'
                   INTO meldung-meldung.
    APPEND meldung.
    CLEAR meldung.
    RAISE error.
  ENDIF.

* Füllen der Strukturen
    SELECT SINGLE * FROM dfkkko
                    WHERE opbel = i_fkk_instpln_head-rpnum.

    IF sy-subrc NE 0.
      meldung-meldung =
       'Belegnummer nicht in Tabelle DFKKKO vorhanden'.
      APPEND meldung.
      RAISE wrong_data.
    ELSEIF sy-subrc EQ 0.
      MOVE-CORRESPONDING i_fkk_instpln_head TO ipl_ipkey.
      MOVE-CORRESPONDING dfkkko             TO ipl_ipkey.
      APPEND ipl_ipkey.
      CLEAR ipl_ipkey.
    ENDIF.

  CLEAR counter.
    SELECT opbel FROM fkk_instpln_hist INTO ipl_ipopky-opbel
                   WHERE rpnum = i_fkk_instpln_head-rpnum.

      counter = counter + 1.
      CLEAR ipl_ipopky-opupw.
      CLEAR ipl_ipopky-opupk.
      CLEAR ipl_ipopky-opupz.
      APPEND ipl_ipopky.
      CLEAR ipl_ipopky.
    ENDSELECT.


*< Datenermittlung ---------
  DELETE ADJACENT DUPLICATES FROM ipl_ipopky COMPARING ALL FIELDS.

*>> Wegschreiben des Objektschlüssels in Entlade-KSV
  o_key = oldkey_ipl.
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
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_ENT_INSTPLAN'
    CALL FUNCTION ums_fuba
         EXPORTING
              firma      = firma
         TABLES
              meldung    = meldung
              ipl_ipkey  = ipl_ipkey
              ipl_ipdata = ipl_ipdata
              ipl_ipopky = ipl_ipopky
         CHANGING
              oldkey_ipl = oldkey_ipl.
  ENDIF.


* Sätze für Datei in interne Tabelle schreiben
  PERFORM fill_ipl_out USING oldkey_ipl
                             firma
                             object.


* Datei schreiben
  OPEN DATASET ent_file IN TEXT MODE FOR APPENDING ENCODING DEFAULT.

  IF sy-subrc NE 0.
    CONCATENATE 'Datei' ent_file
     'konnte nicht geöffnet werden'
                       INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
    RAISE no_open.
  ENDIF.

  LOOP AT ipl_out INTO wipl_out.
    TRANSFER wipl_out TO ent_file.
  ENDLOOP.

  CLOSE DATASET ent_file.

  IF sy-subrc NE 0.
    CONCATENATE 'Datei' ent_file
     'konnte nicht geschlossen werden'
                       INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
    RAISE no_close.
  ENDIF.


ENDFUNCTION.
