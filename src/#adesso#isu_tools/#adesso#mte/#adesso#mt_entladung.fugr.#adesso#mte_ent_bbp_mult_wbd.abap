FUNCTION /adesso/mte_ent_bbp_mult_wbd.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(X_ABPLAN) TYPE  EABP-OPBEL
*"     REFERENCE(PFAD_DAT_ENT) TYPE  EMG_PFAD
*"  EXPORTING
*"     REFERENCE(ANZ_OBJ) TYPE  I
*"     REFERENCE(ANZ_EABP) TYPE  I
*"     REFERENCE(ANZ_EABPV) TYPE  I
*"     REFERENCE(ANZ_EABPS) TYPE  I
*"     REFERENCE(ANZ_EJVL) TYPE  I
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"  EXCEPTIONS
*"      NO_OPEN
*"      NO_CLOSE
*"      WRONG_DATA
*"      NO_DATA
*"      GEN_ERROR
*"      ERROR
*"----------------------------------------------------------------------

  DATA  object          TYPE  emg_object.
  DATA  ent_file        TYPE  emg_pfad.
  DATA: ums_fuba        TYPE  funcname.
  DATA: iobj            TYPE isu25_budbilplan.
  DATA: iauto           TYPE isu25_budbilplan_auto.
  DATA: wa_eabp         LIKE eabp.
  DATA: wa_eabps        LIKE eabps.
  DATA: wa_ejvl         LIKE ejvl.
  DATA: o_key           TYPE  emg_oldkey.
  DATA: lv_ever LIKE ever.
  DATA: lv_subrc LIKE sy-subrc.

  DATA: wa_fkkmaze TYPE fkkmaze.

  object   = 'BBP_MULT'.
  ent_file = pfad_dat_ent.
  oldkey_bpm = x_abplan.

* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.


*>   Initialisierung
  PERFORM init_bpm.
  CLEAR: ibpm_out, wbpm_out, wa_eabps, wa_ejvl, meldung, anz_obj.
  REFRESH: ibpm_out, meldung.
*<


*> Datenermittlung ---------

*  --> Nuss 10.09.2015
*  Sicherstellen, dass nur der Abschlagsplan zum Abwasservertrag ermittelt wird
*  SELECT  single *
*         INTO wa_eabp
*         FROM eabp
*         WHERE opbel = x_abplan.
  CLEAR wa_eabp.
  SELECT * FROM eabp INTO wa_eabp
    WHERE opbel = x_abplan.
    CLEAR lv_ever.
    SELECT SINGLE * FROM ever INTO lv_ever
      WHERE vertrag = wa_eabp-vertrag.
*   Sparte ungleich Abwasser
    IF lv_ever-sparte NE '05'.
      CLEAR wa_eabp.
      CONTINUE.
    ELSE.
      EXIT.
    ENDIF.
  ENDSELECT.

  IF wa_eabp IS INITIAL.
    CONCATENATE 'Abschl.Plan' wa_eabp-opbel
                'beinhaltet keinen Abwasservertrag'
                 INTO meldung-meldung
                 SEPARATED BY space.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.
* <-- Nuss 10.09.2015


  CALL FUNCTION 'ISU_S_BUDBILPLAN_PROVIDE'
    EXPORTING
      x_vertrag     = wa_eabp-vertrag
      x_opbel       = x_abplan
      x_edatum      = sy-datum
      x_wmode       = '1'
    IMPORTING
      y_obj         = iobj
      y_auto        = iauto
    EXCEPTIONS
      not_found     = 1
      foreign_lock  = 2
      general_fault = 3
      OTHERS        = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* ibpm_EABP
  MOVE-CORRESPONDING wa_eabp TO ibpm_eabp.
  APPEND ibpm_eabp.
  CLEAR ibpm_eabp.

* ibpm_EABPV
  LOOP AT iobj-inteabp INTO wa_eabp.

    SELECT SINGLE *
           FROM /adesso/mte_rel
           WHERE firma = firma
             AND ( object = 'MOVE_IN' OR
                   object = 'MOVE_IN_H' OR
                   object = 'MOVE_IN_L' )
             AND obj_key = wa_eabp-vertrag.
    lv_subrc = sy-subrc.

    IF lv_subrc = 0.
      MOVE wa_eabp-vertrag  TO ibpm_eabpv-vtref.
      APPEND ibpm_eabpv.
      CLEAR ibpm_eabpv.
    ELSE.
*   --> Nuss 21.09.2015
*   --> Das wird im Projekt DVV - WBD auskommentiert.
*      CONCATENATE 'Abschl.Plan' wa_eabp-opbel
*                  'beinhaltet einen nicht migrationsrelevanten Vertrag'
*                   wa_eabp-vertrag INTO meldung-meldung
*                   separated by space.
*      APPEND meldung.
*   <-- Nuss 21.09.2015
    ENDIF.
  ENDLOOP.

* --> Nuss 21.09.2015
  IF ibpm_eabpv[] IS INITIAL.
    CONCATENATE 'Abschl.Plan' wa_eabp-opbel
                'hat keinen gültigen Vertrag'
                INTO meldung-meldung
                SEPARATED BY space.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.
* <-- Nuss 21.09.2015


* ibpm_EABPS
  LOOP AT iobj-ieabps INTO wa_eabps.

    SELECT SINGLE *
         FROM /adesso/mte_rel
         WHERE firma = firma
           AND ( object = 'MOVE_IN' OR
                 object = 'MOVE_IN_H' OR
                 object = 'MOVE_IN_L' )
           AND obj_key = wa_eabps-vtref+10(10).
    lv_subrc = sy-subrc.

    IF lv_subrc = 0.

**    --> Nuss 21.09.2015
**    Nur Positionen, die einen offenen Betrag haben migrieren (WBD-Projekt)
*      IF wa_eabps-betro IS INITIAL.
*        CONTINUE.
*      ENDIF.
**    <-- Nuss 21.09.2015

      MOVE-CORRESPONDING wa_eabps TO ibpm_eabps.
**     Die Abschlagsplanzeilen werden als offen migriert und später mit
**    'PAYMENT' ausgeglichen (wenn möglich). """"(bei WBD-Projekt nein)
**     TEMKSV-Schlüssel muss 10-Stellig sein
      MOVE wa_eabps-vtref+10(10) TO ibpm_eabps-vtref.

      MOVE wa_eabps-betrw TO ibpm_eabps-betro.   """""Nuss 10.09.2015
      CLEAR wa_eabps-augst.

*    --> Nuss 10.09.2015
*      Bei WBD-Projekt werden keine Mahnungen migriert
**     Lesen, ob der Posten gemahnt ist und gegebenenfalls in der
**     Relevanztabelle für DUNNING hinterlegen
*      CLEAR wa_fkkmaze.
*      SELECT SINGLE * FROM fkkmaze INTO wa_fkkmaze
*         WHERE opbel = ibpm_eabps-opbel
*          AND  opupw = ibpm_eabps-opupw
*          AND  opupk = ibpm_eabps-opupk
*          AND  opupz = ibpm_eabps-opupz
*          AND xmsto NE 'X'
*          AND mdrkd NE '00000000'.
*      IF sy-subrc = 0.
*        CONCATENATE ibpm_eabps-opbel
*                    ibpm_eabps-opupw
*                    ibpm_eabps-opupk
*                    ibpm_eabps-opupz
*       INTO /adesso/mte_rel-obj_key.
*        MOVE 'DUNNING' TO /adesso/mte_rel-object.
*        MOVE firma TO /adesso/mte_rel-firma.
*        MODIFY /adesso/mte_rel.
*        COMMIT WORK.
*      ENDIF.
*     <-- Nuss 10.09.2015

      APPEND ibpm_eabps.
      CLEAR ibpm_eabps.
    ENDIF.
  ENDLOOP.

** --> Nuss 21.09.2015
** keine offene Positionen im ABP
  IF ibpm_eabps[] IS INITIAL.
    CONCATENATE 'Abschl.Plan' wa_eabp-opbel
                'beinhaltet keine offenen Posten'
                 INTO meldung-meldung
                 SEPARATED BY space.
    APPEND meldung.
    RAISE no_data.
  ENDIF.
** <-- NUss 21.09.2015

* Jahresvorausleistungen
* ibpm_ejvl
  LOOP AT iobj-intejvl INTO wa_ejvl.
    SELECT SINGLE *
         FROM /adesso/mte_rel
         WHERE firma = firma
           AND ( object = 'MOVE_IN' OR
                 object = 'MOVE_IN_H' OR
                 object = 'MOVE_IN_L' )
           AND obj_key = wa_ejvl-vertrag+10(10).
    lv_subrc = sy-subrc.
    IF lv_subrc = 0.
      MOVE-CORRESPONDING wa_ejvl TO ibpm_ejvl.
      APPEND ibpm_ejvl.
      CLEAR ibpm_ejvl.
    ENDIF.
  ENDLOOP.

*< Datenermittlung ---------


*>> Wegschreiben des Objektschlüssels in Entlade-KSV
  o_key = oldkey_bpm.
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
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_ENT_BBP_MULT'
    CALL FUNCTION ums_fuba
      EXPORTING
        firma      = firma
      TABLES
        meldung    = meldung
        ibpm_eabp  = ibpm_eabp
        ibpm_eabpv = ibpm_eabpv
        ibpm_eabps = ibpm_eabps
        ibpm_ejvl  = ibpm_ejvl
      CHANGING
        oldkey_bpm = oldkey_bpm.
  ENDIF.

* Sätze für Datei in interne Tabelle schreiben
  PERFORM fill_bpm_out USING oldkey_bpm
                             firma
                             object
                             anz_eabp
                             anz_eabpv
                             anz_eabps
                             anz_ejvl.

  LOOP AT ibpm_out INTO wbpm_out.
    TRANSFER wbpm_out TO ent_file.
  ENDLOOP.




ENDFUNCTION.
