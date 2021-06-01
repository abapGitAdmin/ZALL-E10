FUNCTION /ADESSO/MTU_SAMPL_ENT_METERRE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IMRD_IEABLU STRUCTURE  /ADESSO/MT_EABLU OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_MRD) TYPE  EMG_OLDKEY
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung der Zählerstände (Entladung)

ENDFUNCTION.
