************************************************************************
****
*            _
*   __ _  __| | ___  ___ ___  ___
*  / _` |/ _` |/ _ \/ __/ __|/ _ \
* | (_| | (_| |  __/\__ \__ \ (_) |
*  \__,_|\__,_|\___||___/___/\___/
************************************************************************
*******
*
*
*&
************************************************************************
*******
REPORT zz_hierech_sequenz_alv.


TYPES: BEGIN OF ty_hdr,
         expand,
         carrid   TYPE s_carr_id,
         carrname TYPE s_carrname,
       END OF ty_hdr.

TYPES: BEGIN OF ty_itm,
         carrid    TYPE s_carr_id,
         connid    TYPE s_conn_id,
         countryfr TYPE land1,
         countryto TYPE land1,
       END OF ty_itm.

DATA: lt_hdr TYPE TABLE OF ty_hdr.
DATA: lt_itm TYPE TABLE OF ty_itm.
DATA: ls_layt TYPE slis_layout_alv.
DATA: lt_fcat TYPE slis_t_fieldcat_alv.
DATA: ls_fcat TYPE LINE OF slis_t_fieldcat_alv.
DATA: ls_key TYPE slis_keyinfo_alv.

START-OF-SELECTION.
  SELECT carrid carrname FROM scarr INTO CORRESPONDING FIELDS OF TABLE lt_hdr.
  CHECK lt_hdr IS NOT INITIAL.
  SELECT carrid connid countryfr countryto FROM spfli INTO CORRESPONDING FIELDS OF TABLE lt_itm
  FOR ALL ENTRIES IN lt_hdr WHERE carrid = lt_hdr-carrid.
  " Build layout
  ls_layt-expand_fieldname = 'EXPAND'.
  ls_layt-colwidth_optimize = 'X'.

  " Build Keyinfo
  ls_key-header01 = 'CARRID'.
  ls_key-item01 = 'CARRID'.

  "Build Fieldcat
  ls_fcat-col_pos = '1'.
  ls_fcat-fieldname = 'CARRID'.
  ls_fcat-tabname = 'LT_HDR'.
  ls_fcat-key = 'X'.
  ls_fcat-seltext_m = 'Flight ID'.
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.

  ls_fcat-col_pos = '2'.
  ls_fcat-fieldname = 'CARRNAME'.
  ls_fcat-tabname = 'LT_HDR'.
  ls_fcat-seltext_m = 'Flight Conn'.
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.

  ls_fcat-col_pos = '3'.
  ls_fcat-fieldname = 'CONNID'.
  ls_fcat-tabname = 'LT_ITM'.
  ls_fcat-seltext_m = 'Conn Number'.
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.

  ls_fcat-col_pos = '4'.
  ls_fcat-fieldname = 'COUNTRYFR'.
  ls_fcat-tabname = 'LT_ITM'.
  ls_fcat-seltext_m = 'From Country'.
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.

  ls_fcat-col_pos = '5'.
  ls_fcat-fieldname = 'COUNTRYTO'.
  ls_fcat-tabname = 'LT_ITM'.
  ls_fcat-seltext_m = 'To Country'.
  APPEND ls_fcat TO lt_fcat.
  CLEAR ls_fcat.

  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      is_layout          = ls_layt
      it_fieldcat        = lt_fcat
      i_tabname_header   = 'LT_HDR'
      i_tabname_item     = 'LT_ITM'
      is_keyinfo         = ls_key
    TABLES
      t_outtab_header    = lt_hdr
      t_outtab_item      = lt_itm
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
