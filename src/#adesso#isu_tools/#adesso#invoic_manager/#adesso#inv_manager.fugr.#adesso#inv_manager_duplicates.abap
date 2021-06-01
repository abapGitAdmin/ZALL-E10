FUNCTION /ADESSO/INV_MANAGER_DUPLICATES .
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

FIELD-SYMBOLS:
          <y_process>    TYPE inv_process_data,
          <doc>          TYPE tinv_inv_doc.


  DATA:    fehler_kz        TYPE char1,
           l_int_inv_doc_no TYPE tinv_inv_doc-int_inv_doc_no,
           l_ext_invoice_no TYPE tinv_inv_doc-ext_invoice_no,
           l_int_sender     TYPE tinv_inv_head-int_sender,
           l_inv_bulk_ref   TYPE tinv_inv_doc-inv_bulk_ref.

* Tabelle für Sätze mit ident. GrpRefNr
  DATA:    BEGIN OF t_doc OCCURS 0,
                int_inv_doc_no LIKE tinv_inv_doc-int_inv_doc_no,
                inv_bulk_ref LIKE tinv_inv_doc-inv_bulk_ref,
                INV_DOC_STATUS LIKE tinv_inv_doc-INV_DOC_STATUS,
           END OF t_doc.

* Tabelle für Sätze mit abw. GrpRefNr
  DATA:    BEGIN OF t_doc2 OCCURS 0,
                int_inv_doc_no LIKE tinv_inv_doc-int_inv_doc_no,
                inv_bulk_ref LIKE tinv_inv_doc-inv_bulk_ref,
                INV_DOC_STATUS LIKE tinv_inv_doc-INV_DOC_STATUS,
           END OF t_doc2.



* Reset global return structures
  mac_reset_inv_return.

* set n-dimensional table xy_process_data into deep-structure
* <y_process> and check it
  LOOP AT xy_process_data ASSIGNING <y_process>
                          WHERE inv_head-sender_type   EQ co_sp
                            AND inv_head-receiver_type EQ co_sp.

    CLEAR: fehler_kz, l_int_sender.

* Sendenen Servieanbieter merken
    l_int_sender = <y_process>-inv_head-int_sender.


    LOOP AT <y_process>-inv_doc ASSIGNING <doc>
            WHERE int_inv_no = <y_process>-inv_head-int_inv_no.

      CLEAR: l_int_inv_doc_no, l_ext_invoice_no, t_doc, t_doc2.


* int.Belegnummer, Belegart und DA-Gruppenreferenz merken
      l_int_inv_doc_no = <doc>-int_inv_doc_no.
      l_inv_bulk_ref = <doc>-inv_bulk_ref.


* Prüfung ob externe Rechnungsnummer gefüllt
      IF <doc>-ext_invoice_no IS INITIAL.
        msg_to_inv_return space co_msg_error '/ADESSO/INV_MANAGER' '014' space space space space..
        IF 1 = 2.
          MESSAGE e014(/ADESSO/INV_MANAGER).
          "Ext.Rchn/AvisNr konnte nicht ermittelt werden.
        ENDIF.
        fehler_kz = 'X'.
        EXIT.
      ELSE.
        l_ext_invoice_no = <doc>-ext_invoice_no.
      ENDIF.



* Prüfung auf vorhanden Rechnungen mit identischer ext. Rechnungsnummer und DA-Gruppenreferenz
        SELECT doc~int_inv_doc_no doc~inv_bulk_ref doc~INV_DOC_STATUS INTO CORRESPONDING FIELDS OF TABLE t_doc
        FROM tinv_inv_head AS head
        INNER JOIN tinv_inv_doc AS doc
        ON doc~int_inv_no = head~int_inv_no
        WHERE doc~ext_invoice_no = <doc>-ext_invoice_no AND
              head~int_sender = l_int_sender AND
              doc~int_inv_doc_no NE l_int_inv_doc_no AND
              doc~inv_bulk_ref = l_inv_bulk_ref.



      IF sy-subrc = 0.
        LOOP AT t_doc.
        SHIFT t_doc-int_inv_doc_no LEFT DELETING LEADING '0'.
        SHIFT t_doc-inv_bulk_ref LEFT DELETING LEADING '0'.


        IF t_doc-inv_doc_status NE '08'.

        fehler_kz = 'F'.

          msg_to_inv_return space co_msg_error '/ADESSO/INV_MANAGER' '015'
                                t_doc-int_inv_doc_no t_doc-inv_bulk_ref t_doc-inv_doc_status space.
          IF 1 = 2.
             MESSAGE e015(/ADESSO/INV_MANAGER).
             "RG mit int. BelNr ReNr &1 und ident. GrpRefNr &2 im Status &3 vorhanden
          ENDIF.
        ELSE.

          IF fehler_kz NE 'F'.
             fehler_kz = 'W'.
          ENDIF.

          msg_to_inv_return space co_msg_warning '/ADESSO/INV_MANAGER' '015'
                                t_doc-int_inv_doc_no t_doc-inv_bulk_ref t_doc-inv_doc_status space.
          IF 1 = 2.
             MESSAGE w015(/ADESSO/INV_MANAGER).
             "RG mit int. BelNr ReNr &1 und ident. GrpRefNr &2 im Status &3 vorhanden
          ENDIF.
        ENDIF.

        ENDLOOP.

      ENDIF.

* Prüfung auf vorhandene Rechnungen mit identischer ext. Rechnungsnummer und abweichender DA-Gruppenreferenz

        SELECT doc~int_inv_doc_no doc~inv_bulk_ref doc~INV_DOC_STATUS INTO CORRESPONDING FIELDS OF TABLE t_doc2
        FROM tinv_inv_head AS head
        INNER JOIN tinv_inv_doc AS doc
        ON doc~int_inv_no = head~int_inv_no
        WHERE doc~ext_invoice_no = <doc>-ext_invoice_no AND
              head~int_sender = l_int_sender AND
              doc~int_inv_doc_no NE l_int_inv_doc_no AND
              doc~inv_bulk_ref NE l_inv_bulk_ref.



      IF sy-subrc = 0.
        LOOP AT t_doc2.
        SHIFT t_doc2-int_inv_doc_no LEFT DELETING LEADING '0'.
        SHIFT t_doc2-inv_bulk_ref LEFT DELETING LEADING '0'.

        IF t_doc2-inv_doc_status NE '08'.

        fehler_kz = 'F'.

          msg_to_inv_return space co_msg_error '/ADESSO/INV_MANAGER' '016'
                                t_doc2-int_inv_doc_no t_doc2-inv_bulk_ref t_doc2-inv_doc_status space.
          IF 1 = 2.
             MESSAGE e016(/ADESSO/INV_MANAGER).
             "RG mit int. BelNr ReNr &1 und abw. GrpRefNr &2 im Status &3 vorhanden
          ENDIF.
        ELSE.

          IF fehler_kz NE 'F'.
             fehler_kz = 'W'.
          ENDIF.

          msg_to_inv_return space co_msg_warning '/ADESSO/INV_MANAGER' '016'
                                t_doc2-int_inv_doc_no t_doc2-inv_bulk_ref t_doc2-inv_doc_status space.
          IF 1 = 2.
             MESSAGE w016(/ADESSO/INV_MANAGER).
             "RG mit int. BelNr ReNr &1 und abw. GrpRefNr &2 im Status &3 vorhanden
          ENDIF.
        ENDIF.

        ENDLOOP.

      ENDIF.

    ENDLOOP. "<y_process>-inv_doc


    IF  fehler_kz is INITIAL.
      msg_to_inv_return space co_msg_success '/ADESSO/INV_MANAGER' '017' space space space space.
      IF 1 = 2.
        MESSAGE s017(/ADESSO/INV_MANAGER).
        "Prüfung auf doppelte Rechnungseingänge erfolgreich.
      ENDIF.
    ELSEIF fehler_kz EQ 'F'.
      msg_to_inv_return space co_msg_error '/ADESSO/INV_MANAGER' '018' space space space space.
      IF 1 = 2.
        MESSAGE e018(/ADESSO/INV_MANAGER).
        "Prüfung auf doppelte Rechnungseingänge nicht erfolgreich.
      ENDIF.
    ELSEIF fehler_kz EQ 'W'.
      msg_to_inv_return space co_msg_warning '/ADESSO/INV_MANAGER' '019' space space space space.
      IF 1 = 2.
        MESSAGE w019(/ADESSO/INV_MANAGER).
        "Prüfung auf doppelte Rechnungseingänge mit Warnung abgeschlossen.
      ENDIF.
    ENDIF.

  ENDLOOP. "xy_process_data

  y_return[] = it_inv_return[].

* Set status
  CALL FUNCTION 'ISU_DEREG_INV_COM_STATUS'
    EXPORTING
      x_return = y_return[]
    IMPORTING
      y_status = y_status.

ENDFUNCTION.
