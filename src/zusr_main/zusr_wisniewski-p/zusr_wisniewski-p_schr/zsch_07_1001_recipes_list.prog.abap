*&---------------------------------------------------------------------*
*& Report ZSCH_07_1001_RECIPES_LIST
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsch_07_1001_recipes_list.

DATA: gs_recipe TYPE zsch06recipe.
DATA: gd_message TYPE string.

INITIALIZATION.
  gs_recipe-rid = '002'.

START-OF-SELECTION.
*  PERFORM read_recipe(zsch_07_1001_recipes_list)
*              USING
*                  gs_recipe-rid
*              CHANGING
*                 gs_recipe.

  CALL FUNCTION 'Z_SCHO7RECIPE_GET_DETAIL'
    EXPORTING
      id_rid    = gs_recipe-rid
    IMPORTING
      es_recipe = gs_recipe.
  .


END-OF-SELECTION.
  IF gs_recipe IS NOT INITIAL.
    PERFORM write_kopf USING gs_recipe.
    SKIP 2.

    PERFORM write_zutaten USING gs_recipe.
    SKIP 2.

    PERFORM write_zubereitung USING gs_recipe.
    ULINE.
  ELSE.
    WRITE: / 'Leider kein Rezept 002 gefunden!'.
  ENDIF.

TOP-OF-PAGE.
  PERFORM welcome_user(zsch_07_1001_recipes_list)
              USING
                  sy-uname
                  sy-uzeit
              CHANGING
                 gd_message.

  WRITE: / gd_message.
  ULINE.

FORM welcome_user USING VALUE(id_uname) TYPE sy-uname
                        VALUE(id_zeit) TYPE sy-uzeit
                  CHANGING ed_message TYPE string.
  DATA: ld_zeit TYPE c LENGTH 8.
  WRITE id_zeit TO ld_zeit USING EDIT MASK '__:__:__'.

  CONCATENATE `Herzlich wilkommen ` id_uname ` um ` ld_zeit ` zu unserer großen Küchensause` INTO ed_message.
ENDFORM.

FORM read_recipe USING VALUE(id_rid) TYPE zsch06recipe-rid
                 CHANGING es_recipe TYPE zsch06recipe.
  SELECT SINGLE * FROM zsch06recipe INTO es_recipe WHERE rid = id_rid.
ENDFORM.

FORM write_kopf USING is_recipe TYPE zsch06recipe.
  WRITE: / 'Menüart: ', is_recipe-menueart.
  WRITE: / 'Kochdauer: ', is_recipe-kochdauer, ' Minuten'.
  WRITE: / 'Region: ', is_recipe-region.
  WRITE: / 'Schwierigkeit: ', is_recipe-schwierigkeit, '(0 ist einfach)'.
ENDFORM.

FORM write_zutaten USING is_recipe TYPE zsch06recipe.
  DATA: lt_zutaten TYPE stringtab,
        ls_zutaten LIKE LINE OF lt_zutaten.

  SPLIT is_recipe-zutaten AT '##' INTO TABLE lt_zutaten.

  LOOP AT lt_zutaten INTO ls_zutaten.
    WRITE: / ls_zutaten.
  ENDLOOP.
ENDFORM.

FORM write_zubereitung USING is_recipe TYPE zsch06recipe.
  DATA: lt_zubereitung TYPE stringtab,
        ls_zubereitung LIKE LINE OF lt_zubereitung,
        ld_mod         TYPE i,
        ld_len         TYPE i,
        ld_index       TYPE i.

  SPLIT is_recipe-zubereitung AT '##' INTO TABLE lt_zubereitung.

  LOOP AT lt_zubereitung INTO ls_zubereitung.
    IF sy-tabix = 1.
      WRITE: / ls_zubereitung.
      NEW-LINE.
      CONTINUE.
    ELSE.
      NEW-LINE.
    ENDIF.
    ld_len = strlen( ls_zubereitung ).
    DO ld_len TIMES.
      ld_index = sy-index - 1.
      WRITE: ls_zubereitung+ld_index(1) NO-GAP.
      ld_mod = sy-index MOD 100.
      IF ld_mod = 0.
        NEW-LINE.
      ENDIF.
    ENDDO.
  ENDLOOP.
ENDFORM.
