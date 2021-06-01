FUNCTION /ADESSO/MTE_ENT_DISC_ORDER.
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


  object   = 'DISC_ORDER'.
  ent_file = pfad_dat_ent.
  oldkey_dco = X_EDISCDOC-DISCNO.



* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.


*>   Initialisierung
  CLEAR: idco_out, wdco_out, meldung, ANZ_OBJ,
         idco_HEADER.
  REFRESH: idco_out, meldung,
         idco_HEADER.
*<


*> Datenermittlung ---------

* idco_HEADER
* prüfen, ob es einen Sperrauftrag gibt:
clear ediscact.

select single * from ediscact
 where  discno = oldkey_dco
 and DISCACTTYP = '01' "Sperrauftrag
 and neworder = ' '
 and DISCCANCELD = ' '.

 if sy-subrc <> 0.
  exit.
 endif.

   move-corresponding X_EDISCDOC to idco_HEADER.
   move ediscact-ACTDATE to idco_HEADER-AB.
   move ediscact-ACTTIME to idco_HEADER-AB_TIME.
   case X_EDISCDOC-REFOBJTYPE.
    when 'ISUACCOUNT'.
     move X_EDISCDOC-REFOBJKEY(12) to idco_HEADER-vkonto.

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
     move X_EDISCDOC-REFOBJKEY to idco_HEADER-equnr.

    when 'INSTLN'.
     move X_EDISCDOC-REFOBJKEY to idco_HEADER-anlage.

    when others.

   endcase.

   append idco_HEADER.
   clear idco_HEADER.


**< Datenermittlung ---------
*
*
**>> Wegschreiben des Objektschlüssels in Entlade-KSV
  o_key = oldkey_dco.
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
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_ENT_DISC_ORD'
          CALL FUNCTION ums_fuba
              EXPORTING
                   firma       = firma
               TABLES
                    meldung     = meldung
                    idco_HEADER  = idco_HEADER
               CHANGING
                    oldkey_dco  = oldkey_dco.
        ENDIF.



* Sätze für Datei in interne Tabelle schreiben
  PERFORM fill_idco_out USING oldkey_dco
                              firma
                              object.



  LOOP AT idco_out INTO wdco_out.
    TRANSFER wdco_out TO ent_file.
  ENDLOOP.







ENDFUNCTION.
