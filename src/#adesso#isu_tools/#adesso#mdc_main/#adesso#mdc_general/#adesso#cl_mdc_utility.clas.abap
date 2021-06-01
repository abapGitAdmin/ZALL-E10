class /ADESSO/CL_MDC_UTILITY definition
  public
  final
  create public .

public section.

  class-data GV_MTEXT type STRING .

  class-methods COMPARE_PROC_STEP_DATA
    importing
      !IS_PROC_STEP_DATA_1 type /IDXGC/S_PROC_STEP_DATA
      !IS_PROC_STEP_DATA_2 type /IDXGC/S_PROC_STEP_DATA
      !IT_MTD_CODE_RESULT_SELECT type /IDXGC/T_MTD_CODE_DETAILS optional
    returning
      value(RT_MTD_CODE_RESULT) type /IDXGC/T_MTD_CODE_DETAILS
    raising
      /IDXGC/CX_GENERAL.
  class-methods CREATE_PARTNER_FROM_PDOC_DATA
    importing
      !IS_NAME_ADDRESS type /IDXGC/S_NAMEADDR_DETAILS
    returning
      value(RV_BU_PARTNER) type BU_PARTNER
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_CHANGES_AS_EDIFACT_STR
    importing
      !IS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA
    returning
      value(RT_EDIFACT_STRUCTUR) type /ADESSO/MDC_T_EDIFACT_STR
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_INTCODE_SERVPROV
    importing
      !IV_SERVICEID type SERVICEID
    returning
      value(RV_INTCODE) type /ADESSO/MDC_INTCODE
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_SERVPROVS_FOR_POD
    importing
      !IV_INT_UI type INT_UI
      !IV_KEYDATE type /IDXGC/DE_KEYDATE
    returning
      value(RT_SERVPROV_DETAILS) type /IDXGC/T_SERVPROV_DETAILS
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_START_AMID
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IV_SENDER_INTCODE type /ADESSO/MDC_INTCODE
      !IV_RECEIVER_INTCODE type /ADESSO/MDC_INTCODE optional
    returning
      value(RV_AMID) type /IDXGC/DE_AMID
    raising
      /IDXGC/CX_GENERAL .
  class-methods IS_FIELD_SET
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_FLAG_IS_SET) type /IDXGC/DE_BOOLEAN_FLAG
    raising
      /IDXGC/CX_GENERAL .
  class-methods SPLIT_HOUSEID_COMPL
    importing
      !IV_HOUSEID_COMPL type /IDXGC/DE_HOUSEID_COMPL
    exporting
      value(EV_HOUSEID) type AD_HSNM1
      value(EV_HOUSEID_ADD) type AD_HSNM2
    raising
      /IDXGC/CX_GENERAL .
  PROTECTED SECTION.
private section.

  class-methods COMPARE_DATA_SET
    importing
      !IS_PROC_STEP_DATA_1 type /IDXGC/S_PROC_STEP_DATA
      !IS_PROC_STEP_DATA_2 type /IDXGC/S_PROC_STEP_DATA
      !IT_CUST_PDOC_TO_PROCESS type /ADESSO/MDC_T_PDOC
      !IV_FLAG_ONLY_DIFFERENCES type /IDXGC/DE_BOOLEAN_FLAG default 'X'
    returning
      value(RT_MTD_CODE_RESULT) type /IDXGC/T_MTD_CODE_DETAILS
    raising
      /IDXGC/CX_GENERAL .
ENDCLASS.



CLASS /ADESSO/CL_MDC_UTILITY IMPLEMENTATION.


  METHOD compare_data_set.
***************************************************************************************************
* THIMEL-R, 20150726, SDÄ auf Common Layer Engine
*    Hilsmethode: Vergleich für eine Tabelle
***************************************************************************************************
    DATA: lt_cust_pqal TYPE /adesso/mdc_t_pqal,
          lr_previous  TYPE REF TO cx_root.

    FIELD-SYMBOLS: <fs_cust_pdoc_to_process> TYPE /adesso/mdc_s_pdoc,
                   <fs_cust_pqal>            TYPE /adesso/mdc_s_pqal,
                   <ft_table_1>              TYPE INDEX TABLE,
                   <ft_table_2>              TYPE INDEX TABLE,
                   <fs_row_1>                TYPE any,
                   <fs_row_2>                TYPE any,
                   <fv_field_1>              TYPE any,
                   <fv_field_2>              TYPE any,
                   <fs_qual_field>           TYPE any,
                   <fs_mtd_code_result>      TYPE /idxgc/s_mtd_code_details.

    lt_cust_pqal = /adesso/cl_mdc_customizing=>get_pdoc_pqal_mapping( ).

    READ TABLE it_cust_pdoc_to_process ASSIGNING <fs_cust_pdoc_to_process> INDEX 1.
    IF sy-subrc = 0.
*---- Zuweisung Daten aus erster Quelle -----------------------------------------------------------
      IF <fs_cust_pdoc_to_process>-pdoc_step_table IS NOT INITIAL.
        ASSIGN COMPONENT <fs_cust_pdoc_to_process>-pdoc_step_table OF STRUCTURE is_proc_step_data_1 TO <ft_table_1>.
        IF sy-subrc = 0.
          IF <fs_cust_pdoc_to_process>-pdoc_step_qualifier IS INITIAL.
            READ TABLE <ft_table_1> ASSIGNING <fs_row_1> INDEX 1.
          ELSE.
            READ TABLE lt_cust_pqal ASSIGNING <fs_cust_pqal> WITH KEY pdoc_step_table = <fs_cust_pdoc_to_process>-pdoc_step_table.
            IF sy-subrc = 0.
              UNASSIGN <fs_qual_field>.
              LOOP AT <ft_table_1> ASSIGNING <fs_row_1>.
                ASSIGN COMPONENT <fs_cust_pqal>-pdoc_step_table_qual_field OF STRUCTURE <fs_row_1> TO <fs_qual_field>.
                IF <fs_qual_field> = <fs_cust_pdoc_to_process>-pdoc_step_qualifier.
                  EXIT.
                ENDIF.
              ENDLOOP.
              IF <fs_qual_field> IS ASSIGNED AND <fs_qual_field> <> <fs_cust_pdoc_to_process>-pdoc_step_qualifier.
                UNASSIGN <fs_row_1>.
              ENDIF.
            ELSE.
              MESSAGE e058(/idxgc/utility) INTO gv_mtext WITH <fs_cust_pqal>-pdoc_step_table_qual_field <fs_cust_pdoc_to_process>-pdoc_step_table.
              /idxgc/cx_general=>raise_exception_from_msg( ).
            ENDIF.
          ENDIF.
        ELSE.
          "Fehlermeldung
        ENDIF.
      ENDIF.

*---- Zuweisung Daten aus zweiter Quelle ----------------------------------------------------------
      IF <fs_cust_pdoc_to_process>-pdoc_step_table IS NOT INITIAL.
        ASSIGN COMPONENT <fs_cust_pdoc_to_process>-pdoc_step_table OF STRUCTURE is_proc_step_data_2 TO <ft_table_2>.
        IF sy-subrc = 0.
          IF <fs_cust_pdoc_to_process>-pdoc_step_qualifier IS INITIAL.
            READ TABLE <ft_table_2> ASSIGNING <fs_row_2> INDEX 1.
          ELSE.
            READ TABLE lt_cust_pqal ASSIGNING <fs_cust_pqal> WITH KEY pdoc_step_table = <fs_cust_pdoc_to_process>-pdoc_step_table.
            IF sy-subrc = 0.
              UNASSIGN <fs_qual_field>.
              LOOP AT <ft_table_2> ASSIGNING <fs_row_2>.
                ASSIGN COMPONENT <fs_cust_pqal>-pdoc_step_table_qual_field OF STRUCTURE <fs_row_2> TO <fs_qual_field>.
                IF <fs_qual_field> = <fs_cust_pdoc_to_process>-pdoc_step_qualifier.
                  EXIT.
                ENDIF.
              ENDLOOP.
              IF <fs_qual_field> IS ASSIGNED AND <fs_qual_field> <> <fs_cust_pdoc_to_process>-pdoc_step_qualifier.
                UNASSIGN <fs_row_2>.
              ENDIF.
            ELSE.
              MESSAGE e058(/idxgc/utility) INTO gv_mtext WITH <fs_cust_pqal>-pdoc_step_table_qual_field <fs_cust_pdoc_to_process>-pdoc_step_table.
              /idxgc/cx_general=>raise_exception_from_msg( ).
            ENDIF.
          ENDIF.
        ELSE.
          "Fehlermeldung
        ENDIF.
      ENDIF.

*---- Vergleich ------------------------------------------------------------------------------------
***** Tabellen vergleichen ************************************************************************
      IF <fs_row_1> IS ASSIGNED OR <fs_row_2> IS ASSIGNED.
        LOOP AT it_cust_pdoc_to_process ASSIGNING <fs_cust_pdoc_to_process>.
          UNASSIGN: <fv_field_1>, <fv_field_2>.

          IF <fs_row_1> IS ASSIGNED AND <fs_row_2> IS NOT ASSIGNED.
            ASSIGN COMPONENT <fs_cust_pdoc_to_process>-pdoc_step_field OF STRUCTURE <fs_row_1> TO <fv_field_1>.
            IF <fv_field_1> IS NOT ASSIGNED.
              MESSAGE e058(/idxgc/utility) INTO gv_mtext WITH <fs_cust_pdoc_to_process>-pdoc_step_field <fs_cust_pdoc_to_process>-pdoc_step_table.
              /idxgc/cx_general=>raise_exception_from_msg( ).
            ENDIF.

            APPEND INITIAL LINE TO rt_mtd_code_result ASSIGNING <fs_mtd_code_result>.
            <fs_mtd_code_result>-compname = <fs_cust_pdoc_to_process>-pdoc_step_table.
            <fs_mtd_code_result>-fieldname = <fs_cust_pdoc_to_process>-pdoc_step_field.
            <fs_mtd_code_result>-ref_id = <fs_cust_pdoc_to_process>-pdoc_step_qualifier.
            <fs_mtd_code_result>-addinfo = <fs_cust_pdoc_to_process>-edifact_structur.
            <fs_mtd_code_result>-src_field_value = <fv_field_1>.

          ELSEIF <fs_row_1> IS NOT ASSIGNED AND <fs_row_2> IS ASSIGNED.
            ASSIGN COMPONENT <fs_cust_pdoc_to_process>-pdoc_step_field OF STRUCTURE <fs_row_2> TO <fv_field_2>.
            IF <fv_field_2> IS NOT ASSIGNED.
              MESSAGE e058(/idxgc/utility) INTO gv_mtext WITH <fs_cust_pdoc_to_process>-pdoc_step_field <fs_cust_pdoc_to_process>-pdoc_step_table.
              /idxgc/cx_general=>raise_exception_from_msg( ).
            ENDIF.

            APPEND INITIAL LINE TO rt_mtd_code_result ASSIGNING <fs_mtd_code_result>.
            <fs_mtd_code_result>-compname = <fs_cust_pdoc_to_process>-pdoc_step_table.
            <fs_mtd_code_result>-fieldname = <fs_cust_pdoc_to_process>-pdoc_step_field.
            <fs_mtd_code_result>-ref_id = <fs_cust_pdoc_to_process>-pdoc_step_qualifier.
            <fs_mtd_code_result>-addinfo = <fs_cust_pdoc_to_process>-edifact_structur.
            <fs_mtd_code_result>-cmp_field_value = <fv_field_2>.

          ELSEIF <fs_row_1> IS ASSIGNED AND <fs_row_2> IS ASSIGNED.
            ASSIGN COMPONENT <fs_cust_pdoc_to_process>-pdoc_step_field OF STRUCTURE <fs_row_1> TO <fv_field_1>.
            ASSIGN COMPONENT <fs_cust_pdoc_to_process>-pdoc_step_field OF STRUCTURE <fs_row_2> TO <fv_field_2>.
            IF <fv_field_1> IS NOT ASSIGNED OR <fv_field_2> IS NOT ASSIGNED.
              MESSAGE e058(/idxgc/utility) INTO gv_mtext WITH <fs_cust_pdoc_to_process>-pdoc_step_field <fs_cust_pdoc_to_process>-pdoc_step_table.
              /idxgc/cx_general=>raise_exception_from_msg( ).
            ENDIF.

            IF <fv_field_1> <> <fv_field_2> OR iv_flag_only_differences = abap_false.
              APPEND INITIAL LINE TO rt_mtd_code_result ASSIGNING <fs_mtd_code_result>.
              <fs_mtd_code_result>-compname = <fs_cust_pdoc_to_process>-pdoc_step_table.
              <fs_mtd_code_result>-fieldname = <fs_cust_pdoc_to_process>-pdoc_step_field.
              <fs_mtd_code_result>-ref_id = <fs_cust_pdoc_to_process>-pdoc_step_qualifier.
              <fs_mtd_code_result>-addinfo = <fs_cust_pdoc_to_process>-edifact_structur.
              <fs_mtd_code_result>-src_field_value = <fv_field_1>.
              <fs_mtd_code_result>-cmp_field_value = <fv_field_2>.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD compare_proc_step_data.
***************************************************************************************************
* THIMEL-R, 20150726, SDÄ auf Common Layer Engine
*    Vergleich von Schrittdaten und Rückgabe der Ergebnisse in der Tabelle MTD_RESULT
*    Zwei Ausführungsmöglichkeiten:
*      1) Wenn IT_MTD_CODE_RESULT_SELECT Tabelle leer: Vergleich für alle Felder; Ergebnis sind
*         alle Unterschiede. Identische Felder werden nicht zurückgegeben.
*      2) Wenn IT_MTD_CODE_RESULT_SELECT Tabelle gefüllt: Prüfung aller dort vorhandenen Einträge,
*         Ergebnis sind alle Einträge aus der Tabelle, auch bei identischen Vergleichsfeldern.
***************************************************************************************************
    DATA: lr_badi_mdc_compare_steps TYPE REF TO /adesso/badi_mdc_compare_steps,
          lt_cust_pdoc              TYPE /adesso/mdc_t_pdoc,
          lt_cust_pdoc_to_process   TYPE /adesso/mdc_t_pdoc,
          ls_cust_pdoc              TYPE /adesso/mdc_pdoc,
          lv_flag_only_differences  TYPE /idxgc/de_boolean_flag.

    FIELD-SYMBOLS: <fs_cust_pdoc>       TYPE /adesso/mdc_s_pdoc,
                   <fs_mtd_code_result> TYPE /idxgc/s_mtd_code_details.

    IF it_mtd_code_result_select IS NOT INITIAL.
      LOOP AT it_mtd_code_result_select ASSIGNING <fs_mtd_code_result>.
        APPEND INITIAL LINE TO lt_cust_pdoc ASSIGNING <fs_cust_pdoc>.
        <fs_cust_pdoc>-pdoc_step_table     = <fs_mtd_code_result>-compname.
        <fs_cust_pdoc>-pdoc_step_field     = <fs_mtd_code_result>-fieldname.
        <fs_cust_pdoc>-pdoc_step_qualifier = <fs_mtd_code_result>-ref_id.
        <fs_cust_pdoc>-edifact_structur    = <fs_mtd_code_result>-addinfo.
      ENDLOOP.
      lv_flag_only_differences = abap_false.
    ELSE.
      lt_cust_pdoc = /adesso/cl_mdc_customizing=>get_pdoc_edifact_mapping( ).
      lv_flag_only_differences = abap_true.
    ENDIF.

    SORT lt_cust_pdoc BY pdoc_step_table pdoc_step_qualifier.
    READ TABLE lt_cust_pdoc INTO ls_cust_pdoc INDEX 1.

    LOOP AT lt_cust_pdoc ASSIGNING <fs_cust_pdoc>.
      IF ls_cust_pdoc-pdoc_step_table <> <fs_cust_pdoc>-pdoc_step_table OR
         ls_cust_pdoc-pdoc_step_qualifier <> <fs_cust_pdoc>-pdoc_step_qualifier.

        APPEND LINES OF /adesso/cl_mdc_utility=>compare_data_set( is_proc_step_data_1 = is_proc_step_data_1 is_proc_step_data_2 = is_proc_step_data_2
          it_cust_pdoc_to_process = lt_cust_pdoc_to_process iv_flag_only_differences = lv_flag_only_differences ) TO rt_mtd_code_result.

        CLEAR: lt_cust_pdoc_to_process.
      ENDIF.

      ls_cust_pdoc = <fs_cust_pdoc>.
      INSERT ls_cust_pdoc INTO TABLE lt_cust_pdoc_to_process.
    ENDLOOP.

    APPEND LINES OF /adesso/cl_mdc_utility=>compare_data_set( is_proc_step_data_1 = is_proc_step_data_1 is_proc_step_data_2 = is_proc_step_data_2
      it_cust_pdoc_to_process = lt_cust_pdoc_to_process iv_flag_only_differences = lv_flag_only_differences ) TO rt_mtd_code_result.

    LOOP AT rt_mtd_code_result ASSIGNING <fs_mtd_code_result>.
      IF <fs_mtd_code_result>-src_field_value = '00000000'.
        CLEAR <fs_mtd_code_result>-src_field_value.
      ENDIF.
      IF <fs_mtd_code_result>-cmp_field_value = '00000000'.
        CLEAR <fs_mtd_code_result>-cmp_field_value.
      ENDIF.
    ENDLOOP.

***** Kundeneigene BAdI Implementierung für Vergleich *********************************************
    TRY.
        GET BADI lr_badi_mdc_compare_steps
          FILTERS
            mandt = sy-mandt
            sysid = sy-sysid.
      CATCH cx_badi_not_implemented.
        "Das BAdI muss nicht implementiert sein.
    ENDTRY.

    IF lr_badi_mdc_compare_steps IS NOT INITIAL.

      CALL BADI lr_badi_mdc_compare_steps->compare_proc_step_data
        EXPORTING
          is_proc_step_data_1 = is_proc_step_data_1
          is_proc_step_data_2 = is_proc_step_data_2
        CHANGING
          ct_mtd_code_result  = rt_mtd_code_result.

    ENDIF.
  ENDMETHOD.


  METHOD create_partner_from_pdoc_data.
    DATA:
      lt_return                  TYPE TABLE OF bapiret2,
      ls_addressdata             TYPE bapibus1006_address,
      ls_centraldata             TYPE bapibus1006_central,
      ls_centraldataperson       TYPE bapibus1006_central_person,
      ls_centraldataorganization TYPE bapibus1006_central_organ,
      lv_bu_type                 TYPE bu_type.


    DATA: lv_title_text TYPE ad_title1t,
          ls_tsad2      TYPE tsad2.

    FIELD-SYMBOLS: <but_field> TYPE any.

***** Daten in die BAPI Strukturen schreiben ******************************************************
*---- Partnertyp ----------------------------------------------------------------------------------
    CASE is_name_address-name_format_code.
      WHEN /idxgc/if_constants_ide=>gc_name_format_code_person.
        lv_bu_type = /idxgc/if_constants_add=>gc_bu_type_per.
      WHEN /idxgc/if_constants_ide=>gc_name_format_code_company.
        lv_bu_type = /idxgc/if_constants_add=>gc_bu_type_org.
    ENDCASE.

*---- Partnername ---------------------------------------------------------------------------------
    CASE lv_bu_type.
      WHEN /idxgc/if_constants_add=>gc_bu_type_per. "Person
        ls_centraldataperson-firstname = is_name_address-first_name.
        ls_centraldataperson-lastname  = is_name_address-fam_comp_name1.

      WHEN /idxgc/if_constants_add=>gc_bu_type_org. " Organisation
        ls_centraldataorganization-name1 = is_name_address-fam_comp_name1.
        ls_centraldataorganization-name2 = is_name_address-fam_comp_name2.
    ENDCASE.

    IF NOT is_name_address-ad_title_ext IS INITIAL.
      lv_title_text = is_name_address-ad_title_ext.
      SELECT SINGLE * FROM tsad2 INTO ls_tsad2
          WHERE title_key  EQ lv_title_text
             OR title_text EQ lv_title_text.
      IF sy-subrc = 0.
        ls_centraldataperson-title_aca1 = ls_tsad2-title_key.
      ENDIF.
    ENDIF.

*---- Geschäftspartneradresse ---------------------------------------------------------------------
    ls_addressdata-po_box = is_name_address-poboxid.
    ls_addressdata-city      = is_name_address-cityname.
    ls_addressdata-district = is_name_address-district.
    ls_addressdata-street = is_name_address-streetname.
    TRY.
        /adesso/cl_mdc_utility=>split_houseid_compl( EXPORTING iv_houseid_compl = is_name_address-houseid_compl
          IMPORTING ev_houseid = ls_addressdata-house_no ev_houseid_add = ls_addressdata-house_no2 ).
      CATCH /idxgc/cx_general.
        ls_addressdata-house_no = is_name_address-houseid_compl.
    ENDTRY.
    ls_addressdata-country    = is_name_address-countrycode.
    "PLZ kann identisch bleiben, muss aber ggf. in ein anderes Feld geschrieben werden
    IF is_name_address-poboxid IS INITIAL.
      ls_addressdata-postl_cod1 = is_name_address-postalcode.
      CLEAR ls_addressdata-postl_cod2.
    ELSE.
      CLEAR ls_addressdata-postl_cod1.
      ls_addressdata-postl_cod2 = is_name_address-postalcode.
    ENDIF.

***** Geschäftspartner neu anlegen ****************************************************************
    CALL FUNCTION 'BAPI_BUPA_CREATE_FROM_DATA'
      EXPORTING
        partnercategory   = lv_bu_type
        centraldata       = ls_centraldata
        centraldataperson = ls_centraldataperson
        addressdata       = ls_addressdata
      IMPORTING
        businesspartner   = rv_bu_partner
      TABLES
        return            = lt_return.

  ENDMETHOD.


  METHOD get_changes_as_edifact_str.
***************************************************************************************************
* THIMEL-R, 20150726, SDÄ auf Common Layer Engine
*    Liefert die EDIFACT-Strukturen aus der Tabelle MTD_CODE_RESULT, falls diese durch einen
*    vorherigen Vergleich gefüllt ist.
***************************************************************************************************
    FIELD-SYMBOLS: <fs_mtd_code_result> TYPE /idxgc/s_mtd_code_details.

    LOOP AT is_proc_step_data-mtd_code_result ASSIGNING <fs_mtd_code_result>.
      APPEND <fs_mtd_code_result>-addinfo TO rt_edifact_structur.
    ENDLOOP.

    SORT rt_edifact_structur.
    DELETE ADJACENT DUPLICATES FROM rt_edifact_structur.
  ENDMETHOD.


  METHOD get_intcode_servprov.
    DATA: lr_badi_mdc_intcode TYPE REF TO /adesso/badi_mdc_intcode,
          lv_service          TYPE sercode.

    SELECT SINGLE service FROM eservprov INTO lv_service WHERE serviceid = iv_serviceid.
    SELECT SINGLE intcode FROM tecde INTO rv_intcode WHERE service = lv_service.
***** 3. Kundeneigene Umsetzung in BAdI ***********************************************************
    TRY.
        GET BADI lr_badi_mdc_intcode
          FILTERS
            mandt = sy-mandt
            sysid = sy-sysid.
      CATCH cx_badi_not_implemented.
        "Das BAdI muss nicht implementiert sein.
    ENDTRY.

    IF lr_badi_mdc_intcode IS NOT INITIAL.
      CALL BADI lr_badi_mdc_intcode->get_intcode_servprov
        EXPORTING
          iv_service   = lv_service
          iv_serviceid = iv_serviceid
        CHANGING
          cv_intcode   = rv_intcode.
    ENDIF.

    IF rv_intcode IS INITIAL.
      MESSAGE e010(/adesso/mdc_general) WITH iv_serviceid INTO gv_mtext.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD get_servprovs_for_pod.
***************************************************************************************************
* THIMEL-R, 20150726, SDÄ auf Common Layer Engine
* Ermittlung aller Empfänger zu einem Zählpunkt.
***************************************************************************************************
    DATA:
      lr_badi_mdc_servprovs_pod TYPE REF TO /adesso/badi_mdc_servprovs_pod,
      lr_previous               TYPE REF TO cx_root,
      lt_servprov_details       TYPE /idxgc/t_servprov_details.
    FIELD-SYMBOLS: <fs_servprov_details> TYPE /idxgc/s_servprov_details.

***** 1. Alle Serviceanbieter zum Zählpunkt holen *************************************************
    TRY.
        /idxgc/cl_utility_isu_add=>get_servprov_onpod(
          EXPORTING iv_int_ui = iv_int_ui iv_keydate = iv_keydate
          IMPORTING et_servprov_details = lt_servprov_details ).
      CATCH /idxgc/cx_utility_error INTO lr_previous.
        /idxgc/cx_general=>raise_exception_from_msg( ir_previous = lr_previous ).
    ENDTRY.

***** 2. Bilanzkreiskoordinator löschen ***********************************************************
    LOOP AT lt_servprov_details ASSIGNING <fs_servprov_details> WHERE service_cat = /adesso/if_mdc_co=>gc_intcode_04.
      DELETE lt_servprov_details.
    ENDLOOP.
    SORT lt_servprov_details BY date_from.

***** 3. Kundeneigene Umsetzung in BAdI ***********************************************************
    TRY.
        GET BADI lr_badi_mdc_servprovs_pod
          FILTERS
            mandt = sy-mandt
            sysid = sy-sysid.
      CATCH cx_badi_not_implemented.
        "Das BAdI muss nicht implementiert sein.
    ENDTRY.

    IF lr_badi_mdc_servprovs_pod IS NOT INITIAL.
      CALL BADI lr_badi_mdc_servprovs_pod->get_servprovs_for_pod
        EXPORTING
          iv_int_ui           = iv_int_ui
          iv_keydate          = iv_keydate
        CHANGING
          ct_servprov_details = lt_servprov_details.
    ENDIF.

    rt_servprov_details = lt_servprov_details.

  ENDMETHOD.


  METHOD get_start_amid.
***************************************************************************************************
* THIMEL-R, 20150726, SDÄ auf Common Layer Engine
*    Ermittlung der Start-AMID. Besonderheit: Im Netz wird auch ohne Empfänger eine AMID zurück-
*    gegeben. Ggf. ist diese nicht eindeutig, ermöglicht aber eine Gruppierung.
***************************************************************************************************
    DATA: ls_cust_raid TYPE /adesso/mdc_raid.

    ls_cust_raid = /adesso/cl_mdc_customizing=>get_roles_amids( iv_edifact_structur = iv_edifact_structur ).

    IF iv_sender_intcode = /idxgc/if_constants=>gc_service_code_dso.
      IF iv_receiver_intcode = /idxgc/if_constants=>gc_service_code_supplier.
        rv_amid = ls_cust_raid-distributor_amid_supplier.
      ELSEIF iv_receiver_intcode = /adesso/if_mdc_co=>gc_intcode_m1.
        rv_amid = ls_cust_raid-distributor_amid_mos.
      ELSE. "Ohne Empfänger: 1) Lieferant, 2) MSB
        IF ls_cust_raid-distributor_amid_supplier IS NOT INITIAL.
          rv_amid = ls_cust_raid-distributor_amid_supplier.
        ELSEIF ls_cust_raid-distributor_amid_mos IS NOT INITIAL.
          rv_amid = ls_cust_raid-distributor_amid_mos.
        ENDIF.
      ENDIF.
    ELSEIF iv_sender_intcode = /idxgc/if_constants=>gc_service_code_supplier.
      rv_amid = ls_cust_raid-supplier_amid.
    ENDIF.

    IF rv_amid IS INITIAL.
      MESSAGE e010(/adesso/mdc_general) WITH iv_edifact_structur iv_sender_intcode iv_receiver_intcode INTO gv_mtext.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.

  ENDMETHOD.


  METHOD is_field_set.
    DATA: lr_previous  TYPE REF TO cx_root,
          lt_cust_pqal TYPE /adesso/mdc_t_pqal,
          ls_cust_pdoc TYPE /adesso/mdc_s_pdoc.

    FIELD-SYMBOLS: <fs_cust_pqal>  TYPE /adesso/mdc_s_pqal,
                   <ft_table>      TYPE INDEX TABLE,
                   <fs_row>        TYPE any,
                   <fv_field>      TYPE any,
                   <fs_qual_field> TYPE any.

    ls_cust_pdoc = /adesso/cl_mdc_customizing=>get_single_pdoc_edifact_map( iv_edifact_structur = iv_edifact_structur ).
    lt_cust_pqal = /adesso/cl_mdc_customizing=>get_pdoc_pqal_mapping( ).

    IF ls_cust_pdoc-pdoc_step_table IS NOT INITIAL.
      ASSIGN COMPONENT ls_cust_pdoc-pdoc_step_table OF STRUCTURE is_proc_step_data TO <ft_table>.
      IF sy-subrc = 0.
        IF ls_cust_pdoc-pdoc_step_qualifier IS INITIAL.
          READ TABLE <ft_table> ASSIGNING <fs_row> INDEX 1.
        ELSE.
          READ TABLE lt_cust_pqal ASSIGNING <fs_cust_pqal> WITH KEY pdoc_step_table = ls_cust_pdoc-pdoc_step_table.
          IF sy-subrc = 0.
            UNASSIGN <fs_qual_field>.
            LOOP AT <ft_table> ASSIGNING <fs_row>.
              ASSIGN COMPONENT <fs_cust_pqal>-pdoc_step_table_qual_field OF STRUCTURE <fs_row> TO <fs_qual_field>.
              IF <fs_qual_field> = ls_cust_pdoc-pdoc_step_qualifier.
                EXIT.
              ENDIF.
            ENDLOOP.
            IF <fs_row> IS ASSIGNED AND <fs_qual_field> <> ls_cust_pdoc-pdoc_step_qualifier.
              UNASSIGN <fs_row>.
            ENDIF.
          ELSE.
            MESSAGE e058(/idxgc/utility) INTO gv_mtext WITH <fs_cust_pqal>-pdoc_step_table_qual_field ls_cust_pdoc-pdoc_step_table.
            /idxgc/cx_general=>raise_exception_from_msg( ).
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF <fs_row> IS ASSIGNED.
      ASSIGN COMPONENT ls_cust_pdoc-pdoc_step_field OF STRUCTURE <fs_row> TO <fv_field>.
      IF <fv_field> IS ASSIGNED AND <fv_field> IS NOT INITIAL.
        rv_flag_is_set = abap_true.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD split_houseid_compl.
***************************************************************************************************
* THIMEL.R, 20160223, Aufteilung der Hausnummer entsprechend der Vorgaben aus den
*   "Allgemeine Festlegungen 4.1a"
***************************************************************************************************
    DATA: lv_offset TYPE int4.

    FIND FIRST OCCURRENCE OF REGEX '[^0-9]' IN iv_houseid_compl MATCH OFFSET lv_offset.
    IF lv_offset > 0.
      ev_houseid = iv_houseid_compl(lv_offset).
      ev_houseid_add = iv_houseid_compl+lv_offset.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
