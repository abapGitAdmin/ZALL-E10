*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_/ADESSO/INK_EVUZ
*   generation date: 30.10.2019 at 15:30:01
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_/ADESSO/INK_EVUZ   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
