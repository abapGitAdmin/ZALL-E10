***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 06.10.2019
*
* Beschreibung: Beispiele für neues ABAP Coding
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
REPORT zcode_examples.

***** Strings verbinden ***************************************************************************
DATA: lv_string TYPE string VALUE 'Test',
      lv_char8  TYPE char8  VALUE 'Länge__8',
      lv_int3   TYPE int3   VALUE 123.

lv_string = |String in lv_string: { lv_string }, Text mit Länge 8: { lv_char8 }, Zahl: { lv_int3 } |.
WRITE: lv_string,/.

lv_string = 'Test'.

CONCATENATE 'String in lv_string: ' lv_string ', Text mit Länge 8: ' lv_char8 ', Zahl: ' lv_int3 INTO lv_string RESPECTING BLANKS.
WRITE: lv_string.
ULINE.

***** Führende Nullen entfernen z.B. bei der Gerätenummer *****************************************
DATA: lv_meternumber TYPE /idxgc/de_meternumber.

lv_meternumber = '000123456789'.
lv_meternumber = |{ lv_meternumber ALPHA = OUT }|.
lv_meternumber = |{ lv_meternumber ALPHA = IN }|.
lv_meternumber = '000X123456789'. "Funktioniert nur für rein numerische Zeichenketten
lv_meternumber = |{ lv_meternumber ALPHA = OUT }|.
lv_meternumber = |{ lv_meternumber ALPHA = IN }|.
"Dies ersetzt die FuBas CONVERSION_EXIT_ALPHA_INPUT bzw. CONVERSION_EXIT_ALPHA_OUTPUT (exakt gleiche Funktion).

CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT' "Funktioniert nicht an dieser Stelle weil "X" in der Zeichenkette enthalten ist
  EXPORTING
    input  = lv_meternumber
  IMPORTING
    output = lv_meternumber.

SHIFT lv_meternumber LEFT DELETING LEADING '0'.

WRITE: lv_meternumber.

***** IN-Line Schleifen ***************************************************************************
TYPES: BEGIN OF ts_number_letter,
         number      TYPE int1,
         letter      TYPE char1,
         letter_type TYPE char1,
       END OF ts_number_letter.

DATA: lt_number_letter TYPE TABLE OF ts_number_letter,
      ls_number_letter TYPE ts_number_letter,
      lv_number        TYPE int1.

lv_number = 1.

lt_number_letter = VALUE #( ( number = 1 letter = 'A' letter_type = 'V' )
                            ( number = 2 letter = 'B' letter_type = 'K' )
                            ( number = 3 letter = 'C' letter_type = 'K' )
                            ( number = 4 letter = 'D' letter_type = 'K' )
                            ( number = 5 letter = 'E' letter_type = 'V' )
                            ( number = 6 letter = 'F' letter_type = 'K' )
                            ( number = 7 letter = 'G' letter_type = 'K' )
                            ( number = 8 letter = 'H' letter_type = 'K' )
                            ( number = 9 letter = 'I' letter_type = 'V' )
                            ( number = 0 letter = 'J' letter_type = 'K' ) ).

DATA(lt_letter_type) = VALUE pve_suform_sso_table( FOR <x> IN lt_number_letter ( <x>-letter_type ) ).

SORT lt_letter_type.
DELETE ADJACENT DUPLICATES FROM lt_letter_type.

DATA(lt_letter_type2) = VALUE pve_suform_sso_table( FOR GROUPS of <x> IN lt_number_letter GROUP BY <x>-letter_type ( <x>-letter_type ) ).

IF 1 = 2.
ENDIF.
