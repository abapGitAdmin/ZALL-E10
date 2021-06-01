class /ADESSO/CL_IM_BPM_BADI_EMMA_CA definition
  public
  create public .

public section.

  interfaces IF_BADI_EMMA_CASE .
  interfaces IF_BADI_INTERFACE .
protected section.
private section.
ENDCLASS.



CLASS /ADESSO/CL_IM_BPM_BADI_EMMA_CA IMPLEMENTATION.


  METHOD if_badi_emma_case~transaction_start.

    DATA: lv_bparea               TYPE emma_bparea,
          lr_bpm_badi_trans_start TYPE REF TO /adesso/bpm_badi_trans_start.

    TRY.
        IF iv_ccat IS NOT INITIAL.
          lv_bparea = /adesso/cl_bpm_utility=>det_bparea( iv_ccat = iv_ccat ).
        ELSE.
          lv_bparea = /adesso/cl_bpm_utility=>det_bparea( iv_ccat = /adesso/cl_bpm_utility=>det_ccat( iv_casenr = iv_casenr ) ).
        ENDIF.

        GET BADI lr_bpm_badi_trans_start
          FILTERS
            business_process_area = lv_bparea.

        TRY.
            CALL METHOD lr_bpm_badi_trans_start->imp->transaction_start
              EXPORTING
                iv_casenr                = iv_casenr
                iv_ccat                  = iv_ccat
                iv_template_case         = iv_template_case
                iv_wmode                 = iv_wmode
                iv_allow_toggle_dispchan = iv_allow_toggle_dispchan
                iv_next_prev_case        = iv_next_prev_case
              IMPORTING
                ev_casenr                = ev_casenr
                ev_okcode                = ev_okcode.
          CATCH /adesso/cx_bpm_general .
        ENDTRY.


      CATCH cx_badi_not_implemented /adesso/cx_bpm_utility .
    ENDTRY.


  ENDMETHOD.
ENDCLASS.
