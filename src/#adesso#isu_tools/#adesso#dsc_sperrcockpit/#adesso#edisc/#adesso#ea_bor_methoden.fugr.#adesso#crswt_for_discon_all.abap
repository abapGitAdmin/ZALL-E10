FUNCTION /ADESSO/CRSWT_FOR_DISCON_ALL.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(X_COMMIT) TYPE  REGEN-KENNZX DEFAULT 'X'
*"     REFERENCE(X_DISCNO) TYPE  EDISCDOC-DISCNO
*"     REFERENCE(X_DISCACT) TYPE  EDISCACT-DISCACT
*"     REFERENCE(X_ORDSTATE) TYPE  EDISCACTS-ORDSTATE
*"     REFERENCE(X_TRANSREASON) TYPE  EIDESWTMSGDATA-TRANSREASON
*"     REFERENCE(X_CATEGORY) TYPE  EIDESWTMSGDATA-CATEGORY
*"  EXPORTING
*"     REFERENCE(Y_BAPIRETURN) TYPE  BAPIRETURN1
*"     REFERENCE(Y_ERROR) TYPE  REGEN-KENNZX
*"     REFERENCE(Y_SWITCHNUM) TYPE  EIDESWTDOC-SWITCHNUM
*"     REFERENCE(Y_DISCACTTYP) TYPE  EDISCACT-DISCACTTYP
*"     REFERENCE(Y_DISCACT) TYPE  EDISCACT-DISCACT
*"     REFERENCE(Y_ACTDATE) TYPE  EDISCACT-ACTDATE
*"  EXCEPTIONS
*"      ZGPKE_551
*"      ZGPKE_552
*"      ZGPKE_553
*"      ZGPKE_554
*"      ZGPKE_555
*"      ZGPKE_556
*"      ZGPKE_557
*"      ZGPKE_558
*"      ZGPKE_559
*"      ZGPKE_561
*"----------------------------------------------------------------------

  TYPE-POOLS isu05.
  TABLES: ediscdoc.

* Arbeitsfelder abhängige Sperrbelege zu Sperrobjekten
  DATA: y_obj        TYPE isu05_discdoc_internal,
        idvalobj     TYPE isu_ediscdvalobj OCCURS 5 WITH HEADER LINE,
        iinv_discdoc TYPE isu_i_inv_discdoc OCCURS 5 WITH HEADER LINE,
        wa_euitrans  TYPE euitrans,
        wa_ediscpos  TYPE ediscpos,
        wa_ediscobj  TYPE ediscobj,
        wa_ediscobjh TYPE ediscobjh,
        wa_eastl     TYPE eastl,
        i_error      TYPE regen-kennzx,
        wa_zlwediscdoc_wb TYPE /ADESSO/SPT_WBSB,
        i_bapireturn TYPE  bapireturn1,
        i_commenttxt TYPE eideswtmsgdataco-commenttxt,
        x_moveindat  TYPE dats,
        x_moveoutdat TYPE dats,
        wa_ediscact TYPE ediscact.

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

* Daten zum Sperrbeleg lesen
  CALL FUNCTION '/ADESSO/LW_EDISCDOC_DATA'
    EXPORTING
     x_discno         = x_discno
     x_discact        = x_discact
   IMPORTING
*   Y_BAPIRETURN       =
*   Y_ERROR            =
     y_obj             = y_obj
     y_ediscact        = wa_ediscact
     y_commenttxt      = i_commenttxt
      EXCEPTIONS
        zgpke_551            = 1
        zgpke_552            = 2
        OTHERS               = 3.
  CASE sy-subrc.
    WHEN 0.
* keine Aktion
      y_discact = wa_ediscact-discact.
      y_discacttyp = wa_ediscact-discacttyp.
      y_actdate = wa_ediscact-actdate.
    WHEN 1.
      set_message gc_fehler gc_nakl '551' space space space space.
      y_error = 'X'.
      RAISE zgpke_551.
    WHEN OTHERS.
      set_message gc_fehler gc_nakl '552' space space space space.
      y_error = 'X'.
      RAISE zgpke_552.
  ENDCASE.

** Wechselbelege nur anlegen, wenn pro Aktion ein Gerät vorhanden ist
  DATA: i_sum TYPE n.
  CLEAR i_sum.
  LOOP AT y_obj-ediscpos INTO wa_ediscpos
              WHERE discno EQ x_discno
                          AND discact EQ x_discact.
    ADD 1 TO i_sum.
  ENDLOOP.

  IF i_sum > 1.
    set_message gc_fehler gc_nakl '561' space space space space.
    y_error = 'X'.
    RAISE zgpke_561.
  ENDIF.


* alle entsprechende Sperrobjekte verarbeiten
  LOOP AT y_obj-ediscpos
            INTO wa_ediscpos
    WHERE discact EQ y_discact.

    DATA: i_anlage TYPE anlage.
    CLEAR i_anlage.
* Sperrobjekt identifizieren
    READ TABLE y_obj-ediscobj
          WITH KEY discobj = wa_ediscpos-discobj
          INTO wa_ediscobj.
    IF sy-subrc NE 0.
      set_message gc_fehler gc_nakl '554' space space space space.
      y_error = 'X'.
      RAISE zgpke_554.
    ELSE.
      i_anlage = wa_ediscobj-anlage.
    ENDIF.
* zugehörige Anlage lesen
    IF i_anlage IS INITIAL.
      LOOP AT y_obj-denv-ieastl INTO wa_eastl
              WHERE logiknr = wa_ediscobj-logiknr.
        i_anlage = wa_eastl-anlage.
* Prüfen, ob es sich bei der gefunden Anlage nicht um eine Abwasser-Anlage handelt (= hat keinen ext. Zählpunkt)
        DATA: wa_v_eanl TYPE v_eanl.
        CALL FUNCTION 'ISU_DB_EANL_SELECT'
          EXPORTING
            x_anlage = i_anlage
          IMPORTING
            y_v_eanl = wa_v_eanl
          EXCEPTIONS
            OTHERS   = 1.
        IF sy-subrc <> 0.
          set_message gc_fehler gc_nakl '557' space space space space.
          y_error = 'X'.
          RAISE zgpke_557.
        ENDIF.
        IF wa_v_eanl-sparte NE '04' .
          EXIT.  " Loop verlassen (= Anlage ist keine Wasseranlage)
        ELSE.
          CLEAR i_anlage.       " (= Anlage ist Wasseranlage)
        ENDIF.
      ENDLOOP.
      IF sy-subrc <> 0.
* bei Neueinzug hat das Bezugsobjekt des Sperrbelegs nicht mehr die Anlage "im Bauch", daher Nachlesen
* über logische Gerätenummer
        DATA: lv_eastl TYPE eastl.
        CLEAR lv_eastl.
        CALL FUNCTION 'ISU_DB_EASTL_SELECT'
          EXPORTING
            x_logiknr     = wa_ediscobj-logiknr
            x_ab          = sy-datum
            x_bis         = sy-datum
          IMPORTING
            y_eastl       = lv_eastl
          EXCEPTIONS
            not_found     = 1
            system_error  = 2
            not_qualified = 3
            OTHERS        = 4.
        IF sy-subrc EQ 0.
          i_anlage = lv_eastl-anlage.
        ENDIF.
      ENDIF.
    ENDIF.

    IF i_anlage IS INITIAL.
      set_message gc_fehler gc_nakl '557' space space space space.
      y_error = 'X'.
      RAISE zgpke_557.
    ENDIF.

    SELECT SINGLE * INTO CORRESPONDING FIELDS OF wa_euitrans
             FROM euitrans AS a
             INNER JOIN euiinstln AS b ON a~int_ui = b~int_ui
             WHERE b~dateto >= sy-datum AND b~datefrom <= sy-datum
             AND   b~anlage = i_anlage.
    IF sy-subrc NE 0.
      set_message gc_fehler gc_nakl '555' space space space space.
      y_error = 'X'.
      RAISE zgpke_555.
    ENDIF.

    IF x_category EQ 'E01'.
* Bei Entsperren ( = E01) Einzugsdatum füllen
      x_moveindat = y_actdate.
      CLEAR x_moveoutdat.
    ELSE.
* Bei Sperren ( = E02) Auszugsdatum füllen
      x_moveoutdat = y_actdate.
      CLEAR x_moveindat.
    ENDIF.

    CALL FUNCTION '/ADESSO/CRSWT_FOR_DISCON'
      EXPORTING
        x_int_ui          = wa_euitrans-int_ui
        x_anlage          = wa_ediscobj-anlage
        x_ext_ui          = wa_euitrans-ext_ui
        x_moveoutdat      = x_moveoutdat
        x_moveindat       = x_moveindat
        x_commit          = ''
        x_reason          = '2'
        x_transreason     = x_transreason
        x_category        = x_category
        x_commenttxt      = i_commenttxt
        x_kennzx_ediscdoc = 'X'
      IMPORTING
        y_error           = i_error
        bapireturn        = i_bapireturn
        y_switchnum       = y_switchnum.
    IF NOT i_error IS INITIAL
      OR y_switchnum IS INITIAL.   " Abfrage trotz Fehlerbehandlung notwendig/sinnvoll
      set_message gc_fehler gc_nakl '559' space space space space.
      y_error = 'X'.
      RAISE zgpke_559.
*      PERFORM message USING i_bapireturn-number
*              CHANGING y_text
*                       y_error
*                       y_msgno.
      i_error = 'X'.
    ELSE.
      DATA: i_gpart TYPE gpart_kk,
            i_vkont TYPE vkont_kk,
            i_vertrag TYPE vertrag.

      CALL FUNCTION '/ADESSO/EA_POD_DATA'
        EXPORTING
          i_int_ui   = wa_euitrans-int_ui
          i_keydatum = sy-datum
          i_ext_ui   = wa_euitrans-ext_ui
        IMPORTING
          e_gpart    = i_gpart
          e_vertrag  = i_vertrag
          e_vkonto   = i_vkont.
      IF i_vkont IS INITIAL.   " Vertragskonto notwendig für mgl. Gebührbuchung
        i_error = 'X'.
        set_message gc_fehler gc_nakl '556' space space space space.
        RAISE zgpke_556.
      ENDIF.


* nur neue Einträge aufnehmen
      SELECT SINGLE * FROM /ADESSO/SPT_WBSB INTO wa_zlwediscdoc_wb
            WHERE discno EQ x_discno
              AND discact EQ y_discact.
      IF sy-subrc NE 0.
        CLEAR wa_zlwediscdoc_wb.
        wa_zlwediscdoc_wb-discno = x_discno.
        wa_zlwediscdoc_wb-discact = y_discact.
        wa_zlwediscdoc_wb-gpart = i_gpart.
        wa_zlwediscdoc_wb-vertrag = i_vertrag.
        wa_zlwediscdoc_wb-vkont = i_vkont.
        wa_zlwediscdoc_wb-wechselbeleg = y_switchnum.
        wa_zlwediscdoc_wb-msgty = i_bapireturn-type.
        wa_zlwediscdoc_wb-msgid = i_bapireturn-id.
        wa_zlwediscdoc_wb-msgno = i_bapireturn-number.
        wa_zlwediscdoc_wb-message = i_bapireturn-message.
        wa_zlwediscdoc_wb-msg_v1 = i_bapireturn-message_v1.
        wa_zlwediscdoc_wb-msg_v2 = i_bapireturn-message_v2.
        wa_zlwediscdoc_wb-msg_v3 = i_bapireturn-message_v3.
        wa_zlwediscdoc_wb-msg_v4 = i_bapireturn-message_v4.
        wa_zlwediscdoc_wb-ernam = sy-uname.
        wa_zlwediscdoc_wb-erdat = sy-datum.
        wa_zlwediscdoc_wb-erzeit = sy-uzeit.

        INSERT /ADESSO/SPT_WBSB FROM wa_zlwediscdoc_wb.
        IF NOT sy-subrc EQ 0.
          i_error = 'X'.
          set_message gc_fehler gc_nakl '556' space space space space.
          RAISE zgpke_556.
        ENDIF.
      ELSE.
* (bei Prozess Ersatzversorgung wird ein Sperrbeleg auf Vertriebsseite angelegt;
* der Eintrag muss an dieser Stelle mit der "richtigen" Wechselbelegnummer aktualisiert werden
        IF wa_zlwediscdoc_wb-wechselbeleg NE y_switchnum.
          wa_zlwediscdoc_wb-wechselbeleg = y_switchnum.
          MODIFY /ADESSO/SPT_WBSB FROM wa_zlwediscdoc_wb.
          IF NOT sy-subrc EQ 0.
            i_error = 'X'.
            set_message gc_fehler gc_nakl '556' space space space space.
            RAISE zgpke_556.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
  IF sy-subrc NE 0.
    set_message gc_fehler gc_nakl '553' space space space space.
    y_error = 'X'.
    RAISE zgpke_553.
  ENDIF.


  IF NOT x_commit IS INITIAL.
    IF i_error IS INITIAL.
      COMMIT WORK.
      CLEAR y_error.
      set_message  gc_erfolg gc_nakl '560' space space space space.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ENDIF.

ENDFUNCTION.
