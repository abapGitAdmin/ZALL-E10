REPORT /adesso/add_servprov_dexproc.
***************************************************************************************************
* THIMEL.R, 20150827, Programm zum Hinzufügen von DA-Prozessen zum Serviceanbieter
***************************************************************************************************
DATA: lt_servprov         TYPE TABLE OF eservprov,
      lt_servprov_own     TYPE TABLE OF eservprov,
      lt_dexproc          TYPE TABLE OF edexproc,
      ls_dexproct         type edexproct,
      lt_dexdefservprov   TYPE TABLE OF edexdefservprov,
      ls_edexbasicprocfor TYPE edexbasicprocfor,
      ls_edexbasicproc    type edexbasicproc,
      ls_dexdefservprov   TYPE edexdefservprov,
      ls_dexcommformat    TYPE edexcommformat,
      ls_dexcommformatt   TYPE edexcommformatt,
      ls_dexcommformmail  TYPE edexcommformmail,
      ls_dexcommmailaddr  TYPE edexcommmailaddr.

FIELD-SYMBOLS: <fs_servprov>     TYPE eservprov,
               <fs_servprov_own> TYPE eservprov,
               <fs_dexproc>      TYPE edexproc.

SELECT-OPTIONS: so_srvid FOR <fs_servprov>-serviceid,
                so_dxprc FOR <fs_dexproc>-dexproc.

PARAMETERS:     p_test AS CHECKBOX DEFAULT abap_true.

START-OF-SELECTION.
  SELECT * FROM eservprov INTO TABLE lt_servprov WHERE serviceid IN so_srvid.
  SELECT * FROM edexproc INTO TABLE lt_dexproc WHERE dexproc IN so_dxprc.
  SELECT * FROM eservprov INTO TABLE lt_servprov_own WHERE own_log_sys = abap_true.

  LOOP AT lt_servprov ASSIGNING <fs_servprov>.
    "ToDo: Hier relevante Daten zum Serviceanbieter lesen, z.B. Email Adressen
* aus einem bestehenden DA-Prozess die Kommunikationsdaten (Emailadressen) lesen.


* Serviceanbieter sperren um Update durchzuführen
    CALL FUNCTION 'ENQUEUE_E_EDMIDE_SERVPRO'
      EXPORTING
        mode_eservprov = 'E'
        mandt          = sy-mandt
        serviceid      = <fs_servprov>-serviceid
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
      "Error
    ENDIF.


    LOOP AT lt_dexproc ASSIGNING <fs_dexproc>.
      CLEAR: ls_dexdefservprov, ls_dexcommformat, ls_dexcommformatt, ls_dexcommformmail, ls_dexcommmailaddr.

      ls_dexdefservprov-dexproc     = <fs_dexproc>-dexproc.
      ls_dexdefservprov-dexservprov = <fs_servprov>-serviceid.
      READ TABLE lt_servprov_own ASSIGNING <fs_servprov_own> WITH KEY service = <fs_dexproc>-dexserviceself.
      ls_dexdefservprov-dexservprovself = <fs_servprov_own>-serviceid.
      "ToDo: Weiter füllen

* Prüfen, ob der Prozess vorhanden ist.
      CALL METHOD cl_isu_datex_definition=>select_sp
        EXPORTING
          im_dexservprov     = ls_dexdefservprov-dexservprov
          im_dexproc         = ls_dexdefservprov-dexproc
          im_dexservprovself = ls_dexdefservprov-dexservprovself
        IMPORTING
          ext_dexdefservprov = lt_dexdefservprov
        EXCEPTIONS
          not_found          = 1
          OTHERS             = 2.
      IF sy-subrc = 1.
        "ToDo: Hier Struktur korrekt befüllen
        "ls_edexdefservprov-... = .
        clear ls_edexbasicproc.
        select single * from edexbasicproc into ls_edexbasicproc
          where dexbasicproc = <fs_dexproc>-DEXBASICPROC.

        CLEAR ls_edexbasicprocfor.
        SELECT SINGLE * FROM edexbasicprocfor INTO ls_edexbasicprocfor
          WHERE dexbasicproc = <fs_dexproc>-dexbasicproc
          AND dexformat LIKE 'IDXGC%'.

        ls_dexdefservprov-dexformat = ls_edexbasicprocfor-dexformat.
        ls_dexdefservprov-datefrom = sy-datum.
        ls_dexdefservprov-dateto = '99991231'.
        ls_dexdefservprov-dexnoduecontr = abap_true.
        ls_dexdefservprov-dexidocsend = 'EINZELN'.   "Problem es gibt auch ein paar aggregierte ???Identifikation???

        CALL FUNCTION 'GUID_CREATE' IMPORTING ev_guid_22 = ls_dexdefservprov-dexcommformid.

        ls_dexcommformat-dexcommformid = ls_dexdefservprov-dexcommformid.
        ls_dexcommformat-dexcommtype = 'EMAIL'.
        ls_dexcommformat-dexcommform = 'UNEDI'.
        "ToDo: Weitere Felder?


        IF p_test IS INITIAL.
          INSERT edexdefservprov FROM ls_dexdefservprov.
          IF sy-subrc NE 0.
            "ToDo: Fehlerbehandlung
          ENDIF.


          INSERT edexcommformat FROM ls_dexcommformat.
          IF sy-subrc <> 0.
            "ToDo: Fehlerbehandlung
            ROLLBACK WORK.
          ELSE.
            ls_dexcommformatt-dexcommformid = ls_dexdefservprov-dexcommformid.
            ls_dexcommformatt-spras         = 'DE'.

            select single * from edexproct into ls_dexproct
              where DEXPROC = <fs_dexproc>-DEXPROC
              and spras = 'DE'.

            ls_dexcommformatt-dexcommformtext = ls_dexproct-dexproctxt.
            "ToDo: Weitere Felder?
            INSERT edexcommformatt FROM ls_dexcommformatt.
            IF sy-subrc NE 0.
              "ToDo: Fehlerbehandlung
*******************************************************************************************
* ToDo
******************************************************************************************
              ROLLBACK WORK.
            ELSE.
              "Was noch?
              ls_dexcommformmail-dexcommformid = ls_dexdefservprov-dexcommformid.
              "ToDo: ggf. hier weiter füllen
              CALL FUNCTION 'GUID_CREATE'
                IMPORTING
                  ev_guid_22 = ls_dexcommformmail-dexcommfrom.

              INSERT edexcommmailaddr FROM ls_dexcommmailaddr.
              IF sy-subrc NE 0.
                "ToDo: Fehlerbehandlung
              ENDIF.
            ENDIF.
            CALL FUNCTION 'GUID_CREATE'
              IMPORTING
                ev_guid_22 = ls_dexcommformmail-dexcommto.
            IF sy-subrc NE 0.
              "ToDo: Fehlerbehandlung
            ENDIF.
            ls_dexcommmailaddr-dexcommaddrid = ls_dexcommformmail-dexcommto.
            INSERT edexcommmailaddr FROM ls_dexcommmailaddr.
            IF sy-subrc NE 0.
              "ToDo: Fehlerbehandlung
            ENDIF.
          ENDIF.
          "die ggf. auch noch wie oben:
*          ls_dexcommformmail-dexcommcc
*          ls_dexcommformmail-dexcommbcc.

        ENDIF.
      ENDIF.
    ENDLOOP.

* Serviceanbieter entsperren nach Update
    CALL FUNCTION 'DEQUEUE_E_EDMIDE_SERVPRO'
      EXPORTING
        mode_eservprov = 'E'
        mandt          = sy-mandt
        serviceid      = <fs_servprov>-serviceid.

* Ausgabe was angelegt wurde... entweder Textinfo mit Anzahl usw. oder eine Liste.


  ENDLOOP.
