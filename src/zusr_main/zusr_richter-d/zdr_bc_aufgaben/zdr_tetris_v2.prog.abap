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
report zdr_tetris_v2.

class: lcl_event_handler definition deferred.

include zdr_tetris_v2_setup.
include zdr_tetris_v2_update.

start-of-selection.
  call screen 100.

*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module status_0100 output.
  set pf-status '100'.
  set titlebar 'TETRIS'.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  CREATE_GAME  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module create_game output.
  if gr_cont is initial.
    perform creat_fieldcat.
    perform create_alv.
    perform create_timer.
  endif.
endmodule.
