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
report zdr_minesweeper.

*PROGRAM demo_minesweeper_740.

class game definition.
  public section.
    methods:
      constructor,
      display.
  private section.
    types:
      begin of t_cell,
        bomb  type abap_bool,  " cell contains bomb y/n
        bombs type i,          " # of neighboring bombs
        state type char1,      " [h]idden, [v]isible, [f]lagged
      end of t_cell,
      t_cells type standard table of t_cell  with empty key,
      t_field type standard table of t_cells with empty key.
    data:
      field  type t_field,
      n      type i,        " dimension of field
      bombs  type i,        " # of existing bombs
      hidden type i,        " # of hidden cells
      flags  type i,        " # of flagged cells
      moves  type i,        " # of moves
      over   type char1,    " game over: [w]in, [d]ead
      header type string.   " HTML header string
    methods:
      at_click for event sapevent of cl_abap_browser importing action,
      detect importing value(x) type i value(y) type i.
endclass.

class game implementation.
  method constructor.
    data(wh) = `width:13px;height:18px`.
    header = replace(
      occ = 0 sub = `@` with = `background-color:` val =
     `<html><head><style type="text/css">` &&
     `.bx{text-decoration:none;cursor:hand;` &&
     wh && `} a{` && wh && `}` &&
     `.hid{@#404080} .flg{@red} .bmb{@black}` &&
     `.b0{@#e0e0e0} .b1{@lightblue} .b2{@lightgreen} .b3{@orange}` &&
     `</style>` &&
     `<script>function setloc(e){window.location=e;}</script>` &&
     `</head><body scroll="no"><table border="0">` ) ##NO_TEXT.
    data(size) = 10.
    data(level) = 3.
    cl_demo_input=>add_field( changing field = size ).
    cl_demo_input=>request(   changing field = level ).
    " size: 2..32
    n     = nmax( val1 = 2 val2 = nmin( val1 = size val2 = 32 ) ).
    " level: 1..5
    level = nmax( val1 = 1 val2 = nmin( val1 = level val2 = 5 ) ).
    data(threshold) = 100 - level * 10.
    " place hidden bombs randomly
    field = value #(
      let r = cl_abap_random_int=>create( seed = conv i( sy-uzeit )
                                          min  = 0
                                          max  = 99 ) in
      for i = 1 until i > n
      ( value #( for j = 1 until j > n
                 ( state = 'h'
                   bomb = cond #( when r->get_next( ) > threshold
                                    then 'X' ) ) ) ) ).
    " compute neighboring-bombs count for each cell, and overall count
    loop at field assigning field-symbol(<cells>).
      data(y) = sy-tabix.
      loop at <cells> assigning field-symbol(<cell>).
        if <cell>-bomb = 'X'.
          bombs = bombs + 1.
        else.
          data(x) = sy-tabix.
          <cell>-bombs = reduce i(
            init b = 0
            for  i = nmax( val1 = 1 val2 = y - 1 )
            while i <= nmin( val1 = y + 1 val2 = n )
            for  j = nmax( val1 = 1 val2 = x - 1 )
            while j <= nmin( val1 = x + 1 val2 = n )
            let <f> = field[ i ][ j ] in
            next b = cond #( when <f>-bomb = 'X' then b + 1 else b ) ).
        endif.
      endloop.
    endloop.
    hidden = n * n.
    set handler at_click.
  endmethod.

  method display.
    cl_abap_browser=>show_html(
     title        = conv cl_abap_browser=>title( sy-title )
     size         = cond #( when n < 20 then cl_abap_browser=>small
                                        else cl_abap_browser=>medium )
     format       = cl_abap_browser=>portrait
     context_menu = 'X'
     html_string  =
       reduce string(
        init  h = header
        for   y = 1 until y > n
        next  h = h && |<tr{ cond #( when over <> '' then
                          ` onclick="setloc('sapevent:ovr');"` ) }>| &&
         reduce string(
          init k = ``
          for  x = 1  until x > n
          let  c = field[ y ][ x ]
               " CSS style (hid,flg,b0,...,b3) of cell
               style = cond string(
                         when over <> '' and
                              c-bomb = 'X'  " bomb
                           then `bmb`
                         when c-state = 'f' " flagged
                           then `flg`
                         when c-state = 'v' " visible
                           then |b{ nmin( val1 = c-bombs val2 = 3 ) }|
                         when over <> ''    " empty
                           then `b0`
                         else  `hid` ) " hidden
               pos = |x{ x width = 2 align = right pad = '0' }| &
                     |y{ y width = 2 align = right pad = '0' }|
          in
          next k = |{ k }<td class={ style }| &&
                   cond #( when c-state = 'v'
                    then |><a>{ c-bombs }</a>| " bombs value
                    else " HTML events on cell (left: try; right: flag)
                     | oncontextmenu="setloc('sapevent:flg{ pos }');| &
                     |return false;"><a href="sapevent:try{ pos }">| &
                     |<div class="bx"/></a>| )
                   && `</td>` )
         && `</tr>` )
       && `</table><br>`
       && cond #(
           when over = 'd' then `*** Bomb  -  Game over ***`
           when over = 'w' then |Finished in { moves } moves!| )
       && `</body></html>` ).
  endmethod.

  method at_click.
    if over <> ''.  " game is over, final click
      cl_abap_browser=>close_browser( ).
      leave program.
    endif.
    moves = moves + 1.
    data(x) = conv i( action+4(2) ).
    data(y) = conv i( action+7(2) ).
    assign field[ y ][ x ] to field-symbol(<cell>).
    if action(3) = 'try'.
      if <cell>-bomb = 'X'.
        over = 'd'.  " hit bomb -> game over
      else.
        detect( x = x y = y ).
      endif.
    else.  " action(3) = 'flg'
      if <cell>-state = 'h'.
        <cell>-state = 'f'.  flags = flags + 1.  hidden = hidden - 1.
      else.
        <cell>-state = 'h'.  flags = flags - 1.  hidden = hidden + 1.
      endif.
    endif.
    if hidden = 0 and flags = bombs .
      over = 'w'.  " all cells opened, all bombs found -> win
    endif.
    display( ).
  endmethod.

  method detect.
    check x >= 1 and x <= n and y >= 1 and y <= n.
    assign field[ y ][ x ] to field-symbol(<cell>).
    case <cell>-state.
      when 'v'.  return.
      when 'h'.  hidden = hidden - 1.
      when 'f'.  flags = flags - 1.
    endcase.
    <cell>-state = 'v'.
    check <cell>-bombs = 0.
    data(u) = y - 1.
    data(d) = y + 1.
    data(l) = x - 1.
    data(r) = x + 1.
    detect( y = u x = l ).
    detect( y = u x = x ).
    detect( y = u x = r ).
    detect( y = y x = l ).
    detect( y = y x = r ).
    detect( y = d x = l ).
    detect( y = d x = x ).
    detect( y = d x = r ).
  endmethod.

endclass.

start-of-selection.
  new game( )->display( ).
