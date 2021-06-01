*&---------------------------------------------------------------------*
*&  Include  /adz/inv_sel_screen_common
*&---------------------------------------------------------------------*

TABLES tinv_inv_head.
TABLES tinv_inv_doc.
TABLES tinv_inv_line_a.
TABLES eanlh.
TABLES euitrans.
TABLES fkkvkp.
TABLES /idexge/rej_noti.
TABLES /adz/rek_vors.

********************************************************************************
* Selektionsbildschirm
********************************************************************************
DATA ls_help type /adz/inv_s_out_reklamon.
"I PARAMETERS:                          tinv_inv_head-invoice_type  " invoice
PARAMETERS:     p_invtp  TYPE numc3  "  /adz/fi_negremadv_invtyp  DEFAULT '1'  " fi_negremadv_invtyp
                         AS LISTBOX VISIBLE LENGTH 30.
SELECTION-SCREEN BEGIN OF BLOCK head WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: s_aggr  FOR fkkvkp-vkont MODIF ID rem.  " REMA
SELECT-OPTIONS: s_rece  FOR tinv_inv_head-int_receiver,
                s_send  FOR tinv_inv_head-int_sender,
                s_insta FOR tinv_inv_head-invoice_status MODIF ID sta DEFAULT '01'  TO '02',
                s_dtrec FOR tinv_inv_head-date_of_receipt.
SELECTION-SCREEN END OF BLOCK head.

SELECTION-SCREEN BEGIN OF BLOCK doc WITH FRAME TITLE TEXT-002.
SELECT-OPTIONS: s_intido FOR tinv_inv_doc-int_inv_doc_no,
                s_extido FOR tinv_inv_doc-ext_invoice_no,
                s_doctyp FOR tinv_inv_doc-doc_type,
                s_imdoct FOR tinv_inv_doc-/idexge/imd_doc_type MODIF ID inv, "INV
                s_idosta FOR tinv_inv_doc-inv_doc_status,
                s_rstgr  FOR tinv_inv_line_a-rstgr,
                s_freetx FOR /idexge/rej_noti-free_text1 NO INTERVALS MODIF ID inv, " INV
                s_dtpaym FOR tinv_inv_doc-date_of_payment,
                s_bulkrf FOR tinv_inv_doc-inv_bulk_ref      MODIF ID inv, "INV
                s_rstv   FOR /adz/rek_vors-vorschlag        MODIF ID inv,   "INV
                s_lstatx FOR ls_help-ls_status_text         MODIF ID inv.
SELECT-OPTIONS: s_invoda FOR tinv_inv_doc-invoice_date      MODIF ID rem,       "REMA
                s_owninv FOR tinv_inv_line_a-own_invoice_no MODIF ID rem,  "REMA
                s_extui  FOR euitrans-ext_ui                MODIF ID rem.      "REMA
SELECTION-SCREEN END OF BLOCK doc.


*SELECTION-SCREEN BEGIN OF BLOCK opt WITH FRAME TITLE text-003.
*PARAMETERS: p_err RADIOBUTTON GROUP opt,
*            p_noerr RADIOBUTTON GROUP opt.
*SELECTION-SCREEN END OF BLOCK opt.

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-005.
SELECT-OPTIONS: s_abrkl FOR eanlh-aklasse   MODIF ID inv.  "INV
SELECT-OPTIONS: s_tatyp FOR eanlh-tariftyp  MODIF ID inv. "INV
SELECT-OPTIONS: s_ablei FOR eanlh-ableinh   MODIF ID inv. "INV
SELECTION-SCREEN END OF BLOCK b01.

SELECTION-SCREEN BEGIN OF BLOCK b03 WITH FRAME TITLE TEXT-007 .
SELECT-OPTIONS: s_zpkt FOR euitrans-ext_ui NO INTERVALS MODIF ID inv.  "INV
SELECTION-SCREEN END OF BLOCK b03.


SELECTION-SCREEN BEGIN OF BLOCK vari WITH FRAME TITLE TEXT-004.
PARAMETERS: p_storno AS CHECKBOX DEFAULT ' ' MODIF ID rem.  "REMA
PARAMETERS: p_vari LIKE disvariant-variant.
SELECTION-SCREEN END OF BLOCK vari.


SELECTION-SCREEN BEGIN OF BLOCK techn WITH FRAME TITLE TEXT-006.
"SELECTION-SCREEN SKIP.
PARAMETERS: p_sperr AS CHECKBOX MODIF ID inv.   "INV
PARAMETERS: p_klaer AS CHECKBOX MODIF ID inv.   "INV
PARAMETERS: p_wait AS CHECKBOX  MODIF ID inv.    "INV
PARAMETERS: p_waitx AS CHECKBOX MODIF ID inv.   "INV
PARAMETERS: p_max TYPE num10 DEFAULT  9999 MODIF ID inv.      "INV
SELECTION-SCREEN END OF BLOCK techn.

" REMA
SELECTION-SCREEN BEGIN OF BLOCK mahn WITH FRAME TITLE TEXT-008 .
PARAMETERS:     pa_lockr LIKE fkkvkp-mansp DEFAULT '8' MODIF ID mah . "REMA
PARAMETERS:     pa_fdate LIKE sy-datum MODIF ID mah .  "REMA
PARAMETERS:     pa_tdate LIKE sy-datum MODIF ID mah .  "REMA
SELECTION-SCREEN END OF BLOCK mahn.

DATA gf_reklamon TYPE abap_bool. " true => Rekalamationsmonitor,  false => INVOICE_MAN

*********************************************************************************
* GET_SEL_SCREEN   Eingabeparameter in Struktur speichern
*********************************************************************************
FORM get_sel_screen CHANGING c_sel_screen TYPE /adz/inv_s_sel_screen.
  c_sel_screen-p_invtp = p_invtp.
  IF gf_reklamon = abap_true.
    c_sel_screen-p_invtp = COND #(
*      WHEN p_invtp < 10 THEN  p_invtp+2
*      WHEN p_invtp < 100 THEN p_invtp+1
*      ELSE p_invtp
       WHEN p_invtp eq '1'  THEN '004'   " NN
       WHEN p_invtp eq '2'  THEN '008'   " Memi
       WHEN p_invtp eq '3'  THEN '011'   " MGV
       WHEN p_invtp eq '4'  THEN '013'   " MSB
      ).
  ENDIF.
  c_sel_screen-s_aggr   =  s_aggr[].
  c_sel_screen-s_rece   =  s_rece[].
  c_sel_screen-s_send   =  s_send[].
  c_sel_screen-s_insta  =  s_insta[].
  c_sel_screen-s_dtrec  =  s_dtrec[].
  c_sel_screen-s_intido =  s_intido[].
  c_sel_screen-s_extido =  s_extido[].
  c_sel_screen-s_doctyp =  s_doctyp[].
  c_sel_screen-s_imdoct =  s_imdoct[].
  c_sel_screen-s_idosta =  s_idosta[].
  c_sel_screen-s_rstgr  =  s_rstgr[].
  c_sel_screen-s_freetx =  s_freetx[].
  c_sel_screen-s_dtpaym =  s_dtpaym[].
  c_sel_screen-s_bulkrf =  s_bulkrf[].
  c_sel_screen-s_lstatx =  s_lstatx[].
  c_sel_screen-s_rstv   =  s_rstv[].
  c_sel_screen-s_invoda =  s_invoda[].
  c_sel_screen-s_owninv =  s_owninv[].
  c_sel_screen-s_extui  =  s_extui[].
  c_sel_screen-s_abrkl  =  s_abrkl[].
  c_sel_screen-s_tatyp  =  s_tatyp[].
  c_sel_screen-s_ablei  =  s_ablei[].
  c_sel_screen-s_zpkt   =  s_zpkt[].
  c_sel_screen-pa_lockr =  pa_lockr.
  c_sel_screen-pa_fdate =  pa_fdate.
  c_sel_screen-pa_tdate =  pa_tdate.
  c_sel_screen-p_storno =  p_storno.
  c_sel_screen-p_vari   =  p_vari.
  c_sel_screen-p_sperr  =  p_sperr.
  c_sel_screen-p_klaer  =  p_klaer.
  c_sel_screen-p_wait   =  p_wait.
  c_sel_screen-p_waitx  =  p_waitx.
  c_sel_screen-p_max    =  p_max.
ENDFORM.
*********************************************************************************
* INITILALZATION
*********************************************************************************
INITIALIZATION.
  DATA lv_save_vari  TYPE char1 VALUE 'A'.
  DATA(ls_vari) = value disvariant( report = sy-repid ).

  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
    EXPORTING
      i_save     = lv_save_vari
    CHANGING
      cs_variant = ls_vari
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 0.
    p_vari = ls_vari-variant.
  ENDIF.

  " INVOICE_MAN oder REKLAMATIONSMON ???
  gf_reklamon = xsdbool( sy-repid CS 'REKLAMA' ).
  if gf_reklamon eq abap_true.
    if ( lines( s_insta ) > 0 ).
      s_insta[ 1 ]-high = '02'.
    endif.
  endif.
  PERFORM set_invtypes.

*********************************************************************************
AT SELECTION-SCREEN OUTPUT.
*********************************************************************************
  DATA lt_r_exclude_group TYPE RANGE OF screen-group1.
  IF gf_reklamon EQ abap_true.
    " Reklamationsmonitor
    lt_r_exclude_group = VALUE #( ( sign = 'I'  option = 'EQ' low = 'INV' ) ).
    SELECT COUNT( * ) FROM /adz/fi_remad WHERE negrem_option = 'SELSCREEN' AND negrem_field = 'MAHNSPERRE' AND negrem_value = 'X'.
    IF sy-subrc <> 0.
      lt_r_exclude_group = VALUE #( BASE lt_r_exclude_group ( sign = 'I'  option = 'EQ' low = 'MAH' ) ).
    ELSE.
      IF pa_fdate IS INITIAL.
        pa_fdate = sy-datum.
        pa_tdate = sy-datum + 14.
      ENDIF.
    ENDIF.
  ELSE.
    " Invoice
    lt_r_exclude_group = VALUE #(
      ( sign = 'I'  option = 'EQ' low = 'REM' )
      ( sign = 'I'  option = 'EQ' low = 'MAH' )
    ).
  ENDIF.
  LOOP AT SCREEN.
    IF screen-group1 in lt_r_exclude_group.
      screen-active = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
*********************************************************************************
* Process on value request
*********************************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  " Suchhilfe für Layoutvariante
  /adz/cl_inv_select_basic=>f4_for_variant(
    EXPORTING  iv_repid = sy-repid
    CHANGING   cv_vari  = p_vari  ).

**********************************************************************************
* AT SELECTION-SCREEN
**********************************************************************************
AT SELECTION-SCREEN.
  IF gf_reklamon EQ abap_true.
    "- Entweder aggr. Vertragskonto oder Sender eingeben
    IF s_aggr IS NOT INITIAL AND s_send IS NOT INITIAL.
      MESSAGE e000(e4) WITH 'Bitte entweder aggr. Vertragskonto'
                            'oder Sender eingeben'.
    ENDIF.

    IF s_insta  IS INITIAL AND  s_dtrec IS INITIAL.
      SET CURSOR FIELD 'S_INSTA-LOW'.
      MESSAGE e000(e4) WITH 'Bitte mindestens Rechnungs-Status'
                             'oder Eingangsdatum eingeben'.
    ENDIF.

    " Mahnsperre Datum Checken
    SELECT COUNT( * ) FROM /adz/fi_remad WHERE negrem_option = 'SELSCREEN' AND negrem_field = 'MAHNSPERRE' AND negrem_value = 'X'.
    IF sy-subrc = 0.
      IF pa_fdate < sy-datum.
        MESSAGE TEXT-e01 TYPE 'E'.
      ENDIF.

      IF pa_tdate < pa_fdate.
        MESSAGE TEXT-e02 TYPE 'E'.
      ENDIF.

    ENDIF.
  ENDIF.

*********************************************************************************
* Mögliche Invoicetypen einsetzen
*********************************************************************************
FORM set_invtypes.
  DATA lt_values TYPE vrm_values.
  DATA ls_value  TYPE vrm_value.

  IF gf_reklamon EQ abap_true.
    " Reklamationsmonitor Belegung
    DATA lt_dd07v TYPE TABLE OF dd07v.
    CALL FUNCTION 'DDUT_DOMVALUES_GET'
      EXPORTING
        name      = '/ADZ/FI_NEGREMADV_INVTYP'
        langu     = sy-langu
      TABLES
        dd07v_tab = lt_dd07v.
    IF sy-subrc <> 0.
      MESSAGE 'no domain info for INV_DOC_STATUS' TYPE 'X'.
    ENDIF.
    LOOP AT lt_dd07v ASSIGNING FIELD-SYMBOL(<ls_dd07v>).
      ls_value-key  = <ls_dd07v>-domvalue_l.
      ls_value-text = |{ <ls_dd07v>-ddtext }|.
      APPEND ls_value TO lt_values.
    ENDLOOP.


  ELSE.
    " Invoice-manager Belegung
    DATA lt_invtypes  TYPE TABLE OF tinv_c_invtypet.
    SELECT * FROM tinv_c_invtypet WHERE spras = @sy-langu
      INTO TABLE @lt_invtypes.
    LOOP AT lt_invtypes ASSIGNING FIELD-SYMBOL(<ls_invtype>).
      ls_value-key  = <ls_invtype>-invoice_type.
      ls_value-text = |{ <ls_invtype>-invoice_type } - { <ls_invtype>-text }|.
      APPEND ls_value TO lt_values.
    ENDLOOP.
    IF lt_values IS INITIAL.
      lt_values = VALUE vrm_values(
        ( key = '001'  text = '1 - Netznutzungsrechnung Einzelkunde' )
        ( key = '002'  text = '2 - Zahlungsavis (Eingang)' )
        ( key = '003'  text = '3 - Reklamationsavis (Ausgang)' )
        ( key = '004'  text = '4 - Reklamationsavis (Eingang)' )
        ( key = '006'  text = '6 - Mehr-Mindermengenabrechnung' )
        ( key = '007'  text = '7 - MSB-Rechnung' )
        ( key = '009'  text = '9 - Netznutzungsrechnung Einzelkunde (fremd)' )
        ( key = '100'  text = '100 - Zahlungsavis (ausgehend)' )
         ).
    ENDIF.
    SELECT SINGLE value  FROM /adz/inv_cust WHERE report = @sy-repid AND field = 'P_INVTP' AND select_parameter = 'X'
      INTO  @DATA(ls_invtp_str).
    IF ( ls_invtp_str IS INITIAL ).
      DATA lt_r_values TYPE RANGE OF vrm_value.
      lt_r_values = VALUE #(
         ( sign = 'I' option = 'EQ' low = '001' high = '' )
         ( sign = 'I' option = 'EQ' low = '006' high = '' )
         ( sign = 'I' option = 'EQ' low = '007' high = '' )
         ).
    ELSE.
      SPLIT ls_invtp_str AT ',' INTO  TABLE DATA(lt_invtp).
      lt_r_values = VALUE #( FOR ls IN lt_invtp
         ( sign = 'I' option = 'EQ' low = ls high  = '' ) ).
    ENDIF.
    DELETE lt_values WHERE key NOT IN lt_r_values.

  ENDIF.

  LOOP AT lt_values INTO ls_value.
    p_invtp = ls_value-key.
    EXIT.
  ENDLOOP.
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = 'P_INVTP'
      values          = lt_values
    EXCEPTIONS
      id_illegal_name = 1
      OTHERS          = 2.

ENDFORM.
