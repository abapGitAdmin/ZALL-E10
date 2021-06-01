*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 21.08.2019 at 09:40:56
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADZ/MDC_MAIN...................................*
DATA:  BEGIN OF STATUS_/ADZ/MDC_MAIN                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADZ/MDC_MAIN                 .
CONTROLS: TCTRL_/ADZ/MDC_MAIN
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */ADZ/MDC_MAIN                 .
TABLES: /ADZ/MDC_MAIN                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
