class /ADESSO/CL_BPM_CUST_SPEC_EIDE definition
  public
  create public .

public section.

  class-methods DETERMINE_ESM
    importing
      !IV_PROC_ID type /IDXGC/DE_PROC_ID
      !IV_PROC_VERSION type /IDXGC/DE_PROCESS_VERSION
      !IV_PROC_STEP_NO type /IDXGC/DE_PROC_STEP_NO
      !IV_CHKID type EIDESWTCHECKID
      !IV_EXCN_NAME type /IDXGC/DE_CHECK_RESULT
    returning
      value(RS_ESM) type /ADESSO/BPM_ESM
    raising
      /ADESSO/CX_BPM_UTILITY .
  class-methods DETERMINE_RULE
    importing
      !IV_PROC_ID type /IDXGC/DE_PROC_ID
      !IV_PROC_VERSION type /IDXGC/DE_PROCESS_VERSION
      !IV_PROC_STEP_NO type /IDXGC/DE_PROC_STEP_NO
      !IV_CHKID type EIDESWTCHECKID
      !IV_EXCN_NAME type /IDXGC/DE_CHECK_RESULT
    returning
      value(RS_RULE) type /ADESSO/BPM_RULE
    raising
      /ADESSO/CX_BPM_UTILITY .
  class-methods DETERMINE_TXT
    importing
      !IV_PROC_ID type /IDXGC/DE_PROC_ID
      !IV_PROC_VERSION type /IDXGC/DE_PROCESS_VERSION
      !IV_PROC_STEP_NO type /IDXGC/DE_PROC_STEP_NO
      !IV_CHKID type EIDESWTCHECKID
      !IV_EXCN_NAME type /IDXGC/DE_CHECK_RESULT
    returning
      value(RS_TXT) type /ADESSO/BPM_TXT
    raising
      /ADESSO/CX_BPM_UTILITY .
  class-methods DETERMINE_BPM_ID
    importing
      !IV_PROC_ID type /IDXGC/DE_PROC_ID
      !IV_PROC_VERSION type /IDXGC/DE_PROCESS_VERSION
      !IV_PROC_STEP_NO type /IDXGC/DE_PROC_STEP_NO
      !IV_CHKID type EIDESWTCHECKID
      !IV_EXCN_NAME type /IDXGC/DE_CHECK_RESULT
    returning
      value(RS_BPM_ID) type /ADESSO/BPM_PID
    raising
      /ADESSO/CX_BPM_UTILITY .
protected section.
private section.
ENDCLASS.



CLASS /ADESSO/CL_BPM_CUST_SPEC_EIDE IMPLEMENTATION.


  METHOD determine_bpm_id.
    DATA: lt_bpm_pid     TYPE TABLE OF /adesso/bpm_pid,
          lv_cnt_new     TYPE i,
          lv_cnt_old     TYPE i,
          lr_typedescr   TYPE REF TO cl_abap_typedescr,
          lr_structdescr TYPE REF TO cl_abap_structdescr,
          lt_components  TYPE ddfields.

    FIELD-SYMBOLS: <fs_bpm_pid>         LIKE LINE OF lt_bpm_pid,
                   <fs_component>       LIKE LINE OF lt_components,
                   <fs_component_value> TYPE any.



    SELECT * FROM /adesso/bpm_pid INTO TABLE lt_bpm_pid WHERE ( proc_id = iv_proc_id OR proc_id = space ) AND
                                                              ( proc_version = iv_proc_version OR proc_version = space ) AND
                                                              ( stepno = iv_proc_step_no OR stepno = 0 ) AND
                                                              ( chkid = iv_chkid OR chkid = space ) AND
                                                              ( excn_name = iv_excn_name OR excn_name = space ).

    CASE lines( lt_bpm_pid ).
      WHEN 1.
        READ TABLE lt_bpm_pid ASSIGNING <fs_bpm_pid> INDEX 1.
        rs_bpm_id = <fs_bpm_pid>.
      WHEN 0.
        clear rs_bpm_id.
      WHEN OTHERS.
        LOOP AT lt_bpm_pid ASSIGNING <fs_bpm_pid>.
          lr_typedescr = cl_abap_structdescr=>describe_by_name( p_name = '/ADESSO/BPM_PID' ).
          lr_structdescr ?= lr_typedescr.
          lt_components = lr_structdescr->get_ddic_field_list( ).

          LOOP AT lt_components ASSIGNING <fs_component> WHERE keyflag = abap_true.
            ASSIGN COMPONENT <fs_component>-fieldname OF STRUCTURE <fs_bpm_pid> TO <fs_component_value>.
            IF <fs_component_value> IS NOT INITIAL.
              ADD 1 TO lv_cnt_new.
            ENDIF.
          ENDLOOP.
          IF lv_cnt_new > lv_cnt_old.
            rs_bpm_id = <fs_bpm_pid>.
            lv_cnt_old = lv_cnt_new.
          ENDIF.
          CLEAR lv_cnt_new.
        ENDLOOP.
    ENDCASE.

  ENDMETHOD.


  METHOD determine_esm.
    DATA: lt_bpm_esm     TYPE TABLE OF /adesso/bpm_esm,
          lv_cnt_new     TYPE i,
          lv_cnt_old     TYPE i,
          lr_typedescr   TYPE REF TO cl_abap_typedescr,
          lr_structdescr TYPE REF TO cl_abap_structdescr,
          lt_components  TYPE ddfields.

    FIELD-SYMBOLS: <fs_bpm_esm>         LIKE LINE OF lt_bpm_esm,
                   <fs_component>       LIKE LINE OF lt_components,
                   <fs_component_value> TYPE any.



    SELECT * FROM /adesso/bpm_esm INTO TABLE lt_bpm_esm WHERE ( proc_id = iv_proc_id OR proc_id = space ) AND
                                                              ( proc_version = iv_proc_version OR proc_version = space ) AND
                                                              ( stepno = iv_proc_step_no OR stepno = 0 ) AND
                                                              ( chkid = iv_chkid OR chkid = space ) AND
                                                              ( excn_name = iv_excn_name OR excn_name = space ).

    CASE lines( lt_bpm_esm ).
      WHEN 1.
        READ TABLE lt_bpm_esm ASSIGNING <fs_bpm_esm> INDEX 1.
        rs_esm = <fs_bpm_esm>.
      WHEN 0.
        clear rs_esm.
      WHEN OTHERS.
        LOOP AT lt_bpm_esm ASSIGNING <fs_bpm_esm>.
          lr_typedescr = cl_abap_structdescr=>describe_by_name( p_name = '/ADESSO/BPM_PID' ).
          lr_structdescr ?= lr_typedescr.
          lt_components = lr_structdescr->get_ddic_field_list( ).

          LOOP AT lt_components ASSIGNING <fs_component> WHERE keyflag = abap_true.
            ASSIGN COMPONENT <fs_component>-fieldname OF STRUCTURE <fs_bpm_esm> TO <fs_component_value>.
            IF <fs_component_value> IS NOT INITIAL.
              ADD 1 TO lv_cnt_new.
            ENDIF.
          ENDLOOP.
          IF lv_cnt_new > lv_cnt_old.
            rs_esm = <fs_bpm_esm>.
            lv_cnt_old = lv_cnt_new.
          ENDIF.
          CLEAR lv_cnt_new.
        ENDLOOP.
    ENDCASE.
  ENDMETHOD.


  METHOD determine_rule.

    DATA: lt_bpm_rule    TYPE TABLE OF /adesso/bpm_rule,
          lv_cnt_new     TYPE i,
          lv_cnt_old     TYPE i,
          lr_typedescr   TYPE REF TO cl_abap_typedescr,
          lr_structdescr TYPE REF TO cl_abap_structdescr,
          lt_components  TYPE ddfields.

    FIELD-SYMBOLS: <fs_bpm_rule>        LIKE LINE OF lt_bpm_rule,
                   <fs_component>       LIKE LINE OF lt_components,
                   <fs_component_value> TYPE any.


    SELECT * FROM /adesso/bpm_rule INTO TABLE lt_bpm_rule WHERE ( proc_id = iv_proc_id OR proc_id = space ) AND
                                                                ( proc_version = iv_proc_version OR proc_version = space ) AND
                                                                ( stepno = iv_proc_step_no OR stepno = 0 ) AND
                                                                ( chkid = iv_chkid OR chkid = space ) AND
                                                                ( excn_name = iv_excn_name OR excn_name = space ).

    CASE lines( lt_bpm_rule ).
      WHEN 1.
        READ TABLE lt_bpm_rule ASSIGNING <fs_bpm_rule> INDEX 1.
        rs_rule = <fs_bpm_rule>.
      WHEN 0.
        clear rs_rule.
      WHEN OTHERS.
        LOOP AT lt_bpm_rule ASSIGNING <fs_bpm_rule>.
          lr_typedescr = cl_abap_structdescr=>describe_by_name( p_name = '/ADESSO/BPM_RULE' ).
          lr_structdescr ?= lr_typedescr.
          lt_components = lr_structdescr->get_ddic_field_list( ).

          LOOP AT lt_components ASSIGNING <fs_component> WHERE keyflag = abap_true.
            ASSIGN COMPONENT <fs_component>-fieldname OF STRUCTURE <fs_bpm_rule> TO <fs_component_value>.
            IF <fs_component_value> IS NOT INITIAL.
              ADD 1 TO lv_cnt_new.
            ENDIF.
          ENDLOOP.
          IF lv_cnt_new > lv_cnt_old.
            rs_rule = <fs_bpm_rule>.
            lv_cnt_old = lv_cnt_new.
          ENDIF.
          CLEAR lv_cnt_new.
        ENDLOOP.
    ENDCASE.


  ENDMETHOD.


  METHOD determine_txt.
    DATA: lt_bpm_txt     TYPE TABLE OF /adesso/bpm_txt,
          lv_cnt_new     TYPE i,
          lv_cnt_old     TYPE i,
          lr_typedescr   TYPE REF TO cl_abap_typedescr,
          lr_structdescr TYPE REF TO cl_abap_structdescr,
          lt_components  TYPE ddfields.

    FIELD-SYMBOLS: <fs_bpm_txt>         LIKE LINE OF lt_bpm_txt,
                   <fs_component>       LIKE LINE OF lt_components,
                   <fs_component_value> TYPE any.



    SELECT * FROM /adesso/bpm_txt INTO TABLE lt_bpm_txt WHERE ( proc_id = iv_proc_id OR proc_id = space ) AND
                                                              ( proc_version = iv_proc_version OR proc_version = space ) AND
                                                              ( stepno = iv_proc_step_no OR stepno = 0 ) AND
                                                              ( chkid = iv_chkid OR chkid = space ) AND
                                                              ( excn_name = iv_excn_name OR excn_name = space ).

    CASE lines( lt_bpm_txt ).
      WHEN 1.
        READ TABLE lt_bpm_txt ASSIGNING <fs_bpm_txt> INDEX 1.
        rs_txt = <fs_bpm_txt>.
      WHEN 0.
        clear rs_txt.
      WHEN OTHERS.
        LOOP AT lt_bpm_txt ASSIGNING <fs_bpm_txt>.
          lr_typedescr = cl_abap_structdescr=>describe_by_name( p_name = '/ADESSO/BPM_PID' ).
          lr_structdescr ?= lr_typedescr.
          lt_components = lr_structdescr->get_ddic_field_list( ).

          LOOP AT lt_components ASSIGNING <fs_component> WHERE keyflag = abap_true.
            ASSIGN COMPONENT <fs_component>-fieldname OF STRUCTURE <fs_bpm_txt> TO <fs_component_value>.
            IF <fs_component_value> IS NOT INITIAL.
              ADD 1 TO lv_cnt_new.
            ENDIF.
          ENDLOOP.
          IF lv_cnt_new > lv_cnt_old.
            rs_txt = <fs_bpm_txt>.
            lv_cnt_old = lv_cnt_new.
          ENDIF.
          CLEAR lv_cnt_new.
        ENDLOOP.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
