*----------------------------------------------------------------------*
***INCLUDE /ADESSO/LINKASSO_FGF04.
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  read_tfk042c
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM read_tfk042c TABLES   p_t_tfk042c STRUCTURE tfk042c.

  DESCRIBE TABLE p_t_tfk042c LINES sy-tfill.

  IF sy-tfill = 0.
    SELECT * FROM  tfk042c INTO TABLE p_t_tfk042c
            WHERE proid = const_proid
              AND datum <= sy-datum.
  ENDIF.
  SORT p_t_tfk042c BY datum DESCENDING.

ENDFORM.                               " read_tfk042c

*&---------------------------------------------------------------------*
*&      Form  CALL_ZP_FB_5065
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM call_zp_fb_5065 TABLES   pt_dfkkcoll      STRUCTURE dfkkcoll
                              pt_all_coll      STRUCTURE dfkkcoll
                              pt_recall_coll   STRUCTURE dfkkcoll
                              pt_reassign_coll STRUCTURE dfkkcoll
                   CHANGING   do_recall.

  DATA: i_fbstab  LIKE tfkfbc OCCURS 1 WITH HEADER LINE,
        p_h_applk LIKE bfkkzgr00-applk.

* ------ determinig application ---------------------------------------*
  CALL FUNCTION 'FKK_GET_APPLICATION'
    IMPORTING
      e_applk       = p_h_applk
    EXCEPTIONS
      error_message = 1.

  CALL FUNCTION 'FKK_FUNC_MODULE_DETERMINE'
    EXPORTING
      i_applk  = p_h_applk
      i_fbeve  = const_event_5065
    TABLES
      t_fbstab = i_fbstab.

* ------ for cross reference purpose only -----------------------------*
  SET EXTENDED CHECK OFF.
  IF 1 = 2.
    CALL FUNCTION 'FKK_SAMPLE_5065'.
  ENDIF.
  SET EXTENDED CHECK ON.
* ------ end of cross reference ---------------------------------------*

  LOOP AT i_fbstab.
    CALL FUNCTION i_fbstab-funcc
      TABLES
        t_dfkkcoll      = pt_dfkkcoll
        t_all_coll      = pt_all_coll
        t_recall_coll   = pt_recall_coll
        t_reassign_coll = pt_reassign_coll
      CHANGING
        do_recall       = do_recall
      EXCEPTIONS
        error_found     = 1
        OTHERS          = 2.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
               RAISING general_fault.
    ENDIF.
  ENDLOOP.
ENDFORM.                               " CALL_ZP_FB_5065

*&---------------------------------------------------------------------*
*&      Form  delete_locks
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM delete_locks TABLES   t_change_coll STRUCTURE dfkkcoll
                           t_fkkop       STRUCTURE fkkop.

  DATA:     h_loobj1    LIKE dfkklocks-loobj1,
            h_tfk033d   LIKE tfk033d,
            h_spzah     LIKE fkkop-spzah,
            h_mansp     LIKE fkkop-mansp,
            t_dfkklocks LIKE TABLE OF dfkklocks WITH HEADER LINE.

  CONSTANTS:const_proid_spzah   LIKE tfk080f-proid VALUE '10',
            const_proid_mansp   LIKE tfk080f-proid VALUE '01',
            const_lotyp_dfkkop  LIKE tfk080b-lotyp VALUE '02',
            const_buber_1054    LIKE tfk033c-buber VALUE '1054'.

* read dunning and payment lock indicator posting area 1054
  CLEAR h_tfk033d.
  CALL FUNCTION 'FKK_GET_APPLICATION'
    EXPORTING
      i_no_dialog      = const_marked
    IMPORTING
      e_applk          = h_tfk033d-applk
    EXCEPTIONS
      no_appl_selected = 1
      OTHERS           = 2.
  h_tfk033d-buber = const_buber_1054.
  PERFORM account_determine CHANGING h_tfk033d.
  h_spzah = h_tfk033d-fun01.
  h_mansp = h_tfk033d-fun02.

  LOOP AT t_change_coll.
    CALL FUNCTION 'FKK_BP_LINE_ITEMS_SELECT'
      EXPORTING
        i_opbel  = t_change_coll-opbel
        ix_opbel = 'X'
        i_inkps  = t_change_coll-inkps
        ix_inkps = 'X'
      TABLES
        pt_fkkop = t_fkkop.

    LOOP AT t_fkkop.
* get locks for open items
      CLEAR: t_dfkklocks, t_dfkklocks[].
      CALL FUNCTION 'FKK_S_LOCK_GET_FOR_DOC_ITEMS'
        EXPORTING
          i_opbel  = t_fkkop-opbel
          i_opupw  = t_fkkop-opupw
          i_opupk  = t_fkkop-opupk
          i_opupz  = t_fkkop-opupz
        TABLES
          et_locks = t_dfkklocks.

      h_loobj1    = t_fkkop-opbel.
      h_loobj1+12 = t_fkkop-opupw.
      h_loobj1+15 = t_fkkop-opupk.
      h_loobj1+19 = t_fkkop-opupz.

      READ TABLE t_dfkklocks WITH KEY loobj1 = h_loobj1
                                      lotyp  = const_lotyp_dfkkop
                                      proid  = const_proid_spzah
                                      lockr  = h_spzah
                                      gpart  = t_fkkop-gpart
                                      vkont  = t_fkkop-vkont.
      IF sy-subrc = 0.
* ------ Delete payment lock ------------------------------------------*
        PERFORM locks_delete USING t_fkkop-gpart
                                   t_fkkop-vkont
                                   h_loobj1 const_proid_spzah
                                   const_lotyp_dfkkop h_spzah
                                   t_dfkklocks-fdate t_dfkklocks-tdate.
      ENDIF.

      READ TABLE t_dfkklocks WITH KEY loobj1 = h_loobj1
                                      lotyp  = const_lotyp_dfkkop
                                      proid  = const_proid_mansp
                                      lockr  = h_mansp
                                      gpart  = t_fkkop-gpart
                                      vkont  = t_fkkop-vkont.

      IF sy-subrc = 0.
* ------ Delete dunning lock ------------------------------------------*
        PERFORM locks_delete USING t_fkkop-gpart
                                   t_fkkop-vkont
                                   h_loobj1 const_proid_mansp
                                   const_lotyp_dfkkop h_mansp
                                   t_dfkklocks-fdate t_dfkklocks-tdate.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " delete_locks

*&---------------------------------------------------------------------*
*&      Form  account_determine
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM account_determine CHANGING ps_tfk033d STRUCTURE tfk033d.
* ------ Anwendungsspezifische Daten lesen ----------------------------*
  CALL FUNCTION 'FKK_ACCOUNT_DETERMINE'
    EXPORTING
      i_tfk033d           = ps_tfk033d
    IMPORTING
      e_tfk033d           = ps_tfk033d
    EXCEPTIONS
      error_in_input_data = 1
      nothing_found       = 2
      OTHERS              = 3.
* ------ for cross reference purpose only -----------------------------*
  SET EXTENDED CHECK OFF.
  IF 1 = 2. CALL FUNCTION 'FKK_ACCOUNT_DETERMINE_1054'. ENDIF.
  SET EXTENDED CHECK ON.
* ------ end of cross reference ---------------------------------------*
ENDFORM.                               " ACCOUNT_DETERMINE


*&---------------------------------------------------------------------*
*&      Form  LOCKS_delete
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM locks_delete USING p_gpart p_vkont p_loobj1 p_proid
                        p_lotyp p_lockr p_fdate p_tdate.

  CALL FUNCTION 'FKK_S_LOCK_DELETE'
    EXPORTING
      i_loobj1              = p_loobj1
      i_gpart               = p_gpart
      i_vkont               = p_vkont
      i_proid               = p_proid
      i_lotyp               = p_lotyp
      i_lockr               = p_lockr
      i_fdate               = p_fdate
      i_tdate               = p_tdate
    EXCEPTIONS
      already_exist         = 1
      imp_data_not_complete = 2
      no_authority          = 3
      enqueue_lock          = 4
      data_protected        = 5
      OTHERS                = 6.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " LOCKS_delete

*&---------------------------------------------------------------------*
*&      Form  create_history
*&---------------------------------------------------------------------*
*       dfkkcoll history
*----------------------------------------------------------------------*
FORM create_history TABLES   p_t_coll         STRUCTURE dfkkcoll
                             p_t_history_coll STRUCTURE dfkkcollh
                             p_t_fimsg        STRUCTURE fimsg.

  DATA: h_lfdnr      LIKE dfkkcollh-lfdnr,
        ht_fkkcollh  LIKE dfkkcollh OCCURS 0 WITH HEADER LINE.

  CLEAR: p_t_history_coll, p_t_history_coll[].

  LOOP AT p_t_coll.
    MOVE-CORRESPONDING p_t_coll TO p_t_history_coll.

    IF ( NOT p_t_history_coll-rudat IS INITIAL AND
       NOT p_t_history_coll-rugrd IS INITIAL ) AND
       NOT p_t_history_coll-agsta EQ const_agsta_recall.
      CLEAR: p_t_history_coll-rugrd, p_t_history_coll-rudat.
    ENDIF.

* maintain released amount in case the item was partially paid
    IF p_t_coll-betrz > 0 AND p_t_coll-agsta = const_agsta_freigegeben.
      SUBTRACT p_t_history_coll-betrz FROM p_t_history_coll-betrw.
      CLEAR p_t_history_coll-betrz.
    ENDIF.

    p_t_history_coll-aenam = sy-uname.
    p_t_history_coll-acpdt = sy-datlo.
    p_t_history_coll-acptm = sy-timlo.

    CALL FUNCTION 'FKK_DB_DFKKCOLLH_COUNT'
      EXPORTING
        i_opbel = p_t_history_coll-opbel
        i_inkps = p_t_history_coll-inkps
      IMPORTING
        e_count = h_lfdnr.

    IF p_t_history_coll-agsta GE '20'.
      CALL FUNCTION 'FKK_DB_DFKKCOLLH_SELECT'
        EXPORTING
          i_seltyp   = '2'
          i_opbel    = p_t_coll-opbel
          i_inkps    = p_t_coll-inkps
        TABLES
          t_fkkcollh = ht_fkkcollh
        EXCEPTIONS
          not_found  = 1
          OTHERS     = 2.

      READ TABLE ht_fkkcollh INDEX h_lfdnr.
      IF sy-subrc = 0.
        p_t_history_coll-agsta_or = ht_fkkcollh-agsta_or.
      ELSE.
        p_t_history_coll-agsta_or = p_t_history_coll-agsta.
      ENDIF.
    ELSE.
      p_t_history_coll-agsta_or = p_t_history_coll-agsta.
    ENDIF.

    ADD 1 TO h_lfdnr.

    p_t_history_coll-lfdnr = h_lfdnr.

    APPEND p_t_history_coll.
  ENDLOOP.

  CALL FUNCTION 'FKK_DB_DFKKCOLLH_INSERT'
    TABLES
      i_dfkkcollh = p_t_history_coll.

ENDFORM.                    " create_history

*&---------------------------------------------------------------------*
*&      Form  changedocument_write
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM changedocument_write TABLES p_fkkcoll_new STRUCTURE dfkkcoll
                                 p_fkkcoll_old STRUCTURE dfkkcoll.

  DATA: h_cdtxt LIKE cdtxt OCCURS 0,
        h_field LIKE cdhdr-objectid.

  LOOP AT p_fkkcoll_old.
    READ TABLE p_fkkcoll_new WITH KEY opbel = p_fkkcoll_old-opbel
                                      inkps = p_fkkcoll_old-inkps.
    IF p_fkkcoll_old NE p_fkkcoll_new.
      MOVE-CORRESPONDING p_fkkcoll_old TO ydfkkcoll.
      APPEND ydfkkcoll.
      MOVE-CORRESPONDING p_fkkcoll_new TO xdfkkcoll.
      xdfkkcoll-kz = 'U'.
      APPEND xdfkkcoll.
      CONCATENATE p_fkkcoll_old-opbel p_fkkcoll_old-inkps INTO h_field.
      CALL FUNCTION 'INKASSO_01_WRITE_DOCUMENT'
        EXPORTING
          objectid                = h_field
          tcode                   = sy-tcode
          utime                   = sy-uzeit
          udate                   = sy-datlo
          username                = sy-uname
          planned_or_real_changes = 'R'
          upd_dfkkcoll            = 'U'
        TABLES
          icdtxt_inkasso_01       = h_cdtxt
          xdfkkcoll               = xdfkkcoll
          ydfkkcoll               = ydfkkcoll
        EXCEPTIONS
          OTHERS                  = 1.
      REFRESH: xdfkkcoll, ydfkkcoll.
    ENDIF.
  ENDLOOP.
ENDFORM.                               " changedocument_write

*&---------------------------------------------------------------------*
*&      Form  items_convert_currency
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM items_convert_currency TABLES  p_t_tfk042c STRUCTURE tfk042c
                                    t_fkkcoll   STRUCTURE dfkkcoll
                                    t_fkkop     STRUCTURE fkkop.
  DATA: lt_bukrs   LIKE fkkop-bukrs,
        ls_fkkvkp  TYPE fkkvkp,
        LS_FKKOP   TYPE FKKOP,
        ls_fkkop_cprc   TYPE fkkop_cprc,
        lv_0119_unused  TYPE xfeld.

  FIELD-SYMBOLS <DFKKCOLL> TYPE dfkkcoll.

* Exchange of processing currency (e.g. if country has left the EURO zone
* and some of old EURO items have to be processed in the new local currency
* (event 0119)
  LOOP AT t_fkkcoll ASSIGNING <DFKKCOLL>.
    MOVE-CORRESPONDING <DFKKCOLL> TO LS_FKKOP.
    CALL FUNCTION 'FKK_OPEN_ITEM_CHANGE_PROC_CURR'
      EXPORTING
        i_procid      = '01'
        i_fkkop       = ls_fkkop
      IMPORTING
        e_fkkop_cprc  = ls_fkkop_cprc
        e_0119_unused = lv_0119_unused.
    IF lv_0119_unused = 'X'.
      EXIT.
    ENDIF.
    IF  ls_fkkop_cprc-waers NE space
    AND ls_fkkop_cprc-waers NE <DFKKCOLL>-waers.
      MOVE-CORRESPONDING LS_FKKOP_CPRC TO <DFKKCOLL>.
    ENDIF.
  ENDLOOP.

  DESCRIBE TABLE p_t_tfk042c LINES sy-tfill.
  IF sy-tfill = 0.
    EXIT.
  ELSE.
    LOOP AT t_fkkcoll.

* -- determine company code group as of 4.72 --------------------------*
      CALL FUNCTION 'FKK_ACCOUNT_READ'
        EXPORTING
          i_vkont      = t_fkkcoll-vkont
          i_gpart      = t_fkkcoll-gpart
          i_only_gpart = const_marked
        IMPORTING
          e_fkkvkp     = ls_fkkvkp
        EXCEPTIONS
          not_found    = 1
          foreign_lock = 2
          not_valid    = 3
          OTHERS       = 4.

      IF sy-subrc EQ 0.
        READ TABLE p_t_tfk042c WITH KEY proid = const_proid
                                        opbuk = ls_fkkvkp-opbuk
                                        waers = t_fkkcoll-waers.
      ELSE.

        READ TABLE t_fkkop WITH KEY opbel = t_fkkcoll-opbel
                                    inkps = t_fkkcoll-inkps.

        IF sy-subrc EQ 0 AND NOT t_fkkop-bukrs IS INITIAL.
          MOVE t_fkkop-bukrs TO lt_bukrs.
        ELSE.
          SELECT bukrs FROM dfkkop INTO lt_bukrs
                                  WHERE opbel = t_fkkcoll-opbel.
          ENDSELECT.
        ENDIF.

        READ TABLE p_t_tfk042c WITH KEY proid = const_proid
                                        opbuk = lt_bukrs
                                        waers = t_fkkcoll-waers.
      ENDIF.

      IF sy-subrc EQ 0.

        CHECK p_t_tfk042c-datum LE sy-datum.

        CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
          EXPORTING
            date             = sy-datum
            foreign_amount   = t_fkkcoll-betrw
            foreign_currency = t_fkkcoll-waers
            local_currency   = p_t_tfk042c-rwaer
          IMPORTING
            local_amount     = t_fkkcoll-betrw
          EXCEPTIONS
            OTHERS           = 1.

        t_fkkcoll-waers = p_t_tfk042c-rwaer.
        MODIFY t_fkkcoll.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                               " items_convert_currency

*&---------------------------------------------------------------------*
*&      Form  MESSAGE_APPEND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM message_append TABLES pt_fimsg STRUCTURE fimsg
                    USING  p_msgid p_msgty p_msgno
                           p_msgv1 p_msgv2 p_msgv3 p_msgv4.

  CLEAR pt_fimsg.
  pt_fimsg-msgid = p_msgid.
  pt_fimsg-msgty = p_msgty.
  pt_fimsg-msgno = p_msgno.
  pt_fimsg-msgv1 = p_msgv1.
  pt_fimsg-msgv2 = p_msgv2.
  pt_fimsg-msgv3 = p_msgv3.
  pt_fimsg-msgv4 = p_msgv4.
  APPEND pt_fimsg.

ENDFORM.                               " MESSAGE_APPEND

*&---------------------------------------------------------------------*
*&      Form  READ_EVENTS_FOR_RELEASE
*&---------------------------------------------------------------------*
FORM read_events_for_release .

  DATA: p_applk LIKE fkkop-applk.

* ------ determinig application ---------------------------------------*
  CALL FUNCTION 'FKK_GET_APPLICATION'
    IMPORTING
      e_applk       = p_applk
    EXCEPTIONS
      error_message = 1.

* Determine function modules for events 5059, 5060 --------------------*
  REFRESH t_tfkfbc_5059.
  CALL FUNCTION 'FKK_FUNC_MODULE_DETERMINE'
    EXPORTING
      i_fbeve  = const_event_5059
      i_applk  = p_applk
    TABLES
      t_fbstab = t_tfkfbc_5059
    EXCEPTIONS
      OTHERS   = 1.

  REFRESH t_tfkfbc_5060.
  CALL FUNCTION 'FKK_FUNC_MODULE_DETERMINE'
    EXPORTING
      i_fbeve  = const_event_5060
      i_applk  = p_applk
    TABLES
      t_fbstab = t_tfkfbc_5060
    EXCEPTIONS
      OTHERS   = 1.

  REFRESH t_tfkfbc_5054.
  CALL FUNCTION 'FKK_FUNC_MODULE_DETERMINE'
    EXPORTING
      i_fbeve  = const_event_5054
      i_applk  = p_applk
    TABLES
      t_fbstab = t_tfkfbc_5054
    EXCEPTIONS
      OTHERS   = 1.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CALL_ZP_FB_5059
*&---------------------------------------------------------------------*
*       delete position for releasing to a collection agency
*----------------------------------------------------------------------*
FORM call_zp_fb_5059 TABLES   pt_fkkop_not_submitted STRUCTURE fkkop
                     USING    h_fkkop  STRUCTURE fkkop
                     CHANGING h_rel_instpln LIKE boole-boole.

  REFRESH: pt_fkkop_not_submitted.

  LOOP AT t_tfkfbc_5059.
    CALL FUNCTION t_tfkfbc_5059-funcc
      EXPORTING
        i_fkkop               = h_fkkop
      TABLES
        t_fkkop_not_submitted = pt_fkkop_not_submitted
      CHANGING
        i_rel_instpln         = h_rel_instpln.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDLOOP.
* ------ for cross reference purpose only -----------------------------*
  SET EXTENDED CHECK OFF.
  IF 1 = 2.
    CALL FUNCTION 'FKK_SAMPLE_5059'.
  ENDIF.
  SET EXTENDED CHECK ON.
* ------ end of cross reference ---------------------------------------*
ENDFORM.                               " CALL_ZP_FB_5059

*&---------------------------------------------------------------------*
*&      Form  CALL_ZP_FB_5060
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM call_zp_fb_5060 TABLES   pt_fkkop STRUCTURE fkkop
                      USING   p_fkkop  STRUCTURE fkkop
                   CHANGING   p_inkgp.

  CHECK h_man_sel IS INITIAL.

  LOOP AT t_tfkfbc_5060.
    CALL FUNCTION t_tfkfbc_5060-funcc
      EXPORTING
        i_fkkop   = p_fkkop
      IMPORTING
        e_inkgp   = p_inkgp
        e_man_sel = h_man_sel
      TABLES
        t_fkkop   = pt_fkkop
      EXCEPTIONS
        OTHERS    = 1.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDLOOP.
* ------ for cross reference purpose only -----------------------------*
  SET EXTENDED CHECK OFF.
  IF 1 = 2.
    CALL FUNCTION 'FKK_SAMPLE_5060'.
  ENDIF.
  SET EXTENDED CHECK ON.
* ------ end of cross reference ---------------------------------------*
ENDFORM.                               " CALL_ZP_FB_5060

*&---------------------------------------------------------------------*
*&      Form  DB_DFKKOP_UPDATE
*&---------------------------------------------------------------------*
FORM db_dfkkop_update.
  LOOP AT ut_dfkkop.
    UPDATE dfkkop SET   inkps = ut_dfkkop-inkps
                  WHERE opbel = ut_dfkkop-opbel
                  AND   opupw = ut_dfkkop-opupw
                  AND   opupk = ut_dfkkop-opupk
                  AND   opupz = ut_dfkkop-opupz.
  ENDLOOP.

  REFRESH ut_dfkkop.
ENDFORM.                    " DB_DFKKOP_UPDATE
