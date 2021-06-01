*&---------------------------------------------------------------------*
*&  Include           /ADESSO/MTE_RELEVANZ_VERT_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  get_data_relevanz
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data_relevanz.
* Zuerst die Relevanz vom Vertrag her aufbauen
  wrel-firma = firma.
  wrel-object = 'MOVE_IN'.

* Zunächst den Stichtag für die Migration lesen
* Im Projekt energieGUT ist dieser Stichtag irrelevant
*  CLEAR datab.
*  SELECT SINGLE * FROM /evuit/mte_datab.
*  IF sy-subrc = 0.
*    datab = /evuit/mte_datab-datab.
*  ELSE.
*    WRITE: /5 'Bitte pflegen Sie einen Stichtag in der Tabelle /EVUIT/MTE_DATAB'.
*    STOP.
*  ENDIF.

*----------------------------------------------------------------------------
* Relevante Vertäge ermitteln
*---------------------------------------------------------------------------
**  Die Verträge sind wie folgt aufgeteilt:
*  1) Verträge mit Auszugsdatum vor dem 01.09.2012  --> irrelvant    muss angepasst werden.
*  2) Verträge mit Auszugsdatum unendlich ohne offenen (nicht fakturiertem) Vorgängervertrag --> MOVE_IN
*  3) Verträge mit Auszugsdatum unendlich und offenem Vorgängervertrag --> MOVE_IN_L
*  4) Verträge mit Auszugsdatum, die fakturiert sind --> MOVE_IN_H
*  5) Verträge mit Auszugsdatum, die noch nicht fakturiert sind --> MOVE_IN und MOVE_OUT.


  CLEAR: it_ever.
  SELECT * FROM ever INTO TABLE it_ever
      WHERE  auszdat GE '20120901' AND
*     Nuss 08.01.2013
*     Vorgabe von DU-IT
*     Vertragskonto des GP TRIANEL ausschließen
       vkonto NE '002001000000'   AND
       loevm NE 'X'.

  LOOP AT it_ever INTO wa_ever.

    IF wa_ever-auszdat = '99991231'.
*     aktive Verträge
      iever_akt-vertrag = wa_ever-vertrag.
      APPEND iever_akt.
    ELSE.
*     beendete Verträge
      iever_end-vertrag = wa_ever-vertrag.
      APPEND iever_end.
    ENDIF.

*   Anlagen zu den Verträgen
    ieanl-anlage = wa_ever-anlage.
    APPEND ieanl.

*   Vertragskonten zu den Verträgen
    ivk-vkont = wa_ever-vkonto.
    APPEND ivk.

*   Auszüge in der Zukunft
*   aktuell außer Acht gelassen
*   IF wa_ever-auszdat ne '99991231'.
*     iever_ausz-vertrag = wa_ever-vertrag.
*     APPEND iever_ausz.
*   ENDIF.

  ENDLOOP.

  IF iever_akt[] IS INITIAL.
    WRITE : / 'Keine relevanten Daten ermittelt'.
    STOP.
  ENDIF.

* aktive Verträge wegschreiben
  SORT iever_akt.
  DELETE ADJACENT DUPLICATES FROM iever_akt COMPARING ALL FIELDS.
  LOOP AT iever_akt.
*  --> Nuss 12.04.2013
    CLEAR wa_ever.
    SELECT SINGLE * FROM ever INTO wa_ever
      WHERE vertrag = iever_akt-vertrag.
** gibt es einen Vorgängervertrag ?
    CLEAR wa_ever_h.
    SELECT SINGLE * FROM ever INTO wa_ever_h
      WHERE anlage = wa_ever-anlage
      AND ( auszdat GE '20120901' AND
            auszdat LT wa_ever-auszdat )
      AND  fakturiert = ' '.
    IF sy-subrc = 0.
      mac_add_relevanz 'MOVE_IN_L' iever_akt-vertrag.
    ELSE.
      mac_add_relevanz 'MOVE_IN' iever_akt-vertrag.
    ENDIF.
*    mac_add_relevanz 'MOVE_IN' iever_akt-vertrag.
*   <-- Nuss 12.04.2013
  ENDLOOP.

* beendete Verträge wegschreiben
  SORT iever_end.
  DELETE ADJACENT DUPLICATES FROM iever_end COMPARING ALL FIELDS.
  LOOP AT iever_end.
*  --> Nuss 12.04.2013
*  Prüfen, ob der Vertrag fakturiert ist oder nicht
    CLEAR wa_ever.
    SELECT SINGLE * FROM ever INTO wa_ever
      WHERE vertrag = iever_end-vertrag.
    IF wa_ever-fakturiert = 'X'.
      mac_add_relevanz 'MOVE_IN_H' iever_end-vertrag.
    ELSE.
      mac_add_relevanz 'MOVE_IN'  iever_end-vertrag.
      mac_add_relevanz 'MOVE_OUT' iever_end-vertrag.
    ENDIF.
*    mac_add_relevanz 'MOVE_IN_H' iever_end-vertrag.
**  <-- Nuss 12.04.2013
  ENDLOOP.

* --> Nuss 22.01.2013
* Abschlagspläne
* Aktive Verträge
  IF NOT iever_akt[] IS INITIAL.
    SELECT * FROM eabp INTO TABLE ieabp
      FOR ALL ENTRIES IN iever_akt
      WHERE vertrag = iever_akt-vertrag
       AND deaktiv = space.
  ENDIF.

* nicht fakturierte, historische Verträge
  IF NOT iever_end[] IS INITIAL.
    SELECT * FROM eabp APPENDING TABLE ieabp
      FOR ALL ENTRIES IN iever_end
      WHERE vertrag = iever_end-vertrag
      AND deaktiv = space.
  ENDIF.

  SORT ieabp BY begperiode.
  LOOP AT ieabp.
    mac_add_relevanz 'BBP_MULT' ieabp-opbel.
  ENDLOOP.
* <-- Nuss 22.01.2013


* Auszüge - aktuell außer Acht gelassen
*  SORT iever_ausz.
*  DELETE ADJACENT DUPLICATES FROM iever_ausz COMPARING ALL FIELDS.
*  IF iever_ausz[] IS NOT INITIAL.
*    SELECT * FROM eausv INTO TABLE it_eausv
*       FOR ALL ENTRIES IN iever_ausz[]
*          WHERE vertrag = iever_ausz-vertrag
*          AND storausz NE 'X'.
*    LOOP AT it_eausv INTO wa_eausv.
*      mac_add_relevanz 'MOVE_OUT' wa_eausv-auszbeleg.
*    ENDLOOP.
*  ENDIF.

  MESSAGE s001 WITH 'Vertragsermittlung abgeschlossen'.
  MESSAGE s001 WITH 'Auszugsbelegermittlung abgeschlossen'.
  MESSAGE s001 WITH 'Abschlagsplanermittlung abgeschlossen'.  "Nuss 22.01.2013

  COMMIT WORK.


*--------------------------------------------------------------------------------
* Vertragskonten
*--------------------------------------------------------------------------------
** Vertragskonten aus den Verträgen
  SORT ivk.
  DELETE ADJACENT DUPLICATES FROM ivk COMPARING ALL FIELDS.

*-------------------------------------------------------------------------
* Ermittlung der inaktiven VKs mit Saldo
*-----------------------------------------------------------------------
* Offene Posten ermitteln
  SELECT gpart vkont FROM dfkkop INTO TABLE idfkkop
         WHERE augst <> '9'.

  SORT idfkkop BY gpart vkont.

  DELETE ADJACENT DUPLICATES FROM idfkkop COMPARING gpart vkont.

  LOOP AT idfkkop.

*   Vertragskonto mit offenem Saldo
    IF idfkkop-vkont IS NOT INITIAL.
      ivk-vkont = idfkkop-vkont.
*     Keine Serviceanbieter und keine Muster-Vedrtragskonten
      CLEAR wa_fkkvk.
      SELECT SINGLE * FROM fkkvk INTO wa_fkkvk
        WHERE vkont = idfkkop-vkont.
      IF ( wa_fkkvk-vktyp = 'NB' OR  wa_fkkvk-vktyp = '00'
           OR wa_fkkvk-vktyp = 'NA' ).                         "Nuss 05.12.2012
        CONTINUE.
      ELSE.
        APPEND ivk.
      ENDIF.
    ENDIF.


*   Geschäftspartner mit offenen Saldo
    IF idfkkop-gpart IS NOT INITIAL.
      ibp-partner = idfkkop-gpart.
      APPEND ibp.
    ENDIF.


  ENDLOOP.

  MESSAGE s001 WITH
  'Ermittlung der VKonten mit Saldo abgeschlossen'.
  COMMIT WORK.

  CLEAR: idfkkop, idfkkop[].
  FREE idfkkop.

* Weitere Vertragskonten
* Vertragskontotyp 'NB' und '00'.
* Nach neuen Vorgeben werden die NB-Vertragskonten
* nicht migriert
** --> Nuss 29.10.2012
*  SELECT * FROM fkkvk INTO TABLE it_fkkvk
**     WHERE vktyp = 'NB' OR
*       WHERE vktyp = '00'.
*
*  LOOP AT it_fkkvk INTO wa_fkkvk.
*    ivk-vkont = wa_fkkvk-vkont.
*    APPEND ivk.
*  ENDLOOP.
* <-- Nuss 29.10.2012

* Tabelle bereinigen
  SORT ivk.
  DELETE ADJACENT DUPLICATES FROM ivk COMPARING ALL FIELDS.

*-------------------------------------------------------------------------
* Ermittlung der Geschäftspartner
*---------------------------------------------------------------
* für alle relevanten Vertragskonten
  LOOP AT ivk.

    SELECT SINGLE * FROM fkkvkp INTO wa_fkkvkp
                         WHERE vkont = ivk-vkont.

    ibp-partner = wa_fkkvkp-gpart.        "Geschäftspartner aus Vertragskonto
    APPEND ibp.

*   Abweichende GP's in den VKonten berücksichtigen
    IF NOT wa_fkkvkp-abwre IS INITIAL.
      ibp-partner = wa_fkkvkp-abwre.  "Abweichender Zahler
      APPEND ibp.
    ENDIF.
    IF NOT wa_fkkvkp-abwra IS INITIAL.
      ibp-partner = wa_fkkvkp-abwra. "Abweichender Zahlungsempfänger
      APPEND ibp.
    ENDIF.
    IF NOT wa_fkkvkp-abwma IS INITIAL.
      ibp-partner = wa_fkkvkp-abwma. "Abweichender Mahnungsempfänger
      APPEND ibp.
    ENDIF.
    IF NOT wa_fkkvkp-abwrh IS INITIAL.
      ibp-partner = wa_fkkvkp-abwrh. "Abweichender Rechnungsempfänger
      APPEND ibp.
    ENDIF.
    IF NOT wa_fkkvkp-def_rec IS INITIAL.
      ibp-partner = wa_fkkvkp-def_rec.  "Abweichender Korrespondenzempfänger
      APPEND ibp.
    ENDIF.

    ivk-gpart = wa_fkkvkp-gpart.
    MODIFY ivk.


    mac_add_relevanz 'ACCOUNT' ivk-vkont.

    CONCATENATE ivk-vkont ivk-gpart INTO tdname.

    PERFORM get_text USING 'FKKVKP' tdname CHANGING txfound.
    IF NOT txfound IS INITIAL.
      mac_add_relevanz 'ACC_NOTE' ivk-vkont.
    ENDIF.

  ENDLOOP.

  MESSAGE s001 WITH 'Vertragskontoermittlung abgeschlossen'.

  COMMIT WORK.

  SORT ibp.
  DELETE ADJACENT DUPLICATES FROM ibp COMPARING ALL FIELDS.

*------------------------------------------------------------------------------------
* Geschäftspartner
*-----------------------------------------------------------------------------------
  LOOP AT ibp.
    mac_add_relevanz 'PARTNER' ibp-partner.
    PERFORM get_text USING 'BUT000' ibp-partner CHANGING txfound.
    IF NOT txfound IS INITIAL.
      mac_add_relevanz 'PARTN_NOTE' ibp-partner.
    ENDIF.
  ENDLOOP.

  MESSAGE s001 WITH 'Geschäftspartnerermittlung abgeschlossen'.
  COMMIT WORK.

*------------------------------------------------------------------------------------
* Kontakte
*-----------------------------------------------------------------------------------
  IF ibp[] IS NOT INITIAL.
    SELECT * FROM bcont INTO TABLE it_bcont
                        FOR ALL ENTRIES IN ibp
                        WHERE partner = ibp-partner
                        AND   loevm <> 'X'.
    LOOP AT it_bcont INTO wa_bcont.
      ibcont-bpcontact = wa_bcont-bpcontact.
      APPEND ibcont.
    ENDLOOP.
  ENDIF.

  SORT ibcont.
  DELETE ADJACENT DUPLICATES FROM ibcont COMPARING ALL FIELDS.

  LOOP AT ibcont.
    mac_add_relevanz 'BCONTACT' ibcont-bpcontact.
    PERFORM get_text USING 'BCONT' ibcont-bpcontact CHANGING txfound.
    IF NOT txfound IS INITIAL.
      mac_add_relevanz 'BCONT_NOTE' ibcont-bpcontact.
    ENDIF.
  ENDLOOP.

  MESSAGE s001 WITH 'Kontaktermittlung abgeschlossen'.
  COMMIT WORK.


*---------------------------------------------------------------------------
* Aktive Anlagen, die über die Verträge ermittelt wurden.
*---------------------------------------------------------------------------
  SORT ieanl.
  DELETE ADJACENT DUPLICATES FROM ieanl COMPARING ALL FIELDS.

  IF NOT ieanl[] IS INITIAL.
    SELECT * FROM eanl INTO TABLE it_eanl
         FOR ALL ENTRIES IN ieanl
        WHERE anlage = ieanl-anlage.
**    --> Nuss 15.05.2013
**    Keine Abfrage auf Löschvormerkung bei den Anlagen
**    Anlagen wurden übder die Verträge ermittelt.
*         AND loevm NE 'X'.
**   <-- Nuss 15.05.2013

  ENDIF.

  LOOP AT it_eanl INTO wa_eanl.
    mac_add_relevanz 'INSTLN' wa_eanl-anlage.
    mac_add_relevanz 'INST_MGMT' wa_eanl-anlage.
    mac_add_relevanz 'METERREAD' wa_eanl-anlage.
    mac_add_relevanz 'DEVINFOREC' wa_eanl-anlage.
  ENDLOOP.

  MESSAGE s001 WITH 'Anlagenermittlung abgeschlossen'.
  MESSAGE s001 WITH 'Ermittlung von INST_MGMT abgeschlossen'.
  MESSAGE s001 WITH 'Ableseergebisermittlung abgeschlossen'.
  MESSAGE s001 WITH 'Geräteinfosatzermittlung abgeschlosen'.

  COMMIT WORK.

*---------------------------------------------------------------------
* Verbrauchsstellen
*---------------------------------------------------------------------
  IF NOT it_eanl[] IS INITIAL.
    SELECT * FROM evbs INTO TABLE it_evbs
       FOR ALL ENTRIES IN it_eanl
        WHERE vstelle = it_eanl-vstelle.
**       Nuss 04.12.2012
**       Bei DU-IT keine Abfrage nach Löschkennzeichen bei Verbrauchstellen
*         AND loevm NE 'X'.
  ENDIF.

  LOOP AT it_evbs INTO wa_evbs.
    mac_add_relevanz 'PREMISE' wa_evbs-vstelle.
  ENDLOOP.

*-------------------------------------------------------------------
* Anschlussobjekte
*--------------------------------------------------------------------
  IF NOT it_evbs[] IS INITIAL.
    SELECT * FROM iflot INTO TABLE it_iflot
        FOR ALL ENTRIES IN it_evbs
          WHERE tplnr = it_evbs-haus
          AND fltyp = 'M'.
  ENDIF.

  LOOP AT it_iflot INTO wa_iflot.
    mac_add_relevanz 'CONNOBJ' wa_iflot-tplnr.
  ENDLOOP.

*---------------------------------------------------------------------
* Notizen zu den Anschlussobjekten
*---------------------------------------------------------------------
  IF NOT it_iflot[] IS INITIAL.
    SELECT * FROM enote INTO TABLE it_enote
        FOR ALL ENTRIES IN it_iflot
        WHERE objkey = it_iflot-tplnr
          AND objtype = '2'.

  ENDIF.

  LOOP AT it_enote INTO wa_enote.
    mac_add_relevanz 'NOTE_CON' wa_enote-objkey.
  ENDLOOP.


  MESSAGE s001 WITH 'Verbrauchsstellenermittlung abgeschlossen'.
  MESSAGE s001 WITH 'Anschlussobjektermittlung abgeschlossen'.

  COMMIT WORK.



ENDFORM.                    " get_data_relevanz

*&---------------------------------------------------------------------*
*&      Form  update_reltab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_reltab.

  SORT irel.
  DELETE ADJACENT DUPLICATES FROM irel COMPARING ALL FIELDS.
  CLEAR z_commit.


  INSERT /adesso/mte_rel FROM TABLE irel.

  MESSAGE s001 WITH 'Relevanztabelle gefüllt'.

*  SORT irel.
*  DELETE ADJACENT DUPLICATES FROM irel COMPARING ALL FIELDS.
*  CLEAR z_commit.
*
*  LOOP AT irel INTO wrel.
*    SELECT SINGLE * FROM /adesso/mte_rel
*                    WHERE firma = wrel-firma
*                      AND object = wrel-object
*                      AND obj_key = wrel-obj_key.
*    IF sy-subrc = 0.
*      ADD 1 TO z_update.
*      CONCATENATE /adesso/mte_rel-quelle lfdnr
*        INTO /adesso/mte_rel-quelle.
*      UPDATE /adesso/mte_rel.
*      IF sy-subrc > 0.
*        WRITE: / 'Programmabbruch beim UPDATE von /adesso/mte_rel'.
*        EXIT.
*      ENDIF.
*
*      z_commit = z_commit + 1.
*      IF z_commit GE 1000.
*        COMMIT WORK.
*        CLEAR z_commit.
*      ENDIF.
*
*    ELSE.
*      ADD 1 TO z_insert.
*      /adesso/mte_rel = wrel.
*      /adesso/mte_rel-quelle = lfdnr.
*      INSERT /adesso/mte_rel.
*      IF sy-subrc > 0.
*        WRITE: / 'Programmabbruch beim INSERT in /adesso/mte_rel'.
*        EXIT.
*      ENDIF.
*
*      z_commit = z_commit + 1.
*      IF z_commit GE 1000.
*        COMMIT WORK.
*        CLEAR z_commit.
*      ENDIF.
*
*    ENDIF.
*  ENDLOOP.
*  MESSAGE s001 WITH 'Relevanztabelle gefüllt'.

ENDFORM.                    " update_reltab

*&---------------------------------------------------------------------*
*&      Form  get_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OBJ   text
*      -->P_NAME  text
*      <--P_TXFOUND  text
*----------------------------------------------------------------------*
FORM get_text USING    VALUE(p_obj)
                       p_name
              CHANGING p_txfound.

  CLEAR p_txfound.

  SELECT SINGLE * FROM stxh WHERE tdobject = p_obj AND tdname = p_name.
  IF sy-subrc = 0.
    p_txfound = 'X'.
  ENDIF.

ENDFORM.                    " get_text

*&---------------------------------------------------------------------*
*&      Form  protokoll
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM protokoll.

  WRITE : / 'Objekt', 44 'Anzahl'.
  LOOP AT irel INTO wrel.
    AT NEW object.
      WRITE : / wrel-object.
    ENDAT.
    ADD 1 TO objcount.
    AT END OF object.
      WRITE : 40 objcount.
      MESSAGE s001 WITH 'Objekt' wrel-object 'Anzahl' objcount.
      CLEAR objcount.
    ENDAT.
  ENDLOOP.

ENDFORM.                    " protokoll
