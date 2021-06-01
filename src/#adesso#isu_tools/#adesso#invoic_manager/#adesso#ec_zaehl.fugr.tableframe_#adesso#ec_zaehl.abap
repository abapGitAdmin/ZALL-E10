*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_/ADESSO/EC_ZAEHL
*   generation date: 22.07.2015 at 11:50:01
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_/ADESSO/EC_ZAEHL   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
