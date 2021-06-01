*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_/ADESSO/INKBIRTH
*   generation date: 23.05.2017 at 15:18:08
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_/ADESSO/INKBIRTH   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
