*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_/ADESSO/INM_MAIL
*   generation date: 10.07.2015 at 11:21:46
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_/ADESSO/INM_MAIL   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
