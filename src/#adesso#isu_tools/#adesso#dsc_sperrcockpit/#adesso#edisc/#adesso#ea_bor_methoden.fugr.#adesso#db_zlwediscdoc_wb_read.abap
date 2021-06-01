FUNCTION /ADESSO/DB_ZLWEDISCDOC_WB_READ.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(X_WECHSELBELEG) TYPE  EIDESWTMSGDATA-SWITCHNUM
*"  EXPORTING
*"     REFERENCE(Y_DISCNO) TYPE  EDISCDOC-DISCNO
*"     REFERENCE(Y_ZLWEDISCDOC_WB) TYPE  /ADESSO/SPT_WBSB
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------
**"----------------------------------------------------------------------
**"*"Lokale Schnittstelle:
**"  IMPORTING
**"     REFERENCE(X_DISCNO) TYPE  EDISCDOC-DISCNO
**"     REFERENCE(X_DISCACT) TYPE  EDISCACT-DISCACT OPTIONAL
**"     REFERENCE(X_CREATE_EVENT) TYPE  KENNZX OPTIONAL
**"  EXPORTING
**"     REFERENCE(Y_ERROR) TYPE  REGEN-KENNZX
**"     REFERENCE(Y_ZLWEDISCDOC_WB) TYPE  /ADESSO/SPT_WBSB
**"----------------------------------------------------------------------
*  DATA: yt_zlwediscdoc_wb TYPE TABLE OF /ADESSO/SPT_WBSB,
*        wa_eideswtdoc TYPE eideswtdoc.
*
** je nach Aufruf letzten (= aktuellsten) oder direkten Eintrag zu Sperraktion lesen
*  IF x_discact IS INITIAL.
*    SELECT * FROM /ADESSO/SPT_WBSB
*      INTO y_zlwediscdoc_wb
*      WHERE discno  EQ x_discno
*      ORDER BY erdat
*               erzeit
*      DESCENDING.
*      EXIT.
*    ENDSELECT.
*  ELSE.
*    SELECT * FROM /ADESSO/SPT_WBSB
*      INTO y_zlwediscdoc_wb
*       WHERE discno  EQ x_discno
*         AND discact EQ x_discact
*      ORDER BY erdat
*               erzeit
*      DESCENDING.
*      EXIT.
*    ENDSELECT.
*  ENDIF.  "   IF x_discact IS INITIAL.
*  IF NOT x_create_event IS INITIAL.
** sollte es sich bei der letzten Aktion um einen Storno handeln, muss überprüft werden, ob es noch weitere
** Stornoaktionen gibt, deren Wechselbeleg noch nicht beantwortet ist
*    DATA: wa_ediscact TYPE ediscact.
*    SELECT SINGLE * FROM ediscact INTO wa_ediscact
*      WHERE discno  EQ y_zlwediscdoc_wb-discno
*      AND   discact EQ y_zlwediscdoc_wb-discact.
*    IF NOT wa_ediscact-disccanceld IS INITIAL.   " letzte Aktion = Storno
*      SELECT * FROM ediscact INTO wa_ediscact " bei allen stornierten Aktionen prüfen, ob der jeweilige WB beantwortet ist
*        WHERE discno EQ x_discno
*        AND   disccanceld NE space.
** WB-Nummer ermitteln
*        SELECT SINGLE * FROM /ADESSO/SPT_WBSB
*      INTO y_zlwediscdoc_wb
*       WHERE discno  EQ wa_ediscact-discno
*         AND discact EQ wa_ediscact-discact.
*        SELECT SINGLE * FROM eideswtdoc
*          INTO wa_eideswtdoc
*          WHERE switchnum EQ y_zlwediscdoc_wb-wechselbeleg
*          AND   status EQ '03'.  " Aktiv
*        APPEND y_zlwediscdoc_wb TO yt_zlwediscdoc_wb.
*      ENDSELECT.
*    ENDIF.
*
** für jeden gefundenen Wechselbelg EVENT auslösen
*    LOOP AT yt_zlwediscdoc_wb INTO y_zlwediscdoc_wb.
** Ereignis ISUSWITCHD.ZCANCELLED auslösen
*      DATA: i_sweinstcou TYPE sweinstcou.
*
*      MOVE 'ISUSWITCHD' TO i_sweinstcou-objtype.
*      MOVE 'ZCANCELLED' TO i_sweinstcou-event.
*      MOVE y_zlwediscdoc_wb-wechselbeleg TO i_sweinstcou-objkey.
*
*      CALL FUNCTION 'SWE_EVENT_CREATE'
*        EXPORTING
*          objtype           = i_sweinstcou-objtype
*          objkey            = i_sweinstcou-objkey
*          event             = i_sweinstcou-event
*        EXCEPTIONS
*          objtype_not_found = 1
*          OTHERS            = 2.
*      IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*      ELSE.
*        COMMIT WORK.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.     "IF NOT x_create_event IS INITIAL.



  SELECT SINGLE * FROM /ADESSO/SPT_WBSB INTO y_zlwediscdoc_wb
        WHERE wechselbeleg EQ x_wechselbeleg.
  IF sy-subrc NE 0.
    RAISE not_found.
  ENDIF.
  y_discno = y_zlwediscdoc_wb-discno.



ENDFUNCTION.
