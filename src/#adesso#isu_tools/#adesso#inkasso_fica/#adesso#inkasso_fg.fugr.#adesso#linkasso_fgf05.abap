*----------------------------------------------------------------------*
***INCLUDE /ADESSO/LINKASSO_FGF05.
*----------------------------------------------------------------------*
INCLUDE lfkcif01.

*&---------------------------------------------------------------------*
*&      Form  ADESSO_CREATE_RANGE_AGSTA
*&---------------------------------------------------------------------*
*       Erzeugen Range für Abgabestatus
*----------------------------------------------------------------------*
FORM adesso_create_range_agsta
                  TABLES p_ht_agsta_range STRUCTURE ht_agsta_range
                  USING  p_fkkcollinfo TYPE fkkcollinfo.

* Inkassobüro immer über alles Informieren
  CLEAR: p_ht_agsta_range[], p_ht_agsta_range.
  p_ht_agsta_range-sign   = 'I'.
  p_ht_agsta_range-option = 'EQ'.
  CLEAR: p_ht_agsta_range-high.

  p_ht_agsta_range-low = c_released.                "01
  APPEND p_ht_agsta_range.
  p_ht_agsta_range-low = c_receivable_submitted.    "02
  APPEND p_ht_agsta_range.
  p_ht_agsta_range-low = c_receivable_paid.         "03
  APPEND p_ht_agsta_range.
  p_ht_agsta_range-low = c_receivable_part_paid.    "04
  APPEND p_ht_agsta_range.
  p_ht_agsta_range-low = c_receivable_cancelled.    "05
  APPEND p_ht_agsta_range.
  p_ht_agsta_range-low = c_receivable_write_off.    "06
  APPEND p_ht_agsta_range.
  p_ht_agsta_range-low = c_agsta_cu_t-erfolglos.    "07
  APPEND p_ht_agsta_range.
  p_ht_agsta_range-low = c_agsta_t-erfolglos.       "08
  APPEND p_ht_agsta_range.
  p_ht_agsta_range-low = c_receivable_recalled.     "09
  APPEND p_ht_agsta_range.
  p_ht_agsta_range-low = c_costumer_directly_paid.  "10
  APPEND p_ht_agsta_range.
  p_ht_agsta_range-low = c_costumer_partally_paid.  "11
  APPEND p_ht_agsta_range.
  p_ht_agsta_range-low = c_full_clearing.           "12
  APPEND p_ht_agsta_range.
  p_ht_agsta_range-low = c_partial_clearing.        "13
  APPEND p_ht_agsta_range.
  p_ht_agsta_range-low = c_receivable_part_write_off. "15
  APPEND p_ht_agsta_range.

* adesso Stati
*  p_ht_agsta_range-low = c_direct_wroff.            "20
*  APPEND p_ht_agsta_range.
  p_ht_agsta_range-low = c_sell.                    "30
  APPEND p_ht_agsta_range.
  p_ht_agsta_range-low = c_decl_sell_wroff.         "31
  APPEND p_ht_agsta_range.
  p_ht_agsta_range-low = c_decl_sell_rcall.         "32
  APPEND p_ht_agsta_range.


ENDFORM.                    " adesso_create_range_agsta

***&---------------------------------------------------------------------*
***&      Form  adesso_infos_pro_inkgp
***&---------------------------------------------------------------------*
FORM adesso_infos_pro_inkgp  TABLES   t_fkkcollh STRUCTURE dfkkcollh
                             USING    i_basics TYPE fkk_mad_basics
                                      wt_fkkcoli_log STRUCTURE dfkkcoli_log
                                      h_intnr_c TYPE intnr_i_kk
                                      h_lfd_p LIKE dfkkcollp_ip_w-lfnum
                                      h_lfd_r LIKE dfkkcollp_ir_w-lfnum.

  DATA:
    h_collh09      LIKE dfkkcollh,
    w_fkkcollh_alt LIKE dfkkcollh,
    h_betrag       TYPE betrz_kk,
    h_ninkb        TYPE ninkb_kk,
    x_delivered    TYPE c,
    h_logtb        TYPE c,
    h_herkf        TYPE herkf_kk,
    h_logkz        TYPE logkz_kk,
    w_collh_last   LIKE dfkkcollh,
    h_collh_next   LIKE dfkkcollh,
    h_tabix        LIKE sy-tabix,
    h_xragl        TYPE xragl_kk,
    h_augbl        TYPE augbl_kk,
    h_xninkb       TYPE boole-boole,
    h_xstorno      TYPE boole-boole.

  DATA: ls_womon TYPE /adesso/wo_mon.

*>>> Note 1798474
  TYPES: rsds_selopt_t LIKE rsdsselopt OCCURS 0.
  TYPES: BEGIN OF rsds_frange,
           fieldname LIKE rsdstabs-prim_fname,
           selopt_t  TYPE rsds_selopt_t,
         END OF rsds_frange.
  TYPES: rsds_frange_t TYPE rsds_frange OCCURS 0.
  DATA: it_ranges LIKE rsdsselopt OCCURS 0 WITH HEADER LINE,
        lt_fkkko  LIKE fkkko      OCCURS 0 WITH HEADER LINE,
        it_sel    TYPE rsds_frange_t       WITH HEADER LINE.
*<<< Note 1798474

* Zusatzmerkmal --> Reine Verkaufsdatei erstellen
* dann alle anderen Selektionen löschen
  IF i_basics-macat IS NOT INITIAL.
    CLEAR: g_fkkcollinfo-xcpart.
    CLEAR: g_fkkcollinfo-xausg.
    CLEAR: g_fkkcollinfo-xback.
    CLEAR: g_fkkcollinfo-xrever.
    CLEAR: g_fkkcollinfo-xreclr.
    CLEAR: g_fkkcollinfo-xretrn.
    CLEAR: g_fkkcollinfo-xstorno.
    CLEAR: g_fkkcollinfo-xwroff.
  ELSE.
    CHECK g_fkkcollinfo-xausg   = c_marked OR
          g_fkkcollinfo-xback   = c_marked OR
          g_fkkcollinfo-xrever  = c_marked OR
          g_fkkcollinfo-xreclr  = c_marked OR
          g_fkkcollinfo-xretrn  = c_marked OR
          g_fkkcollinfo-xstorno = c_marked OR
          g_fkkcollinfo-xwroff  = c_marked.
  ENDIF.

*call event 5051 to fill specific customer field for the file
*header to be passed to event 5052
  IF g_fkkcollinfo-sumknz IS INITIAL.
    READ TABLE lt_fkkcollh_i INTO t_fkkcollh_i
               WITH KEY satztyp = c_header
                        inkgp   = t_fkkcollh-inkgp.
    IF sy-subrc <> 0.
      CLEAR t_fkkcollh_i.
      t_fkkcollh_i-satztyp = c_header.
      t_fkkcollh_i-inkgp   = t_fkkcollh-inkgp.
      t_fkkcollh_i-datum   = sy-datum.
      LOOP AT t_tfkfbc_5051.
        CALL FUNCTION t_tfkfbc_5051-funcc
          EXPORTING
            i_fkkcollh_i = t_fkkcollh_i
          CHANGING
            c_fkkcollh_i = t_fkkcollh_i.
      ENDLOOP.
      APPEND t_fkkcollh_i TO lt_fkkcollh_i.
      SET EXTENDED CHECK OFF.
      IF 1 = 2. CALL FUNCTION 'FKK_SAMPLE_5051'. ENDIF.
      SET EXTENDED CHECK ON.
    ENDIF.
  ENDIF.

* Lesen letzte Rückrufposition aus Historie
  PERFORM read_last_recall TABLES   t_fkkcollh
                           CHANGING h_collh09.

* Verarbeiten noch nicht behandelter Inkassopositionen
  CLEAR: w_fkkcollh_alt.
  CLEAR: h_betrag, h_ninkb, h_xninkb, h_xstorno.
  CLEAR: x_delivered.
  CLEAR: w_collh_last.
  REFRESH: t_stor.

  LOOP AT t_fkkcollh.      " Historie

    CASE  t_fkkcollh-agsta.

      WHEN space    .                                   " space
        CLEAR x_delivered.
        w_collh_last   = t_fkkcollh.

      WHEN c_released.                                      " '01'
        CLEAR x_delivered.
        w_collh_last   = t_fkkcollh.

      WHEN c_receivable_submitted.                          " '02'
        IF w_fkkcollh_alt-agsta EQ c_receivable_part_paid    OR
           w_fkkcollh_alt-agsta EQ c_receivable_paid         OR
           w_fkkcollh_alt-agsta EQ c_costumer_directly_paid  OR
           w_fkkcollh_alt-agsta EQ c_costumer_partally_paid  OR
           w_fkkcollh_alt-agsta EQ c_full_clearing           OR
           w_fkkcollh_alt-agsta EQ c_receivable_cancelled    OR
           w_fkkcollh_alt-agsta EQ c_receivable_write_off    OR
           w_fkkcollh_alt-agsta EQ c_receivable_part_write_off OR
           w_fkkcollh_alt-agsta EQ c_partial_clearing.

          IF w_fkkcollh_alt-agsta EQ c_receivable_cancelled OR
             w_fkkcollh_alt-agsta EQ c_receivable_write_off.
            h_betrag = t_fkkcollh-betrw.
          ELSE.
            h_betrag = t_fkkcollh-betrz - w_fkkcollh_alt-betrz.
            IF h_betrag EQ 0.
              h_betrag = w_fkkcollh_alt-ninkb - t_fkkcollh-ninkb. "note 2461170
            ENDIF.
          ENDIF.

        ELSE.
          x_delivered = true.
          w_collh_last = t_fkkcollh.
          CONTINUE.
        ENDIF.

*-------- Storno     {'10'/'11'/'12'/'13'} --> '02'
        IF t_fkkcollh-lfdnr > wt_fkkcoli_log-lfdnr.

*         Liegt ein Storno-Fall vor, d.h. war der Abgabestatus des
*         vorhergenhenden Postens '10', '11', '12', oder '13' ?
          IF w_fkkcollh_alt-agsta EQ c_costumer_directly_paid  OR
             w_fkkcollh_alt-agsta EQ c_costumer_partally_paid  OR
             w_fkkcollh_alt-agsta EQ c_full_clearing           OR
             w_fkkcollh_alt-agsta EQ c_receivable_cancelled    OR
             w_fkkcollh_alt-agsta EQ c_receivable_write_off    OR
             w_fkkcollh_alt-agsta EQ c_receivable_part_write_off OR
             w_fkkcollh_alt-agsta EQ c_partial_clearing.


            IF t_fkkcollh-lfdnr >= h_collh09-lfdnr.

*              IF g_fkkcollinfo-xwroff IS INITIAL.
*                h_logkz = true.
*              ELSE.
*                CLEAR h_logkz.
*              ENDIF.

              IF NOT t_fkkcollh-storb IS INITIAL.
                CLEAR h_herkf.
                SELECT SINGLE herkf
                       INTO   h_herkf
                       FROM   dfkkko
                       WHERE  opbel EQ t_fkkcollh-storb.

*>>> Note 1798474
                IF sy-subrc <> 0.
                  REFRESH: it_ranges, it_sel, lt_fkkko.
                  it_ranges-sign = 'I'.
                  it_ranges-option = 'EQ'.
                  it_ranges-low = t_fkkcollh-storb.
                  APPEND it_ranges.
                  it_sel-selopt_t[] = it_ranges[].
                  it_sel-fieldname = 'OPBEL'.
                  APPEND it_sel.

                  CALL FUNCTION 'FKK_GET_ARC_DOC'
                    TABLES
                      it_sel        = it_sel
                      t_fkkko       = lt_fkkko
                    EXCEPTIONS
                      error_message = 0.
                  READ TABLE lt_fkkko INDEX 1.
                  IF sy-subrc = 0.
                    MOVE lt_fkkko-herkf TO h_herkf.
                  ENDIF.
                ENDIF.
*<<< Note 1798474

                IF  ( ( h_herkf EQ '08' )  AND
                      ( NOT g_fkkcollinfo-xretrn IS INITIAL ) )

                 OR ( ( h_herkf EQ '09' OR h_herkf EQ '39'  ) AND
                      ( NOT g_fkkcollinfo-xreclr IS INITIAL ) )

                 OR ( ( NOT g_fkkcollinfo-xstorno IS INITIAL ) AND
                    ( ( h_herkf EQ '02' ) OR
                      ( ( h_herkf NE '08' ) AND
                        ( h_herkf NE '09' ) AND
                        ( h_herkf NE '39' ) ) ) ) .

                  PERFORM info_storno  USING    c_storno
                                                i_basics
                                                h_intnr_c
                                                t_fkkcollh
                                                h_lfd_p
                                                h_betrag
                                                h_logkz.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
        x_delivered = true.
        w_fkkcollh_alt = t_fkkcollh.
        w_collh_last   = t_fkkcollh.


      WHEN c_receivable_cancelled.                          " '05'

        h_tabix = sy-tabix + 1.
        READ TABLE t_fkkcollh INDEX h_tabix
                              INTO h_collh_next TRANSPORTING agsta.
        IF sy-subrc EQ 0 AND h_collh_next-agsta EQ space.
          CONTINUE.
        ENDIF.
*------ Abgegebene Forderung storniert '05'
        IF x_delivered EQ true.
          IF t_fkkcollh-lfdnr > wt_fkkcoli_log-lfdnr.
            IF NOT g_fkkcollinfo-xrever IS INITIAL.
              IF t_fkkcollh-lfdnr >= h_collh09-lfdnr.
*             Melden Stornierung abgegebener Forderungen an Inkassobüro
                PERFORM info_storno USING    c_cancelled_receivable
                                             i_basics
                                             h_intnr_c
                                             t_fkkcollh
                                             h_lfd_p
                                             h_betrag
                                             space.
              ELSE.
                PERFORM info_storno USING    c_cancelled_receivable
                                             i_basics
                                             h_intnr_c
                                             t_fkkcollh
                                             h_lfd_p
                                             h_betrag
                                             c_only_log.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
        CLEAR x_delivered.
        w_fkkcollh_alt = t_fkkcollh.
        w_collh_last   = t_fkkcollh.
        CONTINUE.


      WHEN c_receivable_write_off OR c_receivable_part_write_off. "06/15
*           c_agsta_cu_t-erfolglos OR c_agsta_t-erfolglos.   "07/08
*------ Forderung ausgebucht / teilausgebucht '06' / '15'
        IF x_delivered EQ true.
          h_ninkb = t_fkkcollh-ninkb - w_fkkcollh_alt-ninkb. "Note 1410415

          "note 2765757: status 15 is also possible in case of reverse
          "              of payment/clearing ( '07' --> '15')
          CLEAR h_xstorno.
          IF w_fkkcollh_alt-agsta EQ c_agsta_cu_t-erfolglos
              AND t_fkkcollh-storb IS NOT INITIAL.
            h_betrag  = t_fkkcollh-betrz - w_fkkcollh_alt-betrz.
            h_xstorno = true.
          ENDIF.

          IF t_fkkcollh-lfdnr > wt_fkkcoli_log-lfdnr.

*            Info Verkauf / Ablehnung Verkauf bei Ausbuchung
            SELECT SINGLE * FROM /adesso/wo_mon
                   INTO ls_womon
                   WHERE opbel = t_fkkcollh-opbel
                   AND   inkps = t_fkkcollh-inkps.

            IF sy-subrc = 0.
              CASE ls_womon-agsta.

                WHEN '20'.
                  w_collh_last   = t_fkkcollh.
                  CONTINUE.

                WHEN '30' OR '31'.

                  IF NOT i_basics-macat IS INITIAL.
*               Verkauf melden und registrieren.
                    PERFORM adesso_info_sell_decl
                            USING i_basics
                                  h_intnr_c
                                  t_fkkcollh
                                  h_lfd_r
                                  w_collh_last
                                  wt_fkkcoli_log
                                  ls_womon-agsta.
                    CLEAR x_delivered.
                  ENDIF.

                  w_collh_last   = t_fkkcollh.
                  CONTINUE.
              ENDCASE.
            ENDIF.

            IF h_xstorno IS INITIAL.
              IF NOT g_fkkcollinfo-xwroff IS INITIAL.
                IF NOT h_ninkb IS INITIAL.               " NOTE 1429275
                  h_collh_next-ninkb = t_fkkcollh-ninkb. " NOTE 1429275
                  t_fkkcollh-ninkb = h_ninkb.            " NOTE 1429275
                ENDIF.                                   " NOTE 1429275
                IF t_fkkcollh-lfdnr >= h_collh09-lfdnr.
*               Melden Stornierung abgegebener Forderungen an Inkassobüro
                  PERFORM info_storno USING    c_write_off
                                               i_basics
                                               h_intnr_c
                                               t_fkkcollh
                                               h_lfd_p
                                               h_betrag
                                               space.
                ELSE.
                  PERFORM info_storno USING    c_write_off
                                               i_basics
                                               h_intnr_c
                                               t_fkkcollh
                                               h_lfd_p
                                               h_betrag
                                               c_only_log.
                ENDIF.
                t_fkkcollh-ninkb = h_collh_next-ninkb. " NOTE 1429275
              ELSE.

                IF NOT t_fkkcollh-augbl IS INITIAL.
                  CLEAR: h_xragl, h_augbl.
*   check if the clearing document has been reversed or resetted
                  SELECT SINGLE augbl xragl INTO  (h_augbl, h_xragl)
                                      FROM  dfkkop
                                      WHERE opbel EQ t_fkkcollh-augbl.
                  IF NOT h_xragl IS INITIAL.
                    MOVE h_augbl TO t_stor.
                    APPEND t_stor.
                  ENDIF.

                ENDIF.
              ENDIF.
              "note 2765757
            ELSE.
              CLEAR h_herkf.
              SELECT SINGLE herkf
                     INTO   h_herkf
                     FROM   dfkkko
                     WHERE  opbel EQ t_fkkcollh-storb.

              IF  ( ( h_herkf EQ '08' )  AND
                      ( NOT g_fkkcollinfo-xretrn IS INITIAL ) )

                 OR ( ( h_herkf EQ '09' OR h_herkf EQ '39'  ) AND
                      ( NOT g_fkkcollinfo-xreclr IS INITIAL ) )

                 OR ( ( NOT g_fkkcollinfo-xstorno IS INITIAL ) AND
                    ( ( h_herkf EQ '02' ) OR
                      ( ( h_herkf NE '08' ) AND
                        ( h_herkf NE '09' ) AND
                        ( h_herkf NE '39' ) ) ) ) .
                IF t_fkkcollh-lfdnr >= h_collh09-lfdnr.
                  PERFORM info_storno USING  c_storno
                                             i_basics
                                             h_intnr_c
                                             t_fkkcollh
                                             h_lfd_p
                                             h_betrag
                                             space.
                ELSE.
                  PERFORM info_storno USING c_write_off
                                            i_basics
                                            h_intnr_c
                                            t_fkkcollh
                                            h_lfd_p
                                            h_betrag
                                            c_only_log.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
*        CLEAR x_delivered.
        w_fkkcollh_alt = t_fkkcollh.
        w_collh_last   = t_fkkcollh.
        CONTINUE.


      WHEN c_receivable_recalled.                           " '09'

        h_tabix = sy-tabix + 1.
        READ TABLE t_fkkcollh INDEX h_tabix
                              INTO h_collh_next TRANSPORTING agsta.
        IF sy-subrc EQ 0 AND h_collh_next-agsta EQ space.
*        ( h_collh_next-agsta eq space or
*          h_collh_next-agsta eq c_released ).
          CONTINUE.
        ENDIF.

*-------- Rückruf '09'
        IF x_delivered EQ true.
          IF t_fkkcollh-lfdnr > wt_fkkcoli_log-lfdnr.

*           Info Ablehnung Verkauf bei Rückruf
            IF t_fkkcollh-xsold = 'X'.
              IF NOT i_basics-macat IS INITIAL.
*               Verkauf melden und registrieren.
                PERFORM adesso_info_sell_decl
                        USING i_basics
                              h_intnr_c
                              t_fkkcollh
                              h_lfd_r
                              w_collh_last
                              wt_fkkcoli_log
                              '09'.
                CLEAR x_delivered.
              ENDIF.

              w_collh_last   = t_fkkcollh.
              CONTINUE.

            ELSE.
              IF NOT g_fkkcollinfo-xback IS INITIAL.
                IF t_fkkcollh-lfdnr >= h_collh09-lfdnr.
*               Rückruf an Inkassobüro melden und registrieren.
                  PERFORM info_recall  USING    i_basics
                                                h_intnr_c
                                                t_fkkcollh
                                                h_lfd_r
                                                w_collh_last
                                                wt_fkkcoli_log.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.

        IF t_fkkcollh-lfdnr >= h_collh09-lfdnr OR
          h_collh09-lfdnr IS INITIAL.
          CLEAR x_delivered.
        ENDIF.
        w_collh_last   = t_fkkcollh.
        CONTINUE.

*-------- Zahlung / Teilzahlung direkt vom Kunden        {'10'/'11'}
      WHEN c_costumer_directly_paid OR c_costumer_partally_paid.

        IF x_delivered EQ true.
          h_betrag = t_fkkcollh-betrz - w_fkkcollh_alt-betrz.

          " note 2765757: status 11 is also possible in case of reverse
          "              of write off ( '07' --> '11')
          CLEAR h_xninkb.
          IF w_fkkcollh_alt-agsta EQ c_agsta_cu_t-erfolglos
              AND h_betrag = 0.  "for safety
            h_betrag = t_fkkcollh-ninkb - w_fkkcollh_alt-ninkb.
            h_xninkb = true.
          ENDIF.

          IF t_fkkcollh-lfdnr > wt_fkkcoli_log-lfdnr.
            IF h_betrag < 0 AND t_fkkcollh-betrw > 0 .
*           Storno
              "note 2765757 reverse of write-off needs to have positive sign
              IF h_xninkb = true.
                h_betrag = - h_betrag.
              ENDIF.
              IF t_fkkcollh-lfdnr >= h_collh09-lfdnr.
*                Wurde der vorherigr Posten bereits an Inkassobüro
*                gemeldet(d.h. existiert Posten schon in der Log-Tab?
*                PERFORM check_logtable USING    w_fkkcollh_alt
*                                       CHANGING h_logtb
*                                                h_logkz.

*               Möchte der Sachbearbeiter das Inkassobüro über die
*               Stornierung informieren?
                IF NOT g_fkkcollinfo-xstorno IS INITIAL.
*                 Ja: Stornierung an Inkassobüro melden und
*                 in Log-Tabelle registrieren.
                  IF NOT t_fkkcollh-storb IS INITIAL.
                    PERFORM info_storno  USING    c_storno
                                                  i_basics
                                                  h_intnr_c
                                                  t_fkkcollh
                                                  h_lfd_p
                                                  h_betrag
                                                  space.
                  ENDIF.
                ELSE.
*                 Nein: Stornierung nur in Log-Tabelle registrieren
                  IF NOT t_fkkcollh-storb IS INITIAL.
                    PERFORM info_storno  USING    c_storno
                                                  i_basics
                                                  h_intnr_c
                                                  t_fkkcollh
                                                  h_lfd_p
                                                  h_betrag
                                                  c_only_log.
                  ENDIF.
                ENDIF.
              ENDIF.

            ELSE.

*-------- Zahlung bzw. Teilzahlung direkt
              IF NOT g_fkkcollinfo-xausg IS INITIAL.
                IF t_fkkcollh-lfdnr >= h_collh09-lfdnr.
*                 Zahlung an Inkassobüro melden und registrieren
                  PERFORM info_payment USING    c_payment
                                                i_basics
                                                h_intnr_c
                                                t_fkkcollh
                                                h_lfd_p
                                                h_betrag
                                                space.
                ELSE.
*                 Zahlung in Log-Tabelle registrieren
                  PERFORM info_payment USING    c_payment
                                                i_basics
                                                h_intnr_c
                                                t_fkkcollh
                                                h_lfd_p
                                                h_betrag
                                                c_only_log.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
        w_fkkcollh_alt = t_fkkcollh.
        w_collh_last   = t_fkkcollh.


      WHEN c_receivable_paid OR c_receivable_part_paid.     " '03'/'04'

        IF x_delivered EQ true.
          h_betrag = t_fkkcollh-betrz - w_fkkcollh_alt-betrz.

          " note 2765757: status 04 is also possible in case of reverse
          "              of write off ( '08' --> '04')
          CLEAR h_xninkb.
          IF w_fkkcollh_alt-agsta EQ c_agsta_t-erfolglos
              AND h_betrag = 0.  "for safety
            h_betrag = t_fkkcollh-ninkb - w_fkkcollh_alt-ninkb.
            h_xninkb = true.
          ENDIF.

          IF t_fkkcollh-lfdnr > wt_fkkcoli_log-lfdnr.
* Storno case
            IF h_betrag < 0 AND t_fkkcollh-betrw > 0 .
              "note 2765757 reverse of write-off needs to have positive sign
              IF h_xninkb = true.
                h_betrag = - h_betrag.
              ENDIF.
              IF t_fkkcollh-lfdnr >= h_collh09-lfdnr.

*               Liegt ein Storno-Fall vor, d.h. war der Abgabestatus des
*               vorhergenhenden Postens '10', '11', '12', oder '13' ?
                IF w_fkkcollh_alt-agsta EQ c_costumer_directly_paid  OR
                   w_fkkcollh_alt-agsta EQ c_costumer_partally_paid  OR
                   w_fkkcollh_alt-agsta EQ c_full_clearing           OR
                   w_fkkcollh_alt-agsta EQ c_partial_clearing        OR
                   w_fkkcollh_alt-agsta EQ c_receivable_paid         OR
                   w_fkkcollh_alt-agsta EQ c_receivable_part_paid    OR
                   w_fkkcollh_alt-agsta EQ c_agsta_t-erfolglos.

*               Abgabe der Information, falls Postition schon
*               protokolliert wurde.
                  IF NOT g_fkkcollinfo-xstorno IS INITIAL.
*                 Ja: Stornierung an Inkassobüro melden und
*                 in Log-Tabelle registrieren.
                    IF NOT t_fkkcollh-storb IS INITIAL.
                      PERFORM info_storno  USING    c_storno
                                                    i_basics
                                                    h_intnr_c
                                                    t_fkkcollh
                                                    h_lfd_p
                                                    h_betrag
                                                    space.
                    ENDIF.
                  ELSE.
*                 Nein: Stornierung nur in Log-Tabelle registrieren
                    IF NOT t_fkkcollh-storb IS INITIAL.
                      PERFORM info_storno  USING    c_storno
                                                    i_basics
                                                    h_intnr_c
                                                    t_fkkcollh
                                                    h_lfd_p
                                                    h_betrag
                                                    c_only_log.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
        w_fkkcollh_alt = t_fkkcollh.
        w_collh_last   = t_fkkcollh.


*-------- Zahlung / Teilzahlung direkt vom Kunden        {'07'/'08'}
      WHEN c_agsta_cu_t-erfolglos OR c_agsta_t-erfolglos.   " 07, 08

        IF x_delivered EQ true.
          h_betrag = t_fkkcollh-betrz - w_fkkcollh_alt-betrz.
          h_ninkb  = t_fkkcollh-ninkb - w_fkkcollh_alt-ninkb.
          IF t_fkkcollh-lfdnr > wt_fkkcoli_log-lfdnr.
            IF h_betrag < 0 AND t_fkkcollh-betrw > 0.    " REVERSE
              IF t_fkkcollh-lfdnr >= h_collh09-lfdnr.
*               Storno registrieren ?
                IF NOT g_fkkcollinfo-xstorno IS INITIAL.
                  IF NOT t_fkkcollh-storb IS INITIAL.
                    PERFORM info_storno  USING    c_storno
                                                  i_basics
                                                  h_intnr_c
                                                  t_fkkcollh
                                                  h_lfd_p
                                                  h_betrag
                                                  space.
                  ENDIF.
                ELSE.
                  IF NOT t_fkkcollh-storb IS INITIAL.
                    PERFORM info_storno  USING    c_storno
                                                  i_basics
                                                  h_intnr_c
                                                  t_fkkcollh
                                                  h_lfd_p
                                                  h_betrag
                                                  c_only_log.
                  ENDIF.
                ENDIF.
              ENDIF.
            ELSEIF h_ninkb > 0.                         " WRITEOFF
              IF NOT g_fkkcollinfo-xwroff IS INITIAL.
                h_collh_next-ninkb = t_fkkcollh-ninkb. " NOTE 1429275
                t_fkkcollh-ninkb = h_ninkb.            " NOTE 1429275
                IF t_fkkcollh-lfdnr >= h_collh09-lfdnr.
                  PERFORM info_storno USING    c_write_off
                                               i_basics
                                               h_intnr_c
                                               t_fkkcollh
                                               h_lfd_p
                                               h_betrag
                                               space.
                ELSE.
                  PERFORM info_storno USING    c_write_off
                                               i_basics
                                               h_intnr_c
                                               t_fkkcollh
                                               h_lfd_p
                                               h_betrag
                                               c_only_log.
                ENDIF.
                t_fkkcollh-ninkb = h_collh_next-ninkb.   " NOTE 1429275
              ENDIF.
            ELSE.                                       " PAYMENT
*-------- Zahlung bzw. Teilzahlung direkt
              IF NOT g_fkkcollinfo-xausg IS INITIAL AND
                 t_fkkcollh-agsta = c_agsta_cu_t-erfolglos.  " only for 07
                IF t_fkkcollh-lfdnr >= h_collh09-lfdnr.
*                 Zahlung an Inkassobüro melden und registrieren
                  PERFORM info_payment USING    c_payment
                                                i_basics
                                                h_intnr_c
                                                t_fkkcollh
                                                h_lfd_p
                                                h_betrag
                                                space.
                ELSE.
*                 Zahlung in Log-Tabelle registrieren
                  PERFORM info_payment USING    c_payment
                                                i_basics
                                                h_intnr_c
                                                t_fkkcollh
                                                h_lfd_p
                                                h_betrag
                                                c_only_log.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
        w_fkkcollh_alt = t_fkkcollh.
        w_collh_last   = t_fkkcollh.


      WHEN c_full_clearing OR c_partial_clearing.           " '12'/'13'

        IF x_delivered EQ true.
          h_betrag = t_fkkcollh-betrz - w_fkkcollh_alt-betrz.

          " note 2765757: status 13 is also possible in case of reverse
          "              of write off ( '07' --> '13')
          CLEAR h_xninkb.
          IF w_fkkcollh_alt-agsta EQ c_agsta_cu_t-erfolglos
              AND h_betrag = 0.  "for safety
            h_betrag = t_fkkcollh-ninkb - w_fkkcollh_alt-ninkb.
            h_xninkb = true.
          ENDIF.
          IF t_fkkcollh-lfdnr > wt_fkkcoli_log-lfdnr.
            IF h_betrag < 0 AND t_fkkcollh-betrw > 0 .
*         Storno
              "note 2748925/2765757 reverse of write-off needs to have positive sign
              IF h_xninkb = true.
                h_betrag = - h_betrag.
              ENDIF.
              IF t_fkkcollh-lfdnr >= h_collh09-lfdnr.
*               Abgabe der Information, falls Postition schon
*               protokolliert wurde.
                IF NOT g_fkkcollinfo-xstorno IS INITIAL.
*                 Ja: Stornierung an Inkassobüro melden und
*                 in Log-Tabelle registrieren.
                  IF NOT t_fkkcollh-storb IS INITIAL.
                    PERFORM info_storno  USING    c_storno
                                                  i_basics
                                                  h_intnr_c
                                                  t_fkkcollh
                                                  h_lfd_p
                                                  h_betrag
                                                  space.
                  ENDIF.
                ELSE.
*                 Nein: Stornierung nur in Log-Tabelle registrieren
                  IF NOT t_fkkcollh-storb IS INITIAL.
                    PERFORM info_storno  USING    c_storno
                                                  i_basics
                                                  h_intnr_c
                                                  t_fkkcollh
                                                  h_lfd_p
                                                  h_betrag
                                                  c_only_log.
                  ENDIF.
                ENDIF.
              ENDIF.

            ELSE.
*-------- Forderung ausgeglichen bzw. Forderung teilausgeglichen
              IF NOT g_fkkcollinfo-xausg IS INITIAL.
                IF t_fkkcollh-lfdnr >= h_collh09-lfdnr.
*                 Ausgleich an Inkassobüro melden und registrieren
                  PERFORM info_payment USING    c_payment
                                                i_basics
                                                h_intnr_c
                                                t_fkkcollh
                                                h_lfd_p
                                                h_betrag
                                                space.
                ELSE.
*                 Ausgleich in Log-Tabelle registrieren
                  PERFORM info_payment USING    c_payment
                                                i_basics
                                                h_intnr_c
                                                t_fkkcollh
                                                h_lfd_p
                                                h_betrag
                                                c_only_log.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
        w_fkkcollh_alt = t_fkkcollh.
        w_collh_last   = t_fkkcollh.

* adesso Stati
      WHEN c_direct_wroff.                           " '20'

*-------- Ausbuchung (Abgeschlossen) '20'
*         Hier nix mehr machen
*          - Entweder Direkte Ausbuchung aus Vormerkung 99 (war nie abgegeben)
*          - oder Zurückgerufen und dann Ausbuchung (wird eh schon nicht mehr gemeldet
*          - oder Ausbuchung nach Abbruch InkGP wird vorne schon ausgeschlossen

      WHEN c_sell.                                  " '30'
*-------- Verkauf '30'
*       Hier nix mehr machen
*         - Der verkauf wird erst gemeldet, wenn wirklich ausgebucht wurde
*         - Die Meldung erfolgt dann bei Ausbuchung
*           also bei
*           WHEN c_receivable_write_off OR c_receivable_part_write_off. "06/15

*        Das war im ersten Schritt angedacht ist aber obsolet
*        IF x_delivered EQ true.
*          IF t_fkkcollh-lfdnr > wt_fkkcoli_log-lfdnr.
**           Separate Datei für Verkauf / Ablehnung Verkauf
*            IF NOT i_basics-macat IS INITIAL.
**             Info nur wenn wirklich ausgebucht
*              h_tabix = sy-tabix + 1.
*              READ TABLE t_fkkcollh INDEX h_tabix
*                                    INTO h_collh_next TRANSPORTING agsta.
*              IF sy-subrc EQ 0 AND h_collh_next-agsta EQ c_receivable_write_off.
*
**             Verkauf melden und registrieren.
*                PERFORM adesso_info_sell_decl
*                        USING i_basics
*                              h_intnr_c
*                              t_fkkcollh
*                              h_lfd_r
*                              w_collh_last
*                              wt_fkkcoli_log.
*                CLEAR x_delivered.
*              ENDIF.
*            ENDIF.
*          ENDIF.
*        ENDIF.
*        w_collh_last   = t_fkkcollh.
*        CONTINUE.

      WHEN c_decl_sell_wroff.   " '31'
*-------- Ablehnung Verkauf und Ausbuchung '31'
*       Hier nix mehr machen
*         - Die Ablehnung des Verkaufs wird erst gemeldet, wenn wirklich ausgebucht wurde
*         - Die Meldung erfolgt dann bei Ausbuchung
*           also bei "WHEN c_receivable_write_off OR c_receivable_part_write_off. "06/15"

*        Das war im ersten Schritt angedacht ist aber obsolet
*        IF x_delivered EQ true.
*          IF t_fkkcollh-lfdnr > wt_fkkcoli_log-lfdnr.
**           Separate Datei für Verkauf / Ablehnung Verkauf
*            IF NOT i_basics-macat IS INITIAL.
**             Info nur wenn wirklich ausgebucht
**              h_tabix = sy-tabix + 1.
*              READ TABLE t_fkkcollh INDEX h_tabix
*                                    INTO h_collh_next TRANSPORTING agsta.
*              IF sy-subrc EQ 0 AND h_collh_next-agsta EQ c_receivable_write_off.
*
**                ablehnung verkauf melden und registrieren.
*                PERFORM adesso_info_sell_decl
*                        USING i_basics
*                              h_intnr_c
*                              t_fkkcollh
*                              h_lfd_r
*                              w_collh_last
*                              wt_fkkcoli_log.
*                CLEAR x_delivered.
*              ENDIF.
*            ENDIF.
*          ENDIF.
*        ENDIF.
*        w_collh_last   = t_fkkcollh.
*        CONTINUE.

      WHEN c_decl_sell_rcall.  " '32'.
*-------- Ablehnung Verkauf aber zunächst "Erneute Bearbeitung" '32'
*       Hier nix mehr machen
*         - Entweder wird der Fall dann doch noch verkauft --> 30
*             (dann entsprechende Weiterverarbeitung gemäß 30)
*         - Oder der Fall wird zurückgerufen ---> 09
*              (dann muß bei 09 eine Meldung an InkGP erfolgen)

      WHEN OTHERS.

        w_collh_last   = t_fkkcollh.
        CONTINUE.

    ENDCASE.

    w_collh_last   = t_fkkcollh.

  ENDLOOP.     " Historie

ENDFORM.                    " adesso_infos_pro_inkgp

*&---------------------------------------------------------------------*
*&      Form  adesso_info_sell_decl
*&---------------------------------------------------------------------*
FORM adesso_info_sell_decl
     USING  p_i_basics      TYPE fkk_mad_basics
            p_h_intnr_c     TYPE intnr_i_kk
            p_t_fkkcollh    LIKE dfkkcollh
            p_h_lfd_r       TYPE lfnum_kk
            p_w_collh_last  LIKE dfkkcollh
            p_t_fkkcoli_log STRUCTURE dfkkcoli_log
            p_h_womon-agsta TYPE agsta_kk.
*           p_logkz type logkz_kk.

  DATA: l_fkkcollp_ir_w LIKE dfkkcollp_ir_w,
        l_betrw         TYPE betrw_kk.

  DATA lv_txtvw           TYPE txtag_i_kk.
  DATA lv_betrw_content   TYPE betrw_kk.

  DATA ls_collitem        TYPE fkkcollitem.
  DATA ls_collections     TYPE fkkcollections.
  DATA ls_coli_log        TYPE fkkcoli_log.
  DATA ls_coli_log_ext    TYPE gty_fkkcoli_log_ext.
  DATA ls_postyp_sum      TYPE fkkcol_postyp_sum.
  DATA lv_collitem_lv     TYPE collitem_lv_kk.
  DATA ls_fkkcollp_ir     LIKE fkkcollp_ir.

  FIELD-SYMBOLS <fs_collections>  TYPE fkkcollections.
  FIELD-SYMBOLS <fs_coli_log_ext>  TYPE gty_fkkcoli_log_ext.


  CLEAR: l_fkkcollp_ir_w.
  CLEAR: l_betrw.

  SELECT SINGLE astxt INTO  lv_txtvw
                      FROM  tfk050at
                      WHERE spras EQ sy-langu
                      AND   agsta EQ p_t_fkkcollh-agsta.

* ----------------------------------------------------------------------
* file based version (enterprise services not active)
* ----------------------------------------------------------------------
  IF gv_flg_coll_esoa_active IS INITIAL.

    l_fkkcollp_ir_w-laufd   = p_i_basics-runkey-laufd.
    l_fkkcollp_ir_w-laufi   = p_i_basics-runkey-laufi.
    l_fkkcollp_ir_w-w_inkgp = p_t_fkkcollh-inkgp.
    l_fkkcollp_ir_w-intnr   = p_h_intnr_c.

    ADD 1 TO p_h_lfd_r.
    l_fkkcollp_ir_w-lfnum   = p_h_lfd_r.
    l_fkkcollp_ir_w-lfdnr   = p_t_fkkcollh-lfdnr.
    l_fkkcollp_ir_w-satztyp = c_position.

    CASE p_h_womon-agsta.

      WHEN '09'.
        l_fkkcollp_ir_w-postyp  = c_pt_decl.
        l_fkkcollp_ir_w-txtvw   = TEXT-sdc.
*       If the debt collecting agency only partly paid a demand, the remainder is recalled.
        IF p_w_collh_last-agsta EQ c_receivable_part_paid.
          l_betrw = p_t_fkkcollh-betrw - p_t_fkkcollh-betrz.
          WRITE l_betrw TO l_fkkcollp_ir_w-betrw
                           CURRENCY p_t_fkkcollh-waers.
        ELSEIF ( p_w_collh_last-agsta EQ c_costumer_partally_paid OR
                 p_w_collh_last-agsta EQ c_partial_clearing ) AND
                 p_w_collh_last-lfdnr EQ p_t_fkkcoli_log-lfdnr.
          l_betrw = p_t_fkkcollh-betrw - p_t_fkkcollh-betrz.
          WRITE l_betrw TO l_fkkcollp_ir_w-betrw
                           CURRENCY p_t_fkkcollh-waers.
        ELSE.
          WRITE p_t_fkkcollh-betrw TO l_fkkcollp_ir_w-betrw
                                      CURRENCY p_t_fkkcollh-waers.
        ENDIF.

      WHEN '30'.
        l_fkkcollp_ir_w-postyp  = c_pt_sell.
        l_fkkcollp_ir_w-txtvw   = TEXT-sel.
*       Ausbuchungsbetrag übergeben (NINKB)
        WRITE p_t_fkkcollh-ninkb TO l_fkkcollp_ir_w-betrw
                                    CURRENCY p_t_fkkcollh-waers.

      WHEN '31'.
        l_fkkcollp_ir_w-postyp  = c_pt_decl.
        l_fkkcollp_ir_w-txtvw   = TEXT-sdc.
*       Ausbuchungsbetrag übergeben (NINKB)
        WRITE p_t_fkkcollh-ninkb TO l_fkkcollp_ir_w-betrw
                                    CURRENCY p_t_fkkcollh-waers.
    ENDCASE.

    l_fkkcollp_ir_w-nrzas   = p_t_fkkcollh-nrzas.
    l_fkkcollp_ir_w-opbel   = p_t_fkkcollh-opbel.
    l_fkkcollp_ir_w-inkps   = p_t_fkkcollh-inkps.
    l_fkkcollp_ir_w-gpart   = p_t_fkkcollh-gpart.
    l_fkkcollp_ir_w-vkont   = p_t_fkkcollh-vkont.


    l_fkkcollp_ir_w-waers   = p_t_fkkcollh-waers.
    l_fkkcollp_ir_w-rudat   = p_t_fkkcollh-rudat.

    IF g_fkkcollinfo-sumknz IS INITIAL.
*--> fill ls_fkkcollh_i from header data

      MOVE-CORRESPONDING l_fkkcollp_ir_w TO ls_fkkcollp_ir.

* ------- calls user exit 5052 / recall -------------------------------*
      PERFORM call_zp_fb_5052_recall
         USING
            t_fkkcollh_i
            l_fkkcollp_ir_w-lfdnr
         CHANGING
            ls_fkkcollp_ir.

      MOVE-CORRESPONDING ls_fkkcollp_ir TO l_fkkcollp_ir_w.
    ENDIF.

* INSERT: Speichern Informationen zu Rückruf
*    insert into dfkkcollp_ir_w values l_fkkcollp_ir_w.
*>>>>> HANA
    DATA: lo_opt       TYPE REF TO if_fkk_optimization_settings,
          x_optimizing TYPE xfeld.
    lo_opt = cl_fkk_optimization_settings=>get_instance( ).
    x_optimizing = lo_opt->is_active( cl_fkk_optimization_settings=>cc_fica_fpci_mass_insert ).
    IF x_optimizing = abap_true.
      APPEND l_fkkcollp_ir_w TO gt_fkkcollp_ir_w.
    ELSE.
      INSERT INTO dfkkcollp_ir_w VALUES l_fkkcollp_ir_w.  "OLD LOGIC
    ENDIF.
*<<<<< HANA

* Registrieren Inkassobüro
    gt_inkgp = l_fkkcollp_ir_w-w_inkgp.
    COLLECT gt_inkgp.

* Registrieren bearbeiteten Fall
    gt_fall = l_fkkcollp_ir_w-gpart.
    COLLECT gt_fall.

  ENDIF.

ENDFORM.                    " adesso_info_sell_decl

*&---------------------------------------------------------------------*
*&      Form  UPDATE_DFKKCOLLH_I_W
*&---------------------------------------------------------------------*
FORM update_dfkkcollh_i_w  USING fs_fkkcollh_i_w TYPE dfkkcollh_i_w.

  DATA: lt_fkkcollh_i_w TYPE TABLE OF dfkkcollh_i_w.

  REFRESH lt_fkkcollh_i_w.
  APPEND fs_fkkcollh_i_w TO lt_fkkcollh_i_w.

*  TRY.
  INSERT dfkkcollh_i_w FROM TABLE lt_fkkcollh_i_w
                       ACCEPTING DUPLICATE KEYS.
*    CATCH cx_sy_open_sql_db.    " Note 2330715
** do not issue any error message in this case
*  ENDTRY.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CREATE_INFO_SELL_DECL
*&---------------------------------------------------------------------*
FORM create_info_sell_decl USING p_fkkcollinfo TYPE fkkcollinfo
                                 p_h_file_name
                                 p_t_fkkcollh_i_w LIKE dfkkcollh_i_w
                                 p_t_fkkcollh_i LIKE fkkcollh_i
                                 p_i_basics TYPE fkk_mad_basics
                        CHANGING p_t_fkkcollt_i LIKE fkkcollt_i.

  DATA:
    t_fkkcollp_ir   LIKE fkkcollp_ir,
    t_fkkcollp_ir_w LIKE dfkkcollp_ir_w,
    h_lfdnr         LIKE dfkkcoli_log-lfdnr,
    h_sumrc         TYPE sumza_kk,
    h_summe         TYPE sumza_kk,
    h_knz,
    h_anzrc         LIKE sy-tabix,
    sum_fkkcollp_ir LIKE fkkcollp_ir.

  DATA: lt_fkkcollp_ir_w LIKE dfkkcollp_ir_w OCCURS 0 WITH HEADER LINE,
        ls_fkkcollp_ir_w LIKE dfkkcollp_ir_w,
        cursor           TYPE cursor,
        lv_limit         TYPE dblimit_kk VALUE '100000'.

  DATA:
    BEGIN OF h_key_nrzas,
      nrzas TYPE nrzas_kk,
      gpart TYPE gpart_kk,
    END OF h_key_nrzas,
    h_key_nrzas_old LIKE h_key_nrzas.

  DATA:
    BEGIN OF h_key_gpart,
      gpart TYPE gpart_kk,
      nrzas TYPE nrzas_kk,
    END OF h_key_gpart,
    h_key_gpart_old LIKE h_key_gpart.

  DATA:
    BEGIN OF h_key_vkont,
      vkont TYPE vkont_kk,
      nrzas TYPE nrzas_kk,
    END OF h_key_vkont,
    h_key_vkont_old LIKE h_key_vkont.

  CLEAR:
    t_fkkcollp_ir,
    t_fkkcollp_ir_w,
    sum_fkkcollp_ir,
    h_anzrc,
    h_knz.

  CLEAR:
    h_key_nrzas,
    h_key_nrzas_old,
    h_key_gpart,
    h_key_gpart_old,
    h_key_vkont,
    h_key_vkont_old.

* Lesen Rückruf-Informationen aus Zwischenspeicher
  OPEN CURSOR WITH HOLD cursor FOR
    SELECT * FROM  dfkkcollp_ir_w
           WHERE laufd   EQ p_i_basics-runkey-laufd
           AND   laufi   EQ p_i_basics-runkey-laufi
           AND   w_inkgp EQ p_t_fkkcollh_i_w-w_inkgp
           AND   satztyp EQ c_position
           AND   postyp  IN (c_pt_sell, c_pt_decl)
           ORDER BY nrzas opbel inkps gpart.

  DO.
    REFRESH lt_fkkcollp_ir_w.
    FETCH NEXT CURSOR cursor
      INTO CORRESPONDING FIELDS OF TABLE lt_fkkcollp_ir_w
      PACKAGE SIZE lv_limit.

    IF sy-subrc NE 0.
      EXIT.
    ENDIF.

    LOOP AT lt_fkkcollp_ir_w INTO ls_fkkcollp_ir_w.
      MOVE-CORRESPONDING ls_fkkcollp_ir_w TO t_fkkcollp_ir.

* ------- calls user exit 5052 / recall -------------------------------*
      PERFORM call_zp_fb_5052_recall(saplfkci)
         USING    p_t_fkkcollh_i
                  ls_fkkcollp_ir_w-lfdnr
         CHANGING t_fkkcollp_ir.

* Ausgabe Rückrufinformation auf Informationsdatei
      ADD 1 TO h_anzrc.
      IF p_i_basics-status-xsimu IS INITIAL.
        IF g_sort IS INITIAL.
          TRANSFER t_fkkcollp_ir TO p_h_file_name.
        ELSE.
* append to an internal table and sort and transfer to the file later
          MOVE-CORRESPONDING ls_fkkcollp_ir_w TO gt_fkkcollp_ir.
          MOVE-CORRESPONDING t_fkkcollp_ir   TO gt_fkkcollp_ir.
          APPEND gt_fkkcollp_ir.
        ENDIF.

* Registrieren Meldung in Log-Tabelle
        PERFORM write_log_record_recall(saplfkci)
           USING ls_fkkcollp_ir_w-lfdnr
                 t_fkkcollp_ir
                 p_i_basics.
      ENDIF.

* Aktualisieren Datei-Endesatz
      ADD 1 TO p_t_fkkcollt_i-recnum.
      PERFORM addition(saplfkci)
        USING    t_fkkcollp_ir-betrw
        CHANGING p_t_fkkcollt_i-sumrc.

      PERFORM addition(saplfkci)
        USING    t_fkkcollp_ir-betrw
        CHANGING h_summe.

    ENDLOOP.
  ENDDO.

  CLOSE CURSOR cursor.

*>>>>> HANA
  IF NOT gt_fkkcoli_log[] IS INITIAL.
    INSERT dfkkcoli_log FROM TABLE gt_fkkcoli_log.
    CLEAR: gt_fkkcoli_log[],gt_fkkcoli_log.
  ENDIF.
*<<<<< HANA

* Protokoll
* Nachricht: Datei enthält Rückrufpositionen im Gesamtwert von & &
  IF h_anzrc > 0.
    WRITE h_summe TO h_sumrc LEFT-JUSTIFIED.
    SHIFT h_sumrc LEFT DELETING LEADING space.
    mac_appl_log_msg 'I' '>4' '801'
       h_anzrc
       h_sumrc t_fkkcollp_ir-waers space
       c_msgprio_info p_i_basics-appllog-probclass.
    SET EXTENDED CHECK OFF.
    IF 1 = 2. MESSAGE i801(>4). ENDIF.
    SET EXTENDED CHECK ON.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  create_trailer
*&---------------------------------------------------------------------*
FORM create_trailer_ink USING p_fkkcollinfo TYPE fkkcollinfo
                              p_h_file_name
                              p_t_fkkcollh_i LIKE fkkcollh_i
                              p_t_fkkcollt_i LIKE fkkcollt_i
                              p_i_basics TYPE fkk_mad_basics.

* ------- calls user exit 5053 ----------------------------------------*
  PERFORM call_zp_fb_5053
     USING
        p_t_fkkcollh_i
     CHANGING
        p_t_fkkcollt_i.

* Scheiben Datei-Endesatz
  IF p_i_basics-status-xsimu IS INITIAL.
    TRANSFER p_t_fkkcollt_i TO p_h_file_name.
  ENDIF.

ENDFORM.                    " create_trailer_ink

*&---------------------------------------------------------------------*
*&      Form  create_file_header_ink
*&---------------------------------------------------------------------*
FORM create_file_header_ink
     USING    p_fkkcollinfo    TYPE fkkcollinfo
              p_t_fkkcollh_i_w LIKE dfkkcollh_i_w
              p_i_basics       TYPE fkk_mad_basics
     CHANGING p_h_file_name
              p_t_fkkcollh_i   LIKE fkkcollh_i
              p_t_fkkcollt_i   LIKE fkkcollt_i
              p_rc             LIKE sy-subrc.

  DATA: w_open.

  CLEAR: p_rc.
  CLEAR: w_open.

  IF NOT p_t_fkkcollh_i_w-inkgp IS INITIAL.

* Erzeugen Dateiname
    PERFORM create_filename
       USING p_i_basics
             p_fkkcollinfo-datei
             p_t_fkkcollh_i_w-inkgp
       CHANGING p_h_file_name.

* Anlegen Informationsdatei
    IF p_i_basics-status-xsimu IS INITIAL.
*     OPEN DATASET
      OPEN DATASET p_h_file_name FOR OUTPUT IN TEXT MODE
                                     ENCODING DEFAULT.
      IF sy-subrc IS INITIAL.
        w_open = 'X'.
      ENDIF.
    ELSE.
      w_open = 'X'.
    ENDIF.

    IF w_open IS INITIAL.
* Nachricht: File ... konnte nicht geöffnet werden
      mac_appl_log_msg 'E' '>3' '843'
         p_h_file_name space space space
         c_msgprio_high '1'.
      SET EXTENDED CHECK OFF.
      IF 1 = 2. MESSAGE e843(>3). ENDIF.
      SET EXTENDED CHECK ON.

      p_rc = 8 .
      EXIT.
    ELSE.
      IF p_i_basics-status-xsimu IS INITIAL.
* Nachricht: Datei ...  wurde auf Rechner ... gespeichert
        mac_appl_log_msg 'I' '>4' '803'
           p_h_file_name sy-host space space
           c_msgprio_high '1'.
        SET EXTENDED CHECK OFF.
        IF 1 = 2. MESSAGE i803(>4). ENDIF.
        SET EXTENDED CHECK ON.
      ENDIF.

* ------- calls user exit 5051 ----------------------------------------*
      PERFORM call_zp_fb_5051
         USING    p_t_fkkcollh_i_w
         CHANGING p_t_fkkcollh_i.

* Schreiben Datei-Kopfsatz
      IF p_i_basics-status-xsimu IS INITIAL.
        TRANSFER p_t_fkkcollh_i TO p_h_file_name.
      ENDIF.

    ENDIF.
  ELSE.
* Nachricht: Schlüssel Inkassobüro is leer
    mac_appl_log_msg 'I' '>4' '804'
      space space space space
      c_msgprio_low '1'.
    SET EXTENDED CHECK OFF.
    IF 1 = 2. MESSAGE i804(>4). ENDIF.
    SET EXTENDED CHECK ON.

    p_rc = 8 .
    EXIT.
  ENDIF.

* Vorbereiten Datei-Endesatz
  CLEAR p_t_fkkcollt_i.
  p_t_fkkcollt_i-satztyp = c_trailer.

ENDFORM.                    " create_file_header_ink
