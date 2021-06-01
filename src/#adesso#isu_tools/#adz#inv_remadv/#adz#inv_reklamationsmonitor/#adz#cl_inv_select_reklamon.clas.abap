CLASS /adz/cl_inv_select_reklamon DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC INHERITING FROM /adz/cl_inv_select_basic.

  PUBLIC SECTION.
    CONSTANTS   mco_object TYPE tdobject VALUE 'Z_REMADV'.
    CONSTANTS   mco_id     TYPE tdid     VALUE 'Z001'.
    CONSTANTS   mco_nn     TYPE /adz/inv_s_sel_screen-p_invtp VALUE /adz/if_remadv_constants=>mc_invoice_type_nn.
    CONSTANTS   mco_memi   TYPE /adz/inv_s_sel_screen-p_invtp VALUE /adz/if_remadv_constants=>mc_invoice_type_memi.
    CONSTANTS   mco_mgv    TYPE /adz/inv_s_sel_screen-p_invtp VALUE /adz/if_remadv_constants=>mc_invoice_type_mgv.
    CONSTANTS   mco_msb    TYPE /adz/inv_s_sel_screen-p_invtp VALUE /adz/if_remadv_constants=>mc_invoice_type_msb.

    DATA  mt_out_reklamon_data   TYPE  /adz/inv_t_out_reklamon.
    DATA  mv_inv_head_ctr  TYPE integer.
    METHODS  :
      read_reklamon_data
        IMPORTING is_sel_screen TYPE /adz/inv_s_sel_screen
        .
  PROTECTED SECTION.

    METHODS :
      get_locks
        IMPORTING iv_pinvtyp  TYPE /adz/inv_s_sel_screen-p_invtp
                  irs_dfkkthi TYPE REF TO dfkkthi OPTIONAL
        CHANGING  cs_out      TYPE /adz/inv_s_out_reklamon,

      sel_invstorno
        IMPORTING iv_pinvtyp TYPE /adz/inv_s_sel_screen-p_invtp
        CHANGING  cs_out     TYPE /adz/inv_s_out_reklamon,

      fill_nn_specific
        IMPORTING iv_int_crossrefno   TYPE int_crossrefno
                  irt_tinv_inv_docref TYPE REF TO ttinv_inv_docref
        CHANGING  crs_wa_out          TYPE REF TO /adz/inv_s_out_reklamon
        RETURNING VALUE(rt_table)     TYPE isu_dfkkthi_t,

      fill_mgv_specific
        IMPORTING crs_wa_out      TYPE REF TO /adz/inv_s_out_reklamon
        RETURNING VALUE(rt_table) TYPE isu_dfkkthi_t,

      fill_msb_specific
        IMPORTING crs_wa_out TYPE REF TO /adz/inv_s_out_reklamon
        .
    CLASS-METHODS:
      get_new_crossnr_flag RETURNING VALUE(rb_newcrossnr) TYPE abap_bool,

      get_text_vorhanden
        IMPORTING iv_int_inv_doc_no        TYPE  inv_int_inv_doc_no
        RETURNING VALUE(rv_text_vorhanden) TYPE  char1,

      get_read_text
        IMPORTING iv_int_inv_doc_no   TYPE  inv_int_inv_doc_no
                  iv_int_inv_line_no  TYPE  inv_int_inv_line_no
        RETURNING VALUE(rv_read_text) TYPE string.

  PRIVATE SECTION.

    METHODS read_delvnote
      IMPORTING
        !int_ui             TYPE int_ui
        !date_from          TYPE inv_date_from OPTIONAL
        !date_to            TYPE inv_date_to OPTIONAL
      RETURNING
        VALUE(lieferschein) TYPE /idxgl/engy_val .
ENDCLASS.



CLASS /adz/cl_inv_select_reklamon IMPLEMENTATION.


  METHOD fill_mgv_specific.
    DATA: ls_dfkkinvdoc_h  TYPE dfkkinvdoc_h,
          ls_crossrefno    TYPE ecrossrefno,
          ls_dfkkinvbill_x TYPE dfkkinvbill_x,
          ls_dfkkinvdoc_x  TYPE dfkkinvdoc_x.

    SELECT SINGLE * FROM ecrossrefno INTO ls_crossrefno
       WHERE int_crossrefno = crs_wa_out->int_crossrefno.
    CHECK sy-subrc EQ 0.

*    SELECT DFKKINVDOC_H
    SELECT SINGLE  * FROM dfkkinvdoc_h INTO CORRESPONDING FIELDS OF crs_wa_out->*
       WHERE invdocno = ls_crossrefno-belnr.
    CHECK sy-subrc EQ 0.

    "Abrechnungsbeleg selektieren
    SELECT SINGLE * FROM dfkkinvdoc_x INTO ls_dfkkinvdoc_x
      WHERE refobjname = 'MGV_SSQNOT' AND invdocno = crs_wa_out->invdocno.

    IF sy-subrc EQ 0.
      SELECT SINGLE * FROM dfkkinvbill_x INTO ls_dfkkinvbill_x
        WHERE refobjname = 'MGV_SSQNOT' AND refobjvalue = ls_dfkkinvdoc_x-refobjvalue.
      IF sy-subrc EQ 0.
        SELECT SINGLE
            billdocno
            refdocno
            doctype
            gpart
            vkont
            gpart_inv
            vkont_inv
            date_from
            date_to
            simulated
            crname
            crdate
            crtime
        FROM dfkkinvbill_h INTO CORRESPONDING FIELDS OF crs_wa_out->*
          WHERE billdocno = ls_dfkkinvbill_x-billdocno.
      ENDIF.
    ENDIF.

*PDOC Nummer holen
    SELECT SINGLE refobjvalue FROM dfkkinvdoc_x INTO crs_wa_out->proc_ref
      WHERE refobjname = 'MGV_PDOC' AND invdocno = crs_wa_out->invdocno.

    SELECT SINGLE dfkkop~opbel dfkkop~opupk dfkkop~opupw dfkkop~opupz
      FROM dfkkinvdoc_p
      INNER JOIN dfkkop ON dfkkop~opbel = dfkkinvdoc_p~opbel
       INTO (crs_wa_out->opbel, crs_wa_out->opupk ,crs_wa_out->opupw, crs_wa_out->opupz)
      WHERE invdocno = crs_wa_out->invdocno.

    SELECT SINGLE * FROM dfkkthi INTO @DATA(ls_wa_dfkkthi)
    WHERE opbel = @crs_wa_out->opbel
      AND opupk = @crs_wa_out->opupk
      AND opupw = @crs_wa_out->opupw.

    " könnte unnütz sein, leider nicht sicher
    MOVE-CORRESPONDING crs_wa_out->* TO ls_wa_dfkkthi.

    rt_table = VALUE #( ( ls_wa_dfkkthi ) ).
  ENDMETHOD.


  METHOD fill_msb_specific.
    SELECT SINGLE  * FROM dfkkinvdoc_h INTO @DATA(ls_dfkkinvdoc_h)
      WHERE /mosb/inv_doc_ident = @crs_wa_out->crossrefno.

    "CLEAR: ls_dfkkinvdoc_i, lt_dfkkinvdoc_i.
    SELECT * FROM dfkkinvdoc_i INTO TABLE @DATA(lt_dfkkinvdoc_i)
      WHERE invdocno = @ls_dfkkinvdoc_h-invdocno.

    crs_wa_out->mosb_lead_sup  = ls_dfkkinvdoc_h-/mosb/lead_sup.
    crs_wa_out->mosb_mo_sp     = ls_dfkkinvdoc_h-/mosb/mo_sp.
    crs_wa_out->vkont_msb      = ls_dfkkinvdoc_h-vkont.
    crs_wa_out->gpart          = ls_dfkkinvdoc_h-gpart.
    crs_wa_out->invdocno       = ls_dfkkinvdoc_h-invdocno.
    crs_wa_out->prlinv_status  = ls_dfkkinvdoc_h-prlinv_status.
    crs_wa_out->budat          = ls_dfkkinvdoc_h-budat.
    crs_wa_out->bldat          = ls_dfkkinvdoc_h-bldat.
    crs_wa_out->faedn          = ls_dfkkinvdoc_h-faedn.
    crs_wa_out->mosb_id        = ls_dfkkinvdoc_h-/mosb/id.
    " getrennte Hotspotbehandlung notwendig
    crs_wa_out->crossrefno_msb = crs_wa_out->crossrefno.

    LOOP AT lt_dfkkinvdoc_i INTO DATA(ls_dfkkinvdoc_i).
      " Zeile Abrechnungsposition MoSB
      IF ls_dfkkinvdoc_i-itemtype = 'YMOS'.
        crs_wa_out->spart     = ls_dfkkinvdoc_i-spart.
        crs_wa_out->opbel     = ls_dfkkinvdoc_i-opbel.
        crs_wa_out->srcdocno  = ls_dfkkinvdoc_i-srcdocno.
        crs_wa_out->betrw     = ls_dfkkinvdoc_i-betrw.
        crs_wa_out->date_from = ls_dfkkinvdoc_i-date_from.
        crs_wa_out->date_to   = ls_dfkkinvdoc_i-date_to.
        crs_wa_out->bukrs     = ls_dfkkinvdoc_i-bukrs.
      ENDIF.
    ENDLOOP.

    SELECT SINGLE * FROM dfkkinvbill_i INTO @DATA(ls_dfkkinvbill_i)
       WHERE billdocno = @ls_dfkkinvdoc_i-srcdocno.
    IF sy-subrc EQ 0.
      crs_wa_out->quantity = ( ls_dfkkinvbill_i-quantity_pdp + ls_dfkkinvbill_i-quantity_adp ).
      crs_wa_out->qty_unit = ls_dfkkinvbill_i-qty_unit.
    ELSE.
      CLEAR ls_dfkkinvbill_i.
    ENDIF.

    SELECT SINGLE * FROM dfkkinvbill_h INTO @DATA(ls_dfkkinvbill_h)
       WHERE billdocno = @ls_dfkkinvdoc_i-srcdocno.
    IF sy-subrc EQ 0 AND ls_dfkkinvbill_h-revreason IS NOT INITIAL.
      crs_wa_out->cancel_state = icon_storno.
    ENDIF.

    SELECT SINGLE * FROM dfkkinvbill_x INTO @DATA(ls_dfkkinvbill_x)
        WHERE refobjname = 'BILLPLAN'
        AND billdocno = @ls_dfkkinvdoc_i-srcdocno.
    IF sy-subrc = 0.
      crs_wa_out->billplanno = ls_dfkkinvbill_x-refobjvalue.
    ENDIF.

    SELECT SINGLE * FROM dfkkbix_bip_i INTO @DATA(ls_dfkkbix_bip_i)
       WHERE billplanno = @crs_wa_out->billplanno.
    IF sy-subrc EQ 0 AND ls_dfkkbix_bip_i-cancelled = 'X'.
      crs_wa_out->cancel_state_ap = icon_storno.
    ENDIF.

    crs_wa_out->vkont = crs_wa_out->aggvk.

  ENDMETHOD.


  METHOD fill_nn_specific.
    " echte Tabelle fuellen
    SELECT * FROM dfkkthi INTO TABLE @DATA(lt_wa_dfkkthi)
     WHERE crsrf = @iv_int_crossrefno
      AND  stidc = '' AND burel = 'X'.
    rt_table = lt_wa_dfkkthi.

    crs_wa_out->spartyp = get_divcat_for_doc( crs_wa_out->int_receiver ).
    IF crs_wa_out->spartyp = /idxgc/if_constants=>gc_divcat_elec. " Strom => Comdis und RemaDV2 und Lieferschein möglich
      TRY.
          " Referenz auf Comdis suchen
          DATA(ls_docref) = irt_tinv_inv_docref->*[ inbound_ref_type = 92 inbound_ref_no = 1 ].
          crs_wa_out->comdis = ls_docref-inbound_ref.
          SHIFT crs_wa_out->comdis LEFT DELETING LEADING '0'. " fuehrende Nullen entfernen

          " zweite Reklamation suchen
          ls_docref = irt_tinv_inv_docref->*[ inbound_ref_type = 93 inbound_ref_no = 1 ].
          crs_wa_out->remadv2 = ls_docref-inbound_ref.
          get_reklamations_info(
             EXPORTING  iv_remadv  = crs_wa_out->remadv2
             IMPORTING  ev_remdate = crs_wa_out->remdate2
                        ev_rstgr   = crs_wa_out->rstgr2  ).
        CATCH cx_sy_itab_line_not_found.
          TRY.
              " keine Comdis => wenn Referenz vorhanden, dann ist es die erste Reklamation
              ls_docref = irt_tinv_inv_docref->*[ inbound_ref_type = 93 inbound_ref_no = 1 ].
              crs_wa_out->remadv = ls_docref-inbound_ref.
              get_reklamations_info(
                 EXPORTING  iv_remadv  = crs_wa_out->remadv
                 IMPORTING  ev_remdate = crs_wa_out->remdate
                            ev_rstgr   = crs_wa_out->rstgr1  ).
            CATCH cx_sy_itab_line_not_found.
          ENDTRY.
      ENDTRY.
    ENDIF.

  ENDMETHOD.


  METHOD get_locks.
    CASE iv_pinvtyp.
      WHEN mco_nn OR mco_mgv.
* check dunning block for document
        DATA: ls_dfkkop TYPE dfkkop.
        DATA: ls_dfkkop_key TYPE dfkkop_key_s.
        DATA: lt_dfkklock TYPE STANDARD TABLE OF dfkklocks.
        DATA  x_lock_exist TYPE c.
        DATA  x_lock_depex TYPE c.

        CLEAR: x_lock_exist,
        x_lock_depex.

        CLEAR ls_dfkkop.
        CLEAR ls_dfkkop_key.
        IF irs_dfkkthi IS NOT INITIAL AND irs_dfkkthi->* IS NOT INITIAL.
          ls_dfkkop-gpart  = irs_dfkkthi->gpart.
          ls_dfkkop-vkont  = irs_dfkkthi->vkont.
          ls_dfkkop-opbel  = irs_dfkkthi->opbel.
          ls_dfkkop-opupw  = irs_dfkkthi->opupw.
          ls_dfkkop-opupk  = irs_dfkkthi->opupk.
          ls_dfkkop-opupz  = irs_dfkkthi->opupz.
          MOVE-CORRESPONDING ls_dfkkop TO ls_dfkkop_key.

          CALL FUNCTION 'FKK_S_LOCK_GET'
            EXPORTING
              i_keystructure           = ls_dfkkop
              i_lotyp                  = '02'
              i_proid                  = '01'
              i_lockdate               = sy-datum
              i_x_mass_access          = space
              i_x_dependant_locktypes  = space
            IMPORTING
              e_x_lock_exist           = x_lock_exist
              e_x_dependant_lock_exist = x_lock_depex
            TABLES
              et_locks                 = lt_dfkklock.
          cs_out-process_state = COND #( WHEN x_lock_exist = 'X' THEN icon_locked ELSE '' ).
        ENDIF.
        IF 1 < 0.  " only for debuggging
          DATA: lf_info(25).
          LOOP AT lt_dfkklock ASSIGNING FIELD-SYMBOL(<ls_dfkklock>) WHERE loobj1 = ls_dfkkop_key.
            "wa_out-mansp  = t_dfkklock-lockr.
            " lf_info = wa_out-mansp.
            lf_info+13(1) = '-'.
            WRITE <ls_dfkklock>-fdate TO lf_info+2(10) DD/MM/YYYY.
            WRITE <ls_dfkklock>-tdate TO lf_info+15(10) DD/MM/YYYY.
          ENDLOOP.
        ENDIF.

      WHEN  mco_memi. " XXX MEMI
        SELECT * FROM /adz/mem_mloc INTO TABLE @DATA(lt_mloc)
        WHERE doc_id = @cs_out-doc_id
          AND tdate GE @sy-datum
          AND lvorm = ''.

        SORT lt_mloc BY tdate ASCENDING.
        READ TABLE lt_mloc INTO DATA(ls_mloc) INDEX 1.
        IF sy-subrc = 0.
          cs_out-mahnsp = ls_mloc-lockr.          "Nuss 12.02.2018
          cs_out-fdate  = ls_mloc-fdate.          "Nuss 12.02.2018
          cs_out-tdate  = ls_mloc-tdate.          "Nuss 12.02.2018
          cs_out-process_state = COND #( WHEN ls_mloc-fdate LE sy-datum THEN icon_locked ELSE icon_led_yellow ).
        ENDIF.

    ENDCASE.
  ENDMETHOD.


  METHOD get_new_crossnr_flag.
    STATICS sb_sel_done TYPE abap_bool VALUE abap_false.
    STATICS sb_new_crossnr_flag TYPE abap_bool.
    IF sb_sel_done EQ abap_false.
      sb_sel_done = abap_true.
      SELECT SINGLE * FROM ederegswitchsyst INTO @DATA(ls_wa_ederegswitchsyst).
      IF sy-subrc EQ 0 AND ls_wa_ederegswitchsyst-xcrn = 'X'.
        sb_new_crossnr_flag = abap_true.
      ENDIF.
    ENDIF.
    rb_newcrossnr = sb_new_crossnr_flag.
  ENDMETHOD.


  METHOD get_read_text.
    STATICS sb_sel_done TYPE abap_bool VALUE abap_false.
    STATICS sb_entry_exists TYPE abap_bool.
    STATICS : BEGIN OF ss_last_search,
                sname    TYPE tdobname,
                readtext TYPE string,
              END OF ss_last_search.

    IF sb_sel_done EQ abap_false.
      sb_sel_done = abap_true.
      SELECT COUNT(*) FROM /adz/fi_remad WHERE negrem_option = 'FIELDCAT' AND negrem_field = 'NOTIZ' AND negrem_value = 'X'.
      IF sy-subrc EQ 0.
        sb_entry_exists = abap_true.
      ENDIF.
    ENDIF.
    IF sb_entry_exists = abap_true.
      DATA(lv_name) = CONV tdobname( |{ iv_int_inv_doc_no }_{ iv_int_inv_line_no }| ).
      IF ss_last_search-sname = lv_name.
        rv_read_text = ss_last_search-readtext.
      ELSE.
        DATA:  lt_lines  TYPE STANDARD TABLE OF tline.
        CALL FUNCTION 'READ_TEXT'
          EXPORTING
*           CLIENT                  = SY-MANDT
            id                      = mco_id
            language                = sy-langu
            name                    = lv_name
            object                  = mco_object
*           ARCHIVE_HANDLE          = 0
*           LOCAL_CAT               = ' '
*       IMPORTING
*           HEADER                  =
*           OLD_LINE_COUNTER        =
          TABLES
            lines                   = lt_lines
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
*     Implement suitable error handling here
        ENDIF.

        READ TABLE lt_lines INTO DATA(lv_help_line) INDEX 1.
        rv_read_text = COND #( WHEN sy-subrc EQ 0 THEN  lv_help_line ELSE '' ).
        ss_last_search-sname    = lv_name.
        ss_last_search-readtext = rv_read_text.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD get_text_vorhanden.
    STATICS sb_sel_done TYPE abap_bool VALUE abap_false.
    STATICS sb_entry_exists TYPE abap_bool.
    IF sb_sel_done EQ abap_false.
      sb_sel_done = abap_true.
      SELECT COUNT(*) FROM /adz/fi_remad
      WHERE negrem_option = 'FIELDCAT' AND negrem_field = 'BEMERKUNG' AND negrem_value = 'X'.
      IF sy-subrc EQ 0.
        sb_entry_exists = abap_true.
      ENDIF.
    ENDIF.
    IF sb_entry_exists = abap_true.
      SELECT COUNT(*) FROM /adz/remtext  WHERE int_inv_doc_nr = iv_int_inv_doc_no.
      IF sy-subrc = 0.
        rv_text_vorhanden = 'X'.
      ELSE.
        rv_text_vorhanden = ''.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD read_delvnote.

    SELECT * FROM /idxgl/engy_val
      WHERE int_ui = @int_ui
      AND datefrom = @date_from
      AND dateto = @date_to
      INTO TABLE @DATA(lt_lf).

    SORT lt_lf BY eamountdoc DESCENDING.

    READ TABLE lt_lf INTO lieferschein INDEX 1.

  ENDMETHOD.


  METHOD read_reklamon_data.
    DATA ls_tinv_db_data_mon  TYPE inv_db_data_mon.
    DATA ls_tinv_db_data_doc  TYPE inv_db_data_doc.
    DATA ls_wa_inv_head_doc   TYPE /adz/inv_s_inv_head_doc.
    DATA ls_wa_out            TYPE /adz/inv_s_out_reklamon.
    DATA ls_wa_inv_line_a     TYPE tinv_inv_line_a.
    DATA ls_wa_inv_line_b     TYPE tinv_inv_line_b.
    DATA ls_wa_noti           TYPE /idexge/rej_noti.
    DATA ls_wa_inv_c_adj_rsnt TYPE tinv_c_adj_rsnt.
    DATA ls_wa_ecrossrefno    TYPE ecrossrefno.
    DATA ls_wa_paym           TYPE /adz/inv_s_paym.
    DATA ls_wa_euitrans       TYPE euitrans.
    DATA lt_idxgc_pod_rel     TYPE  STANDARD TABLE OF /idxgc/pod_rel .
    DATA ls_wa_idxgc_pod_rel  TYPE  /idxgc/pod_rel.
    DATA ls_wa_euitrans_melo  TYPE  euitrans.
    DATA ls_wa_dfkkthi        TYPE dfkkthi.
    DATA ls_wa_dfkkop         TYPE dfkkop.
    DATA(lo_bc)  = NEW /adz/cl_inv_bc_contact( ).

    me->read_basic_data( is_sel_screen =  is_sel_screen ).
    CLEAR mt_out_reklamon_data.
    mv_inv_head_ctr = 0.
    LOOP AT mt_tinv_db_data_mon INTO ls_tinv_db_data_mon.
      CLEAR: ls_wa_inv_head_doc, ls_wa_out.
      MOVE-CORRESPONDING ls_tinv_db_data_mon-tinv_inv_head TO ls_wa_inv_head_doc.

      CHECK  ( is_sel_screen-p_invtp = mco_nn   AND ls_wa_inv_head_doc-invoice_type = '004' )
         OR  ( is_sel_screen-p_invtp = mco_memi AND ls_wa_inv_head_doc-invoice_type = '008' )
         OR  ( is_sel_screen-p_invtp = mco_mgv  AND ls_wa_inv_head_doc-invoice_type = '011' )
         OR  ( is_sel_screen-p_invtp = mco_msb  AND ls_wa_inv_head_doc-invoice_type = '013' ).

      "READ TABLE ls_tinv_db_data_mon-docs INTO ls_tinv_db_data_doc INDEX 1.
      LOOP AT ls_tinv_db_data_mon-docs INTO ls_tinv_db_data_doc.

        MOVE-CORRESPONDING ls_tinv_db_data_doc-tinv_inv_doc TO ls_wa_inv_head_doc.

        MOVE-CORRESPONDING ls_wa_inv_head_doc TO ls_wa_out.

*    CHECK ls_wa_inv_head-int_receiver IN s_rece.
*  SELECT h~int_inv_no      h~invoice_type
*         h~date_of_receipt h~invoice_status
*         h~int_receiver    h~int_sender
*         d~int_inv_doc_no  d~ext_invoice_no
*         d~doc_type        d~inv_doc_status
*         d~date_of_payment d~invoice_date
*    INTO CORRESPONDING FIELDS OF ls_wa_inv_head_doc
*    FROM tinv_inv_head AS h
*      INNER JOIN tinv_inv_doc AS d
*      ON h~int_inv_no EQ d~int_inv_no
*    WHERE h~int_sender IN s_send
*      AND h~invoice_type EQ co_invtype
        "  AND h~invoice_type EQ co_msbtype co_memi_type co_mgvtype
*      AND h~date_of_receipt IN s_dtrec
*      AND h~invoice_status IN s_insta
*      AND h~int_receiver IN s_rece
*      AND d~int_inv_doc_no IN s_intido
*      AND d~ext_invoice_no IN s_extido
*      AND d~doc_type IN s_doctyp
*      AND d~inv_doc_status IN s_idosta
*      AND d~date_of_payment IN s_dtpaym.
        mv_inv_head_ctr = mv_inv_head_ctr + 1.

        MOVE ls_wa_inv_head_doc-int_receiver     TO ls_wa_out-int_receiver.
        MOVE ls_wa_inv_head_doc-int_sender       TO ls_wa_out-int_sender.
        MOVE ls_wa_inv_head_doc-invoice_status   TO ls_wa_out-invoice_status.
        MOVE ls_wa_inv_head_doc-date_of_receipt  TO ls_wa_out-date_of_receipt.

** Aggr. Vertragskonto ermitteln
        DATA(lt_initiator) = VALUE ttinv_initiator( ( CONV #( ls_wa_out-int_sender ) ) ).
        DATA(lt_tvkont)    = VALUE tvkont_kk( (  ) ).
        CALL FUNCTION 'ISU_DEREG_GET_INITIATOR_VKONT'
          EXPORTING
            x_keydate      = sy-datum         " Datum und Zeit, aktuelles (Applikationsserver-)Datum
            x_tinitiator   = lt_initiator     " Tabelle von Initiatoren
          IMPORTING
            y_tvkont       = lt_tvkont        " Tabellentyp für vertragskonten
          EXCEPTIONS
            internal_error = 1                " interner Fehler
            not_found      = 2                " Kein Konto gefunden
            OTHERS         = 3.
        IF sy-subrc <> 0.
          "MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.
          "return.
        ENDIF.
        READ TABLE lt_tvkont INTO DATA(ls_tvkont) WITH KEY initiator = ls_wa_out-int_sender  partner = ls_wa_out-int_receiver.
        IF sy-subrc EQ 0.
          ls_wa_out-aggvk = ls_tvkont-vkont_aggbill.
        ENDIF.
        IF 1 < 0.
          " alte Ermittlung
          DATA(lt_r_vktyp) = get_range_of_vktyp_kk( ).
          SELECT SINGLE a~vkont INTO ls_wa_out-aggvk
            FROM fkkvk AS a
             INNER JOIN fkkvkp AS b
               ON b~vkont = a~vkont
            INNER JOIN eservprovp AS c
              ON c~bpart = b~gpart
              WHERE c~serviceid = ls_wa_out-int_sender
              AND a~vktyp IN lt_r_vktyp.
        ENDIF.

        MOVE ls_wa_inv_head_doc-int_inv_doc_no  TO ls_wa_out-int_inv_doc_no.
        MOVE ls_wa_inv_head_doc-ext_invoice_no  TO ls_wa_out-ext_invoice_no.
        MOVE ls_wa_inv_head_doc-doc_type        TO ls_wa_out-doc_type.
        MOVE ls_wa_inv_head_doc-inv_doc_status  TO ls_wa_out-inv_doc_status.
        MOVE ls_wa_inv_head_doc-date_of_payment TO ls_wa_out-date_of_payment.
        MOVE ls_wa_inv_head_doc-invoice_date    TO ls_wa_out-invoice_date.

* AVIS-Zeilen
        SELECT * FROM tinv_inv_line_a INTO TABLE @DATA(lt_wa_inv_line_a)
           WHERE int_inv_doc_no EQ @ls_wa_inv_head_doc-int_inv_doc_no
           AND   rstgr IN @is_sel_screen-s_rstgr
           AND   own_invoice_no IN @is_sel_screen-s_owninv.

        LOOP AT lt_wa_inv_line_a INTO ls_wa_inv_line_a
          WHERE rstgr IS NOT INITIAL
            AND own_invoice_no IS NOT INITIAL.

*   Nuss: 11.09.2012
*   Füllen der Ausgabedaten nochmals, wenn mehrere Zeilen im AVIS
          IF ls_wa_out-int_inv_doc_no IS INITIAL.
            MOVE ls_wa_inv_head_doc-int_receiver    TO ls_wa_out-int_receiver.
            MOVE ls_wa_inv_head_doc-int_sender      TO ls_wa_out-int_sender.
            MOVE ls_wa_inv_head_doc-invoice_status  TO ls_wa_out-invoice_status.
            MOVE ls_wa_inv_head_doc-date_of_receipt TO ls_wa_out-date_of_receipt.

            MOVE ls_wa_inv_head_doc-int_inv_doc_no  TO ls_wa_out-int_inv_doc_no.
            MOVE ls_wa_inv_head_doc-ext_invoice_no  TO ls_wa_out-ext_invoice_no.
            MOVE ls_wa_inv_head_doc-doc_type        TO ls_wa_out-doc_type.
            MOVE ls_wa_inv_head_doc-inv_doc_status  TO ls_wa_out-inv_doc_status.
            MOVE ls_wa_inv_head_doc-date_of_payment TO ls_wa_out-date_of_payment.
            MOVE ls_wa_inv_head_doc-invoice_date    TO ls_wa_out-invoice_date.
          ENDIF.
**  <-- Nuss 11.09.2012

* Text zum Rückstellungsgrund
          CLEAR ls_wa_inv_c_adj_rsnt.
          SELECT SINGLE * FROM tinv_c_adj_rsnt
             INTO ls_wa_inv_c_adj_rsnt
               WHERE rstgr = ls_wa_inv_line_a-rstgr
               AND spras = sy-langu.

* Langtext falls vorhanden
          CLEAR ls_wa_noti.
*        IF ls_wa_inv_line_a-rstgr = '28'.
          SELECT * FROM /idexge/rej_noti INTO ls_wa_noti
*        WHERE int_inv_doc_no = ls_wa_inv_doc-int_inv_doc_no.       "Nuss 08.2012
            WHERE int_inv_doc_no = ls_wa_inv_head_doc-int_inv_doc_no
            AND int_inv_line_no = ls_wa_inv_line_a-int_inv_line_no.   "Nuss 08.2012
            ls_wa_out-free_text5 = ls_wa_noti-free_text5.
            ls_wa_out-free_text4 = ls_wa_noti-free_text4.
            IF ls_wa_noti-stat_remk(3) = '@0V'.
              ls_wa_out-line_state = icon_okay.
            ENDIF.
            EXIT.
          ENDSELECT.
*        ENDIF.

*     ls_wa_OUT füllen
          ls_wa_out-int_inv_line_no = ls_wa_inv_line_a-int_inv_line_no.
          ls_wa_out-rstgr           = ls_wa_inv_line_a-rstgr.
          ls_wa_out-text            = ls_wa_inv_c_adj_rsnt-text.
          ls_wa_out-free_text1      = ls_wa_noti-free_text1.
          ls_wa_out-own_invoice_no  = ls_wa_inv_line_a-own_invoice_no.
          ls_wa_out-betrw_req       = ls_wa_inv_line_a-betrw_req.

*  Externer Zählpunkt
          CLEAR ls_wa_ecrossrefno.

          SELECT * FROM ecrossrefno INTO ls_wa_ecrossrefno
            WHERE crossrefno = ls_wa_inv_line_a-own_invoice_no(15)
            OR    crn_rev = ls_wa_inv_line_a-own_invoice_no(15).
            EXIT.
          ENDSELECT.

          SELECT SINGLE * FROM erch WHERE belnr = @ls_wa_ecrossrefno-belnr INTO @DATA(ls_erch).
          IF is_sel_screen-p_invtp = mco_nn.
            CALL METHOD me->read_delvnote
              EXPORTING
                int_ui       = ls_wa_ecrossrefno-int_ui
                date_from    = ls_erch-begabrpe
                date_to      = ls_erch-endabrpe
              RECEIVING
                lieferschein = DATA(ls_lieferschein).
            SELECT SINGLE docnum FROM edextaskidoc WHERE sent = '6' AND dextaskid = @ls_lieferschein-dlv_note_dextaskid
              INTO @ls_wa_out-ls_nummer.
            ls_wa_out-ls_moveindate = ls_lieferschein-cr_date.
            ls_wa_out-ls_status = ls_lieferschein-dlv_note_status.
            "            ls_wa_out-LS_STATUS_TEXT = ls_lieferschein-ch_date. " TODO Richtiger Text
            ls_wa_out-ls_status_date = ls_lieferschein-ch_date.
          ENDIF.


          IF is_sel_screen-p_invtp = mco_memi  " XXX MEMI
          OR is_sel_screen-p_invtp = mco_mgv   " XXX MGV
          OR is_sel_screen-p_invtp = mco_msb.  " XXX MSB
            MOVE-CORRESPONDING ls_wa_ecrossrefno TO ls_wa_out.
          ENDIF.

          SELECT SINGLE createdfrom
            INTO @DATA(lv_crfrom)
            FROM  /idexge/t_at_rem
            WHERE imp_avistype = 'R'
            AND   doc_type = @ls_wa_out-doc_type.
          SELECT  *
            FROM  tinv_inv_line_a
            WHERE int_inv_doc_no = @ls_wa_out-int_inv_doc_no
            AND   transf_relevant = 'X'
            INTO @DATA(ls_tinv_lina_a_org).

            SELECT h~invoice_status
              INTO  ls_wa_paym-invoice_status
              FROM  tinv_inv_line_a AS a
              INNER JOIN tinv_inv_doc AS d
              ON  d~int_inv_doc_no = a~int_inv_doc_no
              INNER JOIN tinv_inv_head AS h
              ON  h~int_inv_no = d~int_inv_no
              INNER JOIN /idexge/t_at_rem AS s
              ON  s~doc_type = d~doc_type
              WHERE a~own_invoice_no = ls_wa_out-own_invoice_no
              AND   s~imp_avistype = 'C'
              AND   s~createdfrom = lv_crfrom.
            ENDSELECT.
          ENDSELECT.


          IF sy-subrc = 0.
            ls_wa_out-paym_stat = ls_wa_paym-invoice_status.
          ENDIF.

          DATA: lb_storno TYPE boolean.
          lb_storno = abap_false.
          CLEAR ls_wa_out-inf_invoice_cancel.

          IF is_sel_screen-p_invtp <> mco_nn.
            DATA(lv_crn) = COND crossrefno(
               WHEN is_sel_screen-p_invtp = mco_memi THEN ls_wa_ecrossrefno-crossrefno
               WHEN is_sel_screen-p_invtp = mco_mgv  THEN ls_wa_ecrossrefno-crn_rev
               WHEN is_sel_screen-p_invtp = mco_msb  THEN ls_wa_ecrossrefno-crn_rev ).
            IF lv_crn EQ ls_wa_inv_line_a-own_invoice_no.
              ls_wa_out-inf_invoice_cancel = icon_storno.
              lb_storno = abap_true.
            ENDIF.
          ENDIF.

          CLEAR ls_wa_euitrans.
          SELECT SINGLE * FROM euitrans INTO ls_wa_euitrans
             WHERE int_ui = ls_wa_ecrossrefno-int_ui
             AND dateto = '99991231'.

*      CHECK ls_wa_euitrans-ext_ui IN s_extui.                 "Nuss 10.2017  Melo/Malo

          MOVE ls_wa_euitrans-ext_ui TO ls_wa_out-ext_ui.

**    --> Nuss 10.2017  Melo/Malo
          CLEAR: lt_idxgc_pod_rel, ls_wa_idxgc_pod_rel.
          IF ls_wa_euitrans-uistrutyp = 'MA'.
            SELECT * FROM /idxgc/pod_rel INTO TABLE lt_idxgc_pod_rel
              WHERE int_ui2 = ls_wa_ecrossrefno-int_ui.
          ENDIF.
          IF sy-subrc = 0.
            DATA(lv_podlines) = lines( lt_idxgc_pod_rel ).
            READ TABLE lt_idxgc_pod_rel INTO ls_wa_idxgc_pod_rel INDEX 1.
            CLEAR ls_wa_euitrans_melo.
            SELECT SINGLE * FROM euitrans INTO ls_wa_euitrans_melo
               WHERE int_ui = ls_wa_idxgc_pod_rel-int_ui1
               AND dateto = '99991231'.
            MOVE ls_wa_euitrans_melo-ext_ui TO ls_wa_out-ext_ui_melo.
            IF lv_podlines GT 1.
              MOVE 'X' TO ls_wa_out-mult_melo.
            ENDIF.
          ENDIF.
**  <-- Nuss 10.2017 Melo/Malo



* Abrechnungsklasse ermitteln
          SELECT aklasse a~anlage a~tariftyp INTO (ls_wa_out-aklasse, ls_wa_out-anlage, ls_wa_out-tariftyp)
            FROM eanlh AS a
              INNER JOIN euiinstln AS b
              ON b~anlage = a~anlage
              INNER JOIN euitrans AS c
               ON c~int_ui = b~int_ui
            WHERE c~ext_ui = ls_wa_out-ext_ui
              AND c~dateto = '99991231'
              AND a~bis = '99991231'.
            EXIT.
          ENDSELECT.
*     DFKKTHI lesen
*     Nur Status "IDOC gebucht"

          "--------------------------------------------------------------------------------
          " spezifischer Teil : Groessere Verarbeitungsunterschiede abhaengig von p_invtp
          "--------------------------------------------------------------------------------
          DATA(lt_tmp_one_row) = VALUE string_table( ( |one_row_for_loop| ) ).
          FIELD-SYMBOLS <lt_tmp> TYPE STANDARD TABLE.
          ASSIGN lt_tmp_one_row TO <lt_tmp>.
          DATA(lr_wa_out) = REF #( ls_wa_out ).

          IF is_sel_screen-p_invtp = mco_nn. " XXX NN --------------------------------------------
            DATA(lt_nn_tab) = fill_nn_specific(
              EXPORTING
                iv_int_crossrefno   = ls_wa_ecrossrefno-int_crossrefno
                irt_tinv_inv_docref = REF #( ls_tinv_db_data_doc-ttinv_inv_docref )
              CHANGING
                crs_wa_out          = lr_wa_out ).
            ASSIGN lt_nn_tab TO <lt_tmp>.

          ELSEIF is_sel_screen-p_invtp = mco_memi. " XXX MEMI ------------------------------------
            " pseudo Tabelle fuellen
            SELECT SINGLE  * FROM /idxmm/memidoc INTO CORRESPONDING FIELDS OF  ls_wa_out
                WHERE crossrefno = ls_wa_out-crossrefno.
            SELECT SINGLE opbel FROM erchc  INTO ls_wa_out-erchcopbel
                WHERE belnr = ls_wa_out-trig_bill_doc_no.
            ls_wa_out-billable_item = ls_wa_out-doc_id.
            ls_wa_out-vkont  = ls_wa_out-aggvk.

          ELSEIF is_sel_screen-p_invtp = mco_mgv. " XXX MGV  --------------------------------------
            DATA(lt_mgv_tab) = fill_mgv_specific( lr_wa_out  ).
            ASSIGN lt_mgv_tab TO <lt_tmp>.

          ELSEIF is_sel_screen-p_invtp = mco_msb. " XXX MSB  --------------------------------------
            fill_msb_specific( lr_wa_out ).
          ENDIF.

          IF <lt_tmp> IS NOT ASSIGNED.
            CONTINUE.
          ENDIF.

          LOOP AT <lt_tmp> ASSIGNING FIELD-SYMBOL(<ls_tmp>).
            IF is_sel_screen-p_invtp = mco_nn.
              ls_wa_dfkkthi =  <ls_tmp>.
              CHECK ls_wa_dfkkthi-crsrf IS NOT INITIAL.
*          check ls_wa_dfkkthi-thist = '4'.  "Nicht mehr benötigt, da auch andere Fälle möglich sind
              IF is_sel_screen-p_storno = 'X'.
                CHECK ls_wa_dfkkthi-storn NE 'X'.
                CHECK ls_wa_dfkkthi-stidc NE 'X'.

              ELSE.
                IF ls_wa_dfkkthi-storn = 'X'.
                  ls_wa_out-inf_invoice_cancel = icon_storno.
                  lb_storno = abap_true.
                ENDIF.
                IF lb_storno EQ abap_true.
                  CHECK ls_wa_dfkkthi-storn EQ 'X'.
                ELSEIF lb_storno = abap_false.
                  CHECK ls_wa_dfkkthi-storn NE 'X'.
                ENDIF.
              ENDIF.
              MOVE-CORRESPONDING ls_wa_dfkkthi TO ls_wa_out.
              SELECT SINGLE * FROM dfkkop INTO ls_wa_dfkkop
                WHERE opbel = ls_wa_dfkkthi-opbel
                  AND opupw = ls_wa_dfkkthi-opupw
                  AND opupk = ls_wa_dfkkthi-opupk
                  AND opupz = ls_wa_dfkkthi-opupz.

              MOVE ls_wa_dfkkop-xblnr TO ls_wa_out-xblnr.
            ELSEIF is_sel_screen-p_invtp = mco_memi. " XXX MEMI
              " nothing special
            ELSEIF is_sel_screen-p_invtp = mco_mgv.
              ls_wa_dfkkthi =  <ls_tmp>.
            ENDIF.


            "ENDIF.
            IF ( is_sel_screen-p_invtp = mco_nn
            OR   is_sel_screen-p_invtp = mco_memi
            OR   is_sel_screen-p_invtp = mco_msb ).
              ls_wa_out-text_vorhanden = get_text_vorhanden( ls_wa_out-int_inv_doc_no ).
              ls_wa_out-free_text5 = get_read_text( iv_int_inv_doc_no  = ls_wa_out-int_inv_doc_no
                                                    iv_int_inv_line_no = ls_wa_out-int_inv_line_no ).
              sel_invstorno(
                EXPORTING   iv_pinvtyp        = is_sel_screen-p_invtp
                CHANGING    cs_out            = ls_wa_out
              ).

            ENDIF.

            IF ( is_sel_screen-p_invtp <> mco_msb ).
              get_locks(
                EXPORTING iv_pinvtyp  = is_sel_screen-p_invtp
                          irs_dfkkthi = REF #( ls_wa_dfkkthi )
                CHANGING  cs_out            = ls_wa_out ) .
            ENDIF.

            "---- contact for comm_state
            DATA(lv_gpart) = COND #( WHEN is_sel_screen-p_invtp EQ mco_memi
                                     THEN ls_wa_out-suppl_bupa ELSE ls_wa_out-gpart  ).
            IF ( lo_bc->check_for_contact( EXPORTING
                    iv_gpart          = lv_gpart
                    iv_int_inv_doc_no = ls_wa_out-int_inv_doc_no ) EQ abap_true ).
              ls_wa_out-comm_state = icon_envelope_closed.
            ENDIF.

            IF ls_wa_out-int_inv_doc_no IS NOT INITIAL  OR is_sel_screen-p_invtp <> mco_nn.
              APPEND ls_wa_out TO mt_out_reklamon_data.
            ENDIF.
            CLEAR ls_wa_out.

          ENDLOOP.
          UNASSIGN <lt_tmp>.
        ENDLOOP. "tinv_inv_line_a
      ENDLOOP. "docs
    ENDLOOP. " basic structure

  ENDMETHOD.


  METHOD sel_invstorno.
    DATA: ls_wa_erdk TYPE erdk,
          lv_opbel   TYPE erdk-opbel.

    IF iv_pinvtyp = mco_nn.  " XXX NN
      lv_opbel = COND #( WHEN get_new_crossnr_flag(  ) = abap_true
                         THEN cs_out-own_invoice_no+3 ELSE cs_out-own_invoice_no ).
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = lv_opbel
        IMPORTING
          output = lv_opbel.
    ELSEIF iv_pinvtyp = mco_memi  " XXX MEMI
    OR     iv_pinvtyp = mco_msb.
      lv_opbel = cs_out-erchcopbel.
    ENDIF.

*   Belegkopf selektieren
    SELECT SINGLE * FROM erdk INTO ls_wa_erdk
      WHERE erdk~opbel EQ lv_opbel.
    IF ls_wa_erdk-stokz IS NOT INITIAL.
      cs_out-inf_invoice_cancel = icon_storno.
    ENDIF.

    IF iv_pinvtyp = mco_nn.  " XXX NN
      IF ls_wa_erdk-abrvorg EQ '06'.                        "manuelle Abrechnung
        cs_out-zisumabr = 'X'.
      ENDIF.
    ELSEIF iv_pinvtyp = mco_memi.  " XXX MEMI
      SELECT COUNT(*) FROM /idxmm/memidoc WHERE doc_id = cs_out-doc_id AND reversal = 'X'.
      IF sy-subrc = 0.
        cs_out-cancel_state_mm = icon_storno.
      ENDIF.
    ENDIF.


  ENDMETHOD.
ENDCLASS.
