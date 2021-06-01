class /ADESSO/CL_BPU_DISPLAY_OBJECT definition
  public
  final
  create public .

public section.

  class-methods DISPLAY_ACCOUNT
    importing
      !IV_OBJECT_ID type DATA
      !IS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    raising
      /IDXGC/CX_GENERAL .
  class-methods DISPLAY_CONNOBJ
    importing
      !IV_OBJECT_ID type DATA
      !IS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    raising
      /IDXGC/CX_GENERAL .
  class-methods DISPLAY_CONTRACT
    importing
      !IV_OBJECT_ID type DATA
      !IS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    raising
      /IDXGC/CX_GENERAL .
  class-methods DISPLAY_INSTLN
    importing
      !IV_OBJECT_ID type DATA
      !IS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    raising
      /IDXGC/CX_GENERAL .
  class-methods DISPLAY_PARTNER
    importing
      !IV_OBJECT_ID type DATA
      !IS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    raising
      /IDXGC/CX_GENERAL .
protected section.
private section.
ENDCLASS.



CLASS /ADESSO/CL_BPU_DISPLAY_OBJECT IMPLEMENTATION.


  METHOD display_account.
    DATA: lv_account TYPE vkont_kk.

    lv_account = iv_object_id.

    CALL FUNCTION '/ADESSO/BPU_DISPLAY_ACCOUNT' STARTING NEW TASK 'DISPLAY_ACCOUNT'
      EXPORTING
        iv_account     = lv_account
        iv_keydate     = is_proc_step_data-proc_date
      EXCEPTIONS
        error_occurred = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD display_connobj.
    DATA: lv_haus TYPE haus.

    lv_haus = iv_object_id.

    CALL FUNCTION '/ADESSO/BPU_DISPLAY_CONNOBJ' STARTING NEW TASK 'DISPLAY_CONNOBJ'
      EXPORTING
        iv_haus        = lv_haus
      EXCEPTIONS
        error_occurred = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD display_contract.
    DATA: lv_vertrag TYPE vertrag.

    lv_vertrag = iv_object_id.

    CALL FUNCTION '/ADESSO/BPU_DISPLAY_CONTRACT' STARTING NEW TASK 'DISPLAY_CONTRACT'
      EXPORTING
        iv_vertrag     = lv_vertrag
      EXCEPTIONS
        error_occurred = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD display_instln.
    DATA: lv_anlage TYPE anlage.

    lv_anlage = iv_object_id.

    CALL FUNCTION '/ADESSO/BPU_DISPLAY_INSTLN' STARTING NEW TASK 'DISPLAY_INSTLN'
      EXPORTING
        iv_anlage      = lv_anlage
        iv_keydate     = is_proc_step_data-proc_date
      EXCEPTIONS
        error_occurred = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD display_partner.
    DATA: lv_partner TYPE bu_partner.

    lv_partner = iv_object_id.

    CALL FUNCTION '/ADESSO/BPU_DISPLAY_PARTNER' STARTING NEW TASK 'DISPLAY_PARTNER'
      EXPORTING
        iv_partner     = lv_partner
        iv_keydate     = is_proc_step_data-proc_date
      EXCEPTIONS
        error_occurred = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
