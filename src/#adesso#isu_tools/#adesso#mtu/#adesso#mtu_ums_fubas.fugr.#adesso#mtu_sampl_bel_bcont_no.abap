FUNCTION /ADESSO/MTU_SAMPL_BEL_BCONT_NO.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IBCN_NOTKEY STRUCTURE  EMG_NOTICE_KEY OPTIONAL
*"      IBCN_NOTLIN STRUCTURE  EMG_TLINE OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_BCN) TYPE  EMG_OLDKEY
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung der Notizen zum Kundenkontakt



ENDFUNCTION.
