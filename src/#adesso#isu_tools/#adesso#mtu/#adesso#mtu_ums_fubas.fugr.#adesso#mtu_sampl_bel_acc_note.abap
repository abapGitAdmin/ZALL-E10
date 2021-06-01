FUNCTION /ADESSO/MTU_SAMPL_BEL_ACC_NOTE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IACN_NOTKEY STRUCTURE  EMG_NOTICE_KEY OPTIONAL
*"      IACN_NOTLIN STRUCTURE  EMG_TLINE OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_ACN) TYPE  EMG_OLDKEY
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung der Notizen zum Vertragskonto



ENDFUNCTION.
