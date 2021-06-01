*&---------------------------------------------------------------------*
*& Report  /ADESSO/INKASSO_READ_FILE
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT /adesso/inkasso_read_file.

TABLES: dfkkcoli_log.
TABLES: dfkkcoll.

DATA: gt_coli_log  TYPE STANDARD TABLE OF dfkkcoli_log.
DATA: gt_collh_i_w TYPE STANDARD TABLE OF dfkkcollh_i_w.
DATA: gs_collh_i_w TYPE dfkkcollh_i_w.
DATA: gt_colfile_h TYPE STANDARD TABLE OF dfkkcolfile_h_w.
DATA: gs_colfile_h TYPE dfkkcolfile_h_w.
DATA: gt_ink_idat  TYPE STANDARD TABLE OF /adesso/ink_idat.
DATA: gs_ink_idat  TYPE /adesso/ink_idat.
DATA: gt_colfile   TYPE STANDARD TABLE OF dfkkcolfile_p_w.
DATA: gt_ink_infi  TYPE STANDARD TABLE OF /adesso/ink_infi.


DATA: gs_f4_selfield TYPE slis_selfield.

DATA: gt_fieldcat TYPE slis_t_fieldcat_alv.
DATA: gs_fieldcat TYPE slis_fieldcat_alv.
DATA: gs_layout   TYPE slis_layout_alv.
DATA: gs_sort     TYPE slis_sortinfo_alv.
DATA: gt_sort     TYPE slis_t_sortinfo_alv.

DATA: h_lines TYPE i.

CONSTANTS: gc_mark TYPE c VALUE 'X'.

* Selektionsbidschirm
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-t01.
SELECT-OPTIONS: so_inkgp FOR dfkkcoll-inkgp.
SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME  TITLE TEXT-t02.
PARAMETERS: p_coll RADIOBUTTON GROUP butt DEFAULT 'X'.
SELECT-OPTIONS: so_cldat FOR dfkkcoli_log-laufd.
SELECTION-SCREEN SKIP.
PARAMETERS: p_fpci RADIOBUTTON GROUP butt.
SELECT-OPTIONS: so_fldat FOR dfkkcoli_log-laufd.
SELECTION-SCREEN SKIP.
PARAMETERS: p_infi RADIOBUTTON GROUP butt.
SELECT-OPTIONS: so_ildat FOR dfkkcoli_log-laufd.
SELECTION-SCREEN END OF BLOCK bl2.

******************************************************************************************
* AT SELECTIO-SCREEN
******************************************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_cldat-low.
  PERFORM f4_for_cldat CHANGING so_cldat-low.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_fldat-low.
  PERFORM f4_for_fldat CHANGING so_fldat-low.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_ildat-low.
  PERFORM f4_for_ildat CHANGING so_ildat-low.

*******************************************************************************************
* START-OF-SELECTION
*******************************************************************************************
START-OF-SELECTION.

  AUTHORITY-CHECK OBJECT 'F_KKINK' ID 'ACTVT' FIELD 'B6'
                                   ID 'BRGRU' DUMMY.
  IF sy-subrc NE 0.
    MESSAGE e592(>3).
  ENDIF.

  CASE gc_mark.
    WHEN p_coll.
      PERFORM read_file_coll.
    WHEN p_fpci.
      PERFORM read_fpci_info.
    WHEN p_infi.
      PERFORM read_file_infi.
  ENDCASE.



************************************************************************************
* END-OF-SELECTION
************************************************************************************
END-OF-SELECTION.
  PERFORM display_alv.

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
FORM display_alv .

  DATA: lv_struct   TYPE dd02l-tabname.

  gs_layout-zebra = 'X'.
  gs_layout-colwidth_optimize = 'X'.


  CASE gc_mark.

    WHEN p_coll.

      REFRESH gt_sort.
      CLEAR gs_sort.
      gs_sort-spos = 1.
      gs_sort-fieldname = 'LAUFD'.
      APPEND gs_sort TO gt_sort.

      CLEAR gs_sort.
      gs_sort-spos = 2.
      gs_sort-fieldname = 'LAUFI'.
      APPEND gs_sort TO gt_sort.

      lv_struct = 'DFKKCOLFILE_P_W'.

      CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
        EXPORTING
          i_program_name         = sy-repid
          i_structure_name       = lv_struct
          i_client_never_display = 'X'
          i_bypassing_buffer     = 'X'
        CHANGING
          ct_fieldcat            = gt_fieldcat
        EXCEPTIONS
          inconsistent_interface = 1
          program_error          = 2
          OTHERS                 = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      LOOP AT gt_fieldcat INTO gs_fieldcat.

        CASE gs_fieldcat-fieldname.

          WHEN 'ZZNAME_RE'.
            gs_fieldcat-seltext_l  = 'Name RE'.
            gs_fieldcat-seltext_m  = 'Name RE'.
            gs_fieldcat-seltext_s  = 'Name RE'.
            MODIFY gt_fieldcat FROM gs_fieldcat.

          WHEN 'ZZNAME_CORE'.
            gs_fieldcat-seltext_l  = 'c/o RE'.
            gs_fieldcat-seltext_m  = 'c/o RE'.
            gs_fieldcat-seltext_s  = 'c/o RE'.
            MODIFY gt_fieldcat FROM gs_fieldcat.

          WHEN 'ZZSTREET_RE'.
            gs_fieldcat-seltext_l  = 'Straße RE'.
            gs_fieldcat-seltext_m  = 'Straße RE'.
            gs_fieldcat-seltext_s  = 'Straßeo RE'.
            MODIFY gt_fieldcat FROM gs_fieldcat.

          WHEN 'ZZCITY_RE'.
            gs_fieldcat-seltext_l  = 'Ort RE'.
            gs_fieldcat-seltext_m  = 'Ort RE'.
            gs_fieldcat-seltext_s  = 'Ort RE'.
            MODIFY gt_fieldcat FROM gs_fieldcat.

        ENDCASE.
      ENDLOOP.


      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
        EXPORTING
*         i_structure_name = 'DFKKCOLI_LOG'
          i_grid_title  = 'Abgabedatei: Abgabe an Inkasso-GP'
          is_layout     = gs_layout
          it_fieldcat   = gt_fieldcat[]
          it_sort       = gt_sort
        TABLES
          t_outtab      = gt_colfile
        EXCEPTIONS
          program_error = 1
          OTHERS        = 2.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

    WHEN p_fpci.

      REFRESH gt_sort.
      CLEAR gs_sort.
      gs_sort-spos = 1.
      gs_sort-fieldname = 'LAUFD'.
      APPEND gs_sort TO gt_sort.

      CLEAR gs_sort.
      gs_sort-spos = 2.
      gs_sort-fieldname = 'LAUFI'.
      APPEND gs_sort TO gt_sort.

      lv_struct = 'DFKKCOLI_LOG'.

      CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
        EXPORTING
          i_program_name         = sy-repid
          i_structure_name       = lv_struct
          i_client_never_display = 'X'
          i_bypassing_buffer     = 'X'
        CHANGING
          ct_fieldcat            = gt_fieldcat
        EXCEPTIONS
          inconsistent_interface = 1
          program_error          = 2
          OTHERS                 = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      LOOP AT gt_fieldcat INTO gs_fieldcat.

        CASE gs_fieldcat-fieldname.

          WHEN 'LAUFD'.
            gs_fieldcat-col_pos = 1.
            MODIFY gt_fieldcat FROM gs_fieldcat.

          WHEN 'LAUFI'.
            gs_fieldcat-col_pos = 2.
            MODIFY gt_fieldcat FROM gs_fieldcat.

          WHEN 'NRZAS'.
            gs_fieldcat-col_pos = 3.
            MODIFY gt_fieldcat FROM gs_fieldcat.

        ENDCASE.
      ENDLOOP.

      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
        EXPORTING
*         i_structure_name = 'DFKKCOLI_LOG'
          i_grid_title  = 'Infodatei: Infos an den Inkasso-GP'
          is_layout     = gs_layout
          it_fieldcat   = gt_fieldcat[]
          it_sort       = gt_sort
        TABLES
          t_outtab      = gt_coli_log
        EXCEPTIONS
          program_error = 1
          OTHERS        = 2.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

    WHEN p_infi.

      REFRESH gt_sort.
      CLEAR gs_sort.
      gs_sort-spos = 1.
      gs_sort-fieldname = 'INFODAT'.
      APPEND gs_sort TO gt_sort.

      CLEAR gs_sort.
      gs_sort-spos = 2.
      gs_sort-fieldname = 'SATZTYP'.
      APPEND gs_sort TO gt_sort.

      lv_struct = '/ADESSO/INK_INFI'.

      CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
        EXPORTING
          i_program_name         = sy-repid
          i_structure_name       = lv_struct
          i_client_never_display = 'X'
          i_bypassing_buffer     = 'X'
        CHANGING
          ct_fieldcat            = gt_fieldcat
        EXCEPTIONS
          inconsistent_interface = 1
          program_error          = 2
          OTHERS                 = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
        EXPORTING
*         i_structure_name = 'DFKKCOLI_LOG'
          i_grid_title  = 'Infodatei: Infos vom Inkasso-GP'
          is_layout     = gs_layout
          it_fieldcat   = gt_fieldcat[]
          it_sort       = gt_sort
        TABLES
          t_outtab      = gt_ink_infi
        EXCEPTIONS
          program_error = 1
          OTHERS        = 2.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.


  ENDCASE.


ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  READ_FPCI_INFO
*&---------------------------------------------------------------------*
FORM read_file_coll .

  SELECT * FROM dfkkcolfile_p_w
         INTO CORRESPONDING FIELDS OF TABLE gt_colfile
         WHERE laufd IN so_cldat
         AND   inkgp IN so_inkgp.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  READ_FPCI_INFO
*&---------------------------------------------------------------------*
FORM read_fpci_info .

  SELECT * FROM dfkkcollh_i_w AS h
         INNER JOIN dfkkcoli_log AS l
         ON l~laufd = h~laufd
         INTO CORRESPONDING FIELDS OF TABLE gt_coli_log
         WHERE h~laufd   IN so_fldat
         AND   h~w_inkgp IN so_inkgp.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  READ_FILE_INFI
*&---------------------------------------------------------------------*
FORM read_file_infi .

  SELECT * FROM /adesso/ink_idat AS d
         INNER JOIN /adesso/ink_infi AS i
         ON i~infodat = d~infodat
         INTO CORRESPONDING FIELDS OF TABLE gt_ink_infi
         WHERE d~mod_date IN so_ildat
         AND   i~inkgp    IN so_inkgp.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  F4_FOR_CLDAT
*&---------------------------------------------------------------------*
FORM f4_for_cldat  CHANGING fp_laufd.

  DATA: lv_title     TYPE char50.
  DATA: lv_tabname   TYPE char50 VALUE  'GT_COLFILE_H'.
  DATA: lv_structure TYPE tabname VALUE 'DFKKCOLFILE_H_W'.
  DATA: lv_exit.

  SELECT * FROM dfkkcolfile_h_w
         INTO TABLE gt_colfile_h
         WHERE inkgp IN so_inkgp.

  SORT gt_colfile_h BY laufd DESCENDING.
  lv_title = TEXT-col.

  CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
    EXPORTING
      i_title          = lv_title
      i_tabname        = lv_tabname
      i_structure_name = lv_structure
    IMPORTING
      es_selfield      = gs_f4_selfield
      e_exit           = lv_exit
    TABLES
      t_outtab         = gt_colfile_h.

  CHECK lv_exit = space.

  READ TABLE gt_colfile_h INTO gs_colfile_h INDEX gs_f4_selfield-tabindex.
  fp_laufd = gs_colfile_h-laufd.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F4_FOR_FLDAT
*&---------------------------------------------------------------------*
FORM f4_for_fldat  CHANGING fp_laufd.

  DATA: lv_title     TYPE char50.
  DATA: lv_tabname   TYPE char50  VALUE 'GT_COLLH_I_W'.
  DATA: lv_structure TYPE tabname VALUE 'DFKKCOLLH_I_W'.
  DATA: lv_exit.

  SELECT * FROM dfkkcollh_i_w
         INTO TABLE gt_collh_i_w
         WHERE inkgp IN so_inkgp.

  SORT gt_collh_i_w BY laufd DESCENDING.
  lv_title     =  TEXT-fpc.

  CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
    EXPORTING
      i_title          = lv_title
      i_tabname        = lv_tabname
      i_structure_name = lv_structure
    IMPORTING
      es_selfield      = gs_f4_selfield
      e_exit           = lv_exit
    TABLES
      t_outtab         = gt_collh_i_w.

  READ TABLE gt_collh_i_w INTO gs_collh_i_w INDEX gs_f4_selfield-tabindex.
  fp_laufd = gs_collh_i_w-laufd.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F4_FOR_ILDAT
*&---------------------------------------------------------------------*
FORM f4_for_ildat  CHANGING fp_laufd.

  DATA: lv_title     TYPE char50.
  DATA: lv_tabname   TYPE char50  VALUE 'GT_INK_IDAT'.
  DATA: lv_structure TYPE tabname VALUE '/ADESSO/INK_IDAT'.
  DATA: lv_exit.

  SELECT * FROM /adesso/ink_idat
         INTO TABLE gt_ink_idat
         WHERE inkgp IN so_inkgp.

  SORT gt_ink_idat BY mod_date DESCENDING.
  lv_title     =  TEXT-inf.

  CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
    EXPORTING
      i_title          = lv_title
      i_tabname        = lv_tabname
      i_structure_name = lv_structure
    IMPORTING
      es_selfield      = gs_f4_selfield
      e_exit           = lv_exit
    TABLES
      t_outtab         = gt_ink_idat.

  READ TABLE gt_ink_idat INTO gs_ink_idat INDEX gs_f4_selfield-tabindex.
  fp_laufd = gs_ink_idat-mod_date.

ENDFORM.
