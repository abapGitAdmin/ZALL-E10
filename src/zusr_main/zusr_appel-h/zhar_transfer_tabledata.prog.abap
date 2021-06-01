************************************************************************
****
*            _
*   __ _  __| | ___  ___ ___  ___
*  / _` |/ _` |/ _ \/ __/ __|/ _ \
* | (_| | (_| |  __/\__ \__ \ (_) |
*  \__,_|\__,_|\___||___/___/\___/
************************************************************************
************************************************************************
REPORT zhar_transfer_tabledata.

##NEEDED
"DATA lc_value_helper TYPE REF TO z1har_cl_value_helper.
##NEEDED
DATA l_str           TYPE string.
##NEEDED
DATA lv_tabname        TYPE tabname.

* Deklarationen für dynam. Methodenaufruf
SELECT-OPTIONS  s_tables FOR  lv_tabname NO INTERVALS DEFAULT '/adz/inv_cust' MODIF ID tab.
PARAMETERS : p_dir    TYPE string       DEFAULT 'C:\zzz_transfer' LOWER CASE OBLIGATORY MODIF ID fil,
             p_cmapfi TYPE string       DEFAULT '' LOWER CASE MODIF ID map,
             p_postf  TYPE string       DEFAULT 'TEST' MODIF ID fil,
             p_addres TYPE string       . "DEFAULT 'STICHTAG > ''20193112'' '.
"SELECTION-SCREEN SKIP 1.
PARAMETERS :
  p_dwnl TYPE flag    USER-COMMAND flag RADIOBUTTON GROUP tmo,
  p_del  TYPE flag    RADIOBUTTON GROUP tmo,
  p_upl  TYPE flag    RADIOBUTTON GROUP tmo.

"------------------------------------------------------------------

AT SELECTION-SCREEN ON VALUE-REQUEST FOR  p_dir.
*  lc_value_helper->read_param_from_dynp2(
*    EXPORTING
*      fieldname = 'P_DIR'   " Feldname
*      dyname    = sy-repid    " ABAP-Programmname
*      dynum     = sy-dynnr    " CHAR04-Datenelement fuer SYST
*    CHANGING
*      retval    = l_str
*  ).
  l_str = p_dir.
  if p_dir is INITIAL.
     l_str = 'C:\zzz_transfer'.
  endif.
  CALL METHOD cl_gui_frontend_services=>directory_browse
    EXPORTING
      window_title         = 'Select File'
      initial_folder       = l_str   " Browsen fängt hier an
    CHANGING
      selected_folder      = p_dir   " Vom Benutzer selektiertes Verzeichnis
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  "------------------------------------------------------------------

INITIALIZATION.

  "------------------------------------------------------------------

AT SELECTION-SCREEN OUTPUT.
  DATA lv_dwn_active   TYPE c LENGTH 1 VALUE '0'.
  DATA lv_del_active   TYPE c LENGTH 1 VALUE '0'.
  DATA lv_upl_active   TYPE c LENGTH 1 VALUE '0'.
  DATA lv_file_active  TYPE c LENGTH 1 VALUE '0'.
  DATA lv_map_active   TYPE c LENGTH 1 VALUE '0'.
  DATA lv_tab_active   TYPE c LENGTH 1 VALUE '0'.

  IF p_upl = 'X'.
    lv_upl_active   = 1.
    lv_file_active  = 1.
    lv_map_active   = 1.

  ELSEIF p_del = 'X'.
    lv_del_active   = 1.

  ELSEIF p_dwnl = 'X' .
    lv_dwn_active   = 1.
    lv_file_active  = 1.

  ELSE.
    lv_dwn_active   = 1.
    lv_file_active  = 1.
  ENDIF.
  lv_tab_active = 1.

  LOOP AT SCREEN .
    CASE screen-group1.
      WHEN 'UPD'.
        screen-input = lv_upl_active.
      WHEN 'DEL'.
        screen-input = lv_del_active.
      WHEN 'DWN'.
        screen-input = lv_dwn_active.
      WHEN 'FIL'.
        screen-input  = lv_file_active.
      WHEN 'MAP'.
        screen-input  = lv_map_active.
      WHEN 'TAB'.
        screen-input  = lv_tab_active.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.

  "------------------------------------------------------------------

START-OF-SELECTION.
  DATA(lc_file) = NEW zhar_cl_transfer_tabledata( ). " zhar_cl_load_file( ).
  DATA  lt_tabnames          TYPE STANDARD TABLE OF tabname.
  DATA  lv_add_restr         TYPE string.

  SELECT tabname FROM dd02l INTO TABLE lt_tabnames WHERE tabname IN s_tables.
  lv_add_restr = p_addres.

  LOOP AT lt_tabnames INTO lv_tabname.
    IF p_dwnl = 'X'.
      IF sy-tabix = 1.
        WRITE : /  'Download-directory:', p_dir.
      ENDIF.

      lc_file->transfer_tables_tofrom_file(
        EXPORTING
          iv_tabname      = lv_tabname
          iv_addrestr     = lv_add_restr
"            it_rng_restr    =
          if_upload       = ''
          iv_col_map_file = ''
          iv_file_postfix = p_postf
          iv_target_dir   = p_dir
        EXCEPTIONS
          update_error    = 1
          OTHERS          = 2
      ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.

    IF p_del = 'X'.
      CALL METHOD lc_file->delete_table
        EXPORTING
          iv_tabname   = lv_tabname
          iv_addrestr  = lv_add_restr
*         it_rng_restr =
        EXCEPTIONS
          delete_error = 1
          OTHERS       = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        RETURN.
      ENDIF.
    ENDIF.

    IF p_upl = 'X'.
      lc_file->transfer_tables_tofrom_file(
        EXPORTING
          iv_tabname      = lv_tabname
          iv_addrestr     = lv_add_restr
"            it_rng_restr    =
          if_upload       = 'X'
          iv_col_map_file = ''
          iv_file_postfix = p_postf
          iv_target_dir   = p_dir
        EXCEPTIONS
          update_error    = 1
          OTHERS          = 2
      ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
  ENDLOOP.
