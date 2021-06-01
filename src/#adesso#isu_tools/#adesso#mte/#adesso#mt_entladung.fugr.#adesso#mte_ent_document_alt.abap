FUNCTION /ADESSO/MTE_ENT_DOCUMENT_ALT.
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
* Änderungen
 DATA  object          TYPE  emg_object.
  DATA  ent_file        TYPE  emg_pfad.
  DATA: ums_fuba        TYPE  funcname.
  DATA: v_dat           LIKE  sy-datum.
  DATA: ifkkop   LIKE sfkkop OCCURS 0 WITH HEADER LINE.
  DATA: ilock    LIKE dfkklocks OCCURS 0 WITH HEADER LINE.
  DATA: partner LIKE but000-partner.
  DATA: beleg LIKE dfkkop-opbel.
  DATA: oldkey_s TYPE emg_oldkey. "Oldkey Mig.Datei
  DATA: h_betrag LIKE dfkkop-betrw.
  DATA: o_key           TYPE  emg_oldkey.

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



  data: h_pos like dfkkop-opupk.


  IF ivtfilled IS INITIAL.
    ivtfilled = 'X'.
    SELECT obj_key FROM /adesso/mte_rel  INTO TABLE ivt
    WHERE firma = firma
       AND object =  'MOVE_IN'.
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



*>   Initialisierung
  PERFORM init_doc.
  CLEAR: idoc_out, wdoc_out, meldung, anz_obj.
  REFRESH: idoc_out, meldung.
*<



*> Datenermittlung ---------

* ermitteln des Datums, ab dem auch die ausgeglichenen Positionen
* mit migriert werden.
* Es ist (erstmal): Ende der letzten Abrechnungsperiode + 1 Tag.
*
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


  CALL FUNCTION 'FKK_COMPLETE_ACCOUNT_READ'
    EXPORTING
      i_gpart                     = partner
      i_vkont                     = oldkey_doc
*   I_XACCU                     = ' '
*   IX_SAMPLE_FLAG              = ' '
*   I_ONLY_OPEN                 = ' '
    TABLES
      t_fkkop                     = ifkkop
    EXCEPTIONS
      no_items_found              = 1
      partner_not_specified       = 2
      OTHERS                      = 3
            .
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
                 OR ( stakz EQ 'P' )
                 OR ( stakz EQ 'G' AND augst = '9' )
*                 OR ( abwbl NE space and abwbl <> 'R' and augst = '9' )
                 OR ( hvorg EQ '0050' )
                 OR ( hvorg = '0020' )
*                 OR ( hvorg = '0040' )
* Boy JVL Belege nicht generell aussteuern
*                 OR ( hvorg = '0045' )
                 OR ( hvorg = '0075' )
                 OR ( hvorg = '0080' )
                 OR ( augrd EQ '05' )
                 OR ( hvorg = '0100'
                      AND augrd = '07' ).

* Aussteuern der JVL Belege TVORG <> 0011
  LOOP AT ifkkop WHERE hvorg = '0045'.
    IF ifkkop-tvorg <> '0011'.
      DELETE ifkkop.
      CONTINUE.
    ENDIF.
  ENDLOOP.
* Ende  JVL-Korrektur

  SORT ifkkop BY vtref.

  LOOP AT ifkkop.
    CHECK NOT ifkkop-vtref IS INITIAL.
    SHIFT ifkkop-vtref LEFT DELETING LEADING '0'.


**  Vertrag muss noch auf das lesbare Format konvertiert werden.
**  Sonst kann nicht in der Relevanztabelle gelsesen werden
    CLEAR h_vertrag.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = ifkkop-vtref
      IMPORTING
        output = h_vertrag.
    MOVE h_vertrag TO ifkkop-vtref.



    MODIFY ifkkop.
    READ TABLE ivt WITH KEY vertrag = ifkkop-vtref.
*    if sy-subrc <> 0.
*      delete ifkkop.
*      continue.
*    endif.
    IF sy-subrc = 0.
      IF ifkkop-vtref <> iendabrpe-vertrag.
        iendabrpe-vertrag = ifkkop-vtref.
        CALL FUNCTION 'ISU_BEGIN_OF_BILLING_PERIOD'
          EXPORTING
            x_vertrag                  = iendabrpe-vertrag
*   X_ABRVORG                  = '01'
*   X_BEGEND                   =
*   X_ABRDATS                  =
*   X_USE_EVER                 = ' '
*   X_USE_PREVIOUS_ERCH        = ' '
*   X_USE_PREVIOUS_IERCH       = ' '
*   X_PREVIOUS_IERCH           =
         IMPORTING
           y_begabrpe                 = iendabrpe-endabrpe
*   Y_BEGNACH                  =
*   y_begend                   = iendabrpe-endabrpe

*   Y_ABR                      =
*   Y_BBP_IERCH                =
* CHANGING
*   XY_EVER                    =
*   XY_PREVIOUS_ERCH           =
   EXCEPTIONS
     general_fault              = 1
     parameter_fault            = 2
     OTHERS                     = 3
                  .
        IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ELSE.
          APPEND iendabrpe.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF iendabrpe[] IS INITIAL.
    DELETE ifkkop WHERE NOT vtref IS INITIAL AND augst = '9'.
    DELETE ifkkop WHERE augst = '9'.
  ENDIF.

*  v_dat = '20080101'.
  SELECT SINGLE vdat FROM /adesso/mte_dcad
                INTO v_dat WHERE firma = firma.
  IF sy-subrc <> 0.
    v_dat = sy-datum.
    v_dat+4(4) = '0101'.
  ENDIF.
*  LOOP AT iendabrpe.
*    IF iendabrpe-endabrpe LE v_dat OR v_dat IS INITIAL..
*      MOVE iendabrpe-endabrpe TO v_dat.
**  höchstes Ende-Abrechnungszeitraum + 1 Tag
**      v_dat = v_dat + 1.
*    ENDIF.
*  ENDLOOP.
* Das oben ermittelte Datum v_dat wird in dieser Programmversion
* noch nicht berücksichtigt. Z.Z. werden alle ausgeglichenen
* Posten gelöscht (s.u. "xxx)

*> Löschen der nicht benötigten Zeilen

* 1) wo Belegdatum kleiner v_dat und Ausgleichsstatus = '9'
*  LOOP AT ifkkop WHERE augst = '9'
*                   AND bldat LT v_dat.
  DELETE ifkkop WHERE ( augst = '9'
                        AND  bldat LT v_dat ).
*                 OR ( augst = '9'
*                      AND betrh < 0 )
*                 OR ( betrh = 0 )
*                 OR ( stakz EQ 'P' )
*                 OR ( abwbl NE space )
*                 OR ( hvorg EQ '0050' )
*                 OR ( hvorg = '0020' )
**                 OR ( hvorg = '0040' )
*                 OR ( hvorg = '0045' )
*                 OR ( hvorg = '0075' )
**                 OR ( hvorg = '0080' )
*                 OR ( augrd EQ '05' )
*                 OR ( hvorg = '0100'
*                      AND augrd = '07' ).
*  LOOP AT ifkkop.
*    CHECK NOT ifkkop-vtref IS INITIAL.
*    if ifkkop-augst = '9'.
*      READ TABLE iendabrpe WITH KEY vertrag = ifkkop-vtref.
*      IF ifkkop-bldat LT iendabrpe-endabrpe.
*        DELETE ifkkop.
*      ENDIF.
*    endif.
*  ENDLOOP.



** Ab hier alles aussternen, da ausgeglichene Posten nicht migriert werden
*  LOOP AT ifkkop.
*    IF ifkkop-augst = '9'.
*      IF ( ifkkop-augrd <> '01'
*           AND ifkkop-augrd <> '02'
*           AND ifkkop-augrd <> '03'
*           AND ifkkop-augrd <> '07'
*           AND ifkkop-augrd <> '08'
*           AND ifkkop-augrd <> '15'
*           AND ifkkop-augrd <> '25'
*           AND ifkkop-augrd <> '31'
*           AND ifkkop-augrd <> '32' ).
*        DELETE ifkkop.
*      ELSEIF ifkkop-betrw <> 0 AND ifkkop-hvorg <> '0100'
*
*                     AND ( ifkkop-augrd = '01'
*                     OR     ifkkop-augrd = '02'
*                     OR ifkkop-augrd = '03'
*                     OR ifkkop-augrd = '07'
*                     OR ifkkop-augrd = '08' ).
*        CLEAR libel.
*        READ TABLE libel WITH KEY opbel = ifkkop-augbl.
*        IF sy-subrc <> 0.
*          SELECT SINGLE * FROM dfkkop WHERE opbel = ifkkop-augbl.
**                                    AND   vkont = wout-vkont.
*          IF sy-subrc <> 0.
*            libel-opbel = ifkkop-augbl.
*            CLEAR libel-found.
*            APPEND libel.
*          ELSE.
*            libel-opbel = ifkkop-augbl.
*            libel-found = 'X'.
*            APPEND libel.
*          ENDIF.
*        ENDIF.
*        IF libel-found = 'X'.
*          CLEAR lvkfound.
*          LOOP AT liumbel WHERE opbel = ifkkop-augbl.
*            ADD 1 TO lvkfound.
*            IF lvkfound > 1.
*              EXIT.
*            ENDIF.
*          ENDLOOP.
*          CASE lvkfound.
*            WHEN 0.
*              SELECT opbel vkont FROM dfkkop APPENDING TABLE liumbel
*                                 WHERE opbel = ifkkop-augbl.
*              DELETE ADJACENT DUPLICATES FROM liumbel
*                     COMPARING ALL FIELDS.
*            WHEN 1.
*            WHEN 2.
*          ENDCASE.
*          IF lvkfound = 0.
*            LOOP AT liumbel WHERE opbel = ifkkop-augbl.
*              ADD 1 TO lvkfound.
*              IF lvkfound > 1.
*                EXIT.
*              ENDIF.
*            ENDLOOP.
*          ENDIF.
*          IF lvkfound = 2.
** do nothing
*          ELSE.
*            DELETE ifkkop.
*          ENDIF.
*        ELSE.
*          SELECT SINGLE * FROM dfkkko WHERE opbel = ifkkop-augbl.
*          CASE dfkkko-herkf.
*            WHEN '01'.
*            WHEN '05'.
*            WHEN '06'.
*            WHEN '19'.
*            WHEN '25'.
*            WHEN OTHERS.
*              DELETE ifkkop.
*          ENDCASE.
*        ENDIF.
*      ENDIF.
*
*    ENDIF.
*  ENDLOOP.

* Alles ausgeglichene Löschen
  DELETE ifkkop WHERE augst = '9'.




  LOOP AT ifkkop.
    MOVE ifkkop-opbel TO iopbel-opbel.
    MOVE ifkkop-vkont TO iopbel-vkont.
    COLLECT iopbel.
  ENDLOOP.


  SORT iopbel BY opbel.
  SORT ifkkop BY opbel opupk.

  LOOP AT iopbel.

*>   Initialisierung
    PERFORM init_doc.
    CLEAR: idoc_out, wdoc_out.
    REFRESH: idoc_out.
*<

* idoc_KO
    SELECT SINGLE * FROM dfkkko WHERE opbel = iopbel-opbel.
    IF sy-subrc EQ 0.
      MOVE-CORRESPONDING dfkkko TO idoc_ko.

**    Für SWL Übernahme des Originalbelegs in die Referenz
      idoc_ko-xblnr = dfkkko-opbel.

      APPEND idoc_ko.
      CLEAR idoc_ko.

* idoc_ADDINF (für Sammler)
** Für Sammler wird der Abweichende Beleg übertragen, wenn der Typ S ist
** Das Passiert weiter unten
*      IF NOT dfkkko-xblnr IS INITIAL.
*        MOVE dfkkko-xblnr  TO idoc_addinf-srxblnr.
*        APPEND idoc_addinf.
*        CLEAR idoc_addinf.
*      ENDIF.

    ELSE.

      CONCATENATE  'Beleg' ifkkop-opbel 'nicht in DFKKKO'
        INTO meldung-meldung SEPARATED BY space.
      APPEND meldung.
      CONTINUE.
    ENDIF.

* opk brauchen wir gar nicht zu füllen, da die Gegenkonten neu ermittelt
* werden
** erstmal aussternen und Gesammtbetrag migrieren (ohne Steuer) s.u.

**** idoc_OPK
*    SELECT * FROM dfkkopk WHERE opbel = iopbel-opbel.
**                           AND  opupk = ifkkop-opupk.
*      MOVE-CORRESPONDING dfkkopk TO idoc_opk.
*      APPEND idoc_opk.
*      CLEAR idoc_opk.
*    ENDSELECT.


** Auf Wunsch des Kunden werden alle Positionen gesperrt
** deshalb wird das Coding an dieser Stelle auskommentiert
** idoc_OPL
*    SELECT * FROM dfkklocks INTO TABLE ilock
*                 WHERE lotyp = '02'
*                   AND proid = '01'
*                   AND lockr NE space
*                   AND vkont = iopbel-vkont
*                   AND tdate = '99991231'.
*    IF sy-subrc EQ 0.
***    move ifkkop-opbel to beleg
*      MOVE iopbel-opbel TO beleg.
*      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*        EXPORTING
*          input  = beleg
*        IMPORTING
*          output = beleg.
*
*
*      LOOP AT ilock WHERE loobj1(12) = beleg.
*        MOVE-CORRESPONDING ilock TO idoc_opl.
*** Sperre nur Eintragen, wenn Gesperrte Position offen
*        READ TABLE ifkkop TRANSPORTING NO FIELDS
*             WITH KEY opbel = beleg
*                      opupw = ilock-loobj1+12(3)
*                      opupk = ilock-loobj1+15(4).
*        IF sy-subrc = 0.
*          idoc_opl-opupw = ilock-loobj1+12(3).
*          idoc_opl-opupk = ilock-loobj1+15(4).
*          APPEND idoc_opl.
*          CLEAR idoc_opl.
*        ENDIF.
*      ENDLOOP.
*
*    ENDIF.

    CLEAR: h_betrag, h_pos.
    LOOP AT ifkkop WHERE opbel = iopbel-opbel.

* idoc_OP
      MOVE-CORRESPONDING ifkkop TO idoc_op.


**  VTREF wieder konvertieren in das Originalformat
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = idoc_op-vtref
        IMPORTING
          output = idoc_op-vtref.

      APPEND idoc_op.
      CLEAR idoc_op.

      ADD ifkkop-betrw TO h_betrag.


*** idoc_ADDINFO (für Sammler)
*** Hier wird ein Sammelrechnungsbeleg weggeschrieben, falls in dem
*** Posten ein abweichender Beleg vom Typ S steht
      IF NOT ifkkop-abwbl IS INITIAL.
        IF ifkkop-abwtp = 'S'.
          MOVE ifkkop-abwbl TO idoc_addinf-srxblnr.
          APPEND idoc_addinf.
          CLEAR idoc_addinf.
        ENDIF.
      ENDIF.

** an dieser Stelle idoc_OPK füllen
** keine Statistischen Posten
** Nur wenn schon ein OPK da ist
      SELECT * FROM dfkkopk WHERE opbel = ifkkop-opbel.
        EXIT.
      ENDSELECT.
      IF sy-subrc = 0.
        IF ifkkop-stakz IS INITIAL.
          idoc_opk-betrw = ( ifkkop-betrw * -1 ).
          idoc_opk-betrh = ( ifkkop-betrh * -1 ).
          idoc_opk-bukrs = ifkkop-bukrs.
          idoc_opk-hkont = '20326920'.
          idoc_opk-mwskz = ifkkop-mwskz.
          COLLECT idoc_opk.
          CLEAR idoc_opk.
        ENDIF.
      ENDIF.

** idoc_OPL
** Auf Wunsch von des Kunden werden für SWL alle offenen Positionen
** mit einer unbefristeten Mahn- und Zahlsperre versehen
** Mahnsperre (PROID = 01)
      add 1 to h_pos.

      idoc_opl-opupw = ifkkop-opupw.
      idoc_opl-opupk = h_pos.
      idoc_opl-fdate = '00010101'.
      idoc_opl-tdate = '99991231'.
      idoc_opl-proid = '01'.
      APPEND idoc_opl.
      CLEAR idoc_opl.

** Zahlsperre (PROID = 10)
      idoc_opl-opupw = ifkkop-opupw.
      idoc_opl-opupk = h_pos.
      idoc_opl-fdate = '00010101'.
      idoc_opl-tdate = '99991231'.
      idoc_opl-proid = '10'.
      APPEND idoc_opl.
      CLEAR idoc_opl.

* neuen oldkey für Datei zusammenbasteln (Vkontonummer geht nicht)
*      CONCATENATE ifkkop-opbel '_' ifkkop-opupk INTO oldkey_s.

    ENDLOOP.




*>> TESTWEISE erstmal hier hart füllen (ohne Steuerbetrag)
** idoc_OPK
*    if h_stakz is initial. "Gegenbuchung bei nicht statistisch
*      idoc_opk-bukrs = h_bukrs.
*      idoc_opk-hkont = '0089150000'. "TEST TEST TEST
*      idoc_opk-betrw = h_betrag * -1.
*
*      APPEND idoc_opk.
*      CLEAR idoc_opk.
*    endif.
*<< TESTWEISE erstmal hier hart füllen


*< Datenermittlung ---------



* neuer oldkey für Datei  (Vkontonummer geht nicht)
    oldkey_s  = iopbel-opbel.



*>> Wegschreiben des Objektschlüssels in Entlade-KSV
    o_key = oldkey_s.
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
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_ENT_DOCUMENT'
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
      TRANSFER wdoc_out TO ent_file.
    ENDLOOP.


  ENDLOOP.



  ENDFUNCTION.
