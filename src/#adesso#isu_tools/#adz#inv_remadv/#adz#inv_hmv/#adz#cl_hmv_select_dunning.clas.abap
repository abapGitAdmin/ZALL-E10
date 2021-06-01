CLASS /adz/cl_hmv_select_dunning DEFINITION
  PUBLIC
  FINAL.

  PUBLIC SECTION.
    DATA mt_out   TYPE /adz/hmv_t_out_dunning.

    METHODS:
      constructor
        IMPORTING is_constants TYPE  /adz/hmv_s_constants,

      read_data
        IMPORTING is_sel_screen TYPE /adz/hmv_s_dunning_sel_params,

      ende_proc_task       IMPORTING p_task TYPE clike
      .
  PROTECTED SECTION.
    TYPES : BEGIN OF ty_fkkvkp,              "Vertragskonto partnerspezifisch
              locked(30),
              buchvert(30),
              gpart           TYPE dfkkthi-gpart,
              vkont           TYPE dfkkthi-vkont,
              vkbez           TYPE fkkvk-vkbez,
              stdbk           TYPE fkkvkp-stdbk,
              recid           TYPE dfkkthi-recid,
              senid           TYPE dfkkthi-senid,
              vktyp           TYPE fkkvk-vktyp,
              mahnv           TYPE fkkvkp-mahnv,
              mansp           TYPE fkkvkp-mansp,
              v_group         TYPE dfkkthi-v_group,
              dexidocsent     TYPE e_dexidocsent,
              dexidocsentinv  TYPE e_dexidocsent,
              dexidocsentctrl TYPE e_dexidocsent,
              dexproc         TYPE e_dexproc,
              dexidocsendcat  TYPE e_dexidocsendcat,
              ext_ui          TYPE ext_ui,
            END OF ty_fkkvkp.
    TYPES  tty_fkkvkp TYPE TABLE OF ty_fkkvkp.

    TYPES: BEGIN OF tsy_dfkkop_buffer,
             opbel TYPE fkkmaze_struc-opbel,
             opupk TYPE fkkmaze_struc-opupk,
             vkont TYPE dfkkthi-vkont,
             bukrs TYPE fkkop-bukrs,
           END OF tsy_dfkkop_buffer.

    TYPES tty_dfkkop_buffer TYPE SORTED TABLE OF tsy_dfkkop_buffer WITH NON-UNIQUE KEY vkont bukrs.

    TYPES : BEGIN OF ty_opbel,
              opbel TYPE dfkkop-opbel,
              opupk TYPE dfkkop-opupk,
            END OF ty_opbel.
    TYPES  tty_opbel TYPE STANDARD TABLE OF ty_opbel.

    METHODS:
      basis_select
        IMPORTING
                  it_fkkvkp        TYPE tty_fkkvkp
                  iv_thidt_to      TYPE thidt_kk
                  iv_thidt_from    TYPE thidt_kk
                  it_rng_bclbn     TYPE /adz/hmv_rt_bcbln_kk
        CHANGING  ct_dfkkop_buffer TYPE tty_dfkkop_buffer,

      pre_select
        IMPORTING
          it_dfkkop_buffer TYPE tty_dfkkop_buffer
          is_fkkvkp        TYPE ty_fkkvkp
          is_sel_screen    TYPE /adz/hmv_s_dunning_sel_params
          iv_thidt_to      TYPE thidt_kk
          iv_thidt_from    TYPE thidt_kk
        CHANGING
          ct_bcbln         TYPE /adz/hmv_t_selct
          ct_memidoc       TYPE /adz/hmv_t_selct_memi
          ct_msbdoc        TYPE /adz/hmv_t_selct_msb,

      serv_prov
        CHANGING
          cs_fkkvkp TYPE ty_fkkvkp,

      get_locks_vk
        CHANGING
          cs_fkkvkp TYPE ty_fkkvkp,

      update_result_table
      .

  PRIVATE SECTION.
    DATA  ms_constants  TYPE /adz/hmv_s_constants.
    DATA  ms_sel_params TYPE /adz/hmv_s_dunning_sel_params.
    DATA  ms_stats      TYPE /adz/hmv_idoc.

    DATA gc_taskmanager TYPE REF TO /adz/cl_hmv_tasks.

ENDCLASS.



CLASS /adz/cl_hmv_select_dunning IMPLEMENTATION.


  METHOD basis_select.
    DATA lt_rng_vkont TYPE /adz/inv_rt_vkont_kk.
    DATA lt_rng_stdbk TYPE RANGE OF fkkvkp-stdbk.

    lt_rng_vkont = VALUE #( FOR ls IN it_fkkvkp ( sign = 'I' option = 'EQ' low = ls-vkont ) ).
    lt_rng_stdbk = VALUE #( FOR ls IN it_fkkvkp ( sign = 'I' option = 'EQ' low = ls-stdbk ) ).

    "    DELETE ADJACENT DUPLICATES FROM lt_rng_stdbk.

    IF lt_rng_vkont IS NOT INITIAL.
      SELECT opbel opupk vkont bukrs FROM dfkkop INTO TABLE ct_dfkkop_buffer
             WHERE augst IN (' ','9')
               AND vkont IN lt_rng_vkont
               AND bukrs IN lt_rng_stdbk
               AND faedn <= iv_thidt_to
               AND faedn >= iv_thidt_from
               AND opbel IN it_rng_bclbn.
    ENDIF.
  ENDMETHOD.


  METHOD constructor.
    ms_constants = is_constants.
  ENDMETHOD.


  METHOD ende_proc_task.
    DATA  lt_out      TYPE /adz/hmv_t_out_dunning.

    RECEIVE RESULTS FROM FUNCTION '/ADZ/HMV_DUN_SELECT_TASK'
      TABLES
           et_out      = lt_out
      EXCEPTIONS
         communication_failure = 1
         system_failure        = 2.

    IF sy-subrc = 0.
      gc_taskmanager->task_finished( ).
      gc_taskmanager->lock( ).
      APPEND LINES OF lt_out TO mt_out.

      gc_taskmanager->release( ).
    ELSE.
      MESSAGE |Fehler bei ende_task { p_task }| TYPE 'X'.
      EXIT.
    ENDIF.

  ENDMETHOD.


  METHOD get_locks_vk.
    DATA  lt_dfkklock    TYPE TABLE OF dfkklocks.
    DATA  ls_dfkkop      TYPE dfkkop.
    DATA  lv_lock_exist  TYPE c.
    DATA  lv_lock_depex  TYPE c.

* Check dunning block in contract account
    CLEAR: cs_fkkvkp-mansp.
    ls_dfkkop-gpart = cs_fkkvkp-gpart.
    ls_dfkkop-vkont = cs_fkkvkp-vkont.

    CALL FUNCTION 'FKK_S_LOCK_GET'
      EXPORTING
        i_keystructure           = ls_dfkkop
        i_lotyp                  = ms_constants-c_lotyp_gp_vk
        i_proid                  = ms_constants-c_proid_dunn
        i_lockdate               = sy-datum
        i_x_mass_access          = space
        i_x_dependant_locktypes  = space
      IMPORTING
        e_x_lock_exist           = lv_lock_exist
        e_x_dependant_lock_exist = lv_lock_depex
      TABLES
        et_locks                 = lt_dfkklock.
    IF lt_dfkklock IS NOT INITIAL.
      cs_fkkvkp-mansp  = lt_dfkklock[ 1 ]-lockr.
      cs_fkkvkp-locked = icon_locked.
    ENDIF.
  ENDMETHOD.


  METHOD pre_select.
    DATA   lt_opbel TYPE tty_opbel.
    REFRESH ct_bcbln.
    REFRESH ct_memidoc.
    REFRESH ct_msbdoc.    "Nuss 09.2018

* Preselect for dfkkthi
    IF it_dfkkop_buffer IS NOT INITIAL.
      lt_opbel = VALUE #( FOR ls IN it_dfkkop_buffer
        WHERE ( vkont =  is_fkkvkp-vkont AND bukrs = is_fkkvkp-stdbk AND opbel IN is_sel_screen-so_bcbln )
        ( opbel = ls-opbel  opupk = ls-opupk ) ).
    ELSE.
      " selektion von db
      SELECT opbel opupk
             INTO CORRESPONDING FIELDS OF TABLE lt_opbel
             FROM dfkkop
             WHERE augst IN (' ','9')
               AND vkont  = is_fkkvkp-vkont
               AND faedn <= iv_thidt_to
               AND faedn >= iv_thidt_from
               AND bukrs  = is_fkkvkp-stdbk
               AND opbel IN is_sel_screen-so_bcbln.
    ENDIF.
    CHECK lt_opbel[] IS NOT INITIAL.
    SELECT bcbln opbel opupw opupk
          INTO CORRESPONDING FIELDS OF TABLE ct_bcbln
          FROM dfkkthi
          FOR ALL ENTRIES IN lt_opbel
          WHERE bcbln = lt_opbel-opbel
            AND vkont IN is_sel_screen-so_ekont
            AND thidt <= iv_thidt_to
            AND thidt >= iv_thidt_from
            AND bukrs IN is_sel_screen-so_bukrs.

    SORT ct_bcbln BY bcbln opbel opupw opupk.

* <<< ET_20160229
* Preselect memidoc
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE ct_memidoc
      FROM /idxmm/memidoc
      FOR ALL ENTRIES IN lt_opbel
        WHERE ci_fica_doc_no = lt_opbel-opbel
          AND opupk = lt_opbel-opupk
          AND due_date <= iv_thidt_to
          AND due_date >= iv_thidt_from.
    SORT ct_memidoc.
* >>> ET_20160229

* Preselect msbdoc
    SELECT * INTO CORRESPONDING FIELDS OF TABLE ct_msbdoc
    FROM dfkkinvdoc_i AS i
      INNER JOIN dfkkinvdoc_h AS h
      ON i~invdocno = h~invdocno
    FOR ALL ENTRIES IN lt_opbel
    WHERE i~opbel = lt_opbel-opbel
    AND i~faedn <= iv_thidt_to
    AND i~faedn >= iv_thidt_from
    AND i~bukrs IN is_sel_screen-so_bukrs
    AND h~inv_process = 'MO'
    AND h~inv_type = 'MO'
    AND h~/mosb/inv_doc_ident NE ''.
    SORT ct_msbdoc.
    DELETE ADJACENT DUPLICATES FROM ct_msbdoc COMPARING ALL FIELDS.

  ENDMETHOD.


  METHOD read_data.
    "----------------------------------------------------------------------------------------
    DATA ls_task           TYPE /adz/cl_hmv_tasks=>ty_task.
    DATA lv_x_thidt_from   TYPE thidt_kk.
    DATA lv_x_thidt_to     TYPE thidt_kk.
    DATA lt_fkkvkp         TYPE tty_fkkvkp.
    DATA lt_dfkkop_buffer  TYPE tty_dfkkop_buffer.
    DATA lt_bcbln          TYPE /adz/hmv_t_selct.
    DATA lt_memidoc        TYPE /adz/hmv_t_selct_memi.
    DATA lt_msbdoc         TYPE /adz/hmv_t_selct_msb.
    DATA lv_err_msg        TYPE char255.

    DATA lt_out            TYPE /adz/hmv_t_out_dunning.
    DATA ls_wa_out         TYPE /adz/hmv_s_out_dunning.
    DATA ls_wa_tmp         TYPE /adz/hmv_s_out_dunning.

    ms_sel_params = is_sel_screen.

    SELECT k~vkont k~vktyp k~vkbez
           p~gpart p~stdbk p~mahnv
           INTO CORRESPONDING FIELDS OF TABLE lt_fkkvkp
           FROM fkkvk AS k INNER JOIN fkkvkp AS p
             ON k~vkont = p~vkont
          WHERE k~vkont IN is_sel_screen-so_vkont
            AND p~stdbk IN is_sel_screen-so_bukrs
            AND p~mahnv IN is_sel_screen-so_mahnv.

    IF is_sel_screen-so_faedn IS NOT  INITIAL.
      IF is_sel_screen-so_faedn[ 1 ]-high IS INITIAL.
        lv_x_thidt_from = is_sel_screen-so_faedn[ 1 ]-low.
        lv_x_thidt_to   = is_sel_screen-so_faedn[ 1 ]-low.
      ELSE.
        lv_x_thidt_to   = is_sel_screen-so_faedn[ 1 ]-high.
        lv_x_thidt_from = is_sel_screen-so_faedn[ 1 ]-low.
      ENDIF.
    ENDIF.

    basis_select(
      EXPORTING
        it_fkkvkp        = lt_fkkvkp
        iv_thidt_to      = lv_x_thidt_to
        iv_thidt_from    = lv_x_thidt_from
        it_rng_bclbn     = is_sel_screen-so_bcbln
      CHANGING
        ct_dfkkop_buffer = lt_dfkkop_buffer
    ).

    DATA(lv_x_maxts) = COND integer( WHEN sy-batch = 'X' THEN ms_constants-c_maxtb ELSE ms_constants-c_maxtd ).
    IF ms_sel_params-p_maxpar IS NOT INITIAL.
      lv_x_maxts = ms_sel_params-p_maxpar.
    ENDIF.
    gc_taskmanager = NEW /adz/cl_hmv_tasks( iv_max_par_taks = lv_x_maxts ).

    "DATA(lt_so_augst) = VALUE rsdsselopt_t( FOR ls1 IN is_sel_screen-so_augst ( CORRESPONDING #( ls1 ) ) ).
    "DATA(lt_so_mansp) = VALUE rsdsselopt_t( FOR ls2 IN is_sel_screen-so_mansp ( CORRESPONDING #( ls2 ) ) ).
    "DATA(lt_so_mahns) = VALUE rsdsselopt_t( FOR ls3 IN is_sel_screen-so_mahns ( CORRESPONDING #( ls3 ) ) ).

    LOOP AT lt_fkkvkp INTO DATA(ls_fkkvkp).
      get_locks_vk(  CHANGING  cs_fkkvkp = ls_fkkvkp ).
      serv_prov( CHANGING  cs_fkkvkp = ls_fkkvkp ).

      CLEAR ls_wa_out.
      ls_wa_out-buchvert         = ls_fkkvkp-buchvert.
      ls_wa_out-aggvk            = ls_fkkvkp-vkont.
      ls_wa_out-vkbez            = ls_fkkvkp-vkbez.
      ls_wa_out-recid            = ls_fkkvkp-recid.
      ls_wa_out-senid            = ls_fkkvkp-senid.
      ls_wa_out-vktyp            = ls_fkkvkp-vktyp.
      ls_wa_out-mahnv            = ls_fkkvkp-mahnv.
      ls_wa_out-agmsp            = ls_fkkvkp-mansp.
      ls_wa_out-v_group          = ls_fkkvkp-v_group.
      ls_wa_out-dexidocsent      = ls_fkkvkp-dexidocsent.
      ls_wa_out-dexidocsentctrl  = ls_fkkvkp-dexidocsentctrl.
      ls_wa_out-dexidocsendcat   = ls_fkkvkp-dexidocsendcat.
      ls_wa_out-dexproc          = ls_fkkvkp-dexproc.
      ls_wa_out-locked           = ls_fkkvkp-locked.
      ls_wa_tmp = ls_wa_out.
*
      pre_select(
        EXPORTING
          it_dfkkop_buffer = lt_dfkkop_buffer
          is_fkkvkp        = ls_fkkvkp
          is_sel_screen    = is_sel_screen
          iv_thidt_to      = lv_x_thidt_to
          iv_thidt_from    = lv_x_thidt_from
        CHANGING
          ct_bcbln         = lt_bcbln
          ct_memidoc       = lt_memidoc
          ct_msbdoc        = lt_msbdoc
      ).

      DATA(lv_min_portion) = 2000.

      DO 3 TIMES.
        CASE sy-index.
          WHEN 1.
            DATA(lv_nr_selcond) = lines( lt_bcbln ).
            DATA(lv_taskname)   = |{ ms_constants-c_doc_kzd }_{ ls_fkkvkp-vkont }|.
          WHEN 2.
            lv_nr_selcond = lines( lt_memidoc ).
            lv_taskname = |{ ms_constants-c_doc_kzm }_{ ls_fkkvkp-vkont }|.
          WHEN 3.
            lv_nr_selcond = lines( lt_msbdoc ).
            lv_taskname = |{ ms_constants-c_doc_kzmsb }_{ ls_fkkvkp-vkont }|.
        ENDCASE.
*  IF sy-sysid = 'E10' and lv_nr_selcond <= 0.
*    " xxxx debug
*    lv_nr_selcond  = 50.
*    c_min_selcond_tasks = 1.
*    c_max_selcond_tasks = 2.
*  ENDIF.
        IF lv_nr_selcond > 0.
          gc_taskmanager->create_tasks(
            EXPORTING
              iv_repid               = sy-repid
              iv_size_selector_array = lv_nr_selcond
              iv_type_str            = lv_taskname
              iv_min_selects         = lv_min_portion
              iv_max_selects         = ms_constants-c_prtio
              iv_append              = 'X'
          ).
        ENDIF.
      ENDDO.

      DATA lt_select      LIKE lt_bcbln.
      DATA lt_select_memi LIKE lt_memidoc.
      DATA lt_select_msb  LIKE lt_msbdoc.

      WHILE ( gc_taskmanager->get_next_task( IMPORTING es_task = ls_task ) EQ abap_true ).
        CLEAR lt_select.
        CLEAR lt_select_memi.
        CLEAR lt_select_msb.
        CLEAR lt_out.

        CASE ls_task-typeinfo(1).
            "** HMV_Select für DFKKTHI
          WHEN ms_constants-c_doc_kzd.
            ls_wa_tmp-kennz = ms_constants-c_doc_kzd.
            APPEND LINES OF lt_bcbln FROM ls_task-low TO  ls_task-high TO  lt_select.

            "** HMV_Select für MEMIDOC
          WHEN ms_constants-c_doc_kzm. " /idxmm/if_constants=>gc_createdfrom_m.
            ls_wa_tmp-kennz = /idxmm/if_constants=>gc_createdfrom_m.
            "            APPEND ls_wa_out TO lt_out.
            APPEND LINES OF lt_memidoc FROM ls_task-low TO  ls_task-high TO  lt_select_memi.

            "** HMV_Select für MSB Selection
          WHEN ms_constants-c_doc_kzmsb.
            ls_wa_tmp-kennz = ms_constants-c_doc_kzmsb.
            APPEND LINES OF lt_msbdoc FROM ls_task-low TO  ls_task-high TO  lt_select_msb.
        ENDCASE.
        "---------------------------------
        CHECK lt_select_msb IS NOT INITIAL
           OR lt_select IS NOT INITIAL
           OR lt_select_memi IS NOT INITIAL.
        IF lv_x_maxts > 1.
          CALL FUNCTION '/ADZ/HMV_DUN_SELECT_TASK'
            STARTING NEW TASK ls_task-name
            DESTINATION IN GROUP DEFAULT
            CALLING ende_proc_task ON END OF TASK
            EXPORTING
              is_constants          = ms_constants
              is_out_vorlage        = ls_wa_tmp
              ib_akonto             = is_sel_screen-p_akonto
              ib_updte              = is_sel_screen-pa_updte
              ib_adunn              = is_sel_screen-p_dunn
              iv_lockr              = is_sel_screen-pa_lockr
              iv_fdate              = is_sel_screen-pa_fdate
              iv_tdate              = is_sel_screen-pa_tdate
              it_so_augst           = is_sel_screen-so_augst
              it_so_mansp           = is_sel_screen-so_mansp
              it_so_mahns           = is_sel_screen-so_mahns
              it_select_bel         = lt_select
              it_select_memi        = lt_select_memi
              it_select_msb         = lt_select_msb
            TABLES
              et_out                = lt_out              " Ausgabestruktur für /ADZ/HMV_DUNNING
            EXCEPTIONS
              system_failure        = 1 MESSAGE lv_err_msg
              communication_failure = 2 MESSAGE lv_err_msg
              resource_failure      = 3
              OTHERS                = 4.
          IF sy-subrc NE 0.
            IF sy-subrc <= 2.
              MESSAGE lv_err_msg TYPE 'X'.
            ELSE.
              MESSAGE TEXT-e04 TYPE 'X'.
            ENDIF.
          ENDIF.
        ELSE.
          CALL FUNCTION '/ADZ/HMV_DUN_SELECT_TASK'
            EXPORTING
              is_constants          = ms_constants
              is_out_vorlage        = ls_wa_tmp
              ib_akonto             = is_sel_screen-p_akonto
              ib_updte              = is_sel_screen-pa_updte
              ib_adunn              = is_sel_screen-p_dunn
              iv_lockr              = is_sel_screen-pa_lockr
              iv_fdate              = is_sel_screen-pa_fdate
              iv_tdate              = is_sel_screen-pa_tdate
              it_so_augst           = is_sel_screen-so_augst
              it_so_mansp           = is_sel_screen-so_mansp
              it_so_mahns           = is_sel_screen-so_mahns
              it_select_bel         = lt_select
              it_select_memi        = lt_select_memi
              it_select_msb         = lt_select_msb
            TABLES
              et_out                = lt_out              " Ausgabestruktur für /ADZ/HMV_DUNNING
            EXCEPTIONS
              system_failure        = 1
              communication_failure = 2 message lv_err_msg
              resource_failure      = 3
              OTHERS                = 4.
          IF sy-subrc NE 0.
            IF sy-subrc EQ 2.
              MESSAGE lv_err_msg TYPE 'X'.
            ELSE.
              MESSAGE TEXT-e04 TYPE 'X'.
            ENDIF.
          ENDIF.
          APPEND LINES OF lt_out TO mt_out.
          gc_taskmanager->task_finished( ).
        ENDIF.
      ENDWHILE.
    ENDLOOP.
    gc_taskmanager->wait_for_all_tasks( ).

    update_result_table( ).
    SORT mt_out.
    DELETE ADJACENT DUPLICATES FROM mt_out COMPARING ALL FIELDS.

  ENDMETHOD.


  METHOD serv_prov.
    DATA lv_initiator  TYPE e_deregspinitiator.
    DATA lv_partner    TYPE e_deregsppartner.
    DATA ls_param_inv_outbound TYPE inv_param_inv_outbound.

* --- determine receiving service provider
    CALL FUNCTION 'ISU_DEREG_GET_AGREEMENT_VKONT'
      EXPORTING
        x_keydate           = sy-datum
        x_vkont             = cs_fkkvkp-vkont
      IMPORTING
        y_initiator         = lv_initiator
        y_partner           = lv_partner
        y_param_wa          = ls_param_inv_outbound
      EXCEPTIONS
        agreement_not_found = 1
        bupart_not_found    = 2
        not_unique          = 3
        internal_error      = 4
        OTHERS              = 5.

    IF sy-subrc = 0.
      cs_fkkvkp-recid = lv_initiator.
      cs_fkkvkp-senid = lv_partner.
    ENDIF.
    READ TABLE ls_param_inv_outbound-account_param ASSIGNING FIELD-SYMBOL(<outbound_acc>)
      WITH KEY vkont_aggbill = cs_fkkvkp-vkont.

    IF sy-subrc = 0.
      cs_fkkvkp-v_group = <outbound_acc>-v_group.
    ENDIF.
    READ TABLE ls_param_inv_outbound-avis_param ASSIGNING FIELD-SYMBOL(<outbound_avis>)
      WITH KEY vkont_aggbill = cs_fkkvkp-vkont.

    IF sy-subrc = 0.
      IF <outbound_avis>-saveacc = 'X'.
        cs_fkkvkp-buchvert = icon_agent_orphan.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD update_result_table.
    DATA: ls_pod_rel       TYPE /idxgc/pod_rel,
          lt_pod_rel       TYPE STANDARD TABLE OF /idxgc/pod_rel,
          ls_euitrans      TYPE euitrans,
          lv_tabix         TYPE sy-tabix,
          ls_euitrans_help TYPE euitrans.

    LOOP AT mt_out ASSIGNING FIELD-SYMBOL(<ls_out>).
      lv_tabix = sy-tabix.

      IF <ls_out>-int_ui IS NOT INITIAL.
        SELECT * FROM /idxgc/pod_rel INTO TABLE lt_pod_rel
          WHERE int_ui2 = <ls_out>-int_ui.
        IF sy-subrc = 0.
          READ TABLE lt_pod_rel INTO ls_pod_rel INDEX 1.
          SELECT SINGLE * FROM euitrans INTO ls_euitrans
            WHERE int_ui = ls_pod_rel-int_ui1.

          <ls_out>-int_ui_melo = ls_pod_rel-int_ui1.
          <ls_out>-ext_ui_melo = ls_euitrans-ext_ui.
        ENDIF.
      ELSE.
        IF <ls_out>-ext_ui IS NOT INITIAL.
          CLEAR ls_euitrans_help.
          SELECT SINGLE * FROM euitrans INTO ls_euitrans_help
            WHERE ext_ui = <ls_out>-ext_ui.
          CHECK sy-subrc = 0.
          MOVE ls_euitrans_help-int_ui TO <ls_out>-int_ui.
          SELECT * FROM /idxgc/pod_rel INTO TABLE lt_pod_rel
            WHERE int_ui2 = <ls_out>-int_ui.
          IF sy-subrc = 0.
            READ TABLE lt_pod_rel INTO ls_pod_rel INDEX 1.
            SELECT SINGLE * FROM euitrans INTO ls_euitrans
              WHERE int_ui = ls_pod_rel-int_ui1.

            <ls_out>-int_ui_melo =  ls_pod_rel-int_ui1.
            <ls_out>-ext_ui_melo =  ls_euitrans-ext_ui.
          ENDIF.
        ENDIF.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
