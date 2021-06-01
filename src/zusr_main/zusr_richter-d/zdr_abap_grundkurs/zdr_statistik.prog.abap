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
report zdr_statistik.

tables: spfli, scarr.

types: begin of stat_type,
         carrid   like spfli-carrid,
         carrname like scarr-carrname,
         dauer    like spfli-fltime,
       end of stat_type.

data: gs_itab type stat_type,
      gt_itab type table of stat_type.

select spfli~carrid carrname max( fltime ) as dauer
  from spfli join scarr on spfli~carrid = scarr~carrid
  into corresponding fields of table gt_itab
  where fltype = ' '
  group by spfli~carrid carrname
  having max( fltime ) > 420
  order by dauer descending.

write: / 'Hello'.
loop at gt_itab into gs_itab.
  write: / gs_itab-carrid, gs_itab-carrname, gs_itab-dauer.
endloop.
