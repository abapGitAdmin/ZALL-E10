class ZCL_AGC_BPM_FIND_OBJ_EIDE definition
  public
  inheriting from /ADESSO/CL_BPM_FIND_OBJ_EIDE
  create public .

public section.

  aliases GET_ACLASS
    for /ADESSO/IF_BPM_FILL_CONTAINER~GET_ACLASS .
  aliases GET_CCAT
    for /ADESSO/IF_BPM_FILL_CONTAINER~GET_CCAT .
  aliases GET_CUSTOMER_FLAG
    for /ADESSO/IF_BPM_FILL_CONTAINER~GET_CUSTOMER_FLAG .
  aliases GET_GRID
    for /ADESSO/IF_BPM_FILL_CONTAINER~GET_GRID .
  aliases GET_INSTLN_TYPE
    for /ADESSO/IF_BPM_FILL_CONTAINER~GET_INSTLN_TYPE .
  aliases GET_ISU_TASK
    for /ADESSO/IF_BPM_FILL_CONTAINER~GET_ISU_TASK .
  aliases GET_MANDT
    for /ADESSO/IF_BPM_FILL_CONTAINER~GET_MANDT .
  aliases GET_METMETHOD
    for /ADESSO/IF_BPM_FILL_CONTAINER~GET_METMETHOD .
  aliases GET_POD
    for /ADESSO/IF_BPM_FILL_CONTAINER~GET_POD .
  aliases GET_REGIOGROUP
    for /ADESSO/IF_BPM_FILL_CONTAINER~GET_REGIOGROUP .
  aliases GET_SYSID
    for /ADESSO/IF_BPM_FILL_CONTAINER~GET_SYSID .

  methods GET_CLASS_ATTRIBUTE
    redefinition .
  methods /ADESSO/IF_BPM_FILL_CONTAINER~GET_METMETHOD
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_AGC_BPM_FIND_OBJ_EIDE IMPLEMENTATION.


  METHOD /adesso/if_bpm_fill_container~get_metmethod.
    "Übernahme aus dem adesso Standard mit Ergänzung um Ermittlung des Zählerverfahrens aus dem System
    DATA: lv_metmethod TYPE /idxgc/de_meter_proc.

    FIELD-SYMBOLS: <fs_diverse_data> TYPE /idxgc/s_diverse_details.

    IF as_proc_step_data-diverse IS INITIAL.
      IF as_proc_step_data_src-diverse IS INITIAL.
        READ TABLE as_proc_step_data_add_src-diverse ASSIGNING <fs_diverse_data> INDEX 1.
      ELSE.
        READ TABLE as_proc_step_data_src-diverse ASSIGNING <fs_diverse_data> INDEX 1.
      ENDIF.
    ELSE.
      READ TABLE as_proc_step_data-diverse ASSIGNING <fs_diverse_data> INDEX 1.
    ENDIF.

    IF <fs_diverse_data> IS ASSIGNED AND <fs_diverse_data>-meter_proc IS NOT INITIAL.
      lv_metmethod = <fs_diverse_data>-meter_proc.
    ENDIF.

    IF lv_metmethod IS NOT INITIAL.
      fill_cont( iv_element = iv_element iv_data = lv_metmethod ).
    ELSE.
      TRY.
          lv_metmethod = zcl_agc_masterdata=>get_metmethod( iv_anlage = zcl_agc_masterdata=>get_anlage( iv_int_ui = as_proc_hdr-int_ui iv_keydate = as_proc_hdr-proc_date ) iv_keydate = as_proc_hdr-proc_date ).
          fill_cont( iv_element = iv_element iv_data = lv_metmethod ).
        CATCH zcx_agc_masterdata.
          rs_message = get_message( iv_msgid = '/ADESSO/BPM_CONT' iv_msgno = '001' iv_msgty = 'W' iv_msgv1 = iv_element ).
      ENDTRY.
    ENDIF.
  ENDMETHOD.


  METHOD get_class_attribute.
    FIELD-SYMBOLS: <ft_any> TYPE ANY TABLE.

    ASSIGN me->(iv_attribute) TO <ft_any>.

    IF <ft_any> IS ASSIGNED.
      et_attribute = <ft_any>.
    ELSE.
      /adesso/cx_bpm_general=>raise_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
