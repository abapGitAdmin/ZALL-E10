FUNCTION /adesso/hmv_parsel .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IF_REPORT_NAME) TYPE  RALDB_REPO
*"     REFERENCE(IF_REPORT_VARIANT) TYPE  RALDB_VARI
*"     REFERENCE(IS_SELOPT_TO_SPLIT) TYPE  WLC_SELECT_FIELDS
*"     REFERENCE(IS_SELOPT_TO_FILL) TYPE  WLC_SELECT_FIELDS
*"     REFERENCE(IS_CUST_OPTIONS) TYPE  WLC_OPTIONS
*"     REFERENCE(IF_REPORT_PARALLEL) TYPE  PROGRAMM
*"     REFERENCE(IT_PRESEL_CRITERIAS) TYPE  WLC_SELECT_PARAMS_T
*"  EXPORTING
*"     REFERENCE(ES_SELOPT_TO_SPLIT) TYPE  WLC_SELECT_FIELDS
*"     REFERENCE(ES_SELOPT_TO_FILL) TYPE  WLC_SELECT_FIELDS
*"     REFERENCE(ET_WORKLOAD) TYPE  WLC_WORKLOAD_T
*"  CHANGING
*"     REFERENCE(CT_TIME_STATISTICS) TYPE  WLC_JOBTIME_STATISTICS_T
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

  TYPE-POOLS: rsds.
  DATA: lt_select_where        TYPE rsds_where_tab
       ,lt_select_fields       TYPE wlc_select_field_t
       ,lt_select_fields_info  TYPE rsti_t_dfi
       ,ls_workload            TYPE wlc_workload.

  DATA: s_presel_criterias TYPE wlc_select_params.
  DATA:
    BEGIN OF t_seledidc OCCURS 0,
      dextaskid TYPE e_dextaskid,
    END OF t_seledidc.
  DATA: t_edextask TYPE edextask OCCURS 0.
  DATA: r_upddat TYPE RANGE OF edi_upddat WITH HEADER LINE.

  FIELD-SYMBOLS: <s_edextask> TYPE edextask.


PERFORM assign_constants.
* <<< ET_20160311

* >>> ET_20160311
*  CONSTANTS: c_mestyp TYPE edi_mestyp VALUE 'ISU_BILL_LIST_INFORMATION'.

  LOOP AT it_presel_criterias
       INTO s_presel_criterias
       WHERE selpar = 'SO_DATUM'.
    MOVE-CORRESPONDING s_presel_criterias TO r_upddat.
    APPEND r_upddat.
  ENDLOOP.

  CALL FUNCTION 'WLC_PRESELECT_RANGE2WHERE'
    EXPORTING
      if_select_table     = 'EDEXTASK'
      if_presel_step      = '0'
      it_presel_criterias = it_presel_criterias
    IMPORTING
      et_select_where     = lt_select_where
*     EF_SUBRC            =
    EXCEPTIONS
      wrong_input         = 01
      internal_error      = 02
      OTHERS              = 99.
  IF sy-subrc <> 0.
    MESSAGE e000(wlc_parallel)
            WITH 'Customer-Function: Not specified Error'
                 sy-repid 'WLC_PRESELECT_RANGE2WHERE'
         RAISING error.
  ENDIF.

  GET TIME.
  CALL FUNCTION 'WLC_RUNTIMER'
    EXPORTING
      if_event           = 'PRESELGEN1'
      if_start           = 'X'
    CHANGING
      ct_time_statistics = ct_time_statistics.


* <<< ET_20160311
  DATA: rng_msgt_tab TYPE /adesso/hmv_rt_msgt,
        so_date      TYPE /adesso/cl_hmv_customizing=>ty_ab_bis.

  so_date-sign   = 'I'.
  so_date-option = 'EQ'.
  so_date-low    = c_faedn_from.
  so_date-high   = sy-datum.

  rng_msgt_tab = /adesso/cl_hmv_customizing=>get_message_type( is_so_datum = so_date ).

  SELECT b~dextaskid
       INTO CORRESPONDING FIELDS OF TABLE t_seledidc
       FROM edidc AS a
            INNER JOIN edextaskidoc AS b
            ON b~docnum = a~docnum
        WHERE a~upddat IN r_upddat
        AND   a~mestyp IN rng_msgt_tab. " = c_mestyp.
* >>> ET_20160311

  SORT t_seledidc.
  DELETE ADJACENT DUPLICATES FROM t_seledidc COMPARING ALL FIELDS.

  IF sy-subrc <> 0.
    MESSAGE e029(wlc_parallel)
            WITH if_report_name
         RAISING error.
  ENDIF.

  GET TIME.
  CALL FUNCTION 'WLC_RUNTIMER'
    EXPORTING
      if_event           = 'PRESELGEN1'
      if_start           = ' '
    CHANGING
      ct_time_statistics = ct_time_statistics.

  GET TIME.
  CALL FUNCTION 'WLC_RUNTIMER'
    EXPORTING
      if_event           = 'PRESELGEN2'
      if_start           = 'X'
    CHANGING
      ct_time_statistics = ct_time_statistics.

  SELECT * FROM edextask
           INTO CORRESPONDING FIELDS OF TABLE t_edextask
           FOR ALL ENTRIES IN t_seledidc
           WHERE dextaskid = t_seledidc-dextaskid
           AND   (lt_select_where).

  IF sy-subrc <> 0.
    MESSAGE e029(wlc_parallel)
            WITH if_report_name
         RAISING error.
  ENDIF.

  GET TIME.
  CALL FUNCTION 'WLC_RUNTIMER'
    EXPORTING
      if_event           = 'PRESELGEN2'
      if_start           = ' '
    CHANGING
      ct_time_statistics = ct_time_statistics.


  LOOP AT t_edextask ASSIGNING <s_edextask>.
    CLEAR ls_workload.
    ls_workload-split_value      = <s_edextask>-dextaskid.
    ls_workload-fill_value-low   = <s_edextask>-dextaskid.
    ls_workload-weighting_factor = 1.
    APPEND ls_workload TO et_workload.
  ENDLOOP.
ENDFUNCTION.
