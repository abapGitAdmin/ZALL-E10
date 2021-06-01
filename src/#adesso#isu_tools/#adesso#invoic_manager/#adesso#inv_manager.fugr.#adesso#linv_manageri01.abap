*----------------------------------------------------------------------*
***INCLUDE LZ_ADESSO_INV_MANAGERO01.

*---------------------------------------------------------------------*
*       CLASS
*---------------------------------------------------------------------*
CLASS event_handle DEFINITION.

  PUBLIC SECTION.
    CLASS-METHODS:
      handle_double_click
                    FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING e_row     "Zeile
                    e_column, "Spalte
      handle_hotspot_click
                    FOR EVENT hotspot_click OF cl_gui_alv_grid
        IMPORTING e_row_id       "Zeile
                    e_column_id,   "Spalte
      handle_data_changed
                    FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING er_data_changed,
      handle_toolbar                                        "#EC NEEDED
                    FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object
                    e_interactive,
      handle_user_command
                    FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm,      "sy-ucomm
      handle_menu_button
                    FOR EVENT menu_button OF cl_gui_alv_grid
        IMPORTING e_object
                    e_ucomm.                                "#EC NEEDED

ENDCLASS.


*----------------------------------------------------------------------*
*       CLASS event_handle IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS event_handle IMPLEMENTATION.

  METHOD handle_double_click.
    PERFORM handle_double_click
      USING e_row               "Zeile
            e_column.           "Spalte
  ENDMETHOD.                    "handle_double_click
  METHOD handle_hotspot_click.
    PERFORM handle_hotspot_click
      USING  e_row_id           "Zeile
             e_column_id.       "Spalte
  ENDMETHOD.
  METHOD handle_data_changed.

    DATA: ls_good  TYPE lvc_s_modi.

    FIELD-SYMBOLS: <fs_itab> TYPE t_ausgabe_sim.

* Tabelle der modifizierten Zellen abarbeiten
    LOOP AT er_data_changed->mt_mod_cells INTO ls_good.

      READ TABLE gt_ausgabe_sim ASSIGNING <fs_itab> INDEX ls_good-row_id.
      IF sy-subrc = 0.
        CASE ls_good-fieldname.
          WHEN 'STATUS_OK'.
            IF <fs_itab>-status_ok = ' '."Achtung, der Aufruf ist vor der Änderung. Also Aufruf wenn satus Ok X gesetzt wird!
              <fs_itab>-status_rek = ''.
              <fs_itab>-status_bear = ''.
              PERFORM refresh_alv1.
            ENDIF.
          WHEN 'STATUS_REK'.
            IF <fs_itab>-status_rek = ' '.
              <fs_itab>-status_ok = ''.
              <fs_itab>-status_bear = ''.
              PERFORM refresh_alv1.
            ENDIF.
          WHEN 'STATUS_BEAR'.
            IF <fs_itab>-status_rek = ''.
              <fs_itab>-status_ok = ''.
              <fs_itab>-status_bear = ' '.
              PERFORM refresh_alv1.
            ENDIF.
        ENDCASE.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.                    "handle_data_changed
  METHOD handle_toolbar.
    PERFORM handle_toolbar
      CHANGING e_object
               e_interactive.
  ENDMETHOD.                    "handle_toolbar
  METHOD handle_menu_button.
    PERFORM handle_menu_button
      USING e_object
            e_ucomm.
  ENDMETHOD.                    "handle_menu_button
  METHOD handle_user_command.
    PERFORM handle_user_command
      USING e_ucomm.             "sy-ucomm
  ENDMETHOD.                    "handle_user_command

ENDCLASS.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  DATA ls_proc_data TYPE inv_process_data.
  DATA ls_invtext         TYPE /adesso/invtext.
  IF gv_ok_sim = 'SIM_START'.
    LOOP AT gt_ausgabe_sim REFERENCE INTO DATA(lr_ausgabe_sim).
      PERFORM get_process_data USING lr_ausgabe_sim->int_inv_doc_no CHANGING ls_proc_data.
      PERFORM sim_verbrauch USING ls_proc_data  CHANGING lr_ausgabe_sim->status_sim_vp.
      PERFORM sim_msc USING ls_proc_data CHANGING lr_ausgabe_sim->status_sim_msc.
      SELECT SINGLE msc_start msc_end FROM /adesso/inv_msc INTO (lr_ausgabe_sim->msc_start, lr_ausgabe_sim->msc_end) WHERE int_inv_no = ls_proc_data-inv_head-int_inv_no.
      "PERFORM  msc_without_readingres.
    ENDLOOP.


  ELSEIF gv_ok_sim = 'SIM_OK'.

    LOOP AT gt_ausgabe_sim INTO DATA(ls_ausgabe_sim).

      ls_invtext-text = ls_ausgabe_sim-bemerkung.
      ls_invtext-datum = sy-datum.
      IF ls_ausgabe_sim-status_ok = 'X'.
        ls_invtext-action = 'EDM_OK'.
      ELSEIF ls_ausgabe_sim-status_rek = 'X'.
        ls_invtext-action = 'EDM_REK'.
      ELSEIF ls_ausgabe_sim-status_bear = 'X'.
        ls_invtext-action = 'EDM_BEAR'.
      ELSE.
        CLEAR ls_invtext.
      ENDIF.
      ls_invtext-int_inv_doc_nr = ls_ausgabe_sim-int_inv_doc_no.
      ls_invtext-uname = sy-uname.
      ls_invtext-zeit = sy-uzeit.
      IF ls_invtext-action IS NOT INITIAL.
        INSERT INTO /adesso/invtext VALUES ls_invtext.
      ENDIF.
    ENDLOOP.
    LEAVE TO SCREEN 0.

  ELSEIF gv_ok_sim = 'SIM_CANC'.
    LEAVE TO SCREEN 0.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  PBO_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_0100 OUTPUT.
  DATA it_tab TYPE tt_ausgabe_sim.
  DATA ls_tab LIKE LINE OF it_tab.
  IF gt_ausgabe_sim IS INITIAL.
    PERFORM select_data CHANGING gt_ausgabe_sim.
  ENDIF.

  PERFORM alv_0100 CHANGING  gt_ausgabe_sim.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'SIM_STATUS'.
  SET TITLEBAR 'Prüfung Simulieren'.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Form  REFRESH_ALV
*&---------------------------------------------------------------------*
*       Aktualisieren ALV-Liste
*----------------------------------------------------------------------*
FORM refresh_alv1.

  DATA: ls_stable TYPE lvc_s_stbl.

  ls_stable-row = true.
  ls_stable-col = true.

  CALL METHOD go_alv_cont->refresh_table_display
    EXPORTING
      is_stable = ls_stable
    EXCEPTIONS
      finished  = 1
      OTHERS    = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  alv_2000
*&---------------------------------------------------------------------*
*       ALV-Output
*----------------------------------------------------------------------*
FORM alv_0100
  CHANGING ct_itab TYPE tt_ausgabe_sim.

  TYPE-POOLS: slis.

  DATA: lt_fcat    TYPE lvc_t_fcat,
        ls_layout  TYPE lvc_s_layo,
*     ls_sort    type LVC_S_SORT,
*     lt_sort    type LVC_T_SORT
        ls_variant TYPE disvariant.

****************
* Fill Variant *
****************
  ls_variant-report  = sy-repid.
  ls_variant-handle  = gv_handle_num1.

* ls_layout-zebra      = 'X'.        "Liste wird im Zebra-Look ausgegeben
* ls_layout-TOTALS_BEF = 'X'.        "Summen vor Einzelsätzen
  ls_layout-cwidth_opt = 'A'.        "Spaltenbreite wird optimiert (hier ein 'A', nicht 'X' !!)
  ls_layout-sel_mode   = 'D'.        "'D' = mit Markierspalte, 'B' = ohne Markierspalte
  ls_layout-excp_fname = 'STATUS_OLD'.
*  ls_layout-excp_led = 'X'.




*****************
* Fill Fieldcat *
*****************
  PERFORM alv_fcat              "Definition Felder, die ausgegeben werden sollen
    CHANGING lt_fcat.


  IF go_cont IS NOT BOUND.
****************************************
* Methode: set_table_for_first_display *
****************************************
* Container erzeugen
    CREATE OBJECT go_cont
      EXPORTING
        container_name = 'GC_SIM_ALV'.

* ALV erzeugen
    CREATE OBJECT go_alv_cont
      EXPORTING
        i_parent = go_cont.


* Rufe die ALV-Liste auf
    CALL METHOD go_alv_cont->set_table_for_first_display
      EXPORTING
        i_bypassing_buffer = 'X' "lv_bypassing_buffer
        i_save             = 'A' "lv_save
*       i_default          = 'X'
        is_layout          = ls_layout
*       it_toolbar_excluding = lt_toolbar_excluding
        is_variant         = ls_variant
      CHANGING
        it_outtab          = ct_itab
        it_fieldcatalog    = lt_fcat.

    IF sy-subrc = 0.
      DATA lv_lines TYPE i.
      lv_lines = lines( ct_itab ).
      go_alv_cont->set_gridtitle( i_gridtitle =  lv_lines && '-fehlerhafte Invoic'(001) ).  "Titelbeschriftung in der ALV-Liste
    ENDIF.

* Register events
    CALL METHOD go_alv_cont->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_enter.

    CALL METHOD go_alv_cont->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.

* Die Eventhandler werden scharf geschaltet
    SET HANDLER event_handle=>handle_double_click   FOR go_alv_cont.
    SET HANDLER event_handle=>handle_hotspot_click  FOR go_alv_cont.
    SET HANDLER event_handle=>handle_data_changed   FOR go_alv_cont.
    SET HANDLER event_handle=>handle_toolbar        FOR go_alv_cont.
    SET HANDLER event_handle=>handle_menu_button    FOR go_alv_cont.
    SET HANDLER event_handle=>handle_user_command   FOR go_alv_cont.

* Die Toolbar soll ergänzt werden um eigene Buttons
    CALL METHOD go_alv_cont->set_toolbar_interactive.

  ELSE.
    PERFORM refresh_alv1.
  ENDIF.

ENDFORM.

FORM get_selected_rows.

  DATA: gt_row_no  TYPE lvc_t_roid.

  CALL METHOD go_alv_cont->get_selected_rows
    IMPORTING
      et_row_no = gt_row_no.

ENDFORM.

FORM set_selected_rows.

  DATA: gt_row_no  TYPE lvc_t_roid.

  CALL METHOD go_alv_cont->set_selected_rows
    EXPORTING
      it_row_no                = gt_row_no
      is_keep_other_selections = space.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  alv_fcat
*&---------------------------------------------------------------------*
*       Feldliste der ALV-Tabelle
*----------------------------------------------------------------------*
FORM alv_fcat
  CHANGING ct_fcat TYPE lvc_t_fcat.

  DATA: ls_fcat TYPE lvc_s_fcat.

* Field =
  ls_fcat-fieldname   = 'INT_INV_DOC_NO'.   "Feldname interne Tabelle
  ls_fcat-ref_table   = 'TINV_INV_DOC'.    "Tabellenname typisierte Tabelle
  ls_fcat-key         = 'X'.       "Spalte ist Key-Spalte (blau und fix beim Scrollen)
  APPEND ls_fcat TO ct_fcat.
  CLEAR ls_fcat.

* Field =
  ls_fcat-fieldname   = 'STATUS_OLD'.   "Feldname interne Tabelle
  ls_fcat-reptext      = 'Status Invoic'.
  ls_fcat-outputlen  = '20'.
  APPEND ls_fcat TO ct_fcat.
  CLEAR ls_fcat.

  ls_fcat-fieldname   = 'STATUS_SIM_VP'.   "Feldname interne Tabelle
  ls_fcat-reptext      = 'VP SIM'.
  APPEND ls_fcat TO ct_fcat.
  CLEAR ls_fcat.

  ls_fcat-fieldname   = 'STATUS_SIM_MSC'.   "Feldname interne Tabelle
  ls_fcat-reptext      = 'MCS SIM'.
  APPEND ls_fcat TO ct_fcat.
  CLEAR ls_fcat.

  ls_fcat-fieldname   = 'MSC_AB'.   "Feldname interne Tabelle
  ls_fcat-reptext      = 'Begin MSC'.
  ls_fcat-hotspot = 'X'.
  APPEND ls_fcat TO ct_fcat.
  CLEAR ls_fcat.

  ls_fcat-fieldname   = 'MSC_END'.   "Feldname interne Tabelle
  ls_fcat-reptext      = 'Ende MSC'.
  ls_fcat-hotspot = 'X'.
  APPEND ls_fcat TO ct_fcat.
  CLEAR ls_fcat.

  ls_fcat-fieldname   = 'CASE'.   "Feldname interne Tabelle
  ls_fcat-reptext      = 'Fall'.
  ls_fcat-hotspot = 'X'.
  APPEND ls_fcat TO ct_fcat.
  CLEAR ls_fcat.

    ls_fcat-fieldname   = 'STATUS_BEAR'.   "Feldname interne Tabelle
  ls_fcat-reptext      = 'IB'.
  ls_fcat-checkbox = 'X'.
  ls_fcat-edit         = 'X'.
  APPEND ls_fcat TO ct_fcat.
  CLEAR ls_fcat.

  ls_fcat-fieldname   = 'STATUS_OK'.   "Feldname interne Tabelle
  ls_fcat-reptext      = 'OK'.
  ls_fcat-checkbox = 'X'.
  ls_fcat-edit         = 'X'.
  APPEND ls_fcat TO ct_fcat.
  CLEAR ls_fcat.

  ls_fcat-fieldname   = 'STATUS_REK'.   "Feldname interne Tabelle
  ls_fcat-reptext      = 'Rek'.
  ls_fcat-checkbox = 'X'.
  ls_fcat-edit         = 'X'.
  APPEND ls_fcat TO ct_fcat.
  CLEAR ls_fcat.


  ls_fcat-fieldname   = 'BEMERKUNG'.   "Feldname interne Tabelle
  ls_fcat-reptext      = 'Bemerkung, wird im Invoic Manager hinterlegt'.
  ls_fcat-edit         = 'X'.
  ls_fcat-outputlen    = '240'.
  APPEND ls_fcat TO ct_fcat.
  CLEAR ls_fcat.



** Field = Original Language
*ls_fcat-fieldname    = .         "Feldname der internen Tabelle
*ls_fcat-ref_field    = .         "Feldname des referenzierten Feldes Datenbanktabelle
*ls_fcat-ref_table    = .         "Tabellenname der referenzierten Datenbanktabelle
*ls_fcat-reptext      = .         "Überschriftbeschreibung
*ls_fcat-seltext      = .         "Überschriftbeschreibung
*ls_fcat-outputlen    = 10.       "Spaltenbreite
*ls_fcat-emphasize    = 'C300'.   "Spaltenfarbe (C300 = beige) zrebconstants=>cv_color_fcat_gelb
*ls_fcat-edit         = 'X'.      "Spalte ist eingabefähig
*APPEND ls_fcat TO ct_fcat.
*CLEAR ls_fcat.

ENDFORM.                    " alv_fcat

FORM handle_user_command USING i_ucomm.

ENDFORM.

FORM handle_double_click USING i_row i_col.
  DATA ls_ausgabe_sim LIKE LINE OF gt_ausgabe_sim.
  DATA ls_log_sim LIKE LINE OF gt_log_sim.
  DATA lt_msg TYPE esp1_message_tab_type.
  DATA ls_msg LIKE LINE OF lt_msg.
  READ TABLE gt_ausgabe_sim INDEX i_row INTO  ls_ausgabe_sim .
  CASE i_col.
    WHEN 'STATUS_SIM_VP'.
      READ TABLE gt_log_sim WITH KEY int_inv_doc_no = ls_ausgabe_sim-int_inv_doc_no verbrauchmsc = 'V' INTO
      ls_log_sim.

      LOOP AT ls_log_sim-messages INTO DATA(ls_message).
        MOVE-CORRESPONDING ls_message TO ls_msg.
        APPEND ls_msg TO lt_msg.
      ENDLOOP.

      CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
        TABLES
          i_message_tab = lt_msg.


      "ausgabe LOG
    WHEN 'STATUS_SIM_MSC'.
      READ TABLE gt_log_sim WITH KEY int_inv_doc_no = ls_ausgabe_sim-int_inv_doc_no verbrauchmsc = 'M'
      INTO ls_log_sim.
      LOOP AT ls_log_sim-messages INTO ls_message.
        MOVE-CORRESPONDING ls_message TO ls_msg.
        APPEND ls_msg TO lt_msg.
      ENDLOOP.

      CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
        TABLES
          i_message_tab = lt_msg.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.

FORM handle_hotspot_click USING i_row i_col.
  IF i_row = 'CASE'.
    DATA(lv_casenr) = gt_ausgabe_sim[ i_col ]-case.
    SET PARAMETER ID 'EMMA_CNR' FIELD lv_casenr.
    CALL TRANSACTION 'EMMAC3' AND SKIP FIRST SCREEN.
  ENDIF.


ENDFORM.

FORM handle_menu_button USING i_row i_col.

ENDFORM.

FORM handle_toolbar CHANGING i_object
                          i_interactive.
ENDFORM.

FORM select_data CHANGING ct_ausgabe_sim TYPE tt_ausgabe_sim.


  DATA ls_ausgabe_sim LIKE LINE OF ct_ausgabe_sim.
  DATA ls_inv_msc TYPE /adesso/inv_msc.
  DATA ls_inv_case TYPE /adesso/inv_case.
  DATA ls_head TYPE tinv_inv_head.
  DATA ls_doc TYPE tinv_inv_doc.
  DATA lv_stat TYPE inv_doc_status .
  LOOP AT gt_inv_doc_no INTO DATA(ls_inv_doc_no).

    SELECT SINGLE * FROM /adesso/inv_msc INTO ls_inv_msc WHERE int_inv_no = ls_inv_doc_no.
    SELECT SINGLE * FROM /adesso/inv_case INTO ls_inv_case WHERE int_inv_no = ls_inv_doc_no.
    ls_ausgabe_sim-int_inv_doc_no = ls_inv_doc_no.
    ls_ausgabe_sim-case = ls_inv_case-casenr.
    ls_ausgabe_sim-msc_end = ls_inv_msc-msc_end.
    ls_ausgabe_sim-msc_start = ls_inv_msc-msc_start.
    SELECT SINGLE * FROM tinv_inv_head INTO ls_head WHERE int_inv_no = ls_inv_doc_no.
    SELECT SINGLE * FROM tinv_inv_doc  INTO ls_doc WHERE int_inv_no = ls_inv_doc_no.
    CASE ls_head-invoice_status.
      WHEN '01'.
        ls_ausgabe_sim-status_old = '0'.
      WHEN '02'.
        ls_ausgabe_sim-status_old = '2'.
      WHEN '03'.
        ls_ausgabe_sim-status_old = '3'.
      WHEN OTHERS.
        ls_ausgabe_sim-status_old = '0'.
    ENDCASE .
    IF ls_doc-inv_doc_status = '09'.
      ls_ausgabe_sim-status_old = '1'.
    ENDIF.
    APPEND ls_ausgabe_sim TO gt_ausgabe_sim.

  ENDLOOP.


ENDFORM.
FORM get_process_data USING inv_doc_no CHANGING cs_inv_process_data TYPE inv_process_data .
  DATA ls_doc TYPE tinv_inv_doc.
  SELECT SINGLE * FROM tinv_inv_head INTO  cs_inv_process_data-inv_head WHERE int_inv_no = inv_doc_no.
  SELECT * FROM tinv_inv_doc INTO  TABLE cs_inv_process_data-inv_doc WHERE int_inv_no = inv_doc_no.
  SELECT * FROM tinv_inv_extid INTO  TABLE cs_inv_process_data-inv_extid WHERE int_inv_no = inv_doc_no.
  READ TABLE cs_inv_process_data-inv_doc INDEX 1 INTO ls_doc.
  SELECT * FROM tinv_inv_line_b INTO TABLE cs_inv_process_data-inv_line_b WHERE int_inv_doc_no = ls_doc-int_inv_doc_no.

ENDFORM.
FORM sim_verbrauch CHANGING  u_inv_process_data TYPE inv_process_data  cv_msc.
  DATA ls_control TYPE inv_control_data.
  DATA lt_return TYPE ttinv_log_msgbody.
  DATA ls_status TYPE inv_status_line.
  DATA ls_return TYPE t_log_sim.
  DATA lt_proc TYPE ttinv_process_data.
  CLEAR lt_proc.
  APPEND u_inv_process_data TO lt_proc.
  CALL FUNCTION 'Z_ADESSOINV_MANAGER_QUANTITY_N'
    EXPORTING
      x_control       = ls_control
    IMPORTING
      y_return        = lt_return
      y_status        = ls_status
*     Y_CHANGED       =
    CHANGING
      xy_process_data = lt_proc.

  ls_return-int_inv_doc_no = u_inv_process_data-inv_head-int_inv_no.
  ls_return-messages = lt_return.
  ls_return-verbrauchmsc = 'V'.
  APPEND ls_return TO gt_log_sim.

  CASE ls_status-status.
    WHEN '01'.
      cv_msc = icon_green_light.
    WHEN '02'.
      cv_msc = icon_yellow_light.
    WHEN '03'.
      cv_msc = icon_red_light.
    WHEN OTHERS.
      cv_msc = icon_light_out.
  ENDCASE .
*  APPEND ls_ausgabe_sim TO gt_ausgabe_sim.




ENDFORM.

FORM sim_msc CHANGING u_inv_process_data TYPE inv_process_data  cv_msc.
  DATA ls_return TYPE t_log_sim.
  DATA ls_control TYPE inv_control_data.
  DATA lt_return TYPE ttinv_log_msgbody.
  DATA ls_status TYPE inv_status_line.
  DATA lt_proc TYPE ttinv_process_data.
  CLEAR lt_proc.
  APPEND u_inv_process_data TO lt_proc.
  CALL FUNCTION 'Z_ADESSOINV_MANAGER_MSCONS'
    EXPORTING
      x_control       = ls_control
    IMPORTING
      y_return        = lt_return
      y_status        = ls_status
*     Y_CHANGED       =
    CHANGING
      xy_process_data = lt_proc.

  ls_return-int_inv_doc_no = u_inv_process_data-inv_head-int_inv_no.
  ls_return-messages = lt_return.
  ls_return-verbrauchmsc = 'M'.
  APPEND ls_return TO gt_log_sim.

  CASE ls_status-status.
    WHEN '01'.
      cv_msc = icon_green_light.
    WHEN '02'.
      cv_msc = icon_yellow_light.
    WHEN '03'.
      cv_msc = icon_red_light.
    WHEN OTHERS.
      cv_msc = icon_light_out.
  ENDCASE .
*  APPEND ls_ausgabe_sim TO gt_ausgabe_sim.

ENDFORM.

FORM msc_without_readingres  CHANGING cv_msg.

ENDFORM.
