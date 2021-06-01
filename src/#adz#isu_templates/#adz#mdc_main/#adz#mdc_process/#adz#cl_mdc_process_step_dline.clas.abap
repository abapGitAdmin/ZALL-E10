class /ADZ/CL_MDC_PROCESS_STEP_DLINE definition
  public
  inheriting from /IDXGL/CL_PROCESS_STEP_DLINE
  create public .

public section.
protected section.

  methods EXECUTE_DEADLINE_CREATE
    redefinition .
private section.
ENDCLASS.



CLASS /ADZ/CL_MDC_PROCESS_STEP_DLINE IMPLEMENTATION.


  METHOD execute_deadline_create.
************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: RIVCHIN-I                                      Datum: 04.11.2019
*
* Beschreibung: Frist auf die Einhaltung der
* bilanzierungsrelevante Frist überprüfen & anpassen
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************

    super->execute_deadline_create( CHANGING ct_check_result_final = ct_check_result_final
                                             cs_process_step_data = cs_process_step_data ).

*IF cs_process_step_data-PROC_ID = /adz/if_mdc_co=>gc_proc_id
*endif.
    DATA: lv_swt_period_type  TYPE e_ideswttimetype,
          lv_bilanz_deadline  TYPE datum,
          lv_process_deadline TYPE datum.

    IF cs_process_step_data-dline_timestamp IS NOT INITIAL.
      lv_swt_period_type = /adz/if_mdc_co=>gc_swt_period_type_adzmdc_s03. "1WT+14WT
      TRY.
          CALL METHOD /idxgc/cl_check_method_add=>calc_due_date
            EXPORTING
              iv_keydate         = cs_process_step_data-msg_date
              iv_swt_period_type = lv_swt_period_type
              iv_proc_type       = cs_process_step_data-proc_type
            IMPORTING
              ev_date            = lv_bilanz_deadline.
        CATCH /idxgc/cx_utility_error .
          gr_process_log->add_message_to_process_log( is_process_step_key = gs_process_step_key ).
          APPEND /idxgc/if_constants_add=>gc_cr_error TO ct_check_result_final.
          RETURN.
      ENDTRY.

      CONVERT TIME STAMP cs_process_step_data-dline_timestamp TIME ZONE sy-zonlo INTO DATE lv_process_deadline TIME DATA(lv_dline_time).
* Frist gerissen
      IF lv_process_deadline > lv_bilanz_deadline.
        CONVERT DATE sy-datum TIME sy-uzeit INTO TIME STAMP cs_process_step_data-dline_timestamp TIME ZONE sy-zonlo.
*        cs_process_step_data-dline_timestamp = sy-datum.

* in case the process step status is not set to other values set status of process step to "on-hold"
        IF cs_process_step_data-proc_step_status = if_isu_ide_switch_constants=>co_swtmsg_status_new OR
          cs_process_step_data-proc_step_status = if_isu_ide_switch_constants=>co_swtmsg_status_ok  OR
          cs_process_step_data-proc_step_status IS INITIAL.

          cs_process_step_data-proc_step_status = /idxgc/if_constants=>gc_step_status_onhold.
        ENDIF.

* Update step data container
        me->gr_process_step_data->update_process_step_data( cs_process_step_data ).

        MESSAGE i081(/idxgc/process) INTO gv_mtext WITH gs_process_step_key-proc_step_no.
        gr_process_log->add_message_to_process_log( is_process_step_key = gs_process_step_key ).
* Add activity
        me->add_activity_to_pdoc( EXPORTING is_process_step_data = cs_process_step_data ).
      ENDIF.
    ENDIF.


  "Bilanzierungsrelevante Daten:
*Start des Abrechnungsjahrs bei RLM
*Geplante Turnusablesung
*Erstmalige bzw. nächste Turnusablesung zur Netznutzungsabrechnung
*Klimazone/ Temperaturmessstelle/ Referenzmessung
*Bilanzierungsgebiet
*Normiertes Profil (Strom), Last-Profil (Gas)
*Bilanzierungsgrundlage der Marktlokation
*Verbrauchsaufteilung für temperaturabhängige Marktlokation
*Profilschar
*Fallgruppenzuordnung
*Arbeit/Leistung für tagesparameterabhängige Marktlokation
*Veranschlagte Jahresmenge gesamt
*TUM Kundenwert
*Kategorie des Zeitreihentyp
*Messtechnische Einordnung der Marktlokation
*Wahlrecht des Bilanzierungsverfahren
*Messwertübermittlungsfall der Marktlokation
*OBIS-Daten für Marktlokation und für Tranche
*Konzessionsabgabedaten
*Steuern- /Abgabeinformation
  ENDMETHOD.
ENDCLASS.
