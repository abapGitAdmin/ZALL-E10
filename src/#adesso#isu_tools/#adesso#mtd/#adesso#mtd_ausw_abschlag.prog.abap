*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTD_AUSW_ABSCHLAG
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT /ADESSO/MTD_AUSW_ABSCHLAG.

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

DATA: wa_eabp     TYPE eabp,
      it_eabp     TYPE STANDARD TABLE OF eabp,
      wa_ever     TYPE ever,
      it_ever     TYPE STANDARD TABLE OF ever,
      wa_tfk001at TYPE tfk001at.

DATA: y_obj  TYPE  isu25_budbilplan,
      y_auto TYPE isu25_budbilplan_auto.

DATA: wa_eabps TYPE eabps.

TABLES rea61.

* Ausgabetabelle
DATA: BEGIN OF wa_out,
        icon(30),
        ta(30),
        sd(30),
        opbel    TYPE opbel_kk,
        opupw    TYPE opupw_kk,
        opupk    TYPE opupk_kk,
        opupz    TYPE opupz_kk,
        bukrs    TYPE bukrs,
        vtref    TYPE vtref_kk,
        spart    TYPE spart_kk,
        vkont    TYPE vkont_kk,
        anlage   TYPE anlage,
        datum    TYPE sy-datum,
        gpart    TYPE gpart_kk,
        bldat    TYPE bldat,
        budat    TYPE budat_kk,
        faedn    TYPE faedn_kk,
        augst    TYPE augst_kk,
        augrd    TYPE augrd_kk,
        txt50    TYPE txt50,
        augbl    TYPE augbl_kk,
        augdt    TYPE augdt_kk,
        betro    TYPE betro_kk,
        betrw    TYPE betrw_kk,
        mwskz    TYPE mwskz,
        sbetw    TYPE sbetw_kk,
        waers    TYPE waers_kk,
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
SELECT-OPTIONS: so_vert FOR wa_ever-vertrag,
                so_abp  FOR wa_eabp-opbel,
                so_augrd FOR wa_tfk001at-augrd,
                so_vkont FOR wa_eabp-vkonto,
                so_gpart FOR wa_eabp-gpart.
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
*  PERFORM fieldcat_build USING gt_fieldcat[].
  PERFORM alv_sortieren USING gt_sort[].
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

  DATA: lt_fkkop TYPE STANDARD TABLE OF fkkop,
        ls_fkkop TYPE fkkop,
        l_sfkkop TYPE sfkkop.

  DATA: h_vertrag TYPE vertrag,
        h_anlage  TYPE anlage,
        h_vtref   TYPE vtref_kk,
        x_vtref   TYPE vtref_kk,
        h_datum   TYPE sy-datum.

*  DATA: BEGIN OF ls_fkkop_help,
*           augbl TYPE augbl_kk,
*           augdt TYPE augdt_kk,
*           betrw TYPE betrw_kk,
*           waers TYPE waers,
*           augrd TYPE augrd_kk,
*           augbd TYPE augbd_kk,
*        END OF ls_fkkop_help.
*  DATA: lt_fkkop_help LIKE STANDARD TABLE OF ls_fkkop_help.

* Verträge selektieren
  SELECT * FROM ever INTO TABLE it_ever
    WHERE  vertrag IN so_vert
      AND  sparte = p_spart
      AND  vkonto IN so_vkont
      AND einzdat LE sy-datum
      AND auszdat GE sy-datum.

* Abschlagspläne selektieren
  IF it_ever IS NOT INITIAL.
    SELECT * FROM eabp INTO TABLE it_eabp
       FOR ALL ENTRIES IN it_ever
         WHERE opbel IN so_abp
          AND  vkonto IN so_vkont
          AND  gpart  IN so_gpart
          AND  vertrag = it_ever-vertrag
          AND  deaktiv = space.
  ENDIF.

* Abschlagspläne abarbeieten
  LOOP AT it_eabp INTO wa_eabp.

    CALL FUNCTION 'ISU_S_BUDBILPLAN_PROVIDE'
      EXPORTING
        x_vertrag     = wa_eabp-vertrag
        x_opbel       = wa_eabp-opbel
        x_edatum      = sy-datum
        x_wmode       = '1'
*       X_EP_PERIOD   =
*       X_LOG_OBJECT  =
      IMPORTING
        y_obj         = y_obj
        y_auto        = y_auto
      EXCEPTIONS
        not_found     = 1
        foreign_lock  = 2
        general_fault = 3
        OTHERS        = 4.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

*   Nur die Abschlagszeilen aus der relevanten Sparte
    LOOP AT y_obj-ieabps INTO wa_eabps
      WHERE spart = p_spart.

*   Anlage aus dem Vertrag ermitteln.
      IF wa_eabps-vtref NE x_vtref.
        CLEAR: h_vertrag, h_anlage, h_datum.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = wa_eabps-vtref
          IMPORTING
            output = h_vertrag.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = h_vertrag
          IMPORTING
            output = h_vertrag.

        SELECT SINGLE anlage FROM ever INTO h_anlage
          WHERE vertrag = h_vertrag.
        wa_out-anlage = h_anlage.

        CALL FUNCTION 'ISU_BILLING_DATES_FOR_INSTLN'
          EXPORTING
            x_anlage          = h_anlage
*           X_DPC_MR          =
          IMPORTING
*           Y_BEGABRPE        =
*           Y_BEGNACH         =
*           Y_BEGEND          =
            y_last_endabrpe   = h_datum
*           Y_NEXT_CONTRACT   =
*           Y_PREVIOUS_BILL   =
*           Y_NO_CONTRACT     =
*           y_default_date    =
          EXCEPTIONS
            no_contract_found = 1
            general_fault     = 2
            parameter_fault   = 3
            OTHERS            = 4.

        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.

        MOVE h_datum TO wa_out-datum.


      ELSE.
        wa_out-anlage = h_anlage.
        wa_out-datum = h_datum.
      ENDIF.




      MOVE-CORRESPONDING wa_eabps TO wa_out.

      MOVE wa_eabps-augdt TO wa_out-bldat.
      MOVE wa_eabps-augbd TO wa_out-budat.
*     Text zum Ausgleichsgrund
      CLEAR wa_tfk001at.
      SELECT SINGLE * FROM tfk001at INTO wa_tfk001at
          WHERE spras = sy-langu
            AND augrd = wa_eabps-augrd.
      IF sy-subrc = 0.
        wa_out-txt50 = wa_tfk001at-txt50.
      ENDIF.
      IF wa_eabps-betro IS INITIAL.
        wa_out-icon = icon_green_light.
      ELSE.
        IF wa_out-faedn LT sy-datum.
          wa_out-icon = icon_red_light.
          IF wa_out-betro NE wa_out-betrw.
            wa_out-ta = icon_led_red.
          ENDIF.
        ELSE.
          wa_out-icon = icon_yellow_light.
        ENDIF.
      ENDIF.
*     Ausgleichsdatum vor dem Datum der letzten Abrechnung
      IF wa_out-augdt IS NOT INITIAL.
        IF wa_out-bldat LE wa_out-datum.
          wa_out-sd = icon_breakpoint.
        ENDIF.
*       Auch, wenn Belegdatum des Ausgleichsbelegs der Folgetag
*       der Abrechnung ist.
        IF wa_out-bldat - wa_out-datum LE 1.
          wa_out-sd = icon_breakpoint.
        ENDIF.
*      Solldatum liegt vor dem Abrechnungsdatum
        IF wa_eabps-solldat LT wa_out-datum.
          wa_out-sd = icon_breakpoint.
        ENDIF.
*      Warnung wenn der Betrag (BETRW) gleich Null ist
        IF wa_out-betrw = 0.
          wa_out-sd = icon_warning.
        ENDIF.

      ENDIF.
*     Mehrere Ausgleichsgründe und Ausgleichsbelege
      IF wa_eabps-augbl = '*'.
        MOVE-CORRESPONDING wa_eabps TO l_sfkkop.

*       Details bei Teilausgleichen
        CALL FUNCTION 'ISU_GET_ALL_PART_FKKOP'
          EXPORTING
            i_fkkop     = l_sfkkop
            i_obj       = y_obj-fkkwh
            i_keyselect = 'Y'
          TABLES
            o_fkkop     = lt_fkkop.

*        CLEAR: lt_fkkop_help, ls_fkkop_help.
*        LOOP AT lt_fkkop INTO ls_fkkop.
*          MOVE-CORRESPONDING ls_fkkop TO ls_fkkop_help.
*          COLLECT ls_fkkop_help INTO lt_fkkop_help.
*        ENDLOOP.


        LOOP AT lt_fkkop INTO ls_fkkop.
*        LOOP AT lt_fkkop_help INTO ls_fkkop_help.

*          MOVE-CORRESPONDING ls_fkkop TO wa_out.
          MOVE-CORRESPONDING wa_eabps TO wa_out.

          MOVE ls_fkkop-augrd TO wa_out-augrd.

          MOVE ls_fkkop-augdt TO wa_out-bldat.
          MOVE ls_fkkop-augbd TO wa_out-budat.

          MOVE ls_fkkop-augbl TO wa_out-augbl.
          MOVE ls_fkkop-betrw TO wa_out-betrw.
          MOVE ls_fkkop-augdt TO wa_out-augdt.

          MOVE h_datum TO wa_out-datum.
          MOVE h_anlage TO wa_out-anlage.

*         Text zum Ausgleichsgrund
          CLEAR wa_tfk001at.
          SELECT SINGLE * FROM tfk001at INTO wa_tfk001at
              WHERE spras = sy-langu
                AND augrd = ls_fkkop-augrd.
          IF sy-subrc = 0.
            wa_out-txt50 = wa_tfk001at-txt50.
          ENDIF.
*          IF wa_eabps-betro IS INITIAL.
          IF wa_eabps-augst = '9'.
            wa_out-icon = icon_green_light.
            IF wa_eabps-betro GT 0.
              wa_out-ta = icon_led_red.
            ELSE.
              wa_out-ta = icon_led_green.
            ENDIF.
          ELSE.
            IF wa_out-faedn LT sy-datum.
              wa_out-icon = icon_red_light.
            ELSE.
              wa_out-icon = icon_yellow_light.
            ENDIF.
          ENDIF.
*    Ausgleichsdatum vor dem Datum der letzten Abrechnung
          IF wa_out-augdt IS NOT INITIAL.
            IF wa_out-augdt LE wa_out-datum.
              wa_out-sd = icon_breakpoint.
            ENDIF.
*       Auch, wenn Ausgleichsdatum der Folgetag
*       der Abrechnung ist.
            IF wa_out-augdt - wa_out-datum LE 1.
              wa_out-sd = icon_breakpoint.
            ENDIF.
*      Solldatum liegt vor dem Abrechnungsdatum
        IF ls_fkkop-solldat LT wa_out-datum.
          wa_out-sd = icon_breakpoint.
        ENDIF.
*      Warnung wenn der Betrag (BETRW) gleich Null ist
            IF wa_out-betrw = 0.
              wa_out-sd = icon_warning.
            ENDIF.
          ENDIF.
*         Anhängen, wenn Ausgleichsgrung in Selektion
          IF wa_out-augrd IN so_augrd.
            APPEND wa_out TO it_out.
          ENDIF.
          CLEAR wa_out.
        ENDLOOP.
      ELSE.
*       Anhängen, wenn Ausgleichsgrund in Selektion
        IF wa_out-augrd IN so_augrd.
          APPEND wa_out TO it_out.
        ENDIF.
        CLEAR wa_out.
      ENDIF.

      x_vtref = wa_eabps-vtref.
    ENDLOOP.

  ENDLOOP.


ENDFORM.                    "select_data

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

ENDFORM.                    "layout_build

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

* Teilausgleich
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TA'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-icon = 'X'.
  ls_fieldcat-seltext_s = 'TA'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Stop-Zeichen
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'SD'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-icon = 'X'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Beleg
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'OPBEL'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-ref_tabname = 'EABPS'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Wiederholungsposition
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'OPUPW'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'EABPS'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Positionsnummer
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'OPUPK'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'EABPS'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Teilposition
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'OPUPZ'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'EABPS'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Buchungskreis
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BUKRS'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'EABPS'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Vertrag
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'VTREF'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-ref_tabname = 'EABPS'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Sparte
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'SPART'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'EABPS'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Vertragskonto
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'VKONT'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'EABPS'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Anlage
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'ANLAGE'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-ref_tabname = 'EVER'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Datum der letzten Abrechnung
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DATUM'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-seltext_s = 'Abr.Dat'.
  ls_fieldcat-seltext_m = 'Dat.Abrechnung'.
  APPEND ls_fieldcat TO lt_fieldcat.


* Geschäftspartner
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'GPART'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'EABPS'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Belegdatum
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BLDAT'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'EABPS'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Buchungsdatum
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BUDAT'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'EABPS'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Fälligkeitsdatum
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'FAEDN'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'EABPS'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Ausgleichsstatus
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'AUGST'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'EABPS'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Ausgleichsgrund
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'AUGRD'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'EABPS'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Text zum Ausglaiechsgrund
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TXT50'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'TFK001AT'.
  ls_fieldcat-seltext_s = 'Ausgl.Gr'.
  ls_fieldcat-seltext_m = 'Ausgleichsgrund'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Ausgleichsbeleg
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'AUGBL'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-ref_tabname = 'EABPS'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Ausgleichsdatum
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'AUGDT'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'EABPS'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Offener Betrag
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BETRO'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'EABPS'.
  ls_fieldcat-seltext_s = 'off.Betr'.
  ls_fieldcat-seltext_m = 'offener Betrag'.
  ls_fieldcat-do_sum = 'X'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Betrag in Transaktionswährung
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BETRW'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'EABPS'.
  ls_fieldcat-do_sum = 'X'.
  APPEND ls_fieldcat TO lt_fieldcat.


* Mehrwertsteuer-Kennzeichen
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'MWSKZ'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'EABPS'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Steuerbetrag
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'SBETW'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'EABPS'.
  ls_fieldcat-do_sum = 'X'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Währung
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'WAERS'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'EABPS'.
  APPEND ls_fieldcat TO lt_fieldcat.


ENDFORM.                    "fieldcat_build

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
          it_sort                 = gt_sort[]
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


ENDFORM.                    "display_alv

*&---------------------------------------------------------------------*
*&      Form  ALV_SORTIEREN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_SORT[]  text
*----------------------------------------------------------------------*
FORM alv_sortieren  USING lt_sort TYPE slis_t_sortinfo_alv..

  DATA: ls_sort TYPE slis_sortinfo_alv.


  CLEAR ls_sort.
  ls_sort-spos = 1.
  ls_sort-fieldname = 'AUGRD'.
  ls_sort-down = 'X'.
  ls_sort-subtot = 'X'.
  ls_sort-comp   = 'X'.
  APPEND ls_sort TO lt_sort.

  CLEAR ls_sort.
  ls_sort-spos = 2.
  ls_sort-fieldname = 'TXT50'.
*  ls_sort-down = 'X'.
  ls_sort-subtot = 'X'.
*  ls_sort-comp   = 'X'.
  APPEND ls_sort TO lt_sort.

ENDFORM.                    "alv_sortieren

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

ENDFORM.                    " SAVE_EXTRACT

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

    WHEN 'OPBEL'.

      CLEAR x_vertrag.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = wa_out-vtref
        IMPORTING
          output = x_vertrag.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = x_vertrag
        IMPORTING
          output = x_vertrag.


      CALL FUNCTION 'ISU_S_BUDBILPLAN_DISPLAY'
        EXPORTING
          x_vertrag      = x_vertrag
          x_opbel        = wa_out-opbel
          x_edatum       = sy-datum
          x_no_change    = 'X'
          x_no_other     = 'X'
        EXCEPTIONS
          not_found      = 1
          general_fault  = 2
          not_authorized = 3
          OTHERS         = 4.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.


    WHEN 'VTREF'.
      CLEAR x_vertrag.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = wa_out-vtref
        IMPORTING
          output = x_vertrag.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = x_vertrag
        IMPORTING
          output = x_vertrag.



      CALL FUNCTION 'ISU_S_CONTRACT_DISPLAY'
        EXPORTING
          x_vertrag = x_vertrag
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

*
*      SET PARAMETER ID 'VTG' FIELD x_vertrag.
*      CALL TRANSACTION 'ES22' AND SKIP FIRST SCREEN.


    WHEN 'AUGBL'.

      SET PARAMETER ID '80B' FIELD wa_out-augbl.
      CALL TRANSACTION 'FPE3' AND SKIP FIRST SCREEN.

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



  ENDCASE.

ENDFORM.                    "user_command
