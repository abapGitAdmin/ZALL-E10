*&---------------------------------------------------------------------*
*& Report  /ADESSO/HMV_IDOC_STATUS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /adesso/hmv_idoc_status.

INCLUDE /adesso/hmv_constants.
INCLUDE /adesso/hmv_idoc_status_selscr.
"INCLUDE /adesso/hmv_idoc_status_class.

TYPE-POOLS: <icon>.

DATA:
  t_sel_datum TYPE /adesso/hmv_t_sel_tab_datum,
  s_sel_datum TYPE /adesso/hmv_s_sel_tab_datum,
  t_sel_serv  TYPE /adesso/hmv_t_sel_tab_serv,
  s_sel_serv  TYPE /adesso/hmv_s_sel_tab_serv,
  t_sel_intui TYPE /adesso/hmv_t_sel_tab_intui,
  s_sel_intui TYPE /adesso/hmv_s_sel_tab_intui,
  t_sel_serve TYPE /adesso/hmv_t_sel_tab_serve,
  s_sel_serve TYPE /adesso/hmv_s_sel_tab_serve.

DATA: t_invout TYPE TABLE OF /adesso/hmv_xpro,
      s_invout TYPE          /adesso/hmv_xpro.

DATA:
  t_sel_taski      TYPE RANGE OF edextaskidoc-dextaskid,
  t_sel_taski_part LIKE t_sel_taski,
  t_listheader     TYPE          slis_t_listheader.

DATA:
  BEGIN OF t_seledidc OCCURS 0,
    dextaskid TYPE e_dextaskid,
  END OF t_seledidc.

DATA: gt_filtered TYPE slis_t_filtered_entries.
DATA:
  g_save     TYPE char1,
  g_exit     TYPE char1,
  gx_variant LIKE disvariant,
  g_variant  LIKE disvariant,
  g_repid    LIKE sy-repid.

DATA  gc_taskmanager  TYPE REF TO /adesso/cl_hmv_tasks.
DATA  gt_alv_grid_data TYPE /adesso/cl_hmv_idoc_stat_class=>tt_dfkkthi_memi_out.
DATA  gc_semaphore  TYPE REF TO cl_lib_semaphore.
DATA  gs_stats    TYPE /adesso/hmv_idoc.


**************************************************************************
* START-OF-SELECTION
**************************************************************************
START-OF-SELECTION.
  DATA ls_task TYPE gc_taskmanager->ty_task.
  DATA lt_out      TYPE /adesso/hmv_t_memi_out.
  DATA ls_stats    TYPE /adesso/hmv_idoc.
  DATA ls_const    type  /ADESSO/HMV_S_IDOC_CONST.
  DATA lS_SEL_PARAMS TYPE /ADESSO/HMV_S_IDOC_SEL_PARAMS.
  DATA lc_idoc_status type ref to /adesso/cl_hmv_idoc_stat_class.

  PERFORM assign_constants.

  IF so_taski IS INITIAL.
    PERFORM pre_sel_edidc.
  ENDIF.

  IF so_taski IS NOT INITIAL.
    REFRESH so_datum.
  ENDIF.

  t_sel_taski[] = so_taski[].
  SORT t_sel_taski BY low.

  IF so_datum IS NOT INITIAL.
    LOOP AT so_datum.
      MOVE-CORRESPONDING so_datum TO s_sel_datum.
      APPEND s_sel_datum TO t_sel_datum.
    ENDLOOP.
  ENDIF.

  IF so_serv IS NOT INITIAL.
    LOOP AT so_serv.
      MOVE-CORRESPONDING so_serv TO s_sel_serv.
      APPEND s_sel_serv TO t_sel_serv.
    ENDLOOP.
  ENDIF.

  IF so_intui IS NOT INITIAL.
    LOOP AT so_intui.
      MOVE-CORRESPONDING so_intui TO s_sel_intui.
      APPEND s_sel_intui TO t_sel_intui.
    ENDLOOP.
  ENDIF.

  " Strukturen fuer Parameteruebergabe
  ls_const-repid  = sy-repid.
  ls_const-slset  = sy-slset.
  ls_const-c_doc_kzd = c_doc_kzd.
  ls_const-c_invoice_status_03 = c_invoice_status_03.
  ls_const-c_invoice_status_04 = c_invoice_status_04.
  ls_const-c_listheader_typ    = c_listheader_typ.


  ls_sel_params-p_maxpar       = p_maxpar.
  ls_sel_params-p_noshow       = p_noshow.
  ls_sel_params-p_shoalv       = p_shoalv.
  ls_sel_params-p_statistics   = p_stat.
  ls_sel_params-p_upd_dfk      = p_updd.
  ls_sel_params-p_upd_memi     = p_updm.
  ls_sel_params-p_upd_msb      = p_updms.
  ls_sel_params-so_datum       = t_sel_datum[].
  ls_sel_params-so_intui       = t_sel_intui[].
  ls_sel_params-so_serv        = t_sel_serv[].
  ls_sel_params-so_serve       = t_sel_serve[].
  ls_sel_params-so_taskid      = so_taski[].
  "ls_sel_params-so_taski       = t_sel_taski_part[].
  gs_stats-datum = sy-datum.
  gs_stats-stati = sy-uzeit.
  " wird benoetigt am Ende der Tasks und am Reportende
  create OBJECT lc_idoc_status
    EXPORTING
      is_const     = ls_const
      is_selparams = ls_sel_params.

  CLEAR gt_alv_grid_data.
  CREATE OBJECT gc_taskmanager EXPORTING iv_max_par_taks = p_maxpar.

  DATA(lv_nr_selcond) = lines( t_sel_taski ).
*  IF lv_nr_selcond < 0.
*    " xxxx debug
*    lv_nr_selcond  = 50.
*    c_min_selcond_tasks = 1.
*    c_max_selcond_tasks = 2.
*  ENDIF.
  gc_taskmanager->create_tasks(
    EXPORTING
      iv_repid             = sy-repid
      iv_size_selector_array = lv_nr_selcond
      iv_min_selects         = c_min_selcond_tasks
      iv_max_selects         = c_max_selcond_tasks
  ).
  IF p_maxpar > 1.
    gc_semaphore = cl_lib_semaphore=>new( 1 ).
  ENDIF.
  WHILE ( gc_taskmanager->get_next_task( IMPORTING es_task = ls_task ) EQ abap_true ).

    REFRESH t_sel_taski_part.

    APPEND LINES OF t_sel_taski
      FROM ls_task-low
        TO ls_task-high
        TO t_sel_taski_part.

    " xxxx debug
    "CHECK t_sel_taski_part IS NOT INITIAL.

    " Werte für HMV_IDOC_STATUS constructor
    ls_sel_params-so_taskid = t_sel_taski_part.

    IF gc_taskmanager->mv_max_par_tasks > 1.
      " Parallel
      CALL FUNCTION '/ADESSO/HMV_IDOC_STAT'
        STARTING NEW TASK ls_task-name
        DESTINATION IN GROUP DEFAULT
        PERFORMING ende_task ON END OF TASK
        EXPORTING
          is_const            = ls_const
          is_sel_params       = ls_sel_params.
    ELSE.
      " Sequentiell
      REFRESH lt_out.
      CALL FUNCTION '/ADESSO/HMV_IDOC_STAT'
        EXPORTING
          is_const            = ls_const
          is_sel_params       = ls_sel_params
        IMPORTING
          es_stats               = ls_stats
        TABLES
          et_alv_grid_data       = lt_out.
      gc_taskmanager->task_finished( ).
      APPEND LINES OF lt_out TO gt_alv_grid_data.
      lc_idoc_status->add_statistics(
        EXPORTING is_sta1 = ls_stats
        CHANGING  cs_sta2 = gs_stats ).
    ENDIF.

  ENDWHILE.

  gc_taskmanager->wait_for_all_tasks( ).

  " muehsam aufsummierten Statisksatz in DB ablegen
  lc_idoc_status->write_stats( CHANGING  cs_stats = gs_stats ).

  " nochn Grid ausgeben
  IF p_shoalv EQ abap_true OR p_stat EQ abap_true.
    lc_idoc_status->show_data(
     EXPORTING
       it_alv_grid_data = gt_alv_grid_data
       is_stats         = gs_stats ).
  ENDIF.

**************************************************************************
* END-OF-SELECTION
**************************************************************************
END-OF-SELECTION.
*&---------------------------------------------------------------------*
*&      Form  ende_task
*&---------------------------------------------------------------------*
FORM ende_task  USING taskname.
  DATA  lt_out      TYPE /adesso/hmv_t_memi_out.
  DATA  ls_stats    TYPE /adesso/hmv_idoc.

  RECEIVE RESULTS FROM FUNCTION '/ADESSO/HMV_IDOC_STAT'
    IMPORTING
       es_stats = ls_stats
    TABLES
       et_alv_grid_data  =  lt_out
    EXCEPTIONS
       communication_failure = 1
       system_failure        = 2.

  IF sy-subrc = 0.
    WAIT UNTIL gc_semaphore->reserve(  ) EQ abap_true.

    gc_taskmanager->task_finished( ).
    APPEND LINES OF lt_out TO gt_alv_grid_data.

    lc_idoc_status->add_statistics(
      EXPORTING is_sta1 = ls_stats
      CHANGING  cs_sta2 = gs_stats ).

    gc_semaphore->release( ).
  ELSE.
    MESSAGE |Fehler bei ende_task { taskname }| TYPE 'E'.
    STOP.
  ENDIF.


ENDFORM.
**&---------------------------------------------------------------------*
**&      Form  top_of_page
**&---------------------------------------------------------------------*
*FORM top_of_page .                                          "#EC *
*  CALL METHOD cl_idoc->build_header
*    RECEIVING
*      r_header = t_listheader.
*
*  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
*    EXPORTING
*      it_list_commentary = t_listheader.
*ENDFORM.                    " top_of_page

*&---------------------------------------------------------------------*
*&      Form  PRE_SEL_EDIDC
*&---------------------------------------------------------------------*
FORM pre_sel_edidc .

  DATA: rng_msgt_tab TYPE /adesso/hmv_rt_msgt.

  rng_msgt_tab = /adesso/cl_hmv_customizing=>get_message_type( is_so_datum = so_datum ).


  SELECT b~dextaskid
        INTO CORRESPONDING FIELDS OF TABLE t_seledidc
        FROM edidc AS a
        INNER JOIN edextaskidoc AS b ON b~docnum = a~docnum
        INNER JOIN edextask AS c ON c~dextaskid = b~dextaskid
         WHERE a~upddat IN so_datum
           AND a~mestyp IN rng_msgt_tab
           AND c~dexservprovself IN so_serv.

  SORT t_seledidc.

  DELETE ADJACENT DUPLICATES FROM t_seledidc COMPARING ALL FIELDS.
  LOOP AT t_seledidc.
    CLEAR so_taski.
    so_taski-sign   = 'I'.
    so_taski-option = 'EQ'.
    so_taski-low    = t_seledidc-dextaskid.
    APPEND so_taski.
  ENDLOOP.
ENDFORM.                    " PRE_SEL_EDIDC
