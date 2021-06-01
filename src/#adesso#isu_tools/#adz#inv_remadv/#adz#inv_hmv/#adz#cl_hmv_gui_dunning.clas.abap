CLASS /adz/cl_hmv_gui_dunning DEFINITION INHERITING FROM /adz/cl_inv_gui_alv_common
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS :
      constructor
        IMPORTING
          is_const TYPE /adz/hmv_s_constants
          iv_vari  TYPE slis_vari OPTIONAL,

      display_data
        IMPORTING
          if_event_handler TYPE REF TO /adz/if_inv_salv_table_evt_hlr
        CHANGING
          crt_data         TYPE REF TO data,

      handle_toolbar REDEFINITION.

  PROTECTED SECTION.
    METHODS:
      get_column_definition REDEFINITION,
      get_sort REDEFINITION.
  PRIVATE SECTION.
    DATA  ms_const        TYPE /adz/hmv_s_constants.

ENDCLASS.



CLASS /ADZ/CL_HMV_GUI_DUNNING IMPLEMENTATION.

  METHOD constructor.
    super->constructor(
       iv_repid =  is_const-repid
       iv_vari   = iv_vari ).
    ms_const = is_const.
  ENDMETHOD.


  METHOD display_data.
    "mb_statlst_flag = ib_statistic_flag.
    " Usergruppenspezifische Knöpfe ausblenden
    DATA lt_excl_func_names TYPE stringtab.
    DATA lv_vari   TYPE slis_vari.

    "    lrt_data = COND #( fieldname = ib_statistic_flag = abap_true THEN crt_stats ELSE crt_data ).
    "lv_vari  = COND #( fieldname = ib_statistic_flag = abap_true THEN '/STATS'  ).
    init_display(
      EXPORTING        if_event_handler  = if_event_handler
                       it_funcnames_excl = lt_excl_func_names
                       ib_use_pf_status  = abap_false
                       ib_use_grid_xt    = abap_false
      CHANGING         crt_data          = crt_data
    ).

    "set_screen_status( 'STANDARD_STATUS' ).

    " Anzeigen
    display( ).
  ENDMETHOD.


  METHOD get_column_definition.
    DATA lo_structdescr   TYPE REF TO cl_abap_structdescr.

    "DATA lt_fieldcat type lvc_t_fcat.
    IF 1 < 0. "i_statlst_flag = abap_true.
      "DATA(lo_structdescr) = CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_name( '/ADZ/HMV_IDOC' ) ).
      "DATA(lt_comp) = lo_structdescr->get_components( ).
      "DATA(lt_fieldcat) = VALUE lvc_t_fcat( FOR ls IN lt_comp
      "   ( fieldname =  ls-name   ref_table = '/ADZ/HMV_IDOC' ) ).
    ELSE.
      DATA ls_data   TYPE /adz/hmv_s_out_dunning.
      lo_structdescr ?= cl_abap_structdescr=>describe_by_data( ls_data ).
      DATA(lt_dfies) = cl_salv_data_descr=>read_structdescr( lo_structdescr ).
      " Grunddefintion aus Datenstruktur
      rt_fieldcat = VALUE lvc_t_fcat( FOR ls IN lt_dfies ( CORRESPONDING #( ls )  ) ).

      " Ergaenzungen
      DATA(lt_fieldcat) = VALUE lvc_t_fcat(
        ( fieldname = 'SEL' key = 'X' edit = 'X'  checkbox = 'X'
                  scrtext_s = 'Mahnsp' scrtext_m = 'Mahnsperre' scrtext_l = 'Mahnsperre' auto_value = 'X' outputlen = 10 )
        ( fieldname = 'LOCKED'   scrtext_s = 'Sp'   scrtext_m = 'Sperre'     scrtext_l = 'Sperre' icon = 'X'  outputlen = 10 ) " key = 'X'
        ( fieldname = 'TO_LOCK'  scrtext_s = 'VS'   scrtext_m = 'V.Sperre'  scrtext_l = 'Vorschlag Sperre' icon = 'X' outputlen = 10 ) " key = 'X'
        ( fieldname = 'KENNZ'    scrtext_s = 'Kz.'  scrtext_m = 'Hrkft Kennz.' scrtext_l = 'Herkunft Kennzeichen' outputlen = 10 ) " key = 'X'
        ( fieldname = 'BUCHVERT' scrtext_s = 'VSt.' scrtext_m = 'Buchg VSt.' scrtext_l = 'Buchg VSt.' icon = 'X' outputlen = 10 ) " key = 'X'
        ( fieldname = 'AGGVK'    scrtext_s = 'Aggr VK' scrtext_m = 'Aggr VK' scrtext_l = 'Aggr VK'  hotspot = 'X' ) " key = 'X'
        ( fieldname = 'STATUS'   scrtext_s = 'Stat'    scrtext_m = 'Status'      scrtext_l = 'Status' icon = 'X' outputlen = 10 )
        ( fieldname = 'VKBEZ' ) "key = 'X' )
        ( fieldname = 'RECID' hotspot = 'X' ) " key = 'X' )
        ( fieldname = 'SENID' hotspot = 'X' ) " key = 'X' )
        ( fieldname = 'VKTYP' ) "key = 'X' )
        ( fieldname = 'MAHNV' ) "key = 'X' )
        ( fieldname = 'AGMSP' no_out = 'X' )
        ( fieldname = 'AKONTO' scrtext_s = 'AKto'    scrtext_m = 'AKonto'      scrtext_l = 'AKonto' icon = 'X' outputlen = 10 )
        ( fieldname = 'BCBLN'  scrtext_s = 'AggrBel' scrtext_m = 'Aggre.Beleg' scrtext_l = 'Aggre.Beleg' hotspot = 'X' )
        ( fieldname = 'BCAUG'  scrtext_s = 'AggrAgl' scrtext_m = 'AggrAglSt'   scrtext_l = 'AggrAglSt'   no_out = 'X' )
        ( fieldname = 'SENT'   no_out = 'X' )
        ( fieldname = 'AUGST' no_out = 'X' )
        ( fieldname = 'VKONT' hotspot = 'X' )
        ( fieldname = 'VTREF' hotspot = 'X' )
        ( fieldname = 'OPBEL' hotspot = 'X' )
        ( fieldname = 'GPART'  hotspot = 'X' )
        ( fieldname = 'OWNRF'  scrtext_s = 'CrsrfNo'  scrtext_m = 'CrossrefNo'   scrtext_l = 'CrossreferenceNo' )
        ( fieldname = 'MDRKD'  scrtext_s = 'Druck 1.' scrtext_m = 'Druck 1.Mahn' scrtext_l = 'Druck 1.Mahn' )
        ( fieldname = 'BETRH'  do_sum = 'X' )
        ( fieldname = 'PAYNO'     scrtext_s = 'Zahl'     scrtext_m = 'Zahl.Avis'   scrtext_l = 'Zahlungsavis' hotspot = 'X' )
        ( fieldname = 'PAYST'     scrtext_s = 'Zahl.St.' scrtext_m = 'Zahl.Status' scrtext_l = 'Zahlung Status' )
        ( fieldname = 'PAYST_ICON' scrtext_s = 'Z.St.'   scrtext_m = 'Z.Stat'      scrtext_l = 'Z.Stat'   icon = 'X' outputlen = 10 )
        ( fieldname = 'DOCNO'   scrtext_s = 'neg.REMADV' scrtext_m = 'neg.REMADV'  scrtext_l = 'neg.REMADV' hotspot = 'X' )
        ( fieldname = 'STATREM' scrtext_s = 'St.R'       scrtext_m = 'St.Rem'      scrtext_l = 'St.Rem'  icon = 'X' outputlen = 10 )
        ( fieldname = 'IDOCIN'  scrtext_s = 'INVOIC'     scrtext_m = 'INVOIC'      scrtext_l = 'INVOIC'  hotspot = 'X' )
        ( fieldname = 'STATIN'  scrtext_s = 'St.I'       scrtext_m = 'St.Inv'      scrtext_l = 'St.Inv'  icon = 'X' outputlen = 10 )
        ( fieldname = 'IDOCCT'  scrtext_s = 'AggrINV'    scrtext_m = 'Aggr.INVOIC' scrtext_l = 'Aggr. INVOIC'  hotspot = 'X' )
        ( fieldname = 'STATCT'  scrtext_s = 'St.C'       scrtext_m = 'St.Ctrl'     scrtext_l = 'St.Ctrl' icon = 'X' outputlen = 10 )
        ( " REMADV1-Nummer  +++
          fieldname = 'REMADV1'  hotspot = 'X' scrtext_m = 'REMADV1-Nr' )
        ( " REMADV1-Datum
          fieldname = 'REMDATE1'    scrtext_s = 'R1-Datum'  scrtext_m = 'R1-Datum' )
        (  " Differenzgrund bei Zahlungen
          fieldname = 'RSTGR1'      scrtext_s = 'R1-DiffG'  scrtext_m = 'R1-DiffGrund'  ) " ref_table = 'TINV_INV_LINE_A' )
        ( " REMADV2-Nummer++++
          fieldname = 'REMADV2'     scrtext_s = 'REMADV2-Nr' scrtext_m = 'REMADV2-Nr'    hotspot  = 'X'   )
        ( " REMADV2-Datum
          fieldname = 'REMDATE2'    scrtext_s = 'R2-Datum'   scrtext_m = 'R2-Datum' )
        (  "REMADV2-Differenzgrund bei Zahlungen
          fieldname = 'RSTGR2'      scrtext_s = 'R2-DiffG' scrtext_m = 'R2-DiffGrund'  ) " ref_table = 'TINV_INV_LINE_A' )
        (  "REMADV2-Status
          fieldname = 'STATREM2'    scrtext_s = 'R2-Status' scrtext_m = 'R2-Status'  )
        ( " COMDIS +++
          fieldname = 'COMDIS'      scrtext_s = 'COMDIS'    scrtext_m = 'COMDIS'   hotspot  = 'X'   )

     ).
      " Ergaenzungen einarbeiten
      LOOP AT rt_fieldcat ASSIGNING FIELD-SYMBOL(<ls_fieldcat>).
        <ls_fieldcat>-fix_column  = ''.
        <ls_fieldcat>-rollname = ''.
        TRY.
            IF <ls_fieldcat>-ref_table IS INITIAL.
              <ls_fieldcat>-ref_table = '/ADZ/HMV_OUT_DUN'.
              <ls_fieldcat>-colddictxt = 'M'.
            ENDIF.

            DATA(ls_fc) = lt_fieldcat[ fieldname = <ls_fieldcat>-fieldname ].
            <ls_fieldcat>-edit     = ls_fc-edit.
            <ls_fieldcat>-checkbox = ls_fc-checkbox.
            <ls_fieldcat>-key      = ls_fc-key.
            <ls_fieldcat>-hotspot  = ls_fc-hotspot.
            <ls_fieldcat>-icon     = ls_fc-icon.
            <ls_fieldcat>-no_out   = ls_fc-no_out.
            <ls_fieldcat>-scrtext_s = COND #( WHEN ls_fc-scrtext_s IS NOT INITIAL THEN ls_fc-scrtext_s ).
            <ls_fieldcat>-scrtext_m = COND #( WHEN ls_fc-scrtext_m IS NOT INITIAL THEN ls_fc-scrtext_m ).
            <ls_fieldcat>-scrtext_l = COND #( WHEN ls_fc-scrtext_l IS NOT INITIAL THEN ls_fc-scrtext_l ).
            <ls_fieldcat>-outputlen = COND #( WHEN ls_fc-outputlen IS NOT INITIAL THEN ls_fc-outputlen ).
            IF <ls_fieldcat>-scrtext_m IS NOT INITIAL.
              <ls_fieldcat>-colddictxt = 'M'.
            ENDIF.
          CATCH cx_sy_itab_line_not_found.
            <ls_fieldcat>-key      = ''.
            <ls_fieldcat>-no_out  = ''.
        ENDTRY.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD get_sort.
    rt_sort = VALUE #(
     ( fieldname = 'AGGVK'  spos = 1  up = 'X' comp = 'X' )
     ( fieldname = 'BCBLN'  spos = 2  up = 'X' subtot = 'X' ) ).
  ENDMETHOD.


  METHOD handle_toolbar.
    e_object->mt_toolbar = VALUE #(
      ( LINES OF /adz/cl_inv_gui_alv_common=>get_fc_standard( ) )
      "( function = cl_gui_alv_grid=>MC_FC_INFO "  icon = icon_information  text = '' quickinfo = 'Information'   )
      "( function = '&CRB' icon = icon_total_left    text = '' quickinfo = 'Erste Spalte'   )
      "( function = '&CRL' icon = icon_column_left   text = '' quickinfo = 'Spalte links'   )
      "( function = '&CRR' icon = icon_column_right  text = '' quickinfo = 'Spalte rechts'   )
      "( function = '&CRE' icon = icon_total_right   text = '' quickinfo = 'Letzte Spalte'   )
      ( function = 'BALANCE' icon = icon_object_list  text = 'KtnStand'       quickinfo = 'Kontenstand'   )
      ( function = 'BALAGGR' icon = icon_object_list  text = 'KtnStand AggVK' quickinfo = 'KtnStand AggVK'  )
      ( function = 'DATEX  ' icon = icon_interchange  text = 'Datex'          quickinfo = 'EDATEX Mon'   )
      "( function = 'INTE_HIST' icon = icon_history   text = 'Zinshistorie' quickinfo = 'Zinshistorie'   )
      ( function = 'DUNN_HIST' icon = icon_protocol  text = 'Mahnhistorie' quickinfo = 'Mahnhistorie'   )
      ( function = 'DUNN_BLK'  icon = icon_locked    text = 'Hist. MSperr.' quickinfo = 'Mahnsperren Historie'   )
      ( function = 'LOCK'      icon = icon_execute_object  text = 'Mahnsperre' quickinfo = 'Mahnsperre setzen'   )
      ( function = 'UNLOCK   ' icon = icon_unlocked        text = 'Löschen MS' quickinfo = 'Löschen Mahnsperre'   )

      ( butn_type = 3 ) " append a separator to normal toolbar
    ).
    " excludierte functions wieder rausfischen
    LOOP AT mt_excl_functions ASSIGNING FIELD-SYMBOL(<ls_excl_func>).
      DELETE e_object->mt_toolbar WHERE function = <ls_excl_func>-fcode.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
