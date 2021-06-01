*&---------------------------------------------------------------------*
*&  Include           /ADESSO/PRINTDOC_INVOIC_SF1
*&---------------------------------------------------------------------*
*
* Änderungshistorie:
* Datum      Benutzer Grund
* ----------------------------------------------------------------

*&---------------------------------------------------------------------*
*&      Form  SEND_FILE_AS_EMAIL_ATTACHMENT
*&---------------------------------------------------------------------*

FORM send_file_as_email_attachment  USING    iv_email TYPE somlreci1-receiver
                                             iv_mtitle TYPE sodocchgi1-obj_descr
                                             iv_format TYPE so_obj_tp
                                             iv_filename TYPE  so_obj_des
                                             iv_attdescription TYPE so_obj_nam
                                             iv_sender_address TYPE soextreci1-receiver
                                             iv_sender_address_type TYPE soextreci1-adr_typ
                                    CHANGING cv_error TYPE sy-subrc
                                             cv_receiver TYPE sy-subrc
                                             ct_message TYPE isumi_mail_content
                                             ct_attach TYPE isumi_mail_content.

  DATA:   lt_packing_list TYPE TABLE OF sopcklsti1,
          ls_packing_list TYPE sopcklsti1,
          lt_receivers    TYPE TABLE OF somlreci1,
          ls_receivers    TYPE somlreci1,
          ls_attachment   TYPE solisti1,
          lt_attachment   TYPE TABLE OF solisti1,
          lv_cnt          TYPE i,
          lv_sent_all(1)  TYPE c,
          ls_doc_data     TYPE sodocchgi1.

* Fill the document data.
  ls_doc_data-doc_size = 1.

* Populate the subject/generic message attributes
  ls_doc_data-obj_langu = sy-langu.
  ls_doc_data-obj_name = 'SAPRPT'.
  ls_doc_data-obj_descr = iv_mtitle .
  ls_doc_data-sensitivty = 'F'.

* Fill the document data and get size of attachment
  CLEAR ls_doc_data.
  READ TABLE ct_attach INTO ls_attachment INDEX lv_cnt.
  ls_doc_data-doc_size = ( lv_cnt - 1 ) * 255 + strlen( ls_attachment ).
  ls_doc_data-obj_langu = sy-langu.
  ls_doc_data-obj_name = 'SAPRPT'.
  ls_doc_data-obj_descr = iv_mtitle.
  ls_doc_data-sensitivty = 'F'.
  CLEAR: ls_attachment.
  CLEAR: lt_attachment[].
  lt_attachment[] = ct_attach[].

* Describe the body of the message
  CLEAR ls_packing_list.
  CLEAR lt_packing_list[].
  ls_packing_list-transf_bin = space.
  ls_packing_list-head_start = 1.
  ls_packing_list-head_num = 0.
  ls_packing_list-body_start = 1.
  DESCRIBE TABLE ct_message LINES ls_packing_list-body_num.
  ls_packing_list-doc_type = 'RAW'.
  APPEND ls_packing_list TO lt_packing_list.

* Create attachment notification
  ls_packing_list-transf_bin = 'X'.
  ls_packing_list-head_start = 1.
  ls_packing_list-head_num = 1.
  ls_packing_list-body_start = 1.
  DESCRIBE TABLE lt_attachment LINES ls_packing_list-body_num.
  ls_packing_list-doc_type = iv_format.
  ls_packing_list-obj_descr = iv_attdescription.
  ls_packing_list-obj_name = iv_filename.
  ls_packing_list-doc_size = ls_packing_list-body_num * 255.
  APPEND ls_packing_list TO lt_packing_list.

* Add the recipients email address
  CLEAR ls_receivers.
  CLEAR lt_receivers[].
  ls_receivers-receiver = iv_email.
  ls_receivers-rec_type = 'U'.
  ls_receivers-com_type = 'INT'.
  ls_receivers-notif_del = 'X'.
  ls_receivers-notif_ndel = 'X'.
  APPEND ls_receivers TO lt_receivers.

  CALL FUNCTION 'SO_DOCUMENT_SEND_API1'
    EXPORTING
      document_data              = ls_doc_data
      put_in_outbox              = 'X'
      sender_address             = iv_sender_address
      sender_address_type        = iv_sender_address_type
      commit_work                = 'X'
    IMPORTING
      sent_to_all                = lv_sent_all
    TABLES
      packing_list               = lt_packing_list
      contents_bin               = lt_attachment
      contents_txt               = ct_message
      receivers                  = lt_receivers
*     contents_hex               = lt_attachment
    EXCEPTIONS
      too_many_receivers         = 1
      document_not_sent          = 2
      document_type_not_exist    = 3
      operation_no_authorization = 4
      parameter_error            = 5
      x_error                    = 6
      enqueue_error              = 7
      OTHERS                     = 8.
* Populate zerror return code
  cv_error = sy-subrc.
* Populate zreceiver return code
  LOOP AT lt_receivers INTO ls_receivers.
    cv_receiver = ls_receivers-retrn_code.
  ENDLOOP.

ENDFORM.                    " SEND_FILE_AS_EMAIL_ATTACHMENT

*&---------------------------------------------------------------------*
*&      Form  INITIATE_MAIL_EXECUTE_PROGRAM
*&---------------------------------------------------------------------*

FORM initiate_mail_execute_program .
  WAIT UP TO 2 SECONDS.
  SUBMIT rsconn01 WITH mode = 'INT'
  WITH output = 'X'
  AND RETURN.
ENDFORM.                    " INITIATE_MAIL_EXECUTE_PROGRAM

*&---------------------------------------------------------------------*
*&      Form  CHECK_ERDZ
*&---------------------------------------------------------------------*

FORM check_erdz  USING    iv_vkont        TYPE erdk-vkont
                          iv_opbel        TYPE erdk-opbel
                          iv_dynnr_01     TYPE sy-dynnr
                 CHANGING cs_error_tab_01 TYPE ts_error_tab
                          ct_erdz         TYPE erdz_tab
                          cs_edi_abs      TYPE /adesso/edi_abs.



  DATA: lv_fromdat TYPE           erdz-ab,
        lv_solldat TYPE           absdat,
        lv_vertrag TYPE           vtref_kk.

  DATA: lt_edi_abs TYPE TABLE OF  /adesso/edi_abs,
        ls_edi_abs TYPE          /adesso/edi_abs.


  DATA: lt_eabps_01  TYPE TABLE OF  eabps,
        ls_eabps_01  TYPE           eabps,
        lv_opupw_01  TYPE           opupw_kk,
        lv_exit_01   TYPE           c,
        lv_tabix_01  TYPE           sy-tabix,
        ls_eabp_01   TYPE           eabp,
        lv_datum_01  TYPE           datum,
        ls_erdk_01   TYPE           erdk,
        ls_erdb_01   TYPE           erdb,
        lv_return_01 TYPE           sy-subrc,
        lv_opbel_01  TYPE           opbel_kk,
        lv_check_01  TYPE           kennzx,
        lv_abszyk_01 TYPE           abszyk,
        lv_diff_01   TYPE           char3.


  FIELD-SYMBOLS: <ls_erdz>     LIKE erdz,
                 <ls_erdz_erg> LIKE erdz.


  CHECK iv_dynnr_01 EQ '100'.

  LOOP AT ct_erdz ASSIGNING <ls_erdz>
    WHERE ab  IS NOT INITIAL
      AND bis IS NOT INITIAL.
  ENDLOOP.

  IF sy-subrc <> 0.

    SELECT SINGLE * FROM erdk INTO ls_erdk_01
      WHERE opbel EQ iv_opbel.

    IF sy-subrc NE 0.

      cs_error_tab_01-msg_typ    = 'E'.
      cs_error_tab_01-msg_klasse = '00'.
      cs_error_tab_01-msg_nr     = '001'.
      cs_error_tab_01-msg_1      = 'Druckbeleg:'(010).
      cs_error_tab_01-msg_2      =  iv_opbel.
      cs_error_tab_01-msg_3      = 'Kein Eintrag in ERDK!'(011).

      RETURN.

    ENDIF.

* read the first line of BPP
    READ TABLE ct_erdz ASSIGNING <ls_erdz> INDEX 1.



* save account agreement into a local variable with 20 char structure
    CONCATENATE '0000000000' <ls_erdz>-vertrag INTO lv_vertrag.

    CLEAR: lv_solldat,
           lv_return_01.

* Wenn ERGRD gleich '04', dann liegt ein Storno vor.
    IF ls_erdk_01-ergrd EQ '04'.

      SELECT * FROM erdb INTO ls_erdb_01
        WHERE opbel EQ ls_erdk_01-intopbel.

        CLEAR: lt_eabps_01[].

        CALL FUNCTION 'ISU_S_BBP_GET_EABP'
          EXPORTING
            x_opbel   = ls_erdb_01-invopbel
          TABLES
            yt_eabps  = lt_eabps_01
          EXCEPTIONS
            not_found = 1
            OTHERS    = 2.

        IF sy-subrc <> 0.

          PERFORM check_idoc_01 USING     ls_erdk_01-intopbel
                                          iv_vkont
                                          lv_vertrag
                                CHANGING  lv_opbel_01
                                          lv_solldat
                                          lv_fromdat
                                          lv_opupw_01
                                          lv_check_01.

          IF lv_check_01 EQ space.

            cs_error_tab_01-msg_typ    = sy-msgty.
            cs_error_tab_01-msg_klasse = sy-msgid.
            cs_error_tab_01-msg_nr     = sy-msgno.
            cs_error_tab_01-msg_1      = sy-msgv1.
            cs_error_tab_01-msg_2      = sy-msgv2.
            cs_error_tab_01-msg_3      = sy-msgv3.
            cs_error_tab_01-msg_4      = sy-msgv4.

            RETURN.

          ELSE.

            EXIT.

          ENDIF.

        ENDIF.


        READ TABLE lt_eabps_01 TRANSPORTING NO FIELDS
        WITH KEY  augst =  space
                  faedn = <ls_erdz>-faedn.

        IF sy-subrc NE 0.

          READ TABLE lt_eabps_01 TRANSPORTING NO FIELDS
                  WITH KEY  faedn = <ls_erdz>-faedn
                            augbl = ls_erdb_01-invopbel.

          IF sy-subrc EQ 0.

            MOVE ls_erdb_01-invopbel TO lv_opbel_01.

            EXIT.

          ENDIF.

        ELSE.

          MOVE ls_erdb_01-invopbel TO lv_opbel_01.

          EXIT.

        ENDIF.

      ENDSELECT.

      IF lv_check_01 EQ space.

        READ TABLE lt_eabps_01 TRANSPORTING NO FIELDS
        WITH KEY  augst =  space
                  faedn = <ls_erdz>-faedn.

        IF sy-subrc NE 0.

          READ TABLE lt_eabps_01 TRANSPORTING NO FIELDS
                  WITH KEY  faedn = <ls_erdz>-faedn
                            augbl = ls_erdb_01-invopbel.

          IF sy-subrc NE 0.
            MOVE 1 TO lv_return_01.
          ENDIF.

        ENDIF.

      ENDIF.

* Wenn ERGRD ungleich '04', dann handelt es sich um eine normale Abschlagsanforderung.
    ELSE.

* Es werden alle Belege zum Faelligkeitsdatum ermittelt.
      CLEAR: lt_eabps_01[].

      CALL FUNCTION 'ISU_S_BBP_GET_EABP'
        EXPORTING
          x_opbel   = <ls_erdz>-abpopbel
        TABLES
          yt_eabps  = lt_eabps_01
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.

      IF sy-subrc <> 0.

        cs_error_tab_01-msg_typ    = sy-msgty.
        cs_error_tab_01-msg_klasse = sy-msgid.
        cs_error_tab_01-msg_nr     = sy-msgno.
        cs_error_tab_01-msg_1      = sy-msgv1.
        cs_error_tab_01-msg_2      = sy-msgv2.
        cs_error_tab_01-msg_3      = sy-msgv3.
        cs_error_tab_01-msg_4      = sy-msgv4.

        RETURN.

      ENDIF.

      READ TABLE lt_eabps_01 TRANSPORTING NO FIELDS
      WITH KEY  augst =  space
                faedn = <ls_erdz>-faedn.

      IF sy-subrc NE 0.


        SELECT * FROM erdb INTO ls_erdb_01
          WHERE opbel EQ ls_erdk_01-intopbel.

* Es werden alle Belege zum Faelligkeitsdatum ermittelt.
          CLEAR: lt_eabps_01[].

          CALL FUNCTION 'ISU_S_BBP_GET_EABP'
            EXPORTING
              x_opbel   = ls_erdb_01-invopbel
            TABLES
              yt_eabps  = lt_eabps_01
            EXCEPTIONS
              not_found = 1
              OTHERS    = 2.

          IF sy-subrc <> 0.

            cs_error_tab_01-msg_typ    = sy-msgty.
            cs_error_tab_01-msg_klasse = sy-msgid.
            cs_error_tab_01-msg_nr     = sy-msgno.
            cs_error_tab_01-msg_1      = sy-msgv1.
            cs_error_tab_01-msg_2      = sy-msgv2.
            cs_error_tab_01-msg_3      = sy-msgv3.
            cs_error_tab_01-msg_4      = sy-msgv4.

            RETURN.

          ENDIF.

          READ TABLE lt_eabps_01 TRANSPORTING NO FIELDS
          WITH KEY  augst =  space
                    faedn = <ls_erdz>-faedn.

          IF sy-subrc NE 0.

            MOVE 1 TO lv_return_01.

          ELSE.

            MOVE ls_erdb_01-invopbel TO lv_opbel_01.

          ENDIF.

          EXIT.

        ENDSELECT.

        IF sy-subrc NE 0.

          MOVE 1 TO lv_return_01.

        ENDIF.

      ELSE.

        MOVE <ls_erdz>-abpopbel TO lv_opbel_01.

      ENDIF.

    ENDIF.

    IF lv_return_01 EQ 0      AND
       lv_check_01  EQ space.

      IF ls_erdk_01-ergrd NE '04'.

        SORT lt_eabps_01 BY solldat.

        LOOP AT lt_eabps_01 INTO ls_eabps_01
          WHERE augst EQ  space           AND
                faedn EQ <ls_erdz>-faedn.
* Nur wenn ein Beleg gefunden wurde, der kein Storno ist, darf jetzt auf die Tabelle
* ZEIDET_ABS geprüft werden, ob bereits ein Eintrag vorhanden ist. Eigentlich darf hier
* keiner zu finden sein.
          SELECT COUNT( * ) FROM /adesso/edi_abs
           WHERE  vkont     EQ iv_vkont                AND
                  vertrag   EQ lv_vertrag              AND
                  opbel_abs EQ lv_opbel_01             AND
                  faedn     EQ ls_eabps_01-solldat    AND
                  opupw     EQ ls_eabps_01-opupw      AND
                  storn     EQ space.

          IF sy-dbcnt         EQ  0.
* Wurde kein Eintrag gefunden, wird das SOLLDAT der DFKKOPW übernommen.
            MOVE ls_eabps_01-solldat TO lv_solldat.
            MOVE ls_eabps_01-opupw   TO lv_opupw_01.

            EXIT.

          ENDIF.

        ENDLOOP.

      ENDIF.

    ELSEIF lv_return_01 NE 0      AND
           lv_check_01  EQ space.

      cs_error_tab_01-msg_typ    = 'E'.
      cs_error_tab_01-msg_klasse = '00'.
      cs_error_tab_01-msg_nr     = '001'.
      cs_error_tab_01-msg_1      = 'Druckbeleg:'(010).
      cs_error_tab_01-msg_2      =  iv_opbel.
      cs_error_tab_01-msg_3      = 'Kein Beleg ermittelbar!'(007).

      RETURN.

    ENDIF.

* Das folgende SOLLDAT kann eigentlich nur initial sein,
* wenn es sich um einen Stornobeleg handelt.
    IF lv_solldat IS INITIAL.

      SORT lt_eabps_01 BY solldat.

      LOOP AT lt_eabps_01 INTO ls_eabps_01
        WHERE augst EQ space           AND
              faedn EQ <ls_erdz>-faedn.
* Wenn es sich um einen Stornobeleg handelt, muß dieser über die Tabelle
* ZEIDET_ABS zugeordnet werden.
        SELECT * FROM /adesso/edi_abs INTO ls_edi_abs
         WHERE  vkont     EQ iv_vkont                AND
                vertrag   EQ lv_vertrag              AND
                opbel_abs EQ lv_opbel_01             AND
                faedn     EQ ls_eabps_01-solldat    AND
                opupw     EQ ls_eabps_01-opupw      AND
                storn     EQ space.

          MOVE ls_edi_abs-faedn   TO lv_solldat.
          MOVE ls_edi_abs-opupw   TO lv_opupw_01.

          MOVE 'X' TO lv_exit_01.

          EXIT.

        ENDSELECT.

        IF NOT lv_exit_01 EQ space.

          EXIT.

        ENDIF.

      ENDLOOP.

      IF sy-subrc NE 0.

        LOOP AT lt_eabps_01 INTO ls_eabps_01
          WHERE faedn EQ <ls_erdz>-faedn         AND
                augbl EQ lv_opbel_01.
* Wenn es sich um einen Stornobeleg handelt, muß dieser über die Tabelle
* ZEIDET_ABS zugeordnet werden.
          SELECT * FROM /adesso/edi_abs INTO ls_edi_abs
           WHERE  vkont     EQ iv_vkont                AND
                  vertrag   EQ lv_vertrag              AND
                  opbel_abs EQ lv_opbel_01             AND
                  faedn     EQ ls_eabps_01-solldat    AND
                  opupw     EQ ls_eabps_01-opupw      AND
                  storn     EQ space.

            MOVE ls_edi_abs-faedn   TO lv_solldat.
            MOVE ls_edi_abs-opupw   TO lv_opupw_01.

            MOVE 'X' TO lv_exit_01.

            EXIT.

          ENDSELECT.

          IF NOT lv_exit_01 EQ space.

            EXIT.

          ENDIF.

        ENDLOOP.

      ENDIF.

      IF lv_exit_01 EQ space.

        cs_error_tab_01-msg_typ    = 'E'.
        cs_error_tab_01-msg_klasse = '00'.
        cs_error_tab_01-msg_nr     = '001'.
        cs_error_tab_01-msg_1      = 'Druckbeleg:'(010).
        cs_error_tab_01-msg_2      =  iv_opbel.
        cs_error_tab_01-msg_3      = 'Achtung: Alter Stornobeleg!'(008).

        RETURN.

      ELSE.

        CLEAR: lv_exit_01.

      ENDIF.

    ENDIF.

* Wenn jetzt immer noch kein SOLLDAT gefunden wurde, ist alles zu spät.
    IF lv_solldat IS INITIAL.

      cs_error_tab_01-msg_typ    = 'E'.
      cs_error_tab_01-msg_klasse = '00'.
      cs_error_tab_01-msg_nr     = '001'.
      cs_error_tab_01-msg_1      = 'Druckbeleg:'(010).
      cs_error_tab_01-msg_2      =  iv_opbel.
      cs_error_tab_01-msg_3      = 'Kein SOLLDAT ermittelbar!'(009).

      RETURN.

    ENDIF.

* Ab hier finden Abschlagsanforderungen und Stornos wieder zusammen.
    IF lv_check_01 EQ space.

      SELECT * FROM /adesso/edi_abs INTO TABLE lt_edi_abs
       WHERE  vkont     EQ iv_vkont                AND
              vertrag   EQ lv_vertrag              AND
              opbel_abs EQ lv_opbel_01             AND
              faedn     EQ ls_eabps_01-solldat    AND
              opupw     EQ ls_eabps_01-opupw      AND
              storn     EQ space.

      IF sy-subrc = 0 OR lt_edi_abs[] IS NOT INITIAL.
* In diesem Fall liegt ein Storno vor.
        SORT lt_edi_abs BY faedn DESCENDING.

        CLEAR ls_edi_abs.

        READ TABLE lt_edi_abs INTO ls_edi_abs INDEX 1.

        IF sy-subrc = 0.

          lv_fromdat = ls_edi_abs-begabrpe.

        ENDIF.
* Der Referenzbeleg in der Tabelle ZEBIT_ABS wird als storniert gekennzeichnet,
* damit er zukünftig nicht mehr zu Verarbeitungszwecken herangezogen wird.
        MOVE 'X' TO ls_edi_abs-storn.

        DO 100 TIMES.

          CALL FUNCTION 'ENQUEUE_EZ_EDI_ABS'
            EXPORTING
              mode_/adesso/edi_abs = 'E'
              mandt                = sy-mandt
              opbel                = ls_edi_abs-opbel.
          IF sy-subrc <> 0.
            WAIT UP TO 1 SECONDS.
          ELSE.
            EXIT.
          ENDIF.

        ENDDO.

        MODIFY /adesso/edi_abs FROM ls_edi_abs.

        IF sy-subrc NE 0.
*          Keine Aktion!
        ENDIF.

        CALL FUNCTION 'DEQUEUE_EZ_EDI_ABS'
          EXPORTING
            mode_/adesso/edi_abs = 'E'
            mandt                = sy-mandt
            opbel                = ls_edi_abs-opbel.

      ELSE.

* Es werden alle Belege zum Faelligkeitsdatum ermittelt.
        CLEAR: lt_eabps_01[].

        CALL FUNCTION 'ISU_S_BBP_GET_EABP'
          EXPORTING
            x_opbel   = lv_opbel_01
          TABLES
            yt_eabps  = lt_eabps_01
          EXCEPTIONS
            not_found = 1
            OTHERS    = 2.

        IF sy-subrc <> 0.

          cs_error_tab_01-msg_typ    = sy-msgty.
          cs_error_tab_01-msg_klasse = sy-msgid.
          cs_error_tab_01-msg_nr     = sy-msgno.
          cs_error_tab_01-msg_1      = sy-msgv1.
          cs_error_tab_01-msg_2      = sy-msgv2.
          cs_error_tab_01-msg_3      = sy-msgv3.
          cs_error_tab_01-msg_4      = sy-msgv4.

          RETURN.

        ENDIF.

        IF NOT lt_eabps_01[] IS INITIAL.

* Ermitteln der Abschlagszyklen:
*  1: Monatlich!
*  2: Alle zwei  Monate!
*  3: Alle drei  Monate!
*  4: Alle vier  Monate!
*  6: Alle sechs Monate!
* 12: Jährlich!
          SELECT abszyk FROM eabp INTO lv_abszyk_01
            WHERE opbel EQ lv_opbel_01.
            EXIT.
          ENDSELECT.

          IF sy-subrc EQ 0.

            IF lv_abszyk_01 EQ 1.
              MOVE '-1' TO lv_diff_01.
            ELSEIF lv_abszyk_01 EQ 2.
              MOVE '-2' TO lv_diff_01.
            ELSEIF lv_abszyk_01 EQ 3.
              MOVE '-3' TO lv_diff_01.
            ELSEIF lv_abszyk_01 EQ 4.
              MOVE '-4' TO lv_diff_01.
            ELSEIF lv_abszyk_01 EQ 6.
              MOVE '-6' TO lv_diff_01.
            ELSEIF lv_abszyk_01 EQ 12.
              MOVE '-12' TO lv_diff_01.
            ENDIF.

          ELSE.

            MOVE '-1' TO lv_diff_01.

          ENDIF.
* Nun wird ermittelt, ob es sich um die erste oder um eine spätere
* Abschlagsanforderung handelt.
          SORT lt_eabps_01 BY solldat.

          LOOP AT lt_eabps_01 INTO ls_eabps_01
            WHERE augst   EQ space      AND
                  solldat EQ lv_solldat.

            MOVE sy-tabix TO lv_tabix_01.

            IF lv_tabix_01 EQ 1.
* Ist es die erste Abschlagsanforderung, wird zur Bestimmung des Beginndatums der Abschlagsanforderung
* der Beginn des Abschlagsplans bestimmt.
              SELECT SINGLE * FROM eabp INTO ls_eabp_01
                WHERE opbel EQ ls_eabps_01-opbel.

              IF sy-subrc EQ 0.
                MOVE ls_eabp_01-begperiode TO lv_fromdat.
              ENDIF.

* Liegt der Beginn des Abschlagsplanes mehr als einen Abschlagszyklus
* vor dem Ende der Abschlagsanforderung, wird ein neues Beginndatum bestimmt.
              CALL FUNCTION 'CALCULATE_DATE'
                EXPORTING
                  months      = lv_diff_01
                  start_date  = lv_solldat
                IMPORTING
                  result_date = lv_datum_01.
              IF sy-subrc NE 0.
*    Keine Aktion!
              ELSE.

                IF lv_fromdat LT lv_datum_01.

                  ADD 1 TO lv_datum_01.

                  MOVE lv_datum_01 TO lv_fromdat.

                ENDIF.

              ENDIF.

            ELSE.
* Handelt es sich um eine spätere Abschlagsanforderung, wird ihr Beginn über das Ende
* der vorangegangenen Abschlagsanforderung bestimmt.

              SUBTRACT 1 FROM lv_tabix_01.

              READ TABLE lt_eabps_01 INTO ls_eabps_01 INDEX lv_tabix_01.

              IF sy-subrc EQ 0.

                MOVE ls_eabps_01-solldat TO lv_fromdat.

                ADD 1 TO lv_fromdat.
* Auch hier sollte eine Abschlagsperiode den Zeitraum eines Abschlagszyklus
* nicht überschreiten.
                CALL FUNCTION 'CALCULATE_DATE'
                  EXPORTING
                    months      = lv_diff_01
                    start_date  = lv_solldat
                  IMPORTING
                    result_date = lv_datum_01.
                IF sy-subrc NE 0.
*    Keine Aktion!
                ELSE.

                  SUBTRACT 10 FROM lv_datum_01.

                  IF lv_fromdat LT lv_datum_01.
                    MOVE lv_datum_01 TO lv_fromdat.
                  ENDIF.

                ENDIF.

              ENDIF.

            ENDIF.

          ENDLOOP.

        ENDIF.

      ENDIF.

    ENDIF.

    IF lv_solldat IS INITIAL OR
       lv_fromdat IS INITIAL.

      cs_error_tab_01-msg_typ    = 'E'.
      cs_error_tab_01-msg_klasse = '00'.
      cs_error_tab_01-msg_nr     = '001'.
      cs_error_tab_01-msg_1      = 'Druckbeleg:'(010).
      cs_error_tab_01-msg_2      =  iv_opbel.
      cs_error_tab_01-msg_3      = 'Kein BIS-Datum ermittelbar!'(012).

      RETURN.

    ENDIF.

* fill from/to date-fields
    LOOP AT ct_erdz ASSIGNING <ls_erdz_erg>.
      <ls_erdz_erg>-ab  = lv_fromdat.
      <ls_erdz_erg>-bis = lv_solldat.
    ENDLOOP.

    ls_edi_abs-opbel     = iv_opbel.
    ls_edi_abs-vkont     = iv_vkont.
    ls_edi_abs-vertrag   = lv_vertrag.
    ls_edi_abs-opbel_abs = lv_opbel_01.
    ls_edi_abs-faedn     = lv_solldat.
    ls_edi_abs-begabrpe  = lv_fromdat.
    ls_edi_abs-endabrpe  = lv_solldat.
    ls_edi_abs-opupw     = lv_opupw_01.
    ls_edi_abs-erdat     = sy-datum.
    ls_edi_abs-ernam     = sy-uname.
    ls_edi_abs-aedat     = sy-datum.
    ls_edi_abs-aenam     = sy-uname.

    MOVE ls_edi_abs TO cs_edi_abs.

    CLEAR: ls_edi_abs, lv_solldat, lv_fromdat, lv_vertrag.

  ENDIF.

ENDFORM.                    " CHECK_ERDZ


*&---------------------------------------------------------------------*
*&      Form  CHECK_IDOC_01
*&---------------------------------------------------------------------*

FORM check_idoc_01  USING    iv_intopbel_01  TYPE opbel_kk
                             iv_vkont_01     TYPE vkont_kk
                             iv_vertrag_01   TYPE vtref_kk
                    CHANGING cv_opbel_01     TYPE opbel_kk
                             cv_solldat_01   TYPE datum
                             cv_fromdat_01   TYPE datum
                             cv_opupw_01     TYPE opupw_kk
                             cv_check_01     TYPE kennzx.

  DATA: ls_abs_01      TYPE /adesso/edi_abs,
        lv_date_01     TYPE datum,
        lv_date_02     TYPE datum,
        lv_sender_01   TYPE service_prov,
        lv_receiver_01 TYPE service_prov,
        lv_vertrag_01  TYPE vertrag,
        lt_docnum_01   TYPE idoc_tt,
        lv_docnum_01   TYPE edi_docnum,
        lv_bgm_ref_01  TYPE char35,
        lv_sdata_01    TYPE edi_sdata,
        ls_edidc_01    TYPE edidc,
        ls_edidd_01    TYPE edidd,
        lt_edidd_01    TYPE edidd_tt,
        lv_senddate_01 TYPE datum.

  CONSTANTS:  lc_segnam_bgm_01 TYPE   edi_mestyp   VALUE '/ISIDEX/E1VDEWBGM_1',
              lc_segnam_dtm_01 TYPE   edi_mestyp   VALUE '/ISIDEX/E1VDEWDTM_1'.


  CLEAR: cv_opbel_01,
         cv_check_01.

  SELECT SINGLE * FROM /adesso/edi_abs INTO ls_abs_01
    WHERE opbel EQ iv_intopbel_01.

  IF sy-subrc EQ 0.

    MOVE ls_abs_01-opupw      TO cv_opupw_01.
    MOVE ls_abs_01-opbel_abs  TO cv_opbel_01.

    MOVE ls_abs_01-begabrpe TO cv_fromdat_01.
    MOVE ls_abs_01-endabrpe TO cv_solldat_01.

    MOVE 'X' TO cv_check_01.

  ELSE.

    SELECT SINGLE invopbel FROM erdb  INTO cv_opbel_01
      WHERE opbel EQ iv_intopbel_01.

    IF sy-subrc NE 0.
*     Keine Aktion!
    ENDIF.

    SELECT SINGLE edisenddate FROM erdk INTO lv_senddate_01
      WHERE opbel EQ iv_intopbel_01.

    IF NOT lv_senddate_01 IS INITIAL.

      lv_date_01 = lv_senddate_01 - 1.
      lv_date_02 = lv_senddate_01 + 1.

    ENDIF.

  ENDIF.

  IF NOT cv_opbel_01 IS INITIAL AND
     NOT lv_date_01  IS INITIAL AND
     NOT lv_date_02  IS INITIAL.

    MOVE iv_vertrag_01+10(10) TO lv_vertrag_01.

    SELECT SINGLE invoicing_party FROM ever INTO lv_sender_01
      WHERE vertrag EQ lv_vertrag_01.

    CHECK sy-subrc EQ 0.


    SELECT SINGLE serviceid FROM /adesso/edivar AS a INNER JOIN
                                 fkkvkp        AS b
                            ON   a~edivariante EQ b~zzedivar
                            INTO lv_receiver_01
                            WHERE b~vkont EQ iv_vkont_01.


    CHECK sy-subrc EQ 0.

    SELECT b~docnum FROM edextaskidoc AS b INNER JOIN
                         edextask     AS a
                    ON   b~dextaskid  EQ a~dextaskid
      INTO TABLE lt_docnum_01
      WHERE ( a~dexproc         EQ 'SE_IN_RAG' OR
              a~dexproc         EQ 'GE_IN_RAG'    )           AND
              a~dexservprov     EQ  lv_receiver_01            AND
              a~dexservprovself EQ  lv_sender_01              AND
              a~dexstatus       EQ 'OK'                       AND
              a~dexduedate      GE  lv_date_01                AND
              a~dexduedate      LE  lv_date_02                AND
              b~sent            EQ '6'
      %_HINTS ORACLE 'INDEX( "&TABLE&" "EDEXTASK~Z03" )'.



    LOOP AT lt_docnum_01 INTO lv_docnum_01.

* Nun wird die BGM-Referenz des IDoc ermittelt.
      SELECT sdata INTO lv_sdata_01 UP TO 1 ROWS FROM edid4
        WHERE docnum   EQ   lv_docnum_01  AND
              segnam   EQ   lc_segnam_bgm_01.
        MOVE lv_sdata_01+58(35)       TO lv_bgm_ref_01 .
      ENDSELECT.

      IF sy-subrc NE 0.
        CONTINUE.
      ENDIF.

      IF lv_bgm_ref_01+3(12) EQ iv_intopbel_01.

        SELECT sdata INTO lv_sdata_01 FROM edid4
          WHERE docnum   EQ   lv_docnum_01      AND
                segnam   EQ   lc_segnam_dtm_01.

          IF     lv_sdata_01+0(3) EQ '155'.
            MOVE lv_sdata_01+3(8) TO cv_fromdat_01.
          ELSEIF lv_sdata_01+0(3) EQ '156'.
            MOVE lv_sdata_01+3(8) TO cv_solldat_01.
          ENDIF.

        ENDSELECT.

        MOVE 'X' TO cv_check_01.

        EXIT.

      ENDIF.

    ENDLOOP.

    IF     cv_solldat_01 IS INITIAL AND
           cv_fromdat_01 IS INITIAL.

      LOOP AT lt_docnum_01 INTO lv_docnum_01.

        CLEAR: ls_edidc_01,
               ls_edidd_01,
               lt_edidd_01[].

        CALL FUNCTION 'EDI_IDOC_GET_FROM_ARCHIVE'
          EXPORTING
            docnum                       = lv_docnum_01
          IMPORTING
            int_edidc                    = ls_edidc_01
          TABLES
            int_edidd                    = lt_edidd_01
          EXCEPTIONS
            idoc_not_in_infostructures   = 1
            idoc_read_error_from_archive = 2
            archive_close_error          = 3
            OTHERS                       = 4.

        IF sy-subrc EQ 0.

          LOOP AT lt_edidd_01 INTO ls_edidd_01
            WHERE segnam   EQ   lc_segnam_bgm_01.

            MOVE ls_edidd_01-sdata+58(35)       TO lv_bgm_ref_01 .

          ENDLOOP.

          IF lv_bgm_ref_01+3(12) EQ iv_intopbel_01.

            LOOP AT lt_edidd_01 INTO ls_edidd_01
              WHERE segnam   EQ   lc_segnam_dtm_01.

              IF     ls_edidd_01-sdata+0(3) EQ '155'.
                MOVE ls_edidd_01-sdata+3(8) TO cv_fromdat_01.
              ELSEIF ls_edidd_01-sdata+0(3) EQ '156'.
                MOVE ls_edidd_01-sdata+3(8) TO cv_solldat_01.
              ENDIF.

            ENDLOOP.

            MOVE 'X' TO cv_check_01.

            EXIT.

          ENDIF.

        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDIF.

  CHECK cv_check_01 EQ 'X'       AND NOT
        ls_abs_01   IS  INITIAL.

  DO 100 TIMES.

    CALL FUNCTION 'ENQUEUE_EZ_EDI_ABS'
      EXPORTING
        mode_zebit_abs = 'E'
        mandt          = sy-mandt
        opbel          = iv_intopbel_01.

    IF sy-subrc <> 0.

      WAIT UP TO 1 SECONDS.

    ELSE.

      MOVE 'X' TO ls_abs_01-storn.

      MODIFY /adesso/edi_abs FROM ls_abs_01.

      IF sy-subrc NE 0.
*          Keine Aktion!
      ENDIF.

      CALL FUNCTION 'DEQUEUE_EZ_EDI_ABS'
        EXPORTING
          mode_zebit_abs = 'E'
          mandt          = sy-mandt
          opbel          = iv_intopbel_01.

      EXIT.

    ENDIF.

  ENDDO.

ENDFORM.                    " CHECK_IDOC_01


*&---------------------------------------------------------------------*
*&      Form  GET_RESEND_DATA_01
*&---------------------------------------------------------------------*

FORM get_resend_data_01  USING    iv_idoc_01    TYPE edi_docnum
                                  iv_opbel_01   TYPE opbel_kk
                                  iv_sel_01     TYPE c
                                  iv_dynnr_01   TYPE sy-dynnr
                         CHANGING ct_erdk_01    TYPE erdk_tab
                                  ct_fkkvkp_01  TYPE fkkvkp_tab
                                  cs_error_01   TYPE ts_error_tab.


  DATA: ls_edidc_01 TYPE edidc,
        ls_edidd_01 TYPE edidd,
        lt_edidd_01 TYPE edidd_tt.

  CHECK iv_dynnr_01 EQ '200'.

  IF     iv_sel_01   NE space   AND
         iv_idoc_01  IS INITIAL.
    MESSAGE e208(00) WITH 'Bitte geben Sie eine IDoc-Nummer an!'(022).
  ELSEIF iv_sel_01   EQ space   AND
         iv_opbel_01 IS INITIAL.
    MESSAGE e208(00) WITH 'Bitte geben Sie eine Druckbelegnummer an!'(023).
  ENDIF.

  PERFORM check_idoc_in_database_01      USING    iv_idoc_01
                                                  iv_sel_01
                                         CHANGING ls_edidc_01
                                                  lt_edidd_01.

  PERFORM check_idoc_in_archive_01       USING    iv_idoc_01
                                                  iv_sel_01
                                         CHANGING ls_edidc_01
                                                  lt_edidd_01.

  PERFORM identify_printdocs_01          USING    lt_edidd_01
                                                  iv_idoc_01
                                                  iv_opbel_01
                                                  iv_sel_01
                                         CHANGING ct_erdk_01
                                                  ct_fkkvkp_01
                                                  cs_error_01.

  PERFORM prepare_printdoc_for_output_01 CHANGING ct_erdk_01.

ENDFORM.                    " GET_RESEND_DATA_01


*&---------------------------------------------------------------------*
*&      Form  CHECK_IDOC_IN_DATABASE_01
*&---------------------------------------------------------------------*

FORM check_idoc_in_database_01  USING    iv_idoc_01   TYPE edi_docnum
                                         iv_sel_01    TYPE c
                                CHANGING cs_edidc_01  TYPE edidc
                                         ct_edidd_01  TYPE edidd_tt.

  CHECK iv_sel_01 NE space.

  SELECT SINGLE * FROM edidc INTO cs_edidc_01
    WHERE docnum EQ iv_idoc_01.

  CHECK sy-subrc EQ 0.

  SELECT * FROM edid4 INTO CORRESPONDING FIELDS OF TABLE ct_edidd_01
    WHERE docnum EQ iv_idoc_01.

  IF sy-subrc NE 0.
*     Keine Aktion!
  ENDIF.

ENDFORM.                    " CHECK_IDOC_IN_DATABASE_01


*&---------------------------------------------------------------------*
*&      Form  CHECK_IDOC_IN_ARCHIVE_01
*&---------------------------------------------------------------------*
FORM check_idoc_in_archive_01   USING    iv_idoc_01   TYPE edi_docnum
                                         iv_sel_01    TYPE c
                                CHANGING cs_edidc_01  TYPE edidc
                                         ct_edidd_01  TYPE edidd_tt.

  CHECK ct_edidd_01[] IS INITIAL AND
        iv_sel_01     NE space.

  CALL FUNCTION 'EDI_IDOC_GET_FROM_ARCHIVE'
    EXPORTING
      docnum                       = iv_idoc_01
    IMPORTING
      int_edidc                    = cs_edidc_01
    TABLES
      int_edidd                    = ct_edidd_01
    EXCEPTIONS
      idoc_not_in_infostructures   = 1
      idoc_read_error_from_archive = 2
      archive_close_error          = 3
      OTHERS                       = 4.

  IF sy-subrc NE 0.
*     Keine Aktion!
  ENDIF.

ENDFORM.                    " CHECK_IDOC_IN_ARCHIVE_01


*&---------------------------------------------------------------------*
*&      Form  IDENTIFY_PRINTDOCS_01
*&---------------------------------------------------------------------*

FORM identify_printdocs_01  USING    it_edidd_01   TYPE edidd_tt
                                     iv_idoc_01    TYPE edi_docnum
                                     iv_opbel_01   TYPE opbel_kk
                                     iv_sel_01     TYPE c
                            CHANGING ct_erdk_01    TYPE erdk_tab
                                     ct_fkkvkp_01  TYPE fkkvkp_tab
                                     cs_error_01   TYPE ts_error_tab.

  CONSTANTS:  lc_segnam_bgm_01     TYPE   edi_mestyp   VALUE '/ISIDEX/E1VDEWBGM_1'.

  DATA:       ls_edidd_01   TYPE   edidd,
              lv_bgm_ref_01 TYPE   char35,
              lv_opbel_01   TYPE   opbel_kk,
              ls_erdk_01    TYPE   erdk.

  IF iv_sel_01     NE space.

    IF it_edidd_01[] IS INITIAL.


      cs_error_01-msg_typ    = 'E'.
      cs_error_01-msg_klasse = '00'.
      cs_error_01-msg_nr     = '001'.
      cs_error_01-msg_1      = 'IDoc:'(015).
      cs_error_01-msg_2      =  iv_idoc_01.
      cs_error_01-msg_3      = '. Das IDoc enthält keine Daten oder existiert nicht!'(016).

      RETURN.

    ENDIF.


    LOOP AT it_edidd_01 INTO ls_edidd_01
      WHERE segnam EQ lc_segnam_bgm_01.

      CLEAR: lv_bgm_ref_01.

      MOVE ls_edidd_01-sdata+58(35)       TO lv_bgm_ref_01.

      CHECK NOT lv_bgm_ref_01 EQ space.

      MOVE lv_bgm_ref_01+3(12) TO lv_opbel_01.

      SELECT * FROM erdk APPENDING TABLE ct_erdk_01
        WHERE opbel       EQ  lv_opbel_01.

      IF sy-subrc NE 0.

        MOVE lv_bgm_ref_01+5(12) TO lv_opbel_01.

        SELECT * FROM erdk APPENDING TABLE ct_erdk_01
          WHERE opbel       EQ  lv_opbel_01.

        IF sy-subrc NE 0.
*             Keine Aktion!
        ENDIF.

      ENDIF.

    ENDLOOP.

  ELSE.

    SELECT * FROM erdk INTO TABLE ct_erdk_01
      WHERE opbel        EQ  iv_opbel_01   AND
            edisenddate  NE '00000000'     AND
            zzdb_freidat NE '00000000'.

    IF sy-subrc NE space.

      cs_error_01-msg_typ    = 'E'.
      cs_error_01-msg_klasse = '00'.
      cs_error_01-msg_nr     = '001'.
      cs_error_01-msg_1      = 'Druckbeleg:'(021).
      cs_error_01-msg_2      =  iv_opbel_01.
      cs_error_01-msg_3      = '. Der Druckbeleg wurde noch nicht freigegeben!'(020).

      RETURN.


    ENDIF.

  ENDIF.

  SORT ct_erdk_01 BY vkont.


  CHECK NOT ct_erdk_01[] IS INITIAL.

  SELECT DISTINCT * FROM fkkvkp INTO TABLE ct_fkkvkp_01
    FOR ALL ENTRIES IN ct_erdk_01
    WHERE vkont EQ ct_erdk_01-vkont.

  IF sy-subrc NE 0.
*      Keine Aktion!
  ENDIF.

ENDFORM.                    " IDENTIFY_PRINTDOCS_01

*&---------------------------------------------------------------------*
*&      Form  PREPARE_PRINTDOC_FOR_OUTPUT_01
*&---------------------------------------------------------------------*

FORM prepare_printdoc_for_output_01  CHANGING    ct_erdk_01  TYPE erdk_tab.

  FIELD-SYMBOLS: <ls_erdk_01> TYPE erdk.

  DATA:           lv_tabix_01 TYPE sy-tabix.

  LOOP AT ct_erdk_01 ASSIGNING <ls_erdk_01>.

    MOVE sy-tabix TO lv_tabix_01.

    CLEAR: <ls_erdk_01>-edisenddate.

    DO 100 TIMES.

      CALL FUNCTION 'ENQUEUE_EZ_ERDK'
        EXPORTING
          mode_erdk      = 'E'
          mandt          = sy-mandt
          opbel          = <ls_erdk_01>-opbel
        EXCEPTIONS
          foreign_lock   = 1
          system_failure = 2
          OTHERS         = 3.

      IF sy-subrc <> 0.

        WAIT UP TO 1 SECONDS.

      ELSE.

        MODIFY erdk FROM <ls_erdk_01>.

        IF sy-subrc NE 0.

          DELETE ct_erdk_01 INDEX lv_tabix_01.

        ENDIF.


        CALL FUNCTION 'DEQUEUE_EZ_ERDK'
          EXPORTING
            mode_erdk = 'E'
            mandt     = sy-mandt
            opbel     = <ls_erdk_01>-opbel.

        EXIT.

      ENDIF.

    ENDDO.

  ENDLOOP.

ENDFORM.                    " PREPARE_PRINTDOC_FOR_OUTPUT_01


*&---------------------------------------------------------------------*
*&      Form  RESEND_ABS_01
*&---------------------------------------------------------------------*

FORM resend_abs_01  USING    iv_opbel_01      TYPE opbel_kk
                             iv_dynnr_01      TYPE sy-dynnr
                    CHANGING cs_error_01      TYPE ts_error_tab
                             ct_erdz_01       TYPE erdz_tab.


  FIELD-SYMBOLS: <ls_erdz_01>   TYPE erdz.

  DATA:           ls_abs_01  TYPE /adesso/edi_abs.

  CHECK iv_dynnr_01 EQ '200'.

  LOOP AT ct_erdz_01 ASSIGNING <ls_erdz_01>
    WHERE ab  IS NOT INITIAL
      AND bis IS NOT INITIAL.
  ENDLOOP.

  CHECK sy-subrc <> 0.


  SELECT SINGLE * FROM /adesso/edi_abs INTO ls_abs_01
    WHERE opbel EQ iv_opbel_01.

  IF sy-subrc EQ 0.

    IF NOT ls_abs_01-begabrpe IS INITIAL AND
       NOT ls_abs_01-endabrpe IS INITIAL.

      LOOP AT ct_erdz_01 ASSIGNING <ls_erdz_01>.
        <ls_erdz_01>-ab  = ls_abs_01-begabrpe.
        <ls_erdz_01>-bis = ls_abs_01-endabrpe.
      ENDLOOP.

    ELSE.

      cs_error_01-msg_typ    = 'E'.
      cs_error_01-msg_klasse = '00'.
      cs_error_01-msg_nr     = '001'.
      cs_error_01-msg_1      = 'Druckbeleg:'(010).
      cs_error_01-msg_2      =  iv_opbel_01.
      cs_error_01-msg_3      = 'Es ist kein Zeitraum ermittelbar!'(013).

      RETURN.

    ENDIF.

  ELSE.

    cs_error_01-msg_typ    = 'E'.
    cs_error_01-msg_klasse = '00'.
    cs_error_01-msg_nr     = '001'.
    cs_error_01-msg_1      = 'Druckbeleg:'(010).
    cs_error_01-msg_2      =  iv_opbel_01.
    cs_error_01-msg_3      = 'Es ist kein Referenzbeleg in ZEBIT_ABS ermittelbar!'(014).

    RETURN.

  ENDIF.

ENDFORM.                    " RESEND_ABS_01
