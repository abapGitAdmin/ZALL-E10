class /ADZ/CL_MDC_UTILITY definition
  public
  final
  create public .

public section.

  class-methods GET_INTCODE
    importing
      !IV_SERVICE type SERCODE optional
      !IV_SERVICEID type SERVICE_PROV optional
    returning
      value(RV_INTCODE) type INTCODE
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_SERVICE_PROVIDER
    importing
      !IV_SERVICEID type SERVICE_PROV
    returning
      value(RS_ESERVPROV) type ESERVPROV
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_INT_UI
    importing
      !IV_EXT_UI type EXT_UI
      !IV_KEYDATE type /IDXGC/DE_KEYDATE default SY-DATUM
    returning
      value(RV_INT_UI) type INT_UI
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_INSTALLATION
    importing
      !IV_EXT_UI type EXT_UI optional
      !IV_INT_UI type INT_UI optional
      !IV_KEYDATE type /IDXGC/DE_KEYDATE default SY-DATUM
    returning
      value(RV_INSTALLATION) type ANLAGE
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_EANL
    importing
      !IV_INT_UI type INT_UI optional
      !IV_EXT_UI type EXT_UI optional
      !IV_INSTALLATION type ANLAGE optional
      !IV_KEYDATE type /IDXGC/DE_KEYDATE default SY-DATUM
    returning
      value(RS_EANL) type EANL
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_DIVISION_CAT
    importing
      !IV_INT_UI type INT_UI optional
      !IV_EXT_UI type EXT_UI optional
      !IV_INSTALLATION type ANLAGE optional
      !IV_DIVISION type SPARTE optional
      !IV_KEYDATE type /IDXGC/DE_KEYDATE default SY-DATUM
    returning
      value(RV_DIVISION_CAT) type SPARTYP
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_ASSIGNED_TSO
    importing
      !IV_INT_UI type INT_UI
      !IV_KEYDATE type /IDXGC/DE_KEYDATE default SY-DATUM
    returning
      value(RS_ESERVPROV) type ESERVPROV
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_ALL_RELATED_INT_UI
    importing
      !IV_INT_UI type INT_UI
      !IV_KEYDATE type /IDXGC/DE_KEYDATE default SY-DATUM
      !IT_INT_UI_TO_EXCLUDE type INT_UI_TABLE optional
    returning
      value(RT_INT_UI) type INT_UI_TABLE .
  class-methods GET_MALO_FROM_MELO
    importing
      !IV_MELO_INT_UI type INT_UI
      !IV_PROCESS_DATE type DATS
    returning
      value(RV_MALO_INT_UI) type INT_UI
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_EXT_UI
    importing
      !IV_ADAT type ADAT
      !IV_INT_UI type INT_UI
    returning
      value(RV_EXT_UI) type EXT_UI
    raising
      /IDXGC/CX_GENERAL .
  class-methods IS_FEEDING_NO_DIRECT_MARKETING
    importing
      !IV_INT_UI type INT_UI optional
      !IV_EXT_UI type EXT_UI optional
      !IV_KEYDATE type /IDXGC/DE_KEYDATE default SY-DATUM
    returning
      value(RV_FLAG_FEED_NO_DIRECT_MARKET) type BOOLEAN
    raising
      /IDXGC/CX_GENERAL .
  class-methods IS_FEED_MAIN_POD_WITH_TRANCHE
    importing
      !IV_INT_UI type INT_UI optional
      !IV_EXT_UI type EXT_UI optional
      !IV_KEYDATE type /IDXGC/DE_KEYDATE default SY-DATUM
    returning
      value(RV_FLAG_FEED_MAIN_POD_WITH_TRA) type BOOLEAN
    raising
      /IDXGC/CX_GENERAL .
protected section.
private section.

  class-data GT_TESPT type ITESPT_TYPE .
  class-data GT_TECDE type EIDE_SERVICE_TAB .
  class-data GV_MSGTXT type STRING .
ENDCLASS.



CLASS /ADZ/CL_MDC_UTILITY IMPLEMENTATION.


  METHOD get_all_related_int_ui.
************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: RIVCHIN-I                                    Datum: 26.11.2019
*
* Beschreibung: Ermittlung von allen zugehörigen INT_UI
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************
    DATA: lt_pod_rel           TYPE /idxgc/t_pod_rel,
          lt_int_ui            TYPE int_ui_table,
          lt_int_ui_to_exclude TYPE int_ui_table.

    SELECT * FROM /idxgc/pod_rel INTO TABLE lt_pod_rel
      WHERE ( int_ui1 = iv_int_ui OR int_ui2 = iv_int_ui ) AND datefrom <= iv_keydate AND dateto >= iv_keydate.

    LOOP AT lt_pod_rel ASSIGNING FIELD-SYMBOL(<ls_pod_rel>).
      READ TABLE it_int_ui_to_exclude TRANSPORTING NO FIELDS WITH KEY table_line = <ls_pod_rel>-int_ui1.
      IF sy-subrc <> 0.
        APPEND <ls_pod_rel>-int_ui1 TO lt_int_ui.
      ENDIF.
      READ TABLE it_int_ui_to_exclude TRANSPORTING NO FIELDS WITH KEY table_line = <ls_pod_rel>-int_ui2.
      IF sy-subrc <> 0.
        APPEND <ls_pod_rel>-int_ui2 TO lt_int_ui.
      ENDIF.
    ENDLOOP.

    lt_int_ui_to_exclude = it_int_ui_to_exclude.
    APPEND LINES OF lt_int_ui TO lt_int_ui_to_exclude.
    LOOP AT lt_int_ui ASSIGNING FIELD-SYMBOL(<lv_int_ui>) WHERE table_line <> iv_int_ui.
      APPEND LINES OF get_all_related_int_ui( iv_int_ui = <lv_int_ui> iv_keydate = iv_keydate
      it_int_ui_to_exclude = lt_int_ui_to_exclude ) TO rt_int_ui.
    ENDLOOP.

    APPEND LINES OF lt_int_ui TO rt_int_ui.
    SORT rt_int_ui.
    DELETE ADJACENT DUPLICATES FROM rt_int_ui.
  ENDMETHOD.


  METHOD get_assigned_tso.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: RIVCHIN-I                                                               Datum: 11.11.2019
*
* Beschreibung: ÜNB ermitteln, Logik übernommen aus BAdI /IDXGL/BADI_DATA_PROVISION->DETERMINE_TSO
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* THIMEL-R    01.03.2020 Signatur angepasst, Unbenutztes Coding gelöscht, Fehlermeldungen eingefügt
***************************************************************************************************
    DATA: lt_euigrid TYPE ieuigrid,
          ls_euigrid TYPE euigrid,
          lt_egridh  TYPE t_egridh,
          ls_egridh  TYPE egridh.

    CALL FUNCTION 'ISU_DB_EUIGRID_SELECT'
      EXPORTING
        x_int_ui      = iv_int_ui
      IMPORTING
        y_euigrid     = lt_euigrid
      EXCEPTIONS
        not_found     = 1
        not_qualified = 2
        system_error  = 3
        OTHERS        = 4.
    IF sy-subrc <> 0.
      /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDIF.

    LOOP AT lt_euigrid INTO ls_euigrid WHERE datefrom <= iv_keydate
                                         AND dateto   >= iv_keydate
                                         AND loevm    = /idxgc/if_constants=>gc_space.
      EXIT.
    ENDLOOP.

    IF sy-subrc = 0.
      CALL FUNCTION 'ISU_DB_EGRIDH_SELECT'
        EXPORTING
          x_grid    = ls_euigrid-grid_id
        IMPORTING
          y_egridh  = lt_egridh
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.
      IF sy-subrc = 0.
        LOOP AT lt_egridh INTO ls_egridh WHERE ab  <= iv_keydate
                                           AND bis >= iv_keydate.
          EXIT.
        ENDLOOP.
      ENDIF.
    ENDIF.

    IF ls_egridh-settlcoord IS INITIAL.
      MESSAGE e030(/adz/mdc_messages) INTO gv_msgtxt.
      /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDIF.

    SELECT SINGLE service_prov_tso FROM /idexge/t_coarea WHERE settlcoord = @ls_egridh-settlcoord INTO @DATA(lv_service_prov_tso).
    IF sy-subrc = 0.
      CALL FUNCTION 'ISU_DB_ESERVPROV_SINGLE'
        EXPORTING
          x_serviceid = lv_service_prov_tso
        IMPORTING
          y_eservprov = rs_eservprov
        EXCEPTIONS
          OTHERS      = 1.
    ENDIF.

    IF rs_eservprov IS INITIAL.
      MESSAGE e031(/adz/mdc_messages) INTO gv_msgtxt.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.

  ENDMETHOD.


METHOD get_division_cat.
************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: WISNIEWSKI-P                                 Datum: 08.11.2019
*
* Beschreibung: Spartentyp holen
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************
  DATA: lv_division TYPE sparte,
        lv_eanl     TYPE eanl.

  IF iv_division IS NOT INITIAL.
    lv_division = iv_division.
  ELSEIF iv_installation IS NOT INITIAL.
    lv_eanl = get_eanl( iv_installation = iv_installation iv_keydate = iv_keydate ).
    lv_division = lv_eanl-sparte.
  ELSEIF iv_ext_ui IS NOT INITIAL.
    lv_eanl = get_eanl( iv_ext_ui = iv_ext_ui iv_keydate = iv_keydate ).
    lv_division = lv_eanl-sparte.
  ELSEIF iv_int_ui IS NOT INITIAL.
    lv_eanl = get_eanl( iv_int_ui = iv_int_ui iv_keydate = iv_keydate ).
    lv_division = lv_eanl-sparte.
  ENDIF.

  IF gt_tespt IS INITIAL.
    SELECT * FROM tespt INTO TABLE @gt_tespt.
  ENDIF.

*  TRY.
*      rv_division_cat = gt_tespt[ sparte = lv_division ]-spartyp.
*    CATCH /idxgc/cx_general.
*      /idxgc/cx_general=>raise_exception_from_msg( ).
*  ENDTRY.

    IF line_exists( gt_tespt[ sparte = lv_division ] ).
      rv_division_cat = gt_tespt[ sparte = lv_division ]-spartyp.
    ELSE.
*      message e
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.

ENDMETHOD.


METHOD get_eanl.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: WISNIEWSKI-P                                                            Datum: 08.11.2019
*
* Beschreibung: Liest die Tabelle EANL zu einem Zählpunkt oder einer Anlage.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
  DATA: lv_installation TYPE anlage.

  IF iv_installation IS NOT INITIAL.
    lv_installation = iv_installation.
  ELSEIF iv_int_ui IS NOT INITIAL.
    lv_installation = get_installation( iv_int_ui = iv_int_ui iv_keydate = iv_keydate ).
  ELSEIF iv_ext_ui IS NOT INITIAL.
    lv_installation = get_installation( iv_ext_ui = iv_ext_ui iv_keydate = iv_keydate ).
  ENDIF.

  SELECT SINGLE * FROM eanl INTO rs_eanl WHERE anlage = lv_installation.

  IF rs_eanl IS INITIAL.
    /idxgc/cx_general=>raise_exception_from_msg( ).
  ENDIF.
ENDMETHOD.


  METHOD get_ext_ui.
************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: RIVCHIN-I                                    Datum: 27.11.2019
*
* Beschreibung: EXT_UI from INT_UI
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************

    DATA:
      lv_message  TYPE string,
      ls_euitrans TYPE euitrans.

    CALL FUNCTION 'ISU_DB_EUITRANS_INT_SINGLE'
      EXPORTING
        x_int_ui     = iv_int_ui
        x_keydate    = iv_adat
      IMPORTING
        y_euitrans   = ls_euitrans
      EXCEPTIONS
        not_found    = 1
        system_error = 2
        OTHERS       = 3.
    IF sy-subrc <> 0.
      MESSAGE e029(/idexge/mscons_msg) WITH iv_int_ui INTO lv_message.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.
    rv_ext_ui = ls_euitrans-ext_ui.

  ENDMETHOD.


METHOD get_installation.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: WISNIEWSKI-P                                                            Datum: 08.11.2019
*
* Beschreibung: Bestimmt Anlage zu einem Zählpunkt.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
  DATA: lv_int_ui    TYPE          int_ui,
        lt_euiinstln TYPE TABLE OF euiinstln.

  FIELD-SYMBOLS: <fs_euiinstln> TYPE euiinstln.

  IF iv_int_ui IS NOT INITIAL.
    lv_int_ui = iv_int_ui.
  ELSEIF iv_ext_ui IS NOT INITIAL.
    lv_int_ui = get_int_ui( iv_ext_ui = iv_ext_ui iv_keydate = iv_keydate ).
  ENDIF.

  CALL FUNCTION 'ISU_DB_EUIINSTLN_SELECT'
    EXPORTING
      x_int_ui      = lv_int_ui
      x_dateto      = iv_keydate
      x_datefrom    = iv_keydate
      x_only_dereg  = abap_true
    IMPORTING
      y_euiinstln   = lt_euiinstln
    EXCEPTIONS
      not_found     = 1
      system_error  = 2
      not_qualified = 3
      OTHERS        = 4.
  IF sy-subrc <> 0.
    /idxgc/cx_general=>raise_exception_from_msg( ).
  ENDIF.

  IF lines( lt_euiinstln ) = 1.
    rv_installation = lt_euiinstln[ 1 ]-anlage.
  ENDIF.
ENDMETHOD.


METHOD get_intcode.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: WISNIEWSKI-P                                                            Datum: 14.08.2019
*
* Beschreibung: Ermittelt den Servicetyp zum Service.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* THIMEL-R    26.03.2020 Namensgebung geändert und um SERVICEID erweitert.
***************************************************************************************************
  DATA lv_service TYPE sercode.

  IF gt_tecde IS INITIAL.
    SELECT * FROM tecde INTO TABLE @gt_tecde.
  ENDIF.

  IF iv_service IS NOT INITIAL.
    lv_service = iv_service.
  ELSE.
    lv_service = get_service_provider( iv_serviceid = iv_serviceid )-service.
  ENDIF.

  IF line_exists( gt_tecde[ service = lv_service ] ).
    rv_intcode = gt_tecde[ service = lv_service ]-intcode.
  ENDIF.
ENDMETHOD.


METHOD get_int_ui.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: WISNIEWSKI-P                                                            Datum: 08.11.2019
*
* Beschreibung: Ermittelt internen Zählpunkt.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
  DATA: ls_euitrans TYPE euitrans.

  CALL FUNCTION 'ISU_DB_EUITRANS_EXT_SINGLE'
    EXPORTING
      x_ext_ui     = iv_ext_ui
      x_keydate    = iv_keydate
    IMPORTING
      y_euitrans   = ls_euitrans
    EXCEPTIONS
      not_found    = 1
      system_error = 2
      OTHERS       = 3.
  IF sy-subrc <> 0.
    /idxgc/cx_general=>raise_exception_from_msg( ).
  ELSE.
    rv_int_ui = ls_euitrans-int_ui.
  ENDIF.
ENDMETHOD.


  method GET_MALO_FROM_MELO.
************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: RIVCHIN-I                                    Datum: 27.11.2019
*
* Beschreibung: Ermittlung der MaLo mit der MeLo
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************
      DATA:
    lr_badi_data_access TYPE REF TO /idxgl/badi_data_access,
    lt_malo_melo        TYPE /idxgl/t_euitrans_malo_melo,
    ls_malo_melo        TYPE /idxgl/s_euitrans_malo_melo,

    lv_message          TYPE string,
    lv_ext_ui           TYPE ext_ui.

  GET BADI lr_badi_data_access.

  CALL BADI lr_badi_data_access->get_pod_malo_melo
    EXPORTING
      iv_int_ui             = iv_melo_int_ui
      iv_key_date           = iv_process_date
    IMPORTING
      et_euitrans_malo_melo = lt_malo_melo.

  READ TABLE lt_malo_melo INTO ls_malo_melo
    WITH KEY uistrutyp = /idxgl/if_badi_data_access=>gc_pod_structure_category_malo.
  IF sy-subrc <> 0.
* Stammdatenprobleme
    lv_ext_ui = get_ext_ui( iv_adat = iv_process_date iv_int_ui = iv_melo_int_ui ).
    MESSAGE e032(/idexge/mscons_msg) WITH lv_ext_ui iv_process_date INTO lv_message.
    /idxgc/cx_general=>raise_exception_from_msg( ).
  ENDIF.

  rv_malo_int_ui = ls_malo_melo-int_ui_malo.
  endmethod.


  METHOD get_service_provider.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 01.10.2019
*
* Beschreibung: Serviceanbieter zu SERVICEID holen
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************

    CALL FUNCTION 'ISU_DB_ESERVPROV_SINGLE'
      EXPORTING
        x_serviceid = iv_serviceid
      IMPORTING
        y_eservprov = rs_eservprov
      EXCEPTIONS
        not_found   = 1
        OTHERS      = 2.
    IF sy-subrc <> 0.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.

  ENDMETHOD.


  METHOD is_feeding_no_direct_marketing.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 26.03.2020
*
* Beschreibung: Prüfen ob es sich um eine Einspeiseanlage ohne Direktvermarktung handelt.
*   Annahme: Bei Einspeisern mit Direktvermarktung gibt es einen Lieferantenservice mit Flag
*   "OWN_SERVICE".
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    DATA: lv_int_ui TYPE int_ui.

    IF iv_int_ui IS NOT INITIAL.
      lv_int_ui = iv_int_ui.
    ELSE.
      lv_int_ui = /adz/cl_mdc_utility=>get_int_ui( iv_ext_ui = iv_ext_ui iv_keydate = iv_keydate ).
    ENDIF.

    /idxgc/cl_utility_isu_add=>get_servprov_onpod( EXPORTING iv_int_ui           = lv_int_ui
                                                             iv_keydate          = iv_keydate
                                                             iv_new              = abap_false
                                                   IMPORTING et_servprov_details = DATA(lt_servprov_details) ).

    IF line_exists( lt_servprov_details[ service_cat = /adz/if_mdc_co=>gc_intcode-sup_02 own_service = abap_true ] ) AND
       line_exists( lt_servprov_details[ service_cat = /adz/if_mdc_co=>gc_intcode-dso_01 own_service = abap_true ] ) AND
       get_eanl( iv_int_ui = iv_int_ui iv_keydate = iv_keydate )-bezug = abap_true.
      rv_flag_feed_no_direct_market = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD is_feed_main_pod_with_tranche.
***************************************************************************************************
*            _                        _____ ______
*           | |                      / ____|  ____|
*   __ _  __| | ___  ___ ___  ___   | (___ | |__
*  / _` |/ _` |/ _ \/ __/ __|/ _ \   \___ \|  __|
* | (_| | (_| |  __/\__ \__ \ (_) |  ____) | |____
*  \__,_|\__,_|\___||___/___/\___/  |_____/|______|
*
* Author: THIMEL-R                                                                Datum: 26.03.2020
*
* Beschreibung: Prüfen ob es sich um eine Haupt-MaLo mit einer Tranche handelt.
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    DATA: lv_int_ui TYPE int_ui.

    IF iv_int_ui IS NOT INITIAL.
      lv_int_ui = iv_int_ui.
    ELSE.
      lv_int_ui = /adz/cl_mdc_utility=>get_int_ui( iv_ext_ui = iv_ext_ui iv_keydate = iv_keydate ).
    ENDIF.

    SELECT COUNT( * ) FROM /idxgc/pod_rel INTO @DATA(lv_num_tranches)
      WHERE int_ui2 = @lv_int_ui AND datefrom <= @iv_keydate AND dateto >= @iv_keydate AND rel_type = @/adz/if_mdc_co=>gc_rel_type-sup_tranche_2000.

    IF lv_num_tranches > 0.
      rv_flag_feed_main_pod_with_tra = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
