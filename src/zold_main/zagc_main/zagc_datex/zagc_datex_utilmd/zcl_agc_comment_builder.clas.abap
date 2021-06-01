class ZCL_AGC_COMMENT_BUILDER definition
  public
  final
  create public .

public section.

  class-methods GET_COMMENT_EB101
    importing
      !IS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
      !IS_PROC_DATA_SRC_ADD type /IDXGC/S_PROC_STEP_DATA_ALL
      !IS_PROC_DATA_SRC type /IDXGC/S_PROC_STEP_DATA_ALL
      !IV_DATA_FROM_ADD_SOURCE type /IDXGC/DE_DATA_FROM_ADD_SOURCE
      !IV_ITEMID type /IDXGC/DE_ITEM_ID
    returning
      value(RV_COMMENT) type /IDXGC/DE_FREE_TEXT_VALUE .
  class-methods GET_COMMENT_EB102
    importing
      !IS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
      !IS_PROC_DATA_SRC_ADD type /IDXGC/S_PROC_STEP_DATA_ALL
      !IS_PROC_DATA_SRC type /IDXGC/S_PROC_STEP_DATA_ALL
      !IV_DATA_FROM_ADD_SOURCE type /IDXGC/DE_DATA_FROM_ADD_SOURCE
      !IV_ITEMID type /IDXGC/DE_ITEM_ID
    returning
      value(RV_COMMENT) type /IDXGC/DE_FREE_TEXT_VALUE .
  class-methods GET_COMMENT_EB103
    importing
      !IS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
      !IS_PROC_DATA_SRC_ADD type /IDXGC/S_PROC_STEP_DATA_ALL
      !IS_PROC_DATA_SRC type /IDXGC/S_PROC_STEP_DATA_ALL
      !IV_DATA_FROM_ADD_SOURCE type /IDXGC/DE_DATA_FROM_ADD_SOURCE
      !IV_ITEMID type /IDXGC/DE_ITEM_ID
    returning
      value(RV_COMMENT) type /IDXGC/DE_FREE_TEXT_VALUE .
  class-methods GET_COMMENT_ES101
    importing
      !IS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
      !IS_PROC_DATA_SRC_ADD type /IDXGC/S_PROC_STEP_DATA_ALL
      !IS_PROC_DATA_SRC type /IDXGC/S_PROC_STEP_DATA_ALL
      !IV_DATA_FROM_ADD_SOURCE type /IDXGC/DE_DATA_FROM_ADD_SOURCE
      !IV_ITEMID type /IDXGC/DE_ITEM_ID
    returning
      value(RV_COMMENT) type /IDXGC/DE_FREE_TEXT_VALUE .
  class-methods GET_COMMENT_ES102
    importing
      !IS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
      !IS_PROC_DATA_SRC_ADD type /IDXGC/S_PROC_STEP_DATA_ALL
      !IS_PROC_DATA_SRC type /IDXGC/S_PROC_STEP_DATA_ALL
      !IV_DATA_FROM_ADD_SOURCE type /IDXGC/DE_DATA_FROM_ADD_SOURCE
      !IV_ITEMID type /IDXGC/DE_ITEM_ID
    returning
      value(RV_COMMENT) type /IDXGC/DE_FREE_TEXT_VALUE .
  class-methods GET_COMMENT_ES103
    importing
      !IS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
      !IS_PROC_DATA_SRC_ADD type /IDXGC/S_PROC_STEP_DATA_ALL
      !IS_PROC_DATA_SRC type /IDXGC/S_PROC_STEP_DATA_ALL
      !IV_DATA_FROM_ADD_SOURCE type /IDXGC/DE_DATA_FROM_ADD_SOURCE
      !IV_ITEMID type /IDXGC/DE_ITEM_ID
    returning
      value(RV_COMMENT) type /IDXGC/DE_FREE_TEXT_VALUE .
  class-methods GET_COMMENT_EE101
    importing
      !IS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
      !IS_PROC_DATA_SRC_ADD type /IDXGC/S_PROC_STEP_DATA_ALL
      !IS_PROC_DATA_SRC type /IDXGC/S_PROC_STEP_DATA_ALL
      !IV_DATA_FROM_ADD_SOURCE type /IDXGC/DE_DATA_FROM_ADD_SOURCE
      !IV_ITEMID type /IDXGC/DE_ITEM_ID
    returning
      value(RV_COMMENT) type /IDXGC/DE_FREE_TEXT_VALUE .
  class-methods GET_COMMENT_SONDERKUENDIGUNG
    importing
      !IS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_COMMENT) type /IDXGC/DE_FREE_TEXT_VALUE .
  class-methods GET_COMMENT_ES301
    importing
      !IS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
      !IS_PROC_DATA_SRC_ADD type /IDXGC/S_PROC_STEP_DATA_ALL
      !IS_PROC_DATA_SRC type /IDXGC/S_PROC_STEP_DATA_ALL
      !IV_DATA_FROM_ADD_SOURCE type /IDXGC/DE_DATA_FROM_ADD_SOURCE
      !IV_ITEMID type /IDXGC/DE_ITEM_ID
    returning
      value(RV_COMMENT) type /IDXGC/DE_FREE_TEXT_VALUE .
  class-methods GET_COMMENT_EC102
    importing
      !IS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
      !IS_PROC_DATA_SRC_ADD type /IDXGC/S_PROC_STEP_DATA_ALL
      !IS_PROC_DATA_SRC type /IDXGC/S_PROC_STEP_DATA_ALL
      !IV_DATA_FROM_ADD_SOURCE type /IDXGC/DE_DATA_FROM_ADD_SOURCE
      !IV_ITEMID type /IDXGC/DE_ITEM_ID
    returning
      value(RV_COMMENT) type /IDXGC/DE_FREE_TEXT_VALUE .
  class-methods GET_COMMENT_CM025
    importing
      !IS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
      !IS_PROC_DATA_SRC_ADD type /IDXGC/S_PROC_STEP_DATA_ALL
      !IS_PROC_DATA_SRC type /IDXGC/S_PROC_STEP_DATA_ALL
      !IV_DATA_FROM_ADD_SOURCE type /IDXGC/DE_DATA_FROM_ADD_SOURCE
      !IV_ITEMID type /IDXGC/DE_ITEM_ID
    returning
      value(RV_COMMENT) type /IDXGC/DE_FREE_TEXT_VALUE .
protected section.

  class-methods _GET_COMMENT_KUENDFRIST
    importing
      !IS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
      !IS_PROC_DATA_SRC_ADD type /IDXGC/S_PROC_STEP_DATA_ALL
      !IS_PROC_DATA_SRC type /IDXGC/S_PROC_STEP_DATA_ALL
      !IV_DATA_FROM_ADD_SOURCE type /IDXGC/DE_DATA_FROM_ADD_SOURCE
      !IV_ITEMID type /IDXGC/DE_ITEM_ID
    returning
      value(RV_COMMENT) type /IDXGC/DE_FREE_TEXT_VALUE .
  class-methods _GET_COMMENT_ANSWER
    importing
      !IS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_COMMENT) type /IDXGC/DE_FREE_TEXT_VALUE .
  class-methods _GET_COMMENT_FROM_TEMPLATE
    importing
      !IS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
      !IS_PROC_DATA_SRC_ADD type /IDXGC/S_PROC_STEP_DATA_ALL
      !IS_PROC_DATA_SRC type /IDXGC/S_PROC_STEP_DATA_ALL
      !IV_DATA_FROM_ADD_SOURCE type /IDXGC/DE_DATA_FROM_ADD_SOURCE
    returning
      value(RV_COMMENT) type /IDXGC/DE_FREE_TEXT_VALUE .
  class-methods _GET_COMMENT_LGZUSATZ
    importing
      !IS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_COMMENT) type /IDXGC/DE_FREE_TEXT_VALUE .
  class-methods _GET_COMMENT_GRV
    importing
      !IS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_COMMENT) type /IDXGC/DE_FREE_TEXT_VALUE .
  class-methods _GET_COMMENT_IHB
    importing
      !IS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_COMMENT) type /IDXGC/DE_FREE_TEXT_VALUE .
  class-methods _GET_COMMENT_EDD
    importing
      !IS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_COMMENT) type /IDXGC/DE_FREE_TEXT_VALUE .
  class-methods _GET_COMMENT_GENERAL
    importing
      !IS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
      !IS_PROC_DATA_SRC_ADD type /IDXGC/S_PROC_STEP_DATA_ALL
      !IS_PROC_DATA_SRC type /IDXGC/S_PROC_STEP_DATA_ALL
      !IV_DATA_FROM_ADD_SOURCE type /IDXGC/DE_DATA_FROM_ADD_SOURCE
    returning
      value(RV_COMMENT) type /IDXGC/DE_FREE_TEXT_VALUE .
  class-methods _GET_COMMENT_STORNO_EDD
    importing
      !IS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    returning
      value(RV_COMMENT) type /IDXGC/DE_FREE_TEXT_VALUE .
private section.
ENDCLASS.



CLASS ZCL_AGC_COMMENT_BUILDER IMPLEMENTATION.


  METHOD GET_COMMENT_CM025.

*   Kommentar zur Ablehnung übernehmen
    CALL METHOD zcl_agc_comment_builder=>_get_comment_answer
      EXPORTING
        is_proc_step_data = is_proc_step_data
      RECEIVING
        rv_comment        = rv_comment.

  ENDMETHOD.


  METHOD get_comment_eb101.

    DATA: lv_comment TYPE /idxgc/de_free_text_value.

*   Kommentar aus Vorlage übernehmen
    CALL METHOD zcl_agc_comment_builder=>_get_comment_from_template
      EXPORTING
        is_proc_step_data       = is_proc_step_data
        is_proc_data_src_add    = is_proc_data_src_add
        is_proc_data_src        = is_proc_data_src
        iv_data_from_add_source = iv_data_from_add_source
      RECEIVING
        rv_comment              = lv_comment.

    rv_comment = lv_comment.
    CLEAR lv_comment.

*   Lagezusatz übernehmen
    CALL METHOD zcl_agc_comment_builder=>_get_comment_lgzusatz
      EXPORTING
        is_proc_step_data = is_proc_step_data
      RECEIVING
        rv_comment        = lv_comment.

    CONCATENATE rv_comment lv_comment INTO rv_comment.
    CLEAR lv_comment.

*   GRV-Kennzeichen übernehmen
    CALL METHOD zcl_agc_comment_builder=>_get_comment_grv
      EXPORTING
        is_proc_step_data = is_proc_step_data
      RECEIVING
        rv_comment        = lv_comment.

    CONCATENATE rv_comment lv_comment INTO rv_comment.

  ENDMETHOD.


  METHOD get_comment_eb102.

    DATA lv_comment TYPE /idxgc/de_free_text_value.

*   Kommentar aus Vorlage übernehmen
    CALL METHOD zcl_agc_comment_builder=>_get_comment_from_template
      EXPORTING
        is_proc_step_data       = is_proc_step_data
        is_proc_data_src_add    = is_proc_data_src_add
        is_proc_data_src        = is_proc_data_src
        iv_data_from_add_source = iv_data_from_add_source
      RECEIVING
        rv_comment              = lv_comment.

    rv_comment = lv_comment.
    CLEAR lv_comment.

*   Kommentar zur Ablehnung übernehmen
    CALL METHOD zcl_agc_comment_builder=>_get_comment_answer
      EXPORTING
        is_proc_step_data = is_proc_step_data
      RECEIVING
        rv_comment        = lv_comment.

    CONCATENATE lv_comment rv_comment INTO rv_comment SEPARATED BY space.

  ENDMETHOD.


  METHOD GET_COMMENT_EB103.

*   Kommentar aus Vorlage übernehmen
    CALL METHOD zcl_agc_comment_builder=>_get_comment_from_template
      EXPORTING
        is_proc_step_data       = is_proc_step_data
        is_proc_data_src_add    = is_proc_data_src_add
        is_proc_data_src        = is_proc_data_src
        iv_data_from_add_source = iv_data_from_add_source
      RECEIVING
        rv_comment              = rv_comment.

  ENDMETHOD.


  METHOD get_comment_ec102.

    DATA lv_comment TYPE /idxgc/de_free_text_value.

*>>> THIMEL.R 20150310 Bei Status Z12 keine FTX Segmente mehr mitschicken.
*   Kommentar zur Kündigungsfrist bei Antwortstatus Z12 übernehmen
*    CALL METHOD zcl_agc_comment_builder=>_get_comment_kuendfrist
*      EXPORTING
*        is_proc_step_data       = is_proc_step_data
*        is_proc_data_src_add    = is_proc_data_src_add
*        is_proc_data_src        = is_proc_data_src
*        iv_data_from_add_source = iv_data_from_add_source
*        iv_itemid               = iv_itemid
*      RECEIVING
*        rv_comment              = lv_comment.
*
*    rv_comment = lv_comment.
*    CLEAR lv_comment.
*<<< THIMEL.R 20150310

*   Kommentar zur Ablehnung übernehmen
    CALL METHOD zcl_agc_comment_builder=>_get_comment_answer
      EXPORTING
        is_proc_step_data = is_proc_step_data
      RECEIVING
        rv_comment        = lv_comment.

    CONCATENATE lv_comment rv_comment INTO rv_comment SEPARATED BY space.

  ENDMETHOD.


  METHOD get_comment_ee101.

    DATA: ls_diverse TYPE /idxgc/s_diverse_details.

    READ TABLE is_proc_step_data-diverse INTO ls_diverse INDEX 1.

    CASE ls_diverse-msgtransreason.
*>>> THIMEL.R 20150331 Mantis 4822 Kommentar aus dem WB übernehmen
*      WHEN 'Z27'.  "Sperrung
*
*        CALL METHOD zcl_agc_comment_builder=>_get_comment_general
*          EXPORTING
*            is_proc_step_data       = is_proc_step_data
*            is_proc_data_src_add    = is_proc_data_src_add
*            is_proc_data_src        = is_proc_data_src
*            iv_data_from_add_source = iv_data_from_add_source
*          RECEIVING
*            rv_comment              = rv_comment.
*<<< THIMEL.R 20150331 Mantis 4822

      WHEN OTHERS.

        CALL METHOD zcl_agc_comment_builder=>get_comment_sonderkuendigung
          EXPORTING
            is_proc_step_data = is_proc_step_data
          RECEIVING
            rv_comment        = rv_comment.

    ENDCASE.

  ENDMETHOD.


  METHOD get_comment_es101.

    DATA: lv_comment TYPE /idxgc/de_free_text_value,
          ls_diverse TYPE /idxgc/s_diverse_details.

    READ TABLE is_proc_step_data-diverse INTO ls_diverse INDEX 1.

    CASE ls_diverse-msgtransreason.
      WHEN 'Z28'.  "Entsperrung

*       Kommentar für Entsperrung übernehmen
        CALL METHOD zcl_agc_comment_builder=>_get_comment_general
          EXPORTING
            is_proc_step_data       = is_proc_step_data
            is_proc_data_src_add    = is_proc_data_src_add
            is_proc_data_src        = is_proc_data_src
            iv_data_from_add_source = iv_data_from_add_source
          RECEIVING
            rv_comment              = rv_comment.

      WHEN OTHERS.

*       IHB-Kennzeichen übernehmen
        rv_comment = zcl_agc_comment_builder=>_get_comment_ihb( is_proc_step_data = is_proc_step_data ).

*       EDD-Kennzeichen übernehmen
        lv_comment = zcl_agc_comment_builder=>_get_comment_edd( is_proc_step_data = is_proc_step_data ).

        IF lv_comment IS NOT INITIAL.
          IF rv_comment IS NOT INITIAL.
            CONCATENATE rv_comment lv_comment INTO rv_comment SEPARATED BY ';'.
            CLEAR lv_comment.
          ELSE.
            rv_comment = lv_comment.
          ENDIF.
        ENDIF.

        CLEAR lv_comment.

*       GRV-Kennzeichen übernehmen
        lv_comment = zcl_agc_comment_builder=>_get_comment_grv( is_proc_step_data = is_proc_step_data ).

        IF lv_comment IS NOT INITIAL.
          IF rv_comment IS NOT INITIAL.
            CONCATENATE rv_comment lv_comment INTO rv_comment SEPARATED BY ';'.
            CLEAR lv_comment.
          ELSE.
            rv_comment = lv_comment.
          ENDIF.
        ENDIF.

    ENDCASE.

  ENDMETHOD.


  METHOD get_comment_es102.

    DATA: lv_comment     TYPE /idxgc/de_free_text_value,
          ls_diverse     TYPE /idxgc/s_diverse_details.

    READ TABLE is_proc_step_data-diverse INTO ls_diverse INDEX 1.

    CASE ls_diverse-msgtransreason.
      WHEN 'Z28'.  "Entsperrung

*       Kommentar für Entsperrung übernehmen
        CALL METHOD zcl_agc_comment_builder=>_get_comment_general
          EXPORTING
            is_proc_step_data       = is_proc_step_data
            is_proc_data_src_add    = is_proc_data_src_add
            is_proc_data_src        = is_proc_data_src
            iv_data_from_add_source = iv_data_from_add_source
          RECEIVING
            rv_comment              = lv_comment.

      WHEN OTHERS.
    ENDCASE.

    rv_comment = lv_comment.
    CLEAR lv_comment.

*   Kommentar zur Ablehnung übernehmen
    CALL METHOD zcl_agc_comment_builder=>_get_comment_answer
      EXPORTING
        is_proc_step_data = is_proc_step_data
      RECEIVING
        rv_comment        = lv_comment.

    CONCATENATE lv_comment rv_comment INTO rv_comment SEPARATED BY space.

  ENDMETHOD.


  METHOD GET_COMMENT_ES103.

    DATA: lv_comment     TYPE /idxgc/de_free_text_value,
          ls_diverse     TYPE /idxgc/s_diverse_details,
          lv_transreason TYPE /idxgc/de_msgtransreason.

    READ TABLE is_proc_step_data-diverse INTO ls_diverse INDEX 1.

    CASE ls_diverse-msgtransreason.
*>>>THIMEL.R 20150331 Mantis 4822 Kommentar aus WF übernehmen
*      WHEN 'Z28'.  "Entsperrung
*
**       Kommentar für Entsperrung übernehmen
*        CALL METHOD zcl_agc_comment_builder=>_get_comment_general
*          EXPORTING
*            is_proc_step_data       = is_proc_step_data
*            is_proc_data_src_add    = is_proc_data_src_add
*            is_proc_data_src        = is_proc_data_src
*            iv_data_from_add_source = iv_data_from_add_source
*          RECEIVING
*            rv_comment              = rv_comment.
*<<<THIMEL.R 20150331

      WHEN OTHERS.
*     sonst keine vorgangsbezogenen Kommentare übernehmen

    ENDCASE.

  ENDMETHOD.


  METHOD get_comment_es301.

    CALL METHOD zcl_agc_comment_builder=>_get_comment_storno_edd
      EXPORTING
        is_proc_step_data = is_proc_step_data
      RECEIVING
        rv_comment        = rv_comment.

  ENDMETHOD.


  METHOD GET_COMMENT_SONDERKUENDIGUNG.
* Diese Methode schreibt bei Bedarf "Sonderkündigung" in den Kommentar
* analog zum Form check_sonderkuendigung im Include LZ_LW_CONTAINERFUBASF01.

    DATA: lv_anlage      TYPE anlage,
          ls_ever        TYPE ever,
          ls_diverse     TYPE /idxgc/s_diverse_details,
          lv_transreason TYPE /idxgc/de_msgtransreason.

    READ TABLE is_proc_step_data-diverse INTO ls_diverse INDEX 1.


*--------------------------------------------------------------------*
*   Anlage besorgen
*--------------------------------------------------------------------*
    TRY.
        CALL METHOD zcl_agc_masterdata=>get_anlage
          EXPORTING
            iv_int_ui  = is_proc_step_data-int_ui
            iv_keydate = sy-datum
          RECEIVING
            rv_anlage  = lv_anlage.
      CATCH zcx_agc_masterdata .
    ENDTRY.
*--------------------------------------------------------------------*


*--------------------------------------------------------------------*
*   Vertragsdaten besorgen
*--------------------------------------------------------------------*
    TRY.
        CALL METHOD zcl_agc_masterdata=>get_ever
          EXPORTING
            iv_anlage  = lv_anlage
            iv_keydate = is_proc_step_data-proc_date
          RECEIVING
            rs_ever    = ls_ever.

*       Prüfe auf Sonderkündigung
        IF NOT  ls_ever-zzskuenddat     IS INITIAL                                               "Sonderkündigungsdatum gefüllt
          AND   ls_ever-zzskuenddat     = is_proc_step_data-proc_date                            "Sonderkündigungsdatum = Kündigungsdatum
          AND ( ls_ever-sparte          = zif_agc_datex_utilmd_co=>gc_sparte_strom               "Sparte Strom
          OR    ls_ever-sparte          = zif_agc_datex_utilmd_co=>gc_sparte_gas ).              "Sparte Gas
*>>> THIMEL.R 20150325 Mantis 4798 Transaktionsgrund entfernt, da auch bei E01 mitgeschickt werden soll.
*          AND   ls_diverse-msgtransreason = /idxgc/if_constants_ide=>GC_TRANS_REASON_CODE_E03.   "Derzeitiger Transaktionsgrund "E03"
*<<< THIMEL.R 20150325
          rv_comment             = 'SONDERKÜNDIGUNG'.

        ENDIF.

      CATCH zcx_agc_masterdata .
    ENDTRY.
*--------------------------------------------------------------------*

  ENDMETHOD.


  METHOD _get_comment_answer.

    DATA wa_eideswtmsgfield TYPE eideswtmsgfield.
    DATA l_fieldcheckid TYPE eideswtfieldcheckid.
    DATA l_ddtext TYPE dd04t-ddtext.
    DATA ls_msgrespstatus TYPE /idxgc/s_msgsts_details.

    IF is_proc_step_data-docname_code = /idxgc/if_constants_ide=>gc_msg_category_e01      "E01
    OR is_proc_step_data-docname_code = /idxgc/if_constants_ide=>gc_msg_category_e02      "E02
    OR is_proc_step_data-docname_code = /idxgc/if_constants_ide=>gc_msg_category_e35.     "E35

      READ TABLE is_proc_step_data-msgrespstatus INTO ls_msgrespstatus INDEX 1.

*     E14 - Ablehnung Sonstiges
      IF ls_msgrespstatus-respstatus = /idxgc/if_constants_ide=>gc_respstatus_e14.

        rv_comment = 'Ablehnung Sonstiges'.

*     Z07 - Ablehnung keine Berechtigung
*    (Dieser Antwortstatus wird zumindest laut Verwendungsnachweis im VNB-Workflow nicht verwendet.)
      ELSEIF ls_msgrespstatus-respstatus = /idxgc/if_constants_ide=>gc_respstatus_z07.   "'Z07'

        rv_comment = 'Entnahmestelle durch anderen Lieferanten beliefert'.

*     Alle anderen Antwortkategorien
      ELSE.

      ENDIF.

    ELSEIF is_proc_step_data-docname_code = /idxgc/if_constants_ide=>gc_msg_category_e03.     "E03

      IF ls_msgrespstatus-respstatus = /idxgc/if_constants_ide=>gc_respstatus_e14.

        rv_comment = 'Unterschiedliche Rollen für SD-Änderungen. Bitte getrennt schicken!'.

      ENDIF.

    ELSE.

    ENDIF.



  ENDMETHOD.


  METHOD _get_comment_edd.
* Diese Methode schreibt bei Bedarf das Kennzeichen EDD in den Kommentar
* analog zum Form hole_auszug im Include LZ_LW_CONTAINERFUBASF05.

    DATA: lv_ever   TYPE ever,
          lv_anlage TYPE anlage.

    FIELD-SYMBOLS <fs_proc_step_data> TYPE /idxgc/s_msgcom_details.

*--------------------------------------------------------------------*
*   Besorge die Anlage
*--------------------------------------------------------------------*
    TRY.
        CALL METHOD zcl_agc_masterdata=>get_anlage
          EXPORTING
            iv_int_ui  = is_proc_step_data-int_ui
            iv_keydate = sy-datum
          RECEIVING
            rv_anlage  = lv_anlage.
      CATCH zcx_agc_masterdata .
    ENDTRY.

*--------------------------------------------------------------------*
*   Besorge die Vertragsdaten zur Anlage
*--------------------------------------------------------------------*
    TRY.
        CALL METHOD zcl_agc_masterdata=>get_ever
          EXPORTING
            iv_anlage  = lv_anlage
            iv_keydate = is_proc_step_data-proc_date
          RECEIVING
            rs_ever    = lv_ever.

        IF lv_ever-zzgue EQ zif_agc_datex_utilmd_co=>gc_versart_edd.   "EDD
*       Es ist ein Einzug gemeldet durch Dritte, also Kennzeichen im
*       Bemerkungsfeld mitgeben.
          LOOP AT is_proc_step_data-msgcomments ASSIGNING <fs_proc_step_data> WHERE text_subj_qual = /idxgc/if_constants_ide=>gc_msg_comments_acb.

            IF <fs_proc_step_data>-free_text_value NE 'SONDERKÜNDIGUNG' AND
               <fs_proc_step_data>-free_text_value NS zif_agc_datex_utilmd_co=>gc_versart_edd.    "EDD

              rv_comment = ';EDD'.

            ENDIF.

          ENDLOOP.

          IF sy-subrc NE 0.
            rv_comment = ';EDD'.
          ENDIF.

        ENDIF.

      CATCH zcx_agc_masterdata .
    ENDTRY.

  ENDMETHOD.


  METHOD _get_comment_from_template.
* Methode  analog zum FORM hole_comment_aus_vorlage aus dem Include LZ_LW_CONTAINERFUBASF03

    DATA lt_commenttxt TYPE TABLE OF zlw_commenttxt.
    DATA lf_commenttxt TYPE zlw_commenttxt.

    FIELD-SYMBOLS:
      <fs_proc_step_data> TYPE /idxgc/s_msgcom_details,
      <fs_proc_data_src>  TYPE /idxgc/s_msgcom_details.

    READ TABLE is_proc_step_data-msgcomments ASSIGNING <fs_proc_step_data> WITH KEY text_subj_qual = /idxgc/if_constants_ide=>gc_msg_comments_acb.
    IF <fs_proc_step_data> IS ASSIGNED.
*     Bei Sonderkündigung sollen keine anderen Bemerkungstexte gezogen werden
      CHECK <fs_proc_step_data>-free_text_value NE 'SONDERKÜNDIGUNG'.
    ENDIF.

    " Abkürzungen in den Bemerkungsfeldern zu den Nachrichtendaten
    SELECT * FROM zlw_commenttxt INTO TABLE lt_commenttxt.

    " wenn Zusätzliche Quellschrittdaten vorhanden, dann diese lesen
    IF iv_data_from_add_source = /idxgc/if_constants=>gc_true.

      LOOP AT is_proc_data_src_add-msgcomments ASSIGNING <fs_proc_data_src> WHERE text_subj_qual = /idxgc/if_constants_ide=>gc_msg_comments_acb.
        LOOP AT lt_commenttxt INTO lf_commenttxt.
          IF <fs_proc_data_src>-free_text_value CS lf_commenttxt-kuerzel.
            IF <fs_proc_step_data> IS ASSIGNED.
              IF <fs_proc_step_data>-free_text_value NS lf_commenttxt-kuerzel.
                CONCATENATE <fs_proc_step_data>-free_text_value lf_commenttxt-kuerzel INTO rv_comment SEPARATED BY ';'.
              ENDIF.
            ELSE.
              CONCATENATE rv_comment lf_commenttxt-kuerzel INTO rv_comment SEPARATED BY ';'.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDLOOP.

    ELSE.

      LOOP AT is_proc_data_src-msgcomments ASSIGNING <fs_proc_data_src> WHERE text_subj_qual = /idxgc/if_constants_ide=>gc_msg_comments_acb.
        LOOP AT lt_commenttxt INTO lf_commenttxt.
          IF <fs_proc_data_src>-free_text_value CS lf_commenttxt-kuerzel.
            IF <fs_proc_step_data> IS ASSIGNED.
              IF <fs_proc_step_data>-free_text_value NS lf_commenttxt-kuerzel.
                CONCATENATE <fs_proc_step_data>-free_text_value lf_commenttxt-kuerzel INTO rv_comment SEPARATED BY ';'.
              ENDIF.
            ELSE.
              CONCATENATE rv_comment lf_commenttxt-kuerzel INTO rv_comment SEPARATED BY ';'.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDLOOP.

    ENDIF.




  ENDMETHOD.


  METHOD _get_comment_general.
* Methode ermittelt den Kommentar analog zum FORM hole_comment  aus dem Include LZ_LW_CONTAINERFUBASF01
* und schreibt diesen in das Kommentarfeld

    DATA lt_commenttxt TYPE TABLE OF zlw_commenttxt.
    DATA lf_commenttxt TYPE zlw_commenttxt.

    FIELD-SYMBOLS:
      <fs_proc_step_data> TYPE /idxgc/s_msgcom_details,
      <fs_proc_data_src>  TYPE /idxgc/s_msgcom_details.

    LOOP AT is_proc_step_data-msgcomments ASSIGNING <fs_proc_step_data> WHERE text_subj_qual = /idxgc/if_constants_ide=>gc_msg_comments_acb.

      IF <fs_proc_step_data>-free_text_value NE 'SONDERKÜNDIGUNG'.

        IF iv_data_from_add_source = /idxgc/if_constants=>gc_true.

          LOOP AT is_proc_data_src_add-msgcomments ASSIGNING <fs_proc_data_src> WHERE text_subj_qual = /idxgc/if_constants_ide=>gc_msg_comments_acb.
            rv_comment = <fs_proc_data_src>-free_text_value.
          ENDLOOP.

        ELSE.

          LOOP AT is_proc_data_src-msgcomments ASSIGNING <fs_proc_data_src> WHERE text_subj_qual = /idxgc/if_constants_ide=>gc_msg_comments_acb.
            rv_comment = <fs_proc_data_src>-free_text_value.
          ENDLOOP.

        ENDIF.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD _get_comment_grv.
* Diese Methode schreibt bei Bedarf das Kennzeichen GRV in den Kommentar
* analog zum Form hole_grv im Include LZ_LW_CONTAINERFUBASF04.

    DATA lf_ever TYPE ever.

    FIELD-SYMBOLS <fs_proc_step_data> TYPE /idxgc/s_msgcom_details.

* Vertrag besorgen
    CALL FUNCTION 'Z_LW_POD_DATA'
      EXPORTING
        x_int_ui   = is_proc_step_data-int_ui
        x_keydatum = is_proc_step_data-proc_date
      IMPORTING
        y_vertrag  = lf_ever-vertrag.

    SELECT SINGLE * FROM ever INTO lf_ever WHERE vertrag = lf_ever-vertrag.
    IF sy-subrc EQ 0.

      IF lf_ever-zzgue EQ zif_agc_datex_utilmd_co=>gc_versart_grv.   "GRV
        LOOP AT is_proc_step_data-msgcomments ASSIGNING <fs_proc_step_data> WHERE text_subj_qual = /idxgc/if_constants_ide=>gc_msg_comments_acb.
          IF <fs_proc_step_data>-free_text_value NE 'SONDERKÜNDIGUNG' AND
             <fs_proc_step_data>-free_text_value NS zif_agc_datex_utilmd_co=>gc_versart_grv.   "GRV
            rv_comment = ';GRV'.
          ENDIF.
        ENDLOOP.

        IF sy-subrc NE 0.
          rv_comment = ';GRV'.
        ENDIF.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD _get_comment_ihb.
* Diese Methode schreibt bei Bedarf das Kennzeichen IHB in den Kommentar
* analog zum Form hole_auszug im Include LZ_LW_CONTAINERFUBASF05.

    DATA lv_anlage TYPE anlage.
    DATA lv_auszdat TYPE dats.
    DATA lv_auszbeleg TYPE auszbeleg.

    FIELD-SYMBOLS <fs_proc_step_data> TYPE /idxgc/s_msgcom_details.

*   Die Anlage besorgen
    TRY.
        CALL METHOD zcl_agc_masterdata=>get_anlage
          EXPORTING
            iv_int_ui  = is_proc_step_data-int_ui
            iv_keydate = sy-datum
          RECEIVING
            rv_anlage  = lv_anlage.
      CATCH zcx_agc_masterdata .
    ENDTRY.

    COMPUTE lv_auszdat = is_proc_step_data-proc_date - 1.

    SELECT auszbeleg FROM eausv
      INTO lv_auszbeleg
     WHERE anlage  = lv_anlage
       AND auszdat = lv_auszdat
       AND erdat   = sy-datum.

      SELECT COUNT(*) FROM eaus
       WHERE auszbeleg = lv_auszbeleg
         AND storausz  = space.

      CHECK sy-subrc EQ 0.

      LOOP AT is_proc_step_data-msgcomments ASSIGNING <fs_proc_step_data> WHERE text_subj_qual = /idxgc/if_constants_ide=>gc_msg_comments_acb.

        IF <fs_proc_step_data>-free_text_value NE 'SONDERKÜNDIGUNG' AND
           <fs_proc_step_data>-free_text_value NS 'IHB'.

          rv_comment = ';IHB'.

        ENDIF.
      ENDLOOP.

      IF sy-subrc NE 0.
        rv_comment = ';IHB'.
      ENDIF.

      EXIT.

    ENDSELECT.

  ENDMETHOD.


  METHOD _GET_COMMENT_KUENDFRIST.
* Diese Methode schreibt bei Bedarf ein Kommentar zum Kündigungsdatum
* analog zum Form hole_comkuendfrist im Include LZ_LW_CONTAINERFUBASF05.

    DATA lf_ever TYPE ever.
    DATA lf_eanl TYPE v_eanl.
    DATA lf_contract_sws TYPE zlw_contract_kd.
    DATA ld_possdate TYPE dats.              "Möglches Kündiungsdatum
    DATA ld_kfrist TYPE kuenzeit.            "Frist zur Kündigung
    DATA ld_kuenper TYPE kuenper.            "Zeiteinheit für Kündigung
    DATA ld_kuenpertxt(7) TYPE c.
    DATA ld_kuenpertxtez(7) TYPE c.
    DATA ld_write_date(10) TYPE c.
    DATA ld_write_date2(10) TYPE c.
    DATA ld_write_frist(3) TYPE c.
    DATA ld_commenttxt TYPE eideswtmdcomment.
    DATA ld_kuenddate TYPE ever-vbeginn.
    DATA ld_year TYPE fkk_fkdate_dummy-int4.
    DATA ld_day TYPE fkk_fkdate_dummy-int4.
    DATA ld_month TYPE fkk_fkdate_dummy-int4.
    DATA ld_flag TYPE kennzx.               "Acar, 15.08.2012 Mantis 3322
    DATA ls_diverse TYPE /idxgc/s_diverse_details.

    FIELD-SYMBOLS <fs_msgcomments> TYPE /idxgc/s_msgcom_details.

*   Kommentar ist nur bei Ablehnung wegen Vertragsbindung zu füllen (Antwortstatus Z12).
    READ TABLE is_proc_step_data-msgrespstatus TRANSPORTING NO FIELDS WITH TABLE KEY item_id = iv_itemid respstatus = /idxgc/if_constants_ide=>gc_respstatus_z12.   " 'Z12'

    CHECK sy-subrc EQ 0.

*   Wenn bei der Vertragslaufzeitprüfung im Workflow bereits ein Text ermittelt wurde, soll dieser Verwendung finden.
    LOOP AT is_proc_step_data-msgcomments ASSIGNING <fs_msgcomments> WHERE text_subj_qual = /idxgc/if_constants_ide=>gc_msg_comments_acb.
      IF  <fs_msgcomments>-free_text_value NS 'Kündigung zum Sonderkündigungsdatum' AND
          <fs_msgcomments>-free_text_value NS 'Nächstmögliches Kündigungsdatum'.
        RETURN.
      ENDIF.
    ENDLOOP.

* Vertrag und Anlage besorgen.
    CALL FUNCTION 'Z_LW_POD_DATA'
      EXPORTING
        x_int_ui   = is_proc_step_data-int_ui
        x_keydatum = is_proc_step_data-proc_date
      IMPORTING
        y_anlage   = lf_eanl-anlage
        y_vertrag  = lf_ever-vertrag.


    SELECT SINGLE * FROM ever INTO lf_ever
                             WHERE vertrag = lf_ever-vertrag.

    CHECK sy-subrc EQ 0.

    SELECT SINGLE * FROM v_eanl  INTO lf_eanl
                                WHERE anlage = lf_eanl-anlage
                                  AND  ab LE is_proc_step_data-proc_date
                                  AND bis GE is_proc_step_data-proc_date.

    CHECK sy-subrc EQ 0.

*   Kündigungsfristdaten über Produkteigenschaften des Tariftyps ermitteln
    CALL FUNCTION 'Z_ZEBI_TARIFTYPMERKMALE'
      EXPORTING
        iv_tariftyp      = lf_eanl-tariftyp
        iv_termine_lesen = abap_true
      IMPORTING
        es_contract_kd   = lf_contract_sws
      EXCEPTIONS
        OTHERS           = 3.
    IF sy-subrc <> 0.
      CLEAR lf_contract_sws.
    ENDIF.

* mögl. Endedatum
    READ TABLE is_proc_step_data-diverse INTO ls_diverse WITH KEY item_id = iv_itemid.
    MOVE ls_diverse-noticeper TO ld_possdate.
* Kündigungsfrist
    IF NOT lf_ever-kfrist IS INITIAL.
      MOVE lf_ever-kfrist TO ld_kfrist.
    ELSE.
      MOVE lf_contract_sws-kfrist TO ld_kfrist.
    ENDIF.
* Kündigungszeiteinheit
    IF NOT lf_ever-kuenper IS INITIAL.
      MOVE lf_ever-kuenper TO ld_kuenper.
    ELSE.
      MOVE lf_contract_sws-kuenper TO ld_kuenper.
    ENDIF.


    IF  NOT ld_kfrist IS INITIAL
    AND NOT ld_kuenper IS INITIAL
    AND NOT ld_possdate IS INITIAL.
      CASE ld_kuenper.
        WHEN '3'.
          MOVE 'Wochen' TO ld_kuenpertxt.
          MOVE 'Woche' TO ld_kuenpertxtez.
        WHEN '2'.
          MOVE 'Jahren' TO ld_kuenpertxt.
          MOVE 'Jahr' TO ld_kuenpertxtez.
        WHEN '1'.
          MOVE 'Monaten' TO ld_kuenpertxt.
          MOVE 'Monat' TO ld_kuenpertxtez.
        WHEN '0'.
          MOVE 'Tagen' TO ld_kuenpertxt.
          MOVE 'Tag' TO ld_kuenpertxtez.
      ENDCASE.


      MOVE lf_ever-vbeginn TO ld_kuenddate.
      MOVE ld_possdate(4)  TO ld_kuenddate(4).

      CLEAR ld_flag.
      IF ld_kuenddate < ld_possdate.
        ld_kuenddate = ld_possdate.
        ld_flag = 'X'. "1 Tag nicht abziehen
      ENDIF.

*->Es kann sein, dass der 29.02. ermittelt wird und dieses Datum ungültig ist, da Schaltjahr->Ermittle den letzten des Monats
      IF ld_kuenddate+4(2) = '02' AND ld_kuenddate+6(2) = '29' AND ld_flag IS INITIAL.
        MOVE ld_kuenddate(4) TO ld_year.
        MOVE ld_kuenddate+4(2) TO ld_month.
        CALL FUNCTION 'FKK_DTE_GET_LASTDAY_OF_MONTH'
          EXPORTING
            i_month       = ld_month
            i_year        = ld_year
          IMPORTING
            e_lastday     = ld_day
          EXCEPTIONS
            invalid_month = 1
            OTHERS        = 2.
        IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.
        MOVE ld_day TO ld_kuenddate+6(2).

      ELSEIF ld_flag IS INITIAL.

        CALL FUNCTION 'ISU_DATE_MODIFIKATION'
          EXPORTING
            m_art       = '-'
            day         = 1
          CHANGING
            date        = ld_kuenddate
          EXCEPTIONS
            check_error = 1
            OTHERS      = 2.
        IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.
      ENDIF.

      WRITE ld_kuenddate TO ld_write_date.
*    pf_msgdata-zz_changedate = ld_kuenddate.


      WRITE ld_kfrist TO ld_write_frist NO-ZERO.



      IF ld_kfrist LT 2.
        CONCATENATE
        text-k01
        ld_write_frist
        ld_kuenpertxtez
        text-k02
        ld_write_date
        text-k03
        INTO ld_commenttxt SEPARATED BY space.
      ELSE.
        CONCATENATE
        text-k01
        ld_write_frist
        ld_kuenpertxt
        text-k02
        ld_write_date
        text-k03
        INTO ld_commenttxt SEPARATED BY space.
      ENDIF.


    ELSEIF NOT ld_possdate IS INITIAL.
      IF NOT lf_ever-kuenddat IS INITIAL.
        WRITE ld_possdate TO ld_write_date.
        WRITE lf_ever-kuenddat TO ld_write_date2.
*      Kündigung ist möglich bis Kuenddat zum ld_possend.
        CONCATENATE
        'Eine Kündigung ist möglich bis'(k06)
        ld_write_date2
        'zum'(k07)
        ld_write_date
        '.'(k08)
        INTO ld_commenttxt SEPARATED BY space.
      ELSE.
        WRITE ld_possdate TO ld_write_date.
        CONCATENATE
        text-k04
        ld_write_date
        text-k05
        INTO ld_commenttxt SEPARATED BY space.
      ENDIF.
    ENDIF.

    CONDENSE ld_commenttxt.
    MOVE ld_commenttxt TO rv_comment.

  ENDMETHOD.


  METHOD _get_comment_lgzusatz.
* Methode ermittelt den Lagezusatz analog zum FORM lgzusatz aus dem Include LZ_LW_CONTAINERFUBASF05
* und schreibt diesen in das Kommentarfeld

    DATA: lv_lgzusatz TYPE evbs-lgzusatz,
          lv_floor    TYPE evbs-floor,
          lv_anlage   TYPE anlage,
          ls_v_eanl   TYPE v_eanl.

* Anlage zum PoD holen
    TRY.
        CALL METHOD zcl_agc_masterdata=>get_anlage
          EXPORTING
            iv_int_ui  = is_proc_step_data-int_ui
            iv_keydate = sy-datum
          RECEIVING
            rv_anlage  = lv_anlage.
      CATCH zcx_agc_masterdata .
    ENDTRY.

* Anlagedaten lesen
    TRY.
        CALL METHOD zcl_agc_masterdata=>get_v_eanl
          EXPORTING
            iv_anlage  = lv_anlage
            iv_keydate = sy-datum
          RECEIVING
            rv_eanl    = ls_v_eanl.
      CATCH zcx_agc_masterdata .
    ENDTRY.

* Bedarfsart übernehmen
    CONCATENATE ';BED'
                ls_v_eanl-zzebedart
           INTO rv_comment.

    SELECT SINGLE lgzusatz floor
      FROM evbs
      INTO (lv_lgzusatz, lv_floor )
     WHERE vstelle = ls_v_eanl-vstelle.

    CHECK sy-subrc EQ 0.

* Lagezusatz übernehmen
    IF NOT lv_lgzusatz IS INITIAL.
      CONCATENATE rv_comment
                  ';LGZ'
                  lv_lgzusatz
             INTO rv_comment.
    ENDIF.

* Etage übernehmen
    IF NOT lv_floor IS INITIAL.
      CONCATENATE rv_comment
                  ';FLO'
                  lv_floor
             INTO rv_comment.
    ENDIF.
  ENDMETHOD.


  METHOD _get_comment_storno_edd.
*--------------------------------------------------------------------*
* Diese Methode schreibt bei Bedarf das Kennzeichen EDD in den Kommentar
* analog zum Form hole_storno_edd im Include LZ_LW_CONTAINERFUBASF05.
*--------------------------------------------------------------------*
* Falls es einen Einzug "EDD" am Zählpunkt gibt, der am Tag nach dem
* Auszugsdatum beginnt, so ist hier das Kennzeichen EDD mitzugeben.
*--------------------------------------------------------------------*

    DATA lv_einzdat TYPE dats.
    DATA lv_gue TYPE zlw_versart.


    CALL FUNCTION 'Z_LW_POD_DATA'
      EXPORTING
        x_int_ui   = is_proc_step_data-int_ui
        x_keydatum = is_proc_step_data-proc_date
      IMPORTING
        y_gue      = lv_gue
        y_einzdat  = lv_einzdat.

    IF  ( lv_gue     EQ zif_agc_datex_utilmd_co=>gc_versart_edd   OR     "EDD
          lv_gue     EQ zif_agc_datex_utilmd_co=>gc_versart_grv   OR     "GRV
          lv_gue     EQ zif_agc_datex_utilmd_co=>gc_versart_ers ) AND    "ERS
          lv_einzdat EQ is_proc_step_data-proc_date.

      CONCATENATE ';' lv_gue INTO rv_comment.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
