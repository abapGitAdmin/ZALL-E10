FUNCTION /ADESSO/MTU_SAMPL_ENT_ACC_NOTE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IACN_NOTKEY STRUCTURE  /ADESSO/MT_EMG_NOTICE_KEY OPTIONAL
*"      IACN_NOTLIN STRUCTURE  /ADESSO/MT_EMG_TLINE OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_ACN) LIKE  FKKVK-VKONT
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung der Notizen zum Vertragskonto
* (Entladung)





ENDFUNCTION.
