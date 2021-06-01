FUNCTION /adesso/fkk_sample_1729.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_LOW) TYPE  C
*"     VALUE(I_HIGH) TYPE  C
*"     VALUE(I_FKKCOCC) LIKE  FKKCOCC STRUCTURE  FKKCOCC OPTIONAL
*"     VALUE(I_FKK_PROT) LIKE  FKKPROT STRUCTURE  FKKPROT OPTIONAL
*"     VALUE(I_BASICS) TYPE  FKK_MAD_BASICS OPTIONAL
*"  TABLES
*"      T_COUNTER STRUCTURE  FKK_MASS_ACT_COUNT
*"      T_FIMSG STRUCTURE  FIMSG OPTIONAL
*"      T_BUKRS STRUCTURE  FKKR_BUKRS OPTIONAL
*"      T_GPART STRUCTURE  FKKR_GPART OPTIONAL
*"      T_VKONT STRUCTURE  FKKR_VKONT OPTIONAL
*"      T_FKKCOINFO STRUCTURE  FKKCOINFO OPTIONAL
*"      T_PROT_GPART STRUCTURE  FKKR_GPART OPTIONAL
*"      T_PROT_VKONT STRUCTURE  FKKR_VKONT OPTIONAL
*"  CHANGING
*"     VALUE(C_TEST_NUM) TYPE  I
*"     VALUE(C_SUCCESS_NUM) TYPE  I
*"----------------------------------------------------------------------
* Deklarationen
  DATA: t_fkkcoll       LIKE dfkkcoll       OCCURS 0 WITH HEADER LINE.
  DATA: t_fkkcollh      LIKE dfkkcollh      OCCURS 0 WITH HEADER LINE.
  DATA: wt_fkkcollh     LIKE dfkkcollh      OCCURS 0 WITH HEADER LINE.
  DATA: t_fkkcoli_log   LIKE dfkkcoli_log   OCCURS 0 WITH HEADER LINE.
  DATA: wt_fkkcoli_log  LIKE dfkkcoli_log   OCCURS 0 WITH HEADER LINE.
  DATA: t_fkkcoll_ch    LIKE dfkkcoll_ch    OCCURS 0 WITH HEADER LINE.
  DATA: t_fkkcollh_i_w  LIKE dfkkcollh_i_w  OCCURS 0 WITH HEADER LINE.
  DATA: t_fkkcollh_i_w_db LIKE dfkkcollh_i_w  OCCURS 0 WITH HEADER LINE.
  DATA: t_fkkcollp_ip_w LIKE dfkkcollp_ip_w OCCURS 0 WITH HEADER LINE.
  DATA: t_fkkcollp_ir_w LIKE dfkkcollp_ir_w OCCURS 0 WITH HEADER LINE.
  DATA: t_fkkcollp_im_w LIKE dfkkcollp_im_w OCCURS 0 WITH HEADER LINE.
  DATA: t_fkkcollt_i_w  LIKE dfkkcollt_i_w  OCCURS 0 WITH HEADER LINE.
  DATA: w_fkkcollh_alt  LIKE dfkkcollh.
  DATA: i_fkkcoll       LIKE dfkkcoll.
  DATA: i_fkkcoli_log   LIKE dfkkcoli_log.
  DATA: h_gpart_low     LIKE fkkop-gpart.
  DATA: h_gpart_high    LIKE fkkop-gpart.
  DATA: h_runkey        TYPE fkk_mad_runkey.
  DATA: h_no_work_to_do TYPE xfeld.
  DATA: h_intnr         TYPE intnr_kk.
  DATA: h_intnr_c       TYPE intnr_i_kk.
  DATA: h_tfill         LIKE sy-tfill.
  DATA: h_applk         LIKE bfkkzgr00-applk.
  DATA: cursor          TYPE cursor.
  DATA: h_limit         LIKE sy-dbcnt.
  DATA: h_lfd_m         LIKE dfkkcollp_im_w-lfnum.
  DATA: h_lfd_r         LIKE dfkkcollp_ir_w-lfnum.
  DATA: h_lfd_p         LIKE dfkkcollp_ip_w-lfnum.
  DATA: h_jobnr(3)      TYPE n.
  DATA: h_storno        TYPE c.
  DATA: h_betrag        TYPE betrz_kk.
  DATA: h_sdat          TYPE d.
  DATA: h_bukrs         TYPE bukrs.
  DATA: h_lfdnr         TYPE lfdnr_kk.
  DATA: h_fall          TYPE i.
  DATA: h_inkkey(25)    TYPE c.
  DATA: h_herkf         TYPE herkf_kk.
  DATA: h_logtb         TYPE c.
  DATA: x_logknz        TYPE c.
  DATA: x_delivered     TYPE c.
  DATA: h_collh09       TYPE dfkkcollh.
  DATA: old_inkgp       TYPE inkgp_kk.
  DATA: w_nofst         TYPE c.
  DATA: w_fkkcollh      LIKE t_fkkcollh.
*---------------- definitions for job and application log -------------*
  DATA: wa_objkey     TYPE         swo_typeid,
        wa_objtype    TYPE         swo_objtyp,
        h_test_num    TYPE         i,
        h_success_num TYPE         i,
        h_error_num   TYPE         i,
        wa_t_counter  LIKE LINE OF t_counter.

  DATA lt_collitem         TYPE fkkcollitem_tab.
  DATA lt_collpaym         TYPE fkkcollpaym_tab.
  DATA lt_collpaymlink     TYPE fkkcollpaymlink_tab.
  DATA ls_collections_out  TYPE fkkcollections_out.
  DATA lt_collections_out  TYPE fkkcollections_out_tab.
  DATA lt_coli_log         TYPE fkkcoli_log_tab.
  DATA lt_postyp_sum       TYPE fkkcol_postyp_sum_tab.
  DATA lx_counter_msg      TYPE i.
  DATA lv_cnt_services     TYPE i.
  DATA lv_cnt_services_error  TYPE i.
  DATA lv_flg_error        TYPE xfeld.
  DATA lv_flg_continue     TYPE xfeld.
  DATA lx_call_service     TYPE xfeld.
  DATA lx_cnt_master_data_ch  TYPE i.
  DATA lv_xiguid           TYPE guidxi_kk.
  DATA: lt_gpart_inkgp_submitted LIKE TABLE OF t_gpart_inkgp,
        lt_inkgp_gpart_submitted LIKE TABLE OF t_inkgp_gpart.

  FIELD-SYMBOLS <fs_collections>  TYPE fkkcollections.


* Mindestgröße der Lese-Einheiten
  h_limit = i_basics-tech-limit.

* Übernahme abstrakter Intervallgrenzen für GPART
  h_gpart_low  = i_low.
  h_gpart_high = i_high.

* check if work to do in this interval
  PERFORM check_interval_intersection
          TABLES   i_basics-ranges-r_gpart
                   i_basics-ranges-r_vkont
                   i_basics-ranges-r_vtref
          USING    i_low
                   i_high
                   i_basics-tech-object
          CHANGING h_no_work_to_do.

* if no work to do just exit.
  IF h_no_work_to_do = 'X'.
    CALL FUNCTION 'FKK_AKTIV2_INTNR_GET'
      IMPORTING
        e_intnr = h_intnr.
    mac_appl_log_msg 'I' '>6' '381'
                     h_intnr i_low i_high space
                     c_msgprio_low i_basics-appllog-probclass.
* Where used list
    SET EXTENDED CHECK OFF.
    IF 1 = 2. MESSAGE i381(>6). ENDIF.
    SET EXTENDED CHECK ON.
    EXIT.
  ENDIF.

* Konstruieren des Runkeys
  CALL FUNCTION 'FKK_AKTIV2_RUN_KEY_CONSTRUCT'
    EXPORTING
      i_aktyp  = i_basics-runkey-aktyp
      i_laufd  = i_basics-runkey-laufd
      i_laufi  = i_basics-runkey-laufi
    IMPORTING
      e_runkey = h_runkey.

* Lesen Zusatzparameter
  IMPORT addons TO g_fkkcollinfo FROM DATABASE rfdt(kk) ID h_runkey.
                                                            "#EC ENHOK

  IF NOT sy-subrc IS INITIAL.
* Nachricht: Zusatzparameter zu Lauf ... konnten nicht gelesen werden
    mac_appl_log_msg 'E' '>6' '376'
      i_basics-runkey-aktyp i_basics-runkey-laufd
      i_basics-runkey-laufi space
      c_msgprio_info '1'.
    SET EXTENDED CHECK OFF.
    IF 1 = 2. MESSAGE e376(>6). ENDIF.
    SET EXTENDED CHECK ON.
    EXIT.
  ENDIF.

* using the Z-report Z_XML_FOR_GPART it is possible to set that
* an XML-message is created for each business partner, instead of
* creating it for each collection agency
  PERFORM set_xml_gpart(z_xml_for_gpart) IF FOUND
                                   CHANGING lv_xml_for_gpart.

* Lesen aktuelle Jobnummer
  CALL FUNCTION 'FKK_AKTIV2_JOBNR_GET'
    IMPORTING
      e_jobnr = h_jobnr.

* Lesen aktuelle Intervalnummer
  CALL FUNCTION 'FKK_AKTIV2_INTNR_GET'
    IMPORTING
      e_intnr = h_intnr.
  h_intnr_c = h_intnr.

* Selektion Abgabestatus-Festwerte
  PERFORM select_agsta_fixed_values.

* Erzeugen Range für Abgabestatus
*  PERFORM create_range_agsta TABLES  ht_agsta_range
*                             USING   g_fkkcollinfo.
  PERFORM adesso_create_range_agsta TABLES  ht_agsta_range
                                    USING   g_fkkcollinfo.

* Lesen Events
  PERFORM read_events
     TABLES
        t_tfkfbc_5051
        t_tfkfbc_5052
        t_tfkfbc_5053.

*********************************************************************
***
*** Selection
***
*********************************************************************
  CLEAR: t_fkkcoll[],       t_fkkcoll.
  CLEAR: t_fkkcoli_log[],   t_fkkcoli_log.
  CLEAR: t_fkkcoll_ch[],    t_fkkcoll_ch.
  CLEAR: t_gpart_inkgp[],   t_gpart_inkgp.
  CLEAR: t_gpart_datum[],   t_gpart_datum.
  CLEAR: t_fkkcollh_i_w[],  t_fkkcollh_i_w.
  CLEAR: t_fkkcollp_ip_w[], t_fkkcollp_ip_w.
  CLEAR: t_fkkcollp_ir_w[], t_fkkcollp_ir_w.
  CLEAR: t_fkkcollp_im_w[], t_fkkcollp_im_w.
  CLEAR: t_fkkcollt_i_w[],  t_fkkcollt_i_w.
  CLEAR: gt_inkgp[],        gt_inkgp.
  CLEAR: h_lfd_m, h_lfd_r, h_lfd_p.

*>> Note 1667410
  CLEAR:  gt_collections_hash, gt_collections_hash[],
          gt_collections, gt_collections[],
          gt_coli_log_ext_hash, gt_coli_log_ext_hash[],
          gt_collpaym_logkz, gt_collpaym_logkz[],
          gt_collitem_logkz, gt_collitem_logkz[].
*<< Note 1667410

  IF NOT g_fkkcollinfo-xcpart IS INITIAL.   " Note 1308486
* Lesen Info-Protokolle über aktuelles Geschäftspartnerintervall
*>>>>> note 1502304
    SELECT gpart udate utime postyp
           INTO CORRESPONDING FIELDS OF TABLE t_fkkcoli_log
      FROM  dfkkcoli_log
      WHERE nrzas EQ space
      AND   opbel EQ space
      AND   gpart BETWEEN h_gpart_low AND h_gpart_high  "#EC CI_NOFIRST
      AND   gpart IN i_basics-ranges-r_gpart.             "#EC PORTABLE
*<<<<< note 1502304

* Lesen Datum der letzten prot. Infos zu Partner-Stammdatenänderungen
    PERFORM last_partner_info_datum TABLES  t_fkkcoli_log
                                            t_gpart_datum.
  ENDIF.

*>> NOTE 985059
** Lesen an Inkassobüros abgegebenen Forderungen für GPART-Intervall
  OPEN CURSOR WITH HOLD cursor FOR
       SELECT *  FROM  dfkkcoll AS l
           WHERE  l~gpart BETWEEN h_gpart_low AND h_gpart_high
           AND    l~gpart IN i_basics-ranges-r_gpart
*             AND    l~bukrs IN i_basics-ranges-r_bukrs
           AND    l~vkont IN i_basics-ranges-r_vkont
           AND    l~agsta IN ht_agsta_range
           AND EXISTS ( SELECT opbel FROM dfkkop AS t
           WHERE l~opbel  EQ t~opbel
*             AND   l~bukrs  EQ t~bukrs
           AND   l~bukrs IN i_basics-ranges-r_bukrs
           AND   l~gpart  EQ t~gpart
           AND   l~vkont  EQ t~vkont
           AND   l~inkps  EQ t~inkps )
           ORDER BY l~mandt l~opbel l~inkps
*>> NOTE 985059

*>>> NOTE 1490877
*     For MS SQL database
          %_HINTS  MSSQLNT '&REPARSE&'.                   "#EC CI_HINTS
*<<< NOTE 1490877

  DO.
    FETCH NEXT CURSOR cursor INTO TABLE t_fkkcoll
                 PACKAGE SIZE h_limit.
    IF NOT sy-subrc IS INITIAL.
      EXIT.
    ENDIF.

*>> NOTE 985059
    DATA: ylt_fkkcoli_log  TYPE SORTED TABLE OF  dfkkcoli_log
          WITH NON-UNIQUE  KEY opbel inkps gpart vkont.
    DATA: ylt_fkkcollh     TYPE SORTED TABLE OF  dfkkcollh
          WITH NON-UNIQUE KEY  opbel inkps gpart vkont.

* Lesen letzte an Inkassobüro gemeldete Position
    CLEAR   ylt_fkkcoli_log.
    REFRESH ylt_fkkcoli_log.
    FREE    ylt_fkkcoli_log.
    IF NOT t_fkkcoll[] IS INITIAL.
      SELECT * INTO  TABLE ylt_fkkcoli_log
               FROM  dfkkcoli_log
      FOR ALL ENTRIES IN t_fkkcoll
*               where nrzas  eq  t_fkkcoll-nrzas
               WHERE opbel  EQ  t_fkkcoll-opbel         "#EC CI_NOFIRST
               AND   inkps  EQ  t_fkkcoll-inkps
               AND   gpart  EQ  t_fkkcoll-gpart
               AND   vkont  EQ  t_fkkcoll-vkont.
    ENDIF.
* Lesen 'Verwaltungsdaten zur Abgabe an Inkassobüro(Historie)'
    CLEAR   ylt_fkkcollh.
    REFRESH ylt_fkkcollh.
    FREE    ylt_fkkcollh.
    IF NOT t_fkkcoll[] IS INITIAL.
      SELECT * INTO  TABLE ylt_fkkcollh
                FROM  dfkkcollh
       FOR ALL ENTRIES IN t_fkkcoll
                WHERE opbel  EQ  t_fkkcoll-opbel
                AND   inkps  EQ  t_fkkcoll-inkps
                AND   gpart  EQ  t_fkkcoll-gpart
                AND   vkont  EQ  t_fkkcoll-vkont.
*                AND   inkgp  in  g_fkkcollinfo-r_inkgp. " Note 2641727
    ENDIF.
*>> NOTE 985059

    LOOP AT t_fkkcoll.

* Letztes Abgabedatum
      SELECT MAX( agdat )
             FROM dfkkcoll
             WHERE gpart  = @t_fkkcoll-gpart
             AND   vkont  = @t_fkkcoll-vkont
             AND   inkgp  = @t_fkkcoll-inkgp
             INTO @DATA(maxagdat).

*  Prüfen, ob Abbruch durch InkGP, dann keine Infos mehr schicken
      SELECT SINGLE @abap_true
             FROM /adesso/ink_infi
             WHERE vkont   =  @t_fkkcoll-vkont
             AND   inkgp   =  @t_fkkcoll-inkgp
             AND   abbruch =  'SEG'
             AND   infodat GE @maxagdat
             INTO  @DATA(exists).

      IF sy-subrc = 0  AND
         exists   = abap_true.
        DELETE t_fkkcoll.
        CONTINUE.
      ENDIF.

* Meldung Verkauf / Ablehnung Verkauf VK an IGP erfolgt
      SELECT SINGLE @abap_true
             FROM dfkkcoli_log
             WHERE gpart   =  @t_fkkcoll-gpart
             AND   vkont   =  @t_fkkcoll-vkont
             AND   postyp  BETWEEN 'A' AND 'V'
             INTO  @DATA(send).

      IF sy-subrc = 0  AND
         send   = abap_true.
        DELETE t_fkkcoll.
        CONTINUE.
      ENDIF.


      IF t_fkkcoll-agsta NE c_released                  AND         "01
         t_fkkcoll-agsta NE c_receivable_submitted      AND         "02
         t_fkkcoll-agsta NE c_receivable_paid           AND         "03
         t_fkkcoll-agsta NE c_receivable_part_paid      AND         "04
         t_fkkcoll-agsta NE c_receivable_cancelled      AND         "05
         t_fkkcoll-agsta NE c_receivable_write_off      AND         "06
         t_fkkcoll-agsta NE c_agsta_cu_t-erfolglos      AND         "07
         t_fkkcoll-agsta NE c_agsta_t-erfolglos         AND         "08
         t_fkkcoll-agsta NE c_receivable_recalled       AND         "09
         t_fkkcoll-agsta NE c_costumer_directly_paid    AND         "10
         t_fkkcoll-agsta NE c_costumer_partally_paid    AND         "11
         t_fkkcoll-agsta NE c_full_clearing             AND         "12
         t_fkkcoll-agsta NE c_partial_clearing          AND         "13
         t_fkkcoll-agsta NE c_receivable_part_write_off AND         "15
         t_fkkcoll-agsta NE c_rec_recall_part_write_off AND         "16
* adesso Stati
         t_fkkcoll-agsta NE c_direct_wroff              AND         "20
         t_fkkcoll-agsta NE c_sell                      AND         "30
         t_fkkcoll-agsta NE c_decl_sell_wroff           AND         "31
         t_fkkcoll-agsta NE c_decl_sell_rcall.                      "32
* Ausschluss von Sätzen anderer Abgabestatus
        DELETE t_fkkcoll.
        CONTINUE.
      ENDIF.

      IF g_fkkcollinfo-r_inkgp IS INITIAL.
* Sammeln der Kombinationen 'Geschäftspartner-Nr. -- Inkassobüro-Nr.'
        MOVE-CORRESPONDING t_fkkcoll TO t_gpart_inkgp.
        COLLECT t_gpart_inkgp.
      ENDIF.

*>> NOTE 985059
* Lesen letzte an Inkassobüro gemeldete Position
      CLEAR   wt_fkkcoli_log.
      REFRESH wt_fkkcoli_log.
      FREE    wt_fkkcoli_log.
      LOOP AT ylt_fkkcoli_log INTO wt_fkkcoli_log
                     WHERE opbel  EQ  t_fkkcoll-opbel
                     AND   inkps  EQ  t_fkkcoll-inkps
                     AND   gpart  EQ  t_fkkcoll-gpart
                     AND   vkont  EQ  t_fkkcoll-vkont.
        APPEND wt_fkkcoli_log.
      ENDLOOP.
      SORT wt_fkkcoli_log BY lfdnr DESCENDING.
      READ TABLE wt_fkkcoli_log INDEX 1.

* Lesen 'Verwaltungsdaten zur Abgabe an Inkassobüro(Historie)'
      CLEAR: t_fkkcollh[], t_fkkcollh.
      CLEAR  w_fkkcollh_alt.
      FREE    t_fkkcollh.
      LOOP AT ylt_fkkcollh INTO t_fkkcollh
      WHERE opbel  EQ  t_fkkcoll-opbel
      AND   inkps  EQ  t_fkkcoll-inkps
      AND   gpart  EQ  t_fkkcoll-gpart
      AND   vkont  EQ  t_fkkcoll-vkont.
        APPEND t_fkkcollh.
      ENDLOOP.
      SORT t_fkkcollh BY lfdnr ASCENDING.
*>> NOTE 985059

      CLEAR: old_inkgp, w_nofst.
      CLEAR: wt_fkkcollh[], wt_fkkcollh.
      CLEAR: w_fkkcollh.

*
      LOOP AT t_fkkcollh.
* Aktivitäten zum Posten sammeln, die von einem Inkassobüro
* bearbeitet werden
        IF old_inkgp = t_fkkcollh-inkgp.
          wt_fkkcollh = t_fkkcollh.
          APPEND wt_fkkcollh.
        ELSE.
* Posten wird von einem anderen Inkassobüro bearbeitet
          IF NOT w_nofst IS INITIAL.

*>>> Note 1863958
* check the entries in wt_fkkcollh
            DESCRIBE TABLE wt_fkkcollh.
            IF sy-tfill = 1 AND wt_fkkcollh-agsta = '01'.
* do not inform the collection agency
            ELSE.
*<<< Note 1863958
* Informieren akluelles Inkassobüro
              IF old_inkgp IN g_fkkcollinfo-r_inkgp.
*                PERFORM infos_pro_inkgp
                PERFORM adesso_infos_pro_inkgp
                        TABLES wt_fkkcollh
                        USING  i_basics
                               wt_fkkcoli_log
                               h_intnr_c
                               h_lfd_p
                               h_lfd_r.
                MOVE-CORRESPONDING w_fkkcollh TO t_gpart_inkgp.
                COLLECT t_gpart_inkgp.
              ENDIF.
            ENDIF.
            CLEAR wt_fkkcollh[].
          ENDIF.
          wt_fkkcollh = t_fkkcollh.
          APPEND wt_fkkcollh.
        ENDIF.
        old_inkgp = t_fkkcollh-inkgp.
        w_fkkcollh = t_fkkcollh.
        w_nofst = 'X'.
      ENDLOOP.
      IF NOT wt_fkkcollh[] IS INITIAL.
* Informieren letztes Inkassobüro
        IF old_inkgp IN g_fkkcollinfo-r_inkgp.
*          PERFORM infos_pro_inkgp.
          PERFORM adesso_infos_pro_inkgp
                  TABLES wt_fkkcollh
                  USING  i_basics
                         wt_fkkcoli_log
                         h_intnr_c
                         h_lfd_p
                         h_lfd_r.
          MOVE-CORRESPONDING t_fkkcollh TO t_gpart_inkgp.
          COLLECT t_gpart_inkgp.
        ENDIF.
        CLEAR wt_fkkcollh[].
      ENDIF.
    ENDLOOP.

*>>>>> HANA
    IF NOT gt_fkkcollp_ip_w[] IS INITIAL.
      INSERT dfkkcollp_ip_w FROM TABLE gt_fkkcollp_ip_w.
      CLEAR: gt_fkkcollp_ip_w[],gt_fkkcollp_ip_w.
    ENDIF.

    IF NOT gt_fkkcollp_ir_w[] IS INITIAL.
      INSERT dfkkcollp_ir_w FROM TABLE gt_fkkcollp_ir_w.
      CLEAR: gt_fkkcollp_ir_w[],gt_fkkcollp_ir_w.
    ENDIF.
*<<<<< HANA
  ENDDO.
  CLOSE CURSOR cursor.

* ----------------------------------------------------------------------
* information for master data changes
* file based version (enterprise services not active)
* ----------------------------------------------------------------------
  IF gv_flg_coll_esoa_active IS INITIAL.

    SORT t_gpart_inkgp BY gpart inkgp.
    CLEAR: t_fkkcoli_log[], t_fkkcoli_log.

* check if there has been items submitted to collection agency of
* the combinations of gpart and inkgp
    CLEAR: lt_gpart_inkgp_submitted[], lt_gpart_inkgp_submitted.
    SELECT DISTINCT gpart inkgp FROM dfkkcoll
      INTO CORRESPONDING FIELDS OF TABLE lt_gpart_inkgp_submitted
      FOR ALL ENTRIES IN t_gpart_inkgp
      WHERE gpart = t_gpart_inkgp-gpart
      AND   inkgp = t_gpart_inkgp-inkgp
      AND ( agsta = c_receivable_submitted   OR "submitted
            agsta = c_receivable_part_paid   OR "part.paid
            agsta = c_costumer_partally_paid OR "part.paid from cust
            agsta = c_partial_clearing       OR "part.cleared
            agsta = c_receivable_part_write_off ). "part paid/wroff

    SORT lt_gpart_inkgp_submitted BY gpart inkgp.

    LOOP AT  t_gpart_inkgp.
* Lesen Geschäftspartner-Stammdatenänderungen
      AT NEW gpart.
        CLEAR: h_tfill.
        CLEAR: t_fkkcoll_ch[], t_fkkcoll_ch[].
        PERFORM select_master_data_changes
                       TABLES t_gpart_datum
                              t_fkkcoll_ch
                       USING  t_gpart_inkgp-gpart.
        DESCRIBE TABLE t_fkkcoll_ch LINES h_tfill.
      ENDAT.

      AT NEW inkgp.

* Zwischenspeichern Infomationen für Inkassobüro
*- Kopf
        PERFORM info_header_data
                     TABLES t_fkkcollh_i_w
                     USING  t_gpart_inkgp-inkgp
                            i_basics.

*>>> Note 2191343
* report master data changes only in case a submitted item has been
* sent to the collection agency
        READ TABLE lt_gpart_inkgp_submitted TRANSPORTING NO FIELDS WITH KEY
           gpart = t_gpart_inkgp-gpart inkgp = t_gpart_inkgp-inkgp BINARY SEARCH.
        IF sy-subrc IS NOT INITIAL.
          CONTINUE.
        ENDIF.
*<<< Note 2191343

*- Positionen Partneränderungen
        CHECK h_tfill > 0.
        IF NOT g_fkkcollinfo-xcpart IS INITIAL.
          PERFORM info_master_data_changes
                       TABLES t_gpart_datum
                              t_fkkcoll_ch
                              t_fkkcollp_im_w
                       USING  t_gpart_inkgp-gpart
                              t_gpart_inkgp-inkgp
                              i_basics
                              h_lfd_m
                              h_intnr_c.
        ENDIF.

      ENDAT.

    ENDLOOP.

  ENDIF.

* ----------------------------------------------------------------------
* file based version (enterprise services not active)
* ----------------------------------------------------------------------
  IF gv_flg_coll_esoa_active IS INITIAL.

* check if entries are already in db => no insert necessary
    IF t_fkkcollh_i_w[] IS NOT INITIAL.
      SELECT * FROM dfkkcollh_i_w INTO TABLE t_fkkcollh_i_w_db
        FOR ALL ENTRIES IN t_fkkcollh_i_w
        WHERE laufd = t_fkkcollh_i_w-laufd
          AND laufi = t_fkkcollh_i_w-laufi
          AND w_inkgp = t_fkkcollh_i_w-inkgp.
    ENDIF.

* Sichern Kopfinformationen für Inkassobüros, zu denen Daten vorliegen.
    LOOP AT t_fkkcollh_i_w.
      READ TABLE gt_inkgp WITH KEY t_fkkcollh_i_w-w_inkgp.
      IF sy-subrc IS  NOT INITIAL.
        DELETE t_fkkcollh_i_w.
        CONTINUE.
      ENDIF.

      READ TABLE t_fkkcollh_i_w_db WITH KEY laufd = t_fkkcollh_i_w-laufd
         laufi = t_fkkcollh_i_w-laufi w_inkgp = t_fkkcollh_i_w-inkgp.
      IF sy-subrc = 0.
        DELETE t_fkkcollh_i_w.
        CONTINUE.
      ENDIF.

      IF i_basics-macat IS NOT INITIAL.
        DELETE t_fkkcollh_i_w.
      ENDIF.

    ENDLOOP.

    IF t_fkkcollh_i_w[] IS NOT INITIAL.
      TRY.
          INSERT dfkkcollh_i_w FROM TABLE t_fkkcollh_i_w
                               ACCEPTING DUPLICATE KEYS.
        CATCH cx_sy_open_sql_db.    " Note 2330715
* do not issue any error message in this case
      ENDTRY.
    ENDIF.

* Protokollieren bearbeitete Fälle
    DESCRIBE TABLE gt_fall LINES h_fall.
    IF i_basics-status-xsimu IS INITIAL.
      c_success_num = h_fall.
    ENDIF.
    c_test_num = h_fall.

  ENDIF.

ENDFUNCTION.
