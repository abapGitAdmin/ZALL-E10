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
report zdr_datenreferenzen_uebung2.

types: begin of lty_person,
         name  type string,
         alter type i,
       end of lty_person.

data: ls_struktur type lty_person,
      lt_tabelle  type table of lty_person,
      lr_ref      type ref to lty_person.

field-symbols <feldsymbol> type lty_person.
get reference of ls_struktur into lr_ref.
assign lr_ref->* to <feldsymbol>.

<feldsymbol>-name = 'Meier'.
<feldsymbol>-alter = 20.
append <feldsymbol> to lt_tabelle.

<feldsymbol>-name = 'Koch'.
<feldsymbol>-alter = 34.
append <feldsymbol> to lt_tabelle.

loop at lt_tabelle into <feldsymbol>.
  write: / <feldsymbol>-name, <feldsymbol>-alter.
endloop.
