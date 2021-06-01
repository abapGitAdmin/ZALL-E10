*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 10.08.2018 at 09:24:51
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADESSO/CUST_KPF................................*
DATA:  BEGIN OF STATUS_/ADESSO/CUST_KPF              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/CUST_KPF              .
CONTROLS: TCTRL_/ADESSO/CUST_KPF
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */ADESSO/CUST_KPF              .
TABLES: /ADESSO/CUST_KPF               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
