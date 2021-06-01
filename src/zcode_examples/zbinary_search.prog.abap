REPORT zbinary_search.

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

SORT lt_number_letter BY letter.

WHILE lv_number < 10.

  READ TABLE lt_number_letter INTO ls_number_letter WITH KEY number = lv_number.
  IF sy-subrc = 0.
    WRITE:|( { ls_number_letter-letter },|.
  ELSE.
    WRITE:|( Not Found,|.
  ENDIF.

  CLEAR: ls_number_letter.

  READ TABLE lt_number_letter INTO ls_number_letter WITH KEY number = lv_number BINARY SEARCH.
  IF sy-subrc = 0.
    WRITE:| { ls_number_letter-letter } )|,/.
  ELSE.
    WRITE:| Not Found )|,/.
  ENDIF.

  lv_number = lv_number + 1.

ENDWHILE.

ULINE.

lv_number = 1.

SORT lt_number_letter BY letter_type.

WHILE lv_number < 10.
  CLEAR: ls_number_letter.
  READ TABLE lt_number_letter INTO ls_number_letter WITH KEY number = lv_number.
  IF sy-subrc = 0.
    WRITE:|( { ls_number_letter-letter },|.
  ELSE.
    WRITE:|( Not Found,|.
  ENDIF.

  CLEAR: ls_number_letter.
  READ TABLE lt_number_letter INTO ls_number_letter WITH KEY number = lv_number BINARY SEARCH.
  IF sy-subrc = 0.
    WRITE:| { ls_number_letter-letter } )|,/.
  ELSE.
    WRITE:| Not Found )|,/.
  ENDIF.

  lv_number = lv_number + 1.

ENDWHILE.

ULINE.

lv_number = 1.

SORT lt_number_letter BY number.

WHILE lv_number < 10.

  CLEAR: ls_number_letter.
  READ TABLE lt_number_letter INTO ls_number_letter WITH KEY number = lv_number.
  IF sy-subrc = 0.
    WRITE:|( { ls_number_letter-letter },|.
  ELSE.
    WRITE:|( Not Found,|.
  ENDIF.

  CLEAR: ls_number_letter.
  READ TABLE lt_number_letter INTO ls_number_letter WITH KEY number = lv_number BINARY SEARCH.
  IF sy-subrc = 0.
    WRITE:| { ls_number_letter-letter } )|,/.
  ELSE.
    WRITE:| Not Found )|,/.
  ENDIF.

  lv_number = lv_number + 1.

ENDWHILE.
