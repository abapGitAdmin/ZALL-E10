CLASS /adz/cl_hmv_select_idocst_task DEFINITION  PUBLIC  FINAL.

  PUBLIC SECTION.

    TYPES:
      tt_datum_type TYPE /adz/hmv_t_sel_tab_datum,
      tt_intui_type TYPE /adz/hmv_t_sel_tab_intui,
      tt_serve_type TYPE /adz/hmv_t_sel_tab_serve.

    TYPES:  tt_taski_type TYPE RANGE OF edextaskidoc-dextaskid.

    METHODS:
      constructor IMPORTING
                    VALUE(is_const)     TYPE /adz/hmv_s_constants
                    VALUE(is_selparams) TYPE /adz/hmv_s_idoc_sel_params,

      main EXPORTING et_alv_grid_data TYPE /adz/hmv_t_memi_out
                     es_stats         TYPE /adz/hmv_idoc,

      add_statistics
        IMPORTING is_sta1 TYPE /adz/hmv_idoc
        CHANGING  cs_sta2 TYPE /adz/hmv_idoc,

      write_stats
        CHANGING cs_stats TYPE /adz/hmv_idoc.

  PRIVATE SECTION.
    DATA  ms_const        TYPE /adz/hmv_s_constants.
    DATA  ms_sel_params   TYPE /adz/hmv_s_idoc_sel_params.
    DATA  mt_output       TYPE /adz/hmv_t_memi_out.

*  DFKKTHI-Type
    TYPES: BEGIN OF type_dfkkthi,
             opbel           TYPE opbel_kk,
             opupw           TYPE opupw_kk,
             opupk           TYPE opupk_kk,
             opupz           TYPE opupz_kk,
             thinr           TYPE thinr_kk,
             bukrs           TYPE bukrs,
             thist           TYPE thist_kk,
             storn           TYPE storn_kk,
             stidc           TYPE stidc_kk,
             thidt           TYPE thidt_kk,
             thprd           TYPE thprd_kk,
             bcbln           TYPE bcbln_kk,
             senid           TYPE e_dexservprovself,
             recid           TYPE e_dexservprov,
             waers           TYPE blwae_kk,
             betrw           TYPE betrw_kk,
             crsrf           TYPE int_crossrefno,
             intui           TYPE int_ui,
             idocin          TYPE /adz/hmv_idocin,
             statin          TYPE /adz/hmv_statin,
             idocct          TYPE /adz/hmv_idocct,
             statct          TYPE /adz/hmv_statct,
             dexproc         TYPE e_dexproc,
             dexidocsent     TYPE e_dexidocsent,
             dexidocsend     TYPE e_dexidocsend,
             dexservprovself TYPE e_dexservprovself,
             dexidocsendcat  TYPE e_dexidocsendcat,
           END OF type_dfkkthi.
    TYPES tty_dfkkthi TYPE STANDARD TABLE OF type_dfkkthi  WITH KEY opbel opupw  opupk  opupz thinr.


*MEMIDOC-Type (/IDXMM/S_MEMI_DATA)
    TYPES: BEGIN OF type_memidoc,
             doc_id              TYPE /idxmm/de_doc_id,
             doc_status          TYPE /idxmm/de_doc_status,
             creation_process    TYPE /idxmm/de_creation_process,   "Erstellungsprozess
             int_pod             TYPE int_ui,                       "Interner Zählpunkt
             dist_sp             TYPE eideserprov_dist,             "SP VNB
             suppl_sp            TYPE service_prov,                 "SP
             company_code        TYPE bukrs,
             reversal            TYPE /idxmm/de_reversal,            "Stornierung('X') oder nicht('')?
             reverse_charge_type TYPE /idxmm/de_reverse_charge_type, "Art des Reverse-Charge-Verfahrens (01 - 03)
             reversal_doc_id     TYPE /idxmm/de_reversal_doc_id,     "Stornobeleg-ID
             reversal_status     TYPE /idxmm/de_reversal_status,     "Stornostatus
             due_date            TYPE /idxmm/de_due_date,            "Fälligkeitsdatum
             aedat               TYPE aedat,                         "Datum der letzten Änderung
             inv_send_date       TYPE /idxmm/de_inv_send_date,
             gross_amount        TYPE /idxmm/de_gross_amount,
             currency            TYPE /idxmm/de_currency,
             crossrefno          TYPE crossrefno,                   "IDE: Crossreferenznummer
             invoic_idoc         TYPE /idxmm/de_invoic_idoc,         "IDoc-Nummer für INVOIC-Nachricht
             ci_invoic_doc_no    TYPE invdocno_kk,                  "Nummer des Fakturierungsbelegs (Faktur.beleg)
             ci_fica_doc_no      TYPE opbel_kk,                     "Nummer eines Belegs des Vertragskontokorrents (Belegnr)
             remadv_idoc         TYPE /idxmm/de_remadv_idoc,         "IDoc-Nummer für REMADV-Nachricht
             settle_measure_unit TYPE /idxmm/de_settle_measure_unit,
             inv_doc_no          TYPE inv_int_inv_doc_no,           "Interne Nummer des Rechnungsbelegs/Avisbelegs
             pdoc_ref            TYPE /idxgc/de_proc_ref,            "Dynamische Prozessreferenz
             pdoc_ref_mass       TYPE /idxgc/de_proc_ref,
             suppl_bupa          TYPE bu_partner,
             suppl_contr_acct    TYPE vkont_kk,
             stidc               TYPE stidc_kk,                     "XFELD Storno
             idocin              TYPE /adz/hmv_idocin,
             statin              TYPE /adz/hmv_statin,
             idocct              TYPE /adz/hmv_idocct,
             statct              TYPE /adz/hmv_statct,
             dexproc             TYPE e_dexproc,
             dexidocsent         TYPE e_dexidocsent,
             dexidocsend         TYPE e_dexidocsend,
             dexservprovself     TYPE e_dexservprovself,
             dexidocsendcat      TYPE e_dexidocsendcat,
           END OF type_memidoc.
    TYPES tty_memidoc TYPE STANDARD TABLE OF type_memidoc  WITH KEY doc_id.

    TYPES: BEGIN OF type_msbdoc,
             invdocno            TYPE invdocno_kk,
             /mosb/ld_malo_i     TYPE /mosb/de_int_ui_malo,
             /mosb/ld_malo_e     TYPE /mosb/de_ext_ui_malo,
             /mosb/mo_sp         TYPE /mosb/de_mo_sp,
             /mosb/lead_sup      TYPE /mosb/de_leading_sup,
             bukrs               TYPE bukrs,
             faedn               TYPE faedn_kk,
             crdate              TYPE invdoc_crdat_kk,
             total_curr          TYPE blwae_kk,
             total_amt           TYPE betrw_kk,
             /mosb/inv_doc_ident TYPE /idxgc/de_document_ident,
             opbel               TYPE opbel_kk,
             idocin              TYPE /adz/hmv_idocin,
             statin              TYPE /adz/hmv_statin,
             idocct              TYPE /adz/hmv_idocct,
             statct              TYPE /adz/hmv_statct,
             dexproc             TYPE e_dexproc,
             dexidocsent         TYPE e_dexidocsent,
             dexidocsend         TYPE e_dexidocsend,
             dexservprovself     TYPE e_dexservprovself,
             dexidocsendcat      TYPE e_dexidocsendcat,
           END OF type_msbdoc.
    TYPES tty_msbdoc TYPE STANDARD TABLE OF type_msbdoc WITH KEY invdocno opbel. " zwei opbel möglich


    " Struktur IDoc-Versandstatus-Ermittlung
    TYPES: BEGIN OF ty_edexdefserprov,
             dexservprov     TYPE e_dexservprov,
             dexproc         TYPE e_dexproc,
             dexservprovself TYPE e_dexservprovself,
             dexidocsent     TYPE e_dexidocsent,
             dexidocsend     TYPE e_dexidocsend,
             dexidocsendcat  TYPE e_dexidocsendcat,
           END OF ty_edexdefserprov.

    " Ecrossrefno
    TYPES:
      BEGIN OF type_ecrossrefno,
        int_crossrefno TYPE int_crossrefno,
        stidc          TYPE stidc_kk,
        docnum         TYPE edi_docnum,
        int_ui         TYPE int_ui,
        keydate        TYPE endabrpe,
        crossrefno     TYPE char35, "har35, e1vdewbgm_1-documentnumber,
        abrdats        TYPE abrdats,
        cancel         TYPE kennzx,
        created_from   TYPE created_from,
        vertrag        TYPE vertrag,
        erdat          TYPE erdat,
        ernam          TYPE ernam,
        aedat          TYPE aedat,
        aenam          TYPE aenam,
        belnr          TYPE e_belnr,
        crn_rev        TYPE crossrefno,
      END OF type_ecrossrefno.
    TYPES tty_ecrossrefno TYPE SORTED TABLE OF type_ecrossrefno WITH UNIQUE KEY int_crossrefno int_ui stidc docnum.

    " EUITRANS (Transformation interne/externe Zählpunktnummer)
    TYPES: BEGIN OF ty_edids_status,
             docnum TYPE edi_docnum,  "edids-docnum,
             status TYPE edi_status,  "edids-status,
           END OF ty_edids_status.
    TYPES tty_edis_status TYPE SORTED TABLE OF ty_edids_status WITH NON-UNIQUE KEY docnum status.

    TYPES: BEGIN OF type_edid4_crf,
             docnum     TYPE edi_docnum,
             crossrefno TYPE crossrefno,
             crn_rev    TYPE crossrefno,
           END OF type_edid4_crf.
    TYPES tty_edid4_crf TYPE SORTED TABLE OF type_edid4_crf WITH UNIQUE KEY docnum crossrefno.

    METHODS:
      get_dexproc
        IMPORTING is_rng_so_datum   TYPE /adz/hmv_s_sel_tab_datum
        RETURNING VALUE(rt_dexproc) TYPE /adz/hmv_rt_xpro,
*      get_edexdefservprov,

      get_idocs
        IMPORTING is_rng_so_datum TYPE /adz/hmv_s_sel_tab_datum
        EXPORTING et_idocs        TYPE /adz/hmv_t_idocs
                  et_edids_status TYPE tty_edis_status
                  et_hmv_sart     TYPE /adz/hmv_t_sart,

      get_euitrans
        IMPORTING is_rng_so_datum    TYPE /adz/hmv_s_sel_tab_datum
                  irt_idocs          TYPE REF TO /adz/hmv_t_idocs
        RETURNING VALUE(rt_euitrans) TYPE /adz/hmv_t_euitrans,

      get_edid4
        IMPORTING irt_idocs           TYPE REF TO /adz/hmv_t_idocs
        RETURNING VALUE(rt_edid4_crf) TYPE tty_edid4_crf,

      get_crsrf
        IMPORTING irt_idocs       TYPE REF TO /adz/hmv_t_idocs
                  irt_edid4_crf   TYPE REF TO tty_edid4_crf
        RETURNING VALUE(rt_crsrf) TYPE  tty_ecrossrefno,

      get_dfkkthi
        IMPORTING irt_crsrf         TYPE REF TO tty_ecrossrefno
        RETURNING VALUE(rt_dfkkthi) TYPE tty_dfkkthi,

      get_memidoc
        IMPORTING irt_crsrf         TYPE REF TO tty_ecrossrefno
        RETURNING VALUE(rt_memidoc) TYPE tty_memidoc,

      get_msbdoc
        IMPORTING irt_crsrf        TYPE REF TO tty_ecrossrefno
        RETURNING VALUE(rt_msbdoc) TYPE tty_msbdoc,

      fill_internal_table
        IMPORTING irt_dfkkthi      TYPE REF TO tty_dfkkthi
                  irt_memidoc      TYPE REF TO tty_memidoc
                  irt_msbdoc       TYPE REF TO tty_msbdoc
                  irt_crsrf        TYPE REF TO tty_ecrossrefno
                  irt_hmv_sart     TYPE REF TO /adz/hmv_t_sart
                  irt_idocs        TYPE REF TO /adz/hmv_t_idocs
                  irt_euitrans     TYPE REF TO /adz/hmv_t_euitrans
                  irt_edids_status TYPE REF TO tty_edis_status,

      fill_idoc_status
        IMPORTING
                  is_idocs          TYPE /adz/hmv_s_idocs
                  is_edexdefserprov TYPE ty_edexdefserprov
                  irt_edids_status  TYPE REF TO tty_edis_status
                  irt_hmv_sart      TYPE REF TO /adz/hmv_t_sart
        CHANGING  crs_output        TYPE REF TO /adz/hmv_s_memi_out,

      get_statistics
        IMPORTING irt_idocs TYPE REF TO /adz/hmv_t_idocs
        CHANGING  cs_stats  TYPE /adz/hmv_idoc,
      update_stats_with_selvar   CHANGING cs_sta TYPE /adz/hmv_idoc,
      update_dfkkthi CHANGING cs_stats TYPE /adz/hmv_idoc,
      update_memidoc CHANGING cs_stats TYPE /adz/hmv_idoc,
      update_msbdoc  CHANGING cs_stats TYPE /adz/hmv_idoc.
ENDCLASS.



CLASS /adz/cl_hmv_select_idocst_task IMPLEMENTATION.

  METHOD constructor.
    MOVE-CORRESPONDING is_const TO ms_const.
    ms_sel_params = is_selparams.

  ENDMETHOD.                    "constructor



  METHOD main.
    DATA lt_dfkkthi      TYPE tty_dfkkthi.
    DATA lt_memidoc      TYPE tty_memidoc.
    DATA lt_msbdoc       TYPE tty_msbdoc.
    DATA lt_idocs        TYPE /adz/hmv_t_idocs.
    DATA lt_edids_status TYPE tty_edis_status.
    DATA lt_euitrans     TYPE /adz/hmv_t_euitrans.
    DATA lt_edid4_crf    TYPE tty_edid4_crf.
    DATA lt_crsf         TYPE tty_ecrossrefno.
    DATA lt_hmv_sart     TYPE /adz/hmv_t_sart.

    GET TIME.

    LOOP AT ms_sel_params-so_datum INTO DATA(ls_rng_so_datum).
      EXIT. "take the first.
    ENDLOOP.

*    get_edexdefservprov( ).
    get_idocs(
      EXPORTING is_rng_so_datum = ls_rng_so_datum
      IMPORTING et_idocs        = lt_idocs
                et_edids_status = lt_edids_status
                et_hmv_sart     = lt_hmv_sart   ).
    CHECK lt_idocs IS NOT INITIAL.
    DATA(lrt_idocs) = REF #( lt_idocs ).

    lt_euitrans = get_euitrans(
      EXPORTING is_rng_so_datum = ls_rng_so_datum
                irt_idocs       = lrt_idocs ).

    lt_edid4_crf = get_edid4( EXPORTING irt_idocs   = lrt_idocs ).

    lt_crsf = get_crsrf(
        EXPORTING irt_idocs     = lrt_idocs
                  irt_edid4_crf = REF #( lt_edid4_crf ) ).
    DATA(lrt_crsf) = REF #( lt_crsf ).

    lt_dfkkthi = get_dfkkthi( EXPORTING irt_crsrf = lrt_crsf ).
    lt_memidoc = get_memidoc( EXPORTING irt_crsrf = lrt_crsf ).
    lt_msbdoc  = get_msbdoc(  EXPORTING irt_crsrf = lrt_crsf ).

    fill_internal_table(
       EXPORTING irt_dfkkthi      = REF #( lt_dfkkthi )
                 irt_memidoc      = REF #( lt_memidoc )
                 irt_msbdoc       = REF #( lt_msbdoc )
                 irt_crsrf        = lrt_crsf
                 irt_hmv_sart     = REF #( lt_hmv_sart )
                 irt_edids_status = REF #( lt_edids_status )
                 irt_idocs        = lrt_idocs
                 irt_euitrans     = REF #( lt_euitrans ) ).

    IF ms_sel_params-p_upd_dfk IS NOT INITIAL.
      update_dfkkthi( CHANGING cs_stats = es_stats ).
    ENDIF.

    IF ms_sel_params-p_upd_memi IS NOT INITIAL.
      update_memidoc( CHANGING cs_stats = es_stats ).
    ENDIF.

    IF ms_sel_params-p_upd_msb IS NOT INITIAL.
      update_msbdoc( CHANGING cs_stats = es_stats ).
    ENDIF.

    APPEND LINES OF mt_output TO et_alv_grid_data.

    get_statistics(
      EXPORTING  irt_idocs  = REF #( lt_idocs )
      CHANGING   cs_stats   = es_stats ).

    COMMIT WORK.
  ENDMETHOD.

  METHOD fill_internal_table.
    DATA ls_edexdefservprov TYPE ty_edexdefserprov.
    DATA ls_output          TYPE /adz/hmv_s_memi_out.
    DATA lrs_output         TYPE REF TO /adz/hmv_s_memi_out.

    lrs_output = REF #( ls_output ).
************************************************* Loop über MEMIDOC (interne Tabelle) *************************************************
    LOOP AT irt_memidoc->* ASSIGNING FIELD-SYMBOL(<s_memidoc>).

      ls_output-kennz = /idxmm/if_constants=>gc_createdfrom_m.

      MOVE <s_memidoc>-doc_id           TO ls_output-opbel.
      MOVE <s_memidoc>-company_code     TO ls_output-bukrs.
      MOVE <s_memidoc>-crossrefno       TO ls_output-ownrf.
      MOVE <s_memidoc>-int_pod          TO ls_output-intui.
      MOVE <s_memidoc>-dist_sp          TO ls_output-senid.
      MOVE <s_memidoc>-suppl_sp         TO ls_output-recid.
      MOVE <s_memidoc>-currency         TO ls_output-waers.
      MOVE <s_memidoc>-gross_amount     TO ls_output-betrw.
      MOVE <s_memidoc>-due_date         TO ls_output-thidt.
      MOVE <s_memidoc>-invoic_idoc      TO ls_output-idocin.
      MOVE <s_memidoc>-ci_fica_doc_no   TO ls_output-bcbln.
      MOVE <s_memidoc>-inv_send_date    TO ls_output-thprd.
      MOVE <s_memidoc>-doc_status       TO ls_output-doc_status.
      MOVE <s_memidoc>-aedat            TO ls_output-dexaedat.
      MOVE <s_memidoc>-suppl_bupa       TO ls_output-suppl_bupa.
      MOVE <s_memidoc>-suppl_contr_acct TO ls_output-suppl_contr_acct.

*   Zählpunktnummer
      READ TABLE irt_euitrans->* ASSIGNING FIELD-SYMBOL(<ls_euitrans>)
        WITH KEY int_ui = <s_memidoc>-int_pod
        BINARY SEARCH.
      IF sy-subrc = 0 AND <ls_euitrans> IS ASSIGNED.
        MOVE <ls_euitrans>-ext_ui TO ls_output-ext_ui.
      ENDIF.

*   Crossrefno (MMM+++)
      LOOP AT irt_crsrf->* ASSIGNING FIELD-SYMBOL(<ls_crsrf>)
        WHERE crossrefno = <s_memidoc>-crossrefno.

*   IDoc
        READ TABLE irt_idocs->* ASSIGNING FIELD-SYMBOL(<ls_idocs>)
          WITH KEY docnum = <ls_crsrf>-docnum
                   int_ui     = ls_output-intui
*                   dexduedate = s_output-thprd
                   BINARY SEARCH.


* <<< ET_20160309
* IDoc-Status fortschreiben
        IF sy-subrc = 0 AND <ls_idocs> IS ASSIGNED.
*          s_output-status_i = <f_idocs>-status.
*          s_output-status_c = <f_idocs>-status.
*        ENDIF.
* >>> ET_20160309
          CLEAR: ls_edexdefservprov.
          SELECT SINGLE a~dexproc a~dexidocsend a~dexservprovself
                 a~dexservprov b~dexidocsendcat
            FROM edexdefservprov AS a
         "Join mit Tabelle EDEXIDOCSEND
            JOIN edexidocsend AS b
              ON a~dexidocsend = b~dexidocsend
            INTO CORRESPONDING FIELDS OF ls_edexdefservprov
            WHERE a~datefrom < <ls_idocs>-dexduedate
              AND a~dateto   > <ls_idocs>-dexduedate
              AND a~dexservprovself = <ls_idocs>-dexservprovself
              AND a~dexservprov = <ls_idocs>-dexservprov
              AND a~dexproc = <ls_idocs>-dexproc.

*    Servprov
*          READ TABLE it_edexdefserprov ASSIGNING <fs_defservprov>
*            WITH KEY dexservprov     = <f_idocs>-dexservprov
*                     dexproc         = <f_idocs>-dexproc
*                     dexservprovself = <f_idocs>-dexservprovself
*                     BINARY SEARCH.

          " Status IDoc
          fill_idoc_status(
            EXPORTING
              is_idocs          = <ls_idocs>
              is_edexdefserprov = ls_edexdefservprov
              irt_edids_status  = irt_edids_status
              irt_hmv_sart      = irt_hmv_sart
            CHANGING
              crs_output        = lrs_output  ).
        ENDIF.

        IF <ls_crsrf>-created_from EQ ms_const-c_invoice_status_03 OR
           <ls_crsrf>-created_from EQ ms_const-c_invoice_status_04.
          ls_output-stidc = 'X'.
        ENDIF.
      ENDLOOP.
      APPEND ls_output TO mt_output.
    ENDLOOP.        "Loop MEMIDOC
************************************************************************** Loop über interne Tabelle DFKKTHI **************************************************************************

    LOOP AT irt_dfkkthi->* ASSIGNING FIELD-SYMBOL(<ls_dfkkthi>).
      CLEAR: ls_output.

      ls_output-kennz = ms_const-c_doc_kzd.

      MOVE-CORRESPONDING <ls_dfkkthi> TO ls_output.

*     Externe Zählpunktbezeichnung
      READ TABLE irt_euitrans->* ASSIGNING <ls_euitrans>
         WITH KEY int_ui = <ls_dfkkthi>-intui
         BINARY SEARCH.
      IF sy-subrc = 0 AND <ls_euitrans> IS ASSIGNED.
        ls_output-ext_ui = <ls_euitrans>-ext_ui.
      ENDIF.

*     Crossrefno (PRN-Nummer)
      LOOP AT irt_crsrf->* ASSIGNING <ls_crsrf>
        WHERE int_crossrefno = <ls_dfkkthi>-crsrf
          AND stidc          = <ls_dfkkthi>-stidc.
        ls_output-ownrf       = <ls_crsrf>-crossrefno.
        ls_output-ownrf_s     = <ls_crsrf>-crn_rev.

*     IDOC
        READ TABLE irt_idocs->* ASSIGNING <ls_idocs>
          WITH KEY docnum     = <ls_crsrf>-docnum
                   int_ui     = ls_output-intui
                   dexduedate = ls_output-thprd.

        IF sy-subrc = 0 AND <ls_idocs> IS ASSIGNED.
          CLEAR: ls_edexdefservprov.
          SELECT SINGLE a~dexproc a~dexidocsend a~dexservprovself
                 a~dexservprov b~dexidocsendcat
            FROM edexdefservprov AS a
         "Join mit Tabelle EDEXIDOCSEND
            JOIN edexidocsend AS b
              ON a~dexidocsend = b~dexidocsend
            INTO CORRESPONDING FIELDS OF ls_edexdefservprov
            WHERE a~datefrom < <ls_idocs>-dexduedate
              AND a~dateto   > <ls_idocs>-dexduedate
              AND a~dexservprovself = <ls_idocs>-dexservprovself
              AND a~dexservprov = <ls_idocs>-dexservprov
              AND a~dexproc = <ls_idocs>-dexproc.

*       Servprov
*          READ TABLE it_edexdefserprov ASSIGNING <fs_defservprov>
*            WITH KEY dexservprov     = <f_idocs>-dexservprov
*                     dexproc         = <f_idocs>-dexproc
*                     dexservprovself = <f_idocs>-dexservprovself
*                     BINARY SEARCH.
          " Status IDoc
          fill_idoc_status(
            EXPORTING
              is_idocs          = <ls_idocs>
              is_edexdefserprov = ls_edexdefservprov
              irt_edids_status  = irt_edids_status
              irt_hmv_sart      = irt_hmv_sart
            CHANGING
              crs_output        = lrs_output  ).
        ENDIF.
      ENDLOOP.
      APPEND ls_output TO mt_output.
    ENDLOOP.

** --> Nuss 09.2018
*******************************Loop über interne Tabelle MSBDOC**********************
    LOOP AT irt_msbdoc->* ASSIGNING FIELD-SYMBOL(<s_msbdoc>).

      CLEAR: ls_output.

      ls_output-kennz = 'I'.

      MOVE <s_msbdoc>-invdocno TO ls_output-opbel.
      MOVE <s_msbdoc>-bukrs TO ls_output-bukrs.
      MOVE <s_msbdoc>-/mosb/inv_doc_ident TO ls_output-ownrf.
      MOVE <s_msbdoc>-/mosb/ld_malo_i TO ls_output-intui.
      MOVE <s_msbdoc>-/mosb/ld_malo_e TO ls_output-ext_ui.
      MOVE <s_msbdoc>-/mosb/mo_sp TO ls_output-senid.
      MOVE <s_msbdoc>-/mosb/lead_sup  TO ls_output-recid.
      MOVE <s_msbdoc>-total_curr  TO ls_output-waers.
      MOVE <s_msbdoc>-total_amt TO ls_output-betrw.
      MOVE <s_msbdoc>-faedn TO ls_output-thidt.
      MOVE <s_msbdoc>-crdate TO ls_output-thprd.
      MOVE <s_msbdoc>-opbel TO ls_output-bcbln.

*     Crossrefno (msb)
      LOOP AT irt_crsrf->* ASSIGNING <ls_crsrf>
        WHERE crossrefno = <s_msbdoc>-/mosb/inv_doc_ident.
*     IDOC
        READ TABLE irt_idocs->* ASSIGNING <ls_idocs>
          WITH KEY docnum     = <ls_crsrf>-docnum
                   int_ui     = ls_output-intui.

        IF sy-subrc = 0 AND <ls_idocs> IS ASSIGNED.

          CLEAR: ls_edexdefservprov.
          SELECT SINGLE a~dexproc a~dexidocsend a~dexservprovself
                 a~dexservprov b~dexidocsendcat
            FROM edexdefservprov AS a
         "Join mit Tabelle EDEXIDOCSEND
            JOIN edexidocsend AS b
              ON a~dexidocsend = b~dexidocsend
            INTO CORRESPONDING FIELDS OF ls_edexdefservprov
            WHERE a~datefrom < <ls_idocs>-dexduedate
              AND a~dateto   > <ls_idocs>-dexduedate
              AND a~dexservprovself = <ls_idocs>-dexservprovself
              AND a~dexservprov = <ls_idocs>-dexservprov
              AND a~dexproc = <ls_idocs>-dexproc.

          " Status IDoc
          fill_idoc_status(
            EXPORTING
              is_idocs          = <ls_idocs>
              is_edexdefserprov = ls_edexdefservprov
              irt_edids_status  = irt_edids_status
              irt_hmv_sart      = irt_hmv_sart
            CHANGING
              crs_output        = lrs_output  ).
        ENDIF.
      ENDLOOP.
      APPEND ls_output TO mt_output.
    ENDLOOP.
** <-- Nuss 09.2018
  ENDMETHOD.                  "fill_internal_table

  METHOD fill_idoc_status.
    DATA  ls_hmv_sart        TYPE /adz/hmv_sart.
    DATA  ls_xsart           TYPE /adz/hmv_sart.

    LOOP AT irt_hmv_sart->* INTO ls_hmv_sart
      WHERE dexproc         = is_idocs-dexproc
        AND serviceanbieter = is_idocs-dexservprovself
        AND dexidocsent     = is_idocs-sent
        AND dexidocsendcat  = is_edexdefserprov-dexidocsendcat
        AND datbi GE is_idocs-credat
        AND datab LE is_idocs-credat.
      crs_output->dexproc         = ls_hmv_sart-dexproc.
*            s_output-dexidocsent     = s_hmv_sart-dexidocsent.
*            s_output-dexidocsentctrl = s_hmv_sart-dexidocsent.
      crs_output->dexidocsendcat  = ls_hmv_sart-dexidocsendcat.
      ls_xsart = ls_hmv_sart.
    ENDLOOP.

    READ TABLE irt_edids_status->* ASSIGNING FIELD-SYMBOL(<f_edids>)
        WITH KEY docnum = is_idocs-docnum
                status = ls_xsart-status
       BINARY SEARCH.

    IF sy-subrc = 0 AND <f_edids> IS ASSIGNED.
      IF ls_xsart-inv  = 'X'.
        crs_output->idocin = is_idocs-docnum.
        crs_output->dexidocsent     = ls_hmv_sart-dexidocsent.
        crs_output->statin_led    = icon_led_green.
        crs_output->status_i  = <f_edids>-status.
      ENDIF.
      IF ls_xsart-ctrl = 'X'.
        crs_output->idocct = is_idocs-docnum.
        crs_output->dexidocsentctrl = ls_hmv_sart-dexidocsent.
        crs_output->statct_led    = icon_led_green.
        crs_output->status_c  = <f_edids>-status.
      ENDIF.
    ELSE.
      IF ls_xsart-inv  = 'X'.
        crs_output->idocin = is_idocs-docnum.
        crs_output->dexidocsent     = ls_hmv_sart-dexidocsent.
        crs_output->statin_led = icon_led_red.
        crs_output->status_i   = is_idocs-status.
      ENDIF.
      IF ls_xsart-ctrl = 'X'.
        crs_output->idocct = is_idocs-docnum.
        crs_output->dexidocsentctrl = ls_hmv_sart-dexidocsent.
        crs_output->statct_led = icon_led_red.
        crs_output->status_c   = is_idocs-status.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD get_crsrf.
* Referenznummer IDoc (Crossrefno)
    DATA ls_crsrf   TYPE          type_ecrossrefno.
    FIELD-SYMBOLS: <s_edid4_s> TYPE type_edid4_crf.

*    assign irt_edid4_crf->* to FIELD-SYMBOL(<lt_edid4>).
*    DATA lt_rng_crossrefno TYPE RANGE OF crossrefno.
*    lt_rng_crossrefno = VALUE #( FOR ls IN irt_edid4_crf->* ( sign = 'I'  option = 'EQ'  low = ls-crossrefno  ) ).
*    DATA lt_rng_crnrev TYPE RANGE OF crossrefno.
*    lt_rng_crnrev = VALUE #( FOR ls IN irt_edid4_crf->* ( sign = 'I'  option = 'EQ'  low = ls-docnum  ) ).
*    DATA lt_rng_intui TYPE RANGE OF int_ui.
*    lt_rng_intui = VALUE #( FOR ls2 IN irt_idocs->* ( sign = 'I'  option = 'EQ'  low = ls2-int_ui  ) ).
*
*    assign irt_idocs->* to FIELD-SYMBOL(<lt_idocs>).
*    assign irt_edid4_crf->* to FIELD-SYMBOL(<lt_edid4_crf>).
*    DATA lt_crsf_all TYPE SORTED TABLE OF type_ecrossrefno
*        WITH NON-UNIQUE KEY  crossrefno
*        WITH NON-UNIQUE SORTED KEY secondkey COMPONENTS crn_rev.
*    SELECT * FROM ecrossrefno INTO CORRESPONDING FIELDS OF TABLE lt_crsf_all
*      for ALL ENTRIES IN  <lt_edid4_crf>
*      WHERE ( crossrefno eq <lt_edid4_crf>-crossrefno OR crn_rev eq <lt_edid4_crf>-crn_rev )
*        and int_ui in lt_rng_intui.
    CLEAR rt_crsrf.
    IF 1 < 0.
      " neu aber nicht ausgereift
      LOOP AT irt_edid4_crf->* ASSIGNING <s_edid4_s>.
        SELECT * FROM ecrossrefno INTO CORRESPONDING FIELDS OF ls_crsrf
          WHERE crossrefno = <s_edid4_s>-crossrefno OR crn_rev = <s_edid4_s>-docnum.
*      if not ( <s_edid4_s>-crossrefno co '0123456789').
*         <s_edid4_s>-crossrefno = '1'.
*      endif.
*      LOOP AT lt_crsf_all INTO ls_crsrf WHERE crossrefno = <s_edid4_s>-crossrefno OR crn_rev = <s_edid4_s>-docnum.
          IF line_exists( irt_idocs->*[ int_ui = ls_crsrf-int_ui ] ).
            CHECK ls_crsrf-crossrefno NE '1' OR ls_crsrf-crn_rev EQ <s_edid4_s>-docnum.
            ls_crsrf-docnum = <s_edid4_s>-docnum.
            INSERT ls_crsrf INTO TABLE rt_crsrf.
            " Storno
            IF ls_crsrf-crossrefno = <s_edid4_s>-crossrefno.
              ls_crsrf-stidc = 'X'.
              INSERT ls_crsrf INTO TABLE rt_crsrf.
            ENDIF.
          ENDIF.
*      ENDLOOP.
        ENDSELECT.
*      "    dann Stornos
*      SELECT * FROM ecrossrefno INTO CORRESPONDING FIELDS OF ls_crsrf
*        WHERE crn_rev = <s_edid4_s>-crossrefno.
*        IF line_exists( irt_idocs->*[ int_ui = ls_crsrf-int_ui ] ).
*          ls_crsrf-docnum = <s_edid4_s>-docnum.
*          ls_crsrf-stidc = 'X'.
*          INSERT ls_crsrf INTO TABLE rt_crsrf.
*        ENDIF.
*        CLEAR ls_crsrf.
*      ENDSELECT.
      ENDLOOP.
    ELSE.
      " alt etwas aufgehuebscht
      LOOP AT irt_edid4_crf->* ASSIGNING <s_edid4_s>.
        "   !erst Rechnungen (wg Index)
        SELECT * FROM ecrossrefno INTO CORRESPONDING FIELDS OF ls_crsrf
               WHERE crossrefno = <s_edid4_s>-crossrefno
                  OR crn_rev    = <s_edid4_s>-docnum.
          IF line_exists( irt_idocs->*[ int_ui = ls_crsrf-int_ui ] ).
            ls_crsrf-docnum = <s_edid4_s>-docnum.
            INSERT ls_crsrf INTO TABLE rt_crsrf.
          ENDIF.
          CLEAR ls_crsrf.
        ENDSELECT.
        "    dann Stornos (wg Index)
        SELECT * FROM ecrossrefno
              INTO CORRESPONDING FIELDS OF ls_crsrf
              WHERE crn_rev = <s_edid4_s>-crossrefno.
          IF line_exists( irt_idocs->*[ int_ui = ls_crsrf-int_ui ] ).
            ls_crsrf-docnum = <s_edid4_s>-docnum.
            ls_crsrf-stidc = 'X'.
            INSERT ls_crsrf INTO TABLE rt_crsrf.
          ENDIF.
          CLEAR ls_crsrf.
        ENDSELECT.
      ENDLOOP.
      DELETE ADJACENT DUPLICATES FROM rt_crsrf COMPARING ALL FIELDS.
    ENDIF.
  ENDMETHOD.


  METHOD get_dexproc.
* DA-Prozesse anhand der Basis-DA-Prozesse ermitteln

    DATA:
      rng_edexproc TYPE /adz/hmv_rt_xpro,
      wa_edexproc  TYPE edexproc.

* DA-Prozesse abhängig von Basisprozess lesen ( INV_OUT, E_INVOIC )
    rng_edexproc = /adz/cl_hmv_customizing=>get_dexproc_invout( is_so_datum = is_rng_so_datum ).
    SELECT dexproc FROM edexproc INTO  TABLE @DATA(lt_dexproc)
      WHERE dexbasicproc IN @rng_edexproc.
    rt_dexproc = VALUE #( FOR ls IN lt_dexproc ( sign = 'I'  option = 'EQ'  low = ls-dexproc ) ).
  ENDMETHOD.                    "get_dexproc


  METHOD get_dfkkthi.
    DATA lt_rng_int_crossrefno TYPE RANGE OF int_crossrefno.
    lt_rng_int_crossrefno = VALUE #( FOR ls IN irt_crsrf->*
      WHERE ( created_from NE /idxmm/if_constants=>gc_createdfrom_m  OR   created_from NE 'I' )
        ( sign = 'I'  option = 'EQ'  low = ls-int_crossrefno  ) ).
    CHECK lt_rng_int_crossrefno IS NOT INITIAL.

    " Tabelle DFKKTHI (nicht versendete buchungsrelevante Datensätze)
    CLEAR rt_dfkkthi.
    SELECT * FROM dfkkthi INTO CORRESPONDING FIELDS OF TABLE rt_dfkkthi
        WHERE crsrf IN lt_rng_int_crossrefno
          AND thist NOT IN (' ','7')      "nicht gesendet/nicht gebucht
          AND burel = 'X'.                "buchungsrelevant
  ENDMETHOD.          "get_dfkkthi


  METHOD get_edid4.
* IDoc Segment
    DATA lv_credat      TYPE edi_ccrdat.
    DATA ls_ediseg      TYPE /adz/hmv_segn.
    DATA lr_bgm_general TYPE REF TO data.
    DATA lt_edid4       TYPE TABLE OF edid4.
    DATA lt_edid4_all   TYPE SORTED TABLE OF edid4 WITH NON-UNIQUE KEY docnum.
    DATA ls_edid4_crf   TYPE LINE OF tty_edid4_crf.

    CLEAR lt_edid4.
*    DATA lt_rng_docnum TYPE RANGE OF edid4-docnum.
*    lt_rng_docnum = VALUE #( FOR ls IN irt_idocs->* ( sign = 'I'  option = 'EQ'  low = ls-docnum  ) ).
*    SELECT * FROM edid4 INTO TABLE lt_edid4_all  WHERE docnum IN lt_rng_docnum.

    LOOP AT irt_idocs->* ASSIGNING FIELD-SYMBOL(<s_idocs>).
      lv_credat = <s_idocs>-credat.
      AT END OF docnum.
        IF NOT line_exists( rt_edid4_crf[ docnum = <s_idocs>-docnum ] ).
          DATA(ls_rng_datum) = VALUE /adz/cl_hmv_customizing=>ty_ab_bis( sign = 'I'  option = 'BT'  low = lv_credat  high = lv_credat ).
          ls_ediseg = /adz/cl_hmv_customizing=>get_edi_segment( is_so_datum = ls_rng_datum ).

          REFRESH lt_edid4.
*          lt_edid4 = VALUE #( FOR ls2 IN lt_edid4_all
*            WHERE ( docnum = <s_idocs>-docnum AND segnam = ls_ediseg-segnam ) ( ls2 ) ).

          SELECT * FROM edid4 INTO TABLE lt_edid4
            WHERE docnum = <s_idocs>-docnum
            "    AND segnam IN rng_segn_tab.                 "/IDXGC/E1VDEWBGM_1, /IDXGC/E1_BGM_02
              AND segnam = ls_ediseg-segnam.

          LOOP AT lt_edid4 ASSIGNING FIELD-SYMBOL(<ls_edid4>).
            CREATE DATA lr_bgm_general TYPE (ls_ediseg-segnam).
            ASSIGN lr_bgm_general->* TO FIELD-SYMBOL(<s_bgm_general>).
            <s_bgm_general> = <ls_edid4>-sdata.
            ASSIGN COMPONENT ls_ediseg-docnoid OF STRUCTURE <s_bgm_general> TO FIELD-SYMBOL(<s_crossrefno>).
            IF <s_crossrefno> IS ASSIGNED.
              ls_edid4_crf-crossrefno = <s_crossrefno>.
            ENDIF.
            ls_edid4_crf-docnum     = <ls_edid4>-docnum.
            ls_edid4_crf-crn_rev    = <ls_edid4>-docnum.
            INSERT ls_edid4_crf INTO TABLE rt_edid4_crf.
            CLEAR ls_edid4_crf.
          ENDLOOP.
        ENDIF.
      ENDAT.
    ENDLOOP.
  ENDMETHOD.                                                "get_edid4


  METHOD get_euitrans.
* Zählpunktbezeichnung
    CLEAR rt_euitrans.
    ASSIGN irt_idocs->* TO FIELD-SYMBOL(<lt_idocs>).
    CHECK NOT irt_idocs->* IS INITIAL.
    SELECT *
      FROM euitrans
        INTO TABLE rt_euitrans
             FOR ALL ENTRIES IN <lt_idocs>
             WHERE int_ui  = <lt_idocs>-int_ui
             AND datefrom <= <lt_idocs>-dexduedate
             AND dateto   >= <lt_idocs>-dexduedate.
  ENDMETHOD.                    "get_euitrans


  METHOD get_idocs.
* Serviceanbieter
*  METHOD get_edexdefservprov.
*    SELECT a~dexproc a~dexidocsend a~dexservprovself
*           a~dexservprov b~dexidocsendcat       "ET_20160401: Ergänzung um Feld dexidocsendcat
*      FROM edexdefservprov AS a
*   "Join mit Tabelle EDEXIDOCSEND
*      JOIN edexidocsend AS b
*        ON a~dexidocsend = b~dexidocsend         "ET_20160401: Join über das Feld dexidocsend
*      INTO CORRESPONDING FIELDS OF TABLE it_edexdefserprov
*      WHERE a~datefrom < so_datum-high
*        AND a~dateto   > so_datum-low
*        AND a~dexservprovself IN my_so_serv
*        AND a~dexservprov IN my_so_serve
*        AND a~dexproc IN t_dexproc.
*    SORT it_edexdefserprov.
*  ENDMETHOD.                   "get_edexdefservprov


* IDoc Status
    DATA lt_rng_status      TYPE /adz/hmv_rt_sart.
    DATA(lt_dexproc) = get_dexproc( EXPORTING is_rng_so_datum = is_rng_so_datum ).

    CLEAR et_idocs.
    SELECT t~int_ui t~dextaskid t~dexduedate
           t~dexrefdateto t~dexstatus t~dexservprov
           t~dexservprovself t~dexaedat t~dexproc
           i~docnum i~sent
           c~status c~credat c~cretim
           INTO CORRESPONDING FIELDS OF TABLE et_idocs
           FROM edextask AS t
           LEFT OUTER JOIN edextaskidoc
                AS i ON i~dextaskid = t~dextaskid
           INNER JOIN edidc
                AS c ON c~docnum = i~docnum
           WHERE t~dextaskid       IN ms_sel_params-so_taskid
             AND t~dexproc         IN lt_dexproc
             AND t~dexaedat        IN ms_sel_params-so_datum
             AND t~dexservprovself IN ms_sel_params-so_serv
             AND t~int_ui          IN ms_sel_params-so_intui
             AND t~dexservprov     IN ms_sel_params-so_serve.

    CHECK NOT et_idocs IS INITIAL.

    CALL METHOD /adz/cl_hmv_customizing=>get_idoc_status(
      EXPORTING
        is_so_datum = is_rng_so_datum
      IMPORTING
        et_stat     = lt_rng_status
        et_sart     = et_hmv_sart ).

    SELECT * FROM edids
      INTO CORRESPONDING FIELDS OF TABLE et_edids_status
      FOR ALL ENTRIES IN et_idocs
      WHERE docnum = et_idocs-docnum
        AND status IN lt_rng_status.
  ENDMETHOD.                    "get_idocs


  METHOD get_memidoc.
* Tabelle /IDXMM/MEMIDOC
    DATA lt_rng_crossrefno TYPE RANGE OF crossrefno.
    lt_rng_crossrefno = VALUE #( FOR ls IN irt_crsrf->*
      WHERE ( created_from EQ /idxmm/if_constants=>gc_createdfrom_m  )
        ( sign = 'I'  option = 'EQ'  low = ls-crossrefno  ) ).
    CHECK lt_rng_crossrefno IS NOT INITIAL.

    CLEAR rt_memidoc.
    SELECT * FROM /idxmm/memidoc INTO CORRESPONDING FIELDS OF TABLE rt_memidoc
      WHERE crossrefno IN lt_rng_crossrefno.
  ENDMETHOD.


  METHOD get_msbdoc.
    DATA ls_msbdoc  TYPE type_msbdoc.
    DATA lt_rng_crossrefno TYPE RANGE OF crossrefno.
    lt_rng_crossrefno = VALUE #( FOR ls IN irt_crsrf->*
      WHERE ( created_from EQ 'I' ) ( sign = 'I'  option = 'EQ'  low = ls-crossrefno  ) ).
    CHECK lt_rng_crossrefno IS NOT INITIAL.

    CLEAR rt_msbdoc.
    SELECT *  FROM dfkkinvdoc_h INTO  CORRESPONDING FIELDS OF TABLE rt_msbdoc
      WHERE /mosb/inv_doc_ident IN lt_rng_crossrefno.

    SELECT invdocno, invdocitem, opbel FROM dfkkinvdoc_i INTO TABLE @DATA(lt_dffinvdoc_i)
     FOR ALL ENTRIES IN @rt_msbdoc
     WHERE invdocno = @rt_msbdoc-invdocno.

    DATA ls_dffinvdoc_i LIKE LINE OF lt_dffinvdoc_i.
    DATA lt_dffinvdoc_i_h LIKE SORTED TABLE OF ls_dffinvdoc_i WITH NON-UNIQUE KEY invdocno.
    INSERT LINES OF lt_dffinvdoc_i INTO TABLE lt_dffinvdoc_i_h.
    CLEAR lt_dffinvdoc_i.

    LOOP AT rt_msbdoc INTO ls_msbdoc.
*      SELECT SINGLE opbel FROM dfkkinvdoc_i  INTO ls_msbdoc-opbel  WHERE invdocno = ls_msbdoc-invdocno.
*      IF sy-subrc EQ 0.
*        INSERT ls_msbdoc INTO  TABLE rt_msbdoc.
*      ENDIF.
      TRY.
          ls_msbdoc-opbel = lt_dffinvdoc_i_h[ invdocno =  ls_msbdoc-invdocno ].
        CATCH cx_sy_itab_line_not_found.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.        "get msbdoc.


  METHOD get_statistics.
    CLEAR cs_stats. "Statistik IDOC-Status
    cs_stats-datum = sy-datum.
    cs_stats-stati = sy-uzeit.
    DESCRIBE TABLE irt_idocs->* LINES cs_stats-anzda.
  ENDMETHOD.

  METHOD add_statistics.
    cs_sta2-anzda = cs_sta2-anzda + is_sta1-anzda.
    cs_sta2-updok = cs_sta2-updok + is_sta1-updok.
    cs_sta2-upder = cs_sta2-upder + is_sta1-upder.
  ENDMETHOD.

  METHOD update_stats_with_selvar.
    DATA:
      mt_valutab TYPE TABLE OF rsparams,
      s_valutab  TYPE          rsparams.

    IF ms_const-slset NE space.
      cs_sta-varia = ms_const-slset.
      CALL FUNCTION 'RS_VARIANT_CONTENTS'
        EXPORTING
          report  = ms_const-repid
          variant = ms_const-slset
        TABLES
          valutab = mt_valutab.

      IF sy-subrc = 0.
        DELETE mt_valutab WHERE selname NE 'SO_TASKI'.
        SORT mt_valutab BY low.
        DESCRIBE TABLE mt_valutab LINES DATA(lv_last_line).
        READ TABLE mt_valutab INTO s_valutab INDEX 1.
        cs_sta-low = s_valutab-low.
        READ TABLE mt_valutab INTO s_valutab INDEX lv_last_line.
        cs_sta-high = s_valutab-low.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD write_stats.
    GET TIME.
    cs_stats-endti = sy-uzeit.
    update_stats_with_selvar(  CHANGING cs_sta = cs_stats ).

    INSERT /adz/hmv_idoc FROM cs_stats.
    COMMIT WORK.
  ENDMETHOD.

  METHOD update_dfkkthi.
* Update DFKKTHI

    FIELD-SYMBOLS: <s_out> TYPE /adz/hmv_s_memi_out.

    DATA:
      wa_edidc    TYPE edidc,
      wa_dfkkthi  TYPE /adz/hmv_dfkk, "dfkkthi,
      p_to_update TYPE char2.

* !!! jeweils den Tabellenbereich mit ASSIGNING angesprochen !!!!
* !!! und Prüfung bei read ob assigned
    LOOP AT mt_output ASSIGNING <s_out> WHERE kennz EQ ms_const-c_doc_kzd.
*      CLEAR p_to_update.
*      IF ( <s_out>-idocin IS NOT INITIAL ) AND ( <s_out>-status_i IS NOT INITIAL ) AND ( <s_out>-dexidocsent IS NOT INITIAL ).
*        p_to_update+0(1) = 'X'.
*      ENDIF.
*      IF ( <s_out>-idocct IS NOT INITIAL ) AND ( <s_out>-status_c IS NOT INITIAL ) AND ( <s_out>-dexidocsentctrl IS NOT INITIAL ).
*        p_to_update+1(1) = 'X'.
*      ENDIF.

* UPDATE Tabelle DFKKTHI
      CLEAR wa_dfkkthi.
      wa_dfkkthi-opbel = <s_out>-opbel.
      wa_dfkkthi-opupw = <s_out>-opupw.
      wa_dfkkthi-opupk = <s_out>-opupk.
      wa_dfkkthi-opupz = <s_out>-opupz.
      wa_dfkkthi-thinr = <s_out>-thinr.

      SELECT SINGLE * FROM /adz/hmv_dfkk INTO @DATA(ls_aktueller_satz) WHERE opbel = @<s_out>-opbel AND
                                                                                opupw = @<s_out>-opupw AND
                                                                                opupk = @<s_out>-opupk AND
                                                                                opupz = @<s_out>-opupz AND
                                                                                thinr = @<s_out>-thinr.

*      CASE p_to_update.
*        WHEN 'XX'.
* Update invoice und control status
      wa_dfkkthi-idocin          = COND #( WHEN ls_aktueller_satz-idocin IS NOT INITIAL AND <s_out>-idocin IS INITIAL THEN ls_aktueller_satz-idocin ELSE <s_out>-idocin ).
      wa_dfkkthi-statin          = COND #( WHEN ls_aktueller_satz-statin IS NOT INITIAL AND <s_out>-status_i IS INITIAL THEN ls_aktueller_satz-statin ELSE <s_out>-status_i ).
      wa_dfkkthi-idocct          = COND #( WHEN ls_aktueller_satz-idocct IS NOT INITIAL AND <s_out>-idocct IS INITIAL THEN ls_aktueller_satz-idocct ELSE <s_out>-idocct ).
      wa_dfkkthi-statct          = COND #( WHEN ls_aktueller_satz-statct IS NOT INITIAL AND <s_out>-status_c IS INITIAL THEN ls_aktueller_satz-statct ELSE <s_out>-status_c ).
      wa_dfkkthi-dexidocsent     = COND #( WHEN ls_aktueller_satz-dexidocsent IS NOT INITIAL AND <s_out>-dexidocsent IS INITIAL THEN ls_aktueller_satz-dexidocsent ELSE <s_out>-dexidocsent ).
      wa_dfkkthi-dexidocsentctrl = COND #( WHEN ls_aktueller_satz-dexidocsentctrl IS NOT INITIAL AND <s_out>-dexidocsentctrl IS INITIAL THEN ls_aktueller_satz-dexidocsentctrl ELSE <s_out>-dexidocsentctrl ).
      wa_dfkkthi-dexidocsendcat  = COND #( WHEN ls_aktueller_satz-dexidocsendcat IS NOT INITIAL AND <s_out>-dexidocsendcat IS INITIAL THEN ls_aktueller_satz-dexidocsendcat ELSE <s_out>-dexidocsendcat ).
      wa_dfkkthi-dexproc         = COND #( WHEN ls_aktueller_satz-dexproc IS NOT INITIAL AND <s_out>-dexproc IS INITIAL THEN ls_aktueller_satz-dexproc ELSE <s_out>-dexproc ).
      MODIFY /adz/hmv_dfkk FROM wa_dfkkthi.
      IF sy-subrc = 0.
        cs_stats-updok = cs_stats-updok + 1.
        <s_out>-status = icon_led_green.
      ELSE.
        cs_stats-upder = cs_stats-upder + 1.
        <s_out>-status = icon_led_red.
      ENDIF.

* Update invoice status
*        WHEN 'X '.
*          wa_dfkkthi-idocin          = COND #( WHEN ls_aktueller_satz-idocin IS NOT INITIAL AND <s_out>-idocin IS INITIAL THEN ls_aktueller_satz-idocin ELSE <s_out>-idocin ).
*          wa_dfkkthi-statin          = COND #( WHEN ls_aktueller_satz-statin IS NOT INITIAL AND <s_out>-status_i IS INITIAL THEN ls_aktueller_satz-statin ELSE <s_out>-status_i ).
*          wa_dfkkthi-dexidocsent     = COND #( WHEN ls_aktueller_satz-dexidocsent IS NOT INITIAL AND <s_out>-dexidocsent IS INITIAL THEN ls_aktueller_satz-dexidocsent ELSE <s_out>-dexidocsent ).
*          wa_dfkkthi-dexidocsendcat  = COND #( WHEN ls_aktueller_satz-dexidocsendcat IS NOT INITIAL AND <s_out>-dexidocsendcat IS INITIAL THEN ls_aktueller_satz-dexidocsendcat ELSE <s_out>-dexidocsendcat ).
*          wa_dfkkthi-dexproc         = COND #( WHEN ls_aktueller_satz-dexproc IS NOT INITIAL AND <s_out>-dexproc IS INITIAL THEN ls_aktueller_satz-dexproc ELSE <s_out>-dexproc ).
*          MODIFY /ADZ/hmv_dfkk FROM wa_dfkkthi.
*          IF sy-subrc = 0.
*            ADD 1 TO x_updok.
*            <s_out>-status = icon_led_green.
*          ELSE.
*            ADD 1 TO x_upder.
*            <s_out>-status = icon_led_red.
*          ENDIF.
*
** Update control status
*        WHEN ' X'.
*          wa_dfkkthi-idocct          = COND #( WHEN ls_aktueller_satz-idocct IS NOT INITIAL AND <s_out>-idocct IS INITIAL THEN ls_aktueller_satz-idocct ELSE <s_out>-idocct ).
*          wa_dfkkthi-statct          = COND #( WHEN ls_aktueller_satz-statct IS NOT INITIAL AND <s_out>-status_c IS INITIAL THEN ls_aktueller_satz-statct ELSE <s_out>-status_c ).
*          wa_dfkkthi-dexidocsentctrl = COND #( WHEN ls_aktueller_satz-dexidocsentctrl IS NOT INITIAL AND <s_out>-dexidocsentctrl IS INITIAL THEN ls_aktueller_satz-dexidocsentctrl ELSE <s_out>-dexidocsentctrl ).
*          wa_dfkkthi-dexidocsendcat  = COND #( WHEN ls_aktueller_satz-dexidocsendcat IS NOT INITIAL AND <s_out>-dexidocsendcat IS INITIAL THEN ls_aktueller_satz-dexidocsendcat ELSE <s_out>-dexidocsendcat ).
*          wa_dfkkthi-dexproc         = COND #( WHEN ls_aktueller_satz-dexproc IS NOT INITIAL AND <s_out>-dexproc IS INITIAL THEN ls_aktueller_satz-dexproc ELSE <s_out>-dexproc ).
*          MODIFY /ADZ/hmv_dfkk FROM wa_dfkkthi.
*          IF sy-subrc = 0.
*            ADD 1 TO x_updok.
*            <s_out>-status = icon_led_green.
*          ELSE.
*            ADD 1 TO x_upder.
*            <s_out>-status = icon_led_red.
*          ENDIF.
* Kein Update
*        WHEN OTHERS.
*          <s_out>-status = icon_led_yellow.
*      ENDCASE.
      MODIFY mt_output FROM <s_out>.
      CLEAR ls_aktueller_satz.
    ENDLOOP.
  ENDMETHOD.                "update_dfkkthi


  METHOD update_memidoc.
* Update /IDXMM/MEMIDOC
    FIELD-SYMBOLS: <s_out> TYPE /adz/hmv_s_memi_out.

    DATA:
      wa_edidc    TYPE edidc,
      wa_memidoc  TYPE /adz/hmv_memi,
      wa_memitemp TYPE /adz/hmv_memi,
      p_to_update TYPE char2.

* !!! jeweils den Tabellenbereich mit ASSIGNING angesprochen !!!!
* !!! und Prüfung bei read ob assigned
    LOOP AT mt_output ASSIGNING <s_out>
      WHERE kennz EQ /idxmm/if_constants=>gc_createdfrom_m.

*      CLEAR p_to_update.
*      IF ( <s_out>-idocin IS NOT INITIAL ) AND ( <s_out>-status_i IS NOT INITIAL ) AND ( <s_out>-dexidocsent IS NOT INITIAL ).
*        p_to_update+0(1) = 'X'.
*      ENDIF.
*      IF ( <s_out>-idocct IS NOT INITIAL ) AND ( <s_out>-status_c IS NOT INITIAL ) AND ( <s_out>-dexidocsentctrl IS NOT INITIAL ).
*        p_to_update+1(1) = 'X'.
*      ENDIF.

      CLEAR wa_memidoc.
      wa_memidoc-doc_id = <s_out>-opbel.

      SELECT SINGLE * FROM /adz/hmv_memi INTO @DATA(ls_aktueller_satz) WHERE doc_id = @<s_out>-opbel.

* Update invoice- und control-status
*      CASE p_to_update.
*        WHEN 'XX'.
      wa_memidoc-idocin          = COND #( WHEN ls_aktueller_satz-idocin IS NOT INITIAL AND <s_out>-idocin IS INITIAL THEN ls_aktueller_satz-idocin ELSE <s_out>-idocin ).
      wa_memidoc-statin          = COND #( WHEN ls_aktueller_satz-statin IS NOT INITIAL AND <s_out>-status_i IS INITIAL THEN ls_aktueller_satz-statin ELSE <s_out>-status_i ).
      wa_memidoc-idocct          = COND #( WHEN ls_aktueller_satz-idocct IS NOT INITIAL AND <s_out>-idocct IS INITIAL THEN ls_aktueller_satz-idocct ELSE <s_out>-idocct ).
      wa_memidoc-statct          = COND #( WHEN ls_aktueller_satz-statct IS NOT INITIAL AND <s_out>-status_c IS INITIAL THEN ls_aktueller_satz-statct ELSE <s_out>-status_c ).
      wa_memidoc-dexidocsent     = COND #( WHEN ls_aktueller_satz-dexidocsent IS NOT INITIAL AND <s_out>-dexidocsent IS INITIAL THEN ls_aktueller_satz-dexidocsent ELSE <s_out>-dexidocsent ).
      wa_memidoc-dexidocsentctrl = COND #( WHEN ls_aktueller_satz-dexidocsentctrl IS NOT INITIAL AND <s_out>-dexidocsentctrl IS INITIAL THEN ls_aktueller_satz-dexidocsentctrl ELSE <s_out>-dexidocsentctrl ).
      wa_memidoc-dexidocsendcat  = COND #( WHEN ls_aktueller_satz-dexidocsendcat IS NOT INITIAL AND <s_out>-dexidocsendcat IS INITIAL THEN ls_aktueller_satz-dexidocsendcat ELSE <s_out>-dexidocsendcat ).
      wa_memidoc-dexproc         = COND #( WHEN ls_aktueller_satz-dexproc IS NOT INITIAL AND <s_out>-dexproc IS INITIAL THEN ls_aktueller_satz-dexproc ELSE <s_out>-dexproc ).

      MODIFY /adz/hmv_memi FROM wa_memidoc.
      IF sy-subrc = 0.
        cs_stats-updok = cs_stats-updok + 1.
        <s_out>-status = icon_led_green.
      ELSE.
        cs_stats-upder = cs_stats-upder + 1.
        <s_out>-status = icon_led_red.
      ENDIF.

* Update invoice status
*        WHEN 'X '.
*          wa_memidoc-idocin          = COND #( WHEN ls_aktueller_satz-idocin IS NOT INITIAL AND <s_out>-idocin IS INITIAL THEN ls_aktueller_satz-idocin ELSE <s_out>-idocin ).
*          wa_memidoc-statin          = COND #( WHEN ls_aktueller_satz-statin IS NOT INITIAL AND <s_out>-status_i IS INITIAL THEN ls_aktueller_satz-statin ELSE <s_out>-status_i ).
*          wa_memidoc-dexidocsent     = COND #( WHEN ls_aktueller_satz-dexidocsent IS NOT INITIAL AND <s_out>-dexidocsent IS INITIAL THEN ls_aktueller_satz-dexidocsent ELSE <s_out>-dexidocsent ).
*          wa_memidoc-dexidocsendcat  = COND #( WHEN ls_aktueller_satz-dexidocsendcat IS NOT INITIAL AND <s_out>-dexidocsendcat IS INITIAL THEN ls_aktueller_satz-dexidocsendcat ELSE <s_out>-dexidocsendcat ).
*          wa_memidoc-dexproc         = COND #( WHEN ls_aktueller_satz-dexproc IS NOT INITIAL AND <s_out>-dexproc IS INITIAL THEN ls_aktueller_satz-dexproc ELSE <s_out>-dexproc ).
*          MODIFY /ADZ/hmv_memi FROM wa_memidoc.
*          IF sy-subrc = 0.
*            ADD 1 TO x_upd_memi_ok.
*            <s_out>-status = icon_led_green.
*          ELSE.
*            ADD 1 TO x_upd_memi_er.
*            <s_out>-status = icon_led_red.
*          ENDIF.
*
** Update control status
*        WHEN ' X'.
*          wa_memidoc-idocct          = COND #( WHEN ls_aktueller_satz-idocct IS NOT INITIAL AND <s_out>-idocct IS INITIAL THEN ls_aktueller_satz-idocct ELSE <s_out>-idocct ).
*          wa_memidoc-statct          = COND #( WHEN ls_aktueller_satz-statct IS NOT INITIAL AND <s_out>-status_c IS INITIAL THEN ls_aktueller_satz-statct ELSE <s_out>-status_c ).
*          wa_memidoc-dexidocsentctrl = COND #( WHEN ls_aktueller_satz-dexidocsentctrl IS NOT INITIAL AND <s_out>-dexidocsentctrl IS INITIAL THEN ls_aktueller_satz-dexidocsentctrl ELSE <s_out>-dexidocsentctrl ).
*          wa_memidoc-dexidocsendcat  = COND #( WHEN ls_aktueller_satz-dexidocsendcat IS NOT INITIAL AND <s_out>-dexidocsendcat IS INITIAL THEN ls_aktueller_satz-dexidocsendcat ELSE <s_out>-dexidocsendcat ).
*          wa_memidoc-dexproc         = COND #( WHEN ls_aktueller_satz-dexproc IS NOT INITIAL AND <s_out>-dexproc IS INITIAL THEN ls_aktueller_satz-dexproc ELSE <s_out>-dexproc ).
*          MODIFY /ADZ/hmv_memi FROM wa_memidoc.
*          IF sy-subrc = 0.
*            ADD 1 TO x_upd_memi_ok.
*            <s_out>-status = icon_led_green.
*          ELSE.
*            ADD 1 TO x_upd_memi_er.
*            <s_out>-status = icon_led_red.
*          ENDIF.
** Kein Update
*        WHEN OTHERS.
*          <s_out>-status = icon_led_yellow.
*      ENDCASE.
      MODIFY mt_output FROM <s_out>.
      CLEAR ls_aktueller_satz.
    ENDLOOP.
  ENDMETHOD.              "update_memidoc


  METHOD update_msbdoc.

    FIELD-SYMBOLS: <s_out> TYPE /adz/hmv_s_memi_out.

    DATA:
      wa_edidc    TYPE edidc,
      wa_msbdoc   TYPE /adz/hmv_mosb,
      p_to_update TYPE char2.

* !!! jeweils den Tabellenbereich mit ASSIGNING angesprochen !!!!
* !!! und Prüfung bei read ob assigned
    LOOP AT mt_output ASSIGNING <s_out>
      WHERE kennz EQ 'I'.

*      CLEAR p_to_update.
*      IF ( <s_out>-idocin IS NOT INITIAL ) AND ( <s_out>-status_i IS NOT INITIAL ) AND ( <s_out>-dexidocsent IS NOT INITIAL ).
*        p_to_update+0(1) = 'X'.
*      ENDIF.
*      IF ( <s_out>-idocct IS NOT INITIAL ) AND ( <s_out>-status_c IS NOT INITIAL ) AND ( <s_out>-dexidocsentctrl IS NOT INITIAL ).
*        p_to_update+1(1) = 'X'.
*      ENDIF.

      CLEAR wa_msbdoc.
      wa_msbdoc-invdocno = <s_out>-opbel.

      SELECT SINGLE * FROM /adz/hmv_mosb INTO @DATA(ls_aktueller_satz) WHERE invdocno = @<s_out>-opbel.

* Update invoice- und control-status
*      CASE p_to_update.
*        WHEN 'XX'.
      wa_msbdoc-idocin          = COND #( WHEN ls_aktueller_satz-idocin IS NOT INITIAL AND <s_out>-idocin IS INITIAL THEN ls_aktueller_satz-idocin ELSE <s_out>-idocin ).
      wa_msbdoc-statin          = COND #( WHEN ls_aktueller_satz-statin IS NOT INITIAL AND <s_out>-status_i IS INITIAL THEN ls_aktueller_satz-statin ELSE <s_out>-status_i ).
      wa_msbdoc-idocct          = COND #( WHEN ls_aktueller_satz-idocct IS NOT INITIAL AND <s_out>-idocct IS INITIAL THEN ls_aktueller_satz-idocct ELSE <s_out>-idocct ).
      wa_msbdoc-statct          = COND #( WHEN ls_aktueller_satz-statct IS NOT INITIAL AND <s_out>-status_c IS INITIAL THEN ls_aktueller_satz-statct ELSE <s_out>-status_c ).
      wa_msbdoc-dexidocsent     = COND #( WHEN ls_aktueller_satz-dexidocsent IS NOT INITIAL AND <s_out>-dexidocsent IS INITIAL THEN ls_aktueller_satz-dexidocsent ELSE <s_out>-dexidocsent ).
      wa_msbdoc-dexidocsentctrl = COND #( WHEN ls_aktueller_satz-dexidocsentctrl IS NOT INITIAL AND <s_out>-dexidocsentctrl IS INITIAL THEN ls_aktueller_satz-dexidocsentctrl ELSE <s_out>-dexidocsentctrl ).
      wa_msbdoc-dexidocsendcat  = COND #( WHEN ls_aktueller_satz-dexidocsendcat IS NOT INITIAL AND <s_out>-dexidocsendcat IS INITIAL THEN ls_aktueller_satz-dexidocsendcat ELSE <s_out>-dexidocsendcat ).
      wa_msbdoc-dexproc         = COND #( WHEN ls_aktueller_satz-dexproc IS NOT INITIAL AND <s_out>-dexproc IS INITIAL THEN ls_aktueller_satz-dexproc ELSE <s_out>-dexproc ).
      MODIFY /adz/hmv_mosb FROM wa_msbdoc.
      IF sy-subrc = 0.
        cs_stats-updok = cs_stats-updok + 1.
        <s_out>-status = icon_led_green.
      ELSE.
        cs_stats-upder = cs_stats-upder + 1.
        <s_out>-status = icon_led_red.
      ENDIF.

** Update invoice status
*        WHEN 'X '.
*          wa_msbdoc-idocin          = COND #( WHEN ls_aktueller_satz-idocin IS NOT INITIAL AND <s_out>-idocin IS INITIAL THEN ls_aktueller_satz-idocin ELSE <s_out>-idocin ).
*          wa_msbdoc-statin          = COND #( WHEN ls_aktueller_satz-statin IS NOT INITIAL AND <s_out>-status_i IS INITIAL THEN ls_aktueller_satz-statin ELSE <s_out>-status_i ).
*          wa_msbdoc-dexidocsent     = COND #( WHEN ls_aktueller_satz-dexidocsent IS NOT INITIAL AND <s_out>-dexidocsent IS INITIAL THEN ls_aktueller_satz-dexidocsent ELSE <s_out>-dexidocsent ).
*          wa_msbdoc-dexidocsendcat  = COND #( WHEN ls_aktueller_satz-dexidocsendcat IS NOT INITIAL AND <s_out>-dexidocsendcat IS INITIAL THEN ls_aktueller_satz-dexidocsendcat ELSE <s_out>-dexidocsendcat ).
*          wa_msbdoc-dexproc         = COND #( WHEN ls_aktueller_satz-dexproc IS NOT INITIAL AND <s_out>-dexproc IS INITIAL THEN ls_aktueller_satz-dexproc ELSE <s_out>-dexproc ).
*          MODIFY /ADZ/hmv_mosb FROM wa_msbdoc.
*          IF sy-subrc = 0.
*            ADD 1 TO x_upd_msb_ok.
*            <s_out>-status = icon_led_green.
*          ELSE.
*            ADD 1 TO x_upd_msb_er.
*            <s_out>-status = icon_led_red.
*          ENDIF.
*
** Update control status
*        WHEN ' X'.
*          wa_msbdoc-idocct          = COND #( WHEN ls_aktueller_satz-idocct IS NOT INITIAL AND <s_out>-idocct IS INITIAL THEN ls_aktueller_satz-idocct ELSE <s_out>-idocct ).
*          wa_msbdoc-statct          = COND #( WHEN ls_aktueller_satz-statct IS NOT INITIAL AND <s_out>-status_c IS INITIAL THEN ls_aktueller_satz-statct ELSE <s_out>-status_c ).
*          wa_msbdoc-dexidocsentctrl = COND #( WHEN ls_aktueller_satz-dexidocsentctrl IS NOT INITIAL AND <s_out>-dexidocsentctrl IS INITIAL THEN ls_aktueller_satz-dexidocsentctrl ELSE <s_out>-dexidocsentctrl ).
*          wa_msbdoc-dexidocsendcat  = COND #( WHEN ls_aktueller_satz-dexidocsendcat IS NOT INITIAL AND <s_out>-dexidocsendcat IS INITIAL THEN ls_aktueller_satz-dexidocsendcat ELSE <s_out>-dexidocsendcat ).
*          wa_msbdoc-dexproc         = COND #( WHEN ls_aktueller_satz-dexproc IS NOT INITIAL AND <s_out>-dexproc IS INITIAL THEN ls_aktueller_satz-dexproc ELSE <s_out>-dexproc ).
*          MODIFY /ADZ/hmv_mosb FROM wa_msbdoc.
*          IF sy-subrc = 0.
*            ADD 1 TO x_upd_msb_ok.
*            <s_out>-status = icon_led_green.
*          ELSE.
*            ADD 1 TO x_upd_msb_er.
*            <s_out>-status = icon_led_red.
*          ENDIF.
** Kein Update
*        WHEN OTHERS.
*          <s_out>-status = icon_led_yellow.
*      ENDCASE.
      MODIFY mt_output FROM <s_out>.
      CLEAR ls_aktueller_satz.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.

