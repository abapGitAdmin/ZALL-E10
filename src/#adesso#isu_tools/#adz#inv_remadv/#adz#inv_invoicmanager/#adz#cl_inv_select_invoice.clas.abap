CLASS /adz/cl_inv_select_invoice DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC INHERITING FROM /adz/cl_inv_select_basic.

  PUBLIC SECTION.
    DATA mt_out_invoice_data   TYPE /adz/inv_t_out_reklamon.
    METHODS  :
      read_invman_data  IMPORTING is_sel_screen TYPE /adz/inv_s_sel_screen.
    .
  PROTECTED SECTION.

  PRIVATE SECTION.

ENDCLASS.



CLASS /ADZ/CL_INV_SELECT_INVOICE IMPLEMENTATION.


  METHOD read_invman_data.
    DATA ls_tinv_db_data_mon TYPE inv_db_data_mon.
    DATA ls_tinv_db_data_doc TYPE inv_db_data_doc.
    DATA ls_wa_inv_head_doc  TYPE /adz/inv_s_inv_head_doc.
    DATA ls_wa_out           TYPE /adz/inv_s_out_reklamon.
    DATA lv_anl_ok           TYPE char1.
    DATA anz_fehler          TYPE i.
    DATA lt_fehler           TYPE /adz/inv_t_fehler.
    DATA ls_fehler           TYPE /adz/inv_s_fehler.
    DATA ls_wa_inv_extid     TYPE tinv_inv_extid.
    DATA ls_wa_inv_line_b    TYPE tinv_inv_line_b.
    DATA ls_wa_t100          TYPE t100.
    DATA ls_wa_inv_doc_a     TYPE tinv_inv_doc.
    DATA ls_wa_inv_c_adj_rsnt TYPE tinv_c_adj_rsnt.
    DATA ls_wa_euitrans      TYPE euitrans.
    DATA ls_wa_euiinstln     TYPE euiinstln.
    DATA ls_wa_eanlh         TYPE eanlh.
    DATA ls_wa_mema_map      TYPE zisu_mema_map.
    DATA ls_docref           TYPE tinv_inv_docref .
    DATA lt_adz_rektexte     TYPE HASHED TABLE OF /adz/rektexte WITH UNIQUE KEY msgnr.
    DATA lt_adz_invtext      TYPE SORTED TABLE OF /adz/invtext  WITH NON-UNIQUE KEY int_inv_doc_nr.

    " Hasttabelle aufbauen
    SELECT * FROM /adz/rektexte INTO TABLE lt_adz_rektexte.
    SELECT * FROM /adz/invtext  INTO TABLE lt_adz_invtext.

    CLEAR mt_out_invoice_data.
    me->read_basic_data( is_sel_screen =  is_sel_screen ).
    LOOP AT mt_tinv_db_data_mon INTO ls_tinv_db_data_mon.
      CLEAR: ls_wa_inv_head_doc, ls_wa_out.
      MOVE-CORRESPONDING ls_tinv_db_data_mon-tinv_inv_head TO ls_wa_inv_head_doc.
      READ TABLE ls_tinv_db_data_mon-docs INTO ls_tinv_db_data_doc INDEX 1.
      MOVE-CORRESPONDING ls_tinv_db_data_doc-tinv_inv_doc TO ls_wa_inv_head_doc.
      MOVE-CORRESPONDING ls_wa_inv_head_doc TO ls_wa_out.
*    ls_tinv_db_data_mon-docs
*    MOVE-CORRESPONDING ls_tinv_db_data_mon-docs- TO ls_wa_inv_head_doc.

      CASE ls_wa_inv_head_doc-invoice_status.
        WHEN '01'.
          ls_wa_out-lights = '0'.
        WHEN '02'.
          ls_wa_out-lights = '2'.
        WHEN '03'.
          ls_wa_out-lights = '3'.
        WHEN OTHERS.
          ls_wa_out-lights = '0'.
      ENDCASE .

      SELECT COUNT(*) FROM /adz/invsperr WHERE int_inv_doc_nr = ls_wa_inv_head_doc-int_inv_doc_no.
      IF sy-subrc = 0.
        ls_wa_out-locked = '@06@'.
      ELSE.
        ls_wa_out-locked = ''.
      ENDIF.

      IF ls_wa_inv_head_doc-invoice_status = '02'.
        DATA ls_wait TYPE /adz/inv_wait.
        SELECT SINGLE * FROM /adz/inv_wait INTO ls_wait WHERE int_inv_no = ls_wa_inv_head_doc-int_inv_no
          AND to_date >= sy-datum.
        IF sy-subrc = 0.
          IF ls_wait-overdue = ''.
            ls_wa_out-waiting = '@9R@'.
            WRITE ls_wait-to_date TO ls_wa_out-waiting_to DD/MM/YYYY.
          ELSE.
            ls_wa_out-waiting = '@HC@'.
            WRITE ls_wait-to_date TO ls_wa_out-waiting_to DD/MM/YYYY.
          ENDIF.
        ELSE.
*      ls_wa_out-waiting = '@HC@'.
*      ls_wa_out-waiting_to = ls_wait-to_date.
        ENDIF.
      ENDIF.

      DATA ls_inv_msc TYPE /adz/inv_msc.
      SELECT SINGLE * FROM /adz/inv_msc INTO ls_inv_msc WHERE int_inv_no = ls_wa_out-int_inv_doc_no.
      ls_wa_out-msc_end = ls_inv_msc-msc_end.
      ls_wa_out-msc_start = ls_inv_msc-msc_start.

      IF is_sel_screen-p_sperr = 'X'.
        CHECK ls_wa_out-locked = '@06@'.
      ENDIF.
*      DATA: lv_reklambelnr(3)  TYPE c VALUE '04',
*            lv_reklamdoctyp(3) TYPE c VALUE '008',
*            lv_paybelart(3)    TYPE c,
*            lv_paydoctyp(3)    TYPE c.
*
*
*      SELECT SINGLE value FROM /adz/inv_cust INTO lv_reklambelnr   WHERE report = 'GLOBAL' AND field = 'REKLAMBELART'.
*      SELECT SINGLE value FROM /adz/inv_cust INTO lv_reklamdoctyp  WHERE report = 'GLOBAL' AND field = 'REKLAMDOCTYP'.
*      SELECT SINGLE value FROM /adz/inv_cust INTO lv_paybelart     WHERE report = 'GLOBAL' AND field = 'PAYBELART'.
*      SELECT SINGLE value FROM /adz/inv_cust INTO lv_paydoctyp     WHERE report = 'GLOBAL' AND field = 'PAYDOCTYP'.


* ´  Langtext falls vorhanden
      SELECT SINGLE free_text1 FROM /idexge/rej_noti INTO ls_wa_out-free_text1
        WHERE int_inv_doc_no = ls_wa_inv_head_doc-int_inv_doc_no
          AND free_text1  IN is_sel_screen-s_freetx.

      " Reklamation1
      TRY.
          ls_wa_out-remadv = ls_tinv_db_data_doc-ttinv_inv_docref[ inbound_ref_type = 15 inbound_ref_no = 1 ]-inbound_ref.
          get_reklamations_info(
             EXPORTING  iv_remadv  = ls_wa_out-remadv
             IMPORTING  ev_remdate = ls_wa_out-remdate
                        ev_rstgr   = ls_wa_out-rstgr  ).
*        CHECK wa_inv_line_a-rstgr IS NOT INITIAL.
*      CHECK wa_inv_line_a-rstgr IN s_rstgr.
          CHECK ls_wa_out-free_text1 IN is_sel_screen-s_freetx.
          CHECK ls_wa_out-rstgr IN is_sel_screen-s_rstgr.
        CATCH cx_sy_itab_line_not_found.
          " no ttinv_inv_docref.
      ENDTRY.


      TRY.
          ls_wa_out-remadv  = ls_tinv_db_data_doc-ttinv_inv_docref[ inbound_ref_type = 10 ]-int_inv_doc_no.
          "MOVE wa_inv_line_a-rstgr          TO ls_wa_out-rstgr.
          MOVE 'Zahlungsavis (ausgehend)'  TO ls_wa_out-free_text1.
        CATCH cx_sy_itab_line_not_found.
          " no remadv found in ttinv_inv_docref.
      ENDTRY.

      " ----- COMDIS
      TRY.
          ls_wa_out-comdis =  ls_tinv_db_data_doc-ttinv_inv_docref[ inbound_ref_type = 92 ]-inbound_ref.
          SHIFT ls_wa_out-comdis LEFT DELETING LEADING '0'. " fuehrende Nullen entfernen
        CATCH cx_sy_itab_line_not_found.
      ENDTRY.

      " Reklamation2
      TRY.
          ls_wa_out-remadv2 = ls_tinv_db_data_doc-ttinv_inv_docref[ inbound_ref_type = 15 inbound_ref_no = 2 ]-inbound_ref.
          get_reklamations_info(
             EXPORTING  iv_remadv  = ls_wa_out-remadv2
             IMPORTING  ev_remdate = ls_wa_out-remdate2
                        ev_rstgr   = ls_wa_out-rstgr2  ).
        CATCH cx_sy_itab_line_not_found.
          " no remadv2 found in ttinv_inv_docref.
      ENDTRY.

      " PdocRef
      IF ls_wa_out-invoice_type EQ '006' OR ls_wa_out-invoice_type EQ '007'.
        DATA ls_docrefno_max TYPE tinv_inv_docref.
        CLEAR ls_docrefno_max.
        LOOP AT  ls_tinv_db_data_doc-ttinv_inv_docref INTO ls_docref WHERE inbound_ref_type = 23.
          IF ls_docrefno_max IS INITIAL  OR ls_docrefno_max-inbound_ref_no < ls_docref-inbound_ref_no.
            ls_docrefno_max = ls_docref.
          ENDIF.
        ENDLOOP.
        IF ls_docrefno_max IS NOT INITIAL.
          ls_wa_out-pdoc_ref = ls_docrefno_max-inbound_ref.
          SHIFT ls_wa_out-pdoc_ref LEFT DELETING LEADING '0'. " fuehrende Nullen entfernen
        ENDIF.
      ENDIF.

      " Lieferschein Nr
      IF ls_wa_out-invoice_type = '001'. " Lierschein nur bei NN fuellen
        ls_wa_out-ls_nummer = ls_tinv_db_data_doc-tinv_inv_doc-/idexge/rff_ace.
        get_lieferschein_info(  crs_wa_out =  REF #( ls_wa_out )  ).
      ENDIF.
      IF is_sel_screen-s_lstatx IS NOT INITIAL.
        IF ls_wa_out-ls_status_text NOT IN is_sel_screen-s_lstatx.
          CONTINUE.
        ENDIF.
      ENDIF.

* Rechnungsbeleg: Externe Identifikationsmerkmale
      SELECT SINGLE * FROM tinv_inv_extid INTO ls_wa_inv_extid
        WHERE int_inv_doc_no = ls_wa_inv_head_doc-int_inv_doc_no
        AND ext_ident IN is_sel_screen-s_zpkt AND ext_ident_type = '01' .

      IF sy-subrc = 0.
        MOVE-CORRESPONDING ls_wa_inv_extid TO  ls_wa_out.
*    if s_a
* Selektion der Anlagen nach Tariftyp, Abrechnungsklasse und Ableseeinheit
        CLEAR: ls_wa_euitrans, ls_wa_euitrans, ls_wa_eanlh.
        CLEAR lv_anl_ok.
        SELECT * FROM euitrans INTO ls_wa_euitrans WHERE
          ext_ui = ls_wa_inv_extid-ext_ident AND
          ( uistrutyp = 'MA' OR                               "Nuss 11.2017 MaLo/MeLo
             uistrutyp = '02' ) AND                                 "Nuss 11.2017 MaLo/MeLo
          dateto GE sy-datum AND
          datefrom LE sy-datum.

          SELECT * FROM euiinstln INTO ls_wa_euiinstln WHERE
            int_ui = ls_wa_euitrans-int_ui AND
            dateto GE sy-datum AND
            datefrom LE sy-datum.

            SELECT * FROM eanlh INTO ls_wa_eanlh WHERE
                 anlage = ls_wa_euiinstln-anlage AND
                 aklasse IN is_sel_screen-s_abrkl AND
                 tariftyp IN is_sel_screen-s_tatyp AND
                 ableinh IN is_sel_screen-s_ablei
                  AND ableinh <> '99999999'
                  AND bis >= sy-datum .

              lv_anl_ok = 'X'.
              EXIT.
            ENDSELECT.
          ENDSELECT.
        ENDSELECT.

**    --> Nuss 11,2017 MaLo/Melo
        IF lv_anl_ok IS INITIAL.
          CLEAR ls_wa_mema_map.
          SELECT * FROM zisu_mema_map INTO ls_wa_mema_map
            WHERE ext_ui = ls_wa_inv_extid-ext_ident.
            MOVE ls_wa_mema_map-malo_id TO ls_wa_out-ext_ident.
            EXIT.
          ENDSELECT.

          SELECT * FROM euitrans INTO ls_wa_euitrans WHERE
           ext_ui = ls_wa_mema_map-malo_id AND
                       uistrutyp = 'MA' AND
           dateto GE sy-datum AND
           datefrom LE sy-datum.

            SELECT * FROM euiinstln INTO ls_wa_euiinstln WHERE
              int_ui = ls_wa_euitrans-int_ui AND
              dateto GE sy-datum AND
              datefrom LE sy-datum.

              SELECT * FROM eanlh INTO ls_wa_eanlh WHERE
                   anlage = ls_wa_euiinstln-anlage AND
                   aklasse IN is_sel_screen-s_abrkl AND
                   tariftyp IN is_sel_screen-s_tatyp AND
                   ableinh IN is_sel_screen-s_ablei
                    AND ableinh <> '99999999'
                    AND bis >= sy-datum .

                lv_anl_ok = 'X'.
                EXIT.
              ENDSELECT.
              EXIT.
            ENDSELECT.
            EXIT.
          ENDSELECT.
        ENDIF.
*  <-- Nuss 11.2017 MaLo/MeLo


        IF lv_anl_ok = 'X'.
          MOVE-CORRESPONDING ls_wa_eanlh TO ls_wa_out.
        ENDIF.
      ENDIF.

      SELECT SINGLE vorschlag FROM /adz/rek_vors INTO ls_wa_out-rstvs WHERE inv_doc_no = ls_wa_inv_head_doc-int_inv_doc_no.
      IF sy-subrc = 0.
        TRY.
            ls_wa_out-rstvs_text = lt_adz_rektexte[ msgnr = ls_wa_out-rstvs ]-text.
          CATCH cx_sy_itab_line_not_found.
        ENDTRY.
      ENDIF.
      IF is_sel_screen-s_rstv IS NOT INITIAL.
        CHECK ls_wa_out-rstvs IN is_sel_screen-s_rstv.
      ENDIF.

      "Rechnungszeile mit Buchungsinformationen
      SELECT SINGLE * FROM tinv_inv_line_b INTO ls_wa_inv_line_b
        WHERE int_inv_doc_no EQ ls_wa_inv_head_doc-int_inv_doc_no
          AND ( line_type EQ '0005' OR
                line_type EQ '0013' ).


      SELECT SUM( quantity ) FROM tinv_inv_line_b INTO ls_wa_inv_line_b-quantity
        WHERE product_id = '9990001000269' AND int_inv_doc_no = ls_wa_inv_head_doc-int_inv_doc_no.

*      Fehlertext ermitteln
      CLEAR lt_fehler.
*       Beendete bzw. Prozessierte keine Fehlerausgabe
      IF ls_wa_inv_head_doc-invoice_status = '03' OR
         ls_wa_inv_head_doc-inv_doc_status = '13'.
**         Do Nothing
      ELSE.
        get_errormessage(
          EXPORTING iv_inv_no = ls_wa_inv_head_doc-int_inv_doc_no
          CHANGING  ct_fehler = lt_fehler ).
      ENDIF.

**      Mehrfacheinträge aus der Fehlertabelle löscben
      IF lt_fehler IS NOT INITIAL.
        SORT lt_fehler.
        DELETE ADJACENT DUPLICATES FROM lt_fehler COMPARING ALL FIELDS.
      ENDIF.

      IF lt_fehler IS NOT INITIAL.
        ls_wa_out-lights = '1'.
      ENDIF.
      MOVE-CORRESPONDING ls_wa_inv_line_b  TO ls_wa_out.
*       Fehlermeldungen ausgeben
*      IF p_err = 'X'.
      ls_wa_out-invoice_status_t = get_domain_text( iv_domtabname = 'INV_DOC_STATUS'
                                                    iv_value      = CONV #( ls_wa_inv_head_doc-inv_doc_status ) ).


      ls_wa_out-stornobelnr = ls_wa_inv_head_doc-inv_cancel_doc.

      SELECT COUNT( * ) FROM tinv_inv_line_b WHERE int_inv_doc_no = ls_wa_out-int_inv_doc_no AND product_id = '9990001000574'.
      IF sy-subrc = 0.
        ls_wa_out-memi = 'X'.
      ENDIF.
      DATA ls_proc TYPE tinv_inv_docproc.
      SORT ls_tinv_db_data_doc-ttinv_inv_docproc BY process_run_no DESCENDING.
      READ TABLE ls_tinv_db_data_doc-ttinv_inv_docproc INTO ls_proc INDEX 1.
      ls_wa_out-process = ls_proc-process.
      ls_wa_out-belegart = ls_tinv_db_data_doc-tinv_inv_doc-/idexge/imd_doc_type.

      SELECT SINGLE vertrag, vkonto
        FROM ever
        INTO CORRESPONDING FIELDS OF @ls_wa_out
        WHERE anlage = @ls_wa_out-anlage
        AND einzdat <= @ls_wa_out-invperiod_start
        AND auszdat > @ls_wa_out-invperiod_end.

      IF lt_fehler IS NOT INITIAL.

        DESCRIBE TABLE lt_fehler LINES anz_fehler.
        IF anz_fehler GT 1.
          ls_wa_out-multi_err = 'X'.
        ENDIF.

*          LOOP AT lt_fehler INTO wa_fehler.
        READ TABLE lt_fehler INTO ls_fehler INDEX 1.
        SELECT * FROM t100 INTO ls_wa_t100
          WHERE sprsl = 'D'
            AND arbgb = ls_fehler-msgid
            AND msgnr = ls_fehler-msgno.
          ls_wa_out-fehler = ls_wa_t100-text.
          REPLACE ALL OCCURRENCES OF '&1' IN ls_wa_out-fehler WITH ls_fehler-msgv1.
          REPLACE ALL OCCURRENCES OF '&2' IN ls_wa_out-fehler WITH ls_fehler-msgv2.
          REPLACE ALL OCCURRENCES OF '&3' IN ls_wa_out-fehler WITH ls_fehler-msgv3.
          REPLACE ALL OCCURRENCES OF '&4' IN ls_wa_out-fehler WITH ls_fehler-msgv4.
          ls_wa_out-lights = '1'.
        ENDSELECT.
      ENDIF.

      " Fall nr, Klärungstext
      DATA(lv_pdoc_ref) = COND num20( WHEN ls_wa_out-invoice_type = '001' THEN ls_wa_out-ls_pdoc_ref
                                 ELSE ls_wa_out-pdoc_ref ).
      IF lv_pdoc_ref IS NOT INITIAL.
        DATA lt_bpem_cases TYPE TABLE OF emma_case.
        SELECT *  FROM emma_case  INTO TABLE lt_bpem_cases
         WHERE ( mainobjtype = if_isu_ide_switch_constants=>co_object_type OR
                 mainobjtype = /idxgc/if_constants=>gc_object_pdoc_bor )
          AND   mainobjkey  = lv_pdoc_ref.
        IF lt_bpem_cases IS NOT INITIAL.
          DATA(ls_case) = lt_bpem_cases[ lines(  lt_bpem_cases ) ].
          "  1   Neu     2   In Bearbeitung  3   Abgeschlossen   4   Storniert   6   Quittiert
          IF ls_case-status = '1' OR ls_case-status = '2'.
            ls_wa_out-casenr  = ls_case-casenr.
            ls_wa_out-casetxt = ls_case-casetxt.
          ENDIF.
        ENDIF.
        " Sap Standard
*      CALL METHOD /idxgc/cl_process_document_db=>/idxgc/if_process_document_db~select_exceptions
*        EXPORTING
*          iv_process_ref = lv_pdoc_ref
*        IMPORTING
*          et_bpem_cases  = DATA(lt_emma_case).
        " von Peter Nuss
*      SELECT SINGLE casenr FROM /adz/inv_case INTO ls_wa_out-casenr WHERE int_inv_no = ls_wa_out-int_inv_doc_no.
*      IF sy-subrc = 0.
*        SELECT SINGLE casetxt FROM emma_case INTO ls_wa_out-casetxt WHERE casenr = ls_wa_out-casenr.
*      ENDIF.
      ELSE.
        ls_wa_out-casenr  = ''.
        ls_wa_out-casetxt = ''.
      ENDIF.
*      SELECT COUNT( * ) FROM /adz/inv_case WHERE int_inv_no = ls_wa_out-int_inv_doc_no AND workitem <> ''.
*      IF sy-subrc = 0.
*        ls_wa_out-workitem = 'X'.
*      ENDIF.
      DATA lt_invtext TYPE STANDARD TABLE OF /adz/invtext.
      lt_invtext = VALUE #( FOR lst IN lt_adz_invtext WHERE ( int_inv_doc_nr = ls_wa_out-int_inv_doc_no ) ( lst ) ).
      SORT lt_invtext BY datum DESCENDING zeit DESCENDING.
      LOOP AT lt_invtext INTO DATA(ls_invtext) WHERE text IS NOT INITIAL.
        ls_wa_out-text_bem = ls_invtext-text.
        EXIT.
      ENDLOOP.
      IF sy-subrc = 0.
        IF ls_invtext-action = 'EDM_OK'.
          ls_wa_out-text_vorhanden = icon_led_green.
        ELSEIF ls_invtext-action = 'EDM_REK'.
          ls_wa_out-text_vorhanden = icon_led_red.
        ELSEIF ls_invtext-action = 'EDM_BEAR'.
          ls_wa_out-text_vorhanden = icon_led_yellow.
        ELSEIF ls_invtext-action = 'EDM_STD'.
          ls_wa_out-text_vorhanden = icon_led_inactive.
        ELSE.
          IF ls_wa_out-text_vorhanden IS INITIAL.
            ls_wa_out-text_vorhanden = 'X'.
          ENDIF.
        ENDIF.
      ENDIF.


      APPEND ls_wa_out TO   mt_out_invoice_data.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
