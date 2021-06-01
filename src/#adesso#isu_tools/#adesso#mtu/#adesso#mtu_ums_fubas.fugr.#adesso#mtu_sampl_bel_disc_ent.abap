FUNCTION /ADESSO/MTU_SAMPL_BEL_DISC_ENT.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IDCE_HEADER STRUCTURE  EMG_DDC_HEADER OPTIONAL
*"      IDCE_ANLAGE STRUCTURE  EMG_DDC_ANLAGE_SELECTION OPTIONAL
*"      IDCE_DEVICE STRUCTURE  EMG_DDC_DEVICE_SELECTION OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_DCE) TYPE  EMG_OLDKEY
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung von Sperrung erfassen




ENDFUNCTION.
