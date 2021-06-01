************************************************************************
****
*            _
*   __ _  __| | ___  ___ ___  ___
*  / _` |/ _` |/ _ \/ __/ __|/ _ \
* | (_| | (_| |  __/\__ \__ \ (_) |
*  \__,_|\__,_|\___||___/___/\___/
************************************************************************
************************************************************************
*******
REPORT zhar_file_load.

parameters  p_file  type localfile default 'C:\Users\appel\Documents\SAP\SAP GUI\c_enet_g.csv'.
parameters  p_table type tablenam  default '/adesso/c_enet_g'.

************************************************************************
* START-OF-SELECTION:
************************************************************************
START-OF-SELECTION.

data lt_rawdata type standard table of string.
data lv_file    type string.
data lr_data    type ref to data.
field-symbols <ls_data>  type  any.
field-symbols <lt_data>  type  standard table.

create data lr_data type (p_table).
assign lr_data->* to <ls_data>.

create data lr_data like table of <ls_data>.
assign lr_data->* to <lt_data>.

lv_file = p_file.


perform read_csv_datei
  using    lv_file
  changing <lt_data>.
  .
 write : /(10) lines( <lt_data> ), 'read'.


 modify (p_table) from  table <lt_data>.
 if sy-subrc ne 0.
    write: / 'error updating table ', p_table.
    exit.
 endif.
 write : / sy-dbcnt, 'rows updated'.

FORM read_csv_datei USING VALUE(uv_dateiname) TYPE string
          CHANGING ct_daten_aus_datei TYPE STANDARD TABLE.

  DATA lv_str_dateiname TYPE string. " Dateinamen als String
  DATA(lv_colsep) = ';'.
  DATA lt_strings type standard table of string.
  data lr_line    type ref to data.
  field-symbols  <lv_string> type string.
  field-symbols  <lv_str_value> type string.
  field-symbols  <ls_target_data>   type any.
  field-symbols  <lv_target_value> type any.

  lv_str_dateiname =  uv_dateiname. " Typecast char -> string

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = lv_str_dateiname
      filetype                = 'ASC'
      HAS_FIELD_SEPARATOR     = ' '
    TABLES
      data_tab                = lt_strings
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
      OTHERS                  = 17.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  create data lr_line like line of ct_daten_aus_datei.
  assign lr_line->* to <ls_target_data>.
  loop at lt_strings assigning <lv_string>.
     SPLIT <lv_string> AT lv_colsep INTO TABLE DATA(lt_columns).
     loop at lt_columns assigning <lv_str_value>.
        assign component sy-tabix of structure <ls_data> to <lv_target_value>.
        <lv_target_value> = <lv_str_value>.
     endloop.
     append <ls_data> to ct_daten_aus_datei.
  endloop.
ENDFORM." datei_lesen_arbeitsplatz
