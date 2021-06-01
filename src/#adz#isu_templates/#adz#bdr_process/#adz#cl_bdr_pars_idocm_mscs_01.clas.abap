class /ADZ/CL_BDR_PARS_IDOCM_MSCS_01 definition
  public
  inheriting from /IDXGL/CL_PARS_IDOCMAP_MSCS_01
  final
  create public .

public section.

  methods PARSE_IDOC
    importing
      value(IS_EDEX_IDOCDATA) type EDEX_IDOCDATA
    returning
      value(RT_CL_PROCESS_DATA_EXTERN) type /IDXGC/T_CL_PROCESS_DATA_EXTRN
    raising
      /IDXGC/CX_PROCESS_ERROR .
protected section.
private section.
ENDCLASS.



CLASS /ADZ/CL_BDR_PARS_IDOCM_MSCS_01 IMPLEMENTATION.


METHOD parse_idoc.
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
* Beschreibung: IDoc parsen
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
  DATA: lt_idex_idocdata TYPE idex_idocdata.

  TRY.
      ms_idoc_data = is_edex_idocdata.
      split_inbound_idoc( IMPORTING et_idex_idocdata = lt_idex_idocdata ).

      LOOP AT lt_idex_idocdata ASSIGNING FIELD-SYMBOL(<ls_edex_idocdata>).
        ms_split_idoc = <ls_edex_idocdata>.
        CLEAR: mt_process_data.
        process_inbound_mapping( ).
        APPEND LINES OF mt_process_data TO rt_cl_process_data_extern.
      ENDLOOP.
    CATCH /idxgc/cx_ide_error.
      "weiter ohne Fehler
  ENDTRY.
ENDMETHOD.
ENDCLASS.
