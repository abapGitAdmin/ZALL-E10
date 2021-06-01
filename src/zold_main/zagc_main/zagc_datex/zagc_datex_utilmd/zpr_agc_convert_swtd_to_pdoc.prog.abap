*&---------------------------------------------------------------------*
*& Report  ZPR_AGC_CONVERT_SWTD_TO_PDOC
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT zpr_agc_convert_swtd_to_pdoc.

TABLES:  eideswtdoc.

DATA: lv_count             TYPE          i,
      lv_error             TYPE          kennzx,
      lv_type              TYPE          /idxgc/de_proc_step_type,
      lv_new_pdoc          TYPE          kennzx,
      lv_data_saved        TYPE          kennzx,
      lv_activity_key      TYPE          eidegenerickey,
      lv_message           TYPE          /idxgc/s_pdoc_log_msg,
      lv_logid             TYPE          guid_32,
      lv_bal_message(180)  TYPE          c,

      ls_eideswtdoc        TYPE          eideswtdoc,
      ls_eideswtdocadddata TYPE          eideswtdocadddata,
      ls_pdoc_data         TYPE          /idxgc/s_pdoc_data,
      ls_pdoc_data_tmp     TYPE          /idxgc/s_pdoc_data,
      ls_pdoc_data_new     TYPE          /idxgc/s_pdoc_data,
      ls_msg_data          TYPE          /idxgc/s_msg_data_all,
      ls_header            TYPE          bal_s_log,
      ls_msg               TYPE          bal_s_msg,

      lt_eideswtdoc        TYPE TABLE OF eideswtdoc,
      lt_msgdata           TYPE          teideswtmsgdata,
      lt_msgdataco         TYPE          teideswtmsgdataco,
      lt_msgadddata        TYPE          teideswtmsgadddata,
      lt_msgdata_single    TYPE          teideswtmsgdata,
      lt_msgdataco_single  TYPE          teideswtmsgdataco,
      lt_msgadddata_single TYPE          teideswtmsgadddata,
      lt_zlw_extmsgdata    TYPE TABLE OF zlw_extmsgdata,

      bal_log_timestamp    TYPE          /idxgc/de_proc_step_timestamp,

      lr_previous          TYPE REF TO   /idxgc/cx_process_error,
      lr_switchdoc         TYPE REF TO   cl_isu_ide_switchdoc,

      lx_previous          TYPE REF TO   /idxgc/cx_general.

CONSTANTS: pc_very_high TYPE bal_s_msg-probclass VALUE '1',
           pc_high      TYPE bal_s_msg-probclass VALUE '2',
           pc_medium    TYPE bal_s_msg-probclass VALUE '3',
           pc_low       TYPE bal_s_msg-probclass VALUE '4',
           pc_none      TYPE bal_s_msg-probclass VALUE ' '.

FIELD-SYMBOLS: <fs_eideswtdoc>        TYPE eideswtdoc,
               <fs_msgdata>           TYPE eideswtmsgdata,
               <fs_msgdata2>          TYPE eideswtmsgdata,
               <fs_msgadddata>        TYPE eideswtmsgadddata,
               <fs_msgdataco>         TYPE eideswtmsgdataco,
               <fs_pdoc_msg_data>     TYPE /idxgc/s_msg_data_all,
               <fs_pdoc_msg_data_new> TYPE /idxgc/s_msg_data_all.

*Parameter:
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.

SELECT-OPTIONS: s_num    FOR eideswtdoc-switchnum,
                s_status FOR eideswtdoc-status,
                s_type   FOR eideswtdoc-switchtype,
                s_view   FOR eideswtdoc-swtview,
                s_mid    FOR eideswtdoc-moveindate,
                s_mod    FOR eideswtdoc-moveoutdate,
                s_partn  FOR eideswtdoc-partner,
                s_spo    FOR eideswtdoc-service_prov_old,
                s_spn    FOR eideswtdoc-service_prov_new,
                s_distr  FOR eideswtdoc-distributor.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.
PARAMETERS:     p_test   TYPE kennzx DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK b2.
SELECTION-SCREEN END OF BLOCK b1.


*-----------------------------------------------------------------------*

INITIALIZATION.

*-----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM open_log.

  PERFORM select.

  IF lt_eideswtdoc IS NOT INITIAL.
    PERFORM work.
  ENDIF.

  PERFORM display_log.

END-OF-SELECTION.
*-----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  SELECT
*&---------------------------------------------------------------------*
*       Suche alle aktiven WB ohne PDOC
*----------------------------------------------------------------------*
FORM select.

  SELECT * FROM eideswtdoc INTO TABLE lt_eideswtdoc
    WHERE switchnum        IN s_num
      AND status           IN s_status
      AND switchtype       IN s_type
      AND swtview          IN s_view
      AND moveindate       IN s_mid
      AND moveoutdate      IN s_mod
      AND partner          IN s_partn
      AND service_prov_old IN s_spo
      AND service_prov_new IN s_spn
      AND distributor      IN s_distr.

  CLEAR lv_count.
  lv_count = lines( lt_eideswtdoc ).
  IF lv_count = 0.
    MESSAGE i899(e9) WITH 'Keine Wechselbelege im Wertebereich' INTO lv_bal_message.
    PERFORM message_log USING pc_low.
  ELSE.
    MESSAGE i899(e9) WITH lv_count 'Wechselbelege im Wertebereich' INTO lv_bal_message.
    PERFORM message_log USING pc_low.
  ENDIF.

  IF p_test IS NOT INITIAL.
    MESSAGE w899(e9) WITH '--------Simulationsmodus--------' INTO lv_bal_message.
    PERFORM message_log USING pc_low.
  ENDIF.

ENDFORM.                    " SELEKTION

*&---------------------------------------------------------------------*
*&      Form  work
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM work.

* Wechselbelege verarbeiten
  LOOP AT lt_eideswtdoc ASSIGNING <fs_eideswtdoc>.
* Fall 1: PDOC existiert, alle Nachrichten haben eine Prozessschrittnummer
* Fall 2: PDOC existiert, eine oder mehrere Nachrichten haben keine Prozessschrittnummer
* Fall 3: PDOC existiert nicht

* Vorgehensweise:
* Fall 1: OK
* Fall 2: "fehlerhafte" Nachricht erneut mappen
* Fall 3: Neues PDOC erstellen

    CLEAR ls_pdoc_data.
    CLEAR lv_error.

    CALL METHOD /idxgc/cl_process_document_db=>/idxgc/if_process_document_db~clear_buffer.

    TRY.
        CALL METHOD /idxgc/cl_process_document_db=>/idxgc/if_process_document_db~select_pdoc
          EXPORTING
            iv_process_ref    = <fs_eideswtdoc>-switchnum
            iv_message_data   = /idxgc/if_constants=>gc_true
            iv_no_swtdoc_flag = /idxgc/if_constants=>gc_true
          IMPORTING
            es_pdoc_data      = ls_pdoc_data.
      CATCH /idxgc/cx_process_error INTO lr_previous.
*        message id sy-msgid type sy-msgty number sy-msgno
*         with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 raising general_error.
    ENDTRY.

    IF ls_pdoc_data IS NOT INITIAL.
      LOOP AT ls_pdoc_data-msg_data ASSIGNING <fs_pdoc_msg_data>
        WHERE proc_step_no IS INITIAL.
        "check
      ENDLOOP.
      IF sy-subrc <> 0 AND ls_pdoc_data-msg_data[] IS NOT INITIAL.
*       Fall 1
        PERFORM pdoc_ok.

      ELSE.
*       Fall 2
        PERFORM try_remap_message.
      ENDIF.
    ELSE.
*     Fall3
      PERFORM create_new_pdoc.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "work

*------------------------------------------------------------------------------*

*-------------SUB_FORMS--------------------------------------------------------*

*------------------------------------------------------------------------------*

FORM get_single_msg_add_co TABLES it_msgdata           TYPE teideswtmsgdata
                                  it_msgadddata        TYPE teideswtmsgadddata
                                  it_msgdataco         TYPE teideswtmsgdataco
                                  et_msgdata_single    TYPE teideswtmsgdata
                                  et_msgadddata_single TYPE teideswtmsgadddata
                                  et_msgdataco_single  TYPE teideswtmsgdataco
                            USING msgdatanum           TYPE eideswtmdnum.

  CLEAR: et_msgdata_single,
         et_msgdata_single[],
         et_msgadddata_single,
         et_msgadddata_single[],
         et_msgdataco_single,
         et_msgdataco_single[].

  LOOP AT it_msgdata ASSIGNING <fs_msgdata2> WHERE msgdatanum EQ msgdatanum.
    APPEND <fs_msgdata2> TO et_msgdata_single.
  ENDLOOP.

  LOOP AT it_msgadddata ASSIGNING <fs_msgadddata> WHERE msgdatanum EQ msgdatanum.
    APPEND <fs_msgadddata> TO et_msgadddata_single.
  ENDLOOP.

  LOOP AT it_msgdataco ASSIGNING <fs_msgdataco> WHERE msgdatanum EQ msgdatanum.
    APPEND <fs_msgdataco> TO et_msgdataco_single.
  ENDLOOP.

ENDFORM.                    "get_single_msg_add_co

*&---------------------------------------------------------------------*
*&      Form  get_and_map_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_and_map_data.

  DATA: ls_proc TYPE /idxgc/proc,
        ls_bmid TYPE zagc_det_bmid.

  FIELD-SYMBOLS: <fs_proc_step_data_tmp> TYPE /idxgc/s_msg_data_all.

* Instanz zum Wechselbeleg erzeugen
  CALL METHOD cl_isu_ide_switchdoc=>select
    EXPORTING
      x_switchnum     = <fs_eideswtdoc>-switchnum
      x_wmode         = cl_isu_wmode=>co_display
    RECEIVING
      y_switchdoc     = lr_switchdoc
    EXCEPTIONS
      not_found       = 1
      parameter_error = 2
      not_unique      = 3
      general_fault   = 4
      foreign_lock    = 5
      not_authorized  = 6
      OTHERS          = 7.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_bal_message.
    PERFORM message_log USING pc_low.
  ENDIF.

*Wechselbelegkopfdaten selektieren
  ls_eideswtdoc = lr_switchdoc->get_all_properties( ).

  lr_switchdoc->get_all_properties_adddata( IMPORTING y_swtdoc_adddata = ls_eideswtdocadddata ).
  lr_switchdoc->get_msgdata( IMPORTING y_tswtmsgdata = lt_msgdata
                                       y_tswtmsgdataco = lt_msgdataco
                                       y_tswtmsg_adddata = lt_msgadddata ).

  lr_switchdoc->close( ).

  CLEAR: ls_msg_data, ls_pdoc_data_new, ls_pdoc_data_tmp.

  SORT lt_msgdata BY erdat msgdate msgtime.

  LOOP AT lt_msgdata ASSIGNING <fs_msgdata>.
*   Schritttyp setzen
    IF <fs_msgdata>-category = 'Z99' AND ls_eideswtdoc = '98'.
      lv_type = /idxgc/if_constants_add=>gc_proc_step_typ_first.
    ELSE.
      IF sy-tabix = 1.
        lv_type = /idxgc/if_constants_add=>gc_proc_step_typ_first.
      ELSEIF <fs_msgdata>-direction EQ /idxgc/if_constants_add=>gc_idoc_direction_inbound. "1
        lv_type = /idxgc/if_constants_add=>gc_proc_step_typ_inbound.
      ELSEIF <fs_msgdata>-direction EQ /idxgc/if_constants_add=>gc_idoc_direction_outbound. "2
        lv_type = /idxgc/if_constants_add=>gc_proc_step_typ_outbound.
      ENDIF.
    ENDIF.

*   Einzelzeilen MSGDATA/MSGDATADD/MSGDATACO selektieren
    PERFORM get_single_msg_add_co TABLES lt_msgdata
                                         lt_msgadddata
                                         lt_msgdataco
                                         lt_msgdata_single
                                         lt_msgadddata_single
                                         lt_msgdataco_single
                                  USING  <fs_msgdata>-msgdatanum.

*   EXTMSGDATA Einträge selektieren und ebenfalls mappen
    SELECT * FROM zlw_extmsgdata INTO TABLE lt_zlw_extmsgdata WHERE guiid = <fs_msgdata>-zz_guid_ext.

*** Map Switchdoc and Msgdata to PDOC-Data
    CALL METHOD zcl_agc_datex_utility=>map_isu_data_to_pdoc
      EXPORTING
        is_pdoc_hdr     = ls_eideswtdoc
        is_pdoc_add     = ls_eideswtdocadddata
        it_msg_hdr      = lt_msgdata_single
        it_msg_add      = lt_msgadddata_single
        it_msg_comments = lt_msgdataco_single
        it_msg_ext      = lt_zlw_extmsgdata
      IMPORTING
        es_pdoc_data    = ls_pdoc_data_tmp.

    "Proc-ID ermitteln
    IF ls_eideswtdoc-switchtype = '94' AND sy-mandt = '210' AND <fs_msgdata>-category = 'E01'.
      ls_proc-proc_id = '9912'.
      ls_pdoc_data_tmp-proc_id = ls_proc-proc_id.
    ELSEIF ls_eideswtdoc-switchtype = '94' AND sy-mandt = '110' AND <fs_msgdata>-category = 'E01'.
      ls_proc-proc_id = '9913'.
      ls_pdoc_data_tmp-proc_id = ls_proc-proc_id.
    ELSE.
      ls_proc = zcl_agc_datex_utility=>determine_proc_id( iv_switchtype = ls_eideswtdoc-switchtype iv_swtview = ls_eideswtdoc-swtview ).
      ls_pdoc_data_tmp-proc_id = ls_proc-proc_id.
    ENDIF.

    "Prozessversion ermitteln
    ls_pdoc_data_tmp-proc_version = zcl_agc_datex_utility=>determine_proc_version( iv_proc_id = ls_proc-proc_id iv_proc_date = sy-datum iv_switchnum = ls_eideswtdoc-switchnum ).

    "BMID ermitteln
    ls_bmid = zcl_agc_datex_utility=>determine_bmid( is_msgdata = <fs_msgdata> is_eideswtdoc = ls_eideswtdoc iv_proc_step_type = lv_type ).

    READ TABLE ls_pdoc_data_tmp-msg_data INDEX 1 ASSIGNING <fs_proc_step_data_tmp>.

    IF <fs_proc_step_data_tmp> IS ASSIGNED.
      <fs_proc_step_data_tmp>-bmid = ls_bmid-bmid.

      "Prozessschritt ermitteln
      <fs_proc_step_data_tmp>-proc_step_no = zcl_agc_datex_utility=>determine_proc_step_no( iv_proc_step_type = lv_type
                                                                                            iv_bmid           = ls_bmid-bmid
                                                                                            iv_proc_version   = ls_pdoc_data_tmp-proc_version
                                                                                            iv_proc_id        = ls_pdoc_data_tmp-proc_id ).

    ENDIF.

    IF ls_pdoc_data_new IS INITIAL.
      "Erste Nachricht innerhaln des Wechselbelegs
      ls_pdoc_data_new = ls_pdoc_data_tmp.
    ELSE.
      "Weitere Nachrichten innerhalb des Wechselbelegs -> Hier brauchen auch die Kopfdaten nicht mehr aktualisiert werden.
      APPEND <fs_proc_step_data_tmp> TO ls_pdoc_data_new-msg_data.
    ENDIF.

    CLEAR: ls_msg_data, ls_pdoc_data_tmp, ls_pdoc_data_tmp.
    UNASSIGN <fs_proc_step_data_tmp>.

  ENDLOOP.

ENDFORM.                    "get_and_map_data

*&---------------------------------------------------------------------*
*&      Form  try_remap_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM try_remap_message.
  PERFORM get_and_map_data.
* Entferne korrekte Nachichten
  LOOP AT ls_pdoc_data-msg_data ASSIGNING <fs_pdoc_msg_data> WHERE proc_step_no IS NOT INITIAL.
    DELETE ls_pdoc_data-msg_data.
  ENDLOOP.
* Bestimme fehlerhafte Nachricht im aktuellen PDOC
  LOOP AT ls_pdoc_data-msg_data ASSIGNING <fs_pdoc_msg_data> WHERE proc_step_no IS INITIAL.
*   Bestimme dazu die neu-gemappte Nachricht
    LOOP AT ls_pdoc_data_new-msg_data ASSIGNING <fs_pdoc_msg_data_new> WHERE msgdatanum EQ <fs_pdoc_msg_data>-msgdatanum AND
                                                                             proc_step_no IS NOT INITIAL.
*     Update Message
      <fs_pdoc_msg_data> = <fs_pdoc_msg_data_new>.
      lv_new_pdoc   = /idxgc/if_constants=>gc_false.
      lv_data_saved = /idxgc/if_constants=>gc_true.
      PERFORM update_pdoc.
    ENDLOOP.
    IF sy-subrc <> 0 AND ls_pdoc_data-msg_data[] IS NOT INITIAL.
*       Fehler beim Mappen
      MESSAGE w899(e9) WITH 'Nachrichtendaten zum bestehenden PDOC' <fs_eideswtdoc>-switchnum 'unvollständig' INTO lv_bal_message.
      PERFORM message_log USING pc_low.
      lv_error = 'X'.
      RETURN.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "try_map_message

*&---------------------------------------------------------------------*
*&      Form  pdoc_ok
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM pdoc_ok.
  MESSAGE i899(e9) WITH 'PDOC zum WB' <fs_eideswtdoc>-switchnum 'existiert bereits.' INTO lv_bal_message.
  PERFORM message_log USING pc_low.
ENDFORM.                    "pdoc_ok

*&---------------------------------------------------------------------*
*&      Form  create_new_pdoc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM create_new_pdoc.
* Switchdoc-Daten von DB holen
  PERFORM get_and_map_data.

* Nachrichten prüfen
  LOOP AT ls_pdoc_data_new-msg_data ASSIGNING <fs_pdoc_msg_data_new> WHERE proc_step_no IS INITIAL.
*   Fehler beim Mappen von Nachrichtendaten
    MESSAGE e899(e9) WITH 'Nachrichtendaten aus WB' <fs_eideswtdoc>-switchnum 'konnten nicht erfolreich gemappt werden.' INTO lv_bal_message.
    PERFORM message_log USING pc_low.
    lv_error = 'X'.
    EXIT.
  ENDLOOP.
  IF sy-subrc <> 0 AND ls_pdoc_data_new-msg_data[] IS NOT INITIAL.
    MOVE ls_pdoc_data_new TO ls_pdoc_data.
    lv_new_pdoc   = 'X'.
    lv_data_saved = /idxgc/if_constants=>gc_false.
*   PDOC in DB speichern
    PERFORM update_pdoc.
  ELSE.
    MESSAGE e899(e9) WITH 'Nachrichtendaten für neues PDOC konnten vom WB: ' <fs_eideswtdoc>-switchnum 'nicht gemappt werden.' INTO lv_bal_message.
    PERFORM message_log USING pc_low.
    lv_error = 'X'.
  ENDIF.
ENDFORM.                    "create_new_pdoc

*&---------------------------------------------------------------------*
*&      Form  set_swtdoc_activity
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->SWITCHNUM  text
*----------------------------------------------------------------------*
FORM set_swtdoc_activity USING switchnum TYPE eideswtnum.

  IF NOT switchnum IS INITIAL.
    WRITE switchnum TO lv_activity_key.
    CALL METHOD cl_isu_switchdoc=>s_set
      EXPORTING
        x_switchnum     = switchnum
        x_activity      = 'ZG6'
        x_status        = if_isu_ide_switch_constants=>co_stat_checked
        x_object        = /idxgc/if_constants=>gc_object_pdoc_bor
        x_objectkey     = lv_activity_key
        x_no_event      = cl_isu_flag=>co_true
      EXCEPTIONS
        not_found       = 1
        parameter_error = 2
        general_fault   = 3
        not_authorized  = 4
        OTHERS          = 5.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

ENDFORM.                    "set_swtdoc_activity

*&---------------------------------------------------------------------*
*&      Form  update_pdoc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM update_pdoc.

* Clear Buffer spielt für neue PDOCs keine Rolle, für bestehende PDOCs schon.
* Damit werden z.B. alte Tabelleninhalte aus der fehlerhaften Nachricht entfernt.
  IF lv_new_pdoc IS INITIAL.
    CALL METHOD /idxgc/cl_process_document_db=>/idxgc/if_process_document_db~clear_buffer.
  ENDIF.

  TRY.
      IF p_test IS INITIAL.
        CALL METHOD /idxgc/cl_process_document_db=>/idxgc/if_process_document_db~update_pdoc
          EXPORTING
            is_pdoc_data  = ls_pdoc_data
            iv_new_pdoc   = lv_new_pdoc
            iv_data_saved = lv_data_saved
            iv_extern     = /idxgc/if_constants=>gc_false.
      ENDIF.
    CATCH /idxgc/cx_process_error.
      IF lv_new_pdoc IS INITIAL.
        MESSAGE e899(e9) WITH 'Fehler beim Erstellen erstellen eines neuen PDOC zum WB: ' <fs_eideswtdoc>-switchnum INTO lv_bal_message.
        PERFORM message_log USING pc_low.
      ELSE.
        MESSAGE w899(e9) WITH 'Fehler beim Speichern des PDOC: ' <fs_eideswtdoc>-switchnum INTO lv_bal_message.
        PERFORM message_log USING pc_low.
      ENDIF.
      lv_error = 'X'.
  ENDTRY.

  IF lv_error IS INITIAL.
    IF lv_new_pdoc IS INITIAL.
      MESSAGE i899(e9) WITH 'Update von Nachrichtendaten im PDOC ' <fs_eideswtdoc>-switchnum 'erfolgreich.' INTO lv_bal_message.
      PERFORM message_log USING pc_low.
    ELSE.
      MESSAGE i899(e9) WITH 'PDOC erfolgreich erstellt vom WB' <fs_eideswtdoc>-switchnum '' INTO lv_bal_message.
      PERFORM message_log USING pc_low.
      IF p_test IS INITIAL.
        CALL METHOD /idxgc/cl_process_document_db=>/idxgc/if_process_document_db~clear_buffer.
        PERFORM set_swtdoc_activity USING <fs_eideswtdoc>-switchnum.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    "update_pdoc

*&---------------------------------------------------------------------*
*&      Form  UPDATE_CHAGEDOC_SWTVIEW
*&---------------------------------------------------------------------*
FORM update_chagedoc_swtview CHANGING cs_eideswtdoc TYPE eideswtdoc.
  DATA lr_switchdoc TYPE REF TO cl_isu_ide_switchdoc.

  CASE ls_eideswtdoc-swtview.
    WHEN '91'. cs_eideswtdoc-swtview = '01'.
    WHEN '92'. cs_eideswtdoc-swtview = '02'.
  ENDCASE.

  CALL METHOD cl_isu_ide_switchdoc=>select
    EXPORTING
      x_switchnum     = cs_eideswtdoc-switchnum
      x_wmode         = cl_isu_wmode=>co_change
    RECEIVING
      y_switchdoc     = lr_switchdoc
    EXCEPTIONS
      not_found       = 1
      parameter_error = 2
      not_unique      = 3
      general_fault   = 4
      foreign_lock    = 5
      not_authorized  = 6
      OTHERS          = 7.

  IF sy-subrc <> 0.
    lv_error = abap_true.
    EXIT.
  ENDIF.

  lr_switchdoc->set_property( EXPORTING x_property = 'SWTVIEW' x_value = ls_eideswtdoc-swtview
                              EXCEPTIONS invalid_property = 1 invalid_value = 2 not_open = 3 not_possible = 4 OTHERS = 5 ).
  IF sy-subrc <> 0.
    lv_error = abap_true.
    EXIT.
  ENDIF.

  lr_switchdoc->save( EXPORTING x_no_commit = abap_false
                      EXCEPTIONS not_open = 1 number_range_error = 2 OTHERS = 3 ).
  IF sy-subrc <> 0.
    lv_error = abap_true.
  ENDIF.
ENDFORM.                    " UPDATE_CHAGEDOC_SWTVIEW
*&---------------------------------------------------------------------*
*&      Form  OPEN_LOG
*&---------------------------------------------------------------------*
FORM open_log .

  CALL FUNCTION 'GUID_CREATE'
    IMPORTING
      ev_guid_32 = lv_logid.

**Log objekt bestimmen
  ls_header-object     = 'ZAGC'.       " Anwendungsprotokoll Wechselbelege
  ls_header-subobject  = 'SWT2PDOC'.                " Übersicht
  ls_header-extnumber  = lv_logid.                  " Guid
  ls_header-alprog     = sy-cprog.                 " Aufrufendes Programm
  ls_header-altcode    = sy-tcode.                 " Aktueller Transaktionscode

  CALL FUNCTION 'BAL_LOG_CREATE'
    EXPORTING
      i_s_log                 = ls_header
    EXCEPTIONS
      log_header_inconsistent = 1
      OTHERS                  = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " OPEN_LOG

*&---------------------------------------------------------------------*
*&      Form  MESSAGE_LOG
*&---------------------------------------------------------------------*
FORM message_log  USING VALUE(i_probclass) TYPE bal_s_msg-probclass.

  ls_msg-msgty     = sy-msgty.
  ls_msg-msgid     = sy-msgid.
  ls_msg-msgno     = sy-msgno.
  ls_msg-msgv1     = sy-msgv1.
  ls_msg-msgv2     = sy-msgv2.
  ls_msg-msgv3     = sy-msgv3.
  ls_msg-msgv4     = sy-msgv4.
  ls_msg-probclass = i_probclass.

  CALL FUNCTION 'BAL_LOG_MSG_ADD'
    EXPORTING
      i_s_msg       = ls_msg
    EXCEPTIONS
      log_not_found = 0
      OTHERS        = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " MESSAGE_LOG

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_LOG
*&---------------------------------------------------------------------*
FORM display_log .

  CALL FUNCTION 'BAL_DB_SAVE'
    EXPORTING
      i_save_all       = 'X'
    EXCEPTIONS
      log_not_found    = 1
      save_not_allowed = 2
      numbering_error  = 3
      OTHERS           = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
    EXCEPTIONS
      profile_inconsistent = 1
      internal_error       = 2
      no_data_available    = 3
      no_authority         = 4
      OTHERS               = 5.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " DISPLAY_LOG
