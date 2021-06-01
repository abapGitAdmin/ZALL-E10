*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTE_REL_NN_ANLAGEN
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT /adesso/mte_rel_nn_anlagen.

** Datenbanken
DATA: wa_rel       TYPE /adesso/mte_rel,
      it_rel       TYPE TABLE OF /adesso/mte_rel,
      wa_doc       TYPE tinv_inv_doc,
      wa_head      TYPE tinv_inv_head,
      wa_extid     TYPE tinv_inv_extid,
      wa_euiinstln TYPE euiinstln,
      wa_euitrans  TYPE euitrans.

DATA: BEGIN OF wa_ausgabe,
        beleg        LIKE tinv_inv_doc-int_inv_doc_no,
        invoice_date LIKE tinv_inv_doc-invoice_date,
        ext_sender   LIKE tinv_inv_head-ext_sender,
        int_sender   LIKE tinv_inv_head-int_sender,
        ext_ui       LIKE euitrans-ext_ui,
        anlage       LIKE euiinstln-anlage,
        komment      TYPE char70,
      END OF wa_ausgabe.
DATA: it_ausgabe LIKE STANDARD TABLE OF wa_ausgabe.

DATA: z_all  TYPE i.
DATA: z_nozp TYPE i.
DATA: z_zperr TYPE i.
DATA: z_irrel TYPE i.
DATA: z_rel   TYPE i.

DATA: h_seite TYPE char1.

DATA: irel LIKE TABLE OF /adesso/mte_rel,
      wrel LIKE /adesso/mte_rel.

DATA:       objcount TYPE i.

** MAKRO für Relevanztabelle
DEFINE mac_add_relevanz.

  wrel-firma = firma.
  wrel-object = &1.
  wrel-obj_key = &2.
  append wrel to irel.

END-OF-DEFINITION.


************************************************************************
* Selektionsbildschirm
**********************************************************************
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-001.
PARAMETERS: firma LIKE temfd-firma DEFAULT 'EGUT ' OBLIGATORY.
SELECT-OPTIONS: so_bel FOR wa_doc-int_inv_doc_no.
SELECTION-SCREEN SKIP.
PARAMETERS: p_rel AS CHECKBOX.

SELECTION-SCREEN END OF BLOCK bl1.

***********************************************************************
* TOP-OF-PAGE
************************************************************************
TOP-OF-PAGE.
  PERFORM seitenkopf.


*********************************************************************
* START-OF-SELECTZION
*********************************************************************
START-OF-SELECTION.
  PERFORM select_data.
  IF p_rel IS NOT INITIAL.
    PERFORM update_reltab.
  ENDIF.


*********************************************************************
* end-OF-SELECTZION
*********************************************************************
END-OF-SELECTION.
  PERFORM protokoll.
  IF p_rel IS NOT INITIAL.
    PERFORM protokoll_rel.
  ENDIF.

  IF it_ausgabe IS NOT INITIAL.
    PERFORM liste_ausgeben.
  ENDIF.


*&---------------------------------------------------------------------*
*&      Form  SELECT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM select_data .

* Belegnummern aus der Relevanztabelle ermitteln
  SELECT * FROM /adesso/mte_rel
      INTO TABLE it_rel
       WHERE firma = 'EGUT'
        AND object = 'INVOICE'
       AND obj_key IN so_bel.


  LOOP AT it_rel INTO wa_rel.

    ADD 1 TO z_all.

*   Beleg aus der TINV_INV_DOC ermitteln
*   In der Relevanztabelle steht der HEADER, alsi die INT_INV_NO
    SELECT SINGLE * FROM tinv_inv_doc INTO wa_doc
       WHERE int_inv_doc_no = wa_rel-obj_key.

**  Zählpunkt über TINV_INV_EXTID holen
**  Hier wird über die INT_INV_DOC_NO selektiert
    CLEAR wa_extid.
    SELECT * FROM tinv_inv_extid INTO wa_extid
       WHERE int_inv_doc_no = wa_doc-int_inv_doc_no.
      EXIT.
    ENDSELECT.

*   Sender der Rechnung ermitteln
    CLEAR wa_head.
    SELECT SINGLE * FROM tinv_inv_head INTO wa_head
       WHERE int_inv_no = wa_doc-int_inv_no.

**  Kein externer ZP in TINV_INV_EXTID gefunden
    IF sy-subrc NE 0.
      wa_ausgabe-beleg = wa_doc-int_inv_doc_no.
      wa_ausgabe-invoice_date = wa_doc-invoice_date.
      wa_ausgabe-ext_sender = wa_head-ext_sender.
      wa_ausgabe-int_sender = wa_head-int_sender.
      wa_ausgabe-komment = 'kein externer Zählpunkt ermittelbar'.
      ADD 1 TO z_nozp.
      APPEND wa_ausgabe TO it_ausgabe.
      CLEAR wa_ausgabe.
      CONTINUE.
    ENDIF.


**  EUIINSTLN lesen
**  Prüfen, wenn in der TINV_INV_EXTID der externe ZP gefüllt ist.
    IF wa_extid-ext_ident IS NOT INITIAL.
      CLEAR: wa_euiinstln.
      SELECT SINGLE * INTO CORRESPONDING FIELDS OF wa_euiinstln
        FROM euiinstln INNER JOIN euitrans
           ON euitrans~int_ui = euiinstln~int_ui
          WHERE euitrans~ext_ui = wa_extid-ext_ident.
**        Keine Prüfung auf Rechnungsdatum, da die zeitliche Relevanz der externen Bezeichnung
**        nicht immer mit dem Rechnungsdatum übereinstimmt.
*           AND euitrans~dateto GE wa_doc-invoice_date
*           AND euitrans~datefrom LE wa_doc-invoice_date.

**  Es wurde keine Anlage gefunden
      IF sy-subrc NE 0.
        wa_ausgabe-beleg = wa_doc-int_inv_doc_no.
        wa_ausgabe-ext_ui = wa_extid-ext_ident.
        wa_ausgabe-invoice_date = wa_doc-invoice_date.
        wa_ausgabe-ext_sender = wa_head-ext_sender.
        wa_ausgabe-int_sender = wa_head-int_sender.
        wa_ausgabe-komment = 'Externer Zählpunkt im System nicht gefunden bzw. nicht gültig'.
        ADD 1 TO z_zperr.
        APPEND wa_ausgabe TO it_ausgabe.
        CLEAR wa_ausgabe.
        CONTINUE.
      ENDIF.


**  Prüfen, ob die Anlage relevant ist
      CLEAR wa_rel.
      SELECT SINGLE * FROM /adesso/mte_rel INTO wa_rel
        WHERE firma = 'EGUT'
         AND object = 'INSTLN'
          AND obj_key = wa_euiinstln-anlage.

*     Anlage ist nicht relevant --> Wegschreiben
      IF sy-subrc NE 0.
        wa_ausgabe-beleg = wa_doc-int_inv_doc_no.
        wa_ausgabe-invoice_date = wa_doc-invoice_date.
        wa_ausgabe-ext_sender = wa_head-ext_sender.
        wa_ausgabe-int_sender = wa_head-int_sender.
        wa_ausgabe-ext_ui = wa_extid-ext_ident.
        wa_ausgabe-anlage = wa_euiinstln-anlage.
        wa_ausgabe-komment = 'Anlage irrelevant'.
**      Relevanztabelle füllen, wenn gewünscht
        IF p_rel IS NOT INITIAL.
          IF wa_ausgabe-anlage IS NOT INITIAL.
            mac_add_relevanz 'INSTLN_NN' wa_ausgabe-anlage.
          ENDIF.
        ENDIF.
        APPEND wa_ausgabe TO it_ausgabe.
        CLEAR wa_ausgabe.
        ADD 1 TO z_irrel.
      ELSE.
        ADD 1 TO z_rel.
      ENDIF.

    ELSE.
*     Über INT_IDENT selektieren
*     INT_IDENT ist initial --> kein ext. ZP ermittelbar
      IF wa_doc-int_ident IS INITIAL.
        wa_ausgabe-beleg = wa_doc-int_inv_doc_no.
        wa_ausgabe-invoice_date = wa_doc-invoice_date.
        wa_ausgabe-ext_sender = wa_head-ext_sender.
        wa_ausgabe-int_sender = wa_head-int_sender.
        wa_ausgabe-komment = 'kein externer Zählpunkt ermittelbar'.
        ADD 1 TO z_nozp.
        APPEND wa_ausgabe TO it_ausgabe.
        CLEAR wa_ausgabe.
        CONTINUE.
      ENDIF.

      CLEAR: wa_euitrans, wa_euiinstln.
      SELECT SINGLE * FROM euitrans INTO wa_euitrans
        WHERE int_ui = wa_doc-int_ident.
**        Keine Prüfung auf Rechnungsdatum, da die zeitliche Relevanz der externen Bezeichnung
**        nicht immer mit dem Rechnungsdatum übereinstimmt.
*          AND    dateto GE wa_doc-invoice_date
*          AND    datefrom LE wa_doc-invoice_date.
*      Kein EUITRANS zum INVOICE_DATE gefunden
      IF sy-subrc NE 0.
        wa_ausgabe-beleg = wa_doc-int_inv_doc_no.
        wa_ausgabe-ext_ui = wa_euitrans-ext_ui.
        wa_ausgabe-ext_sender = wa_head-ext_sender.
        wa_ausgabe-int_sender = wa_head-int_sender.
        wa_ausgabe-invoice_date = wa_doc-invoice_date.
        wa_ausgabe-komment = 'Externer Zählpunkt im System nicht gefunden bzw. nicht gültig'.
        ADD 1 TO z_zperr.
        APPEND wa_ausgabe TO it_ausgabe.
        CLEAR wa_ausgabe.
        CONTINUE.
      ENDIF.

*      EUIINSTLN prüfen
      SELECT SINGLE * FROM euiinstln INTO wa_euiinstln
        WHERE int_ui = wa_doc-int_ident .
*        and dateto GE wa_doc-invoice_date
*        and datefrom LE wa_doc-invoice_date.
      IF sy-subrc NE 0.
        wa_ausgabe-beleg = wa_doc-int_inv_doc_no.
        wa_ausgabe-ext_sender = wa_head-ext_sender.
        wa_ausgabe-int_sender = wa_head-int_sender.
        wa_ausgabe-invoice_date = wa_doc-invoice_date.
        wa_ausgabe-komment = 'kein externer Zählpunkt ermittelbar'.
        ADD 1 TO z_nozp.
        APPEND wa_ausgabe TO it_ausgabe.
        CLEAR wa_ausgabe.
        CONTINUE.
      ENDIF.
*      Prüfen, ob die Anlage relevant ist
      CLEAR wa_rel.
      SELECT SINGLE * FROM /adesso/mte_rel INTO wa_rel
        WHERE firma = 'EGUT'
         AND object = 'INSTLN'
          AND obj_key = wa_euiinstln-anlage.
*     Anlage ist nicht relevant --> Wegschreiben
      IF sy-subrc NE 0.
        wa_ausgabe-beleg = wa_doc-int_inv_doc_no.
        wa_ausgabe-invoice_date = wa_doc-invoice_date.
        wa_ausgabe-ext_sender = wa_head-ext_sender.
        wa_ausgabe-int_sender = wa_head-int_sender.
        wa_ausgabe-ext_ui = wa_euitrans-ext_ui.
        wa_ausgabe-anlage = wa_euiinstln-anlage.
        wa_ausgabe-komment = 'Anlage irrelevant'.
**      Relevanztabelle füllen, wenn gewünscht
        IF p_rel IS NOT INITIAL.
          IF wa_ausgabe-anlage IS NOT INITIAL.
            mac_add_relevanz 'INSTLN_NN' wa_ausgabe-anlage.
          ENDIF.
        ENDIF.
        APPEND wa_ausgabe TO it_ausgabe.
        CLEAR wa_ausgabe.
        ADD 1 TO z_irrel.
      ELSE.
        ADD 1 TO z_rel.
      ENDIF.

    ENDIF.

  ENDLOOP.


ENDFORM.                    " SELECT_DATA
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
  WRITE: /25 'P R O T O K O L L'.
  WRITE: /25 '================='.
  SKIP.
  WRITE: /5 'Gesamtzahl selektierter Belege', 50 z_all,
         /5 'davon:',
         /5 'Belege zu relevanten Anlagen', 50 z_rel,
         /5 'Belege zu bisher irrelevanten Anlagen', 50 z_irrel.
  SKIP 1.
  WRITE: /5 'sonstige Belege (ohne ermittelbare Anlagen):',
         /5 'Ext. ZP nicht im System gefunden', 50 z_zperr,
         /5 'Belege ohne Zählpunkt', 50 z_nozp.


ENDFORM.                    " PROTOKOLL

*&---------------------------------------------------------------------*
*&      Form  SEITENKOPF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM seitenkopf .

  IF h_seite = 'L'.
    WRITE: /5 'Beleg',
           25 'Belegdatum',
           40 'Rechnung-Sender',
           60 'Service-Anbieter',
           80 'Ext-ZP-Bbezeichnung',
           120 'Anlage',
           135 'Kommentar'.
    ULINE.


  ENDIF.

ENDFORM.                    " SEITENKOPF


*&---------------------------------------------------------------------*
*&      Form  LISTE_AUSGEBEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM liste_ausgeben .

  h_seite = 'L'.
  NEW-PAGE.
  LOOP AT it_ausgabe INTO wa_ausgabe.
    WRITE: /5  wa_ausgabe-beleg,
           25  wa_ausgabe-invoice_date,
           40(20) wa_ausgabe-ext_sender,
           60  wa_ausgabe-int_sender,
           80  wa_ausgabe-ext_ui,
           120 wa_ausgabe-anlage,
           135 wa_ausgabe-komment.
  ENDLOOP.

ENDFORM.                    " LISTE_AUSGEBEN


*&---------------------------------------------------------------------*
*&      Form  UPDATE_RELTAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_reltab .

  SORT irel.
  DELETE ADJACENT DUPLICATES FROM irel COMPARING ALL FIELDS.

  INSERT /adesso/mte_rel FROM TABLE irel ACCEPTING DUPLICATE KEYS.

ENDFORM.                    " UPDATE_RELTAB

*&---------------------------------------------------------------------*
*&      Form  PROTOKOLL_REL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM protokoll_rel .
  SKIP.
  WRITE: /5 'Füllen der Relevanztabelle'.
  SKIP.
  WRITE: /5 'Objekt', 55 'Anzahl'.
  ULINE AT /5(70).
  LOOP AT irel INTO wrel.
    AT NEW object.
      WRITE : /5 wrel-object.
    ENDAT.
    ADD 1 TO objcount.
    AT END OF object.
      WRITE : 50 objcount.
      CLEAR objcount.
    ENDAT.
  ENDLOOP.

ENDFORM.                    " PROTOKOLL_REL
