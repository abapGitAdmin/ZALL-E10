class /ADZ/CL_BDR_DP_ORDRSP_002 definition
  public
  inheriting from /IDXGL/CL_DP_ORDRSP_002
  final
  create public .

public section.

  methods PRODUCT
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS /ADZ/CL_BDR_DP_ORDRSP_002 IMPLEMENTATION.


METHOD PRODUCT.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: BOECKMANN-C                                                             Datum: 15.04.2019
*
* Beschreibung: Z34 Logik ist im Standard nicht vorhanden.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
  TRY.
      CALL METHOD super->product.
    CATCH /idxgc/cx_process_error .
  ENDTRY.

  CASE siv_data_processing_mode.
* Get data from additional source step
    WHEN /idxgc/if_constants_add=>gc_data_from_add_source.
      sis_process_step_data-serv_measval  = sis_process_data_src_add-serv_measval.

* Get data from default determination logic/source step
    WHEN /idxgc/if_constants_add=>gc_data_from_source OR
         /idxgc/if_constants_add=>gc_default_processing.

      IF sis_process_step_data-docname_code = /adz/if_bdr_co=>gc_msg_category_z34.
        sis_process_step_data-serv_measval  = sis_process_data_src-serv_measval.
      ENDIF.
  ENDCASE.

* Check if field is filled in case it is mandatory
  IF siv_mandatory_data = abap_true AND sis_process_step_data-docname_code = /adz/if_bdr_co=>gc_msg_category_z34
    AND sis_process_step_data-serv_measval IS INITIAL.
    MESSAGE e038(/idxgc/ide_add) WITH TEXT-016 INTO siv_mtext.
    /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
  ENDIF.

ENDMETHOD.
ENDCLASS.
