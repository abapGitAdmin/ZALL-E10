FUNCTION /ADESSO/MTE_ENT_ADRSTREET.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(X_STRT_CODE) TYPE  ADRSTREETD-STRT_CODE
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
TABLES: adrstreet, adrstreett, adrstrpcd.

  DATA  object          TYPE  emg_object.
  DATA  ent_file        TYPE  emg_pfad.
  DATA: ums_fuba        TYPE  funcname.
  DATA: o_key           TYPE  emg_oldkey.


  DATA: icon_co_pcd LIKE /adesso/mt_adrstrpcd OCCURS 0 WITH HEADER LINE.
  DATA: icon_co_str LIKE /adesso/mt_adrstreet OCCURS 0 WITH HEADER LINE.
  DATA: oldkey_reg LIKE adrstreet-strt_code.

  DATA: istr_out LIKE TABLE OF /adesso/mt_transfer,
        wstr_out LIKE /adesso/mt_transfer.

  object     = 'ADRSTREET'.
  ent_file   = pfad_dat_ent.
  oldkey_reg = x_strt_code.


* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'BEL'.

*>   Initialisierung
  CLEAR: istr_out, wstr_out, meldung, anz_obj, icon_co_str, icon_co_pcd.
  REFRESH: istr_out, meldung, icon_co_str, icon_co_pcd.
*<

*> Datenermittlung ---------
  SELECT SINGLE * FROM adrstreet
         WHERE country EQ 'DE' AND
               strt_code = oldkey_reg.
  IF sy-subrc NE 0.
    meldung-meldung = 'Keine Strasse gefunden!'.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.

*icon_co_str
  SELECT SINGLE * FROM adrstreett
                  WHERE strt_code  = adrstreet-strt_code.
  IF sy-subrc EQ 0.
    MOVE-CORRESPONDING adrstreett TO icon_co_str.
  ENDIF.

  SELECT SINGLE * FROM  adrstrpcd
                    WHERE strt_code  = adrstreet-strt_code.
  IF sy-subrc EQ 0.
    MOVE-CORRESPONDING adrstrpcd TO icon_co_str.
  ENDIF.

  MOVE-CORRESPONDING adrstreet  TO icon_co_str.

  APPEND icon_co_str.
  CLEAR  icon_co_str.





  SELECT SINGLE * FROM  adrstrpcd
                  WHERE strt_code  = adrstreet-strt_code.
  IF sy-subrc EQ 0.
    MOVE-CORRESPONDING adrstrpcd TO icon_co_pcd.
  ENDIF.

  SELECT SINGLE * FROM adrstreet
                  WHERE strt_code  = adrstreet-strt_code.
  IF sy-subrc EQ 0.
    MOVE-CORRESPONDING adrstreet TO icon_co_pcd.
  ENDIF.
  MOVE-CORRESPONDING adrstrpcd TO icon_co_pcd.
  APPEND icon_co_pcd.
  CLEAR  icon_co_pcd.


*< Datenermittlung ---------
*>> Wegschreiben des Objektschlüssels in Entlade-KSV
  o_key = oldkey_reg.
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
    CALL FUNCTION ums_fuba
      EXPORTING
        firma       = firma
      TABLES
        meldung     = meldung
        icon_co_str = icon_co_str
        icon_co_pcd = icon_co_pcd
      CHANGING
        oldkey_reg  = oldkey_reg.
  ENDIF.

* Sätze für Datei in interne Tabelle schreiben
*  PERFORM fill_icon_out USING oldkey_con
*                              firma
*                              object.

  LOOP AT icon_co_str.
    wstr_out-firma  = firma.
    wstr_out-object = object.
*  wstr_out-dttyp  = 'CO_STR'.
    wstr_out-dttyp  = 'STREET'.
*  wcon_out-oldkey = oldkey.
    wstr_out-oldkey = oldkey_reg.
*  wstr_out-data   = Icon_CO_str.
    wstr_out-data   = icon_co_str.
    APPEND wstr_out TO istr_out.
  ENDLOOP.

  LOOP AT icon_co_pcd.
    wstr_out-firma  = firma.
    wstr_out-object = object.
*  wstr_out-dttyp  = 'CO_PCD'.
    wstr_out-dttyp  = 'STRSEC'.
*  wcon_out-oldkey = coldkey.
    wstr_out-oldkey = oldkey_reg.
*  wstr_out-data   = Icon_CO_PCD.
    wstr_out-data   = icon_co_pcd.
    APPEND wstr_out TO istr_out.
  ENDLOOP.
* initialisieren der Tabellen je Altsystemschlüssel
*perform init_con.
  CLEAR:  icon_co_str,
          icon_co_pcd.

  REFRESH: icon_co_str,
           icon_co_pcd.

  LOOP AT istr_out INTO wstr_out.
    TRANSFER wstr_out TO ent_file.
  ENDLOOP.


ENDFUNCTION.
