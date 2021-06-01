FUNCTION /ADESSO/MTU_SAMPL_ENT_PREMISE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IPRE_EVBSD STRUCTURE  /ADESSO/MT_EVBSD OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_PRE) LIKE  EVBS-VSTELLE
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung der Verbrauchsstelle (Entladung)





ENDFUNCTION.
