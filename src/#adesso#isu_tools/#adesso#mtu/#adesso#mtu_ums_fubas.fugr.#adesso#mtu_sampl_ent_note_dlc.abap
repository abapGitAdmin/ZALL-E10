FUNCTION /ADESSO/MTU_SAMPL_ENT_NOTE_DLC.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      INOD_KEY STRUCTURE  /ADESSO/MT_EENFI_NOTE_KEY_DI OPTIONAL
*"      INOD_NOTES STRUCTURE  /ADESSO/MT_EENFI_SINGL_NOTE_DI OPTIONAL
*"      INOD_TEXT STRUCTURE  /ADESSO/MT_EENFI_NOTE_TEXT_DI OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_NOD) LIKE  EGPL-DEVLOC
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung der Außendiensthinweise zum
* Geräteplatz (Entladung)







ENDFUNCTION.
