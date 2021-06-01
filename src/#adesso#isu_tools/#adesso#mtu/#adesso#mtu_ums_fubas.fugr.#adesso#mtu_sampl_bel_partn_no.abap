FUNCTION /ADESSO/MTU_SAMPL_BEL_PARTN_NO.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      I_NOTKEY STRUCTURE  EMG_NOTICE_KEY OPTIONAL
*"      I_NOTLIN STRUCTURE  EMG_TLINE OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_PNO) TYPE  EMG_OLDKEY
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung der Notizen zum Partner



ENDFUNCTION.
