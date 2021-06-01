*&---------------------------------------------------------------------*
*&  Include           /ADESSO/MT_ENTLADUNG_WB_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  Migrationsdateien_erstellen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM migrationsdateien_erstellen.


*ACCOUNT  Vertragskonto anlegen
  IF obj_acc EQ 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'ACCOUNT'.

    PERFORM erst_entlade_files USING dat_acc.

* Schlüssel aus Relevanztabelle ermitteln
    SELECT obj_key FROM /adesso/mte_rel INTO TABLE iacc_vkont
                                  WHERE firma  = firma
                                  AND   object = 'ACCOUNT'.
    IF sy-subrc NE 0.
      SKIP.
      WRITE: /
           'keine Daten für Vertragskonto in Relevanztabelle gefunden'.
      EXIT.
    ELSE.
      IF NOT p_split IS INITIAL.
        REPLACE '.' WITH '01.' INTO ent_file.
      ENDIF.

      PERFORM open_entlade_file.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH  'Objekt: ACCOUNT / System:'
                                       sy-sysid '-' sy-mandt .


    LOOP AT iacc_vkont.

**    Test
*      CHECK iacc_vkont = '000200003411'.
*      BREAK-POINT.

      CALL FUNCTION '/ADESSO/MTE_ENT_ACCOUNT'
        EXPORTING
          firma        = firma
          x_vkont      = iacc_vkont
          x_object     = 'ACCOUNT'
          pfad_dat_ent = ent_file
        IMPORTING
          anz_obj      = anz_obj
          anz_vk_init  = anz_vk_init
          anz_vk       = anz_vk
          anz_vkp      = anz_vkp
          anz_vklock   = anz_vklock
          anz_vkcorr   = anz_vkcorr
          anz_vktaxex  = anz_vktaxex
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
*         no_data      = 4
          error        = 5
          OTHERS       = 6.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'ACCOUNT'.
          imig_err-obj_key = iacc_vkont.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_acc.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.

* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_acc.
      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.

*   Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl Vertragskonten:', 50 anz_acc.
    WRITE: / 'Enthaltene Strukturen VK_INIT', 50 anz_vk_init.
    WRITE: / '                      VK', 50 anz_vk.
    WRITE: / '                      VKP', 50 anz_vkp.
    WRITE: / '                      VKLOCK', 50 anz_vklock.
    WRITE: / '                      VKCORR', 50 anz_vkcorr.
    WRITE: / '                      VKTAXEX', 50 anz_vktaxex.
    SKIP 2.
    WRITE: / 'Fehler bei Dateierstellung ACCOUNT:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_acc.

  ENDIF.

*ACCOUNTS  Vertragskonto für Sammler anlegen
  IF obj_acs EQ 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'ACCOUNTS'.

    PERFORM erst_entlade_files USING dat_acs.

* Schlüssel aus Relevanztabelle ermitteln
    SELECT obj_key FROM /adesso/mte_rel INTO TABLE iacs_vkont
                                  WHERE firma  = firma
                                  AND   object = 'ACCOUNTS'.
    IF sy-subrc NE 0.
      SKIP.
      WRITE: /
    'keine Daten für Vertragskonto-Sammler in Relevanztabelle gefunden'.
      EXIT.
    ELSE.
      IF NOT p_split IS INITIAL.
        REPLACE '.' WITH '01.' INTO ent_file.
      ENDIF.

      PERFORM open_entlade_file.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH  'Objekt: ACCOUNTS / System:'
                                       sy-sysid '-' sy-mandt .


    LOOP AT iacs_vkont.

      CALL FUNCTION '/ADESSO/MTE_ENT_ACCOUNT'
        EXPORTING
          firma        = firma
          x_vkont      = iacs_vkont
          x_object     = 'ACCOUNTS'
          pfad_dat_ent = ent_file
        IMPORTING
          anz_obj      = anz_obj
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
*         no_data      = 4
          error        = 5
          OTHERS       = 6.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'ACCOUNTS'.
          imig_err-obj_key = iacs_vkont.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_acs.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.

* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_acs.
      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.

* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl Vertragskonten-Sammler:', anz_acs.
    SKIP.
    WRITE: / 'Fehler bei Dateierstellung ACCOUNTS:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.


    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_acs.


  ENDIF.

*-----------------------------------------------------------------------
*ACC_NOTE  Notizen zum Vertragskonto anlegen
  IF obj_acn EQ 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'ACC_NOTE'.

    PERFORM erst_entlade_files USING dat_acn.

* Schlüssel aus Relevanztabelle ermitteln
    SELECT obj_key FROM /adesso/mte_rel INTO TABLE iacn_vkont
                                  WHERE firma  = firma
                                  AND   object = 'ACC_NOTE'.
    IF sy-subrc NE 0.
      SKIP.
      WRITE: /
   'keine Daten für Vertragskonto-Notizen in Relevanztabelle gefunden'.
      EXIT.
    ELSE.
      IF NOT p_split IS INITIAL.
        REPLACE '.' WITH '01.' INTO ent_file.
      ENDIF.

      PERFORM open_entlade_file.
    ENDIF.

    LOOP AT iacn_vkont.

      CALL FUNCTION '/ADESSO/MTE_ENT_ACC_NOTE'
        EXPORTING
          firma        = firma
          x_vkont      = iacn_vkont
          pfad_dat_ent = ent_file
        IMPORTING
          anz_obj      = anz_obj
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
*         no_data      = 4
          error        = 5
          OTHERS       = 6.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'ACC_NOTE'.
          imig_err-obj_key = iacn_vkont.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_acn.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.


*     Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_acn.
      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.

* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl Notizen zum Vertragskonto:', anz_acn.
    SKIP.
    WRITE: / 'Fehler bei Dateierstellung ACC_NOTE:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.


    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_acn.

  ENDIF.
*-----------------------------------------------------------------------
*BBP_MULT  Abschlagsplan für mehrere Verträge
  IF obj_bpm EQ 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'BBP_MULT'.


    PERFORM erst_entlade_files USING dat_bpm.

* Schlüssel aus Relevanztabelle ermitteln
    SELECT obj_key FROM /adesso/mte_rel INTO TABLE ibpm_abplan
                                  WHERE firma  = firma
                                  AND   object = 'BBP_MULT'.
    IF sy-subrc NE 0.
      SKIP.
      WRITE: /
       'keine Daten für Abschlagspläne in Relevanztabelle gefunden'.
      EXIT.
    ELSE.
      IF NOT p_split IS INITIAL.
        REPLACE '.' WITH '01.' INTO ent_file.
      ENDIF.

      PERFORM open_entlade_file.
    ENDIF.

    LOOP AT ibpm_abplan.

*     Test
*      CHECK ibpm_abplan = '000602617395'.
*      BREAK-POINT.

      CALL FUNCTION '/ADESSO/MTE_ENT_BBP_MULT'
        EXPORTING
          firma        = firma
          x_abplan     = ibpm_abplan
          pfad_dat_ent = ent_file
        IMPORTING
          anz_obj      = anz_obj
          anz_eabp     = anz_eabp
          anz_eabpv    = anz_eabpv
          anz_eabps    = anz_eabps
          anz_ejvl     = anz_ejvl
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
          no_data      = 4
          error        = 5
          OTHERS       = 6.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'BBP_MULT'.
          imig_err-obj_key = ibpm_abplan.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_bpm.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.


* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_bpm.
      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.

*  Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl Abschlagspläne:', 50 anz_bpm.
    WRITE: / 'Enthaltene Strukturen EABP', 50 anz_eabp,
           / '                      EABPV', 50 anz_eabpv,
           / '                      EABPS', 50 anz_eabps,
           / '                      EJVL', 50 anz_ejvl.
    SKIP.
    WRITE: / 'Fehler bei Dateierstellung BBP_MULT:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_bpm.

  ENDIF.
*-----------------------------------------------------------------------

*BCONTACT  Kundenkontakt anlegen
  IF obj_bct EQ 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'BCONTACT'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_bct.

* Schlüssel aus Relevanztabelle ermitteln
    SELECT obj_key FROM /adesso/mte_rel INTO TABLE ibct_bpcontact
                                  WHERE firma  = firma
                                  AND   object = 'BCONTACT'.
    IF sy-subrc NE 0.
      SKIP.
      WRITE: /
       'keine Daten für Kundenkontakte in Relevanztabelle gefunden'.
      EXIT.
    ELSE.
      IF NOT p_split IS INITIAL.
        REPLACE '.' WITH '01.' INTO ent_file.
      ENDIF.

      PERFORM open_entlade_file.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH  'Objekt: BCONTACT / System:'
                                       sy-sysid '-' sy-mandt .


    LOOP AT ibct_bpcontact.

      CALL FUNCTION '/ADESSO/MTE_ENT_BCONTACT'
        EXPORTING
          firma        = firma
          x_bpcontact  = ibct_bpcontact
          pfad_dat_ent = ent_file
        IMPORTING
          anz_obj      = anz_obj
          anz_bcontd   = anz_bcontd
          anz_iobjects = anz_iobjects
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
*         no_data      = 4
          error        = 5
          OTHERS       = 6.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'BCONTACT'.
          imig_err-obj_key = ibct_bpcontact.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_bct.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.

* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_bct.
      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.
*
* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl Kundenkontakte:', 50 anz_bct.
    WRITE: / 'Enthaltene Strukturen BCONTD', 50 anz_bcontd.
    WRITE: / '                      IOBJECTS', 50 anz_iobjects.
    SKIP.
    WRITE: / 'Fehler bei Dateierstellung BCONTACT:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_bct.

  ENDIF.
*-----------------------------------------------------------------------

*BCONT_NOTE  Notizen zum Kundenkontakt
  IF obj_bcn EQ 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'BCONT_NOTE'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_bcn.

* Schlüssel aus Relevanztabelle ermitteln
    SELECT obj_key FROM /adesso/mte_rel INTO TABLE ibcn_bpcontact
                                  WHERE firma  = firma
                                  AND   object = 'BCONT_NOTE'.
    IF sy-subrc NE 0.
      SKIP.
      WRITE: /
       'keine Daten für Kundenkontakte in Relevanztabelle gefunden'.
      EXIT.
    ELSE.
      IF NOT p_split IS INITIAL.
        REPLACE '.' WITH '01.' INTO ent_file.
      ENDIF.

      PERFORM open_entlade_file.
    ENDIF.

    LOOP AT ibcn_bpcontact.

      CALL FUNCTION '/ADESSO/MTE_ENT_BCONT_NOTE'
        EXPORTING
          firma        = firma
          x_bpcontact  = ibcn_bpcontact
          pfad_dat_ent = ent_file
        IMPORTING
          anz_obj      = anz_obj
          anz_key      = anz_key
          anz_tline    = anz_tline
          anz_konv     = anz_konv
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
*         no_data      = 4
          error        = 5
          OTHERS       = 6.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'BCONT_NOTE'.
          imig_err-obj_key = ibcn_bpcontact.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_bcn.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.


*     Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_bcn.
      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.

* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl Notizen zu Kundenkontakte:', 50 anz_bcn.
    WRITE: / 'Enthaltene Strukturen      KEY', 50 anz_key.
    WRITE: / '                           TLINE', 50 anz_tline.
    SKIP.
    WRITE: / 'Anzahl Konvertierungsfehler', 50 anz_konv.
    SKIP.
    SKIP.
    WRITE: / 'Fehler bei Dateierstellung BCONT_NOTE:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_bcn.

  ENDIF.
*-----------------------------------------------------------------------

*BDC_MRUNIT  Ableseeinheiten
  IF obj_mru EQ 'X'.
*    PERFORM erst_entlade_files USING dat_mru.
* Fuba-Aufruf

    MESSAGE  i001(/adesso/mt_n)  WITH  'Objekt noch nicht implementiert'.
    EXIT.
  ENDIF.
*-----------------------------------------------------------------------

*BDC_TE420  Tabelle E420: Portionen
  IF obj_420 EQ 'X'.
*    PERFORM erst_entlade_files USING dat_420.
* Fuba-Aufruf

    MESSAGE  i001(/adesso/mt_n)  WITH  'Objekt noch nicht implementiert'.
    EXIT.
  ENDIF.
*-----------------------------------------------------------------------

*CONNOBJ  Anschlussobjekt anlegen
  IF obj_con EQ 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'CONNOBJ'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_con.

* Schlüssel aus Relevanztabelle ermitteln
    SELECT obj_key FROM /adesso/mte_rel INTO TABLE icon_haus
                                  WHERE firma  = firma
                                  AND   object = 'CONNOBJ'.
    IF sy-subrc NE 0.
      SKIP.
      WRITE: /
           'keine Daten für Anschlussobjekt in Relevanztabelle gefunden'.
      EXIT.
    ELSE.
      IF NOT p_split IS INITIAL.
        REPLACE '.' WITH '01.' INTO ent_file.
      ENDIF.

      PERFORM open_entlade_file.
    ENDIF.

    LOOP AT icon_haus.

      CALL FUNCTION '/ADESSO/MTE_ENT_CONNOBJ'
        EXPORTING
          firma              = firma
          x_haus             = icon_haus
          pfad_dat_ent       = ent_file
        IMPORTING
          anz_obj            = anz_obj
          anz_ehaud          = anz_ehaud
          anz_addr_data      = anz_addr_data
          anz_addr_comm_data = anz_addr_comm_data
        TABLES
          meldung            = imeldung
        EXCEPTIONS
          no_open            = 1
          no_close           = 2
          wrong_data         = 3
*         no_data            = 4
          error              = 5
          OTHERS             = 6.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'CONNOBJ'.
          imig_err-obj_key = icon_haus.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_con.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.


* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_con.
      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.

* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl Anschlußobjekte:', 50 anz_con.
    WRITE: / 'Enthaltene Strukturen EHAUD', 50 anz_ehaud.
    WRITE: / '                      ADDR_DATA', 50 anz_addr_data.
    WRITE: / '                      ADDR_COMM_DATA', 50 anz_addr_comm_data.
    SKIP 2.
    WRITE: / 'Fehler bei Dateierstellung CONNOBJ:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_con.


  ENDIF.
**-----------------------------------------------------------------------

*CON_NOTE  Notizen zum Anschluss
  IF obj_cno EQ 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'CON_NOTE'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_cno.

* Schlüssel aus Relevanztabelle ermitteln
    SELECT obj_key FROM /adesso/mte_rel INTO TABLE icno_haus
                                  WHERE firma  = firma
                                  AND   object = 'CONNOBJ'.
    IF sy-subrc NE 0.
      SKIP.
      WRITE: /
           'keine Daten für Anschlußobjekt in Relevanztabelle gefunden'.
      EXIT.
    ELSE.

* jetzt die Datensätze ermitteln, wo auch eine Notiz vorhanden
      LOOP AT icno_haus.
        SELECT SINGLE * FROM stxh
          WHERE tdobject EQ 'IFLOT'
            AND tdid     EQ 'LTXT'
            AND tdname   EQ icno_haus
            AND tdspras  EQ sy-langu.
        IF sy-subrc NE 0.
          DELETE icno_haus.
        ENDIF.
      ENDLOOP.

      READ TABLE icno_haus INDEX 1.
      IF sy-subrc NE 0.
        SKIP.
        WRITE: /
             'keine Daten für Anschlußobjektnotizen gefunden'.
        EXIT.
      ELSE.
        IF NOT p_split IS INITIAL.
          REPLACE '.' WITH '01.' INTO ent_file.
        ENDIF.

        PERFORM open_entlade_file.
      ENDIF.

    ENDIF.

    LOOP AT icon_haus.

      CALL FUNCTION '/ADESSO/MTE_ENT_CON_NOTE'
        EXPORTING
          firma        = firma
          x_haus       = icno_haus
          pfad_dat_ent = ent_file
        IMPORTING
          anz_obj      = anz_obj
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
*         no_data      = 4
          error        = 5
          OTHERS       = 6.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'CON_NOTE'.
          imig_err-obj_key = icno_haus.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_cno.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.


* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_cno.
      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.

* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl Anschlußobjektnotizen:', anz_cno.
    SKIP.
    WRITE: / 'Fehler bei Dateierstellung CON_NOTE:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_cno.

  ENDIF.
*-----------------------------------------------------------------------

*DEVGRP  Gerätegruppe Anlegen
  IF obj_dgr EQ 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'DEVGRP'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_dgr.

    OPEN DATASET ent_file FOR OUTPUT IN TEXT MODE ENCODING DEFAULT..
    IF sy-subrc NE 0.
      CONCATENATE 'Datei' ent_file
       'konnte nicht geöffnet werden'
                         INTO imig_err-meldung SEPARATED BY space.
      APPEND imig_err.
      EXIT.
    ENDIF.


* Gerätegruppierung ermitteln
    REFRESH idgr_devgrp.

    SELECT * FROM egerh INTO TABLE iegerh2
                        WHERE devgrp NE space
                          AND devloc NE space
                          AND bis    EQ '99991231'.

    LOOP AT iegerh2.
      data_equnr = iegerh2-equnr.
      SELECT SINGLE * FROM /adesso/mte_rel
                         WHERE firma  EQ firma
                            AND object  = 'DEVICE'
                            AND obj_key = data_equnr.

*      IF sy-subrc NE 0.
** dann in der gesicherten Relevanztabelle gucken
*        SELECT SINGLE * FROM /adesso/mte_rels
*                           WHERE firma  EQ firma
*                             AND object  = 'DEVICE'
**                             AND obj_key = data_equnr.
      IF sy-subrc NE 0.
        CONTINUE.
      ENDIF.
*      ENDIF.

      MOVE iegerh2-devgrp TO idgr_devgrp.
      APPEND idgr_devgrp.
      CLEAR idgr_devgrp.

    ENDLOOP.

    SORT idgr_devgrp.
    DELETE ADJACENT DUPLICATES FROM idgr_devgrp.

* Ermitteln der Gerätegruppierungen
    LOOP AT idgr_devgrp.

      CALL FUNCTION '/ADESSO/MTE_ENT_DEVGRP'
        EXPORTING
          firma        = firma
          x_devgrp     = idgr_devgrp
          pfad_dat_ent = ent_file
        IMPORTING
          anz_obj      = anz_obj
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
*         no_data      = 4
          error        = 5
          OTHERS       = 6.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-object = 'DEVGRP'.
          imig_err-obj_key = idgr_devgrp.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_dgr.
      ENDIF.


* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
      ENDIF.

    ENDLOOP.

    CLOSE DATASET ent_file.
    IF sy-subrc NE 0.
      CONCATENATE 'Datei' ent_file
       'konnte nicht geschlossen werden'
                         INTO imig_err-meldung SEPARATED BY space.
      APPEND imig_err.
    ENDIF.

* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl  Gerätegruppierungen:', anz_dgr.
    SKIP.
    WRITE: / 'Fehler bei Dateierstellung DEVGRP:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_dgr.

  ENDIF.
*-----------------------------------------------------------------------


*DEVICE  Gerät / Equipment anlegen
  IF obj_dev EQ 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'DEVICE'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_dev.

* Schlüssel aus Relevanztabelle ermitteln
    SELECT obj_key FROM /adesso/mte_rel INTO TABLE idev_equnr
                                  WHERE firma  = firma
                                  AND   object = 'DEVICE'.
    IF sy-subrc NE 0.
      SKIP.
      WRITE: /
           'keine Daten für Geräte in Relevanztabelle gefunden'.
      EXIT.
    ELSE.
      IF NOT p_split IS INITIAL.
        REPLACE '.' WITH '01.' INTO ent_file.
      ENDIF.

      PERFORM open_entlade_file.
    ENDIF.

    LOOP AT idev_equnr.

      CALL FUNCTION '/ADESSO/MTE_ENT_DEVICE'
        EXPORTING
          firma        = firma
          x_equnr      = idev_equnr
          pfad_dat_ent = ent_file
        IMPORTING
          anz_obj      = anz_obj
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
*         no_data      = 4
          error        = 5
          OTHERS       = 6.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'DEVICE'.
          imig_err-obj_key = idev_equnr.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_dev.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.


* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_dev.
      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.

* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl Geräte:', anz_dev.
    SKIP.
    WRITE: / 'Fehler bei Dateierstellung DEVICE:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_dev.

  ENDIF.
*-----------------------------------------------------------------------
*DEVICERATE  Tarifdaten zur Anlagenstruktur ändern

  IF obj_drt EQ 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'DEVICERATE'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_drt.

* Schlüssel aus ermitteln
    SELECT * FROM /adesso/mte_htge INTO TABLE iht_ger_drt
            WHERE ( action = '01' OR
                    action = '03' OR
                    action = '04' )
              AND ( kennz_tg  = 'T' OR
                    kennz_tzw = 'T' ).
    IF sy-subrc NE 0.
      SKIP.
      WRITE: /
           'keine Daten für Devicerate in /adesso/mte_htge gefunden'.
      EXIT.
    ELSE.
      IF NOT p_split IS INITIAL.
        REPLACE '.' WITH '01.' INTO ent_file.
      ENDIF.

      PERFORM open_entlade_file.
    ENDIF.


    LOOP AT iht_ger_drt.

*   Aufruf des FUBAS pro iht_ger-Satz
      CALL FUNCTION '/ADESSO/MTE_ENT_DEVICERATE'
        EXPORTING
          firma        = firma
          x_htger      = iht_ger_drt
          pfad_dat_ent = ent_file
        IMPORTING
          anz_obj      = anz_obj
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
          error        = 4
          OTHERS       = 5.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'DEVICERATE'.
          imig_err-obj_key = iht_ger_drt-equnr.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_drt.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.


* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH
                'Anzahl durchlaufender Objekte bzw. Vorgänge:'
                                                       cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_drt.
      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.

* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl Tarifänderungen:', anz_drt.
    SKIP.
    WRITE: / 'Fehler bei Dateierstellung DEVICERATE:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
               'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                              anz_drt.

  ENDIF.

*-----------------------------------------------------------------------
*  DEVINFOREC  Geräteinfosatz
  IF obj_dir EQ 'X'.


*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'DEVINFOREC'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_dir.

* Schlüssel aus Relevanztabelle ermitteln
    SELECT obj_key FROM /adesso/mte_rel INTO TABLE idir_equnr
                                  WHERE firma  = firma
                                  AND   object = 'DEVINFOREC'.
    IF sy-subrc NE 0.
      SKIP.
      WRITE: / 'keine Daten für Geräteinfosätze in Relevanztabelle gefunden'.
      EXIT.
    ELSE.
      IF NOT p_split IS INITIAL.
        REPLACE '.' WITH '01.' INTO ent_file.
      ENDIF.
      PERFORM open_entlade_file.
    ENDIF.

    LOOP AT idir_equnr.

*  Test
*      CHECK idir_equnr = '000000000030723546'.
*      BREAK-POINT.

* Fuba Aufrufen
      CALL FUNCTION '/ADESSO/MTE_ENT_DEVINFOREC'
        EXPORTING
          firma        = firma
          x_equnr      = idir_equnr
          pfad_dat_ent = ent_file
        IMPORTING
          anz_obj      = anz_obj
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
          no_data      = 4
          error        = 5
          OTHERS       = 6.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'DEVINFOREC'.
          imig_err-obj_key = idir_equnr.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_dir.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.

* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_dir.
      ENDIF.

    ENDLOOP.

*** Entladedatei schließen
    PERFORM close_entlade_file.

*** Fehlerauswertung
    SORT imig_err.
    DELETE ADJACENT DUPLICATES FROM imig_err COMPARING ALL FIELDS.

    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl Geräteinfosätze:', anz_dir.
    SKIP.
    WRITE: / 'Fehler bei Dateierstellung DEVINFOREC:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_dir.

  ENDIF.


*-----------------------------------------------------------------------
*DEVLOC  Geräteplatz anlegen
  IF obj_dlc EQ 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'DEVLOC'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_dlc.

* Schlüssel aus Relevanztabelle ermitteln
    SELECT obj_key FROM /adesso/mte_rel INTO TABLE i_devloc
                                  WHERE firma  = firma
                                  AND   object = 'DEVLOC'.
    IF sy-subrc NE 0.
      SKIP.
      WRITE: /
           'keine Daten für Geräteplatz in Relevanztabelle gefunden'.
      EXIT.
    ELSE.
      IF NOT p_split IS INITIAL.
        REPLACE '.' WITH '01.' INTO ent_file.
      ENDIF.

      PERFORM open_entlade_file.
    ENDIF.

    LOOP AT i_devloc.

      CALL FUNCTION '/ADESSO/MTE_ENT_DEVLOC'
        EXPORTING
          firma        = firma
          x_devloc     = i_devloc
          pfad_dat_ent = ent_file
        IMPORTING
          anz_obj      = anz_obj
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
*         no_data      = 4
          error        = 5
          OTHERS       = 6.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'DEVLOC'.
          imig_err-obj_key = i_devloc.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_dlc.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.


* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_dlc.
      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.

* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl Geräteplätze:', anz_dlc.
    SKIP.
    WRITE: / 'Fehler bei Dateierstellung DEVLOC:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_dlc.


  ENDIF.
*-----------------------------------------------------------------------

*DLC_NOTE  Notizen zum Geräteplatz
  IF obj_dno EQ 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'DLC_NOTE'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_dno.

* Schlüssel aus Relevanztabelle ermitteln
    SELECT obj_key FROM /adesso/mte_rel INTO TABLE idno_devloc
                                  WHERE firma  = firma
                                  AND   object = 'DEVLOC'.
    IF sy-subrc NE 0.
      SKIP.
      WRITE: /
           'keine Daten für Geräteplatz in Relevanztabelle gefunden'.
      EXIT.
    ELSE.

* jetzt die Datensätze ermitteln, wo auch eine Notiz vorhanden
      LOOP AT idno_devloc.
        SELECT SINGLE * FROM stxh
          WHERE tdobject EQ 'IFLOT'
            AND tdid     EQ 'LTXT'
            AND tdname   EQ idno_devloc
            AND tdspras  EQ sy-langu.
        IF sy-subrc NE 0.
          DELETE idno_devloc.
        ENDIF.
      ENDLOOP.

      READ TABLE idno_devloc INDEX 1.
      IF sy-subrc NE 0.
        SKIP.
        WRITE: /
             'keine Daten für Geräteplatznotizen gefunden'.
        EXIT.
      ELSE.
        IF NOT p_split IS INITIAL.
          REPLACE '.' WITH '01.' INTO ent_file.
        ENDIF.

        PERFORM open_entlade_file.
      ENDIF.

    ENDIF.

    LOOP AT idno_devloc.

      CALL FUNCTION '/ADESSO/MTE_ENT_DLC_NOTE'
        EXPORTING
          firma        = firma
          x_devloc     = idno_devloc
          pfad_dat_ent = ent_file
        IMPORTING
          anz_obj      = anz_obj
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
*         no_data      = 4
          error        = 5
          OTHERS       = 6.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'DLC_NOTE'.
          imig_err-obj_key = idno_devloc.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_dno.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.


* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_dno.
      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.

* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl Geräteplatznotizen:', anz_dno.
    SKIP.
    WRITE: / 'Fehler bei Dateierstellung DLC_NOTE:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_dno.

  ENDIF.

*-----------------------------------------------------------------------


*DISC_DOC  Sperrbeleg anlegen
  IF obj_dcd EQ 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'DISC_DOC'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_dcd.

* Sperrbelege ermitteln
    SELECT * FROM ediscdoc INTO TABLE iediscdoc
                                  WHERE status NE '99'
                                  AND   loevm  EQ space.
    IF sy-subrc NE 0.
      SKIP.
      WRITE: /
           'keine Daten für Sperrbelege in EDISCDOC gefunden'.
      EXIT.
    ELSE.

* jetzt die Datensätze ermitteln, wo auch Objekte in der
* Relevanzermittlung sind
      LOOP AT iediscdoc.

        CASE iediscdoc-refobjtype.
          WHEN 'ISUACCOUNT'.
            SELECT SINGLE * FROM /adesso/mte_rel
                         WHERE firma   = firma
                           AND object  = 'ACCOUNT'
                           AND obj_key = iediscdoc-refobjkey(12).
            IF sy-subrc NE 0.
              DELETE iediscdoc.
            ENDIF.

          WHEN 'DEVICE'.
            SELECT SINGLE * FROM /adesso/mte_rel
                         WHERE firma   = firma
                           AND object  = 'DEVICE'
                           AND obj_key = iediscdoc-refobjkey.
            IF sy-subrc NE 0.
              DELETE iediscdoc.
            ENDIF.

          WHEN 'INSTLN'.
            SELECT SINGLE * FROM /adesso/mte_rel
                         WHERE firma   = firma
                           AND object  = 'INSTLN'
                           AND obj_key = iediscdoc-refobjkey.
            IF sy-subrc NE 0.
              DELETE iediscdoc.
            ENDIF.

          WHEN OTHERS.
            DELETE iediscdoc.

        ENDCASE.

      ENDLOOP.

      READ TABLE iediscdoc INDEX 1.
      IF sy-subrc NE 0.
        SKIP.
        WRITE: /
             'keine Daten für Sperrbelege gefunden'.
        EXIT.
      ELSE.
        IF NOT p_split IS INITIAL.
          REPLACE '.' WITH '01.' INTO ent_file.
        ENDIF.

        PERFORM open_entlade_file.
      ENDIF.

    ENDIF.

    LOOP AT iediscdoc.

      CALL FUNCTION '/ADESSO/MTE_ENT_DISC_DOC'
        EXPORTING
          firma        = firma
          x_ediscdoc   = iediscdoc
          pfad_dat_ent = ent_file
        IMPORTING
          anz_obj      = anz_obj
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
*         no_data      = 4
          error        = 5
          OTHERS       = 6.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'DISC_DOC'.
          imig_err-obj_key = iediscdoc-discno.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_dcd.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.


* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_dcd.
      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.

* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl Sperrbelege:', anz_dcd.
    SKIP.
    WRITE: / 'Fehler bei Dateierstellung DISC_DOC:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_dcd.

  ENDIF.

*-----------------------------------------------------------------------

*DISC_ORDER  Sperrauftrag anlegen
  IF obj_dco EQ 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'DISC_ORDER'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_dco.

* Sperrbelege ermitteln
    SELECT * FROM ediscdoc INTO TABLE iediscdoc
                                  WHERE status NE '99'
                                  AND   loevm  EQ space.
    IF sy-subrc NE 0.
      SKIP.
      WRITE: /
           'keine Daten für Sperrbelege in EDISCDOC gefunden'.
      EXIT.
    ELSE.

* jetzt die Datensätze ermitteln, wo auch Objekte in der
* Relevanzermittlung sind
      LOOP AT iediscdoc.

        CASE iediscdoc-refobjtype.
          WHEN 'ISUACCOUNT'.
            SELECT SINGLE * FROM /adesso/mte_rel
                         WHERE firma   = firma
                           AND object  = 'ACCOUNT'
                           AND obj_key = iediscdoc-refobjkey(12).
            IF sy-subrc NE 0.
              DELETE iediscdoc.
            ENDIF.

          WHEN 'DEVICE'.
            SELECT SINGLE * FROM /adesso/mte_rel
                         WHERE firma   = firma
                           AND object  = 'DEVICE'
                           AND obj_key = iediscdoc-refobjkey.
            IF sy-subrc NE 0.
              DELETE iediscdoc.
            ENDIF.

          WHEN 'INSTLN'.
            SELECT SINGLE * FROM /adesso/mte_rel
                         WHERE firma   = firma
                           AND object  = 'INSTLN'
                           AND obj_key = iediscdoc-refobjkey.
            IF sy-subrc NE 0.
              DELETE iediscdoc.
            ENDIF.

          WHEN OTHERS.
            DELETE iediscdoc.

        ENDCASE.

      ENDLOOP.

      READ TABLE iediscdoc INDEX 1.
      IF sy-subrc NE 0.
        SKIP.
        WRITE: /
             'keine Daten für Sperrbelege gefunden'.
        EXIT.
      ELSE.
        IF NOT p_split IS INITIAL.
          REPLACE '.' WITH '01.' INTO ent_file.
        ENDIF.

        PERFORM open_entlade_file.
      ENDIF.

    ENDIF.

    LOOP AT iediscdoc.

      CALL FUNCTION '/ADESSO/MTE_ENT_DISC_ORDER'
        EXPORTING
          firma        = firma
          x_ediscdoc   = iediscdoc
          pfad_dat_ent = ent_file
        IMPORTING
          anz_obj      = anz_obj
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
*         no_data      = 4
          error        = 5
          OTHERS       = 6.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'DISC_ORDER'.
          imig_err-obj_key = iediscdoc-discno.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_dco.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.


* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_dco.
      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.

* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl Sperrauftrag anlegen:', anz_dco.
    SKIP.
    WRITE: / 'Fehler bei Dateierstellung DISC_ORDER:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_dco.

  ENDIF.

*-----------------------------------------------------------------------

*DISC_ENTER  Sperrung erfassen
  IF obj_dce EQ 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'DISC_ENTER'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_dce.

* Sperrbelege ermitteln
    SELECT * FROM ediscdoc INTO TABLE iediscdoc
                                  WHERE status NE '99'
                                  AND   loevm  EQ space.
    IF sy-subrc NE 0.
      SKIP.
      WRITE: /
           'keine Daten für Sperrbelege in EDISCDOC gefunden'.
      EXIT.
    ELSE.

* jetzt die Datensätze ermitteln, wo auch Objekte in der
* Relevanzermittlung sind
      LOOP AT iediscdoc.

        CASE iediscdoc-refobjtype.
          WHEN 'ISUACCOUNT'.
            SELECT SINGLE * FROM /adesso/mte_rel
                         WHERE firma   = firma
                           AND object  = 'ACCOUNT'
                           AND obj_key = iediscdoc-refobjkey(12).
            IF sy-subrc NE 0.
              DELETE iediscdoc.
            ENDIF.

          WHEN 'DEVICE'.
            SELECT SINGLE * FROM /adesso/mte_rel
                         WHERE firma   = firma
                           AND object  = 'DEVICE'
                           AND obj_key = iediscdoc-refobjkey.
            IF sy-subrc NE 0.
              DELETE iediscdoc.
            ENDIF.

          WHEN 'INSTLN'.
            SELECT SINGLE * FROM /adesso/mte_rel
                         WHERE firma   = firma
                           AND object  = 'INSTLN'
                           AND obj_key = iediscdoc-refobjkey.
            IF sy-subrc NE 0.
              DELETE iediscdoc.
            ENDIF.

          WHEN OTHERS.
            DELETE iediscdoc.

        ENDCASE.

      ENDLOOP.

      READ TABLE iediscdoc INDEX 1.
      IF sy-subrc NE 0.
        SKIP.
        WRITE: /
             'keine Daten für Sperrbelege gefunden'.
        EXIT.
      ELSE.
        IF NOT p_split IS INITIAL.
          REPLACE '.' WITH '01.' INTO ent_file.
        ENDIF.

        PERFORM open_entlade_file.
      ENDIF.

    ENDIF.

    LOOP AT iediscdoc.

      CALL FUNCTION '/ADESSO/MTE_ENT_DISC_ENTER'
        EXPORTING
          firma        = firma
          x_ediscdoc   = iediscdoc
          pfad_dat_ent = ent_file
        IMPORTING
          anz_obj      = anz_obj
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
*         no_data      = 4
          error        = 5
          OTHERS       = 6.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'DISC_ENTER'.
          imig_err-obj_key = iediscdoc-discno.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_dce.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.


* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_dce.
      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.

* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl Sperrung erfassen:', anz_dce.
    SKIP.
    WRITE: / 'Fehler bei Dateierstellung DISC_ENTER:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_dce.

  ENDIF.

*-----------------------------------------------------------------------

*DISC_RCORD  Wiederinbetriebnahmeauftrag anlegen
  IF obj_dcr EQ 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'DISC_RCORD'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_dcr.

* Sperrbelege ermitteln
    SELECT * FROM ediscdoc INTO TABLE iediscdoc
                                  WHERE status NE '99'
                                  AND   loevm  EQ space.
    IF sy-subrc NE 0.
      SKIP.
      WRITE: /
           'keine Daten für Sperrbelege in EDISCDOC gefunden'.
      EXIT.
    ELSE.

* jetzt die Datensätze ermitteln, wo auch Objekte in der
* Relevanzermittlung sind
      LOOP AT iediscdoc.

        CASE iediscdoc-refobjtype.
          WHEN 'ISUACCOUNT'.
            SELECT SINGLE * FROM /adesso/mte_rel
                         WHERE firma   = firma
                           AND object  = 'ACCOUNT'
                           AND obj_key = iediscdoc-refobjkey(12).
            IF sy-subrc NE 0.
              DELETE iediscdoc.
            ENDIF.

          WHEN 'DEVICE'.
            SELECT SINGLE * FROM /adesso/mte_rel
                         WHERE firma   = firma
                           AND object  = 'DEVICE'
                           AND obj_key = iediscdoc-refobjkey.
            IF sy-subrc NE 0.
              DELETE iediscdoc.
            ENDIF.

          WHEN 'INSTLN'.
            SELECT SINGLE * FROM /adesso/mte_rel
                         WHERE firma   = firma
                           AND object  = 'INSTLN'
                           AND obj_key = iediscdoc-refobjkey.
            IF sy-subrc NE 0.
              DELETE iediscdoc.
            ENDIF.

          WHEN OTHERS.
            DELETE iediscdoc.

        ENDCASE.

      ENDLOOP.

      READ TABLE iediscdoc INDEX 1.
      IF sy-subrc NE 0.
        SKIP.
        WRITE: /
             'keine Daten für Sperrbelege gefunden'.
        EXIT.
      ELSE.
        IF NOT p_split IS INITIAL.
          REPLACE '.' WITH '01.' INTO ent_file.
        ENDIF.

        PERFORM open_entlade_file.
      ENDIF.

    ENDIF.

    LOOP AT iediscdoc.

      CALL FUNCTION '/ADESSO/MTE_ENT_DISC_RCORD'
        EXPORTING
          firma        = firma
          x_ediscdoc   = iediscdoc
          pfad_dat_ent = ent_file
        IMPORTING
          anz_obj      = anz_obj
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
*         no_data      = 4
          error        = 5
          OTHERS       = 6.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'DISC_RCORD'.
          imig_err-obj_key = iediscdoc-discno.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_dcr.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.


* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_dcr.
      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.

* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl Wiederinbetriebnahmeauftrag anlegen:', anz_dcr.
    SKIP.
    WRITE: / 'Fehler bei Dateierstellung DISC_RCORD:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_dcr.

  ENDIF.

*-----------------------------------------------------------------------

*DISC_RCENT  Wiederinbetriebnahme anlegen
  IF obj_dcm EQ 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'DISC_RCENT'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_dcm.

* Sperrbelege ermitteln
    SELECT * FROM ediscdoc INTO TABLE iediscdoc
                                  WHERE status NE '99'
                                  AND   loevm  EQ space.
    IF sy-subrc NE 0.
      SKIP.
      WRITE: /
           'keine Daten für Sperrbelege in EDISCDOC gefunden'.
      EXIT.
    ELSE.

* jetzt die Datensätze ermitteln, wo auch Objekte in der
* Relevanzermittlung sind
      LOOP AT iediscdoc.

        CASE iediscdoc-refobjtype.
          WHEN 'ISUACCOUNT'.
            SELECT SINGLE * FROM /adesso/mte_rel
                         WHERE firma   = firma
                           AND object  = 'ACCOUNT'
                           AND obj_key = iediscdoc-refobjkey(12).
            IF sy-subrc NE 0.
              DELETE iediscdoc.
            ENDIF.

          WHEN 'DEVICE'.
            SELECT SINGLE * FROM /adesso/mte_rel
                         WHERE firma   = firma
                           AND object  = 'DEVICE'
                           AND obj_key = iediscdoc-refobjkey.
            IF sy-subrc NE 0.
              DELETE iediscdoc.
            ENDIF.

          WHEN 'INSTLN'.
            SELECT SINGLE * FROM /adesso/mte_rel
                         WHERE firma   = firma
                           AND object  = 'INSTLN'
                           AND obj_key = iediscdoc-refobjkey.
            IF sy-subrc NE 0.
              DELETE iediscdoc.
            ENDIF.

          WHEN OTHERS.
            DELETE iediscdoc.

        ENDCASE.

      ENDLOOP.

      READ TABLE iediscdoc INDEX 1.
      IF sy-subrc NE 0.
        SKIP.
        WRITE: /
             'keine Daten für Sperrbelege gefunden'.
        EXIT.
      ELSE.
        IF NOT p_split IS INITIAL.
          REPLACE '.' WITH '01.' INTO ent_file.
        ENDIF.

        PERFORM open_entlade_file.
      ENDIF.

    ENDIF.

    LOOP AT iediscdoc.

      CALL FUNCTION '/ADESSO/MTE_ENT_DISC_RCENT'
        EXPORTING
          firma        = firma
          x_ediscdoc   = iediscdoc
          pfad_dat_ent = ent_file
        IMPORTING
          anz_obj      = anz_obj
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
*         no_data      = 4
          error        = 5
          OTHERS       = 6.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'DISC_RCENT'.
          imig_err-obj_key = iediscdoc-discno.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_dcm.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.


* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_dcm.
      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.

* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl Wiederinbetriebnahme anlegen:', anz_dcm.
    SKIP.
    WRITE: / 'Fehler bei Dateierstellung DISC_RCENT:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_dcm.

  ENDIF.

*-----------------------------------------------------------------------


*DOCUMENT  FI-CA Beleg anlegen (nur Offene Posten)
  IF obj_doc EQ 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'DOCUMENT'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_doc.

* Schlüssel aus Relevanztabelle ermitteln
    SELECT obj_key FROM /adesso/mte_rel INTO TABLE idoc_vkont
                                  WHERE firma  = firma
*                                  AND   object = 'DOCUMENT'.
                                  AND (  object = 'ACCOUNT' OR
                                         object = 'ACCOUNTS' ).
    IF sy-subrc NE 0.
      SKIP.
      WRITE: /
           'keine Daten für offene Posten in Relevanztabelle gefunden'.
      EXIT.
    ELSE.
      IF NOT p_split IS INITIAL.
        REPLACE '.' WITH '01.' INTO ent_file.
      ENDIF.

      PERFORM open_entlade_file.
    ENDIF.

* --> Nuss 30.10.2015
*   Bei WBD kein DUNNING
*    DELETE FROM /adesso/mte_rel
*      WHERE firma = firma
*      AND object = 'DUNNING'.
*  <-- Nuss 30.10.2015

    LOOP AT idoc_vkont.

**  Test
*      CHECK idoc_vkont = '000200419233'.
*      BREAK-POINT.


      CALL FUNCTION '/ADESSO/MTE_ENT_DOCUMENT_WBD'   "Nuss 30.10.2015 Neuer Fuba
        EXPORTING
          firma        = firma
          x_vkont      = idoc_vkont
          pfad_dat_ent = ent_file
        IMPORTING
          anz_obj      = anz_obj
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
*         no_data      = 4
          error        = 5
          OTHERS       = 6.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'DOCUMENT'.
          imig_err-obj_key = idoc_vkont.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_doc.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.


* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_doc.
      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.

* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl offene Posten', anz_doc.
    SKIP.
    WRITE: / 'Fehler bei Dateierstellung DOCUMENT:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_doc.

  ENDIF.
*-----------------------------------------------------------------------

*FACTS   Individuelle Fakten zur Versorgungsanlage anlegen
  IF obj_fac EQ 'X'.

*>  Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'FACTS'.
*<  Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_fac.

*   Schlüssel aus Relevanztabelle ermitteln
    SELECT obj_key FROM /adesso/mte_rel INTO TABLE ifac_anlage
                                  WHERE firma  = firma
                                  AND   object = 'INSTLN'.
    IF sy-subrc NE 0.
      SKIP.
      WRITE: /
           'keine Daten für Fakten in Relevanztabelle gefunden'.
      EXIT.
    ELSE.
      IF NOT p_split IS INITIAL.
        REPLACE '.' WITH '01.' INTO ent_file.
      ENDIF.

      PERFORM open_entlade_file.
    ENDIF.

    LOOP AT ifac_anlage.

*   Test
*      CHECK ifac_anlage = '0050011860'.
*      break-point.


      CALL FUNCTION '/ADESSO/MTE_ENT_FACTS_WBD'
        EXPORTING
          firma        = firma
          x_anlage     = ifac_anlage
          pfad_dat_ent = ent_file
        IMPORTING
          anz_obj      = anz_obj
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
*         no_data      = 4
          error        = 5
          OTHERS       = 6.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'FACTS'.
          imig_err-obj_key = ifac_anlage.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_fac.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.


*     Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_fac.
      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.

* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl Fakten:', anz_fac.
    SKIP.
    WRITE: / 'Fehler bei Dateierstellung FACTS:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_fac.

  ENDIF.
*-----------------------------------------------------------------------

*INSTLN  Anlegen: Versorgungsanlage
  IF obj_ins EQ 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'INSTLN'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_ins.

* Schlüssel aus Relevanztabelle ermitteln
    SELECT obj_key FROM /adesso/mte_rel INTO TABLE ins_anlage
                                  WHERE firma  = firma
                                  AND   object = 'INSTLN'.
    IF sy-subrc NE 0.
      SKIP.
      WRITE: /
           'keine Daten für Anlage in Relevanztabelle gefunden'.
      EXIT.
    ELSE.
      IF NOT p_split IS INITIAL.
        REPLACE '.' WITH '01.' INTO ent_file.
      ENDIF.

      PERFORM open_entlade_file.
    ENDIF.

    DELETE FROM /adesso/mte_rel
    WHERE firma = firma
      AND object = 'INSTLNCHA'.

    LOOP AT ins_anlage.

*   Test
*      CHECK ins_anlage = '0050548971'
*        OR ins_anlage = '0050549087'.
*      BREAK-POINT.

*     Für Projekt WBD ein eigener Funktionsbaustein, bei dem die Zählpunkte
*     direkt aufgebaut werden (im Quellsystem liegen keine Zählpunkte für
*     Abwasser vor)
      CALL FUNCTION '/ADESSO/MTE_ENT_INSTLN_WBD'
        EXPORTING
          firma        = firma
          x_anlage     = ins_anlage
          pfad_dat_ent = ent_file
          x_historisch = 'X'
        IMPORTING
          anz_obj      = anz_obj
          anz_key      = anz_key
          anz_data     = anz_data
          anz_rcat     = anz_rcat
          anz_pod      = anz_pod
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
          gen_error    = 4
          error        = 5
          no_adress    = 6
          no_key       = 7
          OTHERS       = 8.

      IF sy-subrc <> 0.
        CASE sy-subrc.
          WHEN 5.
            count_no_adress = count_no_adress + 1.
          WHEN 6.
            count_no_key = count_no_key + 1.
        ENDCASE.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'INSTLN'.
          imig_err-obj_key = ins_anlage.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.

      ELSE.
**      --> Nuss 07.09.2015   Es könnten Anlagen ohne Zählpunkt existieren
**      Diese Anlagen werden als Fehler ausgegeben, aber trotzdem migriert.
        IF imeldung IS NOT INITIAL.
          LOOP AT imeldung.
            imig_err-firma  = firma.
            imig_err-object = 'INSTLN'.
            imig_err-obj_key = ins_anlage.
            imig_err-meldung = imeldung-meldung.
            APPEND imig_err.
          ENDLOOP.
        ENDIF.
**     <-- Nuss 07.09.2015
        ADD anz_obj TO anz_ins.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.


* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_ins.
      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.

* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl Anlagen:', 50 anz_ins.
    WRITE: / 'Enthalten Strukturen KEY', 50 anz_key.
    WRITE: / '                     DATA', 50 anz_data.
    WRITE: / '                     RCAT', 50 anz_rcat.
    WRITE: / '                     POD', 50 anz_pod.
    SKIP.
    WRITE: / 'Anzahl Anlagen ohne Adresse: ', 50 count_no_adress.
    SKIP.
    WRITE: / 'Anzahl Anlagen ohne Abl-Einh aus der Regionalstruktur: ',
              50 count_no_key.
    SKIP.
    WRITE: / 'Fehler bei Dateierstellung INSTLN:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_ins.

  ENDIF.
**-----------------------------------------------------------------------

*INSTLNCHA  Ändern Versorgungsanlage
  IF obj_ich EQ 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'INSTLNCHA'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_ich.

* Schlüssel aus Relevanztabelle ermitteln
    SELECT obj_key FROM /adesso/mte_rel INTO TABLE ich_anlage
                                  WHERE firma  = firma
                                  AND   object = 'INSTLNCHA'.
    IF sy-subrc NE 0.
      SKIP.
      WRITE: /
       'keine Daten für Anlagenänderung in Relevanztabelle gefunden'.
      EXIT.
    ELSE.
      IF NOT p_split IS INITIAL.
        REPLACE '.' WITH '01.' INTO ent_file.
      ENDIF.

      PERFORM open_entlade_file.
    ENDIF.

    LOOP AT ich_anlage.

*   Test
*      CHECK ich_anlage = '0050011411'.
*      BREAK-POINT.

      CALL FUNCTION '/ADESSO/MTE_ENT_INSTLNCHA_WBD'
        EXPORTING
          firma        = firma
          x_anlage     = ich_anlage
          pfad_dat_ent = ent_file
          x_historisch = 'X'
        IMPORTING
          anz_obj      = anz_obj
          anz_key      = anz_key
          anz_data     = anz_data
          anz_rcat     = anz_rcat
          anz_pod      = anz_pod
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
          error        = 4
          no_adress    = 5
          no_key       = 6
          OTHERS       = 7.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'INSTLNCHA'.
          imig_err-obj_key = ich_anlage.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_ich.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.


* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_ich.
      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.
* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl Anlagenänderungen:', 50 anz_ich.
    WRITE: / 'Enthaltene Strukturen KEY', 50 anz_key.
    WRITE: / '                      DATA', 50 anz_data.
    WRITE: / '                      RCAT', 50 anz_rcat.
    WRITE: / '                      POD',  50 anz_pod.
    SKIP 2.
    SKIP.
    WRITE: / 'Fehler bei Dateierstellung INSTLNCHA:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_ich.


  ENDIF.

*----------------------------------------------------------------------
* INSTLN_NN  Anlagen für Netznutzung
*----------------------------------------------------------------------
  IF obj_inn = 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'INSTLN_NN'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_inn.

* Schlüssel aus Relevanztabelle ermitteln
    SELECT obj_key FROM /adesso/mte_rel INTO TABLE inn_anlage
                                  WHERE firma  = firma
                                  AND   object = 'INSTLN_NN'.
    IF sy-subrc NE 0.
      SKIP.
      WRITE: /
           'keine Daten für Anlagen in Relevanztabelle gefunden'.
      EXIT.
    ELSE.
      IF NOT p_split IS INITIAL.
        REPLACE '.' WITH '01.' INTO ent_file.
      ENDIF.

      PERFORM open_entlade_file.
    ENDIF.

    DELETE FROM /adesso/mte_rel
    WHERE firma = firma
      AND object = 'INSTLNCHNN'.

    LOOP AT inn_anlage.


      CALL FUNCTION '/ADESSO/MTE_ENT_INSTLN_NN'
        EXPORTING
          firma        = firma
          x_anlage     = inn_anlage
          pfad_dat_ent = ent_file
***   X_HISTORISCH       =
        IMPORTING
          anz_obj      = anz_obj
          anz_key      = anz_key
          anz_data     = anz_data
          anz_rcat     = anz_rcat
          anz_pod      = anz_pod
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
          gen_error    = 4
          error        = 5
          no_adress    = 6
          no_key       = 7
          OTHERS       = 8.

      IF sy-subrc <> 0.
        CASE sy-subrc.
          WHEN 5.
            count_no_adress = count_no_adress + 1.
          WHEN 6.
            count_no_key = count_no_key + 1.
        ENDCASE.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'INSTLN_NN'.
          imig_err-obj_key = inn_anlage.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.

      ELSE.
        ADD anz_obj TO anz_inn.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.


* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_inn.
      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.

* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl Anlagen:', 50 anz_inn.
    WRITE: / 'Enthalten Strukturen KEY', 50 anz_key.
    WRITE: / '                     DATA', 50 anz_data.
    WRITE: / '                     RCAT', 50 anz_rcat.
    WRITE: / '                     POD', 50 anz_pod.
*    SKIP.
*    WRITE: / 'Anzahl Anlagen ohne Adresse: ', 50 count_no_adress.
*    SKIP.
*    WRITE: / 'Anzahl Anlagen ohne Abl-Einh aus der Regionalstruktur: ',
*              50 count_no_key.
*    SKIP.
    WRITE: / 'Fehler bei Dateierstellung INSTLN_NN:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_inn.
  ENDIF.

*----------------------------------------------------------------------
* INSTLNCHNN  Anlagenänderung für Netznutzung
*----------------------------------------------------------------------
  IF obj_icn = 'X'.

*    WRITE: /5 'Das Objekt wurde noch nicht implementiert'.
*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'INSTLNCHNN'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt
*
    PERFORM erst_entlade_files USING dat_icn.
*
* Schlüssel aus Relevanztabelle ermitteln
    SELECT obj_key FROM /adesso/mte_rel INTO TABLE icn_anlage
                                  WHERE firma  = firma
                                  AND   object = 'INSTLNCHNN'.
    IF sy-subrc NE 0.
      SKIP.
      WRITE: /
       'keine Daten für Anlagenänderung in Relevanztabelle gefunden'.
      EXIT.
    ELSE.
      IF NOT p_split IS INITIAL.
        REPLACE '.' WITH '01.' INTO ent_file.
      ENDIF.

      PERFORM open_entlade_file.
    ENDIF.

    LOOP AT icn_anlage.


      CALL FUNCTION '/ADESSO/MTE_ENT_INSTLNCHNN'
        EXPORTING
          firma        = firma
          x_anlage     = icn_anlage
          pfad_dat_ent = ent_file
*         X_HISTORISCH = 'X'
        IMPORTING
          anz_obj      = anz_obj
          anz_key      = anz_key
          anz_data     = anz_data
          anz_rcat     = anz_rcat
          anz_pod      = anz_pod
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
          gen_error    = 4
          error        = 5
          no_adress    = 6
          no_key       = 7
          OTHERS       = 8.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'INSTLNCHNN'.
          imig_err-obj_key = icn_anlage.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_icn.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.


* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_icn.
      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.
*
* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl Anlagenänderungen (NN):', 50 anz_icn.
    WRITE: / 'Enthaltene Strukturen KEY', 50 anz_key.
    WRITE: / '                      DATA', 50 anz_data.
    WRITE: / '                      RCAT', 50 anz_rcat.
    WRITE: / '                      POD', 50 anz_pod.     "Nuss 14.01.2013
    SKIP 2.
    WRITE: / 'Fehler bei Dateierstellung INSTLNCHNN:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_icn.


  ENDIF.


*-----------------------------------------------------------------------

*INSTPLAN  Ratenplan anlegen
  IF obj_ipl EQ 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'INSTPLAN'.
**< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_ipl.

* Schlüssel aus Relevanztabelle ermitteln
    SELECT obj_key FROM /adesso/mte_rel INTO TABLE ipl_vkont
                                  WHERE firma  = firma
                                  AND   object = 'INSTPLAN'.
    IF sy-subrc NE 0.
      SKIP.
      WRITE: /
       'keine Daten für Ratenplan in Relevanztabelle gefunden'.
      EXIT.
    ELSE.
      IF NOT p_split IS INITIAL.
        REPLACE '.' WITH '01.' INTO ent_file.
      ENDIF.

      PERFORM open_entlade_file.
    ENDIF.


    LOOP AT ipl_vkont.

      CALL FUNCTION '/ADESSO/MTE_ENT_INSTPLAN'
        EXPORTING
          firma        = firma
          x_vkont      = ipl_vkont
          pfad_dat_ent = ent_file
        IMPORTING
          anz_obj      = anz_obj
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
*         no_data      = 4
          error        = 5
          OTHERS       = 6.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'INSTPLAN'.
          imig_err-obj_key = ipl_vkont.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_ipl.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.


* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_ipl.
      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.

* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl Ratenpläne:', anz_ipl.
    SKIP.
    WRITE: / 'Fehler bei Dateierstellung INSTPLAN:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_ipl.

  ENDIF.
*-----------------------------------------------------------------------

*INST_MGMT  Geräteeinbau /-ausbau /-wechsel
  IF obj_inm EQ 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'INST_MGMT'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_inm.

* Schlüssel aus Relevanztabelle ermitteln
    SELECT obj_key FROM /adesso/mte_rel INTO TABLE inm_anlage
                                  WHERE firma  = firma
                                  AND   object = 'INST_MGMT'.
    IF sy-subrc NE 0.
      SKIP.
      WRITE: /
           'keine Daten für Anlage in Relevanztabelle gefunden'.
      EXIT.
    ELSE.

      IF NOT p_split IS INITIAL.
        REPLACE '.' WITH '01.' INTO ent_file.
      ENDIF.

      PERFORM open_entlade_file.

*   Löschen der Hiftabelle /ADESSO/MTE_HTGE
      DELETE  FROM /adesso/mte_htge
                          WHERE   equnr NE space.

      IF sy-subrc EQ 0.
        MESSAGE  s001(/adesso/mt_n)  WITH  sy-dbcnt
                                'Einträge aus HT-GER wurden gelöscht'.
        WRITE : / sy-dbcnt, 'Einträge würden gelöscht'.
        COMMIT WORK.
      ENDIF.

    ENDIF.

*> Sortierung der Anlagen nach Sparte
    LOOP AT inm_anlage.

** Test
*      CHECK inm_anlage = '0050197866'.
*      BREAK-POINT.


      SELECT SINGLE * FROM eanl WHERE anlage = inm_anlage.
      IF sy-subrc EQ 0.
        MOVE eanl-anlage TO inm_anlage_s-anlage.
        MOVE eanl-sparte TO inm_anlage_s-sparte.
        APPEND inm_anlage_s.
        CLEAR inm_anlage_s.
      ENDIF.
    ENDLOOP.
*   Sortierung der Anlagen nach Sparte
    SORT inm_anlage_s BY sparte.

*   Füllen der Hilfstabelle 'Geräte' zur späteren Weiterverarbeitung
*    PERFORM fill_ht_ger.     "Geräte
    PERFORM fill_ht_ger_inf.  "Geräteinfosätze

    CLEAR iht_ger.
    REFRESH iht_ger.
    SELECT * FROM /adesso/mte_htge INTO TABLE iht_ger.

*   interne Tabelle wird aufgeteilt in Wechsel mit allen verknüpften
*   Geräten und den Rest.
    SELECT * FROM /adesso/mte_htge INTO TABLE iht_gerh
                        WHERE vorgang = 'H'.
*    PERFORM split_ihtger.              "Geräte
    PERFORM split_ihtger_inf.           "Geräteinfosätze
    CLEAR:  iht_ger, iht_gerh.
    REFRESH: iht_ger, iht_gerh.

*--------- Normale Datei ausser Wechselbezüge erzeugen---------->>>>>>
*    SORT iht_gern BY equnr ab vorgang. "WICHTIG !!!!!     "Nuss 13.11.2015 Auskommentiert
    SORT iht_gern BY equnr ab ASCENDING vorgang DESCENDING.  "Nuss 13.11.2015  rein

    LOOP AT iht_gern.
*     Füllen der Entladedatei INST_MGMT
*      Geräte
*      CALL FUNCTION '/ADESSO/MTE_ENT_INST_MGMT'
*        EXPORTING
*          firma         = firma
*          x_htger       = iht_gern
*          pfad_dat_ent  = ent_file
*        IMPORTING
*          anz_obj       = anz_obj
*          anz_interface = anz_interface
*          anz_auto_zw   = anz_auto_zw
*          anz_auto_ger  = anz_auto_ger
*          anz_container = anz_container
*        TABLES
*          meldung       = imeldung
*        EXCEPTIONS
*          no_open       = 1
*          no_close      = 2
*          wrong_data    = 3
*          error         = 4
*          OTHERS        = 5.

*    Geräteinfosätze
      CALL FUNCTION '/ADESSO/MTE_ENT_INST_MGMT_INF'
        EXPORTING
          firma         = firma
          x_htger       = iht_gern
          pfad_dat_ent  = ent_file
        IMPORTING
          anz_obj       = anz_obj
          anz_interface = anz_interface
          anz_auto_zw   = anz_auto_zw
          anz_auto_ger  = anz_auto_ger
          anz_container = anz_container
        TABLES
          meldung       = imeldung
        EXCEPTIONS
          no_open       = 1
          no_close      = 2
          wrong_data    = 3
          error         = 4
          OTHERS        = 5.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'INST_MGMT'.
          imig_err-obj_key = iht_gern-equnr.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_inm.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.

*     Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH
                'Anzahl durchlaufender Objekte bzw. Vorgänge:'
                                                       cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_inm.
      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.
*--------- Normale Datei ausser Wechselbezüge erzeugen----------<<<<<

*--------- Datei mit Wechselbezügen erzeugen ------------------->>>>>
    CLEAR ent_file.
    CONCATENATE exp_path dat_inm 'W' '.' exp_ext
          INTO ent_file.

    OPEN DATASET ent_file FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
    IF sy-subrc NE 0.
      CONCATENATE 'Datei' ent_file
       'konnte nicht geöffnet werden'
                         INTO imig_err-meldung SEPARATED BY space.
      APPEND imig_err.
      EXIT.
    ENDIF.

    CLEAR: counter, cnt_index.

    MESSAGE  s001(/adesso/mt_n)  WITH
            'Jetzt kommt die Datei mit Wechselbezügen'.

    SORT iht_gerw BY ab vorgang. "WICHTIG !!!!!

    LOOP AT iht_gerw.
*     Geräte
*     Füllen der Entladedatei INST_MGMT
*      CALL FUNCTION '/ADESSO/MTE_ENT_INST_MGMT'
*        EXPORTING
*          firma         = firma
*          x_htger       = iht_gerw
*          pfad_dat_ent  = ent_file
*        IMPORTING
*          anz_obj       = anz_obj
*          anz_interface = anz_interface
*          anz_auto_zw   = anz_auto_zw
*          anz_auto_ger  = anz_auto_ger
*          anz_container = anz_container
*        TABLES
*          meldung       = imeldung
*        EXCEPTIONS
*          no_open       = 1
*          no_close      = 2
*          wrong_data    = 3
*          error         = 4
*          OTHERS        = 5.

*     Geräteinfosätze
      CALL FUNCTION '/ADESSO/MTE_ENT_INST_MGMT_INF'
        EXPORTING
          firma         = firma
          x_htger       = iht_gerw
          pfad_dat_ent  = ent_file
        IMPORTING
          anz_obj       = anz_obj
          anz_interface = anz_interface
          anz_auto_zw   = anz_auto_zw
          anz_auto_ger  = anz_auto_ger
          anz_container = anz_container
        TABLES
          meldung       = imeldung
        EXCEPTIONS
          no_open       = 1
          no_close      = 2
          wrong_data    = 3
          error         = 4
          OTHERS        = 5.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'INST_MGMT'.
          imig_err-obj_key = iht_gerw-equnr.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_inm.
      ENDIF.

*     Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH
                 'Anzahl durchlaufender Objekte bzw. Vorgänge (03):'
                                                        cnt_index .
        CLEAR counter.
      ENDIF.

    ENDLOOP.

    CLOSE DATASET ent_file.
    IF sy-subrc NE 0.
      CONCATENATE 'Datei' ent_file
       'konnte nicht geschlossen werden'
                         INTO imig_err-meldung SEPARATED BY space.
      APPEND imig_err.
    ENDIF.
*--------- Datei mit Wechselbezügen erzeugen -------------------<<<<<<

*   Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl Vorgänge Geräte Einbau-Ausbau:', 50 anz_inm COLOR 3.
    WRITE: / 'Enthaltene Strukturen      INTERFACE', 50 anz_interface.
    WRITE: / '                           AUTO_ZW', 50 anz_auto_zw.
    WRITE: / '                           AUTO_GER', 50 anz_auto_ger.
    WRITE: / '                           CONTAINER', 50 anz_container.
    SKIP.
    WRITE: / 'Fehler bei Dateierstellung INST_MGMT:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_inm .

  ENDIF.
*-----------------------------------------------------------------------

*LOADPROF  Anlegen: Lastprofil zu Anlage
  IF obj_lop EQ 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'LOADPROF'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_lop.

* erstmal alle Schlüssel ermitteln
    SELECT obj_key FROM /adesso/mte_rel INTO TABLE ilop_anlage
                                  WHERE firma  = firma
                                  AND   object = 'INSTLN'.
    IF sy-subrc NE 0.
      SKIP.
      WRITE: /
       'keine Daten für Anlagen in Relevanztabelle gefunden'.
      EXIT.
    ELSE.

* jetzt alle Datensätze löschen, die nicht in der Tabelle
* ELPASS sind
      LOOP AT ilop_anlage.
        SELECT SINGLE * FROM elpass
               WHERE objkey = ilop_anlage
                 AND  objtype = 'INSTLN'.
        IF sy-subrc NE 0.
          DELETE ilop_anlage.
        ENDIF.
      ENDLOOP.
      IF NOT p_split IS INITIAL.
        REPLACE '.' WITH '01.' INTO ent_file.
      ENDIF.

      PERFORM open_entlade_file.
    ENDIF.

    LOOP AT ilop_anlage.

      CALL FUNCTION '/ADESSO/MTE_ENT_LOADPROF'
        EXPORTING
          firma        = firma
          x_anlage     = ilop_anlage
          pfad_dat_ent = ent_file
        IMPORTING
          anz_obj      = anz_obj
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
*         no_data      = 4
          error        = 5
          OTHERS       = 6.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'LOADPROF'.
          imig_err-obj_key = ilop_anlage.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_lop.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.


* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_lop.
      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.

* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl Lastprofil zu Anlage:', anz_lop.
    SKIP.
    WRITE: / 'Fehler bei Dateierstellung LOADPROF:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
               'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                              anz_lop.

  ENDIF.

*-----------------------------------------------------------------------
*LOT         Stichprobenlos
  IF obj_lot EQ 'X'.
*    PERFORM erst_entlade_files USING dat_lot.
* Fuba-Aufruf

    MESSAGE  i001(/adesso/mt_n)  WITH  'Objekt noch nicht implementiert'.
    EXIT.
  ENDIF.
*-----------------------------------------------------------------------

*METERREAD  Zählerstand anlegen
  IF obj_mrd EQ 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'METERREAD'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_mrd.

* Schlüssel aus ermitteln
    SELECT * FROM /adesso/mte_htge INTO TABLE iht_ger_met
            WHERE action = '01'
               OR action = '04'
               OR action = '06'.

    IF sy-subrc NE 0.
      SKIP.
      WRITE: /
           'keine Daten für Meterread in /adesso/mte_htge gefunden'.
      EXIT.
    ELSE.
      SORT iht_ger_met BY equnr action.
      IF NOT p_split IS INITIAL.
        REPLACE '.' WITH '01.' INTO ent_file.
      ENDIF.

      PERFORM open_entlade_file.
    ENDIF.

    DATA:
      count_no_data   TYPE i,
      count_no_reason TYPE i,
      count_lines     TYPE i.
    DESCRIBE TABLE iht_ger_met LINES count_lines.

    LOOP AT iht_ger_met.

* Test
*      CHECK iht_ger_met-anlage = '0051066739'.
*      BREAK-POINT.

*   Füllen der Entladedatei METERREAD
*   Aufruf des FUBAS pro iht_ger-Satz
*      CALL FUNCTION '/ADESSO/MTE_ENT_METERREAD'
*        EXPORTING
*          firma        = firma
*          x_htger      = iht_ger_met
*          pfad_dat_ent = ent_file
*        IMPORTING
*          anz_obj      = anz_obj
*          anz_ieablu   = anz_ieablu
*        TABLES
*          meldung      = imeldung
*        EXCEPTIONS
*          no_open      = 1
*          no_close     = 2
*          wrong_data   = 3
*          error        = 4
*          no_data      = 5
*          no_reason    = 6
*          OTHERS       = 7.

      CALL FUNCTION '/ADESSO/MTE_ENT_METERREAD_INF'
        EXPORTING
          firma        = firma
          x_htger      = iht_ger_met
          pfad_dat_ent = ent_file
        IMPORTING
          anz_obj      = anz_obj
          anz_ieablu   = anz_ieablu
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
          error        = 4
          no_data      = 5
          no_reason    = 6
          OTHERS       = 7.

      IF sy-subrc <> 0.
        IF sy-subrc < 4.
          LOOP AT imeldung.
            imig_err-firma  = firma.
            imig_err-object = 'METERREAD'.
            imig_err-obj_key = iht_ger_met-equnr.
            imig_err-meldung = imeldung-meldung.
            APPEND imig_err.
          ENDLOOP.
        ENDIF.
        CASE sy-subrc.
          WHEN 4.
            "Beleg wurde bereits entladen. Es können einem Equipment
            "mehrere Anlagen zugeordnet sein.
          WHEN 5.
            count_no_data = count_no_data + 1.
          WHEN 6.
            count_no_reason = count_no_reason + 1.
        ENDCASE.
      ENDIF.

      ADD anz_obj TO anz_mrd.
      ADD anz_obj TO cnt_exp_file.

* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH
                'Anzahl durchlaufender Objekte bzw. Vorgänge:'
                                                       cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_mrd.
      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.

* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Zu verarbeitende sätze aus /adesso/mte_htge: ', 50 count_lines.
    WRITE: / 'Anlagen ohne Ableseergebnisse: ' , 50 count_no_data.
    WRITE: / 'Anlagen ohne relevanten Ablesegrund: ', 50 count_no_reason.
    SKIP.
    WRITE: / 'Anzahl Ableseergebnisse:', 50 anz_mrd.
    WRITE: / 'Enthaltene Strukturen IEABLU', 50 anz_ieablu.
    SKIP.
    WRITE: / 'Fehler bei Dateierstellung METERREAD:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
               'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                              anz_mrd.

  ENDIF.
*-----------------------------------------------------------------------

*MOVE_IN  Anlegen: Einzug / Versorgungsvertrag
  IF obj_moi EQ 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'MOVE_IN'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_moi.

* Schlüssel aus Relevanztabelle ermitteln
    SELECT obj_key FROM /adesso/mte_rel INTO TABLE imoi_vertrag
                                  WHERE firma  = firma
                                  AND   object = 'MOVE_IN'.
    IF sy-subrc NE 0.
      SKIP.
      WRITE: /
       'keine Daten für Verträge in Relevanztabelle gefunden'.
      EXIT.
    ELSE.
      IF NOT p_split IS INITIAL.
        REPLACE '.' WITH '01.' INTO ent_file.
      ENDIF.

      PERFORM open_entlade_file.
    ENDIF.

    LOOP AT imoi_vertrag.

**   Test
*      CHECK imoi_vertrag = '0030011397'.
*      BREAK-POINT.

      CALL FUNCTION '/ADESSO/MTE_ENT_MOVE_IN'
        EXPORTING
          firma        = firma
          x_vertrag    = imoi_vertrag
          pfad_dat_ent = ent_file
        IMPORTING
          anz_obj      = anz_obj
          anz_everd    = anz_everd
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
*         no_data      = 4
          error        = 5
          OTHERS       = 6.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'MOVE_IN'.
          imig_err-obj_key = imoi_vertrag.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_moi.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.


* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_moi.
      ENDIF.
    ENDLOOP.

    PERFORM close_entlade_file.

*******************************************************************************
* MOVE_IN_L
*******************************************************************************
**  Jetzt kommtz die Datei MOVE_IN_L
    SELECT SINGLE * FROM /adesso/mte_rel
       WHERE firma = firma
        AND object = 'MOVE_IN_L'.
    IF sy-subrc = 0.
      CLEAR ent_file.
      CONCATENATE exp_path 'MOVE_INL' '.' exp_ext
        INTO ent_file.

      OPEN DATASET ent_file FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
      IF sy-subrc NE 0.
        CONCATENATE 'Datei' ent_file
         'konnte nicht geöffnet werden'
                           INTO imig_err-meldung SEPARATED BY space.
        APPEND imig_err.
        EXIT.
      ENDIF.

      CLEAR: counter, cnt_index.

      MESSAGE  s001(/adesso/mt_n)  WITH
              'Jetzt kommt die Datei mit Folgeverträgen'.

* Schlüssel aus Relevanztabelle ermitteln
      SELECT obj_key FROM /adesso/mte_rel INTO TABLE imoi_vertragl
                                    WHERE firma  = firma
                                    AND   object = 'MOVE_IN_L'.

      LOOP AT imoi_vertragl.

        CALL FUNCTION '/ADESSO/MTE_ENT_MOVE_IN'
          EXPORTING
            firma        = firma
            x_vertrag    = imoi_vertragl
            pfad_dat_ent = ent_file
          IMPORTING
            anz_obj      = anz_obj
            anz_everd    = anz_everd
          TABLES
            meldung      = imeldung
          EXCEPTIONS
            no_open      = 1
            no_close     = 2
            wrong_data   = 3
*           no_data      = 4
            error        = 5
            OTHERS       = 6.

        IF sy-subrc <> 0.
          LOOP AT imeldung.
            imig_err-firma  = firma.
            imig_err-object = 'MOVE_IN'.
            imig_err-obj_key = imoi_vertragl.
            imig_err-meldung = imeldung-meldung.
            APPEND imig_err.
          ENDLOOP.
        ELSE.
          ADD anz_obj TO anz_moi.
        ENDIF.

*     Ausgabe Zwischenzählerstände ins Job-Log
        counter = counter + 1.
        cnt_index = cnt_index + 1.
        IF counter EQ p_step.
          MESSAGE  s001(/adesso/mt_n)  WITH
                  'Anzahl durchlaufender Objekte bzw. Vorgänge (03):'
                                                         cnt_index .
          CLEAR counter.
        ENDIF.

      ENDLOOP.
      CLOSE DATASET ent_file.
      IF sy-subrc NE 0.
        CONCATENATE 'Datei' ent_file
         'konnte nicht geschlossen werden'
                           INTO imig_err-meldung SEPARATED BY space.
        APPEND imig_err.
      ENDIF.
    ENDIF.
*************************************************************************************
* END MOVE_IN_L
************************************************************************************

* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl Verträge:', 50 anz_moi.
    WRITE: / 'Enthaltene Strukturen EVERD', 50 anz_everd.
    SKIP 2.
    WRITE: / 'Fehler bei Dateierstellung MOVE_IN:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_moi.


  ENDIF.
*-----------------------------------------------------------------------
* MOVE_IN_H   Anlegen: Historischer Versorgungsvertrag
  IF obj_moh EQ 'X'.

* > Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'MOVE_IN_H'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_moh.

* Schlüssel aus Relevanztabelle ermitteln
    SELECT obj_key FROM /adesso/mte_rel INTO TABLE imoh_vertrag
                                  WHERE firma  = firma
                                  AND   object = 'MOVE_IN_H'.

    IF sy-subrc NE 0.
      SKIP.
      WRITE: /
       'keine Daten für histor. Verträge in Relevanztabelle gefunden'.
      EXIT.
    ELSE.
      IF NOT p_split IS INITIAL.
        REPLACE '.' WITH '01.' INTO ent_file.
      ENDIF.

      PERFORM open_entlade_file.
    ENDIF.

    LOOP AT imoh_vertrag.

      CALL FUNCTION '/ADESSO/MTE_ENT_MOVE_IN_H'
        EXPORTING
          firma        = firma
          x_vertrag    = imoh_vertrag
          pfad_dat_ent = ent_file
        IMPORTING
          anz_obj      = anz_obj
          anz_everd    = anz_everd
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
          gen_error    = 4
          error        = 5
          OTHERS       = 6.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'MOVE_IN_H'.
          imig_err-obj_key = imoh_vertrag.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_moh.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.

* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_moh.
      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.

* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl hist. Verträge:', 50 anz_moh.
    WRITE: / 'Enthaltene Strukturen EVERD', 50 anz_everd.
    SKIP 2.
    WRITE: / 'Fehler bei Dateierstellung MOVE_IN_H:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_moh.
    LOOP AT imoh_vertrag.

      CALL FUNCTION '/ADESSO/MTE_ENT_MOVE_IN_H'
        EXPORTING
          firma        = firma
          x_vertrag    = imoh_vertrag
          pfad_dat_ent = ent_file
        IMPORTING
          anz_obj      = anz_obj
          anz_everd    = anz_everd
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
          gen_error    = 4
          error        = 5
          OTHERS       = 6.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'MOVE_IN_H'.
          imig_err-obj_key = imoh_vertrag.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_moh.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.

* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_moh.
      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.

* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl hist. Verträge:', 50 anz_moh.
    WRITE: / 'Enthaltene Strukturen EVERD', 50 anz_everd.
    SKIP 2.
    WRITE: / 'Fehler bei Dateierstellung MOVE_IN_H:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_moh.


  ENDIF.

*-----------------------------------------------------------------------
* MOVE_OUT   Anlagen Auszug
  IF obj_moo EQ 'X'.

* > Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'MOVE_OUT'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_moo.

* Schlüssel aus Relevanztabelle ermitteln
    SELECT obj_key FROM /adesso/mte_rel INTO TABLE imoo_vertrag
                                  WHERE firma  = firma
                                  AND   object = 'MOVE_OUT'.

    IF sy-subrc NE 0.
      SKIP.
      WRITE: /
       'keine Daten für Auszüge in Relevanztabelle gefunden'.
      EXIT.
    ELSE.
      IF NOT p_split IS INITIAL.
        REPLACE '.' WITH '01.' INTO ent_file.
      ENDIF.

      PERFORM open_entlade_file.
    ENDIF.

    LOOP AT imoo_vertrag.

      CALL FUNCTION '/ADESSO/MTE_ENT_MOVE_OUT'
        EXPORTING
          firma        = firma
          x_vertrag    = imoo_vertrag
          pfad_dat_ent = ent_file
        IMPORTING
          anz_obj      = anz_obj
          anz_eausd    = anz_eausd
          anz_eausvd   = anz_eausvd
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
          gen_error    = 4
          error        = 5
          OTHERS       = 6.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'MOVE_OUT'.
          imig_err-obj_key = imoh_vertrag.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_moo.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.
* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING 'MOVE_OUT'.
      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.

*   Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl Auszugsbelege:', 50 anz_moo.
    WRITE: / 'Enthaltene Strukturen EAUSD', 50 anz_eausd.
    WRITE: / '                      EAUSVD', 50 anz_eausvd.
    SKIP 2.
    WRITE: / 'Fehler bei Dateierstellung MOVE_OUT:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_moo.



  ENDIF.

*-----------------------------------------------------------------------

*NOTE_CON  Anlegen: Außendiensthinweise zum Anschlußobjekt
  IF obj_noc EQ 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'NOTE_CON'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_noc.

* Schlüssel aus Relevanztabelle ermitteln
    SELECT obj_key FROM /adesso/mte_rel INTO TABLE inoc_haus
                                  WHERE firma  = firma
                                  AND   object = 'NOTE_CON'.
    IF sy-subrc NE 0.
      SKIP.
      WRITE: /
  'keine Daten für Hinweise Anschlußobjekt in Relevanztabelle gefunden'.
      EXIT.
    ELSE.
      IF NOT p_split IS INITIAL.
        REPLACE '.' WITH '01.' INTO ent_file.
      ENDIF.

      PERFORM open_entlade_file.
    ENDIF.

    LOOP AT inoc_haus.

      CALL FUNCTION '/ADESSO/MTE_ENT_NOTE_CON'
        EXPORTING
          firma        = firma
          x_haus       = inoc_haus
          pfad_dat_ent = ent_file
        IMPORTING
          anz_obj      = anz_obj
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
*         no_data      = 4
          error        = 5
          OTHERS       = 6.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'NOTE_CON'.
          imig_err-obj_key = inoc_haus.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_noc.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.


* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_noc.
      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.

* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl Hinweise zu Anschlußobjekten:', anz_noc.
    SKIP.
    WRITE: / 'Fehler bei Dateierstellung NOTE_CON:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_noc.

  ENDIF.
*-----------------------------------------------------------------------

*NOTE_DLC  Anlegen: Außendiensthinweise zum Geräteplatz
  IF obj_nod EQ 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'NOTE_DLC'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_nod.

* Schlüssel aus Relevanztabelle ermitteln
    SELECT obj_key FROM /adesso/mte_rel INTO TABLE inod_devloc
                                  WHERE firma  = firma
                                  AND   object = 'NOTE_DLC'.
    IF sy-subrc NE 0.
      SKIP.
      WRITE: /
   'keine Daten für Hinweise Geräteplatz in Relevanztabelle gefunden'.
      EXIT.
    ELSE.
      IF NOT p_split IS INITIAL.
        REPLACE '.' WITH '01.' INTO ent_file.
      ENDIF.

      PERFORM open_entlade_file.
    ENDIF.

    LOOP AT inod_devloc.

      CALL FUNCTION '/ADESSO/MTE_ENT_NOTE_DLC'
        EXPORTING
          firma        = firma
          x_devloc     = inod_devloc
          pfad_dat_ent = ent_file
        IMPORTING
          anz_obj      = anz_obj
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
*         no_data      = 4
          error        = 5
          OTHERS       = 6.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'NOTE_DLC'.
          imig_err-obj_key = inod_devloc.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_nod.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.


* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_nod.
      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.

* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl Ablesehinweise Geräteplatz:', anz_nod.
    SKIP.
    WRITE: / 'Fehler bei Dateierstellung NOTE_DLC:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_nod.

  ENDIF.
*-----------------------------------------------------------------------

*PARTNER  Anlegen: Geschäftspartner
  IF obj_par EQ 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'PARTNER'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_par.

* Schlüssel aus Relevanztabelle ermitteln
    SELECT obj_key FROM /adesso/mte_rel INTO TABLE i_partner
                                  WHERE firma  = firma
                                  AND   object = 'PARTNER'.
    IF sy-subrc NE 0.
      SKIP.
      WRITE: / 'keine Daten für Partner in Relevanztabelle gefunden'.
      EXIT.
    ELSE.
      IF NOT p_split IS INITIAL.
        REPLACE '.' WITH '01.' INTO ent_file.
      ENDIF.

      PERFORM open_entlade_file.
    ENDIF.

    LOOP AT i_partner.

***   Test
*      CHECK i_partner = '0010000029'.
*      BREAK-POINT.


      CALL FUNCTION '/ADESSO/MTE_ENT_PARTNER'
        EXPORTING
          firma        = firma
          x_partner    = i_partner
          pfad_dat_ent = ent_file
        IMPORTING
          anz_obj      = anz_obj
          anz_init     = anz_init
          anz_ekun     = anz_ekun
          anz_but000   = anz_but000
          anz_buticom  = anz_buticom
          anz_but001   = anz_but001
          anz_but0bk   = anz_but0bk
          anz_but020   = anz_but020
          anz_but021   = anz_but021
          anz_but0cc   = anz_but0cc
          anz_shipto   = anz_shipto
          anz_taxnum   = anz_taxnum
          anz_eccard   = anz_eccard
          anz_eccardh  = anz_eccardh
          anz_but0is   = anz_but0is
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
          no_data      = 4
          error        = 5
          OTHERS       = 6.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'PARTNER'.
          imig_err-obj_key = i_partner.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_par.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.


* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_par.
      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.

    SORT imig_err.
    DELETE ADJACENT DUPLICATES FROM imig_err COMPARING ALL FIELDS.

* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.

    WRITE: / 'Anzahl Geschäftspartner:', 50 anz_par.
    WRITE: / 'Enthaltene Strukturen INIT', 50 anz_init.
    WRITE: / '                      EKUN', 50 anz_ekun.
    WRITE: / '                      BUT000', 50 anz_but000.
    WRITE: / '                      BUTICOM', 50 anz_buticom.
    WRITE: / '                      BUT001', 50 anz_but001.
    WRITE: / '                      BUT0BK', 50 anz_but0bk.
    WRITE: / '                      BUT020', 50 anz_but020.
    WRITE: / '                      BUT021', 50 anz_but021.
    WRITE: / '                      BUT0CC', 50 anz_but0cc.
    WRITE: / '                      SHIPTO', 50 anz_shipto.
    WRITE: / '                      TAXNUM', 50 anz_taxnum.
    WRITE: / '                      ECCARD', 50 anz_eccard.
    WRITE: / '                      ECCARDH', 50 anz_eccardh.
    WRITE: / '                      BUT0IS', 50 anz_but0is.

    SKIP.
    WRITE: / 'Fehler bei Dateierstellung PARTNER:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_par.

  ENDIF.
*-----------------------------------------------------------------------

*PARTN_NOTE  Notizen zum Geschäftspartner
  IF obj_pno EQ 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'PARTN_NOTE'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_pno.

* Schlüssel aus Relevanztabelle ermitteln
    SELECT obj_key FROM /adesso/mte_rel INTO TABLE ipno_partner
                                  WHERE firma  = firma
                                  AND   object = 'PARTN_NOTE'.
    IF sy-subrc NE 0.
      SKIP.
      WRITE: / 'keine Daten für Partnernotizen in Relevanztabelle gefunden'.
      EXIT.
    ELSE.
      IF NOT p_split IS INITIAL.
        REPLACE '.' WITH '01.' INTO ent_file.
      ENDIF.

      PERFORM open_entlade_file.
    ENDIF.

    LOOP AT ipno_partner.

      CALL FUNCTION '/ADESSO/MTE_ENT_PARTN_NOTE'
        EXPORTING
          firma        = firma
          x_partner    = ipno_partner
          pfad_dat_ent = ent_file
        IMPORTING
          anz_obj      = anz_obj
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
*         no_data      = 4
          error        = 5
          OTHERS       = 6.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'PARTN_NOTE'.
          imig_err-obj_key = ipno_partner.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_pno.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.


* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_pno.
      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.

* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl Notizen zum Geschäftspartner:', anz_pno.
    SKIP.
    WRITE: / 'Fehler bei Dateierstellung PARTN_NOTE:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_pno.
  ENDIF.
*-----------------------------------------------------------------------

*PAYMENT  Anlegen: Zahlung auf offenen Posten
  IF obj_pay EQ 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'PAYMENT'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_pay.

* Schlüssel aus Relevanztabelle ermitteln
    SELECT obj_key FROM /adesso/mte_rel INTO TABLE ipay_abplan
                                  WHERE firma  = firma
                                  AND   object = 'BBP_MULT'.
    IF sy-subrc NE 0.
      SKIP.
      WRITE: / 'keine Daten für Zahlungen in Relevanztabelle gefunden'.
      EXIT.
    ELSE.
      IF NOT p_split IS INITIAL.
        REPLACE '.' WITH '01.' INTO ent_file.
      ENDIF.

      PERFORM open_entlade_file.
    ENDIF.


    LOOP AT ipay_abplan.

**  Test
*      CHECK ipay_abplan = '000602488975'.
*      CHECK ipay_abplan = '005604585704'.
*      BREAK-POINT.

*     --> Nuss 13.01.2016 neuer FuBa
*      CALL FUNCTION '/ADESSO/MTE_ENT_PAYMENT'
*        EXPORTING
*          firma        = firma
*          x_abplan     = ipay_abplan
*          pfad_dat_ent = ent_file
*        IMPORTING
*          anz_obj      = anz_obj
*        TABLES
*          meldung      = imeldung
*        EXCEPTIONS
*          no_open      = 1
*          no_close     = 2
*          wrong_data   = 3
**         no_data      = 4
*          error        = 5
*          OTHERS       = 6.

      CALL FUNCTION '/ADESSO/MTE_ENT_PAYMENT_02'
        EXPORTING
          firma        = firma
          x_abplan     = ipay_abplan
          pfad_dat_ent = ent_file
        IMPORTING
          anz_obj      = anz_obj
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
          gen_error    = 4
          error        = 5
          OTHERS       = 6.
*   <-- Nuss 13.01.2016

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'PAYMENT'.
          imig_err-obj_key = ipay_abplan.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_pay.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.


* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_pay.
      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.
    CLOSE DATASET jvl_file.

* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl Ausgleichsbelege:', anz_pay.
    SKIP.
    WRITE: / 'Meldung bei Dateierstellung PAYMENT:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_pay.

  ENDIF.

*-----------------------------------------------------------------------

*POD         Zählpunkt (Point of Delivery)
  IF obj_pod EQ 'X'.
*    PERFORM erst_entlade_files USING dat_pod.
* Fuba-Aufruf

    MESSAGE  i001(/adesso/mt_n)  WITH  'Objekt noch nicht implementiert'.
    EXIT.
  ENDIF.
*-----------------------------------------------------------------------

*PODCHANGE  Ändern Zählpunkt
  IF obj_poc EQ 'X'.
*    PERFORM erst_entlade_files USING dat_poc.
* Fuba-Aufruf

    MESSAGE  i001(/adesso/mt_n)  WITH  'Objekt noch nicht implementiert'.
    EXIT.
  ENDIF.
*-----------------------------------------------------------------------

*PODSERVICE  Anlegen Zählpunktservice
  IF obj_pos EQ 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'PODSERVICE'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_pos.

* Schlüssel aus Relevanztabelle ermitteln
    SELECT obj_key FROM /adesso/mte_rel INTO TABLE ipos_anlage
                                  WHERE firma  = firma
                                  AND   object = 'INSTLN'.
    IF sy-subrc NE 0.
      SKIP.
      WRITE: /
      'keine Daten Anlagen für Zählpunktservice in Relevanztabelle'.
      EXIT.
    ELSE.
      IF NOT p_split IS INITIAL.
        REPLACE '.' WITH '01.' INTO ent_file.
      ENDIF.

      PERFORM open_entlade_file.
    ENDIF.

    LOOP AT ipos_anlage.

      CALL FUNCTION '/ADESSO/MTE_ENT_PODSERVICE'
        EXPORTING
          firma        = firma
          x_anlage     = ipos_anlage
          pfad_dat_ent = ent_file
        IMPORTING
          anz_obj      = anz_obj
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
*         no_data      = 4
          error        = 5
          OTHERS       = 6.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'PODSERVICE'.
          imig_err-obj_key = ipos_anlage.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_pos.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.


* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl zu prüfender Objekte:'
                                                              cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_pos.
      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.

*   Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl  Zählpunktservice:', anz_pos.
    SKIP.
    WRITE: / 'Fehler bei Dateierstellung PODSERVICE:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_pos.

  ENDIF.
*-----------------------------------------------------------------------

*PREMISE  Anlegen: Verbrauchsstelle
  IF obj_pre EQ 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'PREMISE'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_pre.

* Schlüssel aus Relevanztabelle ermitteln
    SELECT obj_key FROM /adesso/mte_rel INTO TABLE i_vstelle
                                  WHERE firma  = firma
                                  AND   object = 'PREMISE'.
    IF sy-subrc NE 0.
      SKIP.
      WRITE: /
       'keine Daten für Verbrauchsstelle in Relevanztabelle gefunden'.
      EXIT.
    ELSE.
      IF NOT p_split IS INITIAL.
        REPLACE '.' WITH '01.' INTO ent_file.
      ENDIF.

      PERFORM open_entlade_file.
    ENDIF.

    LOOP AT i_vstelle.

      CALL FUNCTION '/ADESSO/MTE_ENT_PREMISE'
        EXPORTING
          firma        = firma
          x_vstelle    = i_vstelle
          pfad_dat_ent = ent_file
        IMPORTING
          anz_obj      = anz_obj
          anz_evbsd    = anz_evbsd
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
*         no_data      = 4
          error        = 5
          OTHERS       = 6.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'PREMISE'.
          imig_err-obj_key = i_vstelle.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_pre.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.


* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_pre.
      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.

* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl  Verbrauchsstellen:', 50 anz_pre.
    WRITE: / 'Enthaltene Strukturen EVBSD', 50 anz_evbsd.
    SKIP.
    WRITE: / 'Fehler bei Dateierstellung PREMISE:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_pre.

  ENDIF.
*-----------------------------------------------------------------------

*REFVALUES  Anlegen: Bezugsgrößen
  IF obj_rva EQ 'X'.

*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'REFVALUES'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_rva.

* Schlüssel aus Relevanztabelle ermitteln
    SELECT obj_key FROM /adesso/mte_rel INTO TABLE irva_anlage
                                  WHERE firma  = firma
                                  AND   object = 'REFVALUES'.
    IF sy-subrc NE 0.
      SKIP.
      WRITE: / 'keine Daten für Bezugsgößen in Relevanztabelle gefunden'.
      EXIT.
    ELSE.
      IF NOT p_split IS INITIAL.
        REPLACE '.' WITH '01.' INTO ent_file.
      ENDIF.

      PERFORM open_entlade_file.
    ENDIF.

    LOOP AT irva_anlage.

      CALL FUNCTION '/ADESSO/MTE_ENT_REFVALUES'
        EXPORTING
          firma        = firma
          x_anlage     = irva_anlage
          pfad_dat_ent = ent_file
        IMPORTING
          anz_obj      = anz_obj
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
*         no_data      = 4
          error        = 5
          OTHERS       = 6.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'REFVALUES'.
          imig_err-obj_key = irva_anlage.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_rva.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.


* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_rva.
      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.

* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl Anlagen mit REFVALUES:', anz_rva.
    SKIP.
    WRITE: / 'Fehler bei Dateierstellung REFVALUES:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_rva.

  ENDIF.
*-----------------------------------------------------------------------

*STRT_ROUTE  Anlegen: Ablesereihenfolge
  IF obj_srt EQ 'X'.
*> Löschen der Entlade-KSV für ausgewähltes Objekt
    PERFORM del_entl_ksv USING 'STRT_ROUTE'.
*< Löschen der Entlade-KSV für ausgewähltes Objekt

    PERFORM erst_entlade_files USING dat_srt.

* Schlüssel aus Relevanztabelle ermitteln
    SELECT obj_key FROM /adesso/mte_rel INTO TABLE isrt_anlage
                                  WHERE firma  = firma
                                  AND   object = 'INSTLN'.
    IF sy-subrc NE 0.
      SKIP.
      WRITE: /
       'keine Daten für Anlagen in Relevanztabelle gefunden'.
      EXIT.
    ELSE.

* Ermitteln der Ableseeinheiten
      LOOP AT isrt_anlage.

        SELECT SINGLE ableinh FROM eanlh INTO isrt_ableinh
                              WHERE anlage = isrt_anlage
                                AND bis    = '99991231'.
        IF sy-subrc EQ 0 AND
          isrt_ableinh NE space.
          COLLECT isrt_ableinh.
        ENDIF.

      ENDLOOP.

    ENDIF.

    IF NOT p_split IS INITIAL.
      REPLACE '.' WITH '01.' INTO ent_file.
    ENDIF.

    PERFORM open_entlade_file.

    LOOP AT isrt_ableinh.

      CALL FUNCTION '/ADESSO/MTE_ENT_STRT_ROUTE'
        EXPORTING
          firma        = firma
          x_ableinh    = isrt_ableinh
          pfad_dat_ent = ent_file
        IMPORTING
          anz_obj      = anz_obj
        TABLES
          meldung      = imeldung
        EXCEPTIONS
          no_open      = 1
          no_close     = 2
          wrong_data   = 3
*         no_data      = 4
          error        = 5
          OTHERS       = 6.

      IF sy-subrc <> 0.
        LOOP AT imeldung.
          imig_err-firma  = firma.
          imig_err-object = 'STRT_ROUTE'.
          imig_err-obj_key = isrt_ableinh.
          imig_err-meldung = imeldung-meldung.
          APPEND imig_err.
        ENDLOOP.
      ELSE.
        ADD anz_obj TO anz_srt.
        ADD anz_obj TO cnt_exp_file.
      ENDIF.


* Ausgabe Zwischenzählerstände ins Job-Log
      counter = counter + 1.
      cnt_index = cnt_index + 1.
      IF counter EQ p_step.
        MESSAGE  s001(/adesso/mt_n)  WITH  'Anzahl durchlaufender Objekte:'
                                                                cnt_index .
        CLEAR counter.
      ENDIF.

*     Entlade-Datei splitten ?
      IF NOT p_split IS INITIAL AND
         cnt_exp_file GE p_split.
        PERFORM neue_entlade_datei USING dat_srt.
      ENDIF.

    ENDLOOP.

    PERFORM close_entlade_file.

* Fehlerauswertung
    READ TABLE imig_err INDEX 1.
    IF sy-subrc EQ 0.
      MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
    ENDIF.
    SKIP.
    WRITE: / 'Anzahl  Ableseeinheiten für Laufweg:', anz_srt.
    SKIP.
    WRITE: / 'Fehler bei Dateierstellung STRT_ROUTE:'.
    LOOP AT imig_err.
      WRITE: / imig_err-obj_key,
               imig_err-meldung.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE: / 'keine Fehler aufgetreten'.
    ENDIF.

    MESSAGE  s001(/adesso/mt_n)  WITH
                'FERTIG: Anzahl Objekte bzw. Vorgänge:'
                                               anz_srt.
  ENDIF.
*-----------------------------------------------------------------------







ENDFORM.                    " Migrationsdateien_erstellen
*&---------------------------------------------------------------------*
*&      Form  erst_entlade_files
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DAT_BCN  text
*----------------------------------------------------------------------*
FORM erst_entlade_files USING    object_name TYPE emg_file.

  CONCATENATE exp_path object_name '.' exp_ext
        INTO ent_file.

ENDFORM.                    " erst_entlade_files

*&---------------------------------------------------------------------*
*&      Form  del_entl_ksv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0010   text
*----------------------------------------------------------------------*
FORM del_entl_ksv USING    VALUE(obj) TYPE any.



  CALL FUNCTION '/ADESSO/MTE_OBJKEY_MAIN'
    EXPORTING
      i_firma          = firma
      i_object         = obj
*     I_OLDKEY         =
    EXCEPTIONS
      error            = 1
      wrong_parameters = 2
      OTHERS           = 3.
  IF sy-subrc <> 0.
    MESSAGE i001(/adesso/mt_n) WITH 'Kein Objekt vorhanden zu' firma obj.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.                    " del_entl_ksv
*&---------------------------------------------------------------------*
*&      Form  fill_ht_ger
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_ht_ger.

  TABLES: eastl,
*          egerh,
*          egers,
*          equi,
          ezuz.
*          etdz.

*  DATA: sparte LIKE equi-sparte.
*  DATA: lfdnr(1) TYPE n.

  DATA: iht_ger LIKE /adesso/mte_htge OCCURS 0 WITH HEADER LINE.
  DATA: iegerh LIKE egerh OCCURS 0 WITH HEADER LINE.
*  DATA: ieastl LIKE eastl OCCURS 0 WITH HEADER LINE.
  DATA: counter_ok TYPE i.
  DATA: counter_er_1 TYPE i.
  DATA: counter_er_2 TYPE i.
  DATA: counter_er_3 TYPE i.
  DATA: counter_er_4 TYPE i.
  DATA: counter_er_5 TYPE i.
  DATA: count_anlagen TYPE i.

  LOOP AT inm_anlage_s.
*   Anlagen sind sortiert nach Sparte
    CALL FUNCTION '/ADESSO/MTE_FILL_HT_GER'
      EXPORTING
        firma      = firma
        x_anlage   = inm_anlage_s-anlage
      IMPORTING
        anz_obj    = anz_obj
      TABLES
        meldung    = imeldung
      EXCEPTIONS
        wrong_data = 1
        no_update  = 2
        error      = 3
        no_history = 5
        OTHERS     = 4.

    IF sy-subrc <> 0.
      CASE sy-subrc.
        WHEN 1.
          counter_er_1 = counter_er_1 + 1.
        WHEN 2.
          counter_er_2 = counter_er_2 + 1.
        WHEN 3.
          counter_er_3 = counter_er_3 + 1.
        WHEN 4.
          counter_er_4 = counter_er_4 + 1.
        WHEN 5.
          counter_er_5 = counter_er_5 + 1.
      ENDCASE.
      LOOP AT imeldung.
        imig_err-firma  = firma.
        imig_err-object = 'I_MGMT_HT'.
        imig_err-obj_key = inm_anlage_s-anlage.
        imig_err-meldung = imeldung-meldung.
        APPEND imig_err.
      ENDLOOP.
    ELSE.
      counter_ok = counter_ok + 1.
      ADD anz_obj TO anz_ht_upd.
    ENDIF.

  ENDLOOP.

* Fehleranzahl ausgeben
  SKIP.
  ULINE.
  WRITE: / 'Zu migrierende Anlagen: ', counter_ok.
  WRITE: / 'Fehler 01: ' , counter_er_1.
  WRITE: / 'Fehler 02: ' , counter_er_2.
  WRITE: / 'Fehler 03: ' , counter_er_3.
  WRITE: / 'Fehler 04: ' , counter_er_4.
  WRITE: / 'Fehler 05: ' , counter_er_5.

* Anzahl der berücksichtigten Anlagen melden
  DATA: BEGIN OF wa_anlage,
          anlage TYPE anlage,
        END OF wa_anlage,
        it_anlage LIKE TABLE OF wa_anlage.

  SELECT DISTINCT anlage FROM /adesso/mte_htge INTO TABLE it_anlage.
  DESCRIBE TABLE it_anlage LINES count_anlagen.
  WRITE: / 'Anzahl der berücksichtigten Anlagen: ', count_anlagen.

  ULINE.
  SKIP.

*------Rein technische Einbauten ermitteln --------------------->>>>>>
*  (haben kein Bezug zur Anlage und wurden
*   nicht in obigen Fuba berücksichtigt)
  CLEAR: iht_ger, iegerh.
  REFRESH: iht_ger, iegerh.

* Lauf über die ganze Datenbank !
  SELECT * FROM egerh INTO TABLE iegerh
                WHERE bis = '99991231'
                  AND logiknr EQ  '0'    "Makosch 24.09.08
*                 AND logiknr NE  '0'    "Makosch 24.09.08
                  AND devloc NE space.

* Prüfen, ob es einen Satz in Tabelle EASTL gibt (abr.technischer Einbau)
  LOOP AT iegerh.
    SELECT SINGLE * FROM eastl WHERE logiknr = iegerh-logiknr.
    IF sy-subrc NE 0.
*     nur technischer Einbau
      CLEAR iht_ger.
      iht_ger-equnr = iegerh-equnr.
      iht_ger-vorgang = 'O'. "Einbau technisch
      iht_ger-action = '06'. "Einbau technisch
      iht_ger-ab = iegerh-ab.
      iht_ger-bis = iegerh-bis.
      iht_ger-devloc = iegerh-devloc.
      iht_ger-zwgruppe = iegerh-zwgruppe.
      iht_ger-gerwechs = iegerh-gerwechs.
      SELECT SINGLE sparte FROM equi INTO iht_ger-sparte
                         WHERE equnr = iegerh-equnr.

*     Messdruck und Abrechnungsfaktor ermitteln
      SELECT SINGLE * FROM ezuz WHERE logiknr2 = iegerh-logiknr
                                  AND      bis = '99991231'.
      IF sy-subrc EQ 0.
        MOVE ezuz-messdrck TO iht_ger-messdrck.
        MOVE ezuz-abrfakt  TO iht_ger-abrfakt.
      ENDIF.

      APPEND iht_ger.
      CLEAR iht_ger.
    ENDIF.

  ENDLOOP.

* Speichern der Ergebniss-Tabelle (wenn nicht leer)
  READ TABLE iht_ger INDEX 1.
  IF sy-subrc EQ 0.
    INSERT  /adesso/mte_htge  FROM  TABLE  iht_ger
        ACCEPTING DUPLICATE KEYS.
    IF sy-subrc NE 0.
      WRITE:
       'Fehler beim INSERT in /adesso/mte_htge oder doppelte Schlüssel',
        '(bei 06)'.
    ENDIF.

    ADD sy-dbcnt TO anz_ht_upd.
    COMMIT WORK.
  ENDIF.
*------Rein technische Einbauten ermitteln ---------------------<<<<<<<<


* Ausgabe Updates ins Job-Log
  MESSAGE  s001(/adesso/mt_n)
        WITH  'Anzahl Update Datensätze in HT-Ger:'
                                      anz_ht_upd .

* Fehlerauswertung
  READ TABLE imig_err INDEX 1.
  IF sy-subrc EQ 0.
    MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
  ENDIF.
  SKIP.
  WRITE: / 'Anzahl Update Datensätze in HT-Ger:', anz_ht_upd.
  SKIP.
  WRITE: / 'Fehler bzw.Infos bei Update /ADESSO/MTE_HTGE:'.
  LOOP AT imig_err.
    WRITE: / imig_err-obj_key,
             imig_err-meldung(55).
  ENDLOOP.
  IF sy-subrc NE 0.
    WRITE: / 'keine Fehler aufgetreten'.
    SKIP 2.
  ELSE.
    SKIP 2.
  ENDIF.

  CLEAR imeldung.
  REFRESH: imeldung, imig_err.


ENDFORM.                    " fill_ht_ger
*&---------------------------------------------------------------------*
*&      Form  split_ihtger
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM split_ihtger.

  CLEAR: iht_gern, iht_gern[], iht_gerw, iht_gerw[].

  LOOP AT iht_ger.

* existiert die Gerätenummer in der Wechseltabelle ????
    LOOP AT iht_gerh WHERE equnr  = iht_ger-equnr
                     OR equnr_alt = iht_ger-equnr.
      EXIT.
    ENDLOOP.
* wenn ja, dann in Wechseltabelle
    IF sy-subrc EQ 0.
      MOVE-CORRESPONDING iht_ger TO iht_gerw.
      APPEND iht_gerw.

* wenn nicht, dann in die Normaltabelle
    ELSE.
      MOVE-CORRESPONDING iht_ger TO iht_gern.
      APPEND iht_gern.
    ENDIF.

  ENDLOOP.



*> -----------------------------------------------------------
* Geräteplatz des gewechselten Zählers auf den aktuellen Geräteplatz
* ändern.
  SKIP 2.
  WRITE: / 'Infos Geräteplatzänderungen:' COLOR 2.
  DATA: devloc LIKE egerh-devloc.

  LOOP AT iht_gerh.

    LOOP AT iht_gerw WHERE equnr   = iht_gerh-equnr_alt
                       AND vorgang = 'N'
* das ab-Datum muss kleiner sein, damit ein späterer Wiedereinbau
* des Gerätes in einer anderen Anlage nicht berücksichtigt wird
                       AND anlage   = iht_gerh-anlage
                       AND ab      LE iht_gerh-ab.

      MOVE iht_gerw-devloc TO devloc.

      IF iht_gerh-devloc NE iht_gerw-devloc.
        MOVE iht_gerh-devloc TO iht_gerw-devloc.
        MODIFY iht_gerw.
        WRITE: / iht_gerw-equnr+10(8),
                 'Geräteplatz:', devloc(10), 'nach Platz',
                 iht_gerh-devloc(10), 'geändert'.
      ENDIF.

    ENDLOOP.

  ENDLOOP.
  SKIP 2.
*< -----------------------------------------------------------



ENDFORM.                    " split_ihtger

*---------------------------------------------------------------------*
*       FORM neue_entlade_datei                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM neue_entlade_datei USING    object_name TYPE emg_file..

  PERFORM close_entlade_file.


*   Neuen Datei-Namen erstellen
  CLEAR cnt_exp_file.
  ADD 1 TO num_exp_file.

  CONCATENATE exp_path object_name num_exp_file '.' exp_ext
      INTO ent_file.

*  SEARCH ent_file FOR '...'.
*  IF sy-subrc NE 0.
*    CONCATENATE 'Datei-Name' ent_file
*     'konnte nicht für die Aufteilung erweitert werden'
*                       INTO imig_err-meldung SEPARATED BY space.
*    APPEND imeldung.
*    RAISE no_open.
*  ELSE.
*    sy-fdpos = sy-fdpos - 2.
*    REPLACE ent_file+sy-fdpos(2) WITH num_exp_file INTO ent_file.
*  ENDIF.

  PERFORM open_entlade_file.

ENDFORM.                    "neue_entlade_datei

*---------------------------------------------------------------------*
*       FORM open_entlade_file                                        *
*---------------------------------------------------------------------*
FORM open_entlade_file.

  OPEN DATASET ent_file FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
*  OPEN DATASET ent_file FOR OUTPUT IN TEXT MODE ENCODING NON-UNICODE.

  IF sy-subrc NE 0.
    CONCATENATE 'Datei' ent_file
    'konnte nicht geöffnet werden'
                       INTO imeldung-meldung SEPARATED BY space.
    APPEND imeldung.
    RAISE no_open.
  ENDIF.
ENDFORM.                    "open_entlade_file

*---------------------------------------------------------------------*
*       FORM close_entlade_file                                       *
*---------------------------------------------------------------------*
FORM close_entlade_file.
  CLOSE DATASET ent_file.
  IF sy-subrc NE 0.
    CONCATENATE 'Datei' ent_file
     'konnte nicht geschlossen werden'
                       INTO imig_err-meldung SEPARATED BY space.
    APPEND imig_err.
    RAISE no_open.
  ELSE.
    COMMIT WORK.
  ENDIF.
ENDFORM.                    "close_entlade_file

*&---------------------------------------------------------------------*
*&      Form  FILL_HT_GER_INF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_ht_ger_inf .


  DATA: iht_ger LIKE /adesso/mte_htge OCCURS 0 WITH HEADER LINE.
  DATA: iegerh LIKE egerh OCCURS 0 WITH HEADER LINE.
*  DATA: ieastl LIKE eastl OCCURS 0 WITH HEADER LINE.
  DATA: counter_ok TYPE i.
  DATA: counter_er_1 TYPE i.
  DATA: counter_er_2 TYPE i.
  DATA: counter_er_3 TYPE i.
  DATA: counter_er_4 TYPE i.
  DATA: counter_er_5 TYPE i.
  DATA: counter_er_6 TYPE i.
  DATA: count_anlagen TYPE i.

  LOOP AT inm_anlage_s.

*   Anlagen sind sortiert nach Sparte
    CALL FUNCTION '/ADESSO/MTE_FILL_HT_GER_NEU'
      EXPORTING
        firma      = firma
        x_anlage   = inm_anlage_s-anlage
      IMPORTING
        anz_obj    = anz_obj
      TABLES
        meldung    = imeldung
      EXCEPTIONS
        wrong_data = 1
        no_update  = 2
        error      = 3
        no_history = 4
        no_device  = 5
        OTHERS     = 6.

    IF sy-subrc <> 0.
      CASE sy-subrc.
        WHEN 1.
          counter_er_1 = counter_er_1 + 1.
        WHEN 2.
          counter_er_2 = counter_er_2 + 1.
        WHEN 3.
          counter_er_3 = counter_er_3 + 1.
        WHEN 4.
          counter_er_4 = counter_er_4 + 1.
        WHEN 5.
          counter_er_5 = counter_er_5 + 1.
        WHEN 6.
          counter_er_6 = counter_er_6 + 1.

      ENDCASE.
      LOOP AT imeldung.
        imig_err-firma  = firma.
        imig_err-object = 'I_MGMT_HT'.
        imig_err-obj_key = inm_anlage_s-anlage.
        imig_err-meldung = imeldung-meldung.
        APPEND imig_err.
      ENDLOOP.
    ELSE.
      counter_ok = counter_ok + 1.
      ADD anz_obj TO anz_ht_upd.
    ENDIF.

  ENDLOOP.

* Fehleranzahl ausgeben
  SKIP.
  ULINE.
  WRITE: / 'Zu migrierende Anlagen: ', 50 counter_ok.
  WRITE: / 'Fehler 01 (WRONG_DATA): ' , 50 counter_er_1.
  WRITE: / 'Fehler 02 (NO_UPDATE): ' , 50 counter_er_2.
  WRITE: / 'Fehler 03 (ERROR): ' , 50 counter_er_3.
  WRITE: / 'Fehler 04 (NO_HISTORY): ' , 50 counter_er_4.
  WRITE: / 'Fehler 05 (NO_DEVICE): ', 50 counter_er_5.
  WRITE: / 'Fehler 06 (OTHERS): ' , 50 counter_er_6.

* Anzahl der berücksichtigten Anlagen melden
  DATA: BEGIN OF wa_anlage,
          anlage TYPE anlage,
        END OF wa_anlage,
        it_anlage LIKE TABLE OF wa_anlage.

  SELECT DISTINCT anlage FROM /adesso/mte_htge INTO TABLE it_anlage.
  DESCRIBE TABLE it_anlage LINES count_anlagen.
  WRITE: / 'Anzahl der berücksichtigten Anlagen: ', 50 count_anlagen.

  ULINE.
  SKIP.
* Ausgabe Updates ins Job-Log
  MESSAGE  s001(/adesso/mt_n)
        WITH  'Anzahl Update Datensätze in HT-Ger:'
                                      anz_ht_upd .
* Fehlerauswertung
  READ TABLE imig_err INDEX 1.
  IF sy-subrc EQ 0.
    MODIFY  /adesso/mte_err  FROM  TABLE  imig_err.
  ENDIF.
  SKIP.
  WRITE: / 'Anzahl Update Datensätze in HT-Ger:', 50 anz_ht_upd.
  SKIP.
  WRITE: / 'Fehler bzw.Infos bei Update /ADESSO/MTE_HTGE:'.
  LOOP AT imig_err.
    WRITE: / imig_err-obj_key,
             imig_err-meldung(55).
  ENDLOOP.
  IF sy-subrc NE 0.
    WRITE: / 'keine Fehler aufgetreten'.
    SKIP 2.
  ELSE.
    SKIP 2.
  ENDIF.

  CLEAR imeldung.
  REFRESH: imeldung, imig_err.


ENDFORM.                    "fill_ht_ger_inf

*&---------------------------------------------------------------------*
*&      Form  SPLIT_IHTGER_INF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM split_ihtger_inf .

  CLEAR: iht_gern, iht_gern[], iht_gerw, iht_gerw[].

  LOOP AT iht_ger.

*  existiert die Gerätenummer in der Wechseltabelle ????
    LOOP AT iht_gerh WHERE equnr  = iht_ger-equnr
                     OR equnr_alt = iht_ger-equnr.
      EXIT.
    ENDLOOP.
*   wenn ja, dann in Wechseltabelle
    IF sy-subrc EQ 0.
      MOVE-CORRESPONDING iht_ger TO iht_gerw.
      APPEND iht_gerw.

*   wenn nicht, dann in die Normaltabelle
    ELSE.
      MOVE-CORRESPONDING iht_ger TO iht_gern.
      APPEND iht_gern.
    ENDIF.

  ENDLOOP.

ENDFORM.                    "split_ihtger_inf
