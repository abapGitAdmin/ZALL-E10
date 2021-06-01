*&---------------------------------------------------------------------*
*&  Include           /ADESSO/MT_MIGTOOL_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  ladereport_dialog
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ladereport_dialog.


  SUBMIT  /adesso/mt_bel_loadwb
      WITH  firma             = firma
      WITH  exp_ext           = exp_ext
      WITH  exp_path          = exp_path
      WITH  imp_ext           = imp_ext
      WITH  imp_path          = imp_path
      WITH  dat_420           = fn_420
      WITH  dat_acc           = fn_acc
      WITH  dat_acs           = fn_acs
      WITH  dat_acn           = fn_acn
      WITH  dat_bcn           = fn_bcn
      WITH  dat_bct           = fn_bct
      WITH  dat_bpm           = fn_bpm
      WITH  dat_con           = fn_con
      WITH  dat_dev           = fn_dev
      WITH  dat_dir           = fn_dir
      WITH  dat_dlc           = fn_dlc
      WITH  dat_doc           = fn_doc
      WITH  dat_fac           = fn_fac
      WITH  dat_ich           = fn_ich
      WITH  dat_inn           = fn_inn
      WITH  dat_icn           = fn_icn
      WITH  dat_inm           = fn_inm
      WITH  dat_ins           = fn_ins
      WITH  dat_ipl           = fn_ipl
      WITH  dat_lot           = fn_lot
      WITH  dat_moi           = fn_moi
      WITH  dat_moh           = fn_moh
      WITH  dat_moo           = fn_moo
      WITH  dat_mrd           = fn_mrd
      WITH  dat_mru           = fn_mru
      WITH  dat_noc           = fn_noc
      WITH  dat_nod           = fn_nod
      WITH  dat_par           = fn_par
      WITH  dat_pay           = fn_pay
      WITH  dat_pno           = fn_pno
      WITH  dat_poc           = fn_poc
      WITH  dat_pod           = fn_pod
      WITH  dat_pos           = fn_pos
      WITH  dat_pre           = fn_pre
      WITH  dat_rva           = fn_rva
      WITH  dat_srt           = fn_srt
      WITH  dat_cno           = fn_cno
      WITH  dat_drt           = fn_drt
      WITH  dat_pad           = fn_pad
      WITH  dat_lop           = fn_lop
      WITH  dat_dno           = fn_dno
      WITH  dat_dcd           = fn_dcd
      WITH  dat_dco           = fn_dco
      WITH  dat_dce           = fn_dce
      WITH  dat_dcr           = fn_dcr
      WITH  dat_dcm           = fn_dcm
      WITH  dat_dgr           = fn_dgr
      WITH  obj_420           = cb_420
      WITH  obj_acc           = cb_acc
      WITH  obj_acs           = cb_acs
      WITH  obj_acn           = cb_acn
      WITH  obj_bcn           = cb_bcn
      WITH  obj_bct           = cb_bct
      WITH  obj_bpm           = cb_bpm
      WITH  obj_con           = cb_con
      WITH  obj_dev           = cb_dev
      WITH  obj_dir           = cb_dir
      WITH  obj_dlc           = cb_dlc
      WITH  obj_doc           = cb_doc
      WITH  obj_fac           = cb_fac
      WITH  obj_ich           = cb_ich
      WITH  obj_inm           = cb_inm
      WITH  obj_ins           = cb_ins
      WITH  obj_inn           = cb_inn
      WITH  obj_icn           = cb_icn
      WITH  obj_ipl           = cb_ipl
      WITH  obj_lot           = cb_lot
      WITH  obj_moi           = cb_moi
      WITH  obj_moh           = cb_moh
      WITH  obj_moo           = cb_moo
      WITH  obj_mrd           = cb_mrd
      WITH  obj_mru           = cb_mru
      WITH  obj_noc           = cb_noc
      WITH  obj_nod           = cb_nod
      WITH  obj_par           = cb_par
      WITH  obj_pay           = cb_pay
      WITH  obj_pno           = cb_pno
      WITH  obj_poc           = cb_poc
      WITH  obj_pod           = cb_pod
      WITH  obj_pos           = cb_pos
      WITH  obj_pre           = cb_pre
      WITH  obj_rva           = cb_rva
      WITH  obj_srt           = cb_srt
      WITH  obj_cno           = cb_cno
      WITH  obj_drt           = cb_drt
      WITH  obj_pad           = cb_pad
      WITH  obj_lop           = cb_lop
      WITH  obj_dno           = cb_dno
      WITH  obj_dcd           = cb_dcd
      WITH  obj_dco           = cb_dco
      WITH  obj_dce           = cb_dce
      WITH  obj_dcr           = cb_dcr
      WITH  obj_dcm           = cb_dcm
      WITH  obj_dgr           = cb_dgr
      WITH  obj_reg           = cb_reg
      AND RETURN
      VIA SELECTION-SCREEN.





ENDFORM.                    " ladereport_dialog
*&---------------------------------------------------------------------*
*&      Form  erm_jobname
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM erm_jobname  CHANGING p_jobname.

  DATA: fname LIKE temfd-file.

  IF      cb_par      EQ   'X'.
    MOVE fn_par TO fname.
  ELSEIF  cb_pno      EQ   'X'.
    MOVE fn_pno TO fname.
  ELSEIF  cb_420      EQ   'X'.
    MOVE fn_420 TO fname.
  ELSEIF  cb_mru      EQ   'X'.
    MOVE fn_mru TO fname.
  ELSEIF  cb_con      EQ   'X'.
    MOVE fn_con TO fname.
  ELSEIF  cb_noc      EQ   'X'.
    MOVE fn_noc TO fname.
  ELSEIF  cb_pre      EQ   'X'.
    MOVE fn_pre TO fname.
  ELSEIF  cb_dlc      EQ   'X'.
    MOVE fn_dlc TO fname.
  ELSEIF  cb_nod      EQ   'X'.
    MOVE fn_nod TO fname.
  ELSEIF  cb_dev      EQ   'X'.
    MOVE fn_dev TO fname.
  ELSEIF  cb_dir      EQ   'X'.
    MOVE fn_dir TO fname.
  ELSEIF  cb_ins      EQ   'X'.
    MOVE fn_ins TO fname.
  ELSEIF  cb_ich      EQ   'X'.
    MOVE fn_ich TO fname.
  ELSEIF  cb_fac      EQ   'X'.
    MOVE fn_fac TO fname.
  ELSEIF  cb_rva      EQ   'X'.
    MOVE fn_rva TO fname.
  ELSEIF  cb_acc      EQ   'X'.
    MOVE fn_acc TO fname.
  ELSEIF  cb_acs      EQ   'X'.
    MOVE fn_acs TO fname.
  ELSEIF  cb_acn      EQ   'X'.
    MOVE fn_acn TO fname.
  ELSEIF  cb_moi      EQ   'X'.
    MOVE fn_moi TO fname.
  ELSEIF  cb_moh      EQ   'X'.
    MOVE fn_moh TO fname.
  ELSEIF  cb_moo      EQ   'X'.
    MOVE fn_moo TO fname.
  ELSEIF  cb_bct      EQ   'X'.
    MOVE fn_bct TO fname.
  ELSEIF  cb_bcn      EQ   'X'.
    MOVE fn_bcn TO fname.
  ELSEIF  cb_bpm      EQ   'X'.
    MOVE fn_bpm TO fname.
  ELSEIF  cb_pay      EQ   'X'.
    MOVE fn_pay TO fname.
  ELSEIF  cb_doc      EQ   'X'.
    MOVE fn_doc TO fname.
  ELSEIF  cb_ipl      EQ   'X'.
    MOVE fn_ipl TO fname.
  ELSEIF  cb_inm      EQ   'X'.
    MOVE fn_inm TO fname.
  ELSEIF  cb_mrd      EQ   'X'.
    MOVE fn_mrd TO fname.
  ELSEIF  cb_pod      EQ   'X'.
    MOVE fn_pod TO fname.
  ELSEIF  cb_poc      EQ   'X'.
    MOVE fn_poc TO fname.
  ELSEIF  cb_pos      EQ   'X'.
    MOVE fn_pos TO fname.
  ELSEIF  cb_lot      EQ   'X'.
    MOVE fn_lot TO fname.
  ELSEIF  cb_cno      EQ   'X'.
    MOVE fn_cno TO fname.
  ELSEIF  cb_drt      EQ   'X'.
    MOVE fn_drt TO fname.
  ELSEIF  cb_pad      EQ   'X'.
    MOVE fn_pad TO fname.
  ELSEIF  cb_lop      EQ   'X'.
    MOVE fn_lop TO fname.
  ELSEIF  cb_dno      EQ   'X'.
    MOVE fn_dno TO fname.
  ELSEIF  cb_dcd      EQ   'X'.
    MOVE fn_dcd TO fname.
  ELSEIF  cb_dco      EQ   'X'.
    MOVE fn_dco TO fname.
  ELSEIF  cb_dce      EQ   'X'.
    MOVE fn_dce TO fname.
  ELSEIF  cb_dcr      EQ   'X'.
    MOVE fn_dcr TO fname.
  ELSEIF  cb_dcm      EQ   'X'.
    MOVE fn_dcm TO fname.
  ELSEIF  cb_dgr      EQ   'X'.
    MOVE fn_dgr TO fname.
  ELSEIF  cb_srt      EQ   'X'.
    MOVE fn_srt TO fname.
  ELSEIF  cb_reg      EQ   'X'.
    MOVE fn_reg TO fname.
  ELSEIF cb_inn     EQ 'X'.
    MOVE fn_inn  TO fname.
  ELSEIF cb_icn     EQ 'X'.
    MOVE fn_icn TO fname.
  ENDIF.

CONCATENATE 'MIGOBJ_' fname INTO p_jobname.
TRANSLATE p_jobname TO UPPER CASE.


ENDFORM.                    " erm_jobname
*&---------------------------------------------------------------------*
*&      Form  job_call_migobject
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_JOB_NAME  text
*----------------------------------------------------------------------*
FORM job_call_migobject USING migobject.

  PERFORM job_start_migobject  USING  migobject
                            CHANGING  gestartet.

  IF gestartet IS INITIAL.
    MESSAGE  i001(/adesso/mt_n) WITH 'Job wurde NICHT gestartet'.
  ELSE.
    MESSAGE  i001(/adesso/mt_n) WITH 'Job wurde gestartet'.
  ENDIF.


ENDFORM.                    " job_call_migobject
*&---------------------------------------------------------------------*
*&      Form  job_start_migobject
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_MIGOBJECT  text
*      <--P_GESTARTET  text
*----------------------------------------------------------------------*
FORM job_start_migobject     USING jobname
                         CHANGING  gestartet.

  DATA: user_print_params     LIKE  pri_params,
        user_arc_params       LIKE  arc_params,
        val.


*  >> Print-Parameter für aktuellen User ermitteln
  PERFORM  fget_print_parameters  CHANGING  user_arc_params
                                            user_print_params
                                            val.
*  << Print-Parameter für aktuellen User ermitteln


* Listenbreite auf 132 festsetzen. Versuche die Eistellung über
* die User-Parameter zu beeinflussen blieben erfolgslos.
* Später könnte man es sicher elegenter lösen
  user_print_params-linsz = 132.
  user_print_params-paart = 'X_65_132'.

* s. auch Form ,Job_Start_ExpObject'


*  >> Job öffnen
  PERFORM  fjob_open              USING     jobname
                                  CHANGING  jobnumber.
*  << Job öffnen

*  >> Report dem Job-Step hinzufügen
*   - Report
  SUBMIT  /adesso/mt_bel_loadwb
      WITH  firma             = firma
      WITH  exp_ext           = exp_ext
      WITH  exp_path          = exp_path
      WITH  imp_ext           = imp_ext
      WITH  imp_path          = imp_path
      WITH  dat_420           = fn_420
      WITH  dat_acc           = fn_acc
      WITH  dat_acs           = fn_acs
      WITH  dat_acn           = fn_acn
      WITH  dat_bcn           = fn_bcn
      WITH  dat_bct           = fn_bct
      WITH  dat_bpm           = fn_bpm
      WITH  dat_con           = fn_con
      WITH  dat_dev           = fn_dev
      WITH  dat_dir           = fn_dir
      WITH  dat_dlc           = fn_dlc
      WITH  dat_doc           = fn_doc
      WITH  dat_fac           = fn_fac
      WITH  dat_ich           = fn_ich
      WITH  dat_inm           = fn_inm
      WITH  dat_ins           = fn_ins
      WITH  dat_ipl           = fn_ipl
      WITH  dat_lot           = fn_lot
      WITH  dat_moi           = fn_moi
      WITH  dat_mrd           = fn_mrd
      WITH  dat_mru           = fn_mru
      WITH  dat_noc           = fn_noc
      WITH  dat_nod           = fn_nod
      WITH  dat_par           = fn_par
      WITH  dat_pay           = fn_pay
      WITH  dat_pno           = fn_pno
      WITH  dat_poc           = fn_poc
      WITH  dat_pod           = fn_pod
      WITH  dat_pos           = fn_pos
      WITH  dat_pre           = fn_pre
      WITH  dat_rva           = fn_rva
      WITH  dat_srt           = fn_srt
      WITH  dat_cno           = fn_cno
      WITH  dat_drt           = fn_drt
      WITH  dat_pad           = fn_pad
      WITH  dat_lop           = fn_lop
      WITH  dat_dno           = fn_dno
      WITH  dat_dcd           = fn_dcd
      WITH  dat_dco           = fn_dco
      WITH  dat_dce           = fn_dce
      WITH  dat_dcr           = fn_dcr
      WITH  dat_dcm           = fn_dcm
      WITH  dat_dgr           = fn_dgr
      WITH  obj_420           = cb_420
      WITH  obj_acc           = cb_acc
      WITH  obj_acs           = cb_acs
      WITH  obj_acn           = cb_acn
      WITH  obj_bcn           = cb_bcn
      WITH  obj_bct           = cb_bct
      WITH  obj_bpm           = cb_bpm
      WITH  obj_con           = cb_con
      WITH  obj_dev           = cb_dev
      WITH  obj_dir           = cb_dir
      WITH  obj_dlc           = cb_dlc
      WITH  obj_doc           = cb_doc
      WITH  obj_fac           = cb_fac
      WITH  obj_ich           = cb_ich
      WITH  obj_inm           = cb_inm
      WITH  obj_ins           = cb_ins
      WITH  obj_ipl           = cb_ipl
      WITH  obj_lot           = cb_lot
      WITH  obj_moi           = cb_moi
      WITH  obj_mrd           = cb_mrd
      WITH  obj_mru           = cb_mru
      WITH  obj_noc           = cb_noc
      WITH  obj_nod           = cb_nod
      WITH  obj_par           = cb_par
      WITH  obj_pay           = cb_pay
      WITH  obj_pno           = cb_pno
      WITH  obj_poc           = cb_poc
      WITH  obj_pod           = cb_pod
      WITH  obj_pos           = cb_pos
      WITH  obj_pre           = cb_pre
      WITH  obj_rva           = cb_rva
      WITH  obj_srt           = cb_srt
      WITH  obj_cno           = cb_cno
      WITH  obj_drt           = cb_drt
      WITH  obj_pad           = cb_pad
      WITH  obj_lop           = cb_lop
      WITH  obj_dno           = cb_dno
      WITH  obj_dcd           = cb_dcd
      WITH  obj_dco           = cb_dco
      WITH  obj_dce           = cb_dce
      WITH  obj_dcr           = cb_dcr
      WITH  obj_dcm           = cb_dcm
      WITH  obj_dgr           = cb_dgr
      WITH  obj_reg           = cb_reg   "19032008_kb
*!  < Parameterübergabe
      AND RETURN
      USER                  sy-uname
      VIA JOB               jobname
      NUMBER                jobnumber
      TO SAP-SPOOL
      SPOOL PARAMETERS      user_print_params
      ARCHIVE PARAMETERS    user_arc_params
      WITHOUT SPOOL DYNPRO.
*  << Report dem Job-Step hinzufügen

*  >> Job schließen und starten
  PERFORM  fjob_close                  USING     jobnumber
                                                 jobname
                                                 space
                                                 space
                                                 'X'
                                                 space
                                                 space
                                                 targetserver
                                       CHANGING  gestartet.
*  << Job schließen und starten






ENDFORM.                    " job_start_migobject
*&---------------------------------------------------------------------*
*&      Form  fget_print_parameters
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_USER_ARC_PARAMS  text
*      <--P_USER_PRINT_PARAMS  text
*      <--P_VAL  text
*----------------------------------------------------------------------*
FORM fget_print_parameters   CHANGING  user_arc_params
                                       user_print_params
                                       val.

  CALL FUNCTION 'GET_PRINT_PARAMETERS'
       EXPORTING
            mode                   = 'CURRENT'
            no_dialog              = 'X'
       IMPORTING
            out_archive_parameters = user_arc_params
            out_parameters         = user_print_params
            valid                  = val
       EXCEPTIONS
            archive_info_not_found = 1
            invalid_print_params   = 2
            invalid_archive_params = 3
            OTHERS                 = 4.
  IF sy-subrc <> 0.
   MESSAGE  i001(/adesso/mt_n) WITH 'GET_PRINT_PARAMETER fehlgeschlagen'.
  ENDIF.


ENDFORM.                    " fget_print_parameters
*&---------------------------------------------------------------------*
*&      Form  fjob_open
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_JOBNAME  text
*      <--P_JOBNUMBER  text
*----------------------------------------------------------------------*
FORM fjob_open                 USING     jobname
                               CHANGING  jobnumber.

  CALL FUNCTION 'JOB_OPEN'
       EXPORTING
            jobname          = jobname
       IMPORTING
            jobcount         = jobnumber
       EXCEPTIONS
            cant_create_job  = 1
            invalid_job_data = 2
            jobname_missing  = 3
            OTHERS           = 4.
  IF sy-subrc <> 0.
    MESSAGE  i001(/adesso/mt_n) WITH 'Job kann nicht geöffnet werden'.
  ENDIF.


ENDFORM.                    " fjob_open
*&---------------------------------------------------------------------*
*&      Form  fjob_close
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_JOBNUMBER  text
*      -->P_JOBNAME  text
*      -->P_SPACE  text
*      -->P_SPACE  text
*      -->P_0873   text
*      -->P_SPACE  text
*      -->P_SPACE  text
*      -->P_TARGETSERVER  text
*      <--P_GESTARTET  text
*----------------------------------------------------------------------*
FORM fjob_close                       USING     jobnumber
                                                 jobname
                                                 pred_jobname
                                                 pred_jobcount
                                                 strtimmed
                                                 event_id
                                                 event_parm
                                                 targetserver
                                       CHANGING  gestartet.

  CALL FUNCTION 'JOB_CLOSE'
       EXPORTING
            jobcount             = jobnumber
            jobname              = jobname
            strtimmed            = strtimmed
            predjob_checkstat    = 'X'
            pred_jobcount        = pred_jobcount
            pred_jobname         = pred_jobname
            event_id             = event_id
            event_param          = event_parm
            targetserver         = targetserver
       IMPORTING
            job_was_released     = gestartet
       EXCEPTIONS
            cant_start_immediate = 1
            invalid_startdate    = 2
            jobname_missing      = 3
            job_close_failed     = 4
            job_nosteps          = 5
            job_notex            = 6
            lock_failed          = 7
            OTHERS               = 8.
  IF sy-subrc <> 0.

    MESSAGE  i001(/adesso/mt_n)
                     WITH 'Job konnte nicht geschlossen werden'.
  ENDIF.


ENDFORM.                    " fjob_close
*&---------------------------------------------------------------------*
*&      Form  erm_jobname_ent
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_JOB_NAME  text
*----------------------------------------------------------------------*
FORM erm_jobname_ent CHANGING p_jobname.

  DATA: fname LIKE temfd-file.

  IF      ecb_par      EQ   'X'.
    MOVE efn_par TO fname.
  ELSEIF  ecb_pno      EQ   'X'.
    MOVE efn_pno TO fname.
  ELSEIF  ecb_420      EQ   'X'.
    MOVE efn_420 TO fname.
  ELSEIF  ecb_mru      EQ   'X'.
    MOVE efn_mru TO fname.
  ELSEIF  ecb_con      EQ   'X'.
    MOVE efn_con TO fname.
  ELSEIF  ecb_noc      EQ   'X'.
    MOVE efn_noc TO fname.
  ELSEIF  ecb_pre      EQ   'X'.
    MOVE efn_pre TO fname.
  ELSEIF  ecb_dlc      EQ   'X'.
    MOVE efn_dlc TO fname.
  ELSEIF  ecb_nod      EQ   'X'.
    MOVE efn_nod TO fname.
  ELSEIF  ecb_dev      EQ   'X'.
    MOVE efn_dev TO fname.
  ELSEIF  ecb_dir      EQ   'X'.
    MOVE  efn_dir TO fname.
  ELSEIF  ecb_ins      EQ   'X'.
    MOVE efn_ins TO fname.
  ELSEIF  ecb_ich      EQ   'X'.
    MOVE efn_ich TO fname.
  elseif  ecb_inn      eq   'X'.
    move  efn_inn to fname.
  elseif  ecb_icn      eq    'X'.
    move  efn_icn to fname.
  ELSEIF  ecb_fac      EQ   'X'.
    MOVE efn_fac TO fname.
  ELSEIF  ecb_rva      EQ   'X'.
    MOVE efn_rva TO fname.
  ELSEIF  ecb_acc      EQ   'X'.
    MOVE efn_acc TO fname.
  ELSEIF  ecb_acs      EQ   'X'.
    MOVE efn_acs TO fname.
  ELSEIF  ecb_acn      EQ   'X'.
    MOVE efn_acn TO fname.
  ELSEIF  ecb_moi      EQ   'X'.
    MOVE efn_moi TO fname.
  ELSEIF  ecb_moh      EQ   'X'.
    MOVE efn_moh TO fname.
  ELSEIF  ecb_moo      EQ   'X'.
    MOVE efn_moo TO fname.
  ELSEIF  ecb_bct      EQ   'X'.
    MOVE efn_bct TO fname.
  ELSEIF  ecb_bcn      EQ   'X'.
    MOVE efn_bcn TO fname.
  ELSEIF  ecb_bpm      EQ   'X'.
    MOVE efn_bpm TO fname.
  ELSEIF  ecb_pay      EQ   'X'.
    MOVE efn_pay TO fname.
  ELSEIF  ecb_doc      EQ   'X'.
    MOVE efn_doc TO fname.
  ELSEIF  ecb_ipl      EQ   'X'.
    MOVE efn_ipl TO fname.
  ELSEIF  ecb_inm      EQ   'X'.
    MOVE efn_inm TO fname.
  ELSEIF  ecb_mrd      EQ   'X'.
    MOVE efn_mrd TO fname.
  ELSEIF  ecb_pod      EQ   'X'.
    MOVE efn_pod TO fname.
  ELSEIF  ecb_poc      EQ   'X'.
    MOVE efn_poc TO fname.
  ELSEIF  ecb_pos      EQ   'X'.
    MOVE efn_pos TO fname.
  ELSEIF  ecb_lot      EQ   'X'.
    MOVE efn_lot TO fname.
  ELSEIF  ecb_cno      EQ   'X'.
    MOVE efn_cno TO fname.
  ELSEIF  ecb_drt      EQ   'X'.
    MOVE efn_drt TO fname.
  ELSEIF  ecb_pad      EQ   'X'.
    MOVE efn_pad TO fname.
  ELSEIF  ecb_lop      EQ   'X'.
    MOVE efn_lop TO fname.
  ELSEIF  ecb_dno      EQ   'X'.
    MOVE efn_dno TO fname.
  ELSEIF  ecb_dcd      EQ   'X'.
    MOVE efn_dcd TO fname.
  ELSEIF  ecb_dco      EQ   'X'.
    MOVE efn_dco TO fname.
  ELSEIF  ecb_dce      EQ   'X'.
    MOVE efn_dce TO fname.
  ELSEIF  ecb_dcr      EQ   'X'.
    MOVE efn_dcr TO fname.
  ELSEIF  ecb_dcm      EQ   'X'.
    MOVE efn_dcm TO fname.
  ELSEIF  ecb_dgr      EQ   'X'.
    MOVE efn_dgr TO fname.
  ELSEIF  ecb_srt      EQ   'X'.
    MOVE efn_srt TO fname.
  ENDIF.

CONCATENATE 'EXPOBJ_' fname INTO p_jobname.
TRANSLATE p_jobname TO UPPER CASE.


ENDFORM.                    " erm_jobname_ent
*&---------------------------------------------------------------------*
*&      Form  job_call_expobject
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_JOB_NAME  text
*----------------------------------------------------------------------*
FORM job_call_expobject USING expobject.

  PERFORM job_start_expobject  USING  expobject
                            CHANGING  gestartet.

  IF gestartet IS INITIAL.
    MESSAGE  i001(/adesso/mt_n) WITH 'Job wurde NICHT gestartet'.
  ELSE.
    MESSAGE  i001(/adesso/mt_n) WITH 'Job wurde gestartet'.
  ENDIF.

ENDFORM.                    " job_call_expobject
*&---------------------------------------------------------------------*
*&      Form  job_start_expobject
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_EXPOBJECT  text
*      <--P_GESTARTET  text
*----------------------------------------------------------------------*
FORM job_start_expobject     USING jobname
                         CHANGING  gestartet.

  DATA: user_print_params     LIKE  pri_params,
        user_arc_params       LIKE  arc_params,
        val.


*  >> Print-Parameter für aktuellen User ermitteln
  PERFORM  fget_print_parameters  CHANGING  user_arc_params
                                            user_print_params
                                            val.
*  << Print-Parameter für aktuellen User ermitteln

* Listenbreite auf 132 festsetzen. Versuche die Eistellung über
* die User-Parameter zu beeinflussen blieben erfolgslos.
* Später könnte man es sicher eleganter lösen.
  user_print_params-linsz = 132.
  user_print_params-paart = 'X_65_132'.

* s. auch Form ,Job_Start_MigObject'

*  >> Job öffnen
  PERFORM  fjob_open              USING     jobname
                                  CHANGING  jobnumber.
*  << Job öffnen

*  >> Report dem Job-Step hinzufügen
*   - Report
  SUBMIT  /adesso/mt_entladung_wb
      WITH  firma             = firma
      WITH  exp_ext           = exp_ext
      WITH  exp_path          = exp_path
      WITH  p_step            = p_step
      WITH  p_split           = p_split
*      WITH  p_delerr          = cbdelerr
      WITH  dat_420           = efn_420
      WITH  dat_acc           = efn_acc
      WITH  dat_acs           = efn_acs
      WITH  dat_acn           = efn_acn
      WITH  dat_bcn           = efn_bcn
      WITH  dat_bct           = efn_bct
      WITH  dat_bpm           = efn_bpm
      WITH  dat_con           = efn_con
      WITH  dat_dev           = efn_dev
      WITH  dat_dir           = efn_dir
      WITH  dat_dlc           = efn_dlc
      WITH  dat_doc           = efn_doc
      WITH  dat_fac           = efn_fac
      WITH  dat_ich           = efn_ich
      WITH  dat_inm           = efn_inm
      with  dat_inn           = efn_inn
      with  dat_icn           = efn_icn
      WITH  dat_ins           = efn_ins
      WITH  dat_ipl           = efn_ipl
      WITH  dat_lot           = efn_lot
      WITH  dat_moi           = efn_moi
      WITH  dat_moh           = efn_moh
      WITH  dat_moo           = efn_moo
      WITH  dat_mrd           = efn_mrd
      WITH  dat_mru           = efn_mru
      WITH  dat_noc           = efn_noc
      WITH  dat_nod           = efn_nod
      WITH  dat_par           = efn_par
      WITH  dat_pay           = efn_pay
      WITH  dat_pno           = efn_pno
      WITH  dat_poc           = efn_poc
      WITH  dat_pod           = efn_pod
      WITH  dat_pos           = efn_pos
      WITH  dat_pre           = efn_pre
      WITH  dat_rva           = efn_rva
      WITH  dat_srt           = efn_srt
      WITH  dat_cno           = efn_cno
      WITH  dat_drt           = efn_drt
      WITH  dat_pad           = efn_pad
      WITH  dat_lop           = efn_lop
      WITH  dat_dno           = efn_dno
      WITH  dat_dcd           = efn_dcd
      WITH  dat_dco           = efn_dco
      WITH  dat_dce           = efn_dce
      WITH  dat_dcr           = efn_dcr
      WITH  dat_dcm           = efn_dcm
      WITH  dat_dgr           = efn_dgr
      WITH  obj_420           = ecb_420
      WITH  obj_acc           = ecb_acc
      WITH  obj_acs           = ecb_acs
      WITH  obj_acn           = ecb_acn
      WITH  obj_bcn           = ecb_bcn
      WITH  obj_bct           = ecb_bct
      WITH  obj_bpm           = ecb_bpm
      WITH  obj_con           = ecb_con
      WITH  obj_dev           = ecb_dev
      WITH  obj_dir           = ecb_dir
      WITH  obj_dlc           = ecb_dlc
      WITH  obj_doc           = ecb_doc
      WITH  obj_fac           = ecb_fac
      WITH  obj_ich           = ecb_ich
      WITH  obj_inm           = ecb_inm
      WITH  obj_ins           = ecb_ins
      with  obj_inn           = ecb_inn
      with  obj_icn           = ecb_icn
      WITH  obj_ipl           = ecb_ipl
      WITH  obj_lot           = ecb_lot
      WITH  obj_moi           = ecb_moi
      WITH  obj_moh           = ecb_moh
      WITH  obj_moo           = ecb_moo
      WITH  obj_mrd           = ecb_mrd
      WITH  obj_mru           = ecb_mru
      WITH  obj_noc           = ecb_noc
      WITH  obj_nod           = ecb_nod
      WITH  obj_par           = ecb_par
      WITH  obj_pay           = ecb_pay
      WITH  obj_pno           = ecb_pno
      WITH  obj_poc           = ecb_poc
      WITH  obj_pod           = ecb_pod
      WITH  obj_pos           = ecb_pos
      WITH  obj_pre           = ecb_pre
      WITH  obj_rva           = ecb_rva
      WITH  obj_srt           = ecb_srt
      WITH  obj_cno           = ecb_cno
      WITH  obj_drt           = ecb_drt
      WITH  obj_pad           = ecb_pad
      WITH  obj_lop           = ecb_lop
      WITH  obj_dno           = ecb_dno
      WITH  obj_dcd           = ecb_dcd
      WITH  obj_dco           = ecb_dco
      WITH  obj_dce           = ecb_dce
      WITH  obj_dcr           = ecb_dcr
      WITH  obj_dcm           = ecb_dcm
      WITH  obj_dgr           = ecb_dgr
*!  < Parameterübergabe
      AND RETURN
      USER                  sy-uname
      VIA JOB               jobname
      NUMBER                jobnumber
      TO SAP-SPOOL
      SPOOL PARAMETERS      user_print_params
      ARCHIVE PARAMETERS    user_arc_params
      WITHOUT SPOOL DYNPRO.
*  << Report dem Job-Step hinzufügen



*  >> Job schließen und starten
  PERFORM  fjob_close                  USING     jobnumber
                                                 jobname
                                                 space
                                                 space
                                                 'X'
                                                 space
                                                 space
                                                 targetserver
                                       CHANGING  gestartet.
*  << Job schließen und starten


ENDFORM.                    " job_start_expobject
*&---------------------------------------------------------------------*
*&      Form  exportreport_dialog
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM exportreport_dialog.

*   - Report
  SUBMIT  /adesso/mt_entladung_wb
      WITH  firma             = firma
      WITH  exp_ext           = exp_ext
      WITH  exp_path          = exp_path
      WITH  p_step            = p_step
      WITH  p_split           = p_split
*      WITH  p_delerr          = cbdelerr
      WITH  dat_420           = efn_420
      WITH  dat_acc           = efn_acc
      WITH  dat_acs           = efn_acs
      WITH  dat_acn           = efn_acn
      WITH  dat_bcn           = efn_bcn
      WITH  dat_bct           = efn_bct
      WITH  dat_bpm           = efn_bpm
      WITH  dat_con           = efn_con
      WITH  dat_dev           = efn_dev
      WITH  dat_dir           = efn_dir
      WITH  dat_dlc           = efn_dlc
      WITH  dat_doc           = efn_doc
      WITH  dat_fac           = efn_fac
      WITH  dat_ich           = efn_ich
      WITH  dat_inm           = efn_inm
      WITH  dat_ins           = efn_ins
      with  dat_inn           = efn_inn
      with  dat_icn           = efn_icn
      WITH  dat_ipl           = efn_ipl
      WITH  dat_lot           = efn_lot
      WITH  dat_moi           = efn_moi
      WITH  dat_moh           = efn_moh
      WITH  dat_moo           = efn_moo
      WITH  dat_mrd           = efn_mrd
      WITH  dat_mru           = efn_mru
      WITH  dat_noc           = efn_noc
      WITH  dat_nod           = efn_nod
      WITH  dat_par           = efn_par
      WITH  dat_pay           = efn_pay
      WITH  dat_pno           = efn_pno
      WITH  dat_poc           = efn_poc
      WITH  dat_pod           = efn_pod
      WITH  dat_pos           = efn_pos
      WITH  dat_pre           = efn_pre
      WITH  dat_rva           = efn_rva
      WITH  dat_srt           = efn_srt
      WITH  dat_cno           = efn_cno
      WITH  dat_drt           = efn_drt
      WITH  dat_pad           = efn_pad
      WITH  dat_lop           = efn_lop
      WITH  dat_dno           = efn_dno
      WITH  dat_dcd           = efn_dcd
      WITH  dat_dco           = efn_dco
      WITH  dat_dce           = efn_dce
      WITH  dat_dcr           = efn_dcr
      WITH  dat_dcm           = efn_dcm
      WITH  dat_dgr           = efn_dgr
      WITH  obj_420           = ecb_420
      WITH  obj_acc           = ecb_acc
      WITH  obj_acs           = ecb_acs
      WITH  obj_acn           = ecb_acn
      WITH  obj_bcn           = ecb_bcn
      WITH  obj_bct           = ecb_bct
      WITH  obj_bpm           = ecb_bpm
      WITH  obj_con           = ecb_con
      WITH  obj_dev           = ecb_dev
      WITH  obj_dir           = ecb_dir
      WITH  obj_dlc           = ecb_dlc
      WITH  obj_doc           = ecb_doc
      WITH  obj_fac           = ecb_fac
      WITH  obj_ich           = ecb_ich
      WITH  obj_inm           = ecb_inm
      WITH  obj_ins           = ecb_ins
      with  obj_inn           = ecb_inn
      with  obj_icn           = ecb_icn
      WITH  obj_ipl           = ecb_ipl
      WITH  obj_lot           = ecb_lot
      WITH  obj_moi           = ecb_moi
      WITH  obj_moh           = ecb_moh
      WITH  obj_moo           = ecb_moo
      WITH  obj_mrd           = ecb_mrd
      WITH  obj_mru           = ecb_mru
      WITH  obj_noc           = ecb_noc
      WITH  obj_nod           = ecb_nod
      WITH  obj_par           = ecb_par
      WITH  obj_pay           = ecb_pay
      WITH  obj_pno           = ecb_pno
      WITH  obj_poc           = ecb_poc
      WITH  obj_pod           = ecb_pod
      WITH  obj_pos           = ecb_pos
      WITH  obj_pre           = ecb_pre
      WITH  obj_rva           = ecb_rva
      WITH  obj_srt           = ecb_srt
      WITH  obj_cno           = ecb_cno
      WITH  obj_drt           = ecb_drt
      WITH  obj_pad           = ecb_pad
      WITH  obj_lop           = ecb_lop
      WITH  obj_dno           = ecb_dno
      WITH  obj_dcd           = ecb_dcd
      WITH  obj_dco           = ecb_dco
      WITH  obj_dce           = ecb_dce
      WITH  obj_dcr           = ecb_dcr
      WITH  obj_dcm           = ecb_dcm
      WITH  obj_dgr           = ecb_dgr

      AND RETURN
      VIA SELECTION-SCREEN.


ENDFORM.                    " exportreport_dialog
*&--------------------------------------------------------------------*
*&      Form  search_right_firm
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*---------------------------------------------------------------------*
FORM search_right_firm.

 IF NOT firma IS INITIAL.
  SELECT SINGLE * FROM /adesso/mt_firma
                    WHERE firma = firma.
   IF sy-subrc EQ 0.
   MOVE: /adesso/mt_firma-exp_pfad TO exp_path,
         /adesso/mt_firma-imp_pfad TO imp_path.
   ELSEIF sy-subrc NE 0.
   LEAVE TO SCREEN 100.
   ENDIF.
 ENDIF.
ENDFORM.                    " search_right_firm
