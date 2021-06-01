FUNCTION /ADESSO/MTU_SAMPL_BEL_DLC_NOTE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IDNO_NOTKEY STRUCTURE  EMG_NOTICE_KEY OPTIONAL
*"      IDNO_NOTLIN STRUCTURE  EMG_TLINE OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_DNO) TYPE  EMG_OLDKEY
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung der Notizen zum Geräteplatz





ENDFUNCTION.
