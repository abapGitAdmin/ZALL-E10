*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTE_RELEVANZ
*&
*&---------------------------------------------------------------------*
***********************************************************************
* Dieser Report ermittelt die relevanten Objekte für die
* IS/U-IS/U - Migration. Die ermittelten Daten werden in einer
* Datenbanktabelle weggeschrieben.
***********************************************************************
REPORT /adesso/mte_relevanz MESSAGE-ID /adesso/mt_n..

INCLUDE /adesso/mte_relevant_top.
INCLUDE /adesso/mte_macros.

INCLUDE /adesso/mte_relevanz_f01.


START-OF-SELECTION.

* Ermitteln der Daten aus dem Relevanzcustomizing
  PERFORM get_data_relc.

  PERFORM get_data_relevanz.

  PERFORM update_reltab.

  PERFORM protokoll.
