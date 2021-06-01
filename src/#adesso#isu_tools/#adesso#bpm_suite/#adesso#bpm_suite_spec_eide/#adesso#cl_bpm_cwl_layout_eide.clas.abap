class /ADESSO/CL_BPM_CWL_LAYOUT_EIDE definition
  public
  create public .

public section.

  interfaces IF_EMMA_CWL_LAYOUT .
protected section.
private section.
ENDCLASS.



CLASS /ADESSO/CL_BPM_CWL_LAYOUT_EIDE IMPLEMENTATION.


  METHOD IF_EMMA_CWL_LAYOUT~DETERMINE_SELCRITERIA.

  ENDMETHOD.


  METHOD if_emma_cwl_layout~select_cases_from_db.
    DATA: lt_bpem_category      TYPE RANGE OF emma_ccat,
          ls_bpem_category      LIKE LINE OF lt_bpem_category,
          lt_actor_id           TYPE RANGE OF actorid,
          ls_actor_id           LIKE LINE OF lt_actor_id,
          lt_proc_id            TYPE RANGE OF /idxgc/de_proc_id,
          ls_proc_id            LIKE LINE OF lt_proc_id,
          lt_transreason        TYPE RANGE OF /idxgc/de_msgtransreason,
          ls_transreason        LIKE LINE OF lt_transreason,
          lt_prio               TYPE RANGE OF emma_cprio,
          ls_prio               LIKE LINE OF lt_prio,
          lt_due_date           TYPE RANGE OF due_date,
          ls_due_date           LIKE LINE OF lt_due_date,
          lt_mainobjkey         TYPE RANGE OF swo_typeid,
          ls_mainobjkey         LIKE LINE OF lt_mainobjkey,
          lt_actors             TYPE TABLE OF bapi_swhactor,
          lt_cases              TYPE TABLE OF emma_case,
          lv_object             TYPE swo_typeid,
          lv_ext_ui             TYPE ext_ui,
          lv_int_ui             TYPE int_ui,
          lt_int_ui             TYPE TABLE OF int_ui,
          lt_pdoc_data          TYPE /idxgc/t_pdoc_data,
          lt_pdoc_status_active TYPE isu_ranges_tab,
          lt_tab_ddshretval     TYPE TABLE OF ddshretval,
          lt_process_id         TYPE TABLE OF /idxgc/de_proc_id,
          lt_sel_proc_id        TYPE isu_ranges_tab,
          lt_sel_int_ui	        TYPE isu_ranges_tab,
          lv_currproc           TYPE emma_cprocessor,
          lv_own_cases          TYPE kennzx VALUE abap_true.

    FIELD-SYMBOLS: <fs_actors>         TYPE bapi_swhactor,
                   <fs_pdoc_data>      LIKE LINE OF lt_pdoc_data,
                   <fs_tab_ddshretval> LIKE LINE OF lt_tab_ddshretval.

    lv_currproc = sy-uname.

    "Standard für Austeuerung von technischen Fehlern
    ls_bpem_category-option = 'EQ'.
    ls_bpem_category-sign = 'E'.
    ls_bpem_category-low = 'ZIX4'.
    APPEND ls_bpem_category TO lt_bpem_category.
    ls_bpem_category-low = 'ZIX5'.
    APPEND ls_bpem_category TO lt_bpem_category.
    ls_bpem_category-low = 'ZIX6'.
    APPEND ls_bpem_category TO lt_bpem_category.
    ls_bpem_category-low = 'ZIX7'.
    APPEND ls_bpem_category TO lt_bpem_category.
    ls_bpem_category-low = 'ZIX8'.
    APPEND ls_bpem_category TO lt_bpem_category.
    ls_bpem_category-low = 'ZIX9'.
    APPEND ls_bpem_category TO lt_bpem_category.
    ls_bpem_category-low = 'ZIXE'.
    APPEND ls_bpem_category TO lt_bpem_category.


    ls_actor_id-option = 'EQ'.
    ls_actor_id-sign = 'I'.

    ls_proc_id-option = 'EQ'.
    ls_proc_id-sign = 'I'.

    ls_due_date-option = 'LT'.
    ls_due_date-sign = 'I'.

    ls_mainobjkey-option = 'EQ'.
    ls_mainobjkey-sign = 'I'.

    ls_transreason-option = 'EQ'.
    ls_transreason-sign = 'I'.

    ls_prio-option = 'EQ'.
    ls_prio-sign = 'E'.
    ls_prio-low = /adesso/if_bpm_eide_co=>gc_case_prio_5.
    APPEND ls_prio TO lt_prio.

    TRY.
        CALL METHOD /idxgc/cl_utility_service=>/idxgc/if_utility_service~built_status_select_table
          EXPORTING
            iv_status_complete     = /idxgc/if_constants=>gc_false
            iv_status_not_relevant = /idxgc/if_constants=>gc_false
          IMPORTING
            et_sel_process_status  = lt_pdoc_status_active.
      CATCH /idxgc/cx_utility_error.
    ENDTRY.

    CASE iv_layout.
      WHEN 'ZADG'.
        CASE iv_butno.
          WHEN 1.
            CLEAR lt_bpem_category.
          WHEN 2. "Stammdatenänderung allgemein
            ls_proc_id-low = /adesso/if_bpm_eide_co=>gc_proc_id_8030.
            APPEND ls_proc_id TO lt_proc_id.
            ls_proc_id-low = /adesso/if_bpm_eide_co=>gc_proc_id_8031.
            APPEND ls_proc_id TO lt_proc_id.
            ls_proc_id-low = /adesso/if_bpm_eide_co=>gc_proc_id_8032.
            APPEND ls_proc_id TO lt_proc_id.
            ls_proc_id-low = /adesso/if_bpm_eide_co=>gc_proc_id_8033.
            APPEND ls_proc_id TO lt_proc_id.
            ls_proc_id-low = /adesso/if_bpm_eide_co=>gc_proc_id_8034.
            APPEND ls_proc_id TO lt_proc_id.
          WHEN 3. "Gerätewechsel
            ls_proc_id-low = /adesso/if_bpm_eide_co=>gc_proc_id_8011.
            APPEND ls_proc_id TO lt_proc_id.
            ls_proc_id-low = /adesso/if_bpm_eide_co=>gc_proc_id_8012.
            APPEND ls_proc_id TO lt_proc_id.
            ls_proc_id-low = /adesso/if_bpm_eide_co=>gc_proc_id_8013.
            APPEND ls_proc_id TO lt_proc_id.
            ls_proc_id-low = /adesso/if_bpm_eide_co=>gc_proc_id_8014.
            APPEND ls_proc_id TO lt_proc_id.
          WHEN 4. "Stammdatenänderung
            ls_transreason-low = /adesso/if_bpm_eide_co=>gc_trans_reason_code_ze6.
            APPEND ls_transreason TO lt_transreason.
          WHEN 5.
            ls_transreason-low = /adesso/if_bpm_eide_co=>gc_trans_reason_code_ze7.
            APPEND ls_transreason TO lt_transreason.
          WHEN 6.
            ls_transreason-low = /adesso/if_bpm_eide_co=>gc_trans_reason_code_ze9.
            APPEND ls_transreason TO lt_transreason.
          WHEN 7.
            ls_transreason-low = /adesso/if_bpm_eide_co=>gc_trans_reason_code_zf0.
            APPEND ls_transreason TO lt_transreason.
          WHEN 8.
            ls_transreason-low = /adesso/if_bpm_eide_co=>gc_trans_reason_code_zf1.
            APPEND ls_transreason TO lt_transreason.
          WHEN 9.
            ls_transreason-low = /adesso/if_bpm_eide_co=>gc_trans_reason_code_zf2.
            APPEND ls_transreason TO lt_transreason.
          WHEN 10.
            ls_transreason-low = /adesso/if_bpm_eide_co=>gc_trans_reason_code_zf3.
            APPEND ls_transreason TO lt_transreason.
          WHEN 11.
            ls_transreason-low = /adesso/if_bpm_eide_co=>gc_trans_reason_code_zf4.
            APPEND ls_transreason TO lt_transreason.
          WHEN 12.
            ls_transreason-low = /adesso/if_bpm_eide_co=>gc_trans_reason_code_zf5.
            APPEND ls_transreason TO lt_transreason.
          WHEN 13.
            ls_transreason-low = /adesso/if_bpm_eide_co=>gc_trans_reason_code_zf6.
            APPEND ls_transreason TO lt_transreason.
          WHEN 14.
            ls_transreason-low = /adesso/if_bpm_eide_co=>gc_trans_reason_code_zf7.
            APPEND ls_transreason TO lt_transreason.
          WHEN 15.
            ls_transreason-low = /adesso/if_bpm_eide_co=>gc_trans_reason_code_zf8.
            APPEND ls_transreason TO lt_transreason.
          WHEN 16.
            ls_transreason-low = /adesso/if_bpm_eide_co=>gc_trans_reason_code_zg7.
            APPEND ls_transreason TO lt_transreason.
          WHEN 17.
            ls_transreason-low = /adesso/if_bpm_eide_co=>gc_trans_reason_code_zg8.
            APPEND ls_transreason TO lt_transreason.
          WHEN 18.
            CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
              EXPORTING
                tabname           = ''
                fieldname         = ''
                searchhelp        = 'ISU_EDM_EXT_UI'
              TABLES
                return_tab        = lt_tab_ddshretval
              EXCEPTIONS
                field_not_found   = 1
                no_help_for_field = 2
                inconsistent_help = 3
                no_values_found   = 4
                OTHERS            = 99.

            IF sy-subrc = 0.
              LOOP AT lt_tab_ddshretval ASSIGNING <fs_tab_ddshretval>.
                lv_object = <fs_tab_ddshretval>-fieldval.
              ENDLOOP.
            ENDIF.

            IF lv_object IS NOT INITIAL.
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  input  = lv_object
                IMPORTING
                  output = lv_ext_ui.

              TRY.
                  CALL METHOD /idxgc/cl_utility_service_isu=>get_intui_from_extui
                    EXPORTING
                      iv_ext_ui = lv_ext_ui
                    IMPORTING
                      rv_int_ui = lv_int_ui.

                  APPEND lv_int_ui TO lt_int_ui.

                  SELECT proc_id FROM /idxgc/proc INTO TABLE lt_process_id WHERE source = 'S'.

                  CALL METHOD /idxgc/cl_process_document_db=>/idxgc/if_process_document_db~select_pdoc_mass
                    EXPORTING
                      it_sel_process_status = lt_pdoc_status_active
                      it_sel_int_ui         = /idxgc/cl_utility_service=>/idxgc/if_utility_service~build_range_table( it_table = lt_int_ui )
                      it_sel_process_id     = /idxgc/cl_utility_service=>/idxgc/if_utility_service~build_range_table( it_table = lt_process_id )
                      iv_max_records        = space
                    IMPORTING
                      et_pdoc_data          = lt_pdoc_data.

                  LOOP AT lt_pdoc_data ASSIGNING <fs_pdoc_data>.
                    ls_mainobjkey-low = <fs_pdoc_data>-switchnum.
                    APPEND ls_mainobjkey TO lt_mainobjkey.
                  ENDLOOP.
                CATCH /idxgc/cx_process_error /idxgc/cx_utility_error.
              ENDTRY.
            ENDIF.
          WHEN 19. "Prio Selektion
            CLEAR lt_prio.
            ls_prio-sign = 'I'.
            ls_prio-option = 'EQ'.
            ls_prio-low = /adesso/if_bpm_eide_co=>gc_case_prio_5.
            APPEND ls_prio TO lt_prio.
          WHEN 20. "Nicht zugeordnete Klärungsfälle
            lv_own_cases = abap_false.
            CLEAR lv_currproc.
            CLEAR lt_bpem_category.
          WHEN 21. "Technische Klärungsfälle
            CLEAR lt_bpem_category.
            ls_bpem_category-option = 'EQ'.
            ls_bpem_category-sign = 'I'.
            ls_bpem_category-low = 'ZIX4'.
            APPEND ls_bpem_category TO lt_bpem_category.
            ls_bpem_category-low = 'ZIX5'.
            APPEND ls_bpem_category TO lt_bpem_category.
            ls_bpem_category-low = 'ZIX6'.
            APPEND ls_bpem_category TO lt_bpem_category.
            ls_bpem_category-low = 'ZIX7'.
            APPEND ls_bpem_category TO lt_bpem_category.
            ls_bpem_category-low = 'ZIX8'.
            APPEND ls_bpem_category TO lt_bpem_category.
            ls_bpem_category-low = 'ZIX9'.
            APPEND ls_bpem_category TO lt_bpem_category.
            ls_bpem_category-low = 'ZIXE'.
            APPEND ls_bpem_category TO lt_bpem_category.
          WHEN OTHERS.
        ENDCASE.
      WHEN OTHERS.
        "Bisher keine weiteren notwendig
    ENDCASE.

    IF lv_own_cases = abap_true.
      CALL METHOD cl_emma_case=>determine_superior_org_obj
        EXPORTING
          iv_orgtype               = 'US'
          iv_orgid                 = sy-uname
          iv_wegid                 = 'EMMA1'
          iv_plvar                 = space
          iv_begda                 = sy-datum
          iv_endda                 = sy-datum
        RECEIVING
          et_actors                = lt_actors
        EXCEPTIONS
          error_determining_actors = 1
          OTHERS                   = 2.
      IF sy-subrc = 0.
      ENDIF.

      LOOP AT lt_actors ASSIGNING <fs_actors> WHERE otype = 'O' OR otype = 'S' OR otype = 'US'.
        ls_actor_id-low = <fs_actors>-objid.
        APPEND ls_actor_id TO lt_actor_id.
      ENDLOOP.

      "1. Schritt = Alle BPEM-Fälle, die anhand der Regel zum Benutzer passen
      SELECT * FROM emma_case AS emc
        JOIN emma_cactor AS ema ON emc~casenr = ema~casenr
        INTO CORRESPONDING FIELDS OF TABLE et_cases
        WHERE emc~ccat IN lt_bpem_category AND
              ( emc~status = /adesso/if_bpm_eide_co=>gc_case_stat_1 OR emc~status = /adesso/if_bpm_eide_co=>gc_case_stat_2 ) AND
              emc~due_date IN lt_due_date AND
              emc~mainobjkey IN lt_mainobjkey AND
              emc~zz_proc_id IN lt_proc_id AND
              emc~zz_msgtransreason IN lt_transreason AND
              emc~prio IN lt_prio AND
              ema~objid IN lt_actor_id.

      "2. Schritt = Alle BPEM-Fälle für die der Benutzer Bearbeiter ist. Nötig, da es auch sein kann, das über die Regel der Benutzer ursprünglich nicht gezogen wurde.
      SELECT * FROM emma_case APPENDING TABLE et_cases
        WHERE ccat IN lt_bpem_category AND
              ( status = /adesso/if_bpm_eide_co=>gc_case_stat_1 OR status = /adesso/if_bpm_eide_co=>gc_case_stat_2 ) AND
              due_date IN lt_due_date AND
              mainobjkey IN lt_mainobjkey AND
              zz_proc_id IN lt_proc_id AND
              zz_msgtransreason IN lt_transreason AND
              prio IN lt_prio AND
              currproc = lv_currproc.
    ELSE.
      "1. Schritt = Alle BPEM-Fälle die keine Bearbeiterzuordnung haben
      SELECT * FROM emma_case AS emc INTO CORRESPONDING FIELDS OF TABLE et_cases WHERE casenr NOT IN ( SELECT casenr FROM emma_cactor AS ema WHERE ema~casenr = emc~casenr ) AND
                                                                                       ( status = /adesso/if_bpm_eide_co=>gc_case_stat_1 OR emc~status = /adesso/if_bpm_eide_co=>gc_case_stat_2 ).

    ENDIF.

    SORT et_cases BY casenr ASCENDING.

    DELETE ADJACENT DUPLICATES FROM et_cases.

    MOVE abap_true TO ev_auto_list_refresh.

  ENDMETHOD.
ENDCLASS.
