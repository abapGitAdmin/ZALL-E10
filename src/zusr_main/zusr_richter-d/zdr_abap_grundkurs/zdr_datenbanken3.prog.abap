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
report zdr_datenbanken3.

types: begin of lty_join_struv,
         carrid   type spfli-carrid,
*         connid   type spfli-connid,
         carrname type scarr-carrname,
         dauer    type spfli-fltime,
       end of lty_join_struv.

data: gt_spfli  type table of spfli,
      gs_spfli  type spfli,
      gt_join   type table of lty_join_struv,
      gs_join   type lty_join_struv,
      gv_fltime type s_fltime.

*select avg( fltime )
*  from spfli
*  into gv_fltime
*  where carrid = 'LH'.

select spfli~carrid carrname avg( fltime ) as dauer
  from spfli join scarr on spfli~carrid = scarr~carrid
  into corresponding fields of table gt_join
*  where spfli~carrid = 'LH' or spfli~carrid = 'AH'
  group by spfli~carrid carrname
  having avg( fltime ) > 400
  order by dauer ascending.

if sy-subrc <> 0.
  write 'Fehler!'.
else.
  write: 'Erfolg'.
endif.
