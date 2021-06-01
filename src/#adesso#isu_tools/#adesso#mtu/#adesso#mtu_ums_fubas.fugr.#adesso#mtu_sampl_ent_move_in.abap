FUNCTION /ADESSO/MTU_SAMPL_ENT_MOVE_IN.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IMOI_EVER STRUCTURE  /ADESSO/MT_EVERD OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_MOI) LIKE  EVER-VERTRAG
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung des Vertrages (Einzug) (Entladung)





ENDFUNCTION.
