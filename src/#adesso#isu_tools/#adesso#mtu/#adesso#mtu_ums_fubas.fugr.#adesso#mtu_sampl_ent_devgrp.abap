FUNCTION /ADESSO/MTU_SAMPL_ENT_DEVGRP.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IDGR_EDEVGR STRUCTURE  /ADESSO/MT_EMG_EDEVGR OPTIONAL
*"      IDGR_DEVICE STRUCTURE  /ADESSO/MT_V_EGER OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_DGR) LIKE  EDEVGR-DEVGRP
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung der Gerätegruppierung (Entladung)





ENDFUNCTION.
