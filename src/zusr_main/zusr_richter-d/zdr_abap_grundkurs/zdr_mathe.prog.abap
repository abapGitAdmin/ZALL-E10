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
report zdr_mathe.

data: gv_zahl1       type i,
      gv_dezimalzahl type p decimals 2 value '4.20',
      gv_adresse     type string.
*      gv_dezimalzahl2 like gv_dezimalzahl.
*      gv_name         like mara-ernam.

constants gc_pi type p decimals 2 value '3.14'.

write: gv_dezimalzahl,
       / gc_pi.

data: gv_var1 type p decimals 2,
      gv_var2 type p decimals 2,
      gv_erg  type p decimals 2.

gv_var1 = 3.
gv_var2 = 5.

gv_erg = gv_var1 + gv_var2.

*add gv_var1 to gv_erg.

write / gv_erg.

gv_erg = gv_var1 - gv_var2.

write / gv_erg.

gv_erg = gv_var1 * gv_var2.

write / gv_erg.

gv_erg = gv_var1 / gv_var2.

write / gv_erg.
