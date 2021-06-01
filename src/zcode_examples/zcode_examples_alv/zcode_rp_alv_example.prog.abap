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
REPORT zcode_rp_alv_example.

DATA: gv_id TYPE zcode_de_alv_id.
*      gv_area  TYPE zbook_area,
*      gv_clas  TYPE zbook_clas,
*      gv_resp  TYPE zbook_person_repsonsible,
*      gv_stat  TYPE zbook_ticket_status.
DATA: gr_custom_cont TYPE REF TO cl_gui_custom_container,
*      gr_alv_controller TYPE REF TO zcode_de_alv_output,
      gs_selection   TYPE zcode_s_alv_selection,
      ok_code        TYPE sy-ucomm.

SELECTION-SCREEN BEGIN OF BLOCK sel
WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: so_id FOR gv_id.
SELECTION-SCREEN END OF BLOCK sel.
SELECTION-SCREEN SKIP 1.
PARAMETERS: p_vari LIKE gs_selection-variant-variant.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = gs_selection-variant
      i_save     = 'A'
    IMPORTING
      es_variant = gs_selection-variant
    EXCEPTIONS
      not_found  = 2.
  p_vari = gs_selection-variant-variant.

INITIALIZATION.
  CALL FUNCTION 'RS_SUPPORT_SELECTIONS'
    EXPORTING
      report               = sy-repid
      variant              = '/STD'
    EXCEPTIONS
      variant_not_existent = 1
      variant_obsolete     = 2
      OTHERS               = 3.
  gs_selection-variant-report = sy-repid.
  gs_selection-variant-username = sy-uname.

START-OF-SELECTION.
  gs_selection-id = so_id.
  CALL SCREEN 0100.
