FUNCTION /ADESSO/MTU_SAMPL_ENT_DISC_RCO.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IDCR_HEADER STRUCTURE  /ADESSO/MT_EMG_DDC_HEADER OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_DCR) LIKE  EDISCDOC-DISCNO
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung der Sperrbelege (Entladung)





ENDFUNCTION.
