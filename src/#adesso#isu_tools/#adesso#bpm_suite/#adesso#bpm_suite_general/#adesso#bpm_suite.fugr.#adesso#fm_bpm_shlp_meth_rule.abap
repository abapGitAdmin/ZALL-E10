FUNCTION /adesso/fm_bpm_shlp_meth_rule.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCT
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     REFERENCE(SHLP) TYPE  SHLP_DESCR
*"     REFERENCE(CALLCONTROL) TYPE  DDSHF4CTRL
*"----------------------------------------------------------------------
  DATA:  BEGIN OF ls_source,
           method          TYPE /idxgc/de_dataprov_method,
           data_prov_class TYPE /idxgc/de_dataprov_class.
  DATA:  END OF ls_source.

  DATA: lt_source   LIKE STANDARD TABLE OF ls_source,
        lv_dp_class TYPE seoclsname,
        lr_dp_class TYPE REF TO cl_oo_class,
        lt_methods  TYPE seo_methods.

  FIELD-SYMBOLS: <fs_method>   TYPE vseomethod.

  IF callcontrol-step = 'SELECT'.
    CALL FUNCTION '/ADESSO/FM_GET_DP_CLASS_NAME'
      IMPORTING
        ev_dp_class = lv_dp_class.

    TRY.
        CREATE OBJECT lr_dp_class
          EXPORTING
            clsname                   = lv_dp_class
            with_inherited_components = abap_true
            with_interface_components = abap_true.
      CATCH cx_class_not_existent.
        RETURN.
    ENDTRY.

    lt_methods = lr_dp_class->get_methods( ).

    LOOP AT lt_methods ASSIGNING <fs_method> WHERE exposure = 2.
      ls_source-method = <fs_method>-cmpname.
      ls_source-data_prov_class = <fs_method>-clsname.
      INSERT ls_source INTO TABLE lt_source.
    ENDLOOP.

    SORT lt_source BY method data_prov_class.
    DELETE ADJACENT DUPLICATES FROM lt_source COMPARING method data_prov_class.

    CALL FUNCTION 'F4UT_RESULTS_MAP'
      TABLES
        shlp_tab          = shlp_tab
        record_tab        = record_tab
        source_tab        = lt_source
      CHANGING
        shlp              = shlp
        callcontrol       = callcontrol
      EXCEPTIONS
        illegal_structure = 1
        OTHERS            = 2.

    IF NOT ( record_tab[] IS INITIAL ).
      callcontrol-step = 'DISP'.
    ELSE.
      callcontrol-step = 'EXIT'.
    ENDIF.
    RETURN.
  ENDIF.
ENDFUNCTION.
