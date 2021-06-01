*&---------------------------------------------------------------------*
*& Report  /ADESSO/INKASSO_INFO_INKDL
*&---------------------------------------------------------------------*
REPORT /adesso/inkasso_info_inkdl MESSAGE-ID /adesso/inkmon.

INCLUDE /adesso/inkasso_info_inkdl_top.

******************************************************************************************
* Initialization
******************************************************************************************
INITIALIZATION.

* Customizing Inbound file
  SELECT SINGLE * FROM /adesso/ink_cust INTO gs_cust
     WHERE inkasso_option   = 'DATEI'
     AND   inkasso_category = 'FILENAME'
     AND   inkasso_field    = 'INBOUND'.

  IF sy-subrc = 0.
    p_fname = gs_cust-inkasso_value.
  ENDIF.

******************************************************************************************
* AT SELECTIO-SCREEN
******************************************************************************************
AT SELECTION-SCREEN.

  CALL FUNCTION 'FILE_GET_NAME'
    EXPORTING
      logical_filename = p_fname
    IMPORTING
      file_name        = gv_dirname
    EXCEPTIONS
      file_not_found   = 1
      OTHERS           = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
* Valid directory ?
* security enhancement (start)
    DATA: hv_dirname TYPE pathextern.
    CONCATENATE gv_dirname 'TEST' INTO hv_dirname.
    CALL FUNCTION 'FILE_VALIDATE_NAME'
      EXPORTING
        logical_filename           = 'FI-CA-COL-READ'
      CHANGING
        physical_filename          = hv_dirname
      EXCEPTIONS
        logical_filename_not_found = 1
        validation_failed          = 2
        OTHERS                     = 3.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
* security enhancement (end)
  ENDIF.

*******************************************************************************************
* START-OF-SELECTION
*******************************************************************************************
START-OF-SELECTION.

  AUTHORITY-CHECK OBJECT 'F_KKINK' ID 'ACTVT' FIELD 'B6'
                                   ID 'BRGRU' DUMMY.
  IF sy-subrc NE 0.
    MESSAGE e592(>3).
  ENDIF.

  PERFORM get_customizing.

  SELECT * FROM /adesso/ink_idat
           INTO CORRESPONDING FIELDS OF TABLE gt_ink_idat_alv.

  CASE gc_mark.
    WHEN p_updt.
      PERFORM get_new_files TABLES gt_ink_idat_alv
                            USING  gv_dirname.
      IF sy-batch IS INITIAL.
        PERFORM popup_filelist TABLES gt_ink_idat_alv.
        DELETE gt_ink_idat_alv WHERE checkbox = space.
      ENDIF.
      LOOP AT gt_ink_idat_alv INTO gs_ink_idat_alv
           WHERE checkbox = gc_mark.
        PERFORM read_file TABLES gt_ink_infi
                          USING  gv_dirname gs_ink_idat_alv-filename.
        PERFORM update_infos TABLES gt_ink_infi CHANGING gf_insert_i gf_subrc.
        IF gf_subrc = 0.
          gs_ink_idat_alv-vstatus = 'OK'.
          gs_ink_idat_alv-anz_line = gf_insert_i.
          READ TABLE gt_ink_infi INTO gs_ink_infi INDEX 1.
          gs_ink_idat_alv-infodat = gs_ink_infi-infodat.
          gs_ink_idat_alv-inkgp   = gs_ink_infi-inkgp.
        ELSE.
          gs_ink_idat_alv-vstatus = 'ERR'.
          DESCRIBE TABLE gt_ink_infi LINES gs_ink_idat_alv-anz_line.
        ENDIF.
        MODIFY gt_ink_idat_alv FROM gs_ink_idat_alv.
        APPEND LINES OF gt_ink_infi TO gt_ink_ialv.
      ENDLOOP.
      PERFORM updt_ink_idat TABLES gt_ink_idat_alv
                            CHANGING gf_subrc.
    WHEN p_snew.
      PERFORM get_new_files TABLES gt_ink_idat_alv
                            USING  gv_dirname.
      PERFORM popup_filelist TABLES gt_ink_idat_alv.
      LOOP AT gt_ink_idat_alv INTO gs_ink_idat_alv
           WHERE checkbox = gc_mark.
        PERFORM read_file TABLES gt_ink_infi
                          USING  gv_dirname gs_ink_idat_alv-filename.
        APPEND LINES OF gt_ink_infi TO gt_ink_ialv.
      ENDLOOP.
    WHEN p_show.
      PERFORM popup_filelist TABLES gt_ink_idat_alv.
      LOOP AT gt_ink_idat_alv INTO gs_ink_idat_alv
           WHERE checkbox = gc_mark.
        PERFORM read_file TABLES gt_ink_infi
                          USING  gv_dirname gs_ink_idat_alv-filename.
        APPEND LINES OF gt_ink_infi TO gt_ink_ialv.
      ENDLOOP.
  ENDCASE.

************************************************************************************
* END-OF-SELECTION
************************************************************************************
END-OF-SELECTION.

  SORT gt_gpvk.
  SORT gt_ink_infi BY gpart vkont satztyp infodat inkgp.

  IF p_updt = gc_mark.

    LOOP AT gt_gpvk INTO gs_gpvk.
      CLEAR: gv_abbrgrund.
      LOOP AT gt_ink_infi INTO gs_ink_infi
           WHERE gpart   = gs_gpvk-gpart
           AND   vkont   = gs_gpvk-vkont
           AND   satztyp = gs_gpvk-satztyp
           AND   infodat = gs_gpvk-infodat
           AND   inkgp   = gs_gpvk-inkgp.
        gv_abbrgrund = gs_ink_infi-abbrgrund.
      ENDLOOP.

      IF sy-subrc = 0.
        PERFORM create_contact USING gs_ink_infi.
        IF gv_abbrgrund NE space.
          PERFORM create_intverm USING gs_ink_infi gv_abbrgrund.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDIF.

  PERFORM display_alv.

  INCLUDE /adesso/inkasso_info_inkdl_f01.
