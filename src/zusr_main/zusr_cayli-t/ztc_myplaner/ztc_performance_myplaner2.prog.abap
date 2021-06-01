************************************************************************
****
*            _
*   __ _  __| | ___  ___ ___  ___
*  / _` |/ _` |/ _ \/ __/ __|/ _ \
* | (_| | (_| |  __/\__ \__ \ (_) |
*  \__,_|\__,_|\___||___/___/\___/
************************************************************************
*******
*
*
*&
************************************************************************
*******
REPORT ztc_performance_myplaner2.

DATA: gv_ext_ui      TYPE ext_ui,
      gs_selection   TYPE /adz/s_mdc_sel,
      gr_custom_cont TYPE REF TO cl_gui_custom_container,
      gr_mdc_cntr    TYPE REF TO /adz/cl_mdc_cntr,
      ok_code        TYPE sy-ucomm.



START-OF-SELECTION.
CALL SCREEN 0100.









































*
*DATA: lt_planer TYPE STANDARD TABLE OF ztc_t_myplaner WITH DEFAULT KEY.
*DATA: o_alv TYPE REF TO cl_gui_alv_grid.
*DATA: o_dock TYPE REF TO cl_gui_docking_container.
*DATA: o_txt TYPE REF TO cl_gui_textedit.
*
*DATA: lr_obj TYPE REF TO ZTC_CL_MYPLANER.
*
*  DATA lv_task TYPE ztc_t_myplaner.
*DATA lv_tasktext TYPE char100.
*
**PARAMETERS: rb_txt RADIOBUTTON GROUP rbg DEFAULT 'X' USER-COMMAND rbc.
**PARAMETERS: rb_alv RADIOBUTTON GROUP rbg.
*
*PARAMETERS: rb_new RADIOBUTTON GROUP rbg2 DEFAULT 'X' USER-COMMAND rbc2.
*PARAMETERS: rb_edit RADIOBUTTON GROUP rbg2.
*PARAMETERS: rb_show RADIOBUTTON GROUP rbg2.
*SELECTION-SCREEN SKIP.
*SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME.
*PARAMETERS: p_idpla      TYPE /adz/de_item_id MODIF ID m1,
*            p_prio       TYPE cmd_lognumc5 MODIF ID m1,
*            p_dat_s      TYPE dats MODIF ID m1,
*            p_dat_e      TYPE dats MODIF ID m1,
*            p_uz_s       TYPE utime MODIF ID m1,
*            p_uz_e       TYPE utime MODIF ID m1,
*            p_usr        TYPE /bcv/qrm_cache_uname MODIF ID m1,
*            p_status(10) AS LISTBOX VISIBLE LENGTH 10 DEFAULT 'offen' MODIF ID m1.
*SELECTION-SCREEN END OF BLOCK b1.
*
*SELECTION-SCREEN BEGIN OF LINE.
*SELECTION-SCREEN PUSHBUTTON 2(30) b_entry USER-COMMAND entry.
*SELECTION-SCREEN PUSHBUTTON 33(30) b_import USER-COMMAND entry.
*SELECTION-SCREEN PUSHBUTTON 64(30) b_export USER-COMMAND entry.
*SELECTION-SCREEN END OF LINE.
*START-OF-SELECTION.
*AT SELECTION-SCREEN OUTPUT.
*   LOOP AT SCREEN INTO DATA(wa_screen).
*
*     IF rb_show = 'X' AND wa_screen-group1 = 'M1'.
*       wa_screen-active = '0'.
*     ENDIF.
*     MODIFY SCREEN FROM wa_screen.
*
*
*
*  ENDLOOP.
*
*AT SELECTION-SCREEN.
*
*   lr_obj = NEW #( lv_task ).
*
* CALL METHOD ztc_cl_myplaner=>get_thema
*    EXPORTING
*      p_o_txt = o_txt
*    IMPORTING
*      p_text  = lv_tasktext.
*
* lv_task = VALUE #( id_planer = p_idpla
*                     prioritaet = p_prio
*                     datum_start = p_dat_s
*                     datum_ende = p_dat_e
*                     uhrzeit_start = p_uz_s
*                     uhrzeit_ende = p_uz_e
*                     beteiligte = p_usr
*                     status = p_status
*                     thema = lv_tasktext ).
*
*
*
** wenn Radiobuttons geklickt
*  IF sy-ucomm = 'RBC2'.
** je nach Radiobutton die GUI-Controls ein-/ausblenden
*    CASE abap_true.
*      WHEN rb_edit OR rb_show.
*        o_txt->set_visible( abap_false ).
*        o_alv->set_visible( abap_true ).
*      WHEN rb_new.
*        o_txt->set_visible( abap_true ).
*        o_alv->set_visible( abap_false ).
*    ENDCASE.
*  ELSEIF sy-ucomm = 'ENTRY'.
*    lr_obj->insert_table( lv_task ).
*  ENDIF.
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*INITIALIZATION.
*b_entry = 'Eintragen'.
*b_import = 'Importieren'.
*b_export = 'Exportieren'.
*
*  IF NOT o_dock IS BOUND.
** Containerobjekt erzeugen
*  o_dock = NEW #( side  = cl_gui_docking_container=>dock_at_bottom
*                    ratio = 50 ).
*
** Texteditor erzeugen
*    o_txt = NEW #( parent = o_dock ).
*
** Daten für ALV holen
*    SELECT *
*      INTO TABLE @lt_planer
*      FROM ztc_t_myplaner
*      UP TO 100 ROWS.
*
** ALV-Gitter erzeugen
*    o_alv = NEW #( i_parent = o_dock ).
*    o_alv->set_table_for_first_display( EXPORTING
*                                          i_structure_name = 'ztc_t_myplaner'
*                                        CHANGING
*                                          it_outtab = lt_planer ).
*  ENDIF.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'STATUS_0100'.
  SET TITLEBAR 'TITLE_0100'.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  UCOMM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ucomm INPUT.

  CASE sy-ucomm.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'NEW'.
      CALL SCREEN '0200'.
    WHEN 'ONLI'.
      CALL SCREEN '0300'.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS 'STATUS_0200'.
  SET TITLEBAR 'TITLE_0200'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.
  CASE sy-ucomm.
    WHEN 'ONLI'.
      CALL SCREEN '0300'.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0300 OUTPUT.
  SET PF-STATUS 'STATUS_0300'.
  SET TITLEBAR 'TITLE_0300'.
ENDMODULE.

MODULE output OUTPUT.
  IF gr_custom_cont IS NOT BOUND.
    CREATE OBJECT gr_custom_cont
      EXPORTING
        container_name = 'CCONT'.
  ENDIF.
  gr_mdc_cntr = /adz/cl_mdc_cntr=>get_instance(
      ir_cont      = gr_custom_cont
      is_selection = gs_selection ).
ENDMODULE.



*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0300 INPUT.
  CASE sy-ucomm.
    WHEN 'ONLI'.
      CALL SCREEN '0300'.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
