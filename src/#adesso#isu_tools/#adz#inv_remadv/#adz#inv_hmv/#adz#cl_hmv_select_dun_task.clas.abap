CLASS /adz/cl_hmv_select_dun_task DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CONSTANTS  mco_belege  TYPE char3  VALUE  'BEL'.
    CONSTANTS  mco_msb     TYPE char3  VALUE  'MSB'.
    CONSTANTS  mco_memi    TYPE char3  VALUE  'MEM'.

    TYPES: BEGIN OF ty_fkkop,
             vkont           TYPE    fkkop-vkont,
             bukrs           TYPE    fkkop-bukrs,
             crsrf           TYPE    fkkop-int_crossrefno,
             crossrefno      TYPE    ecrossrefno-crossrefno,
             bcbln           TYPE    dfkkthi-bcbln,
             vtref           TYPE    fkkop-vtref,
             thinr           TYPE    dfkkthi-thinr,
             opbel           TYPE    fkkmaze_struc-opbel,
             opupw           TYPE    fkkmaze_struc-opupw,
             opupk           TYPE    fkkmaze_struc-opupk,
             opupz           TYPE    fkkmaze_struc-opupz,
             blart           TYPE    fkkop-blart,
             stakz           TYPE    fkkop-stakz,
             augst           TYPE    fkkop-augst,
             faedn           TYPE    dfkkthi-thidt,
             thprd           TYPE    dfkkthi-thprd,
             mansp           TYPE    fkkop-mansp,
             waers           TYPE    fkkop-waers,
             betrh           TYPE    fkkop-betrh,
             ikey            TYPE    fkkop-ikey,
             senid           TYPE    senid_kk,
             recid           TYPE    recid_kk,
             idocin          TYPE    /adz/hmv_idocin,
             statin          TYPE    /adz/hmv_statin,
             idocct          TYPE    /adz/hmv_idocct,
             statct          TYPE    /adz/hmv_statct,
             dexproc         TYPE    e_dexproc,
             dexidocsent     TYPE    e_dexidocsent,
             dexidocsentctrl TYPE    e_dexidocsent,
             dexidocsendcat  TYPE    e_dexidocsendcat,
             intui           TYPE    dfkkthi-intui,
             ext_ui          TYPE    ext_ui,
             thist           TYPE    dfkkthi-thist,
             hvorg           TYPE    fkkop-hvorg,
             tvorg           TYPE    fkkop-tvorg,
             spart           TYPE    fkkop-spart,
             gpart           TYPE    fkkop-gpart,
             xtaus           TYPE    fkkop-xtaus,
             xmanl           TYPE    fkkop-xmanl,
             keydate         TYPE    dfkkthi-keydate,
             status(30),
             akonto(30),
           END OF ty_fkkop.
    TYPES tty_fkkop TYPE TABLE OF ty_fkkop.

    TYPES: BEGIN OF ty_akonto,
             bukrs TYPE dfkkop-bukrs,
             gpart TYPE dfkkop-gpart,
             vkont TYPE dfkkop-vkont,
             vtref TYPE fkkop-vtref,
             opbel TYPE fkkmaze_struc-opbel,
             opupw TYPE fkkmaze_struc-opupw,
             opupk TYPE fkkmaze_struc-opupk,
             opupz TYPE fkkmaze_struc-opupz,
             blart TYPE fkkop-blart,
             stakz TYPE fkkop-stakz,
             augst TYPE fkkop-augst,
             faedn TYPE dfkkthi-thidt,
             mansp TYPE fkkop-mansp,
             waers TYPE fkkop-waers,
             betrh TYPE fkkop-betrh,
             hvorg TYPE fkkop-hvorg,
             tvorg TYPE fkkop-tvorg,
             spart TYPE fkkop-spart,
             xtaus TYPE fkkop-xtaus,
             xmanl TYPE fkkop-xmanl,
           END OF ty_akonto.
    TYPES tty_akonto TYPE TABLE OF ty_akonto.
    TYPES : BEGIN OF ty_opbelkey,
              opbel TYPE opbel_kk,
              opupw TYPE opupw_kk,
              opupk TYPE opupk_kk,
              opupz TYPE opupz_kk,
            END OF ty_opbelkey.

    TYPES : BEGIN OF ty_bcbln,
              opbel TYPE dfkkop-opbel,
              augst TYPE dfkkop-augst,
            END OF ty_bcbln.
    TYPES tty_bcbln TYPE SORTED TABLE OF ty_bcbln WITH NON-UNIQUE KEY opbel.

    TYPES: BEGIN OF ty_crsrf,
             int_crossrefno TYPE ecrossrefno-int_crossrefno,
             crossrefno     TYPE tinv_inv_line_a-own_invoice_no,
             int_ui         TYPE ecrossrefno-int_ui,
             crn_rev        TYPE ecrossrefno-crn_rev,
             ext_ui         TYPE euitrans-ext_ui,
             dateto         TYPE euitrans-dateto,
           END OF ty_crsrf.
    TYPES tty_crsrf TYPE TABLE OF ty_crsrf.
    TYPES: BEGIN OF ty_remadv,
             own_invoice_no TYPE ecrossrefno-crossrefno,
             invoice_type   TYPE tinv_inv_doc-invoice_type,
             int_inv_doc_no TYPE tinv_inv_line_a-int_inv_doc_no,
             invoice_status TYPE tinv_inv_head-invoice_status,
             int_receiver   TYPE tinv_inv_head-int_receiver,
             doc_type       TYPE tinv_inv_doc-doc_type,
             inv_doc_status TYPE tinv_inv_doc-inv_doc_status,
             rstgr          TYPE tinv_inv_line_a-rstgr,
           END OF ty_remadv.
    TYPES tty_remadv TYPE SORTED TABLE OF ty_remadv WITH NON-UNIQUE KEY own_invoice_no invoice_type.

    TYPES tty_fkkopchl TYPE TABLE OF fkkopchl.
    TYPES tty_tinv_inv_docref TYPE SORTED TABLE OF tinv_inv_docref WITH NON-UNIQUE KEY int_inv_doc_no.

    TYPES : BEGIN OF  ty_idoc_info,
              idocin TYPE /adz/hmv_idocin,
              statin TYPE /adz/hmv_statin,
              idocct TYPE /adz/hmv_idocct,
              statct TYPE /adz/hmv_statct,
            END OF  ty_idoc_info.


    "------------------------------------------------------------------------------------------
    METHODS:
      constructor
        IMPORTING
          is_constants TYPE          /adz/hmv_s_constants,

      main_bel
        IMPORTING
          is_out_vorlage TYPE /adz/hmv_s_out_dunning
          ib_akonto      TYPE checkbox
          ib_updte       TYPE checkbox
          ib_adunn       TYPE checkbox
          iv_lockr       TYPE mansp_old_kk
          iv_fdate       TYPE sydatum
          iv_tdate       TYPE sydatum
          it_so_augst    TYPE /adz/inv_rt_augst_kk
          it_so_mansp    TYPE /adz/inv_rt_mansp_old_kk
          it_so_mahns    TYPE /adz/inv_rt_mahns_kk
          it_select_bel  TYPE /adz/hmv_t_selct
        CHANGING
          et_out         TYPE /adz/hmv_t_out_dunning,

      main_msb
        IMPORTING
          is_out_vorlage TYPE /adz/hmv_s_out_dunning
          ib_akonto      TYPE checkbox
          ib_updte       TYPE checkbox
          ib_adunn       TYPE checkbox
          iv_lockr       TYPE mansp_old_kk
          iv_fdate       TYPE sydatum
          iv_tdate       TYPE sydatum
          it_so_augst    TYPE /adz/inv_rt_augst_kk
          it_so_mansp    TYPE /adz/inv_rt_mansp_old_kk
          it_so_mahns    TYPE /adz/inv_rt_mahns_kk
          it_select_msb  TYPE /adz/hmv_t_selct_msb
        CHANGING
          et_out         TYPE /adz/hmv_t_out_dunning,

      main_memi
        IMPORTING
          is_out_vorlage TYPE /adz/hmv_s_out_dunning
          ib_akonto      TYPE checkbox
          ib_updte       TYPE checkbox
          ib_adunn       TYPE checkbox
          iv_lockr       TYPE mansp_old_kk
          iv_fdate       TYPE sydatum
          iv_tdate       TYPE sydatum
          it_so_augst    TYPE /adz/inv_rt_augst_kk
          it_so_mansp    TYPE /adz/inv_rt_mansp_old_kk
          it_so_mahns    TYPE /adz/inv_rt_mahns_kk
          it_select_memi TYPE /adz/hmv_t_selct_memi
        CHANGING
          et_out         TYPE /adz/hmv_t_out_dunning
        .

  PROTECTED SECTION.
    METHODS:
      select_items
        IMPORTING
          it_selct    TYPE /adz/hmv_t_selct
          is_wa_out   TYPE /adz/hmv_s_out_dunning
          it_so_augst TYPE /adz/inv_rt_augst_kk
        EXPORTING
          ct_fkkop    TYPE tty_fkkop,

      select_items_msb
        IMPORTING
          it_selct_msb TYPE /adz/hmv_t_selct_msb
          is_wa_out    TYPE /adz/hmv_s_out_dunning
          it_so_augst  TYPE /adz/inv_rt_augst_kk
        EXPORTING
          ct_fkkop     TYPE tty_fkkop,

      select_memidoc
        IMPORTING
          it_select_memi TYPE /adz/hmv_t_selct_memi
          it_so_augst    TYPE /adz/inv_rt_augst_kk
        EXPORTING
          et_memidoc     TYPE /idxmm/t_memidoc
        ,
      select_akonto
        IMPORTING
          it_fkkop  TYPE tty_fkkop
        EXPORTING
          et_akonto TYPE tty_akonto,

      change_memidoc_status
        CHANGING cs_memidoc_help TYPE /idxmm/memidoc,

      select_crsrf
        IMPORTING
          it_rng_crossrefno TYPE /mosb/t_cross_ref_range
        CHANGING
          ct_crsrf          TYPE tty_crsrf,

      select_remadv
        IMPORTING
          it_crsrf  TYPE tty_crsrf
        CHANGING
          ct_remadv TYPE tty_remadv,

      select_inv_docref
        IMPORTING
          it_remadv     TYPE tty_remadv
        EXPORTING
          et_inv_docref TYPE tty_tinv_inv_docref,

      fill_remadv
        IMPORTING
          iv_int_receiver   TYPE inv_int_receiver
          iv_int_inv_doc_no TYPE inv_int_inv_doc_no
          irt_remadv        TYPE REF TO tty_remadv
          irt_inv_docref    TYPE REF TO tty_tinv_inv_docref
        CHANGING
          crs_wa_out        TYPE REF TO /adz/hmv_s_out_dunning,

      set_dunn_lock
        IMPORTING
                  is_fkkop    TYPE ty_fkkop
                  iv_lockr    TYPE checkbox
                  iv_fdate    TYPE sydatum
                  iv_tdate    TYPE sydatum
        CHANGING  crs_wet_out TYPE REF TO  /adz/hmv_s_out_dunning,

      set_dunn_lock_memi
        IMPORTING
                  iv_lockr    TYPE mansp_old_kk
                  iv_fdate    TYPE sydatum
                  iv_tdate    TYPE sydatum
        CHANGING  crs_wet_out TYPE REF TO  /adz/hmv_s_out_dunning,

      get_remadv_status
        IMPORTING
                 iv_invoice_type   type INV_INVOICE_TYPE
                 iv_invoice_status type INV_INVOICE_STATUS
        RETURNING VALUE(rv_status) type icon_d,

      get_mahnstufe
        IMPORTING
                  iv_proctype TYPE char3
                  is_fkkop    TYPE ty_fkkop
        CHANGING  crs_wet_out TYPE REF TO  /adz/hmv_s_out_dunning,

      get_interest
        IMPORTING is_fkkop    TYPE ty_fkkop
        CHANGING  crs_wet_out TYPE REF TO  /adz/hmv_s_out_dunning,

      get_locks
        IMPORTING
          iv_proctype TYPE char3
          is_fkkop    TYPE ty_fkkop
        CHANGING
          crs_wet_out TYPE REF TO  /adz/hmv_s_out_dunning,

      select_augst_bcbln
        IMPORTING
          it_selct TYPE /adz/hmv_t_selct
        CHANGING
          ct_bcbln TYPE  tty_bcbln,

      select_augst_msbdoc
        IMPORTING
          it_selct_msb TYPE /adz/hmv_t_selct_msb
        CHANGING
          ct_bcbln     TYPE  tty_bcbln,

      set_idoc_status
        IMPORTING
          iv_fdate     TYPE sydatum
          iv_tdate     TYPE sydatum
          iv_idoc_info TYPE ty_idoc_info
        CHANGING
          crs_wet_out  TYPE  REF TO /adz/hmv_s_out_dunning,

      vorschlag_mahnsperre
        CHANGING
          crs_wet_out TYPE  REF TO /adz/hmv_s_out_dunning
        .

  PRIVATE SECTION.
    DATA ms_constants      TYPE          /adz/hmv_s_constants.

ENDCLASS.



CLASS /ADZ/CL_HMV_SELECT_DUN_TASK IMPLEMENTATION.


  METHOD change_memidoc_status.
    DATA ls_memidoc_storno TYPE /idxmm/memidoc.
    DATA ls_memidoc_u      TYPE /idxmm/memidoc.
    DATA lt_memidoc_u      TYPE /idxmm/t_memi_doc.

    "* Prüfen: Ist der Memi-Beleg storniert?
    IF cs_memidoc_help-reversal = abap_true.
      SELECT SINGLE * FROM /idxmm/memidoc INTO ls_memidoc_storno
        WHERE doc_id = cs_memidoc_help-reversal_doc_id.
      IF sy-subrc = 0.
        IF ls_memidoc_storno-doc_status = '70'
        OR ls_memidoc_storno-doc_status = '75'
        OR ls_memidoc_storno-doc_status = '85'
        OR ls_memidoc_storno-doc_status = '86'.

*          DATA(lr_memidoc) = new /idxmm/cl_memi_document_db( ).
          ls_memidoc_u            = cs_memidoc_help.
          ls_memidoc_u-doc_status = '77'.
          APPEND ls_memidoc_u TO lt_memidoc_u.
          TRY.
              CALL METHOD /idxmm/cl_memi_document_db=>update
                EXPORTING
*                 iv_simulate   =
                  it_doc_update = lt_memidoc_u.
            CATCH /idxmm/cx_bo_error .
          ENDTRY.
          IF sy-subrc = 0.
            cs_memidoc_help-doc_status = ls_memidoc_u-doc_status.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD constructor.
    ms_constants = is_constants.
  ENDMETHOD.


  METHOD fill_remadv.
    "DATA(ls_int_receiver) = CONV inv_int_receiver( crs_wa_out->recid ).
    DATA(lv_spartyp) = /adz/cl_inv_select_basic=>get_divcat_for_doc( iv_int_receiver ).
    IF lv_spartyp = /idxgc/if_constants=>gc_divcat_elec. " Strom => Comdis und RemaDV2 und Lieferschein möglich
      TRY.
          IF iv_int_inv_doc_no IS NOT INITIAL.
            " mit einer doc_no in docref suchen
            DATA(lt_inv_docref) = VALUE ttinv_inv_docref( FOR ls IN irt_inv_docref->*
               WHERE ( int_inv_doc_no EQ iv_int_inv_doc_no ) ( ls  )  ).
          ELSE.
            RETURN.
*            iv_own_invoice_no TYPE crossrefno OPTIONAL
*            irt_remadv        TYPE REF TO tty_remadv OPTIONAL
*            " alle relevanten int_inv_doc_no aus remadv-Liste in range-typ verpacken
*            DATA lt_rng_int_inv_doc_no TYPE RANGE OF inv_int_inv_doc_no.
*            lt_rng_int_inv_doc_no = VALUE #( FOR rs IN irt_remadv->* WHERE ( own_invoice_no = iv_own_invoice_no )
*              ( sign = 'I'  option = 'EQ'   low = rs-int_inv_doc_no ) ) .
*
*            " relevante docref Eintraege bestimmen
*            lt_inv_docref = VALUE ttinv_inv_docref( FOR ls IN irt_inv_docref->*
*               WHERE ( int_inv_doc_no IN lt_rng_int_inv_doc_no ) ( ls  )  ).
          ENDIF.

          " Referenz auf Comdis suchen ueber alle relevanten docref Eintraege
          DATA(ls_docref) = lt_inv_docref[ inbound_ref_type = 92 inbound_ref_no = 1 ].
          crs_wa_out->comdis = ls_docref-inbound_ref.
          SHIFT crs_wa_out->comdis LEFT DELETING LEADING '0'. " fuehrende Nullen entfernen

          " zweite Reklamation suchen
          ls_docref = lt_inv_docref[  inbound_ref_type = 93 inbound_ref_no = 1 ].
          crs_wa_out->remadv2 = ls_docref-inbound_ref.
          /adz/cl_inv_select_basic=>get_reklamations_info(
             EXPORTING  iv_remadv  = crs_wa_out->remadv2
             IMPORTING  ev_remdate = crs_wa_out->remdate2
                        ev_rstgr   = crs_wa_out->rstgr2  ).
          ASSIGN irt_remadv->* TO FIELD-SYMBOL(<lt_remadv>).
          DATA(ls_remadv) = <lt_remadv>[ int_inv_doc_no = crs_wa_out->remadv2 ].
          crs_wa_out->statrem2  = get_remadv_status(
              iv_invoice_type   = ls_remadv-invoice_type
              iv_invoice_status = ls_remadv-inv_doc_status ).


        CATCH cx_sy_itab_line_not_found.
*          TRY.
*              IF crs_wa_out->comdis IS INITIAL.
*                " keine Comdis => wenn Referenz vorhanden, dann ist es die erste Reklamation
*                ls_docref = lt_inv_docref[  inbound_ref_type = 93 inbound_ref_no = 1 ].
*                crs_wa_out->remadv1 = ls_docref-inbound_ref.
*                /adz/cl_inv_select_basic=>get_reklamations_info(
*                   EXPORTING  iv_remadv  = crs_wa_out->remadv1
*                   IMPORTING  ev_remdate = crs_wa_out->remdate1
*                              ev_rstgr   = crs_wa_out->rstgr1  ).
*              ENDIF.
*            CATCH cx_sy_itab_line_not_found.
*          ENDTRY.
      ENDTRY.
    ENDIF.
  ENDMETHOD.


  METHOD get_interest .
    DATA: h_ibtrg TYPE ibtrg_kk.

    SELECT b~ibtrg  INTO h_ibtrg
      FROM dfkkih AS a
        INNER JOIN dfkkia AS b
        ON  b~iopbel = a~iopbel
        AND b~opbel  = a~opbel
        AND b~opupk  = a~opupk
        AND b~opupz  = a~opupz
        AND b~opupw  = a~opupw
      WHERE a~opbel  = is_fkkop-opbel
      AND   a~opupk  = is_fkkop-opupk
      AND   a~opupz  = is_fkkop-opupz
      AND   a~opupw  = is_fkkop-opupw
      AND   a~stokz  = space.

      crs_wet_out->ibtrg  = crs_wet_out->ibtrg + h_ibtrg.

    ENDSELECT.
  ENDMETHOD.


  METHOD get_locks.
    DATA: lv_t_dfkklocks TYPE STANDARD TABLE OF dfkklocks WITH DEFAULT KEY.

    IF iv_proctype EQ mco_belege.
      CALL FUNCTION 'FKK_S_LOCK_GET_FOR_DOC_ITEMS'
        EXPORTING
          i_opbel  = is_fkkop-opbel
          i_opupw  = is_fkkop-opupw
          i_opupk  = is_fkkop-opupk
          i_opupz  = is_fkkop-opupz
        TABLES
          et_locks = lv_t_dfkklocks.
    ELSE.
      CALL FUNCTION 'FKK_S_LOCK_GET_FOR_DOC_ITEMS'
        EXPORTING
          i_opbel  = is_fkkop-bcbln
          i_opupw  = '000'   "<t_fkkop_msb>-opupw
          i_opupk  = '0001'  "<t_fkkop_msb>-opupk
          i_opupz  = '000'  "<t_fkkop_msb>-opupz
        TABLES
          et_locks = lv_t_dfkklocks.
    ENDIF.

    LOOP AT lv_t_dfkklocks ASSIGNING FIELD-SYMBOL(<wa_dfkklocks>)
         WHERE lotyp = ms_constants-c_lotyp
         AND   proid = ms_constants-c_proid.

      crs_wet_out->fdate   = <wa_dfkklocks>-fdate.
      crs_wet_out->tdate   = <wa_dfkklocks>-tdate.
      crs_wet_out->mansp   = <wa_dfkklocks>-lockr.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_mahnstufe.
* Mahnstufe (nur "echte")
    DATA lv_key TYPE ty_opbelkey.
    IF iv_proctype EQ mco_belege.
      lv_key = CORRESPONDING #( is_fkkop ).
    ELSEIF iv_proctype EQ mco_msb.
      lv_key = VALUE #(
           opbel = is_fkkop-bcbln
           opupk = '0001'
           opupz = '0000'
           opupw = '000'  ).
    ENDIF.
    SELECT MAX( mahns ) FROM fkkmaze
     INTO crs_wet_out->mahns
           WHERE opbel = lv_key-opbel
           AND   opupk = lv_key-opupk
           AND   opupz = lv_key-opupz
           AND   opupw = lv_key-opupw
           AND   xmsto =  ' '
           AND   mdrkd NE '00000000'.
    IF sy-subrc NE 0.
      CLEAR crs_wet_out->mahns.
    ENDIF.

* Druckdatum 1. Mahnung
    SELECT SINGLE mdrkd FROM fkkmaze
      INTO crs_wet_out->mdrkd
           WHERE opbel = lv_key-opbel
           AND   opupk = lv_key-opupk
           AND   opupz = lv_key-opupz
           AND   opupw = lv_key-opupw
           AND   mahns = '01'
           AND   xmsto =  ' '.
    IF sy-subrc NE 0.
      CLEAR crs_wet_out->mdrkd.
    ENDIF.
  ENDMETHOD.


  METHOD get_remadv_status.
    IF iv_invoice_type EQ ms_constants-c_invoice_paym.              "'002'.
      rv_status = COND #(
        WHEN iv_invoice_status EQ ms_constants-c_invoice_paymst  "'13'.
            THEN icon_led_green        " Überführte Zahlungsavise --> grün
            ELSE icon_led_yellow ).    " sonstige Zahlungsavise   --> gelb

    ELSEIF iv_invoice_type   = ms_constants-c_invoice_type4.              "'004'.
      rv_status = COND #(
        WHEN iv_invoice_status = ms_constants-c_invoice_status_03
            THEN icon_led_yellow   "'03' - abgeschlossene Reklamation nur Warunung
            ELSE icon_led_red ).
    ENDIF.
  ENDMETHOD.


  METHOD main_bel.
    DATA:
      ls_wet_out    TYPE /adz/hmv_s_out_dunning,
      lt_selct      TYPE /adz/hmv_t_selct,
*      lt_selct_memi TYPE /adz/hmv_t_selct_memi,
*      lt_selct_msb  TYPE /adz/hmv_t_selct_msb,
      lt_inv_docref TYPE tty_tinv_inv_docref.
*      lt_memidoc         TYPE TABLE OF /idxmm/memidoc,
*      lt_idxmm_docstscfg TYPE TABLE OF /idxmm/docstscfg,
*      ls_idxmm_docstscfg TYPE /idxmm/docstscfg,
*      lt_idxmm_docst     TYPE /idxmm/docstscfg.
    DATA :
      lt_akonto TYPE tty_akonto,
      lt_remadv TYPE tty_remadv,
      lt_crsrf  TYPE tty_crsrf,
      lt_fkkop  TYPE tty_fkkop,
      wa_fkkop  TYPE ty_fkkop,
      lt_bcbln  TYPE tty_bcbln.

* Datenermittlung
    REFRESH et_out.
    select_items(
      EXPORTING  it_selct    = it_select_bel
                 is_wa_out   = is_out_vorlage
                 it_so_augst = it_so_augst
      IMPORTING  ct_fkkop    = lt_fkkop ).

    DATA(lt_rng_crossrefno) = VALUE /mosb/t_cross_ref_range( FOR ls IN lt_fkkop WHERE ( crsrf IS NOT INITIAL )
        ( sign = 'I' option = 'EQ' low = ls-crsrf ) ).

    select_crsrf(
      EXPORTING  it_rng_crossrefno = lt_rng_crossrefno
      CHANGING   ct_crsrf = lt_crsrf ).
    select_augst_bcbln(
      EXPORTING  it_selct = it_select_bel
      CHANGING   ct_bcbln = lt_bcbln ).
    select_remadv(
      EXPORTING  it_crsrf  = lt_crsrf
      CHANGING   ct_remadv = lt_remadv  ).
    select_inv_docref(
      EXPORTING  it_remadv     = lt_remadv
      IMPORTING  et_inv_docref = lt_inv_docref ).
*
    IF ib_akonto IS NOT INITIAL.
      select_akonto(
        EXPORTING     it_fkkop  = lt_fkkop
        IMPORTING     et_akonto = lt_akonto
      ).
      LOOP AT lt_akonto ASSIGNING FIELD-SYMBOL(<t_akonto>).
        CLEAR wa_fkkop.
        MOVE-CORRESPONDING <t_akonto> TO wa_fkkop.
        wa_fkkop-akonto = icon_businav_value_chain.
        wa_fkkop-status = icon_led_red.
        ls_wet_out         = is_out_vorlage.
        MOVE-CORRESPONDING wa_fkkop TO ls_wet_out.
        CHECK ls_wet_out-mansp IN it_so_mansp.
        CHECK ls_wet_out-mahns IN it_so_mahns.
        APPEND ls_wet_out TO et_out.
      ENDLOOP.
    ENDIF.

    DATA(lr_wet_out) = REF #( ls_wet_out ).
    "------------------------------------------------------------------------------------
    LOOP AT lt_fkkop ASSIGNING FIELD-SYMBOL(<ls_fkkop>).
      ls_wet_out = is_out_vorlage.
      MOVE-CORRESPONDING <ls_fkkop> TO ls_wet_out.

** Mahnsperren und Mahnhistorie lesen
      get_locks(
        EXPORTING iv_proctype = mco_belege
                  is_fkkop     = <ls_fkkop>
        CHANGING  crs_wet_out  = lr_wet_out
      ).
      get_mahnstufe(
        EXPORTING iv_proctype = mco_belege
                  is_fkkop     = <ls_fkkop>
        CHANGING  crs_wet_out = lr_wet_out
      ).

      CHECK ls_wet_out-mansp IN it_so_mansp.
      CHECK ls_wet_out-mahns IN it_so_mahns.

**Verzinsung lesen
      get_interest(
        EXPORTING  is_fkkop   = <ls_fkkop>
        CHANGING   crs_wet_out = lr_wet_out    ).

      " Ausgleichsstatus Aggr.Beleg
      TRY.
          DATA(ls_bcbln) = lt_bcbln[ opbel = ls_wet_out-bcbln ].
          ls_wet_out-bcaug      = ls_bcbln-augst.
          ls_wet_out-doc_status = ls_bcbln-augst.   "Felder Ausgl.St. und MEMI-Status zusammenführen
        CATCH cx_sy_itab_line_not_found.
      ENDTRY.

      IF <ls_fkkop>-akonto = ' '.                " Informationen lesen für Nicht-Akontobelege
        READ TABLE lt_crsrf ASSIGNING FIELD-SYMBOL(<ls_crsrf>)
          WITH KEY int_crossrefno = <ls_fkkop>-crsrf
          BINARY SEARCH.
        IF sy-subrc = 0 AND <ls_crsrf> IS ASSIGNED.
          ls_wet_out-ownrf  = <ls_crsrf>-crossrefno.
          ls_wet_out-ext_ui = <ls_crsrf>-ext_ui.
        ENDIF.

* Pos.REMADV ---------------------------------------------------*
        DATA lv_int_receiver TYPE inv_int_receiver.
        CLEAR lv_int_receiver.
        READ TABLE lt_remadv ASSIGNING FIELD-SYMBOL(<ls_remadv>)
          WITH KEY own_invoice_no = ls_wet_out-ownrf
                   invoice_type   = ms_constants-c_invoice_paym              "'002'.
           ."        BINARY SEARCH.
        IF sy-subrc = 0 AND <ls_remadv> IS ASSIGNED.
          lv_int_receiver = <ls_remadv>-int_receiver.
          ls_wet_out-payno      = <ls_remadv>-int_inv_doc_no.
          ls_wet_out-payst      = <ls_remadv>-inv_doc_status.
*        ls_wet_out-status     = icon_breakpoint.
*        ls_wet_out-sel        = 'X'.
          ls_wet_out-payst_icon = get_remadv_status(
              iv_invoice_type   = <ls_remadv>-invoice_type
              iv_invoice_status = <ls_remadv>-inv_doc_status ).
        ENDIF.
        UNASSIGN <ls_remadv>.

* Neg.REMADV ------------------------------------------------------*
        READ TABLE lt_remadv ASSIGNING <ls_remadv>
          WITH KEY own_invoice_no = ls_wet_out-ownrf
                   invoice_type   = ms_constants-c_invoice_type4              "'004'.
              ."     BINARY SEARCH.
        IF sy-subrc = 0 AND <ls_remadv> IS ASSIGNED.
          lv_int_receiver = <ls_remadv>-int_receiver.
          ls_wet_out-docno   = <ls_remadv>-int_inv_doc_no.
          ls_wet_out-rstgr   = <ls_remadv>-rstgr.
          ls_wet_out-statrem = get_remadv_status(
              iv_invoice_type   = <ls_remadv>-invoice_type
              iv_invoice_status = <ls_remadv>-inv_doc_status ).
          IF <ls_remadv>-invoice_status = ms_constants-c_invoice_status_03.
            ls_wet_out-to_lock = icon_led_yellow.
          ELSE.
*          ls_wet_out-status  = icon_breakpoint.
*          ls_wet_out-sel     = 'X'.
          ENDIF.
        ENDIF.
        "DATA lrt_inv_docref type ref to tty_tinv_inv_docref.
        IF ls_wet_out-docno IS NOT INITIAL.
          DATA(lrt_remadv)     = REF tty_remadv( lt_remadv ).
          DATA(lrt_inv_docref) = REF tty_tinv_inv_docref( lt_inv_docref ).
          fill_remadv(
            EXPORTING  "iv_own_invoice_no = ls_wet_out-ownrf
                       irt_remadv        = lrt_remadv
                       iv_int_receiver   = lv_int_receiver
                       iv_int_inv_doc_no = ls_wet_out-docno
                       irt_inv_docref    = lrt_inv_docref
            CHANGING   crs_wa_out        = lr_wet_out
          ).
        ENDIF.

        " IDOC-Status-Ermittlung
        SELECT SINGLE * FROM /adz/hmv_dfkk INTO @DATA(ls_hmv_dfkk)
          WHERE opbel = @<ls_fkkop>-opbel
          AND   opupw = @<ls_fkkop>-opupw
          AND   opupk = @<ls_fkkop>-opupk
          AND   opupz = @<ls_fkkop>-opupz
          AND   thinr = @<ls_fkkop>-thinr.

        ls_wet_out-dexidocsent     = ls_hmv_dfkk-dexidocsent.
        ls_wet_out-dexidocsentctrl = ls_hmv_dfkk-dexidocsentctrl.
        ls_wet_out-dexidocsendcat  = ls_hmv_dfkk-dexidocsendcat.
        ls_wet_out-dexproc         = ls_hmv_dfkk-dexproc.

        set_idoc_status(
          EXPORTING
            iv_fdate     = iv_fdate
            iv_tdate     = iv_tdate
            iv_idoc_info =  CORRESPONDING ty_idoc_info( ls_hmv_dfkk )
          CHANGING
            crs_wet_out = lr_wet_out ).


        " Ermittlung Mahnsperre setzen
        vorschlag_mahnsperre( CHANGING crs_wet_out = lr_wet_out ).

        IF ib_adunn IS NOT INITIAL. " Bei Selektion Akonto - alle Posten von Mahnung ausschließen
          READ TABLE lt_akonto TRANSPORTING NO FIELDS
                     WITH KEY bukrs = <ls_fkkop>-bukrs
                              gpart = <ls_fkkop>-gpart
                              vkont = <ls_fkkop>-vkont
                     BINARY SEARCH.
          IF sy-subrc = 0.
            ls_wet_out-akonto = icon_led_red.
            ls_wet_out-to_lock = icon_breakpoint.
            ls_wet_out-sel = 'X'.
          ENDIF.
        ENDIF.
      ENDIF.

      IF ls_wet_out-augst = '9'.           " Ausgeglichene Posten nicht zur Mahnung vorsehen
        CLEAR ls_wet_out-akonto.
        ls_wet_out-status = icon_led_green.
        ls_wet_out-sel  = ' '.
      ENDIF.

      IF ib_updte = 'X'.                " Mahnsperre setzen, wenn gewünscht
        set_dunn_lock(
          EXPORTING
            is_fkkop   = <ls_fkkop>
            iv_lockr   = iv_lockr
            iv_fdate   = iv_fdate
            iv_tdate   = iv_tdate
          CHANGING
            crs_wet_out = lr_wet_out ).
      ENDIF.
      APPEND ls_wet_out TO et_out.
    ENDLOOP.
  ENDMETHOD.


  METHOD main_memi.
    DATA ls_mloc          TYPE /adz/mem_mloc.
    DATA lt_mloc          TYPE TABLE OF /adz/mem_mloc.
*    FIELD-SYMBOLS:
*      <f_euitrans> TYPE euitrans,
*      <f_crsrf>    TYPE ecrossrefno.

    DATA :
      ls_wet_out TYPE /adz/hmv_s_out_dunning,
      lt_remadv  TYPE tty_remadv,
      lt_crsrf   TYPE tty_crsrf,
      lt_memidoc TYPE /idxmm/t_memidoc.

    REFRESH et_out.

    select_memidoc(
      EXPORTING  it_select_memi = it_select_memi
                 it_so_augst    = it_so_augst
      IMPORTING  et_memidoc     = lt_memidoc
    ).

    DATA(lt_rng_crossrefno) = VALUE /mosb/t_cross_ref_range( FOR ls IN lt_memidoc WHERE ( crossrefno IS NOT INITIAL )
      ( sign = 'I' option = 'EQ' low = ls-crossrefno ) ).

    select_crsrf(
      EXPORTING  it_rng_crossrefno = lt_rng_crossrefno
      CHANGING   ct_crsrf = lt_crsrf ).

    select_remadv(
      EXPORTING  it_crsrf  = lt_crsrf
      CHANGING   ct_remadv = lt_remadv  ).

    DATA(lr_wet_out) = REF #( ls_wet_out ).
    "------------------------------------------------------------------------------------
    LOOP AT lt_memidoc ASSIGNING FIELD-SYMBOL(<ls_memidoc>).
      ls_wet_out = is_out_vorlage.
      MOVE <ls_memidoc>-doc_id             TO ls_wet_out-opbel.
      MOVE <ls_memidoc>-company_code       TO ls_wet_out-bukrs.
      MOVE <ls_memidoc>-crossrefno         TO ls_wet_out-ownrf.
      MOVE <ls_memidoc>-int_pod            TO ls_wet_out-int_ui.
      MOVE <ls_memidoc>-dist_sp            TO ls_wet_out-senid.
      MOVE <ls_memidoc>-suppl_sp           TO ls_wet_out-recid.
      MOVE <ls_memidoc>-currency           TO ls_wet_out-waers.
      MOVE <ls_memidoc>-gross_amount       TO ls_wet_out-betrh.
      MOVE <ls_memidoc>-due_date           TO ls_wet_out-faedn.
      MOVE <ls_memidoc>-opupk              TO ls_wet_out-opupk.
      "  MOVE <ls_memidoc>-invoic_idoc        TO ls_wet_out-idocin.
      MOVE <ls_memidoc>-ci_fica_doc_no     TO ls_wet_out-bcbln.
      MOVE <ls_memidoc>-inv_send_date      TO ls_wet_out-thprd.
      MOVE <ls_memidoc>-doc_status         TO ls_wet_out-doc_status.
      MOVE <ls_memidoc>-suppl_bupa         TO ls_wet_out-gpart.
      MOVE <ls_memidoc>-suppl_contr_acct   TO ls_wet_out-aggvk.

      " Status für Stornierte MeMi-Belege mit Status 76 ändern
      IF <ls_memidoc>-doc_status = '76'.
        DATA(ls_memidoc_help) = <ls_memidoc>.
        change_memidoc_status( CHANGING cs_memidoc_help = ls_memidoc_help ).
        ls_memidoc_help-doc_status = <ls_memidoc>-doc_status.
        ls_wet_out-doc_status      = <ls_memidoc>-doc_status.
      ENDIF.

      " Mahnhistorie lesen ------------------------------------------------------------------*
*    IF c_idxmm_sp03_dunn IS NOT INITIAL.

*     Mahnstufe (nur "echte")
      SELECT MAX( mahns ) FROM /idxmm/dun_hist  "fkkmaze           "Nuss 01.02.2018
             INTO ls_wet_out-mahns
*             WHERE opbel = ls_wet_out-bcbln "ls_wet_out-opbel          "Nuss 02.02.2018
             WHERE doc_id = ls_wet_out-opbel "ls_wet_out-opbel          "Nuss 02.02.2018
             AND   opupk = ls_wet_out-opupk
             AND   xmsto =  ' '.
*             AND   mdrkd NE '00000000'.                          "Nuss 01.02.2018

      IF sy-subrc NE 0.
        CLEAR ls_wet_out-mahns.
      ENDIF.

*     Druckdatum 1. Mahnung
*        SELECT SINGLE mdrkd FROM fkkmaze
*               INTO ls_wet_out-mdrkd
*             WHERE opbel = ls_wet_out-bcbln "ls_wet_out-opbel
*               AND   opupk = ls_wet_out-opupk
**               AND   mahns = '01'
*               AND   xmsto =  ' '.
*        IF sy-subrc NE 0.
*          CLEAR ls_wet_out-mdrkd.
*        ENDIF.

**     Druckdatum 1. Mahnung
*        SELECT SINGLE mdrkd FROM fkkmaze
*               INTO ls_wet_out-mdrkd
*             WHERE opbel = ls_wet_out-bcbln "ls_wet_out-opbel
*               AND   opupk = ls_wet_out-opupk
**               AND   mahns = '01'
*               AND   xmsto =  ' '.
*        IF sy-subrc NE 0.
*          CLEAR ls_wet_out-mdrkd.
*        ENDIF.

*      SELECT MAX( mdrkd ) FROM fkkmaze
*        INTO ls_wet_out-mdrkd
*      WHERE opbel = ls_wet_out-bcbln
*        AND opupk = ls_wet_out-opupk
*        AND   xmsto =  ' '.


*    ELSE.

**     Mahnstufe (nur "echte")
*      SELECT MAX( mahns ) FROM fkkmaze
*             INTO ls_wet_out-mahns
*             WHERE opbel = ls_wet_out-opbel
*             AND   xmsto =  ' '
*             AND   mdrkd NE '00000000'.
*      IF sy-subrc NE 0.
*        CLEAR ls_wet_out-mahns.
*      ENDIF.
*
**     Druckdatum 1. Mahnung
*      SELECT SINGLE mdrkd FROM fkkmaze
*             INTO ls_wet_out-mdrkd
*           WHERE opbel = ls_wet_out-opbel
*             AND   mahns = '01'
*             AND   xmsto =  ' '.
*      IF sy-subrc NE 0.
*        CLEAR ls_wet_out-mdrkd.
*      ENDIF.

* Mahnsperren lesen --------------------------------------------------------------------*
      CLEAR ls_mloc.

**     --> Nuss 02.02.2018
*      SELECT SINGLE * FROM /ADZ/hmv_mloc INTO ls_mloc
*        WHERE doc_id = ls_wet_out-opbel
*        AND fdate <= sy-datum AND tdate >= sy-datum
*        AND lvorm = ''.

      SELECT * FROM /adz/mem_mloc
        INTO TABLE lt_mloc
        WHERE doc_id = ls_wet_out-opbel
        AND tdate GE sy-datum
        AND lvorm = ''.

      IF sy-subrc = 0.
        SORT lt_mloc BY tdate ASCENDING.
        READ TABLE lt_mloc INTO ls_mloc INDEX 1.

        IF sy-subrc = 0.
          IF sy-datum BETWEEN ls_mloc-fdate AND ls_mloc-tdate.
            ls_wet_out-status = icon_locked.
          ELSE.
            ls_wet_out-status = icon_led_yellow.
          ENDIF.
          ls_wet_out-fdate = ls_mloc-fdate.
          ls_wet_out-tdate = ls_mloc-tdate.
          ls_wet_out-mansp = ls_mloc-lockr.

          CHECK ls_wet_out-mansp IN it_so_mansp.
        ENDIF.
      ENDIF.

      CHECK ls_wet_out-mahns IN it_so_mahns.

*-------------------- Pos. REMADV --------------------*
      READ TABLE lt_remadv ASSIGNING FIELD-SYMBOL(<ls_remadv>)
      WITH KEY own_invoice_no = ls_wet_out-ownrf
                 invoice_type = ms_constants-c_invoice_type7         "'007'.
           ."    BINARY SEARCH.
      IF sy-subrc = 0 AND <ls_remadv> IS ASSIGNED.
        ls_wet_out-payno = <ls_remadv>-int_inv_doc_no.
        ls_wet_out-payst = <ls_remadv>-inv_doc_status.
        IF <ls_remadv>-inv_doc_status = ms_constants-c_invoice_paymst.  "'13'.
          ls_wet_out-payst_icon = icon_led_green.            "überführte Avise - Status grün
        ELSE.
          ls_wet_out-payst_icon = icon_led_yellow.           "offene Avise - Status gelb
        ENDIF.
      ENDIF.
      UNASSIGN <ls_remadv>.


*-------------------- Neg. REMADV --------------------*
*    SORT t_remadv by int_inv_doc_no DESCENDING.
      READ TABLE lt_remadv ASSIGNING <ls_remadv>
        WITH KEY own_invoice_no = ls_wet_out-ownrf
                   invoice_type = ms_constants-c_invoice_type8
        ."       BINARY SEARCH.
      IF sy-subrc = 0 AND <ls_remadv> IS ASSIGNED.
        IF <ls_remadv>-invoice_status = ms_constants-c_invoice_status_03.  "03 - beeendete Reklamation - Warnung
          ls_wet_out-docno    = <ls_remadv>-int_inv_doc_no.
          ls_wet_out-rstgr    = <ls_remadv>-rstgr.
          ls_wet_out-statrem  = icon_led_yellow.
          ls_wet_out-to_lock   = icon_led_yellow.
        ELSE.
          ls_wet_out-docno    = <ls_remadv>-int_inv_doc_no.      " offene Reklamation - Fehler
          ls_wet_out-rstgr    = <ls_remadv>-rstgr.
          ls_wet_out-statrem  = icon_led_red.
        ENDIF.
      ENDIF.

      " Transform int_ui to ext_ui ------------------------------------------------*
      READ TABLE lt_crsrf ASSIGNING FIELD-SYMBOL(<ls_crsrf>)
        WITH KEY int_ui = <ls_memidoc>-int_pod.
      IF sy-subrc = 0 AND <ls_crsrf> IS ASSIGNED.
        MOVE <ls_crsrf>-ext_ui TO ls_wet_out-ext_ui.
      ELSE.
        SELECT SINGLE ext_ui FROM euitrans WHERE int_ui = @<ls_memidoc>-int_pod INTO @ls_wet_out-ext_ui.
      ENDIF.

      " IDOC-Status-Ermittlung----------------------------------------------------------------*
      SELECT SINGLE * FROM /adz/hmv_memi INTO @DATA(ls_hmv_memi) WHERE doc_id = @<ls_memidoc>-doc_id.
        MOVE ls_hmv_memi-dexidocsent     TO ls_wet_out-dexidocsent.
        MOVE ls_hmv_memi-dexidocsentctrl TO ls_wet_out-dexidocsentctrl.
        MOVE ls_hmv_memi-dexidocsendcat  TO ls_wet_out-dexidocsendcat.
        MOVE ls_hmv_memi-dexproc         TO ls_wet_out-dexproc.

        set_idoc_status(
            EXPORTING
              iv_fdate     = iv_fdate
              iv_tdate     = iv_tdate
              iv_idoc_info =  CORRESPONDING ty_idoc_info( ls_hmv_memi )
            CHANGING
              crs_wet_out = lr_wet_out ).

        " Ermittlung Mahnsperre setzen
        vorschlag_mahnsperre( CHANGING crs_wet_out = lr_wet_out ).

        IF ib_updte = 'X'.                            " Mahnsperren setzen, wenn gewünscht
          set_dunn_lock_memi(
            EXPORTING
              iv_lockr    = iv_lockr
              iv_fdate    = iv_fdate
              iv_tdate    = iv_tdate
            CHANGING
              crs_wet_out = lr_wet_out
          ).
        ENDIF.
        APPEND ls_wet_out TO et_out.
      ENDLOOP.
    ENDMETHOD.


  METHOD main_msb.
    DATA :
      ls_wet_out TYPE /adz/hmv_s_out_dunning,
      lt_remadv  TYPE tty_remadv,
      lt_crsrf   TYPE tty_crsrf,
      lt_fkkop   TYPE tty_fkkop,
      wa_fkkop   TYPE ty_fkkop,
      lt_bcbln   TYPE tty_bcbln.

    REFRESH et_out.

    select_items_msb(
      EXPORTING  it_selct_msb = it_select_msb
                 is_wa_out    = is_out_vorlage
                 it_so_augst  = it_so_augst
      IMPORTING  ct_fkkop     = lt_fkkop ).

    DATA(lt_rng_crossrefno) = VALUE /mosb/t_cross_ref_range( FOR ls IN lt_fkkop WHERE ( crossrefno IS NOT INITIAL )
      ( sign = 'I' option = 'EQ' low = ls-crossrefno ) ).
    select_crsrf(
      EXPORTING  it_rng_crossrefno = lt_rng_crossrefno
      CHANGING   ct_crsrf = lt_crsrf ).

    select_augst_msbdoc(
      EXPORTING  it_selct_msb = it_select_msb
      CHANGING   ct_bcbln = lt_bcbln ).

    select_remadv(
      EXPORTING  it_crsrf  = lt_crsrf
      CHANGING   ct_remadv = lt_remadv  ).

    DATA(lr_wet_out) = REF #( ls_wet_out ).
    "------------------------------------------------------------------------------------
    LOOP AT lt_fkkop ASSIGNING FIELD-SYMBOL(<ls_fkkop>).
      ls_wet_out = is_out_vorlage.

      MOVE-CORRESPONDING <ls_fkkop> TO ls_wet_out.
      ls_wet_out-ownrf  = <ls_fkkop>-crossrefno.
      ls_wet_out-int_ui = <ls_fkkop>-intui.

      " Mahnsperren und Mahnhistorie lesen
      get_locks(
        EXPORTING iv_proctype = mco_belege
                  is_fkkop     = <ls_fkkop>
        CHANGING  crs_wet_out  = lr_wet_out ).

      get_mahnstufe(
        EXPORTING iv_proctype = mco_belege
                  is_fkkop     = <ls_fkkop>
        CHANGING  crs_wet_out  = lr_wet_out ).

      CHECK ls_wet_out-mansp IN it_so_mansp.
      CHECK ls_wet_out-mahns IN it_so_mahns.

      " Ausgleichsstatus Aggr.Beleg
      TRY.
          DATA(ls_bcbln) = lt_bcbln[ opbel = ls_wet_out-bcbln ].
          ls_wet_out-bcaug      = ls_bcbln-augst.
          ls_wet_out-doc_status = ls_bcbln-augst.   "Felder Ausgl.St. und MEMI-Status zusammenführen
        CATCH cx_sy_itab_line_not_found.
      ENDTRY.


      "-------------------- Pos. REMADV --------------------*
      READ TABLE lt_remadv ASSIGNING FIELD-SYMBOL(<ls_remadv>)
      WITH KEY own_invoice_no = ls_wet_out-ownrf
                 invoice_type = ms_constants-c_invoice_type12         "'012'.
           ."    BINARY SEARCH.
      IF sy-subrc = 0 AND <ls_remadv> IS ASSIGNED.
        ls_wet_out-payno = <ls_remadv>-int_inv_doc_no.
        ls_wet_out-payst = <ls_remadv>-inv_doc_status.
        IF <ls_remadv>-inv_doc_status = ms_constants-c_invoice_paymst.  "'13'.
          ls_wet_out-payst_icon = icon_led_green.            "überführte Avise - Status grün
        ELSE.
          ls_wet_out-payst_icon = icon_led_yellow.           "offene Avise - Status gelb
        ENDIF.
      ENDIF.
      UNASSIGN <ls_remadv>.

      "-------------------- Neg. REMADV --------------------*
*    SORT lt_remadv by int_inv_doc_no DESCENDING.
      READ TABLE lt_remadv ASSIGNING <ls_remadv>
        WITH KEY own_invoice_no = ls_wet_out-ownrf
                   invoice_type = ms_constants-c_invoice_type13
        ."       BINARY SEARCH.
      IF sy-subrc = 0 AND <ls_remadv> IS ASSIGNED.
        IF <ls_remadv>-invoice_status = ms_constants-c_invoice_status_03.  "03 - beeendete Reklamation - Warnung
          ls_wet_out-docno    = <ls_remadv>-int_inv_doc_no.
          ls_wet_out-rstgr    = <ls_remadv>-rstgr.
          ls_wet_out-statrem  = icon_led_yellow.
          ls_wet_out-to_lock   = icon_led_yellow.
        ELSE.
          ls_wet_out-docno    = <ls_remadv>-int_inv_doc_no.      " offene Reklamation - Fehler
          ls_wet_out-rstgr    = <ls_remadv>-rstgr.
          ls_wet_out-statrem  = icon_led_red.
        ENDIF.
      ENDIF.


      " IDOC-Status-Ermittlung
      SELECT SINGLE * FROM /adz/hmv_mosb INTO @DATA(ls_hmv_msb)  WHERE invdocno = @<ls_fkkop>-opbel.
      MOVE ls_hmv_msb-dexidocsent     TO ls_wet_out-dexidocsent.
      MOVE ls_hmv_msb-dexidocsentctrl TO ls_wet_out-dexidocsentctrl.
      MOVE ls_hmv_msb-dexidocsendcat  TO ls_wet_out-dexidocsendcat.
      MOVE ls_hmv_msb-dexproc         TO ls_wet_out-dexproc.

      " Ermittlung Status INVOIC
      set_idoc_status(
        EXPORTING
          iv_fdate     = iv_fdate
          iv_tdate     = iv_tdate
          iv_idoc_info = CORRESPONDING ty_idoc_info( ls_hmv_msb )
        CHANGING
          crs_wet_out = lr_wet_out ).

      vorschlag_mahnsperre( CHANGING crs_wet_out = lr_wet_out ).

      APPEND ls_wet_out TO et_out.
    ENDLOOP.
  ENDMETHOD.


  METHOD select_akonto.
    DATA: lv_hvorg          TYPE hvorg_kk,
          lt_r_hvorg_akonto LIKE RANGE OF lv_hvorg,
          lt_akto           TYPE TABLE OF /adz/hmv_akto,
          ls_akto           TYPE /adz/hmv_akto.

    CLEAR et_akonto.
    SELECT * FROM /adz/hmv_akto INTO TABLE lt_akto.
    lt_r_hvorg_akonto = VALUE #( FOR ls IN lt_akto WHERE ( aktiv = 'X' ) ( sign = 'I'  option = 'EQ' low = ls-hvorg ) ).
    CHECK lt_r_hvorg_akonto[] IS NOT INITIAL.


    CHECK NOT it_fkkop[] IS INITIAL.
    SELECT * FROM dfkkop
      INTO CORRESPONDING FIELDS OF TABLE et_akonto
        FOR ALL ENTRIES IN it_fkkop
        WHERE augst = ' '
          AND   vkont = it_fkkop-vkont
          AND   bukrs = it_fkkop-bukrs
          AND   gpart = it_fkkop-gpart
*         AND   hvorg = c_hvorg_akonto.
          AND  hvorg IN lt_r_hvorg_akonto.
    SORT et_akonto.
    DELETE ADJACENT DUPLICATES FROM et_akonto.
  ENDMETHOD.


  METHOD select_augst_bcbln .
    IF NOT it_selct[] IS INITIAL.
      SELECT opbel augst
        INTO CORRESPONDING FIELDS OF TABLE ct_bcbln
        FROM dfkkop
        FOR ALL ENTRIES IN it_selct
        WHERE opbel = it_selct-bcbln
          AND opupz = '000'.
    ENDIF.
  ENDMETHOD.


  METHOD select_augst_msbdoc .
    IF NOT it_selct_msb[] IS INITIAL.
      SELECT opbel augst
        INTO CORRESPONDING FIELDS OF TABLE ct_bcbln
        FROM dfkkop
        FOR ALL ENTRIES IN it_selct_msb
        WHERE opbel = it_selct_msb-opbel
          AND opupz = '000'.
    ENDIF.
  ENDMETHOD.


  METHOD select_crsrf .
    REFRESH ct_crsrf.
    IF NOT it_rng_crossrefno[] IS INITIAL.
      SELECT a~int_crossrefno
             ,a~int_ui
             ,a~crossrefno
             ,a~crn_rev
             ,b~ext_ui
             ,b~dateto
        INTO CORRESPONDING FIELDS OF TABLE @ct_crsrf
          FROM ecrossrefno AS a
        LEFT OUTER JOIN euitrans AS b
          ON b~int_ui = a~int_ui
        WHERE a~int_crossrefno IN @it_rng_crossrefno
         AND dateto EQ '99991231'.

      DELETE ADJACENT DUPLICATES FROM ct_crsrf.
    ENDIF.
    SORT ct_crsrf BY crossrefno.
  ENDMETHOD.                    " SELECT_CRSRF


  METHOD select_inv_docref.
    SELECT * FROM tinv_inv_docref AS d INTO TABLE et_inv_docref
    FOR ALL ENTRIES IN it_remadv
    WHERE d~int_inv_doc_no = it_remadv-int_inv_doc_no
      AND ( inbound_ref_type = 92 OR inbound_ref_type = 93 )
      AND inbound_ref_no = 1.
  ENDMETHOD.


  METHOD select_items.
    SELECT b~mandt b~opbel b~opupw b~opupk b~opupz b~bukrs
           b~blart b~vkont b~vtref b~gpart b~waers b~mansp
           b~xmanl b~betrh b~tvorg b~hvorg b~betrw b~stakz
           b~spart b~xtaus b~augst
           b~ikey  b~int_crossrefno AS crsrf
           a~bcbln a~thinr a~thist a~thidt  AS faedn
           a~intui a~thprd a~keydate
           a~senid a~recid
*         a~idocin a~statin a~idocct a~statct
*         a~dexproc a~dexidocsent a~dexidocsentctrl
*         a~dexidocsendcat
           INTO CORRESPONDING FIELDS OF TABLE ct_fkkop
           FROM dfkkthi AS a
           INNER JOIN dfkkop AS b
                   ON b~opbel = a~opbel AND
                      b~opupw = a~opupw AND
                      b~opupk = a~opupk
           FOR ALL ENTRIES IN it_selct
           WHERE a~bcbln = it_selct-bcbln
             AND a~opbel = it_selct-opbel
             AND a~opupw = it_selct-opupw
             AND a~opupk = it_selct-opupk
             AND a~recid = is_wa_out-recid
             AND a~senid = is_wa_out-senid
             AND a~burel = 'X'
             AND a~storn = space
             AND a~stidc = space
             AND a~thist NE space
             AND b~augst IN it_so_augst
             AND b~augrs EQ space
             AND a~thinr = ( SELECT MAX( thinr ) FROM dfkkthi
                                    WHERE opbel = b~opbel
                                    AND   opupw = b~opupw
                                    AND   opupk = b~opupk )
             AND ( a~v_group = is_wa_out-v_group OR a~v_group IS NULL ).
  ENDMETHOD.


  METHOD select_items_msb.
    SELECT b~mandt b~opbel AS bcbln b~opupw b~opupk b~opupz b~bukrs
           b~blart b~vkont b~vtref b~gpart b~waers b~mansp
           b~xmanl b~betrh b~tvorg b~hvorg b~betrw b~stakz
           b~spart b~xtaus b~augst
           b~ikey  b~int_crossrefno AS crsrf
           a~invdocno AS opbel
           a~faedn
           c~crdate AS thprd
           c~/mosb/ld_malo_i AS intui
           c~/mosb/ld_malo_e AS ext_ui
           c~/mosb/inv_doc_ident AS crossrefno
           c~/mosb/lead_sup AS recid
           c~/mosb/mo_sp AS senid
*         a~bcbln a~thinr a~thist a~thidt  AS faedn
*         a~intui a~thprd a~keydate

       INTO CORRESPONDING FIELDS OF TABLE ct_fkkop
       FROM dfkkinvdoc_i AS a
         INNER JOIN dfkkop AS b
                   ON b~opbel = a~opbel "AND
*                    b~opupw = a~opupw AND
*                    b~opupk = a~opupk
         INNER JOIN dfkkinvdoc_h AS c
                 ON c~invdocno = a~invdocno
           FOR ALL ENTRIES IN it_selct_msb
*         WHERE a~bcbln = t_selct_msb-bcbln
           WHERE a~opbel = it_selct_msb-opbel
**           AND a~opupw = t_selct-opupw
**           AND a~opupk = t_selct-opupk
*           AND a~recid = wa_out-recid
*           AND a~senid = wa_out-senid
*           AND a~burel = 'X'
*           AND a~storn = space
*           AND a~stidc = space
*           AND a~thist NE space
             AND b~augst IN it_so_augst
             AND b~augrs EQ space.
*           AND a~thinr = ( SELECT MAX( thinr ) FROM dfkkthi
*                                  WHERE opbel = b~opbel
*                                  AND   opupw = b~opupw
*                                  AND   opupk = b~opupk )
*           AND ( a~v_group = wa_out-v_group OR a~v_group IS NULL ).

    SORT ct_fkkop.
    DELETE ADJACENT DUPLICATES FROM ct_fkkop COMPARING ALL FIELDS.

  ENDMETHOD.


  METHOD select_memidoc.
    DATA: ls_doc_status_range TYPE /idxmm/s_doc_status_range,
          lt_doc_status_range TYPE /idxmm/t_doc_status_range,
          ls_docstatus        TYPE /idxmm/docstatus.


    IF it_so_augst[] IS NOT INITIAL.
      DATA(lrt_docstatus) = /adz/cl_inv_select_basic=>get_docstatus( ).

      LOOP AT it_so_augst INTO DATA(ls_so_augst).
        IF ls_so_augst-low = 9.
          " Ausgeglichene MeMi-Belege berücksichtigen, wenn Ausgleichsstatus 9 selektiert
          lt_doc_status_range = VALUE #( FOR ls IN lrt_docstatus->*
            WHERE ( doc_status GE '80' OR doc_status EQ '65' OR doc_status EQ ms_constants-c_memidoc_dnlcrsn )
            ( sign = 'I'  option = 'EQ'  low = ls-doc_status ) ).
        ELSE.
          " nicht ausgeglichene MeMi-Belege berücksichtigen
          lt_doc_status_range = VALUE #( FOR ls IN lrt_docstatus->*
            WHERE ( doc_status LT '80' AND doc_status NE '65' OR doc_status EQ ms_constants-c_memidoc_dnlcrsn )
           ( sign = 'I'  option = 'EQ'  low = ls-doc_status ) ).
        ENDIF.
      ENDLOOP.

    ENDIF.

    IF NOT it_select_memi[] IS INITIAL.
      SELECT *  INTO TABLE et_memidoc
        FROM /idxmm/memidoc
        FOR ALL ENTRIES IN it_select_memi
        WHERE ci_fica_doc_no = it_select_memi-ci_fica_doc_no
          AND opupk          = it_select_memi-opupk
          AND doc_id         = it_select_memi-doc_id
          AND doc_status     IN lt_doc_status_range.
    ENDIF.
  ENDMETHOD.


  METHOD select_remadv .
* find REMADVs
    REFRESH ct_remadv.
* New Version with Index TINV_INV_LINE_A OWN_INVOIVE_NO
    IF NOT it_crsrf[] IS INITIAL.
      DATA(lt_rng_crossrefno) = VALUE /adz/inv_rt_own_invoice_no(
         FOR ls IN it_crsrf ( sign = 'I'  option = 'EQ'  low = ls-crossrefno )  ).
      SORT lt_rng_crossrefno.
      DELETE ADJACENT DUPLICATES FROM lt_rng_crossrefno.

      SELECT h~invoice_type h~invoice_status h~int_receiver
             d~int_inv_doc_no d~doc_type d~inv_doc_status
             l~own_invoice_no l~rstgr
             INTO CORRESPONDING FIELDS OF TABLE ct_remadv
             FROM tinv_inv_line_a AS l
                  INNER JOIN tinv_inv_doc AS d
                  ON d~int_inv_doc_no = l~int_inv_doc_no
                  INNER JOIN tinv_inv_head AS h
                  ON h~int_inv_no = d~int_inv_no
             WHERE l~own_invoice_no IN lt_rng_crossrefno.
    ENDIF.
  ENDMETHOD.


  METHOD set_dunn_lock.
*  check wa_out-status = icon_breakpoint.
    CHECK crs_wet_out->sel = 'X'.

    DATA lt_fkkopchl TYPE tty_fkkopchl.

    lt_fkkopchl = VALUE #( (
       lockaktyp = ms_constants-c_lockaktyp
       opupk     = is_fkkop-opupk
       opupw     = is_fkkop-opupw
       opupz     = is_fkkop-opupz
       proid     = ms_constants-c_proid
       lockr     = iv_lockr
       fdate     = iv_fdate
       tdate     = iv_tdate
       lotyp     = ms_constants-c_lotyp
       gpart     = is_fkkop-gpart
       vkont     = is_fkkop-vkont
    ) ).

    CALL FUNCTION 'FKK_DOCUMENT_CHANGE_LOCKS'
      EXPORTING
        i_opbel           = is_fkkop-opbel
      TABLES
        t_fkkopchl        = lt_fkkopchl
      EXCEPTIONS
        err_document_read = 1
        err_create_line   = 2
        err_lock_reason   = 3
        err_lock_date     = 4
        OTHERS            = 5.

    IF sy-subrc <> 0.
      crs_wet_out->status = icon_breakpoint.
    ELSE.
      crs_wet_out->mansp  = iv_lockr.
      crs_wet_out->fdate  = iv_fdate.
      crs_wet_out->tdate  = iv_tdate.
      crs_wet_out->status = icon_locked.
    ENDIF.
** Sperren der OPBELS wieder aufheben
    CALL FUNCTION 'FKK_DEQ_OPBELS_AFTER_CHANGES'
      EXPORTING
        _scope          = '3'
        i_only_document = ' '.
  ENDMETHOD.


  METHOD set_dunn_lock_memi.
    DATA ls_mloc TYPE /adz/mem_mloc.
    DATA ls_memidoc_u TYPE /idxmm/memidoc.
    DATA lt_memidoc_u TYPE /idxmm/t_memi_doc.

    CHECK crs_wet_out->sel = 'X'.

    IF ms_constants-c_idxmm_sp03_dunn IS INITIAL.
      ls_mloc-doc_id    = crs_wet_out->opbel.
      ls_mloc-lockr     = iv_lockr.
      ls_mloc-fdate     = iv_fdate.
      ls_mloc-tdate     = iv_tdate.
      GET  TIME STAMP FIELD ls_mloc-timestamp.
      ls_mloc-crnam     = sy-uname.
      ls_mloc-azeit     = sy-timlo.
      ls_mloc-adatum    = sy-datum.

      INSERT INTO /adz/mem_mloc VALUES ls_mloc.
      IF sy-subrc <> 0.
        crs_wet_out->status = icon_breakpoint.
      ELSE.
        crs_wet_out->mansp  = iv_lockr.
        crs_wet_out->fdate  = iv_fdate.
        crs_wet_out->tdate  = iv_tdate.
        crs_wet_out->status = icon_locked.
      ENDIF.
** Sperren der DOC_IDs wieder aufheben
*  CALL FUNCTION 'FKK_DEQ_OPBELS_AFTER_CHANGES'
*    EXPORTING
*      _scope          = '3'
*      i_only_document = ' '.
    ELSE.
      SELECT SINGLE * FROM /idxmm/memidoc INTO ls_memidoc_u WHERE doc_id = crs_wet_out->opbel.

      ls_memidoc_u-doc_status = ms_constants-c_memidoc_dnlcrsn.
      APPEND ls_memidoc_u TO lt_memidoc_u.
*  TRY.
      CALL METHOD /idxmm/cl_memi_document_db=>update
        EXPORTING
*         iv_simulate   =
          it_doc_update = lt_memidoc_u.
*     CATCH /idxmm/cx_bo_error .
*    ENDTRY.
      IF sy-subrc = 0.
        crs_wet_out->doc_status = ms_constants-c_memidoc_dnlcrsn.
      ENDIF.

    ENDIF.
  ENDMETHOD.


  METHOD set_idoc_status.
    DATA lv_xsart    TYPE /adz/hmv_sart.

* Customizing IDoc-Status
    DATA(lrt_hmv_sart) = /adz/cl_hmv_customizing=>get_hmv_sart(  ).

    CLEAR lv_xsart.
    " Ermittlung Status INVOIC
    LOOP AT lrt_hmv_sart->* INTO DATA(ls_hmv_sart)
      WHERE dexproc         = crs_wet_out->dexproc
        AND serviceanbieter = crs_wet_out->senid
        AND dexidocsent     = crs_wet_out->dexidocsent
        AND dexidocsendcat  = crs_wet_out->dexidocsendcat
        AND datab LE iv_tdate
        AND datbi GE iv_fdate.
      lv_xsart = ls_hmv_sart.
    ENDLOOP.

* IDoc füllen und IDOC-Status setzen
    crs_wet_out->idocin = iv_idoc_info-idocin.

    IF sy-subrc = 0.
      IF lv_xsart-inv = 'X'.
        CASE lv_xsart-status.
          WHEN iv_idoc_info-statin.
            crs_wet_out->statin    = icon_led_green.
            crs_wet_out->status_i  = iv_idoc_info-statin.
          WHEN OTHERS.
            crs_wet_out->statin    = icon_led_red.
            crs_wet_out->status_i  = iv_idoc_info-statin.
        ENDCASE.
      ENDIF.
    ELSE.
      crs_wet_out->statin    = icon_led_red.
      crs_wet_out->status_i  = iv_idoc_info-statin.
*      crs_wet_out->statct    = icon_led_red.
*      crs_wet_out->status_c  = ls_hmv_memi-statct.
*      crs_wet_out->sel        = 'X'.
*      crs_wet_out->status     = icon_breakpoint.
    ENDIF.

* Ermittlung Status CONTROL
    CLEAR: ls_hmv_sart, lv_xsart.
    LOOP AT lrt_hmv_sart->* INTO ls_hmv_sart
      WHERE dexproc         = crs_wet_out->dexproc
        AND serviceanbieter = crs_wet_out->senid
        AND dexidocsent     = crs_wet_out->dexidocsentctrl
        AND dexidocsendcat  = crs_wet_out->dexidocsendcat
        AND datab LE iv_tdate
        AND datbi GE iv_fdate.
      lv_xsart = ls_hmv_sart.
    ENDLOOP.

* IDoc füllen und IDOC-Status setzen
    crs_wet_out->idocct    = iv_idoc_info-idocct.

    IF sy-subrc = 0.
      IF lv_xsart-ctrl = 'X'.
        CASE lv_xsart-status.
          WHEN iv_idoc_info-statct.
            crs_wet_out->statct    = icon_led_green.
            crs_wet_out->status_c  = iv_idoc_info-statct.
          WHEN OTHERS.
            crs_wet_out->statct    = icon_led_red.
            crs_wet_out->status_c  = iv_idoc_info-statct.
        ENDCASE.
      ENDIF.
    ELSE.
*      crs_wet_out->statin    = icon_led_red.
*      crs_wet_out->status_i  = ls_hmv_memi-statin.
      crs_wet_out->statct    = icon_led_red.
      crs_wet_out->status_c  = iv_idoc_info-statct.
*      crs_wet_out->sel        = 'X'.
*      crs_wet_out->status     = icon_breakpoint.
    ENDIF.
  ENDMETHOD.


  METHOD vorschlag_mahnsperre.
    DATA: ls_mloc TYPE /adz/mem_mloc.
    DATA ls_memidoc_u TYPE /idxmm/memidoc.
    DATA ls_memidoc_s TYPE /idxmm/memidoc.
    DATA lt_memidoc_u TYPE /idxmm/t_memi_doc.
    DATA lr_memidoc TYPE REF TO /idxmm/cl_memi_document_db.
    DATA lb_comdis_active TYPE abap_bool VALUE abap_false.

    IF  crs_wet_out->comdis  IS NOT INITIAL
    AND crs_wet_out->remadv2 IS INITIAL.
      " nur comdis und keine zweite Reklamation => keine Mahnsperre setzen
      lb_comdis_active = abap_true.
    ENDIF.
** Wenn im Customizing gesetzt ist, dass Belege mit einem Zahlungsavis gemahnt werden sollen
** (C_MAHNEN = 'X') (C_MAHNEN_MEMI = 'X') wird dieser Teil übergangen, also es werden keine
**  Vorschläge für Mahnsperren gesetzt
    IF crs_wet_out->kennz =   ms_constants-c_doc_kzd.
      IF ms_constants-c_mahnen IS INITIAL.
        IF crs_wet_out->payst_icon <> ' '. "icon_led_green OR lr_out->payst_icon = ' '.
*    crs_wet_out->status = icon_breakpoint.
          IF lb_comdis_active EQ abap_false.
            crs_wet_out->to_lock = icon_breakpoint.
            crs_wet_out->sel = 'X'.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
    IF crs_wet_out->kennz = ms_constants-c_doc_kzm.
      IF ms_constants-c_mahnen_memi IS INITIAL.
        IF crs_wet_out->payst_icon <> ' '
          AND crs_wet_out->payst_icon NE icon_led_green.
*    crs_wet_out->status = icon_breakpoint.
          crs_wet_out->to_lock = icon_breakpoint.
          crs_wet_out->sel = 'X'.
        ENDIF.
      ENDIF.
    ENDIF.

    IF crs_wet_out->kennz =   ms_constants-c_doc_kzmsb.
      IF ms_constants-c_mahnen_msb IS INITIAL.
        IF crs_wet_out->payst_icon <> ' '. "icon_led_green OR lr_out->payst_icon = ' '.
*    crs_wet_out->status = icon_breakpoint.
          crs_wet_out->to_lock = icon_breakpoint.
          crs_wet_out->sel = 'X'.
        ENDIF.
      ENDIF.
    ENDIF.

    IF crs_wet_out->statrem = icon_led_red " OR lr_out->payst_icon = ' '.
    AND lb_comdis_active EQ abap_false.
*    crs_wet_out->status = icon_breakpoint.
      crs_wet_out->to_lock = icon_breakpoint.
      crs_wet_out->sel = 'X'.
    ENDIF.

    IF crs_wet_out->statin <> icon_led_green
    AND lb_comdis_active EQ abap_false.
*    crs_wet_out->status = icon_breakpoint.
      crs_wet_out->to_lock = icon_breakpoint.
      crs_wet_out->sel = 'X'.
    ENDIF.

    IF crs_wet_out->statct <> icon_led_green.
*    crs_wet_out->status = icon_breakpoint.
      crs_wet_out->to_lock = icon_breakpoint.
      crs_wet_out->sel = 'X'.
    ENDIF.

* --> Nuss 18.05.2018
    CLEAR ls_memidoc_u.
    SELECT SINGLE * FROM /idxmm/memidoc INTO ls_memidoc_u WHERE doc_id = crs_wet_out->opbel.


    IF ls_memidoc_u-doc_status = '76'
         AND ls_memidoc_u-simulation = ''
         AND ls_memidoc_u-reversal = 'X'.

      CLEAR ls_memidoc_s.
      SELECT SINGLE * FROM /idxmm/memidoc INTO ls_memidoc_s
         WHERE doc_id = ls_memidoc_u-reversal_doc_id
           AND doc_status = '60'
           AND orig_doc_id = ls_memidoc_u-doc_id.
      IF sy-subrc = 0.
        crs_wet_out->to_lock = icon_breakpoint.
        crs_wet_out->sel = 'X'.
      ENDIF.
    ELSEIF ls_memidoc_u-doc_status = '60'
          AND ls_memidoc_u-simulation = ''.
      CLEAR ls_memidoc_s.
      SELECT SINGLE * FROM /idxmm/memidoc INTO ls_memidoc_s
        WHERE doc_id = ls_memidoc_u-orig_doc_id
          AND doc_status = '76'
          AND reversal_doc_id = ls_memidoc_u-doc_id.
      IF sy-subrc = 0.
        crs_wet_out->to_lock = icon_breakpoint.
        crs_wet_out->sel = 'X'.
      ENDIF.
    ENDIF.


* MeMi-Beleg
*   --> Aussternen 02.02.2018 Nuss
*    IF crs_wet_out->payst_icon = icon_led_green
*     AND crs_wet_out->statrem <> icon_led_red
*     AND crs_wet_out->statin = icon_led_green
*     AND crs_wet_out->statct = icon_led_green
*     AND crs_wet_out->doc_status = c_memidoc_dnlcrsn.
*
*        CREATE OBJECT lr_memidoc.
*        SELECT SINGLE * FROM /idxmm/memidoc INTO ls_memidoc_u WHERE doc_id = wet_out-opbel.
*
*
*        ls_memidoc_u-doc_status = 60.
*        APPEND ls_memidoc_u TO lt_memidoc_u.
**      TRY.
*        CALL METHOD /idxmm/cl_memi_document_db=>update
*          EXPORTING
**           iv_simulate   =
*            it_doc_update = lt_memidoc_u.
**         CATCH /idxmm/cx_bo_error .
**        ENDTRY.
*
*        IF sy-subrc = 0.
*          crs_wet_out->doc_status = ls_memidoc_u-doc_status.
*        ENDIF.
*
*    ENDIF.
  ENDMETHOD.
ENDCLASS.
