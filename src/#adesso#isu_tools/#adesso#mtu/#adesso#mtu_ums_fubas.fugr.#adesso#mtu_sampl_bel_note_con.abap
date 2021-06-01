FUNCTION /ADESSO/MTU_SAMPL_BEL_NOTE_CON.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      INOC_KEY STRUCTURE  EENFI_NOTE_KEY_DI OPTIONAL
*"      INOC_NOTES STRUCTURE  EENFI_SINGLE_NOTE_DI OPTIONAL
*"      INOC_TEXT STRUCTURE  EENFI_NOTE_TEXT_DI OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_NOC) TYPE  EMG_OLDKEY
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung der Außendiensthinweise zum
* Anschlußobjekt






ENDFUNCTION.
