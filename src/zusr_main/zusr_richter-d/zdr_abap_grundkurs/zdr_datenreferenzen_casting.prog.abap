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
report zdr_datenreferenzen_casting.

data: lr_generisch type ref to data,
      lr_int       type ref to i,
      lr_date      type ref to d,
      lv_int       type i value 10,
      lv_date      type d value '20200101'.

get reference of lv_int into lr_int.
lr_generisch = lr_int.
lr_int ?= lr_generisch.

get reference of lv_date into lr_date.
lr_generisch = lr_date.
*lr_int ?= lr_generisch. -> ergibt Laufzeitfehler
