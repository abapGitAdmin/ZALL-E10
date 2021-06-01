FUNCTION /ADESSO/MTE_ENT_DISC_RCORD.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(X_EDISCDOC) LIKE  EDISCDOC STRUCTURE  EDISCDOC
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
  data: o_key           TYPE  EMG_OLDKEY.
  data: vkont           like fkkvk-vkont.

  object   = 'DISC_RCORD'.
  ent_file = pfad_dat_ent.
  oldkey_dcr = X_EDISCDOC-DISCNO.



* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.


*>   Initialisierung
  CLEAR: idcr_out, wdcr_out, meldung, ANZ_OBJ,
         idcr_HEADER.
  REFRESH: idcr_out, meldung,
         idcr_HEADER.
*<


*> Datenermittlung ---------

* idcr_HEADER
* prüfen, ob es einen Sperrauftrag gibt:
clear ediscact.

select single * from ediscact
 where  discno = oldkey_dcr
 and DISCACTTYP = '03' "Wiederinbetriebnahmeauftrag
 and neworder = ' '
 and DISCCANCELD = ' '.

 if sy-subrc <> 0.
  exit.
 endif.

   move-corresponding X_EDISCDOC to idcr_HEADER.
   move ediscact-ACTDATE to idcr_HEADER-AB.
   move ediscact-ACTTIME to idcr_HEADER-AB_TIME.
   case X_EDISCDOC-REFOBJTYPE.
    when 'ISUACCOUNT'.
     move X_EDISCDOC-REFOBJKEY(12) to idcr_HEADER-vkonto.

* prüfen, ob zum Vertragskonto überhaupt ein gültiger
* Vertrag existiert.
     clear vkont.
     move X_EDISCDOC-REFOBJKEY(12) to vkont.
     select single * from ever where vkonto = vkont
                                 and auszdat = '99991231'.
     if sy-subrc ne 0.
      write: / X_EDISCDOC-DISCNO,
               'kein gültiger Vertrag zu VKonto', vkont.

      exit.
     endif.

    when 'DEVICE'.
     move X_EDISCDOC-REFOBJKEY to idcr_HEADER-equnr.

    when 'INSTLN'.
     move X_EDISCDOC-REFOBJKEY to idcr_HEADER-anlage.

    when others.

   endcase.

   append idcr_HEADER.
   clear idcr_HEADER.


**< Datenermittlung ---------
*
*
**>> Wegschreiben des Objektschlüssels in Entlade-KSV
  o_key = oldkey_dcr.
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



  add 1 to anz_obj.

* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
        IF NOT ums_fuba IS INITIAL.
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_ENT_DISC_RCO'
          CALL FUNCTION ums_fuba
              EXPORTING
                   firma       = firma
               TABLES
                    meldung     = meldung
                    idcr_HEADER  = idcr_HEADER
               CHANGING
                    oldkey_dcr  = oldkey_dcr.
        ENDIF.



* Sätze für Datei in interne Tabelle schreiben
  PERFORM fill_idcr_out USING oldkey_dcr
                              firma
                              object.



  LOOP AT idcr_out INTO wdcr_out.
    TRANSFER wdcr_out TO ent_file.
  ENDLOOP.






ENDFUNCTION.
