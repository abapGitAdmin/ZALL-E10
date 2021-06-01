*----------------------------------------------------------------------*
***INCLUDE LSE16NF75.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  READ_EXTRACT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LTX_TABLE_DATA  text
*----------------------------------------------------------------------*
FORM read_extract  CHANGING ltx_table_data TYPE fagl_tx_prot_data.

  CLEAR gd_extract-read. "initialize extract mode
  select single extract_id from se16n_lt into gd_extract-id
           where name  = gd_extract-name
             and tab   = gd-tab
             and uname = gd_extract-uname.
  if sy-subrc <> 0.
    message e603(wusl).
  endif.

  IF gd_extract-id IS NOT INITIAL.
    CALL METHOD cl_fagl_prot_services=>load_data
      EXPORTING
        ed_guid       = gd_extract-id
      IMPORTING
        itx_prot_data = ltx_table_data.
    CALL METHOD cl_fagl_prot_services=>retrieve_data
      EXPORTING
        ed_name       = 'GD-SELECT_TYPE'
        etx_prot_data = ltx_table_data
      IMPORTING
        id_data       = gd-select_type.
    CALL METHOD cl_fagl_prot_services=>retrieve_data
      EXPORTING
        ed_name       = 'GT_FIELD'
        etx_prot_data = ltx_table_data
      IMPORTING
        id_data       = gt_field.
    CALL METHOD cl_fagl_prot_services=>retrieve_data
      EXPORTING
        ed_name       = '<all_table>'
        etx_prot_data = ltx_table_data
      IMPORTING
        id_data       = <all_table>.
    IF sy-subrc = 0.
      MESSAGE s601(wusl) WITH gd_extract-name.
    ELSE.
      MESSAGE e603(wusl).
    ENDIF.
  ELSE.
    MESSAGE e606(wusl) WITH gd_extract-name.
    EXIT.
  ENDIF.

  describe table <all_table> lines gd-number.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  WRITE_EXTRACT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LTX_TABLE_DATA  text
*----------------------------------------------------------------------*
FORM write_extract  CHANGING ltx_table_data TYPE fagl_tx_prot_data.

  DATA: ls_se16n_lt     TYPE se16n_lt.
  DATA: ld_extract_id   TYPE guid16.

  CLEAR gd_extract-write. "initialize extract mode
  CLEAR ltx_table_data. REFRESH ltx_table_data.
  CALL METHOD cl_fagl_prot_services=>add_data
    EXPORTING
      ed_name       = '<all_table>'
      ed_data       = <all_table>
    CHANGING
      ctx_prot_data = ltx_table_data.
  CALL METHOD cl_fagl_prot_services=>add_data
    EXPORTING
      ed_name       = 'GT_FIELD'
      ed_data       = gt_field
    CHANGING
      ctx_prot_data = ltx_table_data.
  CALL METHOD cl_fagl_prot_services=>add_data
    EXPORTING
      ed_name       = 'GD-SELECT_TYPE'
      ed_data       = gd-select_type
    CHANGING
      ctx_prot_data = ltx_table_data.
  CALL METHOD cl_fagl_prot_services=>store_data
    EXPORTING
      etx_prot_data = ltx_table_data
    IMPORTING
      id_guid       = ld_extract_id.
  SELECT SINGLE * FROM se16n_lt INTO ls_se16n_lt
                  WHERE name  = gd_extract-name AND
                        tab   = gd-tab  AND
                        uname = gd_extract-uname.
  IF sy-subrc EQ 0.
    ls_se16n_lt-extract_id = ld_extract_id.
    UPDATE se16n_lt FROM ls_se16n_lt.
    MESSAGE s600(wusl) WITH gd_extract-name.
  ELSE.
    MESSAGE e602(wusl).
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  EXTRACT_CREATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM extract_create .

*..User has to enter a name for the variant that is stored with the
*..input data.
*..This variant lateron gets a GUID for the extract
   gs_se16n_lt-uname = sy-uname.
   perform layout_save.
*..abort is variant name is initial
   if gs_se16n_lt-name is initial.
     exit.
   else.
     gd_extract-name  = gs_se16n_lt-name.
     gd_extract-uname = gs_se16n_lt-uname.
     gd_extract-write = true.
   endif.
*..now start batch processing
   perform execute using space true space.
   clear gd_extract.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SHOW_EXTRACT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM show_extract .

*..get name of extract
   gs_se16n_lt-tab = gd-tab.
   gd_extract-read = true.
   perform layout_get.
*..abort is variant name is initial
   if gs_se16n_lt-name is initial.
     clear gd_extract-read.
     exit.
   else.
     gd_extract-name  = gs_se16n_lt-name.
     gd_extract-uname = gs_se16n_lt-uname.
     gd_extract-read  = true.
   endif.
   perform execute using space space space.
   clear gd_extract.

ENDFORM.
