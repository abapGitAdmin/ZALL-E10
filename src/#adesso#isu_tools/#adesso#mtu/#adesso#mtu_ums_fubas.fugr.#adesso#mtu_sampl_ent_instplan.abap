FUNCTION /ADESSO/MTU_SAMPL_ENT_INSTPLAN.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IPL_IPKEY STRUCTURE  /ADESSO/MT_EMG_INSTPLAN OPTIONAL
*"      IPL_IPDATA STRUCTURE  /ADESSO/MT_FKKINTPLN OPTIONAL
*"      IPL_IPOPKY STRUCTURE  /ADESSO/MT_FKKOPKEY OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_IPL) LIKE  FKKVK-VKONT
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung der Ratenpläne (Entladung)





ENDFUNCTION.
