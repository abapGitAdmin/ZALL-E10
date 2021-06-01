FUNCTION /ADZ/HMV_SELECT_MEMIDOC.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IS_OUT) TYPE  /ADZ/HMV_S_OUT_DUNNING
*"     VALUE(IF_AKONTO) TYPE  CHECKBOX
*"     VALUE(IF_UPDTE) TYPE  CHECKBOX
*"     VALUE(IF_ADUNN) TYPE  CHECKBOX
*"     VALUE(IF_LOCKR) TYPE  MANSP_OLD_KK
*"     VALUE(IF_FDATE) TYPE  SYDATUM
*"     VALUE(IF_TDATE) TYPE  SYDATUM
*"  TABLES
*"      IT_SELCT_MEMI STRUCTURE  /ADZ/HMV_SELCT_MEMI
*"      ET_OUT STRUCTURE  /ADZ/HMV_S_OUT_DUNNING
*"      IT_SO_AUGST STRUCTURE  RSDSSELOPT
*"      IT_SO_MANSP STRUCTURE  RSDSSELOPT
*"      IT_SO_MAHNS STRUCTURE  RSDSSELOPT
*"----------------------------------------------------------------------

  wa_out         = is_out.
  t_selct_memi[] = it_selct_memi[].
  f_lockr        = if_lockr.
  f_fdate        = if_fdate.
  f_tdate        = if_tdate.
  t_so_mansp[]   = it_so_mansp[].
  t_so_mahns[]   = it_so_mahns[].
  t_so_augst[]   = it_so_augst[].


  DATA:
    ls_memidoc TYPE /idxmm/memidoc,
    xsart      TYPE /adz/hmv_sart.



  DATA ls_mloc TYPE /adz/mem_mloc .
  DATA ls_hmv_memi TYPE /adz/hmv_memi.

  DATA: lt_mloc TYPE TABLE OF /adz/mem_mloc.          "Nuss 02.02.2018


  FIELD-SYMBOLS:
    <s_memidoc>  TYPE /idxmm/memidoc,
    <f_euitrans> TYPE euitrans,
    <f_crsrf>    TYPE ecrossrefno.

  DATA: ls_memidoc_help  TYPE /idxmm/memidoc.             "Nuss 05.02.2018
* Daten selektieren

  REFRESH et_out.
  ms_constants = /adz/cl_hmv_constants=>get_constants( ).
  PERFORM select_memidoc.
  PERFORM select_crsrf_memi.
  PERFORM select_remadv.

*  REFRESH t_hmv_sart.

* Customizing lesen
  SELECT * FROM /adz/hmv_sart
    INTO TABLE t_hmv_sart.

  LOOP AT t_memidoc ASSIGNING <s_memidoc>.
    CLEAR: wet_out.
    wet_out = wa_out.
    MOVE <s_memidoc>-doc_id             TO wet_out-opbel.
    MOVE <s_memidoc>-company_code       TO wet_out-bukrs.
    MOVE <s_memidoc>-crossrefno         TO wet_out-ownrf.
    MOVE <s_memidoc>-int_pod            TO wet_out-int_ui.
    MOVE <s_memidoc>-dist_sp            TO wet_out-senid.
    MOVE <s_memidoc>-suppl_sp           TO wet_out-recid.
    MOVE <s_memidoc>-currency           TO wet_out-waers.
    MOVE <s_memidoc>-gross_amount       TO wet_out-betrh.
    MOVE <s_memidoc>-due_date           TO wet_out-faedn.
    MOVE <s_memidoc>-opupk              TO wet_out-opupk.
    "  MOVE <s_memidoc>-invoic_idoc        TO wet_out-idocin.
    MOVE <s_memidoc>-ci_fica_doc_no     TO wet_out-bcbln.
    MOVE <s_memidoc>-inv_send_date      TO wet_out-thprd.
    MOVE <s_memidoc>-doc_status         TO wet_out-doc_status.
    MOVE <s_memidoc>-suppl_bupa         TO wet_out-gpart.
    MOVE <s_memidoc>-suppl_contr_acct   TO wet_out-aggvk.

    CLEAR ls_hmv_memi.

**  --> Nuss 05.02.2018
**     Status für Stornierte MeMi-Belege mit Status 76 ändern
    IF <s_memidoc>-doc_status = '76'.
      CLEAR ls_memidoc_help.
      MOVE <s_memidoc> TO ls_memidoc_help.
      PERFORM change_memidoc_status CHANGING ls_memidoc_help.
      ls_memidoc_help-doc_status = <s_memidoc>-doc_status.
      MOVE <s_memidoc>-doc_status TO wet_out-doc_status.
    ENDIF.
**  <-- Nuss 05.02.2018

* Mahnhistorie lesen ------------------------------------------------------------------*

*    IF c_idxmm_sp03_dunn IS NOT INITIAL.

*     Mahnstufe (nur "echte")
    SELECT MAX( mahns ) FROM /idxmm/dun_hist  "fkkmaze           "Nuss 01.02.2018
           INTO wet_out-mahns
*             WHERE opbel = wet_out-bcbln "wet_out-opbel          "Nuss 02.02.2018
           WHERE doc_id = wet_out-opbel "wet_out-opbel          "Nuss 02.02.2018
           AND   opupk = wet_out-opupk
           AND   xmsto =  ' '.
*             AND   mdrkd NE '00000000'.                          "Nuss 01.02.2018

    IF sy-subrc NE 0.
      CLEAR wet_out-mahns.
    ENDIF.

*     Druckdatum 1. Mahnung
*        SELECT SINGLE mdrkd FROM fkkmaze
*               INTO wet_out-mdrkd
*             WHERE opbel = wet_out-bcbln "wet_out-opbel
*               AND   opupk = wet_out-opupk
**               AND   mahns = '01'
*               AND   xmsto =  ' '.
*        IF sy-subrc NE 0.
*          CLEAR wet_out-mdrkd.
*        ENDIF.

**     Druckdatum 1. Mahnung
*        SELECT SINGLE mdrkd FROM fkkmaze
*               INTO wet_out-mdrkd
*             WHERE opbel = wet_out-bcbln "wet_out-opbel
*               AND   opupk = wet_out-opupk
**               AND   mahns = '01'
*               AND   xmsto =  ' '.
*        IF sy-subrc NE 0.
*          CLEAR wet_out-mdrkd.
*        ENDIF.

*      SELECT MAX( mdrkd ) FROM fkkmaze
*        INTO wet_out-mdrkd
*      WHERE opbel = wet_out-bcbln
*        AND opupk = wet_out-opupk
*        AND   xmsto =  ' '.


*    ELSE.

**     Mahnstufe (nur "echte")
*      SELECT MAX( mahns ) FROM fkkmaze
*             INTO wet_out-mahns
*             WHERE opbel = wet_out-opbel
*             AND   xmsto =  ' '
*             AND   mdrkd NE '00000000'.
*      IF sy-subrc NE 0.
*        CLEAR wet_out-mahns.
*      ENDIF.
*
**     Druckdatum 1. Mahnung
*      SELECT SINGLE mdrkd FROM fkkmaze
*             INTO wet_out-mdrkd
*           WHERE opbel = wet_out-opbel
*             AND   mahns = '01'
*             AND   xmsto =  ' '.
*      IF sy-subrc NE 0.
*        CLEAR wet_out-mdrkd.
*      ENDIF.

* Mahnsperren lesen --------------------------------------------------------------------*
    CLEAR ls_mloc.

**     --> Nuss 02.02.2018
*      SELECT SINGLE * FROM /ADZ/hmv_mloc INTO ls_mloc
*        WHERE doc_id = wet_out-opbel
*        AND fdate <= sy-datum AND tdate >= sy-datum
*        AND lvorm = ''.

    SELECT * FROM /adz/mem_mloc
      INTO TABLE lt_mloc
      WHERE doc_id = wet_out-opbel
      AND tdate GE sy-datum
      AND lvorm = ''.

    IF sy-subrc = 0.
      SORT lt_mloc BY tdate ASCENDING.
      READ TABLE lt_mloc INTO ls_mloc INDEX 1.


**  --> Nuss 12.02.2018
      IF sy-subrc = 0.
        IF sy-datum BETWEEN ls_mloc-fdate AND
                            ls_mloc-tdate.
          wet_out-status = icon_locked.
        ELSE.
          wet_out-status = icon_led_yellow.
        ENDIF.
**  <-- Nuss 12.02.2018
        MOVE ls_mloc-fdate TO wet_out-fdate.
        MOVE ls_mloc-tdate TO wet_out-tdate.
        MOVE ls_mloc-lockr TO wet_out-mansp.

        CHECK wet_out-mansp IN t_so_mansp.
      ENDIF.
    ENDIF.
**  <-- Nuss 02.02.2018



    CHECK wet_out-mahns IN t_so_mahns.


*-------------------- Pos. REMADV --------------------*
    READ TABLE t_remadv ASSIGNING <t_remadv>
    WITH KEY own_invoice_no = wet_out-ownrf
               invoice_type = ms_constants-c_invoice_type7         "'007'.
         ."    BINARY SEARCH.
    IF sy-subrc = 0 AND <t_remadv> IS ASSIGNED.
      wet_out-payno = <t_remadv>-int_inv_doc_no.
      wet_out-payst = <t_remadv>-inv_doc_status.
      IF <t_remadv>-inv_doc_status = ms_constants-c_invoice_paymst.  "'13'.
        wet_out-payst_icon = icon_led_green.            "überführte Avise - Status grün
      ELSE.
        wet_out-payst_icon = icon_led_yellow.           "offene Avise - Status gelb
      ENDIF.
    ENDIF.
    UNASSIGN <t_remadv>.


*-------------------- Neg. REMADV --------------------*
*    SORT t_remadv by int_inv_doc_no DESCENDING.
    READ TABLE t_remadv ASSIGNING <t_remadv>
      WITH KEY own_invoice_no = wet_out-ownrf
                 invoice_type = ms_constants-c_invoice_type8
      ."       BINARY SEARCH.
    IF sy-subrc = 0 AND <t_remadv> IS ASSIGNED.
      IF <t_remadv>-invoice_status = ms_constants-c_invoice_status_03.  "03 - beeendete Reklamation - Warnung
        wet_out-docno    = <t_remadv>-int_inv_doc_no.
        wet_out-rstgr    = <t_remadv>-rstgr.
        wet_out-statrem  = icon_led_yellow.
        wet_out-to_lock   = icon_led_yellow.
      ELSE.
        wet_out-docno    = <t_remadv>-int_inv_doc_no.      " offene Reklamation - Fehler
        wet_out-rstgr    = <t_remadv>-rstgr.
        wet_out-statrem  = icon_led_red.
      ENDIF.
    ENDIF.



* Transform int_ui to ext_ui ------------------------------------------------*
    READ TABLE t_crsrf ASSIGNING <t_crsrf>
      WITH KEY int_ui = <s_memidoc>-int_pod.
    IF sy-subrc = 0 AND <t_crsrf> IS ASSIGNED.
      MOVE <t_crsrf>-ext_ui TO wet_out-ext_ui.
    ENDIF.

* IDOC-Status-Ermittlung----------------------------------------------------------------*

    SELECT SINGLE * FROM /adz/hmv_memi INTO ls_hmv_memi WHERE doc_id = <s_memidoc>-doc_id.
    MOVE ls_hmv_memi-dexidocsent     TO wet_out-dexidocsent.
    MOVE ls_hmv_memi-dexidocsentctrl TO wet_out-dexidocsentctrl.
    MOVE ls_hmv_memi-dexidocsendcat  TO wet_out-dexidocsendcat.
    MOVE ls_hmv_memi-dexproc         TO wet_out-dexproc.


* Ermittlung Status INVOIC
    CLEAR: s_hmv_sart, xsart.
    LOOP AT t_hmv_sart INTO s_hmv_sart
      WHERE dexproc         = wet_out-dexproc
        AND serviceanbieter = wet_out-senid
        AND dexidocsent     = wet_out-dexidocsent
        AND dexidocsendcat  = wet_out-dexidocsendcat
        AND datab LE f_tdate
        AND datbi GE f_fdate.
      xsart = s_hmv_sart.
    ENDLOOP.

* IDoc füllen und IDOC-Status setzen

    wet_out-idocin = ls_hmv_memi-idocin.

    IF sy-subrc = 0.
      IF xsart-inv = 'X'.
        CASE xsart-status.
          WHEN ls_hmv_memi-statin.
            wet_out-statin    = icon_led_green.
            wet_out-status_i  = ls_hmv_memi-statin.
          WHEN OTHERS.
            wet_out-statin    = icon_led_red.
            wet_out-status_i  = ls_hmv_memi-statin.
        ENDCASE.
      ENDIF.


    ELSE.
      wet_out-statin    = icon_led_red.
      wet_out-status_i  = ls_hmv_memi-statin.
*      wet_out-statct    = icon_led_red.
*      wet_out-status_c  = ls_hmv_memi-statct.
*      wet_out-sel        = 'X'.
*      wet_out-status     = icon_breakpoint.
    ENDIF.


* Ermittlung Status CONTROL
    CLEAR: s_hmv_sart, xsart.
    LOOP AT t_hmv_sart INTO s_hmv_sart
      WHERE dexproc         = wet_out-dexproc
        AND serviceanbieter = wet_out-senid
        AND dexidocsent     = wet_out-dexidocsentctrl
        AND dexidocsendcat  = wet_out-dexidocsendcat
        AND datab LE f_tdate
        AND datbi GE f_fdate.
      xsart = s_hmv_sart.
    ENDLOOP.

* IDoc füllen und IDOC-Status setzen

    wet_out-idocct    = ls_hmv_memi-idocct.

    IF sy-subrc = 0.
      IF xsart-ctrl = 'X'.
        CASE xsart-status.
          WHEN ls_hmv_memi-statct.
            wet_out-statct    = icon_led_green.
            wet_out-status_c  = ls_hmv_memi-statct.
          WHEN OTHERS.
            wet_out-statct    = icon_led_red.
            wet_out-status_c  = ls_hmv_memi-statct.
        ENDCASE.
      ENDIF.


    ELSE.
*      wet_out-statin    = icon_led_red.
*      wet_out-status_i  = ls_hmv_memi-statin.
      wet_out-statct    = icon_led_red.
      wet_out-status_c  = ls_hmv_memi-statct.
*      wet_out-sel        = 'X'.
*      wet_out-status     = icon_breakpoint.
    ENDIF.


* Ermittlung Mahnsperre setzen

    PERFORM vorschlag_mahnsperre CHANGING wet_out.


    IF if_updte = 'X'.                            " Mahnsperren setzen, wenn gewünscht
      PERFORM set_dunn_lock_memi.
    ENDIF.
    APPEND wet_out TO et_out.
  ENDLOOP.
ENDFUNCTION.
