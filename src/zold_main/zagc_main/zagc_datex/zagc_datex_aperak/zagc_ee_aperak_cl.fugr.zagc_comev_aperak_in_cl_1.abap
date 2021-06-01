FUNCTION zagc_comev_aperak_in_cl_1.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(INPUT_METHOD) TYPE  INPUTMETHD
*"     REFERENCE(MASS_PROCESSING) TYPE  MASS_PROC
*"  EXPORTING
*"     REFERENCE(WORKFLOW_RESULT) TYPE  WF_RESULT
*"     REFERENCE(APPLICATION_VARIABLE) TYPE  APPL_VAR
*"     REFERENCE(IN_UPDATE_TASK) TYPE  UPDATETASK
*"     REFERENCE(CALL_TRANSACTION_DONE) TYPE  CALLTRANS2
*"  TABLES
*"      IDOC_CONTRL STRUCTURE  EDIDC
*"      IDOC_DATA STRUCTURE  EDIDD
*"      IDOC_STATUS STRUCTURE  BDIDOCSTAT
*"      RETURN_VARIABLES STRUCTURE  BDWFRETVAR
*"      SERIALIZATION_INFO STRUCTURE  BDI_SER
*"  EXCEPTIONS
*"      ERROR_OCCURRED
*"----------------------------------------------------------------------

*** For new IDOC type /IDXGC/APREAK_02
*---------------------------------------------------------------------
* THIMEL.R 20150625 Einführung CL APERAK Verarbeitung
*   Alte Logik aus ZISU_COMEV_APERAK_23_IN übernommen und angepasst.
**********************************************************************
  TABLES: zidexge_s_aperak_data.

  DATA:
    lv_object_key      TYPE        swo_typeid,
    lv_object_key2     TYPE        swo_typeid,
    lv_rc              TYPE        sysubrc,
    lv_dummy           TYPE        c,
    ls_contrl          TYPE        edidc,
    lr_aperak          TYPE REF TO /e4u/idxcl_aperak,
    ld_subrc           LIKE        sy-subrc,
    lf_orders_z12      TYPE        kennzx,
    ls_e1_unb_01       TYPE        /idxgc/e1_unb_01,
    ls_e1_unh_01       TYPE        /idxgc/e1_unh_01,
    lv_intch_contr_ref TYPE        /idxgc/de_intch_contr_ref,
    lv_msg_refno       TYPE        /idxgc/de_msg_refno.

  DATA:
    lv_aperak_docnum TYPE edi_docnum,
    ls_idoc_data     TYPE edidd,
    ld_category      TYPE eideswtmsgdata-category.

  DATA: it_input_container    TYPE STANDARD TABLE OF swr_cont,
        it_input_container_wa TYPE                   swr_cont.


*Im Top-Include enthalten!!!
*DATA: ls_proc_aperak     type zidexge_s_aperak_data.


  READ TABLE   idoc_contrl INTO ls_contrl INDEX 1.
  lv_aperak_docnum = ls_contrl-docnum.
  CLEAR: gv_aperak_docnum.
  gv_aperak_docnum = ls_contrl-docnum.

*1. Ermittlung der Idoc-Daten
  LOOP AT idoc_data INTO ls_idoc_data.
    CASE ls_idoc_data-segnam.
*ToDo
*Error_Code
      WHEN gc_seg_erc1.
        PERFORM proc_sg4_erc USING ls_idoc_data-sdata.
*Bulk-Ref. des ursprünglichen Idocs
      WHEN gc_seg_rff8.
        PERFORM proc_sg2_rff USING ls_idoc_data-sdata.
*Ablehnungsgrund als Freitext
      WHEN gc_seg_ftx3.
        PERFORM proc_erc_ftx USING ls_idoc_data-sdata.
*TN-Referenznummer der ursprünglichen Nachricht
      WHEN gc_seg_rff11.
        PERFORM proc_erc_rff11 USING ls_idoc_data-sdata.
    ENDCASE.
  ENDLOOP.

*2. Ermittlung der ursprünglichen Wechsebelegnummer, um dem entsprechenden Workflow
*   mitzuteilen, dass eine eingehende Aperak existiert.

  IF ls_proc_aperak IS NOT INITIAL.
    PERFORM ermittle_wb CHANGING lv_object_key lv_object_key2  ld_category ld_subrc lf_orders_z12.
  ENDIF.

  IF ld_subrc = gc_rcode_wb_found.
    IF lv_object_key IS NOT INITIAL. "Falls der Wechselbeleg aktiv ist
      IF ld_category = 'Z14'.
        REFRESH it_input_container.
        CLEAR it_input_container_wa.
        it_input_container_wa-element = 'SwitchView'.
        it_input_container_wa-value   = '2'.
        APPEND it_input_container_wa TO it_input_container.

        it_input_container_wa-element = 'SwitchType'.
        it_input_container_wa-value   = '22'.
        APPEND it_input_container_wa TO it_input_container.

        CALL FUNCTION 'SAP_WAPI_CREATE_EVENT'
          EXPORTING
            object_type     = 'ISUSWITCHD'
            object_key      = lv_object_key
            event           = 'BDRREJECT'
            commit_work     = 'X'
          IMPORTING
            return_code     = lv_rc
          TABLES
            input_container = it_input_container.
      ELSE.
*     Ereigniscontainer füllen
        REFRESH it_input_container.
        CLEAR it_input_container_wa.
        it_input_container_wa-element = 'AblehnungTxt'.
        it_input_container_wa-value   = ls_proc_aperak-ftx.
        APPEND it_input_container_wa TO it_input_container.
        it_input_container_wa-element = 'IdocNumber'.
        it_input_container_wa-value   = lv_aperak_docnum.
        APPEND it_input_container_wa TO it_input_container.
        it_input_container_wa-element = 'Kategorie'.
        it_input_container_wa-value   = ld_category.
        APPEND it_input_container_wa TO it_input_container.
        it_input_container_wa-element = 'idrefnr'.
        it_input_container_wa-value   = ls_proc_aperak-transaction_id.
        APPEND it_input_container_wa TO it_input_container.
        it_input_container_wa-element   = 'error_code'.
        it_input_container_wa-value   = ls_proc_aperak-error_code.
        APPEND it_input_container_wa TO  it_input_container.

        CALL FUNCTION 'SAP_WAPI_CREATE_EVENT'
          EXPORTING
            object_type     = 'ISUSWITCHD'
            object_key      = lv_object_key
            event           = 'zaperak'
          IMPORTING
            return_code     = lv_rc
          TABLES
            input_container = it_input_container.
      ENDIF.
*--- Fehlerbehandlung
      IF lv_rc = 0.
        MOVE gc_rcode_wf_start TO ld_subrc.
        MESSAGE i003(/e4u/idx_aperak_20a) INTO lv_dummy.
        PERFORM add_status USING lv_aperak_docnum CHANGING idoc_status[] ld_subrc.
        COMMIT WORK.
      ELSE.
        MOVE gc_rcode_no_wf_start TO ld_subrc.
        MESSAGE i018(/e4u/idx_aperak_20a) WITH ls_proc_aperak-transaction_id INTO lv_dummy.
        PERFORM add_status USING lv_aperak_docnum CHANGING idoc_status[] ld_subrc.
      ENDIF.
    ELSEIF  lv_object_key2 IS NOT INITIAL. "Falls WB bereits beendet wurde
*     Ereigniscontainer füllen
      REFRESH it_input_container.
      CLEAR it_input_container_wa.
      it_input_container_wa-element = 'AblehnungTxt'.
      it_input_container_wa-value   = ls_proc_aperak-ftx.
      APPEND it_input_container_wa TO it_input_container.
      it_input_container_wa-element = 'IdocNumber'.
      it_input_container_wa-value   = lv_aperak_docnum.
      APPEND it_input_container_wa TO it_input_container.
      it_input_container_wa-element = 'Kategorie'.
      it_input_container_wa-value   = ld_category.
      APPEND it_input_container_wa TO it_input_container.
      it_input_container_wa-element = 'idrefnr'.
      it_input_container_wa-value   = ls_proc_aperak-transaction_id.
      APPEND it_input_container_wa TO it_input_container.
      it_input_container_wa-element   = 'error_code'.
      it_input_container_wa-value   = ls_proc_aperak-error_code.
      APPEND it_input_container_wa TO  it_input_container.

      CALL FUNCTION 'SAP_WAPI_CREATE_EVENT'
        EXPORTING
          object_type     = 'ISUSWITCHD'
          object_key      = lv_object_key2
          event           = 'zaperaksbinfo'
        IMPORTING
          return_code     = lv_rc
        TABLES
          input_container = it_input_container.

*--- Fehlerbehandlung
      IF lv_rc = 0.
        MOVE gc_rcode_wf_start TO ld_subrc.
        MESSAGE i003(/e4u/idx_aperak_20a) INTO lv_dummy.
        PERFORM add_status USING lv_aperak_docnum CHANGING idoc_status[] ld_subrc.
        COMMIT WORK.
      ELSE.
        MOVE gc_rcode_no_wf_start TO ld_subrc.
        MESSAGE i018(/e4u/idx_aperak_20a) WITH ls_proc_aperak-transaction_id INTO lv_dummy.
        PERFORM add_status USING lv_aperak_docnum CHANGING idoc_status[] ld_subrc.
      ENDIF.

    ELSEIF lf_orders_z12 IS NOT INITIAL.
      MOVE gc_rcode_wf_start TO ld_subrc.
      MESSAGE i003(/e4u/idx_aperak_20a) INTO lv_dummy.
      PERFORM add_status USING lv_aperak_docnum CHANGING idoc_status[] ld_subrc.
      COMMIT WORK.
    ENDIF.

  ELSE.
* Beginn Coding Göbel 26.01.2012
    DATA:  wa_zaperak  TYPE edidc,
           lv_sy_datum TYPE sy-datum.
    DATA: wa_zaperak2 TYPE edid4.
    DATA: lv_kennzx TYPE kennzx.
    DATA:     wa_unb TYPE /isidex/e1vdewunb_1.
    DATA: lv_unh TYPE /isidex/e1vdewunh_1.
    DATA: l_idoc_status_tab LIKE bdidocstat OCCURS 1 WITH HEADER LINE.
    DATA: lv_forschreiben_fehler TYPE kennzx.

    lv_sy_datum  = sy-datum - 2.
    SELECT * FROM edidc INTO wa_zaperak
      WHERE credat <= sy-datum AND credat >= lv_sy_datum AND direct = 1.

      SELECT SINGLE *  FROM edid4 INTO wa_zaperak2
      WHERE docnum = wa_zaperak-docnum AND ( segnam = '/ISIDEX/E1VDEWUNB_1'
        OR segnam = '/IDEXGE/E1VDEWUNB_2' OR segnam = '/IDXGC/E1_UNB_01' ).

      IF sy-subrc = 0.
        IF wa_zaperak2-segnam = '/IDXGC/E1_UNB_01'.
          ls_e1_unb_01 = wa_zaperak2-sdata.
          lv_intch_contr_ref = ls_e1_unb_01-interchange_control_reference.
        ELSE.
          wa_unb =  wa_zaperak2-sdata.
          lv_intch_contr_ref = wa_unb-bulk_ref.
        ENDIF.

        IF lv_intch_contr_ref = ls_proc_aperak-unb_bulk_ref.
          lv_kennzx = 'X'.

          CLEAR l_idoc_status_tab.

          l_idoc_status_tab-docnum = wa_zaperak2-docnum.
          l_idoc_status_tab-status = '17'.
          APPEND l_idoc_status_tab.
          CALL FUNCTION 'IDOC_STATUS_WRITE_TO_DATABASE'
            EXPORTING
              idoc_number               = wa_zaperak2-docnum
            TABLES
              idoc_status               = l_idoc_status_tab
            EXCEPTIONS
              idoc_foreign_lock         = 1
              idoc_not_found            = 2
              idoc_status_records_empty = 3
              idoc_status_invalid       = 4
              db_error                  = 5
              OTHERS                    = 6.

          IF sy-subrc <> 0.
            CLEAR lv_forschreiben_fehler .
            lv_forschreiben_fehler = 'X'.

          ELSE.

          ENDIF.

        ENDIF.
      ELSE.
        SELECT SINGLE * FROM edid4 INTO wa_zaperak2
          WHERE docnum = wa_zaperak-docnum AND ( segnam = '/ISIDEX/E1VDEWUNH_1' OR segnam = '/IDXGC/E1_UNH_01' ).
        IF sy-subrc EQ 0.
          CLEAR lv_unh.
          IF wa_zaperak2-segnam = '/IDXGC/E1_UNH_01'.
            ls_e1_unh_01 = wa_zaperak2-sdata.
            lv_msg_refno = ls_e1_unh_01-message_reference_number.
          ELSE.
            lv_unh =  wa_zaperak2-sdata.
            lv_msg_refno = lv_unh-referencenumber.
          ENDIF.

          IF lv_msg_refno EQ ls_proc_acw.
            lv_kennzx = 'X'.

            CLEAR l_idoc_status_tab.

            l_idoc_status_tab-docnum = wa_zaperak2-docnum.
            l_idoc_status_tab-status = '17'.
            APPEND l_idoc_status_tab.
            CALL FUNCTION 'IDOC_STATUS_WRITE_TO_DATABASE'
              EXPORTING
                idoc_number               = wa_zaperak2-docnum
              TABLES
                idoc_status               = l_idoc_status_tab
              EXCEPTIONS
                idoc_foreign_lock         = 1
                idoc_not_found            = 2
                idoc_status_records_empty = 3
                idoc_status_invalid       = 4
                db_error                  = 5
                OTHERS                    = 6.

            IF sy-subrc <> 0.
              CLEAR lv_forschreiben_fehler .
              lv_forschreiben_fehler = 'X'.
            ENDIF.

          ENDIF.
        ENDIF.
      ENDIF.
      IF lv_kennzx IS NOT INITIAL.
        EXIT.
      ENDIF.
    ENDSELECT.

    IF lv_kennzx IS INITIAL.
      IF ls_proc_aperak-unb_bulk_ref  IS NOT INITIAL.
        MESSAGE i080(eideswd)  WITH ls_proc_aperak-unb_bulk_ref INTO lv_dummy.
        PERFORM add_status USING lv_aperak_docnum CHANGING idoc_status[] ld_subrc.
      ELSE.
        MESSAGE i080(eideswd)  WITH ls_proc_acw INTO lv_dummy.
        PERFORM add_status USING lv_aperak_docnum CHANGING idoc_status[] ld_subrc.
      ENDIF.
    ELSE.
      IF lv_forschreiben_fehler IS NOT INITIAL.
        PERFORM add_status_idoc USING lv_aperak_docnum wa_zaperak2-docnum CHANGING idoc_status[] .
      ELSE.
        PERFORM add_status USING lv_aperak_docnum CHANGING idoc_status[] gc_rcode_no_fehler.
      ENDIF.
    ENDIF.
*Ende Coding Göbel 26.01.2012
  ENDIF.

*
*message i080(eideswd)  with ls_proc_aperak-transaction_id into lv_dummy.
*    perform add_status using lv_aperak_docnum changing idoc_status[] ld_subrc.

ENDFUNCTION.
