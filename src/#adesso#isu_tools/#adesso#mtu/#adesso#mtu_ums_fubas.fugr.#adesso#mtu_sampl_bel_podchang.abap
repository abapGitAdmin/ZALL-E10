FUNCTION /ADESSO/MTU_SAMPL_BEL_PODCHANG.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IPOC_UIHEAD STRUCTURE  EUI_AUTO_HEAD OPTIONAL
*"      IPOC_UISRC STRUCTURE  EUI_AUTO_SOURCE OPTIONAL
*"      IPOC_UITANL STRUCTURE  EMG_UI_AUTO_ANLAGE OPTIONAL
*"      IPOC_UITLZW STRUCTURE  EUI_AUTO_LZW OPTIONAL
*"      IPOC_UIEXT STRUCTURE  EUI_AUTO_EXTUI OPTIONAL
*"      IPOC_UIGRID STRUCTURE  EUI_AUTO_GRID OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_POC) TYPE  EMG_OLDKEY
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung für Ändern Zählpunkt





ENDFUNCTION.
