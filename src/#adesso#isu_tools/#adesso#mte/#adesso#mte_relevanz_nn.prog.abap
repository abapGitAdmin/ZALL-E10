*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTE_RELEVANZ_NN
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT /ADESSO/MTE_RELEVANZ_NN.

INCLUDE /adesso/mte_relevant_nn_top.

INCLUDE /adesso/mte_macros_nn.

INCLUDE /adesso/mte_relevanz_nn_f01.

START-OF-SELECTION.

  PERFORM get_relevant_invoice.

  PERFORM update_reltab.

    PERFORM protokoll.
