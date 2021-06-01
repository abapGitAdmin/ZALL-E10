************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: XXXXX-X                                      Datum: TT.MM.JJJJ
*
* Beschreibung:
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************
report zdr_datenbanken2.

data: gt_studis type table of zdr_studiengang,
      gs_studis type zdr_studiengang.

gs_studis-studiengangid = 7.
*gs_studis-studiengang = 'Geologie'.
*gs_studis-studiengang = 'Mathematik'.
gs_studis-studiengang = 'Angewandte Mathematik'.
append gs_studis to gt_studis.
clear gs_studis.

gs_studis-studiengangid = 8.
gs_studis-studiengang = 'Soziologie'.
append gs_studis to gt_studis.
clear gs_studis.

*insert zdr_studiengang from gs_studis.
*update zdr_studiengang from gs_studis.
*modify zdr_studiengang from table gt_studis.
delete from zdr_studiengang where studiengangid = 7.

*check sy-subrc = 0.
if sy-subrc <> 0.
  write: 'Fehler'.
else.
  write: 'Erfolg'.
endif.
