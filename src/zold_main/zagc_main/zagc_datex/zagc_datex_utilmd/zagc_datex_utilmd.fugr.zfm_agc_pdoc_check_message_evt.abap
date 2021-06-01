FUNCTION zfm_agc_pdoc_check_message_evt .
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(EVENT) LIKE  SWETYPECOU-EVENT
*"     VALUE(RECTYPE) LIKE  SWETYPECOU-RECTYPE
*"     VALUE(OBJTYPE) LIKE  SWETYPECOU-OBJTYPE
*"     VALUE(OBJKEY) LIKE  SWEINSTCOU-OBJKEY
*"  TABLES
*"      EVENT_CONTAINER STRUCTURE  SWCONT
*"  EXCEPTIONS
*"      CONTAINER_ERROR
*"      BMID_DIFFERENT
*"      SENDER_DIFFERENT
*"--------------------------------------------------------------------
**----------------------------------------------------------------------*
**
** Author: SAP Custom Development, 2012
**
** Usage:
** a) Compare BMID in event contianer and workflow contianer to check
**    whether received business message is we are waiting for.
*
** Status: Completed
*----------------------------------------------------------------------*
** Change History:
*
*----------------------------------------------------------------------*
  INCLUDE <cntain>.
  INCLUDE rsweincl.

  DATA: lr_ctx TYPE REF TO /idxgc/cl_pd_doc_context.

  DATA: lv_wi_id TYPE swwwihead-wi_id.
  DATA: lt_wi_container TYPE sweconttab.

  DATA: lv_mtext TYPE string.
  DATA: lv_msgv1 TYPE sy-msgv1.
  DATA: lv_msgv2 TYPE sy-msgv2.
  DATA: lv_msgv3 TYPE sy-msgv3.
  DATA: lv_msgv4 TYPE sy-msgv4.

  DATA: lv_proc_ref TYPE /idxgc/de_proc_ref.
  DATA: lv_proc_step_no TYPE /idxgc/de_proc_step_no.
  DATA: lv_bmid_workflow TYPE /idxgc/de_bmid.
  DATA: lv_bmid_event TYPE /idxgc/de_bmid.
  DATA: lv_proc_step_ref          TYPE /idxgc/de_proc_step_ref,
        lv_send_step_ref_event    TYPE /idxgc/de_proc_step_ref,
        lv_send_step_ref_workflow TYPE /idxgc/de_proc_step_ref.

  DATA: ls_proc_step_data TYPE /idxgc/s_proc_step_data.
  DATA: ls_proc_hdr TYPE /idxgc/s_proc_hdr.
  DATA: ls_proc_step_id TYPE /idxgc/s_proc_step_id.
  DATA: ls_proc_step_config_all TYPE /idxgc/s_proc_step_config_all.

  DATA: lv_activity TYPE eideswtact.
  DATA: lx_evt_exception TYPE REF TO cx_swf_evt_exception,
        lr_container     TYPE REF TO if_swf_ifs_parameter_container.
  DATA: lt_bmid_list TYPE /idxgc/tt_bmid_list,
        ls_bmid_list TYPE /idxgc/de_bmid.

  DATA: lv_count_lock TYPE i VALUE 0.
* ----------------------------------------------------------------------
*
* Get the process step reference key and BMID from the event container
  swc_get_element event_container /idxgc/if_constants_add=>gc_elem_proc_step_ref lv_proc_step_ref.

  IF sy-subrc NE 0.
*   261: Container error: Attribut &1 not available in Event Container
    lv_msgv1 = /idxgc/if_constants_add=>gc_elem_proc_step_ref.
    MESSAGE s026(/idxgc/process_add) INTO lv_mtext WITH lv_msgv1.
    RAISE container_error.
  ENDIF.

  swc_get_element event_container /idxgc/if_constants_add=>gc_elem_bmid_event lv_bmid_event.
  IF sy-subrc NE 0.
*   261: Container error: Attribut &1 not available in Event Container
    lv_msgv1 = /idxgc/if_constants_add=>gc_elem_bmid_event.
    MESSAGE s026(/idxgc/process_add) INTO lv_mtext WITH lv_msgv1.
    RAISE container_error.
  ENDIF.

* Get the process step reference of the send step for E03 UTILMD response
  IF lv_bmid_event = /idxgc/if_constants_ide=>gc_bmid_cm024 OR
     lv_bmid_event = /idxgc/if_constants_ide=>gc_bmid_cm025.
    swc_get_element event_container /idxgc/if_constants_add=>gc_elem_proc_send_step_ref lv_send_step_ref_event.
    IF sy-subrc NE 0.
*   261: Container error: Attribut &1 not available in Event Container
      lv_msgv1 = /idxgc/if_constants_add=>gc_elem_proc_send_step_ref.
      MESSAGE s026(/idxgc/process_add) INTO lv_mtext WITH lv_msgv1.
      RAISE container_error.
    ENDIF.
  ENDIF.

* Get the receiver id of the workitem from the event container
  swc_get_element event_container evt_receiver_id lv_wi_id.
  IF sy-subrc NE 0.
*   261: Container error: Attribut &1 not available in Event Container
    lv_msgv1 = evt_receiver_id.
    MESSAGE s026(/idxgc/process_add) INTO lv_mtext WITH lv_msgv1.
    RAISE container_error.
  ENDIF.

* Get the workitem container from the receiver id workitem
  CALL FUNCTION 'SWW_WI_CONTAINER_READ'
    EXPORTING
      wi_id                    = lv_wi_id
    TABLES
      wi_container             = lt_wi_container
    EXCEPTIONS
      container_does_not_exist = 01.

  IF sy-subrc NE 0.
*   262: Container error: No Container exist for WI &1
    lv_msgv1 = lv_wi_id.
    MESSAGE s027(/idxgc/process_add) INTO lv_mtext WITH lv_msgv1.
    RAISE container_error.
  ENDIF.

* Get the BMID and process step number from the receiver workitem container.
  swc_get_element lt_wi_container /idxgc/if_constants_add=>gc_elem_proc_step_no lv_proc_step_no.
  IF sy-subrc NE 0.
*   263: Container error: Attribut &1 not available in Workitem Container &2
    lv_msgv1 = /idxgc/if_constants_add=>gc_elem_proc_step_no.
    lv_msgv2 = lv_wi_id.
    MESSAGE s028(/idxgc/process_add) INTO lv_mtext WITH lv_msgv1 lv_msgv2.
    RAISE container_error.
  ENDIF.
  IF lv_bmid_event = /idxgc/if_constants_ide=>gc_bmid_cm024 OR
    lv_bmid_event = /idxgc/if_constants_ide=>gc_bmid_cm025.
* Get the send step reference of the workflow container
    swc_get_element lt_wi_container /idxgc/if_constants_add=>gc_elem_proc_send_step_ref_wf lv_send_step_ref_workflow.
*
    IF sy-subrc NE 0.
*   263: Container error: Attribut &1 not available in Workitem Container &2
      lv_msgv1 = /idxgc/if_constants_add=>gc_elem_proc_send_step_ref.
      lv_msgv2 = lv_wi_id.
      MESSAGE s028(/idxgc/process_add) INTO lv_mtext WITH lv_msgv1 lv_msgv2.
      RAISE container_error.
    ENDIF.
  ENDIF.

  swc_get_element lt_wi_container /idxgc/if_constants_add=>gc_elem_bmid_workflow lv_bmid_workflow.
*
  IF sy-subrc NE 0.
*   263: Container error: Attribut &1 not available in Workitem Container &2
    lv_msgv1 = /idxgc/if_constants_add=>gc_elem_bmid_workflow.
    lv_msgv2 = lv_wi_id.
    MESSAGE s028(/idxgc/process_add) INTO lv_mtext WITH lv_msgv1 lv_msgv2.
    RAISE container_error.
  ENDIF.

  swc_get_element lt_wi_container /idxgc/if_constants_add=>gc_elem_bmid_list lt_bmid_list.
* Get instance of process document.
  DO.
    TRY.
        lv_proc_ref = objkey.
        lr_ctx = /idxgc/cl_pd_doc_context=>get_instance( iv_pdoc_no = lv_proc_ref
                                                         iv_wmode = cl_isu_wmode=>co_change ).
        EXIT.
      CATCH /idxgc/cx_process_error.
        IF lv_count_lock = 5.
*     259: Container error: Error creating Instance for Process Doc &1
          WRITE lv_proc_ref TO lv_msgv1 LEFT-JUSTIFIED NO-ZERO.
          SHIFT lv_msgv1 LEFT DELETING LEADING space.
          MESSAGE s025(/idxgc/process_add) INTO lv_mtext WITH lv_msgv1.
          RAISE container_error.
          EXIT.
        ELSE.
          WAIT UP TO 5 SECONDS.
          ADD 1 TO lv_count_lock.
        ENDIF.
    ENDTRY.
  ENDDO.

* Get Pdoc header data
  CALL METHOD lr_ctx->get_header_data
    IMPORTING
      es_proc_hdr = ls_proc_hdr.

* Fill step key and get the prstep configuration
  ls_proc_step_id-proc_id      = ls_proc_hdr-proc_id.
  ls_proc_step_id-proc_version = ls_proc_hdr-proc_version.
  ls_proc_step_id-proc_step_no = lv_proc_step_no.

  TRY.
      CALL METHOD /idxgc/cl_cust_access=>/idxgc/if_cust_access~get_process_step_config
        EXPORTING
          is_process_step_id     = ls_proc_step_id
        RECEIVING
          rs_process_step_config = ls_proc_step_config_all.

    CATCH /idxgc/cx_config_error.
*   don't raise any exception here
  ENDTRY.

* Set Activity
  IF ls_proc_step_config_all-activity IS INITIAL.
    lv_activity = /idxgc/if_constants_add=>gc_activity_i02.
  ELSE.
    lv_activity = ls_proc_step_config_all-activity.
  ENDIF.

* Get process step data.
  TRY.
      CALL METHOD lr_ctx->get_proc_step_data
        EXPORTING
          iv_proc_step_ref  = lv_proc_step_ref
        IMPORTING
          es_proc_step_data = ls_proc_step_data.

    CATCH /idxgc/cx_process_error .
  ENDTRY.

* Compare the two BMID; if not equal: raise exception.
  lv_msgv1 = lv_bmid_workflow.
  lv_msgv2 = lv_proc_step_ref.
  lv_msgv3 = lv_proc_ref.
  lv_msgv4 = lv_bmid_event.

  IF lv_bmid_event NE lv_bmid_workflow.
*-- make it visible in the wf event log
*   265: Expected BMID: &1 but received: &4 (Message: &2 Process Doc: &3)
*--- ... it is NOT an error ...
    IF lt_bmid_list IS NOT INITIAL.

      LOOP AT lt_bmid_list INTO ls_bmid_list
                           WHERE table_line = lv_bmid_event.
      ENDLOOP.
      IF sy-subrc <> 0.
        MESSAGE s029(/idxgc/process_add) INTO lv_mtext WITH lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4 .
        IF lr_ctx IS BOUND.
          TRY.
              lr_ctx->add_message_log( ).
            CATCH /idxgc/cx_process_error.
          ENDTRY.
        ENDIF.
      ENDIF.
    ELSE.
      MESSAGE s029(/idxgc/process_add) INTO lv_mtext WITH lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4 .
      IF lr_ctx IS BOUND.
        TRY.
            lr_ctx->add_message_log( ).
          CATCH /idxgc/cx_process_error.
        ENDTRY.
      ENDIF.

    ENDIF.
  ELSE.
    IF lv_send_step_ref_workflow EQ lv_send_step_ref_event.
*   266: Expected BMID: &1 arrived. (Message: &2 Process Doc: &3)
      MESSAGE s030(/idxgc/process_add) INTO lv_mtext WITH lv_msgv1 lv_msgv2 lv_msgv3.
      IF lr_ctx IS BOUND.
        TRY.
            lr_ctx->add_message_log( ).
          CATCH /idxgc/cx_process_error.
        ENDTRY.
      ENDIF.

*   Update step data in pdoc monitor
      ls_proc_step_data-proc_step_no = lv_proc_step_no.
      ls_proc_step_data-proc_step_status = /idxgc/if_constants_add=>gc_proc_step_status_ok.
      TRY.
          CALL METHOD lr_ctx->update_proc_steps
            EXPORTING
              is_proc_step_data = ls_proc_step_data.
        CATCH /idxgc/cx_process_error.
      ENDTRY.

*   Update activity in pdoc monitor
      lv_msgv1 = lv_bmid_event.
      lv_msgv2 = ls_proc_step_data-assoc_servprov.
*   set activity I02: Message &1 received from &2
      TRY.
          CALL METHOD lr_ctx->update_activity
            EXPORTING
              iv_proc_step_no = lv_proc_step_no
              iv_activity     = lv_activity
              iv_status       = /idxgc/if_constants_add=>gc_act_status_ok
              iv_act_var1     = lv_msgv1
              iv_act_var2     = lv_msgv2.
        CATCH /idxgc/cx_process_error.
      ENDTRY.

*   add log message with the domain text
      MESSAGE s024(/idxgc/process_add) INTO lv_mtext WITH lv_msgv1.
      TRY.
          lr_ctx->add_message_log( ).
        CATCH /idxgc/cx_process_error.
      ENDTRY.
    ELSE.
* Parallel workitem receiving same BMID from different service providers,
* step reference number of sending step doesn#t equall

    ENDIF.

  ENDIF.
*
* Close document
* After this method, the COMMIT WORK action will be triggered
  TRY.
      lr_ctx->close_and_save( ).
    CATCH /idxgc/cx_process_error.
  ENDTRY.
*
* Compare the two BMID; if not equal: raise exception.
  IF lt_bmid_list IS NOT INITIAL.
    LOOP AT lt_bmid_list INTO ls_bmid_list WHERE table_line = lv_bmid_event.
    ENDLOOP.
    IF sy-subrc <> 0.
      RAISE bmid_different.
    ENDIF.
  ELSE.
    IF lv_bmid_event NE lv_bmid_workflow.
      RAISE bmid_different.
    ENDIF.
  ENDIF.

  IF lv_send_step_ref_workflow IS NOT INITIAL AND
     lv_send_step_ref_event IS NOT INITIAL AND
     lv_send_step_ref_workflow <> lv_send_step_ref_event.
    RAISE sender_different.
  ENDIF.

ENDFUNCTION.
