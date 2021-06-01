*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 28.10.2019 at 15:30:16
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADZ/BDR_DEVCONF................................*
DATA:  BEGIN OF STATUS_/ADZ/BDR_DEVCONF              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADZ/BDR_DEVCONF              .
CONTROLS: TCTRL_/ADZ/BDR_DEVCONF
            TYPE TABLEVIEW USING SCREEN '0010'.
*...processing: /ADZ/BDR_MAIN...................................*
DATA:  BEGIN OF STATUS_/ADZ/BDR_MAIN                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADZ/BDR_MAIN                 .
CONTROLS: TCTRL_/ADZ/BDR_MAIN
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */ADZ/BDR_DEVCONF              .
TABLES: */ADZ/BDR_MAIN                 .
TABLES: /ADZ/BDR_DEVCONF               .
TABLES: /ADZ/BDR_MAIN                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
