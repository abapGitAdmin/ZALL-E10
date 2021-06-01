class /ADZ/CL_BDR_DP_ORDERS_002 definition
  public
  inheriting from /IDXGL/CL_DP_ORDERS_002
  final
  create public .

public section.

  methods REFERENCE_TO_PREVIOUS_MESSAGE
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods MEASURED_VALUE_TYPE_OBIS
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods OFF_PEAK_ENABLED
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods REG_CODE_MR_RELEVANCE_AND_USE
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods APPLICATION_INTERRUPTION
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CONSUMPTION_TYPE
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods HEAT_USE
    raising
      /IDXGC/CX_PROCESS_ERROR .

  methods COMPLAINT_INFORMATION
    redefinition .
  methods IMS_DEVICE_CONFIG
    redefinition .
  methods MESSAGE_CATEGORY
    redefinition .
  methods PROCESSING_END_DATE_TIME
    redefinition .
  methods PROCESSING_START_DATE_TIME
    redefinition .
  methods PRODUCT
    redefinition .
  methods SETTLEMENT_PROCEDURE
    redefinition .
  methods OBIS_CODE
    redefinition .
protected section.
private section.

  class-data GX_PREVIOUS type ref to CX_ROOT .
ENDCLASS.



CLASS /ADZ/CL_BDR_DP_ORDERS_002 IMPLEMENTATION.


  METHOD application_interruption.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 01.11.2019
*
* Beschreibung: Unterbrechbarkeit der Verbrauchseinrichtung für Prozess Ändereung der Gerätekonfig.
*   WICHTIG: Damit die Daten im Mapping übernommen werden muss der Wert mit der richtigen ITEM_ID,
*   aber ohne REG_CODE in die Zeile geschrieben werden.
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    FIELD-SYMBOLS: <ls_reg_code_data> TYPE /idxgc/s_reg_code_details.

    CASE siv_data_processing_mode.
      WHEN /idxgc/if_constants_add=>gc_data_from_source
        OR /idxgc/if_constants_add=>gc_default_processing.

        LOOP AT sis_process_data_src-reg_code_data ASSIGNING FIELD-SYMBOL(<ls_reg_src>) WHERE appl_interrupt IS NOT INITIAL.
          IF line_exists( sis_process_step_data-reg_code_data[ item_id = <ls_reg_src>-item_id reg_code = '' ] ).
            sis_process_step_data-reg_code_data[ item_id = <ls_reg_src>-item_id reg_code = '' ]-appl_interrupt = <ls_reg_src>-appl_interrupt.
          ELSE.
            sis_process_step_data-reg_code_data = VALUE #( BASE sis_process_step_data-reg_code_data ( item_id        = <ls_reg_src>-item_id
                                                                                                      appl_interrupt = <ls_reg_src>-appl_interrupt ) ).
          endif.
        ENDLOOP.

      WHEN /idxgc/if_constants_add=>gc_data_from_add_source.

        LOOP AT sis_process_data_src_add-reg_code_data ASSIGNING FIELD-SYMBOL(<ls_reg_src_add>).
          IF line_exists( sis_process_step_data-reg_code_data[ item_id = <ls_reg_src_add>-item_id reg_code = '' ] ).
            sis_process_step_data-reg_code_data[ item_id = <ls_reg_src_add>-item_id reg_code = '' ]-appl_interrupt = <ls_reg_src_add>-appl_interrupt.
          ELSE.
            sis_process_step_data-reg_code_data = VALUE #( BASE sis_process_step_data-reg_code_data ( item_id        = <ls_reg_src_add>-item_id
                                                                                                      appl_interrupt = <ls_reg_src_add>-appl_interrupt ) ).
          endif.
        ENDLOOP.

    ENDCASE.

***** Prüfen ob alle relevanten Daten gefüllt sind ************************************************
    IF strlen( sis_process_step_data-ext_ui ) = 11.
      LOOP AT sis_process_step_data-reg_code_data TRANSPORTING NO FIELDS WHERE appl_interrupt IS INITIAL AND reg_code IS INITIAL.
        MESSAGE e038(/idxgc/ide_add) WITH TEXT-002 INTO siv_mtext.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


METHOD complaint_information.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 17.04.2019
*
* Beschreibung: Grund für Reklamation ORDERS_SG29_FTX+Z04/Z05
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXXXX-X   XX.XX.XXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************

  super->complaint_information( ).

  CASE siv_data_processing_mode.
    WHEN /idxgc/if_constants_add=>gc_default_processing
      OR /idxgc/if_constants_add=>gc_data_from_source.

      CHECK sis_process_step_data-docname_code = /adz/if_bdr_co=>gc_msg_category_z34.

      LOOP AT sis_process_data_src-msgcomments ASSIGNING FIELD-SYMBOL(<ls_msgcomment>)
        WHERE text_subj_qual = /idxgl/if_constants_ide=>gc_ftx_qual_z04
           OR text_subj_qual = /idxgl/if_constants_ide=>gc_ftx_qual_z05
           OR text_subj_qual = /adz/if_bdr_co=>gc_ftx_qual_z06.
        APPEND <ls_msgcomment> TO sis_process_step_data-msgcomments.
      ENDLOOP.

    WHEN OTHERS.

  ENDCASE.

  IF siv_mandatory_data = abap_true AND sis_process_step_data-msgcomments IS INITIAL.
    MESSAGE e038(/idxgc/ide_add) WITH TEXT-001 INTO siv_mtext.
    /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
  ENDIF.
ENDMETHOD.


  METHOD consumption_type.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 01.11.2019
*
* Beschreibung: Verbrauchsart für Prozess Ändereung der Gerätekonfiguration
*   WICHTIG: Damit die Daten im Mapping übernommen werden muss der Wert mit der richtigen ITEM_ID,
*   aber ohne REG_CODE in die Zeile geschrieben werden.
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    FIELD-SYMBOLS: <ls_reg_code_data> TYPE /idxgc/s_reg_code_details.

    CASE siv_data_processing_mode.
      WHEN /idxgc/if_constants_add=>gc_data_from_source
        OR /idxgc/if_constants_add=>gc_default_processing.

        LOOP AT sis_process_data_src-reg_code_data ASSIGNING FIELD-SYMBOL(<ls_reg_src>) WHERE cons_type IS NOT INITIAL.
          IF line_exists( sis_process_step_data-reg_code_data[ item_id = <ls_reg_src>-item_id reg_code = '' ] ).
            sis_process_step_data-reg_code_data[ item_id = <ls_reg_src>-item_id reg_code = '' ]-cons_type = <ls_reg_src>-cons_type.
          ELSE.
            sis_process_step_data-reg_code_data = VALUE #( BASE sis_process_step_data-reg_code_data ( item_id   = <ls_reg_src>-item_id
                                                                                                      cons_type = <ls_reg_src>-cons_type ) ).
          ENDIF.
        ENDLOOP.

      WHEN /idxgc/if_constants_add=>gc_data_from_add_source.

        LOOP AT sis_process_data_src_add-reg_code_data ASSIGNING FIELD-SYMBOL(<ls_reg_src_add>).
          IF line_exists( sis_process_step_data-reg_code_data[ item_id = <ls_reg_src_add>-item_id reg_code = '' ] ).
            sis_process_step_data-reg_code_data[ item_id = <ls_reg_src_add>-item_id reg_code = '' ]-cons_type = <ls_reg_src_add>-cons_type.
          ELSE.
            sis_process_step_data-reg_code_data = VALUE #( BASE sis_process_step_data-reg_code_data ( item_id   = <ls_reg_src_add>-item_id
                                                                                                      cons_type = <ls_reg_src_add>-cons_type ) ).
          ENDIF.
        ENDLOOP.

    ENDCASE.

***** Prüfen ob alle relevanten Daten gefüllt sind ************************************************
    IF strlen( sis_process_step_data-ext_ui ) = 11.
      LOOP AT sis_process_step_data-reg_code_data TRANSPORTING NO FIELDS WHERE cons_type IS INITIAL AND reg_code IS INITIAL.
        MESSAGE e038(/idxgc/ide_add) WITH TEXT-003 INTO siv_mtext.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD heat_use.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 01.11.2019
*
* Beschreibung: Wärmenutzung für Prozess Ändereung der Gerätekonfig.
*   WICHTIG: Damit die Daten im Mapping übernommen werden muss der Wert mit der richtigen ITEM_ID,
*   aber ohne REG_CODE in die Zeile geschrieben werden.
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    FIELD-SYMBOLS: <ls_reg_code_data> TYPE /idxgc/s_reg_code_details.

    CASE siv_data_processing_mode.
      WHEN /idxgc/if_constants_add=>gc_data_from_source
        OR /idxgc/if_constants_add=>gc_default_processing.

        LOOP AT sis_process_data_src-reg_code_data ASSIGNING FIELD-SYMBOL(<ls_reg_src>) WHERE heat_consumpt IS NOT INITIAL.
          IF line_exists( sis_process_step_data-reg_code_data[ item_id = <ls_reg_src>-item_id reg_code = '' ] ).
            sis_process_step_data-reg_code_data[ item_id = <ls_reg_src>-item_id reg_code = '' ]-heat_consumpt = <ls_reg_src>-heat_consumpt.
          ELSE.
            sis_process_step_data-reg_code_data = VALUE #( BASE sis_process_step_data-reg_code_data ( item_id       = <ls_reg_src>-item_id
                                                                                                      heat_consumpt = <ls_reg_src>-heat_consumpt ) ).
          ENDIF.
        ENDLOOP.

      WHEN /idxgc/if_constants_add=>gc_data_from_add_source.

        LOOP AT sis_process_data_src_add-reg_code_data ASSIGNING FIELD-SYMBOL(<ls_reg_src_add>).
          IF line_exists( sis_process_step_data-reg_code_data[ item_id = <ls_reg_src_add>-item_id reg_code = '' ] ).
            sis_process_step_data-reg_code_data[ item_id = <ls_reg_src_add>-item_id reg_code = '' ]-heat_consumpt = <ls_reg_src_add>-heat_consumpt.
          ELSE.
            sis_process_step_data-reg_code_data = VALUE #( BASE sis_process_step_data-reg_code_data ( item_id       = <ls_reg_src_add>-item_id
                                                                                                      heat_consumpt = <ls_reg_src_add>-heat_consumpt ) ).
          ENDIF.
        ENDLOOP.

    ENDCASE.

***** Prüfen ob alle relevanten Daten gefüllt sind ************************************************
    IF strlen( sis_process_step_data-ext_ui ) = 11.
      LOOP AT sis_process_step_data-reg_code_data TRANSPORTING NO FIELDS
        WHERE heat_consumpt IS INITIAL AND reg_code IS INITIAL
          AND ( cons_type = /idxgl/if_constants_ide=>gc_cons_type_z65 OR cons_type = /idxgl/if_constants_ide=>gc_cons_type_z66 ).
        MESSAGE e038(/idxgc/ide_add) WITH TEXT-004 INTO siv_mtext.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD ims_device_config.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 04.03.2019
*
* Beschreibung: Ermittlung neuer Messwertübermittlungsfall
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXXX-X    XX.XX.XXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    DATA: lt_device_list       TYPE /idxgc/t_device_list,
          lv_flag_multiple_reg TYPE flag.

    FIELD-SYMBOLS: <ls_ord_item_add> TYPE /idxgc/s_ord_item_details.

    super->ims_device_config( ).

    CASE siv_data_processing_mode.
      WHEN /idxgc/if_constants_add=>gc_default_processing
        OR /idxgc/if_constants_add=>gc_data_from_source.

        get_device_list( EXPORTING iv_pod = sis_process_step_data-int_ui
                         IMPORTING et_device_list = lt_device_list ).
        LOOP AT lt_device_list ASSIGNING FIELD-SYMBOL(<ls_device>).
          IF lines( <ls_device>-t_etdz ) > 1.
            lv_flag_multiple_reg = abap_true.
          ENDIF.
        ENDLOOP.

        IF line_exists( sis_process_data_src-ord_item_add[ 1 ] ).
          IF line_exists( sis_process_step_data-ord_item_add[ 1 ] ).
            ASSIGN sis_process_step_data-ord_item_add[ 1 ] TO <ls_ord_item_add>.
            CLEAR: <ls_ord_item_add>-settl_proc.
          ELSE.
            APPEND INITIAL LINE TO sis_process_step_data-ord_item_add ASSIGNING <ls_ord_item_add>.
            <ls_ord_item_add>-item_id = siv_itemid.
          ENDIF.

          IF sis_process_data_src-ord_item_add[ 1 ]-settl_proc = /adz/if_bdr_co=>gc_settl_proc_z38. "Prognose auf Basis von Profilen
            "Eintarif: MÜ-B -> MÜ-D, Doppeltarif: MÜ-C -> MÜ-E
            IF lv_flag_multiple_reg = abap_true.
              <ls_ord_item_add>-ims_dev_conf = /adz/if_bdr_co=>gc_ims_dev_conf_z43.
            ELSE.
              <ls_ord_item_add>-ims_dev_conf = /adz/if_bdr_co=>gc_ims_dev_conf_z42.
            ENDIF.
          ELSE.
            "Eintarif: MÜ-D -> MÜ-B, Doppeltarif: MÜ-E -> MÜ-C
            IF lv_flag_multiple_reg = abap_true.
              <ls_ord_item_add>-ims_dev_conf = /adz/if_bdr_co=>gc_ims_dev_conf_z41.
            ELSE.
              <ls_ord_item_add>-ims_dev_conf = /adz/if_bdr_co=>gc_ims_dev_conf_z67.
            ENDIF.
          ENDIF.
        ENDIF.

      WHEN OTHERS.
    ENDCASE.

    IF sis_process_step_data-ord_item_add IS INITIAL.
      MESSAGE e038(/idxgc/ide_add) WITH TEXT-009 INTO siv_mtext.
      /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


METHOD measured_value_type_obis.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: BOECKMANN-C                                                             Datum: 04.03.2019
*
* Beschreibung: Ermittlung OBIS-KEnnziffern
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXXXX-X   XX.XX.XXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
  FIELD-SYMBOLS: <ls_reg_code_data> TYPE /idxgc/s_reg_code_details.

  CASE siv_data_processing_mode.
    WHEN /idxgc/if_constants_add=>gc_default_processing
      OR /idxgc/if_constants_add=>gc_data_from_source.
      READ TABLE sis_process_data_src-reg_code_data INTO DATA(ls_reg_code_data_src) WITH KEY item_id = siv_itemid.
      IF sy-subrc = 0.
        IF line_exists( sis_process_step_data-reg_code_data[ item_id = siv_itemid ] ).
          ASSIGN sis_process_step_data-reg_code_data[ item_id = siv_itemid ] TO <ls_reg_code_data>.
        ELSE.
          APPEND INITIAL LINE TO sis_process_step_data-reg_code_data ASSIGNING <ls_reg_code_data>.
          <ls_reg_code_data>-item_id = siv_itemid.
        ENDIF.
        <ls_reg_code_data>-reg_code = ls_reg_code_data_src-reg_code.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.

  IF sis_process_step_data-reg_code_data IS INITIAL.
    MESSAGE e038(/idxgc/ide_add) WITH TEXT-007 INTO siv_mtext.
    /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
  ENDIF.

ENDMETHOD.


METHOD message_category.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: BOECKMANN-C                                                             Datum: 17.04.2019
*
* Beschreibung: Ermittlung Nachrichtenkategorie
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
  TRY.
      super->message_category( ).
    CATCH /idxgc/cx_process_error.
      "Ob das Feld benötigt wird, wird unten geprüft.
  ENDTRY.

  IF sis_process_step_data-docname_code IS INITIAL.
    CASE siv_data_processing_mode.
*   Get data from source step
      WHEN /idxgc/if_constants_add=>gc_data_from_source.
        sis_process_step_data-docname_code = sis_process_data_src-docname_code.

*   Get data from additional source step
      WHEN /idxgc/if_constants_add=>gc_data_from_add_source.
        sis_process_step_data-docname_code = sis_process_data_src_add-docname_code.

*   Get data from default determination logic
      WHEN /idxgc/if_constants_add=>gc_default_processing.
        CASE sis_process_data_src-docname_code.
          WHEN /adz/if_bdr_co=>gc_msg_category_z30 OR /adz/if_bdr_co=>gc_msg_category_z31 OR /adz/if_bdr_co=>gc_msg_category_z34.
            sis_process_step_data-docname_code = sis_process_data_src-docname_code.
          WHEN OTHERS.
        ENDCASE.

      WHEN OTHERS.
    ENDCASE.
  ENDIF.

  IF sis_process_step_data-docname_code IS INITIAL.
    MESSAGE e038(/idxgc/ide_add) WITH TEXT-007 INTO siv_mtext.
    /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
  ENDIF.
ENDMETHOD.


METHOD obis_code.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 02.11.2019
*
* Beschreibung: Ausnahme abfangen, da nicht alle Einträge in der REG_CODE_DATA Tabelle auch
*   tatsächlich einen REG_CODE enthalten. Das ist nötig, damit das Ausgangs-Mapping funktioniert.
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
  TRY.
      super->obis_code( ).
    CATCH /idxgc/cx_process_error INTO gx_previous.
      IF sis_process_step_data-bmid <> /adz/if_bdr_co=>gc_bmid-ord_sc_201.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ir_previous = gx_previous ).
      ENDIF.
  ENDTRY.
ENDMETHOD.


  METHOD off_peak_enabled.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 01.11.2019
*
* Beschreibung: Schwachlastfähigkeit für Prozess Ändereung der Gerätekonfiguration
*   WICHTIG: Damit die Daten im Mapping übernommen werden muss der Wert mit der richtigen ITEM_ID,
*   aber ohne REG_CODE in die Zeile geschrieben werden.
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* THIMEL-R    17.01.2019 Auch für .0 OBIS-Kennziffern soll augenscheinlich die Schwachlastfähigkeit
*                        mitgeschickt werden.
***************************************************************************************************
    DATA: lt_reg_code_data_src TYPE /idxgc/t_reg_code_details.

    IF siv_data_processing_mode = /idxgc/if_constants_add=>gc_data_from_add_source.
      lt_reg_code_data_src = sis_process_data_src_add-reg_code_data.
    ELSE.
      "Default Processing: Lesen aus dem Quellschritt
      lt_reg_code_data_src = sis_process_data_src-reg_code_data.
    ENDIF.

    LOOP AT lt_reg_code_data_src ASSIGNING FIELD-SYMBOL(<ls_reg_src>) WHERE tarif_alloc IS NOT INITIAL.
      TRY.
          IF cl_abap_matcher=>matches( pattern = '^1-([0-5]?[0-9]|6[0-5]):[12]\.[89]\.[0-9]$' text = <ls_reg_src>-reg_code ). "RT, 17.01.2019, Am Ende war vorher "[1-9]$"
            IF line_exists( sis_process_step_data-reg_code_data[ item_id = <ls_reg_src>-item_id reg_code = '' ] ).
              sis_process_step_data-reg_code_data[ item_id = <ls_reg_src>-item_id reg_code = '' ]-tarif_alloc = <ls_reg_src>-tarif_alloc.
            ELSE.
              sis_process_step_data-reg_code_data = VALUE #( BASE sis_process_step_data-reg_code_data ( item_id     = <ls_reg_src>-item_id
                                                                                                        tarif_alloc = <ls_reg_src>-tarif_alloc ) ).
            ENDIF.
          ENDIF.
        CATCH cx_sy_regex.
          "Fehler werden unten geprüft.
      ENDTRY.
    ENDLOOP.

***** Prüfen ob alle relevanten Daten gefüllt sind ************************************************
    LOOP AT sis_process_step_data-reg_code_data ASSIGNING FIELD-SYMBOL(<ls_reg_code_data>) WHERE reg_code IS NOT INITIAL.
      IF cl_abap_matcher=>matches( pattern = '^1-([0-5]?[0-9]|6[0-5]):[12]\.[89]\.[0-9]$' text = <ls_reg_code_data>-reg_code ). "RT, 17.01.2019, Am Ende war vorher "[1-9]$"
        IF line_exists( sis_process_step_data-reg_code_data[ item_id = <ls_reg_code_data>-item_id reg_code = '' tarif_alloc = '' ] ).
          MESSAGE e038(/idxgc/ide_add) WITH TEXT-005 INTO siv_mtext.
          /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


METHOD processing_end_date_time.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: BOECKMANN-C, Datum: 17.04.2019
*
* Beschreibung: Endedatum ermitteln
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
  DATA: ls_ord_item_add_src TYPE /idxgc/s_ord_item_details.

  FIELD-SYMBOLS: <ls_ord_item_add> TYPE /idxgc/s_ord_item_details.

  TRY.
      super->processing_end_date_time( ).
    CATCH /idxgc/cx_process_error.
      "Ob das Feld benötigt wird, wird unten geprüft.
  ENDTRY.

  CASE siv_data_processing_mode.
    WHEN /idxgc/if_constants_add=>gc_default_processing
      OR /idxgc/if_constants_add=>gc_data_from_source.

      CHECK sis_process_step_data-docname_code = /adz/if_bdr_co=>gc_msg_category_z34.

      READ TABLE sis_process_data_src-ord_item_add INTO ls_ord_item_add_src WITH KEY item_id = siv_itemid.

      READ TABLE sis_process_step_data-ord_item_add ASSIGNING <ls_ord_item_add> WITH KEY item_id = siv_itemid.
      IF <ls_ord_item_add> IS NOT ASSIGNED.
        APPEND INITIAL LINE TO sis_process_step_data-ord_item_add ASSIGNING <ls_ord_item_add>.
        <ls_ord_item_add>-item_id = siv_itemid.
      ENDIF.

      <ls_ord_item_add>-end_read_date = ls_ord_item_add_src-end_read_date.
      <ls_ord_item_add>-end_read_time = ls_ord_item_add_src-end_read_time.
      <ls_ord_item_add>-end_read_offs = ls_ord_item_add_src-end_read_offs.

    WHEN OTHERS .
* Do nothing.
  ENDCASE.

  " Check if field is filled in case it is mandantory
  IF siv_mandatory_data = abap_true AND ( <ls_ord_item_add>-end_read_date IS INITIAL OR
    <ls_ord_item_add>-end_read_offs IS INITIAL ). "Zeit darf initial = 000000 sein.
    MESSAGE e038(/idxgc/ide_add) WITH TEXT-003 INTO siv_mtext.
    /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
  ENDIF.
ENDMETHOD.


METHOD processing_start_date_time.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: BOECKMANN-C                                                             Datum: 17.04.2019
*
* Beschreibung: Startdatum ermitteln
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************

  DATA: ls_ord_item_add_src TYPE /idxgc/s_ord_item_details.

  FIELD-SYMBOLS: <ls_ord_item_add>    TYPE /idxgc/s_ord_item_details.

  TRY.
      super->processing_start_date_time( ).
    CATCH /idxgc/cx_process_error.
      "Ob das Feld benötigt wird, wird unten geprüft.
  ENDTRY.

  CASE siv_data_processing_mode.
    WHEN /idxgc/if_constants_add=>gc_default_processing
      OR /idxgc/if_constants_add=>gc_data_from_source.

      CHECK sis_process_step_data-docname_code = /adz/if_bdr_co=>gc_msg_category_z34.

      READ TABLE sis_process_data_src-ord_item_add INTO ls_ord_item_add_src WITH KEY item_id = siv_itemid.

      READ TABLE sis_process_step_data-ord_item_add ASSIGNING <ls_ord_item_add> WITH KEY item_id = siv_itemid.
      IF <ls_ord_item_add> IS NOT ASSIGNED.
        APPEND INITIAL LINE TO sis_process_step_data-ord_item_add ASSIGNING <ls_ord_item_add>.
        <ls_ord_item_add>-item_id = siv_itemid.
      ENDIF.

      <ls_ord_item_add>-start_read_date = ls_ord_item_add_src-start_read_date.
      <ls_ord_item_add>-start_read_time = ls_ord_item_add_src-start_read_time.
      <ls_ord_item_add>-start_read_offs = ls_ord_item_add_src-start_read_offs.

    WHEN OTHERS.
* Do nothing.
  ENDCASE.

  " Check if field is filled in case it is mandantory
  IF siv_mandatory_data = abap_true AND ( <ls_ord_item_add>-start_read_date IS INITIAL OR
    <ls_ord_item_add>-start_read_offs IS INITIAL ). "Zeit darf initial = 000000 sein.
    MESSAGE e038(/idxgc/ide_add) WITH TEXT-002 INTO siv_mtext.
    /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
  ENDIF.

ENDMETHOD.


METHOD product.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: BOECKMANN-C                                                             Datum: 01.04.2019
*
* Beschreibung: Produkt- / Leistungsbeschreibung für Z34 (Reklamation von Werten) übernehmen.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
  TRY.
      super->product( ).
    CATCH /idxgc/cx_process_error.
      "Ob das Feld benötigt wird, wird unten geprüft.
  ENDTRY.

  CASE siv_data_processing_mode.
* Get data from additional source step
    WHEN /idxgc/if_constants_add=>gc_data_from_add_source.
      sis_process_step_data-serv_measval  = sis_process_data_src_add-serv_measval.

* Get data from default determination logic/source step
    WHEN /idxgc/if_constants_add=>gc_data_from_source OR
         /idxgc/if_constants_add=>gc_default_processing.

      IF sis_process_step_data-docname_code = /adz/if_bdr_co=>gc_msg_category_z34.
        sis_process_step_data-serv_measval  = sis_process_data_src-serv_measval.
      ENDIF.
  ENDCASE.

* Check if field is filled in case it is mandatory
  IF siv_mandatory_data = abap_true AND sis_process_step_data-serv_measval IS INITIAL AND
    ( sis_process_step_data-docname_code = /idxgc/if_constants_ide=>gc_msg_category_7 OR
      sis_process_step_data-docname_code = /adz/if_bdr_co=>gc_msg_category_z34 ).
    MESSAGE e038(/idxgc/ide_add) WITH TEXT-006 INTO siv_mtext.
    /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
  ENDIF.
ENDMETHOD.


METHOD reference_to_previous_message.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: BOECKMANN-C                                                             Datum: 17.04.2019
*
* Beschreibung: Referenz auf vorherige Nachricht ermitteln.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXXXX-X   TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
  DATA: ls_ref_to_msg TYPE /idxgc/s_ref2msg_details.

  FIELD-SYMBOLS <ls_ref_to_msg> TYPE /idxgc/s_ref2msg_details.

  CASE siv_data_processing_mode.
    WHEN /idxgc/if_constants_add=>gc_default_processing
      OR /idxgc/if_constants_add=>gc_data_from_source.
      READ TABLE sis_process_data_src-ref_to_msg
           INTO ls_ref_to_msg WITH KEY ref_qual = /idxgc/if_constants_ide=>gc_rff_qual_acw.

      READ TABLE sis_process_step_data-ref_to_msg
         ASSIGNING <ls_ref_to_msg> WITH KEY ref_qual = /idxgc/if_constants_ide=>gc_rff_qual_acw.
      IF sy-subrc <> 0.
        APPEND INITIAL LINE TO sis_process_step_data-ref_to_msg ASSIGNING <ls_ref_to_msg>.
      ENDIF.
      <ls_ref_to_msg> = ls_ref_to_msg.
    WHEN OTHERS.
  ENDCASE.

  IF <ls_ref_to_msg>-ref_no IS INITIAL OR <ls_ref_to_msg>-ref_msg_date IS INITIAL OR <ls_ref_to_msg>-ref_msg_time IS INITIAL.
    MESSAGE e038(/idxgc/ide_add) WITH TEXT-006 INTO siv_mtext.
    /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
  ENDIF.

ENDMETHOD.


  METHOD reg_code_mr_relevance_and_use.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 01.11.2019
*
* Beschreibung: Marktrollenrelevanz und Verwendungszweck für Prozess Ändereung der Gerätekonfig.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    CASE siv_data_processing_mode.
      WHEN /idxgc/if_constants_add=>gc_data_from_source
        OR /idxgc/if_constants_add=>gc_default_processing.

        CLEAR: sis_process_step_data-/idxgl/data_relevance.
        LOOP AT sis_process_data_src-/idxgl/data_relevance ASSIGNING FIELD-SYMBOL(<ls_data_relevance_src>).
          sis_process_step_data-/idxgl/data_relevance
            = VALUE #( BASE sis_process_step_data-/idxgl/data_relevance ( item_id    = <ls_data_relevance_src>-item_id
                                                                          data_mrrel = <ls_data_relevance_src>-data_mrrel
                                                                          data_use   = <ls_data_relevance_src>-data_use ) ).
        ENDLOOP.

      WHEN /idxgc/if_constants_add=>gc_data_from_add_source.

        CLEAR: sis_process_step_data-/idxgl/data_relevance.
        LOOP AT sis_process_data_src_add-/idxgl/data_relevance ASSIGNING FIELD-SYMBOL(<ls_data_relevance_src_add>).
          sis_process_step_data-/idxgl/data_relevance
            = VALUE #( BASE sis_process_step_data-/idxgl/data_relevance ( item_id    = <ls_data_relevance_src_add>-item_id
                                                                          data_mrrel = <ls_data_relevance_src_add>-data_mrrel
                                                                          data_use   = <ls_data_relevance_src_add>-data_use ) ).
        ENDLOOP.
      WHEN OTHERS.
    ENDCASE.

***** Prüfen ob alle relevanten Daten gefüllt sind ************************************************
    IF strlen( sis_process_step_data-ext_ui ) = 11 AND sis_process_step_data-/idxgl/data_relevance IS INITIAL.
      MESSAGE e038(/idxgc/ide_add) WITH TEXT-001 INTO siv_mtext.
      /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


METHOD settlement_procedure.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 01.03.2019
*
* Beschreibung: Bilanzierungsverfahren übernehmen
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************


  super->settlement_procedure( ).

  CASE siv_data_processing_mode.
    WHEN /idxgc/if_constants_add=>gc_data_from_source
      OR /idxgc/if_constants_add=>gc_default_processing.

      IF line_exists( sis_process_data_src-ord_item_add[ item_id = siv_itemid ] ).
        IF line_exists( sis_process_step_data-ord_item_add[ item_id = siv_itemid ] ).
          sis_process_step_data-ord_item_add[ item_id = siv_itemid ]-settl_proc  = sis_process_data_src-ord_item_add[ item_id = siv_itemid ]-settl_proc.
          sis_process_step_data-ord_item_add[ item_id = siv_itemid ]-device_conf = sis_process_data_src-ord_item_add[ item_id = siv_itemid ]-device_conf.
        ELSE.
          sis_process_step_data-ord_item_add = VALUE #( ( item_id     = siv_itemid
                                                          settl_proc  = sis_process_data_src-ord_item_add[ item_id = siv_itemid ]-settl_proc
                                                          device_conf = sis_process_data_src-ord_item_add[ item_id = siv_itemid ]-device_conf ) ).
        ENDIF.
      ENDIF.

    WHEN /idxgc/if_constants_add=>gc_data_from_add_source.

      IF line_exists( sis_process_data_src_add-ord_item_add[ item_id = siv_itemid ] ).
        IF line_exists( sis_process_step_data-ord_item_add[ item_id = siv_itemid ] ).
          sis_process_step_data-ord_item_add[ item_id = siv_itemid ]-settl_proc  = sis_process_data_src_add-ord_item_add[ item_id = siv_itemid ]-settl_proc.
          sis_process_step_data-ord_item_add[ item_id = siv_itemid ]-device_conf = sis_process_data_src_add-ord_item_add[ item_id = siv_itemid ]-device_conf.
        ELSE.
          sis_process_step_data-ord_item_add = VALUE #( ( item_id     = siv_itemid
                                                          settl_proc  = sis_process_data_src_add-ord_item_add[ item_id = siv_itemid ]-settl_proc
                                                          device_conf = sis_process_data_src_add-ord_item_add[ item_id = siv_itemid ]-device_conf ) ).
        ENDIF.
      ENDIF.

    WHEN OTHERS .

  ENDCASE.

* Check whether the field is required, otherwise raise exception for the missing field.
  IF line_exists( sis_process_step_data-ord_item_add[ item_id = siv_itemid ] ).
    IF siv_mandatory_data = abap_true AND
       ( sis_process_step_data-ord_item_add[ item_id = siv_itemid ]-settl_proc IS INITIAL OR
         sis_process_step_data-ord_item_add[ item_id = siv_itemid ]-device_conf IS INITIAL ).
      MESSAGE e038(/idxgc/ide_add) WITH TEXT-004 INTO siv_mtext.
      /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDIF.
  ENDIF.
ENDMETHOD.
ENDCLASS.
