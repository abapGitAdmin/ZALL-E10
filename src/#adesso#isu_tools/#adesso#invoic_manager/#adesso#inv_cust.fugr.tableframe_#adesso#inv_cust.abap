*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_/ADESSO/INV_CUST
*   generation date: 17.12.2015 at 03:24:07
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_/ADESSO/INV_CUST   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
