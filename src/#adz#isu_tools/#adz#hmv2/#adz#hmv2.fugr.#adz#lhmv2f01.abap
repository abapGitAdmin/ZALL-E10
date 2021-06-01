*----------------------------------------------------------------------*
***INCLUDE LZEVUIT_HMVF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SELECT_ITEMS
*&---------------------------------------------------------------------*
FORM select_items .

  SELECT b~mandt b~opbel b~opupw b~opupk b~opupz b~bukrs
         b~blart b~vkont b~vtref b~gpart b~waers b~mansp
         b~xmanl b~betrh b~tvorg b~hvorg b~betrw b~stakz
         b~spart b~xtaus b~augst
         b~ikey  b~int_crossrefno AS crsrf
         a~bcbln a~thinr a~thist a~thidt  AS faedn
         a~intui a~thprd a~keydate
*         a~idocin a~statin a~idocct a~statct
*         a~dexproc a~dexidocsent a~dexidocsentctrl
*         a~dexidocsendcat
         INTO CORRESPONDING FIELDS OF TABLE t_fkkop
         FROM dfkkthi AS a
         INNER JOIN dfkkop AS b
                 ON b~opbel = a~opbel AND
                    b~opupw = a~opupw AND
                    b~opupk = a~opupk
         FOR ALL ENTRIES IN t_selct
         WHERE a~bcbln = t_selct-bcbln
           AND a~opbel = t_selct-opbel
           AND a~opupw = t_selct-opupw
           AND a~opupk = t_selct-opupk
           AND a~recid = wa_out-recid
           AND a~senid = wa_out-senid
           AND a~burel = 'X'
           AND a~storn = space
           AND a~stidc = space
           AND a~thist NE space
           AND b~augst IN t_so_augst
           AND b~augrs EQ space
           AND a~thinr = ( SELECT MAX( thinr ) FROM dfkkthi
                                  WHERE opbel = b~opbel
                                  AND   opupw = b~opupw
                                  AND   opupk = b~opupk )
           AND ( a~v_group = wa_out-v_group OR a~v_group IS NULL ).
ENDFORM.                    " SELECT_ITEMS

*&---------------------------------------------------------------------*
*&      Form  SELECT_CRSRF
*&---------------------------------------------------------------------*
FORM select_crsrf .

  REFRESH t_crsrf.

  IF NOT t_fkkop[] IS INITIAL.
    SORT t_fkkop BY crsrf.

    SELECT a~int_crossrefno a~int_ui
           a~crossrefno a~crn_rev
           b~ext_ui b~dateto
      INTO CORRESPONDING FIELDS OF TABLE t_crsrf
      FROM ecrossrefno AS a
      LEFT OUTER JOIN euitrans AS b
        ON b~int_ui = a~int_ui
      FOR ALL ENTRIES IN t_fkkop
      WHERE a~int_crossrefno = t_fkkop-crsrf.

    DELETE t_crsrf WHERE dateto NE '99991231'.
    DELETE ADJACENT DUPLICATES FROM t_crsrf.
  ENDIF.
  SORT t_crsrf BY crossrefno.
ENDFORM.                    " SELECT_CRSRF

*&---------------------------------------------------------------------*
*&      Form  SELECT_REMADV
*&---------------------------------------------------------------------*
FORM select_remadv .

* find REMADVs
  REFRESH t_remadv.

* New Version with Index TINV_INV_LINE_A OWN_INVOIVE_NO
  IF NOT t_crsrf[] IS INITIAL.
    SELECT h~invoice_type h~invoice_status
           d~int_inv_doc_no d~doc_type d~inv_doc_status
           l~own_invoice_no l~rstgr
           INTO CORRESPONDING FIELDS OF TABLE t_remadv
           FROM tinv_inv_line_a AS l
                INNER JOIN tinv_inv_doc AS d
                ON d~int_inv_doc_no = l~int_inv_doc_no
                INNER JOIN tinv_inv_head AS h
                ON h~int_inv_no = d~int_inv_no
           FOR ALL ENTRIES IN t_crsrf
           WHERE l~own_invoice_no = t_crsrf-crossrefno.
  ENDIF.

  SORT t_crsrf BY int_crossrefno.
ENDFORM.                    " SELECT_REMADV

*&---------------------------------------------------------------------*
*&      Form  SELECT_INV_DOCREF
*&---------------------------------------------------------------------*
FORM select_inv_docref.
  SELECT * FROM tinv_inv_docref AS d INTO TABLE mt_inv_docref
  FOR ALL ENTRIES IN t_remadv
  WHERE d~int_inv_doc_no = t_remadv-int_inv_doc_no
    and ( inbound_ref_type = 92 or inbound_ref_type = 93 )
    and inbound_ref_no = 1.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECT_INV_DOCREF
*&---------------------------------------------------------------------*
FORM fill_remadv USING iv_own_invoice_no  type crossrefno
                       irt_remadv         type ref to tty_remadv
                 CHANGING crs_wa_out      TYPE REF TO /adz/hmv_s_out_dunning.
  " echte Tabelle fuellen
  DATA(ls_int_receiver) = CONV inv_int_receiver( crs_wa_out->recid ).
  DATA(lv_spartyp) = /adz/cl_inv_select_basic=>get_divcat_for_doc( ls_int_receiver ).
  IF lv_spartyp = /idxgc/if_constants=>gc_divcat_elec. " Strom => Comdis und RemaDV2 und Lieferschein möglich
    TRY.
       " alle relevanten int_inv_doc_no in range-typ verpacken
       DATA lt_rng_INT_INV_DOC_NO type range of INV_INT_INV_DOC_NO.
       lt_rng_int_inv_doc_no = value #( for rs in irt_remadv->* where ( own_invoice_no = iv_own_invoice_no )
         ( sign = 'I'  option = 'EQ'   low = rs-int_inv_doc_no ) ) .

       " relevante docref Eintraege bestimmen
       DATA(lt_inv_docref) = value ttinv_inv_docref( for ls in mt_inv_docref where ( int_inv_doc_no in lt_rng_int_inv_doc_no ) ( ls  )  ).

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


      CATCH cx_sy_itab_line_not_found.
*        TRY.
*            IF crs_wa_out->comdis IS INITIAL.
*              " keine Comdis => wenn Referenz vorhanden, dann ist es die erste Reklamation
*              ls_docref = lt_inv_docref[  inbound_ref_type = 93 inbound_ref_no = 1 ].
*              crs_wa_out->remadv1 = ls_docref-inbound_ref.
*              /adz/cl_inv_select_basic=>get_reklamations_info(
*                 EXPORTING  iv_remadv  = crs_wa_out->remadv1
*                 IMPORTING  ev_remdate = crs_wa_out->remdate1
*                            ev_rstgr   = crs_wa_out->rstgr1  ).
*            ENDIF.
*          CATCH cx_sy_itab_line_not_found.
*        ENDTRY.
    ENDTRY.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECT_AKONTO
*&---------------------------------------------------------------------*
FORM select_akonto .

* --> Nuss 05.03.2018
  DATA: lv_hvorg        TYPE hvorg_kk,
        lr_hvorg_akonto LIKE RANGE OF lv_hvorg WITH HEADER LINE,
        lt_akto         TYPE TABLE OF /adz/hmv_akto WITH HEADER LINE,
        ls_akto         TYPE          /adz/hmv_akto.

  SELECT * FROM /adz/hmv_akto INTO TABLE lt_akto.

  LOOP AT lt_akto INTO ls_akto WHERE aktiv = 'X'.
    lr_hvorg_akonto-sign = 'I'.
    lr_hvorg_akonto-option = 'EQ'.
    lr_hvorg_akonto-low = ls_akto-hvorg.
    APPEND lr_hvorg_akonto.
  ENDLOOP.
  CHECK lr_hvorg_akonto[] IS NOT INITIAL.
* <--- Nuss 05.03.2018


  REFRESH t_akonto.
  CHECK NOT t_fkkop[] IS INITIAL.


  SORT t_fkkop BY vkont bukrs.
  SELECT * FROM dfkkop
           INTO CORRESPONDING FIELDS OF TABLE t_akonto
           FOR ALL ENTRIES IN t_fkkop
           WHERE augst = ' '
           AND   vkont = t_fkkop-vkont
           AND   bukrs = t_fkkop-bukrs
           AND   gpart = t_fkkop-gpart
*           AND   hvorg = c_hvorg_akonto.     "Nuss 05.03.2018
           AND  hvorg IN lr_hvorg_akonto.     "Nuss 05.03.2018
  SORT t_akonto.
  DELETE ADJACENT DUPLICATES FROM t_akonto.

ENDFORM.                    " SELECT_AKONTO

*&---------------------------------------------------------------------*
*&      Form  GET_LOCKS_BEL
*&---------------------------------------------------------------------*
FORM get_locks_bel .

  DATA: lv_t_dfkklocks TYPE STANDARD TABLE OF dfkklocks WITH DEFAULT KEY,
        wa_dfkklocks   TYPE                   dfkklocks.

  CLEAR lv_t_dfkklocks.
  CALL FUNCTION 'FKK_S_LOCK_GET_FOR_DOC_ITEMS'
    EXPORTING
      i_opbel  = <t_fkkop>-opbel
      i_opupw  = <t_fkkop>-opupw
      i_opupk  = <t_fkkop>-opupk
      i_opupz  = <t_fkkop>-opupz
    TABLES
      et_locks = lv_t_dfkklocks.

  LOOP AT lv_t_dfkklocks INTO wa_dfkklocks
       WHERE lotyp = ms_constants-c_lotyp
       AND   proid = ms_constants-c_proid.

    wet_out-fdate   = wa_dfkklocks-fdate.
    wet_out-tdate   = wa_dfkklocks-tdate.
    wet_out-mansp   = wa_dfkklocks-lockr.
  ENDLOOP.
ENDFORM.                    " GET_LOCKS_BEL
*&---------------------------------------------------------------------*
*&      Form  SET_DUNN_LOCK
*&---------------------------------------------------------------------*
FORM set_dunn_lock .

*>>> UH 11102012
*  check wa_out-status = icon_breakpoint.
  CHECK wa_out-sel = 'X'.
*<<< UH 11102012

  CLEAR   wa_fkkopchl.
  REFRESH t_fkkopchl.

  wa_fkkopchl-lockaktyp = ms_constants-c_lockaktyp.
  wa_fkkopchl-opupk     = <t_fkkop>-opupk.
  wa_fkkopchl-opupw     = <t_fkkop>-opupw.
  wa_fkkopchl-opupz     = <t_fkkop>-opupz.
  wa_fkkopchl-proid     = ms_constants-c_proid.
  wa_fkkopchl-lockr     = f_lockr.
  wa_fkkopchl-fdate     = f_fdate.
  wa_fkkopchl-tdate     = f_tdate.
  wa_fkkopchl-lotyp     = ms_constants-c_lotyp.
  wa_fkkopchl-gpart     = <t_fkkop>-gpart.
  wa_fkkopchl-vkont     = <t_fkkop>-vkont.
  APPEND wa_fkkopchl TO t_fkkopchl.

  CALL FUNCTION 'FKK_DOCUMENT_CHANGE_LOCKS'
    EXPORTING
      i_opbel           = <t_fkkop>-opbel
    TABLES
      t_fkkopchl        = t_fkkopchl
    EXCEPTIONS
      err_document_read = 1
      err_create_line   = 2
      err_lock_reason   = 3
      err_lock_date     = 4
      OTHERS            = 5.

  IF sy-subrc <> 0.
    wet_out-status = icon_breakpoint.
  ELSE.
    wet_out-mansp  = f_lockr.
    wet_out-fdate  = f_fdate.
    wet_out-tdate  = f_tdate.
    wet_out-status = icon_locked.
  ENDIF.
** Sperren der OPBELS wieder aufheben
  CALL FUNCTION 'FKK_DEQ_OPBELS_AFTER_CHANGES'
    EXPORTING
      _scope          = '3'
      i_only_document = ' '.
ENDFORM.                    " SET_DUNN_LOCK
*&---------------------------------------------------------------------*
*&      Form  GET_MANST_BEL
*&---------------------------------------------------------------------*
*>>> UH 30012013
FORM get_manst_bel .

* Mahnstufe (nur "echte")
  SELECT MAX( mahns ) FROM fkkmaze
         INTO wet_out-mahns
         WHERE opbel = <t_fkkop>-opbel
         AND   opupk = <t_fkkop>-opupk
         AND   opupz = <t_fkkop>-opupz
         AND   opupw = <t_fkkop>-opupw
         AND   xmsto =  ' '
         AND   mdrkd NE '00000000'.
  IF sy-subrc NE 0.
    CLEAR wet_out-mahns.
  ENDIF.

* Druckdatum 1. Mahnung
  SELECT SINGLE mdrkd FROM fkkmaze
         INTO wet_out-mdrkd
         WHERE opbel = <t_fkkop>-opbel
         AND   opupk = <t_fkkop>-opupk
         AND   opupz = <t_fkkop>-opupz
         AND   opupw = <t_fkkop>-opupw
         AND   mahns = '01'
         AND   xmsto =  ' '.
  IF sy-subrc NE 0.
    CLEAR wet_out-mdrkd.
  ENDIF.
ENDFORM.                    " GET_MANST_BEL
*&---------------------------------------------------------------------*
*&      Form  GET_INTEREST
*&---------------------------------------------------------------------*
FORM get_interest .

  DATA: h_ibtrg TYPE ibtrg_kk.

  SELECT b~ibtrg
    INTO h_ibtrg
    FROM dfkkih AS a
      INNER JOIN dfkkia AS b
      ON  b~iopbel = a~iopbel
      AND b~opbel  = a~opbel
      AND b~opupk  = a~opupk
      AND b~opupz  = a~opupz
      AND b~opupw  = a~opupw
    WHERE a~opbel  = <t_fkkop>-opbel
    AND   a~opupk  = <t_fkkop>-opupk
    AND   a~opupz  = <t_fkkop>-opupz
    AND   a~opupw  = <t_fkkop>-opupw
    AND   a~stokz  = space.

    wet_out-ibtrg  = wet_out-ibtrg + h_ibtrg.

  ENDSELECT.
ENDFORM.                    " GET_INTEREST
*&---------------------------------------------------------------------*
*&      Form  SELECT_AUGST_BCBLN
*&---------------------------------------------------------------------*
FORM select_augst_bcbln .

  IF NOT t_selct[] IS INITIAL.
    SELECT opbel augst
      INTO CORRESPONDING FIELDS OF TABLE t_bcbln
      FROM dfkkop
      FOR ALL ENTRIES IN t_selct
      WHERE opbel = t_selct-bcbln
        AND opupz = '000'.
  ENDIF.
  SORT t_bcbln.
ENDFORM.                    " SELECT_AUGST_BCBLN
*&---------------------------------------------------------------------*
*&      Form  SELECT_MEMIDOC
*&---------------------------------------------------------------------*
FORM select_memidoc.


  DATA: ls_doc_status_range TYPE /idxmm/s_doc_status_range,
        lt_doc_status_range TYPE /idxmm/t_doc_status_range,
        ls_docstatus        TYPE /idxmm/docstatus.


  IF t_so_augst[] IS NOT INITIAL.

    LOOP AT t_so_augst INTO ls_so_augst.

      IF ls_so_augst-low = 9.

* Ausgeglichene MeMi-Belege berücksichtigen, wenn Ausgleichsstatus 9 selektiert

        SELECT *
          FROM /idxmm/docstatus
          INTO ls_docstatus
          WHERE doc_status GE '80' OR doc_status EQ '65' OR doc_status EQ ms_constants-c_memidoc_dnlcrsn.

          ls_doc_status_range-sign   = 'I'.
          ls_doc_status_range-option = 'EQ'.
          ls_doc_status_range-low = ls_docstatus-doc_status.
          APPEND ls_doc_status_range TO lt_doc_status_range.
        ENDSELECT.

      ELSE.

* nicht ausgeglichene MeMi-Belege berücksichtigen

        SELECT *
          FROM /idxmm/docstatus
          INTO ls_docstatus
          WHERE doc_status LT '80' AND doc_status NE '65' OR doc_status EQ ms_constants-c_memidoc_dnlcrsn.

          ls_doc_status_range-sign   = 'I'.
          ls_doc_status_range-option = 'EQ'.
          ls_doc_status_range-low = ls_docstatus-doc_status.
          APPEND ls_doc_status_range TO lt_doc_status_range.
        ENDSELECT.

      ENDIF.

    ENDLOOP.

  ENDIF.

  IF NOT t_selct_memi[] IS INITIAL.
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE t_memidoc
      FROM /idxmm/memidoc
      FOR ALL ENTRIES IN t_selct_memi
      WHERE ci_fica_doc_no = t_selct_memi-ci_fica_doc_no
        AND opupk          = t_selct_memi-opupk
        AND doc_id         = t_selct_memi-doc_id
        AND doc_status IN lt_doc_status_range.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SELECT_CRSRF_MEMI
*&---------------------------------------------------------------------*
FORM select_crsrf_memi .

  REFRESH t_crsrf.
  "Hilfstabellen um leere einträge von der Selektion auszuschließen
  DATA lt_memidoc LIKE  t_memidoc.
  DATA ls_memidoc LIKE LINE OF t_memidoc.
  CLEAR lt_memidoc.
  LOOP AT t_memidoc INTO ls_memidoc WHERE crossrefno IS NOT INITIAL.
    APPEND ls_memidoc TO lt_memidoc.
  ENDLOOP.

  IF NOT lt_memidoc[] IS INITIAL.
    SORT lt_memidoc BY crossrefno.
*    delete t_memidoc WHERE crossrefno IS INITIAL.
    SELECT a~int_crossrefno a~int_ui
           a~crossrefno a~crn_rev
           b~ext_ui b~dateto
       INTO CORRESPONDING FIELDS OF TABLE t_crsrf
       FROM ecrossrefno AS a
            LEFT OUTER JOIN euitrans AS b
            ON b~int_ui = a~int_ui
       FOR ALL ENTRIES IN lt_memidoc
       WHERE a~crossrefno = lt_memidoc-crossrefno
              .

    DELETE t_crsrf WHERE dateto NE '99991231'.
    DELETE ADJACENT DUPLICATES FROM t_crsrf.
  ENDIF.
  SORT t_crsrf BY crossrefno.
ENDFORM.                    " SELECT_CRSRF
*&---------------------------------------------------------------------*
*&      Form  SET_DUNN_LOCK_MEMI
*&---------------------------------------------------------------------*
FORM set_dunn_lock_memi.
* <<< ET_20160315
  DATA: ls_mloc TYPE /adz/mem_mloc.
  DATA ls_memidoc_u TYPE /idxmm/memidoc.
  DATA lt_memidoc_u TYPE /idxmm/t_memi_doc.
  DATA lr_memidoc TYPE REF TO /idxmm/cl_memi_document_db.

  CHECK wet_out-sel = 'X'.

  IF ms_constants-c_idxmm_sp03_dunn IS INITIAL.
    ls_mloc-doc_id    = wet_out-opbel.
    ls_mloc-lockr     = f_lockr.
    ls_mloc-fdate     = f_fdate.
    ls_mloc-tdate     = f_tdate.
    GET  TIME STAMP FIELD ls_mloc-timestamp.    "Nuss 14.02.2018
    ls_mloc-crnam     = sy-uname.
    ls_mloc-azeit     = sy-timlo.
    ls_mloc-adatum    = sy-datum.
    INSERT INTO /adz/mem_mloc VALUES ls_mloc.

*  CLEAR   wa_fkkopchl.
*  REFRESH t_fkkopchl.
*
*  wa_fkkopchl-lockaktyp = c_lockaktyp.
*  wa_fkkopchl-proid     = c_proid.
*  wa_fkkopchl-lockr     = f_lockr.
*  wa_fkkopchl-fdate     = f_fdate.
*  wa_fkkopchl-tdate     = f_tdate.
*  wa_fkkopchl-lotyp     = c_lotyp.
*  wa_fkkopchl-gpart     = <fs_memidoc>-suppl_bupa.
*  wa_fkkopchl-vkont     = <fs_memidoc>-suppl_contr_acct.
*  wa_fkkopchl-opupk     = <fs_memidoc>-opupk.
*  APPEND wa_fkkopchl TO t_fkkopchl.
*
*  CALL FUNCTION 'FKK_DOCUMENT_CHANGE_LOCKS'
*    EXPORTING
*      i_opbel           = <fs_memidoc>-doc_id
*    TABLES
*      t_fkkopchl        = t_fkkopchl
*    EXCEPTIONS
*      err_document_read = 1
*      err_create_line   = 2
*      err_lock_reason   = 3
*      err_lock_date     = 4
*      OTHERS            = 5.

    IF sy-subrc <> 0.
      wet_out-status = icon_breakpoint.
    ELSE.
      wet_out-mansp  = f_lockr.
      wet_out-fdate  = f_fdate.
      wet_out-tdate  = f_tdate.
      wet_out-status = icon_locked.
    ENDIF.


** Sperren der DOC_IDs wieder aufheben
*  CALL FUNCTION 'FKK_DEQ_OPBELS_AFTER_CHANGES'
*    EXPORTING
*      _scope          = '3'
*      i_only_document = ' '.
* >>> ET_20160315

  ELSE.

    CREATE OBJECT lr_memidoc.
    SELECT SINGLE * FROM /idxmm/memidoc INTO ls_memidoc_u WHERE doc_id = wet_out-opbel.


    ls_memidoc_u-doc_status = ms_constants-c_memidoc_dnlcrsn.
    APPEND ls_memidoc_u TO lt_memidoc_u.
*  TRY.
    CALL METHOD /idxmm/cl_memi_document_db=>update
      EXPORTING
*       iv_simulate   =
        it_doc_update = lt_memidoc_u.
*     CATCH /idxmm/cx_bo_error .
*    ENDTRY.

    IF sy-subrc = 0.
      wet_out-doc_status = ms_constants-c_memidoc_dnlcrsn.
    ENDIF.


  ENDIF.



ENDFORM.                    " SET_DUNN_LOCK

FORM vorschlag_mahnsperre CHANGING ls_out TYPE /adz/hmv_s_out_dunning.
  DATA: ls_mloc TYPE /adz/mem_mloc.
  DATA ls_memidoc_u TYPE /idxmm/memidoc.
  DATA ls_memidoc_s TYPE /idxmm/memidoc.                                    "Nuss 18.05.2018
  DATA lt_memidoc_u TYPE /idxmm/t_memi_doc.
  DATA lr_memidoc TYPE REF TO /idxmm/cl_memi_document_db.


** --> Nuss 06.2018
** Wenn im Customizing gesetzt ist, dass Belege mit einem Zahlungsavis gemahnt werden sollen
** (C_MAHENEN = 'X') (C_MAHNEN_MEMI = 'X') wird dieser Teil übergangen, also es werden keine
**  Vorschläge für Mahnsperren gesetzt
  IF ls_out-kennz =   ms_constants-c_doc_kzd.                                                 "Nuss 02.02.2018
    IF ms_constants-c_mahnen IS INITIAL.                                                      "Nuss 06.2018
      IF ls_out-payst_icon <> ' '. "icon_led_green OR lr_out->payst_icon = ' '.
*    ls_out-status = icon_breakpoint.                          "Nuss 18.05.2018
        ls_out-to_lock = icon_breakpoint.                          "Nuss 18.05.2018
        ls_out-sel = 'X'.
      ENDIF.
** --> Nuss 02.02.2018
    ENDIF.                                                                       "Nuss 06.2018
  ENDIF.
  IF ls_out-kennz = ms_constants-c_doc_kzm.
    IF ms_constants-c_mahnen_memi IS INITIAL.                                                 "Nuss 06.2018                                                                    "Nuss 06.2018
      IF ls_out-payst_icon <> ' '
        AND ls_out-payst_icon NE icon_led_green.
*    ls_out-status = icon_breakpoint.                          "Nuss 18.05.2018
        ls_out-to_lock = icon_breakpoint.                          "Nuss 18.05.2018
        ls_out-sel = 'X'.
      ENDIF.
    ENDIF.                                                                        "Nuss 06.2018
  ENDIF.
** <-- Nuss 02.02.2018

** --> Nuss 09.2018
  IF ls_out-kennz =   ms_constants-c_doc_kzmsb.
    IF ms_constants-c_mahnen_msb IS INITIAL.
      IF ls_out-payst_icon <> ' '. "icon_led_green OR lr_out->payst_icon = ' '.
*    ls_out-status = icon_breakpoint.
        ls_out-to_lock = icon_breakpoint.
        ls_out-sel = 'X'.
      ENDIF.
    ENDIF.
  ENDIF.
** <-- Nuss 09.2018


  IF ls_out-statrem = icon_led_red. " OR lr_out->payst_icon = ' '.
*    ls_out-status = icon_breakpoint.                          "Nuss 18.05.2018
    ls_out-to_lock = icon_breakpoint.                          "Nuss 18.05.2018
    ls_out-sel = 'X'.
  ENDIF.

  IF ls_out-statin <> icon_led_green.
*    ls_out-status = icon_breakpoint.                          "Nuss 18.05.2018
    ls_out-to_lock = icon_breakpoint.                          "Nuss 18.05.2018
    ls_out-sel = 'X'.
  ENDIF.

  IF ls_out-statct <> icon_led_green.
*    ls_out-status = icon_breakpoint.                          "Nuss 18.05.2018
    ls_out-to_lock = icon_breakpoint.                          "Nuss 18.05.2018
    ls_out-sel = 'X'.
  ENDIF.

* --> Nuss 18.05.2018
  CLEAR ls_memidoc_u.
  SELECT SINGLE * FROM /idxmm/memidoc INTO ls_memidoc_u WHERE doc_id = wet_out-opbel.


  IF ls_memidoc_u-doc_status = '76'
       AND ls_memidoc_u-simulation = ''
       AND ls_memidoc_u-reversal = 'X'.

    CLEAR ls_memidoc_s.
    SELECT SINGLE * FROM /idxmm/memidoc INTO ls_memidoc_s
       WHERE doc_id = ls_memidoc_u-reversal_doc_id
         AND doc_status = '60'
         AND orig_doc_id = ls_memidoc_u-doc_id.
    IF sy-subrc = 0.
      ls_out-to_lock = icon_breakpoint.
      ls_out-sel = 'X'.
    ENDIF.
  ELSEIF ls_memidoc_u-doc_status = '60'
        AND ls_memidoc_u-simulation = ''.
    CLEAR ls_memidoc_s.
    SELECT SINGLE * FROM /idxmm/memidoc INTO ls_memidoc_s
      WHERE doc_id = ls_memidoc_u-orig_doc_id
        AND doc_status = '76'
        AND reversal_doc_id = ls_memidoc_u-doc_id.
    IF sy-subrc = 0.
      ls_out-to_lock = icon_breakpoint.
      ls_out-sel = 'X'.
    ENDIF.
  ENDIF.
* <-- Nuss 18.05.2018


* MeMi-Beleg
*   --> Aussternen 02.02.2018 Nuss
*    IF ls_out-payst_icon = icon_led_green
*     AND ls_out-statrem <> icon_led_red
*     AND ls_out-statin = icon_led_green
*     AND ls_out-statct = icon_led_green
*     AND ls_out-doc_status = c_memidoc_dnlcrsn.
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
*          ls_out-doc_status = ls_memidoc_u-doc_status.
*        ENDIF.
*
*    ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CHANGE_MEMIDOC_STATUS
*&---------------------------------------------------------------------*
*       Ändern Status von stornierten Memi-Belegen von 76 auf 77
*       - Prüfen ob Storniert und Status = 76 (nur Status 76 ausgewählt)
*       - Ermittlung Beleg-ID des Storno
*       - Prüfung Status des Storno ist gleich 70, 75, 85 oder 86
*----------------------------------------------------------------------*
*      <--P_LS_MEMIDOC_HELP  text
*----------------------------------------------------------------------*
FORM change_memidoc_status  CHANGING p_memidoc_help TYPE /idxmm/memidoc.


  DATA: ls_memidoc_storno TYPE /idxmm/memidoc.
  DATA: ls_memidoc_u  TYPE /idxmm/memidoc.
  DATA lt_memidoc_u TYPE /idxmm/t_memi_doc.



  DATA lr_memidoc TYPE REF TO /idxmm/cl_memi_document_db.
** Prüfen: Ist der Memi-Beleg storniert?

  IF p_memidoc_help-reversal = abap_true.
    CLEAR ls_memidoc_storno.
    SELECT SINGLE * FROM /idxmm/memidoc INTO ls_memidoc_storno
      WHERE doc_id = p_memidoc_help-reversal_doc_id.
    IF sy-subrc = 0.
      IF ls_memidoc_storno-doc_status = '70' OR
         ls_memidoc_storno-doc_status = '75' OR
        ls_memidoc_storno-doc_status = '85' OR
        ls_memidoc_storno-doc_status = '86'.

        CREATE OBJECT lr_memidoc.
        ls_memidoc_u = p_memidoc_help.
        ls_memidoc_u-doc_status = '77'.
        APPEND ls_memidoc_u TO lt_memidoc_u.
        TRY.
            CALL METHOD /idxmm/cl_memi_document_db=>update
              EXPORTING
*               iv_simulate   =
                it_doc_update = lt_memidoc_u.
          CATCH /idxmm/cx_bo_error .
        ENDTRY.
        IF sy-subrc = 0.
          p_memidoc_help-doc_status = ls_memidoc_u-doc_status.
        ENDIF.
      ENDIF.

    ENDIF.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECT_ITEMS_MSB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM select_items_msb .

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

         INTO CORRESPONDING FIELDS OF TABLE t_fkkop_msb
         FROM dfkkinvdoc_i AS a
         INNER JOIN dfkkop AS b
                 ON b~opbel = a~opbel "AND
*                    b~opupw = a~opupw AND
*                    b~opupk = a~opupk
         INNER JOIN dfkkinvdoc_h AS c
               ON c~invdocno = a~invdocno
         FOR ALL ENTRIES IN t_selct_msb
*         WHERE a~bcbln = t_selct_msb-bcbln
         WHERE a~opbel = t_selct_msb-opbel
**           AND a~opupw = t_selct-opupw
**           AND a~opupk = t_selct-opupk
*           AND a~recid = wa_out-recid
*           AND a~senid = wa_out-senid
*           AND a~burel = 'X'
*           AND a~storn = space
*           AND a~stidc = space
*           AND a~thist NE space
           AND b~augst IN t_so_augst
           AND b~augrs EQ space.
*           AND a~thinr = ( SELECT MAX( thinr ) FROM dfkkthi
*                                  WHERE opbel = b~opbel
*                                  AND   opupw = b~opupw
*                                  AND   opupk = b~opupk )
*           AND ( a~v_group = wa_out-v_group OR a~v_group IS NULL ).

  SORT t_fkkop_msb.
  DELETE ADJACENT DUPLICATES FROM t_fkkop_msb COMPARING ALL FIELDS..

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECT_CRSRF_MSB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM select_crsrf_msb .

  REFRESH t_crsrf.
* Hilstabellen um leere Einträge von der Yelektion auszuschließen
  DATA lt_fkkop_msb LIKE t_fkkop_msb.
  DATA ls_fkkop_msb LIKE LINE OF t_fkkop_msb.
  CLEAR ls_fkkop_msb.
  LOOP AT t_fkkop_msb INTO ls_fkkop_msb WHERE crossrefno IS NOT INITIAL.
    APPEND ls_fkkop_msb TO lt_fkkop_msb.
  ENDLOOP.

  IF NOT lt_fkkop_msb[] IS INITIAL.
    SORT lt_fkkop_msb BY crossrefno.
    SELECT a~int_crossrefno a~int_ui
           a~crossrefno a~crn_rev
           b~ext_ui b~dateto
      INTO CORRESPONDING FIELDS OF TABLE t_crsrf
      FROM ecrossrefno AS a
       LEFT OUTER JOIN euitrans AS b
          ON b~int_ui = a~int_ui
      FOR ALL ENTRIES IN lt_fkkop_msb
      WHERE a~crossrefno = lt_fkkop_msb-crossrefno.

    DELETE t_crsrf WHERE dateto NE '99991231'.
    DELETE ADJACENT DUPLICATES FROM t_crsrf.
  ENDIF.
  SORT t_crsrf BY crossrefno.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_LOCKS_BEL_MSB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_locks_bel_msb .

  DATA: lv_t_dfkklocks TYPE STANDARD TABLE OF dfkklocks WITH DEFAULT KEY,
        wa_dfkklocks   TYPE                   dfkklocks.

  CLEAR lv_t_dfkklocks.
  CALL FUNCTION 'FKK_S_LOCK_GET_FOR_DOC_ITEMS'
    EXPORTING
      i_opbel  = <t_fkkop_msb>-bcbln
      i_opupw  = '000'   "<t_fkkop_msb>-opupw
      i_opupk  = '0001'  "<t_fkkop_msb>-opupk
      i_opupz  = '000'  "<t_fkkop_msb>-opupz
    TABLES
      et_locks = lv_t_dfkklocks.

  LOOP AT lv_t_dfkklocks INTO wa_dfkklocks
       WHERE lotyp = ms_constants-c_lotyp
       AND   proid = ms_constants-c_proid.

    wet_out-fdate   = wa_dfkklocks-fdate.
    wet_out-tdate   = wa_dfkklocks-tdate.
    wet_out-mansp   = wa_dfkklocks-lockr.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_MANST_BEL_MSB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_manst_bel_msb .

* Mahnstufe (nur "echte")
  SELECT MAX( mahns ) FROM fkkmaze
         INTO wet_out-mahns
         WHERE opbel = <t_fkkop_msb>-bcbln
         AND   opupk = '0001' "<t_fkkop_msb>-opupk
         AND   opupz = '0000' "<t_fkkop_msb>-opupz
         AND   opupw = '000'  "<t_fkkop_msb>-opupw
         AND   xmsto =  ' '
         AND   mdrkd NE '00000000'.
  IF sy-subrc NE 0.
    CLEAR wet_out-mahns.
  ENDIF.

* Druckdatum 1. Mahnung
  SELECT SINGLE mdrkd FROM fkkmaze
         INTO wet_out-mdrkd
WHERE opbel = <t_fkkop_msb>-bcbln
         AND   opupk = '0001' "<t_fkkop_msb>-opupk
         AND   opupz = '0000' "<t_fkkop_msb>-opupz
         AND   opupw = '000'  "<t_fkkop_msb>-opupw
         AND   mahns = '01'
         AND   xmsto =  ' '.
  IF sy-subrc NE 0.
    CLEAR wet_out-mdrkd.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECT_AUGST_MSBDOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM select_augst_msbdoc .

  IF NOT t_selct_msb[] IS INITIAL.
    SELECT opbel augst
      INTO CORRESPONDING FIELDS OF TABLE t_bcbln
      FROM dfkkop
      FOR ALL ENTRIES IN t_selct_msb
      WHERE opbel = t_selct_msb-opbel
        AND opupz = '000'.
  ENDIF.
  SORT t_bcbln.

ENDFORM.
