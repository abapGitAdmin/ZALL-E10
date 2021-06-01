FUNCTION /ADESSO/MTU_SAMPL_ENT_INSTLNCH.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      ICH_KEY STRUCTURE  /ADESSO/MT_EANLHKEY OPTIONAL
*"      ICH_DATA STRUCTURE  /ADESSO/MT_EMG_EANL OPTIONAL
*"      ICH_RCAT STRUCTURE  /ADESSO/MT_ISU_AITTYP OPTIONAL
*"      ICH_FACTS STRUCTURE  /ADESSO/MT_FACTS OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_ICH) LIKE  EANL-ANLAGE
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung der Anlagenänderungen (Entladung)



ENDFUNCTION.
