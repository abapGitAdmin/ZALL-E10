*&---------------------------------------------------------------------*
*& Report ZSCH_07_RECIPES_LIST
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsch_07_recipes_list.

* Die Daten von der Datenbanktabelle werden in der
* Struktur gepuffert
DATA: gs_recipe TYPE zsch06recipe.
DATA: gd_message TYPE string.

START-OF-SELECTION.
* Einstweilen mal nur Rezept Nummer 1

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

PERFORM welcome_user(zsch_07_recipes_list)
            USING
                sy-uname
                sy-uzeit
            CHANGING
               gd_message.

WRITE: / gd_message.

FORM welcome_user USING VALUE(id_uname) TYPE sy-uname
                        VALUE(id_zeit) TYPE sy-uzeit
                        CHANGING gd_message TYPE string.
  DATA: ld_zeit TYPE c LENGTH 8.
  WRITE id_zeit TO ld_zeit USING EDIT MASK '__:__:__'.
  CONCATENATE `Hallo ` id_uname ` um ` ld_zeit INTO gd_message.
ENDFORM.

FORM read_recipe USING VALUE(id_rid) TYPE zsch06recipe-rid
                 CHANGING es_recipe TYPE zsch06recipe.
  SELECT SINGLE * FROM zsch06recipe INTO gs_recipe WHERE rid = id_rid.
ENDFORM.
