FUNCTION /ADESSO/MTU_SAMPL_BEL_DEVGRP.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IDGR_EDEVGR STRUCTURE  EMG_EDEVGR OPTIONAL
*"      IDGR_DEVICE STRUCTURE  V_EGER OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_DGR) TYPE  EMG_OLDKEY
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung der Gerätegruppierung



ENDFUNCTION.
