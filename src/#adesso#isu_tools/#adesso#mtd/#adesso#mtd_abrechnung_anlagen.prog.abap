*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTD_ABRECHNUNG_ANLAGEN
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT /ADESSO/MTD_ABRECHNUNG_ANLAGEN.

*-----------------------------------------------------------------------
* ALV
*-----------------------------------------------------------------------
TYPE-POOLS: slis.

* Includes
INCLUDE <icon>.

DATA: gt_fieldcat     TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      gt_fieldcat_all TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      gs_layout       TYPE slis_layout_alv,
      gs_keyinfo      TYPE slis_keyinfo_alv,
      gt_sort         TYPE slis_t_sortinfo_alv WITH HEADER LINE,
      gt_sp_group     TYPE slis_t_sp_group_alv,
      g_user_command  TYPE slis_formname VALUE 'USER_COMMAND',
      g_status        TYPE slis_formname VALUE 'STATUS_STANDARD',
      gt_events       TYPE slis_t_event.

DATA: g_repid LIKE sy-repid.
DATA: gt_list_top_of_page TYPE slis_t_listheader.
DATA: g_tabname_header TYPE slis_tabname.
DATA: g_tabname_item   TYPE slis_tabname.
DATA: g_tabname_all    TYPE slis_tabname.
DATA: ls_fieldcat      TYPE slis_fieldcat_alv.

DATA: gs_listheader TYPE slis_listheader,
      gt_listheader TYPE slis_t_listheader.

DATA: gt_filtered TYPE slis_t_filtered_entries.
DATA: sav_ucomm   LIKE sy-ucomm.
DATA: block_line  LIKE sy-index.
DATA: block_beg   LIKE sy-index.
DATA: block_end   LIKE sy-index.

DATA: g_sort TYPE slis_t_sortinfo_alv WITH HEADER LINE.
DATA: rev_alv TYPE REF TO cl_gui_alv_grid.

DATA:    g_save     TYPE char1,
         g_exit     TYPE char1,
         gx_variant LIKE disvariant,
         g_variant  LIKE disvariant.

DATA: h_ex LIKE ltex-exname.
DATA: h_extract TYPE disextract.
DATA: h_extadmin TYPE ltexadmin.

DATA: x_tabix      TYPE sy-tabix.
DATA: x_uzeit      TYPE sy-uzeit.



DATA: wa_eanl     TYPE eanl,
      it_eanl     TYPE STANDARD TABLE OF eanl,
      wa_erch     TYPE erch,
      wa_ever     TYPE ever,
      wa_fkkvkp   TYPE fkkvkp,
      wa_ediscdoc TYPE ediscdoc.

DATA: h_datum TYPE sy-datum.
DATA: h_object TYPE edc_refkey.


DATA: BEGIN OF wa_out,
        icon(30),
        anlage    TYPE anlage,
        sparte    TYPE sparte,
        abrvorg   TYPE abrvorg,
        begabrpe  TYPE begabrpe,
        vkont     TYPE vkont_kk,
        gpart     TYPE gpart_kk,
        vertrag   TYPE vertrag,
        datum01   TYPE sy-datum,
        abrvorg01 TYPE abrvorg,
      END OF wa_out.
DATA: it_out LIKE STANDARD TABLE OF wa_out.


***********************************************************************
* Selektionsbildschirm
***********************************************************************
* Verarbeitungsmodus
SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE text-002.
PARAMETERS: pa_show RADIOBUTTON GROUP out.
PARAMETERS: pa_updex RADIOBUTTON GROUP out.
PARAMETERS: pa_liste RADIOBUTTON GROUP out DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK bl2.


SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-001.
PARAMETERS: p_spart TYPE sparte DEFAULT '05'.
SELECT-OPTIONS: so_anl FOR wa_eanl-anlage,
                so_abrv FOR wa_erch-abrvorg.
SELECTION-SCREEN END OF BLOCK bl1.

************************************************************************
* INITIALIZATION
************************************************************************
INITIALIZATION.
  PERFORM fieldcat_build USING gt_fieldcat[].

************************************************************************
* START-OF-SELECTION
************************************************************************
START-OF-SELECTION.

  GET TIME.
  x_uzeit = sy-uzeit.


  IF pa_show = 'X'.
    PERFORM show_history.
    STOP.
  ENDIF.

  PERFORM select_data.



************************************************************************
* end-OF-SELECTION
************************************************************************
END-OF-SELECTION.
  PERFORM layout_build USING gs_layout.
  PERFORM display_alv.


*&---------------------------------------------------------------------*
*&      Form  SELECT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM select_data .

  DATA: lt_erch TYPE STANDARD TABLE OF erch,
        ls_erch TYPE erch.


  SELECT * INTO CORRESPONDING FIELDS OF TABLE it_eanl
    FROM eanl INNER JOIN ever
       ON ever~anlage = eanl~anlage
    WHERE eanl~anlage IN so_anl
      AND eanl~sparte = p_spart
      AND ever~einzdat LE sy-datum
      AND ever~auszdat GE sy-datum.


  LOOP AT it_eanl INTO wa_eanl.

    wa_out-anlage = wa_eanl-anlage.
    wa_out-sparte = wa_eanl-sparte.

    CALL FUNCTION 'ISU_BILLING_DATES_FOR_INSTLN'
      EXPORTING
        x_anlage          = wa_eanl-anlage
*       X_DPC_MR          =
      IMPORTING
*       Y_BEGABRPE        =
*       Y_BEGNACH         =
*       Y_BEGEND          =
*       Y_LAST_ENDABRPE   =
*       Y_NEXT_CONTRACT   =
        y_previous_bill   = wa_erch
*       Y_NO_CONTRACT     =
        y_default_date    = h_datum
      EXCEPTIONS
        no_contract_found = 1
        general_fault     = 2
        parameter_fault   = 3
        OTHERS            = 4.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    CHECK wa_erch-abrvorg IN so_abrv.
    wa_out-abrvorg = wa_erch-abrvorg.
    wa_out-begabrpe = h_datum.

*   Bei Zwischenabrechnungen - letzte Turnusabrechnung holen
    IF wa_erch-abrvorg = '02'.
      CLEAR lt_erch.
      SELECT * FROM erch INTO TABLE lt_erch
        WHERE vertrag = wa_erch-vertrag
          AND abrvorg NE '02'
           AND erchc_v = 'X'
          AND stornodat = '00000000'.
      IF sy-subrc = 0.
        SORT lt_erch BY begabrpe DESCENDING.
        READ TABLE lt_erch INTO ls_erch INDEX 1.
        wa_out-datum01 = ( ls_erch-endabrpe + 1 ).
        wa_out-abrvorg01 = ls_erch-abrvorg.
      ENDIF.
    ENDIF.

    CLEAR wa_ever.
    SELECT SINGLE * FROM ever INTO wa_ever
      WHERE anlage = wa_eanl-anlage
        AND einzdat LE sy-datum
        AND auszdat GE sy-datum.

    CLEAR wa_fkkvkp.
    SELECT SINGLE * FROM fkkvkp INTO wa_fkkvkp
      WHERE vkont = wa_ever-vkonto.

    wa_out-vertrag = wa_ever-vertrag.
    wa_out-vkont = wa_fkkvkp-vkont.
    wa_out-gpart = wa_fkkvkp-gpart.

    CLEAR h_object.
    CONCATENATE wa_fkkvkp-vkont wa_fkkvkp-gpart INTO h_object.
    CLEAR wa_ediscdoc.
    SELECT * FROM ediscdoc INTO wa_ediscdoc
      WHERE refobjtype = 'ISUACCOUNT'
        AND refobjkey = h_object
        AND status = '21'.
      EXIT.
    ENDSELECT.

    IF sy-subrc = 0.
      wa_out-icon = icon_locked.
    ENDIF.


    APPEND wa_out TO it_out.
    CLEAR wa_out.



  ENDLOOP.

  SORT it_out BY abrvorg anlage.



ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_FIELDCAT[]  text
*----------------------------------------------------------------------*
FORM fieldcat_build  USING  lt_fieldcat TYPE slis_t_fieldcat_alv.

  DATA: ls_fieldcat TYPE slis_fieldcat_alv.

* ICON
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'ICON'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-icon = 'X'.
  ls_fieldcat-seltext_s = 'Status'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Anlage
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'ANLAGE'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-ref_tabname = 'EANL'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Sparte
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'SPARTE'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'EANL'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Abrechnungsvorgang
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'ABRVORG'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'ERCH'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Beginn Abrechnungsüeriode
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BEGABRPE'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'ERCH'.
  APPEND ls_fieldcat TO lt_fieldcat.


* Vertragskonto
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'VKONT'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'FKKVKP'.
  ls_fieldcat-hotspot = 'X'.
  APPEND ls_fieldcat TO lt_fieldcat.


* Geschäftspartner
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'GPART'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'FKKVKP'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Vertrag
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'VERTRAG'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-ref_tabname = 'EVER'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Datum01
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DATUM01'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-seltext_s = 'Datum 01'.
  ls_fieldcat-seltext_m = 'Datum Turnus'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Abrvorg01
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'ABRVORG01'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-seltext_s = 'Abrvorg'.
  ls_fieldcat-seltext_m = 'Abrechnungsvorg.'.
  APPEND ls_fieldcat TO lt_fieldcat.

ENDFORM.

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

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_alv .

  CASE 'X'.

    WHEN pa_show.
      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
        EXPORTING
          i_callback_program      = sy-repid
*         i_callback_pf_status_set = g_status
          i_callback_user_command = g_user_command
          is_layout               = gs_layout
          it_fieldcat             = gt_fieldcat[]
          it_sort                 = gt_sort[]
*         i_save                  = g_save
*         it_events               = gt_events
        TABLES
          t_outtab                = it_out
        EXCEPTIONS
          program_error           = 1
          OTHERS                  = 2.

      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.


    WHEN pa_liste.



      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
        EXPORTING
*         I_INTERFACE_CHECK       = ' '
*         I_BYPASSING_BUFFER      = ' '
*         I_BUFFER_ACTIVE         = ' '
          i_callback_program      = sy-repid
*         I_CALLBACK_PF_STATUS_SET          = ' '
          i_callback_user_command = g_user_command
*         I_CALLBACK_TOP_OF_PAGE  = ' '
*         I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*         I_CALLBACK_HTML_END_OF_LIST       = ' '
*         I_STRUCTURE_NAME        =
*         I_BACKGROUND_ID         = ' '
*         I_GRID_TITLE            =
*         I_GRID_SETTINGS         =
          is_layout               = gs_layout
          it_fieldcat             = gt_fieldcat[]
*         IT_EXCLUDING            =
*         IT_SPECIAL_GROUPS       =
*         it_sort                 = gt_sort[]
*         IT_FILTER               =
*         IS_SEL_HIDE             =
*         I_DEFAULT               = 'X'
*         I_SAVE                  = ' '
*         IS_VARIANT              =
*         IT_EVENTS               =
*         IT_EVENT_EXIT           =
*         IS_PRINT                =
*         IS_REPREP_ID            =
*         I_SCREEN_START_COLUMN   = 0
*         I_SCREEN_START_LINE     = 0
*         I_SCREEN_END_COLUMN     = 0
*         I_SCREEN_END_LINE       = 0
*         I_HTML_HEIGHT_TOP       = 0
*         I_HTML_HEIGHT_END       = 0
*         IT_ALV_GRAPHICS         =
*         IT_HYPERLINK            =
*         IT_ADD_FIELDCAT         =
*         IT_EXCEPT_QINFO         =
*         IR_SALV_FULLSCREEN_ADAPTER        =
*   IMPORTING
*         E_EXIT_CAUSED_BY_CALLER =
*         ES_EXIT_CAUSED_BY_USER  =
        TABLES
          t_outtab                = it_out
        EXCEPTIONS
          program_error           = 1
          OTHERS                  = 2.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

    WHEN pa_updex.

      PERFORM save_extract.


  ENDCASE.


ENDFORM.


*---------------------------------------------------------------------*
*       FORM USER_COMMAND                                             *
*---------------------------------------------------------------------*
FORM user_command USING r_ucomm LIKE sy-ucomm
                  rs_selfield TYPE slis_selfield.

  DATA: bdctab TYPE TABLE OF bdcdata.
  DATA: bdcline TYPE bdcdata.

  DATA: x_vertrag TYPE vertrag.

  READ TABLE it_out INTO wa_out INDEX rs_selfield-tabindex.

  CASE rs_selfield-fieldname.

*  Abschlagsplan



    WHEN 'VERTRAG'.



      CALL FUNCTION 'ISU_S_CONTRACT_DISPLAY'
        EXPORTING
          x_vertrag = wa_out-vertrag
*         X_UPD_ONLINE         =
*         X_NO_CHANGE          =
*         X_NO_OTHER           =
*       IMPORTING
*         Y_DB_UPDATE          =
*         Y_EXIT_TYPE          =
*         Y_NEW_EVER           =
*       EXCEPTIONS
*         NOT_FOUND = 1
*         KEY_INVALID          = 2
*         SYSTEM_ERROR         = 3
*         NOT_AUTHORIZED       = 4
*         OTHERS    = 5
        .
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.


    WHEN 'ANLAGE'.

      CALL FUNCTION 'ISU_S_INSTLN_DISPLAY'
        EXPORTING
          x_anlage  = wa_out-anlage
          x_keydate = sy-datum
*         X_UPD_ONLINE         =
*         X_NO_CHANGE          =
*         X_NO_OTHER           =
*       IMPORTING
*         Y_DB_UPDATE          =
*         Y_EXIT_TYPE          =
*       TABLES
*         YT_NEW_EANL          =
*       EXCEPTIONS
*         NOT_FOUND = 1
*         GENERAL_FAULT        = 2
*         NOT_AUTHORIZED       = 3
*         CANCELLED = 4
*         OTHERS    = 5
        .
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

    WHEN 'VKONT'.
      CALL FUNCTION 'ISU_S_ACCOUNT_DISPLAY'
        EXPORTING
          x_account = wa_out-vkont
          x_gpart   = wa_out-gpart
*         X_VALDT   =
*         X_UPD_ONLINE         =
*         X_NO_OTHER           =
*         X_NO_CHANGE          =
*       IMPORTING
*         Y_DB_UPDATE          =
*         Y_EXIT_TYPE          =
*       CHANGING
*         XY_NEW_ACC           =
*         XY_AUTO   =
*       EXCEPTIONS
*         NOT_FOUND = 1
*         FOREIGN_LOCK         = 2
*         INTERNAL_ERROR       = 3
*         INPUT_ERROR          = 4
*         OTHERS    = 5
        .
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.


  ENDCASE.

ENDFORM.                    "user_command


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
    IMPORTING
      es_admin           = h_extadmin
    TABLES
      et_exp01           = it_out
    EXCEPTIONS
      not_found          = 1
      wrong_relid        = 2
      no_report          = 3
      no_exname          = 4
      no_import_possible = 5
      OTHERS             = 6.

  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.


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
  DATA: h_tabix(10) TYPE c.
  DATA: h_time(8) TYPE c.

* Extraktname bilden ----------------------------------------
* Schlüssel zum Extract bilden
  CLEAR: h_extract.
* Programmname
  h_extract-report = sy-repid.
* Extrakt Text
  h_extract-text = text-003.
  DESCRIBE TABLE it_out LINES x_tabix.
  MOVE x_tabix TO h_tabix.
  CONCATENATE h_extract-text h_tabix INTO h_extract-text SEPARATED BY space.
*  WRITE x_tabix TO h_extract-text+8 LEFT-JUSTIFIED.

*  h_extract-text+25 = text-004.
  CONCATENATE h_extract-text text-004 INTO h_extract-text SEPARATED BY space.

*  WRITE x_uzeit TO h_extract-text+31 USING EDIT MASK '__:__:__'.
  WRITE x_uzeit TO h_time USING EDIT MASK '__:__:__'.

  CONCATENATE h_extract-text h_time INTO h_extract-text SEPARATED BY space.

* Extrakt Name
  h_extract-exname   = sy-datum.
  h_extract-exname+8 = sy-uzeit.

  CALL FUNCTION 'REUSE_ALV_EXTRACT_SAVE'
    EXPORTING
      is_extract         = h_extract
      i_get_selinfos     = 'X'
    TABLES
      it_exp01           = it_out
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


ENDFORM.
