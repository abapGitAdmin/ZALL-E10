FUNCTION /adesso/inv_manager_price .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(X_CONTROL) TYPE  INV_CONTROL_DATA
*"  EXPORTING
*"     REFERENCE(Y_RETURN) TYPE  TTINV_LOG_MSGBODY
*"     REFERENCE(Y_STATUS) TYPE  INV_STATUS_LINE
*"     REFERENCE(Y_CHANGED) TYPE  INV_KENNZX
*"  CHANGING
*"     REFERENCE(XY_PROCESS_DATA) TYPE  TTINV_PROCESS_DATA
*"----------------------------------------------------------------------
*  check meterread data in billing period
************************************************************************

* MessageID
  CONSTANTS: co_z_msgid           TYPE sy-msgid VALUE '/ADESSO/INV_MANAGER'.

  CONSTANTS: co_chcktype_mrreason  TYPE inv_in_chck_type VALUE '018'.
  CONSTANTS: co_chcktype_servid    TYPE inv_in_chck_type VALUE '019'.
  CLEAR: y_return, it_inv_return[]..

  TYPES : BEGIN OF ts_simdaten,
            belzeile TYPE erchz-belzeile,
            belzart  TYPE erchz-belzart,
            ab       TYPE erchz-ab,
            bis      TYPE erchz-bis,
            menge    TYPE erchz-i_abrmenge,
            nebtr    TYPE erchz-nettobtr,
            preisbtr TYPE erchz-preisbtr,
            hvorg    TYPE hvorg_kk,
            tvorg    TYPE tvorg_kk,
          END OF ts_simdaten.


  DATA:
    ls_simdaten        TYPE ts_simdaten,
    ls_simdaten_pruef  TYPE ts_simdaten,
    lt_simdaten        TYPE TABLE OF ts_simdaten,
    lv_id_inv          TYPE tinv_inv_head-int_inv_no,
    ls_inv_head        TYPE tinv_inv_head,
    lt_inv_doc         TYPE TABLE OF tinv_inv_doc,
    ls_inv_doc         TYPE tinv_inv_doc,
    ls_inv_line_i      TYPE tinv_inv_line_b,
    lv_hvorg           TYPE hvorg_kk,
    lv_tvorg           TYPE tvorg_kk,
    lv_belzart         TYPE erchz-belzart,
    ls_erchz           TYPE erchz,
    lv_kofiz           TYPE ever-kofiz,
    lv_price_text      TYPE string,
    lv_price_text2     TYPE string,
    lv_anlage          TYPE anlage,
    lv_fremd           TYPE boolean,
    lv_gefunden        TYPE c,
    ls_ever            TYPE  ever,
    lv_sparte          TYPE sparte,
    lv_adsparte        TYPE /adesso/sparte,
    lv_pruefart        TYPE /adesso/pruefart,
    ls_tinv_inv_docref TYPE tinv_inv_docref,
    lv_ok              TYPE abap_bool VALUE co_true,
    lt_inv_line_i      TYPE TABLE OF tinv_inv_line_b,
    lt_inv_extid       TYPE TABLE OF tinv_inv_extid,
    ls_inv_extid       TYPE  tinv_inv_extid,
    lv_vertrag         TYPE ever-vertrag,
    ls_bill_doc        TYPE isu2a_bill_doc,
    val1               TYPE sy-msgv1,
    lv_einzelp         TYPE string,
    lv_intui           TYPE int_ui,
    lv_anz_instln      TYPE i,
    ls_art_cust        TYPE /adesso/art_cust,
    lv_abw_abs         TYPE int4,
    ls_eanl            TYPE eanl,
    lv_abw_proz        TYPE int1,
    ls_eanlh           TYPE eanlh,
    lt_istln           TYPE iederegpodinstln,
    ls_istln           TYPE LINE OF iederegpodinstln,
    lv_text            TYPE edereg_sidprot-text,
    lv_artikel_text    TYPE edereg_sidprot-text,
    lv_billingrunno    TYPE erch-billingrunno.

  DATA:
    lt_enet_preis TYPE /adesso/enet_preis_artikel_t,
    lt_inv_preis  TYPE /adesso/enet_preis_artikel_t,
    ls_enet_preis TYPE /adesso/preis_artikel_s.


  FIELD-SYMBOLS:
    <y_process> TYPE inv_process_data,
    <head>      TYPE tinv_inv_head,
    <doc>       TYPE tinv_inv_doc,
    <inv_doc>   TYPE STANDARD TABLE,
    <inv_extid> TYPE STANDARD TABLE,
    <line_b>    TYPE STANDARD TABLE,
    <instl>     TYPE euiinstln,
    <eabl>      TYPE eabl.

  LOOP AT xy_process_data ASSIGNING <y_process>.
    ASSIGN <y_process>-inv_head TO <head>.
    ASSIGN <y_process>-inv_line_b TO <line_b>.
    ASSIGN <y_process>-inv_doc TO <inv_doc>.
    ASSIGN <y_process>-inv_extid TO <inv_extid>.

    ls_inv_head = <head>.
    APPEND LINES OF <inv_extid> TO lt_inv_extid.
    APPEND LINES OF <line_b> TO lt_inv_line_i .
    APPEND LINES OF <inv_doc> TO lt_inv_doc .

    "Im doc und extid gibt es nur eine Zeile muss eventuell erwietert werden
    READ TABLE lt_inv_doc INTO ls_inv_doc INDEX 1.
    READ TABLE lt_inv_extid INTO ls_inv_extid INDEX 1.

    lv_intui = ls_inv_doc-int_ident.
    CALL FUNCTION 'ISU_GET_UIINSTLN_FROM_BUFFER'
      EXPORTING
        x_int_ui      = lv_intui
      IMPORTING
        y_iinstln     = lt_istln
      EXCEPTIONS
        general_fault = 1
        OTHERS        = 2.
    IF sy-subrc <> 0.
    ENDIF.

    DESCRIBE TABLE lt_istln LINES lv_anz_instln.
    IF lv_anz_instln > 1.
      LOOP AT lt_istln INTO ls_istln.
        IF  ls_istln-service <> 'SLIF' .
          DELETE lt_istln INDEX sy-tabix .
        ENDIF.
      ENDLOOP.
    ENDIF    .
    READ TABLE lt_istln INTO ls_istln INDEX 1.
    lv_anlage = ls_istln-anlage.

    CALL FUNCTION 'ISU_DB_EVER_SELECT_ANLAGE1'
      EXPORTING
        x_instln     = lv_anlage
        x_keydate    = ls_inv_doc-invperiod_start
      IMPORTING
        y_ever       = ls_ever
      EXCEPTIONS
        not_found    = 1
        system_error = 2
        OTHERS       = 3.
    IF sy-subrc <> 0.
    ENDIF.


    lv_vertrag = ls_ever-vertrag.
    lv_kofiz = ls_ever-kofiz.

    SELECT * FROM eanlh INTO ls_eanlh
        WHERE anlage = lv_anlage
          AND bis GE ls_inv_doc-invperiod_end.
      EXIT.
    ENDSELECT.

    SELECT SINGLE * FROM eanl INTO ls_eanl WHERE anlage = lv_anlage.
    IF ls_eanlh-aklasse = '02'. "Sonderkunden
      lv_pruefart = '1'.
    ELSE.
      lv_pruefart = '0'.
    ENDIF.

    "SELECT SINGLE pruefart FROM /adesso/ec_tarif INTO lv_pruefart WHERE tarif = ls_eanlh-tariftyp.

    break struck-f.
    "Simulation
    IF lv_vertrag IS NOT INITIAL AND lv_pruefart = '0' AND 1 = 2."Simulation erst mal ausgebaut
      PERFORM number_get CHANGING lv_billingrunno.
      CALL FUNCTION 'ISU_SIMULATION_PERIOD_BILL'
        EXPORTING
          x_vertrag        = lv_vertrag
          x_begabrpe       = ls_inv_doc-invperiod_start
          x_endabrpe       = ls_inv_doc-invperiod_end
          x_billingrunno   = lv_billingrunno
*         x_simulation     = co_no_backbill
          x_no_success_msg = ' '
          x_no_update      = ' '
        IMPORTING
          y_bill_doc       = ls_bill_doc
        EXCEPTIONS
          general_fault    = 1
          error_message    = 3                              "##20131203
          OTHERS           = 2.
      IF sy-subrc <> 0 AND 1 = 2."erstmal raus, da performance schwach

        CALL FUNCTION 'ISU_INV_ISU_BILL_SIM_GRID'
          EXPORTING
            x_contract_supply = lv_vertrag
            x_simfrom         = ls_inv_doc-invperiod_start
            x_simto           = ls_inv_doc-invperiod_end
*           X_NO_UPDATE       = 'X'
*           X_CREATE_MSG_OBJECT       = 'X'
          IMPORTING
            y_bill_doc        = ls_bill_doc
          EXCEPTIONS
            general_fault     = 1
            OTHERS            = 2.
        IF sy-subrc <> 0.
          lv_ok = co_false.
          msg_to_inv_return space co_msg_error co_z_msgid '029'
            ls_inv_line_i-int_inv_doc_no space space space .

        ENDIF.

      ENDIF.

      SELECT COUNT(*) FROM tinv_inv_docref "INTO ls_tinv_inv_docref
        WHERE int_inv_doc_no = ls_inv_doc-int_inv_doc_no
        AND   int_inv_no     = ls_inv_doc-int_inv_no
        AND   inbound_ref_type = 4.

      IF sy-subrc = 0.
        DELETE FROM tinv_inv_docref
        WHERE int_inv_doc_no = ls_inv_doc-int_inv_doc_no
        AND   int_inv_no     = ls_inv_doc-int_inv_no
        AND   inbound_ref_type = 4.
        COMMIT WORK.
      ENDIF.

      ls_tinv_inv_docref-int_inv_doc_no = ls_inv_doc-int_inv_doc_no.
      ls_tinv_inv_docref-int_inv_no     = ls_inv_doc-int_inv_no.
      ls_tinv_inv_docref-inbound_ref_type = 4.
      ls_tinv_inv_docref-inbound_ref_no = 1.
      ls_tinv_inv_docref-inbound_ref = ls_bill_doc-erch-belnr.
      ls_tinv_inv_docref-mandt = sy-mandt.

      INSERT INTO tinv_inv_docref VALUES ls_tinv_inv_docref.
      COMMIT  WORK.
      IF sy-subrc <> 0.
        break struck-f.
      ENDIF.

      DATA ls_preise_sim TYPE /adesso/preis_artikel_s.
      DATA lt_preise_sim TYPE TABLE OF /adesso/preis_artikel_s.
      DATA lv_richtiger_preis TYPE c.
      DATA lv_falscher_preis TYPE /adesso/preis_artikel_s-preis.

      "Wichtige Daten aus dem Simulierten Beleg in hübschere Strukur schreiben
      LOOP AT ls_bill_doc-ierchz INTO ls_erchz.
        IF ls_erchz-nettobtr <> 0.
          MOVE ls_erchz-belzeile      TO ls_simdaten-belzeile.
          MOVE ls_erchz-belzart       TO ls_simdaten-belzart.
          MOVE ls_erchz-ab            TO ls_simdaten-ab.
          MOVE ls_erchz-bis           TO ls_simdaten-bis.
          MOVE ls_erchz-i_abrmenge    TO ls_simdaten-menge.
          MOVE ls_erchz-nettobtr      TO ls_simdaten-nebtr.
          MOVE ls_erchz-preisbtr      TO ls_simdaten-preisbtr.
          MOVE ls_erchz-tvorg         TO ls_simdaten-tvorg.
          MOVE ls_bill_doc-erch-hvorg TO ls_simdaten-hvorg.

          APPEND ls_simdaten TO lt_simdaten.
        ENDIF.
      ENDLOOP.
      break struck-f.
      LOOP AT lt_inv_line_i INTO ls_inv_line_i WHERE price IS NOT INITIAL.
        CLEAR: ls_simdaten , ls_simdaten_pruef.
        SELECT  belzart FROM /adesso/art_cust INTO lv_belzart WHERE art_nr = ls_inv_line_i-product_id.
          IF sy-subrc = 0.
            LOOP AT lt_simdaten INTO ls_simdaten WHERE belzart+1 = lv_belzart+1. "AND ab = ls_inv_line_i-date_from .
              ls_preise_sim-ab = ls_simdaten-ab.
              ls_preise_sim-bis = ls_simdaten-bis.
              ls_preise_sim-preis = ls_simdaten-preisbtr.
              ls_preise_sim-artikelnr = ls_inv_line_i-product_id.
              APPEND ls_preise_sim TO lt_preise_sim.
            ENDLOOP.
          ENDIF.
        ENDSELECT.

      ENDLOOP.

      LOOP AT lt_inv_line_i INTO ls_inv_line_i WHERE price IS NOT INITIAL.
        lv_artikel_text = ls_inv_line_i-product_id.
        SELECT SINGLE adsparte FROM /adesso/ec_spart INTO lv_sparte WHERE sparte = ls_ever-sparte.
        SELECT SINGLE * FROM /adesso/art_cust INTO ls_art_cust WHERE art_nr = ls_inv_line_i-product_id AND sparte = lv_sparte.
        IF sy-subrc = 0.
          IF ls_art_cust-max_abw_cent_p > 0.
            lv_abw_abs = ls_art_cust-max_abw_cent_p.
          ENDIF.
          IF ls_art_cust-max_abw_proz_p > 0.
            lv_abw_proz = ls_art_cust-max_abw_proz_p.
          ENDIF.
        ENDIF.
        CLEAR lv_richtiger_preis.

        LOOP AT lt_preise_sim INTO ls_preise_sim WHERE artikelnr = ls_inv_line_i-product_id AND ab = ls_inv_line_i-date_from.
          IF lv_richtiger_preis = 'X'.
            CONTINUE.
          ENDIF.
          IF ls_preise_sim-preis IS NOT INITIAL.
            IF  abs( ls_preise_sim-preis - ls_inv_line_i-price ) <= lv_abw_abs
                OR ( abs( ls_preise_sim-preis - ls_inv_line_i-price ) / ls_inv_line_i-price ) * 100  <= lv_abw_proz.
              lv_price_text = ls_inv_line_i-price.
              lv_price_text2 = ls_preise_sim-preis.
              SHIFT: lv_price_text RIGHT DELETING TRAILING '0' , lv_price_text2 RIGHT DELETING TRAILING '0'.
              CONDENSE: lv_price_text , lv_price_text2.

              msg_to_inv_return space co_msg_success co_z_msgid '023'
                                lv_artikel_text  lv_price_text lv_price_text2 space.
              lv_richtiger_preis = 'X'.

            ELSEIF abs( ls_preise_sim-preis * 12 - ls_inv_line_i-price ) <= lv_abw_abs
                OR ( abs( ls_preise_sim-preis * 12 - ls_inv_line_i-price ) / ls_inv_line_i-price ) * 100  <= lv_abw_proz.

              lv_price_text = ls_inv_line_i-price.
              lv_price_text2 = ls_preise_sim-preis.
              SHIFT: lv_price_text RIGHT DELETING TRAILING '0' , lv_price_text2 RIGHT DELETING TRAILING '0'.
              CONDENSE: lv_price_text , lv_price_text2.

              msg_to_inv_return space co_msg_success co_z_msgid '023'
                                lv_artikel_text  lv_price_text lv_price_text2 space.
              lv_richtiger_preis = 'X'.

            ELSEIF abs( ls_preise_sim-preis / 12 - ls_inv_line_i-price ) <= lv_abw_abs
               OR ( abs( ls_preise_sim-preis / 12 - ls_inv_line_i-price ) / ls_inv_line_i-price ) * 100  <= lv_abw_proz.

              lv_price_text = ls_inv_line_i-price.
              lv_price_text2 = ls_preise_sim-preis.
              SHIFT: lv_price_text RIGHT DELETING TRAILING '0' , lv_price_text2 RIGHT DELETING TRAILING '0'.
              CONDENSE: lv_price_text , lv_price_text2.

              msg_to_inv_return space co_msg_success co_z_msgid '023'
                                lv_artikel_text  lv_price_text lv_price_text2 space.
              lv_richtiger_preis = 'X'.

            ELSEIF  lv_richtiger_preis = ' '.
              lv_falscher_preis = ls_preise_sim-preis.
            ENDIF.
          ENDIF.

        ENDLOOP.
        IF lv_richtiger_preis = ' '.

          lv_ok = co_false.
          lv_price_text = ls_inv_line_i-price.
          IF lv_falscher_preis IS NOT INITIAL.
            lv_price_text2 = lv_falscher_preis.
            SHIFT: lv_price_text RIGHT DELETING TRAILING '0' , lv_price_text2 RIGHT DELETING TRAILING '0'.
            " lv_einzelp = 'SIM: ' && ls_simdaten_pruef-preisbtr && ' INV: ' && ls_inv_line_i-price.
            CONDENSE: lv_price_text , lv_price_text2.
            msg_to_inv_return space co_msg_error co_z_msgid '021'
             lv_artikel_text lv_price_text lv_price_text2 space."lv_einzelp .

          ELSE.
            SHIFT: lv_price_text RIGHT DELETING TRAILING '0' , lv_price_text2 RIGHT DELETING TRAILING '0'.
            " lv_einzelp = 'SIM: ' && ls_simdaten_pruef-preisbtr && ' INV: ' && ls_inv_line_i-price.
            CONDENSE: lv_price_text , lv_price_text2.
            msg_to_inv_return space co_msg_error co_z_msgid '022'
             lv_artikel_text space space space."lv_einzelp .
          ENDIF.
        ENDIF.


      ENDLOOP.



    ELSEIF lv_vertrag IS INITIAL OR lv_pruefart = '1' OR 1 = 1."erstmal alles über ENET

      LOOP AT lt_inv_line_i INTO ls_inv_line_i.
        ls_enet_preis-artikelnr = ls_inv_line_i-product_id.
        ls_enet_preis-ab        = ls_inv_line_i-date_from.
        ls_enet_preis-bis       = ls_inv_line_i-date_to.
        ls_enet_preis-preis     = ls_inv_line_i-price.

        APPEND ls_enet_preis TO lt_inv_preis.

      ENDLOOP.
      READ TABLE lt_inv_preis INTO ls_enet_preis WITH KEY artikelnr = '9990001000532'."Abrechnungspreis
*      SELECT SINGLE sparte FROM ever INTO lv_sparte WHERE vertrag = lv_vertrag.
      SELECT SINGLE adsparte FROM /adesso/ec_spart INTO lv_adsparte WHERE sparte = ls_eanl-sparte.
      IF lv_adsparte = 'ST'.
        CALL FUNCTION '/ADESSO/ENET_GET_PRICES_ANLAGE'
          EXPORTING
            anlage         = lv_anlage
            abr_ab         = ls_inv_doc-invperiod_start
            abr_bis        = ls_inv_doc-invperiod_end
            abr_preis      = ls_enet_preis-preis
            int_inv_doc_no = ls_inv_line_i-int_inv_doc_no
          IMPORTING
            zaehlerfremd   = lv_fremd
          CHANGING
            artikel_preis  = lt_enet_preis.
      ELSEIF lv_adsparte = 'GA'.
        CALL FUNCTION '/ADESSO/ENET_GET_PREIS_ANL_GAS'
          EXPORTING
            anlage         = lv_anlage
            abr_ab         = ls_inv_doc-invperiod_start
            abr_bis        = ls_inv_doc-invperiod_end
            abr_preis      = ls_enet_preis-preis
            int_inv_doc_no = ls_inv_line_i-int_inv_doc_no
          IMPORTING
            zaehlerfremd   = lv_fremd
          CHANGING
            artikel_preis  = lt_enet_preis.

      ENDIF.
      IF lv_fremd = 'X'.
        msg_to_inv_return space co_msg_warning co_z_msgid '037'
                    space  space space space.
      ENDIF.
      IF lt_enet_preis IS NOT INITIAL.
        PERFORM preis_pruefung_enet USING  lt_inv_preis lt_enet_preis lv_adsparte ls_inv_doc-invperiod_start ls_inv_doc-invperiod_end.
      ENDIF.


    ELSE.

      "   MESSAGE 'kein Vertrag gefunden ' TYPE 'E'.

    ENDIF.

  ENDLOOP.

** success!
  IF lv_ok = co_true.
    val1 = ls_inv_doc-int_inv_doc_no.
    msg_to_inv_return space co_msg_success co_z_msgid '020'
                      val1 space space space.
    IF 1 = 2.
      MESSAGE s013(/adesso/inv_manager) WITH val1.
    ENDIF.
  ENDIF.

* Fill export table Y_RETURN
  y_return[] = it_inv_return[].
  break struck-f.
* Set status
  CALL FUNCTION 'ISU_DEREG_INV_COM_STATUS'
    EXPORTING
      x_return = y_return[]
    IMPORTING
      y_status = y_status.


ENDFUNCTION.
*&---------------------------------------------------------------------*
*&      Form  number_get
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->X_BILLINGRUNNO  text
*----------------------------------------------------------------------*
FORM number_get CHANGING x_billingrunno.
  DATA:   co_number_object LIKE inri-object VALUE 'ISU_BIRUN'.

* Abrechnungslaufnr bestimmen
  CALL FUNCTION 'ISU_NUMBER_GET'
    EXPORTING
      object                      = co_number_object
    IMPORTING
      number                      = x_billingrunno
    EXCEPTIONS
      no_range_number_found       = 1
      number_not_in_intervall     = 2
      interval_not_found          = 3
      quantity_is_0               = 4
      interval_te009_inconsistent = 5
      OTHERS                      = 6.
  IF sy-subrc = 0.
** Abrechnungslaufnr
*  MAC_MSG_PUT 'I169(AJ)' X_BILLINGRUNNO SPACE SPACE SPACE SPACE.
*  IF 1 = 2. MESSAGE I169(AJ) WITH SPACE. ENDIF.
  ELSEIF sy-subrc <> 0.
*   number check error
  ENDIF.

ENDFORM.                    "number_get

FORM preis_pruefung_enet USING ut_preise_inv TYPE /adesso/enet_preis_artikel_t  ut_preise_enet TYPE /adesso/enet_preis_artikel_t uv_sparte TYPE /adesso/sparte ab bis.
  DATA:  ls_enet_preis      TYPE /adesso/preis_artikel_s,
         lv_found           TYPE c,
         ls_inv_preis       TYPE /adesso/preis_artikel_s,
         lv_enet_preis      TYPE /adesso/enet_preis,
         ls_art_cust        TYPE /adesso/art_cust,
         lv_abw_abs         TYPE int4 VALUE 0,
         lv_artnr_text(100) TYPE c,
         lv_abw_proz        TYPE int1 VALUE 0,
         lv_preis_string    TYPE string,
         lv_preis_string2   TYPE string.

  CONSTANTS: co_z_msgid           TYPE sy-msgid VALUE '/ADESSO/INV_MANAGER'.

*  IF uv_sparte = 'GA'.
*      msg_to_inv_return space co_msg_warning co_z_msgid '038'
*                          space  space space space.
*  ENDIF.

  LOOP AT ut_preise_inv INTO ls_inv_preis WHERE ab >= ab AND bis <= bis .

    IF ls_inv_preis-artikelnr IS INITIAL.
      CONTINUE.
    ENDIF.

    SELECT SINGLE * FROM /adesso/art_cust INTO ls_art_cust WHERE art_nr = ls_inv_preis-artikelnr AND sparte = uv_sparte.
    IF sy-subrc = 0.
      lv_artnr_text = ls_art_cust-name.
      IF ls_art_cust-max_abw_cent_p > 0.
        lv_abw_abs = ls_art_cust-max_abw_cent_p.
      ENDIF.
      IF ls_art_cust-max_abw_proz_p > 0.
        lv_abw_proz = ls_art_cust-max_abw_proz_p.
      ENDIF.
    ENDIF.
    IF ls_inv_preis-preis = 0.
      msg_to_inv_return space co_msg_warning co_z_msgid '030'
                          lv_artnr_text  space space space.
      CONTINUE.
    ENDIF.
*    IF uv_sparte = 'GA'.
*
*      lv_preis_string = ls_inv_preis-preis.
*      SHIFT lv_preis_string LEFT DELETING LEADING ' '.
*      SHIFT lv_preis_string RIGHT DELETING TRAILING '0'.
*      lv_preis_string =' ' && lv_preis_string && ' '.
*      lv_preis_string2 = ls_enet_preis-preis.
*      SHIFT lv_preis_string2 LEFT DELETING LEADING ' '.
*      SHIFT lv_preis_string2 RIGHT DELETING TRAILING '0'.
*      lv_preis_string2 =' ' && lv_preis_string2 && ' '.
*      msg_to_inv_return space co_msg_success co_z_msgid '026'
*                          lv_artnr_text  lv_preis_string lv_preis_string2 space.
*
*
*    ELSE.
      LOOP AT ut_preise_enet INTO ls_enet_preis WHERE artikelnr = ls_inv_preis-artikelnr AND ab <= ls_inv_preis-ab AND bis => ls_inv_preis-ab.
        IF ls_enet_preis-preis <> 0.
          lv_enet_preis = ls_enet_preis-preis / 100.
        ENDIF.
        IF abs( ls_enet_preis-preis - ls_inv_preis-preis ) =< lv_abw_abs OR ( abs( ls_enet_preis-preis - ls_inv_preis-preis ) / abs( ls_inv_preis-preis ) ) * 100 =< lv_abw_proz.
          lv_preis_string = ls_inv_preis-preis.
          SHIFT lv_preis_string LEFT DELETING LEADING ' '.
          SHIFT lv_preis_string RIGHT DELETING TRAILING '0'.
          lv_preis_string =' ' && lv_preis_string && ' '.
          lv_preis_string2 = ls_enet_preis-preis.
          SHIFT lv_preis_string2 LEFT DELETING LEADING ' '.
          SHIFT lv_preis_string2 RIGHT DELETING TRAILING '0'.
          lv_preis_string2 =' ' && lv_preis_string2 && ' '.
          msg_to_inv_return space co_msg_success co_z_msgid '026'
                              lv_artnr_text  lv_preis_string lv_preis_string2 space.
          lv_found = 'X'.
          EXIT.
        ELSEIF abs( lv_enet_preis - ls_inv_preis-preis ) =< lv_abw_abs OR ( abs( lv_enet_preis - ls_inv_preis-preis ) / abs( ls_inv_preis-preis ) ) * 100 =< lv_abw_proz.
          lv_preis_string = ls_inv_preis-preis.
          SHIFT lv_preis_string LEFT DELETING LEADING ' '.
          SHIFT lv_preis_string RIGHT DELETING TRAILING '0'.
          lv_preis_string =' ' && lv_preis_string && ' '.
          lv_preis_string2 = ls_enet_preis-preis.
          SHIFT lv_preis_string2 LEFT DELETING LEADING ' '.
          SHIFT lv_preis_string2 RIGHT DELETING TRAILING '0'.
          lv_preis_string2 =' ' && lv_preis_string2 && ' '.
          msg_to_inv_return space co_msg_success co_z_msgid '026'
                              lv_artnr_text  lv_preis_string lv_preis_string2 space.
          lv_found = 'X'.
          EXIT.
        ELSEIF ls_inv_preis-preis = 0.
          msg_to_inv_return space co_msg_success co_z_msgid '028'
                         lv_artnr_text  space space space.
        ENDIF.

      ENDLOOP.
      IF lv_found <> 'X'.
        lv_preis_string = ls_inv_preis-preis.
        SHIFT lv_preis_string LEFT DELETING LEADING ' '.
        SHIFT lv_preis_string RIGHT DELETING TRAILING '0'.
        msg_to_inv_return space co_msg_error co_z_msgid '027'
                                    lv_artnr_text lv_preis_string space space.
      ENDIF.
      IF lv_found = ' '.

      ENDIF.
      CLEAR lv_found.
*    ENDIF.
  ENDLOOP.

ENDFORM.
