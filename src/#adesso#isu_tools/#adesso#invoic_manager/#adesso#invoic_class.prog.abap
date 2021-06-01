*&---------------------------------------------------------------------*
*&  Include           ZAD_INVOIC_CLASS
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&       Class lcl_send_mail
*&---------------------------------------------------------------------*
*        Text
*----------------------------------------------------------------------*
CLASS lcl_send_mail DEFINITION.

  PUBLIC SECTION.

    TYPES: type_t_cust TYPE TABLE OF /adesso/inv_chk WITH DEFAULT KEY.

    METHODS: constructor,

      set_content IMPORTING
                    VALUE(iv_ext_invoice_no) TYPE tinv_inv_doc-ext_invoice_no
                    VALUE(iv_ext_ui)         TYPE euitrans-ext_ui
                    VALUE(iv_anlage)         TYPE eanl-anlage,

      send_mail IMPORTING VALUE(im_subject) TYPE sood-objdes DEFAULT 'INVOICE:'
                EXPORTING VALUE(em_betreff) TYPE string
                          VALUE(em_content) TYPE bcsy_text.


  PRIVATE SECTION.


    TYPES: BEGIN OF s_record,
             ext_invoice_no TYPE tinv_inv_doc-ext_invoice_no,            "DOC
             ext_ui         TYPE euitrans-ext_ui,                        "Externe Zählpunktbezeichnung
             anlage         TYPE eanl-anlage,
           END OF s_record.

    DATA: it_records TYPE TABLE OF s_record.

    TYPES:  type_tline TYPE STANDARD TABLE OF tline WITH DEFAULT KEY.

    METHODS:          get_subject IMPORTING VALUE(iv_subject) TYPE sood-objdes
                                  RETURNING VALUE(ev_subject) TYPE sood-objdes.

    METHODS:   add_record_to_mailbody CHANGING VALUE(iv_content) TYPE bcsy_text,

      get_mailbody RETURNING VALUE(rv_content) TYPE bcsy_text,

      get_full_username RETURNING VALUE(ev_full_username) TYPE so_adrnam,

      get_baustein
        IMPORTING VALUE(iv_text_typ) TYPE /adesso/invoic_check_val
        RETURNING VALUE(ev_baustein) TYPE type_tline,

      baustein_selection IMPORTING VALUE(iv_t_bausteine) TYPE type_t_cust
                         RETURNING VALUE(ev_baustein)    TYPE /adesso/inv_chk,

      get_footer CHANGING VALUE(iv_content) TYPE bcsy_text.




ENDCLASS.               "lcl_send_mail


*----------------------------------------------------------------------*
*       CLASS LCL_CUSTOMIZING_DATA DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_customizing_data DEFINITION.

  PUBLIC SECTION.

    TYPES: type_t_cust TYPE TABLE OF /adesso/inv_chk WITH DEFAULT KEY,
           type_t_bdc  TYPE TABLE OF bdcdata WITH DEFAULT KEY.

    METHODS:    constructor

      .
    CLASS-METHODS: get_config IMPORTING VALUE(iv_option)   TYPE /adesso/invoic_check_option OPTIONAL
                                        VALUE(iv_category) TYPE /adesso/invoic_check_cat OPTIONAL
                                        VALUE(iv_field)    TYPE /adesso/invoic_check_field OPTIONAL
                                        VALUE(iv_id)       TYPE /adesso/invoic_check_id OPTIONAL
                              RETURNING VALUE(rv_t_values) TYPE type_t_cust,

      get_config_value IMPORTING VALUE(iv_option)   TYPE /adesso/invoic_check_option
                                 VALUE(iv_category) TYPE /adesso/invoic_check_cat
                                 VALUE(iv_field)    TYPE /adesso/invoic_check_field
                                 VALUE(iv_id)       TYPE /adesso/invoic_check_id
                       RETURNING VALUE(rv_value)    TYPE /adesso/invoic_check_val.



ENDCLASS.                    "LCL_CUSTOMIZING_DATA DEFINITION

*&---------------------------------------------------------------------*
*&       Class (Implementation)  lcl_send_mail
*&---------------------------------------------------------------------*
*        Text
*----------------------------------------------------------------------*
CLASS lcl_send_mail IMPLEMENTATION.

* Konstruktor Methode
  METHOD constructor.

  ENDMETHOD.                    "constructor

  METHOD set_content.

    DATA: wa_record TYPE s_record.

    wa_record-ext_invoice_no  = iv_ext_invoice_no.
    wa_record-ext_ui          = iv_ext_ui.
    wa_record-anlage          = iv_anlage.

    APPEND wa_record TO it_records.

  ENDMETHOD.                    "set_content

  METHOD send_mail.

    DATA: out       TYPE ole2_object,
          strbody_2 TYPE string.
    DATA outmail TYPE ole2_object.
    DATA: strreplacestring TYPE string.

    DATA: lv_reply  TYPE /adesso/inv_chk-invchk_value,
          lv_sender TYPE /adesso/inv_chk-invchk_value,
          repl_rec  TYPE ole2_object.



    CREATE OBJECT out 'Outlook.Application'.
    CALL METHOD OF
        out
        'CREATEITEM' = outmail
      EXPORTING
        #1           = 0.

*    Mailempfänger
*    SET PROPERTY OF OUTMAIL 'TO' = 'Mail@Adresse.de;'.

*    Antwortadresse
    lcl_customizing_data=>get_config_value( EXPORTING iv_option =   'MAIL'
                                                      iv_category = 'REPLY'
                                                      iv_field =     'ADDRESS'
                                                      iv_id = '1'
                                            RECEIVING rv_value = lv_reply ).

    IF lv_reply IS NOT INITIAL.
      CALL METHOD OF
        outmail
          'ReplyRecipients' = repl_rec.
      CALL METHOD OF
        repl_rec
        'Add'
        EXPORTING
          #1 = lv_reply.
    ENDIF.

*   E-Mail im Namen eines anderen schreiben
    lcl_customizing_data=>get_config_value( EXPORTING iv_option = 'MAIL'
                                                iv_category = 'SENDER'
                                                iv_field = 'ADDRESS'
                                                iv_id = '1'
                                      RECEIVING rv_value = lv_sender ).

    IF lv_sender IS NOT INITIAL.
      SET PROPERTY OF outmail 'SentOnBehalfOfName' = lv_sender.
      SET PROPERTY OF outmail 'CC' = lv_sender.
    ENDIF.

*    Betreffzeile
    DATA strbetreff TYPE string.
    strbetreff = get_subject( im_subject ).
    SET PROPERTY OF outmail 'SUBJECT' = strbetreff.

    em_betreff = strbetreff.
    .
*    Textfenster entweder dies oder das untere
    DATA: lv_content TYPE bcsy_text,
          lv_line    TYPE soli.

    lv_content = get_mailbody( ).
    DATA strbody TYPE string.
    strbody = '<BODY><FONT FACE=ARIAL>'.

    LOOP AT lv_content INTO lv_line.
      CONCATENATE strbody lv_line INTO strbody SEPARATED BY '<BR>'.
    ENDLOOP.

    em_content = lv_content.

*   E-Mail anzeigen, damit Signatur aus Mailprogramm erzeugt wird und diese
*   für den weiteren Gebrauch ausgelesen werden kann.
    CALL METHOD OF
      outmail
      'GetInspector'.
    CALL METHOD OF
      outmail
      'Display'.
    GET PROPERTY OF outmail 'HTMLBODY' = strbody_2.

*   Mail-Body um den individuellen Text ergänzen
    DATA: nreplpos_start TYPE i,
          nreplpos_end   TYPE i.
    nreplpos_start = -1.
    SEARCH strbody_2 FOR '<BODY'.

    IF sy-subrc EQ 0.
      nreplpos_start = sy-fdpos.

      SEARCH strbody_2 FOR '>' STARTING AT nreplpos_start.

      IF sy-subrc EQ 0.
        nreplpos_end = sy-fdpos.
      ENDIF.
      strreplacestring = strbody_2+nreplpos_start(nreplpos_end).
    ENDIF.

    REPLACE strreplacestring IN strbody_2 WITH strbody.

    SET PROPERTY OF outmail 'BODYFORMAT' = '1'.
    SET PROPERTY OF outmail 'HTMLBODY' = strbody_2.

*    Hier könnte man Attachments anhängen
*    CALL METHOD OF OUTMAIL 'ATTACHMENTS' = atts.
*    CALL METHOD OF ATTS 'ADD'
*    EXPORTING #1 = <file-name-on-c:drive>.

    FREE OBJECT outmail.

    COMMIT WORK AND WAIT.


  ENDMETHOD.                    "send_mail

  METHOD get_subject.

    DATA: tmp_subject TYPE sood-objdes.
    tmp_subject = iv_subject.

    IF lines( it_records ) = 1.

      FIELD-SYMBOLS <fs_line> LIKE LINE OF it_records.
      READ TABLE it_records ASSIGNING <fs_line> INDEX 1.

      IF <fs_line> IS ASSIGNED.
        CONCATENATE tmp_subject ' /  ' <fs_line>-ext_invoice_no '_' sy-datum INTO ev_subject.
      ENDIF.
    ELSEIF lines( it_records ) > 1.

      CONCATENATE tmp_subject ' / DIVERSE' '_' sy-datum  INTO ev_subject.

    ENDIF.


  ENDMETHOD.                    "get_subject


  METHOD get_mailbody.

    DATA: it_mailbody_template TYPE TABLE OF tline.
    DATA: lv_body_line     TYPE tline,
          lv_full_username TYPE so_adrnam.

    it_mailbody_template = get_baustein( 'MAIL_BODY' ).

    lv_full_username = get_full_username( ).

    LOOP AT it_mailbody_template INTO lv_body_line.

      REPLACE '* ' WITH `` INTO lv_body_line.
      REPLACE '  ' WITH `` INTO lv_body_line.
      REPLACE '</BENUTZER>' WITH  lv_full_username INTO lv_body_line.

      FIND FIRST OCCURRENCE OF '</DATEN>' IN  lv_body_line.

      IF sy-subrc = 0.
        add_record_to_mailbody( CHANGING iv_content = rv_content ).
      ELSE.
        FIND FIRST OCCURRENCE OF '</FOOTER>' IN  lv_body_line.
        IF sy-subrc = 0.
          get_footer( CHANGING iv_content = rv_content ).
        ELSE.
          APPEND lv_body_line TO rv_content.
        ENDIF.
      ENDIF.


    ENDLOOP.


  ENDMETHOD.                    "get_mailbody


  METHOD get_baustein.

    DATA: it_bausteine TYPE TABLE OF /adesso/inv_chk.
    DATA: lv_text TYPE string.

    DATA: lv_readtext TYPE boolean.
    FIELD-SYMBOLS: <fs_baustein> TYPE /adesso/inv_chk.

    DATA: it_selection TYPE TABLE OF /adesso/inv_chk.
    DATA: tmpbaustein TYPE /adesso/inv_chk.

    DATA: BEGIN OF s_baustein,
            mandt    TYPE mandt,
            baustein TYPE tdobname,
            text_id  TYPE tdid,
            sprache  TYPE tdspras,
            object   TYPE tdobject,
          END OF s_baustein.

    DATA: wa_cust     TYPE /adesso/inv_chk,
          lv_baustein LIKE s_baustein.


    lcl_customizing_data=>get_config( EXPORTING iv_option = 'TEXT'
                                                iv_category = iv_text_typ
                                                iv_field = 'BAUSTEIN'
                                      RECEIVING rv_t_values = it_bausteine ).

    IF it_bausteine IS INITIAL.
      CLEAR lv_text.
      CONCATENATE 'Für die Kategorie ' iv_text_typ ' wurde kein Textbaustein'  'konfiguriert.' INTO lv_text.
      MESSAGE e000(e4) WITH lv_text.
    ENDIF.


    lv_readtext = abap_false.

    IF lines( it_bausteine ) > 1.

      lcl_customizing_data=>get_config( EXPORTING iv_option = 'TEXT'
                                                  iv_category = iv_text_typ
                                                  iv_field = 'BAUSTEIN'
                                         RECEIVING rv_t_values = it_selection ).


      tmpbaustein = baustein_selection( it_selection ).

      READ TABLE it_bausteine
        WITH  KEY mandt           = tmpbaustein-mandt
                  invchk_option   = tmpbaustein-invchk_option
                  invchk_category = tmpbaustein-invchk_category
                  invchk_field    = 'BAUSTEIN'
                  invchk_id       = tmpbaustein-invchk_id
        ASSIGNING <fs_baustein>.

      lv_readtext = abap_true.
    ELSEIF lines( it_bausteine ) = 1.

      READ TABLE it_bausteine ASSIGNING <fs_baustein> INDEX 1.
      lv_readtext = abap_true.

    ENDIF.

    IF <fs_baustein> IS NOT ASSIGNED.
      CLEAR lv_text.
      CONCATENATE 'Für die Kategorie ' iv_text_typ ' konnte der Textbaustein nicht ermittelt werden.' INTO lv_text.
      MESSAGE e000(e4) WITH lv_text.
      EXIT.
    ENDIF.

    CLEAR it_selection.
    lcl_customizing_data=>get_config( EXPORTING iv_option   = <fs_baustein>-invchk_option
                                                iv_category = <fs_baustein>-invchk_category
                                                iv_id       = <fs_baustein>-invchk_id
                                       RECEIVING rv_t_values = it_selection ).

    IF it_selection IS INITIAL.
      CLEAR lv_text.
      CONCATENATE
        'Für die Kategorie '
        <fs_baustein>-invchk_category
        ' wurde kein Textbaustein in der Konfiguration definiert.(2)'
      INTO lv_text.
      MESSAGE e000(e4) WITH lv_text.
      EXIT.
    ENDIF.


    LOOP AT it_selection INTO wa_cust.

      IF lv_baustein-mandt IS INITIAL.
        lv_baustein-mandt = wa_cust-mandt.
      ENDIF.

      CASE wa_cust-invchk_field.

        WHEN 'BAUSTEIN'.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = wa_cust-invchk_value
            IMPORTING
              output = lv_baustein-baustein.
        WHEN 'ID'.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = wa_cust-invchk_value
            IMPORTING
              output = lv_baustein-text_id.

        WHEN 'SPRACHE'.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = wa_cust-invchk_value
            IMPORTING
              output = lv_baustein-sprache.

        WHEN 'OBJECT'.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = wa_cust-invchk_value
            IMPORTING
              output = lv_baustein-object.

      ENDCASE.

    ENDLOOP.

    IF lv_readtext = abap_true.
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          client                  = lv_baustein-mandt
          id                      = lv_baustein-text_id
          language                = lv_baustein-sprache
          name                    = lv_baustein-baustein
          object                  = lv_baustein-object
        TABLES
          lines                   = ev_baustein
        EXCEPTIONS
          id                      = 1
          language                = 2
          name                    = 3
          not_found               = 4
          object                  = 5
          reference_check         = 6
          wrong_access_to_archive = 7
          OTHERS                  = 8.
      IF sy-subrc <> 0.
        CLEAR lv_text.
        CONCATENATE 'Der Textbaustein ' lv_baustein-baustein ' konnte nicht gelesen werden.' INTO lv_text.
        MESSAGE e000(e4) WITH lv_text.
      ENDIF.
    ENDIF.


  ENDMETHOD.                    "get_baustein


  METHOD get_full_username.

    DATA: lv_user_data TYPE soudatai1,
          lv_user      TYPE soudnamei1
          .

*   Username auslesen
    lv_user-sapname = sy-uname.

*   Benutzerdaten auslesen
    CALL FUNCTION 'SO_USER_READ_API1'
      EXPORTING
        user      = lv_user
      IMPORTING
        user_data = lv_user_data.

*   Den Benutzernamen im Klartext zurückgeben
    ev_full_username = lv_user_data-fullname.

  ENDMETHOD.                    "get_full_username

  METHOD add_record_to_mailbody.

    DATA: wa_record   TYPE s_record,
          it_tmp_text TYPE TABLE OF tline,
          lv_tmp_line TYPE tline,
          lv_date(10).
    LOOP AT it_records INTO wa_record.

      it_tmp_text = get_baustein( 'MAIL_RECORD' ).

      LOOP AT it_tmp_text INTO lv_tmp_line.


*        Converts SAP date from 20020901 to 01.09.2002
*        WRITE wa_record-invoice_date TO lv_date DD/MM/YYYY.

        REPLACE '</EXT_INV>' WITH wa_record-ext_invoice_no INTO lv_tmp_line.
        REPLACE '</EXT_UI>' WITH wa_record-ext_ui INTO lv_tmp_line.

        REPLACE '* ' WITH `` INTO lv_tmp_line.
        REPLACE '  ' WITH `` INTO lv_tmp_line.
        REPLACE ALL OCCURRENCES OF ','  IN lv_tmp_line WITH cl_abap_char_utilities=>horizontal_tab.
        APPEND lv_tmp_line TO iv_content.

      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.                    "add_record_to_mailbody


  METHOD baustein_selection.

    DATA: lv_t_values TYPE TABLE OF /adesso/invoic_check_val .
    DATA: lv_text TYPE string.
    DATA: wa_cust TYPE /adesso/inv_chk.

    LOOP AT iv_t_bausteine INTO wa_cust.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = wa_cust-invchk_value
        IMPORTING
          output = wa_cust-invchk_value.

      APPEND wa_cust-invchk_value TO lv_t_values.

    ENDLOOP.

    DATA: choice TYPE i.
    CALL FUNCTION 'POPUP_WITH_TABLE_DISPLAY'
      EXPORTING
        endpos_col   = 50
        endpos_row   = 5
        startpos_col = 5
        startpos_row = 5
        titletext    = 'Bitte Baustein auswählen'
      IMPORTING
        choise       = choice
      TABLES
        valuetab     = lv_t_values
      EXCEPTIONS
        break_off    = 1
        OTHERS       = 2.
    IF sy-subrc <> 0.
      MESSAGE e000(e4) WITH 'Fehler beim Aufruf der Textbausteinauswahl.'.
      EXIT.
    ENDIF.

    FIELD-SYMBOLS: <fs_baustein> TYPE /ADESSO/INM_MAIL.
    READ TABLE iv_t_bausteine ASSIGNING <fs_baustein> INDEX choice.

    IF <fs_baustein> IS ASSIGNED.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = wa_cust-invchk_value
        IMPORTING
          output = wa_cust-invchk_value.

      ev_baustein = <fs_baustein>.
    ENDIF.

  ENDMETHOD.                    "baustein_selection

  METHOD get_footer.

    DATA: it_tmp_text TYPE TABLE OF tline,
          lv_tmp_line TYPE tline.

    it_tmp_text = get_baustein( 'MAIL_FOOTER' ).

    LOOP AT it_tmp_text INTO lv_tmp_line.

      REPLACE '* ' WITH `` INTO lv_tmp_line.
      REPLACE '  ' WITH `` INTO lv_tmp_line.
      REPLACE ALL OCCURRENCES OF ','  IN lv_tmp_line WITH cl_abap_char_utilities=>horizontal_tab.
      APPEND lv_tmp_line TO iv_content.

    ENDLOOP.

  ENDMETHOD.                    "get_footer

ENDCLASS.               "lcl_send_mail



*----------------------------------------------------------------------*
*       CLASS lcl_customizing_data IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_customizing_data  IMPLEMENTATION.

  METHOD constructor.

  ENDMETHOD.                    "constructor

  METHOD get_config.

    DATA: where_tab   TYPE TABLE OF edpline,
          source_line TYPE          edpline.

    IF iv_option IS NOT INITIAL.
      CONCATENATE '/ADESSO/INV_CHK~INVCHK_OPTION EQ ''' iv_option ''' ' INTO source_line.
      APPEND source_line TO where_tab.
    ENDIF.

    IF iv_category IS NOT INITIAL.
      IF lines( where_tab ) <> 0.
        APPEND ' AND ' TO where_tab.
      ENDIF.
      CONCATENATE '/ADESSO/INV_CHK~INVCHK_CATEGORY EQ ''' iv_category ''' ' INTO source_line.
      APPEND source_line TO where_tab.
    ENDIF.

    IF iv_field IS NOT INITIAL.
      IF lines( where_tab ) <> 0.
        APPEND ' AND ' TO where_tab.
      ENDIF.
      CONCATENATE '/ADESSO/INV_CHK~INVCHK_FIELD EQ ''' iv_field ''' ' INTO source_line.
      APPEND source_line TO where_tab.
    ENDIF.

    IF iv_id IS NOT INITIAL.
      IF lines( where_tab ) <> 0.
        APPEND ' AND ' TO where_tab.
      ENDIF.

      DATA: lv_id(3) TYPE c.
      lv_id = iv_id.

      CONCATENATE '/ADESSO/INV_CHK~INVCHK_ID EQ ' lv_id ' ' INTO source_line.
      APPEND source_line TO where_tab.
    ENDIF.

    SELECT *
      INTO TABLE rv_t_values
      FROM /adesso/inv_chk
      WHERE     /adesso/inv_chk~mandt EQ sy-mandt AND (where_tab).


  ENDMETHOD.                    "get_config

  METHOD get_config_value.

    SELECT SINGLE invchk_value
  INTO rv_value
  FROM /adesso/inv_chk
  WHERE invchk_option    EQ iv_option
    AND invchk_category  EQ iv_category
    AND invchk_field     EQ iv_field
    AND invchk_id         EQ iv_id.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = rv_value
      IMPORTING
        output = rv_value.


  ENDMETHOD.                       "get_config_value

ENDCLASS.                    "lcl_customizing_data IMPLEMENTATION
