FUNCTION /ADZ/INV_MANAGER_SIM_CHECK.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IT_INV_DOC_NO) TYPE  TINV_INT_INV_DOC_NO
*"     REFERENCE(IV_CHECK_PROC) TYPE  INV_PROCESS OPTIONAL
*"  EXPORTING
*"     REFERENCE(Y_RETURN) TYPE  TTINV_LOG_MSGBODY
*"     REFERENCE(Y_STATUS) TYPE  INV_STATUS_LINE
*"     REFERENCE(Y_CHANGED) TYPE  INV_KENNZX
*"--------------------------------------------------------------------
"Dynpro mit User Command
CLEAR: gt_inv_doc_no, gt_ausgabe_sim .
gt_inv_doc_no = it_inv_doc_no.
call SCREEN 0100 STARTING AT 10 10.

"Control generieren




"Prüfung ausführen


"Ergebnisse ans Dynpro



"Abwerten dann Ergebnisse zurück an Invoic Manager







ENDFUNCTION.
