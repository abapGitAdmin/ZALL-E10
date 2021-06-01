*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTD_MIG_AUSZUG
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT /adesso/mtd_mig_auszug.

TYPE-POOLS: isu06.
* ALV
TYPE-POOLS: slis.

DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,
      gs_layout   TYPE slis_layout_alv,
      gs_keyinfo  TYPE slis_keyinfo_alv,
      gt_sort     TYPE slis_t_sortinfo_alv,
      gt_sp_group TYPE slis_t_sp_group_alv,
      gt_events   TYPE slis_t_event.


DATA: g_repid LIKE sy-repid.
DATA: g_tabname_header TYPE slis_tabname.
DATA: g_tabname TYPE slis_tabname.
DATA: g_error  TYPE char1.
DATA: g_noprot TYPE char1.

DATA: BEGIN OF t_out OCCURS 0,
        vertrag      TYPE ever-vertrag,
        sparte       TYPE ever-sparte,
        anlage       TYPE ever-anlage,
        einzdat      TYPE ever-einzdat,
        auszdat      TYPE ever-auszdat,
        auszbeleg    TYPE eausv-auszbeleg,
        status(2)    TYPE c,
        komment(120) TYPE c,
      END OF t_out.



DATA: wa_ever  TYPE ever,
      wa_eausv TYPE eausv.

DATA: it_vertrag TYPE isu06_mo_t_vertrag,
      lw_vertrag LIKE LINE OF it_vertrag,
      it_eausv   TYPE isu06_t_eausv,
      lw_eausv   LIKE LINE OF it_eausv.

DATA: wa_rel TYPE /adesso/mte_rel,
      it_rel TYPE STANDARD TABLE OF /adesso/mte_rel.

DATA: x_auto   TYPE isu06_moveout_auto,
      it_eablu TYPE isu17_eablu,
      wa_eablu TYPE eablu.

DATA: wa_eablg TYPE eablg,
      it_eablg TYPE STANDARD TABLE OF eablg.

DATA: wa_eabl TYPE eabl,
      it_eabl TYPE STANDARD TABLE OF eabl.

DATA: wa_eastl TYPE eastl,
      it_eastl TYPE STANDARD TABLE OF eastl.

DATA: wa_egerr TYPE egerr,
      it_egerr TYPE STANDARD TABLE OF egerr.

DATA:   g_var1(50) TYPE c,
        g_var2(50) TYPE c,
        g_var3(50) TYPE c,
        g_var4(50) TYPE c.

DATA: wa_ausz TYPE /adesso/mtd_ausz.

*DATA: p_stich TYPE sy-datum.

*************************************************************************
* Selektionsbildschirm
*************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK sel WITH FRAME TITLE text-001.
SELECT-OPTIONS: so_vert FOR lw_eausv-vertrag.
*PARAMETERS: so_vert LIKE lw_eausv-vertrag.
PARAMETERS: p_stich LIKE sy-datum DEFAULT '20151012'.
SELECTION-SCREEN END OF BLOCK sel.



*************************************************************************
* START-OF-SELECTION
*************************************************************************
START-OF-SELECTION.
  PERFORM select_data.
  PERFORM auszug_durchfuehren.



*************************************************************************
* END-OF-SELECTION
*************************************************************************
END-OF-SELECTION.
  PERFORM layout_build USING gs_layout.
  PERFORM fieldcat_build USING gt_fieldcat.
  PERFORM display_alv.


*&---------------------------------------------------------------------*
*&      Form  SELECT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM select_data .

* Relevante Verträge ermitteln
  SELECT * FROM /adesso/mte_rel INTO TABLE it_rel
    WHERE firma = 'WBD'
      AND object = 'MOVE_IN'
      AND obj_key IN so_vert.
*      AND obj_key = so_vert.


ENDFORM.                    " SELECT_DATA

*&---------------------------------------------------------------------*
*&      Form  AUSZUG_DURCHFUEHREN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM auszug_durchfuehren .

  DATA: lw_t100 TYPE t100.

* Schleife über die relevanten Verträge
  LOOP AT it_rel INTO wa_rel.

*   Vertrag ermitteln
    CLEAR wa_ever.
    SELECT SINGLE * FROM ever INTO wa_ever
      WHERE vertrag = wa_rel-obj_key.

*   Ist der Vertrag bereits in Auszugstabelle enthalten ?
    CLEAR wa_ausz.
    SELECT SINGLE * FROM /adesso/mtd_ausz INTO wa_ausz
     WHERE vertrag = wa_ever-vertrag
      AND  status = '99'.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING wa_ausz TO t_out.
      APPEND t_out.
      CONTINUE.
    ENDIF.

*  Relevantes Datum ermitteln
*  Das ist der Beginn der nächsten Abrechnungsperiode
    CLEAR p_stich.
    CALL FUNCTION 'ISU_BILLING_DATES_FOR_INSTLN'
      EXPORTING
        x_anlage          = wa_ever-anlage
*       X_DPC_MR          =
      IMPORTING
*       Y_BEGABRPE        =
*       Y_BEGNACH         =
*       Y_BEGEND          =
*       Y_LAST_ENDABRPE   =
*       Y_NEXT_CONTRACT   =
*       Y_PREVIOUS_BILL   =
*       Y_NO_CONTRACT     =
        y_default_date    = p_stich
      EXCEPTIONS
        no_contract_found = 1
        general_fault     = 2
        parameter_fault   = 3
        OTHERS            = 4.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.



* Gibt es eienen Auszug zum Stichtag ?
*    CLEAR wa_ausz.
*    SELECT SINGLE * FROM /adesso/mtd_ausz INTO wa_ausz
*     WHERE vertrag = wa_ever-vertrag
*      AND  status = '99'.
*    IF sy-subrc = 0.
*      MOVE-CORRESPONDING wa_ausz TO t_out.
*      APPEND t_out.
*      CONTINUE.
*    ENDIF.


*   Wenn ein Auszugsdatum vorliegt,
*   diesen Vertrag nicht weiter bearbeiten.
*   Daten in Ausgabetabelle schreiben
    IF wa_ever-auszdat NE '99991231'.
      t_out-vertrag = wa_ever-vertrag.
      t_out-anlage = wa_ever-anlage.
      t_out-sparte = wa_ever-sparte.
      t_out-einzdat = wa_ever-einzdat.
      t_out-auszdat = wa_ever-auszdat.
      IF wa_ever-auszdat = p_stich.
        t_out-status = '99'.
      ELSE.
        t_out-status = '98'.
        t_out-komment = 'Es wurde bereits ein Auszug durchgeführt'.
      ENDIF.
*    Auszugsbeleg holen.
      CLEAR wa_eausv.
      SELECT SINGLE * FROM eausv INTO wa_eausv
         WHERE vertrag = wa_ever-vertrag
        AND storausz = ' '.
      IF sy-subrc = 0.
        t_out-auszbeleg = wa_eausv-auszbeleg.
      ENDIF.
      MOVE-CORRESPONDING t_out TO wa_ausz.
      MODIFY /adesso/mtd_ausz FROM wa_ausz.
      APPEND t_out.
      CLEAR t_out.
      CONTINUE.
    ENDIF.


    CLEAR: lw_vertrag, it_vertrag.

    lw_vertrag-vertrag = wa_ever-vertrag.
    lw_vertrag-auszdat = p_stich.
    lw_vertrag-auszstat = '06'.

    APPEND lw_vertrag TO it_vertrag.




*   Für Ablesedaten zunächst die Geräte ermitteln
    CLEAR it_eastl.
    SELECT * FROM eastl INTO TABLE it_eastl
      WHERE anlage = wa_ever-anlage
        AND bis GT p_stich.

*   Über die logische Gerätenummer das Gerät aus der EGERR ermitteln
*   Wir haben hier nur Geräteinfosätze
    CLEAR it_egerr.
    LOOP AT it_eastl INTO wa_eastl.
      SELECT * FROM egerr INTO wa_egerr
       WHERE logiknr = wa_eastl-logiknr
        AND bis GE p_stich.
        APPEND wa_egerr TO it_egerr.
        CLEAR wa_egerr.
      ENDSELECT.
    ENDLOOP.

*   Alle Turnusablesungen für die Anlage ermitteln
*   Es können auch Zwischenablesungen mit Abrechnung sowie Einzüge,
*  die noch keine Turnusrechnung hatten vorkommen
    CLEAR it_eablg.
    SELECT * FROM eablg INTO TABLE it_eablg
      WHERE anlage = wa_ever-anlage
        AND ( ablesgr = '01' OR
              ablesgr = '02' OR
              ablesgr = '06' ).



*   Für jedes Equipment die Ablesungen holen
    CLEAR: it_eabl, it_eablu.
    LOOP AT it_egerr INTO wa_egerr.
      ON CHANGE OF wa_egerr-equnr.
        CLEAR it_eabl.
**      Aus allen Ableseergebnissen nur die Turnusablesungen lesen
        IF it_eablg IS NOT INITIAL.
          SELECT * FROM eabl INTO wa_eabl
            FOR ALL ENTRIES IN it_eablg
            WHERE equnr = wa_egerr-equnr
             AND ablbelnr = it_eablg-ablbelnr.
            APPEND wa_eabl TO it_eabl.
          ENDSELECT.
        ENDIF.
*       Aus allen Ablesungen die jüngste Ablesung ermitteln
*       Bei Wasserzählern haben wir nur ein Zählwerk
        SORT it_eabl BY adat DESCENDING.
        READ TABLE it_eabl INTO wa_eabl INDEX 1.
        IF sy-subrc = 0.
          MOVE-CORRESPONDING wa_eabl TO wa_eablu.
          wa_eablu-ablesgr = '03'.
          wa_eablu-zwstand = wa_eabl-v_zwstand.
          wa_eablu-adat = p_stich.
          wa_eablu-adatsoll = p_stich.
          APPEND wa_eablu TO it_eablu.
        ENDIF.
      ENDON.
    ENDLOOP.


*   Aufbau der Automationsdaten
    CLEAR x_auto.
    x_auto-use = 'X'.
    x_auto-okcode = 'SAVE'.
    x_auto-automr-autoeabl-ieablu = it_eablu.
    x_auto-automr-autoeabl-eabl_use = 'X'.
    x_auto-automr-autoeabl-eabl_okcode = 'SAVE'.
    x_auto-automr-autoeabl-eabl_done = 'X'.



*   Auszug durchführen
    CALL FUNCTION 'ISU_S_MOVE_OUT_CREATE'
      EXPORTING
*       X_AUSZBELEG    = ' '
        x_upd_online   = 'X'
        x_no_dialog    = 'X'
*       X_SUPPRESS_DIALOG       = ' '
        x_auto         = x_auto
*       X_AUTO_BAPI    =
*       X_NO_OTHER     = ' '
*       X_SUPPLIER_SWITCH       = ' '
*       X_SSWTCREASON  = ' '
*       X_FROMMOVEIN   = ' '
*       X_NO_COMMIT    = ' '
*       X_OBJ          =
*       X_OBJA         =
*       X_OBJP         =
*       X_OBJS         =
*       X_CONTR_EXT    = ' '
*     IMPORTING
*       Y_DB_UPDATE    =
*       Y_EXIT_TYPE    =
*       Y_CURFIELD     =
*       Y_CURLINE      =
*       Y_CURDYNNR     =
*       Y_NEW_EAUS     =
*       Y_INTLOG       =
      TABLES
        tx_vertrag     = it_vertrag
*       TX_OBJC        =
*       TX_OBJI        =
        ty_new_eausv   = it_eausv
*       TY_NEW_SM_ORDERS        =
*       TY_EMSG        =
      EXCEPTIONS
        existing       = 1
        foreign_lock   = 2
        number_error   = 3
        general_fault  = 4
        invalid_key    = 5
        param_error    = 6
        input_error    = 7
        not_authorized = 8
        action_failed  = 9
        billed         = 10
        OTHERS         = 11.
    IF sy-subrc <> 0.
      CLEAR lw_t100.
      SELECT SINGLE * FROM t100 INTO lw_t100
        WHERE sprsl = sy-langu
          AND arbgb = sy-msgid
          AND msgnr = sy-msgno.

      MOVE lw_t100-text TO t_out-komment.

      REPLACE ALL OCCURRENCES OF '&1' IN t_out-komment WITH sy-msgv1.
      REPLACE ALL OCCURRENCES OF '&2' IN t_out-komment WITH sy-msgv2.
      REPLACE ALL OCCURRENCES OF '&3' IN t_out-komment WITH sy-msgv3.
      REPLACE ALL OCCURRENCES OF '&3' IN t_out-komment WITH sy-msgv4.


*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

* Implement suitable error handling here
      t_out-auszdat = p_stich.
      t_out-vertrag = wa_ever-vertrag.
      t_out-sparte = wa_ever-sparte.
      t_out-anlage = wa_ever-anlage.
      t_out-einzdat = wa_ever-einzdat.
      t_out-status = '01'.
      MOVE-CORRESPONDING t_out TO wa_ausz.
      MODIFY /adesso/mtd_ausz FROM wa_ausz.
      APPEND t_out.
      CLEAR t_out.
      CONTINUE.

    ELSE.
      t_out-auszdat = p_stich.
      READ TABLE it_eausv INTO lw_eausv INDEX 1.
      t_out-auszbeleg = lw_eausv-auszbeleg.
      t_out-vertrag = lw_eausv-vertrag.
      t_out-auszdat = lw_eausv-auszdat.
      t_out-sparte = wa_ever-sparte.
      t_out-anlage = wa_ever-anlage.
      t_out-einzdat = wa_ever-einzdat.
      t_out-status = '99'.
      CONCATENATE 'Auszugsbeleg' lw_eausv-auszbeleg 'zum Vertrag' lw_eausv-vertrag
       INTO g_var1 SEPARATED BY space.
      CONCATENATE 'zum Auszugsdatum' lw_eausv-auszdat 'wurde angelegt'
        INTO g_var2 SEPARATED BY space.
      CONCATENATE g_var1 g_var2 INTO t_out-komment SEPARATED BY space.
      MOVE-CORRESPONDING t_out TO wa_ausz.
      MODIFY /adesso/mtd_ausz FROM wa_ausz.
      APPEND t_out.
      MESSAGE s000(e4) WITH g_var1 g_var2.
      CLEAR t_out.
*      PERFORM msg_add_with_level USING '1'.
    ENDIF.

  ENDLOOP.


ENDFORM.                    " AUSZUG_DURCHFUEHREN
*&---------------------------------------------------------------------*
*&      Form  LAYOUT_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_LAYOUT  text
*----------------------------------------------------------------------*
FORM layout_build  USING  ls_layout TYPE slis_layout_alv.

  ls_layout-zebra = 'X'.
  ls_layout-colwidth_optimize = 'X'.

ENDFORM.                    " LAYOUT_BUILD

*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_FIELDCAT  text
*----------------------------------------------------------------------*
FORM fieldcat_build  USING  lt_fieldcat TYPE slis_t_fieldcat_alv.

  DATA: ls_fieldcat TYPE slis_fieldcat_alv.

* Vertrag
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'VERTRAG'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'EVER'.
  APPEND ls_fieldcat TO lt_fieldcat.


* Sparte
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'SPARTE'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'EVER'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Anlage
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'ANLAGE'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'EVER'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Einzugsdatum alter Vertrag
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'EINZDAT'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-outputlen = '20'.
  ls_fieldcat-ref_tabname = 'EVER'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Auszugsdatum alter Vertrag
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'AUSZDAT'.
  ls_fieldcat-tabname = 'T_OUT'.
*  ls_fieldcat-emphasize = 'C50'.
  ls_fieldcat-ref_tabname = 'EVER'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Auszugsbeleg
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'AUSZBELEG'.
*  ls_fieldcat-emphasize = 'C50'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-ref_tabname = 'EAUSV'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Kommentar
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'STATUS'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-seltext_s = 'Status'.
  ls_fieldcat-seltext_m = 'Status'.
  APPEND ls_fieldcat TO lt_fieldcat.



* Kommentar
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'KOMMENT'.
  ls_fieldcat-tabname = 'T_OUT'.
  ls_fieldcat-seltext_s = 'Komment'.
  ls_fieldcat-seltext_m = 'Kommentar'.
  APPEND ls_fieldcat TO lt_fieldcat.

ENDFORM.                    " FIELDCAT_BUILD

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_alv .

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK  = ' '
*     I_BYPASSING_BUFFER = ' '
*     I_BUFFER_ACTIVE    = ' '
      i_callback_program = sy-repid
*     I_CALLBACK_PF_STATUS_SET          = ' '
*     I_CALLBACK_USER_COMMAND           = ' '
*     I_CALLBACK_TOP_OF_PAGE            = ' '
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME   =
*     I_BACKGROUND_ID    = ' '
*     I_GRID_TITLE       =
*     I_GRID_SETTINGS    =
      is_layout          = gs_layout
      it_fieldcat        = gt_fieldcat
*     IT_EXCLUDING       =
*     IT_SPECIAL_GROUPS  =
*     IT_SORT            =
*     IT_FILTER          =
*     IS_SEL_HIDE        =
*     I_DEFAULT          = 'X'
*     I_SAVE             = ' '
*     IS_VARIANT         =
*     IT_EVENTS          =
*     IT_EVENT_EXIT      =
*     IS_PRINT           =
*     IS_REPREP_ID       =
*     I_SCREEN_START_COLUMN             = 0
*     I_SCREEN_START_LINE               = 0
*     I_SCREEN_END_COLUMN               = 0
*     I_SCREEN_END_LINE  = 0
*     I_HTML_HEIGHT_TOP  = 0
*     I_HTML_HEIGHT_END  = 0
*     IT_ALV_GRAPHICS    =
*     IT_HYPERLINK       =
*     IT_ADD_FIELDCAT    =
*     IT_EXCEPT_QINFO    =
*     IR_SALV_FULLSCREEN_ADAPTER        =
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER           =
*     ES_EXIT_CAUSED_BY_USER            =
    TABLES
      t_outtab           = t_out
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


ENDFORM.                    " DISPLAY_ALV
