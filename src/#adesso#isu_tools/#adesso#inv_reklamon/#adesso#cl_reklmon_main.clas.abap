
CLASS /adesso/cl_reklmon_main DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor .
  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS: co_object TYPE tdobject VALUE 'Z_REMADV',
               co_id     TYPE tdid VALUE 'Z001'.
    TYPES tr_doctype TYPE inv_doc_type .
    TYPES tr_aggr TYPE vkont_kk .
    TYPES tr_send TYPE inv_int_sender .
    TYPES tr_reci TYPE inv_int_receiver .

    DATA p_invtp TYPE /adesso/fi_negremadv_invtyp .
    DATA:
      s_aggr   TYPE RANGE OF tr_aggr .
    DATA:
      s_send   TYPE RANGE OF tr_send .
    DATA:
      s_rece   TYPE RANGE OF tr_reci .
    DATA:
      s_insta  TYPE RANGE OF inv_invoice_status .
    DATA:
      s_dtrec  TYPE RANGE OF inv_date_of_receipt .
    DATA:
      s_intido TYPE RANGE OF inv_int_inv_doc_no .
    DATA:
      s_extido TYPE RANGE OF inv_ext_invoice_no .
    DATA:
      s_doctyp TYPE RANGE OF tr_doctype .
    DATA:
      s_idosta TYPE RANGE OF inv_doc_status .
    DATA:
      s_dtpaym TYPE RANGE OF inv_date_of_payment .
    DATA:
      s_invoda TYPE RANGE OF inv_invoice_date .
    DATA:
      s_rstgr  TYPE RANGE OF rstgr .
    DATA:
      s_owninv TYPE RANGE OF inv_own_invoice_no .
    DATA:
      s_extui  TYPE RANGE OF ext_ui .
    DATA pa_lockr TYPE mansp_old_kk .
    DATA pa_fdate LIKE sy-datum .
    DATA pa_tdate LIKE sy-datum .
    DATA p_storno TYPE c .
    DATA p_vari TYPE disvariant-variant .
    DATA lv_invtype TYPE inv_invoice_type VALUE 004 ##NO_TEXT.

    METHODS set_remadv_finished_single
      IMPORTING
        !im_doc_number TYPE inv_int_inv_doc_no .
    METHODS set_remadv_finished_mass
      IMPORTING
        !it_doc_number TYPE tinv_int_inv_doc_no .
    METHODS select_data .
    METHODS select_data_2 .
ENDCLASS.



CLASS /ADESSO/CL_REKLMON_MAIN IMPLEMENTATION.


  METHOD constructor.
  ENDMETHOD.


  METHOD select_data.

    DATA ls_out TYPE /adesso/inv_s_rekl_sel_gen.
    DATA lt_out TYPE TABLE OF /adesso/inv_s_rekl_sel_gen.
    DATA wa_inv_line_a     TYPE tinv_inv_line_a.
    DATA wa_inv_c_adj_rsnt TYPE tinv_c_adj_rsnt.
    DATA wa_noti           TYPE /idexge/rej_noti.
    DATA wa_ecrossrefno    TYPE ecrossrefno.
    DATA wa_euitrans       TYPE euitrans.
    DATA: x_ctrem TYPE i.

    DATA: BEGIN OF wa_paym,
            own_invoice_no TYPE inv_own_invoice_no,                 "Crossref
            int_inv_doc_no TYPE tinv_inv_line_a-int_inv_doc_no,         "AVIS-Nr
            invoice_status TYPE tinv_inv_head-invoice_status,           "AVIS-Status
          END OF wa_paym.
    DATA ls_paym LIKE wa_paym.

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
      AND h~invoice_type EQ lv_invtype
      AND h~date_of_receipt IN s_dtrec
      AND h~invoice_status IN s_insta
      AND h~int_receiver IN s_rece
      AND d~int_inv_doc_no IN s_intido
      AND d~ext_invoice_no IN s_extido
      AND d~doc_type IN s_doctyp
      AND d~inv_doc_status IN s_idosta
      AND d~date_of_payment IN s_dtpaym.

      x_ctrem = x_ctrem + 1.

      MOVE wa_inv_head_doc-int_receiver TO ls_out-int_receiver.
      MOVE wa_inv_head_doc-int_sender   TO ls_out-int_sender.
      MOVE wa_inv_head_doc-invoice_status   TO ls_out-invoice_status.
      MOVE wa_inv_head_doc-date_of_receipt  TO ls_out-date_of_receipt.

      MOVE wa_inv_head_doc-int_inv_doc_no TO ls_out-int_inv_doc_no.
      MOVE wa_inv_head_doc-ext_invoice_no TO ls_out-ext_invoice_no.
      MOVE wa_inv_head_doc-doc_type TO ls_out-doc_type.
      MOVE wa_inv_head_doc-inv_doc_status TO ls_out-inv_doc_status.
      MOVE wa_inv_head_doc-date_of_payment TO ls_out-date_of_payment.
      MOVE wa_inv_head_doc-invoice_date TO ls_out-invoice_date.

* AVIS-Zeilen
      CLEAR wa_inv_line_a.
      SELECT * FROM tinv_inv_line_a INTO wa_inv_line_a
*      WHERE int_inv_doc_no EQ wa_inv_doc-int_inv_doc_no         "Nuss 08.2012
          WHERE int_inv_doc_no EQ wa_inv_head_doc-int_inv_doc_no   "Nuss 08.2012
          AND  rstgr IN s_rstgr
          AND  own_invoice_no IN s_owninv.

        CHECK wa_inv_line_a-rstgr IS NOT INITIAL.
        CHECK wa_inv_line_a-own_invoice_no IS NOT INITIAL.

        IF ls_out-int_inv_doc_no IS INITIAL.
          MOVE wa_inv_head_doc-int_receiver TO ls_out-int_receiver.
          MOVE wa_inv_head_doc-int_sender   TO ls_out-int_sender.
          MOVE wa_inv_head_doc-invoice_status   TO ls_out-invoice_status.
          MOVE wa_inv_head_doc-date_of_receipt  TO ls_out-date_of_receipt.

          MOVE wa_inv_head_doc-int_inv_doc_no TO ls_out-int_inv_doc_no.
          MOVE wa_inv_head_doc-ext_invoice_no TO ls_out-ext_invoice_no.
          MOVE wa_inv_head_doc-doc_type TO ls_out-doc_type.
          MOVE wa_inv_head_doc-inv_doc_status TO ls_out-inv_doc_status.
          MOVE wa_inv_head_doc-date_of_payment TO ls_out-date_of_payment.
          MOVE wa_inv_head_doc-invoice_date TO ls_out-invoice_date.
        ENDIF.

* Text zum Reklamationsgrund
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
          ls_out-free_text5 = wa_noti-free_text5.
          IF wa_noti-stat_remk(3) = '@0V'.
            ls_out-line_state = icon_okay.

          ENDIF.
          EXIT.
        ENDSELECT.

*     WA_OUT füllen
        MOVE wa_inv_line_a-int_inv_line_no TO ls_out-int_inv_line_no.
        MOVE wa_inv_line_a-rstgr          TO ls_out-rstgr.
        MOVE wa_inv_c_adj_rsnt-text       TO ls_out-text.
        MOVE wa_noti-free_text1           TO ls_out-free_text1.
        MOVE wa_inv_line_a-own_invoice_no TO ls_out-own_invoice_no.
        MOVE wa_inv_line_a-betrw_req      TO ls_out-betrw_req.

        CLEAR wa_ecrossrefno.

        SELECT * FROM ecrossrefno INTO wa_ecrossrefno
          WHERE crossrefno = wa_inv_line_a-own_invoice_no(15)
          OR    crn_rev = wa_inv_line_a-own_invoice_no(15).
          EXIT.
        ENDSELECT.

*        DATA ls_paym LIKE wa_paym.
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
    WHERE a~own_invoice_no = wa_ecrossrefno-crossrefno.

        IF sy-subrc = 0.
          ls_out-paym_avis = ls_paym-int_inv_doc_no.
          ls_out-paym_stat = ls_paym-invoice_status.
        ENDIF.


        DATA: b_storno TYPE boolean.
        b_storno = abap_false.
        CLEAR ls_out-inf_invoice_cancel.
        IF wa_ecrossrefno-crn_rev EQ wa_inv_line_a-own_invoice_no.
          ls_out-inf_invoice_cancel = icon_storno.
          b_storno = abap_true.
        ENDIF.

        CLEAR wa_euitrans.
        SELECT SINGLE * FROM euitrans INTO wa_euitrans
           WHERE int_ui = wa_ecrossrefno-int_ui
           AND dateto = '99991231'.

        CHECK wa_euitrans-ext_ui IN s_extui.

        MOVE wa_euitrans-ext_ui TO ls_out-ext_ui.

* Abrechnungsklasse ermitteln
        SELECT aklasse INTO ls_out-aklasse
          FROM eanlh AS a
            INNER JOIN euiinstln AS b
            ON b~anlage = a~anlage
            INNER JOIN euitrans AS c
             ON c~int_ui = b~int_ui
          WHERE c~ext_ui = ls_out-ext_ui
            AND c~dateto = '99991231'
            AND a~bis = '99991231'.
          EXIT.
        ENDSELECT.


      ENDSELECT.
    ENDSELECT.



  ENDMETHOD.


  METHOD select_data_2.
    DATA ls_out TYPE /adesso/inv_s_rekl_sel_gen.
    DATA lt_out TYPE TABLE OF /adesso/inv_s_rekl_sel_gen.
    DATA: BEGIN OF wa_remadv.
            INCLUDE TYPE vinv_monitoring.
    DATA:   int_inv_line_no TYPE tinv_inv_line_a-int_inv_line_no,        "AVIS-Zeile
            rstgr           TYPE tinv_inv_line_a-rstgr,                  "AVIS-Zeile
            own_invoice_no  TYPE ecrossrefno-crossrefno,                 "AVIS-Zeile
            betrw_req       TYPE tinv_inv_line_a-betrw_req,              "AVIS-Zeile
            free_text1      TYPE /idexge/rej_noti-free_text1,            "Rejection Notification
            free_text5      TYPE /idexge/rej_noti-free_text5.            "Rejection Notification
    DATA: END OF wa_remadv.
    FIELD-SYMBOLS: <fs_remadv> LIKE wa_remadv.
    DATA: BEGIN OF wa_paym,
            own_invoice_no TYPE inv_own_invoice_no,                 "Crossref
            int_inv_doc_no TYPE tinv_inv_line_a-int_inv_doc_no,         "AVIS-Nr
            invoice_status TYPE tinv_inv_head-invoice_status,           "AVIS-Status
          END OF wa_paym.
    DATA: t_paym LIKE TABLE OF wa_paym.
    DATA: r_vktyp TYPE RANGE OF te002a-vktyp.
    DATA: x_ctrem TYPE i.
    DATA: BEGIN OF wa_crsrf_eui,
            int_crossrefno TYPE dfkkthi-crsrf,
            crossrefno     TYPE inv_own_invoice_no,
            crn_rev        TYPE inv_own_invoice_no,
            int_ui         TYPE ecrossrefno-int_ui,
            ext_ui         TYPE euitrans-ext_ui,
            dateto         TYPE euitrans-dateto,
          END OF wa_crsrf_eui.
    DATA: t_crsrf_eui LIKE TABLE OF wa_crsrf_eui.
    DATA: t_crsrf_eu2 LIKE TABLE OF wa_crsrf_eui.
    DATA wa_inv_c_adj_rsnt TYPE tinv_c_adj_rsnt.
    DATA: wa_noti           TYPE /idexge/rej_noti.

    DATA lv_invtype TYPE tinv_inv_head-invoice_type.
    DATA: t_inv_c_adj_rsnt TYPE TABLE OF tinv_c_adj_rsnt.
    DATA: r_send LIKE s_send.
    DATA: t_remadv LIKE TABLE OF wa_remadv.
    CONSTANTS:  co_linetype TYPE tinv_inv_line_a-line_type VALUE '006'.
    CONSTANTS:  co_invpaym TYPE tinv_inv_head-invoice_type VALUE '002'.
    CONSTANTS:  co_docpaym TYPE tinv_inv_doc-doc_type VALUE '004'.
    lv_invtype = lv_invtype.


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

*  t_crsrf_eu2[] = t_crsrf_eui[].
    SORT t_crsrf_eui BY crossrefno.
    SORT t_crsrf_eu2 BY crn_rev.

    LOOP AT t_remadv ASSIGNING <fs_remadv>.

      AT NEW int_inv_doc_no.
        x_ctrem = x_ctrem + 1.
      ENDAT.

      CLEAR ls_out.
      MOVE-CORRESPONDING <fs_remadv> TO ls_out.
** Zeilenstatus
*    IF <fs_remadv>-stat_remk(3) = '@0V'.
*      wa_out-line_state = icon_okay.
*    ENDIF.
** Aggr. Vertragskonto ermitteln
      SELECT SINGLE a~vkont INTO ls_out-aggvk
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
        ls_out-text = wa_inv_c_adj_rsnt-text.
      ENDIF.
      FIELD-SYMBOLS: <fs_crsrf_eui> LIKE wa_crsrf_eui.
* Crosreferenz / Zählpunkt
      READ TABLE t_crsrf_eui
           ASSIGNING <fs_crsrf_eui>
           WITH KEY crossrefno = <fs_remadv>-own_invoice_no
           BINARY SEARCH.
      DATA: b_storno TYPE boolean.
      IF sy-subrc = 0 AND <fs_crsrf_eui> IS ASSIGNED.
        b_storno = abap_false.
        ls_out-ext_ui         = <fs_crsrf_eui>-ext_ui.
        ls_out-int_crossrefno = <fs_crsrf_eui>-int_crossrefno.
      ELSE.
        READ TABLE t_crsrf_eu2
             ASSIGNING <fs_crsrf_eui>
             WITH KEY crn_rev = <fs_remadv>-own_invoice_no
             BINARY SEARCH.
        IF sy-subrc = 0 AND <fs_crsrf_eui> IS ASSIGNED.
          ls_out-inf_invoice_cancel = icon_status_reverse.
          ls_out-ext_ui         = <fs_crsrf_eui>-ext_ui.
          ls_out-int_crossrefno = <fs_crsrf_eui>-int_crossrefno.
          b_storno = abap_true.
        ENDIF.
      ENDIF.

      CHECK ls_out-ext_ui IN s_extui.
      CHECK ls_out-int_crossrefno IS NOT INITIAL.

* Abrechnungsklasse ermitteln
      SELECT aklasse INTO ls_out-aklasse
        FROM eanlh AS a
          INNER JOIN euiinstln AS b
          ON b~anlage = a~anlage
          INNER JOIN euitrans AS c
           ON c~int_ui = b~int_ui
        WHERE c~ext_ui = ls_out-ext_ui
          AND c~dateto = '99991231'
          AND a~bis = '99991231'.
        EXIT.
      ENDSELECT.


      SELECT * FROM /idexge/rej_noti INTO wa_noti
    WHERE int_inv_doc_no = ls_out-int_inv_doc_no.
        IF wa_noti-stat_remk(3) = '@0V'.
          ls_out-line_state = icon_okay.
        ENDIF.
        EXIT.
      ENDSELECT.
*   Zahlungsavis vorhanden?
      FIELD-SYMBOLS: <fs_paym> LIKE wa_paym.
      READ TABLE t_paym
           ASSIGNING <fs_paym>
           WITH KEY own_invoice_no = <fs_remadv>-own_invoice_no
           BINARY SEARCH.

      IF sy-subrc = 0 AND <fs_paym> IS ASSIGNED.
        ls_out-paym_avis = <fs_paym>-int_inv_doc_no.
        ls_out-paym_stat = <fs_paym>-invoice_status.
      ENDIF.

      SELECT COUNT(*) FROM /adesso/remtext WHERE int_inv_doc_nr = ls_out-int_inv_doc_no.
      IF sy-subrc = 0.
        ls_out-text_vorhanden = 'X'.
      ELSE.
        ls_out-text_vorhanden = ''.
      ENDIF.
      DATA gv_name   TYPE tdobname.
      CONCATENATE ls_out-int_inv_doc_no
                  '_'
                  ls_out-int_inv_line_no
                  INTO gv_name.


      DATA: xlines TYPE STANDARD TABLE OF tline.
      DATA: help_line TYPE tline.
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
        ls_out-free_text5 = help_line.
        "  MODIFY it_out FROM wa_out ."INDEX fp_tabindex.
      ENDIF.

      APPEND ls_out TO lt_out.
      CLEAR ls_out.

    ENDLOOP.

  ENDMETHOD.


  METHOD set_remadv_finished_mass.
    DATA ls_doc_number LIKE LINE OF it_doc_number.

    LOOP AT it_doc_number INTO ls_doc_number.

      me->set_remadv_finished_single( im_doc_number = ls_doc_number ).

    ENDLOOP.

  ENDMETHOD.


  METHOD set_remadv_finished_single.

    DATA: l_inv_doc TYPE REF TO cl_inv_inv_remadv_doc.
    DATA: lt_return TYPE bapirettab.

    CREATE OBJECT l_inv_doc
      EXPORTING
        im_work_mode  = cl_inv_inv_remadv_doc=>co_wmode_change
        im_doc_number = im_doc_number
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


  ENDMETHOD.
ENDCLASS.
