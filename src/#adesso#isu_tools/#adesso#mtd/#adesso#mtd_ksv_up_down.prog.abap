*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTD_KSV_UP_DOWN
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT /adesso/mtd_ksv_up_down.

TABLES: temksv, temob, temfirma.

SELECTION-SCREEN BEGIN OF BLOCK dwn WITH FRAME TITLE text-dwn.
SELECTION-SCREEN SKIP.
SELECT-OPTIONS firma FOR temfirma-firma DEFAULT 'EVU01'.
SELECT-OPTIONS object FOR temob-object.
PARAMETERS: download AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK dwn.

SELECTION-SCREEN BEGIN OF BLOCK upl WITH FRAME TITLE text-upl.
SELECTION-SCREEN SKIP.
PARAMETERS: upload AS CHECKBOX,
            split TYPE i DEFAULT 25.
SELECTION-SCREEN SKIP.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(35) text-ums.
PARAMETERS: firma_n LIKE temfirma-firma DEFAULT 'EVU01'.
SELECTION-SCREEN COMMENT 45(10) text-001.
PARAMETERS: cha_firm AS CHECKBOX.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK upl.

DATA  i_ksv LIKE temksv OCCURS 0 WITH HEADER LINE.
DATA  d_ksv LIKE temksv OCCURS 0 WITH HEADER LINE.
DATA: lcnt TYPE i, cnt TYPE i .

AT SELECTION-SCREEN.
  IF upload EQ download.
    MESSAGE e901(38) WITH 'Upload = Download geht nicht'.
  ENDIF.

  IF NOT download IS INITIAL.

    SELECT * FROM temksv INTO TABLE i_ksv
      WHERE firma IN firma
        AND object IN object.

    CALL FUNCTION 'DOWNLOAD'
        EXPORTING
*         BIN_FILESIZE            = ' '
*         CODEPAGE                = ' '
             filename                = 'C:\temp\ksv.txt'
             filetype                = 'ASC'
*         ITEM                    = ' '
*         MODE                    = ' '
*         WK1_N_FORMAT            = ' '
*         WK1_N_SIZE              = ' '
*         WK1_T_FORMAT            = ' '
*         WK1_T_SIZE              = ' '
*         FILEMASK_MASK           = ' '
*         FILEMASK_TEXT           = ' '
             filetype_no_change      = 'X'
*         FILEMASK_ALL            = ' '
*         FILETYPE_NO_SHOW        = ' '
*         SILENT                  = 'S'
*         COL_SELECT              = ' '
*         COL_SELECTMASK          = ' '
*         NO_AUTH_CHECK           = ' '
*    IMPORTING
*         ACT_FILENAME            =
*         ACT_FILETYPE            =
*         FILESIZE                =
*         CANCEL                  =
         TABLES
              data_tab                = i_ksv
*         FIELDNAMES              =
        EXCEPTIONS
             invalid_filesize        = 1
             invalid_table_width     = 2
             invalid_type            = 3
             no_batch                = 4
             unknown_error           = 5
             gui_refuse_filetransfer = 6
             OTHERS                  = 7
              .
    IF sy-subrc <> 0.
      WRITE :/ 'Subrc download', sy-subrc.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ELSEIF NOT upload IS INITIAL.

    CALL FUNCTION 'UPLOAD'
        EXPORTING
*         CODEPAGE                = ' '
             filename                = 'C:\temp\ksv.txt'
             filetype                = 'ASC'
*         ITEM                    = ' '
*         FILEMASK_MASK           = ' '
*         FILEMASK_TEXT           = ' '
             filetype_no_change      = 'X'
*         FILEMASK_ALL            = ' '
*         FILETYPE_NO_SHOW        = ' '
*         LINE_EXIT               = ' '
*         USER_FORM               = ' '
*         USER_PROG               = ' '
*         SILENT                  = 'S'
*    IMPORTING
*         FILESIZE                =
*         CANCEL                  =
*         ACT_FILENAME            =
*         ACT_FILETYPE            =
         TABLES
              data_tab                = i_ksv
        EXCEPTIONS
             conversion_error        = 1
             invalid_table_width     = 2
             invalid_type            = 3
             no_batch                = 4
             unknown_error           = 5
             gui_refuse_filetransfer = 6
             OTHERS                  = 7
              .
    IF sy-subrc <> 0.
      WRITE :/ 'Subrc upload', sy-subrc.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.

*>> Modify auf TEMKSV in Paketen wegen Laufzeit

      DESCRIBE TABLE i_ksv LINES lcnt.
      WRITE :/ lcnt, 'KSV-Einträge eingelesen.'.
      SKIP.


      DIVIDE lcnt BY split.
      ADD 1 TO lcnt.

      DO split TIMES.
        LOOP AT i_ksv INTO d_ksv.
         IF cha_firm ='X'.
          MOVE  firma_n TO d_ksv-firma.
         ENDIF.
          APPEND d_ksv.
          DELETE i_ksv.
          ADD 1 TO cnt.
          IF cnt GE lcnt.
            EXIT.
          ENDIF.
        ENDLOOP.

        MODIFY temksv FROM TABLE d_ksv.
        WRITE:/ sy-dbcnt, 'KSV-Einträge geschrieben.'.
        COMMIT WORK.
        REFRESH d_ksv.
        CLEAR cnt.

      ENDDO.
    ENDIF.

  ENDIF.
