*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTE_REL_SAVE
*&
************************************************************************
*   Programm bietet zwei Funktionen an:                                *
* 1. Sichern des gesammten Inhalts der Relevanz-Tabelle /adesso/mte_rel*
*    in eine Sicherungstabelle /adesso/mte_rels. Der bisherige In-     *
*    halt der Sich.Tab. wird vorher gelöscht.                          *
* 2. Zurückholen des gesicherten Standes in die Rel.Tab. (nach zuvor   *
*    erfolgten Löschung des aktuellen Inhalts von /adesso/mte_rel).    *
*                                                                      *
************************************************************************
REPORT /adesso/mte_rel_save.

TABLES: /adesso/mte_rel,
        /adesso/mte_rels.

DATA: irel  TYPE TABLE OF /adesso/mte_rel WITH HEADER LINE.
DATA: irels TYPE TABLE OF /adesso/mte_rel WITH HEADER LINE.
DATA: z_rel TYPE i,
      z_rels TYPE i.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
SELECT-OPTIONS: fir FOR /adesso/mte_rel-firma.

PARAMETERS: save RADIOBUTTON GROUP rg1,
            rest RADIOBUTTON GROUP rg1.
SELECTION-SCREEN END OF BLOCK b1.

PARAMETERS: pecht AS CHECKBOX.


START-OF-SELECTION.

  SELECT * INTO TABLE irel
           FROM /adesso/mte_rel
           WHERE firma IN fir.
  DESCRIBE TABLE irel LINES z_rel.

  SELECT * INTO TABLE irels
           FROM /adesso/mte_rels
           WHERE firma IN fir.
  DESCRIBE TABLE irels LINES z_rels.

  IF pecht IS INITIAL.
    IF save = 'X'.
      WRITE: / 'Es würden', z_rels, 'Rel_S-Einträge gelöscht und',
             / '         ', z_rel,  'Rel-Einträge gesichert'.
    ELSE.
      WRITE: / 'Es würden', z_rel,  'Rel-Einträge gelöscht und',
             / '         ', z_rels, 'Rel_S-Einträge zurückgeholt'.
    ENDIF.
    EXIT.
  ENDIF.

  IF NOT pecht IS INITIAL.
    IF save = 'X'.
      DELETE FROM /adesso/mte_rels WHERE obj_key NE space AND firma IN fir.

      COMMIT WORK AND WAIT.
      MODIFY /adesso/mte_rels FROM TABLE irel.
      WRITE: / 'Es wurden', z_rels, 'Rel_S-Einträge gelöscht und',
             / '         ', z_rel,  'Rel-Einträge gesichert'.
    ELSE.
      DELETE FROM /adesso/mte_rel WHERE obj_key NE space  AND firma IN fir.
      COMMIT WORK AND WAIT.
      MODIFY /adesso/mte_rel FROM TABLE irels.
      WRITE: / 'Es wurden', z_rel,  'Rel-Einträge gelöscht und',
             / '         ', z_rels, 'Rel_S-Einträge zurückgeholt'.
    ENDIF.
  ENDIF.
