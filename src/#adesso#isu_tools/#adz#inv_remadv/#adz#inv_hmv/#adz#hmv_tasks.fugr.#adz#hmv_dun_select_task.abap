FUNCTION /ADZ/HMV_DUN_SELECT_TASK.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IS_CONSTANTS) TYPE  /ADZ/HMV_S_CONSTANTS
*"     VALUE(IS_OUT_VORLAGE) TYPE  /ADZ/HMV_S_OUT_DUNNING
*"     VALUE(IB_AKONTO) TYPE  CHECKBOX
*"     VALUE(IB_UPDTE) TYPE  CHECKBOX
*"     VALUE(IB_ADUNN) TYPE  CHECKBOX
*"     VALUE(IV_LOCKR) TYPE  MANSP_OLD_KK
*"     VALUE(IV_FDATE) TYPE  SYDATUM
*"     VALUE(IV_TDATE) TYPE  SYDATUM
*"     VALUE(IT_SO_AUGST) TYPE  /ADZ/INV_RT_AUGST_KK
*"     VALUE(IT_SO_MANSP) TYPE  /ADZ/INV_RT_MANSP_OLD_KK
*"     VALUE(IT_SO_MAHNS) TYPE  /ADZ/INV_RT_MAHNS_KK
*"     VALUE(IT_SELECT_BEL) TYPE  /ADZ/HMV_T_SELCT
*"     VALUE(IT_SELECT_MEMI) TYPE  /ADZ/HMV_T_SELCT_MEMI
*"     VALUE(IT_SELECT_MSB) TYPE  /ADZ/HMV_T_SELCT_MSB
*"  TABLES
*"      ET_OUT STRUCTURE  /ADZ/HMV_S_OUT_DUNNING
*"----------------------------------------------------------------------
  DATA lt_out TYPE /adz/hmv_t_out_dunning.
  DATA(lo_bel) = NEW /adz/cl_hmv_select_dun_task( is_constants =  is_constants ).

  IF it_select_bel IS NOT INITIAL.
    lo_bel->main_bel(
      EXPORTING
        is_out_vorlage =  is_out_vorlage
        ib_akonto      =  ib_akonto
        ib_updte       =  ib_updte
        ib_adunn       =  ib_adunn
        iv_lockr       =  iv_lockr
        iv_fdate       =  iv_fdate
        iv_tdate       =  iv_tdate
        it_so_augst    =  it_so_augst
        it_so_mansp    =  it_so_mansp
        it_so_mahns    =  it_so_mahns
        it_select_bel  =  it_select_bel
      CHANGING
        et_out      =  lt_out  ).
    APPEND LINES OF lt_out TO et_out.
  ENDIF.

  IF it_select_msb IS NOT INITIAL.
    lo_bel->main_msb(
      EXPORTING
        is_out_vorlage =  is_out_vorlage
        ib_akonto      =  ib_akonto
        ib_updte       =  ib_updte
        ib_adunn       =  ib_adunn
        iv_lockr       =  iv_lockr
        iv_fdate       =  iv_fdate
        iv_tdate       =  iv_tdate
        it_so_augst    =  it_so_augst
        it_so_mansp    =  it_so_mansp
        it_so_mahns    =  it_so_mahns
        it_select_msb  =  it_select_msb
      CHANGING
        et_out      =  lt_out  ).
    APPEND LINES OF lt_out TO et_out.
  ENDIF.

  IF it_select_memi IS NOT INITIAL.
    lo_bel->main_memi(
      EXPORTING
        is_out_vorlage =  is_out_vorlage
        ib_akonto      =  ib_akonto
        ib_updte       =  ib_updte
        ib_adunn       =  ib_adunn
        iv_lockr       =  iv_lockr
        iv_fdate       =  iv_fdate
        iv_tdate       =  iv_tdate
        it_so_augst    =  it_so_augst
        it_so_mansp    =  it_so_mansp
        it_so_mahns    =  it_so_mahns
        it_select_memi  =  it_select_memi
      CHANGING
        et_out      =  lt_out  ).
    APPEND LINES OF lt_out TO et_out.
  ENDIF.

ENDFUNCTION.
