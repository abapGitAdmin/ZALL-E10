FUNCTION /adesso/mte_ent_bcont_note.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(X_BPCONTACT) LIKE  BCONT-BPCONTACT
*"     REFERENCE(PFAD_DAT_ENT) TYPE  EMG_PFAD
*"  EXPORTING
*"     REFERENCE(ANZ_OBJ) TYPE  I
*"     REFERENCE(ANZ_KEY) TYPE  I
*"     REFERENCE(ANZ_TLINE) TYPE  I
*"     REFERENCE(ANZ_KONV) TYPE  I
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
*  DATA: ibcont LIKE bcont OCCURS 0 WITH HEADER LINE.
  DATA: o_key           TYPE  emg_oldkey.


* Definitionen für Umschlüsselungen UNICODE - NON-UNICODE'.
  DATA: zeichen(1)  TYPE c,
        zeichen2(2) TYPE c.

  FIELD-SYMBOLS: <fs>  TYPE any,
                 <fs2> TYPE any.

  DATA:  hex1(2) TYPE x VALUE 'AC20',  "Euro
         hex2(2) TYPE x VALUE '2620',  "Auslassungspunkte
         hex3(2) TYPE x VALUE '1320',  "Gedanksenstrich, langer Bidestrich
         hex4(2) TYPE x VALUE '1E20',  "Anführungszeichen unten
         hex5(2) TYPE x VALUE '1C20',  "Anführungszeichen oben, verkehrt
         hex6(2) TYPE x VALUE '2221',  "Trademark
         hex7(2) TYPE x VALUE '7D01',   "Apostroph
         hex8(2) TYPE x VALUE '7801',   "Steuerzeichen
         hex9(2) TYPE x VALUE '2220'.   "Aufzählungszeichen

  DATA: hexa1(4) TYPE x VALUE 'C3005201',  "für 'ü'
        hexa2(4) TYPE x VALUE 'C300AC20', "für 'ä'
        hexa3(4) TYPE x VALUE 'C3003F00', "für 'ß'
        hexa4(4) TYPE x VALUE 'C300B600', "für 'ö',
        hexa5(4) TYPE x VALUE 'C3007801', "für 'ß'
        hexa6(4) TYPE x VALUE 'C3005301'. " für'Ü'

  DATA: h_oldkey TYPE emg_oldkey.


* für Text aus FUBA 'READ_TEXT'
  DATA: BEGIN OF itab_txt OCCURS 0.
          INCLUDE STRUCTURE tline.
  DATA: END OF itab_txt.


  object   = 'BCONT_NOTE'.
  ent_file = pfad_dat_ent.
  oldkey_bcn = x_bpcontact.



* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.





*>   Initialisierung
  CLEAR: ibcn_out, wbcn_out, ibcn_notkey, ibcn_notlin, meldung, anz_obj.
  REFRESH: ibcn_out, ibcn_notkey, ibcn_notlin, meldung.
*<



*> Datenermittlung ---------


* ibcn_notkey
  SELECT SINGLE * FROM stxh
     WHERE tdobject EQ 'BCONT'
       AND tdid     EQ 'BCON'
       AND tdname   EQ oldkey_bcn
       AND tdspras  EQ sy-langu.

  IF sy-subrc EQ 0.
    MOVE stxh-tdid        TO ibcn_notkey-tdid.
    MOVE stxh-tdobject    TO ibcn_notkey-tdobject.
    MOVE stxh-tdspras     TO ibcn_notkey-tdspras.
    MOVE stxh-tdname      TO ibcn_notkey-tdname.
    APPEND ibcn_notkey.
    CLEAR  ibcn_notkey.
  ELSE.
    EXIT.
  ENDIF.


* zugehörigen Text ermitteln
* ibcn_notlin
  REFRESH: itab_txt.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      client                  = sy-mandt
      id                      = stxh-tdid
      language                = stxh-tdspras
      name                    = stxh-tdname
      object                  = stxh-tdobject
    TABLES
      lines                   = itab_txt
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7.
  IF sy-subrc EQ 0.

*  Feldsymbol zuweisen mit Casting
    ASSIGN zeichen TO <fs> CASTING TYPE x.
    ASSIGN zeichen2 TO <fs2> CASTING TYPE x.

    LOOP AT itab_txt.
      MOVE-CORRESPONDING itab_txt TO ibcn_notlin.
*     wegen fehlender SAP-Unterstützung bei Konvertierung von '€'
      <fs2> = hexa1.
      REPLACE ALL OCCURENCES OF zeichen2 IN ibcn_notlin-tdline WITH 'ü'.
      <fs2> = hexa2.
      REPLACE ALL OCCURENCES OF zeichen2 IN ibcn_notlin-tdline WITH 'ä'.
      <fs2> = hexa3.
      REPLACE ALL OCCURENCES OF zeichen2 IN ibcn_notlin-tdline WITH 'ß'.
      <fs2> = hexa4.
      REPLACE ALL OCCURENCES OF zeichen2 IN ibcn_notlin-tdline WITH 'ö'.
      <fs2> = hexa5.
      REPLACE ALL OCCURENCES OF zeichen2 IN ibcn_notlin-tdline WITH 'ß'.
      <fs2> = hexa6.
      REPLACE ALL OCCURENCES OF zeichen2 IN ibcn_notlin-tdline WITH 'Ü'.

      <fs> = hex1. "Euro
      REPLACE ALL OCCURRENCES OF zeichen IN ibcn_notlin-tdline WITH 'EUR'.
      <fs> = hex2. "Auslassungspunkte
      REPLACE ALL OCCURRENCES OF zeichen IN ibcn_notlin-tdline WITH ' '.
      <fs> = hex3. "Gedankenstrich
      REPLACE ALL OCCURENCES OF zeichen IN ibcn_notlin-tdline WITH '-'.
      <fs> = hex4. "Anführungszeichen unten
      REPLACE ALL OCCURENCES OF zeichen IN ibcn_notlin-tdline WITH '"'.
      <fs> = hex5.  "Anführungszeichen oben (andersrum)
      REPLACE ALL OCCURENCES OF zeichen IN ibcn_notlin-tdline WITH '"'.
      <fs> = hex6.
      REPLACE ALL OCCURENCES OF zeichen IN ibcn_notlin-tdline WITH ' '.
*     Apostroph durch Hochkomma ersetzen
      <fs> = hex7.
      REPLACE ALL OCCURENCES OF zeichen IN ibcn_notlin-tdline WITH ''''.
*     Steuerzeichen durb Blank ersetzen
      <fs> = hex8.
      REPLACE ALL OCCURENCES OF zeichen IN ibcn_notlin-tdline WITH ' '.
*     Aufzählungszeichen durch Bindestrich ersetzen
      <fs> = hex9.
      REPLACE ALL OCCURENCES OF zeichen IN ibcn_notlin-tdline WITH '-'.
*      REPLACE ALL OCCURRENCES OF '€'
*              IN ibcn_notlin-tdline WITH '$'.
      APPEND ibcn_notlin.
      CLEAR ibcn_notlin.
    ENDLOOP.
  ENDIF.

*  IF sy-subrc EQ 0.
*    LOOP AT itab_txt.
*      MOVE-CORRESPONDING itab_txt TO ibcn_notlin.
*      APPEND ibcn_notlin.
*      CLEAR ibcn_notlin.
*    ENDLOOP.
*  ENDIF.

*< Datenermittlung ---------


*>> Wegschreiben des Objektschlüssels in Entlade-KSV
  o_key = oldkey_bcn.
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
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_ENT_BCONT_NO'
    CALL FUNCTION ums_fuba
      EXPORTING
        firma       = firma
      TABLES
        meldung     = meldung
        ibcn_notkey = ibcn_notkey
        ibcn_notlin = ibcn_notlin
      CHANGING
        oldkey_bcn  = oldkey_bcn.
  ENDIF.


* Sätze für Datei in interne Tabelle schreiben
  PERFORM fill_ibcn_out USING oldkey_bcn
                              firma
                              object
                              anz_key
                              anz_tline.

  CLEAR h_oldkey.
  LOOP AT ibcn_out INTO wbcn_out.
    CATCH SYSTEM-EXCEPTIONS convt_codepage = 4.
      TRANSFER wbcn_out TO ent_file.
    ENDCATCH.
    IF sy-subrc = 4.
      IF h_oldkey NE wbcn_out-oldkey.
        meldung-meldung = 'Fehler beim Konvertieren UNICODE - NON UNICODE'.
        ADD 1 TO anz_konv.
        APPEND meldung.
      ENDIF.
      meldung-meldung = wbcn_out-data.
      APPEND meldung.
      h_oldkey = wbcn_out-oldkey.
*      RAISE error.
    ENDIF.

  ENDLOOP.


ENDFUNCTION.
