*&---------------------------------------------------------------------*
*& Report  /ADESSO/SHOW_FILE_INKASSO
*&
*&---------------------------------------------------------------------*
REPORT /adesso/show_file_inkasso.

DATA: gf_title TYPE string.
DATA: gt_filet TYPE	filetable.
DATA: gf_rccnt TYPE	i.
DATA: gf_actio TYPE i.

DATA gt_fkkcolfile   TYPE TABLE OF fkkcolfile.
DATA gt_fkkcollp     TYPE TABLE OF fkkcollp.
DATA: gt_fkkcollp_ip TYPE TABLE OF fkkcollp_ip.         "Nuss 09.2017

DATA: BEGIN OF gs_data ,
        line(5000),
      END OF gs_data.
DATA: gt_data LIKE TABLE OF gs_data.

*ALV
DATA: gt_events     TYPE slis_t_event.
DATA: gt_listheader TYPE slis_t_listheader.
DATA: gs_listheader TYPE slis_listheader.

SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-b01.
PARAMETER p_rb1 TYPE c RADIOBUTTON GROUP butt DEFAULT 'X'.
PARAMETER p_rb2 TYPE c RADIOBUTTON GROUP butt.
PARAMETER p_rb3 TYPE c RADIOBUTTON GROUP butt.           "Nuss 09.2017
SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE text-b02.
PARAMETERS: p_source(1024) TYPE c LOWER CASE OBLIGATORY.
SELECTION-SCREEN END OF BLOCK bl2.

*----- Event AT SELECTION-SCREEN ON VALUE_REQUEST --------------------
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_source.

  gf_title = text-t01.
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = gf_title
    CHANGING
      file_table              = gt_filet
      rc                      = gf_rccnt
      user_action             = gf_actio
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.
  IF sy-subrc <> 0.
*        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  IF gf_rccnt > 1.
    MESSAGE e062(cacsib_edt).
  ELSE.
    IF NOT gf_rccnt < 1.
      LOOP AT gt_filet INTO p_source.
      ENDLOOP.
    ENDIF.
  ENDIF.

START-OF-SELECTION.

  PERFORM read_file TABLES gt_data USING p_source .


  PERFORM convert_file TABLES gt_data
                              gt_fkkcolfile
                              gt_fkkcollp
                              gt_fkkcollp_ip     "Nuss 09.2017
                       USING  p_rb1
                              p_rb2              "Nuss 09.2017
                              p_rb3 .            "Nuss 09.2017

END-OF-SELECTION.

*  PERFORM alv_set_events USING gt_events[].
  PERFORM output_alv TABLES gt_fkkcolfile
                            gt_fkkcollp
                            gt_fkkcollp_ip         "Nuss 09.2017
                     USING  p_rb1
                            p_rb2                 "Nuss 09.2017
                            p_rb3.                "Nuss 09.2017

FORM read_file   TABLES   p_lt_data STRUCTURE gs_data
                 USING    p_filename.

  TYPES: t_line       TYPE c LENGTH 5000.
  DATA:  lt_table    TYPE STANDARD TABLE OF t_line,
         wa_table    TYPE t_line,
         lv_filename TYPE string.

  lv_filename = p_filename.
  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = lv_filename
*     FILETYPE                = 'ASC'
*     HAS_FIELD_SEPARATOR     = SPACE
*     HEADER_LENGTH           = 0
*     READ_BY_LINE            = 'X'
*  IMPORTING
*     FILELENGTH              =
*     HEADER                  =
    CHANGING
      data_tab                = lt_table
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      not_supported_by_gui    = 17
      error_no_gui            = 18
      OTHERS                  = 19.
  IF sy-subrc <> 0.
    MESSAGE e113(cacsib_edt) WITH p_filename sy-subrc.
  ELSE.
    p_lt_data[] = lt_table[].
  ENDIF.

ENDFORM.                    " open_from_p

*&---------------------------------------------------------------------*
*&      Form  CONVERT_FILE
*&---------------------------------------------------------------------*
FORM convert_file  TABLES   ft_data       STRUCTURE gs_data
                            ft_fkkcolfile STRUCTURE fkkcolfile
                            ft_fkkcollp   STRUCTURE fkkcollp
                            ft_fkkcollp_ip  STRUCTURE fkkcollp_ip   "Nuss 09.2017
                   USING    fp_rb1
                            fp_rb2                                  "Nuss 09.2017
                            fp_rb3.                                 "Nuss 09.2017

  DATA: lf_lines TYPE sytabix.
  DATA: ls_data LIKE gs_data.
  DATA: ls_fkkcolfile TYPE fkkcolfile.
  DATA: ls_fkkcollp   TYPE fkkcollp.
  DATA: ls_fkkcollp_ip TYPE fkkcollp_ip.          "Nuss 09.2017

  DESCRIBE TABLE ft_data LINES lf_lines.
  LOOP AT ft_data INTO ls_data.
    CASE sy-tabix.
      WHEN 1.
        IF fp_rb1 = 'X'.
        ELSE.
        ENDIF.
      WHEN lf_lines.
        IF fp_rb1 = 'X'.
        ELSE.
        ENDIF.
      WHEN OTHERS.
        IF fp_rb1 = 'X'.
          ls_fkkcolfile = ls_data-line.
          APPEND ls_fkkcolfile TO ft_fkkcolfile.
*        ELSE.                                         "Nuss 09.2017
        ELSEIF fp_rb2 = 'X'.                           "Nuss 09.2017
          ls_fkkcollp = ls_data-line.
          APPEND ls_fkkcollp TO ft_fkkcollp.
* --> Nuss 09.2017
        ELSEIF fp_rb3 = 'X'.
          ls_fkkcollp_ip = ls_data-line.
          APPEND ls_fkkcollp_ip TO ft_fkkcollp_ip.
        ENDIF.
* <-- Nuss 09.2017
    ENDCASE.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  OUTPUT_ALV
*&---------------------------------------------------------------------*
FORM output_alv  TABLES ft_fkkcolfile STRUCTURE fkkcolfile
                        ft_fkkcollp   STRUCTURE fkkcollp
                        ft_fkkcollp_ip STRUCTURE fkkcollp_ip   "Nuss 09.2017
                 USING  fp_rb1
                        fb_rb2                                 "Nuss 09.2017
                        fb_rb3.                                "Nuss 09.2017

  CASE fp_rb1.
    WHEN space.
      CASE fb_rb2.  "Nuss 09.2017
        WHEN 'X'.   "Nuss 09.2017
          CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
            EXPORTING
              i_structure_name = 'FKKCOLLP'
              i_grid_title     = 'Inkasso Inbound Datei (Positionen)'
*             it_events        = gt_events
            TABLES
              t_outtab         = ft_fkkcollp.
**  --> Nuss 09.2017
        WHEN space.
          CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
            EXPORTING
              i_structure_name = 'FKKCOLLP_IP'
              i_grid_title     = 'Inkasso Infodatei (Positionen)'
*              it_events        = gt_events
            TABLES
              t_outtab         = ft_fkkcollp_ip.
      ENDCASE.
**  <-- Nuss 09.2017
    WHEN 'X'.
      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
        EXPORTING
          i_structure_name = 'FKKCOLFILE'
          i_grid_title     = 'Inkasso Outbound Datei (Positionen'
          it_events        = gt_events
        TABLES
          t_outtab         = ft_fkkcolfile.

  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ALV_SET_EVENTS
*&---------------------------------------------------------------------*
FORM alv_set_events  USING ft_events TYPE slis_t_event.

  DATA: ls_events TYPE slis_alv_event.
*
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'                      "#EC *
    EXPORTING
      i_list_type     = 4
    IMPORTING
      et_events       = ft_events
    EXCEPTIONS
      list_type_wrong = 1
      OTHERS          = 2.

  READ TABLE ft_events  WITH KEY name = slis_ev_top_of_page
                        INTO ls_events.
  IF sy-subrc = 0.
    MOVE slis_ev_top_of_page TO ls_events-form.
    MODIFY ft_events FROM ls_events INDEX sy-tabix.
  ENDIF.

ENDFORM.                    " ALV_SET_EVENTS

*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
FORM top_of_page .                                          "#EC *

*  clear: gs_listheader.
*  refresh gt_listheader.
*
*    gs_listheader-typ  = 'S'.
*    gs_listheader-key  = 'text-002'.
*    gs_listheader-info = 'XXXXX'.
*
*  call function 'REUSE_ALV_COMMENTARY_WRITE'
*    exporting
*      it_list_commentary = gt_listheader.

ENDFORM.                    " TOP_OF_PAGE
