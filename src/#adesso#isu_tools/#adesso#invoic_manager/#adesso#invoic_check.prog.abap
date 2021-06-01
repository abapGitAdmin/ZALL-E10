*&---------------------------------------------------------------------*
*& Report  ZAD_INVOIC_CHECK
*&---------------------------------------------------------------------*

REPORT  /adesso/invoic_check.

INCLUDE /adesso/invoic_checktop.
*INCLUDE zad_invoic_checktop.
INCLUDE /adesso/invoic_selscr.
*INCLUDE zad_invoic_selscr.
INCLUDE /adesso/invoic_class.
*INCLUDE zad_invoic_class.

DATA gv_cust TYPE /adesso/inv_cust.
*************************************************************************
INITIALIZATION.
  PERFORM init_custom_fields.
  PERFORM alv_variant_init.

*-----------------------------------------------------------------------
* START-OF-SELECTION
*-----------------------------------------------------------------------
START-OF-SELECTION.

  PERFORM select_data.
  PERFORM mult_invoice.

*-----------------------------------------------------------------------
* END-OF-SELECTION
*-----------------------------------------------------------------------
END-OF-SELECTION.

  SORT t_alvout BY aklasse tariftyp ableinh anlage invperiod_start.
  PERFORM alv_layout_build USING gs_layout.
  PERFORM alv_fieldcat_main USING gt_fieldcat_main[].
  PERFORM alv_output_main.



*-----------------------------------------------------------------------
* FORM ALV_OUTPUT_MAIN
*-----------------------------------------------------------------------
FORM alv_output_main.

  g_repid = sy-repid.
  g_structure = '/ADESSO/INVOIC_CHECK_ALV'.
  g_default  = 'X'.
  g_save     = 'A'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = g_repid
      i_callback_pf_status_set = g_status_main
      i_callback_user_command  = g_ucom_main
      is_layout                = gs_layout
      it_fieldcat              = gt_fieldcat_main[]
      i_default                = g_default
      i_save                   = g_save
      is_variant               = gs_variant
      it_events                = gt_events
    TABLES
      t_outtab                 = t_alvout.

ENDFORM.                    "OALV_OUTPUT_MAIN

*&---------------------------------------------------------------------*
*&      Form  ALV_FIELDCAT_MAIN
*&---------------------------------------------------------------------*
FORM alv_fieldcat_main USING ft_fieldcat TYPE slis_t_fieldcat_alv..

  DATA: ls_fieldcat TYPE slis_fieldcat_alv.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = '/ADESSO/INVOIC_CHECK_ALV'
    CHANGING
      ct_fieldcat            = ft_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  LOOP AT ft_fieldcat INTO ls_fieldcat.

    CASE ls_fieldcat-fieldname.

      WHEN 'SEL'.
        ls_fieldcat-fieldname = 'SEL'.
        ls_fieldcat-tabname = 'T_ALVOUT'.
        ls_fieldcat-edit = 'X'.
        ls_fieldcat-input = 'X'.
        ls_fieldcat-checkbox = 'X'.
        ls_fieldcat-seltext_s = 'Sel.'.
        ls_fieldcat-seltext_m = 'Selektion'.
        ls_fieldcat-seltext_l = 'Selektion'.
        MODIFY ft_fieldcat FROM ls_fieldcat INDEX sy-tabix.

      WHEN 'ANLAGE'.
        ls_fieldcat-hotspot = 'X'.
        MODIFY ft_fieldcat FROM ls_fieldcat INDEX sy-tabix.

      WHEN 'EXT_UI'.
        ls_fieldcat-hotspot = 'X'.
        MODIFY ft_fieldcat FROM ls_fieldcat INDEX sy-tabix.

      WHEN 'INT_INV_NO'.
        ls_fieldcat-hotspot = 'X'.
        MODIFY ft_fieldcat FROM ls_fieldcat INDEX sy-tabix.

      WHEN 'INT_SENDER'.
        ls_fieldcat-hotspot = 'X'.
        MODIFY ft_fieldcat FROM ls_fieldcat INDEX sy-tabix.

      WHEN 'INV_STATE_ICON'.
        ls_fieldcat-seltext_s = 'AvisStatus'.
        ls_fieldcat-seltext_m = 'Avis Status'.
        MODIFY ft_fieldcat FROM ls_fieldcat INDEX sy-tabix.

      WHEN 'DOC_STATE_ICON'.
        ls_fieldcat-seltext_s = 'BelStatus'.
        ls_fieldcat-seltext_m = 'Beleg Status'.
        MODIFY ft_fieldcat FROM ls_fieldcat INDEX sy-tabix.

      WHEN 'BELNR'.
        ls_fieldcat-hotspot = 'X'.
        MODIFY ft_fieldcat FROM ls_fieldcat INDEX sy-tabix.

      WHEN 'REMADV'.
        ls_fieldcat-seltext_s = 'REMADV-Nr.'.
        ls_fieldcat-seltext_m = 'REMADV-Nr'.
        ls_fieldcat-hotspot = 'X'.
        MODIFY ft_fieldcat FROM ls_fieldcat INDEX sy-tabix.

      WHEN 'REMDATE'.
        ls_fieldcat-seltext_s = 'REMADV-Dat.'.
        ls_fieldcat-seltext_m = 'REMADV-Datum'.
        MODIFY ft_fieldcat FROM ls_fieldcat INDEX sy-tabix.

      WHEN 'RSTGR'.
        ls_fieldcat-ref_tabname = 'TINV_INV_LINE_A'.
        MODIFY ft_fieldcat FROM ls_fieldcat INDEX sy-tabix.

      WHEN 'MULT_INV'.
        ls_fieldcat-seltext_s = 'MultINV'.
        ls_fieldcat-seltext_m = 'Mehere INVOIC'.
        MODIFY ft_fieldcat FROM ls_fieldcat INDEX sy-tabix.

      WHEN 'EXT_INVOICE_NO'.
        ls_fieldcat-hotspot = 'X'.
        MODIFY ft_fieldcat FROM ls_fieldcat INDEX sy-tabix.

      WHEN 'MAIL_STAT'.
        ls_fieldcat-seltext_s = 'Mail'.
        ls_fieldcat-seltext_m = 'Mail'.
        ls_fieldcat-hotspot = 'X'.
        MODIFY ft_fieldcat FROM ls_fieldcat INDEX sy-tabix.

      WHEN 'FREE_TEXT'.
        ls_fieldcat-seltext_s = 'Notiz'.
        ls_fieldcat-seltext_m = 'Notiz'.
        ls_fieldcat-seltext_l = 'Notiz'.
        ls_fieldcat-hotspot = 'X'.
        MODIFY ft_fieldcat FROM ls_fieldcat INDEX sy-tabix.

    ENDCASE.

  ENDLOOP.

ENDFORM.                    " ALV_FIELDCAT_MAIN

*&---------------------------------------------------------------------*
*&      Form  SELECT_DATA
*&---------------------------------------------------------------------*
FORM select_data .

  DATA:  lx_header TYPE thead.
  DATA:  tx_lines TYPE STANDARD TABLE OF tline.

  DATA: help_line TYPE tline.
  DATA: help_ext_no TYPE inv_ext_invoice_no.

* Selektion der Anlagen
  SELECT  ha~anlage
          ha~bis
          ha~ab
          ha~aklasse
          ha~tariftyp
          ha~ableinh
          ui~int_ui
          ui~ext_ui
    INTO CORRESPONDING FIELDS OF TABLE t_eanl
    FROM  eanlh AS ha
    INNER JOIN euiinstln AS ei
    ON    ei~anlage = ha~anlage AND
          ei~dateto = ha~bis
    INNER JOIN euitrans AS ui
    ON    ui~int_ui = ei~int_ui
    WHERE ha~aklasse  IN so_abrkl
    AND   ha~tariftyp IN so_tatyp
    AND   ha~ableinh  IN so_ablei
    AND   ha~anlage   IN so_anlag
    AND   ha~bis      =  '99991231'.


  LOOP AT t_eanl ASSIGNING <t_eanl>.

    REFRESH t_docs.

*Lesen der INVOIC zur Anlage
    SELECT  dh~int_inv_no
            dh~invoice_status
            dh~int_receiver
            dh~int_sender
            dh~created_on
            dd~doc_type
            dd~inv_doc_status
            dd~ext_invoice_no
            dd~inv_bulk_ref
            dd~invperiod_start
            dd~invperiod_end
            dd~date_of_payment
            dd~int_partner
            dd~inv_cancel_rsn
            dd~inv_cancel_doc
            dd~rstgr
            dt~bukrs
            dt~thbln_ext
            dt~thprd
            dt~line_content
            dt~vkont
            dt~waers
            dt~betrw
            dt~taxbw
            dt~mwskz
      INTO CORRESPONDING FIELDS OF TABLE t_docs
      FROM tinv_inv_extid AS de
      INNER JOIN tinv_inv_head AS dh
      ON    dh~int_inv_no = de~int_inv_no
      INNER JOIN tinv_inv_doc AS dd
      ON    dd~int_inv_doc_no = de~int_inv_doc_no
      LEFT OUTER JOIN tinv_inv_transf AS dt
      ON    dt~int_inv_doc_no = de~int_inv_doc_no
      WHERE de~ext_ident = <t_eanl>-ext_ui
      AND   dh~int_sender IN s_send
      AND   dh~invoice_status IN s_insta
      AND   dh~date_of_receipt IN s_dtrec
      AND   dh~int_receiver IN s_rece
      AND   dh~invoice_type = '001'
      AND   dd~int_inv_doc_no IN s_intido
      AND   dd~inv_doc_status IN s_idosta
      AND   dd~invperiod_start GE pa_datab
      AND   dd~invperiod_start LE pa_datbi.

    DELETE t_docs
           WHERE line_content NE '04'
           AND   line_content NE ''.

*  Es wurden INVOICES gefunden
    IF t_docs[] IS NOT INITIAL.
      LOOP AT t_docs INTO s_docs.
        CLEAR s_alvout.
        MOVE-CORRESPONDING <t_eanl> TO s_alvout.
        MOVE-CORRESPONDING s_docs   TO s_alvout.
**      Status-Icon in Abhängigkeit vom Avis-Status
        CASE s_docs-invoice_status.
          WHEN '01'.
            s_alvout-inv_state_icon = icon_led_inactive.
          WHEN '02'.
            s_alvout-inv_state_icon = icon_led_yellow.
          WHEN '03'.
            s_alvout-inv_state_icon = icon_led_green.
        ENDCASE.
*       Status-Icon für Belegstatus
        CASE s_docs-inv_doc_status.
          WHEN '01'.
            s_alvout-doc_state_icon = icon_led_inactive.
          WHEN '02'.
            s_alvout-doc_state_icon = icon_led_yellow.
          WHEN '03'.
            s_alvout-doc_state_icon = icon_led_yellow.
          WHEN '04'.
            s_alvout-doc_state_icon = icon_reject.
          WHEN '05'.
            s_alvout-doc_state_icon = icon_led_yellow.
          WHEN '06'.
            s_alvout-doc_state_icon = icon_led_yellow.
          WHEN '07'.
            s_alvout-doc_state_icon = icon_led_yellow.
          WHEN '08'.
            s_alvout-doc_state_icon = icon_incomplete.
          WHEN '09'.
            s_alvout-doc_state_icon = icon_led_red.
          WHEN '10'.
            s_alvout-doc_state_icon = icon_led_yellow.
          WHEN '11'.
            s_alvout-doc_state_icon = icon_reject.
          WHEN '12'.
            s_alvout-doc_state_icon = icon_storno.
          WHEN '13'.
            s_alvout-doc_state_icon = icon_checked.
          WHEN '14'.
            s_alvout-doc_state_icon = icon_storno.
          WHEN '15'.
            s_alvout-doc_state_icon = icon_led_inactive.
          WHEN '16'.
            s_alvout-doc_state_icon = icon_booking_stop.
          WHEN '17'.
            s_alvout-doc_state_icon = icon_booking_stop.
          WHEN '18'.
            s_alvout-doc_state_icon = icon_time.
          WHEN '19'.
          WHEN '99'.

        ENDCASE.

**      Reklamationsavise, falls Reklamiert
        IF s_docs-inv_doc_status = '04'.
          SELECT * FROM tinv_inv_doc INTO s_inv_doc_a
            WHERE ext_invoice_no = s_docs-ext_invoice_no
             AND doc_type = '008'.
            EXIT.
          ENDSELECT.

          SELECT * FROM tinv_inv_line_a INTO s_inv_line_a
            WHERE int_inv_doc_no = s_inv_doc_a-int_inv_doc_no
            AND  rstgr NE space.

            SELECT SINGLE date_of_receipt FROM tinv_inv_head INTO s_alvout-remdate
              WHERE int_inv_no = s_inv_line_a-int_inv_doc_no.

            MOVE s_inv_line_a-int_inv_doc_no  TO s_alvout-remadv.

          ENDSELECT.

        ENDIF.

**    Abrechnungsbeleg
        CLEAR s_ever.
        SELECT SINGLE * FROM ever INTO s_ever
          WHERE anlage = <t_eanl>-anlage
           AND auszdat GE sy-datum.

        CLEAR s_erch.
        SELECT * FROM erch INTO s_erch
          WHERE vertrag = s_ever-vertrag
          AND stornodat = '00000000'
          AND simulation = ''
          AND begabrpe = s_docs-invperiod_start
          AND endabrpe = s_docs-invperiod_end.
          EXIT.
        ENDSELECT.
        IF sy-subrc EQ 0.
          MOVE s_erch-belnr TO s_alvout-belnr.
        ENDIF.

**    Wurde schon eine Mail verschickt ?
        SELECT SINGLE * FROM /adesso/chk_mail INTO s_invchk_mail
        WHERE ext_invoice_no = s_docs-ext_invoice_no.
        IF sy-subrc = 0.
          s_alvout-mail_stat = icon_envelope_closed.
        ENDIF.

*  Freitext
        lx_header-tdobject = 'TEXT'.
        lx_header-tdid = 'ZIMM'.
        lx_header-tdspras = sy-langu.
        lx_header-tdlinesize = '132'.

        CONCATENATE 'TEXT' s_alvout-ext_invoice_no INTO lx_header-tdname SEPARATED BY '_'.

        CLEAR: tx_lines, help_line.
* Text (falls bereits vorhanden) einlesen und in Itab stellen
        CALL FUNCTION 'READ_TEXT'
          EXPORTING
*           CLIENT                  = SY-MANDT
            id                      = lx_header-tdid
            language                = lx_header-tdspras
            name                    = lx_header-tdname
            object                  = lx_header-tdobject
*           ARCHIVE_HANDLE          = 0
*           LOCAL_CAT               = ' '
*   IMPORTING
*           HEADER                  =
*           OLD_LINE_COUNTER        =
          TABLES
            lines                   = tx_lines
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

        READ TABLE tx_lines INTO help_line INDEX 1.

        s_alvout-free_text = help_line-tdline.

        APPEND s_alvout TO t_alvout.
      ENDLOOP.

    ELSE.
*     Wenn Selektionskriterien für die Rechnungsbelege vorhanden sind,
*     nicht übertragen
      IF s_rece[]   IS INITIAL AND
         s_send[]   IS INITIAL AND
         s_dtrec[]  IS INITIAL AND
         s_intido[] IS INITIAL AND
         s_idosta[] IS INITIAL.
        CLEAR s_alvout.
        MOVE-CORRESPONDING <t_eanl> TO s_alvout.
        APPEND s_alvout TO t_alvout.
      ENDIF.
    ENDIF.

  ENDLOOP.


ENDFORM.                    " SELECT_DATA

*&---------------------------------------------------------------------*
*&      Form  ALV_LAYOUT_BUILD
*&---------------------------------------------------------------------*
FORM alv_layout_build  USING  ls_layout TYPE slis_layout_alv.

  ls_layout-zebra = 'X'.
  ls_layout-colwidth_optimize = 'X'.

ENDFORM.                    " ALV_LAYOUT_BUILD

*-----------------------------------------------------------------------
*    FORM ALV_STATUS_MAIN
*-----------------------------------------------------------------------
FORM alv_status_main  USING extab TYPE slis_t_extab.

  SET PF-STATUS 'STATUS_MAIN' EXCLUDING extab.

ENDFORM.                    "ALV_STATUS_MAIN


*---------------------------------------------------------------------*
*       FORM ALV_UCOM_MAIN                                             *
*---------------------------------------------------------------------*
FORM alv_ucom_main USING r_ucomm LIKE sy-ucomm
                  rs_selfield TYPE slis_selfield.

  DATA: h_extui   TYPE ext_ui.

  CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
    IMPORTING
      e_grid = rev_alv.

  rev_alv->check_changed_data( ).

  READ TABLE t_alvout INTO s_alvout INDEX rs_selfield-tabindex.

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


  CASE r_ucomm.

*  MAIL Senden
    WHEN 'SENDMAIL'.
      PERFORM ucom_send_mail.

    WHEN 'SELECT_ALL'.
      PERFORM ucom_select_all.

    WHEN 'DESELECT'.
      PERFORM ucom_deselect_all.

    WHEN 'SEL_BLOCK'.
      PERFORM ucom_select_block USING rs_selfield-tabindex.
      PERFORM drop_select.

    WHEN OTHERS.

      CASE rs_selfield-fieldname.

        WHEN 'ANLAGE'.
          SET PARAMETER ID 'ANL' FIELD rs_selfield-value.
          CALL TRANSACTION 'ES32' AND SKIP FIRST SCREEN.

        WHEN 'EXT_UI'.
          MOVE rs_selfield-value TO h_extui.
          CALL FUNCTION 'ISU_S_UI_DISPLAY'
            EXPORTING
              x_ext_ui = h_extui.

        WHEN 'INT_INV_NO'.
          SUBMIT rinv_monitoring
            WITH p_invtp      = '001'
            WITH se_docnr-low = s_alvout-int_inv_no
            AND RETURN.

        WHEN 'INT_SENDER'.
          SET PARAMETER ID 'EESERVPROVID' FIELD rs_selfield-value.
          CALL TRANSACTION 'EEDMIDESERVPROV03' AND SKIP FIRST SCREEN.

        WHEN 'EXT_INVOICE_NO'.
          PERFORM ucom_ext_invoice_no.

        WHEN 'REMADV'.
          SUBMIT rinv_monitoring
            WITH p_invtp      = '008'
            WITH se_docnr-low = s_alvout-remadv
            AND RETURN.

        WHEN 'MAIL_STAT'.
          PERFORM ucom_show_mailtext.

        WHEN 'BELNR'.
          SET PARAMETER ID 'BEL'  FIELD s_alvout-belnr.
          CALL TRANSACTION 'EA22' AND SKIP FIRST SCREEN.

        WHEN 'FREE_TEXT'.
*        Eingabe Notiz über Texteditor
          PERFORM ucom_notice_edit USING rs_selfield-value
                                          rs_selfield-tabindex.

      ENDCASE.

  ENDCASE.

ENDFORM. " ALV_UCOM_MAIN.

*&---------------------------------------------------------------------*
*&      Form  ALV_FIELDCAT_INVNO
*&---------------------------------------------------------------------*
FORM alv_fieldcat_invno  USING ft_fieldcat TYPE slis_t_fieldcat_alv.

  DATA ls_fieldcat TYPE slis_fieldcat_alv.

* Kennung
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'PRODUCT_ID'.
  ls_fieldcat-tabname = 'IT_EXT_OUT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
  APPEND ls_fieldcat TO ft_fieldcat.

*  Text
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TEXT'.
  ls_fieldcat-tabname = 'IT_EXT_OUT'.
  ls_fieldcat-ref_tabname = 'EDEREG_SIDPROT'.
  APPEND ls_fieldcat TO ft_fieldcat.

* AB
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DATE_FROM'.
  ls_fieldcat-tabname = 'IT_EXT_OUT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
  APPEND ls_fieldcat TO ft_fieldcat.

* BIS
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DATE_TO'.
  ls_fieldcat-tabname = 'IT_EXT_OUT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
  APPEND ls_fieldcat TO ft_fieldcat.

*  Menge
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'QUANTITY'.
  ls_fieldcat-tabname = 'IT_EXT_OUT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
  APPEND ls_fieldcat TO ft_fieldcat.

* Mengeneinheit
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'UNIT'.
  ls_fieldcat-tabname = 'IT_EXT_OUT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
  APPEND ls_fieldcat TO ft_fieldcat.

* Preis
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'PRICE'.
  ls_fieldcat-tabname = 'IT_EXT_OUT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
  APPEND ls_fieldcat TO ft_fieldcat.

* Maßeinheit Preis
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'PRICE_UNIT'.
  ls_fieldcat-tabname = 'IT_EXT_OUT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
  APPEND ls_fieldcat TO ft_fieldcat.

* Nettobetrag
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'ETRW_NET'.
  ls_fieldcat-tabname = 'IT_EXT_OUT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
  APPEND ls_fieldcat TO ft_fieldcat.

* Steuerbetrag
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TAXBW'.
  ls_fieldcat-tabname = 'IT_EXT_OUT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
  APPEND ls_fieldcat TO ft_fieldcat.

* Fälligkeitsdatum
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DATE_OF_PAYMENT'.
  ls_fieldcat-tabname = 'IT_EXT_OUT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
  APPEND ls_fieldcat TO ft_fieldcat.

* Mehrwertsteuerkennzeichen
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'MWSKZ'.
  ls_fieldcat-tabname = 'IT_EXT_OUT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
  APPEND ls_fieldcat TO ft_fieldcat.

* Mehrwertsteuersatz
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'STRPZ'.
  ls_fieldcat-tabname = 'IT_EXT_OUT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B'.
  APPEND ls_fieldcat TO ft_fieldcat.

ENDFORM.                    " ALV_FIELDCAT_INVNO

*&---------------------------------------------------------------------*
*&      Form  MULT_INVOICE
*&---------------------------------------------------------------------*
FORM mult_invoice .

  DATA: ls_alvout_help LIKE s_alvout.

  SORT t_alvout BY aklasse tariftyp ableinh anlage int_inv_no.

* Prüfen, ob es mehrere INVOICes gibt zur Anlage und zum
* gleichen Abrechnungszeitraum
  LOOP AT t_alvout INTO s_alvout
    WHERE int_inv_no NE space.
    LOOP AT t_alvout INTO ls_alvout_help
      WHERE anlage = s_alvout-anlage AND
            invperiod_start = s_alvout-invperiod_start AND
            invperiod_end  = s_alvout-invperiod_end AND
            int_inv_no NE s_alvout-int_inv_no.
      ls_alvout_help-mult_inv = icon_copy_object.
      MODIFY t_alvout FROM ls_alvout_help
        TRANSPORTING mult_inv.
    ENDLOOP.

  ENDLOOP.

ENDFORM.                    " MULT_INVOICE


*&---------------------------------------------------------------------*
*&      Form  UCOM_SEND_MAIL
*&---------------------------------------------------------------------*
FORM ucom_send_mail .

  DATA: BEGIN OF s_cont_data,
          anlage         TYPE eanl-anlage,
          ext_ui         TYPE euitrans-ext_ui,
          int_inv_doc_no TYPE tinv_inv_doc-int_inv_doc_no,
        END OF s_cont_data.

  DATA: it_cont       LIKE STANDARD TABLE OF s_cont_data,
        wa_cont       LIKE s_cont_data,
        lv_b_selected TYPE boolean.

  DATA: lv_answer(1)     TYPE c,
        button_text1(16) TYPE c,
        icon_button1(30) TYPE c,
        button_text2(16) TYPE c,
        icon_button2(30) TYPE c.

  DATA: betreff TYPE string.
  DATA: content TYPE bcsy_text.
  DATA: content_line TYPE soli.



* Klasse für Mailversand instanzieren
  DATA cl_sendmail TYPE REF TO lcl_send_mail.
  CREATE OBJECT cl_sendmail.

  LOOP AT t_alvout INTO s_alvout.

    CHECK s_alvout-sel IS NOT INITIAL.
    lv_b_selected = abap_true.

*   Füllen der Felder für die Daten zur INVOIC
    cl_sendmail->set_content( EXPORTING iv_ext_invoice_no = s_alvout-ext_invoice_no
                                        iv_ext_ui         = s_alvout-ext_ui
                                        iv_anlage         = s_alvout-anlage ).

    wa_cont-anlage = s_alvout-anlage.
    wa_cont-ext_ui = s_alvout-ext_ui.
    wa_cont-int_inv_doc_no = s_alvout-int_inv_no.

    APPEND wa_cont TO it_cont.

  ENDLOOP.

  IF lv_b_selected EQ abap_false.
    MESSAGE e000(e4) WITH 'Bitte selektieren Sie einen Datensatz.'.
    EXIT.
  ENDIF.

* Mail versenden
  CALL METHOD cl_sendmail->send_mail
    EXPORTING
      im_subject = 'INVOICE:'
    IMPORTING
      em_betreff = betreff
      em_content = content.
*  betreff = cl_sendmail->send_mail( ).

  button_text1    = 'Ja'.
  button_text2    = 'Nein'.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'E-Mail Versand'
      text_question         = 'Ist die E-Mail verschickt worden?'
      text_button_1         = button_text1
      text_button_2         = button_text2
      default_button        = '1'
      display_cancel_button = ' '
      start_column          = 25
      start_row             = 6
    IMPORTING
      answer                = lv_answer.
  IF sy-subrc <> 0.
  ENDIF.

  IF lv_answer = 1.
    LOOP AT t_alvout INTO s_alvout WHERE
      sel IS NOT INITIAL.
      s_alvout-mail_stat = icon_envelope_closed.
      MODIFY t_alvout FROM s_alvout INDEX sy-tabix.
*     Mail-Tabelle füllen
      s_invchk_mail-ext_invoice_no = s_alvout-ext_invoice_no.
      s_invchk_mail-datum = sy-datum.
      s_invchk_mail-mailbetr = betreff.
      MODIFY /adesso/chk_mail FROM s_invchk_mail.
      CLEAR s_invchk_mail.
    ENDLOOP.

    CLEAR s_header.
    s_header-tdobject = 'TEXT'.
    s_header-tdname = betreff.
    s_header-tdid = 'ZIMM'.
    s_header-tdspras = 'D'.

    LOOP AT content INTO content_line.
      MOVE content_line-line TO s_line-tdline.
      APPEND s_line TO t_line.
    ENDLOOP.

    CALL FUNCTION 'SAVE_TEXT'
      EXPORTING
        client   = sy-mandt
        header   = s_header
*       INSERT   = ' '
*       SAVEMODE_DIRECT       = ' '
*       OWNER_SPECIFIED       = ' '
*       LOCAL_CAT             = ' '
* IMPORTING
*       FUNCTION =
*       NEWHEADER             =
      TABLES
        lines    = t_line
      EXCEPTIONS
        id       = 1
        language = 2
        name     = 3
        object   = 4
        OTHERS   = 5.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

  ENDIF.

ENDFORM.                    " UCOM_SEND_MAIL

*&---------------------------------------------------------------------*
*&      Form  UCOM_EXT_INVOICE_NO
*&---------------------------------------------------------------------*
FORM ucom_ext_invoice_no .

  CLEAR t_ext_out[].

  SELECT * FROM tinv_inv_doc INTO s_inv_doc_a
    WHERE ext_invoice_no = s_alvout-ext_invoice_no.

    SELECT * FROM tinv_inv_line_b INTO s_inv_line_b
      WHERE int_inv_doc_no = s_inv_doc_a-int_inv_doc_no
      AND product_id NE space.

      CLEAR: s_sidpro, s_sidprot.
      SELECT * FROM edereg_sidpro INTO s_sidpro
        WHERE product_id = s_inv_line_b-product_id.
        EXIT.
      ENDSELECT.
      SELECT SINGLE * FROM edereg_sidprot INTO s_sidprot
        WHERE int_serident = s_sidpro-int_serident
          AND product_id_type = s_sidpro-product_id_type
          AND spras = sy-langu.

      MOVE-CORRESPONDING s_inv_line_b TO s_ext_out.
      MOVE s_sidprot-text TO s_ext_out-text.
      APPEND s_ext_out TO t_ext_out.
      CLEAR s_ext_out.

    ENDSELECT.

  ENDSELECT.


  PERFORM alv_fieldcat_invno USING gt_fieldcat_invno[].

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      it_fieldcat           = gt_fieldcat_invno[]
      i_screen_start_column = 10
      i_screen_start_line   = 10
      i_screen_end_column   = 200
      i_screen_end_line     = 20
    TABLES
      t_outtab              = t_ext_out
    EXCEPTIONS
      program_error         = 1
      OTHERS                = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " UCOM_EXT_INVOICE_NO

*&---------------------------------------------------------------------*
*&      Form  UCOM_SELECT_ALL
*&---------------------------------------------------------------------*
FORM ucom_select_all .

  LOOP AT t_alvout INTO s_alvout.

    READ TABLE gt_filtered
       WITH KEY table_line = sy-tabix
       TRANSPORTING NO FIELDS.

    CHECK sy-subrc NE 0.

    s_alvout-sel = 'X'.
    MODIFY t_alvout FROM s_alvout.

  ENDLOOP.

ENDFORM.                    " UCOM_SELECT_ALL

*&---------------------------------------------------------------------*
*&      Form  UCOM_DESELECT_ALL
*&---------------------------------------------------------------------*
FORM ucom_deselect_all .

  LOOP AT t_alvout INTO s_alvout.

    CLEAR s_alvout-sel.
    MODIFY t_alvout FROM s_alvout.

  ENDLOOP.
ENDFORM.                    " UCOM_DESELECT_ALL

*&---------------------------------------------------------------------*
*&      Form  UCOM_SELECT_BLOCK
*&---------------------------------------------------------------------*
FORM ucom_select_block  USING ff_tabindex TYPE slis_selfield-tabindex.

  DATA: l_answer TYPE char1.

  IF g_block_line IS INITIAL.
    g_block_line = ff_tabindex.

    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
      EXPORTING
        defaultoption = 'Y'
        textline1     = text-100
        textline2     = text-101
        titel         = text-t01
      IMPORTING
        answer        = l_answer.

    IF NOT l_answer CA 'jJyY'.
      CLEAR g_block_line.
      EXIT.
    ENDIF.

  ELSE.

    IF g_block_line <= ff_tabindex.
      g_block_beg   = g_block_line.
      g_block_end   = ff_tabindex.
    ELSE.
      g_block_beg   = ff_tabindex.
      g_block_end   = g_block_line.
    ENDIF.

    LOOP AT t_alvout INTO s_alvout
         FROM g_block_beg TO g_block_end.

      READ TABLE gt_filtered
         WITH KEY table_line = sy-tabix
         TRANSPORTING NO FIELDS.

      CHECK sy-subrc NE 0.

      s_alvout-sel = 'X'.
      MODIFY t_alvout FROM s_alvout.

    ENDLOOP.

    CLEAR g_block_line.

  ENDIF.

ENDFORM.                    " UCOM_SELECT_BLOCK

*&---------------------------------------------------------------------*
*&      Form  DROP_SELECT
*&---------------------------------------------------------------------*
FORM drop_select .

  PERFORM ucom_deselect_all.

ENDFORM.                    " DROP_SELECT

*&---------------------------------------------------------------------*
*&      Form  ALV_VARIANT_INIT
*&---------------------------------------------------------------------*
FORM alv_variant_init .

  g_repid = sy-repid.
  g_save = 'A'.

  CLEAR gs_variant.
  gs_variant-report = g_repid.

ENDFORM.                    " ALV_VARIANT_INIT


*&---------------------------------------------------------------------*
*&      Form  ALV_F4_VARIANT
*&---------------------------------------------------------------------*
FORM alv_f4_variant .

  CLEAR gs_variant.
  gs_variant-report = g_repid.
  g_save = 'A'.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = gs_variant
      i_save     = g_save
    IMPORTING
      e_exit     = g_exit
      es_variant = gs_variant
    EXCEPTIONS
      OTHERS     = 4.

  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE 'S'      NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    IF g_exit = space.
      p_varia = gs_variant-variant.
    ENDIF.
  ENDIF.

ENDFORM.                    " ALV_F4_VARIANT

*&---------------------------------------------------------------------*
*&      Form  ALV_PAI_SELSCR
*&---------------------------------------------------------------------*
FORM alv_pai_selscr .
*
  IF NOT p_varia IS INITIAL.
    MOVE gs_variant TO gx_variant.
    MOVE p_varia TO gx_variant-variant.
    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
      EXPORTING
        i_save     = g_save
      CHANGING
        cs_variant = gx_variant.
    gs_variant = gx_variant.
  ELSE.
    PERFORM alv_variant_init.
  ENDIF.

ENDFORM.                    " ALV_PAI_SELSCR

*&---------------------------------------------------------------------*
*&      Form  UCOM_SHOW_MAILTEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ucom_show_mailtext .

  DATA: l_name TYPE thead-tdname.
  DATA: s_text TYPE char120,
        t_text LIKE TABLE OF s_text.


  SELECT SINGLE * FROM /adesso/chk_mail INTO s_invchk_mail
    WHERE ext_invoice_no = s_alvout-ext_invoice_no.

  CLEAR s_header.
  s_header-tdobject = 'TEXT'.
  s_header-tdname = s_invchk_mail-mailbetr.
  s_header-tdid = 'ZIMM'.
  s_header-tdspras = 'D'.
  s_header-tdlinesize = '50'.

  MOVE s_invchk_mail-mailbetr TO l_name.


  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      client                  = sy-mandt
      id                      = 'ZIMM'
      language                = sy-langu
      name                    = l_name
      object                  = 'TEXT'
*     ARCHIVE_HANDLE          = 0
*     LOCAL_CAT               = ' '
* IMPORTING
*     HEADER                  =
*     OLD_LINE_COUNTER        =
    TABLES
      lines                   = t_line
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

  LOOP AT t_line INTO s_line.
    MOVE s_line-tdline TO s_text.
    APPEND s_text TO t_text.
  ENDLOOP.

  CALL FUNCTION 'COPO_POPUP_TO_DISPLAY_TEXTLIST'
    EXPORTING
*     TASK       = 'DISPLAY'
      titel      = s_invchk_mail-mailbetr
* IMPORTING
*     FUNCTION   =
    TABLES
      text_table = t_line.


*  CALL FUNCTION 'ISU_POPUP_TEXT_EDIT'
*    EXPORTING
*      x_start_x_pos = 5
*      x_start_y_pos = 5
*      x_height      = 20
**     X_TITLE       =
*      x_no_change   = 'X'
*    CHANGING
*      xy_texttab    = t_text
*    EXCEPTIONS
*      general_fault = 1
*      OTHERS        = 2.
*  IF sy-subrc <> 0.
** Implement suitable error handling here
*  ENDIF.



ENDFORM.                    " UCOM_SHOW_MAILTEXT

*&---------------------------------------------------------------------*
*&      Form  UCOM_NOTICE_EDIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_RS_SELFIELD_VALUE  text
*      -->P_RS_SELFIELD_TABINDEX  text
*----------------------------------------------------------------------*
FORM ucom_notice_edit  USING    fp_value    TYPE slis_selfield-value
                                fp_tabindex TYPE slis_selfield-tabindex.


  DATA:  lx_header TYPE thead.
  DATA:  tx_lines TYPE STANDARD TABLE OF tline.

  DATA: help_line TYPE tline.
  DATA: length TYPE i.

  lx_header-tdobject = 'TEXT'.
  lx_header-tdid = 'ZIMM'.
  lx_header-tdspras = sy-langu.
  lx_header-tdlinesize = '132'.

  CONCATENATE 'TEXT' s_alvout-ext_invoice_no INTO lx_header-tdname SEPARATED BY '_'.

  CLEAR tx_lines.
* Text (falls bereits vorhanden) einlesen und in Itab stellen
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
*     CLIENT                  = SY-MANDT
      id                      = lx_header-tdid
      language                = lx_header-tdspras
      name                    = lx_header-tdname
      object                  = lx_header-tdobject
*     ARCHIVE_HANDLE          = 0
*     LOCAL_CAT               = ' '
*   IMPORTING
*     HEADER                  =
*     OLD_LINE_COUNTER        =
    TABLES
      lines                   = tx_lines
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
      IF s_alvout-free_text IS NOT INITIAL.
        length = strlen( s_alvout-free_text ).
        IF length GT 132.
          help_line-tdline = s_alvout-free_text(132).
          APPEND help_line TO tx_lines.
          help_line-tdline = s_alvout-free_text+132.
          APPEND help_line TO tx_lines.
        ELSE.
          help_line-tdline = s_alvout-free_text.
          APPEND help_line TO tx_lines.
        ENDIF.
      ENDIF.
    ELSE.
* Implement suitable error handling here
    ENDIF.
  ENDIF.

* Text Editieren
  CALL FUNCTION 'EDIT_TEXT'
    EXPORTING
*     DISPLAY       = ' '
*     EDITOR_TITLE  = ' '
      header        = lx_header
*     PAGE          = ' '
*     WINDOW        = ' '
*     SAVE          = 'X'
*     LINE_EDITOR   = ' '
*     CONTROL       = ' '
*     PROGRAM       = ' '
*     LOCAL_CAT     = ' '
* IMPORTING
*     FUNCTION      =
*     NEWHEADER     =
*     RESULT        =
    TABLES
      lines         = tx_lines
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

  READ TABLE tx_lines INTO help_line INDEX 1.

  IF sy-subrc = 0.
    s_alvout-free_text = help_line-tdline.
    MODIFY t_alvout FROM s_alvout INDEX fp_tabindex.
  ENDIF.


ENDFORM.                    " UCOM_NOTICE_EDIT
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
