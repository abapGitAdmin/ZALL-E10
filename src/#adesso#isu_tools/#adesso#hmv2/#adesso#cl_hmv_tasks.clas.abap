CLASS /adesso/cl_hmv_tasks DEFINITION
  PUBLIC
  FINAL
.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_task,
             name(40) TYPE c,
             count(4) TYPE n,
             low      TYPE sy-tabix,
             high     TYPE sy-tabix,
           END OF ty_task.

    " Zugriff von außen nur lesend
    DATA  mt_tasks TYPE STANDARD TABLE OF ty_task.
    DATA  mv_max_par_tasks TYPE i READ-ONLY.


    METHODS :
      constructor IMPORTING iv_max_par_taks TYPE i,

      create_tasks
        IMPORTING
          iv_repid               TYPE sy-repid
          iv_size_selector_array TYPE syst_tabix
          iv_min_selects         TYPE syst_tabix
          iv_max_selects         TYPE syst_tabix,

      task_finished,
      wait_for_all_tasks,

      get_next_task
        EXPORTING es_task             TYPE ty_task
        RETURNING VALUE(rv_not_empty) TYPE abap_bool.

  PROTECTED SECTION.
    DATA mv_last_task_nr  TYPE i.
    DATA mv_nr_running_tasks TYPE i.

  PRIVATE SECTION.
ENDCLASS.



CLASS /adesso/cl_hmv_tasks IMPLEMENTATION.
  METHOD constructor.
    mv_nr_running_tasks = 0.
    mv_max_par_tasks = nmax( val1 = iv_max_par_taks val2 = 1 ).
  ENDMETHOD.

  METHOD get_next_task.
    " naechste verfuegbare Tasks bereitstellen
    WAIT UNTIL  mv_nr_running_tasks < mv_max_par_tasks.

    rv_not_empty = xsdbool( mv_last_task_nr < lines( mt_tasks ) ).
    IF rv_not_empty EQ  abap_true.
      mv_last_task_nr = mv_last_task_nr +  1.
      es_task = mt_tasks[ mv_last_task_nr ].
      mv_nr_running_tasks  = mv_nr_running_tasks + 1.
    ENDIF.
  ENDMETHOD.

  METHOD task_finished.
    mv_nr_running_tasks = nmax( val1 = 0  val2 = ( mv_nr_running_tasks - 1 ) ).
  ENDMETHOD.

  METHOD wait_for_all_tasks.
    WAIT UNTIL  mv_nr_running_tasks = 0.
  ENDMETHOD.

  METHOD create_tasks.
    " Anzahl der zugelassen Selektionsbedingungen pro Task
    DATA  lv_nr_selects TYPE syst_tabix.
    DATA  lv_used_selects TYPE syst_tabix VALUE 0.
    DATA  ls_task  TYPE  ty_task.
    DATA  lv_size_selector_array LIKE iv_size_selector_array.

    CLEAR : mt_tasks, mv_last_task_nr, mv_nr_running_tasks.
    lv_size_selector_array = nmax( val1 = iv_size_selector_array  val2 = 0 ).

    " 0 ist schlecht, da sonst Fehler bei Zugriff auf mt_tasks
    CHECK lv_size_selector_array > 0.

    IF lv_size_selector_array < iv_min_selects.
      lv_nr_selects = lv_size_selector_array.
    ELSE.
      lv_nr_selects = lv_size_selector_array / mv_max_par_tasks.
      IF lv_nr_selects > iv_max_selects.
        lv_nr_selects = iv_max_selects.
      ENDIF.
    ENDIF.

    DO.
      IF ( ( lv_used_selects + lv_nr_selects ) >  lv_size_selector_array ).
        " Letzte Task hat weniger selects
        lv_nr_selects = lv_size_selector_array - lv_used_selects.
      ENDIF.
      ls_task-count = ls_task-count + 1.
      ls_task-low   = ls_task-high + 1.
      ls_task-high  = ls_task-low  + lv_nr_selects - 1.
      CONCATENATE iv_repid ls_task-count INTO ls_task-name SEPARATED BY space.
      APPEND ls_task TO mt_tasks.
      lv_used_selects = lv_used_selects + lv_nr_selects.
      IF lv_used_selects >= lv_size_selector_array.
        EXIT.
      ENDIF.
    ENDDO.

  ENDMETHOD.


ENDCLASS.
