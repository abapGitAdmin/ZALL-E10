*&---------------------------------------------------------------------*
*& Report  /ADESSO/PRINTDOC_INVOIC_SEND
*&
*&---------------------------------------------------------------------*
* Report zur Erzeugung des IDOCs
* ----------------------------------------------------------------
* Änderungshistorie:
*     Datum       Benutzer  Grund
*&---------------------------------------------------------------------*
REPORT /adesso/printdoc_invoic_send.

INCLUDE /adesso/printdoc_invoic_top.
INCLUDE /adesso/printdoc_invoic_sf1.

INITIALIZATION.
**Authority Check
*  AUTHORITY-CHECK OBJECT 'S_TCODE' ID 'TCD' FIELD '/ADESSO/PRINTDOC_INV'.
*  IF sy-subrc NE 0.
*    MESSAGE e172(00) WITH '/ADESSO/PRINTDOC_INV'.
*  ENDIF.

**Authority Check
*  AUTHORITY-CHECK OBJECT 'F_KKKO_BUK'
*  ID 'BUKRS' FIELD '1283'
*  ID 'ACTVT' FIELD '02'.
*  IF sy-subrc NE 0.
*    MESSAGE e172(00) WITH '/ADESSO/PRINTDOC_INV'.
*  ENDIF.

  button1         = 'Standard'(017).
  button2         = 'Nachversand'(018).
  mytab-prog      = sy-repid.
  mytab-dynnr     = 100.
  mytab-activetab = 'PUSH1'(019).


AT SELECTION-SCREEN.
  CASE sy-dynnr.
    WHEN 1000.
      CASE sy-ucomm.
        WHEN 'PUSH1'.
          mytab-dynnr = 100.
        WHEN 'PUSH2'.
          mytab-dynnr = 200.
        WHEN OTHERS.
*        ...
      ENDCASE.
  ENDCASE.

*-----------------------------------------------------------------------
* Start of Selection
*-----------------------------------------------------------------------
START-OF-SELECTION.

*prepare message log
  CLEAR gs_param.
  gs_eemsg_sub-msgty = co_msg_error.
  gs_eemsg_sub-sub_object = 'ERROR'.
  APPEND gs_eemsg_sub TO gt_eemsg_sub.
  gs_eemsg_sub-msgty = co_msg_warning.
  gs_eemsg_sub-sub_object = 'WARNING'.
  APPEND gs_eemsg_sub TO gt_eemsg_sub.
  gs_eemsg_sub-msgty = co_msg_success.
  gs_eemsg_sub-sub_object = 'SUCCESS'.
  APPEND gs_eemsg_sub TO gt_eemsg_sub.
  gs_param-extnumber = p_extnr.
  gs_param-appl_log  = '/ADESSO/EDIFACT_INV'.
  gs_param-subs = gt_eemsg_sub.

  IF mytab-dynnr EQ '100'.

* Get contract account
    SELECT * FROM fkkvkp INTO TABLE gt_fkkvkp
      WHERE vkont        IN so_vkont AND
            gpart        IN so_gpart AND
            zzedivar IN s_edi.
    IF sy-subrc <> 0.
      CLEAR gs_error_tab.
      gs_error_tab-msg_typ = 'E'.
      gs_error_tab-msg_klasse = '/ADESSO/EDIFACT_INV'.
      gs_error_tab-msg_nr = '090'.
      APPEND gs_error_tab TO gt_error_tab.
      SET EXTENDED CHECK OFF.
      IF 1 = 2. MESSAGE e090(/adesso/edifact_inv). ENDIF.
      SET EXTENDED CHECK ON.
      gv_error_log = 'X'.
    ENDIF.

  ENDIF.

*Get EDI Variante
  IF gv_error_log IS INITIAL.
    SELECT * FROM /adesso/edivar INTO TABLE gt_edivar
      WHERE sparte = p_sparte.
    IF sy-subrc <> 0.
      CLEAR gs_error_tab.
      gs_error_tab-msg_typ = 'E'.
      gs_error_tab-msg_klasse = '/ADESSO/EDIFACT_INV'.
      gs_error_tab-msg_nr = '030'.
      APPEND gs_error_tab TO gt_error_tab.
      SET EXTENDED CHECK OFF.
      IF 1 = 2. MESSAGE e030(/adesso/edifact_inv). ENDIF.
      SET EXTENDED CHECK ON.
      gv_error_log = 'X'.
    ENDIF.
  ENDIF.

* Get printdocs
  IF gv_error_log IS  INITIAL  AND
     mytab-dynnr  EQ '100'.

    SELECT * FROM erdk INTO TABLE gt_erdk
      FOR ALL ENTRIES IN gt_fkkvkp
      WHERE druckdat     =  '00000000'           AND
            vkont        =   gt_fkkvkp-vkont     AND
            edisenddate  =  '00000000'           AND
            zzdb_freidat <> '00000000'.

    IF sy-subrc <> 0.
      CLEAR gs_error_tab.
      gs_error_tab-msg_typ = 'E'.
      gs_error_tab-msg_klasse = '/ADESSO/EDIFACT_INV'.
      gs_error_tab-msg_nr = '092'.
      APPEND gs_error_tab TO gt_error_tab.
      SET EXTENDED CHECK OFF.
      IF 1 = 2. MESSAGE e092(/adesso/edifact_inv). ENDIF.
      SET EXTENDED CHECK ON.
      gv_error_log = 'X'.
    ENDIF.
  ENDIF.

  IF gv_error_log IS INITIAL.

    CLEAR: gv_sent.
* Open MSG Log
    CALL FUNCTION 'MSG_OPEN'
      EXPORTING
        x_no_dialog  = ' '
        x_log        = 'X'
        x_next_msg   = ' '
        x_obj_twice  = ' '
      IMPORTING
        y_msg_handle = gv_handle
      CHANGING
        xy_parm      = gs_param
      EXCEPTIONS
        failed       = 1
        subs_invalid = 2
        log_invalid  = 3
        OTHERS       = 4.
    IF sy-subrc <> 0.
      MESSAGE e021(/adesso/edifact_inv).
    ENDIF.


    PERFORM get_resend_data_01 USING     p_idoc_1
                                         p_prbl_1
                                         p_sel_1
                                         mytab-dynnr
                               CHANGING  gt_erdk
                                         gt_fkkvkp
                                         gs_error_tab.


    SORT gt_erdk BY vkont verart faedn opbel.

    LOOP AT gt_erdk INTO gs_erdk.

      IF gs_erdk-abrvorg    EQ '04'  AND
         gs_erdk-total_amnt EQ  0.
        CONTINUE.
      ENDIF.

* for INVOIC, printdoc has to fullfilled this condition
      IF gs_erdk-edisenddate = '00000000'.

        gv_sent = gv_sent + 1.

* Fill ERDK Structure
        gs_invoice-erdk = gs_erdk.

* Get ERDZ Struktur
        CALL FUNCTION 'ISU_DB_ERDL_SELECT_DOC'
          EXPORTING
            x_opbel           = gs_invoice-erdk-opbel
          TABLES
            yt_erdz           = gs_invoice-t_erdz
          EXCEPTIONS
            not_found         = 1
            not_qualified     = 2
            system_error      = 3
            billdoc_not_found = 4
            OTHERS            = 5.
        IF sy-subrc <> 0.
          CLEAR gs_error_tab.
          gs_error_tab-msg_typ = 'E'.
          gs_error_tab-msg_klasse = '/ADESSO/EDIFACT_INV'.
          gs_error_tab-msg_nr = '083'.
          gs_error_tab-msg_1 = gs_erdk-opbel.
          APPEND gs_error_tab TO gt_error_tab.

          SET EXTENDED CHECK OFF.
          IF 1 = 2. MESSAGE e083(/adesso/edifact_inv). ENDIF.
          SET EXTENDED CHECK ON.
          CONTINUE.
        ENDIF.

* Budget Billing Plan  has to be updated
        IF gs_invoice-erdk-verart = 'R6'.

          CLEAR: gs_edi_abs,
                 gs_error_tab.

          PERFORM check_erdz     USING    gs_invoice-erdk-vkont
                                          gs_invoice-erdk-opbel
                                          mytab-dynnr
                                 CHANGING gs_error_tab
                                          gs_invoice-t_erdz
                                          gs_edi_abs.


          PERFORM resend_abs_01  USING    gs_invoice-erdk-opbel
                                          mytab-dynnr
                                 CHANGING gs_error_tab
                                          gs_invoice-t_erdz.

          IF NOT gs_error_tab IS INITIAL.
            APPEND gs_error_tab TO gt_error_tab.
            CLEAR gs_error_tab.
            CONTINUE.
          ENDIF.

        ENDIF.

        READ TABLE gs_invoice-t_erdz INTO gs_erdz INDEX 1.
        CLEAR gs_erch.
* Nicht für Abschlagsbelege
        IF gs_erdk-verart NE 'R6'.

          SELECT SINGLE * FROM erch INTO gs_erch
            WHERE belnr = gs_erdz-erchbelnr.
          IF sy-subrc <> 0.
            CLEAR gs_error_tab.
            gs_error_tab-msg_typ = 'E'.
            gs_error_tab-msg_klasse = '/ADESSO/EDIFACT_INV'.
            gs_error_tab-msg_nr = '094'.
            APPEND gs_error_tab TO gt_error_tab.
*         gv_error_log = 'X'.
            SET EXTENDED CHECK OFF.
            IF 1 = 2. MESSAGE e094(/adesso/edifact_inv). ENDIF.
            SET EXTENDED CHECK ON.
            CONTINUE.
          ENDIF.

        ENDIF.
* Get Contract
        SELECT SINGLE * FROM ever INTO gs_ever
          WHERE vertrag = gs_erdz-vertrag.  "nicht aus der gs_erch-vertrag
        IF sy-subrc <> 0.
          CLEAR gs_error_tab.
          gs_error_tab-msg_typ = 'E'.
          gs_error_tab-msg_klasse = '/ADESSO/EDIFACT_INV'.
          gs_error_tab-msg_nr = '091'.
          APPEND gs_error_tab TO gt_error_tab.
*         gv_error_log = 'X'.
          SET EXTENDED CHECK OFF.
          IF 1 = 2. MESSAGE e091(/adesso/edifact_inv). ENDIF.
          SET EXTENDED CHECK ON.
          CONTINUE.
        ENDIF.

        IF gs_ever-anlage IS INITIAL.

          CLEAR: gv_anlage_01.

          SELECT anlage FROM everh INTO gv_anlage_01
            WHERE vertrag EQ gs_ever-vertrag  AND
                  bis     GE gs_erdk-bldat    AND
                  anlage  NE space            AND
                  ab      LE gs_erdk-bldat.

            MOVE gs_erdk-bldat TO gv_datum_01.

            EXIT.

          ENDSELECT.

          IF sy-subrc NE 0.

            LOOP AT gs_invoice-t_erdz ASSIGNING <gs_erdz_01>.

              SELECT anlage FROM everh INTO gv_anlage_01
               WHERE vertrag EQ gs_ever-vertrag     AND
                     bis     GE <gs_erdz_01>-bis    AND
                     anlage  NE space               AND
                     ab      LE <gs_erdz_01>-bis.

                MOVE <gs_erdz_01>-bis TO gv_datum_01.

                EXIT.

              ENDSELECT.

              IF sy-subrc EQ 0.
                EXIT.
              ENDIF.

            ENDLOOP.


          ENDIF.

        ELSE.

          MOVE gs_ever-anlage  TO gv_anlage_01.
          MOVE gs_ever-auszdat TO gv_datum_01.

        ENDIF.

        CALL FUNCTION 'ISU_DB_EANL_SELECT'
          EXPORTING
            x_anlage     = gv_anlage_01
            x_keydate    = gv_datum_01
            x_actual     = abap_true
          IMPORTING
            y_v_eanl     = ls_v_eanl
          EXCEPTIONS
            not_found    = 1
            system_error = 2
            invalid_date = 3
            OTHERS       = 4.
        IF sy-subrc <> 0.

        ENDIF.

        IF ls_v_eanl-aklasse EQ 'VRTR'. " RLM
          IF ls_v_eanl-anlart EQ 'GABX'.

            CALL FUNCTION 'ISU_DB_EANL_SELECT_VST_SP'
              EXPORTING
                x_vstelle    = ls_v_eanl-vstelle
                x_sparte     = ls_v_eanl-sparte
              TABLES
                yt_eanl      = lt_eanl
              EXCEPTIONS
                not_found    = 1
                system_error = 2
                OTHERS       = 3.
            IF sy-subrc <> 0.
* Implement suitable error handling here
            ENDIF.

            READ TABLE lt_eanl INTO ls_eanl WITH KEY anlart = 'GKOX'.

            IF sy-subrc EQ 0.

              CALL FUNCTION 'ISU_INT_UI_DETERMINE'
                EXPORTING
*                 X_CONTRACT        =
                  x_anlage          = ls_eanl-anlage
*                 X_EXT_POD         =
*                 X_INT_POD         =
                  x_keydate         = gv_datum_01
                IMPORTING
*                 Y_CONTRACT        =
*                 Y_ANLAGE          =
*                 y_ext_pod         =
                  y_int_pod         = lv_int_ui
*                 Y_SPARTE          =
                EXCEPTIONS
                  not_found         = 1
                  programming_error = 2
                  system_error      = 3
                  OTHERS            = 4.
              IF sy-subrc <> 0.
* Implement suitable error handling here
              ENDIF.

            ENDIF.

          ENDIF.
        ELSE.

* Get POD
          SELECT SINGLE * FROM euiinstln INTO gs_euiinstln
            WHERE anlage   EQ gv_anlage_01    AND
                  dateto   GE gv_datum_01     AND
                  datefrom LE gv_datum_01.

          IF sy-subrc <> 0.

            CLEAR gs_error_tab.

            gs_error_tab-msg_typ    = 'E'.
            gs_error_tab-msg_klasse = '00'.
            gs_error_tab-msg_nr     = '001'.
            gs_error_tab-msg_1      = 'Kein ZP zu Anlage'(024).
            gs_error_tab-msg_2      =  gs_ever-anlage.
            gs_error_tab-msg_3      = 'und Stichtag'(025).
            gs_error_tab-msg_4      =  gs_ever-auszdat.

            APPEND gs_error_tab TO gt_error_tab.

*         gv_error_log = 'X'.
            SET EXTENDED CHECK OFF.

            IF 1 = 2. MESSAGE e001(00). ENDIF.

            SET EXTENDED CHECK ON.

            CONTINUE.

          ENDIF.

        ENDIF.

* Fill ecrosrefno structure
        gs_ecrossrefno-mandt = sy-mandt.
        gs_ecrossrefno-int_crossrefno = space.
        IF gs_euiinstln IS NOT INITIAL.
          gs_ecrossrefno-int_ui  = gs_euiinstln-int_ui.
        ELSE.
          gs_ecrossrefno-int_ui = lv_int_ui.
        ENDIF.
* Nicht für Abschlagsbelege
        IF gs_erdk-verart EQ 'R6'.
          gs_ecrossrefno-keydate = gs_erdk-budat.
        ELSE.
          gs_ecrossrefno-keydate = gs_erch-endabrpe.
        ENDIF.
        gs_ecrossrefno-abrdats = gs_erch-abrdats.
        gs_ecrossrefno-vertrag = gs_erdz-vertrag. "nicht aus gs_erch
        gs_ecrossrefno-created_from = '2'.
        gs_ecrossrefno-belnr = gs_erch-belnr.

* Generate intern crossrefnr.
        CALL FUNCTION 'ISU_DB_ECROSSREFNO_UPDATE'
          EXPORTING
            x_ecrossrefno     = gs_ecrossrefno
            x_upd_mode        = 'I'
          EXCEPTIONS
            update_error      = 1
            programming_error = 2
            OTHERS            = 3.
        IF sy-subrc <> 0.
          mac_msg_repeat co_msg_error space.
          CLEAR gs_error_tab.
          gs_error_tab-msg_typ = 'E'.
          gs_error_tab-msg_klasse = '/ADESSO/EDIFACT_INV'.
          gs_error_tab-msg_nr = '082'.
          APPEND gs_error_tab TO gt_error_tab.
*         gv_error_log = 'X'.
          SET EXTENDED CHECK OFF.
          IF 1 = 2. MESSAGE e082(/adesso/edifact_inv). ENDIF.
          SET EXTENDED CHECK ON.
          CONTINUE.
        ELSE.
* Get the last entry
          SELECT * FROM ecrossrefno INTO TABLE gt_ecrossrefno_read
            WHERE int_ui = gs_ecrossrefno-int_ui AND
                  crossrefno = '' AND
                  vertrag = gs_ecrossrefno-vertrag AND
                  belnr = gs_ecrossrefno-belnr.

          SORT gt_ecrossrefno_read BY erdat DESCENDING.
* Fill the field crossrefno with invoice nr.
          CLEAR: gs_ecrossrefno_read.
          LOOP AT gt_ecrossrefno_read INTO gs_ecrossrefno_read WHERE crossrefno = ''.
            IF sy-subrc = 0 AND gs_ecrossrefno_read IS NOT INITIAL.
              EXIT.
            ELSE.
              CONTINUE.
            ENDIF.
          ENDLOOP.
          CONCATENATE 'PRN' gs_invoice-erdk-opbel INTO gs_ecrossrefno_read-crossrefno.
          CALL FUNCTION 'ISU_DB_ECROSSREFNO_UPDATE'
            EXPORTING
              x_ecrossrefno     = gs_ecrossrefno_read
              x_upd_mode        = 'U'
            EXCEPTIONS
              update_error      = 1
              programming_error = 2
              OTHERS            = 3.
          IF sy-subrc <> 0.
            mac_msg_repeat co_msg_error space.
            CLEAR gs_error_tab.
            gs_error_tab-msg_typ = 'E'.
            gs_error_tab-msg_klasse = '/ADESSO/EDIFACT_INV'.
            gs_error_tab-msg_nr = '082'.
            APPEND gs_error_tab TO gt_error_tab.
            SET EXTENDED CHECK OFF.
            IF 1 = 2. MESSAGE e082(/adesso/edifact_inv). ENDIF.
            SET EXTENDED CHECK ON.
            CONTINUE.
          ENDIF.
        ENDIF.
* Get ERDR Struktur
        IF gs_erdk-erdr_v IS NOT INITIAL.
          CALL FUNCTION 'ISU_DB_ERDR_SELECT_DOC'
            EXPORTING
              x_opbel       = gs_invoice-erdk-opbel
            TABLES
              yt_erdr       = gs_invoice-t_erdr
            EXCEPTIONS
              not_found     = 1
              not_qualified = 2
              system_error  = 3
              OTHERS        = 4.
          IF sy-subrc <> 0.
            CLEAR gs_error_tab.
            gs_error_tab-msg_typ = 'E'.
            gs_error_tab-msg_klasse = '/ADESSO/EDIFACT_INV'.
            gs_error_tab-msg_nr = '084'.
            gs_error_tab-msg_1 = gs_erdk-opbel.
            APPEND gs_error_tab TO gt_error_tab.
*           gv_error_log = 'X'.
            SET EXTENDED CHECK OFF.
            IF 1 = 2. MESSAGE e084(/adesso/edifact_inv). ENDIF.
            SET EXTENDED CHECK ON.
            CONTINUE.
          ENDIF.
        ENDIF.

* Get ERDO Struktur
        IF gs_erdk-erdo_v IS NOT INITIAL.
          CALL FUNCTION 'ISU_DB_ERDO_SELECT_DOC'
            EXPORTING
              x_opbel       = gs_invoice-erdk-opbel
            TABLES
              yt_erdo       = gs_invoice-t_erdo
            EXCEPTIONS
              not_found     = 1
              not_qualified = 2
              system_error  = 3
              OTHERS        = 4.
          IF sy-subrc <> 0.
            CLEAR gs_error_tab.
            gs_error_tab-msg_typ = 'E'.
            gs_error_tab-msg_klasse = '/ADESSO/EDIFACT_INV'.
            gs_error_tab-msg_nr = '085'.
            gs_error_tab-msg_1 = gs_erdk-opbel.
            APPEND gs_error_tab TO gt_error_tab.
*           gv_error_log = 'X'.
            SET EXTENDED CHECK OFF.
            IF 1 = 2. MESSAGE e085(/adesso/edifact_inv). ENDIF.
            SET EXTENDED CHECK ON.
            CONTINUE.
          ENDIF.
        ENDIF.

*Get ERDB Struktur
        IF gs_erdk-erdb_v IS NOT INITIAL.
          CALL FUNCTION 'ISU_DB_ERDB_SELECT_DOC'
            EXPORTING
              x_opbel       = gs_invoice-erdk-opbel
            TABLES
              yt_erdb       = gs_invoice-t_erdb
            EXCEPTIONS
              not_found     = 1
              not_qualified = 2
              system_error  = 3
              OTHERS        = 4.
          IF sy-subrc <> 0.
            CLEAR gs_error_tab.
            gs_error_tab-msg_typ = 'E'.
            gs_error_tab-msg_klasse = '/ADESSO/EDIFACT_INV'.
            gs_error_tab-msg_nr = '086'.
            gs_error_tab-msg_1 = gs_erdk-opbel.
            APPEND gs_error_tab TO gt_error_tab.
*           gv_error_log = 'X'.
            SET EXTENDED CHECK OFF.
            IF 1 = 2. MESSAGE e086(/adesso/edifact_inv). ENDIF.
            SET EXTENDED CHECK ON.
            CONTINUE.
          ENDIF.
        ENDIF.

*Get ERDU Struktur
        IF gs_erdk-erdu_v IS NOT INITIAL.
          CALL FUNCTION 'ISU_DB_ERDU_SELECT_DOC'
            EXPORTING
              x_opbel       = gs_invoice-erdk-opbel
            TABLES
              yt_erdu       = gs_invoice-t_erdu
            EXCEPTIONS
              not_found     = 1
              not_qualified = 2
              system_error  = 3
              OTHERS        = 4.
          IF sy-subrc <> 0.
            CLEAR gs_error_tab.
            gs_error_tab-msg_typ = 'E'.
            gs_error_tab-msg_klasse = '/ADESSO/EDIFACT_INV'.
            gs_error_tab-msg_nr = '087'.
            gs_error_tab-msg_1 = gs_erdk-opbel.
            APPEND gs_error_tab TO gt_error_tab.
*           gv_error_log = 'X'.
            SET EXTENDED CHECK OFF.
            IF 1 = 2. MESSAGE e087(/adesso/edifact_inv). ENDIF.
            SET EXTENDED CHECK ON.
            CONTINUE.
          ENDIF.
        ENDIF.

* Get ERDTS Struktur
        IF gs_erdk-erdts_v IS NOT INITIAL.
          CALL FUNCTION 'ISU_DB_ERDTS_SELECT_DOC'
            EXPORTING
              x_printdoc    = gs_invoice-erdk-opbel
            TABLES
              yt_erdts      = gs_invoice-t_erdts
            EXCEPTIONS
              not_found     = 1
              not_qualified = 2
              system_error  = 3
              OTHERS        = 4.
          IF sy-subrc <> 0.
            CLEAR gs_error_tab.
            gs_error_tab-msg_typ = 'E'.
            gs_error_tab-msg_klasse = '/ADESSO/EDIFACT_INV'.
            gs_error_tab-msg_nr = '088'.
            gs_error_tab-msg_1 = gs_erdk-opbel.
            APPEND gs_error_tab TO gt_error_tab.
*           gv_error_log = 'X'.
            SET EXTENDED CHECK OFF.
            IF 1 = 2. MESSAGE e088(/adesso/edifact_inv). ENDIF.
            SET EXTENDED CHECK ON.
            CONTINUE.
          ENDIF.
        ENDIF.

* Erstellungsgrund des Druckbelegs, Storno?
        IF gs_invoice-erdk-ergrd = '04'.
          gv_reverse = 'X'.
        ELSE.
          gv_reverse = ''.
        ENDIF.

        READ TABLE gt_fkkvkp INTO gs_fkkvkp WITH KEY vkont = gs_erdk-vkont.
* Abweichendes Vertragskonto ?
        IF gs_fkkvkp-abwvk IS NOT INITIAL.
          gv_vkonto = gs_fkkvkp-abwvk.
        ELSE.
          gv_vkonto = gs_erdk-vkont.
        ENDIF.

* check Empfäner
        READ TABLE gt_edivar INTO gs_edivar
          WITH KEY edivariante = gs_fkkvkp-zzedivar
                   sparte = gs_erdz-sparte.
        IF sy-subrc <> 0 OR gs_edivar-serviceid IS INITIAL.

          IF mytab-dynnr EQ '200'.

            ROLLBACK WORK.

            WAIT UP TO 1 SECONDS.

            MESSAGE e001(00) WITH 'Bitte überprüfen Sie EDI-Variante und Sparte!'(026).

          ENDIF.

          CONTINUE.

        ELSE.

          IF p_spfrem IS NOT INITIAL AND
            gs_edivar-serviceid IS NOT INITIAL AND
            p_spfrem = gs_edivar-serviceid.

            gv_empf = p_spfrem.
          ELSE.
            gv_empf = gs_edivar-serviceid.
          ENDIF.

        ENDIF.

* check Sender
        IF gs_ever-invoicing_party IS INITIAL.
          CONTINUE.
        ELSE.
          IF p_spself IS NOT INITIAL AND
            gs_ever-invoicing_party IS NOT INITIAL AND
            p_spself = gs_ever-invoicing_party.

            gv_sender = p_spself.
          ELSE.
            gv_sender = gs_ever-invoicing_party.
          ENDIF.
        ENDIF.

        CALL FUNCTION 'ISU_COMEV_PROCESS_INVOICE' " '/ADESSO/COMEV_PROCESS_INVOICE'
          EXPORTING
            x_invoice          = gs_invoice
            x_reverse          = gv_reverse
            x_ecrossrefno      = gs_ecrossrefno_read
            x_erch             = gs_erch
            x_contract         = gs_erdz-vertrag
            x_vkont_agg        = gv_vkonto
            x_dexservprov      = gv_empf
            x_dexservprovself  = gv_sender
            x_resend           = ''
          IMPORTING
            y_no_communication = gv_nocomm
            y_no_idoc_sent     = gv_noidocsend
          EXCEPTIONS
            general_fault      = 1
            OTHERS             = 2.
        IF sy-subrc <> 0.
          mac_msg_repeat co_msg_error space.
          CLEAR gs_error_tab.
          gs_error_tab-msg_typ = 'E'.
          gs_error_tab-msg_klasse = '/ADESSO/EDIFACT_INV'.
          gs_error_tab-msg_nr = '027'.
          gs_error_tab-msg_1 = gs_erdk-opbel.
          APPEND gs_error_tab TO gt_error_tab.
*         gv_error_log = 'X'.
          SET EXTENDED CHECK OFF.
          IF 1 = 2. MESSAGE e027(/adesso/edifact_inv). ENDIF.
          SET EXTENDED CHECK ON.
          CONTINUE.

        ELSE.
* save printdoc for paper print
          APPEND gs_erdk TO gt_erdk_paper.

          gs_error_tab-msg_typ = 'S'.
          gs_error_tab-msg_klasse = '/ADESSO/EDIFACT_INV'.
          gs_error_tab-msg_nr = '028'.
          gs_error_tab-msg_1 = gs_erdk-opbel.
          APPEND gs_error_tab TO gt_error_tab.
          SET EXTENDED CHECK OFF.
          IF 1 = 2. MESSAGE s028(/adesso/edifact_inv). ENDIF.
          SET EXTENDED CHECK ON.

* Set EDI send date
          gs_erdk-edisenddate = sy-datum.

          DO 100 TIMES.

            CALL FUNCTION 'ENQUEUE_EZ_ERDK'
              EXPORTING
                mode_erdk      = 'E'
                mandt          = sy-mandt
                opbel          = gs_erdk-opbel
                x_opbel        = ' '
                _scope         = '2'
                _wait          = ' '
                _collect       = ' '
              EXCEPTIONS
                foreign_lock   = 1
                system_failure = 2
                OTHERS         = 3.

            IF sy-subrc <> 0.

              WAIT UP TO 1 SECONDS.

            ELSE.

              MODIFY erdk FROM gs_erdk.

              IF sy-subrc NE 0.
*               Keine Aktion!
              ENDIF.

              CALL FUNCTION 'DEQUEUE_EZ_ERDK'
                EXPORTING
                  mode_erdk = 'E'
                  mandt     = sy-mandt
                  opbel     = gs_erdk-opbel
                  x_opbel   = ' '
                  _scope    = '3'
                  _synchron = ' '
                  _collect  = ' '.

              EXIT.

            ENDIF.

          ENDDO.

          IF gs_edi_abs IS NOT INITIAL.
*update Table /adesso/edi_abs
            gs_edi_abs-edisenddate = gs_erdk-edisenddate.

            DO 100 TIMES.

              CALL FUNCTION 'ENQUEUE_EZ_EDI_ABS'
                EXPORTING
                  mode_/adesso/edi_abs = 'E'
                  mandt                = sy-mandt
                  opbel                = gs_edi_abs-opbel.
              IF sy-subrc <> 0.
                WAIT UP TO 1 SECONDS.
              ELSE.
                EXIT.
              ENDIF.

            ENDDO.

            MODIFY /adesso/edi_abs FROM gs_edi_abs.

            IF sy-subrc = 0.
              CLEAR gs_edi_abs.
            ELSE.
              MESSAGE e095(/adesso/edifact_inv) WITH gs_edi_abs-opbel.
            ENDIF.

            CALL FUNCTION 'DEQUEUE_EZ_EDI_ABS'
              EXPORTING
                mode_/adesso/edi_abs = 'E'
                mandt                = sy-mandt
                opbel                = gs_edi_abs-opbel.

          ENDIF.
        ENDIF.
      ELSE.
        gv_not_sent = gv_not_sent + 1.
        CONTINUE.
      ENDIF.
    ENDLOOP.
    IF gv_not_sent NE 0 AND gv_sent EQ 0.
      gs_error_tab-msg_typ    = 'E'.
      gs_error_tab-msg_klasse = '/ADESSO/EDIFACT_INV'.
      gs_error_tab-msg_nr     = '036'.
      gs_error_tab-msg_1      = space.
      gs_error_tab-msg_2      = space.
      APPEND gs_error_tab TO gt_error_tab.
      SET EXTENDED CHECK OFF.
      IF 1 = 2. MESSAGE e036(/adesso/edifact_inv). ENDIF.
      SET EXTENDED CHECK ON.
    ENDIF.
  ENDIF.

* Papierdruck
  IF gv_error_log IS INITIAL.
    IF p_pdruck IS NOT INITIAL.
* Populate Attachment header
      CONCATENATE 'Druckbelegnummer' 'Erstellungsgrund'
      INTO gs_attach SEPARATED BY gc_con_tab.
      APPEND gs_attach TO gt_attach.
      MOVE gc_con_cret TO gs_attach.
      APPEND gs_attach TO gt_attach.

      CHECK gt_erdk_paper[] IS NOT INITIAL.

* Populate Attachment body
      LOOP AT gt_erdk_paper INTO gs_erdk.
* Only if printlock has been disabled
        IF gs_erdk-printlock IS INITIAL.
          READ TABLE gt_fkkvkp INTO gs_fkkvkp WITH KEY vkont = gs_erdk-vkont.
          READ TABLE gt_edivar INTO gs_edivar
            WITH KEY edivariante = gs_fkkvkp-zzedivar.
* Only if EDI Variante has an active papierversand- and drucksperre- option
          IF gs_edivar-papierversand IS NOT INITIAL
            AND gs_edivar-drucksperre IS NOT INITIAL.
            CASE gs_erdk-ergrd.
              WHEN '01'.
                CONCATENATE gs_erdk-opbel 'Verbrauchsabrechnung'
              INTO gs_attach SEPARATED BY gc_con_tab.
              WHEN '02'.
                CONCATENATE gs_erdk-opbel 'Abschlagsanforderung'
              INTO gs_attach SEPARATED BY gc_con_tab.
              WHEN '03'.
                CONCATENATE gs_erdk-opbel 'Teilrechnung'
              INTO gs_attach SEPARATED BY gc_con_tab.
              WHEN '04'.
                CONCATENATE gs_erdk-opbel 'Stornorechnung'
              INTO gs_attach SEPARATED BY gc_con_tab.
              WHEN '05'.
                CONCATENATE gs_erdk-opbel 'Sammelrechnung'
              INTO gs_attach SEPARATED BY gc_con_tab.
              WHEN '06'.
                CONCATENATE gs_erdk-opbel 'Vebr.+Teilrechnung'
              INTO gs_attach SEPARATED BY gc_con_tab.
              WHEN '07'.
                CONCATENATE gs_erdk-opbel 'Abschlagsänderungsbeleg'
              INTO gs_attach SEPARATED BY gc_con_tab.
              WHEN '08'.
                CONCATENATE gs_erdk-opbel 'AbschlagsanfIndustrKunde'
              INTO gs_attach SEPARATED BY gc_con_tab.
              WHEN OTHERS.
                CONCATENATE gs_erdk-opbel 'Aggregierte Rechnung'
              INTO gs_attach SEPARATED BY gc_con_tab.
            ENDCASE.
            APPEND gs_attach TO gt_attach.
            MOVE gc_con_cret TO gs_attach.
            APPEND gs_attach TO gt_attach.
          ELSE.
            CONTINUE.
          ENDIF.
        ELSE.
          CONTINUE.
        ENDIF.
      ENDLOOP.

      CLEAR: gv_tabix.
      DESCRIBE TABLE gt_attach LINES gv_tabix.
      IF gv_tabix LE 1.
        gs_error_tab-msg_typ    = 'E'.
        gs_error_tab-msg_klasse = '/ADESSO/EDIFACT_INV'.
        gs_error_tab-msg_nr     = '037'.
        gs_error_tab-msg_1      = space.
        gs_error_tab-msg_2      = space.
        APPEND gs_error_tab TO gt_error_tab.
        SET EXTENDED CHECK OFF.
        IF 1 = 2. MESSAGE e037(/adesso/edifact_inv). ENDIF.
        SET EXTENDED CHECK ON.
      ELSE.

        CLEAR gt_message[].
        gs_message = text-003.
        APPEND gs_message TO gt_message.

* Create filename
        CONCATENATE text-006 sy-datum INTO gv_filename.

* Send file by email as .xgs speadsheet
        PERFORM send_file_as_email_attachment
          USING p_email
                text-001
                text-002
                gv_filename
                text-006
                ' '
                ' '
          CHANGING gv_error
                   gv_receiver
                   gt_message
                   gt_attach.

        PERFORM initiate_mail_execute_program.
      ENDIF.
    ENDIF.
  ENDIF.

* Create MSGs
  IF gt_error_tab[] IS NOT INITIAL.
    CLEAR gs_error_tab.
    LOOP AT gt_error_tab INTO gs_error_tab.
      IF gs_error_tab-msg_typ = 'E'.
        mac_msg_putx co_msg_error gs_error_tab-msg_nr gs_error_tab-msg_klasse
        gs_error_tab-msg_1 gs_error_tab-msg_2 gs_error_tab-msg_3
        gs_error_tab-msg_4  space.
      ENDIF.
      IF gs_error_tab-msg_typ = 'S'.
        mac_msg_putx co_msg_success gs_error_tab-msg_nr gs_error_tab-msg_klasse
         gs_error_tab-msg_1 gs_error_tab-msg_2 gs_error_tab-msg_3
         gs_error_tab-msg_4  space.
      ENDIF.
    ENDLOOP.
  ENDIF.

* save log
  CALL FUNCTION 'MSG_ACTION'
    EXPORTING
      x_msg_handle         = gv_handle
      x_action             = co_msg_save
    EXCEPTIONS
      action_not_supported = 1
      handle_invalid       = 2
      not_found            = 3
      OTHERS               = 4.
  IF sy-subrc <> 0.
    mac_msg_repeat co_msg_error internal_error.
  ENDIF.

* Display the log (no batch)
  IF sy-batch IS INITIAL.

    CALL FUNCTION 'MSG_ACTION'
      EXPORTING
        x_msg_handle         = gv_handle
        x_action             = co_msg_dspl
      EXCEPTIONS
        action_not_supported = 1
        handle_invalid       = 2
        not_found            = 3
        OTHERS               = 4.
    IF sy-subrc <> 0.
      mac_msg_repeat co_msg_error internal_error.
    ENDIF.

  ENDIF.

* Close the log
  CALL FUNCTION 'MSG_CLOSE'
    EXPORTING
      x_msg_handle = gv_handle.

END-OF-SELECTION.
