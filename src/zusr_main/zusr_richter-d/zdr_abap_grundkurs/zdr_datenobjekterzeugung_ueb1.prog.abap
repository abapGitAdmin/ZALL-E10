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
report zdr_datenobjekterzeugung_ueb1.

types: begin of lty_person,
         name  type string,
         alter type i,
       end of lty_person.

data: lr_ref type ref to data.
field-symbols: <feldsymbol> type lty_person.
create data lr_ref type lty_person.
assign lr_ref->* to <feldsymbol>.

<feldsymbol>-name = 'Meier'.
<feldsymbol>-alter = 40.

write: <feldsymbol>-name, <feldsymbol>-alter.
