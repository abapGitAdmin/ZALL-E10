*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTE_ENTL_KSV_OBJ_SAVE
*&
*&---------------------------------------------------------------------*
************************************************************************
*   Programm bietet zwei Funktionen an:                                *
* 1. Sichern des Inhalts der Entlade-KSV-Tabelle /adesso/mte_obj
*    in eine Sicherungstabelle /adessot/mte_objs. Der bisherige In-  *
*    halt der Sich.Tab. wird vorher gelöscht.                          *
* 2. Zurückholen des gesicherten Standes in die Entl-KSV (nach zuvor   *
*    erfolgten Löschung des aktuellen Inhalts von /adesso/mte_obj).    *
*                                                                      *
************************************************************************
REPORT /adesso/mte_entl_ksv_obj_save.

TABLES: /adesso/mte_obj,
        /adesso/mte_objs.

DATA: iobj TYPE TABLE OF /adesso/mte_obj WITH HEADER LINE.
DATA: iobjsi TYPE TABLE OF /adesso/mte_objs WITH HEADER LINE.
DATA: z_obj TYPE i,
      z_objsi TYPE i.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS: save RADIOBUTTON GROUP rg1,
            rest RADIOBUTTON GROUP rg1.
SELECTION-SCREEN END OF BLOCK b1.

PARAMETERS: pecht AS CHECKBOX.


START-OF-SELECTION.

  SELECT * INTO TABLE iobj
           FROM /adesso/mte_obj.
  DESCRIBE TABLE iobj LINES z_obj.

  SELECT * INTO TABLE iobjsi
           FROM /adesso/mte_objs.
  DESCRIBE TABLE iobjsi LINES z_objsi.

  IF pecht IS INITIAL.
    IF save = 'X'.
      WRITE: / 'Es würden', z_objsi, 'OBJ-S-Einträge gelöscht und',
             / '         ', z_obj,   'OBJ-Einträge gesichert'.
    ELSE.
      WRITE: / 'Es würden', z_obj,  'OBJ-Einträge gelöscht und',
             / '         ', z_objsi, 'OBJ-S-Einträge zurückgeholt'.
    ENDIF.
    EXIT.
  ENDIF.

  IF NOT pecht IS INITIAL.
    IF save = 'X'.
      DELETE FROM /adesso/mte_objs WHERE object NE space.
      COMMIT WORK AND WAIT.
      MODIFY /adesso/mte_objs FROM TABLE iobj.
      WRITE: / 'Es wurden', z_objsi, 'OBJ-S-Einträge gelöscht und',
             / '         ', z_obj,  'OBJ-Einträge gesichert'.
    ELSE.
      DELETE FROM /adesso/mte_obj WHERE object NE space.
      COMMIT WORK AND WAIT.
      MODIFY /adesso/mte_obj FROM TABLE iobjsi.
      WRITE: / 'Es wurden', z_obj,  'OBJ-Einträge gelöscht und',
             / '         ', z_objsi, 'OBJ-S-Einträge zurückgeholt'.
    ENDIF.
  ENDIF.
