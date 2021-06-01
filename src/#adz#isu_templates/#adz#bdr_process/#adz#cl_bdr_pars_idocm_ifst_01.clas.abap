class /ADZ/CL_BDR_PARS_IDOCM_IFST_01 definition
  public
  inheriting from /IDXGL/CL_PARS_IDOCMAP_IFST_01
  create public .

public section.
protected section.

  methods DET_INBOUND_BASICPROC
    redefinition .
private section.
ENDCLASS.



CLASS /ADZ/CL_BDR_PARS_IDOCM_IFST_01 IMPLEMENTATION.


METHOD det_inbound_basicproc.
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
* Beschreibung: Basisprozess für ADZ-Prozesse setzen um in Common Layer Verarbeitung abzubiegen.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
  DATA: lt_segm     TYPE edidd_tt,
        ls_segm     TYPE edidd,
        ls_segm_bgm TYPE /idxgc/e1_bgm_01.

  super->det_inbound_basicproc( ).

* Get BGM segment from IDOC data
  lt_segm = me->get_segment( iv_segnam = /idxgc/if_constants_ide=>gc_segm_bgm_02 ).

  READ TABLE lt_segm INTO ls_segm INDEX 1.
  IF sy-subrc = 0.
    ls_segm_bgm = ls_segm-sdata.
  ENDIF.

  CASE ls_segm_bgm-document_name_code.
    WHEN /adz/if_bdr_co=>gc_msg_category_z33.
      mv_dexbasicproc = /idxgl/if_constants_ide=>gc_basicproc_i_iftsta.
  ENDCASE.
ENDMETHOD.
ENDCLASS.
