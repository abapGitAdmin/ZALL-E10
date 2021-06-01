FUNCTION /adesso/ink_recall_coll_agency.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_XSIMU) LIKE  BOOLE-BOOLE DEFAULT 'X'
*"     VALUE(I_BATCH) LIKE  BOOLE-BOOLE DEFAULT 'X'
*"     REFERENCE(I_RUDAT) TYPE  RUDAT_KK
*"     REFERENCE(I_RUGRD) TYPE  DEAGR_KK
*"     REFERENCE(I_AGSTA) TYPE  AGSTA_KK
*"  TABLES
*"      T_FKKOP STRUCTURE  FKKOP
*"      T_FKKOP_NOT_SUBMITTED STRUCTURE  FKKOP OPTIONAL
*"      T_FIMSG STRUCTURE  FIMSG OPTIONAL
*"      T_RECALL STRUCTURE  DFKKCOLL OPTIONAL
*"      T_REASSIGN STRUCTURE  DFKKCOLL OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

  DATA: ht_dfkkcoll         LIKE dfkkcoll   OCCURS 0 WITH HEADER LINE,
        t_all_coll          LIKE dfkkcoll   OCCURS 0 WITH HEADER LINE,
        t_subm_coll         LIKE dfkkcoll   OCCURS 0 WITH HEADER LINE,
        t_recall_coll       LIKE dfkkcoll   OCCURS 0 WITH HEADER LINE,
        t_reassign_coll     LIKE dfkkcoll   OCCURS 0 WITH HEADER LINE,
        t_history_coll      LIKE dfkkcollh  OCCURS 0 WITH HEADER LINE,
        t_recall_hist       LIKE dfkkcoll   OCCURS 0 WITH HEADER LINE,
        wt_fkkop            LIKE fkkop      OCCURS 0 WITH HEADER LINE,
        nt_fkkop            LIKE sfkkop     OCCURS 0 WITH HEADER LINE,
        ft_fkkop            LIKE sfkkop     OCCURS 0 WITH HEADER LINE,
        ht_fimsg            LIKE fimsg      OCCURS 0 WITH HEADER LINE,
        ht_agsta_range      LIKE fkkr_agsta OCCURS 0 WITH HEADER LINE,
        t_fkkcoll_buffer    LIKE dfkkcoll   OCCURS 0 WITH HEADER LINE,
        r_ht_dfkkcoll_lines LIKE sy-tfill,
        h_ht_dfkkcoll_lines LIKE sy-tfill,
        h_opbel             LIKE dfkkcoll-opbel,
        h_inkps             LIKE fkkop-inkps,
        h_lines             LIKE sy-tfill,
        h_emgpa             LIKE fkkop-emgpa,
        h_field             TYPE text50,
        do_recall           LIKE boole-boole,    " do recall items
        h_rugrd             LIKE dfkkcoll-rugrd,
        h_del               LIKE boole-boole,
        BEGIN OF t_hist OCCURS 0,
          lfdnr LIKE dfkkcollh-lfdnr,
          agsta LIKE dfkkcollh-agsta,
        END OF t_hist.

  DATA: BEGIN OF lt OCCURS 0,
          gpart LIKE fkkop-gpart,
        END OF lt.

*- tables for documents changes
  DATA: it_fkkko       LIKE fkkko   OCCURS 0 WITH HEADER LINE,
        t_fkkop_n      LIKE fkkop   OCCURS 0 WITH HEADER LINE,
        t_fkkop_o      LIKE fkkop   OCCURS 0 WITH HEADER LINE,
        t_fkkopk       LIKE fkkopk  OCCURS 0 WITH HEADER LINE,
        t_fkkopw       LIKE fkkopw  OCCURS 0 WITH HEADER LINE,
        icdtxt_mkk_doc LIKE cdtxt   OCCURS 0 WITH HEADER LINE.

* data for BW trigger update
  DATA: loc_xbw     TYPE xfeld,
        loct_bw_upd LIKE dfkkkobw OCCURS 0 WITH HEADER LINE.

  CLEAR:   ht_dfkkcoll, h_inkps, t_all_coll, t_subm_coll, t_recall_coll,
           t_reassign_coll.
  REFRESH: ht_dfkkcoll,t_all_coll, t_subm_coll, t_recall_coll,
           t_reassign_coll.

* no release of installment plan items
  DELETE t_fkkop WHERE stakz EQ 'R'.

  DESCRIBE TABLE t_fkkop.
  CHECK sy-tfill > 0.

  DELETE ADJACENT DUPLICATES FROM t_fkkop.

*** prepare data for CURRENCY conversion
* Read customizing table TFK042C and convert amounts
  DATA: t_tfk042c LIKE tfk042c OCCURS 0 WITH HEADER LINE.
  PERFORM read_tfk042c TABLES t_tfk042c.
*** -->> end of CURRENCY conversion

  SORT t_fkkop BY opbel opupk opupw.
  LOOP AT t_fkkop WHERE stakz CA 'IP'.                      "#EC *
    AT NEW opbel.
      CLEAR: nt_fkkop.
      REFRESH: nt_fkkop.
      CALL FUNCTION 'FKK_READ_DOC_INTO_LOGICAL'
        EXPORTING
          i_opbel         = t_fkkop-opbel
          i_accumulate    = space
        TABLES
          t_logfkkop      = nt_fkkop
        EXCEPTIONS
          opbel_not_found = 1
          OTHERS          = 2.
      IF sy-subrc NE 0.
        CONTINUE.
      ENDIF.
      APPEND LINES OF nt_fkkop TO ft_fkkop.
    ENDAT.
  ENDLOOP.

  DESCRIBE TABLE ft_fkkop LINES h_lines.
  IF h_lines NE 0.
    CLEAR: nt_fkkop.
    REFRESH: nt_fkkop.
    LOOP AT ft_fkkop.
      READ TABLE t_fkkop WITH KEY opbel = ft_fkkop-opbel
                                  opupk = ft_fkkop-opupk
                                  opupw = ft_fkkop-opupw
                                  opupz = ft_fkkop-opupz.
      IF sy-subrc EQ 0.
        MOVE-CORRESPONDING ft_fkkop TO nt_fkkop.
        APPEND nt_fkkop.
      ENDIF.
    ENDLOOP.

    LOOP AT t_fkkop.
      READ TABLE nt_fkkop WITH KEY opbel = t_fkkop-opbel
                                   opupk = t_fkkop-opupk
                                   opupw = t_fkkop-opupw
                                   opupz = t_fkkop-opupz.
      IF sy-subrc EQ 0.
        DELETE TABLE t_fkkop.
      ENDIF.
    ENDLOOP.

    LOOP AT nt_fkkop.
      MOVE-CORRESPONDING nt_fkkop TO t_fkkop.
      APPEND t_fkkop.
    ENDLOOP.

* ------ Delete cleared repetition items.
    DELETE t_fkkop WHERE augst EQ 9.
  ENDIF.
  CLEAR h_lines.

  LOOP AT t_fkkop.
    CALL FUNCTION 'FKK_DB_DFKKCOLL_SINGLE'
      EXPORTING
        i_opbel       = t_fkkop-opbel
        i_inkps       = t_fkkop-inkps
      IMPORTING
        e_fkkcoll     = ht_dfkkcoll
      EXCEPTIONS
        not_found     = 1
        initial_value = 2
        OTHERS        = 3.
    IF sy-subrc EQ 0.
      APPEND ht_dfkkcoll.
    ENDIF.
  ENDLOOP.

  APPEND LINES OF ht_dfkkcoll TO t_all_coll.


* ------ call user exit 5065 ------------------------------------------*
  PERFORM call_zp_fb_5065 TABLES ht_dfkkcoll   "submitted positions
                                 t_all_coll    "positions at Coll.Agency
                                 t_recall_coll    "recalled positions
                                 t_reassign_coll  "reassigned positions
                        CHANGING do_recall.

  DESCRIBE TABLE t_recall_coll LINES h_ht_dfkkcoll_lines.

  IF h_ht_dfkkcoll_lines GT 0 AND
     NOT do_recall IS INITIAL.

    t_fkkcoll_buffer[] = t_recall_coll[].

    SORT t_recall_coll BY opbel inkps.
    LOOP AT t_recall_coll.

      READ TABLE t_reassign_coll WITH KEY opbel = t_recall_coll-opbel
                                          inkps = t_recall_coll-inkps.

      IF sy-subrc = 0.
        t_reassign_coll-agsta = const_agsta_freigegeben.
        t_reassign_coll-agdat = '00000000'.
        t_reassign_coll-xblnr = t_recall_coll-inkgp.
        MODIFY t_reassign_coll INDEX sy-tabix.
      ENDIF.

      CLEAR h_inkps.

      IF t_recall_coll-agsta EQ const_agsta_abgegeben     OR
         t_recall_coll-agsta EQ const_agsta_erfolglos     OR
         t_recall_coll-agsta EQ const_agsta_t_erfolglos   OR
         t_recall_coll-agsta EQ const_agsta_cu_t_erfolglos OR
         t_recall_coll-agsta EQ const_agsta_sub_erfolglos OR
         t_recall_coll-agsta EQ const_agsta_recall        OR
         t_recall_coll-agsta EQ const_agsta_rec_erfolglos OR
         t_recall_coll-agsta EQ const_agsta_teilbezahlt   OR
         t_recall_coll-agsta EQ const_agsta_cust_pay      OR
         t_recall_coll-agsta EQ const_agsta_cust_p_pay    OR
         t_recall_coll-agsta EQ const_agsta_p_paid        OR
         t_recall_coll-agsta EQ const_decl_sell_rcall.

        t_recall_coll-agsta = i_agsta.
        t_recall_coll-rudat = i_rudat.
        t_recall_coll-rugrd = i_rugrd.

      ENDIF.
      MODIFY t_recall_coll.
    ENDLOOP.

* Conversion of currency and amounts in table DFKKCOLL according to
* table TFK042C (for EURO-Conversion)
    PERFORM items_convert_currency TABLES  t_tfk042c
                                           t_reassign_coll
                                           t_fkkop.

    t_recall_hist[] = t_recall_coll[].

    LOOP AT t_reassign_coll.
      READ TABLE t_recall_coll WITH KEY opbel = t_reassign_coll-opbel
                                        inkps = t_reassign_coll-inkps.
      IF sy-subrc EQ 0.
        MOVE-CORRESPONDING t_reassign_coll TO t_recall_coll.
* maintain released amount in case the item was partially paid
        IF t_recall_coll-betrz > 0.
          SUBTRACT t_recall_coll-betrz FROM t_recall_coll-betrw.
          CLEAR t_recall_coll-betrz.
        ENDIF.
        CLEAR: t_recall_coll-rudat, t_recall_coll-rugrd.
        MODIFY t_recall_coll INDEX sy-tabix.
      ENDIF.
    ENDLOOP.

    IF i_xsimu IS INITIAL.
* chance recalled records
      CALL FUNCTION 'FKK_DB_DFKKCOLL_MODE'
        EXPORTING
          i_mode    = const_mode_modify
        TABLES
          t_fkkcoll = t_recall_coll
        EXCEPTIONS
          error     = 1
          OTHERS    = 2.
      IF sy-subrc <> 0.
        IF NOT sy-batch IS INITIAL.
          PERFORM message_append TABLES t_fimsg
                                  USING '>3' 'E' '521'
                                  'DFKKCOLL' space space space.
* ------ for cross reference purpose only-----------------------------*
          SET EXTENDED CHECK OFF.
          IF 1 = 2. MESSAGE s521(>3) WITH 'DFKKCOLL'. ENDIF.
          SET EXTENDED CHECK ON.
* ------ end of cross reference---------------------------------------*
        ELSE.
          MESSAGE e521(>3) WITH 'DFKKCOLL' space space space.
        ENDIF.
      ELSE.
* delete locks for recalled postings
*        PERFORM delete_locks TABLES t_recall_coll
*                                    wt_fkkop.

* insert collection agency history table
        PERFORM create_history TABLES t_recall_hist
                                      t_history_coll
                                      t_fimsg.

* write change document after changing AGSTA for recalled positions
        PERFORM changedocument_write TABLES t_recall_hist
                                            t_fkkcoll_buffer.

        LOOP AT t_recall_coll.

          CLEAR h_emgpa.

          SELECT SINGLE emgpa FROM dfkkop INTO h_emgpa
           WHERE opbel = t_recall_coll-opbel AND
                 inkps = t_recall_coll-inkps.

          IF NOT h_emgpa IS INITIAL.

            CALL FUNCTION 'FKK_DB_TFK050B_SINGLE'
              EXPORTING
                i_inkgp           = h_emgpa
              EXCEPTIONS
                not_found         = 1
                initial_parameter = 2
                OTHERS            = 3.

            IF sy-subrc EQ 0.
              UPDATE dfkkop SET emgpa = space
                         WHERE opbel = t_recall_coll-opbel AND
                               inkps = t_recall_coll-inkps.

*------- BW trigger needed ?
              CALL FUNCTION 'FKK_BW_TRIGGER_ACTIVE_CHECK'
                IMPORTING
                  ev_active = loc_xbw.

*------- collect trigger for BW
              IF loc_xbw = 'X'.
                loct_bw_upd-opbel = t_recall_coll-opbel.
                COLLECT loct_bw_upd.
              ENDIF.

              CLEAR: t_fkkop_o, t_fkkop_n, t_fkkop_o[], t_fkkop_n[].

              READ TABLE t_fkkop WITH KEY opbel = t_recall_coll-opbel
                                          inkps = t_recall_coll-inkps.

              IF sy-subrc EQ 0.
                t_fkkop_o = t_fkkop_n = wt_fkkop.
                CLEAR t_fkkop_n-emgpa.
                APPEND: t_fkkop_n, t_fkkop_o.

                MOVE-CORRESPONDING t_fkkop TO it_fkkko.
*--- call generated function for update doc creation ------------------*
                CALL FUNCTION 'FKK_BELEG_WRITE_CHANGEDOC'
                  EXPORTING
                    opbel            = it_fkkko-opbel
                    n_fkkko          = it_fkkko
                    o_fkkko          = it_fkkko
                  TABLES
                    icdtxt_mkk_beleg = icdtxt_mkk_doc
                    xfkkop           = t_fkkop_n
                    yfkkop           = t_fkkop_o
                    xfkkopk          = t_fkkopk  "not changed
                    yfkkopk          = t_fkkopk  "not changed
                    xfkkopw          = t_fkkopw  "not changed
                    yfkkopw          = t_fkkopw. "not changed.
              ENDIF.

*------- forward trigger tables for BW
              IF loc_xbw = 'X'.
                CALL FUNCTION 'FKK_DFKKKOBW_UPDATE'
                  CHANGING
                    ct_dfkkkobw_update = loct_bw_upd[]
                  EXCEPTIONS
                    OTHERS             = 0.
              ENDIF.

            ENDIF.
          ENDIF.
        ENDLOOP.

      ENDIF.

* Insert new records
      DESCRIBE TABLE t_reassign_coll LINES r_ht_dfkkcoll_lines.
      IF r_ht_dfkkcoll_lines > 0.
* insert collection agency history table
        PERFORM create_history TABLES t_reassign_coll
                                      t_history_coll
                                      t_fimsg.

* write change document after changing AGSTA for reassigned positions
        PERFORM changedocument_write TABLES t_reassign_coll
                                            t_recall_hist.

      ENDIF.
    ENDIF.

* output message
    IF NOT i_batch IS INITIAL.
      LOOP AT t_recall_coll.
        CONCATENATE t_recall_coll-opbel t_recall_coll-inkps
                    INTO h_field SEPARATED BY '/'.

        READ TABLE t_reassign_coll WITH KEY
                                   opbel = t_recall_coll-opbel
                                   inkps = t_recall_coll-inkps.
        IF sy-subrc EQ 0.
          PERFORM message_append TABLES t_fimsg
                                USING '>3' 'S' '426' h_field
                                   space space space.
        ELSE.
          PERFORM message_append TABLES t_fimsg
                                USING '>3' 'S' '425' h_field
                                   space space space.
        ENDIF.
* ----- for cross reference purpose only -----------------------------*
        SET EXTENDED CHECK OFF.
        IF 1 = 2. MESSAGE s425(>3). ENDIF.
        SET EXTENDED CHECK ON.
* ----- end of cross reference ---------------------------------------*
* ----- for cross reference purpose only -----------------------------*
        SET EXTENDED CHECK OFF.
        IF 1 = 2. MESSAGE s426(>3). ENDIF.
        SET EXTENDED CHECK ON.
* ----- end of cross reference ---------------------------------------*
      ENDLOOP.
    ENDIF.
  ENDIF.

  t_recall[]   = t_recall_coll[].
  t_reassign[] = t_reassign_coll[].

* ------ Reset internal tables ----------------------------------------*
  CLEAR:   ht_dfkkcoll, ht_fimsg.
  REFRESH: ht_dfkkcoll, ht_fimsg.

ENDFUNCTION.
