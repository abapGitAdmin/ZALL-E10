class /ADZ/CL_BDR_PROCESS definition
  public
  inheriting from /IDXGL/CL_PROCESS
  final
  create public .

public section.
protected section.

  methods DETERMINE_PROC_STATUS
    redefinition .
private section.
ENDCLASS.



CLASS /ADZ/CL_BDR_PROCESS IMPLEMENTATION.


METHOD determine_proc_status.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 14.05.2019
*
* Beschreibung: Prozessstatus vor dem letzten Prozessupdate setzen.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************
  super->determine_proc_status( IMPORTING ev_proc_status = ev_proc_status ).

  IF line_exists( gr_process_data->gs_process_data-steps[ bmid = /adz/if_bdr_co=>gc_bmid-ord_sc_102 ] ) OR
     line_exists( gr_process_data->gs_process_data-steps[ bmid = /adz/if_bdr_co=>gc_bmid-ord_sc_202 ] ) OR
     line_exists( gr_process_data->gs_process_data-steps[ bmid = /adz/if_bdr_co=>gc_bmid_adzcd022 ] ).
    ev_proc_status = /idxgc/if_constants_add=>gc_proc_status_wf_reject.
  ENDIF.

ENDMETHOD.
ENDCLASS.
