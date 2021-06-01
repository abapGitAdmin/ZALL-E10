FUNCTION /ADESSO/MTE_ENT_INSTLNCHNN.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(X_ANLAGE) LIKE  EANL-ANLAGE
*"     REFERENCE(PFAD_DAT_ENT) TYPE  EMG_PFAD
*"     REFERENCE(X_HISTORISCH) TYPE  /ADESSO/MTE_INSTLNCHA_HISTORIC
*"       OPTIONAL
*"  EXPORTING
*"     REFERENCE(ANZ_OBJ) TYPE  I
*"     REFERENCE(ANZ_KEY) TYPE  I
*"     REFERENCE(ANZ_DATA) TYPE  I
*"     REFERENCE(ANZ_RCAT) TYPE  I
*"     REFERENCE(ANZ_POD) TYPE  I
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"  EXCEPTIONS
*"      NO_OPEN
*"      NO_CLOSE
*"      WRONG_DATA
*"      GEN_ERROR
*"      ERROR
*"      NO_ADRESS
*"      NO_KEY
*"----------------------------------------------------------------------

  DATA  object          TYPE  emg_object.
  DATA  ent_file        TYPE  emg_pfad.
  DATA: ums_fuba        TYPE  funcname.
  DATA: p_beginn        LIKE  sy-datum.
  DATA: o_key           TYPE  emg_oldkey.


  DATA: BEGIN OF ieanlh OCCURS 0,
         anlage LIKE eanlh-anlage,
         bis    LIKE eanlh-bis,
         ab     LIKE eanlh-ab,
        END OF ieanlh,

        wa_ieanlh LIKE eanlh,
        it_ieanlh_h LIKE TABLE OF wa_ieanlh.

  DATA: oldkey_datei LIKE /adesso/mt_transfer-oldkey.
  DATA: counter(1) TYPE n.

  DATA: anz_zs TYPE i,
        anz_netz TYPE i.
  DATA: it_euigrid TYPE TABLE OF euigrid,
        wa_euigrid TYPE euigrid,
        h_euigrid  TYPE euigrid.
  DATA: ret_code LIKE sy-subrc.
  DATA: BEGIN OF wa_hilf,
          datum       TYPE sy-datum,
          anlage      TYPE anlage,
          int_ui      TYPE int_ui,
          grid_id     TYPE grid_id,
          tabelle(10) TYPE c,
        END OF wa_hilf.
  DATA: it_hilf LIKE STANDARD TABLE OF wa_hilf.


  object   = 'INSTLNCHNN'.
  ent_file = pfad_dat_ent.
  oldkey_icn = x_anlage.

* Werden historische Zeitscheigben übernommen,
* müssen die Enddaten berichtigt werden.
  DATA:  wa_bis_akt TYPE eanlh-bis.

*  REFRESH icn_facts.

* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.

*>   Initialisierung
  PERFORM init_icn.
  CLEAR: icn_out, wicn_out, meldung, anz_obj.
  REFRESH: icn_out, meldung.
*<


*> Datenermittlung ---------

* jüngste Zeitscheibe lesen
  SELECT * FROM eanlh
            INTO CORRESPONDING FIELDS OF TABLE ieanlh
                     WHERE anlage = oldkey_icn.
*                        AND    bis eq  '99991231'.
  IF sy-subrc NE 0.
*   Dateninkonsistenz
    meldung-meldung =
     'Anlage nicht in Tabelle EANLH vorhanden'.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.


* Netze zur Anlage selektieren
  SELECT SINGLE * FROM euiinstln WHERE anlage = oldkey_icn
    AND dateto = '99991231'.
  CLEAR: it_euigrid, wa_euigrid.
  SELECT * FROM euigrid INTO TABLE it_euigrid
      WHERE int_ui = euiinstln-int_ui.
  DESCRIBE TABLE it_euigrid LINES anz_netz.
  DESCRIBE TABLE ieanlh LINES anz_zs.


* Historische Zeitscheibe in der ieanlh einführen;
* Nur, wenn es Historie vor Beginn der Abr. Periode gibt
*  IF x_historisch = 'X'.
**   und, wenn es angefordert wurde
*    SELECT * FROM eanlh
*      INTO CORRESPONDING FIELDS OF TABLE it_ieanlh_h
*      WHERE anlage = oldkey_icn
*        AND bis < p_beginn.
*
*    IF sy-subrc = 0.
**     Frühestes Beginndatum ermitteln (= Beginn der Anlage)
*      SORT it_ieanlh_h BY ab.
*      CLEAR wa_ieanlh.
*      READ TABLE it_ieanlh_h
*        INDEX 1
*        INTO  wa_ieanlh
*        TRANSPORTING anlage ab.
*
**     Späteste Enddatum ermitteln (= Datum vor Beg. Abr.Pe.)
*      SORT it_ieanlh_h BY bis DESCENDING.
*      READ TABLE it_ieanlh_h
*        INDEX 1
*        INTO wa_ieanlh
*        TRANSPORTING bis.
*
*      MOVE-CORRESPONDING wa_ieanlh TO ieanlh.
*      APPEND ieanlh.
*    ENDIF.
*
**   Ende der aktuellen Zeitscheibe ermitteln.
*    READ TABLE ieanlh INDEX 1.
*    wa_bis_akt = ieanlh-bis.
*
*  ENDIF.

* Strukturen füllen
  CLEAR counter.
**  SORT ieanlh BY ab.
  SORT ieanlh BY bis ASCENDING.


**  Fall 1:
** Mehrere Tarife und ein Netz
  IF anz_zs GT 1 AND anz_netz EQ 1.
    LOOP AT ieanlh.

*  Die erste Zeitscheibe wurde schon bei INSTLN entladen.
      IF sy-tabix = 1.
        CONTINUE.
      ENDIF.

      CLEAR: icn_out, wicn_out.
      REFRESH: icn_out.
      counter = counter + 1.

      SELECT SINGLE * FROM v_eanl WHERE anlage = ieanlh-anlage
                                    AND bis    = ieanlh-bis.
      IF sy-subrc EQ 0.
*     icn_key
        MOVE v_eanl-anlage TO icn_key-anlage.
*      MOVE v_eanl-bis TO icn_key-bis.

*     Bis-Datum in Emigall immer auf 31.12.9999 gesetzt
**     Dieses Coding ist demnach ohne Wirkung ------------------------>>>
*      IF ieanlh-bis >= p_beginn.
*        MOVE '99991231'    TO icn_key-bis.
*      ELSE.
*        MOVE ieanlh-bis TO icn_key-bis.
*      ENDIF.
*
*      IF x_historisch = 'X' AND ieanlh-bis < p_beginn.
*        icn_key-bis = wa_bis_akt.
*      ENDIF.
**     Dieses Coding ist demnach ohne Wirkung ------------------------<<<<

        APPEND icn_key.
        CLEAR  icn_key.

*     icn_data
        MOVE-CORRESPONDING v_eanl TO icn_data.

        APPEND icn_data.
        CLEAR  icn_data.

*     icn_rcat
        MOVE-CORRESPONDING v_eanl TO icn_rcat.
        APPEND icn_rcat.
        CLEAR  icn_rcat.

      ELSE.
        meldung-meldung =
         'Anlagen-Zeitscheibe nicht in Tabelle V_EANL gefunden'.
        APPEND meldung.
        RAISE wrong_data.
      ENDIF.

** Fakten werden als eigenes Migrationsobjekt migriert

*< Datenermittlung ---------
*>> Wegschreiben des Objektschlüssels in Entlade-KSV

      CONCATENATE oldkey_icn '_' counter INTO o_key.
*    o_key = oldkey_icn.
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
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_ENT_INSTLNCH'
        CALL FUNCTION ums_fuba
          EXPORTING
            firma      = firma
          TABLES
            meldung    = meldung
            icn_key    = icn_key
            icn_data   = icn_data
            icn_rcat   = icn_rcat
          CHANGING
            oldkey_icn = oldkey_icn
          EXCEPTIONS
            no_adress  = 1
            no_key     = 2
            OTHERS     = 3.
        CASE sy-subrc.
          WHEN 1.
            RAISE no_adress.
          WHEN 2.
            RAISE no_key.
        ENDCASE.
      ENDIF.

* Sätze für Datei in interne Tabelle schreiben
      CONCATENATE oldkey_icn '_' counter INTO oldkey_datei.
*    oldkey_datei = oldkey_icn.
      PERFORM fill_icn_out USING oldkey_datei
                                 firma
                                 object
                                 anz_key
                                 anz_data
                                 anz_rcat
                                 anz_pod.
      LOOP AT icn_out INTO wicn_out.
        TRANSFER wicn_out TO ent_file.
      ENDLOOP.
    ENDLOOP.
  ENDIF.


* Fall 2
* Ein Tariftyp mehrere Netze
  IF anz_zs = 1 AND anz_netz GT 1.
    LOOP AT it_euigrid INTO wa_euigrid.
*     Erste Netzzeitscheibe wurde bereits bei INSTLN_NN entladen
      IF sy-tabix = 1.
        CONTINUE.
      ENDIF.
      READ TABLE ieanlh INDEX 1.

      CLEAR: icn_out, wicn_out.
      REFRESH: icn_out.
      counter = counter + 1.

      SELECT SINGLE * FROM v_eanl WHERE anlage = ieanlh-anlage
                                    AND bis    = ieanlh-bis.
      IF sy-subrc EQ 0.
*     icn_key
        MOVE v_eanl-anlage TO icn_key-anlage.

        APPEND icn_key.
        CLEAR  icn_key.

*     icn_data
        MOVE-CORRESPONDING v_eanl TO icn_data.
        MOVE wa_euigrid-datefrom TO icn_data-ab.
        APPEND icn_data.
        CLEAR  icn_data.

*     icn_rcat
        MOVE-CORRESPONDING v_eanl TO icn_rcat.
        APPEND icn_rcat.
        CLEAR  icn_rcat.

*    icn_pod
        MOVE-CORRESPONDING wa_euigrid TO icn_pod.
        SHIFT icn_pod-grid_id LEFT DELETING LEADING '0'.

        SELECT SINGLE * FROM euitrans
                          WHERE int_ui = wa_euigrid-int_ui
                            AND dateto GE sy-datum "p_datab "p_beginn
                            AND datefrom LE sy-datum. "p_datab. "p_beginn.
        IF sy-subrc EQ 0.
          MOVE-CORRESPONDING euitrans TO icn_pod.
        ELSE.
          MOVE sy-subrc TO ret_code.
          EXIT.
        ENDIF.

        APPEND icn_pod.
        CLEAR icn_pod.

      ELSE.
        meldung-meldung =
         'Anlagen-Zeitscheibe nicht in Tabelle V_EANL gefunden'.
        APPEND meldung.
        RAISE wrong_data.
      ENDIF.

*>> Wegschreiben des Objektschlüssels in Entlade-KSV

      CONCATENATE oldkey_icn '_' counter INTO o_key.
*    o_key = oldkey_icn.
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
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_ENT_INSTLNCH'
        CALL FUNCTION ums_fuba
          EXPORTING
            firma      = firma
          TABLES
            meldung    = meldung
            icn_key    = icn_key
            icn_data   = icn_data
            icn_rcat   = icn_rcat
          CHANGING
            oldkey_icn = oldkey_icn
          EXCEPTIONS
            no_adress  = 1
            no_key     = 2
            OTHERS     = 3.
        CASE sy-subrc.
          WHEN 1.
            RAISE no_adress.
          WHEN 2.
            RAISE no_key.
        ENDCASE.

      ENDIF.

* Sätze für Datei in interne Tabelle schreiben
      CONCATENATE oldkey_icn '_' counter INTO oldkey_datei.
*    oldkey_datei = oldkey_icn.
      PERFORM fill_icn_out USING oldkey_datei
                                 firma
                                 object
                                 anz_key
                                 anz_data
                                 anz_rcat
                                 anz_pod.
      LOOP AT icn_out INTO wicn_out.
        TRANSFER wicn_out TO ent_file.
      ENDLOOP.
    ENDLOOP.
  ENDIF.

* Fall 3
* Mehrere Anlagenzeitscheiben und mehrere Netze
  IF anz_zs GT 1 AND anz_netz GT 1.
*  Aufbau einer chronologischen Hilfstabelle mit
*  Netzänderungen und Anlagenzs-Änderungen
*  Netzänderungen in Hilfstabelle packen
    CLEAR: it_hilf, wa_hilf.
    LOOP AT it_euigrid INTO wa_euigrid.
*     Erste ZS in INSTLN entladen
      IF sy-tabix = 1.
        CONTINUE.
      ENDIF.
      MOVE wa_euigrid-datefrom TO wa_hilf-datum.
      SELECT SINGLE  * FROM euiinstln
        WHERE int_ui = wa_euigrid-int_ui
        AND dateto GT sy-datum
        AND datefrom LT sy-datum.
      MOVE wa_euigrid-grid_id TO wa_hilf-grid_id.
      MOVE euiinstln-anlage TO wa_hilf-anlage.
      move euiinstln-int_ui to wa_hilf-int_ui.
      MOVE 'EUIGRID' TO wa_hilf-tabelle.
      APPEND wa_hilf TO it_hilf.
      CLEAR wa_hilf.
    ENDLOOP.

*   Anlagenzeitscheibenänderungen in Hilfstabelle packen
    LOOP AT ieanlh.
*    Erste ZS in INSTLN entladen
      IF sy-tabix = 1.
        CONTINUE.
      ENDIF.
**    Wenn in der Hilfstabelle das AB-Datum des Zeitscheiben-
**    wechsels bereits steht, wird es nicht noch einmal benötigt
      READ TABLE it_hilf TRANSPORTING NO FIELDS
         WITH KEY datum = ieanlh-ab.
      IF sy-subrc = 0.
        CONTINUE.
      ELSE.
**      Zeitscheibenänderungen in die Hilfstabelle wegschreiben
        MOVE ieanlh-ab TO wa_hilf-datum.
        MOVE ieanlh-anlage TO wa_hilf-anlage.
        MOVE 'EANLH' TO wa_hilf-tabelle.
        APPEND wa_hilf TO it_hilf.
        CLEAR wa_hilf.
      ENDIF.
    ENDLOOP.

*   Tabelle aufsteigend nach Datum sortieren
    SORT it_hilf BY datum ASCENDING.
    LOOP AT it_hilf INTO wa_hilf.

      CLEAR: icn_out, wicn_out.
      REFRESH: icn_out.
      counter = counter + 1.

*     Netzänderung
      IF wa_hilf-tabelle = 'EUIGRID'.
**      Suchen Anlagenzeitscheibe kleiner gleich der Netzänderung
        SELECT SINGLE * FROM v_eanl
          WHERE anlage = wa_hilf-anlage
            AND ab LE wa_hilf-datum
            AND bis GE wa_hilf-datum.

        IF sy-subrc EQ 0.
*         icn_key
          MOVE v_eanl-anlage TO icn_key-anlage.

          APPEND icn_key.
          CLEAR  icn_key.

*         icn_data
          MOVE-CORRESPONDING v_eanl TO icn_data.
          MOVE wa_hilf-datum TO icn_data-ab.
          APPEND icn_data.
          CLEAR  icn_data.

*         icn_rcat
          MOVE-CORRESPONDING v_eanl TO icn_rcat.
          APPEND icn_rcat.
          CLEAR  icn_rcat.

*         icn_pod
          CLEAR h_euigrid.
          select single * from euigrid into h_euigrid
            where int_ui = wa_hilf-int_ui
             and datefrom = wa_hilf-datum.
          MOVE-CORRESPONDING h_euigrid TO icn_pod.
          SHIFT icn_pod-grid_id LEFT DELETING LEADING '0'.

          SELECT SINGLE * FROM euitrans
                            WHERE int_ui = wa_euigrid-int_ui
                              AND dateto GE sy-datum "p_datab "p_beginn
                              AND datefrom LE sy-datum. "p_datab. "p_beginn.
          IF sy-subrc EQ 0.
            MOVE-CORRESPONDING euitrans TO icn_pod.
          ELSE.
            MOVE sy-subrc TO ret_code.
            EXIT.
          ENDIF.

          APPEND icn_pod.
          CLEAR icn_pod.
        ELSE.
**      Es wurde keine Zeitscheibe kleiner gleich dem Netzänderungsdatum gefunden
**      Da in der Migration der Bigenn der Anlage auf den 01.01.2000 gelegt wird,
**      wir hier für die Daten die älteste Zeitscheibe gelesen.
          READ TABLE ieanlh INDEX 1.

          SELECT SINGLE * FROM v_eanl WHERE anlage = ieanlh-anlage
                                        AND bis    = ieanlh-bis.
          IF sy-subrc EQ 0.
*     icn_key
            MOVE v_eanl-anlage TO icn_key-anlage.

            APPEND icn_key.
            CLEAR  icn_key.

*     icn_data
            MOVE-CORRESPONDING v_eanl TO icn_data.
            MOVE wa_hilf-datum TO icn_data-ab.
            APPEND icn_data.
            CLEAR  icn_data.

*     icn_rcat
            MOVE-CORRESPONDING v_eanl TO icn_rcat.
            APPEND icn_rcat.
            CLEAR  icn_rcat.

*    icn_pod
          CLEAR h_euigrid.
          select single * from euigrid into h_euigrid
            where int_ui = wa_hilf-int_ui
             and datefrom = wa_hilf-datum.
          MOVE-CORRESPONDING h_euigrid TO icn_pod.
          SHIFT icn_pod-grid_id LEFT DELETING LEADING '0'.

            SELECT SINGLE * FROM euitrans
                              WHERE int_ui = wa_euigrid-int_ui
                                AND dateto GE sy-datum "p_datab "p_beginn
                                AND datefrom LE sy-datum. "p_datab. "p_beginn.
            IF sy-subrc EQ 0.
              MOVE-CORRESPONDING euitrans TO icn_pod.
            ELSE.
              MOVE sy-subrc TO ret_code.
              EXIT.
            ENDIF.

            APPEND icn_pod.
            CLEAR icn_pod.

          ELSE.
            meldung-meldung =
             'Anlagen-Zeitscheibe nicht in Tabelle V_EANL gefunden'.
            APPEND meldung.
            RAISE wrong_data.
          ENDIF.

        ENDIF.
      ENDIF.

*     Nur Änderung der Anlagenzeitscheibe
*     Kein Aufbau der Strukur ICN_POD
      IF wa_hilf-tabelle = 'EANLH'.
        SELECT SINGLE * FROM v_eanl WHERE anlage = wa_hilf-anlage
                                      AND ab    = wa_hilf-datum.

        IF sy-subrc EQ 0.
*         icn_key
          MOVE v_eanl-anlage TO icn_key-anlage.
          APPEND icn_key.
          CLEAR icn_key.
*         icn_data
          MOVE-CORRESPONDING v_eanl TO icn_data.

          APPEND icn_data.
          CLEAR  icn_data.

*         icn_rcat
          MOVE-CORRESPONDING v_eanl TO icn_rcat.
          APPEND icn_rcat.
          CLEAR  icn_rcat.

        ELSE.
          meldung-meldung =
           'Anlagen-Zeitscheibe nicht in Tabelle V_EANL gefunden'.
          APPEND meldung.
          RAISE wrong_data.
        ENDIF.
      ENDIF.

*>> Wegschreiben des Objektschlüssels in Entlade-KSV
      CONCATENATE oldkey_icn '_' counter INTO o_key.
*    o_key = oldkey_icn.
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
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_ENT_INSTLNCH'
        CALL FUNCTION ums_fuba
          EXPORTING
            firma      = firma
          TABLES
            meldung    = meldung
            icn_key    = icn_key
            icn_data   = icn_data
            icn_rcat   = icn_rcat
          CHANGING
            oldkey_icn = oldkey_icn
          EXCEPTIONS
            no_adress  = 1
            no_key     = 2
            OTHERS     = 3.
        CASE sy-subrc.
          WHEN 1.
            RAISE no_adress.
          WHEN 2.
            RAISE no_key.
        ENDCASE.

      ENDIF.
* Sätze für Datei in interne Tabelle schreiben
      CONCATENATE oldkey_icn '_' counter INTO oldkey_datei.
*    oldkey_datei = oldkey_icn.
      PERFORM fill_icn_out USING oldkey_datei
                                 firma
                                 object
                                 anz_key
                                 anz_data
                                 anz_rcat
                                 anz_pod.
      LOOP AT icn_out INTO wicn_out.
        TRANSFER wicn_out TO ent_file.
      ENDLOOP.

    ENDLOOP.

  ENDIF.



ENDFUNCTION.
