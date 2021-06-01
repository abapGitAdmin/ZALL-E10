FUNCTION /ADESSO/LW_COMMENT_EDISCDOC.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(X_WMODE) TYPE  REGEN-WMODE DEFAULT '1'
*"     REFERENCE(X_DISCACT) TYPE  EDISCACT-DISCACT OPTIONAL
*"     REFERENCE(X_DISCNO) TYPE  EDISCDOC-DISCNO OPTIONAL
*"     REFERENCE(X_DISCREASON) TYPE  EDISCDOC-DISCREASON OPTIONAL
*"  EXPORTING
*"     REFERENCE(Y_DESCRIPT) TYPE  EDISCORDSTATET-DESCRIPT
*"  TABLES
*"      XY_BEMERKUNGEN STRUCTURE  TLINE OPTIONAL
*"  CHANGING
*"     REFERENCE(XY_COMMENTTXT) TYPE  EIDESWTMSGDATACO-COMMENTTXT
*"     REFERENCE(XY_DISCNO) TYPE  EDISCDOC-DISCNO OPTIONAL
*"     REFERENCE(XY_DISCREASON) TYPE  EDISCDOC-DISCREASON OPTIONAL
*"     REFERENCE(XY_ORDSTATE) TYPE  EDISCACT-ORDSTATE OPTIONAL
*"     REFERENCE(XY_REFOBJTYPE) TYPE  EDISCDOC-REFOBJTYPE OPTIONAL
*"     REFERENCE(XY_BETRW) TYPE  DFKKOP-BETRW OPTIONAL
*"     REFERENCE(XY_TELNR) TYPE  ADR2-TELNR_LONG OPTIONAL
*"     REFERENCE(XY_EMAIL) TYPE  ADR6-SMTP_ADDR OPTIONAL
*"     REFERENCE(XY_HVORG) TYPE  HVORG_KK OPTIONAL
*"     REFERENCE(XY_TVORG) TYPE  TVORG_KK OPTIONAL
*"     REFERENCE(XY_BEMERKUNG) TYPE  ZEDISCDOCCOMMENT OPTIONAL
*"----------------------------------------------------------------------
* max. 255 Zeichen für COMMENTTEXT
* zur Zeit belegt: 312
* Anzahl Zeichen:
*  12 -> XY_DISCNO
*   2 -> XY_DISCREASON
*   2 -> XY_ORDSTATE
*  10 -> XY_REFOBJTYPE
*  15 -> XY_BETRW
*  30 -> XY_TELNR
* 241 -> XY_EMAIL

  DATA: i_betrw TYPE string.

  CASE x_wmode.
    WHEN 1.
* 1 = Kommentar erstellen aus Sperrbeleg
      IF NOT x_discno IS INITIAL.
        CALL FUNCTION '/ADESSO/LW_EDISCDOC_DATA'
          EXPORTING
            x_discno     = x_discno
            x_discact    = x_discact
          IMPORTING
*           Y_BAPIRETURN =
*           Y_ERROR      =
*           Y_OBJ        =
*           Y_EDISCDOC   =
*           Y_EDISCACT   =
            y_commenttxt = xy_commenttxt
            y_descript   = y_descript
          EXCEPTIONS
*           ZGPKE_551    = 1
*           ZGPKE_552    = 2
            OTHERS       = 3.
        IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.
      ENDIF.
    WHEN 2.
* 2 = Felder lesen (= Kommentar "zerlegen")
      SPLIT xy_commenttxt AT ';' INTO
                  xy_discno
                  xy_discreason
                  xy_ordstate
                  xy_refobjtype
                  i_betrw
                  xy_telnr
                  xy_email
                  xy_hvorg
                  xy_tvorg
                  xy_bemerkung.
      MOVE i_betrw TO xy_betrw.

      IF y_descript IS REQUESTED.
        SELECT SINGLE descript   FROM ediscordstatet
                      INTO y_descript
                      WHERE spras     = sy-langu
                      AND   ordstate = xy_ordstate.
      ENDIF.
    WHEN 3.
* 3 = Kommentar erstellen zu übergebenen Feldern

      IF xy_discreason IS INITIAL.
        IF NOT x_discreason IS INITIAL.
          xy_discreason = x_discreason.
        ENDIF.
      ENDIF.

      MOVE xy_betrw TO i_betrw.
      CONCATENATE xy_discno "12
                  xy_discreason "2
                  xy_ordstate "2
                  xy_refobjtype "10
                  i_betrw "13
                  xy_telnr " nicht übergeben
                  xy_email " nicht übergeben
                  xy_hvorg "4
                  xy_tvorg "4
                  xy_bemerkung
                  INTO xy_commenttxt
                  SEPARATED BY ';'.
  ENDCASE.

ENDFUNCTION.
