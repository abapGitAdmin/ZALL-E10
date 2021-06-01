*&---------------------------------------------------------------------*
*& Report ZSCH_06_1001_RECIPES_LIST
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsch_06_1001_recipes_list.

DATA: gs_recipe TYPE zsch06recipe.

START-OF-SELECTION.

  SELECT SINGLE * FROM zsch06recipe INTO gs_recipe WHERE rid = '002'.

  IF sy-subrc = 0.

    WRITE: / 'Menüart: ', gs_recipe-menueart.
    WRITE: / 'Kochdauer: ', gs_recipe-kochdauer, ' Minuten'.
    WRITE: / 'Region: ', gs_recipe-region.
    WRITE: / 'Schwierigkeit: ', gs_recipe-schwierigkeit, '(0 ist einfach)'.
    SKIP 2.

    DATA: gt_zutaten TYPE stringtab,
          gs_zutaten LIKE LINE OF gt_zutaten.
    SPLIT gs_recipe-zutaten AT '##' INTO TABLE gt_zutaten.

    LOOP AT gt_zutaten INTO gs_zutaten.
      WRITE: / gs_zutaten.
    ENDLOOP.
    SKIP 2.

    DATA: gt_zubereitung TYPE stringtab,
          gs_zubereitung LIKE LINE OF gt_zubereitung,
          gd_mod         TYPE i,
          gd_len         TYPE i,
          gd_index       TYPE i.
    SPLIT gs_recipe-zubereitung AT '##' INTO TABLE gt_zubereitung.

    LOOP AT gt_zubereitung INTO gs_zubereitung.
      IF sy-tabix = 1.
        WRITE: / gs_zubereitung.
        NEW-LINE.
        CONTINUE.
      ELSE.
        NEW-LINE.
      ENDIF.
      gd_len = strlen( gs_zubereitung ).
      DO gd_len TIMES.
        gd_index = sy-index - 1.
        WRITE: gs_zubereitung+gd_index(1) NO-GAP.
        gd_mod = sy-index MOD 100.
        IF gd_mod = 0.
          NEW-LINE.
        ENDIF.
      ENDDO.
    ENDLOOP.

    ULINE.
  ELSE.
    WRITE: / 'Leider kein Rezept 002 gefunden!'.
  ENDIF.
