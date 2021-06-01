*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_/ADESSO/EC_PAUSC
*   generation date: 20.10.2015 at 11:21:42
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_/ADESSO/EC_PAUSC   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
