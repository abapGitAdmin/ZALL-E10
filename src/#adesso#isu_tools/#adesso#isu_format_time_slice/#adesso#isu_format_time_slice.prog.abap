***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                     Datum: 07.08.2017
*
* Beschreibung: Einfacher Report zum zurückstellen von Zeitscheiben. Die Änderungen können auch
*               wieder rückgängig gemacht werden.
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* THIMEL-R    03.10.2019 Sonderfall 01.12.2019 und Sicherheitsabfrage
* THIMEL-R    17.10.2019 Refaktoring + Löschen für Tabellen angepasst
* THIMEL-R    22.02.2021 Neue Codelisten Tabbelle aufgenommen
***************************************************************************************************
REPORT /adesso/isu_format_time_slice.
DATA: lt_amid_conf_del TYPE TABLE OF /idxgc/amid_conf,
      lt_cdlst_con_del TYPE TABLE OF /idxgl/cdlst_con,
      lv_string        TYPE string,
      lv_answer        TYPE char1,
      lv_date_from     TYPE dats,
      lv_date_from_n   TYPE dats,
      lv_date_to       TYPE dats,
      lv_date_to_n     TYPE dats,
      lv_flag_modified TYPE boolean.

* Selektionsbildschirm
SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-001.
PARAMETERS: p_date TYPE dats OBLIGATORY.
PARAMETERS: p_date_n TYPE dats OBLIGATORY.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: r_add_c RADIOBUTTON GROUP rad1 DEFAULT 'X'.
SELECTION-SCREEN COMMENT 3(79) TEXT-add.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: r_del_c RADIOBUTTON GROUP rad1.
SELECTION-SCREEN COMMENT 3(79) TEXT-del.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b01.

SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-002.
PARAMETERS: p_ou_vcg AS CHECKBOX DEFAULT 'X',
            p_centrl AS CHECKBOX DEFAULT 'X',
            p_parclo AS CHECKBOX DEFAULT 'X',
            p_msgout AS CHECKBOX DEFAULT 'X',
            p_mescod AS CHECKBOX DEFAULT 'X',
            p_prvers AS CHECKBOX DEFAULT 'X',
            p_msgcli AS CHECKBOX DEFAULT 'X',
            p_amidco AS CHECKBOX DEFAULT 'X',
            p_bmidva AS CHECKBOX DEFAULT 'X',
            p_cdlstc AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK b02.


INITIALIZATION.
  p_date = sy-datum.
  IF sy-datum BETWEEN '20190401' AND '20191201'. "RT, 03.10.2019, Sonderfall 01.12.2019
    p_date+4(4) = '1201'.
  ELSEIF sy-datum+4(4) BETWEEN '0401' AND '0930'.
    p_date+4(4) = '1001'.
  ELSE.
    p_date+4(4) = '0401'.
  ENDIF.

  p_date_n = p_date.
  DO 2 TIMES.
    p_date_n = p_date_n - 1.
    p_date_n+6(2) = '01'.
  ENDDO.

START-OF-SELECTION.

  IF sy-sysid CS 'P'. "RT, 03.10.2019, Auf Produktivsystemen nicht ausführen. Funktioniert für alle wo das Programm im Einsatz ist.
    RETURN.
  ENDIF.

  IF ( p_date_n CS '1001' OR p_date_n CS '0401' OR p_date_n = '20191201' ) AND r_del_c IS NOT INITIAL. "RT, 03.10.2019, Sonderfall 01.12.2019
    CONCATENATE 'Möchten Sie die Zeitscheiben zum' p_date_n 'wirklich löschen?'
    INTO lv_string SEPARATED BY space.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar       = ' '
        text_question  = lv_string
      IMPORTING
        answer         = lv_answer
      EXCEPTIONS
        text_not_found = 1
        OTHERS         = 2.
    IF sy-subrc <> 0 OR lv_answer <> 1.
      MESSAGE e000(e4) WITH 'Abbruch durch Benutzer'.
    ENDIF.

  ENDIF.

***** IDEXGE: Klasse für Nachrichtenausgang zuordnen **********************************************
  IF p_ou_vcg = abap_true.
    SELECT * FROM /idexge/t_ou_vcg INTO TABLE @DATA(lt_ou_vcg) WHERE datefrom = @p_date.

    LOOP AT lt_ou_vcg ASSIGNING FIELD-SYMBOL(<fs_ou_vcg>).
      <fs_ou_vcg>-datefrom = p_date_n.
    ENDLOOP.

    IF r_add_c IS NOT INITIAL.
      MODIFY /idexge/t_ou_vcg FROM TABLE @lt_ou_vcg.
    ELSE.
      DELETE /idexge/t_ou_vcg FROM TABLE @lt_ou_vcg.
    ENDIF.
  ENDIF.

***** /IDEXGE/T_CENTRL ****************************************************************************
  IF p_centrl = abap_true.
    SELECT * FROM /idexge/t_centrl INTO TABLE @DATA(lt_centrl) WHERE datefrom = @p_date.

    LOOP AT lt_centrl ASSIGNING FIELD-SYMBOL(<fs_centrl>).
      <fs_centrl>-datefrom = p_date_n.
    ENDLOOP.

    IF r_add_c IS NOT INITIAL.
      MODIFY /idexge/t_centrl FROM TABLE @lt_centrl.
    ELSE.
      DELETE /idexge/t_centrl FROM TABLE @lt_centrl.
    ENDIF.
  ENDIF.

***** IDXGC: Parser-Klasse f. d. AusgVerarbeitung v. Nachrichten zuordnen *************************
  IF p_parclo = abap_true.
    SELECT * FROM /idxgc/parcl_out INTO TABLE @DATA(lt_parcl_out) WHERE valid_from = @p_date AND active = @abap_true.

    LOOP AT lt_parcl_out ASSIGNING FIELD-SYMBOL(<fs_parcl_out>).
      <fs_parcl_out>-valid_from = p_date_n.
      <fs_parcl_out>-source     = /idxgc/if_constants_ide=>gc_customer_source.
    ENDLOOP.

    IF r_add_c IS NOT INITIAL.
      MODIFY /idxgc/parcl_out FROM TABLE @lt_parcl_out.
    ELSE.
      DELETE /idxgc/parcl_out FROM TABLE @lt_parcl_out.
    ENDIF.
  ENDIF.

***** /IDXGC/MSG_OUT ****************************************************************************
  IF p_msgout = abap_true.
    SELECT * FROM /idxgc/msg_out INTO TABLE @DATA(lt_msg_out) WHERE valid_from = @p_date AND active = @abap_true.

    FIELD-SYMBOLS: <fs_msg_out> TYPE /idxgc/msg_out.

    "Auf Grund des Schlüssels der Tabelle müssen identische Einträge für Kunde und SAP gelöscht werden.
    "Es soll immer nur der Kundeneintrag zurück gestellt werden.
    IF r_add_c IS NOT INITIAL.
      LOOP AT lt_msg_out ASSIGNING <fs_msg_out> WHERE source = /idxgc/if_constants_ide=>gc_sap_source AND active = abap_true.
        IF line_exists( lt_msg_out[ dexbasicproc = <fs_msg_out>-dexbasicproc dexformat = <fs_msg_out>-dexformat
                                    valid_from   = <fs_msg_out>-valid_from   source    = /idxgc/if_constants_ide=>gc_customer_source
                                    active       = abap_true ] ).
          DELETE lt_msg_out.
        ENDIF.
      ENDLOOP.
    ENDIF.

    LOOP AT lt_msg_out ASSIGNING <fs_msg_out>.
      <fs_msg_out>-valid_from = p_date_n.
      <fs_msg_out>-source = /idxgc/if_constants_ide=>gc_customer_source.
    ENDLOOP.

    IF r_add_c IS NOT INITIAL.
      MODIFY /idxgc/msg_out FROM TABLE @lt_msg_out.
    ELSE.
      DELETE /idxgc/msg_out FROM TABLE @lt_msg_out.
    ENDIF.
  ENDIF.

***** IDXGC: NachrCode und AnwendCode der zuständ. Organis. des NachrTyps *************************
  IF p_mescod = abap_true.
    SELECT * FROM /idxgc/t_mescod INTO TABLE @DATA(lt_mescod) WHERE valid_from = @p_date.

    LOOP AT lt_mescod ASSIGNING FIELD-SYMBOL(<fs_mescod>).
      <fs_mescod>-valid_from = p_date_n.
    ENDLOOP.

    IF r_add_c IS NOT INITIAL.
      MODIFY /idxgc/t_mescod FROM TABLE @lt_mescod.
    ELSE.
      DELETE /idxgc/t_mescod FROM TABLE @lt_mescod.
    ENDIF.
  ENDIF.

***** IDXGC: Konfiguration der Prozessversion *****************************************************
  IF p_prvers = abap_true.
    SELECT * FROM /idxgc/procvers INTO TABLE @DATA(lt_procvers) WHERE valid_from = @p_date.

    LOOP AT lt_procvers ASSIGNING FIELD-SYMBOL(<fs_procvers>).
      <fs_procvers>-source = /idxgc/if_constants_ide=>gc_customer_source.
      <fs_procvers>-valid_from = p_date_n.
    ENDLOOP.

    IF r_add_c IS NOT INITIAL.
      MODIFY /idxgc/procvers FROM TABLE @lt_procvers.
    ELSE.
      DELETE /idxgc/procvers FROM TABLE @lt_procvers.
    ENDIF.
  ENDIF.

***** IDXGC: Nachrichtenklasse f. die EingVerarb. v. Nachrichten zuordnen *************************
  IF p_msgcli = abap_true.
    SELECT * FROM /idxgc/msgcl_in INTO TABLE @DATA(lt_msgcl_in) WHERE valid_from = @p_date AND active = @abap_true.

    FIELD-SYMBOLS: <ls_msgcl_in> TYPE /idxgc/msgcl_in.
    "Auf Grund des Schlüssels der Tabelle müssen identische Einträge für Kunde und SAP gesondert behandelt werden.
    "Es soll immer nur der Kundeneintrag zurück gestellt werden.
    IF r_add_c = abap_true.
      LOOP AT lt_msgcl_in ASSIGNING <ls_msgcl_in> WHERE source = /idxgc/if_constants_ide=>gc_sap_source AND active = abap_true.
        IF line_exists( lt_msgcl_in[ dexbasicproc = <ls_msgcl_in>-dexbasicproc valid_from = <ls_msgcl_in>-valid_from dexformat = <ls_msgcl_in>-dexformat
                                     source = /idxgc/if_constants_ide=>gc_customer_source active = abap_true ] ).
          DELETE lt_msgcl_in.
        ENDIF.
      ENDLOOP.
    ENDIF.



    LOOP AT lt_msgcl_in ASSIGNING <ls_msgcl_in>.
      <ls_msgcl_in>-valid_from = p_date_n.
      <ls_msgcl_in>-source = /idxgc/if_constants_ide=>gc_customer_source.
    ENDLOOP.

    IF r_add_c IS NOT INITIAL.
      MODIFY /idxgc/msgcl_in FROM TABLE @lt_msgcl_in.
    ELSE.
      DELETE /idxgc/msgcl_in FROM TABLE @lt_msgcl_in.
    ENDIF.
  ENDIF.

***** /IDXGC/AMID_CONF ****************************************************************************
  IF p_amidco = abap_true.
    SELECT * FROM /idxgc/amid_conf INTO TABLE @DATA(lt_amid_conf).

    IF r_del_c = abap_true.
      lv_date_from   = p_date_n.
      lv_date_from_n = p_date.
    ELSE.
      lv_date_from   = p_date.
      lv_date_from_n = p_date_n.
    ENDIF.

    lv_date_to   = lv_date_from - 1.
    lv_date_to_n = lv_date_from_n - 1.

    LOOP AT lt_amid_conf ASSIGNING FIELD-SYMBOL(<ls_amid_conf>).
      lv_flag_modified = abap_false.
      DATA(ls_amid_conf_old) = <ls_amid_conf>.
      IF <ls_amid_conf>-begda = lv_date_from.
        <ls_amid_conf>-begda = lv_date_from_n.
        lv_flag_modified = abap_true.
      ENDIF.
      IF <ls_amid_conf>-endda = lv_date_to.
        <ls_amid_conf>-endda = lv_date_to_n.
        lv_flag_modified = abap_true.
      ENDIF.
      IF lv_flag_modified = abap_true.
        lt_amid_conf_del = VALUE #( BASE lt_amid_conf_del ( ls_amid_conf_old ) ).
      ELSE.
        DELETE lt_amid_conf.
      ENDIF.
    ENDLOOP.

    DELETE /idxgc/amid_conf FROM TABLE @lt_amid_conf_del.
    MODIFY /idxgc/amid_conf FROM TABLE @lt_amid_conf.
  ENDIF.

***** /IDXGC/BMID_VAR ****************************************************************************
  IF p_bmidva = abap_true.
    DATA(lv_valid_from)     = p_date_n.
    DATA(lv_valid_from_old) = p_date.
    IF r_del_c = abap_true.
      lv_valid_from     = p_date.
      lv_valid_from_old = p_date_n.
    ENDIF.

    SELECT * FROM /idxgc/bmid_var INTO TABLE @DATA(lt_bmid_var) WHERE valid_from = @lv_valid_from_old AND active = @abap_true.

    FIELD-SYMBOLS: <ls_bmid_var> TYPE /idxgc/bmid_var.

    "Auf Grund des Schlüssels der Tabelle müssen identische Einträge für Kunde und SAP gesondert behandelt werden.
    "Es soll immer nur der Kundeneintrag zurück gestellt werden.
    IF r_add_c = abap_true.
      SELECT * FROM /idxgc/bmid_var INTO TABLE @DATA(lt_bmid_var_new) WHERE valid_from = @lv_valid_from AND source = @/idxgc/if_constants_ide=>gc_customer_source AND active = @abap_true.
      LOOP AT lt_bmid_var ASSIGNING <ls_bmid_var> WHERE source = /idxgc/if_constants_ide=>gc_sap_source AND active = abap_true.
        IF line_exists( lt_bmid_var[ bmid_var = <ls_bmid_var>-bmid_var bmid = <ls_bmid_var>-bmid source = /idxgc/if_constants_ide=>gc_customer_source active = abap_true ] ) OR "Bei doppelten den Kundeneintrag nehmen
           line_exists( lt_bmid_var_new[ bmid_var = <ls_bmid_var>-bmid_var bmid = <ls_bmid_var>-bmid ] ). "Schon bestehende Kundeneinträge behalten.
          DELETE lt_bmid_var.
        ENDIF.
      ENDLOOP.
      "Falls schon Einträge existieren, nicht mit SAP-Einträgen überschreiben.
    ENDIF.

    "Wenn bei der Rücksetzung ein identische SAP Einträge schon vorhanden ist, dann muss der jetzige Eintrag gelöscht werden.
    DATA: lt_bmid_var_del TYPE TABLE OF /idxgc/bmid_var.
    IF r_del_c = abap_true.
      SELECT * FROM /idxgc/bmid_var INTO TABLE @DATA(lt_bmid_var_actual) WHERE valid_from = @lv_valid_from.
      LOOP AT lt_bmid_var ASSIGNING <ls_bmid_var>.
        IF line_exists( lt_bmid_var_actual[ bmid_var = <ls_bmid_var>-bmid_var bmid = <ls_bmid_var>-bmid
                                            source = /idxgc/if_constants_ide=>gc_sap_source active = abap_true
                                            data_prov_class = <ls_bmid_var>-data_prov_class ] ).
          APPEND <ls_bmid_var> TO lt_bmid_var_del.
          DELETE lt_bmid_var.
        ENDIF.
      ENDLOOP.
    ENDIF.

    LOOP AT lt_bmid_var ASSIGNING <ls_bmid_var>.
      <ls_bmid_var>-valid_from  = lv_valid_from.
      <ls_bmid_var>-source = /idxgc/if_constants_ide=>gc_customer_source.
    ENDLOOP.

    IF r_del_c = abap_true AND lt_bmid_var_del IS NOT INITIAL.
      DELETE /idxgc/bmid_var FROM TABLE @lt_bmid_var_del.
    ENDIF.

    MODIFY /idxgc/bmid_var FROM TABLE @lt_bmid_var.
  ENDIF.

***** /IDXGL/CDLST_CON ****************************************************************************
  IF p_cdlstc = abap_true.
    SELECT * FROM /idxgl/cdlst_con INTO TABLE @DATA(lt_cdlst_con).

    IF r_del_c = abap_true.
      lv_date_from   = p_date_n.
      lv_date_from_n = p_date.
    ELSE.
      lv_date_from   = p_date.
      lv_date_from_n = p_date_n.
    ENDIF.

    lv_date_to   = lv_date_from - 1.
    lv_date_to_n = lv_date_from_n - 1.

    LOOP AT lt_cdlst_con ASSIGNING FIELD-SYMBOL(<ls_cdlst_con>).
      lv_flag_modified = abap_false.
      DATA(ls_cdlst_con_old) = <ls_cdlst_con>.
      IF <ls_cdlst_con>-begda = lv_date_from.
        <ls_cdlst_con>-begda = lv_date_from_n.
        lv_flag_modified = abap_true.
      ENDIF.
      IF <ls_cdlst_con>-endda = lv_date_to.
        <ls_cdlst_con>-endda = lv_date_to_n.
        lv_flag_modified = abap_true.
      ENDIF.
      IF lv_flag_modified = abap_true.
        lt_cdlst_con_del = VALUE #( BASE lt_cdlst_con_del ( ls_cdlst_con_old ) ).
      ELSE.
        DELETE lt_cdlst_con.
      ENDIF.
    ENDLOOP.

    DELETE /idxgl/cdlst_con FROM TABLE @lt_cdlst_con_del.
    MODIFY /idxgl/cdlst_con FROM TABLE @lt_cdlst_con.
  ENDIF.
