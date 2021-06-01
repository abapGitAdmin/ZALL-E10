class /ADZ/CL_MDC_CNTR definition
  public
  final
  create private .

public section.

  class-methods GET_INSTANCE
    importing
      !IR_CONT type ref to CL_GUI_CUSTOM_CONTAINER
      !IS_SELECTION type /ADZ/S_MDC_SEL
    returning
      value(RR_INSTANCE) type ref to /ADZ/CL_MDC_CNTR .
  methods START_PROCESS .
protected section.
private section.

  class-data GR_INSTANCE type ref to /ADZ/CL_MDC_CNTR .
  data GR_ALV type ref to CL_GUI_ALV_GRID .
  data GR_CONT type ref to CL_GUI_CUSTOM_CONTAINER .
  data GS_LAYOUT type LVC_S_LAYO .
  data GS_SELECTION type /ADZ/S_MDC_SEL .
  data GS_VARIANT type DISVARIANT .
  data GT_REQ type /ADZ/T_MDC_REQ .
  data GT_EXCL type UI_FUNCTIONS .
  data GT_FCAT type LVC_T_FCAT .

  methods CONSTRUCTOR
    importing
      !IS_SELECTION type /ADZ/S_MDC_SEL
      !IR_CONT type ref to CL_GUI_CUSTOM_CONTAINER .
  methods BUILD_DISPLAY_OPTIONS .
  methods BUILD_REQUESTS .
  methods BUILD_ALV .
  methods HANDLE_DOUBLE_CLICK
    for event DOUBLE_CLICK of CL_GUI_ALV_GRID
    importing
      !E_ROW
      !E_COLUMN
      !ES_ROW_NO .
ENDCLASS.



CLASS /ADZ/CL_MDC_CNTR IMPLEMENTATION.


METHOD build_alv.
************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: WISNIEWSKI-P                                 Datum: 09.08.2019
*
* Beschreibung: Einstellungen für ALV Grid, GUI Symbole und Variante
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************
  CREATE OBJECT gr_alv
    EXPORTING
      i_parent = gr_cont.

  CALL FUNCTION 'LVC_VARIANT_DEFAULT_GET'
    EXPORTING
      i_save     = 'A'
    CHANGING
      cs_variant = gs_variant
    EXCEPTIONS
      OTHERS     = 1.
  IF sy-subrc <> 0.
    gs_variant-report = /adz/if_mdc_co=>gc_structure_req.
  ENDIF.

* ALV Grid GUI Symbole ausblenden
  APPEND cl_gui_alv_grid=>mc_mb_export TO gt_excl.
  APPEND cl_gui_alv_grid=>mc_mb_subtot TO gt_excl.
  APPEND cl_gui_alv_grid=>mc_mb_sum TO gt_excl.
  APPEND cl_gui_alv_grid=>mc_mb_variant TO gt_excl.
  APPEND cl_gui_alv_grid=>mc_mb_view TO gt_excl.
  APPEND cl_gui_alv_grid=>mc_fc_graph TO gt_excl.
  APPEND cl_gui_alv_grid=>mc_fc_info TO gt_excl.
  APPEND cl_gui_alv_grid=>mc_fc_loc_cut TO gt_excl.
  APPEND cl_gui_alv_grid=>mc_fc_loc_copy_row TO gt_excl.
  APPEND cl_gui_alv_grid=>mc_fc_loc_copy TO gt_excl.
  APPEND cl_gui_alv_grid=>mc_fc_loc_paste_new_row TO  gt_excl.
  APPEND cl_gui_alv_grid=>mc_fc_loc_paste TO  gt_excl.
  APPEND cl_gui_alv_grid=>mc_fc_print TO gt_excl.
  APPEND cl_gui_alv_grid=>mc_fc_refresh TO gt_excl.

  SET HANDLER me->handle_double_click FOR me->gr_alv.

  CALL METHOD gr_alv->set_table_for_first_display
    EXPORTING
      i_bypassing_buffer   = 'X'
      is_variant           = gs_variant
      i_save               = 'X'
      it_toolbar_excluding = gt_excl
      is_layout            = gs_layout
    CHANGING
      it_outtab            = gt_req
      it_fieldcatalog      = gt_fcat.
ENDMETHOD.


METHOD build_display_options.
************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: WISNIEWSKI-P                                 Datum: 09.08.2019
*
* Beschreibung: Einstellungen für Layout und Feldkatalog
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************


  gs_layout-stylefname = 'STYLE'.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = /adz/if_mdc_co=>gc_structure_req
    CHANGING
      ct_fieldcat      = gt_fcat.

  LOOP AT gt_fcat ASSIGNING FIELD-SYMBOL(<ls_fcat>).
    <ls_fcat>-col_opt    = 'A'. " Spaltenoptimierung
    <ls_fcat>-tech       = abap_true. " Spalte ausblenden

    CASE <ls_fcat>-fieldname. " Allgemein
      WHEN /adz/if_mdc_co=>gc_fieldname_ext_ui.
        <ls_fcat>-edit       = abap_true.
        <ls_fcat>-tech       = abap_false.
      WHEN /adz/if_mdc_co=>gc_fieldname_own_servprov.
        <ls_fcat>-edit       = abap_true.
        <ls_fcat>-tech       = abap_false.
      WHEN /adz/if_mdc_co=>gc_fieldname_assoc_servprov.
        <ls_fcat>-edit       = abap_true.
        <ls_fcat>-tech       = abap_false.
      WHEN /adz/if_mdc_co=>gc_fieldname_proc_ref.
        <ls_fcat>-tech       = abap_false.
      WHEN /adz/if_mdc_co=>gc_fieldname_proc_status_txt.
        <ls_fcat>-tech       = abap_false.
    ENDCASE.

    IF gs_selection-rb1 = abap_true. "MSB der MaLo
      CASE <ls_fcat>-fieldname.
        WHEN /adz/if_mdc_co=>gc_fieldname_trans_servprov.
          <ls_fcat>-edit       = abap_true.
          <ls_fcat>-tech       = abap_false.
        WHEN /adz/if_mdc_co=>gc_fieldname_validstart_date.
          <ls_fcat>-edit       = abap_true.
          <ls_fcat>-tech       = abap_false.
        WHEN /adz/if_mdc_co=>gc_fieldname_contr_start_date.
          <ls_fcat>-edit       = abap_true.
          <ls_fcat>-tech       = abap_false.
      ENDCASE.

    ELSEIF gs_selection-rb2 = abap_true. "Stammdatensynchronisation
      CASE <ls_fcat>-fieldname.
        WHEN /adz/if_mdc_co=>gc_fieldname_use_from_date.
          <ls_fcat>-tech = abap_false.
          <ls_fcat>-edit = abap_true.
        WHEN /adz/if_mdc_co=>gc_fieldname_use_from_time.
          <ls_fcat>-tech = abap_false.
          <ls_fcat>-edit = abap_false.
        WHEN /adz/if_mdc_co=>gc_fieldname_use_to_date.
          <ls_fcat>-tech = abap_false.
          <ls_fcat>-edit = abap_true.
        WHEN /adz/if_mdc_co=>gc_fieldname_use_to_time.
          <ls_fcat>-tech = abap_false.
          <ls_fcat>-edit = abap_false.
        WHEN /adz/if_mdc_co=>gc_fieldname_msgtransreason.
          <ls_fcat>-tech = abap_false.
          <ls_fcat>-edit = abap_true.
      ENDCASE.

    ELSEIF gs_selection-rb3 = abap_true. "Lokationsbündel
      CASE <ls_fcat>-fieldname.
        WHEN /adz/if_mdc_co=>gc_fieldname_trans_servprov.
          <ls_fcat>-edit       = abap_true.
          <ls_fcat>-tech       = abap_false.
        WHEN /adz/if_mdc_co=>gc_fieldname_validstart_date.
          <ls_fcat>-edit       = abap_true.
          <ls_fcat>-tech       = abap_false.
        WHEN /adz/if_mdc_co=>gc_fieldname_contr_start_date.
          <ls_fcat>-edit       = abap_true.
          <ls_fcat>-tech       = abap_false.
      ENDCASE.

    ELSEIF gs_selection-rb4 = abap_true. "Bila. rel. SDÄnderung
      CASE <ls_fcat>-fieldname.
        WHEN /adz/if_mdc_co=>gc_fieldname_trans_servprov.
          <ls_fcat>-edit       = abap_true.
          <ls_fcat>-tech       = abap_false.
        WHEN /adz/if_mdc_co=>gc_fieldname_validstart_date.
          <ls_fcat>-edit       = abap_true.
          <ls_fcat>-tech       = abap_false.
        WHEN /adz/if_mdc_co=>gc_fieldname_contr_start_date.
          <ls_fcat>-edit       = abap_true.
          <ls_fcat>-tech       = abap_false.
      ENDCASE.

    ELSEIF gs_selection-rb5 = abap_true. "Beendigung der Aggregationsverantwortung
      CASE <ls_fcat>-fieldname.
        WHEN /adz/if_mdc_co=>gc_fieldname_use_from_date.
          <ls_fcat>-tech = abap_false.
          <ls_fcat>-edit = abap_false.
        WHEN /adz/if_mdc_co=>gc_fieldname_use_from_time.
          <ls_fcat>-tech = abap_false.
          <ls_fcat>-edit = abap_false.
        WHEN /adz/if_mdc_co=>gc_fieldname_use_to_date.
          <ls_fcat>-tech = abap_false.
          <ls_fcat>-edit = abap_true.
        WHEN /adz/if_mdc_co=>gc_fieldname_use_to_time.
          <ls_fcat>-tech = abap_false.
          <ls_fcat>-edit = abap_false.
        WHEN /adz/if_mdc_co=>gc_fieldname_msgtransreason.
          <ls_fcat>-tech = abap_false.
          <ls_fcat>-edit = abap_false.
      ENDCASE.

    ELSEIF gs_selection-rb6 = abap_true.                                               "Taha   bis
      CASE <ls_fcat>-fieldname.
        WHEN /adz/if_mdc_co=>gc_fieldname_use_from_date.
          <ls_fcat>-tech = abap_false.
          <ls_fcat>-edit = abap_false.
        WHEN /adz/if_mdc_co=>gc_fieldname_use_from_time.
          <ls_fcat>-tech = abap_false.
          <ls_fcat>-edit = abap_false.
        WHEN /adz/if_mdc_co=>gc_fieldname_use_to_date.
          <ls_fcat>-tech = abap_false.
          <ls_fcat>-edit = abap_true.
        WHEN /adz/if_mdc_co=>gc_fieldname_use_to_time.
          <ls_fcat>-tech = abap_false.
          <ls_fcat>-edit = abap_false.
        WHEN /adz/if_mdc_co=>gc_fieldname_msgtransreason.
          <ls_fcat>-tech = abap_false.
          <ls_fcat>-edit = abap_false.
      ENDCASE.
    ENDIF.                                                                            "Taha
  ENDLOOP.
ENDMETHOD.


METHOD build_requests.
***************************************************************************************************
*            _                        _____ ______
*           | |                      / ____|  ____|
*   __ _  __| | ___  ___ ___  ___   | (___ | |__
*  / _` |/ _` |/ _ \/ __/ __|/ _ \   \___ \|  __|
* | (_| | (_| |  __/\__ \__ \ (_) |  ____) | |____
*  \__,_|\__,_|\___||___/___/\___/  |_____/|______|
*
* Author: WISNIEWSKI-P                                                            Datum: 09.08.2019
*
* Beschreibung: Aufbau der Einträge in der ALV-Anzeige auf Basis der Selektions-Parameter
*
***************************************************************************************************
* Wichtige / Große Änderungen:
* Nutzer      Datum      Beschreibung
* RIVCHIN-I   06.11.2019 Anpassung Stammdatensynchronisation & MSB der MaLo
* RIVCHIN-I   26.11.2019 Erstellung Lokationsbündel
* THIMEL R    07.05.2020 Anpassung Selektion Serviceprovider
***************************************************************************************************
  DATA: lr_badi_data_access     TYPE REF TO /idxgl/badi_data_access,
        lt_servprov_details     TYPE /idxgc/t_servprov_details,
        lt_servprov_details_mso TYPE /idxgc/t_servprov_details,
        lt_servprov_details_sup TYPE /idxgc/t_servprov_details,
        lt_euitrans             TYPE TABLE OF euitrans,
        lt_pod_bundle           TYPE int_ui_table.

  FIELD-SYMBOLS: <ls_servprov_details_mso> TYPE /idxgc/s_servprov_details,
                 <ls_req>                  TYPE /adz/s_mdc_req.


  IF gs_selection-ext_ui IS NOT INITIAL.

    "Zu der Selektion alle MaLos holen
    SELECT * FROM euitrans INTO TABLE @DATA(lt_euitrans_db)
      WHERE ext_ui IN @gs_selection-ext_ui AND datefrom <= @gs_selection-keydate AND dateto >= @gs_selection-keydate.

    LOOP AT lt_euitrans_db ASSIGNING FIELD-SYMBOL(<ls_euitrans_db>).
      TRY.
          GET BADI lr_badi_data_access.
          CALL BADI lr_badi_data_access->is_pod_malo
            EXPORTING
              iv_int_ui      = <ls_euitrans_db>-int_ui
            RECEIVING
              rv_pod_is_malo = DATA(lv_pod_is_malo).
          IF lv_pod_is_malo = abap_true.
            IF gs_selection-rb3 <> abap_true.
              lt_euitrans = VALUE #( BASE lt_euitrans ( <ls_euitrans_db> ) ).
            ENDIF.
          ELSE. "MaLo aus der MeLo machen
            IF gs_selection-rb3 <> abap_true.
              CALL BADI lr_badi_data_access->get_pod_malo_melo
                EXPORTING
                  iv_int_ui             = <ls_euitrans_db>-int_ui
                IMPORTING
                  et_euitrans_malo_melo = DATA(lt_euitrans_malo_melo).
              LOOP AT lt_euitrans_malo_melo ASSIGNING FIELD-SYMBOL(<ls_euitrans_malo_melo>).
                lt_euitrans = VALUE #( BASE lt_euitrans ( int_ui = <ls_euitrans_malo_melo>-int_ui_malo ext_ui = <ls_euitrans_malo_melo>-ext_ui ) ).
              ENDLOOP.
            ELSE.
              lt_euitrans = VALUE #( BASE lt_euitrans ( <ls_euitrans_db> ) ). "nur MeLo
            ENDIF.
          ENDIF.
        CATCH cx_badi_multiply_implemented cx_badi_not_implemented /idxgc/cx_general.
      ENDTRY.

      SORT lt_euitrans BY int_ui.
      DELETE ADJACENT DUPLICATES FROM lt_euitrans COMPARING int_ui.
    ENDLOOP.

    IF lt_euitrans IS INITIAL.
      APPEND INITIAL LINE TO gt_req ASSIGNING <ls_req>.
    ENDIF.

    LOOP AT lt_euitrans ASSIGNING FIELD-SYMBOL(<ls_euitrans>).

      TRY.
          /idxgc/cl_utility_isu_add=>get_servprov_onpod( EXPORTING iv_int_ui           = <ls_euitrans>-int_ui
                                                                   iv_keydate          = gs_selection-keydate
                                                         IMPORTING et_servprov_details = lt_servprov_details ).
          DATA(lr_pod_rel) = NEW /idxgc/cl_pod_rel_checks( iv_int_ui = <ls_euitrans>-int_ui iv_key_date = gs_selection-keydate ).
        CATCH /idxgc/cx_utility_error.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDTRY.

      TRY.
          IF /adz/cl_mdc_utility=>get_division_cat( iv_int_ui = <ls_euitrans>-int_ui ) = /idxgc/if_constants=>gc_divcat_elec.

***** RB1: Zugeordnete Marktpartner ***************************************************************
            IF gs_selection-rb1 = abap_true.

              IF line_exists( lt_servprov_details[ service_cat = /adz/if_mdc_co=>gc_intcode-sup_02 ] ).
                lt_servprov_details_sup = VALUE #( FOR <x> IN lt_servprov_details WHERE ( service_cat = /adz/if_mdc_co=>gc_intcode-sup_02 ) ( <x> ) ).
              ENDIF.
              IF line_exists( lt_servprov_details[ service_cat = /adz/if_mdc_co=>gc_intcode-mso_m1 ] ).
                lt_servprov_details_mso = VALUE #( FOR <x> IN lt_servprov_details WHERE ( service_cat = /adz/if_mdc_co=>gc_intcode-mso_m1 ) ( <x> ) ).
              ENDIF.

              "SDÄ an Lieferant alt & neu
              LOOP AT lt_servprov_details_sup ASSIGNING FIELD-SYMBOL(<ls_servprov_details_sup>).
                IF NOT lr_pod_rel->is_tranche( ). "Bei Tranche wird nur das SEQ+Z15 mitgeschickt. Das wäre für Lieferanten leer (= keine zugeordneten Marktpartner).
                  APPEND INITIAL LINE TO gt_req ASSIGNING <ls_req>.
                  <ls_req>-ext_ui = <ls_euitrans>-ext_ui.
                  <ls_req>-int_ui = <ls_euitrans>-int_ui.
                  <ls_req>-assoc_servprov = <ls_servprov_details_sup>-service_id.
                  <ls_req>-own_servprov = lt_servprov_details[ service_cat = /adz/if_mdc_co=>gc_intcode-dso_01 ]-service_id.

                  IF <ls_servprov_details_sup>-date_from <= gs_selection-keydate.
                    <ls_req>-validstart_date = gs_selection-keydate.
                    IF <ls_servprov_details_sup>-date_from <= sy-datum.
                      <ls_req>-contr_start_date = gs_selection-keydate.
                    ELSE.
                      <ls_req>-contr_start_date = <ls_servprov_details_mso>-date_from.
                    ENDIF.
                  ELSE.
                    <ls_req>-validstart_date = <ls_servprov_details_sup>-date_from.
                    <ls_req>-contr_start_date = <ls_servprov_details_sup>-date_from.
                  ENDIF.

                  IF lines( lt_servprov_details_mso ) = 1.
                    <ls_req>-trans_servprov = lt_servprov_details_mso[ 1 ]-service_id.
                  ELSEIF lines( lt_servprov_details_mso ) = 0.
                    MESSAGE e023(/adz/mdc_messages) INTO <ls_req>-proc_status_txt.
                  ELSE. "mehrere MSB, da mehrere Versorgungsszenarien
                    LOOP AT lt_servprov_details_mso ASSIGNING <ls_servprov_details_mso> WHERE date_from <= <ls_req>-validstart_date AND date_to >= <ls_req>-validstart_date.
                      <ls_req>-trans_servprov = <ls_servprov_details_mso>-service_id.
                    ENDLOOP.
                    IF sy-subrc <> 0.
                      MESSAGE e023(/adz/mdc_messages) INTO <ls_req>-proc_status_txt.
                    ENDIF.
                  ENDIF.
                ENDIF.

              ENDLOOP.

              "SDÄ an MSB alt & neu
              LOOP AT lt_servprov_details_mso ASSIGNING <ls_servprov_details_mso>.
                APPEND INITIAL LINE TO gt_req ASSIGNING <ls_req>.
                <ls_req>-ext_ui = <ls_euitrans>-ext_ui.
                <ls_req>-int_ui = <ls_euitrans>-int_ui.
                <ls_req>-assoc_servprov = <ls_servprov_details_mso>-service_id.
                <ls_req>-own_servprov = lt_servprov_details[ service_cat = /adz/if_mdc_co=>gc_intcode-dso_01 ]-service_id.
                <ls_req>-trans_servprov = <ls_servprov_details_mso>-service_id.
                IF <ls_servprov_details_mso>-date_from <= gs_selection-keydate.
                  <ls_req>-validstart_date = gs_selection-keydate.
                  IF <ls_servprov_details_mso>-date_from <= sy-datum. " aktueller
                    <ls_req>-contr_start_date = gs_selection-keydate.
                  ELSE. " zukünftiger
                    <ls_req>-contr_start_date = <ls_servprov_details_mso>-date_from.
                  ENDIF.
                ELSE.
                  <ls_req>-validstart_date = <ls_servprov_details_mso>-date_from.
                  <ls_req>-contr_start_date = <ls_servprov_details_mso>-date_from.
                ENDIF.
              ENDLOOP.
              SORT gt_req BY int_ui assoc_servprov validstart_date ASCENDING.
              DELETE ADJACENT DUPLICATES FROM gt_req COMPARING int_ui assoc_servprov trans_servprov. "wenn gleicher LF und MSB am POD bleiben

***** RB2: Stammdatensynchronisation **************************************************************
            ELSEIF gs_selection-rb2 = abap_true OR gs_selection-rb5 = abap_true OR gs_selection-rb6 = abap_true.  "Taha rb6 hinzugefügt. Hier möglich?

              APPEND INITIAL LINE TO gt_req ASSIGNING <ls_req>.
              <ls_req>-ext_ui         = <ls_euitrans>-ext_ui.
              <ls_req>-int_ui         = <ls_euitrans>-int_ui.

              <ls_req>-msgtransreason = gs_selection-msgtransreason.



              IF gs_selection-msgtransreason = /adz/if_mdc_co=>gc_msgtransreason-e03.
                <ls_req>-use_to_date  = gs_selection-keydate.
                <ls_req>-use_to_time  = '000000'.
              ELSE.
                <ls_req>-use_from_date  = gs_selection-keydate.
                <ls_req>-use_from_time  = '000000'.
              ENDIF.

              IF gs_selection-rb6 = abap_true.                            "Taha
                <ls_req>-use_from_date = gs_selection-keydate.            "Taha
                CLEAR <ls_req>-use_to_date.                               "Taha
              ENDIF.                                                      "Taha

              "Serviceanbieter ermitteln
              IF line_exists( lt_servprov_details[ service_cat = /adz/if_mdc_co=>gc_intcode-dso_01 ] ).
                <ls_req>-own_servprov = lt_servprov_details[ service_cat = /adz/if_mdc_co=>gc_intcode-dso_01 ]-service_id.
              ENDIF.
              IF line_exists( lt_servprov_details[ service_cat = /adz/if_mdc_co=>gc_intcode-sup_02 ] ).
                <ls_req>-assoc_servprov = lt_servprov_details[ service_cat = /adz/if_mdc_co=>gc_intcode-sup_02 ]-service_id.
              ENDIF.

              "Serviceanbieter ändern: Bei Einspeisung ohne Direktvermarktung wird vom Netzlieferant an den ÜNB verschickt.
              TRY.
                  IF /adz/cl_mdc_utility=>is_feeding_no_direct_marketing( iv_int_ui = <ls_req>-int_ui ).
                    IF line_exists( lt_servprov_details[ service_cat = /adz/if_mdc_co=>gc_intcode-sup_02 own_service = abap_true ] ).
                      <ls_req>-own_servprov = lt_servprov_details[ service_cat = /adz/if_mdc_co=>gc_intcode-sup_02 own_service = abap_true ]-service_id.
                    ELSE.
                      CLEAR: <ls_req>-own_servprov.
                    ENDIF.
                    IF line_exists( lt_servprov_details[ service_cat = /adz/if_mdc_co=>gc_intcode-tso_t1 ] ).
                      <ls_req>-assoc_servprov = lt_servprov_details[ service_cat = /adz/if_mdc_co=>gc_intcode-tso_t1 ]-service_id.
                    ELSE.
                      CLEAR: <ls_req>-assoc_servprov.
                    ENDIF.
                  ENDIF.
                CATCH /idxgc/cx_general.
                  "Bei Fehler bleiben die Serviceanbieter leer.
                  CLEAR: <ls_req>-assoc_servprov, <ls_req>-own_servprov.
              ENDTRY.

***** RB3: Lokationsbündel ************************************************************************
            ELSEIF gs_selection-rb3 = abap_true.
              lt_pod_bundle = /adz/cl_mdc_utility=>get_all_related_int_ui( EXPORTING iv_int_ui = <ls_euitrans>-int_ui ).
              LOOP AT lt_pod_bundle ASSIGNING FIELD-SYMBOL(<ls_pod_bundle>).
                TRY.
                    GET BADI lr_badi_data_access.
                    CALL BADI lr_badi_data_access->is_pod_melo
                      EXPORTING
                        iv_int_ui      = <ls_pod_bundle>
                      RECEIVING
                        rv_pod_is_melo = DATA(lv_pod_is_melo).
                    IF lv_pod_is_melo = abap_true.
                      APPEND INITIAL LINE TO gt_req ASSIGNING <ls_req>.
                      <ls_req>-int_ui =  <ls_pod_bundle>.
                      TRY.
                          <ls_req>-ext_ui = /adz/cl_mdc_masterdata=>get_ext_ui( iv_int_ui = <ls_pod_bundle> ).
                        CATCH /idxgc/cx_general.
                          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                      ENDTRY.
                      TRY.
                          /idxgc/cl_utility_isu_add=>get_servprov_onpod( EXPORTING iv_int_ui           = <ls_euitrans>-int_ui
                                                                                   iv_keydate          = gs_selection-keydate
                                                                                   iv_old              = abap_true
                                                                         IMPORTING et_servprov_details = lt_servprov_details ).
                        CATCH /idxgc/cx_utility_error.
                          "Bei Fehler bleiben die Serviceanbieter leer.
                          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                      ENDTRY.
                      IF line_exists( lt_servprov_details[ service_cat = /adz/if_mdc_co=>gc_intcode-dso_01 ] ).
                        <ls_req>-own_servprov = lt_servprov_details[ service_cat = /adz/if_mdc_co=>gc_intcode-dso_01 ]-service_id.
                      ENDIF.
                      IF line_exists( lt_servprov_details[ service_cat = /adz/if_mdc_co=>gc_intcode-mso_m1 ] ).
                        <ls_req>-assoc_servprov = lt_servprov_details[ service_cat = /adz/if_mdc_co=>gc_intcode-mso_m1 ]-service_id.
                      ENDIF.
                      IF line_exists( lt_servprov_details[ service_cat = /adz/if_mdc_co=>gc_intcode-mso_m1 ] ).
                        IF lt_servprov_details[ service_cat = /adz/if_mdc_co=>gc_intcode-mso_m1 ]-date_from <= gs_selection-keydate.
                          <ls_req>-validstart_date = gs_selection-keydate.
                          <ls_req>-contr_start_date = gs_selection-keydate.
                        ELSE. " zukünft
                          <ls_req>-contr_start_date = lt_servprov_details[ service_cat = /adz/if_mdc_co=>gc_intcode-mso_m1 ]-date_from.
                          <ls_req>-validstart_date = lt_servprov_details[ service_cat = /adz/if_mdc_co=>gc_intcode-mso_m1 ]-date_from.
                        ENDIF.
                      ENDIF.
                      <ls_req>-msgtransreason = /adz/if_mdc_co=>gc_msgtransreason-zi8." gs_selection-msgtransreason
                      "= Änderung der Lokationsbündelstruktur "ZP6 = Stilllegung des Lokationsbündels
                    ENDIF.
                  CATCH cx_badi_multiply_implemented cx_badi_not_implemented /idxgc/cx_general.
                    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                ENDTRY.
              ENDLOOP.

****** RB4: Bil. rel. SDÄnderungen ****************************************************************
            ELSEIF gs_selection-rb4 = abap_true.

              IF line_exists( lt_servprov_details[ service_cat = /adz/if_mdc_co=>gc_intcode-mso_m1 ] ).
                lt_servprov_details_mso = VALUE #( FOR <x> IN lt_servprov_details WHERE ( service_cat = /adz/if_mdc_co=>gc_intcode-mso_m1 ) ( <x> ) ).
              ELSE.
                MESSAGE e021(/adz/mdc_messages).
              ENDIF.

              "SDÄ an MSB alt & neu
              LOOP AT lt_servprov_details_mso ASSIGNING <ls_servprov_details_mso>.
                APPEND INITIAL LINE TO gt_req ASSIGNING <ls_req>.
                <ls_req>-ext_ui = <ls_euitrans>-ext_ui.
                <ls_req>-int_ui = <ls_euitrans>-int_ui.
                <ls_req>-assoc_servprov = <ls_servprov_details_mso>-service_id.
                <ls_req>-own_servprov = lt_servprov_details[ service_cat = /adz/if_mdc_co=>gc_intcode-dso_01 ]-service_id.
                <ls_req>-trans_servprov = <ls_servprov_details_mso>-service_id.
                IF <ls_servprov_details_mso>-date_from <= gs_selection-keydate.
                  <ls_req>-validstart_date = gs_selection-keydate.
                  IF <ls_servprov_details_mso>-date_from <= sy-datum. " aktueller
                    <ls_req>-contr_start_date = gs_selection-keydate.
                  ELSE. " zukünftiger
                    <ls_req>-contr_start_date = <ls_servprov_details_mso>-date_from.
                  ENDIF.
                ELSE.
                  <ls_req>-validstart_date  = <ls_servprov_details_mso>-date_from.
                  <ls_req>-contr_start_date = <ls_servprov_details_mso>-date_from.
                ENDIF.
              ENDLOOP.
              SORT gt_req BY int_ui assoc_servprov validstart_date ASCENDING.
              DELETE ADJACENT DUPLICATES FROM gt_req COMPARING int_ui assoc_servprov trans_servprov.

            ENDIF.

          ENDIF.
        CATCH /idxgc/cx_general.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDTRY.

    ENDLOOP.

  ELSEIF gs_selection-rb2 IS NOT INITIAL OR gs_selection-rb5 IS NOT INITIAL.
    IF gs_selection-msgtransreason = /adz/if_mdc_co=>gc_msgtransreason-e03.
      gt_req = VALUE #( ( msgtransreason = gs_selection-msgtransreason use_to_date = gs_selection-keydate use_to_time  = '000000' ) ).
    ELSE.
      gt_req = VALUE #( ( msgtransreason = gs_selection-msgtransreason use_from_date = gs_selection-keydate use_from_time  = '000000' ) ).
    ENDIF.
  ELSEIF gs_selection-rb1 IS NOT INITIAL OR gs_selection-rb3 IS NOT INITIAL OR gs_selection-rb4 IS NOT INITIAL.
    gt_req = VALUE #( ( contr_start_date = gs_selection-keydate validstart_date = gs_selection-keydate ) ).
  ENDIF.

  IF gs_selection-rb3 = abap_true.
    SORT gt_req BY ext_ui.
    DELETE ADJACENT DUPLICATES FROM gt_req COMPARING ext_ui.
  ENDIF.
ENDMETHOD.


METHOD constructor.
***************************************************************************************************
*            _                        _____ ______
*           | |                      / ____|  ____|
*   __ _  __| | ___  ___ ___  ___   | (___ | |__
*  / _` |/ _` |/ _ \/ __/ __|/ _ \   \___ \|  __|
* | (_| | (_| |  __/\__ \__ \ (_) |  ____) | |____
*  \__,_|\__,_|\___||___/___/\___/  |_____/|______|
*
* Author: WISNIEWSKI-P                                                            Datum: 09.08.2019
*
* Beschreibung:
*
***************************************************************************************************
* Wichtige / Große Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
  gs_selection = is_selection.
  gr_cont = ir_cont.

  me->build_display_options( ).
  me->build_requests( ).
  me->build_alv( ).
ENDMETHOD.


METHOD get_instance.
************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: WISNIEWSKI-P                                 Datum: 09.08.2019
*
* Beschreibung: Setzt Singleton Muster für den Controller um
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************
  IF NOT gr_instance IS BOUND.
    CREATE OBJECT gr_instance
      EXPORTING
        is_selection = is_selection
        ir_cont      = ir_cont.
  ENDIF.
  rr_instance = gr_instance.
ENDMETHOD.


METHOD handle_double_click.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: WISNIEWSKI-P                                                            Datum: 05.12.2019
*
* Beschreibung: Handle double click
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************

  DATA:
    lv_object TYPE swo_objtyp,
    lv_key    TYPE eidegenerickey,
    ls_obj    TYPE eideswtdoc_dialog_object.

  FIELD-SYMBOLS: <gs_req> TYPE /adz/s_mdc_req.

  READ TABLE me->gt_req ASSIGNING <gs_req> INDEX e_row-index.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  IF e_column-fieldname = /adz/if_mdc_co=>gc_fieldname_proc_ref.
    CHECK <gs_req>-proc_ref IS NOT INITIAL.
    lv_object = /idxgc/if_constants=>gc_object_pdoc_bor.
    lv_key    = <gs_req>-proc_ref.
    CALL FUNCTION '/IDXGC/FM_PDOC_DISPLAY_BOR'
      EXPORTING
        x_object      = lv_object
        x_key         = lv_key
        x_obj         = ls_obj
      EXCEPTIONS
        general_fault = 1
        OTHERS        = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE /idxgc/if_constants=>gc_message_type_success
              NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

ENDMETHOD.


METHOD start_process.
***************************************************************************************************
*            _                        _____ ______
*           | |                      / ____|  ____|
*   __ _  __| | ___  ___ ___  ___   | (___ | |__
*  / _` |/ _` |/ _ \/ __/ __|/ _ \   \___ \|  __|
* | (_| | (_| |  __/\__ \__ \ (_) |  ____) | |____
*  \__,_|\__,_|\___||___/___/\___/  |_____/|______|
*
* Author: WISNIEWSKI-P                                                            Datum: 12.08.2019
*
* Beschreibung: Startet mittels der Anfragendaten Prozesse
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* RIVCHIN-I   06.11.2019 Anpassung Stammdatensynchronisation & MSB der MaLo
* RIVCHIN-I   02.12.2019 Anpassung Lokationsbündel MeLo - MaLo Beziehungen
* THIMEL-R    01.03.2020 Aufruf Methode GET_ASSIGNED_TSO angepasst
* THIMEL-R    07.02.2021 Datenermittlung und Fehlerbehandlung für "Zugehörige MP" angepasst
***************************************************************************************************
  DATA: lt_check_result     TYPE /idxgc/t_check_result_final,
        lt_pod_bundle       TYPE int_ui_table,
        lt_pod_rel_tranche  TYPE TABLE OF /idxgc/pod_rel,
        lt_servprov_details TYPE /idxgc/t_servprov_details,
        lr_proc_log         TYPE REF TO /idxgc/if_process_log,
        lx_previous         TYPE REF TO /idxgc/cx_general,
        lr_badi_data_access TYPE REF TO /idxgl/badi_data_access,
        lr_badi_data_prov   TYPE REF TO /idxgl/badi_data_provision,
        ls_proc_log         TYPE /idxgc/s_pdoc_log,
        ls_proc_data        TYPE /idxgc/s_proc_data,
        ls_proc_step        TYPE /idxgc/s_proc_step_data,
        ls_style            TYPE lvc_s_styl,
        ls_eservprov_tso    TYPE eservprov,
        ls_dialog_object    TYPE eideswtdoc_dialog_object,
        lv_error_proc       TYPE flag,
        lv_service_id_sup   TYPE service_prov.

  FIELD-SYMBOLS : <ls_pod_rel_tranche> TYPE /idxgc/pod_rel.

  gr_alv->check_changed_data( ).
  LOOP AT me->gt_req ASSIGNING FIELD-SYMBOL(<ls_req>) WHERE proc_ref IS INITIAL.
    CLEAR: lr_proc_log, lt_check_result, lt_pod_bundle, lt_pod_rel_tranche,
           ls_proc_data, ls_proc_step, ls_eservprov_tso, lv_error_proc.

    TRY.
        /idxgc/cl_utility_service_isu=>get_intui_from_extui( EXPORTING iv_ext_ui = <ls_req>-ext_ui
                                                                       iv_date   = <ls_req>-use_from_date
                                                             IMPORTING rv_int_ui = <ls_req>-int_ui ).
      CATCH /idxgc/cx_utility_error INTO lx_previous.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDTRY.

    TRY.
        IF gs_selection-rb1 = abap_true OR gs_selection-rb3 = abap_true OR gs_selection-rb4 = abap_true.
          IF <ls_req>-validstart_date IS NOT INITIAL AND <ls_req>-contr_start_date IS NOT INITIAL.
            ls_proc_data-spartyp = /adz/cl_mdc_utility=>get_division_cat( iv_int_ui = <ls_req>-int_ui iv_keydate = <ls_req>-validstart_date ).
          ELSE.
            MESSAGE i042(/adz/mdc_messages) INTO <ls_req>-proc_status_txt.
            CONTINUE.
          ENDIF.
        ENDIF.
        IF gs_selection-rb2 = abap_true OR gs_selection-rb5 = abap_true OR gs_selection-rb6 = abap_true.                                                "Taha (rb6 hinzugefügt)
          IF <ls_req>-msgtransreason = /idxgc/if_constants_add=>gc_msgtransreason_e03.
            CLEAR: <ls_req>-use_from_date, <ls_req>-use_from_time.

            IF <ls_req>-use_to_date IS NOT INITIAL.
              ls_proc_data-spartyp = /adz/cl_mdc_utility=>get_division_cat( iv_int_ui = <ls_req>-int_ui iv_keydate = <ls_req>-use_to_date ).
            ELSE.
              MESSAGE i040(/adz/mdc_messages) INTO <ls_req>-proc_status_txt.
              CONTINUE.
            ENDIF.
          ELSE.
            IF <ls_req>-use_from_date IS NOT INITIAL.
              ls_proc_data-spartyp = /adz/cl_mdc_utility=>get_division_cat( iv_int_ui = <ls_req>-int_ui iv_keydate = <ls_req>-use_from_date ).
            ELSE.
              MESSAGE i041(/adz/mdc_messages) INTO <ls_req>-proc_status_txt.
              CONTINUE.
            ENDIF.

            IF <ls_req>-msgtransreason is INITIAL.
              MESSAGE i043(/adz/mdc_messages) INTO <ls_req>-proc_status_txt.
              CONTINUE.
            ENDIF.


          ENDIF.
        ENDIF.

        ls_proc_data-proc_type      = /adz/if_mdc_co=>gc_proc_type_21.
        ls_proc_data-proc_view      = /adz/if_mdc_co=>gc_proc_view_04.
        ls_proc_data-int_ui         = <ls_req>-int_ui.

        TRY.
            IF /adz/cl_mdc_utility=>get_eanl( iv_int_ui = <ls_req>-int_ui )-bezug = abap_true.
              ls_proc_data-sup_direct_int = /idxgc/if_constants_add=>gc_sup_direct_feeding.
            ELSE.
              ls_proc_data-sup_direct_int = /idxgc/if_constants_add=>gc_sup_direct_supply.
            ENDIF.
          CATCH /idxgc/cx_general.
            "Ohne Fehler weiter
        ENDTRY.

        ls_proc_step-assoc_servprov = <ls_req>-assoc_servprov.
        ls_proc_step-own_servprov   = <ls_req>-own_servprov.
        ls_proc_step-diverse        = VALUE #( ( item_id = 1 ) ).

        IF gs_selection-rb3 <> abap_true.
          ls_proc_step-pod = VALUE #( ( item_id       = 1
                                        int_ui        = ls_proc_data-int_ui
                                        ext_ui        = <ls_req>-ext_ui
                                        loc_func_qual = 172 ) ).
        ENDIF.

        IF ls_proc_data-spartyp = /idxgc/if_constants=>gc_divcat_elec. "rb4 / Bil. rel. Änderung ist auch für Gas

***** RB1: Zugeordnete Marktpartner ***************************************************************
          IF gs_selection-rb1 = abap_true.
            ls_proc_data-proc_date                     = <ls_req>-validstart_date.
            ls_proc_data-proc_id                       = /idxgc/if_constants_add=>gc_prod_id_send_mdc_res.

            ls_proc_step-diverse[ 1 ]-msgtransreason   = /adz/if_mdc_co=>gc_msgtransreason-ze7.
            ls_proc_step-diverse[ 1 ]-contr_start_date = <ls_req>-contr_start_date.
            ls_proc_step-diverse[ 1 ]-validstart_date  = <ls_req>-validstart_date.
            ls_proc_step-diverse[ 1 ]-validstart_form  = 102.

            TRY.
                /idxgc/cl_utility_isu_add=>get_servprov_onpod( EXPORTING iv_int_ui           = <ls_req>-int_ui
                                                                         iv_keydate          = <ls_req>-validstart_date "RT, 07.02.2020
                                                               IMPORTING et_servprov_details = lt_servprov_details ).
                DATA(lr_pod_rel) = NEW /idxgc/cl_pod_rel_checks( iv_int_ui = <ls_req>-int_ui iv_key_date = <ls_req>-validstart_date ).
              CATCH /idxgc/cx_utility_error.
                "Bei Fehler bleiben die Serviceanbieter leer.
                MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO <ls_req>-proc_status_txt.
                CONTINUE.
            ENDTRY.

            "In der Tabelle /IDXGL/POD_DATA muss ein leerer Eintrag erzeugt werden um das SEQ+Z01/Z15 in der Nachricht zu erzeugen.
            IF lr_pod_rel->is_tranche( ).
              ls_proc_step-/idxgl/pod_data = VALUE #( ( item_id = 1 data_type_qual = /adz/if_mdc_co=>gc_seq_action_code-z15 ) ).
            ELSE.
              ls_proc_step-/idxgl/pod_data = VALUE #( ( item_id = 1 data_type_qual = /adz/if_mdc_co=>gc_seq_action_code-z01 ) ).
            ENDIF.

            IF line_exists( lt_servprov_details[ service_cat = /adz/if_mdc_co=>gc_intcode-sup_02 service_id = <ls_req>-assoc_servprov ] ). "an LF
              IF NOT lr_pod_rel->is_tranche( ).
                ls_proc_step-bmid = /adz/if_mdc_co=>gc_bmid-ch111.
                TRY.
                    ls_eservprov_tso = /adz/cl_mdc_utility=>get_assigned_tso( iv_int_ui = <ls_req>-int_ui iv_keydate = <ls_req>-validstart_date ).

                    ls_proc_step-marketpartner_add = VALUE #( ( item_id          = 1
                                                                data_type_qual   = /adz/if_mdc_co=>gc_seq_action_code-z01
                                                                party_identifier = ls_eservprov_tso-externalid
                                                                party_func_qual  = /adz/if_mdc_co=>gc_seq_action_code-z90
                                                                serviceid        = ls_eservprov_tso-serviceid
                                                                mp_counter       = 1 )
                                                              ( item_id          = 1
                                                                data_type_qual   = /adz/if_mdc_co=>gc_seq_action_code-z01
                                                                party_identifier = /adz/cl_mdc_utility=>get_service_provider( <ls_req>-trans_servprov )-externalid
                                                                party_func_qual  = /adz/if_mdc_co=>gc_seq_action_code-z91
                                                                serviceid        = <ls_req>-trans_servprov
                                                                mp_counter       = 2 ) ).
                  CATCH /idxgc/cx_general.
                    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO <ls_req>-proc_status_txt.
                    CONTINUE.
                ENDTRY.
              ELSE.
                MESSAGE i025(/adz/mdc_messages) INTO <ls_req>-proc_status_txt.
                CONTINUE.
              ENDIF.

            ELSEIF line_exists( lt_servprov_details[ service_cat = /adz/if_mdc_co=>gc_intcode-mso_m1 service_id = <ls_req>-assoc_servprov ] ). "an MSB
              ls_proc_step-bmid = /adz/if_mdc_co=>gc_bmid-ch112.
              TRY.

                  "Bei Tranchen enthält die Nachricht an den MSB nur den Lieferant.
                  IF lr_pod_rel->is_tranche( ).

                    IF line_exists( lt_servprov_details[ service_cat = /adz/if_mdc_co=>gc_intcode-sup_02 ] ).
                      lv_service_id_sup = lt_servprov_details[ service_cat = /adz/if_mdc_co=>gc_intcode-sup_02 ]-service_id.
                      ls_proc_step-marketpartner_add = VALUE #( ( item_id          = 1
                                                                  data_type_qual   = /adz/if_mdc_co=>gc_seq_action_code-z15
                                                                  party_identifier = /adz/cl_mdc_utility=>get_service_provider( lv_service_id_sup )-externalid
                                                                  party_func_qual  = /adz/if_mdc_co=>gc_seq_action_code-z89
                                                                  serviceid        = lv_service_id_sup
                                                                  mp_counter       = 1 ) ).
                    ELSE.
                      MESSAGE i020(/adz/mdc_messages) INTO <ls_req>-proc_status_txt.
                      CONTINUE.
                    ENDIF.
                    "Bei Haupt-MaLos mit Tranchen enthält die Nachricht an den MSB nur den ÜNB und den MSB.
                  ELSEIF /adz/cl_mdc_utility=>is_feed_main_pod_with_tranche( iv_int_ui = <ls_req>-int_ui iv_keydate = <ls_req>-validstart_date ).

                    ls_eservprov_tso = /adz/cl_mdc_utility=>get_assigned_tso( iv_int_ui = <ls_req>-int_ui iv_keydate = <ls_req>-validstart_date ).
                    ls_proc_step-marketpartner_add = VALUE #( ( item_id          = 1
                                                                data_type_qual   = /adz/if_mdc_co=>gc_seq_action_code-z01
                                                                party_identifier = ls_eservprov_tso-externalid
                                                                party_func_qual  = /adz/if_mdc_co=>gc_seq_action_code-z90
                                                                serviceid        = ls_eservprov_tso-serviceid
                                                                mp_counter       = 1 )
                                                              ( item_id          = 1
                                                                data_type_qual   = /adz/if_mdc_co=>gc_seq_action_code-z01
                                                                party_identifier = /adz/cl_mdc_utility=>get_service_provider( <ls_req>-trans_servprov )-externalid
                                                                party_func_qual  = /adz/if_mdc_co=>gc_seq_action_code-z91
                                                                serviceid        = <ls_req>-trans_servprov
                                                                mp_counter       = 2 ) ).

                  ELSE.

                    IF line_exists( lt_servprov_details[ service_cat = /adz/if_mdc_co=>gc_intcode-sup_02 ] ).
                      lv_service_id_sup = lt_servprov_details[ service_cat = /adz/if_mdc_co=>gc_intcode-sup_02 ]-service_id.
                      ls_eservprov_tso  = /adz/cl_mdc_utility=>get_assigned_tso( iv_int_ui = <ls_req>-int_ui iv_keydate = <ls_req>-validstart_date ).
                      ls_proc_step-marketpartner_add = VALUE #( ( item_id          = 1
                                                                  data_type_qual   = /adz/if_mdc_co=>gc_seq_action_code-z01
                                                                  party_identifier = /adz/cl_mdc_utility=>get_service_provider( lv_service_id_sup )-externalid
                                                                  party_func_qual  = /adz/if_mdc_co=>gc_seq_action_code-z89
                                                                  serviceid        = lv_service_id_sup
                                                                  mp_counter       = 1 )
                                                                ( item_id          = 1
                                                                  data_type_qual   = /adz/if_mdc_co=>gc_seq_action_code-z01
                                                                  party_identifier = ls_eservprov_tso-externalid
                                                                  party_func_qual  = /adz/if_mdc_co=>gc_seq_action_code-z90
                                                                  serviceid        = ls_eservprov_tso-serviceid
                                                                  mp_counter       = 2 )
                                                                ( item_id          = 1
                                                                  data_type_qual   = /adz/if_mdc_co=>gc_seq_action_code-z01
                                                                  party_identifier = /adz/cl_mdc_utility=>get_service_provider( <ls_req>-trans_servprov )-externalid
                                                                  party_func_qual  = /adz/if_mdc_co=>gc_seq_action_code-z91
                                                                  serviceid        = <ls_req>-trans_servprov
                                                                  mp_counter       = 3 ) ).
                    ELSE.
                      MESSAGE i020(/adz/mdc_messages) INTO <ls_req>-proc_status_txt.
                      CONTINUE.
                    ENDIF.

                  ENDIF.

                CATCH /idxgc/cx_general.
                  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO <ls_req>-proc_status_txt.
                  CONTINUE.
              ENDTRY.

            ELSE.
              MESSAGE w022(/adz/mdc_messages) INTO <ls_req>-proc_status_txt.
              CONTINUE.
            ENDIF.

***** RB2: Stammdatensynchronisation **************************************************************
          ELSEIF gs_selection-rb2  = abap_true OR gs_selection-rb5 = abap_true.

            ls_proc_step-diverse[ 1 ]-msgtransreason = <ls_req>-msgtransreason.
            ls_proc_step-diverse[ 1 ]-use_from_date  = <ls_req>-use_from_date.
            ls_proc_step-diverse[ 1 ]-use_from_time  = <ls_req>-use_from_time.
            ls_proc_step-diverse[ 1 ]-use_to_date    = <ls_req>-use_to_date.
            ls_proc_step-diverse[ 1 ]-use_to_time    = <ls_req>-use_to_time.

            IF <ls_req>-msgtransreason = /idxgc/if_constants_add=>gc_msgtransreason_e03.
              ls_proc_data-proc_date = <ls_req>-use_to_date.
            ELSE.
              ls_proc_data-proc_date = <ls_req>-use_from_date.
            ENDIF.

            ls_proc_data-proc_id   = /adz/if_mdc_co=>gc_proc_id-mdc_sy_dso_adz8035.
            CASE <ls_req>-msgtransreason.
              WHEN /adz/if_mdc_co=>gc_msgtransreason-zp0 OR /adz/if_mdc_co=>gc_msgtransreason-zp1 OR /adz/if_mdc_co=>gc_msgtransreason-zp2.
                ls_proc_step-bmid = /adz/if_mdc_co=>gc_bmid-adz_ch185.
              WHEN /adz/if_mdc_co=>gc_msgtransreason-e03.
                ls_proc_step-bmid = /adz/if_mdc_co=>gc_bmid-adz_ch188.
            ENDCASE.
            DATA(lv_no_direct_marketing) = /adz/cl_mdc_utility=>is_feeding_no_direct_marketing( iv_int_ui = <ls_req>-int_ui ).
            IF lv_no_direct_marketing = abap_true.
              ls_proc_step-bmid = /adz/if_mdc_co=>gc_bmid-adz_ch186.
            ENDIF.

***** RB3: Lokationsbündel ************************************************************************
          ELSEIF gs_selection-rb3 = abap_true.
            ls_proc_data-proc_date                     = <ls_req>-validstart_date.
            ls_proc_data-proc_id                       = /idxgc/if_constants_add=>gc_prod_id_send_mdc_res.
            ls_proc_step-diverse[ 1 ]-msgtransreason   = <ls_req>-msgtransreason.
            ls_proc_step-diverse[ 1 ]-contr_start_date = <ls_req>-contr_start_date.
            ls_proc_step-diverse[ 1 ]-validstart_date  = <ls_req>-validstart_date.
            ls_proc_step-diverse[ 1 ]-validstart_form  = 102.
            ls_proc_step-bmid = /adz/if_mdc_co=>gc_bmid-ch181.

            lt_pod_bundle = /adz/cl_mdc_utility=>get_all_related_int_ui( EXPORTING iv_int_ui = ls_proc_data-int_ui ).
            LOOP AT lt_pod_bundle ASSIGNING FIELD-SYMBOL(<ls_pod_bundle>).
              TRY.
                  DATA(lv_ext_ui) = /adz/cl_mdc_masterdata=>get_ext_ui( iv_int_ui = <ls_pod_bundle> ).
                CATCH /idxgc/cx_general.
                  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
              ENDTRY.
              ls_proc_step-pod = VALUE #( BASE ls_proc_step-pod ( item_id       = 1
                                                                  int_ui        = <ls_pod_bundle>
                                                                  ext_ui        = lv_ext_ui
                                                                  loc_func_qual = /adz/if_mdc_co=>gc_seq_action_code-z08 ) ).

              TRY.
                  GET BADI lr_badi_data_access.
                  CALL BADI lr_badi_data_access->is_pod_melo
                    EXPORTING
                      iv_int_ui      = <ls_pod_bundle>
                    RECEIVING
                      rv_pod_is_melo = DATA(lv_pod_is_melo).
                  IF lv_pod_is_melo = abap_true.
                    "check Anzahl MeLo
                    SELECT * FROM /idxgc/pod_rel INTO TABLE @DATA(lt_pod_rel) WHERE int_ui1 = @<ls_pod_bundle>.
                    CASE lines( lt_pod_rel ).
                      WHEN 0.
                        "Fehlermeldung: keine Relation
                        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                      WHEN 1.
                        TRY.
                            DATA(lv_int_ui_malo) = /adz/cl_mdc_utility=>get_malo_from_melo( EXPORTING iv_melo_int_ui = <ls_pod_bundle>
                                                                                                      iv_process_date = ls_proc_data-proc_date ).
                          CATCH /idxgc/cx_general.
                            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                        ENDTRY.
                        TRY.
                            DATA(lv_ext_ui_malo) = /adz/cl_mdc_masterdata=>get_ext_ui( EXPORTING iv_int_ui = lv_int_ui_malo ).
                          CATCH /idxgc/cx_general.
                            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                        ENDTRY.
                        ls_proc_step-/idxgl/pod_ref = VALUE #( BASE ls_proc_step-/idxgl/pod_ref ( item_id        = 1
                                                                                                  ext_ui         = lv_ext_ui
                                                                                                  ref_to_marketl = lv_ext_ui_malo
                                                                                                  ref_to_meterl  = lv_ext_ui
                                                                                                  data_type_qual = /adz/if_mdc_co=>gc_seq_action_code-z18 ) ).
                        "Tranche
                        SELECT * FROM /idxgc/pod_rel INTO TABLE @lt_pod_rel_tranche WHERE int_ui2 = @lv_int_ui_malo AND  rel_type = '2000'. "1000 = NB-Tranche -> int_ui1 = int_ui2
                        LOOP AT lt_pod_rel_tranche ASSIGNING <ls_pod_rel_tranche>.
                          TRY.
                              DATA(lv_ext_ui_malo_tranche) = /adz/cl_mdc_masterdata=>get_ext_ui( EXPORTING iv_int_ui = <ls_pod_rel_tranche>-int_ui1 ).
                            CATCH /idxgc/cx_general.
                              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                          ENDTRY.
                          ls_proc_step-/idxgl/pod_ref = VALUE #( BASE ls_proc_step-/idxgl/pod_ref ( item_id        = 1
                                                                                                    ext_ui         = lv_ext_ui_malo_tranche
                                                                                                    ref_to_marketl = lv_ext_ui_malo
                                                                                                    ref_to_meterl  = lv_ext_ui_malo_tranche
                                                                                                    data_type_qual = /adz/if_mdc_co=>gc_seq_action_code-z15 ) ).
                        ENDLOOP.
                        SORT ls_proc_step-/idxgl/pod_ref BY ext_ui ref_to_marketl ref_to_meterl.
                        DELETE ADJACENT DUPLICATES FROM ls_proc_step-/idxgl/pod_ref COMPARING item_id ext_ui ref_to_marketl ref_to_meterl data_type_qual.

                        SORT ls_proc_step-pod BY ext_ui loc_func_qual.
                        DELETE ADJACENT DUPLICATES FROM ls_proc_step-pod COMPARING item_id ext_ui loc_func_qual.

                      WHEN OTHERS. "1 MeLo - n MaLo
                        SORT lt_pod_rel BY int_ui2.
                        DELETE ADJACENT DUPLICATES FROM lt_pod_rel COMPARING int_ui2.
                        LOOP AT lt_pod_rel ASSIGNING FIELD-SYMBOL(<ls_pod_rel>).
                          CLEAR: lv_int_ui_malo, lv_ext_ui_malo, lv_ext_ui.
                          TRY.
                              lv_ext_ui = /adz/cl_mdc_masterdata=>get_ext_ui( iv_int_ui = <ls_pod_rel>-int_ui1 ).
                            CATCH /idxgc/cx_general.
                              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                          ENDTRY.
                          TRY.
                              lv_int_ui_malo = <ls_pod_rel>-int_ui2.
                            CATCH /idxgc/cx_general.
                              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                          ENDTRY.
                          TRY.
                              lv_ext_ui_malo = /adz/cl_mdc_masterdata=>get_ext_ui( EXPORTING iv_int_ui = lv_int_ui_malo ).
                            CATCH /idxgc/cx_general.
                              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                          ENDTRY.
                          ls_proc_step-/idxgl/pod_ref = VALUE #( BASE ls_proc_step-/idxgl/pod_ref ( item_id        = 1
                                                                                                    ext_ui         = lv_ext_ui
                                                                                                    ref_to_marketl = lv_ext_ui_malo
                                                                                                    ref_to_meterl  = lv_ext_ui
                                                                                                    data_type_qual = /adz/if_mdc_co=>gc_seq_action_code-z18 ) ).
                          "Tranche
                          SELECT * FROM /idxgc/pod_rel INTO TABLE @lt_pod_rel_tranche WHERE int_ui2 = @lv_int_ui_malo AND  rel_type = '2000'. "1000 = NB-Tranche -> int_ui1 = int_ui2
                          LOOP AT lt_pod_rel_tranche ASSIGNING <ls_pod_rel_tranche>.
                            TRY.
                                lv_ext_ui_malo_tranche = /adz/cl_mdc_masterdata=>get_ext_ui( EXPORTING iv_int_ui = <ls_pod_rel_tranche>-int_ui1 ).
                              CATCH /idxgc/cx_general.
                                MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                            ENDTRY.
                            ls_proc_step-/idxgl/pod_ref = VALUE #( BASE ls_proc_step-/idxgl/pod_ref ( item_id        = 1
                                                                                                      ext_ui         = lv_ext_ui_malo_tranche
                                                                                                      ref_to_marketl = lv_ext_ui_malo
                                                                                                      ref_to_meterl  = lv_ext_ui_malo_tranche
                                                                                                      data_type_qual = /adz/if_mdc_co=>gc_seq_action_code-z15 ) ).
                          ENDLOOP.
                        ENDLOOP.
                        SORT ls_proc_step-/idxgl/pod_ref BY ext_ui ref_to_marketl .
                        DELETE ADJACENT DUPLICATES FROM ls_proc_step-/idxgl/pod_ref COMPARING item_id ext_ui ref_to_marketl ref_to_meterl data_type_qual.

                        SORT ls_proc_step-pod BY ext_ui loc_func_qual.
                        DELETE ADJACENT DUPLICATES FROM ls_proc_step-pod COMPARING item_id ext_ui loc_func_qual.
                    ENDCASE.
                  ENDIF.
                CATCH cx_badi_multiply_implemented cx_badi_not_implemented /idxgc/cx_general.
                  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
              ENDTRY.
            ENDLOOP.

***** RB4: Bil. rel. SD-Änderung ******************************************************************
          ELSEIF gs_selection-rb4                      = abap_true.
            ls_proc_data-proc_date                     = <ls_req>-validstart_date.
            ls_proc_data-proc_id                       = /idxgc/if_constants_add=>gc_prod_id_send_mdc_res.
            ls_proc_step-diverse[ 1 ]-msgtransreason   = /adz/if_mdc_co=>gc_msgtransreason-zf0.
            ls_proc_step-diverse[ 1 ]-contr_start_date = <ls_req>-contr_start_date.
            ls_proc_step-diverse[ 1 ]-validstart_date  = <ls_req>-validstart_date.
            ls_proc_step-diverse[ 1 ]-validstart_form  = 102.
            ls_proc_step-bmid = /adz/if_mdc_co=>gc_bmid-ch141.




***** RB6: Marktzusammenlegung ********************************************************************                                                               Taha
          ELSEIF gs_selection-rb6 = abap_true.
            ls_proc_data-proc_date = <ls_req>-use_from_date.      " oder ?<ls_req>-contr_start_date ?<ls_req>-validstart_date
            ls_proc_data-proc_id   = /idxgc/if_constants_add=>gc_prod_id_send_mdc_res.

            ls_proc_step-diverse[ 1 ]-msgtransreason   = <ls_req>-msgtransreason.
            ls_proc_step-diverse[ 1 ]-contr_start_date = <ls_req>-contr_start_date.
            ls_proc_step-diverse[ 1 ]-validstart_date  = <ls_req>-validstart_date.
            ls_proc_step-bmid = /adz/if_mdc_co=>gc_bmid-ch131.





           ENDIF.
***** Prozessstart ********************************************************************************                                                               Taha
          ls_proc_data-steps = VALUE #( ( ls_proc_step ) ).

          TRY.
              CALL METHOD /idxgc/cl_process_trigger=>start_process
                EXPORTING
                  iv_no_commit          = /idxgc/if_constants=>gc_false
                  iv_pdoc_display       = /idxgc/if_constants=>gc_false
                IMPORTING
                  et_check_result_final = lt_check_result
                  er_process_log        = lr_proc_log
                CHANGING
                  cs_process_data       = ls_proc_data.
            CATCH /idxgc/cx_process_error .
              lv_error_proc = cl_isu_flag=>co_true.
          ENDTRY.

          IF lr_proc_log IS NOT INITIAL.
            LOOP AT lr_proc_log->gt_process_log INTO ls_proc_log WHERE msgty = /idxgc/if_constants_ide=>gc_msgty_e.
              MESSAGE ID ls_proc_log-msgid
                      TYPE ls_proc_log-msgty
                      NUMBER ls_proc_log-msgno
                      WITH ls_proc_log-msgv1 ls_proc_log-msgv2 ls_proc_log-msgv3 ls_proc_log-msgv4
                      INTO <ls_req>-proc_status_txt.
              lv_error_proc = abap_true.
              EXIT.
            ENDLOOP.
          ENDIF.

          IF lv_error_proc IS INITIAL.
            IF ls_proc_data-proc_ref IS NOT INITIAL.
              <ls_req>-proc_ref = ls_proc_data-proc_ref.
            ENDIF.

            MESSAGE s092(/idxgc/process) INTO <ls_req>-proc_status_txt.

            "Für gestartete Prozesse Felder auf nicht editierbar stellen
            LOOP AT me->gt_fcat ASSIGNING FIELD-SYMBOL(<ls_fcat>).
              ls_style-fieldname = <ls_fcat>-fieldname.
              ls_style-style     = cl_gui_alv_grid=>mc_style_disabled.
              ls_style-maxlen    = 8.
              INSERT ls_style INTO TABLE <ls_req>-style.
            ENDLOOP.

          ELSE.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                    INTO <ls_req>-proc_status_txt.
          ENDIF.

        ELSE.
          MESSAGE i010(/adz/mdc_messages) INTO <ls_req>-proc_status_txt.
        ENDIF.
      CATCH /idxgc/cx_general.

        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDTRY.

  ENDLOOP.

***** PDoc anzeigen, falls es nur eins gibt *******************************************************
  IF lines( gt_req ) = 1 AND gt_req[ 1 ]-proc_ref IS NOT INITIAL.
    CALL FUNCTION '/IDXGC/FM_PDOC_DISPLAY_BOR'
      EXPORTING
        x_object      = /idxgc/if_constants=>gc_object_pdoc_bor
        x_key         = CONV eidegenerickey( gt_req[ 1 ]-proc_ref )
        x_obj         = ls_dialog_object
      EXCEPTIONS
        general_fault = 1
        OTHERS        = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE /idxgc/if_constants=>gc_message_type_success
          NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

  gr_alv->refresh_table_display( ).
ENDMETHOD.
ENDCLASS.
