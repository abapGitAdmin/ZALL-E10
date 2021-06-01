FUNCTION /ADESSO/MTU_SAMPL_ENT_DEVICERA.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IDRT_DRINT STRUCTURE  /ADESSO/MT_EMG_DEVRATE_INT OPTIONAL
*"      IDRT_DRDEV STRUCTURE  /ADESSO/MT_REG70_D OPTIONAL
*"      IDRT_DRREG STRUCTURE  /ADESSO/MT_REG70_R OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_DRT) TYPE  EMG_OLDKEY
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung der Tarifänderungen (Entladung)





ENDFUNCTION.
