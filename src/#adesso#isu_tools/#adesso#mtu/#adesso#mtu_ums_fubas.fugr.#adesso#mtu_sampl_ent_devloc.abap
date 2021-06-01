FUNCTION /ADESSO/MTU_SAMPL_ENT_DEVLOC.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IDLC_EGPLD STRUCTURE  /ADESSO/MT_EGPLD OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_DLC) LIKE  EGPL-DEVLOC
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung des Geräteplatzes (Entladung)





ENDFUNCTION.
