FUNCTION /ADESSO/MTU_SAMPL_BEL_DISC_DOC.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IDCD_HEADER STRUCTURE  EMG_DDC_HEADER OPTIONAL
*"      IDCD_FKKMAZ STRUCTURE  EMG_DDC_DOCUMENT_SELECT OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_DCD) TYPE  EMG_OLDKEY
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung der Sperrbelege



ENDFUNCTION.
