FUNCTION /adesso/fkk_sample_5057.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      T_DFKKCOL STRUCTURE  DFKKCOLL
*"      T_FKKOP STRUCTURE  FKKOP
*"----------------------------------------------------------------------
*  INCLUDE: <cntn01>.
* Folgeaktivität nach Abgabe an Inkasso: CIC-Kontakt anlegen
* Folgeaktivität nach Abgabe an Inkasso: Ausgleichssperre auf abgegebene Posten

  DATA: h_gpart   LIKE t_dfkkcol-gpart,
        h2_gpart  LIKE t_dfkkcol-gpart,
        h_vkont   LIKE t_fkkop-vkont,
        h_opbel   LIKE t_dfkkcol-opbel,
        hwo_vkont LIKE t_dfkkcol-vkont.

  DATA: lw_fkkcl       TYPE fkkcl,
        lt_fkkcl       TYPE TABLE OF fkkcl,
        lw_fkkko       TYPE fkkko,
        lw_tfk001b     TYPE tfk001b,
        lw_rfka1       TYPE rfka1,
        lt_fkkcl_split TYPE TABLE OF fkkop_split_by_key,
        lw_ibuktab     TYPE ibuktab,
        lt_ibuktab     TYPE TABLE OF ibuktab,
        lw_fkkop       TYPE fkkop,
        lv_opbel       TYPE fkkko-opbel,
        l_summe        TYPE betrw_kk.


  DATA: lv_partner  TYPE but000-partner.
  DATA: lv_vkont    TYPE fkkvkp-vkont .              "Nuss 08.02.2018
  DATA: lv_auto_data TYPE bpc01_bcontact_auto .
  DATA: lv_object TYPE bpc_obj.          "Nuss 08.02.2018
  DATA: lv_bpcontact TYPE ct_contact.
  DATA: lv_textline TYPE bpc01_text_line.
  DATA: lv_but000   TYPE but000.

* --> Nuss 06.2018
  DATA: lt_cust TYPE TABLE OF /adesso/ink_cust,
        ls_cust TYPE /adesso/ink_cust.

  DATA: lv_class    TYPE ct_cclass,
        lv_activity TYPE ct_activit,
        lv_type     TYPE ct_ctype,
        lv_coming   TYPE ct_coming,
        lv_funcc    TYPE funcc_kk.
* <-- Nuss 06.2018

  FIELD-SYMBOLS: <fs_dfkkcol> TYPE dfkkcoll.
  FIELD-SYMBOLS: <fs_fkkop> TYPE fkkop.
  DATA: ls_fkkop TYPE fkkop.
  DATA: lt_fkkop TYPE TABLE OF fkkop.
  DATA: lv_lockr  TYPE  lockr_kk.
  DATA: ls_ink_addi TYPE /adesso/ink_addi.

* --> Nuss 06.2018
  SELECT * FROM /adesso/ink_cust INTO TABLE lt_cust
     WHERE inkasso_option = 'CONTACT'.

* Kontaktklasse
  CLEAR ls_cust.
  READ TABLE lt_cust INTO ls_cust
    WITH KEY inkasso_option   = 'CONTACT'
             inkasso_category = 'CLASS'
             inkasso_field    = 'CCLASS'
             inkasso_id       = '1'.
  IF sy-subrc = 0.
    lv_class = ls_cust-inkasso_value.
  ELSE.
    lv_class = '0200'.
  ENDIF.

* Kontakt-Aktivität
  CLEAR ls_cust.
  READ TABLE lt_cust INTO ls_cust
    WITH KEY inkasso_option   = 'CONTACT'
             inkasso_category = 'COLLECTION'
             inkasso_field    = 'ACTIVITY'
             inkasso_id       = '1'.
  IF sy-subrc = 0.
    lv_activity = ls_cust-inkasso_value.
  ELSE.
    lv_activity = '0005'.
  ENDIF.

* Kontakt-Typ
  CLEAR ls_cust.
  READ TABLE lt_cust INTO ls_cust
    WITH KEY inkasso_option   = 'CONTACT'
             inkasso_category = 'TYPE'
             inkasso_field    = 'CTYPE'
             inkasso_id       = '1'.
  IF sy-subrc = 0.
    lv_type = ls_cust-inkasso_value.
  ELSE.
    lv_type = '002'.
  ENDIF.

* Richtung
  CLEAR ls_cust.
  READ TABLE lt_cust INTO ls_cust
    WITH KEY inkasso_option   = 'CONTACT'
             inkasso_category = 'DIRECTION'
             inkasso_field    = 'F_COMING'
             inkasso_id       = '1'.
  IF sy-subrc = 0.
    lv_coming = ls_cust-inkasso_value.
  ELSE.
    lv_coming = '2'.
  ENDIF.
* <-- Nuss 06.2018

  SORT t_dfkkcol BY vkont.

* Folgeaktivität nach Abgabe an Inkasso: CIC-Kontakt anlegen
  LOOP AT  t_dfkkcol ASSIGNING <fs_dfkkcol>.

    IF h_vkont NE <fs_dfkkcol>-vkont.

      h_vkont = <fs_dfkkcol>-vkont.

      CLEAR: lv_auto_data.

      lv_vkont   = <fs_dfkkcol>-vkont.
      lv_partner = <fs_dfkkcol>-gpart.

      lv_auto_data-bcontd-mandt       = sy-mandt.
      lv_auto_data-bcontd-partner     = lv_partner.
      lv_auto_data-bcontd-cclass      = lv_class.
      lv_auto_data-bcontd-activity    = lv_activity.
      lv_auto_data-bcontd-ctype       = lv_type.
      lv_auto_data-bcontd-ctdate      = sy-datum.
      lv_auto_data-bcontd-cttime      = sy-uzeit.
      lv_auto_data-bcontd-erdat       = sy-datum.
      lv_auto_data-bcontd-ernam       = sy-uname.
      lv_auto_data-text-langu         = sy-langu.
      lv_auto_data-bcontd_use         = 'X'.

*     Name zum Inkassobüro lesen
      SELECT SINGLE * FROM but000
             INTO lv_but000
             WHERE partner = <fs_dfkkcol>-inkgp.

*     Name Inkasso-Büro über Customizing
      CLEAR ls_cust.
      READ TABLE lt_cust INTO ls_cust
        WITH KEY inkasso_option   = 'CONTACT'
                 inkasso_category = 'NAME_IGP'
                 inkasso_field = <fs_dfkkcol>-inkgp.

      IF sy-subrc = 0.
        CONCATENATE TEXT-018
                    <fs_dfkkcol>-vkont
                    TEXT-019
                    lv_but000-partner
                    ls_cust-inkasso_value
                    INTO lv_textline-tdline
                    SEPARATED BY space.
      ELSE.
        CONCATENATE TEXT-018
                    <fs_dfkkcol>-vkont
                    TEXT-019
                    lv_but000-partner
                    lv_but000-name_org1
                    lv_but000-name_first
                    lv_but000-name_last
                    lv_but000-name_grp1
                    INTO lv_textline-tdline
                    SEPARATED BY space.
      ENDIF.

      lv_textline-tdformat = '/'.
      APPEND lv_textline TO lv_auto_data-text-textt.

      PERFORM get_intverm
              TABLES lv_auto_data-text-textt
              USING  <fs_dfkkcol>-vkont
                     <fs_dfkkcol>-gpart.

      lv_object-objrole = 'X00040002001'.
      lv_object-objtype = 'ISUACCOUNT'.
      CONCATENATE lv_vkont lv_partner INTO lv_object-objkey.
      APPEND lv_object TO lv_auto_data-iobjects.

* abweichender FuBa
      CLEAR ls_cust.
      READ TABLE lt_cust INTO ls_cust
        WITH KEY inkasso_option   = 'CONTACT'
                 inkasso_category = 'FUBA'.

      IF sy-subrc = 0.
        lv_funcc = ls_cust-inkasso_value.
        CALL FUNCTION lv_funcc
          EXPORTING
            x_upd_online    = 'X'
            x_no_dialog     = 'X'
            x_auto          = lv_auto_data
            x_partner       = lv_partner
          IMPORTING
            y_new_bpcontact = lv_bpcontact
          EXCEPTIONS
            existing        = 1
            foreign_lock    = 2
            number_error    = 3
            general_fault   = 4
            input_error     = 5
            not_authorized  = 6
            OTHERS          = 7.

        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.
      ELSE.
        CALL FUNCTION 'BCONTACT_CREATE'
          EXPORTING
            x_upd_online    = 'X'
            x_no_dialog     = 'X'
            x_auto          = lv_auto_data
            x_partner       = lv_partner
          IMPORTING
            y_new_bpcontact = lv_bpcontact
          EXCEPTIONS
            existing        = 1
            foreign_lock    = 2
            number_error    = 3
            general_fault   = 4
            input_error     = 5
            not_authorized  = 6
            OTHERS          = 7.

        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.
*------
      ENDIF.

** Freitext und Zusatzinfos lesen
      SELECT SINGLE * FROM /adesso/ink_addi INTO ls_ink_addi
        WHERE gpart = <fs_dfkkcol>-gpart
          AND vkont = <fs_dfkkcol>-vkont
          AND inkgp = <fs_dfkkcol>-inkgp.

      IF sy-subrc = 0.
        UPDATE /adesso/ink_addi SET agdat = <fs_dfkkcol>-agdat
               WHERE gpart = <fs_dfkkcol>-gpart
               AND   vkont = <fs_dfkkcol>-vkont
               AND   inkgp = <fs_dfkkcol>-inkgp.
      ENDIF.

    ENDIF.

  ENDLOOP.

* Folgeaktivität nach Abgabe an Inkasso: Ausgleichssperre auf abgegebene Posten
  REFRESH lt_cust.
  SELECT * FROM /adesso/ink_cust INTO TABLE lt_cust
     WHERE inkasso_option = 'AUSGL_SPERRE'.

* Kontaktklasse
  CLEAR ls_cust.
  READ TABLE lt_cust INTO ls_cust
    WITH KEY inkasso_option = 'AUSGL_SPERRE'
             inkasso_field = 'CRLLO'.

* Nur wenn Sperrgrund gecustomized
  IF sy-subrc = 0.
    lv_lockr = ls_cust-inkasso_value.

    LOOP AT  t_fkkop ASSIGNING <fs_fkkop>.

      AT NEW opbel.
        REFRESH lt_fkkop.
      ENDAT.

      ls_fkkop = <fs_fkkop>.
      APPEND ls_fkkop TO lt_fkkop.

      AT END OF opupz.

        CALL FUNCTION 'FKK_S_LOCK_CREATE_FOR_DOCITEMS'
          EXPORTING
            iv_opbel              = <fs_fkkop>-opbel
            it_fkkop              = lt_fkkop
            iv_proid              = '09'
            iv_lockr              = lv_lockr
            iv_fdate              = sy-datum
            iv_tdate              = '99991231'
          EXCEPTIONS
            wrong_call            = 1
            foreign_lock          = 2
            error_resolve         = 3
            error_create_lock     = 4
            error_change_document = 5
            OTHERS                = 6.

        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      ENDAT.

    ENDLOOP.
  ENDIF.

** AUSBUCHEN: Abgegebene Posten unter 300 #.
*
**
**
**
*  lw_fkkko-mandt = sy-mandt.
**  lw_fkkko-fikey = 'TEST_NUSS01'. " ABSTIMMSCHLÜSSEL MUSS NOCH GENERIERT WERDEN (FUBA)
*  lw_fkkko-applk = 'R'.
*  lw_fkkko-blart = 'AU'.
*  lw_fkkko-herkf = '16'.
*  lw_fkkko-ernam = sy-uname.
*  lw_fkkko-cpudt = sy-datum.
*  lw_fkkko-cputm = sy-uzeit.
*  lw_fkkko-waers = 'EUR'.
*  lw_fkkko-bldat = sy-datum.
*  lw_fkkko-budat = sy-datum.
*  lw_fkkko-wwert = sy-datum.
**  lw_fkkko-abgrd = '01'.
*
*  IF lw_fkkko-fikey IS INITIAL.
**      s_rfk00-blart = 'AB'.
*    PERFORM get_fikey USING     lw_fkkko-blart
*                      CHANGING  lw_fkkko-fikey.
*  ENDIF.
*
*
** SELECT * FROM TFK001B INTO CORRESPONDING FIELDS OF TABLE lt_ibuktab.
*
**  lw_ibuktab-bukrs = '0010'.
**  APPEND lw_ibuktab TO lt_ibuktab.
*
**  APPEND lw_TFK001B TO lt_ibuktab.
*
*  SORT t_fkkop BY vkont.
*
*  DATA lw_fkkop_help TYPE fkkop.
*
*  LOOP AT t_fkkop INTO lw_fkkop.
*
*    lw_ibuktab-bukrs = lw_fkkop-bukrs.
*    APPEND lw_ibuktab TO lt_ibuktab.
*
*    DELETE ADJACENT DUPLICATES FROM lt_ibuktab.
*
*    IF lw_fkkop-vkont NE hwo_vkont.
*
*      LOOP AT t_fkkop INTO lw_fkkop_help
*        WHERE vkont = lw_fkkop-vkont.
*
*        lw_ibuktab-bukrs = lw_fkkop_help-bukrs.
*        APPEND lw_ibuktab TO lt_ibuktab.
*        SORT lt_ibuktab BY bukrs.
*        DELETE ADJACENT DUPLICATES FROM lt_ibuktab.
*
*
*        MOVE-CORRESPONDING lw_fkkop_help TO lw_fkkcl.
*        lw_fkkcl-augbw = lw_fkkop_help-betrw.
*        lw_fkkcl-augbh = lw_fkkop_help-betrw.
*        lw_fkkcl-augrd = '04'.
*        lw_fkkcl-xaktp = 'X'.
*        IF lw_fkkcl-stakz IS NOT INITIAL.
*          lw_fkkcl-xclon = 'X'.
*        ENDIF.
**        CLEAR lw_fkkcl-stakz.
*
*
*
*        APPEND lw_fkkcl TO lt_fkkcl.
*
*        DELETE lt_fkkcl WHERE augst = 9.    " Bereits ausgebuchte löschen!!!
*
*        l_summe = l_summe + lw_fkkop_help-betrw.
*
*      ENDLOOP.
*
*      IF lt_fkkcl IS NOT INITIAL.
*
*        IF l_summe < 20.
*
*          lw_fkkko-abgrd = '01'.  " Ausbuchungsgrund für < 20 #
*
**       Geschäftspartner sperren
*          READ TABLE ht_enqtab WITH KEY gpart = lw_fkkop_help-gpart.
*          IF sy-subrc NE 0.
*            ht_enqtab-gpart = lw_fkkop_help-gpart.
*            APPEND ht_enqtab.
*          ENDIF.
*
*          PERFORM dfkkop_enqueue.
*
*          CALL FUNCTION 'FKK_WRITEOFF'
*            EXPORTING
*              i_fkkko       = lw_fkkko
*              i_rfka1       = lw_rfka1
**             I_TRANSACTION = 'FP04'
*            IMPORTING
*              e_opbel       = lv_opbel
*            TABLES
*              t_fkkcl       = lt_fkkcl
*              t_fkkcl_split = lt_fkkcl_split
*              t_buktab      = lt_ibuktab.
*
**  * --- Dequeue all business partner ------------------------------------
*          CALL FUNCTION 'FKK_OPEN_ITEM_DEQUEUE'.
*
*        ELSEIF l_summe < 300.
*
*          lw_fkkko-abgrd = '03'.  " Ausbuchungsgrund für 20 - 300 #
*
**       Geschäftspartner sperren
*          READ TABLE ht_enqtab WITH KEY gpart = lw_fkkop_help-gpart.
*          IF sy-subrc NE 0.
*            ht_enqtab-gpart = lw_fkkop_help-gpart.
*            APPEND ht_enqtab.
*          ENDIF.
*
*          PERFORM dfkkop_enqueue.
*
*          CALL FUNCTION 'FKK_WRITEOFF'
*            EXPORTING
*              i_fkkko       = lw_fkkko
*              i_rfka1       = lw_rfka1
**             I_TRANSACTION = 'FP04'
*            IMPORTING
*              e_opbel       = lv_opbel
*            TABLES
*              t_fkkcl       = lt_fkkcl
*              t_fkkcl_split = lt_fkkcl_split
*              t_buktab      = lt_ibuktab.
*
**  * --- Dequeue all business partner ------------------------------------
*          CALL FUNCTION 'FKK_OPEN_ITEM_DEQUEUE'.
*        ENDIF.
*
*        CLEAR lt_fkkcl.
*        CLEAR l_summe.
*
*
*
**      ENDLOOP.
*
*      ENDIF.
*    ENDIF.
*
*    hwo_vkont = lw_fkkop-vkont.
*
*  ENDLOOP.
*
ENDFUNCTION.
**
**&---------------------------------------------------------------------*
**&      Form  get_fikey
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**      -->S_RFK00-BLART  text
**      <--S_RFK00-FIKEY  text
**----------------------------------------------------------------------*
*FORM get_fikey USING    s_rfk00-blart
*               CHANGING s_rfk00-fikey.
*
*  DATA: f_fikey   TYPE fkkko-fikey,
*      f_fikey_d TYPE fkkko-fikey,
*      f_num(3)  TYPE n,
*      f_xclos   TYPE dfkksumc-xclos.
*
*  CLEAR  s_rfk00-fikey.
*
*  DO 999 TIMES.                         "bis zu 100 mögliche Abstimmschlüssel
*    f_fikey(2)   = s_rfk00-blart.
*    f_fikey+2(2) = sy-datum+2(2).
*    f_fikey+4(4) = sy-datum+4(4).
*    f_fikey+8(1) = '-'.
*    f_fikey+9(3) = f_num.
*
*    SELECT SINGLE fikey xclos
*      INTO (f_fikey_d, f_xclos)
*      FROM dfkksumc
*      WHERE fikey  = f_fikey.
*
*    IF sy-subrc <> 0.                   "Anlegen Abstimmschlüssel oder beenden der Schleife
*
** FIKEY für die folgenden Buchungen reservieren
*      CALL FUNCTION 'FKK_FIKEY_OPEN'
*        EXPORTING
*          i_fikey = f_fikey.
*      EXIT.
*    ENDIF.
*    IF f_xclos = 'X'.
*      ADD 1 TO f_num.
*    ELSE.
*      EXIT.
*    ENDIF.
*  ENDDO.
*
** FIKEY prüfen, ob er verwendet werden darf
*  CALL FUNCTION 'FKK_FIKEY_CHECK'
*    EXPORTING
*      i_fikey                = f_fikey
*      i_open_without_dialog  = 'X'
*      i_non_existing_allowed = 'X'.
*
*  s_rfk00-fikey = f_fikey.
* ENDFORM.                    " GET_FIKEY
* GET_FIKEY
