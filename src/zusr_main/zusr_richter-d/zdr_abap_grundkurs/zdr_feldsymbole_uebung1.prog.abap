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
report zdr_feldsymbole_uebung1.

types: begin of lty_person,
         name  type string,
         alter type i,
       end of lty_person.

data: ls_struktur type lty_person,
      lt_tabelle  type table of lty_person.

field-symbols <feldsymbol> type lty_person.

assign ls_struktur to <feldsymbol>.

<feldsymbol>-name = 'Meier'.
<feldsymbol>-alter = 34.
append <feldsymbol> to   lt_tabelle.

<feldsymbol>-name = 'Koch'.
<feldsymbol>-alter = 27.
append <feldsymbol> to   lt_tabelle.

loop at lt_tabelle assigning <feldsymbol>.
  write: / <feldsymbol>-name, <feldsymbol>-alter.
endloop.
