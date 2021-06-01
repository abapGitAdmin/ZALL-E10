class /ADZ/CL_MDC_DP_UTILMD_012 definition
  public
  inheriting from /IDEXGE/CL_DP_UTILMD_012
  create public .

public section.

  methods ASSIGNED_DSO
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods MARKET_LOCATION_INVOLVED_SEQ
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods OBIS_DATA_MALO_INVOLVED_SEQ
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods OBIS_DATA_TRANCHE_INVOLVED_SEQ
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods PROC_SEQUENCE
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods PROFILE_DATA_ELEC_INVOLVED_SEQ
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods PROFILE_SET_DATA_INVOLVED__SEQ
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods TRANCHE_DATA_INVOLVED_SEQ
    exceptions
      /IDXGC/CX_PROCESS_ERROR .
  methods USE_FROM_DATE_TIME
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods USE_TO_DATE_TIME
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods REF_PROFILE_DATA_INVOLVED_SEQ
    raising
      /IDXGC/CX_PROCESS_ERROR .

  methods /IDXGL/IF_DP_OUT~GET_CONFIGURATION
    redefinition .
  methods ASSIGNED_METER_OPERATOR
    redefinition .
  methods ASSIGNED_SUPPLIER
    redefinition .
  methods CLIMATE_TEMP_AND_REF_MEASURE
    redefinition .
  methods CONTROL_AREA
    redefinition .
  methods FORECAST_BASIS
    redefinition .
  methods MABIS_TIME_SERIES_CATEGORY
    redefinition .
  methods MEASURED_VALUE_TYPE_OBIS
    redefinition .
  methods MESSAGE_CATEGORY
    redefinition .
  methods OBIS_DATA_MALO_SEQ
    redefinition .
  methods OBIS_DATA_TRANCHE_SEQ
    redefinition .
  methods POINT_OF_DELIVERY
    redefinition .
  methods PROFILE_ATTRIBUTES
    redefinition .
  methods PROFILE_SET
    redefinition .
  methods REFERENCE_PROFILE
    redefinition .
  methods REFERENCE_TO_POD
    redefinition .
  methods REG_CODE_MR_RELEVANCE_AND_USE
    redefinition .
  methods RESPONSIBLE_MARKET_ROLE
    redefinition .
  methods SETTLEMENT_TERRITORY
    redefinition .
  methods SETTLEMENT_UNIT
    redefinition .
  methods TEMP_DEPEND_POD_ENERGY
    redefinition .
  methods TRANCHE_DATA_SEQ
    redefinition .
  methods TRANSACTION_REASON
    redefinition .
  methods TRANSACTION_REF_RESPONSE
    redefinition .
  methods TRANSFORMATION
    redefinition .
  methods VOLTAGE_LEVEL
    redefinition .
  methods YEARLY_CONSUMPTION_FORECAST
    redefinition .
  methods REFERENCE_PROFILE_DATA_SEQ
    redefinition .
protected section.

  data GX_PREVIOUS type ref to CX_ROOT .
  data GV_OWN_INTCODE type INTCODE .

  methods ASSIGNED_SERVICE_PROVIDER
    redefinition .
  methods GET_POD_MALO_MELO
    redefinition .
  PRIVATE SECTION.
ENDCLASS.



CLASS /ADZ/CL_MDC_DP_UTILMD_012 IMPLEMENTATION.


  METHOD /idxgl/if_dp_out~get_configuration.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 17.11.2019
*
* Beschreibung: Quellschritteinstellung ändern entsprechend der Customizing Einstellung.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* THIMEL-R   13.04.2020 Erweiterung für Versand den LF-Nachricht vom NB (Einspeiser ohne DV)
***************************************************************************************************
    DATA: ls_in TYPE /adz/s_mdc_in.

    super->/idxgl/if_dp_out~get_configuration( IMPORTING et_bmid_config = et_bmid_config
                                                         et_edi_comp    = et_edi_comp
                                                         et_edi_strut   = et_edi_strut ).

    TRY.
        gv_own_intcode = /adz/cl_mdc_customizing=>get_own_intcode( ).
      CATCH /idxgc/cx_general INTO gx_previous.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ir_previous = gx_previous ).
    ENDTRY.

    DATA(lt_hdr_seg_range) = VALUE isu_ranges_tab( ( sign = 'I' option = 'EQ' low = 'UTILMD_SG8_SEQ+Z29' )
                                                   ( sign = 'I' option = 'EQ' low = 'UTILMD_SG8_SEQ+Z30' )
                                                   ( sign = 'I' option = 'EQ' low = 'UTILMD_SG8_SEQ+Z31' )
                                                   ( sign = 'I' option = 'EQ' low = 'UTILMD_SG8_SEQ+Z32' )
                                                   ( sign = 'I' option = 'EQ' low = 'UTILMD_SG8_SEQ+Z33' )
                                                   ( sign = 'I' option = 'EQ' low = 'UTILMD_SG8_SEQ+Z34' ) ).

    LOOP AT et_bmid_config ASSIGNING FIELD-SYMBOL(<ls_bmid_config>)
      WHERE edifact_structur IN lt_hdr_seg_range OR dependent_str IN lt_hdr_seg_range.
      IF sis_process_step_data-bmid = /adz/if_mdc_co=>gc_bmid-adz_ch186 AND gv_own_intcode = /adz/if_mdc_co=>gc_intcode-dso_01.
        <ls_bmid_config>-data_add_source = abap_true.
      ELSE.
        TRY.
            ls_in = /adz/cl_mdc_customizing=>get_inbound_config_for_edifact( iv_edifact_structur = <ls_bmid_config>-edifact_structur
                                                                             iv_assoc_servprov   = sis_process_step_data-assoc_servprov ).
          CATCH /idxgc/cx_general.
            "Wenn kein Eintrag gefunden werden kann, dann sollen die eigenen Daten geschickt werden.
            CLEAR: ls_in.
        ENDTRY.
        IF ls_in-setting_sync = 'AL' OR ls_in-setting_sync = 'ML' OR ls_in-setting_sync = 'NO'.
          <ls_bmid_config>-data_add_source = abap_true.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD assigned_dso.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: RIVCHIN-I, THIMEL-R                                                     Datum: 23.10.2019
*
* Beschreibung: Netzbetreiber ermitteln
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************

    me->assigned_service_provider( iv_servcat         = /idxgc/if_constants_ide=>gc_service_cat_dis
                                   iv_party_func_qual = /idxgl/if_constants_ide=>gc_cci_chardesc_code_z88 ).

  ENDMETHOD.


  METHOD assigned_meter_operator.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: RIVCHIN-I                                                               Datum: 11.03.2020
*
* Beschreibung: - Der MSB muss nur noch bei RLM mitgeschickt werden
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXXXXX    XXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************

    IF siv_meter_proc IS INITIAL.
      get_metering_procedure_details( ).
    ENDIF.

    IF siv_meter_proc <> /idxgc/if_constants_add=>gc_meter_proc_e01.
      RETURN.
    ENDIF.

    super->assigned_meter_operator( ).

  ENDMETHOD.


  METHOD assigned_service_provider.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R, RIVCHIN-I                                                     Datum: 31.10.2019
*
* Beschreibung: - Für Tranchen eigene Implementierung, da SAP-Standard keine Trachen unterstützt.
*               - Fehlende EXT_UI für die Übernahme in das IDoc ergänzen
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* THIMEL-R    15.04.2020 Anpassung für Tranchen
***************************************************************************************************
    DATA:
      lt_uiservice TYPE t_eedmuiservice,
      ls_eservprov TYPE eservprov,
      lv_count     TYPE i.

    IF siv_context_seq          = /adz/if_mdc_co=>gc_seq_action_code-z15         AND
       siv_data_processing_mode = /idxgc/if_constants_add=>gc_default_processing.

      LOOP AT sis_process_step_data-pod ASSIGNING FIELD-SYMBOL(<ls_pod>).
        IF line_exists( sit_pod_dev_relation[ ext_ui = <ls_pod>-ext_ui pod_type = /idxgc/if_constants_ide=>gc_pod_type_z70 ] ).

          CALL FUNCTION 'ISU_GET_UISERVICES_FROM_BUFFER'
            EXPORTING
              x_int_ui                    = <ls_pod>-int_ui
              x_no_buffer                 = abap_true
              x_ignore_service_duplicates = abap_true
            IMPORTING
              yt_uiservice                = lt_uiservice
            EXCEPTIONS
              general_fault               = 1
              OTHERS                      = 2.
          IF sy-subrc <> 0.
            MESSAGE e038(/idxgc/ide_add) WITH TEXT-005 INTO siv_mtext.
            CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg.
          ENDIF.

          lv_count = 1.
          LOOP AT lt_uiservice ASSIGNING FIELD-SYMBOL(<ls_uiservice>)
            WHERE service_type = iv_servcat AND service_start <= sis_process_step_data-proc_date AND service_end >= sis_process_step_data-proc_date.

            CLEAR ls_eservprov.

            CALL FUNCTION 'ISU_DB_ESERVPROV_SINGLE'
              EXPORTING
                x_serviceid = <ls_uiservice>-serviceid
              IMPORTING
                y_eservprov = ls_eservprov
              EXCEPTIONS
                not_found   = 1.
            IF sy-subrc <> 0.
              MESSAGE e038(/idxgc/ide_add) WITH TEXT-005 INTO siv_mtext.
              CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg.
            ENDIF.

            sis_process_step_data-marketpartner_add = VALUE #( BASE sis_process_step_data-marketpartner_add
                                                               ( item_id          = <ls_pod>-item_id
                                                                 party_func_qual  = iv_party_func_qual
                                                                 ext_ui           = <ls_pod>-ext_ui
                                                                 data_type_qual   = siv_context_seq
                                                                 mp_counter       = lv_count
                                                                 party_identifier = ls_eservprov-externalid ) ).

            lv_count = lv_count + 1.
          ENDLOOP.
        ENDIF.
      ENDLOOP.

    ELSE.
      super->assigned_service_provider( iv_servcat = iv_servcat iv_party_func_qual = iv_party_func_qual ).
    ENDIF.

    IF sis_process_step_data-bmid = /adz/if_mdc_co=>gc_bmid-adz_ch185 OR
       sis_process_step_data-bmid = /adz/if_mdc_co=>gc_bmid-adz_ch186 OR
       sis_process_step_data-bmid = /adz/if_mdc_co=>gc_bmid-adz_ch188 OR
       sis_process_step_data-bmid = /adz/if_mdc_co=>gc_bmid-adz_ch189.
      LOOP AT sis_process_step_data-marketpartner_add ASSIGNING FIELD-SYMBOL(<ls_marketpartner_add>) WHERE ext_ui IS INITIAL.
        <ls_marketpartner_add>-ext_ui = sis_process_step_data-ext_ui.
      ENDLOOP.
    ENDIF.

***** Prüfung ob Daten gefüllt sind ***************************************************************
    IF NOT line_exists( sis_process_step_data-marketpartner_add[ item_id = siv_itemid data_type_qual = siv_context_seq party_func_qual = iv_party_func_qual ] ).
      siv_data_not_filled = abap_true.
    ELSEIF sis_process_step_data-marketpartner_add[ item_id = siv_itemid data_type_qual = siv_context_seq party_func_qual = iv_party_func_qual ]-party_identifier IS INITIAL.
      siv_data_not_filled = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD assigned_supplier.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 13.11.2019
*
* Beschreibung: - Bei vorhander Tranche steht der Lieferant im SEQ+Z15 und nicht im SEQ+Z01.
*               - Allgemeine Korrektur: Lieferanten sind im VSZ teilweise doppelt hinterlegt (z.B.
*                 bei Einspeisern oder bei EoG). Daher doppelte Einträge löschen.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* THIMEL-R    13.04.2020 Anpassung für Einspeiser
***************************************************************************************************

    IF siv_sup_direct_int = /idxgc/if_constants_add=>gc_sup_direct_feeding                        AND
       line_exists( sit_pod_dev_relation[ pod_type = /idxgc/if_constants_ide=>gc_pod_type_z70 ] ) AND
       siv_context_seq = /idxgc/if_constants_ide=>gc_seq_action_code_z01.
      RETURN.
    ENDIF.

    super->assigned_supplier( ).

    SORT sis_process_step_data-marketpartner_add.
    DELETE ADJACENT DUPLICATES FROM sis_process_step_data-marketpartner_add COMPARING item_id  party_func_qual  ext_ui data_type_qual party_identifier.
  ENDMETHOD.


  METHOD climate_temp_and_ref_measure.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: RIVCHIN-I                                                               Datum: 25.11.2019
*
* Beschreibung: - Übernahme vom NB (Z08/Z34)
*               - Ggf. EXT_UI löschen
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    IF siv_data_processing_mode = /idxgc/if_constants_add=>gc_data_from_add_source AND
       siv_context_seq          = /idxgl/if_constants_ide=>gc_seq_action_code_z34.
      LOOP AT sis_process_data_src_add-/idxgl/profile_data ASSIGNING FIELD-SYMBOL(<ls_profile_data_src_add>)
        WHERE item_id = siv_itemid AND data_type_qual = /idxgc/if_constants_ide=>gc_seq_action_code_z08.
        IF NOT line_exists( sis_process_step_data-/idxgl/profile_data[ item_id = siv_itemid data_type_qual = siv_context_seq ] ).
          sis_process_step_data-/idxgl/profile_data = VALUE #( BASE sis_process_step_data-/idxgl/profile_data ( item_id        = siv_itemid
                                                                                                                data_type_qual = siv_context_seq ) ).
        ENDIF.
        sis_process_step_data-/idxgl/profile_data[ item_id = siv_itemid data_type_qual = siv_context_seq ]-temp_mp_prov    = <ls_profile_data_src_add>-temp_mp_prov.
        sis_process_step_data-/idxgl/profile_data[ item_id = siv_itemid data_type_qual = siv_context_seq ]-temp_mp_cla     = <ls_profile_data_src_add>-temp_mp_cla.
        sis_process_step_data-/idxgl/profile_data[ item_id = siv_itemid data_type_qual = siv_context_seq ]-temp_mp         = <ls_profile_data_src_add>-temp_mp.
        sis_process_step_data-/idxgl/profile_data[ item_id = siv_itemid data_type_qual = siv_context_seq ]-climatezone     = <ls_profile_data_src_add>-climatezone.
        sis_process_step_data-/idxgl/profile_data[ item_id = siv_itemid data_type_qual = siv_context_seq ]-climatezone_cl  = <ls_profile_data_src_add>-climatezone_cl.
        sis_process_step_data-/idxgl/profile_data[ item_id = siv_itemid data_type_qual = siv_context_seq ]-ref_measure     = <ls_profile_data_src_add>-ref_measure.
        sis_process_step_data-/idxgl/profile_data[ item_id = siv_itemid data_type_qual = siv_context_seq ]-ref_measure_cla = <ls_profile_data_src_add>-ref_measure_cla.
      ENDLOOP.
      RETURN.
    ENDIF.

    super->climate_temp_and_ref_measure( ).

    LOOP AT sis_process_step_data-/idxgl/profile_data ASSIGNING FIELD-SYMBOL(<ls_profile_data>)
      WHERE item_id = siv_itemid AND data_type_qual = siv_context_seq AND ext_ui IS INITIAL.
      CLEAR: <ls_profile_data>-ext_ui.
    ENDLOOP.
  ENDMETHOD.


  METHOD control_area.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 26.10.2019
*
* Beschreibung: - Übernahme vom NB
*               - Fehlende EXT_UI für die Übernahme in das IDoc ergänzen
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************

    IF siv_data_processing_mode = /idxgc/if_constants_add=>gc_data_from_add_source AND
       siv_context_seq          = /idxgl/if_constants_ide=>gc_seq_action_code_z29.
      LOOP AT sis_process_data_src_add-/idxgl/pod_data ASSIGNING FIELD-SYMBOL(<ls_pod_data_src_add>)
        WHERE item_id = siv_itemid AND data_type_qual = /idxgc/if_constants_ide=>gc_seq_action_code_z01.
        IF NOT line_exists( sis_process_step_data-/idxgl/pod_data[ item_id = siv_itemid data_type_qual = siv_context_seq ] ).
          sis_process_step_data-/idxgl/pod_data = VALUE #( BASE sis_process_step_data-/idxgl/pod_data ( item_id        = siv_itemid
                                                                                                        data_type_qual = siv_context_seq ) ).
        ENDIF.
        sis_process_step_data-/idxgl/pod_data[ item_id = siv_itemid data_type_qual = siv_context_seq ]-contrlarea_ext = <ls_pod_data_src_add>-contrlarea_ext.
      ENDLOOP.
      RETURN.
    ENDIF.

    super->control_area( ).

    LOOP AT sis_process_step_data-/idxgl/pod_data ASSIGNING FIELD-SYMBOL(<ls_pod_data>)
      WHERE item_id = siv_itemid AND data_type_qual = siv_context_seq AND ext_ui IS INITIAL.
      <ls_pod_data>-ext_ui = sis_process_step_data-ext_ui.
    ENDLOOP.

  ENDMETHOD.


  METHOD forecast_basis.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: RIVCHIN-I, THIMEL-R                                                     Datum: 21.11.2019
*
* Beschreibung: - Übernahme vom NB
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************

    IF siv_data_processing_mode = /idxgc/if_constants_add=>gc_data_from_add_source AND
       siv_context_seq          = /idxgl/if_constants_ide=>gc_seq_action_code_z29.
      LOOP AT sis_process_data_src_add-/idxgl/pod_data ASSIGNING FIELD-SYMBOL(<ls_pod_data_src_add>)
        WHERE item_id = siv_itemid AND data_type_qual = /idxgc/if_constants_ide=>gc_seq_action_code_z01.
        IF line_exists( sis_process_step_data-/idxgl/pod_data[ item_id = siv_itemid data_type_qual = siv_context_seq ] ).
          sis_process_step_data-/idxgl/pod_data[ item_id = siv_itemid data_type_qual = siv_context_seq ]-forecast_basis       = <ls_pod_data_src_add>-forecast_basis.
          sis_process_step_data-/idxgl/pod_data[ item_id = siv_itemid data_type_qual = siv_context_seq ]-forec_basis_detail_a = <ls_pod_data_src_add>-forec_basis_detail_a.
          sis_process_step_data-/idxgl/pod_data[ item_id = siv_itemid data_type_qual = siv_context_seq ]-forec_basis_detail_b = <ls_pod_data_src_add>-forec_basis_detail_b.
        ENDIF.
      ENDLOOP.
      RETURN.
    ENDIF.

    super->forecast_basis( ).

  ENDMETHOD.


  METHOD get_pod_malo_melo.
***************************************************************************************************
*            _                        _____ ______
*           | |                      / ____|  ____|
*   __ _  __| | ___  ___ ___  ___   | (___ | |__
*  / _` |/ _` |/ _ \/ __/ __|/ _ \   \___ \|  __|
* | (_| | (_| |  __/\__ \__ \ (_) |  ____) | |____
*  \__,_|\__,_|\___||___/___/\___/  |_____/|______|
*
* Author: THIMEL-R                                                                Datum: 23.09.2020
*
* Beschreibung: SAP hat die Methode zur Formatanpassung 01.10.2020 redefiniert. Damit ist die
*               Auswertung der Variable IV_TRANCHE_POD entfallen. Das wird aber hier gebraucht,
*               daher aus der Klassenmethode /IDXGL/CL_DP_UTILMD_002=>GET_POD_MELO_MALO wieder
*               kopiert.
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    DATA: lv_int_ui           TYPE int_ui,
          lv_key_date         TYPE dats,
          lr_badi_data_access TYPE REF TO /idxgl/badi_data_access,
          lx_previous         TYPE REF TO cx_root,
          ls_pod_malo_melo    TYPE /idxgl/s_euitrans_malo_melo,
          lr_pod_rel          TYPE REF TO /idxgc/cl_pod_rel_checks,
          lt_pod_malo_melo    TYPE /idxgl/t_euitrans_malo_melo.

    IF iv_int_ui IS NOT INITIAL.
      lv_int_ui = iv_int_ui.
    ELSE.
      lv_int_ui = sis_process_data_src-int_ui.
    ENDIF.

    IF iv_key_date IS NOT INITIAL.
      lv_key_date = iv_key_date.
    ELSE.
      lv_key_date = sis_process_step_data-proc_date.
    ENDIF.

    super->get_pod_malo_melo( iv_int_ui       = iv_int_ui
                              iv_key_date     = iv_key_date
                              iv_whole_bundle = iv_whole_bundle
                              iv_tranche_pod  = iv_tranche_pod ).

    CHECK iv_tranche_pod = abap_true.

    lt_pod_malo_melo = sit_pod_malo_melo.

    LOOP AT lt_pod_malo_melo ASSIGNING FIELD-SYMBOL(<ls_pod_malo_melo>).
      TRY.
          CREATE OBJECT lr_pod_rel
            EXPORTING
              iv_int_ui   = <ls_pod_malo_melo>-int_ui_malo
              iv_key_date = lv_key_date.

          IF lr_pod_rel->is_master( ) <> abap_true OR
             lr_pod_rel->has_relations( ) <> abap_true.
            CONTINUE.
          ENDIF.

          "Get DSO Tranche. Sometimes DSO tranche is Feed-in PoD
          DATA(lv_dso_tranche_int) = lr_pod_rel->get_eeg_kwkg_pod( ).
          READ TABLE sit_pod_malo_melo TRANSPORTING NO FIELDS
            WITH KEY int_ui_malo = lv_dso_tranche_int.
          IF sy-subrc <> 0 AND
             lv_dso_tranche_int IS NOT INITIAL AND
             lv_dso_tranche_int <> <ls_pod_malo_melo>-int_ui_malo.
            CLEAR ls_pod_malo_melo.
            ls_pod_malo_melo-int_ui_malo = lv_dso_tranche_int.
            ls_pod_malo_melo-ext_ui = /idxgc/cl_utility_service_isu=>get_extui_from_intui(
                                        EXPORTING
                                          iv_int_ui = lv_dso_tranche_int
                                          iv_date   = lv_key_date
                                      ).
            APPEND ls_pod_malo_melo TO sit_pod_malo_melo.
          ENDIF.

          "Get Supply Tranches
          lr_pod_rel->get_tranche_pods(
            IMPORTING
              et_int_ui = DATA(lt_sup_tranche_pods)
          ).
          LOOP AT lt_sup_tranche_pods INTO DATA(lv_sup_tranche_int).
            READ TABLE sit_pod_malo_melo TRANSPORTING NO FIELDS
              WITH KEY int_ui_malo = lv_sup_tranche_int.
            IF sy-subrc = 0.
              CONTINUE.
            ENDIF.

            CLEAR ls_pod_malo_melo.
            ls_pod_malo_melo-int_ui_malo = lv_sup_tranche_int.
            ls_pod_malo_melo-ext_ui = /idxgc/cl_utility_service_isu=>get_extui_from_intui(
                                        EXPORTING
                                          iv_int_ui = lv_sup_tranche_int
                                          iv_date   = lv_key_date
                                      ).
            APPEND ls_pod_malo_melo TO sit_pod_malo_melo.
          ENDLOOP.

        CATCH /idxgc/cx_utility_error.
          CONTINUE.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.


  METHOD mabis_time_series_category.
***************************************************************************************************
*            _                        _____ ______
*           | |                      / ____|  ____|
*   __ _  __| | ___  ___ ___  ___   | (___ | |__
*  / _` |/ _` |/ _ \/ __/ __|/ _ \   \___ \|  __|
* | (_| | (_| |  __/\__ \__ \ (_) |  ____) | |____
*  \__,_|\__,_|\___||___/___/\___/  |_____/|______|
*
* Author: THIMEL-R, RIVCHIN-I                                                     Datum: 31.10.2019
*
* Beschreibung: - Analog zu ES103 Daten ermitteln
*               - Fehlende EXT_UI für die Übernahme in das IDoc ergänzen
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************

    IF siv_data_processing_mode = /idxgc/if_constants_add=>gc_data_from_add_source AND
       siv_context_seq          = /idxgl/if_constants_ide=>gc_seq_action_code_z29.
      LOOP AT sis_process_data_src_add-time_series ASSIGNING FIELD-SYMBOL(<ls_time_series_src_add>)
        WHERE item_id = siv_itemid AND data_type_qual = /idxgc/if_constants_ide=>gc_seq_action_code_z01.
        IF NOT line_exists( sis_process_step_data-time_series[ item_id = siv_itemid data_type_qual = siv_context_seq timeser_counter = <ls_time_series_src_add>-timeser_counter ] ).
          sis_process_step_data-time_series = VALUE #( BASE sis_process_step_data-time_series ( item_id         = siv_itemid
                                                                                                data_type_qual  = siv_context_seq
                                                                                                timeser_counter = <ls_time_series_src_add>-timeser_counter ) ).
        ENDIF.
        sis_process_step_data-time_series[ item_id         = siv_itemid
                                           data_type_qual  = siv_context_seq
                                           timeser_counter = <ls_time_series_src_add>-timeser_counter ]-ext_ui           = <ls_time_series_src_add>-ext_ui.
        sis_process_step_data-time_series[ item_id         = siv_itemid
                                           data_type_qual  = siv_context_seq
                                           timeser_counter = <ls_time_series_src_add>-timeser_counter ]-timseries_vers   = <ls_time_series_src_add>-timseries_vers.
        sis_process_step_data-time_series[ item_id         = siv_itemid
                                           data_type_qual  = siv_context_seq
                                           timeser_counter = <ls_time_series_src_add>-timeser_counter ]-time_series_type = <ls_time_series_src_add>-time_series_type.
        sis_process_step_data-time_series[ item_id         = siv_itemid
                                           data_type_qual  = siv_context_seq
                                           timeser_counter = <ls_time_series_src_add>-timeser_counter ]-timseries_msgcat = <ls_time_series_src_add>-timseries_msgcat.
      ENDLOOP.
      RETURN.
    ENDIF.

    DATA(lv_bmid_old) = sis_process_step_data-bmid.
    sis_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_es103.

    TRY.
        super->mabis_time_series_category( ).
      CATCH /idxgc/cx_process_error INTO DATA(lx_previous).
        sis_process_step_data-bmid = lv_bmid_old.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ir_previous = lx_previous ).
    ENDTRY.

    sis_process_step_data-bmid = lv_bmid_old.
    LOOP AT sis_process_step_data-time_series ASSIGNING FIELD-SYMBOL(<ls_time_series>)
      WHERE item_id = siv_itemid AND data_type_qual = siv_context_seq AND ext_ui IS INITIAL.
      <ls_time_series>-ext_ui = sis_process_step_data-ext_ui.
    ENDLOOP.

  ENDMETHOD.


  METHOD market_location_involved_seq.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 13.11.2019
*
* Beschreibung: - Neuimplementierung da im Standard nicht vorhanden (SEQ+Z29 / SEQ+Z01)
*               - NB: Bei Einspeisern ohne DV Schrittdaten kopieren
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* THIMEL-R    13.04.2020 Erweiterung für Versand den LF-Nachricht vom NB (Einspeiser ohne DV)
***************************************************************************************************

    IF sis_process_step_data-bmid = /adz/if_mdc_co=>gc_bmid-adz_ch186 AND gv_own_intcode = /adz/if_mdc_co=>gc_intcode-dso_01.
      sis_process_data_src_add = sis_process_step_data.
    ENDIF.

    siv_context_seq = /adz/if_mdc_co=>gc_seq_action_code-z29.

    DELETE sis_process_step_data-/idxgl/pod_data
      WHERE item_id = siv_itemid AND data_type_qual = siv_context_seq.

    DELETE sis_process_step_data-marketpartner_add
      WHERE item_id = siv_itemid AND data_type_qual = siv_context_seq.

    DELETE sis_process_step_data-pod_quant
      WHERE item_id = siv_itemid AND data_type_qual = siv_context_seq.

    DELETE sis_process_step_data-time_series
      WHERE item_id = siv_itemid AND data_type_qual = siv_context_seq.

    DELETE sis_process_step_data-settl_terr
      WHERE item_id = siv_itemid AND data_type_qual = siv_context_seq.

    DELETE sis_process_step_data-settl_unit
      WHERE item_id = siv_itemid AND data_type_qual = siv_context_seq.

  ENDMETHOD.


  METHOD measured_value_type_obis.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 26.10.2019
*
* Beschreibung: - Übernahme vom NB
*               - Z02 und Z30 nur für Prognose auf Basis von Werten
*               - Z17 und Z32 nur für Einspeisung
*               - Analog zu ES103 Daten ermitteln
*               - Fehlende EXT_UI für die Übernahme in das IDoc ergänzen
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* THIMEL-R    13.04.2020 Gerätedaten auch für MeLo nachlesen.
* THIMEL-R    25.05.2020 Referenz auf EXT_UI entfernen
***************************************************************************************************

    "OBIS der Tranche nur bei Einspeisung relevant
    IF ( siv_context_seq = /idxgl/if_constants_ide=>gc_seq_action_code_z17 OR
         siv_context_seq = /idxgl/if_constants_ide=>gc_seq_action_code_z32 ) AND
       siv_sup_direct_int <> /idxgc/if_constants_add=>gc_sup_direct_feeding.
      RETURN.
    ENDIF.

    "OBIS nur bei Prognose auf Basis von Werten mitschicken laut Bedingung im AHB
    IF siv_context_seq = /idxgc/if_constants_ide=>gc_seq_action_code_z02 OR
       siv_context_seq = /idxgl/if_constants_ide=>gc_seq_action_code_z30.

      DATA(lv_context_seq_malo) = SWITCH #( siv_context_seq WHEN /idxgc/if_constants_ide=>gc_seq_action_code_z02
                                                              THEN /idxgc/if_constants_ide=>gc_seq_action_code_z01
                                                            WHEN /idxgl/if_constants_ide=>gc_seq_action_code_z30
                                                              THEN /idxgl/if_constants_ide=>gc_seq_action_code_z29 ).

      LOOP AT sis_process_step_data-/idxgl/pod_data ASSIGNING FIELD-SYMBOL(<ls_pod_data>)
        WHERE item_id = siv_itemid AND data_type_qual = lv_context_seq_malo AND forecast_basis = /adz/if_mdc_co=>gc_forecast_basis-za6.
        RETURN.
      ENDLOOP.
    ENDIF.

    "Übernahme vom NB
    IF siv_data_processing_mode = /idxgc/if_constants_add=>gc_data_from_add_source AND
       ( siv_context_seq        = /idxgl/if_constants_ide=>gc_seq_action_code_z30 OR
         siv_context_seq        = /idxgl/if_constants_ide=>gc_seq_action_code_z32 ).

      DATA(lv_context_seq_dso) = SWITCH #( siv_context_seq WHEN /idxgl/if_constants_ide=>gc_seq_action_code_z30
                                                             THEN /idxgc/if_constants_ide=>gc_seq_action_code_z02
                                                           WHEN /idxgl/if_constants_ide=>gc_seq_action_code_z32
                                                             THEN /idxgl/if_constants_ide=>gc_seq_action_code_z17 ).

      LOOP AT sis_process_data_src_add-reg_code_data ASSIGNING FIELD-SYMBOL(<ls_reg_code_data_src_add>)
        WHERE item_id = siv_itemid AND data_type_qual = lv_context_seq_dso.
        IF NOT line_exists( sis_process_step_data-reg_code_data[ item_id        = siv_itemid
                                                                 data_type_qual = siv_context_seq
                                                                 reg_code       = <ls_reg_code_data_src_add>-reg_code ] ).
          sis_process_step_data-reg_code_data = VALUE #( BASE sis_process_step_data-reg_code_data
                                                         ( item_id        = siv_itemid
                                                           data_type_qual = siv_context_seq
                                                           reg_code       = <ls_reg_code_data_src_add>-reg_code ) ).
        ENDIF.
      ENDLOOP.
      RETURN.
    ENDIF.

    DATA(lv_bmid_old) = sis_process_step_data-bmid.
    sis_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_es103.

    TRY.
        "Nochmal für alle ZP nachlesen. Da die MeLo nicht übermittelt wird, fehlen die Geräte zur MeLo.
        LOOP AT sit_pod_dev_relation ASSIGNING FIELD-SYMBOL(<ls_pod_dev_relation>).
          get_device_list( iv_ext_ui = <ls_pod_dev_relation>-ext_ui ).
        ENDLOOP.
        super->measured_value_type_obis( ).
      CATCH /idxgc/cx_process_error INTO DATA(lx_previous).
        sis_process_step_data-bmid = lv_bmid_old.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ir_previous = lx_previous ).
    ENDTRY.

    sis_process_step_data-bmid = lv_bmid_old.

    LOOP AT sis_process_step_data-reg_code_data ASSIGNING FIELD-SYMBOL(<ls_reg_code_data>).
      CLEAR: <ls_reg_code_data>-ext_ui.
    ENDLOOP.

  ENDMETHOD.


  METHOD message_category.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: RIVCHIN-I                                                               Datum: 22.10.2019
*
* Beschreibung: Z38 als message_category
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************

    super->message_category( ).

* Stammdatensynchrnonisation
    IF sis_process_step_data-bmid = /adz/if_mdc_co=>gc_bmid-adz_ch185 OR
       sis_process_step_data-bmid = /adz/if_mdc_co=>gc_bmid-adz_ch186 OR
       sis_process_step_data-bmid = /adz/if_mdc_co=>gc_bmid-adz_ch188 OR
       sis_process_step_data-bmid = /adz/if_mdc_co=>gc_bmid-adz_ch189.
      sis_process_step_data-docname_code = /adz/if_mdc_co=>gc_msg_category-z38.
      siv_data_not_filled = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD obis_data_malo_involved_seq.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 13.11.2019
*
* Beschreibung: - Neuimplementierung da im Standard nicht vorhanden (SEQ+Z30)
*               - NB: Bei Einspeisern ohne DV Schrittdaten kopieren
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* THIMEL-R    13.04.2020 Erweiterung für Versand den LF-Nachricht vom NB (Einspeiser ohne DV)
***************************************************************************************************

    IF siv_sup_direct_int = /idxgc/if_constants_add=>gc_sup_direct_feeding AND
       line_exists( sit_pod_dev_relation[ pod_type = /idxgc/if_constants_ide=>gc_pod_type_z70 ] ).
      siv_process_seq = abap_false.
      RETURN.
    ENDIF.

    IF sis_process_step_data-bmid = /adz/if_mdc_co=>gc_bmid-adz_ch186 AND gv_own_intcode = /adz/if_mdc_co=>gc_intcode-dso_01.
      sis_process_data_src_add = sis_process_step_data.
    ENDIF.

    siv_context_seq = /adz/if_mdc_co=>gc_seq_action_code-z30.

    DELETE sis_process_step_data-reg_code_data
      WHERE item_id = siv_itemid AND data_type_qual = siv_context_seq.

    LOOP AT sis_process_step_data-pod ASSIGNING FIELD-SYMBOL(<ls_pod>)
      WHERE item_id = siv_itemid AND loc_func_qual = /idxgc/if_constants_ide=>gc_loc_qual_172.
      IF line_exists( sit_pod_dev_relation[ ext_ui = <ls_pod>-ext_ui pod_type = /idxgc/if_constants_ide=>gc_pod_type_z30 ] ).
        siv_process_seq = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD obis_data_malo_seq.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 15.04.2020
*
* Beschreibung: - Nur übermitteln wenn es keine Tranche gibt.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************

    IF siv_sup_direct_int = /idxgc/if_constants_add=>gc_sup_direct_feeding AND
       line_exists( sit_pod_dev_relation[ pod_type = /idxgc/if_constants_ide=>gc_pod_type_z70 ] ).
      siv_process_seq = abap_false.
      RETURN.
    ENDIF.

    super->obis_data_malo_seq( ).

  ENDMETHOD.


  METHOD obis_data_tranche_involved_seq.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R, RIVCHIN-I                                                     Datum: 14.11.2019
*
* Beschreibung: - Neuimplementierung da im Standard nicht vorhanden (SEQ+Z32)
*               - NB: Bei Einspeisern ohne DV Schrittdaten kopieren
*               - Nur übermitteln wenn es eine Tranche in der Nachricht gibt.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* THIMEL-R    01.04.2020 Prüfung ob Tranche vom NB übermittelt wurde. Löschen von DATA_RELEVANCE
*                        ergänzt.
* THIMEL-R    13.04.2020 Erweiterung für Versand den LF-Nachricht vom NB (Einspeiser ohne DV)
***************************************************************************************************

    IF sis_process_step_data-bmid = /adz/if_mdc_co=>gc_bmid-adz_ch186 AND gv_own_intcode = /adz/if_mdc_co=>gc_intcode-dso_01.
      sis_process_data_src_add = sis_process_step_data.
    ENDIF.

    IF NOT line_exists( sit_pod_dev_relation[ pod_type = /idxgc/if_constants_ide=>gc_pod_type_z70 ] ).
      siv_process_seq = abap_false.
      RETURN.
    ENDIF.

    siv_context_seq = /adz/if_mdc_co=>gc_seq_action_code-z32.

    DELETE sis_process_step_data-reg_code_data
      WHERE item_id = siv_itemid AND data_type_qual = siv_context_seq.

    DELETE sis_process_step_data-/idxgl/data_relevance
      WHERE item_id = siv_itemid AND data_type_qual = siv_context_seq.

  ENDMETHOD.


  METHOD obis_data_tranche_seq.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 01.04.2020
*
* Beschreibung: - Nur übermitteln wenn es eine Tranche in der Nachricht gibt.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************

    IF NOT line_exists( sit_pod_dev_relation[ pod_type = /idxgc/if_constants_ide=>gc_pod_type_z70 ] ).
      siv_process_seq = abap_false.
      RETURN.
    ENDIF.

    super->obis_data_tranche_seq( ).

  ENDMETHOD.


  METHOD point_of_delivery.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 16.11.2019
*
* Beschreibung: - Die SAP-Standard Methode berücksichtigt die Besonderheiten der SDS nicht.
*               - Annahme: Im PDoc Kopf steht bei Einspeisern die Tranche, falls vorhanden.
*               - SIT_POD_DEV_REALTION soll alle MeLos, die MaLo und die Tranche enthalten.
*               - SIS_PROCESS_STEP_DATA-POD soll die MaLo und die Tranche enthalten.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* THIMEL-R    13.04.2020 Neuimplementierung, weil Einspeiser nicht berücksichtigt wurden.
***************************************************************************************************
    DATA: ls_pod_dev_relation TYPE /idxgc/s_pod_dev_relation.

    "Immer mit Tranche lesen, auch wenn schon gefüllt.
    IF lines( sis_process_data_src-pod ) = 1.
      get_pod_malo_melo( iv_tranche_pod = abap_true ).
    ELSE.
      "Die Methode darf nicht mit der Tranchen-Malo aufgerufen werden.
      LOOP AT sis_process_data_src-pod ASSIGNING FIELD-SYMBOL(<ls_pod>)
        WHERE ext_ui <> sis_process_step_data-ext_ui AND int_ui IS NOT INITIAL.
        get_pod_malo_melo( iv_int_ui = <ls_pod>-int_ui iv_tranche_pod = abap_true ).
      ENDLOOP.
      IF sy-subrc <> 0.
        get_pod_malo_melo( iv_tranche_pod = abap_true ).
      ENDIF.
    ENDIF.

    LOOP AT sit_pod_malo_melo ASSIGNING FIELD-SYMBOL(<ls_pod_malo_melo>).
      CLEAR ls_pod_dev_relation.
      ls_pod_dev_relation-ext_ui   = <ls_pod_malo_melo>-ext_ui.
      ls_pod_dev_relation-int_ui   = <ls_pod_malo_melo>-int_ui_malo.
      ls_pod_dev_relation-pod_type = determine_pod_type( iv_int_ui       = ls_pod_dev_relation-int_ui
                                                         iv_ext_ui       = ls_pod_dev_relation-ext_ui
                                                         iv_process_date = sis_process_step_data-proc_date ).
      APPEND ls_pod_dev_relation TO sit_pod_dev_relation.

      sis_process_step_data-pod = VALUE #( BASE sis_process_step_data-pod
                                           ( item_id  = siv_itemid
                                             ext_ui   = ls_pod_dev_relation-ext_ui
                                             int_ui   = ls_pod_dev_relation-int_ui
                                             loc_func_qual = /idxgc/if_constants_ide=>gc_loc_qual_172 ) ).

      "MeLos in SIT_POD_RELATION mit aufnehmen zur MaLo
      IF ls_pod_dev_relation-pod_type = /idxgc/if_constants_ide=>gc_pod_type_z30.
        LOOP AT <ls_pod_malo_melo>-melo ASSIGNING FIELD-SYMBOL(<ls_melo>).
          sit_pod_dev_relation = VALUE #( BASE sit_pod_dev_relation
                                          ( ext_ui   = <ls_melo>-ext_ui
                                            int_ui   = <ls_melo>-int_ui_melo
                                            pod_type = determine_pod_type( iv_int_ui       = <ls_melo>-int_ui_melo
                                                                           iv_ext_ui       = <ls_melo>-ext_ui
                                                                           iv_process_date = sis_process_step_data-proc_date ) ) ).
        ENDLOOP.
      ENDIF.
    ENDLOOP.

***** Prüfung ob Daten gefüllt sind ***************************************************************
    IF NOT line_exists( sis_process_step_data-pod[ item_id = siv_itemid loc_func_qual = /idxgc/if_constants_ide=>gc_loc_qual_172 ] ).
      siv_data_not_filled = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD proc_sequence.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 26.10.2019
*
* Beschreibung: Zugeordnete Verarbeitungsreihenfolge des NB
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************

    DATA: lv_proc_sequence TYPE /idxgc/de_proc_sequence.

    IF NOT line_exists( sis_process_step_data-diverse[ item_id = siv_itemid ] ).
      sis_process_step_data-diverse = VALUE #( ( item_id = siv_itemid ) ).
    ENDIF.

    CASE siv_data_processing_mode.
      WHEN /idxgc/if_constants_add=>gc_data_from_source.
        IF line_exists( sis_process_data_src-diverse[ item_id = siv_itemid ] ).
          sis_process_step_data-diverse[ item_id = siv_itemid ]-proc_sequence = sis_process_data_src_add-diverse[ item_id = siv_itemid ]-proc_sequence.
        ENDIF.

      WHEN /idxgc/if_constants_add=>gc_data_from_add_source.
        IF line_exists( sis_process_data_src_add-diverse[ item_id = siv_itemid ] ).
          sis_process_step_data-diverse[ item_id = siv_itemid ]-proc_sequence = sis_process_data_src_add-diverse[ item_id = siv_itemid ]-proc_sequence.
        ENDIF.

      WHEN /idxgc/if_constants_add=>gc_default_processing.
        ASSIGN sis_process_step_data-diverse[ item_id = siv_itemid ] TO FIELD-SYMBOL(<ls_diverse>).

        CALL FUNCTION 'NUMBER_GET_NEXT'
          EXPORTING
            nr_range_nr             = '01'
            object                  = /adz/if_mdc_co=>gc_nr_range_object-adz_prseq
          IMPORTING
            number                  = lv_proc_sequence
          EXCEPTIONS
            interval_not_found      = 1
            number_range_not_intern = 2
            object_not_found        = 3
            quantity_is_0           = 4
            quantity_is_not_1       = 5
            interval_overflow       = 6
            buffer_overflow         = 7
            OTHERS                  = 8.
        IF sy-subrc <> 0.
          siv_data_not_filled = abap_true.
        ENDIF.
*führende 0 löschen
        SHIFT lv_proc_sequence LEFT DELETING LEADING '0'.
        <ls_diverse>-proc_sequence = lv_proc_sequence.
    ENDCASE.

***** Prüfung ob Wert gefüllt ist. ****************************************************************
    LOOP AT sis_process_step_data-diverse TRANSPORTING NO FIELDS WHERE item_id = siv_itemid AND proc_sequence IS INITIAL.
      siv_data_not_filled = abap_true.
    ENDLOOP.

  ENDMETHOD.


  METHOD profile_attributes.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 31.10.2019
*
* Beschreibung: - Übernahme vom NB
*               - Ggf. EXT_UI löschen
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* THIMEL-R    26.04.2021 Ergänzunh für Z08 -> Z34
***************************************************************************************************
    FIELD-SYMBOLS: <ls_profile_data_src_add> TYPE /idxgl/s_profile_details.

    IF siv_data_processing_mode = /idxgc/if_constants_add=>gc_data_from_add_source AND
       siv_context_seq          = /idxgl/if_constants_ide=>gc_seq_action_code_z33.
      LOOP AT sis_process_data_src_add-/idxgl/profile_data ASSIGNING <ls_profile_data_src_add>
        WHERE item_id = siv_itemid AND data_type_qual = /idxgl/if_constants_ide=>gc_seq_action_code_z21.
        IF NOT line_exists( sis_process_step_data-/idxgl/profile_data[ item_id = siv_itemid data_type_qual = siv_context_seq ] ).
          sis_process_step_data-/idxgl/profile_data = VALUE #( BASE sis_process_step_data-/idxgl/profile_data ( item_id        = siv_itemid
                                                                                                                data_type_qual = siv_context_seq ) ).
        ENDIF.
        sis_process_step_data-/idxgl/profile_data[ item_id = siv_itemid data_type_qual = siv_context_seq ]-profile_group  = <ls_profile_data_src_add>-profile_group.
        sis_process_step_data-/idxgl/profile_data[ item_id = siv_itemid data_type_qual = siv_context_seq ]-profile_group2 = <ls_profile_data_src_add>-profile_group2.
        sis_process_step_data-/idxgl/profile_data[ item_id = siv_itemid data_type_qual = siv_context_seq ]-prof_code_sy   = <ls_profile_data_src_add>-prof_code_sy.
        sis_process_step_data-/idxgl/profile_data[ item_id = siv_itemid data_type_qual = siv_context_seq ]-prof_code_sy2  = <ls_profile_data_src_add>-prof_code_sy2.
        sis_process_step_data-/idxgl/profile_data[ item_id = siv_itemid data_type_qual = siv_context_seq ]-prof_code_an   = <ls_profile_data_src_add>-prof_code_an.
        sis_process_step_data-/idxgl/profile_data[ item_id = siv_itemid data_type_qual = siv_context_seq ]-prof_code_an2  = <ls_profile_data_src_add>-prof_code_an2.
      ENDLOOP.
      RETURN.
    ENDIF.

    IF siv_data_processing_mode = /idxgc/if_constants_add=>gc_data_from_add_source AND
       siv_context_seq          = /idxgl/if_constants_ide=>gc_seq_action_code_z34.
      LOOP AT sis_process_data_src_add-/idxgl/profile_data ASSIGNING <ls_profile_data_src_add>
        WHERE item_id = siv_itemid AND data_type_qual = /idxgc/if_constants_ide=>gc_seq_action_code_z08.
        IF NOT line_exists( sis_process_step_data-/idxgl/profile_data[ item_id = siv_itemid data_type_qual = siv_context_seq ] ).
          sis_process_step_data-/idxgl/profile_data = VALUE #( BASE sis_process_step_data-/idxgl/profile_data ( item_id        = siv_itemid
                                                                                                                data_type_qual = siv_context_seq ) ).
        ENDIF.
        sis_process_step_data-/idxgl/profile_data[ item_id = siv_itemid data_type_qual = siv_context_seq ]-profile_group  = <ls_profile_data_src_add>-profile_group.
        sis_process_step_data-/idxgl/profile_data[ item_id = siv_itemid data_type_qual = siv_context_seq ]-profile_group2 = <ls_profile_data_src_add>-profile_group2.
        sis_process_step_data-/idxgl/profile_data[ item_id = siv_itemid data_type_qual = siv_context_seq ]-prof_code_sy   = <ls_profile_data_src_add>-prof_code_sy.
        sis_process_step_data-/idxgl/profile_data[ item_id = siv_itemid data_type_qual = siv_context_seq ]-prof_code_sy2  = <ls_profile_data_src_add>-prof_code_sy2.
        sis_process_step_data-/idxgl/profile_data[ item_id = siv_itemid data_type_qual = siv_context_seq ]-prof_code_an   = <ls_profile_data_src_add>-prof_code_an.
        sis_process_step_data-/idxgl/profile_data[ item_id = siv_itemid data_type_qual = siv_context_seq ]-prof_code_an2  = <ls_profile_data_src_add>-prof_code_an2.
      ENDLOOP.
      RETURN.
    ENDIF.

    super->profile_attributes( ).

    LOOP AT sis_process_step_data-/idxgl/profile_data ASSIGNING FIELD-SYMBOL(<ls_profile_data>)
      WHERE item_id = siv_itemid AND data_type_qual = siv_context_seq AND ext_ui IS NOT INITIAL.
      CLEAR: <ls_profile_data>-ext_ui.
    ENDLOOP.

  ENDMETHOD.


  METHOD profile_data_elec_involved_seq.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: RIVCHIN-I                                                                Datum: 14.11.2019
*
* Beschreibung: Prozessierung SEQ Z33 (zu Z21)
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* RIVCHIN-I   07.04.2020 Nicht verwenden von Z33 bei RLM
***************************************************************************************************
    CLEAR siv_context_seq.

    IF siv_meter_proc IS INITIAL.
      CALL METHOD me->get_metering_procedure_details( ).
    ENDIF.

    IF siv_meter_proc <> /idxgc/if_constants_add=>gc_meter_proc_e02
      AND siv_meter_proc <> /idxgc/if_constants_add=>gc_meter_proc_e24
      AND sis_process_step_data-bmid <> /idxgc/if_constants_ide=>gc_bmid_ep100.
      siv_process_seq = abap_false.
      RETURN.
    ENDIF.

    READ TABLE sis_process_data_src-/idxgl/profile_data INTO DATA(ls_pro_data)
      WITH KEY item_id = siv_itemid.
    IF ls_pro_data-profile_set IS INITIAL.
      siv_context_seq = /adz/if_mdc_co=>gc_seq_action_code-z33.
      DELETE sis_process_step_data-/idxgl/profile_data
        WHERE item_id = siv_itemid AND data_type_qual = siv_context_seq.
    ENDIF.

  ENDMETHOD.


  METHOD profile_set.
***************************************************************************************************
*            _                        _____ ______
*           | |                      / ____|  ____|
*   __ _  __| | ___  ___ ___  ___   | (___ | |__
*  / _` |/ _` |/ _ \/ __/ __|/ _ \   \___ \|  __|
* | (_| | (_| |  __/\__ \__ \ (_) |  ____) | |____
*  \__,_|\__,_|\___||___/___/\___/  |_____/|______|
*
* Author: RIVCHIN-I                                                                Datum: 25.11.2019
*
* Beschreibung: - Übernahme vom NB (Z08/Z34)
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************

    IF siv_data_processing_mode = /idxgc/if_constants_add=>gc_data_from_add_source AND
       siv_context_seq          = /idxgl/if_constants_ide=>gc_seq_action_code_z34.
      LOOP AT sis_process_data_src_add-/idxgl/profile_data ASSIGNING FIELD-SYMBOL(<ls_profile_data_src_add>)
        WHERE item_id = siv_itemid AND data_type_qual = /idxgc/if_constants_ide=>gc_seq_action_code_z08.
        IF NOT line_exists( sis_process_step_data-/idxgl/profile_data[ item_id = siv_itemid data_type_qual = siv_context_seq ] ).
          sis_process_step_data-/idxgl/profile_data = VALUE #( BASE sis_process_step_data-/idxgl/profile_data ( item_id        = siv_itemid
                                                                                                                data_type_qual = siv_context_seq ) ).
        ENDIF.
        sis_process_step_data-/idxgl/profile_data[ item_id = siv_itemid data_type_qual = siv_context_seq ]-profile_set = <ls_profile_data_src_add>-profile_set.
      ENDLOOP.
      RETURN.
    ENDIF.

    super->profile_set( ).

    LOOP AT sis_process_step_data-/idxgl/profile_data ASSIGNING FIELD-SYMBOL(<ls_profile_data>)
      WHERE item_id = siv_itemid AND data_type_qual = siv_context_seq AND ext_ui IS INITIAL.
      <ls_profile_data>-ext_ui = sis_process_step_data-ext_ui.
    ENDLOOP.
  ENDMETHOD.


  METHOD profile_set_data_involved__seq.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: RIVCHIN-I                                                                Datum: 14.11.2019
*
* Beschreibung: Prozessierung SEQ Z34 (zu Z08)
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    DATA: ls_pro_data TYPE /idxgl/s_profile_details.

    IF siv_meter_proc <> /idxgc/if_constants_add=>gc_meter_proc_e14
      AND siv_meter_proc <> /idxgc/if_constants_add=>gc_meter_proc_e24
      AND sis_process_step_data-bmid <> /idxgc/if_constants_ide=>gc_bmid_ep100.
      siv_process_seq = abap_false.
      RETURN.
    ENDIF.

    CLEAR siv_context_seq.

    READ TABLE sis_process_data_src-/idxgl/profile_data INTO ls_pro_data
      WITH KEY item_id = siv_itemid.
    IF ls_pro_data-profile_set IS NOT INITIAL.
      siv_context_seq = /adz/if_mdc_co=>gc_seq_action_code-z34. "/idxgc/if_constants_ide=>gc_seq_action_code_z08.
      DELETE sis_process_step_data-/idxgl/profile_data
        WHERE item_id = siv_itemid
          AND data_type_qual = siv_context_seq.
    ENDIF.
  ENDMETHOD.


  METHOD reference_profile.
***************************************************************************************************
*            _                        _____ ______
*           | |                      / ____|  ____|
*   __ _  __| | ___  ___ ___  ___   | (___ | |__
*  / _` |/ _` |/ _ \/ __/ __|/ _ \   \___ \|  __|
* | (_| | (_| |  __/\__ \__ \ (_) |  ____) | |____
*  \__,_|\__,_|\___||___/___/\___/  |_____/|______|
*
* Author: SENCENKO-E                                       Datum: 03.03.2021
*
* Beschreibung: - Übernahme vom NB (Z38/Z39)
*
***************************************************************************************************
* Wichtige / Große Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************

    IF siv_data_processing_mode = /idxgc/if_constants_add=>gc_data_from_add_source AND
       siv_context_seq          = /idxgl/if_constants_ide=>gc_seq_action_code_z39.
      LOOP AT sis_process_data_src_add-/idxgl/profile_data ASSIGNING FIELD-SYMBOL(<ls_profile_data_src_add>)
        WHERE item_id = siv_itemid AND data_type_qual = /idxgl/if_constants_ide=>gc_seq_action_code_z38.
        IF NOT line_exists( sis_process_step_data-/idxgl/profile_data[ item_id = siv_itemid data_type_qual = siv_context_seq ] ).
          sis_process_step_data-/idxgl/profile_data = VALUE #( BASE sis_process_step_data-/idxgl/profile_data ( item_id        = siv_itemid
                                                                                                                data_type_qual = siv_context_seq ) ).
        ENDIF.
        sis_process_step_data-/idxgl/profile_data[ item_id = siv_itemid data_type_qual = siv_context_seq ]-profile_group = <ls_profile_data_src_add>-profile_group.
        sis_process_step_data-/idxgl/profile_data[ item_id = siv_itemid data_type_qual = siv_context_seq ]-ref_prof_code = <ls_profile_data_src_add>-ref_prof_code.

      ENDLOOP.
      RETURN.
    ENDIF.

    super->reference_profile( ).
  ENDMETHOD.


  method REFERENCE_PROFILE_DATA_SEQ.
***************************************************************************************************
*            _                        _____ ______
*           | |                      / ____|  ____|
*   __ _  __| | ___  ___ ___  ___   | (___ | |__
*  / _` |/ _` |/ _ \/ __/ __|/ _ \   \___ \|  __|
* | (_| | (_| |  __/\__ \__ \ (_) |  ____) | |____
*  \__,_|\__,_|\___||___/___/\___/  |_____/|______|
*
* Author: THIMEL-R                                                                Datum: 17.03.2021
*
* Beschreibung: SIV_CONTEXT_SEQ leeren, sonst läuft ein DELETE mit dem aktuellen = alten SEQ.
*
***************************************************************************************************
* Wichtige / Große Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************

    CLEAR: siv_context_seq.

    super->reference_profile_data_seq( ).

  endmethod.


  METHOD reference_to_pod.
***************************************************************************************************
*            _                        _____ ______
*           | |                      / ____|  ____|
*   __ _  __| | ___  ___ ___  ___   | (___ | |__
*  / _` |/ _` |/ _ \/ __/ __|/ _ \   \___ \|  __|
* | (_| | (_| |  __/\__ \__ \ (_) |  ____) | |____
*  \__,_|\__,_|\___||___/___/\___/  |_____/|______|
*
* Author: THIMEL-R                                                                Datum: 22.10.2019
*
* Beschreibung: - Erweiterun für Z15 und Z29
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* THIMEL-R    17.04.2020 Erweiterung für Tranchen
* THIMEL-R    23.09.2020 Tranchen werden nun auch im SAP-Standard richtig umgesetzt, daher wurde
*                        die vorherige Änderung hier zurückgebaut.
***************************************************************************************************

    super->reference_to_pod( ).

    LOOP AT sis_process_step_data-pod ASSIGNING FIELD-SYMBOL(<ls_pod>) WHERE item_id = siv_itemid.
      IF line_exists( sit_pod_dev_relation[ ext_ui = <ls_pod>-ext_ui ] ).
        CASE siv_context_seq.
*          WHEN /idxgl/if_constants_ide=>gc_seq_action_code_z15.
*            IF sit_pod_dev_relation[ ext_ui = <ls_pod>-ext_ui ]-pod_type = /idxgc/if_constants_ide=>gc_pod_type_z70.
*              sis_process_step_data-/idxgl/pod_data = VALUE #( BASE sis_process_step_data-/idxgl/pod_data ( item_id        = siv_itemid
*                                                                                                            data_type_qual = siv_context_seq
*                                                                                                            ext_ui         = <ls_pod>-ext_ui ) ).
*            ENDIF.
          WHEN /idxgl/if_constants_ide=>gc_seq_action_code_z29.
            IF sit_pod_dev_relation[ ext_ui = <ls_pod>-ext_ui ]-pod_type = /idxgc/if_constants_ide=>gc_pod_type_z30.
              sis_process_step_data-/idxgl/pod_data = VALUE #( BASE sis_process_step_data-/idxgl/pod_data ( item_id        = siv_itemid
                                                                                                            data_type_qual = siv_context_seq
                                                                                                            ext_ui         = <ls_pod>-ext_ui ) ).
            ENDIF.
        ENDCASE.
      ENDIF.
    ENDLOOP.

***** Prüfung ob Daten gefüllt sind ***************************************************************
    CASE siv_context_seq.
      WHEN /idxgl/if_constants_ide=>gc_seq_action_code_z29.
        IF NOT line_exists( sis_process_step_data-/idxgl/pod_data[ item_id = siv_itemid ] ).
          siv_data_not_filled = abap_true.
        ENDIF.
    ENDCASE.
  ENDMETHOD.


  METHOD ref_profile_data_involved_seq.
***************************************************************************************************
*            _                        _____ ______
*           | |                      / ____|  ____|
*   __ _  __| | ___  ___ ___  ___   | (___ | |__
*  / _` |/ _` |/ _ \/ __/ __|/ _ \   \___ \|  __|
* | (_| | (_| |  __/\__ \__ \ (_) |  ____) | |____
*  \__,_|\__,_|\___||___/___/\___/  |_____/|______|
*
* Author: SENCENKO-E                                       Datum: 01.03.2021
*
* Beschreibung: - Neuimplementierung da im Standard nicht vorhanden (SEQ+Z39)
*
***************************************************************************************************
* Wichtige / Große Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************

    READ TABLE sis_process_step_data-/idxgl/pod_data INTO DATA(ls_pod_data) WITH KEY item_id = siv_itemid.

    IF ls_pod_data-forec_basis_detail_a <> /idxgc/if_constants_add=>gc_meter_proc_z36 OR
       ls_pod_data-forecast_basis       <> /idxgl/if_constants_ide=>gc_cci_chardesc_code_za6 OR
       ls_pod_data-supply_direct        <> /idxgc/if_constants_add=>gc_supply_direct_z06 OR
       ls_pod_data-resp_market_role     <> /idxgl/if_constants_ide=>gc_resp_market_role_za8.
      siv_process_seq = abap_false.
      RETURN.
    ENDIF.



    CLEAR siv_context_seq.

    IF sit_meter_proc_details IS INITIAL.
      get_metering_procedure_details( ).
    ENDIF.

    READ TABLE sit_meter_proc_details INTO DATA(ls_meter_proc_details) WITH KEY item_id = siv_itemid.
    READ TABLE sis_process_data_src-/idxgl/profile_data INTO DATA(ls_pro_data) WITH KEY item_id = siv_itemid.
    IF ls_pro_data-profile_set IS NOT INITIAL AND ls_meter_proc_details-profile_group = /idxgc/if_constants_ide=>gc_profile_group_z05 .
      siv_context_seq = /idxgl/if_constants_ide=>gc_seq_action_code_z39.
      DELETE sis_process_step_data-/idxgl/profile_data
        WHERE item_id = siv_itemid
          AND data_type_qual = siv_context_seq.
    ELSE.
      siv_process_seq = abap_false.
    ENDIF.

  ENDMETHOD.


  METHOD reg_code_mr_relevance_and_use.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R, RIVCHIN-I                                                     Datum: 25.11.2019
*
* Beschreibung: - Übernahme vom NB (nur für Z85)
*               - Zu viel ermittelte Daten löschen
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* THIMEL-R    12.03.2020 Formatanpassung 01.04.2020: Neuer Qualifier ZB5
* THIMEL-R    13.04.2020 Korrektur Doppelversand CCI+Z27
* THIMEL-R    30.04.2020 Mindestanforderung laut AHB mitschicken
* THIMEL-R    25.05.2020 Referenz auf ZP entfernen
***************************************************************************************************

    IF siv_data_processing_mode = /idxgc/if_constants_add=>gc_data_from_add_source AND
       ( siv_context_seq        = /idxgl/if_constants_ide=>gc_seq_action_code_z30 OR
         siv_context_seq        = /idxgl/if_constants_ide=>gc_seq_action_code_z32 ).

      DATA(lv_data_type_qual_dso) = SWITCH #( siv_context_seq WHEN /idxgl/if_constants_ide=>gc_seq_action_code_z30
                                                                THEN /idxgc/if_constants_ide=>gc_seq_action_code_z02
                                                              WHEN /idxgl/if_constants_ide=>gc_seq_action_code_z32
                                                                THEN /idxgl/if_constants_ide=>gc_seq_action_code_z17 ).

      "Bei der Synchronisation darf von der beteiligten Marktrolle nur Z85 mitgegeben werden und
      "  es sollen nur die für den Lieferanten nötigen Werte übernommen werden.
      LOOP AT sis_process_data_src_add-/idxgl/data_relevance ASSIGNING FIELD-SYMBOL(<ls_data_relevance_src_add>)
        WHERE item_id = siv_itemid AND data_type_qual = lv_data_type_qual_dso AND data_use = /idxgl/if_constants_ide=>gc_data_use_z85
          AND data_mrrel = /idxgl/if_constants_ide=>gc_data_mrrel_za7.

        IF NOT line_exists( sis_process_step_data-/idxgl/data_relevance[ item_id        = siv_itemid
                                                                         data_type_qual = siv_context_seq
                                                                         reg_code       = <ls_data_relevance_src_add>-reg_code
                                                                         data_mrrel     = <ls_data_relevance_src_add>-data_mrrel
                                                                         data_use       = <ls_data_relevance_src_add>-data_use ] ).

          sis_process_step_data-/idxgl/data_relevance = VALUE #( BASE sis_process_step_data-/idxgl/data_relevance
                                                                 ( item_id        = siv_itemid
                                                                   data_type_qual = siv_context_seq
                                                                   reg_code       = <ls_data_relevance_src_add>-reg_code
                                                                   data_mrrel     = <ls_data_relevance_src_add>-data_mrrel
                                                                   data_use       = <ls_data_relevance_src_add>-data_use ) ).
        ENDIF.
      ENDLOOP.
      "Mindestanforderung pro OBIS laut AHB ist ZA7->Z85.
      LOOP AT sis_process_step_data-reg_code_data ASSIGNING FIELD-SYMBOL(<ls_reg_code_data>)
        WHERE item_id = siv_itemid AND data_type_qual = siv_context_seq.
        IF NOT line_exists( sis_process_step_data-/idxgl/data_relevance[ item_id        = siv_itemid
                                                                         data_type_qual = siv_context_seq
                                                                         reg_code       = <ls_reg_code_data>-reg_code
                                                                         data_mrrel     = /idxgl/if_constants_ide=>gc_data_mrrel_za7
                                                                         data_use       = /idxgl/if_constants_ide=>gc_data_use_z85 ] ).

          sis_process_step_data-/idxgl/data_relevance = VALUE #( BASE sis_process_step_data-/idxgl/data_relevance
                                                                 ( item_id        = siv_itemid
                                                                   data_type_qual = siv_context_seq
                                                                   reg_code       = <ls_reg_code_data>-reg_code
                                                                   data_mrrel     = /idxgl/if_constants_ide=>gc_data_mrrel_za7
                                                                   data_use       = /idxgl/if_constants_ide=>gc_data_use_z85 ) ).
        ENDIF.
      ENDLOOP.
      RETURN.
    ENDIF.

    super->reg_code_mr_relevance_and_use( ).

    "Es darf nur Z85 und ZB5 vom Netzbetreiber (Segmente Z02 und Z17) und Z85 von der beteiligten Marktrolle (Segmente Z30 und Z32) mitgeschickt werden.
    IF siv_context_seq = /idxgl/if_constants_ide=>gc_seq_action_code_z30 OR siv_context_seq = /idxgl/if_constants_ide=>gc_seq_action_code_z32.
      DELETE sis_process_step_data-/idxgl/data_relevance
        WHERE item_id = siv_itemid AND data_type_qual = siv_context_seq AND data_use <> /idxgl/if_constants_ide=>gc_data_use_z85.
    ELSE.
      DELETE sis_process_step_data-/idxgl/data_relevance
        WHERE item_id = siv_itemid AND data_type_qual = siv_context_seq
          AND data_use <> /idxgl/if_constants_ide=>gc_data_use_z85 AND data_use <> /adz/if_mdc_co=>gc_data_use-zb5.
    ENDIF.

    LOOP AT sis_process_step_data-/idxgl/data_relevance ASSIGNING FIELD-SYMBOL(<ls_data_relevance>) WHERE ext_ui IS NOT INITIAL.
      CLEAR: <ls_data_relevance>-ext_ui.
    ENDLOOP.

    SORT sis_process_step_data-/idxgl/data_relevance.
    DELETE ADJACENT DUPLICATES FROM sis_process_step_data-/idxgl/data_relevance.

  ENDMETHOD.


  METHOD responsible_market_role.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: RIVCHIN-I                                                               Datum: 21.11.2019
*
* Beschreibung: - Übernahme vom NB
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* THIMEL-R    25.05.2020 ZP-Referenz bei Einspeisern falsch gesetzt -> entfernt
***************************************************************************************************

    IF siv_data_processing_mode = /idxgc/if_constants_add=>gc_data_from_add_source AND
       siv_context_seq          = /idxgl/if_constants_ide=>gc_seq_action_code_z29.
      LOOP AT sis_process_data_src_add-/idxgl/pod_data ASSIGNING FIELD-SYMBOL(<ls_pod_data_src_add>)
        WHERE item_id = siv_itemid AND data_type_qual = /idxgc/if_constants_ide=>gc_seq_action_code_z01.
        IF line_exists( sis_process_step_data-/idxgl/pod_data[ item_id = siv_itemid data_type_qual = siv_context_seq ] ).
          sis_process_step_data-/idxgl/pod_data[ item_id = siv_itemid data_type_qual = siv_context_seq ]-resp_market_role = <ls_pod_data_src_add>-resp_market_role.
        ENDIF.
      ENDLOOP.
      RETURN.
    ENDIF.

    super->responsible_market_role( ).

  ENDMETHOD.


  METHOD settlement_territory.
***************************************************************************************************
*            _                        _____ ______
*           | |                      / ____|  ____|
*   __ _  __| | ___  ___ ___  ___   | (___ | |__
*  / _` |/ _` |/ _ \/ __/ __|/ _ \   \___ \|  __|
* | (_| | (_| |  __/\__ \__ \ (_) |  ____) | |____
*  \__,_|\__,_|\___||___/___/\___/  |_____/|______|
*
* Author: THIMEL-R                                                                Datum: 26.10.2019
*
* Beschreibung: - Übernahme vom NB
*               - Analog zu ES103 Daten ermitteln
*               - Fehlende EXT_UI für die Übernahme in das IDoc ergänzen
*
***************************************************************************************************
* Wichtige / Große Änderungen:
* Nutzer      Datum      Beschreibung
* THIMEL-R    17.04.2020 Richtige EXT_UI bei vorhandener Tranche wählen
***************************************************************************************************

    IF siv_data_processing_mode = /idxgc/if_constants_add=>gc_data_from_add_source AND
       siv_context_seq          = /idxgl/if_constants_ide=>gc_seq_action_code_z29.
      LOOP AT sis_process_data_src_add-settl_terr ASSIGNING FIELD-SYMBOL(<ls_settl_terr_src_add>)
        WHERE item_id = siv_itemid AND data_type_qual = /idxgc/if_constants_ide=>gc_seq_action_code_z01.
        IF NOT line_exists( sis_process_step_data-settl_terr[ item_id = siv_itemid data_type_qual = siv_context_seq ] ).
          sis_process_step_data-settl_terr = VALUE #( BASE sis_process_step_data-settl_terr ( item_id        = siv_itemid
                                                                                              data_type_qual = siv_context_seq ) ).
        ENDIF.
        sis_process_step_data-settl_terr[ item_id = siv_itemid data_type_qual = siv_context_seq ]-ext_ui        = <ls_settl_terr_src_add>-ext_ui.
        sis_process_step_data-settl_terr[ item_id = siv_itemid data_type_qual = siv_context_seq ]-settlterr_ext = <ls_settl_terr_src_add>-settlterr_ext.
      ENDLOOP.
      RETURN.
    ENDIF.

    DATA(lv_bmid_old) = sis_process_step_data-bmid.
    sis_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_es103.

    TRY.
        super->settlement_territory( ).
      CATCH /idxgc/cx_process_error INTO DATA(lx_previous).
        sis_process_step_data-bmid = lv_bmid_old.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ir_previous = lx_previous ).
    ENDTRY.

    sis_process_step_data-bmid = lv_bmid_old.
    LOOP AT sis_process_step_data-settl_terr ASSIGNING FIELD-SYMBOL(<ls_settl_terr>)
      WHERE item_id = siv_itemid AND data_type_qual = siv_context_seq. "AND ext_ui IS INITIAL. 25.09.2020 auskommentiert, weil die SUPER-Methode den EXT_UI schon setzt, aber nicht richtig.
      IF line_exists( sis_process_step_data-/idxgl/pod_data[ item_id = siv_itemid data_type_qual = siv_context_seq ] ).
        <ls_settl_terr>-ext_ui = sis_process_step_data-/idxgl/pod_data[ item_id = siv_itemid data_type_qual = siv_context_seq ]-ext_ui.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD settlement_unit.
***************************************************************************************************
*            _                        _____ ______
*           | |                      / ____|  ____|
*   __ _  __| | ___  ___ ___  ___   | (___ | |__
*  / _` |/ _` |/ _ \/ __/ __|/ _ \   \___ \|  __|
* | (_| | (_| |  __/\__ \__ \ (_) |  ____) | |____
*  \__,_|\__,_|\___||___/___/\___/  |_____/|______|
*
* Author: THIMEL-R                                                                Datum: 31.10.2019
*
* Beschreibung: - Übernahme vom NB (für Z29 und Z31(Tranche))
*               - Fehlende EXT_UI für die Übernahme in das IDoc ergänzen
*
***************************************************************************************************
* Wichtige / Große Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    DATA: lv_seq_action_code_src TYPE /idxgc/de_data_type_qual.

    "Bei Z01 und wenn Tranche vorhanden kein Bilanzkreis mitschicken. Der Bilanzkreis steht dann im Tranchen Segment. 25.09.2020
    IF siv_context_seq = /idxgc/if_constants_ide=>gc_seq_action_code_z01 AND
       line_exists( sit_pod_dev_relation[ pod_type = /idxgc/if_constants_add=>gc_pod_type_z70 ] ).
      RETURN.
    ENDIF.

    IF siv_data_processing_mode = /idxgc/if_constants_add=>gc_data_from_add_source.
      IF siv_context_seq = /idxgl/if_constants_ide=>gc_seq_action_code_z29.
        lv_seq_action_code_src = /idxgc/if_constants_ide=>gc_seq_action_code_z01.
      ELSEIF siv_context_seq = /idxgl/if_constants_ide=>gc_seq_action_code_z31.
        lv_seq_action_code_src = /idxgl/if_constants_ide=>gc_seq_action_code_z15.
      ELSE.
        CLEAR: lv_seq_action_code_src.
      ENDIF.
    ENDIF.

    IF lv_seq_action_code_src IS NOT INITIAL.
      LOOP AT sis_process_data_src_add-settl_unit ASSIGNING FIELD-SYMBOL(<ls_settl_unit_src_add>)
        WHERE item_id = siv_itemid AND data_type_qual = lv_seq_action_code_src.
        IF NOT line_exists( sis_process_step_data-settl_terr[ item_id = siv_itemid data_type_qual = siv_context_seq ] ).
          sis_process_step_data-settl_unit = VALUE #( BASE sis_process_step_data-settl_unit ( item_id        = siv_itemid
                                                                                              data_type_qual = siv_context_seq ) ).
        ENDIF.
        sis_process_step_data-settl_unit[ item_id = siv_itemid data_type_qual = siv_context_seq ]-ext_ui        = sis_process_step_data-ext_ui.
        sis_process_step_data-settl_unit[ item_id = siv_itemid data_type_qual = siv_context_seq ]-settlunit_ext = <ls_settl_unit_src_add>-settlunit_ext.
      ENDLOOP.
      RETURN.
    ENDIF.

    super->settlement_unit( ).

    LOOP AT sis_process_step_data-settl_unit ASSIGNING FIELD-SYMBOL(<ls_settl_unit>)
      WHERE item_id = siv_itemid AND data_type_qual = siv_context_seq AND ext_ui IS INITIAL.
      <ls_settl_unit>-ext_ui = sis_process_step_data-ext_ui.
    ENDLOOP.

  ENDMETHOD.


  METHOD temp_depend_pod_energy.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R, RIVCHIN-I                                                     Datum: 25.11.2019
*
* Beschreibung: - Übernahme vom NB
*               - z01/z29 Daten der Marktlokation der beteiligten Rolle
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************

    IF siv_data_processing_mode = /idxgc/if_constants_add=>gc_data_from_add_source AND
       siv_context_seq          = /idxgl/if_constants_ide=>gc_seq_action_code_z29.
      LOOP AT sis_process_data_src_add-pod_quant ASSIGNING FIELD-SYMBOL(<ls_pod_quant_src_add>)
        WHERE item_id = siv_itemid AND data_type_qual = /idxgc/if_constants_ide=>gc_seq_action_code_z01.
        IF NOT line_exists( sis_process_step_data-pod_quant[ item_id = siv_itemid data_type_qual = siv_context_seq ] ).
          sis_process_step_data-pod_quant = VALUE #( BASE sis_process_step_data-pod_quant ( item_id        = siv_itemid
                                                                                            data_type_qual = siv_context_seq ) ).
        ENDIF.
        sis_process_step_data-pod_quant[ item_id = siv_itemid data_type_qual = siv_context_seq ]-quant_type_qual  = <ls_pod_quant_src_add>-quant_type_qual.
      ENDLOOP.
      RETURN.
    ENDIF.

    DATA(lv_bmid_old) = sis_process_step_data-bmid.
    sis_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_es103.

    TRY.
        super->temp_depend_pod_energy( ).
      CATCH /idxgc/cx_process_error INTO DATA(lx_previous).
        sis_process_step_data-bmid = lv_bmid_old.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ir_previous = lx_previous ).
    ENDTRY.

    sis_process_step_data-bmid = lv_bmid_old.
    LOOP AT sis_process_step_data-pod_quant ASSIGNING FIELD-SYMBOL(<ls_pod_quant>)
      WHERE item_id = siv_itemid AND data_type_qual = siv_context_seq AND ext_ui IS INITIAL.
      <ls_pod_quant>-ext_ui = sis_process_step_data-ext_ui.
    ENDLOOP.

  ENDMETHOD.


  METHOD tranche_data_involved_seq.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: RIVCHIN-I                                                               Datum: 14.11.2019
*
* Beschreibung: - Neuimplementierung da im Standard nicht vorhanden (SEQ+Z31)
*               - Nur bei Einspeisung relevant.
*               - NB: Bei Einspeisern ohne DV Schrittdaten kopieren
*               - Nur übermitteln wenn es eine Tranche in der Nachricht gibt.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* THIMEL-R    01.04.2020 Prüfung ob Tranche vom NB übermittelt wurde.
***************************************************************************************************
    IF siv_sup_direct_int <> /idxgc/if_constants_add=>gc_sup_direct_feeding.
      siv_process_seq = abap_false.
      RETURN.
    ENDIF.

    IF sis_process_step_data-bmid = /adz/if_mdc_co=>gc_bmid-adz_ch186 AND gv_own_intcode = /adz/if_mdc_co=>gc_intcode-dso_01.
      sis_process_data_src_add = sis_process_step_data.
    ENDIF.

    IF NOT line_exists( sit_pod_dev_relation[ pod_type = /idxgc/if_constants_ide=>gc_pod_type_z70 ] ).
      siv_process_seq = abap_false.
      RETURN.
    ENDIF.

    siv_context_seq = /adz/if_mdc_co=>gc_seq_action_code-z31.

    DELETE sis_process_step_data-/idxgl/pod_data
      WHERE item_id = siv_itemid AND data_type_qual = siv_context_seq.

    DELETE sis_process_step_data-/idxgl/pod_ref
      WHERE item_id = siv_itemid AND data_type_qual = siv_context_seq.

    DELETE sis_process_step_data-pod_quant
      WHERE item_id = siv_itemid AND data_type_qual = siv_context_seq.

    DELETE sis_process_step_data-marketpartner_add
      WHERE item_id = siv_itemid AND data_type_qual = siv_context_seq.

    DELETE sis_process_step_data-settl_unit
      WHERE item_id = siv_itemid AND data_type_qual = siv_context_seq.

  ENDMETHOD.


  METHOD tranche_data_seq.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 01.04.2020
*
* Beschreibung: - Nur übermitteln wenn es eine Tranche in der Nachricht gibt.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************

    IF NOT line_exists( sit_pod_dev_relation[ pod_type = /idxgc/if_constants_ide=>gc_pod_type_z70 ] ).
      siv_process_seq = abap_false.
      RETURN.
    ENDIF.

    super->tranche_data_seq( ).

  ENDMETHOD.


  METHOD transaction_reason.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 13.11.2019
*
* Beschreibung: Fehler in der SAP Implementierung: Lesen aus den Quellschritten ist hier nicht
*   möglich.
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    DATA: lv_msgtransreason TYPE /idxgc/de_msgtransreason.

    super->transaction_reason( ).

    CASE siv_data_processing_mode.
      WHEN /idxgc/if_constants_add=>gc_data_from_source.
        IF line_exists( sis_process_data_src-diverse[ item_id = siv_itemid ] ).
          lv_msgtransreason = sis_process_data_src-diverse[ item_id = siv_itemid ]-msgtransreason.
        ENDIF.
      WHEN /idxgc/if_constants_add=>gc_data_from_add_source.
        IF line_exists( sis_process_data_src_add-diverse[ item_id = siv_itemid ] ).
          lv_msgtransreason = sis_process_data_src_add-diverse[ item_id = siv_itemid ]-msgtransreason.
        ENDIF.
    ENDCASE.

    IF lv_msgtransreason IS NOT INITIAL.
      IF NOT line_exists( sis_process_step_data-diverse[ item_id = siv_itemid ] ).
        sis_process_step_data-diverse = VALUE #( ( item_id = siv_itemid ) ).
      ENDIF.
      sis_process_step_data-diverse[ item_id = siv_itemid ]-msgtransreason = lv_msgtransreason.
      siv_data_not_filled = abap_false.
    ENDIF.

  ENDMETHOD.


  METHOD transaction_ref_response.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL- R                                                               Datum: 07.04.2020
*
* Beschreibung: Stammdatensynchronisation /ADZ/CH186 & EEG keine Direktvermarktung
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************

    DATA:
      ls_diverse       TYPE /idxgc/s_diverse_details,
      ls_diverse_pre   TYPE /idxgc/s_diverse_details,
      ls_process_links TYPE /idxgc/s_proc_link,
      lv_proc_ref      TYPE /idxgc/de_proc_trig_ref,
      lr_process       TYPE REF TO /idxgc/if_process,
      lr_process_data  TYPE REF TO /idxgc/if_process_data_extern,
      ls_proc_data_pre TYPE /idxgc/s_proc_data,
      ls_proc_step_pre TYPE /idxgc/s_proc_step_data.

    FIELD-SYMBOLS:
      <ls_diverse_src>     TYPE /idxgc/s_diverse_details,
      <ls_diverse_src_add> TYPE /idxgc/s_diverse_details,
      <ls_diverse>         TYPE /idxgc/s_diverse_details.

    CASE siv_data_processing_mode.
        "ToDo: TRY CATCH
      WHEN /idxgc/if_constants_add=>gc_default_processing.
        TRY.
            IF sis_process_step_data-bmid = /adz/if_mdc_co=>gc_bmid-adz_ch186 AND
               /adz/cl_mdc_utility=>is_feeding_no_direct_marketing( iv_int_ui = sis_process_step_data-int_ui iv_keydate = sis_process_step_data-proc_date ).

              IF line_exists( sis_process_step_data-diverse[ item_id = siv_itemid ] ).
                sis_process_step_data-diverse[ item_id = siv_itemid ]-refnr_transreq = sis_process_step_data-diverse[ item_id = siv_itemid ]-transaction_no.
              ENDIF.
            ENDIF.
          CATCH /idxgc/cx_general.
            "Auf Fehler wird unten geprüft.
        ENDTRY.
    ENDCASE.

    super->transaction_ref_response( ).

* Check whether Mandatory fields are filled
    READ TABLE sis_process_step_data-diverse ASSIGNING <ls_diverse> INDEX 1.
    IF <ls_diverse> IS NOT ASSIGNED
    OR <ls_diverse>-refnr_transreq IS INITIAL.
      siv_data_not_filled = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD transformation.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: RIVCHIN-I                                                               Datum: 21.11.2019
*
* Beschreibung: - Übernahme vom NB für Z01 und Z29
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* THIMEL-R    30.04.2020 Daten aus (zus.) Quellschritt lesen weil im SAP-Standard hier noch eine
*                        Abfrage davor ist und die Daten dann nicht immer übernommen werden.
* THIMEL-R    25.05.2020 ZP-Referenz wird bei Einspeisern falsch gesetzt -> entfernt
***************************************************************************************************

    IF siv_data_processing_mode = /idxgc/if_constants_add=>gc_data_from_add_source AND
       ( siv_context_seq        = /idxgc/if_constants_ide=>gc_seq_action_code_z01 OR "Auch für Z01, weil der SAP-Standard noch eine Prüfung vorgeschaltet hat.
         siv_context_seq        = /idxgl/if_constants_ide=>gc_seq_action_code_z29 ).
      LOOP AT sis_process_data_src_add-/idxgl/pod_data ASSIGNING FIELD-SYMBOL(<ls_pod_data_src_add>)
        WHERE item_id = siv_itemid AND data_type_qual = /idxgc/if_constants_ide=>gc_seq_action_code_z01.
        IF line_exists( sis_process_step_data-/idxgl/pod_data[ item_id = siv_itemid data_type_qual = siv_context_seq ] ).
          sis_process_step_data-/idxgl/pod_data[ item_id = siv_itemid data_type_qual = siv_context_seq ]-transformation = <ls_pod_data_src_add>-transformation.
        ENDIF.
      ENDLOOP.
      RETURN.
    ENDIF.

    super->transformation( ).

  ENDMETHOD.


  METHOD use_from_date_time.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                               Datum: 01.10.2019
*
* Beschreibung: Stammdatensynchronisation - Verwendung der Daten ab
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    CASE siv_data_processing_mode.
      WHEN /idxgc/if_constants_add=>gc_data_from_source
        OR /idxgc/if_constants_add=>gc_default_processing.
        IF line_exists( sis_process_data_src-diverse[ item_id = siv_itemid ] ).
          IF line_exists( sis_process_step_data-diverse[ item_id = siv_itemid ] ).
            sis_process_step_data-diverse[ item_id = siv_itemid ]-use_from_date = sis_process_data_src-diverse[ item_id = siv_itemid ]-use_from_date.
            sis_process_step_data-diverse[ item_id = siv_itemid ]-use_from_time = sis_process_data_src-diverse[ item_id = siv_itemid ]-use_from_time.
          ELSE.
            sis_process_step_data-diverse[ item_id = siv_itemid ] = VALUE #( item_id       = siv_itemid
                                                                             use_from_date = sis_process_data_src-diverse[ item_id = siv_itemid ]-use_from_date
                                                                             use_from_time = sis_process_data_src-diverse[ item_id = siv_itemid ]-use_from_time ).
          ENDIF.
        ENDIF.
      WHEN /idxgc/if_constants_add=>gc_data_from_add_source.
        IF line_exists( sis_process_data_src_add-diverse[ item_id = siv_itemid ] ).
          IF line_exists( sis_process_step_data-diverse[ item_id = siv_itemid ] ).
            sis_process_step_data-diverse[ item_id = siv_itemid ]-use_from_date = sis_process_data_src_add-diverse[ item_id = siv_itemid ]-use_from_date.
            sis_process_step_data-diverse[ item_id = siv_itemid ]-use_from_time = sis_process_data_src_add-diverse[ item_id = siv_itemid ]-use_from_time.
          ELSE.
            sis_process_step_data-diverse[ item_id = siv_itemid ] = VALUE #( item_id       = siv_itemid
                                                                             use_from_date = sis_process_data_src_add-diverse[ item_id = siv_itemid ]-use_from_date
                                                                             use_from_time = sis_process_data_src_add-diverse[ item_id = siv_itemid ]-use_from_time ).
          ENDIF.
        ENDIF.

    ENDCASE.

    IF line_exists( sis_process_data_src_add-diverse[ item_id = siv_itemid ] ).
      "Zeit nicht prüfen, weil diese Null sein kann.
      IF sis_process_data_src_add-diverse[ item_id = siv_itemid ]-use_from_date IS INITIAL.
        siv_data_not_filled = abap_true.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD use_to_date_time.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                               Datum: 01.10.2019
*
* Beschreibung: Stammdatensynchronisation - Verwendung der Daten bis
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    CASE siv_data_processing_mode.
      WHEN /idxgc/if_constants_add=>gc_data_from_source
        OR /idxgc/if_constants_add=>gc_default_processing.
        IF line_exists( sis_process_data_src-diverse[ item_id = siv_itemid ] ).
          IF line_exists( sis_process_step_data-diverse[ item_id = siv_itemid ] ).
            sis_process_step_data-diverse[ item_id = siv_itemid ]-use_to_date = sis_process_data_src-diverse[ item_id = siv_itemid ]-use_to_date.
            sis_process_step_data-diverse[ item_id = siv_itemid ]-use_to_time = sis_process_data_src-diverse[ item_id = siv_itemid ]-use_to_time.
          ELSE.
            sis_process_step_data-diverse[ item_id = siv_itemid ] = VALUE #( item_id       = siv_itemid
                                                                             use_to_date = sis_process_data_src-diverse[ item_id = siv_itemid ]-use_to_date
                                                                             use_to_time = sis_process_data_src-diverse[ item_id = siv_itemid ]-use_to_time ).
          ENDIF.
        ENDIF.
      WHEN /idxgc/if_constants_add=>gc_data_from_add_source.
        IF line_exists( sis_process_data_src_add-diverse[ item_id = siv_itemid ] ).
          IF line_exists( sis_process_step_data-diverse[ item_id = siv_itemid ] ).
            sis_process_step_data-diverse[ item_id = siv_itemid ]-use_to_date = sis_process_data_src_add-diverse[ item_id = siv_itemid ]-use_to_date.
            sis_process_step_data-diverse[ item_id = siv_itemid ]-use_to_time = sis_process_data_src_add-diverse[ item_id = siv_itemid ]-use_to_time.
          ELSE.
            sis_process_step_data-diverse[ item_id = siv_itemid ] = VALUE #( item_id       = siv_itemid
                                                                             use_to_date = sis_process_data_src_add-diverse[ item_id = siv_itemid ]-use_to_date
                                                                             use_to_time = sis_process_data_src_add-diverse[ item_id = siv_itemid ]-use_to_time ).
          ENDIF.
        ENDIF.

    ENDCASE.

    IF line_exists( sis_process_data_src_add-diverse[ item_id = siv_itemid ] ).
      "Zeit nicht prüfen, weil diese Null sein kann.
      IF sis_process_data_src_add-diverse[ item_id = siv_itemid ]-use_to_date IS INITIAL.
        siv_data_not_filled = abap_true.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD voltage_level.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: RIVCHIN-I                                                               Datum: 21.11.2019
*
* Beschreibung: - Übernahme vom NB
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* THIMEL-R    25.05.2020 ZP-Referenz wird bei Einspeisern falsch gesetzt -> entfernt
***************************************************************************************************
    IF siv_data_processing_mode = /idxgc/if_constants_add=>gc_data_from_add_source AND
       siv_context_seq          = /idxgl/if_constants_ide=>gc_seq_action_code_z29.
      LOOP AT sis_process_data_src_add-/idxgl/pod_data ASSIGNING FIELD-SYMBOL(<ls_pod_data_src_add>)
        WHERE item_id = siv_itemid AND data_type_qual = /idxgc/if_constants_ide=>gc_seq_action_code_z01.
        IF line_exists( sis_process_step_data-/idxgl/pod_data[ item_id = siv_itemid data_type_qual = siv_context_seq ] ).
          sis_process_step_data-/idxgl/pod_data[ item_id = siv_itemid data_type_qual = siv_context_seq ]-volt_level = <ls_pod_data_src_add>-volt_level.
        ENDIF.
      ENDLOOP.
      RETURN.
    ENDIF.

    super->voltage_level( ).

  ENDMETHOD.


  METHOD yearly_consumption_forecast.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R, RIVCHIN-I                                                     Datum: 26.10.2019
*
* Beschreibung: - Übernahme vom NB
*               - Analog zu ES103 Daten ermitteln
*               - Fehlende EXT_UI für die Übernahme in das IDoc ergänzen
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************

    IF siv_data_processing_mode = /idxgc/if_constants_add=>gc_data_from_add_source AND
       siv_context_seq          = /idxgl/if_constants_ide=>gc_seq_action_code_z29.
      LOOP AT sis_process_data_src_add-pod_quant ASSIGNING FIELD-SYMBOL(<ls_pod_quant_arc_add>)
        WHERE item_id = siv_itemid AND data_type_qual = /idxgc/if_constants_ide=>gc_seq_action_code_z01.
        IF NOT line_exists( sis_process_step_data-pod_quant[ item_id = siv_itemid data_type_qual = siv_context_seq ] ).
          sis_process_step_data-pod_quant = VALUE #( BASE sis_process_step_data-pod_quant ( item_id        = siv_itemid
                                                                                            data_type_qual = siv_context_seq ) ).
        ENDIF.
        sis_process_step_data-pod_quant[ item_id = siv_itemid data_type_qual = siv_context_seq ]-ext_ui           = <ls_pod_quant_arc_add>-ext_ui.
        sis_process_step_data-pod_quant[ item_id = siv_itemid data_type_qual = siv_context_seq ]-quant_type_qual  = <ls_pod_quant_arc_add>-quant_type_qual.
        sis_process_step_data-pod_quant[ item_id = siv_itemid data_type_qual = siv_context_seq ]-quantitiy_ext    = <ls_pod_quant_arc_add>-quantitiy_ext.
        sis_process_step_data-pod_quant[ item_id = siv_itemid data_type_qual = siv_context_seq ]-measure_unit_ext = <ls_pod_quant_arc_add>-measure_unit_ext.
        sis_process_step_data-pod_quant[ item_id = siv_itemid data_type_qual = siv_context_seq ]-measure_unit_int = <ls_pod_quant_arc_add>-measure_unit_int.
      ENDLOOP.
      RETURN.
    ENDIF.

    DATA(lv_bmid_old) = sis_process_step_data-bmid.
    sis_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_es103.

    TRY.
        super->yearly_consumption_forecast( ).
      CATCH /idxgc/cx_process_error INTO DATA(lx_previous).
        sis_process_step_data-bmid = lv_bmid_old.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ir_previous = lx_previous ).
    ENDTRY.

    sis_process_step_data-bmid = lv_bmid_old.
    LOOP AT sis_process_step_data-pod_quant ASSIGNING FIELD-SYMBOL(<ls_pod_quant>)
      WHERE item_id = siv_itemid AND data_type_qual = siv_context_seq AND ext_ui IS INITIAL.
      <ls_pod_quant>-ext_ui = sis_process_step_data-ext_ui.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
