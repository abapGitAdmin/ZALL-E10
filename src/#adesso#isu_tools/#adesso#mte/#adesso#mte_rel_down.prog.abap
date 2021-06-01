*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTE_REL_DOWN
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT /adesso/mte_rel_down.

DATA: irel LIKE TABLE OF /adesso/mte_rel.
TABLES: /adesso/mte_rel.

SELECT-OPTIONS: sfirma FOR /adesso/mte_rel-firma,
                sobject FOR /adesso/mte_rel-object.

START-OF-SELECTION.

SELECT * FROM /adesso/mte_rel INTO TABLE irel
             WHERE firma IN sfirma
             AND   object IN sobject.

             CALL FUNCTION 'DOWNLOAD'
              EXPORTING
*                BIN_FILESIZE                  = ' '
*                CODEPAGE                      = ' '
*                FILENAME                      = ' '
                filetype                      = 'DAT'
*                ITEM                          = ' '
*                MODE                          = ' '
*                WK1_N_FORMAT                  = ' '
*                WK1_N_SIZE                    = ' '
*                WK1_T_FORMAT                  = ' '
*                WK1_T_SIZE                    = ' '
*                FILEMASK_MASK                 = ' '
*                FILEMASK_TEXT                 = ' '
*                FILETYPE_NO_CHANGE            = ' '
*                FILEMASK_ALL                  = ' '
*                FILETYPE_NO_SHOW              = ' '
*                SILENT                        = 'S'
*                COL_SELECT                    = ' '
*                COL_SELECTMASK                = ' '
*                NO_AUTH_CHECK                 = ' '
*              IMPORTING
*                ACT_FILENAME                  =
*                ACT_FILETYPE                  =
*                FILESIZE                      =
*                CANCEL                        =
               TABLES
                 data_tab                      = irel
*                FIELDNAMES                    =
*              EXCEPTIONS
*                INVALID_FILESIZE              = 1
*                INVALID_TABLE_WIDTH           = 2
*                INVALID_TYPE                  = 3
*                NO_BATCH                      = 4
*                UNKNOWN_ERROR                 = 5
*                GUI_REFUSE_FILETRANSFER       = 6
*                CUSTOMER_ERROR                = 7
*                OTHERS                        = 8
                       .
             IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
             ENDIF.
