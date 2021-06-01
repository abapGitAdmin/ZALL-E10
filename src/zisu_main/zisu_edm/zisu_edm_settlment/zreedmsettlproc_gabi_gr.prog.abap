*&---------------------------------------------------------------------*
*& Report  /IDEXGG/REEDMSETTLPROC_GABI
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZREEDMSETTLPROC_GABI_GR.
parameter: settldoc  type e_edmsettldoc obligatory,
           settlrun  type e_edmsettldocrun obligatory.



data: process_ref    type ref to cl_isu_edm_settlprocess,
      settlunits     type t_settlunit,
      settlunit type  e_edmsettlunit,
      impvalues type  t_settlsteppar_contvalue,
      impprofiles type  t_settlsteppar_contprofile,
      expvalues type  t_settlsteppar_contvalue,
      expprofiles type  t_settlsteppar_contprofile,
      settlsteplevel type e_settlsteplevel,
      temp_settlsteplevel type e_settlsteplevel,
      critical_error type kennzx.

constants: co_selected type kennzx value 'X'.
class cl_isu_edm_settlement definition load.

define exit_error.
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
  exit.
end-of-definition.

define exit_error_repeat_msg.
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
  exit.
end-of-definition.

start-of-selection.
*******************************************
* set initial status
  call method cl_isu_edm_settlement=>cl_set_run_status
    exporting x_status =
cl_isu_edm_settlement=>co_settlrunstatus_started
              x_settldoc = settldoc
              x_settldocrun = settlrun
    exceptions others = 1.
  if sy-subrc <> 0.
    message id sy-msgid type 'S' number sy-msgno
             with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    exit.
  endif.

  create object process_ref
     exporting x_settldoc = settldoc
     exceptions others = 1.
  if sy-subrc <> 0.
    exit_error_repeat_msg.
  endif.


*******************************************
* create new run instance
  call method process_ref->create_settldocrun
    exporting x_settldoc = settldoc
              x_settldocrun = settlrun
    importing yt_settlunit = settlunits
    exceptions others = 1.
  if sy-subrc <> 0.
    exit_error_repeat_msg.
  endif.


*******************************************
* assign PoD to settlementunits
  call method process_ref->start_step
    exporting x_settlstep         = 'ASSIGNPOD3'
              xt_settlunits       = settlunits
    changing  xy_settlsteplevel   = settlsteplevel
    exceptions others             = 1.
  if sy-subrc <> 0.
* set status of settlement run, repeat last message and quitt processing
    exit_error_repeat_msg.
  endif.

*******************************************
* check consistency of parameters
  call method process_ref->start_step
    exporting x_settlstep         = 'CHECKPARAM'
              xt_settlunits       = settlunits
    changing  xy_settlsteplevel   = settlsteplevel
    exceptions others             = 0.


  loop at settlunits into settlunit.
********************************************
    temp_settlsteplevel = settlsteplevel.
    call method process_ref->start_step
       exporting x_settlstep         = 'SUMINTSU01'
                 x_settlunit         = settlunit
       importing yt_expprofiles      = expprofiles
       changing  xy_settlsteplevel   = temp_settlsteplevel
       exceptions others             = 1.
    if sy-subrc <> 0.
      critical_error = co_selected.
      exit.
    endif.
    append lines of expprofiles to impprofiles.
*******************************************
* calculate average load profile of all interval metered customers of one
* settlement unit
    call method process_ref->start_step
       exporting x_settlstep         = 'SUMINTGABI'
                 x_settlunit         = settlunit
       importing yt_expprofiles      = expprofiles
       changing  xy_settlsteplevel   = temp_settlsteplevel
       exceptions others             = 1.
    if sy-subrc <> 0.
      critical_error = co_selected.
      exit.
    endif.
    append lines of expprofiles to impprofiles.
*******************************************
* calculate average load profile of all residential customers of one
* settlement unit
    call method process_ref->start_step
      exporting x_settlstep         = 'SUMRESGABI'
                x_settlunit         = settlunit
      importing yt_expprofiles      = expprofiles
      changing  xy_settlsteplevel   = temp_settlsteplevel
      exceptions others             = 1.
    if sy-subrc <> 0.
      critical_error = co_selected.
      exit.
    endif.
    append lines of expprofiles to impprofiles.
*******************************************
* calculate load profile of all customers of one settlement unit
* and add loss profile
    call method process_ref->start_step
      exporting x_settlstep         = 'SUMSUGABI'
                xt_impprofiles      = impprofiles
                x_settlunit         = settlunit
      importing yt_expprofiles      = expprofiles
      changing  xy_settlsteplevel   = temp_settlsteplevel
      exceptions others             = 1.
    if sy-subrc <> 0.
      critical_error = co_selected.
      exit.
    endif.
    append lines of expprofiles to impprofiles.
  endloop.
  settlsteplevel = temp_settlsteplevel.

  if critical_error = co_selected.
* set status of settlement run and quitt processing
    exit_error.
  endif.

********************************************
** calculate load profile of all customers per grid
** and add loss profile
*  call method process_ref->start_step
*    exporting x_settlstep         = 'SUMGRID'
*              xt_impprofiles      = impprofiles
*              xt_settlunits       = settlunits
*    importing yt_expprofiles      = expprofiles
*    changing  xy_settlsteplevel   = settlsteplevel
*    exceptions others             = 1.
*  if sy-subrc <> 0.
*    critical_error = co_selected.
*    exit.
*  endif.
*  append lines of expprofiles to impprofiles.

*******************************************
* calculate load profile of all customers of top settlement unit
* inclusive subunits
  call method process_ref->start_step
    exporting x_settlstep         = 'SUMSUALL'
              xt_impprofiles      = impprofiles
              xt_settlunits       = settlunits
    importing yt_expprofiles      = expprofiles
    changing  xy_settlsteplevel   = settlsteplevel
    exceptions others             = 1.
  if sy-subrc <> 0.
* set status of settlement run and quitt processing
    exit_error_repeat_msg.
  endif.
  append lines of expprofiles to impprofiles.

********************************************
** calculate load profile of all customers of suprior grids
** inclusive subgrids
*  call method process_ref->start_step
*    exporting x_settlstep         = 'SUMGRIDALL'
*              xt_impprofiles      = impprofiles
*              xt_settlunits       = settlunits
*    importing yt_expprofiles      = expprofiles
*    changing  xy_settlsteplevel   = settlsteplevel
*    exceptions others             = 1.
*  if sy-subrc <> 0.
** set status of settlement run and quitt processing
*    exit_error_repeat_msg.
*  endif.
*  append lines of expprofiles to impprofiles.


*******************************************
  if process_ref->run_information-settldocmode =
        cl_isu_edm_settlement=>co_settldocmode_activ.
* send results to service providers of settlement units and
* service providers of grids
    call method process_ref->start_step
      exporting x_settlstep         = 'SENDSUGRPR'
                xt_impprofiles      = impprofiles
                xt_settlunits       = settlunits
      changing  xy_settlsteplevel   = settlsteplevel
      exceptions others             = 1.
    if sy-subrc <> 0.
* set status of settlement run and quitt processing
      exit_error_repeat_msg.
    endif.
  endif.

*******************************************
* set final status of settlement run
  call method cl_isu_edm_settlement=>cl_set_run_status
    exporting x_status =
cl_isu_edm_settlement=>co_settlrunstatus_ok
              x_settldoc = settldoc
              x_settldocrun = settlrun
    exceptions
      others           = 1.
  if sy-subrc <> 0.
    message id sy-msgid type 'S' number sy-msgno
             with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    exit.
  endif.

  message s423(eedmset) with space.
