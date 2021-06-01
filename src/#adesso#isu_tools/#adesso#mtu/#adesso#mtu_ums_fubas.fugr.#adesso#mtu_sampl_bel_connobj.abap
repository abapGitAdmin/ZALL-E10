FUNCTION /ADESSO/MTU_SAMPL_BEL_CONNOBJ.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      I_CO_EHA STRUCTURE  EHAUD OPTIONAL
*"      I_CO_ADR STRUCTURE  ADDR1_DATA OPTIONAL
*"      I_CO_COM STRUCTURE  ISU02_COMM_AUTO OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_CON) TYPE  EMG_OLDKEY
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung des Anschlußobjekts

  READ TABLE i_co_eha INDEX 1.

*  Version - Herne
*  IF i_co_eha-swerk = '1000'.
*    i_co_eha-swerk = '1001'.
*    MODIFY i_co_eha INDEX 1.
*  ENDIF.

* Version - Bochum
  i_co_eha-swerk = '4001'.
  MODIFY i_co_eha INDEX 1.



ENDFUNCTION.
