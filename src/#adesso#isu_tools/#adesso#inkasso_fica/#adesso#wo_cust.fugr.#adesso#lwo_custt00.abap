*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 13.01.2021 at 17:46:10
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADESSO/WO_BEGR.................................*
DATA:  BEGIN OF STATUS_/ADESSO/WO_BEGR               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/WO_BEGR               .
CONTROLS: TCTRL_/ADESSO/WO_BEGR
            TYPE TABLEVIEW USING SCREEN '0005'.
*...processing: /ADESSO/WO_BGUS.................................*
DATA:  BEGIN OF STATUS_/ADESSO/WO_BGUS               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/WO_BGUS               .
CONTROLS: TCTRL_/ADESSO/WO_BGUS
            TYPE TABLEVIEW USING SCREEN '0006'.
*...processing: /ADESSO/WO_CUST.................................*
DATA:  BEGIN OF STATUS_/ADESSO/WO_CUST               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/WO_CUST               .
CONTROLS: TCTRL_/ADESSO/WO_CUST
            TYPE TABLEVIEW USING SCREEN '0001'.
*...processing: /ADESSO/WO_FREI.................................*
DATA:  BEGIN OF STATUS_/ADESSO/WO_FREI               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/WO_FREI               .
CONTROLS: TCTRL_/ADESSO/WO_FREI
            TYPE TABLEVIEW USING SCREEN '0007'.
*...processing: /ADESSO/WO_IGRD.................................*
DATA:  BEGIN OF STATUS_/ADESSO/WO_IGRD               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/WO_IGRD               .
CONTROLS: TCTRL_/ADESSO/WO_IGRD
            TYPE TABLEVIEW USING SCREEN '0002'.
*...processing: /ADESSO/WO_ORGA.................................*
DATA:  BEGIN OF STATUS_/ADESSO/WO_ORGA               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/WO_ORGA               .
CONTROLS: TCTRL_/ADESSO/WO_ORGA
            TYPE TABLEVIEW USING SCREEN '0004'.
*...processing: /ADESSO/WO_VKS..................................*
DATA:  BEGIN OF STATUS_/ADESSO/WO_VKS                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/WO_VKS                .
CONTROLS: TCTRL_/ADESSO/WO_VKS
            TYPE TABLEVIEW USING SCREEN '0003'.
*.........table declarations:.................................*
TABLES: */ADESSO/WO_BEGR               .
TABLES: */ADESSO/WO_BGUS               .
TABLES: */ADESSO/WO_CUST               .
TABLES: */ADESSO/WO_FREI               .
TABLES: */ADESSO/WO_IGRD               .
TABLES: */ADESSO/WO_IGRDT              .
TABLES: */ADESSO/WO_ORGA               .
TABLES: */ADESSO/WO_VKS                .
TABLES: */ADESSO/WO_VKST               .
TABLES: /ADESSO/WO_BEGR                .
TABLES: /ADESSO/WO_BGUS                .
TABLES: /ADESSO/WO_CUST                .
TABLES: /ADESSO/WO_FREI                .
TABLES: /ADESSO/WO_IGRD                .
TABLES: /ADESSO/WO_IGRDT               .
TABLES: /ADESSO/WO_ORGA                .
TABLES: /ADESSO/WO_VKS                 .
TABLES: /ADESSO/WO_VKST                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
