*&---------------------------------------------------------------------*
*& Report ZSCH_06_1001_RECIPES
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsch_06_1001_recipes.
* Die Daten von der Datenbanktabelle werden in der
* Struktur gepuffert
DATA: gs_recipe TYPE zsch06recipe.

START-OF-SELECTION.
* Einstweilen mal nur Rezept Nummer 1
  SELECT SINGLE * FROM zsch06recipe INTO gs_recipe
  WHERE rid = '001'.
* Falls einen Satz gefunden, dann Ausgabe.
  WRITE: / 'Nicht so schöne Ausgabe:'.
* Feldweise Ausgabe
  WRITE: / gs_recipe-rid,
           gs_recipe-zutaten,
           gs_recipe-zubereitung,
           gs_recipe-menueart,
           gs_recipe-kochdauer,
           gs_recipe-region,
           gs_recipe-schwierigkeit.
