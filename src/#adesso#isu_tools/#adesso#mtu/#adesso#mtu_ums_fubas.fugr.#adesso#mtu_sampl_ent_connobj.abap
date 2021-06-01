FUNCTION /ADESSO/MTU_SAMPL_ENT_CONNOBJ.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      ICON_CO_EHA STRUCTURE  /ADESSO/MT_EHAUD OPTIONAL
*"      ICON_CO_ADR STRUCTURE  /ADESSO/MT_ADDR1_DATA OPTIONAL
*"      ICON_CO_COM STRUCTURE  /ADESSO/MT_ISU02_COMM_AUTO OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_CON) LIKE  EHAUISU-HAUS
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung des Anschlußobjekts (Entladung)





ENDFUNCTION.
