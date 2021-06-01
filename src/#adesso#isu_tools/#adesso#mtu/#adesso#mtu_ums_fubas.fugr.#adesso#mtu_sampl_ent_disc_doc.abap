FUNCTION /ADESSO/MTU_SAMPL_ENT_DISC_DOC.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IDCD_HEADER STRUCTURE  /ADESSO/MT_EMG_DDC_HEADER OPTIONAL
*"      IDCD_FKKMAZ STRUCTURE  /ADESSO/MT_EMG_DDC_DOCU_SEL OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_DCD) LIKE  EDISCDOC-DISCNO
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung der Sperrbelege (Entladung)





ENDFUNCTION.
