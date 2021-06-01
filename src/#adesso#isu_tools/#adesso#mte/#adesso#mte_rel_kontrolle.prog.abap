*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTE_REL_KONTROLLE
*&
************************************************************************
* Programm soll nach jedem Relevanzlauf den Tabelleninhalt von         *
* /adesso/mte_rel ausgeben                                              *
*                                                                      *
************************************************************************
REPORT /adesso/mte_rel_kontrolle MESSAGE-ID /adesso/mt_n.

TABLES: /adesso/mte_rel.

* interne Tabelle und Arbeitsbereich zum Zwischenspeichern der
* ermittelten Relevanz
DATA: irel LIKE TABLE OF /adesso/mte_rel,
      wrel LIKE /adesso/mte_rel.

DATA: objcount TYPE i.

PARAMETERS: start AS CHECKBOX DEFAULT 'X'.

  WRITE : / 'Objekt', 44 'Anzahl'.
  SELECT * FROM /adesso/mte_rel INTO TABLE irel.
  LOOP AT irel INTO wrel.
    AT NEW object.
      WRITE : / wrel-object.
    ENDAT.
    ADD 1 TO objcount.
    AT END OF object.
      WRITE : 40 objcount.
      MESSAGE s001 WITH 'Objekt' wrel-object 'Anzahl' objcount.
      CLEAR objcount.
    ENDAT.
  ENDLOOP.
