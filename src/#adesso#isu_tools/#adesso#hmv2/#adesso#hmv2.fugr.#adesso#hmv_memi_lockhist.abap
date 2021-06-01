FUNCTION /ADESSO/HMV_MEMI_LOCKHIST.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(DOC_ID) TYPE  /IDXMM/DE_DOC_ID
*"  RAISING
*"      CX_SALV_MSG
*"----------------------------------------------------------------------

  DATA lt_memilock TYPE TABLE OF /adesso/mem_mloc.
  DATA: gt_outtab  TYPE STANDARD TABLE OF /adesso/mem_mloc,
        lv_columns TYPE i,
        lv_belnr   TYPE opbel_kk,
        lr_content TYPE REF TO cl_salv_form_element,
        x_wtitle   TYPE lvc_title,
        gr_display TYPE REF TO cl_salv_display_settings,
        gr_table   TYPE REF TO cl_salv_table.

  SELECT * FROM /adesso/mem_mloc INTO TABLE gt_outtab WHERE doc_id = doc_id.

  IF sy-subrc = 0.
    lv_columns = lines( gt_outtab ) + 5.
    cl_salv_table=>factory(
 EXPORTING
    list_display = 'X'
  IMPORTING
    r_salv_table = gr_table
  CHANGING
    t_table      = gt_outtab
       ).

    gr_table->set_screen_popup(
      start_column = 1
      end_column   = 100
      start_line   = 1
      end_line     = lv_columns ).

    DATA: lr_selections TYPE REF TO cl_salv_selections.

    lr_selections = gr_table->get_selections( ).
    lr_selections->set_selection_mode(
  if_salv_c_selection_mode=>none ).

    lv_belnr = doc_id.
    SHIFT lv_belnr LEFT DELETING LEADING '0'.
    CONCATENATE 'Mahnhistorie zu Beleg' lv_belnr INTO x_wtitle SEPARATED BY space.
    gr_display = gr_table->get_display_settings( ).
    gr_display->set_list_header( x_wtitle ).

    gr_table->display( ).

  ELSE.
    MESSAGE i023(/adesso/hmv).
  ENDIF.

  CLEAR wa_out-docno.

ENDFUNCTION.
