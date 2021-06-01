*----------------------------------------------------------------------*
***INCLUDE LFKCIF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  addons_1000_import
*&---------------------------------------------------------------------*
FORM addons_1000_import.

  IMPORT addons TO g_fkkcollinfo FROM MEMORY ID 'FKKMADADDONS'.

ENDFORM.                    " addons_1000_import
*&---------------------------------------------------------------------*
*&      Form  addons_1000_export
*&---------------------------------------------------------------------*
FORM addons_1000_export.

  EXPORT addons FROM g_fkkcollinfo TO MEMORY ID 'FKKMADADDONS'.

ENDFORM.                    " addons_1000_export
*&---------------------------------------------------------------------*
*&      Form  check_interval_intersection
*&---------------------------------------------------------------------*
FORM check_interval_intersection
     TABLES
        r_gpart TYPE fkk_rt_gpart
        r_vkont TYPE fkk_rt_vkont
        r_vtref TYPE fkk_rt_vtref
     USING
        i_low TYPE intlo_kk
        i_high TYPE inthi_kk
        i_object TYPE object_kk
     CHANGING
        c_no_work_to_do TYPE xfeld.

* declarations
  DATA: l_gpart    LIKE igpart OCCURS 0 WITH HEADER LINE,
        l_vkont    LIKE ivkont OCCURS 0 WITH HEADER LINE,
        l_vtref    LIKE ivtref OCCURS 0 WITH HEADER LINE,
        wa_r_vkont TYPE fkkr_vkont,
        wa_r_gpart TYPE fkkr_gpart,
        wa_r_vtref TYPE fkkr_vtref,
        h_low      TYPE intlo_kk,
        h_high     TYPE inthi_kk.

* Assume some work to do.
  CLEAR c_no_work_to_do.

* Prepare VKONT for interval intersection
  LOOP AT r_vkont INTO wa_r_vkont.
    MOVE-CORRESPONDING wa_r_vkont TO l_vkont.
    APPEND l_vkont.
  ENDLOOP.

* Prepare GPART for interval intersection
  LOOP AT r_gpart INTO wa_r_gpart.
    MOVE-CORRESPONDING wa_r_gpart TO l_gpart.
    APPEND l_gpart.
  ENDLOOP.

* Prepare VTREF for interval intersection
  LOOP AT r_vtref INTO wa_r_vtref.
    MOVE-CORRESPONDING wa_r_vtref TO l_vtref.
    APPEND l_vtref.
  ENDLOOP.

*-Create intersection with interval
  h_low  = i_low.
  h_high = i_high.
  CALL FUNCTION 'FKK_DI_INTERVAL_INTERSECTION'
    EXPORTING
      i_intlo  = h_low
      i_inthi  = h_high
      i_object = i_object
    TABLES
      t_gpart  = l_gpart
      t_vkont  = l_vkont
      t_vtref  = l_vtref
    EXCEPTIONS
      is_empty = 1
      OTHERS   = 2.

* If no work to do exit.
  IF sy-subrc = 1.
    c_no_work_to_do = 'X'.
    EXIT.
  ENDIF.

* if work to do, give results back, for GPART
  REFRESH r_gpart.
  LOOP AT l_gpart.
    MOVE-CORRESPONDING l_gpart TO wa_r_gpart.
    wa_r_gpart-sign = 'I'.
    IF l_gpart-high IS INITIAL OR
       l_gpart-low EQ l_gpart-high.
      wa_r_gpart-option = 'EQ'.
      CLEAR wa_r_gpart-high.
    ELSE.
      wa_r_gpart-option = 'BT'.
    ENDIF.
    APPEND wa_r_gpart TO r_gpart.
  ENDLOOP.

* if work to do, give results back, for VKONT
  REFRESH r_vkont.
  LOOP AT l_vkont.
    MOVE-CORRESPONDING l_vkont TO wa_r_vkont.
    wa_r_vkont-sign = 'I'.
    IF l_vkont-high IS INITIAL OR
       l_vkont-low EQ l_vkont-high.
      wa_r_vkont-option = 'EQ'.
      CLEAR wa_r_vkont-high.
    ELSE.
      wa_r_vkont-option = 'BT'.
    ENDIF.
    APPEND wa_r_vkont TO r_vkont.
  ENDLOOP.

* if work to do, give results back, for VTREF
  REFRESH r_vtref.
  LOOP AT l_vtref.
    MOVE-CORRESPONDING l_vtref TO wa_r_vtref.
    wa_r_vtref-sign = 'I'.
    IF l_vtref-high IS INITIAL OR
       l_vtref-low EQ l_vtref-high.
      wa_r_vtref-option = 'EQ'.
      CLEAR wa_r_vtref-high.
    ELSE.
      wa_r_vtref-option = 'BT'.
    ENDIF.
    APPEND wa_r_vtref TO r_vtref.
  ENDLOOP.

ENDFORM.                    " check_interval_intersection
*&---------------------------------------------------------------------*
*&      Form  info_master_data_changes
*&---------------------------------------------------------------------*
FORM info_master_data_changes
            TABLES pt_gpart_datum   STRUCTURE t_gpart_datum
                   pt_fkkcoll_ch    STRUCTURE dfkkcoll_ch
                   pt_fkkcollp_im_w STRUCTURE dfkkcollp_im_w
            USING  p_gpart TYPE gpart_kk
                   p_inkgp TYPE inkgp_kk
                   p_i_basics TYPE fkk_mad_basics
                   p_h_lfd_m TYPE lfnum_kk
                   p_h_intnr_c TYPE intnr_i_kk.

  DATA:
    h_dfies_tab LIKE dfies OCCURS 0 WITH HEADER LINE,
    h_tabname   TYPE ddobjname,
    h_fname     TYPE dfies-fieldname.

  DATA ls_fkkcollp_im     LIKE fkkcollp_im.

* call event 5051 to fill specific customer field for the
* file header to be passed to event 5052
  READ TABLE lt_fkkcollh_i INTO t_fkkcollh_i
             WITH KEY satztyp = c_header
                      inkgp   = p_inkgp.
  IF sy-subrc <> 0.
    CLEAR t_fkkcollh_i.
    t_fkkcollh_i-satztyp = c_header.
    t_fkkcollh_i-inkgp   = p_inkgp.
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

* Übernahme Partneränderungen
  LOOP AT pt_fkkcoll_ch.
    pt_fkkcollp_im_w-laufd      = p_i_basics-runkey-laufd.
    pt_fkkcollp_im_w-laufi      = p_i_basics-runkey-laufi.
    pt_fkkcollp_im_w-w_inkgp    = p_inkgp.
    pt_fkkcollp_im_w-intnr      = p_h_intnr_c.
    ADD 1 TO p_h_lfd_m.
    pt_fkkcollp_im_w-lfnum      = p_h_lfd_m.
    pt_fkkcollp_im_w-satztyp    = c_position.
    pt_fkkcollp_im_w-postyp     = c_master_data_changes.
    pt_fkkcollp_im_w-gpart      = pt_fkkcoll_ch-gpart.
    pt_fkkcollp_im_w-tabname    = pt_fkkcoll_ch-tabname.
    pt_fkkcollp_im_w-tabkey     = pt_fkkcoll_ch-tabkey.
    pt_fkkcollp_im_w-fname      = pt_fkkcoll_ch-fname.
    pt_fkkcollp_im_w-value_new  = pt_fkkcoll_ch-value_new.
    pt_fkkcollp_im_w-value_old  = pt_fkkcoll_ch-value_old.
    pt_fkkcollp_im_w-udate      = pt_fkkcoll_ch-udate.
    pt_fkkcollp_im_w-utime      = pt_fkkcoll_ch-utime.      "260402ins

* Aufbereiten Tabellen- bzw. Feldname
    CLEAR: h_dfies_tab[], h_dfies_tab.
    CLEAR: h_tabname, h_fname.
    h_tabname = pt_fkkcoll_ch-tabname.
    SHIFT h_tabname LEFT DELETING LEADING space.
    h_fname = pt_fkkcoll_ch-fname.
    SHIFT h_fname LEFT DELETING LEADING space.
    IF NOT h_fname IS INITIAL.
      CALL FUNCTION 'DDIF_FIELDINFO_GET'
        EXPORTING
          tabname        = h_tabname
          fieldname      = h_fname
        TABLES
          dfies_tab      = h_dfies_tab
        EXCEPTIONS
          not_found      = 1
          internal_error = 2
          OTHERS         = 3.
      IF NOT sy-subrc IS INITIAL.
        CONCATENATE pt_fkkcoll_ch-tabname '_' pt_fkkcoll_ch-fname
          INTO pt_fkkcollp_im_w-ddtext.
      ELSE.
        READ TABLE h_dfies_tab INDEX 1.
        pt_fkkcollp_im_w-ddtext = h_dfies_tab-scrtext_l.
      ENDIF.
    ELSE.
      SELECT SINGLE ddtext INTO  pt_fkkcollp_im_w-ddtext
                           FROM  dd02t
                           WHERE tabname    EQ h_tabname
                           AND   ddlanguage EQ sy-langu
                           AND   as4vers    EQ 'A'.
      IF NOT sy-subrc IS INITIAL.
        pt_fkkcollp_im_w-ddtext = h_tabname.
      ENDIF.
    ENDIF.

    MOVE-CORRESPONDING pt_fkkcollp_im_w TO ls_fkkcollp_im.

* ------- calls user exit 5052 / BP-Master data changes ---------------*
    PERFORM call_zp_fb_5052_gpart
       USING
          t_fkkcollh_i
       CHANGING
          ls_fkkcollp_im.

    MOVE-CORRESPONDING ls_fkkcollp_im TO pt_fkkcollp_im_w.

* INSERT Informationen zu Partner-Stammdatenänderungen
*    insert into dfkkcollp_im_w values pt_fkkcollp_im_w.
*>>>>> HANA
    DATA: lo_opt       TYPE REF TO if_fkk_optimization_settings,
          x_optimizing TYPE xfeld.
    lo_opt = cl_fkk_optimization_settings=>get_instance( ).
    x_optimizing = lo_opt->is_active( cl_fkk_optimization_settings=>cc_fica_fpci_mass_insert ).
    IF x_optimizing = abap_true.
      APPEND pt_fkkcollp_im_w TO gt_fkkcollp_im_w.
    ELSE.
      INSERT INTO dfkkcollp_im_w VALUES pt_fkkcollp_im_w.  "OLD LOGIC
    ENDIF.
*<<<<< HANA

* Registrieren Inkassobüro
    gt_inkgp = pt_fkkcollp_im_w-w_inkgp.
    COLLECT gt_inkgp.

* Registrieren bearbeiteten Fall
    gt_fall = pt_fkkcollp_im_w-gpart.
    COLLECT gt_fall.

  ENDLOOP.

*>>>>> HANA
  IF NOT gt_fkkcollp_im_w[] IS INITIAL.
    INSERT dfkkcollp_im_w FROM TABLE gt_fkkcollp_im_w.
    CLEAR: gt_fkkcollp_im_w[],gt_fkkcollp_im_w.
  ENDIF.
*<<<<< HANA

ENDFORM.                    " info_master_data_changes
*&---------------------------------------------------------------------*
*&      Form  Last_partner_info_datum
*&---------------------------------------------------------------------*
*       Lesen Datum der letzten prot. Info zu Partner-Stammdatenänderung
*----------------------------------------------------------------------*
*      -->P_T_FKKCOLI_LOG  Struktur Log-Tabelle
*      -->P_T_GPART_DATUM  Struktur für Zuordnung Partner - Änd.Datum
*----------------------------------------------------------------------*
FORM last_partner_info_datum
                       TABLES   pt_fkkcoli_log STRUCTURE dfkkcoli_log
                                pt_gpart_datum STRUCTURE t_gpart_datum.

  SORT pt_fkkcoli_log BY gpart ASCENDING udate DESCENDING utime DESCENDING.

* Selektion der Partner aus Protokoll
  LOOP AT pt_fkkcoli_log WHERE postyp EQ c_master_data_changes.
    pt_gpart_datum = pt_fkkcoli_log-gpart.
    CLEAR pt_gpart_datum-datum.
    CLEAR pt_gpart_datum-uzeit.
    COLLECT pt_gpart_datum.
  ENDLOOP.

* Zuordenen Datum der letzten Partneränderungs-Information zum Partner
  LOOP AT pt_gpart_datum.

*    SELECT MAX( udate ) INTO  pt_gpart_datum-datum
*                        FROM  dfkkcoli_log
*                        WHERE nrzas EQ space
*                        AND   opbel EQ space
**                        AND   inkps EQ space
*                        AND   gpart EQ pt_gpart_datum-gpart.
**>> begin of insert                                        "260402ins
*    CHECK sy-subrc IS INITIAL.
** Zuordenen Uhrzeit der letzten Partneränderungs-Information zum Partner
*    SELECT MAX( utime ) INTO  pt_gpart_datum-uzeit
*                        FROM  dfkkcoli_log
*                        WHERE nrzas EQ space
*                        AND   opbel EQ space
**                        AND   inkps EQ space
*                        AND   gpart EQ pt_gpart_datum-gpart
*                        AND   udate EQ pt_gpart_datum-datum.
**>> end of insert

    READ TABLE pt_fkkcoli_log
            WITH KEY gpart = pt_gpart_datum-gpart.

    IF sy-subrc EQ 0.
      MOVE pt_fkkcoli_log-udate TO pt_gpart_datum-datum.
      MOVE pt_fkkcoli_log-utime TO pt_gpart_datum-uzeit.
      MODIFY pt_gpart_datum.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " Last_partner_info_datum
*&---------------------------------------------------------------------*
*&      Form  select_master_data_changes
*&---------------------------------------------------------------------*
FORM select_master_data_changes
            TABLES   pt_gpart_datum STRUCTURE t_gpart_datum
                     pt_fkkcoll_ch STRUCTURE dfkkcoll_ch
            USING    p_gpart TYPE gpart_kk.

  DATA: i_datum LIKE dfkkcoli_log-udate,
        i_uzeit LIKE dfkkcoli_log-utime.                    "260402ins


* Lesen Zeitpunkt der letzten protokollierten Partneränderung
  CLEAR: pt_gpart_datum.
  READ TABLE pt_gpart_datum WITH KEY gpart = p_gpart.
  IF sy-subrc IS INITIAL.
    i_datum = pt_gpart_datum-datum.
    i_uzeit = pt_gpart_datum-uzeit.                         "260402ins
  ELSE.
    CLEAR i_datum.
    CLEAR i_uzeit.                                          "260402ins
  ENDIF.

* Selektion Geschäftspartner-Stammdatenänderungen
  CLEAR: pt_fkkcoll_ch[], pt_fkkcoll_ch.
  SELECT * INTO TABLE pt_fkkcoll_ch[]
           FROM dfkkcoll_ch
          WHERE gpart EQ p_gpart
*           and udate gt i_datum                          "260402del
            AND ( ( udate EQ i_datum AND utime > i_uzeit )  "260402ins
                 OR udate GT i_datum )  .                   "260402ins

ENDFORM.                    " select_master_data_changes
*&---------------------------------------------------------------------*
*&      Form  info_header_data
*&---------------------------------------------------------------------*
FORM info_header_data TABLES   pt_fkkcollh_i_w STRUCTURE dfkkcollh_i_w
                      USING    p_inkgp TYPE inkgp_kk
                               p_basics TYPE fkk_mad_basics.

  IF g_fkkcollinfo-sumknz IS INITIAL.
    READ TABLE lt_fkkcollh_i INTO t_fkkcollh_i
               WITH KEY satztyp = c_header
                        inkgp   = p_inkgp.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING t_fkkcollh_i TO pt_fkkcollh_i_w.
    ENDIF.
  ENDIF.

* Fortschreiben Kopfinformationen
  pt_fkkcollh_i_w-laufd   = p_basics-runkey-laufd.
  pt_fkkcollh_i_w-laufi   = p_basics-runkey-laufi.
  pt_fkkcollh_i_w-w_inkgp = p_inkgp.
  pt_fkkcollh_i_w-satztyp = c_header.
  pt_fkkcollh_i_w-inkgp   = p_inkgp.
  pt_fkkcollh_i_w-datum   = sy-datum.
  COLLECT pt_fkkcollh_i_w.

ENDFORM.                    " info_header_data
*&---------------------------------------------------------------------*
*&      Form  read_events
*&---------------------------------------------------------------------*
*       read events
*----------------------------------------------------------------------*
FORM read_events TABLES   p_t_tfkfbc_5051 STRUCTURE t_tfkfbc_5051
                          p_t_tfkfbc_5052 STRUCTURE t_tfkfbc_5052
                          p_t_tfkfbc_5053 STRUCTURE t_tfkfbc_5053.

  DATA lv_applk TYPE applk_kk.

  CALL FUNCTION 'FKK_GET_APPLICATION'
    EXPORTING
      i_no_dialog      = 'X'
    IMPORTING
      e_applk          = lv_applk
    EXCEPTIONS
      no_appl_selected = 1
      OTHERS           = 2.

* Determine function modules for events 5051, 5052, 5053 --------------*
  REFRESH p_t_tfkfbc_5051.
  CALL FUNCTION 'FKK_FUNC_MODULE_DETERMINE'
    EXPORTING
      i_fbeve  = c_event_5051
      i_applk  = lv_applk
    TABLES
      t_fbstab = p_t_tfkfbc_5051
    EXCEPTIONS
      OTHERS   = 1.

  REFRESH p_t_tfkfbc_5052.
  CALL FUNCTION 'FKK_FUNC_MODULE_DETERMINE'
    EXPORTING
      i_fbeve  = c_event_5052
      i_applk  = lv_applk
    TABLES
      t_fbstab = p_t_tfkfbc_5052
    EXCEPTIONS
      OTHERS   = 1.

  REFRESH p_t_tfkfbc_5053.
  CALL FUNCTION 'FKK_FUNC_MODULE_DETERMINE'
    EXPORTING
      i_fbeve  = c_event_5053
      i_applk  = lv_applk
    TABLES
      t_fbstab = p_t_tfkfbc_5053
    EXCEPTIONS
      OTHERS   = 1.

ENDFORM.                    " read_events
*&---------------------------------------------------------------------*
*&      Form  create_range_agsta
*&---------------------------------------------------------------------*
*       Erzeugen Range für Abgabestatus
*----------------------------------------------------------------------*
FORM create_range_agsta
                  TABLES p_ht_agsta_range STRUCTURE ht_agsta_range
                  USING  p_fkkcollinfo TYPE fkkcollinfo.
  IF 1 = 1.
    CLEAR: p_ht_agsta_range[], p_ht_agsta_range.
    p_ht_agsta_range-sign   = 'I'.
    p_ht_agsta_range-option = 'EQ'.
    CLEAR: p_ht_agsta_range-high.

    p_ht_agsta_range-low = c_receivable_submitted.
    APPEND p_ht_agsta_range.
    p_ht_agsta_range-low = c_receivable_paid.         "03
    APPEND p_ht_agsta_range.
    p_ht_agsta_range-low = c_receivable_part_paid.    "04
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
    p_ht_agsta_range-low = c_released.                "01
    APPEND p_ht_agsta_range.

  ELSE.
    CLEAR: p_ht_agsta_range[], p_ht_agsta_range.
    p_ht_agsta_range-sign   = 'I'.
    p_ht_agsta_range-option = 'EQ'.
    CLEAR: p_ht_agsta_range-high.

    IF  NOT p_fkkcollinfo-xcpart IS INITIAL
     OR NOT p_fkkcollinfo-xausg  IS INITIAL.
      p_ht_agsta_range-low = c_receivable_submitted.     "02
      APPEND p_ht_agsta_range.
    ENDIF.

    IF NOT p_fkkcollinfo-xback IS INITIAL.
      p_ht_agsta_range-low = c_receivable_recalled.      "09
      APPEND p_ht_agsta_range.
    ENDIF.

    IF NOT p_fkkcollinfo-xausg IS INITIAL.
      p_ht_agsta_range-low = c_costumer_directly_paid.   "10
      APPEND p_ht_agsta_range.
      p_ht_agsta_range-low = c_costumer_partally_paid.   "11
      APPEND p_ht_agsta_range.
      p_ht_agsta_range-low = c_receivable_paid.          "03
      APPEND p_ht_agsta_range.
      p_ht_agsta_range-low = c_receivable_part_paid.     "04
      APPEND p_ht_agsta_range.
      p_ht_agsta_range-low = c_full_clearing.            "12
      APPEND p_ht_agsta_range.
      p_ht_agsta_range-low = c_partial_clearing.         "13
      APPEND p_ht_agsta_range.
    ENDIF.
  ENDIF.

  IF NOT p_fkkcollinfo-xrever IS INITIAL.
    p_ht_agsta_range-low = c_receivable_cancelled.       "05
    APPEND p_ht_agsta_range.
  ENDIF.

  IF NOT p_fkkcollinfo-xback IS INITIAL.
    p_ht_agsta_range-low = c_receivable_cancelled.       "05
    APPEND p_ht_agsta_range.
    p_ht_agsta_range-low = c_rec_recall_part_write_off.  "16
    APPEND p_ht_agsta_range.
  ENDIF.

*>> *<< Note 1320616
  IF NOT p_fkkcollinfo-xwroff IS INITIAL OR
     NOT p_fkkcollinfo-xausg  IS INITIAL.
    p_ht_agsta_range-low = c_agsta_cu_t-erfolglos.       "07
    APPEND p_ht_agsta_range.
  ENDIF.
*<< Note 1320616

  IF NOT p_fkkcollinfo-xwroff IS INITIAL.
    p_ht_agsta_range-low = c_receivable_write_off.       "06
    APPEND p_ht_agsta_range.
    p_ht_agsta_range-low = c_receivable_part_write_off.  "15
    APPEND p_ht_agsta_range.
*    p_ht_agsta_range-low = c_agsta_cu_t-erfolglos.    "07 Note 1320616
*    APPEND p_ht_agsta_range.                              Note 1320616
    p_ht_agsta_range-low = c_agsta_t-erfolglos.          "08
    APPEND p_ht_agsta_range.
  ENDIF.

ENDFORM.                    " create_range_agsta
*&---------------------------------------------------------------------*
*&      Form  create_range_gpart
*&---------------------------------------------------------------------*
*       Erzeugen Range für aktuelles Geschäftspartner-Intervall
*----------------------------------------------------------------------*
FORM create_range_gpart
                  TABLES  p_ht_gpart_range STRUCTURE ht_gpart_range
                  USING   p_h_gpart_low TYPE gpart_kk
                          p_h_gpart_high TYPE gpart_kk.

  CLEAR: p_ht_gpart_range[], p_ht_gpart_range.
  p_ht_gpart_range-sign   = 'I'.
  p_ht_gpart_range-option = 'BT'.
  p_ht_gpart_range-low    = p_h_gpart_low.
  p_ht_gpart_range-high   = p_h_gpart_high.
  APPEND p_ht_gpart_range.

ENDFORM.                    " create_range_gpart
*&---------------------------------------------------------------------*
*&      Form  exit_5052
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM exit_5052 USING    p_postyp TYPE postyp_kk
                        p_pt_fkkcollh_i_w
                        p_pt_fkkcollt_i_w
               CHANGING p_pt_fkkcollp_ip_w
                        p_pt_fkkcollp_ir_w
                        p_pt_fkkcollp_im_w.

  DATA:
    lt_fkkcollh_i_w  LIKE dfkkcollh_i_w,
    lt_fkkcollp_ip_w LIKE dfkkcollp_ip_w,
    lt_fkkcollp_ir_w LIKE dfkkcollp_ir_w,
    lt_fkkcollp_im_w LIKE dfkkcollp_im_w,
    lt_fkkcollt_i_w  LIKE dfkkcollt_i_w.


  lt_fkkcollh_i_w  = p_pt_fkkcollh_i_w.
  lt_fkkcollp_ip_w = p_pt_fkkcollp_ip_w.
  lt_fkkcollp_ir_w = p_pt_fkkcollp_ir_w.
  lt_fkkcollp_im_w = p_pt_fkkcollp_im_w.
  lt_fkkcollt_i_w  = p_pt_fkkcollt_i_w.

  LOOP AT t_tfkfbc_5052.
    CALL FUNCTION t_tfkfbc_5052-funcc
      EXPORTING
        i_postyp        = p_postyp
        i_fkkcollh_i_w  = lt_fkkcollh_i_w
        i_fkkcollt_i_w  = lt_fkkcollt_i_w
      CHANGING
        c_fkkcollp_ip_w = lt_fkkcollp_ip_w
        c_fkkcollp_ir_w = lt_fkkcollp_ir_w
        c_fkkcollp_im_w = lt_fkkcollt_i_w.
  ENDLOOP.

  p_pt_fkkcollp_ip_w = lt_fkkcollp_ip_w.
  p_pt_fkkcollp_ir_w = lt_fkkcollp_ir_w.
  p_pt_fkkcollp_im_w = lt_fkkcollp_im_w.

  SET EXTENDED CHECK OFF.
  IF 1 = 2. CALL FUNCTION 'FKK_SAMPLE_5052'. ENDIF.
  SET EXTENDED CHECK ON.

ENDFORM.                                                    " exit_5052
*&---------------------------------------------------------------------*
*&      Form  info_payment
*&---------------------------------------------------------------------*
FORM info_payment
     USING
        p_postyp TYPE postyp_kk
        p_i_basics TYPE fkk_mad_basics
        p_h_intnr_c TYPE intnr_i_kk
        p_t_fkkcollh LIKE dfkkcollh
        p_h_lfd_p TYPE lfnum_kk
        p_h_betrag TYPE betrz_kk
        p_logkz TYPE logkz_kk.

  DATA:
    l_fkkcollp_ip_w LIKE dfkkcollp_ip_w,
    l_agsta_text    TYPE ddfixvalue,
    h_storb         TYPE storb_kk,
    h_logkz         TYPE logkz_kk,
    h_xragl         TYPE xragl_kk,
    h_augbl         TYPE augbl_kk.

  DATA lv_txtvw           TYPE txtag_i_kk.
  DATA lv_betrw_content   TYPE betrw_kk.

  DATA ls_collpaym        TYPE fkkcollpaym.
  DATA ls_collpaymlink    TYPE fkkcollpaymlink.
  DATA ls_collections     TYPE fkkcollections.
  DATA ls_coli_log        TYPE fkkcoli_log.
  DATA ls_coli_log_ext    TYPE gty_fkkcoli_log_ext.
  DATA ls_postyp_sum      TYPE fkkcol_postyp_sum.
  DATA lv_collitem_lv     TYPE collitem_lv_kk.
  DATA ls_collpaym_logkz  TYPE gty_fkkcollpaym_logkz.
  DATA ls_fkkcollp_ip     LIKE fkkcollp_ip.

  FIELD-SYMBOLS <fs_collections>  TYPE fkkcollections.
  FIELD-SYMBOLS <fs_coli_log_ext>  TYPE gty_fkkcoli_log_ext.


  CLEAR: l_fkkcollp_ip_w.
  CLEAR: h_storb, h_logkz.

  IF p_logkz IS INITIAL AND
   ( p_t_fkkcollh-agsta = c_receivable_cancelled    OR
     p_t_fkkcollh-agsta = c_costumer_directly_paid  OR
     p_t_fkkcollh-agsta = c_costumer_partally_paid  OR
     p_t_fkkcollh-agsta = c_full_clearing           OR
     p_t_fkkcollh-agsta = c_partial_clearing ).
* check if the clearing document has been reversed
*    SELECT SINGLE augbl xragl INTO  (h_augbl, h_xragl)
*                        FROM  dfkkop
*                        WHERE opbel EQ p_t_fkkcollh-augbl.
*    IF NOT h_xragl IS INITIAL.
* note 2915575: check based on DFKKRAPT because a partial
*      reset clearing could be possible
     SELECT SINGLE stblg INTO h_augbl FROM dfkkrapt
        WHERE opbel EQ p_t_fkkcollh-opbel AND
              augbl EQ p_t_fkkcollh-augbl.
    IF sy-subrc = 0.
      h_logkz = 'X'.
      MOVE h_augbl TO t_stor.
      APPEND t_stor.
    ELSE.
      h_logkz = p_logkz.
    ENDIF.
*    SELECT SINGLE storb INTO  h_storb
*                        FROM  dfkkko
*                        WHERE opbel EQ p_t_fkkcollh-augbl.
*    IF NOT h_storb IS INITIAL.
*      h_logkz = 'X'.
*      MOVE h_storb TO t_stor.
*      APPEND t_stor.
*    ELSE.
*      h_logkz = p_logkz.
*    ENDIF.
  ELSE.
    h_logkz = p_logkz.
  ENDIF.

  IF  p_h_betrag GE 0.
    READ TABLE gt_dd07v
         WITH KEY domvalue_l = p_t_fkkcollh-agsta.
    lv_txtvw = gt_dd07v-ddtext.
  ELSE.
    IF p_t_fkkcollh-agsta EQ c_full_clearing.
      lv_txtvw = 'Gutschrift ausgeglichen'(007).
    ELSEIF p_t_fkkcollh-agsta EQ c_partial_clearing.
      lv_txtvw = 'Gutschrift teilausgeglichen'(008).
    ELSE.
      lv_txtvw = 'Gutschrift bezahlt'(002).
    ENDIF.
  ENDIF.

* ----------------------------------------------------------------------
* file based version (enterprise services not active)
* ----------------------------------------------------------------------
  IF gv_flg_coll_esoa_active IS INITIAL.

    l_fkkcollp_ip_w-laufd   = p_i_basics-runkey-laufd.
    l_fkkcollp_ip_w-laufi   = p_i_basics-runkey-laufi.
    l_fkkcollp_ip_w-w_inkgp = p_t_fkkcollh-inkgp.
    l_fkkcollp_ip_w-intnr   = p_h_intnr_c.
    ADD 1 TO p_h_lfd_p.
    l_fkkcollp_ip_w-lfnum   = p_h_lfd_p.
    l_fkkcollp_ip_w-lfdnr   = p_t_fkkcollh-lfdnr.
    l_fkkcollp_ip_w-logkz   = h_logkz.
    l_fkkcollp_ip_w-satztyp = c_position.
    l_fkkcollp_ip_w-postyp  = p_postyp.
    l_fkkcollp_ip_w-nrzas   = p_t_fkkcollh-nrzas.
    l_fkkcollp_ip_w-opbel   = p_t_fkkcollh-opbel.
    l_fkkcollp_ip_w-inkps   = p_t_fkkcollh-inkps.
    l_fkkcollp_ip_w-gpart   = p_t_fkkcollh-gpart.
    l_fkkcollp_ip_w-vkont   = p_t_fkkcollh-vkont.
    WRITE p_t_fkkcollh-betrw TO l_fkkcollp_ip_w-betrw
                                CURRENCY p_t_fkkcollh-waers.
    WRITE p_h_betrag         TO l_fkkcollp_ip_w-bwtrt
                                CURRENCY p_t_fkkcollh-waers. "#EC *
    l_fkkcollp_ip_w-waers   = p_t_fkkcollh-waers.
    l_fkkcollp_ip_w-augdt   = p_t_fkkcollh-rudat.

    l_fkkcollp_ip_w-txtvw = lv_txtvw.

    IF g_fkkcollinfo-sumknz  IS INITIAL AND
       l_fkkcollp_ip_w-logkz IS INITIAL.
*--> fill ls_fkkcollh_i from header data

      MOVE-CORRESPONDING l_fkkcollp_ip_w TO ls_fkkcollp_ip.

* ------- calls user exit 5052 / payment ------------------------------*
      PERFORM call_zp_fb_5052_payment
         USING
            p_postyp
            t_fkkcollh_i
            l_fkkcollp_ip_w-lfdnr
         CHANGING
            ls_fkkcollp_ip.

      MOVE-CORRESPONDING ls_fkkcollp_ip TO l_fkkcollp_ip_w.
    ENDIF.

* INSERT: Speichern Informationen zu Zahlungen
*>>>>> HANA
    DATA: lo_opt       TYPE REF TO if_fkk_optimization_settings,
          x_optimizing TYPE        xfeld.
    lo_opt = cl_fkk_optimization_settings=>get_instance( ).
    x_optimizing = lo_opt->is_active( cl_fkk_optimization_settings=>cc_fica_fpci_mass_insert ).
    IF x_optimizing = abap_true.
      APPEND l_fkkcollp_ip_w TO gt_fkkcollp_ip_w.
    ELSE.
      INSERT INTO dfkkcollp_ip_w VALUES l_fkkcollp_ip_w.  "OLD LOGIC
    ENDIF.
*<<<<< HANA

* Registrieren Inkassobüro
    gt_inkgp = l_fkkcollp_ip_w-w_inkgp.
    COLLECT gt_inkgp.

* Registrieren bearbeiteten Fall
    gt_fall = l_fkkcollp_ip_w-gpart.
    COLLECT gt_fall.

  ENDIF.

* ----------------------------------------------------------------------
* enterprise service version (enterprise services active)
* ----------------------------------------------------------------------
  IF gv_flg_coll_esoa_active = 'X'.

* payment information
    CLEAR ls_collpaym.

    ls_collpaym-inkgp = p_t_fkkcollh-inkgp.
    ls_collpaym-gpart = p_t_fkkcollh-gpart.

    ls_collpaym-collpaym_id = p_t_fkkcollh-augbl.
    ls_collpaym-collpaym_tp = '1'.

    ls_collpaym-waers = p_t_fkkcollh-waers.
    ls_collpaym-betrw = p_h_betrag.
    ls_collpaym-valut = p_t_fkkcollh-rudat.

* payment assignment information
    CLEAR ls_collpaymlink.

    ls_collpaymlink-inkgp = p_t_fkkcollh-inkgp.
    ls_collpaymlink-gpart = p_t_fkkcollh-gpart.

    ls_collpaymlink-collpaym_id = p_t_fkkcollh-augbl.
    ls_collpaymlink-collpaym_tp = '1'.

    CONCATENATE p_t_fkkcollh-opbel p_t_fkkcollh-inkps INTO ls_collpaymlink-collitem_id.

    SELECT SINGLE collitem_lv FROM dfkkcollitem INTO lv_collitem_lv
            WHERE collitem_id = ls_collpaymlink-collitem_id.
    IF sy-subrc = 0 AND NOT lv_collitem_lv IS INITIAL.
      ls_collpaymlink-collitem_lv = lv_collitem_lv.
    ELSE.
      ls_collpaymlink-collitem_lv = '01'.
    ENDIF.

    ls_collpaymlink-waers = p_t_fkkcollh-waers.

    lv_betrw_content      = p_h_betrag.
    ls_collpaymlink-betrz = lv_betrw_content.
    ls_collpaymlink-paydt = p_t_fkkcollh-rudat.

    ls_collpaymlink-txtkm = lv_txtvw.

* logkz information
    CLEAR ls_collpaym_logkz.
    ls_collpaym_logkz-inkgp = p_t_fkkcollh-inkgp.
    ls_collpaym_logkz-collpaym_id = p_t_fkkcollh-augbl.
    ls_collpaym_logkz-collpaym_tp = '1'.
    ls_collpaym_logkz-logkz = h_logkz.
    APPEND ls_collpaym_logkz TO gt_collpaym_logkz.

* insert into global collections table
    READ TABLE gt_collections_hash ASSIGNING <fs_collections>
      WITH TABLE KEY inkgp = ls_collpaymlink-inkgp
                     gpart = ls_collpaymlink-gpart.
    IF sy-subrc = 0.
      COLLECT ls_collpaym INTO <fs_collections>-collpaym_tab.
      APPEND ls_collpaymlink TO <fs_collections>-collpaymlink_tab.
    ELSE.
      CLEAR ls_collections.
      ls_collections-inkgp = ls_collpaymlink-inkgp.
      ls_collections-gpart = ls_collpaymlink-gpart.
      APPEND ls_collpaym TO ls_collections-collpaym_tab.
      APPEND ls_collpaymlink TO ls_collections-collpaymlink_tab.
      INSERT ls_collections INTO TABLE gt_collections_hash.
    ENDIF.


* collect information for DFKKCOLI_LOG
    CLEAR ls_coli_log.
    ls_coli_log-opbel  = p_t_fkkcollh-opbel.
    ls_coli_log-inkps  = p_t_fkkcollh-inkps.
    ls_coli_log-gpart  = p_t_fkkcollh-gpart.
    ls_coli_log-lfdnr  = p_t_fkkcollh-lfdnr.
    ls_coli_log-postyp = p_postyp.
    ls_coli_log-vkont  = p_t_fkkcollh-vkont.
    ls_coli_log-betrw  = p_t_fkkcollh-betrw.
*  ls_coli_log-bwtrt  = p_t_fkkcollh-bwtrt.
    ls_coli_log-waers  = p_t_fkkcollh-waers.
*  ls_coli_log-augdt  = p_t_fkkcollh-augdt.
*  ls_coli_log-txtvw  = p_t_fkkcollh-txtvw.
    ls_coli_log-ernam  = sy-uname.
    ls_coli_log-erdat  = sy-datum.
    ls_coli_log-erzeit = sy-uzeit.
    ls_coli_log-laufd  = p_i_basics-runkey-laufd.
    ls_coli_log-laufi  = p_i_basics-runkey-laufi.

* collect information for application log
    CLEAR ls_postyp_sum.
    ls_postyp_sum-inkgp = p_t_fkkcollh-inkgp.
    IF lv_xml_for_gpart IS INITIAL.
      CLEAR ls_postyp_sum-gpart.
    ELSE.
      ls_postyp_sum-gpart = p_t_fkkcollh-gpart.
    ENDIF.
    ls_postyp_sum-postyp = p_postyp.
    ls_postyp_sum-waers  = p_t_fkkcollh-waers.
    ls_postyp_sum-betrw  = lv_betrw_content.
    ls_postyp_sum-poscnt = 1.

* insert into global coli_log table
    READ TABLE gt_coli_log_ext_hash ASSIGNING <fs_coli_log_ext>
      WITH TABLE KEY inkgp = p_t_fkkcollh-inkgp
                     gpart = p_t_fkkcollh-gpart.
    IF sy-subrc = 0.
      APPEND ls_coli_log TO <fs_coli_log_ext>-coli_log_tab.
      IF h_logkz IS INITIAL.
        COLLECT ls_postyp_sum INTO <fs_coli_log_ext>-postyp_sum_tab.
      ENDIF.
    ELSE.
      CLEAR ls_coli_log_ext.
      ls_coli_log_ext-inkgp = p_t_fkkcollh-inkgp.
      ls_coli_log_ext-gpart = p_t_fkkcollh-gpart.
      APPEND ls_coli_log TO ls_coli_log_ext-coli_log_tab.
      IF h_logkz IS INITIAL.
        COLLECT ls_postyp_sum INTO ls_coli_log_ext-postyp_sum_tab.
      ENDIF.
      INSERT ls_coli_log_ext INTO TABLE gt_coli_log_ext_hash.
    ENDIF.


  ENDIF.

ENDFORM.                    " info_payment
*&---------------------------------------------------------------------*
*&      Form  info_recall
*&---------------------------------------------------------------------*
FORM info_recall
     USING
        p_i_basics TYPE fkk_mad_basics
        p_h_intnr_c TYPE intnr_i_kk
        p_t_fkkcollh LIKE dfkkcollh
        p_h_lfd_r TYPE lfnum_kk
        p_w_collh_last LIKE dfkkcollh
        p_t_fkkcoli_log STRUCTURE dfkkcoli_log.
*       p_logkz type logkz_kk.

  DATA:
    l_fkkcollp_ir_w LIKE dfkkcollp_ir_w,
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
    l_fkkcollp_ir_w-postyp  = c_recall.
    l_fkkcollp_ir_w-nrzas   = p_t_fkkcollh-nrzas.
    l_fkkcollp_ir_w-opbel   = p_t_fkkcollh-opbel.
    l_fkkcollp_ir_w-inkps   = p_t_fkkcollh-inkps.
    l_fkkcollp_ir_w-gpart   = p_t_fkkcollh-gpart.
    l_fkkcollp_ir_w-vkont   = p_t_fkkcollh-vkont.
    IF p_w_collh_last-agsta EQ c_receivable_part_paid.
* If the debt collecting agency only partly paid a demand, the remainder is recalled.
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
    l_fkkcollp_ir_w-waers   = p_t_fkkcollh-waers.
    l_fkkcollp_ir_w-rudat   = p_t_fkkcollh-rudat.

    l_fkkcollp_ir_w-txtvw = lv_txtvw.

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

* ----------------------------------------------------------------------
* enterprise service version (enterprise services active)
* ----------------------------------------------------------------------
  IF gv_flg_coll_esoa_active = 'X'.

* collection unit information
    CLEAR ls_collitem.
    ls_collitem-inkgp = p_t_fkkcollh-inkgp.
    ls_collitem-gpart = p_t_fkkcollh-gpart.
    CONCATENATE p_t_fkkcollh-opbel p_t_fkkcollh-inkps INTO ls_collitem-collitem_id.

    SELECT SINGLE collitem_lv FROM dfkkcollitem INTO lv_collitem_lv
            WHERE collitem_id = ls_collitem-collitem_id.
    IF sy-subrc = 0 AND NOT lv_collitem_lv IS INITIAL.
      ls_collitem-collitem_lv = lv_collitem_lv.
    ELSE.
      ls_collitem-collitem_lv = '01'.
    ENDIF.

    ls_collitem-waers = p_t_fkkcollh-waers.
    ls_collitem-rcdat = p_t_fkkcollh-rudat.
    ls_collitem-txtkm = lv_txtvw.

    IF p_w_collh_last-agsta EQ c_receivable_part_paid.
* If the debt collecting agency only partly paid a demand, the remainder is recalled.
      ls_collitem-rinkb = p_t_fkkcollh-betrw - p_t_fkkcollh-betrz.
    ELSEIF ( p_w_collh_last-agsta EQ c_costumer_partally_paid OR
             p_w_collh_last-agsta EQ c_partial_clearing ) AND
             p_w_collh_last-lfdnr EQ p_t_fkkcoli_log-lfdnr.
      ls_collitem-rinkb = p_t_fkkcollh-betrw - p_t_fkkcollh-betrz.
    ELSE.
      ls_collitem-rinkb = p_t_fkkcollh-betrw.
    ENDIF.
    lv_betrw_content = ls_collitem-rinkb.

* insert into global collections table
    READ TABLE gt_collections_hash ASSIGNING <fs_collections>
      WITH TABLE KEY inkgp = ls_collitem-inkgp
                     gpart = ls_collitem-gpart.
    IF sy-subrc = 0.
      APPEND ls_collitem TO <fs_collections>-collitem_tab.
    ELSE.
      CLEAR ls_collections.
      ls_collections-inkgp = ls_collitem-inkgp.
      ls_collections-gpart = ls_collitem-gpart.
      APPEND ls_collitem TO ls_collections-collitem_tab.
      INSERT ls_collections INTO TABLE gt_collections_hash.
    ENDIF.

* collect information for DFKKCOLI_LOG
    CLEAR ls_coli_log.
    ls_coli_log-opbel  = p_t_fkkcollh-opbel.
    ls_coli_log-inkps  = p_t_fkkcollh-inkps.
    ls_coli_log-gpart  = p_t_fkkcollh-gpart.
    ls_coli_log-lfdnr  = p_t_fkkcollh-lfdnr.
    ls_coli_log-postyp = c_recall.
    ls_coli_log-vkont  = p_t_fkkcollh-vkont.
    ls_coli_log-betrw  = p_t_fkkcollh-betrw.
*  ls_coli_log-bwtrt  = p_t_fkkcollh-bwtrt.
    ls_coli_log-waers  = p_t_fkkcollh-waers.
*  ls_coli_log-augdt  = p_t_fkkcollh-augdt.
*  ls_coli_log-txtvw  = p_t_fkkcollh-txtvw.
    ls_coli_log-ernam  = sy-uname.
    ls_coli_log-erdat  = sy-datum.
    ls_coli_log-erzeit = sy-uzeit.
    ls_coli_log-laufd  = p_i_basics-runkey-laufd.
    ls_coli_log-laufi  = p_i_basics-runkey-laufi.

* collect information for application log
    CLEAR ls_postyp_sum.
    ls_postyp_sum-inkgp  = p_t_fkkcollh-inkgp.
    IF lv_xml_for_gpart IS INITIAL.
      CLEAR ls_postyp_sum-gpart.
    ELSE.
      ls_postyp_sum-gpart = p_t_fkkcollh-gpart.
    ENDIF.
    ls_postyp_sum-postyp = c_recall.
    ls_postyp_sum-waers  = p_t_fkkcollh-waers.
    ls_postyp_sum-betrw  = lv_betrw_content.
    ls_postyp_sum-poscnt = 1.

* insert into global coli_log table
    READ TABLE gt_coli_log_ext_hash ASSIGNING <fs_coli_log_ext>
      WITH TABLE KEY inkgp = p_t_fkkcollh-inkgp
                     gpart = p_t_fkkcollh-gpart.
    IF sy-subrc = 0.
      APPEND ls_coli_log TO <fs_coli_log_ext>-coli_log_tab.
      COLLECT ls_postyp_sum INTO <fs_coli_log_ext>-postyp_sum_tab.
    ELSE.
      CLEAR ls_coli_log_ext.
      ls_coli_log_ext-inkgp = p_t_fkkcollh-inkgp.
      ls_coli_log_ext-gpart = p_t_fkkcollh-gpart.
      APPEND ls_coli_log TO ls_coli_log_ext-coli_log_tab.
      COLLECT ls_postyp_sum INTO ls_coli_log_ext-postyp_sum_tab.
      INSERT ls_coli_log_ext INTO TABLE gt_coli_log_ext_hash.
    ENDIF.

  ENDIF.

ENDFORM.                    " info_recall
*&---------------------------------------------------------------------*
*&      Form  read_header_infos
*&---------------------------------------------------------------------*
FORM read_header_infos TABLES p_t_fkkcollh_i_w STRUCTURE dfkkcollh_i_w
                       USING  p_i_basics TYPE fkk_mad_basics.

  CLEAR: p_t_fkkcollh_i_w[], p_t_fkkcollh_i_w.

  SELECT * INTO  TABLE p_t_fkkcollh_i_w
           FROM  dfkkcollh_i_w
           WHERE laufd EQ p_i_basics-runkey-laufd
           AND   laufi EQ p_i_basics-runkey-laufi.

  SORT p_t_fkkcollh_i_w BY w_inkgp.

ENDFORM.                    " read_header_infos
*&---------------------------------------------------------------------*
*&      Form  create_file_header
*&---------------------------------------------------------------------*
FORM create_file_header USING    p_fkkcollinfo    TYPE fkkcollinfo
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
       USING
          p_i_basics
          p_fkkcollinfo-datei
          p_t_fkkcollh_i_w-inkgp
       CHANGING
          p_h_file_name.

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
         USING
            p_t_fkkcollh_i_w
         CHANGING
            p_t_fkkcollh_i.

* Schreiben Datei-Kopfsatz
      IF p_i_basics-status-xsimu IS INITIAL.
        TRANSFER t_fkkcollh_i TO p_h_file_name.
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

ENDFORM.                    " create_file_header
*&---------------------------------------------------------------------*
*&      Form  create_file_body
*&---------------------------------------------------------------------*
FORM create_file_body USING    p_fkkcollinfo TYPE fkkcollinfo
                               p_h_file_name
                               p_t_fkkcollh_i_w LIKE dfkkcollh_i_w
                               p_t_fkkcollh_i LIKE fkkcollh_i
                               p_i_basics TYPE fkk_mad_basics
                      CHANGING p_t_fkkcollt_i LIKE fkkcollt_i.

* Erzeugen Positionen für direkte Zahlungen
***  if not p_fkkcollinfo-xausg is initial.
  PERFORM create_info_payment
     USING
        c_payment
        p_fkkcollinfo
        p_h_file_name
        p_t_fkkcollh_i_w
        p_t_fkkcollh_i
        p_i_basics
     CHANGING
        p_t_fkkcollt_i.

* Erzeugen Positionen für Stornierungen von Zahlungen
  PERFORM create_info_payment
     USING
        c_storno
        p_fkkcollinfo
        p_h_file_name
        p_t_fkkcollh_i_w
        p_t_fkkcollh_i
        p_i_basics
     CHANGING
        p_t_fkkcollt_i.

* Erzeugen Positionen für Stornierungen abgegebener Forderungen
  PERFORM create_info_storno
     USING
        c_cancelled_receivable
        p_fkkcollinfo
        p_h_file_name
        p_t_fkkcollh_i_w
        p_t_fkkcollh_i
        p_i_basics
     CHANGING
        p_t_fkkcollt_i.


* Erzeugen Positionen für Ausbuchungen abgegebener Forderungen
  PERFORM create_info_storno
     USING
        c_write_off
        p_fkkcollinfo
        p_h_file_name
        p_t_fkkcollh_i_w
        p_t_fkkcollh_i
        p_i_basics
     CHANGING
        p_t_fkkcollt_i.


* Erzeugen Positionen für Ausgleich
  PERFORM create_info_payment
     USING
        c_clearing
        p_fkkcollinfo
        p_h_file_name
        p_t_fkkcollh_i_w
        p_t_fkkcollh_i
        p_i_basics
     CHANGING
        p_t_fkkcollt_i.

* Erzeugen Positionen für Zahlungen durch Inkassobüro
  PERFORM create_info_payment
     USING
        c_coll_ag_paid
        p_fkkcollinfo
        p_h_file_name
        p_t_fkkcollh_i_w
        p_t_fkkcollh_i
        p_i_basics
     CHANGING
        p_t_fkkcollt_i.
***  endif.

* Erzeugen Positionen für Rückruf
  IF NOT p_fkkcollinfo-xback IS INITIAL.
    PERFORM create_info_recall
       USING
          p_fkkcollinfo
          p_h_file_name
          p_t_fkkcollh_i_w
          p_t_fkkcollh_i
          p_i_basics
       CHANGING
         p_t_fkkcollt_i.
  ENDIF.

* Erzeugen Positionen für Geschäftspartner-Stammdatenänderungen
  IF NOT p_fkkcollinfo-xcpart IS INITIAL.
    PERFORM create_info_master_data_change
       USING
          p_fkkcollinfo
          p_h_file_name
          p_t_fkkcollh_i_w
          p_t_fkkcollh_i
          p_i_basics
       CHANGING
          p_t_fkkcollt_i.
  ENDIF.

ENDFORM.                    " create_file_body
*&---------------------------------------------------------------------*
*&      Form  create_trailer
*&---------------------------------------------------------------------*
FORM create_trailer USING    p_fkkcollinfo TYPE fkkcollinfo
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
    TRANSFER p_t_fkkcollt_i TO h_file_name.
  ENDIF.

ENDFORM.                    " create_trailer
*&---------------------------------------------------------------------*
*&      Form  create_filename
*&---------------------------------------------------------------------*
FORM create_filename USING    p_i_basics TYPE fkk_mad_basics
                              p_p_fkkcollinfo_datei
                              p_p_t_fkkcollh_i_w_inkgp
                     CHANGING p_h_file_name.

  DATA: w_knz       TYPE c,
        w_lfdnr(8)  TYPE n,
        w_lfdch(8)  TYPE c,
        w_file_name LIKE h_file_name, " authb-filename
        w_subname   LIKE authb-filename.

  CLEAR: w_knz, w_lfdnr, w_lfdch, w_file_name.

* Erzeugen Dateiname
  CONCATENATE p_p_t_fkkcollh_i_w_inkgp ' '
         INTO w_subname.

  IF p_p_fkkcollinfo_datei IS INITIAL.
* Falls logischer Dateiname ausgelassen, werden Abgabefiles in das
* HOME-Verzeichnis des aktuellen Servers abgelegt.
    p_h_file_name = w_subname.
  ELSE.
* Wurde ein logischer Dateiname angegeben, erfolgt nach Bereitstellung
* des phys. Dateinemens dessen Verknüpfung  mit zusätzlichen
* Informationen wie <Schlüssel des Inkassobüros> und laufende-Nummer.
    CALL FUNCTION 'FILE_GET_NAME'
      EXPORTING
        logical_filename = p_p_fkkcollinfo_datei
      IMPORTING
        file_name        = p_h_file_name
      EXCEPTIONS
        file_not_found   = 01.
    IF sy-subrc EQ 0.
      CONCATENATE p_h_file_name w_subname INTO p_h_file_name.
    ELSE.
      CONCATENATE p_p_fkkcollinfo_datei w_subname INTO p_h_file_name.
    ENDIF.
  ENDIF.

  CLEAR w_file_name.
  w_file_name = p_h_file_name.

* >>> note 1584972
* security enhancement (start)
  CALL FUNCTION 'FILE_VALIDATE_NAME'
    EXPORTING
      logical_filename           = 'FI-CA-COL-INFO'
    CHANGING
      physical_filename          = w_file_name
    EXCEPTIONS
      logical_filename_not_found = 1
      validation_failed          = 2
      OTHERS                     = 3.
  IF sy-subrc NE 0.
    mac_appl_log_msg sy-msgty sy-msgid sy-msgno
     sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
     c_msgprio_high '1' .
  ENDIF.
* security enhancement (end)
* <<< note 1584972

* Test Dateiname
  DO 99999998 TIMES.
    OPEN DATASET w_file_name FOR INPUT IN TEXT MODE
                                       ENCODING DEFAULT.
    IF NOT sy-subrc IS INITIAL.
      EXIT.
    ENDIF.

    IF w_knz IS INITIAL.
* Nachricht: Datei ... ist bereits vorhanden
      mac_appl_log_msg 'I' '>3' '805'
         p_h_file_name space space space
         c_msgprio_low '1'.
      SET EXTENDED CHECK OFF.
      IF 1 = 2. MESSAGE i805(>3). ENDIF.
      SET EXTENDED CHECK ON.

      w_knz = 'X'.
    ENDIF.

* close dataset
    CLOSE DATASET w_file_name.

* Erzeugen neuen Dateinamen, falls Datei schon existiert.
    CLEAR w_file_name.
    ADD 1 TO w_lfdnr.
    WRITE w_lfdnr TO w_lfdch NO-ZERO.
    SHIFT w_lfdch LEFT DELETING LEADING space.
    CONCATENATE p_h_file_name w_lfdch
           INTO w_file_name SEPARATED BY '_'.
  ENDDO.

  p_h_file_name =  w_file_name.

ENDFORM.                    " create_filename
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
*&      Form  create_info_payment
*&---------------------------------------------------------------------*
FORM create_info_payment USING
                            p_postyp TYPE postyp_kk
                            p_p_fkkcollinfo TYPE fkkcollinfo
                            p_p_h_file_name
                            p_p_t_fkkcollh_i_w LIKE dfkkcollh_i_w
                            p_p_t_fkkcollh_i LIKE fkkcollh_i
                            p_p_i_basics TYPE fkk_mad_basics
                         CHANGING
                            p_p_t_fkkcollt_i LIKE fkkcollt_i.

  DATA:
    t_fkkcollp_ip       LIKE fkkcollp_ip,
    t_fkkcollp_ip_w     LIKE dfkkcollp_ip_w,
    h_lfnum             LIKE dfkkcoli_log-lfdnr,
    h_anzza             LIKE sy-tabix,
    h_sumza             TYPE sumza_kk,
    h_summe             TYPE sumza_kk,
    h_knz,
    sum_fkkcollp_ip     LIKE fkkcollp_ip,
    t_fkkcollp_ip_w_old LIKE dfkkcollp_ip_w,
    hx_addtofile    TYPE xfeld.

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
    t_fkkcollp_ip,
    t_fkkcollp_ip_w,
    t_fkkcollp_ip_w_old,
    sum_fkkcollp_ip,
    h_anzza,
    h_summe,
    h_knz,
    hx_addtofile.

  CLEAR:
    h_key_nrzas,
    h_key_nrzas_old,
    h_key_gpart,
    h_key_gpart_old,
    h_key_vkont,
    h_key_vkont_old.

  CASE p_p_fkkcollinfo-sumknz.

    WHEN c_sum_no.
* ------- Keine Summierung --------------------------------------------*

* Lesen Ausgleichs-Informationen aus Zwischenspeicher
      SELECT * INTO CORRESPONDING FIELDS OF t_fkkcollp_ip_w
               FROM  dfkkcollp_ip_w
               WHERE laufd   EQ p_p_i_basics-runkey-laufd
               AND   laufi   EQ p_p_i_basics-runkey-laufi
               AND   w_inkgp EQ p_p_t_fkkcollh_i_w-w_inkgp
               AND   satztyp EQ c_position
               AND   postyp  EQ p_postyp
               ORDER BY nrzas opbel inkps gpart.

        MOVE-CORRESPONDING t_fkkcollp_ip_w TO t_fkkcollp_ip.

* ------- calls user exit 5052 / payment ------------------------------*
*        perform call_zp_fb_5052_payment
*           using
*              p_postyp
*              p_p_t_fkkcollh_i
*              t_fkkcollp_ip_w-lfdnr
*           changing
*              t_fkkcollp_ip.

* Ausgabe Inkassoposition auf Informationsdatei
        IF t_fkkcollp_ip_w-logkz IS INITIAL.
          ADD 1 TO h_anzza.
        ENDIF.
        IF p_p_i_basics-status-xsimu IS INITIAL.
          IF t_fkkcollp_ip_w-logkz IS INITIAL.
            IF g_sort IS INITIAL.
              TRANSFER t_fkkcollp_ip TO p_p_h_file_name.
            ELSE.
* append to an internal table and sort and transfer to the file later
              MOVE-CORRESPONDING t_fkkcollp_ip_w TO gt_fkkcollp_ip.
              MOVE-CORRESPONDING t_fkkcollp_ip   TO gt_fkkcollp_ip.
              APPEND gt_fkkcollp_ip.
            ENDIF.
          ENDIF.

* Meldung registrieren
          PERFORM write_log_record_payment
             USING
                t_fkkcollp_ip_w-lfdnr
                t_fkkcollp_ip
                p_p_i_basics.
        ENDIF.

* Aktualisieren Datei-Endesatz
        IF t_fkkcollp_ip_w-logkz IS INITIAL.
          ADD 1 TO p_p_t_fkkcollt_i-recnum.
          PERFORM addition
            USING
              t_fkkcollp_ip-bwtrt
            CHANGING
              p_p_t_fkkcollt_i-sumza.

* Aktualisieren Summensatz je Positionstyp
          PERFORM addition
            USING
              t_fkkcollp_ip-bwtrt
            CHANGING
              h_summe.
        ENDIF.

      ENDSELECT.


    WHEN c_sum_gpart.

* ------- Summierung auf Geschäftspartnerebene ---------------------*
* Lesen Zahlungs- bzw. Ausgleichs-Informationen aus Zwischenspeicher
      SELECT * INTO  CORRESPONDING FIELDS OF t_fkkcollp_ip_w
               FROM  dfkkcollp_ip_w
               WHERE laufd   EQ p_p_i_basics-runkey-laufd
               AND   laufi   EQ p_p_i_basics-runkey-laufi
               AND   w_inkgp EQ p_p_t_fkkcollh_i_w-w_inkgp
               AND   satztyp EQ c_position
               AND   postyp  EQ p_postyp
            ORDER BY gpart nrzas opbel inkps lfdnr.

        MOVE-CORRESPONDING t_fkkcollp_ip_w TO t_fkkcollp_ip.
        MOVE-CORRESPONDING t_fkkcollp_ip   TO h_key_gpart.

        IF h_key_gpart_old NE h_key_gpart.
* Gruppenwechsel
          IF NOT h_knz IS INITIAL.

* ------- calls user exit 5052 / payment (sum) ------------------------*
            PERFORM call_zp_fb_5052_payment
               USING
                  p_postyp
                  p_p_t_fkkcollh_i
                  0
               CHANGING
                  sum_fkkcollp_ip.

* Ausgabe Inkassoposition auf Informationsdatei
*            IF t_fkkcollp_ip_w-logkz IS INITIAL.
            "note 2890112: not enough to consider t_fkkcollp_ip_w_old as
            "  there could have been other records to report before
            IF hx_addtofile = true.
              ADD 1 TO h_anzza.

              IF p_p_i_basics-status-xsimu IS INITIAL.
                TRANSFER sum_fkkcollp_ip TO p_p_h_file_name.
              ENDIF.

* Aktualisieren Datei-Endesatz
              ADD 1 TO p_p_t_fkkcollt_i-recnum.
              PERFORM addition
                USING
                  sum_fkkcollp_ip-bwtrt
                CHANGING
                  p_p_t_fkkcollt_i-sumza.

            ENDIF.
          ENDIF.
          CLEAR sum_fkkcollp_ip.
          CLEAR hx_addtofile.
        ENDIF.
        h_knz = 'X'.

        IF t_fkkcollp_ip_w-logkz IS INITIAL.
          hx_addtofile = true.
        ENDIF.

* Aufbau Summensatz
        sum_fkkcollp_ip-postyp  = t_fkkcollp_ip-postyp.
        sum_fkkcollp_ip-satztyp = t_fkkcollp_ip-satztyp.
        sum_fkkcollp_ip-nrzas   = t_fkkcollp_ip-nrzas.
        sum_fkkcollp_ip-gpart   = t_fkkcollp_ip-gpart.
        sum_fkkcollp_ip-waers   = t_fkkcollp_ip-waers.
        sum_fkkcollp_ip-txtvw   = t_fkkcollp_ip-txtvw.

        ">>>Note 2072897
          IF t_fkkcollp_ip_w_old IS INITIAL OR
            ( t_fkkcollp_ip_w_old-vkont NE t_fkkcollp_ip_w-vkont
              OR t_fkkcollp_ip_w_old-nrzas NE t_fkkcollp_ip_w-nrzas
              OR t_fkkcollp_ip_w_old-opbel NE t_fkkcollp_ip_w-opbel
              OR t_fkkcollp_ip_w_old-inkps NE t_fkkcollp_ip_w-inkps ).

            PERFORM addition
        USING
          t_fkkcollp_ip-betrw
        CHANGING
          sum_fkkcollp_ip-betrw.
        ENDIF.

        IF t_fkkcollp_ip_w-logkz IS INITIAL.
          PERFORM addition
          USING
            t_fkkcollp_ip-bwtrt
          CHANGING
            sum_fkkcollp_ip-bwtrt.

* Aktualisieren Protokollsatz
          PERFORM addition
            USING
              t_fkkcollp_ip-bwtrt
            CHANGING
              h_summe.
        ENDIF.

* Meldung registrieren
        IF p_p_i_basics-status-xsimu IS INITIAL.
          PERFORM write_log_record_payment
             USING
                t_fkkcollp_ip_w-lfdnr
                t_fkkcollp_ip
                p_p_i_basics.
        ENDIF.

        MOVE-CORRESPONDING h_key_gpart TO h_key_gpart_old.

        CLEAR t_fkkcollp_ip_w_old.
        t_fkkcollp_ip_w_old = t_fkkcollp_ip_w.

      ENDSELECT.

* Ausagbe letzte Inkassoposition
      IF NOT h_knz IS INITIAL.

* ------- calls user exit 5052 / payment -----------------------------*
        PERFORM call_zp_fb_5052_payment
           USING
              p_postyp
              p_p_t_fkkcollh_i
              0
           CHANGING
              sum_fkkcollp_ip.

* Ausgabe Inkassoposition auf Informationsdatei
*        IF NOT h_summe IS INITIAL.
        IF hx_addtofile = true.  "note 2890112
          ADD 1 TO h_anzza.

          IF p_p_i_basics-status-xsimu IS INITIAL.
            TRANSFER sum_fkkcollp_ip TO p_p_h_file_name.
          ENDIF.
*        ENDIF.
        h_knz = 'X'.

* Aktualisieren Datei-Endesatz
*        IF t_fkkcollp_ip_w-logkz IS INITIAL.
          ADD 1 TO p_p_t_fkkcollt_i-recnum.
          PERFORM addition
             USING
               sum_fkkcollp_ip-bwtrt
             CHANGING
               p_p_t_fkkcollt_i-sumza.
        ENDIF.
      ENDIF.


    WHEN c_sum_nrzas.
* ------- Summierung auf Basis Zahlschein-Nummer ----------------------*

* Lesen Ausgleichs-Informationen aus Zwischenspeicher
      SELECT * INTO  CORRESPONDING FIELDS OF t_fkkcollp_ip_w
               FROM  dfkkcollp_ip_w
               WHERE laufd   EQ p_p_i_basics-runkey-laufd
               AND   laufi   EQ p_p_i_basics-runkey-laufi
               AND   w_inkgp EQ p_p_t_fkkcollh_i_w-w_inkgp
               AND   satztyp EQ c_position
               AND   postyp  EQ p_postyp
            ORDER BY nrzas gpart opbel inkps lfdnr.

        MOVE-CORRESPONDING t_fkkcollp_ip_w TO t_fkkcollp_ip.
        MOVE-CORRESPONDING t_fkkcollp_ip   TO h_key_nrzas.

        IF h_key_nrzas_old NE h_key_nrzas.
* Gruppenwechsel
          IF NOT h_knz IS INITIAL.
* ------- calls user exit 5052 / payment (sum) ------------------------*
            PERFORM call_zp_fb_5052_payment
               USING
                  p_postyp
                  p_p_t_fkkcollh_i
                  0
               CHANGING
                  sum_fkkcollp_ip.

* Ausgabe Inkassoposition auf Informationsdatei
*            IF t_fkkcollp_ip_w-logkz IS INITIAL.
            "note 2890112: not enough to consider t_fkkcollp_ip_w_old as
            "  there could have been other records to report before
            IF hx_addtofile = true.
              ADD 1 TO h_anzza.

              IF p_p_i_basics-status-xsimu IS INITIAL.
                TRANSFER sum_fkkcollp_ip TO p_p_h_file_name.
              ENDIF.

* Aktualisieren Datei-Endesatz
              ADD 1 TO p_p_t_fkkcollt_i-recnum.
              PERFORM addition
                 USING
                   sum_fkkcollp_ip-bwtrt
                 CHANGING
                   p_p_t_fkkcollt_i-sumza.
            ENDIF.
          ENDIF.
          CLEAR sum_fkkcollp_ip.
          CLEAR hx_addtofile.
        ENDIF.
        h_knz = 'X'.

        IF t_fkkcollp_ip_w-logkz IS INITIAL.
          hx_addtofile = true.
        ENDIF.

* Aufbau Summensatz
        sum_fkkcollp_ip-postyp  = t_fkkcollp_ip-postyp.
        sum_fkkcollp_ip-satztyp = t_fkkcollp_ip-satztyp.
        sum_fkkcollp_ip-nrzas   = t_fkkcollp_ip-nrzas.
        sum_fkkcollp_ip-gpart   = t_fkkcollp_ip-gpart.
        sum_fkkcollp_ip-waers   = t_fkkcollp_ip-waers.
        sum_fkkcollp_ip-txtvw   = t_fkkcollp_ip-txtvw.

        ">>>Note 2072897
          IF t_fkkcollp_ip_w_old IS INITIAL OR
            ( t_fkkcollp_ip_w_old-vkont NE t_fkkcollp_ip_w-vkont
              OR t_fkkcollp_ip_w_old-nrzas NE t_fkkcollp_ip_w-nrzas
              OR t_fkkcollp_ip_w_old-opbel NE t_fkkcollp_ip_w-opbel
              OR t_fkkcollp_ip_w_old-inkps NE t_fkkcollp_ip_w-inkps ).

            PERFORM addition
        USING
          t_fkkcollp_ip-betrw
        CHANGING
          sum_fkkcollp_ip-betrw.
          ENDIF.

        IF t_fkkcollp_ip_w-logkz IS INITIAL.
          PERFORM addition
          USING
            t_fkkcollp_ip-bwtrt
          CHANGING
            sum_fkkcollp_ip-bwtrt.

* Aktualisieren Protokollsatz
          PERFORM addition
            USING
              t_fkkcollp_ip-bwtrt
            CHANGING
              h_summe.
        ENDIF.

* Meldung registrieren
        IF p_p_i_basics-status-xsimu IS INITIAL.
          PERFORM write_log_record_payment
             USING
                t_fkkcollp_ip_w-lfdnr
                t_fkkcollp_ip
                p_p_i_basics.
        ENDIF.

* Merken letzte Schlüssel
        MOVE-CORRESPONDING h_key_nrzas TO h_key_nrzas_old.
        CLEAR t_fkkcollp_ip_w_old.
        t_fkkcollp_ip_w_old = t_fkkcollp_ip_w.

      ENDSELECT.

      IF NOT h_knz IS INITIAL.
* ------- calls user exit 5052 / payment (sum) ------------------------*
        PERFORM call_zp_fb_5052_payment
           USING
              p_postyp
              p_p_t_fkkcollh_i
              0
           CHANGING
              sum_fkkcollp_ip.

* Ausgabe Inkassoposition auf Informationsdatei
*        IF NOT h_summe IS INITIAL.
        IF hx_addtofile = true.  "note 2890112
          ADD 1 TO h_anzza.
          IF p_p_i_basics-status-xsimu IS INITIAL.
            TRANSFER sum_fkkcollp_ip TO p_p_h_file_name.
          ENDIF.
*        ENDIF.
        h_knz = 'X'.

* Aktualisieren Datei-Endesatz
*        IF t_fkkcollp_ip_w-logkz IS INITIAL.
          ADD 1 TO p_p_t_fkkcollt_i-recnum.
          PERFORM addition
            USING
              sum_fkkcollp_ip-bwtrt
            CHANGING
             p_p_t_fkkcollt_i-sumza.
        ENDIF.
      ENDIF.

    WHEN c_sum_vkont.

* ------- Summierung auf Vertragskontoebene ---------------------*
* Lesen Zahlungs- bzw. Ausgleichs-Informationen aus Zwischenspeicher
      SELECT * INTO  CORRESPONDING FIELDS OF t_fkkcollp_ip_w
               FROM  dfkkcollp_ip_w
               WHERE laufd   EQ p_p_i_basics-runkey-laufd
               AND   laufi   EQ p_p_i_basics-runkey-laufi
               AND   w_inkgp EQ p_p_t_fkkcollh_i_w-w_inkgp
               AND   satztyp EQ c_position
               AND   postyp  EQ p_postyp
            ORDER BY vkont nrzas opbel inkps lfdnr.

        MOVE-CORRESPONDING t_fkkcollp_ip_w TO t_fkkcollp_ip.
        MOVE-CORRESPONDING t_fkkcollp_ip   TO h_key_vkont.

        IF h_key_vkont_old NE h_key_vkont.
* Gruppenwechsel
          IF NOT h_knz IS INITIAL.

* ------- calls user exit 5052 / payment (sum) ------------------------*
            PERFORM call_zp_fb_5052_payment
               USING
                  p_postyp
                  p_p_t_fkkcollh_i
                  0
               CHANGING
                  sum_fkkcollp_ip.

* Ausgabe Inkassoposition auf Informationsdatei
*            IF t_fkkcollp_ip_w-logkz IS INITIAL.
            "note 2890112: not enough to consider t_fkkcollp_ip_w_old as
            "  there could have been other records to report before
            IF hx_addtofile = true.
              ADD 1 TO h_anzza.

              IF p_p_i_basics-status-xsimu IS INITIAL.
                TRANSFER sum_fkkcollp_ip TO p_p_h_file_name.
              ENDIF.

* Aktualisieren Datei-Endesatz
              ADD 1 TO p_p_t_fkkcollt_i-recnum.
              PERFORM addition
                USING
                  sum_fkkcollp_ip-bwtrt
                CHANGING
                  p_p_t_fkkcollt_i-sumza.

            ENDIF.
          ENDIF.
          CLEAR sum_fkkcollp_ip.
          CLEAR hx_addtofile.
        ENDIF.
        h_knz = 'X'.

        IF t_fkkcollp_ip_w-logkz IS INITIAL.
          hx_addtofile = true.
        ENDIF.

* Aufbau Summensatz
        sum_fkkcollp_ip-postyp  = t_fkkcollp_ip-postyp.
        sum_fkkcollp_ip-satztyp = t_fkkcollp_ip-satztyp.
        sum_fkkcollp_ip-nrzas   = t_fkkcollp_ip-nrzas.
        sum_fkkcollp_ip-gpart   = t_fkkcollp_ip-gpart.
        sum_fkkcollp_ip-vkont   = t_fkkcollp_ip-vkont.
        sum_fkkcollp_ip-waers   = t_fkkcollp_ip-waers.
        sum_fkkcollp_ip-txtvw   = t_fkkcollp_ip-txtvw.

        ">>>Note 2072897
          IF t_fkkcollp_ip_w_old IS INITIAL OR
            ( t_fkkcollp_ip_w_old-vkont NE t_fkkcollp_ip_w-vkont
              OR t_fkkcollp_ip_w_old-nrzas NE t_fkkcollp_ip_w-nrzas
              OR t_fkkcollp_ip_w_old-opbel NE t_fkkcollp_ip_w-opbel
              OR t_fkkcollp_ip_w_old-inkps NE t_fkkcollp_ip_w-inkps ).

            PERFORM addition
        USING
          t_fkkcollp_ip-betrw
        CHANGING
          sum_fkkcollp_ip-betrw.
          ENDIF.

        IF t_fkkcollp_ip_w-logkz IS INITIAL.
          PERFORM addition
          USING
            t_fkkcollp_ip-bwtrt
          CHANGING
            sum_fkkcollp_ip-bwtrt.

* Aktualisieren Protokollsatz
          PERFORM addition
            USING
              t_fkkcollp_ip-bwtrt
            CHANGING
              h_summe.
        ENDIF.

* Meldung registrieren
        IF p_p_i_basics-status-xsimu IS INITIAL.
          PERFORM write_log_record_payment
             USING
                t_fkkcollp_ip_w-lfdnr
                t_fkkcollp_ip
                p_p_i_basics.
        ENDIF.

        MOVE-CORRESPONDING h_key_vkont TO h_key_vkont_old.
        CLEAR t_fkkcollp_ip_w_old.
        t_fkkcollp_ip_w_old = t_fkkcollp_ip_w.

      ENDSELECT.

* Ausgabe letzte Inkassoposition
      IF NOT h_knz IS INITIAL.

* ------- calls user exit 5052 / payment -----------------------------*
        PERFORM call_zp_fb_5052_payment
           USING
              p_postyp
              p_p_t_fkkcollh_i
              0
           CHANGING
              sum_fkkcollp_ip.

* Ausgabe Inkassoposition auf Informationsdatei
*        IF NOT h_summe IS INITIAL.
        IF hx_addtofile = true.  "note 2890112
          ADD 1 TO h_anzza.

          IF p_p_i_basics-status-xsimu IS INITIAL.
            TRANSFER sum_fkkcollp_ip TO p_p_h_file_name.
          ENDIF.
*        ENDIF.
        h_knz = 'X'.

* Aktualisieren Datei-Endesatz
*        IF t_fkkcollp_ip_w-logkz IS INITIAL.
          ADD 1 TO p_p_t_fkkcollt_i-recnum.
          PERFORM addition
             USING
               sum_fkkcollp_ip-bwtrt
             CHANGING
               p_p_t_fkkcollt_i-sumza.
        ENDIF.
      ENDIF.

  ENDCASE.

*>>>>> HANA
  IF NOT gt_fkkcoli_log[] IS INITIAL.
    INSERT dfkkcoli_log FROM TABLE gt_fkkcoli_log.
    CLEAR: gt_fkkcoli_log[],gt_fkkcoli_log.
  ENDIF.
*<<<<< HANA

* Protokoll
  WRITE h_summe TO h_sumza.
  SHIFT h_sumza LEFT DELETING LEADING space.
  IF p_postyp EQ c_payment.
* Nachricht: Datei enthält & Zahlungs-Positionen im Gesamtwert von & &
    IF h_anzza > 0.
      mac_appl_log_msg 'I' '>4' '810'
         h_anzza
         h_sumza t_fkkcollp_ip-waers space
         c_msgprio_info p_p_i_basics-appllog-probclass.
      SET EXTENDED CHECK OFF.
      IF 1 = 2. MESSAGE i810(>4). ENDIF.
      SET EXTENDED CHECK ON.
    ENDIF.

  ELSEIF p_postyp EQ c_storno.
* Nachricht: Datei enthält & Storno-Positionen im Gesamtwert von & &
    IF h_anzza > 0.
      mac_appl_log_msg 'I' '>4' '809'
         h_anzza
         h_sumza t_fkkcollp_ip-waers space
         c_msgprio_info p_p_i_basics-appllog-probclass.
      SET EXTENDED CHECK OFF.
      IF 1 = 2. MESSAGE i809(>4). ENDIF.
      SET EXTENDED CHECK ON.
    ENDIF.

  ELSEIF p_postyp EQ c_clearing.
* Nachricht: Datei enthält & Ausgleichspositionen im Gesamtwert von & &
    IF h_anzza > 0.
      mac_appl_log_msg 'I' '>4' '802'
         h_anzza
         h_sumza t_fkkcollp_ip-waers space
         c_msgprio_info p_p_i_basics-appllog-probclass.
      SET EXTENDED CHECK OFF.
      IF 1 = 2. MESSAGE i802(>4). ENDIF.
      SET EXTENDED CHECK ON.
    ENDIF.

  ENDIF.

ENDFORM.                    " create_info_payment
*&---------------------------------------------------------------------*
*&      Form  create_info_recall
*&---------------------------------------------------------------------*
FORM create_info_recall USING    p_p_fkkcollinfo TYPE fkkcollinfo
                                 p_p_h_file_name
                                 p_p_t_fkkcollh_i_w LIKE dfkkcollh_i_w
                                 p_p_t_fkkcollh_i LIKE fkkcollh_i
                                 p_p_i_basics TYPE fkk_mad_basics
                        CHANGING p_p_t_fkkcollt_i LIKE fkkcollt_i.

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

  CASE p_p_fkkcollinfo-sumknz.

    WHEN c_sum_no.
* ------- Keine Summierung --------------------------------------------*

* Lesen Rückruf-Informationen aus Zwischenspeicher
      OPEN CURSOR WITH HOLD cursor FOR
        SELECT * FROM  dfkkcollp_ir_w
               WHERE laufd   EQ p_p_i_basics-runkey-laufd
               AND   laufi   EQ p_p_i_basics-runkey-laufi
               AND   w_inkgp EQ p_p_t_fkkcollh_i_w-w_inkgp
               AND   satztyp EQ c_position
               AND   postyp  EQ c_recall
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
*          PERFORM call_zp_fb_5052_recall
*             USING
*                p_p_t_fkkcollh_i
*                  ls_fkkcollp_ir_w-lfdnr
*             CHANGING
*                t_fkkcollp_ir.

* Ausgabe Rückrufinformation auf Informationsdatei
          ADD 1 TO h_anzrc.
          IF p_p_i_basics-status-xsimu IS INITIAL.
            IF g_sort IS INITIAL.
              TRANSFER t_fkkcollp_ir TO p_p_h_file_name.
            ELSE.
* append to an internal table and sort and transfer to the file later
              MOVE-CORRESPONDING ls_fkkcollp_ir_w TO gt_fkkcollp_ir.
              MOVE-CORRESPONDING t_fkkcollp_ir   TO gt_fkkcollp_ir.
              APPEND gt_fkkcollp_ir.
            ENDIF.

* Registrieren Meldung in Log-Tabelle
            PERFORM write_log_record_recall
               USING
                    ls_fkkcollp_ir_w-lfdnr
                  t_fkkcollp_ir
                  p_p_i_basics.
          ENDIF.

* Aktualisieren Datei-Endesatz
          ADD 1 TO p_p_t_fkkcollt_i-recnum.
          PERFORM addition
            USING
              t_fkkcollp_ir-betrw
            CHANGING
              p_p_t_fkkcollt_i-sumrc.
          PERFORM addition
            USING
              t_fkkcollp_ir-betrw
            CHANGING
              h_summe.

        ENDLOOP.
      ENDDO.

      CLOSE CURSOR cursor.

    WHEN c_sum_gpart.
* ------- Summierung über Geschäftspartner-Nummer ---------------------*

* Lesen Rückruf-Informationen aus Zwischenspeicher
      SELECT * INTO  CORRESPONDING FIELDS OF t_fkkcollp_ir_w
               FROM  dfkkcollp_ir_w
               WHERE laufd   EQ p_p_i_basics-runkey-laufd
               AND   laufi   EQ p_p_i_basics-runkey-laufi
               AND   w_inkgp EQ p_p_t_fkkcollh_i_w-w_inkgp
               AND   satztyp EQ c_position
               AND   postyp  EQ c_recall
               ORDER BY gpart nrzas opbel inkps.

        MOVE-CORRESPONDING t_fkkcollp_ir_w TO t_fkkcollp_ir.
        MOVE-CORRESPONDING t_fkkcollp_ir TO h_key_gpart.

        IF h_key_gpart_old NE h_key_gpart.
* Gruppenwechsel
          IF NOT h_knz IS INITIAL.

* ------- calls user exit 5052 / recall (sum) -------------------------*
            PERFORM call_zp_fb_5052_recall
               USING
                  p_p_t_fkkcollh_i
                  0
               CHANGING
                  sum_fkkcollp_ir.

* Ausgabe Rückruf auf Informationsdatei
            ADD 1 TO h_anzrc.
            IF p_p_i_basics-status-xsimu IS INITIAL.
              TRANSFER sum_fkkcollp_ir TO p_p_h_file_name.
            ENDIF.

* Aktualisieren Datei-Endesatz
            ADD 1 TO p_p_t_fkkcollt_i-recnum.
            PERFORM addition
              USING
                sum_fkkcollp_ir-betrw
              CHANGING
                p_p_t_fkkcollt_i-sumrc.
          ENDIF.
          CLEAR sum_fkkcollp_ir.
        ENDIF.
        h_knz = 'X'.

* Aufbau Summensatz
        sum_fkkcollp_ir-postyp  = t_fkkcollp_ir-postyp.
        sum_fkkcollp_ir-satztyp = t_fkkcollp_ir-satztyp.
        sum_fkkcollp_ir-nrzas   = t_fkkcollp_ir-nrzas.
        sum_fkkcollp_ir-gpart   = t_fkkcollp_ir-gpart.
        sum_fkkcollp_ir-waers   = t_fkkcollp_ir-waers.
        sum_fkkcollp_ir-txtvw   = t_fkkcollp_ir-txtvw.
        PERFORM addition
          USING
            t_fkkcollp_ir-betrw
          CHANGING
            sum_fkkcollp_ir-betrw.
        PERFORM addition
          USING
            t_fkkcollp_ir-betrw
          CHANGING
            h_summe.

* Registrieren Rüchrufmeldung
        IF p_p_i_basics-status-xsimu IS INITIAL.
          PERFORM write_log_record_recall
             USING
                t_fkkcollp_ir_w-lfdnr
                t_fkkcollp_ir
                p_p_i_basics.
        ENDIF.

        MOVE-CORRESPONDING h_key_gpart TO h_key_gpart_old.

      ENDSELECT.

* Ausagbe letzte Info
      IF NOT h_knz IS INITIAL.

* ------- calls user exit 5052 / recall (sum) -------------------------*
        PERFORM call_zp_fb_5052_recall
           USING
              p_p_t_fkkcollh_i
              0
           CHANGING
              sum_fkkcollp_ir.

* Ausgabe Rückrufinformation auf Informationsdatei
        ADD 1 TO h_anzrc.
        IF p_p_i_basics-status-xsimu IS INITIAL.
          TRANSFER sum_fkkcollp_ir TO p_p_h_file_name.
        ENDIF.
        h_knz = 'X'.

* Aktualisieren Datei-Endesatz
        ADD 1 TO p_p_t_fkkcollt_i-recnum.
        PERFORM addition
          USING
            sum_fkkcollp_ir-betrw
          CHANGING
            p_p_t_fkkcollt_i-sumrc.
      ENDIF.

    WHEN c_sum_nrzas.
* ------- Summierung auf Basis Zahlschein-Nummer ---------------------*

* Lesen Rückruf-Informationen aus Zwischenspeicher
      SELECT * INTO  CORRESPONDING FIELDS OF t_fkkcollp_ir_w
               FROM  dfkkcollp_ir_w
               WHERE laufd   EQ p_p_i_basics-runkey-laufd
               AND   laufi   EQ p_p_i_basics-runkey-laufi
               AND   w_inkgp EQ p_p_t_fkkcollh_i_w-w_inkgp
               AND   satztyp EQ c_position
               AND   postyp  EQ c_recall
               ORDER BY nrzas gpart opbel inkps.

        MOVE-CORRESPONDING t_fkkcollp_ir_w TO t_fkkcollp_ir.
        MOVE-CORRESPONDING t_fkkcollp_ir TO h_key_nrzas.

        IF h_key_nrzas_old NE h_key_nrzas.
* Gruppenwechsel
          IF NOT h_knz IS INITIAL.

* ------- calls user exit 5052 / recall (sum) -------------------------*
            PERFORM call_zp_fb_5052_recall
               USING
                  p_p_t_fkkcollh_i
                  0
               CHANGING
                  sum_fkkcollp_ir.

* Ausgabe Rückrufinformation auf Informationsdatei
            ADD 1 TO h_anzrc.
            IF p_p_i_basics-status-xsimu IS INITIAL.
              TRANSFER sum_fkkcollp_ir TO p_p_h_file_name.
            ENDIF.

* Aktualisieren Datei-Endesatz
            ADD 1 TO p_p_t_fkkcollt_i-recnum..
            PERFORM addition
              USING
                sum_fkkcollp_ir-betrw
              CHANGING
                p_p_t_fkkcollt_i-sumrc.
          ENDIF.
          CLEAR sum_fkkcollp_ir.
        ENDIF.
        h_knz = 'X'.

* Aufbau Summensatz
        sum_fkkcollp_ir-postyp  = t_fkkcollp_ir-postyp.
        sum_fkkcollp_ir-satztyp = t_fkkcollp_ir-satztyp.
        sum_fkkcollp_ir-nrzas   = t_fkkcollp_ir-nrzas.
        sum_fkkcollp_ir-gpart   = t_fkkcollp_ir-gpart.
        sum_fkkcollp_ir-waers   = t_fkkcollp_ir-waers.
        sum_fkkcollp_ir-txtvw   = t_fkkcollp_ir-txtvw.
        PERFORM addition
          USING
            t_fkkcollp_ir-betrw
          CHANGING
            sum_fkkcollp_ir-betrw.
        PERFORM addition
          USING
            t_fkkcollp_ir-betrw
          CHANGING
            h_summe.

* Registrieren Rüchrufmeldung
        IF p_p_i_basics-status-xsimu IS INITIAL.
          PERFORM write_log_record_recall
             USING
                t_fkkcollp_ir_w-lfdnr
                t_fkkcollp_ir
                p_p_i_basics.
        ENDIF.

        MOVE-CORRESPONDING h_key_nrzas TO h_key_nrzas_old.

      ENDSELECT.

      IF NOT h_knz IS INITIAL.
* ------- calls user exit 5052 / recall (sum) -------------------------*
        PERFORM call_zp_fb_5052_recall
           USING
              p_p_t_fkkcollh_i
              0
           CHANGING
              sum_fkkcollp_ir.

* Ausgabe Rückrufinformation auf Informationsdatei
        ADD 1 TO h_anzrc.
        IF p_p_i_basics-status-xsimu IS INITIAL.
          TRANSFER sum_fkkcollp_ir TO p_p_h_file_name.
        ENDIF.
        h_knz = 'X'.

* Aktualisieren Datei-Endesatz
        ADD 1 TO p_p_t_fkkcollt_i-recnum.
        PERFORM addition
          USING
            sum_fkkcollp_ir-betrw
          CHANGING
            p_p_t_fkkcollt_i-sumrc.
      ENDIF.

    WHEN c_sum_vkont.
* ------- Summierung über Vertragskonto-Nummer ---------------------*

* Lesen Rückruf-Informationen aus Zwischenspeicher
      SELECT * INTO  CORRESPONDING FIELDS OF t_fkkcollp_ir_w
               FROM  dfkkcollp_ir_w
               WHERE laufd   EQ p_p_i_basics-runkey-laufd
               AND   laufi   EQ p_p_i_basics-runkey-laufi
               AND   w_inkgp EQ p_p_t_fkkcollh_i_w-w_inkgp
               AND   satztyp EQ c_position
               AND   postyp  EQ c_recall
               ORDER BY vkont nrzas opbel inkps.

        MOVE-CORRESPONDING t_fkkcollp_ir_w TO t_fkkcollp_ir.
        MOVE-CORRESPONDING t_fkkcollp_ir TO h_key_vkont.

        IF h_key_vkont_old NE h_key_vkont.
* Gruppenwechsel
          IF NOT h_knz IS INITIAL.

* ------- calls user exit 5052 / recall (sum) -------------------------*
            PERFORM call_zp_fb_5052_recall
               USING
                  p_p_t_fkkcollh_i
                  0
               CHANGING
                  sum_fkkcollp_ir.

* Ausgabe Rückruf auf Informationsdatei
            ADD 1 TO h_anzrc.
            IF p_p_i_basics-status-xsimu IS INITIAL.
              TRANSFER sum_fkkcollp_ir TO p_p_h_file_name.
            ENDIF.

* Aktualisieren Datei-Endesatz
            ADD 1 TO p_p_t_fkkcollt_i-recnum.
            PERFORM addition
              USING
                sum_fkkcollp_ir-betrw
              CHANGING
                p_p_t_fkkcollt_i-sumrc.
          ENDIF.
          CLEAR sum_fkkcollp_ir.
        ENDIF.
        h_knz = 'X'.

* Aufbau Summensatz
        sum_fkkcollp_ir-postyp  = t_fkkcollp_ir-postyp.
        sum_fkkcollp_ir-satztyp = t_fkkcollp_ir-satztyp.
        sum_fkkcollp_ir-nrzas   = t_fkkcollp_ir-nrzas.
        sum_fkkcollp_ir-gpart   = t_fkkcollp_ir-gpart.
        sum_fkkcollp_ir-vkont   = t_fkkcollp_ir-vkont.
        sum_fkkcollp_ir-waers   = t_fkkcollp_ir-waers.
        sum_fkkcollp_ir-txtvw   = t_fkkcollp_ir-txtvw.
        PERFORM addition
          USING
            t_fkkcollp_ir-betrw
          CHANGING
            sum_fkkcollp_ir-betrw.
        PERFORM addition
          USING
            t_fkkcollp_ir-betrw
          CHANGING
            h_summe.

* Registrieren Rüchrufmeldung
        IF p_p_i_basics-status-xsimu IS INITIAL.
          PERFORM write_log_record_recall
             USING
                t_fkkcollp_ir_w-lfdnr
                t_fkkcollp_ir
                p_p_i_basics.
        ENDIF.

        MOVE-CORRESPONDING h_key_vkont TO h_key_vkont_old.

      ENDSELECT.

* Ausagbe letzte Info
      IF NOT h_knz IS INITIAL.

* ------- calls user exit 5052 / recall (sum) -------------------------*
        PERFORM call_zp_fb_5052_recall
           USING
              p_p_t_fkkcollh_i
              0
           CHANGING
              sum_fkkcollp_ir.

* Ausgabe Rückrufinformation auf Informationsdatei
        ADD 1 TO h_anzrc.
        IF p_p_i_basics-status-xsimu IS INITIAL.
          TRANSFER sum_fkkcollp_ir TO p_p_h_file_name.
        ENDIF.
        h_knz = 'X'.

* Aktualisieren Datei-Endesatz
        ADD 1 TO p_p_t_fkkcollt_i-recnum.
        PERFORM addition
          USING
            sum_fkkcollp_ir-betrw
          CHANGING
            p_p_t_fkkcollt_i-sumrc.
      ENDIF.

  ENDCASE.

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
       c_msgprio_info p_p_i_basics-appllog-probclass.
    SET EXTENDED CHECK OFF.
    IF 1 = 2. MESSAGE i801(>4). ENDIF.
    SET EXTENDED CHECK ON.
  ENDIF.

ENDFORM.                    " create_info_recall
*&---------------------------------------------------------------------*
*&      Form  CREATE_INFO_MASTER_DATA_CHANGE
*&---------------------------------------------------------------------*
FORM create_info_master_data_change
                             USING
                                p_p_fkkcollinfo TYPE fkkcollinfo
                                p_p_h_file_name
                                p_p_t_fkkcollh_i_w LIKE dfkkcollh_i_w
                                p_p_t_fkkcollh_i LIKE fkkcollh_i
                                p_p_i_basics TYPE fkk_mad_basics
                             CHANGING
                                p_p_t_fkkcollt_i LIKE fkkcollt_i.

  DATA:
    t_fkkcollp_im   LIKE fkkcollp_im,
    t_fkkcollp_im_w LIKE dfkkcollp_im_w,
    h_anzgp         LIKE sy-tabix,
    h_gpanz(16),
    h_lfdnr         LIKE dfkkcoli_log-lfdnr,
    h_inkps         LIKE dfkkcoli_log-inkps.

  CLEAR:
    t_fkkcollp_im,
    t_fkkcollp_im_w,
    h_anzgp.

  SELECT * INTO  t_fkkcollp_im_w
           FROM  dfkkcollp_im_w
           WHERE laufd   EQ p_p_i_basics-runkey-laufd
           AND   laufi   EQ p_p_i_basics-runkey-laufi
           AND   w_inkgp EQ p_p_t_fkkcollh_i_w-w_inkgp
           AND   satztyp EQ c_position
           AND   postyp  EQ c_master_data_changes
           ORDER BY gpart.

    MOVE-CORRESPONDING  t_fkkcollp_im_w TO t_fkkcollp_im.

* Berechnen lfd. Nummer
    PERFORM get_lfdnr_master_data_change
                USING
                   t_fkkcollp_im-gpart
                CHANGING
                   h_lfdnr
                   h_inkps.

* ------- calls user exit 5052 / BP-Master data changes ---------------*
*    perform call_zp_fb_5052_gpart
*       using
*          p_p_t_fkkcollh_i
*       changing
*          t_fkkcollp_im.

* Scheiben Datei-Position
    IF p_p_i_basics-status-xsimu IS INITIAL.
      TRANSFER t_fkkcollp_im TO p_p_h_file_name.

* Meldung registrieren
      PERFORM write_log_record_gpart
         USING
            h_lfdnr
            h_inkps
            t_fkkcollp_im
            t_fkkcollp_im_w
            p_p_i_basics.
    ENDIF.

* Aktualisieren Zatzähler
    ADD 1 TO p_p_t_fkkcollt_i-recnum.
    ADD 1 TO h_anzgp.

  ENDSELECT.

* Protokoll
* Nachricht: Datei enthält Informationen zu & Stammdatenänderungen
  WRITE h_anzgp TO h_gpanz LEFT-JUSTIFIED.
  IF NOT h_anzgp IS INITIAL.
    mac_appl_log_msg 'I' '>4' '807'
       h_gpanz space space space
       c_msgprio_info p_p_i_basics-appllog-probclass.
    SET EXTENDED CHECK OFF.
    IF 1 = 2. MESSAGE i807(>4). ENDIF.
    SET EXTENDED CHECK ON.
  ENDIF.

ENDFORM.                    " CREATE_INFO_MASTER_DATA_CHANGE
*&---------------------------------------------------------------------*
*&      Form  get_lfdnr_master_data_change
*&---------------------------------------------------------------------*
FORM get_lfdnr_master_data_change
  USING
        p_gpart   TYPE gpart_kk
  CHANGING
        p_lfdnr   TYPE lfdnr_kk
        p_inkps   TYPE inkps_kk.

  STATICS h_lfdnr        TYPE lfdnr_kk.
  STATICS h_gpart_old    TYPE gpart_kk.

* Berechnen lfd. Nummer
  IF p_gpart NE h_gpart_old OR
     h_lfdnr EQ '999'.

    SELECT MAX( inkps ) INTO p_inkps
           FROM  dfkkcoli_log
           WHERE nrzas  EQ space
           AND   opbel  EQ space
           AND   gpart  EQ p_gpart.
    IF NOT sy-subrc IS INITIAL.
      CLEAR p_inkps.
    ENDIF.

    SELECT MAX( lfdnr ) INTO h_lfdnr
           FROM  dfkkcoli_log
           WHERE nrzas  EQ space
           AND   opbel  EQ space
           AND   inkps  EQ p_inkps
           AND   gpart  EQ p_gpart.
    IF NOT sy-subrc IS INITIAL.
      CLEAR h_lfdnr.
    ELSE.
      IF h_lfdnr EQ '999'.
        ADD 1 TO h_lfdnr.
        ADD 1 TO p_inkps.
      ENDIF.
    ENDIF.
  ENDIF.

  ADD 1 TO h_lfdnr.
  p_lfdnr = h_lfdnr.

  h_gpart_old = p_gpart.

ENDFORM.                    "get_lfdnr_master_data_change
*&---------------------------------------------------------------------*
*&      Form  call_zp_fb_5051
*&---------------------------------------------------------------------*
*       Exit 5051 Ergänzen Dateikopf
*----------------------------------------------------------------------*
FORM call_zp_fb_5051 USING    p_p_t_fkkcollh_i_w LIKE dfkkcollh_i_w
                     CHANGING p_p_t_fkkcollh_i LIKE fkkcollh_i.

  DATA:  lt_fkkcollh_i  LIKE fkkcollh_i.

  CLEAR: lt_fkkcollh_i.

  MOVE-CORRESPONDING p_p_t_fkkcollh_i_w  TO lt_fkkcollh_i.
  LOOP AT t_tfkfbc_5051.
    CALL FUNCTION t_tfkfbc_5051-funcc
      EXPORTING
        i_fkkcollh_i = lt_fkkcollh_i
      CHANGING
        c_fkkcollh_i = lt_fkkcollh_i.
  ENDLOOP.
  MOVE-CORRESPONDING lt_fkkcollh_i TO p_p_t_fkkcollh_i.

  SET EXTENDED CHECK OFF.
  IF 1 = 2. CALL FUNCTION 'FKK_SAMPLE_5051'. ENDIF.
  SET EXTENDED CHECK ON.

ENDFORM.                    " call_zp_fb_5051
*&---------------------------------------------------------------------*
*&      Form  call_zp_fb_5052_payment
*&---------------------------------------------------------------------*
*       Exit 5052 Ergänzen Positionsdaten - Zahlungen, Storno, Ausgleich
*----------------------------------------------------------------------*
*      -->P_P_POSTYP          Positionstyp { 1 / 4 / 5 }
*      -->P_P_P_T_FKKCOLLH_I  Kopfsatz
*      <--P_T_FKKCOLLP_IP     Positionsatz Ausgleich
*----------------------------------------------------------------------*
FORM call_zp_fb_5052_payment USING p_p_postyp TYPE postyp_kk
                                   p_p_t_fkkcollh_i LIKE fkkcollh_i
                                   p_lfdnr TYPE lfdnr_kk
                          CHANGING p_t_fkkcollp_ip LIKE fkkcollp_ip.

  DATA:  lt_fkkcollp_ip  LIKE fkkcollp_ip.

  CLEAR: lt_fkkcollp_ip.

  MOVE-CORRESPONDING p_t_fkkcollp_ip TO lt_fkkcollp_ip.

  LOOP AT t_tfkfbc_5052.
    CALL FUNCTION t_tfkfbc_5052-funcc
      EXPORTING
        i_postyp      = p_p_postyp
        i_fkkcollh_i  = p_p_t_fkkcollh_i
        i_lfdnr       = p_lfdnr
      CHANGING
        c_fkkcollp_ip = lt_fkkcollp_ip.
  ENDLOOP.

  MOVE-CORRESPONDING lt_fkkcollp_ip TO p_t_fkkcollp_ip.

  SET EXTENDED CHECK OFF.
  IF 1 = 2. CALL FUNCTION 'FKK_SAMPLE_5052'. ENDIF.
  SET EXTENDED CHECK ON.

ENDFORM.                    " call_zp_fb_5052_payment
*&---------------------------------------------------------------------*
*&      Form  write_log_record_payment
*&---------------------------------------------------------------------*
FORM write_log_record_payment USING  p_h_lfdnr TYPE lfdnr_kk
                                     p_t_fkkcollp_ip LIKE fkkcollp_ip
                                     p_p_p_i_basics TYPE fkk_mad_basics.

  DATA:
    t_fkkcoli_log LIKE dfkkcoli_log,
    h_lfdnr       LIKE dfkkcoli_log-lfdnr.

  CLEAR:
    t_fkkcoli_log,
    h_lfdnr.

  t_fkkcoli_log-nrzas  = p_t_fkkcollp_ip-nrzas.
  t_fkkcoli_log-opbel  = p_t_fkkcollp_ip-opbel.
  t_fkkcoli_log-inkps  = p_t_fkkcollp_ip-inkps.
  t_fkkcoli_log-gpart  = p_t_fkkcollp_ip-gpart.
  t_fkkcoli_log-lfdnr  = p_h_lfdnr.
  t_fkkcoli_log-postyp = p_t_fkkcollp_ip-postyp.
  t_fkkcoli_log-vkont  = p_t_fkkcollp_ip-vkont.
  t_fkkcoli_log-betrw  = p_t_fkkcollp_ip-betrw.
  t_fkkcoli_log-bwtrt  = p_t_fkkcollp_ip-bwtrt.
  t_fkkcoli_log-waers  = p_t_fkkcollp_ip-waers.
  t_fkkcoli_log-augdt  = p_t_fkkcollp_ip-augdt.
  t_fkkcoli_log-txtvw  = p_t_fkkcollp_ip-txtvw.
  t_fkkcoli_log-ernam  = sy-uname.
  t_fkkcoli_log-erdat  = sy-datum.
  t_fkkcoli_log-erzeit = sy-uzeit.
  t_fkkcoli_log-laufd  = p_p_p_i_basics-runkey-laufd.
  t_fkkcoli_log-laufi  = p_p_p_i_basics-runkey-laufi.

* INSERT: Scheiben Protokollsatz
*>>>>> HANA
  DATA: lo_opt       TYPE REF TO if_fkk_optimization_settings,
        x_optimizing TYPE        xfeld.
  lo_opt = cl_fkk_optimization_settings=>get_instance( ).
  x_optimizing = lo_opt->is_active( cl_fkk_optimization_settings=>cc_fica_fpci_mass_insert ).
  IF x_optimizing = abap_true.
    APPEND t_fkkcoli_log TO gt_fkkcoli_log.
    gv_coli_log_cnt = gv_coli_log_cnt + 1.

    "note 2675747: prevent that table gets too big and memory runs out
    IF gv_coli_log_cnt GE 100000.
      INSERT dfkkcoli_log FROM TABLE gt_fkkcoli_log.
      CLEAR: gt_fkkcoli_log[],gt_fkkcoli_log, gv_coli_log_cnt.
    ENDIF.
  ELSE.
    INSERT INTO dfkkcoli_log VALUES t_fkkcoli_log.  "OLD LOGIC
  ENDIF.
*<<<<< HANA

ENDFORM.                    " write_log_record_payment
*&---------------------------------------------------------------------*
*&      Form  call_zp_fb_5052_recall
*&---------------------------------------------------------------------*
*       Exit 5052 Ergänzen Positionsdaten - Rückruf
*----------------------------------------------------------------------*
FORM call_zp_fb_5052_recall  USING p_p_t_fkkcollh_i LIKE fkkcollh_i
                                   p_lfdnr TYPE lfdnr_kk
                          CHANGING p_t_fkkcollp_ir LIKE fkkcollp_ir.

  DATA:  lt_fkkcollp_ir LIKE fkkcollp_ir.

  CLEAR: lt_fkkcollp_ir.

  MOVE-CORRESPONDING p_t_fkkcollp_ir  TO lt_fkkcollp_ir.

  LOOP AT t_tfkfbc_5052.
    CALL FUNCTION t_tfkfbc_5052-funcc
      EXPORTING
        i_postyp      = c_recall
        i_fkkcollh_i  = p_p_t_fkkcollh_i
        i_lfdnr       = p_lfdnr
      CHANGING
        c_fkkcollp_ir = lt_fkkcollp_ir.
  ENDLOOP.

  MOVE-CORRESPONDING lt_fkkcollp_ir TO p_t_fkkcollp_ir.

  SET EXTENDED CHECK OFF.
  IF 1 = 2. CALL FUNCTION 'FKK_SAMPLE_5052'. ENDIF.
  SET EXTENDED CHECK ON.

ENDFORM.                    " call_zp_fb_5052_recall
*&---------------------------------------------------------------------*
*&      Form  write_log_record_recall
*&---------------------------------------------------------------------*
FORM write_log_record_recall USING   p_h_lfdn
                                     p_t_fkkcollp_ir LIKE fkkcollp_ir
                                     p_p_p_i_basics TYPE fkk_mad_basics.

  DATA:
    t_fkkcoli_log LIKE dfkkcoli_log.

  CLEAR:
    t_fkkcoli_log.

  t_fkkcoli_log-nrzas  = p_t_fkkcollp_ir-nrzas.
  t_fkkcoli_log-opbel  = p_t_fkkcollp_ir-opbel.
  t_fkkcoli_log-inkps  = p_t_fkkcollp_ir-inkps.
  t_fkkcoli_log-gpart  = p_t_fkkcollp_ir-gpart.
  t_fkkcoli_log-lfdnr  = p_h_lfdn.
  t_fkkcoli_log-postyp = p_t_fkkcollp_ir-postyp.
  t_fkkcoli_log-vkont  = p_t_fkkcollp_ir-vkont.
  t_fkkcoli_log-betrw  = p_t_fkkcollp_ir-betrw.
  t_fkkcoli_log-waers  = p_t_fkkcollp_ir-waers.
  t_fkkcoli_log-txtvw  = p_t_fkkcollp_ir-txtvw.
  t_fkkcoli_log-rudat  = p_t_fkkcollp_ir-rudat.
  t_fkkcoli_log-ernam  = sy-uname.
  t_fkkcoli_log-erdat  = sy-datum.
  t_fkkcoli_log-erzeit = sy-uzeit.
  t_fkkcoli_log-laufd  = p_p_p_i_basics-runkey-laufd.
  t_fkkcoli_log-laufi  = p_p_p_i_basics-runkey-laufi.

* INSERT: Scheiben Protokollsatz
*>>>>> HANA
  DATA: lo_opt       TYPE REF TO if_fkk_optimization_settings,
        x_optimizing TYPE        xfeld.
  lo_opt = cl_fkk_optimization_settings=>get_instance( ).
  x_optimizing = lo_opt->is_active( cl_fkk_optimization_settings=>cc_fica_fpci_mass_insert ).
  IF x_optimizing = abap_true.
    APPEND t_fkkcoli_log TO gt_fkkcoli_log.
    gv_coli_log_cnt = gv_coli_log_cnt + 1.

    "note 2675747: prevent that table gets too big and memory runs out
    IF gv_coli_log_cnt GE 100000.
      INSERT dfkkcoli_log FROM TABLE gt_fkkcoli_log.
      CLEAR: gt_fkkcoli_log[], gt_fkkcoli_log, gv_coli_log_cnt.
    ENDIF.
  ELSE.
* INSERT: Scheiben Protokollsatz
    INSERT INTO dfkkcoli_log VALUES t_fkkcoli_log.  "OLD LOGIC
  ENDIF.
*<<<<< HANA

ENDFORM.                    " write_log_record_recall
*&---------------------------------------------------------------------*
*&      Form  call_zp_fb_5052_gpart
*&---------------------------------------------------------------------*
*       Exit 5052 Ergänzen Positionsdaten - Partneränderungen
*----------------------------------------------------------------------*
FORM call_zp_fb_5052_gpart USING  p_p_t_fkkcollh_i LIKE fkkcollh_i
                        CHANGING  p_t_fkkcollp_im LIKE fkkcollp_im.

  DATA:  lt_fkkcollp_im  LIKE fkkcollp_im.

  CLEAR: lt_fkkcollp_im.

  MOVE-CORRESPONDING p_t_fkkcollp_im  TO lt_fkkcollp_im.

  LOOP AT t_tfkfbc_5052.
    CALL FUNCTION t_tfkfbc_5052-funcc
      EXPORTING
        i_postyp      = c_master_data_changes
        i_fkkcollh_i  = p_p_t_fkkcollh_i
      CHANGING
        c_fkkcollp_im = lt_fkkcollp_im.
  ENDLOOP.

  MOVE-CORRESPONDING lt_fkkcollp_im TO p_t_fkkcollp_im.

  SET EXTENDED CHECK OFF.
  IF 1 = 2. CALL FUNCTION 'FKK_SAMPLE_5052'. ENDIF.
  SET EXTENDED CHECK ON.

ENDFORM.                    " call_zp_fb_5052_gpart
*&---------------------------------------------------------------------*
*&      Form  write_log_record_gpart
*&---------------------------------------------------------------------*
FORM write_log_record_gpart USING p_h_lfdnr TYPE lfdnr_kk
                                  p_h_inkps TYPE inkps_kk
                                  p_t_fkkcollp_im LIKE fkkcollp_im
                                  p_t_fkkcollp_im_w LIKE dfkkcollp_im_w
                                  p_p_p_i_basics TYPE fkk_mad_basics.

  DATA:  t_fkkcoli_log LIKE dfkkcoli_log.

  CLEAR: t_fkkcoli_log.

  t_fkkcoli_log-gpart      = p_t_fkkcollp_im-gpart.
  t_fkkcoli_log-lfdnr      = p_h_lfdnr.
  t_fkkcoli_log-inkps      = p_h_inkps.
  t_fkkcoli_log-postyp     = p_t_fkkcollp_im-postyp.
  t_fkkcoli_log-vkont      = p_t_fkkcollp_im-vkont.
  t_fkkcoli_log-txtvw      = p_t_fkkcollp_im-ddtext.
  t_fkkcoli_log-udate      = p_t_fkkcollp_im-udate.
  t_fkkcoli_log-utime      = p_t_fkkcollp_im-utime.         "260402ins
  t_fkkcoli_log-tabname    = p_t_fkkcollp_im_w-tabname.
  t_fkkcoli_log-tabkey     = p_t_fkkcollp_im_w-tabkey.
  t_fkkcoli_log-fname      = p_t_fkkcollp_im_w-fname.
  t_fkkcoli_log-value_new  = p_t_fkkcollp_im-value_new.
  t_fkkcoli_log-value_old  = p_t_fkkcollp_im-value_old.
  t_fkkcoli_log-ernam      = sy-uname.
  t_fkkcoli_log-erdat      = sy-datum.
  t_fkkcoli_log-erzeit     = sy-uzeit.
  t_fkkcoli_log-laufd      = p_p_p_i_basics-runkey-laufd.
  t_fkkcoli_log-laufi      = p_p_p_i_basics-runkey-laufi.

* INSERT: Scheiben Protokollsatz
  INSERT INTO dfkkcoli_log VALUES t_fkkcoli_log.

ENDFORM.                    " write_log_record_gpart
*&---------------------------------------------------------------------*
*&      Form  call_zp_fb_5053_gpart
*&---------------------------------------------------------------------*
*       Exit 5052 Ergänzen Datei-Endesatz
*----------------------------------------------------------------------*
FORM call_zp_fb_5053 USING    p_p_t_fkkcollh_i LIKE fkkcollh_i
                     CHANGING p_p_t_fkkcollt_i LIKE fkkcollt_i.

  DATA:  lt_fkkcollt_i LIKE fkkcollt_i.

  CLEAR: lt_fkkcollt_i.

  MOVE-CORRESPONDING p_p_t_fkkcollt_i TO lt_fkkcollt_i.

  LOOP AT t_tfkfbc_5053.
    CALL FUNCTION t_tfkfbc_5053-funcc
      EXPORTING
        i_fkkcollh_i = p_p_t_fkkcollh_i
      CHANGING
        c_fkkcollt_i = lt_fkkcollt_i.
  ENDLOOP.

  MOVE-CORRESPONDING lt_fkkcollt_i TO p_p_t_fkkcollt_i.

  SET EXTENDED CHECK OFF.
  IF 1 = 2. CALL FUNCTION 'FKK_SAMPLE_5053'. ENDIF.
  SET EXTENDED CHECK ON.

ENDFORM.                    " call_zp_fb_5053_gpart
*&---------------------------------------------------------------------*
*&      Form  addition
*&---------------------------------------------------------------------*
FORM addition USING    p_wert
              CHANGING p_summe.

  DATA:
    w_summe   LIKE fkkcollt-sumza,
    w_summe_p TYPE betrw8_kk,
    w_wert    TYPE abetrw_b_kk,
    w_wert_p  TYPE betrw8_kk.

  CASE g_dcpfm.

    WHEN space OR 'Y'.
* decimal_notation 'N.NNN,NN' or 'N NNN,NN'
      CLEAR: w_wert, w_wert_p.
      w_wert  = p_wert.
      TRANSLATE w_wert USING '. '.
      CONDENSE  w_wert NO-GAPS.
      TRANSLATE w_wert USING ',.'.
      w_wert_p = w_wert.

      CLEAR: w_summe, w_summe_p.
      w_summe = p_summe.
      TRANSLATE w_summe USING '. '.
      CONDENSE  w_summe NO-GAPS.
      TRANSLATE w_summe USING ',.'.
      w_summe_p = w_summe.

      ADD w_wert_p TO w_summe_p.
      WRITE w_summe_p TO p_summe.                           "#EC *

    WHEN 'X'.
* decimal_notation 'N,NNN.NN'
      CLEAR: w_wert, w_wert_p.
      w_wert  = p_wert.
      TRANSLATE w_wert USING ', '.
      CONDENSE  w_wert NO-GAPS.
      w_wert_p = w_wert.

      CLEAR: w_summe, w_summe_p.
      w_summe = p_summe.
      TRANSLATE w_summe USING ', '.
      CONDENSE  w_summe NO-GAPS.
      w_summe_p = w_summe.

      ADD w_wert_p TO w_summe_p.
      WRITE w_summe_p TO p_summe.                           "#EC *

  ENDCASE.

ENDFORM.                    " addition
*&---------------------------------------------------------------------*
*&      Form  close_dataset
*&---------------------------------------------------------------------*
FORM close_dataset USING    p_h_file_name
                            p_t_fkkcollt_i LIKE fkkcollt_i
                            p_i_basics TYPE fkk_mad_basics.
  DATA:
    w_recnum  LIKE fkkcollt_i-recnum,
    w_anz(10).

  CLEAR w_recnum.
  CLEAR w_anz.

  IF NOT p_t_fkkcollt_i-recnum IS INITIAL.
    w_recnum = p_t_fkkcollt_i-recnum.
  ENDIF.

* Nachricht: Anzahl Datensätzen: &
  WRITE w_recnum TO w_anz NO-ZERO.
  SHIFT w_anz LEFT DELETING LEADING space.
  mac_appl_log_msg 'I' '>4' '805'
      w_anz space space space
      c_msgprio_low p_i_basics-appllog-probclass.
  SET EXTENDED CHECK OFF.
  IF 1 = 2. MESSAGE i805(>4). ENDIF.
  SET EXTENDED CHECK ON.

* Abschliessen Informationsdatei
  IF p_i_basics-status-xsimu IS INITIAL.
    CLOSE DATASET p_h_file_name.
  ENDIF.

ENDFORM.                    " close_dataset
*&---------------------------------------------------------------------*
*&      Form  delete_old_data
*&---------------------------------------------------------------------*
*       Löschen Tabeleninhalt des Arbeitsspeichers
*----------------------------------------------------------------------*
FORM delete_old_data USING p_i_basics TYPE fkk_mad_basics.

* Löschen Kopfinformationen
  DELETE FROM dfkkcollh_i_w  WHERE laufi EQ p_i_basics-runkey-laufi
                             AND   laufd EQ p_i_basics-runkey-laufd.

* Löschen Zahlungsinformationen
  DELETE FROM dfkkcollp_ip_w WHERE laufi EQ p_i_basics-runkey-laufi
                             AND   laufd EQ p_i_basics-runkey-laufd.

* Löschen Rückrufinformationen
  DELETE FROM dfkkcollp_ir_w WHERE laufi EQ p_i_basics-runkey-laufi
                             AND   laufd EQ p_i_basics-runkey-laufd.

* Löschen Partnerstammdaten-Informationen
  DELETE FROM dfkkcollp_im_w WHERE laufi EQ p_i_basics-runkey-laufi
                             AND   laufd EQ p_i_basics-runkey-laufd.

ENDFORM.                    " delete_old_data
*&---------------------------------------------------------------------*
*&      Form  art_summierung
*&---------------------------------------------------------------------*
FORM art_summierung USING    p_i_basics TYPE fkk_mad_basics
                             p_fkkcollinfo TYPE fkkcollinfo.

  DATA:
    t_dd07v_knz LIKE dd07v OCCURS 0 WITH HEADER LINE,
    w_anz       LIKE sy-tfill.

  IF  NOT p_fkkcollinfo-xausg IS INITIAL
   OR NOT p_fkkcollinfo-xback IS INITIAL.

* Ausgabe Nachricht, falls Daten existieren
    CLEAR w_anz.
    SELECT COUNT( * ) INTO  w_anz
                      FROM  dfkkcollh_i_w
                      WHERE laufd EQ p_i_basics-runkey-laufd
                      AND   laufi EQ p_i_basics-runkey-laufi.
    CHECK NOT w_anz IS INITIAL.
* Lesen Bezeichnung der Art Summierung
    CALL FUNCTION 'DDIF_DOMA_GET'
      EXPORTING
        name          = 'SUMKNZ_KK'
        state         = 'A'
        langu         = sy-langu
      TABLES
        dd07v_tab     = t_dd07v_knz
      EXCEPTIONS
        illegal_input = 1
        OTHERS        = 2.
    IF sy-subrc IS INITIAL.
      READ TABLE t_dd07v_knz WITH KEY domvalue_l = p_fkkcollinfo-sumknz.
      IF sy-subrc IS INITIAL.
* Nachricht: Art der Summierung: ........
        mac_appl_log_msg 'I' '>4' '808'
            t_dd07v_knz-ddtext space space space
            c_msgprio_low p_i_basics-appllog-probclass.
        SET EXTENDED CHECK OFF.
        IF 1 = 2. MESSAGE i808(>4). ENDIF.
        SET EXTENDED CHECK ON.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " art_summierung
*&---------------------------------------------------------------------*
*&      Form  info_storno
*&---------------------------------------------------------------------*
*       Information über stornierte Beträge
*----------------------------------------------------------------------*
FORM info_storno
     USING
        p_postyp TYPE postyp_kk
        p_i_basics TYPE fkk_mad_basics
        p_h_intnr_c TYPE intnr_i_kk
        p_t_fkkcollh LIKE dfkkcollh
        p_h_lfd_p TYPE lfnum_kk
        p_h_betrag TYPE betrz_kk
        p_logkz TYPE logkz_kk.

  DATA:
    l_fkkcollp_ip_w LIKE dfkkcollp_ip_w,
    h_herkf         TYPE herkf_kk,
    h_storb         TYPE storb_kk,
    h_xragl         TYPE xragl_kk,
    h_augbl         TYPE augbl_kk,
    h_htext         TYPE text20,
    h_logkz         TYPE logkz_kk,
    h_augrd         TYPE augrd_kk.

  DATA ls_fkkcollp_ip     LIKE fkkcollp_ip.

  DATA lv_txtvw           TYPE txtag_i_kk.
  DATA lv_betrw_content   TYPE betrw_kk.

  DATA ls_collitem        TYPE fkkcollitem.
  DATA ls_collpaym        TYPE fkkcollpaym.
  DATA ls_collpaymlink    TYPE fkkcollpaymlink.
  DATA ls_collections     TYPE fkkcollections.
  DATA ls_coli_log        TYPE fkkcoli_log.
  DATA ls_coli_log_ext    TYPE gty_fkkcoli_log_ext.
  DATA ls_postyp_sum      TYPE fkkcol_postyp_sum.
  DATA ls_collitem1       TYPE fkkcollitem.
  DATA lv_collitem_lv     TYPE collitem_lv_kk.
  DATA ls_collitem_info   TYPE fkkcollitem.
  DATA lv_collitem_id     TYPE collitem_id_kk.
  DATA: ls_collpaym_logkz TYPE gty_fkkcollpaym_logkz,
        ls_collitem_logkz TYPE gty_fkkcollitem_logkz.

  DATA lv_betrz_st      TYPE betrz_st_kk.
  DATA lx_flg_payment_info  TYPE xfeld.

  FIELD-SYMBOLS <fs_collections>  TYPE fkkcollections.
  FIELD-SYMBOLS <fs_coli_log_ext>  TYPE gty_fkkcoli_log_ext.


  CLEAR: l_fkkcollp_ip_w.
  CLEAR: h_herkf.
  CLEAR: h_htext.

  CLEAR: h_storb, h_xragl, h_augbl.

*>>> Note 1539682
* check which DFKKCOLLH line has been reversed
  DATA: h_stbel TYPE stbel_kk,
        h_agsta TYPE agsta_kk.
  IF NOT p_t_fkkcollh-storb IS INITIAL.
    SELECT SINGLE stbel INTO  h_stbel
                        FROM  dfkkko
                        WHERE opbel EQ p_t_fkkcollh-storb.
    IF NOT h_stbel IS INITIAL.
      SELECT SINGLE agsta FROM dfkkcollh INTO h_agsta
                        WHERE opbel = p_t_fkkcollh-opbel
                          AND inkps = p_t_fkkcollh-inkps
                          AND augbl = h_stbel.
      IF sy-subrc EQ 0 AND
       ( h_agsta EQ c_receivable_part_paid OR
         h_agsta EQ c_receivable_paid ).
        EXIT.
      ENDIF.
    ENDIF.
  ENDIF.
*>>> Note 1539682

  IF p_logkz IS INITIAL AND
     p_t_fkkcollh-agsta = c_receivable_cancelled AND
     NOT p_t_fkkcollh-storb IS INITIAL.
* check if the submitted document number is still reversed
    SELECT SINGLE storb INTO  h_storb
                        FROM  dfkkko
                        WHERE opbel EQ p_t_fkkcollh-opbel.

*>>> Note 2214769
    IF h_storb IS INITIAL.
* check if there was a statistical item reset
      SELECT SINGLE augrd INTO h_augrd
                          FROM  dfkkop
                          WHERE opbel EQ p_t_fkkcollh-opbel
                            AND inkps EQ p_t_fkkcollh-inkps.
    ENDIF.

    IF h_storb IS INITIAL AND NOT h_augrd EQ '06'.
      h_logkz = 'X'.
    ELSE.
      h_logkz = p_logkz.
    ENDIF.
*<<< Note 2214769

    IF h_storb IS INITIAL.
      h_logkz = 'X'.
    ELSE.
      h_logkz = p_logkz.
    ENDIF.

  ELSEIF p_logkz IS INITIAL AND
     NOT p_t_fkkcollh-augbl IS INITIAL AND
     ( p_t_fkkcollh-agsta = c_receivable_write_off OR
       p_t_fkkcollh-agsta = c_receivable_part_write_off ).
* check if the clearing document has been reversed or resetted
    SELECT SINGLE augbl xragl INTO  (h_augbl, h_xragl)
                        FROM  dfkkop
                        WHERE opbel EQ p_t_fkkcollh-augbl.
    IF NOT h_xragl IS INITIAL.
      h_logkz = 'X'.
      MOVE h_augbl TO t_stor.
      APPEND t_stor.
    ELSE.
      h_logkz = p_logkz.
    ENDIF.

  ELSE.
    READ TABLE t_stor WITH KEY storb = p_t_fkkcollh-storb
               TRANSPORTING NO FIELDS.
    IF sy-subrc EQ 0.
      h_logkz = 'X'.
    ELSE.
      h_logkz = p_logkz.
    ENDIF.
  ENDIF.

* Selektion Storno-Text
  IF p_postyp EQ c_cancelled_receivable.

    IF NOT p_t_fkkcollh-storb IS INITIAL.
      lv_txtvw = 'Storno abgegebener Forderung'(009).
    ELSE.
      lv_txtvw =
                   'Storno abgegebener Forderung bei Mahnen'(010).
    ENDIF.

  ELSEIF p_postyp EQ c_write_off.

    IF p_t_fkkcollh-agsta EQ c_receivable_write_off.
      lv_txtvw = 'Abgegebene Forderung ausgebucht'(011).
    ELSEIF p_t_fkkcollh-agsta EQ c_receivable_part_write_off OR
           p_t_fkkcollh-agsta EQ c_agsta_t-erfolglos         OR
           p_t_fkkcollh-agsta EQ c_agsta_cu_t-erfolglos.
      lv_txtvw = 'Abgegebene Forderung teilausgebucht'(012).
    ENDIF.

  ELSE.

    SELECT SINGLE herkf INTO  h_herkf
                        FROM  dfkkko
                        WHERE opbel EQ p_t_fkkcollh-storb.
    SELECT SINGLE htext INTO  h_htext
                        FROM  tfk001t
                        WHERE spras EQ sy-langu
                        AND   herkf EQ h_herkf.

    CASE h_herkf.
      WHEN '02'.
        IF NOT h_htext IS INITIAL.
          lv_txtvw =  h_htext.
        ELSE.
          lv_txtvw = 'Stornierung  von Kundenzahlung'(001).
        ENDIF.

      WHEN '08'.
        IF NOT h_htext IS INITIAL.
          lv_txtvw =  h_htext.
        ELSE.
          lv_txtvw =
                   'Bankrückläufer von Kundenzahlung'(005).
        ENDIF.

      WHEN '09'.
        IF NOT h_htext IS INITIAL.
          lv_txtvw =  h_htext.
        ELSE.
          lv_txtvw =
                   'Rücknahme Ausgleich von Kundenzahlung'(003).
        ENDIF.

      WHEN '39'.
        IF NOT h_htext IS INITIAL.
          lv_txtvw =  h_htext.
        ELSE.
          lv_txtvw =
                   'Teilrücknahme Ausgleich von Kundenzahlung'(006).
        ENDIF.

      WHEN OTHERS.
        lv_txtvw = 'Stornierung von Kundenzahlung'(004).
    ENDCASE.

  ENDIF.

* ----------------------------------------------------------------------
* file based version (enterprise services not active)
* ----------------------------------------------------------------------
  IF gv_flg_coll_esoa_active IS INITIAL.

* Übergabe Werte zu Storno-Information
    l_fkkcollp_ip_w-laufd   = p_i_basics-runkey-laufd.
    l_fkkcollp_ip_w-laufi   = p_i_basics-runkey-laufi.
    l_fkkcollp_ip_w-w_inkgp = p_t_fkkcollh-inkgp.
    l_fkkcollp_ip_w-intnr   = p_h_intnr_c.
    ADD 1 TO p_h_lfd_p.
    l_fkkcollp_ip_w-lfnum   = p_h_lfd_p.
    l_fkkcollp_ip_w-lfdnr   = p_t_fkkcollh-lfdnr.
    l_fkkcollp_ip_w-logkz   = h_logkz.
    l_fkkcollp_ip_w-satztyp = c_position.
    l_fkkcollp_ip_w-postyp  = p_postyp.
    l_fkkcollp_ip_w-nrzas   = p_t_fkkcollh-nrzas.
    l_fkkcollp_ip_w-opbel   = p_t_fkkcollh-opbel.
    l_fkkcollp_ip_w-inkps   = p_t_fkkcollh-inkps.
    l_fkkcollp_ip_w-gpart   = p_t_fkkcollh-gpart.
    l_fkkcollp_ip_w-vkont   = p_t_fkkcollh-vkont.
    WRITE p_t_fkkcollh-betrw TO l_fkkcollp_ip_w-betrw
                                CURRENCY p_t_fkkcollh-waers.
    IF NOT p_h_betrag IS INITIAL.
      WRITE p_h_betrag TO l_fkkcollp_ip_w-bwtrt
                          CURRENCY p_t_fkkcollh-waers.
    ENDIF.

    IF  p_postyp EQ c_write_off.
      WRITE p_t_fkkcollh-ninkb TO l_fkkcollp_ip_w-bwtrt
                                  CURRENCY p_t_fkkcollh-waers.
    ENDIF.

    l_fkkcollp_ip_w-waers   = p_t_fkkcollh-waers.
    l_fkkcollp_ip_w-augdt   = p_t_fkkcollh-rudat.

    l_fkkcollp_ip_w-txtvw = lv_txtvw.

****    l_fkkcollp_ip_w-txtvw   = 'Kundenzahlung wurde storniert'(001).

    IF g_fkkcollinfo-sumknz  IS INITIAL AND
       l_fkkcollp_ip_w-logkz IS INITIAL.
*--> fill ls_fkkcollh_i from header data

      MOVE-CORRESPONDING l_fkkcollp_ip_w TO ls_fkkcollp_ip.

* ------- calls user exit 5052 / payment ------------------------------*
      PERFORM call_zp_fb_5052_payment
         USING
            p_postyp
            t_fkkcollh_i
            l_fkkcollp_ip_w-lfdnr
         CHANGING
            ls_fkkcollp_ip.

      MOVE-CORRESPONDING ls_fkkcollp_ip TO l_fkkcollp_ip_w.
    ENDIF.

* INSERT: Speichern Informationen zu Storno
*    INSERT INTO dfkkcollp_ip_w VALUES l_fkkcollp_ip_w.
*>>>>> HANA
    DATA: lo_opt       TYPE REF TO if_fkk_optimization_settings,
          x_optimizing TYPE xfeld.
    lo_opt = cl_fkk_optimization_settings=>get_instance( ).
    x_optimizing = lo_opt->is_active( cl_fkk_optimization_settings=>cc_fica_fpci_mass_insert ).
    IF x_optimizing = abap_true.
      APPEND l_fkkcollp_ip_w TO gt_fkkcollp_ip_w.
    ELSE.
      INSERT INTO dfkkcollp_ip_w VALUES l_fkkcollp_ip_w.  "OLD LOGIC
    ENDIF.
*<<<<< HANA

* Registrieren Inkassobüro
    gt_inkgp = p_t_fkkcollh-inkgp.
    COLLECT gt_inkgp.

* Registrieren bearbeiteten Fall
    gt_fall = p_t_fkkcollh-gpart.
    COLLECT gt_fall.

  ENDIF.

* ----------------------------------------------------------------------
* enterprise service version (enterprise services active)
* ----------------------------------------------------------------------
  IF gv_flg_coll_esoa_active = 'X'.

* collection unit information
    CLEAR ls_collitem.
    ls_collitem-inkgp = p_t_fkkcollh-inkgp.
    ls_collitem-gpart = p_t_fkkcollh-gpart.
    CONCATENATE p_t_fkkcollh-opbel p_t_fkkcollh-inkps INTO ls_collitem-collitem_id.

    SELECT SINGLE collitem_lv FROM dfkkcollitem INTO lv_collitem_lv
            WHERE collitem_id = ls_collitem-collitem_id.
    IF sy-subrc = 0 AND NOT lv_collitem_lv IS INITIAL.
      ls_collitem-collitem_lv = lv_collitem_lv.
    ELSE.
      ls_collitem-collitem_lv = '01'.
    ENDIF.

    IF  p_postyp EQ c_write_off.
*>>> Note 1687283
* check if the write-off has been reported by the collection agency
      SELECT SINGLE * FROM dfkkcollitem INTO ls_collitem_info
            WHERE collitem_id = ls_collitem-collitem_id
              AND collitem_id_par NE space.
      IF sy-subrc = 0.
        lv_collitem_id = ls_collitem_info-collitem_id_par.
      ELSE.
        lv_collitem_id = ls_collitem-collitem_id.
      ENDIF.
      SELECT SINGLE * FROM dfkkcollitem INTO ls_collitem1
        WHERE inkgp       = p_t_fkkcollh-inkgp
          AND gpart       = p_t_fkkcollh-gpart
          AND collitem_id = lv_collitem_id
          AND ninkb       <> 0             " Note 2543820
          AND prcst BETWEEN '12' AND '13'.
      IF sy-subrc <> 0.
        SELECT SINGLE * FROM dfkkcollitem INTO ls_collitem1
          WHERE inkgp       = p_t_fkkcollh-inkgp
            AND gpart       = p_t_fkkcollh-gpart
            AND collitem_id = p_t_fkkcollh-opbel
            AND ninkb       <> 0          " Note 2543820
            AND prcst BETWEEN '12' AND '13'.
      ENDIF.
      IF sy-subrc = 0.
        EXIT.
      ENDIF.
*<<< Note 1687283
      ls_collitem-rinkb = p_t_fkkcollh-ninkb.
      ls_collitem-rcdat = p_t_fkkcollh-rudat.
      lv_betrw_content = ls_collitem-rinkb.
    ELSEIF p_h_betrag < 0.
* reversal of former payment clearing
      lx_flg_payment_info = 'X'.
      lv_betrz_st = abs( p_h_betrag ).
      lv_betrw_content = lv_betrz_st.
    ELSEIF p_h_betrag > 0.
      ls_collitem-ainkb = p_h_betrag.
* if submitted credit, then inverse amount
      IF p_t_fkkcollh-betrw < 0.
        ls_collitem-ainkb = -1 * ls_collitem-ainkb.
      ENDIF.
      ls_collitem-agdat = p_t_fkkcollh-rudat.
      lv_betrw_content = ls_collitem-ainkb.
    ELSEIF p_t_fkkcollh-storb IS NOT INITIAL.
      ls_collitem-rinkb = abs( p_t_fkkcollh-betrw ).
      ls_collitem-rcdat = p_t_fkkcollh-rudat.
      lv_betrw_content = ls_collitem-rinkb.
    ENDIF.
    ls_collitem-waers = p_t_fkkcollh-waers.
    ls_collitem-txtkm = lv_txtvw.

* reversal payment information
    IF lx_flg_payment_info = 'X'.

* payment information
      CLEAR ls_collpaym.

      ls_collpaym-inkgp = p_t_fkkcollh-inkgp.
      ls_collpaym-gpart = p_t_fkkcollh-gpart.

      ls_collpaym-collpaym_id = p_t_fkkcollh-storb.
      ls_collpaym-collpaym_tp = '1'.

      ls_collpaym-waers = p_t_fkkcollh-waers.
      ls_collpaym-betrw = lv_betrz_st.
      ls_collpaym-revdt = p_t_fkkcollh-rudat.

* payment assignment information
      CLEAR ls_collpaymlink.

      ls_collpaymlink-inkgp = p_t_fkkcollh-inkgp.
      ls_collpaymlink-gpart = p_t_fkkcollh-gpart.

      ls_collpaymlink-collpaym_id = p_t_fkkcollh-storb.
      ls_collpaymlink-collpaym_tp = '1'.

      CONCATENATE p_t_fkkcollh-opbel p_t_fkkcollh-inkps INTO ls_collpaymlink-collitem_id.

      IF NOT lv_collitem_lv IS INITIAL.
        ls_collpaymlink-collitem_lv = lv_collitem_lv.
      ELSE.
        ls_collpaymlink-collitem_lv = '01'.
      ENDIF.

      ls_collpaymlink-waers = p_t_fkkcollh-waers.
      ls_collpaymlink-betrz_st = lv_betrz_st.
      ls_collpaymlink-rcpdt = p_t_fkkcollh-rudat.

      ls_collpaymlink-txtkm = lv_txtvw.

* logkz information paym/paymlink
      CLEAR ls_collpaym_logkz.
      ls_collpaym_logkz-inkgp = ls_collpaym-inkgp.
      ls_collpaym_logkz-collpaym_id = ls_collpaym-collpaym_id.
      ls_collpaym_logkz-collpaym_tp = ls_collpaym-collpaym_tp.
      ls_collpaym_logkz-logkz = h_logkz.
      APPEND ls_collpaym_logkz TO gt_collpaym_logkz.

    ELSE.

* logkz information item
      CLEAR ls_collitem_logkz.
      ls_collitem_logkz-inkgp = ls_collitem-inkgp.
      ls_collitem_logkz-collitem_id = ls_collitem-collitem_id.
      ls_collitem_logkz-collitem_lv = ls_collitem-collitem_lv.
      ls_collitem_logkz-logkz = h_logkz.
      APPEND ls_collitem_logkz TO gt_collitem_logkz.

    ENDIF.

* insert into global collections table
    READ TABLE gt_collections_hash ASSIGNING <fs_collections>
      WITH TABLE KEY inkgp = ls_collitem-inkgp
                     gpart = ls_collitem-gpart.
    IF sy-subrc = 0.
      IF lx_flg_payment_info IS INITIAL.
        APPEND ls_collitem TO <fs_collections>-collitem_tab.
      ELSE.
        COLLECT ls_collpaym INTO <fs_collections>-collpaym_tab.
        APPEND ls_collpaymlink TO <fs_collections>-collpaymlink_tab.
      ENDIF.
    ELSE.
      CLEAR ls_collections.
      ls_collections-inkgp = ls_collitem-inkgp.
      ls_collections-gpart = ls_collitem-gpart.
      IF lx_flg_payment_info IS INITIAL.
        APPEND ls_collitem TO ls_collections-collitem_tab.
      ELSE.
        APPEND ls_collpaym TO ls_collections-collpaym_tab.
        APPEND ls_collpaymlink TO ls_collections-collpaymlink_tab.
      ENDIF.
      INSERT ls_collections INTO TABLE gt_collections_hash.
    ENDIF.

* collect information for DFKKCOLI_LOG
    CLEAR ls_coli_log.
    ls_coli_log-opbel  = p_t_fkkcollh-opbel.
    ls_coli_log-inkps  = p_t_fkkcollh-inkps.
    ls_coli_log-gpart  = p_t_fkkcollh-gpart.
    ls_coli_log-lfdnr  = p_t_fkkcollh-lfdnr.
    ls_coli_log-postyp = p_postyp.
    ls_coli_log-vkont  = p_t_fkkcollh-vkont.
    ls_coli_log-betrw  = p_t_fkkcollh-betrw.
*  ls_coli_log-bwtrt  = p_t_fkkcollh-bwtrt.
    ls_coli_log-waers  = p_t_fkkcollh-waers.
*  ls_coli_log-augdt  = p_t_fkkcollh-augdt.
*  ls_coli_log-txtvw  = p_t_fkkcollh-txtvw.
    ls_coli_log-ernam  = sy-uname.
    ls_coli_log-erdat  = sy-datum.
    ls_coli_log-erzeit = sy-uzeit.
    ls_coli_log-laufd  = p_i_basics-runkey-laufd.
    ls_coli_log-laufi  = p_i_basics-runkey-laufi.

* collect information for application log
    CLEAR ls_postyp_sum.
    ls_postyp_sum-inkgp  = p_t_fkkcollh-inkgp.
    IF lv_xml_for_gpart IS INITIAL.
      CLEAR ls_postyp_sum-gpart.
    ELSE.
      ls_postyp_sum-gpart = p_t_fkkcollh-gpart.
    ENDIF.
    ls_postyp_sum-postyp = p_postyp.
    ls_postyp_sum-waers  = p_t_fkkcollh-waers.
    ls_postyp_sum-betrw  = lv_betrw_content.
    ls_postyp_sum-poscnt = 1.

* insert into global coli_log table
    READ TABLE gt_coli_log_ext_hash ASSIGNING <fs_coli_log_ext>
      WITH TABLE KEY inkgp = p_t_fkkcollh-inkgp
                     gpart = p_t_fkkcollh-gpart.
    IF sy-subrc = 0.
      APPEND ls_coli_log TO <fs_coli_log_ext>-coli_log_tab.
      IF h_logkz IS INITIAL.
        COLLECT ls_postyp_sum INTO <fs_coli_log_ext>-postyp_sum_tab.
      ENDIF.
    ELSE.
      CLEAR ls_coli_log_ext.
      ls_coli_log_ext-inkgp = p_t_fkkcollh-inkgp.
      ls_coli_log_ext-gpart = p_t_fkkcollh-gpart.
      APPEND ls_coli_log TO ls_coli_log_ext-coli_log_tab.
      IF h_logkz IS INITIAL.
        COLLECT ls_postyp_sum INTO ls_coli_log_ext-postyp_sum_tab.
      ENDIF.
      INSERT ls_coli_log_ext INTO TABLE gt_coli_log_ext_hash.
    ENDIF.

  ENDIF.

ENDFORM.                    " info_storno
*&---------------------------------------------------------------------*
*&      Form  select_agsta_fixed_values
*&---------------------------------------------------------------------*
FORM select_agsta_fixed_values.

  CLEAR: gt_dd07v[],gt_dd07v.

* Lesen Abgabestatus-Festwerte
  CALL FUNCTION 'DDUT_DOMVALUES_GET'
    EXPORTING
      name          = 'AGSTA_KK'
      langu         = sy-langu
    TABLES
      dd07v_tab     = gt_dd07v
    EXCEPTIONS
      illegal_input = 1
      OTHERS        = 2.
  IF sy-subrc <> 0.
* Nachricht: Fehler bei Selektion von Abgabestatus-Festwerten
    mac_appl_log_msg sy-msgty sy-msgid sy-msgno
     sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
     c_msgprio_high '1' .
    SET EXTENDED CHECK OFF.
    IF 1 = 2.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    SET EXTENDED CHECK ON.
  ENDIF.

ENDFORM.                    " select_agsta_fixed_values
*&---------------------------------------------------------------------*
*&      Form  check_posting_area
*&---------------------------------------------------------------------*
FORM check_posting_area.

  DATA: h_tfk033d  LIKE tfk033d.

  CLEAR g_xcpart.
  CLEAR g_xausg.
  CLEAR g_xback.
  CLEAR g_xrever.
  CLEAR g_xreclr.
  CLEAR g_xretrn.
  CLEAR h_tfk033d.

  CALL FUNCTION 'FKK_GET_APPLICATION'
    EXPORTING
      i_no_dialog   = c_marked
    IMPORTING
      e_applk       = h_tfk033d-applk
    EXCEPTIONS
      error_message = 1.

  h_tfk033d-buber = c_buber_1059.

* Lesen anwendungsspezifische Daten
  CALL FUNCTION 'FKK_ACCOUNT_DETERMINE'
    EXPORTING
      i_tfk033d           = h_tfk033d
    IMPORTING
      e_tfk033d           = h_tfk033d
    EXCEPTIONS
      error_in_input_data = 1
      nothing_found       = 2
      OTHERS              = 3.
* Inkassobüro über Partneränderungen informieren
  IF NOT h_tfk033d-fun01 IS INITIAL.
    g_xcpart = true.
  ENDIF.
* Inkassobüro über Zahlungen informieren
  IF NOT h_tfk033d-fun02 IS INITIAL.
    g_xausg = true.
  ENDIF.
* Inkassobüro über Rückruf informieren
  IF NOT h_tfk033d-fun03 IS INITIAL.
    g_xback = true.
  ENDIF.
* Inkassobüro über Stornierung informieren
  IF NOT h_tfk033d-fun04 IS INITIAL.
    g_xrever = true.
  ENDIF.
* Inkassobüro über Ausgleichsrücknahme informieren
  IF NOT h_tfk033d-fun05 IS INITIAL.
    g_xreclr = true.
  ENDIF.
* Inkassobüro über Rückläufer informieren
  IF NOT h_tfk033d-fun06 IS INITIAL.
    g_xretrn = true.
  ENDIF.

* ------ for cross reference purpose only -----------------------------*
  SET EXTENDED CHECK OFF.
  IF 1 = 2. CALL FUNCTION 'FKK_ACCOUNT_DETERMINE_1059'. ENDIF.
  SET EXTENDED CHECK ON.
* ------ end of cross reference ---------------------------------------*

ENDFORM.                    " check_posting_area
*&---------------------------------------------------------------------*
*&      Form  esmon_log_bus_object_open
*&---------------------------------------------------------------------*
FORM esmon_log_bus_object_open USING p_objtype TYPE swo_objtyp
                                     p_objkey  TYPE swo_typeid.

  CALL FUNCTION 'EMMA_LOG_BUS_OBJECT_OPEN'
    EXPORTING
      iv_tcode   = sy-tcode
      iv_objtype = p_objtype
      iv_objkey  = p_objkey.

ENDFORM.                    " esmon_log_bus_object_open
*&---------------------------------------------------------------------*
*&      Form  esmon_log_bus_object_close
*&---------------------------------------------------------------------*
FORM esmon_log_bus_object_close USING p_objtype TYPE swo_objtyp.

  CALL FUNCTION 'EMMA_LOG_BUS_OBJECT_CLOSE'
    EXPORTING
      iv_tcode   = sy-tcode
      iv_objtype = p_objtype.

ENDFORM.                    " esmon_log_bus_object_close
*&---------------------------------------------------------------------*
*&      Form  Lesen_herkunft
*&---------------------------------------------------------------------*
FORM lesen_herkunft  USING    p_fkkcollh TYPE dfkkcollh
                     CHANGING p_herkf    TYPE herkf_kk.

  CLEAR p_herkf.
  SELECT SINGLE herkf INTO  p_herkf
                      FROM  dfkkko
                      WHERE opbel EQ p_fkkcollh-storb.

ENDFORM.                    " Lesen_herkunft
*&---------------------------------------------------------------------*
*&      Form  check_Logtable
*&---------------------------------------------------------------------*
FORM check_logtable  USING    p_fkkcollh_alt STRUCTURE dfkkcollh
                     CHANGING p_logtb TYPE c
                              p_logkz TYPE c.

  DATA:
    l_opbel TYPE opbel_kk.

  CLEAR: p_logtb, p_logkz.

* currently no index available for this select
  SELECT SINGLE logkz INTO  p_logkz                     "#EC CI_NOFIRST
                    FROM  dfkkcollp_ip_w
                    WHERE nrzas EQ p_fkkcollh_alt-nrzas
                    AND   opbel EQ p_fkkcollh_alt-opbel
                    AND   inkps EQ p_fkkcollh_alt-inkps
                    AND   gpart EQ p_fkkcollh_alt-gpart
                    AND   lfdnr EQ p_fkkcollh_alt-lfdnr.

* collection agency was not informed, only log entry in DFKKCOLLP_IP_W ?
  IF sy-subrc NE 0.
    CLEAR p_logkz.
  ENDIF.

*  SELECT SINGLE opbel INTO  l_opbel
*                      FROM  dfkkcoli_log
*                      WHERE nrzas EQ p_fkkcollh_alt-nrzas
*                      AND   opbel EQ p_fkkcollh_alt-opbel
*                      AND   inkps EQ p_fkkcollh_alt-inkps
*                      AND   gpart EQ p_fkkcollh_alt-gpart
*                      AND   lfdnr EQ p_fkkcollh_alt-lfdnr .

*  CHECK sy-subrc IS INITIAL.
* Inkassobüro wurde schon einmal über den Posten informiert
*  p_logtb = true.

ENDFORM.                    " check_Logtable
*&---------------------------------------------------------------------*
*&      Form  read_last_recall
*&---------------------------------------------------------------------*
FORM read_last_recall  TABLES   pt_fkkcollh STRUCTURE dfkkcollh
                       CHANGING ph_collh09 TYPE dfkkcollh.

  DATA: lv_last_agsta TYPE agsta_kk.
  DATA: lt_fkkcollh_tmp TYPE STANDARD TABLE OF dfkkcollh.

  CLEAR ph_collh09.
  LOOP AT pt_fkkcollh.
    APPEND pt_fkkcollh TO lt_fkkcollh_tmp.
* if there are two consecutive statuses 09, consider only the first one
    IF lv_last_agsta = c_receivable_recalled AND
       pt_fkkcollh-agsta EQ c_receivable_recalled.
      lv_last_agsta = pt_fkkcollh-agsta.
      CONTINUE.
    ENDIF.
    lv_last_agsta = pt_fkkcollh-agsta.
    CHECK pt_fkkcollh-agsta EQ c_receivable_recalled.
    "if no submission between two statuses 09, consider the first one
    READ TABLE lt_fkkcollh_tmp TRANSPORTING NO FIELDS WITH KEY agsta = c_receivable_submitted.
    IF sy-subrc = 0.
      ph_collh09 = pt_fkkcollh.
    ENDIF.
    CLEAR lt_fkkcollh_tmp.
  ENDLOOP.

ENDFORM.                    " read_last_recall
*&---------------------------------------------------------------------*
*&      Form  infos_pro_inkgp
*&---------------------------------------------------------------------*
FORM infos_pro_inkgp  TABLES   t_fkkcollh STRUCTURE dfkkcollh
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

  CHECK g_fkkcollinfo-xausg   = c_marked OR
        g_fkkcollinfo-xback   = c_marked OR
        g_fkkcollinfo-xrever  = c_marked OR
        g_fkkcollinfo-xreclr  = c_marked OR
        g_fkkcollinfo-xretrn  = c_marked OR
        g_fkkcollinfo-xstorno = c_marked OR
        g_fkkcollinfo-xwroff  = c_marked.

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
                  PERFORM info_payment USING    c_clearing
                                                i_basics
                                                h_intnr_c
                                                t_fkkcollh
                                                h_lfd_p
                                                h_betrag
                                                space.
                ELSE.
*                 Ausgleich in Log-Tabelle registrieren
                  PERFORM info_payment USING    c_clearing
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


      WHEN OTHERS.

        w_collh_last   = t_fkkcollh.
        CONTINUE.

    ENDCASE.

    w_collh_last   = t_fkkcollh.

  ENDLOOP.     " Historie

ENDFORM.                    " infos_pro_inkgp

*&---------------------------------------------------------------------*
*&      Form  get_ibvalues
*&---------------------------------------------------------------------*
*       Show text of collection agency
*----------------------------------------------------------------------*
FORM get_ibvalues  CHANGING p_inkgp TYPE inkgp_kk.

  DATA:
    tab_fields LIKE dfies     OCCURS 0 WITH HEADER LINE,
    tab_update LIKE dynpread  OCCURS 0 WITH HEADER LINE,
    returntab  LIKE ddshretval OCCURS 0 WITH HEADER LINE,
    BEGIN OF ib_text OCCURS 0,
      name TYPE bu_descrip_long,
    END OF ib_text,
    ht_tfk050b    TYPE tfk050b OCCURS 0 WITH HEADER LINE,
    h_descrip     TYPE bu_descrip_long,
    h_selectfield LIKE help_info-fieldname.

  SELECT * FROM tfk050b INTO TABLE ht_tfk050b.

  LOOP AT ht_tfk050b.
    CALL FUNCTION 'BUP_PARTNER_DESCRIPTION_GET'
      EXPORTING
        i_partner          = ht_tfk050b-inkgp
        i_valdt            = sy-datlo
      IMPORTING
        e_description_long = h_descrip
      EXCEPTIONS
        partner_not_found  = 1
        wrong_parameters   = 2
        OTHERS             = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'."Note 1830945
    ELSE.
      MOVE ht_tfk050b-inkgp TO ib_text-name.
      APPEND ib_text.
      MOVE h_descrip        TO ib_text-name.
      APPEND ib_text.
    ENDIF.
  ENDLOOP.

* ------ fill format table with data dictionary information -----------*
  REFRESH tab_fields.
  CLEAR tab_fields.
  tab_fields-tabname     = 'TFK050B'.
  tab_fields-fieldname   = 'INKGP'.
  APPEND tab_fields.
  CLEAR tab_fields.
  tab_fields-tabname    = 'FKKEBPP_PARTNER'.
  tab_fields-fieldname  = 'DESCRIP_LONG'.
  APPEND tab_fields.
  h_selectfield = 'INKGP'.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield   = h_selectfield
      value_org  = 'C'
      display    = ' '
    TABLES
      value_tab  = ib_text
      field_tab  = tab_fields
      return_tab = returntab
    EXCEPTIONS
      OTHERS     = 0.

  READ TABLE returntab INDEX 1.
  IF sy-subrc = 0.
    p_inkgp = returntab-fieldval.
  ENDIF.

ENDFORM.                    " get_ibvalues

*&---------------------------------------------------------------------*
*&      Form  get_decimal_notation
*&---------------------------------------------------------------------*
FORM get_decimal_notation .

  SELECT SINGLE dcpfm INTO g_dcpfm FROM usr01 WHERE bname EQ sy-uname.

ENDFORM.                    " get_decimal_notation
*&                                                                     *
*&      Form  check_logical_file_name
*&                                                                     *
FORM check_logical_file_name USING pi_basics  TYPE fkk_mad_basics
                                   p_filename TYPE fileintern.

  DATA: h_phys_filename TYPE pathextern.  " Note 1922813

  IF NOT g_fkkcollinfo-datei IS INITIAL.
* Lesen phys. Dateiname
    CALL FUNCTION 'FILE_GET_NAME'
      EXPORTING
        logical_filename = p_filename
      IMPORTING
        file_name        = h_phys_filename
      EXCEPTIONS
        file_not_found   = 1
        OTHERS           = 2.
    IF sy-subrc <> 0.
* Nachricht: Log. Datei & wurde nicht gefunden!
      CONCATENATE p_filename c_subname
                  INTO h_phys_filename.
    ELSE.
      CONCATENATE h_phys_filename c_subname
                  INTO h_phys_filename.
    ENDIF.

* >>> note 1584972
* security enhancement (start)
    CALL FUNCTION 'FILE_VALIDATE_NAME'
      EXPORTING
        logical_filename           = 'FI-CA-COL-INFO'
      CHANGING
        physical_filename          = h_phys_filename
      EXCEPTIONS
        logical_filename_not_found = 1
        validation_failed          = 2
        OTHERS                     = 3.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
* security enhancement (end)
* <<< note 1584972

* check if file can be opened
    OPEN DATASET h_phys_filename FOR OUTPUT IN TEXT MODE ENCODING
                           NON-UNICODE IGNORING CONVERSION ERRORS.
    IF NOT sy-subrc IS INITIAL.
* Nachricht: Testdatei & konnte nicht geöffnet werden!
      MESSAGE a825(>4) WITH h_phys_filename.
    ELSE.
      DELETE DATASET h_phys_filename.
    ENDIF.
  ENDIF.
ENDFORM.                    " check_logical_file_name
*&---------------------------------------------------------------------*
*&      Form  create_info_storno
*&---------------------------------------------------------------------*
FORM create_info_storno  USING
                            p_postyp TYPE postyp_kk
                            p_p_fkkcollinfo TYPE fkkcollinfo
                            p_p_h_file_name
                            p_p_t_fkkcollh_i_w LIKE dfkkcollh_i_w
                            p_p_t_fkkcollh_i LIKE fkkcollh_i
                            p_p_i_basics TYPE fkk_mad_basics
                         CHANGING
                            p_p_t_fkkcollt_i LIKE fkkcollt_i.

  DATA:
    t_fkkcollp_ip   LIKE fkkcollp_ip,
    t_fkkcollp_ip_w LIKE dfkkcollp_ip_w,
    h_lfnum         LIKE dfkkcoli_log-lfdnr,
    h_anzza         LIKE sy-tabix,
    h_sumza         TYPE sumza_kk,
    h_summe         TYPE sumza_kk,
    h_knz,
    sum_fkkcollp_ip LIKE fkkcollp_ip,
    t_fkkcollp_ip_w_old LIKE dfkkcollp_ip_w,
    hx_addtofile    TYPE xfeld.

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
    t_fkkcollp_ip,
    t_fkkcollp_ip_w,
    t_fkkcollp_ip_w_old,
    sum_fkkcollp_ip,
    h_anzza,
    h_summe,
    h_knz,
    hx_addtofile.

  CLEAR:
    h_key_nrzas,
    h_key_nrzas_old,
    h_key_gpart,
    h_key_gpart_old,
    h_key_vkont,
    h_key_vkont_old.

  CASE p_p_fkkcollinfo-sumknz.

    WHEN c_sum_no.
* ------- Keine Summierung --------------------------------------------*

* Lesen Ausgleichs-Informationen aus Zwischenspeicher
      SELECT * INTO CORRESPONDING FIELDS OF t_fkkcollp_ip_w
               FROM  dfkkcollp_ip_w
               WHERE laufd   EQ p_p_i_basics-runkey-laufd
               AND   laufi   EQ p_p_i_basics-runkey-laufi
               AND   w_inkgp EQ p_p_t_fkkcollh_i_w-w_inkgp
               AND   satztyp EQ c_position
               AND   postyp  EQ p_postyp
               ORDER BY nrzas opbel inkps gpart.

        MOVE-CORRESPONDING t_fkkcollp_ip_w TO t_fkkcollp_ip.

* ------- calls user exit 5052 / payment ------------------------------*
*        perform call_zp_fb_5052_payment
*           using
*              p_postyp
*              p_p_t_fkkcollh_i
*              t_fkkcollp_ip_w-lfdnr
*           changing
*              t_fkkcollp_ip.

* Ausgabe Inkassoposition auf Informationsdatei
        IF t_fkkcollp_ip_w-logkz IS INITIAL.
          ADD 1 TO h_anzza.
        ENDIF.
        IF p_p_i_basics-status-xsimu IS INITIAL.
          IF t_fkkcollp_ip_w-logkz IS INITIAL.
            IF g_sort IS INITIAL.
              TRANSFER t_fkkcollp_ip TO p_p_h_file_name.
            ELSE.
* append to an internal table and sort and transfer to the file later
              MOVE-CORRESPONDING t_fkkcollp_ip_w TO gt_fkkcollp_ip.
              MOVE-CORRESPONDING t_fkkcollp_ip   TO gt_fkkcollp_ip.
              APPEND gt_fkkcollp_ip.
            ENDIF.
          ENDIF.

* Meldung registrieren
          PERFORM write_log_record_payment
             USING
                t_fkkcollp_ip_w-lfdnr
                t_fkkcollp_ip
                p_p_i_basics.
        ENDIF.

* Aktualisieren Datei-Endesatz
        IF t_fkkcollp_ip_w-logkz IS INITIAL.
          ADD 1 TO p_p_t_fkkcollt_i-recnum.

          IF p_postyp EQ c_cancelled_receivable.
            PERFORM addition
              USING
                t_fkkcollp_ip-betrw
              CHANGING
                p_p_t_fkkcollt_i-sumrc.

* Aktualisieren Summensatz je Positionstyp
            PERFORM addition
              USING
                t_fkkcollp_ip-betrw
              CHANGING
                h_summe.
          ELSE.
            PERFORM addition
              USING
                t_fkkcollp_ip-bwtrt
              CHANGING
                p_p_t_fkkcollt_i-sumza.

* Aktualisieren Summensatz je Positionstyp
            PERFORM addition
              USING
                t_fkkcollp_ip-bwtrt
              CHANGING
                h_summe.
          ENDIF.
        ENDIF.

      ENDSELECT.


    WHEN c_sum_gpart..

* ------- Summierung auf Geschäftspartnerebene ---------------------*
* Lesen Zahlungs- bzw. Ausgleichs-Informationen aus Zwischenspeicher
      SELECT * INTO  CORRESPONDING FIELDS OF t_fkkcollp_ip_w
               FROM  dfkkcollp_ip_w
               WHERE laufd   EQ p_p_i_basics-runkey-laufd
               AND   laufi   EQ p_p_i_basics-runkey-laufi
               AND   w_inkgp EQ p_p_t_fkkcollh_i_w-w_inkgp
               AND   satztyp EQ c_position
               AND   postyp  EQ p_postyp
            ORDER BY gpart nrzas opbel inkps lfdnr.

        MOVE-CORRESPONDING t_fkkcollp_ip_w TO t_fkkcollp_ip.
        MOVE-CORRESPONDING t_fkkcollp_ip TO h_key_gpart.

        IF h_key_gpart_old NE h_key_gpart.
* Gruppenwechsel
          IF NOT h_knz IS INITIAL.

* ------- calls user exit 5052 / payment (sum) ------------------------*
            PERFORM call_zp_fb_5052_payment
               USING
                  p_postyp
                  p_p_t_fkkcollh_i
                  0
               CHANGING
                  sum_fkkcollp_ip.

* Ausgabe Inkassoposition auf Informationsdatei
*            IF t_fkkcollp_ip_w-logkz IS INITIAL.
            "note 2890112: not enough to consider t_fkkcollp_ip_w_old as
            "  there could have been other records to report before
            IF hx_addtofile = true.
              ADD 1 TO h_anzza.

              IF p_p_i_basics-status-xsimu IS INITIAL.
                TRANSFER sum_fkkcollp_ip TO p_p_h_file_name.
              ENDIF.

* Aktualisieren Datei-Endesatz
              ADD 1 TO p_p_t_fkkcollt_i-recnum.
              IF p_postyp EQ c_cancelled_receivable.
                PERFORM addition
                  USING
                    sum_fkkcollp_ip-betrw
                  CHANGING
                    p_p_t_fkkcollt_i-sumrc.
              ELSE.
                PERFORM addition
                  USING
                    sum_fkkcollp_ip-bwtrt
                  CHANGING
                    p_p_t_fkkcollt_i-sumza.
              ENDIF.
            ENDIF.
          ENDIF.
          CLEAR sum_fkkcollp_ip.
          CLEAR hx_addtofile.
        ENDIF.
        h_knz = 'X'.

        IF t_fkkcollp_ip_w-logkz IS INITIAL.
          hx_addtofile = true.
        ENDIF.

* Aufbau Summensatz
        sum_fkkcollp_ip-postyp  = t_fkkcollp_ip-postyp.
        sum_fkkcollp_ip-satztyp = t_fkkcollp_ip-satztyp.
        sum_fkkcollp_ip-nrzas   = t_fkkcollp_ip-nrzas.
        sum_fkkcollp_ip-gpart   = t_fkkcollp_ip-gpart.
        sum_fkkcollp_ip-waers   = t_fkkcollp_ip-waers.
        sum_fkkcollp_ip-txtvw   = t_fkkcollp_ip-txtvw.

        ">>>Note 2890112
        IF t_fkkcollp_ip_w_old IS INITIAL OR
          ( t_fkkcollp_ip_w_old-vkont NE t_fkkcollp_ip_w-vkont
            OR t_fkkcollp_ip_w_old-nrzas NE t_fkkcollp_ip_w-nrzas
            OR t_fkkcollp_ip_w_old-opbel NE t_fkkcollp_ip_w-opbel
            OR t_fkkcollp_ip_w_old-inkps NE t_fkkcollp_ip_w-inkps ).

          PERFORM addition
            USING
              t_fkkcollp_ip-betrw
            CHANGING
              sum_fkkcollp_ip-betrw.
        ENDIF.

        IF t_fkkcollp_ip_w-logkz IS INITIAL.
          PERFORM addition
          USING
            t_fkkcollp_ip-bwtrt
            CHANGING
              sum_fkkcollp_ip-bwtrt.

* Aktualisieren Protokollsatz
          PERFORM addition
            USING
              t_fkkcollp_ip-bwtrt
            CHANGING
              h_summe.
        ENDIF.

* Meldung registrieren
        IF p_p_i_basics-status-xsimu IS INITIAL.
          PERFORM write_log_record_payment
             USING
                t_fkkcollp_ip_w-lfdnr
                t_fkkcollp_ip
                p_p_i_basics.
        ENDIF.

        MOVE-CORRESPONDING h_key_gpart TO h_key_gpart_old.

        CLEAR t_fkkcollp_ip_w_old.
        t_fkkcollp_ip_w_old = t_fkkcollp_ip_w.

      ENDSELECT.

* Ausagbe letzte Inkassoposition
      IF NOT h_knz IS INITIAL.

* ------- calls user exit 5052 / payment -----------------------------*
        PERFORM call_zp_fb_5052_payment
           USING
              p_postyp
              p_p_t_fkkcollh_i
              0
           CHANGING
              sum_fkkcollp_ip.

* Ausgabe Inkassoposition auf Informationsdatei
*        IF NOT h_summe IS INITIAL.
        IF hx_addtofile = true.  "note 2890112
          ADD 1 TO h_anzza.

          IF p_p_i_basics-status-xsimu IS INITIAL.
            TRANSFER sum_fkkcollp_ip TO p_p_h_file_name.
          ENDIF.
*        ENDIF.
        h_knz = 'X'.

* Aktualisieren Datei-Endesatz
*        IF t_fkkcollp_ip_w-logkz IS INITIAL.
          ADD 1 TO p_p_t_fkkcollt_i-recnum.
          IF p_postyp EQ c_cancelled_receivable.
            PERFORM addition
               USING
                sum_fkkcollp_ip-betrw
               CHANGING
                 p_p_t_fkkcollt_i-sumrc.
          ELSE.
            PERFORM addition
               USING
                sum_fkkcollp_ip-bwtrt
               CHANGING
                 p_p_t_fkkcollt_i-sumza.
          ENDIF.
        ENDIF.
      ENDIF.


    WHEN c_sum_nrzas.
* ------- Summierung auf Basis Zahlschein-Nummer ----------------------*

* Lesen Ausgleichs-Informationen aus Zwischenspeicher
      SELECT * INTO  CORRESPONDING FIELDS OF t_fkkcollp_ip_w
               FROM  dfkkcollp_ip_w
               WHERE laufd   EQ p_p_i_basics-runkey-laufd
               AND   laufi   EQ p_p_i_basics-runkey-laufi
               AND   w_inkgp EQ p_p_t_fkkcollh_i_w-w_inkgp
               AND   satztyp EQ c_position
               AND   postyp  EQ p_postyp
            ORDER BY nrzas gpart opbel inkps lfdnr.

        MOVE-CORRESPONDING t_fkkcollp_ip_w TO t_fkkcollp_ip.
        MOVE-CORRESPONDING t_fkkcollp_ip TO h_key_nrzas.

        IF h_key_nrzas_old NE h_key_nrzas.
* Gruppenwechsel
          IF NOT h_knz IS INITIAL.
* ------- calls user exit 5052 / payment (sum) ------------------------*
            PERFORM call_zp_fb_5052_payment
               USING
                  p_postyp
                  p_p_t_fkkcollh_i
                  0
               CHANGING
                  sum_fkkcollp_ip.

* Ausgabe Inkassoposition auf Informationsdatei
*            IF t_fkkcollp_ip_w-logkz IS INITIAL.
            "note 2890112: not enough to consider t_fkkcollp_ip_w_old as
            "  there could have been other records to report before
            IF hx_addtofile = true.
              ADD 1 TO h_anzza.

              IF p_p_i_basics-status-xsimu IS INITIAL.
                TRANSFER sum_fkkcollp_ip TO p_p_h_file_name.
              ENDIF.

* Aktualisieren Datei-Endesatz
              ADD 1 TO p_p_t_fkkcollt_i-recnum.
              IF p_postyp EQ c_cancelled_receivable.
                PERFORM addition
                   USING
                     sum_fkkcollp_ip-betrw
                   CHANGING
                     p_p_t_fkkcollt_i-sumrc.
              ELSE.
                PERFORM addition
                   USING
                     sum_fkkcollp_ip-bwtrt
                   CHANGING
                     p_p_t_fkkcollt_i-sumza.
              ENDIF.
            ENDIF.
          ENDIF.
          CLEAR sum_fkkcollp_ip.
          CLEAR hx_addtofile.
        ENDIF.
        h_knz = 'X'.

        IF t_fkkcollp_ip_w-logkz IS INITIAL.
          hx_addtofile = true.
        ENDIF.

* Aufbau Summensatz
        sum_fkkcollp_ip-postyp  = t_fkkcollp_ip-postyp.
        sum_fkkcollp_ip-satztyp = t_fkkcollp_ip-satztyp.
        sum_fkkcollp_ip-nrzas   = t_fkkcollp_ip-nrzas.
        sum_fkkcollp_ip-gpart   = t_fkkcollp_ip-gpart.
        sum_fkkcollp_ip-waers   = t_fkkcollp_ip-waers.
        sum_fkkcollp_ip-txtvw   = t_fkkcollp_ip-txtvw.

        ">>>Note 2890112
        IF t_fkkcollp_ip_w_old IS INITIAL OR
          ( t_fkkcollp_ip_w_old-vkont NE t_fkkcollp_ip_w-vkont
            OR t_fkkcollp_ip_w_old-nrzas NE t_fkkcollp_ip_w-nrzas
            OR t_fkkcollp_ip_w_old-opbel NE t_fkkcollp_ip_w-opbel
            OR t_fkkcollp_ip_w_old-inkps NE t_fkkcollp_ip_w-inkps ).

          PERFORM addition
            USING
              t_fkkcollp_ip-betrw
            CHANGING
              sum_fkkcollp_ip-betrw.
        ENDIF.

        IF t_fkkcollp_ip_w-logkz IS INITIAL.
          PERFORM addition
          USING
           t_fkkcollp_ip-bwtrt
          CHANGING
           sum_fkkcollp_ip-bwtrt.

* Aktualisieren Protokollsatz
          PERFORM addition
            USING
              t_fkkcollp_ip-bwtrt
            CHANGING
              h_summe.
        ENDIF.

* Meldung registrieren
        IF p_p_i_basics-status-xsimu IS INITIAL.
          PERFORM write_log_record_payment
             USING
                t_fkkcollp_ip_w-lfdnr
                t_fkkcollp_ip
                p_p_i_basics.
        ENDIF.

* Merken letzte Schlüssel
        MOVE-CORRESPONDING h_key_nrzas TO h_key_nrzas_old.
        CLEAR t_fkkcollp_ip_w_old.
        t_fkkcollp_ip_w_old = t_fkkcollp_ip_w.

      ENDSELECT.

      IF NOT h_knz IS INITIAL.
* ------- calls user exit 5052 / payment (sum) ------------------------*
        PERFORM call_zp_fb_5052_payment
           USING
              p_postyp
              p_p_t_fkkcollh_i
              0
           CHANGING
              sum_fkkcollp_ip.

* Ausgabe Inkassoposition auf Informationsdatei
*        IF t_fkkcollp_ip_w-logkz IS INITIAL.
*        IF NOT h_summe IS INITIAL.
        IF hx_addtofile = true.  "note 2890112
          ADD 1 TO h_anzza.
          IF p_p_i_basics-status-xsimu IS INITIAL.
            TRANSFER sum_fkkcollp_ip TO p_p_h_file_name.
          ENDIF.
*        ENDIF.
        h_knz = 'X'.

* Aktualisieren Datei-Endesatz
*        IF t_fkkcollp_ip_w-logkz IS INITIAL.
          ADD 1 TO p_p_t_fkkcollt_i-recnum.
          IF p_postyp EQ c_cancelled_receivable.
            PERFORM addition
               USING
                sum_fkkcollp_ip-betrw
               CHANGING
                 p_p_t_fkkcollt_i-sumrc.
          ELSE.
            PERFORM addition
               USING
                sum_fkkcollp_ip-bwtrt
               CHANGING
                 p_p_t_fkkcollt_i-sumza.
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN c_sum_vkont.

* ------- Summierung auf Vertragskontoebene ---------------------*
* Lesen Zahlungs- bzw. Ausgleichs-Informationen aus Zwischenspeicher
      SELECT * INTO  CORRESPONDING FIELDS OF t_fkkcollp_ip_w
               FROM  dfkkcollp_ip_w
               WHERE laufd   EQ p_p_i_basics-runkey-laufd
               AND   laufi   EQ p_p_i_basics-runkey-laufi
               AND   w_inkgp EQ p_p_t_fkkcollh_i_w-w_inkgp
               AND   satztyp EQ c_position
               AND   postyp  EQ p_postyp
            ORDER BY vkont nrzas opbel inkps lfdnr.

        MOVE-CORRESPONDING t_fkkcollp_ip_w TO t_fkkcollp_ip.
        MOVE-CORRESPONDING t_fkkcollp_ip TO h_key_vkont.

        IF h_key_vkont_old NE h_key_vkont.
* Gruppenwechsel
          IF NOT h_knz IS INITIAL.

* ------- calls user exit 5052 / payment (sum) ------------------------*
            PERFORM call_zp_fb_5052_payment
               USING
                  p_postyp
                  p_p_t_fkkcollh_i
                  0
               CHANGING
                  sum_fkkcollp_ip.

* Ausgabe Inkassoposition auf Informationsdatei
*            IF t_fkkcollp_ip_w-logkz IS INITIAL.
            "note 2890112: not enough to consider t_fkkcollp_ip_w_old as
            "  there could have been other records to report before
            IF hx_addtofile = true.
              ADD 1 TO h_anzza.

              IF p_p_i_basics-status-xsimu IS INITIAL.
                TRANSFER sum_fkkcollp_ip TO p_p_h_file_name.
              ENDIF.

* Aktualisieren Datei-Endesatz
              ADD 1 TO p_p_t_fkkcollt_i-recnum.
              IF p_postyp EQ c_cancelled_receivable.
                PERFORM addition
                  USING
                    sum_fkkcollp_ip-betrw
                  CHANGING
                    p_p_t_fkkcollt_i-sumrc.
              ELSE.
                PERFORM addition
                  USING
                    sum_fkkcollp_ip-bwtrt
                  CHANGING
                    p_p_t_fkkcollt_i-sumza.
              ENDIF.
            ENDIF.
          ENDIF.
          CLEAR sum_fkkcollp_ip.
          CLEAR hx_addtofile.
        ENDIF.
        h_knz = 'X'.

        IF t_fkkcollp_ip_w-logkz IS INITIAL.
          hx_addtofile = true.
        ENDIF.


* Aufbau Summensatz
        sum_fkkcollp_ip-postyp  = t_fkkcollp_ip-postyp.
        sum_fkkcollp_ip-satztyp = t_fkkcollp_ip-satztyp.
        sum_fkkcollp_ip-nrzas   = t_fkkcollp_ip-nrzas.
        sum_fkkcollp_ip-gpart   = t_fkkcollp_ip-gpart.
        sum_fkkcollp_ip-vkont   = t_fkkcollp_ip-vkont.
        sum_fkkcollp_ip-waers   = t_fkkcollp_ip-waers.
        sum_fkkcollp_ip-txtvw   = t_fkkcollp_ip-txtvw.

        ">>>Note 2890112
        IF t_fkkcollp_ip_w_old IS INITIAL OR
          ( t_fkkcollp_ip_w_old-vkont NE t_fkkcollp_ip_w-vkont
            OR t_fkkcollp_ip_w_old-nrzas NE t_fkkcollp_ip_w-nrzas
            OR t_fkkcollp_ip_w_old-opbel NE t_fkkcollp_ip_w-opbel
            OR t_fkkcollp_ip_w_old-inkps NE t_fkkcollp_ip_w-inkps ).

          PERFORM addition
            USING
              t_fkkcollp_ip-betrw
            CHANGING
              sum_fkkcollp_ip-betrw.
        ENDIF.

        IF t_fkkcollp_ip_w-logkz IS INITIAL.
          PERFORM addition
          USING
            t_fkkcollp_ip-bwtrt
          CHANGING
            sum_fkkcollp_ip-bwtrt.

* Aktualisieren Protokollsatz
          PERFORM addition
            USING
              t_fkkcollp_ip-bwtrt
            CHANGING
              h_summe.
        ENDIF.

* Meldung registrieren
        IF p_p_i_basics-status-xsimu IS INITIAL.
          PERFORM write_log_record_payment
             USING
                t_fkkcollp_ip_w-lfdnr
                t_fkkcollp_ip
                p_p_i_basics.
        ENDIF.

        MOVE-CORRESPONDING h_key_vkont TO h_key_vkont_old.
        CLEAR t_fkkcollp_ip_w_old.
        t_fkkcollp_ip_w_old = t_fkkcollp_ip_w.

      ENDSELECT.

* Ausagbe letzte Inkassoposition
      IF NOT h_knz IS INITIAL.

* ------- calls user exit 5052 / payment -----------------------------*
        PERFORM call_zp_fb_5052_payment
           USING
              p_postyp
              p_p_t_fkkcollh_i
              0
           CHANGING
              sum_fkkcollp_ip.

* Ausgabe Inkassoposition auf Informationsdatei
*        IF t_fkkcollp_ip_w-logkz IS INITIAL.
        IF hx_addtofile = true.  "note 2890112
          ADD 1 TO h_anzza.

          IF p_p_i_basics-status-xsimu IS INITIAL.
            TRANSFER sum_fkkcollp_ip TO p_p_h_file_name.
          ENDIF.
*        ENDIF.
        h_knz = 'X'.

* Aktualisieren Datei-Endesatz
*        IF NOT h_summe IS INITIAL.
          ADD 1 TO p_p_t_fkkcollt_i-recnum.
          IF p_postyp EQ c_cancelled_receivable.
            PERFORM addition
               USING
                sum_fkkcollp_ip-betrw
               CHANGING
                 p_p_t_fkkcollt_i-sumrc.
          ELSE.
            PERFORM addition
               USING
                sum_fkkcollp_ip-bwtrt
               CHANGING
                 p_p_t_fkkcollt_i-sumza.
          ENDIF.
        ENDIF.
      ENDIF.

  ENDCASE.

*>>>>> HANA
  IF NOT gt_fkkcoli_log[] IS INITIAL.
    INSERT dfkkcoli_log FROM TABLE gt_fkkcoli_log.
    CLEAR: gt_fkkcoli_log[],gt_fkkcoli_log.
  ENDIF.
*<<<<< HANA

* Protokoll
  WRITE h_summe TO h_sumza.
  SHIFT h_sumza LEFT DELETING LEADING space.
  IF p_postyp EQ c_cancelled_receivable.
* Nachricht: Datei enthält & Storno-Positionen im Gesamtwert von & &
    IF h_anzza > 0.
*      clear h_sumza.
*      write t_fkkcollp_ip_w-betrw to h_sumza.
*      shift h_sumza left deleting leading space.
      mac_appl_log_msg 'I' '>4' '828'
         h_anzza
         h_sumza t_fkkcollp_ip-waers space
         c_msgprio_info p_p_i_basics-appllog-probclass.
      SET EXTENDED CHECK OFF.
      IF 1 = 2. MESSAGE i809(>4). ENDIF.
      SET EXTENDED CHECK ON.
    ENDIF.

  ELSEIF p_postyp EQ c_write_off.
* Nachricht: Datei enthält & Ausbuchungs-Positionen im Gesamtwert von &&
    IF h_anzza > 0.
      mac_appl_log_msg 'I' '>4' '827'
         h_anzza
         h_sumza t_fkkcollp_ip-waers space
         c_msgprio_info p_p_i_basics-appllog-probclass.
      SET EXTENDED CHECK OFF.
      IF 1 = 2. MESSAGE i827(>4). ENDIF.
      SET EXTENDED CHECK ON.
    ENDIF.
  ENDIF.

ENDFORM.                    " create_info_storno
*&---------------------------------------------------------------------*
*&      Form  get_tfk050i
*&---------------------------------------------------------------------*
FORM get_tfk050i.

  DATA:
    t_tfk050i TYPE tfk050i OCCURS 0 WITH HEADER LINE.

  SELECT * INTO TABLE t_tfk050i
           FROM tfk050i.
  LOOP AT t_tfk050i.
    CASE t_tfk050i-ictyp.
      WHEN '01'.
        g_fkkcollinfo-xcpart  = t_tfk050i-xcinf.
      WHEN '02'.
        g_fkkcollinfo-xausg   = t_tfk050i-xcinf.
      WHEN '03'.
        g_fkkcollinfo-xback   = t_tfk050i-xcinf.
      WHEN '04'.
        g_fkkcollinfo-xstorno = t_tfk050i-xcinf.
      WHEN '05'.
        g_fkkcollinfo-xreclr  = t_tfk050i-xcinf.
      WHEN '06'.
        g_fkkcollinfo-xretrn  = t_tfk050i-xcinf.
      WHEN '07'.
        g_fkkcollinfo-xrever  = t_tfk050i-xcinf.
      WHEN '08'.
        g_fkkcollinfo-xwroff  = t_tfk050i-xcinf.
    ENDCASE.
  ENDLOOP.

ENDFORM.                    " get_tfk050i
