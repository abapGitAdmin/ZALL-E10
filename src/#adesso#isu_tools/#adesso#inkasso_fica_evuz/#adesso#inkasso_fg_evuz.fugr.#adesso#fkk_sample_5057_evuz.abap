FUNCTION /adesso/fkk_sample_5057_evuz.
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

  DATA: lt_cust TYPE TABLE OF /adesso/i_cuevuz,
        ls_cust TYPE /adesso/i_cuevuz.

  DATA: lv_class    TYPE ct_cclass,
        lv_activity TYPE ct_activit,
        lv_type     TYPE ct_ctype,
        lv_coming   TYPE ct_coming.
  DATA: lv_lockr    TYPE  lockr_kk.
  DATA: lv_vertyp   TYPE  vertyp_kk.

  FIELD-SYMBOLS: <fs_dfkkcol> TYPE dfkkcoll.
  FIELD-SYMBOLS: <fs_fkkop> TYPE fkkop.
  DATA: ls_fkkop TYPE fkkop.
  DATA: lt_fkkop TYPE TABLE OF fkkop.

  DATA: ls_vkp    TYPE bapiisuvkp.
  DATA: ls_vkpx   TYPE bapiisuvkpx.
  DATA: lt_return TYPE bapiret2.


* --> Nuss 06.2018
  SELECT * FROM /adesso/i_cuevuz INTO TABLE lt_cust.
  SORT lt_cust.

* Kontaktklasse
  CLEAR ls_cust.
  READ TABLE lt_cust INTO ls_cust
    WITH KEY inkasso_option   = 'CONTACT'
             inkasso_category = 'CLASS'
             inkasso_field    = 'CCLASS'.
  IF sy-subrc = 0.
    lv_class = ls_cust-inkasso_value.
  ELSE.
    lv_class = '0200'.
  ENDIF.

* Kontakt-Aktivität
  CLEAR ls_cust.
  READ TABLE lt_cust INTO ls_cust
    WITH KEY inkasso_option   = 'CONTACT'
             inkasso_category = 'ACTIVITY'
             inkasso_field    = 'ACTIVITY'.
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
             inkasso_field    = 'CTYPE'.

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
             inkasso_field    = 'F_COMING'.

  IF sy-subrc = 0.
    lv_coming = ls_cust-inkasso_value.
  ELSE.
    lv_coming = '2'.
  ENDIF.

* Mahnsperre
  CLEAR ls_cust.
  READ TABLE lt_cust INTO ls_cust
    WITH KEY inkasso_option = 'MANSP_KK'
             inkasso_field  = 'LOCKR'.

  IF sy-subrc = 0.
    lv_lockr = ls_cust-inkasso_value.
  ENDIF.

* Verrechnungstyp
  CLEAR ls_cust.
  READ TABLE lt_cust INTO ls_cust
    WITH KEY inkasso_option = 'VERTYP_KK'
             inkasso_field  = 'VERTYP'.

  IF sy-subrc = 0.
    lv_vertyp = ls_cust-inkasso_value.
  ENDIF.

  SORT t_dfkkcol BY vkont.

  CLEAR h_vkont.

* Folgeaktivität nach Abgabe an Inkasso: CIC-Kontakt anlegen und mahnsperre setzen
  LOOP AT  t_dfkkcol ASSIGNING <fs_dfkkcol>.

    IF h_vkont NE <fs_dfkkcol>-vkont.

      CLEAR: lv_auto_data.

      lv_vkont   = <fs_dfkkcol>-vkont.
      lv_partner = <fs_dfkkcol>-gpart.

*{ ADD ILIASS ECHOUAIBI FÜR EVUZ
* Beginn Mahnsperre VK setzn-----------------------------------------------------*
      PERFORM set_mahnsperre USING   lv_partner
                                     lv_vkont
                                     lv_lockr.
* END Mahnsperre VK setzn-----------------------------------------------------*
*} END ILIASS ECHOUAIBI FÜR EVUZ

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

*      Name zum Inkassobüro lesen
      SELECT SINGLE * FROM but000
             INTO lv_but000
             WHERE partner = <fs_dfkkcol>-inkgp.

      CONCATENATE TEXT-001
*                  lv_but000-partner
                  lv_but000-name_org1
                  lv_but000-name_first
                  lv_but000-name_last
                  lv_but000-name_grp1
                  INTO lv_textline-tdline
                  SEPARATED BY space.

      lv_textline-tdformat = '='.
      APPEND lv_textline TO lv_auto_data-text-textt.

      lv_object-objrole = 'X00040002001'.
      lv_object-objtype = 'ISUACCOUNT'.
      CONCATENATE lv_vkont lv_partner INTO lv_object-objkey.
      APPEND lv_object TO lv_auto_data-iobjects.

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

     h_vkont = <fs_dfkkcol>-vkont.

    ENDIF.
  ENDLOOP.

ENDFUNCTION.

FORM del_mahnsperre  USING  pv_gpart
                            pv_vkont.

  DATA: lt_locks  TYPE  dfkklocks_t.
  DATA: ls_locks  TYPE  dfkklocks.

  CALL FUNCTION 'FKK_S_LOCK_GET_FOR_VKONT'
    EXPORTING
      iv_vkont = pv_vkont
      iv_gpart = pv_gpart
      iv_date  = sy-datum
      iv_proid = '01'
    IMPORTING
      et_locks = lt_locks.

* Alle derzeitige Mahnsperre löschen
  LOOP AT lt_locks INTO ls_locks
       WHERE lotyp = '06'
       AND   proid = '01'.

    CALL FUNCTION 'FKK_S_LOCK_DELETE'
      EXPORTING
        i_loobj1 = ls_locks-loobj1
        i_gpart  = ls_locks-gpart
        i_vkont  = ls_locks-vkont
        i_proid  = ls_locks-proid
        i_lotyp  = ls_locks-lotyp
        i_lockr  = ls_locks-lockr
        i_fdate  = ls_locks-fdate
        i_tdate  = ls_locks-tdate
      EXCEPTIONS
        OTHERS   = 7.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDLOOP.

ENDFORM.

FORM set_mahnsperre  USING  pv_gpart
                            pv_vkont
                            pv_lockr.

  DATA: lv_loobj1 LIKE dfkklocks-loobj1.

* Schon Mahnsperre auf VK vorhanden, dann vorher löschen
  PERFORM del_mahnsperre  USING pv_gpart pv_vkont.

* Dann Mahnsperre setzen
  CONCATENATE pv_vkont pv_gpart INTO lv_loobj1.

  CALL FUNCTION 'FKK_S_LOCK_CREATE'
    EXPORTING
      i_loobj1              = lv_loobj1
      i_gpart               = pv_gpart
      i_vkont               = pv_vkont
      i_proid               = '01'
      i_lotyp               = '06'
      i_lockr               = pv_lockr
      i_fdate               = sy-datum
      i_tdate               = '99991231'
      i_upd_online          = 'X'
    EXCEPTIONS
      already_exist         = 1
      imp_data_not_complete = 2
      no_authority          = 3
      enqueue_lock          = 4
      wrong_data            = 5
      OTHERS                = 6.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.
