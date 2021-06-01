*&---------------------------------------------------------------------*
*&  Include           /ADESSO/MTE_RELEVANZ_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  get_data_relc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*

FORM get_data_relc.

* Auslesen der gecustomizten Kriterien für die Relevanzermittlung
* Ableseeinheit
  SELECT * FROM /adesso/mte_rlae WHERE firma = firma
                                 AND   ( lfdnr = lfdnr
                                         OR lfdnr = '00' ).
    MOVE-CORRESPONDING /adesso/mte_rlae TO relae.
    relae-option = /adesso/mte_rlae-soption.
    APPEND relae.
  ENDSELECT.

* Abrechnungsklasse
  SELECT * FROM /adesso/mte_rlak WHERE firma = firma
                                 AND   ( lfdnr = lfdnr
                                         OR lfdnr = '00' ).
    MOVE-CORRESPONDING /adesso/mte_rlak TO relak.
    relak-option = /adesso/mte_rlak-soption.
    APPEND relak.
  ENDSELECT.

* Buchungskreis
  SELECT * FROM /adesso/mte_rlbk WHERE firma = firma
                                 AND   ( lfdnr = lfdnr
                                         OR lfdnr = '00' ).
    MOVE-CORRESPONDING /adesso/mte_rlbk TO relbk.
    relbk-option = /adesso/mte_rlbk-soption.
    APPEND relbk.
  ENDSELECT.

* Geschäftspartner
  SELECT * FROM /adesso/mte_rlgp WHERE firma = firma
                                 AND   ( lfdnr = lfdnr
                                         OR lfdnr = '00' ).
    MOVE-CORRESPONDING /adesso/mte_rlgp TO relgp.
    relgp-option = /adesso/mte_rlgp-soption.
    APPEND relgp.
  ENDSELECT.

* Portion
  SELECT * FROM /adesso/mte_rlpt WHERE firma = firma
                                 AND   ( lfdnr = lfdnr
                                         OR lfdnr = '00' ).
    MOVE-CORRESPONDING /adesso/mte_rlpt TO relpt.
    relpt-option = /adesso/mte_rlpt-soption.
    APPEND relpt.
  ENDSELECT.

  IF NOT relpt[] IS INITIAL." AND NOT relae[] IS INITIAL.
    SELECT * FROM te422 WHERE portion IN relpt.
      relae-sign = 'I'.
      relae-option = 'EQ'.
      relae-low = te422-termschl.
      APPEND relae.
    ENDSELECT.
  ENDIF.

* Tariftyp
  SELECT * FROM /adesso/mte_rltt WHERE firma = firma
                                 AND   ( lfdnr = lfdnr
                                         OR lfdnr = '00' ).
    MOVE-CORRESPONDING /adesso/mte_rltt TO reltt.
    reltt-option = /adesso/mte_rltt-soption.
    APPEND reltt.
  ENDSELECT.

* Vertragskonto
  SELECT * FROM /adesso/mte_rlvk WHERE firma = firma
                                 AND   ( lfdnr = lfdnr
                                         OR lfdnr = '00' ).
    MOVE-CORRESPONDING /adesso/mte_rlvk TO relvk.
    relvk-option = /adesso/mte_rlvk-soption.
    APPEND relvk.
  ENDSELECT.

* Vertragskontotyp
  SELECT * FROM /adesso/mte_rlvt WHERE firma = firma
                                 AND   ( lfdnr = lfdnr
                                         OR lfdnr = '00' ).
    MOVE-CORRESPONDING /adesso/mte_rlvt TO relvt.
    relvt-option = /adesso/mte_rlvt-soption.
    APPEND relvt.
  ENDSELECT.

** Sparte
  SELECT * FROM /adesso/mte_rlsp WHERE firma = firma
                                 AND   ( lfdnr = lfdnr
                                         OR lfdnr = '00' ).
    MOVE-CORRESPONDING /adesso/mte_rlsp TO relsp.
    relsp-option = /adesso/mte_rlsp-soption.
    APPEND relsp.
  ENDSELECT.

** --> Nuss 10.09.2015
** Anlage
  SELECT * FROM /adesso/mte_rlan WHERE firma = firma
                                 AND   ( lfdnr = lfdnr
                                         OR lfdnr = '00' ).
    MOVE-CORRESPONDING /adesso/mte_rlan TO relan.
    relan-option = /adesso/mte_rlan-soption.
    APPEND relan.
  ENDSELECT.
** <-- Nuss 10.09.2015

ENDFORM.                    " get_data_relc
*&---------------------------------------------------------------------*
*&      Form  get_data_relevanz
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data_relevanz.
* Zuerst die Relevanz von der Anlage her aufbauen
  wrel-firma = firma.
  wrel-object = 'INSTLN'.

* Stichtag ermitteln, um relevante Verträge zu holen
* Es kann Auszüge in der Zukunft (nach dem Stichtag geben
* Diese sind für die Migration relevant
  CLEAR datab.
  SELECT SINGLE * FROM /adesso/mte_dtab.
  IF sy-subrc = 0.
    datab = /adesso/mte_dtab-datab.
  ELSE.
*    datab = '99991231'.
    datab = sy-datum.
  ENDIF.


*-------------------------------------------------------------------------
* Aktive Anlagen als Basis für die weitere Selektion lesen
* ---------------------------------------------------------------------------
  SELECT *
         INTO CORRESPONDING FIELDS OF eanlh
              FROM fkkvk AS f
                   JOIN fkkvkp AS g
                        ON f~vkont = g~vkont
                   JOIN ever AS v
                        ON v~vkonto = f~vkont
                   JOIN eanlh AS a
                        ON a~anlage = v~anlage
                   JOIN eanl AS e
                        ON e~anlage = a~anlage
                   WHERE f~vkont IN relvk
                        AND   f~vktyp IN relvt
                        AND   g~gpart IN relgp
                        AND   g~opbuk IN relbk
                        AND   a~anlage IN relan           "Nuss 10.09.2015
                        AND   a~tariftyp IN reltt
                        AND   a~aklasse IN relak
                        AND   a~ableinh IN relae
                        AND   a~bis     GE datab
                        AND   a~ab      LE datab
                        AND   e~sparte  IN relsp
                        AND   e~loevm <> 'X'.

    SELECT SINGLE * FROM ever
              WHERE anlage = eanlh-anlage
                AND auszdat GE datab
                AND einzdat LE datab.

*   wenn kein aktueller Vertrag, dann Anlage mitnehmen
*   wenn die kaufmännischen Daten des letzten Vertrages die Bedingungen
*   erfüllen
    IF sy-subrc <> 0.
      IF pnodel IS INITIAL.
        SELECT * FROM ever UP TO 1 ROWS
                      WHERE anlage = eanlh-anlage
                      ORDER BY auszdat DESCENDING.
          SELECT SINGLE * FROM fkkvk
                              WHERE vkont = ever-vkonto
                              AND   vkont IN relvk
                              AND   vktyp IN relvt.
          IF sy-subrc = 0.
            SELECT SINGLE * FROM fkkvkp
                                 WHERE vkont = fkkvk-vkont
                                 AND   opbuk IN relbk
                                 AND   gpart IN relgp.
            IF sy-subrc = 0.
              ieanl-anlage = eanlh-anlage.
              APPEND ieanl.
            ENDIF.
          ENDIF.
        ENDSELECT.
      ENDIF.
    ELSE.
*     ansonsten prüfen ob die kaufmännischen Daten die Selektionskriterien
*     erfüllen.
      SELECT SINGLE * FROM fkkvk
                           WHERE vkont = ever-vkonto
                           AND   vkont IN relvk
                           AND   vktyp IN relvt.
      IF sy-subrc = 0.
        SELECT SINGLE * FROM fkkvkp
                             WHERE vkont = fkkvk-vkont
                             AND   opbuk IN relbk
                             AND   gpart IN relgp.
        IF sy-subrc = 0.
          ieanl-anlage = eanlh-anlage.
          APPEND ieanl.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDSELECT.

*-------------------------------------------------------------------------
* Ruhende Anlagen dazulesen, auf die Selektionskriterien zutreffen.
*---------------------------------------------------------------------------------
* (auch Anlagen, die noch nie einen Vertrag hatten)
  IF pnodel IS INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF eanl
                  FROM eanl AS a
                  JOIN eanlh AS h
                  ON   a~anlage = h~anlage
                  WHERE a~sparte IN relsp
                  AND   a~loevm <> 'X'
                  AND   h~tariftyp IN reltt
                  AND   h~aklasse IN  relak
                  AND   h~ableinh IN relae
                  AND   h~bis GE datab
                  AND   h~ab  LE datab.

      SELECT SINGLE * FROM ever WHERE anlage = eanl-anlage.
      IF sy-subrc <> 0.
        ieanl-anlage = eanl-anlage.
        APPEND ieanl.
      ENDIF.
    ENDSELECT.
  ENDIF.

  SORT ieanl.
  DELETE ADJACENT DUPLICATES FROM ieanl COMPARING ALL FIELDS.

  MESSAGE s001 WITH 'Anlagenermittlung abgeschlossen'.
  COMMIT WORK.

  IF ieanl[] IS INITIAL.
    WRITE : / 'Keine relevanten Daten ermittelt'.
    STOP.
  ENDIF.

  LOOP AT ieanl.
    mac_add_relevanz 'INSTLN' ieanl-anlage.
    mac_add_relevanz 'INST_MGMT' ieanl-anlage.
    mac_add_relevanz 'METERREAD' ieanl-anlage.
    SELECT SINGLE * FROM eanl WHERE anlage = ieanl-anlage.
    SELECT * FROM evbs
                  WHERE vstelle = eanl-vstelle.
      mac_add_relevanz 'PREMISE' evbs-vstelle.
*     Mitnahme der Eigentümer als GPartner
      IF NOT evbs-eigent IS INITIAL.
        ibp-partner = evbs-eigent.
        APPEND ibp.
      ENDIF.

      SELECT * FROM iflot
                    WHERE tplnr = evbs-haus
                    AND   fltyp = 'M'.
        mac_add_relevanz 'CONNOBJ' iflot-tplnr.


*  -->   Nuss 26.08.2015
*        SELECT SINGLE * FROM enote WHERE objtype = 2
*                                  AND objkey  = iflot-tplnr.
*        IF sy-subrc = 0.
*          mac_add_relevanz 'NOTE_CON' iflot-tplnr.
*        ENDIF.

        PERFORM get_text USING 'IFLOT' iflot-tplnr CHANGING txfound.
        IF NOT txfound IS INITIAL.
          mac_add_relevanz 'NOTE_CON' iflot-tplnr.
        ENDIF.
* <-- Nuss 26.08.2015

      ENDSELECT.
    ENDSELECT.


  ENDLOOP.

  SORT ibp.
  DELETE ADJACENT DUPLICATES FROM ibp COMPARING ALL FIELDS.
  DESCRIBE TABLE ibp.
  MESSAGE s001 WITH 'Eigentümerermittlung abgeschlossen' '-Anzahl:' sy-tfill.

  MESSAGE s001 WITH 'Ableseergebnisermittlung abgeschlossen'.
  MESSAGE s001 WITH 'Verbrauchsstellenermittlung abgeschlossen'.
  MESSAGE s001 WITH 'Anschlussobjektermittlung abgeschlossen'.


  COMMIT WORK.

*-------------------------------------------------------------------------
* Ermittlung der aktiven Verträge und dazugehörenden aktiven VKonten
*-------------------------------------------------------------------------
  SELECT * FROM ever FOR ALL ENTRIES IN ieanl
                     WHERE anlage = ieanl-anlage
*                    AND auszdat = '99991231'
                     AND auszdat GE datab
                     AND einzdat LE datab
                     AND   loevm   <> 'X'.
    iever-vertrag = ever-vertrag.
    APPEND iever.

    ivk-vkont = ever-vkonto.
    APPEND ivk.
  ENDSELECT.

  SORT iever.
  DELETE ADJACENT DUPLICATES FROM iever COMPARING ALL FIELDS.

  LOOP AT iever.
    mac_add_relevanz 'MOVE_IN' iever-vertrag.
    SELECT * FROM eabp
             WHERE vertrag = iever-vertrag
             AND   deaktiv = space
             ORDER BY begperiode.
      mac_add_relevanz 'BBP_MULT' eabp-opbel.
    ENDSELECT.
  ENDLOOP.

  MESSAGE s001 WITH 'Vertragsermittlung abgeschlossen'.
  MESSAGE s001 WITH 'Abschlagsplanermittlung abgeschlossen'.
  COMMIT WORK.

  SORT ivk.
  DELETE ADJACENT DUPLICATES FROM ivk COMPARING ALL FIELDS.

*-------------------------------------------------------------------------
* Ermittlung der inaktiven VKs mit Saldo
*-----------------------------------------------------------------------
* Offene Posten ermitteln
if psaldo is not initial.                                 "Nuss 11.09.2015
  SELECT gpart vkont FROM dfkkop INTO TABLE idfkkop
           WHERE augst <> '9'
           %_HINTS ORACLE 'INDEX("DFKKOP" "DFKKOP~1")'.   "Nuss 25.08.2015

  SORT idfkkop BY gpart vkont.

  DELETE ADJACENT DUPLICATES FROM idfkkop COMPARING gpart vkont.

  COMMIT WORK.                                      "Nuss 25.08.2015

* Schleife über alle VKonten (Sel.Kriterien unterwegs gecheckt)
  SELECT * FROM fkkvkp WHERE  vkont IN relvk
                        AND   gpart IN relgp
                        AND   opbuk IN relbk.
    .
    SELECT SINGLE * FROM fkkvk WHERE vkont = fkkvkp-vkont
                               AND vktyp IN relvt.
    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

*   Sammler-Oberkonten dürfen nur über die Unterkonten ermittelt werden
    SELECT SINGLE * FROM tfk002a
                    WHERE applk = 'R'
                    AND   vktyp = fkkvk-vktyp.
    IF sy-subrc = 0 AND
       tfk002a-samrg = 'X'.
      CONTINUE.
    ENDIF.

*   VKonto bereits als aktiv selektiert
    READ TABLE ivk WITH KEY vkont = fkkvkp-vkont BINARY SEARCH.
    IF sy-subrc = 0.
      CONTINUE.
    ENDIF.

*   gesperrte VKonten nicht migrieren
*   Grund dafür konnte nicht erkannt werden: auskommentiert
*    CONCATENATE fkkvkp-vkont fkkvkp-gpart INTO object.
*    SELECT SINGLE * FROM dfkklocks
*           WHERE loobj1 = object
*           AND   lockr = 'Y'.
*    IF sy-subrc = 0.
*      CONTINUE.
*    ENDIF.

*   Kernfrage: gibt es zu dem VK offene Posten
    READ TABLE idfkkop WITH KEY
         gpart  = fkkvkp-gpart
          vkont = fkkvkp-vkont
          BINARY SEARCH.
    IF sy-subrc = 0.
      ivk-vkont = fkkvkp-vkont.
      APPEND ivk.
    ENDIF.
  ENDSELECT.

  MESSAGE s001 WITH
  'Ermittlung der inaktiven VKonten mit Saldo abgeschlossen'.
  COMMIT WORK.

  CLEAR: idfkkop, idfkkop[].
  FREE idfkkop.
 endif.                                        "Nuss 11.09.2015


** Möglichkeit, alle Vertragskonten als relevant zu übernehmen
  IF NOT pallvk IS INITIAL.
    SELECT vkont APPENDING CORRESPONDING FIELDS OF TABLE ivk
                 FROM fkkvk.
  ENDIF.

  SORT ivk.
  DELETE ADJACENT DUPLICATES FROM ivk COMPARING ALL FIELDS.

*-------------------------------------------------------------------------
* Ermittlung der Geschäftspartner (aus allen möglichen Gründen)
*---------------------------------------------------------------
* für alle relevanten Vertragskonten
  LOOP AT ivk.
*   zu den relevanten VKonten
    SELECT SINGLE * FROM fkkvkp
                         WHERE vkont = ivk-vkont.
    ibp-partner = fkkvkp-gpart.
    APPEND ibp.

*   Sammelvertragskonten erkennen
    IF NOT fkkvkp-abwvk IS INITIAL.
      ivksam-vkont = fkkvkp-abwvk.
      APPEND ivksam.
    ENDIF.

*   Abweichende GP's in den VKonten berücksichtigen
    IF NOT fkkvkp-abwre IS INITIAL.
      ibp-partner = fkkvkp-abwre.
      APPEND ibp.
    ENDIF.
    IF NOT fkkvkp-abwra IS INITIAL.
      ibp-partner = fkkvkp-abwra.
      APPEND ibp.
    ENDIF.
    IF NOT fkkvkp-abwma IS INITIAL.
      ibp-partner = fkkvkp-abwma.
      APPEND ibp.
    ENDIF.
    IF NOT fkkvkp-abwrh IS INITIAL.
      ibp-partner = fkkvkp-abwrh.
      APPEND ibp.
    ENDIF.
    IF NOT fkkvkp-def_rec IS INITIAL.
      ibp-partner = fkkvkp-def_rec.
      APPEND ibp.
    ENDIF.

    ivk-gpart = fkkvkp-gpart.
    MODIFY ivk.

*   Relevanz der normalln VKonten und abhängigen Objekten speichern
*   Prüfen ob das Vertragskonto ein Abweichendes Vertragskonto ist
    DATA: wa_fkkvkp_help TYPE fkkvkp.
    CLEAR wa_fkkvkp_help.
    SELECT * FROM fkkvkp INTO wa_fkkvkp_help
      WHERE abwvk = ivk-vkont.
      EXIT.
    ENDSELECT.

*  Nur wenn das VK NICHT ein Abw.VK ist, wegschreiben
    IF sy-subrc NE 0.
      mac_add_relevanz 'ACCOUNT' ivk-vkont.
    ENDIF.
    CONCATENATE ivk-vkont ivk-gpart INTO tdname.
    PERFORM get_text USING 'FKKVKP' tdname CHANGING txfound.
    IF NOT txfound IS INITIAL.
      mac_add_relevanz 'ACC_NOTE' ivk-vkont.
    ENDIF.
    SELECT SINGLE * FROM fkk_instpln_head
                    WHERE vkont = ivk-vkont
                    AND   gpart = ivk-gpart
                    AND   deman <> 'X'.
    IF sy-subrc = 0.
      mac_add_relevanz 'INSTPLAN' ivk-vkont.
    ENDIF.
  ENDLOOP.

* Relevanz der Sammel-Konten speichern
  SORT ivksam.
  DELETE ADJACENT DUPLICATES FROM ivksam.
  LOOP AT ivksam.
    SELECT SINGLE * FROM fkkvkp WHERE vkont = ivksam-vkont.
    mac_add_relevanz 'ACCOUNTS' ivksam-vkont.
    ibp-partner = fkkvkp-gpart.
    APPEND ibp.
  ENDLOOP.

  MESSAGE s001 WITH 'Vertragskontoermittlung abgeschlossen'.
  MESSAGE s001 WITH 'Ratenplanermittlung abgeschlossen'.
  COMMIT WORK.

* Zusätzliche Möglichkeit: alle vorhandenen GP's als relevant zu kennzeichnen
  IF NOT pallgp IS INITIAL.
    SELECT partner APPENDING CORRESPONDING FIELDS OF TABLE ibp
                   FROM but000.

  ENDIF.

  SORT ibp.
  DELETE ADJACENT DUPLICATES FROM ibp COMPARING ALL FIELDS.

  LOOP AT ibp.
    mac_add_relevanz 'PARTNER' ibp-partner.
    PERFORM get_text USING 'BUT000' ibp-partner CHANGING txfound.
    IF NOT txfound IS INITIAL.
      mac_add_relevanz 'PARTN_NOTE' ibp-partner.
    ENDIF.
  ENDLOOP.

  MESSAGE s001 WITH 'Geschäftspartnerermittlung abgeschlossen'.
  COMMIT WORK.

  SELECT * FROM bcont FOR ALL ENTRIES IN ibp
                      WHERE partner = ibp-partner
*  Keine kontakte mit Löschkennzeichen
                      AND   loevm <> 'X'.

    ibcont-bpcontact = bcont-bpcontact.
    APPEND ibcont.
  ENDSELECT.

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

  SELECT * FROM ettifb
                FOR ALL ENTRIES IN ieanl
                WHERE anlage = ieanl-anlage.
    mac_add_relevanz 'REFVALUES' ettifb-anlage.
  ENDSELECT.

  MESSAGE s001 WITH 'Bezugsgrößenermittlung abgeschlossen'.
  COMMIT WORK.

  CLEAR datab.


* Ermittlung der Gerätedaten ------------------------->>>
  SELECT * FROM eastl
  FOR ALL ENTRIES IN ieanl
    WHERE anlage = ieanl-anlage.
    CLEAR datab.

*   Datab wird aus Tabelle /ADESSO/MTE_DATAB gezogen
*   Der Stichtag aus der Tabelle übersteuert die normale
*   Ermittlung der Abrechnungsperiode
    SELECT SINGLE * FROM /adesso/mte_dtab.
    IF sy-subrc = 0.
      datab = /adesso/mte_dtab-datab.
    ELSE.
      CALL FUNCTION 'ISU_BILLING_DATES_FOR_INSTLN'
        EXPORTING
          x_anlage          = eastl-anlage
        IMPORTING
          y_default_date    = datab
        EXCEPTIONS
          no_contract_found = 1
          general_fault     = 2
          parameter_fault   = 3
          OTHERS            = 4.
      IF sy-subrc <> 0.
        IF sy-subrc EQ 1 AND
           datab IS INITIAL.
          SELECT SINGLE * FROM eanlh WHERE anlage = eastl-anlage
                                       AND bis    = '99991231'.
          IF sy-subrc EQ 0.
            MOVE eanlh-ab TO datab.
          ENDIF.
        ENDIF.
      ENDIF.
*  --> Nuss 17.03.2016
      IF ls_erch IS NOT INITIAL.
        IF ls_erch-abrvorg = '02'.
          CLEAR lt_erch.
          SELECT * FROM erch INTO TABLE lt_erch
            WHERE vertrag = ls_erch-vertrag
             AND abrvorg = '01'
             AND erchc_v = 'X'
             AND simulation = ' '
             AND stornodat = '00000000'.
          IF lt_erch IS NOT INITIAL.
            SORT lt_erch BY endabrpe DESCENDING.
            READ TABLE lt_erch INTO wa_erch INDEX 1.
            datab = ( wa_erch-endabrpe + 1 ).
**        Es lag noch keine Turnusabrechnung vor
          ELSE.
            SELECT SINGLE einzdat FROM ever INTO datab
              WHERE anlage = eastl-anlage
               AND einzdat LE sy-datum
               AND auszdat GE sy-datum.
          ENDIF.
        ENDIF.
      ENDIF.
**  <-- Nuss 17.03.2016
    ENDIF.

*   Ermittlung der Netzgeräte
    IF eastl-bis GE datab. " OR sy-subrc <> 0.
      SELECT * FROM v_eger WHERE logiknr = eastl-logiknr.
        IF v_eger-bis >= datab.
          mac_add_relevanz 'DEVICE' v_eger-equnr.
          mac_add_relevanz 'DEVLOC' v_eger-devloc.
          SELECT SINGLE * FROM iflot
                 WHERE tplnr = v_eger-devloc.
          mac_add_relevanz 'CONNOBJ' iflot-tplma.
*         PERFORM get_text USING 'IFLOT' v_eger-devloc CHANGING txfound.
*          IF NOT txfound IS INITIAL.
          SELECT SINGLE * FROM enote WHERE objtype = 3
                                     AND   objkey = v_eger-devloc.
          IF sy-subrc = 0.
            mac_add_relevanz 'NOTE_DLC' v_eger-devloc.
          ENDIF.
        ENDIF.
      ENDSELECT.

***   Geräteinfosätze
      SELECT * FROM egerr WHERE logiknr = eastl-logiknr.
        IF egerr-bis GE datab.
          mac_add_relevanz 'DEVINFOREC' egerr-equnr.
        ENDIF.
      ENDSELECT.

    ENDIF.
  ENDSELECT.

* Geräte, die nur technisch eingebaut wurden
  SELECT * FROM egerh WHERE bis = '99991231'
                        AND logiknr EQ  '0'
                        AND devloc NE space.

* --> Equipment auf Sparte prüfen
    SELECT SINGLE * FROM equi WHERE equnr = egerh-equnr.
    CHECK equi-sparte IN relsp.

*   jetzt prüfen, ob es einen Satz in Tabelle EASTL gibt
    SELECT SINGLE * FROM eastl WHERE logiknr = egerh-logiknr.
    IF sy-subrc NE 0.
*     technischer Einbau
      mac_add_relevanz 'DEVICE' egerh-equnr.
*      mac_add_relevanz 'LOT' egerh-equnr.
      mac_add_relevanz 'DEVLOC' egerh-devloc.
      SELECT SINGLE * FROM enote WHERE objtype = 3
                                 AND   objkey = egerh-devloc.
      IF sy-subrc = 0.
        mac_add_relevanz 'NOTE_DLC' egerh-devloc.
      ENDIF.
      SELECT SINGLE * FROM iflot
             WHERE tplnr = egerh-devloc.
      mac_add_relevanz 'CONNOBJ' iflot-tplma.
    ENDIF.
  ENDSELECT.

* ---- Lagergeräte ----------------------------------->>>
  SELECT * FROM egerh WHERE bis = '99991231'
                      AND logiknr = '0'
                      AND devloc = space
                      AND ausbdat = '00000000'.

**  Equipment auf Sparte prüfen
    SELECT SINGLE * FROM equi WHERE equnr = egerh-equnr.
    CHECK equi-sparte IN relsp.
**
    mac_add_relevanz 'DEVICE' egerh-equnr.

  ENDSELECT.

  MESSAGE s001 WITH 'Gerätermittlung abgeschlossen'.
  MESSAGE s001 WITH 'Geräteplatzermittlung abgeschlossen'.
  MESSAGE s001 WITH 'Geräteinfosatzermittlung abgeschlossen'.
  COMMIT WORK.

* Losermittlung (LOT)
  SELECT * FROM te271.
    mac_add_relevanz 'LOT' te271-los.
  ENDSELECT.

  MESSAGE s001 WITH 'Losermittlung abgeschlossen'.
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


  LOOP AT irel INTO wrel.
    SELECT SINGLE * FROM /adesso/mte_rel
                    WHERE firma = wrel-firma
                      AND object = wrel-object
                      AND obj_key = wrel-obj_key.
    IF sy-subrc = 0.
      ADD 1 TO z_update.
      CONCATENATE /adesso/mte_rel-quelle lfdnr
        INTO /adesso/mte_rel-quelle.
      UPDATE /adesso/mte_rel.
      IF sy-subrc > 0.
        WRITE: / 'Programmabbruch beim UPDATE von /adesso/mte_rel'.
        EXIT.
      ENDIF.

      z_commit = z_commit + 1.
      IF z_commit GE 1000.
        COMMIT WORK.
        CLEAR z_commit.
      ENDIF.
    ELSE.
      ADD 1 TO z_insert.
      /adesso/mte_rel = wrel.
      /adesso/mte_rel-quelle = lfdnr.
      INSERT /adesso/mte_rel.
      IF sy-subrc > 0.
        WRITE: / 'Programmabbruch beim INSERT in /adesso/mte_rel'.
        EXIT.
      ENDIF.
      z_commit = z_commit + 1.
      IF z_commit GE 1000.
        COMMIT WORK.
        CLEAR z_commit.
      ENDIF.
    ENDIF.
  ENDLOOP.
  MESSAGE s001 WITH 'Relevanztabelle gefüllt'.

ENDFORM.                    " update_reltab
*&---------------------------------------------------------------------*
*&      Form  get_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0474   text
*      -->P_IBP_PARTNER  text
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

  IF NOT ever_count[] IS INITIAL.
    SKIP 2.
    WRITE: / 'Aufteilung der Verträge in Ziel-BUKRS und Ziel-Sparte'.
    SKIP.
    SORT ever_count BY bukrs sparte.
    WRITE: / 'BUKRS', 20 'SP', 30 'Anzahl'.
    ULINE.
    LOOP AT ever_count.
      WRITE: /  ever_count-bukrs,
             20 ever_count-sparte,
             30 ever_count-anzahl.
    ENDLOOP.
  ENDIF.


ENDFORM.                    " protokoll
