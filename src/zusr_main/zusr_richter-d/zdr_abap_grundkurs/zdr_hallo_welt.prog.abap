************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: RICHTER-D                                     Datum: 02.06.2020
*
* Beschreibung: Udemy Schulung
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************
report zdr_hallo_welt line-size 50.

types zdr_st_name type string.

data: gv_name     type string value 'Klaus',
      gv_nachname type zdr_st_name,
      gv_strasse  type string,
      gv_alter    type i.

gv_nachname = 'Meyer'.

*gv_name = 'Klaus'.

*write: 'Hallo Welt!'.

write: gv_name,
       / gv_nachname,
       'Test'.

skip 3.
uline.
