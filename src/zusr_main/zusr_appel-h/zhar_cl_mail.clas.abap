class ZHAR_CL_MAIL definition
  public
  final
  create public .

public section.

  class-methods SEND_MAIL
    importing
      !IV_SUBJECT type SO_OBJ_DES
      !IV_SENDER type UNAME
      !IV_RECIPIENT type AD_SMTPADR
      !IT_BODY type SOLI_TAB
      !IT_EXT_DATA type SOLIX_TAB optional
      !IV_EXT_FILENAME type STRING optional
    exceptions
      ERROR_SENDING_EMAIL .

  class-methods FORMAT_DATE
    importing
      !IV_DATE type DATS
    returning
      value(RV_STR) type STRING .


protected section.
private section.
ENDCLASS.



CLASS ZHAR_CL_MAIL IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZHAR_CL_MAIL=>SEND_MAIL
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_SUBJECT                     TYPE        SO_OBJ_DES
* | [--->] IV_SENDER                      TYPE        UNAME
* | [--->] IV_RECIPIENT                   TYPE        AD_SMTPADR
* | [--->] IT_BODY                        TYPE        SOLI_TAB
* | [--->] IT_EXT_DATA                    TYPE        SOLIX_TAB(optional)
* | [--->] IV_EXT_FILENAME                TYPE        STRING(optional)
* | [EXC!] ERROR_SENDING_EMAIL
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD send_mail.
    DATA lo_send_request TYPE REF TO cl_bcs.
    DATA lo_document     TYPE REF TO cl_document_bcs.
    DATA lo_sender       TYPE REF TO cl_sapuser_bcs.
    DATA lo_receiver     TYPE REF TO if_recipient_bcs.
    DATA lv_subject      TYPE so_obj_des.

    CHECK  iv_recipient IS NOT INITIAL.
    CHECK  iv_subject   IS NOT INITIAL.

    "DATA lv_recipient(241) TYPE c VALUE '10644705@thyssenkrupp.com'. " 'harald.appel@adesso.de'.
    "DATA lv_recipient    TYPE ad_smtpadr VALUE 'harald.appel.external@thyssenkrupp.com'.
    "DATA lv_recipient(241) TYPE c VALUE 'Stefanie.Baumeister@thyssenkrupp.com'.


* Sendeauftrag anlegen
    lo_send_request = cl_bcs=>create_persistent( ).

* HTML-Mail anlegen
    lo_document = cl_document_bcs=>create_document( i_type = 'HTM'
                                                    i_text = it_body
                                                    i_subject = iv_subject ).
* Dokument übergeben
    lo_send_request->set_document( lo_document ).
* Absender
    DATA(lv_sender) = COND uname( WHEN iv_sender IS NOT INITIAL THEN iv_sender ELSE sy-uname ).
    lo_sender = cl_sapuser_bcs=>create( lv_sender ).
    lo_send_request->set_sender( lo_sender ).
* Empfänger
    lo_receiver = cl_cam_address_bcs=>create_internet_address( iv_recipient ).
    lo_send_request->add_recipient( lo_receiver ).
* Sofort senden - nicht in SCOT Queue
    lo_send_request->set_send_immediately( abap_true ).

* Attachement hinzufügen -> Typen siehe Tabelle TSOTD
    IF iv_ext_filename IS NOT INITIAL AND it_ext_data IS NOT INITIAL.
      lo_document->add_attachment( i_attachment_type    = 'EXT'
                                   i_attachment_subject = |{ iv_ext_filename }|
                                   i_att_content_hex    = it_ext_data ).
    ENDIF.

* Senden
    DATA(lv_send_result) = lo_send_request->send( ).
    IF lv_send_result NE 'X'.
      RAISE error_sending_email.
    ENDIF.

    COMMIT WORK.
  ENDMETHOD.

* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method /TKIS/CL_MM_REP_FCST_CHA=>FORMAT_DATE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_DATE                        TYPE        DATS
* | [<-()] RV_STR                         TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method FORMAT_DATE.
    rv_str = cond #( when iv_date is initial or iv_date eq ''  then ''
      else |{ iv_date(4) }-{ iv_date+4(2) }-{ iv_date+6(2) }| ).
  endmethod.

ENDCLASS.
