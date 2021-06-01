FUNCTION z_isu_sample_r470.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_ERDK) LIKE  ERDK STRUCTURE  ERDK
*"     REFERENCE(I_CANC_PARAM) TYPE  ISU21_CANC_PARAM OPTIONAL
*"     REFERENCE(I_CANC_DOC_ACC) TYPE  ISU21_ACC OPTIONAL
*"  EXCEPTIONS
*"      GENERAL_ERROR
*"----------------------------------------------------------------------
  DATA: lv_opbel TYPE erdk-opbel.

  INCLUDE meamac00.                      " Makros
  INCLUDE emsg.

  DATA: lt_erdb       TYPE STANDARD TABLE OF erdb,
        lv_anzahl_i   TYPE i,
        lv_titel(255) TYPE c,
        lv_txt1(255)  TYPE c,
        lv_txt2(255)  TYPE c,
        lv_txt3(255)  TYPE c,
        lv_txt4(255)  TYPE c,
        lv_answer     TYPE c.
  FIELD-SYMBOLS: <fs_erdb> TYPE erdb.

  CALL FUNCTION 'ISU_EVENT_CHCK_RVRSLLOCK_R470'
    EXPORTING
      i_erdk         = i_erdk
      i_canc_param   = i_canc_param
      i_canc_doc_acc = i_canc_doc_acc.

  lv_anzahl_i = 0.

*  lv_titel = '!!!ACHTUNG!!!'.
*  lv_txt1  = 'Rechnungskorrekturen, Forderung im Inkassoverfahren bei externen DL, Forderung verändert sich:'.
*  lv_txt2  = 'Nach Rechnungskorr. darf die Rechnung nicht dem Kunden zugestellt werden. Die Original-Rechnung (mit Logo) an inkassodienstleister@enervie-gruppe.de zu senden. (Korrekturgrund angeben!). Rechnung wird durch Inkasso-DL zugestellt.'.
*  lv_txt3  = 'Rechnungskorrekturen, Forderung im Inkassoverfahren bei externen DL, Forderung entfällt:'.
*  lv_txt4  = 'Bitte E-Mail unter Angabe des Grundes der Gutschrift oder des Stornos an inkassodienstleister@enervie-gruppe.de senden, damit die Einstellung des Vorgang beim Inkasso-Dienstleister veranlasst wird'.

  SELECT * INTO TABLE lt_erdb FROM erdb WHERE opbel = i_erdk-opbel.

  LOOP AT lt_erdb ASSIGNING <fs_erdb>.

    SELECT SINGLE opbel FROM dfkkcoll INTO lv_opbel
      WHERE opbel = <fs_erdb>-invopbel. " AND agsta = '02'.

    IF sy-subrc = 0.
      mac_msg_put 'W002(ZMESS)' <fs_erdb>-invopbel space space space general_error.
      lv_anzahl_i = lv_anzahl_i + 1.
    ENDIF.

  ENDLOOP.

  IF lv_anzahl_i GE 1.

    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar              = '!!!ACHTUNG!!!'
*       DIAGNOSE_OBJECT       = ' '
        text_question         = 'Vorsicht bei Rechnungskorrekturen      Forderungen im Inkassoverfahren           Forderung neu:'
        text_button_1         = 'Änderung'(001)
*       ICON_BUTTON_1         = ' '
        text_button_2         = 'Obsolet'(002)
*       ICON_BUTTON_2         = ' '
        default_button        = '1'
        display_cancel_button = ''
*       USERDEFINED_F1_HELP   = ' '
*       START_COLUMN          = 25
*       START_ROW             = 6
        popup_type            = 'ICON_MESSAGE_WARNING'
*       IV_QUICKINFO_BUTTON_1 = ' '
*       IV_QUICKINFO_BUTTON_2 = ' '
      IMPORTING
        answer                = lv_answer
* TABLES
*       PARAMETER             =
* EXCEPTIONS
*       TEXT_NOT_FOUND        = 1
*       OTHERS                = 2
*
      .
    CASE lv_answer.
      WHEN '1'.
        CALL FUNCTION 'POPUP_FOR_INTERACTION'
          EXPORTING
            headline       = '!!!ACHTUNG!!!'
            text1          = 'Nach der Rechnungskorrektur darf die Rechnung nicht dem'
            text2          = 'Kunden zugestellt werden. Die Original-Rechnung (mit'
            text3          = 'Logo) ist an inkassodienstleister@enervie-gruppe.de '
            text4          = 'zu senden.UNBEDINGT KORREKTURGRUND ANGEBEN! Rechnung'
            text5          = 'wird dem Kunden durch den Inkasso-Dienstleister unter'
            text6          = 'Bekanntgabe der neuen Gesamtforderung zugestellt.  '
            ticon          = 'I'
            button_1       = 'OK'
*           BUTTON_2       = ' '
*           BUTTON_3       = ' '
          IMPORTING
            button_pressed = lv_answer.
      WHEN '2'.
        CALL FUNCTION 'POPUP_FOR_INTERACTION'
          EXPORTING
            headline       = '!!!ACHTUNG!!!'
            text1          = 'Bitte E-Mail unter Angabe des Grundes der Gutschrift '
            text2          = 'oder des Stornos an inkassodienstleister@enervie-gruppe.de '
            TEXT3          = 'senden, damit die Einstellung des Vorgang beim'
            TEXT4          = 'Inkasso-Dienstleister veranlasst wird.'
*           TEXT5          = ' '
*           TEXT6          = ' '
            ticon          = 'I'
            button_1       = 'OK'
*           BUTTON_2       = ' '
*           BUTTON_3       = ' '
          IMPORTING
            button_pressed = lv_answer.
      WHEN OTHERS.
        CALL FUNCTION 'POPUP_FOR_INTERACTION'
          EXPORTING
            headline       = '!!!ACHTUNG!!!'
            text1          = 'Bitte Verfahrensweise beachten! Info unter inkassodienstleister@enervie-gruppe.de.'
*           TEXT2          = 'damit die Einstellung des Vorgang beim Inkasso-Dienstleister veranlasst wird.'
*           TEXT3          = 'UNBEDINGT KORREKTURGRUND ANGEBEN, damit der Inkasso-Dienstleister entsprechend informiert und instruiert werden kann '
*           TEXT4          = 'Die Rechnung wird dem Kunden durch den Inkasso-Dienstleister unter Bekanntgabe der neuen Gesamtforderung zugestellt. '
*           TEXT5          = ' '
*           TEXT6          = ' '
            ticon          = 'I'
            button_1       = 'OK'
*           BUTTON_2       = ' '
*           BUTTON_3       = ' '
          IMPORTING
            button_pressed = lv_answer.
    ENDCASE.
    mac_msg_put 'W003(ZMESS)' lv_anzahl_i space space space general_error.

*CASE lv_answer.
*  WHEN '1'.
*      mac_msg_put 'W003(ZMESS)' lv_anzahl_i space space space space.
*  WHEN '2'.
*      mac_msg_put 'e003(ZMESS)' lv_anzahl_i space space space space.
*  WHEN OTHERS.
*      mac_msg_put 'e003(ZMESS)' lv_anzahl_i space space space space.
* ENDCASE.
  ENDIF.

ENDFUNCTION.
