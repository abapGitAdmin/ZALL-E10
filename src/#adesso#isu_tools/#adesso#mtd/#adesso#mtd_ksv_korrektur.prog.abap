*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTD_KSV_KORREKTUR
*&
*&---------------------------------------------------------------------*
*&Der Report löscht doppelte Einträge in der TEMKSV in verschiedenen
*& Firmen
*&
*&
*&---------------------------------------------------------------------*
REPORT /adesso/mtd_ksv_korrektur.



TABLES: temksv, temob, temfirma.

SELECTION-SCREEN BEGIN OF BLOCK del WITH FRAME TITLE text-del.
SELECTION-SCREEN SKIP.
PARAMETERS: firma_l LIKE temfirma-firma DEFAULT 'EVU01' OBLIGATORY.
SELECT-OPTIONS object FOR temob-object DEFAULT 'DEVICE'.
SELECTION-SCREEN END OF BLOCK del.

SELECTION-SCREEN BEGIN OF BLOCK src WITH FRAME TITLE text-src.
PARAMETERS: firma_s LIKE temfirma-firma DEFAULT 'BOC' OBLIGATORY.

SELECTION-SCREEN END OF BLOCK src.

PARAMETERS: testlauf AS CHECKBOX DEFAULT 'X'..

DATA: idelksv  LIKE TABLE OF temksv WITH HEADER LINE.
DATA: isuchksv LIKE TABLE OF temksv WITH HEADER LINE.
DATA: idelete  LIKE TABLE OF temksv WITH HEADER LINE.


IF firma_l = firma_s.
  SKIP 3.
  WRITE: / 'Such- und Löschfirma müssen unterschiedlich sein !!!!!'.
  EXIT.
ENDIF.

CLEAR: idelksv, isuchksv, idelete.
REFRESH: idelksv, isuchksv, idelete.

SELECT * FROM temksv INTO TABLE idelksv
              WHERE firma = firma_l
               AND object IN object.


SELECT * FROM temksv INTO TABLE isuchksv
              WHERE firma = firma_s
               AND object IN object.


SORT isuchksv BY object oldkey.
SORT idelksv BY object oldkey.

LOOP AT isuchksv.

  READ TABLE idelksv WITH KEY object = isuchksv-object
                              oldkey = isuchksv-oldkey
                              newkey = isuchksv-newkey BINARY SEARCH.
  IF sy-subrc EQ 0.
    MOVE-CORRESPONDING idelksv TO idelete.
    APPEND idelete.
  ENDIF.

ENDLOOP.

IF testlauf EQ 'X'.

  SKIP 1.
  WRITE: / 'Folgende Datensätze werden gelöscht:'.
  LOOP AT idelete.
    WRITE: / idelete-object, idelete-oldkey, idelete-newkey.
  ENDLOOP.

ELSE.
  DELETE temksv FROM TABLE idelete.
  IF sy-subrc EQ 0.
    SKIP.
    WRITE: / 'Anzahl gelöschter Datensätze:', sy-dbcnt COLOR 3.
    COMMIT WORK.
  ELSE.
    WRITE: / 'löschen ist fehlgeschlagen. Rollback ausgeführt'.
    ROLLBACK WORK.
  ENDIF.
ENDIF.




*
