class /ADESSO/CL_MDC_IM_DATEXCONNECT definition
  public
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_ISU_IDE_DATEXCONNECT .

  class-methods GET_PODS
    importing
      !IV_ADDRNUM type AD_ADDRNUM optional
      !IV_VERTRAG type VERTRAG optional
      !IV_ANLAGE type ANLAGE optional
      !IV_VKONT type VKONT_KK optional
      !IV_VSTELLE type VSTELLE optional
      !IV_BU_PARTNER type BU_PARTNER optional
      !IV_HAUS type HAUS optional
      !IV_KEYDATE type SY-DATUM default SY-DATUM
      !IV_ONLY_DEREG type KENNZX default ABAP_TRUE
    returning
      value(RT_INT_UI) type INT_UI_TABLE
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods SWITCH_OUT
    importing
      !X_SENDER type SERVICE_PROV
      !X_RECEIVER type SERVICE_PROV
      !X_MSGDATANUM_REQ type EIDESWTMDNUM optional
      !X_RECEIVER_SWTVIEW type EIDESWTVIEW optional
      !X_NO_EVENT type KENNZX optional
      !X_NO_COMMIT type KENNZX optional
      !XT_MSGDATACOMMENT type TEIDESWTMSGDATACO optional
      !X_SWTACT type EIDESWTACT optional
    changing
      !XY_MSGDATA type EIDESWTMSGDATA
    exceptions
      ERROR_OCCURRED
      NO_DEXPROC_FOUND .
  methods PROCESS_INVOICE
    importing
      value(X_INVOICE) type ISU21_PRINT_DOC
      value(X_REVERSE) type KENNZX optional
      value(X_ECROSSREFNO) type ECROSSREFNO
      value(XT_ERCH) type ISU_IERCH
      value(X_CONTRACT) type VERTRAG optional
      value(X_VKONT_AGG) type E_EDMIDEVKONT_AGGBILL optional
      !X_OLD type KENNZX optional
      !X_EVER type EVER
      !X_DEXSERVPROV type E_DEXSERVPROV optional
      !X_DEXSERVPROVSELF type E_DEXSERVPROVSELF optional
      !X_DEXDUEDATE type E_DEXDUEDATE optional
    exporting
      !Y_IDOC_CREATED type KENNZX
    exceptions
      ERROR_OCCURRED
      NO_DEXPROC_FOUND .
protected section.

  class-data GR_PREVIOUS type ref to CX_ROOT .
  class-data GT_MESSAGE type TISU00_MESSAGE .
  class-data GS_MESSAGE type ISU00_MESSAGE .
  PRIVATE SECTION.
ENDCLASS.



CLASS /ADESSO/CL_MDC_IM_DATEXCONNECT IMPLEMENTATION.


  METHOD get_pods.
    DATA: lt_addr_ref TYPE szadr_addr_ref_read_tab,
          ls_addr_ref TYPE szadr_addr_ref_read_line,
          lv_haus     TYPE haus.

    DATA: lr_badi_mdc_dtx_getpods TYPE REF TO /adesso/badi_mdc_dtx_getpods.

    IF iv_addrnum IS NOT INITIAL AND iv_haus IS INITIAL.
      CALL FUNCTION 'ADDR_REFERENCE_GET'
        EXPORTING
          address_number     = iv_addrnum
        TABLES
          reference_table    = lt_addr_ref
        EXCEPTIONS
          parameter_error    = 1
          address_not_exist  = 2
          no_reference_found = 3
          internal_error     = 4
          OTHERS             = 5.
      IF sy-subrc <> 0.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
      ENDIF.

      READ TABLE lt_addr_ref INTO ls_addr_ref WITH KEY addr_ref-appl_table = 'ILOA' addr_ref-appl_field = 'ADRNR'.
      IF sy-subrc <> 0.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
      ENDIF.

      lv_haus = ls_addr_ref-addr_ref-appl_key.
    ELSE.
      lv_haus = iv_haus.
    ENDIF.

    CALL METHOD cl_def_im_isu_ide_datexconnect=>get_pods
      EXPORTING
        x_vertrag      = iv_vertrag
        x_anlage       = iv_anlage
        x_vkont        = iv_vkont
        x_vstelle      = iv_vstelle
        x_bu_partner   = iv_bu_partner
        x_haus         = lv_haus
        x_keydate      = iv_keydate
        x_only_dereg   = iv_only_dereg
      IMPORTING
        yt_int_ui      = rt_int_ui
      EXCEPTIONS
        error_occurred = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
      /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDIF.

*/adesso/BAdI falls Standard nicht ausreichend ist
    TRY.
        GET BADI lr_badi_mdc_dtx_getpods
          FILTERS
            mandt = sy-mandt
            sysid = sy-sysid.
      CATCH cx_badi_not_implemented.
        "Das BAdI muss nicht implementiert sein.
    ENDTRY.

    IF lr_badi_mdc_dtx_getpods IS NOT INITIAL.
      CALL BADI lr_badi_mdc_dtx_getpods->get_pods
        EXPORTING
          iv_vertrag    = iv_vertrag
          iv_anlage     = iv_anlage
          iv_vkont      = iv_vkont
          iv_vstelle    = iv_vstelle
          iv_bu_partner = iv_bu_partner
          iv_haus       = lv_haus
          iv_keydate    = iv_keydate
          iv_only_dereg = iv_only_dereg
        CHANGING
          ct_int_ui     = rt_int_ui.
    ENDIF.

  ENDMETHOD.


  METHOD if_ex_isu_ide_datexconnect~datexconnect_account_changed.

    DATA:
      lr_badi_mdc_dtx_account TYPE REF TO /adesso/badi_mdc_dtx_account,
      lt_int_ui               TYPE int_ui_table,
      ls_fkkvkp_new           TYPE fkkvkp,
      lt_proc_data            TYPE /idxgc/t_proc_data,
      ls_proc_data            TYPE /idxgc/s_proc_data,
      lv_flag_send            TYPE /adesso/mdc_flag_send.

    FIELD-SYMBOLS:
      <fs_proc_data>      TYPE /idxgc/s_proc_data,
      <fs_proc_step_data> TYPE /idxgc/s_proc_step_data,
      <fv_int_ui>         TYPE int_ui.


    TRY.
***** 1. Daten in PDoc schreiben, Art der Änderung(en) und AMID ermitteln *************************
        lt_proc_data = /adesso/cl_mdc_datex_utility=>get_proc_data_account( it_fkkvkp_new = xt_fkkvkp_new it_fkkvkp_old = xt_fkkvkp_old
                                                                             iv_account_holder = x_account_holder ).

***** 2. Zählpunkte zu den Änderungen ermitteln ***************************************************
        READ TABLE xt_fkkvkp_new WITH KEY gpart = x_account_holder
          INTO ls_fkkvkp_new.

        lt_int_ui = get_pods( iv_vkont = ls_fkkvkp_new-vkont ).

***** 3. Prüfungen und ggf. Prozess starten für alle Zählpunkte ***********************************
        LOOP AT lt_proc_data ASSIGNING <fs_proc_data>.
          LOOP AT lt_int_ui ASSIGNING <fv_int_ui>.
            CLEAR: ls_proc_data.
            ls_proc_data = <fs_proc_data>.
            ls_proc_data-int_ui = <fv_int_ui>.
            READ TABLE ls_proc_data-steps ASSIGNING <fs_proc_step_data> INDEX 1.

*---- 3.1 Empfänger ermitteln ---------------------------------------------------------------------
            /adesso/cl_mdc_datex_utility=>add_servprovs_to_proc_data( CHANGING cs_proc_data = ls_proc_data ).
            CHECK <fs_proc_step_data>-own_servprov   IS NOT INITIAL AND
                  <fs_proc_step_data>-assoc_servprov IS NOT INITIAL AND
                  <fs_proc_step_data>-bmid           IS NOT INITIAL.

*---- 3.2 Prozessdaten vervollständigen -----------------------------------------------------------
            /adesso/cl_mdc_datex_utility=>enhance_proc_data( CHANGING cs_proc_data = ls_proc_data ).

*---- 3.3. Prüfung: Datenaustausch aktiv? ---------------------------------------------------------
            CHECK /adesso/cl_mdc_datex_utility=>get_send_flag_from_datex( iv_int_ui = <fv_int_ui> ) = abap_true.

*---- 3.4. Update der gesendeten Änderung entsprechend der Customizing Einstellungen --------------
            /adesso/cl_mdc_datex_utility=>update_mtd_code_result( CHANGING cs_proc_data = ls_proc_data ).
            CHECK <fs_proc_step_data>-mtd_code_result IS NOT INITIAL.

*---- 3.5. Prüfung: Kundenindividuelle Prüfung ----------------------------------------------------
            lv_flag_send = abap_true.

            TRY.
                GET BADI lr_badi_mdc_dtx_account
                  FILTERS
                    mandt = sy-mandt
                    sysid = sy-sysid.
              CATCH cx_badi_not_implemented.
                "Das BAdI muss nicht implementiert sein.
            ENDTRY.

            IF lr_badi_mdc_dtx_account IS NOT INITIAL.
              CALL BADI lr_badi_mdc_dtx_account->change_proc_data_and_send_flag
                EXPORTING
                  it_fkkvkp_new     = xt_fkkvkp_new
                  it_fkkvkp_old     = xt_fkkvkp_old
                  iv_account_holder = x_account_holder
                CHANGING
                  cs_proc_data      = ls_proc_data
                  cv_flag_send      = lv_flag_send.
            ENDIF.

            CHECK lv_flag_send = abap_true.

*---- 3.6 Prüfen, ob schon SDÄ existiert und als Schritt hinzufügen -------------------------------
*OPTIONAL: Hier können so SDÄ gesammelt werden.
*Abgleich: Empfänger, AMID und Prozess muss noch im Warteschritt hängen zu Beginn.

*---- 3.7 PDoc erzeugen und Prozess starten -------------------------------------------------------
            /idxgc/cl_process_trigger=>start_process( EXPORTING iv_pdoc_display = abap_false CHANGING cs_process_data = ls_proc_data ).

          ENDLOOP.
        ENDLOOP.

*---- 3.8 Fehlerbehandlung: Error PDoc ------------------------------------------------------------
      CATCH /idxgc/cx_general INTO gr_previous.
        TRY.
            CLEAR: gt_message, gs_message.
            MOVE-CORRESPONDING sy TO gs_message.
            APPEND gs_message TO gt_message.
            IF ls_proc_data IS INITIAL.
              READ TABLE lt_proc_data INTO ls_proc_data INDEX 1.
            ENDIF.
            /adesso/cl_mdc_datex_utility=>create_error_pdoc( is_proc_data = ls_proc_data it_message = gt_message ).
          CATCH /idxgc/cx_general INTO gr_previous.
            RAISE error_occurred.
        ENDTRY.
    ENDTRY.

  ENDMETHOD.


  METHOD if_ex_isu_ide_datexconnect~datexconnect_billinginst_chng.
    DATA: lr_badi_mdc_dtx_billingin TYPE REF TO /adesso/badi_mdc_dtx_billingin,
          lt_int_ui                 TYPE int_ui_table,
          lt_proc_data              TYPE /idxgc/t_proc_data,
          lt_message                TYPE tisu00_message,
          ls_proc_data              TYPE  /idxgc/s_proc_data,
          ls_message                TYPE isu00_message,
          lv_flag_send              TYPE /adesso/mdc_flag_send.

    FIELD-SYMBOLS: <fs_proc_data>      TYPE /idxgc/s_proc_data,
                   <fs_proc_step_data> TYPE /idxgc/s_proc_step_data,
                   <fv_int_ui>         TYPE int_ui,
                   <fs_eastl>          TYPE eastl.

    TRY.
***** 1. Daten in PDoc schreiben, Art der Änderung(en) und AMID ermitteln *************************
        lt_proc_data = /adesso/cl_mdc_datex_utility=>get_proc_data_billinginst( is_old_data = x_old_data is_changed_data = x_changed_data ).

***** 2. Zählpunkte zu den Änderungen ermitteln ***************************************************
        LOOP AT x_changed_data-eastl_tab ASSIGNING <fs_eastl>.
          APPEND LINES OF get_pods( iv_anlage = <fs_eastl>-anlage ) TO lt_int_ui.
        ENDLOOP.

        SORT lt_int_ui.
        DELETE ADJACENT DUPLICATES FROM lt_int_ui.

***** 3. Prüfungen und ggf. Prozess starten für alle Zählpunkte ************************************
        LOOP AT lt_proc_data ASSIGNING <fs_proc_data>.
          LOOP AT lt_int_ui ASSIGNING <fv_int_ui>.
            CLEAR: ls_proc_data.
            ls_proc_data = <fs_proc_data>.
            ls_proc_data-int_ui = <fv_int_ui>.
            READ TABLE ls_proc_data-steps ASSIGNING <fs_proc_step_data> INDEX 1.

*---- 3.1 Empfänger und BMID ermitteln ------------------------------------------------------------
            /adesso/cl_mdc_datex_utility=>add_servprovs_and_bmid( CHANGING cs_proc_data = ls_proc_data ).
            CHECK <fs_proc_step_data>-own_servprov   IS NOT INITIAL AND
                  <fs_proc_step_data>-assoc_servprov IS NOT INITIAL AND
                  <fs_proc_step_data>-bmid           IS NOT INITIAL.

*---- 3.2 Prozessdaten vervollständigen -----------------------------------------------------------
            /adesso/cl_mdc_datex_utility=>enhance_proc_data( CHANGING cs_proc_data = ls_proc_data ).

*---- 3.3. Prüfung: Datenaustausch aktiv? ---------------------------------------------------------
            CHECK /adesso/cl_mdc_datex_utility=>get_send_flag_from_datex( iv_int_ui = <fv_int_ui> ) = abap_true.

*---- 3.4. Update der gesendeten Änderung entsprechend der Customizing Einstellungen --------------
            /adesso/cl_mdc_datex_utility=>update_mtd_code_result( CHANGING cs_proc_data = ls_proc_data ).
            CHECK <fs_proc_step_data>-mtd_code_result IS NOT INITIAL.

*---- 3.5. Prüfung: Kundenindividuelle Prüfung ----------------------------------------------------
            lv_flag_send = abap_true.

            TRY.
                GET BADI lr_badi_mdc_dtx_billingin
                  FILTERS
                    mandt = sy-mandt
                    sysid = sy-sysid.
              CATCH cx_badi_not_implemented.
                "Das BAdI muss nicht implementiert sein.
            ENDTRY.

            IF lr_badi_mdc_dtx_billingin IS NOT INITIAL.
              CALL BADI lr_badi_mdc_dtx_billingin->change_proc_data_and_send_flag
                EXPORTING
                  is_changed_data = x_changed_data
                  is_old_data     = x_old_data
                CHANGING
                  cs_proc_data    = ls_proc_data
                  cv_flag_send    = lv_flag_send.
            ENDIF.

            CHECK lv_flag_send = abap_true.

*---- 3.6 Prüfen, ob schon SDÄ existiert und als Schritt hinzufügen -------------------------------
*OPTIONAL: Hier können so SDÄ gesammelt werden.
*Abgleich: Empfänger, AMID und Prozess muss noch im Warteschritt hängen zu Beginn.

*---- 3.7 PDoc erzeugen und Prozess starten -------------------------------------------------------
            /idxgc/cl_process_trigger=>start_process( EXPORTING iv_pdoc_display = abap_false CHANGING cs_process_data = ls_proc_data ).

          ENDLOOP.
        ENDLOOP.

*---- 3.8 Fehlerbehandlung: Error PDoc ------------------------------------------------------------
      CATCH /idxgc/cx_general INTO gr_previous.
        TRY.
            CLEAR: gt_message, gs_message.
            MOVE-CORRESPONDING sy TO gs_message.
            APPEND gs_message TO gt_message.
            IF ls_proc_data IS INITIAL.
              READ TABLE lt_proc_data INTO ls_proc_data INDEX 1.
            ENDIF.
            /adesso/cl_mdc_datex_utility=>create_error_pdoc( is_proc_data = ls_proc_data it_message = gt_message ).
          CATCH /idxgc/cx_general INTO gr_previous.
            RAISE error_occurred.
        ENDTRY.
    ENDTRY.

  ENDMETHOD.


  METHOD if_ex_isu_ide_datexconnect~datexconnect_coaddr_changed.
    DATA: lr_badi_mdc_dtx_coaddr TYPE REF TO /adesso/badi_mdc_dtx_coaddr,
          lt_int_ui              TYPE int_ui_table,
          lt_proc_data           TYPE /idxgc/t_proc_data,
          lt_message             TYPE tisu00_message,
          ls_proc_data           TYPE  /idxgc/s_proc_data,
          ls_message             TYPE isu00_message,
          lv_flag_send           TYPE /adesso/mdc_flag_send.

    FIELD-SYMBOLS: <fs_proc_data>      TYPE /idxgc/s_proc_data,
                   <fs_proc_step_data> TYPE /idxgc/s_proc_step_data,
                   <fv_int_ui>         TYPE int_ui.

    TRY.
***** 1. Daten in PDoc schreiben, Art der Änderung(en) und AMID ermitteln *************************
        lt_proc_data = /adesso/cl_mdc_datex_utility=>get_proc_data_coaddr( iv_addr_ref = x_addr_ref is_addr1_val_new = x_addr1_val_new
                                                                           is_addr1_val_old = x_addr1_val_old ).

***** 2. Zählpunkte zu den Änderungen ermitteln ***************************************************
        lt_int_ui = get_pods( iv_addrnum = x_addr1_val_old-addrnumber ).

***** 3. Prüfungen und ggf. Prozess starten für alle Zählpunkte ************************************
        LOOP AT lt_proc_data ASSIGNING <fs_proc_data>.
          LOOP AT lt_int_ui ASSIGNING <fv_int_ui>.
            CLEAR: ls_proc_data.
            ls_proc_data = <fs_proc_data>.
            ls_proc_data-int_ui = <fv_int_ui>.
            READ TABLE ls_proc_data-steps ASSIGNING <fs_proc_step_data> INDEX 1.

*---- 3.1 Empfänger und BMID ermitteln ------------------------------------------------------------
            /adesso/cl_mdc_datex_utility=>add_servprovs_and_bmid( CHANGING cs_proc_data = ls_proc_data ).
            CHECK <fs_proc_step_data>-own_servprov   IS NOT INITIAL AND
                  <fs_proc_step_data>-assoc_servprov IS NOT INITIAL AND
                  <fs_proc_step_data>-bmid           IS NOT INITIAL.

*---- 3.2 Prozessdaten vervollständigen -----------------------------------------------------------
            /adesso/cl_mdc_datex_utility=>enhance_proc_data( CHANGING cs_proc_data = ls_proc_data ).

*---- 3.3. Prüfung: Datenaustausch aktiv? ---------------------------------------------------------
            CHECK /adesso/cl_mdc_datex_utility=>get_send_flag_from_datex( iv_int_ui = <fv_int_ui> ) = abap_true.

*---- 3.4. Update der gesendeten Änderung entsprechend der Customizing Einstellungen --------------
            /adesso/cl_mdc_datex_utility=>update_mtd_code_result( CHANGING cs_proc_data = ls_proc_data ).
            CHECK <fs_proc_step_data>-mtd_code_result IS NOT INITIAL.

*---- 3.5. Prüfung: Kundenindividuelle Prüfung ----------------------------------------------------
            lv_flag_send = abap_true.

            TRY.
                GET BADI lr_badi_mdc_dtx_coaddr
                  FILTERS
                    mandt = sy-mandt
                    sysid = sy-sysid.
              CATCH cx_badi_not_implemented.
                "Das BAdI muss nicht implementiert sein.
            ENDTRY.

            IF lr_badi_mdc_dtx_coaddr IS NOT INITIAL.
              CALL BADI lr_badi_mdc_dtx_coaddr->change_proc_data_and_send_flag
                EXPORTING
                  iv_addr_ref      = x_addr_ref
                  is_addr1_val_new = x_addr1_val_new
                  is_addr1_val_old = x_addr1_val_old
                CHANGING
                  cs_proc_data     = ls_proc_data
                  cv_flag_send     = lv_flag_send.
            ENDIF.

            CHECK lv_flag_send = abap_true.

*---- 3.6 Prüfen, ob schon SDÄ existiert und als Schritt hinzufügen -------------------------------
*OPTIONAL: Hier können so SDÄ gesammelt werden.
*Abgleich: Empfänger, AMID und Prozess muss noch im Warteschritt hängen zu Beginn.

*---- 3.7 PDoc erzeugen und Prozess starten -------------------------------------------------------
            /idxgc/cl_process_trigger=>start_process( EXPORTING iv_pdoc_display = abap_false CHANGING cs_process_data = ls_proc_data ).

          ENDLOOP.
        ENDLOOP.

*---- 3.8 Fehlerbehandlung: Error PDoc ------------------------------------------------------------
      CATCH /idxgc/cx_general INTO gr_previous.
        TRY.
            CLEAR: gt_message, gs_message.
            MOVE-CORRESPONDING sy TO gs_message.
            APPEND gs_message TO gt_message.
            IF ls_proc_data IS INITIAL.
              READ TABLE lt_proc_data INTO ls_proc_data INDEX 1.
            ENDIF.
            /adesso/cl_mdc_datex_utility=>create_error_pdoc( is_proc_data = ls_proc_data it_message = gt_message ).
          CATCH /idxgc/cx_general INTO gr_previous.
            RAISE error_occurred.
        ENDTRY.
    ENDTRY.

  ENDMETHOD.


  METHOD if_ex_isu_ide_datexconnect~datexconnect_contract_changed.
    DATA: lr_badi_mdc_dtx_contract TYPE REF TO /adesso/badi_mdc_dtx_contract,
          lt_int_ui                TYPE int_ui_table,
          lt_proc_data             TYPE /idxgc/t_proc_data,
          lt_message               TYPE tisu00_message,
          ls_proc_data             TYPE  /idxgc/s_proc_data,
          ls_message               TYPE isu00_message,
          lv_flag_send             TYPE /adesso/mdc_flag_send.

    FIELD-SYMBOLS: <fs_proc_data>      TYPE /idxgc/s_proc_data,
                   <fs_proc_step_data> TYPE /idxgc/s_proc_step_data,
                   <fv_int_ui>         TYPE int_ui.

    TRY.
***** 1. Daten in PDoc schreiben, Art der Änderung(en) und AMID ermitteln *************************
        lt_proc_data = /adesso/cl_mdc_datex_utility=>get_proc_data_contract( is_ever_old = x_ever_old is_ever_new = x_ever_new ).

***** 2. Zählpunkte zu den Änderungen ermitteln ***************************************************
        lt_int_ui = get_pods( iv_vertrag = x_ever_new-vertrag ).

***** 3. Prüfungen und ggf. Prozess starten für alle Zählpunkte ***********************************
        LOOP AT lt_proc_data ASSIGNING <fs_proc_data>.
          LOOP AT lt_int_ui ASSIGNING <fv_int_ui>.
            CLEAR: ls_proc_data.
            ls_proc_data = <fs_proc_data>.
            ls_proc_data-int_ui = <fv_int_ui>.
            READ TABLE ls_proc_data-steps ASSIGNING <fs_proc_step_data> INDEX 1.

*---- 3.1 Empfänger und BMID ermitteln ------------------------------------------------------------
            /adesso/cl_mdc_datex_utility=>add_servprovs_and_bmid( CHANGING cs_proc_data = ls_proc_data ).
            CHECK <fs_proc_step_data>-own_servprov   IS NOT INITIAL AND
                  <fs_proc_step_data>-assoc_servprov IS NOT INITIAL AND
                  <fs_proc_step_data>-bmid           IS NOT INITIAL.

*---- 3.2 Prozessdaten vervollständigen -----------------------------------------------------------
            /adesso/cl_mdc_datex_utility=>enhance_proc_data( CHANGING cs_proc_data = ls_proc_data ).

*---- 3.3. Prüfung: Datenaustausch aktiv? ---------------------------------------------------------
            CHECK /adesso/cl_mdc_datex_utility=>get_send_flag_from_datex( iv_int_ui = <fv_int_ui> ) = abap_true.

*---- 3.4. Update der gesendeten Änderung entsprechend der Customizing Einstellungen --------------
            /adesso/cl_mdc_datex_utility=>update_mtd_code_result( CHANGING cs_proc_data = ls_proc_data ).
            CHECK <fs_proc_step_data>-mtd_code_result IS NOT INITIAL.

*---- 3.5. Prüfung: Kundenindividuelle Prüfung ----------------------------------------------------
            lv_flag_send = abap_true.

            TRY.
                GET BADI lr_badi_mdc_dtx_contract
                  FILTERS
                    mandt = sy-mandt
                    sysid = sy-sysid.
              CATCH cx_badi_not_implemented.
                "Das BAdI muss nicht implementiert sein.
            ENDTRY.

            IF lr_badi_mdc_dtx_contract IS NOT INITIAL.
              CALL BADI lr_badi_mdc_dtx_contract->change_proc_data_and_send_flag
                EXPORTING
                  is_ever_old  = x_ever_old
                  is_ever_new  = x_ever_new
                CHANGING
                  cs_proc_data = ls_proc_data
                  cv_flag_send = lv_flag_send.
            ENDIF.

            CHECK lv_flag_send = abap_true.

*---- 3.6 Prüfen, ob schon SDÄ existiert und als Schritt hinzufügen -------------------------------
*OPTIONAL: Hier können so SDÄ gesammelt werden.
*Abgleich: Empfänger, AMID und Prozess muss noch im Warteschritt hängen zu Beginn.

*---- 3.7 PDoc erzeugen und Prozess starten -------------------------------------------------------
            /idxgc/cl_process_trigger=>start_process( EXPORTING iv_pdoc_display = abap_false CHANGING cs_process_data = ls_proc_data ).

          ENDLOOP.
        ENDLOOP.

*---- 3.8 Fehlerbehandlung: Error PDoc ------------------------------------------------------------
      CATCH /idxgc/cx_general INTO gr_previous.
        TRY.
            CLEAR: gt_message, gs_message.
            MOVE-CORRESPONDING sy TO gs_message.
            APPEND gs_message TO gt_message.
            IF ls_proc_data IS INITIAL.
              READ TABLE lt_proc_data INTO ls_proc_data INDEX 1.
            ENDIF.
            /adesso/cl_mdc_datex_utility=>create_error_pdoc( is_proc_data = ls_proc_data it_message = gt_message ).
          CATCH /idxgc/cx_general INTO gr_previous.
            RAISE error_occurred.
        ENDTRY.
    ENDTRY.

  ENDMETHOD.


  METHOD if_ex_isu_ide_datexconnect~datexconnect_instfacts_chng.
    DATA:
      lr_badi_mdc_dtx_instfacts TYPE REF TO /adesso/badi_mdc_dtx_instfacts,
      lt_int_ui                 TYPE int_ui_table,
      ls_proc_data              TYPE /idxgc/s_proc_data,
      lt_proc_data              TYPE /idxgc/t_proc_data,
      lv_flag_send              TYPE /adesso/mdc_flag_send,
      lt_message                TYPE tisu00_message,
      ls_message                TYPE isu00_message.
    FIELD-SYMBOLS:
      <fs_proc_data>      TYPE /idxgc/s_proc_data,
      <fs_proc_step_data> TYPE /idxgc/s_proc_step_data,
      <fv_int_ui>         TYPE int_ui,
      <fs_facts>          TYPE ettif.

    TRY.
***** 1. Daten in PDoc schreiben, Art der Änderung(en) und AMID ermitteln *************************
        lt_proc_data = /adesso/cl_mdc_datex_utility=>get_proc_data_instfacts( it_new_facts = xt_new_facts it_old_facts = xt_old_facts ).

***** 2. Zählpunkte zu den Änderungen ermitteln ***************************************************
        READ TABLE xt_new_facts ASSIGNING <fs_facts> INDEX 1.
        lt_int_ui = get_pods( iv_anlage = <fs_facts>-anlage ).

***** 3. Prüfungen und ggf. Prozess starten für alle Zählpunkte ************************************
        LOOP AT lt_proc_data ASSIGNING <fs_proc_data>.
          LOOP AT lt_int_ui ASSIGNING <fv_int_ui>.
            CLEAR: ls_proc_data.
            ls_proc_data = <fs_proc_data>.
            ls_proc_data-int_ui = <fv_int_ui>.
            READ TABLE ls_proc_data-steps ASSIGNING <fs_proc_step_data> INDEX 1.

*---- 3.1 Empfänger und BMID ermitteln ------------------------------------------------------------
            /adesso/cl_mdc_datex_utility=>add_servprovs_and_bmid( CHANGING cs_proc_data = ls_proc_data ).
            CHECK <fs_proc_step_data>-own_servprov   IS NOT INITIAL AND
                  <fs_proc_step_data>-assoc_servprov IS NOT INITIAL AND
                  <fs_proc_step_data>-bmid           IS NOT INITIAL.

*---- 3.2 Prozessdaten vervollständigen -----------------------------------------------------------
            /adesso/cl_mdc_datex_utility=>enhance_proc_data( CHANGING cs_proc_data = ls_proc_data ).

*---- 3.3. Prüfung: Datenaustausch aktiv? ---------------------------------------------------------
            CHECK /adesso/cl_mdc_datex_utility=>get_send_flag_from_datex( iv_int_ui = <fv_int_ui> ) = abap_true.

*---- 3.4. Update der gesendeten Änderung entsprechend der Customizing Einstellungen --------------
            /adesso/cl_mdc_datex_utility=>update_mtd_code_result( CHANGING cs_proc_data = ls_proc_data ).
            CHECK <fs_proc_step_data>-mtd_code_result IS NOT INITIAL.


*---- 3.5. Prüfung: Kundenindividuelle Prüfung ----------------------------------------------------
            lv_flag_send = abap_true.

            TRY.
                GET BADI lr_badi_mdc_dtx_instfacts
                  FILTERS
                    mandt = sy-mandt
                    sysid = sy-sysid.
              CATCH cx_badi_not_implemented.
                "Das BAdI muss nicht implementiert sein.
            ENDTRY.

            IF lr_badi_mdc_dtx_instfacts IS NOT INITIAL.
              CALL BADI lr_badi_mdc_dtx_instfacts->change_proc_data_and_send_flag
                EXPORTING
                  it_new_facts = xt_new_facts
                  it_old_facts = xt_old_facts
                CHANGING
                  cs_proc_data = ls_proc_data
                  cv_flag_send = lv_flag_send.
            ENDIF.

            CHECK lv_flag_send = abap_true.

*---- 3.6 PDoc erzeugen und Prozess starten -------------------------------------------------------
            /idxgc/cl_process_trigger=>start_process( EXPORTING iv_pdoc_display = abap_false CHANGING cs_process_data = ls_proc_data ).

          ENDLOOP.
        ENDLOOP.

*---- 3.8 Fehlerbehandlung: Error PDoc ------------------------------------------------------------
      CATCH /idxgc/cx_general INTO gr_previous.
        TRY.
            CLEAR: gt_message, gs_message.
            MOVE-CORRESPONDING sy TO gs_message.
            APPEND gs_message TO gt_message.
            IF ls_proc_data IS INITIAL.
              READ TABLE lt_proc_data INTO ls_proc_data INDEX 1.
            ENDIF.
            /adesso/cl_mdc_datex_utility=>create_error_pdoc( is_proc_data = ls_proc_data it_message = gt_message ).
          CATCH /idxgc/cx_general INTO gr_previous.
            RAISE error_occurred.
        ENDTRY.
    ENDTRY.

  ENDMETHOD.


  METHOD if_ex_isu_ide_datexconnect~datexconnect_instln_changed.
    DATA: lr_badi_mdc_dtx_instln TYPE REF TO /adesso/badi_mdc_dtx_instln,
          lt_int_ui              TYPE int_ui_table,
          lt_proc_data           TYPE /idxgc/t_proc_data,
          lt_message             TYPE tisu00_message,
          ls_proc_data           TYPE /idxgc/s_proc_data,
          ls_message             TYPE isu00_message,
          lv_flag_send           TYPE /adesso/mdc_flag_send.

    FIELD-SYMBOLS: <fs_proc_data>      TYPE /idxgc/s_proc_data,
                   <fs_proc_step_data> TYPE /idxgc/s_proc_step_data,
                   <fv_int_ui>         TYPE int_ui.

    TRY.
***** 1. Daten in PDoc schreiben, Art der Änderung(en) und AMID ermitteln *************************
        lt_proc_data = /adesso/cl_mdc_datex_utility=>get_proc_data_instln( is_changed_data = x_changed_data ).

***** 2. Zählpunkte zu den Änderungen ermitteln ***************************************************
        lt_int_ui = get_pods( iv_anlage = x_changed_data-eanl_new-anlage ).

***** 3. Prüfungen und ggf. Prozess starten für alle Zählpunkte ************************************
        LOOP AT lt_proc_data ASSIGNING <fs_proc_data>.
          LOOP AT lt_int_ui ASSIGNING <fv_int_ui>.
            CLEAR: ls_proc_data.
            ls_proc_data = <fs_proc_data>.
            ls_proc_data-int_ui = <fv_int_ui>.
            READ TABLE ls_proc_data-steps ASSIGNING <fs_proc_step_data> INDEX 1.

*---- 3.1 Empfänger und BMID ermitteln ------------------------------------------------------------
            /adesso/cl_mdc_datex_utility=>add_servprovs_and_bmid( CHANGING cs_proc_data = ls_proc_data ).
            CHECK <fs_proc_step_data>-own_servprov   IS NOT INITIAL AND
                  <fs_proc_step_data>-assoc_servprov IS NOT INITIAL AND
                  <fs_proc_step_data>-bmid           IS NOT INITIAL.

*---- 3.2 Prozessdaten vervollständigen -----------------------------------------------------------
            /adesso/cl_mdc_datex_utility=>enhance_proc_data( CHANGING cs_proc_data = ls_proc_data ).

*---- 3.3. Prüfung: Datenaustausch aktiv? ---------------------------------------------------------
            CHECK /adesso/cl_mdc_datex_utility=>get_send_flag_from_datex( iv_int_ui = <fv_int_ui> ) = abap_true.

*---- 3.4. Update der gesendeten Änderung entsprechend der Customizing Einstellungen --------------
            /adesso/cl_mdc_datex_utility=>update_mtd_code_result( CHANGING cs_proc_data = ls_proc_data ).
            CHECK <fs_proc_step_data>-mtd_code_result IS NOT INITIAL.

*---- 3.5. Prüfung: Kundenindividuelle Prüfung ----------------------------------------------------
            lv_flag_send = abap_true.

            TRY.
                GET BADI lr_badi_mdc_dtx_instln
                  FILTERS
                    mandt = sy-mandt
                    sysid = sy-sysid.
              CATCH cx_badi_not_implemented.
                "Das BAdI muss nicht implementiert sein.
            ENDTRY.

            IF lr_badi_mdc_dtx_instln IS NOT INITIAL.
              CALL BADI lr_badi_mdc_dtx_instln->change_proc_data_and_send_flag
                EXPORTING
                  is_changed_data = x_changed_data
                CHANGING
                  cs_proc_data    = ls_proc_data
                  cv_flag_send    = lv_flag_send.
            ENDIF.

            CHECK lv_flag_send = abap_true.

*---- 3.6 Prüfen, ob schon SDÄ existiert und als Schritt hinzufügen -------------------------------
*OPTIONAL: Hier können so SDÄ gesammelt werden.
*Abgleich: Empfänger, AMID und Prozess muss noch im Warteschritt hängen zu Beginn.


*---- 3.7 PDoc erzeugen und Prozess starten -------------------------------------------------------
            /idxgc/cl_process_trigger=>start_process( EXPORTING iv_pdoc_display = abap_false CHANGING cs_process_data = ls_proc_data ).

          ENDLOOP.
        ENDLOOP.

*---- 3.8 Fehlerbehandlung: Error PDoc ------------------------------------------------------------
      CATCH /idxgc/cx_general INTO gr_previous.
        TRY.
            CLEAR: gt_message, gs_message.
            MOVE-CORRESPONDING sy TO gs_message.
            APPEND gs_message TO gt_message.
            IF ls_proc_data IS INITIAL.
              READ TABLE lt_proc_data INTO ls_proc_data INDEX 1.
            ENDIF.
            /adesso/cl_mdc_datex_utility=>create_error_pdoc( is_proc_data = ls_proc_data it_message = gt_message ).
          CATCH /idxgc/cx_general INTO gr_previous.
            RAISE error_occurred.
        ENDTRY.
    ENDTRY.

  ENDMETHOD.


  METHOD if_ex_isu_ide_datexconnect~datexconnect_lpass_changed.
    DATA: lr_badi_mdc_dtx_lpass TYPE REF TO /adesso/badi_mdc_dtx_lpass,
          lt_anlage             TYPE TABLE OF anlage,
          lt_int_ui             TYPE int_ui_table,
          lt_proc_data          TYPE /idxgc/t_proc_data,
          ls_proc_data          TYPE /idxgc/s_proc_data,
          lv_flag_send          TYPE /adesso/mdc_flag_send,
          lv_anlage             TYPE anlage.

    FIELD-SYMBOLS: <fs_proc_data> TYPE /idxgc/s_proc_data,
                   <fs_proc_step_data> TYPE /idxgc/s_proc_step_data,
                   <fv_int_ui>    TYPE int_ui,
                   <fs_elpass>    TYPE elpass,
                   <fv_anlage>    TYPE anlage.

    TRY.
***** 1. Daten in PDoc schreiben, Art der Änderung(en) und AMID ermitteln *************************
        lt_proc_data = /adesso/cl_mdc_datex_utility=>get_proc_data_lpass( is_old_data = x_old_data is_new_data = x_new_data ).

***** 2. Zählpunkte zu den Änderungen ermitteln ***************************************************
        LOOP AT x_new_data-ielpass ASSIGNING <fs_elpass> WHERE objtype = 'INSTLN'.
          lv_anlage = <fs_elpass>-objkey.
          COLLECT lv_anlage INTO lt_anlage.
        ENDLOOP.

        LOOP AT lt_anlage ASSIGNING <fv_anlage>.
          lt_int_ui = get_pods( iv_anlage = <fv_anlage> ).

***** 3. Prüfungen und ggf. Prozess starten für alle Zählpunkte ************************************
          LOOP AT lt_proc_data ASSIGNING <fs_proc_data>.
            LOOP AT lt_int_ui ASSIGNING <fv_int_ui>.
              CLEAR: ls_proc_data.
              ls_proc_data = <fs_proc_data>.
              ls_proc_data-int_ui = <fv_int_ui>.
              READ TABLE ls_proc_data-steps ASSIGNING <fs_proc_step_data> INDEX 1.

*---- 3.1 Empfänger ermitteln ---------------------------------------------------------------------
              /adesso/cl_mdc_datex_utility=>add_servprovs_to_proc_data( CHANGING cs_proc_data = ls_proc_data ).

*---- 3.2 Prozessdaten vervollständigen -----------------------------------------------------------
              /adesso/cl_mdc_datex_utility=>enhance_proc_data( CHANGING cs_proc_data = ls_proc_data ).

*---- 3.3. Prüfung: Datenaustausch aktiv? ---------------------------------------------------------
              CHECK /adesso/cl_mdc_datex_utility=>get_send_flag_from_datex( iv_int_ui = <fv_int_ui> ) = abap_true.

*---- 3.4. Update der gesendeten Änderung entsprechend der Customizing Einstellungen --------------
              /adesso/cl_mdc_datex_utility=>update_mtd_code_result( CHANGING cs_proc_data = ls_proc_data ).
              CHECK <fs_proc_step_data>-mtd_code_result IS NOT INITIAL.

*---- 3.5. Prüfung: Kundenindividuelle Prüfung ----------------------------------------------------
              lv_flag_send = abap_true.

              TRY.
                  GET BADI lr_badi_mdc_dtx_lpass
                    FILTERS
                      mandt = sy-mandt
                      sysid = sy-sysid.
                CATCH cx_badi_not_implemented.
                  "Das BAdI muss nicht implementiert sein.
              ENDTRY.

              IF lr_badi_mdc_dtx_lpass IS NOT INITIAL.
                CALL BADI lr_badi_mdc_dtx_lpass->change_proc_data_and_send_flag
                  EXPORTING
                    is_old_data  = x_old_data
                    is_new_data  = x_new_data
                  CHANGING
                    cs_proc_data = ls_proc_data
                    cv_flag_send = lv_flag_send.
              ENDIF.

              CHECK lv_flag_send = abap_true.

*---- 3.6 Prüfen, ob schon SDÄ existiert und als Schritt hinzufügen -------------------------------
*OPTIONAL: Hier können so SDÄ gesammelt werden.
*Abgleich: Empfänger, AMID und Prozess muss noch im Warteschritt hängen zu Beginn.

*---- 3.7 PDoc erzeugen und Prozess starten -------------------------------------------------------
              /idxgc/cl_process_trigger=>start_process( EXPORTING iv_pdoc_display = abap_false CHANGING cs_process_data = <fs_proc_data> ).

            ENDLOOP.
          ENDLOOP.
        ENDLOOP.

*---- 3.8 Fehlerbehandlung: Error PDoc ------------------------------------------------------------
      CATCH /idxgc/cx_general INTO gr_previous.
        TRY.
            CLEAR: gt_message, gs_message.
            MOVE-CORRESPONDING sy TO gs_message.
            APPEND gs_message TO gt_message.
            IF ls_proc_data IS INITIAL.
              READ TABLE lt_proc_data INTO ls_proc_data INDEX 1.
            ENDIF.
            /adesso/cl_mdc_datex_utility=>create_error_pdoc( is_proc_data = ls_proc_data it_message = gt_message ).
          CATCH /idxgc/cx_general INTO gr_previous.
            RAISE error_occurred.
        ENDTRY.
    ENDTRY.

  ENDMETHOD.


  METHOD if_ex_isu_ide_datexconnect~datexconnect_nbservice_changed.
    DATA: lr_badi_mdc_dtx_nbservice TYPE REF TO /adesso/badi_mdc_dtx_nbservice,
          lt_int_ui                 TYPE int_ui_table,
          lt_proc_data              TYPE /idxgc/t_proc_data,
          ls_proc_data              TYPE /idxgc/s_proc_data,
          lv_flag_send              TYPE /adesso/mdc_flag_send.

    FIELD-SYMBOLS: <fs_proc_data>      TYPE /idxgc/s_proc_data,
                   <fs_proc_step_data> TYPE /idxgc/s_proc_step_data,
                   <fv_int_ui>         TYPE int_ui.

    TRY.
***** 1. Daten in PDoc schreiben, Art der Änderung(en) und AMID ermitteln *************************
        lt_proc_data = /adesso/cl_mdc_datex_utility=>get_proc_data_nbservice( is_eservice_old = x_eservice_old is_eservice_new = x_eservice_new
                                                                                                            iv_upd_mode = x_upd_mode ).
***** 2. Zählpunkte zu den Änderungen ermitteln ***************************************************
        ASSIGN x_eservice_new-int_ui TO <fv_int_ui>.

***** 3. Prüfungen und ggf. Prozess starten für alle Zählpunkte ***********************************
        LOOP AT lt_proc_data ASSIGNING <fs_proc_data>.
          CLEAR: ls_proc_data.
          ls_proc_data = <fs_proc_data>.
          ls_proc_data-int_ui = <fv_int_ui>.
          READ TABLE ls_proc_data-steps ASSIGNING <fs_proc_step_data> INDEX 1.

*---- 3.1 Empfänger ermitteln ---------------------------------------------------------------------
          /adesso/cl_mdc_datex_utility=>add_servprovs_to_proc_data( CHANGING cs_proc_data = ls_proc_data ).
          CHECK <fs_proc_step_data>-own_servprov   IS NOT INITIAL AND
                <fs_proc_step_data>-assoc_servprov IS NOT INITIAL AND
                <fs_proc_step_data>-bmid           IS NOT INITIAL.

*---- 3.2 Prozessdaten vervollständigen -----------------------------------------------------------
          /adesso/cl_mdc_datex_utility=>enhance_proc_data( CHANGING cs_proc_data = ls_proc_data ).

*---- 3.3. Prüfung: Datenaustausch aktiv? ---------------------------------------------------------
          CHECK /adesso/cl_mdc_datex_utility=>get_send_flag_from_datex( iv_int_ui = <fv_int_ui> ) = abap_true.

*---- 3.4. Update der gesendeten Änderung entsprechend der Customizing Einstellungen --------------
          /adesso/cl_mdc_datex_utility=>update_mtd_code_result( CHANGING cs_proc_data = ls_proc_data ).
          CHECK <fs_proc_step_data>-mtd_code_result IS NOT INITIAL.

*---- 3.5. Prüfung: Kundenindividuelle Prüfung ----------------------------------------------------
          lv_flag_send = abap_true.

          TRY.
              GET BADI lr_badi_mdc_dtx_nbservice
                FILTERS
                  mandt = sy-mandt
                  sysid = sy-sysid.
            CATCH cx_badi_not_implemented.
              "Das BAdI muss nicht implementiert sein.
          ENDTRY.

          IF lr_badi_mdc_dtx_nbservice IS NOT INITIAL.
            CALL BADI lr_badi_mdc_dtx_nbservice->change_proc_data_and_send_flag
              EXPORTING
                is_eservice_old = x_eservice_old
                is_eservice_new = x_eservice_new
                iv_upd_mode     = x_upd_mode
              CHANGING
                cs_proc_data    = ls_proc_data
                cv_flag_send    = lv_flag_send.
          ENDIF.

          CHECK lv_flag_send = abap_true.

*---- 3.6 Prüfen, ob schon SDÄ existiert und als Schritt hinzufügen -------------------------------
*OPTIONAL: Hier können so SDÄ gesammelt werden.
*Abgleich: Empfänger, AMID und Prozess muss noch im Warteschritt hängen zu Beginn.

*---- 3.7 PDoc erzeugen und Prozess starten -------------------------------------------------------
          /idxgc/cl_process_trigger=>start_process( EXPORTING iv_pdoc_display = abap_false CHANGING cs_process_data = ls_proc_data ).

        ENDLOOP.

*---- 3.8 Fehlerbehandlung: Error PDoc ------------------------------------------------------------
      CATCH /idxgc/cx_general INTO gr_previous.
        TRY.
            CLEAR: gt_message, gs_message.
            MOVE-CORRESPONDING sy TO gs_message.
            APPEND gs_message TO gt_message.
            IF ls_proc_data IS INITIAL.
              READ TABLE lt_proc_data INTO ls_proc_data INDEX 1.
            ENDIF.
            /adesso/cl_mdc_datex_utility=>create_error_pdoc( is_proc_data = ls_proc_data it_message = gt_message ).
          CATCH /idxgc/cx_general INTO gr_previous.
            RAISE error_occurred.
        ENDTRY.
    ENDTRY.

  ENDMETHOD.


  METHOD if_ex_isu_ide_datexconnect~datexconnect_partner_changed.
    DATA: lr_badi_mdc_dtx_partner TYPE REF TO /adesso/badi_mdc_dtx_partner,
          lt_int_ui               TYPE int_ui_table,
          lt_proc_data            TYPE /idxgc/t_proc_data,
          ls_proc_data            TYPE  /idxgc/s_proc_data,
          lv_flag_send            TYPE /adesso/mdc_flag_send.

    FIELD-SYMBOLS: <fs_proc_data>      TYPE /idxgc/s_proc_data,
                   <fs_proc_step_data> TYPE /idxgc/s_proc_step_data,
                   <fv_int_ui>         TYPE int_ui.

    TRY.
***** 1. Daten in PDoc schreiben, Art der Änderung(en) und AMID ermitteln *************************
        lt_proc_data = /adesso/cl_mdc_datex_utility=>get_proc_data_partner( is_old_data = x_old_data is_new_data = x_new_data
                                                                            is_bp_crm_data = x_bp_crm_data iv_bp_id = x_bp_id ).

***** 2. Zählpunkte zu den Änderungen ermitteln ***************************************************
        lt_int_ui = get_pods( iv_bu_partner = x_new_data-ekun-partner ).

***** 3. Prüfungen und ggf. Prozess starten für alle Zählpunkte ***********************************
        LOOP AT lt_proc_data ASSIGNING <fs_proc_data>.
          LOOP AT lt_int_ui ASSIGNING <fv_int_ui>.
            CLEAR: ls_proc_data.
            ls_proc_data = <fs_proc_data>.
            ls_proc_data-int_ui = <fv_int_ui>.
            READ TABLE ls_proc_data-steps ASSIGNING <fs_proc_step_data> INDEX 1.

*---- 3.1 Empfänger und BMID ermitteln ------------------------------------------------------------
            /adesso/cl_mdc_datex_utility=>add_servprovs_and_bmid( CHANGING cs_proc_data = ls_proc_data ).
            CHECK <fs_proc_step_data>-own_servprov   IS NOT INITIAL AND
                  <fs_proc_step_data>-assoc_servprov IS NOT INITIAL AND
                  <fs_proc_step_data>-bmid           IS NOT INITIAL.

*---- 3.2 Prozessdaten vervollständigen -----------------------------------------------------------
            /adesso/cl_mdc_datex_utility=>enhance_proc_data( EXPORTING iv_partner = x_new_data-ekun-partner CHANGING cs_proc_data = ls_proc_data ).

*---- 3.3. Prüfung: Datenaustausch aktiv? ---------------------------------------------------------
            CHECK /adesso/cl_mdc_datex_utility=>get_send_flag_from_datex( iv_int_ui = <fv_int_ui> ) = abap_true.

*---- 3.4. Update der gesendeten Änderung entsprechend der Customizing Einstellungen --------------
            /adesso/cl_mdc_datex_utility=>update_mtd_code_result( CHANGING cs_proc_data = ls_proc_data ).
            CHECK <fs_proc_step_data>-mtd_code_result IS NOT INITIAL.

*---- 3.5. Prüfung: Kundenindividuelle Prüfung ----------------------------------------------------
            lv_flag_send = abap_true.

            TRY.
                GET BADI lr_badi_mdc_dtx_partner
                  FILTERS
                    mandt = sy-mandt
                    sysid = sy-sysid.
              CATCH cx_badi_not_implemented.
                "Das BAdI muss nicht implementiert sein.
            ENDTRY.

            IF lr_badi_mdc_dtx_partner IS NOT INITIAL.
              CALL BADI lr_badi_mdc_dtx_partner->change_proc_data_and_send_flag
                EXPORTING
                  is_old_data    = x_old_data
                  is_new_data    = x_new_data
                  is_bp_crm_data = x_bp_crm_data
                  iv_bp_id       = x_bp_id
                CHANGING
                  cs_proc_data   = ls_proc_data
                  cv_flag_send   = lv_flag_send.
            ENDIF.

            CHECK lv_flag_send = abap_true.

*---- 3.6 Prüfen, ob schon SDÄ existiert und als Schritt hinzufügen -------------------------------
*OPTIONAL: Hier können so SDÄ gesammelt werden.
*Abgleich: Empfänger, AMID und Prozess muss noch im Warteschritt hängen zu Beginn.

*---- 3.7 PDoc erzeugen und Prozess starten -------------------------------------------------------
            /idxgc/cl_process_trigger=>start_process( EXPORTING iv_pdoc_display = abap_false CHANGING cs_process_data = ls_proc_data ).

          ENDLOOP.
        ENDLOOP.

*---- 3.8 Fehlerbehandlung: Error PDoc ------------------------------------------------------------
      CATCH /idxgc/cx_general INTO gr_previous.
        TRY.
            CLEAR: gt_message, gs_message.
            MOVE-CORRESPONDING sy TO gs_message.
            APPEND gs_message TO gt_message.
            IF ls_proc_data IS INITIAL.
              READ TABLE lt_proc_data INTO ls_proc_data INDEX 1.
            ENDIF.
            /adesso/cl_mdc_datex_utility=>create_error_pdoc( is_proc_data = ls_proc_data it_message = gt_message ).
          CATCH /idxgc/cx_general INTO gr_previous.
            RAISE error_occurred.
        ENDTRY.
    ENDTRY.

  ENDMETHOD.


  METHOD if_ex_isu_ide_datexconnect~datexconnect_pod_changed.
    DATA: lr_badi_mdc_dtx_pod TYPE REF TO /adesso/badi_mdc_dtx_pod,
          lt_int_ui           TYPE int_ui_table,
          lt_proc_data        TYPE /idxgc/t_proc_data,
          lt_message          TYPE tisu00_message,
          ls_proc_data        TYPE  /idxgc/s_proc_data,
          ls_message          TYPE isu00_message,
          lv_flag_send        TYPE /adesso/mdc_flag_send.

    FIELD-SYMBOLS: <fs_proc_data>      TYPE /idxgc/s_proc_data,
                   <fs_proc_step_data> TYPE /idxgc/s_proc_step_data,
                   <fv_int_ui>         TYPE int_ui.

    TRY.
***** 1. Daten in PDoc schreiben, Art der Änderung(en) und AMID ermitteln *************************
        lt_proc_data = /adesso/cl_mdc_datex_utility=>get_proc_data_pod( is_old_data = x_old_data is_new_data = x_new_data ).

****** 2. Zählpunkte zu den Änderungen ermitteln ***************************************************
        ASSIGN x_new_data-ui_data-int_ui TO <fv_int_ui>.

****** 3. Prüfungen und ggf. Prozess starten für alle Zählpunkte ************************************
        LOOP AT lt_proc_data ASSIGNING <fs_proc_data>.
          CLEAR: ls_proc_data.
          ls_proc_data = <fs_proc_data>.
          ls_proc_data-int_ui = <fv_int_ui>.
          READ TABLE ls_proc_data-steps ASSIGNING <fs_proc_step_data> INDEX 1.

*---- 3.1 Empfänger und BMID ermitteln ------------------------------------------------------------
          /adesso/cl_mdc_datex_utility=>add_servprovs_and_bmid( CHANGING cs_proc_data = ls_proc_data ).
          CHECK <fs_proc_step_data>-own_servprov   IS NOT INITIAL AND
                <fs_proc_step_data>-assoc_servprov IS NOT INITIAL AND
                <fs_proc_step_data>-bmid           IS NOT INITIAL.

*---- 3.2 Prozessdaten vervollständigen -----------------------------------------------------------
          /adesso/cl_mdc_datex_utility=>enhance_proc_data( CHANGING cs_proc_data = ls_proc_data ).

*---- 3.3. Prüfung: Datenaustausch aktiv? ---------------------------------------------------------
          CHECK /adesso/cl_mdc_datex_utility=>get_send_flag_from_datex( iv_int_ui = <fv_int_ui> ) = abap_true.

*---- 3.4. Update der gesendeten Änderung entsprechend der Customizing Einstellungen --------------
          /adesso/cl_mdc_datex_utility=>update_mtd_code_result( CHANGING cs_proc_data = ls_proc_data ).
          CHECK <fs_proc_step_data>-mtd_code_result IS NOT INITIAL.

*---- 3.5. Prüfung: Kundenindividuelle Prüfung ----------------------------------------------------
          lv_flag_send = abap_true.

          TRY.
              GET BADI lr_badi_mdc_dtx_pod
                FILTERS
                  mandt = sy-mandt
                  sysid = sy-sysid.
            CATCH cx_badi_not_implemented.
              "Das BAdI muss nicht implementiert sein.
          ENDTRY.

          IF lr_badi_mdc_dtx_pod IS NOT INITIAL.
            CALL BADI lr_badi_mdc_dtx_pod->change_proc_data_and_send_flag
              EXPORTING
                is_old_data  = x_old_data
                is_new_data  = x_new_data
              CHANGING
                cs_proc_data = ls_proc_data
                cv_flag_send = lv_flag_send.
          ENDIF.

          CHECK lv_flag_send = abap_true.

*---- 3.6 Prüfen, ob schon SDÄ existiert und als Schritt hinzufügen -------------------------------
*OPTIONAL: Hier können so SDÄ gesammelt werden.
*Abgleich: Empfänger, AMID und Prozess muss noch im Warteschritt hängen zu Beginn.


*---- 3.7 PDoc erzeugen und Prozess starten -------------------------------------------------------
          /idxgc/cl_process_trigger=>start_process( EXPORTING iv_pdoc_display = abap_false CHANGING cs_process_data = ls_proc_data ).

        ENDLOOP.

*---- 3.8 Fehlerbehandlung: Error PDoc ------------------------------------------------------------
      CATCH /idxgc/cx_general INTO gr_previous.
        TRY.
            MOVE-CORRESPONDING sy TO ls_message.
            APPEND ls_message TO lt_message.
            IF ls_proc_data IS INITIAL.
              READ TABLE lt_proc_data INTO ls_proc_data INDEX 1.
            ENDIF.
            /adesso/cl_mdc_datex_utility=>create_error_pdoc( is_proc_data = ls_proc_data it_message = lt_message ).
          CATCH /idxgc/cx_general INTO gr_previous.
            RAISE error_occurred.
        ENDTRY.
    ENDTRY.

  ENDMETHOD.


  METHOD if_ex_isu_ide_datexconnect~datexconnect_premise_changed.
    DATA: lr_badi_mdc_dtx_premise TYPE REF TO /adesso/badi_mdc_dtx_premise,
          lt_int_ui               TYPE int_ui_table,
          lt_proc_data            TYPE /idxgc/t_proc_data,
          ls_proc_data            TYPE /idxgc/s_proc_data,
          lv_flag_send            TYPE /adesso/mdc_flag_send.
    FIELD-SYMBOLS: <fs_proc_data>      TYPE /idxgc/s_proc_data,
                   <fs_proc_step_data> TYPE /idxgc/s_proc_step_data,
                   <fv_int_ui>         TYPE int_ui.

    TRY.
***** 1. Daten in PDoc schreiben, Art der Änderung(en) und AMID ermitteln *************************
        lt_proc_data = /adesso/cl_mdc_datex_utility=>get_proc_data_premise( is_changed_data = x_changed_data ).

***** 2. Zählpunkte zu den Änderungen ermitteln ***************************************************
        lt_int_ui = get_pods( iv_vstelle  = x_changed_data-evbs_new-vstelle ).

***** 3. Prüfungen und ggf. Prozess starten für alle Zählpunkte ************************************
        LOOP AT lt_proc_data ASSIGNING <fs_proc_data>.
          LOOP AT lt_int_ui ASSIGNING <fv_int_ui>.
            CLEAR: ls_proc_data.
            ls_proc_data = <fs_proc_data>.
            ls_proc_data-int_ui = <fv_int_ui>.
            READ TABLE ls_proc_data-steps ASSIGNING <fs_proc_step_data> INDEX 1.

*---- 3.1 Empfänger und BMID ermitteln ------------------------------------------------------------
            /adesso/cl_mdc_datex_utility=>add_servprovs_and_bmid( CHANGING cs_proc_data = ls_proc_data ).
            CHECK <fs_proc_step_data>-own_servprov   IS NOT INITIAL AND
                  <fs_proc_step_data>-assoc_servprov IS NOT INITIAL AND
                  <fs_proc_step_data>-bmid           IS NOT INITIAL.

*---- 3.2 Prozessdaten vervollständigen -----------------------------------------------------------
            /adesso/cl_mdc_datex_utility=>enhance_proc_data( CHANGING cs_proc_data = ls_proc_data ).

*---- 3.3. Prüfung: Datenaustausch aktiv? ---------------------------------------------------------
            CHECK /adesso/cl_mdc_datex_utility=>get_send_flag_from_datex( iv_int_ui = <fv_int_ui> ) = abap_true.

*---- 3.4. Update der gesendeten Änderung entsprechend der Customizing Einstellungen --------------
            /adesso/cl_mdc_datex_utility=>update_mtd_code_result( CHANGING cs_proc_data = ls_proc_data ).
            CHECK <fs_proc_step_data>-mtd_code_result IS NOT INITIAL.

*---- 3.5. Prüfung: Kundenindividuelle Prüfung ----------------------------------------------------
            lv_flag_send = abap_true.

            TRY.
                GET BADI lr_badi_mdc_dtx_premise
                  FILTERS
                    mandt = sy-mandt
                    sysid = sy-sysid.
              CATCH cx_badi_not_implemented.
                "Das BAdI muss nicht implementiert sein.
            ENDTRY.

            IF lr_badi_mdc_dtx_premise IS NOT INITIAL.
              CALL BADI lr_badi_mdc_dtx_premise->change_proc_data_and_send_flag
                EXPORTING
                  is_changed_data = x_changed_data
                CHANGING
                  cs_proc_data    = ls_proc_data
                  cv_flag_send    = lv_flag_send.
            ENDIF.

            CHECK lv_flag_send = abap_true.

*---- 3.6 Prüfen, ob schon SDÄ existiert und als Schritt hinzufügen -------------------------------
*OPTIONAL: Hier können so SDÄ gesammelt werden.
*Abgleich: Empfänger, AMID und Prozess muss noch im Warteschritt hängen zu Beginn.

*---- 3.7 PDoc erzeugen und Prozess starten -------------------------------------------------------
            /idxgc/cl_process_trigger=>start_process( EXPORTING iv_pdoc_display = abap_false CHANGING cs_process_data = <fs_proc_data> ).

          ENDLOOP.
        ENDLOOP.

*---- 3.8 Fehlerbehandlung: Error PDoc ------------------------------------------------------------
      CATCH /idxgc/cx_general INTO gr_previous.
        TRY.
            CLEAR: gt_message, gs_message.
            MOVE-CORRESPONDING sy TO gs_message.
            APPEND gs_message TO gt_message.
            IF ls_proc_data IS INITIAL.
              READ TABLE lt_proc_data INTO ls_proc_data INDEX 1.
            ENDIF.
            /adesso/cl_mdc_datex_utility=>create_error_pdoc( is_proc_data = ls_proc_data it_message = gt_message ).
          CATCH /idxgc/cx_general INTO gr_previous.
            RAISE error_occurred.
        ENDTRY.
    ENDTRY.

  ENDMETHOD.


  METHOD if_ex_isu_ide_datexconnect~datexconnect_process_invoice.
    DATA: lr_mdc_im_datexconnect TYPE REF TO /adesso/cl_mdc_im_datexconnect,
          lt_exit_obj            TYPE sxrt_exit_tab.

    FIELD-SYMBOLS: <fs_exit_obj> TYPE sxrt_exit_tab_struct.

    CALL METHOD cl_exit_master=>create_obj_by_interface_filter
      EXPORTING
        inter_name                = 'IF_EX_ISU_IDE_DATEXCONNECT'
        method_name               = 'DATEXCONNECT_PROCESS_INVOICE'
        delayed_instance_creation = abap_true
      IMPORTING
        exit_obj_tab              = lt_exit_obj.

    LOOP AT lt_exit_obj ASSIGNING <fs_exit_obj> WHERE active = abap_true.
      CREATE OBJECT lr_mdc_im_datexconnect TYPE (<fs_exit_obj>-imp_class).
      EXIT.
    ENDLOOP.

    CALL METHOD lr_mdc_im_datexconnect->process_invoice
      EXPORTING
        x_invoice         = x_invoice
        x_reverse         = x_reverse
        x_ecrossrefno     = x_ecrossrefno
        xt_erch           = xt_erch
        x_contract        = x_contract
        x_vkont_agg       = x_vkont_agg
        x_old             = x_old
        x_ever            = x_ever
        x_dexservprov     = x_dexservprov
        x_dexservprovself = x_dexservprovself
        x_dexduedate      = x_dexduedate
      IMPORTING
        y_idoc_created    = y_idoc_created
      EXCEPTIONS
        error_occurred    = 1
        no_dexproc_found  = 2.
    IF sy-subrc = 2.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING no_dexproc_found.
    ELSEIF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_occurred.
    ENDIF.
  ENDMETHOD.


  METHOD if_ex_isu_ide_datexconnect~datexconnect_switch_out.
    DATA: lr_mdc_im_datexconnect TYPE REF TO /adesso/cl_mdc_im_datexconnect,
          lt_exit_obj            TYPE sxrt_exit_tab.

    FIELD-SYMBOLS: <fs_exit_obj> TYPE sxrt_exit_tab_struct.

    CALL METHOD cl_exit_master=>create_obj_by_interface_filter
      EXPORTING
        inter_name                = 'IF_EX_ISU_IDE_DATEXCONNECT'
        method_name               = 'DATEXCONNECT_SWITCH_OUT'
        delayed_instance_creation = abap_true
      IMPORTING
        exit_obj_tab              = lt_exit_obj.

    LOOP AT lt_exit_obj ASSIGNING <fs_exit_obj> WHERE active = abap_true.
      CREATE OBJECT lr_mdc_im_datexconnect TYPE (<fs_exit_obj>-imp_class).
      EXIT.
    ENDLOOP.

    CALL METHOD lr_mdc_im_datexconnect->switch_out
      EXPORTING
        x_sender           = x_sender
        x_receiver         = x_receiver
        x_msgdatanum_req   = x_msgdatanum_req
        x_receiver_swtview = x_receiver_swtview
        x_no_event         = x_no_event
        x_no_commit        = x_no_commit
        xt_msgdatacomment  = xt_msgdatacomment
        x_swtact           = x_swtact
      CHANGING
        xy_msgdata         = xy_msgdata
      EXCEPTIONS
        error_occurred     = 1
        no_dexproc_found   = 2
        OTHERS             = 3.
    IF sy-subrc = 2.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING no_dexproc_found.
    elseif sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_occurred.
    ENDIF.

  ENDMETHOD.


  METHOD if_ex_isu_ide_datexconnect~datexconnect_usage_info.
    DATA:
      lr_badi_mdc_dtx_usageinfo TYPE REF TO /adesso/badi_mdc_dtx_usageinfo,
      lt_int_ui                 TYPE int_ui_table,
      lt_proc_data              TYPE /idxgc/t_proc_data,
      ls_proc_data              TYPE /idxgc/s_proc_data,
      lv_flag_send              TYPE /adesso/mdc_flag_send.
    FIELD-SYMBOLS:
      <fs_proc_data> TYPE /idxgc/s_proc_data,
      <fv_int_ui>    TYPE int_ui.

    TRY.
***** 1. Daten in PDoc schreiben, Art der Änderung(en) und AMID ermitteln *************************
        lt_proc_data = /adesso/cl_mdc_datex_utility=>get_proc_data_usageinfo( is_bill_doc = x_bill_doc is_data_collector = x_data_collector
                                                                               is_billing_data = x_billing_data it_usage = xt_usage ).

***** 2. Zählpunkte zu den Änderungen ermitteln ***************************************************
        lt_int_ui = get_pods( iv_vertrag = x_bill_doc-erch-vertrag ).

***** 3. Prüfungen und ggf. Prozess starten für alle Zählpunkte ************************************
        LOOP AT lt_proc_data ASSIGNING <fs_proc_data>.
          LOOP AT lt_int_ui ASSIGNING <fv_int_ui>.
            CLEAR: <fs_proc_data>-proc_ref.
            <fs_proc_data>-int_ui = <fv_int_ui>.
*---- 3.1 Empfänger ermitteln ---------------------------------------------------------------------
            /adesso/cl_mdc_datex_utility=>add_servprovs_to_proc_data( CHANGING cs_proc_data = <fs_proc_data> ).

*---- 3.2 Prozessdaten vervollständigen -----------------------------------------------------------
            /adesso/cl_mdc_datex_utility=>enhance_proc_data( CHANGING cs_proc_data = <fs_proc_data> ).

*---- 3.3. Prüfung: Datenaustausch aktiv? ---------------------------------------------------------
            CHECK /adesso/cl_mdc_datex_utility=>get_send_flag_from_datex( iv_int_ui = <fv_int_ui> ) = abap_true.

*---- 3.4. Prüfung: Prozess im Customizing aktiviert? ---------------------------------------------
            CHECK /adesso/cl_mdc_datex_utility=>get_send_flag_from_customizing( is_proc_data = <fs_proc_data> ) = abap_true.

*---- 3.5. Prüfung: Kundenindividuelle Prüfung ----------------------------------------------------
            lv_flag_send = abap_true.

            TRY.
                GET BADI lr_badi_mdc_dtx_usageinfo
                  FILTERS
                    mandt = sy-mandt
                    sysid = sy-sysid.
              CATCH cx_badi_not_implemented.
                "Das BAdI muss nicht implementiert sein.
            ENDTRY.

            IF lr_badi_mdc_dtx_usageinfo IS NOT INITIAL.
              CALL BADI lr_badi_mdc_dtx_usageinfo->change_proc_data_and_send_flag
                EXPORTING
                  is_bill_doc       = x_bill_doc
                  is_data_collector = x_data_collector
                  is_billing_data   = x_billing_data
                  it_usage          = xt_usage
                CHANGING
                  cs_proc_data      = ls_proc_data
                  cv_flag_send      = lv_flag_send.
            ENDIF.

            CHECK lv_flag_send = abap_true.

*---- 3.6 Prüfen, ob schon SDÄ existiert und als Schritt hinzufügen -------------------------------
*OPTIONAL: Hier können so SDÄ gesammelt werden.
*Abgleich: Empfänger, AMID und Prozess muss noch im Warteschritt hängen zu Beginn.

*---- 3.7 PDoc erzeugen und Prozess starten -------------------------------------------------------
            /idxgc/cl_process_trigger=>start_process( EXPORTING iv_pdoc_display = abap_false CHANGING cs_process_data = <fs_proc_data> ).

          ENDLOOP.
        ENDLOOP.

*---- 3.8 Fehlerbehandlung: Error PDoc ------------------------------------------------------------
      CATCH /idxgc/cx_general INTO gr_previous.
        TRY.
            CLEAR: gt_message, gs_message.
            MOVE-CORRESPONDING sy TO gs_message.
            APPEND gs_message TO gt_message.
            IF ls_proc_data IS INITIAL.
              READ TABLE lt_proc_data INTO ls_proc_data INDEX 1.
            ENDIF.
            /adesso/cl_mdc_datex_utility=>create_error_pdoc( is_proc_data = ls_proc_data it_message = gt_message ).
          CATCH /idxgc/cx_general INTO gr_previous.
            RAISE error_occurred.
        ENDTRY.
    ENDTRY.

  ENDMETHOD.


  METHOD process_invoice.
    INCLUDE ie00date.

    DATA: l_task_data       TYPE         edextask_data_intf,
          lt_parameter      TYPE         idexprocparval,
          l_parameter       TYPE         edexprocparval,
          lt_interface_data TYPE         abap_parmbind_tab,
          l_interface_data  TYPE         abap_parmbind,
          lt_ever           TYPE         t_ever,
          l_erch            LIKE LINE OF xt_erch.

* set datex parameter
    l_parameter-dexprocparval = x_reverse.
    l_parameter-dexprocparno = '1'.
    APPEND l_parameter TO lt_parameter.

*>>DATEXPRN_3
    l_parameter-dexprocparno = '2'.
    IF x_invoice-erdk-edisenddate IS INITIAL.
      l_parameter-dexprocparval = space.
    ELSE.
      l_parameter-dexprocparval = abap_true.
    ENDIF.
    APPEND l_parameter TO lt_parameter.
*<<DATEXPRN_3

* write additional interface parameters
    l_interface_data-name = 'X_INVOICE'.
    GET REFERENCE OF x_invoice INTO l_interface_data-value.
    INSERT l_interface_data INTO TABLE lt_interface_data.

    l_interface_data-name = 'X_CROSSREFNO'.
    GET REFERENCE OF x_ecrossrefno-crossrefno INTO
                     l_interface_data-value.
    INSERT l_interface_data INTO TABLE lt_interface_data.

    l_interface_data-name = 'X_VKONT_AGG'.
    GET REFERENCE OF x_vkont_agg INTO l_interface_data-value.
    INSERT l_interface_data INTO TABLE lt_interface_data.

    l_interface_data-name = 'XT_ERCH'.
    GET REFERENCE OF xt_erch INTO l_interface_data-value.
    INSERT l_interface_data INTO TABLE lt_interface_data.

    l_interface_data-name = 'XT_EVER'.
    APPEND x_ever TO lt_ever.
    GET REFERENCE OF lt_ever[] INTO l_interface_data-value.
    INSERT l_interface_data INTO TABLE lt_interface_data.

    l_interface_data-name = 'X_REVERSE'.
    GET REFERENCE OF x_reverse INTO l_interface_data-value.
    INSERT l_interface_data INTO TABLE lt_interface_data.

    l_interface_data-name = 'Y_IDOC_CREATED'.
    GET REFERENCE OF y_idoc_created INTO l_interface_data-value.
    INSERT l_interface_data INTO TABLE lt_interface_data.

    IF NOT x_dexservprovself IS INITIAL AND
       NOT x_dexservprov     IS INITIAL.
*   service providers from interface
      l_task_data-dexservprov     = x_dexservprov.
      l_task_data-dexservprovself = x_dexservprovself.
    ELSE.
*   standard behaviour
      l_task_data-dexservprov     = x_ever-invoicing_party.
      l_task_data-dexservprovself = x_ever-serviceid.
    ENDIF.

    l_task_data-int_ui          = x_ecrossrefno-int_ui.
    l_task_data-dexreftimeto    = co_time_infinite.

* bei Abschlägen kein ERCH vorhanden
* Anfdat steht nicht im Printdoc, aber in ECROSSREFNO als Keydate
    READ TABLE xt_erch INTO l_erch INDEX '1'.
    IF l_erch-begabrpe IS INITIAL.
      l_task_data-dexrefdatefrom = x_ecrossrefno-keydate.          "TR
      l_task_data-dexrefdateto   = x_ecrossrefno-keydate.          "TR
    ELSE.                                                          "TR
      l_task_data-dexrefdatefrom = l_erch-begabrpe.                 "TR
      l_task_data-dexrefdateto   = l_erch-endabrpe.                "TR
    ENDIF.                                                         "TR


* call datex basic process
    CALL METHOD cl_isu_datex_controller=>start_ui_datex_basicprocess
      EXPORTING
        x_dexbasicproc     = cl_isu_datex_controller=>co_dexbasicproc_export_invoice
        x_task_data        = l_task_data
        xt_parameter       = lt_parameter
      CHANGING
        xyt_interface_data = lt_interface_data
      EXCEPTIONS
        no_dexproc_found   = 1
        OTHERS             = 2.
    IF sy-subrc = 1.
      RAISE no_dexproc_found.
    ELSEIF sy-subrc <> 0.
      RAISE error_occurred.
    ENDIF.



  ENDMETHOD.


  METHOD switch_out.

    raise error_occurred.

  ENDMETHOD.
ENDCLASS.
