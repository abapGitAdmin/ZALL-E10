*&---------------------------------------------------------------------*
*& Report ZADE_ABT_MA
*&---------------------------------------------------------------------*

REPORT zade_abt_ma  LINE-SIZE 130  NO STANDARD PAGE HEADING.

*----------------------------------------------------------------------*
*- Strukturen, Variablen, Parameter -----------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b00  WITH FRAME  TITLE TEXT-b00.
PARAMETERS:
  p_obj_ab              RADIOBUTTON GROUP obj  DEFAULT 'X',
  p_obj_ma              RADIOBUTTON GROUP obj.

SELECTION-SCREEN SKIP 1.
PARAMETERS:
  p_fkt_01              RADIOBUTTON GROUP fkt  DEFAULT 'X',
  p_fkt_02              RADIOBUTTON GROUP fkt,
  p_fkt_03              RADIOBUTTON GROUP fkt,
  p_fkt_04              RADIOBUTTON GROUP fkt.
SELECTION-SCREEN END OF BLOCK b00.

SELECTION-SCREEN BEGIN OF BLOCK b01  WITH FRAME  TITLE TEXT-b01.
PARAMETERS:
  p_abtid               TYPE zade_abtid,
  p_abtbez              TYPE zade_abtbez.
SELECTION-SCREEN END OF BLOCK b01.

SELECTION-SCREEN BEGIN OF BLOCK b02  WITH FRAME  TITLE TEXT-b02.
PARAMETERS:
  p_manr                TYPE zade_manr,
  p_maabt               TYPE zade_abtid,
  p_maname              TYPE zade_maname.
SELECTION-SCREEN END OF BLOCK b02.

*----------------------------------------------------------------------*

DATA:
  gt_obj_abt            TYPE zadecl_abt_tt,
  gt_obj_ma             TYPE zadecl_ma_tt.

*----------------------------------------------------------------------*
*- Report-Ereignisse --------------------------------------------------*

INITIALIZATION.

START-OF-SELECTION.
  PERFORM start_of_selection.

END-OF-SELECTION.
  PERFORM end_of_selection.

*----------------------------------------------------------------------*
*- Forms --------------------------------------------------------------*

FORM start_of_selection.
  CLEAR: gt_obj_abt[], gt_obj_ma[].

  CASE abap_true.
    WHEN p_obj_ab.
      PERFORM abteilung.

    WHEN p_obj_ma.
      PERFORM mitarbeiter.

    WHEN OTHERS.
      RETURN.
  ENDCASE.
ENDFORM.

*----------------------------------------------------------------------*

FORM end_of_selection.
  DATA:
    lr_obj_abt          TYPE REF TO zadecl_abt,
    lr_obj_ma           TYPE REF TO zadecl_ma.

  GET TIME.
  FORMAT COLOR COL_BACKGROUND  INTENSIFIED ON.

  SKIP 1.
  WRITE: / 'System:',    AT 30 sy-sysid.
  WRITE: / 'Mandant:',   AT 30 sy-mandt.
  WRITE: / 'Benutzer:',  AT 30 sy-uname.
  WRITE: / 'Datum:',     AT 30 sy-datum.
  WRITE: / 'Uhrzeit:',   AT 30 sy-uzeit.

  IF sy-batch = abap_true.
    WRITE: / 'Modus:',   AT 30 'Hintergrundverarbeitung'.
  ELSE.
    WRITE: / 'Modus:',   AT 30 'Dialogverarbeitung'.
  ENDIF.

  SKIP 2.
  FORMAT COLOR COL_HEADING INTENSIFIED ON.
  CASE abap_true.
    WHEN p_fkt_01.  WRITE: / 'Funktion:',  AT 45 'Anzeigen'.
    WHEN p_fkt_02.  WRITE: / 'Funktion:',  AT 45 'Anlegen'.
    WHEN p_fkt_03.  WRITE: / 'Funktion:',  AT 45 'Ändern'.
    WHEN p_fkt_04.  WRITE: / 'Funktion:',  AT 45 'Löschen'.
  ENDCASE.

  SKIP 1.
  CASE abap_true.
    WHEN p_obj_ab.
      WRITE: / 'Abteilung:'.

      FORMAT COLOR COL_NORMAL  INTENSIFIED OFF.
      WRITE: / 'ID:',                  AT 45 p_abtid.
      WRITE: / 'Bezeichnung:',         AT 45 p_abtbez.

      IF gt_obj_abt[] IS NOT INITIAL.
        SKIP 1.
        LOOP AT gt_obj_abt  INTO lr_obj_abt.
          WRITE: / lr_obj_abt->gs_abt-id,  AT 10 lr_obj_abt->gs_abt-bez.
        ENDLOOP.
      ENDIF.

    WHEN p_obj_ma.
      WRITE: / 'Mitarbeiter:'.

      FORMAT COLOR COL_NORMAL  INTENSIFIED OFF.
      WRITE: / 'Nr.:',                 AT 45 p_manr.
      WRITE: / 'Name:',                AT 45 p_maname.
      WRITE: / 'Abteilungs-ID:',       AT 45 p_maabt.

      IF gt_obj_ma[] IS NOT INITIAL.
        SKIP 1.
        LOOP AT gt_obj_ma  INTO lr_obj_ma.
          WRITE: / lr_obj_ma->gs_ma-nr,  AT 10 lr_obj_ma->gs_ma-name,  AT 35 lr_obj_ma->gs_ma-abtid.
        ENDLOOP.
      ENDIF.
  ENDCASE.
ENDFORM.

*----------------------------------------------------------------------*

FORM abteilung.
  CASE abap_true.
    WHEN p_fkt_01.
      PERFORM abteilung_01.

    WHEN p_fkt_02.
      PERFORM abteilung_02.

    WHEN p_fkt_03.
      PERFORM abteilung_03.

    WHEN p_fkt_04.
      PERFORM abteilung_04.

    WHEN OTHERS.
      RETURN.
  ENDCASE.
ENDFORM.

*----------------------------------------------------------------------*

FORM abteilung_01.
  DATA:
    lr_abt              TYPE REF TO zadecl_abt.

  IF p_abtid <> zadecl_abt=>gc_abtid_initial.
    lr_abt = zadecl_abt=>create_abt( p_abtid ).
    APPEND lr_abt  TO gt_obj_abt.
    RETURN.
  ENDIF.

  gt_obj_abt[] = zadecl_abt=>create_abt_list( p_abtbez ).
ENDFORM.

*----------------------------------------------------------------------*

FORM abteilung_02.
  DATA:
    lr_abt              TYPE REF TO zadecl_abt,
    ls_abt              TYPE zade_abt.

  lr_abt = zadecl_abt=>create_abt( zadecl_abt=>gc_abtid_initial ).
  ls_abt = lr_abt->gs_abt.

  ls_abt-bez = p_abtbez.

  lr_abt->set_abt( ls_abt ).
  lr_abt->save_abt( ).

  APPEND lr_abt  TO gt_obj_abt.
ENDFORM.

*----------------------------------------------------------------------*

FORM abteilung_03.
  DATA:
    lr_abt              TYPE REF TO zadecl_abt,
    ls_abt              TYPE zade_abt.

  lr_abt = zadecl_abt=>create_abt( p_abtid ).
  IF lr_abt->gs_abt-id = zadecl_abt=>gc_abtid_initial.
    RETURN.
  ENDIF.

  ls_abt = lr_abt->gs_abt.

  ls_abt-bez = p_abtbez.

  lr_abt->set_abt( ls_abt ).
  lr_abt->save_abt( ).

  APPEND lr_abt  TO gt_obj_abt.
ENDFORM.

*----------------------------------------------------------------------*

FORM abteilung_04.
  DATA:
    lr_abt              TYPE REF TO zadecl_abt.

  lr_abt = zadecl_abt=>create_abt( p_abtid ).
  IF lr_abt->gs_abt-id = zadecl_abt=>gc_abtid_initial.
    RETURN.
  ENDIF.

  lr_abt->delete_abt( ).

  APPEND lr_abt  TO gt_obj_abt.
ENDFORM.

*----------------------------------------------------------------------*

FORM mitarbeiter.
  CASE abap_true.
    WHEN p_fkt_01.
      PERFORM mitarbeiter_01.

    WHEN p_fkt_02.
      PERFORM mitarbeiter_02.

    WHEN p_fkt_03.
      PERFORM mitarbeiter_03.

    WHEN p_fkt_04.
      PERFORM mitarbeiter_04.

    WHEN OTHERS.
      RETURN.
  ENDCASE.

ENDFORM.

*----------------------------------------------------------------------*

FORM mitarbeiter_01.
  DATA:
    lr_ma              TYPE REF TO zadecl_ma.

  IF p_manr <> zadecl_ma=>gc_manr_initial.
    lr_ma = zadecl_ma=>create_ma( p_manr ).
    APPEND lr_ma  TO gt_obj_ma.
    RETURN.
  ENDIF.

  gt_obj_ma[] = zadecl_ma=>create_ma_list(
                    iv_maname = p_maname
                    iv_abtid  = p_maabt ).
ENDFORM.

*----------------------------------------------------------------------*

FORM mitarbeiter_02.
  DATA:
    lr_ma               TYPE REF TO zadecl_ma,
    ls_ma               TYPE zade_ma.

  lr_ma = zadecl_ma=>create_ma( zadecl_ma=>gc_manr_initial ).
  ls_ma = lr_ma->gs_ma.

  ls_ma-name  = p_maname.
  ls_ma-abtid = p_maabt.

  lr_ma->set_ma( ls_ma ).
  lr_ma->save_ma( ).

  APPEND lr_ma  TO gt_obj_ma.
ENDFORM.

*----------------------------------------------------------------------*

FORM mitarbeiter_03.
  DATA:
    lr_ma               TYPE REF TO zadecl_ma,
    ls_ma               TYPE zade_ma.

  lr_ma = zadecl_ma=>create_ma( p_manr ).
  IF lr_ma->gs_ma-nr = zadecl_ma=>gc_manr_initial.
    RETURN.
  ENDIF.

  ls_ma = lr_ma->gs_ma.

  ls_ma-name  = p_maname.
  ls_ma-abtid = p_maabt.

  lr_ma->set_ma( ls_ma ).
  lr_ma->save_ma( ).

  APPEND lr_ma  TO gt_obj_ma.
ENDFORM.

*----------------------------------------------------------------------*

FORM mitarbeiter_04.
  DATA:
    lr_ma               TYPE REF TO zadecl_ma.

  lr_ma = zadecl_ma=>create_ma( p_manr ).
  IF lr_ma->gs_ma-nr = zadecl_ma=>gc_manr_initial.
    RETURN.
  ENDIF.

  lr_ma->delete_ma( ).

  APPEND lr_ma  TO gt_obj_ma.
ENDFORM.

*----------------------------------------------------------------------*
