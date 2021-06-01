*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTE_RELEVANZ_VERT
*&
*&---------------------------------------------------------------------*
***********************************************************************
* Dieser Report ermittelt die relevanten Objekte für die
* IS/U-IS/U - Migration. Die ermittelten Daten werden in einer
* Datenbanktabelle weggeschrieben.
***********************************************************************
REPORT /adesso/mte_relevanz_vert MESSAGE-ID /adesso/mt_n.

INCLUDE /adesso/mte_relevant_vert_top.
INCLUDE /adesso/mte_macros_vert.

INCLUDE /adesso/mte_relevanz_vert_f01.


START-OF-SELECTION.

  PERFORM get_data_relevanz.

  PERFORM update_reltab.

  PERFORM protokoll.
