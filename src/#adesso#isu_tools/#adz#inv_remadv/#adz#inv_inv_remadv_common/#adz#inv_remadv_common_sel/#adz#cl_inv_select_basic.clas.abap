CLASS /adz/cl_inv_select_basic DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS :
      read_basic_data
        IMPORTING is_sel_screen TYPE /adz/inv_s_sel_screen,
      get_errormessage
        IMPORTING iv_inv_no TYPE inv_int_inv_doc_no
        CHANGING  ct_fehler TYPE /adz/inv_t_fehler,

      get_lieferschein_info
        IMPORTING crs_wa_out TYPE REF TO /adz/inv_s_out_reklamon.


    CLASS-METHODS :

      get_domain_text
        IMPORTING iv_domtabname  TYPE ddobjname
                  iv_value       TYPE string
        RETURNING VALUE(rv_text) TYPE val_text,
      get_range_of_vktyp_kk
        RETURNING VALUE(rt_rng_vktyp) TYPE /adz/inv_rt_vktyp_kk,

      get_range_of_sender
        IMPORTING it_r_vkont           TYPE /adz/inv_rt_vkont_kk
        RETURNING VALUE(rt_rng_sender) TYPE /adz/inv_rt_int_sender,

      get_serviceid_sender_receiver
        IMPORTING iv_external_id      TYPE dunsnr
        RETURNING VALUE(rv_serviceid) TYPE service_prov,

      f4_for_variant
        IMPORTING iv_repid TYPE syrepid
        CHANGING  cv_vari  TYPE slis_vari,

      get_default_variant
        IMPORTING iv_repid       TYPE syrepid
        RETURNING VALUE(rv_vari) TYPE slis_vari,

      read_extract
        IMPORTING iv_repid TYPE syrepid
        CHANGING  crt_data TYPE REF TO data,

      get_docstatus
        RETURNING VALUE(rrt_docstatus) TYPE REF TO /idxmm/t_docstatus,

      save_extract
        IMPORTING
          iv_repid        TYPE syrepid
          iv_extract_text TYPE string
          iv_uzeit_text   TYPE string
          iv_uzeit        TYPE syst_uzeit
        CHANGING
          crt_data        TYPE REF TO data,

      get_reklamations_info
        IMPORTING iv_remadv  TYPE inv_int_inv_no
        EXPORTING ev_remdate TYPE inv_date_of_receipt
                  ev_rstgr   TYPE rstgr,

      get_divcat_for_doc
        IMPORTING iv_receiver      TYPE inv_int_receiver
        RETURNING VALUE(rv_divcat) TYPE spartyp.          .

  PROTECTED SECTION.
    DATA mt_tinv_db_data_mon TYPE tinv_db_data_mon.

    METHODS create_isu_range IMPORTING it_rng            TYPE ANY TABLE
                             RETURNING VALUE(rt_isu_tab) TYPE isu00_range_tab.
  PRIVATE SECTION.
ENDCLASS.



CLASS /adz/cl_inv_select_basic IMPLEMENTATION.
  METHOD create_isu_range.
    DATA ls_isu_range           TYPE  isu_ranges.
    FIELD-SYMBOLS  <ls_rng>     TYPE any.

    LOOP AT it_rng ASSIGNING <ls_rng>.
      MOVE-CORRESPONDING <ls_rng> TO ls_isu_range.
      INSERT ls_isu_range INTO TABLE rt_isu_tab.
    ENDLOOP.
  ENDMETHOD.

  METHOD read_basic_data.
    "----------------------------------------------------------------------------
    DATA ls_sel_screen TYPE /adz/inv_s_sel_screen.
    DATA lv_exit    TYPE c.
    DATA lse_dcdat  LIKE  ls_sel_screen-s_dtrec.
    DATA ls_dtrec   LIKE  LINE OF ls_sel_screen-s_dtrec.
    DATA ls_idosta  LIKE  LINE OF ls_sel_screen-s_idosta.
    DATA ls_insta   LIKE  LINE OF ls_sel_screen-s_insta.
    DATA ls_intido  LIKE  LINE OF ls_sel_screen-s_intido.

    ls_sel_screen = is_sel_screen.
    SET PARAMETER ID 'INV_MON_ALLALV' FIELD 'X'.
    IF ls_sel_screen-s_dtrec IS INITIAL.
      ls_dtrec-sign    = 'I'.  " include
      ls_dtrec-option  = 'BT'.  " between
      ls_dtrec-low     = '20000101'.
      ls_dtrec-high    = '99991231'.
      INSERT ls_dtrec INTO TABLE ls_sel_screen-s_dtrec.
    ENDIF.
    IF lse_dcdat IS INITIAL.
      ls_dtrec-sign    = 'I'.  " include
      ls_dtrec-option  = 'BT'.  " between
      ls_dtrec-low     = '20000101'.
      ls_dtrec-high    = '99991231'.
      INSERT ls_dtrec INTO TABLE lse_dcdat.
    ENDIF.
    IF ls_sel_screen-s_idosta IS INITIAL.
      ls_idosta-sign    = 'I'.  " include
      ls_idosta-option  = 'NE'.  " between
      INSERT ls_idosta INTO TABLE ls_sel_screen-s_idosta.
    ENDIF.
    IF ls_sel_screen-s_insta IS INITIAL.
      ls_insta-sign    = 'I'.  " include
      ls_insta-option  = 'NE'.  " between
      INSERT ls_insta INTO TABLE ls_sel_screen-s_insta.
    ENDIF.

    DATA lt_int_inv_no_case TYPE TABLE OF inv_int_inv_no.
    IF ls_sel_screen-p_klaer IS NOT INITIAL.
      CLEAR ls_sel_screen-s_intido.
      SELECT DISTINCT int_inv_no FROM /adz/inv_case UP TO 400 ROWS INTO TABLE lt_int_inv_no_case WHERE finished = '' .
      IF lt_int_inv_no_case IS NOT INITIAL.
        ls_sel_screen-s_intido = value #( for ls in lt_int_inv_no_case ( sign = 'I'  option = 'EQ'  low = ls ) ).
      ENDIF.
    ENDIF.
    IF ls_sel_screen-p_wait IS NOT INITIAL.
      CLEAR ls_sel_screen-s_intido.
      SELECT DISTINCT int_inv_no FROM /adz/inv_wait UP TO 400 ROWS INTO TABLE lt_int_inv_no_case
        WHERE from_date <= sy-datum AND to_date >= sy-datum  AND to_date >= sy-datum.
      IF lt_int_inv_no_case IS NOT INITIAL.
        ls_sel_screen-s_intido = value #( for ls in lt_int_inv_no_case ( sign = 'I'  option = 'EQ'  low = ls ) ).
      ENDIF.
    ENDIF.
    IF ls_sel_screen-p_waitx IS NOT INITIAL.
      CLEAR ls_sel_screen-s_intido.
      SELECT DISTINCT int_inv_no FROM /adz/inv_wait UP TO 400 ROWS INTO TABLE lt_int_inv_no_case
        WHERE overdue = 'X' AND  EXISTS ( SELECT * FROM tinv_inv_doc WHERE int_inv_no = /adz/inv_wait~int_inv_no AND inv_doc_status = 09 ).
      IF lt_int_inv_no_case IS NOT INITIAL.
        ls_sel_screen-s_intido = value #( for ls in lt_int_inv_no_case ( sign = 'I'  option = 'EQ'  low = ls ) ).
      ENDIF.
    ENDIF.
    IF ls_sel_screen-p_wait IS NOT INITIAL OR ls_sel_screen-p_waitx IS NOT INITIAL..
      SELECT DISTINCT int_inv_no FROM /adz/inv_wait UP TO 400 ROWS INTO TABLE lt_int_inv_no_case
        WHERE overdue = 'X'.
      IF lt_int_inv_no_case IS NOT INITIAL.
        ls_sel_screen-s_intido = value #( for ls in lt_int_inv_no_case ( sign = 'I'  option = 'EQ'  low = ls ) ).
        ls_insta = value #( sign = 'I' option = 'NE'  low = '03' ).
        INSERT ls_insta INTO TABLE ls_sel_screen-s_insta.
      ENDIF.
    ENDIF.


    DATA(it_sel_extid) = ls_sel_screen-s_zpkt.
    DATA(it_sel_doc_no) = ls_sel_screen-s_intido.

    DATA(lt_r_sel_invoice_date)    = create_isu_range( it_rng = lse_dcdat ).

    DATA lt_extui TYPE TABLE OF  ext_ui.
    DATA ls_extui TYPE   ext_ui.
    IF ls_sel_screen-s_abrkl IS NOT INITIAL OR ls_sel_screen-s_tatyp IS NOT INITIAL OR ls_sel_screen-s_ablei IS NOT INITIAL.
      SELECT ext_ui FROM eanlh
        INNER JOIN euiinstln ON euiinstln~anlage = eanlh~anlage
        INNER JOIN euitrans ON  euitrans~int_ui  = euiinstln~int_ui UP TO 1500 ROWS
        INTO TABLE lt_extui
        WHERE aklasse IN ls_sel_screen-s_abrkl AND tariftyp IN ls_sel_screen-s_tatyp AND ableinh IN ls_sel_screen-s_ablei AND ext_ui IN ls_sel_screen-s_zpkt.
      .
      IF sy-subrc = 0.
        CLEAR it_sel_extid.
        DATA ls_sel_extid LIKE LINE OF it_sel_extid.
        LOOP AT lt_extui INTO ls_extui.
          ls_sel_extid-sign = 'I'.
          ls_sel_extid-option = 'EQ'.
          ls_sel_extid-low = ls_extui.
          INSERT ls_sel_extid INTO TABLE it_sel_extid.
        ENDLOOP.
      ENDIF.

    ENDIF.

    IF ls_sel_screen-s_imdoct IS NOT INITIAL.
      SELECT int_inv_doc_no FROM tinv_inv_doc
        WHERE /idexge/imd_doc_type IN @ls_sel_screen-s_imdoct
              AND invoice_date IN @lt_r_sel_invoice_date
          INTO TABLE @DATA(lt_imd_int) UP TO 1600 ROWS.
      DATA ls_sel_doc_no  LIKE LINE OF it_sel_doc_no.
      LOOP AT lt_imd_int INTO DATA(lv_int).
        ls_sel_doc_no-sign = 'I'.
        ls_sel_doc_no-option = 'EQ'.
        ls_sel_doc_no-low = lv_int.
        INSERT ls_sel_doc_no INTO TABLE it_sel_doc_no.
      ENDLOOP.
      IF lines( lt_imd_int ) = 1600.
        MESSAGE 'Es konnten nicht alle Einträge selektiert werden, bitte selektion eingrenzen.' TYPE 'I'.
      ELSEIF lines( lt_imd_int ) = 0 .
        ls_sel_screen-p_max = 0.  " !!! hier wird eigentlich Parameter auf der Eingabemaske angepasst !!! BOESE
      ENDIF.
    ENDIF.

    DATA(lt_r_sel_int_sender)      = create_isu_range( it_rng = ls_sel_screen-s_send ).
    DATA(lt_r_sel_int_receiver)    = create_isu_range( it_rng = ls_sel_screen-s_rece ).
    DATA(lt_r_sel_int_partner)     = create_isu_range( it_rng = ls_sel_screen-s_insta ).
    DATA(lt_r_sel_invoice_status)  = create_isu_range( it_rng = ls_sel_screen-s_insta ).
    DATA(lt_r_sel_date_receipt)    = create_isu_range( it_rng = ls_sel_screen-s_dtrec ).
    DATA(lt_r_sel_doc_type)        = create_isu_range( it_rng = ls_sel_screen-s_doctyp ).
    DATA(lt_r_sel_date_of_payment) = create_isu_range( it_rng = ls_sel_screen-s_dtpaym ).
    DATA(lt_r_sel_doc_status)      = create_isu_range( it_rng = ls_sel_screen-s_idosta ).
    DATA(lt_r_sel_ext_invoice_no)  = create_isu_range( it_rng = ls_sel_screen-s_extido ).
    DATA(lt_r_sel_inv_bulk_ref)    = create_isu_range( it_rng = ls_sel_screen-s_bulkrf ).
    "DATA(lt_r_sel_)   = create_isu_range( it_rng = ls_sel_screen-s_ ).

    "  ir_sel_extid        =  it_sel_extid[].
    DATA(lt_r_sel_extid)  = create_isu_range( it_rng = it_sel_extid ).
    DATA(lt_r_sel_doc_no) = create_isu_range( it_rng = it_sel_doc_no  ).
    " ir_sel_doc_no       =  it_sel_doc_no[].

    CLEAR mt_tinv_db_data_mon.

    CALL METHOD cl_inv_inv_remadv_doc=>select_documents
      EXPORTING
        im_invoice_type         = CONV #( ls_sel_screen-p_invtp )
        im_ext_ident_type       = '01'
        im_max_head             = ls_sel_screen-p_max
        im_max_doc              = ls_sel_screen-p_max
        im_sel_tinv_inv_docproc = 'X'
        im_sel_tinv_inv_docref  = 'X'
        im_sel_tinv_inv_bank    = 'X'
        im_sel_tinv_inv_log     = 'X'
*       imt_int_inv_no          =
        im_sel_tinv_inv_logline = 'X'
        imt_sel_int_sender      = lt_r_sel_int_sender
        imt_sel_int_receiver    = lt_r_sel_int_receiver
        imt_sel_date_receipt    = lt_r_sel_date_receipt
        imt_sel_invoice_status  = lt_r_sel_invoice_status
*       imt_sel_begru           =
*       imt_sel_int_partner     =
        imt_sel_doc_type        = lt_r_sel_doc_type
        imt_sel_invoice_date    = lt_r_sel_invoice_date
        imt_sel_date_of_payment = lt_r_sel_date_of_payment
        imt_sel_doc_status      = lt_r_sel_doc_status
        imt_sel_ext_invoice_no  = lt_r_sel_ext_invoice_no
        imt_sel_inv_bulk_ref    = lt_r_sel_inv_bulk_ref
        imt_sel_doc_no          = lt_r_sel_doc_no
        imt_sel_ext_id          = lt_r_sel_extid
*       im_inv_flag             =
      IMPORTING
*       ex_num_head             =
*       ex_num_doc              =
        ext_invoice_data        = mt_tinv_db_data_mon
      EXCEPTIONS
        not_found               = 1
        system_error            = 2
        OTHERS                  = 3.
    IF sy-subrc <> 0.
      " Kein Selektionsergebnis
      "MESSAGE 'cl_inv_inv_remadv_doc=>select_documents returns with errors' TYPE 'E'.
    ENDIF.

  ENDMETHOD.


  METHOD get_errormessage.
    DATA: lt_inv_loghd   TYPE STANDARD TABLE OF tinv_inv_loghd,
          ls_inv_loghd   TYPE tinv_inv_loghd,
          ls_inv_docproc TYPE tinv_inv_docproc,
          ls_inv_logline TYPE tinv_inv_logline,
          lt_inv_docproc TYPE STANDARD TABLE OF tinv_inv_docproc,
          ls_fehler      TYPE /adz/inv_s_fehler.

    DATA: h_datefrom TYPE sy-datum.

    CLEAR lt_inv_docproc.
    SELECT * FROM tinv_inv_docproc INTO TABLE lt_inv_docproc
      WHERE int_inv_doc_no = iv_inv_no
       AND status = '04'.

    IF lt_inv_docproc IS NOT INITIAL.

      SELECT * FROM tinv_inv_loghd INTO TABLE lt_inv_loghd
        FOR ALL ENTRIES IN lt_inv_docproc
        WHERE int_inv_doc_no = iv_inv_no
        AND status = '03'
        AND process = lt_inv_docproc-process.

      SORT lt_inv_loghd BY datefrom DESCENDING.

      LOOP AT lt_inv_loghd INTO ls_inv_loghd.

        IF h_datefrom IS INITIAL.
          h_datefrom = ls_inv_loghd-datefrom.
        ENDIF.

        IF ls_inv_loghd-datefrom LT h_datefrom.
          EXIT.
        ENDIF.

        SELECT * FROM tinv_inv_logline INTO ls_inv_logline
          WHERE inv_log_no = ls_inv_loghd-inv_log_no
           AND msgty = 'E'.
          MOVE-CORRESPONDING ls_inv_logline TO ls_fehler.
          APPEND ls_fehler TO ct_fehler.
          CLEAR ls_fehler.
        ENDSELECT.

      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD get_domain_text.
    " statustext aus Domainwert lesen
    TYPES : BEGIN OF ty_domtab,
              keystr TYPE string,
              rtable TYPE REF TO data,
            END OF ty_domtab.

    STATICS st_domtab TYPE HASHED TABLE OF ty_domtab WITH UNIQUE KEY keystr.
    DATA lrt_domtexts TYPE REF TO data.
    FIELD-SYMBOLS <lt_dd07zv> TYPE dd07vtab.

    TRY.
        lrt_domtexts = st_domtab[ keystr = iv_domtabname ]-rtable.
      CATCH cx_sy_itab_line_not_found.
        DATA     lt_dd07v TYPE TABLE OF dd07v.
        IF iv_domtabname EQ 'EIDESWTSTAT'.
          SELECT * FROM eideswtstatust INTO TABLE @DATA(lt_data) WHERE spras = @sy-langu.
          lt_dd07v = VALUE #( FOR ls IN lt_data ( domvalue_l = ls-status  ddtext = ls-statustext ) ).
        ELSE.
          CALL FUNCTION 'DDUT_DOMVALUES_GET'
            EXPORTING
              name      = iv_domtabname
              langu     = sy-langu
*             TEXTS_ONLY          = ' '
            TABLES
              dd07v_tab = lt_dd07v
*       EXCEPTIONS
*             ILLEGAL_INPUT       = 1
*             OTHERS    = 2
            .
          IF sy-subrc <> 0.
            MESSAGE |no domain info for {  iv_domtabname }| TYPE 'X'.
          ENDIF.
        ENDIF.
        CREATE DATA lrt_domtexts LIKE lt_dd07v.
        ASSIGN lrt_domtexts->* TO <lt_dd07zv>.
        <lt_dd07zv> = lt_dd07v.
        st_domtab = VALUE #( BASE st_domtab ( keystr = iv_domtabname rtable = lrt_domtexts ) ).
    ENDTRY.

    IF lrt_domtexts IS NOT INITIAL.
      ASSIGN lrt_domtexts->* TO <lt_dd07zv>.
      TRY.
          rv_text = <lt_dd07zv>[ domvalue_l = CONV #( iv_value ) ]-ddtext.
        CATCH cx_sy_itab_line_not_found.
          CLEAR rv_text.
      ENDTRY.
    ENDIF.

  ENDMETHOD.

  METHOD get_range_of_vktyp_kk.
    STATICS st_r_vktyp  TYPE /adz/inv_rt_vktyp_kk.
    IF st_r_vktyp IS INITIAL.
      DATA t_te002a   TYPE TABLE OF  te002a.
      DATA ls_r_vktyp TYPE /adz/inv_rs_vktyp_kk.
      SELECT * FROM te002a
               INTO TABLE t_te002a
               WHERE fktsa = 'X'.
      ls_r_vktyp-option = 'EQ'.
      ls_r_vktyp-sign   = 'I'.
      LOOP AT t_te002a ASSIGNING FIELD-SYMBOL(<lv_line>).
        ls_r_vktyp-low    = <lv_line>-vktyp.
        INSERT ls_r_vktyp INTO TABLE st_r_vktyp.
      ENDLOOP.
    ENDIF.
    rt_rng_vktyp = st_r_vktyp.
  ENDMETHOD.

  METHOD get_range_of_sender.
    CLEAR rt_rng_sender.
    " s_aggr
    IF it_r_vkont IS NOT INITIAL.
      DATA(lt_vktyp) =  /adz/cl_inv_select_basic=>get_range_of_vktyp_kk( ).
      DATA lt_fkkvk  TYPE STANDARD TABLE OF fkkvk.
      DATA lv_service_id TYPE service_prov.
      DATA ls_r_sender  TYPE  /adz/inv_rs_int_sender.

      SELECT * FROM fkkvk INTO TABLE lt_fkkvk
        WHERE vkont IN it_r_vkont
          AND vktyp IN lt_vktyp.

      ls_r_sender-sign = 'I'.
      ls_r_sender-option = 'EQ'.

      LOOP AT lt_fkkvk INTO DATA(ls_wa_fkkvk).
        CLEAR lv_service_id.
        SELECT serviceid INTO lv_service_id
           FROM eservprovp AS a
             INNER JOIN fkkvkp AS b
              ON a~bpart = b~gpart
             WHERE b~vkont = ls_wa_fkkvk-vkont.
          ls_r_sender-low = lv_service_id.
          INSERT ls_r_sender INTO TABLE rt_rng_sender.
        ENDSELECT.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD get_lieferschein_info.
    "get steps with document identifier
    IF crs_wa_out->ls_nummer IS NOT INITIAL.
      DATA  ls_hdr_data      TYPE /idxgc/prst_hdr.
      DATA  lt_hdr_data      TYPE TABLE OF /idxgc/prst_hdr.

      SELECT * FROM /idxgc/prst_hdr
        INTO TABLE lt_hdr_data
        WHERE document_ident = crs_wa_out->ls_nummer
          AND mestyp = /idxgc/if_constants_ide=>gc_msgtp_mscons
          AND docname_code = /idxgl/if_constants_ide=>gc_msg_category_270
          AND direct = /idxgc/cl_parser_idoc=>co_idoc_direction_inbound.
      IF lines( lt_hdr_data ) EQ 1.
        READ TABLE lt_hdr_data INTO ls_hdr_data INDEX 1.
      ELSE.
        LOOP AT lt_hdr_data INTO ls_hdr_data.
          TRY .
              DATA(ls_process_step_data) = /idxgc/cl_process_document=>/idxgc/if_process_document~get_instance(
                is_process_key = VALUE #( proc_ref = ls_hdr_data-proc_ref )
                iv_edit_mode = cl_isu_wmode=>co_display
              )->get_process_data( )->get_process_step_data(
                is_process_step_key = VALUE #( proc_step_ref = ls_hdr_data-proc_step_ref )
              ).

              IF crs_wa_out->int_sender EQ ls_process_step_data-assoc_servprov
                AND crs_wa_out->int_receiver EQ ls_process_step_data-own_servprov.
                EXIT.
              ELSE.
                CLEAR ls_hdr_data.
              ENDIF.

            CATCH /idxgc/cx_process_error.
              CLEAR ls_hdr_data.
              CONTINUE.
          ENDTRY.
        ENDLOOP.
      ENDIF.
      crs_wa_out->ls_pdoc_ref = ls_hdr_data-proc_ref.
      IF crs_wa_out->ls_pdoc_ref IS NOT INITIAL.
        DATA lv_statustime TYPE timestampl.
        SELECT SINGLE   moveindate status statustime FROM eideswtdoc
           INTO ( crs_wa_out->ls_moveindate, crs_wa_out->ls_status, lv_statustime )
        WHERE  switchnum EQ crs_wa_out->ls_pdoc_ref.
        CONVERT TIME STAMP lv_statustime TIME ZONE sy-zonlo INTO DATE crs_wa_out->ls_status_date  TIME crs_wa_out->ls_status_time.
      ENDIF.
      IF crs_wa_out->ls_status  IS NOT INITIAL.
        crs_wa_out->ls_status_text = CONV #( get_domain_text( iv_domtabname = 'EIDESWTSTAT'  iv_value = CONV #( crs_wa_out->ls_status ) ) ).
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD get_reklamations_info.
    " remdate
    SELECT SINGLE date_of_receipt FROM tinv_inv_head INTO  ev_remdate
        WHERE int_inv_no = iv_remadv.
    " rstrgr  : Differenzengrund
    SELECT SINGLE  rstgr FROM tinv_inv_line_a   INTO  ev_rstgr
        WHERE int_inv_doc_no = iv_remadv
        AND  rstgr NE space.

  ENDMETHOD.

  METHOD get_serviceid_sender_receiver.
    STATICS st_service_id TYPE HASHED TABLE OF eservprov WITH UNIQUE KEY externalid.
    TRY.
        rv_serviceid = st_service_id[ externalid = iv_external_id ]-serviceid.
      CATCH cx_sy_itab_line_not_found.
        SELECT SINGLE *  FROM eservprov INTO  @DATA(ls_data) WHERE externalid = @iv_external_id.
        IF sy-subrc EQ 0.
          INSERT ls_data INTO TABLE st_service_id.
          rv_serviceid = ls_data-serviceid.
        ENDIF.
    ENDTRY.
  ENDMETHOD.

  METHOD f4_for_variant.
    DATA lv_exit TYPE char1.
    DATA ls_vari TYPE disvariant.
    DATA(ls_disvariant) = VALUE disvariant(  report = iv_repid  variant = cv_vari ).
    DATA lv_save_vari TYPE char1 VALUE 'A'.
    CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
      EXPORTING
        is_variant = ls_disvariant
        i_save     = lv_save_vari
*       it_default_fieldcat =
      IMPORTING
        e_exit     = lv_exit
        es_variant = ls_vari
      EXCEPTIONS
        not_found  = 2.
    IF sy-subrc = 2.
      MESSAGE ID sy-msgid TYPE 'S'      NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.
      IF lv_exit = space.
        cv_vari = ls_vari-variant.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD get_default_variant.
    DATA lv_save_vari  TYPE char1 VALUE 'A'.
    DATA(ls_vari) = VALUE disvariant( report = iv_repid ).

    CLEAR rv_vari.
    CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
      EXPORTING
        i_save     = lv_save_vari
      CHANGING
        cs_variant = ls_vari
      EXCEPTIONS
        not_found  = 2.
    IF sy-subrc = 0.
      rv_vari = ls_vari-variant.
    ENDIF.

  ENDMETHOD.

  METHOD read_extract.
    DATA h_extract  TYPE disextract.
    DATA h_ex       TYPE slis_extr.
    DATA h_extadmin TYPE ltexadmin.
    FIELD-SYMBOLS  <lt_extract> TYPE STANDARD TABLE.

* Extraktname bilden ----------------------------------------
* Schlüssel zum Extract bilden
    h_extract-report = iv_repid.

* F4 Hilfe für Extraktselektion
    CALL FUNCTION 'REUSE_ALV_EXTRACT_AT_F4_P_EX2'
      CHANGING
        c_p_ex2     = h_ex
        c_p_ext2    = h_ex
        cs_extract2 = h_extract.

* Extract Laden
    ASSIGN crt_data->* TO <lt_extract>.
    CALL FUNCTION 'REUSE_ALV_EXTRACT_LOAD'
      EXPORTING
        is_extract         = h_extract
*>>> UH 11102012
      IMPORTING
        es_admin           = h_extadmin
*<<< UH 11102012
      TABLES
        et_exp01           = <lt_extract>
      EXCEPTIONS
        not_found          = 1
        wrong_relid        = 2
        no_report          = 3
        no_exname          = 4
        no_import_possible = 5
        OTHERS             = 6.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE sy-msgty.
    ENDIF.
  ENDMETHOD..                    " SHOW_HISTORY

  METHOD save_extract.
    DATA: h_extract TYPE disextract.
    FIELD-SYMBOLS <ct_data> TYPE STANDARD TABLE.
    "lr_columns    TYPE REF TO cl_salv_columns.

    ASSIGN crt_data->* TO <ct_data>.
* Extraktname bilden ----------------------------------------
* Schlüssel zum Extract bilden
    CLEAR: h_extract.
* Programmname
    h_extract-report = iv_repid.
* Extrakt Text
    WRITE iv_uzeit TO h_extract-text USING EDIT MASK '__:__:__'.
    h_extract-text = |{ iv_extract_text }: { lines( <ct_data> ) }|. " { iv_uzeit_text } { h_extract-text }|.


* Extrakt Name
    h_extract-exname   = sy-datum.
    h_extract-exname+8 = sy-uzeit.

    CALL FUNCTION 'REUSE_ALV_EXTRACT_SAVE'
      EXPORTING
        is_extract         = h_extract
        i_get_selinfos     = 'X'
      TABLES
        it_exp01           = <ct_data>
      EXCEPTIONS
        wrong_relid        = 1
        no_report          = 2
        no_exname          = 3
        no_extract_created = 4
        OTHERS             = 5.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4  DISPLAY LIKE sy-msgty.
    ENDIF.
  ENDMETHOD.

  METHOD get_docstatus.
    STATICS srt_docstatus TYPE REF TO /idxmm/t_docstatus.
    IF srt_docstatus IS INITIAL.
      CREATE DATA srt_docstatus.
      ASSIGN srt_docstatus->* TO FIELD-SYMBOL(<lt_docstatus>).
      SELECT *  FROM /idxmm/docstatus INTO TABLE <lt_docstatus>.
    ENDIF.
    rrt_docstatus = srt_docstatus.
  ENDMETHOD.

  METHOD get_divcat_for_doc.
    TYPES : BEGIN OF ty_receiverdivcat,
              receiver TYPE inv_int_receiver,
              divcat   TYPE spartyp,
            END OF ty_receiverdivcat.
    STATICS st_rec_divcat TYPE HASHED TABLE OF ty_receiverdivcat WITH UNIQUE KEY receiver.
    DATA:
      ls_eservprov TYPE eservprov,
      ls_service   TYPE tecde,
      lv_serviceid TYPE service_prov,
      lv_divcat    TYPE spartyp.

    TRY.
        rv_divcat = st_rec_divcat[ receiver = iv_receiver ]-divcat.
        RETURN.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.
    lv_serviceid = iv_receiver.
    CALL FUNCTION 'ISU_DB_ESERVPROV_SINGLE'
      EXPORTING
        x_serviceid = lv_serviceid
      IMPORTING
        y_eservprov = ls_eservprov
      EXCEPTIONS
        not_found   = 1
        OTHERS      = 2.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    CALL FUNCTION 'ISU_DB_TECDE_SINGLE'
      EXPORTING
        x_service    = ls_eservprov-service
      IMPORTING
        y_service    = ls_service
      EXCEPTIONS
        not_found    = 1
        system_error = 2
        OTHERS       = 3.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    CALL FUNCTION 'ISU_DB_TESPT_SINGLE'
      EXPORTING
        x_sparte      = ls_service-division
      IMPORTING
        y_spartyp     = rv_divcat
      EXCEPTIONS
        not_found     = 1
        system_error  = 2
        not_qualified = 3
        OTHERS        = 4.
    IF sy-subrc <> 0.
      CLEAR rv_divcat.
    ENDIF.
    " hash-tabelle fuellen
    DATA(ls_rec_divcat) = VALUE ty_receiverdivcat( receiver = iv_receiver  divcat = rv_divcat ).
    INSERT ls_rec_divcat  INTO TABLE st_rec_divcat.

  ENDMETHOD.

ENDCLASS.
