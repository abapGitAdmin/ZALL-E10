************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: BOECKMANN-C                                  Datum: 20.05.2019
*
* Beschreibung: Datenbanken 2
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************
REPORT zboe_datenbanken2.

DATA: gt_studis TYPE TABLE OF zboe_studiegang,
      gs_studis TYPE zboe_studiegang.

gs_studis-studiengangid = 7.
gs_studis-studiengang = 'Angewandte Mathematik'.
APPEND gs_studis TO gt_studis.
CLEAR gs_studis.

gs_studis-studiengangid = 8.
gs_studis-studiengang = 'Soziologie'.
APPEND gs_studis TO gt_studis.

*INSERT zboe_studenten FROM gs_studis.
*UPDATE zboe_studiegang FROM gs_studis.
MODIFY zboe_studiegang FROM TABLE gt_studis.

IF sy-subrc <> 0.
  WRITE: 'Fehler!'.
ELSE.
  WRITE: 'Erfolg!'.
ENDIF.
