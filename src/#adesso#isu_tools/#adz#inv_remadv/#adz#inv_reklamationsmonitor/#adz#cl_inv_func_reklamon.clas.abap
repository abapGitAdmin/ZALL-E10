CLASS /adz/cl_inv_func_reklamon DEFINITION
  PUBLIC
  INHERITING FROM /adz/cl_inv_func_common
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS display_anlage
      IMPORTING
        !iv_anlage TYPE anlage .
  PROTECTED SECTION.

    METHODS show_text REDEFINITION .

    METHODS balance
        REDEFINITION .
    METHODS beende_remadv
        REDEFINITION .
    METHODS cancel_abr
        REDEFINITION .
    METHODS cancel_ap
        REDEFINITION .
    METHODS cancel_memi
        REDEFINITION .
    METHODS cancel_mgv
        REDEFINITION .
    METHODS cancel_nne
        REDEFINITION .
    METHODS dun_lock
        REDEFINITION .
    METHODS dun_unlock
        REDEFINITION .
    METHODS execute_process
        REDEFINITION .
    METHODS send_mail
        REDEFINITION .
    METHODS show_pdoc
        REDEFINITION .
    METHODS show_swt
        REDEFINITION .
    METHODS write_note
        REDEFINITION .
    METHODS abl_per_comdis
        REDEFINITION .
  PRIVATE SECTION.
ENDCLASS.



CLASS /adz/cl_inv_func_reklamon IMPLEMENTATION.


  METHOD abl_per_comdis.

    DATA: ls_inv_head   TYPE tinv_inv_head,
          ls_inv_doc    TYPE tinv_inv_doc,
          lt_inv_line_a	TYPE ttinv_inv_line_a,
          lv_answer     TYPE char1,
          lo_badi_check TYPE REF TO /adz/badi_rek_check_4_comdis.

    READ TABLE mrt_out_table->* ASSIGNING FIELD-SYMBOL(<ls_out>) WITH KEY sel = abap_true.
*# prüft, ob es ich um Strom handelt
    IF <ls_out>-spartyp <> /idxgc/if_constants=>gc_divcat_elec.
      MESSAGE i000(e4) WITH 'Comdis kann nur für Strom angetriggert werden.' DISPLAY LIKE 'E'.
      EXIT.
      RETURN.
    ENDIF.

*# prüft, ob COMDIS-Prozess angetriggert werden darf.
    DATA: lv_no_comdis_flag TYPE flag.

    TRY.
        GET BADI lo_badi_check.
        CALL BADI lo_badi_check->check_4_comdis
          EXPORTING
            is_out       = <ls_out>
          CHANGING
            cv_no_comdis = lv_no_comdis_flag.

      CATCH cx_badi.
        MESSAGE i000(e4) WITH 'Fehler beim Ausführen von BaDI-Check.'
                       DISPLAY LIKE 'E'.
        RETURN.
    ENDTRY.

    IF lv_no_comdis_flag IS NOT INITIAL.
      MESSAGE i000(e4) WITH 'COMDIS darf durch BaDI-Check nichit angetriggert werden.'    DISPLAY LIKE 'E'.
    ELSE.

*# Daten-Selektion statt Move-Corresponding
      SELECT SINGLE * FROM tinv_inv_doc   INTO ls_inv_doc    WHERE int_inv_doc_no = <ls_out>-int_inv_doc_no.
      SELECT SINGLE * FROM tinv_inv_head  INTO ls_inv_head   WHERE int_inv_no     = ls_inv_doc-int_inv_no.
      SELECT * FROM tinv_inv_line_a INTO TABLE lt_inv_line_a WHERE int_inv_doc_no = <ls_out>-int_inv_doc_no.
*# COMDIS prozessieren
      TRY.
          CALL METHOD /idexge/cl_inv_adddata=>action_idex_trig_comdis_proc
            EXPORTING
              is_inv_head    = ls_inv_head
              is_inv_doc     = ls_inv_doc
              it_inv_line_a  = lt_inv_line_a
              iv_dialog      = abap_true
            EXCEPTIONS
              error_occurred = 1
              OTHERS         = 2.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.
          ENDIF.

        CATCH cx_root INTO DATA(lo_error).
          MESSAGE i000(e4) WITH lo_error->get_text( ) DISPLAY LIKE 'E'.
          EXIT.
      ENDTRY.
    ENDIF.
  ENDMETHOD.


  METHOD balance.

    READ TABLE mrt_out_table->* ASSIGNING FIELD-SYMBOL(<ls_out>) WITH KEY sel = abap_true.
    CHECK sy-subrc = 0.
    DATA(lt_bdc) = /adz/cl_inv_customizing_data=>get_batch_data( 'BALANCE' ).

    /adz/cl_inv_customizing_data=>determine_values( EXPORTING it_bdc     = lt_bdc
                                                              iv_data = <ls_out>
                                                      RECEIVING rt_bdc  = lt_bdc ).

    DATA(lv_transaction) = /adz/cl_inv_customizing_data=>get_config_value( EXPORTING iv_option   = 'BALANCE'
                                                                                 iv_category = 'BDC_END'
                                                                                 iv_field    = 'TRANSACTION'
                                                                                 iv_id       = '1' ).
    IF lv_transaction IS INITIAL.
      MESSAGE i000(e4) WITH 'Für den Aufruf des Kontenstandes wurde' 'keine Transaktion hinterlegt.' DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.

    DATA(lv_using) = /adz/cl_inv_customizing_data=>get_config_value( EXPORTING iv_option   = 'BALANCE'
                                                                                 iv_category = 'BDC_END'
                                                                                 iv_field    = 'USING'
                                                                                 iv_id       = '1'  ).

    IF lv_using IS INITIAL.
      lv_using = 'E'.
    ENDIF.

    CALL TRANSACTION lv_transaction USING lt_bdc MODE lv_using.


  ENDMETHOD.


  METHOD beende_remadv.

    DATA: lo_inv_doc TYPE REF TO cl_inv_inv_remadv_doc,
          lt_return  TYPE bapirettab,
          lv_answer  TYPE char1,
          lv_icon    TYPE char4.

*  FIELD-SYMBOLS: <it_out> TYPE STANDARD TABLE, <wa_out>, <value>.
*  IF p_invtp = '2'.
*    ASSIGN it_out_memi TO <it_out>.
*  ELSEIF p_invtp = 1.
*    ASSIGN it_out TO <it_out>.
*  ELSEIF p_invtp = 3.
*    ASSIGN it_out_mgv TO <it_out>.
*** --> Nuss 09.2018
*  ELSEIF p_invtp = 4.
*    ASSIGN it_out_msb TO <it_out>.
*** <-- Nuss 09.2018
*  ENDIF.
    DATA: icon(4) TYPE c.

* Sicherheitsabfrage
    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
      EXPORTING
        defaultoption = 'Y'
        textline1     = 'Wollen Sie den Belegstatus auf ''Beendet'' setzen?'
        textline2     = 'Diese Aktion kann nicht mehr rückgängig gemacht werden!'
        titel         = 'Belegstatus auf ''Beendet'' setzen'
      IMPORTING
        answer        = lv_answer.

    IF NOT lv_answer CA 'jJ'.
      EXIT.
    ENDIF.

    LOOP AT mrt_out_table->* ASSIGNING FIELD-SYMBOL(<ls_out>) WHERE sel = abap_true
                                                  AND int_inv_doc_no IS NOT INITIAL
                                                  AND invoice_status NE '01'
                                                  AND invoice_status NE '02'.
**   Zeile muss Markiert sein
*      ASSIGN COMPONENT 'SEL' OF STRUCTURE <wa_out> TO <value>.
*      CHECK <value> = 'X'.

*      lv_b_selected = abap_true.

*   INT_INVOICE_NO muss gefüllt sein.
*   Bei mehreren Fehlern ist nur die erste Zeile zum Beleg gefüllt.
*      ASSIGN COMPONENT 'INT_INV_DOC_NO' OF STRUCTURE <la_out> TO <lv_value>.
*      CHECK <lv_value> IS NOT INITIAL.
*   Status 'Neu' oder 'Zu Bearbeiten'
* Der Status des Avises steht immer in Feld INVOICE_STATUS UlHe
*    IF p_invtp = '2'.
*      ASSIGN COMPONENT 'STATUS' OF STRUCTURE <wa_out> TO <value>.
*    ELSE.
*      ASSIGN COMPONENT 'INVOICE_STATUS' OF STRUCTURE <ls_out> TO <lv_value>.
**    ENDIF.
*      IF <value> NE '01' AND
*         <value> NE '02'.
*        CONTINUE.
*      ENDIF.


*      ASSIGN COMPONENT 'INT_INV_DOC_NO' OF STRUCTURE <wa_out> TO <value>.
      CREATE OBJECT lo_inv_doc
        EXPORTING
          im_work_mode  = cl_inv_inv_remadv_doc=>co_wmode_change
          im_doc_number = <ls_out>-int_inv_doc_no
        EXCEPTIONS
          OTHERS        = 1.
      IF sy-subrc <> 0.
        IF lo_inv_doc IS NOT INITIAL.
          CALL METHOD lo_inv_doc->close.
        ENDIF.
      ENDIF.
*
*      CLEAR lt_return[].
      CALL METHOD lo_inv_doc->change_document_status
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
        lv_icon = icon_led_red.
      ELSE.
        lv_icon = icon_booking_stop.

        IF <ls_out>-invoice_type = /adz/if_remadv_constants=>mc_invoice_type_memi.
*                IF p_invtp = '2'.
*       "MEMIDOC CHANGE STATUS
*          ASSIGN COMPONENT 'DOC_ID' OF STRUCTURE <wa_out> TO <value>.

          DATA ls_memidoc_u TYPE /idxmm/memidoc.
          DATA lt_memidoc_u TYPE /idxmm/t_memi_doc.
          DATA lo_memidoc TYPE REF TO /idxmm/cl_memi_document_db.
          CREATE OBJECT lo_memidoc.
          SELECT SINGLE * FROM /idxmm/memidoc INTO ls_memidoc_u WHERE doc_id = <ls_out>-doc_id.

*       nur setzen wenn Status nicht über Cust ausgeschlossen
          SELECT COUNT( * ) FROM /adz/fi_remad
                 WHERE negrem_option    = 'BEENDE_REMADV'
                 AND   negrem_category  = 'MEMI_DOC_STATUS'
                 AND   negrem_field     = 'EXCLUDE'
                 AND   negrem_value     = ls_memidoc_u-doc_status.
          IF sy-subrc = 0.
*         Status ausgeschlossen, nix machen
          ELSE.
            ls_memidoc_u-doc_status = '77'.
            APPEND ls_memidoc_u TO lt_memidoc_u.
            CLEAR ls_memidoc_u.
*        TRY.
            CALL METHOD /idxmm/cl_memi_document_db=>update
              EXPORTING
*               iv_simulate   =
                it_doc_update = lt_memidoc_u.
*         CATCH /idxmm/cx_bo_error .
*        ENDTRY.

          ENDIF.
        ENDIF.
      ENDIF.

      SELECT SINGLE invoice_status inv_doc_status
        FROM tinv_inv_head
       INNER JOIN tinv_inv_doc
               ON tinv_inv_head~int_inv_no = tinv_inv_doc~int_inv_doc_no
        INTO (<ls_out>-invoice_status, <ls_out>-inv_doc_status)
       WHERE tinv_inv_doc~int_inv_doc_no = <ls_out>-int_inv_doc_no.
      <ls_out>-process_state = lv_icon.
      CLEAR lv_icon.
***      ASSIGN COMPONENT 'INT_INV_DOC_NO' OF STRUCTURE <wa_out> TO <value>.
***      PERFORM set_process_state_all USING icon <value>.

    ENDLOOP.

*    SELECT COUNT(*) FROM /adz/fi_remad
*     WHERE negrem_option = 'DROPLOCKS'
*       AND negrem_field = 'BEENDEN'
*       AND negrem_value = 'X'.
*    IF sy-subrc = 0.
*      PERFORM drop_select.
*    ENDIF.

*    IF lv_b_selected EQ abap_false.
*      MESSAGE e000(e4) WITH 'Bitte selektieren Sie einen Datensatz.'.
*      EXIT.
*    ENDIF.

  ENDMETHOD.


  METHOD cancel_abr.

    DATA: "wa_sel           LIKE LINE OF rspar_tab,
      lv_reason        TYPE bill_revreason_kk,
      ls_dfkkinvbill_h TYPE dfkkinvbill_h.
    DATA: lt_billdocno     TYPE fkkinv_billdocno_tab.

*    FIELD-SYMBOLS: <it_out> TYPE STANDARD TABLE,
*                   <wa_out>,
*                   <value>.

    CLEAR lv_reason.

    SELECT SINGLE negrem_value
    INTO lv_reason
    FROM /adz/fi_remad
    WHERE negrem_option    EQ 'STORNO_ABRBEL'
      AND negrem_category  EQ ''
      AND negrem_field     EQ 'REASON'
      AND negrem_id        EQ 1.
* <-- Nuss 10.2018

    IF lv_reason IS INITIAL.
      lv_reason = '00'.
    ENDIF.

    LOOP AT mrt_out_table->* ASSIGNING FIELD-SYMBOL(<ls_out>) WHERE sel = abap_true.
* Zeile muss markiert sein.
*      CHECK <ls_out>-sel = 'X'.
      APPEND <ls_out>-srcdocno TO lt_billdocno.

*    SUBMIT rfkkinvbillrev02
*     WITH SELECTION-TABLE lt_sel
*     VIA SELECTION-SCREEN
*     AND RETURN.

    ENDLOOP.

    IF lines( lt_billdocno ) > 0.
      DATA  lv_dialog TYPE dialog_kk VALUE ''.
      CALL FUNCTION 'FKK_INV_REV_BILLDOC_SINGLE'
        EXPORTING
          i_applk         = 'R'
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
    LOOP AT mrt_out_table->* INTO <ls_out> WHERE sel = abap_true.

*   Zeile muss Markiert sein
*    check wa_out-xselp = 'X'.
*      CHECK <ls_out>-sel = 'X'.
*
*      DATA: icon(4) TYPE c.
*      icon  = icon_storno.


      SELECT SINGLE * FROM dfkkinvbill_h INTO ls_dfkkinvbill_h
        WHERE billdocno = <ls_out>-srcdocno.

      IF ls_dfkkinvbill_h-revreason IS NOT INITIAL.

        <ls_out>-cancel_state = icon_storno.

*        MODIFY it_out_msb FROM <ls_out>.

      ENDIF.


    ENDLOOP.

  ENDMETHOD.


  METHOD cancel_ap.

    DATA: lv_datum  TYPE sy-datum,
          lv_answer TYPE char1,
          lt_sval   TYPE TABLE OF sval,
          ls_sval   TYPE          sval.

    DATA: lt_sel TYPE TABLE OF rsparams,
          ls_sel TYPE rsparams.

    DATA: ls_dfkkbix_bip_i TYPE dfkkbix_bip_i.

    ls_sval-tabname   = 'SYST'.
    ls_sval-fieldname = 'DATUM'.
    ls_sval-field_obl = 'X'.
    ls_sval-fieldtext = 'Stornodatum'.
    ls_sval-value     = sy-datum.
    APPEND ls_sval TO lt_sval.


    CALL FUNCTION 'POPUP_GET_VALUES'
      EXPORTING
*       NO_VALUE_CHECK        = ' '
        popup_title  = 'Stornodatum'
        start_column = '5'
        start_row    = '4'
      IMPORTING
        returncode   = lv_answer
      TABLES
        fields       = lt_sval.

    IF lv_answer IS INITIAL.
      lv_answer = 'j'.
    ENDIF.

    LOOP AT mrt_out_table->* ASSIGNING FIELD-SYMBOL(<ls_out>) WHERE sel = abap_true.
*    LOOP AT it_out_msb INTO wa_out_msb.
* Zeile muss markiert sein.
*      CHECK wa_out_msb-sel = 'X'.

      CLEAR: ls_sel, lt_sel.
      ls_sel-selname = 'REVFR'.
      ls_sel-kind = 'P'.
      ls_sel-low = ls_sval-value.
      APPEND ls_sel TO lt_sel.

      CLEAR: ls_sel.
      ls_sel-selname = 'BIPNO'.
      ls_sel-kind = 'S'.
      ls_sel-sign = 'I'.
      ls_sel-option = 'EQ'.
      ls_sel-low = <ls_out>-billplanno.
      APPEND ls_sel TO lt_sel.


      SUBMIT rfkkbixbipreqrev02
         WITH SELECTION-TABLE lt_sel
         VIA SELECTION-SCREEN
         AND RETURN.

    ENDLOOP.

* Nach Änderung der Belege müssen die Daten im Datensatz für
* die Anzeige aktualisiert werden
*    LOOP AT it_out_msb INTO wa_out_msb.
    LOOP AT mrt_out_table->* ASSIGNING <ls_out> WHERE sel = abap_true.
* Zeile muss markiert sein.
*      CHECK wa_out_msb-sel = 'X'.

*      DATA: icon(4) TYPE c.
*      icon  = icon_storno.

      SELECT * FROM dfkkbix_bip_i INTO ls_dfkkbix_bip_i
        WHERE billplanno = <ls_out>-billplanno.

        IF ls_dfkkbix_bip_i-cancelled = 'X'.

          <ls_out>-cancel_state_ap = icon_storno.

*          MODIFY it_out_msb FROM wa_out_msb.
          EXIT.
        ENDIF.

      ENDSELECT.


    ENDLOOP.

  ENDMETHOD.


  METHOD cancel_memi.

    DATA: lv_opbel       TYPE erdk-opbel.
    DATA: lv_transaction TYPE /adz/fi_neg_remadv_val.
    DATA: lt_sel_ea15 TYPE TABLE OF rsparams.
    DATA lv_reversalkx  TYPE /idxmm/de_reversal.

    APPEND VALUE rsparams( selname = 'P_TEST' kind = 'P' low     = ' ') TO lt_sel_ea15.
*    CLEAR w_sel_ea15.
*    w_sel_ea15-selname = 'P_TEST'.
*    w_sel_ea15-kind    = 'P'.
*    w_sel_ea15-low     = ' '.
*    APPEND w_sel_ea15 TO t_sel_ea15.

*    LOOP AT it_out_memi INTO wa_out_memi.
    LOOP AT mrt_out_table->* ASSIGNING FIELD-SYMBOL(<ls_out>)
                                 WHERE sel = abap_true
                                   AND invoice_type = /adz/if_remadv_constants=>mc_invoice_type_memi.
**   Zeile muss Markiert sein
*      CHECK wa_out_memi-sel = 'X'.
*      lv_b_selected = abap_true.

      IF <ls_out>-doc_id CO ' 0123456789'.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = <ls_out>-doc_id
          IMPORTING
            output = lv_opbel.
      ELSE.
        lv_opbel = <ls_out>-own_invoice_no+3.
      ENDIF.

*      CLEAR w_sel_ea15.
*      w_sel_ea15-selname = 'S_DOC_ID'.
*      w_sel_ea15-kind    = 'S'.
*      w_sel_ea15-sign    = 'I'..
*      w_sel_ea15-option  = 'EQ'.
*      w_sel_ea15-low     = h_opbel.
      SELECT COUNT(*) FROM erdk WHERE opbel = lv_opbel AND simulated = 'X'.
      IF sy-subrc = 0.
        MESSAGE i000(e4) WITH 'Stornieren von Simulierten Belegen nicht möglich.'
                         DISPLAY LIKE 'E'.
        CONTINUE.
      ELSE.

        APPEND VALUE rsparams( selname = 'S_DOC_ID' kind = 'S' sign = 'I' option = 'EQ' low = lv_opbel )
                  TO lt_sel_ea15.

      ENDIF.


    ENDLOOP.
*
*    IF lv_b_selected EQ abap_false.
*      MESSAGE e000(e4) WITH 'Bitte selektieren Sie eine Beleg.'.
*      EXIT.
*    ENDIF.


    DATA: lv_selscreen TYPE boolean.
    /adz/cl_inv_customizing_data=>get_config_value(
                                            EXPORTING iv_option   = 'CANCEL_M'
                                                      iv_category = 'BDC_END'
                                                      iv_field    = 'SELSCREEN'
                                                      iv_id       = '1'
                                            RECEIVING rv_value = lv_selscreen ).

    /adz/cl_inv_customizing_data=>get_config_value(
                                            EXPORTING iv_option   = 'CANCEL_M'
                                                      iv_category = 'BDC_END'
                                                      iv_field    = 'TRANSACTION'
                                                      iv_id       = '1'
                                            RECEIVING rv_value = lv_transaction ).

    IF lv_transaction IS INITIAL.
      MESSAGE e000(e4) WITH 'Für den Aufruf zur Prozessierung des Belegs wurde keine Transaktion hinterlegt.'.
      EXIT.
    ENDIF.

    IF lv_selscreen EQ abap_false.
      SUBMIT (lv_transaction)
        WITH SELECTION-TABLE lt_sel_ea15
        AND RETURN.
    ELSE.
      SUBMIT (lv_transaction)
        WITH SELECTION-TABLE lt_sel_ea15
        VIA SELECTION-SCREEN
        AND RETURN.
    ENDIF.

* Nach Änderung der Belege müssen die Daten im Datensatz für
* die Anzeige aktualisiert werden
*    DATA: wa_erdk TYPE erdk.
    LOOP AT mrt_out_table->* ASSIGNING <ls_out>
                                 WHERE sel = abap_true
                                   AND invoice_type = /adz/if_remadv_constants=>mc_invoice_type_memi.

*   Zeile muss Markiert sein
*    check wa_out-xselp = 'X'.
*      CHECK wa_out_memi-sel = 'X'.

*      DATA: icon(4) TYPE c.
*      icon  = icon_storno.

      SELECT SINGLE reversal
        FROM /idxmm/memidoc
        INTO lv_reversalkx
       WHERE doc_id = <ls_out>-doc_id.
      IF lv_reversalkx = 'X'.
        <ls_out>-cancel_state_mm = icon_storno.
      ENDIF.
*   Daten in interne Tabelle für Ausgabe schreiben
*      MODIFY it_out_memi FROM wa_out_memi.

      CLEAR lv_reversalkx.

    ENDLOOP.

  ENDMETHOD.


  METHOD cancel_mgv.

    DATA: lv_b_selected TYPE boolean.
    DATA: lv_transaction TYPE  /adz/fi_neg_remadv_val.
    DATA: lv_reason TYPE  /adz/fi_neg_remadv_val.
    DATA: ls_sel_ea15 TYPE  rsparams,
          lt_sel_ea15 TYPE TABLE OF  rsparams.

    CLEAR lt_sel_ea15.

    LOOP AT mrt_out_table->* ASSIGNING FIELD-SYMBOL(<ls_out>) WHERE sel = abap_true.
*      LOOP AT it_out_mgv INTO <ls_out>.
*   Zeile muss Markiert sein
*
*        CHECK <ls_out>-sel = 'X'.
*        lv_b_selected = abap_true.

      CLEAR ls_sel_ea15.
      ls_sel_ea15-selname = 'BDOCNO'.
      ls_sel_ea15-kind    = 'S'.
      ls_sel_ea15-sign    = 'I'.
      ls_sel_ea15-option  = 'EQ'.
      ls_sel_ea15-low     = <ls_out>-billdocno.
      SELECT COUNT(*) FROM dfkkinvbill_h WHERE billdocno = <ls_out>-billdocno AND simulated = 'X'.
      IF sy-subrc = 0.
        MESSAGE i000(e4) WITH 'Stornieren von Simulierten Belegen nicht möglich.'
           DISPLAY LIKE 'E'.
        CONTINUE.
      ELSE.
        APPEND ls_sel_ea15 TO lt_sel_ea15.
      ENDIF.

    ENDLOOP.
    "Transaktion aus dem Customizing holen. Standart = FKKINVBILL_REV_S
    "Außerdem Standart Stornogrund aus dem Customizing
    DATA: lv_b_selscreen TYPE boolean.
    /adz/cl_inv_customizing_data=>get_config_value( EXPORTING iv_option   = 'CANCEL_MGV_DISP'
                                                      iv_category = 'BDC_END'
                                                      iv_field    = 'SELSCREEN'
                                                      iv_id       = '1'
                                            RECEIVING rv_value = lv_b_selscreen
                                           ).
    CLEAR lv_transaction.
    /adz/cl_inv_customizing_data=>get_config_value( EXPORTING iv_option   = 'CANCEL_MGV'
                                                      iv_category = 'BDC_END'
                                                      iv_field    = 'TRANSACTION'
                                                      iv_id       = '1'
                                            RECEIVING rv_value = lv_transaction
                                           ).

    "Methode nicht verwendet, da CONVERSION_EXIT_ALPHA_OUTPUT nicht benutzt werden darf
    SELECT SINGLE negrem_value
    INTO lv_reason
    FROM /adz/fi_remad
    WHERE negrem_option    EQ 'CANCEL_REASON_MGV'
      AND negrem_category  EQ 'BDC_END'
      AND negrem_field     EQ 'TRANSACTION'
     AND negrem_id         EQ '1'.

    CLEAR ls_sel_ea15.
    ls_sel_ea15-selname = 'REASON'.
    ls_sel_ea15-kind    = 'C'.
    ls_sel_ea15-low     = lv_reason.
    APPEND ls_sel_ea15 TO lt_sel_ea15.


    IF lv_transaction IS INITIAL.
      MESSAGE e000(e4) WITH 'Für den Aufruf zur Prozessierung des Belegs wurde keine Transaktion hinterlegt.'
                       DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.
    IF lv_b_selscreen EQ abap_false.
      SUBMIT (lv_transaction)
        WITH SELECTION-TABLE lt_sel_ea15
        AND RETURN.
    ELSE.
      SUBMIT (lv_transaction)
        WITH SELECTION-TABLE lt_sel_ea15
        VIA SELECTION-SCREEN
        AND RETURN.
    ENDIF.

    LOOP AT mrt_out_table->* ASSIGNING <ls_out> WHERE sel = abap_true.

*   Zeile muss Markiert sein
*    check wa_out-xselp = 'X'.
*      CHECK <ls_out>-sel = 'X'.

      DATA: lv_icon(4) TYPE c.
      lv_icon  = icon_storno.

      DATA ls_dfkkinvbill_h TYPE dfkkinvbill_h.
*   Belegkopf selektieren
      SELECT SINGLE *  FROM dfkkinvbill_h INTO ls_dfkkinvbill_h WHERE billdocno = <ls_out>-billdocno .


      IF ls_dfkkinvbill_h-reversaldoc IS INITIAL
         OR sy-subrc <> 0.
        lv_icon = icon_led_red.
      ENDIF.

      <ls_out>-cancel_state = lv_icon.

*   Daten in interne Tabelle für Ausgabe schreiben
*      MODIFY it_out_mgv FROM <ls_out>.

    ENDLOOP.

  ENDMETHOD.


  METHOD cancel_nne.

    FIELD-SYMBOLS    <lv_value> TYPE any.
    DATA: lv_opbel      TYPE erdk-opbel.
*          lv_b_selected TYPE boolean.
    DATA: lv_transaction TYPE  /adz/fi_neg_remadv_val.
*    IF p_invtp = '2'.
*      ASSIGN it_out_memi TO <it_out>.
** --> Nuss 09.2018
*    ELSEIF p_invtp = '4'.
**    ASSIGN it_out_msb TO <it_out>.    "Nuss 09.2018-2
*      EXIT.                              "Nuss 09.2018
** <-- Nuss 09.2018
*    ELSE.
*      ASSIGN it_out TO <it_out>.
*    ENDIF.
*    REFRESH t_sel_ea15.

    DATA(lt_sel_ea15) = VALUE rsparams_tt( ( selname = 'AUGBD' kind = 'P' low = sy-datum )
                                           ( selname = 'BLART' kind = 'P' low = 'ST' )
                                           ( selname = 'ABP_SAVE' kind = 'P' low = 'X' ) ).
*    CLEAR w_sel_ea15.
*    w_sel_ea15-selname = 'AUGBD'.
*    w_sel_ea15-kind    = 'P'.
*    w_sel_ea15-low     = sy-datum.
*    APPEND w_sel_ea15 TO t_sel_ea15.

*    CLEAR w_sel_ea15.
*    w_sel_ea15-selname = 'BLART'.
*    w_sel_ea15-kind    = 'P'.
**  w_sel_ea15-low     = 'FS'.            "nicht BAS
*    w_sel_ea15-low     = 'ST'.           "BAS
*    APPEND w_sel_ea15 TO t_sel_ea15.
*
*    CLEAR w_sel_ea15.
*    w_sel_ea15-selname = 'ABP_SAVE'.
*    w_sel_ea15-kind    = 'P'.
*    w_sel_ea15-low     = 'X'.
*    APPEND w_sel_ea15 TO t_sel_ea15.



    LOOP AT mrt_out_table->* ASSIGNING FIELD-SYMBOL(<ls_out>)
      WHERE sel = 'X' AND invoice_type NE /adz/if_remadv_constants=>mc_invoice_type_msb.

**   Zeile muss Markiert sein
**      ASSIGN COMPONENT 'SEL' OF STRUCTURE <wa_out> TO <value>.
**      CHECK <value> = 'X'.
**      lv_b_selected = abap_true.
      IF <ls_out>-invoice_type = /adz/if_remadv_constants=>mc_invoice_type_memi.
        ASSIGN <ls_out>-erchcopbel     TO <lv_value>.
      ELSE.
        ASSIGN <ls_out>-own_invoice_no TO  <lv_value>.
      ENDIF.
      IF <lv_value> CO ' 0123456789'.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = <lv_value>
          IMPORTING
            output = lv_opbel.
      ELSE.
        lv_opbel = <lv_value>+3.
      ENDIF.

*      CLEAR w_sel_ea15.
*      w_sel_ea15-selname = 'OPBEL'.
*      w_sel_ea15-kind    = 'S'.
*      w_sel_ea15-sign    = 'I'.
*      w_sel_ea15-option  = 'EQ'.
*      w_sel_ea15-low     = lv_opbel.
      SELECT COUNT(*) FROM erdk WHERE opbel = lv_opbel AND simulated = 'X'.
      IF sy-subrc = 0.
        MESSAGE i000(e4) WITH 'Stornieren von Simulierten Belegen nicht möglich.'
                         DISPLAY LIKE 'E'.
        CONTINUE.
      ELSE.
        APPEND VALUE rsparams( selname = 'OPBEL' kind = 'S' sign = 'I' option = 'EQ' low = lv_opbel )
               TO lt_sel_ea15.
*        APPEND w_sel_ea15 TO t_sel_ea15.
      ENDIF.

      CLEAR lv_opbel.

    ENDLOOP.

*    IF lv_b_selected EQ abap_false.
*      MESSAGE e000(e4) WITH 'Bitte selektieren Sie eine Beleg.'.
*      EXIT.
*    ENDIF.

    DATA(lv_selscreen) = /adz/cl_inv_customizing_data=>get_config_value(
                                            EXPORTING iv_option   = 'CANCEL'
                                                      iv_category = 'BDC_END'
                                                      iv_field    = 'SELSCREEN'
                                                      iv_id       = '1'  ).

    /adz/cl_inv_customizing_data=>get_config_value(
                                            EXPORTING iv_option   = 'CANCEL'
                                                      iv_category = 'BDC_END'
                                                      iv_field    = 'TRANSACTION'
                                                      iv_id       = '1'
                                            RECEIVING rv_value = lv_transaction
                                           ).
    IF lv_transaction IS INITIAL.
      MESSAGE i000(e4) WITH 'Für den Aufruf zur Prozessierung des Belegs wurde keine Transaktion hinterlegt.'
                       DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.

    IF lv_selscreen EQ abap_false.
      SUBMIT (lv_transaction)
        WITH SELECTION-TABLE lt_sel_ea15
      AND RETURN.
    ELSE.
      SUBMIT (lv_transaction)
        WITH SELECTION-TABLE lt_sel_ea15
      VIA SELECTION-SCREEN
      AND RETURN.
    ENDIF.


* Nach Änderung der Belege müssen die Daten im Datensatz für
* die Anzeige aktualisiert werden
    DATA: wa_erdk TYPE erdk.
    LOOP AT mrt_out_table->* ASSIGNING <ls_out> WHERE sel = abap_true.
*   Zeile muss Markiert sein
*    check wa_out-xselp = 'X'.

      IF <ls_out>-invoice_type = /adz/if_remadv_constants=>mc_invoice_type_memi.
        ASSIGN <ls_out>-erchcopbel     TO <lv_value>.
      ELSE.
        ASSIGN <ls_out>-own_invoice_no TO <lv_value>.
      ENDIF.
      IF  <lv_value> CO ' 0123456789'.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = <lv_value>
          IMPORTING
            output = lv_opbel.
      ELSE.
        lv_opbel =  <lv_value>+3.
      ENDIF.

*   Belegkopf selektieren
      SELECT SINGLE stokz FROM erdk INTO @DATA(lv_stokz)
        WHERE erdk~opbel = @lv_opbel.

      IF lv_stokz IS INITIAL OR sy-subrc <> 0.
        <ls_out>-cancel_state = icon_led_red.
      ENDIF.
      <ls_out>-cancel_state = icon_storno.
      CLEAR lv_opbel.

    ENDLOOP.

  ENDMETHOD.


  METHOD display_anlage.
    CHECK iv_anlage IS NOT INITIAL.
    CALL FUNCTION 'ISU_S_INSTLN_DISPLAY'
      EXPORTING
        x_anlage     = iv_anlage     " Objektkey 1 (ANLAGE)
        x_keydate    = '00000000'                " Objektkey 2 (AB-Datum)
        x_upd_online = 'X'.                " Flag: Updates direkt im Online

  ENDMETHOD.


  METHOD dun_lock.
    SELECT COUNT(*) FROM tfk047s WHERE mansp = iv_lockr.
    IF sy-subrc <> 0.
      MESSAGE |Mahnsperrgrund { iv_lockr } nicht vorhanden!|  TYPE 'I' DISPLAY LIKE 'I'.
      RETURN.
    ENDIF.
    DATA lv_answer     TYPE char1.
    DATA lt_fkkopchl   TYPE STANDARD TABLE OF fkkopchl.

    " Sicherheitsabfrage
    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
      EXPORTING
        defaultoption = 'Y'
        textline1     = TEXT-110
        textline2     = TEXT-111
        titel         = TEXT-t03
      IMPORTING
        answer        = lv_answer.
    IF NOT lv_answer CA 'jJyY'.
      EXIT.
    ENDIF.
    DATA lt_error TYPE STANDARD TABLE OF opbel_kk.

    LOOP AT mrt_out_table->* ASSIGNING FIELD-SYMBOL(<ls_out>) WHERE sel = 'X'.
      CASE <ls_out>-invoice_type.

        WHEN /adz/if_remadv_constants=>mc_invoice_type_nn
          OR /adz/if_remadv_constants=>mc_invoice_type_mgv
          OR /adz/if_remadv_constants=>mc_invoice_type_msb.  " alles nur kein memi
          lt_fkkopchl = VALUE #( ( lockaktyp = '01'  proid = '01' lotyp = '02' "Belegposition
            lockr = iv_lockr
            fdate = iv_fdate
            tdate = iv_tdate
*      t_fkkopchl-opupz     = wa_out-opupz.
            gpart = <ls_out>-gpart
            vkont = COND #( WHEN <ls_out>-invoice_type EQ /adz/if_remadv_constants=>mc_invoice_type_msb THEN <ls_out>-vkont_msb
                            ELSE <ls_out>-vkont )
            opupk = COND #( WHEN <ls_out>-invoice_type EQ /adz/if_remadv_constants=>mc_invoice_type_msb THEN '0001'
                            ELSE <ls_out>-opupk )
            opupw = COND #( WHEN <ls_out>-invoice_type EQ /adz/if_remadv_constants=>mc_invoice_type_msb THEN ''
                            ELSE <ls_out>-opupw )
            opupz = COND #( WHEN <ls_out>-invoice_type EQ /adz/if_remadv_constants=>mc_invoice_type_nn  THEN  <ls_out>-opupz ELSE '' )
          ) ).
          CALL FUNCTION 'FKK_DOCUMENT_CHANGE_LOCKS'
            EXPORTING
              i_opbel           = <ls_out>-opbel
            TABLES
              t_fkkopchl        = lt_fkkopchl
            EXCEPTIONS
              err_document_read = 1
              err_create_line   = 2
              err_lock_reason   = 3
              err_lock_date     = 4
              OTHERS            = 5.
          IF sy-subrc <> 0.
            APPEND <ls_out>-opbel TO lt_error.
            <ls_out>-process_state = icon_led_red.
          ELSE.
            <ls_out>-process_state = icon_locked.
          ENDIF.

        WHEN /adz/if_remadv_constants=>mc_invoice_type_memi.
          DATA lv_done TYPE abap_bool.
          CLEAR lv_done.
          DATA lv_fdate LIKE iv_fdate.
          DATA lv_tdate LIKE iv_tdate.
          DATA lv_lockr LIKE iv_lockr.
          lv_fdate = iv_fdate.
          lv_tdate = iv_tdate.
          lv_lockr = iv_lockr.
          CALL FUNCTION '/ADZ/MEMI_MAHNSPERRE'
            EXPORTING
              iv_belnr     = <ls_out>-doc_id
*             IX_GET_LOCKHIST       =
              ix_set_lock  = 'X'
*             IX_DEL_LOCK  =
              iv_no_popup  = lv_done
            IMPORTING
              ev_done      = lv_done
            CHANGING
              iv_date_from = lv_fdate
              iv_date_to   = lv_tdate
              iv_lockr     = lv_lockr.
          IF lv_done IS   INITIAL.
            APPEND <ls_out>-opbel TO lt_error.
            <ls_out>-process_state = icon_led_red.
            EXIT.
          ELSE.
            <ls_out>-process_state = icon_locked.
            <ls_out>-mahnsp = lv_lockr.
            <ls_out>-fdate  = lv_fdate.
            <ls_out>-tdate  = lv_tdate.
          ENDIF.

      ENDCASE.
    ENDLOOP.
    IF lt_error IS NOT INITIAL.
      DATA(lv_msgtext) =  |Es sind { lines( lt_error ) } Fehler aufgetreten. Bitte rot markierte Belege prüfen.|.
      CALL FUNCTION 'FC_POPUP_ERR_WARN_MESSAGE'
        EXPORTING
          popup_title  = 'Fehler'                 " Titel des Popups
          is_error     = 'X'              " Flag: Meldung eines Fehlers
          message_text = lv_msgtext
          start_column = 25
          start_row    = 6.
    ENDIF.
  ENDMETHOD.


  METHOD dun_unlock.
    DATA lt_opbel TYPE fkkopkey_t.
    DATA ls_memidoc_u  TYPE /idxmm/memidoc.
    DATA lt_memidoc_u  TYPE /idxmm/t_memi_doc.
    DATA lr_memidoc    TYPE REF TO /idxmm/cl_memi_document_db.

    IF iv_p_invtp <> /adz/if_remadv_constants=>mc_invoice_type_mgv.
* Sicherheitsabfrage
      DATA l_answer TYPE char1.
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

    LOOP AT mrt_out_table->* ASSIGNING FIELD-SYMBOL(<ls_out>) WHERE sel = 'X'.
      CASE <ls_out>-invoice_type.
        WHEN /adz/if_remadv_constants=>mc_invoice_type_nn
          OR /adz/if_remadv_constants=>mc_invoice_type_mgv
          OR /adz/if_remadv_constants=>mc_invoice_type_msb.
          lt_opbel = VALUE #( (
            opbel = <ls_out>-opbel
            opupw = COND #( WHEN <ls_out>-invoice_type EQ /adz/if_remadv_constants=>mc_invoice_type_msb THEN '000'
                            ELSE <ls_out>-opupw )
            opupk = COND #( WHEN <ls_out>-invoice_type EQ /adz/if_remadv_constants=>mc_invoice_type_msb THEN '0001'
                            ELSE <ls_out>-opupk )
            opupz = COND #( WHEN <ls_out>-invoice_type EQ /adz/if_remadv_constants=>mc_invoice_type_msb THEN '000'
                            ELSE <ls_out>-opupz )
          ) ).
          DATA lt_locks TYPE TABLE OF dfkklocks.
          CALL FUNCTION 'FKK_S_LOCK_GET_FOR_DOC_ITEMS'
            EXPORTING
              i_opbel  = lt_opbel[ 1 ]-opbel
              i_opupw  = lt_opbel[ 1 ]-opupw
              i_opupk  = lt_opbel[ 1 ]-opupk
              i_opupz  = lt_opbel[ 1 ]-opupz
            TABLES
              et_locks = lt_locks.

          IF lt_locks IS NOT INITIAL.
            CALL FUNCTION 'FKK_S_LOCK_DELETE_FOR_DOCITEMS'
              EXPORTING
                iv_opbel    = <ls_out>-opbel
                it_fkkopkey = lt_opbel
                iv_proid    = lt_locks[ 1 ]-proid
                iv_lockr    = lt_locks[ 1 ]-lockr
                iv_fdate    = lt_locks[ 1 ]-fdate
                iv_tdate    = lt_locks[ 1 ]-tdate
              EXCEPTIONS
                OTHERS      = 5.

            IF sy-subrc <> 0.
              <ls_out>-process_state = icon_breakpoint.
            ELSE.
              <ls_out>-process_state = icon_unlocked.
            ENDIF.
            " Sperren der OPBELS wieder aufheben
            CALL FUNCTION 'FKK_DEQ_OPBELS_AFTER_CHANGES'
              EXPORTING
                _scope          = '3'
                i_only_document = ' '.
          ENDIF.

        WHEN /adz/if_remadv_constants=>mc_invoice_type_memi.
          DATA lv_done TYPE abap_bool.
          CALL FUNCTION '/ADZ/MEMI_MAHNSPERRE'
            EXPORTING
              iv_belnr    = <ls_out>-doc_id
*             IX_GET_LOCKHIST  =
*             IX_SET_LOCK =
              ix_del_lock = 'X'
*             IV_NO_POPUP =
            IMPORTING
              ev_done     = lv_done.
*        changing
*          iv_date_from =
*          iv_date_to   =
*          iv_lockr     =.

          IF lv_done = 'X'.
            <ls_out>-mahnsp = ''.
            <ls_out>-fdate = ''.
            <ls_out>-tdate = ''.
            <ls_out>-process_state = icon_unlocked.
          ENDIF.

      ENDCASE.
    ENDLOOP.
  ENDMETHOD.


  METHOD execute_process.

    DATA: lt_return     TYPE bapirettab,
          lv_proc_type  TYPE inv_process_type,
          lv_error      TYPE inv_kennzx,
          lv_old_doc_no TYPE inv_int_inv_doc_no.

*    FIELD-SYMBOLS: <it_out> TYPE STANDARD TABLE, <wa_out>, <value>.

*    IF p_invtp = '2'.
*      ASSIGN it_out_memi TO <it_out>.
*    ELSEIF p_invtp = 1.
*      ASSIGN it_out TO <it_out>.
*    ELSEIF p_invtp = 3.
*      ASSIGN it_out_mgv TO <it_out>.
*** --> Nuss 09.2018
*    ELSEIF p_invtp = 4.
*      ASSIGN it_out_msb TO <it_out>.
*** <-- Nuss 09.2018
*    ENDIF.

    LOOP AT mrt_out_table->* ASSIGNING FIELD-SYMBOL(<ls_out>) WHERE sel = abap_true.

*   INT_INVOICE_NO muss gefüllt sein.
*   Bei mehreren Fehlernist nur die erste Zeile zum Beleg gefüllt.
      IF <ls_out>-int_inv_doc_no IS INITIAL OR <ls_out>-int_inv_doc_no = lv_old_doc_no.
        CONTINUE.
      ENDIF.
*      ASSIGN COMPONENT 'INT_INV_DOC_NO' OF STRUCTURE <wa_out> TO <value>.
*      CHECK <value> IS NOT INITIAL.
*   Status 'Neu' oder 'Zu Bearbeiten'
*      ASSIGN COMPONENT 'INVOICE_STATUS' OF STRUCTURE <wa_out> TO <value>.
      IF <ls_out>-invoice_status NE '01' AND
         <ls_out>-invoice_status NE '02'.
        CONTINUE.
      ENDIF.

*      CLEAR lt_return[].
*      CLEAR: lv_proc_type, l_error.
*      ASSIGN COMPONENT 'INT_INV_DOC_NO' OF STRUCTURE <wa_out> TO <value>.
      CALL METHOD cl_inv_inv_remadv_doc=>process_document
        EXPORTING
          im_doc_number          = <ls_out>-int_inv_doc_no
        IMPORTING
          ex_return              = lt_return
          ex_exit_process_type   = lv_proc_type
          ex_proc_error_occurred = lv_error
        EXCEPTIONS
          OTHERS                 = 1.
*   Icon für Prozesstatus setzen
      IF sy-subrc <> 0.
        <ls_out>-process_state = icon_led_red.
      ELSE.
        <ls_out>-process_state = icon_execute_object.
      ENDIF.
*      ASSIGN COMPONENT 'INT_INV_DOC_NO' OF STRUCTURE <wa_out> TO <value>.

      SELECT SINGLE invoice_status, inv_doc_status
        FROM tinv_inv_head
       INNER JOIN tinv_inv_doc
               ON tinv_inv_head~int_inv_no = tinv_inv_doc~int_inv_doc_no
        INTO ( @<ls_out>-invoice_status, @<ls_out>-inv_doc_status )
       WHERE tinv_inv_doc~int_inv_doc_no = @<ls_out>-int_inv_doc_no.

      MODIFY mrt_out_table->* FROM <ls_out>
                       TRANSPORTING invoice_status inv_doc_status
                       WHERE int_inv_doc_no = <ls_out>-int_inv_doc_no.

      lv_old_doc_no = <ls_out>-int_inv_doc_no.

*      LOOP AT it_out_memi ASSIGNING <fs_wa_out_memi> WHERE int_inv_doc_no EQ p_int_inv_docno.
*
*        CHECK <fs_wa_out_memi> IS ASSIGNED.
*
*        MOVE invoice_status   TO <fs_wa_out_memi>-invoice_status.
*        MOVE inv_doc_status   TO <fs_wa_out_memi>-inv_doc_status.
**        <fs_wa_out_memi>-process_state = p_icon.
**   Daten in interne Tabelle für Ausgabe schreiben
*        MODIFY it_out_memi FROM <fs_wa_out_memi>.
*
*      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.


  METHOD send_mail.

* Klasse für Mailversand instanzieren
    DATA lo_sendmail TYPE REF TO /adz/cl_inv_send_mail.
    CREATE OBJECT lo_sendmail.

* Klasse für Kontakt instanzieren
    DATA lo_bcontact TYPE REF TO /adz/cl_inv_bc_contact.
    CREATE OBJECT lo_bcontact.

    DATA: BEGIN OF s_cont_data,
            gpart           TYPE but000-partner,
            vkont           TYPE fkkvkp-vkont,                 "Nuss 08.02.2018
            int_inv_doc_no  TYPE tinv_inv_doc-int_inv_doc_no,
            int_inv_line_no TYPE inv_int_inv_line_no,
          END OF s_cont_data.

    DATA: lt_cont       LIKE STANDARD TABLE OF s_cont_data,
          ls_cont       LIKE s_cont_data,
          lv_b_selected TYPE boolean.

    DATA: lv_int_inv_doc_no TYPE tinv_inv_doc-int_inv_doc_no.
*    IF p_invtp = '2'.
*      LOOP AT it_out_memi INTO <ls_out>.

*   Zeile muss Markiert sein
*    check wa_out-xselp = 'X'.
*        CHECK <ls_out>-sel IS NOT INITIAL.
*        lv_b_selected = abap_true.

    LOOP AT mrt_out_table->* ASSIGNING FIELD-SYMBOL(<ls_out>) WHERE sel = abap_true.

      lo_sendmail->set_content( EXPORTING iv_invoice_date   = <ls_out>-invoice_date
                                          iv_ext_invoice_no = <ls_out>-ext_invoice_no
                                          iv_crossref_no    = <ls_out>-own_invoice_no
                                          iv_rstgr          = <ls_out>-rstgr
                                          iv_text           = <ls_out>-text
**                                          iv_ext_ui         = <ls_out>-ext_ui                "Nuss 10.2017 Bis 01.02.2018
**                                          iv_ext_ui         = <ls_out>-ext_ui_melo            "Nuss 10.2017 Bis 01.02.2018
                                          iv_ext_ui          = <ls_out>-ext_ui                      "Nuss 01.02.2018
                                          iv_ext_ui_me       = <ls_out>-ext_ui_melo                 "Nuss 01.02.2018
                                          iv_free_text5     = <ls_out>-free_text5 ).

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = <ls_out>-int_inv_doc_no
        IMPORTING
          output = lv_int_inv_doc_no.

      ls_cont-int_inv_doc_no = <ls_out>-int_inv_doc_no.
      ls_cont-gpart = COND #( WHEN  <ls_out>-invoice_type = /adz/if_remadv_constants=>mc_invoice_type_memi THEN  <ls_out>-suppl_bupa
                              ELSE  <ls_out>-gpart ).
      ls_cont-vkont = SWITCH #( <ls_out>-invoice_type
                                WHEN /adz/if_remadv_constants=>mc_invoice_type_nn
                                 OR  /adz/if_remadv_constants=>mc_invoice_type_mgv    THEN   <ls_out>-vkont
                                WHEN /adz/if_remadv_constants=>mc_invoice_type_msb    THEN   <ls_out>-vkont_msb
                                ELSE '' ).
      ls_cont-int_inv_line_no = <ls_out>-int_inv_line_no.

      APPEND ls_cont TO lt_cont.
      CLEAR ls_cont.
    ENDLOOP.
*    ELSEIF p_invtp = 1.
*      LOOP AT it_out INTO wa_out.
*
**   Zeile muss Markiert sein
**    check wa_out-xselp = 'X'.
*        CHECK wa_out-sel IS NOT INITIAL.
*        lv_b_selected = abap_true.
*
*        lo_sendmail->set_content( EXPORTING iv_invoice_date   = wa_out-invoice_date
*                                            iv_ext_invoice_no = wa_out-ext_invoice_no
*                                            iv_crossref_no    = wa_out-own_invoice_no
*                                            iv_rstgr          = wa_out-rstgr
*                                            iv_text           = wa_out-text
**                                          iv_ext_ui         = wa_out-ext_ui               "Nuss 10.2017 bis 01.02.2018
**                                          iv_ext_ui         = wa_out-ext_ui_melo           "Nuss 10.2017 bis 01.02.2018
*                                            iv_ext_ui          = wa_out-ext_ui               "Nuss 01.02.2018
*                                            iv_ext_ui_me       = wa_out-ext_ui_melo          "Nuss 01.02.2018
*                                            iv_free_text5     = wa_out-free_text5 ).
*
*        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*          EXPORTING
*            input  = wa_out-int_inv_doc_no
*          IMPORTING
*            output = lv_int_inv_doc_no.
*
*        ls_cont-int_inv_doc_no = wa_out-int_inv_doc_no.
*        ls_cont-gpart = wa_out-gpart.
*        ls_cont-vkont = wa_out-vkont.                       "Nuss 08.02.2018
*        ls_cont-int_inv_line_no = wa_out-int_inv_line_no.
*
*        APPEND ls_cont TO lt_cont.
*
*      ENDLOOP.
*    ELSEIF p_invtp = 3.
*      LOOP AT it_out_mgv INTO wa_out_mgv.
*
**   Zeile muss Markiert sein
**    check wa_out-xselp = 'X'.
*        CHECK wa_out_mgv-sel IS NOT INITIAL.
*        lv_b_selected = abap_true.
*
*        lo_sendmail->set_content( EXPORTING iv_invoice_date   = wa_out_mgv-invoice_date
*                                            iv_ext_invoice_no = wa_out_mgv-ext_invoice_no
*                                            iv_crossref_no    = wa_out_mgv-own_invoice_no
*                                            iv_rstgr          = wa_out_mgv-rstgr
*                                            iv_text           = wa_out_mgv-text
***                                          iv_ext_ui         = wa_out_mgv-ext_ui             "Nuss 10.2017 bis 01.02.2018
**                                          iv_ext_ui         = wa_out_mgv-ext_ui_melo         "Nuss 10.2017 bis 01.02.2018
*                                            iv_ext_ui          = wa_out_mgv-ext_ui              "Nuss 01.02.2018
*                                            iv_ext_ui_me       = wa_out_mgv-ext_ui_melo         "Nuss 01.02.2018
*                                            iv_free_text5     = wa_out_mgv-free_text5 ).
*
*        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*          EXPORTING
*            input  = wa_out_mgv-int_inv_doc_no
*          IMPORTING
*            output = lv_int_inv_doc_no.
*
*        ls_cont-int_inv_doc_no = wa_out_mgv-int_inv_doc_no.
*        ls_cont-gpart = wa_out_mgv-gpart.
*        ls_cont-vkont = wa_out_mgv-vkont.                           "Nuss 08.02.2018
*        ls_cont-int_inv_line_no = wa_out_mgv-int_inv_line_no.
*
*        APPEND ls_cont TO lt_cont.
*
*      ENDLOOP.
** --> Nuss 09.2018
*    ELSEIF p_invtp = 4.
*      LOOP AT it_out_msb INTO wa_out_msb.
*
**   Zeile muss Markiert sein
**    check wa_out-xselp = 'X'.
*        CHECK wa_out_msb-sel IS NOT INITIAL.
*        lv_b_selected = abap_true.
*
*        lo_sendmail->set_content( EXPORTING iv_invoice_date   = wa_out_msb-invoice_date
*                                            iv_ext_invoice_no = wa_out_msb-ext_invoice_no
*                                            iv_crossref_no    = wa_out_msb-own_invoice_no
*                                            iv_rstgr          = wa_out_msb-rstgr
*                                            iv_text           = wa_out_msb-text
*                                            iv_ext_ui          = wa_out_msb-ext_ui
*                                            iv_ext_ui_me       = wa_out_msb-ext_ui_melo
*                                            iv_free_text5     = wa_out_msb-free_text5 ).
*
*        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*          EXPORTING
*            input  = wa_out_msb-int_inv_doc_no
*          IMPORTING
*            output = lv_int_inv_doc_no.
*
*        ls_cont-int_inv_doc_no = wa_out_msb-int_inv_doc_no.
*        ls_cont-gpart = wa_out_msb-gpart.
*        ls_cont-vkont = wa_out_msb-vkont.                       "Nuss 08.02.2018
*        ls_cont-int_inv_line_no = wa_out_msb-int_inv_line_no.
*
*        APPEND ls_cont TO lt_cont.
*
*      ENDLOOP.
** <-- Nuss 09.2018
*
*    ENDIF.

*    IF lv_b_selected EQ abap_false.
*      MESSAGE e000(e4) WITH 'Bitte selektieren Sie einen Datensatz.'.
*      EXIT.
*    ENDIF.

* Mail versenden
    SELECT COUNT( * ) FROM /adz/fi_remad WHERE negrem_option = 'MAILLOTUS'
                                           AND negrem_value = 'X'.
    IF sy-subrc <> 0.
      lo_sendmail->send_mail( ).
    ELSE.
      lo_sendmail->send_lotus_mail( ).
    ENDIF.


    DATA: lv_answer(1)     TYPE c,
          button_text1(16) TYPE c,
          icon_button1(30) TYPE c,
          button_text2(16) TYPE c,
          icon_button2(30) TYPE c.

    button_text1    = 'Ja'(021).
    button_text2    = 'Nein'(022).

    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
      EXPORTING
        defaultoption = 'Y'
        textline1     = 'Ist die E-Mail verschickt worden?'
        textline2     = ''
        titel         = 'E-Mail Versand'                     " Titelzeile des Dialogfensters
      IMPORTING
        answer        = lv_answer.

    IF sy-subrc EQ 0 AND lv_answer EQ 'J'.
      LOOP AT lt_cont INTO ls_cont.

        lo_bcontact->set_contact( EXPORTING iv_partner         = ls_cont-gpart
                                            iv_vkont           = ls_cont-vkont                     "Nuss 08.02.2018
                                            iv_int_inv_doc_no  = ls_cont-int_inv_doc_no
                                            iv_int_inv_line_no = ls_cont-int_inv_line_no ).
      ENDLOOP.
    ENDIF.

    DATA: icon(4) TYPE c.
    icon = icon_envelope_closed.
    IF sy-subrc <> 0 OR lv_answer ne 'J'.
      icon = icon_led_red.
    ENDIF.

    IF lv_answer EQ 'J'.
      LOOP AT mrt_out_table->* ASSIGNING <ls_out> WHERE sel = abap_true.
        <ls_out>-comm_state = icon.
        <ls_out>-cancel_state = icon_storno.

      ENDLOOP.


*      IF p_invtp = '2'.
*        LOOP AT it_out_memi INTO <ls_out>.
*
**     Zeile muss Markiert sein
*          CHECK <ls_out>-sel = 'X'.
*
**    Markierung initialisieren,
**    Mails sollen nicht mehrfach versendet werden
*          CLEAR <ls_out>-sel.
*
*          <ls_out>-comm_state = icon.
**      wa_out-cancel_state = ICON_STORNO.
*          MODIFY it_out_memi FROM <ls_out>.
*
*        ENDLOOP.
*      ELSEIF p_invtp = 1.
*        LOOP AT it_out INTO wa_out.
*
**     Zeile muss Markiert sein
*          CHECK wa_out-sel = 'X'.
*
**    Markierung initialisieren,
**    Mails sollen nicht mehrfach versendet werden
*          CLEAR wa_out-sel.
*
*          wa_out-comm_state = icon.
**      wa_out-cancel_state = ICON_STORNO.
*          MODIFY it_out FROM wa_out.
*
*        ENDLOOP.
*      ELSEIF p_invtp = 3.
*        LOOP AT it_out_mgv INTO wa_out_mgv.
*
**     Zeile muss Markiert sein
*          CHECK wa_out_mgv-sel = 'X'.
*
**    Markierung initialisieren,
**    Mails sollen nicht mehrfach versendet werden
*          CLEAR wa_out_mgv-sel.
*
*          wa_out_mgv-comm_state = icon.
**      wa_out-cancel_state = ICON_STORNO.
*          MODIFY it_out_mgv FROM wa_out_mgv.
*
*        ENDLOOP.
** --> Nuss 09.2018
*      ELSEIF p_invtp = 4.
*        LOOP AT it_out_msb INTO wa_out_msb.
*
**     Zeile muss Markiert sein
*          CHECK wa_out_msb-sel = 'X'.
*
**    Markierung initialisieren,
**    Mails sollen nicht mehrfach versendet werden
*          CLEAR wa_out_msb-sel.
*
*          wa_out_msb-comm_state = icon.
**      wa_out-cancel_state = ICON_STORNO.
*          MODIFY it_out_msb FROM wa_out_msb.
*
*        ENDLOOP.
** <-- Nuss 09.2018
    ENDIF.

*  ENDIF.
  ENDMETHOD.


  METHOD show_pdoc.

    READ TABLE mrt_out_table->* ASSIGNING FIELD-SYMBOL(<ls_out>) WITH KEY sel = abap_true.

    DATA(lv_selscreen) = /adz/cl_inv_customizing_data=>get_config_value(
                                            EXPORTING iv_option   = 'DATEX'
                                                      iv_category = 'BDC_END'
                                                      iv_field    = 'SELSCREEN'
                                                      iv_id       = '1' ).

    DATA(lv_transaction) = /adz/cl_inv_customizing_data=>get_config_value(
                                            EXPORTING iv_option   = iv_option
                                                      iv_category = 'BDC_END'
                                                      iv_field    = 'TRANSACTION'
                                                      iv_id       = '1' ).
    DATA lv_dxdudlow TYPE d.
    DATA lv_dxdud_delta TYPE d.
    /adz/cl_inv_customizing_data=>get_config_value( EXPORTING  iv_option   = 'DATEX'
                                                                 iv_category = 'BDC_END'
                                                                 iv_field    = 'DXDUDLOW'
                                                                 iv_id       = '1'
                                                       RECEIVING rv_value    = lv_dxdud_delta  ).
    DATA : lv_no_date TYPE c, lv_no_max TYPE c.
    /adz/cl_inv_customizing_data=>get_config_value( EXPORTING iv_option   = 'DATEX'
                                                                iv_category = 'BDC_END'
                                                                iv_field    = 'NO_MAX'
                                                                iv_id       = '1'
                                                      RECEIVING rv_value = lv_no_max ).

    /adz/cl_inv_customizing_data=>get_config_value( EXPORTING iv_option   = 'DATEX'
                                                                iv_category = 'BDC_END'
                                                                iv_field    = 'NO_DATE'
                                                                iv_id       = '1'
                                                      RECEIVING rv_value = lv_no_date ).

    lv_dxdudlow = sy-datum - lv_dxdud_delta.

    IF lv_transaction IS INITIAL.
      MESSAGE i000(e4) WITH 'Für den Aufruf zur Prozessierung des Belegs wurde keine Transaktion hinterlegt.'
      DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.

*    ASSIGN COMPONENT 'EXT_UI' OF STRUCTURE <wa_out> TO <value>.
    SELECT COUNT(*) FROM /adz/fi_remad
                   WHERE negrem_option = 'DATEX'
                     AND negrem_field = 'COMMONLA'
                     AND negrem_value = 'X'.
    IF sy-subrc = 0 AND iv_option = 'PDOCMON' .
      SUBMIT (lv_transaction)
        WITH so_extui-low = <ls_out>-ext_ui
        WITH p_no_max = lv_no_max
         AND RETURN.
    ELSE.
      IF lv_selscreen EQ abap_false.
        SUBMIT (lv_transaction)
          WITH se_extui-low  = <ls_out>-ext_ui
          WITH se_dxdud-low  = lv_dxdudlow
          WITH se_dxdud-high = sy-datum
          WITH p_nodate      = lv_no_date
          WITH p_no_max      = lv_no_max
          VIA SELECTION-SCREEN                 "Nuss 10.2017 Melo/Malo
        AND RETURN.
      ELSE.
        SUBMIT (lv_transaction)
          WITH se_extui-low  = <ls_out>-ext_ui
          WITH se_dxdud-low  = lv_dxdudlow
          WITH se_dxdud-high = sy-datum
          WITH p_nodate      = lv_no_date
          WITH p_no_max      = lv_no_max
          VIA SELECTION-SCREEN
          AND RETURN.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD show_swt.

    READ TABLE mrt_out_table->* ASSIGNING FIELD-SYMBOL(<ls_out>) WITH KEY sel = abap_true.

    DATA(lv_selscreen) = /adz/cl_inv_customizing_data=>get_config_value(
                                          EXPORTING iv_option   = 'SWTMON'
                                                    iv_category = 'BDC_END'
                                                    iv_field    = 'SELSCREEN'
                                                    iv_id       = '1'         ).

    DATA(lv_transaction) = /adz/cl_inv_customizing_data=>get_config_value(
                                          EXPORTING iv_option   = 'SWTMON'
                                                    iv_category = 'BDC_END'
                                                    iv_field    = 'TRANSACTION'
                                                    iv_id       = '1'        ).

    IF lv_transaction IS INITIAL.
      MESSAGE i000(e4) WITH 'Für den Aufruf der Wechselbeleganzeige wurde keine Transaktion hinterlegt.'
      DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.

*    ASSIGN COMPONENT 'EXT_UI' OF STRUCTURE <wa_out> TO <value>.
    IF lv_selscreen EQ abap_false.
      SUBMIT (lv_transaction)
        WITH so_extui-low = <ls_out>-ext_ui
         AND RETURN.
    ELSE.
      SUBMIT (lv_transaction)
        WITH so_extui-low = <ls_out>-ext_ui
        VIA SELECTION-SCREEN
        AND RETURN.
    ENDIF.

  ENDMETHOD.


  METHOD show_text.
    SELECT * FROM /adz/remtext INTO TABLE @DATA(lt_texte) WHERE int_inv_doc_nr = @iv_doc_no.

    DATA lt_fieldcat_ext TYPE TABLE OF slis_fieldcat_alv.

    lt_fieldcat_ext = VALUE #(
      ( " Kennung
        fieldname = 'INT_INV_DOC_NR'   ref_tabname = '/ADZ/REMTEXT' )
      ( " AB
        fieldname = 'DATUM'            ref_tabname = '/ADZ/REMTEXT' )
      (  " BIS
        fieldname = 'UNAME'            ref_tabname = '/ADZ/REMTEXT' )
      (  " Menge
        fieldname = 'ACTION'           ref_tabname = '/ADZ/REMTEXT' )
      (  "  Text
        fieldname = 'TEXT'             ref_tabname = '/ADZ/REMTEXT' )
    ).
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
  ENDMETHOD.


  METHOD write_note.

    DATA: title              TYPE text80,
          text1              TYPE text132,
          text2              TYPE text132,
          text255            TYPE text255,
          anzahl_sel         TYPE anzahl,
*          ls_out             LIKE  wa_out,
*          ls_out_memi        LIKE  wa_out_memi,
*          ls_out_mgv         LIKE  wa_out_mgv,
*          ls_out_msb         LIKE  wa_out_msb,          "Nuss 09.2018
          line_no            TYPE i,
*          lt_invtext         TYPE TABLE OF /adz/remtext,
*          ls_invtext         TYPE /adz/remtext,
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

    LOOP AT mrt_out_table->* ASSIGNING FIELD-SYMBOL(<ls_out>) WHERE sel = abap_true..
      APPEND <ls_out>-int_inv_doc_no TO lt_int_doc_no.
    ENDLOOP.

*    IF p_invtp = '2'.
*      LOOP AT it_out_memi INTO ls_out_memi WHERE sel = 'X'.
*        APPEND ls_out_memi-int_inv_doc_no TO lt_int_doc_no.
*      ENDLOOP.
*      IF sy-subrc <> 0.
*        lv_no_row = 'X'.
*      ENDIF.
*      CLEAR ls_invtext.
*    ELSEIF p_invtp = 1.
*      LOOP AT it_out INTO ls_out WHERE sel = 'X'.
*        APPEND ls_out-int_inv_doc_no TO lt_int_doc_no.
*      ENDLOOP.
*      IF sy-subrc <> 0.
*        lv_no_row = 'X'.
*      ENDIF.
*      CLEAR ls_invtext.
*    ELSEIF p_invtp = 3.
*      LOOP AT it_out_mgv INTO ls_out_mgv WHERE sel = 'X'.
*        APPEND ls_out_mgv-int_inv_doc_no TO lt_int_doc_no.
*      ENDLOOP.
*      IF sy-subrc <> 0.
*        lv_no_row = 'X'.
*      ENDIF.
*      CLEAR ls_invtext.
** --> Nuss 09.2018
*    ELSEIF p_invtp = 4.
*      LOOP AT it_out_msb INTO ls_out_msb WHERE sel = 'X'.
*        APPEND ls_out_msb-int_inv_doc_no TO lt_int_doc_no.
*      ENDLOOP.
*      IF sy-subrc <> 0.
*        lv_no_row = 'X'.
*      ENDIF.
*      CLEAR ls_invtext.
** <-- Nuss 09.2018
*    ENDIF.
*
*    IF lv_no_row = 'X'.
*      MESSAGE 'Bitte mindestens eine Zeile markieren.' TYPE 'I' DISPLAY LIKE 'E' .
*    ELSE.
    CALL FUNCTION '/ADZ/REMADV_BEMERKUNG_ANL'
      EXPORTING
        int_inv_doc_no = lt_int_doc_no
* IMPORTING
*       OK_CODE        =
      .


*    DATA lr_out LIKE REF TO wa_out.
*    DATA lr_out_memi LIKE REF TO wa_out_memi.
*    DATA lr_out_mgv LIKE REF TO wa_out_mgv.
*    DATA lr_out_msb LIKE REF TO wa_out_msb.              "Nuss 09.2018
*    IF p_invtp = 1.
    LOOP AT lt_int_doc_no INTO lv_int_doc_no.
      READ TABLE mrt_out_table->* ASSIGNING <ls_out> WITH KEY int_inv_doc_no = lv_int_doc_no.
      IF sy-subrc = 0.
        <ls_out>-text_vorhanden = 'X'.
      ENDIF.
    ENDLOOP.
*    ELSEIF p_invtp = 2.
*      LOOP AT lt_int_doc_no INTO lv_int_doc_no.
*        READ TABLE it_out_memi REFERENCE INTO lr_out_memi WITH KEY int_inv_doc_no = lv_int_doc_no.
*        IF sy-subrc = 0.
*          lr_out_memi->text_vorhanden = 'X'.
*        ENDIF.
*      ENDLOOP.
*    ELSEIF p_invtp = 3.
*      LOOP AT lt_int_doc_no INTO lv_int_doc_no.
*        READ TABLE it_out_mgv REFERENCE INTO lr_out_mgv WITH KEY int_inv_doc_no = lv_int_doc_no.
*        IF sy-subrc = 0.
*          lr_out_mgv->text_vorhanden = 'X'.
*        ENDIF.
*      ENDLOOP.
**  --> Nuss 09.2018
*    ELSEIF p_invtp = 4.
*      LOOP AT lt_int_doc_no INTO lv_int_doc_no.
*        READ TABLE it_out_msb REFERENCE INTO lr_out_msb WITH KEY int_inv_doc_no = lv_int_doc_no.
*        IF sy-subrc = 0.
*          lr_out_msb->text_vorhanden = 'X'.
*        ENDIF.
*      ENDLOOP.
** <-- Nuss 09.2018
*    ENDIF.
*  ENDIF.

  ENDMETHOD.
ENDCLASS.
