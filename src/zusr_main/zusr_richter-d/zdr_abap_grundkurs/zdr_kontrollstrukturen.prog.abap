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
report zdr_kontrollstrukturen.

parameters: p_name  type string,
            p_alter type i.

data: lv_i type i.

write p_name.

if p_alter >= 6 and p_alter < 20.
  write 'Schüler'.
elseif p_alter < 26 or not p_name = 'KEVIN'.
  write 'Student'.
else.
  write 'Mitarbeiter'.
endif.

case p_alter.
  when 6.
    write / 'Alter ist 6 Jahre'.
  when 7 or 8.
    write / 'Alter ist 7 oder 8 Jahre'.
  when others.
    write / 'Alter ist weder 6 noch 7 noch 8'.
endcase.

do 5 times.
*  if not lv_i <= 100.
*    continue.
*  endif.
  check lv_i <= 100.

  lv_i = lv_i + p_alter.
enddo.

*if not lv_i < 100.
*  exit.
*endif.
check lv_i < 100.

while lv_i > 50.
  lv_i = lv_i - 1.
endwhile.

write: /, 'Ergebnis der Multiplication: ', lv_i.
