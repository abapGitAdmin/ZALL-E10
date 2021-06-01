*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTB_BEL_CHANGE_DISC
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT /adesso/mtb_bel_change_disc.

TYPE-POOLS isu05 .

TABLES: ediscdoc,
        ediscact.
TABLES: temksv.

DATA: iediscdoc LIKE ediscdoc OCCURS 0 WITH HEADER LINE.
DATA: iediscact LIKE ediscact OCCURS 0 WITH HEADER LINE.


DATA: BEGIN OF iout OCCURS 0,
       discno  LIKE ediscdoc-discno,
       ordstate LIKE ediscact-ordstate,
       actdate  LIKE ediscact-actdate,
       acttime  LIKE ediscact-acttime,
       discact  LIKE ediscact-discact,
      END OF iout.
DATA: x_auto TYPE  isu05_discdoc_auto.

DATA: unix_file LIKE temfd-path.
DATA: anz_gut TYPE i.
DATA: anz_err TYPE i.
DATA: anz_ges TYPE i.
DATA: datum LIKE sy-datum.
DATA: zeit  LIKE ediscact-acttime.
DATA: discno LIKE ediscdoc-discno.

DATA: ordstate_old LIKE ediscact-ordstate.

PARAMETERS: firma TYPE emg_firma DEFAULT 'EVU02'.
PARAMETERS: exp_path LIKE temfd-path
            DEFAULT '/migp1u/evuit/gen1e/',
            file(30) TYPE c  DEFAULT 'DISC_DOC_CHANGE'.


PARAMETERS: update AS CHECKBOX.


* Einlesen der Sperrdaten
CONCATENATE exp_path file INTO unix_file.

OPEN DATASET unix_file FOR INPUT IN TEXT MODE ENCODING DEFAULT.
DO.
  READ DATASET unix_file INTO iout.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.
  APPEND iout.
ENDDO.
CLOSE DATASET unix_file.

SORT iout BY discact.
LOOP AT iout.
  CLEAR discno.
  SELECT SINGLE * FROM temksv
                    WHERE firma = firma
                      AND object = 'DISC_DOC'
                      AND oldkey = iout-discno.
  IF sy-subrc NE '0'.
    CONTINUE.
  ELSE.
    discno = temksv-newkey.
  ENDIF.



  datum = iout-actdate + 1.
  zeit  = '033333'.
  CLEAR x_auto.
  x_auto-contr-use-okcode = 'X'.
  x_auto-contr-okcode     = 'DARKDCED'.
  x_auto-interface-darkdced-x_ordact = '0001'. "iout-discact. "'0001'.
  x_auto-interface-darkdced-x_ordstat = iout-ordstate.
  x_auto-interface-darkdced-x_discdate = datum.
  x_auto-interface-darkdced-x_disctime = zeit.

  IF update = 'X'.

* in der Tabelle EDISCACT muß das Feld ordstate auf '00' gesetzt
* werden (bei iout-Datensatz mit Status '21'.)

    IF iout-discact = '0002'.
      CLEAR ordstate_old.
      SELECT * FROM ediscact WHERE discno = discno
                               AND discact = '0001'
                               AND discacttyp = '01'
                               AND ordstate   NE '00'.
        MOVE ediscact-ordstate TO ordstate_old.
        MOVE '00' TO ediscact-ordstate.
        UPDATE ediscact.
      ENDSELECT.
      COMMIT WORK AND WAIT.
*      WAIT UP TO 1 SECONDS.
    ENDIF.


    CALL FUNCTION 'ISU_S_DISCDOC_CHANGE'
      EXPORTING
        x_discno                = discno "iout-discno
       x_upd_online             = 'X'
       x_no_dialog              = 'X'
       x_auto                   = x_auto
*     X_OBJ                    =
*     X_NO_OTHER               =
*     X_DISCACT                =
*     X_SET_COMMIT_WORK        =
*   IMPORTING
*     Y_DB_UPDATE              =
*     Y_EXIT_TYPE              =
*     Y_NEW_EDISCDOC           =
*     Y_INTERFACE              =
     EXCEPTIONS
       not_found                = 1
       foreign_lock             = 2
       not_authorized           = 3
       input_error              = 4
       general_fault            = 5
       object_inv_discdoc       = 6
       OTHERS                   = 7
              .
    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      WRITE: / discno, 'Fehler beim ändern', 'DISCNO-Alt', iout-discno,
               '-', iout-discact.
      anz_err = anz_err + 1.

* falls der Datensatz auf einen Fehler gelaufen ist, muss die Tabelle
* EDISCACT wieder zurück geändert werden.
      IF iout-discact = '0002'.
        SELECT * FROM ediscact WHERE discno = discno
                                 AND discact = '0001'
                                 AND discacttyp = '01'
                                 AND ordstate   EQ '00'.
          MOVE ordstate_old TO ediscact-ordstate.
          UPDATE ediscact.
        ENDSELECT.
        COMMIT WORK AND WAIT.

      ENDIF.

    ELSE.
      anz_gut = anz_gut + 1.
    ENDIF.

  ENDIF.

  anz_ges = anz_ges + 1.


ENDLOOP.

WRITE: / 'Anzahl Änderungen:', anz_gut.
WRITE: / 'Anzahl Fehler    :', anz_err.
WRITE: / 'Anzahl gesamt    :', anz_ges.
