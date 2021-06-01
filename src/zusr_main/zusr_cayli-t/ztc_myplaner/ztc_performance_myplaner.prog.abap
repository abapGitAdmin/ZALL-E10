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
REPORT ztc_performance_myplaner.

"Include machen mit Selection Befehlen
DATA: it_plan TYPE STANDARD TABLE OF ztc_t_myplaner WITH DEFAULT KEY.
DATA: o_dock TYPE REF TO cl_gui_docking_container.
DATA: o_txt TYPE REF TO cl_gui_textedit.
DATA: o_alv TYPE REF TO cl_gui_alv_grid.

*************************************************************************************SELECTION-SCREEN COMMENT

SELECTION-SCREEN SKIP.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME.
PARAMETERS: p_idpla    TYPE /adz/de_item_id MODIF ID m1,
            p_prio     TYPE cmd_lognumc5 MODIF ID m1,
            p_dat_s    TYPE dats MODIF ID m1,
            p_dat_e    TYPE dats MODIF ID m1,
            p_uz_s     TYPE utime MODIF ID m1,
            p_uz_z     TYPE utime MODIF ID m1,
            p_usr      TYPE /bcv/qrm_cache_uname MODIF ID m1,
            status(10) AS LISTBOX VISIBLE LENGTH 10 DEFAULT 'offen' MODIF ID m1.
SELECTION-SCREEN END OF BLOCK b1.





SELECTION-SCREEN SKIP.
SELECTION-SCREEN PUSHBUTTON 1(10) eint USER-COMMAND gt.
SELECTION-SCREEN SKIP.
SELECTION-SCREEN PUSHBUTTON 1(10) bear USER-COMMAND st.



PARAMETERS: rb_txt RADIOBUTTON GROUP rbg DEFAULT 'X' USER-COMMAND rbc.
PARAMETERS: rb_alv RADIOBUTTON GROUP rbg.

AT SELECTION-SCREEN OUTPUT.


*  LOOP AT SCREEN INTO DATA(wa_screen).
*
*    IF wa_screen-group1 = 'M1' AND lv_notiz = 'X'.
*      wa_screen-active = '0'.
*
*    ELSEIF wa_screen-group1 = 'M2' AND lv_aufg = 'X'.
*      wa_screen-active = '0'.
*
*    ENDIF.
*    MODIFY SCREEN FROM wa_screen.
*
*
*  ENDLOOP.


*  IF NOT o_dock IS BOUND.
*
** Containerobjekt erzeugen
*    o_dock = NEW #( side  = cl_gui_docking_container=>dock_at_top
*                    ratio = 30 ).
*
** Texteditor erzeugen
*    o_txt = NEW #( parent = o_dock ).
*
*
** Daten für ALV holen
*    SELECT *
*      INTO TABLE @it_plan
*      FROM ztc_t_myplaner
*      UP TO 100 ROWS.
*
** ALV-Gitter erzeugen
*    o_alv = NEW #( i_parent = o_dock ).
*    o_alv->set_table_for_first_display( EXPORTING
*                                          i_structure_name = 'ztc_t_myplaner'
*                                        CHANGING
*                                          it_outtab = it_plan ).
*
*  ENDIF.







  DATA:
    name  TYPE vrm_id,
    list  TYPE vrm_values,
    value TYPE vrm_value.
  name = 'STATUS'.

  value-key = '1'.
  value-text = 'offen'.
  APPEND value TO list.


  value-key = '2'.
  value-text = 'in Bearbeitung'.
  APPEND value TO list.

  value-key = '3'.
  value-text = 'fertiggestellt'.

  APPEND value TO list.




  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = name
      values          = list
    EXCEPTIONS
      id_illegal_name = 0
      OTHERS          = 0.

START-OF-SELECTION.
 IF NOT o_dock IS BOUND.

* Containerobjekt erzeugen
    o_dock = NEW #( side  = cl_gui_docking_container=>dock_at_top
                    ratio = 30 ).

* Texteditor erzeugen
    o_txt = NEW #( parent = o_dock ).


* Daten für ALV holen
    SELECT *
      INTO TABLE @it_plan
      FROM ztc_t_myplaner
      UP TO 100 ROWS.

* ALV-Gitter erzeugen
    o_alv = NEW #( i_parent = o_dock ).
    o_alv->set_table_for_first_display( EXPORTING
                                          i_structure_name = 'ztc_t_myplaner'
                                        CHANGING
                                          it_outtab = it_plan ).

  ENDIF.





AT SELECTION-SCREEN.
  CASE sy-ucomm.
    WHEN 'ST'.
      PERFORM set.
    WHEN 'GT'.                                                                                      "get variante?
      PERFORM get.
    WHEN 'RBC'.
      CASE abap_true.
        WHEN rb_txt.
          o_txt->set_visible( abap_true ).
          o_alv->set_visible( abap_false ).
        WHEN rb_alv.
          o_txt->set_visible( abap_false ).
          o_alv->set_visible( abap_true ).

      ENDCASE.

  ENDCASE.



                                                                               "bei Radio button refresh



  " schreiben in Textfeld

FORM set.
  SELECT SINGLE thema
    FROM ztc_t_myplaner
  INTO @DATA(thema_aus_db).



  DATA text TYPE TABLE OF char100.
  DATA wa LIKE LINE OF text.

  wa = thema_aus_db.

  APPEND wa TO text.

  o_txt->set_text_as_r3table(
    EXPORTING
      table           =   text
  ).
ENDFORM.





* lesen aus Textfeld
FORM get.
  DATA gettext TYPE TABLE OF char100.
  DATA text_table TYPE char100.

  "gucken, ob das mit str nicht besser ist
  o_txt->get_text_as_stream(
     IMPORTING
       text   =   gettext
  ).

  IF gettext IS INITIAL.                                                                          " wie besser?
    DATA empty TYPE char100.
    empty = ' '.
    APPEND empty TO gettext.
  ENDIF.

  text_table = gettext[ 1 ].

  DATA itab TYPE TABLE OF ztc_t_myplaner.
  DATA wa TYPE ztc_t_myplaner.
  wa-id_planer = p_idpla.
  wa-id_task = p_idpla.
  wa-status = status.
  wa-prioritaet = p_prio.
  wa-beteiligte = p_usr.
  wa-thema = text_table.

  APPEND wa TO itab.

  INSERT ztc_t_myplaner FROM TABLE itab.
  PERFORM notif USING p_usr.
ENDFORM.


FORM notif USING p_uname.

  DATA uname TYPE sy-uname.
  uname = p_uname.


*CALL FUNCTION 'TH_POPUP'
*  EXPORTING
*    client         = sy-mandt " kann auch freigelassen werden
*    user           = uname
*    message        = 'Notiz'
**   MESSAGE_LEN    = 0
**   CUT_BLANKS     = ' '
*  EXCEPTIONS
*    user_not_found = 1
*    OTHERS         = 2.
*IF sy-subrc NE 0.
*  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*ENDIF.


ENDFORM.






"Wertehilfe als Struktur wie E03 Z01 Z02...
"Klassen machen
"Events einführen


INITIALIZATION.
  eint = 'Eintragen'.
  bear = 'Bearbeiten'.
