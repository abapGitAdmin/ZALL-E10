*&---------------------------------------------------------------------*
*& Report ZPROG_C_KOCHBUCH
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zprog_c_kochbuch.

DATA: ls_rezept TYPE zproc_c_kbuch,
      lv_string TYPE string,
      lv_int    TYPE i.


FORM pf_einfuegen_von_rezepten USING VALUE(lv_rid) TYPE char10
        VALUE(lv_zutaten) TYPE string
        VALUE(lv_zubereitung) TYPE string
        VALUE(lv_menuart) TYPE char50
        VALUE(lv_kochdauer) TYPE int4.

  ls_rezept-rid = lv_rid.
  ls_rezept-zutaten = lv_zutaten.
  ls_rezept-zubereitung = lv_zubereitung.
  ls_rezept-menuart = lv_menuart.
  ls_rezept-kochdauer = lv_kochdauer.

  INSERT INTO zproc_c_kbuch VALUES ls_rezept .

ENDFORM.

FORM pf_search_string
      USING VALUE(lv_text) TYPE string
      VALUE(lv_pattern) TYPE string.
  FIND FIRST OCCURRENCE OF lv_pattern IN lv_text IGNORING CASE.
  IF sy-subrc = 0.

    CONCATENATE 'Pattern "' lv_pattern '" im Text vorhanden!!' INTO lv_string SEPARATED BY space.
    CONDENSE lv_string.
    WRITE: / lv_string.
  ENDIF.
ENDFORM.

FORM pf_read_recipe USING VALUE(id_rid)
      CHANGING es_recipe.
  SELECT SINGLE * FROM zproc_c_kbuch WHERE rid = id_rid INTO es_rezept.
ENDFORM.

START-OF-SELECTION.
DELETE FROM zproc_c_kbuch.
PERFORM pf_einfuegen_von_rezepten USING '001' 'Cola : Wasser und Zucker' 'Alles zusammenschütten' 'Getränk' 2000.
SELECT SINGLE * FROM zproc_c_kbuch INTO ls_rezept
WHERE rid = '001'.
DATA lv_length_zutaten TYPE string.
lv_length_zutaten = strlen( ls_rezept-zutaten ).
DATA: lv_concatstr TYPE string.
CONCATENATE ' Länge der Zutaten: ' lv_length_zutaten INTO lv_concatstr SEPARATED BY space.
WRITE: / ls_rezept-rid,
/ ls_rezept-zutaten+6(1) ,
/ ls_rezept-zubereitung,
/ ls_rezept-menuart,
/ ls_rezept-kochdauer,
/ condense( lv_concatstr ).

PERFORM pf_search_string USING ls_rezept-zutaten 'r und Z' .

DO 1 TIMES.
  WRITE '.'.
  WAIT UP TO 20 SECONDS.
ENDDO.
WRITE 'You did it!'.
