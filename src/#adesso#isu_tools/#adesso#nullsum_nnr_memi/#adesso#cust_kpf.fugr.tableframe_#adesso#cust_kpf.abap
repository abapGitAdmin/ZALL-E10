*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_/ADESSO/CUST_KPF
*   generation date: 10.08.2018 at 09:24:42
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_/ADESSO/CUST_KPF   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
