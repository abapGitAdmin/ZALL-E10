FUNCTION /adesso/mtb_bel_inst_mgmt.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(PFAD_DAT_ENT) TYPE  EMG_PFAD
*"     REFERENCE(PFAD_DAT_BEL) TYPE  EMG_PFAD
*"     REFERENCE(OBJECT) TYPE  EMG_OBJECT OPTIONAL
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

*  DATA  object          TYPE  emg_object.
  DATA  bel_file        TYPE  emg_pfad.
  DATA  ent_file        TYPE  emg_pfad.
  DATA  rep_name        TYPE  programm.
  DATA  form_name       TYPE  text30.
  DATA  syn_fehler      TYPE  text60.
  DATA: itrans          LIKE  /adesso/mt_transfer.
  DATA: idttyp          TYPE  emg_dttyp.
  DATA: ums_fuba        TYPE  funcname.
  DATA: veranz TYPE n.

  DATA:

        l_filename(10) TYPE c,
        lbelfile TYPE emg_pfad.

*  object   = 'INST_MGMT'.
  bel_file = pfad_dat_bel.
  ent_file = pfad_dat_ent.
  idttyp   = 'DI_INT'.

* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'BEL'.

* Generierung des Reports für die Übergabestrukturen
  CALL FUNCTION '/ADESSO/MTB_REP_GENERATE'
    EXPORTING
      firma               = firma
      object              = object
   IMPORTING
     rep_name             = rep_name
     form_name            = form_name
     syn_fehler           = syn_fehler
   TABLES
*    CODING              =
     meldung              = meldung
   EXCEPTIONS
     error               = 1
     OTHERS              = 2
            .
  IF sy-subrc <> 0.
    IF NOT syn_fehler IS INITIAL.
      meldung-meldung = syn_fehler.
      APPEND meldung.
    ENDIF.

    RAISE gen_error.
  ELSE.
    TRANSLATE rep_name TO UPPER CASE.
    TRANSLATE form_name TO UPPER CASE.
  ENDIF.


* einlesen der Datei
  OPEN DATASET ent_file FOR INPUT IN TEXT MODE ENCODING DEFAULT.

* Error wenn falscher Pfad bzw.Datei
  IF sy-subrc NE 0.
    CONCATENATE 'Öffnen der Datei' ent_file 'nicht möglich'
      INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
    RAISE no_open.
  ENDIF.

* Dataset lesen
  DO.

    CLEAR: itrans.
    READ DATASET ent_file INTO itrans.

    IF sy-subrc EQ 0.

*     Migrationsfirma prüfen.
      IF itrans-firma NE firma.
        CONCATENATE 'Falsche Migrationsfirma:'
                     itrans-firma
          INTO meldung-meldung SEPARATED BY space.
        APPEND meldung.
        RAISE wrong_data.
      ENDIF.

*     Daten werden um einen Altsystemschlüssel verzögert aufgebaut, weil
*     erstmal alle Strukturtabellen für den Umschlüsselungs-FUBA ermittelt
*     werden müssen (siehe: case itrans-dttyp).
      IF itrans-oldkey NE oldkey_inm AND
            oldkey_inm NE space.

        READ TABLE inm_di_int INDEX 1.

        IF inm_di_int-action NE '06' "Techn.Einbauten ohne Anlagenbezug
          AND inm_di_int-action NE '03'. " Wechsel

*         bei Einbau in Netzanlage müssen auf Zählwersebene das
*         Verrechnungspreiskennzeichen und die Preisklasse gelöscht werden
          READ TABLE inm_di_int INDEX 1.
          CASE inm_di_int-action.
            WHEN '01'.
              LOOP AT inm_di_zw.
                CLEAR inm_di_zw-gverrech.
                CLEAR inm_di_zw-preisklae.
                MODIFY inm_di_zw.
              ENDLOOP.
            WHEN '04'.
              LOOP AT inm_di_zw.
                CLEAR inm_di_zw-gverrech.
                CLEAR inm_di_zw-preisklae.
                MODIFY inm_di_zw.
              ENDLOOP.
          ENDCASE.

*         Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
          IF NOT ums_fuba IS INITIAL.
            CALL FUNCTION ums_fuba
              EXPORTING
                firma      = firma
              TABLES
                meldung    = meldung
                inm_di_int = inm_di_int
                inm_di_zw  = inm_di_zw
                inm_di_ger = inm_di_ger
                inm_di_cnt = inm_di_cnt
              CHANGING
                oldkey_inm = oldkey_inm.
          ENDIF.

*         Dateiaufbereitung zum erstellen der Workbench-Dateien
          PERFORM aufbereitung_dat_inm USING oldkey_inm
                                             rep_name
                                             form_name.
          anz_obj = anz_obj + 1.

          CLEAR: inm_di_int, inm_di_zw, inm_di_ger, inm_di_cnt.
          REFRESH: inm_di_int, inm_di_zw, inm_di_ger, inm_di_cnt.


        ELSE.  "bei technischem Einbau und Wechsel

*         alles bleibt wie gehabt
*         ausser bei Wechsel (hier müssen einige Felder gelöscht werden)
          READ TABLE inm_di_int INDEX 1.
          CASE inm_di_int-action.
            WHEN '03'.
*             Anlagenschlüssel löschen   " Kle 01.09.2004
              LOOP AT inm_di_int.
                CLEAR inm_di_int-anlage.
                MODIFY inm_di_int.
              ENDLOOP.

              LOOP AT inm_di_ger.
                CLEAR inm_di_ger-gverrechg.
                CLEAR inm_di_ger-kondigrg.
                CLEAR inm_di_ger-preisklag.
                CLEAR inm_di_ger-tarifartg.
                MODIFY inm_di_ger.
              ENDLOOP.

              LOOP AT inm_di_zw.
                CLEAR inm_di_zw-crgpress.
                CLEAR inm_di_zw-gas_prs_ar.
                CLEAR inm_di_zw-gverrech.
                CLEAR inm_di_zw-kennziffe.
                CLEAR inm_di_zw-kondigre.
                CLEAR inm_di_zw-kzmesswe.
                CLEAR inm_di_zw-preisklae.
                CLEAR inm_di_zw-rabzuse.
                CLEAR inm_di_zw-tarifart.
                CLEAR inm_di_zw-zwnabr.
                CLEAR inm_di_zw-zwnsettle.
                MODIFY inm_di_zw.
              ENDLOOP.
          ENDCASE.

*   bei techn. Einbau wird am Ursprung nichts geändert

*         Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
          IF NOT ums_fuba IS INITIAL.
            CALL FUNCTION ums_fuba
              EXPORTING
                firma      = firma
              TABLES
                meldung    = meldung
                inm_di_int = inm_di_int
                inm_di_zw  = inm_di_zw
                inm_di_ger = inm_di_ger
                inm_di_cnt = inm_di_cnt
              CHANGING
                oldkey_inm = oldkey_inm.
          ENDIF.

*         Dateiaufbereitung zum erstellen der Workbench-Dateien
          PERFORM aufbereitung_dat_inm USING oldkey_inm
                                             rep_name
                                             form_name.
          anz_obj = anz_obj + 1.
        ENDIF.

        CLEAR: inm_di_int, inm_di_zw, inm_di_ger, inm_di_cnt.
        REFRESH: inm_di_int, inm_di_zw, inm_di_ger, inm_di_cnt.

      ENDIF. "Neuer Schlüssel

* füllen der entsprechenden internern Tabellen je Altsystemschlüssel zum
* bearbeiten im Umschlüsselung-FUBA und später zur Aufbereitung der
* Migrationsdaten
* => je Datentyp eigene Tabelle
      CASE itrans-dttyp.
        WHEN 'DI_INT'.
          CLEAR x_inm_di_int.
          MOVE itrans-data TO x_inm_di_int.
          MOVE-CORRESPONDING x_inm_di_int TO inm_di_int.
*          CONCATENATE inm_di_int-anlage '%' INTO oldanl.
          APPEND inm_di_int.
          CLEAR inm_di_int.
        WHEN 'DI_ZW'.
          CLEAR x_inm_di_zw.
          MOVE itrans-data TO x_inm_di_zw.
          MOVE-CORRESPONDING x_inm_di_zw TO inm_di_zw.
          APPEND inm_di_zw.
          CLEAR inm_di_zw.
        WHEN 'DI_GER'.
          CLEAR x_inm_di_ger.
          MOVE itrans-data TO x_inm_di_ger.
          MOVE-CORRESPONDING x_inm_di_ger TO inm_di_ger.
          APPEND inm_di_ger.
          CLEAR inm_di_ger.
        WHEN 'DI_CNT'.
          CLEAR x_inm_di_cnt.
          MOVE itrans-data TO x_inm_di_cnt.
          MOVE-CORRESPONDING x_inm_di_cnt TO inm_di_cnt.
          APPEND inm_di_cnt.
          CLEAR inm_di_cnt.
      ENDCASE.

      MOVE itrans-oldkey TO oldkey_inm.

    ELSE. "Kein weiterer Datensatz in Entladedatei vorhanden

      READ TABLE inm_di_int INDEX 1.

      IF inm_di_int-action NE '06' "Techn.Einbauten ohne Anlagenbezug
        AND inm_di_int-action NE '03'. " Wechsel


*       bei Einbau in Netzanlage müssen auf Zählwersebene das
*       Verrechnungspreiskennzeichen und die Preisklasse gelöscht werden
        READ TABLE inm_di_int INDEX 1.
        CASE inm_di_int-action.
          WHEN '01'.
            LOOP AT inm_di_zw.
              CLEAR inm_di_zw-gverrech.
              CLEAR inm_di_zw-preisklae.
              MODIFY inm_di_zw.
            ENDLOOP.
          WHEN '04'.
            LOOP AT inm_di_zw.
              CLEAR inm_di_zw-gverrech.
              CLEAR inm_di_zw-preisklae.
              MODIFY inm_di_zw.
            ENDLOOP.
        ENDCASE.

*       Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
        IF NOT ums_fuba IS INITIAL.
          CALL FUNCTION ums_fuba
            EXPORTING
              firma      = firma
            TABLES
              meldung    = meldung
              inm_di_int = inm_di_int
              inm_di_zw  = inm_di_zw
              inm_di_ger = inm_di_ger
              inm_di_cnt = inm_di_cnt
            CHANGING
              oldkey_inm = oldkey_inm.
        ENDIF.

*       Dateiaufbereitung zum erstellen der Workbench-Dateien
        PERFORM aufbereitung_dat_inm USING oldkey_inm
                                           rep_name
                                           form_name.

        anz_obj = anz_obj + 1.

        CLEAR: inm_di_int, inm_di_zw, inm_di_ger, inm_di_cnt.
        REFRESH: inm_di_int, inm_di_zw, inm_di_ger, inm_di_cnt.

      ELSE.  "bei technischem Einbau und Wechsel
*       alles bleibt wie gehabt
*       ausser bei Wechsel (hier müssen einige Felder gelöscht werden)
        READ TABLE inm_di_int INDEX 1.
        CASE inm_di_int-action.
          WHEN '03'.
*       Anlagenschlüssel löschen   " Kle 01.09.2004
            LOOP AT inm_di_int.
              CLEAR inm_di_int-anlage.
              MODIFY inm_di_int.
            ENDLOOP.

            LOOP AT inm_di_ger.
              CLEAR inm_di_ger-gverrechg.
              CLEAR inm_di_ger-kondigrg.
              CLEAR inm_di_ger-preisklag.
              CLEAR inm_di_ger-tarifartg.
              MODIFY inm_di_ger.
            ENDLOOP.

            LOOP AT inm_di_zw.
              CLEAR inm_di_zw-crgpress.
              CLEAR inm_di_zw-gas_prs_ar.
              CLEAR inm_di_zw-gverrech.
              CLEAR inm_di_zw-kennziffe.
              CLEAR inm_di_zw-kondigre.
              CLEAR inm_di_zw-kzmesswe.
              CLEAR inm_di_zw-preisklae.
              CLEAR inm_di_zw-rabzuse.
              CLEAR inm_di_zw-tarifart.
              CLEAR inm_di_zw-zwnabr.
              CLEAR inm_di_zw-zwnsettle.
              MODIFY inm_di_zw.
            ENDLOOP.
        ENDCASE.
*   bei techn. Einbau wird am Ursprung nichts geändert

*       Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
        IF NOT ums_fuba IS INITIAL.
          CALL FUNCTION ums_fuba
            EXPORTING
              firma      = firma
            TABLES
              meldung    = meldung
              inm_di_int = inm_di_int
              inm_di_zw  = inm_di_zw
              inm_di_ger = inm_di_ger
              inm_di_cnt = inm_di_cnt
            CHANGING
              oldkey_inm = oldkey_inm.
        ENDIF.

*       Dateiaufbereitung zum erstellen der Workbench-Dateien
        PERFORM aufbereitung_dat_inm USING oldkey_inm
                                           rep_name
                                           form_name.
        anz_obj = anz_obj + 1.
      ENDIF."Technischer Einbau und Wechsel

      CLEAR: inm_di_int, inm_di_zw, inm_di_ger, inm_di_cnt.
      REFRESH: inm_di_int, inm_di_zw, inm_di_ger, inm_di_cnt.

      EXIT.

    ENDIF. "Datensatz in Datei vorhanden

  ENDDO. "Datei lesen

* Erstellen der Migrationsdatei
  READ TABLE i_inm_down INDEX 1.
  IF sy-subrc NE 0.
    CONCATENATE  'Keine Datensätze für Objekt' object
                 'vorhanden bzw. erzeugt'
           INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
    RAISE error.

  ELSE.
*    --> Nuss 15.09.2015
*    PERFORM erst_mig_datei3 TABLES i_inm_down
*                            USING firma
*                                  object
*                                  idttyp
*                                  bel_file.

    PERFORM erst_mig_datei  TABLES i_inm_down
                            USING firma
                                  object
                                  idttyp
                                  bel_file.
*   <-- Nuss 15.09.2015

    CONCATENATE  'Datei' bel_file 'wurde erzeugt'
             INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.

  ENDIF.






ENDFUNCTION.
