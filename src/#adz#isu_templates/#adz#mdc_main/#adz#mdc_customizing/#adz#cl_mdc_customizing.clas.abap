class /ADZ/CL_MDC_CUSTOMIZING definition
  public
  final
  create public .

public section.

  class-methods IS_SERVPROV_IN_MPG
    importing
      !IV_MP_GROUP_ID type /ADZ/DE_MDC_MP_GROUP_ID
      !IV_ASSOC_SERVPROV type E_DEXSERVPROV
    returning
      value(RV_SP_IS_IN_MPG) type BOOLEAN
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_INBOUND_CONFIG_FOR_EDIFACT
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
      !IV_KEYDATE type /IDXGC/DE_KEYDATE default SY-DATUM
      !IV_ASSOC_SERVPROV type E_DEXSERVPROV
    returning
      value(RS_IN) type /ADZ/S_MDC_IN
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_OWN_INTCODE
    returning
      value(RV_OWN_INTCODE) type /ADZ/S_MDC_MAIN
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_PDOC_EDIFACT_MAPPING
    returning
      value(RT_PD_STRC) type /ADZ/T_MDC_PD_STRC
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_PDOC_EDIFACT_MAP_SINGLE
    importing
      !IV_EDIFACT_STRUCTUR type /IDXGC/DE_EDIFACT_STR
    returning
      value(RS_PD_STRC) type /ADZ/S_MDC_PD_STRC
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_PDOC_QUALIFIERS
    returning
      value(RT_PD_QUAL) type /ADZ/T_MDC_PD_QUAL
    raising
      /IDXGC/CX_GENERAL .
protected section.
private section.

  class-data GT_IN type /ADZ/T_MDC_IN .
  class-data GT_IN_MPG type /ADZ/T_MDC_IN_MPG .
  class-data GT_MPG type /ADZ/T_MDC_MPG .
  class-data GT_MPG_SP type /ADZ/T_MDC_MPG_SP .
  class-data GT_PD_QUAL type /ADZ/T_MDC_PD_QUAL .
  class-data GT_PD_STRC type /ADZ/T_MDC_PD_STRC .
  class-data GS_MAIN type /ADZ/S_MDC_MAIN .
  class-data GV_MSGTXT type STRING .
ENDCLASS.



CLASS /ADZ/CL_MDC_CUSTOMIZING IMPLEMENTATION.


  METHOD get_inbound_config_for_edifact.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 26.07.2015
*
* Beschreibung: SDÄ auf Common Layer Engine: Ermitteln der Verbuchungsmethodik zu einer
*    Stammdatenänderung und einem Marktpartner. Suche erst spezielle Bedingungen für den
*    Marktpartner, danach allgemeine für alle.
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* THIMEL-R    26.07.2019 Übernahme in ADZ-Namensraum und Refaktorierung
***************************************************************************************************
    FIELD-SYMBOLS: <ls_in>     TYPE /adz/s_mdc_in,
                   <ls_in_mpg> TYPE /adz/s_mdc_in_mpg.

    IF gt_in IS INITIAL.
      SELECT * FROM /adz/mdc_in INTO TABLE @gt_in ORDER BY valid_from DESCENDING.
    ENDIF.

    IF gt_in_mpg IS INITIAL.
      SELECT * FROM /adz/mdc_in_mpg INTO TABLE gt_in_mpg ORDER BY valid_from DESCENDING.
    ENDIF.

    LOOP AT gt_in ASSIGNING <ls_in> WHERE edifact_structur = iv_edifact_structur AND valid_from < iv_keydate.
      "Suche nach speziellen Einträgen zum Marktpartner
      LOOP AT gt_in_mpg ASSIGNING <ls_in_mpg> WHERE edifact_structur = iv_edifact_structur AND valid_from = <ls_in>-valid_from.
        IF is_servprov_in_mpg( iv_mp_group_id = <ls_in_mpg>-mp_group_id iv_assoc_servprov = iv_assoc_servprov ) = abap_true.
          MOVE-CORRESPONDING <ls_in_mpg> TO rs_in.
          RETURN.
        ENDIF.
      ENDLOOP.
      rs_in = <ls_in>.
      RETURN.
    ENDLOOP.

    MESSAGE e002(/adz/mdc_customizing) WITH iv_edifact_structur '/ADZ/MDC_IN(_MPG)' INTO gv_msgtxt.
    /idxgc/cx_general=>raise_exception_from_msg( ).
  ENDMETHOD.


  METHOD GET_OWN_INTCODE.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 26.07.2015
*
* Beschreibung: SDÄ auf Common Layer Engine: Ermittlung der eigenen Rolle.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* THIMEL-R    26.07.2019 Übernahme in ADZ-Namensraum und Refaktorierung
***************************************************************************************************
    IF gs_main IS INITIAL.
      SELECT SINGLE * FROM /adz/mdc_main INTO @gs_main.
      IF sy-subrc <> 0.
        MESSAGE e001(/adz/mdc_customizing) WITH '/ADZ/MDC_MAIN' INTO gv_msgtxt.
        /idxgc/cx_general=>raise_exception_from_msg( ).
      ENDIF.
    ENDIF.
    rv_own_intcode = gs_main-own_intcode.
  ENDMETHOD.


  METHOD get_pdoc_edifact_mapping.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 13.10.2015
*
* Beschreibung: SDÄ auf Common Layer Engine: EDIFACT <> PDOC Mapping holen.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* THIMEL-R    26.07.2019 Übernahme in ADZ-Namensraum und Refaktorierung
***************************************************************************************************
    IF gt_pd_strc IS INITIAL.
      SELECT * FROM /adz/mdc_pd_strc INTO TABLE @gt_pd_strc.
      IF sy-subrc <> 0.
        MESSAGE e001(/adz/mdc_customizing) WITH '/ADZ/MDC_PD_STRC' INTO gv_msgtxt.
        /idxgc/cx_general=>raise_exception_from_msg( ).
      ENDIF.
    ENDIF.
    rt_pd_strc = gt_pd_strc.
  ENDMETHOD.


  METHOD GET_PDOC_EDIFACT_MAP_SINGLE.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 13.10.2015
*
* Beschreibung: SDÄ auf Common Layer Engine: EDIFACT <> PDOC Mapping holen.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* THIMEL-R    26.07.2019 Übernahme in ADZ-Namensraum und Refaktorierung
***************************************************************************************************
    IF gt_pd_strc IS INITIAL.
      SELECT * FROM /adz/mdc_pd_strc INTO TABLE @gt_pd_strc.
    ENDIF.

    IF line_exists( gt_pd_strc[ edifact_structur = iv_edifact_structur ] ).
      rs_pd_strc = gt_pd_strc[ edifact_structur = iv_edifact_structur ].
    ELSE.
      MESSAGE e001(/adz/mdc_customizing) WITH '/ADZ/MDC_PD_STRC' INTO gv_msgtxt.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD GET_PDOC_QUALIFIERS.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 13.10.2015
*
* Beschreibung: SDÄ auf Common Layer Engine: PDOC Qualifier der Tabellen holen.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* THIMEL-R    26.07.2019 Übernahme in ADZ-Namensraum und Refaktorierung
***************************************************************************************************
    IF gt_pd_qual IS INITIAL.
      SELECT * FROM /adz/mdc_pd_qual INTO TABLE @gt_pd_qual.
      IF sy-subrc <> 0.
        MESSAGE e001(/adz/mdc_customizing) WITH '/ADZ/MDC_PD_QUAL' INTO gv_msgtxt.
        /idxgc/cx_general=>raise_exception_from_msg( ).
      ENDIF.
    ENDIF.
    rt_pd_qual = gt_pd_qual.
  ENDMETHOD.


  METHOD is_servprov_in_mpg.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 13.10.2015
*
* Beschreibung: SDÄ auf Common Layer Engine: Ermitteln, ob für die Marktpartnergruppe eine
*   Stammdatenänderung versendet werden soll.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* THIMEL-R    26.07.2019 Übernahme in ADZ-Namensraum und Refaktorierung
***************************************************************************************************
    IF gt_mpg IS INITIAL.
      SELECT * FROM /adz/mdc_mpg INTO TABLE @gt_mpg.
    ENDIF.
    IF gt_mpg_sp IS INITIAL.
      SELECT * FROM /adz/mdc_mpg_sp INTO TABLE @gt_mpg_sp.
    ENDIF.

    IF line_exists( gt_mpg[ mp_group_id = iv_mp_group_id ] ).
      IF gt_mpg[ mp_group_id = iv_mp_group_id ]-mp_group_type = /adz/if_mdc_co=>gc_mp_group_type-include.
        IF line_exists( gt_mpg_sp[ mp_group_id = iv_mp_group_id servprov = iv_assoc_servprov ] ).
          rv_sp_is_in_mpg = abap_true.
        ELSE.
          rv_sp_is_in_mpg = abap_false.
        ENDIF.
      ELSEIF gt_mpg[ mp_group_id = iv_mp_group_id ]-mp_group_type = /adz/if_mdc_co=>gc_mp_group_type-exclude.
        IF line_exists( gt_mpg_sp[ mp_group_id = iv_mp_group_id servprov = iv_assoc_servprov ] ).
          rv_sp_is_in_mpg = abap_false.
        ELSE.
          rv_sp_is_in_mpg = abap_true.
        ENDIF.
      ENDIF.
    ELSE.
      MESSAGE e001(/adz/mdc_customizing) WITH '/ADZ/MDC_MPG' INTO gv_msgtxt.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
