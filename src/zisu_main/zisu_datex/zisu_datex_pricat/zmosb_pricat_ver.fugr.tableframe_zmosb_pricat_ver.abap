*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZMOSB_PRICAT_VER
*   generation date: 03.01.2018 at 08:54:03
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZMOSB_PRICAT_VER   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
