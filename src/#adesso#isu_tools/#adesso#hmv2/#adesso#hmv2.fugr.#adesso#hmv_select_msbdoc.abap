FUNCTION /adesso/hmv_select_msbdoc.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IS_OUT) TYPE  /ADESSO/HMV_OUT
*"     VALUE(IF_AKONTO) TYPE  CHECKBOX
*"     VALUE(IF_UPDTE) TYPE  CHECKBOX
*"     VALUE(IF_ADUNN) TYPE  CHECKBOX
*"     VALUE(IF_LOCKR) TYPE  MANSP_OLD_KK
*"     VALUE(IF_FDATE) TYPE  SYDATUM
*"     VALUE(IF_TDATE) TYPE  SYDATUM
*"  TABLES
*"      IT_SELCT_MSB STRUCTURE  /ADESSO/HMV_SELCT_MSB
*"      ET_OUT STRUCTURE  /ADESSO/HMV_OUT
*"      IT_SO_AUGST STRUCTURE  RSDSSELOPT
*"      IT_SO_MANSP STRUCTURE  RSDSSELOPT
*"      IT_SO_MAHNS STRUCTURE  RSDSSELOPT
*"----------------------------------------------------------------------

  wa_out       = is_out.
  t_selct_msb[]    = it_selct_msb[].
  t_so_augst[] = it_so_augst[].
  f_lockr      = if_lockr.
  f_fdate      = if_fdate.
  f_tdate      = if_tdate.
  t_so_mansp[] = it_so_mansp[].
  t_so_mahns[] = it_so_mahns[].

  DATA: xsart      TYPE /adesso/hmv_sart,
        ls_hmv_msb TYPE /adesso/hmv_mosb.

* Datenermittlung
  PERFORM assign_constants.
  REFRESH et_out.
  PERFORM select_items_msb.
  PERFORM select_crsrf_msb.
  PERFORM select_remadv.
  PERFORM select_augst_msbdoc.

* Customizing IDoc-Status
  REFRESH t_hmv_sart.
  SELECT * FROM /adesso/hmv_sart
     INTO TABLE t_hmv_sart.


  LOOP AT t_fkkop_msb ASSIGNING <t_fkkop_msb>.

    CLEAR: wet_out.
    wet_out = wa_out.

    MOVE-CORRESPONDING <t_fkkop_msb> TO wet_out.

    MOVE <t_fkkop_msb>-crossrefno TO wet_out-ownrf.
    MOVE <t_fkkop_msb>-intui TO wet_out-int_ui.

* Mahnsperren und Mahnhistorie lesen
    PERFORM get_locks_bel_msb.
    PERFORM get_manst_bel_msb.

    CHECK wet_out-mansp IN t_so_mansp.
    CHECK wet_out-mahns IN t_so_mahns.

* Ausgleichsstatus Aggr.Beleg
    READ TABLE t_bcbln ASSIGNING <t_bcbln>
      WITH KEY opbel = wet_out-bcbln
      BINARY SEARCH.
    IF sy-subrc = 0 AND <t_bcbln> IS ASSIGNED.
      wet_out-bcaug      = <t_bcbln>-augst.
      wet_out-doc_status = <t_bcbln>-augst.   "Felder Ausgl.St. und MEMI-Status zusammenführen
    ENDIF.



    SORT t_remadv BY int_inv_doc_no DESCENDING.

*-------------------- Pos. REMADV --------------------*
    READ TABLE t_remadv ASSIGNING <t_remadv>
    WITH KEY own_invoice_no = wet_out-ownrf
               invoice_type = c_invoice_type12         "'012'.
         ."    BINARY SEARCH.
    IF sy-subrc = 0 AND <t_remadv> IS ASSIGNED.
      wet_out-payno = <t_remadv>-int_inv_doc_no.
      wet_out-payst = <t_remadv>-inv_doc_status.
      IF <t_remadv>-inv_doc_status = c_invoice_paymst.  "'13'.
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
                 invoice_type = c_invoice_type13
      ."       BINARY SEARCH.
    IF sy-subrc = 0 AND <t_remadv> IS ASSIGNED.
      IF <t_remadv>-invoice_status = c_invoice_status_03.  "03 - beeendete Reklamation - Warnung
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


** IDOC-Status-Ermittlung

    SELECT SINGLE * FROM /adesso/hmv_mosb INTO ls_hmv_msb WHERE invdocno = <t_fkkop_msb>-opbel.
    MOVE ls_hmv_msb-dexidocsent     TO wet_out-dexidocsent.
    MOVE ls_hmv_msb-dexidocsentctrl TO wet_out-dexidocsentctrl.
    MOVE ls_hmv_msb-dexidocsendcat  TO wet_out-dexidocsendcat.
    MOVE ls_hmv_msb-dexproc         TO wet_out-dexproc.

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

    wet_out-idocin = ls_hmv_msb-idocin.

    IF sy-subrc = 0.
      IF xsart-inv = 'X'.
        CASE xsart-status.
          WHEN ls_hmv_msb-statin.
            wet_out-statin    = icon_led_green.
            wet_out-status_i  = ls_hmv_msb-statin.
          WHEN OTHERS.
            wet_out-statin    = icon_led_red.
            wet_out-status_i  = ls_hmv_msb-statin.
        ENDCASE.
      ENDIF.

    ELSE.
      wet_out-statin    = icon_led_red.
      wet_out-status_i  = ls_hmv_msb-statin.
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

    wet_out-idocct    = ls_hmv_msb-idocct.

    IF sy-subrc = 0.
      IF xsart-ctrl = 'X'.
        CASE xsart-status.
          WHEN ls_hmv_msb-statct.
            wet_out-statct    = icon_led_green.
            wet_out-status_c  = ls_hmv_msb-statct.
          WHEN OTHERS.
            wet_out-statct    = icon_led_red.
            wet_out-status_c  = ls_hmv_msb-statct.
        ENDCASE.
      ENDIF.


    ELSE.
      wet_out-statct    = icon_led_red.
      wet_out-status_c  = ls_hmv_msb-statct.
    ENDIF.


    PERFORM vorschlag_mahnsperre CHANGING wet_out.

    APPEND wet_out TO et_out.
  ENDLOOP.




ENDFUNCTION.
