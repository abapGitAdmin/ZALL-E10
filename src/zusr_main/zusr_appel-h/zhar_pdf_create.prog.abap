*******
*&---------------------------------------------------------------------*
*& Report ZHAR_PDF_CREATE
*&---------------------------------------------------------------------*
*& Create PDF
*&---------------------------------------------------------------------*
REPORT zhar_pdf_create.
TABLES: mara.

DATA: BEGIN OF itab OCCURS 0.
    INCLUDE STRUCTURE mara.
DATA: END OF itab.
DATA: filesize TYPE i.
*  Spoolnummer
DATA: lv_spool_nr LIKE tsp01-rqident.
*    PDF Ausgabetabelle
DATA: BEGIN OF pdf_output OCCURS 0.
    INCLUDE STRUCTURE tline.
DATA: END OF pdf_output.

DATA lt_pdf_data TYPE solix_tab.
DATA: lv_xstr TYPE xstring.

PARAMETERS p_recip  TYPE ad_smtpadr.

INITIALIZATION.
  SELECT SINGLE m~smtp_addr  INTO p_recip
  FROM usr21 AS u JOIN adr6 AS m
  ON    m~addrnumber = u~addrnumber
   AND  m~persnumber = u~persnumber
  WHERE u~bname = sy-uname.

*

************************************************************************
START-OF-SELECTION.


  SELECT * FROM mara INTO TABLE itab UP TO 100 ROWS.

*  Ausgabe in Spool umleiten
  NEW-PAGE PRINT ON LINE-SIZE 255
  NO DIALOG
  NO-TITLE
  NO-HEADING
  IMMEDIATELY ' '
  .
*   interne tabelle ausgeben
  LOOP AT itab ASSIGNING FIELD-SYMBOL(<ls_itab>).
    WRITE:/ <ls_itab>-matnr, <ls_itab>-ernam.
  ENDLOOP.

*  Rücksetzen Spollausgabe auf Bildschirm.
  NEW-PAGE PRINT OFF.

* Spoolnummer besorgen
  lv_spool_nr = sy-spono.

  DATA lv_mode TYPE integer.
  lv_mode = 3.
  IF lv_mode EQ 1.
    CALL FUNCTION 'CONVERT_ABAPSPOOLJOB_2_PDF'
      EXPORTING
        src_spoolid          = lv_spool_nr
        no_dialog            = abap_true
        pdf_destination      = 'X' " xstring
        get_size_from_format = abap_true
      IMPORTING
        pdf_bytecount        = filesize
        bin_file             = lv_xstr
      TABLES
        pdf                  = pdf_output.
    IF sy-subrc <> 0.
*     MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    lt_pdf_data = cl_bcs_convert=>xstring_to_solix( EXPORTING iv_xstring = lv_xstr ).

  ELSEIF lv_mode EQ 2.
*
    CALL FUNCTION 'RSPO_GET_MERGED_PDF_FROM_SPOOL'
      EXPORTING
        spool_number    = lv_spool_nr
      IMPORTING
        merged_document = lv_xstr
      EXCEPTIONS
        internal_error  = 1
        empty_job       = 2
        not_supported   = 3
        missing_files   = 4
        OTHERS          = 5.
    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_errortext.
*      RAISE EXCEPTION TYPE cx_rspo_spoolid_to_pdf
*        EXPORTING
*          errortext = lv_errortext
*          textid    = cx_rspo_spoolid_to_pdf=>cannot_convert.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      EXIT.
    ENDIF.
    lt_pdf_data = cl_bcs_convert=>xstring_to_solix( EXPORTING iv_xstring = lv_xstr ).

  ELSEIF lv_mode EQ 3.
    PERFORM test_smartform CHANGING lv_xstr.
    lt_pdf_data = cl_bcs_convert=>xstring_to_solix( EXPORTING iv_xstring = lv_xstr ).
  ENDIF.

  DATA  lv_recipient   TYPE ad_smtpadr.
  DATA  lv_sender      TYPE uname VALUE 'BATCH_BC'.

  DATA(lv_date_str) = zhar_cl_mail=>format_date( sy-datum ).
  DATA(lv_subject) = CONV so_obj_des( |Forecast Change since { lv_date_str }| ).
  " recipient
  lv_recipient = p_recip.

  IF sy-subrc EQ 0 AND lv_recipient IS NOT INITIAL.
    " body
    DATA(lt_body) = VALUE soli_tab( ( |<style type="text/css">| )
         ( |.tg  \{border-collapse:collapse;border-spacing:0;\} | )
         ( |.tg td\{border-color:black;border-style:solid;border-width:1px;font-family:Arial, sans-serif;| )
         ( |     font-size:14px;text-align:center;overflow:hidden;padding:10px 5px;word-break:normal;\} | )
         ( |.tg th\{border-color:black;border-style:solid;border-width:1px;font-family:Arial, sans-serif;| )
         ( |     font-size:14px;text-align:center;font-weight:bold;overflow:hidden;padding:10px 5px;word-break:normal;\}| )
         ( |.tex \{border-color:black;border-style:solid;border-width:1px;font-family:Arial, sans-serif;| )
         ( |     font-size:14px;text-align:center;font-weight:normal;background-color:#f9facc;overflow:hidden;padding:10px 5px;word-break:normal;\}| )
         ( |</style>| )
         ( |Hello<br>This is a test!!!| )
        ).
    lt_body = VALUE #( BASE lt_body
        ( |<br><br>| )
        ( |<span style="font-weight: bold;color:#19C2FF;">ThyssenKrupp Industrial Solutions<br>| )
        ( |Project daproh| )
        ( |</span> | )
        ).

    zhar_cl_mail=>send_mail(
      EXPORTING
        iv_sender    =  lv_sender                " Benutzername
        iv_recipient =  lv_recipient              " E-Mail-Adresse
        iv_subject   =  lv_subject                " Kurze Beschreibung des Inhaltes
        it_body      =  lt_body
        iv_ext_filename = 'test.pdf'
        it_ext_data     = lt_pdf_data
    ).
  ENDIF.
  IF sy-batch NE 'X'.
    WRITE : /, 'mail sent to: ', lv_recipient.
  ENDIF.

END-OF-SELECTION.
*********************************************************************************
FORM test_smartform CHANGING cv_xstr TYPE xstring.
  DATA: carr_id TYPE sbook-carrid,
        fm_name TYPE rs38l_fnam.
  DATA: ls_job_output   TYPE ssfcrescl,
        lc_file         TYPE string,
        lt_lines        TYPE TABLE OF tline,
        li_pdf_fsize    TYPE i,
        ls_pdf_string_x TYPE xstring,
        ls_pdf          TYPE char80,
        lt_pdf          TYPE TABLE OF char80.
************************
* Selektionsbildschirm *
************************
  DATA  p_custid TYPE scustom-id VALUE 1.
  DATA  p_form   TYPE tdsfname   VALUE 'SF_EXAMPLE_01'.
  DATA  p_tddest TYPE ssfcompop-tddest VALUE 'LOCL'.


  DATA: customer    TYPE scustom,
        bookings    TYPE ty_bookings,
        connections TYPE ty_connections.

******************
* Datenselektion *
******************
  SELECT SINGLE * FROM scustom INTO customer WHERE id = p_custid.

  CHECK sy-subrc = 0.

  SELECT * FROM sbook INTO TABLE bookings
           WHERE customid = p_custid
           ORDER BY PRIMARY KEY.

  SELECT * FROM spfli INTO TABLE connections
           FOR ALL ENTRIES IN bookings
           WHERE carrid = bookings-carrid
           AND   connid = bookings-connid
           ORDER BY PRIMARY KEY.

***************************
* Formularnamen ermitteln *
***************************
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = p_form
*     variant            = ' '
*     direct_call        = ' '
    IMPORTING
      fm_name            = fm_name
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  IF sy-subrc <> 0.
*   error handling
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    EXIT.
  ENDIF.

******************************************
* Smart Forms Funktionsbaustein aufrufen *
******************************************
* Exportstrukturen
  DATA: lv_document_output_info TYPE  ssfcrespd,
        ls_job_output_info      TYPE  ssfcrescl,
        ls_job_output_options   TYPE  ssfcresop.

  DATA: ls_control_parameters TYPE ssfctrlop,
        ls_output_options     TYPE ssfcompop.

* Importfelder für Unterdrückung Druckdialog
  ls_control_parameters-no_dialog = 'X'.
  ls_control_parameters-device    = 'PRINTER'.
  ls_control_parameters-preview   = 'X'.    "Es wird dann kein Spool-Auftrag erzeugt
  "ls_control_parameters-no_open   = 'X'.
  ls_control_parameters-langu     = sy-langu.
  ls_control_parameters-getotf    = 'X'.

  ls_output_options-tddest        = 'LOCL'.
  "ls_output_options-tdnoprint = 'X'.
  ls_output_options-tdnoprev  = 'X'.
  "ls_output_options-tddelete = 'X'.

  CALL FUNCTION fm_name
    EXPORTING
*     archive_index      =
*     archive_parameters =
      control_parameters = ls_control_parameters
*     mail_appl_obj      =
*     mail_recipient     =
*     mail_sender        =
      output_options     = ls_output_options
      user_settings      = space
      customer           = customer
      bookings           = bookings
      connections        = connections
    IMPORTING
*     document_output_info = lv_DOCUMENT_OUTPUT_INFO  "Anzahl der Formularseiten
      job_output_info    = ls_job_output
*     job_output_options = ls_JOB_OUTPUT_OPTIONS
    EXCEPTIONS
      formatting_error   = 1
      internal_error     = 2
      send_error         = 3
      user_canceled      = 4
      OTHERS             = 5.

  IF sy-subrc <> 0.
*   error handling
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    EXIT.
  ENDIF.

  " Convert smartform OTF to PDF
  CALL FUNCTION 'CONVERT_OTF'
    EXPORTING
      format                = 'PDF'
    IMPORTING
      bin_filesize          = li_pdf_fsize
      bin_file              = ls_pdf_string_x
    TABLES
      otf                   = ls_job_output-otfdata
      lines                 = lt_lines
    EXCEPTIONS
      err_max_linewidth     = 1
      err_format            = 2
      err_conv_not_possible = 3
      err_bad_otf           = 4
      OTHERS                = 5.

  cv_xstr = ls_pdf_string_x.
*  " convert xstring to binary
*  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
*    EXPORTING
*      buffer     = ls_pdf_string_x
*    TABLES
*      binary_tab = lt_pdf.
ENDFORM.
