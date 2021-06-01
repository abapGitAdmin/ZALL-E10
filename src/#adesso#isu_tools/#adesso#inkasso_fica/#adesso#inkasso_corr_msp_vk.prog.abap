*&---------------------------------------------------------------------*
*& Report /ADESSO/INKASSO_CORR_MSP_VK
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /adesso/inkasso_corr_msp_vk.

TABLES: fkkvkp.

DATA: t_dfkklocks TYPE TABLE OF dfkklocks.
DATA: s_dfkklocks TYPE dfkklocks.

DATA: BEGIN OF s_alvout OCCURS 0,
        gpart	   TYPE gpart_kk,
        vkont	   TYPE vkont_kk,
        lockr	   TYPE lockr_kk,
        delet    TYPE icon_d,
        fdate	   TYPE fdate_kk,
        tdate    TYPE tdate_kk,
        uname	   TYPE syuname,
        adatum   TYPE udatum,
        azeit	   TYPE uzeit,
        u_lockr	 TYPE lockr_kk,
        u_updat  TYPE icon_d,
        u_fdate	 TYPE fdate_kk,
        u_tdate  TYPE tdate_kk,
        u_uname	 TYPE syuname,
        u_adatum TYPE udatum,
        u_azeit	 TYPE uzeit,
        bu_long  TYPE bu_descrip_long,
      END OF s_alvout.

DATA: t_alvout LIKE TABLE OF s_alvout.

DATA: gf_subrc TYPE sysubrc.

* ALV
TYPE-POOLS: slis.
DATA: rev_alv TYPE REF TO cl_gui_alv_grid.

DATA: gf_repid    LIKE sy-repid,
      gs_layout   TYPE slis_layout_alv,
      gt_fieldcat TYPE slis_t_fieldcat_alv,
      gf_tabname  TYPE slis_tabname,
      gf_title    TYPE  lvc_title.

*************************************************************************
* Selektionsbildschirm
*************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK vko WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: so_vkont FOR fkkvkp-vkont.
SELECTION-SCREEN END OF BLOCK vko.

SELECTION-SCREEN BEGIN OF BLOCK msp WITH FRAME TITLE TEXT-002.

PARAMETERS: pa_proid  LIKE  dfkklocks-proid DEFAULT '01'.
PARAMETERS: pa_lotyp  LIKE  dfkklocks-lotyp DEFAULT '06'.
PARAMETERS: pa_lockd  LIKE fkkvkp-mansp    DEFAULT '7'.

SELECTION-SCREEN SKIP.

PARAMETERS: pa_locks  LIKE fkkvkp-mansp    DEFAULT 'D'.

SELECTION-SCREEN END OF BLOCK msp.

SELECTION-SCREEN BEGIN OF BLOCK upd WITH FRAME TITLE TEXT-002.

PARAMETERS: pa_updat AS CHECKBOX DEFAULT ' '.

SELECTION-SCREEN END OF BLOCK upd.

**************************************************************************
* START-OF-SELECTION
**************************************************************************
START-OF-SELECTION.

  SELECT * FROM dfkklocks
         INTO TABLE t_dfkklocks
         WHERE vkont IN so_vkont
         AND   proid =  pa_proid
         AND   lotyp =  pa_lotyp
         AND   lockr =  pa_lockd.


  LOOP AT t_dfkklocks INTO s_dfkklocks.
    CLEAR s_alvout.
    MOVE-CORRESPONDING s_dfkklocks TO s_alvout.

    CALL FUNCTION 'BUP_PARTNER_DESCRIPTION_GET'
      EXPORTING
        i_partner          = s_dfkklocks-gpart
        i_valdt_sel        = sy-datum
      IMPORTING
        e_description_long = s_alvout-bu_long
      EXCEPTIONS
        OTHERS             = 5.

    IF sy-subrc <> 0.
      s_alvout-bu_long = '???'.
    ENDIF.

    IF s_dfkklocks-fdate = '00010101'.
      s_alvout-u_fdate = s_dfkklocks-adatum.
    ELSE.
      s_alvout-u_fdate = s_dfkklocks-fdate.
    ENDIF.

    s_alvout-u_lockr  = pa_locks.
    s_alvout-u_tdate  = s_dfkklocks-tdate.
    s_alvout-u_uname  = s_dfkklocks-uname.

    IF pa_updat = 'X'.
*     Erst vorhandene Mahnsperre löschen
      PERFORM del_mahnsperre  USING s_alvout pa_lockd gf_subrc.
*     Dann neue Mahnsperre setzen
      PERFORM set_mahnsperre  USING s_alvout pa_locks gf_subrc.
    ENDIF.

    APPEND s_alvout TO t_alvout.

  ENDLOOP.

**************************************************************************
* END-OF-SELECTION
**************************************************************************
END-OF-SELECTION.

  gf_repid   = sy-repid.
  gf_tabname = 'T_ALVOUT'.
  gs_layout-zebra = 'X'.
  gs_layout-colwidth_optimize = 'X'.
  PERFORM fieldcat_build USING gt_fieldcat[].

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      is_layout          = gs_layout
      it_fieldcat        = gt_fieldcat[]
    TABLES
      t_outtab           = t_alvout
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  SET_MAHNSPERRE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_OUT_VKONT  text
*----------------------------------------------------------------------*
FORM set_mahnsperre   USING  fs_alvout LIKE s_alvout
                             ff_locks
                             ff_subrc.

  DATA: lv_loobj1 LIKE dfkklocks-loobj1.
  DATA: ls_locks  TYPE dfkklocks.
  DATA: lf_fdate  TYPE fdate_kk.


  CLEAR ff_subrc.

* Dann Mahnsperre setzen
  CONCATENATE fs_alvout-vkont fs_alvout-gpart INTO lv_loobj1.

    IF fs_alvout-fdate = '00010101'.
      lf_fdate = fs_alvout-adatum.
    ELSE.
      lf_fdate = fs_alvout-fdate.
    ENDIF.

  CALL FUNCTION 'FKK_S_LOCK_CREATE'
    EXPORTING
      i_loobj1              = lv_loobj1
      i_gpart               = fs_alvout-gpart
      i_vkont               = fs_alvout-vkont
      i_proid               = pa_proid
      i_lotyp               = pa_lotyp
      i_lockr               = ff_locks
      i_fdate               = lf_fdate
      i_tdate               = fs_alvout-tdate
      i_uname               = fs_alvout-uname
      i_upd_online          = 'X'
      i_adatum              = fs_alvout-adatum
      i_azeit               = fs_alvout-azeit
    IMPORTING
      es_locks              = ls_locks
    EXCEPTIONS
      already_exist         = 1
      imp_data_not_complete = 2
      no_authority          = 3
      enqueue_lock          = 4
      wrong_data            = 5
      OTHERS                = 6.

  IF sy-subrc <> 0.
    ff_subrc = sy-subrc.
    fs_alvout-delet = icon_led_red.
  ELSE.
    ff_subrc = sy-subrc.
    fs_alvout-u_lockr	 = ls_locks-lockr.
    fs_alvout-u_updat  = icon_led_green.
    fs_alvout-u_fdate	 = ls_locks-fdate.
    fs_alvout-u_tdate  = ls_locks-tdate.
    fs_alvout-u_uname	 = ls_locks-uname.
    fs_alvout-u_adatum = ls_locks-adatum.
    fs_alvout-u_azeit	 = ls_locks-azeit.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  DEL_MAHNSPERRE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_OUT_VKONT  text
*----------------------------------------------------------------------*
FORM del_mahnsperre  USING  fs_alvout LIKE s_alvout
                            ff_lockd
                            ff_subrc.

  DATA: lt_locks  TYPE  dfkklocks_t.
  DATA: ls_locks  TYPE  dfkklocks.

  CLEAR ff_subrc.

  CALL FUNCTION 'FKK_S_LOCK_GET_FOR_VKONT'
    EXPORTING
      iv_vkont = fs_alvout-vkont
      iv_gpart = fs_alvout-gpart
      iv_date  = sy-datum
      iv_proid = pa_proid
    IMPORTING
      et_locks = lt_locks.

  LOOP AT lt_locks INTO ls_locks
       WHERE lotyp = pa_lotyp
       AND   proid = pa_proid
       AND   lockr = ff_lockd.

    CALL FUNCTION 'FKK_S_LOCK_DELETE'
      EXPORTING
        i_loobj1 = ls_locks-loobj1
        i_gpart  = ls_locks-gpart
        i_vkont  = ls_locks-vkont
        i_proid  = ls_locks-proid
        i_lotyp  = ls_locks-lotyp
        i_lockr  = ls_locks-lockr
        i_fdate  = ls_locks-fdate
        i_tdate  = ls_locks-tdate
      EXCEPTIONS
        OTHERS   = 7.

    IF sy-subrc <> 0.
      ff_subrc = sy-subrc.
      fs_alvout-delet = icon_led_red.
    ELSE.
      ff_subrc = sy-subrc.
      fs_alvout-delet = icon_led_green.
    ENDIF.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_FIELDCAT[]  text
*----------------------------------------------------------------------*
FORM fieldcat_build   USING  lt_fieldcat TYPE slis_t_fieldcat_alv.

  DATA: ls_fieldcat TYPE slis_fieldcat_alv.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'GPART'.
  ls_fieldcat-tabname = gf_tabname.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'VKONT'.
  ls_fieldcat-tabname = gf_tabname.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'LOCKR'.
  ls_fieldcat-tabname = gf_tabname.
  ls_fieldcat-ref_tabname = 'DFKKLOCKS'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DELET'.
  ls_fieldcat-tabname = gf_tabname.
  ls_fieldcat-icon        = 'X'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'FDATE'.
  ls_fieldcat-tabname = gf_tabname.
  ls_fieldcat-ref_tabname = 'DFKKLOCKS'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TDATE'.
  ls_fieldcat-tabname = gf_tabname.
  ls_fieldcat-ref_tabname = 'DFKKLOCKS'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'UNAME'.
  ls_fieldcat-tabname = gf_tabname.
  ls_fieldcat-ref_tabname = 'DFKKLOCKS'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'ADATUM'.
  ls_fieldcat-tabname = gf_tabname.
  ls_fieldcat-ref_tabname = 'DFKKLOCKS'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'AZEIT'.
  ls_fieldcat-tabname = gf_tabname.
  ls_fieldcat-ref_tabname = 'DFKKLOCKS'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'U_LOCKR'.
  ls_fieldcat-tabname = gf_tabname.
  ls_fieldcat-ref_tabname = 'DFKKLOCKS'.
  ls_fieldcat-ref_fieldname = 'LOCKR'.
  ls_fieldcat-emphasize    = 'C50'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'U_UPDAT'.
  ls_fieldcat-tabname = gf_tabname.
  ls_fieldcat-icon        = 'X'.
  ls_fieldcat-emphasize    = 'C50'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'U_FDATE'.
  ls_fieldcat-tabname = gf_tabname.
  ls_fieldcat-ref_tabname = 'DFKKLOCKS'.
  ls_fieldcat-ref_fieldname = 'FDATE'.
  ls_fieldcat-emphasize    = 'C50'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'U_TDATE'.
  ls_fieldcat-tabname = gf_tabname.
  ls_fieldcat-ref_tabname = 'DFKKLOCKS'.
  ls_fieldcat-ref_fieldname = 'TDATE'.
  ls_fieldcat-emphasize    = 'C50'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'U_UNAME'.
  ls_fieldcat-tabname = gf_tabname.
  ls_fieldcat-ref_tabname = 'DFKKLOCKS'.
  ls_fieldcat-ref_fieldname = 'UNAME'.
  ls_fieldcat-emphasize    = 'C50'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'U_ADATUM'.
  ls_fieldcat-tabname = gf_tabname.
  ls_fieldcat-ref_tabname = 'DFKKLOCKS'.
  ls_fieldcat-ref_fieldname = 'ADATUM'.
  ls_fieldcat-emphasize    = 'C50'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'U_AZEIT'.
  ls_fieldcat-tabname = gf_tabname.
  ls_fieldcat-ref_tabname = 'DFKKLOCKS'.
  ls_fieldcat-ref_fieldname = 'AZEIT'.
  ls_fieldcat-emphasize    = 'C50'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BU_LONG'.
  ls_fieldcat-tabname = gf_tabname.
  ls_fieldcat-ref_tabname = 'BUS000FLDS'.
  ls_fieldcat-ref_fieldname = 'DESCRIP_LONG'.
  APPEND ls_fieldcat TO lt_fieldcat.

ENDFORM.                    " FIELDCAT_BUILD
