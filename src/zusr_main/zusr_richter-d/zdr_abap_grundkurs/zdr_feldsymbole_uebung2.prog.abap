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
report zdr_feldsymbole_uebung2.

types: begin of lty_person,
         name  type string,
         alter type i,
       end of lty_person.

data: ls_struktur type lty_person,
      lt_tabelle  type table of lty_person.

field-symbols <feldsymbol> type lty_person.
*field-symbols <tabelle> type index table.
*field-symbols <tabelle> type any table. -> muss Insert anstelle von Append benutzen
field-symbols <tabelle> type standard table.

assign ls_struktur to <feldsymbol>.
assign lt_tabelle to <tabelle>.

<feldsymbol>-name = 'Meier'.
<feldsymbol>-alter = 34.
append <feldsymbol> to <tabelle>.

<feldsymbol>-name = 'Koch'.
<feldsymbol>-alter = 27.
append <feldsymbol> to <tabelle>.

loop at <tabelle> assigning <feldsymbol>.
  write: / <feldsymbol>-name, <feldsymbol>-alter.
endloop.
