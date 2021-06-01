FUNCTION /ADESSO/MTE_ENT_DUNNING.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(X_GPART) TYPE  FKKMAKO-GPART
*"     REFERENCE(PFAD_DAT_ENT) TYPE  EMG_PFAD
*"  EXPORTING
*"     REFERENCE(ANZ_OBJ) TYPE  I
*"     REFERENCE(ANZ_KEY) TYPE  I
*"     REFERENCE(ANZ_FKKMA) TYPE  I
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"  EXCEPTIONS
*"      NO_OPEN
*"      NO_CLOSE
*"      WRONG_DATA
*"      NO_DATA
*"      ERROR
*"----------------------------------------------------------------------
DATA  object          TYPE  emg_object.
  DATA  ent_file        TYPE  emg_pfad.
  DATA: ums_fuba        TYPE  funcname.
  DATA: o_key           TYPE  emg_oldkey.
  DATA: counter(1)      TYPE  n.



  object     = 'DUNNING'.
  ent_file   = pfad_dat_ent.

  DATA: ifkkmako TYPE fkkmako OCCURS 0 WITH HEADER LINE.
  DATA: ifkkmaze TYPE fkkmaze OCCURS 0 WITH HEADER LINE.

  oldkey_dun = x_gpart.
*
* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.


*> Initialisierung
  PERFORM init_dun.
  CLEAR: idun_out, wdun_out, meldung, anz_obj.
  REFRESH: idun_out, meldung.

*> Datenermittlung
* Alle Mahnhistoriköpfe zum Geschäftspartner selektieren, die nicht storniert sind
  CLEAR ifkkmako.
  REFRESH ifkkmako.
  SELECT * FROM fkkmako INTO TABLE ifkkmako
       WHERE gpart = x_gpart
         AND xmsto NE 'X'.

  CLEAR counter.
  LOOP AT ifkkmako.

    CLEAR: idun_out, wdun_out.
    REFRESH idun_out.

    counter = counter + 1.

    MOVE-CORRESPONDING ifkkmako TO idun_key.
    APPEND idun_key.
    CLEAR idun_key.

    CLEAR ifkkmaze.
    REFRESH ifkkmaze.

    SELECT * FROM fkkmaze INTO TABLE ifkkmaze
      WHERE laufd = ifkkmako-laufd
        AND laufi = ifkkmako-laufi
        AND gpart = ifkkmako-gpart
      AND xmsto NE 'X'.

    LOOP AT ifkkmaze.
      MOVE-CORRESPONDING ifkkmaze TO idun_fkkma.
      MOVE ifkkmaze-mbetm TO idun_fkkma-betrw.
      APPEND idun_fkkma.
      CLEAR idun_fkkma.
    ENDLOOP.
***< Datenermittlung

**>> Wegschreiben des Objektschlüssels in Entlade-KSV
    CONCATENATE oldkey_dun '_' counter INTO o_key.

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
**<< Wegschreiben des Objektschlüssels in Entlade-KSV

    ADD 1 TO anz_obj.

* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
    IF NOT ums_fuba IS INITIAL.
*   CALL FUNCTION '/ADESSO/MTU_SAMPLE_ENT_PARTNER'
      CALL FUNCTION ums_fuba
        EXPORTING
          firma      = firma
        TABLES
          meldung    = meldung
          idun_key   = idun_key
          idun_fkkma = idun_fkkma
        CHANGING
          oldkey_dun = oldkey_dun.
    ENDIF.

* Sätze für Datei in interne Tabelle schreiben
    PERFORM fill_dun_out USING o_key
                               firma
                               object
                               anz_key
                               anz_fkkma.

    LOOP AT idun_out INTO wdun_out.
      TRANSFER wdun_out TO ent_file.
    ENDLOOP.
  ENDLOOP.





ENDFUNCTION.
