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
report zdr_mathe_advanced.

*data: gv_string type string value 'Hallo',
*      gv_zahl   type i value 5.
*
*write gv_string.
*
*gv_string = gv_zahl.
*
*write gv_string.
*
*gv_string = '5'.
*
*gv_zahl = gv_string. "Laufzeitfehler falls string nicht konvertierbar
*
*write / gv_zahl.

data: gv_zahl1 type p decimals 2 value 7,
      gv_zahl2 type p decimals 2 value 2,
      gv_erg   type p decimals 2.

gv_erg = gv_zahl1 / gv_zahl2.
write gv_erg.

gv_erg = gv_zahl1 div gv_zahl2.
write gv_erg.

gv_erg = gv_zahl1 mod gv_zahl2.
write gv_erg.

gv_erg = gv_zahl1 ** gv_zahl2.
write gv_erg.
