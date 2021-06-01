FUNCTION /ADESSO/MTU_SAMPL_ENT_DLC_NOTE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IDNO_NOTKEY STRUCTURE  /ADESSO/MT_EMG_NOTICE_KEY OPTIONAL
*"      IDNO_NOTLIN STRUCTURE  /ADESSO/MT_EMG_TLINE OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_DNO) LIKE  EGPL-DEVLOC
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung der Notizen zum Geräteplatz
* (Entladung)




ENDFUNCTION.
