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
program zdr_tetris.

class game definition.
  public section.
    methods:
      constructor,
      display.
  private section.
    types:
      begin of ty_cell,
        color type i,
      end of ty_cell,
      ty_line  type standard table of ty_cell with empty key,
      ty_field type standard table of ty_line with empty key.
*    CONSTANTS:.
    data:
      timer   type ref to cl_gui_timer,
      header  type string,
      body    type string,
      trailer type string,
      t_line  type ty_line,
      t_field type ty_field,
      s_cell  type ty_cell,
      width   type i value 10,
      height  type i value 20.
    methods:
      at_event for event sapevent of cl_abap_browser importing action,
      on_finished for event finished of cl_gui_timer.
endclass.

class game implementation.
  method constructor.
    header = `<html>` &&
               `<head>` &&
                 `<style type="text/css">` &&
                   `* {` &&
                     `margin: 0px;` &&
                   `}` &&
                   `.body {` &&
                     `display: flex;` &&
                     `flex-direction: column;` &&
                     `align-items: center;` &&
                     `justify-content: center;` &&
                     `height: 100vh;` &&
                     `width: 100vw;` &&
                     `background-color: lightgrey;` &&
                   `}` &&
                   `.line {` &&
                     `display: flex;` &&
                   `}` &&
                   `.cell {` &&
                     `margin: 1px;` &&
                   `}` &&
                   `.c1 {` &&
                     `height: 15px;` &&
                     `width: 15px;` &&
                     `background-color: green;` &&
                   `}` &&
                   `.c2 {` &&
                     `height: 15px;` &&
                     `width: 15px;` &&
                     `background-color: red;` &&
                   `}` &&
                 `</style>` &&
                 `<script type="text/javascript">` &&
                   `function okd(e) {` &&
                     `c=window.event.keyCode;` &&
                     `window.location='sapevent:'+c;` &&
                   `}` &&
                   `document.onkeydown = okd;` &&
                 `</script>` &&
               `</head>` &&
               `<body scroll=no">`.

    trailer = `</body></html>`.

    do 20 times.
      if sy-index mod 4 = 0.
        s_cell-color = 1.
      else.
        s_cell-color = 2.
      endif.
      append s_cell to t_line.
    enddo.
    do 30 times.
      append t_line to t_field.
    enddo.

    create object timer.
    set handler on_finished for timer.
    set handler at_event.
  endmethod.

  method display.
    body = `<div class="body">` &&
      reduce string(
*        let w = 360 / 10 in
        init h = ``
        for <line> in t_field
        next h = h && `<div class="line">` &&
          reduce string(
           init k = ``
           for <cell> in <line>
           next k = k && |<div class="cell"><div class="c{ <cell>-color }"></div></div>|
        ) && `</div>`
      ) && `</div>`.

    cl_abap_browser=>show_html(
     title        = |Tetris d-.-b|
     size         = cl_abap_browser=>small
     format       = cl_abap_browser=>portrait
     context_menu = 'X'
     html_string  = header && body && trailer ).
*
*    timer->interval = 1.
*    timer->run( ).
*    write:1.
  endmethod.

  method at_event.
    "bewege die Form entsprechend falls möglich
  endmethod.

  method on_finished.
    "refresh display
  endmethod.

endclass.

start-of-selection.
  new game( )->display( ).
