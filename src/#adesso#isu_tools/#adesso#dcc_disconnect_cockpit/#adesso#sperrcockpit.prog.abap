***&---------------------------------------------------------------------*
***& Report  /ADESSO/SPERRCOCKPIT
***&---------------------------------------------------------------------*
*REPORT /ADESSO/SPERRCOCKPIT.
**
*  PARAMETERS:
*    P_TEXT    TYPE CHAR20,
*    P_INT     TYPE I.
*
*  START-OF-SELECTION.
**    WRITE P_TEXT.
*
*    DATA: LT_EDISCDOC  TYPE STANDARD TABLE OF EDISCDOC
*                                WITH DEFAULT KEY,
*          LS_EDISCDOC  TYPE EDISCDOC,
*          PCOUNT          TYPE I.
*
*    SELECT *  INTO TABLE LT_EDISCDOC
*      FROM EDISCDOC.
*
*    IF P_INT = ''.
*      P_INT = 10.
*    ENDIF.
*    PCOUNT = 1.
*
*    LOOP AT LT_EDISCDOC  INTO LS_EDISCDOC.
*      WRITE / LS_EDISCDOC-DISCNO.
*      WRITE / LS_EDISCDOC-DISCREASON.
*      WRITE / LS_EDISCDOC-STATUS.
*      WRITE / LS_EDISCDOC-AEDAT.
*      WRITE / LS_EDISCDOC-AENAM.
*      IF PCOUNT = P_INT.
*         ULINE.
*         PCOUNT = 1.
*      ELSE.
*        ADD 1 TO PCOUNT.
*      ENDIF.
*
*    ENDLOOP.


****** Bastelstunde ******

*&-----------------------------------------------*
*& Report  /ADESSO/SPERRCOCKPIT
*&
*&-----------------------------------------------*

REPORT  /ADESSO/SPERRCOCKPIT             .

TABLES:   EDISCDOC.

TYPE-POOLS: SLIS.                                 "ALV Declarations
*Data Declaration
*----------------


TYPES: BEGIN OF T_EDISCDOC,
  DISCNO TYPE EDISCDOC-DISCNO, "Sperrbelegnummer
  DISCREASON TYPE EDISCDOC-DISCREASON, "Sperrgrund
  STATUS TYPE EDISCDOC-STATUS, "Status des Sperrbelegs
  AEDAT TYPE EDISCDOC-AEDAT, "Datum der letzten Änderung
  AENAM TYPE EDISCDOC-AENAM, "Name des Sachbarbeiters
  END OF T_EDISCDOC.


DATA: IT_EDISCDOC TYPE STANDARD TABLE OF T_EDISCDOC,
      WA_EDISCDOC TYPE T_EDISCDOC.

*ALV data declarations
DATA: FIELDCATALOG TYPE SLIS_T_FIELDCAT_ALV WITH HEADER LINE,
      GD_TAB_GROUP TYPE SLIS_T_SP_GROUP_ALV,
      GD_LAYOUT    TYPE SLIS_LAYOUT_ALV,
      GD_REPID     LIKE SY-REPID.


************************************************************************
*Start-of-selection.
START-OF-SELECTION.

PERFORM DATA_RETRIEVAL.
PERFORM BUILD_FIELDCATALOG.
PERFORM BUILD_LAYOUT.
PERFORM DISPLAY_ALV_REPORT.

*----------------------------------------------------------------------*
*       Feldkatalog zusammenbauen
*----------------------------------------------------------------------*
FORM BUILD_FIELDCATALOG.

* Beware though, you need to ensure that all fields required are
* populated. When using some of functionality available via ALV, such as
* total. You may need to provide more information than if you were
* simply displaying the result
*               I.e. Field type may be required in-order for
*                    the 'TOTAL' function to work.
  DATA ICOUNT TYPE I VALUE '0'.

*  FIELDCATALOG-FIELDNAME   = 'AUSWAHL'.
*  FIELDCATALOG-SELTEXT_M   = 'Auswahl'.
*  FIELDCATALOG-COL_POS     = ICOUNT.
*  FIELDCATALOG-CHECKBOX   = 'X'.
*  APPEND FIELDCATALOG TO FIELDCATALOG.
*  CLEAR  FIELDCATALOG.
*  ADD 1 TO ICOUNT.

  FIELDCATALOG-FIELDNAME   = 'DISCNO'.
  FIELDCATALOG-SELTEXT_M   = 'Sperrbelegnummer'.
  FIELDCATALOG-COL_POS     = ICOUNT.
  FIELDCATALOG-OUTPUTLEN   = 12.
  APPEND FIELDCATALOG TO FIELDCATALOG.
  CLEAR  FIELDCATALOG.
  ADD 1 TO ICOUNT.

  FIELDCATALOG-FIELDNAME   = 'DISCREASON'.
  FIELDCATALOG-SELTEXT_M   = 'Sperrgrund'.
  FIELDCATALOG-COL_POS     = ICOUNT.
  FIELDCATALOG-OUTPUTLEN   = 2.
  APPEND FIELDCATALOG TO FIELDCATALOG.
  CLEAR  FIELDCATALOG.
  ADD 1 TO ICOUNT.

  FIELDCATALOG-FIELDNAME   = 'STATUS'.
  FIELDCATALOG-SELTEXT_M   = 'Status des Sperrbelegs'.
  FIELDCATALOG-COL_POS     = ICOUNT.
  FIELDCATALOG-OUTPUTLEN   = 2.
  APPEND FIELDCATALOG TO FIELDCATALOG.
  CLEAR  FIELDCATALOG.
  ADD 1 TO ICOUNT.

  FIELDCATALOG-FIELDNAME   = 'AEDAT'.
  FIELDCATALOG-SELTEXT_M   = 'Datum der letzten Änderung'.
  FIELDCATALOG-COL_POS     = ICOUNT.
  FIELDCATALOG-OUTPUTLEN   = 8.
  APPEND FIELDCATALOG TO FIELDCATALOG.
  CLEAR  FIELDCATALOG.
  ADD 1 TO ICOUNT.

  FIELDCATALOG-FIELDNAME   = 'AENAM'.
  FIELDCATALOG-SELTEXT_M   = 'Name des Sachbarbeiters'.
  FIELDCATALOG-COL_POS     = ICOUNT.
  FIELDCATALOG-OUTPUTLEN   = 12.
  APPEND FIELDCATALOG TO FIELDCATALOG.
  CLEAR  FIELDCATALOG.
ENDFORM.                    " BUILD_FIELDCATALOG


*----------------------------------------------------------------------*
*       Layout zusammenbauen
*----------------------------------------------------------------------*
FORM BUILD_LAYOUT.
  GD_LAYOUT-NO_INPUT          = 'X'.
  GD_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
  GD_LAYOUT-TOTALS_TEXT       = 'Totals'(201).
*  gd_layout-totals_only        = 'X'.
*  gd_layout-f2code            = 'DISP'.  "Sets fcode for when double
*                                         "click(press f2)
  gd_layout-zebra             = 'X'.
*  gd_layout-group_change_edit = 'X'.
*  gd_layout-header_text       = 'helllllo'.
ENDFORM.                    " BUILD_LAYOUT


*----------------------------------------------------------------------*
*       Report anzeigen
*----------------------------------------------------------------------*
FORM DISPLAY_ALV_REPORT.
  GD_REPID = SY-REPID.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
       EXPORTING
            I_CALLBACK_PROGRAM      = GD_REPID
*            i_callback_top_of_page   = 'TOP-OF-PAGE'  "see FORM
*            i_callback_user_command = 'USER_COMMAND'
*            i_grid_title           = outtext
            IS_LAYOUT               = GD_LAYOUT
            IT_FIELDCAT             = FIELDCATALOG[]
*            it_special_groups       = gd_tabgroup
*            IT_EVENTS                = GT_XEVENTS
            I_SAVE                  = 'X'
*            is_variant              = z_template

       TABLES
            T_OUTTAB                = IT_EDISCDOC
       EXCEPTIONS
            PROGRAM_ERROR           = 1
            OTHERS                  = 2.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " DISPLAY_ALV_REPORT


*----------------------------------------------------------------------*
*       Daten auslesen
*----------------------------------------------------------------------*
FORM DATA_RETRIEVAL.

SELECT DISCNO DISCREASON STATUS AEDAT AENAM
* up to 10 rows
  FROM EDISCDOC
  INTO TABLE IT_EDISCDOC.
ENDFORM.                    " DATA_RETRIEVAL
