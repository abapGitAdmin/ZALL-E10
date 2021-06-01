*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTB_MIG_INVOICE
*&
*&---------------------------------------------------------------------*
*& Dieser Report baut Netznutzungsabrechnungen (INVOICES) auf.
*& Es wird eine Exportdatei gelesen und je Altsystem-Beleg eine
*& Netznutzungsabrechnung aufgebaut.
*&
*& Es handelt sich um kein klassischen Migrationsobjekt. Es wird
*& jedoch je Altsystemschlüssel ein TEMKSV-Eintrag generiert.
*&
*& Die Belege können mit der Transaktion INVMON bearbeitet werden.
*&---------------------------------------------------------------------*
REPORT /adesso/mtb_mig_invoice LINE-SIZE 132.

*---------------------------------------------------------------------
* Datendeklaration
*---------------------------------------------------------------------
DATA ent_file TYPE emg_pfad.
*DATA bel_file TYPE emg_pfad.

* Interne Strukturen für INVOICE

* BAPI-SChnittstelle
* Für BAPI_INV_LINE wurde eine Kundenstruktur entwickelt da
* Daten aus einer Sequentiellen Datei übertragen werden und
* es durch gepackte Zahlen bei der Übertragung der Felder
* zu Problemen wegen UNICODE kommt.
DATA: x_control     TYPE bapi_inv_control,
      x_inv_head    TYPE bapi_inv_head,
      x_inv_doc     TYPE bapi_inv_doc,
      t_inv_doc     TYPE STANDARD TABLE OF bapi_inv_doc,
      x_inv_lineb   TYPE /adesso/mt_bapi_inv_line,
      t_inv_lineb   TYPE STANDARD TABLE OF /adesso/mt_bapi_inv_line,
      x_inv_doc_db  TYPE /adesso/mt_tinv_inv_doc,
      x_inv_append  TYPE bapiparex,
      t_inv_append  TYPE STANDARD TABLE OF bapiparex,
      x_bapi_return TYPE bapiret2,
      t_bapi_return TYPE STANDARD TABLE OF bapiret2.

* Nochmals die BAPI_INV_LINE im Original
DATA: x_bapi_inv_line TYPE bapi_inv_line,
      t_bapi_inv_line TYPE STANDARD TABLE OF bapi_inv_line.


DATA: e_inv_head       TYPE tinv_inv_head,
      e_inv_doc_tab    TYPE ttinv_inv_doc,
      e_inv_line_tab_i TYPE ttinv_inv_line_i,
      e_inv_line_tab_b TYPE ttinv_inv_line_b,
      e_inv_line_tab_a TYPE ttinv_inv_line_a.


DATA: itrans          LIKE  /adesso/mt_transfer.

DATA: imeldung LIKE /adesso/mt_messages OCCURS 0 WITH HEADER LINE.

* Zähler
DATA: anz_inv TYPE i,
      anz_suc TYPE i,
      anz_err TYPE i,
      anz_tem TYPE i.

DATA: z_commit TYPE i.

DATA: success   TYPE char1,
      in_temksv TYPE char1.


DATA: wa_eservprov TYPE eservprov.
DATA: wa_t100 TYPE t100.
DATA: wa_temksv TYPE temksv.

DATA: longtext(255) TYPE c,
      h_seite(1)    TYPE c.

DATA: BEGIN OF wa_success_list,
        oldkey    TYPE temksv-oldkey,
        newkey    TYPE temksv-newkey,
        text(255) TYPE c,
      END OF wa_success_list.
DATA: it_success_list LIKE STANDARD TABLE OF wa_success_list.

DATA: BEGIN OF wa_error_list,
        oldkey    TYPE temksv-oldkey,
        text(255) TYPE c,
      END OF wa_error_list.
DATA: it_error_list LIKE STANDARD TABLE OF wa_error_list.

DATA: line_no(8) TYPE n.
DATA: wa_tinv_inv_line_b TYPE tinv_inv_line_b.
DATA: wa_head TYPE tinv_inv_head.

DATA: h_tabix TYPE sy-tabix.


***********************************************************************
* Selektionsbildschirm                                                *
***********************************************************************

* Grundeinstellungen (Firma, Exportpfad, Extension Export, Importpfad)
SELECTION-SCREEN BEGIN OF BLOCK a WITH FRAME TITLE text-b01.
SELECTION-SCREEN BEGIN OF BLOCK aa WITH FRAME TITLE text-b02.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(22) text-p01.
PARAMETERS: firma LIKE temfd-firma DEFAULT 'EGUT ' OBLIGATORY.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK aa.

SELECTION-SCREEN BEGIN OF BLOCK ab WITH FRAME TITLE text-b03.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(22) text-p02.
PARAMETERS: exp_path LIKE temfd-path
    DEFAULT '\\sdit10027\migration\Entladung_Golive\'.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(22) text-p03.
PARAMETERS: exp_ext(3) TYPE c DEFAULT 'EXP'.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK ab.

SELECTION-SCREEN END OF BLOCK a.

* Migrations-Objekte
SELECTION-SCREEN BEGIN OF BLOCK b WITH FRAME TITLE text-b05.
* Geräteinfosatz
SELECTION-SCREEN BEGIN OF BLOCK binv WITH FRAME TITLE text-inv.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(18) text-obj.
PARAMETERS: dat_inv LIKE temfd-file DEFAULT 'INVOICE'.
SELECTION-SCREEN COMMENT 42(12) text-001.
PARAMETERS: obj_inv AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK binv.
SELECTION-SCREEN END OF BLOCK b.

* Optionen
SELECTION-SCREEN BEGIN OF BLOCK o WITH FRAME TITLE text-b06.
SELECTION-SCREEN BEGIN OF BLOCK oa WITH FRAME TITLE text-b07.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(53) text-tem.
PARAMETERS: p_tem AS CHECKBOX.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(53) text-suc.
PARAMETERS: p_suc AS CHECKBOX.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK oa.
SELECTION-SCREEN BEGIN OF BLOCK ob WITH FRAME TITLE text-b08.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(15) text-sel.
SELECT-OPTIONS: s_oldkey FOR wa_head-int_inv_no.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK ob.

SELECTION-SCREEN END OF BLOCK o.

*---------------------------------------------------------------------
* TOP-OF-PAGE
*---------------------------------------------------------------------
TOP-OF-PAGE.
  PERFORM seitenkopf.


*---------------------------------------------------------------------
*START-OF-SELECTION
*---------------------------------------------------------------------
START-OF-SELECTION.

  IF obj_inv = 'X'.

    PERFORM entlade_file USING dat_inv.


    PERFORM mig_invoices TABLES imeldung
                         USING firma
                               ent_file
                         CHANGING anz_inv.


    CLOSE DATASET ent_file.


  ENDIF.


*---------------------------------------------------------------------
*START-OF-SELECTION
*---------------------------------------------------------------------
END-OF-SELECTION.

  PERFORM protokoll.

* Erfolgsliste - bei Bedarf ausgeben
  IF p_suc IS NOT INITIAL.
    IF it_success_list IS NOT INITIAL.
      h_seite = 'S'.
      NEW-PAGE.
      LOOP AT it_success_list INTO wa_success_list.
        WRITE: /5 wa_success_list-oldkey,
               25 wa_success_list-newkey,
               45 wa_success_list-text.
      ENDLOOP.
    ENDIF.
  ENDIF.
* Fehlerliste - Wird immer ausgegeben
  IF it_error_list IS NOT INITIAL.
    h_seite = 'E'.
    NEW-PAGE.
    LOOP AT it_error_list INTO wa_error_list.
      WRITE: /5 wa_error_list-oldkey,
             25 wa_error_list-text.
      AT END OF oldkey.
        ULINE.
      ENDAT.
    ENDLOOP.
  ENDIF.




*&---------------------------------------------------------------------*
*&      Form  ENTLADE_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DAT_INV  text
*----------------------------------------------------------------------*
FORM entlade_file  USING    object_name.

  CONCATENATE exp_path object_name '.' exp_ext
        INTO ent_file.

ENDFORM.                    " ENTLADE_FILE


*&---------------------------------------------------------------------*
*&      Form  MIG_INVOICES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IMELDUNG  text
*      -->P_FIRMA  text
*      -->P_ENT_FILE  text
*      <--P_ANZ_INV  text
*----------------------------------------------------------------------*
FORM mig_invoices  TABLES   meldung STRUCTURE /adesso/mt_messages
                   USING    firma TYPE emg_firma
                            ent_file TYPE emg_pfad
                   CHANGING anz_inv TYPE i.


  DATA: oldkey_inv LIKE /adesso/mt_transfer-oldkey.



  DATA: help_doc_type TYPE bapi_inv_doc-doc_type.

* einlesen der Datei
* open Dataset
  OPEN DATASET ent_file FOR INPUT IN TEXT MODE ENCODING DEFAULT.

* Error wenn falscher Pfad bzw.Datei
  IF sy-subrc NE 0.
    CONCATENATE 'Öffnen der Datei' ent_file 'nicht möglich'
      INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
    EXIT.
  ENDIF.


  DO.

    CLEAR: itrans.
    READ DATASET ent_file INTO itrans.

    IF sy-subrc = 0.

      CHECK itrans-oldkey IN s_oldkey.

*   Migrationsfirma prüfen.
      IF itrans-firma NE firma.
        CONCATENATE 'Falsche Migrationsfirma:'
                   itrans-firma
        INTO meldung-meldung SEPARATED BY space.
        APPEND meldung.
        EXIT.
      ENDIF.
*     Daten werden um einen Altsystemschlüssel verzögert aufgebaut, weil
*     erstmal alle Strukturtabellen ermittelt werden müssen
      IF itrans-oldkey NE oldkey_inv AND
            oldkey_inv NE space.


        CLEAR: success, in_temksv.

        PERFORM beleg_aufbauen USING oldkey_inv.

*       Zähler für Erfolg oder Fehler aufbauen
        IF success = 'X'.
          ADD 1 TO anz_suc.
        ELSEIF in_temksv = 'X'.
          ADD 1 TO anz_tem.
        ELSE.
          ADD 1 TO anz_err.
        ENDIF.

        CLEAR: t_inv_lineb, t_inv_doc, t_inv_append, t_bapi_return.

      ENDIF.
*      füllen der entsprechenden internern Tabellen und Strukturen je Altsystemschlüssel
*      zum Anlegen des Belegs
*      => je Datentyp eigene Tabelle
      CASE itrans-dttyp.

**      HEADER-Struktur BAPI_INV_HEAD
        WHEN 'HEAD'.
          CLEAR x_inv_head.
          MOVE itrans-data TO x_inv_head.

*       Initialisierung
          CLEAR x_inv_head-int_inv_no.
          CLEAR: x_inv_head-created_by, x_inv_head-created_on.
          CLEAR: x_inv_head-changed_by, x_inv_head-changed_on.

*       Festwerte:
          x_inv_head-sender_type = '01'.
          x_inv_head-receiver_type = '01'.

*       Umschlüsselungen
*       Receiver ist "Energiegut"
          x_inv_head-int_receiver = '40000004L'.
**       Umschlüsselung Sender
          CLEAR wa_eservprov.
          SELECT SINGLE serviceid  FROM eservprov INTO x_inv_head-int_sender
            WHERE externalid = x_inv_head-ext_sender.
          IF sy-subrc NE 0.
            CONCATENATE 'Für ext. Sender'
                        x_inv_head-ext_sender
                        'wurde kein Wert in ESERVPROV gefunden'
                       INTO meldung-meldung
                        SEPARATED BY space.
            APPEND meldung.
          ENDIF.

**      DOC-Struktur BAPI_INV_DOC
        WHEN 'DOC'.
          CLEAR x_inv_doc.
          MOVE itrans-data TO x_inv_doc.
*         Initialisierungen
          CLEAR: x_inv_doc-changed_by.
          CLEAR: x_inv_doc-changed_on.
*         Festwerte
          x_inv_doc-ext_ident_type = '01'.
*         Umschlüsselungen
          CASE x_inv_doc-doc_type.
            WHEN '001'.              "Jahresverbrauchsrechung
              help_doc_type = '010'.
            WHEN '002'.              "Abschlagsanforderung
              help_doc_type = '011'.
            WHEN '010'.              "Schlussrechnung
              help_doc_type = '012'.
            WHEN '020'.              "Zwischenrechnung
              help_doc_type = '014'.
            WHEN '005'.              "Storno Jahresverbrauchsrechnung
              help_doc_type = '020'.
            WHEN '006'.              "Storno Abschlagsanforderung
              help_doc_type = '021'.
            WHEN '011'.              "Storno Schulssrechnung
              help_doc_type = '022'.
            WHEN '021'.               "Storno Zwischenrechnung
              help_doc_type = '024'.
            WHEN OTHERS.

          ENDCASE.
          MOVE help_doc_type TO x_inv_doc-doc_type.
          CLEAR help_doc_type.
          APPEND x_inv_doc TO t_inv_doc.

***    DOC_DB wird 1:1 übertragen (für Statusverarbeitung )
***     TINV_INV_DOC
        WHEN 'DOC_DB'.
          CLEAR x_inv_doc_db.
          MOVE itrans-data TO x_inv_doc_db.

**      Belegzeilen - BAPI_INV_LINE
        WHEN 'LINEB'.
          CLEAR x_inv_lineb.
          MOVE itrans-data TO x_inv_lineb.
*         Initialisierungen
          CLEAR x_inv_lineb-mwskz.
          CLEAR x_inv_lineb-aufnr.
          CLEAR x_inv_lineb-prctr.
          CLEAR x_inv_lineb-ps_psp_pnr.
          APPEND x_inv_lineb TO t_inv_lineb.

**      Appern-Strukturen
        WHEN 'APPEND'.
          CLEAR x_inv_append.
          MOVE itrans-data TO x_inv_append.
          APPEND x_inv_append TO t_inv_append.

      ENDCASE.

      MOVE itrans-oldkey TO oldkey_inv.

    ELSE.

      CLEAR: success, in_temksv.

      IF oldkey_inv IS INITIAL.
        CLEAR: t_inv_lineb, t_inv_doc, t_inv_append, t_bapi_return.
        EXIT.
      ENDIF.


      PERFORM beleg_aufbauen USING oldkey_inv.

*     Zähler für Erfolg oder Fehler aufbauen
      IF success = 'X'.
        ADD 1 TO anz_suc.
      ELSEIF in_temksv = 'X'.
        ADD 1 TO anz_tem.
      ELSE.
        ADD 1 TO anz_err.
      ENDIF.

      CLEAR: t_inv_lineb, t_inv_doc, t_inv_append, t_bapi_return.
      EXIT.
    ENDIF.

  ENDDO.

ENDFORM.                    " MIG_INVOICES


*&---------------------------------------------------------------------*
*&      Form  SEITENKOPF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM seitenkopf .
  IF h_seite = 'S'.
    FORMAT COLOR COL_POSITIVE INTENSIFIED OFF.
    WRITE: /5 'Migrierte Belege', AT sy-linsz space.
    FORMAT COLOR COL_BACKGROUND.
    WRITE: /5 'Altschlüssel',
           25 'Neue Belegnummer',
           45 'Text'.
    ULINE.
  ENDIF.

  IF h_seite = 'E'.
    FORMAT COLOR COL_NEGATIVE INTENSIFIED OFF.
    WRITE: /5 'Fehler bei der Migration', AT sy-linsz space.
    FORMAT COLOR COL_BACKGROUND.
    WRITE: /5 'Altschlüssel',
           25 'Text'.
    ULINE.
  ENDIF.

ENDFORM.                    " SEITENKOPF

*&---------------------------------------------------------------------*
*&      Form  BELEG_AUFBAUEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM beleg_aufbauen USING oldkey_inv.

  ADD 1 TO anz_inv.
  CLEAR t_bapi_inv_line.
  LOOP AT t_inv_lineb INTO x_inv_lineb.
    MOVE-CORRESPONDING x_inv_lineb TO x_bapi_inv_line.
    APPEND x_bapi_inv_line TO t_bapi_inv_line.
  ENDLOOP.

*     Aufruf des BAPIs zum Anlegen der INVOIC
*    Prüfen, ob der Altschlüssel in der TEMKSV ist
  SELECT SINGLE * FROM temksv INTO wa_temksv
     WHERE firma = firma
      AND  object = 'INVOICE'
      AND oldkey = oldkey_inv.
  IF sy-subrc = 0.
*   Fehler in Fehlerliste reinschreiben, wenn so selektiert
    IF p_tem IS NOT INITIAL.
      MOVE oldkey_inv TO wa_error_list-oldkey.
      MOVE 'wurde bereits migriert' TO wa_error_list-text.
      APPEND wa_error_list TO it_error_list.
      CLEAR wa_error_list.
    ENDIF.
    in_temksv = 'X'.
    CLEAR: t_inv_lineb, t_inv_doc, t_inv_append, t_bapi_return.
  ELSE.
    x_control-update_online = 'X'.

    CALL FUNCTION 'BAPI_INVRADVDOC_CREATE'
      EXPORTING
        controldata    = x_control
        invremadvhead  = x_inv_head
      IMPORTING
        inv_head       = e_inv_head
        inv_doc_tab    = e_inv_doc_tab
        inv_line_tab_i = e_inv_line_tab_i
        inv_line_tab_b = e_inv_line_tab_b
        inv_line_tab_a = e_inv_line_tab_a
      TABLES
        invremadvdocs  = t_inv_doc
        invremadvlines = t_bapi_inv_line
        extensionin    = t_inv_append
        return         = t_bapi_return.

    DESCRIBE TABLE t_bapi_return LINES sy-tabix.
    IF sy-tabix = 0.
*     Sollte nicht vorkommen
    ELSE.
      LOOP AT t_bapi_return INTO x_bapi_return.
        SELECT SINGLE * FROM t100 INTO wa_t100
               WHERE sprsl = 'DE'
                 AND arbgb = x_bapi_return-id
                 AND msgnr = x_bapi_return-number.
        MOVE wa_t100-text TO longtext.
        REPLACE ALL OCCURRENCES OF '&1' IN longtext WITH x_bapi_return-message_v1.
        REPLACE ALL OCCURRENCES OF '&2' IN longtext WITH x_bapi_return-message_v2.
        REPLACE ALL OCCURRENCES OF '&3' IN longtext WITH x_bapi_return-message_v3.
        REPLACE ALL OCCURRENCES OF '&4' IN longtext WITH x_bapi_return-message_v4.
*    Erfolgsmeldung
        IF x_bapi_return-type = 'S'.
*      Meldung  "Der Beleg &1 wurde erfolgreich angelegt"
          IF x_bapi_return-id = 'INV' AND
             x_bapi_return-number = '070'.

            success = 'X'.

*           Nachpflegen der APPEND-Struktur für TINV_INV_LINE_B
*           Die Struktur wurde vom vorherigen BAPI nicht angelegt
*           (Vermischung von CHAR und gepackten Zahlen)
            CLEAR h_tabix.
            LOOP AT t_inv_append INTO x_inv_append
                WHERE structure = 'BAPI_TE_TINV_INV_LINE_B'.
              ADD 1 TO h_tabix.
              SELECT SINGLE * FROM tinv_inv_line_b INTO wa_tinv_inv_line_b
                WHERE int_inv_doc_no = x_bapi_return-message_v1
                AND int_inv_line_no = h_tabix.

              IF sy-subrc = 0.
                wa_tinv_inv_line_b-/idexge/line_id = x_inv_append-valuepart1+24(8).
                wa_tinv_inv_line_b-/idexge/quant2 = x_inv_append-valuepart1+32(15).
                wa_tinv_inv_line_b-/idexge/invunit2 = x_inv_append-valuepart1+47(3).
                wa_tinv_inv_line_b-/idexge/discount = x_inv_append-valuepart1+50(13).
                wa_tinv_inv_line_b-/idexge/currency = x_inv_append-valuepart1+63(5).

*                wa_tinv_inv_line_b-/idexge/quant2 = x_inv_append-valuepart1+32(8).
*                wa_tinv_inv_line_b-/idexge/invunit2 = x_inv_append-valuepart1+40(3).
*                wa_tinv_inv_line_b-/idexge/discount = x_inv_append-valuepart1+43(7).
*                wa_tinv_inv_line_b-/idexge/currency = x_inv_append-valuepart1+50(3).
                UPDATE tinv_inv_line_b FROM wa_tinv_inv_line_b.
              ENDIF.
            ENDLOOP.

**          Statusverarbeitung ???

*           TEMKSV Füllen
            CLEAR wa_temksv.
            wa_temksv-firma = firma.
            wa_temksv-object = 'INVOICE'.
            wa_temksv-oldkey = oldkey_inv.
            wa_temksv-newkey = x_bapi_return-message_v1.
            INSERT temksv FROM wa_temksv.
            ADD 1 TO z_commit.
            IF z_commit = 100.
              COMMIT WORK.
              CLEAR z_commit.
            ENDIF.

**          Füllen der Liste mit den erfolgreich migrierten Belegen
            MOVE oldkey_inv TO wa_success_list-oldkey.
            MOVE x_bapi_return-message_v1 TO wa_success_list-newkey.
            MOVE longtext TO wa_success_list-text.
            APPEND wa_success_list TO it_success_list.
            CLEAR wa_success_list.
**        Andere S-Messages nicht wegschreiben
          ELSE.
            CLEAR x_bapi_return.
          ENDIF.
        ELSE.
**        Fehlermeldungen
          MOVE oldkey_inv TO wa_error_list-oldkey.
          MOVE longtext TO wa_error_list-text.
          APPEND wa_error_list TO it_error_list.
          CLEAR wa_error_list.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDFORM.                    " BELEG_AUFBAUEN

*&---------------------------------------------------------------------*
*&      Form  PROTOKOLL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM protokoll .

  CLEAR h_seite.
  NEW-PAGE.
  SKIP 2.
  WRITE: /5 'Datei:', 20 ent_file.
  SKIP 2.
  WRITE: /25 'P R O T O K O L L'.
  WRITE: /25 '================='.
  SKIP 2.
  WRITE: /5 'Selektierte Belege', 60 anz_inv.
  WRITE: /5 'Davon bereits in TEMKSV enthalten', 60 anz_tem.
  WRITE: /5 'Davon erfolgreich migriert', 60 anz_suc.
  WRITE: /5 'Fehler bei der Migration', 60 anz_err.


ENDFORM.                    " PROTOKOLL
