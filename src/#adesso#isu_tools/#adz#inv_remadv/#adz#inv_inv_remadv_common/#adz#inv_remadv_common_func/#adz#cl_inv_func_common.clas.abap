CLASS /adz/cl_inv_func_common DEFINITION
  PUBLIC
  ABSTRACT
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES /adz/if_inv_salv_table_evt_hlr .

    METHODS constructor
      IMPORTING
        !irt_out_table TYPE REF TO data OPTIONAL
        !is_selscreen  TYPE /adz/inv_s_sel_screen OPTIONAL .
    METHODS process_user_command
      IMPORTING
        !e_ucomm TYPE syst_ucomm
        !sender  TYPE REF TO cl_gui_alv_grid .
    METHODS ende_proc_task
      IMPORTING
        !p_task TYPE clike .
    METHODS in_memory .
  PROTECTED SECTION.

    DATA mrt_out_table TYPE REF TO /adz/inv_t_out_reklamon .
    DATA mt_filter TYPE lvc_t_fidx .
    DATA mv_akt_proz TYPE i .
    DATA mrs_noti    TYPE REF TO /idexge/rej_noti .
    TYPES ty_sel_inv_tp TYPE /adz/inv_s_sel_screen-p_invtp.

    METHODS get_outable  RETURNING VALUE(rrt_out) TYPE REF TO data.
    METHODS get_hotspot_row IMPORTING iv_rownr       TYPE lvc_index
                            RETURNING VALUE(rrs_row) TYPE REF TO data.

    METHODS show_pdoc ABSTRACT IMPORTING !iv_option TYPE /adz/fi_neg_remadv_option .
    METHODS send_mail ABSTRACT.
    METHODS show_swt  ABSTRACT.
    METHODS abl_per_comdis ABSTRACT.
    METHODS write_note  ABSTRACT.
    METHODS execute_process ABSTRACT.
    METHODS dun_unlock  ABSTRACT
      IMPORTING
        !iv_p_invtp TYPE ty_sel_inv_tp.
    METHODS dun_lock ABSTRACT
      IMPORTING
        !iv_lockr TYPE fkkvkp-mansp
        !iv_fdate TYPE sy-datum
        !iv_tdate TYPE sy-datum .
    METHODS check_single_select
      IMPORTING
                !iv_nr_select_lines TYPE integer
                !iv_text            TYPE string OPTIONAL
                !iv_text2           TYPE string OPTIONAL
      RETURNING VALUE(rb_ok)        TYPE abap_bool.
    METHODS cancel_abr ABSTRACT.
    METHODS cancel_ap  ABSTRACT.
    METHODS cancel_memi ABSTRACT.
    METHODS cancel_mgv  ABSTRACT.
    METHODS cancel_nne  ABSTRACT.
    METHODS check_select
      IMPORTING
                !iv_nr_select_lines TYPE integer
      RETURNING VALUE(rv_good)      TYPE abap_bool.
    METHODS balance ABSTRACT.
    METHODS beende_remadv ABSTRACT.
    METHODS change_anl
      IMPORTING
        !iv_option TYPE /adz/fi_neg_remadv_option .
    METHODS set_status_erl .
    METHODS show_cic .
    METHODS get_anlage
      IMPORTING
        !iv_ext_ui       TYPE ext_ui
      RETURNING
        VALUE(rv_anlage) TYPE anlage .
    METHODS show_tasks
      IMPORTING
        iv_ext_ident       TYPE inv_ext_ident
        iv_end_date        TYPE /idxmm/de_end_date
        iv_invperiod_start TYPE inv_period_start
        iv_invperiod_end   TYPE inv_period_end.
    METHODS call_cic
      IMPORTING
        !iv_vertrag TYPE vertrag .
    METHODS get_cic_frame_4_user
      RETURNING
        VALUE(rv_screen_no) TYPE cicfwscreenno .
    METHODS get_popup_comp_reason
      CHANGING
        !cv_compl_reason TYPE rstgr .
    METHODS ucom_compl .
    METHODS show_text  ABSTRACT
      IMPORTING
        !iv_doc_no TYPE inv_int_inv_doc_no .

    METHODS show_error
      IMPORTING
        !iv_doc_no TYPE inv_int_inv_doc_no .
    METHODS show_ext_invoice
      IMPORTING
        !iv_ext_invoice_no TYPE inv_ext_invoice_no .
    METHODS add_text
      IMPORTING
        !iv_action TYPE char20 .
    METHODS check_sperre
      RETURNING
        VALUE(rv_sperre) TYPE bool .
    METHODS choose
      IMPORTING
        !it_sel_rows_index TYPE lvc_t_row .
    METHODS get_enet_price_anl .
    METHODS get_errormessage
      IMPORTING
        !iv_doc_no TYPE inv_int_inv_doc_no
      CHANGING
        !ct_error  TYPE /adz/inv_t_fehler .
    METHODS get_popup_canc_reason
      RETURNING
        VALUE(rv_cancel_reason) TYPE inv_cancel_rsn .
    METHODS mark_all .
    METHODS process
      IMPORTING
        !iv_uv_change TYPE inv_kennzx .
    METHODS refresh_data
      CHANGING
        !cv_refresh_flag TYPE flag .
    METHODS reset_status
      IMPORTING
        !iv_reset_flag   TYPE flag OPTIONAL
        !iv_release_flag TYPE flag OPTIONAL .
    METHODS show_references .
    METHODS simulate_vp
      IMPORTING
        !iv_but_flag TYPE flag OPTIONAL
        !iv_inv_no   TYPE tinv_inv_head-int_inv_no OPTIONAL .
    METHODS sperren .
    METHODS ucom_beenden .
    METHODS ucom_canc .
    METHODS ucom_log .
    METHODS ucom_proc .
    METHODS unmark_all .
    METHODS get_free_text
      IMPORTING iv_int_inv_doc_no TYPE inv_int_inv_doc_no.
    METHODS int_status
      IMPORTING
        iv_int_inv_doc_no  TYPE inv_int_inv_doc_no
        iv_int_inv_line_no TYPE inv_int_inv_line_no
      CHANGING
        cv_free_text4      TYPE char10.

    METHODS int_notice_edit
      IMPORTING
        iv_int_inv_doc_no  TYPE inv_int_inv_doc_no
        iv_int_inv_line_no TYPE inv_int_inv_line_no
      CHANGING
        cv_free_text5      TYPE /idexge/rej_noti_txt.
    METHODS int_notice
      IMPORTING
        iv_int_inv_doc_no  TYPE inv_int_inv_doc_no
        iv_int_inv_line_no TYPE inv_int_inv_line_no
      CHANGING
        cv_free_text5      TYPE /idexge/rej_noti_txt.
    METHODS call_delvnoteman.

  PRIVATE SECTION.

    DATA ms_selscreen TYPE /adz/inv_s_sel_screen .
ENDCLASS.



CLASS /ADZ/CL_INV_FUNC_COMMON IMPLEMENTATION.


  METHOD /adz/if_inv_salv_table_evt_hlr~on_hotspotclick.
    "value(E_ROW_ID) type LVC_S_ROW optional
    "value(E_COLUMN_ID) type LVC_S_COL optional
    "value(ES_ROW_NO) type LVC_S_ROID optional .
    FIELD-SYMBOLS <ls_out_reklamon>  TYPE /adz/inv_s_out_reklamon.
    " Struktur die nur haeufig benutzte Felder fuer Hotspotaktionen enthält
    " dadurch kann man mit verschiedenen Tabellenstrukturen (auch /adz/inv_t_out_delvnoteman) arbeiten
    TYPES: BEGIN OF ty_hotspot_fields,
             int_inv_doc_no  TYPE /adz/inv_s_out_reklamon-int_inv_doc_no,
             invoice_type    TYPE /adz/inv_s_out_reklamon-invoice_type,
             remadv          TYPE /adz/inv_s_out_reklamon-remadv,
             ls_pdoc_ref     TYPE /adz/inv_s_out_reklamon-ls_pdoc_ref,
             inv_bulk_ref    TYPE /adz/inv_s_out_reklamon-inv_bulk_ref,
             invperiod_start TYPE /adz/inv_s_out_reklamon-invperiod_start,
             invperiod_end   TYPE /adz/inv_s_out_reklamon-invperiod_end,
             ext_ident       TYPE /adz/inv_s_out_reklamon-ext_ident,
             end_date        TYPE /adz/inv_s_out_reklamon-end_date,
             "                  type /adz/inv_s_out_reklamon-,
           END OF ty_hotspot_fields.

    " Achtung Methode kann redifiniert sein
    " angeclickte Zeile holen
    DATA(lr_row) = get_hotspot_row( e_row_id-index ).
    ASSIGN lr_row->* TO FIELD-SYMBOL(<ls_row>).
    DATA(ls_out) = CORRESPONDING ty_hotspot_fields( <ls_row> ).
    "ASSIGN mrt_out_table->* TO FIELD-SYMBOL(<lt_out>).
    "READ TABLE <lt_out> INTO DATA(ls_out) INDEX e_row_id-index.

    " ueber Spaltename den Wert ermitteln
    ASSIGN COMPONENT e_column_id-fieldname OF STRUCTURE <ls_row> TO FIELD-SYMBOL(<lv_field_value>).
*# Nur mit Wert befüllten Feld funktionieren
    CHECK <lv_field_value> IS NOT INITIAL.

    CASE e_column_id-fieldname.

*      WHEN 'SEL'.
*        READ TABLE <lt_out> ASSIGNING FIELD-SYMBOL(<ls_out>) INDEX e_row_id-index.
*        <ls_out>-sel = xsdbool( <ls_out>-sel <> abap_true ).
      WHEN 'LOCKED'.
        me->show_text( ls_out-int_inv_doc_no ).

      WHEN 'TEXT_BEM'.
        me->show_text( ls_out-int_inv_doc_no ).

      WHEN 'MOSB_ID'.
        "SET PARAMETER ID 'SO_CONTR' FIELD <lv_field_value>.
        "CALL TRANSACTION '/MOSB/CTR_MON' AND SKIP FIRST SCREEN.
        DATA lt_contract TYPE RANGE OF /mosb/de_contract_id.
        lt_contract = VALUE #( ( sign = 'I'  option = 'EQ' low = <lv_field_value>  ) ).
        SUBMIT /mosb/rp_contract_monitor
            WITH so_contr IN lt_contract
             AND RETURN.


      WHEN 'VERTRAG' OR 'VTREF'.

        DATA: lv_ever TYPE ever-vertrag.

        DATA(lv_string) = CONV string( <lv_field_value> ).
        SHIFT lv_string LEFT DELETING LEADING '0'.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = <lv_field_value>
          IMPORTING
            output = lv_ever.

        CALL FUNCTION 'ISU_S_CONTRACT_DISPLAY'
          EXPORTING
            x_vertrag = lv_ever "CONV vertrag( lv_string )    " Vertragsnummer
          EXCEPTIONS
            OTHERS    = 6.
      WHEN 'ANLAGE'.
        DATA(lv_anlage) = CONV anlage( <lv_field_value> ).
        CALL FUNCTION 'ISU_S_INSTLN_DISPLAY'
          EXPORTING
            x_anlage     = lv_anlage     " Objektkey 1 (ANLAGE)
            x_keydate    = '00000000'                " Objektkey 2 (AB-Datum)
            x_upd_online = 'X'.                " Flag: Updates direkt im Online

      WHEN 'INT_INV_DOC_NO' .   " Interne Nummer des Rechnungsbeleg
        CHECK ls_out-int_inv_doc_no IS NOT INITIAL.
        CALL FUNCTION 'INV_S_INVREMADV_DOC_DISPLAY'
          EXPORTING
            x_inv_doc_no = ls_out-int_inv_doc_no
          EXCEPTIONS
            OTHERS       = 4.

      WHEN 'INT_RECEIVER' OR 'INT_SENDER'.
        DATA(lv_servprov) = CONV service_prov( <lv_field_value>(10) ).
        CALL FUNCTION 'ISU_S_EDMIDE_SERVPROV_DISPLAY'
          EXPORTING
            x_serviceid = lv_servprov.

*
      WHEN 'REMADV2' OR 'REMADV' OR 'REMADV1' OR 'STORNOBELNR'.
        DATA(lv_remadv2) = CONV inv_int_inv_doc_no( <lv_field_value> ).
        CALL FUNCTION 'INV_S_INVREMADV_DOC_DISPLAY'
          EXPORTING
            x_inv_doc_no = lv_remadv2    " Interne Nummer des Rechnungsbelegs
          EXCEPTIONS
            OTHERS       = 4.
        IF sy-subrc <> 0.
*        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

      WHEN 'EXT_IDENT' OR  'EXT_UI_MELO' OR 'EXT_UI'.
        CALL FUNCTION 'ISU_S_UI_DISPLAY'  EXPORTING x_ext_ui = CONV ext_ui( <lv_field_value> ).

      WHEN 'TEXT_VORHANDEN'.
        me->show_text( ls_out-int_inv_doc_no ).
        "        me->simulate_vp( iv_but_flag = abap_false ).
*
      WHEN 'CASENR'.  "Klärungsfall
        CALL FUNCTION 'EMMA_CASE_TRANSACTION_START'
          EXPORTING
            iv_casenr            = CONV emma_cnr( <lv_field_value> ) " Fall
            iv_wmode             = cl_emma_case_txn=>co_wmode_display " Arbeitsmodus Falltransaktion
          EXCEPTIONS
            case_not_found       = 1                " Fall nicht gefunden
            incorrect_workmode   = 2                " Arbeitsmodus inkorrekt
            incorrect_parameters = 3                " Inkorrekte Parameter
            OTHERS               = 4.
        IF sy-subrc <> 0.
*         MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
*
      WHEN 'MULTI_ERR' OR 'FEHLER'.
        me->show_error( ls_out-int_inv_doc_no ).

      WHEN 'EXT_INVOICE_NO'.
        me->show_ext_invoice( <lv_field_value> ).

      WHEN 'OWN_INVOICE_NO' OR 'XBLNR' OR 'ERCHCOPBEL'.

        IF e_column_id-fieldname NE 'OWN_INVOICE_NO'.
          SHIFT <lv_field_value> LEFT DELETING LEADING '0'.
          DATA(lv_opbel) = CONV opbel_kk( <lv_field_value>(12) ).
          SHIFT lv_opbel RIGHT DELETING TRAILING ' '.
          OVERLAY lv_opbel WITH '000000000000'.
        ELSE.
          IF <lv_field_value>(3) = 'PRN'.
            lv_opbel = CONV opbel_kk( <lv_field_value>+3(12) ).
          ELSE.
            lv_opbel = CONV opbel_kk( <lv_field_value>(12) ).
          ENDIF.
        ENDIF.

        "        SELECT SINGLE * FROM erdk INTO @DATA(lv_erdk) WHERE opbel = @lv_opbel.
        CALL FUNCTION 'ISU_S_PRINT_DOC_DISPLAY'
          EXPORTING
            x_opbel = lv_opbel
          EXCEPTIONS
            OTHERS  = 4.

        IF sy-subrc = 4.
          MESSAGE w164(eb) WITH lv_opbel.
        ENDIF.
*   Druckbeleg (&1) nicht vorhanden

      WHEN 'LS_NUMMER'. " LieferscheinNr
        "if ls_out-ls_nummer is not INITIAL and
        IF sy-cprog = '/ADZ/INV_REKLAMATIONSMONITOR'.
          DATA lv_idocnum_ls(16) TYPE n.
          lv_idocnum_ls = <lv_field_value>.
          CALL FUNCTION 'EDI_DOCUMENT_DATA_DISPLAY'
            EXPORTING
              docnum               = lv_idocnum_ls
            EXCEPTIONS
              no_data_record_found = 1
              OTHERS               = 2.
          IF sy-subrc <> 0.
            RETURN.
          ENDIF.
        ELSE.
          IF ls_out-ls_pdoc_ref IS INITIAL.
            CALL FUNCTION 'FC_POPUP_ERR_WARN_MESSAGE'
              EXPORTING
                popup_title  = 'Fehler'                 " Titel des Popups
                is_error     = 'X'              " Flag: Meldung eines Fehlers
                message_text = 'Lieferschein nicht gefunden.'                 " erste Textzeile
                start_column = 25
                start_row    = 6.
          ENDIF.
          CHECK ls_out-ls_pdoc_ref IS NOT INITIAL.
          CALL FUNCTION '/IDXGC/FM_PDOC_DISPLAY'
            EXPORTING
              x_switchnum    = ls_out-ls_pdoc_ref
            EXCEPTIONS
              general_fault  = 1
              not_found      = 2
              not_authorized = 3
              OTHERS         = 4.
        ENDIF.
      WHEN 'COMDIS'. "
        DATA(lv_comdis) = CONV eideswtnum( <lv_field_value> ).
        CALL FUNCTION '/IDXGC/FM_PDOC_DISPLAY'
          EXPORTING
            x_switchnum    = lv_comdis
          EXCEPTIONS
            general_fault  = 1
            not_found      = 2
            not_authorized = 3
            OTHERS         = 4.
        IF sy-subrc NE 0.
          "MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            "WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 type.
        ENDIF.
      WHEN 'PDOC_REF' OR 'LS2_PROC_REF'.
        DATA(lv_switchnum) = CONV eideswtnum( <lv_field_value> ).
        CHECK lv_switchnum IS NOT INITIAL.
        CALL FUNCTION '/IDXGC/FM_PDOC_DISPLAY'
          EXPORTING
            x_switchnum    = lv_switchnum
          EXCEPTIONS
            general_fault  = 1
            not_found      = 2
            not_authorized = 3.

      WHEN 'INV_BULK_REF' OR 'INT_CROSSREFNO' OR 'CROSSREFNO'. " DA-Gruppenrefnr
        IF sy-cprog = '/ADZ/INV_REKLAMATIONSMONITOR'.
          FIELD-SYMBOLS <fs_ext_ui> TYPE ext_ui.
          ASSIGN COMPONENT 'EXT_UI' OF STRUCTURE <ls_row> TO <fs_ext_ui>.
          ls_out-ext_ident = <fs_ext_ui>.
          ls_out-end_date  = sy-datum.
          ls_out-invperiod_start = sy-datum - 100.
          ls_out-invperiod_end   = sy-datum.
        ELSE.
          CHECK ls_out-ext_ident IS NOT INITIAL
            AND ls_out-invperiod_start IS NOT INITIAL
            AND ls_out-invperiod_end IS NOT INITIAL
            AND ls_out-inv_bulk_ref IS NOT INITIAL.
        ENDIF.
        me->show_tasks(
          EXPORTING
            iv_ext_ident       = ls_out-ext_ident
            iv_end_date        = ls_out-end_date
            iv_invperiod_start = ls_out-invperiod_start
            iv_invperiod_end   = ls_out-invperiod_end   ).

      WHEN 'TARIFTYP'.
        DATA(lv_tariftyp) = CONV tariftyp( <lv_field_value> ).
        CALL FUNCTION 'ISU_S_RATE_CAT_DISPLAY'
          EXPORTING
            x_tariftyp     = lv_tariftyp
*           X_UPD_ONLINE   =
            x_no_change    = abap_true
*           X_NO_OTHER     =
*         IMPORTING
*           Y_DB_UPDATE    =
*           Y_EXIT_TYPE    =
          EXCEPTIONS
            not_found      = 1
            not_authorized = 2
            general_fault  = 3
            OTHERS         = 4.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.

      WHEN 'ABLEINH'.
        DATA: ls_te422        TYPE te422,
              ls_comp_te422   TYPE te422,
              lv_update_modus TYPE regen-wmode,
              lt_te422        TYPE TABLE OF te422,
              lt_te425        TYPE TABLE OF te425,
              lt_comp_te425   TYPE TABLE OF te425.

        DATA(lv_ableinh) = CONV ableinh( <lv_field_value> ).
        CALL FUNCTION 'ISU_S_A_SCHEDULMASTREC_PROVIDE'
          EXPORTING
            x_termschl     = lv_ableinh
*           X_RTERMSCHL    =
            x_wmode        = '1'
          IMPORTING
            y_te422        = ls_te422
            y_comp_te422   = ls_comp_te422
            y_update_modus = lv_update_modus
          TABLES
            yt_te425       = lt_te425
            y_comp_te425   = lt_comp_te425
          EXCEPTIONS
            not_found      = 1
            foreign_lock   = 2
            OTHERS         = 3.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.

        CALL FUNCTION 'ISU_S_A_SCHEDULMASTREC_DISPLAY'
          EXPORTING
            x_te422       = ls_te422
            x_comp_te422  = ls_comp_te422
*           X_UPD_ONLINE  =
*           X_NO_CHANGE   =
*         IMPORTING
*           Y_DB_UPDATE   =
*           Y_EXIT_TYPE   =
          TABLES
            xt_te425      = lt_te425
            xt_comp_te425 = lt_comp_te425
          EXCEPTIONS
            error_message = 1
            OTHERS        = 2.

*# Aus FI_NEGATIVE_REMADV_NET
*      WHEN 'INT_INV_DOC_NO'.    inv_mon
      WHEN 'VKONT' OR 'VKONT_INV' OR 'AGGVK' OR 'SUPPL_CONTR_ACCT' OR 'VKONT_MSB'.

        DATA lt_fldvl TYPE TABLE OF bus0fldval.
        lt_fldvl = VALUE  #( ( tbfld = 'FKKVK-VKONT' fldvl = <lv_field_value> ) ).
        CALL FUNCTION 'VKK_FICA_ACCOUNT_MAINTAIN'
          EXPORTING
            i_aktyp = '03'
            i_xinit = ' '
*           I_XSAVE = 'X'
*           I_APPLI =
*           I_XUPDTASK          = 'X'
*           I_SICHT_START       = ' '
*           IMPORTING
*           E_STATE =
*           E_STATE_FCODE       =
*           E_HANDLE            =
          TABLES
*           T_RLTYP =
*           T_RLTGR =
            t_fldvl = lt_fldvl
*           T_SCRSEL            =
*           T_MSG   =
          .




      WHEN 'DOC_ID' OR 'PROC_REF'.

        DATA lv_eideswtnum TYPE eideswtnum.
        DATA lv_doc_id TYPE /idxmm/memidoc-doc_id.

        IF ls_out-invoice_type = /adz/if_remadv_constants=>mc_invoice_type_memi.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = <lv_field_value>
            IMPORTING
              output = lv_doc_id.
          SELECT SINGLE pdoc_ref FROM /idxmm/memidoc INTO lv_eideswtnum WHERE doc_id = lv_doc_id.
        ELSE.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = <lv_field_value>
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

      WHEN 'TRIG_BILL_DOC_NO'.

        DATA lv_bill_doc TYPE e_belnr.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = <lv_field_value>
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


      WHEN 'CI_INVOIC_DOC_NO'.
        DATA lv_ci_inv(12) TYPE n.
        MOVE <lv_field_value> TO lv_ci_inv.
*        IF lv_ci_inv IS NOT INITIAL.
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
*        ENDIF.
      WHEN 'CI_FICA_DOC_NO' .

        DATA lv_opbel_fi(12) TYPE c.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = <lv_field_value>
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

      WHEN 'MSCONS_IDOC' OR 'INVOIC_IDOC' OR 'REMADV_IDOC'.
        DATA lv_idocnum(16) TYPE n.
        lv_idocnum = <lv_field_value>.
        CALL FUNCTION 'EDI_DOCUMENT_DATA_DISPLAY'
          EXPORTING
            docnum               = lv_idocnum
          EXCEPTIONS
            no_data_record_found = 1
            OTHERS               = 2.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

      WHEN 'BILLABLE_ITEM'.
        DATA: ls_srctaid    TYPE fkkr_srctaid,
              lv_srctaid_kk TYPE srctaid_kk,
              lt_srctaid    TYPE fkk_rt_srctaid,
              ls_bitstatus  TYPE fkkr_bitstatus,
              lt_bitstatus  TYPE fkk_rt_bitstatus,
              ls_bitdate    TYPE fkkr_bitdate,
              lt_bitdate    TYPE fkk_rt_bitdate.
*        IF rs_selfield-value IS NOT INITIAL .
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = <lv_field_value>
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

      WHEN 'GPART' OR 'GPART_INV' OR 'PARTNER'.
        DATA: lv_partner TYPE bu_partner.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = <lv_field_value>
          IMPORTING
            output = lv_partner.
        CALL FUNCTION 'ISU_S_PARTNER_DISPLAY'
          EXPORTING
            x_partner = lv_partner.

      WHEN 'INVDOCNO' OR 'CROSSREFNO_MSB'.
        CALL FUNCTION 'FKK_INV_INVDOC_DISP'
          EXPORTING
            x_invdocno = CONV invdocno_kk( <lv_field_value> ).
        IF sy-subrc <> 0.
          " Implement suitable error handling here
        ENDIF.

      WHEN 'BILLDOCNO' OR 'SRCDOCNO'.
        DATA lv_billdocno_kk TYPE billdocno_kk.
        lv_billdocno_kk = <lv_field_value>.
        CALL FUNCTION 'FKK_INV_BILLDOC_DISP'
          EXPORTING
            x_billdocno = lv_billdocno_kk.


      WHEN 'OPBEL' OR 'BCBLN'.
        DATA(lv_transaction) = CONV /adz/fi_neg_remadv_val( 'FPE3' ).
        /adz/cl_inv_customizing_data=>get_config_value(
             EXPORTING iv_option   = CONV #( e_column_id-fieldname )
                       iv_category = 'BDC_END'
                       iv_field    = 'TRANSACTION'
                       iv_id       = '1'
             RECEIVING rv_value = lv_transaction ).
        IF lv_transaction IS INITIAL.
          MESSAGE e000(i4) WITH 'Für den Aufruf des Belegs wurde keine Transaktion hinterlegt.' DISPLAY LIKE 'E'.
          EXIT.
        ENDIF.
        CALL FUNCTION 'FKK_FPE0_START_TRANSACTION'
          EXPORTING
            tcode = CONV syst_tcode( lv_transaction )         " Aufgerufene Transaktionscode
            opbel = CONV opbel_kk( <lv_field_value> ).        " Belegnummer (für Beleganzeige)

        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE sy-msgty.
        ENDIF.

      WHEN 'BILLPLANNO'.
        DATA(lv_billplanno) = CONV billplanno_kk( <lv_field_value> ).
        CALL FUNCTION 'FKK_BIX_BILLPLAN_DISP'
          EXPORTING
            i_billplanno = lv_billplanno.

      WHEN 'FREE_TEXT1'.
        get_free_text( iv_int_inv_doc_no = ls_out-int_inv_doc_no ).

      WHEN 'FREE_TEXT4'.
        ASSIGN <ls_row> TO <ls_out_reklamon>.   " cast auf /adz/inv_s_out_reklamon
        me->int_status(
          EXPORTING
            iv_int_inv_doc_no  = <ls_out_reklamon>-int_inv_doc_no
            iv_int_inv_line_no = <ls_out_reklamon>-int_inv_line_no
          CHANGING
            cv_free_text4      = <ls_out_reklamon>-free_text4 ).
        "sender->refresh_table_display( ).

* Eingabe Notiz
      WHEN 'FREE_TEXT5'.
        ASSIGN <ls_row> TO <ls_out_reklamon>.   " cast auf /adz/inv_s_out_reklamon
        "Sonderfall Solingen
        SELECT COUNT( * ) FROM /adz/fi_remad WHERE negrem_option = 'NOTIZ' AND negrem_field = 'SOLINGEN' AND negrem_value = 'X'.
        IF sy-subrc = 0.
          me->int_notice(
            EXPORTING
              iv_int_inv_doc_no  = <ls_out_reklamon>-int_inv_doc_no
              iv_int_inv_line_no = <ls_out_reklamon>-int_inv_line_no
            CHANGING
              cv_free_text5      = <ls_out_reklamon>-free_text5
          ).
        ELSE.
          " Eingabe Notiz über Texteditor
          me->int_notice_edit(
            EXPORTING
              iv_int_inv_doc_no  = <ls_out_reklamon>-int_inv_doc_no
              iv_int_inv_line_no = <ls_out_reklamon>-int_inv_line_no
            CHANGING
              cv_free_text5      = <ls_out_reklamon>-free_text5
          ).
        ENDIF.
      WHEN OTHERS.

    ENDCASE.
  ENDMETHOD.


  METHOD  /adz/if_inv_salv_table_evt_hlr~on_user_command.
    process_user_command( EXPORTING e_ucomm = e_ucomm    sender = sender ).
  ENDMETHOD.


  METHOD add_text.

    DATA: lv_title           TYPE text80,
          text1              TYPE text132,
          text2              TYPE text132,
          text255            TYPE text255,
          anzahl_sel         TYPE anzahl,
          lv_line_no         TYPE i,
          lt_invtext         TYPE TABLE OF /adz/invtext,
          ls_invtext         TYPE /adz/invtext,
          lt_fields          TYPE TABLE OF sval,
          ls_fields          TYPE sval,
          lv_textnr          TYPE i,
          lv_spaces          TYPE i,
          lv_spacechars(255),
          lv_int_doc_string  TYPE string,
          lv_answer(1)       TYPE c.

*BREAK struck-f.
    LOOP AT mrt_out_table->* ASSIGNING FIELD-SYMBOL(<ls_out>) WHERE sel = 'X'.
      SELECT * FROM /adz/invtext INTO ls_invtext WHERE int_inv_doc_nr = <ls_out>-int_inv_doc_no.

        READ TABLE lt_invtext TRANSPORTING NO FIELDS WITH  KEY datum = ls_invtext-datum zeit = ls_invtext-zeit uname = ls_invtext-uname.
        IF sy-subrc <> 0.
          lv_textnr = lv_textnr + 1 .
          IF lv_textnr > 15.
            EXIT.
          ENDIF.
          lv_int_doc_string =  <ls_out>-int_inv_doc_no.
          SHIFT lv_int_doc_string LEFT DELETING LEADING '0'.
          lv_spaces = 2.
          CONCATENATE  '' ls_invtext-text  INTO ls_invtext-text SEPARATED BY lv_spacechars(lv_spaces).
          CLEAR ls_fields.
          ls_fields-tabname      = '/ADZ/TEXDUMMY'.
          ls_fields-fieldname    = 'TEXT' && lv_textnr.
          ls_fields-field_attr   = '02'.
          ls_fields-value = 'Beleg' && lv_int_doc_string && ' von: ' && ls_invtext-uname && ' am: ' &&  ls_invtext-datum   && ': ' && ls_invtext-text .
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


    lv_title = |Bemerkung zum| && | | && iv_action && | | && |anlegen.|.

* Aufbau des Dialogfensters festlegen
    CLEAR ls_fields.
    ls_fields-tabname      = '/ADZ/INVTEXT'.
    ls_fields-fieldname    = 'TEXT'.
*  FIELDS-VALUE       = E070-TRKORR.
* Schlüsselwort soll nicht aus dem Dictionary übernommen werden
    ls_fields-fieldtext    = 'Bemerkung.'.
*                                      (050).
    ls_fields-field_obl    = ' '.
    APPEND ls_fields TO lt_fields.
    lv_line_no = sy-tabix.

    CALL FUNCTION 'POPUP_GET_VALUES'
      EXPORTING
        no_value_check  = abap_true
        popup_title     = lv_title
*       START_COLUMN    = '5'
*       START_ROW       = '5'
      IMPORTING
        returncode      = lv_answer
      TABLES
        fields          = lt_fields
      EXCEPTIONS
        error_in_fields = 1
        OTHERS          = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

*    CALL FUNCTION 'POPUP_GET_VALUES_USER_BUTTONS'
*      EXPORTING
**       F1_FORMNAME        = ' '
**       F1_PROGRAMNAME     = ' '
**       F4_FORMNAME        = ' '
**       F4_PROGRAMNAME     = ' '
*        formname           = 'HANDLE_CODE_OK'
*        programname        = sy-cprog
*        popup_title        = lv_title
*        ok_pushbuttontext  = 'Ja'
*        quickinfo_ok_push  = 'Es wird ein Text angelegt'
*        first_pushbutton   = 'Nein'
*        quickinfo_button_1 = 'Es wird kein Text angelegt '
*      IMPORTING
*        returncode         = lv_answer
*      TABLES
*        fields             = lt_fields
*      EXCEPTIONS
*        error_in_fields    = 1
*        OTHERS             = 2.
*    IF sy-subrc <> 0.
** Implement suitable error handling here
*    ENDIF.

    IF lv_answer IS INITIAL.
*BREAK struck-f.
      LOOP AT mrt_out_table->* ASSIGNING <ls_out> WHERE sel = 'X'.
        READ TABLE lt_fields INTO ls_fields INDEX lv_line_no.
        ls_invtext-text = ls_fields-value.
        ls_invtext-datum = sy-datum.
        ls_invtext-action = iv_action.
        ls_invtext-int_inv_doc_nr = <ls_out>-int_inv_doc_no.
        ls_invtext-uname = sy-uname.
        ls_invtext-zeit = sy-uzeit.

        INSERT INTO /adz/invtext VALUES ls_invtext.
      ENDLOOP.

    ENDIF."ls_invtext-


  ENDMETHOD.


  METHOD call_cic.

    DATA: ls_bdc       TYPE bdcdata,
          lt_bdc       TYPE TABLE OF bdcdata,
          lt_messtab   TYPE TABLE OF bdcmsgcoll,
          lv_screen_no TYPE cicfwscreenno,
          lv_tcode     TYPE sy-tcode.

    lv_screen_no = me->get_cic_frame_4_user( ).

    CLEAR ls_bdc.
    ls_bdc-program = 'SAPLCIC0'.
    ls_bdc-dynpro = lv_screen_no.
    ls_bdc-dynbegin = 'X'.
    APPEND ls_bdc TO lt_bdc.
    SELECT SINGLE vkonto FROM ever WHERE vertrag = @iv_vertrag INTO @DATA(lv_vkont) .
    SELECT SINGLE gpart FROM fkkvkp WHERE vkont = @lv_vkont INTO @DATA(lv_gpart) .
    CLEAR ls_bdc.
    ls_bdc-fnam = 'EFINDD_CIC-C_BUPART'.
    ls_bdc-fval = lv_gpart.
    APPEND ls_bdc TO lt_bdc.

    lv_tcode = 'CIC0'.
    CALL FUNCTION 'CALL_CIC_TRANSACTION'
      EXPORTING
        tcode        = lv_tcode
        skipfirst    = 'X'
      TABLES
        in_bdcdata   = lt_bdc
        oult_messtab = lt_messtab
*   EXCEPTIONS
*       NO_AUTHORIZATION       = 1
*       OTHERS       = 2
      .
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ENDMETHOD.


  METHOD call_delvnoteman.
    DATA lt_proc_ref  TYPE /adz/inv_rt_de_proc_ref_num.
    lt_proc_ref = VALUE #( FOR ls IN mrt_out_table->* WHERE ( sel = 'X' AND ls_pdoc_ref <> '' )
      ( sign = 'I'  option = 'EQ' low = ls-ls_pdoc_ref  ) ).
    IF lt_proc_ref IS NOT INITIAL.
      SUBMIT /adz/inv_delvnoteman
        WITH so_swtnm IN lt_proc_ref
         AND RETURN.
    ENDIF.
  ENDMETHOD.


  METHOD change_anl.

    READ TABLE mrt_out_table->* ASSIGNING FIELD-SYMBOL(<ls_out>) WITH KEY sel = abap_true.
    IF sy-subrc = 0.

      ASSIGN COMPONENT 'EXT_UI' OF STRUCTURE <ls_out> TO FIELD-SYMBOL(<lv_ext_ui>).
      DATA(lv_anlage) = /adz/cl_inv_remadv_helper=>get_analage( EXPORTING iv_ext_ui = <lv_ext_ui> ).

      DATA(lv_transaction) = /adz/cl_inv_customizing_data=>get_config_value(
                                                        EXPORTING iv_option   = iv_option
                                                                  iv_category = 'BDC_END'
                                                                  iv_field    = 'TRANSACTION'
                                                                  iv_id       = '1' ).
      IF lv_transaction IS INITIAL.
        MESSAGE i000(e4) WITH 'Für den Aufruf der Anlage wurde keine Transaktion hinterlegt.' DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.

      SET PARAMETER ID 'ANL' FIELD lv_anlage.
      CALL TRANSACTION lv_transaction AND SKIP FIRST SCREEN.
    ENDIF.

  ENDMETHOD.


  METHOD check_select.

    IF iv_nr_select_lines  EQ 0.
      rv_good = abap_false.
      MESSAGE i000(e4) WITH 'Bitte selektieren Sie mindestens einen Datensatz.' DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.
    rv_good = abap_true.

  ENDMETHOD.


  METHOD check_single_select.
    rb_ok = abap_false.
    IF iv_nr_select_lines EQ 0.
      MESSAGE i000(e4) WITH 'Bitte selektieren Sie einen Datensatz.' DISPLAY LIKE 'E'.
      EXIT.
    ELSEIF   iv_nr_select_lines GT 1.

      IF iv_text IS NOT INITIAL.
        MESSAGE i000(e4) WITH iv_text iv_text2 DISPLAY LIKE 'E'.
      ELSE.
        MESSAGE i000(e4) WITH 'Bitte selektieren Sie nur einen Datensatz.' DISPLAY LIKE 'E'.
      ENDIF.

      EXIT.
    ENDIF.
    rb_ok = abap_true.
  ENDMETHOD.


  METHOD check_sperre.

    DATA: lv_sperr_flag TYPE flag.
    rv_sperre = abap_false.
    LOOP AT mrt_out_table->* ASSIGNING FIELD-SYMBOL(<ls_out>) WHERE sel = abap_true.

      SELECT COUNT(*) FROM /adz/invsperr WHERE int_inv_doc_nr = <ls_out>-int_inv_doc_no.
      IF sy-subrc = 0.
        lv_sperr_flag = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF lv_sperr_flag = abap_true.
      rv_sperre = abap_true.
      MESSAGE 'Ein oder mehrere Belege sind gesperrt. Aktion abgebrochen.' TYPE 'I' DISPLAY LIKE 'E'.
    ENDIF.

  ENDMETHOD.


  METHOD choose.
    CHECK it_sel_rows_index IS NOT INITIAL.
    DATA lt_r_tabindex TYPE RANGE OF sy-tabix.
    lt_r_tabindex = VALUE #( FOR ls_index IN it_sel_rows_index
     (  sign = 'I' option = 'EQ' low = ls_index-index high = '' ) ).

    DATA(lrt_out) = get_outable(  ).
    FIELD-SYMBOLS <lt_out> TYPE ANY TABLE.
    ASSIGN lrt_out->* TO <lt_out>.
    LOOP AT <lt_out> ASSIGNING FIELD-SYMBOL(<ls_out>).
      IF sy-tabix IN lt_r_tabindex.
        ASSIGN COMPONENT 'SEL' OF STRUCTURE <ls_out> TO FIELD-SYMBOL(<lv_value>).
        IF sy-subrc EQ 0.
          <lv_value> = abap_true.
        ELSE.
          MESSAGE 'COLUMN SEL is not definied' TYPE 'X'.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD constructor.
    IF irt_out_table IS NOT INITIAL.
      mrt_out_table ?= irt_out_table.
    ENDIF.
    ms_selscreen   = is_selscreen.
    CREATE DATA mrs_noti.
  ENDMETHOD.


  METHOD ende_proc_task.
    DATA: lt_ergebnis    TYPE /adz/manager_proz_collect_t,
          ls_ergebnis    TYPE /adz/manager_proz_collect_s,
          lt_inv_collect TYPE tinv_int_inv_doc_no,
          l_tinv_inv_doc TYPE tinv_inv_doc.

    DATA: lt_return    TYPE bapirettab,
          lv_proc_type TYPE inv_process_type,
          lv_error     TYPE inv_kennzx.
    DATA  lt_fehler    TYPE /adz/inv_t_fehler.
    FIELD-SYMBOLS  <ls_out> LIKE LINE OF mrt_out_table->*.


    RECEIVE RESULTS FROM FUNCTION '/ADZ/INV_MANAGER_PROCESS_TA'
        IMPORTING
          it_inv_doc_nr    = lt_inv_collect
          CHANGING
          process_document = lt_ergebnis.

    LOOP AT lt_ergebnis INTO ls_ergebnis.
      "invoice zum Prozessieren sammeln
      TRY.
          ASSIGN mrt_out_table->*[ int_inv_doc_no = ls_ergebnis-int_inv_doc_no ] TO <ls_out>.
          CHECK sy-subrc EQ 0.
          lt_return   = ls_ergebnis-ex_return.
          lv_proc_type = ls_ergebnis-ex_exit_process_type.
          lv_error     = ls_ergebnis-ex_proc_error_occurred.

          SELECT SINGLE * FROM tinv_inv_doc INTO l_tinv_inv_doc
             WHERE int_inv_doc_no = <ls_out>-int_inv_doc_no.

          <ls_out>-inv_doc_status = l_tinv_inv_doc-inv_doc_status.

          IF lt_return[] IS NOT INITIAL.
            CLEAR lt_fehler.
            get_errormessage(
              EXPORTING
                iv_doc_no =  <ls_out>-int_inv_doc_no  " Interne Nummer des Rechnungsbelegs/Avisbelegs
              CHANGING
                ct_error  =  lt_fehler                " Tabelle von Fehlermeldung
            ).

**      Mehrfacheinträge aus der Fehlertabelle löscben
            IF lt_fehler IS NOT INITIAL.
              SORT lt_fehler.
              DELETE ADJACENT DUPLICATES FROM lt_fehler COMPARING ALL FIELDS.
            ENDIF.

            IF lt_fehler IS NOT INITIAL.
              DATA(ls_fehler) = lt_fehler[ 1 ].
              SELECT SINGLE * FROM t100 INTO @DATA(ls_wa_t100)
                WHERE sprsl = 'D'
                  AND arbgb = @ls_fehler-msgid
                  AND msgnr = @ls_fehler-msgno.

              <ls_out>-fehler = ls_wa_t100-text.
              REPLACE ALL OCCURRENCES OF '&1' IN <ls_out>-fehler WITH ls_fehler-msgv1.
              REPLACE ALL OCCURRENCES OF '&2' IN <ls_out>-fehler WITH ls_fehler-msgv2.
              REPLACE ALL OCCURRENCES OF '&3' IN <ls_out>-fehler WITH ls_fehler-msgv3.
              REPLACE ALL OCCURRENCES OF '&4' IN <ls_out>-fehler WITH ls_fehler-msgv4.
              <ls_out>-lights = '1'.
            ENDIF.
          ENDIF.
        CATCH cx_sy_itab_line_not_found.
      ENDTRY.
    ENDLOOP.
    mv_akt_proz = mv_akt_proz - 1.

  ENDMETHOD.


  METHOD get_anlage.
  ENDMETHOD.


  METHOD get_cic_frame_4_user.

    DATA: lt_cic_prof TYPE TABLE OF cicprofiles.

    CALL FUNCTION 'CIC_GET_ORG_PROFILES'
      EXPORTING
        agent                 = sy-uname
      TABLES
        profile_list          = lt_cic_prof
      EXCEPTIONS
        call_center_not_found = 1
        agent_group_not_found = 2
        profiles_not_found    = 3
        no_hr_record          = 4
        cancel                = 5
        OTHERS                = 6.
    IF sy-subrc <> 0.
      MESSAGE i000(e4) WITH 'CIC-Profil konnte nicht gelesen werden(1).' DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.

* existiert mind. 1 Eintrag
    IF lines( lt_cic_prof ) EQ 0.
      MESSAGE i000(e4) WITH 'CIC-Profil konnte nicht gelesen werden(2).' DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.

* 1. Datensatz aus Tabelle zuweisen
    FIELD-SYMBOLS: <ls_prof> TYPE cicprofiles.
    READ TABLE lt_cic_prof ASSIGNING <ls_prof> INDEX 1.
* Fehlerprüfung
    IF <ls_prof> IS NOT ASSIGNED.
      MESSAGE i000(e4) WITH 'CIC-Profil konnte nicht gelesen werden(3).' DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.

* Passendes CIC-Profil lesen
* Konfiguration auslesen um die DYNPRO-Nr zu gelangen
    SELECT SINGLE frame_screen
      INTO rv_screen_no
      FROM cicprofile
        INNER JOIN cicconf
          ON cicconf~frame_conf = cicprofile~framework_id
      WHERE cicprofile~cicprof = <ls_prof>-cicprof.

    IF rv_screen_no IS INITIAL.
      MESSAGE i000(e4) WITH 'CIC-Profil konnte nicht gelesen werden(4).' DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.

  ENDMETHOD.


  METHOD get_enet_price_anl.

    DATA: ls_tinv_inv_line_b TYPE tinv_inv_line_b,
          lv_sparte          TYPE sparte,
          lv_adesparte       TYPE /adz/sparte,
          lv_count           TYPE i.

    LOOP AT mrt_out_table->* ASSIGNING FIELD-SYMBOL(<ls_out>) WHERE sel = abap_true.
      lv_count = lv_count + 1.
    ENDLOOP.
    IF lv_count <> 1.
      MESSAGE 'Bitte genau eine Rechnung auswählen.' TYPE 'I' DISPLAY LIKE 'E'.
      RETURN.
    ELSE.
      READ TABLE mrt_out_table->* ASSIGNING <ls_out> WITH KEY sel = 'X'.
      SELECT SINGLE * FROM tinv_inv_line_b INTO ls_tinv_inv_line_b
       WHERE int_inv_doc_no = <ls_out>-int_inv_doc_no AND product_id = '9990001000532'.
*    break struck-f.
      SELECT SINGLE sparte FROM ever INTO lv_sparte WHERE vertrag = <ls_out>-vertrag.
      IF lv_sparte IS INITIAL.
        SELECT SINGLE sparte FROM eanl INTO lv_sparte  WHERE anlage = <ls_out>-anlage.
      ENDIF.
      SELECT SINGLE adsparte FROM /adz/ec_spart INTO lv_adesparte WHERE sparte = lv_sparte.
      IF lv_adesparte = 'ST' OR lv_adesparte IS INITIAL.
        CALL FUNCTION '/ADZ/ENET_GET_PRICES_ANLAGE'
          EXPORTING
            anlage         = <ls_out>-anlage
            abr_ab         = <ls_out>-invperiod_start
            abr_bis        = <ls_out>-invperiod_end
            display        = 'X'
            abr_preis      = ls_tinv_inv_line_b-price
            int_inv_doc_no = <ls_out>-int_inv_doc_no
          EXCEPTIONS
            kein_netz      = 1
            OTHERS         = 2.
        IF sy-subrc <> 0.
          MESSAGE 'Netz nicht in den ENET Tabellen gefunden!' TYPE 'I' DISPLAY LIKE 'E'.
          RETURN.
        ENDIF.
      ELSEIF lv_adesparte = 'GA'.

        CALL FUNCTION '/ADZ/ENET_GET_PREIS_ANL_GAS'
          EXPORTING
            anlage         = <ls_out>-anlage
            abr_ab         = <ls_out>-invperiod_start
            abr_bis        = <ls_out>-invperiod_end
            display        = 'X'
            abr_preis      = ls_tinv_inv_line_b-price
            int_inv_doc_no = <ls_out>-int_inv_doc_no
* EXCEPTIONS
*           KEIN_NETZ      = 1
*           OTHERS         = 2
          .
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.


      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD get_errormessage.

    DATA: lt_inv_loghd   TYPE STANDARD TABLE OF tinv_inv_loghd,
          ls_inv_loghd   TYPE tinv_inv_loghd,
          ls_inv_docproc TYPE tinv_inv_docproc,
          lt_inv_docproc TYPE STANDARD TABLE OF tinv_inv_docproc,
          ls_error       TYPE /adz/inv_s_fehler.

    DATA: lv_datefrom TYPE sy-datum.

    CLEAR lt_inv_docproc.
    SELECT * FROM tinv_inv_docproc INTO TABLE lt_inv_docproc
      WHERE int_inv_doc_no = iv_doc_no
       AND status = '04'.

    IF lt_inv_docproc IS NOT INITIAL.

      SELECT * FROM tinv_inv_loghd INTO TABLE lt_inv_loghd
        FOR ALL ENTRIES IN lt_inv_docproc
        WHERE int_inv_doc_no = iv_doc_no
        AND status = '03'
        AND process = lt_inv_docproc-process.

      SORT lt_inv_loghd BY datefrom DESCENDING.

      LOOP AT lt_inv_loghd INTO ls_inv_loghd.

        IF lv_datefrom IS INITIAL.
          lv_datefrom = ls_inv_loghd-datefrom.
        ENDIF.

        IF ls_inv_loghd-datefrom LT lv_datefrom.
          EXIT.
        ENDIF.

        SELECT * FROM tinv_inv_logline INTO @DATA(ls_inv_logline)
                WHERE inv_log_no = @ls_inv_loghd-inv_log_no
                  AND msgty = 'E'.
          MOVE-CORRESPONDING ls_inv_logline TO ls_error.
          APPEND ls_error TO ct_error.
          CLEAR ls_error.
        ENDSELECT.

      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD  get_free_text.
    DATA: lt_data TYPE /idexge/tt_doc_adddata,
          ls_data TYPE /idexge/doc_adddata.

    DATA: ls_text TYPE /idexge/rej_noti.
    DATA: lt_text TYPE TABLE OF /idexge/rej_noti.

    CHECK iv_int_inv_doc_no IS NOT INITIAL.

    SELECT * FROM /idexge/rej_noti INTO TABLE lt_text
      WHERE int_inv_doc_no = iv_int_inv_doc_no.

    ls_data-structure = '/IDEXGE/REJ_NOTI'.
    GET REFERENCE OF lt_text  INTO ls_data-adddata_ref.
    APPEND ls_data TO lt_data.

    CALL METHOD /idexge/cl_inv_adddata=>action_idex_alv_rej_noti
      EXPORTING
*       iv_edit_mode   =
        it_adddata     = lt_data
        iv_doc_no      = iv_int_inv_doc_no
*       iv_line_no     = '1'
*       iv_must_flag   =
      EXCEPTIONS
        error_occurred = 1
        edit_cancel    = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
*         Implement suitable error handling here
    ENDIF.
  ENDMETHOD.


  METHOD get_hotspot_row.
    " angeclickte Zeile holen
    ASSIGN mrt_out_table->* TO FIELD-SYMBOL(<lt_out>).
    rrs_row = REF #( <lt_out>[ iv_rownr ] ).
    "READ TABLE <lt_out> INTO DATA(rs_row) INDEX iv_rownr.
  ENDMETHOD.


  METHOD get_outable.
    rrt_out = mrt_out_table.
  ENDMETHOD.


  METHOD get_popup_canc_reason.

    DATA: ls_selfield       TYPE slis_selfield,
          lt_fieldcatalog   TYPE lvc_t_fcat,
          lv_structure_name TYPE dd02l-tabname VALUE 'INV_DIALOG_SCREEN_RVRSL_REASON',
          it_values_alv     TYPE STANDARD TABLE OF inv_dialog_screen_rvrsl_reason,
          ls_values_alv     LIKE LINE OF it_values_alv[],
          lv_values         TYPE tinv_c_cncl_rsnt.

* Prepare POPUP to display values
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name = lv_structure_name
      CHANGING
        ct_fieldcat      = lt_fieldcatalog
      EXCEPTIONS
        OTHERS           = 1.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'X' NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

* Get values
    LOOP AT   cl_inv_inv_remadv_doc=>customizing-t_tinv_c_cncl_rsn[]
         INTO lv_values.
      ls_values_alv-reversal_rsn     = lv_values-inv_cancel_rsn.
      ls_values_alv-reversal_rsn_txt = lv_values-text.
      APPEND ls_values_alv TO it_values_alv[].
    ENDLOOP.

* Call ALV
    CALL FUNCTION 'LVC_SINGLE_ITEM_SELECTION'
      EXPORTING
        i_title         = TEXT-t04           " Stornogrund auswählen
        it_fieldcatalog = lt_fieldcatalog
      IMPORTING
        es_selfield     = ls_selfield
      TABLES
        t_outtab        = it_values_alv[].

* Get value by index...
    READ TABLE it_values_alv[]  INDEX ls_selfield-tabindex
                                INTO  ls_values_alv.
    IF sy-subrc = 0.
      rv_cancel_reason = ls_values_alv-reversal_rsn.
    ELSE.
      CLEAR rv_cancel_reason .
    ENDIF.

  ENDMETHOD.


  METHOD get_popup_comp_reason.

    DATA: lv_deregswitch_paymnt_proc TYPE e_deregswitch_paymnt_proc,
          ls_selfield                TYPE slis_selfield,
          lt_fieldcatalog            TYPE lvc_t_fcat,
          lv_tabname                 TYPE dd02l-tabname VALUE 'INV_DIALOG_SCREEN_ADJ_REASON',
          lt_adj_reason              TYPE STANDARD TABLE OF inv_dialog_screen_adj_reason,
          ls_adj_reason              TYPE inv_dialog_screen_adj_reason,
          lt_adj_rsnt                TYPE STANDARD TABLE OF tinv_c_adj_rsnt,
          ls_adj_rsnt                TYPE tinv_c_adj_rsnt,
          lt_process_list            TYPE tinv_skip_process.

    CALL FUNCTION 'ISU_DB_EDEREGSWITCH2005_SELECT'
      IMPORTING
*       Y_DEREGSWITCH2005       =
*       Y_SERV_PROV_ACTIVE      =
        y_paymnt_proc_active    = lv_deregswitch_paymnt_proc
      EXCEPTIONS
        customizing_not_defined = 1
        error_ocurred           = 2
        OTHERS                  = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE sy-msgty. "RAISING system_error.
    ENDIF.

* Prepare POPUP to display values
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name = lv_tabname
      CHANGING
        ct_fieldcat      = lt_fieldcatalog
      EXCEPTIONS
        OTHERS           = 1.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'X' NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

* Get values
    SELECT * FROM tinv_c_adj_rsnt INTO CORRESPONDING FIELDS OF TABLE lt_adj_rsnt.

* Build table for ALV
    LOOP AT    lt_adj_rsnt INTO  ls_adj_rsnt WHERE spras = sy-langu.
      ls_adj_reason-adj_rstgr = ls_adj_rsnt-rstgr.
      ls_adj_reason-adj_text  = ls_adj_rsnt-text.
      ls_adj_reason-adj_frequ = 0.
      APPEND ls_adj_reason TO lt_adj_reason.
*   Remove all values for this key
      DELETE lt_adj_rsnt WHERE rstgr = ls_adj_rsnt-rstgr.
    ENDLOOP.

* Now add values with SPRAS not equal SY-LANGU (only one)
    LOOP AT lt_adj_rsnt INTO ls_adj_rsnt.
      ls_adj_reason-adj_rstgr = ls_adj_rsnt-rstgr.
      ls_adj_reason-adj_text  = ls_adj_rsnt-text.
      ls_adj_reason-adj_frequ = 0.
      APPEND ls_adj_reason TO lt_adj_reason.
*   Remove all values for this key
      DELETE lt_adj_rsnt WHERE rstgr = ls_adj_rsnt-rstgr.
    ENDLOOP.

* Call ALV
    CALL FUNCTION 'LVC_SINGLE_ITEM_SELECTION'
      EXPORTING
        i_title         = TEXT-t03           " Reklamationsgrund auswählen
        it_fieldcatalog = lt_fieldcatalog
      IMPORTING
        es_selfield     = ls_selfield
      TABLES
        t_outtab        = lt_adj_reason.

* Get value by index...
    READ TABLE lt_adj_reason INDEX ls_selfield-tabindex INTO ls_adj_reason.
    IF sy-subrc = 0.
      cv_compl_reason = ls_adj_reason-adj_rstgr.
    ELSE.
      CLEAR cv_compl_reason.
    ENDIF.

  ENDMETHOD.


  METHOD int_notice.
    DATA lv_answer TYPE char1.
    DATA lt_sval TYPE STANDARD TABLE OF sval.
    lt_sval = VALUE #( ( tabname   = '/IDEXGE/REJ_NOTI'  fieldname = 'FREE_TEXT5' fieldtext = 'Notiz' value = cv_free_text5 ) ).

    CALL FUNCTION 'POPUP_GET_VALUES'
      EXPORTING
        popup_title     = 'Interne Notiz'
        start_column    = '5'
        start_row       = '5'
      IMPORTING
        returncode      = lv_answer
      TABLES
        fields          = lt_sval
      EXCEPTIONS
        error_in_fields = 1
        OTHERS          = 2.

    CHECK sy-subrc = 0.
    CHECK lv_answer = space.

    READ TABLE lt_sval INTO DATA(w_sval) INDEX 1.
* read data from database /idexge/rej_noti
    SELECT SINGLE * FROM /idexge/rej_noti INTO @DATA(wa_rej_noti)
       WHERE int_inv_doc_no  = @iv_int_inv_doc_no
       AND   int_inv_line_no = @iv_int_inv_line_no.

    IF sy-subrc <> 0.
      wa_rej_noti-int_inv_doc_no = iv_int_inv_doc_no.
      wa_rej_noti-int_inv_line_no = iv_int_inv_line_no.
      wa_rej_noti-free_text5 = w_sval-value.
      INSERT INTO /idexge/rej_noti VALUES wa_rej_noti.
    ELSE.
      wa_rej_noti-free_text5 = w_sval-value.
      MODIFY /idexge/rej_noti FROM wa_rej_noti.
    ENDIF.

    IF sy-subrc = 0.
      cv_free_text5 = w_sval-value.
      COMMIT WORK.
    ENDIF.
  ENDMETHOD.


  METHOD int_notice_edit.
    CONSTANTS: co_object TYPE tdobject VALUE 'Z_REMADV',
               co_id     TYPE tdid VALUE 'Z001'.
    DATA:  lsx_header TYPE thead.
    DATA:  ltx_lines TYPE STANDARD TABLE OF tline.

    DATA: help_line TYPE tline.
    DATA: lv_length TYPE i.

    lsx_header-tdobject = co_object.
    lsx_header-tdid = co_id.
    lsx_header-tdspras = sy-langu.
    lsx_header-tdlinesize = '132'.
    CONCATENATE iv_int_inv_doc_no  '_'  iv_int_inv_line_no  INTO lsx_header-tdname.

    CLEAR ltx_lines.
* Text (falls bereits vorhanden) einlesen und in Itab stellen
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
*       CLIENT                  = SY-MANDT
        id                      = lsx_header-tdid
        language                = lsx_header-tdspras
        name                    = lsx_header-tdname
        object                  = lsx_header-tdobject
*       ARCHIVE_HANDLE          = 0
*       LOCAL_CAT               = ' '
*   IMPORTING
*       HEADER                  =
*       OLD_LINE_COUNTER        =
      TABLES
        lines                   = ltx_lines
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
        IF cv_free_text5 IS NOT INITIAL.
          lv_length = strlen( cv_free_text5 ).
          IF lv_length GT 132.
            help_line-tdline = cv_free_text5(132).
            APPEND help_line TO ltx_lines.
            help_line-tdline = cv_free_text5+132.
            APPEND help_line TO ltx_lines.
          ELSE.
            help_line-tdline = cv_free_text5.
            APPEND help_line TO ltx_lines.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.


* Text Editieren
    CALL FUNCTION 'EDIT_TEXT'
      EXPORTING
*       DISPLAY       = ' '
*       EDITOR_TITLE  = ' '
        header        = lsx_header
      TABLES
        lines         = ltx_lines
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

    IF lines( ltx_lines ) > 0.
      cv_free_text5 = CONV #( ltx_lines[ 1 ] ).
    ENDIF.

  ENDMETHOD.                    " INT_NOTICE_EDIT


  METHOD int_status.
    DATA lv_answer TYPE char1.
    DATA lt_sval TYPE STANDARD TABLE OF sval.
    lt_sval = VALUE #( ( tabname   = '/IDEXGE/REJ_NOTI'  fieldname = 'FREE_TEXT4' fieldtext = 'Status' value = cv_free_text4 ) ).
    CALL FUNCTION 'POPUP_GET_VALUES'
      EXPORTING
        popup_title     = 'Interner Status'
        start_column    = '5'
        start_row       = '5'
      IMPORTING
        returncode      = lv_answer
      TABLES
        fields          = lt_sval
      EXCEPTIONS
        error_in_fields = 1
        OTHERS          = 2.

    CHECK sy-subrc = 0.
    CHECK lv_answer = space.

    READ TABLE lt_sval INTO DATA(w_sval) INDEX 1.
* read data from database /idexge/rej_noti
    SELECT SINGLE * FROM /idexge/rej_noti INTO @DATA(wa_rej_noti)
       WHERE int_inv_doc_no  = @iv_int_inv_doc_no
       AND   int_inv_line_no = @iv_int_inv_line_no.

    IF sy-subrc <> 0.
      wa_rej_noti-int_inv_doc_no  = iv_int_inv_doc_no.
      wa_rej_noti-int_inv_line_no = iv_int_inv_line_no.
      wa_rej_noti-free_text4 = w_sval-value.
      INSERT INTO /idexge/rej_noti VALUES wa_rej_noti.
    ELSE.
      wa_rej_noti-free_text4 = w_sval-value.
      MODIFY /idexge/rej_noti FROM wa_rej_noti.
    ENDIF.

    IF sy-subrc = 0.
      cv_free_text4 = w_sval-value.
      COMMIT WORK.
    ENDIF.
  ENDMETHOD.


  METHOD in_memory.
    IF 1 = 2.
      "In memory of our friend Peter Nuß.
    ENDIF.
  ENDMETHOD.


  METHOD mark_all.
    DATA(lrt_out) = get_outable(  ).
    FIELD-SYMBOLS <lt_out> TYPE ANY TABLE.
    ASSIGN lrt_out->* TO <lt_out>.
    LOOP AT <lt_out> ASSIGNING FIELD-SYMBOL(<ls_out>).
      ASSIGN COMPONENT 'SEL' OF STRUCTURE <ls_out> TO FIELD-SYMBOL(<lv_value>).
      <lv_value> = abap_true.
    ENDLOOP.
  ENDMETHOD.


  METHOD process.

    TYPES: BEGIN OF tt_art_check,
             belegart(3) TYPE c,
             anzahl      TYPE i,
           END OF tt_art_check.

    DATA: lt_ex_return           TYPE         bapirettab,
          lo_doc_object          TYPE REF TO cl_inv_inv_remadv_doc,
          ls_art_check           TYPE tt_art_check,
          lt_art_check           TYPE TABLE OF tt_art_check,
          lv_anz                 TYPE i,
          lv_doc_no1             TYPE   inv_int_inv_doc_no,
          lv_count               TYPE i,
          lt_tinv_int_inv_doc_no TYPE tinv_int_inv_doc_no,
          lt_tinv_inv_prcsupp    TYPE TABLE OF tinv_inv_prcsupp,
          ls_tinv_inv_prcsupp    TYPE  tinv_inv_prcsupp.

    LOOP AT mrt_out_table->* ASSIGNING FIELD-SYMBOL(<ls_out>) WHERE sel = abap_true.
      lv_anz = lv_anz + 1.
      ls_art_check-anzahl = 1.
      ls_art_check-belegart = <ls_out>-belegart.
      COLLECT ls_art_check INTO lt_art_check.
    ENDLOOP.

*  IF lines( lt_art_check ) > 1.
*    MESSAGE i024(/adz/inv_manager) DISPLAY LIKE 'E'.
*    exit.
*  ENDIF.

    IF lv_anz = 0.
      MESSAGE i025(/adz/inv_manager) DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.

    LOOP AT mrt_out_table->* ASSIGNING <ls_out> WHERE sel = abap_true.
      FREE lo_doc_object.
*    CREATE OBJECT lo_doc_object
*      EXPORTING
*        im_work_mode  = cl_inv_inv_remadv_doc=>co_wmode_change
*        im_doc_number = lr_out->int_inv_doc_no
*      EXCEPTIONS
*        others        = 1.
      IF lv_count = 0.
        lv_doc_no1 = <ls_out>-int_inv_doc_no.
        CALL METHOD cl_inv_inv_remadv_doc=>suppress_subprocess
          EXPORTING
            im_doc_number   = <ls_out>-int_inv_doc_no
            im_no_close     = ''
            im_dialog_mode  = ''
            im_no_update    = ''
            im_commit_work  = 'X'
            im_display_only = iv_uv_change
          IMPORTING
            ex_return       = lt_ex_return
          CHANGING
            ch_doc_object   = lo_doc_object.
        IF iv_uv_change = abap_false.
          COMMIT WORK.
*        break struck-f.
          " lo_doc_object->update( ).
        ENDIF.
        IF lines( lt_ex_return ) = 1.
          CALL METHOD cl_inv_inv_remadv_doc=>suppress_subprocess
            EXPORTING
              im_doc_number   = <ls_out>-int_inv_doc_no
              im_no_close     = ''
              im_dialog_mode  = 'X'
              im_no_update    = ''
              im_commit_work  = ''
              im_display_only = 'X'
            IMPORTING
              ex_return       = lt_ex_return
            CHANGING
              ch_doc_object   = lo_doc_object.

        ENDIF.
        lv_count = 1.
      ELSE.

        DELETE FROM tinv_inv_prcsupp WHERE int_inv_doc_no = <ls_out>-int_inv_doc_no.

        SELECT * FROM tinv_inv_prcsupp INTO TABLE lt_tinv_inv_prcsupp WHERE int_inv_doc_no = lv_doc_no1.

        LOOP AT lt_tinv_inv_prcsupp  INTO ls_tinv_inv_prcsupp.

          ls_tinv_inv_prcsupp-int_inv_doc_no = <ls_out>-int_inv_doc_no.
          SELECT SINGLE int_inv_no FROM tinv_inv_doc INTO ls_tinv_inv_prcsupp-int_inv_no
           WHERE int_inv_doc_no = <ls_out>-int_inv_doc_no.
          "ls_tinv_inv_prcsupp-int_inv_no = lr_out->int_inv_no.

          INSERT INTO tinv_inv_prcsupp VALUES ls_tinv_inv_prcsupp.
          COMMIT WORK.
          " MESSAGE i602(mc)
        ENDLOOP.

      ENDIF.
    ENDLOOP.


  ENDMETHOD.


  METHOD  process_user_command.
    DATA: lv_answer TYPE char1.
    DATA  lv_nr_rows_selected TYPE i.
*    DATA: lv_index TYPE i.
    " eigene Userkommandos behandeln
    " BREAK-POINT.
    IF mt_filter IS INITIAL.
      sender->get_filtered_entries( IMPORTING et_filtered_entries = mt_filter ).
    ENDIF.
*    IF lv_index IS INITIAL.
*      sender->get_selected_rows( IMPORTING et_index_rows =  lv_index  ).
*      IF lv_index IS NOT INITIAL.
*        READ TABLE mrt_out_table ASSIGNING FIELD-SYMBOL(<ls_out>) INDEX lv_index.
*      ENDIF.
*    ENDIF.

    " Ridvan mochete gerne dass Zeilenmarkierungen auch eine gueltige Auswahl fuer Aktionen darstellen
    " deswegen werden diese in die Sel-Spalte zusaetzlich uebernommen
    sender->get_selected_rows(
      IMPORTING
        et_index_rows = DATA(lt_sel_index_rows)     " Indizes der selektierten Zeilen
        et_row_no     = DATA(lt_sel_no_rows)     " Numerische IDs der selektierten Zeilen
    ).
    IF lt_sel_index_rows IS NOT INITIAL.
      me->choose( lt_sel_index_rows ).
      sender->refresh_table_display( ).
    ENDIF.
    lv_nr_rows_selected = REDUCE #( INIT x1 = 0  FOR ls IN mrt_out_table->* WHERE (  sel = 'X' )  NEXT x1 = x1 + 1  ).

    CASE e_ucomm.
*# aus Invoice-Manager
*# zu aktualisieren
      WHEN 'ZEFRESH'.
        me->/adz/if_inv_salv_table_evt_hlr~mo_controller->refresh_data(  ).
        sender->refresh_table_display( ).
*# zu stornieren
      WHEN 'CANCEL'.
        CHECK NOT me->check_sperre( ).
        me->add_text( 'stornieren' ).
        me->ucom_canc( ).
        me->/adz/if_inv_salv_table_evt_hlr~mo_controller->refresh_data(  ).
        sender->refresh_table_display( ).
      WHEN '&ALL_U'.
        me->mark_all( ).
        sender->refresh_table_display( ).
      WHEN '&SAL_U'.
        me->unmark_all( ).
        sender->refresh_table_display( ).
      WHEN 'REFERENZ'.
        me->show_references( ).
      WHEN 'UEBER'.
        me->process( iv_uv_change = abap_false ).
      WHEN 'ANZ'.
        me->process( iv_uv_change = abap_true ).
      WHEN 'ENET'.
        me->get_enet_price_anl( ).
      WHEN 'PRUEFUNGEN'.
        me->process( iv_uv_change = abap_false ).
      WHEN 'SIM_VP'.
        me->simulate_vp( iv_but_flag = abap_true ).
      WHEN 'SPERREN'.
        me->add_text( ' sperren ' ).
        me->sperren( ).
        me->/adz/if_inv_salv_table_evt_hlr~mo_controller->refresh_data(  ).
        sender->refresh_table_display( ).
      WHEN 'BEENDEN'.
        CHECK NOT me->check_sperre( ).
        me->ucom_beenden( ).
      WHEN 'LOG'.
        me->ucom_log( ).
      WHEN 'STATISTIK'.
*# GN: noch nötig??
      WHEN 'CHECK'.
        " Auswahl wird schon vor CASE immer uebernommen
*        sender->get_selected_rows(
*          IMPORTING
*            et_index_rows = DATA(lt_sel_index_rows)     " Indizes der selektierten Zeilen
*            et_row_no     = DATA(lt_sel_no_rows)     " Numerische IDs der selektierten Zeilen
*        ).
*        me->choose( lt_sel_index_rows ).
        sender->refresh_table_display( ).

      WHEN 'STAT_RESET'.
        CHECK NOT me->check_sperre( ).
        me->add_text( 'zurücksetzen' ).
        me->reset_status( iv_reset_flag = abap_true ).
        me->/adz/if_inv_salv_table_evt_hlr~mo_controller->refresh_data(  ).
        sender->refresh_table_display( ).
      WHEN 'RELEASE'.
        CHECK NOT me->check_sperre( ).
        me->add_text( 'Freigeben' ).
        me->reset_status( iv_release_flag = abap_true ).
        me->/adz/if_inv_salv_table_evt_hlr~mo_controller->refresh_data(  ).
        sender->refresh_table_display( ).
*# Prozessieren
      WHEN 'PROCESS'.
        CHECK me->check_select( lv_nr_rows_selected ) EQ abap_true.
        me->execute_process( ).
        me->/adz/if_inv_salv_table_evt_hlr~mo_controller->refresh_data(  ).
        sender->refresh_table_display( ).
*# zu Reklamieren
      WHEN 'COMPLAIN'.
        CHECK NOT me->check_sperre( ).
        me->add_text( 'reklamieren' ).
        me->ucom_compl( ).
        me->/adz/if_inv_salv_table_evt_hlr~mo_controller->refresh_data(  ).
        sender->refresh_table_display( ).
*# Aus REMADV----------------------------------------------------------------------------------------------------------------------

      WHEN 'CHANGE_VER'.           "was ist das?

*        ASSIGN COMPONENT 'VTREF' OF STRUCTURE <wa_out> TO <value>.
*        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*          EXPORTING
*            input  = <value>
*          IMPORTING
*            output = h_vertrag.
*
**    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
**      EXPORTING
**        input  = h_vertrag
**      IMPORTING
**        output = h_vertrag.
*
*        SET PARAMETER ID 'VTG' FIELD h_vertrag.
*        CALL TRANSACTION 'ES21' AND SKIP FIRST SCREEN.

*# Kontostand
      WHEN 'BALANCE'.
        CHECK me->check_single_select( lv_nr_rows_selected ) EQ abap_true.
        me->balance( ).
*# Wechselbeleg anzeigen
      WHEN 'SWTMON'.
        CHECK me->check_single_select( lv_nr_rows_selected ) EQ abap_true.
        me->show_swt( ).
*# Datex-Mon
      WHEN 'DATEX'.
        CHECK me->check_single_select( lv_nr_rows_selected ) EQ abap_true.
        LOOP AT mrt_out_table->* ASSIGNING FIELD-SYMBOL(<ls_out>) WHERE sel = 'X'.
          me->show_tasks(
            EXPORTING
              iv_ext_ident       = <ls_out>-ext_ui
              iv_end_date        = <ls_out>-end_date
              iv_invperiod_start = <ls_out>-invperiod_start
              iv_invperiod_end   = <ls_out>-invperiod_end   ).
        ENDLOOP.
*# Pdocmon
      WHEN 'PDOCMON'.
        CHECK me->check_single_select( lv_nr_rows_selected ) EQ abap_true.
        me->show_pdoc( iv_option = CONV #( e_ucomm ) ).
*# CIC anzeigen
      WHEN 'CIC' .
        CHECK me->check_single_select( lv_nr_rows_selected ) EQ abap_true.
        me->show_cic( ).
*# NNE stornieren
      WHEN 'CANCEL_NN'.
        CHECK me->check_select( lv_nr_rows_selected ) EQ abap_true.
        me->cancel_nne( ).
        sender->refresh_table_display( ).
*# MEMI stornieren
      WHEN 'CANCEL_M'.
        CHECK me->check_select( lv_nr_rows_selected ) EQ abap_true.
        me->cancel_memi( ).
        sender->refresh_table_display( ).
*# MGV stornieren
      WHEN 'CANCEL_MGV'.
        CHECK me->check_select( lv_nr_rows_selected ) EQ abap_true.
        me->cancel_mgv( ).
        sender->refresh_table_display( ).
      WHEN 'CANCEL_AP'.
        CHECK me->check_select( lv_nr_rows_selected ) EQ abap_true.
        me->cancel_ap( ).
        sender->refresh_table_display( ).
      WHEN 'CANCEL_A'.
        CHECK me->check_select( lv_nr_rows_selected ) EQ abap_true.
        me->cancel_abr( ).
        sender->refresh_table_display( ).
      WHEN 'COMDIS_PR'.
        CHECK me->check_single_select(  EXPORTING iv_nr_select_lines = lv_nr_rows_selected
              iv_text  = 'COMDIS Verarbeitung derzeit nur einzelne '
              iv_text2 = 'Reklamationen möglich' )  EQ abap_true.
        me->abl_per_comdis( ).
*# Remadv beenden
      WHEN 'BEENDEN' OR 'BEENDEN_M'.
        CHECK me->check_select( lv_nr_rows_selected ) EQ abap_true.
        me->beende_remadv( ).
      WHEN 'SM_SEL_DAT'.
        CHECK me->check_select( lv_nr_rows_selected ) EQ abap_true.
        me->send_mail( ).
      WHEN 'BEMERKUNG'.
        CHECK me->check_select( lv_nr_rows_selected ) EQ abap_true.
        me->write_note( ).
      WHEN 'LOCK'.
        CHECK me->check_select( lv_nr_rows_selected ) EQ abap_true.
        me->dun_lock( EXPORTING iv_lockr   = ms_selscreen-pa_lockr
                                iv_fdate   = ms_selscreen-pa_fdate
                                iv_tdate   = ms_selscreen-pa_tdate ).
        sender->refresh_table_display( ).

      WHEN 'UNLOCK'.
        CHECK me->check_select( lv_nr_rows_selected ) EQ abap_true.
        me->dun_unlock( ms_selscreen-p_invtp ).
        sender->refresh_table_display( ).

*# Erledigt setzen.
      WHEN 'ERLEDIGEN'.
        CHECK me->check_select( lv_nr_rows_selected ) EQ abap_true.
        me->set_status_erl( ).
        sender->refresh_table_display( ).
      WHEN 'DELVNOTEMAN'.
        CHECK me->check_select( lv_nr_rows_selected ) EQ abap_true.
        call_delvnoteman(  ).
      WHEN OTHERS.
        " Standardfkt aufrufen
        DATA(lv_ucomm) = e_ucomm.
        sender->set_function_code( CHANGING c_ucomm = lv_ucomm  ).  " Funktionscode

    ENDCASE.
  ENDMETHOD.


  METHOD refresh_data.
*# GN: Data_Selektion!!!!!!!

*        clear: it_out, wa_out.
*        perform Data_selektion
    cv_refresh_flag = abap_true.

  ENDMETHOD.


  METHOD reset_status.
    DATA: lo_inv_doc      TYPE REF TO cl_inv_inv_remadv_doc,
          lt_return       TYPE bapirettab,
          ls_return       TYPE bapiret2,
          ls_tinv_inv_doc TYPE tinv_inv_doc,
          lv_proc_type    TYPE inv_process_type,
          lv_error        TYPE inv_kennzx,
          lv_done         TYPE char1.

    CLEAR lv_done.
    LOOP AT mrt_out_table->* ASSIGNING FIELD-SYMBOL(<ls_out>) WHERE sel = abap_true.

      READ TABLE mt_filter WITH KEY table_line = sy-tabix TRANSPORTING NO FIELDS.

      CHECK sy-subrc NE 0.

*   INT_INVOICE_NO muss gefüllt sein.
      CHECK <ls_out>-int_inv_doc_no IS NOT INITIAL.

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
        EXIT.
      ENDIF.

      CLEAR lt_return[].

      CALL METHOD lo_inv_doc->change_document_status
        EXPORTING
          im_set_to_reset            = iv_reset_flag
          im_set_to_released         = iv_release_flag
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
          MESSAGE ID ls_return-id TYPE 'I' NUMBER ls_return-number
            WITH ls_return-message_v1 ls_return-message_v2 ls_return-message_v3 ls_return-message_v4  DISPLAY LIKE ls_return-type.
          RETURN.
        ENDIF.
        EXIT.
      ENDIF.

      SELECT SINGLE * FROM tinv_inv_doc INTO ls_tinv_inv_doc
         WHERE int_inv_doc_no = <ls_out>-int_inv_doc_no.

      <ls_out>-inv_doc_status = ls_tinv_inv_doc-inv_doc_status.

* Dequeue document
      CALL FUNCTION 'DEQUEUE_E_TINV_INV_DOC'
        EXPORTING
          mode_tinv_inv_doc = 'X'
          mandt             = sy-mandt
          int_inv_doc_no    = <ls_out>-int_inv_doc_no.

    ENDLOOP.

  ENDMETHOD.


  METHOD set_status_erl.
    LOOP AT mrt_out_table->* ASSIGNING FIELD-SYMBOL(<ls_out>) WHERE sel = 'X'.

*        wa_out-line_state = '@0V@'.

* read data from database /idexge/rej_noti
      SELECT SINGLE * FROM /idexge/rej_noti INTO @DATA(ls_rej_noti)
       WHERE int_inv_doc_no  = @<ls_out>-int_inv_doc_no
         AND int_inv_line_no = @<ls_out>-int_inv_line_no.
      IF sy-subrc <> 0.
        ls_rej_noti-int_inv_doc_no  = <ls_out>-int_inv_doc_no.
        ls_rej_noti-int_inv_line_no = <ls_out>-int_inv_line_no.
        ls_rej_noti-stat_remk       = <ls_out>-line_state.
        INSERT INTO /idexge/rej_noti VALUES ls_rej_noti.
      ELSE.
        ls_rej_noti-stat_remk = '@0V@'.
        MODIFY /idexge/rej_noti FROM ls_rej_noti.
      ENDIF.
      IF sy-subrc = 0.
        COMMIT WORK.
      ELSE.
        <ls_out>-line_state = icon_led_red.
      ENDIF.

      CLEAR <ls_out>-sel.

    ENDLOOP.
*    ELSEIF p_invtp = 2.
*      LOOP AT it_out_memi INTO wa_out_memi WHERE sel = 'X'.
*        lv_b_selected = 'X'.
*        wa_out_memi-line_state = '@0V@' .
** read data from database /idexge/rej_noti
*        SELECT SINGLE * FROM /idexge/rej_noti INTO wa_rej_noti
*           WHERE int_inv_doc_no = wa_out_memi-int_inv_doc_no
*           AND   int_inv_line_no = wa_out_memi-int_inv_line_no.              "Nuss 09.2018
*
*        IF sy-subrc <> 0.
*          wa_rej_noti-int_inv_doc_no = wa_out_memi-int_inv_doc_no.
*          wa_rej_noti-int_inv_line_no = wa_out_memi-int_inv_line_no.
*          wa_rej_noti-stat_remk = wa_out_memi-line_state.
*          INSERT INTO /idexge/rej_noti VALUES wa_rej_noti.
*        ELSE.
*          wa_rej_noti-stat_remk = wa_out_memi-line_state.
*          MODIFY /idexge/rej_noti FROM wa_rej_noti.
*        ENDIF.
*
*        IF sy-subrc = 0.
*          COMMIT WORK.
*        ELSE.
*          wa_out_memi-line_state = icon_led_red.
*        ENDIF.
*
*        MODIFY it_out_memi FROM wa_out_memi.
*      ENDLOOP.
*    ELSEIF p_invtp = 3.
*      LOOP AT it_out_mgv INTO wa_out_mgv WHERE sel = 'X'.
*        lv_b_selected = 'X'.
*        wa_out_mgv-line_state = '@0V@' .
** read data from database /idexge/rej_noti
*        SELECT SINGLE * FROM /idexge/rej_noti INTO wa_rej_noti
*           WHERE int_inv_doc_no = wa_out_mgv-int_inv_doc_no
*           AND   int_inv_line_no = wa_out_mgv-int_inv_line_no.
*
*        IF sy-subrc <> 0.
*          wa_rej_noti-int_inv_doc_no = wa_out_mgv-int_inv_doc_no.
*          wa_rej_noti-int_inv_line_no = wa_out_mgv-int_inv_line_no.
*          wa_rej_noti-stat_remk = wa_out_mgv-line_state.
*          INSERT INTO /idexge/rej_noti VALUES wa_rej_noti.
*        ELSE.
*          wa_rej_noti-stat_remk = wa_out_mgv-line_state.
*          MODIFY /idexge/rej_noti FROM wa_rej_noti.
*        ENDIF.
*
*        IF sy-subrc = 0.
*          COMMIT WORK.
*        ELSE.
*          wa_out_mgv-line_state = icon_led_red.
*        ENDIF.
*
*        MODIFY it_out_mgv FROM wa_out_mgv.
*      ENDLOOP.
** --> Nuss 09.2018
*    ELSEIF p_invtp = 4.
*      LOOP AT it_out_msb INTO wa_out_msb WHERE sel = 'X'.
*        lv_b_selected = 'X'.
*        wa_out_msb-line_state = '@0V@' .
** read data from database /idexge/rej_noti
*        SELECT SINGLE * FROM /idexge/rej_noti INTO wa_rej_noti
*           WHERE int_inv_doc_no = wa_out_msb-int_inv_doc_no
*           AND   int_inv_line_no = wa_out_msb-int_inv_line_no.
*
*        IF sy-subrc <> 0.
*          wa_rej_noti-int_inv_doc_no = wa_out_msb-int_inv_doc_no.
*          wa_rej_noti-int_inv_line_no = wa_out_msb-int_inv_line_no.
*          wa_rej_noti-stat_remk = wa_out_msb-line_state.
*          INSERT INTO /idexge/rej_noti VALUES wa_rej_noti.
*        ELSE.
*          wa_rej_noti-stat_remk = wa_out_msb-line_state.
*          MODIFY /idexge/rej_noti FROM wa_rej_noti.
*        ENDIF.
*
*        IF sy-subrc = 0.
*          COMMIT WORK.
*        ELSE.
*          wa_out_msb-line_state = icon_led_red.
*        ENDIF.
*
*        MODIFY it_out_msb FROM wa_out_msb.
*      ENDLOOP.

  ENDMETHOD.


  METHOD show_cic.

    DATA: ls_bdc      TYPE bdcdata,
          lv_tcode    TYPE sy-tcode,
          lv_taskname TYPE char30.

    READ TABLE mrt_out_table->* ASSIGNING FIELD-SYMBOL(<ls_out>) WITH KEY sel = abap_true.


    DATA(lv_screen_no) = /adz/cl_inv_remadv_helper=>get_cic_frame_4_user( ).
    IF lv_screen_no IS INITIAL.
      MESSAGE i000(e4) WITH 'Für den Aufruf des CIC wurde keine Transaktion hinterlegt.' DISPLAY LIKE 'E'.
    ENDIF.

    DATA(lt_bdc) = /adz/cl_inv_customizing_data=>get_batch_data( EXPORTING iv_option = 'CIC').

    /adz/cl_inv_customizing_data=>determine_values( EXPORTING it_bdc   = lt_bdc
                                                              iv_data  = <ls_out>
                                                    RECEIVING rt_bdc  = lt_bdc ).
*   Besonderheit beim CIC. Hier kann das Dynpro nicht durch das Customizing
*   vorgegeben werden, da es indiv. dem User durch das Profil zugeordnet wird.
    ls_bdc-program  = 'SAPLCIC0'.
    ls_bdc-dynpro   = lv_screen_no.
    ls_bdc-dynbegin = 'X'.
    APPEND ls_bdc TO lt_bdc.

    SORT lt_bdc BY program DESCENDING fnam ASCENDING.

    DATA(lv_transaction) = /adz/cl_inv_customizing_data=>get_config_value( EXPORTING iv_option   = 'CIC'
                                                                                       iv_category = 'BDC_END'
                                                                                       iv_field    = 'TRANSACTION'
                                                                                       iv_id       = '1' ).
    IF lv_transaction IS INITIAL.
      MESSAGE e000(e4) WITH 'Für den Aufruf des CIC wurde keine Transaktion hinterlegt.'.
      EXIT.
    ENDIF.

    lv_tcode = lv_transaction.

    CONCATENATE 'CIC' sy-datum sy-uzeit lv_tcode INTO lv_taskname.

*    call function 'CALL_CIC_TRANSACTION'
    CALL FUNCTION '/ADZ/FI_NEG_REAMADV_CIC'
      STARTING NEW TASK lv_taskname
      EXPORTING
        tcode            = lv_tcode
        skipfirst        = 'X'
      TABLES
        in_bdcdata       = lt_bdc
*       out_messtab      = lt_messtab
      EXCEPTIONS
        no_authorization = 1
        OTHERS           = 2.
    IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ENDMETHOD.


  METHOD show_error.

    DATA: BEGIN OF ls_errorline,
            text(120) TYPE c,
          END OF ls_errorline.
    DATA: lt_errorline LIKE STANDARD TABLE OF ls_errorline.

    DATA: ls_fehler TYPE /adz/inv_s_fehler,
          lt_fehler TYPE /adz/inv_t_fehler,
          ls_t100   TYPE t100.
    DATA: ls_fieldcat TYPE slis_fieldcat_alv,
          lt_fieldcat TYPE slis_t_fieldcat_alv.

*# Warum select? Wofür?
    SELECT * FROM tinv_inv_line_b INTO @DATA(ls_inv_line_b)
     WHERE int_inv_doc_no EQ @iv_doc_no
       AND ( line_type EQ '0005' OR
             line_type EQ '0013' ).

*         Fehlertext ermitteln
      me->get_errormessage( EXPORTING iv_doc_no = iv_doc_no
                            CHANGING  ct_error  = lt_fehler ).

*         Mehrfacheinträge aus der Fehlertabelle löscben
      IF lt_fehler IS NOT INITIAL.
        SORT lt_fehler.
        DELETE ADJACENT DUPLICATES FROM lt_fehler COMPARING ALL FIELDS.
      ENDIF.

    ENDSELECT.

    LOOP AT lt_fehler INTO ls_fehler.
      SELECT * FROM t100 INTO ls_t100
        WHERE sprsl = 'D'
          AND arbgb = ls_fehler-msgid
          AND msgnr = ls_fehler-msgno.
        ls_errorline-text = ls_t100-text.
        REPLACE ALL OCCURRENCES OF '&1' IN ls_errorline-text WITH ls_fehler-msgv1.
        REPLACE ALL OCCURRENCES OF '&2' IN ls_errorline-text WITH ls_fehler-msgv2.
        REPLACE ALL OCCURRENCES OF '&3' IN ls_errorline-text WITH ls_fehler-msgv3.
        REPLACE ALL OCCURRENCES OF '&4' IN ls_errorline-text WITH ls_fehler-msgv4.
        APPEND ls_errorline TO lt_errorline.
        CLEAR ls_errorline.
      ENDSELECT.
    ENDLOOP.

    ls_fieldcat-fieldname = 'TEXT'.
    ls_fieldcat-tabname = 'IT_Errorline'.
    ls_fieldcat-seltext_s = 'Fehler'.
    ls_fieldcat-seltext_m = 'Fehlermeldung'.
    ls_fieldcat-seltext_l = 'Fehlermeldung'.
    ls_fieldcat-outputlen = '120'.
    ls_fieldcat-hotspot = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        it_fieldcat           = lt_fieldcat
        i_screen_start_column = 10
        i_screen_start_line   = 10
        i_screen_end_column   = 80
        i_screen_end_line     = 20
      TABLES
        t_outtab              = lt_errorline
      EXCEPTIONS
        program_error         = 1
        OTHERS                = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE sy-msgty.
    ENDIF.


  ENDMETHOD.


  METHOD show_ext_invoice.

    DATA: BEGIN OF ls_ext_out,
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
          END OF ls_ext_out.
    DATA: lt_ext_out LIKE TABLE OF ls_ext_out.

    DATA: ls_fieldcat TYPE slis_fieldcat_alv,
          lt_fieldcat TYPE slis_t_fieldcat_alv.

    SELECT * FROM tinv_inv_doc INTO @DATA(ls_inv_doc_a)
      WHERE ext_invoice_no = @iv_ext_invoice_no.

      SELECT * FROM tinv_inv_line_b INTO @DATA(ls_inv_line_b)
        WHERE int_inv_doc_no = @ls_inv_doc_a-int_inv_doc_no
        AND product_id NE @space.

        SELECT SINGLE * FROM edereg_sidpro INTO @DATA(ls_sidpro)
          WHERE product_id = @ls_inv_line_b-product_id.

        SELECT SINGLE * FROM edereg_sidprot INTO @DATA(ls_sidprot)
          WHERE int_serident = @ls_sidpro-int_serident
            AND product_id_type = @ls_sidpro-product_id_type
            AND spras = @sy-langu.

        MOVE-CORRESPONDING ls_inv_line_b TO ls_ext_out.
        MOVE ls_sidprot-text TO ls_ext_out-text.
        APPEND ls_ext_out TO lt_ext_out.
        CLEAR ls_ext_out.

      ENDSELECT.
*
    ENDSELECT.

* Kennung
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'PRODUCT_ID'.
    ls_fieldcat-tabname = 'IT_EXT_OUT'.
    ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
    APPEND ls_fieldcat TO lt_fieldcat.

*  Text
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'TEXT'.
    ls_fieldcat-tabname = 'IT_EXT_OUT'.
    ls_fieldcat-ref_tabname = 'EDEREG_SIDPROT'.
    APPEND ls_fieldcat TO lt_fieldcat.

* AB
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'DATE_FROM'.
    ls_fieldcat-tabname = 'IT_EXT_OUT'.
    ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
    APPEND ls_fieldcat TO lt_fieldcat.

* BIS
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'DATE_TO'.
    ls_fieldcat-tabname = 'IT_EXT_OUT'.
    ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
    APPEND ls_fieldcat TO lt_fieldcat.

*  Menge
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'QUANTITY'.
    ls_fieldcat-tabname = 'IT_EXT_OUT'.
    ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
    APPEND ls_fieldcat TO lt_fieldcat.

* Mengeneinheit
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'UNIT'.
    ls_fieldcat-tabname = 'IT_EXT_OUT'.
    ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
    APPEND ls_fieldcat TO lt_fieldcat.

* Preis
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'PRICE'.
    ls_fieldcat-tabname = 'IT_EXT_OUT'.
    ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
    APPEND ls_fieldcat TO lt_fieldcat.

* Maßeinheit Preis
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'PRICE_UNIT'.
    ls_fieldcat-tabname = 'IT_EXT_OUT'.
    ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
    APPEND ls_fieldcat TO lt_fieldcat.

* Nettobetrag
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'ETRW_NET'.
    ls_fieldcat-tabname = 'IT_EXT_OUT'.
    ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
    APPEND ls_fieldcat TO lt_fieldcat.

* Steuerbetrag
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'TAXBW'.
    ls_fieldcat-tabname = 'IT_EXT_OUT'.
    ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
    APPEND ls_fieldcat TO lt_fieldcat.

* Fälligkeitsdatum
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'DATE_OF_PAYMENT'.
    ls_fieldcat-tabname = 'IT_EXT_OUT'.
    ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
    APPEND ls_fieldcat TO lt_fieldcat.

* Mehrwertsteuerkennzeichen
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'MWSKZ'.
    ls_fieldcat-tabname = 'IT_EXT_OUT'.
    ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
    APPEND ls_fieldcat TO lt_fieldcat.

* Mehrwertsteuersatz
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'STRPZ'.
    ls_fieldcat-tabname = 'IT_EXT_OUT'.
    ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
    APPEND ls_fieldcat TO lt_fieldcat.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        it_fieldcat           = lt_fieldcat
        i_screen_start_column = 10
        i_screen_start_line   = 10
        i_screen_end_column   = 200
        i_screen_end_line     = 20
      TABLES
        t_outtab              = lt_ext_out
      EXCEPTIONS
        program_error         = 1
        OTHERS                = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE sy-msgty.
    ENDIF.

  ENDMETHOD.


  METHOD show_references.

    DATA : lo_remadv_doc TYPE REF TO cl_inv_inv_remadv_doc,
           lv_anz        TYPE i.

    LOOP AT mrt_out_table->* ASSIGNING FIELD-SYMBOL(<ls_out>) WHERE sel = abap_true.
      lv_anz = lv_anz + 1.
    ENDLOOP.
    IF lv_anz <> 1.
      MESSAGE 'Bitte genau eine Rechnung auswählen.' TYPE 'I' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

    READ TABLE mrt_out_table->* ASSIGNING <ls_out> WITH KEY sel = abap_true.

    FREE lo_remadv_doc.
    CREATE OBJECT lo_remadv_doc
      EXPORTING
        im_work_mode  = cl_inv_inv_remadv_doc=>co_wmode_display
        im_doc_number = <ls_out>-int_inv_doc_no
      EXCEPTIONS
        OTHERS        = 1.

    CALL FUNCTION 'INV_DISPLAY_REFERENCE'
      EXPORTING
        im_no_dialog              = ''
        imt_tinv_inv_docref       = lo_remadv_doc->doc_docref[]
      EXCEPTIONS
        no_ref_to_display         = 1
        no_ref_function           = 2
        error_in_display_function = 3
        OTHERS                    = 4.

  ENDMETHOD.


  METHOD show_tasks.

    DATA: lt_sel_dexstatus  TYPE isu00_range_tab,
          lt_sel_exi_ui     TYPE isu00_range_tab,
          lt_sel_int_ui     TYPE isu00_range_tab,
          lt_sel_dexduedate TYPE isu00_range_tab,
          lt_sel_dexduetime TYPE isu00_range_tab.

    SELECT SINGLE int_ui
             FROM euitrans
             INTO @DATA(lv_int_ui)
            WHERE ext_ui = @iv_ext_ident
              AND dateto GE @iv_end_date.
    CHECK lv_int_ui IS NOT INITIAL.

    lt_sel_exi_ui = VALUE #( ( sign = 'I' option = 'EQ' low = iv_ext_ident ) ).
    lt_sel_int_ui = VALUE #( ( sign = 'I' option = 'EQ' low = lv_int_ui ) ).
    lt_sel_dexstatus = VALUE #( sign = 'I' option = 'EQ' ( low = 'CANCELLED')
                                                         ( low = 'ERROR')
                                                         ( low = 'IN_WORK')
                                                         ( low = 'OBSOLETE')
                                                         ( low = 'OK')
                                                         ( low = 'PLANNED')
                                                         ( low = 'UNKNOW')
                                                         ( low = 'USER_CANC')
                                                         ( low = ' ')         ).
    IF iv_invperiod_start IS INITIAL OR iv_invperiod_end IS INITIAL.
      lt_sel_dexduedate = VALUE #( ( sign = 'I' option = 'BT' low = ( sy-datum - 100 ) high = sy-datum ) ).
    ELSE.
      lt_sel_dexduedate = VALUE #( ( sign = 'I' option = 'BT' low = iv_invperiod_start high = iv_invperiod_end ) ).
    ENDIF.
    lt_sel_dexduetime = VALUE #( ( sign = 'I' option = 'BT' low = '000000' high = '235959' ) ).

    CALL METHOD cl_isu_datex_monitoring=>display_tasks
      EXPORTING
        x_wmode           = '2'
        x_max_records     = '100'
*       xt_dextaskid      =
*       xt_sel_idocnum    =
*       xt_sel_dexidocstat     =
        xt_sel_int_ui     = lt_sel_int_ui
*       xt_sel_dexproc    =
        xt_sel_ext_ui     = lt_sel_exi_ui
*       xt_sel_dexservprov     =
*       xt_sel_dexservprovself =
        xt_sel_dexstatus  = lt_sel_dexstatus
        xt_sel_dexduedate = lt_sel_dexduedate
        xt_sel_dexduetime = lt_sel_dexduetime
*       x_no_corrected    = ''
*       x_no_change       =
*       x_sort_by_duedate = ''
*       x_display_empty   = 'X'
*       x_grid_container  =
*       xt_sel_dexexttaskid    =
*       xt_sel_dexmsgconfstate =
*       x_limited_by_duedate   =
*       x_popup_read_archive   = 'X'
      EXCEPTIONS
        not_found         = 1
        system_error      = 2
        OTHERS            = 3.
    IF sy-subrc <> 0.
*      Implement suitable error handling here
    ENDIF.
  ENDMETHOD.


  METHOD simulate_vp.

    DATA lv_inv_no TYPE tinv_inv_head-int_inv_no.
    DATA lt_inv_no TYPE TABLE OF tinv_inv_head-int_inv_no.

    IF iv_but_flag = 'X'.
      LOOP AT mrt_out_table->* ASSIGNING FIELD-SYMBOL(<ls_out>) WHERE sel = abap_true.
        SELECT SINGLE int_inv_no INTO lv_inv_no FROM tinv_inv_doc WHERE int_inv_doc_no = <ls_out>-int_inv_doc_no.
        APPEND lv_inv_no TO lt_inv_no.
      ENDLOOP.
    ELSE.
      lv_inv_no = iv_inv_no.
      APPEND lv_inv_no TO lt_inv_no.
    ENDIF.

    CHECK lt_inv_no IS NOT INITIAL.

    CALL FUNCTION '/ADZ/INV_MANAGER_SIM_CHECK'
      EXPORTING
        it_inv_doc_no = lt_inv_no
*       iv_check_proc =
*   IMPORTING
*       Y_RETURN      =
*       Y_STATUS      =
*       Y_CHANGED     =
      .

    LOOP AT mrt_out_table->* ASSIGNING <ls_out> WHERE sel = abap_true.
      SELECT * FROM /adz/invtext  WHERE int_inv_doc_nr = @<ls_out>-int_inv_doc_no INTO TABLE @DATA(lt_text).
      SORT lt_text BY datum zeit DESCENDING.
      READ TABLE lt_text INTO DATA(ls_invtxt) INDEX 1.
      <ls_out>-text_bem = ls_invtxt-text.
      IF sy-subrc = 0.
        IF ls_invtxt-action = 'EDM_OK'.
          <ls_out>-text_vorhanden = icon_led_green.
        ELSEIF ls_invtxt-action = 'EDM_REK'.
          <ls_out>-text_vorhanden = icon_led_red.
        ELSEIF ls_invtxt-action = 'EDM_BEAR'.
          <ls_out>-text_vorhanden = icon_led_yellow.
        ELSEIF ls_invtxt-action = 'EDM_STD'.
          <ls_out>-text_vorhanden = icon_led_inactive.
        ELSE.
          IF <ls_out>-text_vorhanden IS INITIAL.
            <ls_out>-text_vorhanden = 'X'.
          ENDIF.
        ENDIF.
      ENDIF.
      CLEAR: ls_invtxt, lt_text.
    ENDLOOP.
    IF sy-subrc <> 0.
      "assign mrt_out_table->*[ int_inv_doc_no = lv_inv_no ] to <ls_out>.
      READ TABLE mrt_out_table->* ASSIGNING <ls_out> WITH KEY int_inv_doc_no = lv_inv_no.
      CHECK sy-subrc EQ 0.
      SELECT * FROM /adz/invtext  WHERE int_inv_doc_nr = @<ls_out>-int_inv_doc_no INTO TABLE @lt_text.
      CHECK sy-subrc EQ 0.
      SORT lt_text BY datum zeit DESCENDING.
      READ TABLE lt_text INTO ls_invtxt INDEX 1.
      IF sy-subrc = 0.
        <ls_out>-text_bem = ls_invtxt-text.
        IF ls_invtxt-action = 'EDM_OK'.
          <ls_out>-text_vorhanden = icon_led_green.
        ELSEIF ls_invtxt-action = 'EDM_REK'.
          <ls_out>-text_vorhanden = icon_led_red.
        ELSEIF ls_invtxt-action = 'EDM_BEAR'.
          <ls_out>-text_vorhanden = icon_led_yellow.
        ELSEIF ls_invtxt-action = 'EDM_STD'.
          <ls_out>-text_vorhanden = icon_led_inactive.
        ELSE.
          IF <ls_out>-text_vorhanden IS INITIAL.
            <ls_out>-text_vorhanden = 'X'.
          ENDIF.
        ENDIF.
      ENDIF.
      CLEAR: ls_invtxt, lt_text.

    ENDIF.

  ENDMETHOD.


  METHOD sperren.

    DATA: lv_count    TYPE i,
          lv_sperr    TYPE c,
          ls_invsperr TYPE /adz/invsperr,
          lv_entsperr TYPE c.

    LOOP AT mrt_out_table->* ASSIGNING FIELD-SYMBOL(<ls_out>) WHERE sel = abap_true.

      SELECT COUNT(*) FROM /adz/invsperr WHERE int_inv_doc_nr = <ls_out>-int_inv_doc_no.
      IF sy-subrc = 0.
        lv_entsperr = 'X'.
      ELSE.
        lv_sperr = 'X'.
      ENDIF.
      lv_count = lv_count + 1.

    ENDLOOP.

*  break struck-f.

    IF lv_sperr = 'X' AND lv_entsperr = 'X'.
      MESSAGE 'Bitte entweder gesperrte oder freie Belege selektieren.' TYPE 'I' DISPLAY LIKE 'E'.
      RETURN.
    ELSEIF lv_sperr = ' ' AND lv_entsperr = 'X'.
      LOOP AT mrt_out_table->* ASSIGNING <ls_out> WHERE sel = abap_true.
        DELETE FROM /adz/invsperr WHERE  int_inv_doc_nr = <ls_out>-int_inv_doc_no.
      ENDLOOP.
      MESSAGE lv_count && 'Belege entsperrt.' TYPE 'I'.
    ELSEIF lv_sperr = 'X' AND lv_entsperr = ' '.
      LOOP AT mrt_out_table->* ASSIGNING <ls_out> WHERE sel = abap_true.
        ls_invsperr-int_inv_doc_nr = <ls_out>-int_inv_doc_no.
        ls_invsperr-datum = sy-datum.
        ls_invsperr-username = sy-uname.
        INSERT INTO /adz/invsperr  VALUES ls_invsperr.
      ENDLOOP.
      MESSAGE lv_count && 'Belege gesperrt.' TYPE 'I'.
    ENDIF.


  ENDMETHOD.


  METHOD ucom_beenden.

    DATA: lo_inv_doc TYPE REF TO cl_inv_inv_remadv_doc.
    DATA: lv_answer TYPE char1.
    DATA: lt_return TYPE bapirettab.

* Sicherheitsabfrage
    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
      EXPORTING
        defaultoption = 'Y'
        textline1     = TEXT-100
        textline2     = TEXT-101
        titel         = TEXT-t01
      IMPORTING
        answer        = lv_answer.

    IF NOT lv_answer CA 'jJyY'.
      EXIT.
    ENDIF.

    me->add_text( 'Beenden' ).
**   Zeile muss Markiert sein
    LOOP AT mrt_out_table->* ASSIGNING FIELD-SYMBOL(<ls_out>) WHERE sel = abap_true.
      READ TABLE mt_filter WITH KEY table_line = sy-tabix TRANSPORTING NO FIELDS.

      CHECK sy-subrc NE 0.
*   INT_INVOICE_NO muss gefüllt sein.
*   Bei mehreren Fehlern ist nur die erste Zeile zum Beleg gefüllt.
      CHECK <ls_out>-int_inv_doc_no IS NOT INITIAL.

      CREATE OBJECT lo_inv_doc
        EXPORTING
          im_work_mode  = cl_inv_inv_remadv_doc=>co_wmode_change
          im_doc_number = <ls_out>-int_inv_doc_no
        EXCEPTIONS
          OTHERS        = 1.

      IF sy-subrc <> 0.
        IF lo_inv_doc IS NOT INITIAL.
          CALL METHOD lo_inv_doc->close.
          EXIT.
        ENDIF.
      ENDIF.
      IF lo_inv_doc IS NOT INITIAL.
        CLEAR lt_return[].
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

        IF lt_return IS INITIAL.
          <ls_out>-inv_doc_status = '08'.              "Beendet
        ENDIF.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD ucom_canc.

    DATA: lv_canc_reason  TYPE inv_cancel_rsn,
          lo_inv_doc      TYPE REF TO cl_inv_inv_remadv_doc,
          lv_answer       TYPE char1,lt_return TYPE bapirettab,
          lv_tinv_inv_doc TYPE tinv_inv_doc.

    lv_canc_reason = me->get_popup_canc_reason( ).

    CHECK lv_canc_reason IS NOT INITIAL.

    LOOP AT mrt_out_table->* ASSIGNING FIELD-SYMBOL(<ls_out>) WHERE sel = abap_true.

*# Guochen:  ToDo: Werte von mrt_filter besorgen!!!!!!!
      READ TABLE mt_filter WITH KEY table_line = sy-tabix TRANSPORTING NO FIELDS.
      CHECK sy-subrc NE 0.

*   INT_INVOICE_NO muss gefüllt sein.
*   Bei mehreren Fehlern ist nur die erste Zeile zum Beleg gefüllt.
      CHECK <ls_out>-int_inv_doc_no IS NOT INITIAL.

      CREATE OBJECT lo_inv_doc
        EXPORTING
          im_work_mode  = cl_inv_inv_remadv_doc=>co_wmode_change
          im_doc_number = <ls_out>-int_inv_doc_no
        EXCEPTIONS
          OTHERS        = 1.

      IF sy-subrc <> 0.
        IF lo_inv_doc IS NOT INITIAL.
          CALL METHOD lo_inv_doc->close.
          EXIT.
        ENDIF.
      ENDIF.

      CLEAR lt_return[].
      CALL METHOD lo_inv_doc->change_document_status
        EXPORTING
          im_set_to_reset            = ' '
          im_set_to_released         = ' '
          im_set_to_finished         = ' '
          im_set_to_to_be_complained = ' '
          im_reason_for_complain     = ' '
          im_set_to_to_be_reversed   = 'X'
          im_reversal_rsn            = lv_canc_reason
          im_commit_work             = 'X'
          im_automatic_change        = ' '
          im_create_reversal_doc     = ' '
        IMPORTING
          ex_return                  = lt_return.

      SELECT SINGLE * FROM tinv_inv_doc INTO lv_tinv_inv_doc
         WHERE int_inv_doc_no = <ls_out>-int_inv_doc_no.

      <ls_out>-inv_doc_status = lv_tinv_inv_doc-inv_doc_status.

    ENDLOOP.

  ENDMETHOD.


  METHOD ucom_compl.

    DATA: lv_compl_reason TYPE rstgr,
          lo_inv_doc      TYPE REF TO cl_inv_inv_remadv_doc,
          lv_answer       TYPE char1,
          lt_return       TYPE bapirettab,
          ls_return       TYPE bapiret2,
          ls_adj_rsn      TYPE tinv_c_adj_rsn,
          ls_tinv_inv_doc TYPE tinv_inv_doc,
          lv_proc_type    TYPE inv_process_type,
          lv_error        TYPE inv_kennzx,
          lv_ok           TYPE ok,
          lv_done         TYPE char1,
          lv_forall       TYPE xfeld,
          lv_not_found    TYPE i,
          lv_reklambelnr  TYPE char3 VALUE '04',
          lv_reklamdoctyp TYPE char3 VALUE '008',
          ls_rekvor       TYPE /adz/rek_vors,
          lv_rej_noti     type /idexge/rej_noti.

    DATA: lt_fehler TYPE /adz/inv_t_fehler.

    SELECT SINGLE value FROM /adz/inv_cust INTO lv_reklambelnr   WHERE report = 'GLOBAL' AND field = 'REKLAMBELART'.
    SELECT SINGLE value FROM /adz/inv_cust INTO lv_reklamdoctyp  WHERE report = 'GLOBAL' AND field = 'REKLAMDOCTYP'.

    LOOP AT mrt_out_table->* ASSIGNING FIELD-SYMBOL(<ls_out>) WHERE sel IS NOT INITIAL.

      READ TABLE mt_filter WITH KEY table_line = sy-tabix TRANSPORTING NO FIELDS.
      CHECK sy-subrc NE 0.

      SELECT SINGLE * FROM /adz/rek_vors INTO ls_rekvor WHERE inv_doc_no = <ls_out>-int_inv_doc_no.
      IF sy-subrc = 0.

        DATA: ls_rej_noti TYPE /idexge/rej_noti.
        ls_rej_noti-int_inv_doc_no = <ls_out>-int_inv_doc_no.
        ls_rej_noti-int_inv_line_no = 1.
        CALL FUNCTION '/ADZ/REKLAMATIONSVORSCHLAG'
          EXPORTING
            nodisp         = lv_forall
            int_inv_doc_no = ls_rej_noti-int_inv_doc_no
            rstgr          = ls_rekvor-rstgr
            rstgv          = ls_rekvor-vorschlag
          IMPORTING
            accpt          = lv_ok
            text           = ls_rej_noti-free_text1
            forall         = lv_forall.

        INSERT INTO /idexge/rej_noti VALUES ls_rej_noti.
        IF sy-subrc <> 0.
          UPDATE /idexge/rej_noti FROM ls_rej_noti.
        ENDIF.
        COMMIT WORK.
        IF lv_ok = 'ACCPT'.
          lv_compl_reason = ls_rekvor-rstgr.
*   INT_INVOICE_NO muss gefüllt sein.
          CHECK <ls_out>-int_inv_doc_no IS NOT INITIAL.

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
            EXIT.
          ENDIF.

          CLEAR lt_return[].
          CALL METHOD lo_inv_doc->change_document_status
            EXPORTING
              im_set_to_reset            = ' '
              im_set_to_released         = ' '
              im_set_to_finished         = ' '
              im_set_to_to_be_complained = 'X'
              im_reason_for_complain     = lv_compl_reason
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
              MESSAGE ID ls_return-id TYPE 'I' NUMBER ls_return-number
                WITH ls_return-message_v1 ls_return-message_v2 ls_return-message_v3 ls_return-message_v4  DISPLAY LIKE ls_return-type.
              RETURN.
            ENDIF.
            EXIT.
          ENDIF.

          SELECT SINGLE * FROM tinv_inv_doc INTO ls_tinv_inv_doc
             WHERE int_inv_doc_no = <ls_out>-int_inv_doc_no.

          <ls_out>-inv_doc_status = ls_tinv_inv_doc-inv_doc_status.

* Dequeue document
          CALL FUNCTION 'DEQUEUE_E_TINV_INV_DOC'
            EXPORTING
              mode_tinv_inv_doc = 'X'
              mandt             = sy-mandt
              int_inv_doc_no    = <ls_out>-int_inv_doc_no.

          COMMIT WORK.

          CALL METHOD cl_inv_inv_remadv_doc=>process_document
            EXPORTING
              im_doc_number          = <ls_out>-int_inv_doc_no
            IMPORTING
              ex_return              = lt_return[]
              ex_exit_process_type   = lv_proc_type
              ex_proc_error_occurred = lv_error
            EXCEPTIONS
              OTHERS                 = 1.

          SELECT SINGLE * FROM tinv_inv_doc INTO ls_tinv_inv_doc
             WHERE int_inv_doc_no = <ls_out>-int_inv_doc_no.

          <ls_out>-inv_doc_status = ls_tinv_inv_doc-inv_doc_status.

          IF lt_return[] IS NOT INITIAL.
            CLEAR lt_fehler.
            me->get_errormessage( EXPORTING iv_doc_no = <ls_out>-int_inv_doc_no
                                  CHANGING ct_error = lt_fehler ).

**      Mehrfacheinträge aus der Fehlertabelle löscben
            IF lt_fehler IS NOT INITIAL.
              SORT lt_fehler.
              DELETE ADJACENT DUPLICATES FROM lt_fehler COMPARING ALL FIELDS.
            ENDIF.

            IF lt_fehler IS NOT INITIAL.
              READ TABLE lt_fehler INTO DATA(ls_fehler) INDEX 1.
              SELECT SINGLE * FROM t100 INTO @DATA(ls_t100)
                WHERE sprsl = 'D'
                  AND arbgb = @ls_fehler-msgid
                  AND msgnr = @ls_fehler-msgno.
              <ls_out>-fehler = ls_t100-text.
              REPLACE ALL OCCURRENCES OF '&1' IN <ls_out>-fehler WITH ls_fehler-msgv1.
              REPLACE ALL OCCURRENCES OF '&2' IN <ls_out>-fehler WITH ls_fehler-msgv2.
              REPLACE ALL OCCURRENCES OF '&3' IN <ls_out>-fehler WITH ls_fehler-msgv3.
              REPLACE ALL OCCURRENCES OF '&4' IN <ls_out>-fehler WITH ls_fehler-msgv4.
              <ls_out>-lights = '1'.
            ENDIF.
          ENDIF.

          IF ls_tinv_inv_doc-inv_doc_status = lv_reklambelnr.  "reklamiert.

            DATA: ls_inv_doc_a TYPE tinv_inv_doc.
            SELECT * FROM tinv_inv_doc INTO ls_inv_doc_a
              WHERE ext_invoice_no = <ls_out>-ext_invoice_no
               AND doc_type = lv_reklamdoctyp.
              EXIT.
            ENDSELECT.

            DATA: ls_inv_line_a TYPE tinv_inv_line_a.
            SELECT * FROM tinv_inv_line_a INTO ls_inv_line_a
              WHERE int_inv_doc_no = ls_inv_doc_a-int_inv_doc_no
              AND  rstgr NE space.

* ´  Langtext falls vorhanden übertragen
              IF mrs_noti->* IS NOT INITIAL.
                MOVE <ls_out>-int_inv_doc_no TO mrs_noti->*-int_inv_doc_no.
                MOVE ls_inv_line_a-int_inv_line_no TO mrs_noti->*-int_inv_line_no.
                MODIFY /idexge/rej_noti FROM mrs_noti->*.
                CLEAR mrs_noti->*-int_inv_doc_no.
                CLEAR mrs_noti->*-int_inv_line_no.
              ENDIF.

*     WA_OUT füllen
              SELECT SINGLE date_of_receipt FROM tinv_inv_head INTO <ls_out>-remdate
               WHERE int_inv_no = ls_inv_doc_a-int_inv_no.

              MOVE ls_inv_line_a-int_inv_doc_no  TO <ls_out>-remadv.
              MOVE ls_inv_line_a-rstgr           TO <ls_out>-rstgr.
              MOVE mrs_noti->*-free_text1        TO <ls_out>-free_text1.

            ENDSELECT.

          ENDIF.

        ELSE.
          lv_not_found = lv_not_found + 1.
        ENDIF.
      ELSE.
        lv_not_found = lv_not_found + 1.
      ENDIF.
    ENDLOOP.

    IF lv_not_found <> 0.
* Reklamationsgrund holen

      me->get_popup_comp_reason( CHANGING cv_compl_reason = lv_compl_reason ).
      CHECK lv_compl_reason IS NOT INITIAL.

* Reklamationsgrund 28 (Sonstiges) --> Popup für Freitext
      CALL METHOD /idexge/cl_inv_adddata=>read_table_adj_rsn
        EXPORTING
          iv_rstgr       = lv_compl_reason
        IMPORTING
          es_adj_rsn     = ls_adj_rsn
        EXCEPTIONS
          error_occurred = 1
          OTHERS         = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE sy-msgty.
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
          MESSAGE ID sy-msgid TYPE 'I'  NUMBER sy-msgno
                     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE sy-msgty.
        ENDIF.
      ENDIF.

    ELSE.
      lv_compl_reason = ls_rekvor-rstgr.
    ENDIF.
    CLEAR lv_done.
    LOOP AT mrt_out_table->* ASSIGNING <ls_out>
       WHERE sel IS NOT INITIAL AND inv_doc_status <> lv_reklambelnr.  ".


      READ TABLE mt_filter WITH KEY table_line = sy-tabix TRANSPORTING NO FIELDS.
      CHECK sy-subrc NE 0.

*   INT_INVOICE_NO muss gefüllt sein.
      CHECK <ls_out>-int_inv_doc_no IS NOT INITIAL.

      IF mrs_noti->* IS NOT INITIAL.

        MOVE <ls_out>-int_inv_doc_no TO mrs_noti->*-int_inv_doc_no.

        SELECT SINGLE * FROM /idexge/rej_noti INTO lv_rej_noti  WHERE int_inv_doc_no = <ls_out>-int_inv_doc_no.
        IF sy-subrc NE 0.
          INSERT /idexge/rej_noti FROM mrs_noti->*.
        ELSE.
          UPDATE /idexge/rej_noti FROM mrs_noti->*.
        ENDIF.
        CLEAR mrs_noti->*-int_inv_doc_no.

      ENDIF.

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
        EXIT.
      ENDIF.

      CLEAR lt_return[].
      CALL METHOD lo_inv_doc->change_document_status
        EXPORTING
          im_set_to_reset            = ' '
          im_set_to_released         = ' '
          im_set_to_finished         = ' '
          im_set_to_to_be_complained = 'X'
          im_reason_for_complain     = lv_compl_reason
          im_set_to_to_be_reversed   = ' '
          im_reversal_rsn            = ' '
          im_commit_work             = 'X'
          im_automatic_change        = ' '
          im_create_reversal_doc     = ' '
        IMPORTING
          ex_return                  = lt_return.


      IF mrs_noti->* IS INITIAL .
        SELECT SINGLE * FROM /idexge/rej_noti INTO mrs_noti->* WHERE int_inv_doc_no = <ls_out>-int_inv_doc_no.
      ENDIF.

      IF lt_return IS NOT INITIAL.
        READ TABLE lt_return INTO ls_return
           WITH KEY type = 'E'.
        IF sy-subrc = 0.
          MESSAGE ID ls_return-id TYPE 'I'  NUMBER ls_return-number
            WITH ls_return-message_v1 ls_return-message_v2 ls_return-message_v3 ls_return-message_v4 DISPLAY LIKE ls_return-type.
          RETURN.
        ENDIF.
        EXIT.
      ENDIF.

      SELECT SINGLE * FROM tinv_inv_doc INTO ls_tinv_inv_doc
         WHERE int_inv_doc_no = <ls_out>-int_inv_doc_no.

      <ls_out>-inv_doc_status = ls_tinv_inv_doc-inv_doc_status.

* Dequeue document
      CALL FUNCTION 'DEQUEUE_E_TINV_INV_DOC'
        EXPORTING
          mode_tinv_inv_doc = 'X'
          mandt             = sy-mandt
          int_inv_doc_no    = <ls_out>-int_inv_doc_no.

      COMMIT  WORK.

      CALL METHOD cl_inv_inv_remadv_doc=>process_document
        EXPORTING
          im_doc_number          = <ls_out>-int_inv_doc_no
        IMPORTING
          ex_return              = lt_return[]
          ex_exit_process_type   = lv_proc_type
          ex_proc_error_occurred = lv_error
        EXCEPTIONS
          OTHERS                 = 1.

      SELECT SINGLE * FROM tinv_inv_doc INTO ls_tinv_inv_doc
         WHERE int_inv_doc_no = <ls_out>-int_inv_doc_no.

      <ls_out>-inv_doc_status = ls_tinv_inv_doc-inv_doc_status.

      IF lt_return[] IS NOT INITIAL.
        CLEAR lt_fehler.
        me->get_errormessage( EXPORTING iv_doc_no = <ls_out>-int_inv_doc_no
                              CHANGING  ct_error  = lt_fehler ).

**      Mehrfacheinträge aus der Fehlertabelle löscben
        IF lt_fehler IS NOT INITIAL.
          SORT lt_fehler.
          DELETE ADJACENT DUPLICATES FROM lt_fehler COMPARING ALL FIELDS.
        ENDIF.

        IF lt_fehler IS NOT INITIAL.
          READ TABLE lt_fehler INTO ls_fehler INDEX 1.
          SELECT SINGLE * FROM t100 INTO ls_t100
            WHERE sprsl = 'D'
              AND arbgb = ls_fehler-msgid
              AND msgnr = ls_fehler-msgno.
          <ls_out>-fehler = ls_t100-text.
          REPLACE ALL OCCURRENCES OF '&1' IN <ls_out>-fehler WITH ls_fehler-msgv1.
          REPLACE ALL OCCURRENCES OF '&2' IN <ls_out>-fehler WITH ls_fehler-msgv2.
          REPLACE ALL OCCURRENCES OF '&3' IN <ls_out>-fehler WITH ls_fehler-msgv3.
          REPLACE ALL OCCURRENCES OF '&4' IN <ls_out>-fehler WITH ls_fehler-msgv4.
          <ls_out>-lights = '1'.
        ENDIF.
      ENDIF.

      SELECT SINGLE value FROM /adz/inv_cust INTO lv_reklambelnr   WHERE report = 'GLOBAL' AND field = 'REKLAMBELART'.
      SELECT SINGLE value FROM /adz/inv_cust INTO lv_reklamdoctyp  WHERE report = 'GLOBAL' AND field = 'REKLAMDOCTYP'.

      IF ls_tinv_inv_doc-inv_doc_status = lv_reklambelnr.  "reklamiert.

        SELECT * FROM tinv_inv_doc INTO ls_inv_doc_a
          WHERE ext_invoice_no = <ls_out>-ext_invoice_no
           AND doc_type = lv_reklamdoctyp.
          EXIT.
        ENDSELECT.

        SELECT * FROM tinv_inv_line_a INTO ls_inv_line_a
          WHERE int_inv_doc_no = ls_inv_doc_a-int_inv_doc_no
          AND  rstgr NE space.

* ´  Langtext falls vorhanden übertragen
          IF mrs_noti->* IS NOT INITIAL.
            MOVE <ls_out>-int_inv_doc_no TO mrs_noti->*-int_inv_doc_no.
            MOVE ls_inv_line_a-int_inv_line_no TO mrs_noti->*-int_inv_line_no.
            MODIFY /idexge/rej_noti FROM mrs_noti->*.
            CLEAR mrs_noti->*-int_inv_doc_no.
            CLEAR mrs_noti->*-int_inv_line_no.
          ENDIF.

*     WA_OUT füllen
          SELECT SINGLE date_of_receipt FROM tinv_inv_head INTO <ls_out>-remdate
           WHERE int_inv_no = ls_inv_doc_a-int_inv_no.

          MOVE ls_inv_line_a-int_inv_doc_no  TO <ls_out>-remadv.
          MOVE ls_inv_line_a-rstgr           TO <ls_out>-rstgr.
          MOVE mrs_noti->*-free_text1        TO <ls_out>-free_text1.

        ENDSELECT.

      ENDIF.


    ENDLOOP.
  ENDMETHOD.


  METHOD ucom_log.

    DATA: lt_inv_inv_dockey TYPE ttinv_inv_dockey,
          lv_inv_inv_dockey TYPE inv_inv_dockey,
          lv_count          TYPE i.

    LOOP AT mrt_out_table->* ASSIGNING FIELD-SYMBOL(<ls_out>) WHERE sel = abap_true.
      ADD 1 TO lv_count.
    ENDLOOP.

    IF lv_count GT 1.
      MESSAGE i000(e4) WITH 'Bitte nur ein Feld markieren' DISPLAY LIKE 'E'.
      RETURN.
    ELSEIF lv_count = 0.
      MESSAGE i000(e4) WITH 'Bitte ein Feld markieren'  DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

    READ TABLE mrt_out_table->* ASSIGNING <ls_out> WITH KEY sel = abap_true.

    lv_inv_inv_dockey-int_inv_doc_no = <ls_out>-int_inv_doc_no.
    APPEND lv_inv_inv_dockey TO lt_inv_inv_dockey.

    CALL METHOD cl_inv_inv_remadv_log=>cl_display_log
      EXPORTING
        im_int_inv_doc_no_tab = lt_inv_inv_dockey
*       im_int_inv_no         = wa_out-int_inv_no
*       im_show_all_data      = SPACE
*       im_close_log          = 'X'
*       im_amodal             = SPACE
*       im_doc                =
*       im_sel_lines          =
*  CHANGING
*       ch_log                =
      EXCEPTIONS
        no_log_exists         = 1
        internal_error        = 2
        no_authority          = 3
        OTHERS                = 4.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'I'  NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE sy-msgty.
    ENDIF.

  ENDMETHOD.


  METHOD ucom_proc.

    DATA: lt_return       TYPE bapirettab,
          lv_proc_type    TYPE inv_process_type,
          lv_error        TYPE inv_kennzx,
          lv_b_selected   TYPE boolean,
          lt_inv_collect  TYPE tinv_int_inv_doc_no,
          lt_ergebnis     TYPE /adz/manager_proz_collect_t,
          ls_tinv_inv_doc TYPE tinv_inv_doc,
          lt_inv_proc     TYPE /adz/inv_t_out_reklamon.

    mv_akt_proz = 0.
    LOOP AT mrt_out_table->*  ASSIGNING FIELD-SYMBOL(<ls_out>).

      READ TABLE mt_filter WITH KEY table_line = sy-tabix TRANSPORTING NO FIELDS.
      CHECK sy-subrc NE 0.

*   Zeile muss Markiert sein
      CHECK <ls_out>-sel = 'X'.

      lv_b_selected = abap_true.

*   INT_INVOICE_NO muss gefüllt sein.
*   Bei mehreren Fehlern ist nur die erste Zeile zum Beleg gefüllt.
      CHECK <ls_out>-int_inv_doc_no IS NOT INITIAL.
*   Status 'Neu' oder 'Zu Bearbeiten'
      IF <ls_out>-invoice_status NE '01' AND
        <ls_out>-invoice_status NE '02' AND
        <ls_out>-invoice_status NE '03'.           "Nuss 08.2012
        CONTINUE.
      ENDIF.
      APPEND <ls_out> TO lt_inv_proc.
    ENDLOOP.

*  break struck-f.
    IF lines( lt_inv_proc ) <= 10.
      LOOP AT lt_inv_proc ASSIGNING FIELD-SYMBOL(<ls_inv_proc>).
        "invoice zum Prozessieren sammeln
        READ TABLE mrt_out_table->* ASSIGNING <ls_out> WITH KEY int_inv_doc_no = <ls_inv_proc>-int_inv_doc_no.
        CLEAR lt_return[].
        CLEAR: lv_proc_type, lv_error.

        CALL METHOD cl_inv_inv_remadv_doc=>process_document
          EXPORTING
            im_doc_number          = <ls_out>-int_inv_doc_no
          IMPORTING
            ex_return              = lt_return[]
            ex_exit_process_type   = lv_proc_type
            ex_proc_error_occurred = lv_error
          EXCEPTIONS
            OTHERS                 = 1.

        SELECT SINGLE * FROM tinv_inv_doc INTO ls_tinv_inv_doc
           WHERE int_inv_doc_no = <ls_out>-int_inv_doc_no.

        <ls_out>-inv_doc_status = ls_tinv_inv_doc-inv_doc_status.

        DATA: lt_fehler TYPE /adz/inv_t_fehler,
              ls_fehler TYPE /adz/inv_s_fehler.

        IF lt_return[] IS NOT INITIAL.
          CLEAR lt_fehler.

          me->get_errormessage( EXPORTING iv_doc_no = <ls_out>-int_inv_doc_no
                                CHANGING  ct_error  = lt_fehler ).

**      Mehrfacheinträge aus der Fehlertabelle löscben
          IF lt_fehler IS NOT INITIAL.
            SORT lt_fehler.
            DELETE ADJACENT DUPLICATES FROM lt_fehler COMPARING ALL FIELDS.
          ENDIF.

          IF lt_fehler IS NOT INITIAL.
            READ TABLE lt_fehler INTO ls_fehler INDEX 1.
            SELECT * FROM t100 INTO @DATA(ls_t100)
              WHERE sprsl = 'D'
                AND arbgb = @ls_fehler-msgid
                AND msgnr = @ls_fehler-msgno.
              <ls_out>-fehler = ls_t100-text.
              REPLACE ALL OCCURRENCES OF '&1' IN <ls_out>-fehler WITH ls_fehler-msgv1.
              REPLACE ALL OCCURRENCES OF '&2' IN <ls_out>-fehler WITH ls_fehler-msgv2.
              REPLACE ALL OCCURRENCES OF '&3' IN <ls_out>-fehler WITH ls_fehler-msgv3.
              REPLACE ALL OCCURRENCES OF '&4' IN <ls_out>-fehler WITH ls_fehler-msgv4.
              <ls_out>-lights = '1'.
            ENDSELECT.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ELSE.
      DATA lv_tabix TYPE char20.
      LOOP AT lt_inv_proc ASSIGNING <ls_inv_proc>.
        lv_tabix = sy-tabix.
        APPEND <ls_inv_proc>-int_inv_doc_no TO lt_inv_collect.
        IF lines( lt_inv_collect ) = 10.
          ADD 1 TO mv_akt_proz.
*# GV_max_proz aus Customizing !!!!!!!!!!!
          WAIT UNTIL mv_akt_proz < 100 . "gv_max_proz.
          CALL FUNCTION '/ADZ/INV_MANAGER_PROCESS_TA'
            STARTING NEW TASK lv_tabix
            DESTINATION IN GROUP DEFAULT
            CALLING ende_proc_task ON END OF TASK
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
        ADD 1 TO mv_akt_proz.
*# GV_max_proz aus Customizing !!!!!!!!!!!
        WAIT UNTIL mv_akt_proz < 100 . "gv_max_proz.
        CALL FUNCTION '/ADZ/INV_MANAGER_PROCESS_TA'
          STARTING NEW TASK 'Ende'
          DESTINATION IN GROUP DEFAULT
          CALLING ende_proc_task ON END OF TASK
*          PERFORMING ende_task ON END OF TASK   ToDO!!!!!
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

  ENDMETHOD.


  METHOD unmark_all.
    DATA(lrt_out) = get_outable(  ).
    FIELD-SYMBOLS <lt_out> TYPE ANY TABLE.
    ASSIGN lrt_out->* TO <lt_out>.
    LOOP AT <lt_out> ASSIGNING FIELD-SYMBOL(<ls_out>).
      ASSIGN COMPONENT 'SEL' OF STRUCTURE <ls_out> TO FIELD-SYMBOL(<lv_value>).
      IF sy-subrc EQ 0.
        <lv_value> = ''.
      ENDIF.
      ASSIGN COMPONENT 'XSELP' OF STRUCTURE <ls_out> TO <lv_value>.
      IF sy-subrc EQ 0.
        <lv_value> = ''.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
