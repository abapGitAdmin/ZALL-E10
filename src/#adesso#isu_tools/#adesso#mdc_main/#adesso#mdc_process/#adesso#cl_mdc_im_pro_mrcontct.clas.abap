class /ADESSO/CL_MDC_IM_PRO_MRCONTCT definition
  public
  create public .

public section.

  interfaces /ADESSO/IF_MDC_PRO_CHG .
  interfaces IF_BADI_INTERFACE .
protected section.

  class-data GR_PREVIOUS type ref to CX_ROOT .
  class-data GV_MTEXT type STRING .

  methods SET_PARTNER_DATA
    importing
      !IS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
      !IS_PROC_STEP_DATA_SRC type /IDXGC/S_PROC_STEP_DATA_ALL
    changing
      !CS_OBJ type ISU01_PARTNER
      !CS_AUTO type ISU01_PARTNER_AUTO
    raising
      /IDXGC/CX_UTILITY_ERROR .
private section.
ENDCLASS.



CLASS /ADESSO/CL_MDC_IM_PRO_MRCONTCT IMPLEMENTATION.


  METHOD /adesso/if_mdc_pro_chg~change_auto.
    DATA: gr_previous         TYPE REF TO cx_root,
          lr_utility          TYPE REF TO /idxgc/cl_utility_generic,
          lt_sel_process_id   TYPE isu_ranges_tab,
          lt_sel_process_date TYPE isu_ranges_tab,
          lt_sel_int_ui       TYPE isu_ranges_tab,
          lt_sel_create_date  TYPE isu_ranges_tab,
          lt_pdoc_data        TYPE /idxgc/t_pdoc_data,
          lt_proc_ref         TYPE TABLE OF /idxgc/de_proc_ref,
          ls_mrcontact        TYPE /idxgc/mrcontact,
          ls_obj              TYPE isu01_partner,
          ls_auto             TYPE isu01_partner_auto,
          ls_cust_in          TYPE /adesso/mdc_s_in,
          ls_name_address     TYPE /idxgc/s_nameaddr_details,
          lv_bu_partner       TYPE partner,
          lv_contact_bp       TYPE /idxgc/de_contact_bp,
          lv_type             TYPE bu_type,
          lv_valdt            TYPE bu_valdt_di,
          lv_update           TYPE e_update,
          lv_subrc            TYPE syst_subrc,
          lv_keydate          TYPE /idxgc/de_keydate,
          lv_flag_change_bp   TYPE flag,
          lv_flag_create_bp   TYPE flag.

    FIELD-SYMBOLS: <fs_isu_range>        TYPE isu_ranges,
                   <fs_pdoc_data>        TYPE /idxgc/s_pdoc_data,
                   <fs_msg_data>         TYPE /idxgc/s_msg_data_all,
                   <fs_mtd_code_result>  TYPE /idxgc/s_mtd_code_details,
                   <fs_name_address_ud>  TYPE /idxgc/s_nameaddr_details,
                   <fs_name_address_z04> TYPE /idxgc/s_nameaddr_details,
                   <fs_name_address_z05> TYPE /idxgc/s_nameaddr_details.

***** Korrespondierende Nachrichten suchen ********************************************************
    TRY.
        ls_cust_in = /adesso/cl_mdc_customizing=>get_inbound_config_for_edifact(
          iv_edifact_structur = /adesso/if_mdc_co=>gc_edifact_nad_z05 iv_assoc_servprov = is_proc_step_data-assoc_servprov ).
      CATCH /idxgc/cx_general INTO gr_previous.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.
    IF ls_cust_in-auto_change_delay IS NOT INITIAL.
      APPEND INITIAL LINE TO lt_sel_process_id ASSIGNING <fs_isu_range>.
      <fs_isu_range>-sign   = /idxgc/if_constants=>gc_sel_sign_include.
      <fs_isu_range>-option = /idxgc/if_constants=>gc_sel_opt_between.
      <fs_isu_range>-low    = /adesso/if_mdc_co=>gc_proc_id_rec_mdc_res.
      <fs_isu_range>-high   = /adesso/if_mdc_co=>gc_proc_id_rec_mdc_fwd.

      APPEND INITIAL LINE TO lt_sel_process_date ASSIGNING <fs_isu_range>.
      <fs_isu_range>-sign   = /idxgc/if_constants=>gc_sel_sign_include.
      <fs_isu_range>-option = /idxgc/if_constants=>gc_sel_opt_equal.
      <fs_isu_range>-low    = is_proc_step_data-proc_date.

      APPEND INITIAL LINE TO lt_sel_int_ui ASSIGNING <fs_isu_range>.
      <fs_isu_range>-sign   = /idxgc/if_constants=>gc_sel_sign_include.
      <fs_isu_range>-option = /idxgc/if_constants=>gc_sel_opt_equal.
      <fs_isu_range>-low    = is_proc_step_data-int_ui.

      APPEND INITIAL LINE TO lt_sel_create_date ASSIGNING <fs_isu_range>.
      <fs_isu_range>-sign   = /idxgc/if_constants=>gc_sel_sign_include.
      <fs_isu_range>-option = /idxgc/if_constants=>gc_sel_opt_between.
      <fs_isu_range>-low    = is_proc_step_data-msg_date - 1.
      <fs_isu_range>-high   = is_proc_step_data-msg_date + 1.

      TRY.
          /idxgc/cl_process_document_db=>/idxgc/if_process_document_db~select_pdoc_mass(
            EXPORTING it_sel_process_id = lt_sel_process_id it_sel_process_date = lt_sel_process_date
              it_sel_int_ui = lt_sel_int_ui it_sel_create_date = lt_sel_create_date
            IMPORTING et_pdoc_data = lt_pdoc_data ).
        CATCH /idxgc/cx_process_error INTO gr_previous.
          /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
      ENDTRY.

      LOOP AT lt_pdoc_data ASSIGNING <fs_pdoc_data> WHERE switchnum <> is_proc_step_data-proc_ref.
        LOOP AT <fs_pdoc_data>-msg_data ASSIGNING <fs_msg_data>.
          LOOP AT <fs_msg_data>-name_address TRANSPORTING NO FIELDS
            WHERE party_func_qual = /adesso/if_mdc_co=>gc_edifact_nad_ud_c080
               OR party_func_qual = /adesso/if_mdc_co=>gc_edifact_nad_z04_c059ff.
            APPEND <fs_msg_data>-proc_ref TO lt_proc_ref.
            EXIT.
          ENDLOOP.
        ENDLOOP.
      ENDLOOP.

      SORT lt_proc_ref.
      DELETE ADJACENT DUPLICATES FROM lt_proc_ref.
    ENDIF.

    "Name und Adresse zur Ablesekarte lesen
    TRY.
        ASSIGN is_proc_step_data-name_address[ party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_z05 ] TO <fs_name_address_z05>.
      CATCH cx_sy_itab_line_not_found.
        RETURN. "Keine automatische Verbuchung
    ENDTRY.

    "MRCONTACT Tabelle lesen
    TRY.
        ls_mrcontact = /adesso/cl_mdc_mrcontact=>db_select_mrcontact( iv_int_ui = is_proc_step_data-int_ui iv_keydate = is_proc_step_data-proc_date ).
      CATCH /idxgc/cx_general INTO gr_previous.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.

***** Keine korrespondierende Nachricht gefunden **************************************************
    IF lines( lt_proc_ref ) = 0.
      lr_utility = /idxgc/cl_utility_generic=>get_instance( ).

      CALL METHOD lr_utility->get_partner_name_addr_data
        EXPORTING
          iv_bu_partner     = is_proc_step_data-bu_partner
          iv_key_date       = is_proc_step_data-proc_date
        IMPORTING
          es_name_addr_data = ls_name_address.

*---- Name und Adresse identisch zum aktuellen GP -------------------------------------------------
      IF ls_name_address-name_format_code = <fs_name_address_z05>-name_format_code AND
         ls_name_address-fam_comp_name1   = <fs_name_address_z05>-fam_comp_name1   AND
         ls_name_address-fam_comp_name2   = <fs_name_address_z05>-fam_comp_name2   AND
         ls_name_address-first_name       = <fs_name_address_z05>-first_name       AND
         ls_name_address-name_add1        = <fs_name_address_z05>-name_add1        AND
         ls_name_address-name_add2        = <fs_name_address_z05>-name_add2        AND
         ls_name_address-ad_title_ext     = <fs_name_address_z05>-ad_title_ext     AND
         ls_name_address-streetname       = <fs_name_address_z05>-streetname       AND
         ls_name_address-houseid_compl    = <fs_name_address_z05>-houseid_compl    AND
         ls_name_address-poboxid          = <fs_name_address_z05>-poboxid          AND
         ls_name_address-postalcode       = <fs_name_address_z05>-postalcode       AND
         ls_name_address-district         = <fs_name_address_z05>-district         AND
         ls_name_address-cityname         = <fs_name_address_z05>-cityname         AND
         ls_name_address-countrycode      = <fs_name_address_z05>-countrycode.

        IF ls_mrcontact IS NOT INITIAL.
          lv_keydate = is_proc_step_data-proc_date - 1.
          TRY.
              /adesso/cl_mdc_mrcontact=>stop_mrcontact( iv_int_ui = is_proc_step_data-int_ui iv_keydate = lv_keydate ).
            CATCH /idxgc/cx_general INTO gr_previous.
              /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
          ENDTRY.
        ENDIF.

        RETURN. "Keine weiteren Aktionen nötig, da keine Unterschiede zum aktuellen GP.

*---- Name und/oder Adresse unterschiedlich zu aktuellem GP ---------------------------------------
      ELSE.
        IF ls_mrcontact IS NOT INITIAL.
          lv_contact_bp = ls_mrcontact-contact_bp.
          lv_flag_change_bp = abap_true.
        ELSE.
          lv_flag_create_bp = abap_true.
        ENDIF.
      ENDIF.

***** Genau eine korrespondierende Nachricht gefunden *********************************************
    ELSEIF lines( lt_proc_ref ) = 1.
      TRY.
          LOOP AT lt_pdoc_data ASSIGNING <fs_pdoc_data> WHERE switchnum = lt_proc_ref[ 1 ].
            SORT <fs_pdoc_data>-msg_data BY proc_step_no.
            ASSIGN <fs_pdoc_data>-msg_data[ 1 ]-name_address[ party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_z04 ] TO <fs_name_address_z04>.
            ASSIGN <fs_pdoc_data>-msg_data[ 1 ]-name_address[ party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_ud ] TO <fs_name_address_ud>.
          ENDLOOP.
        CATCH cx_sy_itab_line_not_found.
          RETURN. "Keine automatische Verbuchung
      ENDTRY.

*---- Name und Adresse identisch zum GP in korrespondierender Nachricht ---------------------------
      IF <fs_name_address_ud>-name_format_code = <fs_name_address_z05>-name_format_code AND
         <fs_name_address_ud>-fam_comp_name1   = <fs_name_address_z05>-fam_comp_name1   AND
         <fs_name_address_ud>-fam_comp_name2   = <fs_name_address_z05>-fam_comp_name2   AND
         <fs_name_address_ud>-first_name       = <fs_name_address_z05>-first_name       AND
         <fs_name_address_ud>-name_add1        = <fs_name_address_z05>-name_add1        AND
         <fs_name_address_ud>-name_add2        = <fs_name_address_z05>-name_add2        AND
         <fs_name_address_ud>-ad_title_ext     = <fs_name_address_z05>-ad_title_ext     AND
         <fs_name_address_z04>-streetname      = <fs_name_address_z05>-streetname       AND
         <fs_name_address_z04>-houseid_compl   = <fs_name_address_z05>-houseid_compl    AND
         <fs_name_address_z04>-poboxid         = <fs_name_address_z05>-poboxid          AND
         <fs_name_address_z04>-postalcode      = <fs_name_address_z05>-postalcode       AND
         <fs_name_address_z04>-district        = <fs_name_address_z05>-district         AND
         <fs_name_address_z04>-cityname        = <fs_name_address_z05>-cityname         AND
         <fs_name_address_z04>-countrycode     = <fs_name_address_z05>-countrycode.

        IF ls_mrcontact IS NOT INITIAL.
          lv_keydate = is_proc_step_data-proc_date - 1.
          TRY.
              /adesso/cl_mdc_mrcontact=>stop_mrcontact( iv_int_ui = is_proc_step_data-int_ui iv_keydate = lv_keydate ).
            CATCH /idxgc/cx_general INTO gr_previous.
              /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
          ENDTRY.
        ENDIF.

        RETURN. "Keine weiteren Aktionen nötig. Aktuell GP wird mit korrespondierender Nachricht geändert.

*---- Name und/oder Adresse unterschiedlich zum GP in korrespondierender Nachricht ---------------------------
      ELSE.
        IF ls_mrcontact IS NOT INITIAL.
          lv_contact_bp = ls_mrcontact-contact_bp.
          lv_flag_change_bp = abap_true.
        ELSE.
          lv_flag_create_bp = abap_true.
        ENDIF.
      ENDIF.

***** Mehrere korrespondierende Nachrichten gefunden **********************************************
    ELSE.
      RETURN. "Keine automatische Verbuchung
    ENDIF.


***** Partner anlegen *****************************************************************************
    IF lv_flag_create_bp = abap_true.
      TRY.
          lv_contact_bp = /adesso/cl_mdc_utility=>create_partner_from_pdoc_data( is_name_address = <fs_name_address_z05> ).
        CATCH /idxgc/cx_general INTO gr_previous.
          /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
      ENDTRY.

      TRY.
          /adesso/cl_mdc_mrcontact=>create_mrcontact( iv_int_ui = is_proc_step_data-int_ui
            iv_fromdate = is_proc_step_data-proc_date iv_todate = '99991231' iv_contact_bp = lv_contact_bp ).
        CATCH /idxgc/cx_general INTO gr_previous.
         /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
      ENDTRY.

***** Partner ändern: Daten für automatische Verbuchung ermitteln *********************************
    ELSEIF lv_flag_change_bp = abap_true.
      lv_valdt = is_proc_step_data-proc_date.
      CALL FUNCTION 'ISU_S_PARTNER_PROVIDE'
        EXPORTING
          x_partner                 = lv_contact_bp
          x_valdt                   = lv_valdt
          x_wmode                   = /idxgc/cl_pod_rel_access=>gc_change
          x_no_dialog               = abap_true
        IMPORTING
          y_obj                     = ls_obj
          y_auto                    = ls_auto
          y_type                    = lv_type
        EXCEPTIONS
          not_found                 = 1
          partner_in_role_not_found = 2
          foreign_lock              = 3
          not_authorized            = 4
          invalid_wmode             = 5
          different_type            = 6
          general_fault             = 7
          OTHERS                    = 8.
      IF sy-subrc <> 0.
        MESSAGE e011(/adesso/mdc_process) INTO gv_mtext.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ).
      ENDIF.

      CALL FUNCTION 'ISU_O_PARTNER_CLOSE'
        CHANGING
          xy_obj = ls_obj.

      me->set_partner_data( EXPORTING is_proc_step_data = is_proc_step_data is_proc_step_data_src = is_proc_step_data_src CHANGING cs_obj = ls_obj cs_auto = ls_auto ).

***** Partner ändern: Automatische Verbuchung durchführen *****************************************
      /adesso/cl_mdc_datex_utility=>disable_datex( iv_int_ui = is_proc_step_data-int_ui ).

      DO 5 TIMES.
        CALL FUNCTION 'ISU_S_PARTNER_CHANGE'
          EXPORTING
            x_partner      = is_proc_step_data-bu_partner
            x_valdt        = lv_valdt
            x_upd_online   = abap_true
            x_no_dialog    = abap_true
            x_auto         = ls_auto
            x_obj          = ls_obj
          IMPORTING
            y_db_update    = lv_update
          EXCEPTIONS
            not_found      = 1
            foreign_lock   = 2
            not_authorized = 3
            cancelled      = 4
            input_error    = 5
            general_fault  = 6
            OTHERS         = 7.
        IF sy-subrc = 0.
          EXIT.
        ELSEIF sy-subrc = 2.
          "Bei Sperre max. 5 Sekunden warten und nochmal probieren.
          WAIT UP TO 1 SECONDS.
        ELSEIF sy-subrc <> 0.
          /adesso/cl_mdc_datex_utility=>enable_datex( iv_int_ui = is_proc_step_data-int_ui ).
          MESSAGE e012(/adesso/mdc_process) INTO gv_mtext.
          /idxgc/cx_utility_error=>raise_util_exception_from_msg( ).
        ENDIF.
      ENDDO.

      /adesso/cl_mdc_datex_utility=>enable_datex( iv_int_ui = is_proc_step_data-int_ui ).
    ENDIF.

  ENDMETHOD.


  METHOD /adesso/if_mdc_pro_chg~change_manual.
    DATA: ls_proc_step_data TYPE /idxgc/s_proc_step_data_all,
          ls_mrcontact      TYPE /idxgc/mrcontact.

    TRY.
        ls_mrcontact = /adesso/cl_mdc_mrcontact=>db_select_mrcontact( iv_int_ui = is_proc_step_data-int_ui iv_keydate = is_proc_step_data-proc_date ).
      CATCH /idxgc/cx_general INTO gr_previous.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.
    IF ls_mrcontact IS NOT INITIAL.
      ls_proc_step_data-bu_partner = ls_mrcontact-contact_bp.
    ENDIF.

    CALL FUNCTION '/ADESSO/MDC_CHANGE_PARTNER' STARTING NEW TASK 'MDC_CHANGE_PARTNER'
      EXPORTING
        is_proc_step_data = ls_proc_step_data.

  ENDMETHOD.


  METHOD set_partner_data.
    DATA: ls_bus020_ext TYPE bus020_ext,
          lv_valdt      TYPE bu_valdt_di.

    FIELD-SYMBOLS: <fs_name_address>    TYPE /idxgc/s_nameaddr_details,
                   <fs_mtd_code_result> TYPE /idxgc/s_mtd_code_details,
                   <fs_bus020_ext>      TYPE bus020_ext.

***** Geschäftspartnername ************************************************************************
    READ TABLE is_proc_step_data-name_address ASSIGNING <fs_name_address> WITH KEY party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_Z05.
    IF sy-subrc = 0.
      IF ( <fs_name_address>-name_format_code = /idxgc/if_constants_ide=>gc_name_format_code_person  AND
           cs_auto-act-type = /idxgc/if_constants_add=>gc_bu_type_per ) OR
         ( <fs_name_address>-name_format_code = /idxgc/if_constants_ide=>gc_name_format_code_company AND
         ( cs_auto-act-type = /idxgc/if_constants_add=>gc_bu_type_org OR cs_auto-act-type = /idxgc/if_constants_add=>gc_bu_type_grp ) ).

        LOOP AT is_proc_step_data-mtd_code_result ASSIGNING <fs_mtd_code_result>
          WHERE compname = /adesso/if_mdc_co=>gc_compname_name_address AND ref_id = /idxgc/if_constants_ide=>gc_nad_qual_z05.
          CASE cs_auto-act-type.
            WHEN /idxgc/if_constants_add=>gc_bu_type_per. "Person
              CASE <fs_mtd_code_result>-fieldname.
                WHEN /adesso/if_mdc_co=>gc_fieldname_first_name.
                  cs_auto-act-name_first = <fs_name_address>-first_name.
                  cs_auto-ekund_use = abap_true.
                WHEN /adesso/if_mdc_co=>gc_fieldname_fam_comp_name1.
                  cs_auto-act-name_last =  <fs_name_address>-fam_comp_name1.
                  cs_auto-ekund_use = abap_true.
*            WHEN 'AD_TITLE_EXT'.
*              cs_auto-act-title_aca1 = <fs_name_address>-ad_title_ext.
*              cs_auto-ekund_use = abap_true.
              ENDCASE.
            WHEN /idxgc/if_constants_add=>gc_bu_type_org. " Organisation
              CASE <fs_mtd_code_result>-fieldname.
                WHEN /adesso/if_mdc_co=>gc_fieldname_fam_comp_name1.
                  cs_auto-act-name_org1 =  <fs_name_address>-fam_comp_name1.
                  cs_auto-ekund_use = abap_true.
                WHEN /adesso/if_mdc_co=>gc_fieldname_fam_comp_name2.
                  cs_auto-act-name_org2 =  <fs_name_address>-fam_comp_name2.
                  cs_auto-ekund_use = abap_true.
*            WHEN 'AD_TITLE_EXT'.
*              cs_auto-act-title_aca1 = <fs_name_address>-ad_title_ext.
*              cs_auto-ekund_use = abap_true.
              ENDCASE.
            WHEN /idxgc/if_constants_add=>gc_bu_type_grp. " Gruppe
              CASE <fs_mtd_code_result>-fieldname.
                WHEN /adesso/if_mdc_co=>gc_fieldname_fam_comp_name1.
                  cs_auto-act-name_grp1 =  <fs_name_address>-fam_comp_name1.
                  cs_auto-ekund_use = abap_true.
                WHEN /adesso/if_mdc_co=>gc_fieldname_fam_comp_name2.
                  cs_auto-act-name_grp2 =  <fs_name_address>-fam_comp_name2.
                  cs_auto-ekund_use = abap_true.
              ENDCASE.
          ENDCASE.
        ENDLOOP.

      ENDIF.

***** Geschäftspartneradresse **************************************************
      lv_valdt = is_proc_step_data-proc_date.
      CALL FUNCTION 'ISU_PARTNER_READ_DEF_ADDRESS'
        EXPORTING
          x_valdt        = lv_valdt
          x_partner_data = cs_obj-db
        IMPORTING
          e_address      = ls_bus020_ext.

      READ TABLE cs_auto-t_address ASSIGNING <fs_bus020_ext> WITH KEY addrnumber = ls_bus020_ext-addrnumber.
      IF sy-subrc = 0.
        LOOP AT is_proc_step_data-mtd_code_result ASSIGNING <fs_mtd_code_result>
          WHERE compname = /adesso/if_mdc_co=>gc_compname_name_address AND ref_id = /idxgc/if_constants_ide=>gc_nad_qual_z05.
          CASE <fs_mtd_code_result>-fieldname.
            WHEN /adesso/if_mdc_co=>gc_fieldname_poboxid.
              <fs_bus020_ext>-po_box     = <fs_name_address>-poboxid.
              cs_auto-t_address_use      = abap_true.
            WHEN /adesso/if_mdc_co=>gc_fieldname_postalcode.
              "PLZ wird unten übernommen.
              cs_auto-t_address_use      = abap_true.
            WHEN /adesso/if_mdc_co=>gc_fieldname_cityname.
              <fs_bus020_ext>-city1      = <fs_name_address>-cityname.
              cs_auto-t_address_use      = abap_true.
            WHEN /adesso/if_mdc_co=>gc_fieldname_district.
              <fs_bus020_ext>-city2      = <fs_name_address>-district.
              cs_auto-t_address_use      = abap_true.
            WHEN /adesso/if_mdc_co=>gc_fieldname_streetname.
              <fs_bus020_ext>-street     = <fs_name_address>-streetname.
              cs_auto-t_address_use      = abap_true.
            WHEN /adesso/if_mdc_co=>gc_fieldname_houseid_compl.
              TRY.
                  /adesso/cl_mdc_utility=>split_houseid_compl( EXPORTING iv_houseid_compl = <fs_name_address>-houseid_compl
                    IMPORTING ev_houseid = <fs_bus020_ext>-house_num1 ev_houseid_add = <fs_bus020_ext>-house_num2 ).
                CATCH /idxgc/cx_general.
              ENDTRY.
              cs_auto-t_address_use      = abap_true.
            WHEN /adesso/if_mdc_co=>gc_fieldname_countrycode.
              <fs_bus020_ext>-country    = <fs_name_address>-countrycode.
              cs_auto-t_address_use      = abap_true.
          ENDCASE.
        ENDLOOP.
        "PLZ kann identisch bleiben, muss aber ggf. in ein anderes Feld geschrieben werden
        IF cs_auto-t_address_use = abap_true.
          IF <fs_name_address>-poboxid IS INITIAL.
            <fs_bus020_ext>-post_code1 = <fs_name_address>-postalcode.
            CLEAR <fs_bus020_ext>-post_code2.
          ELSE.
            CLEAR <fs_bus020_ext>-post_code1.
            <fs_bus020_ext>-post_code2 = <fs_name_address>-postalcode.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
