*----------------------------------------------------------------------*
***INCLUDE /ADESSO/INKASSO_MONITOR_F02.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  UCOM_SELL_HIER
*&---------------------------------------------------------------------*
FORM ucom_sell_hier USING ff_ucomm LIKE sy-ucomm
                          ff_gplocked LIKE gv_gplocked.

  DATA: ls_header TYPE /adesso/inkasso_header.
  DATA: ls_items  TYPE /adesso/inkasso_items.
  DATA: lt_sr     TYPE TABLE OF /adesso/inkasso_items.
  DATA: lf_nochange TYPE sy-tabix.
  DATA: lf_nochg_stat TYPE sy-tabix.
  DATA: lt_wo_mon TYPE TABLE OF /adesso/wo_mon.
  DATA: ls_wo_mon TYPE /adesso/wo_mon.
  DATA: lt_wo_mon_h TYPE TABLE OF /adesso/wo_mon_h.
  DATA: ls_wo_mon_h TYPE /adesso/wo_mon_h.
  DATA: ls_dfkkko TYPE dfkkko.
  DATA: ls_cust   TYPE /adesso/ink_cust.
  DATA: lf_wohkf  TYPE /adesso/wo_mon-wohkf.
  DATA: lf_abgrd  TYPE /adesso/wo_mon-abgrd.
  DATA: lf_woigd  TYPE /adesso/wo_mon-woigd.
  DATA: lf_wovks  TYPE /adesso/wo_mon-wovks.
  DATA: lf_wosta  TYPE /adesso/wo_mon-wosta.
  DATA: lf_orgbe  TYPE /adesso/wo_mon-orgbe.
  DATA: lf_iverm  TYPE /adesso/inkasso_text.
  DATA: lf_lockr  TYPE lockr_kk.
  DATA: lf_faedn  TYPE faedn_kk.
  DATA: lf_h_wosta(3).
  DATA: ls_nf_mahn TYPE /adesso/ink_nfhf.  "HV / TV Mahnung
  DATA: lf_exists     TYPE abap_bool.
  DATA: lf_nodocu     TYPE sy-tabix.


  READ TABLE gt_cust INTO gs_cust
       WITH KEY inkasso_option   = 'AUSBUCHUNG'
                inkasso_category = 'HERKUNFT'
                inkasso_field    = 'WOHKF'.

  IF sy-subrc = 0.
    lf_wohkf = gs_cust-inkasso_value.
  ENDIF.

  READ TABLE gt_cust INTO gs_cust
       WITH KEY inkasso_option   = 'VERKAUF'
                inkasso_category = 'MAHNSP'
                inkasso_field    = 'LOCKR'.

  IF sy-subrc = 0.
    lf_lockr = gs_cust-inkasso_value.
  ENDIF.

* pop-up to enter abgrd and wovks
  CALL SCREEN 9004
     STARTING AT 21 2.

  IF ok EQ 'CANC'.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-f12
        textline2 = TEXT-e25.
    EXIT.
  ELSE.
    lf_abgrd = /adesso/wo_mon-abgrd.
    lf_woigd = /adesso/wo_mon-woigd.
    lf_wovks = /adesso/wo_mon-wovks.
    lf_iverm = wa_out-freetext.
  ENDIF.
  CLEAR ok.

* Für Hierarchische Liste
  LOOP AT t_header INTO ls_header
       WHERE sel IS NOT INITIAL.

* VK für Bearbeitung gesperrt ?
    IF ls_header-locked IS NOT INITIAL.
      ff_gplocked = 'X'.
      CONTINUE.
    ENDIF.

    IF ls_header-satztyp NE 'A'.
      ADD 1 TO lf_nochange.
      CONTINUE.
    ENDIF.

*  Prüfen, ob schon im Amor ?
    SELECT SINGLE @abap_true FROM /adesso/wo_mon
       WHERE gpart = @ls_header-gpart
       AND   vkont = @ls_header-vkont
       INTO  @DATA(exists).

    IF exists = abap_true.
      ADD 1 TO lf_nochange.
      CONTINUE.
    ENDIF.

*   Prüfung Doku Ausbuchung hinterlegt
    CLEAR lf_wosta.
    CLEAR gs_wo_frei.
    LOOP AT gt_wo_frei INTO gs_wo_frei
         WHERE begru = gs_bgus-begru.

      lf_wosta = gs_wo_frei-freig_1.
      IF ls_header-betrw LE gs_wo_frei-betrg.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF lf_wosta = '10'.
      PERFORM check_docu_exists USING ls_header lf_exists.
      IF lf_exists = space.
        ADD 1 TO lf_nodocu.
        CONTINUE.
      ENDIF.
    ENDIF.


* Berechtigung für Status ?
    CLEAR gs_stat.
    READ TABLE gt_stat INTO gs_stat
         WITH KEY begru = gs_bgus-begru
                  ucomm = ff_ucomm
                  agsta = ls_header-agsta.

    IF sy-subrc NE 0.
      CLEAR gs_stat.
      ADD 1 TO lf_nochg_stat.
      CONTINUE.
    ENDIF.


*   Status Freigabe Ausbuchungen
    lf_wosta = '01'.

*     Ausbuchungen OrgBereich
    READ TABLE gt_wo_begr INTO gs_wo_begr
         WITH KEY begru = gs_bgus-begru.

    IF sy-subrc = 0.
      lf_orgbe = gs_wo_begr-orgbe.
    ENDIF.

* Ermittlung Fälligkeit letzte Schlußrechnung
    REFRESH lt_sr.
    CLEAR lf_faedn.
    LOOP AT t_items INTO ls_items
         WHERE gpart =  ls_header-gpart
         AND   vkont =  ls_header-vkont
         AND   hvorg IN gr_hvorg.
      APPEND ls_items TO lt_sr.
    ENDLOOP.
    SORT lt_sr BY faedn DESCENDING.
    READ TABLE lt_sr INTO ls_items INDEX 1.
    IF sy-subrc = 0.
      lf_faedn = ls_items-faedn.
    ELSE.
      lf_faedn = '99991231'.
    ENDIF.

* jetzt alle Posten bearbeiten
    REFRESH lt_wo_mon.
    LOOP AT t_items INTO ls_items
         WHERE gpart = ls_header-gpart
         AND   vkont = ls_header-vkont.

* Ausgeglichene oder stornierte Posten nicht berücksichtigen
      CHECK ls_items-augdt IS INITIAL.

      CLEAR ls_wo_mon.
      ls_items-agsta = gs_stat-set_agsta.
      MOVE-CORRESPONDING ls_items TO ls_wo_mon.

      SELECT SINGLE * FROM dfkkko
             INTO ls_dfkkko
             WHERE opbel = ls_items-opbel.

      IF sy-subrc = 0.
        ls_wo_mon-herkf = ls_dfkkko-herkf.
        ls_wo_mon-blart = ls_dfkkko-blart.
      ENDIF.

      ls_wo_mon-abgrd = lf_abgrd.
      ls_wo_mon-woigd = lf_woigd.
      ls_wo_mon-wohkf = lf_wohkf.
      ls_wo_mon-wosta = lf_wosta.
      ls_wo_mon-wovks = lf_wovks.
      ls_wo_mon-inkgp = ls_header-inkgp.
      ls_wo_mon-xsold = 'X'.
      ls_wo_mon-orgbe = lf_orgbe.
      ls_wo_mon-begru = gs_bgus-begru.
      ls_wo_mon-erdat = sy-datum.
      ls_wo_mon-ernam = sy-uname.

      IF ls_items-faedn GE lf_faedn.
        READ TABLE gt_nf_mahn INTO ls_nf_mahn
             WITH KEY hvorg = ls_items-hvorg.
        IF sy-subrc = 0.
          IF ls_items-tvorg BETWEEN ls_nf_mahn-tv_mahn_von AND
                                    ls_nf_mahn-tv_mahn_bis.
            ls_wo_mon-wovks = '00'.
            ls_wo_mon-xmnsr = 'X'.
          ENDIF.
        ENDIF.
      ENDIF.

      APPEND ls_wo_mon TO lt_wo_mon.

      MOVE-CORRESPONDING ls_wo_mon TO ls_wo_mon_h.
      ls_wo_mon_h-lfdnr = 1.
      ls_wo_mon_h-aenam = sy-uname.
      ls_wo_mon_h-aedat = sy-datlo.
      ls_wo_mon_h-acptm = sy-timlo.
      APPEND ls_wo_mon_h TO lt_wo_mon_h.

    ENDLOOP.

    CHECK lt_wo_mon[] IS NOT INITIAL.

    CALL FUNCTION '/ADESSO/WO_MON_DB_MODE'
      EXPORTING
        i_mode   = 'I'
      TABLES
        t_wo_mon = lt_wo_mon
      EXCEPTIONS
        error    = 1
        OTHERS   = 2.

    IF sy-subrc = 0.
      INSERT /adesso/wo_mon_h FROM TABLE lt_wo_mon_h
             ACCEPTING DUPLICATE KEYS.
      COMMIT WORK.
*   icon auf Verkauft setzen
      ls_header-agsta = '30'.
      PERFORM set_status_icon USING ls_header-agsta ls_header-status.

      ls_header-wosta = lf_wosta.
      CONCATENATE 'W' lf_wosta INTO lf_h_wosta.
      PERFORM set_status_icon USING lf_h_wosta ls_header-infosta.

      PERFORM set_mahnsperre  USING ls_header-gpart
                                    ls_header-vkont
                                    lf_lockr.

      IF lf_iverm NE space.
        PERFORM create_intverm  USING ls_header-gpart
                                      ls_header-vkont
                                      lf_iverm.
        ls_header-intverm = lf_iverm.
      ENDIF.

      ls_header-lockr   = lf_lockr.
      MODIFY t_header FROM ls_header.

      PERFORM create_contact
              USING ls_header-gpart
                    ls_header-vkont
                    ls_header-inkgp
                    'SELL'
                    lf_iverm
                    ' '.

      PERFORM create_iverm_wo USING ls_header-gpart
                                    ls_header-vkont
                                    ls_header-wosta
                                    lf_iverm
                                    'SELL'.

      LOOP AT lt_wo_mon INTO ls_wo_mon.
        PERFORM set_agsta_dfkkcoll
                USING ls_wo_mon-opbel
                      ls_wo_mon-inkps
                      c_mode_mod
                      ls_wo_mon-agsta
                      ls_wo_mon-xsold.
        LOOP AT t_items INTO ls_items
             WHERE opbel = ls_wo_mon-opbel
             AND   inkps = ls_wo_mon-inkps.
          PERFORM set_status_icon USING '30' ls_items-status.
          MODIFY t_items FROM ls_items.
        ENDLOOP.
      ENDLOOP.
    ELSE.
      ROLLBACK WORK.
      PERFORM set_status_icon USING 'ER' ls_header-status.
      MODIFY t_header FROM ls_header.
      LOOP AT t_items INTO ls_items
            WHERE gpart = ls_header-gpart
            AND   vkont = ls_header-vkont.
        PERFORM set_status_icon USING 'ER' ls_items-status.
        MODIFY t_items FROM ls_items.
      ENDLOOP.
    ENDIF.

  ENDLOOP.

  IF lf_nochange > 0.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-f12
        textline2 = TEXT-e04.
  ENDIF.

  IF lf_nochg_stat > 0.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-f12
        textline2 = TEXT-e09.
  ENDIF.

  IF lf_nodocu > 0.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-f12
        textline2 = TEXT-e34.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UCOM_SELL_DECL_HIER
*&---------------------------------------------------------------------*
FORM ucom_sell_decl_hier USING ff_ucomm LIKE sy-ucomm
                               ff_gplocked LIKE gv_gplocked.

  DATA: lf_abgrd  TYPE /adesso/wo_mon-abgrd.
  DATA: lf_woigd  TYPE /adesso/wo_mon-woigd.

  DATA: lf_rudat    TYPE rudat_kk.
  DATA: lf_rugrd    TYPE deagr_kk.

  DATA: lf_iverm  TYPE /adesso/inkasso_text.

* pop-up to select what to do
  CALL SCREEN 9003
     STARTING AT 21 2.

  CASE ok.
* Abbruch
    WHEN 'CANC'.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
        EXPORTING
          titel     = TEXT-inf
          textline1 = TEXT-f11
          textline2 = TEXT-e26.
      EXIT.

* Ablehnung Verkauf: erstmal Erneute Bearbeitung
    WHEN 'RCALL'.
      lf_iverm = wa_out-freetext.
      PERFORM sell_decl_rcall USING lf_iverm ff_ucomm ff_gplocked.

* Ablehnung Verkauf: Ausbuchung
    WHEN 'WROFF'.
      lf_abgrd = /adesso/wo_mon-abgrd.
      lf_woigd = /adesso/wo_mon-woigd.
      lf_iverm = wa_out-freetext.

      PERFORM sell_decl_wroff USING lf_abgrd lf_woigd lf_iverm
                                    ff_ucomm ff_gplocked.

  ENDCASE.
  CLEAR ok.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UCOM_WROFF_HIER
*&---------------------------------------------------------------------*
FORM ucom_wroff_hier USING ff_ucomm LIKE sy-ucomm
                           ff_gplocked LIKE gv_gplocked.

  DATA: ls_header     TYPE /adesso/inkasso_header.
  DATA: ls_items      TYPE /adesso/inkasso_items.
  DATA: lf_nochange   TYPE sy-tabix.
  DATA: lf_nochg_stat TYPE sy-tabix.
  DATA: lt_wo_mon     TYPE TABLE OF /adesso/wo_mon.
  DATA: ls_wo_mon     TYPE /adesso/wo_mon.
  DATA: lt_wo_mon_h   TYPE TABLE OF /adesso/wo_mon_h.
  DATA: ls_wo_mon_h   TYPE /adesso/wo_mon_h.
  DATA: ls_dfkkko     TYPE dfkkko.
  DATA: ls_cust       TYPE /adesso/ink_cust.
  DATA: lf_wohkf      TYPE /adesso/wo_mon-wohkf.
  DATA: lf_abgrd      TYPE /adesso/wo_mon-abgrd.
  DATA: lf_woigd      TYPE /adesso/wo_mon-woigd.
  DATA: lf_wosta      TYPE /adesso/wo_mon-wosta.
  DATA: lf_orgbe      TYPE /adesso/wo_mon-orgbe.
  DATA: lf_iverm      TYPE /adesso/inkasso_text.
  DATA: lf_lockr      TYPE lockr_kk.
  DATA: lt_sr         TYPE TABLE OF /adesso/inkasso_items.
  DATA: lf_faedn      TYPE faedn_kk.
  DATA: ls_nf_mahn    TYPE /adesso/ink_nfhf.  "HV / TV Mahnung
  DATA: lf_h_wosta(3).
  DATA: lf_exists     TYPE abap_bool.
  DATA: lf_nodocu     TYPE sy-tabix.

  READ TABLE gt_cust INTO gs_cust
       WITH KEY inkasso_option   = 'AUSBUCHUNG'
                inkasso_category = 'HERKUNFT'
                inkasso_field    = 'WOHKF'.

  IF sy-subrc = 0.
    lf_wohkf = gs_cust-inkasso_value.
  ENDIF.

  READ TABLE gt_cust INTO gs_cust
       WITH KEY inkasso_option   = 'AUSBUCHUNG'
                inkasso_category = 'MAHNSP'
                inkasso_field    = 'LOCKR'.

  IF sy-subrc = 0.
    lf_lockr = gs_cust-inkasso_value.
  ENDIF.

* pop-up to enter abgrd and woigd
  CALL SCREEN 9002
     STARTING AT 21 2.

  IF ok EQ 'CANC'.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-f10
        textline2 = TEXT-e27.
    EXIT.
  ELSE.
    lf_abgrd = /adesso/wo_mon-abgrd.
    lf_woigd = /adesso/wo_mon-woigd.
    lf_iverm = wa_out-freetext.
  ENDIF.
  CLEAR ok.

* Für Hierarchische Liste
  LOOP AT t_header INTO ls_header
       WHERE sel IS NOT INITIAL.

* VK für Bearbeitung gesperrt ?
    IF ls_header-locked IS NOT INITIAL.
      ff_gplocked = 'X'.
      CONTINUE.
    ENDIF.

    IF ls_header-satztyp = 'A'.
      ADD 1 TO lf_nochange.
      CONTINUE.
    ENDIF.

*   Prüfung Doku Ausbuchung hinterlegt
    CLEAR lf_wosta.
    CLEAR gs_wo_frei.
    LOOP AT gt_wo_frei INTO gs_wo_frei
         WHERE begru = gs_bgus-begru.

      lf_wosta = gs_wo_frei-freig_1.
      IF ls_header-betrw LE gs_wo_frei-betrg.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF lf_wosta = '10'.
      PERFORM check_docu_exists USING ls_header lf_exists.
      IF lf_exists = space.
        ADD 1 TO lf_nodocu.
        CONTINUE.
      ENDIF.
    ENDIF.

* Berechtigung für Status ?
    CLEAR gs_stat.
    READ TABLE gt_stat INTO gs_stat
         WITH KEY begru = gs_bgus-begru
                  ucomm = ff_ucomm
                  agsta = ls_header-agsta.

    IF sy-subrc NE 0.
      CLEAR gs_stat.
      ADD 1 TO lf_nochg_stat.
      CONTINUE.
    ENDIF.

*   Vormerkung zur Ausbuchungen
    lf_wosta = '01'.

*   Ausbuchungen OrgBereich
    READ TABLE gt_wo_begr INTO gs_wo_begr
         WITH KEY begru = gs_bgus-begru.

    IF sy-subrc = 0.
      lf_orgbe = gs_wo_begr-orgbe.
    ENDIF.

* Ermittlung Fälligkeit letzte Schlußrechnung
    REFRESH lt_sr.
    CLEAR lf_faedn.
    LOOP AT t_items INTO ls_items
         WHERE gpart =  ls_header-gpart
         AND   vkont =  ls_header-vkont
         AND   hvorg IN gr_hvorg.
      APPEND ls_items TO lt_sr.
    ENDLOOP.
    SORT lt_sr BY faedn DESCENDING.
    READ TABLE lt_sr INTO ls_items INDEX 1.
    IF sy-subrc = 0.
      lf_faedn = ls_items-faedn.
    ELSE.
      lf_faedn = '99991231'.
    ENDIF.

* jetzt alle Posten bearbeiten
    REFRESH lt_wo_mon.
    LOOP AT t_items INTO ls_items
         WHERE gpart = ls_header-gpart
         AND   vkont = ls_header-vkont.

* Ausgeglichene oder stornierte Posten nicht berücksichtigen
      CHECK ls_items-augdt IS INITIAL.

      CLEAR ls_wo_mon.
      ls_items-agsta = gs_stat-set_agsta.
      MOVE-CORRESPONDING ls_items TO ls_wo_mon.

      SELECT SINGLE * FROM dfkkko
             INTO ls_dfkkko
             WHERE opbel = ls_items-opbel.

      IF sy-subrc = 0.
        ls_wo_mon-herkf = ls_dfkkko-herkf.
        ls_wo_mon-blart = ls_dfkkko-blart.
      ENDIF.

      ls_wo_mon-abgrd = lf_abgrd.
      ls_wo_mon-wohkf = lf_wohkf.
      ls_wo_mon-wosta = lf_wosta.
      ls_wo_mon-woigd = lf_woigd.
      ls_wo_mon-wovks = '00'.
      ls_wo_mon-inkgp = ls_header-inkgp.
      ls_wo_mon-orgbe = lf_orgbe.
      ls_wo_mon-begru = gs_bgus-begru.
      ls_wo_mon-erdat = sy-datum.
      ls_wo_mon-ernam = sy-uname.

      IF ls_items-faedn GE lf_faedn.
        READ TABLE gt_nf_mahn INTO ls_nf_mahn
             WITH KEY hvorg = ls_items-hvorg.
        IF sy-subrc = 0.
          IF ls_items-tvorg BETWEEN ls_nf_mahn-tv_mahn_von AND
                                    ls_nf_mahn-tv_mahn_bis.
            ls_wo_mon-wovks = '00'.
            ls_wo_mon-xmnsr = 'X'.
          ENDIF.
        ENDIF.
      ENDIF.

      APPEND ls_wo_mon TO lt_wo_mon.

      MOVE-CORRESPONDING ls_wo_mon TO ls_wo_mon_h.
      ls_wo_mon_h-lfdnr = 1.
      ls_wo_mon_h-aenam = sy-uname.
      ls_wo_mon_h-aedat = sy-datlo.
      ls_wo_mon_h-acptm = sy-timlo.
      APPEND ls_wo_mon_h TO lt_wo_mon_h.

    ENDLOOP.

    CHECK lt_wo_mon[] IS NOT INITIAL.

    CALL FUNCTION '/ADESSO/WO_MON_DB_MODE'
      EXPORTING
        i_mode   = 'I'
      TABLES
        t_wo_mon = lt_wo_mon
      EXCEPTIONS
        error    = 1
        OTHERS   = 2.

    IF sy-subrc = 0.
      INSERT /adesso/wo_mon_h FROM TABLE lt_wo_mon_h
             ACCEPTING DUPLICATE KEYS.
      COMMIT WORK.

*   icon auf Ausbuchung setzen
      PERFORM set_status_icon USING '20' ls_header-status.

      CONCATENATE 'W' lf_wosta INTO lf_h_wosta.
      PERFORM set_status_icon USING lf_h_wosta ls_header-infosta.

      PERFORM set_mahnsperre  USING ls_header-gpart
                                    ls_header-vkont
                                    lf_lockr.

      IF lf_iverm NE space.
        PERFORM create_intverm  USING ls_header-gpart
                                      ls_header-vkont
                                      lf_iverm.
        ls_header-intverm = lf_iverm.
      ENDIF.

      ls_header-lockr   = lf_lockr.
      MODIFY t_header FROM ls_header.

      PERFORM create_contact
              USING ls_header-gpart
                    ls_header-vkont
                    ls_header-inkgp
                    'WROFF'
                    lf_iverm
                    '  '.

      PERFORM create_iverm_wo USING ls_header-gpart
                                    ls_header-vkont
                                    ls_header-wosta
                                    lf_iverm
                                    'WROFF'.

      LOOP AT lt_wo_mon INTO ls_wo_mon.
        PERFORM set_agsta_dfkkcoll
                USING ls_wo_mon-opbel
                      ls_wo_mon-inkps
                      c_mode_mod
                      ls_wo_mon-agsta
                      ls_wo_mon-xsold.
        LOOP AT t_items INTO ls_items
             WHERE opbel = ls_wo_mon-opbel
             AND   inkps = ls_wo_mon-inkps.
          PERFORM set_status_icon USING '20' ls_items-status.
          MODIFY t_items FROM ls_items.
        ENDLOOP.
      ENDLOOP.
    ELSE.
      ROLLBACK WORK.
      PERFORM set_status_icon USING 'ER' ls_header-status.
      MODIFY t_header FROM ls_header.
      LOOP AT t_items INTO ls_items
            WHERE gpart = ls_header-gpart
            AND   vkont = ls_header-vkont.
        PERFORM set_status_icon USING 'ER' ls_items-status.
        MODIFY t_items FROM ls_items.
      ENDLOOP.
    ENDIF.

  ENDLOOP.

  IF lf_nochange > 0.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-f10
        textline2 = TEXT-e04.
  ENDIF.

  IF lf_nochg_stat > 0.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-f10
        textline2 = TEXT-e04.
  ENDIF.

  IF lf_nodocu > 0.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-f10
        textline2 = TEXT-e34.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELL_DECL_WROFF
*&---------------------------------------------------------------------*
FORM sell_decl_wroff  USING    ff_abgrd TYPE abgrd_kk
                               ff_woigd TYPE /adesso/wo_mon-woigd
                               ff_iverm TYPE /adesso/inkasso_text
                               ff_ucomm LIKE sy-ucomm
                               ff_gplocked LIKE gv_gplocked.

  DATA: ls_header TYPE /adesso/inkasso_header.
  DATA: ls_items  TYPE /adesso/inkasso_items.
  DATA: lf_nochange TYPE sy-tabix.
  DATA: lf_nochg_stat TYPE sy-tabix.
  DATA: lt_wo_mon TYPE TABLE OF /adesso/wo_mon.
  DATA: ls_wo_mon TYPE /adesso/wo_mon.
  DATA: lt_wo_mon_h   TYPE TABLE OF /adesso/wo_mon_h.
  DATA: ls_wo_mon_h   TYPE /adesso/wo_mon_h.
  DATA: ls_dfkkko TYPE dfkkko.
  DATA: ls_cust   TYPE /adesso/ink_cust.
  DATA: lf_wohkf  TYPE /adesso/wo_mon-wohkf.
  DATA: lf_wosta  TYPE /adesso/wo_mon-wosta.
  DATA: lf_orgbe  TYPE /adesso/wo_mon-orgbe.
  DATA: lf_iverm  TYPE /adesso/inkasso_text.
  DATA: lf_lockr  TYPE lockr_kk.
  DATA: lt_sr     TYPE TABLE OF /adesso/inkasso_items.
  DATA: lf_faedn  TYPE faedn_kk.
  DATA: ls_nf_mahn TYPE /adesso/ink_nfhf.  "HV / TV Mahnung
  DATA: lf_h_wosta(3).
  DATA: lf_exists     TYPE abap_bool.
  DATA: lf_nodocu     TYPE sy-tabix.


  READ TABLE gt_cust INTO gs_cust
       WITH KEY inkasso_option   = 'AUSBUCHUNG'
                inkasso_category = 'HERKUNFT'
                inkasso_field    = 'WOHKF'.

  IF sy-subrc = 0.
    lf_wohkf = gs_cust-inkasso_value.
  ENDIF.

  READ TABLE gt_cust INTO gs_cust
       WITH KEY inkasso_option   = 'AUSBUCHUNG'
                inkasso_category = 'MAHNSP'
                inkasso_field    = 'LOCKR'.

  IF sy-subrc = 0.
    lf_lockr = gs_cust-inkasso_value.
  ENDIF.

* Für Hierarchische Liste
  LOOP AT t_header INTO ls_header
       WHERE sel IS NOT INITIAL.

* VK für Bearbeitung gesperrt ?
    IF ls_header-locked IS NOT INITIAL.
      ff_gplocked = 'X'.
      CONTINUE.
    ENDIF.

    IF ls_header-satztyp NE 'A'.
      ADD 1 TO lf_nochange.
      CONTINUE.
    ENDIF.

*  Prüfen, ob im Amor?
    SELECT SINGLE @abap_true FROM /adesso/wo_mon
       WHERE gpart = @ls_header-gpart
       AND   vkont = @ls_header-vkont
       INTO  @DATA(exists).

    IF exists = abap_true.
      ADD 1 TO lf_nochange.
      CONTINUE.
    ENDIF.

*   Prüfung Doku Ausbuchung hinterlegt
    CLEAR lf_wosta.
    CLEAR gs_wo_frei.
    LOOP AT gt_wo_frei INTO gs_wo_frei
         WHERE begru = gs_bgus-begru.

      lf_wosta = gs_wo_frei-freig_1.
      IF ls_header-betrw LE gs_wo_frei-betrg.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF lf_wosta = '10'.
      PERFORM check_docu_exists USING ls_header lf_exists.
      IF lf_exists = space.
        ADD 1 TO lf_nodocu.
        CONTINUE.
      ENDIF.
    ENDIF.

* Berechtigung für Status ?
    CLEAR gs_stat.
    READ TABLE gt_stat INTO gs_stat
         WITH KEY begru = gs_bgus-begru
                  ucomm = ff_ucomm
                  agsta = ls_header-agsta.

    IF sy-subrc NE 0.
      CLEAR gs_stat.
      ADD 1 TO lf_nochg_stat.
      CONTINUE.
    ENDIF.

*   Vormerkung zur Ausbuchungen
    lf_wosta = '01'.

*     Ausbuchungen OrgBereich
    READ TABLE gt_wo_begr INTO gs_wo_begr
         WITH KEY begru = gs_bgus-begru.

    IF sy-subrc = 0.
      lf_orgbe = gs_wo_begr-orgbe.
    ENDIF.

* Ermittlung Fälligkeit letzte Schlußrechnung
    REFRESH lt_sr.
    CLEAR lf_faedn.
    LOOP AT t_items INTO ls_items
         WHERE gpart =  ls_header-gpart
         AND   vkont =  ls_header-vkont
         AND   hvorg IN gr_hvorg.
      APPEND ls_items TO lt_sr.
    ENDLOOP.
    SORT lt_sr BY faedn DESCENDING.
    READ TABLE lt_sr INTO ls_items INDEX 1.
    IF sy-subrc = 0.
      lf_faedn = ls_items-faedn.
    ELSE.
      lf_faedn = '99991231'.
    ENDIF.

* jetzt alle Posten bearbeiten
    REFRESH lt_wo_mon.
    LOOP AT t_items INTO ls_items
         WHERE gpart = ls_header-gpart
         AND   vkont = ls_header-vkont.

* Ausgeglichene oder stornierte Posten nicht berücksichtigen
      CHECK ls_items-augdt IS INITIAL.

      CLEAR ls_wo_mon.
      ls_items-agsta = '31'.
      MOVE-CORRESPONDING ls_items TO ls_wo_mon.

      SELECT SINGLE * FROM dfkkko
             INTO ls_dfkkko
             WHERE opbel = ls_items-opbel.

      IF sy-subrc = 0.
        ls_wo_mon-herkf = ls_dfkkko-herkf.
        ls_wo_mon-blart = ls_dfkkko-blart.
      ENDIF.

      ls_wo_mon-abgrd = ff_abgrd.
      ls_wo_mon-wohkf = lf_wohkf.
      ls_wo_mon-wosta = lf_wosta.
      ls_wo_mon-woigd = ff_woigd.
      ls_wo_mon-wovks = '00'.
      ls_wo_mon-inkgp = ls_header-inkgp.
      ls_wo_mon-orgbe = lf_orgbe.
      ls_wo_mon-begru = gs_bgus-begru.
      ls_wo_mon-erdat = sy-datum.
      ls_wo_mon-ernam = sy-uname.

      IF ls_items-faedn GE lf_faedn.
        READ TABLE gt_nf_mahn INTO ls_nf_mahn
             WITH KEY hvorg = ls_items-hvorg.
        IF sy-subrc = 0.
          IF ls_items-tvorg BETWEEN ls_nf_mahn-tv_mahn_von AND
                                    ls_nf_mahn-tv_mahn_bis.
            ls_wo_mon-wovks = '00'.
            ls_wo_mon-xmnsr = 'X'.
          ENDIF.
        ENDIF.
      ENDIF.

      APPEND ls_wo_mon TO lt_wo_mon.

      MOVE-CORRESPONDING ls_wo_mon TO ls_wo_mon_h.
      ls_wo_mon_h-lfdnr = 1.
      ls_wo_mon_h-aenam = sy-uname.
      ls_wo_mon_h-aedat = sy-datlo.
      ls_wo_mon_h-acptm = sy-timlo.
      APPEND ls_wo_mon_h TO lt_wo_mon_h.

    ENDLOOP.

    CHECK lt_wo_mon[] IS NOT INITIAL.

    CALL FUNCTION '/ADESSO/WO_MON_DB_MODE'
      EXPORTING
        i_mode   = 'I'
      TABLES
        t_wo_mon = lt_wo_mon
      EXCEPTIONS
        error    = 1
        OTHERS   = 2.

    IF sy-subrc = 0.
      INSERT /adesso/wo_mon_h FROM TABLE lt_wo_mon_h
             ACCEPTING DUPLICATE KEYS.
      COMMIT WORK.
*    icon auf Ablehnung - Ausbuchung setzen
      ls_header-agsta = '31'.
      PERFORM set_status_icon USING ls_header-agsta ls_header-status.

      ls_header-wosta = lf_wosta.
      CONCATENATE 'W' lf_wosta INTO lf_h_wosta.
      PERFORM set_status_icon USING lf_h_wosta ls_header-infosta.

      PERFORM set_mahnsperre  USING ls_header-gpart
                                    ls_header-vkont
                                    lf_lockr.

      IF ff_iverm NE space.
        PERFORM create_intverm  USING ls_header-gpart
                                      ls_header-vkont
                                      ff_iverm.
        ls_header-intverm = ff_iverm.
      ENDIF.

      ls_header-lockr   = lf_lockr.
      MODIFY t_header FROM ls_header.

      PERFORM create_contact
              USING ls_header-gpart
                    ls_header-vkont
                    ls_header-inkgp
                    'SELL_DECL'
                    ff_iverm
                    ' '.

      PERFORM create_iverm_wo USING ls_header-gpart
                                    ls_header-vkont
                                    ls_header-wosta
                                    ff_iverm
                                    'SELL_DECL'.

      LOOP AT lt_wo_mon INTO ls_wo_mon.
        PERFORM set_agsta_dfkkcoll
                USING ls_wo_mon-opbel
                      ls_wo_mon-inkps
                      c_mode_mod
                      ls_wo_mon-agsta
                      ls_wo_mon-xsold.
        LOOP AT t_items INTO ls_items
             WHERE opbel = ls_wo_mon-opbel
             AND   inkps = ls_wo_mon-inkps.
          PERFORM set_status_icon USING '31' ls_items-status.
          MODIFY t_items FROM ls_items.
        ENDLOOP.
      ENDLOOP.
    ELSE.
      ROLLBACK WORK.
      PERFORM set_status_icon USING 'ER' ls_header-status.
      MODIFY t_header FROM ls_header.
      LOOP AT t_items INTO ls_items
            WHERE gpart = ls_header-gpart
            AND   vkont = ls_header-vkont.
        PERFORM set_status_icon USING 'ER' ls_items-status.
        MODIFY t_items FROM ls_items.
      ENDLOOP.
    ENDIF.

  ENDLOOP.

  IF lf_nochange > 0.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-f11
        textline2 = TEXT-e04.
  ENDIF.

  IF lf_nochg_stat > 0.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-f11
        textline2 = TEXT-e09.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  SELL_DECL_RCALL
*&---------------------------------------------------------------------*
FORM sell_decl_rcall   USING ff_iverm    TYPE /adesso/inkasso_text
                             ff_ucomm    LIKE sy-ucomm
                             ff_gplocked LIKE gv_gplocked.

  DATA: ls_header   TYPE /adesso/inkasso_header.
  DATA: ls_items    TYPE /adesso/inkasso_items.
  DATA: lf_nochange TYPE sy-tabix.
  DATA: lf_nochg_stat TYPE sy-tabix.
  DATA: ls_tfk050at TYPE tfk050at.
  DATA: lv_tabix    LIKE sy-tabix.
  DATA: lf_agstatxt TYPE val_text.
  DATA: lf_lockr    TYPE lockr_kk.
  DATA: lf_error.

  CLEAR:   lf_nochange.
  CLEAR:   lf_nochg_stat.
  CLEAR:   ff_gplocked.

  READ TABLE gt_cust INTO gs_cust
       WITH KEY inkasso_option   = 'VERKAUF_ABLEHNUNG'
                inkasso_category = 'MAHNSP'
                inkasso_field    = 'LOCKR'.

  IF sy-subrc = 0.
    lf_lockr = gs_cust-inkasso_value.
  ENDIF.

* Für Hierarchische Liste
  LOOP AT t_header INTO ls_header
       WHERE sel IS NOT INITIAL.

* VK für Bearbeitung gesperrt ?
    IF ls_header-locked IS NOT INITIAL.
      ff_gplocked = 'X'.
      CONTINUE.
    ENDIF.

    IF ls_header-satztyp NE 'A'.
      ADD 1 TO lf_nochange.
      CONTINUE.
    ENDIF.

* Berechtigung für Status ?
    CLEAR gs_stat.
    READ TABLE gt_stat INTO gs_stat
         WITH KEY begru = gs_bgus-begru
                  ucomm = ff_ucomm
                  agsta = ls_header-agsta.

    IF sy-subrc NE 0.
      CLEAR gs_stat.
      ADD 1 TO lf_nochg_stat.
      CONTINUE.
    ENDIF.

    LOOP AT t_items INTO ls_items
         WHERE gpart = ls_header-gpart
         AND   vkont = ls_header-vkont.

* Ausgeglichene oder stornierte Posten nicht berücksichtigen
      CHECK ls_items-augdt IS INITIAL.

      ls_items-agsta = '32'.
      PERFORM set_agsta_dfkkcoll
              USING ls_items-opbel
                    ls_items-inkps
                    c_mode_mod
                    ls_items-agsta
                    'X'.
      PERFORM set_status_icon USING ls_items-agsta ls_items-status.

      MODIFY t_items FROM ls_items.

    ENDLOOP.

    IF ff_iverm NE space.
      PERFORM create_intverm  USING ls_header-gpart
                                    ls_header-vkont
                                    ff_iverm.
      ls_header-intverm = ff_iverm.
    ENDIF.

*   ICON auf Ablehnung Verkauf Erneute Bearbeitungsetzen
    ls_header-agsta = '32'.
    PERFORM set_status_icon USING ls_header-agsta ls_header-status.
    PERFORM set_status_icon USING 'B' ls_header-infosta.
    PERFORM set_mahnsperre  USING ls_header-gpart
                                  ls_header-vkont
                                  lf_lockr.

    MODIFY t_header FROM ls_header.

  ENDLOOP.

  IF lf_nochange > 0.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-f11
        textline2 = TEXT-e04.
  ENDIF.

  IF lf_nochg_stat > 0.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-f11
        textline2 = TEXT-e09.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CREATE_INTVERM
*&---------------------------------------------------------------------*
FORM create_intverm  USING ff_gpart
                           ff_vkont
                           ff_iverm.

  DATA: lt_head     TYPE TABLE OF thead,
        ls_head     TYPE thead,
        ls_line     TYPE tline,
        lt_line     TYPE TABLE OF tline,
        ls_stxh     TYPE stxh,
        lt_stxh     TYPE TABLE OF stxh,
        lv_lfdnr(3) TYPE n,
        lv_pattern  TYPE char30,
        lv_select   TYPE char30,
        lv_object   TYPE /adesso/inkasso_value,
        lv_id       TYPE /adesso/inkasso_value.

  CLEAR gs_cust.
  READ TABLE gt_cust INTO gs_cust
    WITH KEY inkasso_option = 'INTVERM'
             inkasso_field  = 'TDOBJECT'.

  IF sy-subrc = 0.
    MOVE gs_cust-inkasso_value TO lv_object.
  ELSE.
    EXIT.
  ENDIF.

  CLEAR gs_cust.
  READ TABLE gt_cust INTO gs_cust
    WITH KEY inkasso_option = 'INTVERM'
             inkasso_field  = 'TDID'.

  IF sy-subrc = 0.
    MOVE gs_cust-inkasso_value TO lv_id.
  ELSE.
    EXIT.
  ENDIF.

  MOVE ff_iverm TO ls_line-tdline.
  APPEND ls_line TO lt_line.

  CONCATENATE ff_gpart '_'
              ff_vkont '_'
              INTO  lv_pattern.

  CONCATENATE lv_pattern '%' INTO lv_select.

  CLEAR lt_stxh.
  SELECT * FROM stxh INTO TABLE lt_stxh
           WHERE tdobject = lv_object
           AND tdname LIKE lv_select
           AND tdid = lv_id
           AND tdspras = sy-langu.

  SORT lt_stxh BY tdname DESCENDING.
  READ TABLE lt_stxh INTO ls_stxh INDEX 1.
  IF sy-subrc = 0.
    lv_lfdnr = ls_stxh-tdname+24(3).
    ADD 1 TO lv_lfdnr.
    CONCATENATE lv_pattern lv_lfdnr INTO ls_head-tdname.
  ELSE.
    CONCATENATE lv_pattern '001' INTO ls_head-tdname.
  ENDIF.

  ls_head-tdobject = lv_object.
  ls_head-tdid   = lv_id.
  ls_head-tdspras = sy-langu.

  CALL FUNCTION 'SAVE_TEXT'
    EXPORTING
      client   = sy-mandt
      header   = ls_head
    TABLES
      lines    = lt_line
    EXCEPTIONS
      id       = 1
      language = 2
      name     = 3
      object   = 4
      OTHERS   = 5.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UCOM_APPROVE_HIER
*&---------------------------------------------------------------------*
FORM ucom_approve_hier USING ff_ucomm LIKE sy-ucomm
                             ff_gplocked LIKE gv_gplocked.

  DATA: ls_header     TYPE /adesso/inkasso_header.
  DATA: ls_items      TYPE /adesso/inkasso_items.
  DATA: lf_nochange   TYPE sy-tabix.
  DATA: lf_nochg_stat TYPE sy-tabix.
  DATA: lf_no_appr    TYPE sy-tabix.
  DATA: lf_to_amor    TYPE sy-tabix.

  DATA: lt_wo_mon     TYPE TABLE OF /adesso/wo_mon.
  DATA: ls_wo_mon     TYPE /adesso/wo_mon.
  DATA: lt_wo_mon_h   TYPE TABLE OF /adesso/wo_mon_h.
  DATA: ls_wo_mon_h   TYPE /adesso/wo_mon_h.
  DATA: ls_cust       TYPE /adesso/ink_cust.
  DATA: lf_wosta      TYPE /adesso/wo_mon-wosta.
  DATA: lf_abgrd      TYPE /adesso/wo_mon-abgrd.
  DATA: lf_woigd      TYPE /adesso/wo_mon-woigd.
  DATA: lf_wovks      TYPE /adesso/wo_mon-wovks.
  DATA: lf_rc         TYPE syst_subrc.
  DATA: lf_h_wosta(3).
  DATA: lf_poserr   TYPE sy-tabix.
  DATA: lf_iverm    TYPE /adesso/inkasso_text.

* Für Hierarchische Liste
  LOOP AT t_header INTO ls_header
       WHERE sel IS NOT INITIAL.

* VK für Bearbeitung gesperrt ?
    IF ls_header-locked IS NOT INITIAL.
      ff_gplocked = 'X'.
      CONTINUE.
    ENDIF.

* Berechtigung für Status ?
    CLEAR gs_stat.
    READ TABLE gt_stat INTO gs_stat
         WITH KEY begru = gs_bgus-begru
                  ucomm = ff_ucomm
                  agsta = ls_header-agsta.

    IF sy-subrc NE 0.
      CLEAR gs_stat.
      ADD 1 TO lf_nochg_stat.
      CONTINUE.
    ENDIF.

* Genehmigung
    CASE ls_header-wosta.
*     Vorgemerkte
      WHEN '01'.
*     Zur Korrektur
      WHEN '02'.
      WHEN OTHERS.
        CLEAR gs_stat.
        ADD 1 TO lf_nochange.
        CONTINUE.
    ENDCASE.

    CLEAR ls_wo_mon.
    SELECT * FROM /adesso/wo_mon
           WHERE vkont =  @ls_header-vkont
           AND   wosta =  @ls_header-wosta
           AND   hvorg IN @gr_hvorg
           INTO  @ls_wo_mon
           UP TO 1 ROWS.
    ENDSELECT.

    IF sy-subrc = 0.
      /adesso/wo_mon-gpart = ls_wo_mon-gpart.
      /adesso/wo_mon-vkont = ls_wo_mon-vkont.
      /adesso/wo_mon-agsta = ls_wo_mon-agsta.
      /adesso/wo_mon-wovks = ls_wo_mon-wovks.
      /adesso/wo_mon-abgrd = ls_wo_mon-abgrd.
      /adesso/wo_mon-woigd = ls_wo_mon-woigd.
    ELSE.
      ADD 1 TO lf_nochange.
      CONTINUE.
    ENDIF.

* pop-up to enter text
    CALL SCREEN 9005
       STARTING AT 21 2.

    IF ok EQ 'CANC'.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
        EXPORTING
          titel     = TEXT-inf
          textline1 = TEXT-f14
          textline2 = TEXT-e33.
      CONTINUE.
    ELSE.
      lf_iverm = wa_out-freetext.
      lf_wovks = /adesso/wo_mon-wovks.
      lf_abgrd = /adesso/wo_mon-abgrd.
      lf_woigd = /adesso/wo_mon-woigd.
    ENDIF.
    CLEAR ok.

*   Genehmigung Ausbuchungen / Verkauf
    CLEAR lf_wosta.
    CLEAR gs_wo_frei.
    LOOP AT gt_wo_frei INTO gs_wo_frei
         WHERE begru = gs_bgus-begru.

      lf_wosta = gs_wo_frei-freig_1.
      IF ls_header-betrw LE gs_wo_frei-betrg.
        EXIT.
      ENDIF.
    ENDLOOP.

    CASE lf_wosta.
      WHEN space.
        ADD 1 TO lf_no_appr.
        CONTINUE.
      WHEN '10'.
        ADD 1 TO lf_to_amor.
      WHEN OTHERS.
    ENDCASE.

* jetzt alle Posten bearbeiten
    REFRESH lt_wo_mon.
    LOOP AT t_items INTO ls_items
         WHERE gpart = ls_header-gpart
         AND   vkont = ls_header-vkont.

** Ausgeglichene oder stornierte Posten nicht berücksichtigen
*      CHECK ls_items-augdt IS INITIAL.

      CLEAR ls_wo_mon.
      SELECT SINGLE * FROM /adesso/wo_mon
             INTO  ls_wo_mon
             WHERE opbel = ls_items-opbel
             AND   opupw = ls_items-opupw
             AND   opupk = ls_items-opupk
             AND   opupz = ls_items-opupz.

      IF sy-subrc = 0.
        ls_wo_mon-wosta = lf_wosta.
        ls_wo_mon-abgrd = lf_abgrd.
        ls_wo_mon-woigd = lf_woigd.
        ls_wo_mon-aenam = sy-uname.
        ls_wo_mon-aedat = sy-datlo.
        ls_wo_mon-acptm = sy-timlo.
*       Verkaufsquote nur ändern wenn nicht Mahnung nach SR
        IF ls_wo_mon-xmnsr NE 'X'.
          ls_wo_mon-wovks = lf_wovks.
        ENDIF.
        MOVE-CORRESPONDING ls_wo_mon TO ls_wo_mon_h.

        CLEAR lf_rc.
        PERFORM update_womon_wohist
                USING ls_wo_mon
                      ls_wo_mon_h
                      c_mode_upd
                      lf_rc.

        IF lf_rc NE 0.
          PERFORM set_status_icon USING 'ER' ls_items-status.
          PERFORM set_status_icon USING 'ER' ls_header-status.
          ADD 1 TO lf_poserr.
        ENDIF.

      ELSE.
*        PERFORM set_status_icon USING 'ER' ls_items-status.
*        PERFORM set_status_icon USING 'ER' ls_header-status.
*        ADD 1 TO lf_poserr.
      ENDIF.

      MODIFY t_items FROM ls_items.

    ENDLOOP.

*   ICON auf Genehmigungsstatus setzen
    IF lf_poserr = 0.
      CASE ls_header-wosta.
*     Vorgemerkte
        WHEN '01'.
          PERFORM create_iverm_wo USING ls_header-gpart
                                        ls_header-vkont
                                        lf_wosta
                                        lf_iverm
                                        'APPROVE'.
*     Zur Korrektur
        WHEN '02'.
          ls_header-intverm = text-coa.
          PERFORM create_intverm USING ls_header-gpart
                                       ls_header-vkont
                                       ls_header-intverm.
          PERFORM create_iverm_wo USING ls_header-gpart
                                        ls_header-vkont
                                        lf_wosta
                                        lf_iverm
                                        'CORRECT'.
      ENDCASE.
      ls_header-wosta = lf_wosta.
      CONCATENATE 'W' lf_wosta INTO lf_h_wosta.
      PERFORM set_status_icon USING lf_h_wosta ls_header-infosta.

* nicht schön aber erstmal so ok
      ls_header-ic_docu+10(10) = space.
      CONCATENATE ls_header-ic_docu  ' '
                  lf_abgrd '_'
                  lf_woigd '_'
                  lf_wovks
                  INTO ls_header-ic_docu.

    ENDIF.

    MODIFY t_header FROM ls_header.

  ENDLOOP.


  IF lf_nochange > 0.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-f13
        textline2 = TEXT-e29.
  ENDIF.

  IF lf_nochg_stat > 0.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-f13
        textline2 = TEXT-e04.
  ENDIF.

  IF lf_no_appr > 0.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-f13
        textline2 = TEXT-e30.
  ENDIF.

  IF lf_to_amor > 0.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-f13
        textline2 = TEXT-e31.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UCOM_REVOKE_HIER
*&---------------------------------------------------------------------*
FORM ucom_revoke_hier USING ff_ucomm LIKE sy-ucomm
                            ff_gplocked LIKE gv_gplocked.

  DATA: ls_header     TYPE /adesso/inkasso_header.
  DATA: ls_items      TYPE /adesso/inkasso_items.
  DATA: ls_ink_infi   TYPE /adesso/ink_infi.
  DATA: lt_ink_infi   TYPE TABLE OF /adesso/ink_infi.
  DATA: lf_nochange   TYPE sy-tabix.
  DATA: lf_nochg_stat TYPE sy-tabix.
  DATA: lt_wo_mon     TYPE TABLE OF /adesso/wo_mon.
  DATA: ls_wo_mon     TYPE /adesso/wo_mon.
  DATA: lt_wo_mon_h   TYPE TABLE OF /adesso/wo_mon_h.
  DATA: ls_wo_mon_h   TYPE /adesso/wo_mon_h.
  DATA: ls_cust       TYPE /adesso/ink_cust.
  DATA: lf_wosta      TYPE /adesso/wo_mon-wosta.
  DATA: lf_rc         TYPE syst_subrc.
  DATA: lf_mode       TYPE char1.
  DATA: lf_h_wosta(3).
  DATA: lf_poserr   TYPE sy-tabix.
  DATA: lf_iverm  TYPE /adesso/inkasso_text.


* Für Hierarchische Liste
  LOOP AT t_header INTO ls_header
       WHERE sel IS NOT INITIAL.

* VK für Bearbeitung gesperrt ?
    IF ls_header-locked IS NOT INITIAL.
      ff_gplocked = 'X'.
      CONTINUE.
    ENDIF.

* Berechtigung für Status ?
    CLEAR gs_stat.
    READ TABLE gt_stat INTO gs_stat
         WITH KEY begru = gs_bgus-begru
                  ucomm = ff_ucomm
                  agsta = ls_header-agsta.

    IF sy-subrc NE 0.
      CLEAR gs_stat.
      ADD 1 TO lf_nochg_stat.
      CONTINUE.
    ENDIF.

* Ablehnung
    CASE ls_header-wosta.
*     Vorgemerkte
      WHEN '01'.
*     Zur Korrektur
      WHEN '02'.
      WHEN OTHERS.
        CLEAR gs_stat.
        ADD 1 TO lf_nochange.
        CONTINUE.
    ENDCASE.

    CLEAR ls_wo_mon.
    SELECT * FROM /adesso/wo_mon
           WHERE vkont =  @ls_header-vkont
           AND   wosta =  @ls_header-wosta
           AND   hvorg IN @gr_hvorg
           INTO  @ls_wo_mon
           UP TO 1 ROWS.
    ENDSELECT.

    IF sy-subrc = 0.
      /adesso/wo_mon-gpart = ls_wo_mon-gpart.
      /adesso/wo_mon-vkont = ls_wo_mon-vkont.
      /adesso/wo_mon-agsta = ls_wo_mon-agsta.
      /adesso/wo_mon-wovks = ls_wo_mon-wovks.
      /adesso/wo_mon-abgrd = ls_wo_mon-abgrd.
      /adesso/wo_mon-woigd = ls_wo_mon-woigd.
    ELSE.
      ADD 1 TO lf_nochange.
      CONTINUE.
    ENDIF.

* pop-up to enter text
    CALL SCREEN 9005
       STARTING AT 21 2.

    IF ok EQ 'CANC'.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
        EXPORTING
          titel     = TEXT-inf
          textline1 = TEXT-f14
          textline2 = TEXT-e32.
      CONTINUE.
    ELSE.
      lf_iverm = wa_out-freetext.
    ENDIF.
    CLEAR ok.

* jetzt alle Posten bearbeiten
    REFRESH lt_wo_mon.
    LOOP AT t_items INTO ls_items
         WHERE gpart = ls_header-gpart
         AND   vkont = ls_header-vkont.

* Ausgeglichene oder stornierte Posten nicht berücksichtigen
* das hier nicht prüfen da auch diese in wo_mon stehen können
*      CHECK ls_items-augdt IS INITIAL.

      CLEAR ls_wo_mon.
      SELECT SINGLE * FROM /adesso/wo_mon
             INTO  ls_wo_mon
             WHERE opbel = ls_items-opbel
             AND   opupw = ls_items-opupw
             AND   opupk = ls_items-opupk
             AND   opupz = ls_items-opupz.

      IF sy-subrc = 0.
        MOVE-CORRESPONDING ls_wo_mon TO ls_wo_mon_h.

        CLEAR lf_rc.
        PERFORM update_womon_wohist
                USING ls_wo_mon
                      ls_wo_mon_h
                      c_mode_del
                      lf_rc.

        IF lf_rc NE 0.
          ROLLBACK WORK.
          PERFORM set_status_icon USING 'ER' ls_items-status.
          PERFORM set_status_icon USING 'ER' ls_header-status.
          ADD 1 TO lf_poserr.

        ELSE.
          PERFORM get_last_agsta
                  USING ls_items-opbel
                        ls_items-inkps
                        ls_items-augdt
                  CHANGING ls_items-agsta
                           lf_rc.
          IF lf_rc = 0.
            PERFORM set_agsta_dfkkcoll
                    USING ls_items-opbel
                          ls_items-inkps
                          c_mode_mod
                          ls_items-agsta
                          ' '.
          ENDIF.
          PERFORM set_status_icon USING ls_items-agsta ls_items-status.
        ENDIF.

      ELSE.
*        PERFORM set_status_icon USING 'ER' ls_items-status.
*        PERFORM set_status_icon USING 'ER' ls_header-status.
*        ADD 1 TO lf_poserr.
      ENDIF.


      MODIFY t_items FROM ls_items.

    ENDLOOP.

    IF lf_poserr = 0.

*     Keine Ausbuchung, Rücknahme WO Status
      CLEAR ls_header-wosta.

      CASE ls_header-agsta.
*         Ankaufangebot InkGP
        WHEN '30' OR '31' OR '32'.
          PERFORM set_status_icon USING 'A' ls_header-infosta.
        WHEN OTHERS.
          REFRESH: lt_ink_infi.
          CLEAR:   ls_ink_infi.
*          Letzte Info vom Inkassobüro
          SELECT * FROM /adesso/ink_infi
                 INTO TABLE lt_ink_infi
                 WHERE gpart = ls_header-gpart
                 AND   vkont = ls_header-vkont
                 AND   inkgp = ls_header-inkgp.

          SORT lt_ink_infi BY infodat DESCENDING.
          READ TABLE lt_ink_infi INTO ls_ink_infi INDEX 1.

          IF ls_ink_infi-abbruch = const_abbri.
            PERFORM set_status_icon USING 'C' ls_header-infosta.
          ELSE.
            PERFORM set_status_icon USING 'I' ls_header-infosta.
          ENDIF.
      ENDCASE.

*     Status für header au ITEM Schlußrechnung ermitteln
      LOOP AT t_items INTO ls_items
           WHERE gpart =  ls_header-gpart
           AND   vkont =  ls_header-vkont
           AND   hvorg IN gr_hvorg.
        ls_header-agsta = ls_items-agsta.
      ENDLOOP.

      PERFORM set_status_icon USING ls_header-agsta ls_header-status.

      ls_header-lockr = p_lockr.
      PERFORM set_mahnsperre USING   ls_header-gpart
                                     ls_header-vkont
                                     p_lockr.

      IF lf_iverm NE space.
        PERFORM create_intverm  USING ls_header-gpart
                                      ls_header-vkont
                                      lf_iverm.
        ls_header-intverm = lf_iverm.
      ENDIF.

      PERFORM create_iverm_wo USING ls_header-gpart
                                    ls_header-vkont
                                    ls_header-wosta
                                    lf_iverm
                                    'REVOKE'.
    ENDIF.

    MODIFY t_header FROM ls_header.

  ENDLOOP.

  IF lf_nochange > 0.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-f14
        textline2 = TEXT-e29.
  ENDIF.

  IF lf_nochg_stat > 0.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = TEXT-inf
        textline1 = TEXT-f14
        textline2 = TEXT-e04.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UPDATE_WOMON_WOHIST
*&---------------------------------------------------------------------*
FORM update_womon_wohist USING fs_wo_mon   TYPE /adesso/wo_mon
                               fs_wo_mon_h TYPE /adesso/wo_mon_h
                               fv_mode     TYPE char1
                               fv_rc.

  DATA: lt_wo_mon TYPE TABLE OF /adesso/wo_mon.
  DATA: h_lfdnr   LIKE /adesso/wo_mon_h-lfdnr.

  APPEND fs_wo_mon TO lt_wo_mon.
  CHECK lt_wo_mon[] IS NOT INITIAL.

  CALL FUNCTION '/ADESSO/WO_MON_DB_MODE'
    EXPORTING
      i_mode   = fv_mode
    TABLES
      t_wo_mon = lt_wo_mon
    EXCEPTIONS
      error    = 1
      OTHERS   = 2.

  IF sy-subrc = 0.

    SELECT MAX( lfdnr ) FROM /adesso/wo_mon_h
           INTO h_lfdnr
           WHERE opbel = fs_wo_mon-opbel
           AND   opupw = fs_wo_mon-opupw
           AND   opupk = fs_wo_mon-opupk
           AND   opupz = fs_wo_mon-opupz.

    ADD 1 TO h_lfdnr.

    fs_wo_mon_h-lfdnr = h_lfdnr.
    fs_wo_mon_h-aenam = sy-uname.
    fs_wo_mon_h-aedat = sy-datlo.
    fs_wo_mon_h-acptm = sy-timlo.

    INSERT /adesso/wo_mon_h FROM fs_wo_mon_h.
    fv_rc = sy-subrc.

  ELSE.
    fv_rc = sy-subrc.
  ENDIF.


  IF fv_rc = 0.
    COMMIT WORK.
  ELSE.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UCOM_DOWNL_XLS_HIER
*&---------------------------------------------------------------------*
FORM ucom_downl_xls_hier TABLES ft_header   STRUCTURE /adesso/inkasso_header
                                ft_items    STRUCTURE /adesso/inkasso_items
                                ft_fieldc_h TYPE slis_t_fieldcat_alv
                                ft_fieldc_i TYPE slis_t_fieldcat_alv
                         USING  ff_ucomm.

  CASE ff_ucomm.

    WHEN 'XLS_HEAD'.

      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
        EXPORTING
          i_callback_program       = g_repid
          i_grid_title             = 'EXCEL Download Kopf'
          i_callback_pf_status_set = 'PF_STATUS_XXL'
          it_fieldcat              = ft_fieldc_h[]
          i_screen_start_column    = 5
          i_screen_start_line      = 5
          i_screen_end_column      = 150
          i_screen_end_line        = 20
        TABLES
          t_outtab                 = ft_header
        EXCEPTIONS
          program_error            = 1
          OTHERS                   = 2.

      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN 'XLS_ITEM'.

      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
        EXPORTING
          i_callback_program       = g_repid
          i_grid_title             = 'EXCEL Download Position'
          i_callback_pf_status_set = 'PF_STATUS_XXL'
          it_fieldcat              = ft_fieldc_i[]
          i_screen_start_column    = 5
          i_screen_start_line      = 5
          i_screen_end_column      = 150
          i_screen_end_line        = 20
        TABLES
          t_outtab                 = ft_items
        EXCEPTIONS
          program_error            = 1
          OTHERS                   = 2.

      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CREATE_IVERM_WO
*&---------------------------------------------------------------------*
FORM create_iverm_wo USING ff_gpart
                           ff_vkont
                           ff_wosta
                           ff_iverm
                           ff_proc.

  DATA: ls_cust_wo TYPE /adesso/wo_cust.  "Customizing Ausbuchungen

  DATA: lt_head     TYPE TABLE OF thead,
        ls_head     TYPE thead,
        ls_line     TYPE tline,
        lt_line     TYPE TABLE OF tline,
        ls_stxh     TYPE stxh,
        lt_stxh     TYPE TABLE OF stxh,
        lv_lfdnr(3) TYPE n,
        lv_pattern  TYPE char30,
        lv_select   TYPE char30,
        lv_object   TYPE /adesso/inkasso_value,
        lv_id       TYPE /adesso/inkasso_value.
  DATA: lv_text_appr(20).

  CLEAR ls_cust_wo.
  READ TABLE gt_cust_wo INTO ls_cust_wo
    WITH KEY wo_option    = 'INTVERM'
             wo_category  = 'OBJECT'
             wo_field     = 'TDOBJECT'.

  IF sy-subrc = 0.
    MOVE ls_cust_wo-wo_value TO lv_object.
  ELSE.
    EXIT.
  ENDIF.

  CLEAR ls_cust_wo.
  READ TABLE gt_cust_wo INTO ls_cust_wo
    WITH KEY wo_option    = 'INTVERM'
             wo_category  = 'APPROVAL'
             wo_field     = 'TDID'.

  IF sy-subrc = 0.
    MOVE ls_cust_wo-wo_value TO lv_id.
  ELSE.
    EXIT.
  ENDIF.

  CASE ff_wosta.
    WHEN '10'.
      lv_text_appr = TEXT-w10.
    WHEN '11'.
      lv_text_appr = TEXT-w11.
    WHEN '12'.
      lv_text_appr = TEXT-w12.
  ENDCASE.

  CASE ff_proc.
    WHEN 'WROFF'.
      CONCATENATE TEXT-036
                  TEXT-a20
                  INTO ls_line-tdline
                  SEPARATED BY space.
    WHEN 'SELL'.
      CONCATENATE TEXT-036
                  TEXT-a30
                  INTO ls_line-tdline
                  SEPARATED BY space.
    WHEN 'SELL_DECL'.
      CONCATENATE TEXT-036
                  TEXT-a31
                  INTO ls_line-tdline
                  SEPARATED BY space.
    WHEN 'APPROVE'.
      ls_line-tdline = lv_text_appr.
    WHEN 'CORRECT'.
      CONCATENATE lv_text_appr
                  TEXT-cor
                  INTO ls_line-tdline
                  SEPARATED BY space.
    WHEN 'REVOKE'.
      ls_line-tdline = TEXT-037.
  ENDCASE.
  APPEND ls_line TO lt_line.

  MOVE ff_iverm TO ls_line-tdline.
  APPEND ls_line TO lt_line.

  CONCATENATE ff_gpart '_'
              ff_vkont '_'
              INTO  lv_pattern.

  CONCATENATE lv_pattern '%' INTO lv_select.

  CLEAR lt_stxh.
  SELECT * FROM stxh INTO TABLE lt_stxh
           WHERE tdobject = lv_object
           AND tdname LIKE lv_select
           AND tdid = lv_id
           AND tdspras = sy-langu.

  SORT lt_stxh BY tdname DESCENDING.
  READ TABLE lt_stxh INTO ls_stxh INDEX 1.
  IF sy-subrc = 0.
    lv_lfdnr = ls_stxh-tdname+24(3).
    ADD 1 TO lv_lfdnr.
    CONCATENATE lv_pattern lv_lfdnr INTO ls_head-tdname.
  ELSE.
    CONCATENATE lv_pattern '001' INTO ls_head-tdname.
  ENDIF.

  ls_head-tdobject = lv_object.
  ls_head-tdid   = lv_id.
  ls_head-tdspras = sy-langu.

  CALL FUNCTION 'SAVE_TEXT'
    EXPORTING
      client   = sy-mandt
      header   = ls_head
    TABLES
      lines    = lt_line
    EXCEPTIONS
      id       = 1
      language = 2
      name     = 3
      object   = 4
      OTHERS   = 5.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_LAST_AGSTA
*&---------------------------------------------------------------------*
FORM get_last_agsta  USING ff_opbel
                           ff_inkps
                           ff_augdt
                     CHANGING ff_agsta
                              ff_subrc.

  DATA: lv_lfdnr TYPE lfdnr_kk.
  DATA: lv_agsta TYPE agsta_kk.
  DATA: ls_dfkkcoll TYPE dfkkcollh.

  ff_subrc = 4.

* Ausgeglichene oder stornierte Posten nicht berücksichtigen
  CHECK ff_augdt IS INITIAL.

  SELECT MAX( lfdnr ) FROM dfkkcollh
         INTO  lv_lfdnr
         WHERE opbel = ff_opbel
         AND   inkps = ff_inkps
         AND   agsta = ff_agsta.

  lv_lfdnr = lv_lfdnr - 1.

  SELECT SINGLE agsta FROM dfkkcollh
         INTO  lv_agsta
         WHERE opbel = ff_opbel
         AND   inkps = ff_inkps
         AND   lfdnr = lv_lfdnr.

  IF sy-subrc = 0.
    ff_agsta = lv_agsta.
    ff_subrc = sy-subrc.
  ENDIF.

ENDFORM.
