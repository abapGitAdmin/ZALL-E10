*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTE_REL_DEL
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT /adesso/mte_rel_del.

TABLES: /adesso/mte_rel.

SELECT-OPTIONS: sfirma FOR /adesso/mte_rel-firma,
                sobject FOR /adesso/mte_rel-object,
                sobjkey FOR /adesso/mte_rel-obj_key.
PARAMETERS:     pecht AS CHECKBOX.

START-OF-SELECTION.

  DELETE  FROM /adesso/mte_rel
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
