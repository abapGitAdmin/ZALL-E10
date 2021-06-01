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
report zdr_datenreferenzen.

types: begin of lty_person,
         name  type string,
         alter type i,
       end of lty_person.

*data: lv_zahl type i value 10,
*      lr_ref type ref to i.
*get reference of lv_zahl into lr_ref.
*lr_ref->* = 20.
*write lv_zahl.

data: ls_struktur type lty_person,
      lr_ref      type ref to lty_person.
get reference of ls_struktur into lr_ref.
lr_ref->name = 'Meier'.
lr_ref->alter = 40.
write: ls_struktur-name, ls_struktur-alter.
