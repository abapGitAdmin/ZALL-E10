FUNCTION /ADESSO/MTU_SAMPL_ENT_NOTE_CON.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      INOC_KEY STRUCTURE  /ADESSO/MT_EENFI_NOTE_KEY_DI OPTIONAL
*"      INOC_NOTES STRUCTURE  /ADESSO/MT_EENFI_SINGL_NOTE_DI OPTIONAL
*"      INOC_TEXT STRUCTURE  /ADESSO/MT_EENFI_NOTE_TEXT_DI OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_NOC) LIKE  EHAUISU-HAUS
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung der Außendiensthinweise zum
* Anschlußobjekt (Entladung)







ENDFUNCTION.
