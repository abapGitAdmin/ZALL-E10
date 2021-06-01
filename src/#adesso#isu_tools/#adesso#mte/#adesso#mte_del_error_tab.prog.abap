*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTE_DEL_ERROR_TAB
*&
*&---------------------------------------------------------------------*
*& Der Report löscht die Fehlertabelle, die bei der
*& Entladung gefüllt wird
*&
*&---------------------------------------------------------------------*
REPORT /adesso/mte_del_error_tab.



TABLES: /adesso/mte_err.

PARAMETERS:      firma  LIKE /adesso/mte_err-firma.
SELECT-OPTIONS:  migobj FOR  /adesso/mte_err-object.
PARAMETERS:      simul  AS   CHECKBOX  DEFAULT 'X'.

SELECT * FROM /adesso/mte_err
    WHERE object  IN  migobj
      AND firma   EQ  firma.
  IF  simul  IS INITIAL.
    DELETE  /adesso/mte_err.
     ELSE.
    WRITE: / /adesso/mte_err.
  ENDIF.
ENDSELECT.


WRITE: / 'Durchgeführt !'.
