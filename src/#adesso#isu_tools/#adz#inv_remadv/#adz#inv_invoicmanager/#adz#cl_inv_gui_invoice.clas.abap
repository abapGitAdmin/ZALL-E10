CLASS /adz/cl_inv_gui_invoice DEFINITION INHERITING FROM /adz/cl_inv_gui_alv_common
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



CLASS /ADZ/CL_INV_GUI_INVOICE IMPLEMENTATION.


  METHOD constructor.
    super->constructor(
       iv_repid =  iv_repid
       iv_vari   = iv_vari ).
  ENDMETHOD.


  METHOD display_data.

    " Usergruppenspezifische Knöpfe ausblenden
    DATA(lt_excl_func_names) = get_exclude_functions( VALUE stringtab(
      ( |STAT_RESET| )
      ( |PROCESS| )
      ( |COMPLAIN| )
      ( |CANCEL| )
      ( |BEENDEN| )
      ( |REFERENZ| )
      ( |LOG| )
      ( |PRUEFUNGEN| )
      ( |SPERREN| )
      ( |ENET| )
      ( |STATISTIK| )
      ( |SIM_VP| )
      ( |RELEASE| )
      ( |DELVNOTEMAN| ) ) ).

    init_display(
      EXPORTING        if_event_handler  = if_event_handler
                       it_funcnames_excl = lt_excl_func_names
                       ib_use_pf_status  = abap_false
      CHANGING         crt_data          = crt_data
    ).

    "set_screen_status( 'STANDARD_STATUS' ).

    " Anzeigen
    display( ).
  ENDMETHOD.


  METHOD get_column_definition.
    DATA lt_fieldcat TYPE lvc_t_fcat. "slis_t_fieldcat_alv.

    lt_fieldcat = VALUE #(
       ( fieldname = 'LIGHTS'    tech = 'X' )
       ( fieldname = 'XSELP'     tech = 'X' )
       ( fieldname = 'SEL'       key = 'X'   checkbox = 'X'    scrtext_s = 'Selektion'  edit = 'X' auto_value = 'X' outputlen = '3'  ) "input = 'X'
       ( fieldname = 'LS_NUMMER' hotspot = 'X' outputlen = '15'"       ref_fieldname = '/IDEXGE/RFF_ACE'   ref_table   = 'TINV_INV_DOC'
            scrtext_s = 'LS-Nummer'   scrtext_m = 'LieferscheinNr' scrtext_l = 'LieferscheinNummer' )
       ( fieldname = 'LS_MOVEINDATE'  scrtext_s = 'LS EingDat'  scrtext_m = 'LS Eingangsdatum' outputlen = '10' )
       ( fieldname = 'LS_STATUS'      scrtext_s = 'LS-Status'   scrtext_m = 'LieferscheinStatus' scrtext_l = 'LieferscheinStatus'
                ref_field = 'STATUS'   ref_table = 'EIDESWTDOC'   domname = 'EIDESWTSTAT' f4availabl = 'X' outputlen = '4' )
       ( fieldname = 'LS_STATUS_TEXT' scrtext_s = 'LSStText'    scrtext_m = 'LS-Statustext'  )
       ( fieldname = 'LS_STATUS_DATE' scrtext_s ='LSStDate'     scrtext_m = 'LS-StatusDatum' scrtext_l = 'LS-StatusDatum' outputlen = '10' )
       ( fieldname = 'WAITING'        scrtext_s = 'Wartend'     scrtext_m = 'In Warteschritt' scrtext_l = 'In Warteschritt'  outputlen = '50' )
       ( fieldname = 'WAITING_TO'   scrtext_s = 'Wartend bis' scrtext_m = 'In Warteschritt bis' scrtext_l = 'In Warteschritt bis' )
        "  outputlen = '5'   hotspot = 'X'.
       ( fieldname = 'MULTI_ERR' scrtext_m = 'Mult.Fehler' hotspot = 'X' )
       ( fieldname = 'MEMI'   scrtext_m = 'MEMI'    hotspot = ' '  icon = 'X' )
       ( fieldname = 'LOCKED' scrtext_m = 'Sperre'  hotspot = ' '  icon = 'X' )
       ( fieldname = 'TEXT_BEM' scrtext_m = 'Bemerkung-Txt'  hotspot = 'X' )
       ( fieldname = 'TEXT_VORHANDEN'  scrtext_m = 'Bemerkung'   hotspot = 'X' outputlen = '4' )
       ( " stornobelnr
         fieldname = 'PROCESS' scrtext_s = 'Prozess' ) "  ref_table = 'BELEGART'.
       ( " Interne Nummer des Rechnungsbelegs/Avisbelegs
         fieldname = 'INT_INV_DOC_NO' key = 'X'  hotspot = 'X'  ref_table = 'TINV_INV_DOC' outputlen = '9' )
       (  " Interne Bezeichnung des Rechnung-/Avisempfängers
         fieldname = 'INT_RECEIVER'    hotspot = 'X'     ref_table = 'TINV_INV_HEAD'  )  "key = 'X'
       (  " Interne Bezeichnung des Rechnungs-/Avissenders
         fieldname = 'INT_SENDER'      hotspot = 'X'  ref_table = 'TINV_INV_HEAD'  ) "key = 'X'.
         " Interne Bezeichnung des Rechnungs-/Avissenders
       ( fieldname = 'CASENR' hotspot = 'X'  ref_table = 'EMMA_CASE'    ) "key = 'X'
         " Interne Bezeichnung des Rechnungs-/Avissenders
       ( fieldname = 'CASETXT' ref_table = 'EMMA_CASE'    ) "key = 'X'  hotspot = 'X'
         " Status der Rechnung/des Avises
      " ( fieldname = 'INVOICE_STATUS' ref_table = 'TINV_INV_HEAD' )  "key = 'X'*
         "  Eingangsdatum des Dokumentes
       ( fieldname = 'DATE_OF_RECEIPT'  ref_table = 'TINV_INV_HEAD' outputlen = '10'  )  "key = 'X'
         " Externe Rechnungsnummer/Avisnummer
       ( fieldname = 'EXT_INVOICE_NO' ref_table = 'TINV_INV_DOC' hotspot = 'X' )
         "Belegart
       ( fieldname = 'BELEGART'  scrtext_s = 'Art'  scrtext_l = 'Rechnungsart'   outputlen = '5'  ) " ref_table = 'BELEGART'
         " Art des Belegs
       ( fieldname = 'DOC_TYPE'   ref_table = 'TINV_INV_DOC' )
         " Status des Belegs
       ( fieldname = 'INV_DOC_STATUS'   ref_table = 'TINV_INV_DOC' outputlen = '4'   )
       ( fieldname = 'INVOICE_STATUS_T'  scrtext_m    = 'BelStatus' outputlen = '5' ) "    reptext_ddic = 'X'  *  hotspot = 'X'.
         " stornobelnr
       ( fieldname = 'STORNOBELNR' scrtext_s = 'Storno'  scrtext_l = 'Stornobeleg'   no_zero = 'X' ) " ref_table = 'BELEGART'

       ( " Langtext
         fieldname = 'FREE_TEXT1'  ref_table = '/IDEXGE/REJ_NOTI' )

       ( " REMADV-Nummer +++
         fieldname = 'REMADV'  hotspot = 'X' scrtext_s = 'REMADV1') "scrtext_m = 'REMADV-Nr' )
       ( " REMADV-Datum
         fieldname = 'REMDATE' scrtext_m = 'R1-Datum' )
       (  " Differenzgrund bei Zahlungen
         fieldname = 'RSTGR'   scrtext_m = 'R1-DiffGrund'  ) " ref_table = 'TINV_INV_LINE_A' )
       ( " REMADV-Fälligkeitsdatum
         fieldname = 'DATE_OF_PAYMENT' scrtext_m = 'Fälligk.dat.'  ) " ref_table = 'TINV_INV_DOC' )

       ( fieldname = 'RSTVS'  scrtext_s = 'RekVorschlag'      scrtext_m = 'Reklamations Vorschlag' )
       ( fieldname = 'RSTVS_TEXT'  scrtext_s = 'RekVorsText'  scrtext_m = 'Rekla.Vorschl. Text' )

       ( " REMADV2-Nummer++++
         fieldname = 'REMADV2'       scrtext_s = 'REMADV2'    hotspot  = 'X'   )
       ( " REMADV2-Datum
         fieldname = 'REMDATE2'      scrtext_m = 'R2-Datum'  outputlen = '10' )
       (  "REMADV2-Differenzgrund bei Zahlungen
         fieldname = 'RSTGR2'        scrtext_m = 'R2-DiffGrund'  ) " ref_table = 'TINV_INV_LINE_A' )
"       ( " REMADV2-Fälligkeitsdatum
"         fieldname = 'DATE_OF_PAYMENT2' scrtext_m = 'R2-Fälligk.dat.'  ) " ref_table = 'TINV_INV_DOC' )
"       ( " REMADV2-Langtext
"         fieldname = 'FREE_TEXT1_2'  scrtext_m = 'REMADV2-Txt'   ) " ref_table = '/IDEXGE/REJ_NOTI' )

       ( " COMDIS +++
         fieldname = 'COMDIS'      scrtext_s = 'COMIS-NR'  scrtext_m = 'COMIS-NR' scrtext_l = 'COMIS-NR' hotspot  = 'X'   )
       ( " PDocRef
         fieldname = 'PDOC_REF'    scrtext_s = 'PDOC-REF' scrtext_m = 'PDOC-Referenz'  hotspot  = 'X'   )
         " DA-Gruppenreferenznummer
       ( fieldname = 'INV_BULK_REF'   ref_table = 'TINV_INV_DOC'  hotspot = 'X'   )
         " Datum der Rechnung oder des Avises
       ( fieldname = 'INVOICE_DATE'    ref_table = 'TINV_INV_DOC' )
         " Beginn des Zeitraums für den die Rechnung/das Avis gilt
       ( fieldname = 'INVPERIOD_START'    ref_table = 'TINV_INV_DOC' )
         " Ende des Zeitraums für den die Rechnung/das Avis gilt
       ( fieldname = 'INVPERIOD_END'    ref_table = 'TINV_INV_DOC' )
       ( fieldname = 'MSC_START'    scrtext_s = 'MSC Beginn' ) "  ref_table = 'TINV_INV_DOC' )
       ( fieldname = 'MSC_END'    scrtext_s = 'MSC Ende' )     "   ref_table = 'TINV_INV_DOC' )
         " Name 1/Nachname
       ( fieldname = 'MC_NAME1'    ref_table = 'TINV_INV_EXTID' )
         " Name 2/Vorname
       ( fieldname = 'MC_NAME2'    ref_table = 'TINV_INV_EXTID' )
         " Straßenname
       ( fieldname = 'MC_STREET'    ref_table = 'TINV_INV_EXTID' )
         " Hausnummer
       ( fieldname = 'MC_HOUSE_NUM1' ref_table = 'TINV_INV_EXTID' )
         " Ortsname
       ( fieldname = 'MC_CITY1'    ref_table = 'TINV_INV_EXTID' )
         " Postleitzahl des Orts
       ( fieldname = 'MC_POSTCODE'    ref_table = 'TINV_INV_EXTID' )
       ( " Externe Identifizierung eines Belegs (zB Zählpunkt)
         "fieldname = 'EXT_IDENT' scrtext_s = 'Mktlok-ID'  scrtext_m = 'Marktlok-ID' scrtext_l = 'Marktlokations-ID'
         fieldname = 'EXT_IDENT' hotspot = 'X'  ref_table = 'TINV_INV_EXTID' no_out = '' tech = '' )
       ( " Anlage
         fieldname = 'ANLAGE'  ref_table = 'EANLH'   hotspot = 'X'   )
       ( " Vertrag
         fieldname = 'VERTRAG'  scrtext_s = 'Vertrag'  ref_table = 'EVER'  hotspot = 'X'   )
       ( " Vertragskontonummer
         fieldname = 'VKONTO'  scrtext_s = 'Vertragskonto'  ref_table = 'EVER' )
         " Abrechnungsklasse
       ( fieldname = 'AKLASSE'   ref_table = 'EANLH' )
       (  " Tariftyp
         fieldname = 'TARIFTYP'  ref_table = 'EANLH'  hotspot = 'X' )
       (  " Ableseeinheit
         fieldname = 'ABLEINH'   ref_table = 'EANLH'   hotspot = 'X' )
         " Bruttobetrag in Transaktionswährung mit Vorzeichen
       ( fieldname = 'BETRW'     no_zero = 'X' do_sum = 'X'  ref_table = 'TINV_INV_LINE_B' )
         " Steuerbetrag in Transaktionswährung
       ( fieldname = 'TAXBW'    no_zero = 'X'  do_sum = 'X'  ref_table = 'TINV_INV_LINE_B' )
         " Steuerpfl Betrag in Transaktionswährung (Steuerbasisbetrag)
       ( fieldname = 'SBASW'    no_zero = 'X'  do_sum = 'X'  ref_table = 'TINV_INV_LINE_B' )
         "Menge Wirkarbeit
       ( fieldname = 'QUANTITY' no_zero = 'X'  do_sum = 'X'  ref_table = 'TINV_INV_LINE_B'
           scrtext_s = 'Wirkarbeit in kWh'  scrtext_m = 'Wirkarbeit in kWh'  scrtext_l = 'Wirkarbeit in kWh'  )
"  IF p_err IS NOT INITIAL
       ( fieldname = 'FEHLER'  hotspot = 'X'  scrtext_s = 'Fehler' scrtext_m = 'Fehlermeldung' scrtext_l = 'Fehlermeldung'
           outputlen = '120' )
"  ENDIF
       ).
    LOOP AT lt_fieldcat ASSIGNING FIELD-SYMBOL(<ls_fieldcat>).
      IF <ls_fieldcat>-ref_table IS INITIAL.
        <ls_fieldcat>-ref_table = '/ADZ/OUT_INVREMA'.  " F1-Wertehilfe
        <ls_fieldcat>-colddictxt = 'M'.
        <ls_fieldcat>-scrtext_m = COND #( WHEN <ls_fieldcat>-scrtext_m IS INITIAL THEN  <ls_fieldcat>-scrtext_s ELSE <ls_fieldcat>-scrtext_m ).
      ENDIF.
    ENDLOOP.
    rt_fieldcat = lt_fieldcat.
*    DATA ls_fcat TYPE lvc_s_fcat.
*    LOOP AT lt_fieldcat INTO ls_fieldcat.
*      MOVE-CORRESPONDING ls_fieldcat TO ls_fcat.
*      ls_fcat-ref_table = ref_tabname.
*      ls_fcat-scrtext_l = seltext_l.
*      ls_fcat-scrtext_m = seltext_m.
*      ls_fcat-scrtext_s = seltext_s.
*      APPEND ls_fcat TO rt_fieldcat.
*    ENDLOOP.

  ENDMETHOD.


  METHOD handle_toolbar.
* § 2.In event handler method for event TOOLBAR: Append own functions
*   by using event parameter E_OBJECT.
*....................................................................
* E_OBJECT of event TOOLBAR is of type REF TO CL_ALV_EVENT_TOOLBAR_SET.
* This class has got one attribute, namly MT_TOOLBAR, which
* is a table of type TTB_BUTTON. One line of this table is
* defined by the Structure STB_BUTTON (see data deklaration above).
*

* A remark to the flag E_INTERACTIVE:
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*         'e_interactive' is set, if this event is raised due to
*         the call of 'set_toolbar_interactive' by the user.
*         You can distinguish this way if the event was raised
*         by yourself or by ALV
*         (e.g. in method 'refresh_table_display').
*         An application of this feature is still unknown... :-)

    e_object->mt_toolbar = VALUE #(
      "MOVE 'Show Bookings'(111) TO quickinfo.
      ( LINES OF /adz/cl_inv_gui_alv_common=>get_fc_standard( ) )
      ( function = 'RELEASE' icon = icon_release        text = '' quickinfo = 'Manuell Freigeben.' disabled = ' '  )
      ( function = 'STAT_RESET' icon = icon_system_undo text = '' quickinfo = 'Manuell zurücksetzen' disabled = ' ' )
      ( function = 'PROCESS' icon = icon_execute_object text = '' quickinfo = 'Prozessieren' disabled = ' '  )
      ( function = 'COMPLAIN' icon = icon_status_reverse text = 'Reklamieren' quickinfo = 'Reklamieren' disabled = ' ' )
      ( function = 'CANCEL'   icon = icon_storno         text = '' "Zu Stornieren'
            quickinfo = 'Status ''Zu stornieren'' setzen.' disabled = ' '  )
      ( function = 'BEENDEN' icon = icon_booking_stop text = ''  "'Verarb. beenden'
            quickinfo = 'Status: Auf beendet setzen.' disabled = ' ' )
      ( function = 'REFERENZ' icon = icon_relationship text = 'Referenz' quickinfo = 'Referenz' disabled = ' '  )
      ( function = 'LOG' icon = icon_protocol text = '' quickinfo = 'Protokoll anzeigen' disabled = ' '  )
      ( function = 'PRUEFUNGEN' icon = icon_intensify text = '' quickinfo = 'Prüfungen Ein/Ausschalten' disabled = ' ' )
      ( function = 'SPERREN' icon = icon_locked text = '' quickinfo = 'Beleg sperren/entsperren' disabled = ' '  )
      ( butn_type = 3 ) " append a separator to normal toolbar
      ( function = 'ENET'  text = 'ene''t' quickinfo = '' disabled = ' ' )
      ( function = 'STATISTIK' icon = icon_information text = 'STAT' quickinfo = 'Statistik' disabled = ' '  )
      ( function = 'SIM_VP' icon = icon_simulate text = '' quickinfo = 'Verbrauch Simulieren' disabled = ' '  )
      ( function = 'DELVNOTEMAN' text = 'DNMan' quickinfo = 'Lieferschein Manager' disabled = ' '  )
    ).
    " excludierte functions wieder rausfischen
    LOOP AT mt_excl_functions ASSIGNING FIELD-SYMBOL(<ls_excl_func>).
      DELETE e_object->mt_toolbar WHERE function = <ls_excl_func>-fcode.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
