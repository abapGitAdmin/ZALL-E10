*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_/ADESSO/MDC_CUST
*   generation date: 16.02.2016 at 14:25:19
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_/ADESSO/MDC_CUST   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
