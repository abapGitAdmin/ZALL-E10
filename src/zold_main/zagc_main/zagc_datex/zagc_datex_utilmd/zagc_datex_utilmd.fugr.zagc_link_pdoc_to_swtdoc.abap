FUNCTION zagc_link_pdoc_to_swtdoc.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(EVENT) LIKE  SWETYPECOU-EVENT
*"     VALUE(RECTYPE) LIKE  SWETYPECOU-RECTYPE
*"     VALUE(OBJTYPE) LIKE  SWETYPECOU-OBJTYPE
*"     VALUE(OBJKEY) LIKE  SWEINSTCOU-OBJKEY
*"  TABLES
*"      EVENT_CONTAINER STRUCTURE  SWCONT
*"  EXCEPTIONS
*"      NO_WF
*"      GENERAL_FAULT
*"----------------------------------------------------------------------


  DATA: lv_switchnum      TYPE        eideswtnum,
        lv_event          TYPE        swo_event,
        lv_objtype        TYPE        swo_objtyp,
        lv_objkey         TYPE        swo_typeid,
        lv_activity_key   TYPE        eidegenerickey,
        lv_active         TYPE        char80,
        lv_event_new      TYPE        swo_event,
        lv_msgnum         TYPE        eideswtmdnum,
        lv_bmid           TYPE        /idxgc/de_bmid,

        ls_eideswtdoc     TYPE        eideswtdoc,
        ls_eideswtmsgdata TYPE        eideswtmsgdata,
        ls_eideswtdocstep TYPE        eideswtdocstep,
        ls_msg_activity   TYPE        /idexge/s_activity_status,
        ls_convvartodate  TYPE        eideswtconvertactvar,
        ls_attribute      TYPE        eideswtdocattrstruc,

        lt_attributes     TYPE        teideswtdocattrstruc,

        lr_badi_swtdoc2   TYPE REF TO isu_ide_switchdoc2,
        lr_root           TYPE REF TO cx_root.

  lv_event = event.
  lv_objtype = objtype.
  lv_switchnum = objkey.
  lv_objkey = objkey.

  CHECK zcl_agc_datex_utility=>check_cl_process_is_enabled( iv_proc_ref = lv_switchnum ) = abap_false.

  SELECT SINGLE * FROM eideswtdoc INTO ls_eideswtdoc WHERE switchnum = lv_switchnum.

  SELECT SINGLE * FROM eideswtdocstep INTO ls_eideswtdocstep WHERE switchnum = lv_switchnum.

  SELECT SINGLE * FROM eideswtmsgdata INTO ls_eideswtmsgdata WHERE switchnum = lv_switchnum.

*--------------------------------------------------------------------------------------Liebsch, 06.12.2012--------*

  CASE lv_event.
    WHEN 'PDOCCREATED'.

      IF NOT lv_switchnum IS INITIAL.
        WRITE lv_switchnum TO lv_activity_key.
        CALL METHOD cl_isu_switchdoc=>s_set
          EXPORTING
            x_switchnum     = lv_switchnum
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
        ENDIF.
      ENDIF.

      CALL FUNCTION 'SWC_ELEMENT_SET'
        EXPORTING
          element       = 'SwitchView'
          field         = ls_eideswtdoc-swtview
        TABLES
          container     = event_container
        EXCEPTIONS
          type_conflict = 1
          OTHERS        = 2.
      IF sy-subrc <> 0.
*     ignore
      ENDIF.

*   Set element of 'SWITCHTYPE'
      CALL FUNCTION 'SWC_ELEMENT_SET'
        EXPORTING
          element       = 'SwitchType'
          field         = ls_eideswtdoc-switchtype
        TABLES
          container     = event_container
        EXCEPTIONS
          type_conflict = 1
          OTHERS        = 2.
      IF sy-subrc <> 0.
*     ignore
      ENDIF.

*   Set element of 'CATEGORY'
      CALL FUNCTION 'SWC_ELEMENT_SET'
        EXPORTING
          element       = 'MessageCategory'
          field         = ls_eideswtmsgdata-category
        TABLES
          container     = event_container
        EXCEPTIONS
          type_conflict = 1
          OTHERS        = 2.
      IF sy-subrc <> 0.
*     ignore
      ENDIF.

*   Set element of 'SPARTYP'
      CALL FUNCTION 'SWC_ELEMENT_SET'
        EXPORTING
          element       = 'DivisionCategory'
          field         = ls_eideswtdoc-spartyp
        TABLES
          container     = event_container
        EXCEPTIONS
          type_conflict = 1
          OTHERS        = 2.
      IF sy-subrc <> 0.
*     ignore
      ENDIF.

      lv_objkey = lv_switchnum.
      CALL FUNCTION 'SWE_EVENT_CREATE'
        EXPORTING
          objtype           = 'ISUSWITCHD'
          objkey            = lv_objkey
          event             = 'CREATED'
        TABLES
          event_container   = event_container
        EXCEPTIONS
          objtype_not_found = 1
          OTHERS            = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN 'PDOCMESSAGEPROCESSED'.

      CALL FUNCTION 'SWC_ELEMENT_GET'
        EXPORTING
          element       = 'PROC_STEP_REF'
        IMPORTING
          field         = lv_msgnum
        TABLES
          container     = event_container
        EXCEPTIONS
          is_null       = 1
          not_found     = 2
          type_conflict = 3
          OTHERS        = 4.
      IF sy-subrc <> 0.
*       Implement suitable error handling here
      ENDIF.

      CALL FUNCTION 'SWC_ELEMENT_GET'
        EXPORTING
          element       = 'BMID'
        IMPORTING
          field         = lv_bmid
        TABLES
          container     = event_container
        EXCEPTIONS
          is_null       = 1
          not_found     = 2
          type_conflict = 3
          OTHERS        = 4.
      IF sy-subrc <> 0.
*       Implement suitable error handling here
      ENDIF.

* Find Data from eideswtmsgdata
      SELECT SINGLE * FROM eideswtmsgdata INTO  ls_eideswtmsgdata
        WHERE msgdatanum = lv_msgnum.

*     Find Event via BaDi:
*      Instantiate BAdI for the Process:
      TRY.
          GET BADI lr_badi_swtdoc2.
*
        CATCH cx_badi_not_implemented INTO lr_root.
*           to be ignored
          RETURN.

        CATCH cx_badi_multiply_implemented INTO lr_root.
*
      ENDTRY.

*      Call BAdI:
      IF NOT lr_badi_swtdoc2 IS INITIAL.
        CALL BADI lr_badi_swtdoc2->interpret_msgdata
          EXPORTING
            x_msgdata       = ls_eideswtmsgdata
            x_direction     = ls_eideswtmsgdata-direction
          IMPORTING
            y_activity      = ls_msg_activity-activity
            y_act_var1      = ls_msg_activity-act_var1
            y_act_var2      = ls_msg_activity-act_var2
            y_act_var3      = ls_msg_activity-act_var3
            y_act_var4      = ls_msg_activity-act_var4
            y_convvartodate = ls_convvartodate
            y_event         = lv_event_new
          EXCEPTIONS
            general_fault   = 1
            OTHERS          = 2.

        IF sy-subrc = 0.
          IF NOT ls_eideswtmsgdata IS INITIAL
          AND NOT ls_msg_activity-activity IS INITIAL.
            ls_attribute-attributetype = 'EIDESWTMDNUM'.
            ls_attribute-attributevalue = ls_eideswtmsgdata-msgdatanum.
            APPEND ls_attribute TO lt_attributes.
            CALL METHOD cl_isu_switchdoc=>s_set_activity_status
              EXPORTING
                x_switchnum     = ls_eideswtmsgdata-switchnum
                x_activity      = ls_msg_activity-activity
                x_status        = if_isu_ide_switch_constants=>co_stat_checked
                x_act_var1      = ls_msg_activity-act_var1
                x_act_var2      = ls_msg_activity-act_var2
                x_act_var3      = ls_msg_activity-act_var3
                x_act_var4      = ls_msg_activity-act_var4
                x_convvartodate = ls_convvartodate
                xt_attribute    = lt_attributes
                x_no_event      = cl_isu_flag=>co_true
                x_no_commit     = cl_isu_flag=>co_true
              EXCEPTIONS
                not_found       = 1
                parameter_error = 2
                general_fault   = 3
                OTHERS          = 4.
          ENDIF.
        ENDIF.
      ELSE.

      ENDIF.

      CALL FUNCTION 'SWC_ELEMENT_SET'
        EXPORTING
          element       = 'Activity'
          field         = ls_msg_activity-activity
        TABLES
          container     = event_container
        EXCEPTIONS
          type_conflict = 1
          OTHERS        = 2.
      IF sy-subrc <> 0.
      ENDIF.

      CALL FUNCTION 'SWC_ELEMENT_SET'
        EXPORTING
          element       = 'Direction'
          field         = ls_eideswtmsgdata-direction
        TABLES
          container     = event_container
        EXCEPTIONS
          type_conflict = 1
          OTHERS        = 2.
      IF sy-subrc <> 0.
      ENDIF.

      CALL FUNCTION 'SWC_ELEMENT_SET'
        EXPORTING
          element       = 'MessageNumber'
          field         = ls_eideswtmsgdata-msgdatanum
        TABLES
          container     = event_container
        EXCEPTIONS
          type_conflict = 1
          OTHERS        = 2.
      IF sy-subrc <> 0.
      ENDIF.

      CALL FUNCTION 'SWC_ELEMENT_SET'
        EXPORTING
          element       = 'AnswerStatus'
          field         = ls_eideswtmsgdata-msgstatus
        TABLES
          container     = event_container
        EXCEPTIONS
          type_conflict = 1
          OTHERS        = 2.
      IF sy-subrc <> 0.
      ENDIF.

*-----------------------------------------------------------------------------------------------------------------*
*     Create Event:
      CALL FUNCTION 'SWE_EVENT_CREATE'
        EXPORTING
          objtype           = 'ISUSWITCHD'
          objkey            = lv_objkey
          event             = lv_event_new
        TABLES
          event_container   = event_container
        EXCEPTIONS
          objtype_not_found = 1
          OTHERS            = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

*-----------------------------------------------------------------------------------------------------------------*

    WHEN OTHERS.

  ENDCASE.


ENDFUNCTION.
