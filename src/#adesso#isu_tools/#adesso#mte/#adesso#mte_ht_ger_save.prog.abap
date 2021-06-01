*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTE_HT_GER_SAVE
*&
*&---------------------------------------------------------------------*
************************************************************************
*   Programm bietet zwei Funktionen an:                                *
* 1. Sichern des Inhalts der Hilfstabelle-Tabelle EVUIT/MTE_HT_GE
*    in eine Sicherungstabelle /EVUIT/MTE_HT_SI. Der bisherige In-     *
*    halt der Sich.Tab. wird vorher gelöscht.                          *
* 2. Zurückholen des gesicherten Standes in die HT-Tab. (nach zuvor   *
*    erfolgten Löschung des aktuellen Inhalts von EVUIT/MTE_HT_GE).    *
*                                                                      *
************************************************************************
REPORT /adesso/mte_ht_ger_save.

TABLES: /adesso/mte_htge,
        /adesso/mte_htsi.

DATA: ihtger TYPE TABLE OF /adesso/mte_htge WITH HEADER LINE.
DATA: ihtgers TYPE TABLE OF /adesso/mte_htsi WITH HEADER LINE.
DATA: z_htger TYPE i,
      z_htgers TYPE i.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS: save RADIOBUTTON GROUP rg1,
            rest RADIOBUTTON GROUP rg1.
SELECTION-SCREEN END OF BLOCK b1.

PARAMETERS: pecht AS CHECKBOX.


START-OF-SELECTION.

  SELECT * INTO TABLE ihtger
           FROM /adesso/mte_htge.
  DESCRIBE TABLE ihtger LINES z_htger.

  SELECT * INTO TABLE ihtgers
           FROM /adesso/mte_htsi.
  DESCRIBE TABLE ihtgers LINES z_htgers.

  IF pecht IS INITIAL.
    IF save = 'X'.
      WRITE: / 'Es würden', z_htgers, 'HT_GER_S-Einträge gelöscht und',
             / '         ', z_htger,  'HT_GER-Einträge gesichert'.
    ELSE.
      WRITE: / 'Es würden', z_htger,  'HT_GER-Einträge gelöscht und',
             / '         ', z_htgers, 'HT_GER_S-Einträge zurückgeholt'.
    ENDIF.
    EXIT.
  ENDIF.

  IF NOT pecht IS INITIAL.
    IF save = 'X'.
      DELETE FROM /adesso/mte_htsi WHERE equnr NE space.
      COMMIT WORK AND WAIT.
      MODIFY /adesso/mte_htsi FROM TABLE ihtger.
      WRITE: / 'Es wurden', z_htgers, 'HT_GER_S-Einträge gelöscht und',
             / '         ', z_htger,  'HT_GER-Einträge gesichert'.
    ELSE.
      DELETE FROM /adesso/mte_htge WHERE equnr NE space.
      COMMIT WORK AND WAIT.
      MODIFY /adesso/mte_htge FROM TABLE ihtgers.
      WRITE: / 'Es wurden', z_htger,  'HT_GER-Einträge gelöscht und',
             / '         ', z_htgers, 'HT_GER_S-Einträge zurückgeholt'.
    ENDIF.
  ENDIF.
