class /ADZ/CL_BDR_CUSTOMIZING definition
  public
  final
  create public .

public section.

  types:
    lt_bdr_devconf TYPE TABLE OF /adz/bdr_devconf WITH KEY mandt settl_proc device_conf euistrutyp validstart_date kennziff .

  class-methods GET_CUST_MAIN
    returning
      value(RS_CUST_MAIN) type /ADZ/BDR_MAIN
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_FORMAT_SETTING
    returning
      value(RV_FORMAT_SETTING) type /ADZ/DE_BDR_FORMAT_SETTING
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_OWN_INTCODE_1
    returning
      value(RV_INTCODE_1) type INTCODE
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_OWN_INTCODE_2
    returning
      value(RV_INTCODE_2) type INTCODE
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_DEVCONF
    importing
      !IV_SETTL_PROC type /IDXGC/DE_SETTL_PROC
      !IV_DEVICE_CONF type /IDXGC/DE_DEVICE_CONF
      !IV_EUISTRUTYP type EUISTRUTYP
      !IV_KEYDATE type /IDXGC/DE_KEYDATE default SY-DATUM
    returning
      value(RT_DEVCONF) type LT_BDR_DEVCONF
    raising
      /IDXGC/CX_GENERAL .
protected section.
private section.

  class-data GS_CUST_MAIN type /ADZ/BDR_MAIN .
  class-data GT_DEVCONF type table of /ADZ/BDR_DEVCONF .
  class-data GV_MSGTXT type STRING .
ENDCLASS.



CLASS /ADZ/CL_BDR_CUSTOMIZING IMPLEMENTATION.


  METHOD get_cust_main.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 08.05.2019
*
* Beschreibung: Hauptcustomizing zurückgeben
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    IF gs_cust_main IS INITIAL.
      SELECT SINGLE * FROM /adz/bdr_main INTO @gs_cust_main.
    ENDIF.

    rs_cust_main = gs_cust_main.

    IF rs_cust_main IS INITIAL.
      MESSAGE e030(/adz/bdr_messages) INTO gv_msgtxt.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


METHOD get_devconf.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: WISNIEWSKI-P                                                            Datum: 25.10.2019
*
* Beschreibung: Gibt Standartkonfiguration zur Änderung der
* Gerätekonfiguration zurück
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
  FIELD-SYMBOLS: <ls_devconf> TYPE /adz/bdr_devconf.

  IF gt_devconf IS INITIAL.
    SELECT * FROM /adz/bdr_devconf INTO TABLE @gt_devconf.
  ENDIF.

  LOOP AT gt_devconf ASSIGNING <ls_devconf> WHERE settl_proc      =  iv_settl_proc
                                              AND device_conf     =  iv_device_conf
                                              AND euistrutyp      =  iv_euistrutyp
                                              AND validstart_date <= iv_keydate.
    INSERT <ls_devconf> INTO TABLE rt_devconf.
  ENDLOOP.

  "Nur die neuesten Einträge behalten.
  SORT rt_devconf BY validstart_date DESCENDING.
  LOOP AT rt_devconf ASSIGNING <ls_devconf>.
    DELETE rt_devconf WHERE kennziff = <ls_devconf>-kennziff AND validstart_date < <ls_devconf>-validstart_date.
  ENDLOOP.
ENDMETHOD.


  METHOD get_format_setting.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 08.05.2019
*
* Beschreibung: Formatschalter zurückgeben
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    DATA(ls_cust_main) = get_cust_main( ).

    rv_format_setting = ls_cust_main-format_setting.
  ENDMETHOD.


METHOD get_own_intcode_1.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: WISNIEWSKI-P                                                            Datum: 19.07.2019
*
* Beschreibung: Servicetyp 1 zurückgeben
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
  DATA(ls_cust_main) = get_cust_main( ).

  rv_intcode_1 = ls_cust_main-own_intcode_1.
ENDMETHOD.


METHOD GET_OWN_INTCODE_2.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: WISNIEWSKI-P                                                            Datum: 19.07.2019
*
* Beschreibung: Servicetyp 2 zurückgeben
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
  DATA(ls_cust_main) = get_cust_main( ).

  rv_intcode_2 = ls_cust_main-own_intcode_2.
ENDMETHOD.
ENDCLASS.
