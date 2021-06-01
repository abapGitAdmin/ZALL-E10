*&---------------------------------------------------------------------*
*& Report  REEDMSETTLPROC_VV2_SYNTH_GRP                                *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

REPORT  zreedmsettlproc_vv2_synth_grp      .

PARAMETER: settldoc  TYPE e_edmsettldoc OBLIGATORY,
           settlrun  TYPE e_edmsettldocrun OBLIGATORY,
           steplev   TYPE e_settlsteplevel,
           subcalc   TYPE kennzx. " runs as subcalculation



DATA: process_ref    TYPE REF TO cl_isu_edm_settlprocess,
      settlunits     TYPE t_settlunit,
      settlunit	TYPE	e_edmsettlunit,
      impvalues	TYPE	t_settlsteppar_contvalue,
      impprofiles	TYPE	t_settlsteppar_contprofile,
      expvalues	TYPE	t_settlsteppar_contvalue,
      expprofiles	TYPE	t_settlsteppar_contprofile,
      settlsteplevel TYPE e_settlsteplevel,
      temp_settlsteplevel TYPE e_settlsteplevel,
      critical_error TYPE kennzx.

CONSTANTS: co_selected TYPE kennzx VALUE 'X',
           co_settlparameter(7) TYPE c VALUE 'EEDMSET'.
CLASS cl_isu_edm_settlement DEFINITION LOAD.

DEFINE exit_error.
  message s415(eedmset) with space space.
  call method cl_isu_edm_settlement=>cl_set_run_status
    exporting x_status =
cl_isu_edm_settlement=>co_settlrunstatus_error
              x_settldoc = settldoc
              x_settldocrun = settlrun
     exceptions others = 1.
  if sy-subrc <> 0.
    message id sy-msgid type 'S' number sy-msgno
             with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.
  export settlsteplevel impprofiles impvalues
       to memory id co_settlparameter.
  exit.
END-OF-DEFINITION.

DEFINE exit_error_repeat_msg.
  if not sy-msgid is initial and
     not sy-msgno is initial.
    message id sy-msgid type 'S' number sy-msgno
             with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  else.
    message s415(eedmset) with space space.
  endif.
  call method cl_isu_edm_settlement=>cl_set_run_status
    exporting x_status =
cl_isu_edm_settlement=>co_settlrunstatus_error
              x_settldoc = settldoc
              x_settldocrun = settlrun
     exceptions others = 1.
  if sy-subrc <> 0.
    message id sy-msgid type 'S' number sy-msgno
             with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.
  export settlsteplevel impprofiles impvalues
       to memory id co_settlparameter.
  exit.
END-OF-DEFINITION.

START-OF-SELECTION.
  IF subcalc IS INITIAL.
*******************************************
* set initial status
    CALL METHOD cl_isu_edm_settlement=>cl_set_run_status
      EXPORTING x_status =
  cl_isu_edm_settlement=>co_settlrunstatus_started
                x_settldoc = settldoc
                x_settldocrun = settlrun
      EXCEPTIONS OTHERS = 1.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      EXIT.
    ENDIF.
  ENDIF.


  CREATE OBJECT process_ref
     EXPORTING x_settldoc = settldoc
     EXCEPTIONS others = 1.
  IF sy-subrc <> 0.
    exit_error_repeat_msg.
  ENDIF.

*******************************************
* create new run instance
  CALL METHOD process_ref->create_settldocrun
    EXPORTING x_settldoc = settldoc
              x_settldocrun = settlrun
    IMPORTING yt_settlunit = settlunits
    EXCEPTIONS OTHERS = 1.
  IF sy-subrc <> 0.
    exit_error_repeat_msg.
  ENDIF.


  settlsteplevel = steplev.
*******************************************
* assign PoD to settlementunits
  CALL METHOD process_ref->start_step
    EXPORTING x_settlstep         = 'ASSIGNPOD'
              xt_settlunits       = settlunits
    CHANGING  xy_settlsteplevel   = settlsteplevel
    EXCEPTIONS OTHERS             = 1.
  IF sy-subrc <> 0.
* set status of settlement run, repeat last message and quitt processing
    exit_error_repeat_msg.
  ENDIF.

*******************************************
* check consistency of parameters
  CALL METHOD process_ref->start_step
    EXPORTING x_settlstep         = 'CHECKPARAM'
              xt_settlunits       = settlunits
    CHANGING  xy_settlsteplevel   = settlsteplevel
    EXCEPTIONS OTHERS             = 0.


  LOOP AT settlunits INTO settlunit.
*******************************************
* calculate load profile of all interval metered customers of one
* settlement unit
    temp_settlsteplevel = settlsteplevel.
    CALL METHOD process_ref->start_step
      EXPORTING x_settlstep         = 'SUMINTSU'
                x_settlunit         = settlunit
      IMPORTING yt_expprofiles      = expprofiles
      CHANGING  xy_settlsteplevel   = temp_settlsteplevel
      EXCEPTIONS OTHERS             = 1.
    IF sy-subrc <> 0.
      critical_error = co_selected.
      EXIT.
    ENDIF.
    APPEND LINES OF expprofiles TO impprofiles.
*******************************************
* calculate load profile of all residential customers of one
* settlement unit
    CALL METHOD process_ref->start_step
      EXPORTING x_settlstep         = 'SUMRES08SU'
                x_settlunit         = settlunit
      IMPORTING yt_expprofiles      = expprofiles
      CHANGING  xy_settlsteplevel   = temp_settlsteplevel
      EXCEPTIONS OTHERS             = 1.
    IF sy-subrc <> 0.
      critical_error = co_selected.
      EXIT.
    ENDIF.
    APPEND LINES OF expprofiles TO impprofiles.
*******************************************
* calculate load profile of all customers of one settlement unit
* and add loss profile
    CALL METHOD process_ref->start_step
      EXPORTING x_settlstep         = 'SUMSU'
                xt_impprofiles      = impprofiles
                x_settlunit         = settlunit
      IMPORTING yt_expprofiles      = expprofiles
      CHANGING  xy_settlsteplevel   = temp_settlsteplevel
      EXCEPTIONS OTHERS             = 1.
    IF sy-subrc <> 0.
      critical_error = co_selected.
      EXIT.
    ENDIF.
    APPEND LINES OF expprofiles TO impprofiles.
  ENDLOOP.
  settlsteplevel = temp_settlsteplevel.

  IF critical_error = co_selected.
* set status of settlement run and quitt processing
    exit_error.
  ENDIF.


*******************************************
* calculate load profile of all customers of top settlement unit
* inclusive subunits
  CALL METHOD process_ref->start_step
    EXPORTING x_settlstep         = 'SUMSUALL'
              xt_impprofiles      = impprofiles
              xt_settlunits       = settlunits
    IMPORTING yt_expprofiles      = expprofiles
    CHANGING  xy_settlsteplevel   = settlsteplevel
    EXCEPTIONS OTHERS             = 1.
  IF sy-subrc <> 0.
* set status of settlement run and quitt processing
    exit_error_repeat_msg.
  ENDIF.
  APPEND LINES OF expprofiles TO impprofiles.


  IF subcalc IS INITIAL.
*******************************************
    IF process_ref->run_information-settldocmode =
          cl_isu_edm_settlement=>co_settldocmode_activ.
* send results to service providers of settlementunits
      CALL METHOD process_ref->start_step
        EXPORTING x_settlstep         = 'SENDSUPR'
                  xt_impprofiles      = impprofiles
                  xt_settlunits       = settlunits
        CHANGING  xy_settlsteplevel   = settlsteplevel
        EXCEPTIONS OTHERS             = 1.
      IF sy-subrc <> 0.
* set status of settlement run and quitt processing
        exit_error_repeat_msg.
      ENDIF.
    ENDIF.

*******************************************
* set final status of settlement run
    CALL METHOD cl_isu_edm_settlement=>cl_set_run_status
      EXPORTING x_status =
  cl_isu_edm_settlement=>co_settlrunstatus_ok
                x_settldoc = settldoc
                x_settldocrun = settlrun
      EXCEPTIONS
        OTHERS           = 1
            .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      EXIT.
    ENDIF.

    MESSAGE s423(eedmset) with space.
  ELSE.
* export calculated results (profiles and values) to memory
    EXPORT settlsteplevel impprofiles impvalues
       TO MEMORY ID co_settlparameter.
  ENDIF.
