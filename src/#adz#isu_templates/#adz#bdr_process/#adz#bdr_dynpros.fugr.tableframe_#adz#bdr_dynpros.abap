*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_/ADZ/BDR_DYNPROS
*   generation date: 28.10.2019 at 15:30:16
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_/ADZ/BDR_DYNPROS   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
