FUNCTION /ADESSO/MTU_SAMPL_ENT_CON_NOTE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      ICNO_NOTKEY STRUCTURE  /ADESSO/MT_EMG_NOTICE_KEY OPTIONAL
*"      ICNO_NOTLIN STRUCTURE  /ADESSO/MT_EMG_TLINE OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_CNO) LIKE  EVBS-HAUS
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung der Notizen zum Anschlussobjekt
* (Entladung)




ENDFUNCTION.
