************************************************************************
****
*            _
*   __ _  __| | ___  ___ ___  ___
*  / _` |/ _` |/ _ \/ __/ __|/ _ \
* | (_| | (_| |  __/\__ \__ \ (_) |
*  \__,_|\__,_|\___||___/___/\___/
************************************************************************
*******
*
*
*&
************************************************************************
*******
REPORT zls_datenbanken2.

DATA: gt_studis TYPE TABLE OF zls_tstudiengang,
      gs_studis TYPE zls_tstudiengang.

gs_studis-studiengangid = 7.
gs_studis-studiengang = 'Angewandte Biologie'.
APPEND gs_studis TO gt_studis.
CLEAR gs_studis.

gs_studis-studiengangid = 8.
gs_studis-studiengang = 'Chemie'.
APPEND gs_studis TO gt_studis.

* INSERT zls_tstudiengang FROM gs_studis.
* UPDATE zls_tstudiengang FROM gs_studis.
* MODIFY zls_tstudiengang FROM TABLE gt_studis.
DELETE FROM zls_tstudiengang WHERE studiengangid = 7.

IF sy-subrc <> 0.
  WRITE 'Fehler!'.
ELSE.
  WRITE 'Erfolg'.
ENDIF.
