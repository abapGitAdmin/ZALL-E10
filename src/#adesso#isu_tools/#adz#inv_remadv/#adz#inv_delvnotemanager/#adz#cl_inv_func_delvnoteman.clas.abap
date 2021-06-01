CLASS /adz/cl_inv_func_delvnoteman DEFINITION
  INHERITING FROM /adz/cl_inv_func_common
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS:
      /adz/if_inv_salv_table_evt_hlr~on_hotspotclick REDEFINITION,
      /adz/if_inv_salv_table_evt_hlr~on_user_command REDEFINITION,

      constructor     IMPORTING
                        !irt_out_table    TYPE REF TO data  OPTIONAL
                        !is_selscreen_dnm TYPE /adz/inv_s_delvnoteman_selpar OPTIONAL.
  PROTECTED SECTION.
    METHODS:
      get_hotspot_row REDEFINITION,

      show_quantities_old IMPORTING
                            iv_proc_ref      TYPE /idxgc/de_proc_ref
                            iv_proc_step_ref TYPE /idxgc/de_proc_step_ref,

      show_quantities IMPORTING
                        iv_proc_ref      TYPE /idxgc/de_proc_ref
                        iv_proc_step_ref TYPE /idxgc/de_proc_step_ref,

      show_cases      IMPORTING
                        iv_proc_ref TYPE /idxgc/de_proc_ref.

    METHODS get_outable     REDEFINITION.
    METHODS execute_process REDEFINITION.
    METHODS show_text      REDEFINITION.
    METHODS dun_lock       REDEFINITION.
    METHODS dun_unlock     REDEFINITION.
    METHODS balance        REDEFINITION.
    METHODS beende_remadv  REDEFINITION.
    METHODS cancel_ap      REDEFINITION.
    METHODS cancel_abr     REDEFINITION.
    METHODS cancel_memi    REDEFINITION.
    METHODS cancel_mgv     REDEFINITION.
    METHODS cancel_nne     REDEFINITION.
    METHODS send_mail      REDEFINITION.
    METHODS show_pdoc      REDEFINITION.
    METHODS show_swt       REDEFINITION.
    METHODS write_note     REDEFINITION.
    METHODS abl_per_comdis REDEFINITION.


  PRIVATE SECTION.
    DATA ms_selscreen_dnm  TYPE /adz/inv_s_delvnoteman_selpar.
    DATA mrt_out_dnm       TYPE REF TO /adz/inv_t_out_delvnoteman.

ENDCLASS.


CLASS /adz/cl_inv_func_delvnoteman IMPLEMENTATION.
  METHOD constructor.
    super->constructor(  ).
    IF irt_out_table IS NOT INITIAL.
      mrt_out_dnm ?= irt_out_table.
    ENDIF.
    ms_selscreen_dnm = is_selscreen_dnm.
  ENDMETHOD.

  METHOD get_hotspot_row.
    " angeclickte Zeile holen
    ASSIGN mrt_out_dnm->* TO FIELD-SYMBOL(<lt_out>).
    rrs_row = REF #( <lt_out>[ iv_rownr ] ).
    "READ TABLE <lt_out> INTO DATA(rs_row) INDEX iv_rownr.
  ENDMETHOD.

  METHOD get_outable.
    rrt_out = mrt_out_dnm.
  ENDMETHOD.

  METHOD /adz/if_inv_salv_table_evt_hlr~on_hotspotclick.
    "value(E_ROW_ID) type LVC_S_ROW optional
    "value(E_COLUMN_ID) type LVC_S_COL optional
    "value(ES_ROW_NO) type LVC_S_ROID optional .

    " angeclickte Zeile holen
    DATA(lr_row) = get_hotspot_row( e_row_id-index ).
    ASSIGN lr_row->* TO FIELD-SYMBOL(<ls_row>).
    DATA(ls_out) = CORRESPONDING /adz/inv_s_out_delvnoteman( <ls_row> ).

    " ueber Spaltename den Wert ermitteln
    ASSIGN COMPONENT e_column_id-fieldname OF STRUCTURE ls_out TO FIELD-SYMBOL(<lv_field_value>).
*# Nur mit Wert befüllten Feld funktionieren
    CHECK <lv_field_value> IS NOT INITIAL.

    CASE e_column_id-fieldname.

      WHEN 'MORE_CASES'.
        show_cases( ls_out-proc_ref ).

      WHEN 'QUANTITY_EXT'.
        show_quantities( EXPORTING iv_proc_ref = ls_out-proc_ref iv_proc_step_ref = ls_out-proc_step10_ref ).

      WHEN OTHERS.
        super->/adz/if_inv_salv_table_evt_hlr~on_hotspotclick(
          EXPORTING
            e_row_id    = e_row_id
            e_column_id = e_column_id
            es_row_no   = es_row_no
        ).
    ENDCASE.
  ENDMETHOD.

  METHOD  /adz/if_inv_salv_table_evt_hlr~on_user_command.
*    DATA: lv_index TYPE i.
    " eigene Userkommandos behandeln
    " BREAK-POINT.
*    IF mrt_filter IS INITIAL.
*      sender->get_filtered_entries( IMPORTING et_filtered_entries = DATA(mrt_filter) ).
*    ENDIF.
*    IF lv_index IS INITIAL.
*      sender->get_selected_rows( IMPORTING et_index_rows =  lv_index  ).
*      IF lv_index IS NOT INITIAL.
*        READ TABLE mrt_out_table ASSIGNING FIELD-SYMBOL(<ls_out>) INDEX lv_index.
*      ENDIF.
*    ENDIF.
    sender->get_selected_rows(
      IMPORTING
        et_index_rows = DATA(lt_sel_index_rows)     " Indizes der selektierten Zeilen
        et_row_no     = DATA(lt_sel_no_rows)     " Numerische IDs der selektierten Zeilen
    ).
    IF lt_sel_index_rows IS NOT INITIAL.
      me->choose( lt_sel_index_rows ).
      sender->refresh_table_display( ).
    ENDIF.

    CASE e_ucomm.
*# aus Invoice-Manager
*# zu aktualisieren
      WHEN 'ZEFRESH'.
        "me->/adz/if_inv_salv_table_evt_hlr~mo_controller->refresh_data(  ).
        sender->refresh_table_display( ).
      WHEN '&ALL_U'.
        mark_all( ).
        sender->refresh_table_display( ).
      WHEN '&SAL_U'.
        unmark_all( ).
        sender->refresh_table_display( ).
      WHEN OTHERS.
        " Standardfkt aufrufen
        DATA(lv_ucomm) = e_ucomm.
        sender->set_function_code( CHANGING c_ucomm = lv_ucomm  ).  " Funktionscode
    ENDCASE.
  ENDMETHOD.

  METHOD show_quantities_old.
    SELECT proc_ref, proc_step_ref, quant_type_qual, quantity_ext, datefrom, dateto FROM /idxgc/prst_mciq
      INTO TABLE @DATA(lt_mciq)
    WHERE proc_ref      = @iv_proc_ref
     AND  proc_step_ref = @iv_proc_step_ref.

    DATA lo_structdescr   TYPE REF TO cl_abap_structdescr.
    DATA ls_data          LIKE LINE OF lt_mciq.

    lo_structdescr ?= cl_abap_structdescr=>describe_by_data( ls_data ).
    DATA(lt_comp) = lo_structdescr->get_components( ).

    DATA(lt_fieldcat_ext) = VALUE slis_t_fieldcat_alv( FOR ls IN lt_comp ( fieldname = ls-name ref_tabname = '/IDXGC/PRST_MCIQ' ) ).
    lt_fieldcat_ext[ fieldname = 'QUANTITY_EXT' ]-do_sum = 'X'.

    DATA(ls_layout) = VALUE slis_layout_alv( colwidth_optimize = 'X' ).

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        it_fieldcat           = lt_fieldcat_ext
        i_screen_start_column = 10
        i_screen_start_line   = 10
        i_screen_end_column   = 100
        i_screen_end_line     = 20
        is_layout             = ls_layout
      TABLES
        t_outtab              = lt_mciq
      EXCEPTIONS
        program_error         = 1
        OTHERS                = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE sy-msgty.
    ENDIF.

  ENDMETHOD.

  METHOD show_quantities.
    SELECT proc_ref, proc_step_ref, quant_type_qual, quantity_ext, datefrom, dateto FROM /idxgc/prst_mciq
      INTO TABLE @DATA(lt_mciq)
    WHERE proc_ref      = @iv_proc_ref
     AND  proc_step_ref = @iv_proc_step_ref.

    DATA lo_structdescr   TYPE REF TO cl_abap_structdescr.
    DATA ls_data          LIKE LINE OF lt_mciq.

    lo_structdescr ?= cl_abap_structdescr=>describe_by_data( ls_data ).
    DATA(lt_comp) = lo_structdescr->get_components( ).

    DATA(lt_fieldcat) = VALUE lvc_t_fcat( FOR ls IN lt_comp ( fieldname = ls-name ref_table = '/IDXGC/PRST_MCIQ' ) ).
    lt_fieldcat[ fieldname = 'QUANTITY_EXT' ]-do_sum = 'X'.

    DATA(lo_alv_grid) = /adz/cl_inv_gui_dialogbox=>create_dialogbox(
                          EXPORTING
                            iv_width    = 900
                            iv_height   = 100
                            iv_top      = 20
                            iv_left     = 100
                            iv_title    = 'Quantities'
                          CHANGING
                            ct_fieldcat = lt_fieldcat
                            ct_data     = lt_mciq
                        ).
    DATA(lo_func_handler) = NEW /adz/cl_inv_func_subdialog_dnm( irt_out_table  =  REF #( lt_fieldcat ) ).
    SET HANDLER lo_func_handler->/adz/if_inv_salv_table_evt_hlr~on_user_command FOR lo_alv_grid.
    SET HANDLER lo_func_handler->/adz/if_inv_salv_table_evt_hlr~on_hotspotclick FOR lo_alv_grid.

  ENDMETHOD.

  METHOD show_cases.
    TYPES : BEGIN OF ty_emmacase_ext,
              mainobjkey     TYPE  emma_case-mainobjkey,
              casenr         TYPE  emma_case-casenr,
              ccat           TYPE  emma_case-ccat,
              prio           TYPE  emma_case-prio,
              priotxt        TYPE  /adz/inv_s_out_delvnoteman-priotxt,
              exception_code TYPE  /adz/inv_s_out_delvnoteman-exception_code,
              casetxt        TYPE  emma_case-casetxt,
              zz_casetxt     TYPE  emma_case-zz_casetxt,
              status         TYPE  emma_case-status,
              currproc       TYPE  emma_case-currproc,
              created_date   TYPE  emma_case-created_date,
              created_time   TYPE  emma_case-created_time,
              changed_date   TYPE  emma_case-changed_date,
              changed_time   TYPE  emma_case-changed_time,
            END OF ty_emmacase_ext.
    DATA lt_bpem_cases_pr TYPE TABLE OF ty_emmacase_ext.

    SELECT *  FROM emma_case   INTO CORRESPONDING FIELDS OF TABLE lt_bpem_cases_pr
    WHERE ( mainobjtype = if_isu_ide_switch_constants=>co_object_type
         OR mainobjtype = /idxgc/if_constants=>gc_object_pdoc_bor )
      AND   mainobjkey  = iv_proc_ref.

    DATA lo_structdescr   TYPE REF TO cl_abap_structdescr.
    DATA ls_data          LIKE LINE OF lt_bpem_cases_pr.
    DATA lo_emma_dbl      TYPE REF TO cl_emma_dbl.
    DATA lo_case          TYPE REF TO cl_emma_case.

    lo_emma_dbl = cl_emma_dbl=>create_dblayer( ).

    LOOP AT lt_bpem_cases_pr ASSIGNING FIELD-SYMBOL(<ls_bpem_case>).
      <ls_bpem_case>-priotxt = /adz/cl_inv_select_basic=>get_domain_text(
           EXPORTING  iv_domtabname = 'EMMA_CPRIO'
                      iv_value  = CONV #( <ls_bpem_case>-prio ) ).
      CALL METHOD lo_emma_dbl->read_case_detail
        EXPORTING
          iv_case   = <ls_bpem_case>-casenr
        RECEIVING
          er_case   = lo_case
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.
      IF sy-subrc EQ 0.
        lo_case->get_objects( IMPORTING  et_objects = DATA(lt_emma_objs) ).
        TRY.
            <ls_bpem_case>-exception_code = lt_emma_objs[ reffield = 'EXCEPTION_CODE' ]-id.
          CATCH cx_sy_itab_line_not_found.
        ENDTRY.
      ENDIF.
    ENDLOOP.
    IF sy-sysid EQ 'E10' AND lt_bpem_cases_pr IS INITIAL.
      lt_bpem_cases_pr = VALUE #( ( casenr = '001' ) ).
    ENDIF.

    lo_structdescr ?= cl_abap_structdescr=>describe_by_data( ls_data ).
    DATA(lt_comp) = lo_structdescr->get_components( ).
    DATA(lt_fieldcat) = VALUE lvc_t_fcat( FOR ls IN lt_comp ( fieldname = ls-name ref_table = 'EMMA_CASE' ) ).
    lt_fieldcat[ fieldname = 'PRIOTXT'         ]-scrtext_s = 'PrioText'.
    lt_fieldcat[ fieldname = 'EXCEPTION_CODE'  ]-scrtext_s = 'ExcCode'.
    lt_fieldcat[ fieldname = 'EXCEPTION_CODE'  ]-scrtext_m = 'ExceptionCode'.
    lt_fieldcat[ fieldname = 'CASENR' ]-hotspot = 'X'.
    lt_fieldcat[ fieldname = 'MAINOBJKEY' ]-outputlen = 26.

    DATA(lo_alv_grid) = /adz/cl_inv_gui_dialogbox=>create_dialogbox(
                          EXPORTING
                            iv_width    = 1400
                            iv_height   = 100
                            iv_top      = 20
                            iv_left     = 100
                            iv_title    = 'Ausnahmen'
                          CHANGING
                            ct_fieldcat = lt_fieldcat
                            ct_data     = lt_bpem_cases_pr
                        ).
    DATA(lo_func_handler) = NEW /adz/cl_inv_func_subdialog_dnm( irt_out_table  =  REF #( lt_bpem_cases_pr ) ).
    SET HANDLER lo_func_handler->/adz/if_inv_salv_table_evt_hlr~on_user_command FOR lo_alv_grid.
    SET HANDLER lo_func_handler->/adz/if_inv_salv_table_evt_hlr~on_hotspotclick FOR lo_alv_grid.

  ENDMETHOD.

  METHOD execute_process.
  ENDMETHOD.

  METHOD show_text.
  ENDMETHOD.

  METHOD dun_lock.
  ENDMETHOD.

  METHOD dun_unlock.
  ENDMETHOD.

  METHOD balance.
  ENDMETHOD.

  METHOD beende_remadv.
  ENDMETHOD.

  METHOD cancel_abr.
  ENDMETHOD.

  METHOD cancel_ap.
  ENDMETHOD.

  METHOD cancel_memi.
  ENDMETHOD.

  METHOD cancel_mgv.
  ENDMETHOD.

  METHOD cancel_nne.
  ENDMETHOD.

  METHOD send_mail.
  ENDMETHOD.

  METHOD show_pdoc.
  ENDMETHOD.

  METHOD show_swt.
  ENDMETHOD.

  METHOD write_note.
  ENDMETHOD.

  METHOD abl_per_comdis.
  ENDMETHOD.

ENDCLASS.

