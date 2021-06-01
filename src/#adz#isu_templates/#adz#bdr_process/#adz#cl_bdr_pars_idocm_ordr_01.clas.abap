class /ADZ/CL_BDR_PARS_IDOCM_ORDR_01 definition
  public
  inheriting from /IDXGL/CL_PARS_IDOCMAP_ORDR_01
  create public .

public section.
protected section.

  methods DET_INBOUND_BASICPROC
    redefinition .
private section.
ENDCLASS.



CLASS /ADZ/CL_BDR_PARS_IDOCM_ORDR_01 IMPLEMENTATION.


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
  DATA: ls_segm_bgm TYPE /idxgc/e1_bgm_02,
        ls_segm_rff TYPE /idxgc/e1_rff_07,
        ls_segm     TYPE edidd,
        lt_segm     TYPE edidd_tt.

  super->det_inbound_basicproc( ).

  IF mv_dexbasicproc IS INITIAL.
* Get IDOC segment value of BGM_02 segment
    lt_segm = get_segment( iv_segnam = /idxgc/if_constants_ide=>gc_segm_bgm_02 ).
    READ TABLE lt_segm INTO ls_segm INDEX 1.
    IF sy-subrc = 0.
      ls_segm_bgm = ls_segm-sdata.
    ENDIF.

* Get IDOC segment value of RFF_07+Z13 segment
    REFRESH: lt_segm.
    lt_segm = get_segment( iv_segnam = /idxgc/if_constants_ide=>gc_segm_rff_07 ).
    LOOP AT lt_segm INTO ls_segm.
      ls_segm_rff = ls_segm-sdata.
      IF ls_segm_rff-reference_code_qualifier = /idxgc/if_constants_ide=>gc_rff_qual_z13.
        ls_segm_rff = ls_segm-sdata.
        EXIT.
      ELSE.
        CONTINUE.
      ENDIF.
    ENDLOOP.

* ADZ Prozesse für Änderung Bilanzierungsverfahren / Gerätekonfiguration und Reklamation von Werten
    IF ls_segm_rff-reference_identifier = /adz/if_bdr_co=>gc_amid_19111 OR
       ls_segm_rff-reference_identifier = /adz/if_bdr_co=>gc_amid_19112 OR
       ls_segm_rff-reference_identifier = /adz/if_bdr_co=>gc_amid_19113 OR
       ls_segm_rff-reference_identifier = /adz/if_bdr_co=>gc_amid_19114.
      mv_dexbasicproc = /idxgc/if_constants_ide=>gc_basicproc_i_ordrsp.
    ELSE.
      RETURN.
    ENDIF.
  ENDIF.

ENDMETHOD.
ENDCLASS.
