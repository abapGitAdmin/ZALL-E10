FUNCTION /ADESSO/MTU_SAMPL_ENT_DISC_RCE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IDCM_HEADER STRUCTURE  /ADESSO/MT_EMG_DDC_HEADER OPTIONAL
*"      IDCM_ANLAGE STRUCTURE  /ADESSO/MT_EMG_DDC_ANLAGE_SEL OPTIONAL
*"      IDCM_DEVICE STRUCTURE  /ADESSO/MT_EMG_DDC_DEVICE_SEL OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_DCM) LIKE  EDISCDOC-DISCNO
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung der Sperrbelege (Entladung)





ENDFUNCTION.
