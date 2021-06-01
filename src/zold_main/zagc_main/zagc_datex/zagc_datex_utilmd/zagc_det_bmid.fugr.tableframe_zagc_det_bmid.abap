*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZAGC_DET_BMID
*   generation date: 24.03.2015 at 18:15:28 by user THIMEL.R
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZAGC_DET_BMID      .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
