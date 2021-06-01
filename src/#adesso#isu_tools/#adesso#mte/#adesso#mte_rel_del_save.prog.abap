*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTE_REL_DEL_SAVE
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT /ADESSO/MTE_REL_DEL_SAVE.

TABLES: /adesso/mte_rels.

SELECT-OPTIONS: sfirma FOR /adesso/mte_rels-firma,
                sobject FOR /adesso/mte_rels-object,
                sobjkey FOR /adesso/mte_rels-obj_key.
PARAMETERS:     pecht AS CHECKBOX.

START-OF-SELECTION.

  DELETE  FROM /adesso/mte_rels
               WHERE firma IN sfirma
               AND   object IN sobject
               AND   obj_key IN sobjkey.

  IF pecht IS INITIAL.
    WRITE : / sy-dbcnt, 'Einträge würden gelöscht'.
    ROLLBACK WORK.
  ELSE.
    WRITE : / sy-dbcnt, 'Einträge wurden gelöscht'.
    COMMIT WORK.
  ENDIF.
