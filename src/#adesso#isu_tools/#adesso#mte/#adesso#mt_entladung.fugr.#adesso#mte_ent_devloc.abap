FUNCTION /adesso/mte_ent_devloc.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(X_DEVLOC) LIKE  EGPL-DEVLOC
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

  object   = 'DEVLOC'.
  ent_file = pfad_dat_ent.
  oldkey_dlc = x_devloc.

* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.


*>   Initialisierung
  PERFORM init_dlc.
  CLEAR: idlc_out, wdlc_out, meldung, anz_obj.
  REFRESH: idlc_out, meldung.
*<



*> Datenermittlung ---------

*idlc_egpld
  SELECT SINGLE * FROM  iflot  WHERE tplnr  = oldkey_dlc.
  IF sy-subrc EQ 0.
    MOVE-CORRESPONDING iflot TO idlc_egpld.
    MOVE iflot-tplma TO idlc_egpld-haus.
    MOVE iflot-prems TO idlc_egpld-vstelle.
  ELSE.
    meldung-meldung = 'Geräteplatz nicht in IFLOT gefunden'.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.
  SELECT SINGLE * FROM  iflotx WHERE tplnr  = oldkey_dlc.
  IF sy-subrc EQ 0.
    MOVE-CORRESPONDING iflotx TO idlc_egpld.
  ENDIF.
  SELECT SINGLE * FROM  iloa   WHERE tplnr  = oldkey_dlc.
  IF sy-subrc EQ 0.
    MOVE-CORRESPONDING iloa  TO idlc_egpld.
  ELSE.
    meldung-meldung = 'Geräteplatz nicht in ILOA gefunden'.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.
  SELECT SINGLE * FROM  egpltx WHERE devloc  = oldkey_dlc.
  IF sy-subrc EQ 0.
    MOVE-CORRESPONDING egpltx TO idlc_egpld.
  ENDIF.

  APPEND idlc_egpld.
  CLEAR  idlc_egpld.

*< Datenermittlung ---------


*>> Wegschreiben des Objektschlüssels in Entlade-KSV
  o_key = oldkey_dlc.
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
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_ENT_DEVLOC'
          CALL FUNCTION ums_fuba
               EXPORTING
                   firma       = firma
               TABLES
                    meldung     = meldung
                    idlc_egpld  = idlc_egpld
               CHANGING
                    oldkey_dlc  = oldkey_dlc.
        ENDIF.


* Sätze für Datei in interne Tabelle schreiben
  PERFORM fill_idlc_out USING oldkey_dlc
                              firma
                              object.


  LOOP AT idlc_out INTO wdlc_out.
    TRANSFER wdlc_out TO ent_file.
  ENDLOOP.





ENDFUNCTION.
