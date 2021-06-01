class /ADZ/CL_BDR_DP_ORDERS_001 definition
  public
  inheriting from /IDXGL/CL_DP_ORDERS_001
  final
  create public .

public section.

  methods REFERENCE_TO_PREVIOUS_MESSAGE
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods MEASURED_VALUE_TYPE_OBIS
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
protected section.
private section.
ENDCLASS.



CLASS /ADZ/CL_BDR_DP_ORDERS_001 IMPLEMENTATION.


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

    IF siv_mandatory_data = abap_true AND sis_process_step_data-ord_item_add IS INITIAL.
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

  IF siv_mandatory_data = abap_true AND sis_process_step_data-reg_code_data IS INITIAL.
    MESSAGE e038(/idxgc/ide_add) WITH TEXT-008 INTO siv_mtext.
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

  IF siv_mandatory_data = abap_true AND sis_process_step_data-docname_code IS INITIAL.
    MESSAGE e038(/idxgc/ide_add) WITH TEXT-007 INTO siv_mtext.
    /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
  ENDIF.
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
    MESSAGE e038(/idxgc/ide_add) WITH TEXT-005 INTO siv_mtext.
    /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
  ENDIF.

ENDMETHOD.


METHOD settlement_procedure.
************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R, Datum: 01.03.2019
*
* Beschreibung: Bilanzierungsverfahren übernehmen
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************

  TRY.
      CALL METHOD super->settlement_procedure( ).
    CATCH /idxgc/cx_general.
      "Ob das Feld benötigt wird, wird unten geprüft.
  ENDTRY.

  DATA: ls_ord_item_add     TYPE /idxgc/s_ord_item_details,
        ls_ord_item_add_src TYPE /idxgc/s_ord_item_details.

  FIELD-SYMBOLS:
        <ls_ord_item_add>    TYPE /idxgc/s_ord_item_details.

  CASE siv_data_processing_mode.
* Get data from source step
    WHEN /idxgc/if_constants_add=>gc_data_from_source.
      READ TABLE sis_process_data_src-ord_item_add INTO ls_ord_item_add_src WITH KEY item_id = siv_itemid.

      READ TABLE sis_process_step_data-ord_item_add ASSIGNING <ls_ord_item_add> WITH KEY item_id = siv_itemid.
      IF sy-subrc <> 0.
        APPEND INITIAL LINE TO sis_process_step_data-ord_item_add ASSIGNING <ls_ord_item_add>.
        <ls_ord_item_add>-item_id = siv_itemid.
      ENDIF.

      <ls_ord_item_add>-settl_proc = ls_ord_item_add_src-settl_proc.

* Get data from additional source step
    WHEN /idxgc/if_constants_add=>gc_data_from_add_source.
      READ TABLE sis_process_data_src_add-ord_item_add INTO ls_ord_item_add_src WITH KEY item_id = siv_itemid.

      READ TABLE sis_process_step_data-ord_item_add ASSIGNING <ls_ord_item_add> WITH KEY item_id = siv_itemid.
      IF sy-subrc <> 0.
        APPEND INITIAL LINE TO sis_process_step_data-ord_item_add ASSIGNING <ls_ord_item_add>.
        <ls_ord_item_add>-item_id = siv_itemid.
      ENDIF.

      <ls_ord_item_add>-settl_proc = ls_ord_item_add_src-settl_proc.

* Get data from default determination logic
* Default logic is getting data from source step in case of Z27 and Z28
    WHEN /idxgc/if_constants_add=>gc_default_processing.

      CHECK sis_process_step_data-docname_code = /adz/if_bdr_co=>gc_msg_category_z30.

      READ TABLE sis_process_data_src-ord_item_add INTO ls_ord_item_add_src WITH KEY item_id = siv_itemid.

      READ TABLE sis_process_step_data-ord_item_add ASSIGNING <ls_ord_item_add> WITH KEY item_id = siv_itemid.
      IF sy-subrc <> 0.
        APPEND INITIAL LINE TO sis_process_step_data-ord_item_add ASSIGNING <ls_ord_item_add>.
        <ls_ord_item_add>-item_id = siv_itemid.
      ENDIF.

      <ls_ord_item_add>-settl_proc = ls_ord_item_add_src-settl_proc.

    WHEN OTHERS .
* Do nothing.
  ENDCASE.

* Check whether the field is required, otherwise raise exception for the missing field.
  READ TABLE sis_process_step_data-ord_item_add INTO ls_ord_item_add WITH KEY item_id = siv_itemid.
  IF sy-subrc <> 0.
    CLEAR ls_ord_item_add.
  ENDIF.
  IF siv_mandatory_data = abap_true AND ls_ord_item_add-settl_proc IS INITIAL.
    MESSAGE e038(/idxgc/ide_add) WITH TEXT-004 INTO siv_mtext.
    /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
  ENDIF.
ENDMETHOD.
ENDCLASS.
