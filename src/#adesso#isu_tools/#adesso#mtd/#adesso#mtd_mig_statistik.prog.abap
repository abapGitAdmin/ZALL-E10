*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTD_MIG_STATISTIK
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT /ADESSO/MTD_MIG_STATISTIK.


* Felddefinitionen für Swelektionsbildschirm
DATA firma   TYPE temfirma-firma.
DATA object  TYPE temob-object.
DATA datum   TYPE sy-datum.
DATA zeit    TYPE sy-uzeit.
DATA user    TYPE sy-uname.

* Tabelle TEMSTATISTIK + TEMSTATISTILOG
DATA: BEGIN OF wa_temstat_and_log,
        s_name        TYPE  emg_s_name  ,
        s_date        TYPE  emg_s_date  ,
        s_time        TYPE  emg_s_time  ,
        s_id          TYPE  emg_s_id  ,
        knz_btc       TYPE  emg_batch ,
        firma         TYPE  emg_firma ,
        object        TYPE  emg_object  ,
        file          TYPE  emg_file  ,
        oldkey        TYPE  emg_oldkey  ,
        cnt_good      TYPE  emg_cnt_good  ,
        cnt_bad       TYPE  emg_cnt_bad ,
        cnt_datei     TYPE emg_anzahl,
        erabs         TYPE  emg_erabs ,
        errel         TYPE  emg_errel ,
        status        TYPE  emg_status  ,
        datum         TYPE  emg_adatum  ,
        uzeit         TYPE  emg_auzeit  ,
        mandt         TYPE  mandt ,
        jobname       TYPE  btcjob  ,
        jobcount      TYPE  btcjobcnt ,
        cnt_rerun     TYPE  emg_cnt_rerun ,
        restart       TYPE  emg_repeat  ,
        throughput    TYPE  emg_throughput  ,
        p_date        TYPE  emg_p_date  ,
        p_time        TYPE  emg_p_time  ,
        p_id          TYPE  emg_stepno  ,
        function_imp  TYPE  emg_function_import ,
        massrun_imp   TYPE  emg_massrun_import  ,
        runid         TYPE  emg_massrun ,
        cnt_restart   TYPE  emg_cnt_restart ,
        execserver    TYPE  btcsrvname  ,
        wp_no         TYPE  wpno  ,
        lognumber1    TYPE  balognr ,
        lognumber2    TYPE  balognr ,
        lognumber3    TYPE  balognr ,
        lognumber4    TYPE  balognr ,
        lognumber5    TYPE  balognr ,
      END OF wa_temstat_and_log.

DATA it_temstat_and_log LIKE TABLE OF wa_temstat_and_log.

* Tabelle für Protokolle
DATA: BEGIN OF wa_log_number,
       mandt     LIKE sy-mandt,
       lognumber TYPE balognr,
       file      TYPE temstatistik-file,
       object    TYPE temob-object,
       firma     TYPE temfirma-firma,
       datum     TYPE sy-datum,
       uzeit     TYPE sy-uzeit,
      END OF wa_log_number.
DATA: it_log_number LIKE TABLE OF wa_log_number.

* Itab und Workare der BALHDR
DATA: it_balhdr TYPE balhdr_t,
      wa_balhdr LIKE LINE OF it_balhdr.

DATA: BEGIN OF wa_log_handle,
        balloghndl TYPE balloghndl,
      END OF wa_log_handle.
DATA: it_log_handle TYPE bal_t_logh.

DATA: it_msg_handle TYPE bal_t_msgh,
      wa_msg_handle TYPE balmsghndl.

DATA: in_msg TYPE bal_s_msg,
      msg_text(255) TYPE c.

DATA:  BEGIN OF msg.
INCLUDE TYPE bal_s_msg.
DATA:  msgnr(3) TYPE c,
       END OF msg.
DATA:  it_msg LIKE TABLE OF msg.

* Ausgabetabelle
DATA: BEGIN OF wa_ausgabe,
        firma      TYPE temfirma-firma,
        object     TYPE temob-object,
        mandt      TYPE sy-mandt,
        error(25)  TYPE c,
        msg_text   TYPE string,
        msgv1      TYPE symsgv,
        msgv2      TYPE symsgv,
        msgv3      TYPE symsgv,
        msgv4      TYPE symsgv,
        oldkey(50) TYPE c,
        file       TYPE temstatistik-file,
        datum(10)  TYPE c,
        uzeit(8)   TYPE c,
      END OF wa_ausgabe.
DATA: it_ausgabe LIKE STANDARD TABLE OF wa_ausgabe.
**        text TYPE NATXT,
**        t100 TYPE t100,
*        file type TEMSTATISTIK-file,
*      end of msg_with_oldkey,
*      gt_msg_with_oldkey LIKE TABLE OF msg_with_oldkey.

DATA: wa_temksv TYPE temksv.

DATA: wa_t100  TYPE t100.

DATA: wa_download TYPE string,
      it_download LIKE TABLE OF wa_download.

DATA: z_error   TYPE i,
      z_temksv  TYPE i.

DATA: wrong_input TYPE char1,
      h_obj       TYPE temksv-object,
      h_firma     TYPE temksv-firma.

*************************************************************************
* Selektionsbildschirm
*************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-001.
SELECT-OPTIONS: so_firma FOR firma,
                so_obj   FOR object,
                so_datum FOR datum DEFAULT sy-datum,
                so_zeit  FOR zeit,
                so_user  FOR user DEFAULT sy-uname.
SELECTION-SCREEN SKIP.
PARAMETERS p_temksv AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE text-002.
SELECTION-SCREEN SKIP.
PARAMETERS: p_datei TYPE string DEFAULT 'c:\migstat.csv'.
SELECTION-SCREEN END OF BLOCK bl2.



***************************************************************************
* START-OF-SELECTION
***************************************************************************
START-OF-SELECTION.
* TEMKSV prüfen
  PERFORM temksv_anzahl.
* Daten Sammeln
  IF wrong_input IS INITIAL.
    PERFORM get_data.
    PERFORM get_protokolle.
    PERFORM write_protokoll.
  ENDIF.



***************************************************************************
* END-OF-SELECTION
***************************************************************************
END-OF-SELECTION.
  PERFORM zusammenfassung.


*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data .

  REFRESH it_temstat_and_log.
  CLEAR it_temstat_and_log.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE it_temstat_and_log
      FROM temstatistik INNER JOIN temstatistik_log
        ON temstatistik~s_name  = temstatistik_log~s_name
        AND temstatistik~s_date = temstatistik_log~s_date
        AND temstatistik~s_time = temstatistik_log~s_time
        AND temstatistik~s_id   = temstatistik_log~s_id
        WHERE temstatistik~firma IN so_firma
        AND temstatistik~object  IN so_obj
        AND temstatistik~s_date  IN so_datum
        AND temstatistik~s_time  IN so_zeit
        AND temstatistik~s_name  IN so_user
        AND mandt = sy-mandt.

  LOOP AT it_temstat_and_log INTO wa_temstat_and_log.
    wa_temstat_and_log-cnt_datei = wa_temstat_and_log-cnt_good +
                                   wa_temstat_and_log-cnt_bad +
                                   wa_temstat_and_log-cnt_rerun.


    MODIFY it_temstat_and_log FROM wa_temstat_and_log INDEX sy-tabix.

  ENDLOOP.

ENDFORM.                    " GET_DATA


*&---------------------------------------------------------------------*
*&      Form  GET_PROTOKOLLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_protokolle .


* Sammeln der relevanten Protokollnummen
  REFRESH it_log_number.
  CLEAR it_log_number.

  LOOP AT it_temstat_and_log INTO wa_temstat_and_log.
    CLEAR wa_log_number.
*   Es werden nur die Protokolle gesammelt, bei denen die Fehlerazahl größer Null ist
*   und die Lognummer 2 gefüllt ist.
    IF NOT wa_temstat_and_log-lognumber2 IS INITIAL AND wa_temstat_and_log-cnt_bad > 0.
      MOVE wa_temstat_and_log-lognumber2 TO wa_log_number-lognumber.
      MOVE wa_temstat_and_log-mandt      TO wa_log_number-mandt.
      MOVE wa_temstat_and_log-file       TO wa_log_number-file.
      MOVE wa_temstat_and_log-object     TO wa_log_number-object.
      MOVE wa_temstat_and_log-firma      TO wa_log_number-firma.
      MOVE wa_temstat_and_log-s_date     TO wa_log_number-datum.
      MOVE wa_temstat_and_log-s_time     TO wa_log_number-uzeit.
      APPEND wa_log_number TO it_log_number.
    ENDIF.
  ENDLOOP.

* Sammelön derProtokolle
  CLEAR it_balhdr.

  LOOP AT it_log_number INTO wa_log_number.

    SELECT * FROM balhdr CLIENT SPECIFIED
      INTO CORRESPONDING FIELDS OF TABLE it_balhdr
      WHERE mandant = wa_log_number-mandt
       AND lognumber = wa_log_number-lognumber.

    REFRESH it_log_handle.
    REFRESH it_msg_handle.


*   Laden der Anwendungsprotokolle aus der Datenbank
    CALL FUNCTION 'BAL_DB_LOAD'
     EXPORTING
        i_t_log_header                      =   it_balhdr
*   I_T_LOG_HANDLE                      =
*   I_T_LOGNUMBER                       =
*   I_CLIENT                            = SY-MANDT
*   I_DO_NOT_LOAD_MESSAGES              = ' '
        i_exception_if_already_loaded       = 'X'
     IMPORTING
       e_t_log_handle                      =  it_log_handle
       e_t_msg_handle                      =  it_msg_handle
     EXCEPTIONS
       no_logs_specified                   = 1
       log_not_found                       = 2
       log_already_loaded                  = 3
       OTHERS                              = 4.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.


    LOOP AT it_log_handle INTO wa_log_handle.

      LOOP AT  it_msg_handle INTO wa_msg_handle
         WHERE log_handle = wa_log_handle-balloghndl.

        CALL FUNCTION 'BAL_LOG_MSG_READ'
          EXPORTING
            i_s_msg_handle                 = wa_msg_handle
*           I_LANGU                        = SY-LANGU
           IMPORTING
             e_s_msg                        = in_msg
*            E_EXISTS_ON_DB                 =
*            E_TXT_MSGTY                    =
*            E_TXT_MSGID                    =
*            E_TXT_DETLEVEL                 =
*            E_TXT_PROBCLASS                =
             e_txt_msg                      =   msg_text
*            E_WARNING_TEXT_NOT_FOUND       =
         EXCEPTIONS
            log_not_found                  = 1
            msg_not_found                  = 2
            OTHERS                         = 3.
        IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.

        CLEAR msg.
        MOVE-CORRESPONDING in_msg TO msg.
        MOVE msg-msgno TO  msg-msgnr.


* Daten wegschreiben
* Fehlermeldung 110 (Fehler bei Bearbeitung Altsystemschlüssel)
* kommt immer hinterher
        IF msg-msgno = '110'.
          MOVE msg-msgv1 TO wa_ausgabe-oldkey.
* Prüfen, ob der Oldkey schon migriert wurde
          SELECT SINGLE * FROM temksv
              CLIENT SPECIFIED
              INTO wa_temksv
              WHERE mandt  = wa_log_number-mandt
               AND  firma  = wa_log_number-firma
               AND  object = wa_log_number-object
               AND  oldkey = wa_ausgabe-oldkey.
* Ja - Oldkey stammt aus altem Fehler ist nun migriert
* Weiter
* Zusätzliche Prüfung auf Flag P_TEMKSV
* Wenn dieses Flag nicht gesetzt ist, wird der Fehler
* trotzdem ausgegeben.
          IF sy-subrc = 0 AND
              p_temksv IS NOT INITIAL.
            CLEAR wa_ausgabe.
            CONTINUE.
          ELSE.
* Nein  Anhängen an die Itab
            IF NOT wa_ausgabe-msg_text IS INITIAL.
*              ADD 1 TO z_error.
              APPEND wa_ausgabe TO it_ausgabe.
            ENDIF.
          ENDIF.
*  Sonstige Fehlermeldungen
        ELSE.
          MOVE wa_log_number-firma    TO wa_ausgabe-firma.
          MOVE wa_log_number-object   TO wa_ausgabe-object.
          MOVE wa_log_number-mandt    TO wa_ausgabe-mandt.
*          CONCATENATE wa_log_number-datum+6(2)
*                      '.'
*                      wa_log_number-datum+4(2)
*                      '.'
*                      wa_log_number-datum+0(4)
*                      INTO wa_ausgabe-datum.
          MOVE wa_log_number-datum    TO wa_ausgabe-datum.
*          CONCATENATE wa_log_number-uzeit+0(2)
*                      ':'
*                      wa_log_number-uzeit+2(2)
*                      ':'
*                      wa_log_number-uzeit+4(2)
*                      INTO wa_ausgabe-uzeit.
          MOVE wa_log_number-uzeit    TO wa_ausgabe-uzeit.
          CONCATENATE msg-msgid
                      msg-msgno
                      INTO wa_ausgabe-error
                      SEPARATED BY space.
          MOVE msg_text TO wa_ausgabe-msg_text.
          MOVE wa_log_number-file     TO wa_ausgabe-file.

          SELECT SINGLE * FROM t100 INTO wa_t100
            WHERE sprsl = sy-langu
            AND   arbgb = msg-msgid
            AND   msgnr = msg-msgno.

* Wenn Variable 1 schon in Nachricht drin ist, dann nicht
* noch einmal in Tabelle
          IF wa_t100-text CS '&1'.
            CLEAR wa_ausgabe-msgv1.
          ELSE.
            MOVE msg-msgv1              TO wa_ausgabe-msgv1.
          ENDIF.

* Wenn Variable 2 schon in Nachricht drin ist, dann nicht
* noche einmal in Tabelle
          IF wa_t100-text CS '&2'.
            CLEAR wa_ausgabe-msgv2.
          ELSE.
            MOVE msg-msgv2              TO wa_ausgabe-msgv2.
          ENDIF.

* Wenn Variable 3 schon in Nachricht drin ist, dann nicht
* noche einmal in Tabelle
          IF wa_t100-text CS '&3'.
            CLEAR wa_ausgabe-msgv3.
          ELSE.
            MOVE msg-msgv3              TO wa_ausgabe-msgv3.
          ENDIF.

* Wenn Variable 4 schon in Nachricht drin ist, dann nicht
* noche einmal in Tabelle
          IF wa_t100-text CS '&4'.
            CLEAR wa_ausgabe-msgv4.
          ELSE.
            MOVE msg-msgv4              TO wa_ausgabe-msgv4.
          ENDIF.

        ENDIF.

      ENDLOOP.

    ENDLOOP.

  ENDLOOP.


ENDFORM.                    " GET_PROTOKOLLE


*&---------------------------------------------------------------------*
*&      Form  WRITE_PROTOKOLL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_protokoll .

  SORT it_ausgabe BY oldkey ASCENDING
                     datum DESCENDING
                     uzeit DESCENDING.

  DELETE ADJACENT DUPLICATES FROM it_ausgabe
                  COMPARING mandt
                            firma
                            object
                            error
                            oldkey
                            file.

  CONCATENATE 'Mandant'
              'Firma'
              'Objekt'
              'Fehler-Nr'
              'Nachrichtentext'
              'Variable 1'
              'Variable 2'
              'Variable 3'
              'Variable 4'
              'Altschlüssel'
              'Importdatei'
              'Datum'
              'Uhrzeit'
              INTO wa_download
              SEPARATED BY ';'.
  APPEND wa_download TO it_download.
  CLEAR wa_download.


  LOOP AT it_ausgabe INTO wa_ausgabe.

* Datum konvertieren
    CONCATENATE wa_ausgabe-datum+6(2)
            '.'
            wa_ausgabe-datum+4(2)
            '.'
            wa_ausgabe-datum+0(4)
            INTO wa_ausgabe-datum.

* Uhrzeit konvertieren
    CONCATENATE wa_ausgabe-uzeit+0(2)
                ':'
                wa_ausgabe-uzeit+2(2)
                ':'
                wa_ausgabe-uzeit+4(2)
                INTO wa_ausgabe-uzeit.


    CONCATENATE   wa_ausgabe-mandt
                  wa_ausgabe-firma
                  wa_ausgabe-object
                  wa_ausgabe-error
                  wa_ausgabe-msg_text
                  wa_ausgabe-msgv1
                  wa_ausgabe-msgv2
                  wa_ausgabe-msgv3
                  wa_ausgabe-msgv4
                  wa_ausgabe-oldkey
                  wa_ausgabe-file
                  wa_ausgabe-datum
                  wa_ausgabe-uzeit
                  INTO wa_download
                  SEPARATED BY ';'.
    ADD 1 TO z_error.
    APPEND wa_download TO it_download.
    CLEAR wa_download.
  ENDLOOP.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
*   BIN_FILESIZE                    =
      filename                        = p_datei
*   FILETYPE                        = 'ASC'
*   APPEND                          = ' '
*   WRITE_FIELD_SEPARATOR           = ' '
*   HEADER                          = '00'
*   TRUNC_TRAILING_BLANKS           = ' '
*   WRITE_LF                        = 'X'
*   COL_SELECT                      = ' '
*   COL_SELECT_MASK                 = ' '
*   DAT_MODE                        = ' '
*   CONFIRM_OVERWRITE               = ' '
*   NO_AUTH_CHECK                   = ' '
*   CODEPAGE                        = ' '
*   IGNORE_CERR                     = ABAP_TRUE
*   REPLACEMENT                     = '#'
*   WRITE_BOM                       = ' '
*   TRUNC_TRAILING_BLANKS_EOL       = 'X'
*   WK1_N_FORMAT                    = ' '
*   WK1_N_SIZE                      = ' '
*   WK1_T_FORMAT                    = ' '
*   WK1_T_SIZE                      = ' '
*   WRITE_LF_AFTER_LAST_LINE        = ABAP_TRUE
*   SHOW_TRANSFER_STATUS            = ABAP_TRUE
* IMPORTING
*   FILELENGTH                      =
    TABLES
      data_tab                        =  it_download
*   FIELDNAMES                      =
 EXCEPTIONS
   file_write_error                = 1
   no_batch                        = 2
   gui_refuse_filetransfer         = 3
   invalid_type                    = 4
   no_authority                    = 5
   unknown_error                   = 6
   header_not_allowed              = 7
   separator_not_allowed           = 8
   filesize_not_allowed            = 9
   header_too_long                 = 10
   dp_error_create                 = 11
   dp_error_send                   = 12
   dp_error_write                  = 13
   unknown_dp_error                = 14
   access_denied                   = 15
   dp_out_of_memory                = 16
   disk_full                       = 17
   dp_timeout                      = 18
   file_not_found                  = 19
   dataprovider_exception          = 20
   control_flush_error             = 21
   OTHERS                          = 22
            .
  IF sy-subrc <> 0.
    FORMAT COLOR COL_NEGATIVE INTENSIFIED OFF.
    WRITE: /5 'Fehler beim Übertragen der Daten'.
    EXIT.
  ENDIF.


ENDFORM.                    " WRITE_PROTOKOLL

*&---------------------------------------------------------------------*
*&      Form  ZUSAMMENFASSUNG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM zusammenfassung .

  NEW-PAGE.
  SKIP 2.
  IF NOT wrong_input IS INITIAL.
    FORMAT COLOR COL_NEGATIVE INTENSIFIED OFF.
    WRITE: /5 'Bitte geben Sie genau eine Firma und genau ein Objekt ein'.
  ELSE.
    WRITE: /5 'Einträge für Firma', h_firma, 'und Objekt', h_obj,  'in TEMKSV :', 60 z_temksv.
    WRITE: /5 'Vorhandene Migrationsfehler:', 60 z_error.
    IF p_temksv IS INITIAL.
      SKIP.
      WRITE: /5 'In der Fehlermenge können bereits migrierte Einträge vorhanden sein'.
    ENDIF.
  ENDIF.



ENDFORM.                    " ZUSAMMENFASSUNG

*&---------------------------------------------------------------------*
*&      Form  TEMKSV_ANZAHL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM temksv_anzahl .

  DATA: l_lines_firma TYPE i,
        l_lines_obj   TYPE i.

  DATA: lit_temksv TYPE STANDARD TABLE OF temksv.

* Nur eine Firma im Selektionsbildschirm
  DESCRIBE TABLE so_firma  LINES l_lines_firma.
  IF l_lines_firma NE 1.
    wrong_input = 'X'.
    EXIT.
  ENDIF.

* Nur ein Objekt im Selektionsbildschirm
  DESCRIBE TABLE so_obj    LINES l_lines_obj.
  IF l_lines_obj NE 1.
    wrong_input = 'X'.
    EXIT.
  ENDIF.

  LOOP AT so_firma.
    IF so_firma-option NE 'EQ' OR
       so_firma-sign NE 'I' OR
       so_firma-low IS INITIAL OR
      NOT so_firma-high IS INITIAL.
      wrong_input = 'X'.
      EXIT.
    ENDIF.
  ENDLOOP.

  LOOP AT so_obj.
    IF so_obj-option NE 'EQ' OR
       so_obj-sign NE 'I' OR
       so_obj-low IS INITIAL OR
      NOT so_obj-high IS INITIAL.
      wrong_input = 'X'.
      EXIT.
    ENDIF.
  ENDLOOP.

  SELECT * FROM temksv INTO TABLE lit_temksv
    WHERE firma IN so_firma
     AND  object IN so_obj.

  DESCRIBE TABLE lit_temksv LINES z_temksv.

  h_obj = so_obj-low.
  h_firma = so_firma-low.

ENDFORM.                    " TEMKSV_ANZAHL
