*&---------------------------------------------------------------------*
*& Report  /ADESSO/ESERVICE_EDIFACT_UPD
*&
*&---------------------------------------------------------------------*
* Report zur Aktualisierung der Tabelle Eservice bzgl. die neue Serviceart
* zum Thema Rechnungslegung EDIFACT, sobald des entsp. Vertragskontos
* vom Sachbearbeiter mit der EDI Variante gekennzeichnet ist.
*
* Änderungshistorie:
* Datum       Benutzer  Grund
* ---------------------------------------------------------------------
REPORT /adesso/eservice_edifact_upd.

INCLUDE /adesso/eservice_edifact_top.    " top include

*-----------------------------------------------------------------------
* Selectionscreen
*-----------------------------------------------------------------------

SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN BEGIN OF BLOCK selbeginnpar WITH FRAME TITLE text-001.
PARAMETER:      p_vbeg AS CHECKBOX.
SELECT-OPTIONS: s_vkont  FOR  gs_fkkvkp-vkont NO INTERVALS OBLIGATORY.
PARAMETER:      p_kdate  TYPE eservice-service_start DEFAULT sy-datum,
                p_sparte TYPE eanl-sparte OBLIGATORY,
                p_prov   TYPE eservice-serviceid OBLIGATORY.
PARAMETER:      p_extnr TYPE balhdr-extnumber NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK selbeginnpar.

SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN BEGIN OF BLOCK selendpar WITH FRAME TITLE text-002.
PARAMETER:      p_vend  AS CHECKBOX,
                p_edate TYPE eservice-service_end DEFAULT sy-datum.
SELECTION-SCREEN END OF BLOCK selendpar.

INITIALIZATION.
**Authority Check
*  AUTHORITY-CHECK OBJECT 'S_TCODE' ID 'TCD' FIELD '/ADESSO/SERVICE_UPD'.
*  IF sy-subrc NE 0.
*    MESSAGE e172(00) WITH '/ADESSO/SERVICE_UPD'.
*  ENDIF.

AT SELECTION-SCREEN.
  IF p_vbeg IS INITIAL AND p_vend IS INITIAL.
    MESSAGE e000(/adesso/edifact_inv).
  ELSEIF p_vbeg IS NOT INITIAL AND p_vend IS NOT INITIAL.
    MESSAGE e001(/adesso/edifact_inv).
  ENDIF.

  IF p_vbeg IS NOT INITIAL AND p_kdate IS INITIAL.
    MESSAGE e002(/adesso/edifact_inv).
  ENDIF.

  IF p_vend IS NOT INITIAL AND p_edate IS INITIAL.
    MESSAGE e003(/adesso/edifact_inv).
  ENDIF.

  SELECT SINGLE * FROM eservprov INTO gs_eservprov WHERE
    serviceid = p_prov.
  IF sy-subrc <> 0.
    MESSAGE e022(/adesso/edifact_inv).
  ELSE.
    CASE p_sparte.
      WHEN '01'.
        IF gs_eservprov-service <> 'S100'.
          MESSAGE e023(/adesso/edifact_inv).
        ENDIF.
      WHEN '02'.
        IF gs_eservprov-service <> 'G100'.
          MESSAGE e023(/adesso/edifact_inv).
        ENDIF.
      WHEN OTHERS.
        MESSAGE e024(/adesso/edifact_inv).
    ENDCASE.
  ENDIF.
*-----------------------------------------------------------------------
* Start of selection
*-----------------------------------------------------------------------

START-OF-SELECTION.
*open message log
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

  IF p_kdate IS NOT INITIAL.
    gv_keydatum = p_kdate.
  ELSEIF p_edate IS NOT INITIAL.
    gv_keydatum = p_edate.
  ENDIF.

* get all contract-datas from ever using contract accounts
  SELECT * FROM ever INTO TABLE gt_ever
    WHERE  sparte = p_sparte AND
           vkonto IN s_vkont AND
           auszdat = '99991231'.
  IF sy-subrc <> 0.
    mac_msg_putx co_msg_error '004' '/ADESSO/EDIFACT_INV'
    space space space space space.
    SET EXTENDED CHECK OFF.
    IF 1 = 2. MESSAGE e004(/adesso/edifact_inv). ENDIF.
    SET EXTENDED CHECK ON.
  ENDIF.

* get euiinstln structure for each installation
  SELECT * FROM euiinstln INTO TABLE gt_euiinstln
    FOR ALL ENTRIES IN gt_ever
    WHERE anlage = gt_ever-anlage AND
          dateto > gv_keydatum AND
          datefrom <= gv_keydatum.
  IF sy-subrc <> 0.
    mac_msg_putx co_msg_error '005' '/ADESSO/EDIFACT_INV'
     space space space space space.
    SET EXTENDED CHECK OFF.
    IF 1 = 2. MESSAGE e005(/adesso/edifact_inv). ENDIF.
    SET EXTENDED CHECK ON.
  ENDIF.

* get active services for each installation
  SELECT * FROM eservice INTO TABLE gt_eservice
    FOR ALL ENTRIES IN gt_euiinstln
          WHERE int_ui = gt_euiinstln-int_ui AND
                service_end = '99991231'.
  IF sy-subrc <> 0.
    mac_msg_putx co_msg_error '009' '/ADESSO/EDIFACT_INV'
    space space space space space.
    SET EXTENDED CHECK OFF.
    IF 1 = 2. MESSAGE e009(/adesso/edifact_inv). ENDIF.
    SET EXTENDED CHECK ON.
  ENDIF.

  LOOP AT gt_ever INTO gs_ever.
* get euiinstln structure for each installation
    READ TABLE gt_euiinstln INTO gs_euiinstln WITH KEY
      anlage = gs_ever-anlage.

* get ext_ui
* No need to include date_to and time_to into WHERE, because we only need the ext_ui description
    SELECT SINGLE * FROM euitrans INTO gs_euitrans WHERE int_ui = gs_euiinstln-int_ui.

    IF p_vbeg IS NOT INITIAL.
* set new eservice structure with the new service line, which is going to be inserted in eservice table
      gs_auto-eserviced-vertrag       = space.
      gs_auto-eserviced_use           = 'X'.
      gs_auto-eserviced-mandt         = sy-mandt.
      gs_auto-eserviced-int_ui        = gs_euiinstln-int_ui.
      gs_auto-eserviced-service_start = p_kdate.
      gs_auto-eserviced-service_end   = '99991231'.
      IF p_sparte = '01'.
        gs_auto-eserviced-service = 'S100'.
      ELSEIF p_sparte = '02'.
        gs_auto-eserviced-service = 'G100'.
      ELSE.
        CONTINUE.
      ENDIF.
      gs_auto-eserviced-sparte        = p_sparte.
      gs_auto-eserviced-serviceid     = p_prov.

* first make a connection between the new service and service provider.
      PERFORM update_eservprofservice USING gs_auto
                                            p_prov
                                            p_kdate
                                            gs_euiinstln.

* bevor insert the new structure, check active old entry of service S100 or G0100
      READ TABLE gt_eservice INTO gs_eservice_old
        WITH KEY  int_ui = gs_euiinstln-int_ui
                  service = gs_auto-eserviced-service.
      IF sy-subrc = 0.
* modify old entry of servce S100 or G100.
        gs_eservice_old-service_end = p_kdate - 1.

* enqueue eservice
        CALL FUNCTION 'ENQUEUE_E_ESERVICE'
          EXPORTING
            mode_eservice  = 'E'
            mandt          = sy-mandt
            vertrag        = gs_eservice_old-vertrag
            x_vertrag      = ' '
            _scope         = '2'
            _wait          = ' '
            _collect       = ' '
          EXCEPTIONS
            foreign_lock   = 1
            system_failure = 2
            OTHERS         = 3.
        IF sy-subrc = 0.
          mac_msg_putx co_msg_error '031' '/ADESSO/EDIFACT_INV'
            gs_eservice-vertrag space
            space space space.
          SET EXTENDED CHECK OFF.
          IF 1 = 2. MESSAGE e031(/adesso/edifact_inv). ENDIF.
          SET EXTENDED CHECK ON.
          CONTINUE.
        ENDIF.

        UPDATE eservice FROM gs_eservice_old.

* dequeue eservice
        CALL FUNCTION 'DEQUEUE_E_ESERVICE'
          EXPORTING
            mode_eservice = 'E'
            mandt         = sy-mandt
            vertrag       = gs_eservice_old-vertrag
            x_vertrag     = ' '
            _scope        = '3'
            _synchron     = ' '
            _collect      = ' '.


        IF sy-subrc = 0.
* insert the new service S100/g100
          PERFORM eservice_insert USING gs_auto
                                        p_kdate
                                  CHANGING gv_updatedone
                                           gs_new_eservice
                                           gv_error.

          PERFORM error_handling USING gv_error
                                       gs_auto
                                       gs_euiinstln
                                       gs_ever
                                       gs_new_eservice
                                       gs_euitrans.
          CONTINUE.
        ELSE.
          mac_msg_putx co_msg_error '008' '/ADESSO/EDIFACT_INV'
            gs_ever-vkonto gs_euitrans-ext_ui
            space space space.
          SET EXTENDED CHECK OFF.
          IF 1 = 2. MESSAGE e008(/adesso/edifact_inv). ENDIF.
          SET EXTENDED CHECK ON.
          CONTINUE.
        ENDIF.
      ELSE.
* there is no entry in ESERVICE of service S100/G100 to the pod
* insert the new eservice structure
        PERFORM eservice_insert USING gs_auto
                                      p_kdate
                                CHANGING gv_updatedone
                                         gs_new_eservice
                                         gv_error.

        PERFORM error_handling USING gv_error
                                       gs_auto
                                       gs_euiinstln
                                       gs_ever
                                       gs_new_eservice
                                       gs_euitrans.
        CONTINUE.
      ENDIF.
    ENDIF.

    IF p_vend IS NOT INITIAL.
      IF p_sparte = '01'.
        READ TABLE gt_eservice INTO gs_eservice WITH KEY int_ui = gs_euiinstln-int_ui
                                                         service = 'S100'.
      ELSEIF p_sparte = '02'.
        READ TABLE gt_eservice INTO gs_eservice WITH KEY int_ui = gs_euiinstln-int_ui
                                                         service = 'G100'.
      ENDIF.
      IF gs_eservice IS INITIAL.
        mac_msg_putx co_msg_error '010' '/ADESSO/EDIFACT_INV'
            gs_euitrans-ext_ui space
            space space space.
        SET EXTENDED CHECK OFF.
        IF 1 = 2. MESSAGE e010(/adesso/edifact_inv). ENDIF.
        SET EXTENDED CHECK ON.
        CONTINUE.
      ELSE.
        gs_eservice-service_end = p_edate.

* enqueue eservice
        CALL FUNCTION 'ENQUEUE_E_ESERVICE'
          EXPORTING
            mode_eservice  = 'E'
            mandt          = sy-mandt
            vertrag        = gs_eservice-vertrag
            x_vertrag      = ' '
            _scope         = '2'
            _wait          = ' '
            _collect       = ' '
          EXCEPTIONS
            foreign_lock   = 1
            system_failure = 2
            OTHERS         = 3.

        IF sy-subrc <> 0.
          mac_msg_putx co_msg_error '031' '/ADESSO/EDIFACT_INV'
            gs_eservice-vertrag space
            space space space.
          SET EXTENDED CHECK OFF.
          IF 1 = 2. MESSAGE e031(/adesso/edifact_inv). ENDIF.
          SET EXTENDED CHECK ON.
          CONTINUE.
        ENDIF.

        UPDATE eservice FROM gs_eservice.

* dequeue eservice
        CALL FUNCTION 'DEQUEUE_E_ESERVICE'
          EXPORTING
            mode_eservice = 'E'
            mandt         = sy-mandt
            vertrag       = gs_eservice-vertrag
            x_vertrag     = ' '
            _scope        = '3'
            _synchron     = ' '
            _collect      = ' '.

        IF sy-subrc = 0.
          mac_msg_putx co_msg_success '011' '/ADESSO/EDIFACT_INV'
            gs_eservice-service gs_euitrans-ext_ui
            space space space.
          SET EXTENDED CHECK OFF.
          IF 1 = 2. MESSAGE s011(/adesso/edifact_inv). ENDIF.
          SET EXTENDED CHECK ON.
          CONTINUE.
        ELSE.
          mac_msg_putx co_msg_error '008' '/ADESSO/EDIFACT_INV'
            gs_ever-vkonto gs_euitrans-ext_ui
            space space space.
          SET EXTENDED CHECK OFF.
          IF 1 = 2. MESSAGE e008(/adesso/edifact_inv). ENDIF.
          SET EXTENDED CHECK ON.
          CONTINUE.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
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

  INCLUDE  /adesso/eservice_edifact_f01.
