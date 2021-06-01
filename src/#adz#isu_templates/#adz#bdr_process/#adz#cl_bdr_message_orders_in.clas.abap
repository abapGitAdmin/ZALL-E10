class /ADZ/CL_BDR_MESSAGE_ORDERS_IN definition
  public
  inheriting from /IDXGL/CL_MESSAGE_ORDERS_IN
  final
  create public .

public section.
protected section.

  methods SET_PROCESS_DATE
    redefinition .
private section.
ENDCLASS.



CLASS /ADZ/CL_BDR_MESSAGE_ORDERS_IN IMPLEMENTATION.


  METHOD set_process_date.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: BOECKMANN-C                                                             Datum: 28.05.2019
*
* Beschreibung: Hinzufügen von BMID /ADZ/CD011 zur Standard-Verarbeitung
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************

    super->set_process_date( EXPORTING iv_bmid           = iv_bmid
                                       is_proc_step_data = is_proc_step_data
                             IMPORTING ev_process_date   = ev_process_date ).

    CASE iv_bmid.
      WHEN /adz/if_bdr_co=>gc_bmid-ord_sc_101.
        ev_process_date = is_proc_step_data-execution_date.
      WHEN OTHERS.
* Do nothing.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
