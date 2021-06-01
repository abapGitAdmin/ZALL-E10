*&---------------------------------------------------------------------*
*& Report  /ADESSO/INKASSO_MONITOR_LS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT /adesso/inkasso_monitor_ls.


* Konstanten
CONSTANTS: const_aggrd_einzelabgabe  LIKE dfkkcoll-aggrd VALUE '06',
           const_agsta_freigegeben   LIKE dfkkcoll-agsta VALUE '01',
           const_agsta_storniert     LIKE dfkkcoll-agsta VALUE '05',
           const_agsta_recalled      LIKE dfkkcoll-agsta VALUE '09',
           const_agsta_cust_p_pay    LIKE dfkkcoll-agsta VALUE '11',
           const_agsta_p_paid        LIKE dfkkcoll-agsta VALUE '13',
           const_agsta_rel_erfolglos LIKE dfkkcoll-agsta VALUE '14',
           const_marked(1)           TYPE c VALUE 'X'.

CONSTANTS: c_prtio           TYPE sy-tabix VALUE 20000.
CONSTANTS: c_maxtb           TYPE sy-tabix VALUE 5.
CONSTANTS: c_maxtd           TYPE sy-tabix VALUE 10.

* ALV
TYPE-POOLS: slis.

DATA: g_repid        LIKE sy-repid,
      g_save         TYPE char1,
      g_exit         TYPE char1,
      gx_variant     LIKE disvariant,
      g_variant      LIKE disvariant,
      gs_layout      TYPE slis_layout_alv,
      gt_sort        TYPE slis_t_sortinfo_alv,
      gt_fieldcat    TYPE slis_t_fieldcat_alv,
      g_user_command TYPE slis_formname VALUE 'USER_COMMAND',
      g_status       TYPE slis_formname VALUE 'STATUS_STANDARD'.

DATA: gt_event      TYPE slis_t_event.
DATA: gs_listheader TYPE slis_listheader.
DATA: gt_listheader TYPE slis_listheader OCCURS 1.
DATA: x_lines TYPE i.
DATA: c_lines(10) TYPE c.

* Für Extrakt
DATA: h_ex LIKE ltex-exname.
DATA: h_extract TYPE disextract.
DATA: h_extadmin TYPE ltexadmin.

DATA: wa_fkkop    TYPE fkkop,
      wa_dfkkcoll TYPE dfkkcoll,
      wa_fkkmaze  TYPE fkkmaze.
*      it_fkkmaze TYPE STANDARD TABLE OF fkkmaze.

* Positionstabelle
DATA: pos_itab_marked TYPE TABLE OF /adesso/inkasso_out WITH HEADER LINE,
      ht_enqtab       LIKE ienqtab OCCURS 0 WITH HEADER LINE,
      t_history_coll  LIKE dfkkcollh OCCURS 0 WITH HEADER LINE.

DATA: wa_out  TYPE  /adesso/inkasso_out.
DATA: wa_tout TYPE  /adesso/inkasso_out.
DATA: ft_out TYPE TABLE OF /adesso/inkasso_out.
DATA: t_out  TYPE TABLE OF /adesso/inkasso_out.

DATA: wa_opt TYPE /adesso/inkasso_opt.

DATA:  error           TYPE i.
DATA:  okcode          LIKE sy-ucomm.

DATA: t_gpvk TYPE TABLE OF /adesso/inkasso_select.
DATA: t_select TYPE TABLE OF /adesso/inkasso_select.

DATA: BEGIN OF wa_tasks,
        name(40) TYPE c,
        count(4) TYPE n,
        low      TYPE sy-tabix,
        high     TYPE sy-tabix,
      END OF wa_tasks.
DATA: t_tasks  LIKE TABLE OF wa_tasks.
FIELD-SYMBOLS: <t_tasks> LIKE wa_tasks.
DATA: taskname LIKE wa_tasks-name.
DATA: taskcnt(4) TYPE n.

DATA: x_runts TYPE sy-tabix.
DATA: x_maxts TYPE sy-tabix.
DATA: x_uzeit TYPE sy-uzeit.
DATA: x_tabix      TYPE sy-tabix.
DATA: x_prtio      TYPE sy-tabix.


*************************************************************************
* Selektionsbildschirm
*************************************************************************

* Verarbeitungsmodus
SELECTION-SCREEN BEGIN OF BLOCK mod WITH FRAME TITLE text-005.
PARAMETERS: pa_showh RADIOBUTTON GROUP out.
PARAMETERS: pa_updhi RADIOBUTTON GROUP out.
PARAMETERS: pa_liste RADIOBUTTON GROUP out DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK mod.


SELECTION-SCREEN BEGIN OF BLOCK sel WITH FRAME TITLE text-001.
SELECT-OPTIONS: so_bukrs FOR wa_fkkop-bukrs NO-DISPLAY,
                so_gpart FOR wa_fkkop-gpart,
                so_vkont FOR wa_fkkop-vkont,
                so_vtref FOR wa_fkkop-vtref NO-DISPLAY,
                so_opbel FOR wa_fkkop-opbel NO-DISPLAY,
                so_faedn FOR wa_fkkop-faedn NO-DISPLAY,
                so_mahns FOR wa_fkkmaze-mahns NO-DISPLAY,
                so_mahnv FOR wa_fkkmaze-mahnv NO-DISPLAY.

SELECTION-SCREEN END OF BLOCK sel.


SELECTION-SCREEN BEGIN OF BLOCK opt WITH FRAME TITLE text-002.
PARAMETERS: p_xagapi AS CHECKBOX DEFAULT 'X',
            p_xopwo  AS CHECKBOX,
            p_xagip  AS CHECKBOX.

SELECT-OPTIONS: so_agsta FOR wa_dfkkcoll-agsta NO-DISPLAY,
                so_aggrd FOR wa_dfkkcoll-aggrd NO-DISPLAY.

SELECTION-SCREEN END OF BLOCK opt.

SELECTION-SCREEN BEGIN OF BLOCK vor WITH FRAME TITLE text-004.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(40) text-100.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(40) text-101.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(40) text-102.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK vor.



SELECTION-SCREEN BEGIN OF BLOCK inf WITH FRAME TITLE text-003.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(79) text-200.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(79) text-201.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(79) text-202.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(79) text-203.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(79) text-204.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(79) text-205.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK inf.




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
  wa_opt-xopwo = p_xopwo.
  wa_opt-xagip = p_xagip.

  PERFORM pre_select.

  WAIT UNTIL t_tasks IS INITIAL.

  PERFORM create_tasks.

  LOOP AT t_tasks ASSIGNING <t_tasks>.

    REFRESH t_select.

    APPEND LINES OF t_gpvk
      FROM <t_tasks>-low
        TO <t_tasks>-high
        TO t_select.

    CHECK t_select IS NOT INITIAL.

    ADD 1 TO x_runts.

    CALL FUNCTION 'Z_INKASSO_SELECT_LS'
      STARTING NEW TASK <t_tasks>-name
      DESTINATION IN GROUP DEFAULT
      PERFORMING ende_task ON END OF TASK
      EXPORTING
        x_opt                 = wa_opt
      TABLES
        it_select             = t_select
        et_out                = ft_out
      EXCEPTIONS
        communication_failure = 1
        system_failure        = 2
        resource_failure      = 3.

*    IF sy-subrc NE 0.
*      MESSAGE text-e04 TYPE 'E'.
*      STOP.
*    ENDIF.

    WAIT UNTIL x_runts < x_maxts.

  ENDLOOP.

  WAIT UNTIL t_tasks IS INITIAL.

*  LOOP AT pos_itab INTO pos_wa.
*    PERFORM icon_create.
*    MODIFY pos_itab FROM pos_wa TRANSPORTING status.
*  ENDLOOP.


**************************************************************************
* END-OF-SELECTION
**************************************************************************
END-OF-SELECTION.

  PERFORM layout_build USING gs_layout.
  PERFORM set_events.
  PERFORM fieldcat_build USING gt_fieldcat[].
  PERFORM alv_sortieren USING gt_sort[].
  PERFORM display_alv.




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

**  CLEAR ls_fieldcat.
**  ls_fieldcat-fieldname = 'XSELP'.
**  ls_fieldcat-tech      = 'X'.
**  ls_fieldcat-tabname = 'POS_ITAB'.
**  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'SEL'.
  ls_fieldcat-tabname = 'T_OUT'.
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
  ls_fieldcat-tabname     = 'T_OUT'.
  ls_fieldcat-icon        = 'X'.
  ls_fieldcat-seltext_s   = 'Status'.
  ls_fieldcat-seltext_m   = 'Status'.
  ls_fieldcat-seltext_l   = 'Status'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Geschäftspartnernummer
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'GPART'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Vertragskonto
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'VKONT'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Sparte
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'SPART'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Spartentext
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'VTEXT'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'TSPAT'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Hauptvorgang
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'HVORG'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Teilvorgang
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TVORG'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Teilvorgang (Text)
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TXT30'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'TFKTVOT'.
  APPEND ls_fieldcat TO lt_fieldcat.


* Belegnummer
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'OPBEL'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Inkassobüro
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'INKGP'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-ref_tabname = 'DFKKCOLL'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Inkassobüro-Name
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'INKNAME'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-seltext_s = 'NameInkGP'.
  ls_fieldcat-seltext_m = 'Name Inkassobüro'.
  ls_fieldcat-seltext_l = 'Name Inkassobüro'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Inkassoposition
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'INKPS'.
  ls_fieldcat-tabname = 'T_OUT'.
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
  ls_fieldcat-tabname = 'T_OUT'.
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
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'FKKMAZE'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Mahnstufe
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'MAHNS'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'FKKMAZE'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Betrag
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BETRW'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-do_sum = 'X'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Währung
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'WAERS'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Fälligkeit
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'FAEDN'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'OPUPW'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'OPUPK'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'OPUPZ'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Statistikkennzeichen
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'STAKZ'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Buchungsdatum
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BUDAT'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Belegdatum
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BLDAT'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Referenzbeleg
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'XBLNR'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Ausgleichsgrund
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'AUGRD'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Ausgebucht
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'AUSGEB'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-seltext_s = 'ausgeb.'.
  ls_fieldcat-seltext_m = 'ausgebucht'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Buchungskreis
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BUKRS'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Vertrag
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'VTREF'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'FKKOP'.
  ls_fieldcat-hotspot = 'X'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Schlussabgerechnet
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BILLFIN'.
  ls_fieldcat-tabname = 'T_OUT'.
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

  SORT t_out.
  DELETE ADJACENT DUPLICATES FROM t_out COMPARING ALL FIELDS.


  CASE 'X'.

    WHEN pa_showh.

      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
        EXPORTING
          i_callback_program       = sy-repid
          i_callback_pf_status_set = g_status
          i_callback_user_command  = g_user_command
          i_callback_top_of_page   = 'TOP_OF_PSAGE'
          is_layout                = gs_layout
          it_fieldcat              = gt_fieldcat[]
          it_sort                  = gt_sort
          it_events                = gt_event
        TABLES
          t_outtab                 = t_out
        EXCEPTIONS
          program_error            = 1
          OTHERS                   = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN pa_liste.

      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
        EXPORTING
          i_callback_program       = sy-repid
          i_callback_pf_status_set = g_status
          i_callback_user_command  = g_user_command
          i_callback_top_of_page   = 'TOP_OF_PSAGE'
          is_layout                = gs_layout
          it_fieldcat              = gt_fieldcat[]
          it_sort                  = gt_sort
          it_events                = gt_event
        TABLES
          t_outtab                 = t_out
        EXCEPTIONS
          program_error            = 1
          OTHERS                   = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN pa_updhi.
      PERFORM save_extract.

  ENDCASE.





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

  FIELD-SYMBOLS: <wa_out> LIKE wa_out.

  rs_selfield-refresh = 'X'.
  rs_selfield-col_stable = 'X'.

  CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
    IMPORTING
      e_grid = rev_alv.

  rev_alv->check_changed_data( ).

  READ TABLE t_out INTO wa_out INDEX rs_selfield-tabindex.

  IF sy-ucomm = 'RELE'.

    PERFORM freigabe.

  ELSEIF sy-ucomm = 'UNDO'.

    PERFORM freigabe_ruecknahme.

  ELSEIF sy-ucomm = 'MARK'.

    LOOP AT t_out ASSIGNING <wa_out>
      WHERE vkont = wa_out-vkont.
      <wa_out>-sel = 'X'.
    ENDLOOP.

  ELSEIF sy-ucomm = 'MARKALL'.
    LOOP AT t_out ASSIGNING <wa_out>.
      <wa_out>-sel = 'X'.
    ENDLOOP.

  ELSEIF sy-ucomm = 'DEMARK'.

    LOOP AT t_out ASSIGNING <wa_out>
      WHERE vkont = wa_out-vkont.
      <wa_out>-sel = ' '.
    ENDLOOP.

  ELSEIF sy-ucomm = 'DMALL'.

    LOOP AT t_out ASSIGNING <wa_out>.
      <wa_out>-sel = ' '.
    ENDLOOP.

** --> Nuss 24.11.2014 Erweiterung
  ELSEIF sy-ucomm = 'SETSTAT'.

    PERFORM set_status.

  ELSEIF sy-ucomm = 'DELSTAT'.

    PERFORM delete_status.

  ELSE.

    CASE rs_selfield-fieldname.
      WHEN 'GPART'.
        SET PARAMETER ID 'BPA'  FIELD wa_out-gpart.
        CALL TRANSACTION 'FPP3'.
      WHEN 'VKONT'.
        PERFORM view_vkont USING  wa_out-vkont
                                  wa_out-gpart.
      WHEN 'OPBEL'.
        SET PARAMETER ID '80B' FIELD  wa_out-opbel.
        CALL TRANSACTION 'FPE3' AND SKIP FIRST SCREEN.
      WHEN 'INKGP'.
        SET PARAMETER ID 'BPA' FIELD  wa_out-inkgp.
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
                                               wa_out-vtref.
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

  DATA: itab_release               LIKE TABLE OF fkkop WITH HEADER LINE,
        itab_release_not_submitted LIKE TABLE OF fkkop,
        ht_pos                     TYPE /adesso/inkasso_out OCCURS 0 WITH HEADER LINE,
        ht_dfkkcoll                LIKE TABLE OF dfkkcoll WITH HEADER LINE,
        h_tabix                    LIKE sy-tabix,
        h_tfill                    LIKE sy-tfill,
        lt_gpart                   TYPE gpart_tab,
        ls_gpart                   TYPE LINE OF gpart_tab,
        wa_release                 TYPE fkkop,
        wa_pos                     TYPE /adesso/inkasso_out,
        lx_error                   TYPE xfeld,
        ls_dd07t                   TYPE dd07t,
        ls_but000                  TYPE but000.

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

    ht_pos[] = t_out[].

    LOOP AT itab_release.
      MOVE-CORRESPONDING itab_release TO wa_out.
      READ TABLE ht_dfkkcoll WITH KEY opbel = wa_out-opbel
                                      betrw = wa_out-betrw
                                      inkps = wa_out-inkps.
      IF sy-subrc EQ 0.
        wa_out-agsta = ht_dfkkcoll-agsta.
        wa_out-aggrd = ht_dfkkcoll-aggrd.
        wa_out-inkgp = ht_dfkkcoll-inkgp.

        READ TABLE ht_pos WITH KEY opbel = wa_out-opbel
                                   opupk = wa_out-opupk
                                   opupw = wa_out-opupw
                                   opupz = wa_out-opupz.
        h_tabix = sy-tabix.

        wa_out-mahnv = ht_pos-mahnv.
        wa_out-mahns = ht_pos-mahns.

*     ICON auf ROT setzen
        CALL FUNCTION 'ICON_CREATE'
          EXPORTING
            name                  = 'ICON_LED_RED'
            info                  = text-007
          IMPORTING
            result                = wa_out-status
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
          wa_out-agstatxt = ls_dd07t-ddtext.
        ENDSELECT.

*      Name zum Inkassobüro lesen
        SELECT SINGLE name_org1 FROM but000 INTO wa_out-inkname
            WHERE partner = wa_out-inkgp.

*    Wenn ORG1 nicht gefüllt ist, prüfen, ob es eine Gruppe ist
        IF wa_out-inkname IS INITIAL.
          SELECT SINGLE name_grp1 FROM but000 INTO wa_out-inkname
            WHERE partner = wa_out-inkgp.
        ENDIF.

*    Letztendlich noch Vorname Nachname
        IF wa_out-inkname IS INITIAL.
          CLEAR ls_but000.
          SELECT SINGLE * FROM but000 INTO ls_but000
            WHERE partner = wa_out-inkgp.
          CONCATENATE ls_but000-name_first ls_but000-name_last
            INTO wa_out-inkname SEPARATED BY space.
        ENDIF.

        MODIFY t_out FROM wa_out INDEX h_tabix.
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

  DATA:  ht_fkkcoll     TYPE TABLE OF dfkkcoll WITH HEADER LINE,
         wt_fkkop       LIKE fkkop OCCURS 0 WITH HEADER LINE,
         first_warn     TYPE c,
         first_warn_999 TYPE c.


  CLEAR: ht_enqtab, ht_enqtab[].
  REFRESH et_itab_release.

  CLEAR: first_warn, first_warn_999.


  LOOP AT t_out INTO wa_out
     WHERE sel IS NOT INITIAL.
    APPEND wa_out TO pos_itab_marked.
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

  LOOP AT t_out INTO wa_out
   WHERE sel IS NOT INITIAL.
    APPEND wa_out TO pos_itab_marked.
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


      LOOP AT t_out INTO wa_out
                       WHERE opbel = itab_undo-opbel
                         AND inkps = itab_undo-inkps.

        CLEAR wa_out-inkgp.
        CLEAR wa_out-inkname.
        CLEAR wa_out-agsta.
        CLEAR wa_out-aggrd.
        CLEAR wa_out-agstatxt.

        wa_out-inkps = 0.
*   ICON auf Rücknahme Freigabe setzen
        CALL FUNCTION 'ICON_CREATE'
          EXPORTING
            name                  = 'ICON_LED_GREEN'
            info                  = text-006
          IMPORTING
            result                = wa_out-status
          EXCEPTIONS
            icon_not_found        = 1
            outputfield_too_short = 2
            OTHERS                = 3.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

        MODIFY t_out FROM wa_out.
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

  DATA: h_lfdnr     LIKE dfkkcollh-lfdnr,
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
FORM view_vkont  USING    p_pos_wa_vkont TYPE vkont_kk
                          p_pos_wa_gpart TYPE gpart_kk.

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


*&---------------------------------------------------------------------*
*&      Form  PRE_SELECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pre_select .

  SELECT gpart vkont FROM dfkkop INTO TABLE t_gpvk
    WHERE augst = space
      AND gpart IN so_gpart
      AND vkont IN so_vkont.

  SORT t_gpvk.

  DELETE ADJACENT DUPLICATES FROM t_gpvk.


ENDFORM.                    " PRE_SELECT
*&---------------------------------------------------------------------*
*&      Form  CREATE_TASKS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_tasks .

  CLEAR wa_tasks.
  wa_tout   = wa_out.


  DESCRIBE TABLE t_gpvk LINES x_tabix.
  CHECK x_tabix NE 0.

  IF x_tabix < 2000.
    x_prtio = x_tabix.
  ELSE.
    x_prtio = x_tabix / x_maxts.
    IF x_prtio > c_prtio.
      x_prtio = c_prtio.
    ENDIF.
  ENDIF.

  DO.
    wa_tasks-count = wa_tasks-count + 1.
    wa_tasks-low  = wa_tasks-high + 1.
    wa_tasks-high = wa_tasks-low  + x_prtio.
    CONCATENATE sy-repid wa_tasks-count
      INTO wa_tasks-name SEPARATED BY space.
    APPEND wa_tasks TO t_tasks.
    x_tabix = x_tabix - x_prtio.
    IF x_tabix <= 0.
      EXIT.
    ENDIF.
  ENDDO.



ENDFORM.                    " CREATE_TASKS
*&---------------------------------------------------------------------*
*&      Form  ENDE_TASK
*&---------------------------------------------------------------------*

FORM ende_task  USING taskname.

  RECEIVE RESULTS FROM FUNCTION 'Z_INKASSO_SELECT'
   TABLES
     et_out  = ft_out
    EXCEPTIONS
       communication_failure = 1
       system_failure        = 2.

  IF sy-subrc = 0.
    APPEND LINES OF ft_out TO t_out.

*   Lösche die Task aus der Tasktabelle
    DELETE t_tasks WHERE name = taskname.
    SUBTRACT 1 FROM x_runts.
  ELSE.
*    MESSAGE text-e04 TYPE 'E'.
*    STOP.
  ENDIF.


ENDFORM.                    " ENDE_TASK

*&---------------------------------------------------------------------*
*&      Form  ALV_SORTIEREN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_SORT[]  text
*----------------------------------------------------------------------*
FORM alv_sortieren  USING    lt_sort TYPE slis_t_sortinfo_alv..

  DATA: ls_sort TYPE slis_sortinfo_alv.

  CLEAR ls_sort.
  ls_sort-spos = 1.
  ls_sort-fieldname = 'VKONT'.
  ls_sort-up = 'X'.
  ls_sort-subtot = 'X'.
*  ls_sort-comp   = 'X'.
  APPEND ls_sort TO lt_sort.

  CLEAR ls_sort.
  ls_sort-spos = 2.
  ls_sort-fieldname = 'GPART'.
  ls_sort-up = 'X'.
*  ls_sort-subtot = 'X'.
*  ls_sort-comp   = 'X'.
  APPEND ls_sort TO lt_sort.

ENDFORM.                    " ALV_SORTIEREN

*&---------------------------------------------------------------------*
*&      Form  SET_EVENTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_events .

  DATA: ls_events TYPE slis_alv_event.
*
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'                      "#EC *
    EXPORTING
      i_list_type     = 4
    IMPORTING
      et_events       = gt_event
    EXCEPTIONS
      list_type_wrong = 1
      OTHERS          = 2.

  READ TABLE gt_event  WITH KEY name = slis_ev_top_of_page
                         INTO ls_events.
  IF sy-subrc = 0.
    MOVE slis_ev_top_of_page TO ls_events-form.
    MODIFY gt_event FROM ls_events INDEX sy-tabix.
  ENDIF.

ENDFORM.                    " SET_EVENTS


*&---------------------------------------------------------------------*
*&      Form  top_of_page
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM top_of_page.


  CLEAR: gs_listheader.
  REFRESH gt_listheader.

  DATA: anzahl TYPE string.

  DESCRIBE TABLE t_out LINES x_tabix.
  MOVE x_tabix TO anzahl.
  gs_listheader-typ  = 'S'.
*  gs_listheader-key  = 'Anzahl Posten:'.
  CONCATENATE anzahl 'Posten selektiert' INTO gs_listheader-info SEPARATED BY space.
  APPEND gs_listheader TO gt_listheader.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = gt_listheader.

ENDFORM.                    "top_of_page

*&---------------------------------------------------------------------*
*&      Form  SHOW_HISTORY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM show_history .

* Extraktname bilden ----------------------------------------
* Schlüssel zum Extract bilden
  h_extract-report = sy-repid.

* F4 Hilfe für Extraktselektion
  CALL FUNCTION 'REUSE_ALV_EXTRACT_AT_F4_P_EX2'
* EXPORTING
*   I_PARNAME_P_EXT2       = 'P_EXT2'
    CHANGING
      c_p_ex2     = h_ex
      c_p_ext2    = h_ex
      cs_extract2 = h_extract.

* Extract Laden
  CALL FUNCTION 'REUSE_ALV_EXTRACT_LOAD'
    EXPORTING
      is_extract         = h_extract
*>>> UH 11102012
    IMPORTING
      es_admin           = h_extadmin
*<<< UH 11102012
    TABLES
      et_exp01           = t_out
    EXCEPTIONS
      not_found          = 1
      wrong_relid        = 2
      no_report          = 3
      no_exname          = 4
      no_import_possible = 5
      OTHERS             = 6.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.



ENDFORM.                    " SHOW_HISTORY

*&---------------------------------------------------------------------*
*&      Form  SAVE_EXTRACT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_extract .

  DATA: h_extract TYPE disextract.

* Extraktname bilden ----------------------------------------
* Schlüssel zum Extract bilden
  CLEAR: h_extract.
* Programmname
  h_extract-report = sy-repid.
* Extrakt Text
  h_extract-text = text-009.
  DESCRIBE TABLE t_out LINES x_tabix.
  WRITE x_tabix TO h_extract-text+15 LEFT-JUSTIFIED.

  h_extract-text+25 = text-010.
  WRITE sy-uzeit TO h_extract-text+31 USING EDIT MASK '__:__:__'.

* Extrakt Name
  h_extract-exname   = sy-datum.
  h_extract-exname+8 = sy-uzeit.

  CALL FUNCTION 'REUSE_ALV_EXTRACT_SAVE'
    EXPORTING
      is_extract         = h_extract
      i_get_selinfos     = 'X'
    TABLES
      it_exp01           = t_out
    EXCEPTIONS
      wrong_relid        = 1
      no_report          = 2
      no_exname          = 3
      no_extract_created = 4
      OTHERS             = 5.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " SAVE_EXTRACT

*&---------------------------------------------------------------------*
*&      Form  SET_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_status .

  DATA:  ls_dd07t     TYPE dd07t.
  DATA: ls_dfkkcoll TYPE dfkkcoll.


  LOOP AT t_out INTO wa_out
     WHERE sel IS NOT INITIAL.

    CLEAR ls_dfkkcoll.

    CHECK wa_out-agsta IS INITIAL.

    wa_out-agsta = '99'.

*   Kurztext zum Abgabestatus reinschreiben
    CLEAR ls_dd07t.
    SELECT * FROM dd07t INTO ls_dd07t
       WHERE domname = 'AGSTA_KK'
        AND ddlanguage = sy-langu
        AND domvalue_l = '99'.
      wa_out-agstatxt = ls_dd07t-ddtext.
    ENDSELECT.

    IF sy-subrc NE 0.
      wa_out-agstatxt = 'Vorgemerkt'.
    ENDIF.

*     ICON auf ROT setzen
    CALL FUNCTION 'ICON_CREATE'
      EXPORTING
        name                  = 'ICON_LED_RED'
        info                  = text-007
      IMPORTING
        result                = wa_out-status
      EXCEPTIONS
        icon_not_found        = 1
        outputfield_too_short = 2
        OTHERS                = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.


    MOVE-CORRESPONDING wa_out TO ls_dfkkcoll.
    MODIFY dfkkcoll FROM ls_dfkkcoll.

    MODIFY t_out FROM wa_out.
  ENDLOOP.

ENDFORM.                    " SET_STATUS

*&---------------------------------------------------------------------*
*&      Form  DELETE_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_status .

  DATA: ls_dfkkcoll TYPE dfkkcoll.

  LOOP AT t_out INTO wa_out
   WHERE sel IS NOT INITIAL.

    CHECK wa_out-agsta = '99'.

    CLEAR wa_out-agstatxt.
    CLEAR wa_out-agsta.

    CALL FUNCTION 'ICON_CREATE'
      EXPORTING
        name                  = 'ICON_LED_GREEN'
        info                  = text-006
      IMPORTING
        result                = wa_out-status
      EXCEPTIONS
        icon_not_found        = 1
        outputfield_too_short = 2
        OTHERS                = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    SELECT * FROM dfkkcoll INTO ls_dfkkcoll
      WHERE opbel = wa_out-opbel.
      DELETE dfkkcoll FROM ls_dfkkcoll.
    ENDSELECT.

    MODIFY t_out FROM wa_out.


  ENDLOOP.

ENDFORM.                    " DELETE_STATUS
