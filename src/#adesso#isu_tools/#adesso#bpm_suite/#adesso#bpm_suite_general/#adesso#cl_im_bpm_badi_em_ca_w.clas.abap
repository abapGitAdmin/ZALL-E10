class /ADESSO/CL_IM_BPM_BADI_EM_CA_W definition
  public
  create public .

public section.

  interfaces IF_BADI_EMMA_CASE_WORK_LIST .
  interfaces IF_BADI_INTERFACE .
protected section.
private section.
ENDCLASS.



CLASS /ADESSO/CL_IM_BPM_BADI_EM_CA_W IMPLEMENTATION.


  METHOD if_badi_emma_case_work_list~call_enhancement_function.
    DATA: lt_spopli        TYPE TABLE OF spopli,
          ls_spopli        TYPE spopli,
          lt_emma_case     TYPE /adesso/tt_bpm_emma_case_obj,
          lr_case          TYPE REF TO cl_emma_case,
          lt_cases         TYPE isu_ranges_tab,
          ls_cases         LIKE LINE OF lt_cases,
          lt_ccat          TYPE isu_ranges_tab,
          ls_ccat          LIKE LINE OF lt_ccat,
          lt_case_stat     TYPE isu_ranges_tab,
          ls_case_stat     LIKE LINE OF lt_case_stat,
          lt_emma_ccat_sop TYPE TABLE OF emmac_ccat_sop,
          lv_swc_shtext    TYPE swc_shtext,
          ls_data          TYPE emma_case.

    FIELD-SYMBOLS: <fs_row>           LIKE LINE OF it_row_marked,
                   <fs_outtab_line>   LIKE LINE OF it_caselist,
                   <fs_emma_ccat_sop> LIKE LINE OF lt_emma_ccat_sop.

    CASE iv_ucomm.
      WHEN '+EF1'.
        ls_case_stat-sign = 'I'.
        ls_case_stat-option = 'BT'.
        ls_case_stat-low = '1'.
        ls_case_stat-high = '2'.
        APPEND ls_case_stat TO lt_case_stat.

        ls_cases-sign = 'I'.
        ls_cases-option = 'EQ'.

        LOOP AT it_row_marked ASSIGNING <fs_row>.
          READ TABLE it_caselist ASSIGNING <fs_outtab_line> INDEX <fs_row>-index.

          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.

          ls_cases-low = <fs_outtab_line>-casenr.
          APPEND ls_cases TO lt_cases.

          SELECT * FROM emmac_ccat_sop INTO TABLE lt_emma_ccat_sop WHERE ccat = <fs_outtab_line>-ccat.

          IF sy-subrc = 0.
            LOOP AT lt_emma_ccat_sop ASSIGNING <fs_emma_ccat_sop>.
              CALL FUNCTION 'SWO_TEXT_VERB'
                EXPORTING
                  objtype   = <fs_emma_ccat_sop>-objtype
                  verb      = <fs_emma_ccat_sop>-method
                IMPORTING
                  shorttext = lv_swc_shtext.
              ls_spopli-varoption = lv_swc_shtext.
              APPEND ls_spopli TO lt_spopli.
            ENDLOOP.
          ENDIF.
        ENDLOOP.

        SORT lt_spopli BY varoption DESCENDING.
        DELETE ADJACENT DUPLICATES FROM lt_spopli COMPARING varoption.

        CALL FUNCTION 'POPUP_TO_DECIDE_LIST'
          EXPORTING
            textline1          = 'Prozessauswahl:'
            titel              = 'Klärungsfälle Massenverarbeitung'
          TABLES
            t_spopli           = lt_spopli
          EXCEPTIONS
            not_enough_answers = 1
            too_much_answers   = 2
            too_much_marks     = 3
            OTHERS             = 4.
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.

        READ TABLE lt_spopli INTO ls_spopli WITH KEY selflag = abap_true.

        IF sy-subrc <> 0.
          EXIT.
        ENDIF.

        LOOP AT lt_emma_ccat_sop ASSIGNING <fs_emma_ccat_sop>.
          CALL FUNCTION 'SWO_TEXT_VERB'
            EXPORTING
              objtype   = <fs_emma_ccat_sop>-objtype
              verb      = <fs_emma_ccat_sop>-method
            IMPORTING
              shorttext = lv_swc_shtext.
          IF lv_swc_shtext EQ ls_spopli-varoption.
            EXIT.
          ENDIF.
        ENDLOOP.

        IF <fs_emma_ccat_sop> IS ASSIGNED.

          TRY.
              lt_emma_case = /adesso/cl_bpm_utility=>get_bpm_cases_by_param( it_casenr = lt_cases it_casestat = lt_case_stat ).
            CATCH /adesso/cx_bpm_utility.
              MESSAGE e006(emma).
          ENDTRY.

          LOOP AT lt_emma_case INTO lr_case.

            CALL METHOD lr_case->execute_process
              EXPORTING
                iv_sequnr           = <fs_emma_ccat_sop>-seqnr
              EXCEPTIONS
                process_not_found   = 1
                system_error        = 2
                invalid_case_object = 3
                case_ccat_not_found = 4
                dataflow_error      = 5
                OTHERS              = 6.
            IF sy-subrc <> 0.
              EXIT.
            ELSE.
              COMMIT WORK AND WAIT.
            ENDIF.

            ls_data = lr_case->get_data( ).

            cl_emma_case_functions=>complete_no_dialog( EXPORTING iv_casenr = ls_data-casenr
                                             EXCEPTIONS complete_failed = 1 OTHERS = 2 ).
            IF sy-subrc <> 0.
              EXIT.
            ELSE.
              cl_emma_case_functions=>confirm_no_dialog( EXPORTING iv_casenr = ls_data-casenr
                                             EXCEPTIONS confirm_failed = 1 OTHERS = 2 ).
              IF sy-subrc <> 0.
                EXIT.
              ENDIF.
            ENDIF.

          ENDLOOP.
        ENDIF.
      WHEN '+EF2'.
        "Bisher nicht implementiert
      WHEN '+EF3'.
        "Bisher nicht implementiert
      WHEN OTHERS.

    ENDCASE.

  ENDMETHOD.


  METHOD if_badi_emma_case_work_list~exclude_fcodes.

  ENDMETHOD.


  method IF_BADI_EMMA_CASE_WORK_LIST~FILL_CASELIST_CUSTOMER_FIELDS.
  endmethod.
ENDCLASS.
