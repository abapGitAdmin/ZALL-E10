FUNCTION /ADESSO/LW_EDISCDOC_DATA.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(X_DISCNO) TYPE  EDISCDOC-DISCNO
*"     REFERENCE(X_DISCACT) TYPE  EDISCACT-DISCACT OPTIONAL
*"  EXPORTING
*"     REFERENCE(Y_BAPIRETURN) TYPE  BAPIRETURN1
*"     REFERENCE(Y_ERROR) TYPE  REGEN-KENNZX
*"     REFERENCE(Y_OBJ) TYPE  ISU05_DISCDOC_INTERNAL
*"     REFERENCE(Y_EDISCDOC) TYPE  EDISCDOC
*"     REFERENCE(Y_EDISCACT) TYPE  EDISCACT
*"     REFERENCE(Y_DISCACT_STORNO) TYPE  EDISCACT
*"     REFERENCE(Y_COMMENTTXT) TYPE  EIDESWTMSGDATACO-COMMENTTXT
*"     REFERENCE(Y_ORDSTATE) TYPE  EDISCACT-ORDSTATE
*"     REFERENCE(Y_DESCRIPT) TYPE  EDISCORDSTATET-DESCRIPT
*"  EXCEPTIONS
*"      ZGPKE_551
*"      ZGPKE_552
*"----------------------------------------------------------------------

  DATA: wa_dfkkop   TYPE dfkkop,
        wa_ediscact TYPE  ediscact,
        x_lines     TYPE TABLE OF tline,
        lt_lines    TYPE TABLE OF tline,
*        w_lines  TYPE tline,
        t_discno    TYPE thead-tdname,
        lv_comment  TYPE /ADESSO/SPT_EDISCCOMMENT.

* Makros
  DEFINE set_message.
    move &1 to y_bapireturn-type.
    move &2 to y_bapireturn-id.
    move &3 to y_bapireturn-number.
    move &4 to y_bapireturn-message_v1.
    move &5 to y_bapireturn-message_v2.
    move &6 to y_bapireturn-message_v3.
    move &7 to y_bapireturn-message_v4.

    message id &2 type &1 number &3 into y_bapireturn-message
       with &4 &5 &6 &7 .
  END-OF-DEFINITION.

*   Sperrbeleg einlesen
  CALL FUNCTION 'ISU_O_DISCDOC_OPEN_INTERNAL'
    EXPORTING
      x_discno    = x_discno
      x_wmode     = '1'
      x_no_dialog = 'X'
    IMPORTING
      y_obj       = y_obj
    EXCEPTIONS
      OTHERS      = 0.
*   Sperrbeleg nicht gefunden
  IF sy-subrc NE 0.
    set_message gc_fehler gc_nakl '551' space space space space.
    y_error = 'X'.
    RAISE zgpke_551.
  ENDIF.

  y_ediscdoc = y_obj-ediscdoc.

  DESCRIBE TABLE y_obj-ediscact LINES sy-tabix.
  IF sy-tabix EQ 0.
    set_message gc_fehler gc_nakl '552' space space space space.
    y_error = 'X'.
    RAISE zgpke_552.
  ENDIF.

  IF NOT x_discact IS INITIAL.
    READ TABLE y_obj-ediscact INTO y_ediscact
            WITH KEY discact = x_discact.
  ELSE.
    SORT y_obj-ediscact BY discact DESCENDING.
    READ TABLE y_obj-ediscact INTO y_ediscact
            INDEX 1.
  ENDIF.

  IF NOT y_ediscact-orderact IS INITIAL   " = Antwortstatus steht in anderer Aktionszeile
    AND y_ediscact-disccanceld IS INITIAL.
    READ TABLE y_obj-ediscact INTO wa_ediscact
          WITH KEY discact = y_ediscact-orderact.
    y_ordstate = wa_ediscact-ordstate.
  ELSE.
    y_ordstate = y_ediscact-ordstate.
  ENDIF.

  IF y_commenttxt IS REQUESTED.
    WAIT UP TO 30 SECONDS.

* Betrag aus gebuchter Gebühr lesen
    CLEAR wa_dfkkop.
    IF NOT y_ediscact-ordstate IS INITIAL.   " = negative Rückmeldung, eine positive Rückmeldung wird im jeweiligen Auftrag hinterlegt
* da im negativen Fall die Belegnummer SAP-seitig nicht im Sperrbeleg gespeichert wird, entsprechende Gebühr ermitteln)
      DATA: i_fkkvkp   TYPE fkkvkp1,
            i_ever     TYPE ever,
            i_vtref    TYPE vtref_kk,
            i_num20    TYPE num20,
            it_tfk047k TYPE STANDARD TABLE OF tfk047k WITH HEADER LINE,
            s_hvorg    TYPE RANGE OF hvorg_kk WITH HEADER LINE,
            s_tvorg    TYPE RANGE OF tvorg_kk WITH HEADER LINE.

      READ TABLE y_obj-denv-ifkkvkp INTO i_fkkvkp INDEX 1.
      READ TABLE y_obj-denv-iever   INTO i_ever   INDEX 1.
      i_num20 = i_ever-vertrag.
      i_vtref = i_num20.

* mögliche Haupt- und Teilvorgänge lesen
      SELECT * FROM tfk047k INTO TABLE it_tfk047k
            WHERE chgid EQ '41'
              AND chgty EQ '41'.

      s_hvorg-sign = 'I'.
      s_hvorg-option = 'EQ'.
      s_tvorg-sign = 'I'.
      s_tvorg-option = 'EQ'.

      LOOP AT it_tfk047k.
        s_hvorg-low   = it_tfk047k-hvorg. APPEND s_hvorg.
        s_tvorg-low   = it_tfk047k-tvorg. APPEND s_tvorg.
      ENDLOOP.

      SORT s_hvorg BY low. DELETE ADJACENT DUPLICATES FROM s_hvorg COMPARING low.
      SORT s_tvorg BY low. DELETE ADJACENT DUPLICATES FROM s_tvorg COMPARING low.

* evtl. vorhandene Gebührenbuchung zu Geschäftspartner, Vertragskonto, Vertrag, aktuellem Beleg- und Buchungsdatum und
* für Gebührenbuchung in Frage kommende Haupt- und Teilvorgänge lesen
* (sollten mehrere Gebühren an einem Tag gebucht, wird der jeweils aktuellste, also der mit der höchsten Belegnummer genommen)

      SELECT * FROM dfkkop INTO wa_dfkkop
        WHERE gpart EQ i_fkkvkp-gpart
        AND   vtref EQ i_vtref
        AND   vkont EQ i_fkkvkp-vkont
        AND   hvorg IN s_hvorg
        AND   tvorg IN s_tvorg
        AND   bldat EQ sy-datum
        AND   budat EQ sy-datum     "
        AND   augrd EQ space        " nicht storniert
        ORDER BY opbel DESCENDING.
        EXIT. " nur der jeweils zuletzt gebuchte Beleg ist ausschlaggebend
      ENDSELECT.
    ELSE.
      SELECT SINGLE * FROM dfkkop INTO wa_dfkkop
        WHERE opbel EQ  y_ediscact-charge_opbel.
    ENDIF.
* K. Lattemann 15.08.14 Anfang
    t_discno = x_discno.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        client                  = sy-mandt
        id                      = 'ISU'
        language                = sy-langu
        name                    = t_discno
        object                  = 'EDCN'
*       ARCHIVE_HANDLE          = 0
*       LOCAL_CAT               = ' '
*     IMPORTING
*       HEADER                  =
*       OLD_LINE_COUNTER        =
      TABLES
        lines                   = x_lines
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
* Implement suitable error handling here
    ENDIF.
    CONCATENATE LINES OF x_lines INTO lv_comment SEPARATED BY space.
    CALL FUNCTION '/ADESSO/LW_COMMENT_EDISCDOC'
      EXPORTING
        x_wmode       = '3'
      CHANGING
        xy_commenttxt = y_commenttxt
        xy_discno     = y_ediscdoc-discno
        xy_discreason = y_ediscdoc-discreason
        xy_ordstate   = y_ordstate
        xy_refobjtype = y_ediscdoc-refobjtype
        xy_betrw      = wa_dfkkop-betrw
*       XY_TELNR      =
*       XY_EMAIL      =
        xy_hvorg      = wa_dfkkop-hvorg
        xy_tvorg      = wa_dfkkop-tvorg
        xy_bemerkung  = lv_comment.
  ENDIF.

  IF y_discact_storno IS REQUESTED.
* letzte Stornoaktion ermitteln
    SORT y_obj-ediscact BY discact ASCENDING.     " letzte Stornoaktion immer mit jüngster Aktionsnummer
    LOOP AT y_obj-ediscact INTO y_discact_storno
            WHERE NOT disccanceld IS INITIAL.
      EXIT.
    ENDLOOP.
  ENDIF.

  IF y_descript IS REQUESTED.
    SELECT SINGLE descript   FROM ediscordstatet
                  INTO y_descript
                  WHERE spras     = sy-langu
                  AND   ordstate = y_ordstate.
  ENDIF.

ENDFUNCTION.
