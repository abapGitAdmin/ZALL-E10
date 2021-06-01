*&---------------------------------------------------------------------*
*&  Include           /ADESSO/MT_BEL_LOADWB_F01
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
    PERFORM be_und_entlade_files USING dat_acc.
*   Fuba-aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_ACCOUNT'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_acc
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Vertragskonten:', anz_acc.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung ACCOUNT:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Vertragskonten:', anz_acc.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.
  ENDIF.
*-----------------------------------------------------------------------

*ACCOUNTS  Vertragskonto für Sammler anlegen
  IF obj_acs EQ 'X'.
    PERFORM be_und_entlade_files USING dat_acs.
*   Fuba-aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_ACCOUNT'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_acs
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Vertragskonten-Sammler:', anz_acs.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung ACCOUNTS:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Vertragskonten-Sammler:', anz_acs.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.
  ENDIF.
*-----------------------------------------------------------------------
*ACC_NOTE  Notizen zum Vertragskonto anlegen
  IF obj_acn EQ 'X'.
    PERFORM be_und_entlade_files USING dat_acn.
* Fuba-Aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_ACC_NOTE'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_acn
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Notizen Vertragskonto:', anz_acn.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung ACC_NOTE:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Notizen Vertragskonto:', anz_acn.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.
  ENDIF.
*-----------------------------------------------------------------------

*BBP_MULT  Abschlagsplan für mehrere Verträge
  IF obj_bpm EQ 'X'.
    PERFORM be_und_entlade_files USING dat_bpm.
* Fuba-Aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_BBP_MULT'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_bpm
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Abschlagspläne:', anz_bpm.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung BBP_MULT:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Abschlagspläne:', anz_bpm.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.
  ENDIF.
*-----------------------------------------------------------------------

*BCONTACT  Kundenkontakt anlegen
  IF obj_bct EQ 'X'.
    PERFORM be_und_entlade_files USING dat_bct.
* Fuba-Aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_BCONTACT'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_bct
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Kundenkontakte:', anz_bct.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung BCONTACT:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Kundenkontakte:', anz_bct.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.
  ENDIF.
*-----------------------------------------------------------------------

*BCONT_NOTE  Notizen zum Kundenkontakt
  IF obj_bcn EQ 'X'.
    PERFORM be_und_entlade_files USING dat_bcn.
* Fuba-Aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_BCONT_NOTE'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_bcn
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Notizen zu Kundenkontakte:', anz_bcn.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung BCONT_NOTE:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Notizen zu Kundenkontakte:', anz_bcn.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.
  ENDIF.
*-----------------------------------------------------------------------

*BDC_MRUNIT  Ableseeinheiten
  IF obj_mru EQ 'X'.
*    PERFORM be_und_entlade_files USING dat_mru.
* Fuba-Aufruf

    MESSAGE  i001(/adesso/mt_n)  WITH  'Objekt noch nicht implementiert'.
    EXIT.
  ENDIF.
*-----------------------------------------------------------------------

*BDC_TE420  Tabelle E420: Portionen
  IF obj_420 EQ 'X'.
*    PERFORM be_und_entlade_files USING dat_420.
* Fuba-Aufruf

    MESSAGE  i001(/adesso/mt_n)  WITH  'Objekt noch nicht implementiert'.
    EXIT.
  ENDIF.
*-----------------------------------------------------------------------

*CONNOBJ  Anschlußobjekt anlegen
  IF obj_con EQ 'X'.
    PERFORM be_und_entlade_files USING dat_con.
* Fuba-Aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_CONNOBJ'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_con
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Anschlußobjekte:', anz_con.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung CONNOBJ:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Anschlußobjekte:', anz_con.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.

  ENDIF.
*-----------------------------------------------------------------------

*CON_NOTE  Notizen zum Anschlussobjekt
  IF obj_cno EQ 'X'.
    PERFORM be_und_entlade_files USING dat_cno.
* Fuba-Aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_CON_NOTE'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_cno
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Notizen zum Anschlußobjekt:', anz_cno.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung CON_NOTE:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Notizen zum Anschlußobjekt:', anz_cno.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.

  ENDIF.
*-----------------------------------------------------------------------

*DEVGRP  Gerätegruppe Anlegen
  IF obj_dgr EQ 'X'.

    PERFORM be_und_entlade_files USING dat_dgr.
*   Fuba-aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_DEVGRP'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_dgr
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Gerätegruppierungen:', anz_dgr.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung DEVGRP:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Gerätegruppierungen:', anz_dgr.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.


  ENDIF.
*-----------------------------------------------------------------------


*DEVICE  Gerät / Equipment anlegen
  IF obj_dev EQ 'X'.
    PERFORM be_und_entlade_files USING dat_dev.

* Schnittstelle erweitert um Object
    MOVE dat_dev TO h_obj.

* Fuba-Aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_DEVICE'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
        object       = h_obj
      IMPORTING
        anz_obj      = anz_dev
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Geräte:', anz_dev.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung DEVICE:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Geräte:', anz_dev.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.

  ENDIF.
*-----------------------------------------------------------------------
* DEVINFOREC   Geräteinfosatz
  IF obj_dir EQ 'X'.

    PERFORM be_und_entlade_files USING dat_dir.
* Fuba-Aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_DEVINFOREC'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_dir
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Geräteinfosätze:', anz_dir.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung DEVINFOREC:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Geräteinfosätze:', anz_dir.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.

  ENDIF.
*-----------------------------------------------------------------------
*DEVICERATE  Tarifdaten zur Anlagenstruktur ändern
  IF obj_drt EQ 'X'.
    PERFORM be_und_entlade_files USING dat_drt.
* Fuba-Aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_DEVICERATE'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_drt
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Geräte:', anz_drt.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung DEVICERATE:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Tarifdatenänderungen:', anz_drt.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.

  ENDIF.
*-----------------------------------------------------------------------

*DEVLOC  Geräteplatz anlegen
  IF obj_dlc EQ 'X'.
    PERFORM be_und_entlade_files USING dat_dlc.
* Fuba-Aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_DEVLOC'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_dlc
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Geräteplätze:', anz_dlc.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung DEVLOC:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Geräteplätze:', anz_dlc.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.
  ENDIF.

*-----------------------------------------------------------------------
*DLC_NOTE  Notizen zum Geräteplatz
  IF obj_dno EQ 'X'.
    PERFORM be_und_entlade_files USING dat_dno.
* Fuba-Aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_DLC_NOTE'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_dno
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Notizen zum Geräteplatz:', anz_dno.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung DLC_NOTE:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Notizen zum Geräteplatz:', anz_dno.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.

  ENDIF.
*-----------------------------------------------------------------------

*DISC_DOC  Sperrbeleg anlegen
  IF obj_dcd EQ 'X'.
    PERFORM be_und_entlade_files USING dat_dcd.
* Fuba-Aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_DISC_DOC'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_dcd
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Sperrbelege:', anz_dcd.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung DISC_DOC:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Sperrbelege:', anz_dcd.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.

  ENDIF.
*-----------------------------------------------------------------------

*DISC_ORDER  Sperrauftrag anlegen
  IF obj_dco EQ 'X'.
    PERFORM be_und_entlade_files USING dat_dco.
* Fuba-Aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_DISC_ORDER'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_dco
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Sperraufträge angelegt:', anz_dco.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung DISC_ORDER:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Sperraufträge angelegt:', anz_dco.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.

  ENDIF.
*-----------------------------------------------------------------------

*DISC_ENTER  Sperrung erfassen
  IF obj_dce EQ 'X'.
    PERFORM be_und_entlade_files USING dat_dce.
* Fuba-Aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_DISC_ENTER'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_dce
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl erfasste Sperren:', anz_dce.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung DISC_ENTER:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl erfasste Sperren:', anz_dce.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.

  ENDIF.
*-----------------------------------------------------------------------

*DISC_RCORD  Wiederinbetriebnahmeauftrag anlegen
  IF obj_dcr EQ 'X'.
    PERFORM be_und_entlade_files USING dat_dcr.
* Fuba-Aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_DISC_RCORD'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_dcr
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Wiederinbetriebnahmeauftrag anlegen:', anz_dcr.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung DISC_RCORD:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Wiederinbetriebnahmeauftrag anlegen:', anz_dcr.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.

  ENDIF.
*-----------------------------------------------------------------------

*DISC_RCENT  Wiederinbetriebnahme anlegen
  IF obj_dcm EQ 'X'.
    PERFORM be_und_entlade_files USING dat_dcm.
* Fuba-Aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_DISC_RCENT'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_dcm
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Wiederinbetriebnahme anlegen:', anz_dcm.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung DISC_RCENT:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Wiederinbetriebnahme anlegen:', anz_dcm.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.

  ENDIF.
*-----------------------------------------------------------------------



*DOCUMENT  FI-CA Beleg anlegen (nur Offene Posten)
  IF obj_doc EQ 'X'.
    PERFORM be_und_entlade_files USING dat_doc.
* Fuba-Aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_DOCUMENT'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_doc
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl offener Posten:', anz_doc.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung DOCUMENT:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl offener Posten:', anz_doc.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.

  ENDIF.
*-----------------------------------------------------------------------

*FACTS   Individuelle Fakten zur Versorgungsanlage anlegen
  IF obj_fac EQ 'X'.
    PERFORM be_und_entlade_files USING dat_fac.
* Fuba-Aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_FACTS'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_fac
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Anlagefakten:', anz_fac.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung FACTS:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Anlagefakten:', anz_fac.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.
  ENDIF.
*-----------------------------------------------------------------------

*INSTLN  Anlegen: Versorgungsanlage
  IF obj_ins EQ 'X'.
    PERFORM be_und_entlade_files USING dat_ins.
* Fuba-Aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_INSTLN'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_ins
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Anlagen:', anz_ins.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung INSTLN:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Anlagen:', anz_ins.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.
  ENDIF.
*-----------------------------------------------------------------------

*INSTLNCHA  Ändern Versorgungsanlage
  IF obj_ich EQ 'X'.
    PERFORM be_und_entlade_files USING dat_ich.
* Fuba-Aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_INSTLNCHA'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_ich
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Anlagenänderungen:', anz_ich.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung INSTLNCHA:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Anlagenänderungen:', anz_ich.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.
  ENDIF.

*-----------------------------------------------------------------------
*INSTLN_NN  Anlagen (Netznutzung)
  IF obj_inn EQ 'X'.
    PERFORM be_und_entlade_files USING dat_inn.

    CALL FUNCTION '/ADESSO/MTB_BEL_INSTLN_NN'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_inn
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Anlagen (NN)', anz_inn.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung INSTLN_NN:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Anlagen (NN)', anz_inn.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.
  ENDIF.

*-----------------------------------------------------------------------
*INSTLN_NN  Anlagen (Netznutzung)
  IF obj_icn EQ 'X'.

    PERFORM be_und_entlade_files USING dat_icn.

** Fuba-Aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_INSTLNCHNN'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_icn
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Anlagenänderungen:', anz_icn.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung INSTLNCHNN:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Anlagenänderungen:', anz_icn.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.

  ENDIF.
*-----------------------------------------------------------------------
*INSTPLAN  Ratenplan anlegen
  IF obj_ipl EQ 'X'.
    PERFORM be_und_entlade_files USING dat_ipl.
* Fuba-Aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_INSTPLAN'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_ipl
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Ratenpläne:', anz_ipl.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung INSTPLAN:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Ratenpläne:', anz_ipl.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.
  ENDIF.
*-----------------------------------------------------------------------

*INST_MGMT  Geräteeinbau /-ausbau /-wechsel
  IF obj_inm EQ 'X'.

    DATA: name TYPE temfd-file.

    CONCATENATE dat_inm 'W' INTO name.
*    PERFORM be_und_entlade_files USING name.
    PERFORM be_und_entlade_files USING dat_inm.

*  Schnittstelle erweitert um Object
    MOVE dat_inm TO h_obj.
    MOVE 'INST_MGMT' TO h_obj.

*    CALL FUNCTION '/ADESSO/MTB_BEL_INST_MGMT'
*      EXPORTING
*        firma        = firma
*        pfad_dat_ent = ent_file
*        pfad_dat_bel = bel_file
*        object       = h_obj
*      IMPORTING
*        anz_obj      = anz_inm
*      TABLES
*        meldung      = imeldung
*      EXCEPTIONS
*        no_open      = 1
*        no_close     = 2
*        wrong_data   = 3
*        gen_error    = 4
*        error        = 5
*        OTHERS       = 6.

    CALL FUNCTION '/ADESSO/MTB_BEL_INST_MGMT_INF'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
        object       = h_obj
      IMPORTING
        anz_obj      = anz_inm
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
* Implement suitable error handling here
    ENDIF.

    IF sy-subrc <> 0.
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Geräteeinbau:', anz_inm.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung INST_MGMT:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Geräteeinbau:', anz_inm.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.

  ENDIF.
*-----------------------------------------------------------------------

*LOADPROF  Anlegen: Lastprofil zu Anlage
  IF obj_lop EQ 'X'.
    PERFORM be_und_entlade_files USING dat_lop.
* Fuba-Aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_LOADPROF'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_lop
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Lastprofil zu Anlage:', anz_lop.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung LOADPROF:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Lastprofil zu Anlage:', anz_lop.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.

  ENDIF.
*-----------------------------------------------------------------------


*LOT         Stichprobenlos
  IF obj_lot EQ 'X'.
    PERFORM be_und_entlade_files USING dat_lot.
* Fuba-Aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_LOT'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_lot
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Stichprobenlos:', anz_lot.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung LOT:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Stichprobenlos:', anz_lot.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.
  ENDIF.
*-----------------------------------------------------------------------

*METERREAD  Zählerstand anlegen
  IF obj_mrd EQ 'X'.
    PERFORM be_und_entlade_files USING dat_mrd.
* Fuba-Aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_METERREAD'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_mrd
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Zählerstände:', anz_mrd.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung METERREAD:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Zählerstände:', anz_mrd.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.
  ENDIF.
*-----------------------------------------------------------------------

*MOVE_IN  Anlegen: Einzug / Versorgungsvertrag
  IF obj_moi EQ 'X'.
    PERFORM be_und_entlade_files USING dat_moi.
* Fuba-Aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_MOVE_IN'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_moi
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Verträge (Einzüge):', anz_moi.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung MOVE_IN:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Verträge (Einzüge):', anz_moi.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.
  ENDIF.
*-----------------------------------------------------------------------
* MOVE_IN_H  Anlagen: Hist. Verorgungsvertrag
  IF obj_moh EQ 'X'.

    PERFORM be_und_entlade_files USING dat_moh.

* Buba-Aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_MOVE_IN_H'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_moh
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Historische Verträge:', anz_moh.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung MOVE_IN_H:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Historische Verträge:', anz_moh.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.


  ENDIF.
*-----------------------------------------------------------------------
*  MOVE_OUT Anlegen Auszug
  IF obj_moo EQ 'X'.

    PERFORM be_und_entlade_files USING dat_moo.

* Fuba-Aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_MOVE_OUT'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_moo
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Auszüge', anz_moo.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung MOVE_OUT:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Auszüge:', anz_moo.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.

  ENDIF.
*-----------------------------------------------------------------------

*NOTE_CON  Anlegen: Außendiensthinweise zum Anschlußobjekt
  IF obj_noc EQ 'X'.
    PERFORM be_und_entlade_files USING dat_noc.

* Fuba-Aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_NOTE_CON'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_noc
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Außendiensthinweise CONNOBJ:', anz_noc.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung NOTE_CON:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Außendiensthinweise CONNOBJ:', anz_noc.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.
  ENDIF.
*-----------------------------------------------------------------------

*NOTE_DLC  Anlegen: Außendiensthinweise zum Geräteplatz
  IF obj_nod EQ 'X'.
    PERFORM be_und_entlade_files USING dat_nod.

* Fuba-Aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_NOTE_DLC'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_nod
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Außendiensthinweise DEVLOC:', anz_nod.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung NOTE_DLC:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Außendiensthinweise DEVLOC:', anz_nod.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.
  ENDIF.
*-----------------------------------------------------------------------

*PARTNER  Anlegen: Geschäftspartner
  IF obj_par EQ 'X'.
    PERFORM be_und_entlade_files USING dat_par.

    CALL FUNCTION '/ADESSO/MTB_BEL_PARTNER'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_par
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Geschäftspartner:', anz_par.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung PARTNER:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Geschäftspartner:', anz_par.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.

  ENDIF.
*-----------------------------------------------------------------------

*PARTN_NOTE  Notizen zum Geschäftspartner
  IF obj_pno EQ 'X'.
    PERFORM be_und_entlade_files USING dat_pno.

* Fuba-Aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_PARTN_NOTE'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_pno
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Geschäftspartnernotizen:', anz_pno.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung PARTN_NOTE:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Geschäftspartnernotizen:', anz_pno.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.
  ENDIF.
*-----------------------------------------------------------------------

*PAYMENT  Anlegen: Zahlung auf offenen Posten
  IF obj_pay EQ 'X'.
    PERFORM be_und_entlade_files USING dat_pay.
* Fuba-Aufruf
*    CALL FUNCTION '/ADESSO/MTB_BEL_PAYMENT'             "Nuss 13.01.2016
    CALL FUNCTION '/ADESSO/MTB_BEL_PAYMENT_NEU'          "Nuss 13.01.2016
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_pay
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Zahlungen:', anz_pay.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung PAYMENT:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Zahlungen:', anz_pay.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.
  ENDIF.
*-----------------------------------------------------------------------

*POD         Zählpunkt (Point of Delivery)
  IF obj_pod EQ 'X'.
    PERFORM be_und_entlade_files USING dat_pod.
* Fuba-Aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_POD'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_pod
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Zählpunkte:', anz_pod.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung POD:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Zählpunkte:', anz_pod.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.
  ENDIF.
*-----------------------------------------------------------------------

*PODCHANGE  Ändern Zählpunkt
  IF obj_poc EQ 'X'.
    PERFORM be_und_entlade_files USING dat_poc.
* Fuba-Aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_PODCHANGE'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_poc
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Zählpunkte ändern:', anz_poc.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung PODCHANGE:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Zählpunkte ändern:', anz_poc.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.
  ENDIF.
*-----------------------------------------------------------------------

*PODSERVICE  Anlegen Zählpunktservice
  IF obj_pos EQ 'X'.
    PERFORM be_und_entlade_files USING dat_pos.
* Fuba-Aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_PODSERVICE'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_pos
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Zählpunktservice:', anz_pos.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung PODSERVICE:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Zählpunktservice:', anz_pos.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.
  ENDIF.
*-----------------------------------------------------------------------

*PREMISE  Anlegen: Verbrauchsstelle
  IF obj_pre EQ 'X'.
    PERFORM be_und_entlade_files USING dat_pre.
* Fuba-Aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_PREMISE'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_pre
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Verbrauchsstellen:', anz_pre.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung PREMISE:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Verbrauchsstellen:', anz_pre.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.

  ENDIF.
*-----------------------------------------------------------------------

*REFVALUES  Anlegen: Bezugsgrößen
  IF obj_rva EQ 'X'.
    PERFORM be_und_entlade_files USING dat_rva.
* Fuba-Aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_REFVALUES'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_rva
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Bezugsgrößen:', anz_rva.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung REFVALUES:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Bezugsgrößen:', anz_rva.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.
  ENDIF.
*-----------------------------------------------------------------------

*STRT_ROUTE  Anlegen: Ablesereihenfolge
  IF obj_srt EQ 'X'.
    PERFORM be_und_entlade_files USING dat_srt.
* Fuba-Aufruf
    CALL FUNCTION '/ADESSO/MTB_BEL_STRT_ROUTE'
      EXPORTING
        firma        = firma
        pfad_dat_ent = ent_file
        pfad_dat_bel = bel_file
      IMPORTING
        anz_obj      = anz_srt
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
      APPEND LINES OF imeldung TO mig_err.
      WRITE: / 'Anzahl Ablesereihenfolge:', anz_srt.
      SKIP.
      WRITE: / 'Fehler bei Dateierstellung STRT_ROUTE:'.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ELSE.
      WRITE: / 'Anzahl Ablesereihenfolge:', anz_srt.
      LOOP AT imeldung.
        WRITE: / imeldung-meldung.
      ENDLOOP.
    ENDIF.
  ENDIF.
*-----------------------------------------------------------------------







ENDFORM.                    " Migrationsdateien_erstellen
*&---------------------------------------------------------------------*
*&      Form  be_und_entlade_files
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DAT_BCN  text
*----------------------------------------------------------------------*
FORM be_und_entlade_files USING    object_name.

  CONCATENATE exp_path object_name '.' exp_ext
        INTO ent_file.
  CONCATENATE imp_path object_name '.' imp_ext
        INTO bel_file.


ENDFORM.                    " be_und_entlade_files
