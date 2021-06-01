*&---------------------------------------------------------------------*
*& Report  /ADESSO/INKASSO_MONITOR
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT /adesso/inkasso_monitor MESSAGE-ID /adesso/inkmon.


INCLUDE /adesso/inkasso_monitor_top.

INCLUDE /adesso/inkasso_monitor_scr.

INCLUDE /adesso/inkasso_monitor_o01.

INCLUDE /adesso/inkasso_monitor_i01.

INCLUDE /adesso/inkasso_monitor_f01.

INCLUDE /adesso/inkasso_monitor_f02.

************************************************************************
* INITIALIZATION
************************************************************************
INITIALIZATION.

  PERFORM get_cust_begru.

  PERFORM init_custom_fields.

  CASE const_marked.
    WHEN p_alv.
      PERFORM variant_init USING const_alv.
    WHEN p_hier.
      PERFORM variant_init USING const_hier.
  ENDCASE.

**************************************************************************
* AT SELECTION-SCREEN OUTPUT
**************************************************************************
AT SELECTION-SCREEN OUTPUT.

** FC01 Statistik (Funktionstaste 1)
  READ TABLE    gt_bgss INTO gs_bgss
       WITH KEY begru    = gs_bgus-begru
                bgcat_ss = 'SELSCREEN'
                bgfld_ss = 'FC01'.
  IF sy-subrc = 0 AND gs_bgss-inactiv = space.
    sscrfields-functxt_01 = VALUE smp_dyntxt( icon_id = icon_statistics
                                              quickinfo = 'Statistik'
                                              icon_text = 'Statistik' ).
  ENDIF.

  READ TABLE gt_bgus INTO gs_bgus INDEX 1.
  IF sy-subrc NE 0.
    MESSAGE TEXT-e02 TYPE 'E'.
  ENDIF.

  LOOP AT SCREEN.
    READ TABLE    gt_bgss INTO gs_bgss
         WITH KEY begru    = gs_bgus-begru
                  bgcat_ss = 'SELSCREEN'
                  bgfld_ss = screen-name.
    IF sy-subrc = 0.
      IF gs_bgss-inactiv = const_marked.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.
      CONTINUE.
    ENDIF.
    READ TABLE    gt_bgss INTO gs_bgss
         WITH KEY begru    = gs_bgus-begru
                  bgcat_ss = 'SELSCREEN'
                  bgfld_ss = screen-group1.
    IF sy-subrc = 0.
      IF gs_bgss-inactiv = const_marked.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.
      CONTINUE.
    ENDIF.
  ENDLOOP.

  SELECT SINGLE * FROM /adesso/ink_cust
      INTO gs_cust
      WHERE inkasso_option = 'TITLE'.

  READ TABLE gt_begr INTO gs_begr INDEX 1.

  CONCATENATE gs_cust-inkasso_value gs_begr-bgtxt
              INTO g_title SEPARATED BY space.

  SELECT MAX( laufd )
         FROM dfkkcollh_i_w
         INTO @DATA(maxlaufd).

  WRITE maxlaufd TO datinfos DD/MM/YYYY.

  SELECT MAX( infodat )
         FROM /adesso/ink_idat
         INTO @DATA(maxinfodat).

  WRITE maxinfodat TO datinfgp DD/MM/YYYY.

  SET TITLEBAR 'STANDARD_INKASSO'  OF PROGRAM sy-repid WITH g_title.


*********************************************************************************
* Process on value request
*********************************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM f4_for_variant CHANGING p_vari.

**********************************************************************************
* AT SELECTION-SCREEN
**********************************************************************************
AT SELECTION-SCREEN.

  CASE sscrfields-ucomm.
* wenn Funktionstaste 1: Statistik
    WHEN 'FC01'.
      SUBMIT /adesso/inkasso_statistik
             VIA SELECTION-SCREEN AND RETURN.
      CLEAR sscrfields-ucomm.

    WHEN OTHERS.
      PERFORM pai_of_selection_screen.

      wa_opt-xagapi = p_xagapi.
      wa_opt-xopwo  = p_xopwo.
      wa_opt-xagip  = p_xagip.
      wa_opt-xvorm  = p_vorm.
      wa_opt-xlook  = p_look.
      wa_opt-xchkd  = p_chkd.
      wa_opt-xfrei  = p_frei.
      wa_opt-xreca  = p_reca.
      wa_opt-xrview = p_xrview.
      wa_opt-xinspl = p_xinspl.
      wa_opt-xnewin = p_xnewin.
      wa_opt-xfact  = p_xfact.
      wa_opt-xsell  = p_sell.
      wa_opt-xdsel  = p_dsel.
      wa_opt-xwroff = p_wroff.
      wa_opt-abbri  = p_abbri.
      wa_opt-apprse = p_apprse.
      wa_opt-apprwo = p_apprwo.

      IF wa_opt IS INITIAL AND
         p_infos = space AND p_infgp = space.
        MESSAGE TEXT-e01 TYPE 'E'.
      ENDIF.
  ENDCASE.

**************************************************************************
* START-OF-SELECTION
**************************************************************************
START-OF-SELECTION.

  IF sy-batch = 'X'.
    x_maxts = c_maxtb.
  ELSE.
    x_maxts = c_maxtd.
  ENDIF.

  IF pa_showh = 'X'.
    PERFORM show_history.
    STOP.
  ENDIF.

  wa_opt-xagapi = p_xagapi.
  wa_opt-xvorm  = p_vorm.          "Nuss 05.2018
  wa_opt-xlook  = p_look.          "Nuss 05.2018
  wa_opt-xchkd  = p_chkd.          "Nuss 05.2018
  wa_opt-xfrei  = p_frei.          "Nuss 05.2018
  wa_opt-xreca  = p_reca.
  wa_opt-xagip  = p_xagip.
  wa_opt-xopwo  = p_xopwo.
  wa_opt-xrview = p_xrview.
  wa_opt-xinspl = p_xinspl.
  wa_opt-xnewin = p_xnewin.
  wa_opt-xfact  = p_xfact.
  wa_opt-xsell  = p_sell.
  wa_opt-xdsel  = p_dsel.
  wa_opt-xwroff = p_wroff.
  wa_opt-abbri  = p_abbri.
  wa_opt-apprse = p_apprse.
  wa_opt-apprwo = p_apprwo.

  PERFORM build_ranges.

  PERFORM get_customizing.

  PERFORM pre_select.

  WAIT FOR ASYNCHRONOUS TASKS UNTIL t_tasks IS INITIAL.

  PERFORM create_tasks.

  LOOP AT t_tasks ASSIGNING <t_tasks>.

    REFRESH t_select.

    APPEND LINES OF t_gpvk
      FROM <t_tasks>-low
        TO <t_tasks>-high
        TO t_select.

    CHECK t_select IS NOT INITIAL.

    ADD 1 TO x_runts.

    CALL FUNCTION '/ADESSO/INKASSO_SELECT'
      STARTING NEW TASK <t_tasks>-name
      DESTINATION IN GROUP DEFAULT
      PERFORMING ende_task ON END OF TASK
      EXPORTING
        x_opt                 = wa_opt
        x_check               = p_check
        x_ovrdue              = p_ovrdue
        xt_spart              = gt_spart
        xt_vktyp              = gt_vktyp
        xt_regio              = gt_regio
        xt_lockr              = gt_lockr
      TABLES
        it_select             = t_select
*        et_out                = ft_out
      EXCEPTIONS
        communication_failure = 1
        system_failure        = 2
        resource_failure      = 3.

*    IF sy-subrc NE 0.
*      MESSAGE text-e04 TYPE 'E'.
*      STOP.
*    ENDIF.

*    WAIT FOR ASYNCHRONOUS TASKS UNTIL x_runts < x_maxts.
    WAIT FOR ASYNCHRONOUS TASKS UNTIL t_tasks[] IS INITIAL UP TO 20 SECONDS.

  ENDLOOP.

  WAIT FOR ASYNCHRONOUS TASKS UNTIL t_tasks[] IS INITIAL UP TO 20 SECONDS.
*  WAIT FOR ASYNCHRONOUS TASKS UNTIL 1 = 2 UP TO 10 SECONDS.

**************************************************************************
* END-OF-SELECTION
**************************************************************************
END-OF-SELECTION.

  DATA: h_betrw TYPE betrw_kk.
  DATA: lv_vjfrist TYPE /adesso/overdue.
  DATA: lv_vjduedt TYPE dats.

  DATA: BEGIN OF lt_faedn OCCURS 0,
          faedn TYPE faedn_kk,
        END OF lt_faedn.

  CLEAR gs_cust.
  READ TABLE gt_cust INTO  gs_cust
     WITH KEY inkasso_option = 'VJ_FRIST'
              inkasso_field  = 'VJFRIST'
              inkasso_id     = '1'.

  MOVE gs_cust-inkasso_value TO lv_vjfrist.

  CASE const_marked.
    WHEN p_alv.
      PERFORM init_alv USING const_alv.
      PERFORM fieldcat_build USING gt_fieldcat[].


    WHEN p_hier.

      PERFORM init_alv USING const_hier.
      PERFORM set_keyinfo CHANGING gs_keyinfo.
      PERFORM fieldcat_header USING gt_fieldcat_header.
      PERFORM fieldcat_items  USING gt_fieldcat_items.
      APPEND LINES OF gt_fieldcat_header TO gt_fieldcat.
      APPEND LINES OF gt_fieldcat_items  TO gt_fieldcat.

      CLEAR lv_vjduedt.
      lv_vjduedt = sy-datum - lv_vjfrist.

*      SORT t_out BY gpart vkont agsta DESCENDING.
      SORT t_out BY gpart vkont hf DESCENDING hvorg DESCENDING faedn ASCENDING.
      LOOP AT t_out ASSIGNING <t_out>.

        AT NEW vkont.
          MOVE-CORRESPONDING <t_out> TO t_header.

          CLEAR gv_info.
          CALL FUNCTION 'ENQUEUE_/ADESSO/INKMON'
            EXPORTING
              mode_/adesso/ink_enqu = 'X'
              ink_proc              = '01'
              vkont                 = <t_out>-vkont
              x_bukrs               = ' '
              _scope                = '1'
              _wait                 = ' '
              _collect              = ' '
            EXCEPTIONS
              foreign_lock          = 1
              system_failure        = 2
              OTHERS                = 3.

          CASE sy-subrc.
            WHEN 1.
              CONCATENATE TEXT-021 sy-msgv1
                          INTO gv_info
                          SEPARATED BY space.
              CALL FUNCTION 'ICON_CREATE'
                EXPORTING
                  name                  = 'ICON_USER_BREAKPOINT'
                  info                  = gv_info
                IMPORTING
                  result                = t_header-locked
                EXCEPTIONS
                  icon_not_found        = 1
                  outputfield_too_short = 2
                  OTHERS                = 3.
              IF sy-subrc <> 0.
                MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
              ENDIF.
            WHEN 2.
            WHEN OTHERS.

          ENDCASE.
        ENDAT.

        MOVE-CORRESPONDING <t_out> TO t_items.
        APPEND t_items.
        h_betrw = h_betrw + <t_out>-betrw.

        IF <t_out>-hvorg IN gr_hvorg.
          CLEAR lt_faedn.
          lt_faedn-faedn = <t_out>-faedn.
          COLLECT lt_faedn.
        ENDIF.

        IF <t_out>-ssr = 'X'.
          t_header-ssr = 'X'.
        ENDIF.

        AT END OF vkont.

          t_header-betrw = h_betrw.

          CLEAR: t_header-faedn, t_header-vjfrist.
          SORT lt_faedn.
          LOOP AT lt_faedn.
            IF sy-tabix = 1.
              t_header-faedn = lt_faedn-faedn.
            ENDIF.
            IF lt_faedn-faedn < lv_vjduedt.
              CALL FUNCTION 'ICON_CREATE'
                EXPORTING
                  name                  = 'ICON_ALERT'
                  info                  = TEXT-017
                IMPORTING
                  result                = t_header-vjfrist
                EXCEPTIONS
                  icon_not_found        = 1
                  outputfield_too_short = 2
                  OTHERS                = 3.
              IF sy-subrc <> 0.
                MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
              ENDIF.
            ENDIF.
          ENDLOOP.

          APPEND  t_header.
          CLEAR h_betrw.
          REFRESH lt_faedn.

        ENDAT.
      ENDLOOP.

  ENDCASE.

  PERFORM display_alv.


  IF sy-subrc = 0.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  CALL_ZP_FB_5059
*&---------------------------------------------------------------------*
*       delete position for releasing to a collection agency
*----------------------------------------------------------------------*
FORM call_zp_fb_5059 TABLES   pt_fkkop_not_submitted STRUCTURE fkkop
                     USING    h_fkkop  STRUCTURE fkkop
                     CHANGING h_rel_instpln LIKE boole-boole.

  DATA: t_tfkfbc_5059 LIKE tfkfbc OCCURS 0 WITH HEADER LINE.
  DATA: p_applk LIKE fkkop-applk.

* ------ determinig application ---------------------------------------*
  CALL FUNCTION 'FKK_GET_APPLICATION'
    IMPORTING
      e_applk       = p_applk
    EXCEPTIONS
      error_message = 1.

* Determine function modules for events 5059, 5060 --------------------*
  REFRESH t_tfkfbc_5059.
  CALL FUNCTION 'FKK_FUNC_MODULE_DETERMINE'
    EXPORTING
      i_fbeve  = '5059'
      i_applk  = p_applk
    TABLES
      t_fbstab = t_tfkfbc_5059
    EXCEPTIONS
      OTHERS   = 1.

  CLEAR h_rel_instpln.
  REFRESH: pt_fkkop_not_submitted.

  LOOP AT t_tfkfbc_5059.
    CALL FUNCTION t_tfkfbc_5059-funcc
      EXPORTING
        i_fkkop               = h_fkkop
      TABLES
        t_fkkop_not_submitted = pt_fkkop_not_submitted
      CHANGING
        i_rel_instpln         = h_rel_instpln
      EXCEPTIONS
        OTHERS                = 1.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDLOOP.
* ------ for cross reference purpose only -----------------------------*
  SET EXTENDED CHECK OFF.
  IF 1 = 2.
    CALL FUNCTION 'FKK_SAMPLE_5059'.
  ENDIF.
  SET EXTENDED CHECK ON.
* ------ end of cross reference ---------------------------------------*

ENDFORM.                    " CALL_ZP_FB_5059


*&---------------------------------------------------------------------*
*&      Form  GET_BEGRU
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITAB_FKKOP_GPART  text
*      -->P_ITAB_FKKOP_VKONT  text
*      <--P_H_BEGRU  text
*----------------------------------------------------------------------*
FORM get_begru  USING p_gpart LIKE fkkvkp1-gpart
                      p_vkont LIKE fkkvkp1-vkont
             CHANGING p_begru LIKE fkkvkp1-begru.

  DATA: BEGIN OF t_fkkvkp1 OCCURS 1.
          INCLUDE STRUCTURE fkkvkp1.
        DATA: END OF t_fkkvkp1.

  t_fkkvkp1-vkont = p_vkont.
  t_fkkvkp1-gpart = p_gpart.
  APPEND t_fkkvkp1.

  CALL FUNCTION 'FKK_DB_FKKVKP1_FORALL'
    TABLES
      t_fkkvkp1    = t_fkkvkp1
    EXCEPTIONS
      not_found    = 1
      system_error = 2
      OTHERS       = 3.

  IF sy-subrc NE 0.
    MESSAGE e620(>3) WITH t_fkkvkp1-vkont t_fkkvkp1-gpart.
  ELSE.
    p_begru = t_fkkvkp1-begru.
  ENDIF.

ENDFORM.                    " GET_BEGRU

******&---------------------------------------------------------------------*
******&      Form  PROCESS_POS_4_REQ_DRS
******&---------------------------------------------------------------------*
******       text
******----------------------------------------------------------------------*
******      -->P_ITAB_FKKOP  text
******      <--P_P_POS_WA  text
******----------------------------------------------------------------------*
*****FORM process_pos_4_req_drs USING    is_fkkop  TYPE fkkop
*****                           CHANGING cs_pos    TYPE zinkasso_out.
*****
*****  DATA: lv_applk TYPE applk_kk,
*****        xrequest TYPE xfeld.
*****  STATICS: loct_6250 LIKE tfkfbc OCCURS 0 WITH HEADER LINE.
*****
****** check DRS is active
*****  CHECK gv_flg_drs_active EQ 'X'.
*****
****** determine the function module for event 6250
*****  IF loct_6250[] IS INITIAL.
*****    CALL FUNCTION 'FKK_GET_APPLICATION'
*****      IMPORTING
*****        e_applk = lv_applk
*****      EXCEPTIONS
*****        OTHERS  = 0.
*****
*****    CALL FUNCTION 'FKK_FUNC_MODULE_DETERMINE'
*****      EXPORTING
*****        i_applk  = lv_applk
*****        i_fbeve  = '6250'
*****      TABLES
*****        t_fbstab = loct_6250.
*****    IF loct_6250[] IS INITIAL.
*****      CLEAR loct_6250.
*****      APPEND loct_6250.
*****    ENDIF.
*****  ENDIF.
****** call event
*****  LOOP AT loct_6250 WHERE funcc NE space.
*****    CALL FUNCTION loct_6250-funcc
*****      EXPORTING
*****        i_fkkop    = is_fkkop
*****        i_source   = '1' "release manually
*****      IMPORTING
*****        e_xrequest = xrequest.
*****
*****    cs_pos-rqs_drs = xrequest.
*****
*****    SET EXTENDED CHECK OFF.
*****    IF 1 = 2. CALL FUNCTION 'FKK_SAMPLE_6250'. ENDIF.
*****    SET EXTENDED CHECK ON.
*****  ENDLOOP.
*****
*****ENDFORM.                    " PROCESS_POS_4_REQ_DRS

INCLUDE /adesso/inkasso_monitor_d01.
