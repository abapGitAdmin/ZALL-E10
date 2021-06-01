class /ADESSO/CL_BPU_IM_BADI_EC_TRAN definition
  public
  create public .

public section.

  interfaces IF_BADI_EMMA_CASE_TRANSACTION .
  interfaces IF_BADI_INTERFACE .
protected section.
private section.
ENDCLASS.



CLASS /ADESSO/CL_BPU_IM_BADI_EC_TRAN IMPLEMENTATION.


  method IF_BADI_EMMA_CASE_TRANSACTION~ADJUST_ALVMSG_OUTPUT.
  endmethod.


  method IF_BADI_EMMA_CASE_TRANSACTION~ADJUST_ALVOBJ_OUTPUT.
  endmethod.


  METHOD if_badi_emma_case_transaction~adjust_alvproc_output.
    IF is_case-mainobjtype = /idxgc/if_constants=>gc_object_pdoc_bor. "Nur für Klärfälle zu Prozessdokumenten
      TRY.
          ct_proc_change  = /adesso/cl_bpu_utility=>det_processes( iv_casenr = is_case-casenr it_actual_proc = it_proc ).
        CATCH /idxgc/cx_general.
          "Bei Fehler ohne Änderung weiter.
      ENDTRY.
    ENDIF.
  ENDMETHOD.


  method IF_BADI_EMMA_CASE_TRANSACTION~CALL_ENHANCEMENT_FUNCTION.
  endmethod.


  METHOD if_badi_emma_case_transaction~change_description.
  ENDMETHOD.


  METHOD if_badi_emma_case_transaction~change_description_output.
    IF is_case-mainobjtype = /idxgc/if_constants=>gc_object_pdoc_bor. "Nur für Klärfälle zu Prozessdokumenten
      TRY.
          ct_tline = /adesso/cl_bpu_utility=>det_description( iv_casenr = is_case-casenr it_actual_tline = ct_tline ).
        CATCH /idxgc/cx_general.
          "Ohne Erweiterung der Beschreibung weiter
      ENDTRY.
    ENDIF.
  ENDMETHOD.


  method IF_BADI_EMMA_CASE_TRANSACTION~EXCLUDE_ALV_BUTTONS.
  endmethod.


  method IF_BADI_EMMA_CASE_TRANSACTION~EXCLUDE_FCODES.
  endmethod.
ENDCLASS.
