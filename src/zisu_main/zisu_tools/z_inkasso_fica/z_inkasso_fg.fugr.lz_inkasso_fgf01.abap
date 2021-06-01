*----------------------------------------------------------------------*
***INCLUDE LZ_INKASSO_FGF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  DFKKOP_ENQUEUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM dfkkop_enqueue .

  CALL FUNCTION 'FKK_OPEN_ITEM_ENQUEUE'
    TABLES
      t_enqtab = ht_enqtab.

  READ TABLE ht_enqtab INDEX 1.

  IF NOT ht_enqtab-xenqe IS INITIAL.
* dequeue to refresh internal lock tables
    CALL FUNCTION 'FKK_OPEN_ITEM_DEQUEUE'.
    CLEAR okcode.
    MESSAGE e499(>3) WITH ht_enqtab-gpart ht_enqtab-uname.
  ENDIF.

  IF NOT ht_enqtab-xenqm IS INITIAL.
* dequeue to refresh internal lock tables
    CALL FUNCTION 'FKK_OPEN_ITEM_DEQUEUE'.
    CLEAR okcode.
    MESSAGE e500(>3) WITH ht_enqtab-gpart.
  ENDIF.


ENDFORM.                    " DFKKOP_ENQUEUE


*----------------------------------------------------------------------*
***INCLUDE LE31CF02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  check_no_display_1205
*&---------------------------------------------------------------------*
FORM check_no_display_1205  USING    p_postab  TYPE fkkepos
                            CHANGING p_do_not_display_line.

*Dont display budget billing payments already transferred
  IF  p_postab-astkz CA 'PZ'
  AND p_postab-augbl NE space
  AND p_postab-xanza EQ 'X'
  AND p_postab-augrd EQ '07'.
    p_do_not_display_line = 1.
    EXIT.
  ENDIF.

* don't display cleared collective bill documents with amount zero
* from the reversal of the invoicing
  IF p_postab-stakz = co_stakz_coll_bill_req
    AND p_postab-betrw = 0
    AND NOT p_postab-augst IS INITIAL
    AND p_postab-opbel = p_postab-augbl.
    p_do_not_display_line = 1.
    EXIT.
  ENDIF.

  DATA: h_count TYPE i.
* don't display collective bill documents which
* have amount equal zero and
* don't contain any items.
  IF p_postab-stakz = co_stakz_coll_bill_req
   AND p_postab-betrw = 0.

    CALL FUNCTION 'FKK_BP_LINE_ITEMS_SELECT'
      EXPORTING
        i_abwbl      = p_postab-opbel
        i_linecount  = 1
        i_count_flag = 'X'
      IMPORTING
        e_count      = h_count.
    IF h_count IS INITIAL.
      CALL FUNCTION 'FKK_REPEAT_LINE_ITEMS_SELECT'
        EXPORTING
          i_abwbl      = p_postab-opbel
          i_linecount  = 1
          i_count_flag = 'X'
        IMPORTING
          e_count      = h_count.
    ENDIF.
    IF h_count IS INITIAL.
      p_do_not_display_line = 1.
      EXIT.
    ENDIF.
  ENDIF.

* the following checks are not necessary for IS-T
  IF p_postab-applk <> co_applk_ist.
* JVL und ABS Zeilen mit AUGRD nicht beachten
    IF p_postab-augrd = co_augrd_jvl.
      p_do_not_display_line = 1.
      EXIT.
    ENDIF.
* Barzahler JVL-Zeile bei Ablauf der Zahlfrist nicht beachten
*  ermittle HVORG/TVORG des Barzahlerbelegs
    IF p_postab-stakz = co_stakz_bbp_req OR p_postab-stakz = 'Z'.
      DATA:  p_hvo  LIKE teivv-hvorg,
             p_tvo  LIKE teivv-tvorg,
             l_ejvl LIKE ejvl.

      CALL FUNCTION 'ISU_DB_TEIVV_SELECT'
        EXPORTING
          i_ihvor             = '0045'
          i_itvor             = '0030'
          i_applk             = 'R'
        IMPORTING
          e_hvorg             = p_hvo
          e_tvorg             = p_tvo
        EXCEPTIONS
          not_found           = 1
          int_trans_not_valid = 2
          trans_not_valid     = 3
          OTHERS              = 4.

      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
* Posten finden
      IF p_postab-hvorg = p_hvo
      AND p_postab-tvorg = p_tvo.
* wenn bezahlt, dann immer berücksichtigen
        IF NOT p_postab-augbl IS INITIAL.
          IF  p_postab-augbl <> p_postab-opbel
          AND p_postab-augrd <> '06'.
            EXIT.
          ENDIF.
        ENDIF.
* wenn Posten nicht mehr bezahlt werden kann, dann nicht mehr beachten
        CALL FUNCTION 'ISU_DB_EJVL_SINGLE'
          EXPORTING
            x_opbel      = p_postab-opbel
            x_vertrag    = p_postab-vtref
          IMPORTING
            y_ejvl       = l_ejvl
          EXCEPTIONS
            not_found    = 1
            system_error = 2
            OTHERS       = 3.
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.
* Posten nicht anzeigen, wenn Sy-Datum größer als Sperrdatum ist
        IF l_ejvl-fdate < sy-datum.
          p_do_not_display_line = 1.
          EXIT.
        ENDIF.
      ENDIF.
    ENDIF.
* Abschlagsanforderungen mit Betrag 0 nicht anzeigen
    IF p_postab-stakz = co_stakz_bbp_req
      AND p_postab-betrw = 0.
      p_do_not_display_line = 1.
      EXIT.
    ENDIF.

* umgebuchte Abschlagsanforderungen nicht anzeigen
    IF p_postab-stakz CA 'PZ' AND p_postab-augrd = '06'.
      p_do_not_display_line = 1.
      EXIT.
    ENDIF.


* gestoppte Abschlagspositionen nicht anzeigen
    IF ( p_postab-stakz CA 'PZ' OR p_postab-ori_stakz CA 'PZ' )
     AND p_postab-opbel = p_postab-augbl
     AND ( p_postab-augrd = co_augrd_stopped
      OR   p_postab-augrd = co_augrd_deact
      OR   p_postab-augrd = co_augrd_pc
      OR   p_postab-augrd = co_augrd_euro ).
      p_do_not_display_line = 1.
      EXIT.
    ENDIF.

  ENDIF. " not IS-T

* Deaktivierten Ratenplan nicht anzeigen
  IF (  p_postab-stakz = co_stakz_installments
     OR  p_postab-ori_stakz = co_stakz_installments )
     AND p_postab-opbel = p_postab-augbl
     AND p_postab-augrd = co_augrd_deact.
    p_do_not_display_line = 1.
    EXIT.
  ENDIF.

ENDFORM.                    " check_no_display_1205
*&---------------------------------------------------------------------*
*&      Form  fill_add_fields_1205
*&---------------------------------------------------------------------*
FORM fill_add_fields_1205  USING    p_langu      LIKE sy-langu
                                    p_header_arc TYPE fkkko
                           CHANGING p_postab     TYPE fkkepos.

  DATA:
        h_tfktvot LIKE tfktvot,
        h_tfkhvot LIKE tfkhvot,
        h_fkkvk   LIKE fkkvk,
        h_fkkko   LIKE fkkko,
        h_tfk033d LIKE tfk033d.

* local buffer for origin text
  DATA: BEGIN OF L_HTEXT OCCURS 5,
          HERKF TYPE HERKF_KK,
          HTEXT TYPE HTEXT_KK,
        END   OF L_HTEXT.

* fill physical existing items (FKKOP)
  IF p_postab-xzahl IS INITIAL.

    wa_hvtxt_buftab-hvorg = p_postab-hvorg.
    READ TABLE hvtxt_buftab FROM  wa_hvtxt_buftab
                             INTO wa_hvtxt_buftab.

    IF sy-subrc EQ 0.
      p_postab-hvtxt = wa_hvtxt_buftab-hvtxt.
    ELSE.
      CALL FUNCTION 'ISU_GET_ENTRY_FROM_TFKHVOT'
        EXPORTING
          x_spras   = p_langu
          x_applk   = p_postab-applk
          x_hvorg   = p_postab-hvorg
        IMPORTING
          y_tfkhvot = h_tfkhvot
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.

      IF sy-subrc = 0.
*        pi_postab-hvtxt = h_tfkhvot-txt30.
        p_postab-hvtxt = h_tfkhvot-txt30.
        wa_hvtxt_buftab-applk = p_postab-gpart.
        wa_hvtxt_buftab-hvorg = p_postab-hvorg.
        wa_hvtxt_buftab-hvtxt = p_postab-hvtxt.
        INSERT wa_hvtxt_buftab INTO TABLE hvtxt_buftab.
      ENDIF.
    ENDIF.
    CALL FUNCTION 'ISU_GET_TRANSACTION_TEXT'
      EXPORTING
        x_applk  = p_postab-applk
        x_spras  = p_langu
        x_bukrs  = p_postab-bukrs
        x_sparte = p_postab-spart
        x_hvorg  = p_postab-hvorg
        x_tvorg  = p_postab-tvorg
      IMPORTING
        h_votxt  = p_postab-votxt.
  ENDIF.

  IF p_postab-xzahl = 'X' .
    h_tfk033d-applk = p_postab-applk.
    IF p_postab-applk = co_applk_isu.
      h_tfk033d-buber = co_buber_r010.
    ELSEIF p_postab-applk = co_applk_ist.
      h_tfk033d-buber = co_buber_t010.
    ELSE.
      mac_msg_putx_wp co_msg_programming_error 898 'E9' 'APPLK'
                      p_postab-applk 'ISU_ACC_DISP_BASIC_LIST'
                                                          space space.
      IF 1 = 2.
* nur wegen Verwendungsnachweis
        MESSAGE a898(e9) WITH 'APPLK' p_postab-applk
                              'ISU_ACC_DISP_BASIC_LIST'.
      ENDIF.
    ENDIF.

* Get chart of accounts
    IF bufktopl IS INITIAL.
      CALL FUNCTION 'ISU_GET_CHART_OF_ACCOUNTS'
        EXPORTING
          x_bukrs      = p_postab-bukrs
        IMPORTING
          y_ktopl      = bufktopl
        EXCEPTIONS
          not_found    = 1
          system_error = 2
          OTHERS       = 3.
      IF sy-subrc = 1.
        mac_msg_putx co_msg_error sy-msgno sy-msgid
          sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 not_found.
      ELSEIF sy-subrc = 2.
        mac_msg_putx co_msg_error sy-msgno sy-msgid
          sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 not_found.
      ELSEIF sy-subrc <> 0.
        mac_msg_putx_wp co_msg_programming_error 898 'E9' 'sy-subrc'
                       sy-subrc 'ISU_ACC_DISP_BASIC_LIST_1205'
                                                     space space.
        IF 1 = 2.
* nur wegen Verwendungsnachweis
          MESSAGE a898(e9) WITH space space space space.
        ENDIF.
      ENDIF.
      h_tfk033d-ktopl = bufktopl.
    ELSE.
      h_tfk033d-ktopl = bufktopl.
    ENDIF.
    MOVE: p_postab-augrd  TO h_tfk033d-key01.


    CALL FUNCTION 'FKK_ACCOUNT_DETERMINE'
      EXPORTING
        i_tfk033d           = h_tfk033d
      IMPORTING
        e_tfk033d           = h_tfk033d
      EXCEPTIONS
        error_in_input_data = 1
        nothing_found       = 2
        OTHERS              = 3.

    IF sy-subrc = 0.
      p_postab-hvorg = h_tfk033d-fun01.
      p_postab-tvorg = h_tfk033d-fun02.
    ENDIF.

    CALL FUNCTION 'ISU_GET_ENTRY_FROM_TFKHVOT'
      EXPORTING
        x_spras   = p_langu
        x_applk   = p_postab-applk
        x_hvorg   = p_postab-hvorg
      IMPORTING
        y_tfkhvot = h_tfkhvot
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.

    IF sy-subrc = 0.
      p_postab-hvtxt = h_tfkhvot-txt30.
    ENDIF.

    CALL FUNCTION 'ISU_GET_ENTRY_FROM_TFKTVOT'
      EXPORTING
        x_spras   = p_langu
        x_applk   = p_postab-applk
        x_hvorg   = p_postab-hvorg
        x_tvorg   = p_postab-tvorg
      IMPORTING
        y_tfktvot = h_tfktvot
      EXCEPTIONS
        OTHERS    = 1.

    IF sy-subrc NE 0.
      CLEAR p_postab-votxt.
    ELSE.
      p_postab-votxt = h_tfktvot-txt30.
    ENDIF.
  ENDIF.

  IF p_postab-abwkt IS INITIAL AND
     p_postab-gpart NE g_gpart.
    CLEAR: vkont_buftab.
    REFRESH: vkont_buftab.
    g_gpart = p_postab-gpart.
  ENDIF.

  wa_vkont_buftab-gpart = p_postab-gpart.
  wa_vkont_buftab-vkont = p_postab-vkont.

  READ TABLE vkont_buftab INTO wa_vkont_buftab
                          WITH KEY gpart = p_postab-gpart
                                   vkont = p_postab-vkont
                             BINARY SEARCH.

  IF sy-subrc EQ 0.
    p_postab-vkbez = wa_vkont_buftab-vkbez.
  ELSE.
    CALL FUNCTION 'FKK_ACCOUNT_READ'
      EXPORTING
        i_vkont      = p_postab-vkont
      IMPORTING
        e_fkkvk      = h_fkkvk
      EXCEPTIONS
        not_found    = 1
        foreign_lock = 2
        OTHERS       = 3.

    IF sy-subrc EQ 0.
      p_postab-vkbez = h_fkkvk-vkbez.
      wa_vkont_buftab-gpart = p_postab-gpart.
      wa_vkont_buftab-vkont = p_postab-vkont.
      wa_vkont_buftab-vkbez = h_fkkvk-vkbez.
      INSERT wa_vkont_buftab INTO TABLE vkont_buftab.
    ENDIF.
  ENDIF.

* check optimizing setting (HANA)
  STATICS: LV_OPT_DET TYPE XFELD,            "optimizing determined?
           LV_OPT_ACT TYPE XFELD.            "optimizing active?
  DATA: lo_opt_settings TYPE REF TO if_fkk_optimization_settings.
  if lv_opt_det is initial.
    lo_opt_settings = cl_fkk_optimization_settings=>get_instance( ).
    case p_postab-applk.
      when 'R'.
        lv_opt_act = lo_opt_settings->is_active( cl_fkk_optimization_settings=>CC_ISU_ACCBAL_HEAD_MASS_FETCH ).
      when 'T'.
        lv_opt_act = lo_opt_settings->is_active( cl_fkk_optimization_settings=>CC_IST_ACCBAL_HEAD_MASS_FETCH ).
    endcase.
    lv_opt_det = 'X'.
  endif.

  IF wa_head_buftab-opbel NE p_postab-opbel.
    CLEAR wa_head_buftab. "new opbel=>new wa_head_buftab,cf.note 901895
    wa_head_buftab-opbel = p_postab-opbel.

*   for archived documents header data provided by framework
    CLEAR: h_fkkko.
    IF p_postab-xarch = 'X'.
      h_fkkko = p_header_arc.
    ELSE.
*   with optimization, DFKKKO is mass-read in event 1211 for all items
      if lv_opt_act is initial.
        CALL FUNCTION 'FKK_DOC_HEADER_SELECT_BY_OPBEL'
          EXPORTING
            i_opbel = p_postab-opbel
          IMPORTING
            e_fkkko = h_fkkko
          EXCEPTIONS
            OTHERS  = 1.
        IF sy-subrc <> 0.
          CLEAR h_fkkko.
        ENDIF.
*   do not read DFKKKO single mode, H_FKKKO stays initial for non-archived items
      ELSE.
      ENDIF.
    ENDIF.
    IF h_fkkko IS NOT INITIAL.
      wa_head_buftab-herkf = h_fkkko-herkf.
      IF wa_head_buftab-herkf = 'R4'
      OR wa_head_buftab-herkf = 'R5'
      OR wa_head_buftab-herkf = 'R6'.
        wa_head_buftab-xblnr = h_fkkko-xblnr.
      ENDIF.
      wa_head_buftab-cpudt = h_fkkko-cpudt.
      wa_head_buftab-cputm = h_fkkko-cputm.
      wa_head_buftab-ernam = h_fkkko-ernam.

      CLEAR wa_head_buftab-htext.

      IF LV_opt_act NE SPACE.
        READ TABLE L_HTEXT WITH KEY HERKF = H_FKKKO-HERKF.
        IF SY-SUBRC = 0.
          WA_HEAD_BUFTAB-HTEXT = L_HTEXT-HTEXT.
        ELSE.
          SELECT  SINGLE htext FROM  tfk001t INTO WA_HEAD_BUFTAB-HTEXT
            WHERE spras = sy-langu
            AND   herkf = H_FKKKO-HERKF.
          IF SY-SUBRC = 0.
            L_HTEXT-HERKF = H_FKKKO-HERKF.
            L_HTEXT-HTEXT = WA_HEAD_BUFTAB-HTEXT.
            APPEND L_HTEXT.
          ENDIF.
        ENDIF.
      ELSE.
        SELECT SINGLE htext FROM  tfk001t INTO wa_head_buftab-htext
         WHERE  spras       = p_langu
         AND    herkf       = wa_head_buftab-herkf.
      ENDIF.
    ENDIF.
  ENDIF.

  if lv_opt_act eq space
  or (     lv_opt_act ne space
       and p_postab-xarch ne space ).
    IF    wa_head_buftab-herkf = 'R4'
       OR wa_head_buftab-herkf = 'R5'
       OR wa_head_buftab-herkf = 'R6'.
      p_postab-xblnr = wa_head_buftab-xblnr.
    ELSE.
      p_postab-xblnr = p_postab-xblnr.
    ENDIF.
    p_postab-herkf = wa_head_buftab-herkf.
    p_postab-htext = wa_head_buftab-htext.
    p_postab-cpudt = wa_head_buftab-cpudt.
    p_postab-cputm = wa_head_buftab-cputm.
    p_postab-ernam_std = wa_head_buftab-ernam.
  endif.
*-----------------------------------------------------------------------
* don't display any payment if i_fkkl1-szahl is initial.
  IF wa_augrd_vorg_buffer IS INITIAL.
    CLEAR: h_tfk033d.
    h_tfk033d-key01 = '01'.
    h_tfk033d-applk = p_postab-applk.
    h_tfk033d-buber = '1091'.
    IF bufktopl IS INITIAL.
      CALL FUNCTION 'ISU_GET_CHART_OF_ACCOUNTS'
        EXPORTING
          x_bukrs      = p_postab-bukrs
        IMPORTING
          y_ktopl      = bufktopl
        EXCEPTIONS
          not_found    = 1
          system_error = 2
          OTHERS       = 3.
      IF sy-subrc = 1.
        mac_msg_putx co_msg_error sy-msgno sy-msgid
          sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 not_found.
      ELSEIF sy-subrc = 2.
        mac_msg_putx co_msg_error sy-msgno sy-msgid
          sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 not_found.
      ELSEIF sy-subrc <> 0.
        mac_msg_putx_wp co_msg_programming_error 898 'E9' 'sy-subrc'
                       sy-subrc 'ISU_ACC_DISP_BASIC_LIST_1205'
                                                     space space.
        IF 1 = 2.
* nur wegen Verwendungsnachweis
          MESSAGE a898(e9) WITH space space space space.
        ENDIF.
      ENDIF.
      h_tfk033d-ktopl = bufktopl.
    ELSE.
      h_tfk033d-ktopl = bufktopl.
    ENDIF.

    CALL FUNCTION 'FKK_ACCOUNT_DETERMINE'
      EXPORTING
        i_tfk033d           = h_tfk033d
      IMPORTING
        e_tfk033d           = h_tfk033d
      EXCEPTIONS
        error_in_input_data = 1
        nothing_found       = 2
        OTHERS              = 3.

    IF sy-subrc = 0.
      wa_augrd_vorg_buffer-hvorg = h_tfk033d-fun01.
      wa_augrd_vorg_buffer-tvorg = h_tfk033d-fun02.
    ENDIF.

  ENDIF.

ENDFORM.                    " fill_add_fields_1205
*&---------------------------------------------------------------------*
*&      Form  check_only_payment_list
*&---------------------------------------------------------------------*
*       check which items should only be displayed on payment list
*       but not on the receivables list
*----------------------------------------------------------------------*
FORM check_only_payment_list USING p_fkkl1        STRUCTURE fkkl1
                                   p_postab       STRUCTURE fkkepos
                                   p_payment_list TYPE boole-boole.

* Hide BBPlans and BBPayments which are invoiced already
  PERFORM check_old_bbp USING p_postab
                              p_payment_list.

* Cleared statistical positions
  PERFORM hide_cleared_stat_items USING p_fkkl1
                                        p_postab
                                        p_payment_list.

ENDFORM.                    " check_only_payment_list

*&---------------------------------------------------------------------*
*&     Form check_xeanz
*&---------------------------------------------------------------------*
*      unmark down payment (POSTAB-XEANZ) for main transaction 0270
*----------------------------------------------------------------------*
FORM check_xeanz  USING     p_postab       STRUCTURE fkkepos
                  CHANGING  e_postab       STRUCTURE fkkepos.

  DATA: wa_buffer_trans_list LIKE wa_invoice_trans.

  READ TABLE gt_buffer_trans_list INTO wa_buffer_trans_list
                                  WITH KEY applk = p_postab-applk
                                           hvorg = p_postab-hvorg
                                           tvorg = p_postab-tvorg
                                  BINARY SEARCH.

  IF sy-subrc <> 0.
    SELECT SINGLE * FROM tfkivv
    INTO wa_buffer_trans_list
    WHERE  applk = p_postab-applk
       AND hvorg = p_postab-hvorg
       AND tvorg = p_postab-tvorg.
    IF sy-subrc EQ 0.
      APPEND wa_buffer_trans_list TO gt_buffer_trans_list.
      SORT gt_buffer_trans_list BY applk hvorg tvorg.
    ENDIF.
  ENDIF.

  IF wa_buffer_trans_list-ihvor = co_ihv_umbufakt_cran.
    CLEAR e_postab-xeanz.
  ENDIF.


ENDFORM.                    "check_xeanz
*&---------------------------------------------------------------------*
*&      Form  DEREG_FIELDS
*&---------------------------------------------------------------------*
* INVOICING_PARTY füllen, falls ursprünglich ausgeglichene Positionen  *
* auch eine hatten. Ausgleich über mehrere Posten mit unterschied-     *
* licher Invoicing Party sollte nicht möglich sein. Ist die Invoicing  *
* Party gefüllt, so muss auch der Vertrag ergänzt werden.              *
*----------------------------------------------------------------------*
FORM dereg_fields USING pt_fkkop_ag TYPE fkkop_t
                        i_fkkop     TYPE fkkop
                        i_fkkko     TYPE fkkko
               CHANGING e_fkkopzf   TYPE fkkopzf
                        e_fkkopsf   TYPE fkkopsf.

  DATA: wa_fkkop_ag          TYPE fkkop,
        lv_inbound           TYPE xfeld,
        lv_outbound          TYPE xfeld,
        lv_agreement_inactiv TYPE xfeld,
        lv_initiator         TYPE e_deregsppartner,
        ls_param_inv_out     TYPE inv_param_inv_outbound,
        ls_pay_param         TYPE inv_param_inv_outbound_pay,
        ls_ever              TYPE ever.

  READ TABLE pt_fkkop_ag INTO wa_fkkop_ag INDEX 1.

  e_fkkopzf-invoicing_party = wa_fkkop_ag-invoicing_party.
  e_fkkopzf-ethppm          = wa_fkkop_ag-ethppm.
  e_fkkopzf-payfreqid       = wa_fkkop_ag-payfreqid.

  IF wa_fkkop_ag-invoicing_party IS INITIAL.
    EXIT.
  ENDIF.

  IF wa_fkkop_ag-vtref IS INITIAL.
    mac_msg_putx_we co_msg_error '061' 'EDER'
                                  wa_fkkop_ag-opbel
                                  wa_fkkop_ag-opupk
                                  wa_fkkop_ag-opupz
                                  wa_fkkop_ag-invoicing_party.
    IF 1 EQ 2. MESSAGE e061(eder) WITH space space space space. ENDIF.
  ENDIF.

  e_fkkopsf-vbund = i_fkkop-vbund.
  e_fkkopsf-vtref = i_fkkop-vtref.
  e_fkkopsf-spart = i_fkkop-spart.
  e_fkkopsf-kofiz = i_fkkop-kofiz.

  CLEAR ls_ever.
  CALL FUNCTION 'ISU_INTERNAL_VTREF_TO_VERTRAG'
    EXPORTING
      i_vtref   = wa_fkkop_ag-vtref
    IMPORTING
      e_vertrag = ls_ever-vertrag.
  CALL FUNCTION 'ISU_DB_EVER_SINGLE'
    EXPORTING
      x_vertrag = ls_ever-vertrag
    IMPORTING
      y_ever    = ls_ever.

  CALL FUNCTION 'ISU_DEREG_PARAM_INV_REM'
    EXPORTING
      x_process           = co_process_par_invoice_cust
      x_keydate           = i_fkkko-bldat
      x_ever_key          = ls_ever-vertrag
    IMPORTING
      y_param_inv_out     = ls_param_inv_out
      y_agreement_inactiv = lv_agreement_inactiv
    CHANGING
      xy_initiator        = lv_initiator
      xy_ever             = ls_ever
    EXCEPTIONS
      general_fault       = 1
      no_parameter_found  = 2
      internal_error      = 3
      OTHERS              = 4.
  IF sy-subrc NE 0.
    mac_msg_repeat_we co_msg_error.
  ENDIF.

  IF lv_agreement_inactiv EQ abap_false.
    READ TABLE ls_param_inv_out-pay_param INTO ls_pay_param
         WITH KEY servprov_pay = ls_ever-servprov_pay.
    IF sy-subrc NE 0.
      MESSAGE e610(edereg_inv) WITH ls_ever-servprov_pay
                                    lv_initiator.
    ENDIF.

    e_fkkopzf-ethppm    = ls_pay_param-thppm.
    e_fkkopzf-payfreqid = ls_pay_param-payfreqid.
  ENDIF.

ENDFORM.                    " DEREG_FIELDS

*----------------------------------------------------------------------*
***INCLUDE LE31CF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_TRANSACTION
*&---------------------------------------------------------------------*
FORM get_transaction CHANGING p_hvorg
                              p_tvorg.

  DATA: h_applk LIKE fkkko-applk.

  CALL FUNCTION 'FKK_GET_APPLICATION'
    IMPORTING
      e_applk          = h_applk
    EXCEPTIONS
      no_appl_selected = 1
      OTHERS           = 2.

  IF sy-subrc <> 0.
    mac_msg_putx_wp co_msg_error 858 '>3' space space space space
                sy-subrc.
    IF 1 = 2.  MESSAGE e858(>3). ENDIF. "cross reference only
  ENDIF.

  CALL FUNCTION 'ISU_DB_TEIVV_SELECT'
    EXPORTING
      i_ihvor       = co_ihv_abs
      i_itvor       = co_itv_abszahlum
      i_applk       = h_applk
    IMPORTING
      e_hvorg       = p_hvorg
      e_tvorg       = p_tvorg
*     E_TFKHVO      =
    EXCEPTIONS
      error_message = 1.
  IF sy-subrc NE 0.
* don't abort display with error message.
  ENDIF.

ENDFORM.                    " GET_TRANSACTION
*&---------------------------------------------------------------------*
*&      Form  te000_read
*&---------------------------------------------------------------------*
FORM te000_read USING  p_te000.

*  SELECT SINGLE * FROM te000 INTO p_te000.

  CALL FUNCTION 'ISU_DB_TE000_SINGLE'
    IMPORTING
      y_te000 = p_te000.

ENDFORM.                    " te000_read
*&---------------------------------------------------------------------*
*&      Form  fill_opbel
*&---------------------------------------------------------------------*
FORM fill_opbel  USING    p_erdb_opbel
                          p_text_004
                 CHANGING p_opbel.

  DATA: opbel_no_zero(13),
        opbel_left(13).

  CLEAR p_opbel.
  CLEAR opbel_no_zero.
  CLEAR opbel_left.

  WRITE p_erdb_opbel TO opbel_no_zero NO-ZERO.
  WRITE opbel_no_zero LEFT-JUSTIFIED TO opbel_left.

  p_opbel(12) = opbel_left.
  p_opbel+13(1) = p_text_004.

ENDFORM.                    " fill_opbel
*&---------------------------------------------------------------------*
*&      Form  invoice_trans_fill
*&---------------------------------------------------------------------*
FORM invoice_trans_fill USING p_applk.

  CHECK t_invoice_trans[] IS INITIAL.
  CHECK p_applk = 'R'.

  wa_invoice_trans-ihvor = co_ihv_vabr.                     "(0100).
  wa_invoice_trans-itvor = co_itv_xabrh.                    "(0010).
  APPEND wa_invoice_trans TO t_invoice_trans.

  wa_invoice_trans-ihvor = co_ihv_vabr.                     "(0100).
  wa_invoice_trans-itvor = co_itv_xabrs.                    "(0020).
  APPEND wa_invoice_trans TO t_invoice_trans.

  wa_invoice_trans-ihvor = co_ihv_sabr.                     "(0200).
  wa_invoice_trans-itvor = co_itv_xabrh.                    "(0010).
  APPEND wa_invoice_trans TO t_invoice_trans.

  wa_invoice_trans-ihvor = co_ihv_sabr.                     "(0200).
  wa_invoice_trans-itvor = co_itv_xabrs.                    "(0020).
  APPEND wa_invoice_trans TO t_invoice_trans.

  wa_invoice_trans-ihvor = co_ihv_umbufakt.                 "(0250).
  wa_invoice_trans-itvor = co_itv_umbu_fakth.               "(0010).
  APPEND wa_invoice_trans TO t_invoice_trans.

  wa_invoice_trans-ihvor = co_ihv_umbufakt.                 "(0250).
  wa_invoice_trans-itvor = co_itv_umbu_fakts.               "(0020).
  APPEND wa_invoice_trans TO t_invoice_trans.


  LOOP AT t_invoice_trans INTO wa_invoice_trans.
    CALL FUNCTION 'ISU_DB_TEIVV_SELECT'
      EXPORTING
        i_ihvor             = wa_invoice_trans-ihvor
        i_itvor             = wa_invoice_trans-itvor
        i_applk             = 'R'
      IMPORTING
        e_hvorg             = wa_invoice_trans-hvorg
        e_tvorg             = wa_invoice_trans-tvorg
      EXCEPTIONS
        not_found           = 1
        int_trans_not_valid = 2
        trans_not_valid     = 3
        OTHERS              = 4.
    MODIFY t_invoice_trans FROM wa_invoice_trans.
  ENDLOOP.

  PERFORM enhance_invoice_trans  IN PROGRAM zisu_eff IF FOUND "1095674
          CHANGING t_invoice_trans.

  LOOP AT t_invoice_trans INTO wa_invoice_trans
    WHERE ihvor = co_ihv_umbufakt.
    APPEND wa_invoice_trans TO t_inv_trans_guth.
  ENDLOOP.

ENDFORM.                    " invoice_trans_fill

*&---------------------------------------------------------------------*
*&      Form  invoice_trans_check
*&---------------------------------------------------------------------*
FORM invoice_trans_check  CHANGING  p_postab TYPE fkkepos.

  LOOP AT t_invoice_trans INTO wa_invoice_trans
    WHERE hvorg = p_postab-hvorg
      AND tvorg = p_postab-tvorg.
    EXIT.
  ENDLOOP.
  IF sy-subrc = 0.
*   Item is still open
    IF p_postab-augbl IS INITIAL.
      p_postab-x_lead_rg = 'X'.
    ENDIF.
*   Item is cleared, but not with itself and not cancelled
    IF NOT p_postab-augbl IS INITIAL   "
       AND p_postab-augbl_kk_rg NE p_postab-opbel_kk_rg
       AND p_postab-augrd NE '05'.
      p_postab-x_lead_rg = 'X'.
    ENDIF.
*   Item is cleared with itself but within a account maint.
    IF p_postab-augbl_kk_rg EQ p_postab-opbel_kk_rg
       AND p_postab-augrd = '08'.
      p_postab-x_lead_rg = 'X'.
    ENDIF.
*   Item is cleared within a cancellation -> check if it
*   was cleared with itself before
    IF p_postab-augrd = '05'
       AND p_postab-opupz EQ '000'.
      SELECT * FROM dfkkrapt
         INTO wa_dfkkrapt
          WHERE opbel = p_postab-opbel
            AND opupk = p_postab-opupk
            AND augrd = '07'
            AND augbl = p_postab-opbel.
        EXIT.
      ENDSELECT.
      IF sy-subrc NE 0.
        p_postab-x_lead_rg = 'X'.
      ENDIF.
    ENDIF.

*  Move line to T_LEAD_POSTAB and modify T_POSTAB_INV_HASH
    IF p_postab-x_lead_rg = 'X'.
      MOVE-CORRESPONDING p_postab TO wa_lead_postab.
      APPEND wa_lead_postab TO t_lead_postab.
      READ TABLE t_postab_inv_hash WITH KEY opbel = p_postab-opbel
                                       opupk = p_postab-opupk
                                       opupz = p_postab-opupz
                                       opupw = p_postab-opupw
                                       INTO wa_postab_inv.
      IF sy-subrc EQ 0.
        wa_postab_inv-x_lead_rg = 'X'.
        MODIFY TABLE t_postab_inv_hash FROM wa_postab_inv.
      ENDIF.

    ENDIF.
  ENDIF.
ENDFORM.                    " invoice_trans_check
*&---------------------------------------------------------------------*
*&      Form  determine_bel
*&---------------------------------------------------------------------*
FORM determine_bel  USING    i_bel
                             postab STRUCTURE fkkepos
                             x_augbl
                    CHANGING e_bel_kk_rg.

  DATA: h_erdb TYPE erdb,
        lt_ext_opbel TYPE tisu_arch_as_prdoch2_key,
        ls_ext_opbel LIKE LINE OF lt_ext_opbel.

  CLEAR wa_erdb.

* a) look in buffer table
  READ TABLE it_erdb WITH TABLE KEY invopbel = i_bel
                     INTO wa_erdb.

  IF sy-subrc NE 0.
* b) look in table erdb
    CALL FUNCTION 'ISU_S_ERDK_SELECT_DOC_KK'
      EXPORTING
        x_opbel   = i_bel
        x_herkf   = postab-herkf
      IMPORTING
        y_erdb    = h_erdb
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc EQ 0.
      MOVE-CORRESPONDING h_erdb TO wa_erdb.
      wa_erdb-gpart    = postab-gpart.
      INSERT wa_erdb INTO TABLE it_erdb.
    ELSE.
* c) look in archive (archiv index only)
      CALL FUNCTION 'ISU_ARCHIVE_AS_PRDOCH2_READ'
        EXPORTING
          im_invopbel = i_bel
*         IM_DIALOG   =
        IMPORTING
          ext_opbel   = lt_ext_opbel
        EXCEPTIONS
          OTHERS      = 1.

      IF sy-subrc EQ 0.
        CLEAR wa_erdb.
        LOOP AT lt_ext_opbel INTO ls_ext_opbel WHERE doc_id CN 'FPRZ'.
          EXIT.
        ENDLOOP.
        IF sy-subrc = 0.
          wa_erdb-invopbel = i_bel.
          wa_erdb-opbel    = ls_ext_opbel-opbel.
          wa_erdb-doc_id   = ls_ext_opbel-doc_id.
          wa_erdb-gpart    = postab-gpart.
          INSERT wa_erdb INTO TABLE it_erdb.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF wa_erdb IS NOT INITIAL.
* anything found?
    PERFORM fill_opbel_and_postab_inv USING  wa_erdb-opbel
                                             text-009
                                             postab
                                             x_augbl
                                    CHANGING e_bel_kk_rg.
  ELSE.
    e_bel_kk_rg = i_bel.
  ENDIF.
ENDFORM.                    " determine_bel
*&---------------------------------------------------------------------*
*&      Form  hide_old_bbp
*&---------------------------------------------------------------------*
FORM hide_old_bbp USING  postab STRUCTURE fkkepos
                         e_only_show_in_payment_list TYPE xfeld.

  IF wa_eabp-gpart NE postab-gpart.
    REFRESH it_eabp.
  ENDIF.
* abgerechnete Apläne und Zahlungen ausblenden >>>
* Abschlagsplan:
  IF postab-stakz CA 'PZ'.

    IF wa_eabp-opbel NE postab-opbel OR
       wa_eabp-vtref NE postab-vtref.
      LOOP AT it_eabp INTO wa_eabp
        WHERE opbel = postab-opbel
          AND vtref = postab-vtref.
      ENDLOOP.
      IF sy-subrc NE 0.
        CALL FUNCTION 'ISU_INTERNAL_VTREF_TO_VERTRAG'
          EXPORTING
            i_vtref   = postab-vtref
            i_subap   = postab-subap
          IMPORTING
            e_vertrag = i_eabp_vtref.

        SELECT SINGLE opbel gpart deaktiv FROM eabp
               INTO CORRESPONDING FIELDS OF wa_eabp
          WHERE opbel   = postab-opbel
            AND vertrag = i_eabp_vtref.
        IF sy-subrc EQ 0.
          wa_eabp-vtref = postab-vtref.
          APPEND wa_eabp TO it_eabp.
        ELSE.
          CLEAR wa_eabp.
          wa_eabp-gpart = postab-gpart.
        ENDIF.
      ENDIF.
    ENDIF.

    IF NOT wa_eabp-deaktiv IS INITIAL.
      e_only_show_in_payment_list = 1.
    ENDIF.
  ENDIF.
* Generierte Zahlungszeile
  IF postab-ori_stakz CA 'PZ'
     AND postab-xzahl = 'X'
     AND postab-xanza = 'X'
     AND postab-augst = '9'
     AND ( postab-augrd = '01' OR
           postab-augrd = '07' OR
           postab-augrd = '08' OR
           postab-augrd = '15' ).

*   im Feld CDOCN steht die Nummer das Abschlagsplans
    IF wa_eabp-opbel NE postab-cdocn OR
       wa_eabp-vtref NE postab-vtref.
      LOOP AT it_eabp INTO wa_eabp
          WHERE opbel = postab-cdocn
            AND vtref = postab-vtref.
      ENDLOOP.
      IF sy-subrc NE 0.

        CALL FUNCTION 'ISU_INTERNAL_VTREF_TO_VERTRAG'
          EXPORTING
            i_vtref   = postab-vtref
            i_subap   = postab-subap
          IMPORTING
            e_vertrag = i_eabp_vtref.

        SELECT SINGLE opbel gpart deaktiv FROM eabp
               INTO CORRESPONDING FIELDS OF wa_eabp
          WHERE opbel   = postab-cdocn
            AND vertrag = i_eabp_vtref.
        IF sy-subrc EQ 0.
          wa_eabp-vtref = postab-vtref.
          APPEND wa_eabp TO it_eabp.
        ELSE.
          CLEAR wa_eabp.
          wa_eabp-gpart = postab-gpart.
        ENDIF.
      ENDIF.
    ENDIF.
    IF NOT wa_eabp-deaktiv IS INITIAL.
      e_only_show_in_payment_list = 1.
    ENDIF.
* Append this line to T_ZEROCL if it is part of a zeroclearing -> find
* the corresponding line in Event 1211 and clear XZCLR
    IF NOT postab-xzclr IS INITIAL.
      MOVE postab TO wa_zerocl.
      APPEND wa_zerocl TO t_zerocl.
      CLEAR postab-xzclr.
    ENDIF.

  ENDIF.

ENDFORM.                    " hide_old_bbp
*&---------------------------------------------------------------------*
*&      Form  merge_postab_inv_postab
*&---------------------------------------------------------------------*
FORM merge_postab_inv_postab TABLES   t_postab STRUCTURE fkkepos.

  REFRESH t_opbel_kk_rg.
  REFRESH t_postab_inv_help.
  CHECK NOT t_postab_inv[] IS INITIAL.
  t_postab_inv_save[] = t_postab_inv[].
* For the further processing it is only interesting to know it the
* invoice is cancelled or not
* -> Fill table T_OPBEL_KK_RG
  LOOP AT t_postab_inv INTO wa_postab_inv.
    MOVE wa_postab_inv-opbel_kk_rg TO wa_opbel_kk_rg-opbel.
    MOVE wa_postab_inv-herkf       TO wa_opbel_kk_rg-herkf.
    IF NOT wa_postab_inv-x_lead_rg IS INITIAL.
      MOVE '1' TO wa_opbel_kk_rg-h_count.
    ELSE.
      CLEAR wa_opbel_kk_rg-h_count.
    ENDIF.
    CLEAR wa_opbel_kk_rg-augrd.
    IF wa_postab_inv-augrd = '05'.
      MOVE wa_postab_inv-augrd       TO wa_opbel_kk_rg-augrd.
    COLLECT wa_opbel_kk_rg INTO t_opbel_kk_rg.
    ENDIF.
  ENDLOOP.

* Find the entries in T_POSTAB and move to T_POSTAB_INV_HELP
  REFRESH t_postab_inv_help.
  LOOP AT t_opbel_kk_rg INTO wa_opbel_kk_rg.
    IF wa_opbel_kk_rg-augrd = '05'.
      LOOP AT t_postab
         WHERE opbel_kk_rg = wa_opbel_kk_rg-opbel
           AND herkf       = wa_opbel_kk_rg-herkf
           AND augrd = '05'.
        wa_postab_inv_help = t_postab.
        APPEND wa_postab_inv_help TO t_postab_inv_help.
      ENDLOOP.
    ELSE.
      LOOP AT t_postab
         WHERE opbel_kk_rg = wa_opbel_kk_rg-opbel
           AND herkf       = wa_opbel_kk_rg-herkf
           AND augrd NE '05'.
        wa_postab_inv_help = t_postab.
        APPEND wa_postab_inv_help TO t_postab_inv_help.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

* Move them to T_POSTAB_INV again
  REFRESH t_postab_inv.
  LOOP AT t_postab_inv_help INTO wa_postab_inv_help.
    APPEND wa_postab_inv_help TO t_postab_inv..
  ENDLOOP.

* Adjust T_LEAD_POSTAB as well
  REFRESH t_lead_postab.
  LOOP AT t_postab_inv_help INTO wa_postab_inv_help
    WHERE x_lead_rg = 'X'.
    APPEND wa_postab_inv_help TO t_lead_postab.
  ENDLOOP.
  REFRESH t_postab_inv_help.

ENDFORM.                    " merge_postab_inv_postab
*&---------------------------------------------------------------------*
*&      Form  condense_fakt
*&---------------------------------------------------------------------*
FORM condense_fakt TABLES   t_postab STRUCTURE fkkepos.

  DATA: x_handle TYPE boole-boole.

*Adjust T_POSTAB from T_POSTAB_INV, T_LEAD_POSTAB and T_POSTAB_NEW
  PERFORM adjust_t_postab TABLES  t_postab.


* condensation didn't really wokr, to many different cases of invoice
* -> coding deleted!!!!!!

ENDFORM.                    " condense_fakt
*&---------------------------------------------------------------------*
*&      Form  check_old_bbp
*&---------------------------------------------------------------------*
FORM check_old_bbp  USING    i_postab
                             e_only_show_in_payment_list TYPE xfeld.
  IF x_read_r011 IS INITIAL.
    PERFORM read_buber_r011 CHANGING x_no_old_bbp.
    x_read_r011 = 'X'.
  ENDIF.

  IF x_no_old_bbp = 'X'.
    PERFORM hide_old_bbp USING i_postab
                               e_only_show_in_payment_list.
  ENDIF.

ENDFORM.                    " check_old_bbp
*&---------------------------------------------------------------------*
*&      Form  read_buber_r011
*&---------------------------------------------------------------------*
FORM read_buber_r011  CHANGING p_x_no_old_bbp.

  DATA: wa_tfk033d  TYPE tfk033d.

  wa_tfk033d-applk = co_applk_isu.
  wa_tfk033d-buber = 'R011'.
  CALL FUNCTION 'FKK_ACCOUNT_DETERMINE'
    EXPORTING
      i_tfk033d           = wa_tfk033d
    IMPORTING
      e_tfk033d           = wa_tfk033d
    EXCEPTIONS
      error_in_input_data = 1
      nothing_found       = 2
      OTHERS              = 3.

  IF sy-subrc = 0.
    IF wa_tfk033d-fun01 = 'X'.
      x_no_old_bbp = 'X'.
    ELSE.
      CLEAR x_no_old_bbp.
    ENDIF.
  ENDIF.

* call dummy function for where-used list
  IF 1 = 2.
    CALL FUNCTION 'FKK_ACCOUNT_DETERMINE_R011'.
  ENDIF.

ENDFORM.                    " read_buber_r011

*&---------------------------------------------------------------------*
*&      Form  hide_cleared_stat_items
*&---------------------------------------------------------------------*
FORM hide_cleared_stat_items USING    i_fkkl1 STRUCTURE fkkl1
                                      i_postab STRUCTURE fkkepos
                                      payment_list TYPE boole-boole.

  IF i_fkkl1-stakno = 'X'
      AND ( i_fkkl1-stakg = 'X' OR i_fkkl1-stak = 'X' ).
    IF i_postab-stakz IS INITIAL AND i_postab-astkz = 'G'.

      IF i_postab-opbel EQ i_postab-augbl
        OR i_postab-xzahl = 'X'.
        CHECK i_postab-augrd NE '05'.
        CHECK i_postab-augrd NE '10'.
        CHECK i_postab-augrd NE '11'.
        CHECK i_postab-augrd NE '14'.
        CHECK i_postab-augrd NE '04'.
        payment_list = 1.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " hide_cleared_stat_items
*&---------------------------------------------------------------------*
*&      Form  fill_opbel_kk_rg
*&---------------------------------------------------------------------*
FORM fill_opbel_kk_rg USING i_postab STRUCTURE fkkepos
                            e_postab STRUCTURE fkkepos.

  IF wa_erdb-gpart NE i_postab-gpart.
    REFRESH: it_erdb, t_lead_postab, t_postab_inv.
  ENDIF.
* only relevant for invoicing documents
  IF e_postab-herkf  = 'R4'
    OR e_postab-herkf = 'R9'
    OR e_postab-herkf = 'R6'
    OR e_postab-herkf = 'R5'
    OR e_postab-herkf = 'RF'.
    PERFORM determine_bel USING i_postab-opbel
                                e_postab
                                ' '
                          CHANGING e_postab-opbel_kk_rg.
  ELSE.
    e_postab-opbel_kk_rg = i_postab-opbel.
  ENDIF.

ENDFORM.                    " fill_opbel_kk_rg
*&---------------------------------------------------------------------*
*&      Form  fill_opbel_and_postab_inv
*&---------------------------------------------------------------------*
FORM fill_opbel_and_postab_inv USING    wa_erbb_opbel
                                        text_009
                                        postab STRUCTURE fkkepos
                                        x_augbl
                               CHANGING e_bel_kk_rg.

  PERFORM fill_opbel USING    wa_erdb-opbel
                              text-009
                     CHANGING e_bel_kk_rg.

  IF x_augbl IS INITIAL.
    CHECK postab-xeanz IS INITIAL. "for event 1211, no real
    "Downpayments in T_POSTAB_INV
    wa_postab_inv = postab.
    INSERT wa_postab_inv INTO TABLE t_postab_inv_hash.
  ENDIF.

ENDFORM.                    " fill_opbel_and_postab_inv
*&---------------------------------------------------------------------*
*&      Form  fill_augbl_kk_rg
*&---------------------------------------------------------------------*
FORM fill_augbl_kk_rg USING    i_postab STRUCTURE fkkepos
                               e_postab STRUCTURE fkkepos.

  IF NOT e_postab-augbl IS INITIAL.
    IF e_postab-applk = 'R'.
*     only for invoicing documents
      IF e_postab-augrd = '07'
        OR e_postab-augrd = '08'
        OR e_postab-augrd = '05'
        OR e_postab-augrd = '03'.
        PERFORM determine_bel USING i_postab-augbl
                                    e_postab
                                    'X'
                                    CHANGING e_postab-augbl_kk_rg.
      ELSE.
        e_postab-augbl_kk_rg = e_postab-augbl.
      ENDIF.
    ELSE.
      e_postab-augbl_kk_rg = e_postab-augbl.
    ENDIF.
  ENDIF.

ENDFORM.                    " fill_augbl_kk_rg
*&---------------------------------------------------------------------*
*&      Form  delete_diverse
*&---------------------------------------------------------------------*
FORM delete_diverse TABLES t_postab STRUCTURE fkkepos
                     USING p_xfakt  TYPE xflag.

  PERFORM delete_absza.

  PERFORM delete_cancelled_inv.

* delete account maintenance ( only if xfakt = 'X'.)
  IF NOT p_xfakt IS INITIAL.
    PERFORM delete_acc_maint.
  ENDIF.

  PERFORM delete_rest.

ENDFORM.                    " delete_diverse
*&---------------------------------------------------------------------*
*&      Form  delete_absza
*&---------------------------------------------------------------------*
FORM delete_absza .
  DATA: wa_postab_absumb LIKE fkkepos.
  DATA: t_postab_absumb_old LIKE fkkepos OCCURS 0,
        t_postab_absumb_new LIKE fkkepos OCCURS 0.

  CHECK NOT t_postab_inv[] IS INITIAL.

* check if invoice has new layout or not
  DATA: h_new_inv TYPE xflag.
  DATA: t_bill_hvorg TYPE TABLE OF tfkhvo.

  CALL FUNCTION 'ISU_DB_GET_HVORG_FOR_BILLING'
    TABLES
      t_tfkhvo = t_bill_hvorg
    EXCEPTIONS
      OTHERS   = 1.
  IF sy-subrc <> 0.
    REFRESH t_bill_hvorg.
  ENDIF.

  LOOP AT t_opbel_kk_rg INTO wa_opbel_kk_rg
    WHERE augrd NE '05'.
    REFRESH: t_postab_absumb_new, t_postab_absumb_old.
    h_new_inv = 'X'.

*   delete all lines with clearing reason 07
*   except for actual consumption bill items (HVORG 100, 200, 300)
    LOOP AT t_postab_inv INTO wa_postab_inv
          WHERE opbel_kk_rg EQ wa_opbel_kk_rg-opbel
            AND augrd     = '07'
            AND x_lead_rg NE 'X'.
*     check layout
      PERFORM check_new_inv USING   wa_postab_inv
                           CHANGING h_new_inv.

*     store entries if new layout of documents
      IF wa_postab_inv-xzahl = space.
        READ TABLE t_bill_hvorg TRANSPORTING NO FIELDS
                                WITH KEY hvorg = wa_postab_inv-hvorg.
        IF sy-subrc <> 0.
          APPEND wa_postab_inv TO t_postab_absumb_new.
        ENDIF.
      ENDIF.
*     store entriesold layout documents
      READ TABLE t_invoice_trans INTO wa_invoice_trans
           WITH KEY hvorg = wa_postab_inv-hvorg
                    tvorg = wa_postab_inv-tvorg.
      IF sy-subrc = 0.
        APPEND wa_postab_inv TO t_postab_absumb_old.
      ENDIF.
    ENDLOOP.
*   depending of layout of document, eliminate different items
    IF h_new_inv = 'X'.
*     Get the corresponding payment lines from t_postab_inv
      LOOP AT t_postab_absumb_new INTO wa_postab_absumb.
        LOOP AT t_postab_inv INTO wa_postab_inv
           WHERE orino_ref EQ wa_postab_absumb-orino
             AND xzclr     IS INITIAL.
*         Move both lines to t_postab_inv_help
          APPEND wa_postab_absumb TO t_postab_inv_help.
          APPEND wa_postab_inv TO t_postab_inv_help.
        ENDLOOP.
      ENDLOOP.
    ELSE.
*     Get the corresponding payment lines from t_postab_inv
      LOOP AT t_postab_absumb_old INTO wa_postab_absumb
        WHERE NOT orino IS INITIAL.
        LOOP AT t_postab_inv INTO wa_postab_inv
           WHERE orino_ref EQ wa_postab_absumb-orino
             AND xzclr     IS INITIAL.
*         Move both lines to t_postab_inv_help
          APPEND wa_postab_absumb TO t_postab_inv_help.
          APPEND wa_postab_inv TO t_postab_inv_help.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " delete_absza
*&---------------------------------------------------------------------*
*&      Form  delete_cancelled_inv
*&---------------------------------------------------------------------*
FORM delete_cancelled_inv .
  DATA: wa_postab_canc TYPE fkkepos,
         t_postab_canc TYPE fkkepos OCCURS 0.

  CHECK NOT t_postab_inv[] IS INITIAL.
* find the right line of the invoice: it was cleared by itself before
  LOOP AT t_opbel_kk_rg INTO wa_opbel_kk_rg
    WHERE augrd EQ '05'
      AND herkf EQ 'R4'.

    REFRESH: t_postab_canc.

    LOOP AT t_postab_inv INTO wa_postab_inv
       WHERE opbel_kk_rg EQ wa_opbel_kk_rg-opbel
               AND xragl EQ 'X'.

      READ TABLE t_invoice_trans INTO wa_invoice_trans
                 WITH KEY hvorg = wa_postab_inv-hvorg
                          tvorg = wa_postab_inv-tvorg.
      IF sy-subrc = 0.
* Was it cleared with itself before???
        SELECT * FROM dfkkrapt
           INTO wa_dfkkrapt
           WHERE opbel = wa_postab_inv-opbel
             AND opupk = wa_postab_inv-opupk.
          IF wa_dfkkrapt-augrd = '07' AND
             wa_dfkkrapt-augbl = wa_postab_inv-opbel.
            APPEND wa_postab_inv TO t_postab_canc.
          ENDIF.
          EXIT.
        ENDSELECT.
      ENDIF.
    ENDLOOP.

* Get the corresponding line of the clearing document
    LOOP AT t_postab_canc INTO wa_postab_canc.
      LOOP AT t_postab_inv INTO wa_postab_inv
        WHERE orino_ref EQ wa_postab_canc-orino.
* Move both lines to t_postab_inv_help
        APPEND wa_postab_canc TO t_postab_inv_help.
        APPEND wa_postab_inv TO t_postab_inv_help.
      ENDLOOP.
    ENDLOOP.
  ENDLOOP.

ENDFORM.                    " delete_cancelled_inv
*&---------------------------------------------------------------------*
*&      Form  delete_acc_maint
*&---------------------------------------------------------------------*
FORM delete_acc_maint.

  DATA: wa_postab_inv_hp TYPE fkkepos.
  DATA: t_postab_inv_hp TYPE fkkepos OCCURS 0.
  DATA: BEGIN OF wa_postab_collect.
  DATA: opbe_kk_rg TYPE opbel_kk_rg,
        betrw TYPE betrw_kk.
  DATA: END OF wa_postab_collect.
  DATA: t_postab_collect LIKE wa_postab_collect OCCURS 0.

  CHECK NOT t_postab_inv[] IS INITIAL.
  LOOP AT t_opbel_kk_rg INTO wa_opbel_kk_rg
    WHERE augrd NE '05'
    AND   h_count GT '1' .

    LOOP AT t_postab_inv INTO wa_postab_inv
      WHERE opbel_kk_rg EQ wa_opbel_kk_rg-opbel
        AND x_lead_rg EQ 'X'
        AND augrd EQ '08'.
*        and opupz ne '000'.
      IF wa_postab_inv-opbel_kk_rg NE wa_postab_inv-augbl_kk_rg.
        CONTINUE.
      ELSE.
        APPEND wa_postab_inv TO t_postab_inv_hp.
      ENDIF.
    ENDLOOP.

    LOOP AT t_postab_inv_hp INTO wa_postab_inv_hp.
      LOOP AT t_postab_inv INTO wa_postab_inv
        WHERE orino_ref    = wa_postab_inv_hp-orino
          AND opbel_kk_rg  = wa_postab_inv-opbel_kk_rg.
        IF wa_postab_inv-xzclr = 'X'.
          MOVE wa_postab_inv TO wa_zerocl.
          APPEND wa_zerocl TO t_zerocl.
          CLEAR wa_postab_inv-xzclr.
          MODIFY t_postab_inv FROM wa_postab_inv.
        ENDIF.
        APPEND wa_postab_inv TO t_postab_inv_help.
        APPEND wa_postab_inv_hp TO t_postab_inv_help.
        EXIT.
      ENDLOOP.
    ENDLOOP.

* Handle the following situation:
* 0250 0010  2.994,76-  open
* Acct.Maint 1.005,24-  Zero Clearing  ORINOREF 40
* 0100 0010  1.005,24                  ORINO    40    DELETE
* Acct.Maint 1.005,24   Zero Clearing  ORINOREF 41
* 0250 0010  1.005,24-                 ORINO    41    DELETE
    REFRESH t_postab_inv_hp.
    LOOP AT t_postab_inv INTO wa_postab_inv
       WHERE opbel_kk_rg EQ wa_opbel_kk_rg-opbel
         AND x_lead_rg EQ 'X'
         AND augrd EQ '08'.
      IF wa_postab_inv-opbel_kk_rg NE wa_postab_inv-augbl_kk_rg.
        CONTINUE.
      ELSE.
        APPEND wa_postab_inv TO t_postab_inv_hp.
      ENDIF.
    ENDLOOP.

    LOOP AT t_postab_inv_hp INTO wa_postab_inv_hp.
      MOVE-CORRESPONDING wa_postab_inv_hp TO wa_postab_collect.
      COLLECT wa_postab_collect INTO t_postab_collect.
    ENDLOOP.
  ENDLOOP.

  CHECK NOT t_postab_collect[] IS INITIAL.
  READ TABLE t_postab_collect INDEX 1 INTO wa_postab_collect.
  IF wa_postab_collect-betrw IS INITIAL.
    APPEND LINES OF t_postab_inv_hp TO t_postab_inv_help.
  ENDIF.

ENDFORM.                    " delete_acc_maint

*&---------------------------------------------------------------------*
*&      Form  adjust_zerocl
*&---------------------------------------------------------------------*
FORM adjust_zerocl TABLES t_postab STRUCTURE fkkepos.

  DATA: h_betrw LIKE dfkkop-betrw.
  CLEAR: h_betrw.    "note 646711
  LOOP AT t_zerocl INTO wa_zerocl.
    LOOP AT t_postab
      WHERE augbl = wa_zerocl-augbl
        AND xzclr = 'X'
        AND xzahl = 'X'
        AND x1205 = ' '.
      h_betrw = h_betrw + t_postab-betrw.
      t_postab-xzclr = 'T'.
      MODIFY t_postab.
    ENDLOOP.
    IF h_betrw = 0.
      CLEAR t_postab-xzclr.
      MODIFY t_postab TRANSPORTING xzclr WHERE xzclr = 'T'.
    ELSE.
      LOOP AT t_postab
        WHERE augbl = wa_zerocl-augbl.
        CLEAR t_postab-xzclr.
        MODIFY t_postab.
      ENDLOOP.
    ENDIF.

    CLEAR h_betrw.
    LOOP AT t_postab_inv INTO wa_postab_inv
      WHERE augbl = wa_zerocl-augbl
        AND xzclr = 'X'
        AND xzahl = 'X'
        AND x1205 = ' '.
      h_betrw = h_betrw + wa_postab_inv-betrw.
      wa_postab_inv-xzclr = 'T'.
      MODIFY t_postab_inv FROM wa_postab_inv.
    ENDLOOP.
    IF h_betrw = 0.
      CLEAR wa_postab_inv-xzclr.
      MODIFY t_postab_inv FROM wa_postab_inv
          TRANSPORTING xzclr WHERE xzclr = 'T'.
    ELSE.
      LOOP AT t_postab_inv INTO wa_postab_inv
        WHERE augbl = wa_zerocl-augbl.
        CLEAR wa_postab_inv-xzclr.
        MODIFY t_postab_inv FROM wa_postab_inv.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " adjust_zerocl
*&---------------------------------------------------------------------*
*&      Form  delete_postab
*&---------------------------------------------------------------------*
FORM delete_postab TABLES  t_postab STRUCTURE fkkepos.

  CHECK NOT t_postab_inv_help[] IS INITIAL.
  LOOP AT t_postab_inv_help INTO wa_postab_inv_help.
    IF NOT wa_postab_inv_help-orino IS INITIAL.
      LOOP AT t_postab
        WHERE orino = wa_postab_inv_help-orino.
        DELETE t_postab.
        EXIT.
      ENDLOOP.
    ELSE.
      LOOP AT t_postab
        WHERE orino_ref = wa_postab_inv_help-orino_ref.
        DELETE t_postab.
        EXIT.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " delete_postab
*&---------------------------------------------------------------------*
*&      Form  delete_postab_inv
*&---------------------------------------------------------------------*
FORM delete_postab_inv .

  DATA: t_pos_help TYPE fkkepos OCCURS 0 WITH HEADER LINE.

  CHECK NOT t_postab_inv_help[] IS INITIAL.
  t_pos_help[] = t_postab_inv_help.

  LOOP AT t_postab_inv_help INTO wa_postab_inv_help
    WHERE xzclr IS INITIAL.
    IF NOT wa_postab_inv_help-orino IS INITIAL.
      READ TABLE t_pos_help
          WITH KEY orino_ref = wa_postab_inv_help-orino.
      IF sy-subrc EQ 0.
        LOOP AT t_postab_inv INTO wa_postab_inv
          WHERE orino = wa_postab_inv_help-orino.
          DELETE TABLE t_postab_inv FROM wa_postab_inv.
          EXIT.
        ENDLOOP.
      ENDIF.
    ELSE.
      LOOP AT t_postab_inv INTO wa_postab_inv
        WHERE orino_ref = wa_postab_inv_help-orino_ref.
        DELETE TABLE t_postab_inv FROM wa_postab_inv.
        EXIT.
      ENDLOOP.
    ENDIF.
    IF wa_postab_inv_help-x_lead_rg ='X'.
      IF NOT wa_postab_inv_help-orino IS INITIAL.
       READ TABLE t_lead_postab INTO wa_lead_postab
         WITH KEY orino = wa_postab_inv_help-orino.
      ELSE.
       READ TABLE t_lead_postab INTO wa_lead_postab
        WITH KEY orino_ref = wa_postab_inv_help-orino_ref.
      ENDIF.
      DELETE TABLE t_lead_postab FROM wa_lead_postab.
    ENDIF.
  ENDLOOP.

  REFRESH t_postab_inv_help.

ENDFORM.                    " delete_postab_inv
*&---------------------------------------------------------------------*
*&      Form  fakt_kum
*&---------------------------------------------------------------------*
FORM fakt_kum TABLES t_postab STRUCTURE fkkepos.

  PERFORM del_couples.
  PERFORM del_couples_canc.
* Find the entries in T_POSTAB_INV and delete them
  PERFORM delete_postab_inv.
* Condense the rest
  PERFORM condense_fakt TABLES t_postab.

ENDFORM.                    " fakt_kum
*&---------------------------------------------------------------------*
*&      Form  del_couples
*&---------------------------------------------------------------------*
FORM del_couples.

  DATA: wa_h_postab TYPE fkkepos,
          t_h_postab TYPE fkkepos OCCURS 0.

  CHECK NOT t_postab_inv IS INITIAL.
  t_h_postab[] = t_postab_inv.

  LOOP AT t_opbel_kk_rg INTO wa_opbel_kk_rg
    WHERE augrd NE '05'.

    LOOP AT t_postab_inv INTO wa_postab_inv
      WHERE NOT orino_ref IS INITIAL
        AND opbel_kk_rg   EQ wa_opbel_kk_rg-opbel
        AND xzclr         IS INITIAL.
      LOOP AT t_h_postab INTO wa_h_postab
        WHERE orino       = wa_postab_inv-orino_ref
          AND opbel_kk_rg = wa_postab_inv-opbel_kk_rg
          AND x_lead_rg   IS INITIAL.
        MOVE-CORRESPONDING wa_h_postab TO wa_postab_inv_help.
        APPEND wa_postab_inv_help TO t_postab_inv_help.
        MOVE-CORRESPONDING wa_postab_inv TO wa_postab_inv_help.
        APPEND wa_postab_inv_help TO t_postab_inv_help.
        EXIT.
      ENDLOOP.
    ENDLOOP.
  ENDLOOP.

ENDFORM.                    " del_couples
*&---------------------------------------------------------------------*
*&      Form  del_couples_canc
*&---------------------------------------------------------------------*
FORM del_couples_canc.

  DATA: wa_canc_help TYPE fkkepos,
          t_canc_help TYPE fkkepos OCCURS 0.
  DATA: wa_canc_lead TYPE fkkepos.
  DATA: t_canc_lead TYPE fkkepos OCCURS 0.

  CHECK NOT t_postab_inv[] IS INITIAL.
* Find the first line: X_LEAD_RG must be set!!
  LOOP AT t_opbel_kk_rg INTO wa_opbel_kk_rg
    WHERE augrd     EQ '05'
      AND herkf     EQ 'R4'.

    REFRESH t_canc_help.
    REFRESH t_canc_lead.
    LOOP AT t_postab_inv INTO wa_postab_inv
       WHERE opbel_kk_rg EQ wa_opbel_kk_rg-opbel
         AND x_lead_rg   EQ 'X'.

      APPEND wa_postab_inv TO t_canc_help.
      EXIT.
    ENDLOOP.

* Get the corresponding line of the clearing document
    LOOP AT t_canc_help INTO wa_canc_help.
      LOOP AT t_postab_inv INTO wa_postab_inv
        WHERE orino_ref EQ wa_canc_help-orino.
* Move both lines to t_postab_inv_help
        APPEND wa_canc_help  TO t_canc_lead.
        APPEND wa_postab_inv TO t_canc_lead.
        EXIT.
      ENDLOOP.
    ENDLOOP.

* Delete all the other lines and move them go T_POSTAB_INV_HELP
    CHECK NOT t_canc_lead[] IS INITIAL.
    REFRESH t_canc_help.
    t_canc_help[] = t_postab_inv[].
    LOOP AT t_postab_inv INTO wa_postab_inv
      WHERE opbel_kk_rg = wa_opbel_kk_rg-opbel
        AND x_lead_rg   IS INITIAL
        AND xzclr       IS INITIAL.
      LOOP AT t_canc_help INTO wa_canc_help
        WHERE orino_ref = wa_postab_inv-orino.
        APPEND wa_canc_help  TO t_postab_inv_help .
        APPEND wa_postab_inv TO t_postab_inv_help .
        EXIT.
      ENDLOOP.
    ENDLOOP.

  ENDLOOP.

ENDFORM.                    " del_couples_canc
*&---------------------------------------------------------------------*
*&      Form  adjust_t_postab
*&---------------------------------------------------------------------*
FORM adjust_t_postab TABLES t_postab STRUCTURE fkkepos.

* Entries are in T_POSTAB_INV or T_LEAD_POSTAB
* First of all make sure that there are no lines doubled
  DATA: saldo   type betrw_kk .                " note 1624875

  LOOP AT t_lead_postab INTO wa_lead_postab.
    IF NOT wa_lead_postab-orino IS INITIAL.
      READ TABLE t_postab_inv INTO wa_postab_inv
                   WITH KEY orino = wa_lead_postab-orino.
      IF sy-subrc EQ 0.
        DELETE TABLE t_postab_inv FROM wa_postab_inv.
      ENDIF.
    ELSE.
      READ TABLE t_postab_inv INTO wa_postab_inv
                   WITH KEY orino_ref = wa_lead_postab-orino_ref.
      IF sy-subrc EQ 0.
        DELETE TABLE t_postab_inv FROM wa_postab_inv.
      ENDIF.
    ENDIF.
  ENDLOOP.

* Delete entries in T_POSTAB first
  LOOP AT t_postab_inv INTO wa_postab_inv.
    LOOP AT t_postab
      WHERE opbel_kk_rg = wa_postab_inv-opbel_kk_rg.
      DELETE t_postab.
    ENDLOOP.
  ENDLOOP.

  LOOP AT t_lead_postab INTO wa_lead_postab.
    LOOP AT t_postab
      WHERE opbel_kk_rg = wa_lead_postab-opbel_kk_rg.
      DELETE t_postab.
    ENDLOOP.
  ENDLOOP.

* note 761162 >>>
  LOOP AT t_postab_inv_save INTO wa_postab_inv_save.
    clear saldo .                                   " note 1624875
    LOOP AT t_postab
      WHERE opbel_kk_rg = wa_postab_inv_save-opbel_kk_rg and
             augrd      eq '07'.
       saldo = t_postab-betrw + saldo .             " note 1624875
    ENDLOOP.
*   note 1624875
     if sy-subrc = 0 and saldo = 0.
       delete t_postab where
                 opbel_kk_rg = wa_postab_inv_save-opbel_kk_rg
               and  augrd = '07'.
     endif.
*  note 1624875
  ENDLOOP.
* note 761162 <<<

* Append lines from T_POSTAB_INV
*    check not t_postab_inv is initial.
  LOOP AT t_postab_inv INTO wa_postab_inv.
    t_postab = wa_postab_inv.
    APPEND t_postab.
  ENDLOOP.

* Append the leading positions
*    check not t_lead_postab[] is initial.
  LOOP AT t_lead_postab INTO wa_lead_postab.
    t_postab = wa_lead_postab.
    APPEND t_postab.
  ENDLOOP.
* Append the new leading positions
  CHECK NOT t_postab_new[] IS INITIAL.
  LOOP AT t_postab_new INTO wa_postab_new.
    CHECK NOT wa_postab_new-betrw IS INITIAL.
    t_postab = wa_postab_new.
    APPEND t_postab.
  ENDLOOP.

ENDFORM.                    " adjust_t_postab
*&---------------------------------------------------------------------*
*&      Form  check_postab_x1205
*&---------------------------------------------------------------------*
FORM check_postab_x1205  TABLES   t_postab STRUCTURE fkkepos.

  DATA: t_before_s TYPE fkkepos OCCURS 0 WITH HEADER LINE,
        t_before_h TYPE fkkepos OCCURS 0 WITH HEADER LINE,
        h_kum LIKE dfkkop-betrw.

  CLEAR h_kum.
  LOOP AT t_postab
    WHERE x1205 = 'X'.
    h_kum = h_kum + t_postab-betrw.
    IF t_postab-betrw GE 0.
      APPEND t_postab TO t_before_s.
    ELSE.
      APPEND t_postab TO t_before_h.
    ENDIF.
  ENDLOOP.

* If the sum is not 0 -> error -> find the line without the
* partner!!!
  IF h_kum NE 0.
    LOOP AT t_before_s.
* try match by orino/orino_ref rather than by amount and clearing doc
      LOOP AT t_before_h
        WHERE orino       = t_before_s-orino_ref
          AND orino_ref   = t_before_s-orino.
        DELETE t_before_h.
        DELETE t_before_s.
        EXIT.
      ENDLOOP.
    ENDLOOP.

    sort t_postab by  orino orino_ref x1205 xndsp xzclr .  " note
* Find the corresponding entry in T_POSTAB and set X1205
    IF NOT t_before_s[] IS INITIAL.
      LOOP AT t_before_s.
* look for match by orino/orino_ref first
*        LOOP AT t_postab
*           WHERE orino     = t_before_s-orino_ref
*             AND orino_ref = t_before_s-orino
*             AND x1205     = ' '
*             AND xndsp     = ' '
*             AND xzclr     = ' '.
*          t_postab-x1205 = 'X'.
*          MODIFY t_postab.
*          EXIT.
*        ENDLOOP.
        read table t_postab with key orino = t_before_s-orino_ref
                                     orino_ref = t_before_s-orino
                                     x1205     = ' '
                                     xndsp     = ' '
                                     xzclr     = ' '
                                     binary search.
        IF sy-subrc = 0.
          t_postab-x1205 = 'X'.
          MODIFY t_postab  index sy-tabix.
        ELSEIF sy-subrc <> 0.
* no match, take any item with the correct amount and same clearing doc
          t_before_s-betrw = t_before_s-betrw * -1.
*          LOOP AT t_postab
*            WHERE betrw = t_before_s-betrw
*              AND augbl = t_before_s-augbl
*              AND x1205 = ' '
*              AND xndsp = ' '
*              AND xzclr = ' '.
*            t_postab-x1205 = 'X'.
*            MODIFY t_postab.
*            EXIT.
*          ENDLOOP.
          IF t_before_s-augbl IS NOT INITIAL.   " Note 1893487
             read table t_postab with key betrw = t_before_s-betrw
                                       augbl = t_before_s-augbl
                                       x1205     = ' '
                                       xndsp     = ' '
                                       xzclr     = ' '.
*                                       binary search.   Note 1893487
          ELSE.                         " Note 1893487
             sy-subrc = 1.              " Note 1893487
          ENDIF.                        " Note 1893487
          IF sy-subrc = 0.
            t_postab-x1205 = 'X'.
            MODIFY t_postab  index sy-tabix.
          ELSEIF sy-subrc <> 0.
* Still no match, we have to remove the x1205 flag
* so that the balance displayed is not affected.
            t_before_s-betrw = t_before_s-betrw * -1.
*            LOOP AT t_postab
*              WHERE betrw     = t_before_s-betrw
*                AND augbl     = t_before_s-augbl
*                AND orino     = t_before_s-orino
*                AND orino_ref = t_before_s-orino_ref
*                AND x1205     = 'X'.
*              t_postab-x1205 = ' '.
*              MODIFY t_postab.
*              EXIT.
*            ENDLOOP.
            read table t_postab with key orino     = t_before_s-orino
                                         orino_ref = t_before_s-orino_ref
                                         x1205     = 'X'
                                         betrw = t_before_s-betrw
                                         opbel = t_before_h-opbel
                                         augbl = t_before_s-augbl.
            IF sy-subrc = 0.
              t_postab-x1205 = ' '.
              MODIFY t_postab  index sy-tabix.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF NOT t_before_h[] IS INITIAL.
      LOOP AT t_before_h.
* look for match by orino/orino_ref first
*          LOOP AT t_postab
*             WHERE orino     = t_before_h-orino_ref
*               AND orino_ref = t_before_h-orino
*               AND x1205     = ' '
*               AND xndsp     = ' '
*               AND xzclr     = ' '.
*            t_postab-x1205 = 'X'.
*            MODIFY t_postab.
*            EXIT.
*          ENDLOOP.
        read table t_postab with key orino = t_before_h-orino_ref
                                     orino_ref = t_before_h-orino
                                     x1205     = ' '
                                     xndsp     = ' '
                                     xzclr     = ' '
                                     binary search.
        IF sy-subrc = 0.
          t_postab-x1205 = 'X'.
          MODIFY t_postab  index sy-tabix.
        ELSEIF sy-subrc <> 0.
* no match, take any item with the correct amount and same clearing doc
          t_before_h-betrw = t_before_h-betrw * -1.
*            LOOP AT t_postab
*              WHERE betrw = t_before_h-betrw
*                AND opbel = t_before_h-opbel
*                AND augbl = t_before_h-augbl
*                AND x1205 = ' '
*                AND xndsp = ' '
*                AND xzclr = ' '.
*              t_postab-x1205 = 'X'.
*              MODIFY t_postab.
*              EXIT.
*            ENDLOOP.
          read table t_postab with key betrw = t_before_h-betrw
                                       opbel = t_before_h-opbel
                                       augbl = t_before_h-augbl
                                       x1205     = ' '
                                       xndsp     = ' '
                                       xzclr     = ' '.
*                                      binary search.   Note 1893487
          IF sy-subrc = 0.
            t_postab-x1205 = 'X'.
            MODIFY t_postab index sy-tabix.
          ELSEIF sy-subrc <> 0.
* Still no match, we have to remove the x1205 flag
* so that the balance displayed is not affected.
            t_before_h-betrw = t_before_h-betrw * -1.
*              LOOP AT t_postab
*                WHERE betrw     = t_before_h-betrw
*                  AND augbl     = t_before_h-augbl
*                  AND orino     = t_before_h-orino
*                  AND orino_ref = t_before_h-orino_ref
*                  AND x1205     = 'X'.
*                t_postab-x1205 = ' '.
*                MODIFY t_postab.
*                EXIT.
*              ENDLOOP.
            read table t_postab with key orino     = t_before_h-orino
                                         orino_ref = t_before_h-orino_ref
                                         x1205     = 'X'
                                         betrw = t_before_h-betrw
                                         opbel = t_before_h-opbel
                                         augbl = t_before_h-augbl.
            IF sy-subrc = 0.
              t_postab-x1205 = ' '.
              MODIFY t_postab index sy-tabix.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDIF.

ENDFORM.                    " check_postab_x1205
*&---------------------------------------------------------------------*
*&      Form  authority_check
*&---------------------------------------------------------------------*
FORM authority_check USING p_opbel LIKE erdk-opbel.

  DATA: l_fkkvk    LIKE fkkvk,
        l_fkkvkp   LIKE fkkvkp,
        l_rc       LIKE sy-subrc,
        lt_author  TYPE TABLE OF isu_author WITH HEADER LINE,
        wa_erdk    LIKE erdk.
*----------------------------------------------------------------------*
  STATICS: loc_wa_erdk  LIKE erdk.
*----------------------------------------------------------------------*
  IF ( loc_wa_erdk IS INITIAL          ) OR
     ( loc_wa_erdk-opbel <> p_opbel ).
*   Druckdokumentkopf lesen
    CALL FUNCTION 'ISU_DB_ERDK_SINGLE'
      EXPORTING
        x_opbel       = p_opbel
      IMPORTING
        y_erdk        = wa_erdk
      EXCEPTIONS
        not_found     = 1
        not_qualified = 2
        system_error  = 3
        OTHERS        = 4.

    IF sy-subrc = 4.
      mac_msg_others sy-subrc 'ISU_DB_ERDK_SINGLE'.
    ELSEIF ( sy-subrc <> 0 ).
      IF ( p_opbel IS INITIAL ).
*       Text: Druckbeleg (&1) nicht vorhanden
        MESSAGE s033(eb) WITH p_opbel.
      ELSE.
*       Text: Druckbeleg nicht vorhanden ( Langtext -> Archivierung )
        MESSAGE s164(eb) WITH p_opbel.
      ENDIF.
      EXIT.
    ELSE.
      loc_wa_erdk = wa_erdk.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'FKK_ACCOUNT_READ'
    EXPORTING
      i_vkont      = wa_erdk-vkont
    IMPORTING
      e_fkkvk      = l_fkkvk
      e_fkkvkp     = l_fkkvkp
    EXCEPTIONS
      not_found    = 1
      foreign_lock = 2
      OTHERS       = 3.

  IF sy-subrc = 1 OR sy-subrc = 2.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING
            not_found.
  ELSEIF sy-subrc <> 0.
    mac_msg_others sy-subrc 'FKK_ACCOUNT_READ'.
  ENDIF.

  IF l_fkkvk-vktyp IS INITIAL.
    l_fkkvk-vktyp = co_auth_dummy.
  ENDIF.
  IF l_fkkvkp-opbuk IS INITIAL.
    l_fkkvkp-opbuk = co_auth_dummy.
  ENDIF.
  IF l_fkkvkp-begru IS INITIAL.
*    L_FKKVKP-BEGRU = CO_AUTH_DUMMY.
  ENDIF.

  CALL FUNCTION 'FKK_ACCOUNT_AUTHORITY_CHECK'
    EXPORTING
      i_bukrs      = l_fkkvkp-stdbk
      i_opbuk      = l_fkkvkp-opbuk
      i_vktyp      = l_fkkvk-vktyp
      i_begru      = l_fkkvkp-begru
      i_actvt      = '03'
    EXCEPTIONS
      foreign_lock = 1
      OTHERS       = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING
            not_authorized.
  ELSEIF sy-subrc <> 0.
    mac_msg_others sy-subrc 'FKK_ACCOUNT_AUTHORITY_CHECK'.
  ENDIF.

* authority check (Berechtigungsprüfung)
  CALL FUNCTION 'ISU_AUTHORITY_CHECK_REGIOGROUP'
    EXPORTING
      x_activity          = co_display
      x_address_type      = co_for_account
      x_vkont             = wa_erdk-vkont
    EXCEPTIONS
      authority_not_given = 1
      OTHERS              = 2.

  IF sy-subrc <> 0.
    mac_msg_repeat co_msg_error not_authorized.
  ELSEIF sy-subrc <> 0.
    mac_msg_others sy-subrc 'ISU_AUTHORITY_CHECK_REGIOGROUP'.
  ENDIF.

* LT_AUTHOR fuellen
  CLEAR lt_author.
  REFRESH lt_author.
  lt_author-id    = co_authid_activity.
  lt_author-field = '1'.
  APPEND lt_author.

  CLEAR lt_author.
  lt_author-id = co_authid_vktyp_kk.
  IF NOT l_fkkvk-vktyp IS INITIAL.
    lt_author-field = l_fkkvk-vktyp.
  ELSE.
    lt_author-field = co_auth_dummy.
  ENDIF.
  APPEND lt_author.

  CLEAR lt_author.
  lt_author-id = co_authid_bukrs.
  IF NOT l_fkkvkp-opbuk IS INITIAL.
    lt_author-field =  l_fkkvkp-opbuk.
  ELSE.
    lt_author-field = co_auth_dummy.
  ENDIF.
  APPEND lt_author.

  CLEAR lt_author.
  lt_author-id = co_authid_begru.
  IF NOT l_fkkvkp-begru IS INITIAL.
    lt_author-field =  l_fkkvkp-begru.
  ELSE.
    lt_author-field = co_auth_dummy.
  ENDIF.
  APPEND lt_author.

  CALL FUNCTION 'ISU_AUTHORITY_CHECK'
    EXPORTING
      x_object  = co_auth_object
    IMPORTING
      y_subrc   = l_rc
    TABLES
      xt_author = lt_author
    EXCEPTIONS
      OTHERS    = 1.

  IF ( sy-subrc <> 0 ).
    mac_msg_others sy-subrc 'ISU_AUTHORITY_CHECK'.
  ENDIF.
  IF ( l_rc <> 0 ).
* Text: Sie haben keine Berechtigung zur Anzeige von Druckbelegen zu Kom
    mac_msg_putx co_msg_error '169' 'EB' l_fkkvk-vkont
                               space space space not_authorized.
* nur wegen Verwendungsnachweis
    SET EXTENDED CHECK OFF.
    IF 1 = 2. MESSAGE e169(eb). ENDIF.
    SET EXTENDED CHECK ON.
  ENDIF.

ENDFORM.                    " authority_check
*&---------------------------------------------------------------------*
*&      Form  check_new_inv
*&---------------------------------------------------------------------*
*& New with Release 4.72
*&
*& The layout of invoices was changed
*& And the account display has to be adjusted
*& Signature of the new layout:
*& no BBP transfer lines with transaction 0050/0030 are created
*&---------------------------------------------------------------------*
FORM check_new_inv  USING   p_postab  TYPE fkkepos
                    CHANGING p_new_inv TYPE xflag.

  CONSTANTS: co_ihvorg TYPE hvorg_kk VALUE '0050',
             co_itvorg TYPE tvorg_kk VALUE '0030'.


  STATICS: h_vorg_read TYPE xflag,
           h_ehvorg    TYPE hvorg_kk,
           h_etvorg    TYPE tvorg_kk.

  IF h_vorg_read IS INITIAL.
* retrieve external transaction for BBP transfer
    h_vorg_read = 'X'.
    CALL FUNCTION 'ISU_DB_TEIVV_SELECT'
      EXPORTING
        i_ihvor = co_ihvorg
        i_itvor = co_itvorg
        i_applk = 'R'
      IMPORTING
        e_hvorg = h_ehvorg
        e_tvorg = h_etvorg
      EXCEPTIONS
        OTHERS  = 1.

    IF sy-subrc <> 0.
      CLEAR: h_ehvorg, h_etvorg.
    ENDIF.

  ENDIF.

  IF h_ehvorg IS INITIAL OR h_etvorg IS INITIAL.
    p_new_inv = 'X'.
  ELSEIF ( p_postab-hvorg = h_ehvorg ) AND
         ( p_postab-tvorg = h_etvorg ).
    p_new_inv = space.
  ENDIF.

ENDFORM.                    " check_new_inv
*&---------------------------------------------------------------------*
*&      Form  delete_rest
*&---------------------------------------------------------------------*
*       In some cases (e.g. the leading line is in an installment plan
*       and the installment plan items are shown) the following lines
*       from the invoice should be hidden as well:
*       0050 0030    20,-  DELETE THIS LINE
*       0050 0010   -20,-  DELETE THIS LINE
*----------------------------------------------------------------------*
FORM delete_rest.

  DATA: wa_h_postab TYPE fkkepos,
        t_h_postab TYPE fkkepos OCCURS 0.
  DATA: v_found(1)  TYPE c.

  CHECK NOT t_postab_inv IS INITIAL.
  t_h_postab[] = t_postab_inv.

  LOOP AT t_opbel_kk_rg INTO wa_opbel_kk_rg
    WHERE augrd NE '05'
      AND h_count IS INITIAL.  "no line with x_lead_rg exists

*   check if all items of a bill would be deleted
    v_found = ' '.
    LOOP AT t_postab_inv INTO wa_postab_inv
      WHERE NOT orino_ref IS INITIAL
        AND opbel_kk_rg   EQ wa_opbel_kk_rg-opbel
        AND xzclr         IS INITIAL.

      LOOP AT t_h_postab INTO wa_h_postab
        WHERE orino       = wa_postab_inv-orino_ref.
        IF ( wa_h_postab-opbel_kk_rg NE wa_postab_inv-opbel_kk_rg ) OR
           (  NOT wa_h_postab-x_lead_rg  IS INITIAL ).
          v_found = 'X'.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    CHECK v_found = 'X'.

    LOOP AT t_postab_inv INTO wa_postab_inv
      WHERE NOT orino_ref IS INITIAL
        AND opbel_kk_rg   EQ wa_opbel_kk_rg-opbel
        AND xzclr         IS INITIAL.
      LOOP AT t_h_postab INTO wa_h_postab
        WHERE orino       = wa_postab_inv-orino_ref
          AND opbel_kk_rg = wa_postab_inv-opbel_kk_rg
          AND x_lead_rg   IS INITIAL.
        MOVE-CORRESPONDING wa_h_postab TO wa_postab_inv_help.
        APPEND wa_postab_inv_help TO t_postab_inv_help.
        MOVE-CORRESPONDING wa_postab_inv TO wa_postab_inv_help.
        APPEND wa_postab_inv_help TO t_postab_inv_help.
        EXIT.
      ENDLOOP.
    ENDLOOP.
  ENDLOOP.

ENDFORM.                    " delete_rest
*&---------------------------------------------------------------------*
*&      Form  read_archive
*&---------------------------------------------------------------------*
*       Read print document from archive
*----------------------------------------------------------------------*
*      -->P_I_OPBEL  Number of Contract Accts Rec. & Payable Doc
*      -->P_I_OPUPK  Item number in contract account document
*      -->P_I_OPUPW  Repetition Item in Contract Account Document
*----------------------------------------------------------------------*
FORM read_archive  USING    i_opbel TYPE fkkop-opbel
                            i_opupk TYPE fkkop-opupk
                            i_opupw TYPE fkkop-opupw
                   CHANGING y_archivekey TYPE arkey
                            y_archiveofs TYPE admi_offst.
  TYPES: BEGIN OF t_arc_key,
             archivekey      TYPE arkey,
             archiveofs      TYPE admi_offst,
           END OF t_arc_key.
  DATA: iw_archive_result  TYPE t_arc_key,
        it_archive_result  TYPE t_arc_key OCCURS 0,
        w_answer           TYPE c,
        lv_arc_file_key    TYPE isu_arch_as_prdoch2_key,
        l_erdb             TYPE erdb,
        l_print_doc        TYPE isu21_print_doc.

* The invoicing doc is not found, do ask, if try to look for it in
* achiving file.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar       = text-t10
      text_question  = text-t11
    IMPORTING
      answer         = w_answer
    EXCEPTIONS
      text_not_found = 1
      OTHERS         = 2.

  IF sy-subrc = 0 AND w_answer = '1'.                  "Ja
* Set FI-CA Document number into key field structure
    lv_arc_file_key-invopbel = i_opbel.

* Call SAP AS to get results
    CALL FUNCTION 'AS_API_READ'
      EXPORTING
        i_fieldcat         = 'SAP_ISU_PRDOCH2'
        i_selections       = lv_arc_file_key
      IMPORTING
        e_result           = it_archive_result
      EXCEPTIONS
        parameters_invalid = 1
        no_infostruc_found = 2
        OTHERS             = 3.

    IF sy-subrc <> 0.
      mac_msg_repeat co_msg_error archive_read_error.
    ELSE.
      CLEAR iw_archive_result.
* search for right print doc in the tabel of results
      CLEAR y_archivekey. CLEAR y_archiveofs.
      LOOP AT it_archive_result INTO iw_archive_result.
        CALL FUNCTION 'ISU_ARCH_READ_PRDOC'
          EXPORTING
            i_archivekey = iw_archive_result-archivekey
            i_offset     = iw_archive_result-archiveofs
          IMPORTING
            y_print_doc  = l_print_doc
          EXCEPTIONS
            OTHERS       = 1.
        IF sy-subrc <> 0.
          mac_msg_repeat co_msg_error archive_read_error.
        ENDIF.
* Only invoiced documents can be relevant
        IF l_print_doc-erdk-invoiced IS INITIAL OR
           l_print_doc-erdk-simulated EQ 'X' OR
           l_print_doc-erdk-tobreleasd = 'X'.
* Try next entry in archive
          CONTINUE.
        ENDIF.
*  First check for the doc ids for documents created during invoicing
        LOOP AT l_print_doc-t_erdb INTO l_erdb  WHERE doc_id CN 'FPRZ'
                AND invopbel EQ i_opbel.
          y_archivekey = iw_archive_result-archivekey.
          y_archiveofs = iw_archive_result-archiveofs.
        ENDLOOP.
        IF sy-subrc EQ 0.
* Document found.
          EXIT.
        ENDIF.
* Do not display reversed/reversal documents for other doc ids.
        IF l_print_doc-erdk-ergrd = '04' OR
           l_print_doc-erdk-stokz = 'X'.
          CONTINUE.
        ENDIF.
        LOOP AT l_print_doc-t_erdb INTO l_erdb WHERE doc_id CA 'FRZ'
                AND invopbel EQ i_opbel
                AND invopupk EQ i_opupk
                AND invopupw EQ i_opupw.
          y_archivekey = iw_archive_result-archivekey.
          y_archiveofs = iw_archive_result-archiveofs.
        ENDLOOP.
        IF sy-subrc EQ 0.
* Document found.
          EXIT.
        ELSE.
* try next entry in archive
          CONTINUE.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF. " sy-subrc = 0 AND w_answer = '1'

ENDFORM.                    " read_archive
