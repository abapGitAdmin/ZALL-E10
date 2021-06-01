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
report zdr_feldsymbole_uebung3.

types: begin of lty_uhrzeit,
         stunde(2)  type n,
         minute(2)  type n,
         sekunde(2) type n,
       end of lty_uhrzeit.

** implizit
*field-symbols <feldsymbol> type lty_uhrzeit.
*assign sy-uzeit to <feldsymbol> casting.
*write: <feldsymbol>-stunde, <feldsymbol>-minute, <feldsymbol>-sekunde.

* explizit
field-symbols <feldsymbol> type any.
field-symbols <wert> type n.
assign sy-uzeit to <feldsymbol> casting type lty_uhrzeit.
do.
  assign component sy-index of structure <feldsymbol> to <wert>.
  if sy-subrc <> 0.
    exit.
  endif.
  write / <wert>.
enddo.
