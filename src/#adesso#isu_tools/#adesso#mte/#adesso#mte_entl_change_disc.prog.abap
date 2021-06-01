*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTE_ENTL_CHANGE_DISC
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT /adesso/mte_entl_change_disc.

TABLES: ediscdoc,
        ediscact.

DATA: iediscdoc LIKE ediscdoc OCCURS 0 WITH HEADER LINE.
DATA: iediscact LIKE ediscact OCCURS 0 WITH HEADER LINE.


DATA: BEGIN OF iout OCCURS 0,
       discno  LIKE ediscdoc-discno,
       ordstate LIKE ediscact-ordstate,
       actdate  LIKE ediscact-actdate,
       acttime  LIKE ediscact-acttime,
       discact  LIKE ediscact-discact,
      END OF iout.


 DATA: unix_file LIKE temfd-path.
DATA: anzahl TYPE i.

DATA: p_discact LIKE ediscact-discact.



SELECT-OPTIONS: status FOR ediscdoc-status.
PARAMETERS: exp_path LIKE temfd-path
            DEFAULT '/migp1u/evuit/gen1e/',
            file(30) TYPE c  DEFAULT 'DISC_DOC_CHANGE'.



SELECT * FROM ediscdoc INTO TABLE iediscdoc
                      WHERE status IN status. " '00'
*                         or status = '10'.


LOOP AT iediscdoc.
  CLEAR iout.

  IF iediscdoc-status = '21'.
  SELECT * FROM ediscact INTO TABLE iediscact
                    WHERE discno = iediscdoc-discno.
   IF sy-subrc EQ 0.
     SORT iediscact BY discact DESCENDING.
     READ TABLE iediscact WITH KEY discacttyp = '02'.
      IF sy-subrc EQ 0.
        MOVE iediscdoc-discno TO iout-discno.
        MOVE '0002' TO iout-discact.
        MOVE iediscact-actdate  TO iout-actdate.
        MOVE iediscact-acttime  TO iout-acttime.
        p_discact = iediscact-discact - 1.
        LOOP AT iediscact WHERE discact = p_discact
                           AND ordstate BETWEEN '90' AND '98'.
         MOVE iediscact-ordstate TO iout-ordstate.
         APPEND iout.
         CLEAR iout.
        ENDLOOP.
      ELSE.
        CONTINUE.
      ENDIF.
   ELSE.
    CONTINUE.
   ENDIF.

  ELSE.

  SELECT * FROM ediscact INTO TABLE iediscact
                    WHERE discno = iediscdoc-discno
                      AND discacttyp = '01'
                      AND ordstate     NE '00'.
    IF sy-subrc EQ 0.

     SORT iediscact BY discact DESCENDING.
     READ TABLE iediscact INDEX 1.
     MOVE iediscdoc-discno TO iout-discno.
     MOVE '0001' TO iout-discact.
     MOVE iediscact-ordstate TO iout-ordstate.
     MOVE iediscact-actdate  TO iout-actdate.
     MOVE iediscact-acttime  TO iout-acttime.
     APPEND iout.
     CLEAR iout.
    ELSE.
    CONTINUE.
    ENDIF.
  ENDIF.

ENDLOOP.

DESCRIBE TABLE iout LINES anzahl.
WRITE: / 'Anzahl gefundener Datensätze', anzahl.

  CONCATENATE exp_path file INTO unix_file.

  OPEN DATASET unix_file FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.

  LOOP AT iout.
    TRANSFER iout TO unix_file.
  ENDLOOP.

  CLOSE DATASET unix_file.
