FUNCTION /ADESSO/MTU_SAMPL_BEL_INSTPLAN.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IPL_IPKEY STRUCTURE  EMG_INSTPLAN OPTIONAL
*"      IPL_IPDATA STRUCTURE  FKKINTPLN OPTIONAL
*"      IPL_IPOPKY STRUCTURE  FKKOPKEY OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_IPL) TYPE  EMG_OLDKEY
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung der Ratenpläne



ENDFUNCTION.
