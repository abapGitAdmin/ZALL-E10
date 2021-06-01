FUNCTION /ADZ/INV_MANAGER_MEMI .
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(X_CONTROL) TYPE  INV_CONTROL_DATA
*"  EXPORTING
*"     REFERENCE(Y_RETURN) TYPE  TTINV_LOG_MSGBODY
*"     REFERENCE(Y_STATUS) TYPE  INV_STATUS_LINE
*"     REFERENCE(Y_CHANGED) TYPE  INV_KENNZX
*"  CHANGING
*"     REFERENCE(XY_PROCESS_DATA) TYPE  TTINV_PROCESS_DATA
*"--------------------------------------------------------------------

* MessageID
  CONSTANTS: co_z_msgid           TYPE sy-msgid VALUE '/ADZ/INV_MANAGER'.

  FIELD-SYMBOLS:
    <y_process> TYPE inv_process_data,
    <doc>       TYPE tinv_inv_line_b.


  DATA :val1          TYPE sy-msgv1,
        lv_memi       TYPE C,
        lt_inv_line_i TYPE TABLE OF tinv_inv_line_b.


* Reset global return structures
  mac_reset_inv_return.

* set n-dimensional table xy_process_data into deep-structure
* <y_process> and check it
  LOOP AT xy_process_data ASSIGNING <y_process>
                          WHERE inv_head-sender_type   EQ co_sp
                            AND inv_head-receiver_type EQ co_sp.

    DATA lv_int_inv_doc_no TYPE tinv_inv_doc-int_inv_doc_no.
    CLEAR lv_memi.
    SELECT SINGLE int_inv_doc_no  FROM tinv_inv_doc INTO lv_int_inv_doc_no WHERE int_inv_no = <y_process>-inv_head-int_inv_no.
    LOOP AT <y_process>-inv_line_b ASSIGNING <doc>
      WHERE int_inv_doc_no = lv_int_inv_doc_no.
      "   WHERE int_inv_doc_no = <y_process>-INV_LINE_B-int_inv_doc_no.


      IF <doc>-product_id = '9990001000574'.
        lv_memi = 'X'.
      ENDIF.

    ENDLOOP. "xy_process_data
    if <doc> IS ASSIGNED.
    IF lv_memi = 'X'.
      val1 = <doc>-int_inv_doc_no.
      msg_to_inv_return space co_msg_error co_z_msgid '035'
                        val1 space space space.


    ELSE.
      val1 = <doc>-int_inv_doc_no.
      msg_to_inv_return space co_msg_success co_z_msgid '036'
                        val1 space space space.

    ENDIF.
    ENDIF.



  ENDLOOP.
  y_return[] = it_inv_return[].

* Set status
  CALL FUNCTION 'ISU_DEREG_INV_COM_STATUS'
    EXPORTING
      x_return = y_return[]
    IMPORTING
      y_status = y_status.

ENDFUNCTION.
