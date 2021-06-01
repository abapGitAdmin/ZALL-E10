*&---------------------------------------------------------------------*
*& Report  Report /ADESSO/INKASSO_HIST_EVUZ
*&
*&---------------------------------------------------------------------*
REPORT /adesso/inkasso_hist_evuz.

TABLES: dfkkcollh.

DATA: gt_dfkkcollh   TYPE TABLE OF dfkkcollh.
DATA: gs_dfkkcollh   TYPE dfkkcollh.

DATA: gt_fieldcat    TYPE slis_t_fieldcat_alv.
DATA: gt_sort        TYPE slis_t_sortinfo_alv.

DATA: gs_fieldcat    TYPE slis_fieldcat_alv.
DATA: gs_sort        TYPE slis_sortinfo_alv.
DATA: gs_layout      TYPE slis_layout_alv.

DATA: g_repid        TYPE sy-repid.
DATA: g_tabname      TYPE slis_tabname.
DATA: g_struct       TYPE dd02l-tabname.
DATA: g_user_command TYPE slis_formname VALUE 'USER_COMMAND'.

TYPE-POOLS: slis.

SELECTION-SCREEN: BEGIN OF BLOCK alpha1 WITH FRAME TITLE TEXT-t01.
SELECT-OPTIONS: so_agsta FOR dfkkcollh-agsta DEFAULT '03' TO '20'.
SELECT-OPTIONS: so_rudat FOR dfkkcollh-rudat.
SELECT-OPTIONS: so_acpdt FOR dfkkcollh-acpdt.
SELECTION-SCREEN SKIP.
SELECT-OPTIONS: so_bukrs FOR dfkkcollh-bukrs.
SELECT-OPTIONS: so_gpart FOR dfkkcollh-gpart MATCHCODE OBJECT bupa.
SELECT-OPTIONS: so_vkont FOR dfkkcollh-vkont.
SELECT-OPTIONS: so_opbel FOR dfkkcollh-opbel MATCHCODE OBJECT fkdc.
SELECT-OPTIONS: so_inkgp FOR dfkkcollh-inkgp.
SELECT-OPTIONS: so_aggrd FOR dfkkcollh-aggrd.
SELECT-OPTIONS: so_agdat FOR dfkkcollh-agdat.
SELECTION-SCREEN: END OF BLOCK alpha1.


*-----------------------------------------------------------------------
* START-OF-SELECTION
*-----------------------------------------------------------------------
START-OF-SELECTION.

  AUTHORITY-CHECK OBJECT 'F_KKINK' ID 'ACTVT' FIELD '03'  "Display
                                   ID 'BRGRU' DUMMY.

  IF sy-subrc NE 0.
    MESSAGE e105(>2) WITH '03' TEXT-a01 'F_KKINK'.
  ENDIF.

  REFRESH: gt_dfkkcollh.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text = TEXT-001.


  SELECT * FROM dfkkcollh INTO TABLE gt_dfkkcollh
         WHERE gpart IN so_gpart
         AND   vkont IN so_vkont
         AND   bukrs IN so_bukrs
         AND   opbel IN so_opbel
         AND   inkgp IN so_inkgp
         AND   aggrd IN so_aggrd
         AND   agdat IN so_agdat
         AND   agsta IN so_agsta
         AND   rudat  IN so_rudat
         AND   acpdt  IN so_acpdt.

  SORT gt_dfkkcollh.

*-----------------------------------------------------------------------
* END-OF-SELECTION
*-----------------------------------------------------------------------
END-OF-SELECTION.

  IF sy-batch IS INITIAL.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        text = TEXT-002.
  ENDIF.

  PERFORM alv_init.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program      = g_repid
      i_callback_user_command = g_user_command
      is_layout               = gs_layout
      it_fieldcat             = gt_fieldcat[]
      it_sort                 = gt_sort[]
    TABLES
      t_outtab                = gt_dfkkcollh
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  ALV_INIT
*&---------------------------------------------------------------------*
FORM alv_init.

  g_repid    = sy-repid.
  g_tabname  = 'T_DFKKCOLLH'.
  g_struct   = 'DFKKCOLLH'.

* define layout
  CLEAR gs_layout.
  gs_layout-zebra             = 'X'.
  gs_layout-colwidth_optimize = 'X'.
  gs_layout-no_vline          = ' '.

  CLEAR gs_sort.
  gs_sort-spos = 1.
  gs_sort-fieldname = 'GPART'.
  gs_sort-up = 'X'.
*  ls_sort-subtot = 'X'.
*  ls_sort-comp   = 'X'.
  APPEND gs_sort TO gt_sort.

  CLEAR gs_sort.
  gs_sort-spos = 2.
  gs_sort-fieldname = 'VKONT'.
  gs_sort-up = 'X'.
*  ls_sort-subtot = 'X'.
*  ls_sort-comp   = 'X'.
  APPEND gs_sort TO gt_sort.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = g_repid
      i_structure_name       = g_struct
      i_client_never_display = 'X'
      i_bypassing_buffer     = 'X'
    CHANGING
      ct_fieldcat            = gt_fieldcat
    EXCEPTIONS
      OTHERS                 = 0.

**  Felder anpassen
  LOOP AT gt_fieldcat INTO gs_fieldcat.

    CASE gs_fieldcat-fieldname.
      WHEN 'GPART'.
        gs_fieldcat-hotspot     = 'X'.
        MODIFY gt_fieldcat INDEX sy-tabix FROM gs_fieldcat.
      WHEN 'VKONT'.
        gs_fieldcat-hotspot     = 'X'.
        MODIFY gt_fieldcat INDEX sy-tabix FROM gs_fieldcat.
      WHEN 'OPBEL'.
        gs_fieldcat-hotspot     = 'X'.
        MODIFY gt_fieldcat INDEX sy-tabix FROM gs_fieldcat.
      WHEN 'AUGBL'.
        gs_fieldcat-hotspot     = 'X'.
        MODIFY gt_fieldcat INDEX sy-tabix FROM gs_fieldcat.
      WHEN 'STORB'.
        gs_fieldcat-hotspot     = 'X'.
        MODIFY gt_fieldcat INDEX sy-tabix FROM gs_fieldcat.
    ENDCASE.

  ENDLOOP.

ENDFORM.


*---------------------------------------------------------------------*
*       FORM USER_COMMAND                                             *
*---------------------------------------------------------------------*
FORM user_command USING r_ucomm LIKE sy-ucomm
                rs_selfield TYPE slis_selfield.

  READ TABLE gt_dfkkcollh INTO gs_dfkkcollh INDEX rs_selfield-tabindex.

  rs_selfield-refresh = 'X'.
  rs_selfield-row_stable = 'X'.
  rs_selfield-col_stable = 'X'.

  CASE rs_selfield-fieldname.


     WHEN 'GPART'.
       PERFORM gp_anzeigen(saplfkk_sec) USING gs_dfkkcollh-gpart.

     WHEN 'VKONT'.
        PERFORM account_display(saplfkk_sec) USING gs_dfkkcollh-vkont.

    WHEN 'OPBEL'.
* display selected document
      SET PARAMETER ID '80B' FIELD gs_dfkkcollh-opbel.
      CALL FUNCTION 'FKK_FPE0_START_TRANSACTION'
        EXPORTING
          tcode              = 'FPE3'
          opbel              = gs_dfkkcollh-opbel
          i_calling_tcode    = 'FPE3'
          i_call_transaction = 'X'.

    WHEN 'AUGBL'.
* display selected document
      SET PARAMETER ID '80B' FIELD gs_dfkkcollh-augbl.
      CALL FUNCTION 'FKK_FPE0_START_TRANSACTION'
        EXPORTING
          tcode              = 'FPE3'
          opbel              = gs_dfkkcollh-augbl
          i_calling_tcode    = 'FPE3'
          i_call_transaction = 'X'.

    WHEN 'STORB'.
* display selected document
      SET PARAMETER ID '80B' FIELD gs_dfkkcollh-storb.
      CALL FUNCTION 'FKK_FPE0_START_TRANSACTION'
        EXPORTING
          tcode              = 'FPE3'
          opbel              = gs_dfkkcollh-storb
          i_calling_tcode    = 'FPE3'
          i_call_transaction = 'X'.


  ENDCASE.

ENDFORM.                    "user_command
