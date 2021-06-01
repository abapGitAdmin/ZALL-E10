FUNCTION /adesso/mtb_bel_account.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(PFAD_DAT_ENT) TYPE  EMG_PFAD
*"     REFERENCE(PFAD_DAT_BEL) TYPE  EMG_PFAD
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
  DATA  bel_file        TYPE  emg_pfad.
  DATA  ent_file        TYPE  emg_pfad.
  DATA  rep_name        TYPE  programm.
  DATA  form_name       TYPE  text30.
  DATA  syn_fehler      TYPE  text60.
  DATA: itrans          LIKE  /adesso/mt_transfer.
  DATA: idttyp          TYPE  emg_dttyp.
  DATA: ums_fuba        TYPE  funcname.

  object   = 'ACCOUNT'.
  bel_file = pfad_dat_bel.
  ent_file = pfad_dat_ent.
  idttyp   = 'INIT'.

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
* open Dataset
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

*   Migrationsfirma prüfen.
      IF itrans-firma NE firma.
        CONCATENATE 'Falsche Migrationsfirma:'
                     itrans-firma
          INTO meldung-meldung SEPARATED BY space.
        APPEND meldung.
        RAISE wrong_data.
      ENDIF.

* Daten werden um einen Altsystemschlüssel verzögert aufgebaut, weil
* erstmal alle Strukturtabellen für den Umschlüsselungs-FUBA ermittelt
* werden müssen (siehe: case itrans-dttyp).
      IF itrans-oldkey NE oldkey_acc AND
            oldkey_acc NE space.

* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
        IF NOT ums_fuba IS INITIAL.
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_BEL_ACCOUNT'
          CALL FUNCTION ums_fuba
               EXPORTING
                    firma          = firma
               TABLES
                    meldung        = meldung
                    iacc_init      = iacc_init
                    iacc_vk        = iacc_vk
                    iacc_vkp       = iacc_vkp
                    iacc_vklock    = iacc_vklock
                    iacc_vkcorr    = iacc_vkcorr
                    iacc_vktxex    = iacc_vktxex
               CHANGING
                    oldkey_acc = oldkey_acc.
        ENDIF.


*  Dateiaufbereitung zum erstellen der Workbench-Dateien
        PERFORM aufbereitung_dat_acc USING oldkey_acc
                                           rep_name
                                           form_name.
        anz_obj = anz_obj + 1.

      ENDIF.

* füllen der entsprechenden internern Tabellen je Altsystemschlüssel zum
* bearbeiten im Umschlüsselung-FUBA und später zur Aufbereitung der
* Migrationsdaten
* => je Datentyp eigene Tabelle
      CASE itrans-dttyp.
        WHEN 'INIT'.
          CLEAR x_iacc_init.
          MOVE itrans-data TO x_iacc_init.
          MOVE-CORRESPONDING  x_iacc_init  TO iacc_init.
          APPEND iacc_init.
          CLEAR iacc_init.
        WHEN 'VK'.
          CLEAR x_iacc_vk.
          MOVE itrans-data TO x_iacc_vk.
          MOVE-CORRESPONDING  x_iacc_vk  TO iacc_vk.
          APPEND iacc_vk.
          CLEAR iacc_vk.
        WHEN 'VKP'.
          CLEAR x_iacc_vkp.
          MOVE itrans-data TO x_iacc_vkp.
          MOVE-CORRESPONDING  x_iacc_vkp  TO iacc_vkp.
          APPEND iacc_vkp.
          CLEAR iacc_vkp.
        WHEN 'VKLOCK'.
          CLEAR x_iacc_vklock.
          MOVE itrans-data TO x_iacc_vklock.
          MOVE-CORRESPONDING  x_iacc_vklock  TO iacc_vklock.
* ------- Aktuelle Sperren wieder in die MIG aufnehmen --->>>>
          IF iacc_vklock-tdate_key GE sy-datum.
            APPEND iacc_vklock.
          ENDIF.
* -------------------------------------------------------------------------<<<<
          CLEAR iacc_vklock.
        WHEN 'VKCORR'.
          CLEAR x_iacc_vkcorr.
          MOVE itrans-data TO x_iacc_vkcorr.
          MOVE-CORRESPONDING  x_iacc_vkcorr  TO iacc_vkcorr.
          APPEND iacc_vkcorr.
          CLEAR iacc_vkcorr.
        WHEN 'VKTXEX'.
          CLEAR x_iacc_vktxex.
          MOVE itrans-data TO x_iacc_vktxex.
          MOVE-CORRESPONDING  x_iacc_vktxex  TO iacc_vktxex.
          APPEND iacc_vktxex.
          CLEAR iacc_vktxex.
      ENDCASE.

      MOVE itrans-oldkey TO oldkey_acc.

    ELSE.

* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
        IF NOT ums_fuba IS INITIAL.
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_BEL_ACCOUNT'
          CALL FUNCTION ums_fuba
               EXPORTING
                    firma          = firma
               TABLES
                    meldung        = meldung
                    iacc_init      = iacc_init
                    iacc_vk        = iacc_vk
                    iacc_vkp       = iacc_vkp
                    iacc_vklock    = iacc_vklock
                    iacc_vkcorr    = iacc_vkcorr
                    iacc_vktxex    = iacc_vktxex
               CHANGING
                    oldkey_acc = oldkey_acc.
        ENDIF.


* Verarbeitung der noch fehlenden Sätze (Altsystemschlüssel)
      PERFORM aufbereitung_dat_acc USING oldkey_acc
                                         rep_name
                                         form_name.
      anz_obj = anz_obj + 1.

      EXIT.

    ENDIF.
  ENDDO.


* Erstellen der Migrationsdatei
  READ TABLE i_acc_down INDEX 1.
  IF sy-subrc NE 0.
    CONCATENATE  'Keine Datensätze für Objekt' object
                 'vorhanden bzw. erzeugt'
           INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
    RAISE error.

  ELSE.
    PERFORM erst_mig_datei TABLES i_acc_down
                            USING firma
                                  object
                                  idttyp
                                  bel_file.

    CONCATENATE  'Datei' bel_file 'wurde erzeugt'
             INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.

  ENDIF.

ENDFUNCTION.
