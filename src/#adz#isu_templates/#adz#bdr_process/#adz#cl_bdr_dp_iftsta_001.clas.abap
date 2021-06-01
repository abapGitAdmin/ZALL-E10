class /ADZ/CL_BDR_DP_IFTSTA_001 definition
  public
  inheriting from /IDXGL/CL_DP_IFTSTA_001
  final
  create public .

public section.

  methods CNI_POINT_OF_DELIVERY
    redefinition .
  methods MESSAGE_CATEGORY
    redefinition .
  methods CNI_DOC_REJ_STATUS
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS /ADZ/CL_BDR_DP_IFTSTA_001 IMPLEMENTATION.


  METHOD cni_doc_rej_status.
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
* Beschreibung: Status bei Ablehnung füllen
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXXXX-X   TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    DATA: ls_status_info TYPE /idxgl/s_sts_info_details.

    FIELD-SYMBOLS: <ls_status_info> TYPE /idxgl/s_sts_info_details.

    TRY.
        super->cni_doc_rej_status( ).
      CATCH /idxgc/cx_process_error.
        "Kein Fehler, Prüfung erfolgt unten
    ENDTRY.

    READ TABLE sis_process_step_data-/idxgl/status_info WITH KEY item_id = siv_itemid
      status_cat_code = /adz/if_bdr_co=>gc_sts_category_code_z21 ASSIGNING <ls_status_info>.
    IF <ls_status_info> IS ASSIGNED.
      <ls_status_info>-status_code = /idxgl/if_constants_ide=>gc_sts_code_z13.
    ELSE.
      APPEND INITIAL LINE TO sis_process_step_data-/idxgl/status_info ASSIGNING <ls_status_info>.
      <ls_status_info>-item_id         = siv_itemid.
      <ls_status_info>-status_cat_code = /adz/if_bdr_co=>gc_sts_category_code_z21.
      <ls_status_info>-status_code     = /idxgl/if_constants_ide=>gc_sts_code_z13.
    ENDIF.

* Check whether Mandatory field is filled
    LOOP AT sis_process_step_data-/idxgl/status_info INTO ls_status_info
      WHERE status_cat_code = /idxgl/if_constants_ide=>gc_sts_category_code_z20 OR
            status_cat_code = /adz/if_bdr_co=>gc_sts_category_code_z21.
    ENDLOOP.
    IF sy-subrc <> 0 AND siv_mandatory_data = abap_true.
      MESSAGE e038(/idxgc/ide_add) WITH TEXT-010 INTO siv_mtext.
      CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ELSE.
      IF ls_status_info-status_code IS INITIAL AND siv_mandatory_data = abap_true.
        MESSAGE e038(/idxgc/ide_add) WITH TEXT-011 INTO siv_mtext.
        CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
      ENDIF.

      IF ls_status_info-status_cat_code = /idxgl/if_constants_ide=>gc_sts_category_code_z20 AND
         ls_status_info-status_add_info IS INITIAL AND siv_mandatory_data = abap_true.
        MESSAGE e038(/idxgc/ide_add) WITH TEXT-012 INTO siv_mtext.
        CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD cni_point_of_delivery.
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
* Beschreibung: Nachrichtenkategorie füllen
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXXXX-X   TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    DATA: ls_pod_info         TYPE /idxgc/s_pod_info_details,
          lx_error            TYPE REF TO /idxgc/cx_general,
          lr_badi_data_access TYPE REF TO /idxgl/badi_data_access,
          lv_int_ui           TYPE int_ui,
          lv_ext_ui           TYPE ext_ui.

    FIELD-SYMBOLS: <ls_pod_info_src>     TYPE /idxgc/s_pod_info_details,
                   <ls_pod_info_src_add> TYPE /idxgc/s_pod_info_details,
                   <ls_pod_info>         TYPE /idxgc/s_pod_info_details.

    TRY.
        super->cni_point_of_delivery( ).
      CATCH /idxgc/cx_process_error.
        "Kein Fehler, Prüfung erfolgt unten
    ENDTRY.

    TRY.
        GET BADI lr_badi_data_access.
        IF lr_badi_data_access IS BOUND.
          CALL BADI lr_badi_data_access->is_pod_melo
            EXPORTING
              iv_int_ui      = sis_process_step_data-int_ui
            RECEIVING
              rv_pod_is_melo = DATA(lv_pod_is_melo).
          IF lv_pod_is_melo = abap_true.
            CALL BADI lr_badi_data_access->get_pod_malo_melo
              EXPORTING
                iv_int_ui             = sis_process_step_data-int_ui
              IMPORTING
                et_euitrans_malo_melo = DATA(lt_euitrans_malo_melo).
            READ TABLE lt_euitrans_malo_melo ASSIGNING FIELD-SYMBOL(<ls_euitrans>) INDEX 1.
            IF sy-subrc = 0.
              lv_ext_ui = <ls_euitrans>-ext_ui.
              lv_int_ui = <ls_euitrans>-int_ui_malo.
            ENDIF.
          ELSE.
            lv_ext_ui = sis_process_step_data-ext_ui.
            lv_int_ui = sis_process_step_data-int_ui.
          ENDIF.
        ENDIF.
      CATCH cx_badi_not_implemented ##NO_HANDLER.
* Fallback class has been provided, this exception will not happen

      CATCH /idxgc/cx_general INTO lx_error.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ir_previous = lx_error ).
    ENDTRY.
    IF NOT ( lv_ext_ui IS INITIAL OR lv_int_ui IS INITIAL ).
      READ TABLE sis_process_step_data-pod ASSIGNING <ls_pod_info>
        WITH KEY item_id = siv_itemid
                 ext_ui  = sis_process_step_data-ext_ui.
      IF sy-subrc = 0.
        <ls_pod_info>-loc_func_qual = /idxgc/if_constants_ide=>gc_loc_qual_172.
        <ls_pod_info>-ext_ui        = lv_ext_ui.
        <ls_pod_info>-int_ui        = lv_int_ui.
      ELSE.
        ls_pod_info-item_id         = siv_itemid.
        ls_pod_info-loc_func_qual   = /idxgc/if_constants_ide=>gc_loc_qual_172.
        ls_pod_info-ext_ui          = lv_ext_ui.
        ls_pod_info-int_ui          = lv_int_ui.
        APPEND ls_pod_info TO sis_process_step_data-pod.
      ENDIF.
    ENDIF.


    IF sis_process_step_data-pod IS INITIAL AND siv_mandatory_data IS NOT INITIAL.
      MESSAGE e038(/idxgc/ide_add) WITH TEXT-002 INTO siv_mtext.
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
* Author: THIMEL-R                                                                Datum: 17.04.2019
*
* Beschreibung: Nachrichtenkategorie füllen
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXXXX-X   TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    TRY.
        super->message_category( ).
      CATCH /idxgc/cx_process_error.
        "Kein Fehler, Prüfung erfolgt unten
    ENDTRY.

    CASE siv_data_processing_mode.
      WHEN /idxgc/if_constants_add=>gc_default_processing.
        sis_process_step_data-docname_code = /adz/if_bdr_co=>gc_msg_category_z33.

      WHEN OTHERS.
    ENDCASE.

    IF sis_process_step_data-docname_code IS INITIAL.
      MESSAGE e038(/idxgc/ide_add) WITH TEXT-009 INTO siv_mtext.
      /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
