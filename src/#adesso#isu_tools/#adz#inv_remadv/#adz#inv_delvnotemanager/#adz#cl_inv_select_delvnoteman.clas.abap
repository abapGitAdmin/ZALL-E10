CLASS /adz/cl_inv_select_delvnoteman DEFINITION
  PUBLIC
  FINAL.

  PUBLIC SECTION.
    DATA mt_out_data         TYPE /adz/inv_t_out_delvnoteman.
    DATA mt_pdoc_data        TYPE /idxgc/t_pdoc_data.
    DATA mt_proc_data        TYPE /idxgc/t_proc_data.
    METHODS  :
      read_data        IMPORTING is_sel_screen TYPE /adz/inv_s_delvnoteman_selpar,
      read_basic_data  IMPORTING is_sel_screen TYPE /adz/inv_s_delvnoteman_selpar.

  PROTECTED SECTION.
    METHODS :
      get_internal_pod
        IMPORTING it_r_sel_ext_ui      TYPE /adz/inv_rt_ext_ui
        RETURNING VALUE(rt_sel_int_ui) TYPE isu00_range_tab,

      get_storno_kz
        CHANGING cs_wa_out   TYPE /adz/inv_s_out_delvnoteman
                 cs_post_sel TYPE /adz/inv_s_delvnoteman_selpar OPTIONAL.

  PRIVATE SECTION.

ENDCLASS.

CLASS /adz/cl_inv_select_delvnoteman IMPLEMENTATION.
  METHOD read_data.
    DATA ls_wa_out     TYPE /adz/inv_s_out_delvnoteman.
    DATA lv_step10_ref TYPE /idxgc/de_proc_step_ref.
    DATA lo_emma_dbl   TYPE REF TO cl_emma_dbl.
    DATA lo_case       TYPE REF TO cl_emma_case.
    DATA ls_post_sel   LIKE is_sel_screen.

    read_basic_data( is_sel_screen ).
    CLEAR mt_out_data.
    IF mt_pdoc_data IS INITIAL.
      RETURN.
    ENDIF.

    DATA lt_rng_proc_ref TYPE RANGE OF /idxgc/de_proc_ref.
    lt_rng_proc_ref = VALUE #( FOR lsp IN mt_pdoc_data ( sign = 'I' option = 'EQ' low = lsp-switchnum ) ).

    " PreSelects für alle proc_refs
    SELECT proc_ref, proc_step_ref, proc_step_no, dline_timestamp, msg_refno, intch_contr_ref FROM /idxgc/prst_hdr
      INTO TABLE @DATA(lt_proc_steps)
      WHERE proc_ref IN @lt_rng_proc_ref.

    " Kennziffern Zählwerk und Qualifier
    SELECT proc_ref, proc_step_ref, reg_code, reg_code_qual  FROM /idxgc/prst_regc
      INTO TABLE @DATA(lt_reg_codes)
      WHERE proc_ref IN @lt_rng_proc_ref.
    TYPES ty_reg_codes LIKE LINE OF lt_reg_codes.
    DATA lt_reg_codes_h TYPE SORTED TABLE OF ty_reg_codes WITH NON-UNIQUE KEY proc_ref  proc_step_ref.
    INSERT LINES OF lt_reg_codes INTO TABLE lt_reg_codes_h.
    CLEAR lt_reg_codes.

    " MSCons
    TYPES: BEGIN OF ty_prst_mchd,
             proc_ref      TYPE /idxgc/prst_mchd-proc_ref,
             proc_step_ref TYPE /idxgc/prst_mchd-proc_step_ref,
             procdate      TYPE /idxgc/prst_mchd-procdate,
           END OF ty_prst_mchd.
    DATA lt_mscons_h TYPE HASHED TABLE OF ty_prst_mchd WITH UNIQUE KEY proc_ref proc_step_ref.
    SELECT proc_ref, proc_step_ref, procdate  FROM /idxgc/prst_mchd
      INTO TABLE @lt_mscons_h
      WHERE proc_ref IN @lt_rng_proc_ref.


    " Sender / Receiver
    SELECT *  FROM /idxgc/prst_mkpr
      INTO TABLE @DATA(lt_step_add_mkpr)
      WHERE proc_ref IN @lt_rng_proc_ref.
    TYPES ty_mkpr LIKE LINE OF lt_step_add_mkpr.
    DATA lt_step_add_mkpr_h TYPE SORTED TABLE OF ty_mkpr WITH NON-UNIQUE KEY proc_ref  proc_step_ref  party_func_qual.
    INSERT LINES OF lt_step_add_mkpr INTO TABLE lt_step_add_mkpr_h.
    CLEAR lt_step_add_mkpr.

    " Energiemengen
    SELECT proc_ref, proc_step_ref, quant_type_qual, quantity_ext, datefrom, dateto FROM /idxgc/prst_mciq
      INTO TABLE @DATA(lt_mciq)
      WHERE proc_ref IN @lt_rng_proc_ref.
    TYPES ty_mciq LIKE LINE OF lt_mciq.
    DATA lt_mciq_h TYPE SORTED TABLE OF ty_mciq WITH NON-UNIQUE KEY proc_ref  proc_step_ref.
    INSERT LINES OF lt_mciq INTO TABLE lt_mciq_h.
    CLEAR lt_mciq.

    " Ausnahmen/Klärungsfälle
    SELECT mainobjkey, casenr, ccat, prio, casetxt, zz_casetxt, status, created_date, created_time   FROM emma_case   INTO TABLE @DATA(lt_bpem_cases)
      WHERE ( mainobjtype = @if_isu_ide_switch_constants=>co_object_type
          OR  mainobjtype = @/idxgc/if_constants=>gc_object_pdoc_bor )
         AND  mainobjkey  IN @lt_rng_proc_ref.
    TYPES ty_cases LIKE LINE OF lt_bpem_cases.
    DATA lt_bpem_cases_h TYPE SORTED TABLE OF ty_cases WITH NON-UNIQUE KEY mainobjkey.
    INSERT LINES OF lt_bpem_cases INTO TABLE lt_bpem_cases_h.
    CLEAR lt_bpem_cases.

    DATA lt_bpem_cases_pr LIKE lt_bpem_cases.
    IF lo_emma_dbl IS INITIAL.
      lo_emma_dbl = cl_emma_dbl=>create_dblayer( ).
    ENDIF.

    " Zählpunktbezeichnung/Markt-LokationsId
    TYPES: BEGIN OF ty_eidesmsg_redu,
             switchnum  TYPE eideswtmsgdata-switchnum,
             msgdatanum TYPE eideswtmsgdata-msgdatanum,
             ext_ui     TYPE eideswtmsgdata-ext_ui,
           END OF ty_eidesmsg_redu.
    DATA lt_extui TYPE HASHED TABLE OF ty_eidesmsg_redu WITH UNIQUE KEY switchnum msgdatanum.
    SELECT switchnum, msgdatanum, ext_ui FROM eideswtmsgdata INTO TABLE @lt_extui
      WHERE switchnum IN @lt_rng_proc_ref.

    DATA lt_rng_pod TYPE RANGE OF int_ui.
    lt_rng_pod = VALUE #( FOR lsp IN mt_pdoc_data ( sign = 'I' option = 'EQ' low = lsp-pod ) ).
    " Anlage
    SELECT a~int_ui,  a~anlage, c~tariftyp, c~ab, c~bis, b~service
      INTO TABLE @DATA(lt_anlage)
      FROM euiinstln AS a
        INNER JOIN eanl AS b
          ON a~anlage = b~anlage
        INNER JOIN eanlh AS c
          ON a~anlage = c~anlage
      WHERE a~int_ui IN @lt_rng_pod
      AND   a~dateto   GE @sy-datum
      AND   a~datefrom LE @sy-datum
      "AND   a~anlage = b~anlage
      "AND   a~anlage = c~anlage
      AND   c~bis   GE @sy-datum
      AND   c~ab    LE @sy-datum.
    TYPES ty_anlage LIKE LINE OF lt_anlage.
    DATA lt_anlage_h TYPE SORTED TABLE OF ty_anlage WITH NON-UNIQUE KEY int_ui.
    INSERT LINES OF lt_anlage INTO TABLE lt_anlage_h.
    CLEAR lt_anlage.

    " Vertrag
    DATA lt_rng_anlage TYPE RANGE OF ever-anlage.
    lt_rng_anlage = VALUE #( FOR lanl IN lt_anlage_h  ( sign = 'I'  option = 'EQ'  low = lanl-anlage ) ).
    SELECT anlage, vertrag, einzdat, auszdat FROM ever AS d INTO TABLE @DATA(lt_vertrag)
      WHERE   d~anlage   IN  @lt_rng_anlage
         AND    d~auszdat >= @sy-datum   " @ls_anlage-ab
         AND    d~einzdat <= @sy-datum.  " @ls_anlage-bis.
    TYPES ty_vertrag LIKE LINE OF lt_vertrag.
    DATA lt_vertrag_h TYPE SORTED TABLE OF ty_vertrag WITH NON-UNIQUE KEY anlage.
    INSERT LINES OF lt_vertrag INTO TABLE lt_vertrag_h.
    CLEAR lt_vertrag.

    "-------------------------------------------------------------------------------------------------------------------
    LOOP AT mt_pdoc_data  ASSIGNING FIELD-SYMBOL(<ls_pdoc>).
      CLEAR ls_wa_out.
      ls_wa_out = CORRESPONDING #( <ls_pdoc> ).
      ls_wa_out-proc_ref = <ls_pdoc>-switchnum.

      ls_wa_out-spartyp_text = /adz/cl_inv_select_basic=>get_domain_text(
          EXPORTING  iv_domtabname = 'SPARTYP'     iv_value  = CONV #( ls_wa_out-spartyp ) ).

      TRY.
          " Zählpunktbezeichnung/Markt-LokationsId
          " ersten Step holen
          DATA(lv_first_step_ref) = <ls_pdoc>-step_links[ 1 ]-step_ref.
          ls_wa_out-ext_ui = lt_extui[ switchnum = <ls_pdoc>-switchnum msgdatanum = lv_first_step_ref ]-ext_ui.
        CATCH cx_sy_itab_line_not_found.
      ENDTRY.

      TRY.
          " Schrittfolge 010 bestimmen geht nicht
          " erste Schrittfolge bestimmen
          CLEAR lv_step10_ref.
          lv_step10_ref = <ls_pdoc>-step_links[ 1 ]-step_ref. " condition_no = '010' ]-step_ref.
          ls_wa_out-proc_step10_ref = lv_step10_ref.
        CATCH cx_sy_itab_line_not_found.
      ENDTRY.

      IF lv_step10_ref IS NOT INITIAL.
        " Verweisnr auf Lieferschein für Suche in Belegen (tinv_inv_doc)
        ls_wa_out-ref_to_beleg = lt_proc_steps[ proc_ref = ls_wa_out-proc_ref  proc_step_ref = lv_step10_ref ]-msg_refno.

        " Sender / Receiver aus Schrittfolge 10
        LOOP AT lt_step_add_mkpr_h  ASSIGNING FIELD-SYMBOL(<ls_mkpr>)
        WHERE  proc_ref      = ls_wa_out-proc_ref
          AND  proc_step_ref = lv_step10_ref
          AND  ( party_func_qual = 'MR' OR party_func_qual = 'MS' ).

          IF <ls_mkpr>-party_func_qual = 'MR'.
            ls_wa_out-int_receiver = /adz/cl_inv_select_basic=>get_serviceid_sender_receiver( <ls_mkpr>-party_identifier ).
          ELSEIF <ls_mkpr>-party_func_qual = 'MS'.
            ls_wa_out-int_sender = /adz/cl_inv_select_basic=>get_serviceid_sender_receiver( <ls_mkpr>-party_identifier ).
          ENDIF.
        ENDLOOP.
        " eventuell durch Selektionsparameter ausgeschlossen
        IF ls_wa_out-int_receiver NOT IN is_sel_screen-so_receiver
        OR ls_wa_out-int_sender   NOT IN is_sel_screen-so_sender.
          CONTINUE.
        ENDIF.

        " MSCONS-Datum aus Schrittfolge 10
        TRY.
            ls_wa_out-mscons_procdate = lt_mscons_h[ proc_ref = ls_wa_out-proc_ref  proc_step_ref = lv_step10_ref ]-procdate.
          CATCH cx_sy_itab_line_not_found.
        ENDTRY.


        " Kennziffern Zählwerk und Qualifier auch aus Schrittfolge 10
        LOOP AT lt_reg_codes_h ASSIGNING FIELD-SYMBOL(<ls_reg>)
          WHERE proc_ref     = ls_wa_out-proc_ref
          AND  proc_step_ref = lv_step10_ref.

          ls_wa_out-kz_zw    = <ls_reg>-reg_code.
          ls_wa_out-kz_qual  = <ls_reg>-reg_code_qual.
          EXIT.
        ENDLOOP.

        " Energiemengen auch aus Schrittfolge 10
        LOOP AT lt_mciq_h ASSIGNING FIELD-SYMBOL(<ls_mciq>)
        WHERE proc_ref      = ls_wa_out-proc_ref
         AND  proc_step_ref = lv_step10_ref.
          IF ls_wa_out-quant_type_qual IS INITIAL.
            ls_wa_out-quant_type_qual = <ls_mciq>-quant_type_qual.
            ls_wa_out-quantity_ext    = <ls_mciq>-quantity_ext.
            ls_wa_out-datefrom        = <ls_mciq>-datefrom.
            ls_wa_out-dateto          = <ls_mciq>-dateto.
          ELSE.
            ls_wa_out-quantity_ext    = ls_wa_out-quantity_ext + <ls_mciq>-quantity_ext.
          ENDIF.
        ENDLOOP.
        " für Excel-Uploads
        REPLACE '.' IN ls_wa_out-quantity_ext WITH ','.

        TRY.
            " Lieferscheintermin
            DATA(lv_timestamp) = lt_proc_steps[ proc_ref = ls_wa_out-proc_ref  proc_step_no = '0030' ]-dline_timestamp.
            DATA ls_terminzeit TYPE  time.

            CONVERT TIME STAMP lv_timestamp TIME ZONE sy-zonlo
            INTO DATE ls_wa_out-ls_termin
                 TIME ls_terminzeit.

          CATCH cx_sy_itab_line_not_found.
        ENDTRY.
      ENDIF.

      TRY.
          " Verweis auf anderen Lieferschein in zus. Kopfdaten
          DATA(process_link) = <ls_pdoc>-process_links[ proc_id = 'DE_DELVNOTE_SUP' ].
          IF process_link-proc_ref NE ls_wa_out-proc_ref.  " Verweis auf sich selbst => ist bereits LS2
            ls_wa_out-ls2_proc_ref = process_link-proc_ref.
          ELSEIF process_link-assoc_proc_ref NE ls_wa_out-proc_ref.  " Verweis auf sich selbst => ist bereits LS2
            ls_wa_out-ls2_proc_ref = process_link-assoc_proc_ref.
          ENDIF.
        CATCH cx_sy_itab_line_not_found.
      ENDTRY.

      " Ausnahme / Klärungsfall
      CLEAR lt_bpem_cases_pr.
      lt_bpem_cases_pr = VALUE #( FOR lsbpem IN lt_bpem_cases_h WHERE ( mainobjkey = ls_wa_out-proc_ref ) ( lsbpem ) ).
      SORT lt_bpem_cases_pr BY created_date DESCENDING created_time DESCENDING.

      LOOP AT lt_bpem_cases_pr INTO DATA(ls_bpem_case).
        IF sy-tabix > 1.
          ls_wa_out-more_cases = 'X'.
          EXIT.
        ENDIF.
        ls_wa_out-casenr      = ls_bpem_case-casenr.
        ls_wa_out-case_status = ls_bpem_case-status.
        ls_wa_out-ccat        = ls_bpem_case-ccat.
        ls_wa_out-casetxt     = ls_bpem_case-casetxt.
        ls_wa_out-casetext2   = ls_bpem_case-zz_casetxt.
        ls_wa_out-prio        = ls_bpem_case-prio.
        ls_wa_out-priotxt = /adz/cl_inv_select_basic=>get_domain_text(
          EXPORTING  iv_domtabname = 'EMMA_CPRIO'     iv_value  = CONV #( ls_wa_out-prio ) ).

        CALL METHOD lo_emma_dbl->read_case_detail
          EXPORTING
            iv_case   = ls_bpem_case-casenr
          RECEIVING
            er_case   = lo_case
          EXCEPTIONS
            not_found = 1
            OTHERS    = 2.
        IF sy-subrc EQ 0.
          lo_case->get_objects( IMPORTING  et_objects = DATA(lt_emma_objs) ).
          TRY.
              ls_wa_out-exception_code = lt_emma_objs[ reffield = 'EXCEPTION_CODE' ]-id.
            CATCH cx_sy_itab_line_not_found.
          ENDTRY.
        ENDIF.
      ENDLOOP.

      " Anlage / Vertrag
*      SELECT a~int_ui, d~vertrag, a~anlage, c~tariftyp, c~ab, c~bis
*        INTO TABLE @DATA(lt_tariftyp)
*        FROM euiinstln AS a
*          INNER JOIN eanlh AS c
*            ON a~anlage = c~anlage
*            INNER JOIN ever AS d
*              ON  c~anlage = d~anlage
*              AND c~ab    <= d~auszdat
*              AND c~bis   >= d~einzdat
*        WHERE a~int_ui = @<ls_pdoc>-pod
*        AND   a~dateto   GE @sy-datum
*        AND   a~datefrom LE @sy-datum
*        AND   a~anlage = a~anlage
*        AND   a~anlage = c~anlage
*        AND   c~bis   GE @sy-datum
*        AND   c~ab    LE @sy-datum
*        AND   c~anlage = d~anlage
*        AND   c~ab    <= d~auszdat
*        AND   c~bis   >= d~einzdat.
      DATA(lv_anl_ctr) = 0.
      DATA(lb_service_ok) = abap_false.
      LOOP AT lt_anlage_h INTO DATA(ls_anlage) WHERE int_ui = <ls_pdoc>-pod.
        lv_anl_ctr = lv_anl_ctr + 1.
        lb_service_ok = xsdbool( ls_anlage-service = 'SLIF' OR ls_anlage-service = 'GLIF' ).
        IF lv_anl_ctr > 1 AND lb_service_ok EQ abap_false.
          CONTINUE. " Service immer noch unpassend, es bleibt beim ersten, sollte nicht vorkommen
        ENDIF.
        ls_wa_out-anlage  = ls_anlage-anlage.

        DATA(lv_vertrag_ctr) = 0.
        LOOP AT lt_vertrag_h ASSIGNING FIELD-SYMBOL(<ls_vertrag>) WHERE anlage = ls_anlage-anlage.
          lv_vertrag_ctr = lv_vertrag_ctr + 1.
          IF lv_vertrag_ctr > 1.
            CONTINUE.  " mehrere Vertraege ?
          ENDIF.
          ls_wa_out-vertrag = <ls_vertrag>-vertrag.
        ENDLOOP.
        IF lb_service_ok EQ abap_true.
          EXIT.  " service passt => raus
        ENDIF.
      ENDLOOP.

      " Storno setzen, wenn referenzierter Datensatz Status stornier hat
      IF ls_wa_out-ls2_proc_ref IS NOT INITIAL.
        get_storno_kz( CHANGING cs_wa_out = ls_wa_out  cs_post_sel = ls_post_sel ).
      ENDIF.

      " Ampel abhaengig vom Eingangsdatum setzen
      IF ( ls_wa_out-status EQ '01' OR ls_wa_out-status EQ '03' OR ls_wa_out-status EQ '12' ).
*01  OK
*02  Nein/Fehler
*03  Aktiv
*04  Storniert
*05  Obsolet
*06  Abgebrochen
*07  Warnung
*08  Unvollständig
*11  Workflow-Fehler
*12  Benutzeraktion erforderlich
*13  Anforderung abgelehnt
        ls_wa_out-lights = COND #(
           WHEN ls_wa_out-ls_termin   EQ  sy-datum THEN '3'
           WHEN ( ls_wa_out-ls_termin + 1 ) EQ  ( sy-datum + 0 ) THEN '2'
           ELSE '1' ).
      ELSE.
        ls_wa_out-lights = SWITCH #( ls_wa_out-status
          WHEN '04' OR '05' THEN '3'  " grün
          WHEN '07'         THEN '2'  " warnung
          ELSE                   '1'  " fehler
        ).
      ENDIF.

      INSERT ls_wa_out INTO TABLE mt_out_data.
    ENDLOOP.
    " Nochmal fehlende Pdocs für StornoKz nachselektieren
    IF ls_post_sel-so_swtnm IS NOT INITIAL.
      read_basic_data( is_sel_screen =  ls_post_sel ).
      LOOP AT mt_out_data ASSIGNING FIELD-SYMBOL(<ls_wa_out>)
      WHERE ls2_proc_ref IS NOT INITIAL AND storno_kz = ''.
        get_storno_kz( CHANGING cs_wa_out = <ls_wa_out>  ).
      ENDLOOP.
    ENDIF.
    IF is_sel_screen-p_intbel = 'X'.
      " Interne Belegnr
      DATA lt_rng_rff_ace TYPE RANGE OF /idexge/de_rff_ace.
      lt_rng_rff_ace = VALUE #( FOR ls IN mt_out_data WHERE ( ref_to_beleg IS NOT INITIAL ) ( sign = 'I'  option = 'EQ'  low = ls-ref_to_beleg ) ).
      CHECK lt_rng_rff_ace IS NOT INITIAL.
      DELETE ADJACENT DUPLICATES FROM lt_rng_rff_ace.
      " boeser Selekt (kein Index)
      SELECT /idexge/rff_ace, int_inv_doc_no FROM tinv_inv_doc  INTO TABLE @DATA(lt_inv_doc)
        WHERE /idexge/rff_ace IN @lt_rng_rff_ace.
      " Doppelverwendung der Referenznr möglich ?
      SORT lt_inv_doc BY /idexge/rff_ace.
      DELETE ADJACENT DUPLICATES FROM lt_inv_doc COMPARING /idexge/rff_ace.
      DATA ls_inv_doc LIKE LINE OF lt_inv_doc.
      DATA lt_inv_doc_h LIKE HASHED TABLE OF ls_inv_doc WITH UNIQUE KEY /idexge/rff_ace.
      INSERT LINES OF lt_inv_doc INTO TABLE lt_inv_doc_h.
      CLEAR lt_inv_doc.
      LOOP AT mt_out_data ASSIGNING <ls_wa_out>  WHERE ref_to_beleg IS NOT INITIAL.
        TRY.
            <ls_wa_out>-int_inv_doc_no = lt_inv_doc_h[ /idexge/rff_ace = <ls_wa_out>-ref_to_beleg ]-int_inv_doc_no.
          CATCH cx_sy_itab_line_not_found.
        ENDTRY.
      ENDLOOP.
    ELSE.
      LOOP AT mt_out_data ASSIGNING <ls_wa_out>  WHERE ref_to_beleg IS NOT INITIAL.
        <ls_wa_out>-int_inv_doc_no = 'select not enabled'.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD read_basic_data.
    DATA:
      it_eideswtnum  TYPE ieideswtnum,
      it_result_tab  TYPE teideswtdoc,
      it_result_tab2 TYPE teideswtdoc,
      lv_preselected TYPE kennzx,
      lv_auth_rc     TYPE sy-subrc,
      lv_index       TYPE sytabix,
**Start Incorporation in March, 2014************************************
      lt_pdoc_ref    TYPE /idxgc/t_proc_ref.

*    ls_sel_switch_doc      TYPE isu_ranges,
*    ls_dexbasicproc_data   TYPE edexbasicproc_db_data,
*    ls_dexproc_data        TYPE edexproc_db_data,
*    lt_edextask_data       TYPE iedextask_db_data.
**End Incorporation in March, 2014**************************************

    FIELD-SYMBOLS:
      <wa_sel_batch_switchdoc> TYPE isu_ranges,
      <ls_eideswtdoc>          TYPE eideswtdoc,
      <ls_eideswtdoc2>         TYPE eideswtdoc,
**Start Incorporation in March, 2014************************************
      <fs_pdoc_data>           TYPE /idxgc/s_pdoc_data.
*    <fs_edextask_data>       TYPE edextask_db_data,
*    <fs_edexbasicprocref>    TYPE edexbasicprocref,
*    <fs_iedextaskref>        TYPE edextaskref.
**End Incorporation in March, 2014**************************************
*--------------------------------------------------------------------*
* Write object into select options table
    CLEAR mt_pdoc_data.

    DATA(it_sel_switch_doc)  = CORRESPONDING iisu_ranges( is_sel_screen-so_swtnm ).
    DATA(it_sel_moveindate)  = CORRESPONDING iisu_ranges( is_sel_screen-so_movin ).
    DATA(it_sel_proc_id)     = CORRESPONDING iisu_ranges( is_sel_screen-so_prid ).
    DATA(lt_sel_int_ui)      = get_internal_pod( it_r_sel_ext_ui = is_sel_screen-so_extui ).
    DATA(it_sel_status)      = CORRESPONDING iisu_ranges( is_sel_screen-so_status ).

*    IF NOT it_sel_idoc IS INITIAL.
*
**   Get Process Documents for IDoc
*      TRY.
*          CALL METHOD /idxgc/cl_process_document_db=>/idxgc/if_process_document_db~select_pdoc_from_idoc
*            EXPORTING
*              it_sel_idoc    = it_sel_idoc
*              iv_max_records = x_maxrec
*            IMPORTING
*              et_pdoc_ref    = lt_pdoc_ref.
*        CATCH /idxgc/cx_process_error.
*          MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
*           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
*           DISPLAY LIKE 'E'.
*          RETURN. "Return if no Pdoc for IDoc found
*      ENDTRY.
*
*      TRY.
*          it_sel_switch_doc[] = /idxgc/cl_utility_service=>/idxgc/if_utility_service~build_range_table( lt_pdoc_ref ).
*        CATCH /idxgc/cx_utility_error.
*          MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
*           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
*           DISPLAY LIKE 'E'.
*      ENDTRY.
***End Incorporation in March, 2014**************************************
*    ENDIF.

*--------------------------------------------------------------------*
    TRY.
        DATA lv_process_view TYPE /idxgc/de_proc_view.
        DATA lv_division_cat TYPE spartyp.
        CALL METHOD /idxgc/cl_process_document_db=>/idxgc/if_process_document_db~select_pdoc_mass
          EXPORTING
            iv_process_view       = lv_process_view
            iv_division_cat       = lv_division_cat
            it_sel_process_id     = it_sel_proc_id[]
            it_sel_process_ref    = it_sel_switch_doc[]
            "it_sel_process_type   = it_sel_switch_type[]
            it_sel_process_date   = it_sel_moveindate[]
            it_sel_process_status = it_sel_status[]
            "it_sel_int_ui         = xt_sel_int_ui[]
            "it_sel_partner        = it_sel_partner[]
            "it_sel_create_date    = it_sel_create_date[]
            "it_sel_old_sup        = it_sel_supplier_old[]
            "it_sel_new_sup        = it_sel_supplier_new[]
            "it_sel_distributor    = it_sel_distributor[]
            "it_sel_source_scen    = it_sel_source_scen[]
            "it_sel_target_scen    = it_sel_target_scen[]
            iv_max_records        = 0
            "iv_assoc_processes    = x_assoc
            iv_message_data       = /idxgc/if_constants=>gc_false
**Start Incorporation in March, 2014************************************
            iv_buffer             = /idxgc/if_constants=>gc_true
**End Incorporation in March, 2014**************************************
          IMPORTING
            et_pdoc_data          = mt_pdoc_data
            et_proc_data          = mt_proc_data.

      CATCH /idxgc/cx_process_error. "occurs only if no Pdocs found
        "MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
        " WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
        " DISPLAY LIKE 'E'.
    ENDTRY.

    IF NOT mt_pdoc_data IS INITIAL.
      SORT mt_pdoc_data BY mandt switchnum.
      DELETE ADJACENT DUPLICATES FROM mt_pdoc_data COMPARING switchnum.
    ENDIF.
  ENDMETHOD.

  METHOD get_internal_pod.
    DATA   lt_euitrans         TYPE ieuitrans.

    IF NOT it_r_sel_ext_ui IS INITIAL.
      CALL FUNCTION 'ISU_DB_EUI_SELECT_IN_RANGE'
        EXPORTING
          x_maxcount  = 0
        TABLES
          xt_ext_ui   = it_r_sel_ext_ui
          yt_euitrans = lt_euitrans
        EXCEPTIONS
          OTHERS      = 1.
      IF sy-subrc NE 0.
*     Could not determine any internal POD(s). Set error flag
        rt_sel_int_ui = VALUE #( ( sign = 'I' option = 'EQ' low = 'NO_INTERNAL_POD_FOUND' ) ).
      ELSE.
        rt_sel_int_ui = VALUE #( FOR ls IN lt_euitrans ( sign = 'I' option = 'EQ' low = ls-int_ui ) ).
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD get_storno_kz.
    TRY.
        IF mt_pdoc_data[ switchnum = cs_wa_out-ls2_proc_ref ]-status EQ '04'.
          cs_wa_out-storno_kz = 'X'.
        ENDIF.
      CATCH cx_sy_itab_line_not_found.
        " referenzierter Datensaetze ist nicht bei Selektionsergebnis dabei => Nachselektion.
        IF cs_post_sel IS SUPPLIED.
          cs_post_sel-so_swtnm  = VALUE #( BASE cs_post_sel-so_swtnm ( sign = 'I'  option = 'EQ'  low = cs_wa_out-ls2_proc_ref  ) ).
          cs_post_sel-so_status = VALUE #( ( sign = 'I'  option = 'EQ'  low = '04'  ) ).
        ENDIF.
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
