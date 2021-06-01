FUNCTION /adesso/mte_ent_payment_xx.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(X_ABPLAN) TYPE  EABP-OPBEL
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
  DATA: iobj            TYPE isu25_budbilplan.
  DATA: iauto           TYPE isu25_budbilplan_auto.
  DATA: wa_eabps        LIKE eabps.
  DATA: wa_eabp         LIKE eabp.
  DATA: wa_ejvls        LIKE eabps.
  DATA: counter TYPE i.
  DATA: o_key           TYPE  emg_oldkey.
  DATA: lv_ever LIKE ever.
  DATA: lv_subrc LIKE sy-subrc.

  DATA: zaehler(2) TYPE n.


  DATA: lt_fkkop TYPE STANDARD TABLE OF fkkop,
        ls_fkkop TYPE fkkop,
        l_sfkkop  TYPE sfkkop.

  DATA: l_dfkkko TYPE dfkkko.

  object     = 'PAYMENT'.
  ent_file   = pfad_dat_ent.
  oldkey_pay = x_abplan.


* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.



*>   Initialisierung
  PERFORM init_pay.
  CLEAR: ipay_out, wpay_out, wa_eabps, meldung, anz_obj.
  REFRESH: ipay_out, meldung.
*<



*> Datenermittlung ---------

  SELECT SINGLE vertrag
         INTO wa_eabp-vertrag
         FROM eabp
         WHERE opbel = x_abplan.

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


  CLEAR counter.
  CLEAR zaehler.
* alle Belegzeilen lesen, auf denen Zahlungen erfolgt sind
  LOOP AT iobj-ieabps INTO wa_eabps
      WHERE augbl <> ' ' AND betrw <> 0.
    CLEAR lt_fkkop.
* Prüfen ob es sich um Vertrag relevant ist
    CLEAR lv_ever.
    SELECT SINGLE * FROM ever INTO lv_ever
                  WHERE vertrag = wa_eabps-vtref+10(10).

    SELECT SINGLE *
         FROM /adesso/mte_rel
         WHERE firma = firma
           AND object = 'MOVE_IN'
           AND obj_key = wa_eabps-vtref+10(10).
    lv_subrc = sy-subrc.

    IF lv_subrc > 0.
      CONCATENATE 'Abschl.Plan' wa_eabps-opbel
                  'beinhaltet einen nicht migrationsrelevanten Vertrag'
                   wa_eabps-vtref+10(10) INTO meldung-meldung.
      APPEND meldung.
    ELSE.

*    ipay_FKKOPK
*     Teilausgleiche
      IF wa_eabps-augbl = '*'.
        MOVE-CORRESPONDING wa_eabps TO l_sfkkop.
        CALL FUNCTION 'ISU_GET_ALL_PART_FKKOP'
          EXPORTING
            i_fkkop     = l_sfkkop
            i_obj       = iobj-fkkwh
            i_keyselect = 'Y'
          TABLES
            o_fkkop     = lt_fkkop.

        LOOP AT lt_fkkop INTO ls_fkkop
          WHERE augbl IS NOT INITIAL
            AND betrw NE 0.

          zaehler = zaehler + 1.

          CLEAR l_dfkkko.
          SELECT SINGLE * FROM dfkkko INTO l_dfkkko
              WHERE opbel = ls_fkkop-augbl.
*      ipay_FKKKO
          ipay_fkkko-applk = 'R'.

*          ipay_fkkko-blart = 'XZ'. "Zahlung Migration
          ipay_fkkko-blart  = l_dfkkko-blart.
**        --> Nuss 03.02.2016
**         Buchungs- und Belegdatum aus dem Ausgleichsbeleg
*          ipay_fkkko-bldat = ls_fkkop-bldat. "neu
*          ipay_fkkko-budat = ls_fkkop-budat.
          ipay_fkkko-bldat = ls_fkkop-augdt.
          ipay_fkkko-budat = ls_fkkop-augbd.
**       <-- Nuss 03.02.2016
*         i pay_FKKKO-FIKEY
          ipay_fkkko-augrd = ls_fkkop-augrd. "neu
          ipay_fkkko-herkf = 'RZ'. "IS-U Migr. Zahlungen
*          ipay_fkkko-herkf  = l_dfkkko-herkf.
          ipay_fkkko-oibel = ls_fkkop-opbel.
          ipay_fkkko-xblnr = ls_fkkop-augbl. "neu
          ipay_fkkko-waers = 'EUR'.

**       --> Nuss 01.02.2016
          ipay_fkkko-giart = ls_fkkop-gpart.
          ipay_fkkko-viont = ls_fkkop-vkont.
          ipay_fkkko-viref = ls_fkkop-vtref+10(10).
          ipay_fkkko-fiedn = ls_fkkop-faedn.
**      <-- Nuss 01.02.2016

          SELECT SINGLE * FROM dfkkko
                        WHERE opbel = wa_eabps-opbel.
          IF sy-subrc = 0.
            MOVE: dfkkko-aginf TO ipay_fkkko-aginf,
                  dfkkko-bltyp TO ipay_fkkko-bltyp.
          ELSE.
          ENDIF.
          APPEND ipay_fkkko.
          CLEAR  ipay_fkkko.

*    ipay_FKKOPK
          ipay_fkkopk-bukrs = ls_fkkop-bukrs.
          ipay_fkkopk-hkont = ls_fkkop-hkont.
          ipay_fkkopk-opupk = ls_fkkop-opupk.
          ipay_fkkopk-valut = ls_fkkop-augdt.
          ipay_fkkopk-betrw = ls_fkkop-betrw.
***        --> Nuss Test 22.01.2016
*          MULTIPLY ipay_fkkopk-betrw BY -1.
***        <-- Nuss Test 22.01.2016
          APPEND ipay_fkkopk.
          CLEAR ipay_fkkopk.

*    ipay_SELTNS
          CLEAR ipay_seltns.
          ipay_seltns-augrd = ls_fkkop-augrd.
          ipay_seltns-betrw = ls_fkkop-betrw.
          ipay_seltns-fiedn = ls_fkkop-faedn.
          ipay_seltns-giart = ls_fkkop-gpart.
          ipay_seltns-oibel = ls_fkkop-opbel.
*     ipay_seltns-oibel = wa_eabps-augbl.
          ipay_seltns-viont = ls_fkkop-vkont.
          ipay_seltns-viref = ls_fkkop-vtref.
          ipay_seltns-waers = ls_fkkop-waers.
          APPEND ipay_seltns.
          CLEAR  ipay_seltns.

*>> Wegschreiben des Objektschlüssels in Entlade-KSV
          CONCATENATE oldkey_pay '_' zaehler INTO o_key.
*  o_key = oldkey_pay.
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
             'Meldung bei Wegschreiben in Entlade-KSV'.
            APPEND meldung.
            RAISE error.
          ENDIF.
*<< Wegschreiben des Objektschlüssels in Entlade-KSV

* Doppelte Meldungen entfernen (z.B. abgeschlossene Verträge)
          DELETE ADJACENT DUPLICATES FROM meldung.

          ADD 1 TO anz_obj.

*        Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
          IF NOT ums_fuba IS INITIAL.
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_ENT_PAYMENT'
            CALL FUNCTION ums_fuba
              EXPORTING
                firma       = firma
              TABLES
                meldung     = meldung
                ipay_fkkko  = ipay_fkkko
                ipay_fkkopk = ipay_fkkopk
                ipay_seltns = ipay_seltns
              CHANGING
                oldkey_pay  = oldkey_pay.

          ENDIF.

* Sätze für Datei in interne Tabelle schreiben
          PERFORM fill_pay_out_neu USING  o_key
                                          firma
                                          object.


          LOOP AT ipay_out INTO wpay_out.
            TRANSFER wpay_out TO ent_file.
          ENDLOOP.

          CLEAR: ipay_out, wpay_out.
          REFRESH: ipay_out.

        ENDLOOP.

**    Eindeutiger Ausgleichsbeleg - Eine Zahlung
      ELSE.

        CLEAR l_dfkkko.
        SELECT SINGLE * FROM dfkkko INTO l_dfkkko
            WHERE opbel = wa_eabps-augbl.

        zaehler = zaehler + 1.
*
*      ipay_FKKKO
        ipay_fkkko-applk = 'R'.

*        ipay_fkkko-blart = 'XZ'. "Zahlung Migration
        ipay_fkkko-blart = l_dfkkko-blart.
**      --> Nuss 03.02.2016
**       Beleg- und Buchungsdatum aus dem Ausgleichsbeleg
*        ipay_fkkko-bldat = wa_eabps-bldat. "neu
*        ipay_fkkko-budat = wa_eabps-budat.
        ipay_fkkko-bldat = wa_eabps-augdt.
        ipay_fkkko-budat = wa_eabps-augbd.
**      <-- Nuss 03.02.2016
*    i pay_FKKKO-FIKEY
        ipay_fkkko-augrd = wa_eabps-augrd. "neu
        ipay_fkkko-herkf = 'RZ'. "IS-U Migr. Zahlungen
*        ipay_fkkko-herkf = l_dfkkko-herkf.
        ipay_fkkko-oibel = wa_eabps-opbel.
        ipay_fkkko-xblnr = wa_eabps-augbl. "neu
        ipay_fkkko-waers = 'EUR'.

**       --> Nuss 01.02.2016
        ipay_fkkko-giart = wa_eabps-gpart.
        ipay_fkkko-viont = wa_eabps-vkont.
        ipay_fkkko-viref = wa_eabps-vtref+10(10).
        ipay_fkkko-fiedn = wa_eabps-faedn.
**      <-- Nuss 01.02.2016


        SELECT SINGLE * FROM dfkkko
                      WHERE opbel = wa_eabps-opbel.
        IF sy-subrc = 0.
          MOVE: dfkkko-aginf TO ipay_fkkko-aginf,
                dfkkko-bltyp TO ipay_fkkko-bltyp.
        ELSE.
        ENDIF.
        APPEND ipay_fkkko.
        CLEAR  ipay_fkkko.

*     ipay_FKKOPK
        ipay_fkkopk-bukrs = wa_eabps-bukrs.
*> !!! HKONT muß umgeschlüsselt werden !!!
        ipay_fkkopk-hkont = wa_eabps-hkont. " <- FALSCH !!!!
*< muß noch zum Migrations-HKONT umgeschlüsselt werden !!!!!!!
        ipay_fkkopk-opupk = wa_eabps-opupk.
        ipay_fkkopk-valut = wa_eabps-augdt.
*
*        ipay_fkkopk-betrw = ipay_fkkopk-betrw + wa_eabps-betrw  "Gesamtford.
        ipay_fkkopk-betrw = wa_eabps-betrw.
***        --> Nuss Test 22.01.2016
*          MULTIPLY ipay_fkkopk-betrw BY -1.
***        <-- Nuss Test 22.01.2016
*
        APPEND ipay_fkkopk.
        CLEAR  ipay_fkkopk.
* ipay_SELTNS
        CLEAR ipay_seltns.
        ipay_seltns-augrd = wa_eabps-augrd.
        ipay_seltns-betrw = wa_eabps-betrw. " - wa_eabps-betro.
        ipay_seltns-fiedn = wa_eabps-faedn.
        ipay_seltns-giart = wa_eabps-gpart.
        ipay_seltns-oibel = wa_eabps-opbel.
        ipay_seltns-viont = wa_eabps-vkont.
        ipay_seltns-viref = wa_eabps-vtref.
        ipay_seltns-waers = wa_eabps-waers.
        APPEND ipay_seltns.
        CLEAR  ipay_seltns.

        CONCATENATE oldkey_pay '_' zaehler INTO o_key.

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
           'Meldung bei Wegschreiben in Entlade-KSV'.
          APPEND meldung.
          RAISE error.
        ENDIF.
*<< Wegschreiben des Objektschlüssels in Entlade-KSV

* Doppelte Meldungen entfernen (z.B. abgeschlossene Verträge)
        DELETE ADJACENT DUPLICATES FROM meldung.

        ADD 1 TO anz_obj.

* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
        IF NOT ums_fuba IS INITIAL.
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_ENT_PAYMENT'
          CALL FUNCTION ums_fuba
            EXPORTING
              firma       = firma
            TABLES
              meldung     = meldung
              ipay_fkkko  = ipay_fkkko
              ipay_fkkopk = ipay_fkkopk
              ipay_seltns = ipay_seltns
            CHANGING
              oldkey_pay  = oldkey_pay.


        ENDIF.

* Sätze für Datei in interne Tabelle schreiben
        PERFORM fill_pay_out_neu USING  o_key
                                        firma
                                        object.


        LOOP AT ipay_out INTO wpay_out.
          TRANSFER wpay_out TO ent_file.
        ENDLOOP.

        CLEAR: ipay_out, wpay_out.
        REFRESH: ipay_out.

      ENDIF.
    ENDIF.

  ENDLOOP.
  IF sy-subrc NE 0.

    CONCATENATE
         ' Vertragskonto '
         wa_eabps-vkont
         ' keine Abschlags-Zahlungen vorhanden'
     INTO meldung-meldung.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.

ENDFUNCTION.
