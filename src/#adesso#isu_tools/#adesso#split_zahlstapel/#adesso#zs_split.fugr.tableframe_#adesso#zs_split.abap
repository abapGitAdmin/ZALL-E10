*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_/ADESSO/ZS_SPLIT
*   generation date: 05.12.2017 at 11:01:04
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_/ADESSO/ZS_SPLIT   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
