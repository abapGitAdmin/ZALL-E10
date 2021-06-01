FUNCTION /ADESSO/MTE_ENT_PAYMENT.
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
* alle Belegzeilen lesen, auf denen Zahlungen erfolgt sind
  LOOP AT iobj-ieabps INTO wa_eabps
      WHERE augbl <> ' ' AND betrw <> 0.
* Prüfen ob es sich um einen BKA Vertrag handelt
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
      counter = counter + 1.

      IF counter EQ 1.
*      ipay_FKKKO
        ipay_fkkko-applk = 'R'.
*        ipay_fkkko-augrd = '01'. "Einzahlung
        ipay_fkkko-blart = 'XZ'. "Zahlung Migration
*        ipay_fkkko-bldat = sy-datum.  raus
         ipay_fkkko-bldat = wa_eabps-bldat. "neu
*        ipay_fkkko-budat = sy-datum.  raus
*    i pay_FKKKO-FIKEY
        ipay_fkkko-augrd = wa_eabps-augrd. "neu
        ipay_fkkko-herkf = 'RZ'. "IS-U Migr. Zahlungen
        ipay_fkkko-oibel = wa_eabps-opbel.
        ipay_fkkko-xblnr = wa_eabps-augbl. "neu
        ipay_fkkko-waers = 'EUR'.

        select single * from dfkkko
                      where opbel = wa_eabps-opbel.
           if sy-subrc = 0.
           move: dfkkko-aginf to ipay_fkkko-aginf,
                 dfkkko-bltyp to ipay_fkkko-bltyp.

           else.
           endif.
        APPEND ipay_fkkko.
        CLEAR  ipay_fkkko.

* ipay_FKKOPK
        ipay_fkkopk-bukrs = wa_eabps-bukrs.
*> !!! HKONT muß umgeschlüsselt werden !!!
        ipay_fkkopk-hkont = wa_eabps-hkont. " <- FALSCH !!!!
*< muß noch zum Migrations-HKONT umgeschlüsselt werden !!!!!!!
        ipay_fkkopk-opupk = wa_eabps-opupk.
*        ipay_fkkopk-valut = wa_eabps-augdt.
*
      ENDIF.
      ipay_fkkopk-betrw = ipay_fkkopk-betrw + wa_eabps-betrw  "Gesamtford.
                                                         - wa_eabps-betro.
* ipay_SELTNS
      CLEAR ipay_seltns.
      ipay_seltns-augrd = wa_eabps-augrd.
      ipay_seltns-betrw = wa_eabps-betrw - wa_eabps-betro.
      ipay_seltns-fiedn = wa_eabps-faedn.
      ipay_seltns-giart = wa_eabps-gpart.
      ipay_seltns-oibel = wa_eabps-opbel.
*     ipay_seltns-oibel = wa_eabps-augbl.
      ipay_seltns-viont = wa_eabps-vkont.
      ipay_seltns-viref = wa_eabps-vtref.
      ipay_seltns-waers = wa_eabps-waers.
      APPEND ipay_seltns.
      CLEAR  ipay_seltns.
    ENDIF.
  ENDLOOP.

  IF sy-subrc EQ 0.
* JVL Ausgleiche abziehen
    LOOP AT iobj-iejvls INTO wa_ejvls WHERE ( augrd = '01'
                                              OR augrd = '08' )
                                      AND   hvorg = '0045'
                                      AND   tvorg = '0030'.
      CLEAR lv_ever.
      SELECT SINGLE * FROM ever INTO lv_ever
                    WHERE vertrag = wa_ejvls-vtref+10(10).

        SELECT SINGLE *
             FROM /adesso/mte_rel
             WHERE firma = firma
               AND object = 'MOVE_IN'
               AND obj_key = wa_eabps-vtref+10(10).
        lv_subrc = sy-subrc.

      IF lv_subrc = 0.
        ipay_fkkopk-betrw = ipay_fkkopk-betrw + wa_ejvls-betrw.
      ENDIF.
    ENDLOOP.
    APPEND ipay_fkkopk.
    CLEAR  ipay_fkkopk.
  ELSE.
    CONCATENATE
         ' Vertragskonto '
         wa_eabps-vkont
         ' keine Abschlags-Zahlungen vorhanden'
     INTO meldung-meldung.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.

*< Datenermittlung ---------

*>> Wegschreiben des Objektschlüssels in Entlade-KSV
  o_key = oldkey_pay.
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
  PERFORM fill_pay_out USING oldkey_pay
                            firma
                             object.

  LOOP AT ipay_out INTO wpay_out.
    TRANSFER wpay_out TO ent_file.
  ENDLOOP.





ENDFUNCTION.
