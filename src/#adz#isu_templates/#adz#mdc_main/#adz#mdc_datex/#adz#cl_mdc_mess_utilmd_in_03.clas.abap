CLASS /adz/cl_mdc_mess_utilmd_in_03 DEFINITION
  PUBLIC
  INHERITING FROM /idxgl/cl_message_utilmd_in_03
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  PROTECTED SECTION.

    METHODS handle_reference_resp_rev
        REDEFINITION .
    METHODS set_process_date
        REDEFINITION .
    METHODS set_ext_ui_for_step
        REDEFINITION .
  PRIVATE SECTION.

    CLASS-DATA gv_msgtxt TYPE string .
    CLASS-DATA gx_previous TYPE REF TO cx_root .
ENDCLASS.



CLASS /ADZ/CL_MDC_MESS_UTILMD_IN_03 IMPLEMENTATION.


  METHOD handle_reference_resp_rev.
***************************************************************************************************
*            _                        _____ ______
*           | |                      / ____|  ____|
*   __ _  __| | ___  ___ ___  ___   | (___ | |__
*  / _` |/ _` |/ _ \/ __/ __|/ _ \   \___ \|  __|
* | (_| | (_| |  __/\__ \__ \ (_) |  ____) | |____
*  \__,_|\__,_|\___||___/___/\___/  |_____/|______|
*
* Author: THIMEL-R                                                                Datum: 29.11.2019
*
* Beschreibung: Bei der Stammdatensynchronisation ist in den Antworten nicht immer ein
*   Antwortstatus enthalten und der Absender der Antwort passt ggf. auch nicht zum Empfänger der
*   ursprünglichen Nachricht.
***************************************************************************************************
* Änderungen:
* Nutzer         Datum      Beschreibung
* THIMEL-R       24.03.2020 Nachrichten vom ÜNB haben nicht den eigentlichen Absender
* THIMEL-R       07.05.2020 Anpassung für Einspeiser (mit und ohne Direktvermarktung)
* SPASOJEVIC V   03.02.2021 Anpassung für Einspeiser mit Tranche
* THIMEL-R       11.02.2021 Anpassung für Beendigung der Aggregation vom ÜNB
***************************************************************************************************
    DATA: lx_previous                   TYPE REF TO cx_root,
          lt_servprov_details           TYPE /idxgc/t_servprov_details,
          lv_assoc_serv_prov            TYPE e_dexservprov,
          lv_flag_feed_no_direct_market TYPE boolean,
          lv_keydate                    TYPE /idxgc/de_keydate,
          lv_int_ui                     TYPE int_ui.

    FIELD-SYMBOLS: <ls_pod> TYPE /idxgc/s_pod_info_details.

    "Einfach eine Zeile einfügen, dann funktioniert der Standard.
    IF line_exists( cs_process_step_data-amid[ amid = /adz/if_mdc_co=>gc_amid-id_11186 ] ) OR
       line_exists( cs_process_step_data-amid[ amid = /adz/if_mdc_co=>gc_amid-id_11189 ] ).
      cs_process_step_data-msgrespstatus = VALUE #( ( item_id = 1 ) ).
    ENDIF.

    "Bei Antworten vom ÜNB entspricht der Empfänger im Prozess nicht dem Absender der Antwort
    IF line_exists( cs_process_step_data-amid[ amid = /adz/if_mdc_co=>gc_amid-id_11187 ] ) OR
       line_exists( cs_process_step_data-amid[ amid = /adz/if_mdc_co=>gc_amid-id_11190 ] ).
      IF lines( cs_process_step_data-diverse ) = 1 AND cs_process_step_data-diverse[ 1 ]-use_from_date IS NOT INITIAL.
        lv_keydate = cs_process_step_data-diverse[ 1 ]-use_from_date.
      ELSEIF lines( cs_process_step_data-diverse ) = 1 AND cs_process_step_data-diverse[ 1 ]-use_to_date IS NOT INITIAL.
        lv_keydate = cs_process_step_data-diverse[ 1 ]-use_to_date.
      ELSE.
        lv_keydate = sy-datum.
      ENDIF.

      TRY.
          IF lines( cs_process_step_data-pod ) = 1.
            LOOP AT cs_process_step_data-pod ASSIGNING <ls_pod>.
              IF <ls_pod>-int_ui IS INITIAL.
                <ls_pod>-int_ui = /adz/cl_mdc_utility=>get_int_ui( iv_ext_ui = <ls_pod>-ext_ui iv_keydate = lv_keydate ).
              ENDIF.
              lv_int_ui = <ls_pod>-int_ui.
              lv_flag_feed_no_direct_market = /adz/cl_mdc_utility=>is_feeding_no_direct_marketing( iv_int_ui = <ls_pod>-int_ui iv_keydate = lv_keydate ).
              IF lv_flag_feed_no_direct_market = abap_true.
                EXIT.
              ENDIF.
            ENDLOOP.
          ELSE.  " mehr als eine Malo in der Tabelle
            LOOP AT cs_process_step_data-pod ASSIGNING <ls_pod>.
              IF <ls_pod>-int_ui IS INITIAL.
                <ls_pod>-int_ui = /adz/cl_mdc_utility=>get_int_ui( iv_ext_ui = <ls_pod>-ext_ui iv_keydate = lv_keydate ).
              ENDIF.
              DATA(lr_pod_rel) = NEW /idxgc/cl_pod_rel_checks( iv_int_ui = <ls_pod>-int_ui iv_key_date = lv_keydate ).
              IF lr_pod_rel->is_tranche( ).
                lv_int_ui = <ls_pod>-int_ui.
                lv_flag_feed_no_direct_market = /adz/cl_mdc_utility=>is_feeding_no_direct_marketing( iv_int_ui = <ls_pod>-int_ui iv_keydate = lv_keydate ).
                IF lv_flag_feed_no_direct_market = abap_true.
                  EXIT.
                ENDIF.
              ENDIF.
            ENDLOOP.
          ENDIF.
        CATCH /idxgc/cx_general INTO gx_previous.
          /idxgc/cx_ide_error=>raise_ide_exception_from_msg( ir_previous = gx_previous ).
      ENDTRY.


      IF lv_flag_feed_no_direct_market = abap_false.
        lv_assoc_serv_prov = cs_process_step_data-assoc_servprov.
        CLEAR: cs_process_step_data-assoc_servprov.

        TRY.
            /idxgc/cl_utility_isu_add=>get_servprov_onpod(  EXPORTING iv_int_ui           = lv_int_ui
                                                                      iv_keydate          = lv_keydate
                                                            IMPORTING et_servprov_details = lt_servprov_details ).
          CATCH /idxgc/cx_utility_error /idxgc/cx_general INTO gx_previous.
            MESSAGE e020(/adz/mdc_messages) INTO gv_msgtxt.
            /idxgc/cx_ide_error=>raise_ide_exception_from_msg( ir_previous = gx_previous ).
        ENDTRY.
        IF line_exists( lt_servprov_details[ service_cat = /adz/if_mdc_co=>gc_intcode-sup_02 ] ).
          LOOP AT lt_servprov_details ASSIGNING FIELD-SYMBOL(<fs_servprov_details>)
            WHERE service_cat = /adz/if_mdc_co=>gc_intcode-sup_02
              AND date_from <= lv_keydate
              AND date_to   >= lv_keydate.
            cs_process_step_data-assoc_servprov = <fs_servprov_details>-service_id.
            EXIT.
          ENDLOOP.
        ENDIF.
        IF cs_process_step_data-assoc_servprov IS INITIAL.
          MESSAGE e020(/adz/mdc_messages) INTO gv_msgtxt.
          /idxgc/cx_ide_error=>raise_ide_exception_from_msg( ).
        ENDIF.
      ENDIF.
    ENDIF.

    TRY.
        super->handle_reference_resp_rev( CHANGING cs_process_step_data = cs_process_step_data ).
      CATCH /idxgc/cx_ide_error INTO lx_previous.
        "Ausnahme wird unten erzeugt.
    ENDTRY.

    IF line_exists( cs_process_step_data-amid[ amid = /adz/if_mdc_co=>gc_amid-id_11186 ] ) OR
       line_exists( cs_process_step_data-amid[ amid = /adz/if_mdc_co=>gc_amid-id_11189 ] ).
      CLEAR: cs_process_step_data-msgrespstatus.
    ENDIF.

    IF ( line_exists( cs_process_step_data-amid[ amid = /adz/if_mdc_co=>gc_amid-id_11187 ] ) OR
         line_exists( cs_process_step_data-amid[ amid = /adz/if_mdc_co=>gc_amid-id_11190 ] ) ) AND
       lv_flag_feed_no_direct_market = abap_false.
      cs_process_step_data-assoc_servprov = lv_assoc_serv_prov.
    ENDIF.

    IF lx_previous IS NOT INITIAL.
      /idxgc/cx_ide_error=>raise_ide_exception_from_msg( ir_previous = lx_previous ).
    ENDIF.

  ENDMETHOD.


  METHOD set_ext_ui_for_step.
***************************************************************************************************
*            _                        _____ ______
*           | |                      / ____|  ____|
*   __ _  __| | ___  ___ ___  ___   | (___ | |__
*  / _` |/ _` |/ _ \/ __/ __|/ _ \   \___ \|  __|
* | (_| | (_| |  __/\__ \__ \ (_) |  ____) | |____
*  \__,_|\__,_|\___||___/___/\___/  |_____/|______|
*
* Author: THIMEL-R                                                                Datum: 24.09.2020
*
* Beschreibung: Wenn mehrere Zählpunkte vorhanden sind, dann handelt es sich um eine Tranche und
*               die Tranche soll im Kopf des PDoc stehen.
***************************************************************************************************
* Wichtige / Große Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************

    FIELD-SYMBOLS: <ls_pod>               TYPE /idxgc/s_pod_info_details.

    TRY.
        super->set_ext_ui_for_step( CHANGING cs_proc_data = cs_proc_data ).
      CATCH /idxgc/cx_ide_error INTO DATA(lx_previous).
        "Ausnahme später nochmal werfen, wenn nötig
    ENDTRY.

    IF line_exists( cs_proc_data-steps[ 1 ] ) AND
       ( cs_proc_data-steps[ 1 ]-bmid = /adz/if_mdc_co=>gc_bmid-adz_ch185 OR cs_proc_data-steps[ 1 ]-bmid = /adz/if_mdc_co=>gc_bmid-adz_ch186 ) AND
       lines( cs_proc_data-steps[ 1 ]-pod ) > 1.
      TRY.
          LOOP AT cs_proc_data-steps[ 1 ]-pod ASSIGNING <ls_pod> WHERE int_ui IS INITIAL.
            <ls_pod>-int_ui = /adz/cl_mdc_utility=>get_int_ui( iv_ext_ui = <ls_pod>-ext_ui iv_keydate = cs_proc_data-steps[ 1 ]-diverse[ 1 ]-use_from_date ).
          ENDLOOP.
          LOOP AT cs_proc_data-steps[ 1 ]-pod ASSIGNING <ls_pod>.
            DATA(lr_pod_rel) = NEW /idxgc/cl_pod_rel_checks( iv_int_ui = <ls_pod>-int_ui iv_key_date = cs_proc_data-steps[ 1 ]-diverse[ 1 ]-use_from_date ).
            IF lr_pod_rel->is_tranche( ).
              cs_proc_data-steps[ 1 ]-ext_ui = <ls_pod>-ext_ui.
              RETURN.
            ENDIF.
          ENDLOOP.
        CATCH /idxgc/cx_general cx_sy_itab_line_not_found.
          "Probieren ob er aus der Schleife geflogen ist und den Eintrag nehmen, wo kein INT_UI existiert. Im Prozess wird dann eine APERAK verschickt.
          IF <ls_pod> IS ASSIGNED AND <ls_pod>-ext_ui IS NOT INITIAL.
            cs_proc_data-steps[ 1 ]-ext_ui = <ls_pod>-ext_ui.
            RETURN.
          ENDIF.
          "Sonst den ersten Eintrag nehmen.
          cs_proc_data-steps[ 1 ]-ext_ui = cs_proc_data-steps[ 1 ]-pod[ 1 ]-ext_ui.
      ENDTRY.
    ELSEIF lx_previous IS NOT INITIAL.
      lx_previous->raise_ide_exception_from_msg( ).
    ENDIF.

  ENDMETHOD.


  METHOD set_process_date.
***************************************************************************************************
*            _                        _____ ______
*           | |                      / ____|  ____|
*   __ _  __| | ___  ___ ___  ___   | (___ | |__
*  / _` |/ _` |/ _ \/ __/ __|/ _ \   \___ \|  __|
* | (_| | (_| |  __/\__ \__ \ (_) |  ____) | |____
*  \__,_|\__,_|\___||___/___/\___/  |_____/|______|
*
* Author: THIMEL-R                                                                Datum: 03.04.2020
*
* Beschreibung: Das USE_FROM_DATE oder USE_TO_DATE sollen als Prozessdatum genutzt werden.
*
***************************************************************************************************
* Wichtige / Große Änderungen:
* Nutzer      Datum      Beschreibung
* THIMEL-R    03.09.2020 Ergänzung um CH188
***************************************************************************************************

    super->set_process_date( EXPORTING iv_bmid           = iv_bmid
                                       is_proc_step_data = is_proc_step_data
                             IMPORTING ev_process_date   = ev_process_date ).

    IF iv_bmid = /adz/if_mdc_co=>gc_bmid-adz_ch185.
      IF line_exists( is_proc_step_data-diverse[ 1 ] ).
        ev_process_date = is_proc_step_data-diverse[ 1 ]-use_from_date.
      ENDIF.
    ELSEIF iv_bmid = /adz/if_mdc_co=>gc_bmid-adz_ch188.
      IF line_exists( is_proc_step_data-diverse[ 1 ] ).
        ev_process_date = is_proc_step_data-diverse[ 1 ]-use_to_date.
      ENDIF.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
