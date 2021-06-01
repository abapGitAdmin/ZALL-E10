FUNCTION /ADESSO/MTU_SAMPL_ENT_DISC_ENT.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IDCE_HEADER STRUCTURE  /ADESSO/MT_EMG_DDC_HEADER OPTIONAL
*"      IDCE_ANLAGE STRUCTURE  /ADESSO/MT_EMG_DDC_ANLAGE_SEL OPTIONAL
*"      IDCE_DEVICE STRUCTURE  /ADESSO/MT_EMG_DDC_DEVICE_SEL OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_DCE) LIKE  EDISCDOC-DISCNO
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung der Sperrbelege (Entladung)





ENDFUNCTION.
