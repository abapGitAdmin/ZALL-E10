class /ADZ/CL_MDC_SY_PROCESS_TRIGGER definition
  public
  inheriting from /IDXGL/CL_MDC_PROCESS_TRIGGER
  final
  create public .

public section.
protected section.

  methods ENHANCE_CHILD_PROCESS_DATA
    redefinition .
  methods ENHANCE_STEP_DATA
    redefinition .
private section.
ENDCLASS.



CLASS /ADZ/CL_MDC_SY_PROCESS_TRIGGER IMPLEMENTATION.


   METHOD enhance_child_process_data.
***************************************************************************************************
*            _                        _____ ______
*           | |                      / ____|  ____|
*   __ _  __| | ___  ___ ___  ___   | (___ | |__
*  / _` |/ _` |/ _ \/ __/ __|/ _ \   \___ \|  __|
* | (_| | (_| |  __/\__ \__ \ (_) |  ____) | |____
*  \__,_|\__,_|\___||___/___/\___/  |_____/|______|
*
* Author: THIMEL-R                                                                Datum: 20.11.2019
*
* Beschreibung: Vorbereitung der Daten für Prozess /ADZ/8035
*
***************************************************************************************************
* Wichtige / Große Änderungen:
* Nutzer      Datum      Beschreibung
* THIMEL-R    25.09.2020 Ermittlung Transaktionsgrund ZP0 eingebaut
***************************************************************************************************
     DATA: lr_badi_data_provision TYPE REF TO /idxgl/badi_data_provision,
           lt_pod_data            TYPE /idxgl/t_pod_data_details,
           lv_msgtransreason      TYPE /idxgc/de_msgtransreason.

     CLEAR: cs_process_data_assoc-distributor, cs_process_data_assoc-service_prov_new, cs_process_data_assoc-service_prov_old.

     IF line_exists( cs_process_data_assoc-steps[ 1 ] ).
       cs_process_data_assoc-steps[ 1 ]-own_servprov   = is_process_step_data-own_servprov.
       cs_process_data_assoc-steps[ 1 ]-assoc_servprov = is_process_step_data-assoc_servprov.
       cs_process_data_assoc-steps[ 1 ]-bmid           = is_process_step_data-bmid.

       cs_process_data_assoc-steps[ 1 ]-pod            = is_process_step_data-pod.
       LOOP AT cs_process_data_assoc-steps[ 1 ]-pod ASSIGNING FIELD-SYMBOL(<ls_pod>).
         IF <ls_pod>-int_ui IS INITIAL.
           TRY.
               <ls_pod>-int_ui = /adz/cl_mdc_utility=>get_int_ui( iv_ext_ui = <ls_pod>-ext_ui iv_keydate = is_process_step_data-proc_date ).
             CATCH /idxgc/cx_general.
               "Ohne Fehler weiter
           ENDTRY.
         ENDIF.
         "Tranchen ZP muss im Header vom neuen PDoc stehen, wenn vorhanden.
         IF <ls_pod>-pod_type = /idxgc/if_constants_add=>gc_pod_type_z70 AND <ls_pod>-int_ui IS NOT INITIAL.
           cs_process_data_assoc-int_ui            = <ls_pod>-int_ui.
           cs_process_data_assoc-steps[ 1 ]-ext_ui = <ls_pod>-ext_ui.
         ENDIF.
       ENDLOOP.

       "Der Transaktionsgrund ist i.d.R. ZP1. In seltenen Fällen, wenn auf iMS umgestellt wird, kann er auch ZP0 sein.
       "Wenn in den Schrittdaten ZA9 (ÜNB) steht und am Tag vor dem Datum in der auslösenden Nachricht ZA8(NB) gesenedet würde,
       "  dann ist das hier eine Erstanmeldung mit Transaktionsgrund ZP0.
       IF line_exists( is_process_step_data-/idxgl/pod_data[ data_type_qual = /idxgl/if_constants_ide=>gc_data_type_qual_z01 ] ) AND
          is_process_step_data-/idxgl/pod_data[ data_type_qual = /idxgl/if_constants_ide=>gc_data_type_qual_z01 ]-resp_market_role = /adz/if_mdc_co=>gc_resp_market_role-za9.

         GET BADI lr_badi_data_provision.

         DATA(ls_process_data) = is_process_step_data.
         ls_process_data-proc_date = ls_process_data-proc_date - 1.
         IF line_exists( ls_process_data-diverse[ 1 ] ).
           ls_process_data-diverse[ 1 ]-use_from_date   = ls_process_data-proc_date.
           ls_process_data-diverse[ 1 ]-validstart_date = ls_process_data-proc_date.
         ENDIF.

         "Das BAdI zur Datenbereitstellung sollte die Implementierung für die Ermittlung der Verantwortlichkeit enthalten.
         "Ggf. muss das BAdI noch angepasst werden, falls es für die SDÄ-Synchronisation nicht ausgeprägt ist.
         CALL BADI lr_badi_data_provision->responsible_market_role
           EXPORTING
             is_process_data_src     = ls_process_data
             is_process_data_src_add = ls_process_data
             is_process_data         = ls_process_data
             iv_itemid               = 1
             iv_data_type_qual       = /idxgl/if_constants_ide=>gc_data_type_qual_z01
           CHANGING
             ct_pod_data             = lt_pod_data.

         IF line_exists( lt_pod_data[ 1 ] ) AND lt_pod_data[ 1 ]-resp_market_role = /idxgl/if_constants_ide=>gc_resp_market_role_za8.
           lv_msgtransreason = /adz/if_mdc_co=>gc_msgtransreason-zp0.
         ENDIF.

       ENDIF.

       IF lv_msgtransreason IS INITIAL.
         lv_msgtransreason = /adz/if_mdc_co=>gc_msgtransreason-zp1.
       ENDIF.

       IF line_exists( is_process_step_data-diverse[ 1 ] ) AND is_process_step_data-diverse[ 1 ]-use_from_date IS NOT INITIAL.
         cs_process_data_assoc-steps[ 1 ]-diverse = VALUE #( ( item_id        = 1
                                                               use_from_date  = is_process_step_data-diverse[ 1 ]-use_from_date
                                                               msgtransreason = lv_msgtransreason ) ).
         cs_process_data_assoc-proc_date = is_process_step_data-diverse[ 1 ]-use_from_date.
       ELSE.
         cs_process_data_assoc-steps[ 1 ]-diverse = VALUE #( ( item_id        = 1
                                                               use_from_date  = is_process_step_data-proc_date
                                                               msgtransreason = lv_msgtransreason ) ).
         cs_process_data_assoc-proc_date = is_process_step_data-proc_date.
       ENDIF.
     ENDIF.

     IF is_process_data_source-sup_direct_int IS NOT INITIAL.
       cs_process_data_assoc-sup_direct_int = is_process_data_source-sup_direct_int.
     ELSE.
       TRY.
           IF /adz/cl_mdc_utility=>get_eanl(  iv_int_ui = cs_process_data_assoc-int_ui iv_keydate = cs_process_data_assoc-proc_date )-bezug = abap_true.
             cs_process_data_assoc-sup_direct_int = /idxgc/if_constants_add=>gc_sup_direct_feeding.
           ELSE.
             cs_process_data_assoc-sup_direct_int = /idxgc/if_constants_add=>gc_sup_direct_supply.
           ENDIF.
         CATCH /idxgc/cx_general.
           /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
       ENDTRY.
     ENDIF.

   ENDMETHOD.


  METHOD enhance_step_data.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 20.11.2019
*
* Beschreibung: Einen Serviceanbieter aus den eigenen Daten lesen und übernehmen. Sender, Empfänger
*               und BMID setzen.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    super->enhance_step_data( EXPORTING iv_copy_complete_source   = abap_true
                                        is_process_data_src       = is_process_data_src
                                        it_process_data_assoc_src = it_process_data_assoc_src
                              CHANGING  cs_process_step_data      = cs_process_step_data ).

    IF line_exists( cs_process_step_data-serviceprovider[ 1 ] ).
      cs_process_step_data-assoc_servprov = cs_process_step_data-serviceprovider[ 1 ]-service_id.
      cs_process_step_data-bmid           = cs_process_step_data-serviceprovider[ 1 ]-contract_ref.
      cs_process_step_data-diverse        = VALUE #( ( item_id = 1 use_from_date = cs_process_step_data-serviceprovider[ 1 ]-date_from ) ).

      DELETE cs_process_step_data-serviceprovider INDEX 1.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
