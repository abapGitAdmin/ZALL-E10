REPORT  zpdoc_create_bdr.

*Include ZFG_AUFGABE/REQUEST_DIALOG_AUFG.

DATA: doctype       TYPE zproc_doctype,
      lv_ext_ui     TYPE ext_ui,
      lv_logbelnr   TYPE e_logbelnr,
      lt_euitrans   TYPE TABLE OF euitrans,
      ls_euitrans   TYPE euitrans,
      lt_bdr_orders TYPE ztt_ao_bdr_orders_req, "TABLE OF zstruc_ao_final_bdr_req.
      ls_bdr_orders TYPE zstruc_ao_final_bdr_req.

*BLOCK 1------------------------------------------------------------------------------------------------------------------
SELECTION-SCREEN BEGIN OF BLOCK gb_hdr WITH FRAME TITLE TEXT-bk3.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_z30  RADIOBUTTON GROUP g1 DEFAULT 'X' USER-COMMAND rb1.
SELECTION-SCREEN COMMENT 6(40) TEXT-t10 FOR FIELD p_z30.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_z34  RADIOBUTTON GROUP g1.
SELECTION-SCREEN COMMENT 6(40) TEXT-t11 FOR FIELD p_z34.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK gb_hdr.

*BLOCK 2--------------------------------------------------------------------------------------------------------------------
SELECTION-SCREEN BEGIN OF BLOCK gb_z30 WITH FRAME TITLE TEXT-bk4.

SELECT-OPTIONS s_mloc FOR lv_ext_ui MODIF ID z30.
PARAMETERS: p_asdate TYPE /idxgc/de_proc_date MODIF ID z30.
PARAMETERS: p_bverf TYPE /idxgc/de_settl_proc MODIF ID z30.

SELECTION-SCREEN END OF BLOCK gb_z30.

*BLOCK 3--------------------------------------------------------------------------------------------------------------------
SELECTION-SCREEN BEGIN OF BLOCK gb_z34 WITH FRAME TITLE TEXT-bk5.

SELECT-OPTIONS s_blgnr FOR lv_logbelnr MODIF ID z34.

SELECTION-SCREEN END OF BLOCK gb_z34.


*BlÖCKE SPERREN---------------------------------------------------------------------------------------------------------
FORM pf_update_screen.
  IF p_z30 EQ 'X' .
    CLEAR:
        s_blgnr,
        s_blgnr[].
    LOOP AT SCREEN.
      IF screen-group1 = 'Z34'.
        screen-input = '0'.
      ENDIF.
      IF screen-group1 = 'Z30'.
        screen-input = '1'.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ELSE .
    CLEAR:
      s_mloc,
      s_mloc[],
      p_asdate ,
      p_bverf.
    LOOP AT SCREEN.
      IF screen-group1 = 'Z34'.
        screen-input = '1'.
      ENDIF.
      IF screen-group1 = 'Z30'.
        screen-input = '0'.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.

* Beim Ausführen die Eingaben überprüfen und dementsprechend Error-Message senden-----------------
*FORM pf_check_input.
*  IF p_z30 EQ 'X'.
*    IF ( s_mloc IS INITIAL OR p_asdate IS INITIAL OR p_bverf IS INITIAL ).
*      MESSAGE 'Es fehlen Eingaben im oberen Block!' TYPE 'I'.
*CALL SELECTION-SCREEN 1000.
**CALL SCREEN 1000.
*    ENDIF.
**
*  ELSE.
*    IF s_blgnr IS INITIAL.
*      MESSAGE 'Es fehlen Eingaben in unteren Block!' TYPE 'I'.
*      CALL SELECTION-SCREEN 1000.
*    ENDIF.
*  ENDIF.
*ENDFORM.


*Beim Ausführen wird die Z-Nummer der Funktion mitgegeben um das dementprechend zu selektieren
FORM pf_run_program .
  DATA: ls_bdr_orders_hdr TYPE /idxgc/s_bdr_orders_hdr.
**--------------------------------fill data with fake -----------------
  ls_bdr_orders_hdr-proc_id     = '8020'.
  ls_bdr_orders_hdr-proc_type   = '22'.
  ls_bdr_orders_hdr-proc_view   = '4'.
  ls_bdr_orders_hdr-sender      = 'AD_DO_S_LF'.
  ls_bdr_orders_hdr-receiver    = 'AD_DO_S_NB'.
*  IF p_z14 IS NOT INITIAL.
*    ls_bdr_orders_hdr-docname_code = /idxgc/if_constants_ide=>gc_msg_category_z14.
  IF ( p_z30 = 'X').
    ls_bdr_orders_hdr-docname_code = 'Z30'.

*----------------------------Aufgabe 7-----------------------------------------------------------------------
    SELECT * FROM euitrans WHERE ext_ui IN @s_mloc INTO TABLE @lt_euitrans.
    LOOP AT lt_euitrans INTO ls_euitrans.
      ls_bdr_orders-int_ui = ls_euitrans-int_ui.
      ls_bdr_orders-ext_ui = ls_euitrans-ext_ui.
     ls_bdr_orders-execution_date = p_asdate.
    ls_bdr_orders-settl_proc = p_bverf.
    APPEND ls_bdr_orders TO lt_bdr_orders.
      ENDLOOP.
*--------------------------Aufgabe 7---------------------------------------------------------------------------

else.
      ls_bdr_orders_hdr-docname_code = 'Z34'.
    ENDIF.

    CALL FUNCTION 'REQUEST_DIALOG_AUFG'
      EXPORTING
        doctype           = doctype
        ls_bdr_orders_hdr = ls_bdr_orders_hdr.
*    ltt_bdr_orders_newhdr = lt_bdr_orders.
ENDFORM.


*EREIGNISSE---------------------------------------------------------------------------------------------------------------
AT SELECTION-SCREEN OUTPUT.
  PERFORM pf_update_screen.

*AT SELECTION-SCREEN ON RADIOBUTTON GROUP g1 .
*  PERFORM pf_update_screen.
*
*AT SELECTION-SCREEN ON p_asdate.
*  PERFORM pf_check_input.
*
*AT SELECTION-SCREEN ON BLOCK gb_z34.
*  PERFORM pf_check_input.

AT SELECTION-SCREEN .

*  IF p_z30 EQ 'X' AND sy-ucomm = 'ONLI'.
*    IF ( s_mloc IS INITIAL OR p_asdate IS INITIAL OR p_bverf IS INITIAL ).
*      MESSAGE 'Es fehlen Eingaben im oberen Block!' TYPE 'E'.
*    ENDIF.
*  ELSEIF sy-ucomm = 'ONLI'.
*    IF s_blgnr IS INITIAL.
*      MESSAGE 'Es fehlen Eingaben in unteren Block!' TYPE 'E'.
*    ENDIF.
*  ENDIF.
*  PERFORM pf_update_screen.


START-OF-SELECTION.

  PERFORM pf_run_program.


*AT SELECTION-SCREEN ON BLOCK gb_hdr .
**PERFORM pf_update_screen.
*
*AT SELECTION-SCREEN ON BLOCK gb_msg .
**PERFORM pf_check_input.
*
*AT SELECTION-SCREEN ON BLOCK gb_z34 .
*PERFORM pf_check_input.
