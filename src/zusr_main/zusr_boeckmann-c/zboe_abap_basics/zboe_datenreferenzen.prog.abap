************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: BOECKMANN-C                                  Datum: 21.05.2019
*
* Beschreibung: Datenreferenzen
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************

REPORT zboe_datenreferenzen.
*
*DATA: lv_zahl TYPE i VALUE 10,
*      lr_ref  TYPE REF TO i.
*
*GET REFERENCE OF lv_zahl INTO lr_ref.
*
*lr_ref->* = 20.
*
*WRITE / lv_zahl.

**********************************************************************
*
**********************************************************************

*TYPES: BEGIN OF lty_person,
*         name  TYPE string,
*         alter TYPE i,
*       END OF lty_person.
*
*DATA: ls_struktur TYPE lty_person,
*      lr_ref TYPE REF TO lty_person.
*
*GET REFERENCE OF ls_struktur INTO lr_ref.
*
*lr_ref->name = 'Meier'.
*lr_ref->alter = 24.
*
*WRITE: ls_struktur-name, ls_struktur-alter.

**********************************************************************
*
**********************************************************************

TYPES: BEGIN OF lty_person,
         name  TYPE string,
         alter TYPE i,
       END OF lty_person.

DATA: it_tabelle  TYPE TABLE OF lty_person,
      ls_struktur TYPE lty_person,
      lr_ref      TYPE REF TO data.

FIELD-SYMBOLS <feldsymbol> TYPE lty_person.

GET REFERENCE OF ls_struktur INTO lr_ref.
ASSIGN lr_ref->* TO <feldsymbol>.
<feldsymbol>-name = 'Schmidt'.
<feldsymbol>-alter = 33.
APPEND <feldsymbol> TO it_tabelle.

<feldsymbol>-name = 'Koch'.
<feldsymbol>-alter = 19.
APPEND <feldsymbol> TO it_tabelle.

LOOP AT it_tabelle INTO <feldsymbol>.
  WRITE: / <feldsymbol>-name, <feldsymbol>-alter.
ENDLOOP.
