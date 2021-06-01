class /ADZ/CL_BDR_ORDERS_REQ_CNTR definition
  public
  inheriting from /IDXGL/CL_BDR_ORDERS_REQ_CNTR
  final
  create public .

public section.

  data GT_BDR_CREATE_REQ type /ADZ/T_BDR_CREATE_REQ .

  methods CONSTRUCTOR
    importing
      !IS_BDR_ORDERS_HDR type /ADZ/S_BDR_ORDERS_HDR
      !IT_BDR_CREATE_REQ type /ADZ/T_BDR_CREATE_REQ
    raising
      /IDXGC/CX_PROCESS_ERROR .

  methods CREATE_ALV_GRID
    redefinition .
  methods HANDLE_OK_CODE
    redefinition .
protected section.

  methods GET_PROCESS_DATA
    importing
      !IT_BDR_CREATE_REQ type /ADZ/T_BDR_CREATE_REQ
    returning
      value(RS_PROC_DATA) type /IDXGC/S_PROC_DATA
    raising
      /IDXGC/CX_PROCESS_ERROR .

  methods BUILD_FIELDCAT
    redefinition .
  methods ON_DATA_CHANGED
    redefinition .
  methods ON_DOUBLE_CLICK
    redefinition .
  PRIVATE SECTION.

    DATA gv_serv_measval TYPE /idxgc/de_serv_measval .
ENDCLASS.



CLASS /ADZ/CL_BDR_ORDERS_REQ_CNTR IMPLEMENTATION.


  METHOD build_fieldcat.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: Kerkhoff-L, THIMEL-R                                                    Datum: 03.01.2019
*
* Beschreibung: Feldkatalog für ORDERS erzeugen
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    FIELD-SYMBOLS: <ls_fieldcat> TYPE lvc_s_fcat.

    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name = /adz/if_bdr_co=>gc_structure_bdr_create_req
      CHANGING
        ct_fieldcat      = et_fieldcat.

    LOOP AT et_fieldcat ASSIGNING <ls_fieldcat>.
*   Setze Standardeinsellungen für alle Spalten
      <ls_fieldcat>-col_pos    = 100.
      <ls_fieldcat>-valexi     = co_valexi_exclam.  "Deactivate domain value check
      <ls_fieldcat>-col_opt    = 'A'.
      <ls_fieldcat>-edit       = abap_true.
      <ls_fieldcat>-f4availabl = abap_false.
      <ls_fieldcat>-tech       = abap_true. "Blendet Spalte aus.

*   Einstellungen für Z30
      IF gs_bdr_hdr-docname_code = /adz/if_bdr_co=>gc_msg_category_z14.
        CASE <ls_fieldcat>-fieldname.
          WHEN co_fieldname_ext_ui.
            <ls_fieldcat>-col_pos    = 10.
            <ls_fieldcat>-col_opt    = abap_false.
            <ls_fieldcat>-tech       = abap_false.
            <ls_fieldcat>-f4availabl = abap_true.
            <ls_fieldcat>-lowercase  = abap_true.
          WHEN co_fieldname_sender.
            <ls_fieldcat>-col_pos    = 20.
            <ls_fieldcat>-tech       = abap_false.
          WHEN co_fieldname_receiver.
            <ls_fieldcat>-col_pos    = 30.
            <ls_fieldcat>-tech       = abap_false.
          WHEN co_fieldname_supply_direct.
            <ls_fieldcat>-col_pos    = 40.
            <ls_fieldcat>-tech       = abap_false.
          WHEN co_fieldname_async.
            <ls_fieldcat>-col_pos    = 50.
            <ls_fieldcat>-tech       = abap_false.
            <ls_fieldcat>-checkbox   = abap_true.
          WHEN co_fieldname_proc_ref.
            <ls_fieldcat>-col_pos    = 60.
            <ls_fieldcat>-tech       = abap_false.
            <ls_fieldcat>-edit       = abap_false.
          WHEN co_fieldname_status_text.
            <ls_fieldcat>-col_pos    = 70.
            <ls_fieldcat>-tech       = abap_false.
            <ls_fieldcat>-edit       = abap_false.
        ENDCASE.
      ENDIF.

*   Einstellungen für Z30
      IF gs_bdr_hdr-docname_code = /adz/if_bdr_co=>gc_msg_category_z30.
        CASE <ls_fieldcat>-fieldname.
          WHEN co_fieldname_ext_ui.
            <ls_fieldcat>-col_pos    = 10.
            <ls_fieldcat>-col_opt    = abap_false.
            <ls_fieldcat>-tech       = abap_false.
            <ls_fieldcat>-f4availabl = abap_true.
            <ls_fieldcat>-lowercase  = abap_true.
          WHEN co_fieldname_sender.
            <ls_fieldcat>-col_pos    = 20.
            <ls_fieldcat>-tech       = abap_false.
          WHEN co_fieldname_receiver.
            <ls_fieldcat>-col_pos    = 30.
            <ls_fieldcat>-tech       = abap_false.
          WHEN /adz/if_bdr_co=>gc_fieldname_execution_date.
            <ls_fieldcat>-col_pos    = 40.
            <ls_fieldcat>-tech       = abap_false.
          WHEN /adz/if_bdr_co=>gc_fieldname_settl_proc.
            <ls_fieldcat>-col_pos    = 50.
            <ls_fieldcat>-tech       = abap_false.
          WHEN /adz/if_bdr_co=>gc_fieldname_device_conf.
            <ls_fieldcat>-col_pos    = 60.
            <ls_fieldcat>-tech       = abap_false.
          WHEN co_fieldname_async.
            <ls_fieldcat>-col_pos    = 70.
            <ls_fieldcat>-tech       = abap_false.
            <ls_fieldcat>-checkbox   = abap_true.
          WHEN co_fieldname_proc_ref.
            <ls_fieldcat>-col_pos    = 80.
            <ls_fieldcat>-tech       = abap_false.
            <ls_fieldcat>-edit       = abap_false.
          WHEN co_fieldname_status_text.
            <ls_fieldcat>-col_pos    = 90.
            <ls_fieldcat>-tech       = abap_false.
            <ls_fieldcat>-edit       = abap_false.
        ENDCASE.
      ENDIF.

*   Einstellungen für Z31
      IF gs_bdr_hdr-docname_code = /adz/if_bdr_co=>gc_msg_category_z31.
        CASE <ls_fieldcat>-fieldname.
          WHEN co_fieldname_ext_ui.
            <ls_fieldcat>-col_pos    = 10.
            <ls_fieldcat>-col_opt    = abap_false.
            <ls_fieldcat>-tech       = abap_false.
            <ls_fieldcat>-f4availabl = abap_true.
            <ls_fieldcat>-lowercase  = abap_true.
          WHEN co_fieldname_sender.
            <ls_fieldcat>-col_pos    = 20.
            <ls_fieldcat>-tech       = abap_false.
          WHEN co_fieldname_receiver.
            <ls_fieldcat>-col_pos    = 30.
            <ls_fieldcat>-tech       = abap_false.
          WHEN /adz/if_bdr_co=>gc_fieldname_execution_date.
            <ls_fieldcat>-col_pos    = 40.
            <ls_fieldcat>-tech       = abap_false.
          WHEN /adz/if_bdr_co=>gc_fieldname_kennziff.
            <ls_fieldcat>-col_pos    = 50.
            <ls_fieldcat>-tech       = abap_false.
          WHEN /adz/if_bdr_co=>gc_fieldname_tarif_alloc.
            <ls_fieldcat>-col_pos    = 60.
            <ls_fieldcat>-tech       = abap_false.
          WHEN /adz/if_bdr_co=>gc_fieldname_cons_type.
            <ls_fieldcat>-col_pos    = 70.
            <ls_fieldcat>-tech       = abap_false.
          WHEN /adz/if_bdr_co=>gc_fieldname_appl_interrupt.
            <ls_fieldcat>-col_pos    = 80.
            <ls_fieldcat>-tech       = abap_false.
          WHEN /adz/if_bdr_co=>gc_fieldname_heat_consumpt.
            <ls_fieldcat>-col_pos    = 90.
            <ls_fieldcat>-tech       = abap_false.

          WHEN /adz/if_bdr_co=>gc_fieldname_za7_z84.
            <ls_fieldcat>-col_pos    = 100.
            <ls_fieldcat>-checkbox   = abap_true.
            <ls_fieldcat>-tech       = abap_false.
            <ls_fieldcat>-emphasize  = 'C111'.
          WHEN /adz/if_bdr_co=>gc_fieldname_za7_z85.
            <ls_fieldcat>-col_pos    = 101.
            <ls_fieldcat>-checkbox   = abap_true.
            <ls_fieldcat>-tech       = abap_false.
            <ls_fieldcat>-emphasize  = 'C111'.
          WHEN /adz/if_bdr_co=>gc_fieldname_za7_z86.
            <ls_fieldcat>-col_pos    = 102.
            <ls_fieldcat>-checkbox   = abap_true.
            <ls_fieldcat>-tech       = abap_false.
            <ls_fieldcat>-emphasize  = 'C111'.
          WHEN /adz/if_bdr_co=>gc_fieldname_za7_z47.
            <ls_fieldcat>-col_pos    = 103.
            <ls_fieldcat>-checkbox   = abap_true.
            <ls_fieldcat>-tech       = abap_false.
            <ls_fieldcat>-emphasize  = 'C111'.

          WHEN /adz/if_bdr_co=>gc_fieldname_za8_z84.
            <ls_fieldcat>-col_pos    = 110.
            <ls_fieldcat>-checkbox   = abap_true.
            <ls_fieldcat>-tech       = abap_false.
            <ls_fieldcat>-emphasize  = 'C511'.
          WHEN /adz/if_bdr_co=>gc_fieldname_za8_z85.
            <ls_fieldcat>-col_pos    = 111.
            <ls_fieldcat>-checkbox   = abap_true.
            <ls_fieldcat>-tech       = abap_false.
            <ls_fieldcat>-emphasize  = 'C511'.
          WHEN /adz/if_bdr_co=>gc_fieldname_za8_z86.
            <ls_fieldcat>-col_pos    = 112.
            <ls_fieldcat>-checkbox   = abap_true.
            <ls_fieldcat>-tech       = abap_false.
            <ls_fieldcat>-emphasize  = 'C511'.
          WHEN /adz/if_bdr_co=>gc_fieldname_za8_z92.
            <ls_fieldcat>-col_pos    = 113.
            <ls_fieldcat>-checkbox   = abap_true.
            <ls_fieldcat>-tech       = abap_false.
            <ls_fieldcat>-emphasize  = 'C511'.
          WHEN /adz/if_bdr_co=>gc_fieldname_za8_z47.
            <ls_fieldcat>-col_pos    = 114.
            <ls_fieldcat>-checkbox   = abap_true.
            <ls_fieldcat>-tech       = abap_false.
            <ls_fieldcat>-emphasize  = 'C511'.

          WHEN /adz/if_bdr_co=>gc_fieldname_za9_z85.
            <ls_fieldcat>-col_pos    = 120.
            <ls_fieldcat>-checkbox   = abap_true.
            <ls_fieldcat>-tech       = abap_false.
            <ls_fieldcat>-emphasize  = 'C711'.

          WHEN co_fieldname_async.
            <ls_fieldcat>-col_pos    = 130.
            <ls_fieldcat>-tech       = abap_false.
            <ls_fieldcat>-checkbox   = abap_true.
          WHEN co_fieldname_proc_ref.
            <ls_fieldcat>-col_pos    = 140.
            <ls_fieldcat>-tech       = abap_false.
            <ls_fieldcat>-edit       = abap_false.
          WHEN co_fieldname_status_text.
            <ls_fieldcat>-col_pos    = 150.
            <ls_fieldcat>-tech       = abap_false.
            <ls_fieldcat>-edit       = abap_false.
        ENDCASE.
      ENDIF.

*   Einstellungen für Z34
      IF gs_bdr_hdr-docname_code = /adz/if_bdr_co=>gc_msg_category_z34.
        CASE <ls_fieldcat>-fieldname.
          WHEN co_fieldname_ext_ui.
            <ls_fieldcat>-col_pos    = 01.
            <ls_fieldcat>-col_opt    = abap_false.
            <ls_fieldcat>-tech       = abap_false.
            <ls_fieldcat>-f4availabl = abap_true.
            <ls_fieldcat>-outputlen  = 29.
          WHEN co_fieldname_supply_direct.
            <ls_fieldcat>-col_pos    = 02.
            <ls_fieldcat>-tech       = abap_false.
          WHEN /adz/if_bdr_co=>gc_fieldname_text_subj_qual.
            <ls_fieldcat>-col_pos    = 10.
            <ls_fieldcat>-tech       = abap_false.
            <ls_fieldcat>-f4availabl = abap_true.
          WHEN /adz/if_bdr_co=>gc_fieldname_free_text_value.
            <ls_fieldcat>-col_pos    = 11.
            <ls_fieldcat>-col_opt    = abap_false.
            <ls_fieldcat>-tech       = abap_false.
            <ls_fieldcat>-outputlen  = 20.
            <ls_fieldcat>-lowercase  = abap_false.
          WHEN co_fieldname_sender.
            <ls_fieldcat>-col_pos    = 20.
            <ls_fieldcat>-tech       = abap_false.
          WHEN co_fieldname_receiver.
            <ls_fieldcat>-col_pos    = 21.
            <ls_fieldcat>-tech       = abap_false.
          WHEN /adz/if_bdr_co=>gc_fieldname_ref_no.
            <ls_fieldcat>-col_pos    = 30.
            <ls_fieldcat>-col_opt    = abap_false.
            <ls_fieldcat>-tech       = abap_false.
            <ls_fieldcat>-outputlen  = 20.
            <ls_fieldcat>-emphasize  = 'C111'.
          WHEN /adz/if_bdr_co=>gc_fieldname_ref_msg_date.
            <ls_fieldcat>-col_pos    = 31.
            <ls_fieldcat>-col_opt    = abap_false.
            <ls_fieldcat>-tech       = abap_false.
            <ls_fieldcat>-outputlen  = 10.
            <ls_fieldcat>-coltext    = 'Datum der Referenzierten Nachricht'.
            <ls_fieldcat>-emphasize  = 'C111'.
          WHEN /adz/if_bdr_co=>gc_fieldname_ref_msg_time.
            <ls_fieldcat>-col_pos    = 32.
            <ls_fieldcat>-col_opt    = abap_false.
            <ls_fieldcat>-tech       = abap_false.
            <ls_fieldcat>-outputlen  = 10.
            <ls_fieldcat>-coltext    = 'Zeit der Referenzierten Nachricht'.
            <ls_fieldcat>-emphasize  = 'C111'.
          WHEN /adz/if_bdr_co=>gc_fieldname_reg_code.
            <ls_fieldcat>-col_pos    = 50.
            <ls_fieldcat>-col_opt    = abap_false.
            <ls_fieldcat>-tech       = abap_false.
            <ls_fieldcat>-outputlen  = 15.
            "<ls_fieldcat>-emphasize = 'C511'.
          WHEN /adz/if_bdr_co=>gc_fieldname_start_read_date.
            <ls_fieldcat>-col_pos    = 60.
            <ls_fieldcat>-col_opt    = abap_false.
            <ls_fieldcat>-tech       = abap_false.
            <ls_fieldcat>-outputlen  = 10.
            <ls_fieldcat>-emphasize  = 'C511'.
          WHEN /adz/if_bdr_co=>gc_fieldname_start_read_time.
            <ls_fieldcat>-col_pos    = 61.
            <ls_fieldcat>-col_opt    = abap_false.
            <ls_fieldcat>-tech       = abap_false.
            <ls_fieldcat>-outputlen  = 10.
            <ls_fieldcat>-emphasize  = 'C511'.
          WHEN /adz/if_bdr_co=>gc_fieldname_start_read_offs.
            <ls_fieldcat>-col_pos    = 62.
            <ls_fieldcat>-col_opt    = abap_false.
            <ls_fieldcat>-tech       = abap_false.
            <ls_fieldcat>-outputlen  = 7.
            <ls_fieldcat>-emphasize  = 'C511'.
          WHEN /adz/if_bdr_co=>gc_fieldname_end_read_date.
            <ls_fieldcat>-col_pos    = 70.
            <ls_fieldcat>-col_opt    = abap_false.
            <ls_fieldcat>-tech       = abap_false.
            <ls_fieldcat>-outputlen  = 10.
            <ls_fieldcat>-emphasize  = 'C711'.
          WHEN /adz/if_bdr_co=>gc_fieldname_end_read_time.
            <ls_fieldcat>-col_pos    = 71.
            <ls_fieldcat>-col_opt    = abap_false.
            <ls_fieldcat>-tech       = abap_false.
            <ls_fieldcat>-outputlen  = 10.
            <ls_fieldcat>-emphasize  = 'C711'.
          WHEN /adz/if_bdr_co=>gc_fieldname_end_read_offs.
            <ls_fieldcat>-col_pos    = 72.
            <ls_fieldcat>-col_opt    = abap_false.
            <ls_fieldcat>-tech       = abap_false.
            <ls_fieldcat>-outputlen  = 7.
            <ls_fieldcat>-emphasize  = 'C711'.
          WHEN co_fieldname_async.
            <ls_fieldcat>-col_pos    = 80.
            <ls_fieldcat>-tech       = abap_false.
            <ls_fieldcat>-checkbox   = abap_true.
          WHEN co_fieldname_status_text.
            <ls_fieldcat>-col_pos    = 81.
            <ls_fieldcat>-tech       = abap_false.
            <ls_fieldcat>-edit       = abap_false.
          WHEN co_fieldname_proc_ref.
            <ls_fieldcat>-col_pos    = 82.
            <ls_fieldcat>-tech       = abap_false.
            <ls_fieldcat>-edit       = abap_false.
        ENDCASE.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD constructor.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: WISNIEWSKI-P, KERKHOFF-L                                                Datum: 03.01.2019
*
* Beschreibung: Tabelle statt Struktur benutzen und Dummy-Werte in Standard Header schreiben um
*   Ausnahme zu verhindern.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    DATA: ls_bdr_orders_hdr TYPE /adz/s_bdr_orders_hdr.

    ls_bdr_orders_hdr = is_bdr_orders_hdr.
    IF ls_bdr_orders_hdr-sender IS INITIAL.
      ls_bdr_orders_hdr-sender = 'XX_NONE_XX'.
    ENDIF.
    IF ls_bdr_orders_hdr-receiver IS INITIAL.
      ls_bdr_orders_hdr-receiver = 'XX_NONE_XX'.
    ENDIF.

    super->constructor( is_bdr_orders_hdr = ls_bdr_orders_hdr-hdr ).

    gv_serv_measval   = ls_bdr_orders_hdr-serv_measval.
    gt_bdr_create_req = it_bdr_create_req.
    gs_bdr_hdr        = is_bdr_orders_hdr.
  ENDMETHOD.


  METHOD create_alv_grid.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R, WISNIEWSKI-P                                                  Datum: 05.07.2019
*
* Beschreibung: ALV-Grid erstellen
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************

    DATA: lt_fieldcat TYPE lvc_t_fcat.
    DATA: ls_variant  TYPE disvariant.
    DATA: ls_layout   TYPE lvc_s_layo.
    DATA: lt_exclude  TYPE ui_functions.


    FIELD-SYMBOLS: <fs_orders_req> TYPE /adz/s_bdr_create_req." /idxgc/s_ui_bdr_orders_req.

    CALL FUNCTION 'LVC_VARIANT_DEFAULT_GET'
      EXPORTING
        i_save     = 'A'
      CHANGING
        cs_variant = ls_variant
      EXCEPTIONS
        OTHERS     = 1.

    IF sy-subrc <> 0.
      ls_variant-report = /adz/if_bdr_co=>gc_fieldname_bdr_pdoc_create.
    ENDIF.

    ls_layout-smalltitle = cl_isu_flag=>co_true.
    ls_layout-stylefname = 'CELLSTYLE'.

    IF me->grid_container IS INITIAL.
      CREATE OBJECT me->grid_container
        EXPORTING
          container_name = co_orders_container.

      IF me->alv_grid IS INITIAL.
* append a initial line to the out alv grid
        IF me->gt_bdr_create_req IS INITIAL.
          APPEND INITIAL LINE TO me->gt_bdr_create_req ASSIGNING <fs_orders_req>.
        ENDIF.

        CREATE OBJECT me->alv_grid
          EXPORTING
            i_parent = me->grid_container.

        CALL METHOD me->build_fieldcat
          IMPORTING
            et_fieldcat = lt_fieldcat.

        me->gt_fieldcat = lt_fieldcat.

        CALL METHOD me->exclude_grid_functions
          CHANGING
            ct_ui_functions_exclude = lt_exclude.

* display the input screen of request data
        CALL METHOD me->alv_grid->set_table_for_first_display
          EXPORTING
            i_structure_name     = /adz/if_bdr_co=>gc_structure_bdr_create_req
            is_variant           = ls_variant
            i_default            = cl_isu_flag=>co_true
            i_save               = 'A'
            is_layout            = ls_layout
            it_toolbar_excluding = lt_exclude
          CHANGING
            it_outtab            = me->gt_bdr_create_req
            it_fieldcatalog      = lt_fieldcat.

        alv_grid->get_frontend_fieldcatalog( IMPORTING et_fieldcatalog = gt_fieldcat ).

* set layout
        CALL METHOD me->alv_grid->set_frontend_layout
          EXPORTING
            is_layout = ls_layout.

* register edit event
        CALL METHOD me->alv_grid->register_edit_event
          EXPORTING
            i_event_id = cl_gui_alv_grid=>mc_evt_modified
          EXCEPTIONS
            error      = 1
            OTHERS     = 2.

* allow edit
        CALL METHOD me->alv_grid->set_ready_for_input
          EXPORTING
            i_ready_for_input = 1.

* set handler
        SET HANDLER
            me->on_double_click
            me->on_data_changed
            FOR me->alv_grid.

      ENDIF.

    ELSE.

      CALL METHOD me->alv_grid->refresh_table_display.

    ENDIF.

  ENDMETHOD.


  METHOD get_process_data.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 03.01.2019
*
* Beschreibung: Struktur mit Prozessdaten füllen.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    DATA: ls_proc_step        TYPE /idxgc/s_proc_step_data,
          ls_proc_step_config TYPE /idxgc/s_proc_step_config_all.

    FIELD-SYMBOLS: <ls_ord_item_add> TYPE /idxgc/s_ord_item_details.

    IF lines( it_bdr_create_req ) = 0.
      RETURN.
    ENDIF.

* Set the process header data
    rs_proc_data-proc_id          = it_bdr_create_req[ 1 ]-proc_id.
    rs_proc_data-proc_type        = it_bdr_create_req[ 1 ]-proc_type.
    rs_proc_data-proc_view        = it_bdr_create_req[ 1 ]-proc_view.
    rs_proc_data-proc_date        = sy-datum. "Wird unten ggf. noch überschrieben
    rs_proc_data-key_docname_code = it_bdr_create_req[ 1 ]-docname_code.

    IF it_bdr_create_req[ 1 ]-ext_ui IS NOT INITIAL.
      TRY.
          /idxgc/cl_utility_service_isu=>get_intui_from_extui( EXPORTING iv_ext_ui = it_bdr_create_req[ 1 ]-ext_ui
                                                                         iv_date   = sy-datum
                                                               IMPORTING rv_int_ui = rs_proc_data-int_ui ).
          IF rs_proc_data-int_ui IS NOT INITIAL.
            rs_proc_data-spartyp = /idxgc/cl_utility_service_isu=>get_divcat_from_intui( iv_int_ui    = rs_proc_data-int_ui
                                                                                         iv_proc_date = sy-datum ).
          ENDIF.
        CATCH /idxgc/cx_utility_error .
*       Ignore this error
      ENDTRY.
    ENDIF.

* Prepare the process step data
    ls_proc_step-own_servprov   = it_bdr_create_req[ 1 ]-sender.
    ls_proc_step-assoc_servprov = it_bdr_create_req[ 1 ]-receiver.
    ls_proc_step-ext_ui         = it_bdr_create_req[ 1 ]-ext_ui.
    ls_proc_step-supply_direct  = it_bdr_create_req[ 1 ]-supply_direct.
    ls_proc_step-docname_code   = it_bdr_create_req[ 1 ]-docname_code.

* Populate initial message date and time
    ls_proc_step-msg_date = sy-datum.
    ls_proc_step-msg_time = sy-uzeit.

* Get first step number
    READ TABLE gs_proc_config-steps INTO ls_proc_step_config
      WITH KEY category = /idxgc/if_constants_add=>gc_proc_step_cat_init
               source   = /idxgc/if_constants_add=>gc_owner_type_cust.
    IF sy-subrc EQ 0.
      ls_proc_step-proc_step_no = ls_proc_step_config-proc_step_no.
    ELSE.
      READ TABLE gs_proc_config-steps INTO ls_proc_step_config
        WITH KEY category = /idxgc/if_constants_add=>gc_proc_step_cat_init
                 source   = /idxgc/if_constants_add=>gc_owner_type_sap.
      IF sy-subrc EQ 0.
        ls_proc_step-proc_step_no = ls_proc_step_config-proc_step_no.
      ENDIF.
    ENDIF.

    IF ls_proc_step-docname_code = /adz/if_bdr_co=>gc_msg_category_z30.
      rs_proc_data-proc_date            = it_bdr_create_req[ 1 ]-execution_date.
      ls_proc_step-execution_date       = it_bdr_create_req[ 1 ]-execution_date.

      APPEND INITIAL LINE TO ls_proc_step-ord_item_add ASSIGNING <ls_ord_item_add>.
      <ls_ord_item_add>-item_id         = 1.
      <ls_ord_item_add>-settl_proc      = it_bdr_create_req[ 1 ]-settl_proc.
      <ls_ord_item_add>-device_conf     = it_bdr_create_req[ 1 ]-device_conf.

    ELSEIF ls_proc_step-docname_code    = /adz/if_bdr_co=>gc_msg_category_z31.

      rs_proc_data-proc_date            = it_bdr_create_req[ 1 ]-execution_date.
      ls_proc_step-execution_date       = it_bdr_create_req[ 1 ]-execution_date.

      DATA(lv_item_id) = 1.
      ASSIGN ls_proc_step-reg_code_data TO FIELD-SYMBOL(<lt_reg_code_data>).
      ASSIGN ls_proc_step-/idxgl/data_relevance TO FIELD-SYMBOL(<lt_data_relevance>).

      LOOP AT it_bdr_create_req ASSIGNING FIELD-SYMBOL(<ls_bdr_create_req>).
        ls_proc_step-ord_item_add = VALUE #( BASE ls_proc_step-ord_item_add ( item_id = lv_item_id ) ).

        <lt_reg_code_data> = VALUE #( BASE <lt_reg_code_data> ( item_id        = lv_item_id
                                                                reg_code       = <ls_bdr_create_req>-kennziff
                                                                tarif_alloc    = <ls_bdr_create_req>-tarif_alloc
                                                                cons_type      = <ls_bdr_create_req>-cons_type
                                                                heat_consumpt  = <ls_bdr_create_req>-heat_consumpt
                                                                appl_interrupt = <ls_bdr_create_req>-appl_interrupt ) ).
        IF <ls_bdr_create_req>-za7_z84 = abap_true.
          <lt_data_relevance> = VALUE #( BASE <lt_data_relevance> ( item_id    = lv_item_id
                                                                    data_mrrel = /idxgl/if_constants_ide=>gc_data_mrrel_za7
                                                                    data_use   = /idxgl/if_constants_ide=>gc_data_use_z84 ) ).
        ENDIF.
        IF <ls_bdr_create_req>-za7_z85 = abap_true.
          <lt_data_relevance> = VALUE #( BASE <lt_data_relevance> ( item_id    = lv_item_id
                                                                    data_mrrel = /idxgl/if_constants_ide=>gc_data_mrrel_za7
                                                                    data_use   = /idxgl/if_constants_ide=>gc_data_use_z85 ) ).
        ENDIF.
        IF <ls_bdr_create_req>-za7_z86 = abap_true.
          <lt_data_relevance> = VALUE #( BASE <lt_data_relevance> ( item_id    = lv_item_id
                                                                    data_mrrel = /idxgl/if_constants_ide=>gc_data_mrrel_za7
                                                                    data_use   = /idxgl/if_constants_ide=>gc_data_use_z86 ) ).
        ENDIF.
        IF <ls_bdr_create_req>-za7_z47 = abap_true.
          <lt_data_relevance> = VALUE #( BASE <lt_data_relevance> ( item_id    = lv_item_id
                                                                    data_mrrel = /idxgl/if_constants_ide=>gc_data_mrrel_za7
                                                                    data_use   = /idxgl/if_constants_ide=>gc_data_use_z47 ) ).
        ENDIF.
        IF <ls_bdr_create_req>-za8_z84 = abap_true.
          <lt_data_relevance> = VALUE #( BASE <lt_data_relevance> ( item_id    = lv_item_id
                                                                    data_mrrel = /idxgl/if_constants_ide=>gc_data_mrrel_za8
                                                                    data_use   = /idxgl/if_constants_ide=>gc_data_use_z84 ) ).
        ENDIF.
        IF <ls_bdr_create_req>-za8_z85 = abap_true.
          <lt_data_relevance> = VALUE #( BASE <lt_data_relevance> ( item_id    = lv_item_id
                                                                    data_mrrel = /idxgl/if_constants_ide=>gc_data_mrrel_za8
                                                                    data_use   = /idxgl/if_constants_ide=>gc_data_use_z85 ) ).
        ENDIF.
        IF <ls_bdr_create_req>-za8_z86 = abap_true.
          <lt_data_relevance> = VALUE #( BASE <lt_data_relevance> ( item_id    = lv_item_id
                                                                    data_mrrel = /idxgl/if_constants_ide=>gc_data_mrrel_za8
                                                                    data_use   = /idxgl/if_constants_ide=>gc_data_use_z86 ) ).
        ENDIF.
        IF <ls_bdr_create_req>-za8_z92 = abap_true.
          <lt_data_relevance> = VALUE #( BASE <lt_data_relevance> ( item_id    = lv_item_id
                                                                    data_mrrel = /idxgl/if_constants_ide=>gc_data_mrrel_za8
                                                                    data_use   = /idxgl/if_constants_ide=>gc_data_use_z92 ) ).
        ENDIF.
        IF <ls_bdr_create_req>-za8_z47 = abap_true.
          <lt_data_relevance> = VALUE #( BASE <lt_data_relevance> ( item_id    = lv_item_id
                                                                    data_mrrel = /idxgl/if_constants_ide=>gc_data_mrrel_za8
                                                                    data_use   = /idxgl/if_constants_ide=>gc_data_use_z47 ) ).
        ENDIF.
        IF <ls_bdr_create_req>-za9_z85 = abap_true.
          <lt_data_relevance> = VALUE #( BASE <lt_data_relevance> ( item_id    = lv_item_id
                                                                    data_mrrel = /idxgl/if_constants_ide=>gc_data_mrrel_za9
                                                                    data_use   = /idxgl/if_constants_ide=>gc_data_use_z85 ) ).
        ENDIF.

        lv_item_id = lv_item_id + 1.
      ENDLOOP.


    ELSEIF ls_proc_step-docname_code    = /adz/if_bdr_co=>gc_msg_category_z34.
      ls_proc_step-serv_measval         = it_bdr_create_req[ 1 ]-serv_measval.

      APPEND INITIAL LINE TO ls_proc_step-ord_item_add ASSIGNING <ls_ord_item_add>.
      <ls_ord_item_add>-item_id         = 1.
      <ls_ord_item_add>-start_read_date = it_bdr_create_req[ 1 ]-start_read_date.
      <ls_ord_item_add>-start_read_time = it_bdr_create_req[ 1 ]-start_read_time.
      <ls_ord_item_add>-start_read_offs = it_bdr_create_req[ 1 ]-start_read_offs.
      <ls_ord_item_add>-end_read_date   = it_bdr_create_req[ 1 ]-end_read_date.
      <ls_ord_item_add>-end_read_time   = it_bdr_create_req[ 1 ]-end_read_time.
      <ls_ord_item_add>-end_read_offs   = it_bdr_create_req[ 1 ]-end_read_offs.

      APPEND INITIAL LINE TO ls_proc_step-ref_to_msg ASSIGNING FIELD-SYMBOL(<ls_ref_to_msg>).
      <ls_ref_to_msg>-ref_qual          = /idxgc/if_constants_ide=>gc_rff_02_qual_acw.
      <ls_ref_to_msg>-ref_no            = it_bdr_create_req[ 1 ]-ref_no.
      <ls_ref_to_msg>-ref_msg_date      = it_bdr_create_req[ 1 ]-ref_msg_date.
      <ls_ref_to_msg>-ref_msg_time      = it_bdr_create_req[ 1 ]-ref_msg_time.

      APPEND INITIAL LINE TO ls_proc_step-msgcomments ASSIGNING FIELD-SYMBOL(<ls_msgcomment>).
      <ls_msgcomment>-item_id           = 1.
      <ls_msgcomment>-text_subj_qual    = it_bdr_create_req[ 1 ]-text_subj_qual.
      <ls_msgcomment>-free_text_value   = it_bdr_create_req[ 1 ]-free_text_value.

      APPEND INITIAL LINE TO ls_proc_step-reg_code_data ASSIGNING FIELD-SYMBOL(<ls_reg_code>).
      <ls_reg_code>-item_id             = 1.
      <ls_reg_code>-reg_code            = it_bdr_create_req[ 1 ]-reg_code.
    ENDIF.

    APPEND ls_proc_step TO rs_proc_data-steps.
  ENDMETHOD.


  METHOD handle_ok_code.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R, WISNIEWSKI-P                                                  Datum: 10.07.2019
*
* Beschreibung: Ablaufsteuerung
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* THIMEL-R    01.11.2019 Anpassung für ORDERS Z31 neue Formate
***************************************************************************************************
    TYPES: BEGIN OF ts_bdr_create_cluster,
             ext_ui         TYPE ext_ui,
             bdr_create_req TYPE /adz/t_bdr_create_req,
           END OF ts_bdr_create_cluster,
           tt_bdr_create_cluster TYPE TABLE OF ts_bdr_create_cluster.
    DATA: lt_bdr_create_cluster TYPE tt_bdr_create_cluster,
          lt_cell               TYPE lvc_t_ceno,
          ls_cell               TYPE lvc_s_ceno,
          lt_fieldnames         TYPE /idxgc/t_fieldnames,
          lv_fieldname          TYPE name_feld,
          ls_fieldcat           TYPE lvc_s_fcat,
          ls_proc_data          TYPE /idxgc/s_proc_data,
          lt_check_result       TYPE /idxgc/t_check_result_final,
          lr_process_log        TYPE REF TO /idxgc/if_process_log,
          lt_row                TYPE lvc_t_row,
          lv_error_flag         TYPE flag,
          lv_error_proc         TYPE flag,
          lv_index              TYPE i,
          lv_index_char         TYPE char20,
          ls_style              TYPE lvc_s_styl,
          lt_proc_log           TYPE /idxgc/t_pdoc_log,
          ls_proc_log           TYPE /idxgc/s_pdoc_log,
          lref_error            TYPE REF TO cl_isu_error_log,
          lv_lines              TYPE i,
          lv_object             TYPE swo_objtyp,
          lv_key                TYPE eidegenerickey,
          ls_obj                TYPE eideswtdoc_dialog_object,
          lt_errors             TYPE smt_error_tab,
          lv_cur_line           TYPE str.

    FIELD-SYMBOLS: <fs_row>                TYPE lvc_s_row,
                   <fs_fcat>               TYPE lvc_s_fcat,
                   <ls_bdr_create_cluster> TYPE ts_bdr_create_cluster.

    CASE gv_okcode.
      WHEN cl_isu_okcode=>co_back OR
           cl_isu_okcode=>co_canc.
        me->free_object( ).
        LEAVE TO SCREEN 0.

      WHEN cl_isu_okcode=>co_exit.
        me->free_object( ).
        LEAVE PROGRAM.

      WHEN cl_isu_okcode=>co_chck OR co_send.

        me->alv_grid->check_changed_data( ).

* check data
        CLEAR lv_error_flag.
        CLEAR lv_index.
        CREATE OBJECT lref_error.

        "Für Z31 können mehrere zusammengehörige Zeilen angegeben werden, daher wird hier in einem Cluster zusammenfassen
        LOOP AT gt_bdr_create_req ASSIGNING FIELD-SYMBOL(<ls_bdr_create_req>).
          IF <ls_bdr_create_req>-proc_id IS INITIAL.
            <ls_bdr_create_req>-proc_id = gs_bdr_hdr-proc_id.
          ENDIF.
          IF <ls_bdr_create_req>-proc_type IS INITIAL.
            <ls_bdr_create_req>-proc_type = gs_bdr_hdr-proc_type.
          ENDIF.
          IF <ls_bdr_create_req>-proc_view IS INITIAL.
            <ls_bdr_create_req>-proc_view = gs_bdr_hdr-proc_view.
          ENDIF.
          IF <ls_bdr_create_req>-docname_code IS INITIAL.
            <ls_bdr_create_req>-docname_code = gs_bdr_hdr-docname_code.
          ENDIF.
          IF <ls_bdr_create_req>-serv_measval IS INITIAL.
            <ls_bdr_create_req>-serv_measval = gv_serv_measval.
          ENDIF.

          IF gs_bdr_hdr-docname_code = /adz/if_bdr_co=>gc_msg_category_z31 AND line_exists( lt_bdr_create_cluster[ ext_ui = <ls_bdr_create_req>-ext_ui ] ).
            lt_bdr_create_cluster[ ext_ui = <ls_bdr_create_req>-ext_ui ]-bdr_create_req
              = VALUE #( BASE lt_bdr_create_cluster[ ext_ui = <ls_bdr_create_req>-ext_ui ]-bdr_create_req ( <ls_bdr_create_req> ) ) .
          ELSE.
            lt_bdr_create_cluster = VALUE #( BASE lt_bdr_create_cluster ( ext_ui = <ls_bdr_create_req>-ext_ui bdr_create_req = VALUE #( ( <ls_bdr_create_req> ) ) ) ).
          ENDIF.
        ENDLOOP.


        LOOP AT lt_bdr_create_cluster ASSIGNING <ls_bdr_create_cluster>.
          lv_index = lv_index + 1.
          lv_index_char = CONV char20( lv_index ).
          CONDENSE lv_index_char.

          CLEAR: lt_fieldnames.

          ls_proc_data = get_process_data( <ls_bdr_create_cluster>-bdr_create_req ).

          /adz/cl_bdr_utility=>check_orders_data( EXPORTING is_proc_step_data = CONV #( ls_proc_data-steps[ 1 ] )
                                                  IMPORTING et_fieldnames     = lt_fieldnames
                                                            et_errors         = lt_errors ).

          IF lt_fieldnames IS NOT INITIAL OR lt_errors IS NOT INITIAL.
            lv_error_flag = cl_isu_flag=>co_true.
            LOOP AT lt_errors ASSIGNING FIELD-SYMBOL(<ls_error>).
              lref_error->add_message( EXPORTING x_msgid = <ls_error>-msgid
                                                 x_msgno = CONV #( <ls_error>-msgno )
                                                 x_msgty = <ls_error>-msgty
                                                 x_msgv1 = |Zeile | && lv_index_char && |: |
                                                 x_msgv2 = CONV char20( <ls_error>-msgv2 )
                                                 x_msgv3 = CONV char20( <ls_error>-msgv3 )
                                                 x_msgv4 = CONV char20( <ls_error>-msgv4 ) ).
            ENDLOOP.

*           Get the colmn about the field
            LOOP AT lt_fieldnames INTO lv_fieldname.
              READ TABLE gt_fieldcat INTO ls_fieldcat WITH KEY fieldname = lv_fieldname.
              IF sy-subrc = 0.
                CLEAR: ls_cell.
                ls_cell-col_id = ls_fieldcat-col_pos.
                ls_cell-row_id = lv_index.
                APPEND ls_cell TO lt_cell.
              ENDIF.
            ENDLOOP.
            IF lt_fieldnames IS INITIAL.
*             Get selected row
              APPEND INITIAL LINE TO lt_row ASSIGNING <fs_row>.
              <fs_row>-index = lv_index.
            ENDIF.
          ENDIF.
        ENDLOOP.
        me->alv_grid->refresh_table_display( ).

        IF lt_cell IS NOT INITIAL.
          CALL METHOD me->alv_grid->set_selected_cells_id
            EXPORTING
              it_cells = lt_cell.
        ELSEIF lt_row IS NOT INITIAL.
          CALL METHOD me->alv_grid->set_selected_rows( it_index_rows = lt_row ).
        ENDIF.

*     Display any errors that occurred.
        lref_error->display_messages( EXCEPTIONS
                                      OTHERS = 1 ).
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

        IF gv_okcode = co_send AND lv_error_flag IS INITIAL.
*       send orders request if no error
          LOOP AT lt_bdr_create_cluster ASSIGNING <ls_bdr_create_cluster>.
            IF lines( <ls_bdr_create_cluster>-bdr_create_req ) = 0 OR
               NOT line_exists( <ls_bdr_create_cluster>-bdr_create_req[ proc_ref = '' ] ).
              CONTINUE.
            ENDIF.

            "Erstmal mit der ersten Zeile arbeiten. Die anderen werden später aktualisiert.
            ASSIGN <ls_bdr_create_cluster>-bdr_create_req[ 1 ] TO <ls_bdr_create_req>.

            CLEAR: ls_proc_data,
                   lt_check_result,
                   lr_process_log,
                   lv_error_proc.

            ls_proc_data = get_process_data( <ls_bdr_create_cluster>-bdr_create_req ).

            TRY.
                CALL METHOD /idxgc/cl_process_trigger=>start_process
                  EXPORTING
                    iv_only_synchronous   = <ls_bdr_create_req>-async
*                   iv_raise_trigger_event = /IDXGC/IF_CONSTANTS=>GC_FALSE
                    iv_no_commit          = /idxgc/if_constants=>gc_false
*                   iv_no_exception       = /IDXGC/IF_CONSTANTS=>GC_FALSE
                    iv_pdoc_display       = /idxgc/if_constants=>gc_false
                  IMPORTING
*                   ev_not_launchable     =
                    et_check_result_final = lt_check_result
*                   et_process_key_all    =
                    er_process_log        = lr_process_log
                  CHANGING
                    cs_process_data       = ls_proc_data.
              CATCH /idxgc/cx_process_error .
                lv_error_proc = cl_isu_flag=>co_true.
            ENDTRY.

*         Check the process log
            IF lr_process_log IS NOT INITIAL.
              LOOP AT lt_proc_log INTO ls_proc_log
                  WHERE msgty = /idxgc/if_constants_ide=>gc_msgty_e.
                MESSAGE ID ls_proc_log-msgid TYPE ls_proc_log-msgty NUMBER ls_proc_log-msgno
                        WITH ls_proc_log-msgv1 ls_proc_log-msgv2 ls_proc_log-msgv3 ls_proc_log-msgv4
                        INTO <ls_bdr_create_req>-status_text.
                lv_error_proc = cl_isu_flag=>co_true.
                EXIT.
              ENDLOOP.
            ENDIF.

            IF lv_error_proc IS INITIAL.
              IF ls_proc_data-proc_ref IS NOT INITIAL.
                <ls_bdr_create_req>-proc_ref = ls_proc_data-proc_ref.
              ENDIF.

              MESSAGE s092(/idxgc/process) INTO <ls_bdr_create_req>-status_text.

*           de-activate the edit mode for success records.
              LOOP AT me->gt_fieldcat ASSIGNING <fs_fcat>.
                ls_style-fieldname  = <fs_fcat>-fieldname.
                ls_style-style     = cl_gui_alv_grid=>mc_style_disabled.
                ls_style-maxlen    = 8.
                INSERT ls_style INTO TABLE <ls_bdr_create_req>-cellstyle.
              ENDLOOP.

            ELSE.
              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                      INTO <ls_bdr_create_req>-status_text.
            ENDIF.

          ENDLOOP.

*       IF there is only one PDoc created, then open it immediatedly
          IF lines( lt_bdr_create_cluster ) = 1 AND lines( lt_bdr_create_cluster[ 1 ]-bdr_create_req ) > 0 AND
             lt_bdr_create_cluster[ 1 ]-bdr_create_req[ 1 ]-proc_ref IS NOT INITIAL.
            lv_object = /idxgc/if_constants=>gc_object_pdoc_bor.
            lv_key    = lt_bdr_create_cluster[ 1 ]-bdr_create_req[ 1 ]-proc_ref.
            CALL FUNCTION '/IDXGC/FM_PDOC_DISPLAY_BOR'
              EXPORTING
                x_object      = lv_object
                x_key         = lv_key
                x_obj         = ls_obj
              EXCEPTIONS
                general_fault = 1
                OTHERS        = 2.
            IF sy-subrc <> 0.
              MESSAGE ID sy-msgid TYPE /idxgc/if_constants=>gc_message_type_success
                      NUMBER sy-msgno
                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.
          ENDIF.

          "Für Cluster Status und Prozessreferenz auf andere Zeilen übertragen und Daten in GT-Tabelle zurückschreiben
          CLEAR: gt_bdr_create_req.
          LOOP AT lt_bdr_create_cluster ASSIGNING <ls_bdr_create_cluster>.
            LOOP AT <ls_bdr_create_cluster>-bdr_create_req ASSIGNING <ls_bdr_create_req> WHERE status_text IS INITIAL AND proc_ref IS INITIAL.
              <ls_bdr_create_req>-proc_ref    = <ls_bdr_create_cluster>-bdr_create_req[ 1 ]-proc_ref.
              <ls_bdr_create_req>-status_text = <ls_bdr_create_cluster>-bdr_create_req[ 1 ]-status_text.
              <ls_bdr_create_req>-cellstyle   = <ls_bdr_create_cluster>-bdr_create_req[ 1 ]-cellstyle.
            ENDLOOP.
            gt_bdr_create_req = VALUE #( BASE gt_bdr_create_req FOR <ls_line> IN <ls_bdr_create_cluster>-bdr_create_req ( <ls_line> ) ).
          ENDLOOP.

          me->alv_grid->refresh_table_display( ).

        ENDIF.
    ENDCASE.

  ENDMETHOD.


  METHOD on_data_changed.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R, WISNIEWSKI-P                                                  Datum: 27.05.2019
*
* Beschreibung: Automatische Befüllung von Feldern wenn Daten geändert wurden.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    DATA:
      ls_mod_cells          TYPE lvc_s_modi,

      ls_euitrans           TYPE euitrans,
      lv_sender             TYPE e_dexservprovself,
      lv_receiver           TYPE e_dexservprovself,

      lv_eanl               TYPE eanl,
      lv_division_cat       TYPE spartyp,

      lr_badi_data_access   TYPE REF TO /idxgl/badi_data_access,
      lt_euitrans_malo_melo TYPE /idxgl/t_euitrans_malo_melo,
      lv_pod_is_melo        TYPE /idxgc/de_boolean_flag.

    LOOP AT er_data_changed->mt_mod_cells INTO ls_mod_cells WHERE fieldname = co_fieldname_ext_ui.
      CASE ls_mod_cells-fieldname.
        WHEN co_fieldname_ext_ui.

          CHECK ls_mod_cells-value IS NOT INITIAL.

          SELECT SINGLE * FROM euitrans WHERE ext_ui = @ls_mod_cells-value INTO @ls_euitrans.

          CLEAR: lv_receiver, lv_sender.

          TRY.
              lv_eanl = /adz/cl_bdr_utility=>get_eanl( iv_int_ui = ls_euitrans-int_ui ).
              lv_division_cat = /adz/cl_bdr_utility=>get_division_cat( iv_division = lv_eanl-sparte ).

              TRY.
                  GET BADI lr_badi_data_access.
                  CALL BADI lr_badi_data_access->is_pod_melo
                    EXPORTING
                      iv_ext_ui      = ls_euitrans-ext_ui
                    RECEIVING
                      rv_pod_is_melo = lv_pod_is_melo.
                  CALL BADI lr_badi_data_access->get_pod_malo_melo
                    EXPORTING
                      iv_ext_ui             = ls_euitrans-ext_ui
                    IMPORTING
                      et_euitrans_malo_melo = lt_euitrans_malo_melo.
                CATCH cx_badi_multiply_implemented cx_badi_not_implemented.
                  MESSAGE i020(/adz/bdr_messages).
              ENDTRY.

              IF gs_bdr_hdr-docname_code = /adz/if_bdr_co=>gc_msg_category_z14.

                /adz/cl_bdr_utility=>get_servprov_from_pod( EXPORTING iv_int_ui         = /adz/cl_bdr_utility=>get_int_ui( iv_ext_ui =  ls_euitrans-ext_ui )
                                                                      iv_keydate        = sy-datum
                                                                      iv_assoc_intcode  = /adz/if_bdr_co=>gc_intcode_01 " NB
                                                                      iv_own_intcode    = /adz/cl_bdr_customizing=>get_own_intcode_1( )
                                                            IMPORTING ev_own_servprov   = lv_sender
                                                                      ev_assoc_servprov = lv_receiver ).

              ELSEIF gs_bdr_hdr-docname_code = /adz/if_bdr_co=>gc_msg_category_z30.
                IF lines( lt_euitrans_malo_melo ) = 1.
                  "Serviceprovider bestimmen
                  /adz/cl_bdr_utility=>get_servprov_from_pod( EXPORTING iv_int_ui         = lt_euitrans_malo_melo[ 1 ]-int_ui_malo
                                                                        iv_assoc_intcode  = /adz/if_bdr_co=>gc_intcode_01 "NB
                                                                        iv_own_intcode    = /adz/if_bdr_co=>gc_intcode_02 "LF
                                                              IMPORTING ev_own_servprov   = lv_sender
                                                                        ev_assoc_servprov = lv_receiver ).

                  "Zählpunktbezeichnung von Malo auf Melo ändern
                  IF lv_pod_is_melo = abap_true.
                    er_data_changed->modify_cell( EXPORTING i_row_id    = ls_mod_cells-row_id
                                                            i_fieldname = co_fieldname_ext_ui
                                                            i_value     = lt_euitrans_malo_melo[ 1 ]-ext_ui ).
                  ENDIF.
                ENDIF.

              ELSEIF gs_bdr_hdr-docname_code = /adz/if_bdr_co=>gc_msg_category_z31.
                IF lines( lt_euitrans_malo_melo ) = 1.
                  "Serviceprovider bestimmen
                  /adz/cl_bdr_utility=>get_servprov_from_pod( EXPORTING iv_int_ui         = /adz/cl_bdr_utility=>get_int_ui( iv_ext_ui =  ls_euitrans-ext_ui )
                                                                        iv_assoc_intcode  = /adz/if_bdr_co=>gc_intcode_m1 " MSB
                                                                        iv_own_intcode    = /adz/if_bdr_co=>gc_intcode_01 " NB
                                                              IMPORTING ev_own_servprov   = lv_sender
                                                                        ev_assoc_servprov = lv_receiver ).

                ENDIF.
              ELSEIF gs_bdr_hdr-docname_code = /adz/if_bdr_co=>gc_msg_category_z34.
                "Serviceprovider bestimmen
                IF lines( lt_euitrans_malo_melo ) = 1.
                  IF /adz/cl_bdr_customizing=>get_format_setting( ) = /adz/if_bdr_co=>gc_format_setting_02 "Format ab 01.12.2019
                      AND lv_division_cat = /adz/if_bdr_co=>gc_division_cat_01. "Strom
                    /adz/cl_bdr_utility=>get_servprov_from_pod( EXPORTING iv_int_ui         = lt_euitrans_malo_melo[ 1 ]-int_ui_malo
                                                                          iv_assoc_intcode  = /adz/if_bdr_co=>gc_intcode_m1 "MSB
                                                                          iv_own_intcode    = /adz/cl_bdr_customizing=>get_own_intcode_1( )
                                                                IMPORTING ev_own_servprov   = lv_sender
                                                                          ev_assoc_servprov = lv_receiver ).
                  ELSE. "Gas oder Strom mit Formate ab 01.10.2017
                    /adz/cl_bdr_utility=>get_servprov_from_pod( EXPORTING iv_int_ui         = lt_euitrans_malo_melo[ 1 ]-int_ui_malo
                                                                          iv_assoc_intcode  = /adz/if_bdr_co=>gc_intcode_01 "NB
                                                                          iv_own_intcode    = /adz/if_bdr_co=>gc_intcode_02 "LF
                                                                IMPORTING ev_own_servprov   = lv_sender
                                                                          ev_assoc_servprov = lv_receiver ).
                  ENDIF.
                ENDIF.

                "Lieferrichtung setzen falls hinterlegt
                TRY.
                    IF lv_eanl-bezug = abap_true.
                      er_data_changed->modify_cell( EXPORTING i_row_id    = ls_mod_cells-row_id
                                                              i_fieldname = co_fieldname_supply_direct
                                                              i_value     = /idxgc/if_constants_add=>gc_supply_direct_z06 ).
                    ELSE.
                      er_data_changed->modify_cell( EXPORTING i_row_id    = ls_mod_cells-row_id
                                                              i_fieldname = co_fieldname_supply_direct
                                                              i_value     = /idxgc/if_constants_add=>gc_supply_direct_z07 ).
                    ENDIF.
                  CATCH /idxgc/cx_general.
                    "Weiter mit leerem Feld
                ENDTRY.

              ENDIF.

              "Serviceprovider setzen
              er_data_changed->modify_cell( EXPORTING i_row_id    = ls_mod_cells-row_id
                                                      i_fieldname = co_fieldname_sender
                                                      i_value     = lv_sender ).

              er_data_changed->modify_cell( EXPORTING i_row_id    = ls_mod_cells-row_id
                                                      i_fieldname = co_fieldname_receiver
                                                      i_value     = lv_receiver ).

            CATCH /idxgc/cx_general.
              MESSAGE i020(/adz/bdr_messages).
          ENDTRY.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.


  METHOD on_double_click.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: WISNIEWSKI-P                                                            Datum: 07.02.2020
*
* Beschreibung:
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    DATA:
      lv_object TYPE swo_objtyp,
      lv_key    TYPE eidegenerickey,
      ls_obj    TYPE eideswtdoc_dialog_object.

    FIELD-SYMBOLS: <gs_bdr_create_req> TYPE /adz/s_bdr_create_req.

    READ TABLE me->gt_bdr_create_req ASSIGNING <gs_bdr_create_req> INDEX e_row-index.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    IF e_column-fieldname = co_fieldname_proc_ref.
      CHECK <gs_bdr_create_req>-proc_ref IS NOT INITIAL.
      lv_object = /idxgc/if_constants=>gc_object_pdoc_bor.
      lv_key    = <gs_bdr_create_req>-proc_ref.
      CALL FUNCTION '/IDXGC/FM_PDOC_DISPLAY_BOR'
        EXPORTING
          x_object      = lv_object
          x_key         = lv_key
          x_obj         = ls_obj
        EXCEPTIONS
          general_fault = 1
          OTHERS        = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE /idxgc/if_constants=>gc_message_type_success
                NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
