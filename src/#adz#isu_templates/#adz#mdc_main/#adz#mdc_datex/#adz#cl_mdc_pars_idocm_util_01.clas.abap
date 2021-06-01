class /ADZ/CL_MDC_PARS_IDOCM_UTIL_01 definition
  public
  inheriting from /IDXGL/CL_PARS_IDOCMAP_UTIL_01
  create public .

public section.
protected section.

  methods DET_DATEX_BASICPROC_Z38
    redefinition .
private section.
ENDCLASS.



CLASS /ADZ/CL_MDC_PARS_IDOCM_UTIL_01 IMPLEMENTATION.


  METHOD det_datex_basicproc_z38.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 01.10.2019
*
* Beschreibung: Die Stammdatensynchronisation soll in CL-Eingang laufen.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************


    DATA: ls_segm_rff_09 TYPE /idxgc/e1_rff_09.

    super->det_datex_basicproc_z38( ).

    DATA(lt_seg_rff) = me->get_segment( iv_segnam = /idxgc/if_constants_ide=>gc_segm_rff_09 ).
    LOOP AT lt_seg_rff ASSIGNING FIELD-SYMBOL(<ls_seg_rff>).
      ls_segm_rff_09 = <ls_seg_rff>-sdata.
      IF ls_segm_rff_09-reference_code_qualifier = /idxgc/if_constants_ide=>gc_rff_qual_tn AND
         ls_segm_rff_09-reference_identifier IS NOT INITIAL.
        me->mv_dexbasicproc = /idxgc/if_constants_ide=>gc_basicproc_i_utilres.
      ELSE.
        me->mv_dexbasicproc = /idxgc/if_constants_ide=>gc_basicproc_i_utilreq.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
