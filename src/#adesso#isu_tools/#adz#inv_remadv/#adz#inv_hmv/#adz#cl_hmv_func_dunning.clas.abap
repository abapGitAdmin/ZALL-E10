CLASS /adz/cl_hmv_func_dunning DEFINITION
  PUBLIC
  INHERITING FROM /adz/cl_inv_func_common
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS :
      constructor
        IMPORTING
          !irt_out_table TYPE REF TO data
          !is_selscreen  TYPE /adz/hmv_s_dunning_sel_params,

      /adz/if_inv_salv_table_evt_hlr~on_hotspotclick REDEFINITION,
      /adz/if_inv_salv_table_evt_hlr~on_user_command REDEFINITION
      .


  PROTECTED SECTION.
    METHODS:
      get_outable REDEFINITION,
      get_hotspot_row REDEFINITION,
      mahnsperre_setzen
        IMPORTING
          !iv_lockr TYPE fkkvkp-mansp
          !iv_fdate TYPE sy-datum
          !iv_tdate TYPE sy-datum,
      mahnsperre_loeschen,
      dunn_blck IMPORTING is_out TYPE /adz/hmv_s_out_dunning,
      dunn_hist IMPORTING is_out TYPE /adz/hmv_s_out_dunning,
      select_block IMPORTING  !it_sel_rows_index TYPE lvc_t_row.

    METHODS show_text REDEFINITION .

    METHODS execute_process REDEFINITION .
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

    .
  PRIVATE SECTION.
    DATA mrt_out_dun       TYPE REF TO /adz/hmv_t_out_dunning.
    DATA ms_selscreen_dun  TYPE /adz/hmv_s_dunning_sel_params.
    DATA ms_constants      TYPE /adz/hmv_s_constants.

ENDCLASS.



CLASS /adz/cl_hmv_func_dunning IMPLEMENTATION.


  METHOD /adz/if_inv_salv_table_evt_hlr~on_hotspotclick.
    "value(E_ROW_ID) type LVC_S_ROW optional
    "value(E_COLUMN_ID) type LVC_S_COL optional
    "value(ES_ROW_NO) type LVC_S_ROID optional .

    " angeclickte Zeile holen
    DATA(lr_row) = get_hotspot_row( e_row_id-index ).
    ASSIGN lr_row->* TO FIELD-SYMBOL(<ls_row>).
    DATA(ls_out) = CORRESPONDING /adz/hmv_s_out_dunning( <ls_row> ).

    " ueber Spaltename den Wert ermitteln
    ASSIGN COMPONENT e_column_id-fieldname OF STRUCTURE ls_out TO FIELD-SYMBOL(<lv_field_value>).
    CHECK <lv_field_value> IS NOT INITIAL.

    CASE e_column_id-fieldname.
*      WHEN 'SEL'.
*        READ TABLE <lt_out> ASSIGNING FIELD-SYMBOL(<ls_out>) INDEX e_row_id-index.
*        <ls_out>-sel = xsdbool( <ls_out>-sel <> abap_true ).

        " Vertragskonto
        " Aggregiertes Vertragskonto
      WHEN  'VKONT' OR 'AGGVK'.
        "SET PARAMETER ID 'KTO' FIELD <lv_field_value>.
        "CALL TRANSACTION 'CAA3' AND SKIP FIRST SCREEN.
        DATA lt_fldvl TYPE TABLE OF bus0fldval.
        lt_fldvl = VALUE  #( ( tbfld = 'FKKVK-VKONT' fldvl = <lv_field_value> ) ).
        CALL FUNCTION 'VKK_FICA_ACCOUNT_MAINTAIN'
          EXPORTING
            i_aktyp = '03'
            i_xinit = ' '
          TABLES
            t_fldvl = lt_fldvl.

        "  Sender Empfänger
      WHEN 'SENID' OR 'RECID'.
        SET PARAMETER ID 'EESERVPROVID' FIELD <lv_field_value>.
        CALL TRANSACTION 'EEDMIDESERVPROV03' AND SKIP FIRST SCREEN.

        " Aggr. Beleg
      WHEN 'BCBLN'.
        SET PARAMETER ID '80B' FIELD <lv_field_value>.
        CALL TRANSACTION 'FPE3' AND SKIP FIRST SCREEN.

        "  Belegnummer
      WHEN 'OPBEL'.
        CASE ls_out-kennz.
          WHEN ms_constants-c_doc_kzm.
            DATA lv_pdocnr TYPE eideswtnum .
            DATA lv_doc_id(12) TYPE n.
            lv_doc_id = <lv_field_value>.
            SELECT SINGLE pdoc_ref FROM /idxmm/memidoc INTO lv_pdocnr WHERE doc_id = lv_doc_id.
            IF sy-subrc = 0.
              CALL FUNCTION '/IDXGC/FM_PDOC_DISPLAY'
                EXPORTING
                  x_switchnum    = lv_pdocnr
                EXCEPTIONS
                  general_fault  = 1
                  not_found      = 2
                  not_authorized = 3
                  OTHERS         = 4.
              IF sy-subrc NE 0.
                MESSAGE TEXT-t01 TYPE 'I' DISPLAY LIKE 'E'.
              ENDIF.
            ENDIF.
          WHEN ms_constants-c_doc_kzd.
            SET PARAMETER ID '80B' FIELD <lv_field_value>.
            CALL TRANSACTION 'FPE3' AND SKIP FIRST SCREEN.
          WHEN ms_constants-c_doc_kzmsb.
            CALL FUNCTION 'FKK_INV_INVDOC_DISP'
              EXPORTING
                x_invdocno = CONV invdocno_kk( <lv_field_value> ).
        ENDCASE.


      WHEN 'PAYNO'    " positive REMADV
        OR 'DOCNO'    " negative REMADV
        OR 'REMADV2'. " zweite REMADV
        CALL FUNCTION 'INV_S_INVREMADV_DOC_DISPLAY'
          EXPORTING
            x_inv_doc_no = CONV inv_int_inv_doc_no( <lv_field_value> )    " Interne Nummer des Rechnungsbelegs
          EXCEPTIONS
            OTHERS       = 4.
*      WHEN 'DOCNO'.
*        " SUBMIT rinv_monitoring WITH se_docnr-low = wa_out-docno AND RETURN.
*        CALL FUNCTION 'FKK_INV_INVDOC_DISP'
*          EXPORTING
*            x_invdocno = CONV invdocno_kk( <lv_field_value> ).

        "  INVOIC-IDOC
      WHEN 'IDOCIN'.
        SUBMIT idoc_tree_control WITH docnum = <lv_field_value> AND RETURN.

        "  CONTROL-IDOC (Aggr. IDOC)
      WHEN 'IDOCCT'.
        SUBMIT idoc_tree_control WITH docnum = <lv_field_value> AND RETURN.

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
    " eigene Userkommandos behandeln
    DATA  lv_nr_rows_selected TYPE i.

    " BREAK-POINT.
    sender->get_filtered_entries( IMPORTING et_filtered_entries = mt_filter ).

    sender->get_selected_rows(
      IMPORTING
        et_index_rows = DATA(lt_sel_index_rows)     " Indizes der selektierten Zeilen
        et_row_no     = DATA(lt_sel_no_rows)     " Numerische IDs der selektierten Zeilen
    ).
    IF lt_sel_index_rows IS NOT INITIAL.
      me->choose( lt_sel_index_rows ).
      sender->refresh_table_display( ).
    ENDIF.
    lv_nr_rows_selected = REDUCE #( INIT x1 = 0  FOR ls IN mrt_out_dun->* WHERE (  sel = 'X' )  NEXT x1 = x1 + 1  ).

    IF lv_nr_rows_selected EQ 1.
      LOOP AT mrt_out_dun->* INTO DATA(ls_out) WHERE sel = 'X'.
      ENDLOOP.
    ENDIF.

*        READ TABLE t_out INTO wa_out INDEX rs_selfield-tabindex.
*
*        CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
*          IMPORTING
*            e_grid = rev_alv.
*
*        CALL METHOD rev_alv->check_changed_data.
*
*        rs_selfield-refresh    = 'X'.
*        rs_selfield-row_stable = 'X'.
*        rs_selfield-col_stable = 'X'.
*
*        REFRESH gt_filtered.
*        CALL FUNCTION 'REUSE_ALV_GRID_LAYOUT_INFO_GET'
*          IMPORTING
*            et_filtered_entries = gt_filtered
*          EXCEPTIONS
*            no_infos            = 1
*            program_error       = 2
*            OTHERS              = 3.
    CASE e_ucomm.
*# aus Invoice-Manager
*# zu aktualisieren
      WHEN 'ZEFRESH'.
        "me->/adz/if_inv_salv_table_evt_hlr~mo_controller->refresh_data(  ).
        sender->refresh_table_display( ).

      WHEN '&ALL_U'.
        LOOP AT mrt_out_dun->* ASSIGNING FIELD-SYMBOL(<ls_out>).
          <ls_out>-sel = abap_true.
        ENDLOOP.
        sender->refresh_table_display( ).

      WHEN  '&SAL_U'.
        LOOP AT mrt_out_dun->* ASSIGNING  <ls_out>.
          <ls_out>-sel = abap_false.
        ENDLOOP.
        sender->refresh_table_display( ).

      WHEN 'LOCK'.
        mahnsperre_setzen( EXPORTING iv_lockr = ms_selscreen_dun-pa_lockr
                                     iv_fdate = ms_selscreen_dun-pa_fdate
                                     iv_tdate = ms_selscreen_dun-pa_tdate ).
        sender->refresh_table_display( ).

      WHEN 'UNLOCK'.
        mahnsperre_loeschen( ).
        sender->refresh_table_display( ).

      WHEN 'DATEX'.
        CHECK me->check_single_select( lv_nr_rows_selected ) EQ abap_true.
        SUBMIT ree_datex_monitoring WITH se_extui-low = ls_out-ext_ui
            VIA SELECTION-SCREEN AND RETURN.

      WHEN 'BALANCE'.
        CHECK me->check_single_select( lv_nr_rows_selected ) EQ abap_true.
        SET PARAMETER ID 'KTO' FIELD ls_out-vkont.
        CALL TRANSACTION 'FPL9'.

      WHEN 'SEL_BLOCK'.
        select_block( lt_sel_index_rows ).
        sender->refresh_table_display( ).

      WHEN 'DUNN_HIST'.
        CHECK me->check_single_select( lv_nr_rows_selected ) EQ abap_true.
        dunn_hist( ls_out ).

      WHEN 'DUNN_BLK'.
        CHECK me->check_single_select( lv_nr_rows_selected ) EQ abap_true.
        dunn_blck( ls_out ).

*      WHEN 'INTE_HIST'.  " Zinshistorie
*        CHECK me->check_single_select( lv_nr_rows_selected ) EQ abap_true.
*        CALL FUNCTION 'FKK_INTEREST_HISTORY_BROWSE'
*          EXPORTING
*            i_opbel            = ls_out-opbel
*            i_opupk            = ls_out-opupk
*          EXCEPTIONS
*            appendix_not_found = 1
*            OTHERS             = 2.
*
*        IF sy-subrc <> 0.
*          MESSAGE TEXT-s01 TYPE 'S'.
*        ENDIF.

      WHEN 'BALAGGR'.
        CHECK me->check_single_select( lv_nr_rows_selected ) EQ abap_true.
        SET PARAMETER ID 'KTO' FIELD ls_out-aggvk.
        CALL TRANSACTION 'FPL9'.

      WHEN OTHERS.
        " Standardfkt aufrufen
        DATA(lv_ucomm) = e_ucomm.
        sender->set_function_code( CHANGING c_ucomm = lv_ucomm  ).  " Funktionscode
    ENDCASE.
  ENDMETHOD.


  METHOD constructor.
    DATA lr_data TYPE REF TO data.
    super->constructor( EXPORTING   irt_out_table = lr_data ).
    mrt_out_dun ?= irt_out_table.
    ms_selscreen_dun = is_selscreen.
    ms_constants = /adz/cl_hmv_constants=>get_constants( ).
  ENDMETHOD.


  METHOD dunn_blck.
    DATA: lt_dfkklocks  TYPE STANDARD TABLE OF dfkklocks WITH DEFAULT KEY.
    DATA: lt_dfkklocksh TYPE STANDARD TABLE OF dfkklocksh WITH DEFAULT KEY.
    DATA: lv_loobj1     TYPE dfkklocks-loobj1.

* --- move keyfields into key structure -----------------------------
    DATA(ls_dfkkop_key) = VALUE dfkkop_key_s(
      opbel = is_out-opbel
      opupw = is_out-opupw
      opupk = is_out-opupk
      opupz = is_out-opupz ).

    IF is_out-kennz EQ ms_constants-c_doc_kzd.
      MOVE ls_dfkkop_key TO lv_loobj1.
      CALL FUNCTION 'FKK_DB_LOCK_SELECT'
        EXPORTING
          i_loobj1          = lv_loobj1
          i_proid           = ms_constants-c_proid
          i_lotyp           = ms_constants-c_lotyp
          i_x_hist          = 'X'
          i_x_use_fieldlist = 'X'
        TABLES
          et_locks          = lt_dfkklocks
          et_locksh         = lt_dfkklocksh.

      lt_dfkklocks = VALUE #( FOR ls IN lt_dfkklocksh ( CORRESPONDING #( ls ) ) ).

      IF sy-subrc = 0.
        TRY.
            cl_salv_table=>factory(
             EXPORTING   list_display = 'X'
              IMPORTING  r_salv_table = DATA(lo_salv_table)
              CHANGING   t_table      = lt_dfkklocks  ).
          CATCH cx_salv_msg .
        ENDTRY.

        lo_salv_table->set_screen_popup(
          start_column = 1
          end_column   = 200
          start_line   = 1
          end_line     = lines( lt_dfkklocks ) + 5 ).

        DATA(lv_belnr) = ls_dfkkop_key-opbel.
        SHIFT lv_belnr LEFT DELETING LEADING '0'.
        DATA(lv_title) = CONV lvc_title( |{ TEXT-t04 } { lv_belnr }| ).

        DATA(lo_display) = lo_salv_table->get_display_settings( ).
        lo_display->set_list_header( lv_title ).

        DATA(lo_selections) = lo_salv_table->get_selections( ).
        lo_selections->set_selection_mode( if_salv_c_selection_mode=>none ).

        lo_salv_table->display( ).
      ELSE.
        MESSAGE i023(/adz/hmv).
      ENDIF.

*    CONCATENATE text-t03 wa_out-opbel INTO x_wtitle SEPARATED BY space.
*    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*      EXPORTING
*        ddic_structure  = 'DFKKLOCKS'
*        retfield        = 'LOOBJ1'
*        window_title    = x_wtitle
*        value_org       = 'S'
*      TABLES
*        value_tab       = lv_t_dfkklocks
*      EXCEPTIONS
*        parameter_error = 1
*        no_values_found = 2
*        OTHERS          = 3.
*    IF sy-subrc <> 0.
*      MESSAGE text-s02 TYPE 'S'.
*    ENDIF.

    ELSEIF is_out-kennz EQ ms_constants-c_doc_kzm.
*    CALL FUNCTION '/ADZ/HMV_MEMI_LOCKHIST'
*      EXPORTING
*        doc_id = wa_out-opbel.
      CALL FUNCTION '/ADZ/MEMI_MAHNSPERRE'
        EXPORTING
          iv_belnr        = is_out-opbel
          ix_get_lockhist = 'X'
*         IX_SET_LOCK     =
*         IX_DEL_LOCK     =
*         IV_NO_POPUP     =
* IMPORTING
*         EV_DONE         =
* CHANGING
*         IV_DATE_FROM    =
*         IV_DATE_TO      =
*         IV_LOCKR        =
        .
    ENDIF.
  ENDMETHOD.


  METHOD dunn_hist.
    " Select dunnhist für Dfkkthi
    IF is_out-kennz = 'D'.
      SELECT * FROM fkkmaze   INTO TABLE @DATA(lt_fkkmaze)
        WHERE opbel = @is_out-opbel
          AND opupw = @is_out-opupw
          AND opupk = @is_out-opupk.
    ELSE.
      SELECT * FROM fkkmaze   INTO TABLE lt_fkkmaze
        WHERE opbel = is_out-bcbln
          AND opupk = is_out-opupk.
    ENDIF.

    IF sy-subrc = 0.
      TRY.
          cl_salv_table=>factory(
            EXPORTING  list_display = 'X'
            IMPORTING  r_salv_table = DATA(lo_salv_table)
            CHANGING   t_table      = lt_fkkmaze
          ).
        CATCH cx_salv_msg .
      ENDTRY.

      lo_salv_table->set_screen_popup(
        start_column = 1
        end_column   = 200
        start_line   = 1
        end_line     = lines( lt_fkkmaze ) + 5 ).

      DATA(lv_belnr) = is_out-opbel.
      SHIFT lv_belnr LEFT DELETING LEADING '0'.
      DATA(lv_title) = CONV lvc_title( |{ TEXT-t04 } { lv_belnr }| ).

      DATA(lo_display) = lo_salv_table->get_display_settings( ).
      lo_display->set_list_header( lv_title ).

      DATA: lr_selections TYPE REF TO cl_salv_selections.

      lr_selections = lo_salv_table->get_selections( ).
      lr_selections->set_selection_mode( if_salv_c_selection_mode=>none ).

      lo_salv_table->display( ).

    ELSE.
      MESSAGE i019(/adz/hmv).
    ENDIF.
  ENDMETHOD.


  METHOD get_hotspot_row.
    " angeclickte Zeile holen
    ASSIGN mrt_out_dun->* TO FIELD-SYMBOL(<lt_out>).
    rrs_row = REF #( <lt_out>[ iv_rownr ] ).
    "READ TABLE <lt_out> INTO DATA(rs_row) INDEX iv_rownr.
  ENDMETHOD.


  METHOD get_outable.
    rrt_out = mrt_out_dun.
  ENDMETHOD.


  METHOD mahnsperre_loeschen.
    DATA lt_opbel TYPE fkkopkey_t.
    DATA lv_answer TYPE char1.
    DATA lv_text TYPE string.

* Sicherheitsabfrage
    DATA(lv_anz) = REDUCE #( INIT nr = 0  FOR ls IN mrt_out_dun->*  WHERE ( sel = 'X' ) NEXT  nr = nr + 1 ).
    lv_text =  TEXT-104.
    REPLACE 'Einträge' IN lv_text WITH |  { lv_anz } Einträge |.
    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
      EXPORTING
        defaultoption = 'Y'
        textline1     = lv_text
        textline2     = TEXT-105
        titel         = TEXT-t05
      IMPORTING
        answer        = lv_answer.
    IF NOT lv_answer CA 'jJyY'.
      EXIT.
    ENDIF.

    LOOP AT mrt_out_dun->* ASSIGNING FIELD-SYMBOL(<ls_out>) WHERE sel = 'X'.
      READ TABLE mt_filter WITH KEY table_line = sy-tabix TRANSPORTING NO FIELDS.
      CHECK sy-subrc NE 0.
      CHECK <ls_out>-augst  = ' '.

      IF <ls_out>-kennz EQ ms_constants-c_doc_kzd
      OR <ls_out>-kennz EQ ms_constants-c_doc_kzmsb.
        CHECK <ls_out>-mansp IS NOT INITIAL.

        lt_opbel = VALUE #( (
          opbel     = COND #(  WHEN <ls_out>-kennz EQ ms_constants-c_doc_kzd THEN <ls_out>-opbel ELSE <ls_out>-bcbln )
          opupk     = COND #(  WHEN <ls_out>-kennz EQ ms_constants-c_doc_kzd THEN <ls_out>-opupk ELSE '0001' )
          opupw     = COND #(  WHEN <ls_out>-kennz EQ ms_constants-c_doc_kzd THEN <ls_out>-opupw ELSE '000'  )
          opupz     = COND #(  WHEN <ls_out>-kennz EQ ms_constants-c_doc_kzd THEN <ls_out>-opupz ELSE '0000' )
        ) ).

        CALL FUNCTION 'FKK_S_LOCK_DELETE_FOR_DOCITEMS'
          EXPORTING
            iv_opbel    = lt_opbel[ 1 ]-opbel
            it_fkkopkey = lt_opbel
            iv_proid    = ms_constants-c_proid
            iv_lockr    = <ls_out>-mansp
            iv_fdate    = <ls_out>-fdate
            iv_tdate    = <ls_out>-tdate
          EXCEPTIONS
            OTHERS      = 5.

        IF sy-subrc <> 0.
          <ls_out>-status = icon_breakpoint.
        ELSE.
          CLEAR: <ls_out>-mansp, <ls_out>-fdate, <ls_out>-tdate.
          <ls_out>-status = icon_unlocked.
        ENDIF.

        " Sperren der OPBELS wieder aufheben
        CALL FUNCTION 'FKK_DEQ_OPBELS_AFTER_CHANGES'
          EXPORTING
            _scope          = '3'
            i_only_document = ' '.

      ELSEIF  <ls_out>-kennz EQ ms_constants-c_doc_kzm.
        DATA lv_done_del TYPE abap_bool.

        CALL FUNCTION '/ADZ/MEMI_MAHNSPERRE'
          EXPORTING
            iv_belnr    = <ls_out>-opbel
*           IX_GET_LOCKHIST       =
*           IX_SET_LOCK =
            ix_del_lock = 'X'
            iv_no_popup = 'X'
          IMPORTING
            ev_done     = lv_done_del.
        IF lv_done_del = 'X'.
          <ls_out>-mansp = ''.
          <ls_out>-fdate = ''.
          <ls_out>-tdate = ''.
          <ls_out>-status = icon_unlocked.
        ENDIF.

      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD mahnsperre_setzen.
    DATA t_sval TYPE TABLE OF sval.
    t_sval = VALUE #(
     ( tabname = 'FKKMAZE'    fieldname = 'MANSP'  field_obl = 'X'   fieldtext = 'Sperrgrund'  value = iv_lockr )
     ( tabname = 'DFKKLOCKS'  fieldname = 'FDATE'  field_obl = 'X'   fieldtext = 'von Datum'   value = iv_fdate )
     ( tabname = 'DFKKLOCKS'  fieldname = 'TDATE'  field_obl = 'X'   fieldtext = 'bis Datum'   value = iv_tdate )
    ).
    CALL FUNCTION 'POPUP_GET_VALUES'
      EXPORTING
        popup_title  = 'Mahnsperre'
        start_column = '5'
        start_row    = '5'
      TABLES
        fields       = t_sval.

    DATA(lv_lockr) = CONV mansp_old_kk( t_sval[ fieldname = 'MANSP' ]-value ).
    DATA(lv_fdate) = CONV dats( t_sval[ fieldname = 'FDATE' ]-value ).
    DATA(lv_tdate) = CONV dats( t_sval[ fieldname = 'TDATE' ]-value ).

    " Abdatum darf nicht kleiner als Tagesdatum sein
    IF lv_fdate < sy-datum.
      MESSAGE TEXT-e03 TYPE 'I' DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.

    " Bis-Datum darf nicht größer Ab-Datum sein
    IF lv_tdate < lv_fdate.
      MESSAGE TEXT-e05 TYPE 'E' DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.

    " Sicherheitsabfrage
    DATA lv_answer TYPE char1.
    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
      EXPORTING
        defaultoption = 'Y'
        textline1     = TEXT-100
        textline2     = TEXT-101
        titel         = TEXT-t01
      IMPORTING
        answer        = lv_answer.
    IF NOT lv_answer CA 'jJyY'.
      EXIT.
    ENDIF.

    DATA lt_fkkopchl   TYPE STANDARD TABLE OF fkkopchl.
    LOOP AT mrt_out_dun->* ASSIGNING FIELD-SYMBOL(<ls_out>) WHERE sel = 'X'.
      READ TABLE mt_filter WITH KEY table_line = sy-tabix TRANSPORTING NO FIELDS.
      CHECK sy-subrc NE 0.
*    CHECK <t_out>-status = icon_breakpoint.
      CHECK <ls_out>-augst  = ' '.

      IF <ls_out>-kennz EQ ms_constants-c_doc_kzd
      OR <ls_out>-kennz EQ ms_constants-c_doc_kzmsb.

        lt_fkkopchl = VALUE #( (
          lockaktyp = ms_constants-c_lockaktyp
          opupk     = COND #(  WHEN <ls_out>-kennz EQ ms_constants-c_doc_kzd THEN <ls_out>-opupk ELSE '0001' )
          opupw     = COND #(  WHEN <ls_out>-kennz EQ ms_constants-c_doc_kzd THEN <ls_out>-opupw ELSE '000'  )
          opupz     = COND #(  WHEN <ls_out>-kennz EQ ms_constants-c_doc_kzd THEN <ls_out>-opupz ELSE '0000' )
          proid     = ms_constants-c_proid
          lockr     = lv_lockr
          fdate     = lv_fdate
          tdate     = lv_tdate
          lotyp     = ms_constants-c_lotyp
          gpart     = <ls_out>-gpart
          vkont     = <ls_out>-vkont
        ) ).

        "  Sperren zu Belegpositionen
        CALL FUNCTION 'FKK_DOCUMENT_CHANGE_LOCKS'
          EXPORTING
            i_opbel           = <ls_out>-opbel
          TABLES
            t_fkkopchl        = lt_fkkopchl
          EXCEPTIONS
            err_document_read = 1
            err_create_line   = 2
            err_lock_reason   = 3
            err_lock_date     = 4
            OTHERS            = 5.
        IF sy-subrc <> 0.
          <ls_out>-to_lock = icon_breakpoint.
        ELSE.
          <ls_out>-mansp = lv_lockr.
          <ls_out>-fdate = lv_fdate.
          <ls_out>-tdate = lv_tdate.
          <ls_out>-status = icon_locked.
        ENDIF.
*>>> UH 08042013
** Sperren der OPBELS wieder aufheben
        CALL FUNCTION 'FKK_DEQ_OPBELS_AFTER_CHANGES'
          EXPORTING
            _scope          = '3'
            i_only_document = ' '.

      ELSEIF <ls_out>-kennz EQ ms_constants-c_doc_kzm.
        DATA lv_done TYPE abap_bool.
*      DATA: ls_mloc TYPE /ADZ/hmv_mloc.
*      DATA ls_memidoc_u TYPE /idxmm/memidoc.
*      DATA lt_memidoc_u TYPE /idxmm/t_memi_doc.
*      DATA lr_memidoc TYPE REF TO /idxmm/cl_memi_document_db.
*
**      IF c_idxmm_sp03_dunn IS INITIAL.                              "Nuss 02.02.2018
*
**    Es ist schon eine Mahnsperre vorhanden
*      IF <ls_out>-fdate IS NOT INITIAL AND
*         <ls_out>-tdate IS NOT INITIAL.
*        IF pa_tdate ge <ls_out>-fdate.
*           MESSAGE TEXT-e06 TYPE 'E'.
*        ENDIF.
*      ENDIF.
*
*      ls_mloc-doc_id    = <ls_out>-opbel.
*      ls_mloc-lockr     = pa_lockr.
*      ls_mloc-fdate     = pa_fdate.
*      ls_mloc-tdate     = pa_tdate.
*      ls_mloc-crnam     = sy-uname.
*      ls_mloc-azeit     = sy-timlo.
*      ls_mloc-adatum    = sy-datum.
*      ls_mloc-lvorm     = ''.
**        INSERT INTO /ADZ/hmv_mloc VALUES ls_mloc.      "Nuss 02.02.2018
*      MODIFY /ADZ/hmv_mloc FROM ls_mloc.              "Nuss 02.02.2018
*
*      IF sy-subrc = 0.
*        <ls_out>-mansp  = pa_lockr.
*        <ls_out>-fdate  = pa_fdate.
*        <ls_out>-tdate  = pa_tdate.
*        <ls_out>-status = icon_locked.
*      ENDIF.

**     --> Nuss 02.02.2018 auskommentiert
*      ELSE.
        CALL FUNCTION '/ADZ/MEMI_MAHNSPERRE'
          EXPORTING
            iv_belnr     = <ls_out>-opbel
*           IX_GET_LOCKHIST       =
            ix_set_lock  = 'X'
*           IX_DEL_LOCK  =
            iv_no_popup  = 'X'
          IMPORTING
            ev_done      = lv_done
          CHANGING
            iv_date_from = lv_fdate
            iv_date_to   = lv_tdate
            iv_lockr     = lv_lockr.
        IF lv_done = 'X'.
*      IF sy-subrc = 0.
          <ls_out>-mansp  = lv_lockr.
          <ls_out>-fdate  = lv_fdate.
          <ls_out>-tdate  = lv_tdate.
          <ls_out>-status = icon_locked.
*      ENDIF.
        ENDIF.
*        CREATE OBJECT lr_memidoc.
*        SELECT SINGLE * FROM /idxmm/memidoc INTO ls_memidoc_u WHERE doc_id = <t_out>-opbel.
*        ls_memidoc_u-doc_status = c_memidoc_dnlcrsn.
*        APPEND ls_memidoc_u TO lt_memidoc_u.
**      TRY.
*        CALL METHOD /idxmm/cl_memi_document_db=>update
*          EXPORTING
**           iv_simulate   =
*            it_doc_update = lt_memidoc_u.
**         CATCH /idxmm/cx_bo_error .
**        ENDTRY.
*        IF sy-subrc = 0.
*          <t_out>-doc_status = c_memidoc_dnlcrsn.
*        ENDIF.
*      ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD select_block.
    DATA(lv_max) = REDUCE i( INIT ma = 0
       FOR ls IN it_sel_rows_index NEXT     ma = nmax( val1 = ma  val2 = ls-index )  ).
    DATA(lv_min) = REDUCE i( INIT mi = lines( mrt_out_dun->* )
       FOR ls IN it_sel_rows_index NEXT     mi = nmin( val1 = mi  val2 = ls-index )  ).
    IF lv_max >= lv_min.
      LOOP AT mrt_out_dun->* ASSIGNING FIELD-SYMBOL(<ls_out>) FROM lv_min TO lv_max.
        READ TABLE mt_filter WITH KEY table_line = sy-tabix TRANSPORTING NO FIELDS.
        CHECK sy-subrc NE 0.
        <ls_out>-sel = 'X'.
      ENDLOOP.
    ENDIF.
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
