CLASS zhar_cl_tools DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.

    CLASS-METHODS convert_fpm_search_crit_to_sel
      IMPORTING
        !it_fpm_search_criteria TYPE fpmgb_t_search_criteria
      EXPORTING
        !et_usmd_select         TYPE usmd_ts_sel .
    CLASS-METHODS create_buffer_keystr
      IMPORTING
        !iv_prefix_key        TYPE string
        !it_keyfields         TYPE ANY TABLE
        !if_del_leading_zeros TYPE flag OPTIONAL
        !is_data              TYPE any
      RETURNING
        VALUE(rv_keystr)      TYPE string .
    CLASS-METHODS fill_buffer_table
      IMPORTING
        !irt_data             TYPE REF TO data OPTIONAL
        !it_data              TYPE data OPTIONAL
        !iv_prefix_key        TYPE string
        !it_keyfields         TYPE ANY TABLE
        !if_del_leading_zeros TYPE flag OPTIONAL
      CHANGING
        !ct_buffer            TYPE zhar_t_buffer .
    CLASS-METHODS append_selection_condition
      IMPORTING
        !iv_fieldname TYPE fieldname
        !iv_value     TYPE data
      CHANGING
        !ct_sel_cond  TYPE usmd_ts_sel .
    CLASS-METHODS get_search_values_from_domain
      IMPORTING
        !iv_field_name TYPE name_komp
        !iv_tab_name   TYPE tablenam
      EXPORTING
        !et_search_tab TYPE usmdz10_ts_ovs_output .
    CLASS-METHODS convert_usmd_messages
      IMPORTING
        !it_messages       TYPE usmd_t_message
      RETURNING
        VALUE(rt_messages) TYPE fpmgb_t_messages .
    CLASS-METHODS ends_with
      IMPORTING
        VALUE(iv_str)         TYPE string
        VALUE(iv_end_pattern) TYPE string
      RETURNING
        VALUE(rv_bool)        TYPE flag .
    CLASS-METHODS convert_bapi_messages
      IMPORTING
        !it_messages TYPE bapiret2_tab
      CHANGING
        !ct_messages TYPE fpmgb_t_messages .
    CLASS-METHODS add_bapi_to_fpmgb_msg
      IMPORTING
        !it_bapi_msg TYPE bapiret2_tab
      CHANGING
        !ct_messages TYPE fpmgb_t_messages .
    CLASS-METHODS add_sy_to_fpmgb_msg
      CHANGING
        !ct_messages TYPE fpmgb_t_messages .
    CLASS-METHODS add_usmd_to_fpmgb_msg
      CHANGING
        !ct_usmd_msg TYPE usmd_t_message
        !ct_messages TYPE fpmgb_t_messages .
    CLASS-METHODS add_sy_to_usmd_msg
      IMPORTING
        !iv_row      TYPE integer OPTIONAL
      CHANGING
        !ct_usmd_msg TYPE usmd_t_message .
    CLASS-METHODS add_sy_to_bapi_msg
      CHANGING
        !ct_bapi_msg TYPE bapiret2_tab .
    CLASS-METHODS get_component_value
      IMPORTING
        !is_data      TYPE any
        !iv_component TYPE any
      EXPORTING
        !ev_value     TYPE any
        !ev_type      TYPE any
      CHANGING
        !ct_usmd_msg  TYPE usmd_t_message .
    CLASS-METHODS add_bapi_to_usmd_msg
      CHANGING
        !ct_usmd_msg TYPE usmd_t_message
        !ct_bapi_msg TYPE bapiret2_tab .
    CLASS-METHODS add_usmd_to_bapi_msg
      CHANGING
        !ct_usmd_msg TYPE usmd_t_message
        !ct_bapi_msg TYPE bapiret2_tab .
    CLASS-METHODS add_usmd_msg_to_appl_log
      IMPORTING
        !it_usmd_msg   TYPE usmd_t_message
        !id_log_handle TYPE balloghndl .
    CLASS-METHODS get_components_flat
      IMPORTING
        !is_data       TYPE any OPTIONAL
        !it_components TYPE cl_abap_structdescr=>component_table OPTIONAL
      CHANGING
        !ct_components TYPE cl_abap_structdescr=>component_table .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zhar_cl_tools IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method zhar_CL_TOOLS=>ADD_BAPI_TO_FPMGB_MSG
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_BAPI_MSG                    TYPE        BAPIRET2_TAB
* | [<-->] CT_MESSAGES                    TYPE        FPMGB_T_MESSAGES
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD add_bapi_to_fpmgb_msg.

    DATA ls_message TYPE fpmgb_s_t100_message.

    DATA ls_bapi_msg TYPE bapiret2.
    DATA ls_usmd_msg TYPE usmd_s_message.

    LOOP AT it_bapi_msg INTO ls_bapi_msg.
      ls_message-msgid    = ls_bapi_msg-id.
      ls_message-severity = ls_bapi_msg-type.
      ls_message-msgno    = ls_bapi_msg-number.
      ls_message-parameter_1 = ls_bapi_msg-message_v1.
      ls_message-parameter_2 = ls_bapi_msg-message_v2.
      ls_message-parameter_3 = ls_bapi_msg-message_v3.
      ls_message-parameter_4 = ls_bapi_msg-message_v4.
      APPEND ls_message TO ct_messages.
    ENDLOOP.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method zhar_CL_TOOLS=>ADD_BAPI_TO_USMD_MSG
* +-------------------------------------------------------------------------------------------------+
* | [<-->] CT_USMD_MSG                    TYPE        USMD_T_MESSAGE
* | [<-->] CT_BAPI_MSG                    TYPE        BAPIRET2_TAB
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD add_bapi_to_usmd_msg.

    DATA ls_bapi_msg TYPE bapiret2.
    DATA ls_usmd_msg TYPE usmd_s_message.

    LOOP AT ct_bapi_msg INTO ls_bapi_msg.
      ls_usmd_msg-msgid = ls_bapi_msg-id.
      ls_usmd_msg-msgty = ls_bapi_msg-type.
      ls_usmd_msg-msgno = ls_bapi_msg-number.
      ls_usmd_msg-msgv1 = ls_bapi_msg-message_v1.
      ls_usmd_msg-msgv2 = ls_bapi_msg-message_v2.
      ls_usmd_msg-msgv3 = ls_bapi_msg-message_v3.
      ls_usmd_msg-msgv4 = ls_bapi_msg-message_v4.
      APPEND ls_usmd_msg TO ct_usmd_msg.
    ENDLOOP.

    CLEAR ct_bapi_msg.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method zhar_CL_TOOLS=>ADD_SY_TO_BAPI_MSG
* +-------------------------------------------------------------------------------------------------+
* | [<-->] CT_BAPI_MSG                    TYPE        BAPIRET2_TAB
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD add_sy_to_bapi_msg.

    DATA ls_bapi_msg TYPE bapiret2.

    ls_bapi_msg-id         = sy-msgid.
    ls_bapi_msg-type       = sy-msgty.
    ls_bapi_msg-number     = sy-msgno.
    ls_bapi_msg-message_v1 = sy-msgv1.
    ls_bapi_msg-message_v2 = sy-msgv2.
    ls_bapi_msg-message_v3 = sy-msgv3.
    ls_bapi_msg-message_v4 = sy-msgv4.

    APPEND ls_bapi_msg TO ct_bapi_msg.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method zhar_CL_TOOLS=>ADD_SY_TO_FPMGB_MSG
* +-------------------------------------------------------------------------------------------------+
* | [<-->] CT_MESSAGES                    TYPE        FPMGB_T_MESSAGES
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD add_sy_to_fpmgb_msg.

    DATA ls_message TYPE fpmgb_s_t100_message.

    MOVE sy-msgty TO ls_message-severity.
    MOVE sy-msgid TO ls_message-msgid.
    MOVE sy-msgno TO ls_message-msgno.
    MOVE sy-msgv1 TO ls_message-parameter_1.
    MOVE sy-msgv2 TO ls_message-parameter_2.
    MOVE sy-msgv3 TO ls_message-parameter_3.
    MOVE sy-msgv4 TO ls_message-parameter_4.
    APPEND ls_message TO ct_messages.


  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method zhar_CL_TOOLS=>ADD_SY_TO_USMD_MSG
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ROW                         TYPE        integer
* | [<-->] CT_USMD_MSG                    TYPE        USMD_T_MESSAGE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD add_sy_to_usmd_msg.

    DATA ls_usmd_msg TYPE usmd_s_message.

    ls_usmd_msg-msgid = sy-msgid.
    ls_usmd_msg-msgty = sy-msgty.
    ls_usmd_msg-msgno = sy-msgno.
    ls_usmd_msg-msgv1 = sy-msgv1.
    ls_usmd_msg-msgv2 = sy-msgv2.
    ls_usmd_msg-msgv3 = sy-msgv3.
    ls_usmd_msg-msgv4 = sy-msgv4.

    ls_usmd_msg-row   = iv_row.

    APPEND ls_usmd_msg TO ct_usmd_msg.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method zhar_CL_TOOLS=>ADD_USMD_MSG_TO_APPL_LOG
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_USMD_MSG                    TYPE        USMD_T_MESSAGE
* | [--->] ID_LOG_HANDLE                  TYPE        BALLOGHNDL
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD add_usmd_msg_to_appl_log.

* Übernommen aus CL_USMDZ7_RS_usmd_msg

    DATA ls_usmd_msg   TYPE usmd_s_message.
    DATA ls_bal_log    TYPE bal_s_msg.
    DATA ls_params     TYPE bal_s_parm.
    DATA ls_par        TYPE bal_s_par.

    DATA lv_msgv1      TYPE balmi-msgv1.

* The usage of the class CL_USMD_APPL_LOG is not possible therefore
* using the function of EHP4. internal message 0120031469-241407-2009.
    LOOP AT it_usmd_msg INTO ls_usmd_msg.

      CLEAR ls_bal_log.
      ls_bal_log-msgty      = ls_usmd_msg-msgty.
      ls_bal_log-msgid      = ls_usmd_msg-msgid.
      ls_bal_log-msgno      = ls_usmd_msg-msgno.
      ls_bal_log-msgv1      = ls_usmd_msg-msgv1.
      ls_bal_log-msgv2      = ls_usmd_msg-msgv2.
      ls_bal_log-msgv3      = ls_usmd_msg-msgv3.
      ls_bal_log-msgv4      = ls_usmd_msg-msgv4.

      CLEAR ls_params.
      CLEAR ls_par.
      ls_par-parname        = cl_usmd_rule_service=>gc_msg_row.
      ls_par-parvalue       = ls_usmd_msg-row.
      APPEND ls_par TO ls_params-t_par.
      ls_par-parname        = cl_usmd_rule_service=>gc_msg_fieldname.
      ls_par-parvalue       = ls_usmd_msg-fieldname.
      APPEND ls_par TO ls_params-t_par.

      CONCATENATE ls_bal_log-msgty ls_bal_log-msgno '(' ls_bal_log-msgid ')' INTO ls_params-altext.
      ls_bal_log-params     = ls_params.

      CALL FUNCTION 'BAL_LOG_MSG_ADD'
        EXPORTING
          i_log_handle     = id_log_handle
          i_s_msg          = ls_bal_log
*     IMPORTING
*         E_S_MSG_HANDLE   =
*         E_MSG_WAS_LOGGED =
*         E_MSG_WAS_DISPLAYED       =
        EXCEPTIONS
          log_not_found    = 1
          msg_inconsistent = 2
          log_is_full      = 3
          OTHERS           = 4.
      IF sy-subrc <> 0.
        CASE sy-subrc.
          WHEN 1.
            lv_msgv1 = 'log not found'.                     "#EC NOTEXT
          WHEN 2.
            lv_msgv1 = 'message inconsistent'.              "#EC NOTEXT
          WHEN 3.
            lv_msgv1 = 'log is full'.                       "#EC NOTEXT
*      when others.
        ENDCASE.
        IF 1 = 0.
          MESSAGE e069(usmdz3) WITH lv_msgv1.
*   Fehler(&1): Keine Fortschreibung der Nachrichten ins Anwendungsproto
        ENDIF.
        CLEAR ls_bal_log.
        ls_bal_log-msgty      = if_usmdz_constants=>gc_msgty_error.
        ls_bal_log-msgid      = if_usmdz_constants=>gc_msgid_usmdz3.
        ls_bal_log-msgno      = '069'.
        ls_bal_log-msgv1      = lv_msgv1.
        ls_bal_log-msgv2      = space.
        ls_bal_log-msgv3      = space.
        ls_bal_log-msgv4      = space.

        CALL FUNCTION 'BAL_LOG_MSG_ADD'
          EXPORTING
            i_log_handle     = id_log_handle
            i_s_msg          = ls_bal_log
*     IMPORTING
*           E_S_MSG_HANDLE   =
*           E_MSG_WAS_LOGGED =
*           E_MSG_WAS_DISPLAYED       =
          EXCEPTIONS
            log_not_found    = 1
            msg_inconsistent = 2
            log_is_full      = 3
            OTHERS           = 4.
        IF sy-subrc NE 0.
          MESSAGE e069(usmdz3) WITH lv_msgv1.
*   Fehler(&1): Keine Fortschreibung der Nachrichten ins Anwendungsproto
        ENDIF.  "sy-subrc ne 0

      ENDIF.
    ENDLOOP.  "it_usmd_msg

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method zhar_CL_TOOLS=>ADD_USMD_TO_BAPI_MSG
* +-------------------------------------------------------------------------------------------------+
* | [<-->] CT_USMD_MSG                    TYPE        USMD_T_MESSAGE
* | [<-->] CT_BAPI_MSG                    TYPE        BAPIRET2_TAB
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD add_usmd_to_bapi_msg.

    DATA ls_bapi_msg TYPE bapiret2.
    DATA ls_usmd_msg TYPE usmd_s_message.

    LOOP AT ct_usmd_msg INTO ls_usmd_msg.
      ls_bapi_msg-id         = ls_usmd_msg-msgid.
      ls_bapi_msg-type       = ls_usmd_msg-msgty.
      ls_bapi_msg-number     = ls_usmd_msg-msgno.
      ls_bapi_msg-message_v1 = ls_usmd_msg-msgv1.
      ls_bapi_msg-message_v2 = ls_usmd_msg-msgv2.
      ls_bapi_msg-message_v3 = ls_usmd_msg-msgv3.
      ls_bapi_msg-message_v4 = ls_usmd_msg-msgv4.
      APPEND ls_bapi_msg TO ct_bapi_msg.
    ENDLOOP.

    CLEAR ct_usmd_msg.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method zhar_CL_TOOLS=>ADD_USMD_TO_FPMGB_MSG
* +-------------------------------------------------------------------------------------------------+
* | [<-->] CT_USMD_MSG                    TYPE        USMD_T_MESSAGE
* | [<-->] CT_MESSAGES                    TYPE        FPMGB_T_MESSAGES
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD add_usmd_to_fpmgb_msg.

    DATA ls_message TYPE fpmgb_s_t100_message.
    DATA ls_usmd_msg TYPE usmd_s_message.

    LOOP AT ct_usmd_msg INTO ls_usmd_msg.
      ls_message-msgid       = ls_usmd_msg-msgid.
      ls_message-severity    = ls_usmd_msg-msgty.
      ls_message-msgno       = ls_usmd_msg-msgno.
      ls_message-parameter_1 = ls_usmd_msg-msgv1.
      ls_message-parameter_2 = ls_usmd_msg-msgv2.
      ls_message-parameter_3 = ls_usmd_msg-msgv3.
      ls_message-parameter_4 = ls_usmd_msg-msgv4.
      APPEND ls_message TO ct_messages.
    ENDLOOP.
    CLEAR ct_usmd_msg.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method zhar_CL_TOOLS=>APPEND_SELECTION_CONDITION
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_FIELDNAME                   TYPE        FIELDNAME
* | [--->] IV_VALUE                       TYPE        DATA
* | [<-->] CT_SEL_COND                    TYPE        USMD_TS_SEL
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD append_selection_condition.
    DATA ls_selection_condition TYPE usmd_s_sel.

    CHECK iv_value IS NOT INITIAL.

    MOVE iv_fieldname TO ls_selection_condition-fieldname.
    MOVE 'I' TO ls_selection_condition-sign.

    IF iv_value CA '*?'.
      MOVE 'CP' TO ls_selection_condition-option.
    ELSE.
      MOVE 'EQ' TO ls_selection_condition-option.
    ENDIF.
    MOVE iv_value  TO ls_selection_condition-low.

    INSERT ls_selection_condition INTO TABLE ct_sel_cond.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method zhar_CL_TOOLS=>CONVERT_BAPI_MESSAGES
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_MESSAGES                    TYPE        BAPIRET2_TAB
* | [<-->] CT_MESSAGES                    TYPE        FPMGB_T_MESSAGES
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD convert_bapi_messages.

* Messageformat konvertieren

    DATA ls_message_in LIKE LINE OF it_messages.
    DATA ls_message_out LIKE LINE OF ct_messages.



** Schleife über Eingabetabelle
    LOOP AT it_messages INTO ls_message_in.
      CLEAR ls_message_out.
      MOVE ls_message_in-type TO ls_message_out-severity.
      MOVE ls_message_in-id TO ls_message_out-msgid.
      MOVE ls_message_in-number TO ls_message_out-msgno.
      MOVE ls_message_in-message_v1 TO ls_message_out-parameter_1.
      MOVE ls_message_in-message_v2 TO ls_message_out-parameter_2.
      MOVE ls_message_in-message_v3 TO ls_message_out-parameter_3.
      MOVE ls_message_in-message_v4 TO ls_message_out-parameter_4.
      APPEND ls_message_out TO ct_messages.
    ENDLOOP.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method zhar_CL_TOOLS=>CONVERT_FPM_SEARCH_CRIT_TO_SEL
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_FPM_SEARCH_CRITERIA         TYPE        FPMGB_T_SEARCH_CRITERIA
* | [<---] ET_USMD_SELECT                 TYPE        USMD_TS_SEL
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD convert_fpm_search_crit_to_sel.
    DATA lt_search_attributes TYPE usmd_ts_sel.
    DATA ls_search_attribute  TYPE usmd_s_sel.


    FIELD-SYMBOLS <ls_search_crit>  TYPE fpmgb_s_search_criteria.

    LOOP AT it_fpm_search_criteria ASSIGNING <ls_search_crit>.
      ls_search_attribute-sign      = <ls_search_crit>-sign.
      ls_search_attribute-fieldname = <ls_search_crit>-search_attribute.
      ls_search_attribute-low       = <ls_search_crit>-low.
      ls_search_attribute-high      = <ls_search_crit>-high.
      CASE <ls_search_crit>-operator.
        WHEN '01' OR '06' OR '17'.  " ist
          ls_search_attribute-option  =  'EQ'.
          IF ls_search_attribute-low CA '*?+'.
            ls_search_attribute-option  =  'CP'.
            REPLACE ALL OCCURRENCES OF '?' IN ls_search_attribute-low WITH '+'.
          ENDIF.
        WHEN '02' OR '07'.  "ist nicht
          ls_search_attribute-option  =  'NE'.
          IF ls_search_attribute-low CA '*?+'.
            REPLACE ALL OCCURRENCES OF '?' IN ls_search_attribute-low WITH '+'.
            ls_search_attribute-option  = 'NP'.
          ENDIF.
        WHEN '03'. "ist leer
          ls_search_attribute-option  =  'EQ'.
          CLEAR ls_search_attribute-low.
        WHEN '04'. "beginnt mit
          ls_search_attribute-option  =  'CP'.
          ls_search_attribute-low     = ls_search_attribute-low && '*'.
        WHEN '05'. " enthält
          ls_search_attribute-option  =  'CP'.
          ls_search_attribute-low     =  '*' && ls_search_attribute-low && '*'.
        WHEN '08' OR '12'. " ist größer als
          ls_search_attribute-option  =  'GT'.
        WHEN '09' OR '11'. " ist kleiner als
          ls_search_attribute-option  =  'LT'.
        WHEN '10' OR '13'. " ist zwischen
          ls_search_attribute-option  =  'BT'.
        WHEN '14'. " liegt nicht innerhalb
          ls_search_attribute-option  =  'NB'.
        WHEN '15'. " enthält alle Texte
          ls_search_attribute-option  =  'CP'.
        WHEN '16'. " enthält einen der Texte
          ls_search_attribute-option  =  'CP'.
        WHEN '18'. "  enthält keinen der Texte
          ls_search_attribute-option  =  'NP'.
          ls_search_attribute-low     =  '*' && ls_search_attribute-low && '*'.
        WHEN '19'. "  ist größer oder gleich
          ls_search_attribute-option  =  'GE'.
        WHEN '20'. "  ist kleiner oder gleich
          ls_search_attribute-option  =  'LE'.
        WHEN '21'. "  ist früher als oder am
          ls_search_attribute-option  =  'LE'.
        WHEN '22'. "  ist später als oder am
          ls_search_attribute-option  =  'GE'.
        WHEN '23'. "  ist nicht leer
          ls_search_attribute-option  =  'NE'.
          CLEAR ls_search_attribute-low.
        WHEN '24'. "  ist ähnlich
          ls_search_attribute-option  =  'CS'.
      ENDCASE.
      INSERT ls_search_attribute INTO TABLE lt_search_attributes.
    ENDLOOP.

    et_usmd_select = lt_search_attributes.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method zhar_CL_TOOLS=>CONVERT_USMD_MESSAGES
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_MESSAGES                    TYPE        USMD_T_MESSAGE
* | [<-()] RT_MESSAGES                    TYPE        FPMGB_T_MESSAGES
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD convert_usmd_messages.

* Messageformat konvertieren

    DATA ls_message_in LIKE LINE OF it_messages.
    DATA ls_message_out LIKE LINE OF rt_messages.



** Schleife über Eingabetabelle
    LOOP AT it_messages INTO ls_message_in.
      CLEAR ls_message_out.
      MOVE ls_message_in-msgty TO ls_message_out-severity.
      MOVE ls_message_in-msgid TO ls_message_out-msgid.
      MOVE ls_message_in-msgno TO ls_message_out-msgno.
      MOVE ls_message_in-msgv1 TO ls_message_out-parameter_1.
      MOVE ls_message_in-msgv2 TO ls_message_out-parameter_2.
      MOVE ls_message_in-msgv3 TO ls_message_out-parameter_3.
      MOVE ls_message_in-msgv4 TO ls_message_out-parameter_4.
      APPEND ls_message_out TO rt_messages.
    ENDLOOP.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method zhar_CL_TOOLS=>CREATE_BUFFER_KEYSTR
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_PREFIX_KEY                  TYPE        STRING
* | [--->] IT_KEYFIELDS                   TYPE        ANY TABLE
* | [--->] IF_DEL_LEADING_ZEROS           TYPE        FLAG(optional)
* | [--->] IS_DATA                        TYPE        ANY
* | [<-()] RV_KEYSTR                      TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD create_buffer_keystr.
    FIELD-SYMBOLS  <lv_fieldname>      TYPE any.
    FIELD-SYMBOLS  <lv_value>          TYPE any.
    DATA lv_value   TYPE string.

    rv_keystr     = iv_prefix_key.
    LOOP AT it_keyfields ASSIGNING <lv_fieldname>.
      ASSIGN COMPONENT <lv_fieldname> OF STRUCTURE is_data TO <lv_value>.
      lv_value = <lv_value>.
      IF if_del_leading_zeros = 'X'.
        SHIFT lv_value LEFT DELETING LEADING '0'.
      ENDIF.
      rv_keystr = rv_keystr && '|' && lv_value.
    ENDLOOP.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method zhar_CL_TOOLS=>ENDS_WITH
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_STR                         TYPE        STRING
* | [--->] IV_END_PATTERN                 TYPE        STRING
* | [<-()] RV_BOOL                        TYPE        FLAG
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD ends_with.
    DATA lv_len TYPE i.
    DATA lv_len2 TYPE i.
    DATA lv_pos TYPE i.

    lv_len = strlen( iv_str ).
    lv_len2 = strlen( iv_end_pattern ).
    lv_pos  = lv_len - lv_len2.
    IF lv_pos >= 0 AND iv_str+lv_pos(lv_len2) = iv_end_pattern.
      rv_bool = 'X'.
    ELSE.
      rv_bool = ''.
    ENDIF.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method zhar_CL_TOOLS=>FILL_BUFFER_TABLE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IRT_DATA                       TYPE REF TO DATA(optional)
* | [--->] IT_DATA                        TYPE        DATA(optional)
* | [--->] IV_PREFIX_KEY                  TYPE        STRING
* | [--->] IT_KEYFIELDS                   TYPE        ANY TABLE
* | [--->] IF_DEL_LEADING_ZEROS           TYPE        FLAG(optional)
* | [<-->] CT_BUFFER                      TYPE        zhar_T_BUFFER
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD fill_buffer_table.
    DATA           lv_keystr            TYPE string.
    DATA           ls_search_buffer    TYPE zhar_s_buffer.

    FIELD-SYMBOLS  <lt_data>           TYPE  ANY TABLE.
    FIELD-SYMBOLS  <ls_data>           TYPE  any.
    FIELD-SYMBOLS  <lt_data2>          TYPE ANY TABLE.
    FIELD-SYMBOLS  <ls_search_buffer>  TYPE zhar_s_buffer.

    IF irt_data IS SUPPLIED.
      ASSIGN irt_data->* TO <lt_data>.
    ELSEIF it_data IS SUPPLIED.
      ASSIGN it_data  TO <lt_data>.
    ELSE.
      MESSAGE 'no table with data supplied' TYPE 'X'.
    ENDIF.

    LOOP AT <lt_data> ASSIGNING <ls_data>.
      " keystring aus prefix und schluesselfeldern bilden
      lv_keystr = create_buffer_keystr(
        EXPORTING
          iv_prefix_key        =  iv_prefix_key  " Kennung für Daten
          it_keyfields         =  it_keyfields   " Namen der Schlüsselfelder
          if_del_leading_zeros =  if_del_leading_zeros
          is_data              =  <ls_data>      " Tabellenzeile mit Schlüsselfeldern
      ).

      " datentabelle anlegen oder ggfs ergänzen
      READ TABLE ct_buffer ASSIGNING <ls_search_buffer> WITH TABLE KEY keyfield = lv_keystr.
      IF sy-subrc NE 0.
        " neu anlegen
        ls_search_buffer-keyfield = lv_keystr.
        CREATE DATA ls_search_buffer-data LIKE <lt_data>.
        INSERT ls_search_buffer INTO TABLE ct_buffer.
        " referenz lesen um datentabelle zu ergänzen
        READ TABLE ct_buffer ASSIGNING <ls_search_buffer> WITH TABLE KEY keyfield = lv_keystr.
      ENDIF.
      " datentabelle ergänzgen
      ASSIGN <ls_search_buffer>-data->* TO <lt_data2>.
      INSERT <ls_data> INTO TABLE <lt_data2>.
    ENDLOOP.

    " Marker das was gelesen wurde
    ls_search_buffer-keyfield = iv_prefix_key.
    CLEAR ls_search_buffer-data.
    INSERT ls_search_buffer INTO TABLE ct_buffer.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method zhar_CL_TOOLS=>GET_COMPONENTS_FLAT
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_DATA                        TYPE        ANY(optional)
* | [--->] IT_COMPONENTS                  TYPE        CL_ABAP_STRUCTDESCR=>COMPONENT_TABLE(optional)
* | [<-->] CT_COMPONENTS                  TYPE        CL_ABAP_STRUCTDESCR=>COMPONENT_TABLE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_components_flat.
    DATA lr_structdescr     TYPE REF TO cl_abap_structdescr.
    DATA lr_typedescr       TYPE REF TO cl_abap_typedescr.
    DATA lr_tabledescr      TYPE REF TO cl_abap_tabledescr.
    DATA lr_datadescr       TYPE REF TO cl_abap_datadescr.
    DATA lr_refdescr        TYPE REF TO cl_abap_refdescr.
    DATA lt_components      TYPE abap_component_tab.
    DATA lt_components_sub  TYPE abap_component_tab.
    FIELD-SYMBOLS <ls_component>    TYPE LINE OF abap_component_tab.

    IF it_components IS SUPPLIED.
      lt_components = it_components.
    ELSE.
      lr_structdescr ?= cl_abap_datadescr=>describe_by_data( p_data = is_data  ).
      lt_components = lr_structdescr->get_components( ).
    ENDIF.

    LOOP AT lt_components ASSIGNING <ls_component>.
      lr_typedescr = <ls_component>-type.
      CASE lr_typedescr->kind.
        WHEN cl_abap_typedescr=>kind_table.
          lr_tabledescr ?= lr_typedescr.
          lr_datadescr = lr_tabledescr->get_table_line_type( ).
          lr_typedescr = lr_datadescr.
          "    PERFORM return_components USING lr_typedescr CHANGING ct_component.
        WHEN cl_abap_typedescr=>kind_struct.
          lr_structdescr ?= lr_typedescr.
          lt_components_sub = lr_structdescr->get_components( ).
          CALL METHOD get_components_flat
            EXPORTING
              it_components = lt_components_sub
            CHANGING
              ct_components = ct_components.    " Komponentenbeschreibungstabelle
        WHEN cl_abap_typedescr=>kind_elem.
          APPEND <ls_component> TO ct_components.
      ENDCASE.
    ENDLOOP.


  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method zhar_CL_TOOLS=>GET_COMPONENT_VALUE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_DATA                        TYPE        ANY
* | [--->] IV_COMPONENT                   TYPE        ANY
* | [<---] EV_VALUE                       TYPE        ANY
* | [<---] EV_TYPE                        TYPE        any
* | [<-->] CT_USMD_MSG                    TYPE        USMD_T_MESSAGE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_component_value.

    DATA lv_message TYPE string.
    DATA lv_type    TYPE c LENGTH 1.

    FIELD-SYMBOLS <lv_value> TYPE any.

    CLEAR ev_value.
    CLEAR ev_type.

    ASSIGN COMPONENT iv_component OF STRUCTURE is_data TO <lv_value>.

    IF sy-subrc EQ 0.
      ev_value = <lv_value>.
    ELSE.
      MESSAGE e015(zhar_val) INTO lv_message WITH iv_component.
      CALL METHOD add_sy_to_usmd_msg
        CHANGING
          ct_usmd_msg = ct_usmd_msg.
    ENDIF.

    DESCRIBE FIELD <lv_value> TYPE lv_type.

*    IF lv_type EQ 'b' OR
*      lv_type EQ 's' OR
*      lv_type EQ 'I' OR
*      lv_type EQ 'N'.
*      ev_type = zhar_if_rs_constants=>gc_data_type_numeric.
*    ELSEIF lv_type EQ 'C' OR
*      lv_type EQ 'g' OR
*      lv_type EQ 'D' OR
*      lv_type EQ 'T'.
*      ev_type = zhar_if_rs_constants=>gc_data_type_character.
*    ENDIF.

  ENDMETHOD.




* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method zhar_CL_TOOLS=>GET_SEARCH_VALUES_FROM_DOMAIN
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_FIELD_NAME                  TYPE        NAME_KOMP
* | [--->] IV_TAB_NAME                    TYPE        TABLENAM
* | [<---] ET_SEARCH_TAB                  TYPE        USMDZ10_TS_OVS_OUTPUT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_search_values_from_domain.
    DATA lt_dom_values   TYPE TABLE OF dd07v.
    DATA lv_langu        TYPE dd07t-ddlanguage.
    DATA ls_output       TYPE usmdz10_s_ovs_output.
    DATA lv_domname       TYPE dd04l-domname.

    FIELD-SYMBOLS  <ls_dom_value> TYPE dd07v.

    CLEAR et_search_tab.

    CALL FUNCTION 'TB_FIELD_GET_INFO'
      EXPORTING
        fieldname = iv_field_name    " Feldname
        tabname   = iv_tab_name " Tabellenname
      IMPORTING
        domname   = lv_domname  " Domänenname
*       rollname  =     " Datenelementname
*       description   =     " Kurzbeschreibung
*       length_field  =     " Ausgabelänge des Feldes
*       length_header =     " Länge der Überschrift
*       length_long   =     " Länge des Schlüsselworts lang
*       length_middle =     " Länge des Schlüsselworts mittel
*       length_short  =     " Länge des Schlüsselworts kurz
*       text_header   =     " Überschrift
*       text_long =     " Schlüsselwort lang
*       text_middle   =     " Schlüsselwort mittel
*       text_short    =     " Schlüsselwort kurz
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'X'  NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    lv_langu = sy-langu.
    CALL FUNCTION 'DD_DOMVALUES_GET'
      EXPORTING
        domname       = lv_domname
        text          = 'X'
        langu         = lv_langu
        bypass_buffer = 'X'
      TABLES
        dd07v_tab     = lt_dom_values.

    LOOP AT lt_dom_values ASSIGNING <ls_dom_value>.
      ls_output-key   =  <ls_dom_value>-domvalue_l.
      ls_output-text  =  <ls_dom_value>-ddtext.
      INSERT ls_output INTO TABLE et_search_tab.
    ENDLOOP.
    ls_output-key     = ''.
    ls_output-text    = 'Default' .
    INSERT ls_output INTO TABLE et_search_tab.

  ENDMETHOD.
ENDCLASS.

