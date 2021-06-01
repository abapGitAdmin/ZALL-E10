class /ADESSO/CL_MDC_IM_PRO_EXTUI definition
  public
  create public .

public section.

  interfaces /ADESSO/IF_MDC_PRO_CHG .
  interfaces IF_BADI_INTERFACE .
protected section.

  class-data GR_PREVIOUS type ref to CX_ROOT .
  class-data GV_MTEXT type STRING .

  methods SET_EXTUI_DATA
    importing
      !IS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    changing
      !CS_OBJ type EEDM_UI_OBJECT
      !CS_AUTO type EUI_AUTO
    raising
      /IDXGC/CX_UTILITY_ERROR .
private section.
ENDCLASS.



CLASS /ADESSO/CL_MDC_IM_PRO_EXTUI IMPLEMENTATION.


  method /ADESSO/IF_MDC_PRO_CHG~CHANGE_AUTO.
  endmethod.


  METHOD /adesso/if_mdc_pro_chg~change_manual.

    CALL FUNCTION '/ADESSO/MDC_CHANGE_EXTUI' STARTING NEW TASK 'MDC_CHANGE_EXTUI'
      EXPORTING
        is_proc_step_data = is_proc_step_data.

  ENDMETHOD.


  method SET_EXTUI_DATA.
  endmethod.
ENDCLASS.
