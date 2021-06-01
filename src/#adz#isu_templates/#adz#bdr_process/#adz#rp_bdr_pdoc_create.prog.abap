REPORT /adz/rp_bdr_pdoc_create.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R, KERKHOFF-L, WISNIEWSKI-P                                      Datum: 02.11.2018
*
* Beschreibung: Programm zum Versand von ORDERS Nachrichten
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
TYPES: BEGIN OF tt_inst_per_abl,
         int_ui   TYPE int_ui,
         ext_ui   TYPE ext_ui,
         adatsoll TYPE adatsoll,
         bezug    TYPE bezug,
         is_melo  TYPE /idxgc/de_boolean_flag,
       END OF tt_inst_per_abl.

DATA: lr_badi_data_access   TYPE REF TO /idxgl/badi_data_access,
      lt_bdr_create_req     TYPE /adz/t_bdr_create_req,
      lt_euitrans           TYPE TABLE OF euitrans,
      lt_euitrans_malo_melo TYPE /idxgl/t_euitrans_malo_melo,
      ls_bdr_orders_hdr     TYPE /adz/s_bdr_orders_hdr,
      lv_pod_is_melo        TYPE /idxgc/de_boolean_flag,
      lv_pod_is_malo        TYPE /idxgc/de_boolean_flag,
      lv_ablbelnr           TYPE ablbelnr,

*---- Variablen die durch Z30 und Z31 verwendet werden --------------------------------------------
      lv_keydate            TYPE /idxgc/de_keydate,
      lt_bdr_devconf        TYPE TABLE OF /adz/bdr_devconf,

*---- Variablen die nur durch Z34 verwendet werden ------------------------------------------------
      lr_parsing            TYPE REF TO object,
      lt_cl_process_data    TYPE /idxgc/t_cl_process_data_extrn,
      lt_eedmimportlog_db   TYPE TABLE OF eedmimportlog_db,
      lt_docnum             TYPE TABLE OF edi_docnum,
      lt_edidc              TYPE TABLE OF edidc,
      lt_msconsref          TYPE TABLE OF /idxgc/msconsref,
      lt_eabl               TYPE TABLE OF eabl,
      lt_eablg              TYPE TABLE OF eablg,
      lt_euiinstln          TYPE TABLE OF euiinstln,
      lv_anlage             TYPE anlage,
      ls_edex_idocdata      TYPE edex_idocdata,
      ls_proc_data          TYPE /idxgc/s_proc_data,
      lv_serv_measval       TYPE /idxgc/de_serv_measval,
      ls_inst_for_abl       TYPE tt_inst_per_abl,
      lt_inst_for_abl       TYPE TABLE OF tt_inst_per_abl.

FIELD-SYMBOLS: <ls_bdr_create_req>   TYPE /adz/s_bdr_create_req,
               <ls_bdr_devconf>      TYPE /adz/bdr_devconf,
               <ls_eedmimportlog_db> TYPE eedmimportlog_db,
               <ls_edidc>            TYPE edidc,
               <lv_docnum>           TYPE edi_docnum,
               <ls_euitrans>         TYPE euitrans,
               <ls_eabl>             TYPE eabl,
               <ls_inst_for_abl>     TYPE tt_inst_per_abl.

***** Selektionsscreen ****************************************************************************

*---- BLOCK 1: Auswahl des Nachrichtentyps --------------------------------------------------------
SELECTION-SCREEN BEGIN OF BLOCK gb_hdr WITH FRAME TITLE TEXT-bk1.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_z14  RADIOBUTTON GROUP g1 USER-COMMAND chng.
SELECTION-SCREEN COMMENT 6(60) TEXT-t14 FOR FIELD p_z14.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_z30  RADIOBUTTON GROUP g1 DEFAULT 'X'.
SELECTION-SCREEN COMMENT 6(60) TEXT-t30 FOR FIELD p_z30.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_z31  RADIOBUTTON GROUP g1.
SELECTION-SCREEN COMMENT 6(60) TEXT-t31 FOR FIELD p_z31.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_z34z11  RADIOBUTTON GROUP g1.
SELECTION-SCREEN COMMENT 6(60) TEXT-t34 FOR FIELD p_z34z11.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_z34z12  RADIOBUTTON GROUP g1.
SELECTION-SCREEN COMMENT 6(60) TEXT-t35 FOR FIELD p_z34z12.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_z34z35  RADIOBUTTON GROUP g1.
SELECTION-SCREEN COMMENT 6(60) TEXT-t36 FOR FIELD p_z34z35.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK gb_hdr.

*---- BLOCK 2: Z14: Änderung des Bilanzierungsverfahrens ------------------------------------------
SELECTION-SCREEN BEGIN OF BLOCK gb_z14 WITH FRAME TITLE TEXT-bk2.

SELECT-OPTIONS: s_exui14 FOR <ls_bdr_create_req>-ext_ui     MODIF ID d14.

SELECTION-SCREEN END OF BLOCK gb_z14.

*---- BLOCK 3: Z30: Änderung des Bilanzierungsverfahrens ------------------------------------------
SELECTION-SCREEN BEGIN OF BLOCK gb_z30 WITH FRAME TITLE TEXT-bk3.

SELECT-OPTIONS: s_exui30 FOR <ls_bdr_create_req>-ext_ui     MODIF ID d30.
PARAMETERS: p_exdt30 TYPE /idxgc/de_execution_date          MODIF ID d30,
            p_sttl30 TYPE /idxgc/de_settl_proc              MODIF ID d30,
            p_dvc30  TYPE /idxgc/de_device_conf             MODIF ID d30.

SELECTION-SCREEN END OF BLOCK gb_z30.

*---- BLOCK 4: Z31: Änderung der Gerätekonfiguration ----------------------------------------------
SELECTION-SCREEN BEGIN OF BLOCK gb_z31 WITH FRAME TITLE TEXT-bk4.

SELECT-OPTIONS: s_exui31 FOR <ls_bdr_create_req>-ext_ui     MODIF ID d31.
PARAMETERS: p_exdt31 TYPE /idxgc/de_execution_date          MODIF ID d31,
            p_sttl31 TYPE /idxgc/de_settl_proc              MODIF ID d31,
            p_dvc31  TYPE /idxgc/de_device_conf             MODIF ID d31.

SELECTION-SCREEN END OF BLOCK gb_z31.

*---- BLOCK 5: Z34-Z11: Reklamation von Lastgängen ------------------------------------------------
SELECTION-SCREEN BEGIN OF BLOCK gb_z34z11 WITH FRAME TITLE TEXT-bk5.

SELECT-OPTIONS: s_lblnr  FOR <ls_eedmimportlog_db>-logbelnr MODIF ID d11,
                s_idoc11 FOR <ls_eedmimportlog_db>-docnum   MODIF ID d11.

SELECTION-SCREEN END OF BLOCK gb_z34z11.

*---- BLOCK 6: Z34-Z12: Reklamation von Zählerständen ---------------------------------------------
SELECTION-SCREEN BEGIN OF BLOCK gb_z34z12 WITH FRAME TITLE TEXT-bk6.

SELECT-OPTIONS: s_ablbel FOR lv_ablbelnr                    MODIF ID d12,
                s_idoc12 FOR <ls_eedmimportlog_db>-docnum   MODIF ID d12.

SELECTION-SCREEN END OF BLOCK gb_z34z12.

*---- BLOCK 7: Z34-Z35: Reklamation von Energiemenge Einzelwert -----------------------------------
SELECTION-SCREEN BEGIN OF BLOCK gb_z34z35 WITH FRAME TITLE TEXT-bk7.

SELECT-OPTIONS: s_idoc35 FOR <ls_eedmimportlog_db>-docnum   MODIF ID d35.

SELECTION-SCREEN END OF BLOCK gb_z34z35.

*---- BLOCK 8: Z34: Grund für Reklamation ---------------------------------------------------------
SELECTION-SCREEN BEGIN OF BLOCK gb_z34 WITH FRAME TITLE TEXT-bk8.

PARAMETERS: p_tqual TYPE /adz/de_bdr_text_subj_qual         MODIF ID d34,
            p_text  TYPE /adz/de_bdr_free_text_value        MODIF ID d34.

SELECTION-SCREEN END OF BLOCK gb_z34.

***** Selection-Screen Anpassungen durch Auswahl **************************************************
AT SELECTION-SCREEN OUTPUT.

*---- Mögliche Nachrichtentypen ausblenden je nach eigenem Servicetyp -----------------------------
  TRY.
      IF /adz/cl_bdr_utility=>is_own_intcode( /adz/if_bdr_co=>gc_intcode_02 ) = abap_false.
        IF p_z30 = abap_true.
          p_z30 = abap_false.
          p_z31 = abap_true.
        ENDIF.
        LOOP AT SCREEN.
          IF screen-name = 'P_Z30'.
            screen-input = '0'.
          ENDIF.
          IF screen-group1 = 'D30'.
            screen-active = '0'.
          ENDIF.
          IF /adz/cl_bdr_customizing=>get_format_setting( ) = /adz/if_bdr_co=>gc_format_setting_01.
            IF screen-name = 'P_Z34Z11'.
              screen-input = '0'.
            ENDIF.
            IF screen-group1 = 'D11' OR screen-group1 = 'D34'.
              screen-active = '0'.
            ENDIF.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
      ENDIF.

      IF /adz/cl_bdr_utility=>is_own_intcode( /adz/if_bdr_co=>gc_intcode_01 ) = abap_false.
        IF p_z31 = abap_true.
          p_z31 = abap_false.
          p_z34z11 = abap_true.
        ENDIF.
        LOOP AT SCREEN.
          IF screen-name = 'P_Z31'.
            screen-input = '0'.
          ENDIF.
          IF screen-group1 = 'D31'.
            screen-active = '0'.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
      ENDIF.

      IF /adz/cl_bdr_utility=>is_own_intcode( /adz/if_bdr_co=>gc_intcode_01 ) = abap_false
          AND /adz/cl_bdr_utility=>is_own_intcode( /adz/if_bdr_co=>gc_intcode_02 ) = abap_false.
        LOOP AT SCREEN.
          IF screen-name = 'P_Z14'.
            screen-input = '0'.
          ENDIF.
          IF screen-group1 = 'D14'.
            screen-active = '0'.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
      ENDIF.

      IF /adz/cl_bdr_customizing=>get_format_setting( ) = /adz/if_bdr_co=>gc_format_setting_01.
        LOOP AT SCREEN.
          IF screen-name = 'P_Z34Z12' OR screen-name = 'P_Z34Z35'.
            screen-input = '0'.
          ENDIF.
          IF screen-group1 = 'D12' OR screen-group1 = 'D35'.
            screen-active = '0'.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
      ENDIF.
    CATCH /idxgc/cx_general.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDTRY.
*---- Beim Betätigen der Radiobuttons die entsprechenden Felder ausgrauen und Feldinhalte löschen -
  IF p_z14 = abap_true.
    CLEAR: s_exui30, s_exui30[], p_exdt30, p_sttl30, p_dvc30,s_exui31, s_exui31[], p_exdt31,
           p_sttl31, p_dvc31, s_lblnr, s_lblnr[], s_ablbel, s_ablbel[], s_idoc11, s_idoc11[],
           s_idoc12, s_idoc12[], s_idoc35, s_idoc35[], p_tqual, p_text.
    LOOP AT SCREEN.
      IF screen-group1 = 'D14'.
        screen-input = '1'.
      ELSEIF screen-group1 = 'D30' OR screen-group1 = 'D31' OR screen-group1 = 'D11' OR screen-group1 = 'D12'
          OR screen-group1 = 'D35' OR screen-group1 = 'D34'.
        screen-input = '0'.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF p_z30 = abap_true.
    CLEAR: s_exui14, s_exui14[], s_exui31, s_exui31[], p_exdt31, p_sttl31, p_dvc31,
           s_lblnr, s_lblnr[], s_ablbel, s_ablbel[], s_idoc11, s_idoc11[], s_idoc12, s_idoc12[],
           s_idoc35, s_idoc35[], p_tqual, p_text.
    LOOP AT SCREEN.
      IF screen-group1 = 'D30'.
        screen-input = '1'.
      ELSEIF screen-group1 = 'D14' OR screen-group1 = 'D31' OR screen-group1 = 'D11' OR screen-group1 = 'D12'
          OR screen-group1 = 'D35' OR screen-group1 = 'D34'.
        screen-input = '0'.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF p_z31 = abap_true.
    CLEAR: s_exui14, s_exui14[], s_exui30, s_exui30[], p_exdt30, p_sttl30, p_dvc30,
           s_lblnr, s_lblnr[], s_ablbel, s_ablbel[], s_idoc11, s_idoc11[], s_idoc12, s_idoc12[],
           s_idoc35, s_idoc35[], p_tqual, p_text.
    LOOP AT SCREEN.
      IF screen-group1 = 'D31'.
        screen-input = '1'.
      ELSEIF screen-group1 = 'D14' OR screen-group1 = 'D30' OR screen-group1 = 'D11' OR screen-group1 = 'D12'
          OR screen-group1 = 'D35' OR screen-group1 = 'D34'.
        screen-input = '0'.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF p_z34z11 = abap_true.
    CLEAR: s_exui14, s_exui14[], s_exui30, s_exui30[], p_exdt30, p_sttl30, p_dvc30,
           s_exui31, s_exui31[], p_exdt31, p_sttl31, p_dvc31,s_ablbel, s_ablbel[],
           s_idoc12, s_idoc12[], s_idoc35, s_idoc35[].
    LOOP AT SCREEN.
      IF screen-group1 = 'D11' OR screen-group1 = 'D34'.
        screen-input = '1'.
      ELSEIF screen-group1 = 'D14' OR screen-group1 = 'D30' OR screen-group1 = 'D31'
          OR screen-group1 = 'D12' OR screen-group1 = 'D35'.
        screen-input = '0'.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF p_z34z12 = abap_true.
    CLEAR: s_exui14, s_exui14[], s_exui30, s_exui30[], p_exdt30, p_sttl30, p_dvc30,
           s_exui31, s_exui31[], p_exdt31, p_sttl31, p_dvc31, s_lblnr, s_lblnr[], s_ablbel, s_ablbel[],
           s_idoc11, s_idoc11[], s_idoc35, s_idoc35[].
    LOOP AT SCREEN.
      IF screen-group1 = 'D12' OR screen-group1 = 'D34'.
        screen-input = '1'.
      ELSEIF screen-group1 = 'D14' OR screen-group1 = 'D30' OR screen-group1 = 'D31'
          OR screen-group1 = 'D11' OR screen-group1 = 'D35'.
        screen-input = '0'.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF p_z34z35 = abap_true.
    CLEAR: s_exui14, s_exui14[], s_exui30, s_exui30[], p_exdt30, p_sttl30, p_dvc30,
           s_exui31, s_exui31[], p_exdt31, p_sttl31, p_dvc31, s_lblnr, s_lblnr[],
           s_ablbel, s_ablbel[], s_idoc11, s_idoc11[], s_idoc12, s_idoc12[].
    LOOP AT SCREEN.
      IF screen-group1 = 'D35' OR screen-group1 = 'D34'.
        screen-input = '1'.
      ELSEIF screen-group1 = 'D14' OR screen-group1 = 'D30' OR screen-group1 = 'D31'
          OR screen-group1 = 'D11' OR screen-group1 = 'D12'.
        screen-input = '0'.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.


****** Programmlogik zum Ermitteln der Daten für die Tabellenanzeige ******************************
START-OF-SELECTION.

*----- Für alle Selektionen identische Parameter --------------------------------------------------
  ls_bdr_orders_hdr-proc_type = /adz/if_bdr_co=>gc_proc_type_22.
  ls_bdr_orders_hdr-proc_view = /adz/if_bdr_co=>gc_proc_view_04.

*----- Nur für Z14 Stammdaten der Markt- oder Messlokation ----------------------------------------
  IF p_z14 = abap_true.
    ls_bdr_orders_hdr-proc_id      = /ADZ/IF_BDR_CO=>gc_proc_id_8020.
    ls_bdr_orders_hdr-docname_code = /adz/if_bdr_co=>gc_msg_category_z14.

    IF s_exui14 IS INITIAL.
      APPEND INITIAL LINE TO lt_bdr_create_req ASSIGNING <ls_bdr_create_req>.
      <ls_bdr_create_req>-execution_date = sy-datum.
    ELSE.
      SELECT * FROM euitrans WHERE ext_ui IN @s_exui14 INTO TABLE @lt_euitrans.
      LOOP AT lt_euitrans ASSIGNING <ls_euitrans>.
        APPEND INITIAL LINE TO lt_bdr_create_req  ASSIGNING <ls_bdr_create_req>.
        <ls_bdr_create_req>-ext_ui  = <ls_euitrans>-ext_ui.
        <ls_bdr_create_req>-int_ui  = <ls_euitrans>-int_ui.

        /adz/cl_bdr_utility=>get_servprov_from_pod( EXPORTING iv_int_ui         = <ls_euitrans>-int_ui
                                                              iv_keydate        = sy-datum
                                                              iv_assoc_intcode  = /adz/if_bdr_co=>gc_intcode_01 " NB
                                                              iv_own_intcode    = /adz/cl_bdr_customizing=>get_own_intcode_1( )
                                                    IMPORTING ev_own_servprov   = <ls_bdr_create_req>-sender
                                                              ev_assoc_servprov = <ls_bdr_create_req>-receiver ).

        TRY.
            IF /adz/cl_bdr_utility=>get_eanl( iv_int_ui = <ls_euitrans>-int_ui )-bezug = abap_true.
              <ls_bdr_create_req>-supply_direct   = /idxgc/if_constants_add=>gc_supply_direct_z06.
            ELSE.
              <ls_bdr_create_req>-supply_direct   = /idxgc/if_constants_add=>gc_supply_direct_z07.
            ENDIF.
          CATCH /idxgc/cx_general.
            "Weiter mit leerem Feld
        ENDTRY.
      ENDLOOP.
    ENDIF.

*----- Nur für Z30 - Änderung des Bilanzierungsverfahrens -----------------------------------------
  ELSEIF p_z30 = abap_true.
    ls_bdr_orders_hdr-proc_id      = /adz/if_bdr_co=>gc_proc_id_adz8020.
    ls_bdr_orders_hdr-docname_code = /adz/if_bdr_co=>gc_msg_category_z30.

    IF p_exdt30 IS NOT INITIAL.
      lv_keydate = p_exdt30.
    ELSE.
      lv_keydate = sy-datum.
    ENDIF.

    IF s_exui30 IS INITIAL.
      APPEND INITIAL LINE TO lt_bdr_create_req ASSIGNING <ls_bdr_create_req>.
      <ls_bdr_create_req>-execution_date = lv_keydate.
      <ls_bdr_create_req>-settl_proc = p_sttl30.
      <ls_bdr_create_req>-device_conf = p_dvc30.
    ELSE.
      SELECT * FROM euitrans WHERE ext_ui IN @s_exui30 INTO TABLE @lt_euitrans.
      LOOP AT lt_euitrans ASSIGNING <ls_euitrans>.
        "Z30 wird nur mit MaLo verschickt, daher prüfen und ggf. MaLo holen
        TRY.
            GET BADI lr_badi_data_access.
            CALL BADI lr_badi_data_access->is_pod_melo
              EXPORTING
                iv_ext_ui      = <ls_euitrans>-ext_ui
                iv_key_date    = lv_keydate
              RECEIVING
                rv_pod_is_melo = lv_pod_is_melo.
            IF lv_pod_is_melo = abap_true.
              CALL BADI lr_badi_data_access->get_pod_malo_melo
                EXPORTING
                  iv_ext_ui             = <ls_euitrans>-ext_ui
                  iv_key_date           = lv_keydate
                IMPORTING
                  et_euitrans_malo_melo = lt_euitrans_malo_melo.
              IF lines( lt_euitrans_malo_melo ) = 1.
                <ls_euitrans>-ext_ui = lt_euitrans_malo_melo[ 1 ]-ext_ui.
                <ls_euitrans>-int_ui = lt_euitrans_malo_melo[ 1 ]-int_ui_malo.
              ELSEIF lines( lt_euitrans_malo_melo ) = 0.
                MESSAGE i021(/adz/bdr_messages).
              ELSE.
                MESSAGE i022(/adz/bdr_messages).
              ENDIF.
            ENDIF.
          CATCH cx_badi_multiply_implemented cx_badi_not_implemented /idxgc/cx_general.
            MESSAGE e020(/adz/bdr_messages).
        ENDTRY.

        APPEND INITIAL LINE TO lt_bdr_create_req  ASSIGNING <ls_bdr_create_req>.
        <ls_bdr_create_req>-ext_ui  = <ls_euitrans>-ext_ui.
        <ls_bdr_create_req>-int_ui  = <ls_euitrans>-int_ui.
        IF p_exdt30 IS NOT INITIAL.
          <ls_bdr_create_req>-execution_date = lv_keydate.
        ENDIF.
        IF p_sttl30 IS NOT INITIAL.
          <ls_bdr_create_req>-settl_proc = p_sttl30.
        ENDIF.
        IF p_dvc30 IS NOT INITIAL.
          <ls_bdr_create_req>-device_conf = p_dvc30.
        ENDIF.

        /adz/cl_bdr_utility=>get_servprov_from_pod( EXPORTING iv_int_ui         = <ls_euitrans>-int_ui
                                                              iv_keydate        = lv_keydate
                                                              iv_assoc_intcode  = /adz/if_bdr_co=>gc_intcode_01 " NB
                                                              iv_own_intcode    = /adz/if_bdr_co=>gc_intcode_02 " LF
                                                    IMPORTING ev_own_servprov   = <ls_bdr_create_req>-sender
                                                              ev_assoc_servprov = <ls_bdr_create_req>-receiver ).
      ENDLOOP.
    ENDIF.

*----- Nur für Z31 - Änderung der Gerätekonfiguration ---------------------------------------------
  ELSEIF p_z31 = abap_true.
    ls_bdr_orders_hdr-proc_id      = /adz/if_bdr_co=>gc_proc_id_adz8022.
    ls_bdr_orders_hdr-docname_code = /adz/if_bdr_co=>gc_msg_category_z31.

    IF p_exdt31 IS NOT INITIAL.
      lv_keydate = p_exdt31.
    ELSE.
      lv_keydate = sy-datum.
    ENDIF.

    IF s_exui31 IS INITIAL.
      APPEND INITIAL LINE TO lt_bdr_create_req ASSIGNING <ls_bdr_create_req>.
      <ls_bdr_create_req>-execution_date = lv_keydate.
    ELSE.
      SELECT * FROM euitrans WHERE ext_ui IN @s_exui31 INTO TABLE @lt_euitrans.
      LOOP AT lt_euitrans ASSIGNING <ls_euitrans>.
        "Z31 kann mit MaLo und Melo verschickt werden, daher beide erstmal in Tabelle schreiben.
        TRY.
            GET BADI lr_badi_data_access.
            CALL BADI lr_badi_data_access->get_pod_malo_melo
              EXPORTING
                iv_ext_ui             = <ls_euitrans>-ext_ui
                iv_key_date           = lv_keydate
              IMPORTING
                et_euitrans_malo_melo = lt_euitrans_malo_melo.
            LOOP AT lt_euitrans_malo_melo ASSIGNING FIELD-SYMBOL(<ls_euitrans_malo_melo>).
              lt_bdr_devconf = /adz/cl_bdr_customizing=>get_devconf( iv_settl_proc  = p_sttl31
                                                                     iv_device_conf = p_dvc31
                                                                     iv_euistrutyp  = /adz/if_bdr_co=>gc_euistrutyp_ma
                                                                     iv_keydate     = lv_keydate ).
              LOOP AT lt_bdr_devconf ASSIGNING <ls_bdr_devconf>.
                APPEND INITIAL LINE TO lt_bdr_create_req  ASSIGNING <ls_bdr_create_req>.
                <ls_bdr_create_req> = CORRESPONDING #( <ls_bdr_devconf> ).
                <ls_bdr_create_req>-int_ui_malo = <ls_euitrans_malo_melo>-int_ui_malo. "Nur um MeLo / MaLo Pärchen zusammenzuhalten in der Anzeige
                <ls_bdr_create_req>-ext_ui      = <ls_euitrans_malo_melo>-ext_ui.
                <ls_bdr_create_req>-int_ui      = <ls_euitrans_malo_melo>-int_ui_malo.
                <ls_bdr_create_req>-execution_date = lv_keydate.
                /adz/cl_bdr_utility=>get_servprov_from_pod( EXPORTING iv_int_ui         = <ls_euitrans_malo_melo>-int_ui_malo
                                                                      iv_keydate        = lv_keydate
                                                                      iv_assoc_intcode  = /adz/if_bdr_co=>gc_intcode_m1 "MSB
                                                                      iv_own_intcode    = /adz/if_bdr_co=>gc_intcode_01 "NB
                                                            IMPORTING ev_own_servprov   = <ls_bdr_create_req>-sender
                                                                      ev_assoc_servprov = <ls_bdr_create_req>-receiver ).
              ENDLOOP.
              IF lt_bdr_devconf IS INITIAL.
                APPEND INITIAL LINE TO lt_bdr_create_req  ASSIGNING <ls_bdr_create_req>.
                <ls_bdr_create_req>-int_ui_malo = <ls_euitrans_malo_melo>-int_ui_malo. "Nur um MeLo / MaLo Pärchen zusammenzuhalten in der Anzeige
                <ls_bdr_create_req>-ext_ui      = <ls_euitrans_malo_melo>-ext_ui.
                <ls_bdr_create_req>-int_ui      = <ls_euitrans_malo_melo>-int_ui_malo.
                <ls_bdr_create_req>-execution_date = lv_keydate.
                /adz/cl_bdr_utility=>get_servprov_from_pod( EXPORTING iv_int_ui         = <ls_euitrans_malo_melo>-int_ui_malo
                                                                      iv_keydate        = lv_keydate
                                                                      iv_assoc_intcode  = /adz/if_bdr_co=>gc_intcode_m1 "MSB
                                                                      iv_own_intcode    = /adz/if_bdr_co=>gc_intcode_01 "NB
                                                            IMPORTING ev_own_servprov   = <ls_bdr_create_req>-sender
                                                                      ev_assoc_servprov = <ls_bdr_create_req>-receiver ).
              ENDIF.

              LOOP AT <ls_euitrans_malo_melo>-melo ASSIGNING FIELD-SYMBOL(<ls_melo>).
                lt_bdr_devconf = /adz/cl_bdr_customizing=>get_devconf( iv_settl_proc  = p_sttl31
                                                                       iv_device_conf = p_dvc31
                                                                       iv_euistrutyp  = /adz/if_bdr_co=>gc_euistrutyp_me
                                                                       iv_keydate     = lv_keydate ).
                LOOP AT lt_bdr_devconf ASSIGNING <ls_bdr_devconf>.
                  APPEND INITIAL LINE TO lt_bdr_create_req ASSIGNING <ls_bdr_create_req>.
                  <ls_bdr_create_req> = CORRESPONDING #( <ls_bdr_devconf> ).
                  <ls_bdr_create_req>-int_ui_malo = <ls_euitrans_malo_melo>-int_ui_malo. "Nur um MeLo / MaLo Pärchen zusammenzuhalten in der Anzeige
                  <ls_bdr_create_req>-ext_ui  = <ls_melo>-ext_ui.
                  <ls_bdr_create_req>-int_ui  = <ls_melo>-int_ui_melo.
                  <ls_bdr_create_req>-execution_date = lv_keydate.
                  /adz/cl_bdr_utility=>get_servprov_from_pod( EXPORTING iv_int_ui         = <ls_melo>-int_ui_melo
                                                                        iv_keydate        = lv_keydate
                                                                        iv_assoc_intcode  = /adz/if_bdr_co=>gc_intcode_m1 "MSB
                                                                        iv_own_intcode    = /adz/if_bdr_co=>gc_intcode_01 "NB
                                                              IMPORTING ev_own_servprov   = <ls_bdr_create_req>-sender
                                                                        ev_assoc_servprov = <ls_bdr_create_req>-receiver ).
                ENDLOOP.
                IF lt_bdr_devconf IS INITIAL.
                  APPEND INITIAL LINE TO lt_bdr_create_req ASSIGNING <ls_bdr_create_req>.
                  <ls_bdr_create_req>-int_ui_malo = <ls_euitrans_malo_melo>-int_ui_malo. "Nur um MeLo / MaLo Pärchen zusammenzuhalten in der Anzeige
                  <ls_bdr_create_req>-ext_ui  = <ls_melo>-ext_ui.
                  <ls_bdr_create_req>-int_ui  = <ls_melo>-int_ui_melo.
                  <ls_bdr_create_req>-execution_date = lv_keydate.
                  /adz/cl_bdr_utility=>get_servprov_from_pod( EXPORTING iv_int_ui         = <ls_melo>-int_ui_melo
                                                                        iv_keydate        = lv_keydate
                                                                        iv_assoc_intcode  = /adz/if_bdr_co=>gc_intcode_m1 "MSB
                                                                        iv_own_intcode    = /adz/if_bdr_co=>gc_intcode_01 "NB
                                                              IMPORTING ev_own_servprov   = <ls_bdr_create_req>-sender
                                                                        ev_assoc_servprov = <ls_bdr_create_req>-receiver ).
                ENDIF.
              ENDLOOP.
            ENDLOOP.
          CATCH cx_badi_multiply_implemented cx_badi_not_implemented /idxgc/cx_general.
            MESSAGE e020(/adz/bdr_messages).
        ENDTRY.

      ENDLOOP.

      IF lt_bdr_create_req IS INITIAL.
        APPEND INITIAL LINE TO lt_bdr_create_req ASSIGNING <ls_bdr_create_req>.
        <ls_bdr_create_req>-execution_date = lv_keydate.
      ENDIF.

      SORT lt_bdr_create_req.
      DELETE ADJACENT DUPLICATES FROM lt_bdr_create_req.

    ENDIF.

*----- Nur für Z34 - Reklamation von Werten -------------------------------------------------------
  ELSE.
    ls_bdr_orders_hdr-proc_id      =  /IDXGL/IF_CONSTANTS=>gc_proc_id_de_mrr_sender.
    ls_bdr_orders_hdr-docname_code = /adz/if_bdr_co=>gc_msg_category_z34.

    IF p_z34z11 = abap_true.
      ls_bdr_orders_hdr-serv_measval = /idxgc/if_constants_ide=>gc_imd_chardesc_code_z11.

      IF s_lblnr IS NOT INITIAL.
        SELECT * FROM eedmimportlog_db WHERE logbelnr IN @s_lblnr INTO TABLE @lt_eedmimportlog_db.
        SORT lt_eedmimportlog_db BY int_ui docnum.
        DELETE ADJACENT DUPLICATES FROM lt_eedmimportlog_db COMPARING int_ui docnum.
        LOOP AT lt_eedmimportlog_db ASSIGNING <ls_eedmimportlog_db>.
          APPEND <ls_eedmimportlog_db>-docnum TO lt_docnum.
        ENDLOOP.
      ENDIF.

      IF s_idoc11 IS NOT INITIAL.
        SELECT * FROM edidc WHERE docnum IN @s_idoc11 INTO TABLE @lt_edidc.
        LOOP AT lt_edidc ASSIGNING <ls_edidc>.
          APPEND <ls_edidc>-docnum TO lt_docnum.
        ENDLOOP.
      ENDIF.

    ELSEIF p_z34z12 = abap_true.
      ls_bdr_orders_hdr-serv_measval = /idxgc/if_constants_ide=>gc_imd_chardesc_code_z12.

      IF s_ablbel IS NOT INITIAL.
        SELECT *
          FROM /idxgc/msconsref
          WHERE objectkey IN @s_ablbel
            AND objecttype = @/adz/if_bdr_co=>gc_objtype_mtrreaddoc
            AND direction = @/idxgc/if_constants_add=>gc_idoc_direction_inbound
            AND edi_docnum = @( VALUE #( ) )
          INTO TABLE @lt_msconsref.

        SELECT * FROM eabl WHERE ablbelnr IN @s_ablbel INTO TABLE @lt_eabl.

        LOOP AT lt_eabl ASSIGNING <ls_eabl>.
          IF line_exists( lt_msconsref[ objectkey = <ls_eabl>-ablbelnr ] ).
            APPEND lt_msconsref[ objectkey = <ls_eabl>-ablbelnr ]-edi_docnum TO lt_docnum.
            DELETE lt_eabl.
          ENDIF.
        ENDLOOP.
      ENDIF.

      IF s_idoc12 IS NOT INITIAL.
        SELECT * FROM edidc WHERE docnum IN @s_idoc12 INTO TABLE @lt_edidc.
        LOOP AT lt_edidc ASSIGNING <ls_edidc>.
          APPEND <ls_edidc>-docnum TO lt_docnum.
        ENDLOOP.
      ENDIF.

    ELSEIF p_z34z35 = abap_true.
      ls_bdr_orders_hdr-serv_measval = /adz/if_bdr_co=>gc_imd_chardesc_code_z35.

      IF s_idoc35 IS NOT INITIAL.
        SELECT * FROM edidc WHERE docnum IN @s_idoc35 INTO TABLE @lt_edidc.
        LOOP AT lt_edidc ASSIGNING <ls_edidc>.
          APPEND <ls_edidc>-docnum TO lt_docnum.
        ENDLOOP.
      ENDIF.
    ENDIF.

    LOOP AT lt_docnum ASSIGNING <lv_docnum>.
      CALL FUNCTION 'IDOC_READ_COMPLETELY'
        EXPORTING
          document_number         = <lv_docnum>
        IMPORTING
          idoc_control            = ls_edex_idocdata-control
        TABLES
          int_edidd               = ls_edex_idocdata-data
        EXCEPTIONS
          document_not_exist      = 1
          document_number_invalid = 2
          OTHERS                  = 3.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      lr_parsing = /idxgc/cl_pars_idocmap=>get_inst( is_idoc_data = ls_edex_idocdata ).

      CALL METHOD lr_parsing->('PARSE_IDOC')
        EXPORTING
          is_edex_idocdata          = ls_edex_idocdata
        RECEIVING
          rt_cl_process_data_extern = lt_cl_process_data.

      LOOP AT lt_cl_process_data ASSIGNING FIELD-SYMBOL(<lr_process_data>).
        <lr_process_data>->get_process_data( IMPORTING es_process_data = ls_proc_data ).
        READ TABLE ls_proc_data-steps ASSIGNING FIELD-SYMBOL(<ls_proc_step_data>) INDEX 1.
        IF <ls_proc_step_data> IS ASSIGNED.
          APPEND INITIAL LINE TO lt_bdr_create_req  ASSIGNING <ls_bdr_create_req>.

          <ls_bdr_create_req>-serv_measval    = ls_bdr_orders_hdr-serv_measval.
          <ls_bdr_create_req>-text_subj_qual  = p_tqual.
          <ls_bdr_create_req>-free_text_value = p_text.

          IF lines( <ls_proc_step_data>-pod ) > 0.
            <ls_bdr_create_req>-ext_ui          = <ls_proc_step_data>-pod[ 1 ]-ext_ui.
          ENDIF.
          IF lines( <ls_proc_step_data>-reg_code_data ) > 0. "für 01.12.2019
            <ls_bdr_create_req>-reg_code = <ls_proc_step_data>-reg_code_data[ 1 ]-reg_code.
          ENDIF.
          <ls_bdr_create_req>-sender          = <ls_proc_step_data>-own_servprov.
          <ls_bdr_create_req>-receiver        = <ls_proc_step_data>-assoc_servprov.
          <ls_bdr_create_req>-ref_no          = <ls_proc_step_data>-document_ident.
          <ls_bdr_create_req>-ref_msg_date    = <ls_proc_step_data>-msg_date.
          <ls_bdr_create_req>-ref_msg_time    = <ls_proc_step_data>-msg_time.

          IF line_exists( <ls_proc_step_data>-msc_item_quant[ 1 ] ).
            IF <ls_proc_step_data>-msc_item_quant[ 1 ]-datefrom IS NOT INITIAL.
              <ls_bdr_create_req>-start_read_date = <ls_proc_step_data>-msc_item_quant[ 1 ]-datefrom.
              <ls_bdr_create_req>-start_read_time = <ls_proc_step_data>-msc_item_quant[ 1 ]-timefrom.
              <ls_bdr_create_req>-start_read_offs = <ls_proc_step_data>-msc_item_quant[ 1 ]-timefrom_offs.
              <ls_bdr_create_req>-end_read_date   = <ls_proc_step_data>-msc_item_quant[ 1 ]-dateto.
              <ls_bdr_create_req>-end_read_time   = <ls_proc_step_data>-msc_item_quant[ 1 ]-timeto.
              <ls_bdr_create_req>-end_read_offs   = <ls_proc_step_data>-msc_item_quant[ 1 ]-timeto_offs.
            ELSE.
              <ls_bdr_create_req>-start_read_date = <ls_proc_step_data>-msc_item_quant[ 1 ]-procdate.
              <ls_bdr_create_req>-start_read_time = <ls_proc_step_data>-msc_item_quant[ 1 ]-proctime.
              <ls_bdr_create_req>-start_read_offs = <ls_proc_step_data>-msc_item_quant[ 1 ]-proctime_offs.
              <ls_bdr_create_req>-end_read_date   = <ls_proc_step_data>-msc_item_quant[ 1 ]-procdate.
              <ls_bdr_create_req>-end_read_time   = '2359'. "Default: Bis Tagesende
              <ls_bdr_create_req>-end_read_offs   = <ls_proc_step_data>-msc_item_quant[ 1 ]-proctime_offs.
            ENDIF.
            IF <ls_bdr_create_req>-start_read_offs IS INITIAL.
              <ls_bdr_create_req>-start_read_offs = /adz/cl_bdr_utility=>get_timezone( ).
            ENDIF.
            IF <ls_bdr_create_req>-end_read_offs IS INITIAL.
              <ls_bdr_create_req>-end_read_offs   = /adz/cl_bdr_utility=>get_timezone( ).
            ENDIF.
          ENDIF.

          TRY.
              IF /adz/cl_bdr_utility=>get_eanl( iv_ext_ui = <ls_bdr_create_req>-ext_ui )-bezug = abap_true.
                <ls_bdr_create_req>-supply_direct   = /idxgc/if_constants_add=>gc_supply_direct_z06.
              ELSE.
                <ls_bdr_create_req>-supply_direct   = /idxgc/if_constants_add=>gc_supply_direct_z07.
              ENDIF.
            CATCH /idxgc/cx_general.
              "Weiter mit leerem Feld
          ENDTRY.
        ENDIF.

      ENDLOOP.
    ENDLOOP.

    LOOP AT lt_eabl ASSIGNING <ls_eabl>.
      SELECT euiinstln~int_ui, euitrans~ext_ui, eabl~adatsoll, eanl~bezug
        FROM eablg INNER JOIN eabl      ON eablg~ablbelnr   = eabl~ablbelnr
                   INNER JOIN euiinstln ON eablg~anlage     = euiinstln~anlage
                   INNER JOIN euitrans  ON euiinstln~int_ui = euitrans~int_ui
                   INNER JOIN eanl      ON eablg~anlage     = eanl~anlage
        WHERE eablg~ablbelnr     =  @<ls_eabl>-ablbelnr
          AND euiinstln~dateto   >= eabl~adatsoll
          AND euiinstln~datefrom <= eabl~adatsoll
        INTO TABLE @lt_inst_for_abl.

      GET BADI lr_badi_data_access.
      LOOP AT lt_inst_for_abl ASSIGNING <ls_inst_for_abl>.
        TRY.
            CALL BADI lr_badi_data_access->is_pod_melo
              EXPORTING
                iv_ext_ui      = <ls_inst_for_abl>-ext_ui
                iv_key_date    = <ls_inst_for_abl>-adatsoll
              RECEIVING
                rv_pod_is_melo = <ls_inst_for_abl>-is_melo.
          CATCH cx_badi_multiply_implemented cx_badi_not_implemented /idxgc/cx_general.
            MESSAGE e020(/adz/bdr_messages).
        ENDTRY.
      ENDLOOP.

      IF line_exists( lt_inst_for_abl[ is_melo = abap_true ] ).
        DELETE lt_inst_for_abl WHERE is_melo = abap_false.
      ENDIF.

      LOOP AT lt_inst_for_abl ASSIGNING <ls_inst_for_abl>.
        APPEND INITIAL LINE TO lt_bdr_create_req  ASSIGNING <ls_bdr_create_req>.

        <ls_bdr_create_req>-serv_measval    = ls_bdr_orders_hdr-serv_measval.
        <ls_bdr_create_req>-text_subj_qual  = /adz/if_bdr_co=>gc_text_subj_qual_z06.
        <ls_bdr_create_req>-free_text_value = p_text.
        <ls_bdr_create_req>-ext_ui          = <ls_inst_for_abl>-ext_ui.
        <ls_bdr_create_req>-int_ui          = <ls_inst_for_abl>-int_ui.

        <ls_bdr_create_req>-start_read_date = <ls_eabl>-adatsoll.
        <ls_bdr_create_req>-start_read_time = '000000'.
        <ls_bdr_create_req>-start_read_offs = /adz/cl_bdr_utility=>get_timezone( ).
        <ls_bdr_create_req>-end_read_date   = <ls_eabl>-adatsoll.
        <ls_bdr_create_req>-end_read_time   = '235959'.
        <ls_bdr_create_req>-end_read_offs   = /adz/cl_bdr_utility=>get_timezone( ).

        IF <ls_inst_for_abl>-bezug = abap_true.
          <ls_bdr_create_req>-supply_direct   = /idxgc/if_constants_add=>gc_supply_direct_z06.
        ELSEIF <ls_inst_for_abl>-bezug = abap_false.
          <ls_bdr_create_req>-supply_direct   = /idxgc/if_constants_add=>gc_supply_direct_z07.
        ENDIF.

        /adz/cl_bdr_utility=>get_servprov_from_pod( EXPORTING iv_int_ui         = <ls_inst_for_abl>-int_ui
                                                              iv_assoc_intcode  = /adz/if_bdr_co=>gc_intcode_m1 " MSB
                                                              iv_own_intcode    = /adz/cl_bdr_customizing=>get_own_intcode_1( )
                                                    IMPORTING ev_own_servprov   = <ls_bdr_create_req>-sender
                                                              ev_assoc_servprov = <ls_bdr_create_req>-receiver ).


      ENDLOOP.
    ENDLOOP.

    IF lines( lt_eabl ) > 0.
      SORT lt_bdr_create_req BY ext_ui.
      DELETE ADJACENT DUPLICATES FROM lt_bdr_create_req COMPARING ext_ui.
    ENDIF.

    IF lt_bdr_create_req IS INITIAL AND ( p_tqual IS NOT INITIAL OR p_text IS NOT INITIAL ).
      APPEND INITIAL LINE TO lt_bdr_create_req ASSIGNING <ls_bdr_create_req>.
      <ls_bdr_create_req>-text_subj_qual  = p_tqual.
      <ls_bdr_create_req>-free_text_value = p_text.
    ENDIF.

  ENDIF.

*---- Dialog zum Bearbeiten von BDR Requests öffnen -----------------------------------------------
  TRY.
      CALL FUNCTION '/ADZ/BDR_REQUEST_DIALOG'
        EXPORTING
          is_bdr_orders_hdr = ls_bdr_orders_hdr
          it_bdr_create_req = lt_bdr_create_req.
    CATCH /idxgc/cx_process_error.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDTRY.
