INTERFACE /adz/if_mdc_co
  PUBLIC .


  CONSTANTS:
    BEGIN OF gc_amid,
      id_11185 TYPE /idxgc/de_amid VALUE '11185',
      id_11186 TYPE /idxgc/de_amid VALUE '11186',
      id_11187 TYPE /idxgc/de_amid VALUE '11187',
      id_11188 TYPE /idxgc/de_amid VALUE '11188',
      id_11189 TYPE /idxgc/de_amid VALUE '11189',
      id_11190 TYPE /idxgc/de_amid VALUE '11190',
    END OF gc_amid,
    BEGIN OF gc_bmid,
      adz_ch185 TYPE /idxgc/de_bmid VALUE '/ADZ/CH185',
      adz_ch186 TYPE /idxgc/de_bmid VALUE '/ADZ/CH186',
      adz_ch187 TYPE /idxgc/de_bmid VALUE '/ADZ/CH187',
      adz_ch188 TYPE /idxgc/de_bmid VALUE '/ADZ/CH188',
      adz_ch189 TYPE /idxgc/de_bmid VALUE '/ADZ/CH189',
      adz_ch190 TYPE /idxgc/de_bmid VALUE '/ADZ/CH190',
      ch181     TYPE /idxgc/de_bmid VALUE 'CH181',
      ch141     TYPE /idxgc/de_bmid VALUE 'CH141',
      ch111     TYPE /idxgc/de_bmid VALUE 'CH111',
      ch112     TYPE /idxgc/de_bmid VALUE 'CH112',
      ch131     TYPE /idxgc/de_bmid VALUE 'CH131',
      zch01     TYPE /idxgc/de_bmid VALUE 'ZCH01',
    END OF gc_bmid,
    BEGIN OF gc_cr,
      auto                    TYPE /idxgc/de_check_result VALUE 'AUTO',
      auto_reject             TYPE /idxgc/de_check_result VALUE 'AUTO_REJECT',
      difference_found        TYPE /idxgc/de_check_result VALUE 'DIFFERENCE_FOUND',
      distribution_needed     TYPE /idxgc/de_check_result VALUE 'DISTRIBUTION_NEEDED',
      distribution_not_needed TYPE /idxgc/de_check_result VALUE 'DISTRIBUTION_NOT_NEEDED',
      forward                 TYPE /idxgc/de_check_result VALUE 'FORWARD',
      notification_period_ok  TYPE /idxgc/de_check_result VALUE 'NOTIFICATION_PERIOD_OK',
      no_accept               TYPE /idxgc/de_check_result VALUE 'NO_ACCEPT',
      no_difference_found     TYPE /idxgc/de_check_result VALUE 'NO_DIFFERENCE_FOUND',
      no_forward              TYPE /idxgc/de_check_result VALUE 'NO_FORWARD',
      no_wait                 TYPE /idxgc/de_check_result VALUE 'NO_WAIT',
      manual                  TYPE /idxgc/de_check_result VALUE 'MANUAL',
      mdc_sync_necessary      TYPE /idxgc/de_check_result VALUE 'MDC_SYNC_NECESSARY',
      mdc_sync_not_necessary  TYPE /idxgc/de_check_result VALUE 'MDC_SYNC_NOT_NECESSARY',
      meter_proc_equal        TYPE /idxgc/de_check_result VALUE 'METER_PROC_EQUAL',
      meter_proc_unequal      TYPE /idxgc/de_check_result VALUE 'METER_PROC_UNEQUAL',
      pod_type_equal          TYPE /idxgc/de_check_result VALUE 'POD_TYPE_EQUAL',
      pod_type_unequal        TYPE /idxgc/de_check_result VALUE 'POD_TYPE_UNEQUAL',
      receiver_updated        TYPE /idxgc/de_check_result VALUE 'RECEIVER_UPDATED',
      receiver_not_updated    TYPE /idxgc/de_check_result VALUE 'RECEIVER_NOT_UPDATED',
      response_code_not_set   TYPE /idxgc/de_check_result VALUE 'RESPONSE_CODE_NOT_SET',
      response_code_set       TYPE /idxgc/de_check_result VALUE 'RESPONSE_CODE_SET',
      send_valid_data         TYPE /idxgc/de_check_result VALUE 'SEND_VALID_DATA',
      transaction_allowed     TYPE /idxgc/de_check_result VALUE 'TRANSACTION_ALLOWED',
      transaction_not_allowed TYPE /idxgc/de_check_result VALUE 'TRANSACTION_NOT_ALLOWED',
      wait                    TYPE /idxgc/de_check_result VALUE 'WAIT',
    END OF gc_cr,
    BEGIN OF gc_data_use,
      zb5 TYPE /idxgl/de_data_use VALUE 'ZB5',
    END OF gc_data_use .
  CONSTANTS gc_dexbasicproc_mdc_dummy TYPE e_dexbasicproc VALUE 'ADESSO_MDC' ##NO_TEXT.
  CONSTANTS gc_edifact_nad_ud_c059ff TYPE /idxgc/de_edifact_str VALUE 'UTILMD_SG12_NAD+UD_C059FF.' ##NO_TEXT.
  CONSTANTS gc_edifact_nad_ud_c080 TYPE /idxgc/de_edifact_str VALUE 'UTILMD_SG12_NAD+UD_C080' ##NO_TEXT.
  CONSTANTS gc_edifact_nad_z04_c059ff TYPE /idxgc/de_edifact_str VALUE 'UTILMD_SG12_NAD+Z04_C059FF.' ##NO_TEXT.
  CONSTANTS gc_edifact_nad_z05 TYPE /idxgc/de_edifact_str VALUE 'UTILMD_SG12_NAD+Z05' ##NO_TEXT.
  CONSTANTS gc_edifact_sg8_seq_z02 TYPE /idxgc/de_edifact_str VALUE 'UTILMD_SG8_SEQ+Z02' ##NO_TEXT.
  CONSTANTS gc_edifact_sg8_seq_z07 TYPE /idxgc/de_edifact_str VALUE 'UTILMD_SG8_SEQ+Z07' ##NO_TEXT.
  CONSTANTS gc_edifact_sg8_seq_z10 TYPE /idxgc/de_edifact_str VALUE 'UTILMD_SG8_SEQ+Z10' ##NO_TEXT.
  CONSTANTS gc_fieldname_assoc_servprov TYPE fieldname VALUE 'ASSOC_SERVPROV' ##NO_TEXT.
  CONSTANTS gc_fieldname_cityname TYPE fieldname VALUE 'CITYNAME' ##NO_TEXT.
  CONSTANTS gc_fieldname_contr_start_date TYPE fieldname VALUE 'CONTR_START_DATE' ##NO_TEXT.
  CONSTANTS gc_fieldname_countrycode TYPE fieldname VALUE 'COUNTRYCODE' ##NO_TEXT.
  CONSTANTS gc_fieldname_datefrom TYPE fieldname VALUE 'DATEFROM' ##NO_TEXT.
  CONSTANTS gc_fieldname_district TYPE fieldname VALUE 'DISTRICT' ##NO_TEXT.
  CONSTANTS gc_fieldname_ext_ui TYPE fieldname VALUE 'EXT_UI' ##NO_TEXT.
  CONSTANTS gc_fieldname_fam_comp_name1 TYPE fieldname VALUE 'FAM_COMP_NAME1' ##NO_TEXT.
  CONSTANTS gc_fieldname_fam_comp_name2 TYPE fieldname VALUE 'FAM_COMP_NAME2' ##NO_TEXT.
  CONSTANTS gc_fieldname_first_name TYPE fieldname VALUE 'FIRST_NAME' ##NO_TEXT.
  CONSTANTS gc_fieldname_first_name1 TYPE fieldname VALUE 'FIRST_NAME1' ##NO_TEXT.
  CONSTANTS gc_fieldname_first_name2 TYPE fieldname VALUE 'FIRST_NAME2' ##NO_TEXT.
  CONSTANTS gc_fieldname_franchise_fee TYPE fieldname VALUE 'FRANCHISE_FEE' ##NO_TEXT.
  CONSTANTS gc_fieldname_houseid TYPE fieldname VALUE 'HOUSEID' ##NO_TEXT.
  CONSTANTS gc_fieldname_houseid_add TYPE fieldname VALUE 'HOUSEID_ADD' ##NO_TEXT.
  CONSTANTS gc_fieldname_houseid_compl TYPE fieldname VALUE 'HOUSEID_COMPL' ##NO_TEXT.
  CONSTANTS gc_fieldname_int_ui TYPE fieldname VALUE 'INT_UI' ##NO_TEXT.
  CONSTANTS gc_fieldname_keydate TYPE fieldname VALUE 'KEYDATE' ##NO_TEXT.
  CONSTANTS gc_fieldname_msgtransreason TYPE fieldname VALUE 'MSGTRANSREASON' ##NO_TEXT.
  CONSTANTS gc_fieldname_own_servprov TYPE fieldname VALUE 'OWN_SERVPROV' ##NO_TEXT.
  CONSTANTS gc_fieldname_poboxid TYPE fieldname VALUE 'POBOXID' ##NO_TEXT.
  CONSTANTS gc_fieldname_postalcode TYPE fieldname VALUE 'POSTALCODE' ##NO_TEXT.
  CONSTANTS gc_fieldname_press_level_offt TYPE fieldname VALUE 'PRESS_LEVEL_OFFT' ##NO_TEXT.
  CONSTANTS gc_fieldname_proc_ref TYPE fieldname VALUE 'PROC_REF' ##NO_TEXT.
  CONSTANTS gc_fieldname_proc_status_txt TYPE fieldname VALUE 'PROC_STATUS_TXT' ##NO_TEXT.
  CONSTANTS gc_fieldname_quantitiy_ext TYPE fieldname VALUE 'QUANTITIY_EXT' ##NO_TEXT.
  CONSTANTS gc_fieldname_serv_start_date TYPE fieldname VALUE 'SERV_START_DATE' ##NO_TEXT.
  CONSTANTS gc_fieldname_streetname TYPE fieldname VALUE 'STREETNAME' ##NO_TEXT.
  CONSTANTS gc_fieldname_trans_servprov TYPE fieldname VALUE 'TRANS_SERVPROV' ##NO_TEXT.
  CONSTANTS gc_fieldname_use_from_date TYPE fieldname VALUE 'USE_FROM_DATE' ##NO_TEXT.
  CONSTANTS gc_fieldname_use_from_time TYPE fieldname VALUE 'USE_FROM_TIME' ##NO_TEXT.
  CONSTANTS gc_fieldname_use_to_date TYPE fieldname VALUE 'USE_TO_DATE' ##NO_TEXT.
  CONSTANTS gc_fieldname_use_to_time TYPE fieldname VALUE 'USE_TO_TIME' ##NO_TEXT.
  CONSTANTS gc_fieldname_validstart_date TYPE fieldname VALUE 'VALIDSTART_DATE' ##NO_TEXT.
  CONSTANTS gc_fieldname_volt_level_meas TYPE fieldname VALUE 'VOLT_LEVEL_MEAS' ##NO_TEXT.
  CONSTANTS:
    BEGIN OF gc_forecast_basis,
      za6 TYPE /idxgl/de_forecast_basis VALUE 'ZA6',
      zc0 TYPE /idxgl/de_forecast_basis VALUE 'ZC0',
    END OF gc_forecast_basis,
    BEGIN  OF gc_intcode,
      dso_01 TYPE intcode VALUE '01',
      sup_02 TYPE intcode VALUE '02',
      stc_04 TYPE intcode VALUE '04',
      mso_m1 TYPE intcode VALUE 'M1',
      tso_t1 TYPE intcode VALUE 'T1',
    END OF gc_intcode,
    BEGIN OF gc_mp_group_type,
      include TYPE /adz/de_mdc_mp_group_type VALUE 'I',
      exclude TYPE /adz/de_mdc_mp_group_type VALUE 'E',
    END OF gc_mp_group_type,
    BEGIN OF gc_msgtransreason,
      zp0 TYPE /idxgc/de_msgtransreason VALUE 'ZP0',
      zp1 TYPE /idxgc/de_msgtransreason VALUE 'ZP1',
      zp2 TYPE /idxgc/de_msgtransreason VALUE 'ZP2',
      ze7 TYPE /idxgc/de_msgtransreason VALUE 'ZE7',
      zi8 TYPE /idxgc/de_msgtransreason VALUE 'ZI8',
      zf0 TYPE /idxgc/de_msgtransreason VALUE 'ZF0',
      e03 TYPE /idxgc/de_msgtransreason VALUE 'E03',
    END OF gc_msgtransreason,
    BEGIN OF gc_msg_category,
      z38 TYPE /idxgc/de_docname_code VALUE 'Z38',
    END OF gc_msg_category,
    BEGIN OF gc_nr_range_object,
      adz_prseq TYPE nrobj VALUE '/ADZ/PRSEQ',
    END OF gc_nr_range_object .
  CONSTANTS gc_okcode_send TYPE cua_code VALUE 'SEND' ##NO_TEXT.
  CONSTANTS:
    BEGIN OF gc_proc_id,
      mdc_send_res_8030  TYPE /idxgc/de_proc_id VALUE '8030',
      mdc_send_ath_8031  TYPE /idxgc/de_proc_id VALUE '8031',
      mdc_rec_res_8032   TYPE /idxgc/de_proc_id VALUE '8032',
      mdc_rec_ath_8033   TYPE /idxgc/de_proc_id VALUE '8033',
      mdc_rec_fwd_8034   TYPE /idxgc/de_proc_id VALUE '8034',
      mdc_sy_dso_adz8035 TYPE /idxgc/de_proc_id VALUE '/ADZ/8035',
      mdc_sy_sup_adz8036 TYPE /idxgc/de_proc_id VALUE '/ADZ/8036',
      sos_1012           TYPE /idxgc/de_proc_id VALUE '1012',
      sbs_1041           TYPE /idxgc/de_proc_id VALUE '1041',
    END OF gc_proc_id,
    BEGIN OF gc_proc_step_status,
      completed_001 TYPE /idxgc/de_proc_step_status VALUE '001',
    END OF gc_proc_step_status.
  CONSTANTS gc_proc_type_21 TYPE /idxgc/de_proc_type VALUE '21' ##NO_TEXT.
  CONSTANTS gc_proc_view_04 TYPE /idxgc/de_proc_view VALUE '04' ##NO_TEXT.
  CONSTANTS:
    BEGIN OF gc_rel_type,
      dso_tranche_1000 TYPE /idxgc/de_rel_type VALUE '1000',
      sup_tranche_2000 TYPE /idxgc/de_rel_type VALUE '2000',
      mema             TYPE /idxgc/de_rel_type VALUE 'MEMA',
    END OF gc_rel_type,
    BEGIN OF gc_resp_market_role,
      za8 TYPE char3 VALUE 'ZA8',
      za9 TYPE char3 VALUE 'ZA9',
      zb7 TYPE char3 VALUE 'ZB7',
    END OF gc_resp_market_role,
    BEGIN OF gc_seq_action_code,
      z01 TYPE char3 VALUE 'Z01',
      z08 TYPE char3 VALUE 'Z08',
      z10 TYPE char3 VALUE 'Z10',
      z15 TYPE char3 VALUE 'Z15',
      z18 TYPE char3 VALUE 'Z18',
      z29 TYPE char3 VALUE 'Z29',
      z30 TYPE char3 VALUE 'Z30',
      z31 TYPE char3 VALUE 'Z31',
      z32 TYPE char3 VALUE 'Z32',
      z33 TYPE char3 VALUE 'Z33',
      z34 TYPE char3 VALUE 'Z34',
      z89 TYPE char3 VALUE 'Z89',
      z90 TYPE char3 VALUE 'Z90',
      z91 TYPE char3 VALUE 'Z91',
    END OF gc_seq_action_code .
  CONSTANTS gc_structure_req TYPE tabname VALUE '/ADZ/S_MDC_REQ' ##NO_TEXT.
  CONSTANTS gc_swt_period_type_adzmdc_h02 TYPE e_ideswttimetype VALUE '/ADZ/MDC_H02' ##NO_TEXT.
  CONSTANTS gc_swt_period_type_adzmdc_s02 TYPE e_ideswttimetype VALUE '/ADZ/MDC_S02' ##NO_TEXT.
  CONSTANTS gc_swt_period_type_adzmdc_s03 TYPE e_ideswttimetype VALUE '/ADZ/MDC_S03' ##NO_TEXT.
  CONSTANTS:
    BEGIN OF gc_uistrutyp,
      ma TYPE euistrutyp VALUE 'MA',
      me TYPE euistrutyp VALUE 'ME',
    END OF gc_uistrutyp,
    BEGIN OF gc_msg_resp,
      e14 TYPE /idxgc/de_respstatus VALUE 'E14', " Ablehnung Sonstiges
      e62 TYPE /idxgc/de_respstatus VALUE 'E62', " Ablehnung (OBIS nicht passend)
      z58 TYPE /idxgc/de_respstatus VALUE 'Z58', " Ablehnung (Bilanzierungsgebiet nicht gültig)
      z60 TYPE /idxgc/de_respstatus VALUE 'Z60', " Ablehnung (Regelzone falsch)
      zj5 TYPE /idxgc/de_respstatus VALUE 'ZJ5', " Lieferrichtung steht im Widerspruch zur gemeldeten Marktlokation
      zm4 TYPE /idxgc/de_respstatus VALUE 'ZM4', " Bilanzierungsverfahren nicht gültig
      zm5 TYPE /idxgc/de_respstatus VALUE 'ZM5', " Bilanzkreis nicht gültig
      zn3 TYPE /idxgc/de_respstatus VALUE 'ZN3', " Netzbetreiber nicht gültig
      zn4 TYPE /idxgc/de_respstatus VALUE 'ZN4', " Normiertes Profil liegt nicht vor
      zn9 TYPE /idxgc/de_respstatus VALUE 'ZN9', " ZRT nicht passend
      zo1 TYPE /idxgc/de_respstatus VALUE 'ZO1', " Zuordnung der Datenaggregation liegt bereits vor
      zo5 TYPE /idxgc/de_respstatus VALUE 'ZO5', " Stammdaten wurden übernommen
      zq0 TYPE /idxgc/de_respstatus VALUE 'ZQ0', " LF im Vorgang weicht vom Absender ab
      zq1 TYPE /idxgc/de_respstatus VALUE 'ZQ1', " Falscher Aggregationsverantwortlicher
      zq2 TYPE /idxgc/de_respstatus VALUE 'ZQ2', " Unpassende Prognosegrundlage
      a13 TYPE /idxgc/de_respstatus VALUE 'A13', " Stammdaten wurden widerspruchsfrei übernommen
    END OF gc_msg_resp .
ENDINTERFACE.
