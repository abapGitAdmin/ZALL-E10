FUNCTION /adesso/inv_manager_sperr .
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

* MessageID
  CONSTANTS: co_z_msgid           TYPE sy-msgid VALUE '/ADESSO/INV_MANAGER'.

  FIELD-SYMBOLS:
    <y_process> TYPE inv_process_data,
    <doc>       TYPE tinv_inv_doc.


  DATA :ls_inv_sperr TYPE /adesso/invsperr,
        val1         TYPE sy-msgv1.


* Reset global return structures
  mac_reset_inv_return.

* set n-dimensional table xy_process_data into deep-structure
* <y_process> and check it
  LOOP AT xy_process_data ASSIGNING <y_process>
                          WHERE inv_head-sender_type   EQ co_sp
                            AND inv_head-receiver_type EQ co_sp.


    LOOP AT <y_process>-inv_doc ASSIGNING <doc>
            WHERE int_inv_no = <y_process>-inv_head-int_inv_no.

      SELECT SINGLE * FROM /adesso/invsperr INTO ls_inv_sperr WHERE int_inv_doc_nr =  <doc>-int_inv_no.
      IF sy-subrc = 0. " Gesperrt.

    val1 = <doc>-int_inv_doc_no.
    msg_to_inv_return space co_msg_error co_z_msgid '031'
                      val1 ls_inv_sperr-username space space.


      ELSE.
    val1 = <doc>-int_inv_doc_no.
    msg_to_inv_return space co_msg_success co_z_msgid '032'
                      val1 space space space.

      ENDIF.


    ENDLOOP. "xy_process_data

  ENDLOOP.
  y_return[] = it_inv_return[].

* Set status
  CALL FUNCTION 'ISU_DEREG_INV_COM_STATUS'
    EXPORTING
      x_return = y_return[]
    IMPORTING
      y_status = y_status.

ENDFUNCTION.
