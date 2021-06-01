***&---------------------------------------------------------------------*
***& Report  Z_INKASSO_MONITOR
***&
***&---------------------------------------------------------------------*
***&
***&
***&---------------------------------------------------------------------*
**
REPORT z_inkasso_monitor_old.

* Konstanten
CONSTANTS: const_aggrd_einzelabgabe LIKE dfkkcoll-aggrd VALUE '06',
           const_agsta_freigegeben  LIKE dfkkcoll-agsta VALUE '01',
           const_agsta_storniert    LIKE dfkkcoll-agsta VALUE '05',
           const_agsta_recalled     LIKE dfkkcoll-agsta VALUE '09',
           const_agsta_cust_p_pay   LIKE dfkkcoll-agsta VALUE '11',
           const_agsta_p_paid       LIKE dfkkcoll-agsta VALUE '13',
           const_agsta_rel_erfolglos LIKE dfkkcoll-agsta VALUE '14',
           const_marked(1)          TYPE c VALUE 'X'.

* ALV
TYPE-POOLS: slis.

DATA: g_repid LIKE sy-repid,
      g_save TYPE char1,
      g_exit TYPE char1,
      gx_variant LIKE disvariant,
      g_variant LIKE disvariant,
      gs_layout   TYPE slis_layout_alv,
      gt_sort     TYPE slis_t_sortinfo_alv,
      gt_fieldcat TYPE slis_t_fieldcat_alv,
      g_user_command TYPE slis_formname VALUE 'USER_COMMAND',
      g_status  TYPE slis_formname VALUE 'STATUS_STANDARD'.

DATA: gt_event      TYPE slis_t_event.
DATA: gs_listheader TYPE slis_listheader.
DATA: gt_listheader TYPE slis_listheader OCCURS 1.
DATA: x_lines TYPE i.
DATA: c_lines(10) TYPE c.


DATA: wa_fkkop TYPE fkkop,
      wa_dfkkcoll TYPE dfkkcoll,
      wa_fkkmaze TYPE fkkmaze,
      it_fkkmaze TYPE STANDARD TABLE OF fkkmaze.

* Positionstabelle
TYPES: BEGIN OF t_tc_pos,
         applk LIKE dfkkop-applk,
         xselp           TYPE xselp,
         sel(1)        TYPE c,
         status TYPE char35,         "stat_fp03e_kk,
         gpart LIKE dfkkop-gpart,
         vkont LIKE dfkkop-vkont,
         opbel LIKE dfkkop-opbel,
         xblnr LIKE dfkkop-xblnr,
         mahns LIKE fkkmaze-mahns,
         mahnv LIKE fkkmaze-mahnv,
         waers TYPE dfkkop-waers,
         betrw TYPE dfkkcoll-betrw,
         faedn TYPE dfkkop-faedn,
         inkgp LIKE dfkkcoll-inkgp,
         inkname LIKE but000-name_org1,
         agsta LIKE dfkkcoll-agsta,
         agstatxt  LIKE dd07t-ddtext,
         aggrd LIKE dfkkcoll-aggrd,
         opupk LIKE dfkkop-opupk,
         opupw LIKE dfkkop-opupw,
         opupz LIKE dfkkop-opupz,
         bldat LIKE dfkkop-bldat,
         budat LIKE dfkkop-budat,
         inkps LIKE dfkkop-inkps,
         stakz LIKE dfkkop-stakz,
         bukrs LIKE dfkkop-bukrs,
         vtref LIKE dfkkop-vtref,
         augrd LIKE dfkkop-augrd,
         ausgeb  TYPE char1,
         billfin TYPE char1,
         drs_reqdate LIKE dfkkcms-drs_reqdate,
*         drs_upddate TYPE dfkkcms-drs_upddate,
         drs_rspdate TYPE dfkkcms-drs_rspdate,
         drs_score   TYPE dfkkcms-drs_score,
         rqs_drs     TYPE reqdrs_kk,
       END OF t_tc_pos.

TYPES  t_tc_pos_tab TYPE TABLE OF t_tc_pos.
DATA: pos_itab TYPE TABLE OF t_tc_pos,
      pos_wa LIKE LINE OF pos_itab,
      fkkop_itab LIKE TABLE OF fkkop WITH HEADER LINE,
      pos_itab_marked TYPE TABLE OF t_tc_pos WITH HEADER LINE,
      ht_enqtab       LIKE ienqtab OCCURS 0 WITH HEADER LINE,
*      rfka10_buffer LIKE rfka10,
      t_history_coll LIKE dfkkcollh OCCURS 0 WITH HEADER LINE.

DATA  gv_flg_drs_active TYPE xfeld.
DATA:  error           TYPE i.
DATA:  okcode          LIKE sy-ucomm.



*************************************************************************
* Selektionsbildschirm
*************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK sel WITH FRAME TITLE text-001.
SELECT-OPTIONS: so_bukrs FOR wa_fkkop-bukrs,
                so_gpart FOR wa_fkkop-gpart,
                so_vkont FOR wa_fkkop-vkont,
                so_vtref FOR wa_fkkop-vtref,
                so_opbel FOR wa_fkkop-opbel,
                so_faedn FOR wa_fkkop-faedn,
                so_mahns FOR wa_fkkmaze-mahns,
                so_mahnv FOR wa_fkkmaze-mahnv.
SELECTION-SCREEN END OF BLOCK sel.

*SELECTION-SCREEN BEGIN OF BLOCK dun WITH FRAME TITLE text-dun.
*SELECT-OPTIONS: so_laufd FOR wa_fkkmaze-laufd,
*                so_laufi FOR wa_fkkmaze-laufi.
*SELECTION-SCREEN END OF BLOCK dun.

SELECTION-SCREEN BEGIN OF BLOCK opt WITH FRAME TITLE text-002.
PARAMETERS: p_xagapi AS CHECKBOX DEFAULT 'X',
            p_xopwo AS CHECKBOX,
            p_xagip AS CHECKBOX.
SELECT-OPTIONS: so_agsta FOR wa_dfkkcoll-agsta,
                so_aggrd FOR wa_dfkkcoll-aggrd.

SELECTION-SCREEN END OF BLOCK opt.



**************************************************************************
* START-OF-SELECTION
**************************************************************************
START-OF-SELECTION.
*  IF NOT so_laufd IS INITIAL OR
*     NOT so_laufi IS INITIAL.
*    PERFORM mahnzeilen_lesen.
*  ENDIF.
  PERFORM select_data CHANGING pos_itab
                               pos_wa.

  LOOP AT pos_itab INTO pos_wa.
    PERFORM icon_create.
    MODIFY pos_itab FROM pos_wa TRANSPORTING status.
  ENDLOOP.


**************************************************************************
* END-OF-SELECTION
**************************************************************************
END-OF-SELECTION.
  CHECK pos_itab IS NOT INITIAL.
  PERFORM layout_build USING gs_layout.
  PERFORM fieldcat_build USING gt_fieldcat[].
  PERFORM display_alv.



*&---------------------------------------------------------------------*
*&      Form  SELECT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_POS_ITAB  text
*      <--P_POS_WA  text
*----------------------------------------------------------------------*
FORM select_data  CHANGING p_pos_itab LIKE pos_itab
                           p_pos_wa LIKE pos_wa.

  DATA: count   LIKE sy-dbcnt,
        itab_fkkop LIKE TABLE OF fkkop WITH HEADER LINE,
        ht_fkkop_not_submitted LIKE fkkop OCCURS 0 WITH HEADER LINE,
        h_rel_instpln LIKE boole-boole,
        h_begru       LIKE fkkvkp1-begru,
        h_gpart       LIKE fkkop-gpart.

  DATA: lv_xmiss_auth TYPE xfeld.

  DATA: ls_ever TYPE ever,
        ls_dd07t     TYPE dd07t,
        lv_vertrag TYPE ever-vertrag.

  REFRESH: p_pos_itab,
           itab_fkkop.

* Lesen aller Positionen
  CALL FUNCTION 'FKK_BP_LINE_ITEMS_SEL_LOGICAL'
    TABLES
      pt_logfkkop    = itab_fkkop
*     PT_WHERETAB    =
      tp_vkont_range = so_vkont
      tp_gpart_range = so_gpart
      tp_opbel_range = so_opbel
      tp_faedn_range = so_faedn
      tp_vtref_range = so_vtref.

*  Keine Ratenplanpositionen
  LOOP AT itab_fkkop.

* ------ Call event 5059 to delete position for submission
    PERFORM call_zp_fb_5059 TABLES    ht_fkkop_not_submitted
                             USING    itab_fkkop
                             CHANGING h_rel_instpln.

    READ TABLE ht_fkkop_not_submitted INDEX 1.
    IF sy-subrc EQ 0 OR
       ( itab_fkkop-stakz EQ 'R' AND
         h_rel_instpln EQ space ).
      DELETE itab_fkkop.
    ENDIF.

*  check authority for each position
    IF itab_fkkop-gpart NE h_gpart.
      PERFORM get_begru USING itab_fkkop-gpart
                              itab_fkkop-vkont
                     CHANGING h_begru.
    ENDIF.
    h_gpart = itab_fkkop-gpart.

    CALL FUNCTION 'FKK_DOC_AUTHORITY_CHECK'
      EXPORTING
        i_bukrs       = itab_fkkop-bukrs
        i_gsber       = itab_fkkop-gsber
        i_begru       = h_begru
        i_subap       = itab_fkkop-subap
        i_vtref       = itab_fkkop-vtref
        i_actvt       = '03'
      EXCEPTIONS
        error_message = 1
        OTHERS        = 2.
    IF sy-subrc NE 0.
*---- set flag for missing authority
      lv_xmiss_auth = 'X'.
*---- delete entry due to missing authority
      DELETE itab_fkkop.
    ENDIF.

  ENDLOOP.

* missing authority ?
  IF NOT lv_xmiss_auth IS INITIAL.
    MESSAGE s541(>1).
  ENDIF.

* Sind Einträger vorhanden
  DESCRIBE TABLE itab_fkkop LINES count.
  IF count = 0.
    IF lv_xmiss_auth IS INITIAL.
      MESSAGE s105(>3).
    ENDIF.
  ELSE.
    LOOP AT itab_fkkop.
      MOVE-CORRESPONDING itab_fkkop TO p_pos_wa.
**    nur abzugebende Posten (auch ausgebuchte möglich)
      IF p_xagapi = 'X'.
        IF p_pos_wa-inkps = 0.
          IF NOT p_xopwo IS INITIAL.
            CHECK itab_fkkop-augdt IS INITIAL OR
                  ( p_pos_wa-augrd CS '04' OR
                    p_pos_wa-augrd CS '14' ).
            IF p_pos_wa-augrd = '04' OR
              p_pos_wa-augrd = '14'.
              p_pos_wa-ausgeb = 'X'.
            ENDIF.
          ELSE.
            CHECK itab_fkkop-augdt IS INITIAL.
          ENDIF.
          PERFORM process_pos_4_req_drs USING itab_fkkop  CHANGING p_pos_wa.
          APPEND p_pos_wa TO p_pos_itab.
          CLEAR p_pos_wa.
        ENDIF.
      ELSE.
*      nur ausgebuchte Posten
        IF p_pos_wa-inkps = 0.
          IF p_xopwo = 'X'.
            CHECK ( p_pos_wa-augrd CS '04' OR
                    p_pos_wa-augrd CS '14' ).
            PERFORM process_pos_4_req_drs USING itab_fkkop  CHANGING p_pos_wa.
            p_pos_wa-ausgeb = 'X'.
            APPEND p_pos_wa TO p_pos_itab.
            CLEAR p_pos_wa.
          ENDIF.
        ENDIF.
      ENDIF.
**   abgegebene Posten (zusätzlich auch Abgabestatus und Abgabegrund)
      IF p_xagip = 'X'.
        IF p_pos_wa-inkps > 0.
          SELECT SINGLE inkps agsta aggrd inkgp FROM dfkkcoll
                    INTO CORRESPONDING FIELDS OF p_pos_wa
                       WHERE inkps = p_pos_wa-inkps
                       AND   opbel = p_pos_wa-opbel
                       AND   agsta IN so_agsta
                       AND   aggrd IN so_aggrd.
          IF sy-subrc EQ 0.
            PERFORM process_pos_4_req_drs USING itab_fkkop  CHANGING p_pos_wa.
*       Kurztext zum Abgabestatus reinschreiben
            CLEAR ls_dd07t.
            SELECT * FROM dd07t INTO ls_dd07t
               WHERE domname = 'AGSTA_KK'
                AND ddlanguage = sy-langu
                AND domvalue_l = p_pos_wa-agsta.
              p_pos_wa-agstatxt = ls_dd07t-ddtext.
            ENDSELECT.

*      Name zum Inkassobüro lesen
        SELECT SINGLE name_org1 FROM but000 INTO p_pos_wa-inkname
            WHERE partner = p_pos_wa-inkgp.

            APPEND p_pos_wa TO p_pos_itab.
            CLEAR  p_pos_wa.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.



*   Mahnstufe und Mahnverfahren prüfen

    LOOP AT pos_itab INTO pos_wa.

      IF NOT pos_wa-vtref IS INITIAL.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = pos_wa-vtref
          IMPORTING
            output = lv_vertrag.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lv_vertrag
          IMPORTING
            output = lv_vertrag.


        CLEAR ls_ever.
        SELECT SINGLE * FROM ever INTO ls_ever
          WHERE vertrag = lv_vertrag.

        IF   ls_ever-billfinit = 'X'.
          pos_wa-billfin = 'X'.
          MODIFY pos_itab FROM pos_wa
            TRANSPORTING billfin.
        ENDIF.

      ENDIF.

      CLEAR it_fkkmaze.
      SELECT * FROM fkkmaze INTO TABLE it_fkkmaze
        WHERE gpart = pos_wa-gpart
          AND vkont = pos_wa-vkont
          AND opbel = pos_wa-opbel
          AND opupw = pos_wa-opupw
          AND opupk = pos_wa-opupk
          AND opupz = pos_wa-opupz.

      IF sy-subrc = 0.
        SORT it_fkkmaze BY laufd DESCENDING.
        READ TABLE it_fkkmaze INTO wa_fkkmaze INDEX 1.

        IF sy-subrc = 0.
          MOVE wa_fkkmaze-mahnv TO pos_wa-mahnv.
          MOVE wa_fkkmaze-mahns TO pos_wa-mahns.

          MODIFY pos_itab FROM pos_wa
                        TRANSPORTING mahnv mahns.

        ENDIF.
      ENDIF.
    ENDLOOP.

    LOOP AT pos_itab INTO pos_wa.

*    Mahnstufe
      IF pos_wa-mahns IN so_mahns.
*   Do Nothing
      ELSE.
        DELETE TABLE pos_itab FROM pos_wa.
        CONTINUE.
      ENDIF.

      IF pos_wa-mahnv IN so_mahnv.
*  Do nothing
      ELSE.
        DELETE TABLE pos_itab FROM pos_wa.
        CONTINUE.
      ENDIF.
    ENDLOOP.

  ENDIF.

  DESCRIBE TABLE pos_itab LINES count.
  IF count = 0.
    MESSAGE s105(>3).
  ENDIF.



ENDFORM.                    " SELECT_DATA

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

*&---------------------------------------------------------------------*
*&      Form  PROCESS_POS_4_REQ_DRS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITAB_FKKOP  text
*      <--P_P_POS_WA  text
*----------------------------------------------------------------------*
FORM process_pos_4_req_drs USING    is_fkkop  TYPE fkkop
                           CHANGING cs_pos    TYPE t_tc_pos.

  DATA: lv_applk TYPE applk_kk,
        xrequest TYPE xfeld.
  STATICS: loct_6250 LIKE tfkfbc OCCURS 0 WITH HEADER LINE.

* check DRS is active
  CHECK gv_flg_drs_active EQ 'X'.

* determine the function module for event 6250
  IF loct_6250[] IS INITIAL.
    CALL FUNCTION 'FKK_GET_APPLICATION'
      IMPORTING
        e_applk = lv_applk
      EXCEPTIONS
        OTHERS  = 0.

    CALL FUNCTION 'FKK_FUNC_MODULE_DETERMINE'
      EXPORTING
        i_applk  = lv_applk
        i_fbeve  = '6250'
      TABLES
        t_fbstab = loct_6250.
    IF loct_6250[] IS INITIAL.
      CLEAR loct_6250.
      APPEND loct_6250.
    ENDIF.
  ENDIF.
* call event
  LOOP AT loct_6250 WHERE funcc NE space.
    CALL FUNCTION loct_6250-funcc
      EXPORTING
        i_fkkop    = is_fkkop
        i_source   = '1' "release manually
      IMPORTING
        e_xrequest = xrequest.

    cs_pos-rqs_drs = xrequest.

    SET EXTENDED CHECK OFF.
    IF 1 = 2. CALL FUNCTION 'FKK_SAMPLE_6250'. ENDIF.
    SET EXTENDED CHECK ON.
  ENDLOOP.

ENDFORM.                    " PROCESS_POS_4_REQ_DRS

*&---------------------------------------------------------------------*
*&      Form  ICON_CREATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM icon_create .

  IF pos_wa-inkps >= 998.
*   Special case: internal collection case
    CALL FUNCTION 'ICON_CREATE'
      EXPORTING
        name                  = 'ICON_BUSINAV_PROC_EXIST'
        info                  = text-008
      IMPORTING
        result                = pos_wa-status
      EXCEPTIONS
        icon_not_found        = 1
        outputfield_too_short = 2
        OTHERS                = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

* Abzugebende Posten
  ELSEIF pos_wa-inkps = 0    AND
         pos_wa-aggrd IS INITIAL AND
         pos_wa-inkgp IS INITIAL AND
         pos_wa-agsta IS INITIAL.

**post for release
    CALL FUNCTION 'ICON_CREATE'
      EXPORTING
        name                  = 'ICON_LED_GREEN'
        info                  = text-006
      IMPORTING
        result                = pos_wa-status
      EXCEPTIONS
        icon_not_found        = 1
        outputfield_too_short = 2
        OTHERS                = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
*released post
    CALL FUNCTION 'ICON_CREATE'
      EXPORTING
        name                  = 'ICON_LED_RED'
        info                  = text-007
      IMPORTING
        result                = pos_wa-status
      EXCEPTIONS
        icon_not_found        = 1
        outputfield_too_short = 2
        OTHERS                = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

ENDFORM.                    " ICON_CREATE


*&---------------------------------------------------------------------*
*&      Form  LAYOUT_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_LAYOUT  text
*----------------------------------------------------------------------*
FORM layout_build  USING  ls_layout TYPE slis_layout_alv.

  ls_layout-zebra = 'X'.
  ls_layout-colwidth_optimize = 'X'.
  ls_layout-box_fieldname = 'XSELP'.

ENDFORM.                    " LAYOUT_BUILD

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
  ls_fieldcat-fieldname = 'XSELP'.
  ls_fieldcat-tech      = 'X'.
  ls_fieldcat-tabname = 'POS_ITAB'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'SEL'.
  ls_fieldcat-tabname = 'POS_ITAB'.
  ls_fieldcat-edit = 'X'.
  ls_fieldcat-input = 'X'.
  ls_fieldcat-checkbox = 'X'.
  ls_fieldcat-seltext_s = 'Selektion'.
  ls_fieldcat-seltext_m = 'Selektion'.
  ls_fieldcat-seltext_l = 'Selektion'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Status-Icon für Status
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname   = 'STATUS'.
  ls_fieldcat-tabname     = 'POS_ITAB'.
  ls_fieldcat-icon        = 'X'.
  ls_fieldcat-seltext_s   = 'Status'.
  ls_fieldcat-seltext_m   = 'Status'.
  ls_fieldcat-seltext_l   = 'Status'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Geschäftspartnernummer
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'GPART'.
  ls_fieldcat-tabname = 'POS_ITAB'.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Vertragskonto
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'VKONT'.
  ls_fieldcat-tabname = 'POS_ITAB'.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Belegnummer
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'OPBEL'.
  ls_fieldcat-tabname = 'POS_ITAB'.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Inkassobüro
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'INKGP'.
  ls_fieldcat-tabname = 'POS_ITAB'.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-ref_tabname = 'DFKKCOLL'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Inkassobüro-Name
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'INKNAME'.
  ls_fieldcat-tabname = 'POS_ITAB'.
  ls_fieldcat-seltext_s = 'NameInkGP'.
  ls_fieldcat-seltext_m = 'Name Inkassobüro'.
  ls_fieldcat-seltext_l = 'Name Inkassobüro'.
  APPEND ls_fieldcat TO lt_fieldcat.


* Inkassoposition
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'INKPS'.
  ls_fieldcat-tabname = 'POS_ITAB'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Abgabestatus
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'AGSTA'.
  ls_fieldcat-tabname = 'POS_ITAB'.
  ls_fieldcat-ref_tabname = 'DFKKCOLL'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'AGSTATXT'.
  ls_fieldcat-tabname = 'POS_ITAB'.
  ls_fieldcat-seltext_s = 'TextStat'.
  ls_fieldcat-seltext_m = 'Text zum Status'.
  APPEND ls_fieldcat TO lt_fieldcat.


* Abgabegrund
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'AGGRD'.
  ls_fieldcat-tabname = 'POS_ITAB'.
  ls_fieldcat-ref_tabname = 'DFKKCOLL'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Mahnverfahren
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'MAHNV'.
  ls_fieldcat-tabname = 'POS_ITAB'.
  ls_fieldcat-ref_tabname = 'FKKMAZE'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Mahnstufe
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'MAHNS'.
  ls_fieldcat-tabname = 'POS_ITAB'.
  ls_fieldcat-ref_tabname = 'FKKMAZE'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Betrag
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BETRW'.
  ls_fieldcat-tabname = 'POS_ITAB'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Währung
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'WAERS'.
  ls_fieldcat-tabname = 'POS_ITAB'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Fälligkeit
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'FAEDN'.
  ls_fieldcat-tabname = 'POS_ITAB'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'OPUPW'.
  ls_fieldcat-tabname = 'POS_ITAB'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'OPUPK'.
  ls_fieldcat-tabname = 'POS_ITAB'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'OPUPZ'.
  ls_fieldcat-tabname = 'POS_ITAB'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Statistikkennzeichen
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'STAKZ'.
  ls_fieldcat-tabname = 'POS_ITAB'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Buchungsdatum
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BUDAT'.
  ls_fieldcat-tabname = 'POS_ITAB'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Belegdatum
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BLDAT'.
  ls_fieldcat-tabname = 'POS_ITAB'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Referenzbeleg
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'XBLNR'.
  ls_fieldcat-tabname = 'POS_ITAB'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Ausgleichsgrund
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'AUGRD'.
  ls_fieldcat-tabname = 'POS_ITAB'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Ausgebucht
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'AUSGEB'.
  ls_fieldcat-tabname = 'POS_ITAB'.
  ls_fieldcat-seltext_s = 'ausgeb.'.
  ls_fieldcat-seltext_m = 'ausgebucht'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Buchungskreis
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BUKRS'.
  ls_fieldcat-tabname = 'POS_ITAB'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Vertrag
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'VTREF'.
  ls_fieldcat-tabname = 'POS_ITAB'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  ls_fieldcat-hotspot = 'X'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Schlussabgerechnet
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BILLFIN'.
  ls_fieldcat-tabname = 'POS_ITAB'.
  ls_fieldcat-seltext_s = 'fakt.'.
  ls_fieldcat-seltext_m = 'fakturiert'.
  APPEND ls_fieldcat TO lt_fieldcat.


ENDFORM.                    " FIELDCAT_BUILD


*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_alv .

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
   EXPORTING
*     I_INTERFACE_CHECK                 = ' '
*     I_BYPASSING_BUFFER                = ' '
*     I_BUFFER_ACTIVE                   = ' '
     i_callback_program                = sy-repid
     i_callback_pf_status_set          = g_status
     i_callback_user_command           = g_user_command
*     I_CALLBACK_TOP_OF_PAGE            = ' '
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME                  =
*     I_BACKGROUND_ID                   = ' '
*     I_GRID_TITLE                      =
*     I_GRID_SETTINGS                   =
     is_layout                         =  gs_layout
     it_fieldcat                       =  gt_fieldcat[]
*     IT_EXCLUDING                      =
*     IT_SPECIAL_GROUPS                 =
*     IT_SORT                           =
*     IT_FILTER                         =
*     IS_SEL_HIDE                       =
*     I_DEFAULT                         = 'X'
*     I_SAVE                            = ' '
*     IS_VARIANT                        =
*     IT_EVENTS                         =
*     IT_EVENT_EXIT                     =
*     IS_PRINT                          =
*     IS_REPREP_ID                      =
*     I_SCREEN_START_COLUMN             = 0
*     I_SCREEN_START_LINE               = 0
*     I_SCREEN_END_COLUMN               = 0
*     I_SCREEN_END_LINE                 = 0
*     I_HTML_HEIGHT_TOP                 = 0

*     I_HTML_HEIGHT_END                 = 0
*     IT_ALV_GRAPHICS                   =
*     IT_HYPERLINK                      =
*     IT_ADD_FIELDCAT                   =
*     IT_EXCEPT_QINFO                   =
*     IR_SALV_FULLSCREEN_ADAPTER        =
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER           =
*     ES_EXIT_CAUSED_BY_USER            =
    TABLES
      t_outtab                          =  pos_itab
   EXCEPTIONS
     program_error                     = 1
     OTHERS                            = 2
            .
  IF sy-subrc <> 0.
    EXIT.
* Implement suitable error handling here
  ENDIF.


ENDFORM.                    " DISPLAY_ALV

*-----------------------------------------------------------------------
*    FORM PF_STATUS_SET
*-----------------------------------------------------------------------
*    ........
*-----------------------------------------------------------------------
*    --> extab
*-----------------------------------------------------------------------
FORM status_standard  USING extab TYPE slis_t_extab.

  SET PF-STATUS 'STANDARD_INKASSO' EXCLUDING extab.

ENDFORM.                    "status_standard

*---------------------------------------------------------------------*
*       FORM USER_COMMAND                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*       --> R_UCOMM                                                   *
*       --> RS_SELFIELD                                               *
*---------------------------------------------------------------------*
FORM user_command USING r_ucomm LIKE sy-ucomm
                  rs_selfield TYPE slis_selfield.

* Daten im ALV aktualisieren (wichtig für das Selektionsfeld)
  DATA: rev_alv TYPE REF TO cl_gui_alv_grid.

  rs_selfield-refresh = 'X'.

  CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
    IMPORTING
      e_grid = rev_alv.

  rev_alv->check_changed_data( ).

  READ TABLE pos_itab INTO pos_wa INDEX rs_selfield-tabindex.

  IF sy-ucomm = 'RELE'.

    PERFORM freigabe.

  ELSEIF sy-ucomm = 'UNDO'.

    PERFORM freigabe_ruecknahme.

  ELSE.

    CASE rs_selfield-fieldname.
      WHEN 'GPART'.
        SET PARAMETER ID 'BPA'  FIELD pos_wa-gpart.
        CALL TRANSACTION 'FPP3'.
      WHEN 'VKONT'.
        PERFORM view_vkont USING pos_wa-vkont
                                 pos_wa-gpart.
      WHEN 'OPBEL'.
        SET PARAMETER ID '80B' FIELD pos_wa-opbel.
        CALL TRANSACTION 'FPE3' AND SKIP FIRST SCREEN.
      WHEN 'INKGP'.
        SET PARAMETER ID 'BPA' FIELD pos_wa-inkgp.
        CALL TRANSACTION 'FPP3'.
      WHEN 'VTREF'.
        DATA: lv_applk TYPE applk_kk.
        CALL FUNCTION 'FKK_GET_APPLICATION'
          IMPORTING
            e_applk       = lv_applk
          EXCEPTIONS
            error_message = 1.
        "call event 1201 -> display contract object
        PERFORM event_1201(saplfkk_sec) USING lv_applk
                                              pos_wa-vtref.
    ENDCASE.

  ENDIF.

ENDFORM.                    "user_command

*&---------------------------------------------------------------------*
*&      Form  FREIGABE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM freigabe .

  DATA: itab_release  LIKE TABLE OF fkkop WITH HEADER LINE,
        itab_release_not_submitted LIKE TABLE OF fkkop,
        ht_pos       TYPE t_tc_pos OCCURS 0 WITH HEADER LINE,
        ht_dfkkcoll  LIKE TABLE OF dfkkcoll WITH HEADER LINE,
        h_tabix      LIKE sy-tabix,
        h_tfill      LIKE sy-tfill,
        lt_gpart     TYPE gpart_tab,
        ls_gpart     TYPE LINE OF gpart_tab,
        wa_release   TYPE fkkop,
        wa_pos       TYPE t_tc_pos,
        lx_error     TYPE xfeld,
        ls_dd07t     TYPE dd07t.

  CLEAR pos_itab_marked.
  REFRESH pos_itab_marked.
  PERFORM build_release_tab TABLES itab_release.

  CHECK NOT itab_release IS INITIAL.

* --Enqueue the business partner ---------------------------------------
  PERFORM dfkkop_enqueue.



* * init answer for popup for determination of collection agency
  CALL FUNCTION 'FKK_COLL_AG_SAMPLE_5060_INIT'.

*Tabelle t_fkkop muss gefüllt werden. Move-Corresponding von pos_itab
*-----------------------------------------------------------------------
  CALL FUNCTION 'FKK_RELEASE_FOR_COLLECT_AGENCY'
    EXPORTING
      i_aggrd               = const_aggrd_einzelabgabe
      i_xsimu               = ' '
      i_batch               = ' '
    TABLES
      t_fkkop               = itab_release
      t_fkkop_not_submitted = itab_release_not_submitted
      t_dfkkcoll            = ht_dfkkcoll
    EXCEPTIONS
      error                 = 1
      OTHERS                = 2.
  IF sy-subrc <> 0.
*      MESSAGE e513(>3) WITH 'FKK_RELEASE_FOR_COLLECT_AGENCY'.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    DESCRIBE TABLE itab_release_not_submitted.
    IF sy-tfill > 0.
      h_tfill = sy-tfill.
      DESCRIBE TABLE itab_release.
      MESSAGE w453(>3) WITH h_tfill sy-tfill.
    ENDIF.

*  pos_itab von itab_release modifizieren

    ht_pos[] = pos_itab[].

    LOOP AT itab_release.
      MOVE-CORRESPONDING itab_release TO pos_wa.
      READ TABLE ht_dfkkcoll WITH KEY opbel = pos_wa-opbel
                                      betrw = pos_wa-betrw
                                      inkps = pos_wa-inkps.
      IF sy-subrc EQ 0.
        pos_wa-agsta = ht_dfkkcoll-agsta.
        pos_wa-aggrd = ht_dfkkcoll-aggrd.
        pos_wa-inkgp = ht_dfkkcoll-inkgp.

        READ TABLE ht_pos WITH KEY opbel = pos_wa-opbel
                                   opupk = pos_wa-opupk
                                   opupw = pos_wa-opupw
                                   opupz = pos_wa-opupz.
        h_tabix = sy-tabix.

*     ICON auf ROT setzen
        CALL FUNCTION 'ICON_CREATE'
          EXPORTING
            name                  = 'ICON_LED_RED'
            info                  = text-007
          IMPORTING
            result                = pos_wa-status
          EXCEPTIONS
            icon_not_found        = 1
            outputfield_too_short = 2
            OTHERS                = 3.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

*       Kurztext zum Abgabestatus reinschreiben
        CLEAR ls_dd07t.
        SELECT * FROM dd07t INTO ls_dd07t
           WHERE domname = 'AGSTA_KK'
            AND ddlanguage = sy-langu
            AND domvalue_l = ht_dfkkcoll-agsta.
          pos_wa-agstatxt = ls_dd07t-ddtext.
        ENDSELECT.

*      Name zum Inkassobüro lesen
        SELECT SINGLE name_org1 FROM but000 INTO pos_wa-inkname
            WHERE partner = pos_wa-inkgp.


        MODIFY pos_itab FROM pos_wa INDEX h_tabix.
      ENDIF.
    ENDLOOP.

    COMMIT WORK.
  ENDIF.

*  * --- Dequeue all business partner ------------------------------------
  CALL FUNCTION 'FKK_OPEN_ITEM_DEQUEUE'.

ENDFORM.                    " FREIGABE
*&---------------------------------------------------------------------*
*&      Form  BUILD_RELEASE_TAB
*&---------------------------------------------------------------------*
*      POS_ITAB_MARKED    Tabelle mit den markierten
*                         Positionen (global)
*      <--P_ITAB_RELEASE  Posten, die abgegeben werden können
*----------------------------------------------------------------------*
FORM build_release_tab  TABLES  et_itab_release    STRUCTURE fkkop.

  DATA:  ht_fkkcoll TYPE TABLE OF dfkkcoll WITH HEADER LINE,
         wt_fkkop   LIKE fkkop OCCURS 0 WITH HEADER LINE,
         first_warn     TYPE c,
         first_warn_999 TYPE c.


  CLEAR: ht_enqtab, ht_enqtab[].
  REFRESH et_itab_release.

  CLEAR: first_warn, first_warn_999.


  LOOP AT pos_itab INTO pos_wa
     WHERE sel IS NOT INITIAL.
    APPEND pos_wa TO pos_itab_marked.
  ENDLOOP.

  LOOP AT pos_itab_marked.
    IF pos_itab_marked-inkps <> '999'.
*     Normal case: any value for INKPS
      CALL FUNCTION 'FKK_COLLECT_AGENCY_ITEM_SELECT'
        EXPORTING
          i_opbel        = pos_itab_marked-opbel
          ix_opbel       = 'X' "const_marked
          i_inkps        = pos_itab_marked-inkps
          ix_inkps       = 'X' "const_marked
        TABLES
          t_fkkcoll      = ht_fkkcoll
        EXCEPTIONS
          initial_values = 1
          not_found      = 2
          OTHERS         = 3.
      IF sy-subrc = 0.
        READ TABLE ht_fkkcoll INDEX 1.
        IF ht_fkkcoll-agsta = const_agsta_freigegeben.
          IF first_warn IS INITIAL.
            first_warn = const_marked.
            MESSAGE w492(>3) WITH pos_itab_marked-opbel space.
          ENDIF.
          CONTINUE.   " Go to next table entry
        ENDIF.
      ELSE.
        CLEAR et_itab_release.
        CALL FUNCTION 'FKK_BP_LINE_ITEM_SELECT_SINGLE'
          EXPORTING
            i_opbel = pos_itab_marked-opbel
            i_opupw = pos_itab_marked-opupw
            i_opupk = pos_itab_marked-opupk
            i_opupz = pos_itab_marked-opupz
          IMPORTING
            e_fkkop = et_itab_release.

        IF et_itab_release IS INITIAL AND
           pos_itab_marked-opupw NE '000'.
* select repetition positions
          CALL FUNCTION 'FKK_BP_LINE_ITEMS_SEL_LOGICAL'
            EXPORTING
              i_opbel     = pos_itab_marked-opbel
            TABLES
              pt_logfkkop = wt_fkkop.

          READ TABLE wt_fkkop INTO et_itab_release WITH KEY
                                      opbel = pos_itab_marked-opbel
                                      opupw = pos_itab_marked-opupw
                                      opupk = pos_itab_marked-opupk
                                      opupz = pos_itab_marked-opupz.
          REFRESH wt_fkkop.
        ENDIF.

        IF NOT et_itab_release IS INITIAL.

          APPEND et_itab_release.

          READ TABLE ht_enqtab WITH KEY gpart = et_itab_release-gpart.
          IF sy-subrc NE 0.
            ht_enqtab-gpart = et_itab_release-gpart.
            APPEND ht_enqtab.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSE.
*     FKKOP-INKPS = 999 shows that items is in collection case
      IF first_warn_999 IS INITIAL.
        first_warn_999 = const_marked.
        MESSAGE w505(>3) WITH pos_itab_marked-opbel.
      ENDIF.
      CONTINUE.   " Go to next table entry
    ENDIF.
  ENDLOOP.

ENDFORM.                    " BUILD_RELEASE_TAB

*&---------------------------------------------------------------------*
*&      Form  FREIGABE_RUECKNAHME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM freigabe_ruecknahme .

  DATA: itab_dfkkcoll LIKE TABLE OF dfkkcoll WITH HEADER LINE,
        itab_undo     LIKE TABLE OF pos_itab_marked WITH HEADER LINE,
        l_agsta       LIKE dfkkcoll-agsta,
        l_agdat       LIKE dfkkcoll-agdat,
        mode_delete   VALUE 'D'.

  CLEAR pos_itab_marked.
  REFRESH pos_itab_marked.

  LOOP AT pos_itab INTO pos_wa
   WHERE sel IS NOT INITIAL.
    APPEND pos_wa TO pos_itab_marked.
  ENDLOOP.

  LOOP AT pos_itab_marked.
    CLEAR: l_agsta, l_agdat.
* check that the status did not change
    SELECT SINGLE agsta agdat FROM dfkkcoll INTO (l_agsta, l_agdat)
                   WHERE opbel = pos_itab_marked-opbel
                     AND inkps = pos_itab_marked-inkps.

    IF l_agsta = const_agsta_freigegeben         OR
       l_agsta = const_agsta_storniert           OR
       l_agsta = const_agsta_recalled            OR
       ( ( l_agsta = const_agsta_cust_p_pay      OR
           l_agsta = const_agsta_p_paid          OR
           l_agsta = const_agsta_rel_erfolglos ) AND
           l_agdat IS INITIAL )                  AND
       pos_itab_marked-inkps > 0.

      READ TABLE itab_dfkkcoll
                WITH KEY opbel = pos_itab_marked-opbel
                         inkps = pos_itab_marked-inkps.
      IF sy-subrc NE 0.
        MOVE-CORRESPONDING: pos_itab_marked TO itab_dfkkcoll.
        APPEND itab_dfkkcoll.
      ENDIF.

      READ TABLE itab_undo
                WITH KEY opbel = pos_itab_marked-opbel
                         inkps = pos_itab_marked-inkps.
      IF sy-subrc NE 0.
        MOVE-CORRESPONDING pos_itab_marked TO itab_undo.
        APPEND itab_undo.
      ENDIF.

      READ TABLE ht_enqtab WITH KEY gpart = pos_itab_marked-gpart.
      IF sy-subrc NE 0.
        ht_enqtab-gpart = pos_itab_marked-gpart.
        APPEND ht_enqtab.
      ENDIF.
    ELSE.
      error = error + 1.
    ENDIF.

  ENDLOOP.

* -- Enqueue the business partner before changing table DFKKOP ---------
  PERFORM dfkkop_enqueue.

  IF NOT itab_dfkkcoll IS INITIAL.
    CALL FUNCTION 'FKK_DB_DFKKCOLL_MODE'
      EXPORTING
        i_mode    = mode_delete
      TABLES
        t_fkkcoll = itab_dfkkcoll
      EXCEPTIONS
        error     = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
      MESSAGE e845(>3) WITH 'DFKKCOLL'.
    ELSE.
*    insert collection agency history table
      PERFORM create_history TABLES itab_dfkkcoll
                                    t_history_coll.
    ENDIF.

    LOOP AT itab_undo.
      UPDATE dfkkop SET inkps = 0
                    WHERE opbel = itab_undo-opbel
                    AND   inkps = itab_undo-inkps.


      LOOP AT pos_itab INTO pos_wa
                       WHERE opbel = itab_undo-opbel
                         AND inkps = itab_undo-inkps.

        CLEAR pos_wa-inkgp.
        CLEAR pos_wa-inkname.
        CLEAR pos_wa-agsta.
        CLEAR pos_wa-aggrd.
        CLEAR pos_wa-agstatxt.

        pos_wa-inkps = 0.
*   ICON auf Rücknahme Freigabe setzen
        CALL FUNCTION 'ICON_CREATE'
          EXPORTING
            name                  = 'ICON_LED_GREEN'
            info                  = text-006
          IMPORTING
            result                = pos_wa-status
          EXCEPTIONS
            icon_not_found        = 1
            outputfield_too_short = 2
            OTHERS                = 3.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

        MODIFY pos_itab FROM pos_wa.
      ENDLOOP.

    ENDLOOP.

    COMMIT WORK.

* --- Dequeue all business partner ------------------------------------
    CALL FUNCTION 'FKK_OPEN_ITEM_DEQUEUE'.
  ENDIF.



ENDFORM.                    " FREIGABE_RUECKNAHME

*&---------------------------------------------------------------------*
*&      Form  CREATE_HISTORY
*&---------------------------------------------------------------------*

FORM create_history TABLES   p_t_coll  STRUCTURE dfkkcoll
                             p_t_history_coll STRUCTURE dfkkcollh.

  DATA: h_lfdnr LIKE dfkkcollh-lfdnr,
        ht_fkkcollh LIKE dfkkcollh OCCURS 0 WITH HEADER LINE.

  CLEAR: p_t_history_coll, p_t_history_coll[].

  LOOP AT p_t_coll.
    MOVE-CORRESPONDING p_t_coll TO p_t_history_coll.

    p_t_history_coll-aenam = sy-uname.
    p_t_history_coll-acpdt = sy-datlo.
    p_t_history_coll-acptm = sy-timlo.
    CLEAR p_t_history_coll-agsta.

    CALL FUNCTION 'FKK_DB_DFKKCOLLH_COUNT'
      EXPORTING
        i_opbel = p_t_history_coll-opbel
        i_inkps = p_t_history_coll-inkps
      IMPORTING
        e_count = h_lfdnr.

    IF p_t_history_coll-agsta GE '20'.
      CALL FUNCTION 'FKK_DB_DFKKCOLLH_SELECT'
        EXPORTING
          i_seltyp   = '2'
          i_opbel    = p_t_coll-opbel
          i_inkps    = p_t_coll-inkps
        TABLES
          t_fkkcollh = ht_fkkcollh
        EXCEPTIONS
          not_found  = 1
          OTHERS     = 2.

      READ TABLE ht_fkkcollh INDEX h_lfdnr.
      IF sy-subrc = 0.
        p_t_history_coll-agsta_or = ht_fkkcollh-agsta_or.
      ELSE.
        p_t_history_coll-agsta_or = p_t_history_coll-agsta.
      ENDIF.
    ELSE.
      p_t_history_coll-agsta_or = p_t_history_coll-agsta.
    ENDIF.

    ADD 1 TO h_lfdnr.

    p_t_history_coll-lfdnr = h_lfdnr.

    APPEND p_t_history_coll.
  ENDLOOP.

  CALL FUNCTION 'FKK_DB_DFKKCOLLH_INSERT'
    TABLES
      i_dfkkcollh = p_t_history_coll.

ENDFORM.                    " create_history

*&---------------------------------------------------------------------*
*&      Form  DFKKOP_ENQUEUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM dfkkop_enqueue .

  CALL FUNCTION 'FKK_OPEN_ITEM_ENQUEUE'
    TABLES
      t_enqtab = ht_enqtab.

  READ TABLE ht_enqtab INDEX 1.

  IF NOT ht_enqtab-xenqe IS INITIAL.
* dequeue to refresh internal lock tables
    CALL FUNCTION 'FKK_OPEN_ITEM_DEQUEUE'.
    CLEAR okcode.
    MESSAGE e499(>3) WITH ht_enqtab-gpart ht_enqtab-uname.
  ENDIF.

  IF NOT ht_enqtab-xenqm IS INITIAL.
* dequeue to refresh internal lock tables
    CALL FUNCTION 'FKK_OPEN_ITEM_DEQUEUE'.
    CLEAR okcode.
    MESSAGE e500(>3) WITH ht_enqtab-gpart.
  ENDIF.

ENDFORM.                    " DFKKOP_ENQUEUE

*&---------------------------------------------------------------------*
*&      Form  VIEW_VKONT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_POS_WA_GVKONT  text
*      -->P_POS_WA_GPART  text
*----------------------------------------------------------------------*
FORM view_vkont  USING    p_pos_wa_vkont
                          p_pos_wa_gpart.

  CHECK NOT p_pos_wa_vkont IS INITIAL.

  SET PARAMETER ID 'BPA' FIELD p_pos_wa_gpart.
  SET PARAMETER ID 'KTO' FIELD p_pos_wa_vkont.

  CALL FUNCTION 'FKK_ACCOUNT_CHANGE'
    EXPORTING
      i_vkont       = p_pos_wa_vkont
      i_gpart       = p_pos_wa_gpart
      i_ch_mode     = '1'
      i_no_other    = 'X'
      i_no_change   = 'X'
    EXCEPTIONS
      error_message = 1.
  IF sy-subrc = 1.
*   raises only in dialog
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.                    " VIEW_VKONT
*&---------------------------------------------------------------------*
*&      Form  MAHNZEILEN_LESEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*FORM mahnzeilen_lesen .

*  RANGES: lt_gpart FOR wa_fkkmaze-gpart,
*          lt_vkont for wa_fkkmaze-vkont,
*          lt_opbel for wa_fkkmaze-opbel,
*          lt_bukrs for wa_fkkmaze-bukrs,
*          lt_vtref for wa_fkkmaze-vtref.
*
*  SELECT * FROM fkkmaze INTO TABLE it_fkkmaze
*     WHERE laufd IN so_laufd
*      AND laufi IN so_laufi.
*
*  LOOP AT it_fkkmaze INTO wa_fkkmaze.
**   Geschäftspartner
*    lt_gpart-sign = 'I'.
*    lt_gpart-option = 'EQ'.
*    lt_gpart-low = wa_fkkmaze-gpart.
*    COLLECT lt_gpart.
*    CLEAR lt_gpart.
**   Vertragskonto
*    lt_vkont-sign = 'I'.
*    lt_vkont-option = 'EQ'.
*    lt_vkont-low = wa_fkkmaze-vkont.
*    COLLECT lt_vkont.
*    CLEAR lt_vkont.
**   Belegnummer
*    lt_opbel-sign = 'I'.
*    lt_opbel-option = 'EQ'.
*    lt_opbel-low = wa_fkkmaze-opbel.
*    COLLECT lt_opbel.
*    CLEAR lt_opbel.
**   Buchungskreis
*    lt_bukrs-sign = 'I'.
*    lt_bukrs-option = 'EQ'.
*    lt_bukrs-low = wa_fkkmaze-bukrs.
*    COLLECT lt_bukrs.
*    CLEAR lt_bukrs.
**   Vertrag
*    lt_vtref-sign = 'I'.
*    lt_vtref-option = 'EQ'.
*    lt_vtref-low = wa_fkkmaze-vtref.
*    COLLECT lt_vtref.
*    CLEAR lt_vtref.
*  ENDLOOP.
*
*so_gpart[] = lt_gpart[].
*so_vkont[] = lt_vkont[].
*so_opbel[] = lt_opbel[].
*so_vtref[] = lt_vtref[].
*so_bukrs[] = lt_bukrs[].

***ENDFORM.                    " MAHNZEILEN_LESEN
