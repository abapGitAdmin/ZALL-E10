FUNCTION /ADESSO/MTU_SAMPL_ENT_BCONT_NO.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IBCN_NOTKEY STRUCTURE  /ADESSO/MT_EMG_NOTICE_KEY OPTIONAL
*"      IBCN_NOTLIN STRUCTURE  /ADESSO/MT_EMG_TLINE OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_BCN) LIKE  BCONT-BPCONTACT
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung der Notizen zum Kundenkontakt
* (Entladung)




ENDFUNCTION.
