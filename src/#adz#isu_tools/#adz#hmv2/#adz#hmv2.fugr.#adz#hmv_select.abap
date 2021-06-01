FUNCTION /ADZ/HMV_SELECT.
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
*"      IT_SELCT STRUCTURE  /ADZ/HMV_SELCT
*"      ET_OUT STRUCTURE  /ADZ/HMV_S_OUT_DUNNING
*"      IT_SO_AUGST STRUCTURE  RSDSSELOPT
*"      IT_SO_MANSP STRUCTURE  RSDSSELOPT
*"      IT_SO_MAHNS STRUCTURE  RSDSSELOPT
*"----------------------------------------------------------------------

  wa_out       = is_out.
  t_selct[]    = it_selct[].
  t_so_augst[] = it_so_augst[].
  f_lockr      = if_lockr.
  f_fdate      = if_fdate.
  f_tdate      = if_tdate.
  t_so_mansp[] = it_so_mansp[].
  t_so_mahns[] = it_so_mahns[].

  DATA: xsart       TYPE /adz/hmv_sart,
        ls_hmv_dfkk TYPE /adz/hmv_dfkk.

* Datenermittlung

  ms_constants = /adz/cl_hmv_constants=>get_constants( ).
  REFRESH et_out.
  PERFORM select_items.
  PERFORM select_crsrf.
  PERFORM select_remadv.
  PERFORM select_augst_bcbln.
  PERFORM select_inv_docref.

  IF if_akonto IS NOT INITIAL.
    PERFORM select_akonto.
    LOOP AT t_akonto ASSIGNING <t_akonto>.
      CLEAR wa_fkkop.
      MOVE-CORRESPONDING <t_akonto> TO wa_fkkop.
      wa_fkkop-akonto = icon_businav_value_chain.
      wa_fkkop-status = icon_led_red.
      wet_out         = wa_out.
      MOVE-CORRESPONDING wa_fkkop TO wet_out.
      CHECK wet_out-mansp IN t_so_mansp.
      CHECK wet_out-mahns IN t_so_mahns.
      APPEND wet_out TO et_out.
    ENDLOOP.
  ENDIF.

* Customizing IDoc-Status
  REFRESH t_hmv_sart.
  SELECT * FROM /adz/hmv_sart
     INTO TABLE t_hmv_sart.

  LOOP AT t_fkkop ASSIGNING <t_fkkop>.
    CLEAR: wet_out.
    wet_out = wa_out.
    DATA(lr_out) = REF #( wet_out ).

    MOVE-CORRESPONDING <t_fkkop> TO wet_out.

* Mahnsperren und Mahnhistorie lesen
    PERFORM get_locks_bel.
    PERFORM get_manst_bel.

    CHECK wet_out-mansp IN t_so_mansp.
    CHECK wet_out-mahns IN t_so_mahns.

*Verzinsung lesen
    PERFORM get_interest.

* Ausgleichsstatus Aggr.Beleg
    READ TABLE t_bcbln ASSIGNING <t_bcbln>
      WITH KEY opbel = wet_out-bcbln
      BINARY SEARCH.
    IF sy-subrc = 0 AND <t_bcbln> IS ASSIGNED.
      wet_out-bcaug      = <t_bcbln>-augst.
* <<< ET_20160303
      wet_out-doc_status = <t_bcbln>-augst.   "Felder Ausgl.St. und MEMI-Status zusammenführen
* >>> ET_20160303
    ENDIF.

    IF <t_fkkop>-akonto = ' '.                " Informationen lesen für Nicht-Akontobelege
      READ TABLE t_crsrf ASSIGNING <t_crsrf>
        WITH KEY int_crossrefno = <t_fkkop>-crsrf
        BINARY SEARCH.
      IF sy-subrc = 0 AND <t_crsrf> IS ASSIGNED.
        wet_out-ownrf  = <t_crsrf>-crossrefno.
        wet_out-ext_ui = <t_crsrf>-ext_ui.
      ENDIF.

      UNASSIGN <t_remadv>.
* Pos.REMADV ---------------------------------------------------*
      READ TABLE t_remadv ASSIGNING <t_remadv>
        WITH KEY own_invoice_no = wet_out-ownrf
                 invoice_type   = ms_constants-c_invoice_paym              "'002'.
         ."        BINARY SEARCH.
      IF sy-subrc = 0 AND <t_remadv> IS ASSIGNED.
        wet_out-payno      = <t_remadv>-int_inv_doc_no.
        wet_out-payst      = <t_remadv>-inv_doc_status.
*        wet_out-status     = icon_breakpoint.
*        wet_out-sel        = 'X'.
        IF <t_remadv>-inv_doc_status = ms_constants-c_invoice_paymst.   "'13'.
          wet_out-payst_icon = icon_led_green.              " Überführte Zahlungsavise --> grün
        ELSE.
          wet_out-payst_icon = icon_led_yellow.             " sonstige Zahlungsavise --> gelb
        ENDIF.
      ENDIF.
      UNASSIGN <t_remadv>.

* Neg.REMADV ------------------------------------------------------*
      READ TABLE t_remadv ASSIGNING <t_remadv>
        WITH KEY own_invoice_no = wet_out-ownrf
                 invoice_type   = ms_constants-c_invoice_type4              "'004'.
            ."     BINARY SEARCH.
      IF sy-subrc = 0 AND <t_remadv> IS ASSIGNED.
        IF <t_remadv>-invoice_status = ms_constants-c_invoice_status_03.    "'03' - abgeschlossene Reklamation nur Warunung
          wet_out-docno   = <t_remadv>-int_inv_doc_no.
          wet_out-statrem = icon_led_yellow.
          wet_out-rstgr   = <t_remadv>-rstgr.
          wet_out-to_lock  = icon_led_yellow.
        ELSE.
          wet_out-docno   = <t_remadv>-int_inv_doc_no.
          wet_out-statrem = icon_led_red.
          wet_out-rstgr   = <t_remadv>-rstgr.
*          wet_out-status  = icon_breakpoint.
*          wet_out-sel     = 'X'.
        ENDIF.
      ENDIF.
      DATA lrt_remadv type ref to tty_remadv.
      if t_remadv is not INITIAL.
        lrt_remadv = ref #( t_remadv ).
        perform fill_remadv
          USING  wet_out-ownrf
                 lrt_remadv
          CHANGING    lr_out.
      endif.

* IDOC-Status-Ermittlung

      SELECT SINGLE * FROM /adz/hmv_dfkk INTO ls_hmv_dfkk
        WHERE opbel = <t_fkkop>-opbel
        AND   opupw = <t_fkkop>-opupw
        AND   opupk = <t_fkkop>-opupk
        AND   opupz = <t_fkkop>-opupz
        AND   thinr = <t_fkkop>-thinr.

      MOVE ls_hmv_dfkk-dexidocsent     TO wet_out-dexidocsent.
      MOVE ls_hmv_dfkk-dexidocsentctrl TO wet_out-dexidocsentctrl.
      MOVE ls_hmv_dfkk-dexidocsendcat  TO wet_out-dexidocsendcat.
      MOVE ls_hmv_dfkk-dexproc         TO wet_out-dexproc.



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

      wet_out-idocin = ls_hmv_dfkk-idocin.

      IF sy-subrc = 0.
        IF xsart-inv = 'X'.
          CASE xsart-status.
            WHEN ls_hmv_dfkk-statin.
              wet_out-statin    = icon_led_green.
              wet_out-status_i  = ls_hmv_dfkk-statin.
            WHEN OTHERS.
              wet_out-statin    = icon_led_red.
              wet_out-status_i  = ls_hmv_dfkk-statin.
          ENDCASE.
        ENDIF.


      ELSE.
        wet_out-statin    = icon_led_red.
        wet_out-status_i  = ls_hmv_dfkk-statin.
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

      wet_out-idocct    = ls_hmv_dfkk-idocct.

      IF sy-subrc = 0.
        IF xsart-ctrl = 'X'.
          CASE xsart-status.
            WHEN ls_hmv_dfkk-statct.
              wet_out-statct    = icon_led_green.
              wet_out-status_c  = ls_hmv_dfkk-statct.
            WHEN OTHERS.
              wet_out-statct    = icon_led_red.
              wet_out-status_c  = ls_hmv_dfkk-statct.
          ENDCASE.
        ENDIF.


      ELSE.
*      wet_out-statin    = icon_led_red.
*      wet_out-status_i  = ls_hmv_memi-statin.
        wet_out-statct    = icon_led_red.
        wet_out-status_c  = ls_hmv_dfkk-statct.
*      wet_out-sel        = 'X'.
*      wet_out-status     = icon_breakpoint.
      ENDIF.


* Ermittlung Mahnsperre setzen

      PERFORM vorschlag_mahnsperre CHANGING wet_out.



      IF if_adunn IS NOT INITIAL. " Bei Selektion Akonto - alle Posten von Mahnung ausschließen
        READ TABLE t_akonto TRANSPORTING NO FIELDS
                   WITH KEY bukrs = <t_fkkop>-bukrs
                            gpart = <t_fkkop>-gpart
                            vkont = <t_fkkop>-vkont
                   BINARY SEARCH.
        IF sy-subrc = 0.
          wet_out-akonto = icon_led_red.
          wet_out-to_lock = icon_breakpoint.
          wet_out-sel = 'X'.
        ENDIF.
      ENDIF.
    ENDIF.

    IF wet_out-augst = '9'.           " Ausgeglichene Posten nicht zur Mahnung vorsehen
      CLEAR wet_out-akonto.
      wet_out-status = icon_led_green.
      wet_out-sel  = ' '.
    ENDIF.

    IF if_updte = 'X'.                " Mahnsperre setzen, wenn gewünscht
      PERFORM set_dunn_lock.
    ENDIF.
    APPEND wet_out TO et_out.
  ENDLOOP.
ENDFUNCTION.
