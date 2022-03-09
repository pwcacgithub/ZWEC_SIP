*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 07.05.2021 at 09:46:18
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZTCU_SIPCONFIG..................................*
DATA:  BEGIN OF STATUS_ZTCU_SIPCONFIG                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTCU_SIPCONFIG                .
CONTROLS: TCTRL_ZTCU_SIPCONFIG
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZTCU_SIPCONFIG                .
TABLES: ZTCU_SIPCONFIG                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
