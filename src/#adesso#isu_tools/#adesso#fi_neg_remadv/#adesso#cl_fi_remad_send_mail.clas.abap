CLASS /adesso/cl_fi_remad_send_mail DEFINITION PUBLIC FINAL.
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

ENDCLASS.



CLASS /adesso/cl_fi_remad_send_mail IMPLEMENTATION.

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
    /adesso/cl_fi_remad_cust_data=>get_config_value( EXPORTING iv_option = 'MAIL'
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
    /adesso/cl_fi_remad_cust_data=>get_config_value( EXPORTING iv_option = 'MAIL'
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

    /adesso/cl_fi_remad_cust_data=>get_config( EXPORTING iv_option = 'TEXT'
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
      /adesso/cl_fi_remad_cust_data=>get_config( EXPORTING iv_option = 'TEXT'
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
    /adesso/cl_fi_remad_cust_data=>get_config( EXPORTING iv_option   = <fs_baustein>-negrem_option
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
            text_id  TYPE tdid,
            sprache  TYPE tdspras,
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

ENDCLASS.
