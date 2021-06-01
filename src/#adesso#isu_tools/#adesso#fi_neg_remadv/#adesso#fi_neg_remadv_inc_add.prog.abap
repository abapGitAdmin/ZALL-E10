*&---------------------------------------------------------------------*
*&  Include           ZAD_FI_NEG_REMADV_INC_ADD
*&---------------------------------------------------------------------*
TYPE-POOLS: bpc01.


*----------------------------------------------------------------------*
*       CLASS lcl_send_mail DEFINITION
*----------------------------------------------------------------------*
* Klasse zum verschicken von E-Mail-Nachrichten
*----------------------------------------------------------------------*
CLASS lcl_send_mail DEFINITION.

  PUBLIC SECTION.
    TYPES: type_t_cust TYPE TABLE OF /adesso/fi_remad WITH DEFAULT KEY.

    METHODS:  constructor,

      set_content IMPORTING
                    VALUE(iv_invoice_date)   TYPE tinv_inv_doc-invoice_date
                    VALUE(iv_ext_invoice_no) TYPE tinv_inv_doc-ext_invoice_no
                    VALUE(iv_crossref_no)    TYPE tinv_inv_line_a-own_invoice_no
                    VALUE(iv_rstgr)          TYPE tinv_inv_line_a-rstgr
                    VALUE(iv_text)           TYPE tinv_c_adj_rsnt-text
                    VALUE(iv_ext_ui)         TYPE euitrans-ext_ui
                    VALUE(iv_ext_ui_me)      TYPE euitrans-ext_ui              "Nuss 01.02.2018
                    VALUE(iv_free_text5)     TYPE /idexge/rej_noti_txt,

      send_mail IMPORTING VALUE(im_subject) TYPE sood-objdes DEFAULT 'Abweisung neg. REMADV',
      send_lotus_mail IMPORTING VALUE(im_subject) TYPE sood-objdes DEFAULT 'Abweisung neg. REMADV'
      .

  PRIVATE SECTION.


    TYPES: BEGIN OF s_record,
             invoice_date   TYPE tinv_inv_doc-invoice_date,               "DOC
             ext_invoice_no TYPE tinv_inv_doc-ext_invoice_no,             "DOC
             crossref_no    TYPE tinv_inv_line_a-own_invoice_no,
             rstgr          TYPE tinv_inv_line_a-rstgr,                  "AVIS-Zeile
             text           TYPE tinv_c_adj_rsnt-text,                   "Text zum Reklamationsgrund
             ext_ui         TYPE euitrans-ext_ui,                        "Externe Zählpunktbezeichnung
             ext_ui_melo    TYPE euitrans-ext_ui,                        "Nuss 01.02.2018
             free_text5     TYPE /idexge/rej_noti_txt,
           END OF s_record.

    TYPES:  type_tline TYPE STANDARD TABLE OF tline WITH DEFAULT KEY.

    DATA    : it_records TYPE TABLE OF s_record.



    METHODS: add_record_to_mailbody CHANGING VALUE(iv_content) TYPE bcsy_text,

      get_subject IMPORTING VALUE(iv_subject) TYPE sood-objdes
                  RETURNING VALUE(ev_subject) TYPE sood-objdes,

      get_mailbody RETURNING VALUE(rv_content) TYPE bcsy_text,

      get_full_username RETURNING VALUE(ev_full_username) TYPE so_adrnam,

      get_baustein
        IMPORTING VALUE(iv_text_typ) TYPE /adesso/fi_remad-negrem_value
        RETURNING VALUE(ev_baustein) TYPE type_tline,

      baustein_selection IMPORTING VALUE(iv_t_bausteine) TYPE type_t_cust
                         RETURNING VALUE(ev_baustein)    TYPE /adesso/fi_remad,

      get_footer CHANGING VALUE(iv_content) TYPE bcsy_text

      .

ENDCLASS.                    "lcl_Send_Mail DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_add_bcontact DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_bcontact DEFINITION.

  PUBLIC SECTION.
    METHODS:  constructor,

      set_contact IMPORTING VALUE(iv_partner)         TYPE but000-partner
                            VALUE(iv_vkont)           TYPE fkkvkp-vkont               "Nuss 08.02.2018
                            VALUE(iv_int_inv_doc_no)  TYPE tinv_inv_doc-int_inv_doc_no
                            VALUE(iv_int_inv_line_no) TYPE inv_int_inv_line_no
                            VALUE(iv_auto_data)       TYPE bpc01_bcontact_auto OPTIONAL,

      get_autodata IMPORTING VALUE(iv_gpart)           TYPE but000-partner
                             VALUE(iv_vkont)           TYPE fkkvkp-vkont               "Nuss 08.02.2018
                             VALUE(iv_int_inv_doc_no)  TYPE tinv_inv_doc-int_inv_doc_no
                             VALUE(iv_int_inv_line_no) TYPE inv_int_inv_line_no
                   RETURNING VALUE(ev_auto_data)       TYPE bpc01_bcontact_auto,


      check_for_contact IMPORTING VALUE(iv_gpart)          TYPE but000-partner
                                  VALUE(iv_int_inv_doc_no) TYPE tinv_inv_doc-int_inv_doc_no
                        RETURNING VALUE(rv_b_contexist)    TYPE boolean
                        .

  PRIVATE SECTION.

    DATA: BEGIN OF s_contact_config,
            cont_class     TYPE ct_cclass,
            cont_activity	 TYPE ct_activit,
            cont_type	     TYPE ct_ctype,
            cont_direction TYPE ct_coming,
            cont_cust_info TYPE ct_custinfo,
          END OF s_contact_config.
    TYPES: s_cont_conf LIKE s_contact_config.

    DATA: g_config TYPE s_cont_conf.

    METHODS:  get_config.

ENDCLASS.                    "lcl_add_bcontact DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_customizing_data DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_customizing_data DEFINITION.

  PUBLIC SECTION.


    TYPES: type_t_cust TYPE TABLE OF /adesso/fi_remad WITH DEFAULT KEY,
           type_t_bdc  TYPE TABLE OF bdcdata WITH DEFAULT KEY.

    METHODS:    constructor

      .
    CLASS-METHODS: get_config IMPORTING VALUE(iv_option)   TYPE /adesso/fi_neg_remadv_option OPTIONAL
                                        VALUE(iv_category) TYPE /adesso/fi_neg_remadv_cat OPTIONAL
                                        VALUE(iv_field)    TYPE /adesso/fi_neg_remadv_field OPTIONAL
                                        VALUE(iv_id)       TYPE /adesso/fi_neg_remadv_id OPTIONAL
                              RETURNING VALUE(rv_t_values) TYPE type_t_cust,

      get_config_value IMPORTING VALUE(iv_option)   TYPE /adesso/fi_neg_remadv_option
                                 VALUE(iv_category) TYPE /adesso/fi_neg_remadv_cat
                                 VALUE(iv_field)    TYPE /adesso/fi_neg_remadv_field
                                 VALUE(iv_id)       TYPE /adesso/fi_neg_remadv_id
                       RETURNING VALUE(rv_value)    TYPE /adesso/fi_neg_remadv_val,

      get_batch_data IMPORTING VALUE(iv_option) TYPE /adesso/fi_neg_remadv_option
                     RETURNING VALUE(rv_t_bdc)  TYPE type_t_bdc,


      determine_values  IMPORTING VALUE(iv_t_bdc)   TYPE type_t_bdc
                                  VALUE(iv_wa_data) TYPE any
                        RETURNING VALUE(rv_t_bdc)   TYPE type_t_bdc

                        .
  PRIVATE SECTION.

ENDCLASS.                    "lcl_customizing_data DEFINITION


*----------------------------------------------------------------------*
*       CLASS lcl_Send_Mail IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_send_mail IMPLEMENTATION.

* METH_INFO "Konstruktor"
  METHOD constructor.



  ENDMETHOD.                    "constructor

* METH_INFO "Inhalte für den Mailtext übergeben"
  METHOD set_content.
*     importing value(iv_invoice_date)    type tinv_inv_doc-invoice_date
*                                    value(iv_ext_invoice_no)  type tinv_inv_doc-ext_invoice_no
*                                    value(iv_rstgr)           type tinv_inv_line_a-rstgr
*                                    value(iv_text)            type tinv_c_adj_rsnt-text
*                                    value(iv_ext_ui)          type euitrans-ext_ui,

    DATA: wa_record TYPE s_record.

    wa_record-invoice_date    = iv_invoice_date.
    wa_record-ext_invoice_no  = iv_ext_invoice_no.
    wa_record-crossref_no     = iv_crossref_no.
    wa_record-rstgr           = iv_rstgr.
    wa_record-text            = iv_text.
    wa_record-ext_ui          = iv_ext_ui.
    wa_record-ext_ui_melo     = iv_ext_ui_me.                     "Nuss 01.02.2018
    wa_record-free_text5      = iv_free_text5.

    APPEND wa_record TO it_records.

  ENDMETHOD.                    "set_content


* METH_INFO "Dialog für den Mailversand öffnen und vordefinierte Werte übergeben"
  METHOD send_mail.
    DATA: out       TYPE ole2_object,
          strbody_2 TYPE string.
    DATA outmail TYPE ole2_object.
    DATA: strreplacestring TYPE string.

    DATA: lv_reply  TYPE /adesso/fi_remad-negrem_value,
          lv_sender TYPE /adesso/fi_remad-negrem_value,
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
    lcl_customizing_data=>get_config_value( EXPORTING iv_option = 'MAIL'
                                                iv_category = 'REPLY'
                                                iv_field = 'ADDRESS'
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

  METHOD send_lotus_mail.


    DATA: notessession TYPE ole2_object,
          maildb       TYPE ole2_object,
          memo         TYPE ole2_object,
          notesrtf     TYPE ole2_object,
          noteshtm     TYPE ole2_object,
          signature_r  TYPE ole2_object,
          signature_1  TYPE ole2_object,
          signature_2  TYPE ole2_object,
          uiws         TYPE ole2_object,
          profile      TYPE ole2_object,
          esigobj      TYPE ole2_object,
          osigobj      TYPE ole2_object.


    DATA: strbetreff TYPE string,
          esig       TYPE string,
          osig       TYPE string,
          sig_1      TYPE string,
          sig_2      TYPE string.

    DATA: lv_content TYPE bcsy_text,
          lv_line    TYPE soli.

    DATA: wa_lotus TYPE /adesso/fi_lotus,
          datei    TYPE char255.

* Notes-Session generieren
    CREATE OBJECT notessession 'Notes.NotesSession'.
    CREATE OBJECT uiws 'Notes.NotesUIWorkspace'.

* Datenbank ermitteln
* Customizingtabelle muss gepflegt sein
    SELECT SINGLE * FROM /adesso/fi_lotus INTO wa_lotus
       WHERE bname = sy-uname.

    IF sy-subrc NE 0.
      MESSAGE e000(e4) WITH 'Für User'
                            sy-uname
                            'ist Tabelle /EVUIT/FI_LOTUS'
                            'nicht gepflegt'.
      EXIT.
    ENDIF.

    CONCATENATE wa_lotus-pathname
                wa_lotus-lotus_nsf
                INTO datei.

* Datenbank ermitteln
    CALL METHOD OF notessession 'GetDatabase' = maildb
      EXPORTING
      #1 = 'STWBON01/STWBO'
      #2 = datei.

* Profil ermitteln
    CALL METHOD OF maildb 'GetProfileDocument' = profile
      EXPORTING
      #1 = 'CalendarProfile'.

* Signatur ermitteln
    CALL METHOD OF profile 'GetFirstItem' = esigobj
      EXPORTING
      #1 = 'EnableSignature'.

    CALL METHOD OF profile 'GetFirstItem' = osigobj
      EXPORTING
      #1 = 'SignatureOption'.

    GET PROPERTY OF esigobj 'Text' = esig.
    GET PROPERTY OF osigobj 'Text' = osig.

* Signatur in Abhängigkeit der Option einstellen
*   Einfacher Text
    IF osig = '1'.

      CALL METHOD OF profile 'GetFirstItem' = signature_1
        EXPORTING
        #1 = 'Signature_1'.

*   HTML
    ELSEIF osig = '2'.

      CALL METHOD OF profile 'GetFirstItem' = signature_2
        EXPORTING
        #1 = 'Signature_2'.

*   Rich-Text
    ELSEIF osig = '3'.

      CALL METHOD OF profile 'GetFirstItem' = signature_r
        EXPORTING
        #1 = 'Signature_Rich'.

    ENDIF.

* Signatur erstmal deaktivieren, damit sie nicht vor dem Text steht.
    SET PROPERTY OF profile 'EnableSignature'  = '0'.
    SET PROPERTY OF profile 'SignatureOption'  = '0'.

* Dokument anlegen
    CALL METHOD OF maildb 'Createdocument' = memo.
    SET PROPERTY OF memo 'Form'             = 'Memo'.
    SET PROPERTY OF memo 'SendTo'           = ''.

* Betreffzeile
    strbetreff = get_subject( im_subject ).
    SET PROPERTY OF memo 'Subject'          = strbetreff.

    lv_content = get_mailbody( ).

    CALL METHOD OF memo 'CreateRichTextItem' = notesrtf
      EXPORTING
      #1 = 'Body'.

*    Textkörper
    LOOP AT lv_content INTO lv_line.
      CALL METHOD OF notesrtf 'AppendText'
        EXPORTING
          #1 = lv_line-line.

      CALL METHOD OF notesrtf 'AddNewLine'
        EXPORTING
          #1 = '1'.

    ENDLOOP.

    CALL METHOD OF notesrtf 'AddNewLine'
      EXPORTING
        #1 = '2'.

*   Einfacher Text
    IF osig = '1'.

      GET PROPERTY OF signature_1 'Text' = sig_1.

      CALL METHOD OF notesrtf 'AppendText'
        EXPORTING
          #1 = sig_1.

*   HTML
    ELSEIF osig = '2'.

      GET PROPERTY OF signature_2 'Text' = sig_2.

      CALL METHOD OF notesrtf 'AppendText'
        EXPORTING
          #1 = 'Pfad für die HTML-Signatur:'.

      CALL METHOD OF notesrtf 'AddTab'
        EXPORTING
          #1 = '1'.

      CALL METHOD OF notesrtf 'AppendText'
        EXPORTING
          #1 = sig_2.

* RICH-Text
    ELSEIF osig = '3'.

      CALL METHOD OF notesrtf 'AppendRtItem'
        EXPORTING
          #1 = signature_r.

    ENDIF.

    CALL METHOD OF notesrtf 'Update'.

    CALL METHOD OF uiws 'EditDocument'
      EXPORTING
        #1 = 'True'
        #2 = memo.

    SET PROPERTY OF profile 'EnableSignature'  = esig.
    SET PROPERTY OF profile 'SignatureOption'  = osig.

    FREE OBJECT notessession.
    FREE OBJECT maildb      .
    FREE OBJECT memo        .
    FREE OBJECT notesrtf    .
    FREE OBJECT signature_1 .
    FREE OBJECT signature_2 .
    FREE OBJECT signature_r .
    FREE OBJECT uiws        .
    FREE OBJECT profile     .
    FREE OBJECT esigobj     .
    FREE OBJECT osigobj     .

    COMMIT WORK AND WAIT.



  ENDMETHOD.                    "send_lotus_mail

  METHOD get_mailbody.

    DATA: it_mailbody_template TYPE TABLE OF tline.

    it_mailbody_template = get_baustein( 'MAIL_BODY' ).

    DATA: lv_body_line     TYPE tline,
          lv_full_username TYPE so_adrnam.

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

  METHOD add_record_to_mailbody.


    DATA: wa_record   TYPE s_record,
          it_tmp_text TYPE TABLE OF tline,
          lv_tmp_line TYPE tline,
          lv_date(10).
    LOOP AT it_records INTO wa_record.

      it_tmp_text = get_baustein( 'MAIL_RECORD' ).

      LOOP AT it_tmp_text INTO lv_tmp_line.


*       Converts SAP date from 20020901 to 01.09.2002
        WRITE wa_record-invoice_date TO lv_date DD/MM/YYYY.

        REPLACE '</ERSTELLDATUM>'  WITH lv_date   INTO lv_tmp_line.
        REPLACE '</CROSREF_NR>'    WITH wa_record-crossref_no    INTO lv_tmp_line.
        REPLACE '</AVIS_NUMMER>'   WITH wa_record-ext_invoice_no INTO lv_tmp_line.
        REPLACE '</DIFF_GRUND_NR>' WITH wa_record-rstgr          INTO lv_tmp_line.
        REPLACE '</DIFF_GRUND>'    WITH wa_record-text           INTO lv_tmp_line.
        REPLACE '</ZP>'            WITH wa_record-ext_ui         INTO lv_tmp_line.
        REPLACE '</ZP_ME>'         WITH wa_record-ext_ui_melo    INTO lv_tmp_line.               "Nuss 01.02.2018
        REPLACE '</ABLEHNUNG>'     WITH wa_record-free_text5     INTO lv_tmp_line.

        REPLACE '* ' WITH `` INTO lv_tmp_line.
        REPLACE '  ' WITH `` INTO lv_tmp_line.
        REPLACE ALL OCCURRENCES OF ','  IN lv_tmp_line WITH cl_abap_char_utilities=>horizontal_tab.
        APPEND lv_tmp_line TO iv_content.

      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.                    "add_record_to_mailbody

  METHOD get_subject.

    DATA: tmp_subject TYPE sood-objdes.
    tmp_subject = iv_subject.

    IF lines( it_records ) = 1.

      FIELD-SYMBOLS <fs_line> LIKE LINE OF it_records.
      READ TABLE it_records ASSIGNING <fs_line> INDEX 1.

      IF <fs_line> IS ASSIGNED.
        CONCATENATE tmp_subject ' /  ' <fs_line>-crossref_no INTO ev_subject.
      ENDIF.
    ELSEIF lines( it_records ) > 1.

      CONCATENATE tmp_subject ' / DIVERSE'  INTO ev_subject.

    ENDIF.


  ENDMETHOD.                    "get_subject

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

  METHOD get_baustein.

    DATA: it_bausteine TYPE TABLE OF /adesso/fi_remad.
    DATA: lv_text TYPE string.

    lcl_customizing_data=>get_config( EXPORTING iv_option = 'TEXT'
                                                iv_category = iv_text_typ
                                                iv_field = 'BAUSTEIN'
                                      RECEIVING rv_t_values = it_bausteine ).

    IF it_bausteine IS INITIAL.
      CLEAR lv_text.
      CONCATENATE 'Für die Kategorie ' iv_text_typ ' wurde kein Textbaustein in der Konfiguration definiert (1).' INTO lv_text.
      MESSAGE e000(e4) WITH lv_text.
    ENDIF.

    DATA: lv_readtext TYPE boolean.
    FIELD-SYMBOLS: <fs_baustein> TYPE /adesso/fi_remad.
    lv_readtext = abap_false.

    IF lines( it_bausteine ) > 1.

      DATA: it_selection TYPE TABLE OF /adesso/fi_remad.
      lcl_customizing_data=>get_config( EXPORTING iv_option = 'TEXT'
                                                  iv_category = iv_text_typ
                                                  iv_field = 'BEZEICHNUNG'
                       	                RECEIVING rv_t_values = it_selection ).

      DATA: tmpbaustein TYPE /adesso/fi_remad.
      tmpbaustein = baustein_selection( it_selection ).

      READ TABLE it_bausteine
        WITH  KEY mandt           = tmpbaustein-mandt
                  negrem_option   = tmpbaustein-negrem_option
                  negrem_category = tmpbaustein-negrem_category
                  negrem_field    = 'BAUSTEIN'
                  negrem_id       = tmpbaustein-negrem_id
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
    lcl_customizing_data=>get_config( EXPORTING iv_option   = <fs_baustein>-negrem_option
                                                iv_category = <fs_baustein>-negrem_category
                                                iv_id       = <fs_baustein>-negrem_id
                       	              RECEIVING rv_t_values = it_selection ).

    IF it_selection IS INITIAL.
      CLEAR lv_text.
      CONCATENATE
        'Für die Kategorie '
        <fs_baustein>-negrem_category
        ' wurde kein Textbaustein in der Konfiguration definiert.(2)'
      INTO lv_text.
      MESSAGE e000(e4) WITH lv_text.
      EXIT.
    ENDIF.
    DATA: BEGIN OF s_baustein,
            mandt    TYPE /adesso/fi_remad-mandt,
            baustein TYPE tdobname,
            text_id	 TYPE tdid,
            sprache	 TYPE tdspras,
            object   TYPE tdobject,
          END OF s_baustein.

    DATA: wa_cust     TYPE /adesso/fi_remad,
          lv_baustein LIKE s_baustein.

    LOOP AT it_selection INTO wa_cust.

      IF lv_baustein-mandt IS INITIAL.
        lv_baustein-mandt = wa_cust-mandt.
      ENDIF.

      CASE wa_cust-negrem_field.

        WHEN 'BAUSTEIN'.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = wa_cust-negrem_value
            IMPORTING
              output = lv_baustein-baustein.
        WHEN 'ID'.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = wa_cust-negrem_value
            IMPORTING
              output = lv_baustein-text_id.

        WHEN 'SPRACHE'.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = wa_cust-negrem_value
            IMPORTING
              output = lv_baustein-sprache.

        WHEN 'OBJECT'.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = wa_cust-negrem_value
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

  METHOD baustein_selection.


    DATA: lv_t_values TYPE TABLE OF /adesso/fi_neg_remadv_val .
    DATA: lv_text TYPE string.
    DATA: wa_cust TYPE /adesso/fi_remad.
    LOOP AT iv_t_bausteine INTO wa_cust.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = wa_cust-negrem_value
        IMPORTING
          output = wa_cust-negrem_value.

      APPEND wa_cust-negrem_value TO lv_t_values.

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

    FIELD-SYMBOLS: <fs_baustein> TYPE /adesso/fi_remad.
    READ TABLE iv_t_bausteine ASSIGNING <fs_baustein> INDEX choice.

    IF <fs_baustein> IS ASSIGNED.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = wa_cust-negrem_value
        IMPORTING
          output = wa_cust-negrem_value.

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

ENDCLASS.                    "lcl_Send_Mail IMPLEMENTATION


*----------------------------------------------------------------------*
*       CLASS lcl_bcontact IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_bcontact IMPLEMENTATION.

  METHOD constructor.
    get_config( ).
  ENDMETHOD.                    "constructor


  METHOD set_contact.

    DATA: lp_bpcontact TYPE ct_contact.

    IF iv_auto_data IS INITIAL.
      get_autodata( EXPORTING iv_gpart = iv_partner
                              iv_vkont = iv_vkont           "Nuss 08.02.2018
                              iv_int_inv_doc_no = iv_int_inv_doc_no
                              iv_int_inv_line_no = iv_int_inv_line_no
                    RECEIVING ev_auto_data = iv_auto_data ).
    ENDIF.

    IF iv_auto_data IS INITIAL.
      EXIT.
    ENDIF.

    iv_auto_data-bcontd_use = 'X'.
    CALL FUNCTION 'BCONTACT_CREATE'
      EXPORTING
*       X_UPD_ONLINE    =
        x_no_dialog     = 'X'
        x_auto          = iv_auto_data
        x_partner       = iv_partner
      IMPORTING
        y_new_bpcontact = lp_bpcontact
      EXCEPTIONS
        existing        = 1
        foreign_lock    = 2
        number_error    = 3
        general_fault   = 4
        input_error     = 5
        not_authorized  = 6
        OTHERS          = 7.
    IF sy-subrc <> 0.
      DATA: lv_text TYPE string.
      CASE sy-subrc.

        WHEN 1.
          lv_text = 'Der Eintrag existiert bereits'.
        WHEN 2.
          lv_text = 'Der Eintrag wird blockiert'.
        WHEN 3.
          lv_text = 'Fehler bei der ID-Vergabe'.
        WHEN 4.
          lv_text = 'Genereller Fehler'.
        WHEN 5.
          lv_text = 'Fehler in den Eingabedaten'.
        WHEN 6.
          lv_text = 'Nicht Authorisiert'.
        WHEN 7.
          lv_text = 'undefinierter Grund'.
      ENDCASE.

      CONCATENATE 'Fehler beim Erstellen des Kontakts. Grund: ' lv_text INTO lv_text.
      MESSAGE e000(e4) WITH lv_text.
      EXIT.

    ELSE.
      COMMIT WORK AND WAIT.

      UPDATE stxh SET tdtitle = iv_int_inv_doc_no
             WHERE tdobject = 'BCONT'
             AND   tdname   = lp_bpcontact
             AND   tdid     = 'BCON'.

      COMMIT WORK AND WAIT.

    ENDIF.


  ENDMETHOD.                    "set_contact

  METHOD get_autodata.
*     IMPORTING value(iv_gpart) TYPE BUT000-PARTNER
*               value(iv_contact_class) TYPE BCONT-CCLASS
*               value(iv_contact_action) TYPE BCONT-ACTIVITY
*               value(iv_contact_direction) TYPE BCONT-F_COMING
*               value(iv_contact_origin) TYPE BCONT-ORIGIN
*
*     RETURNING value(ev_auto_data) TYPE BPC01_BCONTACT_AUTO

    IF g_config IS INITIAL.
      MESSAGE e000(e4) WITH 'Für die Erstellung eines Kontaktes ist keine Konfiguration hinterlegt. Abbruch.'.
      EXIT.
    ENDIF.

    DATA: lv_textline TYPE bpc01_text_line.

    DATA:  wa_object TYPE bpc_obj.          "Nuss 08.02.2018

    DATA: choice TYPE i.
    DATA: BEGIN OF s_bconta,
            cclass   TYPE bconta-cclass,
            fill1    TYPE c,
            activity TYPE bconta-activity,
            fill2    TYPE c,
            acttxt   TYPE bcontat-acttxt,
          END OF s_bconta.
    DATA: t_bconta LIKE TABLE OF s_bconta.

    DATA:  lx_header TYPE thead.
    DATA:  tx_lines TYPE STANDARD TABLE OF tline.

    DATA: help_line TYPE tline.
    DATA: length TYPE i.

    SELECT a~cclass a~activity
           b~acttxt
           FROM bconta AS a
           INNER JOIN bcontat AS b
           ON  b~cclass = a~cclass
           AND b~activity = a~activity
           INTO CORRESPONDING FIELDS OF TABLE t_bconta
           WHERE a~cclass = g_config-cont_class
           AND   b~spras = sy-langu.

*   --> Nuss 08.02.2018
*  Abfangen, wenn SY-SUBRC hier ungleich 0.
    IF sy-subrc <> 0.
      MESSAGE e000(e4) WITH 'Fehler beim Aufruf der Kontaktklasse.'.
      EXIT.
    ENDIF.
*   <-- Nuss 08.02.2018


    CALL FUNCTION 'POPUP_WITH_TABLE_DISPLAY'
      EXPORTING
        endpos_col   = 60
        endpos_row   = 20
        startpos_col = 5
        startpos_row = 5
        titletext    = 'Bitte Kontaktklasse auswählen'
      IMPORTING
        choise       = choice
      TABLES
        valuetab     = t_bconta
      EXCEPTIONS
        break_off    = 1
        OTHERS       = 2.
    IF sy-subrc <> 0.
      MESSAGE e000(e4) WITH 'Fehler beim Aufruf der Kontaktklasse.'.
      EXIT.
    ENDIF.

    READ TABLE t_bconta INTO s_bconta INDEX choice.

    CLEAR ev_auto_data.

    ev_auto_data-bcontd-mandt       = sy-mandt.
    ev_auto_data-bcontd-partner     = iv_gpart.
    ev_auto_data-bcontd-cclass      = s_bconta-cclass.
    ev_auto_data-bcontd-activity    = s_bconta-activity.
    ev_auto_data-bcontd-f_coming    = g_config-cont_direction.
    ev_auto_data-bcontd-ctype       = g_config-cont_type.
    ev_auto_data-bcontd-custinfo    = g_config-cont_cust_info.
    ev_auto_data-bcontd-ctdate      = sy-datum.
    ev_auto_data-bcontd-cttime      = sy-uzeit.
    ev_auto_data-bcontd-erdat       = sy-datum.
    ev_auto_data-bcontd-ernam       = sy-uname.
    ev_auto_data-bcontd-name_o       = s_username-name_text.

    ev_auto_data-text-langu       = sy-langu.

    lv_textline-tdformat = '='.
    lv_textline-tdline = iv_int_inv_doc_no.
    APPEND lv_textline TO ev_auto_data-text-textt.

**  --> Nuss 08.02.2018
    CLEAR wa_object.
    lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'CONTACT'
                                                      iv_category = 'OBJECT'
                                                      iv_field    = 'ROLE'
                                                      iv_id       = '1'
                                            RECEIVING rv_value = wa_object-objrole ).

    IF wa_object-objrole IS NOT INITIAL.
      wa_object-objrole =  wa_object-objrole.
      wa_object-objtype = 'ISUACCOUNT'.
      wa_object-objkey = iv_vkont.
      APPEND wa_object TO ev_auto_data-iobjects.
    ENDIF.

    CLEAR wa_object.
    lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'CONTACT'
                                                      iv_category = 'OBJECT'
                                                      iv_field    = 'ROLE'
                                                      iv_id       = '2'
                                            RECEIVING rv_value = wa_object-objrole ).

    IF wa_object-objrole IS NOT INITIAL.
      wa_object-objrole = wa_object-objrole.
      wa_object-objtype = 'INVRADVDOC'.
      wa_object-objkey = iv_int_inv_doc_no.
      APPEND wa_object TO ev_auto_data-iobjects.
    ENDIF.
**  <-- Nuss 08.02.2018

* Notiz aus dem ALV in die Kontaktnotiz übernehmen
    lx_header-tdobject = co_object.
    lx_header-tdid = co_id.
    lx_header-tdspras = sy-langu.
    lx_header-tdlinesize = '132'.

    CONCATENATE iv_int_inv_doc_no
                '_'
                iv_int_inv_line_no
                INTO lx_header-tdname.

    CLEAR tx_lines.
* Text (falls bereits vorhanden) einlesen und in Itab stellen
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
*       CLIENT                  = SY-MANDT
        id                      = lx_header-tdid
        language                = lx_header-tdspras
        name                    = lx_header-tdname
        object                  = lx_header-tdobject
*       ARCHIVE_HANDLE          = 0
*       LOCAL_CAT               = ' '
*   IMPORTING
*       HEADER                  =
*       OLD_LINE_COUNTER        =
      TABLES
        lines                   = tx_lines
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
*  Wenn noch kein Text im Texteditor vorhanden ist, dann Prüfen, ob ein alter Text
*  hinterlegt wurde. Dieser wird an der 132. Stelle geteilt und eine zweite Zeile
* aufgemacht.
      IF sy-subrc = 4.
        IF wa_out-free_text5 IS NOT INITIAL.
          length = strlen( wa_out-free_text5 ).
          IF length GT 132.
            lv_textline-tdline = wa_out-free_text5(132).
            lv_textline-tdformat = '='.
            APPEND lv_textline TO ev_auto_data-text-textt.
            lv_textline-tdline = wa_out-free_text5+132.
            lv_textline-tdformat = '='.
            APPEND lv_textline TO ev_auto_data-text-textt.
          ELSE.
            lv_textline-tdline = wa_out-free_text5.
            lv_textline-tdformat = '='.
            APPEND lv_textline TO ev_auto_data-text-textt.
          ENDIF.
        ENDIF.
      ELSE.
* Implement suitable error handling here
      ENDIF.
    ELSE.
*     Text aus Editor direkt übernehmen
      LOOP AT tx_lines INTO help_line.
        lv_textline-tdline = help_line-tdline.
        lv_textline-tdformat = '='.
        APPEND lv_textline TO ev_auto_data-text-textt.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.                    "get_AutoData

  METHOD get_config.


    lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'CONTACT'
                                                      iv_category = 'CIC_BC'
                                                      iv_field    = 'CLASS'
                                                      iv_id       = '1'
                                            RECEIVING rv_value = g_config-cont_class
                                           ).
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = g_config-cont_class
      IMPORTING
        output = g_config-cont_class.

    lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'CONTACT'
                                                      iv_category = 'CIC_BC'
                                                      iv_field    = 'ACTIVITY'
                                                      iv_id       = '1'
                                            RECEIVING rv_value = g_config-cont_activity
                                           ).
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = g_config-cont_activity
      IMPORTING
        output = g_config-cont_activity.
    lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'CONTACT'
                                                      iv_category = 'CIC_BC'
                                                      iv_field    = 'TYPE'
                                                      iv_id       = '1'
                                            RECEIVING rv_value = g_config-cont_type
                                           ).
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = g_config-cont_type
      IMPORTING
        output = g_config-cont_type.
    lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'CONTACT'
                                                      iv_category = 'CIC_BC'
                                                      iv_field    = 'DIRECTION'
                                                      iv_id       = '1'
                                            RECEIVING rv_value = g_config-cont_direction
                                           ).
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = g_config-cont_direction
      IMPORTING
        output = g_config-cont_direction.
    lcl_customizing_data=>get_config_value( EXPORTING iv_option   = 'CONTACT'
                                                      iv_category = 'CIC_BC'
                                                      iv_field    = 'INFO'
                                                      iv_id       = '1'
                                            RECEIVING rv_value = g_config-cont_cust_info
                                           ).
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = g_config-cont_cust_info
      IMPORTING
        output = g_config-cont_cust_info.


  ENDMETHOD.                    "get_config

  METHOD check_for_contact.

    TYPES: type_tline TYPE STANDARD TABLE OF tline WITH DEFAULT KEY.

    DATA: wa_bcont TYPE bcont,
          lv_text  TYPE type_tline.
    DATA: lv_tmp_line           TYPE tline,
          h_temp_int_inv_doc_no TYPE tinv_inv_doc-int_inv_doc_no,
          wa_head               TYPE thead.

    rv_b_contexist = abap_false.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = iv_int_inv_doc_no
      IMPORTING
        output = iv_int_inv_doc_no.

    SELECT *
      INTO wa_bcont
      FROM bcont
      WHERE partner = iv_gpart
            AND cclass = g_config-cont_class
            AND activity = g_config-cont_activity
            AND f_coming = g_config-cont_direction
            AND custinfo = g_config-cont_cust_info
            AND ctype = g_config-cont_type.

      CLEAR wa_head.
      MOVE wa_bcont-bpcontact TO wa_head-tdname.
      MOVE wa_bcont-mandt TO wa_head-mandt.
      wa_head-tdid    = 'BCON'.
      wa_head-tdspras = 'D'.
      wa_head-tdobject  = 'BCONT'.

      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          client                  = wa_head-mandt
          id                      = wa_head-tdid
          language                = wa_head-tdspras
          name                    = wa_head-tdname
          object                  = wa_head-tdobject
        TABLES
          lines                   = lv_text
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
        "    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        "            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      LOOP AT lv_text INTO lv_tmp_line.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = lv_tmp_line-tdline
          IMPORTING
            output = h_temp_int_inv_doc_no.

        IF iv_int_inv_doc_no EQ h_temp_int_inv_doc_no.
          rv_b_contexist = abap_true.
        ENDIF.

      ENDLOOP.
    ENDSELECT.


  ENDMETHOD.                    "check_for_contact

ENDCLASS.                    "lcl_add_bcontact IMPLEMENTATION


*----------------------------------------------------------------------*
*       CLASS lcl_customizing_data IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_customizing_data IMPLEMENTATION.

  METHOD constructor.


  ENDMETHOD.                    "constructor

  METHOD get_config.

    DATA: where_tab   TYPE TABLE OF edpline,
          source_line TYPE          edpline.

    IF iv_option IS NOT INITIAL.
      CONCATENATE '/ADESSO/FI_REMAD~NEGREM_OPTION EQ ''' iv_option ''' ' INTO source_line.
      APPEND source_line TO where_tab.
    ENDIF.

    IF iv_category IS NOT INITIAL.
      IF lines( where_tab ) <> 0.
        APPEND ' AND ' TO where_tab.
      ENDIF.
      CONCATENATE '/ADESSO/FI_REMAD~NEGREM_CATEGORY EQ ''' iv_category ''' ' INTO source_line.
      APPEND source_line TO where_tab.
    ENDIF.

    IF iv_field IS NOT INITIAL.
      IF lines( where_tab ) <> 0.
        APPEND ' AND ' TO where_tab.
      ENDIF.
      CONCATENATE '/ADESSO/FI_REMAD~NEGREM_FIELD EQ ''' iv_field ''' ' INTO source_line.
      APPEND source_line TO where_tab.
    ENDIF.

    IF iv_id IS NOT INITIAL.
      IF lines( where_tab ) <> 0.
        APPEND ' AND ' TO where_tab.
      ENDIF.

      DATA: lv_id(3) TYPE c.
      lv_id = iv_id.

      CONCATENATE '/ADESSO/FI_REMAD~NEGREM_ID EQ ' lv_id ' ' INTO source_line.
      APPEND source_line TO where_tab.
    ENDIF.

    SELECT *
      INTO TABLE rv_t_values
      FROM /adesso/fi_remad
      WHERE     /adesso/fi_remad~mandt EQ sy-mandt AND (where_tab).


  ENDMETHOD.                    "get_config

  METHOD get_config_value.


    SELECT SINGLE negrem_value
      INTO rv_value
      FROM /adesso/fi_remad
      WHERE negrem_option    EQ iv_option
        AND negrem_category  EQ iv_category
        AND negrem_field     EQ iv_field
       AND negrem_id        EQ iv_id.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = rv_value
      IMPORTING
        output = rv_value.



  ENDMETHOD.                    "get_config_value

  METHOD get_batch_data.

    DATA: wa_bdc TYPE bdcdata.

    DATA: lv_bdc_data      TYPE /adesso/fi_remad,
          lv_x_segcomplete TYPE x,
          x01              TYPE x VALUE '01',
          x02              TYPE x VALUE '02',
          x03              TYPE x VALUE '03',
          x04              TYPE x VALUE '04',
          x07              TYPE x VALUE '07'.


    SELECT *
      INTO lv_bdc_data
      FROM /adesso/fi_remad
         WHERE negrem_option = iv_option
            AND negrem_category LIKE 'BDC_%'
      ORDER BY negrem_category
               negrem_id
               negrem_field.

      CASE lv_bdc_data-negrem_category.

        WHEN 'BDC_START'.

          CASE lv_bdc_data-negrem_field.

            WHEN 'PROGRAM'.
              wa_bdc-program = lv_bdc_data-negrem_value.
              lv_x_segcomplete = lv_x_segcomplete BIT-OR x01.
            WHEN 'DYNPRO'.
              wa_bdc-dynpro = lv_bdc_data-negrem_value.
              lv_x_segcomplete = lv_x_segcomplete BIT-OR x02.
            WHEN 'DYNBEGIN'.
              wa_bdc-dynbegin = lv_bdc_data-negrem_value.
              lv_x_segcomplete = lv_x_segcomplete BIT-OR x04.
          ENDCASE.

          IF lv_x_segcomplete = x07.

            APPEND wa_bdc TO rv_t_bdc.
            CLEAR lv_x_segcomplete.
            CLEAR wa_bdc.

          ENDIF.

        WHEN 'BDC_DATA'.

          CASE lv_bdc_data-negrem_field.

            WHEN 'FIELD'.
              wa_bdc-fnam = lv_bdc_data-negrem_value.
              lv_x_segcomplete = lv_x_segcomplete BIT-OR x01.
            WHEN 'VALUE'.
              wa_bdc-fval = lv_bdc_data-negrem_value.
              lv_x_segcomplete = lv_x_segcomplete BIT-OR x02.

          ENDCASE.

          IF  lv_x_segcomplete = x03.

            APPEND wa_bdc TO rv_t_bdc.
            CLEAR lv_x_segcomplete.
            CLEAR wa_bdc.

          ENDIF.

      ENDCASE.

    ENDSELECT.

*   Die Startwerte müssen immer an Indexposition 1 stehen,
*   da sonst der Batchaufruf fehlschlägt
    SORT rv_t_bdc
                 BY program DESCENDING
                    fnam    ASCENDING.

  ENDMETHOD.                    "get_batch_data

  METHOD determine_values.

    FIELD-SYMBOLS: <fs_tab>   TYPE table,
                   <fs_line>  TYPE bdcdata,
                   <fs_field> TYPE any.

    LOOP AT iv_t_bdc ASSIGNING <fs_line>.

      IF <fs_line> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.


      IF <fs_line>-fval IS NOT INITIAL AND <fs_line>-fval(1) EQ ''''.
        REPLACE ALL OCCURRENCES OF '''' IN <fs_line>-fval WITH ''.
        APPEND <fs_line> TO rv_t_bdc.
        CONTINUE.
      ELSE.

        ASSIGN COMPONENT <fs_line>-fval
                              OF STRUCTURE iv_wa_data
                              TO <fs_field>
                              CASTING TYPE (<fs_line>-fnam).

        IF <fs_field> IS NOT ASSIGNED.
          APPEND <fs_line> TO rv_t_bdc.
          CONTINUE.
        ENDIF.
      ENDIF.

      <fs_line>-fval = <fs_field>.
      APPEND <fs_line> TO rv_t_bdc.

    ENDLOOP.


  ENDMETHOD.                    "determine_values

ENDCLASS.                    "lcl_customizing_data IMPLEMENTATION
