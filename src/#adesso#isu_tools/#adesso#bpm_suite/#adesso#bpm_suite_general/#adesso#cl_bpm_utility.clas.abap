class /ADESSO/CL_BPM_UTILITY definition
  public
  final
  create public .

public section.

  class-data AV_MTEXT type STRING .

  class-methods DET_BPAREA
    importing
      !IV_CCAT type EMMA_CCAT
    returning
      value(RV_BPAREA) type EMMA_BPAREA
    raising
      /ADESSO/CX_BPM_UTILITY .
  class-methods DET_GEN_CUST
    importing
      !IV_KEYDATE type DATS default SY-DATUM
      !IV_BPAREA type EMMA_BPAREA
    returning
      value(RS_GEN_CUST) type /ADESSO/BPM_GEN
    raising
      /ADESSO/CX_BPM_UTILITY .
  class-methods GET_BPM_CASES_BY_PARAM
    importing
      !IV_ORG_TYPE type OTYPE optional
      !IV_ORG_NAME type ACTORID optional
      !IT_CASENR type EMMA_RANGES_TAB optional
      !IT_CCAT type EMMA_RANGES_TAB optional
      !IT_CASESTAT type EMMA_RANGES_TAB optional
      !IT_CURRPROC type EMMA_RANGES_TAB optional
      !IT_MAINOBJKEY type EMMA_RANGES_TAB optional
      !IV_ORG_TYPE_EXCLUDE type OTYPE optional
      !IV_ORG_NAME_EXCLUDE type ACTORID optional
    returning
      value(RT_EMMA_CASE) type /ADESSO/TT_BPM_EMMA_CASE_OBJ
    raising
      /ADESSO/CX_BPM_UTILITY .
  class-methods DET_CCAT
    importing
      !IV_CASENR type EMMA_CNR
    returning
      value(RV_CCAT) type EMMA_CCAT
    raising
      /ADESSO/CX_BPM_UTILITY .
protected section.
private section.
ENDCLASS.



CLASS /ADESSO/CL_BPM_UTILITY IMPLEMENTATION.


  METHOD det_bparea.
    DATA: lr_emma_dbl TYPE REF TO cl_emma_dbl,
          ls_ccat_hdr TYPE emmac_ccat_hdr.

    lr_emma_dbl = cl_emma_dbl=>create_dblayer( ).

    IF lr_emma_dbl IS BOUND.
      CALL METHOD lr_emma_dbl->readc_ccat_hdr
        EXPORTING
          iv_ccat        = iv_ccat
        RECEIVING
          es_ccat        = ls_ccat_hdr
        EXCEPTIONS
          ccat_not_found = 1
          OTHERS         = 2.
      IF sy-subrc <> 0.
        /adesso/cx_bpm_utility=>raise_exception_from_msg( ).
      ENDIF.

      CALL METHOD lr_emma_dbl->read_bpcode
        EXPORTING
          iv_bpcode = ls_ccat_hdr-bpcode
        IMPORTING
          ev_bparea = rv_bparea
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.
      IF sy-subrc <> 0.
        /adesso/cx_bpm_utility=>raise_exception_from_msg( ).
      ENDIF.

    ELSE.
      MESSAGE e001(/adesso/bpm_utility) WITH iv_ccat INTO av_mtext.
      /adesso/cx_bpm_utility=>raise_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD det_ccat.

    DATA: lr_emma_dbl TYPE REF TO cl_emma_dbl,
          ls_case_hdr TYPE emma_case.

    lr_emma_dbl = cl_emma_dbl=>create_dblayer( ).

    IF lr_emma_dbl IS BOUND.

      CALL METHOD lr_emma_dbl->read_case_header
        EXPORTING
          iv_casenr = iv_casenr
        RECEIVING
          es_case   = ls_case_hdr
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.
      IF sy-subrc <> 0.
        /adesso/cx_bpm_utility=>raise_exception_from_msg( ).
      ENDIF.

      rv_ccat = ls_case_hdr-ccat.

    ELSE.
      MESSAGE e004(/adesso/bpm_utility) WITH iv_casenr INTO av_mtext.
      /adesso/cx_bpm_utility=>raise_exception_from_msg( ).
    ENDIF.

  ENDMETHOD.


  METHOD det_gen_cust.
    DATA: lt_gen_cust TYPE TABLE OF /adesso/bpm_gen.
    SELECT * FROM /adesso/bpm_gen INTO TABLE lt_gen_cust WHERE bparea = iv_bparea.

    IF sy-subrc <> 0.
      MESSAGE e002(/adesso/bpm_utility) WITH iv_bparea INTO av_mtext.
      /adesso/cx_bpm_utility=>raise_exception_from_msg( ).
    ENDIF.

    READ TABLE lt_gen_cust INTO rs_gen_cust INDEX 1.
  ENDMETHOD.


  METHOD get_bpm_cases_by_param.
    DATA: lt_actors    TYPE TABLE OF bapi_swhactor,
          lt_actor_id  TYPE RANGE OF actorid,
          ls_actor_id  LIKE LINE OF lt_actor_id,
          lr_case_db   TYPE REF TO cl_emma_dbl,
          lt_emma_case TYPE emma_case_tab,
          lr_case      TYPE REF TO cl_emma_case.

    FIELD-SYMBOLS: <fs_actors>    TYPE bapi_swhactor,
                   <fs_emma_case> TYPE emma_case.

    "Benutzer einschließen
    IF iv_org_type IS NOT INITIAL AND iv_org_name IS NOT INITIAL.

      ls_actor_id-sign = 'I'.
      ls_actor_id-option = 'EQ'.
      ls_actor_id-low = iv_org_name.

      APPEND ls_actor_id TO lt_actor_id.

      CALL METHOD cl_emma_case=>determine_superior_org_obj
        EXPORTING
          iv_orgtype               = iv_org_type
          iv_orgid                 = iv_org_name
          iv_wegid                 = 'EMMA1'
          iv_plvar                 = space
          iv_begda                 = sy-datum
          iv_endda                 = sy-datum
        RECEIVING
          et_actors                = lt_actors
        EXCEPTIONS
          error_determining_actors = 1
          OTHERS                   = 2.
      IF sy-subrc = 0.
      ENDIF.

      LOOP AT lt_actors ASSIGNING <fs_actors> WHERE otype = 'S' OR otype = 'US'.
        ls_actor_id-low = <fs_actors>-objid.
        APPEND ls_actor_id TO lt_actor_id.
      ENDLOOP.

    ENDIF.

    "Benutzer ausschließen
    IF iv_org_type_exclude IS NOT INITIAL AND iv_org_name_exclude IS NOT INITIAL.

      ls_actor_id-sign = 'E'.
      ls_actor_id-option = 'EQ'.
      ls_actor_id-low = iv_org_name_exclude.

      APPEND ls_actor_id TO lt_actor_id.

      CALL METHOD cl_emma_case=>determine_superior_org_obj
        EXPORTING
          iv_orgtype               = iv_org_type_exclude
          iv_orgid                 = iv_org_name_exclude
          iv_wegid                 = 'EMMA1'
          iv_plvar                 = space
          iv_begda                 = sy-datum
          iv_endda                 = sy-datum
        RECEIVING
          et_actors                = lt_actors
        EXCEPTIONS
          error_determining_actors = 1
          OTHERS                   = 2.
      IF sy-subrc = 0.
      ENDIF.

      LOOP AT lt_actors ASSIGNING <fs_actors> WHERE otype = 'S' OR otype = 'US'.
        ls_actor_id-low = <fs_actors>-objid.
        APPEND ls_actor_id TO lt_actor_id.
      ENDLOOP.

    ENDIF.

    SELECT * FROM emma_case AS emc
      JOIN emma_cactor AS ema ON emc~casenr = ema~casenr
      INTO CORRESPONDING FIELDS OF TABLE lt_emma_case
      WHERE emc~status     IN it_casestat AND
            emc~casenr     IN it_casenr AND
            emc~ccat       IN it_ccat AND
            emc~currproc   IN it_currproc AND
            emc~mainobjkey IN it_mainobjkey AND
            ema~objid      IN lt_actor_id.

    IF iv_org_type IS NOT INITIAL AND iv_org_name IS NOT INITIAL.

      SELECT * FROM emma_case APPENDING TABLE lt_emma_case
      WHERE status IN it_casestat AND
            casenr IN it_casenr AND
            ccat IN it_ccat AND
            currproc = iv_org_name.

    ENDIF.

    lr_case_db = cl_emma_dbl=>create_dblayer( ).

    SORT lt_emma_case BY casenr.
    DELETE ADJACENT DUPLICATES FROM lt_emma_case.

    IF lr_case_db IS BOUND.
      LOOP AT lt_emma_case ASSIGNING <fs_emma_case>.
        lr_case ?= lr_case_db->read_case_detail( iv_case = <fs_emma_case>-casenr ).
        APPEND lr_case TO rt_emma_case.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
