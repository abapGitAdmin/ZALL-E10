*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_/ADESSO/EC_TARIF
*   generation date: 06.08.2015 at 14:06:09
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_/ADESSO/EC_TARIF   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
