FUNCTION /ADESSO/MTU_SAMPL_BEL_DISC_RCE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IDCM_HEADER STRUCTURE  EMG_DDC_HEADER OPTIONAL
*"      IDCM_ANLAGE STRUCTURE  EMG_DDC_ANLAGE_SELECTION OPTIONAL
*"      IDCM_DEVICE STRUCTURE  EMG_DDC_DEVICE_SELECTION OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_DCM) TYPE  EMG_OLDKEY
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung von Wiederinbetriebnahme anlegen



ENDFUNCTION.
