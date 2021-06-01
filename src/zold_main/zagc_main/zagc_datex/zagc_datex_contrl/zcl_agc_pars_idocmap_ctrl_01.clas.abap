class ZCL_AGC_PARS_IDOCMAP_CTRL_01 definition
  public
  inheriting from /IDXGC/CL_PARS_IDOCMAP_CTRL_01
  create public .

public section.
protected section.

  methods TRIGGER_INBOUND_OLD_PROCESS
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_AGC_PARS_IDOCMAP_CTRL_01 IMPLEMENTATION.


  METHOD trigger_inbound_old_process.
***************************************************************************************************
* THIMEL.R 20150630 Einführung CL
*   Die alten Prozesse können nicht mit CONTRL Nachrichten umgehen und SAP erzeugt hier im Standard
*   eine Fehlermeldung. Wir setzen das IDoc auf Status 53 (grün) mit entsprechender Meldung, dass
*   kein Verarbeitung stattgefunden hat.
***************************************************************************************************
    DATA:
      ls_idoc_status TYPE bdidocstat.

    CLEAR ls_idoc_status.
    ls_idoc_status-status = /idxgc/if_constants_ide=>gc_idoc_status_53.
    ls_idoc_status-docnum = me->ms_idoc_data-control-docnum.
    ls_idoc_status-msgty = 'I'.
    ls_idoc_status-msgid = '/IDXGC/IDE_ADD'.
    ls_idoc_status-msgno = '060'.
    ls_idoc_status-uname  = sy-uname.
    ls_idoc_status-repid  = sy-repid.
    ls_idoc_status-routid = /idxgc/if_constants_ide=>gc_fm_comev_in.
    APPEND ls_idoc_status TO et_idoc_status.
  ENDMETHOD.
ENDCLASS.
