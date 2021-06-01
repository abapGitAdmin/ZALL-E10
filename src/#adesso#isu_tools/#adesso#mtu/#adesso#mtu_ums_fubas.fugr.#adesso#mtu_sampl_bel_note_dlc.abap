FUNCTION /ADESSO/MTU_SAMPL_BEL_NOTE_DLC.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      INOD_KEY STRUCTURE  EENFI_NOTE_KEY_DI OPTIONAL
*"      INOD_NOTES STRUCTURE  EENFI_SINGLE_NOTE_DI OPTIONAL
*"      INOD_TEXT STRUCTURE  EENFI_NOTE_TEXT_DI OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_NOD) TYPE  EMG_OLDKEY
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung der Außendiensthinweise zum
* Geräteplatz





ENDFUNCTION.
