FUNCTION /adesso/inv_manager_quantity .
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

* --- field symbols
  FIELD-SYMBOLS:
    <y_process> TYPE inv_process_data,
    <head>      TYPE tinv_inv_head,
    <doc>       TYPE tinv_inv_doc,
    <inv_extid> TYPE tinv_inv_extid,
    <line_b>    TYPE tinv_inv_line_b,
    <instl>     TYPE euiinstln,
    <eabl>      TYPE eabl.

* Check parameter in SPA
  DATA: l_receiver TYPE e_deregspinitiator,
        l_sender   TYPE e_deregsppartner,
        l_mrreason LIKE eablg-ablesgr.

* check parameter
  DATA: lt_tinv_c_inchcka TYPE ttinv_c_inchcka,             "#EC NEEDED
        lt_tinv_c_inchckp TYPE ttinv_c_inchckp,             "#EC NEEDED
        lw_tinv_c_inchcka TYPE tinv_c_inchcka,              "#EC NEEDED
        lw_tinv_c_inchckp TYPE tinv_c_inchckp.

* Installations, meter reading documents, pod
  DATA: t_euiinstln   TYPE ieuiinstln,
        ls_eanl       TYPE eanl,
        lt_eabl       TYPE STANDARD TABLE OF eabl,
        ls_last_eabl  TYPE eabl,
        ls_check_eabl TYPE eabl,
        l_int_ui      TYPE int_ui,
        l_consmpt     TYPE i_abrmenge,
        l_sucsmpt     TYPE tinv_inv_line_b-quantity,
        l_sumblind    TYPE tinv_inv_line_b-quantity.

* ranges
  DATA: tr_anlage   TYPE STANDARD TABLE OF isu_ranges,
        tr_eabl     TYPE STANDARD TABLE OF isu_ranges,
        tr_mrreason TYPE STANDARD TABLE OF isu_ranges,
        tr_servid   TYPE STANDARD TABLE OF isu_ranges.

* work areas
  DATA: l_eservprov TYPE eservprov,
        lr_anlage   LIKE LINE OF tr_anlage,
        lr_eabl     LIKE LINE OF tr_eabl,
        lr_mrreason LIKE LINE OF tr_mrreason,
        lr_servid   LIKE LINE OF tr_servid.

* data
  DATA: l_lin      TYPE i,
        l_servprov TYPE service_prov,
        c_quantity TYPE reabld-zwstand,
        c_consumpt TYPE reabld-zwstand.

* Datenermittlung zur Lastgangmessung
  DATA : lv_count     TYPE e_maxcount,
         lt_tab       TYPE   ilogikzw_tab,
         ls_tab       TYPE   LINE OF ilogikzw_tab,
         lv_anlage    TYPE anlage,
         ls_euihead   TYPE euihead,
         ls_eproftime TYPE eproftime,
         ls_profile   TYPE eprofile.

  DATA: BEGIN OF s_data,
          int_ui          TYPE euitrans-int_ui,
          ext_ui          TYPE euitrans-ext_ui,
          f_status        TYPE c LENGTH 50,
          vertrag         TYPE eservice-vertrag,
          service_start   TYPE eservice-service_start,
          service_end     TYPE eservice-service_end,
          int_inv_doc_no  TYPE tinv_inv_extid-int_inv_doc_no,
          invoice_status  TYPE tinv_inv_head-invoice_status,
          int_receiver    TYPE tinv_inv_head-int_receiver,
          int_sender      TYPE tinv_inv_head-int_sender,
          sp_name         TYPE eservprovt-sp_name,
          created_on      TYPE tinv_inv_head-created_on,
          doc_type        TYPE tinv_inv_doc-doc_type,
          inv_doc_status  TYPE tinv_inv_doc-inv_doc_status,
          ext_invoice_no  TYPE tinv_inv_doc-ext_invoice_no,
          inv_bulk_ref    TYPE tinv_inv_doc-inv_bulk_ref,
          invperiod_start TYPE tinv_inv_doc-invperiod_start,
          invperiod_end   TYPE tinv_inv_doc-invperiod_end,
          date_of_payment TYPE tinv_inv_doc-date_of_payment,
          bukrs           TYPE tinv_inv_transf-bukrs,
          thbln_ext       TYPE tinv_inv_transf-thbln_ext,
          thprd           TYPE tinv_inv_transf-thprd,
          line_content    TYPE tinv_inv_transf-line_content,
          rstgr           TYPE tinv_inv_line_a-rstgr,
          anlage          TYPE ever-anlage,
          gpart           TYPE fkkvkp-gpart,
          f_last          TYPE c LENGTH 50,
          prof_value      TYPE eprofvalue-prof_value,
        END OF s_data.
  DATA: t_data LIKE TABLE OF s_data WITH HEADER LINE.

  DATA: s_from TYPE eedmdatefrom,
        s_to   TYPE eedmdateto.

  DATA: s_euihead   TYPE euihead,
        s_profileui TYPE LINE OF t_eedm_profile_from_ui,
        t_profileui TYPE t_eedm_profile_from_ui.

  DATA: xt_int_ui_tasks          TYPE t_eprofsel_blkno_appl,
        xs_int_ui_tasks          TYPE LINE OF t_eprofsel_blkno_appl,
        ls_eprofsel_blkno_appl03 TYPE LINE OF  t_eprofsel_blkno_appl03,
        lt_eprofsel_blkno_appl03 TYPE  t_eprofsel_blkno_appl03.


  DATA: BEGIN OF s_last,
          int_ui          TYPE euitrans-int_ui,
          invperiod_start TYPE tinv_inv_doc-invperiod_start,
          invperiod_end   TYPE tinv_inv_doc-invperiod_end,
          logikzw         TYPE easts-logikzw,
          profile         TYPE eprofass-profile,
          profrole        TYPE eprofass-profrole,
          prof_value      TYPE eprofvalue-prof_value,
        END OF s_last.

  DATA: t_last      LIKE TABLE OF s_last WITH HEADER LINE,
        s_eprofhead TYPE eprofhead,
        lv_adsparte TYPE /adesso/sparte,
        xy_profile  TYPE eprofile,
        t_value     TYPE teprofvalues_sorted,
        arch_data   TYPE REF TO data,
        BEGIN OF s_values,
          prof_date  TYPE        eprofvalue-prof_date,
          prof_time  TYPE        eprofvalue-prof_time,
          prof_value TYPE        eprofvalue-prof_value,
        END OF s_values,
        t_range   TYPE teedm_date_time_from_to_utc,
        s_range   TYPE eedm_date_time_from_to_utc,
        f_end_gas TYPE d.

  DATA: BEGIN OF s_verb,
          int_ui          TYPE euitrans-int_ui,
          invperiod_start TYPE tinv_inv_doc-invperiod_start,
          invperiod_end   TYPE tinv_inv_doc-invperiod_end,
          prof_value      TYPE eprofvalue-prof_value,
        END OF s_verb.

  DATA: t_verb            LIKE TABLE OF s_verb WITH HEADER LINE.

  DATA: BEGIN OF s_blind,
          int_ui          TYPE euitrans-int_ui,
          invperiod_start TYPE tinv_inv_doc-invperiod_start,
          invperiod_end   TYPE tinv_inv_doc-invperiod_end,
          prof_value      TYPE eprofvalue-prof_value,
        END OF s_blind.

  DATA: t_blind            LIKE TABLE OF s_verb WITH HEADER LINE.

  DATA:          ls_art_cust TYPE /adesso/art_cust,
                 lv_abw_abs  TYPE int4 VALUE 0,
                 lv_abw_proz TYPE int1 VALUE 0.

  CONSTANTS:  tm_strom_a TYPE eprofvalue-prof_time VALUE '000000',
              tm_strom_b TYPE eprofvalue-prof_time VALUE '235959',
              tm_gas_a   TYPE eprofvalue-prof_time VALUE '060000',
              tm_gas_b   TYPE eprofvalue-prof_time VALUE '055959'.

  FIELD-SYMBOLS <s_value> LIKE s_values.



* Itabs
  DATA: BEGIN OF t_quant OCCURS 0,
          quantity   TYPE tinv_inv_line_b-quantity,
          unit       TYPE tinv_inv_line_b-unit,
          product_id TYPE tinv_inv_line_b-product_id,
        END OF t_quant.

  TABLES: eablg.

* MessageID
  CONSTANTS: co_z_msgid           TYPE sy-msgid VALUE '/ADESSO/INV_MANAGER'.

  CONSTANTS: co_chcktype_mrreason  TYPE inv_in_chck_type VALUE '019'.
  CONSTANTS: co_chcktype_servid    TYPE inv_in_chck_type VALUE '018'.

  DATA:  f_rc              TYPE c,
         h_date_of_payment TYPE inv_date_of_payment,
         h_date_transf     TYPE c,
         val1              TYPE sy-msgv1,
         val2              TYPE sy-msgv1,
         val3              TYPE sy-msgv1.


  DATA: ls_eanlh    TYPE eanlh,
        ls_etdz     TYPE etdz,
        is_pauschal TYPE c,
        ls_ettifn   TYPE ettifn,
        is_rlm      TYPE char1,
        l_diff      TYPE tinv_inv_line_b-quantity.

  CONSTANTS: co_sonder TYPE aklasse VALUE '02',
             co_gaspau TYPE e_operand VALUE 'GSZAHTLP'.


  DATA: lt_euipodgroup TYPE ieuipodgroup,
        ls_euipodgroup TYPE euipodgroup,
        lv_podgroup    TYPE e_deregpodgroup,
        lv_int_ui      TYPE int_ui.



  mac_reset_inv_return.


  CLEAR f_rc.

  LOOP AT xy_process_data ASSIGNING <y_process>.
    ASSIGN <y_process>-inv_head TO <head>.

    LOOP AT <y_process>-inv_doc ASSIGNING <doc>
                    WHERE int_inv_no = <head>-int_inv_no.

      l_receiver = <y_process>-inv_head-int_receiver(10).
      l_sender = <y_process>-inv_head-int_sender(10).

      CLEAR t_quant. REFRESH t_quant.
      CLEAR l_sucsmpt. CLEAR l_consmpt.
      CLEAR c_quantity.


      CLEAR: lt_euipodgroup,
             ls_euipodgroup.
      REFRESH: lt_euipodgroup.

      LOOP AT <y_process>-inv_extid ASSIGNING <inv_extid>.
        EXIT.
      ENDLOOP.
      CLEAR lv_int_ui.
      SELECT int_ui FROM euitrans
        INTO lv_int_ui
       WHERE ext_ui = <inv_extid>-ext_ident
         AND datefrom LE <doc>-invoice_date
         AND dateto   GE <doc>-invoice_date.
      ENDSELECT.

      CALL METHOD cl_isu_ide_ui_podgroup=>select_uipodgroup
        EXPORTING
          im_int_ui       = lv_int_ui
          im_deregproc    = 'INV_INCHCK'
        IMPORTING
          ex_ieuipodgroup = lt_euipodgroup.

      LOOP AT lt_euipodgroup INTO ls_euipodgroup
                            WHERE datefrom LE <doc>-invoice_date
                              AND dateto   GE <doc>-invoice_date.
      ENDLOOP.

      lv_podgroup = ls_euipodgroup-podgroup.

*     check parameter meterread reason in Service partner agreement (mrreason)
      CALL FUNCTION 'ISU_DEREG_GET_INV_INCHCK'
        EXPORTING
          x_keydate         = <doc>-invoice_date
          x_initiator       = l_sender
          x_partner         = l_receiver
          x_invoice_type    = <doc>-invoice_type
          x_doc_type        = <doc>-doc_type
          x_chck_type       = co_chcktype_mrreason
          x_podgroup        = lv_podgroup
        IMPORTING
          yt_tinv_c_inchcka = lt_tinv_c_inchcka
          yt_tinv_c_inchckp = lt_tinv_c_inchckp
          y_tinv_c_inchcka  = lw_tinv_c_inchcka
          y_tinv_c_inchckp  = lw_tinv_c_inchckp
        EXCEPTIONS
          internal_error    = 1
          no_check_found    = 2
          OTHERS            = 3.

      IF sy-subrc <> 0.
        f_rc = co_true.
        msg_to_inv_return space co_msg_warning co_z_msgid '001'
          co_chcktype_mrreason l_sender space space.
        IF 1 = 2.
          MESSAGE w001(/adesso/inv_manager).
        ENDIF.
      ELSE.
        msg_to_inv_return space co_msg_information co_z_msgid '007'
          co_chcktype_mrreason l_sender space space.
        IF 1 = 2.
          MESSAGE i007(/adesso/inv_manager).
        ENDIF.

        LOOP AT lt_tinv_c_inchckp INTO lw_tinv_c_inchckp.
          CLEAR:  l_mrreason,
                  lr_mrreason.
          CHECK   lw_tinv_c_inchckp IS NOT INITIAL.
          SHIFT lw_tinv_c_inchckp-chck_val BY 11 PLACES.
          l_mrreason = lw_tinv_c_inchckp-chck_val.
          lr_mrreason-option = /isidex/cl_isu_ident_variant=>co_equals.
          lr_mrreason-sign   = /isidex/cl_isu_ident_variant=>co_including.
          lr_mrreason-low    = l_mrreason.
          APPEND lr_mrreason TO tr_mrreason[].

          CLEAR:  lw_tinv_c_inchckp.

        ENDLOOP.

        SELECT * FROM tinv_c_inchckp INTO TABLE lt_tinv_c_inchckp WHERE chck_type = '019'.
        LOOP AT lt_tinv_c_inchckp INTO lw_tinv_c_inchckp.
          CLEAR:  l_mrreason,
                  lr_mrreason.
          CHECK   lw_tinv_c_inchckp IS NOT INITIAL.
          SHIFT lw_tinv_c_inchckp-chck_val BY 11 PLACES.
          l_mrreason = lw_tinv_c_inchckp-chck_val.
          lr_mrreason-option = /isidex/cl_isu_ident_variant=>co_equals.
          lr_mrreason-sign   = /isidex/cl_isu_ident_variant=>co_including.
          lr_mrreason-low    = l_mrreason.
          APPEND lr_mrreason TO tr_mrreason[].

          CLEAR:  lw_tinv_c_inchckp.
        ENDLOOP.
        SORT tr_mrreason.
        DELETE ADJACENT DUPLICATES FROM tr_servid.

      ENDIF.

* Check if mrdata should be processed
      IF f_rc EQ co_false.


        CLEAR: lt_euipodgroup,
               ls_euipodgroup.
        REFRESH: lt_euipodgroup.



        CALL METHOD cl_isu_ide_ui_podgroup=>select_uipodgroup
          EXPORTING
            im_int_ui       = lv_int_ui
            im_deregproc    = 'INV_INCHCK'
          IMPORTING
            ex_ieuipodgroup = lt_euipodgroup.

        LOOP AT lt_euipodgroup INTO ls_euipodgroup
                              WHERE datefrom LE <doc>-invoice_date
                                AND dateto   GE <doc>-invoice_date.
        ENDLOOP.

        lv_podgroup = ls_euipodgroup-podgroup.



*     check parameter service-Id in Service partner agreement (servid)
        CALL FUNCTION 'ISU_DEREG_GET_INV_INCHCK'
          EXPORTING
            x_keydate         = <doc>-invoice_date
            x_initiator       = l_sender
            x_partner         = l_receiver
            x_invoice_type    = <doc>-invoice_type
            x_doc_type        = <doc>-doc_type
            x_chck_type       = co_chcktype_servid
            x_podgroup        = lv_podgroup
          IMPORTING
            yt_tinv_c_inchcka = lt_tinv_c_inchcka
            yt_tinv_c_inchckp = lt_tinv_c_inchckp
            y_tinv_c_inchcka  = lw_tinv_c_inchcka
            y_tinv_c_inchckp  = lw_tinv_c_inchckp
          EXCEPTIONS
            internal_error    = 1
            no_check_found    = 2
            OTHERS            = 3.

        IF sy-subrc <> 0.
          f_rc = co_true.
          msg_to_inv_return space co_msg_error co_z_msgid '008'
            co_chcktype_servid l_sender space space.
          IF 1 = 2.
            MESSAGE e008(/adesso/inv_manager).
          ENDIF.
        ELSE.

          LOOP AT lt_tinv_c_inchckp INTO lw_tinv_c_inchckp.
            lr_servid-option = /isidex/cl_isu_ident_variant=>co_equals.
            lr_servid-sign   = /isidex/cl_isu_ident_variant=>co_including.
            lr_servid-low    = lw_tinv_c_inchckp-chck_val.
            APPEND lr_servid TO tr_servid[].
          ENDLOOP.
        ENDIF.

*       select mrdata for check
        IF f_rc EQ co_false.

* --- process relevant lines in invoice for quantity-check
          LOOP AT <y_process>-inv_line_b ASSIGNING <line_b>
                             WHERE int_inv_doc_no =  <doc>-int_inv_doc_no
                             AND   product_id     IN tr_servid
                             AND   date_from      GE <doc>-invperiod_start
                             AND   date_to        LE <doc>-invperiod_end
                             AND   betrw_net      NE 0.

            WRITE <line_b>-quantity TO c_quantity DECIMALS 0.
            msg_to_inv_return space co_msg_information co_z_msgid '002'
                               <line_b>-product_id <line_b>-unit c_quantity space.
            IF 1 = 0. MESSAGE i002(/adesso/inv_manager). ENDIF.

            CLEAR t_quant.
            t_quant-quantity = <line_b>-quantity.
            t_quant-unit     = <line_b>-unit.
            t_quant-product_id     = <line_b>-product_id.
            COLLECT t_quant.

          ENDLOOP.



**      Wenn keine Artikelnummern aus der INVOIC zu den Serviceanbietervereinbarungen passen, wird keine PrÃ¼fung vorgenommen.
          IF sy-subrc NE 0.
            msg_to_inv_return space co_msg_information co_z_msgid '008'
              co_chcktype_servid l_sender space space.
            IF 1 = 2.
              MESSAGE e008(/adesso/inv_manager).
            ENDIF.
            CONTINUE.
          ENDIF.


* --- process relevant lines in invoice for quantity-check
          LOOP AT <y_process>-inv_line_b ASSIGNING <line_b>
                             WHERE int_inv_doc_no =  <doc>-int_inv_doc_no
                             AND   product_id     IN tr_servid
                             AND   date_from      GE <doc>-invperiod_start
                             AND   date_to        LE <doc>-invperiod_end
                             AND   betrw_net      NE 0.

            WRITE <line_b>-quantity TO c_quantity DECIMALS 0.
            msg_to_inv_return space co_msg_information co_z_msgid '002'
                               <line_b>-product_id <line_b>-unit c_quantity space.
            IF 1 = 0. MESSAGE i002(/adesso/inv_manager). ENDIF.

            CLEAR t_quant.
            t_quant-quantity = <line_b>-quantity.
            t_quant-unit     = <line_b>-unit.
            COLLECT t_quant.

          ENDLOOP.


*         sum of quantity invoiced
          LOOP AT t_quant.
            WRITE t_quant-quantity TO c_quantity DECIMALS 0.
            msg_to_inv_return space co_msg_information co_z_msgid '004'
                              t_quant-unit c_quantity space space.
            IF 1 = 0. MESSAGE i004(/adesso/inv_manager). ENDIF.
          ENDLOOP.

* Find the respective mrdata to compare
* get mr results for POD
*     check internal pod
          IF <doc>-int_ident_type <> co_isu_zaehlpunkt OR
             <doc>-int_ident      IS INITIAL.
            msg_to_inv_return space co_msg_error co_msgid '675'
                              space space space space.
            IF 1 = 0. MESSAGE e675(edereg_inv). ENDIF.
            CONTINUE.
          ENDIF.

*     Get Installations for PoD
          MOVE <doc>-int_ident TO l_int_ui.

          CALL FUNCTION 'ISU_DB_EUIINSTLN_SELECT'
            EXPORTING
              x_int_ui      = l_int_ui
              x_dateto      = <doc>-invperiod_end     "end of validity period for bill/pan
              x_datefrom    = <doc>-invperiod_start   "start of validity period for bill/pan
              x_only_dereg  = co_flag_marked
            IMPORTING
              y_euiinstln   = t_euiinstln[]
            EXCEPTIONS
              not_found     = 1
              system_error  = 2
              not_qualified = 3
              OTHERS        = 4.
          IF sy-subrc <> 0.
            IF sy-msgid = 'E9' AND sy-msgno = '033'.
*         e.g. dateto, datefrom not filled
              msg_to_inv_return space co_msg_warning co_z_msgid '005'
                                l_int_ui space space space.
              IF 1 = 2. MESSAGE w005(/adesso/inv_manager). ENDIF.
              EXIT.
            ELSE.
              msg_to_inv_return space    sy-msgty sy-msgid sy-msgno
                                sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
              EXIT.
            ENDIF.
          ENDIF.

*     Get service provider data for receiving service provider.
          MOVE <head>-int_receiver TO l_servprov.

          CALL FUNCTION 'ISU_DB_ESERVPROV_SINGLE'
            EXPORTING
              x_serviceid = l_servprov
              x_langu     = sy-langu
            IMPORTING
              y_eservprov = l_eservprov
            EXCEPTIONS
              not_found   = 1
              OTHERS      = 2.
          IF sy-subrc <> 0.
            msg_to_inv_return space    sy-msgty sy-msgid sy-msgno
                              sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ELSE.
*       field w_eservprov-service is filled.
          ENDIF.

          LOOP AT        t_euiinstln[]
               ASSIGNING <instl>.
*       Get data for installations found
            CALL FUNCTION 'ISU_DB_EANLS_SINGLE'
              EXPORTING
                x_anlage     = <instl>-anlage
              IMPORTING
                y_eanl       = ls_eanl
              EXCEPTIONS
                not_found    = 1
                system_error = 2
                OTHERS       = 3.
            IF sy-subrc <> 0.
              msg_to_inv_return space    sy-msgty sy-msgid sy-msgno
                                sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.

*       Consider only installations with the same service type as the
*       receiving service provider
            IF ls_eanl-service = l_eservprov-service.
              lr_anlage-option = /isidex/cl_isu_ident_variant=>co_equals.
              lr_anlage-sign   = /isidex/cl_isu_ident_variant=>co_including.
              lr_anlage-low    = <instl>-anlage.
              APPEND lr_anlage TO tr_anlage[].
            ENDIF.
          ENDLOOP.

          DESCRIBE TABLE tr_anlage[]  LINES l_lin.

          IF l_lin = 0.
*       No installation with correct service type
            msg_to_inv_return space co_msg_warning co_z_msgid '006'
                              l_eservprov-service space space space.
            EXIT.
            IF 1 = 2. MESSAGE w006(/adesso/inv_manager). ENDIF.
          ENDIF.
          READ TABLE tr_anlage INTO lr_anlage INDEX 1.
          READ TABLE t_euiinstln ASSIGNING <instl> WITH KEY anlage = lr_anlage-low.


**  --> EVNUSS 05.04.2012, PrÃ¼fen auf RLM-Kunden (Abrechnungsklasse 02)
          CLEAR: ls_eanlh, is_rlm.
*          IF ls_eanl-sparte = '10'.
          SELECT * FROM eanlh INTO ls_eanlh
                  WHERE anlage = <instl>-anlage
                    AND bis GE sy-datum.
            EXIT.
          ENDSELECT.
          IF ls_eanlh-aklasse = co_sonder.
            is_rlm = 'X'.
          ENDIF.
          DATA ls_tarif TYPE /adesso/ec_tarif.
          SELECT SINGLE * FROM /adesso/ec_tarif INTO ls_tarif WHERE tarif = ls_eanlh-tariftyp.
          IF sy-subrc = 0.
            IF ls_tarif-pruefart = '0'.
              is_rlm = ''.
            ELSE.
              is_rlm = 'X'  .
            ENDIF.
          ENDIF.
          DATA lv_cust TYPE c.
          SELECT SINGLE adsparte FROM /adesso/ec_spart INTO lv_adsparte WHERE sparte = ls_eanl-sparte.
          PERFORM cust_pruef USING
                lv_adsparte
                is_rlm
                <doc>-invperiod_start
                <doc>-invperiod_end
                <instl>-anlage
              CHANGING lv_cust
                      l_sucsmpt.
          IF lv_cust <> 'X'.
            "Pauschalanlagen beachten
            DATA ls_pausch TYPE /adesso/ec_pausc.
            DATA lt_ettifn TYPE TABLE OF ettifn.
*DATA ls_ettifn TYPE ettifn.
            SELECT * FROM /adesso/ec_pausc INTO ls_pausch WHERE tarif = ls_eanlh-tariftyp.
              SELECT  * FROM ettifn INTO TABLE lt_ettifn WHERE anlage = <instl>-anlage AND operand = ls_pausch-anlagefakt AND ab =  <doc>-invperiod_start AND bis = <doc>-invperiod_end .
              IF sy-subrc = 0.
                is_pauschal = 'X'.
                SORT lt_ettifn BY ab DESCENDING.
                READ TABLE lt_ettifn INTO ls_ettifn INDEX 1.
                l_sucsmpt = l_sucsmpt + ls_ettifn-wert1.
              ENDIF.
            ENDSELECT.



*          SELECT * FROM
*          ENDIF.
DATA lv_abwv TYPE i.
DATA lv_abwn TYPE i.
DATA lv_value TYPE /adesso/inv_cust-value.
SELECT SINGLE value FROM /adesso/inv_cust INTO lv_value  WHERE report = 'INV_MANAGER_QUANTITY' AND field = 'ABL_DATEV'.
if sy-subrc = 0.
  lv_abwV = lv_value.
  <doc>-invperiod_start = <doc>-invperiod_start - lv_abwv.
endif.
SELECT SINGLE value FROM /adesso/inv_cust INTO lv_value  WHERE report = 'INV_MANAGER_QUANTITY' AND field = 'ABL_DATEN'.
if sy-subrc = 0.
  lv_abwN = lv_value.
  <doc>-invperiod_end = <doc>-invperiod_end + lv_abwN.
endif.

*     Get meter reading documents for the installations found
            CALL FUNCTION 'ISU_DB_EABL_SELECT_INSTALL_ENT'
              EXPORTING
                x_adatvon        = <doc>-invperiod_start
                x_adatbis        = <doc>-invperiod_end
                x_valid          = 'X'
              TABLES
                ty_eabl          = lt_eabl[]
                tx_anlage        = tr_anlage[]
                tx_ablesgr       = tr_mrreason[]
              EXCEPTIONS
                not_found        = 1
                system_error     = 2
                not_qualified    = 3
                invalid_interval = 4
                path_invalid     = 5
                date_invalid     = 6
                internal_error   = 7
                OTHERS           = 8.
            IF sy-subrc <> 0.

* >>> B.Duda 25.03.2014 SR-1407558
              "Fehlermeldung nicht bei RLM nur bei SLP
              IF is_rlm = ' ' AND is_pauschal = ' '. "SLP Kunde
* <<< B.Duda 25.03.2014 SR-1407558
                IF sy-msgid = 'E9' AND sy-msgno = '200'.
                  msg_to_inv_return space co_msg_error co_msgid1 '871'
                                    space space space space.
                  IF 1 = 2. MESSAGE e871(edereg_inv). ENDIF.
                ELSE.
                  msg_to_inv_return space    sy-msgty sy-msgid sy-msgno
                                    sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                ENDIF.
              ENDIF.
            ENDIF.


*        RLM-Kunden
            IF is_rlm = 'X' AND is_pauschal = ' '.
**          Sparte Strom


* Datenermittlung zur Lastgangmessung
              CLEAR: s_last,
                     ls_euihead.

              s_last-int_ui           = <instl>-int_ui.
              "s_last-anlage           = ls_eanlh-anlage.
              s_last-invperiod_start  = <doc>-invperiod_start.
              s_last-invperiod_end    = <doc>-invperiod_end.

              SELECT SINGLE *
                FROM  euihead
                INTO  ls_euihead
                WHERE int_ui = <instl>-int_ui.

              s_from-datefrom = <doc>-invperiod_start.
              s_from-timefrom = tm_strom_a.
              s_to-dateto     = <doc>-invperiod_end.
              s_to-timeto     = tm_strom_b.

              CLEAR:  s_profileui,
                      t_profileui,
                      t_profileui[].

              CALL FUNCTION 'ISU_EDM_DETERMINE_PROFILE_UI'
                EXPORTING
                  x_int_ui           = <instl>-int_ui
                  x_from             = s_from
                  x_to               = s_to
                  x_euihead          = s_euihead
                  x_read_notfulltime = 'X'
                IMPORTING
                  yt_profileui       = t_profileui
                EXCEPTIONS
                  not_found          = 1
                  no_assignment      = 2
                  general_fault      = 3
                  OTHERS             = 4.

              LOOP AT t_profileui INTO s_profileui.
                s_last-logikzw  = s_profileui-logikzw.
                s_last-profile  = s_profileui-profile.
                s_last-profrole = s_profileui-profrole.

                APPEND  s_last TO t_last.
              ENDLOOP.



              LOOP AT t_last INTO s_last.
                CLEAR:  s_eprofhead,
                        xy_profile.

                CALL FUNCTION 'ISU_DB_EPROFHEAD_SINGLE'
                  EXPORTING
                    x_profile  = s_last-profile
                  IMPORTING
                    y_profhead = s_eprofhead
                  EXCEPTIONS
                    not_found  = 1
                    OTHERS     = 2.

                SELECT SINGLE adsparte FROM /adesso/ec_spart INTO lv_adsparte WHERE sparte = s_eprofhead-sparte.
                IF sy-subrc <> 0.
                  lv_adsparte = 'ST'.
                ENDIF.

                CASE lv_adsparte.
                  WHEN 'ST'.
                    CALL FUNCTION 'ISU_EDM_PROFILE_SELECT'
                      EXPORTING
                        x_profilenr            = s_last-profile
                        x_datefrom             = s_last-invperiod_start
                        x_timefrom             = tm_strom_a
                        x_dateto               = s_last-invperiod_end
                        x_timeto               = tm_strom_b
                        x_timezone             = s_eprofhead-time_zone
                      IMPORTING
                        y_profile              = xy_profile
                      EXCEPTIONS
                        not_found              = 1
                        values_not_found       = 2
                        status_not_found       = 3
                        statushist_not_found   = 4
                        version_not_found      = 5
                        not_customized         = 6
                        conversion_not_allowed = 7
                        archiving_error        = 8
                        invalid_timerange      = 9
                        invalid_data           = 10
                        OTHERS                 = 11.
                  WHEN 'GA'.
                    CLEAR:  f_end_gas.
                    f_end_gas = s_last-invperiod_end + 1.

                    CALL FUNCTION 'ISU_EDM_PROFILE_SELECT'
                      EXPORTING
                        x_profilenr            = s_last-profile
                        x_datefrom             = s_last-invperiod_start
                        x_timefrom             = tm_gas_a
                        x_dateto               = s_last-invperiod_end
                        x_timeto               = tm_gas_b
                        x_timezone             = s_eprofhead-time_zone
                      IMPORTING
                        y_profile              = xy_profile
                      EXCEPTIONS
                        not_found              = 1
                        values_not_found       = 2
                        status_not_found       = 3
                        statushist_not_found   = 4
                        version_not_found      = 5
                        not_customized         = 6
                        conversion_not_allowed = 7
                        archiving_error        = 8
                        invalid_timerange      = 9
                        invalid_data           = 10
                        OTHERS                 = 11.
                ENDCASE.


                IF sy-subrc = 0.
                  LOOP AT xy_profile-profvalues_utc ASSIGNING <s_value>.
                    ADD <s_value>-prof_value TO s_last-prof_value.
                  ENDLOOP.
                ENDIF.

                MODIFY t_last FROM s_last.
              ENDLOOP.

              SORT t_last BY int_ui invperiod_start invperiod_end logikzw profile profrole.

              LOOP AT t_last INTO s_last.
                s_verb-int_ui          = s_last-int_ui.
                s_verb-invperiod_start = s_last-invperiod_start.
                s_verb-invperiod_end   = s_last-invperiod_end.
                s_verb-prof_value      = s_last-prof_value.
                CASE s_last-profrole.
                  WHEN '0001' OR 'G105' OR '0026'.
                    COLLECT s_verb INTO t_verb.
                    l_sucsmpt = s_verb-prof_value + l_sucsmpt.
                    CLEAR s_verb.
                  WHEN '0030'.
                    COLLECT s_verb INTO t_blind.
                    l_sumblind = s_verb-prof_value + l_sumblind.
                    CLEAR s_verb.
                ENDCASE.

              ENDLOOP.

              CLEAR:  s_last,
                      s_verb,
                      s_data.

              "  LOOP AT t_data INTO s_data.
              CLEAR:      s_last.
              READ TABLE  t_verb INTO s_verb
                WITH KEY  int_ui          = <instl>-int_ui
                          invperiod_start = <doc>-invperiod_start
                          invperiod_end   = <doc>-invperiod_end.
              IF sy-subrc = 0.
                s_data-f_last = '@5B\Q Lastgang für Abrechnungsperiode gepflegt@'.
                s_data-prof_value = s_verb-prof_value.
                LOOP AT t_last INTO s_last.

                  CALL METHOD cl_isu_edm_profile=>get_valid_value_timeranges
                    EXPORTING
                      profile_number = s_last-profile
                    IMPORTING
                      timeslices     = t_range
                    EXCEPTIONS
                      not_found      = 1
                      OTHERS         = 2.

                  LOOP AT t_range INTO s_range
                    WHERE datefrom LE s_data-invperiod_start
                    AND   dateto   GE s_data-invperiod_end.
                  ENDLOOP.
                  IF sy-subrc = 0.
                    "l_sucsmpt = s_last-prof_value + l_sucsmpt.
                  ELSEIF sy-subrc NE 0.
                    s_data-f_last = '@5D\Q Lastgangdaten für Abr.periode nicht vollständig@'.
                    EXIT.
                  ENDIF.

                ENDLOOP.
              ELSE.
                s_data-f_last = '@5C\Q Kein Lastgang für Abr.periode gepflegt@'.
              ENDIF.

              "      MODIFY t_data FROM s_data.




*--->  Erweiterung um Lastgangprüfung
*--->  Akaslan - SR-1517522



              CALL FUNCTION 'ROUND'
                EXPORTING
                  decimals      = 0
                  input         = l_sucsmpt
                  sign          = 'X'
                IMPORTING
                  output        = l_sucsmpt
                EXCEPTIONS
                  input_invalid = 1
                  overflow      = 2
                  type_invalid  = 3
                  OTHERS        = 4.
              IF sy-subrc <> 0.
                MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
              ENDIF.

            ELSEIF is_pauschal = ' '.
**    <-- EVNUSS 05.04.2012
              DATA lt_etdz TYPE TABLE OF etdz.
              LOOP AT lt_eabl[] ASSIGNING <eabl>.
*              SELECT count( * ) FROM easts WHERE anlage = <eabl>-anlage AND ZWNABR <> 'X' AND LOGIKZW =<eabl>-zwnummer.
*              IF lines( lt_etdz ) > 0.
*                READ TABLE lt_etdz TRANSPORTING NO FIELDS WITH KEY zwnummer = <eabl>-zwnummer.
*                IF sy-subrc <> 0.
*                  CONTINUE.
*                ENDIF.
*              ENDIF.
**            03.11.2014 SR-1423354
                SELECT SINGLE *
                  FROM  eablg
                  WHERE ablbelnr = <eabl>-ablbelnr
                  AND   ( ablesgr  = '06'
                  OR    ablesgr  = '21' ).

                IF sy-subrc NE 0.                         "Keine Verarbeitung bei AnfangszÃ¤hlerstÃ¤nden.


                  CALL FUNCTION 'ISU_DB_EABL_LAST'
                    EXPORTING
                      x_equnr       = <eabl>-equnr
                      x_zwnummer    = <eabl>-zwnummer
                      x_adat        = <eabl>-adat
                      x_atim        = <eabl>-atim
                      x_mr_status   = '2'
                    IMPORTING
                      y_eabl        = ls_last_eabl
                    EXCEPTIONS
                      not_found     = 1
                      system_error  = 2
                      not_qualified = 3
                      adat_to_old   = 4
                      OTHERS        = 5.



                  IF sy-subrc <> 0.
                    msg_to_inv_return space co_msg_error sy-msgid sy-msgno sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                  ELSE.

**                05.11.2014 SR-1424893
                    SELECT SINGLE g~ablbelnr                      "PrÃ¼fung ob es sich um eine Einzugsablesung handelt.
                      INTO       ls_check_eabl
                      FROM       eablg AS g
                      INNER JOIN ever  AS v
                      ON    v~anlage   = g~anlage
                      WHERE g~ablbelnr = ls_last_eabl-ablbelnr
                      AND   g~ablesgr  = '06'
                      AND   v~einzdat  = <doc>-invperiod_start.

                    IF sy-subrc = 0.                                    "Verarbeitung bei Einzugsablesung und weiteren AblesegrÃ¼nden
                      CALL FUNCTION 'ISU_CONSUMPTION_DETERMINE'
                        EXPORTING
                          x_geraet          = <eabl>-gernr
                          x_equnr           = <eabl>-equnr
                          x_zwnummer        = <eabl>-zwnummer
                          x_adat            = <eabl>-adat
                          x_atim            = <eabl>-atim
*                         X_I_ZWSTNDAB      =
                          x_v_zwstndab      = <eabl>-v_zwstndab
                          x_n_zwstndab      = <eabl>-n_zwstndab
                          x_adatvor         = ls_last_eabl-adat
                          x_atimvor         = ls_last_eabl-atim
*                         X_I_ZWSTVOR       =
                          x_v_zwstvor       = ls_last_eabl-v_zwstand
                          x_n_zwstvor       = ls_last_eabl-n_zwstand
*                         X_WABLT           =
*                         X_WTHG            =
*                         X_NO_INSTSTRU_READ        = ' '
*                         X_NORUND          =
*                         X_GUSE            = 'MR'
*                         X_READ_GASFAKTOR  = ' '
*                         X_ROUND_EXEC      = ' '
*                         X_IF              =
*                         X_CONSID_FACTOR   = 'X'
                        IMPORTING
                          y_i_abrmenge      = l_consmpt
*                         Y_V_ABRMENGE      =
*                         Y_N_ABRMENGE      =
*                     CHANGING
*                         XY_INST_FOR_BILLING       =
                        EXCEPTIONS
                          general_fault     = 1
                          zwstandab_missing = 2
                          zwstand_missing   = 3
                          parameter_missing = 4
                          no_inst_structure = 5
                          no_ratetyp        = 6
                          no_gas_proc       = 7
                          OTHERS            = 8.
                      IF sy-subrc <> 0.
                        msg_to_inv_return space co_msg_error sy-msgid sy-msgno sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                      ELSE.
                        WRITE l_consmpt TO c_consumpt DECIMALS 0.
                        msg_to_inv_return space co_msg_information co_z_msgid '009'
                                          <eabl>-zwnummer <eabl>-massbill c_consumpt space.
                        IF 1 = 2. MESSAGE i009(/adesso/inv_manager). ENDIF.
                      ENDIF.
                    ELSE.
                      CALL FUNCTION 'ISU_CONSUMPTION_DETERMINE'
                        EXPORTING
                          x_geraet          = <eabl>-gernr
                          x_equnr           = <eabl>-equnr
                          x_zwnummer        = <eabl>-zwnummer
                          x_adat            = <eabl>-adat
                          x_atim            = <eabl>-atim
*                         X_I_ZWSTNDAB      =
                          x_v_zwstndab      = <eabl>-v_zwstndab
                          x_n_zwstndab      = <eabl>-n_zwstndab
                          x_adatvor         = ls_last_eabl-adat
                          x_atimvor         = ls_last_eabl-atim
*                         X_I_ZWSTVOR       =
                          x_v_zwstvor       = ls_last_eabl-v_zwstndab
                          x_n_zwstvor       = ls_last_eabl-n_zwstndab
*                         X_WABLT           =
*                         X_WTHG            =
*                         X_NO_INSTSTRU_READ        = ' '
*                         X_NORUND          =
*                         X_GUSE            = 'MR'
*                         X_READ_GASFAKTOR  = ' '
*                         X_ROUND_EXEC      = ' '
*                         X_IF              =
*                         X_CONSID_FACTOR   = 'X'
                        IMPORTING
                          y_i_abrmenge      = l_consmpt
*                         Y_V_ABRMENGE      =
*                         Y_N_ABRMENGE      =
*                     CHANGING
*                         XY_INST_FOR_BILLING       =
                        EXCEPTIONS
                          general_fault     = 1
                          zwstandab_missing = 2
                          zwstand_missing   = 3
                          parameter_missing = 4
                          no_inst_structure = 5
                          no_ratetyp        = 6
                          no_gas_proc       = 7
                          OTHERS            = 8.
                      IF sy-subrc <> 0.
                        msg_to_inv_return space co_msg_error sy-msgid sy-msgno sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                      ELSE.
                        WRITE l_consmpt TO c_consumpt DECIMALS 0.
                        msg_to_inv_return space co_msg_information co_z_msgid '009'
                                          <eabl>-zwnummer <eabl>-massbill c_consumpt space.
                        IF 1 = 2. MESSAGE i009(/adesso/inv_manager). ENDIF.
                      ENDIF.
                    ENDIF.


                  ENDIF.
                  l_sucsmpt = l_sucsmpt + l_consmpt.
                ENDIF.
              ENDLOOP.
*          ENDIF.                                                "EVNUSS 05.04.2012
              WRITE l_sucsmpt TO c_consumpt DECIMALS 0.

              IF sy-subrc <> 0.
                msg_to_inv_return space co_msg_error co_msgid1 '871'
                                  space space space space.
                IF 1 = 2. MESSAGE e871(edereg_inv). ENDIF.
              ELSE.
                msg_to_inv_return space co_msg_information co_z_msgid '010'
                                  <eabl>-massbill c_consumpt space space.
                IF 1 = 2. MESSAGE i010(/adesso/inv_manager). ENDIF.
              ENDIF.
            ENDIF.                                                "EVNUSS 11.04.2012



          ENDIF.

          if is_rlm = 'X' AND lv_adsparte = 'GA'.
                        lr_servid-option = /isidex/cl_isu_ident_variant=>co_equals.
            lr_servid-sign   = /isidex/cl_isu_ident_variant=>co_including.
            lr_servid-low    = '9990001000417'.
            APPEND lr_servid TO tr_servid[].
            CLEAR t_quant.
            endif.


**       --> Akaslan 23.01.2015 SR-1501341
**       Bei RLM und einer Nullsumme zum Abrechnungszeitraum aus der INVOIC,
**       sollen die VerbrÃ¤uche zur Artikelnummer aus der INVOIC aufsummiert werden.

          IF t_quant-quantity = 0.
*           process relevant lines in invoice for quantity-check without invperiod check
            LOOP AT <y_process>-inv_line_b ASSIGNING <line_b>
                             WHERE int_inv_doc_no =  <doc>-int_inv_doc_no
                             AND   product_id     IN tr_servid.
*                             AND   betrw_net      NE 0.

              CLEAR t_quant.
              t_quant-quantity    = <line_b>-quantity.
              t_quant-unit        = <line_b>-unit.
              t_quant-product_id  = <line_b>-product_id.
              COLLECT t_quant.

            ENDLOOP.
            LOOP AT t_quant.
              WRITE t_quant-quantity TO c_quantity DECIMALS 0.
              msg_to_inv_return space co_msg_information co_z_msgid '002'
                               t_quant-product_id t_quant-unit c_quantity space.
              IF 1 = 0. MESSAGE i002(/adesso/inv_manager). ENDIF.
            ENDLOOP.
          ENDIF.
**      <-- Akaslan 23.01.2015 SR-1501341
          DO 2 TIMES.
            IF sy-index = 1.
              if is_rlm = 'X' AND lv_adsparte = 'GA'.
              READ TABLE t_quant INTO t_quant  WITH KEY product_id = '9990001000417'.
              ELSE.
              READ TABLE t_quant INTO t_quant  WITH KEY product_id = '9990001000269'.
              endif.
              break struck-f.
              IF sy-subrc = 0.

              ELSE.
                EXIT.
              ENDIF.
            ELSE.
              READ TABLE t_quant INTO t_quant  WITH KEY product_id = '9990001000508'.
              break struck-f.
              IF sy-subrc = 0.
                l_sucsmpt = l_sumblind.
              ELSE.
                EXIT.
              ENDIF.
            ENDIF.
            WRITE l_sucsmpt TO  c_consumpt.
            SELECT SINGLE adsparte FROM /adesso/ec_spart INTO lv_adsparte WHERE sparte = ls_eanl-sparte.

            SELECT SINGLE * FROM /adesso/art_cust INTO ls_art_cust WHERE art_nr = t_quant-product_id AND sparte = lv_adsparte.
            IF sy-subrc = 0.
              IF ls_art_cust-max_abw_cent_p > 0.
                lv_abw_abs = ls_art_cust-max_abw_cent_v.
              ENDIF.
              IF ls_art_cust-max_abw_proz_p > 0.
                lv_abw_proz = ls_art_cust-max_abw_proz_v.
              ENDIF.
            ENDIF.

**       --> Nuss 11.04.2012

            l_diff = ( l_sucsmpt - t_quant-quantity ).

            IF abs( l_diff ) GT lv_abw_abs AND abs( l_diff ) / t_quant-quantity * 100 > lv_abw_proz.
              f_rc = co_true.
              IF sy-index = 1.
                msg_to_inv_return space co_msg_error co_z_msgid '011'
                                  c_quantity c_consumpt t_quant-unit space .
              ELSE.
                msg_to_inv_return space co_msg_error co_z_msgid '033'
                                 c_quantity c_consumpt t_quant-unit space .
              ENDIF.
              IF 1 = 2. MESSAGE e011(/adesso/inv_manager). ENDIF.
            ELSE.
              IF sy-index = 1.
                msg_to_inv_return space co_msg_information co_z_msgid '012'
                                  c_quantity c_consumpt t_quant-unit space .
              ELSE.
                msg_to_inv_return space co_msg_information co_z_msgid '034'
                                 c_quantity c_consumpt t_quant-unit space .
              ENDIF.

              IF 1 = 2. MESSAGE i012(/adesso/inv_manager). ENDIF.
            ENDIF.
          ENDDO.
        ENDIF.
      ENDIF.

    ENDLOOP.
  ENDLOOP.

* success!
  IF f_rc IS INITIAL.
    WRITE <doc>-ext_invoice_no TO val1.
    msg_to_inv_return space co_msg_success co_z_msgid '013'
                      val1 space space space.
    IF 1 = 2.
      MESSAGE s013(/adesso/inv_manager) WITH val1.
    ENDIF.
  ENDIF.

* Fill export table Y_RETURN
  y_return[] = it_inv_return[].

* Set status
  CALL FUNCTION 'ISU_DEREG_INV_COM_STATUS'
    EXPORTING
      x_return = y_return[]
    IMPORTING
      y_status = y_status.





ENDFUNCTION.
FORM cust_pruef USING u_sparte u_rlm u_start u_end u_anlage CHANGING c_cust c_verbr.
  DATA: lv_custreport TYPE string,
        lv_custform   TYPE string.
  SELECT SINGLE value FROM /adesso/inv_cust INTO lv_custreport WHERE report = 'GLOBAL' AND field = 'CUST_REPORT'.
  IF u_sparte = 'ST' AND u_rlm = 'X'.
    SELECT SINGLE value FROM /adesso/inv_cust INTO lv_custform WHERE report = 'GLOBAL' AND field = 'VP_RLM_STROM_FORM'.
    IF lv_custform IS NOT INITIAL AND lv_custreport IS NOT INITIAL.

    ENDIF.
  ELSEIF u_sparte = 'ST' AND u_rlm = ''.
    SELECT SINGLE value FROM /adesso/inv_cust INTO lv_custform WHERE report = 'GLOBAL' AND field = 'VP_SLP_STROM_FORM'.
    IF lv_custform IS NOT INITIAL AND lv_custreport IS NOT INITIAL.

    ENDIF.
  ELSEIF u_sparte = 'GAS' AND u_rlm = ''.
    SELECT SINGLE value FROM /adesso/inv_cust INTO lv_custform WHERE report = 'GLOBAL' AND field = 'VP_SLP_GAS_FORM'.
    IF lv_custform IS NOT INITIAL AND lv_custreport IS NOT INITIAL.
      CALL FUNCTION '/ADESSO/CONSUMPT_SLP_GAS_CUST'
        EXPORTING
          anlage       = u_anlage
          datbis       = u_end
          datab        = u_start
          custform     = lv_custform
          custprogramm = lv_custreport
        IMPORTING
          consumpt     = c_verbr.
      c_cust = 'X'.
    ENDIF.
  ELSEIF u_sparte = 'GAS' AND u_rlm = 'X'.
    SELECT SINGLE value FROM /adesso/inv_cust INTO lv_custform WHERE report = 'GLOBAL' AND field = 'VP_RLM_GAS_FORM'.
    IF lv_custform IS NOT INITIAL AND lv_custreport IS NOT INITIAL.

    ENDIF.
  ENDIF.
ENDFORM.
