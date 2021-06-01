class /ADZ/CL_MDC_CHECK_METHOD_APRK definition
  public
  create public .

public section.

  class-methods CHECK_POD_MALO_EXIST
    importing
      !IS_PROCESS_STEP_KEY type /IDXGC/S_PROC_STEP_KEY
    exporting
      !ET_CHECK_RESULT type /IDXGC/T_CHECK_RESULT
    changing
      !CR_DATA type ref to DATA
      !CR_DATA_LOG type ref to DATA
    raising
      /IDXGC/CX_UTILITY_ERROR .
  class-methods CHECK_RECEIVER_AUTHORIZATION
    importing
      !IS_PROCESS_STEP_KEY type /IDXGC/S_PROC_STEP_KEY
    exporting
      !ET_CHECK_RESULT type /IDXGC/T_CHECK_RESULT
    changing
      !CR_DATA type ref to DATA
      !CR_DATA_LOG type ref to DATA
    raising
      /IDXGC/CX_UTILITY_ERROR .
  class-methods CHECK_SENDER_AUTHORIZATION
    importing
      !IS_PROCESS_STEP_KEY type /IDXGC/S_PROC_STEP_KEY
    exporting
      !ET_CHECK_RESULT type /IDXGC/T_CHECK_RESULT
    changing
      !CR_DATA type ref to DATA
      !CR_DATA_LOG type ref to DATA
    raising
      /IDXGC/CX_UTILITY_ERROR .
protected section.

  class-data GR_UTILITY_GENERIC type ref to /IDXGL/CL_UTILITY_GENERIC .
private section.

  class-data GV_MSGTXT type STRING .
  class-data GX_PREVIOUS type ref to CX_ROOT .
ENDCLASS.



CLASS /ADZ/CL_MDC_CHECK_METHOD_APRK IMPLEMENTATION.


  METHOD check_pod_malo_exist.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R, ECHOUAIBI-I                                                   Datum: 04.11.2019
*
* Beschreibung: Prüfung ob Zählpunkt im System vorhanden ist und eine MaLo ist.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* THIMEL-R    30.03.2020 Methode überarbeitet
***************************************************************************************************
    DATA: lr_badi_data_access  TYPE REF TO /idxgl/badi_data_access,
          lr_process_data_step TYPE REF TO /idxgc/if_process_data_step,
          lv_is_malo           TYPE flag.

    FIELD-SYMBOLS: <lr_process_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
                   <lr_process_log>         TYPE REF TO /idxgc/if_process_log.

    ASSIGN cr_data->* TO <lr_process_data_extern>.
    ASSIGN cr_data_log->* TO <lr_process_log>.

    IF <lr_process_data_extern> IS ASSIGNED.
      lr_process_data_step ?= <lr_process_data_extern>.
    ELSE.
      MESSAGE e002(/adz/mdc_messages) INTO gv_msgtxt.
      IF <lr_process_log> IS ASSIGNED.
        <lr_process_log>->add_message_to_process_log( is_process_step_key = is_process_step_key ).
      ENDIF.
      et_check_result = VALUE #( ( /idxgc/if_constants_add=>gc_cr_error ) ).
      RETURN.
    ENDIF.

    TRY.
        DATA(ls_proc_step_data) = lr_process_data_step->get_process_step_data( is_process_step_key  = is_process_step_key ).
      CATCH /idxgc/cx_process_error INTO gx_previous.
        IF <lr_process_log> IS ASSIGNED.
          <lr_process_log>->add_message_to_process_log( is_process_step_key =  is_process_step_key ).
        ENDIF.
        et_check_result = VALUE #( ( /idxgc/if_constants_add=>gc_cr_error ) ).
        RETURN.
    ENDTRY.

    GET BADI lr_badi_data_access.

    TRY.
        LOOP AT ls_proc_step_data-pod ASSIGNING FIELD-SYMBOL(<ls_pod>).
          CALL BADI lr_badi_data_access->is_pod_malo
            EXPORTING
              iv_ext_ui      = <ls_pod>-ext_ui
              iv_key_date    = ls_proc_step_data-proc_date
            RECEIVING
              rv_pod_is_malo = lv_is_malo.
          IF lv_is_malo = abap_false.
            EXIT.
          ENDIF.
        ENDLOOP.
      CATCH /idxgc/cx_general.
        lv_is_malo = abap_false.
    ENDTRY.

    IF lv_is_malo = abap_true.
      et_check_result = VALUE #( ( 'MALO_EXIST' ) ).
    ELSE.
      et_check_result = VALUE #( ( 'MALO_NOT_EXIST' ) ).
    ENDIF.

  ENDMETHOD.


  METHOD check_receiver_authorization.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: IGOR RIVCHIN                                                            Datum: 30.03.2020
*
* Beschreibung: Prüfen, ob Empfänger über eine Berechtigung für den ZP verfügt.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    DATA: lr_process_data_step TYPE REF TO /idxgc/if_process_data_step,
          lv_check_result      TYPE /idxgc/de_check_result.

    FIELD-SYMBOLS: <lr_process_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
                   <lr_process_log>         TYPE REF TO /idxgc/if_process_log.

    ASSIGN cr_data->* TO <lr_process_data_extern>.
    ASSIGN cr_data_log->* TO <lr_process_log>.

    IF <lr_process_data_extern> IS ASSIGNED.
      lr_process_data_step ?= <lr_process_data_extern>.
    ELSE.
      MESSAGE e002(/adz/mdc_messages) INTO gv_msgtxt.
      IF <lr_process_log> IS ASSIGNED.
        <lr_process_log>->add_message_to_process_log( is_process_step_key = is_process_step_key ).
      ENDIF.
      et_check_result = VALUE #( ( /idxgc/if_constants_add=>gc_cr_error ) ).
      RETURN.
    ENDIF.

    TRY.
        DATA(ls_proc_step_data) = lr_process_data_step->get_process_step_data( is_process_step_key  = is_process_step_key ).
      CATCH /idxgc/cx_process_error INTO gx_previous.
        IF <lr_process_log> IS ASSIGNED.
          <lr_process_log>->add_message_to_process_log( is_process_step_key =  is_process_step_key ).
        ENDIF.
        et_check_result = VALUE #( ( /idxgc/if_constants_add=>gc_cr_error ) ).
        RETURN.
    ENDTRY.

    IF gr_utility_generic IS NOT BOUND.
      gr_utility_generic = /idxgl/cl_utility_generic=>get_instance( ).
    ENDIF.

    TRY.
        gr_utility_generic->check_supply_scenario( EXPORTING iv_int_ui         = ls_proc_step_data-int_ui
                                                             iv_key_date       = ls_proc_step_data-proc_date
                                                             iv_servprov       = ls_proc_step_data-own_servprov
                                                             iv_sup_direct_int = ls_proc_step_data-sup_direct_int
                                                   IMPORTING ev_check_result   = lv_check_result ).
      CATCH /idxgc/cx_process_error.
        IF <lr_process_log> IS ASSIGNED.
          <lr_process_log>->add_message_to_process_log( EXPORTING is_process_step_key =  is_process_step_key ).
        ENDIF.
        et_check_result = VALUE #( ( /idxgc/if_constants_add=>gc_cr_error ) ).
        RETURN.
    ENDTRY.

    IF lv_check_result = /idxgl/if_constants=>gc_cr_current_sp.
      et_check_result = VALUE #( ( /idxgc/if_constants_add=>gc_cr_receiver_authorized ) ).
      MESSAGE s002(/idxgc/utility_add) WITH ls_proc_step_data-ext_ui ls_proc_step_data-own_servprov INTO gv_msgtxt.
      IF <lr_process_log> IS ASSIGNED.
        <lr_process_log>->add_message_to_process_log( is_process_step_key = is_process_step_key is_business_log = /idxgc/if_constants=>gc_true ).
      ENDIF.
    ELSE.
      et_check_result = VALUE #( ( /idxgc/if_constants_add=>gc_cr_receiver_not_authorized ) ).
      MESSAGE e001(/idxgc/utility_add) WITH /idxgc/if_constants_add=>gc_rejection_code_z18 ls_proc_step_data-bmid INTO gv_msgtxt.
      IF <lr_process_log> IS ASSIGNED.
        <lr_process_log>->add_message_to_process_log( EXPORTING is_process_step_key = is_process_step_key is_business_log = /idxgc/if_constants=>gc_true ).
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD check_sender_authorization.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: IGOR RIVCHIN                                                            Datum: 30.03.2020
*
* Beschreibung: Prüfen, ob Sender über eine Berechtigung für den ZP verfügt
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    DATA: lr_process_data_step TYPE REF TO /idxgc/if_process_data_step,
          lv_check_result      TYPE /idxgc/de_check_result.

    FIELD-SYMBOLS: <lr_process_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
                   <lr_process_log>         TYPE REF TO /idxgc/if_process_log.

    ASSIGN cr_data->* TO <lr_process_data_extern>.
    ASSIGN cr_data_log->* TO <lr_process_log>.

    IF <lr_process_data_extern> IS ASSIGNED.
      lr_process_data_step ?= <lr_process_data_extern>.
    ELSE.
      MESSAGE e002(/adz/mdc_messages) INTO gv_msgtxt.
      IF <lr_process_log> IS ASSIGNED.
        <lr_process_log>->add_message_to_process_log( is_process_step_key = is_process_step_key ).
      ENDIF.
      et_check_result = VALUE #( ( /idxgc/if_constants_add=>gc_cr_error ) ).
      RETURN.
    ENDIF.

    TRY.
        DATA(ls_proc_step_data) = lr_process_data_step->get_process_step_data( is_process_step_key  = is_process_step_key ).
      CATCH /idxgc/cx_process_error INTO gx_previous.
        IF <lr_process_log> IS ASSIGNED.
          <lr_process_log>->add_message_to_process_log( is_process_step_key =  is_process_step_key ).
        ENDIF.
        et_check_result = VALUE #( ( /idxgc/if_constants_add=>gc_cr_error ) ).
        RETURN.
    ENDTRY.

    IF gr_utility_generic IS NOT BOUND.
      gr_utility_generic = /idxgl/cl_utility_generic=>get_instance( ).
    ENDIF.

    TRY.
        gr_utility_generic->check_supply_scenario( EXPORTING iv_int_ui         = ls_proc_step_data-int_ui
                                                              iv_key_date       = ls_proc_step_data-proc_date
                                                              iv_servprov       = ls_proc_step_data-assoc_servprov
                                                              iv_sup_direct_int = ls_proc_step_data-sup_direct_int
                                                    IMPORTING ev_check_result   = lv_check_result ).
      CATCH /idxgc/cx_process_error .
        IF <lr_process_log> IS ASSIGNED.
          <lr_process_log>->add_message_to_process_log( EXPORTING is_process_step_key = is_process_step_key ).
        ENDIF.
        et_check_result = VALUE #( ( /idxgc/if_constants_add=>gc_cr_error ) ).
        RETURN.
    ENDTRY.
    IF lv_check_result = /idxgl/if_constants=>gc_cr_current_sp.
      et_check_result = VALUE #( ( /idxgc/if_constants_add=>gc_cr_sender_authorized ) ).
      MESSAGE s002(/idxgc/utility_add) WITH ls_proc_step_data-ext_ui ls_proc_step_data-assoc_servprov INTO gv_msgtxt.
      IF <lr_process_log> IS ASSIGNED.
        <lr_process_log>->add_message_to_process_log( EXPORTING is_process_step_key = is_process_step_key is_business_log = /idxgc/if_constants=>gc_true ).
      ENDIF.
    ELSE.
      et_check_result = VALUE #( ( /idxgc/if_constants_add=>gc_cr_sender_not_authorized ) ).
      MESSAGE e001(/idxgc/utility_add) WITH /idxgc/if_constants_add=>gc_rejection_code_z17 ls_proc_step_data-bmid INTO gv_msgtxt.
      IF <lr_process_log> IS ASSIGNED.
        <lr_process_log>->add_message_to_process_log( EXPORTING is_process_step_key = is_process_step_key is_business_log = /idxgc/if_constants=>gc_true ).
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
