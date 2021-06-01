FUNCTION /ADESSO/MTU_SAMPL_BEL_CON_NOTE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      ICNO_NOTKEY STRUCTURE  EMG_NOTICE_KEY OPTIONAL
*"      ICNO_NOTLIN STRUCTURE  EMG_TLINE OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_CNO) TYPE  EMG_OLDKEY
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung der Notizen zum Anschlußobjek



ENDFUNCTION.
