CLASS /adz/cl_bdr_check_method DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-DATA gx_previous TYPE REF TO cx_root .

    CLASS-METHODS check_chg_dev_conf_rejection
      IMPORTING
        !is_process_step_key TYPE /idxgc/s_proc_step_key
      EXPORTING
        !et_check_result     TYPE /idxgc/t_check_result
      CHANGING
        !cr_data             TYPE REF TO data
        !cr_data_log         TYPE REF TO data
      RAISING
        /idxgc/cx_utility_error .
    CLASS-METHODS check_chg_settl_deadline
      IMPORTING
        !is_process_step_key TYPE /idxgc/s_proc_step_key
      EXPORTING
        !et_check_result     TYPE /idxgc/t_check_result
      CHANGING
        !cr_data             TYPE REF TO data
        !cr_data_log         TYPE REF TO data
      RAISING
        /idxgc/cx_utility_error .
    CLASS-METHODS check_chg_settl_rejection
      IMPORTING
        !is_process_step_key TYPE /idxgc/s_proc_step_key
      EXPORTING
        !et_check_result     TYPE /idxgc/t_check_result
      CHANGING
        !cr_data             TYPE REF TO data
        !cr_data_log         TYPE REF TO data
      RAISING
        /idxgc/cx_utility_error .
    CLASS-METHODS check_start_data_valid
      IMPORTING
        !is_process_step_key TYPE /idxgc/s_proc_step_key
      EXPORTING
        !et_check_result     TYPE /idxgc/t_check_result
      CHANGING
        !cr_data             TYPE REF TO data
        !cr_data_log         TYPE REF TO data
      RAISING
        /idxgc/cx_utility_error .
    CLASS-METHODS check_recl_value_rejection
      IMPORTING
        !is_process_step_key TYPE /idxgc/s_proc_step_key
      EXPORTING
        !et_check_result     TYPE /idxgc/t_check_result
      CHANGING
        !cr_data             TYPE REF TO data
        !cr_data_log         TYPE REF TO data
      RAISING
        /idxgc/cx_utility_error .
    CLASS-METHODS check_resp_msg_type
      IMPORTING
        !is_process_step_key TYPE /idxgc/s_proc_step_key
      EXPORTING
        !et_check_result     TYPE /idxgc/t_check_result
      CHANGING
        !cr_data             TYPE REF TO data
        !cr_data_log         TYPE REF TO data
      RAISING
        /idxgc/cx_utility_error .
    CLASS-METHODS check_start_dev_conf_proc
      IMPORTING
        !is_process_step_key TYPE /idxgc/s_proc_step_key
      EXPORTING
        !et_check_result     TYPE /idxgc/t_check_result
      CHANGING
        !cr_data             TYPE REF TO data
        !cr_data_log         TYPE REF TO data
      RAISING
        /idxgc/cx_utility_error .
    CLASS-METHODS link_iftsta_with_ordrsp_pdoc
      IMPORTING
        !is_process_step_key TYPE /idxgc/s_proc_step_key
      EXPORTING
        !et_check_result     TYPE /idxgc/t_check_result
      CHANGING
        !cr_data             TYPE REF TO data
        !cr_data_log         TYPE REF TO data
      RAISING
        /idxgc/cx_utility_error .
    CLASS-METHODS upd_foreign_mos_list
      IMPORTING
        !is_process_step_key TYPE /idxgc/s_proc_step_key
      EXPORTING
        !et_check_result     TYPE /idxgc/t_check_result
      CHANGING
        !cr_data             TYPE REF TO data
        !cr_data_log         TYPE REF TO data
      RAISING
        /idxgc/cx_utility_error .
    CLASS-METHODS upd_receiver_for_iftsta
      IMPORTING
        !is_process_step_key TYPE /idxgc/s_proc_step_key
      EXPORTING
        !et_check_result     TYPE /idxgc/t_check_result
      CHANGING
        !cr_data             TYPE REF TO data
        !cr_data_log         TYPE REF TO data
      RAISING
        /idxgc/cx_utility_error .
  PROTECTED SECTION.

    CLASS-DATA gv_msgtxt TYPE string .
  PRIVATE SECTION.
ENDCLASS.



CLASS /ADZ/CL_BDR_CHECK_METHOD IMPLEMENTATION.


  METHOD check_chg_dev_conf_rejection.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R, Datum: 09.10.2018
*
* Beschreibung: Aktuell immer einen Klärfall erzeugen.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    APPEND /adz/if_bdr_co=>gc_cr_user_decision TO et_check_result.
  ENDMETHOD.


  METHOD check_chg_settl_deadline.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 29.03.2019
*
* Beschreibung: Prüfung, ob die Frist eingehalten wird zur Änderung des Bilanzierungsverfahrens.
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    DATA: lr_process_data_step TYPE REF TO /idxgc/if_process_data_step,
          ls_proc_step_data    TYPE /idxgc/s_proc_step_data_all,
          ls_proc_data         TYPE /idxgc/s_proc_data,
          lv_swt_period_type   TYPE e_ideswttimetype,
          lv_deadline          TYPE datum.

    FIELD-SYMBOLS: <lr_process_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
                   <lr_process_log>         TYPE REF TO /idxgc/if_process_log.

    ASSIGN cr_data->*     TO  <lr_process_data_extern>.
    ASSIGN cr_data_log->* TO  <lr_process_log>.
    lr_process_data_step ?= <lr_process_data_extern>.

***** Schrittdaten vom aktuellen Schritt holen ****************************************************
    TRY.
        ls_proc_step_data = lr_process_data_step->get_process_step_data( is_process_step_key ).
      CATCH /idxgc/cx_process_error INTO gx_previous.
        IF <lr_process_log> IS ASSIGNED.
          <lr_process_log>->add_message_to_process_log( ).
        ENDIF.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gx_previous ).
    ENDTRY.

    <lr_process_data_extern>->get_process_data( IMPORTING es_process_data = ls_proc_data ).

***** Methodenlogik *******************************************************************************
    IF ls_proc_step_data-docname_code = /adz/if_bdr_co=>gc_msg_category_z30.
      IF ls_proc_step_data-msg_date IS INITIAL.
        APPEND /idxgc/if_constants_add=>gc_cr_error TO et_check_result.
        RETURN.
      ENDIF.

      IF line_exists( ls_proc_step_data-ord_item_add[ 1 ] ).
        IF ls_proc_step_data-ord_item_add[ 1 ]-settl_proc = /adz/if_bdr_co=>gc_settl_proc_z38 OR
           ls_proc_step_data-ord_item_add[ 1 ]-settl_proc = /adz/if_bdr_co=>gc_settl_proc_z39.
          lv_swt_period_type = /adz/if_bdr_co=>gc_swt_period_type_adzbdr_s01.
        ELSE.
          lv_swt_period_type = /adz/if_bdr_co=>gc_swt_period_type_adzbdr_t01.
        ENDIF.
      ELSE.
        APPEND /idxgc/if_constants_add=>gc_cr_error TO et_check_result.
        RETURN.
      ENDIF.

      TRY.
          CALL METHOD /idxgc/cl_check_method_add=>calc_due_date
            EXPORTING
              iv_keydate         = ls_proc_step_data-msg_date
              iv_swt_period_type = lv_swt_period_type
              iv_proc_type       = ls_proc_step_data-proc_type
            IMPORTING
              ev_date            = lv_deadline.
        CATCH /idxgc/cx_utility_error .
          IF <lr_process_log> IS ASSIGNED.
            <lr_process_log>->add_message_to_process_log( is_process_step_key = is_process_step_key ).
          ENDIF.
          APPEND /idxgc/if_constants_add=>gc_cr_error TO et_check_result.
          RETURN.
      ENDTRY.

      IF ls_proc_step_data-proc_date <= lv_deadline.
        APPEND /adz/if_bdr_co=>gc_cr_deadline_not_met TO et_check_result.
      ELSE.
        APPEND /adz/if_bdr_co=>gc_cr_in_time TO et_check_result.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD check_chg_settl_rejection.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R, Datum: 09.10.2018
*
* Beschreibung: Aktuell immer einen Klärfall erzeugen.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    APPEND /adz/if_bdr_co=>gc_cr_user_decision TO et_check_result.
  ENDMETHOD.


  METHOD check_recl_value_rejection.
************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R, Datum: 09.10.2018
*
* Beschreibung: Aktuell immer einen Klärfall erzeugen.
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************
    APPEND /adz/if_bdr_co=>gc_cr_user_decision TO et_check_result.
  ENDMETHOD.


  METHOD check_resp_msg_type.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 28.05.2019
*
* Beschreibung: Kopie aus Klassenmethode /IDXGC/CL_CHECK_METHOD_ADD=>/IDXGC/IF_CHECK_METHOD_ADD~
*   CHECK_RESP_MSG_TYPE und Anpassung für Reklamation von Werten und Bilanzierungsverfahrens-
*   änderung. Änderungen sind mit +++++++++++ markiert, Variablen und Methodenaufrufe wurden
*   angepasst.
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    DATA:
      lv_check_result      TYPE /idxgc/de_check_result,
      ls_process_step_data TYPE /idxgc/s_proc_step_data_all,
      lr_process_data_step TYPE REF TO /idxgc/if_process_data_step,
      lr_ctx               TYPE REF TO /idxgc/cl_pd_doc_context,
      lt_proc_step_data    TYPE /idxgc/t_proc_step_data,
      ls_proc_step_data    TYPE /idxgc/s_proc_step_data,
      lx_previous          TYPE REF TO /idxgc/cx_general.

    FIELD-SYMBOLS:
      <lr_process_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
      <lr_process_log>         TYPE REF TO /idxgc/if_process_log.

    ASSIGN cr_data->*     TO  <lr_process_data_extern>.
    ASSIGN cr_data_log->* TO  <lr_process_log>.

    lr_process_data_step ?= <lr_process_data_extern>.

    TRY.
        ls_process_step_data = lr_process_data_step->get_process_step_data( is_process_step_key ).

        lr_ctx = /idxgc/cl_pd_doc_context=>get_instance( iv_pdoc_no = ls_process_step_data-proc_ref
                                                         iv_bufref  = /idxgc/if_constants=>gc_true ).

        lr_ctx->get_proc_step_data( EXPORTING iv_msg_dir        = /idxgc/if_constants_add=>gc_message_direction_import
                                    IMPORTING et_proc_step_data = lt_proc_step_data ).
      CATCH /idxgc/cx_process_error INTO lx_previous.
        IF <lr_process_log> IS ASSIGNED.
          <lr_process_log>->add_message_to_process_log( ).
        ENDIF.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = lx_previous ).
    ENDTRY.

* if there is message which BMID is /ADZ/CD012, /ADZ/CD022 or /ADZ/CD032, then it is rejection message
    SORT lt_proc_step_data BY proc_step_timestamp DESCENDING.
    READ TABLE lt_proc_step_data INTO ls_proc_step_data INDEX 1.
*>>>+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    IF ls_proc_step_data-bmid = /adz/if_bdr_co=>gc_bmid-ord_sc_202.
      "Bei Ablehnung Gerätekonfiguration prüfen ob der Prozess von einem LF ausgelöst wurde.
      lr_ctx->get_header_data( IMPORTING es_proc_hdr = DATA(ls_proc_hdr) ).
      IF line_exists( ls_proc_hdr-process_links[ proc_id = /adz/if_bdr_co=>gc_proc_id_adz8021 ] ) . "Start aus anderem Prozess
        MESSAGE s011(/adz/bdr_messages) INTO gv_msgtxt.
        lv_check_result = /adz/if_bdr_co=>gc_cr_send_iftsta.
      ELSE.
        MESSAGE s326(/idxgc/utility_add) WITH ls_proc_step_data-assoc_servprov ls_proc_step_data-bmid ls_proc_step_data-response_cat INTO gv_msgtxt.
        lv_check_result = /idxgc/if_constants_add=>gc_cr_rec_rej_msg.
      ENDIF.
    ELSEIF ls_proc_step_data-bmid = /adz/if_bdr_co=>gc_bmid_adzif001 OR
           ls_proc_step_data-bmid = /adz/if_bdr_co=>gc_bmid-ord_sc_102 OR
           ls_proc_step_data-bmid = /adz/if_bdr_co=>gc_bmid_adzcd022.
*<<<+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      MESSAGE s326(/idxgc/utility_add) WITH ls_proc_step_data-assoc_servprov ls_proc_step_data-bmid ls_proc_step_data-response_cat INTO gv_msgtxt.
      lv_check_result = /idxgc/if_constants_add=>gc_cr_rec_rej_msg.
    ELSE.
      MESSAGE s327(/idxgc/utility_add) WITH ls_proc_step_data-assoc_servprov ls_proc_step_data-bmid INTO gv_msgtxt.
      lv_check_result = /idxgc/if_constants_add=>gc_cr_rec_con_msg.
    ENDIF.

    IF <lr_process_log> IS ASSIGNED.
      <lr_process_log>->add_message_to_process_log( is_business_log = /idxgc/if_constants=>gc_true ).
    ENDIF.

    APPEND lv_check_result TO et_check_result.
  ENDMETHOD.


  METHOD check_start_data_valid.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R, WÍSNIEWSKI-P                                                  Datum: 29.06.2019
*
* Beschreibung: Prüfung der an den Prozess übergebenen Daten.
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    DATA: lr_process_data_step TYPE REF TO /idxgc/if_process_data_step,
          ls_proc_step_data    TYPE /idxgc/s_proc_step_data_all.

    FIELD-SYMBOLS: <lr_process_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
                   <lr_process_log>         TYPE REF TO /idxgc/if_process_log.

    ASSIGN cr_data->*     TO  <lr_process_data_extern>.
    ASSIGN cr_data_log->* TO  <lr_process_log>.
    lr_process_data_step ?= <lr_process_data_extern>.

***** Schrittdaten vom aktuellen Schritt holen ****************************************************
    TRY.
        ls_proc_step_data = lr_process_data_step->get_process_step_data( is_process_step_key ).
      CATCH /idxgc/cx_process_error INTO gx_previous.
        IF <lr_process_log> IS ASSIGNED.
          <lr_process_log>->add_message_to_process_log( ).
        ENDIF.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gx_previous ).
    ENDTRY.

***** Methodenlogik *******************************************************************************
    /adz/cl_bdr_utility=>check_orders_data( EXPORTING is_proc_step_data = CORRESPONDING #( ls_proc_step_data )
                                            IMPORTING et_errors         = DATA(lt_errors) ).

    IF lt_errors IS INITIAL.
      APPEND /idxgc/if_constants_add=>gc_cr_ok TO et_check_result.
    ELSE.
      IF <lr_process_log> IS ASSIGNED.
        LOOP AT lt_errors ASSIGNING FIELD-SYMBOL(<ls_error>).
          <lr_process_log>->add_message_to_process_log( is_message = CORRESPONDING #( <ls_error> ) ).
        ENDLOOP.
      ENDIF.
      APPEND /idxgc/if_constants_add=>gc_cr_error TO et_check_result.
    ENDIF.


  ENDMETHOD.


  METHOD check_start_dev_conf_proc.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 28.05.2019
*
* Beschreibung: Prüfen ob der Prozess Bestellung Änderung der Gerätekonfiguration gestartet werden
*   soll. Dazu müssen in Tabelle SERVICEPROVIDER der Schrittdaten Einträge vorhanden sein.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    DATA: lr_process_data_step TYPE REF TO /idxgc/if_process_data_step,
          ls_proc_step_data    TYPE /idxgc/s_proc_step_data_all.

    FIELD-SYMBOLS: <lr_process_log>         TYPE REF TO /idxgc/if_process_log,
                   <lr_process_data_extern> TYPE REF TO /idxgc/if_process_data_extern.

    ASSIGN cr_data_log->* TO <lr_process_log>.
    ASSIGN cr_data->*     TO <lr_process_data_extern>.
    lr_process_data_step  ?= <lr_process_data_extern>.

***** Schrittdaten vom aktuellen Schritt holen ****************************************************
    TRY.
        ls_proc_step_data = lr_process_data_step->get_process_step_data( is_process_step_key ).
      CATCH /idxgc/cx_process_error INTO gx_previous.
        IF <lr_process_log> IS ASSIGNED.
          <lr_process_log>->add_message_to_process_log( ).
        ENDIF.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gx_previous ).
    ENDTRY.

***** Methodenlogik *******************************************************************************
    IF lines( ls_proc_step_data-serviceprovider ) > 0.
      APPEND /adz/if_bdr_co=>gc_cr_dev_conf_proc_start TO et_check_result.
    ELSE.
      APPEND /adz/if_bdr_co=>gc_cr_dev_conf_proc_not_needed TO et_check_result.
    ENDIF.
  ENDMETHOD.


  METHOD link_iftsta_with_ordrsp_pdoc.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 18.06.2019
*
* Beschreibung: Den letzten abgeschlossenen Bestellprozess suchen und mit dem IFTSTA Prozess ver-
*   linken.
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    DATA: lr_proc_data_step     TYPE REF TO /idxgc/if_process_data_step,
          lr_proc_data_pdoc     TYPE REF TO /idxgc/if_process_data_pdoc,
          lt_proc_data          TYPE /idxgc/t_proc_data,
          lt_sel_process_id     TYPE isu_ranges_tab,
          lt_sel_int_ui         TYPE isu_ranges_tab,
          lt_sel_process_status TYPE isu_ranges_tab,
          ls_range              TYPE isu_ranges,
          ls_proc_data          TYPE /idxgc/s_proc_data,
          ls_proc_step_data     TYPE /idxgc/s_proc_step_data_all.

    FIELD-SYMBOLS: <lr_process_log>      TYPE REF TO /idxgc/if_process_log,
                   <lr_proc_data_extern> TYPE REF TO /idxgc/if_process_data_extern.

    ASSIGN cr_data_log->* TO <lr_process_log>.
    ASSIGN cr_data->*     TO <lr_proc_data_extern>.
    lr_proc_data_step ?= <lr_proc_data_extern>.
    lr_proc_data_pdoc ?= <lr_proc_data_extern>.

    TRY.
        lr_proc_data_pdoc->get_process_data( IMPORTING es_process_data = ls_proc_data ).
        ls_proc_step_data = lr_proc_data_step->get_process_step_data( is_process_step_key ).
      CATCH /idxgc/cx_process_error INTO gx_previous.
        APPEND /idxgc/if_constants_add=>gc_cr_error TO et_check_result.
        RETURN.
    ENDTRY.

    TRY.
        ls_range-sign   = 'I'.
        ls_range-option = 'EQ'.

        ls_range-low    = /adz/if_bdr_co=>gc_proc_id_adz8020.
        APPEND ls_range TO lt_sel_process_id.
        ls_range-low    = ls_proc_step_data-int_ui.
        APPEND ls_range TO lt_sel_int_ui.
        ls_range-low    = /idxgc/if_constants_add=>gc_proc_status_confirmed.
        APPEND ls_range TO lt_sel_process_status.

        /idxgc/cl_process_document_db=>/idxgc/if_process_document_db~select_pdoc_mass( EXPORTING it_sel_process_id     = lt_sel_process_id
                                                                                                 it_sel_int_ui         = lt_sel_int_ui
                                                                                                 it_sel_process_status = lt_sel_process_status
                                                                                       IMPORTING et_proc_data = lt_proc_data ).
        IF lines( lt_proc_data ) > 0 .
          SORT lt_proc_data BY erdat DESCENDING.
          APPEND INITIAL LINE TO ls_proc_data-process_links ASSIGNING FIELD-SYMBOL(<ls_process_link>).
          <ls_process_link>-assoc_proc_id  = lt_proc_data[ 1 ]-proc_id.
          <ls_process_link>-assoc_proc_ref = lt_proc_data[ 1 ]-proc_ref.
          <ls_process_link>-proc_id        = ls_proc_step_data-proc_id.
          <ls_process_link>-proc_ref       = ls_proc_step_data-proc_ref.
          <ls_process_link>-trigger_step   = ls_proc_step_data-proc_step_ref.
          <ls_process_link>-link_type      = /idxgc/if_constants=>gc_proc_link_assoc.
          <ls_process_link>-link_timestamp = /idxgc/cl_utility_service=>/idxgc/if_utility_service~get_current_timestamp( ).
          <ls_process_link>-link_status    = /idxgc/if_constants=>gc_status_active.

          lr_proc_data_pdoc->update_process_data( is_process_data = ls_proc_data ).
          APPEND /idxgc/if_constants_add=>gc_cr_ok TO et_check_result.
        ELSE.
          APPEND /idxgc/if_constants_add=>gc_cr_error TO et_check_result.
        ENDIF.
      CATCH /idxgc/cx_process_error.
        APPEND /idxgc/if_constants_add=>gc_cr_error TO et_check_result.
    ENDTRY.

  ENDMETHOD.


  METHOD upd_foreign_mos_list.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 28.05.2019
*
* Beschreibung: Wenn fremde MSBs an den MeLos vorhanden sind, dann sollen diese in die Schrittdaten
*   geschrieben werden (Tabelle: SERVICEPROVIDER).
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* THIMEL-R    01.11.2019 Fremden MSB an MaLo zusätzlich ermitteln, Fehlerbehandlung angepasst
***************************************************************************************************
    DATA: lr_process_data_step  TYPE REF TO /idxgc/if_process_data_step,
          lr_badi_data_access   TYPE REF TO /idxgl/badi_data_access,
          lt_servprov_details   TYPE /idxgc/t_servprov_details,
          lt_euitrans_malo_melo TYPE /idxgl/t_euitrans_malo_melo,
          ls_proc_step_data     TYPE /idxgc/s_proc_step_data_all.

    FIELD-SYMBOLS: <lr_process_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
                   <lr_process_log>         TYPE REF TO /idxgc/if_process_log,
                   <ls_servprov_details>    TYPE /idxgc/s_servprov_details.

    ASSIGN cr_data_log->* TO <lr_process_log>.
    ASSIGN cr_data->*     TO <lr_process_data_extern>.
    lr_process_data_step  ?= <lr_process_data_extern>.

***** Schrittdaten vom aktuellen Schritt holen ****************************************************
    TRY.
        ls_proc_step_data = lr_process_data_step->get_process_step_data( is_process_step_key ).
      CATCH /idxgc/cx_process_error INTO gx_previous.
        IF <lr_process_log> IS ASSIGNED.
          <lr_process_log>->add_message_to_process_log( ).
        ENDIF.
        APPEND /idxgc/if_constants_add=>gc_cr_error TO et_check_result.
        RETURN.
    ENDTRY.

***** Methodenlogik *******************************************************************************
    TRY.
        GET BADI lr_badi_data_access.
      CATCH cx_badi_not_implemented.
    ENDTRY.

    IF lr_badi_data_access IS NOT INITIAL.
      TRY.
          CALL BADI lr_badi_data_access->get_pod_malo_melo
            EXPORTING
              iv_int_ui             = ls_proc_step_data-int_ui
              iv_key_date           = ls_proc_step_data-proc_date
            IMPORTING
              et_euitrans_malo_melo = lt_euitrans_malo_melo.
        CATCH /idxgc/cx_general.
      ENDTRY.
    ENDIF.

    LOOP AT lt_euitrans_malo_melo ASSIGNING FIELD-SYMBOL(<ls_euitrans_malo_melo>)
      WHERE int_ui_malo = ls_proc_step_data-int_ui AND datefrom <= ls_proc_step_data-proc_date AND dateto >= ls_proc_step_data-proc_date.

      /idxgc/cl_utility_isu_add=>get_servprov_onpod( EXPORTING iv_int_ui      = <ls_euitrans_malo_melo>-int_ui_malo
                                                          iv_keydate          = ls_proc_step_data-proc_date
                                                          iv_srv_cat          = /adz/if_bdr_co=>gc_intcode_m1
                                                IMPORTING et_servprov_details = lt_servprov_details ).
      LOOP AT lt_servprov_details ASSIGNING <ls_servprov_details> WHERE own_service = abap_false.
        APPEND <ls_servprov_details> TO ls_proc_step_data-serviceprovider.
      ENDLOOP.

      LOOP AT <ls_euitrans_malo_melo>-melo ASSIGNING FIELD-SYMBOL(<ls_euitrans_melo>)
        WHERE datefrom <= ls_proc_step_data-proc_date AND dateto >= ls_proc_step_data-proc_date.

        /idxgc/cl_utility_isu_add=>get_servprov_onpod( EXPORTING iv_int_ui           = <ls_euitrans_melo>-int_ui_melo
                                                                 iv_keydate          = ls_proc_step_data-proc_date
                                                                 iv_srv_cat          = /adz/if_bdr_co=>gc_intcode_m1
                                                       IMPORTING et_servprov_details = lt_servprov_details ).
        LOOP AT lt_servprov_details ASSIGNING <ls_servprov_details> WHERE own_service = abap_false.
          APPEND <ls_servprov_details> TO ls_proc_step_data-serviceprovider.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

    IF ls_proc_step_data-serviceprovider IS NOT INITIAL.
      TRY.
          lr_process_data_step->update_process_step_data( is_process_step_data = ls_proc_step_data ).
        CATCH /idxgc/cx_process_error INTO gx_previous.
          IF <lr_process_log> IS ASSIGNED.
            <lr_process_log>->add_message_to_process_log( ).
          ENDIF.
          APPEND /idxgc/if_constants_add=>gc_cr_error TO et_check_result.
      ENDTRY.
      APPEND /adz/if_bdr_co=>gc_cr_foreign_mos_found TO et_check_result.
    ELSE.
      APPEND /adz/if_bdr_co=>gc_cr_foreign_mos_not_found TO et_check_result.
    ENDIF.
  ENDMETHOD.


  METHOD upd_receiver_for_iftsta.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 28.05.2019
*
* Beschreibung: Empfänger für IFTSTA aus Prozess 8021 holen und übernehmen.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    DATA: lr_process_data_step   TYPE REF TO /idxgc/if_process_data_step,
          lr_badi_data_access    TYPE REF TO /idxgl/badi_data_access,
          lt_servprov_details    TYPE /idxgc/t_servprov_details,
          lt_euitrans_malo_melo  TYPE /idxgl/t_euitrans_malo_melo,
          ls_proc_step_data      TYPE /idxgc/s_proc_step_data_all,
          lr_ctx                 TYPE REF TO /idxgc/cl_pd_doc_context,
          ls_proc_step_data_8021 TYPE /idxgc/s_proc_step_data,
          ls_process_data        TYPE /idxgc/s_proc_data.

    FIELD-SYMBOLS: <lr_process_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
                   <lr_process_log>         TYPE REF TO /idxgc/if_process_log.

    ASSIGN cr_data_log->* TO <lr_process_log>.
    ASSIGN cr_data->*     TO <lr_process_data_extern>.
    lr_process_data_step  ?= <lr_process_data_extern>.

***** Schrittdaten vom aktuellen Schritt holen ****************************************************
    TRY.
        <lr_process_data_extern>->get_process_data( IMPORTING es_process_data = ls_process_data ).
        ls_proc_step_data = lr_process_data_step->get_process_step_data( is_process_step_key ).
      CATCH /idxgc/cx_process_error INTO gx_previous.
        IF <lr_process_log> IS ASSIGNED.
          <lr_process_log>->add_message_to_process_log( ).
        ENDIF.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gx_previous ).
    ENDTRY.

***** Methodenlogik *******************************************************************************
    IF line_exists( ls_process_data-process_links[ proc_id = /adz/if_bdr_co=>gc_proc_id_adz8021 ] ).
      TRY.
          lr_ctx = /idxgc/cl_pd_doc_context=>get_instance( iv_pdoc_no = ls_process_data-process_links[ proc_id = /adz/if_bdr_co=>gc_proc_id_adz8021 ]-proc_ref iv_bufref  = abap_true ).
          lr_ctx->get_proc_step_data( EXPORTING iv_msg_dir        = /idxgc/if_constants_add=>gc_message_direction_import
                                                iv_bmid           = /adz/if_bdr_co=>gc_bmid-ord_sc_101
                                      IMPORTING es_proc_step_data = ls_proc_step_data_8021 ).
          ls_proc_step_data-assoc_servprov = ls_proc_step_data_8021-assoc_servprov.
          lr_process_data_step->update_process_step_data( EXPORTING is_process_step_data = ls_proc_step_data ).
          APPEND /idxgc/if_constants_add=>gc_cr_ok TO et_check_result.
        CATCH /idxgc/cx_process_error.
          APPEND /idxgc/if_constants_add=>gc_cr_error TO et_check_result.
      ENDTRY.
    ELSE.
      APPEND /idxgc/if_constants_add=>gc_cr_error TO et_check_result.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
