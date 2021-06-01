FUNCTION /adesso/fm_zaehler_id_shlps.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCT
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     REFERENCE(SHLP) TYPE  SHLP_DESCR
*"     REFERENCE(CALLCONTROL) LIKE  DDSHF4CTRL STRUCTURE  DDSHF4CTRL
*"----------------------------------------------------------------------
  DATA: ls_shlp LIKE LINE OF shlp_tab.

  FIELD-SYMBOLS: <fs_interface> LIKE LINE OF shlp-interface.

  IF callcontrol-step = 'SELONE'.
    READ TABLE shlp-interface ASSIGNING <fs_interface> WITH KEY shlpfield = 'SPARTE'.
    IF <fs_interface> IS ASSIGNED.
      LOOP AT shlp_tab INTO ls_shlp.
        IF ls_shlp-shlpname = '/ADESSO/SH_ZAEHLER_ID_ELE' AND <fs_interface>-value = '02'.
          DELETE shlp_tab.
        ELSEIF ls_shlp-shlpname = '/ADESSO/SH_ZAEHLER_ID_GAS' AND <fs_interface>-value = '01'.
          DELETE shlp_tab.
        ENDIF.
      ENDLOOP.
    ENDIF.
    EXIT.
  ENDIF.
ENDFUNCTION.
