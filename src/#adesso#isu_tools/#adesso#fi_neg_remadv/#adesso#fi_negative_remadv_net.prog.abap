*&---------------------------------------------------------------------*
*& Report  ZAD_FI_NEGATIVE_REMADV_NETZ
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT /adesso/fi_negative_remadv_net.

* Informationen zum Programm / Änderungen
INCLUDE /adesso/fi_neg_remadv_inc_def.
*INCLUDE /adesso/fi_neg_remadv_inc_def.
*INCLUDE zad_fi_neg_remadv_inc_def.
INCLUDE /adesso/fi_neg_remadv_inc_add.
*INCLUDE /adesso/fi_neg_remadv_inc_add.
*INCLUDE zad_fi_neg_remadv_inc_add.
TYPE-POOLS: icon.
*INCLUDE icons.

DATA: BEGIN OF wa_inv_head_doc,
        int_inv_no      TYPE inv_int_inv_no,
        invoice_type    TYPE inv_invoice_type,
        date_of_receipt TYPE inv_date_of_receipt,
        invoice_status  TYPE inv_invoice_status,
        int_receiver    TYPE inv_int_receiver,
        int_sender      TYPE inv_int_sender,
        int_inv_doc_no  TYPE inv_int_inv_doc_no,
        ext_invoice_no  TYPE inv_ext_invoice_no,
        doc_type        TYPE inv_doc_type,
        inv_doc_status  TYPE inv_doc_status,
        date_of_payment TYPE inv_date_of_payment,
        invoice_date    TYPE inv_invoice_date,
      END OF wa_inv_head_doc.
DATA  c_applk TYPE applk_kk.

********************************************************************************
* Selektionsbildschirm
********************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK head WITH FRAME TITLE TEXT-001.
PARAMETERS:     p_invtp  TYPE /adesso/fi_negremadv_invtyp DEFAULT '1'
                         AS LISTBOX VISIBLE LENGTH 30.
SELECT-OPTIONS: s_aggr FOR wa_fkkvkp-vkont,
                s_send  FOR wa_inv_head-int_sender,
                s_rece  FOR wa_inv_head-int_receiver,
                s_insta FOR wa_inv_head-invoice_status
                MODIF ID sta DEFAULT '01' TO '99',
                s_dtrec FOR wa_inv_head-date_of_receipt.
SELECTION-SCREEN END OF BLOCK head.

SELECTION-SCREEN BEGIN OF BLOCK doc WITH FRAME TITLE TEXT-002.
SELECT-OPTIONS: s_intido FOR wa_inv_doc-int_inv_doc_no,
                s_extido FOR wa_inv_doc-ext_invoice_no,
                s_doctyp FOR wa_inv_doc-doc_type,
                s_idosta FOR wa_inv_doc-inv_doc_status,
                s_dtpaym FOR wa_inv_doc-date_of_payment,
                s_invoda FOR wa_inv_doc-invoice_date,
                s_rstgr  FOR wa_inv_line_a-rstgr,
                s_owninv FOR wa_inv_line_a-own_invoice_no,
                s_extui  FOR wa_euitrans-ext_ui NO-DISPLAY.       "Nuss 10.2017 Melo/Malo
SELECTION-SCREEN END OF BLOCK doc.

SELECTION-SCREEN BEGIN OF BLOCK mahn WITH FRAME TITLE TEXT-005 .
PARAMETERS:     pa_lockr LIKE fkkvkp-mansp DEFAULT '8' MODIF ID mah .
PARAMETERS:     pa_fdate LIKE sy-datum MODIF ID mah .
PARAMETERS:     pa_tdate LIKE sy-datum MODIF ID mah .
SELECTION-SCREEN END OF BLOCK mahn.

SELECTION-SCREEN BEGIN OF BLOCK vari WITH FRAME TITLE TEXT-004 .
PARAMETERS: p_storno AS CHECKBOX DEFAULT ' '.
PARAMETERS: p_vari LIKE disvariant-variant.
SELECTION-SCREEN END OF BLOCK vari.


AT SELECTION-SCREEN OUTPUT.
  SELECT COUNT( * ) FROM /adesso/fi_remad WHERE negrem_option = 'SELSCREEN' AND negrem_field = 'MAHNSPERRE' AND negrem_value = 'X'.
  IF sy-subrc <> 0.
    LOOP AT SCREEN.
      IF screen-group1 EQ 'MAH'.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSE.
    IF pa_fdate IS INITIAL.
      pa_fdate = sy-datum.
      pa_tdate = sy-datum + 14.
    ENDIF.
  ENDIF.

*********************************************************************************
* INITILALZATION
*********************************************************************************
INITIALIZATION.
  PERFORM init_custom_fields.
  DATA: r_vktyp TYPE RANGE OF te002a-vktyp WITH HEADER LINE.
  DATA t_te002a   LIKE te002a           OCCURS 0 WITH HEADER LINE.
  SELECT * FROM te002a
           INTO TABLE t_te002a
           WHERE fktsa = 'X'.
  LOOP AT t_te002a.
    r_vktyp-option = 'EQ'.
    r_vktyp-sign   = 'I'.
    r_vktyp-low    = t_te002a-vktyp.
    APPEND r_vktyp.
  ENDLOOP.

  g_repid = sy-repid.
  g_save = 'A'.
  PERFORM variant_init.
* Get default variant
  gx_variant = g_variant.
  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
    EXPORTING
      i_save     = g_save
    CHANGING
      cs_variant = gx_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 0.
    p_vari = gx_variant-variant.
  ENDIF.

*********************************************************************************
* Process on value request
*********************************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM f4_for_variant.

**********************************************************************************
* AT SELECTION-SCREEN
**********************************************************************************
AT SELECTION-SCREEN.
  PERFORM check_input.
  PERFORM pai_of_selection_screen.

* --> Nuss 12.02.2018
* Mahnsperre Datum Checken
  SELECT COUNT( * ) FROM /adesso/fi_remad WHERE negrem_option = 'SELSCREEN' AND negrem_field = 'MAHNSPERRE' AND negrem_value = 'X'.
  IF sy-subrc = 0.
    IF pa_fdate < sy-datum.
      MESSAGE TEXT-e01 TYPE 'E'.
    ENDIF.

    IF pa_tdate < pa_fdate.
      MESSAGE TEXT-e02 TYPE 'E'.
    ENDIF.

  ENDIF.
* <-- Nuss 12.02.2018

**********************************************************************************
* AT SELECTION-SCREEN on s_aggr
**********************************************************************************
AT SELECTION-SCREEN ON s_aggr.
* Nur Vertragskonten vom Vertragskontotyp '11 (aggr. Vertragskonto Lieferant)'
  IF s_aggr IS NOT INITIAL.
    SELECT * FROM fkkvk INTO TABLE it_fkkvk
      WHERE vkont IN s_aggr
       AND vktyp IN r_vktyp.
    LOOP AT it_fkkvk INTO wa_fkkvk.
      CLEAR h_service_id.
      SELECT serviceid INTO h_service_id
         FROM eservprovp AS a
           INNER JOIN fkkvkp AS b
            ON a~bpart = b~gpart
           WHERE b~vkont = wa_fkkvk-vkont.
*       Hilfsrange aufbauen
        r_send-low = h_service_id.
        r_send-sign = 'I'.
        r_send-option = 'EQ'.
        APPEND r_send.
        CLEAR r_send.
      ENDSELECT.
    ENDLOOP.
  ENDIF.


*********************************************************************************
* START-OF-SELECTION
*********************************************************************************
START-OF-SELECTION.

  PERFORM selektionsbild_speichern.
  SELECT SINGLE * FROM ederegswitchsyst INTO wa_ederegswitchsyst.
  PERFORM get_customizing.
  PERFORM get_constants.
  IF p_invtp = 1.
    SELECT COUNT(*) FROM /adesso/fi_remad WHERE negrem_option = 'SELECT' AND negrem_category = 'OLD' AND negrem_value = 'X'.
    IF sy-subrc = 0.
      PERFORM daten_selektieren.
    ELSE.
      PERFORM daten_selektieren_old.
    ENDIF.
  ELSEIF p_invtp = 2.
    SELECT COUNT(*) FROM /adesso/fi_remad WHERE negrem_option = 'SELECT' AND negrem_category = 'OLD' AND negrem_value = 'X'.
    IF sy-subrc = 0.
      PERFORM daten_selektieren_memi.
    ELSE.
      PERFORM daten_selektieren_memi_old.
    ENDIF.

*   > Nuss 28.03.2017 Erweiterung MGV-Reklamation
  ELSEIF p_invtp = 3.
    SELECT COUNT(*) FROM /adesso/fi_remad WHERE negrem_option = 'SELECT'.
    IF sy-subrc = 0.
      PERFORM daten_selektieren_mgv.
    ELSE.
      PERFORM daten_selektieren_mgv_old.
    ENDIF.
* --> Nuss 09.2018 Erweiterung MSB-Reklamationen
  ELSEIF p_invtp = '4'.
    SELECT COUNT(*) FROM /adesso/fi_remad WHERE negrem_option = 'SELECT' AND negrem_category = 'OLD' AND negrem_value = 'X'.
    IF sy-subrc = 0.
      PERFORM daten_selektieren_msb.
    ELSE.
      PERFORM daten_selektieren_msb_old.
    ENDIF.
* <-- Nuss 09.2018

  ENDIF.
* <   Nuss 28.03.2017

*********************************************************************************
* START-OF-SELECTION
*********************************************************************************
END-OF-SELECTION.
  PERFORM layout_build USING gs_layout.
  PERFORM set_events CHANGING gt_event.  "Events
  PERFORM fieldcat_build USING gt_fieldcat[].  "Wg Parametern

  PERFORM display_alv.

*&---------------------------------------------------------------------*
*&      Form  DATEN_SELEKTIEREN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM daten_selektieren .


  SELECT h~int_inv_no      h~invoice_type
         h~date_of_receipt h~invoice_status
         h~int_receiver    h~int_sender
         d~int_inv_doc_no  d~ext_invoice_no
         d~doc_type        d~inv_doc_status
         d~date_of_payment d~invoice_date
    INTO CORRESPONDING FIELDS OF wa_inv_head_doc
    FROM tinv_inv_head AS h
      INNER JOIN tinv_inv_doc AS d
      ON h~int_inv_no EQ d~int_inv_no
    WHERE h~int_sender IN s_send
      AND h~invoice_type EQ co_invtype
      AND h~date_of_receipt IN s_dtrec
      AND h~invoice_status IN s_insta
      AND h~int_receiver IN s_rece
      AND d~int_inv_doc_no IN s_intido
      AND d~ext_invoice_no IN s_extido
      AND d~doc_type IN s_doctyp
      AND d~inv_doc_status IN s_idosta
      AND d~date_of_payment IN s_dtpaym.
    x_ctrem = x_ctrem + 1.
    MOVE wa_inv_head_doc-int_receiver TO wa_out-int_receiver.
    MOVE wa_inv_head_doc-int_sender   TO wa_out-int_sender.
    MOVE wa_inv_head_doc-invoice_status   TO wa_out-invoice_status.
    MOVE wa_inv_head_doc-date_of_receipt  TO wa_out-date_of_receipt.

** Aggr. Vertragskonto ermitteln
    SELECT SINGLE a~vkont INTO wa_out-aggvk
      FROM fkkvk AS a
       INNER JOIN fkkvkp AS b
         ON b~vkont = a~vkont
      INNER JOIN eservprovp AS c
        ON c~bpart = b~gpart
        WHERE c~serviceid = wa_out-int_sender
        AND a~vktyp IN r_vktyp.

    MOVE wa_inv_head_doc-int_inv_doc_no TO wa_out-int_inv_doc_no.
    MOVE wa_inv_head_doc-ext_invoice_no TO wa_out-ext_invoice_no.
    MOVE wa_inv_head_doc-doc_type TO wa_out-doc_type.
    MOVE wa_inv_head_doc-inv_doc_status TO wa_out-inv_doc_status.
    MOVE wa_inv_head_doc-date_of_payment TO wa_out-date_of_payment.
    MOVE wa_inv_head_doc-invoice_date TO wa_out-invoice_date.

* AVIS-Zeilen
    CLEAR wa_inv_line_a.
    SELECT * FROM tinv_inv_line_a INTO wa_inv_line_a
*      WHERE int_inv_doc_no EQ wa_inv_doc-int_inv_doc_no         "Nuss 08.2012
        WHERE int_inv_doc_no EQ wa_inv_head_doc-int_inv_doc_no   "Nuss 08.2012
        AND  rstgr IN s_rstgr
        AND  own_invoice_no IN s_owninv.

      CHECK wa_inv_line_a-rstgr IS NOT INITIAL.
      CHECK wa_inv_line_a-own_invoice_no IS NOT INITIAL.

*   Nuss: 11.09.2012
*   Füllen der Ausgabedaten nochmals, wenn mehrere Zeilen im AVIS
      IF wa_out-int_inv_doc_no IS INITIAL.
        MOVE wa_inv_head_doc-int_receiver TO wa_out-int_receiver.
        MOVE wa_inv_head_doc-int_sender   TO wa_out-int_sender.
        MOVE wa_inv_head_doc-invoice_status   TO wa_out-invoice_status.
        MOVE wa_inv_head_doc-date_of_receipt  TO wa_out-date_of_receipt.

        MOVE wa_inv_head_doc-int_inv_doc_no TO wa_out-int_inv_doc_no.
        MOVE wa_inv_head_doc-ext_invoice_no TO wa_out-ext_invoice_no.
        MOVE wa_inv_head_doc-doc_type TO wa_out-doc_type.
        MOVE wa_inv_head_doc-inv_doc_status TO wa_out-inv_doc_status.
        MOVE wa_inv_head_doc-date_of_payment TO wa_out-date_of_payment.
        MOVE wa_inv_head_doc-invoice_date TO wa_out-invoice_date.
      ENDIF.
**  <-- Nuss 11.09.2012

* Text zum Rückstellungsgrund
      CLEAR wa_inv_c_adj_rsnt.
      SELECT SINGLE * FROM tinv_c_adj_rsnt
         INTO wa_inv_c_adj_rsnt
           WHERE rstgr = wa_inv_line_a-rstgr
           AND spras = sy-langu.

* Langtext falls vorhanden
      CLEAR wa_noti.
*        IF wa_inv_line_a-rstgr = '28'.
      SELECT * FROM /idexge/rej_noti INTO wa_noti
*        WHERE int_inv_doc_no = wa_inv_doc-int_inv_doc_no.       "Nuss 08.2012
        WHERE int_inv_doc_no = wa_inv_head_doc-int_inv_doc_no
        AND int_inv_line_no = wa_inv_line_a-int_inv_line_no.   "Nuss 08.2012
        wa_out-free_text5 = wa_noti-free_text5.
        IF wa_noti-stat_remk(3) = '@0V'.
          wa_out-line_state = icon_okay.

        ENDIF.
        EXIT.
      ENDSELECT.
*        ENDIF.


*     WA_OUT füllen
      MOVE wa_inv_line_a-int_inv_line_no TO wa_out-int_inv_line_no.
      MOVE wa_inv_line_a-rstgr          TO wa_out-rstgr.
      MOVE wa_inv_c_adj_rsnt-text       TO wa_out-text.
      MOVE wa_noti-free_text1           TO wa_out-free_text1.
      MOVE wa_inv_line_a-own_invoice_no TO wa_out-own_invoice_no.
      MOVE wa_inv_line_a-betrw_req      TO wa_out-betrw_req.



**    <-- Nuss 27.07.2012

*  Externer Zählpunkt
      CLEAR wa_ecrossrefno.

      SELECT * FROM ecrossrefno INTO wa_ecrossrefno
        WHERE crossrefno = wa_inv_line_a-own_invoice_no(15)
        OR    crn_rev = wa_inv_line_a-own_invoice_no(15).
        EXIT.
      ENDSELECT.

      DATA ls_paym LIKE wa_paym.
      SELECT SINGLE a~own_invoice_no
       a~int_inv_doc_no
       c~invoice_status
  INTO CORRESPONDING FIELDS OF ls_paym
  FROM tinv_inv_line_a AS a
       INNER JOIN tinv_inv_doc AS b
       ON b~int_inv_doc_no = a~int_inv_doc_no
       INNER JOIN tinv_inv_head AS c
       ON c~int_inv_no = b~int_inv_no
*      FOR ALL ENTRIES IN t_crsrf_eui
  WHERE a~own_invoice_no = wa_ecrossrefno-crossrefno
    AND a~int_inv_doc_no = wa_out-int_inv_doc_no.            "Nuss 12.03.2018

      IF sy-subrc = 0.
        wa_out-paym_avis = ls_paym-int_inv_doc_no.
        wa_out-paym_stat = ls_paym-invoice_status.
      ENDIF.


      DATA: b_storno TYPE boolean.
      b_storno = abap_false.
      CLEAR wa_out-inf_invoice_cancel.
*      IF wa_ecrossrefno-crossrefno EQ wa_inv_line_a-own_invoice_no.
*        wa_out-inf_invoice_cancel = icon_storno.
*        b_storno = abap_true.
*      ENDIF.

      CLEAR wa_euitrans.
      SELECT SINGLE * FROM euitrans INTO wa_euitrans
         WHERE int_ui = wa_ecrossrefno-int_ui
         AND dateto = '99991231'.

*      CHECK wa_euitrans-ext_ui IN s_extui.                 "Nuss 10.2017  Melo/Malo

      MOVE wa_euitrans-ext_ui TO wa_out-ext_ui.

**    --> Nuss 10.2017  Melo/Malo
      CLEAR: it_idxgc_pod_rel, wa_idxgc_pod_rel.
      IF wa_euitrans-uistrutyp = 'MA'.
        SELECT * FROM /idxgc/pod_rel INTO TABLE it_idxgc_pod_rel
          WHERE int_ui2 = wa_ecrossrefno-int_ui.
      ENDIF.
      IF sy-subrc = 0.
        DESCRIBE TABLE it_idxgc_pod_rel LINES gv_podlines.
        READ TABLE it_idxgc_pod_rel INTO wa_idxgc_pod_rel INDEX 1.
        CLEAR wa_euitrans_melo.
        SELECT SINGLE * FROM euitrans INTO wa_euitrans_melo
           WHERE int_ui = wa_idxgc_pod_rel-int_ui1
           AND dateto = '99991231'.
        MOVE wa_euitrans_melo-ext_ui TO wa_out-ext_ui_melo.
        IF gv_podlines GT 1.
          MOVE 'X' TO wa_out-mult_melo.
        ENDIF.
      ENDIF.
**  <-- Nuss 10.2017 Melo/Malo



* Abrechnungsklasse ermitteln
      SELECT aklasse INTO wa_out-aklasse
        FROM eanlh AS a
          INNER JOIN euiinstln AS b
          ON b~anlage = a~anlage
          INNER JOIN euitrans AS c
           ON c~int_ui = b~int_ui
        WHERE c~ext_ui = wa_out-ext_ui
          AND c~dateto = '99991231'
          AND a~bis = '99991231'.
        EXIT.
      ENDSELECT.
*     DFKKTHI lesen
*     Nur Status "IDOC gebucht"

      CLEAR wa_dfkkthi.
      SELECT * FROM dfkkthi INTO wa_dfkkthi
       WHERE crsrf = wa_ecrossrefno-int_crossrefno
             AND  stidc = '' AND burel = 'X'.
        CHECK wa_dfkkthi-crsrf IS NOT INITIAL.
*          check wa_dfkkthi-thist = '4'.  "Nicht mehr benötigt, da auch andere Fälle möglich sind
        IF p_storno = 'X'.
          CHECK wa_dfkkthi-storn NE 'X'.
          CHECK wa_dfkkthi-stidc NE 'X'.

        ELSE.
          IF wa_dfkkthi-storn = 'X'.
            wa_out-inf_invoice_cancel = icon_storno.
            b_storno = abap_true.
          ENDIF.
          IF b_storno EQ abap_true.
            CHECK wa_dfkkthi-storn EQ 'X'.
          ELSEIF b_storno = abap_false.
            CHECK wa_dfkkthi-storn NE 'X'.
          ENDIF.
        ENDIF.
        MOVE-CORRESPONDING wa_dfkkthi TO wa_out.
        SELECT SINGLE * FROM dfkkop INTO wa_dfkkop
          WHERE opbel = wa_dfkkthi-opbel
            AND opupw = wa_dfkkthi-opupw
            AND opupk = wa_dfkkthi-opupk
            AND opupz = wa_dfkkthi-opupz.

        MOVE wa_dfkkop-xblnr TO wa_out-xblnr.
        SELECT COUNT(*) FROM /adesso/fi_remad WHERE negrem_option = 'FIELDCAT' AND negrem_field = 'BEMERKUNG' AND negrem_value = 'X'.
        IF sy-subrc = 0.
          SELECT COUNT(*) FROM /adesso/remtext WHERE int_inv_doc_nr = wa_out-int_inv_doc_no.
          IF sy-subrc = 0.
            wa_out-text_vorhanden = 'X'.
          ELSE.
            wa_out-text_vorhanden = ''.
          ENDIF.
        ENDIF.
        SELECT COUNT(*) FROM /adesso/fi_remad WHERE negrem_option = 'FIELDCAT' AND negrem_field = 'NOTIZ' AND negrem_value = 'X'.
        IF sy-subrc = 0.
          CLEAR gv_name.
          CLEAR xlines.
          CONCATENATE wa_out-int_inv_doc_no
                      '_'
                      wa_out-int_inv_line_no
                      INTO gv_name.

          CLEAR xlines.
          CALL FUNCTION 'READ_TEXT'
            EXPORTING
*             CLIENT                  = SY-MANDT
              id                      = co_id
              language                = sy-langu
              name                    = gv_name
              object                  = co_object
*             ARCHIVE_HANDLE          = 0
*             LOCAL_CAT               = ' '
*   IMPORTING
*             HEADER                  =
*             OLD_LINE_COUNTER        =
            TABLES
              lines                   = xlines
            EXCEPTIONS
              id                      = 1
              language                = 2
              name                    = 3
              not_found               = 4
              object                  = 5
              reference_check         = 6
              wrong_access_to_archive = 7
              OTHERS                  = 8.
          IF sy-subrc <> 0.
* Implement suitable error handling here
          ENDIF.

          READ TABLE xlines INTO help_line INDEX 1.

          IF sy-subrc = 0.
            wa_out-free_text5 = help_line.
            "  MODIFY it_out FROM wa_out .
          ENDIF.
        ENDIF.


        MOVE-CORRESPONDING wa_dfkkthi TO wa_dfkkthi_op.
        ASSIGN wa_dfkkthi_op TO <fs_dfkkthi_op>.
        PERFORM get_locks.
        PERFORM sel_bcontact USING wa_out.
        PERFORM sel_invstorno USING wa_out.
        SELECT COUNT(*) FROM /adesso/remtext WHERE int_inv_doc_nr = wa_out-int_inv_doc_no.
        IF sy-subrc = 0.
          wa_out-text_vorhanden = 'X'.
        ELSE.
          wa_out-text_vorhanden = ''.
        ENDIF.
        IF wa_out-int_inv_doc_no IS NOT INITIAL.
          APPEND wa_out TO it_out.
        ENDIF.
        CLEAR wa_out.

      ENDSELECT.


    ENDSELECT.

*    ENDSELECT.                                          "TINV_INV_DOC

  ENDSELECT.                                            "TINV_INV_HEAD

ENDFORM.                    " DATEN_SELEKTIEREN


*&---------------------------------------------------------------------*
*&      Form  DATEN_SELEKTIEREN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM daten_selektieren_old .

  DATA lv_invtype TYPE tinv_inv_head-invoice_type.
  lv_invtype = co_invtype.


* Texte zum Rückstellungsgrund
  SELECT * FROM tinv_c_adj_rsnt
           INTO TABLE t_inv_c_adj_rsnt
           WHERE spras = sy-langu.

* Hilfsrange Sender auf Selektionsrange übertragen
  IF r_send[] IS NOT INITIAL AND s_send[] IS INITIAL.
    s_send[] = r_send[].
  ENDIF.

* Reklamationsavise
  SELECT a~int_inv_doc_no
         a~int_inv_no
         a~int_partner
         a~doc_type
         a~invoice_date
         a~date_of_payment
         a~inv_doc_status
         a~int_ident
         a~invoice_type
         a~int_sender
         a~int_receiver
         a~date_of_receipt
         a~invoice_status
         a~auth_grp
         a~ext_invoice_no
         a~inv_bulk_ref
         b~int_inv_line_no
         b~rstgr
         b~own_invoice_no
         b~betrw_req
         c~free_text1
         c~free_text5
         c~stat_remk
    INTO CORRESPONDING FIELDS OF TABLE t_remadv
    FROM vinv_monitoring AS a
         INNER JOIN tinv_inv_line_a AS b
         ON b~int_inv_doc_no = a~int_inv_doc_no
         LEFT OUTER JOIN /idexge/rej_noti AS c
         ON  c~int_inv_doc_no  = b~int_inv_doc_no
         AND c~int_inv_line_no = b~int_inv_line_no
    WHERE a~int_sender IN s_send
      AND a~int_receiver IN s_rece
      AND a~invoice_type EQ lv_invtype
      AND a~date_of_receipt IN s_dtrec
      AND a~invoice_status IN s_insta
      AND a~int_inv_doc_no IN s_intido
      AND a~ext_invoice_no IN s_extido
      AND a~doc_type IN s_doctyp
      AND a~inv_doc_status IN s_idosta
      AND a~date_of_payment IN s_dtpaym
      AND a~invoice_date IN s_invoda
      AND b~line_type EQ co_linetype
      AND b~rstgr IN s_rstgr
      AND b~own_invoice_no IN s_owninv.

  SORT t_remadv.



*  Crossreference und Externer Zählpunkt
  IF t_remadv[] IS NOT INITIAL.

    SELECT a~int_crossrefno
           a~int_ui
           a~crossrefno
           a~crn_rev
           b~ext_ui
           b~dateto
      INTO CORRESPONDING FIELDS OF TABLE t_crsrf_eui
      FROM ecrossrefno AS a
           LEFT OUTER JOIN euitrans AS b
           ON b~int_ui = a~int_ui
      FOR ALL ENTRIES IN t_remadv
      WHERE ( a~crossrefno = t_remadv-own_invoice_no
      OR      a~crn_rev    = t_remadv-own_invoice_no ).
    "  WHERE ( a~crossrefno = wa_out-own_invoice_no
    " OR      a~crn_rev    = wa_out-own_invoice_no ).

    SORT t_crsrf_eui BY int_crossrefno.

    DELETE t_crsrf_eui
           WHERE dateto NE '99991231'.

    DELETE ADJACENT DUPLICATES FROM t_crsrf_eui.

* Für den nächsten Zugriff auf Zahlungsavise besser nach crossrefno sortieren
* UH 19082016
*    SORT t_crsrf_eui BY int_crossrefno.
    SORT t_crsrf_eui BY crossrefno.

  ENDIF.

* Zahlungsavise
  IF t_crsrf_eui[] IS NOT INITIAL.

    SELECT a~own_invoice_no
           a~int_inv_doc_no
           c~invoice_status
      INTO CORRESPONDING FIELDS OF TABLE t_paym
      FROM tinv_inv_line_a AS a
           INNER JOIN tinv_inv_doc AS b
           ON b~int_inv_doc_no = a~int_inv_doc_no
           INNER JOIN tinv_inv_head AS c
           ON c~int_inv_no = b~int_inv_no
      FOR ALL ENTRIES IN t_crsrf_eui
      WHERE a~own_invoice_no = t_crsrf_eui-crossrefno
      AND   a~line_type      = co_linetype
      AND   b~doc_type       = co_docpaym
      AND   c~invoice_type   = co_invpaym.

* Zahlungavise zu stornierten Rechnungen gesondert betrachten
* UH 19082016
  ENDIF.


* Ist das Feld crn_rev nie gefüllt kommt es zum Laufzeitfehler
* da die komplette DB durchsucht wird
* daher vorher alle leeren crn_rev eliminieren
* UH 19082016
  t_crsrf_eu2[] = t_crsrf_eui[].

  SORT t_crsrf_eu2 BY crn_rev.
  DELETE t_crsrf_eu2 WHERE crn_rev = space.
  DELETE ADJACENT DUPLICATES FROM t_crsrf_eu2.

  IF t_crsrf_eu2[] IS NOT INITIAL.

    SELECT a~own_invoice_no
           a~int_inv_doc_no
           c~invoice_status
      APPENDING CORRESPONDING FIELDS OF TABLE t_paym
      FROM tinv_inv_line_a AS a
           INNER JOIN tinv_inv_doc AS b
           ON b~int_inv_doc_no = a~int_inv_doc_no
           INNER JOIN tinv_inv_head AS c
           ON c~int_inv_no = b~int_inv_no
      FOR ALL ENTRIES IN t_crsrf_eu2
      WHERE a~own_invoice_no = t_crsrf_eu2-crn_rev
      AND   a~line_type      = co_linetype
      AND   b~doc_type       = co_docpaym
      AND   c~invoice_type   = co_invpaym.

  ENDIF.

  SORT t_paym BY own_invoice_no.

*PERFORM DFKKTHI_DFKKOP.
*  DFKKTHI und DFKKOP

  IF t_crsrf_eui[] IS NOT INITIAL.

    SELECT a~crsrf
           a~opbel
           a~opupw
           a~opupk
           a~opupz
           a~thinr
           a~thidt
           a~thist
           a~thprd
           a~storn
           a~stidc
           a~betrw
           a~gpart
           a~vkont
           a~vtref
           a~bcbln
           a~senid
           a~recid
           b~xblnr
      INTO CORRESPONDING FIELDS OF TABLE t_dfkkthi_op
      FROM dfkkthi AS a
           LEFT OUTER JOIN dfkkop AS b
           ON b~opbel = a~opbel AND
              b~opupw = a~opupw AND
              b~opupk = a~opupk AND
              b~opupz = a~opupz
      FOR ALL ENTRIES IN t_crsrf_eui
       WHERE a~crsrf = t_crsrf_eui-int_crossrefno
             AND  stidc = ' ' AND burel = 'X'.

    SORT t_dfkkthi_op BY crsrf stidc.

  ENDIF.

*  BCONT
  IF t_dfkkthi_op[] IS NOT INITIAL.
    PERFORM sel_bcontact_old." USING wa_.
  ENDIF.

*  t_crsrf_eu2[] = t_crsrf_eui[].
  SORT t_crsrf_eui BY crossrefno.
  SORT t_crsrf_eu2 BY crn_rev.

  LOOP AT t_remadv ASSIGNING <fs_remadv>.

    AT NEW int_inv_doc_no.
      x_ctrem = x_ctrem + 1.
    ENDAT.

    CLEAR wa_out.
    MOVE-CORRESPONDING <fs_remadv> TO wa_out.
** Zeilenstatus
*    IF <fs_remadv>-stat_remk(3) = '@0V'.
*      wa_out-line_state = icon_okay.
*    ENDIF.
** Aggr. Vertragskonto ermitteln
    SELECT SINGLE a~vkont INTO wa_out-aggvk
      FROM fkkvk AS a
       INNER JOIN fkkvkp AS b
         ON b~vkont = a~vkont
      INNER JOIN eservprovp AS c
        ON c~bpart = b~gpart
        WHERE c~serviceid = <fs_remadv>-int_sender
        AND a~vktyp IN r_vktyp.


** Text zum Rückstellungsgrund
    READ TABLE t_inv_c_adj_rsnt
         INTO  wa_inv_c_adj_rsnt
         WITH KEY rstgr = <fs_remadv>-rstgr
                  spras = sy-langu.
    IF sy-subrc = 0.
      wa_out-text = wa_inv_c_adj_rsnt-text.
    ENDIF.

* Crosreferenz / Zählpunkt
    READ TABLE t_crsrf_eui
         ASSIGNING <fs_crsrf_eui>
         WITH KEY crossrefno = <fs_remadv>-own_invoice_no
         BINARY SEARCH.

    IF sy-subrc = 0 AND <fs_crsrf_eui> IS ASSIGNED.
      b_storno = abap_false.
      wa_out-ext_ui         = <fs_crsrf_eui>-ext_ui.
      wa_out-int_crossrefno = <fs_crsrf_eui>-int_crossrefno.
    ELSE.
      READ TABLE t_crsrf_eu2
           ASSIGNING <fs_crsrf_eui>
           WITH KEY crn_rev = <fs_remadv>-own_invoice_no
           BINARY SEARCH.
      IF sy-subrc = 0 AND <fs_crsrf_eui> IS ASSIGNED.
        wa_out-inf_invoice_cancel = icon_status_reverse.
        wa_out-ext_ui         = <fs_crsrf_eui>-ext_ui.
        wa_out-int_crossrefno = <fs_crsrf_eui>-int_crossrefno.
        b_storno = abap_true.
      ENDIF.
    ENDIF.

*    CHECK wa_out-ext_ui IN s_extui.                    "Nuss 10.2017 Melo/Malo
    CHECK wa_out-int_crossrefno IS NOT INITIAL.

* Abrechnungsklasse ermitteln
    SELECT aklasse INTO wa_out-aklasse
      FROM eanlh AS a
        INNER JOIN euiinstln AS b
        ON b~anlage = a~anlage
        INNER JOIN euitrans AS c
         ON c~int_ui = b~int_ui
      WHERE c~ext_ui = wa_out-ext_ui
        AND c~dateto = '99991231'
        AND a~bis = '99991231'.
      EXIT.
    ENDSELECT.


*   DFKKTHI lesen
    READ TABLE t_dfkkthi_op
         ASSIGNING <fs_dfkkthi_op>
         WITH KEY crsrf = wa_out-int_crossrefno
                  stidc = b_storno
         BINARY SEARCH.

    IF sy-subrc = 0 AND <fs_dfkkthi_op> IS ASSIGNED.

      MOVE-CORRESPONDING <fs_dfkkthi_op> TO wa_out.

      IF p_storno = 'X'.
        CHECK wa_out-storn NE 'X'.
        CHECK wa_out-stidc NE 'X'.
      ENDIF.

    ENDIF.
    SELECT * FROM /idexge/rej_noti INTO wa_noti
  WHERE int_inv_doc_no = wa_out-int_inv_doc_no.
      IF wa_noti-stat_remk(3) = '@0V'.
        wa_out-line_state = icon_okay.
      ENDIF.
      EXIT.
    ENDSELECT.
*   Zahlungsavis vorhanden?
    READ TABLE t_paym
         ASSIGNING <fs_paym>
         WITH KEY own_invoice_no = <fs_remadv>-own_invoice_no
         BINARY SEARCH.

    IF sy-subrc = 0 AND <fs_paym> IS ASSIGNED.
      wa_out-paym_avis = <fs_paym>-int_inv_doc_no.
      wa_out-paym_stat = <fs_paym>-invoice_status.
    ENDIF.

    READ TABLE t_bcontact
         WITH KEY int_inv_doc_no = <fs_remadv>-int_inv_doc_no
         TRANSPORTING NO FIELDS
         BINARY SEARCH.

    IF sy-subrc = 0.
      wa_out-comm_state = icon_envelope_closed.
    ENDIF.
    SELECT COUNT(*) FROM /adesso/remtext WHERE int_inv_doc_nr = wa_out-int_inv_doc_no.
    IF sy-subrc = 0.
      wa_out-text_vorhanden = 'X'.
    ELSE.
      wa_out-text_vorhanden = ''.
    ENDIF.
    PERFORM sel_invstorno USING wa_out.

    CONCATENATE wa_out-int_inv_doc_no
                '_'
                wa_out-int_inv_line_no
                INTO gv_name.

    CLEAR xlines.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
*       CLIENT                  = SY-MANDT
        id                      = co_id
        language                = sy-langu
        name                    = gv_name
        object                  = co_object
*       ARCHIVE_HANDLE          = 0
*       LOCAL_CAT               = ' '
*   IMPORTING
*       HEADER                  =
*       OLD_LINE_COUNTER        =
      TABLES
        lines                   = xlines
      EXCEPTIONS
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    READ TABLE xlines INTO help_line INDEX 1.

    IF sy-subrc = 0.
      wa_out-free_text5 = help_line.
      "  MODIFY it_out FROM wa_out ."INDEX fp_tabindex.
    ENDIF.
    PERFORM sel_invstorno USING wa_out.
*      ENDLOOP.
*    ENDIF.
    "     PERFORM sel_bcontact USING wa_out.

    PERFORM get_locks.
    APPEND wa_out TO it_out.
    CLEAR wa_out.

  ENDLOOP.

ENDFORM.                    " DATEN_SELEKTIEREN

*&---------------------------------------------------------------------*
*&      Form  LAYOUT_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LS_LAYOUT  text
*----------------------------------------------------------------------*
FORM layout_build  USING  ls_layout TYPE slis_layout_alv.

  ls_layout-zebra = 'X'.
  ls_layout-colwidth_optimize = 'X'.
  ls_layout-box_fieldname = 'XSELP'.
*  ls_layout-box_fieldname = 'SEL'.

ENDFORM.                    " LAYOUT_BUILD


*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LT_FIELDCAT  text
*----------------------------------------------------------------------*
FORM fieldcat_build  USING  lt_fieldcat TYPE slis_t_fieldcat_alv.

  DATA: ls_fieldcat TYPE slis_fieldcat_alv.
  DATA lv_tabname TYPE string.

  IF p_invtp = 1.
    lv_tabname = 'IT_OUT'.
  ELSEIF p_invtp = 2.
    lv_tabname = 'IT_OUT_MEMI'.
*   > Nuss 28.03.2017
  ELSEIF p_invtp = 3.
    lv_tabname = 'IT_OUT_MGV'.
* <   Nuss 28.03.2017
*  --> Nuss 09.2018
  ELSEIF p_invtp = 4.
    lv_tabname = 'IT_OUT_MSB'.
* <-- Nuss 09.2018
  ENDIF.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'XSELP'.
  ls_fieldcat-tech      = 'X'.
  ls_fieldcat-tabname = lv_tabname.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'SEL'.
  ls_fieldcat-tabname = lv_tabname.
  ls_fieldcat-edit = 'X'.
  ls_fieldcat-input = 'X'.
  ls_fieldcat-checkbox = 'X'.
  ls_fieldcat-key = 'X'.
  ls_fieldcat-seltext_s = 'Selektion'.
  ls_fieldcat-seltext_m = 'Selektion'.
  ls_fieldcat-seltext_l = 'Selektion'.
  APPEND ls_fieldcat TO lt_fieldcat.


*Interne Nummer des Rechnungsbelegs/Avisbelegs
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'INT_INV_DOC_NO'.
  ls_fieldcat-tabname = lv_tabname.
  ls_fieldcat-key = 'X'.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-ref_tabname = 'TINV_INV_DOC'.
  APPEND ls_fieldcat TO lt_fieldcat.

  SELECT COUNT(*) FROM /adesso/fi_remad WHERE negrem_option = 'FIELDCAT' AND negrem_field = 'BEMERKUNG' AND negrem_value = 'X'.
  IF sy-subrc = 0.
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'TEXT_VORHANDEN'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-seltext_m = 'Bemerkung'.
    ls_fieldcat-hotspot = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.
  ENDIF.

*zeilennummer /Avisbelegs
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'INT_INV_LINE_NO'.
  ls_fieldcat-tabname = lv_tabname.
  ls_fieldcat-no_out   = 'X'.
  ls_fieldcat-ref_tabname = 'TINV_INV_LINE_A'.
  APPEND ls_fieldcat TO lt_fieldcat.

*Interne Bezeichnung des Rechnung-/Avisempfängers
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'INT_RECEIVER'.
  ls_fieldcat-tabname = lv_tabname.
  ls_fieldcat-key = 'X'.
  ls_fieldcat-seltext_s = 'Empfänger'.
  ls_fieldcat-seltext_m = 'Empfänger'.
  ls_fieldcat-seltext_l = 'Empfänger'.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-ref_tabname = 'TINV_INV_HEAD'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Interne Bezeichnung des Rechnungs-/Avissenders
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'INT_SENDER'.
  ls_fieldcat-tabname = lv_tabname.
  ls_fieldcat-key = 'X'.
  ls_fieldcat-seltext_s = 'Sender'.
  ls_fieldcat-seltext_m = 'Sender'.
  ls_fieldcat-seltext_l = 'Sender'.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-ref_tabname = 'TINV_INV_HEAD'.
  APPEND ls_fieldcat TO lt_fieldcat.
  SELECT COUNT( * ) FROM /adesso/fi_remad WHERE negrem_option = 'LINE_STATE' AND negrem_field = 'SHOW' AND negrem_value = 'X'.
  IF sy-subrc = 0.
* Status-Icon für Mahnsperre
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname   = 'LINE_STATE'.
    ls_fieldcat-tabname     = lv_tabname.
    ls_fieldcat-icon        = 'X'.
    ls_fieldcat-seltext_s   = 'Z.Stat'.
    ls_fieldcat-seltext_m   = 'Zeil.Stat'.
    ls_fieldcat-seltext_l   = 'Zeilen Status'.
    APPEND ls_fieldcat TO lt_fieldcat.
  ENDIF.
  SELECT COUNT(*) FROM /adesso/fi_remad WHERE negrem_option = 'INTSTAT' AND negrem_field = 'SHOW' AND negrem_value = 'X'.
  IF sy-subrc = 0.
* interner Status
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname   = 'FREE_TEXT4'.
    ls_fieldcat-tabname     = lv_tabname.
    ls_fieldcat-hotspot     = 'X'.
    ls_fieldcat-seltext_s   = 'I.Stat'.
    ls_fieldcat-seltext_m   = 'Int.Stat.'.
    ls_fieldcat-seltext_l   = 'Interner Status'.
    ls_fieldcat-outputlen   = 10.
    APPEND ls_fieldcat TO lt_fieldcat.
  ENDIF.

* Aggr. Vertragskonto des Senders
  IF p_invtp NE 4.                                  "Nuss 09.2018
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'AGGVK'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-key = 'X'.
    ls_fieldcat-seltext_s = 'Aggr.Vk NNE'.
    ls_fieldcat-seltext_m = 'Aggr.Vkonto NNE'.
    ls_fieldcat-seltext_l = 'Aggr.Vkonto NNE'.
    ls_fieldcat-hotspot = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.
  ENDIF.                                          "Nuss 09.2018


  IF p_invtp = 2.                                 "Nuss 09.2018
* Aggr. Vertragskonto des Senders
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'SUPPL_CONTR_ACCT'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    ls_fieldcat-key = 'X'.
    ls_fieldcat-seltext_s = 'Aggr.Vk MEMI'.
    ls_fieldcat-seltext_m = 'Aggr.Vkonto MEMI'.
    ls_fieldcat-seltext_l = 'Aggr.Vkonto MEMI'.
    ls_fieldcat-hotspot = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.
  ENDIF.

* --> Nuss 09.2018
  IF p_invtp = 4.
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'VKONT_MSB'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-key = 'X'.
    ls_fieldcat-seltext_s = 'Vk MSB'.
    ls_fieldcat-seltext_m = 'Vkonto MSB'.
    ls_fieldcat-seltext_l = 'Vkonto MSB'.
    ls_fieldcat-hotspot = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.
  ENDIF.
* <-- Nuss 09.2018


* Status der Rechnung/des Avises
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'INVOICE_STATUS'.
  ls_fieldcat-tabname = lv_tabname.
  ls_fieldcat-key = 'X'.
  ls_fieldcat-ref_tabname = 'TINV_INV_HEAD'.
  APPEND ls_fieldcat TO lt_fieldcat.

*  Eingangsdatum des Dokumentes
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DATE_OF_RECEIPT'.
  ls_fieldcat-tabname = lv_tabname.
  ls_fieldcat-key = 'X'.
  ls_fieldcat-ref_tabname = 'TINV_INV_HEAD'.
  APPEND ls_fieldcat TO lt_fieldcat.


* Status-Icon für Prozessstatus
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname   = 'PROCESS_STATE'.
  ls_fieldcat-tabname = lv_tabname.
  ls_fieldcat-icon        = 'X'.
  ls_fieldcat-seltext_s   = 'Pr.Status'.
  ls_fieldcat-seltext_m   = 'Pr.Status'.
  ls_fieldcat-seltext_l   = 'Prozessstatus'.
  APPEND ls_fieldcat TO lt_fieldcat.

  DATA lv_state TYPE c.
  CLEAR lv_state.
  SELECT COUNT(*) FROM /adesso/fi_remad WHERE negrem_option = 'CANCELSTATE' AND negrem_field = 'SHOW' AND negrem_value = 'X'.
  IF sy-subrc = 0.
    lv_state = 'X'.
  ENDIF.
* Status-Icon für Storner_coostatus
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname   = 'CANCEL_STATE'.
  ls_fieldcat-tabname = lv_tabname.
  ls_fieldcat-icon        = 'X'.
* --> Nuss 09.2018-2
  IF p_invtp = 4.
    ls_fieldcat-seltext_s = 'StStAbbel'.
    ls_fieldcat-seltext_m = 'StStatAbrbel'.
    ls_fieldcat-seltext_l = 'Storno-Status CI-Abrbel'.
  ELSEIF p_invtp = 1 OR lv_state = ' '.
*  IF p_invtp = 1 OR lv_state = ' '.
* <-- Nuss 09.2018-2
    ls_fieldcat-seltext_s   = 'St.Status'.
    ls_fieldcat-seltext_m   = 'St.Status'.
    ls_fieldcat-seltext_l   = 'Storno-Status'.
  ELSE.
    ls_fieldcat-seltext_s   = 'St.Stat. NNE'.
    ls_fieldcat-seltext_m   = 'St.Status NNE'.
    ls_fieldcat-seltext_l   = 'Storno-Status NNE'.
  ENDIF.
  APPEND ls_fieldcat TO lt_fieldcat.

*  IF ( p_invtp = 2 OR p_invtp = 4 ) AND lv_state = 'X'.           "Nuss 09.2018-2
  IF p_invtp = 2  AND lv_state = 'X'.           "Nuss 09.2018-2
* status-icon für stornostatus
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname   = 'CANCEL_STATE_MM'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-icon        = 'X'.
    ls_fieldcat-seltext_s   = 'St.StatMMMA'.
    ls_fieldcat-seltext_m   = 'St.Status MMMA'.
    ls_fieldcat-seltext_l   = 'Storno-Status MMMA'.
    APPEND ls_fieldcat TO lt_fieldcat.
  ENDIF.

* --> Nuss 09.2018-2
  IF p_invtp = 4.
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'CANCEL_STATE_AP'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-icon        = 'X'.
    ls_fieldcat-seltext_s = 'St.StatAP'.
    ls_fieldcat-seltext_m = 'St.Status AP'.
    ls_fieldcat-seltext_l = 'Storno-Status Abr.Plan'.
    APPEND ls_fieldcat TO lt_fieldcat.
  ENDIF.
* <-- Nuss 09.2018-2



* Status-Icon für Mailversand
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname   = 'COMM_STATE'.
  ls_fieldcat-tabname = lv_tabname.
  ls_fieldcat-icon        = 'X'.
  ls_fieldcat-seltext_s   = 'Kom.Status'.
  ls_fieldcat-seltext_m   = 'Kom.Status'.
  ls_fieldcat-seltext_l   = 'Kommunikationsstatus'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Status-Icon Storno-Crossrefno
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname   = 'INF_INVOICE_CANCEL'.
  ls_fieldcat-tabname = lv_tabname.
  ls_fieldcat-icon        = 'X'.
  ls_fieldcat-seltext_s   = 'St.int.Bel.'.
  ls_fieldcat-seltext_m   = 'St.int.Bel.'.
  ls_fieldcat-seltext_l   = 'Storno int. Beleg'.
  APPEND ls_fieldcat TO lt_fieldcat.

  SELECT COUNT(*) FROM /adesso/fi_remad WHERE negrem_option = 'FIELDCAT' AND negrem_field = 'NOTIZ' AND negrem_value = 'X'.
  IF sy-subrc = 0.
* Langtext
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname   = 'FREE_TEXT5'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-hotspot     = 'X'.
    ls_fieldcat-seltext_s   = 'Notiz'.
    ls_fieldcat-seltext_m   = 'Notiz'.
    ls_fieldcat-seltext_l   = 'Notiz'.
    ls_fieldcat-outputlen   = 10.
    APPEND ls_fieldcat TO lt_fieldcat.
  ENDIF.
* Zahlungsavis
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname   = 'PAYM_AVIS'.
  ls_fieldcat-tabname = lv_tabname.
  ls_fieldcat-emphasize   = 'C30'.
  ls_fieldcat-hotspot     = 'X'.
  ls_fieldcat-seltext_s   = 'RAvis.'.
  ls_fieldcat-seltext_m   = 'Rekl.A'.
  ls_fieldcat-seltext_l   = 'Reklamationsavis'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Status-Icon Storno-status
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname   = 'PAYM_STAT'.
  ls_fieldcat-tabname = lv_tabname.
  ls_fieldcat-emphasize   = 'C30'.
  ls_fieldcat-seltext_s   = 'RAStat.'.
  ls_fieldcat-seltext_m   = 'RAStat.'.
  ls_fieldcat-seltext_l   = 'Reklamationsavis Status'.
  ls_fieldcat-ref_tabname = 'TINV_INV_HEAD'.
  ls_fieldcat-ref_fieldname = 'INVOICE_STATUS'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Externe Rechnungsnummer/Avisnummer
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'EXT_INVOICE_NO'.
  ls_fieldcat-tabname = lv_tabname.
  ls_fieldcat-emphasize = 'C30'.
  ls_fieldcat-ref_tabname = 'TINV_INV_DOC'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Interne Belegnummer
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'OWN_INVOICE_NO'.
  ls_fieldcat-tabname = lv_tabname.
  ls_fieldcat-emphasize = 'C30'.
  ls_fieldcat-ref_tabname = 'TINV_INV_LINE_A'.
  IF p_invtp = '1'.
    ls_fieldcat-hotspot = 'X'.
  ENDIF.
  APPEND ls_fieldcat TO lt_fieldcat.

* Art des Belegs
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DOC_TYPE'.
  ls_fieldcat-tabname = lv_tabname.
  ls_fieldcat-emphasize = 'C30'.
  ls_fieldcat-ref_tabname = 'TINV_INV_DOC'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Status des Belegs
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'INV_DOC_STATUS'.
  ls_fieldcat-tabname = lv_tabname.
  ls_fieldcat-emphasize = 'C30'.
  ls_fieldcat-ref_tabname = 'TINV_INV_DOC'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Fälligkeitsdatum
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DATE_OF_PAYMENT'.
  ls_fieldcat-tabname = lv_tabname.
  ls_fieldcat-emphasize = 'C30'.
  ls_fieldcat-ref_tabname = 'TINV_INV_DOC'.
  ls_fieldcat-no_out      = 'X'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Datum der Rechnung oder des Avises
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'INVOICE_DATE'.
  ls_fieldcat-tabname = lv_tabname.
  ls_fieldcat-emphasize = 'C30'.
  ls_fieldcat-ref_tabname = 'TINV_INV_DOC'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Differenzgrund bei Zahlungen
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'RSTGR'.
  ls_fieldcat-tabname = lv_tabname.
  ls_fieldcat-emphasize = 'C30'.
  ls_fieldcat-ref_tabname = 'TINV_INV_LINE_A'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Text
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TEXT'.
  ls_fieldcat-tabname = lv_tabname.
  ls_fieldcat-emphasize = 'C30'.
  ls_fieldcat-ref_tabname = 'TINV_C_ADJ_RSNT'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Langtext
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'FREE_TEXT1'.
  ls_fieldcat-tabname = lv_tabname.
  ls_fieldcat-emphasize = 'C30'.
  ls_fieldcat-ref_tabname = '/IDEXGE/REJ_NOTI'.
  ls_fieldcat-hotspot = 'X'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Externe Identifizierung eines Belegs (z.B. Zählpunkt)
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'EXT_UI'.
  ls_fieldcat-tabname = lv_tabname.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-emphasize = 'C30'.
  ls_fieldcat-seltext_s = 'Malo-ID'.           "Nuss 10.2017
  ls_fieldcat-seltext_m = 'Malo-ID / ZP-Bez'.  "Nuss 10.2017
  ls_fieldcat-seltext_l = 'Malo-ID / Zählpunktbez'. "Nuss 10.2017
*  ls_fieldcat-ref_tabname = 'EUITRANS'.           "Nuss 10.2017
  APPEND ls_fieldcat TO lt_fieldcat.

* Abrechnungsklasse der Anlage
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'AKLASSE'.
  ls_fieldcat-tabname = lv_tabname.
  ls_fieldcat-emphasize = 'C30'.
  ls_fieldcat-ref_tabname = 'EANLH'.
  APPEND ls_fieldcat TO lt_fieldcat.

*** --> Nuss 10.2017 Melo/Malo
*** Externer Zählpunkt MeLo-Anlage
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'EXT_UI_MELO'.
  ls_fieldcat-tabname = lv_tabname.
  ls_fieldcat-emphasize = 'C30'.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-seltext_s = 'ZP Melo'.
  ls_fieldcat-seltext_m = 'ZP Melo-Anlage'.
  ls_fieldcat-seltext_l = 'Zählpunkt Melo-Anlage'.
  APPEND ls_fieldcat TO lt_fieldcat.

** Multiple Melos
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'MULT_MELO'.
  ls_fieldcat-tabname = lv_tabname.
  ls_fieldcat-emphasize = 'C30'.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-seltext_s = 'Mult Melo'.
  APPEND ls_fieldcat TO lt_fieldcat.
** <-- Nuss 10.2017 Melo/Malo




* Interne Crossreferenz
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'INT_CROSSREFNO'.
  ls_fieldcat-tabname = lv_tabname.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-emphasize = 'C30'.
  ls_fieldcat-ref_tabname = 'ECROSSREFNO'.
  ls_fieldcat-no_out      = 'X'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Bruttobetrag (angefordert) in Transaktionswährung
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BETRW_REQ'.
  ls_fieldcat-tabname = lv_tabname.
  ls_fieldcat-no_zero = 'X'.
  ls_fieldcat-do_sum = 'X'.
  ls_fieldcat-emphasize = 'C30'.
  ls_fieldcat-ref_tabname = 'TINV_INV_LINE_A'.
  ls_fieldcat-no_out      = 'X'.
  APPEND ls_fieldcat TO lt_fieldcat.

  IF p_invtp = 1.
    SELECT COUNT(*) FROM /adesso/fi_remad WHERE negrem_option = 'FIELDCAT' AND negrem_field = 'ZISUMABR' AND negrem_value = 'X'.
    IF sy-subrc = 0.
* Kennz. Beleg aus manueller Abrechnung
      CLEAR ls_fieldcat.
      ls_fieldcat-fieldname = 'ZISUMABR'.
      ls_fieldcat-tabname = 'IT_OUT'.
      ls_fieldcat-hotspot = 'X'.
      ls_fieldcat-emphasize = 'C50'.
      ls_fieldcat-seltext_s   = 'Man.Abr.'.
      ls_fieldcat-seltext_m   = 'Kennz. manuelle Abr.'.
      ls_fieldcat-seltext_l   = 'Beleg aus manueller Abrechnung'.
      APPEND ls_fieldcat TO lt_fieldcat.
    ENDIF.


* Nummer eines Belegs des Vertragskontokorrents
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'OPBEL'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-hotspot = 'X'.
    ls_fieldcat-emphasize = 'C50'.
    ls_fieldcat-ref_tabname = 'DFKKTHI'.
    APPEND ls_fieldcat TO lt_fieldcat.

* Wiederholungsposition im Beleg des Vertragskontokorrents
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'OPUPW'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-emphasize = 'C50'.
    ls_fieldcat-ref_tabname = 'DFKKTHI'.
    ls_fieldcat-no_out      = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.

* Positionsnummer im Beleg des Vertragskontokorrents
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'OPUPK'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-emphasize = 'C50'.
    ls_fieldcat-ref_tabname = 'DFKKTHI'.
    APPEND ls_fieldcat TO lt_fieldcat.

* Teilposition zu einem Teilausgleich im Beleg
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'OPUPZ'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-emphasize = 'C50'.
    ls_fieldcat-ref_tabname = 'DFKKTHI'.
    ls_fieldcat-no_out      = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.

* Laufende Nummer des DFKKTHI Eintrags zu einer Belegposition
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'THINR'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-emphasize = 'C50'.
    ls_fieldcat-ref_tabname = 'DFKKTHI'.
    ls_fieldcat-no_out      = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.

* Fälligkeitsdatum für den Dritten
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'THIDT'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-emphasize = 'C50'.
    ls_fieldcat-ref_tabname = 'DFKKTHI'.
    APPEND ls_fieldcat TO lt_fieldcat.

* Status des Eintrags
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'THIST'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-emphasize = 'C50'.
    ls_fieldcat-ref_tabname = 'DFKKTHI'.
    ls_fieldcat-no_out      = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.

* Beleg wurde storniert
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'STORN'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-emphasize = 'C50'.
    ls_fieldcat-ref_tabname = 'DFKKTHI'.
    APPEND ls_fieldcat TO lt_fieldcat.

* Herkunft des Eintrags ist Storno
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'STIDC'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-emphasize = 'C50'.
    ls_fieldcat-ref_tabname = 'DFKKTHI'.
    APPEND ls_fieldcat TO lt_fieldcat.

* Bruttobetrag in Transaktionswährung
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'BETRW'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-no_zero = 'X'.
    ls_fieldcat-do_sum = 'X'.
    ls_fieldcat-emphasize = 'C50'.
    ls_fieldcat-ref_tabname = 'DFKKTHI'.
    APPEND ls_fieldcat TO lt_fieldcat.

* Geschäftspartnernummer
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'GPART'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-hotspot = 'X'.
    ls_fieldcat-emphasize = 'C50'.
    ls_fieldcat-ref_tabname = 'DFKKTHI'.
    ls_fieldcat-no_out      = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.

* Vertragskontonummer
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'VKONT'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-hotspot = 'X'.
    ls_fieldcat-emphasize = 'C50'.
    ls_fieldcat-ref_tabname = 'DFKKTHI'.
    APPEND ls_fieldcat TO lt_fieldcat.

* Referenzangaben aus dem Vertrag
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'VTREF'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-hotspot = 'X'.
    ls_fieldcat-emphasize = 'C50'.
    ls_fieldcat-ref_tabname = 'DFKKTHI'.
    APPEND ls_fieldcat TO lt_fieldcat.

* Belegnummer der Buchung auf das Serviceanbieter-Konto
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'BCBLN'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-hotspot = 'X'.
    ls_fieldcat-emphasize = 'C50'.
    ls_fieldcat-ref_tabname = 'DFKKTHI'.
    APPEND ls_fieldcat TO lt_fieldcat.


* Referenzbelegnummer
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'XBLNR'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-hotspot = 'X'.
    ls_fieldcat-emphasize = 'C50'.
    ls_fieldcat-ref_tabname = 'DFKKOP'.
    APPEND ls_fieldcat TO lt_fieldcat.

  ELSEIF p_invtp = 2.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'DOC_ID'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-hotspot = 'X'.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'DOC_STATUS'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'CROSSREFNO'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.

*   --> Nuss 12.02.2018
*   Zusätzliche FElder für Mahnsperren Memi
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'MAHNSP'.
    ls_fieldcat-seltext_s = 'MSp'.
    ls_fieldcat-seltext_m = 'Mahnsperre'.
    ls_fieldcat-tabname = lv_tabname.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'FDATE'.
    ls_fieldcat-seltext_s = 'ab'.
    ls_fieldcat-seltext_m = 'gültig ab'.
    ls_fieldcat-tabname = lv_tabname.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'TDATE'.
    ls_fieldcat-seltext_s = 'ab'.
    ls_fieldcat-seltext_m = 'gültig bis'.
    ls_fieldcat-tabname = lv_tabname.
    APPEND ls_fieldcat TO lt_fieldcat.
*   <-- Nuss 12.02.2018


    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'DIVISION'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'DIST_SP'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'SUPPL_SP'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'SUPPL_BUPA'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'QUANTITY_TYPE'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'QUANTITY'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'APPLICATION_MONTH'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'APPLICATION_YEAR'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'START_DATE'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'END_DATE'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'PRICE'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'NET_AMOUNT'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.


    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'ENERGY_TAX_AMOUNT'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'GROSS_AMOUNT'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'TAX_CODE'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'TAX_RATE'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'TRIG_BILL_DOC_NO'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-seltext_s   = 'AbrBelnrNNE'.
    ls_fieldcat-seltext_m   = 'AbrBelnrNNE.'.
    ls_fieldcat-seltext_l   = 'Abrechnungsbeleg Netznutzung'.
    ls_fieldcat-hotspot = 'X'.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'ERCHCOPBEL'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-seltext_s   = 'DruckbelNNE'.
    ls_fieldcat-seltext_m   = 'DruckbelNNE.'.
    ls_fieldcat-seltext_l   = 'Druckbeleg Netznutzung'.
    ls_fieldcat-hotspot = 'X'.
*    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'TRIG_BILL_TRANSACT'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'TRIG_BILL_ORIG_START_DATE'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'TRIG_BILL_ORIG_END_DATE'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'TRIG_BILL_START_DATE'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'TRIG_BILL_END_DATE'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'TRIG_BILL_QUANTITY'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'TRIG_BILL_MEASURE_UNIT'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'TRIG_BILL_TRANS_PREVIOUS'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'TRIG_BILL_SPLIT'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.


    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'SETTLE_QUERY_END_DATE'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.


    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'SETTLE_QUERY_START_DATE'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'SETTLE_QUERY_END_DATE'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'SETTLE_START_DATE'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'SETTLE_END_DATE'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'SETTLE_QUANTITY'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'SETTLE_MEASURE_UNIT'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.


    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'COMPANY_CODE'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'DOC_DATE'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'POST_DATE'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'DUE_DATE'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'INV_SEND_DATE'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'CI_INVOIC_DOC_NO'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    ls_fieldcat-hotspot = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'CI_FICA_DOC_NO'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    ls_fieldcat-hotspot = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'OPUPK'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    ls_fieldcat-hotspot = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'MSCONS_IDOC'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    ls_fieldcat-hotspot = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'INVOIC_IDOC'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    ls_fieldcat-hotspot = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'REMADV_IDOC'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    ls_fieldcat-hotspot = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.


    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'BILLABLE_ITEM'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-seltext_s   = 'Abrechenb.Pos'.
    ls_fieldcat-seltext_m   = 'Abrechenb.Pos'.
    ls_fieldcat-seltext_l   = 'Abrechenb.Pos'.
    ls_fieldcat-hotspot = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.

*    CLEAR ls_fieldcat.
*    ls_fieldcat-fieldname = 'INV_DOC_NO'.
*    ls_fieldcat-tabname = lv_tabname.
*    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
*    ls_fieldcat-hotspot = 'X'.
*    APPEND ls_fieldcat TO lt_fieldcat.



  ELSEIF p_invtp = 3.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'PROC_REF'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXGC/PDOC_LOG'.
    ls_fieldcat-hotspot = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'OPBEL'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = 'DFKKOP'.
    ls_fieldcat-hotspot = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'INVDOCNO'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = 'DFKKINVDOC_H'.
    ls_fieldcat-hotspot = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'BILLDOCNO'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = 'DFKKINVBILL_H'.
    ls_fieldcat-hotspot = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'REFDOCNO'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = 'DFKKINVBILL_H'.
    "ls_fieldcat-hotspot = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'DOCTYPE'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = 'DFKKINVBILL_H'.
    "ls_fieldcat-hotspot = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'GPART'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = 'DFKKINVBILL_H'.
    ls_fieldcat-hotspot = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'VKONT'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = 'DFKKINVBILL_H'.
    ls_fieldcat-hotspot = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'GPART_INV '.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = 'DFKKINVBILL_H'.
    ls_fieldcat-hotspot = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'VKONT_INV'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = 'DFKKINVBILL_H'.
    ls_fieldcat-hotspot = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'DATE_FROM'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = 'DFKKINVBILL_H'.
    " ls_fieldcat-hotspot = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'DATE_TO'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = 'DFKKINVBILL_H'.
    " ls_fieldcat-hotspot = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'SIMULATED'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = 'DFKKINVBILL_H'.
    "  ls_fieldcat-hotspot = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'CRNAME'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = 'DFKKINVBILL_H'.
    " ls_fieldcat-hotspot = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'CRDATE'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = 'DFKKINVBILL_H'.
    " ls_fieldcat-hotspot = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'CRTIME'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = 'DFKKINVBILL_H'.
    " ls_fieldcat-hotspot = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'FAEDN'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = 'DFKKINVDOC_H'.
    " ls_fieldcat-hotspot = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.

** --> nuss 09.2018
  ELSEIF p_invtp = 4.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'INVDOCNO'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-hotspot = 'X'.
    ls_fieldcat-seltext_m = 'CI-Fakturabeleg'.
    ls_fieldcat-seltext_l = 'CI-Fakturierungsbeleg'.
    ls_fieldcat-ref_tabname = 'DFKKINVDOC_H'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'PRLINV_STATUS'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = 'DFKKINVDOC_H'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'CROSSREFNO'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'SPART'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = 'DFKKINVDOC_I'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = '/MOSB/MO_SP'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = 'DFKKINVDOC_H'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = '/MOSB/LEAD_SUP'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = 'DFKKINVDOC_H'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'GPART'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = 'DFKKINVDOC_H'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'BUDAT'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = 'DFKKINVDOC_H'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'BLDAT'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = 'DFKKINVDOC_H'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'FAEDN'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = 'DFKKINVDOC_H'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'OPBEL'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = 'DFKKINVDOC_H'.
    ls_fieldcat-seltext_m = 'FICA-Beleg'.
    ls_fieldcat-hotspot = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.


    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'SRCDOCNO'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-seltext_s   = 'CI-AbrBel'.
    ls_fieldcat-seltext_m   = 'CI-AbrBelnr.'.
    ls_fieldcat-seltext_l   = 'CI-Abrechnungsbeleg'.
    ls_fieldcat-hotspot = 'X'.
    ls_fieldcat-ref_tabname = 'DFKKINVDOC_I'.
    APPEND ls_fieldcat TO lt_fieldcat.

** --> Nuss 09.2018-2
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'BILLPLANNO'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-seltext_s   = 'Abr.Plan'.
    ls_fieldcat-seltext_m   = 'Abrech.Plan'.
    ls_fieldcat-seltext_l   = 'Abrechnungsplan'.
    ls_fieldcat-hotspot = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.
** <-- Nuss 09.2018-2

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'QUANTITY'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-seltext_s   = 'Abr.Menge'.
    ls_fieldcat-seltext_m   = 'Abrech.Menge'.
    ls_fieldcat-seltext_l   = 'Abrechnungsmenge'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'QTY_UNIT'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = 'DFKKINVBILL_I'.
    APPEND ls_fieldcat TO lt_fieldcat.


*    CLEAR ls_fieldcat.
*    ls_fieldcat-fieldname = 'ERCHCOPBEL'.
*    ls_fieldcat-tabname = lv_tabname.
*    ls_fieldcat-seltext_s   = 'DruckbelNNE'.
*    ls_fieldcat-seltext_m   = 'DruckbelNNE.'.
*    ls_fieldcat-seltext_l   = 'Druckbeleg Netznutzung'.
*    ls_fieldcat-hotspot = 'X'.
*    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'BETRW'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-no_zero = 'X'.
    ls_fieldcat-do_sum = 'X'.
    ls_fieldcat-ref_tabname = 'DFKKINVDOC_I'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'DATE_FROM'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = 'DFKKINVDOC_I'.
    " ls_fieldcat-hotspot = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'DATE_TO'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = 'DFKKINVDOC_I'.
    " ls_fieldcat-hotspot = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'BUKRS'.
    ls_fieldcat-tabname = lv_tabname.
    ls_fieldcat-ref_tabname = 'DFKKINVDOC_I'.
    APPEND ls_fieldcat TO lt_fieldcat.



** <-- Nuss 09.2018

  ENDIF.

  CLEAR ls_fieldcat.

ENDFORM.                    " FIELDCAT_BUILD


*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_alv .

  DATA ls_fi_negrem TYPE /adesso/fi_remad.
  DATA lt_extab TYPE slis_t_extab.
  SELECT * FROM /adesso/fi_remad INTO ls_fi_negrem WHERE negrem_option = 'EXCLUDE'.
    APPEND ls_fi_negrem-negrem_field TO lt_extab.
    "Felder an IT_EXCLUDING
  ENDSELECT.

  IF p_invtp = 1.
    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program       = g_repid
        i_callback_pf_status_set = g_status
        i_callback_user_command  = g_user_command
        is_layout                = gs_layout
        it_fieldcat              = gt_fieldcat[]
        it_excluding             = lt_extab
        i_save                   = g_save
        it_events                = gt_event
      TABLES
        t_outtab                 = it_out
      EXCEPTIONS
        program_error            = 1
        OTHERS                   = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSEIF p_invtp = 2.
    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program       = g_repid
        i_callback_pf_status_set = g_status
        i_callback_user_command  = g_user_command
        is_layout                = gs_layout
        it_fieldcat              = gt_fieldcat[]
        it_excluding             = lt_extab
        i_save                   = g_save
        it_events                = gt_event
      TABLES
        t_outtab                 = it_out_memi
      EXCEPTIONS
        program_error            = 1
        OTHERS                   = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ELSEIF p_invtp = 3.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program       = g_repid
        i_callback_pf_status_set = g_status
        i_callback_user_command  = g_user_command
        is_layout                = gs_layout
        it_fieldcat              = gt_fieldcat[]
        it_excluding             = lt_extab
        i_save                   = g_save
        it_events                = gt_event
      TABLES
        t_outtab                 = it_out_mgv
      EXCEPTIONS
        program_error            = 1
        OTHERS                   = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

* --> Nuss 09.2018
  ELSEIF p_invtp = 4.
    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program       = g_repid
        i_callback_pf_status_set = g_status
        i_callback_user_command  = g_user_command
        is_layout                = gs_layout
        it_fieldcat              = gt_fieldcat[]
        it_excluding             = lt_extab
        i_save                   = g_save
        it_events                = gt_event
      TABLES
        t_outtab                 = it_out_msb
      EXCEPTIONS
        program_error            = 1
        OTHERS                   = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDIF.
* <-- Nuss 09.2018




ENDFORM.                    " DISPLAY_ALV


*&---------------------------------------------------------------------*
*&      Form  VARIANT_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM variant_init .

  CLEAR g_variant.
  g_variant-report = g_repid.

ENDFORM.                    " VARIANT_INIT

*&---------------------------------------------------------------------*
*&      Form  F4_FOR_VARIANT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f4_for_variant .

*
  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = g_variant
      i_save     = g_save
*     it_default_fieldcat =
    IMPORTING
      e_exit     = g_exit
      es_variant = gx_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 2.
    MESSAGE ID sy-msgid TYPE 'S'      NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    IF g_exit = space.
      p_vari = gx_variant-variant.
    ENDIF.
  ENDIF.

ENDFORM.                    " F4_FOR_VARIANT

*&---------------------------------------------------------------------*
*&      Form  PAI_OF_SELECTION_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pai_of_selection_screen .

  IF NOT p_vari IS INITIAL.
    MOVE g_variant TO gx_variant.
    MOVE p_vari TO gx_variant-variant.
    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
      EXPORTING
        i_save     = g_save
      CHANGING
        cs_variant = gx_variant.
    g_variant = gx_variant.
  ELSE.
    PERFORM variant_init.
  ENDIF.

ENDFORM.                    " PAI_OF_SELECTION_SCREEN

*&---------------------------------------------------------------------*
*&      Form  CHECK_INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_input .

* Entweder aggr. Vertragskonto oder Sender eingeben
  IF s_aggr IS NOT INITIAL.
    IF s_send IS NOT INITIAL.
      MESSAGE e000(e4) WITH 'Bitte entweder aggr. Vertragskonto'
                            'oder Sender eingeben'.
    ELSE.
    ENDIF.
  ENDIF.

  IF s_insta  IS INITIAL AND
     s_dtrec IS INITIAL.
    SET CURSOR FIELD 'S_INSTA-LOW'.
    MESSAGE e000(e4) WITH 'Bitte mindestens Rechnungs-Status'
                           'oder Eingangsdatum eingeben'.
  ENDIF.

ENDFORM.                    " CHECK_INPUT


*---------------------------------------------------------------------*
*       FORM USER_COMMAND                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*       --> R_UCOMM                                                   *
*       --> RS_SELFIELD                                               *
*---------------------------------------------------------------------*
FORM user_command USING r_ucomm LIKE sy-ucomm
                  rs_selfield TYPE slis_selfield.

* Daten im ALV aktualisieren (wichtig für das Selektionsfeld)
  DATA: rev_alv TYPE REF TO cl_gui_alv_grid.
  DATA: lv_transaction TYPE /adesso/fi_neg_remadv_option,
        lv_using       TYPE  /adesso/fi_neg_remadv_val.
  DATA: lv_b_selscreen TYPE boolean.
  DATA: lv_tcode TYPE sy-tcode.
  DATA: taskname(30) TYPE c.
  DATA: lt_fldvl   LIKE bus0fldval OCCURS 1 WITH HEADER LINE.
  rs_selfield-refresh = 'X'.

  rs_selfield-row_stable = 'X'.
  rs_selfield-col_stable = 'X'.

  CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
    IMPORTING
      e_grid = rev_alv.
*  BREAK-POINT.
  rev_alv->check_changed_data( ).
  FIELD-SYMBOLS: <wa_out>, <value>.
  IF p_invtp = 2.
    READ TABLE it_out_memi ASSIGNING <wa_out> INDEX rs_selfield-tabindex.
    wa_out_memi = <wa_out>.
  ELSEIF p_invtp = 1.
    READ TABLE it_out ASSIGNING <wa_out> INDEX rs_selfield-tabindex.
    wa_out = <wa_out>.
  ELSEIF p_invtp = 3.
    READ TABLE it_out_mgv ASSIGNING <wa_out> INDEX rs_selfield-tabindex.
    wa_out_mgv = <wa_out>.
* --> Nuss 09.2018
  ELSEIF p_invtp = 4.
    READ TABLE it_out_msb ASSIGNING <wa_out> INDEX rs_selfield-tabindex.
    wa_out_msb = <wa_out>.
* <-- Nuss 09.2018
  ENDIF.

  DATA: h_partner TYPE bu_partner,
        h_extui   TYPE ext_ui,
        h_anlage  TYPE anlage,
        h_vertrag TYPE vertrag.

  DATA: wa_bdc    TYPE bdcdata,
        t_bdc     TYPE TABLE OF bdcdata,
        t_messtab TYPE TABLE OF bdcmsgcoll.


  IF r_ucomm = 'CHANGE_ANL'.
    ASSIGN COMPONENT 'XSELP' OF STRUCTURE <wa_out> TO <value>.
    IF <value> IS INITIAL.
      MESSAGE e000(e4) WITH 'Bitte selektieren Sie eine Anlage.'.
      EXIT.
    ENDIF.
    ASSIGN COMPONENT 'EXT_UI' OF STRUCTURE <wa_out> TO <value>.
    PERFORM get_anlage USING <value>
                       CHANGING h_anlage.


    CLEAR lv_transaction.
    lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'CHANGE_ANL'
                                                      iv_category = 'BDC_END'
                                                      iv_field    = 'TRANSACTION'
                                                      iv_id       = '1'
                                            RECEIVING rv_value = lv_transaction
                                           ).

    IF lv_transaction IS INITIAL.
      MESSAGE e000(e4) WITH 'Für den Aufruf der Anlage wurde keine Transaktion hinterlegt.'.
      EXIT.
    ENDIF.

    SET PARAMETER ID 'ANL' FIELD h_anlage.
    CALL TRANSACTION lv_transaction AND SKIP FIRST SCREEN.

  ELSEIF r_ucomm = 'TARIF'.
    ASSIGN COMPONENT 'XSELP' OF STRUCTURE <wa_out> TO <value>.
    IF <value> IS INITIAL.
      MESSAGE e000(e4) WITH 'Bitte selektieren Sie eine Anlage.'.
      EXIT.
    ENDIF.
    ASSIGN COMPONENT 'EXT_UI' OF STRUCTURE <wa_out> TO <value>.
    PERFORM get_anlage USING <value>
                       CHANGING h_anlage.


    CLEAR lv_transaction.
    lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'TARIF'
                                                      iv_category = 'BDC_END'
                                                      iv_field    = 'TRANSACTION'
                                                      iv_id       = '1'
                                            RECEIVING rv_value = lv_transaction
                                           ).

    IF lv_transaction IS INITIAL.
      MESSAGE e000(e4) WITH 'Für den Aufruf der Anlage wurde keine Transaktion hinterlegt.'.
      EXIT.
    ENDIF.

    SET PARAMETER ID 'ANL' FIELD h_anlage.
    CALL TRANSACTION lv_transaction AND SKIP FIRST SCREEN.


  ELSEIF r_ucomm = 'CHANGE_VER'.
    ASSIGN COMPONENT 'VTREF' OF STRUCTURE <wa_out> TO <value>.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = <value>
      IMPORTING
        output = h_vertrag.

*    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*      EXPORTING
*        input  = h_vertrag
*      IMPORTING
*        output = h_vertrag.


    SET PARAMETER ID 'VTG' FIELD h_vertrag.
    CALL TRANSACTION 'ES21' AND SKIP FIRST SCREEN.
  ELSEIF r_ucomm = 'ERLEDIGEN'.

    PERFORM set_status_erl.
*>>> UH30012013
    PERFORM drop_select.
  ELSEIF r_ucomm = 'CIC'.
    ASSIGN COMPONENT 'XSELP' OF STRUCTURE <wa_out> TO <value>.
    IF <value> IS INITIAL.
      MESSAGE e000(e4) WITH 'Bitte selektieren Sie einen Datensatz.'.
      EXIT.
    ENDIF.

    DATA: iv_screen_no TYPE cicfwscreenno.
    PERFORM get_cic_frame_for_user CHANGING iv_screen_no.

    CLEAR t_bdc.
    CLEAR lv_transaction.
    CLEAR lv_using.


    lcl_customizing_data=>get_batch_data( EXPORTING iv_option = 'CIC'
                                          RECEIVING rv_t_bdc = t_bdc ).

    lcl_customizing_data=>determine_values( EXPORTING iv_t_bdc = t_bdc
                                                      iv_wa_data = <wa_out>
                                            RECEIVING rv_t_bdc = t_bdc ).
*   Besonderheit beim CIC. Hier kann das Dynpro nicht durch das Customizing
*   vorgegeben werden, da es indiv. dem User durch das Profil zugeordnet wird.
    IF iv_screen_no IS NOT INITIAL.
      CLEAR wa_bdc.
      wa_bdc-program = 'SAPLCIC0'.
      wa_bdc-dynpro = iv_screen_no.
      wa_bdc-dynbegin = 'X'.
      APPEND wa_bdc TO t_bdc.

      SORT t_bdc
            BY program DESCENDING
               fnam    ASCENDING.
    ELSE.
      MESSAGE w000(w4) WITH 'Das CIC-Profil konnte nich gelesen werden(6).'.
      CLEAR t_bdc.
    ENDIF.

    lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'CIC'
                                                      iv_category = 'BDC_END'
                                                      iv_field    = 'TRANSACTION'
                                                      iv_id       = '1'
                                            RECEIVING rv_value = lv_transaction
                                           ).
    lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'CIC'
                                                      iv_category = 'BDC_END'
                                                      iv_field    = 'USING'
                                                      iv_id       = '1'
                                            RECEIVING rv_value = lv_using
                                           ).
    IF lv_transaction IS INITIAL.
      MESSAGE e000(e4) WITH 'Für den Aufruf des CIC wurde keine Transaktion hinterlegt.'.
      EXIT.
    ENDIF.
    IF lv_using IS INITIAL.
      lv_using = 'E'.
    ENDIF.

*    CALL TRANSACTION lv_transaction USING t_bdc MODE lv_using.

    lv_tcode = lv_transaction.

    GET TIME.
    CLEAR taskname.
    CONCATENATE 'CIC' sy-datum sy-uzeit lv_tcode INTO taskname.

*    call function 'CALL_CIC_TRANSACTION'
    CALL FUNCTION '/ADESSO/FI_NEG_REAMADV_CIC'
      STARTING NEW TASK taskname
      EXPORTING
        tcode       = lv_tcode
        skipfirst   = 'X'
      TABLES
        in_bdcdata  = t_bdc
        out_messtab = t_messtab.
*     EXCEPTIONS
*       NO_AUTHORIZATION       = 1
*       OTHERS                 = 2
    .
    IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ELSEIF r_ucomm = 'BALANCE'.
    ASSIGN COMPONENT 'XSELP' OF STRUCTURE <wa_out> TO <value>.
    IF <value> IS INITIAL.
      MESSAGE e000(e4) WITH 'Bitte selektieren Sie einen Datensatz.'.
      EXIT.
    ENDIF.

*   LOOP AT SELECTION OPTION
*   Tabelle so aufbauen, dass es individuell steuerbar ist

* Quick and dirty ohne Customizing

    IF p_invtp NE 4.                        "Nuss 09.2018-2

      CLEAR t_bdc.
      CLEAR lv_transaction.
      CLEAR lv_using.

      lcl_customizing_data=>get_batch_data( EXPORTING iv_option = 'BALANCE'
                                            RECEIVING rv_t_bdc = t_bdc ).

      lcl_customizing_data=>determine_values( EXPORTING iv_t_bdc = t_bdc
                                                        iv_wa_data = <wa_out>
                                              RECEIVING rv_t_bdc = t_bdc ).


      lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'BALANCE'
                                                        iv_category = 'BDC_END'
                                                        iv_field    = 'TRANSACTION'
                                                        iv_id       = '1'
                                              RECEIVING rv_value = lv_transaction
                                             ).
      lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'BALANCE'
                                                        iv_category = 'BDC_END'
                                                        iv_field    = 'USING'
                                                        iv_id       = '1'
                                              RECEIVING rv_value = lv_using
                                             ).

      IF lv_transaction IS INITIAL.
        MESSAGE e000(e4) WITH 'Für den Aufruf des Kontenstandes wurde keine Transaktion hinterlegt.'.
        EXIT.
      ENDIF.
      IF lv_using IS INITIAL.
        lv_using = 'E'.
      ENDIF.

      CALL TRANSACTION lv_transaction USING t_bdc MODE lv_using.

** --> Nuss 09.2018-2
    ELSE.
      ASSIGN COMPONENT 'VKONT_MSB' OF STRUCTURE <wa_out> TO <value>.
      CLEAR lv_transaction.
      lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'BALANCE_MSB'
                                                        iv_category = 'BDC_END'
                                                        iv_field    = 'TRANSACTION'
                                                        iv_id       = '1'
                                              RECEIVING rv_value = lv_transaction
                                              ).
      IF lv_transaction IS INITIAL.
        MESSAGE e000(e4) WITH 'Für den Aufruf des Kontenstands wurde keine' 'Transaktion hinterlegt.'.
        EXIT.
      ENDIF.

      SUBMIT (lv_transaction)
          WITH p_ca = <value>
          VIA SELECTION-SCREEN
         AND RETURN.
    ENDIF.
** <-- Nuss 09.2018-2



  ELSEIF r_ucomm =  '&ALL_U'.
*      BREAK-POINT.
    PERFORM mark_all.

  ELSEIF  r_ucomm = '&SAL_U'  .
*      BREAK-POINT.
    PERFORM unmark_all.

  ELSEIF r_ucomm = 'SWTMON'.
    ASSIGN COMPONENT 'XSELP' OF STRUCTURE <wa_out> TO <value>.
    IF <value> IS INITIAL.
      MESSAGE e000(e4) WITH 'Bitte selektieren Sie einen Datensatz.'.
      EXIT.
    ENDIF.

    CLEAR lv_b_selscreen.
    lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'SWTMON'
                                                      iv_category = 'BDC_END'
                                                      iv_field    = 'SELSCREEN'
                                                      iv_id       = '1'
                                            RECEIVING rv_value = lv_b_selscreen
                                           ).
    CLEAR lv_transaction.
    lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'SWTMON'
                                                      iv_category = 'BDC_END'
                                                      iv_field    = 'TRANSACTION'
                                                      iv_id       = '1'
                                            RECEIVING rv_value = lv_transaction
                                           ).

    IF lv_transaction IS INITIAL.
      MESSAGE e000(e4) WITH 'Für den Aufruf der Wechselbeleganzeige wurde keine Transaktion hinterlegt.'.
      EXIT.
    ENDIF.
    ASSIGN COMPONENT 'EXT_UI' OF STRUCTURE <wa_out> TO <value>.
    IF lv_b_selscreen EQ abap_false.
      SUBMIT (lv_transaction)
        WITH so_extui-low = <value>
        AND RETURN.
    ELSE.
      SUBMIT (lv_transaction)
        WITH so_extui-low = <value>
        VIA SELECTION-SCREEN
        AND RETURN.
    ENDIF.

  ELSEIF r_ucomm = 'DATEX'OR r_ucomm = 'PDOCMON' .
    ASSIGN COMPONENT 'XSELP' OF STRUCTURE <wa_out> TO <value>.
    IF <value> IS INITIAL.
      MESSAGE e000(e4) WITH 'Bitte selektieren Sie einen Zählpunkt.'.
      EXIT.
    ENDIF.

    CLEAR lv_b_selscreen.
    lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'DATEX'
                                                      iv_category = 'BDC_END'
                                                      iv_field    = 'SELSCREEN'
                                                      iv_id       = '1'
                                            RECEIVING rv_value = lv_b_selscreen
                                           ).
    CLEAR lv_transaction.
    DATA lv_option TYPE /adesso/fi_neg_remadv_option.
    lv_option = r_ucomm.
    lcl_customizing_data=>get_config_value( EXPORTING iv_option   = lv_option
                                                      iv_category = 'BDC_END'
                                                      iv_field    = 'TRANSACTION'
                                                      iv_id       = '1'
                                            RECEIVING rv_value = lv_transaction
                                           ).
    DATA lv_dxdudlow TYPE d.
    DATA lv_dxdud_delta TYPE d.
    lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'DATEX'
                                                  iv_category = 'BDC_END'
                                                  iv_field    = 'DXDUDLOW'
                                                  iv_id       = '1'
                                        RECEIVING rv_value = lv_dxdud_delta
                                       ).
    DATA : lv_no_date TYPE c, lv_no_max TYPE c.
    lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'DATEX'
                                                  iv_category = 'BDC_END'
                                                  iv_field    = 'NO_MAX'
                                                  iv_id       = '1'
                                        RECEIVING rv_value = lv_no_max
                                       ).
    lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'DATEX'
                                                  iv_category = 'BDC_END'
                                                  iv_field    = 'NO_DATE'
                                                  iv_id       = '1'
                                        RECEIVING rv_value = lv_no_date
                                       ).
    lv_dxdudlow = sy-datum - lv_dxdud_delta.
    IF lv_transaction IS INITIAL.
      MESSAGE e000(e4) WITH 'Für den Aufruf zur Prozessierung des Belegs wurde keine Transaktion hinterlegt.'.
      EXIT.
    ENDIF.
    ASSIGN COMPONENT 'EXT_UI' OF STRUCTURE <wa_out> TO <value>.
    SELECT COUNT(*) FROM /adesso/fi_remad WHERE negrem_option = 'DATEX' AND negrem_field = 'COMMONLA' AND negrem_value = 'X'.
    IF sy-subrc = 0 AND r_ucomm = 'PDOCMON' .
      SUBMIT (lv_transaction)
    WITH so_extui-low = <value>
    WITH p_no_max = lv_no_max
  AND RETURN.
    ELSE.
      IF lv_b_selscreen EQ abap_false.
        SUBMIT (lv_transaction)
          WITH se_extui-low = <value>
          WITH se_dxdud-low = lv_dxdudlow
          WITH se_dxdud-high = sy-datum
          WITH p_nodate = lv_no_date
          WITH p_no_max = lv_no_max
          VIA SELECTION-SCREEN                 "Nuss 10.2017 Melo/Malo
        AND RETURN.
      ELSE.
        SUBMIT (lv_transaction)
          WITH se_extui-low = <value>
          WITH se_dxdud-low = lv_dxdudlow
          WITH se_dxdud-high = sy-datum
          WITH p_nodate = lv_no_date
          WITH p_no_max = lv_no_max
          VIA SELECTION-SCREEN
          AND RETURN.
      ENDIF.
    ENDIF.

  ELSEIF r_ucomm = 'PROZESS'.
    "läuft auch für memi

    PERFORM prozessiere_remadv. " USING wa_out-int_inv_doc_no.
    SELECT COUNT(*) FROM /adesso/fi_remad WHERE negrem_option = 'DROPLOCKS' AND negrem_field = 'PROZESS' AND negrem_value = 'X'.
    IF sy-subrc = 0.
      PERFORM drop_select.
    ENDIF.

  ELSEIF r_ucomm = 'BEENDEN'.


    PERFORM beende_remadv.
    SELECT COUNT(*) FROM /adesso/fi_remad WHERE negrem_option = 'DROPLOCKS' AND negrem_field = 'BEENDEN' AND negrem_value = 'X'.
    IF sy-subrc = 0.
      PERFORM drop_select.
    ENDIF.

  ELSEIF r_ucomm = 'BEENDEN_M'.


    PERFORM beende_remadv.
    SELECT COUNT(*) FROM /adesso/fi_remad WHERE negrem_option = 'DROPLOCKS' AND negrem_field = 'BEENDEN' AND negrem_value = 'X'.
    IF sy-subrc = 0.
      PERFORM drop_select.
    ENDIF.
  ELSEIF r_ucomm = 'LOCK'.
    SELECT COUNT(*) FROM tfk047s WHERE mansp = pa_lockr.
    IF sy-subrc <> 0.
      DATA lv_message TYPE string.
      CONCATENATE 'Mahnsperrgrund'   pa_lockr 'nicht vorhanden!' INTO lv_message SEPARATED BY ' '.
      MESSAGE lv_message TYPE 'E'.
    ELSE.
      PERFORM mahnsperre_setzen.
    ENDIF.

  ELSEIF r_ucomm = 'UNLOCK'.
    PERFORM mahnsperre_entfernen.

  ELSEIF r_ucomm = 'BEMERKUNG'.

    DATA lv_empty(10) TYPE c.
    PERFORM add_text CHANGING lv_empty.

*   Kennzeichen für Aktualisierung der Anzeige setzen

  ELSEIF r_ucomm = 'CANCEL'.

    PERFORM cancel_printdoc. "
    SELECT COUNT(*) FROM /adesso/fi_remad WHERE negrem_option = 'DROPLOCKS' AND negrem_field = 'CANCEL' AND negrem_value = 'X'.
    IF sy-subrc = 0.
      PERFORM drop_select.
    ENDIF.

  ELSEIF r_ucomm = 'CANCEL_M'.

    PERFORM cancel_memidoc. "
    SELECT COUNT(*) FROM /adesso/fi_remad WHERE negrem_option = 'DROPLOCKS' AND negrem_field = 'CANCEL' AND negrem_value = 'X'.
    IF sy-subrc = 0.
      PERFORM drop_select.
    ENDIF.

  ELSEIF r_ucomm = 'CANCEL_MGV'.

    PERFORM cancel_mgv. "
    SELECT COUNT(*) FROM /adesso/fi_remad WHERE negrem_option = 'DROPLOCKS' AND negrem_field = 'CANCEL' AND negrem_value = 'X'.
    IF sy-subrc = 0.
      PERFORM drop_select.
    ENDIF.

* --> Nuss 09.2018-2
  ELSEIF r_ucomm = 'CANCEL_A'.

    PERFORM cancel_abrdoc.

    SELECT COUNT(*) FROM /adesso/fi_remad WHERE negrem_option = 'DROPLOCKS' AND negrem_field = 'CANCEL' AND negrem_value = 'X'.
    IF sy-subrc = 0.
      PERFORM drop_select.
    ENDIF.

  ELSEIF r_ucomm = 'CANCEL_AP'.

    PERFORM cancel_abrplan.


* <-- Nuss 09.2018-2
  ELSEIF r_ucomm = 'SM_SEL_DAT'.

    PERFORM send_sel_data_via_mail.


  ELSE.

    CASE rs_selfield-fieldname.

      WHEN 'TEXT_VORHANDEN'.
        ASSIGN COMPONENT 'INT_INV_DOC_NO' OF STRUCTURE <wa_out> TO <value>.
        PERFORM texte_anzeigen USING <value>.


*  Geschäftspartner anzeigen
      WHEN 'GPART' OR 'GPART_INV'.

        MOVE rs_selfield-value TO h_partner.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = h_partner
          IMPORTING
            output = h_partner.

        CALL FUNCTION 'ISU_S_PARTNER_DISPLAY'
          EXPORTING
            x_partner = h_partner.
*      SET PARAMETER ID 'BPA' FIELD h_partner.
*      CALL TRANSACTION 'FPP3' AND SKIP FIRST SCREEN.
      WHEN 'INVDOCNO'.
        DATA lv_invdocno_kk TYPE invdocno_kk.
        lv_invdocno_kk = rs_selfield-value.
        CALL FUNCTION 'FKK_INV_INVDOC_DISP'
          EXPORTING
            x_invdocno = lv_invdocno_kk.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.

        "do sth
      WHEN 'BILLDOCNO'.
        DATA lv_billdocno_kk TYPE billdocno_kk.
        lv_billdocno_kk = rs_selfield-value.
        CALL FUNCTION 'FKK_INV_BILLDOC_DISP'
          EXPORTING
            x_billdocno = lv_billdocno_kk.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.

* Aggregiertes Vertragskonto anzeigen
      WHEN 'AGGVK' OR 'SUPPL_CONTR_ACCT' OR 'VKONT_MSB'.              "Nuss 09.2018.
        CLEAR lv_transaction.
        lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'VKONT'
                                                          iv_category = 'BDC_END'
                                                          iv_field    = 'TRANSACTION'
                                                          iv_id       = '1'
                                                RECEIVING rv_value = lv_transaction
                                               ).
        IF lv_transaction IS INITIAL.
          MESSAGE e000(e4) WITH 'Für den Aufruf des Vertragskontos wurde keine Transaktion hinterlegt.'.
          EXIT.
        ENDIF.
        IF lv_transaction = 'DEFFUBA'.
          CLEAR lt_fldvl.
          IF NOT rs_selfield-value IS INITIAL.
            lt_fldvl-tbfld = 'FKKVK-VKONT'.
            lt_fldvl-fldvl = rs_selfield-value.
            APPEND lt_fldvl.
          ENDIF.

          CALL FUNCTION 'VKK_FICA_ACCOUNT_MAINTAIN'
            EXPORTING
              i_aktyp = '03'
              i_xinit = ' '
*             I_XSAVE = 'X'
*             I_APPLI =
*             I_XUPDTASK          = 'X'
*             I_SICHT_START       = ' '
*           IMPORTING
*             E_STATE =
*             E_STATE_FCODE       =
*             E_HANDLE            =
            TABLES
*             T_RLTYP =
*             T_RLTGR =
              t_fldvl = lt_fldvl
*             T_SCRSEL            =
*             T_MSG   =
            .

        ELSE.
          SET PARAMETER ID 'KTO' FIELD rs_selfield-value.
          CALL TRANSACTION lv_transaction AND SKIP FIRST SCREEN.
        ENDIF.
* Vertragskonto anzeigen
      WHEN  'VKONT' OR 'VKONT_INV'.
        CLEAR lv_transaction.
        lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'VKONT'
                                                          iv_category = 'BDC_END'
                                                          iv_field    = 'TRANSACTION'
                                                          iv_id       = '1'
                                                RECEIVING rv_value = lv_transaction
                                               ).
        IF lv_transaction IS INITIAL.
          MESSAGE e000(e4) WITH 'Für den Aufruf des Vertragskontos wurde keine Transaktion hinterlegt.'.
          EXIT.
        ENDIF.
        IF lv_transaction = 'DEFFUBA'.
*          DATA: lt_fldvl   LIKE bus0fldval OCCURS 1 WITH HEADER LINE.
          CLEAR: lt_fldvl.
          IF NOT rs_selfield-value IS INITIAL.
            lt_fldvl-tbfld = 'FKKVK-VKONT'.
            lt_fldvl-fldvl = rs_selfield-value.
            APPEND lt_fldvl.
          ENDIF.

          CALL FUNCTION 'VKK_FICA_ACCOUNT_MAINTAIN'
            EXPORTING
              i_aktyp = '03'
              i_xinit = ' '
*             I_XSAVE = 'X'
*             I_APPLI =
*             I_XUPDTASK          = 'X'
*             I_SICHT_START       = ' '
*           IMPORTING
*             E_STATE =
*             E_STATE_FCODE       =
*             E_HANDLE            =
            TABLES
*             T_RLTYP =
*             T_RLTGR =
              t_fldvl = lt_fldvl
*             T_SCRSEL            =
*             T_MSG   =
            .

        ELSE.

          SET PARAMETER ID 'KTO' FIELD rs_selfield-value.
          CALL TRANSACTION lv_transaction AND SKIP FIRST SCREEN.
        ENDIF.
* Vertrag anzeigen
      WHEN 'VTREF'.
        CLEAR lv_transaction.
        lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'VTREF'
                                                          iv_category = 'BDC_END'
                                                          iv_field    = 'TRANSACTION'
                                                          iv_id       = '1'
                                                RECEIVING rv_value = lv_transaction
                                               ).
        IF lv_transaction IS INITIAL.
          MESSAGE e000(e4) WITH 'Für den Aufruf des Vertrages wurde keine Transaktion hinterlegt.'.
          EXIT.
        ENDIF.
        SET PARAMETER ID 'VTG' FIELD rs_selfield-value.
        CALL TRANSACTION lv_transaction AND SKIP FIRST SCREEN.

*   Sender-ID
      WHEN 'INT_SENDER'.
        CLEAR lv_transaction.
        lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'INT_SENDER'
                                                          iv_category = 'BDC_END'
                                                          iv_field    = 'TRANSACTION'
                                                          iv_id       = '1'
                                                RECEIVING rv_value = lv_transaction
                                               ).
        IF lv_transaction IS INITIAL.
          MESSAGE e000(e4) WITH 'Für den Aufruf Senders wurde keine Transaktion hinterlegt.'.
          EXIT.
        ENDIF.
        SET PARAMETER ID 'EESERVPROVID' FIELD rs_selfield-value.
        CALL TRANSACTION lv_transaction AND SKIP FIRST SCREEN.

*  Empfänger-ID
      WHEN 'INT_RECEIVER'.
        CLEAR lv_transaction.
        lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'INT_RECEIVER'
                                                          iv_category = 'BDC_END'
                                                          iv_field    = 'TRANSACTION'
                                                          iv_id       = '1'
                                                RECEIVING rv_value = lv_transaction
                                               ).
        IF lv_transaction IS INITIAL.
          MESSAGE e000(e4) WITH 'Für den Aufruf des Empfängers wurde keine Transaktion hinterlegt.'.
          EXIT.
        ENDIF.
        SET PARAMETER ID 'EESERVPROVID' FIELD rs_selfield-value.
        CALL TRANSACTION lv_transaction AND SKIP FIRST SCREEN.

*  Druckbeleg
      WHEN 'XBLNR'.
        CLEAR lv_transaction.
        lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'XBLNR'
                                                          iv_category = 'BDC_END'
                                                          iv_field    = 'TRANSACTION'
                                                          iv_id       = '1'
                                                RECEIVING rv_value = lv_transaction
                                               ).
        IF lv_transaction IS INITIAL.
          MESSAGE e000(e4) WITH 'Für den Aufruf des Belegs wurde keine Transaktion hinterlegt.'.
          EXIT.
        ENDIF.
        SET PARAMETER ID 'E_PRINTDOC' FIELD rs_selfield-value.
        CALL TRANSACTION lv_transaction AND SKIP FIRST SCREEN.

*  int. Belegnr
      WHEN 'OWN_INVOICE_NO'.
        IF p_invtp = 1.
          CLEAR lv_transaction.
          lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'OWN_INVOICE_NO'
                                                            iv_category = 'BDC_END'
                                                            iv_field    = 'TRANSACTION'
                                                            iv_id       = '1'
                                                  RECEIVING rv_value = lv_transaction
                                                 ).
          IF lv_transaction IS INITIAL.
            MESSAGE e000(e4) WITH 'Für den Aufruf des Belegs wurde keine Transaktion hinterlegt.'.
            EXIT.
          ENDIF.
          IF rs_selfield-value CO ' 0123456789'.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = rs_selfield-value
              IMPORTING
                output = rs_selfield-value.
          ELSE.
            rs_selfield-value = rs_selfield-value+3.
          ENDIF.

          SET PARAMETER ID 'E_PRINTDOC' FIELD rs_selfield-value.
          CALL TRANSACTION lv_transaction AND SKIP FIRST SCREEN.
        ELSE.



        ENDIF.

      WHEN 'ERCHCOPBEL'.
        SET PARAMETER ID 'E_PRINTDOC' FIELD rs_selfield-value.
        CALL TRANSACTION 'EA40' AND SKIP FIRST SCREEN.

* Belegnummer
      WHEN 'OPBEL' .
        CLEAR lv_transaction.
        lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'OPBEL'
                                                          iv_category = 'BDC_END'
                                                          iv_field    = 'TRANSACTION'
                                                          iv_id       = '1'
                                                RECEIVING rv_value = lv_transaction
                                               ).
        IF lv_transaction IS INITIAL.
          MESSAGE e000(e4) WITH 'Für den Aufruf des Belegs wurde keine Transaktion hinterlegt.'.
          EXIT.
        ENDIF.
        SET PARAMETER ID '80B' FIELD rs_selfield-value.
        CALL TRANSACTION lv_transaction AND SKIP FIRST SCREEN.

* aggr. Beleg
      WHEN 'BCBLN'.
        CLEAR lv_transaction.
        lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'BCBLN'
                                                          iv_category = 'BDC_END'
                                                          iv_field    = 'TRANSACTION'
                                                          iv_id       = '1'
                                                RECEIVING rv_value = lv_transaction
                                               ).
        IF lv_transaction IS INITIAL.
          MESSAGE e000(e4) WITH 'Für den Aufruf des Belegs wurde keine Transaktion hinterlegt.'.
          EXIT.
        ENDIF.
        SET PARAMETER ID '80B' FIELD rs_selfield-value.
        CALL TRANSACTION lv_transaction AND SKIP FIRST SCREEN.

** --> Nuss 09.2018-2
      WHEN 'BILLPLANNO'.
        CLEAR lv_transaction.
        lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'BILLPLAN'
                                                          iv_category = 'BDC_END'
                                                          iv_field    = 'TRANSACTION'
                                                          iv_id       = '1'
                                                RECEIVING rv_value = lv_transaction
                                                ).
        IF lv_transaction IS INITIAL.
          MESSAGE e000(e4) WITH 'Für den Aufruf des Abrechnungsplans wurde keine' 'Transaktion hinterlegt.'.
          EXIT.
        ENDIF.
        SET PARAMETER ID 'CI_BILLPLAN' FIELD rs_selfield-value.
        SUBMIT (lv_transaction)
          WITH billplan_low = rs_selfield-value
          AND RETURN.
** <-- Nuss 09.2018-2

* Ext.ZP
      WHEN 'EXT_UI'.
        MOVE rs_selfield-value TO h_extui.
        CALL FUNCTION 'ISU_S_UI_DISPLAY'
          EXPORTING
            x_ext_ui = h_extui.

*** --> Nuss 10.2017 Melo/Malo
      WHEN 'EXT_UI_MELO'.
        MOVE rs_selfield-value TO h_extui.
        CALL FUNCTION 'ISU_S_UI_DISPLAY'
          EXPORTING
            x_ext_ui = h_extui.
*** <-- Nuss 10.2017 Melo/Malo



* int.Belegnr
      WHEN 'INT_INV_DOC_NO'.
*        SEt PARAMETER ID 'INV_INVOICE_TYPE' FIELD space.      "Nuss 25.01.2018
        ASSIGN COMPONENT 'INT_INV_DOC_NO' OF STRUCTURE <wa_out> TO <value>.
        CLEAR lv_transaction.
        lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'INT_INV_DOC_NO'
                                                          iv_category = 'BDC_END'
                                                          iv_field    = 'TRANSACTION'
                                                          iv_id       = '1'
                                                RECEIVING rv_value = lv_transaction
                                               ).
        IF lv_transaction IS INITIAL.
          MESSAGE e000(e4) WITH 'Für den Aufruf des Belegs wurde keine Transaktion hinterlegt.'.
          EXIT.
        ENDIF.
        SET PARAMETER ID 'INV_INVOICE_TYPE' FIELD '000'.     "Nuss 25.01.2017
        SUBMIT (lv_transaction)
          "WITH p_invtp      = p_invtp
          WITH se_docnr-low = <value>
          AND RETURN.

* int.Belegnr
      WHEN 'PAYM_AVIS'.
        CLEAR lv_transaction.
        lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'PAYM_AVIS'
                                                          iv_category = 'BDC_END'
                                                          iv_field    = 'TRANSACTION'
                                                          iv_id       = '1'
                                                RECEIVING rv_value = lv_transaction
                                               ).
        IF lv_transaction IS INITIAL.
          MESSAGE e000(e4) WITH 'Für den Aufruf des Belegs wurde keine Transaktion hinterlegt.'.
          EXIT.
        ENDIF.
        ASSIGN COMPONENT 'PAYM_AVIS' OF STRUCTURE <wa_out> TO <value>.
        SET PARAMETER ID 'INV_INVOICE_TYPE' FIELD '000'.     "Nuss 25.01.2017
        SUBMIT (lv_transaction)
          "WITH p_invtp      = '002'
          WITH se_docnr-low = <value>
          AND RETURN.

* interner Status (in Feld FREE_TEXT4 )
      WHEN 'FREE_TEXT4'.

        PERFORM int_status USING rs_selfield-value rs_selfield-tabindex.
* Eingabe Notiz
      WHEN 'FREE_TEXT5'.
        "Sonderfall Solingen
        SELECT COUNT( * ) FROM /adesso/fi_remad WHERE negrem_option = 'NOTIZ' AND negrem_field = 'SOLINGEN' AND negrem_value = 'X'.
        IF sy-subrc = 0.
          PERFORM int_notice USING rs_selfield-value rs_selfield-tabindex.
* Eingabe Notiz über Texteditor
        ELSE.
          PERFORM int_notice_edit USING rs_selfield-value
                                        rs_selfield-tabindex.
        ENDIF.

      WHEN 'FREE_TEXT1'.

        PERFORM get_free_text USING rs_selfield-value
                                    rs_selfield-tabindex.


        "MeMi
      WHEN 'DOC_ID' OR 'PROC_REF'.
        DATA lv_eideswtnum TYPE eideswtnum.
        DATA lv_doc_id TYPE /idxmm/memidoc-doc_id.
        IF p_invtp = 2.
          lv_doc_id = rs_selfield-value(12).

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = rs_selfield-value
            IMPORTING
              output = lv_doc_id.
          SELECT SINGLE pdoc_ref FROM /idxmm/memidoc INTO lv_eideswtnum WHERE doc_id = lv_doc_id.
        ELSE.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = rs_selfield-value
            IMPORTING
              output = lv_eideswtnum.

        ENDIF.

        CALL FUNCTION '/IDXGC/FM_PDOC_DISPLAY'
          EXPORTING
            x_switchnum    = lv_eideswtnum
          EXCEPTIONS
            general_fault  = 1
            not_found      = 2
            not_authorized = 3
            OTHERS         = 4.


        IF sy-subrc NE 0.

        ENDIF.
** --> Nuss 09.2018
      WHEN 'SRCDOCNO'.
        SUBMIT rfkkinv_billdoc_disp
          WITH billdoc = rs_selfield-value
          AND RETURN.
** <-- Nuss 09.2018

      WHEN 'TRIG_BILL_DOC_NO'.
        DATA lv_bill_doc TYPE e_belnr.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = rs_selfield-value
          IMPORTING
            output = lv_bill_doc.
        IF lv_bill_doc IS NOT INITIAL.
          CALL FUNCTION 'ISU_S_BILL_DOC_DISPLAY'
            EXPORTING
              x_belnr       = lv_bill_doc
            EXCEPTIONS
              not_found     = 1
              general_fault = 2
              OTHERS        = 3.
          IF sy-subrc <> 0.
*             Implement suitable error handling here
            RETURN.
          ENDIF.
        ENDIF.

      WHEN 'MSCONS_IDOC'
        OR 'INVOIC_IDOC'
        OR 'REMADV_IDOC'.
        DATA lv_idocnum(16) TYPE n.
        MOVE rs_selfield-value TO lv_idocnum .
        CALL FUNCTION 'EDI_DOCUMENT_DATA_DISPLAY'
          EXPORTING
            docnum               = lv_idocnum
          EXCEPTIONS
            no_data_record_found = 1
            OTHERS               = 2.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

      WHEN 'VKONTO_MEMI'.
        DATA lv_account(12) TYPE c.
        MOVE rs_selfield-value TO lv_account.

        CALL FUNCTION 'ISU_S_ACCOUNT_DISPLAY'
          EXPORTING
            x_account      = lv_account
            x_no_change    = 'X'
          EXCEPTIONS
            not_found      = 1
            foreign_lock   = 2
            internal_error = 3
            input_error    = 4
            OTHERS         = 5.
        IF sy-subrc <> 0.
*           Implement suitable error handling here
          RETURN.
        ENDIF.

      WHEN 'CI_INVOIC_DOC_NO'.
        DATA lv_ci_inv(12) TYPE n.
        MOVE rs_selfield-value TO lv_ci_inv.
        IF lv_ci_inv IS NOT INITIAL.
          CALL FUNCTION 'FKK_INV_INVDOC_DISP'
            EXPORTING
              x_invdocno    = lv_ci_inv
            EXCEPTIONS
              general_fault = 1
              OTHERS        = 2.
          IF sy-subrc <> 0.
*             Implement suitable error handling here
            RETURN.
          ENDIF.
        ENDIF.

      WHEN 'FI_DOC_EXT'.
        DATA lv_opbel_ext(12) TYPE c.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = rs_selfield-value
          IMPORTING
            output = lv_opbel_ext.
        IF lv_opbel_ext IS NOT INITIAL.
          CALL FUNCTION 'FKK_FPE0_START_TRANSACTION'
            EXPORTING
              tcode              = 'FPE3'
              opbel              = lv_opbel_ext
            EXCEPTIONS
              document_not_found = 1
              OTHERS             = 2.
          IF sy-subrc <> 0.
*             Implement suitable error handling here
            RETURN.
          ENDIF.
        ENDIF.

      WHEN 'INV_DOC_NO'.
        DATA lv_inv_doc_no_a(18) TYPE n.
        IF rs_selfield-value IS NOT INITIAL.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = rs_selfield-value
            IMPORTING
              output = lv_inv_doc_no_a.

          CALL FUNCTION 'INV_S_INVREMADV_DOC_DISPLAY'
            EXPORTING
              x_inv_doc_no = lv_inv_doc_no_a
            EXCEPTIONS
              OTHERS       = 1.
          IF sy-subrc <> 0.
          ENDIF.
        ENDIF.

      WHEN 'BILLABLE_ITEM'.
        DATA: ls_srctaid    TYPE fkkr_srctaid,
              lv_srctaid_kk TYPE srctaid_kk,
              lt_srctaid    TYPE fkk_rt_srctaid,
              ls_bitstatus  TYPE fkkr_bitstatus,
              lt_bitstatus  TYPE fkk_rt_bitstatus,
              ls_bitdate    TYPE fkkr_bitdate,
              lt_bitdate    TYPE fkk_rt_bitdate.
        IF rs_selfield-value IS NOT INITIAL .
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = rs_selfield-value
            IMPORTING
              output = lv_srctaid_kk.
          ls_srctaid-sign     = /idxgc/if_constants=>gc_sel_sign_include.
          ls_srctaid-option   = /idxgc/if_constants=>gc_sel_opt_equal.
          ls_srctaid-low      = lv_srctaid_kk.
          APPEND ls_srctaid TO lt_srctaid.
          ls_bitstatus-sign   = /idxgc/if_constants=>gc_sel_sign_include.
          ls_bitstatus-option = /idxgc/if_constants=>gc_sel_opt_equal.
          ls_bitstatus-low    = space.  " Space - All Statuses
          APPEND ls_bitstatus TO lt_bitstatus.
          ls_bitdate-sign     = /idxgc/if_constants=>gc_sel_sign_include.
          ls_bitdate-option   = /idxgc/if_constants=>gc_sel_opt_between.
          ls_bitdate-high     = sy-datum.
          APPEND ls_bitdate TO lt_bitdate.
          CALL FUNCTION 'FKK_BIX_BIT_MON'
            EXPORTING
              irt_srctaid           = lt_srctaid
              irt_bitstatus         = lt_bitstatus
              irt_bitdate           = lt_bitdate
              i_bit4_uninvoiced_req = abap_true
              i_bit4_invoiced_req   = abap_true
            EXCEPTIONS
              not_found             = 1
              OTHERS                = 2.
          IF sy-subrc <> 0.
          ENDIF.
        ENDIF.

      WHEN 'CI_FICA_DOC_NO'.
        DATA lv_opbel_fi(12) TYPE c.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = rs_selfield-value
          IMPORTING
            output = lv_opbel_fi.
        IF lv_opbel_fi IS NOT INITIAL.
          CALL FUNCTION 'FKK_FPE0_START_TRANSACTION'
            EXPORTING
              tcode              = 'FPE3'  " 'FPE3'
              opbel              = lv_opbel_fi
            EXCEPTIONS
              document_not_found = 1
              OTHERS             = 2.
          IF sy-subrc <> 0.
*             Implement suitable error handling here
            RETURN.
          ENDIF.
        ENDIF.





    ENDCASE.
  ENDIF.
ENDFORM.                    "user_command

*-----------------------------------------------------------------------
*    FORM PF_STATUS_SET
*-----------------------------------------------------------------------
*    ........
*-----------------------------------------------------------------------
*    --> extab
*-----------------------------------------------------------------------
FORM status_standard  USING extab TYPE slis_t_extab.
  IF p_invtp = '1'.
    SET PF-STATUS 'STANDARD_NEG_REMADV' EXCLUDING extab.
  ELSEIF p_invtp = '2'.
    SET PF-STATUS 'MEMI_NEG_REMADV' EXCLUDING extab.
** --> Nuss 28.03.2017
  ELSEIF p_invtp = '3'.
    SET PF-STATUS 'MGV_NEG_REMADV' EXCLUDING extab.
** <-- Nuss 28.03.2017
** --> Nuss 09.2018
  ELSEIF p_invtp = '4'.
    SET PF-STATUS 'MSB_NEG_REMADV' EXCLUDING extab.
** <-- Nuss 09.2018
  ENDIF.
ENDFORM.                    "status_standard

*&---------------------------------------------------------------------*
*&      Form  GET_ANLAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_OUT_EXT_UI  text
*----------------------------------------------------------------------*
FORM get_anlage  USING    p_wa_out_ext_ui
                 CHANGING p_anlage.


  SELECT SINGLE euiinstln~anlage INTO p_anlage
    FROM euiinstln
    INNER JOIN euitrans
    ON  euiinstln~int_ui = euitrans~int_ui
*       inner join eanl
*         on euiinstln~anlage = eanl~anlage
    WHERE euitrans~ext_ui = p_wa_out_ext_ui
    AND euiinstln~dateto >= sy-datum
    AND euitrans~dateto >= sy-datum
    AND euiinstln~datefrom <= sy-datum

    AND euitrans~datefrom <= sy-datum.
*      AND eanl~loevm ne 'X'.



ENDFORM.                    " GET_ANLAGE


*&---------------------------------------------------------------------*
*&      Form  PROZESSIERE_REMADV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM prozessiere_remadv. " USING p_int_inv_doc_no.

  DATA: lt_return     TYPE bapirettab,
        l_proc_type   TYPE inv_process_type,
        l_error       TYPE inv_kennzx,
        lv_b_selected TYPE boolean.

  DATA: icon(4) TYPE c.

  FIELD-SYMBOLS: <it_out> TYPE STANDARD TABLE, <wa_out>, <value>.

  IF p_invtp = '2'.
    ASSIGN it_out_memi TO <it_out>.
  ELSEIF p_invtp = 1.
    ASSIGN it_out TO <it_out>.
  ELSEIF p_invtp = 3.
    ASSIGN it_out_mgv TO <it_out>.
** --> Nuss 09.2018
  ELSEIF p_invtp = 4.
    ASSIGN it_out_msb TO <it_out>.
** <-- Nuss 09.2018
  ENDIF.

  LOOP AT <it_out> ASSIGNING <wa_out>.

*   Zeile muss Markiert sein
    ASSIGN COMPONENT 'SEL' OF STRUCTURE <wa_out> TO <value>.
    CHECK <value> = 'X'.

    lv_b_selected = abap_true.

*   INT_INVOICE_NO muss gefüllt sein.
*   Bei mehreren Fehlernist nur die erste Zeile zum Beleg gefüllt.
    ASSIGN COMPONENT 'INT_INV_DOC_NO' OF STRUCTURE <wa_out> TO <value>.
    CHECK <value> IS NOT INITIAL.
*   Status 'Neu' oder 'Zu Bearbeiten'
    ASSIGN COMPONENT 'INVOICE_STATUS' OF STRUCTURE <wa_out> TO <value>.
    IF <value> NE '01' AND
       <value> NE '02'.
      CONTINUE.
    ENDIF.

    CLEAR lt_return[].
    CLEAR: l_proc_type, l_error.
    ASSIGN COMPONENT 'INT_INV_DOC_NO' OF STRUCTURE <wa_out> TO <value>.
    CALL METHOD cl_inv_inv_remadv_doc=>process_document
      EXPORTING
        im_doc_number          = <value>
      IMPORTING
        ex_return              = lt_return[]
        ex_exit_process_type   = l_proc_type
        ex_proc_error_occurred = l_error
      EXCEPTIONS
        OTHERS                 = 1.

*   Icon für Prozesstatus setzen

    IF sy-subrc <> 0.
      icon = icon_led_red.
    ELSE.
      icon = icon_execute_object.
    ENDIF.
    ASSIGN COMPONENT 'INT_INV_DOC_NO' OF STRUCTURE <wa_out> TO <value>.
    PERFORM set_process_state_all USING icon <value>.

  ENDLOOP.

  IF lv_b_selected EQ abap_false.
    MESSAGE e000(e4) WITH 'Bitte selektieren Sie einen Datensatz.'.
    EXIT.
  ENDIF.

ENDFORM.                    " PROZESSIERE_REMADV


*&---------------------------------------------------------------------*
*&      Form  BEENDE_REMADV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM beende_remadv. " USING p_int_inv_doc_no.

  DATA: l_inv_doc TYPE REF TO cl_inv_inv_remadv_doc.
  DATA: lt_return TYPE bapirettab.
  DATA: l_answer      TYPE char1,
        lv_b_selected TYPE boolean.

  FIELD-SYMBOLS: <it_out> TYPE STANDARD TABLE, <wa_out>, <value>.
  IF p_invtp = '2'.
    ASSIGN it_out_memi TO <it_out>.
  ELSEIF p_invtp = 1.
    ASSIGN it_out TO <it_out>.
  ELSEIF p_invtp = 3.
    ASSIGN it_out_mgv TO <it_out>.
** --> Nuss 09.2018
  ELSEIF p_invtp = 4.
    ASSIGN it_out_msb TO <it_out>.
** <-- Nuss 09.2018
  ENDIF.
  DATA: icon(4) TYPE c.

* Sicherheitsabfrage
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      defaultoption = 'Y'
      textline1     = TEXT-100
      textline2     = TEXT-101
      titel         = TEXT-t01
    IMPORTING
      answer        = l_answer.

  IF NOT l_answer CA 'jJyY'.
    EXIT.
  ENDIF.

  LOOP AT <it_out> ASSIGNING <wa_out>.

*   Zeile muss Markiert sein
    ASSIGN COMPONENT 'SEL' OF STRUCTURE <wa_out> TO <value>.
    CHECK <value> = 'X'.

    lv_b_selected = abap_true.

*   INT_INVOICE_NO muss gefüllt sein.
*   Bei mehreren Fehlern ist nur die erste Zeile zum Beleg gefüllt.
    ASSIGN COMPONENT 'INT_INV_DOC_NO' OF STRUCTURE <wa_out> TO <value>.
    CHECK <value> IS NOT INITIAL.
*   Status 'Neu' oder 'Zu Bearbeiten'
* Der Status des Avises steht immer in Feld INVOICE_STATUS UlHe
*    IF p_invtp = '2'.
*      ASSIGN COMPONENT 'STATUS' OF STRUCTURE <wa_out> TO <value>.
*    ELSE.
    ASSIGN COMPONENT 'INVOICE_STATUS' OF STRUCTURE <wa_out> TO <value>.
*    ENDIF.
    IF <value> NE '01' AND
       <value> NE '02'.
      CONTINUE.
    ENDIF.


    ASSIGN COMPONENT 'INT_INV_DOC_NO' OF STRUCTURE <wa_out> TO <value>.
    CREATE OBJECT l_inv_doc
      EXPORTING
        im_work_mode  = cl_inv_inv_remadv_doc=>co_wmode_change
        im_doc_number = <value>
      EXCEPTIONS
        OTHERS        = 1.

    IF sy-subrc <> 0.
      IF l_inv_doc IS NOT INITIAL.
        CALL METHOD l_inv_doc->close.
      ENDIF.
    ENDIF.

    CLEAR lt_return[].
    CALL METHOD l_inv_doc->change_document_status
      EXPORTING
        im_set_to_reset            = ' '
        im_set_to_released         = ' '
        im_set_to_finished         = 'X'
        im_set_to_to_be_complained = ' '
        im_reason_for_complain     = ' '
        im_set_to_to_be_reversed   = ' '
        im_reversal_rsn            = ' '
        im_commit_work             = 'X'
        im_automatic_change        = ' '
        im_create_reversal_doc     = ' '
      IMPORTING
        ex_return                  = lt_return.

    IF sy-subrc <> 0.
      icon = icon_led_red.
    ELSE.
      icon = icon_booking_stop.

      IF p_invtp = '2'.
*       "MEMIDOC CHANGE STATUS
        ASSIGN COMPONENT 'DOC_ID' OF STRUCTURE <wa_out> TO <value>.

        DATA ls_memidoc_u TYPE /idxmm/memidoc.
        DATA lt_memidoc_u TYPE /idxmm/t_memi_doc.
        DATA lr_memidoc TYPE REF TO /idxmm/cl_memi_document_db.
        CREATE OBJECT lr_memidoc.
        SELECT SINGLE * FROM /idxmm/memidoc INTO ls_memidoc_u WHERE doc_id = <value>.

*       nur setzen wenn Status nicht über Cust ausgeschlossen
        SELECT COUNT( * ) FROM /adesso/fi_remad
               WHERE negrem_option    = 'BEENDE_REMADV'
               AND   negrem_category  = 'MEMI_DOC_STATUS'
               AND   negrem_field     = 'EXCLUDE'
               AND   negrem_value     = ls_memidoc_u-doc_status.
        IF sy-subrc = 0.
*         Status ausgeschlossen, nix machen
        ELSE.
          ls_memidoc_u-doc_status = '77'.
          APPEND ls_memidoc_u TO lt_memidoc_u.
*        TRY.
          CALL METHOD /idxmm/cl_memi_document_db=>update
            EXPORTING
*             iv_simulate   =
              it_doc_update = lt_memidoc_u.
*         CATCH /idxmm/cx_bo_error .
*        ENDTRY.

        ENDIF.
      ENDIF.
    ENDIF.
    ASSIGN COMPONENT 'INT_INV_DOC_NO' OF STRUCTURE <wa_out> TO <value>.
    PERFORM set_process_state_all USING icon <value>.

  ENDLOOP.

  IF lv_b_selected EQ abap_false.
    MESSAGE e000(e4) WITH 'Bitte selektieren Sie einen Datensatz.'.
    EXIT.
  ENDIF.


ENDFORM.                    " BEENDE_REMADV


*&---------------------------------------------------------------------*
*&      Form  SELEKTIONSBILD_SPEICHERN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM selektionsbild_speichern .

  LOOP AT s_aggr.
    rspar_line-selname = 'S_AGGR'.
    rspar_line-kind = 'S'.
    rspar_line-sign = s_rece-sign.
    rspar_line-option = s_rece-option.
    rspar_line-low = s_rece-low.
    rspar_line-high = s_rece-high.
    APPEND rspar_line TO rspar_tab.
    CLEAR rspar_line.
  ENDLOOP.

  LOOP AT s_rece.
    rspar_line-selname = 'S_RECE'.
    rspar_line-kind = 'S'.
    rspar_line-sign = s_rece-sign.
    rspar_line-option = s_rece-option.
    rspar_line-low = s_rece-low.
    rspar_line-high = s_rece-high.
    APPEND rspar_line TO rspar_tab.
    CLEAR rspar_line.
  ENDLOOP.

  LOOP AT s_send.
    rspar_line-selname = 'S_SEND'.
    rspar_line-kind = 'S'.
    rspar_line-sign = s_send-sign.
    rspar_line-option = s_send-option.
    rspar_line-low = s_send-low.
    rspar_line-high = s_send-high.
    APPEND rspar_line TO rspar_tab.
    CLEAR rspar_line.
  ENDLOOP.

  LOOP AT s_insta.
    rspar_line-selname = 'S_INSTA'.
    rspar_line-kind = 'S'.
    rspar_line-sign = s_insta-sign.
    rspar_line-option = s_insta-option.
    rspar_line-low = s_insta-low.
    rspar_line-high = s_insta-high.
    APPEND rspar_line TO rspar_tab.
    CLEAR rspar_line.
  ENDLOOP.

  LOOP AT s_dtrec.
    rspar_line-selname = 'S_DTREC'.
    rspar_line-kind = 'S'.
    rspar_line-sign = s_dtrec-sign.
    rspar_line-option = s_dtrec-option.
    rspar_line-low = s_dtrec-low.
    rspar_line-high = s_dtrec-high.
    APPEND rspar_line TO rspar_tab.
    CLEAR rspar_line.
  ENDLOOP.

  LOOP AT s_intido.
    rspar_line-selname = 'S_INTIDO'.
    rspar_line-kind = 'S'.
    rspar_line-sign = s_intido-sign.
    rspar_line-option = s_intido-option.
    rspar_line-low = s_intido-low.
    rspar_line-high = s_intido-high.
    APPEND rspar_line TO rspar_tab.
    CLEAR rspar_line.
  ENDLOOP.

  LOOP AT s_extido.
    rspar_line-selname = 'S_EXTIDO'.
    rspar_line-kind = 'S'.
    rspar_line-sign = s_extido-sign.
    rspar_line-option = s_extido-option.
    rspar_line-low = s_extido-low.
    rspar_line-high = s_extido-high.
    APPEND rspar_line TO rspar_tab.
    CLEAR rspar_line.
  ENDLOOP.

  LOOP AT s_doctyp.
    rspar_line-selname = 'S_DOCTYP'.
    rspar_line-kind = 'S'.
    rspar_line-sign = s_doctyp-sign.
    rspar_line-option = s_doctyp-option.
    rspar_line-low = s_doctyp-low.
    rspar_line-high = s_doctyp-high.
    APPEND rspar_line TO rspar_tab.
    CLEAR rspar_line.
  ENDLOOP.

  LOOP AT s_idosta.
    rspar_line-selname = 'S_IDOSTA'.
    rspar_line-kind = 'S'.
    rspar_line-sign = s_idosta-sign.
    rspar_line-option = s_idosta-option.
    rspar_line-low = s_idosta-low.
    rspar_line-high = s_idosta-high.
    APPEND rspar_line TO rspar_tab.
    CLEAR rspar_line.
  ENDLOOP.

  LOOP AT s_dtpaym.
    rspar_line-selname = 'S_DTPAYM'.
    rspar_line-kind = 'S'.
    rspar_line-sign = s_dtpaym-sign.
    rspar_line-option = s_dtpaym-option.
    rspar_line-low = s_dtpaym-low.
    rspar_line-high = s_dtpaym-high.
    APPEND rspar_line TO rspar_tab.
    CLEAR rspar_line.
  ENDLOOP.

  LOOP AT s_invoda.
    rspar_line-selname = 'S_INVODA'.
    rspar_line-kind = 'S'.
    rspar_line-sign = s_invoda-sign.
    rspar_line-option = s_invoda-option.
    rspar_line-low = s_invoda-low.
    rspar_line-high = s_invoda-high.
    APPEND rspar_line TO rspar_tab.
    CLEAR rspar_line.
  ENDLOOP.

  LOOP AT s_rstgr.
    rspar_line-selname = 'S_RSTGR'.
    rspar_line-kind = 'S'.
    rspar_line-sign = s_rstgr-sign.
    rspar_line-option = s_rstgr-option.
    rspar_line-low = s_rstgr-low.
    rspar_line-high = s_rstgr-high.
    APPEND rspar_line TO rspar_tab.
    CLEAR rspar_line.
  ENDLOOP.

  LOOP AT s_owninv.
    rspar_line-selname = 'S_OWNINV'.
    rspar_line-kind = 'S'.
    rspar_line-sign = s_owninv-sign.
    rspar_line-option = s_owninv-option.
    rspar_line-low = s_owninv-low.
    rspar_line-high = s_owninv-high.
    APPEND rspar_line TO rspar_tab.
    CLEAR rspar_line.
  ENDLOOP.

*  --> Nuss 10.2017 Melo/Malo
*  LOOP AT s_extui.
*    rspar_line-selname = 'S_EXTUI'.
*    rspar_line-kind = 'S'.
*    rspar_line-sign = s_extui-sign.
*    rspar_line-option = s_extui-option.
*    rspar_line-low = s_extui-low.
*    rspar_line-high = s_extui-high.
*    APPEND rspar_line TO rspar_tab.
*    CLEAR rspar_line.
*  ENDLOOP.
* <-- Nuss 10.2017 Melo/Malo

  rspar_line-selname = 'P_VARI'.
  rspar_line-kind = 'P'.
  rspar_line-low = p_vari.
  APPEND rspar_line TO rspar_tab.
  CLEAR rspar_line.


ENDFORM.                    " SELEKTIONSBILD_SPEICHERN

*&---------------------------------------------------------------------*
*&      Form  SET_EVENTS
*&---------------------------------------------------------------------*
FORM set_events  CHANGING lt_event TYPE slis_t_event.

  DATA: ls_events TYPE slis_alv_event.
*
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'                      "#EC *
    EXPORTING
      i_list_type     = 4
    IMPORTING
      et_events       = lt_event
    EXCEPTIONS
      list_type_wrong = 1
      OTHERS          = 2.

  READ TABLE lt_event  WITH KEY name = slis_ev_top_of_page
                         INTO ls_events.
  IF sy-subrc = 0.
    MOVE slis_ev_top_of_page TO ls_events-form.
    MODIFY lt_event FROM ls_events INDEX sy-tabix.
  ENDIF.

ENDFORM.                    " SET_EVENTS

*&---------------------------------------------------------------------*
*&      Form  top_of_list
*&---------------------------------------------------------------------*
FORM top_of_page .                                          "#EC *

  CLEAR:gs_listheader.
  REFRESH gt_listheader.

  WRITE x_ctrem TO c_lines.
  CLEAR: gs_listheader.
  gs_listheader-typ  = 'S'.
  gs_listheader-key  = 'Anzahl REMADVs:'.
  CONCATENATE c_lines 'selektiert'
              INTO gs_listheader-info
              SEPARATED BY space..
  APPEND gs_listheader TO gt_listheader.
  IF  p_invtp = 1..
    DESCRIBE TABLE it_out LINES x_lines.
    WRITE x_lines TO c_lines.
  ELSEIF p_invtp = 2.                                         "Nuss 09.2018
    DESCRIBE TABLE it_out_memi LINES x_lines.
    WRITE x_lines TO c_lines.
* --> Nuss 09.2018
  ELSEIF p_invtp = 3.
    DESCRIBE TABLE it_out_mgv LINES x_lines.
    WRITE x_lines TO c_lines.
  ELSEIF p_invtp = 4.
    DESCRIBE TABLE it_out_msb LINES x_lines.
    WRITE x_lines TO c_lines.
* <-- Nuss 09.2018
  ENDIF.

  CLEAR:gs_listheader.
  gs_listheader-typ  = 'S'.

*  gs_listheader-key  = 'Anzahl REMADVs:'.
  gs_listheader-key  = 'Anzahl Zeilen:'.

  CONCATENATE c_lines 'selektiert'
              INTO gs_listheader-info
              SEPARATED BY space..
  APPEND gs_listheader TO gt_listheader.


  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = gt_listheader.


ENDFORM.                    " handle_event_top_of_page


*&---------------------------------------------------------------------*
*&      Form  CANCEL_MGV
*&---------------------------------------------------------------------*
FORM cancel_mgv.
  DATA: lv_b_selected TYPE boolean.
  DATA: lv_transaction TYPE  /adesso/fi_neg_remadv_val.
  DATA: lv_reason TYPE  /adesso/fi_neg_remadv_val.
  CLEAR t_sel_ea15.
  LOOP AT it_out_mgv INTO wa_out_mgv.
*   Zeile muss Markiert sein

    CHECK wa_out_mgv-sel = 'X'.
    lv_b_selected = abap_true.

    CLEAR w_sel_ea15.
    w_sel_ea15-selname = 'BDOCNO'.
    w_sel_ea15-kind    = 'S'.
    w_sel_ea15-sign    = 'I'..
    w_sel_ea15-option  = 'EQ'.
    w_sel_ea15-low     = wa_out_mgv-billdocno.
    SELECT COUNT(*) FROM dfkkinvbill_h WHERE billdocno = wa_out_mgv-billdocno AND simulated = 'X'.
    IF sy-subrc = 0.
      MESSAGE 'Stornieren von Simulierten Belegen nicht möglich.' TYPE 'E'.
    ELSE.
      APPEND w_sel_ea15 TO t_sel_ea15.
    ENDIF.

  ENDLOOP.
  "Transaktion aus dem Customizing holen. Standart = FKKINVBILL_REV_S
  "Außerdem Standart Stornogrund aus dem Customizing
  DATA: lv_b_selscreen TYPE boolean.
  lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'CANCEL_MGV_DISP'
                                                    iv_category = 'BDC_END'
                                                    iv_field    = 'SELSCREEN'
                                                    iv_id       = '1'
                                          RECEIVING rv_value = lv_b_selscreen
                                         ).
  CLEAR lv_transaction.
  lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'CANCEL_MGV'
                                                    iv_category = 'BDC_END'
                                                    iv_field    = 'TRANSACTION'
                                                    iv_id       = '1'
                                          RECEIVING rv_value = lv_transaction
                                         ).
*  lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'CANCEL_REASON_MGV'
*                                                    iv_category = 'BDC_END'
*                                                    iv_field    = 'TRANSACTION'
*                                                    iv_id       = '1'
*                                          RECEIVING rv_value = lv_reason
*                                         ).
  "Methode nicht verwendet, da CONVERSION_EXIT_ALPHA_OUTPUT nicht benutzt werden darf
  SELECT SINGLE negrem_value
  INTO lv_reason
  FROM /adesso/fi_remad
  WHERE negrem_option    EQ 'CANCEL_REASON_MGV'
    AND negrem_category  EQ 'BDC_END'
    AND negrem_field     EQ 'TRANSACTION'
   AND negrem_id        EQ '1'.

  CLEAR w_sel_ea15.
  w_sel_ea15-selname = 'REASON'.
  w_sel_ea15-kind    = 'C'.
  w_sel_ea15-low     = lv_reason.
  APPEND w_sel_ea15 TO t_sel_ea15.


  IF lv_transaction IS INITIAL.
    MESSAGE e000(e4) WITH 'Für den Aufruf zur Prozessierung des Belegs wurde keine Transaktion hinterlegt.'.
    EXIT.
  ENDIF.
  IF lv_b_selscreen EQ abap_false.
    SUBMIT (lv_transaction)
      WITH SELECTION-TABLE t_sel_ea15
      AND RETURN.
  ELSE.
    SUBMIT (lv_transaction)
      WITH SELECTION-TABLE t_sel_ea15
      VIA SELECTION-SCREEN
      AND RETURN.
  ENDIF.

  LOOP AT it_out_mgv INTO wa_out_mgv.

*   Zeile muss Markiert sein
*    check wa_out-xselp = 'X'.
    CHECK wa_out_mgv-sel = 'X'.

    DATA: icon(4) TYPE c.
    icon  = icon_storno.

    DATA ls_dfkkinvbill_h TYPE dfkkinvbill_h.
*   Belegkopf selektieren
    SELECT SINGLE *  FROM dfkkinvbill_h INTO ls_dfkkinvbill_h WHERE billdocno = wa_out_mgv-billdocno .


    IF ls_dfkkinvbill_h-reversaldoc IS INITIAL
       OR sy-subrc <> 0.
      icon = icon_led_red.
    ENDIF.

    wa_out_mgv-cancel_state = icon.

*   Daten in interne Tabelle für Ausgabe schreiben
    MODIFY it_out_mgv FROM wa_out_mgv.

  ENDLOOP.


ENDFORM.                    " CANCEL_PRINTDOC


*&---------------------------------------------------------------------*
*&      Form  CANCEL_PRINTDOC
*&---------------------------------------------------------------------*
FORM cancel_printdoc .

  DATA: h_opbel       TYPE erdk-opbel,
        lv_b_selected TYPE boolean.
  DATA: lv_transaction TYPE  /adesso/fi_neg_remadv_val.
  FIELD-SYMBOLS: <it_out> TYPE STANDARD TABLE, <wa_out>, <value>.
  IF p_invtp = '2'.
    ASSIGN it_out_memi TO <it_out>.
* --> Nuss 09.2018
  ELSEIF p_invtp = '4'.
*    ASSIGN it_out_msb TO <it_out>.    "Nuss 09.2018-2
    EXIT.                              "Nuss 09.2018
* <-- Nuss 09.2018
  ELSE.
    ASSIGN it_out TO <it_out>.
  ENDIF.
  REFRESH t_sel_ea15.

  CLEAR w_sel_ea15.
  w_sel_ea15-selname = 'AUGBD'.
  w_sel_ea15-kind    = 'P'.
  w_sel_ea15-low     = sy-datum.
  APPEND w_sel_ea15 TO t_sel_ea15.

  CLEAR w_sel_ea15.
  w_sel_ea15-selname = 'BLART'.
  w_sel_ea15-kind    = 'P'.
*  w_sel_ea15-low     = 'FS'.            "nicht BAS
  w_sel_ea15-low     = 'ST'.           "BAS
  APPEND w_sel_ea15 TO t_sel_ea15.

  CLEAR w_sel_ea15.
  w_sel_ea15-selname = 'ABP_SAVE'.
  w_sel_ea15-kind    = 'P'.
  w_sel_ea15-low     = 'X'.
  APPEND w_sel_ea15 TO t_sel_ea15.



  LOOP AT <it_out> ASSIGNING <wa_out>.

*   Zeile muss Markiert sein
    ASSIGN COMPONENT 'SEL' OF STRUCTURE <wa_out> TO <value>.
    CHECK <value> = 'X'.
    lv_b_selected = abap_true.
    IF p_invtp = '2'.
      ASSIGN COMPONENT 'ERCHCOPBEL' OF STRUCTURE <wa_out> TO <value>.
    ELSE.
      ASSIGN COMPONENT 'OWN_INVOICE_NO' OF STRUCTURE <wa_out> TO <value>.
    ENDIF.
    IF <value> CO ' 0123456789'.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <value>
        IMPORTING
          output = h_opbel.
    ELSE.
      h_opbel = <value>+3.
    ENDIF.

    CLEAR w_sel_ea15.
    w_sel_ea15-selname = 'OPBEL'.
    w_sel_ea15-kind    = 'S'.
    w_sel_ea15-sign    = 'I'..
    w_sel_ea15-option  = 'EQ'.
    w_sel_ea15-low     = h_opbel.
    SELECT COUNT(*) FROM erdk WHERE opbel = h_opbel AND simulated = 'X'.
    IF sy-subrc = 0.
      MESSAGE 'Stornieren von Simulierten Belegen nicht möglich.' TYPE 'E'.
    ELSE.
      APPEND w_sel_ea15 TO t_sel_ea15.
    ENDIF.
  ENDLOOP.

  IF lv_b_selected EQ abap_false.
    MESSAGE e000(e4) WITH 'Bitte selektieren Sie eine Beleg.'.
    EXIT.
  ENDIF.


  DATA: lv_b_selscreen TYPE boolean.
  lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'CANCEL'
                                                    iv_category = 'BDC_END'
                                                    iv_field    = 'SELSCREEN'
                                                    iv_id       = '1'
                                          RECEIVING rv_value = lv_b_selscreen
                                         ).
  CLEAR lv_transaction.
  lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'CANCEL'
                                                    iv_category = 'BDC_END'
                                                    iv_field    = 'TRANSACTION'
                                                    iv_id       = '1'
                                          RECEIVING rv_value = lv_transaction
                                         ).
  IF lv_transaction IS INITIAL.
    MESSAGE e000(e4) WITH 'Für den Aufruf zur Prozessierung des Belegs wurde keine Transaktion hinterlegt.'.
    EXIT.
  ENDIF.
  IF lv_b_selscreen EQ abap_false.
    SUBMIT (lv_transaction)
      WITH SELECTION-TABLE t_sel_ea15
      AND RETURN.
  ELSE.
    SUBMIT (lv_transaction)
      WITH SELECTION-TABLE t_sel_ea15
      VIA SELECTION-SCREEN
      AND RETURN.
  ENDIF.

* Nach Änderung der Belege müssen die Daten im Datensatz für
* die Anzeige aktualisiert werden
  DATA: wa_erdk TYPE erdk.
  LOOP AT <it_out> ASSIGNING <wa_out>.

*   Zeile muss Markiert sein
*    check wa_out-xselp = 'X'.

    ASSIGN COMPONENT 'SEL' OF STRUCTURE <wa_out> TO <value>.
    CHECK <value> = 'X'.

    DATA: icon(4) TYPE c.
    icon  = icon_storno.
    IF p_invtp = '2'.
      ASSIGN COMPONENT 'ERCHCOPBEL' OF STRUCTURE <wa_out> TO <value>.
    ELSE.
      ASSIGN COMPONENT 'OWN_INVOICE_NO' OF STRUCTURE <wa_out> TO <value>.
    ENDIF.
    IF  <value> CO ' 0123456789'.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <value>
        IMPORTING
          output = h_opbel.
    ELSE.
      h_opbel =  <value>+3.
    ENDIF.


*   Belegkopf selektieren
    SELECT   SINGLE * FROM erdk INTO wa_erdk
      WHERE erdk~opbel EQ h_opbel.


    IF wa_erdk-stokz IS INITIAL
       OR sy-subrc <> 0.
      icon = icon_led_red.
    ENDIF.
    ASSIGN COMPONENT 'CANCEL_STATE' OF STRUCTURE <wa_out> TO <value>.
    IF sy-subrc = 0.
      <value> = icon.
    ENDIF.
*   Daten in interne Tabelle für Ausgabe schreiben
    MODIFY <it_out>  FROM <wa_out>.

  ENDLOOP.



*  submit zisu_negative_remadv_netz "VIA SELECTION-SCREEN
*                                   with selection-table rspar_tab.

ENDFORM.                    " CANCEL_PRINTDOC

*&---------------------------------------------------------------------*
*&      Form  CANCEL_PRINTDOC
*&---------------------------------------------------------------------*
FORM cancel_memidoc .

  DATA: h_opbel       TYPE erdk-opbel,
        lv_b_selected TYPE boolean.
  DATA: lv_transaction TYPE  /adesso/fi_neg_remadv_val.

  REFRESH t_sel_ea15.

*
  CLEAR w_sel_ea15.
  w_sel_ea15-selname = 'P_TEST'.
  w_sel_ea15-kind    = 'P'.
  w_sel_ea15-low     = ' '.
  APPEND w_sel_ea15 TO t_sel_ea15.



  LOOP AT it_out_memi INTO wa_out_memi.

*   Zeile muss Markiert sein
    CHECK wa_out_memi-sel = 'X'.
    lv_b_selected = abap_true.

    IF wa_out_memi-doc_id CO ' 0123456789'.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = wa_out_memi-doc_id
        IMPORTING
          output = h_opbel.
    ELSE.
      h_opbel = wa_out_memi-own_invoice_no+3.
    ENDIF.

    CLEAR w_sel_ea15.
    w_sel_ea15-selname = 'S_DOC_ID'.
    w_sel_ea15-kind    = 'S'.
    w_sel_ea15-sign    = 'I'..
    w_sel_ea15-option  = 'EQ'.
    w_sel_ea15-low     = h_opbel.
    SELECT COUNT(*) FROM erdk WHERE opbel = h_opbel AND simulated = 'X'.
    IF sy-subrc = 0.
      MESSAGE 'Stornieren von Simulierten Belegen nicht möglich.' TYPE 'E'.
    ELSE.
      APPEND w_sel_ea15 TO t_sel_ea15.
    ENDIF.


  ENDLOOP.

  IF lv_b_selected EQ abap_false.
    MESSAGE e000(e4) WITH 'Bitte selektieren Sie eine Beleg.'.
    EXIT.
  ENDIF.


  DATA: lv_b_selscreen TYPE boolean.
  lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'CANCEL_M'
                                                    iv_category = 'BDC_END'
                                                    iv_field    = 'SELSCREEN'
                                                    iv_id       = '1'
                                          RECEIVING rv_value = lv_b_selscreen
                                         ).
  CLEAR lv_transaction.
  lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'CANCEL_M'
                                                    iv_category = 'BDC_END'
                                                    iv_field    = 'TRANSACTION'
                                                    iv_id       = '1'
                                          RECEIVING rv_value = lv_transaction
                                         ).
  IF lv_transaction IS INITIAL.
    MESSAGE e000(e4) WITH 'Für den Aufruf zur Prozessierung des Belegs wurde keine Transaktion hinterlegt.'.
    EXIT.
  ENDIF.
  IF lv_b_selscreen EQ abap_false.
    SUBMIT (lv_transaction)
      WITH SELECTION-TABLE t_sel_ea15
      AND RETURN.
  ELSE.
    SUBMIT (lv_transaction)
      WITH SELECTION-TABLE t_sel_ea15
      VIA SELECTION-SCREEN
      AND RETURN.
  ENDIF.

* Nach Änderung der Belege müssen die Daten im Datensatz für
* die Anzeige aktualisiert werden
  DATA: wa_erdk TYPE erdk.
  LOOP AT it_out_memi INTO wa_out_memi.

*   Zeile muss Markiert sein
*    check wa_out-xselp = 'X'.
    CHECK wa_out_memi-sel = 'X'.

    DATA: icon(4) TYPE c.
    icon  = icon_storno.

    DATA lv_reversalkx  TYPE /idxmm/de_reversal.
    CLEAR lv_reversalkx.
    SELECT SINGLE reversal FROM /idxmm/memidoc INTO lv_reversalkx WHERE doc_id = wa_out_memi-doc_id.
    IF lv_reversalkx = 'X'.
      wa_out_memi-cancel_state_mm = icon.
    ENDIF.
*   Daten in interne Tabelle für Ausgabe schreiben
    MODIFY it_out_memi FROM wa_out_memi.

  ENDLOOP.



*  submit zisu_negative_remadv_netz "VIA SELECTION-SCREEN
*                                   with selection-table rspar_tab.

ENDFORM.                    " CANCEL_PRINTDOC

*&---------------------------------------------------------------------*
*&      Form  SEND_SEL_DATA_VIA_MAIL
*&---------------------------------------------------------------------*
*       Die selektierten Daten sollen per Mail verschickt werden
*----------------------------------------------------------------------*
FORM send_sel_data_via_mail.

* Klasse für Mailversand instanzieren
  DATA cl_sendmail TYPE REF TO lcl_send_mail.
  CREATE OBJECT cl_sendmail.

* Klasse für Kontakt instanzieren
  DATA cl_bcontact TYPE REF TO lcl_bcontact.
  CREATE OBJECT cl_bcontact.

  DATA: BEGIN OF s_cont_data,
          gpart           TYPE but000-partner,
          vkont           TYPE fkkvkp-vkont,                 "Nuss 08.02.2018
          int_inv_doc_no  TYPE tinv_inv_doc-int_inv_doc_no,
          int_inv_line_no TYPE inv_int_inv_line_no,
        END OF s_cont_data.

  DATA: it_cont       LIKE STANDARD TABLE OF s_cont_data,
        wa_cont       LIKE s_cont_data,
        lv_b_selected TYPE boolean.

  DATA: h_int_inv_doc_no TYPE tinv_inv_doc-int_inv_doc_no.
  IF p_invtp = '2'.
    LOOP AT it_out_memi INTO wa_out_memi.

*   Zeile muss Markiert sein
*    check wa_out-xselp = 'X'.
      CHECK wa_out_memi-sel IS NOT INITIAL.
      lv_b_selected = abap_true.

      cl_sendmail->set_content( EXPORTING iv_invoice_date   = wa_out_memi-invoice_date
                                          iv_ext_invoice_no = wa_out_memi-ext_invoice_no
                                          iv_crossref_no    = wa_out_memi-own_invoice_no
                                          iv_rstgr          = wa_out_memi-rstgr
                                          iv_text           = wa_out_memi-text
**                                          iv_ext_ui         = wa_out_memi-ext_ui                "Nuss 10.2017 Bis 01.02.2018
**                                          iv_ext_ui         = wa_out_memi-ext_ui_melo            "Nuss 10.2017 Bis 01.02.2018
                                          iv_ext_ui          = wa_out_memi-ext_ui                      "Nuss 01.02.2018
                                          iv_ext_ui_me       = wa_out_memi-ext_ui_melo                 "Nuss 01.02.2018
                                          iv_free_text5     = wa_out_memi-free_text5 ).

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = wa_out_memi-int_inv_doc_no
        IMPORTING
          output = h_int_inv_doc_no.

      wa_cont-int_inv_doc_no = wa_out_memi-int_inv_doc_no.
      wa_cont-gpart = wa_out_memi-suppl_bupa.
      wa_cont-vkont = wa_out_memi-vkont.                       "Nuss 08.02.2018
      wa_cont-int_inv_line_no = wa_out_memi-int_inv_line_no.

      APPEND wa_cont TO it_cont.

    ENDLOOP.
  ELSEIF p_invtp = 1.
    LOOP AT it_out INTO wa_out.

*   Zeile muss Markiert sein
*    check wa_out-xselp = 'X'.
      CHECK wa_out-sel IS NOT INITIAL.
      lv_b_selected = abap_true.

      cl_sendmail->set_content( EXPORTING iv_invoice_date   = wa_out-invoice_date
                                          iv_ext_invoice_no = wa_out-ext_invoice_no
                                          iv_crossref_no    = wa_out-own_invoice_no
                                          iv_rstgr          = wa_out-rstgr
                                          iv_text           = wa_out-text
*                                          iv_ext_ui         = wa_out-ext_ui               "Nuss 10.2017 bis 01.02.2018
*                                          iv_ext_ui         = wa_out-ext_ui_melo           "Nuss 10.2017 bis 01.02.2018
                                          iv_ext_ui          = wa_out-ext_ui               "Nuss 01.02.2018
                                          iv_ext_ui_me       = wa_out-ext_ui_melo          "Nuss 01.02.2018
                                          iv_free_text5     = wa_out-free_text5 ).

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = wa_out-int_inv_doc_no
        IMPORTING
          output = h_int_inv_doc_no.

      wa_cont-int_inv_doc_no = wa_out-int_inv_doc_no.
      wa_cont-gpart = wa_out-gpart.
      wa_cont-vkont = wa_out-vkont.                       "Nuss 08.02.2018
      wa_cont-int_inv_line_no = wa_out-int_inv_line_no.

      APPEND wa_cont TO it_cont.

    ENDLOOP.
  ELSEIF p_invtp = 3.
    LOOP AT it_out_mgv INTO wa_out_mgv.

*   Zeile muss Markiert sein
*    check wa_out-xselp = 'X'.
      CHECK wa_out_mgv-sel IS NOT INITIAL.
      lv_b_selected = abap_true.

      cl_sendmail->set_content( EXPORTING iv_invoice_date   = wa_out_mgv-invoice_date
                                          iv_ext_invoice_no = wa_out_mgv-ext_invoice_no
                                          iv_crossref_no    = wa_out_mgv-own_invoice_no
                                          iv_rstgr          = wa_out_mgv-rstgr
                                          iv_text           = wa_out_mgv-text
**                                          iv_ext_ui         = wa_out_mgv-ext_ui             "Nuss 10.2017 bis 01.02.2018
*                                          iv_ext_ui         = wa_out_mgv-ext_ui_melo         "Nuss 10.2017 bis 01.02.2018
                                          iv_ext_ui          = wa_out_mgv-ext_ui              "Nuss 01.02.2018
                                          iv_ext_ui_me       = wa_out_mgv-ext_ui_melo         "Nuss 01.02.2018
                                          iv_free_text5     = wa_out_mgv-free_text5 ).

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = wa_out_mgv-int_inv_doc_no
        IMPORTING
          output = h_int_inv_doc_no.

      wa_cont-int_inv_doc_no = wa_out_mgv-int_inv_doc_no.
      wa_cont-gpart = wa_out_mgv-gpart.
      wa_cont-vkont = wa_out_mgv-vkont.                           "Nuss 08.02.2018
      wa_cont-int_inv_line_no = wa_out_mgv-int_inv_line_no.

      APPEND wa_cont TO it_cont.

    ENDLOOP.
* --> Nuss 09.2018
  ELSEIF p_invtp = 4.
    LOOP AT it_out_msb INTO wa_out_msb.

*   Zeile muss Markiert sein
*    check wa_out-xselp = 'X'.
      CHECK wa_out_msb-sel IS NOT INITIAL.
      lv_b_selected = abap_true.

      cl_sendmail->set_content( EXPORTING iv_invoice_date   = wa_out_msb-invoice_date
                                          iv_ext_invoice_no = wa_out_msb-ext_invoice_no
                                          iv_crossref_no    = wa_out_msb-own_invoice_no
                                          iv_rstgr          = wa_out_msb-rstgr
                                          iv_text           = wa_out_msb-text
                                          iv_ext_ui          = wa_out_msb-ext_ui
                                          iv_ext_ui_me       = wa_out_msb-ext_ui_melo
                                          iv_free_text5     = wa_out_msb-free_text5 ).

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = wa_out_msb-int_inv_doc_no
        IMPORTING
          output = h_int_inv_doc_no.

      wa_cont-int_inv_doc_no = wa_out_msb-int_inv_doc_no.
      wa_cont-gpart = wa_out_msb-gpart.
      wa_cont-vkont = wa_out_msb-vkont.                       "Nuss 08.02.2018
      wa_cont-int_inv_line_no = wa_out_msb-int_inv_line_no.

      APPEND wa_cont TO it_cont.

    ENDLOOP.
* <-- Nuss 09.2018

  ENDIF.

  IF lv_b_selected EQ abap_false.
    MESSAGE e000(e4) WITH 'Bitte selektieren Sie einen Datensatz.'.
    EXIT.
  ENDIF.

* Mail versenden
  SELECT COUNT( * ) FROM /adesso/fi_remad WHERE negrem_option = 'MAILLOTUS' AND negrem_value = 'X'.
  IF sy-subrc <> 0.
    cl_sendmail->send_mail( ).
  ELSE.
    cl_sendmail->send_lotus_mail( ).
  ENDIF.



  DATA: lv_answer(1)     TYPE c,
        button_text1(16) TYPE c,
        icon_button1(30) TYPE c,
        button_text2(16) TYPE c,
        icon_button2(30) TYPE c.

  button_text1    = 'Ja'(021).
  button_text2    = 'Nein'(022).

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'E-Mail Versand'
      text_question         = 'Ist die E-Mail verschickt worden?'
      text_button_1         = button_text1
      text_button_2         = button_text2
      default_button        = '1'
      display_cancel_button = ' '
      start_column          = 25
      start_row             = 6
    IMPORTING
      answer                = lv_answer.
  IF sy-subrc <> 0.
  ENDIF.

  DATA: x_tdname TYPE stxh-tdname.

  IF sy-subrc EQ 0 AND lv_answer EQ 1.
    LOOP AT it_cont INTO wa_cont.

      cl_bcontact->set_contact( EXPORTING iv_partner  = wa_cont-gpart
                                          iv_vkont    = wa_cont-vkont                     "Nuss 08.02.2018
                                          iv_int_inv_doc_no = wa_cont-int_inv_doc_no
                                          iv_int_inv_line_no = wa_cont-int_inv_line_no ).

    ENDLOOP.
  ENDIF.

  DATA: icon(4) TYPE c.
  icon = icon_envelope_closed.
  IF sy-subrc <> 0 OR lv_answer EQ 2.
    icon = icon_led_red.
  ENDIF.

  IF lv_answer EQ 1.
    IF p_invtp = '2'.
      LOOP AT it_out_memi INTO wa_out_memi.

*     Zeile muss Markiert sein
        CHECK wa_out_memi-sel = 'X'.

*    Markierung initialisieren,
*    Mails sollen nicht mehrfach versendet werden
        CLEAR wa_out_memi-sel.

        wa_out_memi-comm_state = icon.
*      wa_out-cancel_state = ICON_STORNO.
        MODIFY it_out_memi FROM wa_out_memi.

      ENDLOOP.
    ELSEIF p_invtp = 1.
      LOOP AT it_out INTO wa_out.

*     Zeile muss Markiert sein
        CHECK wa_out-sel = 'X'.

*    Markierung initialisieren,
*    Mails sollen nicht mehrfach versendet werden
        CLEAR wa_out-sel.

        wa_out-comm_state = icon.
*      wa_out-cancel_state = ICON_STORNO.
        MODIFY it_out FROM wa_out.

      ENDLOOP.
    ELSEIF p_invtp = 3.
      LOOP AT it_out_mgv INTO wa_out_mgv.

*     Zeile muss Markiert sein
        CHECK wa_out_mgv-sel = 'X'.

*    Markierung initialisieren,
*    Mails sollen nicht mehrfach versendet werden
        CLEAR wa_out_mgv-sel.

        wa_out_mgv-comm_state = icon.
*      wa_out-cancel_state = ICON_STORNO.
        MODIFY it_out_mgv FROM wa_out_mgv.

      ENDLOOP.
* --> Nuss 09.2018
    ELSEIF p_invtp = 4.
      LOOP AT it_out_msb INTO wa_out_msb.

*     Zeile muss Markiert sein
        CHECK wa_out_msb-sel = 'X'.

*    Markierung initialisieren,
*    Mails sollen nicht mehrfach versendet werden
        CLEAR wa_out_msb-sel.

        wa_out_msb-comm_state = icon.
*      wa_out-cancel_state = ICON_STORNO.
        MODIFY it_out_msb FROM wa_out_msb.

      ENDLOOP.
* <-- Nuss 09.2018
    ENDIF.
  ENDIF.

ENDFORM.                    "SEND_SEL_DATA_VIA_MAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->WA_OUT     text
*----------------------------------------------------------------------*
FORM sel_bcontact USING wa_out LIKE wa_out.

  DATA: lv_bc          TYPE REF TO lcl_bcontact,
        lv_b_contexist TYPE boolean.

  CREATE OBJECT lv_bc.
  lv_bc->check_for_contact( EXPORTING iv_gpart          = wa_out-gpart
                                      iv_int_inv_doc_no = wa_out-int_inv_doc_no
                            RECEIVING rv_b_contexist    = lv_b_contexist
                           ).

  IF lv_b_contexist EQ abap_true.
    wa_out-comm_state = icon_envelope_closed.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->WA_OUT     text
*----------------------------------------------------------------------*
FORM sel_bcontact_memi USING wa_out_memi LIKE wa_out_memi.

  DATA: lv_bc          TYPE REF TO lcl_bcontact,
        lv_b_contexist TYPE boolean.

  CREATE OBJECT lv_bc.
  lv_bc->check_for_contact( EXPORTING iv_gpart          = wa_out_memi-suppl_bupa
                                      iv_int_inv_doc_no = wa_out_memi-int_inv_doc_no
                            RECEIVING rv_b_contexist    = lv_b_contexist
                           ).

  IF lv_b_contexist EQ abap_true.
    wa_out_memi-comm_state = icon_envelope_closed.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->WA_OUT     text
*----------------------------------------------------------------------*
FORM sel_bcontact_mgv USING wa_out LIKE wa_out_mgv.

  DATA: lv_bc          TYPE REF TO lcl_bcontact,
        lv_b_contexist TYPE boolean.

  CREATE OBJECT lv_bc.
  lv_bc->check_for_contact( EXPORTING iv_gpart          = wa_out-gpart
                                      iv_int_inv_doc_no = wa_out-int_inv_doc_no
                            RECEIVING rv_b_contexist    = lv_b_contexist
                           ).

  IF lv_b_contexist EQ abap_true.
    wa_out-comm_state = icon_envelope_closed.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  sel_bcontact
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM sel_bcontact_old .

  DATA:  wa_head TYPE thead.
  DATA:  lv_text TYPE TABLE OF tline.
  DATA:  lv_tmp_line TYPE tline.

  SELECT * FROM bcont
     INTO CORRESPONDING FIELDS OF TABLE t_bcontact
     FOR ALL ENTRIES IN t_dfkkthi_op
     WHERE partner = t_dfkkthi_op-gpart
      AND cclass   = s_cust_cont-class
      AND f_coming = s_cust_cont-direction
      AND ctype    = s_cust_cont-type.

  LOOP AT t_bcontact INTO wa_bcontact.
    CLEAR wa_stxh.
    SELECT SINGLE * FROM stxh
           INTO wa_stxh
           WHERE tdobject = 'BCONT'
           AND   tdname   = wa_bcontact-bpcontact
           AND   tdid     = 'BCON'.

    IF sy-subrc = 0 AND
       wa_stxh-tdtitle IS NOT INITIAL.
      wa_bcontact-int_inv_doc_no = wa_stxh-tdtitle.
      MODIFY t_bcontact FROM wa_bcontact.
    ELSE.
      CLEAR wa_head.
      wa_head-tdname   = wa_bcontact-bpcontact.
      wa_head-tdid     = 'BCON'.
      wa_head-tdspras  = 'D'.
      wa_head-tdobject = 'BCONT'.

      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          id                      = wa_head-tdid
          language                = wa_head-tdspras
          name                    = wa_head-tdname
          object                  = wa_head-tdobject
        TABLES
          lines                   = lv_text
        EXCEPTIONS
          id                      = 1
          language                = 2
          name                    = 3
          not_found               = 4
          object                  = 5
          reference_check         = 6
          wrong_access_to_archive = 7
          OTHERS                  = 8.
      IF sy-subrc <> 0.
*        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      LOOP AT lv_text INTO lv_tmp_line.

        wa_bcontact-int_inv_doc_no = lv_tmp_line-tdline.
        MODIFY t_bcontact FROM wa_bcontact.

      ENDLOOP.
    ENDIF.
  ENDLOOP.

  SORT t_bcontact BY int_inv_doc_no.

ENDFORM.                    "sel_bcontact

*&---------------------------------------------------------------------*
*&      Form  sel_bcontact_memi
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM sel_bcontact_old_memi .

  DATA:  wa_head TYPE thead.
  DATA:  lv_text TYPE TABLE OF tline.
  DATA:  lv_tmp_line TYPE tline.

  SELECT * FROM bcont
     INTO CORRESPONDING FIELDS OF TABLE t_bcontact
*     FOR ALL ENTRIES IN t_dfkkthi_op
     WHERE partner = wa_out_memi-suppl_bupa
      AND cclass   = s_cust_cont-class
      AND f_coming = s_cust_cont-direction
      AND ctype    = s_cust_cont-type.

  LOOP AT t_bcontact INTO wa_bcontact.
    CLEAR wa_stxh.
    SELECT SINGLE * FROM stxh
           INTO wa_stxh
           WHERE tdobject = 'BCONT'
           AND   tdname   = wa_bcontact-bpcontact
           AND   tdid     = 'BCON'.

    IF sy-subrc = 0 AND
       wa_stxh-tdtitle IS NOT INITIAL.
      wa_bcontact-int_inv_doc_no = wa_stxh-tdtitle.
      MODIFY t_bcontact FROM wa_bcontact.
    ELSE.
      CLEAR wa_head.
      wa_head-tdname   = wa_bcontact-bpcontact.
      wa_head-tdid     = 'BCON'.
      wa_head-tdspras  = 'D'.
      wa_head-tdobject = 'BCONT'.

      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          id                      = wa_head-tdid
          language                = wa_head-tdspras
          name                    = wa_head-tdname
          object                  = wa_head-tdobject
        TABLES
          lines                   = lv_text
        EXCEPTIONS
          id                      = 1
          language                = 2
          name                    = 3
          not_found               = 4
          object                  = 5
          reference_check         = 6
          wrong_access_to_archive = 7
          OTHERS                  = 8.
      IF sy-subrc <> 0.
*        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      LOOP AT lv_text INTO lv_tmp_line.

        wa_bcontact-int_inv_doc_no = lv_tmp_line-tdline.
        MODIFY t_bcontact FROM wa_bcontact.

      ENDLOOP.
    ENDIF.
  ENDLOOP.

  SORT t_bcontact BY int_inv_doc_no.

ENDFORM.                    "sel_bcontact

*&---------------------------------------------------------------------*
*&      Form  sel_invstorno
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->WA_OUT     text
*----------------------------------------------------------------------*
FORM sel_invstorno_memi USING wa_out LIKE wa_out_memi.

  DATA: wa_erdk TYPE erdk,
        h_opbel TYPE erdk-opbel.

  DATA: icon(4) TYPE c.
  icon  = icon_storno.

* Für MeMi-Belege steht die Druckbelegnummer der NN-Rechnung im Feld erchcopbel
*  IF wa_ederegswitchsyst-xcrn = 'X'.
*    h_opbel = wa_out-own_invoice_no+3.
*  ELSE.
*    h_opbel = wa_out-own_invoice_no.
*  ENDIF.
*
*
*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*    EXPORTING
*      input  = h_opbel
*    IMPORTING
*      output = h_opbel.

*   Belegkopf selektieren
  SELECT SINGLE * FROM erdk INTO wa_erdk
*    WHERE erdk~opbel EQ h_opbel.
    WHERE erdk~opbel EQ wa_out_memi-erchcopbel.


  IF wa_erdk-stokz IS NOT INITIAL.
    wa_out_memi-inf_invoice_cancel = icon_storno.
  ENDIF.

  SELECT COUNT(*) FROM /idxmm/memidoc WHERE doc_id = wa_out-doc_id AND reversal = 'X'.
  IF sy-subrc = 0.
    wa_out_memi-cancel_state_mm = icon_storno.
  ENDIF.

ENDFORM.                    "sel_invstorno
*&---------------------------------------------------------------------*
*&      Form  sel_invstorno
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->WA_OUT     text
*----------------------------------------------------------------------*
FORM sel_invstorno USING wa_out LIKE wa_out.

  DATA: wa_erdk TYPE erdk,
        h_opbel TYPE erdk-opbel.

  DATA: icon(4) TYPE c.
  icon  = icon_storno.

  IF wa_ederegswitchsyst-xcrn = 'X'.
    h_opbel = wa_out-own_invoice_no+3.
  ELSE.
    h_opbel = wa_out-own_invoice_no.
  ENDIF.


  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = h_opbel
    IMPORTING
      output = h_opbel.

*   Belegkopf selektieren
  SELECT SINGLE * FROM erdk INTO wa_erdk
    WHERE erdk~opbel EQ h_opbel.

  IF wa_erdk-abrvorg EQ '06'.                        "manuelle Abrechnung
    wa_out-zisumabr = 'X'.
  ENDIF.


  IF wa_erdk-stokz IS NOT INITIAL.
    wa_out-inf_invoice_cancel = icon_storno.
  ENDIF.


ENDFORM.                    "sel_invstorno

*&---------------------------------------------------------------------*
*&      Form  get_cic_frame_for_user
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IV_SCREEN_NO  text
*----------------------------------------------------------------------*
FORM get_cic_frame_for_user CHANGING iv_screen_no TYPE cicfwscreenno.

  DATA: it_cic_prof TYPE TABLE OF cicprofiles.

  CALL FUNCTION 'CIC_GET_ORG_PROFILES'
    EXPORTING
      agent                 = sy-uname
    TABLES
      profile_list          = it_cic_prof
    EXCEPTIONS
      call_center_not_found = 1
      agent_group_not_found = 2
      profiles_not_found    = 3
      no_hr_record          = 4
      cancel                = 5
      OTHERS                = 6.
  IF sy-subrc <> 0.
    MESSAGE e000(e4) WITH 'CIC-Profil konnte nicht gelesen werden(1).'.
    EXIT.
  ENDIF.

* existiert mind. 1 Eintrag
  IF lines( it_cic_prof ) EQ 0.
    MESSAGE e000(e4) WITH 'CIC-Profil konnte nicht gelesen werden(2).'.
    EXIT.
  ENDIF.

* 1. Datensatz aus Tabelle zuweisen
  FIELD-SYMBOLS: <fs_prof> TYPE cicprofiles.
  READ TABLE it_cic_prof ASSIGNING <fs_prof> INDEX 1.
* Fehlerprüfung
  IF <fs_prof> IS NOT ASSIGNED.
    MESSAGE e000(e4) WITH 'CIC-Profil konnte nicht gelesen werden(3).'.
    EXIT.
  ENDIF.

* Passendes CIC-Profil lesen
* Konfiguration auslesen um die DYNPRO-Nr zu gelangen
  SELECT SINGLE frame_screen
    INTO iv_screen_no
    FROM cicprofile
      INNER JOIN cicconf
        ON cicconf~mandt = cicprofile~mandt
        AND cicconf~frame_conf = cicprofile~framework_id
    WHERE cicprofile~mandt = sy-mandt
    AND cicprofile~cicprof = <fs_prof>-cicprof.

  IF iv_screen_no IS INITIAL.
    MESSAGE e000(e4) WITH 'CIC-Profil konnte nicht gelesen werden(4).'.
  ENDIF.

ENDFORM.                    "get_cic_frame_for_user

*&---------------------------------------------------------------------*
*&      Form  GET_CUSTOMIZING
*&---------------------------------------------------------------------*
FORM get_customizing .

  SELECT * FROM /adesso/fi_remad
           INTO TABLE t_cust_remadv.

  LOOP AT t_cust_remadv
    INTO wa_cust_remadv
    WHERE negrem_option   = 'CONTACT'
    AND   negrem_category = 'CIC_BC'
    AND   negrem_id       = '1'.

    CASE wa_cust_remadv-negrem_field.
      WHEN 'CLASS'.
        s_cust_cont-class = wa_cust_remadv-negrem_value.
      WHEN 'ACTIVITY'.
        s_cust_cont-activity = wa_cust_remadv-negrem_value.
      WHEN 'TYPE'.
        s_cust_cont-type = wa_cust_remadv-negrem_value.
      WHEN 'DIRECTION'.
        s_cust_cont-direction = wa_cust_remadv-negrem_value.
      WHEN 'INFO'.
        s_cust_cont-custinfo = wa_cust_remadv-negrem_value.
    ENDCASE.

  ENDLOOP.

  SELECT SINGLE * FROM v_username
         INTO s_username
         WHERE bname = sy-uname.

  IF sy-subrc NE 0.
    s_username-name_text = sy-uname.
  ENDIF.

ENDFORM.                    " GET_CUSTOMIZING

*&---------------------------------------------------------------------*
*&      Form  GET_CONSTANTS
*&---------------------------------------------------------------------*
FORM GET_CONSTANTS.
    " get current application
    CALL FUNCTION 'FKK_GET_APPLICATION'
      IMPORTING
        e_applk          = c_applk
      EXCEPTIONS
        no_appl_selected = 1
        OTHERS           = 2.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_PROCESS_STATE_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ICON  text
*----------------------------------------------------------------------*
FORM set_process_state_all  USING    p_icon
                                     p_int_inv_docno.

  DATA: invoice_status LIKE wa_out-invoice_status,
        inv_doc_status LIKE wa_out-inv_doc_status.

  FIELD-SYMBOLS: <fs_wa_out> LIKE wa_out.
  FIELD-SYMBOLS: <fs_wa_out_memi> LIKE wa_out_memi.


  SELECT SINGLE invoice_status inv_doc_status
    FROM tinv_inv_head
    INNER JOIN tinv_inv_doc
    ON tinv_inv_head~int_inv_no = tinv_inv_doc~int_inv_doc_no
    INTO (invoice_status, inv_doc_status)
    WHERE tinv_inv_doc~int_inv_doc_no = p_int_inv_docno.
  IF p_invtp <> '2'.
    LOOP AT it_out ASSIGNING <fs_wa_out> WHERE int_inv_doc_no EQ p_int_inv_docno.

      CHECK <fs_wa_out> IS ASSIGNED.

      MOVE invoice_status   TO <fs_wa_out>-invoice_status.
      MOVE inv_doc_status   TO <fs_wa_out>-inv_doc_status.
      <fs_wa_out>-process_state = p_icon.
*   Daten in interne Tabelle für Ausgabe schreiben
      MODIFY it_out FROM <fs_wa_out>.

    ENDLOOP.
  ELSE.
    LOOP AT it_out_memi ASSIGNING <fs_wa_out_memi> WHERE int_inv_doc_no EQ p_int_inv_docno.

      CHECK <fs_wa_out_memi> IS ASSIGNED.

      MOVE invoice_status   TO <fs_wa_out_memi>-invoice_status.
      MOVE inv_doc_status   TO <fs_wa_out_memi>-inv_doc_status.
      <fs_wa_out_memi>-process_state = p_icon.
*   Daten in interne Tabelle für Ausgabe schreiben
      MODIFY it_out_memi FROM <fs_wa_out_memi>.

    ENDLOOP.
  ENDIF.

ENDFORM.                    " SET_PROCESS_STATE_ALL


*&---------------------------------------------------------------------*
*&      Form  INT_NOTICE
*&---------------------------------------------------------------------*
FORM int_notice USING fp_value    TYPE slis_selfield-value
                      fp_tabindex TYPE slis_selfield-tabindex.

  DATA: l_answer TYPE char1.

  REFRESH t_sval.

  CLEAR w_sval.
  w_sval-tabname   = '/IDEXGE/REJ_NOTI'.
  w_sval-fieldname = 'FREE_TEXT5'.
  w_sval-value     = fp_value.
  w_sval-fieldtext = 'Notiz'.
  APPEND w_sval TO t_sval.

  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
      popup_title     = 'Interne Notiz'
      start_column    = '5'
      start_row       = '5'
    IMPORTING
      returncode      = l_answer
    TABLES
      fields          = t_sval
    EXCEPTIONS
      error_in_fields = 1
      OTHERS          = 2.

  CHECK sy-subrc = 0.
  CHECK l_answer = space.

  READ TABLE t_sval INTO w_sval INDEX 1.
  IF p_invtp = '1'.
* read data from database /idexge/rej_noti
    SELECT SINGLE * FROM /idexge/rej_noti INTO wa_rej_noti
       WHERE int_inv_doc_no = wa_out-int_inv_doc_no
       AND   int_inv_line_no = wa_out-int_inv_line_no.

    IF sy-subrc <> 0.
      wa_rej_noti-int_inv_doc_no = wa_out-int_inv_doc_no.
      wa_rej_noti-int_inv_line_no = wa_out-int_inv_line_no.
      wa_rej_noti-free_text5 = w_sval-value.
      INSERT INTO /idexge/rej_noti VALUES wa_rej_noti.
    ELSE.
      wa_rej_noti-free_text5 = w_sval-value.
      MODIFY /idexge/rej_noti FROM wa_rej_noti.
    ENDIF.

    IF sy-subrc = 0.
      wa_out-free_text5 = w_sval-value.
      COMMIT WORK.
    ENDIF.

    MODIFY it_out FROM wa_out INDEX fp_tabindex.
  ELSEIF p_invtp = 2.
* read data from database /idexge/rej_noti
    SELECT SINGLE * FROM /idexge/rej_noti INTO wa_rej_noti
       WHERE int_inv_doc_no = wa_out_memi-int_inv_doc_no
       AND   int_inv_line_no = wa_out_memi-int_inv_line_no.

    IF sy-subrc <> 0.
      wa_rej_noti-int_inv_doc_no = wa_out_memi-int_inv_doc_no.
      wa_rej_noti-int_inv_line_no = wa_out_memi-int_inv_line_no.
      wa_rej_noti-free_text5 = w_sval-value.
      INSERT INTO /idexge/rej_noti VALUES wa_rej_noti.
    ELSE.
      wa_rej_noti-free_text5 = w_sval-value.
      MODIFY /idexge/rej_noti FROM wa_rej_noti.
    ENDIF.

    IF sy-subrc = 0.
      wa_out_memi-free_text5 = w_sval-value.
      COMMIT WORK.
    ENDIF.

    MODIFY it_out_memi FROM wa_out_memi INDEX fp_tabindex.
  ELSEIF p_invtp = 3.
* read data from database /idexge/rej_noti
    SELECT SINGLE * FROM /idexge/rej_noti INTO wa_rej_noti
       WHERE int_inv_doc_no = wa_out_mgv-int_inv_doc_no
       AND   int_inv_line_no = wa_out_mgv-int_inv_line_no.

    IF sy-subrc <> 0.
      wa_rej_noti-int_inv_doc_no = wa_out_mgv-int_inv_doc_no.
      wa_rej_noti-int_inv_line_no = wa_out_mgv-int_inv_line_no.
      wa_rej_noti-free_text5 = w_sval-value.
      INSERT INTO /idexge/rej_noti VALUES wa_rej_noti.
    ELSE.
      wa_rej_noti-free_text5 = w_sval-value.
      MODIFY /idexge/rej_noti FROM wa_rej_noti.
    ENDIF.

    IF sy-subrc = 0.
      wa_out_mgv-free_text5 = w_sval-value.
      COMMIT WORK.
    ENDIF.

    MODIFY it_out_mgv FROM wa_out_mgv INDEX fp_tabindex.
** --> Nuss 09.2018
* read data from database /idexge/rej_noti
  ELSEIF p_invtp = 4.
    SELECT SINGLE * FROM /idexge/rej_noti INTO wa_rej_noti
       WHERE int_inv_doc_no = wa_out_msb-int_inv_doc_no
       AND   int_inv_line_no = wa_out_msb-int_inv_line_no.

    IF sy-subrc <> 0.
      wa_rej_noti-int_inv_doc_no = wa_out_msb-int_inv_doc_no.
      wa_rej_noti-int_inv_line_no = wa_out_msb-int_inv_line_no.
      wa_rej_noti-free_text5 = w_sval-value.
      INSERT INTO /idexge/rej_noti VALUES wa_rej_noti.
    ELSE.
      wa_rej_noti-free_text5 = w_sval-value.
      MODIFY /idexge/rej_noti FROM wa_rej_noti.
    ENDIF.

    IF sy-subrc = 0.
      wa_out_msb-free_text5 = w_sval-value.
      COMMIT WORK.
    ENDIF.

    MODIFY it_out_msb FROM wa_out_msb INDEX fp_tabindex.
* <-- Nuss 09.2018
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  INT_NOTICE_EDIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_RS_SELFIELD_VALUE  text
*      -->P_RS_SELFIELD_TABINDEX  text
*----------------------------------------------------------------------*
FORM int_notice_edit  USING    fp_value    TYPE slis_selfield-value
                               fp_tabindex TYPE slis_selfield-tabindex.

  DATA:  lx_header TYPE thead.
  DATA:  tx_lines TYPE STANDARD TABLE OF tline.

  DATA: help_line TYPE tline.
  DATA: length TYPE i.

  lx_header-tdobject = co_object.
  lx_header-tdid = co_id.
  lx_header-tdspras = sy-langu.
  lx_header-tdlinesize = '132'.
  IF p_invtp = 2.
    CONCATENATE wa_out_memi-int_inv_doc_no
                '_'
                wa_out_memi-int_inv_line_no
                INTO lx_header-tdname.
  ELSEIF p_invtp = 1.
    CONCATENATE wa_out-int_inv_doc_no
                '_'
                wa_out-int_inv_line_no
                INTO lx_header-tdname.
  ELSEIF p_invtp = 3.
    CONCATENATE wa_out_mgv-int_inv_doc_no
                '_'
                wa_out_mgv-int_inv_line_no
                INTO lx_header-tdname.
* --> Nuss 09.2018
  ELSEIF p_invtp = 4.
    CONCATENATE wa_out_msb-int_inv_doc_no
            '_'
            wa_out_msb-int_inv_line_no
            INTO lx_header-tdname.
* <-- Nuss 09.2018
  ENDIF.
  CLEAR tx_lines.
* Text (falls bereits vorhanden) einlesen und in Itab stellen
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
*     CLIENT                  = SY-MANDT
      id                      = lx_header-tdid
      language                = lx_header-tdspras
      name                    = lx_header-tdname
      object                  = lx_header-tdobject
*     ARCHIVE_HANDLE          = 0
*     LOCAL_CAT               = ' '
*   IMPORTING
*     HEADER                  =
*     OLD_LINE_COUNTER        =
    TABLES
      lines                   = tx_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc <> 0.
*  Wenn noch kein Text im Texteditor vorhanden ist, dann Prüfen, ob ein alter Text
*  hinterlegt wurde. Dieser wird an der 132. Stelle geteilt und eine zweite Zeile
* aufgemacht.
    IF sy-subrc = 4.
      IF p_invtp = 2.
        IF wa_out_memi-free_text5 IS NOT INITIAL.
          length = strlen( wa_out_memi-free_text5 ).
          IF length GT 132.
            help_line-tdline = wa_out_memi-free_text5(132).
            APPEND help_line TO tx_lines.
            help_line-tdline = wa_out_memi-free_text5+132.
            APPEND help_line TO tx_lines.
          ELSE.
            help_line-tdline = wa_out_memi-free_text5.
            APPEND help_line TO tx_lines.
          ENDIF.
        ENDIF.
      ELSEIF p_invtp = 1.
        IF wa_out-free_text5 IS NOT INITIAL.
          length = strlen( wa_out-free_text5 ).
          IF length GT 132.
            help_line-tdline = wa_out-free_text5(132).
            APPEND help_line TO tx_lines.
            help_line-tdline = wa_out-free_text5+132.
            APPEND help_line TO tx_lines.
          ELSE.
            help_line-tdline = wa_out-free_text5.
            APPEND help_line TO tx_lines.
          ENDIF.
        ENDIF.
      ELSEIF p_invtp = 3.
        IF wa_out_mgv-free_text5 IS NOT INITIAL.
          length = strlen( wa_out_mgv-free_text5 ).
          IF length GT 132.
            help_line-tdline = wa_out_mgv-free_text5(132).
            APPEND help_line TO tx_lines.
            help_line-tdline = wa_out_mgv-free_text5+132.
            APPEND help_line TO tx_lines.
          ELSE.
            help_line-tdline = wa_out_mgv-free_text5.
            APPEND help_line TO tx_lines.
          ENDIF.
        ENDIF.
* --> Nuss 09.2018
      ELSEIF p_invtp = 4.
        IF wa_out_msb-free_text5 IS NOT INITIAL.
          length = strlen( wa_out_msb-free_text5 ).
          IF length GT 132.
            help_line-tdline = wa_out_msb-free_text5(132).
            APPEND help_line TO tx_lines.
            help_line-tdline = wa_out_msb-free_text5+132.
            APPEND help_line TO tx_lines.
          ELSE.
            help_line-tdline = wa_out_msb-free_text5.
            APPEND help_line TO tx_lines.
          ENDIF.
        ENDIF.
      ENDIF.
* <-- Nuss 09.2018
    ELSE.
* Implement suitable error handling here
    ENDIF.
  ENDIF.


* Text Editieren
  CALL FUNCTION 'EDIT_TEXT'
    EXPORTING
*     DISPLAY       = ' '
*     EDITOR_TITLE  = ' '
      header        = lx_header
*     PAGE          = ' '
*     WINDOW        = ' '
*     SAVE          = 'X'
*     LINE_EDITOR   = ' '
*     CONTROL       = ' '
*     PROGRAM       = ' '
*     LOCAL_CAT     = ' '
* IMPORTING
*     FUNCTION      =
*     NEWHEADER     =
*     RESULT        =
    TABLES
      lines         = tx_lines
    EXCEPTIONS
      id            = 1
      language      = 2
      linesize      = 3
      name          = 4
      object        = 5
      textformat    = 6
      communication = 7
      OTHERS        = 8.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  READ TABLE tx_lines INTO help_line INDEX 1.

  IF sy-subrc = 0.

    IF p_invtp = 2.
      wa_out_memi-free_text5 = help_line.
      MODIFY it_out_memi FROM wa_out_memi INDEX fp_tabindex.
    ELSEIF p_invtp = 1.
      wa_out-free_text5 = help_line.
      MODIFY it_out FROM wa_out INDEX fp_tabindex.
    ELSEIF p_invtp = 3.
      wa_out-free_text5 = help_line.
      MODIFY it_out FROM wa_out INDEX fp_tabindex.
* --> Nuss 09.2018
    ELSEIF p_invtp = 4.
      wa_out_msb-free_text5 = help_line.
      MODIFY it_out_msb FROM wa_out_msb INDEX fp_tabindex.
* <-- Nuss 09.2018
    ENDIF.
  ENDIF.

ENDFORM.                    " INT_NOTICE_EDIT


*&---------------------------------------------------------------------*
*&      Form  GET_FREE_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_RS_SELFIELD_VALUE  text
*      -->P_RS_SELFIELD_TABINDEX  text
*----------------------------------------------------------------------*
FORM get_free_text  USING    fp_value    TYPE slis_selfield-value
                             fp_tabindex TYPE slis_selfield-tabindex.

** --> Nuss 06.02.2018 Neues Coding
  DATA: lt_data TYPE /idexge/tt_doc_adddata,
        ls_data TYPE /idexge/doc_adddata.

  DATA: ls_text TYPE /idexge/rej_noti.
  DATA: lt_text TYPE TABLE OF /idexge/rej_noti.

  IF p_invtp = '1'.                                               "Nuss 12.02.2018

    SELECT * FROM /idexge/rej_noti INTO TABLE lt_text
      WHERE int_inv_doc_no = wa_out-int_inv_doc_no.

    ls_data-structure = '/IDEXGE/REJ_NOTI'.
    GET REFERENCE OF lt_text  INTO ls_data-adddata_ref.
    APPEND ls_data TO lt_data.

    CALL METHOD /idexge/cl_inv_adddata=>action_idex_alv_rej_noti
      EXPORTING
*       iv_edit_mode   =
        it_adddata     = lt_data
        iv_doc_no      = wa_out-int_inv_doc_no
*       iv_line_no     = '1'
*       iv_must_flag   =
      EXCEPTIONS
        error_occurred = 1
        edit_cancel    = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
*         Implement suitable error handling here
    ENDIF.

* --> Nuss 12.02.2018
  ELSEIF p_invtp = '2'.

    SELECT * FROM /idexge/rej_noti INTO TABLE lt_text
      WHERE int_inv_doc_no = wa_out_memi-int_inv_doc_no.

    ls_data-structure = '/IDEXGE/REJ_NOTI'.
    GET REFERENCE OF lt_text  INTO ls_data-adddata_ref.
    APPEND ls_data TO lt_data.

    CALL METHOD /idexge/cl_inv_adddata=>action_idex_alv_rej_noti
      EXPORTING
*       iv_edit_mode   =
        it_adddata     = lt_data
        iv_doc_no      = wa_out_memi-int_inv_doc_no
*       iv_line_no     = '1'
*       iv_must_flag   =
      EXCEPTIONS
        error_occurred = 1
        edit_cancel    = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
*         Implement suitable error handling here
    ENDIF.

  ELSEIF p_invtp = '3'.

    SELECT * FROM /idexge/rej_noti INTO TABLE lt_text
     WHERE int_inv_doc_no = wa_out_mgv-int_inv_doc_no.

    ls_data-structure = '/IDEXGE/REJ_NOTI'.
    GET REFERENCE OF lt_text  INTO ls_data-adddata_ref.
    APPEND ls_data TO lt_data.

    CALL METHOD /idexge/cl_inv_adddata=>action_idex_alv_rej_noti
      EXPORTING
*       iv_edit_mode   =
        it_adddata     = lt_data
        iv_doc_no      = wa_out_mgv-int_inv_doc_no
*       iv_line_no     = '1'
*       iv_must_flag   =
      EXCEPTIONS
        error_occurred = 1
        edit_cancel    = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
*         Implement suitable error handling here
    ENDIF.
**  <-- Nuss 12.02.2018
** --> Nuss 09.2018
  ELSEIF p_invtp = '4'.

    SELECT * FROM /idexge/rej_noti INTO TABLE lt_text
      WHERE int_inv_doc_no = wa_out_msb-int_inv_doc_no.

    ls_data-structure = '/IDEXGE/REJ_NOTI'.
    GET REFERENCE OF lt_text  INTO ls_data-adddata_ref.
    APPEND ls_data TO lt_data.

    CALL METHOD /idexge/cl_inv_adddata=>action_idex_alv_rej_noti
      EXPORTING
*       iv_edit_mode   =
        it_adddata     = lt_data
        iv_doc_no      = wa_out_msb-int_inv_doc_no
*       iv_line_no     = '1'
*       iv_must_flag   =
      EXCEPTIONS
        error_occurred = 1
        edit_cancel    = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
*         Implement suitable error handling here
    ENDIF.
** <-- Nuss 09.2018

  ENDIF.


*  DATA: wa_rej_noti TYPE /idexge/rej_noti.
*
** Sruktur für Ausgabezeile
*  DATA: BEGIN OF wa_line.
*      INCLUDE STRUCTURE /idexge/rej_noti.
*  DATA: box.
*  DATA: END OF wa_line.
*  DATA: it_line LIKE STANDARD TABLE OF wa_line.
*
**  Layout
*  DATA: ls_layout   TYPE slis_layout_alv.
*
** Feldkatalog
*  DATA: lt_fieldcat TYPE slis_t_fieldcat_alv.
*  DATA: ls_fieldcat TYPE slis_fieldcat_alv.
*
*
*
*
** Layout aufbauen
*  ls_layout-zebra             = 'X'.
*  ls_layout-colwidth_optimize = 'X'.
*  ls_layout-box_fieldname     = g_boxnam.
*
*
*  IF p_invtp = 2.
*
*    READ TABLE it_out_memi INTO wa_out_memi INDEX fp_tabindex.
*    IF wa_out_memi-int_inv_line_no IS INITIAL.
*      wa_out_memi-int_inv_line_no = '00000001'.
*    ENDIF.
*    SELECT SINGLE * FROM /idexge/rej_noti INTO wa_line
*      WHERE int_inv_doc_no = wa_out_memi-int_inv_doc_no
*        AND int_inv_line_no = wa_out_memi-int_inv_line_no.
*
*    APPEND wa_line TO it_line.
*
*  ELSEIF p_invtp = 1.
*
*
*    READ TABLE it_out INTO wa_out INDEX fp_tabindex.
*    IF wa_out-int_inv_line_no IS INITIAL.
*      wa_out-int_inv_line_no = '00000001'.
*    ENDIF.
*    SELECT SINGLE * FROM /idexge/rej_noti INTO wa_line
*      WHERE int_inv_doc_no = wa_out-int_inv_doc_no
*        AND int_inv_line_no = wa_out-int_inv_line_no.
*
*    APPEND wa_line TO it_line.
*
*  ELSEIF p_invtp = 3.
*
*
*    READ TABLE it_out_mgv INTO wa_out_mgv INDEX fp_tabindex.
*    IF wa_out_mgv-int_inv_line_no IS INITIAL.
*      wa_out_mgv-int_inv_line_no = '00000001'.
*    ENDIF.
*    SELECT SINGLE * FROM /idexge/rej_noti INTO wa_line
*      WHERE int_inv_doc_no = wa_out_mgv-int_inv_doc_no
*        AND int_inv_line_no = wa_out_mgv-int_inv_line_no.
*
*    APPEND wa_line TO it_line.
*
*  ENDIF.
*
**   Feldkatalog aufbauen
*  CLEAR: lt_fieldcat, ls_fieldcat.
*
**Interne Nummer des Rechnungsbelegs/Avisbelegs
*  CLEAR ls_fieldcat.
*  ls_fieldcat-fieldname = 'INT_INV_DOC_NO'.
*  ls_fieldcat-tabname = 'IT_LINE'.
*  ls_fieldcat-ref_tabname = 'TINV_INV_DOC'.
*  APPEND ls_fieldcat TO lt_fieldcat.
*
**  zeilennummer /Avisbelegs
*  CLEAR ls_fieldcat.
*  ls_fieldcat-fieldname = 'INT_INV_LINE_NO'.
*  ls_fieldcat-tabname = 'IT_LINE'.
*  ls_fieldcat-ref_tabname = 'TINV_INV_LINE_A'.
*  APPEND ls_fieldcat TO lt_fieldcat.
*
**  Freitext1
*  CLEAR ls_fieldcat.
*  ls_fieldcat-fieldname = 'FREE_TEXT1'.
*  ls_fieldcat-tabname = 'IT_LINE'.
*  ls_fieldcat-seltext_m = 'Ablehnungstext 1'.
**  ls_fieldcat-ref_tabname = '/IDEXGE/REJ_NOTI'.
*  APPEND ls_fieldcat TO lt_fieldcat.
*
**  Freitext2
*  CLEAR ls_fieldcat.
*  ls_fieldcat-fieldname = 'FREE_TEXT2'.
*  ls_fieldcat-tabname = 'IT_LINE'.
*  ls_fieldcat-seltext_m = 'Ablehnungstext 2'.
**  ls_fieldcat-ref_tabname = '/IDEXGE/REJ_NOTI'.
*  APPEND ls_fieldcat TO lt_fieldcat.
*
**  Freitext3
*  CLEAR ls_fieldcat.
*  ls_fieldcat-fieldname = 'FREE_TEXT3'.
*  ls_fieldcat-tabname = 'IT_LINE'.
*  ls_fieldcat-seltext_m = 'Ablehnungstext 3'.
**  ls_fieldcat-ref_tabname = '/IDEXGE/REJ_NOTI'.
*  APPEND ls_fieldcat TO lt_fieldcat.
*
**  Freitext4
*  CLEAR ls_fieldcat.
*  ls_fieldcat-fieldname = 'FREE_TEXT4'.
*  ls_fieldcat-tabname = 'IT_LINE'.
*  ls_fieldcat-seltext_m = 'Ablehnungstext 4'.
**  ls_fieldcat-ref_tabname = '/IDEXGE/REJ_NOTI'.
*  APPEND ls_fieldcat TO lt_fieldcat.
*
**  Freitext5
*  CLEAR ls_fieldcat.
*  ls_fieldcat-fieldname = 'FREE_TEXT5'.
*  ls_fieldcat-tabname = 'IT_LINE'.
*  ls_fieldcat-seltext_m = 'Ablehnungstext 5'.
**  ls_fieldcat-ref_tabname = '/IDEXGE/REJ_NOTI'.
*
*  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
*    EXPORTING
**     I_INTERFACE_CHECK     = ' '
**     I_BYPASSING_BUFFER    = ' '
**     I_BUFFER_ACTIVE       = ' '
*      i_callback_program    = g_repid
**     i_callback_pf_status_set          = g_status
**     i_callback_user_command           = g_user_command
**     I_CALLBACK_TOP_OF_PAGE            = ' '
**     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
**     I_CALLBACK_HTML_END_OF_LIST       = ' '
**     i_structure_name      = '/IDEXGE/REJ_NOTI'
**     I_BACKGROUND_ID       = ' '
**     I_GRID_TITLE          =
**     I_GRID_SETTINGS       =
*      is_layout             = ls_layout
*      it_fieldcat           = lt_fieldcat
**     IT_SPECIAL_GROUPS     =
**     IT_SORT               =
**     IT_FILTER             =
**     IS_SEL_HIDE           =
*      i_default             = ' '
*      i_save                = ' '
**     IS_VARIANT            =
**     IT_EVENTS             =
**     IT_EVENT_EXIT         =
**     IS_PRINT              =
**     IS_REPREP_ID          =
*      i_screen_start_column = 10
*      i_screen_start_line   = 10
*      i_screen_end_column   = 150
*      i_screen_end_line     = 20
**     I_HTML_HEIGHT_TOP     = 0
**     I_HTML_HEIGHT_END     = 0
**     IT_ALV_GRAPHICS       =
**     IT_HYPERLINK          =
**     IT_ADD_FIELDCAT       =
**     IT_EXCEPT_QINFO       =
**     IR_SALV_FULLSCREEN_ADAPTER        =
**   IMPORTING
**     E_EXIT_CAUSED_BY_CALLER           =
**     ES_EXIT_CAUSED_BY_USER            =
*    TABLES
*      t_outtab              = it_line
*    EXCEPTIONS
*      program_error         = 1
*      OTHERS                = 2.
*  IF sy-subrc <> 0.
** Implement suitable error handling here
*  ENDIF.

* <-- Nuss 06.02.2018


ENDFORM.                    " GET_FREE_TEXT

*&---------------------------------------------------------------------*
*&      Form  DATEN_SELEKTIEREN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM daten_selektieren_memi_old .

  DATA lv_invtype TYPE tinv_inv_head-invoice_type.
  lv_invtype = co_memitype.

* Texte zum Rückstellungsgrund
  SELECT * FROM tinv_c_adj_rsnt
           INTO TABLE t_inv_c_adj_rsnt
           WHERE spras = sy-langu.

* Hilfsrange Sender auf Selektionsrange übertragen
  IF r_send[] IS NOT INITIAL AND s_send[] IS INITIAL.
    s_send[] = r_send[].
  ENDIF.

* Reklamationsavise
  SELECT a~int_inv_doc_no
         a~int_inv_no
         a~int_partner
         a~doc_type
         a~invoice_date
         a~date_of_payment
         a~inv_doc_status
         a~int_ident
         a~invoice_type
         a~int_sender
         a~int_receiver
         a~date_of_receipt
         a~invoice_status
         a~auth_grp
         a~ext_invoice_no
         a~inv_bulk_ref
         b~int_inv_line_no
         b~rstgr
         b~own_invoice_no
         b~betrw_req
         c~free_text1
         c~free_text5
    INTO CORRESPONDING FIELDS OF TABLE t_remadv
    FROM vinv_monitoring AS a
         INNER JOIN tinv_inv_line_a AS b
         ON b~int_inv_doc_no = a~int_inv_doc_no
         LEFT OUTER JOIN /idexge/rej_noti AS c
         ON  c~int_inv_doc_no  = b~int_inv_doc_no
         AND c~int_inv_line_no = b~int_inv_line_no
    WHERE a~int_sender IN s_send
      AND a~int_receiver IN s_rece
      AND a~invoice_type EQ lv_invtype
      AND a~date_of_receipt IN s_dtrec
      AND a~invoice_status IN s_insta
      AND a~int_inv_doc_no IN s_intido
      AND a~ext_invoice_no IN s_extido
      AND a~doc_type IN s_doctyp
      AND a~inv_doc_status IN s_idosta
      AND a~date_of_payment IN s_dtpaym
      AND a~invoice_date IN s_invoda
      AND b~line_type EQ co_linetype
      AND b~rstgr IN s_rstgr
      AND b~own_invoice_no IN s_owninv.

  SORT t_remadv.

* Überschreiben FREE_:TEXT5 aus Text-Editor
  IF t_remadv[] IS NOT INITIAL.
    LOOP AT t_remadv ASSIGNING <fs_remadv>.
      CLEAR gv_name.
      CONCATENATE <fs_remadv>-int_inv_doc_no
                  '_'
                  <fs_remadv>-int_inv_line_no
                  INTO gv_name.

      CLEAR xlines.
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
*         CLIENT                  = SY-MANDT
          id                      = co_id
          language                = sy-langu
          name                    = gv_name
          object                  = co_object
*         ARCHIVE_HANDLE          = 0
*         LOCAL_CAT               = ' '
*   IMPORTING
*         HEADER                  =
*         OLD_LINE_COUNTER        =
        TABLES
          lines                   = xlines
        EXCEPTIONS
          id                      = 1
          language                = 2
          name                    = 3
          not_found               = 4
          object                  = 5
          reference_check         = 6
          wrong_access_to_archive = 7
          OTHERS                  = 8.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      READ TABLE xlines INTO help_line INDEX 1.

      IF sy-subrc = 0.
        <fs_remadv>-free_text5 = help_line.
*    MODIFY it_out FROM wa_out INDEX fp_tabindex.
      ENDIF.

    ENDLOOP.
  ENDIF.

*  Crossreference und Externer Zählpunkt
  IF t_remadv[] IS NOT INITIAL.
    CLEAR t_crsrf_eui.
    SELECT a~int_crossrefno
           a~int_ui
           a~crossrefno
           a~crn_rev
           b~ext_ui
           b~dateto
      INTO CORRESPONDING FIELDS OF TABLE t_crsrf_eui
      FROM ecrossrefno AS a
           LEFT OUTER JOIN euitrans AS b
           ON b~int_ui = a~int_ui
      FOR ALL ENTRIES IN t_remadv
      WHERE ( a~crossrefno = t_remadv-own_invoice_no
      OR      a~crn_rev    = t_remadv-own_invoice_no ).

    SORT t_crsrf_eui BY int_crossrefno.

    DELETE t_crsrf_eui WHERE dateto NE '99991231'.

    DELETE ADJACENT DUPLICATES FROM t_crsrf_eui.

* Für den nächsten Zugriff auf Zahlungsavise besser nach crossrefno sortieren
* UH 19082016
*    SORT t_crsrf_eui BY int_crossrefno.
    SORT t_crsrf_eui BY crossrefno.

  ENDIF.

* Zahlungsavise
  IF t_crsrf_eui[] IS NOT INITIAL.

    SELECT a~own_invoice_no
           a~int_inv_doc_no
           c~invoice_status
      INTO CORRESPONDING FIELDS OF TABLE t_paym
      FROM tinv_inv_line_a AS a
           INNER JOIN tinv_inv_doc AS b
           ON b~int_inv_doc_no = a~int_inv_doc_no
           INNER JOIN tinv_inv_head AS c
           ON c~int_inv_no = b~int_inv_no
      FOR ALL ENTRIES IN t_crsrf_eui
      WHERE a~own_invoice_no = t_crsrf_eui-crossrefno
      AND   a~line_type      = co_linetype
      AND   b~doc_type       = co_docpaym
      AND   c~invoice_type   = co_invpaym.

* Zahlungavise zu stornierten Rechnungen gesondert betrachten
* UH 19082016
  ENDIF.


* Ist das Feld crn_rev nie gefüllt kommt es zum Laufzeitfehler
* da die komplette DB durchsucht wird
* daher vorher alle leeren crn_rev eliminieren
* UH 19082016

  t_crsrf_eu2[] = t_crsrf_eui[].

  SORT t_crsrf_eu2 BY crn_rev.
  DELETE t_crsrf_eu2 WHERE crn_rev = space.
  DELETE ADJACENT DUPLICATES FROM t_crsrf_eu2.

  IF t_crsrf_eu2[] IS NOT INITIAL.

    SELECT a~own_invoice_no
           a~int_inv_doc_no
           c~invoice_status
      APPENDING CORRESPONDING FIELDS OF TABLE t_paym
      FROM tinv_inv_line_a AS a
           INNER JOIN tinv_inv_doc AS b
           ON b~int_inv_doc_no = a~int_inv_doc_no
           INNER JOIN tinv_inv_head AS c
           ON c~int_inv_no = b~int_inv_no
      FOR ALL ENTRIES IN t_crsrf_eu2
      WHERE a~own_invoice_no = t_crsrf_eu2-crn_rev
      AND   a~line_type      = co_linetype
      AND   b~doc_type       = co_docpaym
      AND   c~invoice_type   = co_invpaym.

  ENDIF.

  SORT t_paym BY own_invoice_no.


*      wa_out_memi-crossrefno.
**  BCONT
*  IF t_dfkkthi_op[] IS NOT INITIAL.

*  ENDIF.

*  t_crsrf_eu2[] = t_crsrf_eui[].
  SORT t_crsrf_eui BY crossrefno.
  SORT t_crsrf_eu2 BY crn_rev.

  LOOP AT t_remadv ASSIGNING <fs_remadv>.

    AT NEW int_inv_doc_no.
      x_ctrem = x_ctrem + 1.
    ENDAT.

    CLEAR wa_out_memi.
    MOVE-CORRESPONDING <fs_remadv> TO wa_out_memi.

** Aggr. Vertragskonto ermitteln
    SELECT SINGLE a~vkont INTO wa_out_memi-aggvk
      FROM fkkvk AS a
       INNER JOIN fkkvkp AS b
         ON b~vkont = a~vkont
      INNER JOIN eservprovp AS c
        ON c~bpart = b~gpart
        WHERE c~serviceid = <fs_remadv>-int_sender
        AND a~vktyp IN r_vktyp.


** Text zum Rückstellungsgrund
    READ TABLE t_inv_c_adj_rsnt
         INTO  wa_inv_c_adj_rsnt
         WITH KEY rstgr = <fs_remadv>-rstgr
                  spras = sy-langu.
    IF sy-subrc = 0.
      wa_out_memi-text = wa_inv_c_adj_rsnt-text.
    ENDIF.

* Crosreferenz / Zählpunkt
    READ TABLE t_crsrf_eui
         ASSIGNING <fs_crsrf_eui>
         WITH KEY crossrefno = <fs_remadv>-own_invoice_no
         BINARY SEARCH.

    IF sy-subrc = 0 AND <fs_crsrf_eui> IS ASSIGNED.
      b_storno = abap_false.
      wa_out_memi-ext_ui         = <fs_crsrf_eui>-ext_ui.
      wa_out_memi-int_crossrefno = <fs_crsrf_eui>-int_crossrefno.
      wa_out_memi-crossrefno = <fs_crsrf_eui>-crossrefno.
    ELSE.
      READ TABLE t_crsrf_eu2
           ASSIGNING <fs_crsrf_eui>
           WITH KEY crn_rev = <fs_remadv>-own_invoice_no
           BINARY SEARCH.
      IF sy-subrc = 0 AND <fs_crsrf_eui> IS ASSIGNED.
        wa_out_memi-inf_invoice_cancel = icon_status_reverse.
        wa_out_memi-ext_ui         = <fs_crsrf_eui>-ext_ui.
        wa_out_memi-int_crossrefno = <fs_crsrf_eui>-int_crossrefno.
        wa_out_memi-crossrefno = <fs_crsrf_eui>-crossrefno.
        b_storno = abap_true.
      ENDIF.
    ENDIF.

    SELECT * FROM /idexge/rej_noti INTO wa_noti
      WHERE int_inv_doc_no = wa_out_memi-int_inv_doc_no.
      IF wa_noti-stat_remk(3) = '@0V'.
        wa_out_memi-line_state = icon_okay.
      ENDIF.
      EXIT.
    ENDSELECT.

    wa_out_memi-vkont = wa_out_memi-aggvk.
*    "  ENDIF.
*    CLEAR: lt_efindres ,ls_efindres.

*    CHECK wa_out_memi-ext_ui IN s_extui.                  "Nuss 10.2017 Melo/Malo
    CHECK wa_out_memi-int_crossrefno IS NOT INITIAL.

* Abrechnungsklasse ermitteln
    SELECT aklasse INTO wa_out_memi-aklasse
      FROM eanlh AS a
        INNER JOIN euiinstln AS b
        ON b~anlage = a~anlage
        INNER JOIN euitrans AS c
         ON c~int_ui = b~int_ui
      WHERE c~ext_ui = wa_out_memi-ext_ui
        AND c~dateto = '99991231'
        AND a~bis = '99991231'.
      EXIT.
    ENDSELECT.


    MOVE-CORRESPONDING <fs_remadv> TO wa_out_memi.
*   Zahlungsavis vorhanden?
    READ TABLE t_paym
         ASSIGNING <fs_paym>
         WITH KEY own_invoice_no = <fs_remadv>-own_invoice_no
         BINARY SEARCH.

    IF sy-subrc = 0 AND <fs_paym> IS ASSIGNED.
      wa_out_memi-paym_avis = <fs_paym>-int_inv_doc_no.
      wa_out_memi-paym_stat = <fs_paym>-invoice_status.
    ENDIF.


*    SELECT Memidoc
    SELECT SINGLE  * FROM /idxmm/memidoc INTO CORRESPONDING FIELDS OF  wa_out_memi WHERE
    crossrefno = wa_out_memi-crossrefno.

    PERFORM sel_bcontact_old_memi.
    READ TABLE t_bcontact
         WITH KEY int_inv_doc_no = <fs_remadv>-int_inv_doc_no
         TRANSPORTING NO FIELDS
         BINARY SEARCH.

    IF sy-subrc = 0.
      wa_out_memi-comm_state = icon_envelope_closed.
    ENDIF.

    SELECT SINGLE opbel FROM erchc  INTO wa_out_memi-erchcopbel WHERE belnr = wa_out_memi-trig_bill_doc_no.
    wa_out_memi-billable_item = wa_out_memi-doc_id.
    SELECT COUNT(*) FROM /adesso/remtext WHERE int_inv_doc_nr = wa_out_memi-int_inv_doc_no.
    IF sy-subrc = 0.
      wa_out_memi-text_vorhanden = 'X'.
    ELSE.
      wa_out_memi-text_vorhanden = ''.
    ENDIF.
    PERFORM sel_invstorno_memi USING wa_out_memi.
    PERFORM sel_bcontact_memi USING wa_out_memi.
    PERFORM get_locks_memi.
    APPEND wa_out_memi TO it_out_memi.
    CLEAR wa_out_memi.

  ENDLOOP.

ENDFORM.                    " DATEN_SELEKTIEREN
FORM daten_selektieren_memi .


  SELECT h~int_inv_no      h~invoice_type
         h~date_of_receipt h~invoice_status
         h~int_receiver    h~int_sender
         d~int_inv_doc_no  d~ext_invoice_no
         d~doc_type        d~inv_doc_status
         d~date_of_payment d~invoice_date
    INTO CORRESPONDING FIELDS OF wa_inv_head_doc
    FROM tinv_inv_head AS h
      INNER JOIN tinv_inv_doc AS d
      ON h~int_inv_no EQ d~int_inv_no
    WHERE h~int_sender IN s_send
      AND h~invoice_type EQ co_memitype
      AND h~date_of_receipt IN s_dtrec
      AND h~invoice_status IN s_insta
      AND h~int_receiver IN s_rece
      AND d~int_inv_doc_no IN s_intido
      AND d~ext_invoice_no IN s_extido
      AND d~doc_type IN s_doctyp
      AND d~inv_doc_status IN s_idosta
      AND d~date_of_payment IN s_dtpaym.

*    CHECK wa_inv_head-int_receiver IN s_rece.
    x_ctrem = x_ctrem + 1.
*   Felder aus HEADER füllen.
*    MOVE wa_inv_head-int_receiver    TO wa_out-int_receiver.
*    MOVE wa_inv_head-int_sender      TO wa_out-int_sender.
*    MOVE wa_inv_head-invoice_status  TO wa_out-invoice_status.
*    MOVE wa_inv_head-date_of_receipt TO wa_out-date_of_receipt.
    MOVE wa_inv_head_doc-int_receiver TO wa_out_memi-int_receiver.
    MOVE wa_inv_head_doc-int_sender   TO wa_out_memi-int_sender.
    MOVE wa_inv_head_doc-invoice_status   TO wa_out_memi-invoice_status.
    MOVE wa_inv_head_doc-date_of_receipt  TO wa_out_memi-date_of_receipt.

    SELECT SINGLE a~vkont INTO wa_out_memi-aggvk
      FROM fkkvk AS a
       INNER JOIN fkkvkp AS b
         ON b~vkont = a~vkont
      INNER JOIN eservprovp AS c
        ON c~bpart = b~gpart
        WHERE c~serviceid = wa_out_memi-int_sender
        AND a~vktyp  IN r_vktyp.

* Rechnungsbelegdaten selektieren
*    SELECT * FROM tinv_inv_doc INTO wa_inv_doc
*      WHERE int_inv_doc_no IN s_intido
*        AND int_inv_no EQ wa_inv_head-int_inv_no
*        AND ext_invoice_no IN s_extido
*        AND doc_type IN s_doctyp
*        AND inv_doc_status IN s_idosta
*        AND date_of_payment IN s_dtpaym.

*       WA_OUT füllen
*      MOVE wa_inv_doc-int_inv_doc_no   TO wa_out-int_inv_doc_no.
*      MOVE wa_inv_doc-ext_invoice_no   TO wa_out-ext_invoice_no.
*      MOVE wa_inv_doc-doc_type         TO wa_out-doc_type.
*      MOVE wa_inv_doc-inv_doc_status   TO wa_out-inv_doc_status.
*      MOVE wa_inv_doc-date_of_payment  TO wa_out-date_of_payment.
*      MOVE wa_inv_doc-invoice_date     TO wa_out-invoice_date.

    MOVE wa_inv_head_doc-int_inv_doc_no TO wa_out_memi-int_inv_doc_no.
    MOVE wa_inv_head_doc-ext_invoice_no TO wa_out_memi-ext_invoice_no.
    MOVE wa_inv_head_doc-doc_type TO wa_out_memi-doc_type.
    MOVE wa_inv_head_doc-inv_doc_status TO wa_out_memi-inv_doc_status.
    MOVE wa_inv_head_doc-date_of_payment TO wa_out_memi-date_of_payment.
    MOVE wa_inv_head_doc-invoice_date TO wa_out_memi-invoice_date.

* AVIS-Zeilen
    CLEAR wa_inv_line_a.
    SELECT * FROM tinv_inv_line_a INTO wa_inv_line_a
*      WHERE int_inv_doc_no EQ wa_inv_doc-int_inv_doc_no         "Nuss 08.2012
        WHERE int_inv_doc_no EQ wa_inv_head_doc-int_inv_doc_no   "Nuss 08.2012
        AND  rstgr IN s_rstgr
        AND  own_invoice_no IN s_owninv.

      CHECK wa_inv_line_a-rstgr IS NOT INITIAL.
      CHECK wa_inv_line_a-own_invoice_no IS NOT INITIAL.

*   Nuss: 11.09.2012
*   Füllen der Ausgabedaten nochmals, wenn mehrere Zeilen im AVIS
      IF wa_out-int_inv_doc_no IS INITIAL.
        MOVE wa_inv_head_doc-int_receiver TO wa_out_memi-int_receiver.
        MOVE wa_inv_head_doc-int_sender   TO wa_out_memi-int_sender.
        MOVE wa_inv_head_doc-invoice_status   TO wa_out_memi-invoice_status.
        MOVE wa_inv_head_doc-date_of_receipt  TO wa_out_memi-date_of_receipt.

        MOVE wa_inv_head_doc-int_inv_doc_no TO wa_out_memi-int_inv_doc_no.
        MOVE wa_inv_head_doc-ext_invoice_no TO wa_out_memi-ext_invoice_no.
        MOVE wa_inv_head_doc-doc_type TO wa_out_memi-doc_type.
        MOVE wa_inv_head_doc-inv_doc_status TO wa_out_memi-inv_doc_status.
        MOVE wa_inv_head_doc-date_of_payment TO wa_out_memi-date_of_payment.
        MOVE wa_inv_head_doc-invoice_date TO wa_out_memi-invoice_date.
      ENDIF.
**  <-- Nuss 11.09.2012

* Text zum Rückstellungsgrund
      CLEAR wa_inv_c_adj_rsnt.
      SELECT SINGLE * FROM tinv_c_adj_rsnt
         INTO wa_inv_c_adj_rsnt
           WHERE rstgr = wa_inv_line_a-rstgr
           AND spras = sy-langu.

* Langtext falls vorhanden
      CLEAR wa_noti.
*        IF wa_inv_line_a-rstgr = '28'.
      SELECT * FROM /idexge/rej_noti INTO wa_noti
*        WHERE int_inv_doc_no = wa_inv_doc-int_inv_doc_no.       "Nuss 08.2012
        WHERE int_inv_doc_no = wa_inv_head_doc-int_inv_doc_no
        AND int_inv_line_no = wa_inv_line_a-int_inv_line_no.
        wa_out_memi-free_text5 = wa_noti-free_text5.
        IF wa_noti-stat_remk(3) = '@0V'.
          wa_out_memi-line_state = icon_okay.
        ENDIF.
        EXIT.
      ENDSELECT.
*        ENDIF.


*     WA_OUT füllen
      MOVE wa_inv_line_a-int_inv_line_no TO wa_out_memi-int_inv_line_no.
      MOVE wa_inv_line_a-rstgr          TO wa_out_memi-rstgr.
      MOVE wa_inv_c_adj_rsnt-text       TO wa_out_memi-text.
      MOVE wa_noti-free_text1           TO wa_out_memi-free_text1.
      MOVE wa_inv_line_a-own_invoice_no TO wa_out_memi-own_invoice_no.
      MOVE wa_inv_line_a-betrw_req      TO wa_out_memi-betrw_req.


**    <-- Nuss 27.07.2012

*  Externer Zählpunkt
      CLEAR wa_ecrossrefno.

      SELECT * FROM ecrossrefno INTO wa_ecrossrefno
        WHERE crossrefno = wa_inv_line_a-own_invoice_no(15)
        OR    crn_rev = wa_inv_line_a-own_invoice_no(15).
        EXIT.
      ENDSELECT.

      MOVE-CORRESPONDING wa_ecrossrefno TO wa_out_memi.

      DATA ls_paym LIKE wa_paym.
      SELECT SINGLE a~own_invoice_no
       a~int_inv_doc_no
       c~invoice_status
  INTO CORRESPONDING FIELDS OF ls_paym
  FROM tinv_inv_line_a AS a
       INNER JOIN tinv_inv_doc AS b
       ON b~int_inv_doc_no = a~int_inv_doc_no
       INNER JOIN tinv_inv_head AS c
       ON c~int_inv_no = b~int_inv_no
*      FOR ALL ENTRIES IN t_crsrf_eui
  WHERE a~own_invoice_no = wa_out_memi-crossrefno
    AND a~int_inv_doc_no = wa_out_memi-int_inv_doc_no.    "Nuss 12.03.2018


      IF sy-subrc = 0.
        wa_out_memi-paym_avis = ls_paym-int_inv_doc_no.
        wa_out_memi-paym_stat = ls_paym-invoice_status.
      ENDIF.
*      AND   a~line_type      = co_linetype
*      AND   b~doc_type       = co_docpaym
*      AND   c~invoice_type   = co_invpaym.


      SORT t_paym BY own_invoice_no.

      DATA: b_storno TYPE boolean.
      b_storno = abap_false.
      CLEAR wa_out_memi-inf_invoice_cancel.
      IF wa_ecrossrefno-crn_rev EQ wa_inv_line_a-own_invoice_no.
        wa_out_memi-inf_invoice_cancel = icon_storno.
        b_storno = abap_true.
      ENDIF.

      CLEAR wa_euitrans.
      SELECT SINGLE * FROM euitrans INTO wa_euitrans
         WHERE int_ui = wa_ecrossrefno-int_ui
         AND dateto = '99991231'.

*      CHECK wa_euitrans-ext_ui IN s_extui.             "Nuss 10.2017 Melo/Malo

      MOVE wa_euitrans-ext_ui TO wa_out_memi-ext_ui.

**    --> Nuss 10.2017  Melo/Malo
      CLEAR: it_idxgc_pod_rel, wa_idxgc_pod_rel.
      IF wa_euitrans-uistrutyp = 'MA'.
        SELECT * FROM /idxgc/pod_rel INTO TABLE it_idxgc_pod_rel
          WHERE int_ui2 = wa_ecrossrefno-int_ui.
      ENDIF.
      IF sy-subrc = 0.
        DESCRIBE TABLE it_idxgc_pod_rel LINES gv_podlines.
        READ TABLE it_idxgc_pod_rel INTO wa_idxgc_pod_rel INDEX 1.
        CLEAR wa_euitrans_melo.
        SELECT SINGLE * FROM euitrans INTO wa_euitrans_melo
           WHERE int_ui = wa_idxgc_pod_rel-int_ui1
           AND dateto = '99991231'.
        MOVE wa_euitrans_melo-ext_ui TO wa_out_memi-ext_ui_melo.
        IF gv_podlines GT 1.
          MOVE 'X' TO wa_out_memi-mult_melo.
        ENDIF.
      ENDIF.
**  <-- Nuss 10.2017 Melo/Malo


* Abrechnungsklasse ermitteln
      SELECT aklasse INTO wa_out_memi-aklasse
        FROM eanlh AS a
          INNER JOIN euiinstln AS b
          ON b~anlage = a~anlage
          INNER JOIN euitrans AS c
           ON c~int_ui = b~int_ui
        WHERE c~ext_ui = wa_out_memi-ext_ui
          AND c~dateto = '99991231'
          AND a~bis = '99991231'.
        EXIT.
      ENDSELECT.


*    SELECT Memidoc
      SELECT SINGLE  * FROM /idxmm/memidoc INTO CORRESPONDING FIELDS OF  wa_out_memi WHERE
      crossrefno = wa_out_memi-crossrefno.

      SELECT SINGLE opbel FROM erchc  INTO wa_out_memi-erchcopbel WHERE belnr = wa_out_memi-trig_bill_doc_no.
      wa_out_memi-billable_item = wa_out_memi-doc_id.
      SELECT COUNT(*) FROM /adesso/fi_remad WHERE negrem_option = 'FIELDCAT' AND negrem_field = 'BEMERKUNG' AND negrem_value = 'X'.
      IF sy-subrc = 0.
        SELECT COUNT(*) FROM /adesso/remtext WHERE int_inv_doc_nr = wa_out_memi-int_inv_doc_no.
        IF sy-subrc = 0.
          wa_out_memi-text_vorhanden = 'X'.
        ELSE.
          wa_out_memi-text_vorhanden = ''.
        ENDIF.
      ENDIF.
      SELECT COUNT(*) FROM /adesso/fi_remad WHERE negrem_option = 'FIELDCAT' AND negrem_field = 'NOTIZ' AND negrem_value = 'X'.
      IF sy-subrc = 0.
        CLEAR gv_name.
        CLEAR xlines.
        CONCATENATE wa_out_memi-int_inv_doc_no
                    '_'
                    wa_out_memi-int_inv_line_no
                    INTO gv_name.

        CLEAR xlines.
        CALL FUNCTION 'READ_TEXT'
          EXPORTING
*           CLIENT                  = SY-MANDT
            id                      = co_id
            language                = sy-langu
            name                    = gv_name
            object                  = co_object
*           ARCHIVE_HANDLE          = 0
*           LOCAL_CAT               = ' '
*   IMPORTING
*           HEADER                  =
*           OLD_LINE_COUNTER        =
          TABLES
            lines                   = xlines
          EXCEPTIONS
            id                      = 1
            language                = 2
            name                    = 3
            not_found               = 4
            object                  = 5
            reference_check         = 6
            wrong_access_to_archive = 7
            OTHERS                  = 8.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.

        READ TABLE xlines INTO help_line INDEX 1.

        IF sy-subrc = 0.
          wa_out_memi-free_text5 = help_line.
*    MODIFY it_out FROM wa_out INDEX fp_tabindex.
        ENDIF.
      ENDIF.


      wa_out_memi-vkont = wa_out_memi-aggvk.
      PERFORM sel_bcontact_memi USING wa_out_memi.
      PERFORM sel_invstorno_memi USING wa_out_memi.
      PERFORM get_locks_memi.
      APPEND wa_out_memi TO it_out_memi.
      CLEAR wa_out_memi.

    ENDSELECT.

*    ENDSELECT.                                          "TINV_INV_DOC

  ENDSELECT.                                            "TINV_INV_HEAD

ENDFORM.                    " DATEN_SELEKTIEREN
FORM add_text CHANGING action.
  DATA: title              TYPE text80,
        text1              TYPE text132,
        text2              TYPE text132,
        text255            TYPE text255,
        anzahl_sel         TYPE anzahl,
        ls_out             LIKE  wa_out,
        ls_out_memi        LIKE  wa_out_memi,
        ls_out_mgv         LIKE  wa_out_mgv,
        ls_out_msb         LIKE  wa_out_msb,          "Nuss 09.2018
        line_no            TYPE i,
        lt_invtext         TYPE TABLE OF /adesso/remtext,
        ls_invtext         TYPE /adesso/remtext,
        lt_fields          TYPE TABLE OF sval,
        ls_fields          TYPE  sval,
        lv_textnr          TYPE i,
        lv_spaces          TYPE i,
        lv_spacechars(255),
        lv_no_row          TYPE c,
        int_doc_string     TYPE string,
        answer(1)          TYPE c.


  DATA lt_int_doc_no TYPE tinv_int_inv_doc_no.
  DATA lv_int_doc_no TYPE inv_int_inv_doc_no.
  CLEAR lt_int_doc_no.
*BREAK struck-f.
  IF p_invtp = '2'.
    LOOP AT it_out_memi INTO ls_out_memi WHERE sel = 'X'.
      APPEND ls_out_memi-int_inv_doc_no TO lt_int_doc_no.
    ENDLOOP.
    IF sy-subrc <> 0.
      lv_no_row = 'X'.
    ENDIF.
    CLEAR ls_invtext.
  ELSEIF p_invtp = 1.
    LOOP AT it_out INTO ls_out WHERE sel = 'X'.
      APPEND ls_out-int_inv_doc_no TO lt_int_doc_no.
    ENDLOOP.
    IF sy-subrc <> 0.
      lv_no_row = 'X'.
    ENDIF.
    CLEAR ls_invtext.
  ELSEIF p_invtp = 3.
    LOOP AT it_out_mgv INTO ls_out_mgv WHERE sel = 'X'.
      APPEND ls_out_mgv-int_inv_doc_no TO lt_int_doc_no.
    ENDLOOP.
    IF sy-subrc <> 0.
      lv_no_row = 'X'.
    ENDIF.
    CLEAR ls_invtext.
* --> Nuss 09.2018
  ELSEIF p_invtp = 4.
    LOOP AT it_out_msb INTO ls_out_msb WHERE sel = 'X'.
      APPEND ls_out_msb-int_inv_doc_no TO lt_int_doc_no.
    ENDLOOP.
    IF sy-subrc <> 0.
      lv_no_row = 'X'.
    ENDIF.
    CLEAR ls_invtext.
* <-- Nuss 09.2018
  ENDIF.

  IF lv_no_row = 'X'.
    MESSAGE 'Bitte mindestens eine Zeile markieren.' TYPE 'I' DISPLAY LIKE 'E' .
  ELSE.
    CALL FUNCTION '/ADESSO/REMADV_BEMERKUNG_ANL'
      EXPORTING
        int_inv_doc_no = lt_int_doc_no
* IMPORTING
*       OK_CODE        =
      .
    DATA lr_out LIKE REF TO wa_out.
    DATA lr_out_memi LIKE REF TO wa_out_memi.
    DATA lr_out_mgv LIKE REF TO wa_out_mgv.
    DATA lr_out_msb LIKE REF TO wa_out_msb.              "Nuss 09.2018
    IF p_invtp = 1.
      LOOP AT lt_int_doc_no INTO lv_int_doc_no.
        READ TABLE it_out REFERENCE INTO lr_out WITH KEY int_inv_doc_no = lv_int_doc_no.
        IF sy-subrc = 0.
          lr_out->text_vorhanden = 'X'.
        ENDIF.
      ENDLOOP.
    ELSEIF p_invtp = 2.
      LOOP AT lt_int_doc_no INTO lv_int_doc_no.
        READ TABLE it_out_memi REFERENCE INTO lr_out_memi WITH KEY int_inv_doc_no = lv_int_doc_no.
        IF sy-subrc = 0.
          lr_out_memi->text_vorhanden = 'X'.
        ENDIF.
      ENDLOOP.
    ELSEIF p_invtp = 3.
      LOOP AT lt_int_doc_no INTO lv_int_doc_no.
        READ TABLE it_out_mgv REFERENCE INTO lr_out_mgv WITH KEY int_inv_doc_no = lv_int_doc_no.
        IF sy-subrc = 0.
          lr_out_mgv->text_vorhanden = 'X'.
        ENDIF.
      ENDLOOP.
*  --> Nuss 09.2018
    ELSEIF p_invtp = 4.
      LOOP AT lt_int_doc_no INTO lv_int_doc_no.
        READ TABLE it_out_msb REFERENCE INTO lr_out_msb WITH KEY int_inv_doc_no = lv_int_doc_no.
        IF sy-subrc = 0.
          lr_out_msb->text_vorhanden = 'X'.
        ENDIF.
      ENDLOOP.
* <-- Nuss 09.2018
    ENDIF.
  ENDIF.





ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  HANDLE_CODE_OK
*&---------------------------------------------------------------------*
*       Unterprogramm zum Behandeln der Rückgabewerte des OK_Popups.
*       OK = J oder N gesetzt
*----------------------------------------------------------------------*
FORM handle_code_ok TABLES   fields STRUCTURE sval
                 USING    code
                 CHANGING error  STRUCTURE svale show_popup.

  CLEAR: gv_okcode.
  CASE code.
    WHEN 'FURT'.  gv_okcode = 'J'.
    WHEN 'COD1'.  gv_okcode = 'N'.
    WHEN 'COD2'.  gv_okcode = 'U'.
  ENDCASE.

ENDFORM.

FORM texte_anzeigen USING docnr.


*** Variablen
  DATA:
    lt_texte TYPE TABLE OF /adesso/remtext,
    ls_texte TYPE  /adesso/remtext.

  SELECT * FROM /adesso/remtext INTO TABLE lt_texte WHERE int_inv_doc_nr = docnr.

  DATA ls_fieldcat TYPE slis_fieldcat_alv.
  DATA lt_fieldcat_ext TYPE TABLE OF slis_fieldcat_alv.

* Kennung
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'INT_INV_DOC_NR'.
  ls_fieldcat-tabname = 'LT_TEXTE'.
  ls_fieldcat-ref_tabname = '/ADESSO/REMTEXT'.
  APPEND ls_fieldcat TO lt_fieldcat_ext.

* AB
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DATUM'.
  ls_fieldcat-tabname = 'LT_TEXTE'.
  ls_fieldcat-ref_tabname = '/ADESSO/REMTEXT'.
  APPEND ls_fieldcat TO lt_fieldcat_ext.

* BIS
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'UNAME'.
  ls_fieldcat-tabname = 'LT_TEXTE'.
  ls_fieldcat-ref_tabname = '/ADESSO/REMTEXT'.
  APPEND ls_fieldcat TO lt_fieldcat_ext.

*  Menge
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'ACTION'.
  ls_fieldcat-tabname = 'LT_TEXTE'.
  ls_fieldcat-ref_tabname = '/ADESSO/REMTEXT'.
  APPEND ls_fieldcat TO lt_fieldcat_ext.

*  Text
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TEXT'.
  ls_fieldcat-tabname = 'LT_TEXTE'.
  ls_fieldcat-ref_tabname = '/ADESSO/REMTEXT'.
  APPEND ls_fieldcat TO lt_fieldcat_ext.






  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      it_fieldcat           = lt_fieldcat_ext[]
      i_screen_start_column = 10
      i_screen_start_line   = 10
      i_screen_end_column   = 200
      i_screen_end_line     = 20
    TABLES
      t_outtab              = lt_texte
    EXCEPTIONS
      program_error         = 1
      OTHERS                = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.
FORM mahnsperre_setzen .

  DATA: l_answer      TYPE char1,
        lv_b_selected TYPE boolean.
  DATA: t_fkkopchl LIKE fkkopchl         OCCURS 0 WITH HEADER LINE.



* Sicherheitsabfrage
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      defaultoption = 'Y'
      textline1     = TEXT-110
      textline2     = TEXT-111
      titel         = TEXT-t03
    IMPORTING
      answer        = l_answer.

  IF NOT l_answer CA 'jJyY'.
    EXIT.
  ENDIF.

  IF p_invtp = '1'.
    LOOP AT it_out INTO wa_out.

      CHECK wa_out-sel = 'X'.

      lv_b_selected = abap_true.

      CLEAR t_fkkopchl. REFRESH t_fkkopchl.

*   Sperren zu Belegpositionen
      t_fkkopchl-lockaktyp = '01'.  "Verarbeitungsmodus  Anlegen
      t_fkkopchl-opupk     = wa_out-opupk.
      t_fkkopchl-opupw     = wa_out-opupw.
      t_fkkopchl-opupz     = wa_out-opupz.
      t_fkkopchl-proid     = '01'. "Prozess Mahnen
      t_fkkopchl-lockr     = pa_lockr.
      t_fkkopchl-fdate     = pa_fdate.
      t_fkkopchl-tdate     = pa_tdate.
      t_fkkopchl-lotyp     = '02'. "Belegposition
      t_fkkopchl-gpart     = wa_out-gpart.
      t_fkkopchl-vkont     = wa_out-vkont.
      APPEND t_fkkopchl.

      CALL FUNCTION 'FKK_DOCUMENT_CHANGE_LOCKS'
        EXPORTING
          i_opbel           = wa_out-opbel
        TABLES
          t_fkkopchl        = t_fkkopchl
        EXCEPTIONS
          err_document_read = 1
          err_create_line   = 2
          err_lock_reason   = 3
          err_lock_date     = 4
          OTHERS            = 5.
      IF sy-subrc <> 0.
        wa_out-process_state = icon_led_red.
      ELSE.
        wa_out-process_state = icon_locked.
      ENDIF.

      MODIFY it_out FROM wa_out.

    ENDLOOP.
  ELSEIF p_invtp = 3.
    LOOP AT it_out_mgv INTO wa_out_mgv.

      CHECK wa_out_mgv-sel = 'X'.

      lv_b_selected = abap_true.

      CLEAR t_fkkopchl. REFRESH t_fkkopchl.

*   Sperren zu Belegpositionen
      t_fkkopchl-lockaktyp = '01'.  "Verarbeitungsmodus  Anlegen
      t_fkkopchl-opupk     = wa_out_mgv-opupk.
      t_fkkopchl-opupw     = wa_out_mgv-opupw.
*      t_fkkopchl-opupz     = wa_out-opupz.
      t_fkkopchl-proid     = '01'. "Prozess Mahnen
      t_fkkopchl-lockr     = pa_lockr.
      t_fkkopchl-fdate     = pa_fdate.
      t_fkkopchl-tdate     = pa_tdate.
      t_fkkopchl-lotyp     = '02'. "Belegposition
      t_fkkopchl-gpart     = wa_out_mgv-gpart.
      t_fkkopchl-vkont     = wa_out_mgv-vkont.
      APPEND t_fkkopchl.

      CALL FUNCTION 'FKK_DOCUMENT_CHANGE_LOCKS'
        EXPORTING
          i_opbel           = wa_out_mgv-opbel
        TABLES
          t_fkkopchl        = t_fkkopchl
        EXCEPTIONS
          err_document_read = 1
          err_create_line   = 2
          err_lock_reason   = 3
          err_lock_date     = 4
          OTHERS            = 5.
      IF sy-subrc <> 0.
        wa_out_mgv-process_state = icon_led_red.
      ELSE.
        wa_out_mgv-process_state = icon_locked.
      ENDIF.

      MODIFY it_out_mgv FROM wa_out_mgv.

    ENDLOOP.
  ELSEIF p_invtp = 2.
    DATA lv_done TYPE abap_bool.
    CLEAR lv_done.
    LOOP AT it_out_memi INTO wa_out_memi.


      CHECK wa_out_memi-sel = 'X'.

*    --> Nuss 13.02.2018
*    Liegt eine Mahnsperre vor?
*      IF wa_out_memi-fdate IS NOT INITIAL.
*        IF pa_tdate GE wa_out_memi-fdate.
*          MESSAGE TEXT-e04 TYPE 'E'.
*        ENDIF.
*      ENDIF.
**     <-- Nuss 13.02.2018
      CALL FUNCTION '/ADESSO/MEMI_MAHNSPERRE'
        EXPORTING
          iv_belnr     = wa_out_memi-doc_id
*         IX_GET_LOCKHIST       =
          ix_set_lock  = 'X'
*         IX_DEL_LOCK  =
          iv_no_popup  = lv_done
        IMPORTING
          ev_done      = lv_done
        CHANGING
          iv_date_from = pa_fdate
          iv_date_to   = pa_tdate
          iv_lockr     = pa_lockr.
      IF lv_done IS   INITIAL.
        EXIT.
      ELSE.
        wa_out_memi-process_state = icon_locked.   "Nuss 13.02.2018
        wa_out_memi-mahnsp = pa_lockr.               "Nuss 12.02.2018
        wa_out_memi-fdate  = pa_fdate.               "Nuss 12.02.2018
        wa_out_memi-tdate  = pa_tdate.               "Nuss 12.02.2018

      ENDIF.


      lv_b_selected = abap_true.

***    --> Nuss 09.02.2018
*      DATA: ls_mloc TYPE /adesso/hmv_mloc.
*      DATA ls_memidoc_u TYPE /idxmm/memidoc.
*      DATA lt_memidoc_u TYPE /idxmm/t_memi_doc.
*      DATA lr_memidoc TYPE REF TO /idxmm/cl_memi_document_db.
*
*      CLEAR ls_mloc.
*      ls_mloc-doc_id    = wa_out_memi-doc_id.
*      ls_mloc-lockr     = pa_lockr.
*      ls_mloc-fdate     = pa_fdate.
*      ls_mloc-tdate     = pa_tdate.
*      ls_mloc-crnam     = sy-uname.
*      ls_mloc-azeit     = sy-timlo.
*      ls_mloc-adatum    = sy-datum.
*      ls_mloc-lvorm     = ''.
*
*      MODIFY /adesso/hmv_mloc FROM ls_mloc.
*
*      IF sy-subrc = 0.
**       --> Nuss 13.02.2018
*        IF pa_fdate LE sy-datum.
*          wa_out_memi-process_state = icon_locked.
*        ELSE.
*          wa_out_memi-process_state = icon_led_yellow.
*        ENDIF.
**       <-- Nuss 13.02.2018
*
**        wa_out_memi-process_state = icon_locked.   "Nuss 13.02.2018
*        wa_out_memi-mahnsp = pa_lockr.               "Nuss 12.02.2018
*        wa_out_memi-fdate  = pa_fdate.               "Nuss 12.02.2018
*        wa_out_memi-tdate  = pa_tdate.               "Nuss 12.02.2018
*      ENDIF.



*      DATA lv_memi_state_lock TYPE /idxmm/memidoc-doc_status.
*      DATA ls_memidoc_u TYPE /idxmm/memidoc.
*      DATA lt_memidoc_u TYPE /idxmm/t_memi_doc.
*      DATA lr_memidoc TYPE REF TO /idxmm/cl_memi_document_db.
*      "customizing
*      SELECT SINGLE negrem_value FROM /adesso/fi_remad INTO lv_memi_state_lock WHERE negrem_option = 'MAHNSPERRSTAT' AND negrem_field = 'MEMI' .
*
*      CREATE OBJECT lr_memidoc.
*      SELECT SINGLE * FROM /idxmm/memidoc INTO ls_memidoc_u WHERE doc_id = wa_out_memi-doc_id.
*
*
*      ls_memidoc_u-doc_status = lv_memi_state_lock.
*      APPEND ls_memidoc_u TO lt_memidoc_u.
**      TRY.
*      CALL METHOD /idxmm/cl_memi_document_db=>update
*        EXPORTING
**         iv_simulate   =
*          it_doc_update = lt_memidoc_u.
**         CATCH /idxmm/cx_bo_error .
**        ENDTRY.
*
*      IF sy-subrc = 0.
*
*        wa_out_memi-doc_status = lv_memi_state_lock.
*
*      ENDIF.
*
*
      MODIFY it_out_memi FROM wa_out_memi.

    ENDLOOP.

* --> Nuss 09.2018-2
  ELSEIF p_invtp = 4.

    LOOP AT it_out_msb INTO wa_out_msb.

      CHECK wa_out_msb-sel = 'X'.

      lv_b_selected = abap_true.

      CLEAR t_fkkopchl. REFRESH t_fkkopchl.

*   Sperren zu Belegpositionen
      t_fkkopchl-lockaktyp = '01'.  "Verarbeitungsmodus  Anlegen
      t_fkkopchl-opupk     = '0001'.
      t_fkkopchl-proid     = '01'. "Prozess Mahnen
      t_fkkopchl-lockr     = pa_lockr.
      t_fkkopchl-fdate     = pa_fdate.
      t_fkkopchl-tdate     = pa_tdate.
      t_fkkopchl-lotyp     = '02'. "Belegposition
      t_fkkopchl-gpart     = wa_out_msb-gpart.
      t_fkkopchl-vkont     = wa_out_msb-vkont_msb.
      APPEND t_fkkopchl.

      CALL FUNCTION 'FKK_DOCUMENT_CHANGE_LOCKS'
        EXPORTING
          i_opbel           = wa_out_msb-opbel
        TABLES
          t_fkkopchl        = t_fkkopchl
        EXCEPTIONS
          err_document_read = 1
          err_create_line   = 2
          err_lock_reason   = 3
          err_lock_date     = 4
          OTHERS            = 5.
      IF sy-subrc <> 0.
        wa_out_msb-process_state = icon_led_red.
      ELSE.
        wa_out_msb-process_state = icon_locked.
      ENDIF.

      MODIFY it_out_msb FROM wa_out_msb.


    ENDLOOP.
* <-- Nuss 09.2018-2

  ENDIF.


  IF lv_b_selected EQ abap_false.
    MESSAGE e000(e4) WITH 'Bitte selektieren Sie mindestens einen Datensatz.'.
    EXIT.
  ENDIF.

ENDFORM.                    " MAHNSPERRE_SETZEN
*&---------------------------------------------------------------------*
*&      Form  DROP_SELECT
*&---------------------------------------------------------------------*
*>>> UH 30012013
FORM drop_select .

  DATA x_button TYPE c.
  IF p_invtp = 1.
* MArkierungen beibehalten?
    LOOP AT it_out TRANSPORTING NO FIELDS
         WHERE sel = 'X'.

      CLEAR x_button.
      CALL FUNCTION 'POPUP_FOR_INTERACTION'
        EXPORTING
          headline       = TEXT-t04
          text1          = TEXT-104
          text2          = TEXT-105
          ticon          = 'I'
          button_1       = TEXT-b01
          button_2       = TEXT-b02
        IMPORTING
          button_pressed = x_button.

      IF x_button = '2'.
        PERFORM deselect_all.
      ENDIF.

      EXIT.

    ENDLOOP.
  ELSEIF p_invtp = 2.                                        "Nuss 09.2018
* MArkierungen beibehalten?
    LOOP AT it_out_memi TRANSPORTING NO FIELDS               "Nuss 09.2018
         WHERE sel = 'X'.

      CLEAR x_button.
      CALL FUNCTION 'POPUP_FOR_INTERACTION'
        EXPORTING
          headline       = TEXT-t03
          text1          = TEXT-104
          text2          = TEXT-105
          ticon          = 'I'
          button_1       = TEXT-b01
          button_2       = TEXT-b02
        IMPORTING
          button_pressed = x_button.

      IF x_button = '2'.
        PERFORM deselect_all.
      ENDIF.

      EXIT.

    ENDLOOP.
  ELSEIF p_invtp = 3.
* MArkierungen beibehalten?
    LOOP AT it_out_mgv TRANSPORTING NO FIELDS
         WHERE sel = 'X'.

      CLEAR x_button.
      CALL FUNCTION 'POPUP_FOR_INTERACTION'
        EXPORTING
          headline       = TEXT-t03
          text1          = TEXT-104
          text2          = TEXT-105
          ticon          = 'I'
          button_1       = TEXT-b01
          button_2       = TEXT-b02
        IMPORTING
          button_pressed = x_button.

      IF x_button = '2'.
        PERFORM deselect_all.
      ENDIF.

      EXIT.

    ENDLOOP.
* --> Nuss 09.2018
  ELSEIF p_invtp = 4.
* MArkierungen beibehalten?
    LOOP AT it_out_msb TRANSPORTING NO FIELDS               "Nuss 09.2018
         WHERE sel = 'X'.

      CLEAR x_button.
      CALL FUNCTION 'POPUP_FOR_INTERACTION'
        EXPORTING
          headline       = TEXT-t03
          text1          = TEXT-104
          text2          = TEXT-105
          ticon          = 'I'
          button_1       = TEXT-b01
          button_2       = TEXT-b02
        IMPORTING
          button_pressed = x_button.

      IF x_button = '2'.
        PERFORM deselect_all.
      ENDIF.

      EXIT.

    ENDLOOP.
* <-- Nuss 09.2018


  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  DESELECT_ALL
*&---------------------------------------------------------------------*
FORM deselect_all .

  LOOP AT it_out_memi INTO wa_out_memi.

    CLEAR wa_out_memi-sel.
    MODIFY it_out_memi FROM wa_out_memi.

  ENDLOOP.

  LOOP AT it_out_mgv INTO wa_out_mgv.

    CLEAR wa_out_mgv-sel.
    MODIFY it_out_mgv FROM wa_out_mgv.

  ENDLOOP.

  LOOP AT it_out INTO wa_out.

    CLEAR wa_out-sel.
    MODIFY it_out FROM wa_out.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_LOCKS
*&---------------------------------------------------------------------*
FORM get_locks.
* check dunning block for document
  DATA: lf_info(25).
  DATA: s_dfkkop LIKE dfkkop.
  DATA: s_dfkkop_key LIKE dfkkop_key_s.
  DATA: t_dfkklock TYPE TABLE OF dfkklocks WITH HEADER LINE.
  DATA:x_lock_exist TYPE c,
       x_lock_depex TYPE c.

  CLEAR: x_lock_exist,
         x_lock_depex.

  CLEAR s_dfkkop.
  CLEAR s_dfkkop_key.
  IF <fs_dfkkthi_op> IS ASSIGNED.
    s_dfkkop-gpart  = <fs_dfkkthi_op>-gpart.
    s_dfkkop-vkont  = <fs_dfkkthi_op>-vkont.
    s_dfkkop-opbel  = <fs_dfkkthi_op>-opbel.
    s_dfkkop-opupw  = <fs_dfkkthi_op>-opupw.
    s_dfkkop-opupk  = <fs_dfkkthi_op>-opupk.
    s_dfkkop-opupz  = <fs_dfkkthi_op>-opupz.
    MOVE-CORRESPONDING s_dfkkop TO s_dfkkop_key.

    CALL FUNCTION 'FKK_S_LOCK_GET'
      EXPORTING
        i_keystructure           = s_dfkkop
        i_lotyp                  = '02'
        i_proid                  = '01'
        i_lockdate               = sy-datum
        i_x_mass_access          = space
        i_x_dependant_locktypes  = space
      IMPORTING
        e_x_lock_exist           = x_lock_exist
        e_x_dependant_lock_exist = x_lock_depex
      TABLES
        et_locks                 = t_dfkklock.

    CHECK x_lock_exist = 'X'.
    LOOP AT t_dfkklock WHERE loobj1 = s_dfkkop_key.
      "wa_out-mansp  = t_dfkklock-lockr.
      " lf_info = wa_out-mansp.
      lf_info+13(1) = '-'.
      WRITE t_dfkklock-fdate TO lf_info+2(10) DD/MM/YYYY.
      WRITE t_dfkklock-tdate TO lf_info+15(10) DD/MM/YYYY.
    ENDLOOP.
    IF p_invtp = 1.
      wa_out-process_state = icon_locked.
    ELSEIF p_invtp = 3.
      wa_out_mgv-process_state = icon_locked.
    ENDIF.
  ENDIF.
ENDFORM.
FORM get_locks_memi.

* --> Nuss 13.02.2018
  DATA: ls_mloc TYPE /adesso/mem_mloc,
        lt_mloc TYPE STANDARD TABLE OF /adesso/mem_mloc.

  SELECT * FROM /adesso/mem_mloc INTO TABLE lt_mloc
    WHERE doc_id = wa_out_memi-doc_id
     AND tdate GE sy-datum
     AND lvorm = ''.

  SORT lt_mloc BY tdate ASCENDING.
  READ TABLE lt_mloc INTO ls_mloc INDEX 1.
  IF sy-subrc = 0.
    wa_out_memi-mahnsp = ls_mloc-lockr.          "Nuss 12.02.2018
    wa_out_memi-fdate  = ls_mloc-fdate.          "Nuss 12.02.2018
    wa_out_memi-tdate  = ls_mloc-tdate.          "Nuss 12.02.2018
    IF ls_mloc-fdate LE sy-datum.
      wa_out_memi-process_state = icon_locked.
    ELSE.
      wa_out_memi-process_state = icon_led_yellow.
    ENDIF.
  ENDIF.
*  --> 09.02.2018
*  DATA: ls_mloc TYPE /adesso/hmv_mloc.
*  SELECT SINGLE * FROM /adesso/hmv_mloc INTO ls_mloc
*    WHERE doc_id = wa_out_memi-doc_id
*     AND tdate GE sy-datum
**     AND fdate LE sy-datum                      "Nuss 13.02.2018
*     AND lvorm = ''.
*  IF sy-subrc = 0.
*    wa_out_memi-mahnsp = ls_mloc-lockr.          "Nuss 12.02.2018
*    wa_out_memi-fdate  = ls_mloc-fdate.          "Nuss 12.02.2018
*    wa_out_memi-tdate  = ls_mloc-tdate.          "Nuss 12.02.2018
*    wa_out_memi-process_state = icon_locked.
*  ENDIF.

*  DATA lv_memi_state_lock TYPE /idxmm/memidoc-doc_status.
*  SELECT SINGLE negrem_value FROM /adesso/fi_remad INTO lv_memi_state_lock WHERE negrem_option = 'MAHNSPERRSTAT' AND negrem_field = 'MEMI' .
*  IF wa_out_memi-doc_status = lv_memi_state_lock.
*    wa_out_memi-process_state = icon_locked.
*  ENDIF.
* <-- Nuss 09.02.2018
* <-- Nuss 13.02.2018

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_LOCKS
*&---------------------------------------------------------------------*
FORM set_locks .
  DATA: t_fkkopchl LIKE fkkopchl         OCCURS 0 WITH HEADER LINE.
  DATA: lv_b_selected TYPE boolean.
  DATA: lf_info(25).

  DATA: if_lockr LIKE t_fkkopchl-lockr.
  DATA: if_fdate LIKE t_fkkopchl-fdate.
  DATA: if_tdate LIKE t_fkkopchl-tdate.

  REFRESH t_sval.

  CLEAR w_sval.
  w_sval-tabname   = 'FKKMAZE'.
  w_sval-fieldname = 'MANSP'.
  w_sval-field_obl = 'X'.
  w_sval-value     = '*'.
  w_sval-fieldtext = 'Sperrgrund'.
  APPEND w_sval TO t_sval.

  CLEAR w_sval.
  w_sval-tabname   = 'DFKKLOCKS'.
  w_sval-fieldname = 'FDATE'.
  w_sval-field_obl = 'X'.
  w_sval-fieldtext = 'von Datum'.
  APPEND w_sval TO t_sval.

  CLEAR w_sval.
  w_sval-tabname   = 'DFKKLOCKS'.
  w_sval-fieldname = 'TDATE'.
  w_sval-field_obl = 'X'.
  w_sval-fieldtext = 'bis Datum'.
  APPEND w_sval TO t_sval.

  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
      popup_title  = 'Setzen Mahnsperre'
      start_column = '5'
      start_row    = '5'
    TABLES
      fields       = t_sval.

  LOOP AT t_sval INTO w_sval.
    CASE w_sval-fieldname.
      WHEN 'MANSP'.
        if_lockr = w_sval-value.
      WHEN 'FDATE'.
        if_fdate = w_sval-value.
      WHEN 'TDATE'.
        if_tdate = w_sval-value.
    ENDCASE.
  ENDLOOP.

  LOOP AT it_out INTO wa_out
       WHERE sel = 'X'. "AND
    "augst  = ' '.



    lv_b_selected = 'X'.

    CLEAR t_fkkopchl. REFRESH t_fkkopchl.

*   Sperren zu Belegpositionen
    t_fkkopchl-lockaktyp = '01'.
    t_fkkopchl-opupk     = wa_out-opupk.
    t_fkkopchl-opupw     = wa_out-opupw.
    t_fkkopchl-opupz     = wa_out-opupz.
    t_fkkopchl-proid     = '01'.
    t_fkkopchl-lockr     = if_lockr.
    t_fkkopchl-fdate     = if_fdate.
    t_fkkopchl-tdate     = if_tdate.
    t_fkkopchl-lotyp     = '02'.
    t_fkkopchl-gpart     = wa_out-gpart.
    t_fkkopchl-vkont     = wa_out-vkont.
    APPEND t_fkkopchl.

    CALL FUNCTION 'FKK_DOCUMENT_CHANGE_LOCKS'
      EXPORTING
        i_opbel           = wa_out-opbel
      TABLES
        t_fkkopchl        = t_fkkopchl
      EXCEPTIONS
        err_document_read = 1
        err_create_line   = 2
        err_lock_reason   = 3
        err_lock_date     = 4
        OTHERS            = 5.

    IF sy-subrc <> 0.
      wa_out-process_state = icon_led_red.
    ELSE.
      "wa_out-mansp = if_lockr.

      " lf_info = wa_out-mansp.
      lf_info+13(1) = '-'.
      WRITE if_fdate TO lf_info+2(10) DD/MM/YYYY.
      WRITE if_tdate TO lf_info+15(10) DD/MM/YYYY.

      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_LOCKED'
          info                  = lf_info
        IMPORTING
          result                = wa_out-process_state
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.

    ENDIF.

    MODIFY it_out FROM wa_out.

  ENDLOOP.

  IF lv_b_selected EQ abap_false.
    MESSAGE e000(e4) WITH 'Bitte selektieren Sie einen Datensatz.'.
    EXIT.
  ENDIF.

ENDFORM.                    " SET_LOCKS
*&---------------------------------------------------------------------*
*&      Form  mark_all
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM mark_all.
  DATA lr_out LIKE REF TO wa_out.
  DATA lr_out_memi LIKE REF TO wa_out_memi.
  DATA lr_out_mgv LIKE REF TO wa_out_mgv.
  DATA lr_out_msb LIKE REF TO wa_out_msb.                   "09.2018

  IF p_invtp = 1.
    LOOP AT it_out REFERENCE INTO lr_out WHERE xselp = 'X'.
      lr_out->sel = 'X'.
      "  lr_out->xselp = 'X'.
    ENDLOOP.
  ELSEIF p_invtp = 2.
    LOOP AT it_out_memi REFERENCE INTO lr_out_memi WHERE xselp = 'X'.
      lr_out_memi->sel = 'X'.
      "  lr_out->xselp = 'X'.
    ENDLOOP.
  ELSEIF p_invtp = 3.
    LOOP AT it_out_mgv REFERENCE INTO lr_out_mgv WHERE xselp = 'X'.
      lr_out_mgv->sel = 'X'.
      "  lr_out->xselp = 'X'.
    ENDLOOP.
* --> Nuss 09.2018
  ELSEIF p_invtp = 4.
    LOOP AT it_out_msb REFERENCE INTO lr_out_msb WHERE xselp = 'X'.
      lr_out_msb->sel = 'X'.
      "  lr_out->xselp = 'X'.
    ENDLOOP.
* <-- Nuss 09.2018

  ENDIF.

ENDFORM.                    "mark_all

*&---------------------------------------------------------------------*
*&      Form  unmark_all
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM unmark_all.
  DATA lr_out LIKE REF TO wa_out.
  DATA lr_out_memi LIKE REF TO wa_out_memi.
  DATA lr_out_mgv LIKE REF TO wa_out_mgv.
  DATA lr_out_msb LIKE REF TO wa_out_msb.             "Nuss 09.2018


  IF p_invtp = 1.
    LOOP AT it_out REFERENCE INTO lr_out .
      lr_out->sel = ' '.
      lr_out->xselp = ' '.
    ENDLOOP.
  ELSEIF p_invtp = 2.
    LOOP AT it_out_memi REFERENCE INTO lr_out_memi .
      lr_out_memi->sel = ' '.
      lr_out_memi->xselp = ' '.
    ENDLOOP.
  ELSEIF p_invtp = 3.
    LOOP AT it_out_mgv REFERENCE INTO lr_out_mgv .
      lr_out_mgv->sel = ' '.
      lr_out_mgv->xselp = ' '.
    ENDLOOP.
* --> Nuss 09.2018
  ELSEIF p_invtp = 4.
    LOOP AT it_out_msb REFERENCE INTO lr_out_msb .
      lr_out_msb->sel = ' '.
      lr_out_msb->xselp = ' '.
    ENDLOOP.
* -- Nuss 09.2018
  ENDIF.

ENDFORM.                    "unmark_all
*&---------------------------------------------------------------------*
*&      Form  INT_STATUS
*&---------------------------------------------------------------------*
FORM int_status USING fp_value    TYPE slis_selfield-value
                      fp_tabindex TYPE slis_selfield-tabindex.

  DATA: l_answer TYPE char1.

  REFRESH t_sval.

  CLEAR w_sval.
  w_sval-tabname   = '/IDEXGE/REJ_NOTI'.
  w_sval-fieldname = 'FREE_TEXT4'.
  w_sval-value     = fp_value.
  w_sval-fieldtext = 'Status'.
  APPEND w_sval TO t_sval.

  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
      popup_title     = 'Interner Status'
      start_column    = '5'
      start_row       = '5'
    IMPORTING
      returncode      = l_answer
    TABLES
      fields          = t_sval
    EXCEPTIONS
      error_in_fields = 1
      OTHERS          = 2.

  CHECK sy-subrc = 0.
  CHECK l_answer = space.

  READ TABLE t_sval INTO w_sval INDEX 1.
  IF p_invtp = 1.
* read data from database /idexge/rej_noti
    SELECT SINGLE * FROM /idexge/rej_noti INTO wa_rej_noti
       WHERE int_inv_doc_no = wa_out-int_inv_doc_no
       AND   int_inv_line_no = wa_out-int_inv_line_no.

    IF sy-subrc <> 0.
      wa_rej_noti-int_inv_doc_no = wa_out-int_inv_doc_no.
      wa_rej_noti-int_inv_line_no = wa_out-int_inv_line_no.
      wa_rej_noti-free_text4 = w_sval-value.
      INSERT INTO /idexge/rej_noti VALUES wa_rej_noti.
    ELSE.
      wa_rej_noti-free_text4 = w_sval-value.
      MODIFY /idexge/rej_noti FROM wa_rej_noti.
    ENDIF.

    IF sy-subrc = 0.
      wa_out-free_text4 = w_sval-value.
      COMMIT WORK.
    ENDIF.

    MODIFY it_out FROM wa_out INDEX fp_tabindex.
  ELSEIF p_invtp = 2.
* read data from database /idexge/rej_noti
    SELECT SINGLE * FROM /idexge/rej_noti INTO wa_rej_noti
       WHERE int_inv_doc_no = wa_out_memi-int_inv_doc_no
       AND   int_inv_line_no = wa_out_memi-int_inv_line_no.

    IF sy-subrc <> 0.
      wa_rej_noti-int_inv_doc_no = wa_out_memi-int_inv_doc_no.
      wa_rej_noti-int_inv_line_no = wa_out_memi-int_inv_line_no.
      wa_rej_noti-free_text4 = w_sval-value.
      INSERT INTO /idexge/rej_noti VALUES wa_rej_noti.
    ELSE.
      wa_rej_noti-free_text4 = w_sval-value.
      MODIFY /idexge/rej_noti FROM wa_rej_noti.
    ENDIF.

    IF sy-subrc = 0.
      wa_out_memi-free_text4 = w_sval-value.
      COMMIT WORK.
    ENDIF.

    MODIFY it_out_memi FROM wa_out_memi INDEX fp_tabindex.
  ELSEIF p_invtp = 3.
* read data from database /idexge/rej_noti
    SELECT SINGLE * FROM /idexge/rej_noti INTO wa_rej_noti
       WHERE int_inv_doc_no = wa_out_mgv-int_inv_doc_no
       AND   int_inv_line_no = wa_out_mgv-int_inv_line_no.

    IF sy-subrc <> 0.
      wa_rej_noti-int_inv_doc_no = wa_out_mgv-int_inv_doc_no.
      wa_rej_noti-int_inv_line_no = wa_out_mgv-int_inv_line_no.
      wa_rej_noti-free_text4 = w_sval-value.
      INSERT INTO /idexge/rej_noti VALUES wa_rej_noti.
    ELSE.
      wa_rej_noti-free_text4 = w_sval-value.
      MODIFY /idexge/rej_noti FROM wa_rej_noti.
    ENDIF.

    IF sy-subrc = 0.
      wa_out_mgv-free_text4 = w_sval-value.
      COMMIT WORK.
    ENDIF.

    MODIFY it_out_mgv FROM wa_out_mgv INDEX fp_tabindex.
* --> Nuss 09.2018
  ELSEIF p_invtp = 4.
* read data from database /idexge/rej_noti
    SELECT SINGLE * FROM /idexge/rej_noti INTO wa_rej_noti
       WHERE int_inv_doc_no = wa_out_msb-int_inv_doc_no
       AND   int_inv_line_no = wa_out_msb-int_inv_line_no.

    IF sy-subrc <> 0.
      wa_rej_noti-int_inv_doc_no = wa_out_msb-int_inv_doc_no.
      wa_rej_noti-int_inv_line_no = wa_out_msb-int_inv_line_no.
      wa_rej_noti-free_text4 = w_sval-value.
      INSERT INTO /idexge/rej_noti VALUES wa_rej_noti.
    ELSE.
      wa_rej_noti-free_text4 = w_sval-value.
      MODIFY /idexge/rej_noti FROM wa_rej_noti.
    ENDIF.

    IF sy-subrc = 0.
      wa_out_msb-free_text4 = w_sval-value.
      COMMIT WORK.
    ENDIF.

    MODIFY it_out_msb FROM wa_out_msb INDEX fp_tabindex.
* <-- Nuss 09.2018
  ENDIF.

ENDFORM.                    " INT_STATUS
*&---------------------------------------------------------------------*
*&      Form  SET_STATUS_ERL
*&---------------------------------------------------------------------*
FORM set_status_erl .

  DATA: lv_b_selected TYPE boolean.
  IF p_invtp = 1.
    LOOP AT it_out INTO wa_out WHERE sel = 'X'.
      lv_b_selected = 'X'.

      wa_out-line_state = '@0V@' .


* read data from database /idexge/rej_noti
      SELECT SINGLE * FROM /idexge/rej_noti INTO wa_rej_noti
         WHERE int_inv_doc_no = wa_out-int_inv_doc_no
         AND   int_inv_line_no = wa_out-int_inv_line_no.

      IF sy-subrc <> 0.
        wa_rej_noti-int_inv_doc_no = wa_out-int_inv_doc_no.
        wa_rej_noti-int_inv_line_no = wa_out-int_inv_line_no.
        wa_rej_noti-stat_remk = wa_out-line_state.
        INSERT INTO /idexge/rej_noti VALUES wa_rej_noti.
      ELSE.
        wa_rej_noti-stat_remk = wa_out-line_state.
        MODIFY /idexge/rej_noti FROM wa_rej_noti.
      ENDIF.

      IF sy-subrc = 0.
        COMMIT WORK.
      ELSE.
        wa_out-line_state = icon_led_red.
      ENDIF.

      MODIFY it_out FROM wa_out.
    ENDLOOP.
  ELSEIF p_invtp = 2.
    LOOP AT it_out_memi INTO wa_out_memi WHERE sel = 'X'.
      lv_b_selected = 'X'.
      wa_out_memi-line_state = '@0V@' .
* read data from database /idexge/rej_noti
      SELECT SINGLE * FROM /idexge/rej_noti INTO wa_rej_noti
         WHERE int_inv_doc_no = wa_out_memi-int_inv_doc_no
         AND   int_inv_line_no = wa_out_memi-int_inv_line_no.              "Nuss 09.2018

      IF sy-subrc <> 0.
        wa_rej_noti-int_inv_doc_no = wa_out_memi-int_inv_doc_no.
        wa_rej_noti-int_inv_line_no = wa_out_memi-int_inv_line_no.
        wa_rej_noti-stat_remk = wa_out_memi-line_state.
        INSERT INTO /idexge/rej_noti VALUES wa_rej_noti.
      ELSE.
        wa_rej_noti-stat_remk = wa_out_memi-line_state.
        MODIFY /idexge/rej_noti FROM wa_rej_noti.
      ENDIF.

      IF sy-subrc = 0.
        COMMIT WORK.
      ELSE.
        wa_out_memi-line_state = icon_led_red.
      ENDIF.

      MODIFY it_out_memi FROM wa_out_memi.
    ENDLOOP.
  ELSEIF p_invtp = 3.
    LOOP AT it_out_mgv INTO wa_out_mgv WHERE sel = 'X'.
      lv_b_selected = 'X'.
      wa_out_mgv-line_state = '@0V@' .
* read data from database /idexge/rej_noti
      SELECT SINGLE * FROM /idexge/rej_noti INTO wa_rej_noti
         WHERE int_inv_doc_no = wa_out_mgv-int_inv_doc_no
         AND   int_inv_line_no = wa_out_mgv-int_inv_line_no.

      IF sy-subrc <> 0.
        wa_rej_noti-int_inv_doc_no = wa_out_mgv-int_inv_doc_no.
        wa_rej_noti-int_inv_line_no = wa_out_mgv-int_inv_line_no.
        wa_rej_noti-stat_remk = wa_out_mgv-line_state.
        INSERT INTO /idexge/rej_noti VALUES wa_rej_noti.
      ELSE.
        wa_rej_noti-stat_remk = wa_out_mgv-line_state.
        MODIFY /idexge/rej_noti FROM wa_rej_noti.
      ENDIF.

      IF sy-subrc = 0.
        COMMIT WORK.
      ELSE.
        wa_out_mgv-line_state = icon_led_red.
      ENDIF.

      MODIFY it_out_mgv FROM wa_out_mgv.
    ENDLOOP.
* --> Nuss 09.2018
  ELSEIF p_invtp = 4.
    LOOP AT it_out_msb INTO wa_out_msb WHERE sel = 'X'.
      lv_b_selected = 'X'.
      wa_out_msb-line_state = '@0V@' .
* read data from database /idexge/rej_noti
      SELECT SINGLE * FROM /idexge/rej_noti INTO wa_rej_noti
         WHERE int_inv_doc_no = wa_out_msb-int_inv_doc_no
         AND   int_inv_line_no = wa_out_msb-int_inv_line_no.

      IF sy-subrc <> 0.
        wa_rej_noti-int_inv_doc_no = wa_out_msb-int_inv_doc_no.
        wa_rej_noti-int_inv_line_no = wa_out_msb-int_inv_line_no.
        wa_rej_noti-stat_remk = wa_out_msb-line_state.
        INSERT INTO /idexge/rej_noti VALUES wa_rej_noti.
      ELSE.
        wa_rej_noti-stat_remk = wa_out_msb-line_state.
        MODIFY /idexge/rej_noti FROM wa_rej_noti.
      ENDIF.

      IF sy-subrc = 0.
        COMMIT WORK.
      ELSE.
        wa_out_msb-line_state = icon_led_red.
      ENDIF.

      MODIFY it_out_msb FROM wa_out_msb.
    ENDLOOP.
* <-- Nuss 09.2018

  ENDIF.



  IF lv_b_selected EQ abap_false.
    MESSAGE e000(e4) WITH 'Bitte selektieren Sie einen Datensatz.'.
    EXIT.
  ENDIF.

ENDFORM.                    " SET_STATUS_ERL
FORM init_custom_fields.
  FIELD-SYMBOLS: <var> , <tab> TYPE STANDARD TABLE .
  DATA: gv_string TYPE string,
        gv_cust   TYPE /adesso/fi_remad,
        gv_type   TYPE typ.
  SELECT  * FROM /adesso/fi_remad INTO gv_cust WHERE negrem_option = 'SELSCREEN'.
    gv_string = gv_cust-negrem_field && '[]'.
    ASSIGN (gv_cust-negrem_field) TO <var>.
    IF sy-subrc = 0.

      DESCRIBE  FIELD <var> TYPE gv_type.
      IF gv_cust-negrem_id = 0."Select
        ASSIGN (gv_string) TO <tab>.
        REFRESH <tab>.
        IF sy-subrc = 0.
          " IF <var> IS INITIAL.
          <var> = gv_cust-negrem_value.
          APPEND <var> TO <tab>.
          " ENDIF.
        ENDIF.
      ELSEIF  gv_cust-negrem_id = 1."Param
        <var> = gv_cust-negrem_value.
      ENDIF.
    ENDIF.
  ENDSELECT.


ENDFORM.

FORM mahnsperre_entfernen.

  DATA: lt_opbel TYPE fkkopkey_t.
  DATA: ls_opbel TYPE fkkopkey.
  DATA: l_answer TYPE char1.
  DATA ls_memidoc_u TYPE /idxmm/memidoc.
  DATA lt_memidoc_u TYPE /idxmm/t_memi_doc.
  DATA lr_memidoc TYPE REF TO /idxmm/cl_memi_document_db.
  FIELD-SYMBOLS <t_out> LIKE LINE OF it_out.
  FIELD-SYMBOLS <t_out_memi> LIKE LINE OF it_out_memi.
  FIELD-SYMBOLS <t_out_mgv> LIKE LINE OF it_out_mgv.
  FIELD-SYMBOLS <t_out_msb> LIKE LINE OF it_out_msb.           "Nuss 09.2018-2

  IF p_invtp <> 3.
* Sicherheitsabfrage
    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
      EXPORTING
        defaultoption = 'Y'
        textline1     = TEXT-124
        textline2     = TEXT-125
        titel         = TEXT-t05
      IMPORTING
        answer        = l_answer.

    IF NOT l_answer CA 'jJyY'.
      EXIT.
    ENDIF.
  ENDIF.



  IF p_invtp = '1'.

    LOOP AT it_out ASSIGNING <t_out> WHERE sel IS NOT INITIAL.


*    CHECK sy-subrc NE 0.

*      CHECK <t_out> IS NOT INITIAL.
      REFRESH lt_opbel.
      CLEAR ls_opbel.

      ls_opbel-opbel = <t_out>-opbel.
      ls_opbel-opupw = <t_out>-opupw.
      ls_opbel-opupk = <t_out>-opupk.
      ls_opbel-opupz = <t_out>-opupz.
      APPEND ls_opbel TO lt_opbel.

      DATA lt_locks TYPE TABLE OF dfkklocks.
      DATA ls_locks TYPE dfkklocks.
      CALL FUNCTION 'FKK_S_LOCK_GET_FOR_DOC_ITEMS'
        EXPORTING
          i_opbel  = <t_out>-opbel
          i_opupw  = <t_out>-opupw
          i_opupk  = <t_out>-opupk
          i_opupz  = <t_out>-opupz
        TABLES
          et_locks = lt_locks.

      READ TABLE lt_locks INTO ls_locks INDEX 1.

      CALL FUNCTION 'FKK_S_LOCK_DELETE_FOR_DOCITEMS'
        EXPORTING
          iv_opbel    = <t_out>-opbel
          it_fkkopkey = lt_opbel
          iv_proid    = ls_locks-proid
          iv_lockr    = ls_locks-lockr
          iv_fdate    = ls_locks-fdate
          iv_tdate    = ls_locks-tdate
        EXCEPTIONS
          OTHERS      = 5.

      IF sy-subrc <> 0.
        <t_out>-process_state = icon_breakpoint.
      ELSE.
        <t_out>-process_state = icon_unlocked.
      ENDIF.

** Sperren der OPBELS wieder aufheben
      CALL FUNCTION 'FKK_DEQ_OPBELS_AFTER_CHANGES'
        EXPORTING
          _scope          = '3'
          i_only_document = ' '.
    ENDLOOP.
  ELSEIF p_invtp = '3'.

    LOOP AT it_out_mgv ASSIGNING <t_out_mgv> WHERE sel IS NOT INITIAL.


*    CHECK sy-subrc NE 0.

*      CHECK <t_out> IS NOT INITIAL.
      REFRESH lt_opbel.
      CLEAR ls_opbel.

      ls_opbel-opbel = <t_out_mgv>-opbel.
      ls_opbel-opupw = <t_out_mgv>-opupw.
      ls_opbel-opupk = <t_out_mgv>-opupk.
      ls_opbel-opupz = <t_out_mgv>-opupz.
      APPEND ls_opbel TO lt_opbel.

      CALL FUNCTION 'FKK_S_LOCK_GET_FOR_DOC_ITEMS'
        EXPORTING
          i_opbel  = <t_out_mgv>-opbel
          i_opupw  = <t_out_mgv>-opupw
          i_opupk  = <t_out_mgv>-opupk
          i_opupz  = <t_out_mgv>-opupz
        TABLES
          et_locks = lt_locks.

      READ TABLE lt_locks INTO ls_locks INDEX 1.

      CALL FUNCTION 'FKK_S_LOCK_DELETE_FOR_DOCITEMS'
        EXPORTING
          iv_opbel    = <t_out_mgv>-opbel
          it_fkkopkey = lt_opbel
          iv_proid    = ls_locks-proid
          iv_lockr    = ls_locks-lockr
          iv_fdate    = ls_locks-fdate
          iv_tdate    = ls_locks-tdate
        EXCEPTIONS
          OTHERS      = 5.

      IF sy-subrc <> 0.
        <t_out_mgv>-process_state = icon_breakpoint.
      ELSE.
        <t_out_mgv>-process_state = icon_unlocked.
      ENDIF.

** Sperren der OPBELS wieder aufheben
      CALL FUNCTION 'FKK_DEQ_OPBELS_AFTER_CHANGES'
        EXPORTING
          _scope          = '3'
          i_only_document = ' '.
    ENDLOOP.
*<<< UH 08042013
  ELSEIF  p_invtp = '2'.
    DATA lv_done TYPE abap_bool.
    LOOP AT it_out_memi ASSIGNING <t_out_memi> WHERE sel IS NOT INITIAL.

*       --> Nuss 12.02.2018
*      CHECK <t_out_memi>-process_state = icon_locked OR
*            <t_out_memi>-process_state = icon_led_yellow.
*
*      UPDATE /adesso/hmv_mloc SET
*      azeit     = sy-timlo
*      adatum    = sy-datum
*      aenam     = sy-uname
*      lvorm     = 'X'
*      WHERE doc_id = <t_out_memi>-doc_id AND
*      fdate = <t_out_memi>-fdate AND
*      tdate = <t_out_memi>-tdate .
*
*      IF sy-subrc = 0.
*        <t_out_memi>-mahnsp = ''.
*        <t_out_memi>-fdate = ''.
*        <t_out_memi>-tdate = ''.
*        <t_out_memi>-process_state = icon_unlocked.
*      ENDIF.

      CALL FUNCTION '/ADESSO/MEMI_MAHNSPERRE'
        EXPORTING
          iv_belnr    = <t_out_memi>-doc_id
*         IX_GET_LOCKHIST  =
*         IX_SET_LOCK =
          ix_del_lock = 'X'
*         IV_NO_POPUP =
        IMPORTING
          ev_done     = lv_done.
*        changing
*          iv_date_from =
*          iv_date_to   =
*          iv_lockr     =.

      IF lv_done = 'X'.
        <t_out_memi>-mahnsp = ''.
        <t_out_memi>-fdate = ''.
        <t_out_memi>-tdate = ''.
        <t_out_memi>-process_state = icon_unlocked.
      ENDIF.


*      CREATE OBJECT lr_memidoc.
*      SELECT SINGLE * FROM /idxmm/memidoc INTO ls_memidoc_u WHERE doc_id = <t_out_memi>-doc_id.
*
*      DATA lv_memi_state_lock TYPE /idxmm/memidoc-doc_status.
*      SELECT SINGLE negrem_value FROM /adesso/fi_remad INTO lv_memi_state_lock WHERE negrem_option = 'MAHNSPERRSTAT' AND negrem_field = 'MEMI' .
*      IF ls_memidoc_u-doc_status = lv_memi_state_lock.
*        IF <t_out_memi>-invoic_idoc IS INITIAL.
*          ls_memidoc_u-doc_status = 50.
*        ELSE.
*          ls_memidoc_u-doc_status = 60.
*        ENDIF.
*        APPEND ls_memidoc_u TO lt_memidoc_u.
**        TRY.
*        CALL METHOD /idxmm/cl_memi_document_db=>update
*          EXPORTING
**           iv_simulate   =
*            it_doc_update = lt_memidoc_u.
**           CATCH /idxmm/cx_bo_error .
**          ENDTRY.
*
*        IF sy-subrc = 0.
*          <t_out_memi>-process_state = icon_unlocked.
*          <t_out_memi>-doc_status = ls_memidoc_u-doc_status.
*
*        ENDIF.
*      ENDIF.
*     <-- Nuss 12.02.2018



    ENDLOOP.
* --> Nuss 09.2018-2
  ELSEIF p_invtp = 4.

    LOOP AT it_out_msb ASSIGNING <t_out_msb> WHERE sel IS NOT INITIAL.


*    CHECK sy-subrc NE 0.

*      CHECK <t_out> IS NOT INITIAL.
      REFRESH lt_opbel.
      CLEAR ls_opbel.

      ls_opbel-opbel = <t_out_msb>-opbel.
      ls_opbel-opupk = '0001'.

      APPEND ls_opbel TO lt_opbel.


      CALL FUNCTION 'FKK_S_LOCK_GET_FOR_DOC_ITEMS'
        EXPORTING
          i_opbel  = <t_out_msb>-opbel
          i_opupw  = '000'
          i_opupk  = '0001'
          i_opupz  = '000'
        TABLES
          et_locks = lt_locks.

      READ TABLE lt_locks INTO ls_locks INDEX 1.

      CALL FUNCTION 'FKK_S_LOCK_DELETE_FOR_DOCITEMS'
        EXPORTING
          iv_opbel    = <t_out_msb>-opbel
          it_fkkopkey = lt_opbel
          iv_proid    = ls_locks-proid
          iv_lockr    = ls_locks-lockr
          iv_fdate    = ls_locks-fdate
          iv_tdate    = ls_locks-tdate
        EXCEPTIONS
          OTHERS      = 5.

      IF sy-subrc <> 0.
        <t_out_msb>-process_state = icon_breakpoint.
      ELSE.
        <t_out_msb>-process_state = icon_unlocked.
      ENDIF.

** Sperren der OPBELS wieder aufheben
      CALL FUNCTION 'FKK_DEQ_OPBELS_AFTER_CHANGES'
        EXPORTING
          _scope          = '3'
          i_only_document = ' '.
    ENDLOOP.
* <-- Nuss 09.2018-2

  ENDIF.


ENDFORM.                    " MAHNSPERRE_LOESCHEN
** --> Nuss 28.03.2017
*&---------------------------------------------------------------------*
*&      Form  DATEN_SELEKTIEREN_MGV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM daten_selektieren_mgv .

* Nuss 08.2012

* Anpassung Coding
* Rechnungskopf selektieren
*  SELECT * FROM tinv_inv_head INTO wa_inv_head
*    WHERE int_sender IN s_send
*      AND invoice_type EQ co_invtype
*      AND date_of_receipt IN s_dtrec
*      AND invoice_status IN s_insta.


  SELECT h~int_inv_no      h~invoice_type
         h~date_of_receipt h~invoice_status
         h~int_receiver    h~int_sender
         d~int_inv_doc_no  d~ext_invoice_no
         d~doc_type        d~inv_doc_status
         d~date_of_payment d~invoice_date
    INTO CORRESPONDING FIELDS OF wa_inv_head_doc
    FROM tinv_inv_head AS h
      INNER JOIN tinv_inv_doc AS d
      ON h~int_inv_no EQ d~int_inv_no
    WHERE h~int_sender IN s_send
      AND h~invoice_type EQ co_mgvtype
      AND h~date_of_receipt IN s_dtrec
      AND h~invoice_status IN s_insta
      AND h~int_receiver IN s_rece
      AND d~int_inv_doc_no IN s_intido
      AND d~ext_invoice_no IN s_extido
      AND d~doc_type IN s_doctyp
      AND d~inv_doc_status IN s_idosta
      AND d~date_of_payment IN s_dtpaym.

*    CHECK wa_inv_head-int_receiver IN s_rece.
    x_ctrem = x_ctrem + 1.
*   Felder aus HEADER füllen.
*    MOVE wa_inv_head-int_receiver    TO wa_out-int_receiver.
*    MOVE wa_inv_head-int_sender      TO wa_out-int_sender.
*    MOVE wa_inv_head-invoice_status  TO wa_out-invoice_status.
*    MOVE wa_inv_head-date_of_receipt TO wa_out-date_of_receipt.
    MOVE wa_inv_head_doc-int_receiver TO wa_out_mgv-int_receiver.
    MOVE wa_inv_head_doc-int_sender   TO wa_out_mgv-int_sender.
    MOVE wa_inv_head_doc-invoice_status   TO wa_out_mgv-invoice_status.
    MOVE wa_inv_head_doc-date_of_receipt  TO wa_out_mgv-date_of_receipt.
*
    SELECT SINGLE a~vkont INTO wa_out_mgv-aggvk
      FROM fkkvk AS a
       INNER JOIN fkkvkp AS b
         ON b~vkont = a~vkont
      INNER JOIN eservprovp AS c
        ON c~bpart = b~gpart
        WHERE c~serviceid = wa_out_mgv-int_sender
        AND a~vktyp  IN r_vktyp.

* Rechnungsbelegdaten selektieren
*    SELECT * FROM tinv_inv_doc INTO wa_inv_doc
*      WHERE int_inv_doc_no IN s_intido
*        AND int_inv_no EQ wa_inv_head-int_inv_no
*        AND ext_invoice_no IN s_extido
*        AND doc_type IN s_doctyp
*        AND inv_doc_status IN s_idosta
*        AND date_of_payment IN s_dtpaym.
*
*       WA_OUT füllen
*      MOVE wa_inv_doc-int_inv_doc_no   TO wa_out-int_inv_doc_no.
*      MOVE wa_inv_doc-ext_invoice_no   TO wa_out-ext_invoice_no.
*      MOVE wa_inv_doc-doc_type         TO wa_out-doc_type.
*      MOVE wa_inv_doc-inv_doc_status   TO wa_out-inv_doc_status.
*      MOVE wa_inv_doc-date_of_payment  TO wa_out-date_of_payment.
*      MOVE wa_inv_doc-invoice_date     TO wa_out-invoice_date.

    MOVE wa_inv_head_doc-int_inv_doc_no TO wa_out_mgv-int_inv_doc_no.
    MOVE wa_inv_head_doc-ext_invoice_no TO wa_out_mgv-ext_invoice_no.
    MOVE wa_inv_head_doc-doc_type TO wa_out_mgv-doc_type.
    MOVE wa_inv_head_doc-inv_doc_status TO wa_out_mgv-inv_doc_status.
    MOVE wa_inv_head_doc-date_of_payment TO wa_out_mgv-date_of_payment.
    MOVE wa_inv_head_doc-invoice_date TO wa_out_mgv-invoice_date.
*
* AVIS-Zeilen
    CLEAR wa_inv_line_a.
    SELECT * FROM tinv_inv_line_a INTO wa_inv_line_a
*      WHERE int_inv_doc_no EQ wa_inv_doc-int_inv_doc_no         "Nuss 08.2012
        WHERE int_inv_doc_no EQ wa_inv_head_doc-int_inv_doc_no   "Nuss 08.2012
        AND  rstgr IN s_rstgr
        AND  own_invoice_no IN s_owninv.

      CHECK wa_inv_line_a-rstgr IS NOT INITIAL.
      CHECK wa_inv_line_a-own_invoice_no IS NOT INITIAL.

*   Nuss: 11.09.2012
*   Füllen der Ausgabedaten nochmals, wenn mehrere Zeilen im AVIS
      IF wa_out-int_inv_doc_no IS INITIAL.
        MOVE wa_inv_head_doc-int_receiver TO wa_out_mgv-int_receiver.
        MOVE wa_inv_head_doc-int_sender   TO wa_out_mgv-int_sender.
        MOVE wa_inv_head_doc-invoice_status   TO wa_out_mgv-invoice_status.
        MOVE wa_inv_head_doc-date_of_receipt  TO wa_out_mgv-date_of_receipt.
        MOVE wa_inv_head_doc-int_inv_doc_no TO wa_out_mgv-int_inv_doc_no.
        MOVE wa_inv_head_doc-ext_invoice_no TO wa_out_mgv-ext_invoice_no.
        MOVE wa_inv_head_doc-doc_type TO wa_out_mgv-doc_type.
        MOVE wa_inv_head_doc-inv_doc_status TO wa_out_mgv-inv_doc_status.
        MOVE wa_inv_head_doc-date_of_payment TO wa_out_mgv-date_of_payment.
        MOVE wa_inv_head_doc-invoice_date TO wa_out_mgv-invoice_date.
      ENDIF.
*  <-- Nuss 11.09.2012

* Text zum Rückstellungsgrund
      CLEAR wa_inv_c_adj_rsnt.
      SELECT SINGLE * FROM tinv_c_adj_rsnt
         INTO wa_inv_c_adj_rsnt
           WHERE rstgr = wa_inv_line_a-rstgr
           AND spras = sy-langu.

* Langtext falls vorhanden
      CLEAR wa_noti.
      SELECT * FROM /idexge/rej_noti INTO wa_noti
        WHERE int_inv_doc_no = wa_inv_head_doc-int_inv_doc_no
        AND int_inv_line_no = wa_inv_line_a-int_inv_line_no.
        wa_out_mgv-free_text5 = wa_noti-free_text5.
        IF wa_noti-stat_remk(3) = '@0V'.
          wa_out_mgv-line_state = icon_okay.
        ENDIF.
        EXIT.
      ENDSELECT.
*        ENDIF.
*
*
*     WA_OUT füllen
      MOVE wa_inv_line_a-int_inv_line_no TO wa_out_mgv-int_inv_line_no.
      MOVE wa_inv_line_a-rstgr          TO wa_out_mgv-rstgr.
      MOVE wa_inv_c_adj_rsnt-text       TO wa_out_mgv-text.
      MOVE wa_noti-free_text1           TO wa_out_mgv-free_text1.
      MOVE wa_inv_line_a-own_invoice_no TO wa_out_mgv-own_invoice_no.
      MOVE wa_inv_line_a-betrw_req      TO wa_out_mgv-betrw_req.


**    <-- Nuss 27.07.2012

*  Externer Zählpunkt
      CLEAR wa_ecrossrefno.

      SELECT * FROM ecrossrefno INTO wa_ecrossrefno
        WHERE crossrefno = wa_inv_line_a-own_invoice_no(15)
        OR    crn_rev = wa_inv_line_a-own_invoice_no(15).
        EXIT.
      ENDSELECT.

      MOVE-CORRESPONDING wa_ecrossrefno TO wa_out_mgv.

      DATA ls_paym LIKE wa_paym.
      SELECT SINGLE a~own_invoice_no
       a~int_inv_doc_no
       c~invoice_status
  INTO CORRESPONDING FIELDS OF ls_paym
  FROM tinv_inv_line_a AS a
       INNER JOIN tinv_inv_doc AS b
       ON b~int_inv_doc_no = a~int_inv_doc_no
       INNER JOIN tinv_inv_head AS c
       ON c~int_inv_no = b~int_inv_no
*      FOR ALL ENTRIES IN t_crsrf_eui
  WHERE a~own_invoice_no = wa_ecrossrefno-crossrefno
    AND a~int_inv_doc_no = wa_out_mgv-int_inv_doc_no.   "Nuss 12.03.2018


      IF sy-subrc = 0.
        wa_out_mgv-paym_avis = ls_paym-int_inv_doc_no.
        wa_out_mgv-paym_stat = ls_paym-invoice_status.
      ENDIF.



      SORT t_paym BY own_invoice_no.

      DATA: b_storno TYPE boolean.
      b_storno = abap_false.
      CLEAR wa_out_mgv-inf_invoice_cancel.

      IF wa_ecrossrefno-crn_rev EQ wa_inv_line_a-own_invoice_no.
        wa_out_mgv-inf_invoice_cancel = icon_storno.
        b_storno = abap_true.
      ENDIF.

      CLEAR wa_euitrans.
      SELECT SINGLE * FROM euitrans INTO wa_euitrans
         WHERE int_ui = wa_ecrossrefno-int_ui
         AND dateto = '99991231'.

*      CHECK wa_euitrans-ext_ui IN s_extui.              "Nuss 10.2017 Melo/Malo

      MOVE wa_euitrans-ext_ui TO wa_out_mgv-ext_ui.

**    --> Nuss 10.2017  Melo/Malo
      CLEAR: it_idxgc_pod_rel, wa_idxgc_pod_rel.
      IF wa_euitrans-uistrutyp = 'MA'.
        SELECT * FROM /idxgc/pod_rel INTO TABLE it_idxgc_pod_rel
          WHERE int_ui2 = wa_ecrossrefno-int_ui.
      ENDIF.
      IF sy-subrc = 0.
        DESCRIBE TABLE it_idxgc_pod_rel LINES gv_podlines.
        READ TABLE it_idxgc_pod_rel INTO wa_idxgc_pod_rel INDEX 1.
        CLEAR wa_euitrans_melo.
        SELECT SINGLE * FROM euitrans INTO wa_euitrans_melo
           WHERE int_ui = wa_idxgc_pod_rel-int_ui1
           AND dateto = '99991231'.
        MOVE wa_euitrans_melo-ext_ui TO wa_out_memi-ext_ui_melo.
        IF gv_podlines GT 1.
          MOVE 'X' TO wa_out_memi-mult_melo.
        ENDIF.
      ENDIF.
**  <-- Nuss 10.2017 Melo/Malo


* Abrechnungsklasse ermitteln
      SELECT aklasse INTO wa_out_mgv-aklasse
        FROM eanlh AS a
          INNER JOIN euiinstln AS b
          ON b~anlage = a~anlage
          INNER JOIN euitrans AS c
           ON c~int_ui = b~int_ui
        WHERE c~ext_ui = wa_out_mgv-ext_ui
          AND c~dateto = '99991231'
          AND a~bis = '99991231'.
        EXIT.
      ENDSELECT.


      DATA: ls_dfkkinvdoc_h  TYPE dfkkinvdoc_h,
            ls_crossrefno    TYPE ecrossrefno,
            ls_dfkkinvbill_x TYPE dfkkinvbill_x,
            ls_dfkkinvdoc_x  TYPE dfkkinvdoc_x.

      SELECT SINGLE * FROM ecrossrefno INTO ls_crossrefno WHERE int_crossrefno = wa_out_mgv-int_crossrefno.
*    SELECT DFKKINVDOC_H
      SELECT SINGLE  * FROM dfkkinvdoc_h INTO CORRESPONDING FIELDS OF  wa_out_mgv WHERE
       invdocno = ls_crossrefno-belnr.

      "Abrechnungsbeleg selektieren
      SELECT SINGLE * FROM dfkkinvdoc_x INTO ls_dfkkinvdoc_x WHERE refobjname = 'MGV_SSQNOT' AND invdocno = wa_out_mgv-invdocno.
      SELECT SINGLE * FROM dfkkinvbill_x INTO ls_dfkkinvbill_x WHERE refobjname = 'MGV_SSQNOT' AND refobjvalue = ls_dfkkinvdoc_x-refobjvalue.
      SELECT SINGLE * FROM dfkkinvbill_h INTO CORRESPONDING FIELDS OF wa_out_mgv WHERE billdocno = ls_dfkkinvbill_x-billdocno.

*PDOC Nummer holen
      SELECT SINGLE * FROM dfkkinvdoc_x INTO ls_dfkkinvdoc_x WHERE refobjname = 'MGV_PDOC' AND invdocno = wa_out_mgv-invdocno.
      wa_out_mgv-proc_ref = ls_dfkkinvdoc_x-refobjvalue.
      SELECT SINGLE dfkkop~opbel dfkkop~opupk dfkkop~opupw dfkkop~opupz
        FROM dfkkinvdoc_p
        INNER JOIN dfkkop ON dfkkop~opbel = dfkkinvdoc_p~opbel
        INTO (wa_out_mgv-opbel, wa_out_mgv-opupk ,wa_out_mgv-opupw, wa_out_mgv-opupz)
        WHERE invdocno = wa_out_mgv-invdocno.

      SELECT SINGLE * FROM dfkkthi INTO wa_dfkkthi
      WHERE opbel = wa_out_mgv-opbel
      AND opupk = wa_out_mgv-opupk
      AND opupw = wa_out_mgv-opupw.
      MOVE-CORRESPONDING wa_dfkkthi TO wa_dfkkthi_op.
      MOVE-CORRESPONDING wa_out_mgv TO wa_dfkkthi_op.
      ASSIGN wa_dfkkthi_op TO <fs_dfkkthi_op>.
      PERFORM get_locks.
      PERFORM sel_bcontact_mgv USING wa_out_mgv.
      APPEND wa_out_mgv TO it_out_mgv.
      CLEAR wa_out_mgv.
*
    ENDSELECT.

*    ENDSELECT.                                          "TINV_INV_DOC
*
  ENDSELECT.                                            "TINV_INV_HEAD

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  DATEN_SELEKTIEREN_MGV_OLD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM daten_selektieren_mgv_old .

  DATA lv_invtype TYPE tinv_inv_head-invoice_type.
  lv_invtype = co_mgvtype.

* Texte zum Rückstellungsgrund
  SELECT * FROM tinv_c_adj_rsnt
           INTO TABLE t_inv_c_adj_rsnt
           WHERE spras = sy-langu.

* Hilfsrange Sender auf Selektionsrange übertragen
  IF r_send[] IS NOT INITIAL AND s_send[] IS INITIAL.
    s_send[] = r_send[].
  ENDIF.

* Reklamationsavise
  SELECT a~int_inv_doc_no
         a~int_inv_no
         a~int_partner
         a~doc_type
         a~invoice_date
         a~date_of_payment
         a~inv_doc_status
         a~int_ident
         a~invoice_type
         a~int_sender
         a~int_receiver
         a~date_of_receipt
         a~invoice_status
         a~auth_grp
         a~ext_invoice_no
         a~inv_bulk_ref
         b~int_inv_line_no
         b~rstgr
         b~own_invoice_no
         b~betrw_req
         c~free_text1
         c~free_text5
    INTO CORRESPONDING FIELDS OF TABLE t_remadv
    FROM vinv_monitoring AS a
         INNER JOIN tinv_inv_line_a AS b
         ON b~int_inv_doc_no = a~int_inv_doc_no
         LEFT OUTER JOIN /idexge/rej_noti AS c
         ON  c~int_inv_doc_no  = b~int_inv_doc_no
         AND c~int_inv_line_no = b~int_inv_line_no
    WHERE a~int_sender IN s_send
      AND a~int_receiver IN s_rece
      AND a~invoice_type EQ lv_invtype
      AND a~date_of_receipt IN s_dtrec
      AND a~invoice_status IN s_insta
      AND a~int_inv_doc_no IN s_intido
      AND a~ext_invoice_no IN s_extido
      AND a~doc_type IN s_doctyp
      AND a~inv_doc_status IN s_idosta
      AND a~date_of_payment IN s_dtpaym
      AND a~invoice_date IN s_invoda
      AND b~line_type EQ co_linetype
      AND b~rstgr IN s_rstgr
      AND b~own_invoice_no IN s_owninv.

  SORT t_remadv.

* Überschreiben FREE_:TEXT5 aus Text-Editor
  IF t_remadv[] IS NOT INITIAL.
    LOOP AT t_remadv ASSIGNING <fs_remadv>.
      CLEAR gv_name.
      CONCATENATE <fs_remadv>-int_inv_doc_no
                  '_'
                  <fs_remadv>-int_inv_line_no
                  INTO gv_name.

      CLEAR xlines.
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
*         CLIENT                  = SY-MANDT
          id                      = co_id
          language                = sy-langu
          name                    = gv_name
          object                  = co_object
*         ARCHIVE_HANDLE          = 0
*         LOCAL_CAT               = ' '
*   IMPORTING
*         HEADER                  =
*         OLD_LINE_COUNTER        =
        TABLES
          lines                   = xlines
        EXCEPTIONS
          id                      = 1
          language                = 2
          name                    = 3
          not_found               = 4
          object                  = 5
          reference_check         = 6
          wrong_access_to_archive = 7
          OTHERS                  = 8.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      READ TABLE xlines INTO help_line INDEX 1.

      IF sy-subrc = 0.
        <fs_remadv>-free_text5 = help_line.
*    MODIFY it_out FROM wa_out INDEX fp_tabindex.
      ENDIF.
*
    ENDLOOP.
  ENDIF.

*  Crossreference und Externer Zählpunkt
  IF t_remadv[] IS NOT INITIAL.
    CLEAR t_crsrf_eui.
    SELECT a~int_crossrefno
           a~int_ui
           a~crossrefno
           a~crn_rev
           b~ext_ui
           b~dateto
      INTO CORRESPONDING FIELDS OF TABLE t_crsrf_eui
      FROM ecrossrefno AS a
           LEFT OUTER JOIN euitrans AS b
           ON b~int_ui = a~int_ui
      FOR ALL ENTRIES IN t_remadv
      WHERE ( a~crossrefno = t_remadv-own_invoice_no
      OR      a~crn_rev    = t_remadv-own_invoice_no ).

    SORT t_crsrf_eui BY int_crossrefno.

    DELETE t_crsrf_eui WHERE dateto NE '99991231'.

    DELETE ADJACENT DUPLICATES FROM t_crsrf_eui.

* Für den nächsten Zugriff auf Zahlungsavise besser nach crossrefno sortieren
* UH 19082016
*    SORT t_crsrf_eui BY int_crossrefno.
    SORT t_crsrf_eui BY crossrefno.

  ENDIF.

* Zahlungsavise
  IF t_crsrf_eui[] IS NOT INITIAL.

    SELECT a~own_invoice_no
           a~int_inv_doc_no
           c~invoice_status
      INTO CORRESPONDING FIELDS OF TABLE t_paym
      FROM tinv_inv_line_a AS a
           INNER JOIN tinv_inv_doc AS b
           ON b~int_inv_doc_no = a~int_inv_doc_no
           INNER JOIN tinv_inv_head AS c
           ON c~int_inv_no = b~int_inv_no
      FOR ALL ENTRIES IN t_crsrf_eui
      WHERE a~own_invoice_no = t_crsrf_eui-crossrefno
      AND   a~line_type      = co_linetype
      AND   b~doc_type       = co_docpaym
      AND   c~invoice_type   = co_invpaym.

* Zahlungavise zu stornierten Rechnungen gesondert betrachten
* UH 19082016
  ENDIF.


* Ist das Feld crn_rev nie gefüllt kommt es zum Laufzeitfehler
* da die komplette DB durchsucht wird
* daher vorher alle leeren crn_rev eliminieren
* UH 19082016

  t_crsrf_eu2[] = t_crsrf_eui[].

  SORT t_crsrf_eu2 BY crn_rev.
  DELETE t_crsrf_eu2 WHERE crn_rev = space.
  DELETE ADJACENT DUPLICATES FROM t_crsrf_eu2.

  IF t_crsrf_eu2[] IS NOT INITIAL.

    SELECT a~own_invoice_no
           a~int_inv_doc_no
           c~invoice_status
      APPENDING CORRESPONDING FIELDS OF TABLE t_paym
      FROM tinv_inv_line_a AS a
           INNER JOIN tinv_inv_doc AS b
           ON b~int_inv_doc_no = a~int_inv_doc_no
           INNER JOIN tinv_inv_head AS c
           ON c~int_inv_no = b~int_inv_no
      FOR ALL ENTRIES IN t_crsrf_eu2
      WHERE a~own_invoice_no = t_crsrf_eu2-crn_rev
      AND   a~line_type      = co_linetype
      AND   b~doc_type       = co_docpaym
      AND   c~invoice_type   = co_invpaym.

  ENDIF.

  SORT t_paym BY own_invoice_no.

  SORT t_crsrf_eui BY crossrefno.
  SORT t_crsrf_eu2 BY crn_rev.

  LOOP AT t_remadv ASSIGNING <fs_remadv>.
*
    AT NEW int_inv_doc_no.
      x_ctrem = x_ctrem + 1.
    ENDAT.

    CLEAR wa_out_mgv.
    MOVE-CORRESPONDING <fs_remadv> TO wa_out_mgv.

** Aggr. Vertragskonto ermitteln
    SELECT SINGLE a~vkont INTO wa_out_mgv-aggvk
      FROM fkkvk AS a
       INNER JOIN fkkvkp AS b
         ON b~vkont = a~vkont
      INNER JOIN eservprovp AS c
        ON c~bpart = b~gpart
        WHERE c~serviceid = <fs_remadv>-int_sender
        AND a~vktyp IN r_vktyp.


** Text zum Rückstellungsgrund
    READ TABLE t_inv_c_adj_rsnt
         INTO  wa_inv_c_adj_rsnt
         WITH KEY rstgr = <fs_remadv>-rstgr
                  spras = sy-langu.
    IF sy-subrc = 0.
      wa_out_mgv-text = wa_inv_c_adj_rsnt-text.
    ENDIF.

* Crosreferenz / Zählpunkt
    READ TABLE t_crsrf_eui
         ASSIGNING <fs_crsrf_eui>
         WITH KEY crossrefno = <fs_remadv>-own_invoice_no
         BINARY SEARCH.

    IF sy-subrc = 0 AND <fs_crsrf_eui> IS ASSIGNED.
      b_storno = abap_false.
      wa_out_mgv-ext_ui         = <fs_crsrf_eui>-ext_ui.
      wa_out_mgv-int_crossrefno = <fs_crsrf_eui>-int_crossrefno.
*      wa_out_mgv-crossrefno = <fs_crsrf_eui>-crossrefno.
    ELSE.
      READ TABLE t_crsrf_eu2
           ASSIGNING <fs_crsrf_eui>
           WITH KEY crn_rev = <fs_remadv>-own_invoice_no
           BINARY SEARCH.
      IF sy-subrc = 0 AND <fs_crsrf_eui> IS ASSIGNED.
        wa_out_mgv-inf_invoice_cancel = icon_status_reverse.
        wa_out_mgv-ext_ui         = <fs_crsrf_eui>-ext_ui.
        wa_out_mgv-int_crossrefno = <fs_crsrf_eui>-int_crossrefno.
*        wa_out_mgv-crossrefno = <fs_crsrf_eui>-crossrefno.
        b_storno = abap_true.
      ENDIF.
    ENDIF.

    SELECT * FROM /idexge/rej_noti INTO wa_noti
      WHERE int_inv_doc_no = wa_out_mgv-int_inv_doc_no.
      IF wa_noti-stat_remk(3) = '@0V'.
        wa_out_mgv-line_state = icon_okay.
      ENDIF.
      EXIT.
    ENDSELECT.

    wa_out_mgv-vkont = wa_out_mgv-aggvk.
*    "  ENDIF.
*    CLEAR: lt_efindres ,ls_efindres.

*    CHECK wa_out_mgv-ext_ui IN s_extui.             "Nuss 10.2017 Melo/Malo
    CHECK wa_out_mgv-int_crossrefno IS NOT INITIAL.

* Abrechnungsklasse ermitteln
    SELECT aklasse INTO wa_out_mgv-aklasse
      FROM eanlh AS a
        INNER JOIN euiinstln AS b
        ON b~anlage = a~anlage
        INNER JOIN euitrans AS c
         ON c~int_ui = b~int_ui
      WHERE c~ext_ui = wa_out_mgv-ext_ui
        AND c~dateto = '99991231'
        AND a~bis = '99991231'.
      EXIT.
    ENDSELECT.


    MOVE-CORRESPONDING <fs_remadv> TO wa_out_mgv.
*   Zahlungsavis vorhanden?
    READ TABLE t_paym
         ASSIGNING <fs_paym>
         WITH KEY own_invoice_no = <fs_remadv>-own_invoice_no
         BINARY SEARCH.

    IF sy-subrc = 0 AND <fs_paym> IS ASSIGNED.
      wa_out_mgv-paym_avis = <fs_paym>-int_inv_doc_no.
      wa_out_mgv-paym_stat = <fs_paym>-invoice_status.
    ENDIF.

    DATA: ls_dfkkinvdoc_h  TYPE dfkkinvdoc_h,
          ls_crossrefno    TYPE ecrossrefno,
          ls_dfkkinvbill_x TYPE dfkkinvbill_x,
          ls_dfkkinvdoc_x  TYPE dfkkinvdoc_x.

    SELECT SINGLE * FROM ecrossrefno INTO ls_crossrefno WHERE int_crossrefno = wa_out_mgv-int_crossrefno.
*    SELECT DFKKINVDOC_H
    SELECT SINGLE  * FROM dfkkinvdoc_h INTO CORRESPONDING FIELDS OF  wa_out_mgv WHERE
     invdocno = ls_crossrefno-belnr.

    "Abrechnungsbeleg selektieren
    SELECT SINGLE * FROM dfkkinvdoc_x  INTO ls_dfkkinvdoc_x WHERE refobjname = 'MGV_SSQNOT' AND invdocno = wa_out_mgv-invdocno.
    SELECT SINGLE * FROM dfkkinvbill_x INTO ls_dfkkinvbill_x WHERE refobjname = 'MGV_SSQNOT' AND refobjvalue = ls_dfkkinvdoc_x-refobjvalue.
    SELECT SINGLE * FROM dfkkinvbill_h INTO CORRESPONDING FIELDS OF wa_out_mgv WHERE billdocno = ls_dfkkinvbill_x-billdocno.

*PDOC Nummer holen
    SELECT SINGLE * FROM dfkkinvdoc_x INTO ls_dfkkinvdoc_x WHERE refobjname = 'MGV_PDOC' AND invdocno = wa_out_mgv-invdocno.
    wa_out_mgv-proc_ref = ls_dfkkinvdoc_x-refobjvalue.
    SELECT SINGLE * FROM dfkkthi INTO wa_dfkkthi
      WHERE opbel = wa_out_mgv-opbel
      AND opupk = wa_out_mgv-opupk
      AND opupw = wa_out_mgv-opupw.
    MOVE-CORRESPONDING wa_dfkkthi TO wa_dfkkthi_op.
    ASSIGN wa_dfkkthi_op TO <fs_dfkkthi_op>.
    PERFORM get_locks.
    PERFORM sel_bcontact_mgv USING wa_out_mgv.
    APPEND wa_out_mgv TO it_out_mgv.
    CLEAR wa_out_mgv.

  ENDLOOP.



ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  DATEN_SELEKTIEREN_MSB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM daten_selektieren_msb .

  DATA: ls_dfkkinvdoc_h  TYPE dfkkinvdoc_h,
        ls_dfkkinvdoc_i  TYPE dfkkinvdoc_i,
        lt_dfkkinvdoc_i  TYPE STANDARD TABLE OF dfkkinvdoc_i,
        ls_dfkkinvbill_i TYPE dfkkinvbill_i,
        ls_dfkkinvbill_h TYPE dfkkinvbill_h,            "Nuss 09.2018-2
        ls_dfkkinvbill_x TYPE dfkkinvbill_x,            "Nuss 09.2018-2
        ls_dfkkbix_bip_i TYPE dfkkbix_bip_i.            "Nuss 09.2018-2

  SELECT         h~int_inv_no      h~invoice_type
                 h~date_of_receipt h~invoice_status
                 h~int_receiver    h~int_sender
                 d~int_inv_doc_no  d~ext_invoice_no
                 d~doc_type        d~inv_doc_status
                 d~date_of_payment d~invoice_date
            INTO CORRESPONDING FIELDS OF wa_inv_head_doc
            FROM tinv_inv_head AS h
              INNER JOIN tinv_inv_doc AS d
              ON h~int_inv_no EQ d~int_inv_no
            WHERE h~int_sender IN s_send
              AND h~invoice_type EQ co_msbtype
              AND h~date_of_receipt IN s_dtrec
              AND h~invoice_status IN s_insta
              AND h~int_receiver IN s_rece
              AND d~int_inv_doc_no IN s_intido
              AND d~ext_invoice_no IN s_extido
              AND d~doc_type IN s_doctyp
              AND d~inv_doc_status IN s_idosta
              AND d~date_of_payment IN s_dtpaym.

    x_ctrem = x_ctrem + 1.
*   Felder aus HEADER füllen.
    MOVE wa_inv_head_doc-int_receiver TO wa_out_msb-int_receiver.
    MOVE wa_inv_head_doc-int_sender   TO wa_out_msb-int_sender.
    MOVE wa_inv_head_doc-invoice_status   TO wa_out_msb-invoice_status.
    MOVE wa_inv_head_doc-date_of_receipt  TO wa_out_msb-date_of_receipt.

    SELECT SINGLE a~vkont INTO wa_out_msb-aggvk
      FROM fkkvk AS a
       INNER JOIN fkkvkp AS b
         ON b~vkont = a~vkont
      INNER JOIN eservprovp AS c
        ON c~bpart = b~gpart
        WHERE c~serviceid = wa_out_msb-int_sender
        AND a~vktyp  IN r_vktyp.

*       WA_OUT füllen
    MOVE wa_inv_head_doc-int_inv_doc_no TO wa_out_msb-int_inv_doc_no.
    MOVE wa_inv_head_doc-ext_invoice_no TO wa_out_msb-ext_invoice_no.
    MOVE wa_inv_head_doc-doc_type TO wa_out_msb-doc_type.
    MOVE wa_inv_head_doc-inv_doc_status TO wa_out_msb-inv_doc_status.
    MOVE wa_inv_head_doc-date_of_payment TO wa_out_msb-date_of_payment.
    MOVE wa_inv_head_doc-invoice_date TO wa_out_msb-invoice_date.

* AVIS-Zeilen
    CLEAR wa_inv_line_a.
    SELECT * FROM tinv_inv_line_a INTO wa_inv_line_a
*      WHERE int_inv_doc_no EQ wa_inv_doc-int_inv_doc_no         "Nuss 08.2012
        WHERE int_inv_doc_no EQ wa_inv_head_doc-int_inv_doc_no   "Nuss 08.2012
        AND  rstgr IN s_rstgr
        AND  own_invoice_no IN s_owninv.

      CHECK wa_inv_line_a-rstgr IS NOT INITIAL.
      CHECK wa_inv_line_a-own_invoice_no IS NOT INITIAL.

*   Füllen der Ausgabedaten nochmals, wenn mehrere Zeilen im AVIS
      IF wa_out-int_inv_doc_no IS INITIAL.
        MOVE wa_inv_head_doc-int_receiver TO wa_out_msb-int_receiver.
        MOVE wa_inv_head_doc-int_sender   TO wa_out_msb-int_sender.
        MOVE wa_inv_head_doc-invoice_status   TO wa_out_msb-invoice_status.
        MOVE wa_inv_head_doc-date_of_receipt  TO wa_out_msb-date_of_receipt.

        MOVE wa_inv_head_doc-int_inv_doc_no TO wa_out_msb-int_inv_doc_no.
        MOVE wa_inv_head_doc-ext_invoice_no TO wa_out_msb-ext_invoice_no.
        MOVE wa_inv_head_doc-doc_type TO wa_out_msb-doc_type.
        MOVE wa_inv_head_doc-inv_doc_status TO wa_out_msb-inv_doc_status.
        MOVE wa_inv_head_doc-date_of_payment TO wa_out_msb-date_of_payment.
        MOVE wa_inv_head_doc-invoice_date TO wa_out_msb-invoice_date.
      ENDIF.

* Text zum Rückstellungsgrund
      CLEAR wa_inv_c_adj_rsnt.
      SELECT SINGLE * FROM tinv_c_adj_rsnt
         INTO wa_inv_c_adj_rsnt
           WHERE rstgr = wa_inv_line_a-rstgr
           AND spras = sy-langu.

* Langtext falls vorhanden
      CLEAR wa_noti.

      SELECT * FROM /idexge/rej_noti INTO wa_noti
        WHERE int_inv_doc_no = wa_inv_head_doc-int_inv_doc_no
        AND int_inv_line_no = wa_inv_line_a-int_inv_line_no.
        wa_out_msb-free_text5 = wa_noti-free_text5.
        IF wa_noti-stat_remk(3) = '@0V'.
          wa_out_msb-line_state = icon_okay.
        ENDIF.
        EXIT.
      ENDSELECT.

*     WA_OUT füllen
      MOVE wa_inv_line_a-int_inv_line_no TO wa_out_msb-int_inv_line_no.
      MOVE wa_inv_line_a-rstgr          TO wa_out_msb-rstgr.
      MOVE wa_inv_c_adj_rsnt-text       TO wa_out_msb-text.
      MOVE wa_noti-free_text1           TO wa_out_msb-free_text1.
      MOVE wa_inv_line_a-own_invoice_no TO wa_out_msb-own_invoice_no.
      MOVE wa_inv_line_a-betrw_req      TO wa_out_msb-betrw_req.


*  Externer Zählpunkt
      CLEAR wa_ecrossrefno.

      SELECT * FROM ecrossrefno INTO wa_ecrossrefno
        WHERE crossrefno = wa_inv_line_a-own_invoice_no(15)
        OR    crn_rev = wa_inv_line_a-own_invoice_no(15).
        EXIT.
      ENDSELECT.

      MOVE-CORRESPONDING wa_ecrossrefno TO wa_out_msb.

      DATA ls_paym LIKE wa_paym.
      SELECT SINGLE a~own_invoice_no
       a~int_inv_doc_no
       c~invoice_status
  INTO CORRESPONDING FIELDS OF ls_paym
  FROM tinv_inv_line_a AS a
       INNER JOIN tinv_inv_doc AS b
       ON b~int_inv_doc_no = a~int_inv_doc_no
       INNER JOIN tinv_inv_head AS c
       ON c~int_inv_no = b~int_inv_no
*      FOR ALL ENTRIES IN t_crsrf_eui
  WHERE a~own_invoice_no = wa_out_msb-crossrefno.


      IF sy-subrc = 0.
        wa_out_msb-paym_avis = ls_paym-int_inv_doc_no.
        wa_out_msb-paym_stat = ls_paym-invoice_status.
      ENDIF.
*      AND   a~line_type      = co_linetype
*      AND   b~doc_type       = co_docpaym
*      AND   c~invoice_type   = co_invpaym.


      SORT t_paym BY own_invoice_no.

      DATA: b_storno TYPE boolean.
      b_storno = abap_false.
      CLEAR wa_out_msb-inf_invoice_cancel.
      IF wa_ecrossrefno-crn_rev EQ wa_inv_line_a-own_invoice_no.
        wa_out_msb-inf_invoice_cancel = icon_storno.
        b_storno = abap_true.
      ENDIF.

      CLEAR wa_euitrans.
      SELECT SINGLE * FROM euitrans INTO wa_euitrans
         WHERE int_ui = wa_ecrossrefno-int_ui
         AND dateto = '99991231'.


      MOVE wa_euitrans-ext_ui TO wa_out_msb-ext_ui.

**     Melo/Malo
      CLEAR: it_idxgc_pod_rel, wa_idxgc_pod_rel.
      IF wa_euitrans-uistrutyp = 'MA'.
        SELECT * FROM /idxgc/pod_rel INTO TABLE it_idxgc_pod_rel
          WHERE int_ui2 = wa_ecrossrefno-int_ui.
      ENDIF.
      IF sy-subrc = 0.
        DESCRIBE TABLE it_idxgc_pod_rel LINES gv_podlines.
        READ TABLE it_idxgc_pod_rel INTO wa_idxgc_pod_rel INDEX 1.
        CLEAR wa_euitrans_melo.
        SELECT SINGLE * FROM euitrans INTO wa_euitrans_melo
           WHERE int_ui = wa_idxgc_pod_rel-int_ui1
           AND dateto = '99991231'.
        MOVE wa_euitrans_melo-ext_ui TO wa_out_msb-ext_ui_melo.
        IF gv_podlines GT 1.
          MOVE 'X' TO wa_out_msb-mult_melo.
        ENDIF.
      ENDIF.
**   Melo/Malo


* Abrechnungsklasse ermitteln
      SELECT aklasse INTO wa_out_msb-aklasse
        FROM eanlh AS a
          INNER JOIN euiinstln AS b
          ON b~anlage = a~anlage
          INNER JOIN euitrans AS c
           ON c~int_ui = b~int_ui
        WHERE c~ext_ui = wa_out_msb-ext_ui
          AND c~dateto = '99991231'
          AND a~bis = '99991231'.
        EXIT.
      ENDSELECT.


*    SELECT MSB-DOC

      CLEAR ls_dfkkinvdoc_h.
      SELECT SINGLE  * FROM dfkkinvdoc_h INTO ls_dfkkinvdoc_h
        WHERE /mosb/inv_doc_ident = wa_out_msb-crossrefno.

      CLEAR: ls_dfkkinvdoc_i, lt_dfkkinvdoc_i.
      SELECT * INTO TABLE lt_dfkkinvdoc_i
        FROM dfkkinvdoc_i
        WHERE invdocno = ls_dfkkinvdoc_h-invdocno.



      wa_out_msb-/mosb/lead_sup = ls_dfkkinvdoc_h-/mosb/lead_sup.
      wa_out_msb-/mosb/mo_sp = ls_dfkkinvdoc_h-/mosb/mo_sp.
      wa_out_msb-vkont_msb = ls_dfkkinvdoc_h-vkont.
      wa_out_msb-gpart = ls_dfkkinvdoc_h-gpart.
      wa_out_msb-invdocno = ls_dfkkinvdoc_h-invdocno.
      wa_out_msb-prlinv_status = ls_dfkkinvdoc_h-prlinv_status.
      wa_out_msb-budat = ls_dfkkinvdoc_h-budat.
      wa_out_msb-bldat = ls_dfkkinvdoc_h-bldat.
      wa_out_msb-faedn = ls_dfkkinvdoc_h-faedn.

      LOOP AT lt_dfkkinvdoc_i INTO ls_dfkkinvdoc_i.
* Zeile Abrechnungsposition MoSB
        IF ls_dfkkinvdoc_i-itemtype = 'YMOS'.
          wa_out_msb-spart = ls_dfkkinvdoc_i-spart.
          wa_out_msb-opbel    = ls_dfkkinvdoc_i-opbel.
          wa_out_msb-srcdocno = ls_dfkkinvdoc_i-srcdocno.
          wa_out_msb-betrw    = ls_dfkkinvdoc_i-betrw.
          wa_out_msb-date_from = ls_dfkkinvdoc_i-date_from.
          wa_out_msb-date_to = ls_dfkkinvdoc_i-date_to.
          wa_out_msb-bukrs    = ls_dfkkinvdoc_i-bukrs.
        ENDIF.
      ENDLOOP.

      CLEAR ls_dfkkinvbill_i.
      SELECT * FROM dfkkinvbill_i INTO ls_dfkkinvbill_i
          WHERE billdocno = ls_dfkkinvdoc_i-srcdocno.
        wa_out_msb-quantity = ( ls_dfkkinvbill_i-quantity_pdp +
                                ls_dfkkinvbill_i-quantity_adp ).
        wa_out_msb-qty_unit = ls_dfkkinvbill_i-qty_unit.
        EXIT.
      ENDSELECT.

**   --> Nuss 09.2018-2
      CLEAR ls_dfkkinvbill_h.

      DATA: icon(4) TYPE c.
      icon  = icon_storno.

      SELECT SINGLE * FROM dfkkinvbill_h INTO ls_dfkkinvbill_h
         WHERE billdocno = ls_dfkkinvdoc_i-srcdocno.
      IF ls_dfkkinvbill_h-revreason IS NOT INITIAL.
        wa_out_msb-cancel_state = icon.
      ENDIF.

      CLEAR ls_dfkkinvbill_x.
      SELECT SINGLE * FROM dfkkinvbill_x INTO ls_dfkkinvbill_x
           WHERE refobjname = 'BILLPLAN'
           AND billdocno = ls_dfkkinvdoc_i-srcdocno.
      IF sy-subrc = 0.
        wa_out_msb-billplanno = ls_dfkkinvbill_x-refobjvalue.
      ENDIF.

      SELECT * FROM dfkkbix_bip_i INTO ls_dfkkbix_bip_i
        WHERE billplanno = wa_out_msb-billplanno.

        IF ls_dfkkbix_bip_i-cancelled = 'X'.
          wa_out_msb-cancel_state_ap = icon.
          EXIT.
        ENDIF.

      ENDSELECT.

**   <-- Nuss 09.2018-2


*      SELECT SINGLE opbel FROM erchc  INTO wa_out_msb-erchcopbel WHERE belnr = wa_out_msb-trig_bill_doc_no.
*      wa_out_msb-billable_item = wa_out_msb-invdocno.
      SELECT COUNT(*) FROM /adesso/fi_remad WHERE negrem_option = 'FIELDCAT' AND negrem_field = 'BEMERKUNG' AND negrem_value = 'X'.
      IF sy-subrc = 0.
        SELECT COUNT(*) FROM /adesso/remtext WHERE int_inv_doc_nr = wa_out_msb-int_inv_doc_no.
        IF sy-subrc = 0.
          wa_out_msb-text_vorhanden = 'X'.
        ELSE.
          wa_out_msb-text_vorhanden = ''.
        ENDIF.
      ENDIF.
      SELECT COUNT(*) FROM /adesso/fi_remad WHERE negrem_option = 'FIELDCAT' AND negrem_field = 'NOTIZ' AND negrem_value = 'X'.
      IF sy-subrc = 0.
        CLEAR gv_name.
        CLEAR xlines.
        CONCATENATE wa_out_msb-int_inv_doc_no
                    '_'
                    wa_out_msb-int_inv_line_no
                    INTO gv_name.

        CLEAR xlines.
        CALL FUNCTION 'READ_TEXT'
          EXPORTING
*           CLIENT                  = SY-MANDT
            id                      = co_id
            language                = sy-langu
            name                    = gv_name
            object                  = co_object
*           ARCHIVE_HANDLE          = 0
*           LOCAL_CAT               = ' '
*   IMPORTING
*           HEADER                  =
*           OLD_LINE_COUNTER        =
          TABLES
            lines                   = xlines
          EXCEPTIONS
            id                      = 1
            language                = 2
            name                    = 3
            not_found               = 4
            object                  = 5
            reference_check         = 6
            wrong_access_to_archive = 7
            OTHERS                  = 8.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.

        READ TABLE xlines INTO help_line INDEX 1.

        IF sy-subrc = 0.
          wa_out_msb-free_text5 = help_line.
*    MODIFY it_out FROM wa_out INDEX fp_tabindex.
        ENDIF.
      ENDIF.


      wa_out_msb-vkont = wa_out_msb-aggvk.
      PERFORM sel_bcontact_msb USING wa_out_msb.
      PERFORM sel_invstorno_msb USING wa_out_msb.
*      PERFORM get_locks_memi.
      APPEND wa_out_msb TO it_out_msb.
      CLEAR wa_out_msb.

    ENDSELECT.

  ENDSELECT.                                            "TINV_INV_HEAD


ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  DATEN_SELEKTIEREN_MSB_OLD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM daten_selektieren_msb_old .

  DATA lv_invtype TYPE tinv_inv_head-invoice_type.
  lv_invtype = co_memitype.

* Texte zum Rückstellungsgrund
  SELECT * FROM tinv_c_adj_rsnt
           INTO TABLE t_inv_c_adj_rsnt
           WHERE spras = sy-langu.

* Hilfsrange Sender auf Selektionsrange übertragen
  IF r_send[] IS NOT INITIAL AND s_send[] IS INITIAL.
    s_send[] = r_send[].
  ENDIF.

* Reklamationsavise
  SELECT a~int_inv_doc_no
         a~int_inv_no
         a~int_partner
         a~doc_type
         a~invoice_date
         a~date_of_payment
         a~inv_doc_status
         a~int_ident
         a~invoice_type
         a~int_sender
         a~int_receiver
         a~date_of_receipt
         a~invoice_status
         a~auth_grp
         a~ext_invoice_no
         a~inv_bulk_ref
         b~int_inv_line_no
         b~rstgr
         b~own_invoice_no
         b~betrw_req
         c~free_text1
         c~free_text5
    INTO CORRESPONDING FIELDS OF TABLE t_remadv
    FROM vinv_monitoring AS a
         INNER JOIN tinv_inv_line_a AS b
         ON b~int_inv_doc_no = a~int_inv_doc_no
         LEFT OUTER JOIN /idexge/rej_noti AS c
         ON  c~int_inv_doc_no  = b~int_inv_doc_no
         AND c~int_inv_line_no = b~int_inv_line_no
    WHERE a~int_sender IN s_send
      AND a~int_receiver IN s_rece
      AND a~invoice_type EQ lv_invtype
      AND a~date_of_receipt IN s_dtrec
      AND a~invoice_status IN s_insta
      AND a~int_inv_doc_no IN s_intido
      AND a~ext_invoice_no IN s_extido
      AND a~doc_type IN s_doctyp
      AND a~inv_doc_status IN s_idosta
      AND a~date_of_payment IN s_dtpaym
      AND a~invoice_date IN s_invoda
      AND b~line_type EQ co_linetype
      AND b~rstgr IN s_rstgr
      AND b~own_invoice_no IN s_owninv.

  SORT t_remadv.

* Überschreiben FREE_:TEXT5 aus Text-Editor
  IF t_remadv[] IS NOT INITIAL.
    LOOP AT t_remadv ASSIGNING <fs_remadv>.
      CLEAR gv_name.
      CONCATENATE <fs_remadv>-int_inv_doc_no
                  '_'
                  <fs_remadv>-int_inv_line_no
                  INTO gv_name.

      CLEAR xlines.
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
*         CLIENT                  = SY-MANDT
          id                      = co_id
          language                = sy-langu
          name                    = gv_name
          object                  = co_object
*         ARCHIVE_HANDLE          = 0
*         LOCAL_CAT               = ' '
*   IMPORTING
*         HEADER                  =
*         OLD_LINE_COUNTER        =
        TABLES
          lines                   = xlines
        EXCEPTIONS
          id                      = 1
          language                = 2
          name                    = 3
          not_found               = 4
          object                  = 5
          reference_check         = 6
          wrong_access_to_archive = 7
          OTHERS                  = 8.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      READ TABLE xlines INTO help_line INDEX 1.

      IF sy-subrc = 0.
        <fs_remadv>-free_text5 = help_line.
*    MODIFY it_out FROM wa_out INDEX fp_tabindex.
      ENDIF.

    ENDLOOP.
  ENDIF.

*  Crossreference und Externer Zählpunkt
  IF t_remadv[] IS NOT INITIAL.
    CLEAR t_crsrf_eui.
    SELECT a~int_crossrefno
           a~int_ui
           a~crossrefno
           a~crn_rev
           b~ext_ui
           b~dateto
      INTO CORRESPONDING FIELDS OF TABLE t_crsrf_eui
      FROM ecrossrefno AS a
           LEFT OUTER JOIN euitrans AS b
           ON b~int_ui = a~int_ui
      FOR ALL ENTRIES IN t_remadv
      WHERE ( a~crossrefno = t_remadv-own_invoice_no
      OR      a~crn_rev    = t_remadv-own_invoice_no ).

    SORT t_crsrf_eui BY int_crossrefno.

    DELETE t_crsrf_eui WHERE dateto NE '99991231'.

    DELETE ADJACENT DUPLICATES FROM t_crsrf_eui.

* Für den nächsten Zugriff auf Zahlungsavise besser nach crossrefno sortieren
* UH 19082016
*    SORT t_crsrf_eui BY int_crossrefno.
    SORT t_crsrf_eui BY crossrefno.

  ENDIF.

* Zahlungsavise
  IF t_crsrf_eui[] IS NOT INITIAL.

    SELECT a~own_invoice_no
           a~int_inv_doc_no
           c~invoice_status
      INTO CORRESPONDING FIELDS OF TABLE t_paym
      FROM tinv_inv_line_a AS a
           INNER JOIN tinv_inv_doc AS b
           ON b~int_inv_doc_no = a~int_inv_doc_no
           INNER JOIN tinv_inv_head AS c
           ON c~int_inv_no = b~int_inv_no
      FOR ALL ENTRIES IN t_crsrf_eui
      WHERE a~own_invoice_no = t_crsrf_eui-crossrefno
      AND   a~line_type      = co_linetype
      AND   b~doc_type       = co_docpaym
      AND   c~invoice_type   = co_invpaym.

* Zahlungavise zu stornierten Rechnungen gesondert betrachten
* UH 19082016
  ENDIF.


* Ist das Feld crn_rev nie gefüllt kommt es zum Laufzeitfehler
* da die komplette DB durchsucht wird
* daher vorher alle leeren crn_rev eliminieren
* UH 19082016

  t_crsrf_eu2[] = t_crsrf_eui[].

  SORT t_crsrf_eu2 BY crn_rev.
  DELETE t_crsrf_eu2 WHERE crn_rev = space.
  DELETE ADJACENT DUPLICATES FROM t_crsrf_eu2.

  IF t_crsrf_eu2[] IS NOT INITIAL.

    SELECT a~own_invoice_no
           a~int_inv_doc_no
           c~invoice_status
      APPENDING CORRESPONDING FIELDS OF TABLE t_paym
      FROM tinv_inv_line_a AS a
           INNER JOIN tinv_inv_doc AS b
           ON b~int_inv_doc_no = a~int_inv_doc_no
           INNER JOIN tinv_inv_head AS c
           ON c~int_inv_no = b~int_inv_no
      FOR ALL ENTRIES IN t_crsrf_eu2
      WHERE a~own_invoice_no = t_crsrf_eu2-crn_rev
      AND   a~line_type      = co_linetype
      AND   b~doc_type       = co_docpaym
      AND   c~invoice_type   = co_invpaym.

  ENDIF.

  SORT t_paym BY own_invoice_no.


**  BCONT
*  IF t_dfkkthi_op[] IS NOT INITIAL.

*  ENDIF.

*  t_crsrf_eu2[] = t_crsrf_eui[].
  SORT t_crsrf_eui BY crossrefno.
  SORT t_crsrf_eu2 BY crn_rev.

  LOOP AT t_remadv ASSIGNING <fs_remadv>.

    AT NEW int_inv_doc_no.
      x_ctrem = x_ctrem + 1.
    ENDAT.

    CLEAR wa_out_msb.
    MOVE-CORRESPONDING <fs_remadv> TO wa_out_msb.

** Aggr. Vertragskonto ermitteln
    SELECT SINGLE a~vkont INTO wa_out_msb-aggvk
      FROM fkkvk AS a
       INNER JOIN fkkvkp AS b
         ON b~vkont = a~vkont
      INNER JOIN eservprovp AS c
        ON c~bpart = b~gpart
        WHERE c~serviceid = <fs_remadv>-int_sender
        AND a~vktyp IN r_vktyp.


** Text zum Rückstellungsgrund
    READ TABLE t_inv_c_adj_rsnt
         INTO  wa_inv_c_adj_rsnt
         WITH KEY rstgr = <fs_remadv>-rstgr
                  spras = sy-langu.
    IF sy-subrc = 0.
      wa_out_msb-text = wa_inv_c_adj_rsnt-text.
    ENDIF.

* Crosreferenz / Zählpunkt
    READ TABLE t_crsrf_eui
         ASSIGNING <fs_crsrf_eui>
         WITH KEY crossrefno = <fs_remadv>-own_invoice_no
         BINARY SEARCH.

    IF sy-subrc = 0 AND <fs_crsrf_eui> IS ASSIGNED.
      b_storno = abap_false.
      wa_out_msb-ext_ui         = <fs_crsrf_eui>-ext_ui.
      wa_out_msb-int_crossrefno = <fs_crsrf_eui>-int_crossrefno.
      wa_out_msb-crossrefno = <fs_crsrf_eui>-crossrefno.
    ELSE.
      READ TABLE t_crsrf_eu2
           ASSIGNING <fs_crsrf_eui>
           WITH KEY crn_rev = <fs_remadv>-own_invoice_no
           BINARY SEARCH.
      IF sy-subrc = 0 AND <fs_crsrf_eui> IS ASSIGNED.
        wa_out_msb-inf_invoice_cancel = icon_status_reverse.
        wa_out_msb-ext_ui         = <fs_crsrf_eui>-ext_ui.
        wa_out_msb-int_crossrefno = <fs_crsrf_eui>-int_crossrefno.
        wa_out_msb-crossrefno = <fs_crsrf_eui>-crossrefno.
        b_storno = abap_true.
      ENDIF.
    ENDIF.

    SELECT * FROM /idexge/rej_noti INTO wa_noti
      WHERE int_inv_doc_no = wa_out_msb-int_inv_doc_no.
      IF wa_noti-stat_remk(3) = '@0V'.
        wa_out_msb-line_state = icon_okay.
      ENDIF.
      EXIT.
    ENDSELECT.

    wa_out_msb-vkont = wa_out_msb-aggvk.
*    "  ENDIF.
*    CLEAR: lt_efindres ,ls_efindres.

*    CHECK wa_out_msb-ext_ui IN s_extui.                  "Nuss 10.2017 Melo/Malo
    CHECK wa_out_msb-int_crossrefno IS NOT INITIAL.

* Abrechnungsklasse ermitteln
    SELECT aklasse INTO wa_out_msb-aklasse
      FROM eanlh AS a
        INNER JOIN euiinstln AS b
        ON b~anlage = a~anlage
        INNER JOIN euitrans AS c
         ON c~int_ui = b~int_ui
      WHERE c~ext_ui = wa_out_msb-ext_ui
        AND c~dateto = '99991231'
        AND a~bis = '99991231'.
      EXIT.
    ENDSELECT.


    MOVE-CORRESPONDING <fs_remadv> TO wa_out_msb.
*   Zahlungsavis vorhanden?
    READ TABLE t_paym
         ASSIGNING <fs_paym>
         WITH KEY own_invoice_no = <fs_remadv>-own_invoice_no
         BINARY SEARCH.

    IF sy-subrc = 0 AND <fs_paym> IS ASSIGNED.
      wa_out_msb-paym_avis = <fs_paym>-int_inv_doc_no.
      wa_out_msb-paym_stat = <fs_paym>-invoice_status.
    ENDIF.


*    SELECT Memidoc
    SELECT SINGLE  * FROM /idxmm/memidoc INTO CORRESPONDING FIELDS OF  wa_out_msb WHERE
    crossrefno = wa_out_msb-crossrefno.

    PERFORM sel_bcontact_old_memi.
    READ TABLE t_bcontact
         WITH KEY int_inv_doc_no = <fs_remadv>-int_inv_doc_no
         TRANSPORTING NO FIELDS
         BINARY SEARCH.

    IF sy-subrc = 0.
      wa_out_msb-comm_state = icon_envelope_closed.
    ENDIF.

    SELECT SINGLE opbel FROM erchc  INTO wa_out_msb-erchcopbel WHERE belnr = wa_out_msb-srcdocno.
    wa_out_msb-billable_item = wa_out_msb-invdocno.
    SELECT COUNT(*) FROM /adesso/remtext WHERE int_inv_doc_nr = wa_out_msb-int_inv_doc_no.
    IF sy-subrc = 0.
      wa_out_msb-text_vorhanden = 'X'.
    ELSE.
      wa_out_msb-text_vorhanden = ''.
    ENDIF.
    PERFORM sel_invstorno_msb USING wa_out_msb.
    PERFORM sel_bcontact_msb USING wa_out_msb.
*    PERFORM get_locks_memi.
    APPEND wa_out_msb TO it_out_msb.
    CLEAR wa_out_msb.

  ENDLOOP.


ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SEL_BCONTACT_MSB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_OUT_MSB  text
*----------------------------------------------------------------------*
FORM sel_bcontact_msb    USING wa_out_memi LIKE wa_out_msb.

  DATA: lv_bc          TYPE REF TO lcl_bcontact,
        lv_b_contexist TYPE boolean.

  CREATE OBJECT lv_bc.
  lv_bc->check_for_contact( EXPORTING iv_gpart          = wa_out_memi-gpart
                                      iv_int_inv_doc_no = wa_out_memi-int_inv_doc_no
                            RECEIVING rv_b_contexist    = lv_b_contexist
                           ).

  IF lv_b_contexist EQ abap_true.
    wa_out_msb-comm_state = icon_envelope_closed.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SEL_INVSTORNO_MSB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_OUT_MSB  text
*----------------------------------------------------------------------*
FORM sel_invstorno_msb  USING   wa_out LIKE wa_out_msb.

  DATA: wa_erdk TYPE erdk,
        h_opbel TYPE erdk-opbel.

  DATA: icon(4) TYPE c.
  icon  = icon_storno.

* Für MeMi-Belege steht die Druckbelegnummer der NN-Rechnung im Feld erchcopbel
*  IF wa_ederegswitchsyst-xcrn = 'X'.
*    h_opbel = wa_out-own_invoice_no+3.
*  ELSE.
*    h_opbel = wa_out-own_invoice_no.
*  ENDIF.
*
*
*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*    EXPORTING
*      input  = h_opbel
*    IMPORTING
*      output = h_opbel.

*   Belegkopf selektieren
  SELECT SINGLE * FROM erdk INTO wa_erdk
*    WHERE erdk~opbel EQ h_opbel.
    WHERE erdk~opbel EQ wa_out_memi-erchcopbel.


  IF wa_erdk-stokz IS NOT INITIAL.
    wa_out_msb-inf_invoice_cancel = icon_storno.
  ENDIF.

*  SELECT COUNT(*) FROM /idxmm/memidoc WHERE doc_id = wa_out_memi-doc_id AND reversal = 'X'.
*  IF sy-subrc = 0.
*    wa_out_msb-cancel_state_mm = icon_storno.
*  ENDIF..

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CANCEL_ABRDOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cancel_abrdoc .

  DATA: wa_sel           LIKE LINE OF rspar_tab,
        lv_reason        TYPE bill_revreason_kk,
        ls_dfkkinvbill_h TYPE dfkkinvbill_h.
  DATA: lt_billdocno     TYPE fkkinv_billdocno_tab.

  FIELD-SYMBOLS: <it_out> TYPE STANDARD TABLE,
                 <wa_out>,
                 <value>.

  CLEAR lv_reason.

* --> Nuss 10.2018
*  lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'STORNO_ABRBEL'
*                                                    iv_category = ''
*                                                    iv_field    = 'REASON'
*                                                    iv_id       = '1'
*                                          RECEIVING rv_value = lv_reason
  SELECT SINGLE negrem_value
  INTO lv_reason
  FROM /adesso/fi_remad
  WHERE negrem_option    EQ 'STORNO_ABRBEL'
    AND negrem_category  EQ ''
    AND negrem_field     EQ 'REASON'
   AND negrem_id        EQ 1.
* <-- Nuss 10.2018


  IF lv_reason IS INITIAL.
    lv_reason = '00'.
  ENDIF.

  LOOP AT it_out_msb INTO wa_out_msb.
* Zeile muss markiert sein.
    CHECK wa_out_msb-sel = 'X'.
    APPEND wa_out_msb-srcdocno TO lt_billdocno.

*    SUBMIT rfkkinvbillrev02
*     WITH SELECTION-TABLE lt_sel
*     VIA SELECTION-SCREEN
*     AND RETURN.

  ENDLOOP.

  IF lines( lt_billdocno ) > 0.
    DATA  lv_dialog TYPE dialog_kk VALUE ''.
    CALL FUNCTION 'FKK_INV_REV_BILLDOC_SINGLE'
      EXPORTING
        i_applk         = c_applk
        "i_billdocno            = bdocno
        i_billdocno_tab = lt_billdocno
        i_vkont         = ''
        i_gpart         = ''
        i_mdcat         = ''
        i_reason        = lv_reason
        i_dialog        = lv_dialog
        i_params_popup  = ' '
        i_show_results  = 'X'
      EXCEPTIONS
        general_fault   = 1
        OTHERS          = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
* Nach Änderung der Belege müssen die Daten im Datensatz für
* die Anzeige aktualisiert werden
  LOOP AT it_out_msb INTO wa_out_msb.

*   Zeile muss Markiert sein
*    check wa_out-xselp = 'X'.
    CHECK wa_out_msb-sel = 'X'.

    DATA: icon(4) TYPE c.
    icon  = icon_storno.


    SELECT SINGLE * FROM dfkkinvbill_h INTO ls_dfkkinvbill_h
      WHERE billdocno = wa_out_msb-srcdocno.


    IF ls_dfkkinvbill_h-revreason IS NOT INITIAL.
      wa_out_msb-cancel_state = icon.
      MODIFY it_out_msb FROM wa_out_msb.
    ENDIF.


  ENDLOOP.


ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CANCEL_ABRPLAN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cancel_abrplan .

  DATA: lv_datum  TYPE sy-datum,
        lv_answer TYPE char1,
        t_sval    LIKE TABLE OF sval,
        w_sval    LIKE          sval.

  DATA: lt_sel TYPE TABLE OF rsparams,
        wa_sel LIKE LINE OF rspar_tab.

  DATA: ls_dfkkbix_bip_i TYPE dfkkbix_bip_i.

  w_sval-tabname   = 'SYST'.
  w_sval-fieldname = 'DATUM'.
  w_sval-field_obl = 'X'.
  w_sval-fieldtext = 'Stornodatum'.
  w_sval-value     = sy-datum.
  APPEND w_sval TO t_sval.


  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
*     NO_VALUE_CHECK        = ' '
      popup_title  = 'Stornodatum'
      start_column = '5'
      start_row    = '4'
    IMPORTING
      returncode   = lv_answer
    TABLES
      fields       = t_sval.

  IF lv_answer IS INITIAL.
    lv_answer = 'j'.
  ENDIF.


  LOOP AT it_out_msb INTO wa_out_msb.
* Zeile muss markiert sein.
    CHECK wa_out_msb-sel = 'X'.

    CLEAR: wa_sel, lt_sel.
    wa_sel-selname = 'REVFR'.
    wa_sel-kind = 'P'.
    wa_sel-low = w_sval-value.
    APPEND wa_sel TO lt_sel.

    CLEAR: wa_sel.
    wa_sel-selname = 'BIPNO'.
    wa_sel-kind = 'S'.
    wa_sel-sign = 'I'.
    wa_sel-option = 'EQ'.
    wa_sel-low = wa_out_msb-billplanno.
    APPEND wa_sel TO lt_sel.


    SUBMIT rfkkbixbipreqrev02
       WITH SELECTION-TABLE lt_sel
       VIA SELECTION-SCREEN
       AND RETURN.

  ENDLOOP.

* Nach Änderung der Belege müssen die Daten im Datensatz für
* die Anzeige aktualisiert werden
  LOOP AT it_out_msb INTO wa_out_msb.
* Zeile muss markiert sein.
    CHECK wa_out_msb-sel = 'X'.

    DATA: icon(4) TYPE c.
    icon  = icon_storno.

    SELECT * FROM dfkkbix_bip_i INTO ls_dfkkbix_bip_i
      WHERE billplanno = wa_out_msb-billplanno.

      IF ls_dfkkbix_bip_i-cancelled = 'X'.
        wa_out_msb-cancel_state_ap = icon.
        MODIFY it_out_msb FROM wa_out_msb.
        EXIT.
      ENDIF.

    ENDSELECT.


  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_LOCKS_MSB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_locks_msb .

* check dunning block for document
  DATA: lf_info(25).
  DATA: s_dfkkop LIKE dfkkop.
  DATA: s_dfkkop_key LIKE dfkkop_key_s.
  DATA: t_dfkklock TYPE TABLE OF dfkklocks WITH HEADER LINE.
  DATA:x_lock_exist TYPE c,
       x_lock_depex TYPE c.

  CLEAR: x_lock_exist,
         x_lock_depex.

  CLEAR s_dfkkop.
  CLEAR s_dfkkop_key.
*  IF <fs_dfkkthi_op> IS ASSIGNED.

  s_dfkkop-gpart  = wa_out_msb-gpart.
  s_dfkkop-vkont  = wa_out_msb-vkont.
  s_dfkkop-opbel  = wa_out_msb-opbel.
  s_dfkkop-opupw  = '000'.
  s_dfkkop-opupk  = '0001'.
  s_dfkkop-opupz  = '000'.
  MOVE-CORRESPONDING s_dfkkop TO s_dfkkop_key.

  CALL FUNCTION 'FKK_S_LOCK_GET'
    EXPORTING
      i_keystructure           = s_dfkkop
      i_lotyp                  = '02'
      i_proid                  = '01'
      i_lockdate               = sy-datum
      i_x_mass_access          = space
      i_x_dependant_locktypes  = space
    IMPORTING
      e_x_lock_exist           = x_lock_exist
      e_x_dependant_lock_exist = x_lock_depex
    TABLES
      et_locks                 = t_dfkklock.

  CHECK x_lock_exist = 'X'.
  LOOP AT t_dfkklock WHERE loobj1 = s_dfkkop_key.
    "wa_out-mansp  = t_dfkklock-lockr.
    " lf_info = wa_out-mansp.
    lf_info+13(1) = '-'.
    WRITE t_dfkklock-fdate TO lf_info+2(10) DD/MM/YYYY.
    WRITE t_dfkklock-tdate TO lf_info+15(10) DD/MM/YYYY.

    wa_out_msb-process_state = icon_locked.

  ENDLOOP.

ENDFORM.
