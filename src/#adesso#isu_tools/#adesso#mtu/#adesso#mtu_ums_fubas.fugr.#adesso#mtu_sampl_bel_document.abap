FUNCTION /ADESSO/MTU_SAMPL_BEL_DOCUMENT.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IDOC_KO STRUCTURE  FKKKO OPTIONAL
*"      IDOC_OP STRUCTURE  FKKOP OPTIONAL
*"      IDOC_OPK STRUCTURE  FKKOPK OPTIONAL
*"      IDOC_OPL STRUCTURE  FKKOPL OPTIONAL
*"      IDOC_ADDINF STRUCTURE  EMIG_DOC_ADDINFO OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_DOC) TYPE  EMG_OLDKEY
*"----------------------------------------------------------------------

  DATA: lidoc_opl LIKE TABLE OF fkkopl WITH HEADER LINE.
* SAMPLE-Baustein zur Umschlüsselung der offenen Posten
  DATA: litemksv LIKE TABLE OF temksv WITH HEADER LINE,
        oldkey LIKE temksv-oldkey.
  DATA: lwatfk033d LIKE tfk033d.

* Tabelle einlesen
  IF filled_mwst IS INITIAL.
    SELECT * INTO TABLE iums_mwst
             FROM /adesso/mtu_mwst.
    filled_mwst = 'X'.
    SORT iums_mwst.
  ENDIF.
* Tabelle einlesen
  IF filled_hv IS INITIAL.
    SELECT * INTO TABLE iums_hv
             FROM /adesso/mtu_hvtv.
    filled_hv = 'X'.
    SORT iums_hv.
  ENDIF.


* Hauptbuchpostionen zurücksetzen
* diese werden nachher neu aufgebaut.
  CLEAR : idoc_opk, idoc_opk[].
  lidoc_opl[] = idoc_opl[].
  CLEAR : idoc_opl, idoc_opl[].

* Abstimmschlüssel generieren
  READ TABLE idoc_ko INDEX 1.
  CONCATENATE 'DOC' sy-datum '1' INTO idoc_ko-fikey.
  idoc_ko-budat = sy-datum.
  MODIFY idoc_ko INDEX 1.

  LOOP AT idoc_op.
    CLEAR: litemksv, litemksv[].
    IF NOT idoc_op-vtref IS INITIAL.
      CONCATENATE idoc_op-vtref '%' INTO oldkey.
      SELECT * FROM temksv INTO TABLE litemksv
                    WHERE firma = 'EVU01'
                    AND   object = 'MOVE_IN'
                    AND   oldkey LIKE oldkey.
      DESCRIBE TABLE litemksv LINES sy-tfill.
      SORT litemksv BY oldkey.
      CASE sy-tfill.
        WHEN '0'.
          CONCATENATE 'Kein Vertrag für alten Vertrag gefunden'
          idoc_op-vtref INTO meldung-meldung.
          APPEND meldung.
          CLEAR idoc_op-vtref.
       SELECT SINGLE opbuk kofiz_sd INTO (idoc_op-bukrs, idoc_op-kofiz)
                                 FROM fkkvkp
                                 WHERE gpart = idoc_op-gpart
                                 AND   vkont = idoc_op-vkont.
        WHEN 1.
          READ TABLE litemksv INDEX 1.
          idoc_op-vtref = litemksv-newkey.
          SELECT SINGLE bukrs kofiz INTO (idoc_op-bukrs, idoc_op-kofiz)
                             FROM ever
                             WHERE vertrag = litemksv-newkey.
        WHEN 2.
          READ TABLE litemksv INDEX 2.
          idoc_op-vtref = litemksv-newkey.
          SELECT SINGLE bukrs kofiz INTO (idoc_op-bukrs, idoc_op-kofiz)
                             FROM ever
                             WHERE vertrag = litemksv-newkey.
      ENDCASE.
    ELSE.
      SELECT SINGLE opbuk kofiz_sd INTO (idoc_op-bukrs, idoc_op-kofiz)
                          FROM fkkvkp
                          WHERE gpart = idoc_op-gpart
                          AND   vkont = idoc_op-vkont.
    ENDIF.
    IF idoc_op-betrw < 0.
      idoc_op-tvorg = '0010'.
    ELSE.
      idoc_op-tvorg = '0020'.
    ENDIF.

    IF NOT idoc_op-mwskz IS INITIAL.
      ikey_mwst-mandt = sy-mandt.
      ikey_mwst-bukrs = bukrs_v.
      ikey_mwst-mwskz_alt = idoc_op-mwskz.
*
* Umschlüsselung
      READ TABLE iums_mwst WITH KEY ikey_mwst BINARY SEARCH.
      IF sy-subrc = 0.
        idoc_op-mwskz = iums_mwst-mwstk_neu.
      ELSE.
        CONCATENATE 'Fehler bei MWST-Umschlüsselung,'
                    '(Umschl-Key:'
                    ikey_mwst-bukrs
                    ikey_mwst-mwskz_alt ')'
                    INTO meldung-meldung SEPARATED BY space.
        APPEND meldung.
      ENDIF.
    ENDIF.
    READ TABLE iums_hv WITH KEY hvorg_alt = idoc_op-hvorg BINARY SEARCH.
    IF sy-subrc = 0.
      idoc_op-hvorg = iums_hv-hvorg_neu.
    ELSE.
      CONCATENATE 'Fehler bei HVORG-Umschlüsselung,'
                  '(Umschl-Key:'
                  idoc_op-bukrs
                  idoc_op-hvorg ')'
                  'Beleg alt' oldkey_doc
                  INTO meldung-meldung SEPARATED BY space.
      APPEND meldung.
    ENDIF.
    lwatfk033d-buber = 'R000'.
    lwatfk033d-ktopl = 'GKV'.
    lwatfk033d-key01 = idoc_op-bukrs.
    lwatfk033d-key02 = idoc_op-spart.
    lwatfk033d-key03 = idoc_op-kofiz.
    lwatfk033d-key04 = idoc_op-hvorg.
    lwatfk033d-key05 = space.
    CALL FUNCTION 'FKK_ACCOUNT_DETERMINE'
      EXPORTING
        i_tfk033d                 = lwatfk033d
*                     I_DO_NOT_USE_BUFFER       = ' '
*                     I_ONLY_SIMULATION         = ' '
     IMPORTING
       e_tfk033d                 = lwatfk033d
     EXCEPTIONS
*                     ERROR_IN_INPUT_DATA       = 1
*                     NOTHING_FOUND             = 2
       OTHERS                    = 3
              .

    IF sy-subrc <> 0.
      CONCATENATE 'Fehler bei Kontenfindung' idoc_op-bukrs
      idoc_op-spart idoc_op-kofiz idoc_op-hvorg
                  'Beleg alt' oldkey_doc
      INTO meldung-meldung SEPARATED BY space.
      APPEND meldung.
    ELSE.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
           EXPORTING
                input  = lwatfk033d-fun01
           IMPORTING
                output = idoc_op-hkont.

    ENDIF.
    MODIFY idoc_op.

    MOVE-CORRESPONDING idoc_op TO idoc_opk.
    idoc_opk-betrw = idoc_opk-betrw * -1.
    IF idoc_opk-bukrs+3(1) = '1'.
      idoc_opk-hkont = '0076990200'.
    ELSE.
      idoc_opk-hkont = '0076990100'.
    ENDIF.
    APPEND idoc_opk.
    LOOP AT lidoc_opl WHERE opbel = idoc_op-opbel
                      AND   opupk = idoc_op-opupk
                      AND   opupw = idoc_op-opupw.
      APPEND lidoc_opl TO idoc_opl.
    ENDLOOP.
  ENDLOOP.


*  LOOP AT idoc_opk.
*    IF NOT idoc_opk-mwskz IS INITIAL.
*      ikey_mwst-mandt = sy-mandt.
*      ikey_mwst-bukrs = bukrs_v.
*      ikey_mwst-mwskz_alt = idoc_opk-mwskz.
**
** Umschlüsselung
*      READ TABLE iums_mwst WITH KEY ikey_mwst BINARY SEARCH.
*      IF sy-subrc = 0.
*        idoc_opk-mwskz = iums_mwst-mwstk_neu.
*      ELSE.
*        CONCATENATE 'Fehler bei MWST-Umschlüsselung,'
*                    '(Umschl-Key:'
*                    ikey_mwst-bukrs
*                    ikey_mwst-mwskz_alt ')'
*                    INTO meldung-meldung SEPARATED BY space.
*        APPEND meldung.
*      ENDIF.
*    ENDIF.
*    idoc_opk-hkont = '0076995000'.
*    MODIFY idoc_opk.
*  ENDLOOP.
ENDFUNCTION.
