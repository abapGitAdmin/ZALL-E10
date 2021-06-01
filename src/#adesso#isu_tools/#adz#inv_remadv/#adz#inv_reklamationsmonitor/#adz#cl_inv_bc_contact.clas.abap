class /ADZ/CL_INV_BC_CONTACT definition
  public
  create public .

public section.

  methods CONSTRUCTOR .
  methods SET_CONTACT
    importing
      value(IV_PARTNER) type BUT000-PARTNER
      value(IV_VKONT) type FKKVKP-VKONT
      value(IV_INT_INV_DOC_NO) type TINV_INV_DOC-INT_INV_DOC_NO
      value(IV_INT_INV_LINE_NO) type INV_INT_INV_LINE_NO
      value(IV_FREE_TEXT5) type /IDEXGE/REJ_NOTI_TXT optional
      value(IV_AUTO_DATA) type BPC01_BCONTACT_AUTO optional .
  methods GET_AUTODATA
    importing
      value(IV_GPART) type BUT000-PARTNER
      value(IV_VKONT) type FKKVKP-VKONT
      value(IV_INT_INV_DOC_NO) type TINV_INV_DOC-INT_INV_DOC_NO
      value(IV_INT_INV_LINE_NO) type INV_INT_INV_LINE_NO
      value(IV_FREE_TEXT5) type /IDEXGE/REJ_NOTI_TXT
    returning
      value(EV_AUTO_DATA) type BPC01_BCONTACT_AUTO .
  methods CHECK_FOR_CONTACT
    importing
      value(IV_GPART) type BUT000-PARTNER
      value(IV_INT_INV_DOC_NO) type TINV_INV_DOC-INT_INV_DOC_NO
    returning
      value(RV_B_CONTEXIST) type BOOLEAN .
  class-methods GET_ACTUSERDATA
    returning
      value(RS_USERNAME) type V_USERNAME .
  PRIVATE SECTION.

    DATA: BEGIN OF s_contact_config,
            cont_class     TYPE ct_cclass,
            cont_activity  TYPE ct_activit,
            cont_type      TYPE ct_ctype,
            cont_direction TYPE ct_coming,
            cont_cust_info TYPE ct_custinfo,
          END OF s_contact_config.
    TYPES: s_cont_conf LIKE s_contact_config.

    DATA: g_config TYPE s_cont_conf.

    METHODS:  get_config.

ENDCLASS.



CLASS /ADZ/CL_INV_BC_CONTACT IMPLEMENTATION.


  METHOD check_for_contact.

    TYPES: type_tline TYPE STANDARD TABLE OF tline WITH DEFAULT KEY.

    DATA: ls_wa_bcont TYPE bcont,
          lv_text  TYPE type_tline.
    DATA: lv_tmp_line           TYPE tline,
          h_temp_int_inv_doc_no TYPE tinv_inv_doc-int_inv_doc_no,
          ls_wa_head            TYPE thead.

    rv_b_contexist = abap_false.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = iv_int_inv_doc_no
      IMPORTING
        output = iv_int_inv_doc_no.

    SELECT *
      INTO ls_wa_bcont
      FROM bcont
      WHERE partner = iv_gpart
            AND cclass = g_config-cont_class
            AND activity = g_config-cont_activity
            AND f_coming = g_config-cont_direction
            AND custinfo = g_config-cont_cust_info
            AND ctype = g_config-cont_type.

      CLEAR ls_wa_head.
      MOVE ls_wa_bcont-bpcontact TO ls_wa_head-tdname.
      MOVE ls_wa_bcont-mandt TO ls_wa_head-mandt.
      ls_wa_head-tdid    = 'BCON'.
      ls_wa_head-tdspras = 'D'.
      ls_wa_head-tdobject  = 'BCONT'.

      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          client                  = ls_wa_head-mandt
          id                      = ls_wa_head-tdid
          language                = ls_wa_head-tdspras
          name                    = ls_wa_head-tdname
          object                  = ls_wa_head-tdobject
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


  METHOD constructor.
    get_config( ).
  ENDMETHOD.                    "constructor


  METHOD get_actuserdata.
    STATICS ss_userdata TYPE v_username.
    IF ss_userdata IS INITIAL.
      SELECT SINGLE * FROM v_username
          INTO rs_username
          WHERE bname = sy-uname.
    ELSE.
      rs_username = ss_userdata.
    ENDIF.
  ENDMETHOD.


  METHOD get_autodata.
*     IMPORTING value(iv_gpart) TYPE BUT000-PARTNER
*               value(iv_contact_class) TYPE BCONT-CCLASS
*               value(iv_contact_action) TYPE BCONT-ACTIVITY
*               value(iv_contact_direction) TYPE BCONT-F_COMING
*               value(iv_contact_origin) TYPE BCONT-ORIGIN
*
*     RETURNING value(ev_auto_data) TYPE BPC01_BCONTACT_AUTO

    IF g_config IS INITIAL.
      MESSAGE i000(e4) WITH 'Für die Erstellung eines Kontaktes ist keine Konfiguration hinterlegt. Abbruch.' DISPLAY LIKE 'E'.
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
      MESSAGE i000(e4) WITH 'Fehler beim Aufruf der Kontaktklasse.' DISPLAY LIKE 'E'.
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
      MESSAGE i000(e4) WITH 'Fehler beim Aufruf der Kontaktklasse.' DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.

    READ TABLE t_bconta INTO s_bconta INDEX choice.

    CLEAR ev_auto_data.
    DATA(ls_username) = get_actuserdata(  ).

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
    ev_auto_data-bcontd-name_o      = ls_username-name_text.

    ev_auto_data-text-langu       = sy-langu.

    lv_textline-tdformat = '='.
    lv_textline-tdline = iv_int_inv_doc_no.
    APPEND lv_textline TO ev_auto_data-text-textt.

**  --> Nuss 08.02.2018
    CLEAR wa_object.
    /adz/cl_inv_customizing_data=>get_config_value( EXPORTING iv_option   = 'CONTACT'
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
    /adz/cl_inv_customizing_data=>get_config_value( EXPORTING iv_option   = 'CONTACT'
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
    lx_header-tdobject = /adz/cl_inv_select_reklamon=>mco_object.
    lx_header-tdid     = /adz/cl_inv_select_reklamon=>mco_id.
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
        IF iv_free_text5 IS NOT INITIAL.
          length = strlen( iv_free_text5 ).
          IF length GT 132.
            lv_textline-tdline = iv_free_text5(132).
            lv_textline-tdformat = '='.
            APPEND lv_textline TO ev_auto_data-text-textt.
            lv_textline-tdline = iv_free_text5+132.
            lv_textline-tdformat = '='.
            APPEND lv_textline TO ev_auto_data-text-textt.
          ELSE.
            lv_textline-tdline = iv_free_text5.
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


    /adz/cl_inv_customizing_data=>get_config_value( EXPORTING iv_option   = 'CONTACT'
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

    /adz/cl_inv_customizing_data=>get_config_value( EXPORTING iv_option   = 'CONTACT'
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
    /adz/cl_inv_customizing_data=>get_config_value( EXPORTING iv_option   = 'CONTACT'
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
    /adz/cl_inv_customizing_data=>get_config_value( EXPORTING iv_option   = 'CONTACT'
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
    /adz/cl_inv_customizing_data=>get_config_value( EXPORTING iv_option   = 'CONTACT'
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


  METHOD set_contact.

    DATA: lp_bpcontact TYPE ct_contact.

    IF iv_auto_data IS INITIAL.
      get_autodata( EXPORTING iv_gpart = iv_partner
                              iv_vkont = iv_vkont           "Nuss 08.02.2018
                              iv_int_inv_doc_no  = iv_int_inv_doc_no
                              iv_int_inv_line_no = iv_int_inv_line_no
                              iv_free_text5      = iv_free_text5
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
      MESSAGE i000(e4) WITH lv_text DISPLAY LIKE 'E'.
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
ENDCLASS.
