CLASS /adz/cl_hmv_select_idoc_status DEFINITION
  PUBLIC
  FINAL.

  PUBLIC SECTION.
    DATA mt_out   TYPE /adz/hmv_t_memi_out.

    METHODS:
      constructor
        IMPORTING is_constants TYPE  /adz/hmv_s_constants,

      read_idoc_data
        IMPORTING is_sel_screen TYPE /adz/hmv_s_idoc_sel_params,
      get_statistics
        RETURNING VALUE(rs_stats) TYPE /adz/hmv_idoc,

      ende_proc_task
        IMPORTING p_task TYPE clike

        .
  PROTECTED SECTION.

  PRIVATE SECTION.
    DATA  ms_constants  TYPE /adz/hmv_s_constants.
    DATA  ms_sel_params TYPE /adz/hmv_s_idoc_sel_params.
    DATA  ms_stats      TYPE /adz/hmv_idoc.

    DATA gc_taskmanager TYPE REF TO /adz/cl_hmv_tasks.
    DATA gc_idoc_status TYPE REF TO /adz/cl_hmv_select_idocst_task.
    METHODS:
      pre_sel_edidc
        CHANGING cs_sel_params TYPE /adz/hmv_s_idoc_sel_params.


ENDCLASS.

CLASS /adz/cl_hmv_select_idoc_status IMPLEMENTATION.
  METHOD constructor.
    ms_constants = is_constants.
  ENDMETHOD.

  METHOD pre_sel_edidc.
    IF cs_sel_params-so_datum IS NOT INITIAL.
      DATA(rng_msgt_tab) = /adz/cl_hmv_customizing=>get_message_type( is_so_datum = cs_sel_params-so_datum[ 1 ] ).
    ENDIF.

    SELECT b~dextaskid
          INTO TABLE @DATA(lt_seledidc)
          FROM edidc AS a
          INNER JOIN edextaskidoc AS b ON b~docnum = a~docnum
          INNER JOIN edextask AS c ON c~dextaskid = b~dextaskid
           WHERE a~upddat IN @cs_sel_params-so_datum
             AND a~mestyp IN @rng_msgt_tab
             AND c~dexservprovself IN @cs_sel_params-so_serv.

    SORT lt_seledidc by dextaskid.

    DELETE ADJACENT DUPLICATES FROM lt_seledidc COMPARING ALL FIELDS.
    cs_sel_params-so_taskid = VALUE #( BASE cs_sel_params-so_taskid
       FOR ls IN lt_seledidc (  sign = 'I' option = 'EQ' low = ls )
    ).
  ENDMETHOD.

  METHOD read_idoc_data.
    "----------------------------------------------------------------------------------------
    DATA lt_out             LIKE mt_out.
    DATA ls_task            TYPE /adz/cl_hmv_tasks=>ty_task.
    DATA lt_sel_taskid      TYPE /adz/hmv_rt_taskid.
    DATA lt_sel_taski_part  LIKE lt_sel_taskid.
    DATA  ls_stats          TYPE /adz/hmv_idoc.

    CLEAR mt_out.
    CLEAR ms_stats.
    ms_stats-datum = sy-datum.
    ms_stats-stati = sy-uzeit.


    ms_sel_params = is_sel_screen.
    IF ms_sel_params-so_taskid IS INITIAL.
      pre_sel_edidc( CHANGING cs_sel_params = ms_sel_params ).
    ENDIF.

    IF ms_sel_params-so_taskid IS NOT INITIAL.
      "REFRESH ms_sel_params-so_datum.  " loeschen der Datumparameter stoert die Selektion
    ENDIF.
    IF ms_sel_params-so_datum IS NOT INITIAL.
      DELETE ms_sel_params-so_datum FROM 2.
    ENDIF.


    " wird benoetigt am Ende der Tasks und am Reportende
    gc_idoc_status = NEW /adz/cl_hmv_select_idocst_task(
        is_const     = ms_constants
        is_selparams = ms_sel_params ).

    gc_taskmanager = NEW /adz/cl_hmv_tasks( iv_max_par_taks = ms_sel_params-p_maxpar ).

    lt_sel_taskid = ms_sel_params-so_taskid.
    SORT lt_sel_taskid BY low.
    DATA(lv_nr_selcond) = lines( lt_sel_taskid ).
*  IF lv_nr_selcond < 0.
*    " xxxx debug
*    lv_nr_selcond  = 50.
*    c_min_selcond_tasks = 1.
*    c_max_selcond_tasks = 2.
*  ENDIF.
    gc_taskmanager->create_tasks(
      EXPORTING
        iv_repid               = sy-repid
        iv_size_selector_array = lv_nr_selcond
        iv_min_selects         = ms_constants-c_min_selcond_tasks
        iv_max_selects         = ms_constants-c_max_selcond_tasks
    ).
    WHILE ( gc_taskmanager->get_next_task( IMPORTING es_task = ls_task ) EQ abap_true ).

      REFRESH lt_sel_taski_part.

      APPEND LINES OF lt_sel_taskid
        FROM ls_task-low
          TO ls_task-high
          TO lt_sel_taski_part.

      " xxxx debug
      "CHECK t_sel_taski_part IS NOT INITIAL.

      " Werte für HMV_IDOC_STATUS constructor
      ms_sel_params-so_taskid = lt_sel_taski_part.

      IF gc_taskmanager->mv_max_par_tasks > 1.
        " Parallel
        CALL FUNCTION '/ADZ/HMV_IDOC_STAT'
          STARTING NEW TASK ls_task-name
          DESTINATION IN GROUP DEFAULT
          CALLING ende_proc_task ON END OF TASK
          EXPORTING
            is_const      = ms_constants
            is_sel_params = ms_sel_params.
      ELSE.
        " Sequentiell
        REFRESH lt_out.
        CALL FUNCTION '/ADZ/HMV_IDOC_STAT'
          EXPORTING
            is_const         = ms_constants
            is_sel_params    = ms_sel_params
          IMPORTING
            es_stats         = ls_stats
          TABLES
            et_alv_grid_data = lt_out.
        gc_taskmanager->task_finished( ).

        APPEND LINES OF lt_out TO mt_out.
        gc_idoc_status->add_statistics(
          EXPORTING is_sta1 = ls_stats
          CHANGING  cs_sta2 = ms_stats ).
      ENDIF.

    ENDWHILE.

    gc_taskmanager->wait_for_all_tasks( ).

    " muehsam aufsummierten Statisksatz in DB ablegen
    gc_idoc_status->write_stats( CHANGING  cs_stats = ms_stats ).

  ENDMETHOD.

  METHOD get_statistics.
    rs_stats = ms_stats.
  ENDMETHOD.

  METHOD ende_proc_task.
    DATA  lt_out      TYPE /adz/hmv_t_memi_out.
    DATA  ls_stats    TYPE /adz/hmv_idoc.

    RECEIVE RESULTS FROM FUNCTION '/ADZ/HMV_IDOC_STAT'
      IMPORTING
         es_stats = ls_stats
      TABLES
         et_alv_grid_data  =  lt_out
      EXCEPTIONS
         communication_failure = 1
         system_failure        = 2.

    IF sy-subrc = 0.
      gc_taskmanager->task_finished( ).
      gc_taskmanager->lock( ).
      APPEND LINES OF lt_out TO mt_out.

      gc_idoc_status->add_statistics(
        EXPORTING is_sta1 = ls_stats
        CHANGING  cs_sta2 = ms_stats ).

      gc_taskmanager->release( ).
    ELSE.
      MESSAGE |Fehler bei ende_task { p_task }| TYPE 'X'.
      EXIT.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
