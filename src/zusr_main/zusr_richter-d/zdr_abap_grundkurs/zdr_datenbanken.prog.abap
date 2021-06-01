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
report zdr_datenbanken.

data: gt_spfli type table of spfli,
      gs_spfli type spfli.

*select * from spfli into table gt_spfli.
select * from spfli into table gt_spfli where carrid = 'LH'.
select single * from spfli into gs_spfli where carrid = 'LH'.

if sy-subrc <> 0.
  write 'Fehler!!'.
else.
  loop at gt_spfli into gs_spfli.
    write: gs_spfli-carrid, gs_spfli-connid, /.
  endloop.
endif.
