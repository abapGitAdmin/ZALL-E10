*&---------------------------------------------------------------------*
*& Report  ZAD_INVOIC_MANAGER
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  /ADESSO/INVOIC_MANAGER_TEST.

TABLES: tinv_inv_head.
TABLES: tinv_inv_doc.
TABLES: tinv_inv_line_a.
TABLES: eanlh.
TABLES:euitrans.

* ALV
TYPE-POOLS: slis.
TYPES t_belegart(3) TYPE c.
DATA: g_repid            LIKE sy-repid,
      g_save             TYPE char1,
      g_exit             TYPE char1,
      gx_variant         LIKE disvariant,
      g_variant          LIKE disvariant,
      g_lignam           TYPE slis_fieldname VALUE  'LIGHTS',
      gs_layout          TYPE slis_layout_alv,
      gt_sort            TYPE slis_t_sortinfo_alv,
      gt_fieldcat        TYPE slis_t_fieldcat_alv,
      gt_fieldcat_error  TYPE slis_t_fieldcat_alv,
      gt_fieldcat_ext    TYPE slis_t_fieldcat_alv,
      gv_max_proz_c(200) TYPE c,
      gv_max_proz        TYPE i,
      gv_akt_proz        TYPE i,
      gv_okcode          TYPE c,
      g_user_command     TYPE slis_formname VALUE 'USER_COMMAND',
      g_status           TYPE slis_formname VALUE 'STATUS_STANDARD',
      gv_cust            TYPE  /adesso/inv_cust.
DATA: gt_filtered TYPE slis_t_filtered_entries.


DATA: wa_inv_extid      TYPE tinv_inv_extid,
      wa_inv_line_b     TYPE tinv_inv_line_b,
      wa_inv_loghd      TYPE tinv_inv_loghd,
      wa_inv_logline    TYPE tinv_inv_logline,
      wa_t100           TYPE t100,
      wa_inv_doc_a      TYPE tinv_inv_doc,
      wa_inv_line_a     TYPE tinv_inv_line_a,
      wa_inv_c_adj_rsnt TYPE tinv_c_adj_rsnt,
      wa_noti           TYPE /idexge/rej_noti.

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
        invperiod_start	TYPE inv_period_start,
        invperiod_end	  TYPE inv_period_end,
        inv_bulk_ref    TYPE inv_bulk_ref,
        ext_inv_no_orig TYPE inv_ext_invoice_no_orig,
        inv_cancel_doc  TYPE tinv_inv_doc-inv_cancel_doc,
*        INV_DOC_STATUS  TYPE INV_DOC_STATUS,

      END OF wa_inv_head_doc.
DATA lt_inv_head_doc LIKE TABLE OF wa_inv_head_doc.
DATA: BEGIN OF wa_fehler,
        msgid TYPE msgid,
        msgno TYPE msgno,
        msgv1 TYPE msgv1,
        msgv2 TYPE msgv2,
        msgv3 TYPE msgv3,
        msgv4 TYPE msgv4,
      END OF wa_fehler.
DATA:  it_fehler LIKE STANDARD TABLE OF wa_fehler.

* Ausgabetabelle
DATA: BEGIN OF wa_out,
        xselp            TYPE xselp,
        sel(1)           TYPE c,
        multi_err(1)     TYPE c,
        memi             TYPE c,
        locked(4)        TYPE c,
        text_vorhanden   TYPE c,
        invoice_status_t TYPE ddtext,                       "20150820
        int_inv_doc_no   TYPE tinv_inv_doc-int_inv_doc_no,
        int_receiver     TYPE tinv_inv_head-int_receiver,
        int_sender       TYPE    tinv_inv_head-int_sender,
        invoice_status   TYPE  tinv_inv_head-invoice_status,
        date_of_receipt  TYPE tinv_inv_head-date_of_receipt,
        ext_invoice_no   TYPE tinv_inv_doc-ext_invoice_no,
        ext_inv_no_orig  TYPE tinv_inv_doc-ext_inv_no_orig,
        doc_type         TYPE    tinv_inv_doc-doc_type,
        process          TYPE tinv_inv_docproc-process,
        inv_doc_status   TYPE  tinv_inv_doc-inv_doc_status,
        stornobelnr      TYPE inv_int_inv_cancel_doc_no,
        remadv           TYPE tinv_inv_line_a-int_inv_doc_no,
        remdate          TYPE tinv_inv_head-date_of_receipt,
        rstgr            TYPE tinv_inv_line_a-rstgr,
        free_text1       TYPE /idexge/rej_noti-free_text1,
        date_of_payment  TYPE tinv_inv_doc-date_of_payment,
        inv_bulk_ref     TYPE tinv_inv_doc-inv_bulk_ref,
        invoice_date     TYPE tinv_inv_doc-invoice_date,
        invperiod_start  TYPE tinv_inv_doc-invperiod_start,
        invperiod_end    TYPE tinv_inv_doc-invperiod_end,
        mc_name1         TYPE tinv_inv_extid-mc_name1,
        mc_name2         TYPE tinv_inv_extid-mc_name2,
        mc_street        TYPE tinv_inv_extid-mc_street,
        mc_house_num1    TYPE tinv_inv_extid-mc_house_num1,
        mc_city1         TYPE tinv_inv_extid-mc_city1,
        mc_postcode      TYPE tinv_inv_extid-mc_postcode,
        ext_ident        TYPE tinv_inv_extid-ext_ident,
        anlage           TYPE eanlh-anlage,
        aklasse          TYPE eanlh-aklasse,
        tariftyp         TYPE eanlh-tariftyp,
        ableinh          TYPE eanlh-ableinh,
        betrw            TYPE tinv_inv_line_b-betrw,
        taxbw            TYPE tinv_inv_line_b-taxbw,
        sbasw            TYPE tinv_inv_line_b-sbasw,
        quantity         TYPE tinv_inv_line_b-quantity,
        fehler           TYPE char120,
        belegart(3)      TYPE c, "Struck 20150406
        vertrag          TYPE ever-vertrag,
        lights,
      END OF wa_out.
DATA: it_out LIKE STANDARD TABLE OF wa_out.


DATA: txt        TYPE c LENGTH 10,
      rspar_tab  TYPE TABLE OF rsparams,
      rspar_line LIKE LINE OF rspar_tab,
      range_tab  LIKE RANGE OF txt,
      range_line LIKE LINE OF range_tab.

DATA: BEGIN OF wa_errorline,
        text(120) TYPE c,
      END OF wa_errorline.
DATA: it_errorline LIKE STANDARD TABLE OF wa_errorline.

DATA: wa_euitrans  TYPE euitrans,
      wa_euiinstln TYPE euiinstln,
      wa_eanlh     TYPE eanlh.

DATA: anl_ok(1) TYPE c.
DATA: zpkt_ok(1) TYPE c.

DATA: BEGIN OF wa_ext_out,
        product_id      TYPE tinv_inv_line_b-product_id,
        text            TYPE edereg_sidprot-text,
        date_from       TYPE tinv_inv_line_b-date_from,
        date_to         TYPE tinv_inv_line_b-date_to,
        quantity        TYPE tinv_inv_line_b-quantity,
        unit            TYPE tinv_inv_line_b-unit,
        price           TYPE tinv_inv_line_b-price,
        price_unit      TYPE tinv_inv_line_b-price_unit,
        betrw_net       TYPE tinv_inv_line_b-betrw_net,
        taxbw           TYPE tinv_inv_line_b-taxbw,
        date_of_payment TYPE tinv_inv_line_b-date_of_payment,
        mwskz           TYPE tinv_inv_line_b-mwskz,
        strpz           TYPE tinv_inv_line_b-strpz,
      END OF wa_ext_out.
DATA: it_ext_out LIKE STANDARD TABLE OF wa_ext_out.

DATA: wa_sidpro  TYPE edereg_sidpro,
      wa_sidprot TYPE edereg_sidprot.

DATA lv_test TYPE c.

********************************************************************************
* Selektionsbildschirm
********************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK head WITH FRAME TITLE text-001.
SELECT-OPTIONS: s_rece  FOR tinv_inv_head-int_receiver,
                s_send  FOR tinv_inv_head-int_sender,
                s_insta FOR tinv_inv_head-invoice_status,
                s_dtrec FOR tinv_inv_head-date_of_receipt,
                s_inv_t for tinv_inv_head-invoice_type.
SELECTION-SCREEN END OF BLOCK head.

SELECTION-SCREEN BEGIN OF BLOCK doc WITH FRAME TITLE text-002.
SELECT-OPTIONS: s_intido FOR tinv_inv_doc-int_inv_doc_no,
                s_extido FOR tinv_inv_doc-ext_invoice_no,
                s_doctyp FOR tinv_inv_doc-doc_type,
                s_idosta FOR tinv_inv_doc-inv_doc_status,
                s_rstgr  FOR tinv_inv_line_a-rstgr,
                s_freetx FOR wa_noti-free_text1 NO INTERVALS,
                s_dtpaym FOR tinv_inv_doc-date_of_payment,
                s_bulkrf FOR tinv_inv_doc-inv_bulk_ref.
SELECTION-SCREEN END OF BLOCK doc.
*SELECTION-SCREEN BEGIN OF BLOCK opt WITH FRAME TITLE text-003.
*PARAMETERS: p_err RADIOBUTTON GROUP opt,
*            p_noerr RADIOBUTTON GROUP opt.
*SELECTION-SCREEN END OF BLOCK opt.

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE text-005.
SELECT-OPTIONS: s_abrkl FOR eanlh-aklasse.
SELECT-OPTIONS: s_tatyp FOR eanlh-tariftyp.
SELECT-OPTIONS: s_ablei FOR eanlh-ableinh .
SELECTION-SCREEN END OF BLOCK b01.

SELECTION-SCREEN BEGIN OF BLOCK b03 WITH FRAME TITLE text-007 .
SELECT-OPTIONS: s_zpkt FOR euitrans-ext_ui NO INTERVALS.
SELECTION-SCREEN END OF BLOCK b03.


SELECTION-SCREEN BEGIN OF BLOCK vari WITH FRAME TITLE text-004.
SELECTION-SCREEN SKIP.
PARAMETERS: p_vari LIKE disvariant-variant.
SELECTION-SCREEN END OF BLOCK vari.


SELECTION-SCREEN BEGIN OF BLOCK techn WITH FRAME TITLE text-006.
SELECTION-SCREEN SKIP.
PARAMETERS: p_max TYPE i.
SELECTION-SCREEN END OF BLOCK techn.

*********************************************************************************
* INITILALZATION
*********************************************************************************
INITIALIZATION.
  PERFORM init_custom_fields.
  SELECT SINGLE value FROM /adesso/inv_cust INTO gv_max_proz_c WHERE report = 'GLOBAL' AND field = 'GV_MAX_PROZ'.
  SELECT SINGLE value FROM /adesso/inv_cust INTO lv_test WHERE report = 'GLOBAL' AND field = 'TEST'.
  gv_max_proz = gv_max_proz_c.
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

*********************************************************************************
* START-OF-SELECTION
*********************************************************************************
START-OF-SELECTION.
  PERFORM selektionsbild_speichern.
  PERFORM daten_selektieren.


*********************************************************************************
* START-OF-SELECTION
*********************************************************************************
END-OF-SELECTION.
  PERFORM layout_build USING gs_layout.
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
  DATA lv_exit TYPE c.
  DATA: anz_fehler TYPE i.

DATA SE_DCDAT LIKE  s_dtrec[] WITH HEADER LINE.

  IF s_dtrec IS INITIAL.
    s_dtrec-sign    = 'I'.  " include
    s_dtrec-option  = 'BT'.  " between
    s_dtrec-low     = '20000101'.
    s_dtrec-high    = '99991231'.
    APPEND s_dtrec.
  ENDIF.
  IF SE_DCDAT IS INITIAL.
    SE_DCDAT-sign    = 'I'.  " include
    SE_DCDAT-option  = 'BT'.  " between
    SE_DCDAT-low     = '20000101'.
    SE_DCDAT-high    = '99991231'.
    APPEND SE_DCDAT.
  ENDIF.
  IF s_idosta IS INITIAL.
    s_idosta-sign    = 'I'.  " include
    s_idosta-option  = 'NE'.  " between
    APPEND s_idosta.
  ENDIF.
  IF s_insta IS INITIAL.
    s_insta-sign    = 'I'.  " include
    s_insta-option  = 'NE'.  " between
    APPEND s_insta.
  ENDIF.





  SELECT h~int_inv_no      h~invoice_type
         h~date_of_receipt h~invoice_status
         h~int_receiver    h~int_sender
         d~int_inv_doc_no  d~ext_invoice_no
         d~doc_type        d~inv_doc_status
         d~date_of_payment d~invoice_date
         d~invperiod_start d~invperiod_end
         d~inv_bulk_ref    d~ext_inv_no_orig

    INTO CORRESPONDING FIELDS OF TABLE lt_inv_head_doc
    FROM tinv_inv_head AS h
      INNER JOIN tinv_inv_doc AS d
      ON h~int_inv_no EQ d~int_inv_no
      "UP TO p_max ROWS
    WHERE h~int_sender IN s_send
      AND h~date_of_receipt IN s_dtrec
      AND h~invoice_status IN s_insta
      AND d~invoice_date in SE_DCDAT
      AND h~invoice_type In s_inv_t
      AND h~int_receiver IN s_rece
      AND d~int_inv_doc_no IN s_intido
      AND d~ext_invoice_no IN s_extido
      AND d~doc_type IN s_doctyp
      AND d~inv_doc_status IN s_idosta
      AND d~rstgr IN s_rstgr
      AND d~date_of_payment IN s_dtpaym
      AND d~inv_bulk_ref IN s_bulkrf.

    LOOP AT lt_inv_head_doc INTO wa_inv_head_doc.


    IF lv_exit = '1'.
      EXIT.
    ENDIF.
    CLEAR wa_out.

* Standardmäßig setzen, wird später evtl. krrigiert
    CASE wa_inv_head_doc-invoice_status.
      WHEN '01'.
        wa_out-lights = '0'.
      WHEN '02'.
        wa_out-lights = '2'.
      WHEN '03'.
        wa_out-lights = '3'.
      WHEN OTHERS.
        wa_out-lights = '0'.
    ENDCASE  .

    SELECT COUNT(*) FROM /adesso/invsperr WHERE int_inv_doc_nr = wa_inv_head_doc-int_inv_doc_no.
    IF sy-subrc = 0.
      wa_out-locked = '@06@'.
    ELSE.
      wa_out-locked = ''.
    ENDIF.




    DATA: lv_reklambelnr(3)  TYPE c VALUE '04',
          lv_reklamdoctyp(3) TYPE c VALUE '008',
          lv_paybelart(3)    TYPE c,
          lv_paydoctyp(3)    TYPE c.


    SELECT SINGLE value FROM /adesso/inv_cust INTO lv_reklambelnr   WHERE report = 'GLOBAL' AND field = 'REKLAMBELART'.
    SELECT SINGLE value FROM /adesso/inv_cust INTO lv_reklamdoctyp  WHERE report = 'GLOBAL' AND field = 'REKLAMDOCTYP'.
    SELECT SINGLE value FROM /adesso/inv_cust INTO lv_paybelart     WHERE report = 'GLOBAL' AND field = 'PAYBELART'.
    SELECT SINGLE value FROM /adesso/inv_cust INTO lv_paydoctyp     WHERE report = 'GLOBAL' AND field = 'PAYDOCTYP'.

**  Reklamationsavise, falls Reklamiert
*BREAK-POINT.
    IF wa_inv_head_doc-inv_doc_status = lv_reklambelnr.  "reklamiert.

      SELECT * FROM tinv_inv_doc INTO wa_inv_doc_a
        WHERE ext_invoice_no = wa_inv_head_doc-ext_invoice_no
         AND doc_type = lv_reklamdoctyp.
        EXIT.
      ENDSELECT.

      SELECT * FROM tinv_inv_line_a INTO wa_inv_line_a
        WHERE int_inv_doc_no = wa_inv_doc_a-int_inv_doc_no
        AND  rstgr NE space.

*        CHECK wa_inv_line_a-rstgr IS NOT INITIAL.
        CHECK wa_inv_line_a-rstgr IN s_rstgr.
*        CHECK wa_inv_line_a-own_invoice_no IS NOT INITIAL.

* Text zum Rückstellungsgrund
*          CLEAR wa_inv_c_adj_rsnt.
*          SELECT SINGLE * FROM tinv_c_adj_rsnt
*             INTO wa_inv_c_adj_rsnt
*               WHERE rstgr = wa_inv_line_a-rstgr
*               AND spras = sy-langu.

* ´  Langtext falls vorhanden
        CLEAR wa_noti.
        SELECT * FROM /idexge/rej_noti INTO wa_noti
          WHERE int_inv_doc_no = wa_inv_head_doc-int_inv_doc_no.
          EXIT.
        ENDSELECT.
        CHECK wa_noti-free_text1 IN s_freetx.
*     WA_OUT füllen
        SELECT SINGLE date_of_receipt FROM tinv_inv_head INTO wa_out-remdate
          WHERE int_inv_no = wa_inv_doc_a-int_inv_no.

        MOVE wa_inv_line_a-int_inv_doc_no  TO wa_out-remadv.
        MOVE wa_inv_line_a-rstgr          TO wa_out-rstgr.
*      MOVE wa_inv_c_adj_rsnt-text       TO wa_out-text.
        MOVE wa_noti-free_text1           TO wa_out-free_text1.

      ENDSELECT.

**    Hier noch einmal den Free-Text testen, damit die Zeile nicht trotzdem
**    ausgegeben wird
      CHECK wa_noti-free_text1 IN s_freetx.
      CHECK wa_inv_line_a-rstgr IN s_rstgr.

    ELSE."IF  wa_inv_head_doc-inv_doc_status = lv_PAYBELART.  "gezahlt
      SELECT * FROM tinv_inv_doc INTO wa_inv_doc_a
  WHERE ext_invoice_no = wa_inv_head_doc-ext_invoice_no
   AND doc_type = lv_paydoctyp.
        EXIT.
      ENDSELECT.

      IF sy-subrc = 0.
        MOVE wa_inv_doc_a-int_inv_doc_no  TO wa_out-remadv.
        "MOVE wa_inv_line_a-rstgr          TO wa_out-rstgr.
        MOVE 'Zahlungsavis (ausgehend)'       TO wa_out-free_text1.
        "MOVE wa_noti-free_text1           TO wa_out-free_text1.
      ENDIF.
*      ENDSELECT.

**    Hier noch einmal den Free-Text testen, damit die Zeile nicht trotzdem
**    ausgegeben wird
      " CHECK wa_noti-free_text1 IN s_freetx.
      " CHECK wa_inv_line_a-rstgr IN s_rstgr.
    ENDIF.


    CLEAR zpkt_ok.
* Rechnungsbeleg: Externe Identifikationsmerkmale
    SELECT * FROM tinv_inv_extid INTO wa_inv_extid
      WHERE int_inv_doc_no EQ wa_inv_head_doc-int_inv_doc_no
      AND ext_ident IN s_zpkt AND ext_ident_type = '01' .

      MOVE-CORRESPONDING wa_inv_extid TO  wa_out.
      zpkt_ok = 'X'.
    ENDSELECT.



* Selektion der Anlagen nach Tariftyp, Abrechnungsklasse und Ableseeinheit
    CLEAR: wa_euitrans, wa_euitrans, wa_eanlh.
    CLEAR anl_ok.
    SELECT * FROM euitrans INTO wa_euitrans WHERE
      ext_ui = wa_inv_extid-ext_ident AND
      dateto GE sy-datum AND
      datefrom LE sy-datum.

      SELECT * FROM euiinstln INTO wa_euiinstln WHERE
        int_ui = wa_euitrans-int_ui AND
        dateto GE sy-datum AND
        datefrom LE sy-datum.

        SELECT * FROM eanlh INTO wa_eanlh WHERE
             anlage = wa_euiinstln-anlage AND
             aklasse IN s_abrkl AND
             tariftyp IN s_tatyp AND
             ableinh IN s_ablei
              AND ableinh <> '99999999'
              AND bis >= sy-datum .

          anl_ok = 'X'.
          EXIT.
        ENDSELECT.
      ENDSELECT.
    ENDSELECT.
    IF sy-subrc = 4 AND lv_test = 'X'.
      "keine Zählpunktdaten vorhanden
      anl_ok = 'X'.
    ENDIF.

    IF s_abrkl IS INITIAL AND s_tatyp IS INITIAL AND s_ablei IS INITIAL.
      anl_ok = 'X'.
    ENDIF.



    IF anl_ok IS INITIAL OR zpkt_ok IS INITIAL.
      CLEAR wa_out.
      CONTINUE.
    ELSE.
      MOVE-CORRESPONDING wa_eanlh TO wa_out.
    ENDIF.



* Rechnungszeile mit Buchungsinformationen
    SELECT * FROM tinv_inv_line_b INTO wa_inv_line_b
      WHERE int_inv_doc_no EQ wa_inv_head_doc-int_inv_doc_no
        AND ( line_type EQ '0005' OR
              line_type EQ '0013' ).


      SELECT SUM( quantity ) FROM tinv_inv_line_b INTO wa_inv_line_b-quantity
        WHERE product_id = '9990001000269' AND int_inv_doc_no EQ wa_inv_head_doc-int_inv_doc_no.

*      Fehlertext ermitteln
      CLEAR it_fehler.
*       Beendete bzw. Prozessierte keine Fehlerausgabe
      IF wa_inv_head_doc-invoice_status = '03' OR
         wa_inv_head_doc-inv_doc_status = '13'.
**         Do Nothing
      ELSE.
        PERFORM get_errormessage USING wa_inv_head_doc-int_inv_doc_no
                                 CHANGING it_fehler.
      ENDIF.

**      Mehrfacheinträge aus der Fehlertabelle löscben
      IF it_fehler IS NOT INITIAL.
        SORT it_fehler.
        DELETE ADJACENT DUPLICATES FROM it_fehler COMPARING ALL FIELDS.
      ENDIF.

      IF it_fehler IS NOT INITIAL.
        wa_out-lights = '1'.
      ENDIF.
      MOVE-CORRESPONDING wa_inv_head_doc TO wa_out.
*      MOVE-CORRESPONDING wa_inv_doc TO wa_out.
      MOVE-CORRESPONDING wa_inv_line_b TO wa_out.
*       Fehlermeldungen ausgeben
*      IF p_err = 'X'.
      DATA: lt_dd07v TYPE TABLE OF dd07v,
            ls_dd07v TYPE dd07v.
      CALL FUNCTION 'DDUT_DOMVALUES_GET'
        EXPORTING
          name      = 'INV_DOC_STATUS'
*         LANGU     = SY-LANGU
*         TEXTS_ONLY          = ' '
        TABLES
          dd07v_tab = lt_dd07v
*       EXCEPTIONS
*         ILLEGAL_INPUT       = 1
*         OTHERS    = 2
        .
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      READ TABLE lt_dd07v INTO ls_dd07v WITH KEY domvalue_l = wa_inv_head_doc-inv_doc_status.
      wa_out-invoice_status_t = ls_dd07v-ddtext.

      SELECT COUNT(*) FROM /adesso/invtext WHERE int_inv_doc_nr = wa_out-int_inv_doc_no.
      IF sy-subrc = 0.
        wa_out-text_vorhanden = 'X'.
      ENDIF.
      wa_out-stornobelnr = wa_inv_head_doc-inv_cancel_doc.
      SELECT COUNT( * ) FROM tinv_inv_line_b WHERE int_inv_doc_no = wa_out-int_inv_doc_no AND product_id = '9990001000574'.
*      SELECT SINGLE int_inv_doc_no FROM tinv_inv_doc INTO wa_out-stornobelnr WHERE ext_inv_no_orig = wa_out-ext_invoice_no.
      DATA lt_proc TYPE TABLE OF tinv_inv_docproc.
      DATA ls_proc TYPE tinv_inv_docproc.
      CLEAR lt_proc.
      SELECT * FROM  tinv_inv_docproc INTO TABLE lt_proc WHERE int_inv_doc_no = wa_out-int_inv_doc_no.
      IF sy-subrc = 0.
        SORT lt_proc BY  process_run_no DESCENDING.
        READ TABLE lt_proc INTO ls_proc INDEX 1.
        wa_out-process = ls_proc-process.
      ENDIF.

      wa_out-belegart = wa_inv_doc_a-/idexge/imd_doc_type.
      IF wa_out-belegart IS INITIAL.
        PERFORM belegart_holen USING wa_out-int_inv_doc_no wa_out-ext_invoice_no CHANGING wa_out-belegart ."Struck 20150406
      ENDIF.
      SELECT SINGLE vertrag
        FROM ever
        INTO wa_out-vertrag
        WHERE anlage = wa_out-anlage
        AND einzdat <= wa_out-invperiod_start
        AND auszdat > wa_out-invperiod_end.

      IF it_fehler IS NOT INITIAL.

        DESCRIBE TABLE it_fehler LINES anz_fehler.
        IF anz_fehler GT 1.
          wa_out-multi_err = 'X'.
        ENDIF.

*          LOOP AT it_fehler INTO wa_fehler.
        READ TABLE it_fehler INTO wa_fehler INDEX 1.
        SELECT * FROM t100 INTO wa_t100
          WHERE sprsl = 'D'
            AND arbgb = wa_fehler-msgid
            AND msgnr = wa_fehler-msgno.
          wa_out-fehler = wa_t100-text.
          REPLACE ALL OCCURRENCES OF '&1' IN wa_out-fehler WITH wa_fehler-msgv1.
          REPLACE ALL OCCURRENCES OF '&2' IN wa_out-fehler WITH wa_fehler-msgv2.
          REPLACE ALL OCCURRENCES OF '&3' IN wa_out-fehler WITH wa_fehler-msgv3.
          REPLACE ALL OCCURRENCES OF '&4' IN wa_out-fehler WITH wa_fehler-msgv4.
          wa_out-lights = '1'.
          APPEND wa_out TO it_out.
          IF lines( it_out ) = p_max.
            lv_exit = '1'.
          ENDIF.
          CLEAR wa_out.
        ENDSELECT.
*          ENDLOOP.
      ELSE.
        APPEND wa_out TO it_out.
        IF lines( it_out ) = p_max.
          lv_exit = '1'.
        ENDIF.
      ENDIF.
*       keine Fehlermeldungen ausgeben
*      ELSEIF p_noerr = 'X'.
*        APPEND wa_out TO it_out.
*      ENDIF.
      CLEAR wa_out.

    ENDSELECT.

  endloop.                                         "TINV_INV_DOC

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
  ls_layout-lights_fieldname  = g_lignam.
  ls_layout-colwidth_optimize = 'X'.
  ls_layout-box_fieldname = 'XSELP'.


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

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'XSELP'.
  ls_fieldcat-tech      = 'X'.
  ls_fieldcat-tabname = 'IT_OUT'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'SEL'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-edit = 'X'.
  ls_fieldcat-input = 'X'.
  ls_fieldcat-checkbox = 'X'.
  ls_fieldcat-key = 'X'.
  ls_fieldcat-seltext_s = 'Selektion'.
  ls_fieldcat-seltext_m = 'Selektion'.
  ls_fieldcat-seltext_l = 'Selektion'.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'MULTI_ERR'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-seltext_m = 'Mult.Fehler'.
  ls_fieldcat-hotspot = 'X'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'MEMI'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-seltext_m = 'MEMI'.
  ls_fieldcat-hotspot = ' '.
  ls_fieldcat-icon = 'X'.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'LOCKED'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-seltext_m = 'Sperre'.
  ls_fieldcat-hotspot = ' '.
  ls_fieldcat-icon = 'X'.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TEXT_VORHANDEN'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-seltext_m = 'Bemerkung'.
  ls_fieldcat-hotspot = 'X'.
  APPEND ls_fieldcat TO lt_fieldcat.
  "Struck 20150820

* stornobelnr
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'PROCESS'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-seltext_s = 'Prozess'.
  ls_fieldcat-seltext_l = 'Prozess'.
*  ls_fieldcat-ref_tabname = 'BELEGART'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'INVOICE_STATUS_T'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-seltext_m = 'BelStatus'.
  ls_fieldcat-reptext_ddic = 'X'.
*  ls_fieldcat-hotspot = 'X'.
  APPEND ls_fieldcat TO lt_fieldcat.


*Interne Nummer des Rechnungsbelegs/Avisbelegs
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'INT_INV_DOC_NO'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-key = 'X'.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-ref_tabname = 'TINV_INV_DOC'.
  APPEND ls_fieldcat TO lt_fieldcat.

*Interne Bezeichnung des Rechnung-/Avisempfängers
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'INT_RECEIVER'.
  ls_fieldcat-tabname = 'IT_OUT'.
  "ls_fieldcat-key = 'X'.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-ref_tabname = 'TINV_INV_HEAD'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Interne Bezeichnung des Rechnungs-/Avissenders
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'INT_SENDER'.
  ls_fieldcat-tabname = 'IT_OUT'.
  "ls_fieldcat-key = 'X'.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-ref_tabname = 'TINV_INV_HEAD'.
  APPEND ls_fieldcat TO lt_fieldcat.

** Status der Rechnung/des Avises
*  CLEAR ls_fieldcat.
*  ls_fieldcat-fieldname = 'INVOICE_STATUS'.
*  ls_fieldcat-tabname = 'IT_OUT'.
*  "ls_fieldcat-key = 'X'.
*  ls_fieldcat-ref_tabname = 'TINV_INV_HEAD'.
*  APPEND ls_fieldcat TO lt_fieldcat.

*  Eingangsdatum des Dokumentes
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DATE_OF_RECEIPT'.
  ls_fieldcat-tabname = 'IT_OUT'.
  "ls_fieldcat-key = 'X'.
  ls_fieldcat-ref_tabname = 'TINV_INV_HEAD'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Externe Rechnungsnummer/Avisnummer
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'EXT_INVOICE_NO'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_DOC'.
  ls_fieldcat-hotspot = 'X'.
  APPEND ls_fieldcat TO lt_fieldcat.

*Belegart
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BELEGART'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-seltext_s = 'Art'.
  ls_fieldcat-seltext_l = 'Rechnungsart'.
  ls_fieldcat-ref_tabname = 'BELEGART'.
  APPEND ls_fieldcat TO lt_fieldcat.
* Art des Belegs
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DOC_TYPE'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_DOC'.
  APPEND ls_fieldcat TO lt_fieldcat.



* stornobelnr
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'STORNOBELNR'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-seltext_s = 'Storno'.
  ls_fieldcat-seltext_l = 'Stornobeleg'.
*  ls_fieldcat-ref_tabname = 'BELEGART'.
  APPEND ls_fieldcat TO lt_fieldcat.


* Status des Belegs
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'INV_DOC_STATUS'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_DOC'.
  APPEND ls_fieldcat TO lt_fieldcat.


* REMADV-Nummer
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'REMADV'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-seltext_m = 'REMADV-Nr.'.
  APPEND ls_fieldcat TO lt_fieldcat.

* REMADV-Datum
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'REMDATE'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-seltext_m = 'REMADV-Dat.'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Differenzgrund bei Zahlungen
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'RSTGR'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_LINE_A'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Langtext
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'FREE_TEXT1'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = '/IDEXGE/REJ_NOTI'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Fälligkeitsdatum
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DATE_OF_PAYMENT'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_DOC'.
  APPEND ls_fieldcat TO lt_fieldcat.

* DA-Gruppenreferenznummer
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'INV_BULK_REF'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_DOC'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Datum der Rechnung oder des Avises
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'INVOICE_DATE'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_DOC'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Beginn des Zeitraums für den die Rechnung/das Avis gilt
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'INVPERIOD_START'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_DOC'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Ende des Zeitraums für den die Rechnung/das Avis gilt
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'INVPERIOD_END'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_DOC'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Name 1/Nachname
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'MC_NAME1'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_EXTID'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Name 2/Vorname
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'MC_NAME2'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_EXTID'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Straßenname
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'MC_STREET'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_EXTID'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Hausnummer
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'MC_HOUSE_NUM1'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_EXTID'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Ortsname
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'MC_CITY1'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_EXTID'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Postleitzahl des Orts
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'MC_POSTCODE'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_EXTID'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Externe Identifizierung eines Belegs (z.B. Zählpunkt)
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'EXT_IDENT'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-ref_tabname = 'TINV_INV_EXTID'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Anlage
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'ANLAGE'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'EANLH'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Anlage
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'VERTRAG'.
  ls_fieldcat-seltext_s = 'Vertrag'.
  ls_fieldcat-ref_tabname = 'EVER'.
  ls_fieldcat-tabname = 'IT_OUT'.
  " ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-ref_tabname = 'VERTRAG'.
  APPEND ls_fieldcat TO lt_fieldcat.


* Abrechnungsklasse
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'AKLASSE'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'EANLH'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Tariftyp
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TARIFTYP'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'EANLH'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Ableseeinheit
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'ABLEINH'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'EANLH'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Bruttobetrag in Transaktionswährung mit Vorzeichen
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BETRW'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-no_zero = 'X'.
  ls_fieldcat-do_sum = 'X'.
  ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Steuerbetrag in Transaktionswährung
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TAXBW'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-no_zero = 'X'.
  ls_fieldcat-do_sum = 'X'.
  ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Steuerpfl. Betrag in Transaktionswährung (Steuerbasisbetrag)
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'SBASW'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-no_zero = 'X'.
  ls_fieldcat-do_sum = 'X'.
  ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
  APPEND ls_fieldcat TO lt_fieldcat.

*Menge Wirkarbeit

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'QUANTITY'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-no_zero = 'X'.
  ls_fieldcat-do_sum = 'X'.
  ls_fieldcat-seltext_s = 'Wirkarbeit in kWh'.
  ls_fieldcat-seltext_m = 'Wirkarbeit in kWh'.
  ls_fieldcat-seltext_l = 'Wirkarbeit in kWh'.
  ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
  APPEND ls_fieldcat TO lt_fieldcat.



* Fehlermeldung
*  IF p_err IS NOT INITIAL.
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'FEHLER'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-seltext_s = 'Fehler'.
  ls_fieldcat-seltext_m = 'Fehlermeldung'.
  ls_fieldcat-seltext_l = 'Fehlermeldung'.
  ls_fieldcat-outputlen = '120'.
  ls_fieldcat-hotspot = 'X'.
  APPEND ls_fieldcat TO lt_fieldcat.
*  ENDIF.

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

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK        = ' '
*     I_BYPASSING_BUFFER       = ' '
*     I_BUFFER_ACTIVE          = ' '
      i_callback_program       = g_repid
      i_callback_pf_status_set = g_status
      i_callback_user_command  = g_user_command
*     I_CALLBACK_TOP_OF_PAGE   = ' '
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME         =
*     I_BACKGROUND_ID          = ' '
*     I_GRID_TITLE             =
*     I_GRID_SETTINGS          =
      is_layout                = gs_layout
      it_fieldcat              = gt_fieldcat[]
*     IT_EXCLUDING             =
*     IT_SPECIAL_GROUPS        =
*     IT_SORT                  =
*     IT_FILTER                =
*     IS_SEL_HIDE              =
*     I_DEFAULT                = 'X'
      i_save                   = g_save
*     IS_VARIANT               =
*     IT_EVENTS                =
*     IT_EVENT_EXIT            =
*     IS_PRINT                 =
*     IS_REPREP_ID             =
*     I_SCREEN_START_COLUMN    = 0
*     I_SCREEN_START_LINE      = 0
*     I_SCREEN_END_COLUMN      = 0
*     I_SCREEN_END_LINE        = 0
*     I_HTML_HEIGHT_TOP        = 0
*     I_HTML_HEIGHT_END        = 0
*     IT_ALV_GRAPHICS          =
*     IT_HYPERLINK             =
*     IT_ADD_FIELDCAT          =
*     IT_EXCEPT_QINFO          =
*     IR_SALV_FULLSCREEN_ADAPTER        =
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER  =
*     ES_EXIT_CAUSED_BY_USER   =
    TABLES
      t_outtab                 = it_out
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.                    " DISPLAY_ALV
*&---------------------------------------------------------------------*
*&      Form  GET_ERRORMESSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_INV_NO  text
*      <--P_FEHLER  text
*----------------------------------------------------------------------*
FORM get_errormessage  USING    p_inv_no
                       CHANGING t_fehler LIKE it_fehler.

  DATA: lt_inv_loghd   TYPE STANDARD TABLE OF tinv_inv_loghd,
        ls_inv_loghd   TYPE tinv_inv_loghd,
        ls_inv_docproc TYPE tinv_inv_docproc,
        lt_inv_docproc TYPE STANDARD TABLE OF tinv_inv_docproc,
        ls_fehler      LIKE wa_fehler.

  DATA: h_datefrom TYPE sy-datum.

  CLEAR lt_inv_docproc.
  SELECT * FROM tinv_inv_docproc INTO TABLE lt_inv_docproc
    WHERE int_inv_doc_no = p_inv_no
     AND status = '04'.

  IF lt_inv_docproc IS NOT INITIAL.

    SELECT * FROM tinv_inv_loghd INTO TABLE lt_inv_loghd
      FOR ALL ENTRIES IN lt_inv_docproc
      WHERE int_inv_doc_no = p_inv_no
      AND status = '03'
      AND process = lt_inv_docproc-process.

    SORT lt_inv_loghd BY datefrom DESCENDING.

    LOOP AT lt_inv_loghd INTO ls_inv_loghd.

      IF h_datefrom IS INITIAL.
        h_datefrom = ls_inv_loghd-datefrom.
      ENDIF.

      IF ls_inv_loghd-datefrom LT h_datefrom.
        EXIT.
      ENDIF.

      SELECT * FROM tinv_inv_logline INTO wa_inv_logline
        WHERE inv_log_no = ls_inv_loghd-inv_log_no
         AND msgty = 'E'.
        MOVE-CORRESPONDING wa_inv_logline TO ls_fehler.
        APPEND ls_fehler TO t_fehler.
        CLEAR ls_fehler.
      ENDSELECT.

    ENDLOOP.
  ENDIF.


ENDFORM.                    " GET_ERRORMESSAGE

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

*  IF s_insta  IS INITIAL AND
*     s_dtrec IS INITIAL AND
*     s_intido IS INITIAL.
*    SET CURSOR FIELD 'S_INTIDO-LOW'.
*    MESSAGE e000(e4) WITH 'Bitte mindestens Belegnummer, Rechnungs-Status'
*                           'oder Eingangsdatum eingeben'.
*  ENDIF.

ENDFORM.                    " CHECK_INPUT

*-----------------------------------------------------------------------
*    FORM PF_STATUS_SET
*-----------------------------------------------------------------------
*    ........
*-----------------------------------------------------------------------
*    --> extab
*-----------------------------------------------------------------------
FORM status_standard  USING extab TYPE slis_t_extab.

  SET PF-STATUS 'STANDARD_STATUS' EXCLUDING extab.

ENDFORM.                    "status_standard


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


** --> Nuss 26.01.2015
  DATA: rev_alv TYPE REF TO cl_gui_alv_grid.

  DATA: h_extui   TYPE ext_ui.

  CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
    IMPORTING
      e_grid = rev_alv.

  rev_alv->check_changed_data( ).

  READ TABLE it_out INTO wa_out INDEX rs_selfield-tabindex.

  rs_selfield-refresh = 'X'.
  rs_selfield-row_stable = 'X'.
  rs_selfield-col_stable = 'X'.

  CLEAR: gt_filtered.
  REFRESH gt_filtered.

  CALL FUNCTION 'REUSE_ALV_GRID_LAYOUT_INFO_GET'
    IMPORTING
      et_filtered_entries = gt_filtered
    EXCEPTIONS
      no_infos            = 1
      program_error       = 2
      OTHERS              = 3.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


  CASE r_ucomm.

    WHEN '&ALL_U'.
      PERFORM mark_all.

    WHEN '&SAL_U'  .
      PERFORM unmark_all.

    WHEN 'REFERENZ'.
      PERFORM show_references.

    WHEN 'UEBER'.
      PERFORM prozesse USING ' '.

    WHEN 'ANZ'.
      PERFORM prozesse USING 'X'.

    WHEN 'ENET'.
      PERFORM enet_preisblatt_anzeigen.

    WHEN 'PRUEFUNGEN'.
      PERFORM prozesse USING ' '.

    WHEN 'SPERREN'.
      PERFORM add_text USING ' sperren '.
      PERFORM sperren." USING ' '.
      PERFORM refresh_data CHANGING rs_selfield-refresh.
    WHEN 'ZEFRESH'.
      PERFORM refresh_data CHANGING rs_selfield-refresh.

* Status auf Beendet setzen
    WHEN 'BEENDEN'.
      PERFORM check_sperre.
      PERFORM ucom_beenden.

* --> Nuss 26.01.2015
* Protokoll anzeigen
    WHEN 'LOG'.

      PERFORM ucom_log.

* --> Struck 20150407

    WHEN 'CHECK'.

      PERFORM auswaehlen.

    WHEN 'STAT_RESET'.
      PERFORM check_sperre.
      PERFORM add_text USING 'zurücksetzen'.
      IF gv_okcode <> 'U'.
        PERFORM reset_status USING 'X' ' '.
        PERFORM refresh_data CHANGING rs_selfield-refresh.
      ENDIF.

    WHEN 'RELEASE'.
      PERFORM check_sperre.
      IF gv_okcode <> 'U'.
        PERFORM add_text USING 'Freigeben'.
        PERFORM reset_status USING ' ' 'X'.
        PERFORM refresh_data CHANGING rs_selfield-refresh.
      ENDIF.

* Prozessieren
    WHEN 'PROCESS'.
      PERFORM check_sperre.
      PERFORM ucom_proc.
      PERFORM refresh_data CHANGING rs_selfield-refresh.

* zu Reklamieren
    WHEN 'COMPLAIN'.
      PERFORM check_sperre.
      IF gv_okcode <> 'U'.
        PERFORM add_text USING 'reklamieren'.
        PERFORM ucom_compl.
        PERFORM refresh_data CHANGING rs_selfield-refresh.
      ENDIF.

*  zu stornieren
    WHEN 'CANCEL'.
      PERFORM check_sperre.
      IF gv_okcode <> 'U'.
        PERFORM add_text USING 'stornieren'.
        PERFORM ucom_canc.
        PERFORM refresh_data CHANGING rs_selfield-refresh.
      ENDIF.

    WHEN OTHERS.

      CASE rs_selfield-fieldname.

        WHEN 'LOCKED'.
          PERFORM texte_anzeigen USING wa_out-int_inv_doc_no.


        WHEN 'VERTRAG'.
          SET PARAMETER ID 'VTG' FIELD rs_selfield-value.
          CALL TRANSACTION 'ES22' AND SKIP FIRST SCREEN .

        WHEN 'ANLAGE'.
          SET PARAMETER ID 'ANL' FIELD rs_selfield-value.
          CALL TRANSACTION 'ES32' AND SKIP FIRST SCREEN .

        WHEN 'INT_INV_DOC_NO' .

          SUBMIT rinv_monitoring
            WITH p_invtp      = wa_out-doc_type
            WITH p_allalv     = 'X'
            WITH se_docnr-low = wa_out-int_inv_doc_no
            AND RETURN.

        WHEN 'INT_RECEIVER' .

          SET PARAMETER ID 'EESERVPROVID' FIELD rs_selfield-value.
          CALL TRANSACTION 'EEDMIDESERVPROV03' AND SKIP FIRST SCREEN.

        WHEN 'INT_SENDER' .

          SET PARAMETER ID 'EESERVPROVID' FIELD rs_selfield-value.
          CALL TRANSACTION 'EEDMIDESERVPROV03' AND SKIP FIRST SCREEN.

        WHEN 'REMADV' .
*BREAK struck-f.

          DATA: lv_reklambelnr(3)   TYPE c VALUE '04',
                lv_paybelart(3)     TYPE c,
                lv_reklaminvtype(3) TYPE c VALUE '003',
                lv_payinvtyp(3)     TYPE c.

          SELECT SINGLE value FROM /adesso/inv_cust INTO lv_reklambelnr   WHERE report = 'GLOBAL' AND field = 'REKLAMBELART'.
          SELECT SINGLE value FROM /adesso/inv_cust INTO lv_reklaminvtype  WHERE report = 'GLOBAL' AND field = 'REKLAMINVTYP'.
          SELECT SINGLE value FROM /adesso/inv_cust INTO lv_paybelart     WHERE report = 'GLOBAL' AND field = 'PAYBELART'.
          SELECT SINGLE value FROM /adesso/inv_cust INTO lv_payinvtyp     WHERE report = 'GLOBAL' AND field = 'PAYINVTYP'.

          IF wa_out-inv_doc_status = lv_reklambelnr.
            SUBMIT rinv_monitoring
              WITH p_invtp      = lv_reklaminvtype
              WITH se_docnr-low = wa_out-remadv
              AND RETURN.
          ELSE.
            SUBMIT rinv_monitoring
             WITH p_invtp      = lv_payinvtyp
             WITH se_docnr-low = wa_out-remadv
             AND RETURN.
          ENDIF.

        WHEN 'STORNOBELNR' .
          SUBMIT rinv_monitoring
  WITH se_docnr-low = wa_out-remadv
  AND RETURN.

        WHEN 'EXT_IDENT' .
          MOVE rs_selfield-value TO h_extui.
          CALL FUNCTION 'ISU_S_UI_DISPLAY'
            EXPORTING
              x_ext_ui = h_extui.


        WHEN 'TEXT_VORHANDEN'.
          PERFORM texte_anzeigen USING wa_out-int_inv_doc_no.

        WHEN 'MULTI_ERR' OR 'FEHLER'.

          CLEAR it_errorline.

          CLEAR it_fehler.
          SELECT * FROM tinv_inv_line_b INTO wa_inv_line_b
            WHERE int_inv_doc_no EQ wa_out-int_inv_doc_no
              AND ( line_type EQ '0005' OR
                    line_type EQ '0013' ).


*         Fehlertext ermitteln
*            CLEAR it_fehler.

            PERFORM get_errormessage USING wa_out-int_inv_doc_no
                                     CHANGING it_fehler.

*         Mehrfacheinträge aus der Fehlertabelle löscben
            IF it_fehler IS NOT INITIAL.
              SORT it_fehler.
              DELETE ADJACENT DUPLICATES FROM it_fehler COMPARING ALL FIELDS.
            ENDIF.

          ENDSELECT.



          LOOP AT it_fehler INTO wa_fehler.
            SELECT * FROM t100 INTO wa_t100
              WHERE sprsl = 'D'
                AND arbgb = wa_fehler-msgid
                AND msgnr = wa_fehler-msgno.
              wa_errorline-text = wa_t100-text.
              REPLACE ALL OCCURRENCES OF '&1' IN wa_errorline-text WITH wa_fehler-msgv1.
              REPLACE ALL OCCURRENCES OF '&2' IN wa_errorline-text WITH wa_fehler-msgv2.
              REPLACE ALL OCCURRENCES OF '&3' IN wa_errorline-text WITH wa_fehler-msgv3.
              REPLACE ALL OCCURRENCES OF '&4' IN wa_errorline-text WITH wa_fehler-msgv4.
              APPEND wa_errorline TO it_errorline.
              CLEAR wa_errorline.
            ENDSELECT.
          ENDLOOP.

          PERFORM fieldcat_build_error USING gt_fieldcat_error[].

          CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
            EXPORTING
              it_fieldcat           = gt_fieldcat_error[]
              i_screen_start_column = 10
              i_screen_start_line   = 10
              i_screen_end_column   = 80
              i_screen_end_line     = 20
            TABLES
              t_outtab              = it_errorline
            EXCEPTIONS
              program_error         = 1
              OTHERS                = 2.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.

        WHEN 'EXT_INVOICE_NO'.

          CLEAR it_ext_out[].

          SELECT * FROM tinv_inv_doc INTO wa_inv_doc_a
            WHERE ext_invoice_no = wa_out-ext_invoice_no.

            SELECT * FROM tinv_inv_line_b INTO wa_inv_line_b
              WHERE int_inv_doc_no = wa_inv_doc_a-int_inv_doc_no
              AND product_id NE space.

              CLEAR: wa_sidpro, wa_sidprot.
              SELECT * FROM edereg_sidpro INTO wa_sidpro
                WHERE product_id = wa_inv_line_b-product_id.
                EXIT.
              ENDSELECT.
              SELECT SINGLE * FROM edereg_sidprot INTO wa_sidprot
                WHERE int_serident = wa_sidpro-int_serident
                  AND product_id_type = wa_sidpro-product_id_type
                  AND spras = sy-langu.

              MOVE-CORRESPONDING wa_inv_line_b TO wa_ext_out.
              MOVE wa_sidprot-text TO wa_ext_out-text.
              APPEND wa_ext_out TO it_ext_out.
              CLEAR wa_ext_out.

            ENDSELECT.

          ENDSELECT.


          PERFORM fieldcat_build_ext USING gt_fieldcat_ext[].

          CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
            EXPORTING
              it_fieldcat           = gt_fieldcat_ext[]
              i_screen_start_column = 10
              i_screen_start_line   = 10
              i_screen_end_column   = 200
              i_screen_end_line     = 20
            TABLES
              t_outtab              = it_ext_out
            EXCEPTIONS
              program_error         = 1
              OTHERS                = 2.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.

      ENDCASE.


  ENDCASE.

ENDFORM.                    "user_command


*&---------------------------------------------------------------------*
*&      Form  ucom_beenden
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ucom_beenden .

  DATA: l_inv_doc TYPE REF TO cl_inv_inv_remadv_doc.
  DATA: l_answer TYPE char1.
  DATA: lt_return TYPE bapirettab.

  FIELD-SYMBOLS: <t_out> LIKE wa_out.

* Sicherheitsabfrage
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      defaultoption = 'Y'
      textline1     = text-100
      textline2     = text-101
      titel         = text-t01
    IMPORTING
      answer        = l_answer.

  IF NOT l_answer CA 'jJyY'.
    EXIT.
  ENDIF.

  PERFORM add_text USING 'Beenden'.
**   Zeile muss Markiert sein
  LOOP AT it_out ASSIGNING <t_out>
     WHERE sel IS NOT INITIAL.


    READ TABLE gt_filtered
     WITH KEY table_line = sy-tabix
       TRANSPORTING NO FIELDS.

    CHECK sy-subrc NE 0.
*   INT_INVOICE_NO muss gefüllt sein.
*   Bei mehreren Fehlern ist nur die erste Zeile zum Beleg gefüllt.
    CHECK <t_out>-int_inv_doc_no IS NOT INITIAL.

    CREATE OBJECT l_inv_doc
      EXPORTING
        im_work_mode  = cl_inv_inv_remadv_doc=>co_wmode_change
        im_doc_number = <t_out>-int_inv_doc_no
      EXCEPTIONS
        OTHERS        = 1.

    IF sy-subrc <> 0.
      IF l_inv_doc IS NOT INITIAL.
        CALL METHOD l_inv_doc->close.
        EXIT.
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

    IF lt_return IS INITIAL.
      <t_out>-inv_doc_status = '08'.              "Beendet
    ENDIF.

  ENDLOOP.

ENDFORM.                    " ucom_beenden

*&---------------------------------------------------------------------*
*&      Form  SELEKTIONSBILD_SPEICHERN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM selektionsbild_speichern .


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

  LOOP AT s_bulkrf.
    rspar_line-selname = 'S_BULRRF'.
    rspar_line-kind = 'S'.
    rspar_line-sign = s_bulkrf-sign.
    rspar_line-option = s_bulkrf-option.
    rspar_line-low = s_bulkrf-low.
    rspar_line-high = s_bulkrf-high.
    APPEND rspar_line TO rspar_tab.
    CLEAR rspar_line.
  ENDLOOP.

*  rspar_line-selname = 'P_ERR'.
*  rspar_line-kind = 'P'.
*  rspar_line-low = p_err.
*  APPEND rspar_line TO rspar_tab.
*  CLEAR rspar_line.
*
*  rspar_line-selname = 'P_NOERR'.
*  rspar_line-kind = 'P'.
*  rspar_line-low = p_noerr.
*  APPEND rspar_line TO rspar_tab.
*  CLEAR rspar_line.

  rspar_line-selname = 'P_VARI'.
  rspar_line-kind = 'P'.
  rspar_line-low = p_vari.
  APPEND rspar_line TO rspar_tab.
  CLEAR rspar_line.

ENDFORM.                    " SELEKTIONSBILD_SPEICHERN


*&---------------------------------------------------------------------*
*&      Form  UCOM_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ucom_log .
  DATA: it_inv_inv_dockey TYPE ttinv_inv_dockey,
        wa_inv_inv_dockey TYPE inv_inv_dockey.

  DATA: l_count TYPE i.

  LOOP AT it_out INTO wa_out
       WHERE sel = 'X'.
    ADD 1 TO l_count.
  ENDLOOP.

  IF l_count GT 1.
    MESSAGE e000(e4) WITH 'Bitte nur ein Feld markieren'.
  ENDIF.

  READ TABLE it_out INTO wa_out WITH KEY sel = 'X'.


  wa_inv_inv_dockey-int_inv_doc_no = wa_out-int_inv_doc_no.
  APPEND wa_inv_inv_dockey TO it_inv_inv_dockey.

  CALL METHOD cl_inv_inv_remadv_log=>cl_display_log
    EXPORTING
      im_int_inv_doc_no_tab = it_inv_inv_dockey
*     im_int_inv_no         = wa_out-int_inv_no
*     im_show_all_data      = SPACE
*     im_close_log          = 'X'
*     im_amodal             = SPACE
*     im_doc                =
*     im_sel_lines          =
*  CHANGING
*     ch_log                =
    EXCEPTIONS
      no_log_exists         = 1
      internal_error        = 2
      no_authority          = 3
      OTHERS                = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.                    " UCOM_LOG


*&---------------------------------------------------------------------*
*&      Form  UCOM_PROC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ucom_proc .

  DATA: lt_return      TYPE bapirettab,
        l_proc_type    TYPE inv_process_type,
        l_error        TYPE inv_kennzx,
        lv_b_selected  TYPE boolean,
        l_answer       TYPE char1,
        lt_inv_proc    LIKE it_out,
        lt_inv_collect TYPE tinv_int_inv_doc_no,
        ls_inv_proc    LIKE wa_out,
        lr_out         LIKE REF TO wa_out,
        lt_ergebnis    TYPE /adesso/manager_proz_collect_t,
        l_tinv_inv_doc TYPE tinv_inv_doc.



  LOOP AT it_out INTO wa_out.

    READ TABLE gt_filtered
          WITH KEY table_line = sy-tabix
          TRANSPORTING NO FIELDS.

    CHECK sy-subrc NE 0.

*   Zeile muss Markiert sein
    CHECK wa_out-sel = 'X'.

    lv_b_selected = abap_true.

*   INT_INVOICE_NO muss gefüllt sein.
*   Bei mehreren Fehlern ist nur die erste Zeile zum Beleg gefüllt.
    CHECK wa_out-int_inv_doc_no IS NOT INITIAL.
*   Status 'Neu' oder 'Zu Bearbeiten'
    IF wa_out-invoice_status NE '01' AND
       wa_out-invoice_status NE '02' AND
       wa_out-invoice_status NE '03'.           "Nuss 08.2012
      CONTINUE.
    ENDIF.
    APPEND wa_out TO lt_inv_proc.
  ENDLOOP.

*  break struck-f.
  IF lines( lt_inv_proc ) <= 10.
    LOOP AT lt_inv_proc INTO ls_inv_proc.
      "invoice zum Prozessieren sammeln
      READ TABLE it_out  REFERENCE INTO lr_out WITH KEY int_inv_doc_no = ls_inv_proc-int_inv_doc_no.
      CLEAR lt_return[].
      CLEAR: l_proc_type, l_error.

      CALL METHOD cl_inv_inv_remadv_doc=>process_document
        EXPORTING
          im_doc_number          = lr_out->int_inv_doc_no
        IMPORTING
          ex_return              = lt_return[]
          ex_exit_process_type   = l_proc_type
          ex_proc_error_occurred = l_error
        EXCEPTIONS
          OTHERS                 = 1.

      SELECT SINGLE * FROM tinv_inv_doc INTO l_tinv_inv_doc
         WHERE int_inv_doc_no = lr_out->int_inv_doc_no.

      lr_out->inv_doc_status = l_tinv_inv_doc-inv_doc_status.

      IF lt_return[] IS NOT INITIAL.
        CLEAR it_fehler.
        PERFORM get_errormessage USING lr_out->int_inv_doc_no
                           CHANGING it_fehler.

**      Mehrfacheinträge aus der Fehlertabelle löscben
        IF it_fehler IS NOT INITIAL.
          SORT it_fehler.
          DELETE ADJACENT DUPLICATES FROM it_fehler COMPARING ALL FIELDS.
        ENDIF.

        IF it_fehler IS NOT INITIAL.
          READ TABLE it_fehler INTO wa_fehler INDEX 1.
          SELECT * FROM t100 INTO wa_t100
            WHERE sprsl = 'D'
              AND arbgb = wa_fehler-msgid
              AND msgnr = wa_fehler-msgno.
            lr_out->fehler = wa_t100-text.
            REPLACE ALL OCCURRENCES OF '&1' IN lr_out->fehler WITH wa_fehler-msgv1.
            REPLACE ALL OCCURRENCES OF '&2' IN lr_out->fehler WITH wa_fehler-msgv2.
            REPLACE ALL OCCURRENCES OF '&3' IN lr_out->fehler WITH wa_fehler-msgv3.
            REPLACE ALL OCCURRENCES OF '&4' IN lr_out->fehler WITH wa_fehler-msgv4.
            lr_out->lights = '1'.
          ENDSELECT.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ELSE.
    DATA lv_tabix LIKE sy-tabix.
    LOOP AT lt_inv_proc INTO ls_inv_proc.
      lv_tabix = sy-tabix.
      APPEND ls_inv_proc-int_inv_doc_no TO lt_inv_collect.
      IF lines( lt_inv_collect ) = 10.
        ADD 1 TO gv_akt_proz.
        WAIT UNTIL gv_akt_proz < gv_max_proz.
        CALL FUNCTION '/ADESSO/INV_MANAGER_PROCESS_TA'
          STARTING NEW TASK lv_tabix
          DESTINATION IN GROUP DEFAULT
          PERFORMING ende_task ON END OF TASK
          EXPORTING
            it_inv_doc_nr         = lt_inv_collect
          CHANGING
            process_document      = lt_ergebnis
          EXCEPTIONS
            communication_failure = 1
            system_failure        = 2
            OTHERS                = 3.
        .
        CLEAR lt_inv_collect.
      ENDIF.


    ENDLOOP.
    IF lt_inv_collect IS NOT INITIAL.
      ADD 1 TO gv_akt_proz.
      WAIT UNTIL gv_akt_proz < gv_max_proz.
      CALL FUNCTION '/ADESSO/INV_MANAGER_PROCESS_TA'
        STARTING NEW TASK 'Ende'
        DESTINATION IN GROUP DEFAULT
        PERFORMING ende_task ON END OF TASK
        EXPORTING
          it_inv_doc_nr         = lt_inv_collect
        CHANGING
          process_document      = lt_ergebnis
        EXCEPTIONS
          communication_failure = 1
          system_failure        = 2
          OTHERS                = 3.
      .
      CLEAR lt_inv_collect.
    ENDIF.


  ENDIF.


ENDFORM.                    " UCOM_PROC


*&---------------------------------------------------------------------*
*&      Form  UCOM_COMPL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ucom_compl .

  DATA: compl_reason TYPE rstgr.
  DATA: l_inv_doc TYPE REF TO cl_inv_inv_remadv_doc.
  DATA: l_answer TYPE char1.
  DATA: lt_return TYPE bapirettab.
  DATA: ls_return TYPE bapiret2.
  DATA: ls_adj_rsn TYPE tinv_c_adj_rsn.
  DATA:  l_tinv_inv_doc TYPE tinv_inv_doc.
  DATA:  l_proc_type TYPE inv_process_type.
  DATA:  l_error     TYPE inv_kennzx.
  DATA:  l_done   TYPE char1.

  FIELD-SYMBOLS: <t_out> LIKE wa_out.

* Reklamationsgrund holen
  PERFORM get_popup_compl_reason USING wa_out-int_inv_doc_no
                                 CHANGING compl_reason.

  CHECK compl_reason IS NOT INITIAL.

* Reklamationsgrund 28 (Sonstiges) --> Popup für Freitext
  CALL METHOD /idexge/cl_inv_adddata=>read_table_adj_rsn
    EXPORTING
      iv_rstgr       = compl_reason
    IMPORTING
      es_adj_rsn     = ls_adj_rsn
    EXCEPTIONS
      error_occurred = 1
      OTHERS         = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
               RAISING error_occurred.
  ENDIF.

  IF ls_adj_rsn-/idexge/reason <> '28'.

    CALL METHOD /idexge/cl_inv_adddata=>action_idex_alv_rej_noti
      EXPORTING
        iv_edit_mode   = /idexge/cl_inv_adddata=>co_true
        iv_must_flag   = ls_adj_rsn-/idexge/reason
      EXCEPTIONS
        edit_cancel    = 1
        error_occurred = 2
        OTHERS         = 3.
    IF sy-subrc = 1.
      EXIT.
    ELSEIF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                 RAISING error_occurred.
    ENDIF.
  ENDIF.


  CLEAR l_done.
  LOOP AT it_out ASSIGNING <t_out>
     WHERE sel IS NOT INITIAL.


    READ TABLE gt_filtered
     WITH KEY table_line = sy-tabix
       TRANSPORTING NO FIELDS.

    CHECK sy-subrc NE 0.

*   INT_INVOICE_NO muss gefüllt sein.
    CHECK <t_out>-int_inv_doc_no IS NOT INITIAL.


    CREATE OBJECT l_inv_doc
      EXPORTING
        im_work_mode  = cl_inv_inv_remadv_doc=>co_wmode_change
        im_doc_number = <t_out>-int_inv_doc_no
      EXCEPTIONS
        OTHERS        = 1.

    IF sy-subrc <> 0.
      IF l_inv_doc IS NOT INITIAL.
        CALL METHOD l_inv_doc->close.
      ENDIF.
      EXIT.
    ENDIF.

    CLEAR lt_return[].
    CALL METHOD l_inv_doc->change_document_status
      EXPORTING
        im_set_to_reset            = ' '
        im_set_to_released         = ' '
        im_set_to_finished         = ' '
        im_set_to_to_be_complained = 'X'
        im_reason_for_complain     = compl_reason
        im_set_to_to_be_reversed   = ' '
        im_reversal_rsn            = ' '
        im_commit_work             = 'X'
        im_automatic_change        = ' '
        im_create_reversal_doc     = ' '
      IMPORTING
        ex_return                  = lt_return.

    IF lt_return IS NOT INITIAL.
      READ TABLE lt_return INTO ls_return
         WITH KEY type = 'E'.
      IF sy-subrc = 0.
        MESSAGE ID ls_return-id TYPE ls_return-type NUMBER ls_return-number
          WITH ls_return-message_v1 ls_return-message_v2 ls_return-message_v3 ls_return-message_v4.
      ENDIF.
      EXIT.
    ENDIF.

    SELECT SINGLE * FROM tinv_inv_doc INTO l_tinv_inv_doc
       WHERE int_inv_doc_no = <t_out>-int_inv_doc_no.

    <t_out>-inv_doc_status = l_tinv_inv_doc-inv_doc_status.

* Dequeue document
    CALL FUNCTION 'DEQUEUE_E_TINV_INV_DOC'
      EXPORTING
        mode_tinv_inv_doc = 'X'
        mandt             = sy-mandt
        int_inv_doc_no    = <t_out>-int_inv_doc_no.

    COMMIT  WORK.

    CALL METHOD cl_inv_inv_remadv_doc=>process_document
      EXPORTING
        im_doc_number          = <t_out>-int_inv_doc_no
      IMPORTING
        ex_return              = lt_return[]
        ex_exit_process_type   = l_proc_type
        ex_proc_error_occurred = l_error
      EXCEPTIONS
        OTHERS                 = 1.

    SELECT SINGLE * FROM tinv_inv_doc INTO l_tinv_inv_doc
       WHERE int_inv_doc_no = <t_out>-int_inv_doc_no.

    <t_out>-inv_doc_status = l_tinv_inv_doc-inv_doc_status.

    IF lt_return[] IS NOT INITIAL.
      CLEAR it_fehler.
      PERFORM get_errormessage USING wa_out-int_inv_doc_no
                         CHANGING it_fehler.

**      Mehrfacheinträge aus der Fehlertabelle löscben
      IF it_fehler IS NOT INITIAL.
        SORT it_fehler.
        DELETE ADJACENT DUPLICATES FROM it_fehler COMPARING ALL FIELDS.
      ENDIF.

      IF it_fehler IS NOT INITIAL.
        READ TABLE it_fehler INTO wa_fehler INDEX 1.
        SELECT * FROM t100 INTO wa_t100
          WHERE sprsl = 'D'
            AND arbgb = wa_fehler-msgid
            AND msgnr = wa_fehler-msgno.
          wa_out-fehler = wa_t100-text.
          REPLACE ALL OCCURRENCES OF '&1' IN <t_out>-fehler WITH wa_fehler-msgv1.
          REPLACE ALL OCCURRENCES OF '&2' IN <t_out>-fehler WITH wa_fehler-msgv2.
          REPLACE ALL OCCURRENCES OF '&3' IN <t_out>-fehler WITH wa_fehler-msgv3.
          REPLACE ALL OCCURRENCES OF '&4' IN <t_out>-fehler WITH wa_fehler-msgv4.
          wa_out-lights = '1'.
          EXIT.
        ENDSELECT.
      ENDIF.
    ENDIF.

    DATA: lv_reklambelnr(3)  TYPE c VALUE '04',
          lv_reklamdoctyp(3) TYPE c VALUE '008'.


    SELECT SINGLE value FROM /adesso/inv_cust INTO lv_reklambelnr   WHERE report = 'GLOBAL' AND field = 'REKLAMBELART'.
    SELECT SINGLE value FROM /adesso/inv_cust INTO lv_reklamdoctyp  WHERE report = 'GLOBAL' AND field = 'REKLAMDOCTYP'.


    IF l_tinv_inv_doc-inv_doc_status = lv_reklambelnr.  "reklamiert.

      SELECT * FROM tinv_inv_doc INTO wa_inv_doc_a
        WHERE ext_invoice_no = <t_out>-ext_invoice_no
         AND doc_type = lv_reklamdoctyp.
        EXIT.
      ENDSELECT.

      SELECT * FROM tinv_inv_line_a INTO wa_inv_line_a
        WHERE int_inv_doc_no = wa_inv_doc_a-int_inv_doc_no
        AND  rstgr NE space.

* ´  Langtext falls vorhanden übertragen
        IF wa_noti IS NOT INITIAL.
          MOVE <t_out>-int_inv_doc_no TO wa_noti-int_inv_doc_no.
          MOVE wa_inv_line_a-int_inv_line_no TO wa_noti-int_inv_line_no.
          MODIFY /idexge/rej_noti FROM wa_noti.
          CLEAR wa_noti-int_inv_doc_no.
          CLEAR wa_noti-int_inv_line_no.
        ENDIF.



*     WA_OUT füllen
        SELECT SINGLE date_of_receipt FROM tinv_inv_head INTO <t_out>-remdate
         WHERE int_inv_no = wa_inv_doc_a-int_inv_no.

        MOVE wa_inv_line_a-int_inv_doc_no  TO <t_out>-remadv.
        MOVE wa_inv_line_a-rstgr          TO <t_out>-rstgr.
        MOVE wa_noti-free_text1           TO <t_out>-free_text1.

      ENDSELECT.

    ENDIF.


  ENDLOOP.


ENDFORM.                    " UCOM_COMPL

*&---------------------------------------------------------------------*
*&      Form  GET_POPUP_COMPL_REASON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_OUT_INV_DOC_NO  text
*      <--P_COMPL_REASON  text
*----------------------------------------------------------------------*
FORM get_popup_compl_reason  USING    p_inv_doc_no
                             CHANGING p_compl_reason.

  DATA: vl_deregswitch_paymnt_proc TYPE e_deregswitch_paymnt_proc.

  DATA: i_selfield      TYPE slis_selfield,
        i_fieldcatalog  TYPE lvc_t_fcat,
        i_structure     TYPE dd02l-tabname
                        VALUE 'INV_DIALOG_SCREEN_ADJ_REASON',
        it_values_alv   TYPE STANDARD TABLE OF
                             inv_dialog_screen_adj_reason,
        i_values_alv    LIKE LINE OF it_values_alv[],
        it_values       TYPE STANDARD TABLE OF tinv_c_adj_rsnt,
        i_values        LIKE LINE OF it_values[],
        it_process_list TYPE tinv_skip_process.



  CALL FUNCTION 'ISU_DB_EDEREGSWITCH2005_SELECT'
    IMPORTING
*     Y_DEREGSWITCH2005       =
*     Y_SERV_PROV_ACTIVE      =
      y_paymnt_proc_active    = vl_deregswitch_paymnt_proc
    EXCEPTIONS
      customizing_not_defined = 1
      error_ocurred           = 2
      OTHERS                  = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING system_error.
  ENDIF.

* Prepare POPUP to display values
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = i_structure
    CHANGING
      ct_fieldcat      = i_fieldcatalog
    EXCEPTIONS
      OTHERS           = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'X' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* Get values
  SELECT * FROM tinv_c_adj_rsnt
           INTO CORRESPONDING FIELDS OF TABLE it_values[].

* Build table for ALV
  LOOP AT    it_values[]
       INTO  i_values
       WHERE spras = sy-langu.
    i_values_alv-adj_rstgr = i_values-rstgr.
    i_values_alv-adj_text  = i_values-text.
    i_values_alv-adj_frequ = 0.
    APPEND i_values_alv TO it_values_alv[].
*   Remove all values for this key
    DELETE it_values[]  WHERE rstgr = i_values-rstgr.
  ENDLOOP.


* Now add values with SPRAS not equal SY-LANGU (only one)
  LOOP AT    it_values[]
       INTO  i_values.
    i_values_alv-adj_rstgr = i_values-rstgr.
    i_values_alv-adj_text  = i_values-text.
    i_values_alv-adj_frequ = 0.
    APPEND i_values_alv TO it_values_alv[].
*   Remove all values for this key
    DELETE it_values[]  WHERE rstgr = i_values-rstgr.
  ENDLOOP.

* Call ALV
  CALL FUNCTION 'LVC_SINGLE_ITEM_SELECTION'
    EXPORTING
      i_title         = text-t03           " Reklamationsgrund auswählen
      it_fieldcatalog = i_fieldcatalog
    IMPORTING
      es_selfield     = i_selfield
    TABLES
      t_outtab        = it_values_alv[].

* Get value by index...
  READ TABLE it_values_alv[]  INDEX i_selfield-tabindex
                              INTO  i_values_alv.
  IF sy-subrc = 0.
    p_compl_reason = i_values_alv-adj_rstgr.
  ELSE.
    CLEAR p_compl_reason.
  ENDIF.

ENDFORM.                    " GET_POPUP_COMPL_REASON


*&---------------------------------------------------------------------*
*&      Form  UCOM_CANC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ucom_canc .

  DATA: canc_reason TYPE inv_cancel_rsn.
  DATA: l_inv_doc TYPE REF TO cl_inv_inv_remadv_doc.
  DATA: l_answer TYPE char1.
  DATA: lt_return TYPE bapirettab.
  DATA:  l_tinv_inv_doc TYPE tinv_inv_doc.

  FIELD-SYMBOLS: <t_out> LIKE wa_out.

  PERFORM get_popup_canc_reason CHANGING canc_reason.

  CHECK canc_reason IS NOT INITIAL.

  LOOP AT it_out ASSIGNING <t_out>
     WHERE sel IS NOT INITIAL.


    READ TABLE gt_filtered
     WITH KEY table_line = sy-tabix
       TRANSPORTING NO FIELDS.

    CHECK sy-subrc NE 0.

*   INT_INVOICE_NO muss gefüllt sein.
*   Bei mehreren Fehlern ist nur die erste Zeile zum Beleg gefüllt.
    CHECK <t_out>-int_inv_doc_no IS NOT INITIAL.


    CREATE OBJECT l_inv_doc
      EXPORTING
        im_work_mode  = cl_inv_inv_remadv_doc=>co_wmode_change
        im_doc_number = <t_out>-int_inv_doc_no
      EXCEPTIONS
        OTHERS        = 1.

    IF sy-subrc <> 0.
      IF l_inv_doc IS NOT INITIAL.
        CALL METHOD l_inv_doc->close.
        EXIT.
      ENDIF.
    ENDIF.

    CLEAR lt_return[].
    CALL METHOD l_inv_doc->change_document_status
      EXPORTING
        im_set_to_reset            = ' '
        im_set_to_released         = ' '
        im_set_to_finished         = ' '
        im_set_to_to_be_complained = ' '
        im_reason_for_complain     = ' '
        im_set_to_to_be_reversed   = 'X'
        im_reversal_rsn            = canc_reason
        im_commit_work             = 'X'
        im_automatic_change        = ' '
        im_create_reversal_doc     = ' '
      IMPORTING
        ex_return                  = lt_return.

    SELECT SINGLE * FROM tinv_inv_doc INTO l_tinv_inv_doc
       WHERE int_inv_doc_no = <t_out>-int_inv_doc_no.

    <t_out>-inv_doc_status = l_tinv_inv_doc-inv_doc_status.

  ENDLOOP.

ENDFORM.                    " UCOM_CANC


*&---------------------------------------------------------------------*
*&      Form  GET_POPUP_CANC_REASON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_CANC_REASON  text
*----------------------------------------------------------------------*
FORM get_popup_canc_reason  CHANGING p_canc_reason.

  DATA: i_selfield     TYPE slis_selfield,
        i_fieldcatalog TYPE lvc_t_fcat,
        i_structure    TYPE dd02l-tabname
                       VALUE 'INV_DIALOG_SCREEN_RVRSL_REASON',
        it_values_alv  TYPE STANDARD TABLE OF
                            inv_dialog_screen_rvrsl_reason,
        i_values_alv   LIKE LINE OF it_values_alv[],
        i_values       TYPE tinv_c_cncl_rsnt.



* Prepare POPUP to display values
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = i_structure
    CHANGING
      ct_fieldcat      = i_fieldcatalog
    EXCEPTIONS
      OTHERS           = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'X' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* Get values
  LOOP AT   cl_inv_inv_remadv_doc=>customizing-t_tinv_c_cncl_rsn[]
       INTO i_values.
    i_values_alv-reversal_rsn     = i_values-inv_cancel_rsn.
    i_values_alv-reversal_rsn_txt = i_values-text.
    APPEND i_values_alv TO it_values_alv[].
  ENDLOOP.


* Call ALV
  CALL FUNCTION 'LVC_SINGLE_ITEM_SELECTION'
    EXPORTING
      i_title         = text-t04           " Stornogrund auswählen
      it_fieldcatalog = i_fieldcatalog
    IMPORTING
      es_selfield     = i_selfield
    TABLES
      t_outtab        = it_values_alv[].


* Get value by index...
  READ TABLE it_values_alv[]  INDEX i_selfield-tabindex
                              INTO  i_values_alv.
  IF sy-subrc = 0.
    p_canc_reason = i_values_alv-reversal_rsn.
  ELSE.
    CLEAR p_canc_reason .
  ENDIF.


ENDFORM.                    " GET_POPUP_CANC_REASON

*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_BUILD_ERROR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_FIELDCAT_ERROR[]  text
*----------------------------------------------------------------------*
FORM fieldcat_build_error  USING lt_fieldcat_error TYPE slis_t_fieldcat_alv.

  DATA: ls_fieldcat TYPE slis_fieldcat_alv.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TEXT'.
  ls_fieldcat-tabname = 'IT_Errorline'.
  ls_fieldcat-seltext_s = 'Fehler'.
  ls_fieldcat-seltext_m = 'Fehlermeldung'.
  ls_fieldcat-seltext_l = 'Fehlermeldung'.
  ls_fieldcat-outputlen = '120'.
  ls_fieldcat-hotspot = 'X'.
  APPEND ls_fieldcat TO lt_fieldcat_error.

ENDFORM.                    " FIELDCAT_BUILD_ERROR


*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_BUILD_EXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_FIELDCAT_EXT[]  text
*----------------------------------------------------------------------*
FORM fieldcat_build_ext  USING   lt_fieldcat_ext TYPE slis_t_fieldcat_alv.

  DATA ls_fieldcat TYPE slis_fieldcat_alv.

* Kennung
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'PRODUCT_ID'.
  ls_fieldcat-tabname = 'IT_EXT_OUT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
  APPEND ls_fieldcat TO lt_fieldcat_ext.

*  Text
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TEXT'.
  ls_fieldcat-tabname = 'IT_EXT_OUT'.
  ls_fieldcat-ref_tabname = 'EDEREG_SIDPROT'.
  APPEND ls_fieldcat TO lt_fieldcat_ext.

* AB
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DATE_FROM'.
  ls_fieldcat-tabname = 'IT_EXT_OUT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
  APPEND ls_fieldcat TO lt_fieldcat_ext.

* BIS
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DATE_TO'.
  ls_fieldcat-tabname = 'IT_EXT_OUT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
  APPEND ls_fieldcat TO lt_fieldcat_ext.

*  Menge
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'QUANTITY'.
  ls_fieldcat-tabname = 'IT_EXT_OUT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
  APPEND ls_fieldcat TO lt_fieldcat_ext.

* Mengeneinheit
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'UNIT'.
  ls_fieldcat-tabname = 'IT_EXT_OUT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
  APPEND ls_fieldcat TO lt_fieldcat_ext.

* Preis
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'PRICE'.
  ls_fieldcat-tabname = 'IT_EXT_OUT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
  APPEND ls_fieldcat TO lt_fieldcat_ext.

* Maßeinheit Preis
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'PRICE_UNIT'.
  ls_fieldcat-tabname = 'IT_EXT_OUT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
  APPEND ls_fieldcat TO lt_fieldcat_ext.

* Nettobetrag
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'ETRW_NET'.
  ls_fieldcat-tabname = 'IT_EXT_OUT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
  APPEND ls_fieldcat TO lt_fieldcat_ext.

* Steuerbetrag
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TAXBW'.
  ls_fieldcat-tabname = 'IT_EXT_OUT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
  APPEND ls_fieldcat TO lt_fieldcat_ext.

* Fälligkeitsdatum
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DATE_OF_PAYMENT'.
  ls_fieldcat-tabname = 'IT_EXT_OUT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
  APPEND ls_fieldcat TO lt_fieldcat_ext.

* Mehrwertsteuerkennzeichen
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'MWSKZ'.
  ls_fieldcat-tabname = 'IT_EXT_OUT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
  APPEND ls_fieldcat TO lt_fieldcat_ext.

* Mehrwertsteuersatz
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'STRPZ'.
  ls_fieldcat-tabname = 'IT_EXT_OUT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
  APPEND ls_fieldcat TO lt_fieldcat_ext.

ENDFORM.                    " FIELDCAT_BUILD_EXT
*&---------------------------------------------------------------------*
*&      Form  belegart_holen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->U_INV_NR   text
*      <--C_BELEGART text
*----------------------------------------------------------------------*
FORM belegart_holen USING u_inv_nr TYPE  tinv_inv_docref-int_inv_no ext_inv_no TYPE inv_ext_invoice_no  CHANGING c_belegart TYPE t_belegart.
  DATA lv_docref TYPE tinv_inv_docref-inbound_ref .
  DATA lv_docnum TYPE edid4-docnum.
  DATA lv_dtint2 TYPE edid4-dtint2.
  DATA lv_sdata TYPE edid4-sdata.
  DATA ls_edid4 TYPE edid4.
  DATA lv_psgnum TYPE edi_psgnum.
  DATA lv_ext_inv_no(42) TYPE c.

  DATA: gv_seg1 TYPE string,
        gv_seg2 TYPE string,
        gv_seg3 TYPE string,
        gv_seg4 TYPE string.

  SELECT SINGLE value FROM /adesso/inv_cust INTO gv_seg1 WHERE report = 'GLOBAL' AND field = 'SEG_1_EDID4'.
  SELECT SINGLE value FROM /adesso/inv_cust INTO gv_seg2 WHERE report = 'GLOBAL' AND field = 'SEG_2_EDID4'.
  SELECT SINGLE value FROM /adesso/inv_cust INTO gv_seg3 WHERE report = 'GLOBAL' AND field = 'SEG_3_EDID4'.
  SELECT SINGLE value FROM /adesso/inv_cust INTO gv_seg4 WHERE report = 'GLOBAL' AND field = 'SEG_4_EDID4'.

  lv_ext_inv_no = '%' && ext_inv_no && '%'.

  SELECT SINGLE inbound_ref
    FROM tinv_inv_docref
    INTO lv_docref
    WHERE int_inv_no = u_inv_nr AND inbound_ref_type = 6.

  lv_docnum = lv_docref.

  DATA:   f_dtint2 TYPE edidd-dtint2,
          f_sdata  TYPE edidd-sdata.
  DATA:  lt_edid4 TYPE TABLE OF edid4.
  FIELD-SYMBOLS: <fs_edid4> TYPE edid4.

  SELECT * FROM edid4
    INTO  TABLE lt_edid4
    WHERE docnum = lv_docnum
    AND ( segnam = gv_seg1 OR segnam = gv_seg2 ).
  LOOP AT lt_edid4 ASSIGNING <fs_edid4> WHERE sdata+58(30) = ext_inv_no.
    SELECT SINGLE dtint2 sdata
       FROM  edid4
       INTO  (f_dtint2, f_sdata )
       WHERE docnum = lv_docnum
       AND  ( segnam = gv_seg2 OR segnam = gv_seg4 )
       AND   psgnum = <fs_edid4>-psgnum.
    CHECK sy-subrc = 0.
    c_belegart  = f_sdata+3(3).
  ENDLOOP.



  .
ENDFORM.                    "belegart_holen
*&---------------------------------------------------------------------*
*&      Form  auswaehlen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM auswaehlen.

  DATA lr_out LIKE REF TO wa_out.

  LOOP AT it_out REFERENCE INTO lr_out WHERE xselp = 'X'.
    lr_out->sel = 'X'.
  ENDLOOP.

  " BREAK-POINT.
ENDFORM.                    "auswaehlen
*&---------------------------------------------------------------------*
*&      Form  ende_task
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->TASKNAME   text
*----------------------------------------------------------------------*
FORM ende_task USING taskname.
  DATA: lt_ergebnis    TYPE /adesso/manager_proz_collect_t,
        ls_ergebnis    TYPE /adesso/manager_proz_collect_s,
        lr_out         LIKE REF TO wa_out,
        lt_inv_collect TYPE tinv_int_inv_doc_no,
        l_tinv_inv_doc TYPE tinv_inv_doc.

  DATA:  lt_return   TYPE bapirettab,
         l_proc_type TYPE inv_process_type,
         l_error     TYPE inv_kennzx.

  RECEIVE RESULTS FROM FUNCTION '/ADESSO/INV_MANAGER_PROCESS_TA'
      IMPORTING
        it_inv_doc_nr    = lt_inv_collect
        CHANGING
        process_document = lt_ergebnis.

  LOOP AT lt_ergebnis INTO ls_ergebnis.
    "invoice zum Prozessieren sammeln
    READ TABLE it_out  REFERENCE INTO lr_out WITH KEY int_inv_doc_no = ls_ergebnis-int_inv_doc_no.
    IF sy-subrc = 0.
      lt_return = ls_ergebnis-ex_return.
      l_proc_type = ls_ergebnis-ex_exit_process_type.
      l_error = ls_ergebnis-ex_proc_error_occurred.

      SELECT SINGLE * FROM tinv_inv_doc INTO l_tinv_inv_doc
         WHERE int_inv_doc_no = lr_out->int_inv_doc_no.

      lr_out->inv_doc_status = l_tinv_inv_doc-inv_doc_status.

      IF lt_return[] IS NOT INITIAL.
        CLEAR it_fehler.
        PERFORM get_errormessage USING lr_out->int_inv_doc_no
                           CHANGING it_fehler.

**      Mehrfacheinträge aus der Fehlertabelle löscben
        IF it_fehler IS NOT INITIAL.
          SORT it_fehler.
          DELETE ADJACENT DUPLICATES FROM it_fehler COMPARING ALL FIELDS.
        ENDIF.

        IF it_fehler IS NOT INITIAL.
          READ TABLE it_fehler INTO wa_fehler INDEX 1.
          SELECT * FROM t100 INTO wa_t100
            WHERE sprsl = 'D'
              AND arbgb = wa_fehler-msgid
              AND msgnr = wa_fehler-msgno.
            lr_out->fehler = wa_t100-text.
            REPLACE ALL OCCURRENCES OF '&1' IN lr_out->fehler WITH wa_fehler-msgv1.
            REPLACE ALL OCCURRENCES OF '&2' IN lr_out->fehler WITH wa_fehler-msgv2.
            REPLACE ALL OCCURRENCES OF '&3' IN lr_out->fehler WITH wa_fehler-msgv3.
            REPLACE ALL OCCURRENCES OF '&4' IN lr_out->fehler WITH wa_fehler-msgv4.
            lr_out->lights = '1'.
          ENDSELECT.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
  SUBTRACT 1 FROM gv_akt_proz.



ENDFORM.                    "ende_task
*&---------------------------------------------------------------------*
*&      Form  Prozesse
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->UV_CHANGE  text
*----------------------------------------------------------------------*
FORM prozesse  USING uv_change.

  TYPES:  BEGIN OF tt_art_check,
            belegart(3) TYPE c,
            anzahl      TYPE i,
          END OF tt_art_check.

  DATA: ex_return    TYPE bapirettab,
        i_doc_object TYPE REF TO cl_inv_inv_remadv_doc,
        ls_art_check TYPE tt_art_check,
        lt_art_check TYPE TABLE OF tt_art_check.

  DATA lr_out LIKE REF TO wa_out.
  DATA lv_anz TYPE i.
  DATA lv_doc_no1 TYPE   inv_int_inv_doc_no.
  DATA lv_count TYPE i.
  DATA lt_tinv_int_inv_doc_no TYPE tinv_int_inv_doc_no.

  DATA: lt_tinv_inv_prcsupp TYPE TABLE OF tinv_inv_prcsupp,
        ls_tinv_inv_prcsupp TYPE  tinv_inv_prcsupp.

  LOOP AT it_out REFERENCE INTO lr_out WHERE sel = 'X'.
    lv_anz = lv_anz + 1.
    ls_art_check-anzahl = 1.
    ls_art_check-belegart = lr_out->belegart.
    COLLECT ls_art_check INTO lt_art_check.
  ENDLOOP.

  IF lines( lt_art_check ) > 1.
    MESSAGE e024(/adesso/inv_manager).
  ENDIF.

  IF lv_anz = 0.
    MESSAGE e025(/adesso/inv_manager).
  ENDIF.

  LOOP AT it_out  REFERENCE INTO lr_out WHERE sel = 'X'.
    FREE i_doc_object.
*    CREATE OBJECT i_doc_object
*      EXPORTING
*        im_work_mode  = cl_inv_inv_remadv_doc=>co_wmode_change
*        im_doc_number = lr_out->int_inv_doc_no
*      EXCEPTIONS
*        others        = 1.
    IF lv_count = 0.
      lv_doc_no1 = lr_out->int_inv_doc_no.
      CALL METHOD cl_inv_inv_remadv_doc=>suppress_subprocess
        EXPORTING
          im_doc_number   = lr_out->int_inv_doc_no
          im_no_close     = ''
          im_dialog_mode  = ''
          im_no_update    = ''
          im_commit_work  = 'X'
          im_display_only = uv_change
        IMPORTING
          ex_return       = ex_return[]
        CHANGING
          ch_doc_object   = i_doc_object.
      IF uv_change = ' '.
        COMMIT WORK.
*        break struck-f.
        " i_doc_object->update( ).
      ENDIF.
      IF lines( ex_return ) = 1.
        CALL METHOD cl_inv_inv_remadv_doc=>suppress_subprocess
          EXPORTING
            im_doc_number   = lr_out->int_inv_doc_no
            im_no_close     = ''
            im_dialog_mode  = 'X'
            im_no_update    = ''
            im_commit_work  = ''
            im_display_only = 'X'
          IMPORTING
            ex_return       = ex_return[]
          CHANGING
            ch_doc_object   = i_doc_object.

      ENDIF.
      lv_count = 1.
    ELSE.

      DELETE FROM tinv_inv_prcsupp WHERE int_inv_doc_no = lr_out->int_inv_doc_no.

      SELECT * FROM tinv_inv_prcsupp INTO TABLE lt_tinv_inv_prcsupp WHERE int_inv_doc_no = lv_doc_no1.

      LOOP AT lt_tinv_inv_prcsupp  INTO ls_tinv_inv_prcsupp.

        ls_tinv_inv_prcsupp-int_inv_doc_no = lr_out->int_inv_doc_no.
        SELECT SINGLE int_inv_no FROM tinv_inv_doc INTO ls_tinv_inv_prcsupp-int_inv_no  WHERE int_inv_doc_no = lr_out->int_inv_doc_no.
        "ls_tinv_inv_prcsupp-int_inv_no = lr_out->int_inv_no.

        INSERT INTO tinv_inv_prcsupp VALUES ls_tinv_inv_prcsupp.
        COMMIT WORK.
        " MESSAGE i602(mc)
      ENDLOOP.



    ENDIF.
  ENDLOOP.


ENDFORM.                    "Prozesse
*&---------------------------------------------------------------------*
*&      Form  refresh_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM refresh_data CHANGING cv_refresh.
  CLEAR: it_out, wa_out.
  cv_refresh = 'X'."Struck 20150407
  PERFORM daten_selektieren.
ENDFORM.                    "refresh_data
*&---------------------------------------------------------------------*
*&      Form  show_references
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM show_references.
  DATA : i_doc_object  TYPE REF TO cl_inv_inv_remadv_doc.

  DATA lr_out LIKE REF TO wa_out.
  DATA lv_anz TYPE i.

  LOOP AT it_out REFERENCE INTO lr_out WHERE sel = 'X'.
    lv_anz = lv_anz + 1.
  ENDLOOP.
  IF lv_anz <> 1.
    MESSAGE 'Bitte genau eine Rechnung auswählen.' TYPE 'E'.
  ENDIF.

  READ TABLE it_out REFERENCE INTO lr_out WITH KEY sel = 'X'.

  FREE i_doc_object.

  CREATE OBJECT i_doc_object
    EXPORTING
      im_work_mode  = cl_inv_inv_remadv_doc=>co_wmode_display
      im_doc_number = lr_out->int_inv_doc_no
    EXCEPTIONS
      OTHERS        = 1.

  CALL FUNCTION 'INV_DISPLAY_REFERENCE'
    EXPORTING
      im_no_dialog              = ''
      imt_tinv_inv_docref       = i_doc_object->doc_docref[]
    EXCEPTIONS
      no_ref_to_display         = 1
      no_ref_function           = 2
      error_in_display_function = 3
      OTHERS                    = 4.

ENDFORM.                    "show_references
*&---------------------------------------------------------------------*
*&      Form  mark_all
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM mark_all.
  DATA lr_out LIKE REF TO wa_out.

  LOOP AT it_out REFERENCE INTO lr_out .
    lr_out->sel = 'X'.
    "  lr_out->xselp = 'X'.
  ENDLOOP.

ENDFORM.                    "mark_all

*&---------------------------------------------------------------------*
*&      Form  unmark_all
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM unmark_all.
  DATA lr_out LIKE REF TO wa_out.
  LOOP AT it_out REFERENCE INTO lr_out .
    lr_out->sel = ' '.
    lr_out->xselp = ' '.
  ENDLOOP.

ENDFORM.                    "unmark_all

FORM enet_preisblatt_anzeigen.

  DATA: ls_out             LIKE  wa_out,
        ls_tinv_inv_line_b TYPE tinv_inv_line_b,
        lv_sparte          TYPE sparte,
        lv_adesparte       TYPE /adesso/sparte,
        lv_count           TYPE i.

  LOOP AT it_out INTO ls_out WHERE sel = 'X'.
    lv_count = lv_count + 1.
  ENDLOOP.
  IF lv_count <> 1.
    MESSAGE 'Bitte genau eine Rechnung auswählen.' TYPE 'E'.
  ELSE.
    READ TABLE it_out INTO ls_out WITH KEY sel = 'X'.
    SELECT SINGLE * FROM tinv_inv_line_b INTO ls_tinv_inv_line_b WHERE int_inv_doc_no = ls_out-int_inv_doc_no AND product_id = '9990001000532'.
*    break struck-f.
    SELECT SINGLE sparte FROM ever INTO lv_sparte WHERE vertrag = ls_out-vertrag.
    IF lv_sparte IS INITIAL.
      SELECT SINGLE sparte FROM eanl INTO lv_sparte  WHERE anlage = ls_out-anlage.
    ENDIF.
    SELECT SINGLE adsparte FROM /adesso/ec_spart INTO lv_adesparte WHERE sparte = lv_sparte.
    IF lv_adesparte = 'ST' OR lv_adesparte IS INITIAL.
      CALL FUNCTION '/ADESSO/ENET_GET_PRICES_ANLAGE'
        EXPORTING
          anlage         = ls_out-anlage
          abr_ab         = ls_out-invperiod_start
          abr_bis        = ls_out-invperiod_end
          display        = 'X'
          abr_preis      = ls_tinv_inv_line_b-price
          int_inv_doc_no = ls_out-int_inv_doc_no
        EXCEPTIONS
          kein_netz      = 1
          OTHERS         = 2.
      IF sy-subrc <> 0.
        MESSAGE 'Netz nicht in den ENET Tabellen gefunden!' TYPE 'E'.
      ENDIF.
    ELSEIF lv_adesparte = 'GA'.

      CALL FUNCTION '/ADESSO/ENET_GET_PREIS_ANL_GAS'
        EXPORTING
          anlage         = ls_out-anlage
          abr_ab         = ls_out-invperiod_start
          abr_bis        = ls_out-invperiod_end
          display        = 'X'
          abr_preis      = ls_tinv_inv_line_b-price
          int_inv_doc_no = ls_out-int_inv_doc_no
* EXCEPTIONS
*         KEIN_NETZ      = 1
*         OTHERS         = 2
        .
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.


    ENDIF.

  ENDIF.

ENDFORM.
FORM init_custom_fields.
  FIELD-SYMBOLS: <var> , <tab> TYPE STANDARD TABLE .
  DATA: gv_string TYPE string,
        gv_type   TYPE typ.
  SELECT  * FROM /adesso/inv_cust INTO gv_cust WHERE report = sy-repid.
    gv_string = gv_cust-field && '[]'.
    ASSIGN (gv_cust-field) TO <var>.
    IF sy-subrc = 0.
      DESCRIBE  FIELD <var> TYPE gv_type.
      IF gv_cust-select_parameter = 'S'.
        ASSIGN (gv_string) TO <tab>.
        IF sy-subrc = 0.
          IF <var> IS INITIAL.
            <var> = gv_cust-value.
            APPEND <var> TO <tab>.
          ENDIF.
        ENDIF.
      ELSEIF  gv_cust-select_parameter = 'P'.
        <var> = gv_cust-value.
      ENDIF.
    ENDIF.
  ENDSELECT.


ENDFORM.

FORM sperren.

  DATA: ls_out      LIKE  wa_out,
        lv_count    TYPE i,
        lv_sperr    TYPE c,
        ls_invsperr TYPE /adesso/invsperr,
        lv_entsperr TYPE c.

  LOOP AT it_out INTO ls_out WHERE sel = 'X'.

    SELECT COUNT(*) FROM /adesso/invsperr WHERE int_inv_doc_nr = ls_out-int_inv_doc_no.
    IF sy-subrc = 0.
      lv_entsperr = 'X'.
    ELSE.
      lv_sperr = 'X'.
    ENDIF.
    lv_count = lv_count + 1.

  ENDLOOP.

*  break struck-f.

  IF lv_sperr = 'X' AND lv_entsperr = 'X'.
    MESSAGE 'Bitte entweder gesperrte oder freie Belege selektieren.' TYPE 'E'.
  ELSEIF lv_sperr = ' ' AND lv_entsperr = 'X'.
    LOOP AT it_out INTO ls_out WHERE sel = 'X'.
      DELETE FROM /adesso/invsperr WHERE  int_inv_doc_nr = ls_out-int_inv_doc_no.
    ENDLOOP.
    MESSAGE lv_count && 'Belege entsperrt.' TYPE 'I'.
  ELSEIF lv_sperr = 'X' AND lv_entsperr = ' '.
    LOOP AT it_out INTO ls_out WHERE sel = 'X'.
      ls_invsperr-int_inv_doc_nr = ls_out-int_inv_doc_no.
      ls_invsperr-datum = sy-datum.
      ls_invsperr-username = sy-uname.
      INSERT INTO /adesso/invsperr  VALUES ls_invsperr.
    ENDLOOP.
    MESSAGE lv_count && 'Belege gesperrt.' TYPE 'I'.
  ENDIF.


ENDFORM.
FORM reset_status USING refresh release.



  DATA: l_inv_doc TYPE REF TO cl_inv_inv_remadv_doc.
  DATA: lt_return TYPE bapirettab.
  DATA: ls_return TYPE bapiret2.
  DATA:  l_tinv_inv_doc TYPE tinv_inv_doc.
  DATA:  l_proc_type TYPE inv_process_type.
  DATA:  l_error     TYPE inv_kennzx.
  DATA:  l_done   TYPE char1.

  FIELD-SYMBOLS: <t_out> LIKE wa_out.


  CLEAR l_done.
  LOOP AT it_out ASSIGNING <t_out>
     WHERE sel IS NOT INITIAL.


    READ TABLE gt_filtered
     WITH KEY table_line = sy-tabix
       TRANSPORTING NO FIELDS.

    CHECK sy-subrc NE 0.

*   INT_INVOICE_NO muss gefüllt sein.
    CHECK <t_out>-int_inv_doc_no IS NOT INITIAL.


    CREATE OBJECT l_inv_doc
      EXPORTING
        im_work_mode  = cl_inv_inv_remadv_doc=>co_wmode_change
        im_doc_number = <t_out>-int_inv_doc_no
      EXCEPTIONS
        OTHERS        = 1.

    IF sy-subrc <> 0.
      IF l_inv_doc IS NOT INITIAL.
        CALL METHOD l_inv_doc->close.
      ENDIF.
      EXIT.
    ENDIF.

    CLEAR lt_return[].

    CALL METHOD l_inv_doc->change_document_status
      EXPORTING
        im_set_to_reset            = refresh
        im_set_to_released         = release
        im_set_to_finished         = ' '
        im_set_to_to_be_complained = ' '
        im_reason_for_complain     = ' '
        im_set_to_to_be_reversed   = ' '
        im_reversal_rsn            = ' '
        im_commit_work             = 'X'
        im_automatic_change        = ' '
        im_create_reversal_doc     = ' '
      IMPORTING
        ex_return                  = lt_return.

    IF lt_return IS NOT INITIAL.
      READ TABLE lt_return INTO ls_return
         WITH KEY type = 'E'.
      IF sy-subrc = 0.
        MESSAGE ID ls_return-id TYPE ls_return-type NUMBER ls_return-number
          WITH ls_return-message_v1 ls_return-message_v2 ls_return-message_v3 ls_return-message_v4.
      ENDIF.
      EXIT.
    ENDIF.

    SELECT SINGLE * FROM tinv_inv_doc INTO l_tinv_inv_doc
       WHERE int_inv_doc_no = <t_out>-int_inv_doc_no.

    <t_out>-inv_doc_status = l_tinv_inv_doc-inv_doc_status.

* Dequeue document
    CALL FUNCTION 'DEQUEUE_E_TINV_INV_DOC'
      EXPORTING
        mode_tinv_inv_doc = 'X'
        mandt             = sy-mandt
        int_inv_doc_no    = <t_out>-int_inv_doc_no.

  ENDLOOP.


ENDFORM.
FORM add_text USING action.
  DATA: title              TYPE text80,
        text1              TYPE text132,
        text2              TYPE text132,
        text255            TYPE text255,
        anzahl_sel         TYPE anzahl,
        ls_out             LIKE  wa_out,
        line_no            TYPE i,
        lt_invtext         TYPE TABLE OF /adesso/invtext,
        ls_invtext         TYPE /adesso/invtext,
        lt_fields          TYPE TABLE OF sval,
        ls_fields          TYPE  sval,
        lv_textnr          TYPE i,
        lv_spaces          TYPE i,
        lv_spacechars(255),
        int_doc_string     TYPE string,
        answer(1)          TYPE c.

*BREAK struck-f.
  LOOP AT it_out INTO ls_out WHERE sel = 'X'.
    SELECT * FROM /adesso/invtext INTO ls_invtext WHERE int_inv_doc_nr = ls_out-int_inv_doc_no.

      READ TABLE lt_invtext TRANSPORTING NO FIELDS WITH  KEY datum = ls_invtext-datum zeit = ls_invtext-zeit uname = ls_invtext-uname.
      IF sy-subrc <> 0.
        lv_textnr = lv_textnr + 1 .
        IF lv_textnr > 15.
          EXIT.
        ENDIF.
        int_doc_string =  ls_out-int_inv_doc_no.
        SHIFT int_doc_string LEFT DELETING LEADING '0'.
        lv_spaces = 2.
        CONCATENATE  '' ls_invtext-text  INTO ls_invtext-text SEPARATED BY lv_spacechars(lv_spaces).
        CLEAR ls_fields.
        ls_fields-tabname      = '/ADESSO/TEXDUMMY'.
        ls_fields-fieldname    = 'TEXT' && lv_textnr.
        ls_fields-field_attr   = '02'.
        ls_fields-value = 'Beleg' && int_doc_string && ' von: ' && ls_invtext-uname && ' am: ' &&  ls_invtext-datum   && ': ' && ls_invtext-text .
*  FIELDS-VALUE       = E070-TRKORR.
* Schlüsselwort soll nicht aus dem Dictionary übernommen werden
        ls_fields-fieldtext    = 'vorhandene Bemerkung:'.
*                                      (050).
        ls_fields-field_obl    = ' '.
        APPEND ls_fields TO lt_fields.
        APPEND ls_invtext TO lt_invtext.
      ENDIF.

    ENDSELECT.
  ENDLOOP.
  CLEAR ls_invtext.


  title = 'Bemerkung zum ' && action && ' anlegen.'.

* Aufbau des Dialogfensters festlegen
  CLEAR ls_fields.
  ls_fields-tabname      = '/ADESSO/INVTEXT'.
  ls_fields-fieldname    = 'TEXT'.
*  FIELDS-VALUE       = E070-TRKORR.
* Schlüsselwort soll nicht aus dem Dictionary übernommen werden
  ls_fields-fieldtext    = 'Bemerkung.'.
*                                      (050).
  ls_fields-field_obl    = ' '.
  APPEND ls_fields TO lt_fields.
  line_no = sy-tabix.

  CALL FUNCTION 'POPUP_GET_VALUES_USER_BUTTONS'
    EXPORTING
*     F1_FORMNAME        = ' '
*     F1_PROGRAMNAME     = ' '
*     F4_FORMNAME        = ' '
*     F4_PROGRAMNAME     = ' '
      formname           = 'HANDLE_CODE_OK'
      programname        = '/ADESSO/INVOIC_MANAGER'
      popup_title        = title
      ok_pushbuttontext  = 'Ja'
      quickinfo_ok_push  = 'Es wird ein Text angelegt'
      first_pushbutton   = 'Nein'
      quickinfo_button_1 = 'Es wird kein Text angelegt '
* IMPORTING
*     RETURNCODE         =
    TABLES
      fields             = lt_fields
* EXCEPTIONS
*     ERROR_IN_FIELDS    = 1
*     OTHERS             = 2
    .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
*BREAK struck-f.
  IF gv_okcode = 'J'.
*BREAK struck-f.
    LOOP AT it_out INTO ls_out WHERE sel = 'X'.
      READ TABLE lt_fields INTO ls_fields INDEX line_no.
      ls_invtext-text = ls_fields-value.
      ls_invtext-datum = sy-datum.
      ls_invtext-action = action.
      ls_invtext-int_inv_doc_nr = ls_out-int_inv_doc_no.
      ls_invtext-uname = sy-uname.
      ls_invtext-zeit = sy-uzeit.

      INSERT INTO /adesso/invtext VALUES ls_invtext.
    ENDLOOP.

  ENDIF."ls_invtext-





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
    lt_texte TYPE TABLE OF /adesso/invtext,
    ls_texte TYPE  /adesso/invtext.

  SELECT * FROM /adesso/invtext INTO TABLE lt_texte WHERE int_inv_doc_nr = docnr.

  DATA ls_fieldcat TYPE slis_fieldcat_alv.
  DATA lt_fieldcat_ext TYPE TABLE OF slis_fieldcat_alv.

* Kennung
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'INT_INV_DOC_NR'.
  ls_fieldcat-tabname = 'LT_TEXTE'.
  ls_fieldcat-ref_tabname = '/ADESSO/INVTEXT'.
  APPEND ls_fieldcat TO lt_fieldcat_ext.

* AB
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DATUM'.
  ls_fieldcat-tabname = 'LT_TEXTE'.
  ls_fieldcat-ref_tabname = '/ADESSO/INVTEXT'.
  APPEND ls_fieldcat TO lt_fieldcat_ext.

* BIS
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'UNAME'.
  ls_fieldcat-tabname = 'LT_TEXTE'.
  ls_fieldcat-ref_tabname = '/ADESSO/INVTEXT'.
  APPEND ls_fieldcat TO lt_fieldcat_ext.

*  Menge
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'ACTION'.
  ls_fieldcat-tabname = 'LT_TEXTE'.
  ls_fieldcat-ref_tabname = '/ADESSO/INVTEXT'.
  APPEND ls_fieldcat TO lt_fieldcat_ext.

*  Text
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TEXT'.
  ls_fieldcat-tabname = 'LT_TEXTE'.
  ls_fieldcat-ref_tabname = '/ADESSO/INVTEXT'.
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
FORM check_sperre.
  DATA: ls_out      LIKE  wa_out,
        lv_count    TYPE i,
        ls_invsperr TYPE /adesso/invsperr,
        lv_entsperr TYPE c.

  LOOP AT it_out INTO ls_out WHERE sel = 'X'.

    SELECT COUNT(*) FROM /adesso/invsperr WHERE int_inv_doc_nr = ls_out-int_inv_doc_no.
    IF sy-subrc = 0.
      lv_entsperr = 'X'.
    ENDIF.
    lv_count = lv_count + 1.

  ENDLOOP.

  IF lv_entsperr = 'X'.
    MESSAGE 'Ein oder mehrere Belege sind gesperrt. Aktion abgebrochen.' TYPE 'E'.
  ENDIF.



ENDFORM.
