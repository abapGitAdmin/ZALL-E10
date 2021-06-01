interface /ADZ/IF_BDR_CO
  public .


  constants GC_AMID_17111 type /IDXGC/DE_AMID value '17111' ##NO_TEXT.
  constants GC_AMID_17112 type /IDXGC/DE_AMID value '17112' ##NO_TEXT.
  constants GC_AMID_17113 type /IDXGC/DE_AMID value '17113' ##NO_TEXT.
  constants GC_AMID_19111 type /IDXGC/DE_AMID value '19111' ##NO_TEXT.
  constants GC_AMID_19112 type /IDXGC/DE_AMID value '19112' ##NO_TEXT.
  constants GC_AMID_19113 type /IDXGC/DE_AMID value '19113' ##NO_TEXT.
  constants GC_AMID_19114 type /IDXGC/DE_AMID value '19114' ##NO_TEXT.
  constants GC_APPL_INTERRUPT_Z62 type /IDXGC/DE_APPL_INTERRUPT value 'Z62' ##NO_TEXT.
  constants GC_APPL_INTERRUPT_Z63 type /IDXGC/DE_APPL_INTERRUPT value 'Z63' ##NO_TEXT.
  constants:
    BEGIN OF gc_bmid,
      ord_sc_101 TYPE /idxgc/de_bmid VALUE 'ORD_SC_101',
      ord_sc_102 TYPE /idxgc/de_bmid VALUE 'ORD_SC_102',
      ord_sc_103 TYPE /idxgc/de_bmid VALUE 'ORD_SC_103',
      ord_sc_201 TYPE /idxgc/de_bmid VALUE 'ORD_SC_201',
      ord_sc_202 TYPE /idxgc/de_bmid VALUE 'ORD_SC_202',
    END OF gc_bmid .
  constants GC_BMID_ADZCD022 type /IDXGC/DE_BMID value '/ADZ/CD022' ##NO_TEXT.
  constants GC_BMID_ADZIF001 type /IDXGC/DE_BMID value '/ADZ/IF001' ##NO_TEXT.
  constants GC_CONS_TYPE_Z64 type /IDXGC/DE_CONS_TYPE value 'Z64' ##NO_TEXT.
  constants GC_CONS_TYPE_Z65 type /IDXGC/DE_CONS_TYPE value 'Z65' ##NO_TEXT.
  constants GC_CONS_TYPE_Z66 type /IDXGC/DE_CONS_TYPE value 'Z66' ##NO_TEXT.
  constants GC_CONS_TYPE_Z87 type /IDXGC/DE_CONS_TYPE value 'Z87' ##NO_TEXT.
  constants GC_CONS_TYPE_ZA8 type /IDXGC/DE_CONS_TYPE value 'ZA8' ##NO_TEXT.
  constants GC_CONS_TYPE_ZB3 type /IDXGC/DE_CONS_TYPE value 'ZB3' ##NO_TEXT.
  constants GC_CR_ACCEPETED type /IDXGC/DE_CHECK_RESULT value 'ACCEPTED' ##NO_TEXT.
  constants GC_CR_DEADLINE_NOT_MET type /IDXGC/DE_CHECK_RESULT value 'DEADLINE_NOT_MET' ##NO_TEXT.
  constants GC_CR_DEV_CONF_PROC_NOT_NEEDED type /IDXGC/DE_CHECK_RESULT value 'DEV_CONF_PROC_NOT_NEEDED' ##NO_TEXT.
  constants GC_CR_DEV_CONF_PROC_START type /IDXGC/DE_CHECK_RESULT value 'DEV_CONF_PROC_START' ##NO_TEXT.
  constants GC_CR_FOREIGN_MOS_FOUND type /IDXGC/DE_CHECK_RESULT value 'FOREIGN_MOS_FOUND' ##NO_TEXT.
  constants GC_CR_FOREIGN_MOS_NOT_FOUND type /IDXGC/DE_CHECK_RESULT value 'FOREIGN_MOS_NOT_FOUND' ##NO_TEXT.
  constants GC_CR_IN_TIME type /IDXGC/DE_CHECK_RESULT value 'IN_TIME' ##NO_TEXT.
  constants GC_CR_OWN_MOS type /IDXGC/DE_CHECK_RESULT value 'OWN_MOS' ##NO_TEXT.
  constants GC_CR_REJECTED type /IDXGC/DE_CHECK_RESULT value 'REJECTED' ##NO_TEXT.
  constants GC_CR_SEND_IFTSTA type /IDXGC/DE_CHECK_RESULT value 'SEND_IFTSTA' ##NO_TEXT.
  constants GC_CR_USER_DECISION type /IDXGC/DE_CHECK_RESULT value 'USER_DECISION' ##NO_TEXT.
  constants GC_DIVISION_CAT_01 type SPARTYP value '01' ##NO_TEXT.
  constants GC_DIVISION_CAT_02 type SPARTYP value '02' ##NO_TEXT.
  constants GC_EUISTRUTYP_MA type EUISTRUTYP value 'MA' ##NO_TEXT.
  constants GC_EUISTRUTYP_ME type EUISTRUTYP value 'ME' ##NO_TEXT.
  constants GC_FIELDNAME_APPL_INTERRUPT type FIELDNAME value 'APPL_INTERRUPT' ##NO_TEXT.
  constants GC_FIELDNAME_BDR_PDOC_CREATE type FIELDNAME value '/ADZ/BDR_PDOC_CREATE' ##NO_TEXT.
  constants GC_FIELDNAME_CONS_TYPE type FIELDNAME value 'CONS_TYPE' ##NO_TEXT.
  constants GC_FIELDNAME_DEVICE_CONF type FIELDNAME value 'DEVICE_CONF' ##NO_TEXT.
  constants GC_FIELDNAME_END_READ_DATE type FIELDNAME value 'END_READ_DATE' ##NO_TEXT.
  constants GC_FIELDNAME_END_READ_OFFS type FIELDNAME value 'END_READ_OFFS' ##NO_TEXT.
  constants GC_FIELDNAME_END_READ_TIME type FIELDNAME value 'END_READ_TIME' ##NO_TEXT.
  constants GC_FIELDNAME_EXECUTION_DATE type FIELDNAME value 'EXECUTION_DATE' ##NO_TEXT.
  constants GC_FIELDNAME_FREE_TEXT_VALUE type FIELDNAME value 'FREE_TEXT_VALUE' ##NO_TEXT.
  constants GC_FIELDNAME_HEAT_CONSUMPT type FIELDNAME value 'HEAT_CONSUMPT' ##NO_TEXT.
  constants GC_FIELDNAME_IMS_DEV_CONF type FIELDNAME value 'IMS_DEV_CONF' ##NO_TEXT.
  constants GC_FIELDNAME_INT_UI type FIELDNAME value 'INT_UI' ##NO_TEXT.
  constants GC_FIELDNAME_KENNZIFF type FIELDNAME value 'KENNZIFF' ##NO_TEXT.
  constants GC_FIELDNAME_REF_MSG_DATE type FIELDNAME value 'REF_MSG_DATE' ##NO_TEXT.
  constants GC_FIELDNAME_REF_MSG_TIME type FIELDNAME value 'REF_MSG_TIME' ##NO_TEXT.
  constants GC_FIELDNAME_REF_NO type FIELDNAME value 'REF_NO' ##NO_TEXT.
  constants GC_FIELDNAME_REG_CODE type FIELDNAME value 'REG_CODE' ##NO_TEXT.
  constants GC_FIELDNAME_SETTL_PROC type FIELDNAME value 'SETTL_PROC' ##NO_TEXT.
  constants GC_FIELDNAME_START_READ_DATE type FIELDNAME value 'START_READ_DATE' ##NO_TEXT.
  constants GC_FIELDNAME_START_READ_OFFS type FIELDNAME value 'START_READ_OFFS' ##NO_TEXT.
  constants GC_FIELDNAME_START_READ_TIME type FIELDNAME value 'START_READ_TIME' ##NO_TEXT.
  constants GC_FIELDNAME_TARIF_ALLOC type FIELDNAME value 'TARIF_ALLOC' ##NO_TEXT.
  constants GC_FIELDNAME_TEXT_SUBJ_QUAL type FIELDNAME value 'TEXT_SUBJ_QUAL' ##NO_TEXT.
  constants GC_FIELDNAME_ZA7_Z47 type FIELDNAME value 'ZA7_Z47' ##NO_TEXT.
  constants GC_FIELDNAME_ZA7_Z84 type FIELDNAME value 'ZA7_Z84' ##NO_TEXT.
  constants GC_FIELDNAME_ZA7_Z85 type FIELDNAME value 'ZA7_Z85' ##NO_TEXT.
  constants GC_FIELDNAME_ZA7_Z86 type FIELDNAME value 'ZA7_Z86' ##NO_TEXT.
  constants GC_FIELDNAME_ZA8_Z47 type FIELDNAME value 'ZA8_Z47' ##NO_TEXT.
  constants GC_FIELDNAME_ZA8_Z84 type FIELDNAME value 'ZA8_Z84' ##NO_TEXT.
  constants GC_FIELDNAME_ZA8_Z85 type FIELDNAME value 'ZA8_Z85' ##NO_TEXT.
  constants GC_FIELDNAME_ZA8_Z86 type FIELDNAME value 'ZA8_Z86' ##NO_TEXT.
  constants GC_FIELDNAME_ZA8_Z92 type FIELDNAME value 'ZA8_Z92' ##NO_TEXT.
  constants GC_FIELDNAME_ZA9_Z85 type FIELDNAME value 'ZA9_Z85' ##NO_TEXT.
  constants GC_FORMAT_SETTING_01 type /ADZ/DE_BDR_FORMAT_SETTING value '01' ##NO_TEXT.
  constants GC_FORMAT_SETTING_02 type /ADZ/DE_BDR_FORMAT_SETTING value '02' ##NO_TEXT.
  constants GC_FTX_QUAL_Z06 type CHAR3 value 'Z06' ##NO_TEXT.
  constants GC_HEAT_CONSUMPT_Z56 type /IDXGC/DE_HEAT_CONSUMPT value 'Z56' ##NO_TEXT.
  constants GC_HEAT_CONSUMPT_Z57 type /IDXGC/DE_HEAT_CONSUMPT value 'Z57' ##NO_TEXT.
  constants GC_HEAT_CONSUMPT_Z61 type /IDXGC/DE_HEAT_CONSUMPT value 'Z61' ##NO_TEXT.
  constants GC_IMD_CHARDESC_CODE_Z35 type CHAR3 value 'Z35' ##NO_TEXT.
  constants GC_IMS_DEV_CONF_Z41 type /IDXGC/DE_IMS_DEV_CONF value 'Z41' ##NO_TEXT.
  constants GC_IMS_DEV_CONF_Z42 type /IDXGC/DE_IMS_DEV_CONF value 'Z42' ##NO_TEXT.
  constants GC_IMS_DEV_CONF_Z43 type /IDXGC/DE_IMS_DEV_CONF value 'Z43' ##NO_TEXT.
  constants GC_IMS_DEV_CONF_Z60 type /IDXGC/DE_IMS_DEV_CONF value 'Z60' ##NO_TEXT.
  constants GC_IMS_DEV_CONF_Z67 type /IDXGC/DE_IMS_DEV_CONF value 'Z67' ##NO_TEXT.
  constants GC_INTCODE_01 type INTCODE value '01' ##NO_TEXT.
  constants GC_INTCODE_02 type INTCODE value '02' ##NO_TEXT.
  constants GC_INTCODE_90 type INTCODE value '90' ##NO_TEXT.
  constants GC_INTCODE_M1 type INTCODE value 'M1' ##NO_TEXT.
  constants GC_MSG_CATEGORY_Z14 type /IDXGC/DE_MSG_CATEGORY value 'Z14' ##NO_TEXT.
  constants GC_MSG_CATEGORY_Z30 type /IDXGC/DE_MSG_CATEGORY value 'Z30' ##NO_TEXT.
  constants GC_MSG_CATEGORY_Z31 type /IDXGC/DE_MSG_CATEGORY value 'Z31' ##NO_TEXT.
  constants GC_MSG_CATEGORY_Z33 type /IDXGC/DE_MSG_CATEGORY value 'Z33' ##NO_TEXT.
  constants GC_MSG_CATEGORY_Z34 type /IDXGC/DE_MSG_CATEGORY value 'Z34' ##NO_TEXT.
  constants GC_OBJTYPE_MTRREADDOC type SWO_OBJTYP value 'MTRREADDOC' ##NO_TEXT.
  constants GC_PROC_CLUSTER_ADZBDR type /IDXGC/DE_PROC_CLUSTER value '/ADZ/BDR' ##NO_TEXT.
  constants GC_PROC_ID_8020 type /IDXGC/DE_PROC_ID value '8020' ##NO_TEXT.
  constants GC_PROC_ID_ADZ8020 type /IDXGC/DE_PROC_ID value '/ADZ/8020' ##NO_TEXT.
  constants GC_PROC_ID_ADZ8021 type /IDXGC/DE_PROC_ID value '/ADZ/8021' ##NO_TEXT.
  constants GC_PROC_ID_ADZ8022 type /IDXGC/DE_PROC_ID value '/ADZ/8022' ##NO_TEXT.
  constants GC_PROC_ID_ADZ8120 type /IDXGC/DE_PROC_ID value '/ADZ/8120' ##NO_TEXT.
  constants GC_PROC_ID_ADZ8121 type /IDXGC/DE_PROC_ID value '/ADZ/8121' ##NO_TEXT.
  constants GC_PROC_TYPE_22 type /IDXGC/DE_PROC_TYPE value '22' ##NO_TEXT.
  constants:
    BEGIN OF gc_proc_value,
               accepted            TYPE /idxgc/de_proc_value VALUE 'ACCEPTED',
               dev_conf_proc_start TYPE /idxgc/de_proc_value VALUE 'DEV_CONF_PROC_START',
               rejected            TYPE /idxgc/de_proc_value VALUE 'REJECTED',
             END OF gc_proc_value .
  constants GC_PROC_VIEW_04 type /IDXGC/DE_PROC_VIEW value '04' ##NO_TEXT.
  constants GC_SETTL_PROC_Z38 type /IDXGC/DE_SETTL_PROC value 'Z38' ##NO_TEXT.
  constants GC_SETTL_PROC_Z39 type /IDXGC/DE_SETTL_PROC value 'Z39' ##NO_TEXT.
  constants GC_SETTL_PROC_ZA9 type /IDXGC/DE_SETTL_PROC value 'ZA9' ##NO_TEXT.
  constants GC_SETTL_PROC_ZB0 type /IDXGC/DE_SETTL_PROC value 'ZB0' ##NO_TEXT.
  constants GC_STRUCTURE_BDR_CREATE_REQ type TABNAME value '/ADZ/S_BDR_CREATE_REQ' ##NO_TEXT.
  constants GC_STS_CATEGORY_CODE_Z21 type /IDXGC/DE_STATUS_CAT_CODE value 'Z21' ##NO_TEXT.
  constants GC_SUPPLY_DIRECT_Z06 type /IDXGC/DE_SUPPLY_DIRECT_1 value 'Z06' ##NO_TEXT.
  constants GC_SUPPLY_DIRECT_Z07 type /IDXGC/DE_SUPPLY_DIRECT_1 value 'Z07' ##NO_TEXT.
  constants GC_SWT_PERIOD_TYPE_ADZBDR_S01 type E_IDESWTTIMETYPE value '/ADZ/BDR_S01' ##NO_TEXT.
  constants GC_SWT_PERIOD_TYPE_ADZBDR_T01 type E_IDESWTTIMETYPE value '/ADZ/BDR_T01' ##NO_TEXT.
  constants GC_TARIF_ALLOC_Z59 type /IDXGC/DE_TARIF_ALLOC value 'Z59' ##NO_TEXT.
  constants GC_TARIF_ALLOC_Z60 type /IDXGC/DE_TARIF_ALLOC value 'Z60' ##NO_TEXT.
  constants GC_TEXT_SUBJ_QUAL_Z04 type /IDXGC/DE_TEXT_SUBJ_QUAL value 'Z04' ##NO_TEXT.
  constants GC_TEXT_SUBJ_QUAL_Z05 type /IDXGC/DE_TEXT_SUBJ_QUAL value 'Z05' ##NO_TEXT.
  constants GC_TEXT_SUBJ_QUAL_Z06 type /IDXGC/DE_TEXT_SUBJ_QUAL value 'Z06' ##NO_TEXT.
endinterface.
