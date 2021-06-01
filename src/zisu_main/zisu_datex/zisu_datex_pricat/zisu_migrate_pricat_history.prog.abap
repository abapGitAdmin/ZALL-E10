*&---------------------------------------------------------------------*
*& Report ZISU_MIGRATE_PRICAT_HISTORY
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zisu_migrate_pricat_history.
TABLES: /idxgl/pricat_h, zv_pricat_idocs, zisu_pricat_exp, edextask.

DATA: lt_exp TYPE TABLE OF zisu_pricat_exp ,
      lv_exp TYPE zisu_pricat_exp,
      lt_edextask TYPE TABLE OF edextask,
      lv_edextask TYPE edextask,
      lv_pricat TYPE /idxgl/pricat_h,
      lv_same_pricat TYPE /idxgl/pricat_h,
      lt_pricat TYPE TABLE OF /idxgl/pricat_h.
DATA: lt_edid         TYPE STANDARD TABLE OF edid4,
      ls_edid         TYPE edid4.
DATA: ls_bgm       TYPE /idxgc/e1vdewbgm_2,
      ls_unh       TYPE /idxgc/e1vdewunh_1,
      lv_docnum       TYPE edi_docnum.


SELECTION-SCREEN BEGIN OF BLOCK select1 WITH FRAME TITLE TEXT-001 .
SELECT-OPTIONS: sel_send FOR edextask-dexservprovself,
                sel_recv FOR edextask-dexservprov.

SELECTION-SCREEN END OF BLOCK select1.


START-OF-SELECTION.


SELECT * FROM  zisu_pricat_exp INTO TABLE lt_exp.

 LOOP AT lt_exp INTO lv_exp.
   CLEAR: lv_pricat, lt_edextask, lv_edextask, lv_docnum, ls_edid, lv_pricat.
      SELECT * FROM edextask INTO TABLE lt_edextask
             WHERE dextaskid EQ  lv_exp-dextaskid
             AND dexstatus EQ 'OK'
             AND dexservprovself IN sel_send[]
             AND dexservprov     IN sel_recv[]
             ORDER BY dexduedate DESCENDING dexduetime DESCENDING.

     IF sy-subrc EQ 0.
      READ TABLE lt_edextask INTO lv_edextask INDEX 1.

        SELECT COUNT(*)
           FROM /idxgl/pricat_h
           WHERE bgm_docname_code = 'Z32'
           AND sender = lv_edextask-dexservprovself
           AND receiver = lv_edextask-dexservprov.

         IF sy-subrc NE 0.
            lv_pricat-sender         = lv_edextask-dexservprovself.
            lv_pricat-receiver       = lv_edextask-dexservprov.
            lv_pricat-val_start_date = lv_edextask-dexrefdatefrom.
            lv_pricat-msg_date       = lv_edextask-dexduedate.
            lv_pricat-msg_time       = lv_edextask-dexduetime.
            lv_pricat-price_catalogue_id = lv_exp-price_catalogue_id.
            lv_pricat-pricat_version_id  = lv_exp-pricat_version.

          SELECT SINGLE docnum FROM edextaskidoc INTO lv_docnum
                               WHERE dextaskid EQ lv_exp-dextaskid.

          SELECT  SINGLE * FROM edid4
                  INTO ls_edid
                  WHERE docnum EQ lv_docnum
                  AND segnam EQ '/IDXGC/E1VDEWBGM_2'.

              ls_bgm =  ls_edid-sdata.
              IF ls_bgm-name = 'Z32'.
                 lv_pricat-bgm_docname_code = 'Z32'.
              ENDIF.

          SELECT  SINGLE * FROM edid4
                   INTO ls_edid
                   WHERE docnum EQ lv_docnum
                   AND segnam EQ '/IDXGC/E1VDEWUNH_1'.
               ls_unh =  ls_edid-sdata.
               lv_pricat-current_ref_no = ls_unh-referencenumber.
               CLEAR lv_same_pricat.
          LOOP AT lt_pricat INTO lv_same_pricat WHERE  sender = lv_pricat-sender
                                                AND  receiver = lv_pricat-receiver
                                                AND  val_start_date = lv_pricat-val_start_date
                                                AND  msg_date = lv_pricat-msg_date.
            IF lv_pricat-current_ref_no > lv_same_pricat-current_ref_no.
               DELETE lt_pricat.
            ELSE.
               CLEAR lv_pricat.
            ENDIF.
          ENDLOOP.
          IF lv_pricat IS NOT INITIAL.
             APPEND lv_pricat TO lt_pricat.
          ENDIF.

         ENDIF.
         ENDIF.

 ENDLOOP.
    SORT lt_pricat BY sender receiver msg_date  msg_time DESCENDING.

    INSERT /idxgl/pricat_h FROM TABLE lt_pricat.
    IF sy-subrc = 0.
       COMMIT WORK.
       WRITE 'Alle Daten übertragen.'.
    ELSE.
        ROLLBACK WORK.
        WRITE 'Fehler beim Übertragung'.
    ENDIF.
