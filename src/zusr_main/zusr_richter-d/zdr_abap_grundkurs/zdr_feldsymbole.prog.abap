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
report zdr_feldsymbole.

data: lv_zahl type i value 5.

field-symbols <feldsymbol> type i.

assign lv_zahl to <feldsymbol>.

unassign <feldsymbol>.

if <feldsymbol> is assigned.
  <feldsymbol> = 20.
  write lv_zahl.
else.
  write 'Keine Zuweisung vorhanden'.
endif.
