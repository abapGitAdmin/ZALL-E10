FUNCTION /ADESSO/LW_EDISCDOC.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(X_COMMIT) TYPE  REGEN-KENNZX
*"     VALUE(X_OKCODE) TYPE  REGEN-OKCODE DEFAULT 'DARK_CREATE_DCOR'
*"     VALUE(X_REFOBJTYPE) TYPE  EDISCDOC-REFOBJTYPE OPTIONAL
*"     VALUE(X_ACTDAT) TYPE  EDISCACT-ACTDATE
*"     VALUE(X_ORDSTAT) TYPE  EDISCACTS-ORDSTATE OPTIONAL
*"     VALUE(X_ORDACT) TYPE  EDISCACT-DISCACT OPTIONAL
*"     VALUE(X_SWITCHNUM) TYPE  EIDESWTDOC-SWITCHNUM OPTIONAL
*"     VALUE(X_CONTACT) TYPE  REGEN-KENNZX OPTIONAL
*"     VALUE(X_CCLASS) TYPE  BCONT-CCLASS OPTIONAL
*"     VALUE(X_ACTIVITY) TYPE  BCONT-ACTIVITY OPTIONAL
*"     VALUE(X_GEBUEHR) TYPE  REGEN-KENNZX OPTIONAL
*"     VALUE(X_BETRW) TYPE  DFKKOP-BETRW OPTIONAL
*"     VALUE(X_BUKRS) TYPE  DFKKOP-BUKRS OPTIONAL
*"     VALUE(X_DISCNO_REF) TYPE  EDISCDOC-DISCNO OPTIONAL
*"     VALUE(X_HVORG) TYPE  DFKKOP-HVORG OPTIONAL
*"     VALUE(X_TVORG) TYPE  DFKKOP-TVORG OPTIONAL
*"     VALUE(X_DISCREASON) TYPE  EDISCDOC-DISCREASON OPTIONAL
*"  EXPORTING
*"     REFERENCE(Y_BAPIRETURN) TYPE  BAPIRETURN1
*"     REFERENCE(Y_ERROR) TYPE  REGEN-KENNZX
*"     REFERENCE(Y_DISCACTTYP) TYPE  EDISCACT-DISCACTTYP
*"     REFERENCE(Y_OPBEL) TYPE  FKKOP-OPBEL
*"  CHANGING
*"     REFERENCE(XY_ANLAGE) TYPE  EANL-ANLAGE OPTIONAL
*"     REFERENCE(XY_DISCNO) TYPE  EDISCDOC-DISCNO OPTIONAL
*"     REFERENCE(XY_EXT_UI) TYPE  EUITRANS-EXT_UI OPTIONAL
*"     REFERENCE(XY_LINES) TYPE  /ADESSO/SPT_EDISCCOMMENT OPTIONAL
*"  EXCEPTIONS
*"      ZGPKE_501
*"      ZGPKE_502
*"      ZGPKE_503
*"      ZGPKE_504
*"      ZGPKE_505
*"      ZGPKE_506
*"      ZGPKE_507
*"      ZGPKE_551
*"      ZGPKE_552
*"      ZGPKE_508
*"      ZGPKE_509
*"      ZGPKE_510
*"      ZGPKE_511
*"----------------------------------------------------------------------


  TYPE-POOLS isu05.

  DATA: h_auto            TYPE isu05_discdoc_auto,
        it_installation   LIKE STANDARD TABLE OF bapiisupodinstln,
        it_return         LIKE STANDARD TABLE OF bapiret2,
        x_refobjkey       TYPE ediscdoc-refobjkey,
        wa_ediscdoc       TYPE ediscdoc,
        wa_discpos        TYPE isu05_discdoc_discpos,
        wa_ediscact       TYPE ediscact,
        wa_ediscobj       TYPE ediscobj,
        wa_zlwediscdoc_wb TYPE /ADESSO/SPT_WBSB,
        y_obj             TYPE isu05_discdoc_internal,

        wa_rcpos          TYPE isu05_discdoc_rcpos,
        i_kennzx          TYPE regen-kennzx,
        i_partner         TYPE bu_partner,
        i_vkonto          TYPE vkont_kk,   " Vertragskonto, zu welchem die Sperre angelegt wurde
        i_vertrag         TYPE vertrag,
        BEGIN OF i_sperr,      " Objekte, zu welchem die Sperre angelegt wurde
          gpart   TYPE bu_partner,
          vkont   TYPE vkont_kk,
          vertrag TYPE vertrag,
        END OF i_sperr,
        i_kz_abschluss TYPE kennzx.

  DATA: wa_eastl        TYPE eastl,
        it_ediscpos     TYPE STANDARD TABLE OF ediscpos WITH HEADER LINE,
        it_ediscobj     TYPE STANDARD TABLE OF ediscobj WITH HEADER LINE,
        it_ediscobj_old TYPE STANDARD TABLE OF ediscobj WITH HEADER LINE,
        it_ediscobjh    TYPE STANDARD TABLE OF ediscobjh WITH HEADER LINE,
        i_tabix         TYPE sy-tabix.
  DATA: txt_header     TYPE thead,
        l_lines        TYPE tline OCCURS 0,
        l_lines_single LIKE LINE OF l_lines,
        xy_lines_len   TYPE i,
        lv_lines_len   TYPE i.
  DATA: lv_strlen TYPE i.
  DATA: ls_lines LIKE LINE OF l_lines.



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

  CLEAR i_kennzx.

  CALL FUNCTION '/ADESSO/EA_POD_DATA'
    EXPORTING
      i_ext_ui   = xy_ext_ui
      i_keydatum = x_actdat
    IMPORTING
      e_anlage   = xy_anlage
      e_discno   = xy_discno
      e_gpart    = i_partner
      e_vkonto   = i_vkonto
      e_vertrag  = i_vertrag.

*Wenn bereits Sperrbelegnummer mitgegeben wurde, diese nicht neu bestimmen
*--> Falls zwei Sperrbelege zum gleichen Zählpunkt angelegt wurden.
*  IF x_discno_ref IS NOT INITIAL.
*    xy_discno = x_discno_ref.
*  ENDIF.


  IF xy_anlage IS INITIAL.
    ROLLBACK WORK.
    set_message gc_fehler gc_nakl '501' space space space space.
    y_error = 'X'.
    RAISE zgpke_501.
  ENDIF.

* Geschäftspartner, Vertragskonto und Vertrag aus ZLWEDISCDOC lesen
  SELECT SINGLE * FROM /ADESSO/SPT_WBSB INTO wa_zlwediscdoc_wb
          WHERE discno EQ xy_discno
            AND discact EQ x_ordact.
  IF sy-subrc EQ 0.
* Eintrag gefunden -> Vertragskonto für Gebührenbuchung
    i_sperr-gpart = wa_zlwediscdoc_wb-gpart.
    i_sperr-vkont = wa_zlwediscdoc_wb-vkont.
    i_sperr-vertrag = wa_zlwediscdoc_wb-vertrag.
  ENDIF.

  IF xy_discno IS INITIAL.
    IF x_okcode EQ 'DARK_CREATE_DCOR' OR x_okcode EQ 'DARK_CREATE'.
* Objektbezug festlegen
      x_refobjtype = 'INSTLN'.
      x_refobjkey = xy_anlage.

      CALL FUNCTION 'ISU_S_DISCDOC_CREATE'
        EXPORTING
          x_discreason   = '00'            " hier muss Sperrgrund 00 = unbekannt sein, da sonst Probleme bei DUNN (kein Sperrgrund da keine Sperrposten)
          x_refobjtype   = x_refobjtype
          x_refobjkey    = x_refobjkey
          x_upd_online   = 'X'    "hier muss ein Update erfolgen, da sonst bei der Änderung kein Sperrbleg ermittelt werden kann
          x_no_dialog    = 'X'
        IMPORTING
          y_new_ediscdoc = wa_ediscdoc
        EXCEPTIONS
          OTHERS         = 1.
      IF sy-subrc EQ 0.
        xy_discno = wa_ediscdoc-discno.
        txt_header-tdobject = 'EDCN'.
        txt_header-tdname = xy_discno.
        txt_header-tdid ='ISU'.
        txt_header-tdspras = sy-langu.


        DESCRIBE FIELD xy_lines LENGTH xy_lines_len IN CHARACTER MODE.
        DESCRIBE FIELD l_lines_single LENGTH lv_lines_len IN CHARACTER MODE.

        lv_strlen = xy_lines_len - lv_lines_len.

        ls_lines-tdline = xy_lines+0(lv_lines_len).
        APPEND ls_lines TO l_lines.

        lv_lines_len = lv_lines_len - 2.

        ls_lines-tdline = xy_lines+lv_lines_len(lv_strlen).
        APPEND ls_lines TO l_lines.

        CALL FUNCTION 'SAVE_TEXT'
          EXPORTING
            client          = sy-mandt
            header          = txt_header
            insert          = 'X'
            savemode_direct = 'X'
*           OWNER_SPECIFIED = ' '
*           LOCAL_CAT       = ' '
*         IMPORTING
*           FUNCTION        =
*           NEWHEADER       =
          TABLES
            lines           = l_lines
          EXCEPTIONS
            id              = 1
            language        = 2
            name            = 3
            object          = 4
            OTHERS          = 5.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.
      ELSE.
        CLEAR xy_discno.
        set_message gc_fehler gc_nakl '502' space space space space.
        ROLLBACK WORK.
        y_error = 'X'.
        RAISE zgpke_502.
      ENDIF.
    ENDIF.
  ENDIF.

  CASE x_okcode.
    WHEN 'DARK_CREATE_DCOR'.
* DARK_CREATE_DCOR = Sperrbeleg und Sperrauftrag erstellen, daher ab hier als OK_CODE = DARKDCOR weiter
      x_okcode = 'DARKDCOR'.
      x_ordact = '0001'.   " bei Neuanlage mit Aktion 0001 weiter
    WHEN 'DARK_CREATE'.
* nach erfolgtem Anlegen des Sperrbelegs, Verarbeitung beenden
      set_message gc_erfolg gc_nakl '508' space space space space.
      CLEAR y_error.
      COMMIT WORK.
      RAISE zgpke_508.
    WHEN 'DARKDOCOR'.
      x_ordact = '0001'.   " bei Neuanlage mit Aktion 0001 weiter
  ENDCASE.

  IF x_okcode NE 'DARKDCOR'.   "Bei "Anlegen" sind noch keine Aktionen hinterlegt
* aktuellste Aktion lesen
    CALL FUNCTION '/ADESSO/LW_EDISCDOC_DATA'
      EXPORTING
        x_discno   = xy_discno
*       X_DISCACT  =
*       X_ORDSTATE =
      IMPORTING
*       Y_BAPIRETURN =
*       Y_ERROR    =
        y_obj      = y_obj
        y_ediscdoc = wa_ediscdoc
        y_ediscact = wa_ediscact
      EXCEPTIONS
        zgpke_551  = 1
        zgpke_552  = 2
        OTHERS     = 3.
    CASE sy-subrc.
      WHEN 0.
        IF x_ordact IS INITIAL.
          x_ordact = wa_ediscact-orderact.
        ENDIF.
        DATA: wa_ediscpos TYPE ediscpos.
        READ TABLE y_obj-db_ediscpos INTO wa_ediscpos WITH KEY discact = x_ordact.
        xy_discno = wa_ediscdoc-discno.
*        txt_header-tdobject = 'EDCN'.
*        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*          EXPORTING
*            input  = xy_discno
*          IMPORTING
*            output = txt_header-tdname.
**        txt_header-tdname = xy_discno.
*        txt_header-tdid ='ISU'.
*        txt_header-tdspras = sy-langu.
*        LOOP AT xy_lines INTO lw_lines.
*        APPEND xy_lines TO l_lines.
        DESCRIBE FIELD xy_lines LENGTH xy_lines_len IN CHARACTER MODE.
        DESCRIBE FIELD l_lines_single LENGTH lv_lines_len IN CHARACTER MODE.

        lv_strlen = xy_lines_len - lv_lines_len.

        ls_lines-tdline = xy_lines+0(lv_lines_len).
        APPEND ls_lines TO l_lines.

        lv_lines_len = lv_lines_len - 2.

        ls_lines-tdline = xy_lines+lv_lines_len(lv_strlen).
        APPEND ls_lines TO l_lines.
*          APPEND lw_lines TO l_lines.
*        ENDLOOP.
        txt_header-tdobject = 'EDCN'.
        txt_header-tdname = xy_discno.
        txt_header-tdid ='ISU'.
        txt_header-tdspras = sy-langu.

        CALL FUNCTION 'SAVE_TEXT'
          EXPORTING
            client          = sy-mandt
            header          = txt_header
*           INSERT          = ' '
            savemode_direct = 'X'
*           OWNER_SPECIFIED = ' '
*           LOCAL_CAT       = ' '
*         IMPORTING
*           FUNCTION        =
*           NEWHEADER       =
          TABLES
            lines           = l_lines
*         EXCEPTIONS
*           ID              = 1
*           LANGUAGE        = 2
*           NAME            = 3
*           OBJECT          = 4
*           OTHERS          = 5
          .
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.

      WHEN 1.
        set_message gc_fehler gc_nakl '551' space space space space.
        y_error = 'X'.
        RAISE zgpke_551.
      WHEN OTHERS.
        set_message gc_fehler gc_nakl '552' space space space space.
        y_error = 'X'.
        RAISE zgpke_552.
    ENDCASE.
  ENDIF.

* Sperrstatus zwischenspeichern
*  SELECT * FROM ediscobj INTO TABLE it_ediscobj_old
*                 WHERE discno EQ xy_discno.

* Sperraktion durchführen
  CLEAR h_auto.
  h_auto-contr-use-okcode = 'X'.
  h_auto-contr-okcode = x_okcode.
  h_auto-contr-use-interface = 'X'.

  CASE x_okcode.
    WHEN 'DARKDCOR'. " Sperruftrag erstellen
      h_auto-interface-darkdcor-x_actdate   = x_actdat.
*      h_auto-interface-darkdcor-x_ordercode =
*      h_auto-interface-darkdcor-x_orderwerk =
*      h_auto-interface-darkdcor-y_new_discact =
*      h_auto-interface-darkdcor-y_new_ordernum =
    WHEN 'DARKDCED'. " Rückmeldestatus setzen
      h_auto-interface-darkdced-x_ordact   = x_ordact.
      h_auto-interface-darkdced-x_ordstat  = x_ordstat.
      h_auto-interface-darkdced-x_discdate = x_actdat.
*      h_auto-interface-darkdced-x_neworder =
*      h_auto-interface-darkdced-x_disctime  =
*      h_auto-interface-darkdced-x_bbpchanged =
*      h_auto-interface-darkdced-y_new_discact =
* Sperrobjekte nur bei Rückmeldestatus '10' mitgeben
      IF x_ordstat EQ '10'.
        wa_discpos-x_discobj     = wa_ediscpos-discobj.
        wa_discpos-x_discposdate = x_actdat.
*        wa_discpos-x_discpostime = '070000'.
        wa_discpos-x_discpostime = sy-uzeit.
*        wa_discpos-x_disctype    = '0001'.     "Gerät verplompt
        APPEND wa_discpos TO h_auto-interface-darkdced-xt_discpos.
      ENDIF.
    WHEN 'DARKRCOR'. " Wiederinbetriebnahmeauftrag anlegen
      h_auto-interface-darkrcor-x_actdate = x_actdat.
      h_auto-interface-darkrcor-x_ordercode = 'RC00'.
      h_auto-interface-darkrcor-x_orderwerk = '0001'.
      i_kennzx = 'X'.
*      h_auto-interface-darkrcor-y_new_discact =
*      h_auto-interface-darkrcor-y_new_ordernum =
*      h_auto-interface-darkrcor-y_permits_count =
*      h_auto-interface-darkrcor-y_permits_tab =
*      h_auto-interface-darkrcor-y_connobj =
*      h_auto-interface-darkrcor-y_bpartner =
    WHEN 'DARKCOMPL'. "Abschluss
    WHEN 'DARKRELE'.  "Freigabe eines Sperrbeleges
    WHEN 'DARKRCED'.  "Anlegen einer Wiederinbetriebnahme
      h_auto-interface-darkrced-x_ordact = x_ordact.
      h_auto-interface-darkrced-x_ordstat = x_ordstat.
      h_auto-interface-darkrced-x_rcdate = x_actdat.
      h_auto-interface-darkrced-x_rctime = sy-uzeit.
*      h_auto-interface-darkrced-x_neworder =
*      h_auto-interface-darkrced-y_new_discact =
      wa_rcpos-x_rcobj     = wa_ediscpos-discobj.
      wa_rcpos-x_rcposdate = x_actdat.
*      wa_rcpos-x_rcpostime = '090000'.
      wa_rcpos-x_rcpostime = sy-uzeit.
      APPEND wa_rcpos TO h_auto-interface-darkrced-xt_rcpos.
    WHEN 'DARKREVERSE'. "Stornieren von Sperraktionen
    WHEN 'DARKDCSC'. " Status von 99 auf 30 ändern
    WHEN OTHERS.
  ENDCASE.

  DATA: i_subrc TYPE sy-subrc,
        i_msgid TYPE sy-msgid,
        i_msgno TYPE sy-msgno.
* Änderung durchführen
  CALL FUNCTION 'ISU_S_DISCDOC_CHANGE'
    EXPORTING
      x_discno           = xy_discno
      x_upd_online       = 'X'
      x_no_dialog        = 'X'
      x_auto             = h_auto
      x_set_commit_work  = i_kennzx
    EXCEPTIONS
      not_found          = 1
      foreign_lock       = 2
      not_authorized     = 3
      input_error        = 4
      general_fault      = 5
      object_inv_discdoc = 6
      OTHERS             = 7.
  i_subrc = sy-subrc.
  i_msgid = sy-msgid.
  i_msgno = sy-msgno.

  IF sy-subrc <> 0.
* Bei Fehler, Sperrbeleg wieder abschließen
*    CLEAR h_auto.
*    h_auto-contr-use-okcode = 'X'.
*    h_auto-contr-okcode = 'DARKCOMPL'.
*    h_auto-contr-use-interface = 'X'.
*    CALL FUNCTION 'ISU_S_DISCDOC_CHANGE'
*      EXPORTING
*        x_discno          = xy_discno
*        x_upd_online      = 'X'
*        x_no_dialog       = 'X'
*        x_auto            = h_auto
*        x_set_commit_work = ''
*      EXCEPTIONS
*        OTHERS            = 1.
* CLEAR xy_discno.
    ROLLBACK WORK.
    CASE i_subrc.
      WHEN '2'.
        set_message gc_fehler gc_nakl '507' space space space space.
        y_error = 'X'.
        RAISE zgpke_507.
      WHEN '5'.
        IF i_msgid EQ 'EH' AND i_msgno EQ '421'.
* es existiert schon ein Sperr-, bzw. WIB-Auftrag
          set_message gc_fehler gc_nakl '510' space space space space.
          y_error = 'X'.
          RAISE zgpke_510.
        ELSEIF i_msgid EQ 'EH' AND i_msgno EQ '426'.
* Keine sperrbaren Objekte im Datenumfeld des Bezugsobjekts
          set_message gc_fehler gc_nakl '503' space space space space.
          y_error = 'X'.
          RAISE zgpke_503.
        ELSE.
          set_message gc_fehler gc_nakl '507' space space space space.
          y_error = 'X'.
          RAISE zgpke_507.
        ENDIF.
      WHEN OTHERS.
        set_message gc_fehler gc_nakl '503' space space space space.
        y_error = 'X'.
        RAISE zgpke_503.
    ENDCASE.
  ENDIF.

  CLEAR i_kz_abschluss.
* Sperrbeleg abschließen,
**  - nach erfolgreicher Wiederinbetriebnahme => wird durch Standard-Customizing gesteuert
*  - nach erfolgreichem Storno eines Sperrauftrags im Vertriebsmandant "dunkles Nachziehen im Netzmandant"
  IF x_okcode EQ 'DARKREVERSE' .
    i_kz_abschluss = 'X'.
  ENDIF.

* Sperrbeleg einlesen
  CALL FUNCTION 'ISU_O_DISCDOC_OPEN_INTERNAL'
    EXPORTING
      x_discno    = xy_discno
      x_wmode     = '1'
      x_no_dialog = 'X'
    IMPORTING
      y_obj       = y_obj
    EXCEPTIONS
      OTHERS      = 0.
* Sperrbeleg nicht gefunden
  IF sy-subrc NE 0.
    CLEAR xy_discno.
    ROLLBACK WORK.
    set_message gc_fehler gc_nakl '505' space space space space.
    y_error = 'X'.
    RAISE zgpke_505.
  ENDIF.


  LOOP AT y_obj-ediscobj INTO wa_ediscobj
    WHERE discstate NE '00'.
    CLEAR i_kz_abschluss.
  ENDLOOP.

  IF NOT i_kz_abschluss IS INITIAL.
    CLEAR h_auto.
    CLEAR i_kennzx.
    h_auto-contr-use-okcode = 'X'.
    h_auto-contr-okcode = 'DARKCOMPL'.
    h_auto-contr-use-interface = 'X'.
    CALL FUNCTION 'ISU_S_DISCDOC_CHANGE'
      EXPORTING
        x_discno          = xy_discno
        x_upd_online      = 'X'
        x_no_dialog       = 'X'
        x_auto            = h_auto
        x_set_commit_work = i_kennzx
      EXCEPTIONS
        OTHERS            = 1.
    IF sy-subrc <> 0.
      set_message gc_fehler gc_nakl '503' space space space space.
      y_error = 'X'.
      ROLLBACK WORK.
      RAISE zgpke_503.
    ENDIF.
  ENDIF.

* Bei Sperrauftrag und Wiederinbetriebenahme, Wechselbelegnummer in Tabelle fortschreiben
  IF x_okcode EQ 'DARKDCOR'
    OR x_okcode EQ 'DARKRCOR'.
    IF x_switchnum IS INITIAL.
      CLEAR xy_discno.
      ROLLBACK WORK.
      set_message gc_fehler gc_nakl '504' space space space space.
      y_error = 'X'.
      ROLLBACK WORK.
      RAISE zgpke_504.
    ENDIF.

* aktuellste Sperraktion = gerade durchgeführte Aktion
    SORT y_obj-ediscact BY discact DESCENDING.
    LOOP AT y_obj-ediscact INTO wa_ediscact.
      EXIT.
    ENDLOOP.

    CLEAR wa_zlwediscdoc_wb.
    wa_zlwediscdoc_wb-discno = xy_discno.
    wa_zlwediscdoc_wb-discact = wa_ediscact-discact.
    wa_zlwediscdoc_wb-wechselbeleg = x_switchnum.
    IF x_okcode EQ  'DARKDCOR' .  " Sperrauftragsauslösendes Vertragsonto abspeichern
      wa_zlwediscdoc_wb-gpart = i_partner.
      wa_zlwediscdoc_wb-vkont = i_vkonto.
      wa_zlwediscdoc_wb-vertrag = i_vertrag.
    ELSE.
      wa_zlwediscdoc_wb-gpart = i_sperr-gpart.
      wa_zlwediscdoc_wb-vkont = i_sperr-vkont.
      wa_zlwediscdoc_wb-vertrag = i_sperr-vertrag.
    ENDIF.
    wa_zlwediscdoc_wb-ext_ui = xy_ext_ui.
    wa_zlwediscdoc_wb-ernam = sy-uname.
    wa_zlwediscdoc_wb-erdat = sy-datum.
    wa_zlwediscdoc_wb-erzeit = sy-uzeit.
    wa_zlwediscdoc_wb-discno_ref = x_discno_ref.
    INSERT /ADESSO/SPT_WBSB FROM wa_zlwediscdoc_wb.
    IF NOT sy-subrc EQ 0.
      CLEAR xy_discno.
      ROLLBACK WORK.
      set_message gc_fehler gc_nakl '506' space space space space.
      y_error = 'X'.
      RAISE zgpke_506.
    ENDIF.
  ENDIF.

* Kontakt anlegen?
  IF NOT x_contact IS INITIAL AND NOT x_cclass IS INITIAL.
    PERFORM create_contact USING i_sperr-gpart    " Kontakt zum die Sperre auslösenden GP erfassen
*                                i_partner
                                 x_cclass
                                 x_activity.
  ENDIF.

* Gebühr buchen?
  DATA: i_gebuehr TYPE kennzx.
  i_gebuehr = x_gebuehr.

* Buchung der Gebühr
* i_gebuehr = 'X': nur wenn "Sperrung auslösendes Vertragskonto" gleich aktuellem Vertragskonto
* i_gebuehr = '': immer auf Vertragskonto, welches Sperrung ausgelöst hat
  IF i_sperr-vkont NE i_vkonto.
    CLEAR i_gebuehr.
  ENDIF.

* keine Buchung, wenn Gebühr = 0
  IF x_betrw EQ 0.
    CLEAR i_gebuehr.
  ENDIF.

  IF NOT i_gebuehr IS INITIAL.
* Gebührenbuchung
    x_commit = 'X'.
    PERFORM gebuehr_buchen USING x_okcode
                                 x_betrw
                                 x_bukrs
                                 i_sperr-gpart
                                 i_sperr-vkont
                                 i_sperr-vertrag
                                 x_hvorg
                                 x_tvorg
                                 CHANGING y_opbel
                                          x_commit.
  ENDIF.

  IF x_commit IS INITIAL.
    set_message gc_fehler gc_nakl '511' space space space space.
    y_error = 'X'.
    RAISE zgpke_511.
  ELSE.
    COMMIT WORK.   " Änderungen bis hierher speichern (v.a. Gebührenbuchung)
  ENDIF.

* Commit, wenn bis hier angekommen
*  IF NOT x_commit IS INITIAL.
*    set_message gc_erfolg gc_nakl '508' space space space space.
*    CLEAR y_error.
*    COMMIT WORK.
*  ENDIF.

*  wa_ediscact-orderact = x_ordact + 1.

  IF NOT i_gebuehr IS INITIAL.
    CALL FUNCTION '/ADESSO/LW_EDISCDOC_DATA'
      EXPORTING
        x_discno   = xy_discno
*       x_discact  = wa_ediscact-orderact
      IMPORTING
*       Y_BAPIRETURN =
*       Y_ERROR    =
        y_obj      = y_obj
        y_ediscdoc = wa_ediscdoc
        y_ediscact = wa_ediscact
      EXCEPTIONS
        zgpke_551  = 1
        zgpke_552  = 2
        OTHERS     = 3.
    CASE sy-subrc.
      WHEN 0.
* keine Aktion
      WHEN 1.
        set_message gc_fehler gc_nakl '551' space space space space.
        y_error = 'X'.
        RAISE zgpke_551.
      WHEN OTHERS.
        set_message gc_fehler gc_nakl '552' space space space space.
        y_error = 'X'.
        RAISE zgpke_552.
    ENDCASE.

* Gebuchte Gebühr, bzw. Belegnummer in Sperrbeleg schreiben
    wa_ediscact-charge_opbel = y_opbel.
    UPDATE ediscact FROM wa_ediscact.
    COMMIT WORK.
  ENDIF.






* beim Anlegen eines Sperrauftrages nur eine Anlage pro Aktion zulassen (unbeteiligte Geräte aus Sperrbeleg entfernen)
*  IF x_okcode = 'DARKDCOR' OR x_okcode = 'DARKRCOR'.
*
** beteiligte logische Gerätenummer lesen
*    READ TABLE y_obj-denv-ieastl WITH KEY anlage = xy_anlage INTO wa_eastl.
*
*
*    SELECT * FROM ediscpos INTO TABLE it_ediscpos
*                      WHERE discno EQ xy_discno.
*
*    SELECT * FROM ediscobj INTO TABLE it_ediscobj
*                   WHERE discno EQ xy_discno.
*
*    SELECT * FROM ediscobjh INTO TABLE it_ediscobjh
*                      WHERE discno EQ xy_discno.
*

** Alle an letzer Sperraktion beteiligten "Gegenstände" ermitteln
*    LOOP AT it_ediscpos.
*      IF NOT it_ediscpos-discact EQ wa_ediscact-discact.
*        DELETE it_ediscpos.
*        DELETE it_ediscobjh WHERE discobj EQ it_ediscpos-discobj.
*        IF x_okcode EQ 'DARKDCOR'.   " Sperrobjekte nur bei 'Anlegen Sperrauftrag' bearbeiten
*          DELETE it_ediscobj WHERE discobj EQ it_ediscpos-discobj.
*        ENDIF.
*      ELSE.
*        READ TABLE it_ediscobj WITH KEY discobj = it_ediscpos-discobj.
*        i_tabix = sy-tabix.
** handelt es sich bei dem Sperrgegenstand um die die Aktion auslösende Anlage?
*        IF it_ediscobj-logiknr EQ wa_eastl-logiknr.
*          DELETE it_ediscpos.
*          DELETE it_ediscobjh WHERE discobj EQ it_ediscpos-discobj.
*          IF x_okcode EQ 'DARKDCOR'.   " Sperrobjekte nur bei 'Anlegen Sperrauftrag' bearbeiten
*            DELETE it_ediscobj WHERE discobj EQ it_ediscpos-discobj.
*          ENDIF.
*        ELSE.
** alten Stand vor der Änderung übernehmen
*          READ TABLE it_ediscobj_old WITH KEY discobj = it_ediscpos-discobj.
*          IF sy-subrc EQ 0 AND i_tabix NE 0.
*            MODIFY it_ediscobj FROM it_ediscobj_old INDEX i_tabix.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*    ENDLOOP.
*
** verbleibende Einträge aus entsprechenden DB-Tabellen löschen
*
*    LOOP AT it_ediscpos.
*      DELETE ediscpos FROM it_ediscpos.
*    ENDLOOP.
*
*    LOOP AT it_ediscobjh.
*      DELETE ediscobjh FROM it_ediscobjh.
*    ENDLOOP.
*
*    LOOP AT it_ediscobj.
*      CASE x_okcode.
*        WHEN 'DARKDCOR'.
*          DELETE ediscobj FROM it_ediscobj.
*        WHEN 'DARKRCOR'.
*          UPDATE ediscobj FROM it_ediscobj.
*      ENDCASE.
*    ENDLOOP.
*  ENDIF.


ENDFUNCTION.
