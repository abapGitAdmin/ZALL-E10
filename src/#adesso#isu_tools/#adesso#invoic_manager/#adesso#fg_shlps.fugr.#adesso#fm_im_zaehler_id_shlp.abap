FUNCTION /ADESSO/FM_IM_ZAEHLER_ID_SHLP.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCT
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     REFERENCE(SHLP) TYPE  SHLP_DESCR
*"     REFERENCE(CALLCONTROL) TYPE  DDSHF4CTRL
*"----------------------------------------------------------------------
DATA: lt_source_ele TYPE TABLE OF /adesso/zaehler,
        lt_source_gas TYPE TABLE OF /adesso/g_zaehlr.

  IF callcontrol-step = 'SELECT'.

    IF shlp-shlpname = '/ADESSO/SH_ZAEHLER_ID_GAS'.
      SELECT * FROM /adesso/g_zaehlr INTO TABLE lt_source_gas.
      SORT lt_source_gas.
      DELETE ADJACENT DUPLICATES FROM lt_source_gas.

      CALL FUNCTION 'F4UT_RESULTS_MAP'
        TABLES
          shlp_tab          = shlp_tab
          record_tab        = record_tab
          source_tab        = lt_source_gas
        CHANGING
          shlp              = shlp
          callcontrol       = callcontrol
        EXCEPTIONS
          illegal_structure = 1
          OTHERS            = 2.
    ELSEIF shlp-shlpname = '/ADESSO/SH_ZAEHLER_ID_ELE'.
      SELECT * FROM /adesso/zaehler INTO TABLE lt_source_ele.
      SORT lt_source_ele.
      DELETE ADJACENT DUPLICATES FROM lt_source_ele.

      CALL FUNCTION 'F4UT_RESULTS_MAP'
        TABLES
          shlp_tab          = shlp_tab
          record_tab        = record_tab
          source_tab        = lt_source_ele
        CHANGING
          shlp              = shlp
          callcontrol       = callcontrol
        EXCEPTIONS
          illegal_structure = 1
          OTHERS            = 2.
    ENDIF.

    IF NOT ( record_tab[] IS INITIAL ).
      callcontrol-step = 'DISP'.
    ELSE.
      callcontrol-step = 'EXIT'.
    ENDIF.
    RETURN.
  ENDIF.
ENDFUNCTION.
