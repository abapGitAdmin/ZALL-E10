*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_/ADESSO/REKTEXTE
*   generation date: 01.02.2017 at 09:52:05
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_/ADESSO/REKTEXTE   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
