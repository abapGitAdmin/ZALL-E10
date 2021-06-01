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
report zdr_fluege message-id zdr_messages.

tables sscrfields.

data: lt_fluege type table of spfli,
      ls_flug   type spfli.

selection-screen comment 1(83) text.
selection-screen uline.

selection-screen begin of line.
selection-screen comment (25) text3.
parameters: pa_ges type spfli-carrid.
selection-screen comment 50(50) text2.
selection-screen end of line.

selection-screen skip 2.

selection-screen pushbutton 27(20) btn user-command del.

initialization.
  text = 'Wilkommen zum Selektionsbildschirm des Testprogramms.'.
  text2 = 'Bitte nur gültige Werte eingeben.'.
  text3 = 'Fluggesellschaft:'.
  btn = 'Eingabe löschen'.

at selection-screen.
  if sscrfields-ucomm = 'DEL'.
    clear pa_ges.
  endif.

start-of-selection.
  call function 'Z_DR_GET_FLUEGE'
    exporting
      iv_carrid = pa_ges
    importing
      et_fluege = lt_fluege
    exceptions
      no_auth   = 7.

  case sy-subrc.
    when 0.
      format frames on.
      format color 1.
      write: / 'Verbindung', 12 'Abflugort', 35(17) 'Ankunftsort'.
      format color off.
      write /.
      uline (51).
      loop at lt_fluege into ls_flug.
        format color 2.
        write: / '|', ls_flug-connid, '|', (15) ls_flug-cityfrom,
              26 '|', 31 ls_flug-cityto, 51 '|'.
        hide ls_flug.
        write: / '|', 8 '|', ls_flug-countryfr under ls_flug-cityfrom,
              26 '|', ls_flug-countryto under ls_flug-cityto, 51 '|'.
        hide ls_flug.
        new-line.
        uline (51).
        hide ls_flug.
      endloop.
      message s000 with pa_ges.
    when 7.
      write 'Keine Berechtigung'.
    when others.
  endcase.

at line-selection.
  check sy-lsind = 1.
  check sy-lilli > 5.
  format color 1.
  write: / 'Abflugzeit', 15 'Ankunftzeit', 30 'Flugzeit', 40(20) 'Entfernung'.
  format color off.
  write /.
  uline (65).
  format color 2.
  write: / '|', ls_flug-deptime, 14 '|', ls_flug-arrtime,
        29 '|', ls_flug-fltime, 44 '|',  ls_flug-distance,
           ' ', ls_flug-distid, 65 '|'.
  uline (65).
  message s001 with ls_flug-connid.
