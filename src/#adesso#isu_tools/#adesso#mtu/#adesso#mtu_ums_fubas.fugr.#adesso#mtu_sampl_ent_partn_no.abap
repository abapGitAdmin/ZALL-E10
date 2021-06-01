FUNCTION /ADESSO/MTU_SAMPL_ENT_PARTN_NO.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IPNO_NOTKEY STRUCTURE  /ADESSO/MT_EMG_NOTICE_KEY OPTIONAL
*"      IPNO_NOTLIN STRUCTURE  /ADESSO/MT_EMG_TLINE OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_PNO) TYPE  EMG_OLDKEY
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung der Notizen zum Partner (Entladung)





ENDFUNCTION.
