*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_/ADESSO/MTE_GPZS
*   generation date: 16.06.2015 at 16:24:37
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_/ADESSO/MTE_GPZS   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
