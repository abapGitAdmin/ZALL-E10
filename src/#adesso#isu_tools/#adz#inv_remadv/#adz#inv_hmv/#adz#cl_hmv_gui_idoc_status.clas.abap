CLASS /adz/cl_hmv_gui_idoc_status DEFINITION INHERITING FROM /adz/cl_inv_gui_alv_common
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS :
      constructor
        IMPORTING
          is_const TYPE /adz/hmv_s_constants,

      display_data
        IMPORTING
          if_event_handler  TYPE REF TO /adz/if_inv_salv_table_evt_hlr
          ib_statistic_flag TYPE abap_bool
        CHANGING
          crt_data          TYPE REF TO data
          crt_stats         TYPE REF TO data,

      handle_toolbar REDEFINITION.

  PROTECTED SECTION.
    METHODS:
      build_header
         IMPORTING  is_stats          type  /adz/hmv_idoc
         RETURNING VALUE(r_header)    TYPE slis_t_listheader,
      get_column_definition REDEFINITION.
  PRIVATE SECTION.
    DATA  mb_statlst_flag TYPE boolean.
    DATA  ms_const        TYPE /adz/hmv_s_constants.

ENDCLASS.



CLASS /adz/cl_hmv_gui_idoc_status IMPLEMENTATION.


  METHOD constructor.
    super->constructor(
       iv_repid =  is_const-repid
       iv_vari   = '' ).
    ms_const = is_const.
  ENDMETHOD.


  METHOD display_data.
    mb_statlst_flag = ib_statistic_flag.
    " Usergruppenspezifische Knöpfe ausblenden
    DATA lt_excl_func_names TYPE stringtab.
    DATA lrt_data  type ref to data.
    DATA lv_vari   TYPE slis_vari.

    lrt_data = COND #( WHEN ib_statistic_flag = abap_true THEN crt_stats else crt_data ).
    "lv_vari  = COND #( WHEN ib_statistic_flag = abap_true THEN '/STATS'  ).
    init_display(
      EXPORTING        if_event_handler  = if_event_handler
                       it_funcnames_excl = lt_excl_func_names
                       ib_use_pf_status  = abap_false
                       iv_vari           = lv_vari
                       ib_show_all_cols  = ib_statistic_flag
                       ib_use_grid_xt    = abap_false
      CHANGING         crt_data          = lrt_data
    ).

    "set_screen_status( 'STANDARD_STATUS' ).

    " Anzeigen
    display( ).
  ENDMETHOD.


  METHOD get_column_definition.
    "DATA lt_fieldcat type lvc_t_fcat.
    IF mb_statlst_flag = abap_true.
      DATA(lo_structdescr) = CAST cl_abap_structdescr( cl_abap_structdescr=>DESCRIBE_BY_name( '/ADZ/HMV_IDOC' ) ).
      DATA(lt_comp) = lo_structdescr->get_components( ).
      DATA(lt_fieldcat) = value lvc_t_fcat( for ls in lt_comp
         ( fieldname = ls-name   ref_table = '/ADZ/HMV_IDOC' ) ).
    else.
      lt_fieldcat = VALUE lvc_t_fcat(
      (  " Status
      fieldname = 'STATUS' key = 'X'  scrtext_s = 'St'   scrtext_m = 'Stat' scrtext_l = 'Status'    icon = 'X' )
      ( " Kennzeichen zur Herkunft: D oder M
      fieldname = 'KENNZ'  key = 'X' scrtext_s = 'KzHk'    scrtext_m = 'Kz Herkunft'    scrtext_l = 'Kennzeichen Herkunft' )
      ( " Belegnummer
      fieldname = 'OPBEL'   key = 'X' scrtext_s = 'Belnr'   scrtext_m = 'Belegnr'   scrtext_l = 'Belegnummer'   ref_table = 'DFKKTHI' )
      ( " Buchungskreis
      fieldname = 'BUKRS'   scrtext_s = 'BUKRS' scrtext_m = 'Buchungskr '   scrtext_l = 'Buchungskreis' ref_table = 'DFKKTHI' )
      ( " Status des Eintrags
      fieldname = 'THIST'   scrtext_m = 'Status'    ref_table = 'DFKKTHI' )
      ( " Beleg wurde storniert
      fieldname = 'STORN'   scrtext_m = 'Storno'    scrtext_l = 'Beleg storniert'   ref_table = 'DFKKTHI' )
      ( " Herkunft des Eintrags ist Storno
      fieldname = 'STIDC'   scrtext_s = 'Hrkft.St.'  scrtext_m = 'HerkunftSt.'  scrtext_l = 'Herkunft Storno'    ref_table = 'DFKKTHI' )
      ( " Fälligkeitsdatum der Übertragung an einen Dritten  "FAEDN_KK
      fieldname = 'THIDT' scrtext_s = 'F.Dat.'     scrtext_m = 'Fäll.Dat.'    scrtext_l = 'Fälligkeitsdatum'    ref_table = 'DFKKTHI' )
      ( " Ist-Datum der Übertragung an einen Dritten
      fieldname = 'THPRD'   tabname = 'IT_OUTPUT'   scrtext_s = 'Ist-Dat    '   scrtext_m = 'Ist Datum' ref_table = 'DFKKTHI' )
      ( " Belegnummer der Buchung auf das Serviceanbieter-Konto "CI_FICA_DOC_NO
      fieldname = 'BCBLN'   scrtext_s = 'BelNr. SP' scrtext_m = 'BelNr. Servprov.' scrtext_l = 'Belegnummer Servprov.' ref_table = 'DFKKTHI' )
      ( " Interne bezeichnung des rechnungs-/avissenders
      fieldname = 'SENID'   scrtext_m = 'Avissender'    ref_table = 'DFKKTHI' )
      ( " Interne Bezeichnung des Rechnung-/Avisempfängers
      fieldname = 'RECID'   scrtext_s = 'A-Empf.'   scrtext_m = 'Avisempf.' scrtext_l = 'Avisempfänger.'    ref_table = 'DFKKTHI' )
      ( " Transaktionswährung
      fieldname = 'WAERS'   scrtext_m = 'Waers' scrtext_l = 'Währung'   ref_table = 'DFKKTHI' )
      ( " Betrag in Transaktionswährung mit Vorzeichen
      fieldname = 'BETRW'   currency = 'EUR'    scrtext_m = 'Betrag'    ref_table = 'DFKKTHI' )
      ( " IDE: Interne Cross Referenznummer
      fieldname = 'CRSRF'   scrtext_s = 'CRSRF' scrtext_m = 'Crossref'  scrtext_l = 'Crossrefno'    ref_table = 'DFKKTHI' )
      ( " Interner Schlüssel des Zählpunkts
      fieldname = 'INTUI'   scrtext_s = 'Int.ZP'    scrtext_m = 'Interner ZP'   scrtext_l = 'Interner Zählpunkt'    ref_table = 'DFKKTHI' )
      ( " IDE: Crossreferenznummer
      fieldname = 'OWNRF'   scrtext_s = 'IDE:Crsrf' scrtext_m = 'IDE:Crossref'  scrtext_l = 'IDE:Crossrefno' )
      ( "  Datum der letzten Änderung
      fieldname = 'DEXAEDAT'    scrtext_s = 'Änd.'  scrtext_m = 'Geändert am'   scrtext_l = 'Zuletzt geändert am'   ref_table = 'EDEXTASK'    no_out = 'X' )
      ( " INVOIC
      fieldname = 'IDOCIN'  scrtext_s = 'Nr.INV'    scrtext_m = 'Nr.Invoic' scrtext_l = 'Nr Invoic' emphasize = 'C30'   ref_table = 'DFKKTHI' )
      ( " Status INVOIC
      fieldname = 'STATIN_LED'  scrtext_s = 'INV'   scrtext_m = 'St.INV'    scrtext_l = 'Status Invoice'    emphasize = 'C30' )
      ( " CONTROL
      fieldname = 'IDOCCT'  scrtext_s = 'Nr.CT' scrtext_m = 'Nr.Control'    scrtext_l = 'Nr Control'    emphasize = 'C30'   ref_table = 'DFKKTHI' )
      ( " Status CONTROL
      fieldname = 'STATCT_LED'  scrtext_s = 'CT'    scrtext_m = 'Stat.CTRL' scrtext_l = 'St.Control'    emphasize = 'C30' )
      ( " Externer Zählpunkt
      fieldname = 'EXT_UI'  scrtext_s = 'ext.ZP'    scrtext_m = 'ext.ZP-Bez'    scrtext_l = 'ext.Zählpunktbezeichnung'  ref_table = 'DFKKTHI' )
      ( " IDoc-Stautus aus Tabelle EDIDC  "10 bis 86
      fieldname = 'DOC_STATUS'    scrtext_s = 'Rück.St.'    scrtext_m = 'Statusrückm.'  scrtext_l = 'Statusrückmeldung'
         ref_table = '/IDXMM/MEMIDOC'  ref_field = 'DOC_STATUS' )
      ( " EDIDS Status invoice
      fieldname = 'STATUS_I'    scrtext_s = 'Stat i'    scrtext_m = 'Status i'  scrtext_l = 'Status i' )
      ( " EDIDS Status ctrl
      fieldname = 'STATUS_C'    scrtext_s = 'Stat c'    scrtext_m = 'Status c'  scrtext_l = 'Status c' )
      ( " IT_OUTPUT DEXIDOCSENT
      fieldname = 'DEXIDOCSENT' scrtext_s = 'SINV'  scrtext_m = 'SENTINV'   scrtext_l = 'SENTINVOICE'   ref_table = 'DFKKTHI' )
      ( " IT_OUTPUT DEXIDOCSENTCTRL
      fieldname = 'DEXIDOCSENTCTRL' scrtext_s = 'SCTRL' scrtext_m = 'SENTCTRL'  scrtext_l = 'SENTCONTROL'   ref_table = 'DFKKTHI' )
      ( " IT_OUTPUT DEXIDOCSENDCAT
      fieldname = 'DEXIDOCSENDCAT'  scrtext_s = 'CAT'   scrtext_m = 'SENDCAT'   scrtext_l = 'DEXIDOCSENDCAT'    ref_table = 'DFKKTHI' )
      ( " IT_OUTPUT DEXPROC
      fieldname = 'DEXPROC' scrtext_s = 'XPROC' scrtext_m = 'DEXPROC'   scrtext_l = 'DEXPROC'   ref_table = 'DFKKTHI' )
      ).
      loop at lt_fieldcat ASSIGNING FIELD-SYMBOL(<ls_fieldcat>).
        <ls_fieldcat>-tabname = '/ADZ/HMV_OUTIDOC'.
      ENDLOOP.
    ENDIF.
    rt_fieldcat = lt_fieldcat.
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

  METHOD build_header.
*    " Gesamtstatistik wird nicht gebracht
*    REFRESH: r_header.
*    r_header = VALUE slis_t_listheader(
*        ( typ  = ms_const-c_listheader_typ	key  = c_lines	info = TEXT-003	)
*        ( typ  = ms_const-c_listheader_typ	key  = c_lines	info = TEXT-004	)
*        ( typ  = ms_const-c_listheader_typ	key  = is_stats-updok	info = TEXT-005	)
*        ( typ  = ms_const-c_listheader_typ	key  = is_stats-upder	info = TEXT-006	)
*        ( typ  = ms_const-c_listheader_typ	key  = c_lines	info = TEXT-011	)
*     "   ( typ  = ms_const-c_listheader_typ	key  = is_stats-upd_memi_ok	info = TEXT-012	)
*     "   ( typ  = ms_const-c_listheader_typ	key  = is_stats-upd_memi_er	info = TEXT-013	)
*        ( typ  = ms_const-c_listheader_typ	key  = c_lines	info = TEXT-014	)
*     "   ( typ  = ms_const-c_listheader_typ	key  = is_stats-upd_msb_ok	info = TEXT-015	)
*     "   ( typ  = ms_const-c_listheader_typ	key  = is_stats-upd_msb_er	info = TEXT-016	)
*    ).
*
  ENDMETHOD.                    "build_header


ENDCLASS.
