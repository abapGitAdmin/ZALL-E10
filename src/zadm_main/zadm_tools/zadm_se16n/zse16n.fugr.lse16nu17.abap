FUNCTION SE16N_START_MOBILE_APP.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_VARIANT) TYPE  RALDB_VARI
*"  EXPORTING
*"     REFERENCE(E_LINE_NR) TYPE  SYTABIX
*"     REFERENCE(E_DREF)
*"     REFERENCE(ET_FIELDCAT) TYPE  LVC_T_FCAT
*"----------------------------------------------------------------------

data: ld_report like rsvar-report value 'SE16N_BATCH'.
data: ld_Rc like sy-subrc.
DATA: BEGIN OF RSPARAMS_TAB OCCURS 10.
        INCLUDE STRUCTURE RSPARAMS.
DATA: END OF RSPARAMS_TAB.
data: lt_or_selfields type se16n_or_t.
data: lt_selfields    like se16n_seltab occurs 0 with header line.
data: lt_output       like se16n_output occurs 0 with header line.
data: lt_curr_add_up  like se16n_output occurs 0 with header line.
data: lt_quan_add_up  like se16n_output occurs 0 with header line.
data: lt_sum_up       like se16n_output occurs 0 with header line.
data: lt_group_by     like se16n_output occurs 0 with header line.
data: lt_order_by     like se16n_output occurs 0 with header line.
data: lt_toplow       like se16n_seltab occurs 0 with header line.
data: lt_sortorder    like se16n_seltab occurs 0 with header line.
data: lt_aggregate    like se16n_seltab occurs 0 with header line.
data: I_TAB         type se16n_tab,
      i_no_txt(1),
      i_max         like sy-tabix,
      i_line(1),
      i_clnt(1),
      i_vari        type slis_vari,
      i_guid(20),
      i_tech(1),
      i_cwid(1),
      i_roll(1),
      i_conv(1),
      i_lget(1),
      i_add_f(40),
      i_add_on(1),
      i_uname like sy-uname,
      i_hana(1),
      i_dbcon type dbcon_name,
      i_ojkey type tswappl,
      i_formul type gtb_formula_name.
data: begin of indxkey,
        fix(5) value 'SE16N',
        guid(15),
end of indxkey.
data: ld_guid type timestamp.
field-symbols: <fieldname>.

*.check if variant exists
  CALL FUNCTION 'RS_VARIANT_EXISTS'
    EXPORTING
      report              = ld_report
      variant             = i_variant
    IMPORTING
      r_c                 = ld_rc
    EXCEPTIONS
      not_authorized      = 01
      no_report           = 02
      report_not_existent = 03
      report_not_supplied = 04.

  IF sy-subrc <> 0.
    MESSAGE e142(ga) WITH ld_report i_variant.
  ENDIF.
  IF ld_rc <> 0.                           " variant exists
    MESSAGE e139(ga) WITH i_variant.
  ENDIF.

*.read variant data
  CALL FUNCTION 'RS_VARIANT_VALUES_TECH_DATA'
       EXPORTING
            report               = ld_report
            variant              = i_variant
*           SEL_TEXT             = ' '
            move_or_write        = 'M'
            sorted               = 'X'
*       IMPORTING
*            techn_data           = varid_tab
       TABLES
            variant_values       = rsparams_tab
*           VARIANT_TEXT         =
       EXCEPTIONS
            variant_non_existent = 1
            variant_obsolete     = 2
            OTHERS               = 3.

*.now fill data of each field into transfer data
  LOOP AT RSPARAMS_TAB.

    CASE RSPARAMS_TAB-SELNAME.
    WHEN 'LT_OUT'.
         check RSPARAMS_TAB-LOW <> space.
         lt_output = RSPARAMS_TAB-LOW.
         append lt_output.
    WHEN 'LT_CURR'.
         check RSPARAMS_TAB-LOW <> space.
         lt_curr_add_up = RSPARAMS_TAB-LOW.
         append lt_curr_add_up.
    WHEN 'LT_QUAN'.
         check RSPARAMS_TAB-LOW <> space.
         lt_quan_add_up = RSPARAMS_TAB-LOW.
         append lt_quan_add_up.
    WHEN 'LT_SUM'.
         check RSPARAMS_TAB-LOW <> space.
         lt_sum_up = RSPARAMS_TAB-LOW.
         append lt_sum_up.
    WHEN 'LT_GRP'.
         check RSPARAMS_TAB-LOW <> space.
         lt_group_by = RSPARAMS_TAB-LOW.
         append lt_group_by.
    WHEN 'LT_ORD'.
         check RSPARAMS_TAB-LOW <> space.
         lt_order_by = RSPARAMS_TAB-LOW.
         append lt_order_by.
    WHEN 'LT_TOP'.
         check RSPARAMS_TAB-LOW <> space.
         lt_toplow-field = RSPARAMS_TAB-LOW.
         case rsparams_tab-option.
           when 'AS'.
             MOVE 'ASC' TO: lt_toplow-low.
           when 'DE'.
             MOVE 'DES' TO: lt_toplow-low.
         endcase.
         append lt_toplow.
    WHEN 'LT_SOR'.
         check RSPARAMS_TAB-LOW <> space.
         lt_sortorder-field = RSPARAMS_TAB-low.
         MOVE RSPARAMS_TAB-option to lt_sortorder-low.
         append lt_sortorder.
    WHEN 'LT_AGG'.
         check RSPARAMS_TAB-LOW <> space.
         lt_aggregate-field = RSPARAMS_TAB-low.
         case RSPARAMS_TAB-option.
           when 'MX'.
             MOVE 'MAX' TO: lt_aggregate-low.
           when 'MI'.
             MOVE 'MIN' TO: lt_aggregate-low.
           when 'AV'.
             MOVE 'AVG' TO: lt_aggregate-low.
         endcase.
         append lt_aggregate.
    WHEN others.
         assign (rsparams_tab-selname) to <fieldname>.
         <fieldname> = rsparams_tab-low.
    ENDCASE.

  ENDLOOP.

*.get the selection data from database buffer
  indxkey-guid = i_guid.
* import lt_selfields from database indx(al) id indxkey.
  import lt_or_selfields from database indx(al) id indxkey.

  CALL FUNCTION 'SE16N_INTERFACE'
    EXPORTING
      I_TAB                  = i_tab
*     I_EDIT                 = i_edit
      I_NO_TXT               = i_no_txt
      I_MAX_LINES            = i_max
      I_LINE_DET             = i_line
      I_DISPLAY              = space
      I_DISPLAY_ALL          = space
      I_CLNT_SPEZ            = i_clnt
      I_VARIANT              = i_vari
      I_TECH_NAMES           = i_tech
      I_cwidth_opt_off       = i_cwid
      I_scroll               = i_roll
      I_no_convexit          = i_conv
      I_layout_get           = i_lget
      I_ADD_FIELD            = i_add_f
      I_ADD_FIELDS_ON        = i_add_on
      I_UNAME                = i_uname
      I_HANA_ACTIVE          = i_hana
      I_DBCON                = i_dbcon
      I_OJKEY                = i_ojkey
      I_FORMULA_NAME         = i_formul
    IMPORTING
      E_LINE_NR              = e_line_nr
      E_DREF                 = e_dref
      ET_FIELDCAT            = et_fieldcat
    TABLES
*      IT_SELFIELDS           = lt_selfields
      IT_OR_SELFIELDS        = lt_or_selfields
      IT_OUTPUT_FIELDS       = lt_output
      IT_ADD_UP_CURR_FIELDS  = lt_curr_add_up
      IT_ADD_UP_QUAN_FIELDS  = lt_quan_add_up
      IT_SUM_UP_FIELDS       = lt_sum_up
      IT_GROUP_BY_FIELDS     = lt_group_by
      IT_ORDER_BY_FIELDS     = lt_order_by
      IT_TOPLOW_FIELDS       = lt_toplow
      IT_SORTORDER_FIELDS    = lt_sortorder
      IT_AGGREGATE_FIELDS    = lt_aggregate
    EXCEPTIONS
*      NO_VALUES              = 1
      OTHERS                 = 2.

  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFUNCTION.
