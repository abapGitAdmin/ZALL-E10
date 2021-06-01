CLASS /adz/cl_inv_gui_reklamon DEFINITION INHERITING FROM /adz/cl_inv_gui_alv_common
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    DATA mv_invtyp         TYPE /adz/inv_s_sel_screen-p_invtp.
    DATA mo_event_handler  TYPE  REF TO /adz/if_inv_salv_table_evt_hlr.

    METHODS :
      constructor
        IMPORTING
          iv_invtyp TYPE /adz/inv_s_sel_screen-p_invtp
          iv_repid  TYPE repid
          iv_vari   TYPE slis_vari OPTIONAL,
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



CLASS /ADZ/CL_INV_GUI_REKLAMON IMPLEMENTATION.


  METHOD constructor.
    super->constructor(
       iv_repid =  iv_repid
       iv_vari   = iv_vari ).
    mv_invtyp = iv_invtyp.
  ENDMETHOD.


  METHOD display_data.
    mo_event_handler = if_event_handler.

    " Usergruppenspezifische Knöpfe ausblenden
    SELECT * FROM /adz/fi_remad INTO TABLE @DATA(lt_fi_negrem) WHERE negrem_option = 'EXCLUDE'.
    DATA(lt_excl_func) = VALUE stringtab( FOR ls IN lt_fi_negrem ( CONV #( ls-negrem_field ) ) ).

    init_display(
      EXPORTING        if_event_handler  = mo_event_handler
                       it_funcnames_excl = lt_excl_func
                       ib_use_pf_status  = abap_false
      CHANGING         crt_data          = crt_data
    ).

    "set_screen_status( 'STANDARD_STATUS' ).

    " Anzeigen
    display( ).
  ENDMETHOD.


  METHOD get_column_definition.
    SELECT negrem_field, negrem_option FROM /adz/fi_remad INTO TABLE @DATA(lt_adz_remad)  WHERE negrem_value = 'X'.

    rt_fieldcat = VALUE #(
       ( fieldname = 'XSELP' tech = 'X' )
       ( fieldname = 'SEL'       key = 'X'  checkbox = 'X'  scrtext_s = 'Selektion' edit = 'X' ) " input = 'X'
       ( " Interne Nummer des Rechnungsbelegs/Avisbeleg
         fieldname = 'INT_INV_DOC_NO'  key = 'X' hotspot = 'X' ref_table = 'TINV_INV_DOC' )
       ( fieldname = 'TEXT_VORHANDEN'  scrtext_s = 'Bem.' scrtext_m = 'Bemerkung' scrtext_l = 'Bemerkung' hotspot = 'X' )
       ( "zeilennummer /Avisbeleg
         fieldname = 'INT_INV_LINE_NO'  no_out = 'X' ref_table = 'TINV_INV_LINE_A' )
       ( "Interne Bezeichnung des Rechnung-/Avisempfänger
         fieldname = 'INT_RECEIVER'  key = 'X' scrtext_s = 'Empfänger' scrtext_m = 'Empfänger' scrtext_l = 'Empfänger' hotspot = 'X' ref_table = 'TINV_INV_HEAD' )
       ( "Interne Bezeichnung des Rechnungs-/Avissender
         fieldname = 'INT_SENDER'  key = 'X' scrtext_s = 'Sender' scrtext_m = 'Sender' scrtext_l = 'Sender' hotspot = 'X' ref_table = 'TINV_INV_HEAD' )
       ( " Status-Icon für Mahnsperre
         fieldname = 'LINE_STATE' icon = 'X'   scrtext_s = 'Z.Stat' scrtext_m = 'Zeil.Stat' scrtext_l = 'Zeilen Status' )
       ( "interner Status
         fieldname = 'FREE_TEXT4' hotspot = 'X' scrtext_s = 'I.Stat' scrtext_m = 'Int.Stat.' scrtext_l = 'Interner Status'  outputlen = 10 )
       ( " Aggr. Vertragskonto des Senders
         fieldname = 'AGGVK'    key = 'X'  scrtext_s = 'Aggr.Vk NNE'  scrtext_m = 'Aggr.Vkonto NNE'  scrtext_l = 'Aggr.Vkonto NNE'  hotspot = 'X' )
       ( " Status der Rechnung/des Avises
         fieldname = 'INVOICE_STATUS'  key = 'X' ref_table = 'TINV_INV_HEAD' )
       ( "  Eingangsdatum des Dokumentes
         fieldname = 'DATE_OF_RECEIPT'  key = 'X' ref_table = 'TINV_INV_HEAD' )
       ( " Status-Icon für Prozessstatus
         fieldname = 'PROCESS_STATE'  icon = 'X' scrtext_s = 'Pr.Status' scrtext_m = 'Pr.Status' scrtext_l = 'Prozessstatus' )
         " DA-Gruppenreferenznummer
       ( fieldname = 'INV_BULK_REF'   ref_table = 'TINV_INV_DOC'  hotspot = 'X'   )
       (  " Tariftyp
         fieldname = 'TARIFTYP'  ref_table = 'EANLH'  hotspot = 'X' )
       ( " Anlage
         fieldname = 'ANLAGE'  ref_table = 'EANLH'   hotspot = 'X'   )

       ( " Status-Icon für Storner_coostatus
         fieldname = 'CANCEL_STATE' icon = 'X'
            scrtext_s = COND #( WHEN  mv_invtyp EQ /adz/cl_inv_select_reklamon=>mco_msb                    THEN 'StStAbbel'
                                WHEN  mv_invtyp EQ /adz/cl_inv_select_reklamon=>mco_nn OR mv_invtyp EQ ''  THEN 'St.Status'
                                ELSE  'St.Stat. NNE'   )
            scrtext_m = COND #( WHEN  mv_invtyp EQ /adz/cl_inv_select_reklamon=>mco_msb                    THEN 'StStatAbrbel'
                                WHEN  mv_invtyp EQ /adz/cl_inv_select_reklamon=>mco_nn OR mv_invtyp EQ ''  THEN 'St.Status'
                                ELSE  'St.Status NNE'   )
            scrtext_l = COND #( WHEN  mv_invtyp EQ /adz/cl_inv_select_reklamon=>mco_msb                    THEN 'Storno-Status CI-Abrbel'
                                WHEN  mv_invtyp EQ /adz/cl_inv_select_reklamon=>mco_nn OR mv_invtyp EQ ''  THEN 'Storno Status'
                                ELSE  'Storno-Status NNE'   ) )
       ( " status-icon für stornostatus
         fieldname = 'CANCEL_STATE_MM'  icon = 'X' scrtext_s = 'St.StatMMMA' scrtext_m = 'St.Status MMMA' scrtext_l = 'Storno-Status MMMA' )
       ( " Status-Icon für Mailversand
         fieldname = 'COMM_STATE'  icon = 'X' scrtext_s = 'Kom.Status' scrtext_m = 'Kom.Status' scrtext_l = 'Kommunikationsstatus' )
       ( " Status-Icon Storno-Crossrefno
         fieldname = 'INF_INVOICE_CANCEL'  icon = 'X' scrtext_s = 'St.int.Bel.' scrtext_m = 'St.int.Bel.' scrtext_l = 'Storno int. Beleg' )
       ( " Langtext
         fieldname = 'FREE_TEXT5' hotspot = 'X' scrtext_s = 'Notiz' scrtext_m = 'Notiz' scrtext_l = 'Notiz' outputlen = 10 )
"       ( " Zahlungsavis
"         fieldname = 'PAYM_AVIS' emphasize = 'C30' hotspot = 'X' scrtext_s = 'RAvis.' scrtext_m = 'Rekl.A' scrtext_l = 'Reklamationsavis' )
       ( " Status-Icon Storno-status
         fieldname = 'PAYM_STAT'  emphasize = 'C30' scrtext_s = 'RAStat.' scrtext_m = 'RAStat.' scrtext_l = 'Reklamationsavis Status'
           ref_table = 'TINV_INV_HEAD' ref_field = 'INVOICE_STATUS' )
       ( " Externe Rechnungsnummer/Avisnummer
         fieldname = 'EXT_INVOICE_NO'  emphasize = 'C30' ref_table = 'TINV_INV_DOC' )
       ( " Interne Belegnummer
         fieldname = 'OWN_INVOICE_NO'  emphasize = 'C30' ref_table = 'TINV_INV_LINE_A'
             hotspot = COND #( WHEN mv_invtyp EQ /adz/cl_inv_select_reklamon=>mco_nn THEN 'X'  ELSE '' ) )
       ( " Art des Belegs
         fieldname = 'DOC_TYPE'  emphasize = 'C30' ref_table = 'TINV_INV_DOC' )
       ( " Status des Belegs
         fieldname = 'INV_DOC_STATUS'  emphasize = 'C30' ref_table = 'TINV_INV_DOC' )
       ( " Fälligkeitsdatum
         fieldname = 'DATE_OF_PAYMENT'  emphasize = 'C30' ref_table = 'TINV_INV_DOC' no_out = 'X' )
       ( " Datum der Rechnung oder des Avises
         fieldname = 'INVOICE_DATE'  emphasize = 'C30' ref_table = 'TINV_INV_DOC' )
       ( " Differenzgrund bei Zahlungen
         fieldname = 'RSTGR'  emphasize = 'C30' ref_table = 'TINV_INV_LINE_A' )
       ( " Text
         fieldname = 'TEXT'  emphasize = 'C30' ref_table = 'TINV_C_ADJ_RSNT' )
       ( " Langtext
         fieldname = 'FREE_TEXT1'  emphasize = 'C30' ref_table = '/IDEXGE/REJ_NOTI' hotspot = 'X' )
       ( "Externe Identifizierung eines Belegs (z.B. Zählpunkt)
         fieldname = 'EXT_UI'  hotspot = 'X' emphasize = 'C30' scrtext_s = 'Malo-ID'
             scrtext_m = 'Malo-ID / ZP-Bez' scrtext_l = 'Malo-ID / Zählpunktbez' )  "  ref_table = 'EUITRANS'.
       ( " Abrechnungsklasse der Anlage
         fieldname = 'AKLASSE'  emphasize = 'C30' ref_table = 'EANLH'  domname = 'AKLASSE' f4availabl = 'X'  )
       ( "** Externer Zählpunkt MeLo-Anlage
         fieldname = 'EXT_UI_MELO'  emphasize = 'C30' hotspot = 'X' scrtext_s = 'ZP Melo' scrtext_m = 'ZP Melo-Anlage' scrtext_l = 'Zählpunkt Melo-Anlage' )
       ( "* Multiple Melos
         fieldname = 'MULT_MELO'  emphasize = 'C30' scrtext_s = 'Mult Melo' )
       ( " Interne Crossreferenz
         fieldname = 'INT_CROSSREFNO'  hotspot = 'X' emphasize = 'C30' ref_table = 'ECROSSREFNO' no_out = 'X' )
       ( " Bruttobetrag (angefordert) in Transaktionswährung
         fieldname = 'BETRW_REQ'  no_zero = 'X' do_sum = 'X' emphasize = 'C30' ref_table = 'TINV_INV_LINE_A' no_out = 'X' )
    ).
    IF NOT line_exists( lt_adz_remad[ negrem_option = 'FIELDCAT' negrem_field = 'BEMERKUNG'  ] ).
      DELETE rt_fieldcat WHERE fieldname = 'TEXT_VORHANDEN'.
    ENDIF.
    IF NOT line_exists( lt_adz_remad[ negrem_option = 'LINE_STATE' negrem_field = 'SHOW' ] ).
      DELETE rt_fieldcat WHERE fieldname = 'LINE_STATE'.
    ENDIF.
    IF NOT line_exists( lt_adz_remad[ negrem_option = 'INTSTAT' negrem_field = 'SHOW' ] ).
      DELETE rt_fieldcat WHERE fieldname = 'FREE_TEXT4'.
    ENDIF.
    IF NOT line_exists( lt_adz_remad[ negrem_option = 'FIELDCAT' negrem_field = 'NOTIZ' ] ).
      DELETE rt_fieldcat WHERE fieldname = 'FREE_TEXT5'.
    ENDIF.
    IF mv_invtyp EQ /adz/cl_inv_select_reklamon=>mco_msb.
      DELETE rt_fieldcat WHERE fieldname = 'AGGVK'.
    ENDIF.

    IF mv_invtyp EQ /adz/cl_inv_select_reklamon=>mco_memi
    AND NOT line_exists( lt_adz_remad[ negrem_option = 'CANCELSTATE' negrem_field = 'SHOW' ] ).
      DELETE rt_fieldcat WHERE fieldname = 'CANCEL_STATE_MM'.
    ENDIF.

    IF mv_invtyp EQ /adz/cl_inv_select_reklamon=>mco_nn.
      rt_fieldcat = VALUE #( BASE rt_fieldcat
           ( " Kennz. Beleg aus manueller Abrechnung
              fieldname = 'ZISUMABR' hotspot = 'X' emphasize = 'C50'
               scrtext_s = 'Man.Abr.' scrtext_m = 'Kennz. manuelle Abr.' scrtext_l = 'Beleg aus manueller Abrechnung' )
           ( " Nummer eines Belegs des Vertragskontokorrents
             fieldname = 'OPBEL'  hotspot = 'X' emphasize = 'C50' ref_table = 'DFKKTHI' )
           ( " Wiederholungsposition im Beleg des Vertragskontokorrents
             fieldname = 'OPUPW'  emphasize = 'C50' ref_table = 'DFKKTHI' no_out = 'X' )
           ( " Positionsnummer im Beleg des Vertragskontokorrents
             fieldname = 'OPUPK'  emphasize = 'C50' ref_table = 'DFKKTHI' )
           ( " Teilposition zu einem Teilausgleich im Beleg
             fieldname = 'OPUPZ'  emphasize = 'C50' ref_table = 'DFKKTHI' no_out = 'X' )
           ( " Laufende Nummer des DFKKTHI Eintrags zu einer Belegposition
             fieldname = 'THINR'  emphasize = 'C50' ref_table = 'DFKKTHI' no_out = 'X' )
           ( " Fälligkeitsdatum für den Dritten
             fieldname = 'THIDT'  emphasize = 'C50' ref_table = 'DFKKTHI' )
           ( " Status des Eintrags
             fieldname = 'THIST'  emphasize = 'C50' ref_table = 'DFKKTHI' no_out = 'X' )
           ( " Beleg wurde storniert
             fieldname = 'STORN'  emphasize = 'C50' ref_table = 'DFKKTHI' )
           ( " Herkunft des Eintrags ist Storno
             fieldname = 'STIDC'  emphasize = 'C50' ref_table = 'DFKKTHI' )
           ( " Bruttobetrag in Transaktionswährung
             fieldname = 'BETRW'  no_zero = 'X' do_sum = 'X' emphasize = 'C50' ref_table = 'DFKKTHI' )
           ( " Geschäftspartnernummer
             fieldname = 'GPART'  hotspot = 'X' emphasize = 'C50' ref_table = 'DFKKTHI' no_out = 'X' )
           ( " Vertragskontonummer
             fieldname = 'VKONT'  hotspot = 'X' emphasize = 'C50' ref_table = 'DFKKTHI' )
           ( " Referenzangaben aus dem Vertrag
             fieldname = 'VTREF'  hotspot = 'X' emphasize = 'C50' ref_table = 'DFKKTHI' )
           ( " Belegnummer der Buchung auf das Serviceanbieter-Konto
             fieldname = 'BCBLN'  hotspot = 'X' emphasize = 'C50' ref_table = 'DFKKTHI' )
           ( " Referenzbelegnummer
             fieldname = 'XBLNR'  hotspot = 'X' emphasize = 'C50' ref_table = 'DFKKOP' )
           ( " Spartentyp: Stron oder Gas
             fieldname = 'SPARTYP'  emphasize = 'C50' ref_table = '/IDEXGE/DEV_TYPE' )
             " Lieferschein
           ( fieldname = 'LS_NUMMER' emphasize = 'C10' hotspot = 'X' "       ref_fieldname = '/IDEXGE/RFF_ACE'   ref_table   = 'TINV_INV_DOC'
                                      scrtext_s = 'LS-Nummer'   scrtext_m = 'LieferscheinNr' scrtext_l = 'LieferscheinNummer' )
           ( fieldname = 'LS_MOVEINDATE' emphasize = 'C10' scrtext_s = 'LS EingDat'  scrtext_m = 'LS Erstellungsdatum' )
           ( fieldname = 'LS_STATUS'  emphasize = 'C10'    scrtext_s = 'LS-Status'   scrtext_m = 'LieferscheinStatus'  scrtext_l = 'LieferscheinStatus'
                ref_field = 'STATUS'   ref_table = 'EIDESWTDOC'   domname = 'EIDESWTSTAT' f4availabl = 'X' )
           ( fieldname = 'LS_STATUS_TEXT'  emphasize = 'C10' scrtext_s = 'LSStText'    scrtext_m = 'LS-Statustext'  )
           ( fieldname = 'LS_STATUS_DATE' emphasize = 'C10'  scrtext_s ='LSStDate'     scrtext_m = 'LS-StatusDatum' )

           ( " REMADV1-Nummer +++
             fieldname = 'REMADV'  hotspot = 'X' scrtext_m = 'REMADV1-Nr' )
           ( " REMADV1-Datum
             fieldname = 'REMDATE'  scrtext_m = 'R1-Datum' )
           (  " Differenzgrund bei Zahlungen
             fieldname = 'RSTGR1'   scrtext_m = 'R1-DiffGrund'  ) " ref_table = 'TINV_INV_LINE_A' )

           ( " REMADV2-Nummer++++
             fieldname = 'REMADV2'       scrtext_s = 'REMADV2-Nr'    hotspot  = 'X'   )
           ( " REMADV2-Datum
             fieldname = 'REMDATE2'      scrtext_m = 'R2-Datum' )
           (  "REMADV2-Differenzgrund bei Zahlungen
             fieldname = 'RSTGR2'        scrtext_m = 'R2-DiffGrund'  ) " ref_table = 'TINV_INV_LINE_A' )
           ( " COMDIS +++
             fieldname = 'COMDIS'      scrtext_s = 'COMDIS-NR'   hotspot  = 'X'   )
       ).
      IF NOT line_exists( lt_adz_remad[ negrem_option = 'FIELDCAT' negrem_field = 'ZISUMABR' ] ).
        DELETE rt_fieldcat WHERE fieldname = 'ZISUMABR'.
      ENDIF.

    ELSEIF mv_invtyp EQ /adz/cl_inv_select_reklamon=>mco_memi.
      rt_fieldcat = VALUE #( BASE rt_fieldcat
         (  " Aggr. Vertragskonto des Senders
           fieldname = 'SUPPL_CONTR_ACCT'  ref_table = '/IDXMM/MEMIDOC' key = 'X' hotspot = 'X'
              scrtext_s = 'Aggr.Vk MEMI' scrtext_m = 'Aggr.Vkonto MEMI' scrtext_l = 'Aggr.Vkonto MEMI'  )
         ( fieldname = 'DOC_ID'  hotspot = 'X' ref_table = '/IDXMM/MEMIDOC' )
         ( fieldname = 'DOC_STATUS'  ref_table = '/IDXMM/MEMIDOC' )
         ( fieldname = 'CROSSREFNO'  ref_table = '/IDXMM/MEMIDOC' hotspot = 'X' )
         "   Zusätzliche FElder für Mahnsperren Memi
         ( fieldname = 'MAHNSP' scrtext_s = 'MSp' scrtext_m = 'Mahnsperre'  )
         ( fieldname = 'FDATE' scrtext_s = 'ab' scrtext_m = 'gültig ab'  )
         ( fieldname = 'TDATE' scrtext_s = 'ab' scrtext_m = 'gültig bis'  )
         ( fieldname = 'DIVISION'  ref_table = '/IDXMM/MEMIDOC' )
      "   ( fieldname = 'DIST_SP'  ref_table = '/IDXMM/MEMIDOC' )
      "   ( fieldname = 'SUPPL_SP'  ref_table = '/IDXMM/MEMIDOC' )
         ( fieldname = 'SUPPL_BUPA'  ref_table = '/IDXMM/MEMIDOC' )
         ( fieldname = 'QUANTITY_TYPE'  ref_table = '/IDXMM/MEMIDOC' )
         ( fieldname = 'QUANTITY'  ref_table = '/IDXMM/MEMIDOC' )
         ( fieldname = 'APPLICATION_MONTH'  ref_table = '/IDXMM/MEMIDOC' )
         ( fieldname = 'APPLICATION_YEAR'  ref_table = '/IDXMM/MEMIDOC' )
         ( fieldname = 'START_DATE'  ref_table = '/IDXMM/MEMIDOC' )
         ( fieldname = 'END_DATE'  ref_table = '/IDXMM/MEMIDOC' )
         ( fieldname = 'PRICE'  ref_table = '/IDXMM/MEMIDOC' )
         ( fieldname = 'NET_AMOUNT'  ref_table = '/IDXMM/MEMIDOC' )
         ( fieldname = 'ENERGY_TAX_AMOUNT'  ref_table = '/IDXMM/MEMIDOC' )
         ( fieldname = 'GROSS_AMOUNT'  ref_table = '/IDXMM/MEMIDOC' )
         ( fieldname = 'TAX_CODE'  ref_table = '/IDXMM/MEMIDOC' )
         ( fieldname = 'TAX_RATE'  ref_table = '/IDXMM/MEMIDOC' )
         ( fieldname = 'TRIG_BILL_DOC_NO'  hotspot = 'X' ref_table = '/IDXMM/MEMIDOC'
              scrtext_s = 'AbrBelnrNNE' scrtext_m = 'AbrBelnrNNE.' scrtext_l = 'Abrechnungsbeleg Netznutzung' )
         ( fieldname = 'ERCHCOPBEL'   hotspot = 'X' "    ref_table = '/IDXMM/MEMIDOC' )
               scrtext_s = 'DruckbelNNE' scrtext_m = 'DruckbelNNE.' scrtext_l = 'Druckbeleg Netznutzung' )
         ( fieldname = 'TRIG_BILL_TRANSACT'  ref_table = '/IDXMM/MEMIDOC' )
         ( fieldname = 'TRIG_BILL_ORIG_START_DATE'  ref_table = '/IDXMM/MEMIDOC' )
         ( fieldname = 'TRIG_BILL_ORIG_END_DATE'  ref_table = '/IDXMM/MEMIDOC' )
         ( fieldname = 'TRIG_BILL_START_DATE'  ref_table = '/IDXMM/MEMIDOC' )
         ( fieldname = 'TRIG_BILL_END_DATE'  ref_table = '/IDXMM/MEMIDOC' )
         ( fieldname = 'TRIG_BILL_QUANTITY'  ref_table = '/IDXMM/MEMIDOC' )
         ( fieldname = 'TRIG_BILL_MEASURE_UNIT'  ref_table = '/IDXMM/MEMIDOC' )
         ( fieldname = 'TRIG_BILL_TRANS_PREVIOUS'  ref_table = '/IDXMM/MEMIDOC' )
         ( fieldname = 'TRIG_BILL_SPLIT'  ref_table = '/IDXMM/MEMIDOC' )
         ( fieldname = 'SETTLE_QUERY_END_DATE'  ref_table = '/IDXMM/MEMIDOC' )
         ( fieldname = 'SETTLE_QUERY_START_DATE'  ref_table = '/IDXMM/MEMIDOC' )
         ( fieldname = 'SETTLE_QUERY_END_DATE'  ref_table = '/IDXMM/MEMIDOC' )
         ( fieldname = 'SETTLE_START_DATE'  ref_table = '/IDXMM/MEMIDOC' )
         ( fieldname = 'SETTLE_END_DATE'  ref_table = '/IDXMM/MEMIDOC' )
         ( fieldname = 'SETTLE_QUANTITY'  ref_table = '/IDXMM/MEMIDOC' )
         ( fieldname = 'SETTLE_MEASURE_UNIT'  ref_table = '/IDXMM/MEMIDOC' )
         ( fieldname = 'COMPANY_CODE'  ref_table = '/IDXMM/MEMIDOC' )
         ( fieldname = 'DOC_DATE'  ref_table = '/IDXMM/MEMIDOC' )
         ( fieldname = 'POST_DATE'  ref_table = '/IDXMM/MEMIDOC' )
         ( fieldname = 'DUE_DATE'  ref_table = '/IDXMM/MEMIDOC' )
         ( fieldname = 'INV_SEND_DATE'  ref_table = '/IDXMM/MEMIDOC' )
         ( fieldname = 'CI_INVOIC_DOC_NO'  ref_table = '/IDXMM/MEMIDOC' hotspot = 'X' )
         ( fieldname = 'CI_FICA_DOC_NO'  ref_table = '/IDXMM/MEMIDOC' hotspot = 'X' )
         ( fieldname = 'OPUPK'  ref_table = '/IDXMM/MEMIDOC' hotspot = 'X' )
         ( fieldname = 'MSCONS_IDOC'  ref_table = '/IDXMM/MEMIDOC' hotspot = 'X' )
         ( fieldname = 'INVOIC_IDOC'  ref_table = '/IDXMM/MEMIDOC' hotspot = 'X' )
         ( fieldname = 'REMADV_IDOC'  ref_table = '/IDXMM/MEMIDOC' hotspot = 'X' )
         ( fieldname = 'BILLABLE_ITEM'  scrtext_s = 'Abrechenb.Pos' scrtext_m = 'Abrechenb.Pos' scrtext_l = 'Abrechenb.Pos' hotspot = 'X' )
         "( fieldname = 'INV_DOC_NO' ref_table = '/IDXMM/MEMIDOC' hotspot = 'X' )
      ).

    ELSEIF mv_invtyp EQ /adz/cl_inv_select_reklamon=>mco_mgv.
      rt_fieldcat = VALUE #( BASE rt_fieldcat
          ( fieldname = 'PROC_REF'  ref_table = '/IDXGC/PDOC_LOG' hotspot = 'X' )
          ( fieldname = 'OPBEL'     ref_table = 'DFKKOP'  hotspot = 'X' )
          ( fieldname = 'INVDOCNO'  ref_table = 'DFKKINVDOC_H'  hotspot = 'X' )
          ( fieldname = 'BILLDOCNO' ref_table = 'DFKKINVBILL_H' hotspot = 'X' )
          ( fieldname = 'REFDOCNO'  ref_table = 'DFKKINVBILL_H'  )"hotspot = 'X' )
          ( fieldname = 'DOCTYPE'   ref_table = 'DFKKINVBILL_H'  ) "hotspot = 'X' )
          ( fieldname = 'GPART'     ref_table = 'DFKKINVBILL_H' hotspot = 'X' )
          ( fieldname = 'VKONT'     ref_table = 'DFKKINVBILL_H' hotspot = 'X' )
          ( fieldname = 'GPART_INV ' ref_table = 'DFKKINVBILL_H' hotspot = 'X' )
          ( fieldname = 'VKONT_INV' ref_table = 'DFKKINVBILL_H' hotspot = 'X' )
          ( fieldname = 'DATE_FROM' ref_table = 'DFKKINVBILL_H' ) " hotspot = 'X' )
          ( fieldname = 'DATE_TO'   ref_table = 'DFKKINVBILL_H' ) " hotspot = 'X' )
          ( fieldname = 'SIMULATED' ref_table = 'DFKKINVBILL_H' )"  hotspot = 'X' )
          ( fieldname = 'CRNAME'    ref_table = 'DFKKINVBILL_H' ) " hotspot = 'X' )
          ( fieldname = 'CRDATE'    ref_table = 'DFKKINVBILL_H' ) " hotspot = 'X' )
          ( fieldname = 'CRTIME'    ref_table = 'DFKKINVBILL_H' ) " hotspot = 'X' )
          ( fieldname = 'FAEDN'     ref_table = 'DFKKINVDOC_H' ) " hotspot = 'X' )
       ).

    ELSEIF mv_invtyp EQ /adz/cl_inv_select_reklamon=>mco_msb.
      rt_fieldcat = VALUE #( BASE rt_fieldcat
          ( fieldname = 'CANCEL_STATE_AP'  icon = 'X' scrtext_s = 'St.StatAP' scrtext_m = 'St.Status AP' scrtext_l = 'Storno-Status Abr.Plan' )
          ( fieldname = 'VKONT_MSB'  key = 'X' scrtext_s = 'Vk MSB' scrtext_m = 'Vkonto MSB' scrtext_l = 'Vkonto MSB' hotspot = 'X' )
          ( fieldname = 'INVDOCNO' hotspot = 'X' scrtext_m = 'CI-Fakturabeleg' scrtext_l = 'CI-Fakturierungsbeleg' ref_table = 'DFKKINVDOC_H' )
          ( fieldname = 'PRLINV_STATUS'  ref_table = 'DFKKINVDOC_H' )
          " getrennte Hotspotbehandlung notwendig
          ( fieldname = 'CROSSREFNO_MSB' ref_table = '/IDXMM/MEMIDOC' ref_field = 'CROSSREFNO' hotspot = 'X' )
          ( fieldname = 'SPART'          ref_table = 'DFKKINVDOC_I' )
          ( fieldname = 'MOSB_MO_SP'    ref_table = 'DFKKINVDOC_H'  ref_field = '/MOSB/MO_SP'  )
          ( fieldname = 'MOSB_LEAD_SUP' ref_table = 'DFKKINVDOC_H'  ref_field = '/MOSB/LEAD_SUP' )
          ( fieldname = 'MOSB_ID'      ref_table  = 'DFKKINVDOC_H'  ref_field = '/MOSB/ID'  hotspot = 'X' )
          ( fieldname = 'GPART' ref_table = 'DFKKINVDOC_H' )
          ( fieldname = 'BUDAT' ref_table = 'DFKKINVDOC_H' )
          ( fieldname = 'BLDAT' ref_table = 'DFKKINVDOC_H' )
          ( fieldname = 'FAEDN' ref_table = 'DFKKINVDOC_H' )
          ( fieldname = 'OPBEL' ref_table = 'DFKKINVDOC_H'  scrtext_m = 'FICA-Beleg' hotspot = 'X' )
          ( fieldname = 'SRCDOCNO' hotspot = 'X'  ref_table = 'DFKKINVDOC_I'
              scrtext_s = 'CI-AbrBel' scrtext_m = 'CI-AbrBelnr.' scrtext_l = 'CI-Abrechnungsbeleg'   )
          ( fieldname = 'BILLPLANNO' scrtext_s = 'Abr.Plan'  scrtext_m = 'Abrech.Plan'  scrtext_l = 'Abrechnungsplan'  hotspot = 'X' )
          ( fieldname = 'QUANTITY'   scrtext_s = 'Abr.Menge' scrtext_m = 'Abrech.Menge' scrtext_l = 'Abrechnungsmenge' )
          ( fieldname = 'QTY_UNIT'   ref_table = 'DFKKINVBILL_I' )
         " ( fieldname = 'ERCHCOPBEL' scrtext_s = 'DruckbelNNE'     scrtext_m = 'DruckbelNNE.'   scrtext_l = 'Druckbeleg Netznutzung'   hotspot = 'X' )
          ( fieldname = 'BETRW' no_zero = 'X' do_sum = 'X' ref_table = 'DFKKINVDOC_I' )
          ( fieldname = 'DATE_FROM' ref_table = 'DFKKINVDOC_I' )  " hotspot = 'X' )
          ( fieldname = 'DATE_TO'   ref_table = 'DFKKINVDOC_I' )  " hotspot = 'X' )
          ( fieldname = 'BUKRS'     ref_table = 'DFKKINVDOC_I' )
      ).
    ENDIF.

    LOOP AT rt_fieldcat ASSIGNING FIELD-SYMBOL(<ls_fieldcat>).
      IF <ls_fieldcat>-ref_table IS INITIAL.
        <ls_fieldcat>-ref_table = '/ADZ/OUT_INVREMA'.  " F1-Wertehilfe
        <ls_fieldcat>-colddictxt = 'M'.
        <ls_fieldcat>-scrtext_m = COND #( WHEN <ls_fieldcat>-scrtext_m IS INITIAL THEN  <ls_fieldcat>-scrtext_s ELSE <ls_fieldcat>-scrtext_m ).
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD handle_toolbar.
    e_object->mt_toolbar = VALUE #(
      ( LINES OF /adz/cl_inv_gui_alv_common=>get_fc_standard( ) )
"      ( function = 'CHANGE_ANL' icon = icon_change text = 'Anlage' quickinfo = 'Anlage ändern' disabled = ' ' )
"      ( function = 'TARIF'   icon = icon_change     text = 'Tarif' quickinfo = 'Tarif ändern' disabled = ' '  )
      ( function = 'BALANCE' icon = icon_object_list text = 'KtnStand'  quickinfo = 'Kontenstand' )
      ( function = 'SWTMON' icon = icon_toggle_display text = 'WechselBel' quickinfo = 'Wechselbelege anzeigen' )
      ( function = 'PDOCMON' icon = icon_move text = '' quickinfo = 'Pdoc Monitoring' )
      ( function = 'DATEX'       icon = icon_interchange text = 'EDATEX Mon.' quickinfo = 'Datenaustauschprozesse' )
      ( function = 'PROCESS'     icon = icon_execute_object text = 'Remadv' quickinfo = 'REMADV Prozessieren' ) ).

    IF mv_invtyp EQ /adz/cl_inv_select_reklamon=>mco_nn.
      e_object->mt_toolbar = VALUE #( BASE e_object->mt_toolbar
        ( function = 'CIC'   icon = icon_customer    text = 'CIC'   quickinfo = 'CIC aufrufen' disabled = ' '  )
        ( function = 'CANCEL_NN'    icon = icon_storno        text = 'NNE Rechnung' quickinfo = 'Rechnung stornieren'  )
        ( function = 'COMDIS_PR'   icon = icon_reject        text = 'COMDIS Rekl-Abl.' quickinfo = 'Ablehnung Reklamation per COMDIS'  ) ).
    ELSEIF mv_invtyp EQ /adz/cl_inv_select_reklamon=>mco_memi.
      e_object->mt_toolbar = VALUE #( BASE e_object->mt_toolbar
        ( function = 'CANCEL_M'    icon = icon_storno        text = 'MeMi stornieren' quickinfo = 'MeMi Stornieren'  )
        ( function = 'CANCEL_NN'      icon = icon_storno      text = 'NNE Rechnung' quickinfo = 'Rechnung stornieren'  ) ).
    ELSEIF mv_invtyp EQ /adz/cl_inv_select_reklamon=>mco_mgv.
      e_object->mt_toolbar = VALUE #( BASE e_object->mt_toolbar
        ( function = 'CANCEL_MGV'  icon = icon_storno         text = 'MGV-Abrechnung stornieren' quickinfo = 'MGV-Abrechnung stornieren'  ) ).
    ELSEIF mv_invtyp EQ /adz/cl_inv_select_reklamon=>mco_msb.
      e_object->mt_toolbar = VALUE #( BASE e_object->mt_toolbar
        ( function = 'CANCEL_AP'    icon = icon_storno       text = 'Abr.Plan stornieren' quickinfo = 'Abrechnungsplan stornieren'  )
        ( function = 'CANCEL_A'     icon = icon_storno       text = 'AbrBel Storno'   quickinfo = 'AbrBel Storno'  ) ).
    ENDIF.

    e_object->mt_toolbar = VALUE #( BASE e_object->mt_toolbar
        ( function = 'BEENDEN'     icon = icon_booking_stop  text = 'REMADV Beenden' quickinfo = 'REMADV Beenden'  )
        ( function = 'SM_SEL_DAT'  icon = icon_mail          text = '' quickinfo = 'E-Mail versenden'  )
        ( function = 'BEMERKUNG'   icon = icon_intensify     text = 'Bem. erf.' quickinfo = 'Bemerkung erfassen'  )
        ( butn_type = 3 ) " append a separator to normal toolbar
        ( function = 'LOCK'      icon = icon_locked   text = '' quickinfo = 'Mahnsperre setzen' )
        ( function = 'UNLOCK'    icon = icon_unlocked text = '' quickinfo = 'Mahnsperre entfernen'   )
        ( function = 'ERLEDIGEN' icon = icon_okay     text = '' quickinfo = 'ERLEDIGT'  )
    ).

    " excludierte functions wieder rausfischen
    LOOP AT mt_excl_functions ASSIGNING FIELD-SYMBOL(<ls_excl_func>).
      DELETE e_object->mt_toolbar WHERE function = <ls_excl_func>-fcode.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
