CLASS /adz/cl_inv_gui_delvnoteman DEFINITION INHERITING FROM /adz/cl_inv_gui_alv_common
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS :
      constructor
        IMPORTING
          iv_repid TYPE repid
          iv_vari  TYPE slis_vari OPTIONAL,
      display_data
        IMPORTING
          if_event_handler TYPE REF TO /adz/if_inv_salv_table_evt_hlr
        CHANGING
          crt_data         TYPE REF TO data,
      handle_toolbar REDEFINITION.
  PROTECTED SECTION.
    METHODS:
      get_column_definition REDEFINITION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /adz/cl_inv_gui_delvnoteman IMPLEMENTATION.


  METHOD constructor.
    super->constructor(
       iv_repid =  iv_repid
       iv_vari   = iv_vari ).
  ENDMETHOD.


  METHOD display_data.
    " Usergruppenspezifische Knöpfe ausblenden
    DATA(lt_excl_func_names) = VALUE stringtab( ( ) ).
    init_display(
      EXPORTING        if_event_handler  = if_event_handler
                       it_funcnames_excl = lt_excl_func_names
                       ib_use_pf_status  = abap_false
                       ib_use_grid_xt    = abap_false
      CHANGING         crt_data          = crt_data
    ).
    display( ).
  ENDMETHOD.


  METHOD get_column_definition.
    DATA lo_structdescr   TYPE REF TO cl_abap_structdescr.
    DATA ls_data   TYPE /adz/inv_s_out_delvnoteman.

    lo_structdescr ?= cl_abap_structdescr=>describe_by_data( ls_data ).
    DATA(lt_comp) = lo_structdescr->get_components( ).

    rt_fieldcat = VALUE #(
      ( fieldname = 'LIGHTS'    tech = 'X' )
      ( fieldname = 'XSELP'     tech = 'X' )
      ( fieldname = 'SEL'       key = 'X'   checkbox = 'X'    scrtext_s = 'Selektion'  edit = 'X' auto_value = 'X' outputlen = '3'  ) "input = 'X'
      ( fieldname = 'PROC_REF'        scrtext_s = 'LS-Ref'     scrtext_m = 'Lieferschn-Referenz'  scrtext_l = 'Lieferschein-Referenz'
              key = 'X' )
      ( fieldname = 'LS2_PROC_REF'    scrtext_s = 'LS2-Ref'    scrtext_m = 'LS2-Referenz'  )
      ( " Interne Nummer des Rechnungsbelegs/Avisbelegs
        fieldname = 'INT_INV_DOC_NO'  ref_table = 'TINV_INV_DOC' outputlen = '10' )
      ( fieldname = 'INT_SENDER'      scrtext_s = 'Sender'     ) "ref_table = 'ESERVPROV' ref_field = 'SERVICEID' )
      ( fieldname = 'INT_RECEIVER'    scrtext_s = 'Receiver'   )
      ( fieldname = 'MOVEINDATE'      scrtext_s = 'LS EingDat'  scrtext_m = 'LS Eingangsdatum' outputlen = '10' )
      ( fieldname = 'MOVEOUTDATE'     scrtext_s = 'LS AusgDat'  scrtext_m = 'LS Ausgangsdatum' outputlen = '10' )
      ( fieldname = 'LS_TERMIN'       scrtext_s = 'LS-Termin'   scrtext_m = 'Lieferscheintermin' )
      ( fieldname = 'CASETEXT2'       scrtext_s = 'Falltext2' )
      ( fieldname = 'CASE_STATUS'     scrtext_s = 'FallStat'   scrtext_m = 'Fall-Status'
            ref_field = 'STATUS'     ref_table = 'EMMA_CASE'    domname = 'EMMA_CSTATUS'  f4availabl = 'X' )
      ( fieldname = 'EXT_UI'          scrtext_s = 'MktLokID'   scrtext_m = 'Marktlokations-ID' )
      ( fieldname = 'SPARTYP_TEXT'    scrtext_s = 'SptTxt'     scrtext_m = 'Spartentyp Text' )
      ( fieldname = 'STATUS'          scrtext_s = 'LS-Status'  scrtext_m = 'Lieferscheinstatus'
             ref_field = 'STATUS'   ref_table = 'EIDESWTDOC'    domname = 'EIDESWTSTAT' f4availabl = 'X' )
      ( fieldname = 'MORE_CASES'      scrtext_s = 'weitAusn'  scrtext_m = 'weitere Ausnahmen' )
      ( fieldname = 'MSCONS_PROCDATE'  scrtext_s = 'MSCONS-PD'  scrtext_m = 'MSCONS-ProcDate' scrtext_l = 'MSCONS-ProcDate')

    ).
    " Entfern-Range definieren.
    DATA lt_rng_fieldname TYPE RANGE OF lvc_s_fcat-fieldname.
    lt_rng_fieldname = VALUE #(
       ( sign = 'I' option = 'EQ' low = 'COLOR' )
       ( sign = 'I' option = 'EQ' low = 'SWITCHNUM' )
       ( sign = 'I' option = 'EQ' low = 'PROC_STEP10_REF' )
       ( sign = 'I' option = 'EQ' low = 'SERVICE_PROV_OLD' )
       ( sign = 'I' option = 'EQ' low = 'SERVICE_PROV_NEW' )
       ( sign = 'I' option = 'EQ' low = 'EXT_REFERENCE' )
       ).
    lt_rng_fieldname = VALUE #( BASE lt_rng_fieldname
       FOR lsr IN rt_fieldcat ( sign = 'I' option = 'EQ' low = lsr-fieldname )
      ).

    " Alle restlichen Felder aus Strukturdefinition übernehmen
    DATA(lt_dfies) = cl_salv_data_descr=>read_structdescr( lo_structdescr ).
    rt_fieldcat = VALUE lvc_t_fcat( BASE rt_fieldcat
      FOR ls IN lt_dfies WHERE (  fieldname NOT IN lt_rng_fieldname )
      ( CORRESPONDING #( ls )  )
    ).

    " besondere KZ setzen
    LOOP AT rt_fieldcat ASSIGNING FIELD-SYMBOL(<ls_fieldcat>).
      " Hotspots auf einen Blick
      <ls_fieldcat>-hotspot = SWITCH #( <ls_fieldcat>-fieldname
            WHEN 'PROC_REF'
              OR 'LS2_PROC_REF'
              OR 'CASENR'
              OR 'MORE_CASES'
              OR 'INT_SENDER'
              OR 'INT_RECEIVER'
              "OR 'INT_UI'
              OR 'EXT_UI'
              OR 'PARTNER'
              OR 'ANLAGE'
              OR 'VERTRAG'
              OR 'QUANTITY_EXT'
              OR 'SERVICE_PROV_OLD'
              OR 'SERVICE_PROV_NEW'
              OR 'INT_INV_DOC_NO'
            THEN 'X'
            ELSE '' ).

      <ls_fieldcat>-no_zero = SWITCH #( <ls_fieldcat>-fieldname
            WHEN 'SWITCHNUM'
              OR 'DLINE_TIMESTAMP' THEN 'X'
            ELSE '' ).
      <ls_fieldcat>-rollname = ''.
      IF <ls_fieldcat>-ref_table IS INITIAL.
        <ls_fieldcat>-ref_table = '/ADZ/OUT_DNM'.
        <ls_fieldcat>-colddictxt = 'M'.
        <ls_fieldcat>-scrtext_m = COND #( WHEN <ls_fieldcat>-scrtext_m IS INITIAL THEN  <ls_fieldcat>-scrtext_s ELSE <ls_fieldcat>-scrtext_m ).
        IF <ls_fieldcat>-scrtext_l  IS INITIAL.
          <ls_fieldcat>-scrtext_l = <ls_fieldcat>-scrtext_m.
        ENDIF.
        CONTINUE.
        TRY.
            DATA(lo_elem) = CAST cl_abap_elemdescr( lt_comp[ name = <ls_fieldcat>-fieldname ]-type ).
            IF sy-subrc EQ 0.
              <ls_fieldcat>-rollname = lo_elem->help_id.
            ENDIF.
          CATCH cx_sy_itab_line_not_found.
        ENDTRY.
      ENDIF.
    ENDLOOP.
    CLEAR lo_structdescr.
  ENDMETHOD.


  METHOD handle_toolbar.
    e_object->mt_toolbar = VALUE #(
      ( LINES OF /adz/cl_inv_gui_alv_common=>get_fc_standard( ) )
    ).

    " excludierte functions wieder rausfischen
    LOOP AT mt_excl_functions ASSIGNING FIELD-SYMBOL(<ls_excl_func>).
      DELETE e_object->mt_toolbar WHERE function = <ls_excl_func>-fcode.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
