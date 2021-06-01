FUNCTION /adesso/mte_ent_devgrp.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(X_DEVGRP) LIKE  EDEVGR-DEVGRP
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
  DATA: d_equnr         LIKE  /adesso/mte_rel-obj_key.




  object   = 'DEVGRP'.
  ent_file = pfad_dat_ent.
  oldkey_dgr = x_devgrp.


* interne Tabelle iegerh einmalig füllen
IF flag_egerh NE 'X'.
SELECT * FROM egerh INTO TABLE iegerh
                    WHERE devgrp NE space
                      AND devloc NE space
                      AND bis    EQ '99991231'.
IF sy-subrc EQ 0.
 flag_egerh = 'X'.
ELSE.
    meldung-meldung =
        'Keine Daten in Tabelle EGERH mit Gruppierung vorhanden'.
    APPEND meldung.
    RAISE error.
ENDIF.

ENDIF.





* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.


*>   Initialisierung
  PERFORM init_dgr.
  CLEAR: idgr_out, wdgr_out, meldung, anz_obj.
  REFRESH: idgr_out, meldung.
*<


*> Datenermittlung ---------

SELECT SINGLE * FROM edevgr WHERE devgrp = x_devgrp
                              AND loevm  EQ space.

IF sy-subrc NE 0.
    meldung-meldung =
        'keinen gültigen Satz in Tabelle EDEVGR gefunden'.
    APPEND meldung.
    RAISE error.
ENDIF.

*idgr_DEVICE
LOOP AT iegerh WHERE devgrp EQ x_devgrp.
 MOVE-CORRESPONDING iegerh TO idgr_device.
 APPEND idgr_device.
 CLEAR idgr_device.
ENDLOOP.
IF sy-subrc NE 0.
    meldung-meldung =
        'keinen gültigen Satz in Tabelle EGERH gefunden'.
    APPEND meldung.
    RAISE error.
ENDIF.

* überprüfen, ob Geräte überhaupt in Relevanztabelle
LOOP AT idgr_device.
 d_equnr = idgr_device-equnr.
 SELECT SINGLE * FROM /adesso/mte_rel
                     WHERE firma  EQ firma
                       AND object  = 'DEVICE'
                       AND obj_key = d_equnr.

* if sy-subrc ne 0.
** dann in der gesicherten Relavanztabelle gucken
*  select single * from /adesso/mte_rels
*                     where firma  eq firma
*                       and OBJECT  = 'DEVICE'
*                       and obj_key = d_equnr.
  IF sy-subrc NE 0.
   WRITE: / 'Gerät', d_equnr, 'nicht in Relevanzermittlung'.
   DELETE idgr_device.
  ENDIF.
* endif.
ENDLOOP.

* ist überhaupt noch ein Gerät zum Gruppieren vorhanden?
READ TABLE idgr_device INDEX 1.
 IF sy-subrc NE 0.
  meldung-meldung =
         'keine Geräte (mehr) für Gruppierung vorhanden'.
    APPEND meldung.
    RAISE error.
 ENDIF.


*idgr_EDEVGR
idgr_edevgr-action = ' '.
idgr_edevgr-devgrp = edevgr-devgrp.
idgr_edevgr-devgrptyp = edevgr-devgrptyp.
*idgr_EDEVGR-keydate = sy-datum.
  idgr_edevgr-keydate = iegerh-ab.

idgr_edevgr-prorate = ' '.
APPEND idgr_edevgr.
CLEAR idgr_edevgr.

*< Datenermittlung ---------


*>> Wegschreiben des Objektschlüssels in Entlade-KSV
  o_key = oldkey_dgr.
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
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_ENT_DEVGRP'
          CALL FUNCTION ums_fuba
              EXPORTING
                   firma       = firma
               TABLES
                    meldung     = meldung
                    idgr_edevgr  = idgr_edevgr
                    idgr_device  = idgr_device
               CHANGING
                    oldkey_dgr  = oldkey_dgr.
        ENDIF.



* Sätze für Datei in interne Tabelle schreiben
  PERFORM fill_idgr_out USING oldkey_dgr
                              firma
                              object.



  LOOP AT idgr_out INTO wdgr_out.
    TRANSFER wdgr_out TO ent_file.
  ENDLOOP.


ENDFUNCTION.
