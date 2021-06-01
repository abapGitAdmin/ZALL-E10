*&---------------------------------------------------------------------*
*& Report  /ADESSO/EDISC_TEST
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT  /ADESSO/EDISCT_TEST.

TYPE-POOLS: slis, isu05.
TABLES: ediscdoc, /ADESSO/SPT_EDI2, efkkop.

CONSTANTS: i_save VALUE 'A'.

DATA: itab LIKE STANDARD TABLE OF /ADESSO/SPT_EDI2,
      itab2 LIKE itab,
      wa_itab LIKE /ADESSO/SPT_EDI2,
      it_itab LIKE STANDARD TABLE OF /ADESSO/SPT_EDI2,
      wa_adesso_edisc2 TYPE /ADESSO/SPT_EDI2,
      wa_ediscdoc TYPE ediscdoc,
      it_ediscdoc TYPE TABLE OF ediscdoc,
      i_anzahl TYPE i,
      i_schwelle TYPE i,
      i_percentage TYPE p,
      i_printparams TYPE eprintparams,
      it_dd07 TYPE STANDARD TABLE OF dd07v,
      wa_dd07 TYPE dd07v,
      i_kz_fehler TYPE kennzx,
      is_variant TYPE disvariant,
      it_error TYPE STANDARD TABLE OF char480,
      i_error TYPE char480,
      it_ediscordstate TYPE STANDARD TABLE OF ediscordstate,
      is_allow TYPE RANGE OF ediscordstate-ordstate WITH HEADER LINE,
      gd_form TYPE formkey,
      eanl_count TYPE i,
      it_adesso_edisc2 TYPE /ADESSO/SPT_EDI2.

DATA: lf_customizing TYPE /ADESSO/SPT_EDCU.
CONSTANTS: co_schwelle TYPE i VALUE 5.   " Schwelle für Fortschrittsanzeige

SELECTION-SCREEN BEGIN OF BLOCK s1 WITH FRAME TITLE text-s01.
SELECT-OPTIONS: s_discno FOR ediscdoc-discno,
                s_status FOR ediscdoc-status,
                s_discpr FOR ediscdoc-discprocv.
SELECTION-SCREEN SKIP 1.
SELECT-OPTIONS: s_gpart FOR /ADESSO/SPT_EDI2-gpart,
                s_vkont FOR /ADESSO/SPT_EDI2-vkont,
                s_bukrs FOR /ADESSO/SPT_EDI2-bukrs.

SELECTION-SCREEN SKIP 1.
PARAMETERS:     p_op     TYPE kennzx AS CHECKBOX.  " DEFAULT 'X'.
SELECT-OPTIONS: s_limit  FOR /ADESSO/SPT_EDI2-sum_op NO-EXTENSION.

SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN COMMENT /1(30) text-clf.
PARAMETERS:
  p_lart01 TYPE c RADIOBUTTON GROUP lart DEFAULT 'X' ,
  p_lart99 TYPE c RADIOBUTTON GROUP lart.

SELECTION-SCREEN SKIP 1.
PARAMETERS:
*                p_reorg  TYPE kennzx,
                p_varian TYPE slis_vari.
SELECTION-SCREEN END OF BLOCK s1.

INITIALIZATION.
  CLEAR: s_status, s_status[].

  s_status-sign   = 'I'.
  s_status-option = 'BT'.
  s_status-low    = '00'.
  s_status-high   = '30'.
  APPEND s_status.

  LOOP AT SCREEN.
    IF screen-group1 = 'SC1'.
      screen-intensified = '1'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_varian.
  PERFORM f4_report_variant.


START-OF-SELECTION.

  PERFORM init.

  CLEAR i_kz_fehler.

* alle aktuellen Sperrbelege lesen
  SELECT * FROM ediscdoc INTO TABLE it_ediscdoc
    WHERE discno    IN s_discno
      AND status    IN s_status
      AND discprocv IN s_discpr.

  DESCRIBE TABLE it_ediscdoc LINES i_anzahl.
  CLEAR: i_schwelle,
         i_percentage.
  i_schwelle = co_schwelle.

  LOOP AT it_ediscdoc INTO wa_ediscdoc.
    CLEAR wa_itab.

    SELECT SINGLE * FROM /ADESSO/SPT_EDI2 INTO wa_itab
        WHERE discno EQ wa_ediscdoc-discno.


    IF sy-subrc EQ 0
      AND sy-batch IS INITIAL
      .

* Sperrbeleg bekannt, daher hier nur Aktualisierung von Status u. Änderungsdatum
* (alle anderen Daten (bis auf offene/fällige Posten) bleiben "statisch )

*     Es kann mehrere Einträge zur discno geben, da Anlage auch Schlüssel
*     LOOP bei erfolgreicher Selektion ergänzt

      SELECT * FROM /ADESSO/SPT_EDI2 INTO TABLE it_itab
        WHERE discno EQ wa_ediscdoc-discno.

      LOOP AT it_itab INTO wa_itab.

        IF wa_ediscdoc-aedat NE wa_itab-aedat
          OR wa_ediscdoc-status NE wa_itab-status.
*    hier feststellen, ob ggf. weitere Änderungen zu aktualisieren sind
          wa_itab-aedat  = wa_ediscdoc-aedat.
          wa_itab-status = wa_ediscdoc-status.
        ENDIF.
        PERFORM forderungen_lesen CHANGING wa_itab.
        PERFORM set_icon_status   CHANGING wa_itab.
        PERFORM set_langtexte     CHANGING wa_itab.

        MODIFY it_itab FROM wa_itab.
      ENDLOOP.

    ELSE.
* Sperrbeleg unbekannt oder Batch-Lauf, daher kompletter Aufbau der Daten
      wa_itab-discno = wa_ediscdoc-discno.
      PERFORM read_discdoc TABLES it_itab CHANGING wa_itab.  " 2012-01-24, Krämer: vorher itab.
    ENDIF.

    APPEND LINES OF it_itab TO itab.

    PERFORM indicator USING sy-tabix.
  ENDLOOP.

* Daten in DB für den beschleunigten Zugriff zwischenspeichern
  CLEAR wa_itab.
  MODIFY itab FROM wa_itab TRANSPORTING mark error WHERE mandt EQ sy-mandt.
  MODIFY /ADESSO/SPT_EDI2 FROM TABLE itab.

*>> 2012-01-24, 17:00, Krämer
* Achtung:
*   Die aus der Laufart zum Zählpunkt gewonnenen Werte können nicht
*   in der adesso_edisc2 abgespeichert werden.  Tatsächlich steht nach
*   dem ersten Lauf nur noch die Anlage mit der höchsten Nummer je
*   Sperrbeleg in der Tabelle.  Der Lauf zum Sperrbeleg zeigt dies.
*   Die Geräte müssen also jedes Mal neu nachgelesen werden, auch
*   wenn die Daten seit dem letzten unverändert geblieben sind.
*   Um in der Tabelle gespeichert werden zu können, müsste das
*   Feld "Anlage" eine Schlüsselfeld sein.
*<< 2012-01-24, 17:00, Krämer


* Nur Sperrbelege ausgeben, die über der Betragsgrenze liegen
  DELETE itab WHERE sum_op NOT IN s_limit AND sum_op GE 0.
  DELETE itab WHERE gpart NOT IN s_gpart.
  DELETE itab WHERE vkont NOT IN s_vkont.
  DELETE itab WHERE ( bukrs NOT IN s_bukrs AND bukrs NE space ).

* ALV-Tabelle ausgeben
  IF sy-batch IS INITIAL.
    PERFORM error_message.
    SORT itab BY discno ASCENDING.

    itab2[] = itab[].
    IF NOT p_lart01 IS INITIAL.
      DELETE ADJACENT DUPLICATES FROM itab COMPARING discno.
    ENDIF.

    PERFORM ausgabe.

*>> 2012-01-25, 10:45, Krämer
    LOOP AT itab INTO wa_itab.
      MODIFY TABLE itab2 FROM wa_itab.
    ENDLOOP.
*<< 2012-01-25, 10:45, Krämer
  ENDIF.

END-OF-SELECTION.
* Daten in DB für den beschleunigten Zugriff zwischenspeichern
* (Aufruf hier nochmal, um im Dialog geänderte Daten zu sichern)

*>> Krämer:  Kommentar siehe oben <<*

  CLEAR wa_itab.
  MODIFY itab2 FROM wa_itab TRANSPORTING mark error WHERE mandt EQ sy-mandt.
  MODIFY /ADESSO/SPT_EDI2 FROM TABLE itab2.

* Tabelle /ADESSO/SPT_EDI2 reorganisieren (alt: manuell auf Selektionsbildschirm einstellen - neu: matisch im Batchlauf)
*  IF NOT p_reorg IS INITIAL.
  IF NOT sy-batch IS INITIAL.
    PERFORM reorg_adesso_edisc.
  ENDIF.

  LOOP AT it_error INTO i_error.
    WRITE / i_error.
  ENDLOOP.

************************************************************************
************************************************************************
************************************************************************
************************************************************************
************************************************************************
************************************************************************
************************************************************************
************************************************************************
************************************************************************
* ab hier FORM-Routinen
FORM init.
  PERFORM read_customizing.
  PERFORM read_ediscordstate.

* Domänen-Texte lesen
  PERFORM langtexte_lesen USING 'DISCREASON' 'DCNREASTXT'.
  PERFORM langtexte_lesen USING 'EDCDOCSTAT' 'STATUSTEXT'.
ENDFORM.                    "init
*&---------------------------------------------------------------------*
*&      Form  read_EDISCORDSTATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM read_ediscordstate.
  DATA: wa_ediscordstate TYPE ediscordstate.
  SELECT * FROM ediscordstate INTO TABLE it_ediscordstate.

*>> 2012-01-24, 10:35, Krämer:  CLEAR ergänzt und aus LOOP gezogen
  CLEAR: is_allow, is_allow[].

  is_allow-sign = 'I'.
  is_allow-option = 'EQ'.
*<< 2012-01-24, 10:35, Krämer

* alle Status für erfolgreiche Sperraktionen ermitteln
  LOOP AT it_ediscordstate INTO wa_ediscordstate
    WHERE objallow NE space.
    is_allow-low = wa_ediscordstate-ordstate.
    APPEND is_allow.
  ENDLOOP.

ENDFORM.                    "read_EDISCORDSTATE

*&---------------------------------------------------------------------*
*&      Form  read_customizing
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM read_customizing.

  SELECT SINGLE * FROM /ADESSO/SPT_EDCU INTO lf_customizing.

ENDFORM.                    "read_customizing



*&---------------------------------------------------------------------*
*&      Form  user_command
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->R_UCOMM      text
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM user_command USING r_ucomm LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.

  CASE r_ucomm.
    WHEN 'REFRESH'.
      PERFORM ucomm_refresh CHANGING rs_selfield.
    WHEN 'FPL9'.
      PERFORM ucomm_fpl9 USING rs_selfield.
    WHEN 'EDIT'.
      PERFORM ucomm_edit CHANGING rs_selfield.
    WHEN 'COMPLETE'.
      PERFORM ucomm_complete CHANGING rs_selfield.
    WHEN 'POST'.
      PERFORM ucomm_post CHANGING rs_selfield.
    WHEN 'ORDER'.
      PERFORM ucomm_order CHANGING rs_selfield.
    WHEN 'ORDER_NETZ'.
      PERFORM ucomm_order_netz CHANGING rs_selfield.
    WHEN 'CLERK'.
      PERFORM ucomm_clerk CHANGING rs_selfield.
    WHEN OTHERS.
* Hotspot oder Doppelklick
      CASE  rs_selfield-fieldname.
        WHEN 'ICON'.
          READ TABLE itab INTO wa_itab INDEX rs_selfield-tabindex.
          PERFORM discdoc_change USING rs_selfield
                                       wa_itab.
        WHEN 'DISCNO'.
          PERFORM display_discno CHANGING rs_selfield wa_itab.
        WHEN 'GPART'.
          PERFORM display_gpart USING rs_selfield.
        WHEN 'VKONT'.
          PERFORM display_vkont USING rs_selfield.
        WHEN 'VERTRAG'.
          PERFORM display_vertrag USING rs_selfield.
        WHEN 'ANLAGE'.
          PERFORM display_anlage USING rs_selfield.
        WHEN 'GERAET'.
          PERFORM display_geraet USING rs_selfield.
        WHEN 'VSTELLE'.
          PERFORM display_vstelle USING rs_selfield.
        WHEN OTHERS.
      ENDCASE.
  ENDCASE.

  PERFORM error_message.
ENDFORM.                    "USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  read_discdoc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM read_discdoc
*>> 2012-01-24, Krämer:  Schnittstellenerw. auch bei Aufruf ergänzt
  TABLES
    itb_adesso_edisc2 STRUCTURE /ADESSO/SPT_EDI2
*<< 2012-01-24, Krämer
  CHANGING
    i_adesso_edisc2 TYPE /ADESSO/SPT_EDI2.

  DATA: y_obj TYPE isu05_discdoc_internal,
        wa_ekun   TYPE ekun,
        wa_fkkvkp TYPE fkkvkp,
        wa_ever   TYPE ever,
        it_eanl    TYPE STANDARD TABLE OF v_eanl, "2012-01-24, Krämer
        wa_eanl   TYPE v_eanl,
        wa_eastl  TYPE eastl,
        wa_eger   TYPE v_eger,
        i_kz_abschluss TYPE kennzx,
        wa_ediscact TYPE ediscact.

  CLEAR: y_obj,
        wa_ekun,
        wa_fkkvkp,
        wa_ever,
        wa_eanl,
        wa_eastl,
        wa_eger,
        i_kz_abschluss,
        itb_adesso_edisc2,
        itb_adesso_edisc2[].

  PERFORM open_discdoc CHANGING i_adesso_edisc2
                                y_obj.

* Sperrbeleg abschließen?

  PERFORM check_ediscdoc CHANGING y_obj
                                  i_kz_abschluss.

  IF NOT i_kz_abschluss IS INITIAL
    AND NOT lf_customizing-compl IS INITIAL.
    PERFORM edit_discdoc USING i_adesso_edisc2
                               '99'.

    i_adesso_edisc2-status = '99'.
* komplettes Nachlesen des Sperrbeleg-Umfeldes sollte nicht nötig sein, da nur Änderung des us
    EXIT.
  ENDIF.


***>> 2012-01-24, 14:10, Krämer
**    Fallunterscheidung wieder auskommentiert, da bei neuem Sperrbeleg
**    stets /alle/ Anlagen hinzugelesen werden sollen
**
**  IF NOT p_lart01 IS INITIAL.
**    READ TABLE y_obj-denv-ieanl   INDEX 1 INTO wa_eanl.  "Ursprüngliche Zeile
**    APPEND wa_eanl TO it_eanl.
**  ELSEIF NOT p_lart99 IS INITIAL.
    MOVE y_obj-denv-ieanl TO it_eanl.
**  ENDIF.
**<< 2012-01-24, 14:10, Krämer


  READ TABLE y_obj-denv-iekun   INDEX 1 INTO wa_ekun.
  READ TABLE y_obj-denv-ieger   INDEX 1 INTO wa_eger.
  READ TABLE y_obj-denv-ifkkvkp INDEX 1 INTO wa_fkkvkp.

  MOVE-CORRESPONDING wa_eger   TO i_adesso_edisc2.  " Anlagenzuordnung ergänzen!
  MOVE-CORRESPONDING wa_ekun   TO i_adesso_edisc2.
  MOVE-CORRESPONDING wa_fkkvkp TO i_adesso_edisc2.

*>> 2012-01-24, 14:15, Krämer
*  MOVE-CORRESPONDING wa_eanl   TO i_adesso_edisc2.
*<< 2012-01-24, 14:15, Krämer

  MOVE-CORRESPONDING y_obj-ediscdoc TO i_adesso_edisc2.
* aktuellste Aktion merken
  SORT y_obj-ediscact BY discact DESCENDING.
  READ TABLE y_obj-ediscact INTO wa_ediscact INDEX 1.
  i_adesso_edisc2-discact = wa_ediscact-discact.
  i_adesso_edisc2-actdate = wa_ediscact-actdate.
  i_adesso_edisc2-acttime = wa_ediscact-acttime.

  PERFORM set_name_gpart      CHANGING i_adesso_edisc2.
  PERFORM set_adresse_vstelle CHANGING i_adesso_edisc2.
  PERFORM set_icon_status     CHANGING i_adesso_edisc2.
  PERFORM set_sperrdatum      CHANGING i_adesso_edisc2 y_obj.
  PERFORM forderungen_lesen   CHANGING i_adesso_edisc2.
  PERFORM wvdatum_ermitteln   CHANGING i_adesso_edisc2 y_obj.
  PERFORM set_langtexte       CHANGING i_adesso_edisc2.

*>> 2012-01-24, 17:20, Krämer
  PERFORM get_vdewnum         CHANGING i_adesso_edisc2.
*<< 2012-01-24, 17:20, Krämer

*>> 2012-01-24, 14:15, Krämer
  LOOP AT it_eanl INTO wa_eanl.

    READ TABLE y_obj-denv-ieastl
      INTO wa_eastl
      WITH KEY
        anlage = wa_eanl-anlage.

    READ TABLE y_obj-denv-iever
      INTO wa_ever
      WITH KEY
        anlage = wa_eanl-anlage.

    MOVE-CORRESPONDING wa_eastl  TO i_adesso_edisc2.  " Anlagenzuordnung ergänzen!
    MOVE-CORRESPONDING wa_ever   TO i_adesso_edisc2.  " AnlaSgenzuordnung ergänzen!

    MOVE-CORRESPONDING wa_eanl TO i_adesso_edisc2.

*>> 2012-01-24, 15:40, Krämer:  Vorbereitung Externe Zählpunk-ID nachlesen
    PERFORM determine_ext_ui  CHANGING i_adesso_edisc2.
**      USING wa_eanl-anlage
**      CHANGING i_adesso_edisc2-ext_ui.
*<< 2012-01-24, 15:40, Krämer

    APPEND i_adesso_edisc2 TO itb_adesso_edisc2.
  ENDLOOP.

  IF itb_adesso_edisc2[] IS INITIAL.
    APPEND i_adesso_edisc2 TO itb_adesso_edisc2.
  ENDIF.

*<< 2012-01-24, 14:15, Krämer
ENDFORM.                    "read_discdoc
*&---------------------------------------------------------------------*
*&      Form  ausgabe
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM ausgabe.
  DATA: h_title TYPE lvc_title,
        is_layout TYPE   slis_layout_alv,
        it_fieldcat TYPE slis_t_fieldcat_alv,
        wa_fieldcat TYPE slis_fieldcat_alv.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = i_percentage
      text       = 'bereite Ausgabe vor...'
    EXCEPTIONS
      OTHERS     = 1.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = '/ADESSO/SPT_EDI2'
      i_bypassing_buffer     = 'X'
      i_buffer_active        = ''
    CHANGING
      ct_fieldcat            = it_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  IF sy-subrc <> 0.
    EXIT.
  ENDIF.
  IF it_fieldcat IS INITIAL.
    EXIT.
  ENDIF.

  WRITE sy-title TO h_title.
  is_layout-zebra  = 'X'.
  is_layout-colwidth_optimize = 'X'.
  is_layout-confirmation_prompt = lf_customizing-prompt.
  is_layout-box_fieldname = 'MARK'.



  LOOP AT it_fieldcat INTO wa_fieldcat.
    CLEAR wa_fieldcat-key.
    CASE wa_fieldcat-fieldname.
      WHEN 'MARK'.
        wa_fieldcat-checkbox = 'X'.
        wa_fieldcat-no_out   = 'X'.
        wa_fieldcat-tech     = 'X'.
        wa_fieldcat-edit     = 'X'.
      WHEN 'ICON'.
        wa_fieldcat-icon = 'X'.
        wa_fieldcat-hotspot = 'X'.
        wa_fieldcat-seltext_l = 'Status'.
        wa_fieldcat-seltext_m = 'Status'.
        wa_fieldcat-seltext_s = 'Status'.
        wa_fieldcat-reptext_ddic = 'Status'.
      WHEN 'DISCNO'.
        wa_fieldcat-hotspot = 'X'.
      WHEN 'VKONT'.
        wa_fieldcat-hotspot = 'X'.
      WHEN 'GPART'.
        wa_fieldcat-hotspot = 'X'.
      WHEN 'VERTRAG'.
        wa_fieldcat-hotspot = 'X'.
      WHEN 'ANLAGE'.
        wa_fieldcat-hotspot = 'X'.
      WHEN 'GERAET'.
        wa_fieldcat-hotspot = 'X'.
      WHEN 'VSTELLE'.
        wa_fieldcat-hotspot = 'X'.
      WHEN OTHERS.
    ENDCASE.

    MODIFY it_fieldcat FROM wa_fieldcat.
  ENDLOOP.

  is_variant-variant = p_varian.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'SET_STATUS'
      i_grid_title             = h_title
      is_layout                = is_layout
      it_fieldcat              = it_fieldcat
      i_callback_user_command  = 'USER_COMMAND'
      i_save                   = i_save
      is_variant               = is_variant
*      i_structure_name        =
    TABLES
      t_outtab                = itab.

  CLEAR wa_itab.
  MODIFY itab FROM wa_itab TRANSPORTING mark error WHERE mandt EQ sy-mandt.


  IF sy-subrc NE 0.
    EXIT.
  ENDIF.
ENDFORM.                    "ausgabe

*&---------------------------------------------------------------------*
*&      Form  set_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RT_EXTAB   text
*----------------------------------------------------------------------*
FORM set_status USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS lf_customizing-pfkey EXCLUDING rt_extab.
ENDFORM.                    "set_status
*&---------------------------------------------------------------------*
*&      Form  status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM indicator USING tabix TYPE sy-tabix.
* Userparameter "SIN" auf "0"?

  CHECK sy-batch IS INITIAL.
  i_percentage = ( tabix / i_anzahl ) * 100.

  IF i_percentage > i_schwelle.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = i_schwelle
        text       = 'lese Sperrbelege...'
      EXCEPTIONS
        OTHERS     = 1.
    i_schwelle = i_schwelle + co_schwelle.
  ENDIF.
ENDFORM.                    "status
*&---------------------------------------------------------------------*
*&      Form  langtexte_lesen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM langtexte_lesen USING i_domname  TYPE dd07l-domname
                           i_feldname TYPE char10.
* Langtexte ausgeben
  DATA: it_dd07v TYPE STANDARD TABLE OF dd07v,
        i_dcnreastxt LIKE ediscdocs-reasontext.

  CALL FUNCTION 'DD_DOMVALUES_GET'
    EXPORTING
      domname        = i_domname
      text           = 'X'
      langu          = sy-langu
    TABLES
      dd07v_tab      = it_dd07v
    EXCEPTIONS
      wrong_textflag = 1
      OTHERS         = 2.
  IF sy-subrc NE 0.
* keine Fehlerausgabe notwendig
  ELSE.
    APPEND LINES OF it_dd07v TO it_dd07.
  ENDIF.
ENDFORM.                    "langtexte_lesen
*&---------------------------------------------------------------------*
*&      Form  sperrbeleg_posten_lesen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->X_EDISCDOC text
*      -->Y_TEXT     text
*----------------------------------------------------------------------*
FORM forderungen_lesen CHANGING i_adesso_edisc2 TYPE /ADESSO/SPT_EDI2.
  DATA: it_mahnop TYPE STANDARD TABLE OF tema01 WITH HEADER LINE.
  CHECK NOT i_adesso_edisc2-vkont IS INITIAL.

  CHECK NOT p_op IS INITIAL.

* Offene und sperrrelevante Posten lesen
  CALL FUNCTION 'ISU_DB_GET_DUE_AND_DISCREL_POS'
    EXPORTING
      x_vkont             = i_adesso_edisc2-vkont
    IMPORTING
      y_sumoi             = i_adesso_edisc2-sum_op
      y_sumdi             = i_adesso_edisc2-sum_gp
    TABLES
      t_mahnop            = it_mahnop
    EXCEPTIONS
      not_found           = 0  "Fehler akzeptiert !
      concurrent_clearing = 2
      OTHERS              = 3.
  IF sy-subrc NE 0.
    PERFORM write_error USING '001'
                        CHANGING i_adesso_edisc2.
    EXIT.
  ENDIF.

  PERFORM determine_credit_rating CHANGING i_adesso_edisc2.

ENDFORM.                    "sperrbeleg_posten_lesen
*&---------------------------------------------------------------------*
*&      Form  wvdatum_ermitteln
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->I_adesso_edisc2  text
*      -->I_OBJ      text
*----------------------------------------------------------------------*
FORM wvdatum_ermitteln CHANGING i_adesso_edisc2 TYPE /ADESSO/SPT_EDI2
                                i_obj TYPE isu05_discdoc_internal.
  DATA: wa_ediscact TYPE ediscact.

* Wiedervorlagedatum = aktuellstes Freigabedatum (wg. möglicher Stornierungen) + Anzahl ktage gem. Customizing

* aktuellste Sperraktion mit "Freigabe Sperrbeleg" ermitteln
  SORT i_obj-ediscact BY discact DESCENDING.
  LOOP AT i_obj-ediscact INTO wa_ediscact
    WHERE discacttyp EQ '05' .   " Freigabe Sperrbeleg
    EXIT.
  ENDLOOP.

* Wiedervorlagedatum berechnen
  CALL FUNCTION 'WFCS_FCAL_DATE_GET_S'
    EXPORTING
      pi_date           = wa_ediscact-actdate
      pi_offset         = lf_customizing-wvfrist
      pi_fcalid         = lf_customizing-fcalid
    CHANGING
      pe_date_to        = i_adesso_edisc2-wvdatum
    EXCEPTIONS
      error_interface   = 1
      error_buffer_read = 2
      OTHERS            = 3.
  IF sy-subrc <> 0.
* bei fehlerhaftem Kalender Tage ohne Berücksichtigung von Feiertagen addieren
    i_adesso_edisc2-wvdatum = wa_ediscact-actdate + lf_customizing-wvfrist.
  ENDIF.

ENDFORM.                    "wvdatum_ermitteln
*&---------------------------------------------------------------------*
*&      Form  set_langtexte
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->I_adesso_edisc2  text
*----------------------------------------------------------------------*
FORM set_langtexte CHANGING i_adesso_edisc2 TYPE /ADESSO/SPT_EDI2.
* Langtexte zuweisen
  PERFORM read_dd07 USING 'EDCDOCSTAT' CHANGING i_adesso_edisc2-status i_adesso_edisc2-statustext.
  PERFORM read_dd07 USING 'DISCREASON' CHANGING i_adesso_edisc2-discreason i_adesso_edisc2-dcnreastxt.
ENDFORM.                    "set_langtexte
*&---------------------------------------------------------------------*
*&      Form  read_dd07
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->I_DOMNAME  text
*      -->I_DOMVALUE text
*      -->I_TEXT     text
*----------------------------------------------------------------------*
FORM read_dd07 USING i_domname
               CHANGING i_domvalue i_text.
  READ TABLE it_dd07 INTO wa_dd07
  WITH KEY domname = i_domname
           domvalue_l = i_domvalue.
  i_text = wa_dd07-ddtext.
ENDFORM.                                                    "read_dd07
*&---------------------------------------------------------------------*
*&      Form  set_icon_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_icon_status CHANGING i_adesso_edisc2 TYPE /ADESSO/SPT_EDI2.
* Icon inkl. Langtext generieren
  CASE i_adesso_edisc2-status.
    WHEN '00'.
      PERFORM icon_create USING 'ICON_STATUS_REVERSE' i_adesso_edisc2-statustext
                          CHANGING i_adesso_edisc2.
    WHEN '01'.
      PERFORM icon_create USING 'ICON_STATUS_OPEN' i_adesso_edisc2-statustext
                          CHANGING i_adesso_edisc2.
    WHEN '10'.
      PERFORM icon_create USING 'ICON_STATUS_BOOKED' i_adesso_edisc2-statustext
                          CHANGING i_adesso_edisc2.
    WHEN '20'.
      PERFORM icon_create USING 'ICON_ORDER' i_adesso_edisc2-statustext
                          CHANGING i_adesso_edisc2.
    WHEN '21'.
      PERFORM icon_create USING 'ICON_DISCONNECT' i_adesso_edisc2-statustext
                          CHANGING i_adesso_edisc2.
    WHEN '22'.
      PERFORM icon_create USING 'ICON_CONNECT' i_adesso_edisc2-statustext
                          CHANGING i_adesso_edisc2.
    WHEN '30'.
      PERFORM icon_create USING 'ICON_RELEASE' i_adesso_edisc2-statustext
                          CHANGING i_adesso_edisc2.
    WHEN '99'.
      PERFORM icon_create USING 'ICON_COMPLETE' i_adesso_edisc2-statustext
                          CHANGING i_adesso_edisc2.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    "set_icon_status
*&---------------------------------------------------------------------*
*&      Form  set_sperrdatum
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->I_adesso_edisc2  text
*----------------------------------------------------------------------*
FORM set_sperrdatum CHANGING i_adesso_edisc2 TYPE /ADESSO/SPT_EDI2
                             y_obj TYPE isu05_discdoc_internal.
  DATA: wa_ediscact TYPE ediscact,
        i_actdate TYPE ediscact-actdate.

  SORT y_obj-ediscact BY discact DESCENDING.    "aktuellste Sperraktion zuerst

  LOOP AT y_obj-ediscact INTO wa_ediscact
    WHERE discacttyp EQ '02'   " Sperrerfassung
    AND   disccanceld EQ space.
    i_actdate = wa_ediscact-actdate.
    EXIT.
  ENDLOOP.
  IF sy-subrc EQ 0.
    IF wa_ediscact-orderact IS INITIAL.
* Sperrung wurde ohne Sperrauftrag durchgeführt
      i_adesso_edisc2-actdate = i_actdate.
    ELSE.
* war die Rückmeldung eines Sperrauftrags erfolgreich?
*   - hierzu die beteiligte Sperraktion (= Sperrauftrag) lesen
      READ TABLE y_obj-ediscact INTO wa_ediscact
            WITH KEY discact = wa_ediscact-orderact.
* nur bei erfolgreichen Sperrvorgängen das Sperrdatum übernehmen
      IF wa_ediscact-ordstate IN is_allow.
        i_adesso_edisc2-actdate = i_actdate.
      ENDIF.
    ENDIF.
  ENDIF.      " IF sy-subrc EQ 0.
ENDFORM.                                                "set_sperrdatum
*&---------------------------------------------------------------------*
*&      Form  icon_create
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->NAME       text
*      -->INFO       text
*----------------------------------------------------------------------*
FORM icon_create USING name info
      CHANGING i_adesso_edisc2 TYPE /ADESSO/SPT_EDI2.
  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name                        = name
      info                        = info
*     ADD_STDINF                  = 'X'
   IMPORTING
     RESULT                      = i_adesso_edisc2-icon
   EXCEPTIONS
     icon_not_found              = 1
     outputfield_too_short       = 2
     OTHERS                      = 3.
  IF sy-subrc NE 0.
* keine Fehlerausgabe notwendig
  ENDIF.
ENDFORM.                    "icon_create
*&---------------------------------------------------------------------*
*&      Form  reorg_adesso_edisc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM reorg_adesso_edisc.
  SELECT * FROM /ADESSO/SPT_EDI2.
    SELECT SINGLE * FROM ediscdoc INTO wa_ediscdoc
        WHERE discno EQ /ADESSO/SPT_EDI2-discno.
    IF wa_ediscdoc-status EQ '99'.
      DELETE /ADESSO/SPT_EDI2.
    ENDIF.
  ENDSELECT.
ENDFORM.                    "reorg_adesso_edisc
*&---------------------------------------------------------------------*
*&      Form  ucomm_refresh
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->R_UCOMM      text
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM ucomm_refresh CHANGING rs_selfield TYPE slis_selfield.
  LOOP AT itab INTO wa_itab
    WHERE NOT mark IS INITIAL
    AND   NOT discno IS INITIAL.
    PERFORM read_discdoc TABLES it_itab CHANGING wa_itab.

    MODIFY itab FROM wa_itab.
  ENDLOOP.
  rs_selfield-refresh = 'X'.
ENDFORM.                    "ucomm_refresh
*&---------------------------------------------------------------------*
*&      Form  ucomm_fpl9
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM ucomm_fpl9 USING rs_selfield TYPE slis_selfield.
  DATA: y_db_update LIKE  regen-db_update,
        wa_fkkeposc TYPE fkkeposc,
        it_selhead  TYPE STANDARD TABLE OF fkkeposs1,
        wa_selhead  TYPE fkkeposs1.
  LOOP AT itab INTO wa_itab
    WHERE NOT mark IS INITIAL.
*    AND   NOT vkont IS INITIAL.
    REFRESH it_selhead.
    wa_selhead-gpart = wa_itab-gpart.
    wa_selhead-vkont = wa_itab-vkont.

    GET PARAMETER ID '818' FIELD wa_fkkeposc-bala_role.   " Kontenstandsrolle
    GET PARAMETER ID '8LT' FIELD wa_fkkeposc-lstyp.       " Listtyp für die Kontenstandanzeige
    GET PARAMETER ID '812' FIELD wa_fkkeposc-varnr.       " Zeilenaufbau / Variante
    GET PARAMETER ID '8SO' FIELD wa_fkkeposc-srvar.       " Sortiervariante
    GET PARAMETER ID '815' FIELD wa_fkkeposc-fitab.       " Startbild der Liste
*   GET PARAMETER ID  '???' field     wa_fkkeposc-svvar     = ''.                   " Saldenvariante

    APPEND wa_selhead TO it_selhead.
    CALL FUNCTION 'FKK_LINE_ITEMS_WITH_SELECTIONS'
      EXPORTING
        i_fkkeposc              = wa_fkkeposc
      TABLES
        t_selhead               = it_selhead
      EXCEPTIONS
        no_items_found          = 1
        invalid_selection       = 2
        maximal_number_of_items = 3
        OTHERS                  = 4.
    IF sy-subrc EQ 1.
      MESSAGE s429(>4).
    ELSE.
* keine Fehlerausgabe nötig
    ENDIF.
  ENDLOOP.
ENDFORM.                                                    "ucomm_fpl9
*&---------------------------------------------------------------------*
*&      Form  ucomm_edit
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->R_UCOMM      text
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM ucomm_edit CHANGING rs_selfield TYPE slis_selfield.
  LOOP AT itab INTO wa_itab
    WHERE NOT mark IS INITIAL
    AND   NOT discno IS INITIAL.
    PERFORM discdoc_change USING rs_selfield
                                 wa_itab.
    MODIFY itab FROM wa_itab.
    rs_selfield-refresh = 'X'.
  ENDLOOP.
ENDFORM.                                                    "ucomm_edit
*&---------------------------------------------------------------------*
*&      Form  ucomm_complete
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM ucomm_complete CHANGING rs_selfield TYPE slis_selfield.
  LOOP AT itab INTO wa_itab
    WHERE NOT mark IS INITIAL
    AND   NOT discno IS INITIAL
    AND   ( status EQ 0 OR status EQ 1 OR status EQ 10 OR status EQ 30 ).
    PERFORM discdoc_complete USING rs_selfield
                                 wa_itab.
    MODIFY itab FROM wa_itab.
    rs_selfield-refresh = 'X'.
  ENDLOOP.
ENDFORM.                                                "ucomm_complete
*&---------------------------------------------------------------------*
*&      Form  discdoc_complete
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RS_SELFIELD  text
*      -->I_adesso_edisc2    text
*----------------------------------------------------------------------*
FORM discdoc_complete USING rs_selfield TYPE slis_selfield
                            i_adesso_edisc2   TYPE /ADESSO/SPT_EDI2.
  DATA: h_auto TYPE isu05_discdoc_auto,
        y_db_update LIKE  regen-db_update,
        i_tabix TYPE sy-tabix.

  i_tabix = sy-tabix.

  h_auto-contr-use-okcode = 'X'.
  h_auto-contr-okcode = 'DARKCOMPL'.

  CALL FUNCTION 'ISU_S_DISCDOC_CHANGE'
    EXPORTING
      x_discno           = i_adesso_edisc2-discno
      x_upd_online       = 'X'
      x_no_dialog        = 'X'
      x_auto             = h_auto
    IMPORTING
      y_db_update        = y_db_update
    EXCEPTIONS
      not_found          = 1
      foreign_lock       = 2
      not_authorized     = 3
      input_error        = 4
      general_fault      = 5
      object_inv_discdoc = 6
      OTHERS             = 7.
  IF   sy-subrc NE 0.
    IF sy-subrc EQ 2.
      MESSAGE 'Fehler! Sperrbeleg gesperrt!' TYPE 'S'.
    ENDIF.
  ELSE.
    IF y_db_update NE space.
      COMMIT WORK.
      PERFORM read_discdoc TABLES it_itab CHANGING i_adesso_edisc2.
      MODIFY itab FROM i_adesso_edisc2 INDEX i_tabix.
      rs_selfield-refresh = 'X'.
    ENDIF.
  ENDIF.

ENDFORM.                    "discdoc_complete


*&---------------------------------------------------------------------*
*&      Form  Discdoc_change
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RS_SELFIELD  text
*      -->WA_ITAB      text
*----------------------------------------------------------------------*
FORM discdoc_change  USING rs_selfield TYPE slis_selfield
                           i_adesso_edisc2   TYPE /ADESSO/SPT_EDI2.
  DATA: y_db_update LIKE  regen-db_update,
        i_tabix TYPE sy-tabix,
        ld_charge TYPE charge_dc,
        lf_ediscact TYPE ediscact.

  i_tabix = sy-tabix.

  IF sy-mandt EQ '755'.
* 19.08.2010 Frellstedt
* auf Nezseite wird bei jedem Aufruf der Änderungsfunktion ein zu buchendes hrenschema abgefragt.
* Dieses wird in der das Feld CHARGE_OPBEL der ersten Sperraktion (Tabelle EDISCACT) rieben und beim Datenversand
* im Kommentarfeld versandt
* Vertriebsseitig wird dann eine Gebühr mithilfe dieses Schemas gebucht
    PERFORM get_charge_edit CHANGING ld_charge.

    SELECT * FROM ediscact
      INTO lf_ediscact
      WHERE discno EQ i_adesso_edisc2-discno
      ORDER BY orderact ASCENDING.
* erste Sperraktion lesen
      EXIT.
    ENDSELECT.
    IF sy-subrc EQ 0.
      WRITE ld_charge TO lf_ediscact-charge_opbel.
      MODIFY ediscact FROM lf_ediscact.
      COMMIT WORK AND WAIT.
    ENDIF.

  ENDIF.

  CALL FUNCTION 'ISU_S_DISCDOC_CHANGE'
    EXPORTING
      x_discno     = i_adesso_edisc2-discno
      x_upd_online = 'X'
      x_no_other   = 'X'
    IMPORTING
      y_db_update  = y_db_update
    EXCEPTIONS
      OTHERS       = 1.
  IF   sy-subrc NE 0.
* keine Fehlerausgabe notwendig
    MESSAGE 'Fehler! Sperrbeleg gesperrt!' TYPE 'S'.
  ELSE.
    IF y_db_update NE space.
      COMMIT WORK.
      PERFORM read_discdoc TABLES it_itab CHANGING i_adesso_edisc2.
      MODIFY itab FROM i_adesso_edisc2 INDEX i_tabix.
      rs_selfield-refresh = 'X'.
    ENDIF.
  ENDIF.
ENDFORM.                    "Discdoc_change

*&---------------------------------------------------------------------*
*&      Form  ucomm_post
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->R_UCOMM      text
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM ucomm_post CHANGING rs_selfield TYPE slis_selfield.
  DATA: i_opbel     TYPE fkkko-opbel,
        i_bpcontact TYPE bcont-bpcontact,
        i_dumfrist  TYPE datum.

  i_dumfrist = sy-datum - lf_customizing-dumfrist.

  PERFORM get_charge_post CHANGING lf_customizing-charge_post.



* Vorabdurchlauf für Nachdruck von Belegen im Status 10
  LOOP AT itab INTO wa_itab
     WHERE NOT mark IS INITIAL
     AND   NOT discno IS INITIAL
     AND       status EQ 10.
* Beleg drucken
    PERFORM druck CHANGING lf_customizing-form_post wa_itab.
  ENDLOOP.

  LOOP AT itab INTO wa_itab
    WHERE NOT mark IS INITIAL
    AND   NOT discno IS INITIAL
    AND       status EQ 0           " nur noch nicht freigegebene Sperrbelege verarbeiten
    AND       erdat LE i_dumfrist.  " nur Belege, deren Sperrfrist abgelaufen ist

* Gebühr buchen
    PERFORM gebuehr_buchen USING lf_customizing-charge_post CHANGING wa_itab
                                  i_opbel.
* Sperrbeleg freigeben
    PERFORM edit_discdoc USING wa_itab
                               '10'.

* Beleg drucken
    PERFORM druck CHANGING lf_customizing-form_post wa_itab.

* Kontakt anlegen
    PERFORM kontakt_anlegen USING lf_customizing-bpc_post
                                  wa_itab
                            CHANGING i_bpcontact.

*  Kontakt und Belegnummer in "Freigabe-Aktion" schreiben
    PERFORM change_discdoc USING '05'   " Freigabe Sperrbeleg
                           CHANGING wa_itab
                                    i_opbel
                                    i_bpcontact.


    PERFORM read_discdoc TABLES it_itab CHANGING wa_itab.
    MODIFY itab FROM wa_itab.
    rs_selfield-refresh = 'X'.
  ENDLOOP.
ENDFORM.                    "ucomm_post
*&---------------------------------------------------------------------*
*&      Form  ucomm_order
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->R_UCOMM      text
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM ucomm_order CHANGING rs_selfield TYPE slis_selfield.
  DATA: i_bpcontact  TYPE bcont-bpcontact,
        i_opbel      TYPE fkkko-opbel,
        lt_dfkklocks TYPE dfkklocks_t.

  LOOP AT itab INTO wa_itab
    WHERE NOT mark IS INITIAL
    AND   NOT discno IS INITIAL
    AND   ( status EQ '01' OR status EQ '10' )
    AND   wvdatum LE sy-datum.   " nur Belege, deren WV-Frist abgelaufen ist

* existiert zum Vertragskonto eine aktive Mahnsperre?
    IF NOT wa_itab-vkont IS INITIAL.
      REFRESH lt_dfkklocks.
      CALL FUNCTION 'FKK_S_LOCK_GET_FOR_VKONT'
        EXPORTING
          iv_vkont = wa_itab-vkont
          iv_date  = sy-datum
        IMPORTING
          et_locks = lt_dfkklocks.

      IF NOT lt_dfkklocks[] IS INITIAL.
* VK mit Mahnsperre gefunden
        CONTINUE.
      ENDIF.
    ENDIF.


* Sperrauftrag erstellen
    PERFORM edit_discdoc USING wa_itab
                               '20'.

* Gebühr buchen
    PERFORM gebuehr_buchen USING lf_customizing-charge_dcor CHANGING wa_itab
                                 i_opbel.


* Kontakt anlegen
    PERFORM kontakt_anlegen USING lf_customizing-bpc_dcor
                                  wa_itab
                            CHANGING i_bpcontact.

*  Kontakt und Belegnummer in ersten "Sperrauftrag" schreiben
    PERFORM change_discdoc USING '01'   " Sperrauftrag
                           CHANGING wa_itab
                                    i_opbel
                                    i_bpcontact.


* Beleg drucken
    PERFORM druck CHANGING lf_customizing-form_dcor wa_itab.

    PERFORM read_discdoc TABLES it_itab CHANGING wa_itab.
    MODIFY itab FROM wa_itab.
    rs_selfield-refresh = 'X'.
  ENDLOOP.
ENDFORM.                    "ucomm_order
*&---------------------------------------------------------------------*
*&      Form  ucomm_order_netz
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM ucomm_order_netz CHANGING rs_selfield TYPE slis_selfield.
  DATA: i_bpcontact TYPE bcont-bpcontact,
        i_opbel     TYPE fkkko-opbel.

  LOOP AT itab INTO wa_itab
    WHERE NOT mark IS INITIAL
    AND   NOT discno IS INITIAL
    AND   status EQ '20'.

* Sperrbelegsaktion um 1 verringern (wird später wieder dazu addiert)
    SUBTRACT 1 FROM wa_itab-discact.


* Gebühr buchen
    PERFORM gebuehr_buchen USING lf_customizing-charge_dcor CHANGING wa_itab
                                 i_opbel.


* Kontakt anlegen
    PERFORM kontakt_anlegen USING lf_customizing-bpc_dcor
                                  wa_itab
                            CHANGING i_bpcontact.

*  Kontakt und Belegnummer in ersten "Sperrauftrag" schreiben
    PERFORM change_discdoc USING '01'   " Sperrauftrag
                           CHANGING wa_itab
                                    i_opbel
                                    i_bpcontact.


* Beleg drucken
    PERFORM druck CHANGING lf_customizing-form_dcor wa_itab.

    PERFORM read_discdoc TABLES it_itab CHANGING wa_itab.
    MODIFY itab FROM wa_itab.
    rs_selfield-refresh = 'X'.
  ENDLOOP.
ENDFORM.                    "ucomm_order_netz
*&---------------------------------------------------------------------*
*&      Form  ucomm_clerk
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM ucomm_clerk CHANGING rs_selfield TYPE slis_selfield.
  DATA: it_sval TYPE STANDARD TABLE OF sval,
        wa_sval TYPE sval,
        i_returncode.

  wa_sval-tabname = 'USR02'.
  wa_sval-fieldname = 'BNAME'.
*  MOVE sy-uname TO wa_sval-value.
*  wa_sval-field_obl = 'X'.      " leeres Feld zulassen, um Zuordnung aufheben zu können
*  wa_sval-comp_code = 'EQ'.
  APPEND wa_sval TO it_sval.


  CALL FUNCTION 'POPUP_GET_VALUES_DB_CHECKED'
    EXPORTING
   check_existence       = ' '    " keine Existenzprüfung, damit auch Kürzel etc. eingetragen werden en
   popup_title           = 'zuständigen Sachbearbeiter auswählen'
*   START_COLUMN          = '5'
*   START_ROW             = '5'
  IMPORTING
    returncode            = i_returncode
    TABLES
      fields                = it_sval
 EXCEPTIONS
   error_in_fields       = 1
   OTHERS                = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  READ TABLE it_sval INTO wa_sval INDEX 1.
  LOOP AT itab INTO wa_itab
    WHERE NOT mark IS INITIAL.
    MOVE wa_sval-value TO wa_itab-bname.
    MODIFY itab FROM wa_itab.
    rs_selfield-refresh = 'X'.
  ENDLOOP.
ENDFORM.                    "ucomm_clerk
*&---------------------------------------------------------------------*
*&      Form  display_discno
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_discno CHANGING rs_selfield  TYPE slis_selfield
                             i_adesso_edisc2 TYPE /ADESSO/SPT_EDI2.
  DATA: x_discno LIKE ediscdoc-discno,
        y_db_update LIKE  regen-db_update,
        h_num12(12) TYPE n,
        i_tabix TYPE sy-tabix.

  i_tabix = sy-tabix.

  h_num12 = rs_selfield-value.
  x_discno = h_num12.
  CALL FUNCTION 'ISU_S_DISCDOC_DISPLAY'
    EXPORTING
      x_discno    = x_discno
      x_no_change = 'X'
      x_no_other  = 'X'
    IMPORTING
      y_db_update = y_db_update
    EXCEPTIONS
      OTHERS      = 1.
  IF   sy-subrc NE 0.
* keine Fehlerausgabe notwendig
  ELSE.
    IF y_db_update NE space.
      COMMIT WORK.
      PERFORM read_discdoc TABLES it_itab CHANGING i_adesso_edisc2.
      MODIFY itab FROM i_adesso_edisc2 INDEX i_tabix.
      rs_selfield-refresh = 'X'.
    ENDIF.
  ENDIF.
ENDFORM.                    "display_discno
*&---------------------------------------------------------------------*
*&      Form  display_gpart
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_gpart USING rs_selfield TYPE slis_selfield.
  DATA: x_partner LIKE  but000-partner,
         h_num10(10) TYPE n.
  h_num10 = rs_selfield-value.
  x_partner = h_num10.
  CALL FUNCTION 'ISU_S_PARTNER_DISPLAY'
    EXPORTING
      x_partner   = x_partner
      x_no_change = 'X'
    EXCEPTIONS
      OTHERS      = 1.
  IF sy-subrc NE 0.
* keine Fehlerausgabe notwendig
  ENDIF.
ENDFORM.                    "display_gpart
*&---------------------------------------------------------------------*
*&      Form  display_vkont
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_vkont USING rs_selfield TYPE slis_selfield.
  DATA: x_account LIKE  fkkvk-vkont.
  x_account = rs_selfield-value.
  CALL FUNCTION 'ISU_S_ACCOUNT_DISPLAY'
    EXPORTING
      x_account   = x_account
      x_no_change = 'X'
    EXCEPTIONS
      OTHERS      = 1.
  IF sy-subrc NE 0.
* keine Fehlerausgabe notwendig
  ENDIF.
ENDFORM.                    "display_vkont
*&---------------------------------------------------------------------*
*&      Form  display_vertrag
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_vertrag USING rs_selfield TYPE slis_selfield.
  DATA: x_vertrag LIKE  ever-vertrag,
        h_num10(10) TYPE n.
  MOVE rs_selfield-value TO h_num10.
  x_vertrag = h_num10.
  CALL FUNCTION 'ISU_S_CONTRACT_DISPLAY'
    EXPORTING
      x_vertrag   = x_vertrag
      x_no_change = 'X'
    EXCEPTIONS
      OTHERS      = 1.
  IF sy-subrc NE 0.
* keine Fehlerausgabe notwendig
  ENDIF.
ENDFORM.                    "display_vertrag
*&---------------------------------------------------------------------*
*&      Form  display_anlage
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_anlage USING rs_selfield TYPE slis_selfield.
  DATA: x_anlage LIKE  v_eanl-anlage,
        h_num10(10) TYPE n.
  MOVE rs_selfield-value TO h_num10.
  x_anlage = h_num10.
  CALL FUNCTION 'ISU_S_INSTLN_DISPLAY'
    EXPORTING
      x_anlage    = x_anlage
      x_keydate   = sy-datum
      x_no_change = 'X'
    EXCEPTIONS
      OTHERS      = 1.
  IF sy-subrc NE 0.
* keine Fehlerausgabe notwendig
  ENDIF.
ENDFORM.                    "display_anlage
*&---------------------------------------------------------------------*
*&      Form  display_geraet
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_geraet USING rs_selfield TYPE slis_selfield.
  DATA: x_geraet LIKE  v_eger-geraet,
        h_num18(18) TYPE n.
  h_num18 = rs_selfield-value.
  x_geraet = h_num18.
  CALL FUNCTION 'ISU_S_EGER_DISPLAY'
    EXPORTING
      x_geraet = x_geraet
    EXCEPTIONS
      OTHERS   = 1.
  IF sy-subrc NE 0.
* keine Fehlerausgabe notwendig
  ENDIF.
ENDFORM.                    "display_geraet
*&---------------------------------------------------------------------*
*&      Form  display_vstelle
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM display_vstelle USING rs_selfield TYPE slis_selfield.
  DATA: x_vstelle LIKE  evbs-vstelle,
        h_num10(10) TYPE n.
  h_num10 = rs_selfield-value.
  x_vstelle = h_num10.
  CALL FUNCTION 'ISU_S_PREMISE_DISPLAY'
    EXPORTING
      x_vstelle   = x_vstelle
      x_no_change = 'X'
    EXCEPTIONS
      OTHERS      = 1.
  IF sy-subrc NE 0.
* keine Fehlerausgabe notwendig
  ENDIF.
ENDFORM.                    "display_geraet
*&---------------------------------------------------------------------*
*&      Form  gebuehr_buchen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM gebuehr_buchen USING i_charge TYPE charge_dc
                 CHANGING i_adesso_edisc2 TYPE /ADESSO/SPT_EDI2
                          i_opbel   TYPE fkkko-opbel.
  DATA: xy_obj TYPE isu05_discdoc_internal.

* Gebührenbuchung nur möglich bei Vorgabe Gebührenschema
  CHECK NOT i_charge IS INITIAL.

  PERFORM open_discdoc CHANGING i_adesso_edisc2
                                xy_obj.

* Gebühr nach Gebührenschema buchen
  CALL FUNCTION 'ISU_DISCDOC_SAVE_CHARGE'
    EXPORTING
      x_charge                     = i_charge
      x_vkont                      = i_adesso_edisc2-vkont
      x_contract                   = i_adesso_edisc2-vertrag
    CHANGING
      xy_opbel                     = i_opbel
      xy_obj                       = xy_obj
    EXCEPTIONS
      charge_not_found             = 1
      error_create_charge_document = 2
      OTHERS                       = 3.
  IF sy-subrc NE 0.
    PERFORM write_error USING '005'
                        CHANGING i_adesso_edisc2.
  ELSE.
    COMMIT WORK.
  ENDIF.

ENDFORM.                    "gebuehr_buchen
*&---------------------------------------------------------------------*
*&      Form  get_charge_post
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LD_CHARGE  text
*----------------------------------------------------------------------*
FORM get_charge_post CHANGING ld_charge TYPE charge_dc.


  IF sy-mandt EQ '255'.
    DATA: it_sval TYPE STANDARD TABLE OF sval,
           wa_sval TYPE sval,
           i_returncode.
* Pop-Up zur Eingabe eines Gebührenschmema
    wa_sval-tabname = '/ADESSO/SPT_EDCU'.
    wa_sval-fieldname = 'CHARGE_POST'.
    MOVE ld_charge TO wa_sval-value.
*  wa_sval-field_obl = 'X'.      " leeres Feld zulassen, um Gebührenbuchung zu unterbinden
    wa_sval-comp_code = 'EQ'.
    APPEND wa_sval TO it_sval.


    CALL FUNCTION 'POPUP_GET_VALUES_DB_CHECKED'
      EXPORTING
     check_existence       = 'X'
     popup_title           = 'Wählen Sie ein Gebührenschema aus'
*   START_COLUMN          = '5'
*   START_ROW             = '5'
    IMPORTING
      returncode            = i_returncode
      TABLES
        fields                = it_sval
   EXCEPTIONS
     error_in_fields       = 1
     OTHERS                = 2.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    IF i_returncode EQ 'A'.
      MESSAGE 'Abbruch durch Benutzer' TYPE 'W'.
    ENDIF.



    CLEAR wa_sval.
    READ TABLE it_sval INTO wa_sval INDEX 1.
    ld_charge = wa_sval-value.
  ENDIF.
ENDFORM.                    "get_charge_post
*&---------------------------------------------------------------------*
*&      Form  get_charge_edit
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LD_CHARGE  text
*----------------------------------------------------------------------*
FORM get_charge_edit CHANGING ld_charge TYPE charge_dc.

  DATA: it_sval TYPE STANDARD TABLE OF sval,
         wa_sval TYPE sval,
         i_returncode.
* Pop-Up zur Eingabe eines Gebührenschmema
  wa_sval-tabname = 'TFK047ET'.
  wa_sval-fieldname = 'CHGID'.
  MOVE ld_charge TO wa_sval-value.
*  wa_sval-field_obl = 'X'.      " leeres Feld zulassen, um Gebührenbuchung zu unterbinden
*  wa_sval-comp_code = 'EQ'.
  APPEND wa_sval TO it_sval.


  CALL FUNCTION 'POPUP_GET_VALUES_DB_CHECKED'
    EXPORTING
*   check_existence       = ''
   popup_title           = 'Wählen Sie ein Gebührenschema aus'
*   START_COLUMN          = '5'
*   START_ROW             = '5'
  IMPORTING
    returncode            = i_returncode
    TABLES
      fields                = it_sval
 EXCEPTIONS
   error_in_fields       = 1
   OTHERS                = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  IF i_returncode EQ 'A'.
    MESSAGE 'Abbruch durch Benutzer' TYPE 'W'.
  ENDIF.



  CLEAR wa_sval.
  READ TABLE it_sval INTO wa_sval INDEX 1.
  ld_charge = wa_sval-value.

ENDFORM.                    "get_charge_edit
*&---------------------------------------------------------------------*
*&      Form  edit_discdoc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->WA_adesso_edisc2 text
*----------------------------------------------------------------------*
FORM edit_discdoc CHANGING i_adesso_edisc2 TYPE /ADESSO/SPT_EDI2
                           i_status   TYPE edcdocstat.
  DATA: h_auto TYPE isu05_discdoc_auto,
        i_no_dialog TYPE kennzx,
        y_obj TYPE isu05_discdoc_internal,
        i_zaehler TYPE sy-tabix.

* sollte im Datenumfeld des Sperrbelegs nur ein Gerät zu sperren sein, Sperrauftrag "dunkel" ntergrund anlegen

  CALL FUNCTION 'ISU_O_DISCDOC_OPEN_INTERNAL'
    EXPORTING
      x_discno = i_adesso_edisc2-discno
      x_wmode  = '1'
    IMPORTING
      y_obj    = y_obj
    EXCEPTIONS
      OTHERS   = 1.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  DESCRIBE TABLE y_obj-denv-ieger LINES i_zaehler.

  CLEAR h_auto.
  h_auto-contr-use-okcode = 'X'.


  CASE i_status.
    WHEN '10'.  " Sperrbeleg freigeben
      h_auto-contr-okcode = 'DARKRELE'.
      i_no_dialog = 'X'.
    WHEN '20'.
      CASE i_zaehler.
        WHEN 0.
*          MESSAGE 'Fehler! Keine sperrbaren Objekte im Datenumfeld des Bezugsobjekts!' TYPE
          MESSAGE e426(eh).
        WHEN 1.
          h_auto-contr-okcode = 'DARKDCOR'.
          h_auto-interface-darkdcor-x_actdate   = sy-datum.
          i_no_dialog = 'X'.
        WHEN OTHERS.
          h_auto-contr-okcode = 'DCOR'.
          CLEAR i_no_dialog.
      ENDCASE.
    WHEN '99'.
* Abschluss Sperrbeleg
      h_auto-contr-okcode = 'DARKCOMPL'.
      i_no_dialog = 'X'.
    WHEN OTHERS.
      EXIT.
  ENDCASE.



  DO i_zaehler TIMES.
    CALL FUNCTION 'ISU_S_DISCDOC_CHANGE'
      EXPORTING
        x_discno           = i_adesso_edisc2-discno
        x_upd_online       = 'X'
        x_no_dialog        = i_no_dialog
        x_auto             = h_auto
        x_set_commit_work  = 'X'
      EXCEPTIONS
        not_found          = 1
        foreign_lock       = 2
        not_authorized     = 3
        input_error        = 4
        general_fault      = 5
        object_inv_discdoc = 6
        OTHERS             = 7.
    IF sy-subrc NE 0.
      IF sy-subrc = 3.
        PERFORM write_error USING '008' CHANGING i_adesso_edisc2.
      ELSEIF sy-subrc = 6.
        PERFORM write_error USING '009' CHANGING i_adesso_edisc2.
      ELSE.
        PERFORM write_error USING '006' CHANGING i_adesso_edisc2.
      ENDIF.
    ELSE.

      COMMIT WORK.

      IF NOT sy-index EQ i_zaehler AND i_status EQ '20'.
        DATA: i_question TYPE text80,
              y_answer.
        i_question = 'Möchten Sie einen weiteren Sperrauftrag zu Sperrbeleg &1 anlegen?'.
        REPLACE '&1' WITH i_adesso_edisc2-discno INTO i_question.

        CALL FUNCTION 'POPUP_TO_CONFIRM'
          EXPORTING
            titlebar              = 'Sperrauftrag erstellen'
            text_question         = i_question
            text_button_1         = 'Ja'
            text_button_2         = 'Nein'
            default_button        = '1'
            display_cancel_button = ' '
            start_column          = 25
            start_row             = 6
          IMPORTING
            answer                = y_answer
          EXCEPTIONS
            OTHERS                = 1.
        IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ELSE.
          IF y_answer EQ 2.
            EXIT.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDDO.

ENDFORM.                    "edit_discdoc
*&---------------------------------------------------------------------*
*&      Form  druck
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->I_FORM     text
*----------------------------------------------------------------------*
FORM druck CHANGING i_form         TYPE eprintparams-formkey
                    i_adesso_edisc2 TYPE /ADESSO/SPT_EDI2.

  DATA: isel1 LIKE efg_ranges OCCURS 0 WITH HEADER LINE,
        isel2 LIKE efg_ranges OCCURS 0 WITH HEADER LINE,
        h_auto TYPE isu05_discdoc_auto.

** Druckfunktionen nur möglich bei Formularvorgabe
  CHECK NOT i_form IS INITIAL.

*  IF i_form IS INITIAL.
*    i_form = 'Z*'.
*  ENDIF.

* Druckparameter bei Erstaufruf zum Formular versorgen
* Druckdialog vor jedem Druck aufrufen
  IF i_printparams-formkey <> i_form.
    i_printparams-formkey = i_form.

* nur Formulare der Klasse IS_U_CS_DISCONNECTION_ORDER zulassen
    i_printparams-formclass = 'IS_U_CS_DISCONNECTION_ORDER'.

    CALL FUNCTION 'EFG_GET_PRINT_PARAMETERS'
      EXPORTING
        x_printparams = i_printparams
        x_no_formkey  = ''
      IMPORTING
        y_printparams = i_printparams
      EXCEPTIONS
        cancelled     = 1
        input_error   = 2
        failed        = 3
        OTHERS        = 4.
    IF sy-subrc NE 0.
* keine Fehlerausgabe notwendig
      CLEAR i_printparams.
      EXIT.
    ENDIF.
  ENDIF.

* Sperrbelegsaktion um 1 erhöhen
  ADD 1 TO i_adesso_edisc2-discact.
* Druck durchführen
  isel1-low = i_adesso_edisc2-discno.
  APPEND isel1.
  isel2-low = i_adesso_edisc2-discact.
  APPEND isel2.
  CALL FUNCTION 'EFG_PRINT'
    EXPORTING
      x_printparams       = i_printparams
      x_dialog            = ' '
    IMPORTING
      y_printparams       = i_printparams
    TABLES
      xt_ranges           = isel1
      xt_ranges1          = isel2
    EXCEPTIONS
      not_qualified       = 1
      formclass_not_found = 2
      form_not_found      = 3
      internal_error      = 4
      formclass_invalid   = 5
      print_failed        = 6
      form_invalid        = 7
      func_invalid        = 8
      cancelled           = 9
      not_authorized      = 10
      OTHERS              = 11.
  IF sy-subrc NE 0.
    PERFORM write_error USING '002'
                        CHANGING i_adesso_edisc2.
  ENDIF.

* ausgewähltes Formular als temporäres "Customizing-Formular" übernehmen
  i_form = i_printparams-formkey.

ENDFORM.                    "druck
*&---------------------------------------------------------------------*
*&      Form  name_gpart
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->I_adesso_edisc2  text
*----------------------------------------------------------------------*
FORM set_name_gpart CHANGING i_adesso_edisc2 TYPE /ADESSO/SPT_EDI2.
  DATA: y_eadrdat TYPE eadrdat.
  CALL FUNCTION 'ISU_ADDRESS_PROVIDE'
    EXPORTING
      x_address_type             = 'B'
      x_partner                  = i_adesso_edisc2-gpart
    IMPORTING
      y_eadrdat                  = y_eadrdat
    EXCEPTIONS
      not_found                  = 1
      parameter_error            = 2
      object_not_given           = 3
      address_inconsistency      = 4
      installation_inconsistency = 5
      OTHERS                     = 6.
  IF sy-subrc <> 0.
* keine Fehlerausgabe notwendig
  ENDIF.

  i_adesso_edisc2-name1 = y_eadrdat-name1.
  i_adesso_edisc2-name2 = y_eadrdat-name2.
  i_adesso_edisc2-name3 = y_eadrdat-name3.
  i_adesso_edisc2-name4 = y_eadrdat-name4.

ENDFORM.                    "name_gpart
*&---------------------------------------------------------------------*
*&      Form  adresse_vstelle
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->WA_adesso_edisc2 text
*----------------------------------------------------------------------*
FORM set_adresse_vstelle CHANGING i_adesso_edisc2 TYPE /ADESSO/SPT_EDI2.
  DATA:
*        y_addr_lines TYPE eadrln,
        y_eadrdat TYPE eadrdat.
  IF NOT i_adesso_edisc2-anlage IS INITIAL.
    CALL FUNCTION 'ISU_ADDRESS_PROVIDE'
      EXPORTING
        x_address_type = 'I'
        x_anlage       = i_adesso_edisc2-anlage
      IMPORTING
*        y_addr_lines   = y_addr_lines
        y_eadrdat      = y_eadrdat
      EXCEPTIONS
        OTHERS         = 1.
    IF sy-subrc NE 0.
      PERFORM write_error USING '003'
                          CHANGING i_adesso_edisc2.
    ELSE.
      i_adesso_edisc2-street = y_eadrdat-street.
      i_adesso_edisc2-house_num1 = y_eadrdat-house_num1.
      i_adesso_edisc2-post_code1 = y_eadrdat-post_code1.
      i_adesso_edisc2-city1 = y_eadrdat-city1.
      i_adesso_edisc2-city2 = y_eadrdat-city2.
    ENDIF.
  ENDIF.
ENDFORM.                    "adresse_vstelle
*&---------------------------------------------------------------------*
*&      Form  check_ediscdoc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->I_OBJ           text
*      -->,               text
*      -->I_KZ_ABSCHLUSS  text
*----------------------------------------------------------------------*
FORM check_ediscdoc CHANGING i_obj          TYPE isu05_discdoc_internal
                             i_kz_abschluss TYPE kennzx.
* prüfen, ob Sperrgrund obsolet
  IF i_obj-ediscdoc-dat_obsolt LE sy-datum
    AND i_obj-ediscdoc-dat_obsolt NE '00000000'.
    i_kz_abschluss = 'X'.
  ENDIF.
ENDFORM.                    "check_ediscdoc
*&---------------------------------------------------------------------*
*&      Form  open_discdoc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->I_DISCNO   text
*      -->I_OBJ      text
*----------------------------------------------------------------------*
FORM open_discdoc CHANGING i_adesso_edisc2 TYPE /ADESSO/SPT_EDI2
                           i_obj TYPE isu05_discdoc_internal.
  CALL FUNCTION 'ISU_O_DISCDOC_OPEN_INTERNAL'
    EXPORTING
      x_discno       = i_adesso_edisc2-discno
      x_wmode        = '1'
    IMPORTING
      y_obj          = i_obj
    EXCEPTIONS
      not_found      = 1
      not_authorized = 2
      existing       = 3
      foreign_lock   = 4
      invalid_key    = 5
      number_error   = 6
      input_error    = 7
      system_error   = 8
      OTHERS         = 9.
  IF sy-subrc NE 0.
    PERFORM write_error USING '004'
                        CHANGING i_adesso_edisc2.
  ENDIF.
ENDFORM.                    "open_discdoc
*&---------------------------------------------------------------------*
*&      Form  determine_credit_rating
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->I_adesso_edisc2  text
*----------------------------------------------------------------------*
FORM determine_credit_rating CHANGING i_adesso_edisc2 TYPE /ADESSO/SPT_EDI2.
  IF NOT i_adesso_edisc2-gpart IS INITIAL.
    CALL FUNCTION 'FKK_DETERMINE_CREDIT_RATING'
      EXPORTING
        i_gpart = i_adesso_edisc2-gpart
        i_datum = sy-datum
      IMPORTING
        e_bonit = i_adesso_edisc2-bonit.
    IF sy-subrc NE 0.
      PERFORM write_error USING '007'
                    CHANGING i_adesso_edisc2.
    ENDIF.
  ENDIF.
ENDFORM.                    "DETERMINE_CREDIT_RATING
*&---------------------------------------------------------------------*
*&      Form  write_error
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->I_MSGNO    text
*      -->I_adesso_edisc2  text
*----------------------------------------------------------------------*
FORM write_error USING    i_msgno TYPE symsgno
                 CHANGING i_adesso_edisc2 TYPE /ADESSO/SPT_EDI2.
  DATA: i_text TYPE char255.
  i_kz_fehler     = 'X'.
  i_adesso_edisc2-error = 'X'.
  CASE i_msgno.
    WHEN '001'.
      i_text = 'Fehler bei Ermittlung Offene Posten lesen (Error 001)'.
    WHEN '002'.
      i_text = 'Fehler bei Druck (Error 002)'.
    WHEN '003'.
      i_text = 'Fehler bei Ermittlung Adresse zur Verbrauchsstelle (Error 003)'.
    WHEN '004'.
      i_text = 'Fehler bei Lesen Sperrbeleg (Error 004)'.
    WHEN '005'.
      i_text = 'Fehler bei Gebührenbuchung (Error 005)'.
    WHEN '006'.
      i_text = 'Fehler bei Änderung Sperrbelegstatus (Error 006)'.
    WHEN '007'.
      i_text = 'Fehler bei Ermittlung Bonität (Error 007)'.
    WHEN '008'.
      i_text = 'Keine Berechtigung (Error 008)'.
    WHEN '009'.
      i_text = 'Objekt in anderem Sperrbeleg (Error 009)'.
    WHEN '010'.
      i_text = 'Objekt in anderem Sperrbeleg (Error 010)'.
    WHEN OTHERS.
  ENDCASE.

  CONCATENATE 'Sperrbeleg' i_adesso_edisc2-discno ':' i_text INTO i_error SEPARATED BY space.
  APPEND i_error TO it_error.
ENDFORM.                    "write_error
*&---------------------------------------------------------------------*
*&      Form  error_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM error_message.
  IF NOT i_kz_fehler IS INITIAL.
    MESSAGE 'Fehler! Bitte Ausgabe beachten!' TYPE 'S'.
  ENDIF.
ENDFORM.                    "error_message
*&---------------------------------------------------------------------*
*&      Form  F4_REPORT_VARIANT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f4_report_variant.
  is_variant-report = sy-repid.
*  is_variant-USERNAME = sy-uname.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant                = is_variant
*   I_TABNAME_HEADER          = I_TABNAME_HEADER
*   I_TABNAME_ITEM            = I_TABNAME_ITEM
*   IT_DEFAULT_FIELDCAT       = IT_DEFAULT_FIELDCAT
    i_save                    = i_save
*   I_DISPLAY_VIA_GRID        = ' '
    IMPORTING
*   E_EXIT                    = E_EXIT
     es_variant                = is_variant
   EXCEPTIONS
     not_found                 = 1
     program_error             = 2
     OTHERS                    = 3.
  IF sy-subrc NE 0.
    MESSAGE 'Es wurden noch keine Varianten angelegt' TYPE 'S'.
  ELSE.
    p_varian = is_variant-variant.
  ENDIF.

ENDFORM.                    "F4_REPORT_VARIANT
*&---------------------------------------------------------------------*
*&      Form  kontakt_anlegen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->I_TYP      text
*      -->I_adesso_edisc2  text
*----------------------------------------------------------------------*
FORM kontakt_anlegen USING i_bpcconfig TYPE bcontconf-bpcconfig
                           i_adesso_edisc2  TYPE  /ADESSO/SPT_EDI2
                  CHANGING i_bpcontact TYPE bcont-bpcontact.

  TYPE-POOLS: bpc01.

* Kontakt anlegen nur möglich, falls
* entsprechende Kontaktkonfiguration gefüllt
  CHECK NOT i_bpcconfig IS INITIAL.

* Kontakt mitels Kontaktkonfiguration erzeugen
  CALL FUNCTION 'BCONTACT_CREATE'
    EXPORTING
      x_upd_online    = 'X'
      x_no_dialog     = 'X'
      x_bpcconfig     = i_bpcconfig
      x_partner       = i_adesso_edisc2-gpart
    IMPORTING
      y_new_bpcontact = i_bpcontact
    EXCEPTIONS
      existing        = 1
      foreign_lock    = 2
      number_error    = 3
      general_fault   = 4
      input_error     = 5
      not_authorized  = 6
      OTHERS          = 7.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

* Objektverknüpfungen anlegen
  DATA: lt_bconto TYPE STANDARD TABLE OF bcont_obj,
        lf_bconto TYPE bcont_obj.

* Sperrbeleg
  CLEAR lf_bconto.
  lf_bconto-bpcontact = i_bpcontact.
  lf_bconto-objrole   = 'DEFAULT'.
  lf_bconto-objtype   = 'DISCONNECT'.
  lf_bconto-objkey    = i_adesso_edisc2-discno.
  lf_bconto-reltype   = 'EREF'.
  APPEND lf_bconto TO lt_bconto.

* Geschäftspartner
  CLEAR lf_bconto.
  lf_bconto-bpcontact = i_bpcontact.
  lf_bconto-objrole   = 'DEFAULT'.
  lf_bconto-objtype   = 'ISUPARTNER'.
  lf_bconto-objkey    = i_adesso_edisc2-gpart.
  lf_bconto-reltype   = 'EREF'.
  APPEND lf_bconto TO lt_bconto.

* Vertragskonto
  CLEAR lf_bconto.
  lf_bconto-bpcontact = i_bpcontact.
  lf_bconto-objrole   = 'DEFAULT'.
  lf_bconto-objtype   = 'ISUACCOUNT'.
  lf_bconto-objkey    = i_adesso_edisc2-vkont.
  lf_bconto-reltype   = 'EREF'.
  APPEND lf_bconto TO lt_bconto.

  CALL FUNCTION 'BCONTACT_CREATE_RELATIONS'
    TABLES
      tx_bconto    = lt_bconto
    EXCEPTIONS
      update_error = 1
      OTHERS       = 2.

ENDFORM.                    "kontakt_anlegen
*&---------------------------------------------------------------------*
*&      Form  change_discdoc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->I_adesso_edisc2  text
*----------------------------------------------------------------------*
FORM change_discdoc USING i_discacttyp
                    CHANGING i_adesso_edisc2 TYPE /ADESSO/SPT_EDI2
                             i_opbel   TYPE fkkko-opbel
                             i_bpcontact TYPE bcont-bpcontact.
  DATA: y_obj TYPE isu05_discdoc_internal,
        wa_ediscact TYPE ediscact.

  CHECK NOT i_opbel IS INITIAL OR NOT i_bpcontact IS INITIAL.


  CLEAR: y_obj.

  PERFORM open_discdoc CHANGING i_adesso_edisc2
                                y_obj.

* aktuellste Sperraktion mit "Freigabe Sperrbeleg" ermitteln
  SORT y_obj-ediscact BY discact DESCENDING.
  LOOP AT y_obj-ediscact INTO wa_ediscact
    WHERE discacttyp EQ i_discacttyp.
    EXIT.
  ENDLOOP.

  wa_ediscact-bc_contact = i_bpcontact.
  wa_ediscact-charge_opbel = i_opbel.

  MODIFY ediscact FROM wa_ediscact.
  IF sy-subrc EQ 0.
    COMMIT WORK.
  ELSE.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.                    "change_discdoc
*&---------------------------------------------------------------------*
*&      Form  DETERMINE_EXT_UI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_I_adesso_edisc2  text
**      -->P_WA_EANL_ANLAGE  text
**      <--P_I_adesso_edisc2_EXT_UI  text
*----------------------------------------------------------------------*
FORM determine_ext_ui CHANGING i_adesso_edisc2 TYPE /ADESSO/SPT_EDI2.
*  USING    p_wa_eanl_anlage LIKE eanl-anlage
*  CHANGING p_i_adesso_edisc2_ext_ui LIKE euitrans-ext_ui.
  DATA: l_ext_pod LIKE euitrans-ext_ui.

  CALL FUNCTION 'ISU_INT_UI_DETERMINE'
    EXPORTING
*     x_contract = ...                     "OPTIONAL
       x_anlage   = i_adesso_edisc2-anlage  "OPTIONAL
*     x_ext_pod  = ...                     "OPTIONAL
*     x_int_pod  = ...                     "OPTIONAL
*     x_keydate  = ...                     "SY-DATUM
    IMPORTING
*     y_contract = ...                     "EVER-VERTRAG
*     y_anlage = ...                       "EANL-ANLAGE
       y_ext_pod = l_ext_pod                "EUITRANS-EXT_UI
*     y_int_pod  = ...                     "EUITRANS-INT_UI
*     y_sparte = ...                       "SPARTE
    EXCEPTIONS
        not_found = 1
        programming_error = 2
        system_error = 3.

ENDFORM.                    " DETERMINE_EXT_UI


*&---------------------------------------------------------------------*
*&      Form  GET_VDEWNUM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_I_adesso_edisc2  text
*----------------------------------------------------------------------*
FORM get_vdewnum  CHANGING i_adesso_edisc2.
*  DATA: l_zediscdoc LIKE zediscdoc.
*
*  SELECT vdewnum
*    FROM zediscdoc
*    INTO l_zediscdoc
*    WHERE discno EQ i_adessot_edisc-disno
*    .
ENDFORM.                    " GET_VDEWNUM
