*----------------------------------------------------------------------*
***INCLUDE /ADESSO/INKASSO_INFO_INKDL_F01.
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_alv .

  gs_layout-zebra = 'X'.
  gs_layout-colwidth_optimize = 'X'.

  PERFORM set_events.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      i_structure_name   = '/ADESSO/INK_INFI'
      is_layout          = gs_layout
      it_events          = gt_event
    TABLES
      t_outtab           = gt_ink_ialv
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  READ_FILE
*&---------------------------------------------------------------------*
FORM read_file TABLES ft_ink_infi STRUCTURE /adesso/ink_infi
               USING ff_dirname ff_filename.


  DATA: lf_dataset TYPE pathextern.

  CLEAR lf_dataset.
  CONCATENATE ff_dirname ff_filename INTO lf_dataset.

  REFRESH: ft_ink_infi.

*   Check if file is UTF-8
  TRY.
      CALL METHOD cl_abap_file_utilities=>check_utf8
        EXPORTING
          file_name = lf_dataset
          max_kb    = 0
        IMPORTING
          bom       = gv_file_bom
          encoding  = gv_file_encoding.

    CATCH  cx_sy_file_open
           cx_sy_file_authority
           cx_sy_file_io.
      CLEAR: gv_file_bom, gv_file_encoding.
  ENDTRY.

* Öffnen, um die Datei zu verarbeiten
  IF gv_file_bom      EQ cl_abap_file_utilities=>bom_utf8 AND
     gv_file_encoding EQ cl_abap_file_utilities=>encoding_utf8.
*   Read as UTF-8 character representation and skip BOM
    OPEN DATASET lf_dataset FOR INPUT
         IN TEXT MODE ENCODING UTF-8 SKIPPING BYTE-ORDER MARK
         WITH SMART LINEFEED.
  ELSE.
    OPEN DATASET lf_dataset FOR INPUT IN TEXT MODE ENCODING DEFAULT.
  ENDIF.
  IF sy-subrc GT 0.
    MESSAGE e800(29) WITH ff_filename.
  ENDIF.

* Verarbeitung der Datei
  DO.

    READ DATASET lf_dataset INTO p_string.
    IF sy-subrc NE 0.
      EXIT.
    ENDIF.

    MOVE p_string TO gs_ink_infi.
    APPEND gs_ink_infi TO gt_ink_infi.

    MOVE-CORRESPONDING gs_ink_infi TO gs_gpvk.
    COLLECT gs_gpvk INTO gt_gpvk.

  ENDDO.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UPDATE_INFOS
*&---------------------------------------------------------------------*
FORM update_infos TABLES   ft_ink_infi STRUCTURE /adesso/ink_infi
                  CHANGING ff_dbcnt ff_subrc.

  DATA: ls_ink_infi TYPE /adesso/ink_infi.

  ff_dbcnt = 0.
  ff_subrc = 0.

  READ TABLE ft_ink_infi INTO ls_ink_infi INDEX 1.
  CHECK sy-subrc = 0.

  INSERT /adesso/ink_infi FROM TABLE ft_ink_infi ACCEPTING DUPLICATE KEYS.
  CASE sy-subrc.
    WHEN 0.
      ff_dbcnt = sy-dbcnt.
      COMMIT WORK.
    WHEN OTHERS.
      ff_subrc = sy-subrc.
      ROLLBACK WORK.
      IF sy-batch = gc_mark.
        MESSAGE e010 WITH gs_ink_idat_alv-filename.
      ELSE.
        MESSAGE i010 WITH gs_ink_idat_alv-filename.
      ENDIF.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CREATE_CONTACT
*&---------------------------------------------------------------------*
FORM create_contact USING fs_ink_infi TYPE /adesso/ink_infi.

  DATA: lv_auto_data TYPE bpc01_bcontact_auto .
  DATA: lv_object    TYPE bpc_obj.
  DATA: lv_bpcontact TYPE ct_contact.
  DATA: lv_textline  TYPE bpc01_text_line.
  DATA: lv_but000    TYPE but000.

  DATA: lv_partner  TYPE but000-partner.
  DATA: lv_vkont    TYPE fkkvkp-vkont .
  DATA: lv_class    TYPE ct_cclass.
  DATA: lv_activity TYPE ct_activit.
  DATA: lv_type     TYPE ct_ctype.
  DATA: lv_coming   TYPE ct_coming.
  DATA: lv_funcc    TYPE funcc_kk.

  DATA: lv_text(20).
  DATA: lv_infodat(10).

  FIELD-SYMBOLS: <comp> TYPE any.
  DATA: BEGIN OF ls_value,
          descr(25),
          value(100),
        END OF ls_value.

  CASE fs_ink_infi-satztyp.
    WHEN 'I'.
      lv_text = TEXT-001.
    WHEN 'A'.
      lv_text = TEXT-003.
  ENDCASE.

* Kontaktklasse
  CLEAR gs_cust.
  READ TABLE gt_cust INTO gs_cust
    WITH KEY inkasso_option   = 'CONTACT'
             inkasso_category = 'CLASS'
             inkasso_field    = 'CCLASS'
             inkasso_id       = '1'.
  IF sy-subrc = 0.
    lv_class = gs_cust-inkasso_value.
  ELSE.
    lv_class = '0200'.
  ENDIF.

* Kontakt-Aktivität
  CLEAR gs_cust.
  READ TABLE gt_cust INTO gs_cust
    WITH KEY inkasso_option   = 'CONTACT'
             inkasso_category = 'INFO_INKDL'
             inkasso_field    = 'ACTIVITY'
             inkasso_id       = '1'.
  IF sy-subrc = 0.
    lv_activity = gs_cust-inkasso_value.
  ELSE.
    lv_activity = '0010'.
  ENDIF.

* Kontakt-Typ
  CLEAR gs_cust.
  READ TABLE gt_cust INTO gs_cust
    WITH KEY inkasso_option   = 'CONTACT'
             inkasso_category = 'TYPE'
             inkasso_field    = 'CTYPE'
             inkasso_id       = '1'.
  IF sy-subrc = 0.
    lv_type = gs_cust-inkasso_value.
  ELSE.
    lv_type = '002'.
  ENDIF.

* Richtung
  CLEAR gs_cust.
  READ TABLE gt_cust INTO gs_cust
    WITH KEY inkasso_option   = 'CONTACT'
             inkasso_category = 'DIRECTION'
             inkasso_field    = 'F_COMING'
             inkasso_id       = '1'.
  IF sy-subrc = 0.
    lv_coming = gs_cust-inkasso_value.
  ELSE.
    lv_coming = '2'.
  ENDIF.

  CLEAR: lv_auto_data.

  lv_vkont   = fs_ink_infi-vkont.
  lv_partner = fs_ink_infi-gpart.
  WRITE fs_ink_infi-infodat TO lv_infodat DD/MM/YYYY.

  lv_auto_data-bcontd-mandt       = sy-mandt.
  lv_auto_data-bcontd-partner     = lv_partner.
  lv_auto_data-bcontd-cclass      = lv_class.
  lv_auto_data-bcontd-activity    = lv_activity.
  lv_auto_data-bcontd-ctype       = lv_type.
  lv_auto_data-bcontd-ctdate      = sy-datum.
  lv_auto_data-bcontd-cttime      = sy-uzeit.
  lv_auto_data-bcontd-erdat       = sy-datum.
  lv_auto_data-bcontd-ernam       = sy-uname.
  lv_auto_data-text-langu         = sy-langu.
  lv_auto_data-bcontd_use         = 'X'.

*      Name zum Inkassobüro lesen
  SELECT SINGLE * FROM but000
         INTO lv_but000
         WHERE partner = fs_ink_infi-inkgp.

  CLEAR gs_cust.
  READ TABLE gt_cust INTO gs_cust
    WITH KEY inkasso_option   = 'CONTACT'
             inkasso_category = 'NAME_IGP'
             inkasso_field    = fs_ink_infi-inkgp.

  IF sy-subrc = 0.
*    CONCATENATE lv_infodat
    CONCATENATE lv_text
                fs_ink_infi-vkont
                TEXT-002
                lv_but000-partner
                gs_cust-inkasso_value
                INTO lv_textline-tdline
                SEPARATED BY space.
  ELSE.
*    CONCATENATE lv_infodat
    CONCATENATE lv_text
                fs_ink_infi-vkont
                TEXT-002
                lv_but000-partner
                lv_but000-name_org1
                lv_but000-name_first
                lv_but000-name_last
                lv_but000-name_grp1
                INTO lv_textline-tdline
                SEPARATED BY space.
  ENDIF.

  lv_textline-tdformat = '/'.
  APPEND lv_textline TO lv_auto_data-text-textt.

  LOOP AT gt_dd03m INTO gs_dd03m.
    ls_value-descr = gs_dd03m-scrtext_m.
    ASSIGN COMPONENT  gs_dd03m-fieldname OF STRUCTURE fs_ink_infi TO <comp>.
    IF gs_dd03m-domname = 'DATUM'.
      IF <comp> NE space.
        WRITE <comp> TO ls_value-value DD/MM/YYYY.
      ELSE.
        ls_value-value = <comp>.
      ENDIF.
    ELSE.
      ls_value-value = <comp>.
    ENDIF.

    IF ls_value-value NE space.
      lv_textline-tdformat = '/'.
      lv_textline-tdline = ls_value.
      APPEND lv_textline TO lv_auto_data-text-textt.
    ENDIF.
  ENDLOOP.

  lv_object-objrole = 'X00040002001'.
  lv_object-objtype = 'ISUACCOUNT'.
  CONCATENATE lv_vkont lv_partner INTO lv_object-objkey.
  APPEND lv_object TO lv_auto_data-iobjects.

* abweichender FuBa
  CLEAR gs_cust.
  READ TABLE gt_cust INTO gs_cust
    WITH KEY inkasso_option   = 'CONTACT'
             inkasso_category = 'FUBA'.

  IF sy-subrc = 0.
    lv_funcc = gs_cust-inkasso_value.

    CALL FUNCTION lv_funcc
      EXPORTING
        x_upd_online    = 'X'
        x_no_dialog     = 'X'
        x_auto          = lv_auto_data
        x_partner       = lv_partner
      IMPORTING
        y_new_bpcontact = lv_bpcontact
      EXCEPTIONS
        existing        = 1
        foreign_lock    = 2
        number_error    = 3
        general_fault   = 4
        input_error     = 5
        not_authorized  = 6
        OTHERS          = 7.

    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

  ELSE.

    CALL FUNCTION 'BCONTACT_CREATE'
      EXPORTING
        x_upd_online    = 'X'
        x_no_dialog     = 'X'
        x_auto          = lv_auto_data
        x_partner       = lv_partner
      IMPORTING
        y_new_bpcontact = lv_bpcontact
      EXCEPTIONS
        existing        = 1
        foreign_lock    = 2
        number_error    = 3
        general_fault   = 4
        input_error     = 5
        not_authorized  = 6
        OTHERS          = 7.

    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.
*------

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_EVENTS
*&---------------------------------------------------------------------*
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
FORM top_of_page.

  DATA: x_tabix     TYPE sy-tabix.
  DATA: c_lines(20) TYPE c.

  REFRESH: gt_listheader.

  LOOP AT gt_ink_idat_alv INTO gs_ink_idat_alv
       WHERE checkbox = gc_mark.
    gs_listheader-typ  = 'S'.
    gs_listheader-key  = gs_ink_idat_alv-vstatus.
    gs_listheader-info = gs_ink_idat_alv-filename.
    APPEND gs_listheader TO gt_listheader.
  ENDLOOP.


  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = gt_listheader.

ENDFORM.                    "top_of_page

*&---------------------------------------------------------------------*
*&      Form  GET_CUSTOMIZING
*&---------------------------------------------------------------------*
FORM get_customizing .

* Felder der Tabelle /ADESSO/INK_INFI
  SELECT * FROM dd03m
           INTO TABLE gt_dd03m
           WHERE tabname    = '/ADESSO/INK_INFI'
           AND   ddlanguage = sy-langu .

  SORT gt_dd03m BY position.

  LOOP AT gt_dd03m INTO gs_dd03m.
    CASE gs_dd03m-fieldname.
      WHEN 'MANDT'.
        DELETE gt_dd03m.
      WHEN 'SATZTYP'.
        DELETE gt_dd03m.
      WHEN 'INFODAT'.
        DELETE gt_dd03m.
      WHEN 'OPBEL'.
        DELETE gt_dd03m.
      WHEN 'INKPS'.
        DELETE gt_dd03m.
      WHEN 'INKGP'.
        DELETE gt_dd03m.
      WHEN 'GPART'.
        DELETE gt_dd03m.
      WHEN 'VKONT'.
        DELETE gt_dd03m.
    ENDCASE.
  ENDLOOP.

* Customizing Kontakte
  SELECT * FROM /adesso/ink_cust
     APPENDING TABLE gt_cust
     WHERE inkasso_option = 'CONTACT'.

* Customizing interner Vermerk
  SELECT * FROM /adesso/ink_cust
     APPENDING TABLE gt_cust
     WHERE inkasso_option = 'INTVERM'.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_NEW_FILES
*&---------------------------------------------------------------------*
FORM get_new_files TABLES ft_ink_idat_alv STRUCTURE /adesso/ink_idat_alv
                   USING  fp_dir_name.

  DATA: lt_file LIKE TABLE OF gs_file.
  DATA: ls_file LIKE gs_file.
  DATA: ls_ink_idat_alv TYPE /adesso/ink_idat_alv.
  DATA: lt_ink_neu_alv TYPE TABLE OF /adesso/ink_idat_alv.

  REFRESH lt_file.
  PERFORM get_file_list TABLES lt_file
                        USING  fp_dir_name.

  SORT lt_file BY filename.
  SORT ft_ink_idat_alv BY filename.
  LOOP AT lt_file INTO ls_file.
    READ TABLE ft_ink_idat_alv
         WITH KEY filename = ls_file-filename
         TRANSPORTING NO FIELDS
         BINARY SEARCH.
    IF sy-subrc NE 0.
      MOVE-CORRESPONDING ls_file TO ls_ink_idat_alv.
      ls_ink_idat_alv-vstatus  = 'NEU'.
      ls_ink_idat_alv-checkbox = 'X'.
      APPEND ls_ink_idat_alv TO lt_ink_neu_alv.
    ENDIF.
  ENDLOOP.

  REFRESH ft_ink_idat_alv.
  APPEND LINES OF lt_ink_neu_alv TO ft_ink_idat_alv.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_FILE_LIST
*&---------------------------------------------------------------------*
FORM get_file_list TABLES ft_file STRUCTURE gs_file
                   USING  fp_dir_name.


  DATA: sap_yes(1) VALUE 'X',
        sap_no(1)  VALUE ' '.

  DATA: ls_file LIKE gs_file.

  DATA: errcnt(2) TYPE p VALUE 0.

  IF fp_dir_name IS INITIAL.
    MESSAGE e220.     " 'Place cursor on valid line !'.
  ENDIF.

  CALL 'C_DIR_READ_FINISH'             " just to be sure
      ID 'ERRNO'  FIELD ls_file-errno
      ID 'ERRMSG' FIELD ls_file-errmsg.

  CALL 'C_DIR_READ_START' ID 'DIR'    FIELD fp_dir_name
                          ID 'ERRNO'  FIELD ls_file-errno
                          ID 'ERRMSG' FIELD ls_file-errmsg.
  IF sy-subrc <> 0.
    sy-subrc = 4.
    EXIT.
  ENDIF.

  DO.
    CLEAR ls_file.
    CALL 'C_DIR_READ_NEXT'
      ID 'TYPE'   FIELD ls_file-type
      ID 'NAME'   FIELD ls_file-filename
      ID 'LEN'    FIELD ls_file-len
      ID 'OWNER'  FIELD ls_file-owner
      ID 'MTIME'  FIELD ls_file-mtime
      ID 'MODE'   FIELD ls_file-mode
      ID 'ERRNO'  FIELD ls_file-errno
      ID 'ERRMSG' FIELD ls_file-errmsg.
    ls_file-dirname = fp_dir_name.
    MOVE sy-subrc TO ls_file-subrc.
    CASE sy-subrc.
      WHEN 0.
        CLEAR: ls_file-errno, ls_file-errmsg.
        CASE ls_file-type(1).
          WHEN 'F'.                 " normal file.
            PERFORM filename_useable USING ls_file-filename ls_file-useable.
          WHEN 'f'.                 " normal file.
            PERFORM filename_useable USING ls_file-filename ls_file-useable.
          WHEN OTHERS.              " directory, device, fifo, socket,...
            MOVE sap_no  TO ls_file-useable.
        ENDCASE.
        IF ls_file-len = 0.
          MOVE sap_no TO ls_file-useable.
        ENDIF.
      WHEN 1.                     " end of directory
        EXIT.
      WHEN 4.                     " filename too long
        MOVE sap_no TO ls_file-useable.
      WHEN OTHERS.
        MOVE sap_no TO ls_file-useable.
    ENDCASE.
    PERFORM convert_date_time_tz USING ls_file-mtime
                                       ls_file-mod_time
                                       ls_file-mod_date.

    IF ls_file-useable = sap_yes.
      APPEND ls_file TO ft_file.
    ENDIF.

  ENDDO.

  CALL 'C_DIR_READ_FINISH'
      ID 'ERRNO'  FIELD ls_file-errno
      ID 'ERRMSG' FIELD ls_file-errmsg.

ENDFORM.                    "GET_FILE_LIST

*&---------------------------------------------------------------------*
*&      Form  FILENAME_USABLE
*&---------------------------------------------------------------------*
FORM filename_useable USING a_name a_useable.
  DATA l_name(75).

  l_name = a_name.
  IF l_name(4) = 'core'.
    a_useable = ' '.
  ELSE.
    a_useable = 'X'.
  ENDIF.
ENDFORM.                    "FILENAME_USEABLE

*&---------------------------------------------------------------------*
*&      Form  CONVERT_DATE_TIME_TZ
*&---------------------------------------------------------------------*
FORM convert_date_time_tz  USING    ff_mtime
                                    ff_mod_time
                                    ff_mod_date.

  DATA: lf_opcode TYPE x.
  DATA: lf_unique.
  DATA: lf_not_found.
  DATA: lf_timestamp TYPE i.
  DATA: lf_date TYPE d.
  DATA: lf_time TYPE t.
  DATA: lf_tz LIKE sy-zonlo.
  DATA: lf_abapstamp(14).
  DATA: lf_abaptstamp TYPE timestamp.

  lf_timestamp =  ff_mtime.

  IF sy-zonlo = space.
* Der Benutzer hat keine Zeitzone gepflegt: nehme lokale des App. Srv.
    CALL FUNCTION 'TZON_GET_OS_TIMEZONE'
      IMPORTING
        ef_timezone   = lf_tz
        ef_not_unique = lf_unique
        ef_not_found  = lf_not_found.
    IF lf_unique = 'X' OR lf_not_found = 'X'.          .
      lf_tz = sy-tzone.
      CONCATENATE 'UTC+' lf_tz INTO lf_tz.
    ENDIF.
  ELSE.
    lf_tz = sy-zonlo.
  ENDIF.
* wandle den Timestamp in ABAP Format um und lass den ABAP konvertieren
  lf_opcode = 3.
  CALL 'RstrDateConv'
    ID 'OPCODE' FIELD lf_opcode
    ID 'TIMESTAMP' FIELD lf_timestamp
    ID 'ABAPSTAMP' FIELD lf_abapstamp.
  lf_abaptstamp = lf_abapstamp.
  CONVERT TIME STAMP lf_abaptstamp TIME ZONE  lf_tz
          INTO DATE lf_date TIME lf_time.
  IF sy-subrc <> 0.
    ff_mod_date = lf_abapstamp(8).
    ff_mod_time = lf_abapstamp+8.
  ELSE.
    ff_mod_time = lf_time.
    ff_mod_date = lf_date.
  ENDIF.


ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UPDT_INK_IDAT
*&---------------------------------------------------------------------*
FORM updt_ink_idat  TABLES ft_ink_idat_alv STRUCTURE /adesso/ink_idat_alv
                    CHANGING ff_subrc.

  DATA: ls_ink_idat_alv TYPE /adesso/ink_idat_alv.
  DATA: lt_ink_idat TYPE TABLE OF /adesso/ink_idat.

  ff_subrc = 0.

  READ TABLE ft_ink_idat_alv INTO ls_ink_idat_alv INDEX 1.
  CHECK sy-subrc = 0.

  MOVE-CORRESPONDING ft_ink_idat_alv[] TO lt_ink_idat[].

  INSERT /adesso/ink_idat FROM TABLE lt_ink_idat.
  IF sy-subrc = 0.
    COMMIT WORK.
  ELSE.
    ff_subrc = sy-subrc.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  POPUP_FILELIST
*&---------------------------------------------------------------------*
FORM popup_filelist  TABLES ft_ink_idat_alv STRUCTURE gs_ink_idat_alv.

  DATA: lt_fieldcat TYPE slis_t_fieldcat_alv.
  DATA: ls_fieldcat TYPE slis_fieldcat_alv.
  DATA: ls_layout   TYPE slis_layout_alv.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = '/ADESSO/INK_IDAT_ALV'
    CHANGING
      ct_fieldcat            = lt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
            RAISING internal_error.
  ENDIF.

  LOOP AT lt_fieldcat INTO ls_fieldcat
    WHERE fieldname = 'CHECKBOX'.
    ls_fieldcat-edit = 'X'.
    ls_fieldcat-input = 'X'.
    ls_fieldcat-checkbox = 'X'.
    ls_fieldcat-seltext_s = 'Sel'.
    ls_fieldcat-seltext_m = 'Sel'.
    ls_fieldcat-seltext_l = 'Sel'.
    MODIFY lt_fieldcat FROM ls_fieldcat.
  ENDLOOP.

*Layout-Kriterien festlegen.
  ls_layout-box_fieldname     = 'CHECKBOX'.
  ls_layout-colwidth_optimize = 'X'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program      = sy-repid
      i_callback_user_command = g_user_command
      i_structure_name        = '/ADESSO/INK_IDAT'
      i_grid_title            = 'Informationen vom Inkassobüro'
      is_layout               = gs_layout
      it_fieldcat             = lt_fieldcat[]
      it_events               = gt_event
      i_screen_start_column   = 5
      i_screen_start_line     = 5
      i_screen_end_column     = 100
      i_screen_end_line       = 20
    TABLES
      t_outtab                = gt_ink_idat_alv
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


ENDFORM.

*---------------------------------------------------------------------*
*       FORM UCOMM_POPUP                                             *
*---------------------------------------------------------------------*
FORM ucomm_popup USING r_ucomm LIKE sy-ucomm
                       rs_selfield TYPE slis_selfield.

* Daten im ALV aktualisieren (wichtig für das Selektionsfeld)
  DATA: rev_alv TYPE REF TO cl_gui_alv_grid.

  rs_selfield-refresh = 'X'.
  rs_selfield-col_stable = 'X'.
  rs_selfield-row_stable = 'X'.

  CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
    IMPORTING
      e_grid = rev_alv.

  rev_alv->check_changed_data( ).

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CREATE_INTVERM
*&---------------------------------------------------------------------*
FORM create_intverm  USING fs_ink_infi   TYPE /adesso/ink_infi
                           ff_abbrgrund  TYPE /adesso/ink_abbrgrund.

  DATA: lt_head     TYPE TABLE OF thead,
        ls_head     TYPE thead,
        ls_line     TYPE tline,
        lt_line     TYPE TABLE OF tline,
        ls_stxh     TYPE stxh,
        lt_stxh     TYPE TABLE OF stxh,
        lv_lfdnr(3) TYPE n,
        lv_pattern  TYPE char30,
        lv_select   TYPE char30,
        lv_object   TYPE /adesso/inkasso_value,
        lv_id       TYPE /adesso/inkasso_value.

  CLEAR gs_cust.
  READ TABLE gt_cust INTO gs_cust
    WITH KEY inkasso_option = 'INTVERM'
             inkasso_field  = 'TDOBJECT'.

  IF sy-subrc = 0.
    MOVE gs_cust-inkasso_value TO lv_object.
  ELSE.
    EXIT.
  ENDIF.

  CLEAR gs_cust.
  READ TABLE gt_cust INTO gs_cust
    WITH KEY inkasso_option = 'INTVERM'
             inkasso_field  = 'TDID'.

  IF sy-subrc = 0.
    MOVE gs_cust-inkasso_value TO lv_id.
  ELSE.
    EXIT.
  ENDIF.

*  MOVE ff_abbrgrund TO ls_line-tdline.
  CONCATENATE ff_abbrgrund
              TEXT-004
              INTO  ls_line-tdline
              SEPARATED BY space.
  APPEND ls_line TO lt_line.

  CONCATENATE fs_ink_infi-gpart '_'
              fs_ink_infi-vkont '_'
              INTO  lv_pattern.

  CONCATENATE lv_pattern '%' INTO lv_select.

  CLEAR lt_stxh.
  SELECT * FROM stxh INTO TABLE lt_stxh
           WHERE tdobject = lv_object
           AND tdname LIKE lv_select
           AND tdid = lv_id
           AND tdspras = sy-langu.

  SORT lt_stxh BY tdname DESCENDING.
  READ TABLE lt_stxh INTO ls_stxh INDEX 1.
  IF sy-subrc = 0.
    lv_lfdnr = ls_stxh-tdname+24(3).
    ADD 1 TO lv_lfdnr.
    CONCATENATE lv_pattern lv_lfdnr INTO ls_head-tdname.
  ELSE.
    CONCATENATE lv_pattern '001' INTO ls_head-tdname.
  ENDIF.

  ls_head-tdobject = lv_object.
  ls_head-tdid     = lv_id.
  ls_head-tdspras  = sy-langu.

  CALL FUNCTION 'SAVE_TEXT'
    EXPORTING
      client   = sy-mandt
      header   = ls_head
    TABLES
      lines    = lt_line
    EXCEPTIONS
      id       = 1
      language = 2
      name     = 3
      object   = 4
      OTHERS   = 5.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
