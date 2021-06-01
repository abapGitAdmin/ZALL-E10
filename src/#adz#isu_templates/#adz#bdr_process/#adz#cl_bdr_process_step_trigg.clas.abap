class /ADZ/CL_BDR_PROCESS_STEP_TRIGG definition
  public
  inheriting from /IDXGL/CL_PROCESS_STEP_TRIGGER
  create public .

public section.

  constants GC_BDR_SETTL_REC type /IDXGC/DE_PROC_UID value '/ADZ/BDR_SETTL_REC' ##NO_TEXT.
protected section.

  methods ENHANCE_STEP_DATA
    redefinition .
  methods DETERMINE_CHILD_PROCESS_DATA
    redefinition .
private section.
ENDCLASS.



CLASS /ADZ/CL_BDR_PROCESS_STEP_TRIGG IMPLEMENTATION.


  METHOD determine_child_process_data.
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
* Beschreibung: Erweiterung der Datenermittlung für Prozess "Bestellung Änderung der Gerätekonf-
*   igruation (NB > MSB).
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* THIMEL-R    01.11.2019 Daten für Gerätekonfiguration füllen
***************************************************************************************************
    super->determine_child_process_data( EXPORTING is_process_step_data   = is_process_step_data
                                                   is_process_data_source = is_process_data_source
                                         IMPORTING es_process_data_assoc  = es_process_data_assoc ).

    CLEAR: es_process_data_assoc-int_ui.

    IF line_exists( es_process_data_assoc-steps[ 1 ] ).
      IF line_exists( is_process_step_data-pod[ 1 ] ).
        DATA(lv_ext_ui) = is_process_step_data-pod[ 1 ]-ext_ui.
        es_process_data_assoc-steps[ 1 ]-ext_ui = lv_ext_ui.
        SELECT SINGLE * FROM euitrans
          WHERE ext_ui = @lv_ext_ui AND datefrom <= @is_process_step_data-proc_date AND dateto >= @is_process_step_data-proc_date
          INTO @DATA(ls_euitrans).
      ENDIF.
      es_process_data_assoc-steps[ 1 ]-docname_code = /adz/if_bdr_co=>gc_msg_category_z31.

      IF line_exists( is_process_step_data-ord_item_add[ 1 ] ).
        TRY.
            DATA(lt_devconf) = /adz/cl_bdr_customizing=>get_devconf( iv_settl_proc  = is_process_step_data-ord_item_add[ 1 ]-settl_proc
                                                                     iv_device_conf = is_process_step_data-ord_item_add[ 1 ]-device_conf
                                                                     iv_euistrutyp  = ls_euitrans-uistrutyp
                                                                     iv_keydate     = is_process_step_data-proc_date ).
            DATA(lv_item_id) = 1.
            ASSIGN es_process_data_assoc-steps[ 1 ]-reg_code_data TO FIELD-SYMBOL(<lt_reg_code_data>).
            ASSIGN es_process_data_assoc-steps[ 1 ]-/idxgl/data_relevance TO FIELD-SYMBOL(<lt_data_relevance>).

            LOOP AT lt_devconf ASSIGNING FIELD-SYMBOL(<ls_devconf>).
              <lt_reg_code_data> = VALUE #( BASE <lt_reg_code_data> ( item_id        = lv_item_id
                                                                      reg_code       = <ls_devconf>-kennziff
                                                                      tarif_alloc    = <ls_devconf>-tarif_alloc
                                                                      cons_type      = <ls_devconf>-cons_type
                                                                      heat_consumpt  = <ls_devconf>-heat_consumpt
                                                                      appl_interrupt = <ls_devconf>-appl_interrupt ) ).
              IF <ls_devconf>-za7_z84 = abap_true.
                <lt_data_relevance> = VALUE #( BASE <lt_data_relevance> ( item_id    = lv_item_id
                                                                          data_mrrel = /idxgl/if_constants_ide=>gc_data_mrrel_za7
                                                                          data_use   = /idxgl/if_constants_ide=>gc_data_use_z84 ) ).
              ENDIF.
              IF <ls_devconf>-za7_z85 = abap_true.
                <lt_data_relevance> = VALUE #( BASE <lt_data_relevance> ( item_id    = lv_item_id
                                                                          data_mrrel = /idxgl/if_constants_ide=>gc_data_mrrel_za7
                                                                          data_use   = /idxgl/if_constants_ide=>gc_data_use_z85 ) ).
              ENDIF.
              IF <ls_devconf>-za7_z86 = abap_true.
                <lt_data_relevance> = VALUE #( BASE <lt_data_relevance> ( item_id    = lv_item_id
                                                                          data_mrrel = /idxgl/if_constants_ide=>gc_data_mrrel_za7
                                                                          data_use   = /idxgl/if_constants_ide=>gc_data_use_z86 ) ).
              ENDIF.
              IF <ls_devconf>-za7_z47 = abap_true.
                <lt_data_relevance> = VALUE #( BASE <lt_data_relevance> ( item_id    = lv_item_id
                                                                          data_mrrel = /idxgl/if_constants_ide=>gc_data_mrrel_za7
                                                                          data_use   = /idxgl/if_constants_ide=>gc_data_use_z47 ) ).
              ENDIF.
              IF <ls_devconf>-za8_z84 = abap_true.
                <lt_data_relevance> = VALUE #( BASE <lt_data_relevance> ( item_id    = lv_item_id
                                                                          data_mrrel = /idxgl/if_constants_ide=>gc_data_mrrel_za8
                                                                          data_use   = /idxgl/if_constants_ide=>gc_data_use_z84 ) ).
              ENDIF.
              IF <ls_devconf>-za8_z85 = abap_true.
                <lt_data_relevance> = VALUE #( BASE <lt_data_relevance> ( item_id    = lv_item_id
                                                                          data_mrrel = /idxgl/if_constants_ide=>gc_data_mrrel_za8
                                                                          data_use   = /idxgl/if_constants_ide=>gc_data_use_z85 ) ).
              ENDIF.
              IF <ls_devconf>-za8_z86 = abap_true.
                <lt_data_relevance> = VALUE #( BASE <lt_data_relevance> ( item_id    = lv_item_id
                                                                          data_mrrel = /idxgl/if_constants_ide=>gc_data_mrrel_za8
                                                                          data_use   = /idxgl/if_constants_ide=>gc_data_use_z86 ) ).
              ENDIF.
              IF <ls_devconf>-za8_z92 = abap_true.
                <lt_data_relevance> = VALUE #( BASE <lt_data_relevance> ( item_id    = lv_item_id
                                                                          data_mrrel = /idxgl/if_constants_ide=>gc_data_mrrel_za8
                                                                          data_use   = /idxgl/if_constants_ide=>gc_data_use_z92 ) ).
              ENDIF.
              IF <ls_devconf>-za8_z47 = abap_true.
                <lt_data_relevance> = VALUE #( BASE <lt_data_relevance> ( item_id    = lv_item_id
                                                                          data_mrrel = /idxgl/if_constants_ide=>gc_data_mrrel_za8
                                                                          data_use   = /idxgl/if_constants_ide=>gc_data_use_z47 ) ).
              ENDIF.
              IF <ls_devconf>-za9_z85 = abap_true.
                <lt_data_relevance> = VALUE #( BASE <lt_data_relevance> ( item_id    = lv_item_id
                                                                          data_mrrel = /idxgl/if_constants_ide=>gc_data_mrrel_za9
                                                                          data_use   = /idxgl/if_constants_ide=>gc_data_use_z85 ) ).
              ENDIF.

              lv_item_id = lv_item_id + 1.
            ENDLOOP.
          CATCH /idxgc/cx_general.
            "Im Prozess werden die Daten nochmal geprüft.
        ENDTRY.
      ENDIF.
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
* Author: THIMEL-R                                                                Datum: 04.03.2019
*
* Beschreibung: Erweiterung der Datenermittlung für Prozess "Bestellung Änderung der Gerätekonf-
*   igruation (NB > MSB). Es soll an alle Serviceanbieter und MeLos/MaLos in der Tabelle
*   SERVICEPROVIDER der Schrittdaten eine ORDERS geschickt werden. Hier wird ein Datensatz
*   "entnommen" und in die aktuellen Schrittdaten geschrieben. Für diesen Datensatz wird dann
*   der Prozess gestartet.
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXXX-X    XX.XX.XXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    super->enhance_step_data( EXPORTING iv_copy_complete_source   = abap_true
                                        is_process_data_src       = is_process_data_src
                                        it_process_data_assoc_src = it_process_data_assoc_src
                              CHANGING  cs_process_step_data      = cs_process_step_data ).

    IF line_exists( cs_process_step_data-serviceprovider[ 1 ] ).
      CLEAR: cs_process_step_data-bmid, cs_process_step_data-amid, cs_process_step_data-pod, cs_process_step_data-marketpartner.
      cs_process_step_data-assoc_servprov = cs_process_step_data-serviceprovider[ 1 ]-service_id.
      APPEND INITIAL LINE TO cs_process_step_data-pod ASSIGNING FIELD-SYMBOL(<ls_pod>).
      <ls_pod>-ext_ui = cs_process_step_data-serviceprovider[ 1 ]-ext_ui.
      <ls_pod>-loc_func_qual = /idxgc/if_constants_ide=>gc_loc_qual_172.

      DELETE cs_process_step_data-serviceprovider INDEX 1.
    ENDIF.

    IF lines( cs_process_step_data-serviceprovider ) > 0.
      cs_process_step_data-proc_step_values = VALUE #( ( proc_step_value = /adz/if_bdr_co=>gc_proc_value-dev_conf_proc_start ) ).
    ELSE.
      cs_process_step_data-proc_step_values = VALUE #( ( proc_step_value = /idxgc/if_constants=>gc_proc_step_value_continue ) ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
