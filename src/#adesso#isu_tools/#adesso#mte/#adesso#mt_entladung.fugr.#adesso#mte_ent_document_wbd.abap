FUNCTION /adesso/mte_ent_document_wbd.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(X_VKONT) LIKE  FKKVK-VKONT
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
*{   INSERT         GIMK900004                                        1
* Änderungen


  DATA  object          TYPE  emg_object.
  DATA  ent_file        TYPE  emg_pfad.
  DATA: ums_fuba        TYPE  funcname.
  DATA: v_dat           LIKE  sy-datum.
  DATA: ifkkop          LIKE sfkkop OCCURS 0 WITH HEADER LINE.
  DATA: ifkkop_open     LIKE sfkkop OCCURS 0 WITH HEADER LINE.
  DATA: ilock    LIKE dfkklocks OCCURS 0 WITH HEADER LINE.
  DATA: partner LIKE but000-partner.
  DATA: beleg LIKE dfkkop-opbel.
  DATA: oldkey_s TYPE emg_oldkey. "Oldkey Mig.Datei
  DATA: h_betrag LIKE dfkkop-betrw.
  DATA: o_key           TYPE  emg_oldkey.


  DATA: h_vorg(8)       TYPE c.
  DATA: BEGIN OF h_konten OCCURS 0,
         hkont TYPE saknr,
         betrag TYPE betrw_kk,
        END OF h_konten.
  DATA: wa_fkkmaze TYPE fkkmaze.

  DATA: BEGIN OF iopbel OCCURS 0,
         opbel LIKE sfkkop-opbel,
         vkont LIKE sfkkop-vkont,
        END OF iopbel.

  DATA: BEGIN OF libel OCCURS 0,
          opbel LIKE dfkkop-opbel,
          found(1) TYPE c,
  END OF libel.

  DATA: lvkfound TYPE i.

  DATA: BEGIN OF liumbel OCCURS 0,
          opbel LIKE dfkkop-opbel,
          vkont LIKE dfkkop-vkont,
        END OF liumbel.

  DATA: BEGIN OF iendabrpe OCCURS 0,
          vertrag LIKE ever-vertrag,
          endabrpe LIKE erch-endabrpe,
        END OF iendabrpe.

  DATA: h_vertrag LIKE ever-vertrag.
  DATA: h_pos LIKE dfkkop-opupk.

  IF ivtfilled IS INITIAL.
    ivtfilled = 'X'.
    SELECT obj_key FROM /adesso/mte_rel  INTO TABLE ivt
    WHERE firma = firma
       AND ( object =  'MOVE_IN' OR
             object =  'MOVE_IN_H' OR
             object =  'MOVE_IN_L' ).
  ENDIF.

  object   = 'DOCUMENT'.
  ent_file = pfad_dat_ent.
  oldkey_doc = x_vkont.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = oldkey_doc
    IMPORTING
      output = oldkey_doc.

* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.

  PERFORM init_doc.
  CLEAR: idoc_out, wdoc_out, meldung, anz_obj.
  REFRESH: idoc_out, meldung.

  CLEAR v_dat.
  CLEAR: iendabrpe, iendabrpe[].

* zugehörigen Partner ermitteln
  SELECT SINGLE gpart FROM fkkvkp INTO partner
                  WHERE vkont = oldkey_doc.
  IF sy-subrc NE 0.
    meldung-meldung =
     'kein zugehöriger Geschäftspartner ermittelbar (aus FKKVKP)'.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.

* Alle Posten (nicht nur offene) pro VKonto ermitteln
  CALL FUNCTION 'FKK_COMPLETE_ACCOUNT_READ'
    EXPORTING
      i_gpart               = partner
      i_vkont               = oldkey_doc
    TABLES
      t_fkkop               = ifkkop
    EXCEPTIONS
      no_items_found        = 1
      partner_not_specified = 2
      OTHERS                = 3.
  IF sy-subrc <> 0.
    CASE sy-subrc.
      WHEN '1'.
        meldung-meldung =
         'keine Datensätze gefunden (DFKKOP)'.
        APPEND meldung.
        RAISE wrong_data.
      WHEN '2'.
        meldung-meldung =
         'Geschäftspartner ist nicht vorhanden (FUBA)'.
        APPEND meldung.
        RAISE wrong_data.
      WHEN '3'.
        meldung-meldung =
         'Fehler im FUBA: FKK_COMPLETE_ACCOUNT_READ'.
        APPEND meldung.
        RAISE wrong_data.
    ENDCASE.
  ENDIF.

  DELETE ifkkop WHERE ( betrh = 0 )
                 OR ( augrd EQ '05' )
                 OR ( stakz EQ 'P' )                  "Abschl.Plan
                 OR ( stakz EQ 'G' AND augst = '9' )  "Sonstige ausgeglichene
                 OR ( hvorg EQ '0050' )               "Abschlag stat.Verfahren
                 OR ( hvorg = '0020' )                "Barsicherheiten
                 OR ( hvorg = '0040' )                "Zinsen
                 OR ( hvorg = '0045' )                "JVL
                 OR  ( hvorg = '0060' )               "Akonto                    "Nuss 30.10.2015
                 OR ( hvorg = '0075' )                "Sammelrechnung
                 OR ( hvorg = '0080' ).               "Raten
*                OR ( hvorg = '0100' AND augrd = '07' ).  "Erstellen der Endabrechnung


* Alles Ausgeglichene löschen
  DELETE ifkkop WHERE augst = '9'.



  LOOP AT ifkkop.
    CHECK NOT ifkkop-vtref IS INITIAL.
    SHIFT ifkkop-vtref LEFT DELETING LEADING '0'.

**  Vertrag auf das lesbare Format konvertieren
**  Sonst kann nicht in der Relevanztabelle gelsesen werden
    CLEAR h_vertrag.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = ifkkop-vtref
      IMPORTING
        output = h_vertrag.
    MOVE h_vertrag TO ifkkop-vtref.

*   Für nicht relevante Verträge keine Vertragsreferenz
    READ TABLE ivt WITH KEY vertrag = ifkkop-vtref.
    IF sy-subrc NE 0.
      CLEAR ifkkop-vtref.
    ENDIF.
    MODIFY ifkkop.

*   Die erste MIG wird ohne ausgeglichene Posten durchgeführt;
*   Untere Passagen können später aktiviert werden, wenn es erforderlich sein sollte;

*   READ TABLE ivt WITH KEY vertrag = ifkkop-vtref.
*   ermitteln des Datums, ab dem auch die ausgeglichenen Positionen
*   mit migriert werden: Begin der aktuellen Abr.Pperiode
*    IF sy-subrc = 0.
*      IF ifkkop-vtref <> iendabrpe-vertrag.
*        iendabrpe-vertrag = ifkkop-vtref.
*        CALL FUNCTION 'ISU_BEGIN_OF_BILLING_PERIOD'
*          EXPORTING
*            x_vertrag                 = iendabrpe-vertrag
*         IMPORTING
*           y_begabrpe                 = iendabrpe-endabrpe
*         EXCEPTIONS
*           general_fault              = 1
*           parameter_fault            = 2
*         OTHERS                       = 3.
*
*        IF sy-subrc = 0.
*          APPEND iendabrpe.
*        ENDIF.
*      ENDIF.
*    ENDIF.
  ENDLOOP.

* Tabelle mit (teilweise) offenen Posten aufbaue
*  ifkkop_open[] = ifkkop[].

* Alles Ausgeglichene löschen
*  DELETE ifkkop WHERE augst = '9'.

* Wenn ganzes VKonto abgerechnet wurde, dann keine ausgeglichene Posten
*  IF iendabrpe[] IS INITIAL.
*    DELETE ifkkop WHERE augst = '9'.
*  ENDIF.

* Möglichkeit, die ausgeglichene Posten ab einem Stichtag zu übernehmen
*  SELECT SINGLE vdat FROM /adesso/mte_docd
*                INTO v_dat WHERE firma = firma.
*  IF sy-subrc <> 0.
*    v_dat = sy-datum.
*    v_dat+4(4) = '0101'.
*  ENDIF.
*  DELETE ifkkop WHERE ( augst = '9'
*                        AND  bldat LT v_dat ).

* --> Nuss 19.11.2015
* Für WBD-Projekt sind nur die Umbuchen aus Faktura relevant

  DELETE ifkkop WHERE hvorg NE '0250'.
  DELETE ifkkop WHERE spart NE '05'.

  IF ifkkop[] IS INITIAL.
    CONCATENATE 'Für Vertragskonto' oldkey_doc
                'wurden keine Posten HVORG 0250 ermittelt'
                INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.
* <-- Nuss 19.11.2015

  SORT ifkkop BY vtref.


* Offene Belege ermitteln
  LOOP AT ifkkop.
    MOVE ifkkop-opbel TO iopbel-opbel.
    MOVE ifkkop-vkont TO iopbel-vkont.
    COLLECT iopbel.
  ENDLOOP.
  SORT iopbel BY opbel.


  LOOP AT iopbel.
*>   Initialisierung
    PERFORM init_doc.
    CLEAR: idoc_out, wdoc_out.
    REFRESH: idoc_out.

*   Belegkopf aufbauen
    SELECT SINGLE * FROM dfkkko WHERE opbel = iopbel-opbel.
    IF sy-subrc EQ 0.
      MOVE-CORRESPONDING dfkkko TO idoc_ko.
      APPEND idoc_ko.
      CLEAR idoc_ko.

    ELSE.
      CONCATENATE  'Beleg' ifkkop-opbel 'nicht in DFKKKO'
        INTO meldung-meldung SEPARATED BY space.
      APPEND meldung.
      CONTINUE.
    ENDIF.

*   sämtliche Posten zu dem Beleg aufbauen
    SORT ifkkop BY opbel opupk.
    CLEAR: h_betrag, h_pos.
    CLEAR h_konten.
    REFRESH h_konten.
    LOOP AT ifkkop WHERE opbel = iopbel-opbel.

      MOVE-CORRESPONDING ifkkop TO idoc_op.

**    VTREF wieder konvertieren in das Originalformat
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = idoc_op-vtref
        IMPORTING
          output = idoc_op-vtref.


*  --> Nuss 30.10.2015
*  WBD-Projekt keine MAhnungen
***  Füllen Relevanztabelle für Dunning
*      CLEAR wa_fkkmaze.
*      SELECT SINGLE * FROM fkkmaze INTO wa_fkkmaze
*         WHERE opbel = idoc_op-opbel
*          AND  opupw = idoc_op-opupw
*          AND  opupk = idoc_op-opupk
*          AND  opupz = idoc_op-opupz
*          AND  xmsto NE 'X'
*          AND  mdrkd NE '00000000'.
*      IF sy-subrc = 0.
*        CONCATENATE idoc_op-opbel
*                    idoc_op-opupw
*                    idoc_op-opupk
*                    idoc_op-opupz
*       INTO /adesso/mte_rel-obj_key.
*        MOVE 'DUNNING' TO /adesso/mte_rel-object.
*        MOVE firma TO /adesso/mte_rel-firma.
*        MODIFY /adesso/mte_rel.
**       COMMIT WORK.
*      ENDIF.
*   <-- NUss 30.10.2015



      APPEND idoc_op.
      CLEAR idoc_op.

*  Speziell für DU-IT werden in Abhängigkeit vom Haupt- und Teilvorgang die Hauptbuchkonten
*  für die DFKKOPK gebildet.
*      ADD ifkkop-betrw TO h_betrag.
      CLEAR h_vorg.
      h_vorg(4) = ifkkop-hvorg.
      h_vorg+4(4) = ifkkop-tvorg.

      CASE h_vorg.

        WHEN '00100010'.
          h_konten-hkont = '120163'.
          h_konten-betrag = ifkkop-betrw.

        WHEN '00100020'.
          h_konten-hkont = '120163'.
          h_konten-betrag = ifkkop-betrw.

        WHEN '00600010'.
          h_konten-hkont = '120163'.
          h_konten-betrag = ifkkop-betrw.

        WHEN '00700010'.
          h_konten-hkont = '120163'.
          h_konten-betrag = ifkkop-betrw.

        WHEN '00900020'.
          h_konten-hkont = '120103'.
          h_konten-betrag = ifkkop-betrw.

        WHEN '01000010'.
          h_konten-hkont = '120103'.
          h_konten-betrag = ifkkop-betrw.

        WHEN '01000020'.
          h_konten-hkont = '120103'.
          h_konten-betrag = ifkkop-betrw.

        WHEN '02000020'.
          h_konten-hkont = '120103'.
          h_konten-betrag = ifkkop-betrw.

        WHEN '02500010'.
          h_konten-hkont = '120103'.
          h_konten-betrag = ifkkop-betrw.

        WHEN '06000010'.
          h_konten-hkont = '120103'.
          h_konten-betrag = ifkkop-betrw.

        WHEN '09000010'.
          h_konten-hkont = '120103'.
          h_konten-betrag = ifkkop-betrw.

        WHEN '60000090'.
          h_konten-hkont = '120163'.
          h_konten-betrag = ifkkop-betrw.

        WHEN '60000092'.
          h_konten-hkont = '120163'.
          h_konten-betrag = ifkkop-betrw.

        WHEN '91000140'.
          h_konten-hkont = '120103'.
          h_konten-betrag = ifkkop-betrw.

      ENDCASE.

      COLLECT h_konten.
      CLEAR h_konten.

    ENDLOOP.


*   Hauptbuchposten aufbauen;
*    SELECT * FROM dfkkopk WHERE opbel = iopbel-opbel
*      MOVE-CORRESPONDING dfkkopk TO idoc_opk.
*      APPEND idoc_opk.
*      CLEAR idoc_opk.
*    ENDSELECT.

*   Betrag aus den OP's mit -1 multipliztieren
*   Alle Anderen Felder werden beim Import als Festwerte übergeben
    LOOP AT h_konten.

      MOVE h_konten-betrag TO idoc_opk-betrw.
      MULTIPLY idoc_opk-betrw BY -1.
      MOVE h_konten-hkont TO idoc_opk-hkont.
      MOVE '0' TO idoc_opk-sbasw.                   "Nuss 16.11.2015
*      move 'B7' to idoc_opk-mwskz.                "Nuss 16.11.2015
      APPEND idoc_opk.
      CLEAR idoc_opk.
    ENDLOOP.

*   neuer oldkey für Datei  (Vkontonummer geht nicht)
    oldkey_s  = iopbel-opbel.


    ADD 1 TO anz_obj.

*   Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
    IF NOT ums_fuba IS INITIAL.

      CALL FUNCTION ums_fuba
        EXPORTING
          firma       = firma
        TABLES
          meldung     = meldung
          idoc_ko     = idoc_ko
          idoc_op     = idoc_op
          idoc_opk    = idoc_opk
          idoc_opl    = idoc_opl
          idoc_addinf = idoc_addinf
        CHANGING
          oldkey_doc  = oldkey_s
        EXCEPTIONS
          wrong_data  = 1.
      CASE sy-subrc.
        WHEN 1.
          RAISE wrong_data.
      ENDCASE.

    ENDIF.

* Sätze für Datei in interne Tabelle schreiben
    PERFORM fill_doc_out USING oldkey_s
                               firma
                               object.

    LOOP AT idoc_out INTO wdoc_out.
*      TRANSFER wdoc_out TO ent_file.
      CATCH SYSTEM-EXCEPTIONS convt_codepage = 4.
        TRANSFER wdoc_out TO ent_file.
      ENDCATCH.
      IF sy-subrc = 4.
        meldung-meldung = 'Fehler beim Konvertieren UNICODE - NON UNICODE'.
        APPEND meldung.
        RAISE error.
      ENDIF.
    ENDLOOP.

  ENDLOOP.

*}   INSERT
ENDFUNCTION.
