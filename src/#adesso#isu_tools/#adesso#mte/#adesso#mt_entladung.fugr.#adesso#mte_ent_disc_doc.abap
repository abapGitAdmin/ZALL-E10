FUNCTION /adesso/mte_ent_disc_doc.
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
  DATA: o_key           TYPE  emg_oldkey.
  DATA: vkont           LIKE  fkkvk-vkont.

  object   = 'DISC_DOC'.
  ent_file = pfad_dat_ent.
  oldkey_dcd = x_ediscdoc-discno.


* interne Tabelle IFKKMAZE einmalig füllen
IF flag_maze NE 'X'.
SELECT * FROM fkkmaze INTO TABLE ifkkmaze
                    WHERE discno NE space
                      AND xmsus  EQ space
                      AND xmsto  EQ space
                      AND xinfo  EQ space.
IF sy-subrc EQ 0.
 flag_maze = 'X'.
ELSE.
    meldung-meldung =
        'Keine Daten in Tabelle FKKMAZE mit Sperrbelgnr. vorhanden'.
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
  CLEAR: idcd_out, wdcd_out, meldung, anz_obj,
         idcd_header, idcd_fkkmaz.
  REFRESH: idcd_out, meldung,
         idcd_header, idcd_fkkmaz.
*<


*> Datenermittlung ---------

* idcd_HEADER
   MOVE-CORRESPONDING x_ediscdoc TO idcd_header.
   CASE x_ediscdoc-refobjtype.
    WHEN 'ISUACCOUNT'.
     MOVE x_ediscdoc-refobjkey(12) TO idcd_header-vkonto.

* prüfen, ob zum Vertragskonto überhaupt ein gültiger
* Vertrag existiert.
     CLEAR vkont.
     MOVE x_ediscdoc-refobjkey(12) TO vkont.
     SELECT SINGLE * FROM ever WHERE vkonto = vkont
                                 AND auszdat = '99991231'.
     IF sy-subrc NE 0.
      WRITE: / x_ediscdoc-discno,
               'kein gültiger Vertrag zu VKonto', vkont.

      EXIT.
     ENDIF.

    WHEN 'DEVICE'.
     MOVE x_ediscdoc-refobjkey TO idcd_header-equnr.

    WHEN 'INSTLN'.
     MOVE x_ediscdoc-refobjkey TO idcd_header-anlage.

    WHEN OTHERS.

   ENDCASE.

   APPEND idcd_header.
   CLEAR idcd_header.


*idcd_FKKMAZ
*select * from fkkmaze where DISCNO = X_EDISCDOC-discno.
LOOP AT ifkkmaze WHERE discno = x_ediscdoc-discno.
 MOVE-CORRESPONDING ifkkmaze TO idcd_fkkmaz.
 APPEND idcd_fkkmaz.
 CLEAR idcd_fkkmaz.
ENDLOOP.
*endselect.
*>-------------------------------------------------------
IF sy-subrc NE 0 AND
   x_ediscdoc-discreason = '01'. "Vertragskontobezug

      WRITE: / x_ediscdoc-discno,
               'kein gültiger Satz in Mahnhistorie -> ausgesteuert'.
 EXIT.
ENDIF.
*<-------------------------------------------------------


*sort idcd_FKKMAZ by

*< Datenermittlung ---------


*>> Wegschreiben des Objektschlüssels in Entlade-KSV
  o_key = oldkey_dcd.
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
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_ENT_DISC_DOC'
          CALL FUNCTION ums_fuba
              EXPORTING
                   firma       = firma
               TABLES
                    meldung     = meldung
                    idcd_header  = idcd_header
                    idcd_fkkmaz  = idcd_fkkmaz
               CHANGING
                    oldkey_dcd  = oldkey_dcd.
        ENDIF.



* Sätze für Datei in interne Tabelle schreiben
  PERFORM fill_idcd_out USING oldkey_dcd
                              firma
                              object.

  LOOP AT idcd_out INTO wdcd_out.
    TRANSFER wdcd_out TO ent_file.
  ENDLOOP.


ENDFUNCTION.
