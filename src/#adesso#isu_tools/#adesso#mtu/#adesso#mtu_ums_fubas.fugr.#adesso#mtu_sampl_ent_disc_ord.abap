FUNCTION /ADESSO/MTU_SAMPL_ENT_DISC_ORD.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IDCO_HEADER STRUCTURE  /ADESSO/MT_EMG_DDC_HEADER OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_DCO) LIKE  EDISCDOC-DISCNO
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung der Sperrbelege (Entladung)





ENDFUNCTION.
