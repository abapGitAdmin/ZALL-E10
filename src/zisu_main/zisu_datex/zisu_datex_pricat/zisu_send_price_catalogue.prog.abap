*&---------------------------------------------------------------------*
*& Report  ZISU_SEND_PRICE_CATALOGUE
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

INCLUDE zisu_send_price_catalogue_top           .    " global Data

* INCLUDE ZISU_SEND_PRICE_CATALOGUE_O01           .  " PBO-Modules
* INCLUDE ZISU_SEND_PRICE_CATALOGUE_I01           .  " PAI-Modules
* INCLUDE ZISU_SEND_PRICE_CATALOGUE_F01           .  " FORM-Routines

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF p_all = abap_true AND screen-group1 = 'SEL'.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.


START-OF-SELECTION.
  DATA: lt_lief           TYPE TABLE OF service_prov,
        lt_tecde          TYPE TABLE OF tecde,
        lt_tespt          TYPE TABLE OF tespt,
        lt_dextask        TYPE iedextask,
        lt_interface_data TYPE abap_parmbind_tab,
        ls_task_data      TYPE edextask_data_intf,
        ls_interface_data TYPE LINE OF abap_parmbind_tab,
        ls_compen_prices  TYPE /idexge/s_eqs_cprice,
        ls_mosb_price     TYPE zmosb_price,
        ls_price_list_z32 LIKE LINE OF ls_compen_prices-price_list_z32,
        ls_pricat_export  TYPE zisu_pricat_exp,
        lv_dexbasicproc   TYPE e_dexbasicproc,
        lv_message        TYPE string.

  FIELD-SYMBOLS: <ls_lief>    LIKE LINE OF lt_lief,
                 <ls_so_lief> LIKE LINE OF so_lief,
                 <ls_dextask> LIKE LINE OF lt_dextask.

* get_pricelist
  ls_compen_prices-price_catalogue_id = p_pricat.
  ls_compen_prices-pricat_version     = p_priver.
  ls_compen_prices-currency           = 'EUR'.
  ls_compen_prices-prod_group         = '9'.
  ls_compen_prices-sender             = p_msb.

  SELECT SINGLE val_start_date FROM zmosb_pricat_ver
    INTO ls_compen_prices-val_start_date
      WHERE price_catalogue_id = p_pricat
        AND pricat_version     = p_priver.

  SELECT * FROM zmosb_price INTO ls_mosb_price
    WHERE price_catalogue_id = p_pricat
      AND price_version      = p_priver.

    CLEAR ls_price_list_z32.
    ls_price_list_z32-price_class      = ls_mosb_price-price_class.
    ls_price_list_z32-price_class_add  = ls_mosb_price-price_class_add.
    ls_price_list_z32-price_curr       = ls_mosb_price-price_curr.
    ls_price_list_z32-price            = ls_mosb_price-price.
    APPEND ls_price_list_z32 TO ls_compen_prices-price_list_z32.
  ENDSELECT.


  IF p_all = abap_true.
    CLEAR: lt_tespt, lt_tecde, lt_lief.
    SELECT * FROM tespt INTO TABLE lt_tespt WHERE spartyp = /idxgc/if_constants=>gc_divcat_elec.

    IF NOT lt_tespt IS INITIAL.
      SELECT * FROM tecde INTO TABLE lt_tecde FOR ALL ENTRIES IN lt_tespt
        WHERE division = lt_tespt-sparte
          AND intcode  = /idxgc/if_constants=>gc_service_code_supplier.
    ENDIF.

    IF NOT lt_tecde IS INITIAL.
      SELECT serviceid FROM eservprov INTO TABLE lt_lief FOR ALL ENTRIES IN lt_tecde WHERE service = lt_tecde-service.
    ENDIF.
  ELSE.
    LOOP AT so_lief ASSIGNING <ls_so_lief>.
      APPEND <ls_so_lief>-low TO lt_lief.
    ENDLOOP.
  ENDIF.

  LOOP AT lt_lief ASSIGNING <ls_lief>.
    ls_compen_prices-receiver = <ls_lief>.

* create data exchange task
* fill task data
    CLEAR ls_task_data.
    ls_task_data-dexrefdatefrom  = sy-datum.
    ls_task_data-dexservprov     = <ls_lief>.
    ls_task_data-dexservprovself = p_msb.
    ls_task_data-dexreftimeto    = /idexge/cl_datex_proc_gen=>co_time_infinite. "'235959'.
    ls_task_data-dexrefdateto    = /idexge/cl_datex_proc_gen=>co_date_infinite. "'99991231'

* fill interface data
    ls_interface_data-name = 'IV_SENDER'.
    GET REFERENCE OF p_msb INTO ls_interface_data-value.
    INSERT ls_interface_data INTO TABLE lt_interface_data.

    ls_interface_data-name = 'IV_RECEIVER'.
    GET REFERENCE OF <ls_lief> INTO ls_interface_data-value.
    INSERT ls_interface_data INTO TABLE lt_interface_data.

    ls_interface_data-name = 'IS_COMPEN_PRICES'.
    GET REFERENCE OF ls_compen_prices INTO ls_interface_data-value.
    INSERT ls_interface_data INTO TABLE lt_interface_data.

    lv_dexbasicproc = 'EXPPRICAT'.

* start datex processing
    CALL METHOD cl_isu_datex_controller=>start_ui_datex_basicprocess
      EXPORTING
        x_dexbasicproc     = lv_dexbasicproc
        x_task_data        = ls_task_data
        x_no_commit        = abap_false "iv_no_commit
*       xt_parameter       = lt_parameter
      IMPORTING
        yt_task            = lt_dextask
      CHANGING
        xyt_interface_data = lt_interface_data
      EXCEPTIONS
        no_dexproc_found   = 1
        OTHERS             = 2.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message.
      WRITE / 'PRICAT für Lieferant' &&  | | && <ls_lief> && | | && 'nicht versendet:' && | | && lv_message.
    ELSE.
      WRITE / 'PRICAT für Lieferant' && | | &&  <ls_lief> && | | && 'versendet'.

      READ TABLE lt_dextask ASSIGNING <ls_dextask> INDEX 1.
      IF sy-subrc = 0.
        IF <ls_dextask>-dexstatus = cl_isu_datex_process=>co_dexstatus_ok.
          CLEAR: ls_pricat_export.
          ls_pricat_export-dextaskid          = <ls_dextask>-dextaskid.
          ls_pricat_export-price_catalogue_id = p_pricat.
          ls_pricat_export-pricat_version     = p_priver.
          INSERT zisu_pricat_exp FROM ls_pricat_export.
          IF sy-subrc <> 0.
            WRITE / 'Tabelle ZISU_PRICAT_EXPORT konnte nicht aktualisiert werden'.
          ENDIF.
        ELSE.
          WRITE / 'Status der DA-Aufgabe ist <> "OK". Tabelle ZISU_PRICAT_EXPORT wird nicht aktualisiert.'.
        ENDIF.
      ENDIF.

    ENDIF.


  ENDLOOP.
