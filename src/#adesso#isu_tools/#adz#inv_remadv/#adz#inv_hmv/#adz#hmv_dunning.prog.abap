*&---------------------------------------------------------------------*
*& Report  /ADZ/HMV_DUNNING
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /adz/hmv_dunning.

TABLES:
  fkkvkp,
  fkkmako,
  dfkkthi,
  dfkkop.

DATA gs_constants TYPE /adz/hmv_s_constants.

*-----------------------------------------------------------------------
* Selections
*-----------------------------------------------------------------------
* Verarbeitungsmodus
SELECTION-SCREEN BEGIN OF BLOCK mod WITH FRAME TITLE TEXT-b05.
PARAMETERS: pa_showh RADIOBUTTON GROUP out.
PARAMETERS: pa_updhi RADIOBUTTON GROUP out.
PARAMETERS: pa_liste RADIOBUTTON GROUP out DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK mod.
* Vertragskonto
SELECTION-SCREEN BEGIN OF BLOCK vkont WITH FRAME TITLE TEXT-b01.
SELECT-OPTIONS: so_vkont FOR fkkvkp-vkont.  "Aggregiertes VK
SELECT-OPTIONS: so_bcbln FOR dfkkthi-bcbln. "Belegnummer der Buchung
SELECTION-SCREEN SKIP.
SELECT-OPTIONS: so_ekont FOR dfkkop-vkont.  "Vertragskontonummer
SELECT-OPTIONS: so_bukrs FOR dfkkop-bukrs.
SELECT-OPTIONS: so_augst FOR dfkkop-augst DEFAULT ' ' OPTION EQ SIGN I.
SELECTION-SCREEN SKIP.
SELECT-OPTIONS: so_mansp FOR fkkvkp-mansp.
SELECT-OPTIONS: so_mahns FOR fkkmako-mahns.
SELECTION-SCREEN SKIP.
PARAMETERS: p_akonto AS CHECKBOX DEFAULT 'X'.
PARAMETERS: p_dunn   AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK vkont.
* Mahnen
SELECTION-SCREEN BEGIN OF BLOCK mahn WITH FRAME TITLE TEXT-b02.
SELECT-OPTIONS: so_mahnv FOR fkkvkp-mahnv.
SELECT-OPTIONS: so_faedn FOR dfkkop-faedn NO-EXTENSION OBLIGATORY.
SELECTION-SCREEN SKIP.
PARAMETERS:     pa_lockr LIKE fkkvkp-mansp OBLIGATORY.
PARAMETERS:     pa_fdate LIKE sy-datum.
PARAMETERS:     pa_tdate LIKE sy-datum.
SELECTION-SCREEN END OF BLOCK mahn.
* Ausgabe
SELECTION-SCREEN BEGIN OF BLOCK var WITH FRAME TITLE TEXT-b04.
PARAMETERS: pa_updte AS CHECKBOX.
SELECTION-SCREEN SKIP.
PARAMETERS: p_vari LIKE disvariant-variant.
SELECTION-SCREEN END OF BLOCK var.
SELECTION-SCREEN BEGIN OF BLOCK bl3 WITH FRAME TITLE TEXT-017.
PARAMETERS  p_maxpar TYPE i DEFAULT 4.
SELECTION-SCREEN END OF BLOCK bl3.

INITIALIZATION.
  gs_constants = /adz/cl_hmv_constants=>get_constants( iv_repid = sy-repid ).
  PERFORM fill_selection_param.
  p_vari = /adz/cl_inv_select_basic=>get_default_variant(  sy-repid  ).

  pa_fdate = sy-datum.
  pa_tdate = sy-datum + 2.

  "### Leon weiß warum diese Varablen gelöscht werden, obwohl sie in fill_selection_param befuellt wurden.
  CLEAR: so_vkont, so_mahnv.

*-----------------------------------------------------------------------
* At selection-screen p_vari
*-----------------------------------------------------------------------
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  " Suchhilfe für Layoutvariante
  /adz/cl_inv_select_basic=>f4_for_variant(
    EXPORTING  iv_repid = sy-repid
    CHANGING   cv_vari  = p_vari  ).

*-----------------------------------------------------------------------
* At selection-screen
*-----------------------------------------------------------------------
AT SELECTION-SCREEN.
  IF pa_fdate < sy-datum.
    MESSAGE TEXT-e03 TYPE 'E'.
  ENDIF.

* --> Nuss 12.02.2018
* Bis-Datum darf nicht größer Ab-Datum sein
  IF pa_tdate < pa_fdate.
    MESSAGE TEXT-e05 TYPE 'E'.
  ENDIF.
* <-- Nuss 12.02.2018

  IF sy-ucomm NE 'ONLI' AND
    pa_updte = 'X'.
    MESSAGE TEXT-w01 TYPE 'W'.
  ENDIF.

  DATA(lv_tage) = ( pa_tdate - pa_fdate ).
  IF lv_tage GT 14.
    SET CURSOR FIELD 'PA_TDATE'.
    MESSAGE TEXT-e02 TYPE 'E'.
  ENDIF.
*
*&---------------------------------------------------------------------*
*&      Form  fill_selection_param
*&---------------------------------------------------------------------*
FORM fill_selection_param.
* Customizing Tabelle Intervallgrenzen für Vertragskonten (/ADZ/hmv_ival)
  SELECT * FROM /adz/hmv_ival INTO TABLE @DATA(t_hmv_ival).

* Aggregiertes VK
  LOOP AT t_hmv_ival INTO DATA(ls_interval) WHERE aktiv = 'X'.
*  READ TABLE t_hmv_ival INTO s_interval WITH KEY aktiv = 'X'.
    so_vkont-sign    = 'I'.
    so_vkont-option  = 'BT'.
    so_vkont-low     = ls_interval-fromnumber.
    so_vkont-high    = ls_interval-tonumber.
    APPEND so_vkont.
  ENDLOOP.

* Mahnsperrgrund
  pa_lockr    = COND #( WHEN gs_constants-c_lockr IS NOT INITIAL THEN gs_constants-c_lockr ELSE '7' ).

* Mahnsperren
  IF gs_constants-c_mansp = ' '.
    gs_constants-c_mansp = '*'.
  ENDIF.
  so_mansp         = gs_constants-c_mansp.

* Mahnverfahren
  SELECT * FROM /adz/hmv_mver INTO TABLE @DATA(lt_hmv_mver).
  LOOP AT lt_hmv_mver INTO DATA(ls_hmv_mver) WHERE aktiv = 'X'.
    so_mahnv-sign = 'I'.
    so_mahnv-option = 'EQ'.
    so_mahnv-low = ls_hmv_mver-mahnv.
    APPEND so_mahnv.
  ENDLOOP.
*  so_mahnv-sign    = 'I'.
*  so_mahnv-option  = 'EQ'.
*  so_mahnv-low     = c_mahnv.
*  APPEND so_mahnv.
* <-- Nuss 05.03.2018

* Fälligkeitsdatum von bis...
  IF gs_constants-c_faedn_to IS INITIAL.
    gs_constants-c_faedn_to = 0.
  ENDIF.

  so_faedn-sign    = 'I'.
  so_faedn-option  = 'BT'.
  so_faedn-low     = gs_constants-c_faedn_from.
  so_faedn-high    = sy-datum - gs_constants-c_faedn_to.
  IF so_faedn-low IS INITIAL.
    so_faedn-low = so_faedn-high - 14.
  ENDIF.
  APPEND so_faedn.
ENDFORM.

DATA ok_code LIKE sy-ucomm.
*-----------------------------------------------------------------------
* START-OF-SELECTION
*-----------------------------------------------------------------------
START-OF-SELECTION.
  DATA ls_sel_params  TYPE /adz/hmv_s_dunning_sel_params.
  ls_sel_params-pa_showh = pa_showh.
  ls_sel_params-pa_updhi = pa_updhi.
  ls_sel_params-pa_liste = pa_liste.
  ls_sel_params-so_vkont = so_vkont[].
  ls_sel_params-so_bcbln = so_bcbln[].
  ls_sel_params-so_ekont = so_ekont[].
  ls_sel_params-so_bukrs = so_bukrs[].
  ls_sel_params-so_augst = so_augst[].
  ls_sel_params-so_mansp = so_mansp[].
  ls_sel_params-so_mahns = so_mahns[].
  ls_sel_params-p_akonto = p_akonto.
  ls_sel_params-p_dunn   = p_dunn.
  ls_sel_params-so_mahnv = so_mahnv[].
  ls_sel_params-so_faedn = so_faedn[].
  ls_sel_params-pa_lockr = pa_lockr.
  ls_sel_params-pa_fdate = pa_fdate.
  ls_sel_params-pa_tdate = pa_tdate.
  ls_sel_params-pa_updte = pa_updte.
  ls_sel_params-p_maxpar = p_maxpar.
  "ls_sel_params-so_taski       = t_sel_taski_part[].

  GET TIME.
  DATA(lv_uzeit) = sy-uzeit.

  DATA(lo_controller) = NEW /adz/cl_hmv_controller_dunning( is_constants = gs_constants   is_sel_params = ls_sel_params ).
  IF ls_sel_params-pa_showh EQ 'X'.
    " Daten aus Extrakt lesen
    lo_controller->read_extract( ).
  ELSE.
    " Daten von DB lesen
    lo_controller->read_data(  ).
  ENDIF.

  IF ls_sel_params-pa_updhi EQ 'X'.
    " Daten als Extrakt sichern
    lo_controller->save_extract(
      EXPORTING
        iv_extract_text = CONV #( TEXT-001 )
        iv_uzeit_text   = CONV #( TEXT-007 )
        iv_uzeit        = lv_uzeit  ).
  ELSEIF sy-batch <> 'X'.
    DATA(lrt_data)  = lo_controller->get_data( ).
    DATA(go_gui)  = NEW  /adz/cl_hmv_gui_dunning(  is_const = gs_constants   iv_vari  = p_vari ).
    lo_controller->/adz/if_inv_controller_basic~mo_gui = go_gui.
    go_gui->display_data(
      EXPORTING  if_event_handler  = lo_controller->get_gui_event_handler( )
      CHANGING   crt_data          = lrt_data
    ).
    CALL SCREEN 100.
  ENDIF.

**************************************************************************
* END-OF-SELECTION
**************************************************************************
END-OF-SELECTION.


*&---------------------------------------------------------------------*
*&      Module  PAI_INVOICE_MANAGER  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_actions INPUT.
  CASE ok_code.
    WHEN '&F03' OR 'E'.
      LEAVE TO SCREEN 0.
    WHEN '&F12' OR '&F15' OR 'ENDE' OR 'ECAN'.
      LEAVE PROGRAM.
    WHEN OTHERS.
      go_gui->execute_user_command( ok_code ).
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  PBO_INVOICE_MANAGER  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_actions OUTPUT.
  SET TITLEBAR  'STANDARD_TITEL'  WITH go_gui->mv_titel_param1.
ENDMODULE.
