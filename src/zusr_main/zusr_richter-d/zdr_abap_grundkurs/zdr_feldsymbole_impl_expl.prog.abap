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
report zdr_feldsymbole_impl_expl.

types: begin of lty_datum,
         jahr(4)  type n,
         monat(2) type n,
         tag(2)   type n,
       end of lty_datum.

field-symbols: <fs>         type lty_datum,
               <feldsymbol> type any,
               <wert>       type n.

*assign sy-datum to <fs> casting.
*write: / <fs>-tag, <fs>-monat, <fs>-jahr.

assign sy-datum to <feldsymbol> casting type lty_datum.

do.
  assign component sy-index of structure <feldsymbol> to <wert>.
  if sy-subrc <> 0.
    exit.
  endif.
  write / <wert>.
enddo.
