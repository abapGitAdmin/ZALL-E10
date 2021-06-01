FUNCTION /ADESSO/INK_REL_FOR_COLLAGENCY.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_AGGRD) LIKE  DFKKCOLL-AGGRD
*"     VALUE(I_XSIMU) LIKE  BOOLE-BOOLE DEFAULT 'X'
*"     VALUE(I_BATCH) LIKE  BOOLE-BOOLE DEFAULT 'X'
*"     VALUE(I_BUFFERED_DOCS_ALLOWED) LIKE  BOOLE-BOOLE OPTIONAL
*"     VALUE(I_INKGP) TYPE  INKGP_KK OPTIONAL
*"  TABLES
*"      T_FKKOP STRUCTURE  FKKOP
*"      T_FKKOP_NOT_SUBMITTED STRUCTURE  FKKOP OPTIONAL
*"      T_FIMSG STRUCTURE  FIMSG OPTIONAL
*"      T_DFKKCOLL STRUCTURE  DFKKCOLL OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"--------------------------------------------------------------------
  DATA: ht_fkkop            LIKE fkkop      OCCURS 0 WITH HEADER LINE,
        ht_dfkkcoll         LIKE dfkkcoll   OCCURS 0 WITH HEADER LINE,
        t_all_coll          LIKE dfkkcoll   OCCURS 0 WITH HEADER LINE,
        t_subm_coll         LIKE dfkkcoll   OCCURS 0 WITH HEADER LINE,
        t_recall_coll       LIKE dfkkcoll   OCCURS 0 WITH HEADER LINE,
        t_reassign_coll     LIKE dfkkcoll   OCCURS 0 WITH HEADER LINE,
        t_history_coll      LIKE dfkkcollh  OCCURS 0 WITH HEADER LINE,
        t_recall_hist       LIKE dfkkcoll   OCCURS 0 WITH HEADER LINE,
        ht_dfkkop           LIKE fkkop      OCCURS 0 WITH HEADER LINE,
        ht_fkkop_not_submitted LIKE fkkop   OCCURS 0 WITH HEADER LINE,
        ht_fimsg            LIKE fimsg      OCCURS 0 WITH HEADER LINE,
        wt_fkkop            LIKE fkkop      OCCURS 0 WITH HEADER LINE,
        rt_fkkop            LIKE sfkkop     OCCURS 0 WITH HEADER LINE,
        nt_fkkop            LIKE sfkkop     OCCURS 0 WITH HEADER LINE,
        ft_fkkop            LIKE sfkkop     OCCURS 0 WITH HEADER LINE,
        ht_agsta_range      LIKE fkkr_agsta OCCURS 0 WITH HEADER LINE,
        h_t_fkkop_lines     LIKE sy-tfill,
        h_t_fkkop_ns_lines  LIKE sy-tfill,
        h_ht_dfkkcoll_lines LIKE sy-tfill,
        r_ht_dfkkcoll_lines LIKE sy-tfill,
        h_ht_dfkkop_lines   LIKE sy-tfill,
        h_opbel             LIKE dfkkcoll-opbel,
        h_inkgp             LIKE dfkkcoll-inkgp,
        h_inkps             LIKE fkkop-inkps,
        h_lines             LIKE sy-tfill,
        h_lines_not         LIKE sy-tfill,
        hx_submission_denied LIKE boole-boole,
        h_field             TYPE text50,
        do_recall           LIKE boole-boole,         " do recall items
        h_rugrd             LIKE dfkkcoll-rugrd,
        h_emgpa             LIKE fkkop-emgpa,
        h_inkps_max         LIKE dfkkcoll-inkps,
        h_max               LIKE boole-boole,
        BEGIN OF lt OCCURS 0,
          gpart LIKE fkkop-gpart,
        END OF lt,
        h_rel_instpln LIKE boole-boole.

*- tables for documents changes
  DATA: it_fkkko        LIKE fkkko   OCCURS 0 WITH HEADER LINE,
        t_fkkop_n       LIKE fkkop   OCCURS 0 WITH HEADER LINE,
        t_fkkop_o       LIKE fkkop   OCCURS 0 WITH HEADER LINE,
        t_fkkopk        LIKE fkkopk  OCCURS 0 WITH HEADER LINE,
        t_fkkopw        LIKE fkkopw  OCCURS 0 WITH HEADER LINE,
        icdtxt_mkk_doc  LIKE cdtxt   OCCURS 0 WITH HEADER LINE.

* data for BW trigger update
  DATA: loc_xbw       TYPE xfeld,
        loct_bw_upd   LIKE dfkkkobw OCCURS 0 WITH HEADER LINE.

  CLEAR:   ht_dfkkcoll, h_inkps, t_all_coll, t_subm_coll, t_recall_coll,
           t_reassign_coll, h_lines.
  REFRESH: ht_dfkkcoll, t_all_coll, t_subm_coll, t_recall_coll,
           t_reassign_coll.

*-- read events 5059 and 5060
  PERFORM read_events_for_release.

* no release of installment plan items
*  DELETE t_fkkop WHERE stakz EQ 'R'.

  DESCRIBE TABLE t_fkkop.
  CHECK sy-tfill > 0.

  DELETE ADJACENT DUPLICATES FROM t_fkkop.

  LOOP AT t_fkkop.
    IF NOT i_batch IS INITIAL OR
       i_aggrd = 02.      " manual write off
* --- Call event 5059 to delete position for submission
      PERFORM call_zp_fb_5059 TABLES ht_fkkop_not_submitted
                               USING t_fkkop
                            CHANGING h_rel_instpln.

      DESCRIBE TABLE ht_fkkop_not_submitted LINES h_lines_not.
      IF NOT h_lines_not IS INITIAL  OR
       ( t_fkkop-stakz EQ 'R' AND
         h_rel_instpln EQ space ).
        DELETE t_fkkop.
      ENDIF.
    ENDIF.
  ENDLOOP.

*** prepare data for CURRENCY conversion
* Read customizing table TFK042C and convert amounts
  DATA: t_tfk042c LIKE tfk042c OCCURS 0 WITH HEADER LINE.
  PERFORM read_tfk042c TABLES t_tfk042c.
*** -->> end of CURRENCY conversion

  SORT t_fkkop BY opbel opupk opupw.
*  LOOP AT t_fkkop WHERE stakz CA 'IPR'.
  LOOP AT t_fkkop WHERE whgrp NE '000'
                    AND stakz NE space.

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

  READ TABLE ft_fkkop INDEX 1.
  IF sy-subrc EQ 0.
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

  CLEAR: h_lines.

  LOOP AT t_fkkop.

* If there is a collection number set, the new number must be calculated
    CLEAR   ht_fimsg.
    REFRESH ht_fimsg.
    CALL FUNCTION 'FKK_COLLECT_AGENCY_NUMBER_CALC'
      EXPORTING
        i_opbel             = t_fkkop-opbel
        i_inkps             = t_fkkop-inkps
*        i_aggrd             = const_aggrd_ausbuchen "note 2640312
        i_aggrd             = i_aggrd
      IMPORTING
        e_inkps             = h_inkps
        e_submission_denied = hx_submission_denied
      TABLES
        t_fimsg             = ht_fimsg
      EXCEPTIONS
        error               = 1
        OTHERS              = 2.
    IF sy-subrc > 0 OR NOT hx_submission_denied IS INITIAL.
      APPEND t_fkkop TO t_fkkop_not_submitted.
      LOOP AT ht_fimsg.
        IF i_batch IS INITIAL.
          MESSAGE ID ht_fimsg-msgid TYPE ht_fimsg-msgty NUMBER
                     ht_fimsg-msgno WITH ht_fimsg-msgv1 ht_fimsg-msgv2
                                         ht_fimsg-msgv3 ht_fimsg-msgv4.
        ELSE.
          APPEND ht_fimsg TO t_fimsg.
        ENDIF.
      ENDLOOP.
      CONTINUE.
    ENDIF.

* -- Add 1 to the collection number for each already written off
* -- position with the given document number in this function module
    IF h_inkps_max IS INITIAL.
      LOOP AT ht_dfkkcoll WHERE opbel = t_fkkop-opbel.
        h_inkps = h_inkps + 1.
      ENDLOOP.
    ELSE.
      READ TABLE ht_dfkkcoll WITH KEY opbel = t_fkkop-opbel
                                      inkps = h_inkps_max.
      IF sy-subrc NE 0.
        CLEAR h_inkps_max.
      ELSE.
        h_inkps = h_inkps_max.   "note 2656538
      ENDIF.
    ENDIF.

* ------ Determine collection agency for current item -----------------*
* ------ It will be possible to select a different Collection Agency per
* ------ line item.
    CLEAR   ht_fkkop.
    REFRESH ht_fkkop.
    ht_fkkop[] = t_fkkop[].

    IF i_inkgp IS NOT INITIAL.
* direct input from FCC
      h_inkgp = i_inkgp.
    ELSE.
* ------ calls user exit 5060 -----------------------------------------*
      PERFORM call_zp_fb_5060 TABLES   ht_fkkop
                               USING   t_fkkop
                            CHANGING   h_inkgp.
    ENDIF.

    IF NOT h_inkgp IS INITIAL.
      IF h_inkps_max IS INITIAL.
        ht_dfkkcoll-mandt = t_fkkop-mandt.
        ht_dfkkcoll-opbel = t_fkkop-opbel.
        ht_dfkkcoll-inkps = h_inkps.
        ht_dfkkcoll-bukrs = t_fkkop-bukrs.
        ht_dfkkcoll-gpart = t_fkkop-gpart.
        ht_dfkkcoll-vkont = t_fkkop-vkont.
        ht_dfkkcoll-inkgp = h_inkgp.
        ht_dfkkcoll-aggrd = i_aggrd.
        ht_dfkkcoll-betrw = t_fkkop-betrw.
        ht_dfkkcoll-waers = t_fkkop-waers.
        ht_dfkkcoll-agsta = const_agsta_freigegeben.
        APPEND ht_dfkkcoll.
        ht_dfkkop = t_fkkop.
        ht_dfkkop-inkps = h_inkps.
        APPEND ht_dfkkop.
        t_fkkop-inkps = h_inkps.
        MODIFY t_fkkop.
      ELSE.
* create summary collection agency positions when INKPS>990
        ht_dfkkcoll-inkps = h_inkps_max.
        ADD t_fkkop-betrw TO ht_dfkkcoll-betrw.
        MODIFY TABLE ht_dfkkcoll.
        ht_dfkkop = t_fkkop.
        ht_dfkkop-inkps = h_inkps_max.
        APPEND ht_dfkkop.
        t_fkkop-inkps = h_inkps_max.
        MODIFY t_fkkop.
      ENDIF.
    ELSE.
      READ TABLE t_fkkop_not_submitted
                 WITH KEY gpart = t_fkkop-gpart
                 TRANSPORTING NO FIELDS.
      IF sy-subrc NE 0.
        IF i_batch IS INITIAL.
          IF h_man_sel IS INITIAL.
            MESSAGE w842(>3) WITH t_fkkop-gpart.
          ENDIF.
        ELSE.
          PERFORM message_append TABLES t_fimsg USING '>3' 'W' '842'
                                        t_fkkop-gpart space space space.
        ENDIF.
      ENDIF.
      APPEND t_fkkop TO t_fkkop_not_submitted.
    ENDIF.

    IF h_inkps > 990.
* if the collection agency number > 990, start collecting the items
* under one summary INKPS.
      h_inkps_max = h_inkps.
      h_max = const_marked.
    ELSE.
      CLEAR h_inkps_max.
    ENDIF.

  ENDLOOP.

  IF h_inkgp IS INITIAL AND
     NOT h_man_sel IS INITIAL.
    CLEAR h_man_sel.
    MESSAGE w504(>3).
  ENDIF.

* ------ Internal check of consistency --------------------------------*
  DESCRIBE TABLE ht_dfkkop   LINES h_ht_dfkkop_lines.
  DESCRIBE TABLE ht_dfkkcoll LINES h_ht_dfkkcoll_lines.
  h_lines = h_ht_dfkkop_lines - h_ht_dfkkcoll_lines.
  IF h_lines NE 0 AND h_max IS INITIAL.
    t_fkkop_not_submitted[] = t_fkkop[].
    IF i_batch IS INITIAL.
      MESSAGE e457(>3) WITH h_ht_dfkkop_lines h_ht_dfkkcoll_lines
                       RAISING error.
    ELSE.
      PERFORM message_append TABLES t_fimsg USING '>3' 'E' '457'
                     h_ht_dfkkop_lines h_ht_dfkkcoll_lines space space.
      RAISE error.
    ENDIF.
  ENDIF.

  DESCRIBE TABLE t_fkkop               LINES h_t_fkkop_lines.
  DESCRIBE TABLE t_fkkop_not_submitted LINES h_t_fkkop_ns_lines.
  h_lines = h_t_fkkop_lines - h_t_fkkop_ns_lines - h_ht_dfkkop_lines.
  IF h_lines NE 0.
    t_fkkop_not_submitted[] = t_fkkop[].
    IF i_batch IS INITIAL.
      MESSAGE e457(>3) WITH h_t_fkkop_lines h_ht_dfkkop_lines
                            h_t_fkkop_ns_lines
                       RAISING error.
    ELSE.
      PERFORM message_append TABLES t_fimsg USING '>3' 'E' '457'
             h_t_fkkop_lines h_ht_dfkkop_lines h_t_fkkop_ns_lines space.
      RAISE error.
    ENDIF.
  ENDIF.

  t_dfkkcoll[] = ht_dfkkcoll[].

  IF h_ht_dfkkcoll_lines > 0.

*------- BW trigger needed ?
    CALL FUNCTION 'FKK_BW_TRIGGER_ACTIVE_CHECK'
      IMPORTING
        ev_active = loc_xbw.

*------- Recall items from Collection Agency -------------------------*
* KEIN ALLGEMEINER RÜCKRUF FÜR
*    LOOP AT t_fkkop.
*      lt-gpart = t_fkkop-gpart.
*      APPEND lt.
*    ENDLOOP.
*
*    SORT lt.
*    DELETE ADJACENT DUPLICATES FROM lt.
*
*    ht_agsta_range-sign   = 'I'.
*    ht_agsta_range-option = 'EQ'.
*    ht_agsta_range-low    = const_agsta_abgegeben.
*    APPEND ht_agsta_range.
*    ht_agsta_range-sign   = 'I'.
*    ht_agsta_range-option = 'EQ'.
*    ht_agsta_range-low    = const_agsta_teilbezahlt.
*    APPEND ht_agsta_range.
*    ht_agsta_range-sign   = 'I'.
*    ht_agsta_range-option = 'EQ'.
*    ht_agsta_range-low    = const_agsta_cust_p_pay.
*    APPEND ht_agsta_range.
*    ht_agsta_range-sign   = 'I'.
*    ht_agsta_range-option = 'EQ'.
*    ht_agsta_range-low    = const_agsta_p_paid.
*    APPEND ht_agsta_range.
*    ht_agsta_range-sign   = 'I'.
*    ht_agsta_range-option = 'EQ'.
*    ht_agsta_range-low    = const_agsta_sub_erfolglos.
*    APPEND ht_agsta_range.
**    ht_agsta_range-sign   = 'I'.
**    ht_agsta_range-option = 'EQ'.
**    ht_agsta_range-low    = const_agsta_erfolglos.
**    APPEND ht_agsta_range.
*
*    LOOP AT lt.
** select all positions already submitted
*      CALL FUNCTION 'FKK_COLLECT_AGENCY_ITEM_SELECT'
*        EXPORTING
*          i_gpart        = lt-gpart
*          ix_gpart       = 'X'
*        TABLES
*          t_agsta_range  = ht_agsta_range
*          t_fkkcoll      = t_subm_coll
*        EXCEPTIONS
*          initial_values = 1
*          not_found      = 2
*          OTHERS         = 3.
*      IF sy-subrc EQ 0.
*        APPEND LINES OF t_subm_coll TO t_all_coll.
*        CLEAR: t_subm_coll[], t_subm_coll.
*      ENDIF.
*    ENDLOOP.
*
**------- RECALL ITEMS -------------------------------------------------*
** ------ calls user exit 5065 -----------------------------------------*
*    PERFORM call_zp_fb_5065 TABLES t_dfkkcoll  "submitted positions
*                                   t_all_coll  "positions at Coll.Agency
*                                   t_recall_coll   "recalled positions
*                                   t_reassign_coll "reassigned positions
*                          CHANGING do_recall.
*
*    DESCRIBE TABLE t_recall_coll LINES h_ht_dfkkcoll_lines.
*    IF h_ht_dfkkcoll_lines GT 0 AND
*       NOT do_recall IS INITIAL.
*
*      SORT t_recall_coll BY opbel inkps.
*      LOOP AT t_recall_coll.
*
*        READ TABLE t_reassign_coll WITH KEY opbel = t_recall_coll-opbel
*                                            inkps = t_recall_coll-inkps.
*
*        IF sy-subrc = 0.
*          t_reassign_coll-agsta = const_agsta_freigegeben.
*          t_reassign_coll-agdat = '00000000'.
*          t_reassign_coll-xblnr = t_recall_coll-inkgp.
*          MODIFY t_reassign_coll INDEX sy-tabix.
*        ENDIF.
*
*        CLEAR h_inkps.
*
*        IF t_recall_coll-agsta EQ const_agsta_abgegeben      OR
*            t_recall_coll-agsta EQ const_agsta_recall        OR
**            t_recall_coll-agsta EQ const_agsta_erfolglos     OR
*            t_recall_coll-agsta EQ const_agsta_sub_erfolglos OR
*            t_recall_coll-agsta EQ const_agsta_rec_erfolglos.
*          t_recall_coll-agsta = const_agsta_recall.
*          t_recall_coll-rudat = sy-datlo.
** get recalling reason from posting area 1058
*          PERFORM read_buber_1058 CHANGING h_rugrd t_fkkop-applk.
*          IF NOT h_rugrd IS INITIAL.
*            t_recall_coll-rugrd = h_rugrd.
*          ENDIF.
*        ENDIF.
*        MODIFY t_recall_coll.
*      ENDLOOP.
** Conversion of currency and amounts in table DFKKCOLL according to
** table TFK042C (for EURO-Conversion)
*      PERFORM items_convert_currency TABLES  t_tfk042c
*                                             t_reassign_coll
*                                             t_fkkop.
*
*      t_recall_hist[] = t_recall_coll[].
*
*      LOOP AT t_reassign_coll.
*        READ TABLE t_recall_coll WITH KEY opbel = t_reassign_coll-opbel
*                                          inkps = t_reassign_coll-inkps.
*        IF sy-subrc EQ 0.
*          MOVE-CORRESPONDING t_reassign_coll TO t_recall_coll.
** maintain released amount in case the item was partially paid
*          IF t_recall_coll-betrz > 0.
*            SUBTRACT t_recall_coll-betrz FROM t_recall_coll-betrw.
*            CLEAR t_recall_coll-betrz.
*          ENDIF.
*          CLEAR: t_recall_coll-rudat, t_recall_coll-rugrd.
*          MODIFY t_recall_coll INDEX sy-tabix.
*        ENDIF.
*      ENDLOOP.
*
*      IF i_xsimu IS INITIAL.
** change records in table DFKKCOLL after recalling
*        CALL FUNCTION 'FKK_DB_DFKKCOLL_MODE'
*          EXPORTING
*            i_mode    = const_mode_modify
*          TABLES
*            t_fkkcoll = t_recall_coll
*          EXCEPTIONS
*            error     = 1
*            OTHERS    = 2.
*        IF sy-subrc <> 0.
*          IF NOT sy-batch IS INITIAL.
*            PERFORM message_append TABLES t_fimsg
*                                    USING '>3' 'E' '521'
*                                    'DFKKCOLL' space space space.
*          ELSE.
*            MESSAGE e521(>3) WITH 'DFKKCOLL' space space space.
*          ENDIF.
*        ELSE.
** delete locks for recalled postings
*          PERFORM delete_locks TABLES t_recall_coll
*                                      wt_fkkop.
*
** insert collection agency history table
*          PERFORM create_history TABLES t_recall_hist
*                                        t_history_coll
*                                        t_fimsg.
*
*          LOOP AT t_recall_coll.
*
*            CLEAR h_emgpa.
*
*            SELECT SINGLE emgpa FROM dfkkop INTO h_emgpa
*             WHERE opbel = t_recall_coll-opbel AND
*                   inkps = t_recall_coll-inkps.
*
*            IF NOT h_emgpa IS INITIAL.
*
*              CALL FUNCTION 'FKK_DB_TFK050B_SINGLE'
*                EXPORTING
*                  i_inkgp           = h_emgpa
*                EXCEPTIONS
*                  not_found         = 1
*                  initial_parameter = 2
*                  OTHERS            = 3.
*
*              IF sy-subrc EQ 0.
*
**------- collect trigger for BW
*                IF loc_xbw = 'X'.
*                  loct_bw_upd-opbel = t_recall_coll-opbel.
*                  COLLECT loct_bw_upd.
*                ENDIF.
*
*                UPDATE dfkkop SET emgpa = space
*                           WHERE opbel = t_recall_coll-opbel AND
*                                 inkps = t_recall_coll-inkps.
*
*                CLEAR: t_fkkop_o, t_fkkop_n, t_fkkop_o[], t_fkkop_n[].
*
*                READ TABLE t_fkkop WITH KEY opbel = t_recall_coll-opbel
*                                            inkps = t_recall_coll-inkps.
*
*                IF sy-subrc EQ 0.
*                  t_fkkop_o = t_fkkop_n = wt_fkkop.
*                  CLEAR t_fkkop_n-emgpa.
*                  APPEND: t_fkkop_n, t_fkkop_o.
*
*                  MOVE-CORRESPONDING t_fkkop TO it_fkkko.
**--- call generated function for update doc creation ------------------*
*                  CALL FUNCTION 'FKK_BELEG_WRITE_CHANGEDOC'
*                    EXPORTING
*                      opbel            = it_fkkko-opbel
*                      n_fkkko          = it_fkkko
*                      o_fkkko          = it_fkkko
*                    TABLES
*                      icdtxt_mkk_beleg = icdtxt_mkk_doc
*                      xfkkop           = t_fkkop_n
*                      yfkkop           = t_fkkop_o
*                      xfkkopk          = t_fkkopk  "not changed
*                      yfkkopk          = t_fkkopk  "not changed
*                      xfkkopw          = t_fkkopw  "not changed
*                      yfkkopw          = t_fkkopw. "not changed.
*                ENDIF.
*              ENDIF.
*            ENDIF.
*          ENDLOOP.
*
*        ENDIF.
*
** Insert new records
*        DESCRIBE TABLE t_reassign_coll LINES r_ht_dfkkcoll_lines.
*        IF r_ht_dfkkcoll_lines > 0.
** insert collection agency history table
*          PERFORM create_history TABLES t_reassign_coll
*                                        t_history_coll
*                                        t_fimsg.
*        ENDIF.
*      ENDIF.
*
** output message
*      LOOP AT t_recall_coll.
*        READ TABLE t_reassign_coll WITH KEY opbel = t_recall_coll-opbel
*                                            inkps = t_recall_coll-inkps.
*        IF sy-subrc = 0.
*          CONCATENATE t_recall_coll-opbel t_recall_coll-inkps
*                      INTO h_field SEPARATED BY '/'.
*          IF NOT i_batch IS INITIAL.
*            PERFORM message_append TABLES t_fimsg
*                                  USING '>3' 'S' '426' h_field
*                                    const_agsta_freigegeben space space.
**   for cross reference purpose only
*            IF 1 = 2. MESSAGE s426(>3). ENDIF.
*          ENDIF.
*        ELSE.
*          CONCATENATE t_recall_coll-opbel t_recall_coll-inkps
*                      INTO h_field SEPARATED BY '/'.
*          IF NOT i_batch IS INITIAL.
*            PERFORM message_append TABLES t_fimsg
*                                  USING '>3' 'S' '425' h_field
*                                    const_agsta_freigegeben space space.
**   for cross reference purpose only
*            IF 1 = 2. MESSAGE s425(>3). ENDIF.
*          ENDIF.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.

* Conversion of currency and amounts in table DFKKCOLL according to
* table TFK042C (for EURO-Conversion)
    PERFORM items_convert_currency TABLES  t_tfk042c
                                           ht_dfkkcoll
                                           t_fkkop.

*   PERFORM call_zp_fb_5054 TABLES ht_dfkkcoll
*                                  t_fkkop.

   t_dfkkcoll[] = ht_dfkkcoll[].

* ---- If there is a least one item to release for collection agency --*
    IF i_xsimu IS INITIAL.
      CALL FUNCTION 'FKK_DB_DFKKCOLL_MODE'
        EXPORTING
          i_mode    = const_mode_insert
        TABLES
          t_fkkcoll = ht_dfkkcoll
        EXCEPTIONS
          error     = 1
          OTHERS    = 2.
      IF sy-subrc <> 0.
        t_fkkop_not_submitted[] = t_fkkop[].
        IF i_batch IS INITIAL.
          MESSAGE e521(>3) WITH 'DFKKCOLL' RAISING error.
        ELSE.
          PERFORM message_append TABLES t_fimsg
                  USING '>3' 'E' '521' 'DFKKCOLL' space space space.
          RAISE error.
        ENDIF.
      ELSE.
* insert collection agency history table
        PERFORM create_history TABLES ht_dfkkcoll
                                      t_history_coll
                                      t_fimsg.

* resolve repetition positions for budget billing position (STAKZ = P)
* resolve repetition positions for installment plan (STAKZ = R)
        DATA: st_fkkop LIKE sfkkop OCCURS 0 WITH HEADER LINE,
              gt_fkkop LIKE fkkop  OCCURS 0 WITH HEADER LINE,
              t_fkkko  LIKE fkkko  OCCURS 0 WITH HEADER LINE,
              LT_W_DFKKOP LIKE FKKOP OCCURS 0 WITH HEADER LINE,
              g_index  LIKE sy-tabix.

        SORT ht_dfkkop BY opbel opupk opupw.
*        LOOP AT ht_dfkkop INTO gt_fkkop WHERE stakz EQ 'P'
*                                           OR stakz EQ 'R'.

        LOOP AT HT_DFKKOP INTO GT_FKKOP WHERE WHGRP NE '000'
                                          AND STAKZ NE SPACE.
          APPEND GT_FKKOP TO LT_W_DFKKOP.
        ENDLOOP.

        LOOP AT LT_W_DFKKOP INTO gt_fkkop WHERE whgrp NE '000'
                                          AND stakz NE space.

          AT NEW opbel.
            CLEAR: rt_fkkop, st_fkkop.
            REFRESH: rt_fkkop, st_fkkop.
            CALL FUNCTION 'FKK_READ_DOC_INTO_LOGICAL'
              EXPORTING
                i_opbel         = gt_fkkop-opbel
                i_accumulate    = space
              TABLES
                t_logfkkop      = rt_fkkop
              EXCEPTIONS
                opbel_not_found = 1
                OTHERS          = 2.
            IF sy-subrc NE 0.
              CONTINUE.
            ENDIF.

            APPEND LINES OF rt_fkkop TO st_fkkop.

            CALL FUNCTION 'FKK_DOC_HEADER_SELECT_BY_OPBEL'
              EXPORTING
                i_opbel = gt_fkkop-opbel
              IMPORTING
                e_fkkko = t_fkkko.
            APPEND t_fkkko.
          ENDAT.

          READ TABLE st_fkkop WITH KEY opbel = gt_fkkop-opbel
                                       opupw = gt_fkkop-opupw
                                       opupk = gt_fkkop-opupk
                                       opupz = gt_fkkop-opupz.
          g_index = sy-tabix.
          IF sy-subrc NE 0.
            CONTINUE.
          ENDIF.

          st_fkkop-inkps = gt_fkkop-inkps.
          MODIFY st_fkkop INDEX g_index.

          AT END OF opbel.
            CALL FUNCTION 'FKK_CREATE_DOC_FROM_LOGICAL'
              EXPORTING
                i_mode        = 'V'
                i_accumulate  = space
                i_calc_tax    = space                " Note 1050078
              TABLES
                i_logfkkop    = st_fkkop
                i_fkkko       = t_fkkko
              EXCEPTIONS
                error_message = 1
                OTHERS        = 2.
            IF sy-subrc <> 0.
              IF i_batch IS INITIAL.
                MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                       RAISING error.
              ELSE.
                PERFORM message_append TABLES t_fimsg
                           USING sy-msgid sy-msgty sy-msgno
                               sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv3.
                RAISE error.
              ENDIF.
            ENDIF.
          ENDAT.
        ENDLOOP.

* update DFKKOP for field INKPS
        IF i_buffered_docs_allowed IS INITIAL.
          DESCRIBE TABLE ht_dfkkop LINES h_lines.
          LOOP AT ht_dfkkop.
            CONCATENATE ht_dfkkop-opbel ht_dfkkop-opupw ht_dfkkop-opupk
                        ht_dfkkop-opupz INTO h_field SEPARATED BY '/'.
            h_inkps = ht_dfkkop-inkps.
            CALL FUNCTION 'FKK_BP_LINE_ITEM_SELECT_SINGLE'
              EXPORTING
                i_opbel = ht_dfkkop-opbel
                i_opupw = ht_dfkkop-opupw
                i_opupk = ht_dfkkop-opupk
                i_opupz = ht_dfkkop-opupz
              IMPORTING
                e_fkkop = ht_fkkop.
            ht_dfkkop-inkps = h_inkps.
            IF i_aggrd EQ const_aggrd_ausbuchen.
              ut_dfkkop-inkps = ht_dfkkop-inkps.
              ut_dfkkop-opbel = ht_dfkkop-opbel.
              ut_dfkkop-opupw = ht_dfkkop-opupw.
              ut_dfkkop-opupk = ht_dfkkop-opupk.
              ut_dfkkop-opupz = ht_dfkkop-opupz.
              APPEND ut_dfkkop.
            ELSE.
              UPDATE dfkkop SET   inkps = ht_dfkkop-inkps
                            WHERE opbel = ht_dfkkop-opbel
                            AND   opupw = ht_dfkkop-opupw
                            AND   opupk = ht_dfkkop-opupk
                            AND   opupz = ht_dfkkop-opupz.
            ENDIF.
            IF sy-subrc = 0.

*------- collect trigger for BW
              IF loc_xbw = 'X'.
                loct_bw_upd-opbel = ht_dfkkop-opbel.
                COLLECT loct_bw_upd.
              ENDIF.

              IF ht_dfkkop-betrw > 0.
                IF i_batch IS INITIAL AND NOT i_xsimu EQ 'X'.
                  IF h_lines > 1.
                    MESSAGE s454(>3) WITH h_lines.
                  ELSE.
                    MESSAGE s549(>3)
                            WITH h_field const_agsta_freigegeben.
                  ENDIF.
                ELSE.
                  PERFORM message_append TABLES t_fimsg
                                         USING '>3' 'S' '549' h_field
                                    const_agsta_freigegeben space space.
                ENDIF.
              ELSE.
                IF i_batch IS INITIAL AND NOT i_xsimu EQ 'X'.
                  IF h_lines > 1.
                    MESSAGE s454(>3) WITH h_lines.
                  ELSE.
                    MESSAGE s051(>i)
                            WITH h_field const_agsta_freigegeben.
                  ENDIF.
                ELSE.
                  PERFORM message_append TABLES t_fimsg
                                         USING '>I' 'S' '051' h_field
                                    const_agsta_freigegeben space space.
                ENDIF.
              ENDIF.
            ELSE.
              t_fkkop_not_submitted[] = t_fkkop[].
              IF i_batch IS INITIAL.
                MESSAGE e547(>3) WITH ht_dfkkop-inkps h_field
                                 RAISING error.
              ELSE.
                PERFORM message_append TABLES t_fimsg
                                   USING '>3' 'E' '547' ht_dfkkop-inkps
                                             h_field space space.
                RAISE error.
              ENDIF.
            ENDIF.
          ENDLOOP.

          IF i_aggrd EQ const_aggrd_ausbuchen.
            PERFORM db_dfkkop_update ON COMMIT.
          ENDIF.
        ELSE.
          CALL FUNCTION 'FKK_CHANGE_DOCUMENT_IN_BUFFER'
            EXPORTING
              i_change_inkps = const_marked
            TABLES
              t_fkkop        = ht_dfkkop.
        ENDIF.
      ENDIF.

*------- forward trigger tables for BW
      IF loc_xbw = 'X'.
        CALL FUNCTION 'FKK_DFKKKOBW_UPDATE'
          CHANGING
            ct_dfkkkobw_update = loct_bw_upd[]
          EXCEPTIONS
            OTHERS             = 0.
      ENDIF.

    ELSE.
      DESCRIBE TABLE ht_dfkkop LINES h_lines.
      LOOP AT ht_dfkkop.
        CONCATENATE ht_dfkkop-opbel ht_dfkkop-opupw ht_dfkkop-opupk
                    ht_dfkkop-opupz INTO h_field SEPARATED BY '/'.
        IF ht_dfkkop-betrw > 0.
          IF i_batch IS INITIAL AND NOT i_xsimu EQ 'X'.
            MESSAGE s549(>3) WITH h_field const_agsta_freigegeben.
          ELSE.
            PERFORM message_append TABLES t_fimsg
                                   USING '>3' 'S' '549' h_field
                                    const_agsta_freigegeben space space.
          ENDIF.
        ELSE.
          IF i_batch IS INITIAL AND NOT i_xsimu EQ 'X'.
            IF h_lines > 1.
              MESSAGE s454(>3) WITH h_lines.
            ELSE.
              MESSAGE s051(>i)
                      WITH h_field const_agsta_freigegeben.
            ENDIF.
          ELSE.
            PERFORM message_append TABLES t_fimsg
                                   USING '>I' 'S' '051' h_field
                              const_agsta_freigegeben space space.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

* ------ Reset internal tables ----------------------------------------*
  CLEAR:   ht_fkkop, ht_dfkkop, ht_dfkkcoll, ht_fimsg, h_man_sel.
  REFRESH: ht_fkkop, ht_dfkkop, ht_dfkkcoll, ht_fimsg.
  CLEAR:   h_ht_dfkkcoll_lines, r_ht_dfkkcoll_lines.
ENDFUNCTION.
